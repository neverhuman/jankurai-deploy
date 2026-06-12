# jankurai-deploy Testing

Testing in this repo is routed proof. Agents should not guess which lane
matters; they route through [`agent/test-map.json`](../agent/test-map.json) to
the smallest lane that proves the change.

| Lane | Purpose |
| --- | --- |
| `fast` | deterministic local proof for most edits (`bash scripts/ci-local.sh required` + a no-write `jankurai audit`) |
| `security` | secret scanning (gitleaks) and dependency scanning (cargo audit) |
| `release` | the artifact-backed release audit gate run before tagging |
| `audit` | jankurai repo score and hard-rule findings |
| `full` | the full release/merge gate |

The local runner `scripts/ci-local.sh` and the CI workflows under `.github/`
call the exact same `ops/ci/*.sh` entrypoints, so a green local run predicts a
green CI run. See [`docs/ci-local.md`](ci-local.md) for the per-lane contract.

## Typed exception and error surface

Release and mirror automation in this repo fails loudly with a typed, agent
friendly error surface instead of opaque exit codes. Every `ops/ci/*.sh`
entrypoint sources `ops/ci/lib.sh`, whose `fail` helper emits a structured error
that names:

- `purpose` — what the lane was trying to prove.
- `reason` — why it stopped.
- common fixes — the concrete next commands an agent should run.
- `docs_url` — the doc that explains the lane (this file or `docs/ci-local.md`).
- `repair_hint` — the exact rerun command so the next attempt is local.

The shadow lane in `ops/ci/post-main-shadow.sh` writes a typed JSON repair
receipt (`target/jankurai/jeryu-shadow.json`) plus a Markdown summary that
records the status, reason, branch, commit, origin, shadow config, and shadow
command. This is the agent-friendly exception pattern: an override or failure is
data, not prose, and points at the next rerun.

## Repair receipts and telemetry

When a lane fails, keep the next agent on the shortest possible rerun path.

- Emit structured errors and typed JSON receipts under `target/jankurai/`
  instead of free-form log spam.
- Record the failing command, exit code, changed paths, artifact paths, and the
  rerun command in the receipt.
- Surface the repair hint, docs URL, and common fixes together so the next
  rerun is obvious.
- If a lane writes a receipt or summary, point it at the exact proof command the
  next agent should trust.

## Budgets, quotas, and stop conditions

Paid or unbounded work in this repo (release builds, signing, publishing,
mirroring) needs an explicit ceiling before it starts.

- **Budget**: every CI job sets a `timeout-minutes` cap in its workflow, and the
  release lanes run only on immutable tags, never in a retry loop.
- **Quota**: signing and publishing run once per tag; the tag-mirror config in
  `.jeryu/repo.toml` bounds mirroring to `jankurai-deploy-v*` tags only.
- **Stop condition / kill switch**: `set -euo pipefail` plus `lib.sh#fail` halt
  the run on the first failing step; the shadow lane refuses to run on a dirty
  worktree or a non-`main` branch and writes a `skipped`/`failed` receipt.
- **Evidence**: the stop is captured in the receipt so the next agent can tell a
  planned stop from a silent failure. Do not retry a paid publish after the cap
  is reached without a fresh approval receipt.

## What is proven where

- `just fast` / `bash scripts/ci-local.sh required` syntax-checks every shell
  entrypoint and runs the required local proof, then writes a no-write audit
  snapshot under `target/jankurai/`.
- `just security` runs gitleaks and cargo audit.
- `just audit` writes `.jankurai/repo-score.json` and `.jankurai/repo-score.md`.
- `just release` runs `ops/ci/release-audit-gate.sh`, the artifact-backed launch
  gate, before any tag is cut. See [`docs/release.md`](release.md).
