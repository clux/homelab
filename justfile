REPO := "clux/homelab"
open := if os() == "macos" { "open" } else { "xdg-open" }

[private]
default:
  @just --list --unsorted --color=always

# -----------------------------------------------------------------------------
# manual steps

[group('manual'), doc('make flux reconcile without git changes')]
ping:
  flux reconcile source git homelab -n flux

[group('manual'), confirm("apply crds to current context?"), doc('apply crds manually')]
crds: # idempotent apply, should be done if changes in folder after gen-crds
  kubectl apply -f crds/ -R --force-conflicts --server-side

[group('manual'), confirm("apply bootstrap to current context?"), doc('apply bootstrap configuration manually')]
bootstrap:
  kubectl apply -f bootstrap/ -R --force-conflicts --server-side

[group('manual'), doc('manual update chart dependencies for a given chart folder')]
update chart:
  (cd ./charts/{{chart}} && sd '  version: .*' '  version: "*"' Chart.yaml && helm dependency update)
  git add charts/{{chart}}
  just gen-{{chart}}
  git add deploy/{{chart}}

# -----------------------------------------------------------------------------
# generators - generated folders are watched by flux

[group('gen'), doc('generate everything from sources')]
gen: gen-promstack gen-crds gen-dashboards gen-flux

[group('gen'), doc('generate prom from charts')]
gen-promstack: (gen-prom-raw "./charts/promstack/homelab.yaml")
[private]
gen-prom-raw values:
  rm -rf deploy/promstack
  helm template promstack ./charts/promstack --create-namespace -n monitoring --skip-tests -f {{values}} --output-dir deploy/promstack
  # remove unavoidable, bad dashboards
  rm deploy/promstack/promstack/charts/kube-prometheus-stack/templates/grafana/dashboards-1.14/{grafana-overview,alertmanager-overview,prometheus}.yaml
  rm -f deploy/promstack/promstack/charts/kube-prometheus-stack/templates/grafana/dashboards-1.14/{nodes.yaml,node-cluster-rsrc-use.yaml,node-rsrc-use.yaml}
  rm -f deploy/promstack/promstack/charts/kube-prometheus-stack/templates/grafana/dashboards-1.14/{kubelet,k8s-resources-multicluster}.yaml
  # change default refreshes on grafana dashboards to be 1m rather than 10s
  fd -g '*.yaml' deploy/promstack/promstack/charts/kube-prometheus-stack/templates/grafana/dashboards-1.14/ -x sd '"refresh":"10s"' '"refresh":"1m"' {}
  # change default time range to be now-12h rather than now-1h on boards that cannot handle 2 days...
  fd -g '*.yaml' deploy/promstack/promstack/charts/kube-prometheus-stack/templates/grafana/dashboards-1.14/ -x sd '"from":"now-1h"' '"from":"now-12h"' {}
  # change default time range to be now-2d rather than now-1h on solid dashboards...
  fd -g 'k8s*.yaml' deploy/promstack/promstack/charts/kube-prometheus-stack/templates/grafana/dashboards-1.14/ -x sd '"from":"now-12h"' '"from":"now-2d"' {}

[group('gen'), doc('generate flux from charts')]
gen-flux:
  rm -rf deploy/flux
  helm template flux ./charts/flux --create-namespace -n flux --skip-tests --output-dir deploy/flux

[group('gen'), doc('generate renovate from charts')]
gen-renovate:
  rm -rf deploy/renovate
  helm template renovate ./charts/renovate -n renovate --skip-tests --output-dir deploy/renovate/kube -f charts/renovate/kube.yaml --debug
  cat deploy/renovate/kube/renovate/charts/renovate/templates/config.yaml | yq '.data["config.json"]' -r | jq
  helm template renovate ./charts/renovate -n renovate --skip-tests --output-dir deploy/renovate/clux -f charts/renovate/clux.yaml --debug
  cat deploy/renovate/clux/renovate/charts/renovate/templates/config.yaml | yq '.data["config.json"]' -r | jq

[group('gen'), doc('generate crds (run AFTER gen-prom)')]
gen-crds:
  #!/usr/bin/env bash
  version="$(cat deploy/promstack/promstack/charts/kube-prometheus-stack/templates/prometheus-operator/deployment.yaml | yq '.spec.template.spec.containers[0].image' -y | cut -d':' -f2)"
  echo "Inferred prometheus-operator version: ${version}"
  crdbase="https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/${version}/example/prometheus-operator-crd/monitoring.coreos.com"
  rm -rf crds && mkdir crds && cd crds
  declare -a crds=("prometheusrules" "podmonitors" "probes" "prometheuses" "alertmanagerconfigs" "servicemonitors" "alertmanagers")
  for crd in "${crds[@]}"; do
    curl -sSL "${crdbase}_${crd}.yaml" -O
  done

[group('gen'), doc('generate dashboard yaml from grafana json in dashboards folder')]
gen-dashboards:
  rm -f deploy/dashboards/*.yaml
  fd -g '*.json' dashboards --type f -x ./mkdashboard.sh {}

# -----------------------------------------------------------------------------
# local testing methods

[private] # locally apply prometheus into a local cluster
local-prom:
  helm install promstack clux/promstack -f charts/promstack/local.yaml
  helm install dashboards clux/cx-dashboards -f charts/cx-dashboards/local.yaml

[private] # forward prometheus default port to check metrics ui
forward-prom:
  (sleep 2 && {{open}} http://0.0.0.0:9090/) &
  kubectl port-forward -n monitoring service/prometheus-operated 9090:9090

[private] # forward grafana default port to look at dashboards
forward-grafana:
  (sleep 2 && {{open}} http://0.0.0.0:3030/) &
  kubectl port-forward -n monitoring service/promstack-grafana 3030:80

# -----------------------------------------------------------------------------
# initial cluster/dev env setup - only needed once

[private] # initialise helm dependencies
init-helm:
  helm repo add grafana https://grafana.github.io/helm-charts
  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
  helm repo add fluxcd-community https://fluxcd-community.github.io/helm-charts
  helm repo add renovate https://docs.renovatebot.com/helm-charts

[private, confirm("Recreate flux secret?")] # single-setup flux with a GITHUB_TOKEN on env
init-flux:
  #!/usr/bin/env bash
  flux create secret git flux-key-{{ REPO }} \
    --namespace=flux \
    --url=ssh://git@github.com/{{ REPO }}.git
  kubectl get secret flux-key-{{ REPO }} -n flux -oyaml | yq '.data["identity.pub"]' -r | base64 -d > keyfile
  gh repo deploy-key add keyfile -R {{ REPO }} -t "flux-${USER}" -w
  rm keyfile

# -----------------------------------------------------------------------------
# hacks to actually release dashboards - not really necessary for myself

[group('release'), doc('generate cx-dashboard chart from grafana json in dashboard folder')]
release-dashboard-chart:
  #!/usr/bin/env bash
  rm -f charts/cx-dashboards/templates/*.yaml
  declare -a released=("home" "prometheus" "alertmanager" "flux" "machine")
  for board in "${released[@]}"; do
    ./mkdashboard.sh dashboards/${board}.json charts/cx-dashboards/templates
  done
  # escape grafana double braces used in legends to prevent them being seen by helm
  sd '\{\{(\s*\w*\s*)\}\}' '{{{{`{{{{`}} $1 {{{{`}}`}}' charts/cx-dashboards/templates/*.yaml
  # make our static clux.dev url a helm configurable value
  sd 'http://(\w+).clux.dev' '{{{{ .Values.urls.$1 }}' charts/cx-dashboards/templates/*.yaml
  for board in "${released[@]}"; do
    # Add do not modify and enabled headers/footer
    sd -f=s '(.*)' '{{{{- if .Values.dashboards.THEACTUALBOARD.enabled }}\n# GENERATED DO NOT EDIT\n$1\n\n{{{{- end }}\n' charts/cx-dashboards/templates/cx${board}.yaml
    sd 'THEACTUALBOARD' "$board" charts/cx-dashboards/templates/cx${board}.yaml
  done
  # ensure it can be generated
  rm -rf deploy/dashtest/
  helm template dashboards ./charts/cx-dashboards -n default --output-dir deploy/dashtest --debug
