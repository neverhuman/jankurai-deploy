# GitHub deployment tooling

GitHub is the primary source. The hub at `neverhuman/jankurai` owns assembled
integration, release builds, signing, attestations, and publication. This repository
keeps the deployment helpers and historical extraction tools independently editable.

`bash ops/ci/github-check.sh` runs deployment script validation, secret scanning,
workflow security checks, a software bill of materials, and the default-branch
ratchet audit. Full Rust, proof, conformance, UX, and release-platform checks run
against the hub's locked family. The obsolete monolithic workflow definitions
are preserved in `docs/legacy-workflows/` for history; their missing product paths
and self-hosted runners are not public build dependencies.
