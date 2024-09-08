# cx-dashboards

A set of modern dashboards for small clusters with prometheus backlinks.

## Installation
Can be installed in two ways:

1. Via [raw json](https://github.com/clux/homelab/tree/main/dashboards) into grafana - but, you'll likely need `sed` or similar to change hardcoded urls
2. Via this chart, then you can change the urls in the [values.yaml](https://github.com/clux/homelab/blob/main/charts/cx-dashboards/values.yaml)

The mandatory parameters are the ingress urls for your prometheus and alertmanager - which grafana does not know about.

### Configmap Loading

ConfigMap dashboards can be loaded into grafana via the dashboard sidecar. It can be setup as follows in `kube-prometheus-stack`:

```yaml
  grafana:
    sidecar:
      enabled: true
      dashboards:
        enabled: true
        resource: configmap
        searchNamespace: monitoring
        provider:
          name: sidecarProvider
          allowUiUpdates: false
```

### Home Dashboard

The [cx / home](https://github.com/clux/homelab/blob/main/charts/cx-dashboards/templates/cxhome.yaml) is intended to be set as the grafana home dashboard.

This can be done through grafana configuration:

```yaml
  grafana:
    grafana.ini:
      dashboards:
        default_home_dashboard_path: /tmp/dashboards/cxhome.json
```

### Alertmanager Dashboard

The [cx / alertmanager](https://github.com/clux/homelab/blob/main/charts/cx-dashboards/templates/cxalertmanager.yaml) dashboard cross-link to a stand-alone alertmanager (rather than grafana cloud's builtin alertmanager), and use metrics obtained from this. They rely on a couple of features from `kube-prometheus-stack`:

```yaml
  alertmanager:
    enableFeatures: ["receiver-name-in-metrics"]
  grafana:
    grafana.ini:
      unified_alerting:
        enabled: false
      alerting:
        enabled: false
```

The feature is from [alertmanager 0.27](https://github.com/prometheus/alertmanager/releases/tag/v0.27.0).

## Contribution

This chart is generated from the [raw grafana json folder](https://github.com/clux/homelab/tree/main/dashboards). Reasoned tweaks are considered, but please only git add any relevant changes (no url changes).
