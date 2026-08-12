#!/usr/bin/env bash
# mcp-merge.test.sh — unit tests for mcp-merge.sh host branching (Cursor vs
# Claude Code) and the Claude-native syntax transform in mcp-merge.mjs.
#
# Usage (from repo root):
#   bash scripts/lib/setup-agent-collections/mcp-merge.test.sh

set -euo pipefail

LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${LIB_DIR}/../../.." && pwd)"

PASS=0
FAIL=0

_pass() { echo "  ✓ $1"; PASS=$(( PASS + 1 )); }
_fail() { echo "  ✗ $1"; FAIL=$(( FAIL + 1 )); exit 1; }

# Minimal env for sourcing mcp-merge.sh — COLLECTIONS_HOME points at this
# repo so templates/mcp.json and mcp-server-list.json resolve without a
# built MCP server (dist/index.js existence is never checked by the merge).
COLLECTIONS_HOME="$REPO_ROOT"
TARGET_DIR="$(mktemp -d)"
trap 'rm -rf "$TARGET_DIR"' EXIT

# shellcheck source=common.sh
source "${LIB_DIR}/common.sh"
# shellcheck source=mcp-merge.sh
source "${LIB_DIR}/mcp-merge.sh"

echo "mcp-merge.sh unit tests"
echo ""

# Case 1: SELECTED_AGENTS unset — defaults to cursor-only (no regression for
# callers that never set SELECTED_AGENTS).
unset SELECTED_AGENTS MCP_SELECTED_IDS VENDOR_MODE 2>/dev/null || true
merge_mcp_json
if [[ -f "${TARGET_DIR}/.cursor/mcp.json" ]] && [[ ! -f "${TARGET_DIR}/.mcp.json" ]]; then
  _pass "default (no SELECTED_AGENTS) writes only .cursor/mcp.json"
else
  _fail "default (no SELECTED_AGENTS) writes only .cursor/mcp.json"
fi

# Case 2: claude only, local vendor mode — Claude-native syntax, explicit env.
rm -rf "${TARGET_DIR}/.cursor" "${TARGET_DIR}/.mcp.json"
SELECTED_AGENTS="claude"
VENDOR_MODE=""
merge_mcp_json
if [[ -f "${TARGET_DIR}/.mcp.json" ]] && [[ ! -f "${TARGET_DIR}/.cursor/mcp.json" ]]; then
  _pass "claude-only writes only .mcp.json"
else
  _fail "claude-only writes only .mcp.json"
fi
if ! grep -qF '${env:' "${TARGET_DIR}/.mcp.json" && ! grep -qF 'workspaceFolder' "${TARGET_DIR}/.mcp.json"; then
  _pass "claude .mcp.json has no \${env:...} or \${workspaceFolder} syntax"
else
  _fail "claude .mcp.json has no \${env:...} or \${workspaceFolder} syntax"
fi
if grep -qF '"AGENT_COLLECTIONS_HOME"' "${TARGET_DIR}/.mcp.json"; then
  _pass "claude .mcp.json sets explicit env.AGENT_COLLECTIONS_HOME"
else
  _fail "claude .mcp.json sets explicit env.AGENT_COLLECTIONS_HOME"
fi
if ! grep -qF '"inputs"' "${TARGET_DIR}/.mcp.json"; then
  _pass "claude .mcp.json omits the inputs key"
else
  _fail "claude .mcp.json omits the inputs key"
fi
if node -e "JSON.parse(require('fs').readFileSync('${TARGET_DIR}/.mcp.json','utf8'))" 2>/dev/null; then
  _pass "claude .mcp.json is valid JSON"
else
  _fail "claude .mcp.json is valid JSON"
fi

# Case 3: claude + vendored (copy) — CLAUDE_PROJECT_DIR-relative path.
rm -f "${TARGET_DIR}/.mcp.json"
VENDOR_MODE="copy"
merge_mcp_json
if grep -qF '${CLAUDE_PROJECT_DIR:-.}/vendor/agent-collections' "${TARGET_DIR}/.mcp.json"; then
  _pass "claude+copy vendor mode uses CLAUDE_PROJECT_DIR-relative path"
else
  _fail "claude+copy vendor mode uses CLAUDE_PROJECT_DIR-relative path"
fi

# Case 4: both agents selected together — independent, non-interfering outputs.
rm -rf "${TARGET_DIR}/.cursor" "${TARGET_DIR}/.mcp.json"
SELECTED_AGENTS="cursor,claude"
VENDOR_MODE=""
merge_mcp_json
if [[ -f "${TARGET_DIR}/.cursor/mcp.json" ]] && [[ -f "${TARGET_DIR}/.mcp.json" ]]; then
  _pass "cursor,claude writes both .cursor/mcp.json and .mcp.json"
else
  _fail "cursor,claude writes both .cursor/mcp.json and .mcp.json"
fi
if grep -qF '${env:AGENT_COLLECTIONS_HOME}' "${TARGET_DIR}/.cursor/mcp.json"; then
  _pass "cursor mcp.json keeps \${env:...} syntax unchanged (no regression)"
else
  _fail "cursor mcp.json keeps \${env:...} syntax unchanged (no regression)"
fi

echo ""
echo "  ✅  All ${PASS} mcp-merge unit tests passed."
