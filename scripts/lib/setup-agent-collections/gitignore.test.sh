#!/usr/bin/env bash
# gitignore.test.sh — unit tests for gitignore.sh marker merge logic.
#
# Usage (from repo root):
#   bash scripts/lib/setup-cursor-local/gitignore.test.sh

set -euo pipefail

LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${LIB_DIR}/../../.." && pwd)"

PASS=0
FAIL=0

_pass() { echo "  ✓ $1"; PASS=$(( PASS + 1 )); }
_fail() { echo "  ✗ $1"; FAIL=$(( FAIL + 1 )); exit 1; }

# Minimal env for sourcing gitignore.sh
TARGET_DIR="$(mktemp -d)"
trap 'rm -rf "$TARGET_DIR"' EXIT

export ARG_GITIGNORE_AGENT_ARTIFACTS="false"
VENDOR_MODE=""

# shellcheck source=common.sh
source "${LIB_DIR}/common.sh"
# shellcheck source=gitignore.sh
source "${LIB_DIR}/gitignore.sh"

write_base_local_block() {
  cat > "${TARGET_DIR}/.gitignore" <<'EOF'
node_modules/

# cursor-collections local [begin]
.cursor/mcp.json
.cursor/prompts/
# cursor-collections local [end]
EOF
}

echo "gitignore.sh unit tests"
echo ""

# Case 1: add artifacts sub-block
write_base_local_block
ARG_GITIGNORE_AGENT_ARTIFACTS="true"
_ensure_artifacts_subblock "${TARGET_DIR}/.gitignore"
if grep -qF "docs/specs/*/" "${TARGET_DIR}/.gitignore" && \
   grep -qF "cursor-collections agent-artifacts [begin]" "${TARGET_DIR}/.gitignore"; then
  _pass "add artifacts sub-block"
else
  _fail "add artifacts sub-block"
fi

# Case 2: remove artifacts sub-block
_remove_artifacts_subblock "${TARGET_DIR}/.gitignore"
if grep -qF "cursor-collections local [begin]" "${TARGET_DIR}/.gitignore" && \
   ! grep -qF "docs/specs/*/" "${TARGET_DIR}/.gitignore"; then
  _pass "remove artifacts sub-block keeps local block"
else
  _fail "remove artifacts sub-block keeps local block"
fi

# Case 3: vendor removes entire local block
write_base_local_block
ARG_GITIGNORE_AGENT_ARTIFACTS="true"
_ensure_artifacts_subblock "${TARGET_DIR}/.gitignore"
VENDOR_MODE="copy"
manage_gitignore
if ! grep -qF "cursor-collections local [begin]" "${TARGET_DIR}/.gitignore"; then
  _pass "vendor mode removes local block including artifacts"
else
  _fail "vendor mode removes local block including artifacts"
fi

# Case 4: refresh migrates legacy per-file rules to glob; keeps artifacts
cat > "${TARGET_DIR}/.gitignore" <<'EOF'
node_modules/

# cursor-collections local [begin]
.cursor/mcp.json
.cursor/prompts/
.cursor/rules/eversis-agent-core.mdc
.cursor/rules/eversis-code-reviewer.mdc
# cursor-collections agent-artifacts [begin]
docs/specs/*/
docs/context/*/
# cursor-collections agent-artifacts [end]
# cursor-collections local [end]
EOF
VENDOR_MODE=""
ARG_GITIGNORE_AGENT_ARTIFACTS="true"
_refresh_local_gitignore_block "${TARGET_DIR}/.gitignore" "true"
if grep -qF ".cursor/rules/eversis-*.mdc" "${TARGET_DIR}/.gitignore" && \
   grep -qF "!.cursor/rules/eversis-project-stack.mdc" "${TARGET_DIR}/.gitignore" && \
   ! grep -qF "eversis-agent-core.mdc" "${TARGET_DIR}/.gitignore" && \
   grep -qF "cursor-collections agent-artifacts [begin]" "${TARGET_DIR}/.gitignore"; then
  _pass "refresh migrates legacy rules to glob and keeps artifacts"
else
  _fail "refresh migrates legacy rules to glob and keeps artifacts"
fi

echo ""
echo "  ✅  All ${PASS} gitignore unit tests passed."
