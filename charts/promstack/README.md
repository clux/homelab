# promstack

A personal minimal `kube-prometheus-stack` + `tempo` chart wrapper with tracing support for homelab setups.

Blog post on [clux.dev :: Prometheus Minified](https://clux.dev/post/2024-09-07-prometheus-minified/).

## Usage

Direct from helm;

```sh
helm repo add clux https://clux.github.io/homelab
helm install [RELEASE_NAME] clux/promstack
```

or take/dissect the [values file](https://github.com/clux/homelab/blob/main/charts/promstack/values.yaml) and take what you want.

There's probably not much value for you to depend on me for good defaults.
