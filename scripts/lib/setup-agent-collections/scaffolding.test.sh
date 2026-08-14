#!/usr/bin/env bash
# scaffolding.test.sh — unit tests for scaffold_project()'s docs-triad README scaffolding.
#
# Usage (from repo root):
#   bash scripts/lib/setup-agent-collections/scaffolding.test.sh

set -euo pipefail

LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${LIB_DIR}/../../.." && pwd)"

PASS=0
FAIL=0

_pass() { echo "  ✓ $1"; PASS=$(( PASS + 1 )); }
_fail() { echo "  ✗ $1"; FAIL=$(( FAIL + 1 )); exit 1; }

# Minimal env for sourcing scaffolding.sh
TARGET_DIR="$(mktemp -d)"
trap 'rm -rf "$TARGET_DIR"' EXIT

COLLECTIONS_HOME="$REPO_ROOT"
SELECTED_AGENTS=""

# shellcheck source=common.sh
source "${LIB_DIR}/common.sh"
# shellcheck source=scaffolding.sh
source "${LIB_DIR}/scaffolding.sh"

_reset_target() {
  rm -rf "${TARGET_DIR:?}"/*
}

echo "scaffolding.sh unit tests"
echo ""

# Case 1: fresh scaffold creates all 3 triad READMEs
_reset_target
scaffold_project
if [[ -s "${TARGET_DIR}/docs/context/README.md" ]] && \
   [[ -s "${TARGET_DIR}/docs/plans/README.md" ]] && \
   [[ -s "${TARGET_DIR}/docs/specs/README.md" ]]; then
  _pass "fresh scaffold creates docs/context, docs/plans, docs/specs README.md"
else
  _fail "fresh scaffold creates docs/context, docs/plans, docs/specs README.md"
fi

# Case 2: backfill — pre-existing dirs without README get the README on re-run
_reset_target
mkdir -p "${TARGET_DIR}/docs/context" "${TARGET_DIR}/docs/plans"
scaffold_project
if [[ -f "${TARGET_DIR}/docs/context/README.md" ]] && \
   [[ -f "${TARGET_DIR}/docs/plans/README.md" ]]; then
  _pass "backfill creates missing README into pre-existing empty triad dirs"
else
  _fail "backfill creates missing README into pre-existing empty triad dirs"
fi

# Case 3: never overwrite — a custom README is preserved across re-runs
_reset_target
mkdir -p "${TARGET_DIR}/docs/context"
echo "# custom" > "${TARGET_DIR}/docs/context/README.md"
scaffold_project
if [[ "$(cat "${TARGET_DIR}/docs/context/README.md")" == "# custom" ]]; then
  _pass "never overwrite a pre-existing custom docs/context/README.md"
else
  _fail "never overwrite a pre-existing custom docs/context/README.md"
fi

# Case 4: idempotent — calling scaffold_project twice does not error or change content
_reset_target
scaffold_project
CHECKSUM_1="$(cat "${TARGET_DIR}/docs/specs/README.md" "${TARGET_DIR}/docs/context/README.md" "${TARGET_DIR}/docs/plans/README.md" | shasum)"
scaffold_project
CHECKSUM_2="$(cat "${TARGET_DIR}/docs/specs/README.md" "${TARGET_DIR}/docs/context/README.md" "${TARGET_DIR}/docs/plans/README.md" | shasum)"
if [[ "$CHECKSUM_1" == "$CHECKSUM_2" ]]; then
  _pass "calling scaffold_project twice is idempotent"
else
  _fail "calling scaffold_project twice is idempotent"
fi

echo ""
echo "  ✅  All ${PASS} scaffolding unit tests passed."
