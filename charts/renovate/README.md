# renovate

A personal `renovate` setup running against select repos in `kube-rs` and `clux`'s repos.

## Secrets

- [Fine grained minimal renovate token](https://docs.renovatebot.com/modules/platform/github/#running-using-a-fine-grained-token) for [kube-rs](https://github.com/kube-rs) via @sszynrae. kube-rs org has to approve the PAT.

- [Classic PAT](https://docs.renovatebot.com/modules/platform/github/#authentication) for @clux's repos via @sszynrae (need to invite sszynrae as collaborator and opt-in repos in clux.yaml).

## Image

Built from [clux/renovate](https://github.com/clux/renovate).
