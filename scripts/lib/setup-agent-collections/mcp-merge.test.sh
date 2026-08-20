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

# Asserts the "eversis-collections" entry in $1 is a Docker Compose stdio
# invocation: command "docker", args exactly
# [compose, -f, $2, run, --rm, -T, eversis-collections], and no "env" key
# (the compose file hardcodes AGENT_COLLECTIONS_HOME=/repo — no host env
# passthrough is needed any more).
_assert_docker_entry() {
  local file="$1" expected_fpath="$2" label="$3"
  if node -e '
      const fs = require("fs");
      const [file, expectedFpath] = process.argv.slice(1);
      const j = JSON.parse(fs.readFileSync(file, "utf8"));
      const e = j.mcpServers["eversis-collections"];
      if (!e) process.exit(1);
      if (e.command !== "docker") process.exit(1);
      const expectedArgs = ["compose", "-f", expectedFpath, "run", "--rm", "-T", "eversis-collections"];
      if (JSON.stringify(e.args) !== JSON.stringify(expectedArgs)) process.exit(1);
      if (e.type !== "stdio") process.exit(1);
      if ("env" in e) process.exit(1);
    ' "$file" "$expected_fpath"; then
    _pass "$label"
  else
    _fail "$label"
  fi
}

# Minimal env for sourcing mcp-merge.sh — COLLECTIONS_HOME points at this
# repo so templates/mcp.json and mcp-server-list.json resolve without a
# built MCP server (the Docker image is never checked by the merge).
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
# callers that never set SELECTED_AGENTS). Cursor + absolute mode.
unset SELECTED_AGENTS MCP_SELECTED_IDS VENDOR_MODE 2>/dev/null || true
merge_mcp_json
if [[ -f "${TARGET_DIR}/.cursor/mcp.json" ]] && [[ ! -f "${TARGET_DIR}/.mcp.json" ]]; then
  _pass "default (no SELECTED_AGENTS) writes only .cursor/mcp.json"
else
  _fail "default (no SELECTED_AGENTS) writes only .cursor/mcp.json"
fi
_assert_docker_entry "${TARGET_DIR}/.cursor/mcp.json" '${env:AGENT_COLLECTIONS_HOME}/docker-compose.yml' \
  "cursor (absolute) eversis-collections entry is docker compose -f \${env:AGENT_COLLECTIONS_HOME}/docker-compose.yml"

# Case 2: claude only, absolute (non-relative) mode — Claude-native syntax,
# no env block (the ${AGENT_COLLECTIONS_HOME:-<resolved>} default covers
# GUI-launched hosts that don't inherit shell env).
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
_assert_docker_entry "${TARGET_DIR}/.mcp.json" "\${AGENT_COLLECTIONS_HOME:-${REPO_ROOT}}/docker-compose.yml" \
  "claude (absolute) eversis-collections entry is docker compose -f \${AGENT_COLLECTIONS_HOME:-<resolved>}/docker-compose.yml, no env block"
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
_assert_docker_entry "${TARGET_DIR}/.mcp.json" '${CLAUDE_PROJECT_DIR:-.}/vendor/agent-collections/docker-compose.yml' \
  "claude+copy vendor mode eversis-collections entry is docker compose -f \${CLAUDE_PROJECT_DIR:-.}/vendor/agent-collections/docker-compose.yml, no env block"

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
_assert_docker_entry "${TARGET_DIR}/.cursor/mcp.json" '${env:AGENT_COLLECTIONS_HOME}/docker-compose.yml' \
  "cursor mcp.json keeps \${env:...} syntax unchanged (no regression)"
_assert_docker_entry "${TARGET_DIR}/.mcp.json" "\${AGENT_COLLECTIONS_HOME:-${REPO_ROOT}}/docker-compose.yml" \
  "claude mcp.json (paired with cursor) still resolves the absolute-mode docker entry correctly"

echo ""
echo "  ✅  All ${PASS} mcp-merge unit tests passed."
