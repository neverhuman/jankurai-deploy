# jankurai-deploy Agent Instructions

Read [`SPLIT.md`](SPLIT.md) first. This repository is one member of the Jankurai
split family: the release, signing, mirroring, and split-generator member.

- Historical Jeryu repo: `root/jankurai-deploy` on the Jeryu remote
  `ssh://git@127.0.0.1:2224/root/*`. Primary GitHub repository: `neverhuman/jankurai-deploy`.
- One-command setup and validation: `just setup`, `just fast`, `just check`
  (root [`Justfile`](Justfile)).
- Route changes through [`agent/owner-map.json`](agent/owner-map.json) and
  [`agent/test-map.json`](agent/test-map.json), then the smallest proof lane in
  [`agent/proof-lanes.toml`](agent/proof-lanes.toml).
- Do not add committed cross-repo `path = "../..."` dependencies. Use the hub
  fusion workspace for local path patches.
- Do not hand-edit generated artifacts listed in
  [`agent/generated-zones.toml`](agent/generated-zones.toml).
- Durable detail lives in the docs, not here: [architecture](docs/architecture.md),
  [boundaries](docs/boundaries.md), [testing](docs/testing.md),
  [release](docs/release.md), [exceptions](docs/exceptions.md), and
  [CI-local](docs/ci-local.md).
- Run `bash scripts/ci-local.sh required` (or `just fast`) before handing off.
