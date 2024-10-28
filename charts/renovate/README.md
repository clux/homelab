# renovate

A small `renovate` setup for a daily upgrade job against a select set of repositories.

Runs image from [clux/renovate](https://github.com/clux/renovate).

## Usage

Configure for a [github org](./kube.yaml), [personal github acc](./clux.yaml), [forgejo instance](./forgejo.yaml).

## Integration

### Github

For automerges of PRs:

- add an [automerge workflow](https://github.com/clux/renovate/blob/main/.github/workflows/automerge.yml)
- repo settings: enable auto-merge
- repo settings / branches: add branch protection to `main` and require ci statuses to pass
- repo settings / actions / runners: allow gh actions to create and approve prs
- add account (whose pat you are running) to the org (in org case) or repo (in user case)
- approve PAT if necessary (org)

### Forgejo

See [forgejo.yaml](./forgejo.yaml).
