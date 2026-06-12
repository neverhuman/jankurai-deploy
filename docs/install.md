# Deploy Install Notes

Status: split deploy install note
Owner: Jankurai maintainers
Last reviewed: 2026-06-12
Applies to: `jankurai-deploy`

The deploy repo does not install from local core source. It publishes and
verifies release artifacts produced from the hub `family.lock`.

Use the hub installer for users:

```bash
curl -fsSL https://github.com/neverhuman/jankurai/releases/download/v1.7.0-split.0/jankurai-installer.sh \
  | JANKURAI_RELEASE_TAG=v1.7.0-split.0 bash
```

Use the hub fusion workspace for source builds:

```bash
cd ../jankurai
./scripts/fuse.sh --source local --all
.fusion/dev.sh build
```
