# cx dashboards

Raw grafana "Copy JSON to clipboard" snapshots that is used to generate `ConfigMap`s via `just gen-dashboards`.

The generation setup is defined in [mkdashboard.sh](../mkdashboard.sh) and is run for every file in this directory.

> [!WARNING]
> We export these from a live grafana tied to the promstack version of grafana.

## Dashboard Chart

These files also generate the [cx-dashboard chart](https://github.com/clux/homelab/tree/main/charts/cx-dashboards) separately.

See the last recipe in the [justfile](https://github.com/clux/homelab/blob/main/justfile).

Curretly we support templating in:

- enabled gates (big helm if enabled header / end footer)
- do not edit generated header
- alertmanager and prometheus urls
