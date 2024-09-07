# CX Dashboards

A set of modern dashboards for small clusters with prometheus backlinks.

## Installation
Can be installed in two ways:

1. Via [raw json](https://github.com/clux/homelab/tree/main/dashboards) into grafana - but, you'll likely need `sed` or similar to change hardcoded urls
2. Via this chart, then you can change the urls in the [values.yaml](https://github.com/clux/homelab/blob/main/charts/dashboards/values.yaml)

The mandatory parameters are the ingress urls for your prometheus and alertmanager - which grafana does not know about.

## Contribution

This chart is generated from the [raw grafana json folder](https://github.com/clux/homelab/tree/main/dashboards). Reasoned tweaks are considered, but please only git add any relevant changes (no url changes).
