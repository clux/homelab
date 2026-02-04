# Kubernetes Homelab Automation and Helm Charts

[![Release Charts](https://github.com/clux/homelab/actions/workflows/release.yml/badge.svg)](https://github.com/clux/homelab/actions/workflows/release.yml)
[![Releases downloads](https://img.shields.io/github/downloads/clux/homelab/total.svg)](https://github.com/clux/homelab/releases)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

Minimal helm chart wrappers for minimal home lab setups. Matches my k3s setup.

## Chart Usage

Add the [helm](https://helm.sh) repo:

```console
helm repo add clux https://clux.github.io/homelab
```

then `helm search repo clux` to see the charts.

## Charts

- [promstack](https://github.com/clux/homelab/tree/main/charts/promstack) :: A low-footprint prometheus/observability chart
- [cx-dashboards](https://github.com/clux/homelab/tree/main/charts/cx-dashboards) :: A set of modern dashboards for small clusters with prometheus backlinks
- [flux](https://github.com/clux/homelab/tree/main/charts/flux) :: Minimal [flux](https://fluxcd.io/flux/components/) for gitops from this repo
- [renovate](https://github.com/clux/homelab/tree/main/charts/renovate) :: Minimal [renovate](https://docs.renovatebot.com/examples/self-hosting/) running [clux/renovate](https://github.com/clux/renovate)
- [forgejo](https://github.com/clux/homelab/tree/main/charts/forgejo) :: Basic [forgejo](https://forgejo.org/) setup (no runners)
- [cilium](https://github.com/clux/homelab/tree/main/charts/cilium) :: Basic [cilium](https://docs.cilium.io/en/stable/) for k3s with `hubble` replacing `kube-proxy`
- [coredns](https://github.com/clux/homelab/tree/main/charts/coredns) :: Basic [coredns](https://coredns.io/manual/toc/) with minor diverging elements from `k3s`

## Cluster Setup
If following these charts, they are made for `k3s` [server](https://docs.k3s.io/cli/server) with the following minimal configuration in `/etc/rancher/k3s/config.yaml`:

```yaml
disable:
- traefik
- servicelb
- coredns
- helm-controller
disable-network-policy: true
# api server pin to the main host
node-ip: 192.168.1.40
https-listen-port: 6443
# defaults
cluster-cidr: 10.42.0.0/24
service-cidr: 10.43.0.0/16
# cilium takeover
disable-kube-proxy: true
flannel-backend: none
```

## Cluster Bootstrap
Given a fresh `k3s` cluster, apply the crds and network stack, inject the config above, and restart `k3s.service`

```sh
just crds # apply crds folder
just network # install coredns and cilium
```

Then flux based applications can be `kubectl apply`'d from the [bootstrap](./bootstrap) directory.
