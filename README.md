# Kubernetes Homelab Automation and Helm Charts

[![Release Charts](https://github.com/clux/homelab/actions/workflows/release.yml/badge.svg)](https://github.com/clux/homelab/actions/workflows/release.yml)
[![Releases downloads](https://img.shields.io/github/downloads/clux/homelab/total.svg)](https://github.com/clux/homelab/releases)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

Minimal helm chart wrappers for minimal home lab setups.

## Chart Usage

Add the [helm](https://helm.sh) repo:

```console
helm repo add clux https://clux.github.io/homelab
```

then `helm search repo clux` to see the charts.

## Charts

- [promstack](https://github.com/clux/homelab/tree/main/charts/promstack) :: A low-footprint prometheus/observability chart
- [cx-dashboards](https://github.com/clux/homelab/tree/main/charts/cx-dashboards) :: A set of modern dashboards for small clusters with prometheus backlinks
