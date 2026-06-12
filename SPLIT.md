# jankurai-deploy

Status: initial split-family extraction
Owner: Jankurai maintainers
Last reviewed: 2026-06-12
Applies to: jankurai-deploy

## Role

Release builds, signing, installer publishing, mirroring, and split generator tooling.

## Repositories

- Local authoritative repo: `root/jankurai-deploy`
- Public mirror: `neverhuman/jankurai-deploy`
- Release tag pattern: `jankurai-deploy-v1.7.0-split.0`
- Source extraction commit: `cea83b0cbe204be276a2f0299cd760f6812ea2b0`

## Split Rules

- Jeryu remains authoritative; GitHub is the public mirror.
- Release builds depend on immutable GitHub tags, not branches.
- Local development uses the hub `scripts/fuse.sh` output under `.fusion/`.
- Committed manifests must not depend on sibling checkout paths.
- Generated outputs are regenerated from their source contracts or build commands.

## Required Local Check

```bash
bash scripts/ci-local.sh required
```
