#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/../.."
for script in scripts/*.sh ops/ci/*.sh; do bash -n "$script"; done
