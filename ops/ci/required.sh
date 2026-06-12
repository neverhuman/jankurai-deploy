#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/../.."

bash -n scripts/*.sh ops/ci/*.sh
