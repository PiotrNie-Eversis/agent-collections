#!/usr/bin/env bash
# mcp-merge.test.sh — unit tests for mcp-merge.sh host branching (Cursor vs
# Claude Code) and the Claude-native syntax transform in mcp-merge.mjs.
#
# Usage (from repo root):
#   bash scripts/lib/setup-agent-collections/mcp-merge.test.sh

set -euo pipefail

LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${LIB_DIR}/../../.." && pwd)"
WRAPPER_TEMPLATE="${REPO_ROOT}/templates/run-eversis-collections-mcp.sh"

PASS=0
FAIL=0

_pass() { echo "  ✓ $1"; PASS=$(( PASS + 1 )); }
_fail() { echo "  ✗ $1"; FAIL=$(( FAIL + 1 )); exit 1; }

# Asserts the "eversis-collections" entry in $1 is a Docker Compose stdio
# invocation: command "docker", args exactly
# [compose, -f, $2, run, --rm, -T, eversis-collections], and
# env.CONSUMER_PROJECT_ROOT === $3 (host token for the /workspace bind).
_assert_docker_entry() {
  local file="$1" expected_fpath="$2" expected_root="$3" label="$4"
  if node -e '
      const fs = require("fs");
      const [file, expectedFpath, expectedRoot] = process.argv.slice(1);
      const j = JSON.parse(fs.readFileSync(file, "utf8"));
      const e = j.mcpServers["eversis-collections"];
      if (!e) process.exit(1);
      if (e.command !== "docker") process.exit(1);
      const expectedArgs = ["compose", "-f", expectedFpath, "run", "--rm", "-T", "eversis-collections"];
      if (JSON.stringify(e.args) !== JSON.stringify(expectedArgs)) process.exit(1);
      if (e.type !== "stdio") process.exit(1);
      if (!e.env || e.env.CONSUMER_PROJECT_ROOT !== expectedRoot) process.exit(1);
    ' "$file" "$expected_fpath" "$expected_root"; then
    _pass "$label"
  else
    _fail "$label"
  fi
}

# Asserts the vendored Claude bash -c wrapper entry (no env object).
_assert_claude_vendor_wrapper() {
  local file="$1" label="$2"
  if node -e '
      const fs = require("fs");
      const file = process.argv[1];
      const j = JSON.parse(fs.readFileSync(file, "utf8"));
      const e = j.mcpServers["eversis-collections"];
      if (!e) process.exit(1);
      if (e.command !== "bash") process.exit(1);
      if (!Array.isArray(e.args) || e.args[0] !== "-c") process.exit(1);
      const locator = e.args[1] || "";
      if (!locator.includes("$CLAUDE_PROJECT_DIR")) process.exit(1);
      if (locator.includes("${CLAUDE_PROJECT_DIR")) process.exit(1);
      if (!locator.includes("[ -n \"$CLAUDE_PROJECT_DIR\" ]")) process.exit(1);
      if (e.type !== "stdio") process.exit(1);
      if (e.env !== undefined) process.exit(1);
    ' "$file"; then
    _pass "$label"
  else
    _fail "$label"
  fi
}

_assert_wrapper_script_copied() {
  local target="$1" label="$2"
  local copied="${target}/scripts/run-eversis-collections-mcp.sh"
  if [[ -f "$copied" ]] && cmp -s "$WRAPPER_TEMPLATE" "$copied"; then
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
# shellcheck source=mcp-user-overlap.sh
source "${LIB_DIR}/mcp-user-overlap.sh"

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
  '${workspaceFolder}' \
  "cursor (absolute) eversis-collections entry is docker compose -f \${env:AGENT_COLLECTIONS_HOME}/docker-compose.yml with env.CONSUMER_PROJECT_ROOT=\${workspaceFolder}"
if [[ ! -f "${TARGET_DIR}/scripts/run-eversis-collections-mcp.sh" ]]; then
  _pass "cursor absolute mode does not copy the Claude wrapper script"
else
  _fail "cursor absolute mode does not copy the Claude wrapper script"
fi

# Case 1b: cursor + vendored (copy) — relative -f path, same consumer-root token.
rm -rf "${TARGET_DIR}/.cursor" "${TARGET_DIR}/.mcp.json" "${TARGET_DIR}/scripts"
unset SELECTED_AGENTS MCP_SELECTED_IDS
VENDOR_MODE="copy"
merge_mcp_json
_assert_docker_entry "${TARGET_DIR}/.cursor/mcp.json" '${workspaceFolder}/vendor/agent-collections/docker-compose.yml' \
  '${workspaceFolder}' \
  "cursor+copy vendor mode eversis-collections entry uses relative -f and env.CONSUMER_PROJECT_ROOT=\${workspaceFolder}"
if [[ ! -f "${TARGET_DIR}/scripts/run-eversis-collections-mcp.sh" ]]; then
  _pass "cursor+copy does not copy the Claude wrapper script"
else
  _fail "cursor+copy does not copy the Claude wrapper script"
fi

# Case 2: claude only, absolute (non-relative) mode — Claude-native syntax.
# AGENT_COLLECTIONS_HOME uses \${VAR:-default} in the -f path; CONSUMER_PROJECT_ROOT
# is a separate env block with \${CLAUDE_PROJECT_DIR:-.}.
rm -rf "${TARGET_DIR}/.cursor" "${TARGET_DIR}/.mcp.json" "${TARGET_DIR}/scripts"
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
  '${CLAUDE_PROJECT_DIR:-.}' \
  "claude (absolute) eversis-collections entry is docker compose -f \${AGENT_COLLECTIONS_HOME:-<resolved>}/docker-compose.yml with env.CONSUMER_PROJECT_ROOT=\${CLAUDE_PROJECT_DIR:-.}"
if [[ ! -f "${TARGET_DIR}/scripts/run-eversis-collections-mcp.sh" ]]; then
  _pass "claude absolute mode does not copy the wrapper script"
else
  _fail "claude absolute mode does not copy the wrapper script"
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

# Case 3: claude + vendored (copy) — bash -c locator wrapper.
rm -rf "${TARGET_DIR}/.cursor" "${TARGET_DIR}/.mcp.json" "${TARGET_DIR}/scripts"
# Leave an unrelated file in scripts/ to prove merge does not wipe the dir.
mkdir -p "${TARGET_DIR}/scripts"
echo keep > "${TARGET_DIR}/scripts/unrelated.sh"
VENDOR_MODE="copy"
merge_mcp_json
_assert_claude_vendor_wrapper "${TARGET_DIR}/.mcp.json" \
  "claude+copy vendor mode eversis-collections entry is bash -c locator (no env)"
_assert_wrapper_script_copied "$TARGET_DIR" \
  "claude+copy copies run-eversis-collections-mcp.sh matching the template"
if [[ -f "${TARGET_DIR}/scripts/unrelated.sh" ]]; then
  _pass "claude+copy leaves other files in scripts/ untouched"
else
  _fail "claude+copy leaves other files in scripts/ untouched"
fi

# Case 3b: claude + vendored (submodule) — same wrapper.
rm -rf "${TARGET_DIR}/.cursor" "${TARGET_DIR}/.mcp.json" "${TARGET_DIR}/scripts"
VENDOR_MODE="submodule"
merge_mcp_json
_assert_claude_vendor_wrapper "${TARGET_DIR}/.mcp.json" \
  "claude+submodule vendor mode eversis-collections entry is bash -c locator (no env)"
_assert_wrapper_script_copied "$TARGET_DIR" \
  "claude+submodule copies run-eversis-collections-mcp.sh matching the template"

# Case 4: both agents selected together — independent, non-interfering outputs.
rm -rf "${TARGET_DIR}/.cursor" "${TARGET_DIR}/.mcp.json" "${TARGET_DIR}/scripts"
SELECTED_AGENTS="cursor,claude"
VENDOR_MODE=""
merge_mcp_json
if [[ -f "${TARGET_DIR}/.cursor/mcp.json" ]] && [[ -f "${TARGET_DIR}/.mcp.json" ]]; then
  _pass "cursor,claude writes both .cursor/mcp.json and .mcp.json"
else
  _fail "cursor,claude writes both .cursor/mcp.json and .mcp.json"
fi
_assert_docker_entry "${TARGET_DIR}/.cursor/mcp.json" '${env:AGENT_COLLECTIONS_HOME}/docker-compose.yml' \
  '${workspaceFolder}' \
  "cursor mcp.json keeps \${env:...} syntax unchanged (no regression)"
_assert_docker_entry "${TARGET_DIR}/.mcp.json" "\${AGENT_COLLECTIONS_HOME:-${REPO_ROOT}}/docker-compose.yml" \
  '${CLAUDE_PROJECT_DIR:-.}' \
  "claude mcp.json (paired with cursor) still resolves the absolute-mode docker entry correctly"

# Case 4b: cursor,claude + vendored copy — Cursor stays docker; Claude is wrapper.
rm -rf "${TARGET_DIR}/.cursor" "${TARGET_DIR}/.mcp.json" "${TARGET_DIR}/scripts"
SELECTED_AGENTS="cursor,claude"
VENDOR_MODE="copy"
merge_mcp_json
_assert_docker_entry "${TARGET_DIR}/.cursor/mcp.json" '${workspaceFolder}/vendor/agent-collections/docker-compose.yml' \
  '${workspaceFolder}' \
  "cursor,claude+copy keeps Cursor on docker + \${workspaceFolder}"
_assert_claude_vendor_wrapper "${TARGET_DIR}/.mcp.json" \
  "cursor,claude+copy puts Claude on the bash -c wrapper"
_assert_wrapper_script_copied "$TARGET_DIR" \
  "cursor,claude+copy copies the wrapper script once for Claude"

# Case 4b: submodule pin lacks the wrapper template. The running installer
# still has it (INSTALLER_FRAMEWORK_HOME). COLLECTIONS_HOME is only the pin.
_pinned="$(mktemp -d)"
mkdir -p "${_pinned}/templates"
cp "${REPO_ROOT}/templates/mcp.json" "${_pinned}/templates/mcp.json"
_saved_home="$COLLECTIONS_HOME"
COLLECTIONS_HOME="$_pinned"
INSTALLER_FRAMEWORK_HOME="$REPO_ROOT"
export INSTALLER_FRAMEWORK_HOME
rm -rf "${TARGET_DIR}/.cursor" "${TARGET_DIR}/.mcp.json" "${TARGET_DIR}/scripts"
SELECTED_AGENTS="claude"
VENDOR_MODE="submodule"
unset MCP_SELECTED_IDS
merge_mcp_json
_assert_claude_vendor_wrapper "${TARGET_DIR}/.mcp.json" \
  "claude+submodule with a stale pin still emits the bash -c wrapper"
_assert_wrapper_script_copied "$TARGET_DIR" \
  "claude+submodule with a stale pin copies the wrapper from INSTALLER_FRAMEWORK_HOME"
COLLECTIONS_HOME="$_saved_home"
unset INSTALLER_FRAMEWORK_HOME
rm -rf "$_pinned"
unset _pinned _saved_home

# Case 5: AWS API pins MCP Python SDK < 2; AWS docs requires SDK 2 (do not pin).
rm -rf "${TARGET_DIR}/.cursor" "${TARGET_DIR}/.mcp.json"
unset SELECTED_AGENTS VENDOR_MODE
MCP_SELECTED_IDS="eversis-collections,awslabs.aws-api-mcp-server,awslabs.aws-documentation-mcp-server"
merge_mcp_json
if node -e '
    const fs = require("fs");
    const j = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
    const api = j.mcpServers["awslabs.aws-api-mcp-server"] && j.mcpServers["awslabs.aws-api-mcp-server"].args;
    const docs = j.mcpServers["awslabs.aws-documentation-mcp-server"] && j.mcpServers["awslabs.aws-documentation-mcp-server"].args;
    const apiExpected = ["--with", "mcp<2", "awslabs.aws-api-mcp-server@latest"];
    const docsExpected = ["awslabs.aws-documentation-mcp-server@latest"];
    if (JSON.stringify(api) !== JSON.stringify(apiExpected)) process.exit(1);
    if (JSON.stringify(docs) !== JSON.stringify(docsExpected)) process.exit(1);
  ' "${TARGET_DIR}/.cursor/mcp.json"; then
  _pass "AWS API uvx pins mcp<2; AWS docs server stays unpinned"
else
  _fail "AWS API uvx pins mcp<2; AWS docs server stays unpinned"
fi

echo ""
echo "  ✅  All ${PASS} mcp-merge unit tests passed."
