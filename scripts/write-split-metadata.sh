#!/usr/bin/env bash
# Generate the common metadata required by every Jankurai split-family repo.
set -euo pipefail

root="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
source_commit="${SOURCE_COMMIT:-cea83b0cbe204be276a2f0299cd760f6812ea2b0}"
split_release="${SPLIT_RELEASE:-1.7.0}"
standard_version="${STANDARD_VERSION:-0.9.0}"
auditor_version="${AUDITOR_VERSION:-1.7.0}"
schema_version="${SCHEMA_VERSION:-1.9.0}"

repos=(
  jankurai
  jankurai-core
  jankurai-contracts
  jankurai-standard
  jankurai-conformance
  jankurai-paper
  jankurai-tools-tui
  jankurai-tools-ux
  jankurai-tools-kernel
  jankurai-tools-guard
  jankurai-tools-proof
  jankurai-tools-dedup
  jankurai-tools-analyzers
  jankurai-tools-fleet
  jankurai-deploy
)

role_for() {
  case "$1" in
    jankurai) echo "Public hub, installer, GitHub Action, family manifest, lock, and local fusion." ;;
    jankurai-core) echo "Rust package and binary source for the jankurai auditor and merge control plane." ;;
    jankurai-contracts) echo "Schemas, artifact contracts, compatibility fixtures, and generated type source." ;;
    jankurai-standard) echo "Standard, mission, public conformance policy, and agent-native guidance text." ;;
    jankurai-conformance) echo "Conformance fixtures, expected reports, and acceptance corpus data." ;;
    jankurai-paper) echo "TeX paper, paper data, generated table inputs, and paper build lane." ;;
    jankurai-tools-tui) echo "Tuiwright libraries, CLI, examples, and terminal UI testing docs." ;;
    jankurai-tools-ux) echo "UX QA package, Playwright and axe wrapper, schemas, and policy fixtures." ;;
    jankurai-tools-guard) echo "Guard/save-gate runtime, filesystem watcher/FUSE/PTTY state, and standalone guard crate." ;;
    jankurai-tools-proof) echo "Proofbind, proofmark, proof receipt helpers, and proof schemas." ;;
    jankurai-tools-dedup) echo "Copy-code scanner, cross-checks, variety detector source snapshots, and fingerprint contracts." ;;
    jankurai-tools-analyzers) echo "Language, web-security, repo-rot, coverage, migration, and repair detector source snapshots." ;;
    jankurai-tools-fleet) echo "Fleet dashboard, diff-audit, score history, trend, and repair-task bank source snapshots." ;;
    jankurai-deploy) echo "Release builds, signing, installer publishing, mirroring, and split generator tooling." ;;
    *) echo "Jankurai split-family repository." ;;
  esac
}

required_command_for() {
  case "$1" in
    jankurai) echo "bash scripts/validate-family.sh" ;;
    jankurai-core) echo "cargo metadata --no-deps --format-version 1" ;;
    jankurai-contracts) echo "find schemas -name '*.json' -maxdepth 1 -print | sort | xargs -r -n1 jq empty" ;;
    jankurai-standard) echo "test -f docs/agent-native-standard.md && test -f docs/mission.md" ;;
    jankurai-conformance) echo "test -d conformance/fixtures && test -d conformance/expected" ;;
    jankurai-paper) echo "latexmk -pdf -interaction=nonstopmode -halt-on-error -outdir=paper paper/jankurai.tex" ;;
    jankurai-tools-ux) echo "npm ci && npm run build && npm test" ;;
    jankurai-tools-dedup|jankurai-tools-analyzers|jankurai-tools-fleet) echo "test -d src-snapshot && find src-snapshot -type f | sort | head -n 1 >/dev/null" ;;
    jankurai-deploy) echo "bash -n scripts/*.sh ops/ci/*.sh" ;;
    *) echo "cargo test --workspace --locked" ;;
  esac
}

write_common_files() {
  local repo="$1"
  local dir="${root}/${repo}"
  local role
  local required
  role="$(role_for "$repo")"
  required="$(required_command_for "$repo")"

  mkdir -p "${dir}/.jeryu" "${dir}/agent" "${dir}/ops/ci" "${dir}/scripts"

  cat > "${dir}/AGENTS.md" <<EOF_AGENT
# ${repo} Agent Instructions

Read \`SPLIT.md\` first. This repository is one member of the Jankurai split family.

- Historical Jeryu repo: \`root/${repo}\`.
- Primary GitHub repository: \`github.com/neverhuman/${repo}\`.
- Do not add committed cross-repo \`path = "../..."\` dependencies. Use the hub fusion workspace for local path patches.
- Do not hand-edit generated artifacts listed in \`agent/generated-zones.toml\`.
- Run \`bash scripts/ci-local.sh required\` before handing off changes.
EOF_AGENT

  cat > "${dir}/SPLIT.md" <<EOF_SPLIT
# ${repo}

Status: initial split-family extraction
Owner: Jankurai maintainers
Last reviewed: 2026-06-12
Applies to: ${repo}

## Role

${role}

## Repositories

- Historical Jeryu repo: \`root/${repo}\`
- Primary GitHub repository: \`neverhuman/${repo}\`
- Release tag pattern: \`${repo}-v${split_release}\`
- Source extraction commit: \`${source_commit}\`

## Split Rules

- GitHub is authoritative; Jeryu refs remain historical inputs.
- Release builds depend on immutable GitHub tags, not branches.
- Local development uses the hub \`scripts/fuse.sh\` output under \`.fusion/\`.
- Committed manifests must not depend on sibling checkout paths.
- Generated outputs are regenerated from their source contracts or build commands.

## Required Local Check

\`\`\`bash
bash scripts/ci-local.sh required
\`\`\`
EOF_SPLIT

  cat > "${dir}/.jeryu/repo.toml" <<EOF_JERYU
repo = "root/${repo}"
default_branch = "main"

[shadow_main]
enabled = true
remote_url = "git@github.com:neverhuman/${repo}.git"
refs = ["refs/heads/main"]

[tag_mirror]
enabled = true
remote_url = "git@github.com:neverhuman/${repo}.git"
tag_pattern = "${repo}-v*"
EOF_JERYU

  cat > "${dir}/agent/split-member.toml" <<EOF_MEMBER
schema_version = "1.0.0"
family = "jankurai"
repo = "${repo}"
role = "$(printf '%s' "$role" | sed 's/"/\\"/g')"
source_repo = "root/jankurai"
source_commit = "${source_commit}"
public_owner = "neverhuman"
local_owner = "root"
release_tag_pattern = "${repo}-v${split_release}"
EOF_MEMBER

  cat > "${dir}/agent/standard-version.toml" <<EOF_VERSION
standard = "jankurai"
standard_version = "${standard_version}"
auditor_version = "${auditor_version}"
schema_version = "${schema_version}"
target_stack = "rust-ts-vite-react-postgres-bounded-python"
split_family = "jankurai"
split_member = "${repo}"
split_release = "${split_release}"
source_commit = "${source_commit}"
EOF_VERSION

  cat > "${dir}/agent/owner-map.json" <<EOF_OWNER
{
  "workspace": "${repo}",
  "owners": {
    "AGENTS.md": "agent",
    "SPLIT.md": "workspace",
    "README.md": "workspace",
    "LICENSE": "workspace",
    "CHANGELOG.md": "workspace",
    ".gitignore": "workspace",
    ".jeryu/": "ops",
    ".github/": "ops",
    "action.yml": "ops",
    "jankurai-installer.sh": "ops",
    "agent/": "agent",
    "ops/": "ops",
    "scripts/": "ops",
    "Cargo.toml": "tools",
    "Cargo.lock": "tools",
    "package.json": "tools",
    "package-lock.json": "tools",
    "crates/": "tools",
    "packages/": "tools",
    "tools/": "tools",
    "src-snapshot/": "tools",
    "schemas/": "standard",
    "contracts/": "standard",
    "conformance/": "standard",
    "db/": "standard",
    "docs/": "standard",
    "paper/": "paper",
    "assets/": "paper",
    "tips/": "paper",
    "repos.manifest.toml": "workspace",
    "family.lock": "workspace"
  }
}
EOF_OWNER

  cat > "${dir}/agent/test-map.json" <<EOF_TEST
{
  "workspace": "${repo}",
  "tests": {
    "AGENTS.md": {
      "command": "bash scripts/ci-local.sh required",
      "purpose": "verify split-family agent routing remains present"
    },
    "SPLIT.md": {
      "command": "bash scripts/ci-local.sh required",
      "purpose": "verify split metadata stays coherent"
    },
    ".jeryu/": {
      "command": "bash scripts/ci-local.sh required",
      "purpose": "verify local Jeryu and GitHub mirror metadata"
    },
    "agent/": {
      "command": "bash scripts/ci-local.sh required",
      "purpose": "verify split control maps and standard metadata"
    },
    "ops/": {
      "command": "bash scripts/ci-local.sh required",
      "purpose": "verify pinned CI script entrypoints"
    },
    "scripts/": {
      "command": "bash scripts/ci-local.sh required",
      "purpose": "verify local CI and fusion helpers"
    },
    ".": {
      "command": "bash scripts/ci-local.sh required",
      "purpose": "required local proof for ${repo}"
    }
  }
}
EOF_TEST

  cat > "${dir}/agent/generated-zones.toml" <<EOF_ZONES
[[zone]]
path = "target/"
source = "Rust and CI commands"
command = "bash scripts/ci-local.sh required"
read_only = true
write_policy = "generated_output"

[[zone]]
path = "dist/"
source = "release build commands"
command = "bash ops/ci/required.sh"
read_only = true
write_policy = "generated_output"

[[zone]]
path = ".fusion/"
source = "jankurai hub scripts/fuse.sh"
command = "./scripts/fuse.sh --source local --all"
read_only = true
write_policy = "generated_output"

[[zone]]
path = "package-lock.json"
source = "package.json and packages/*/package.json"
command = "npm install --package-lock-only"
read_only = true
write_policy = "lockfile"
EOF_ZONES

  cat > "${dir}/.gitignore" <<EOF_IGNORE
.DS_Store
._*
target/
dist/
build/
node_modules/
test-results/
.fusion/
.jankurai/
EOF_IGNORE

  cat > "${dir}/ops/ci/required.sh" <<EOF_REQUIRED
#!/usr/bin/env bash
set -euo pipefail
cd "\$(dirname "\${BASH_SOURCE[0]}")/../.."

${required}
EOF_REQUIRED
  chmod +x "${dir}/ops/ci/required.sh"

  cat > "${dir}/scripts/ci-local.sh" <<'EOF_CI'
#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

lane="${1:-required}"
case "$lane" in
  required) bash ops/ci/required.sh ;;
  *) echo "usage: $0 {required}" >&2; exit 2 ;;
esac
EOF_CI
  chmod +x "${dir}/scripts/ci-local.sh"
}

for repo in "${repos[@]}"; do
  write_common_files "$repo"
done

echo "split metadata written under ${root}"
