#!/usr/bin/env bash
# ssot.test.sh — unit tests for ssot.sh scaffolding + best-effort seed logic.
#
# Usage (from repo root):
#   bash scripts/lib/setup-agent-collections/ssot.test.sh

set -euo pipefail

LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PASS=0
FAIL=0
SKIP=0

_pass() { echo "  ✓ $1"; PASS=$(( PASS + 1 )); }
_fail() { echo "  ✗ $1"; FAIL=$(( FAIL + 1 )); exit 1; }
_skip() { echo "  ⚬ $1 (skipped)"; SKIP=$(( SKIP + 1 )); }

TARGET_DIR="$(mktemp -d)"
REMOTE_DIR="$(mktemp -d)"
trap 'rm -rf "$TARGET_DIR" "$REMOTE_DIR"' EXIT

# shellcheck source=common.sh
source "${LIB_DIR}/common.sh"
# shellcheck source=ssot.sh
source "${LIB_DIR}/ssot.sh"

echo "ssot.sh unit tests"
echo ""

git -C "$TARGET_DIR" init -q -b main
echo "consumer project" > "${TARGET_DIR}/README.md"
git -C "$TARGET_DIR" add README.md
git -C "$TARGET_DIR" -c user.email=test@example.com -c user.name=test commit -q -m "init"

# Case 1: scaffold_ssot_project derives a slug from the target dir basename
unset SSOT_PROJECT_SLUG || true
scaffold_ssot_project
slug="$(basename "$TARGET_DIR" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')"
if [[ -f "${TARGET_DIR}/docs/context/${slug}/INDEX.md" ]] && grep -qF "domain knowledge index" "${TARGET_DIR}/docs/context/${slug}/INDEX.md"; then
  _pass "scaffold_ssot_project creates docs/context/<slug>/INDEX.md"
else
  _fail "scaffold_ssot_project creates docs/context/<slug>/INDEX.md"
fi

# Case 2: scaffold_ssot_project is idempotent — does not overwrite existing INDEX.md
echo "hand-edited" >> "${TARGET_DIR}/docs/context/${slug}/INDEX.md"
scaffold_ssot_project
if grep -qF "hand-edited" "${TARGET_DIR}/docs/context/${slug}/INDEX.md"; then
  _pass "scaffold_ssot_project does not overwrite an existing INDEX.md"
else
  _fail "scaffold_ssot_project does not overwrite an existing INDEX.md"
fi

# Case 3: seed_ssot_global with no ARG_SSOT_SOURCE — succeeds, creates nothing
ARG_SSOT_SOURCE=""
seed_ssot_global
if [[ ! -d "${TARGET_DIR}/docs/context/global" ]]; then
  _pass "seed_ssot_global without --ssot-source does not create docs/context/global/"
else
  _fail "seed_ssot_global without --ssot-source does not create docs/context/global/"
fi

# Case 4: seed_ssot_global with an unreachable remote — warns, does not exit non-zero
ARG_SSOT_SOURCE="/nonexistent/path/does-not-exist"
if seed_ssot_global; then
  if [[ ! -d "${TARGET_DIR}/docs/context/global" ]]; then
    _pass "seed_ssot_global with unreachable remote does not block install"
  else
    _fail "seed_ssot_global with unreachable remote does not block install"
  fi
else
  _fail "seed_ssot_global with unreachable remote does not block install (non-zero exit)"
fi

# Case 5: seed_ssot_global with a reachable local remote — requires `git subtree`.
# `git subtree` (bare) exits non-zero (usage message) even when available, and
# `--help` shells out to `man` and fails on systems without man pages installed —
# neither is usable directly under `set -o pipefail`. Capture output first so the
# probe's own non-zero exit never feeds into a pipeline status.
_subtree_probe="$(git subtree 2>&1 || true)"
if echo "$_subtree_probe" | grep -q "usage: git subtree"; then
  (
    cd "$REMOTE_DIR"
    git init -q -b main
    echo "# domain-context" > INDEX.md
    git add INDEX.md
    git -c user.email=test@example.com -c user.name=test commit -q -m "seed"
  )
  ARG_SSOT_SOURCE="$REMOTE_DIR"
  ARG_SSOT_BRANCH="main"
  seed_ssot_global
  if [[ -f "${TARGET_DIR}/docs/context/global/INDEX.md" ]]; then
    _pass "seed_ssot_global with reachable remote seeds docs/context/global/"
  else
    _fail "seed_ssot_global with reachable remote seeds docs/context/global/"
  fi
else
  _skip "seed_ssot_global with reachable remote (git subtree not available in this environment)"
fi

echo ""
echo "  ✅  ${PASS} passed, ${SKIP} skipped, ${FAIL} failed."
