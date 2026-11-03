#!/usr/bin/env bash
# mcp-merge.test.sh — unit tests for mcp-merge.sh host branching (Cursor vs
# Claude Code) and the Claude-native syntax transform in mcp-merge.mjs.
# Also covers the Pi host (AC-14): .pi/mcp.json bash -c locator entries and
# Pi failure isolation.
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
# Pi failure isolation (mark_pi_stage_failed) lives with the Pi stage.
FAILED_STEPS=()
record_fail() { FAILED_STEPS+=("$1"); }
# shellcheck source=link-framework.sh
source "${LIB_DIR}/link-framework.sh"

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

# Case 6 (AC-99): preserve mode — upgrade/sync reusing the record without
# --mcp-servers. Existing entries are kept byte-equal (custom env included),
# eversis-collections is regenerated, missing selected ids come from the
# template, nothing is deleted.
rm -rf "${TARGET_DIR}/.cursor" "${TARGET_DIR}/.mcp.json" "${TARGET_DIR}/scripts"
mkdir -p "${TARGET_DIR}/.cursor"
cat > "${TARGET_DIR}/.cursor/mcp.json" <<'EOF'
{
  "mcpServers": {
    "atlassian": { "url": "https://mcp.atlassian.com/v1/mcp", "type": "http", "env": { "TOKEN": "${env:MY_ATLASSIAN_TOKEN}" } },
    "eversis-collections": { "command": "stale", "args": [] },
    "my-private-server": { "command": "node", "args": ["./tools/mcp.js"] }
  },
  "inputs": [{ "id": "keep-me" }]
}
EOF
_preserve_before="$(cat "${TARGET_DIR}/.cursor/mcp.json")"
SELECTED_AGENTS="cursor"
VENDOR_MODE=""
MCP_SELECTED_IDS="eversis-collections,context7"
MCP_PRESERVE_EXISTING="true"
merge_mcp_json 2>/dev/null
if node -e '
    const fs = require("fs");
    const before = JSON.parse(process.argv[1]).mcpServers;
    const after = JSON.parse(fs.readFileSync(process.argv[2], "utf8")).mcpServers;
    if (JSON.stringify(after.atlassian) !== JSON.stringify(before.atlassian)) process.exit(1);
  ' "$_preserve_before" "${TARGET_DIR}/.cursor/mcp.json"; then
  _pass "preserve: unselected catalog id (atlassian, custom env) kept byte-equal"
else
  _fail "preserve: unselected catalog id (atlassian, custom env) kept byte-equal"
fi
_assert_docker_entry "${TARGET_DIR}/.cursor/mcp.json" '${env:AGENT_COLLECTIONS_HOME}/docker-compose.yml' \
  '${workspaceFolder}' \
  "preserve: eversis-collections is still regenerated"
if node -e '
    const fs = require("fs");
    const j = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
    const t = JSON.parse(fs.readFileSync(process.argv[2], "utf8")).mcpServers;
    if (JSON.stringify(j.mcpServers.context7) !== JSON.stringify(t.context7)) process.exit(1);
  ' "${TARGET_DIR}/.cursor/mcp.json" "${REPO_ROOT}/templates/mcp.json"; then
  _pass "preserve: selected id missing from the file (context7) added from template"
else
  _fail "preserve: selected id missing from the file (context7) added from template"
fi
if node -e '
    const fs = require("fs");
    const j = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
    if (!j.mcpServers["my-private-server"]) process.exit(1);
    if (JSON.stringify(j.inputs) !== JSON.stringify([{ id: "keep-me" }])) process.exit(1);
  ' "${TARGET_DIR}/.cursor/mcp.json"; then
  _pass "preserve: custom non-catalog server and existing inputs kept"
else
  _fail "preserve: custom non-catalog server and existing inputs kept"
fi

# Case 6b: a recorded (selected) id already in the file is not re-templated.
cat > "${TARGET_DIR}/.cursor/mcp.json" <<'EOF'
{ "mcpServers": { "context7": { "command": "npx", "args": ["-y", "@upstash/context7-mcp@1.0.0"], "env": { "CONTEXT7_API_KEY": "secret" } } } }
EOF
_preserve_before="$(cat "${TARGET_DIR}/.cursor/mcp.json")"
MCP_SELECTED_IDS="eversis-collections,context7"
MCP_PRESERVE_EXISTING="true"
merge_mcp_json 2>/dev/null
if node -e '
    const fs = require("fs");
    const before = JSON.parse(process.argv[1]).mcpServers;
    const after = JSON.parse(fs.readFileSync(process.argv[2], "utf8")).mcpServers;
    if (JSON.stringify(after.context7) !== JSON.stringify(before.context7)) process.exit(1);
  ' "$_preserve_before" "${TARGET_DIR}/.cursor/mcp.json"; then
  _pass "preserve: selected id already in the file keeps its customised config"
else
  _fail "preserve: selected id already in the file keeps its customised config"
fi

# Case 6c: regression guard — preserve false still prunes deselected catalog ids.
cat > "${TARGET_DIR}/.cursor/mcp.json" <<'EOF'
{ "mcpServers": { "atlassian": { "url": "https://mcp.atlassian.com/v1/mcp", "type": "http" }, "my-private-server": { "command": "node" } } }
EOF
MCP_SELECTED_IDS="eversis-collections"
MCP_PRESERVE_EXISTING="false"
merge_mcp_json
if node -e '
    const fs = require("fs");
    const j = JSON.parse(fs.readFileSync(process.argv[1], "utf8")).mcpServers;
    if (j.atlassian) process.exit(1);
    if (!j["my-private-server"] || !j["eversis-collections"]) process.exit(1);
  ' "${TARGET_DIR}/.cursor/mcp.json"; then
  _pass "preserve=false: deselected catalog id removed, custom server kept"
else
  _fail "preserve=false: deselected catalog id removed, custom server kept"
fi

# Case 6d: claude host preserve — existing entries are not touched by the
# Claude syntax rewrite; only template-sourced additions are rewritten.
rm -rf "${TARGET_DIR}/.cursor" "${TARGET_DIR}/.mcp.json" "${TARGET_DIR}/scripts"
cat > "${TARGET_DIR}/.mcp.json" <<'EOF'
{ "mcpServers": { "figma": { "url": "https://mcp.figma.com/mcp", "type": "http", "headers": { "X-Root": "${workspaceFolder}", "X-Key": "${env:FIGMA_KEY}" } } } }
EOF
_preserve_before="$(cat "${TARGET_DIR}/.mcp.json")"
SELECTED_AGENTS="claude"
MCP_SELECTED_IDS="eversis-collections,context7"
MCP_PRESERVE_EXISTING="true"
merge_mcp_json 2>/dev/null
if node -e '
    const fs = require("fs");
    const before = JSON.parse(process.argv[1]).mcpServers;
    const after = JSON.parse(fs.readFileSync(process.argv[2], "utf8"));
    if (JSON.stringify(after.mcpServers.figma) !== JSON.stringify(before.figma)) process.exit(1);
    if (!after.mcpServers.context7 || !after.mcpServers["eversis-collections"]) process.exit(1);
    if (after.inputs !== undefined) process.exit(1);
  ' "$_preserve_before" "${TARGET_DIR}/.mcp.json"; then
  _pass "claude preserve: existing entry not re-written by the Claude syntax rewrite"
else
  _fail "claude preserve: existing entry not re-written by the Claude syntax rewrite"
fi
_assert_docker_entry "${TARGET_DIR}/.mcp.json" "\${AGENT_COLLECTIONS_HOME:-${REPO_ROOT}}/docker-compose.yml" \
  '${CLAUDE_PROJECT_DIR:-.}' \
  "claude preserve: eversis-collections regenerated with Claude-native syntax"

# Case 6e (review S2): preserve mode regenerates an existing eversis-collections
# entry even when the record does not select it (framework-owned, may be stale
# after a vendor-mode change), and names it in the preserve log line.
rm -rf "${TARGET_DIR}/.cursor" "${TARGET_DIR}/.mcp.json" "${TARGET_DIR}/scripts"
mkdir -p "${TARGET_DIR}/.cursor"
cat > "${TARGET_DIR}/.cursor/mcp.json" <<'EOF'
{ "mcpServers": { "eversis-collections": { "command": "docker", "args": ["compose", "-f", "${workspaceFolder}/vendor/agent-collections/docker-compose.yml"] }, "context7": { "command": "npx" } } }
EOF
SELECTED_AGENTS="cursor"
VENDOR_MODE=""
MCP_SELECTED_IDS="context7"
MCP_PRESERVE_EXISTING="true"
_preserve_log="$(merge_mcp_json 2>&1 >/dev/null)"
_assert_docker_entry "${TARGET_DIR}/.cursor/mcp.json" '${env:AGENT_COLLECTIONS_HOME}/docker-compose.yml' \
  '${workspaceFolder}' \
  "preserve: unselected existing eversis-collections is regenerated for the current vendor mode"
if echo "$_preserve_log" | grep -qF 'regenerated: eversis-collections'; then
  _pass "preserve: log line names the regenerated eversis-collections entry"
else
  _fail "preserve: log line names the regenerated eversis-collections entry"
fi

# Case 6f: preserve mode does not add eversis-collections when it is neither
# selected nor already in the file.
cat > "${TARGET_DIR}/.cursor/mcp.json" <<'EOF'
{ "mcpServers": { "context7": { "command": "npx" } } }
EOF
MCP_SELECTED_IDS="context7"
MCP_PRESERVE_EXISTING="true"
merge_mcp_json 2>/dev/null
if node -e '
    const j = JSON.parse(require("fs").readFileSync(process.argv[1], "utf8")).mcpServers;
    if (j["eversis-collections"]) process.exit(1);
  ' "${TARGET_DIR}/.cursor/mcp.json"; then
  _pass "preserve: eversis-collections not added when unselected and absent"
else
  _fail "preserve: eversis-collections not added when unselected and absent"
fi
unset MCP_PRESERVE_EXISTING _preserve_before _preserve_log

# --- Pi host (AC-14) --------------------------------------------------------
# Asserts the Pi eversis-collections entry is a bash -c locator that walks up
# to the nearest .pi/ and that the file has no inputs and no host variable Pi
# cannot expand in any command / args value.
_assert_pi_mcp_shape() {
  local file="$1" mode="$2" label="$3"
  if node -e '
      const fs = require("fs");
      const [file, mode, home] = process.argv.slice(1);
      const j = JSON.parse(fs.readFileSync(file, "utf8"));
      if (j.inputs !== undefined) process.exit(1);
      const e = j.mcpServers["eversis-collections"];
      if (!e || e.command !== "bash" || !Array.isArray(e.args) || e.args[0] !== "-c") process.exit(2);
      if (e.type !== "stdio" || e.env !== undefined) process.exit(3);
      const script = e.args[1] || "";
      if (!script.includes("[ ! -d \"$d/.pi\" ]")) process.exit(4);
      if (mode === "vendored") {
        if (!script.includes("exec \"$d/scripts/run-eversis-collections-mcp.sh\"")) process.exit(5);
        if (script.includes("${")) process.exit(6);
      } else {
        if (!script.includes("CONSUMER_PROJECT_ROOT=\"$d\" exec docker compose -f \"${AGENT_COLLECTIONS_HOME:-" + home + "}/docker-compose.yml\" run --rm -T eversis-collections")) process.exit(7);
      }
      for (const [id, cfg] of Object.entries(j.mcpServers)) {
        const vals = [cfg.command, ...(cfg.args || [])].filter((v) => typeof v === "string");
        for (let v of vals) {
          if (id === "eversis-collections") v = v.replace(/\$\{AGENT_COLLECTIONS_HOME:-[^}]*\}/g, "");
          if (v.includes("${workspaceFolder}") || v.includes("${env:") || v.includes("CLAUDE_PROJECT_DIR") || v.includes("${")) process.exit(8);
        }
      }
    ' "$file" "$mode" "$REPO_ROOT"; then
    _pass "$label"
  else
    _fail "$label (shape check exit $?)"
  fi
}

# Case 7: pi + vendored (copy) — locator execs the committed wrapper; only
# .pi/mcp.json is written; other catalog servers copied as-is.
rm -rf "${TARGET_DIR}/.cursor" "${TARGET_DIR}/.mcp.json" "${TARGET_DIR}/.pi" "${TARGET_DIR}/scripts"
SELECTED_AGENTS="pi"
VENDOR_MODE="copy"
MCP_SELECTED_IDS="eversis-collections,context7,figma"
PI_STAGE_FAILED="false"
merge_mcp_json
if [[ -f "${TARGET_DIR}/.pi/mcp.json" ]] && [[ ! -f "${TARGET_DIR}/.cursor/mcp.json" ]] && [[ ! -f "${TARGET_DIR}/.mcp.json" ]]; then
  _pass "pi-only writes only .pi/mcp.json"
else
  _fail "pi-only writes only .pi/mcp.json"
fi
_assert_pi_mcp_shape "${TARGET_DIR}/.pi/mcp.json" vendored \
  "pi+copy: eversis-collections is a bash -c .pi/ walk-up locator exec'ing the wrapper; no inputs, no host variables"
_assert_wrapper_script_copied "$TARGET_DIR" \
  "pi+copy copies run-eversis-collections-mcp.sh matching the template"
if node -e '
    const fs = require("fs");
    const j = JSON.parse(fs.readFileSync(process.argv[1], "utf8")).mcpServers;
    const t = JSON.parse(fs.readFileSync(process.argv[2], "utf8")).mcpServers;
    if (JSON.stringify(j.context7) !== JSON.stringify(t.context7)) process.exit(1);
    if (JSON.stringify(j.figma) !== JSON.stringify(t.figma)) process.exit(1);
  ' "${TARGET_DIR}/.pi/mcp.json" "${REPO_ROOT}/templates/mcp.json"; then
  _pass "pi: other catalog servers are copied as-is from the template"
else
  _fail "pi: other catalog servers are copied as-is from the template"
fi
# The locator finds the project root from a subdirectory (Pi spawns stdio
# servers in the session directory). A stub wrapper prints its own location.
mkdir -p "${TARGET_DIR}/src/deep/dir"
printf '#!/usr/bin/env bash\necho "wrapper:$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"\n' \
  > "${TARGET_DIR}/scripts/run-eversis-collections-mcp.sh"
_pi_locator="$(node -e 'console.log(JSON.parse(require("fs").readFileSync(process.argv[1],"utf8")).mcpServers["eversis-collections"].args[1])' "${TARGET_DIR}/.pi/mcp.json")"
_pi_out="$(cd "${TARGET_DIR}/src/deep/dir" && bash -c "$_pi_locator" 2>&1)" || true
if [[ "$_pi_out" == "wrapper:$(cd "$TARGET_DIR" && pwd)" ]]; then
  _pass "pi vendored locator walks up from a subdirectory to the .pi/ project root"
else
  echo "    got: ${_pi_out}"
  _fail "pi vendored locator walks up from a subdirectory to the .pi/ project root"
fi

# Case 7b: pi + local mode — docker compose with the resolved framework path
# as the bash default and CONSUMER_PROJECT_ROOT from the .pi/ walk-up.
rm -rf "${TARGET_DIR}/.pi" "${TARGET_DIR}/scripts"
VENDOR_MODE=""
MCP_SELECTED_IDS="eversis-collections"
merge_mcp_json
_assert_pi_mcp_shape "${TARGET_DIR}/.pi/mcp.json" local \
  "pi local: eversis-collections bash -c locator runs docker compose with \${AGENT_COLLECTIONS_HOME:-<resolved>} inside the bash script"
if [[ ! -f "${TARGET_DIR}/scripts/run-eversis-collections-mcp.sh" ]]; then
  _pass "pi local mode does not copy the wrapper script"
else
  _fail "pi local mode does not copy the wrapper script"
fi
_fake_bin="$(mktemp -d)"
printf '#!/usr/bin/env bash\necho "docker root=$CONSUMER_PROJECT_ROOT args=$*"\n' > "${_fake_bin}/docker"
chmod +x "${_fake_bin}/docker"
_pi_locator="$(node -e 'console.log(JSON.parse(require("fs").readFileSync(process.argv[1],"utf8")).mcpServers["eversis-collections"].args[1])' "${TARGET_DIR}/.pi/mcp.json")"
_pi_out="$(cd "${TARGET_DIR}/src/deep/dir" && env -u AGENT_COLLECTIONS_HOME PATH="${_fake_bin}:${PATH}" bash -c "$_pi_locator" 2>&1)" || true
if [[ "$_pi_out" == "docker root=$(cd "$TARGET_DIR" && pwd) args=compose -f ${REPO_ROOT}/docker-compose.yml run --rm -T eversis-collections" ]]; then
  _pass "pi local locator sets CONSUMER_PROJECT_ROOT to the .pi/ root and falls back to the resolved framework path"
else
  echo "    got: ${_pi_out}"
  _fail "pi local locator sets CONSUMER_PROJECT_ROOT to the .pi/ root and falls back to the resolved framework path"
fi
rm -rf "$_fake_bin" "${TARGET_DIR}/src"
unset _fake_bin _pi_locator _pi_out

# Case 7b2: pi + local mode with a framework path containing characters that
# would break a double-quoted ${VAR:-word} default (} " $ ` and ' plus a
# space). With AGENT_COLLECTIONS_HOME unset the locator must hand docker the
# exact path; the Pi host-variable check must not flag the baked-in path.
_weird_parent="$(mktemp -d)"
_weird_home="${_weird_parent}/fw }\"\$HOME\`x\`'q {a}"
mkdir -p "${_weird_home}/templates"
cp "${REPO_ROOT}/templates/mcp.json" "${_weird_home}/templates/mcp.json"
_saved_home="$COLLECTIONS_HOME"
COLLECTIONS_HOME="$_weird_home"
rm -rf "${TARGET_DIR}/.pi" "${TARGET_DIR}/scripts"
SELECTED_AGENTS="pi"
VENDOR_MODE=""
MCP_SELECTED_IDS="eversis-collections"
PI_STAGE_FAILED="false"
merge_mcp_json
COLLECTIONS_HOME="$_saved_home"
if [[ "$PI_STAGE_FAILED" == "false" ]] && [[ -f "${TARGET_DIR}/.pi/mcp.json" ]]; then
  _pass "pi local: special-character framework path passes the Pi host-variable check"
else
  _fail "pi local: special-character framework path passes the Pi host-variable check"
fi
_fake_bin="$(mktemp -d)"
printf '#!/usr/bin/env bash\nprintf "%%s\\n" "$3"\n' > "${_fake_bin}/docker"
chmod +x "${_fake_bin}/docker"
mkdir -p "${TARGET_DIR}/src/deep/dir"
_pi_locator="$(node -e 'console.log(JSON.parse(require("fs").readFileSync(process.argv[1],"utf8")).mcpServers["eversis-collections"].args[1])' "${TARGET_DIR}/.pi/mcp.json")"
_pi_out="$(cd "${TARGET_DIR}/src/deep/dir" && env -u AGENT_COLLECTIONS_HOME PATH="${_fake_bin}:${PATH}" bash -c "$_pi_locator" 2>&1)" || true
if [[ "$_pi_out" == "${_weird_home}/docker-compose.yml" ]]; then
  _pass "pi local: framework path with } \" \$ \` ' reaches docker compose -f byte-exact (AGENT_COLLECTIONS_HOME unset)"
else
  echo "    expected: ${_weird_home}/docker-compose.yml"
  echo "    got:      ${_pi_out}"
  _fail "pi local: framework path with } \" \$ \` ' reaches docker compose -f byte-exact (AGENT_COLLECTIONS_HOME unset)"
fi
_pi_out="$(cd "${TARGET_DIR}/src/deep/dir" && AGENT_COLLECTIONS_HOME=/override PATH="${_fake_bin}:${PATH}" bash -c "$_pi_locator" 2>&1)" || true
if [[ "$_pi_out" == "/override/docker-compose.yml" ]]; then
  _pass "pi local: exported AGENT_COLLECTIONS_HOME still overrides the special-character default"
else
  echo "    got: ${_pi_out}"
  _fail "pi local: exported AGENT_COLLECTIONS_HOME still overrides the special-character default"
fi
rm -rf "$_fake_bin" "$_weird_parent" "${TARGET_DIR}/src" "${TARGET_DIR}/.pi"
unset _fake_bin _pi_locator _pi_out _weird_parent _weird_home _saved_home

# Case 7c: cursor,claude,pi together — Cursor / Claude files unchanged by Pi.
rm -rf "${TARGET_DIR}/.cursor" "${TARGET_DIR}/.mcp.json" "${TARGET_DIR}/.pi" "${TARGET_DIR}/scripts"
SELECTED_AGENTS="cursor,claude,pi"
VENDOR_MODE=""
merge_mcp_json
_assert_docker_entry "${TARGET_DIR}/.cursor/mcp.json" '${env:AGENT_COLLECTIONS_HOME}/docker-compose.yml' \
  '${workspaceFolder}' \
  "cursor,claude,pi: Cursor entry unchanged"
_assert_docker_entry "${TARGET_DIR}/.mcp.json" "\${AGENT_COLLECTIONS_HOME:-${REPO_ROOT}}/docker-compose.yml" \
  '${CLAUDE_PROJECT_DIR:-.}' \
  "cursor,claude,pi: Claude entry unchanged"
_assert_pi_mcp_shape "${TARGET_DIR}/.pi/mcp.json" local "cursor,claude,pi: Pi entry written"

# Case 7d: malformed existing .pi/mcp.json → Pi failure recorded (no die),
# Cursor file still written, Pi file left untouched.
rm -rf "${TARGET_DIR}/.cursor" "${TARGET_DIR}/.mcp.json" "${TARGET_DIR}/.pi"
mkdir -p "${TARGET_DIR}/.pi"
echo '{not-json' > "${TARGET_DIR}/.pi/mcp.json"
SELECTED_AGENTS="cursor,pi"
PI_STAGE_FAILED="false"
PI_STAGE_FAILURE_REASON=""
FAILED_STEPS=()
_rc=0
_pi_log="$(merge_mcp_json 2>&1)" || _rc=$?
# merge_mcp_json ran in a subshell above; re-run in this shell for the flags.
PI_STAGE_FAILED="false"
FAILED_STEPS=()
merge_mcp_json >/dev/null 2>&1 || _rc=$?
if [[ "$_rc" -eq 0 ]] && [[ "$PI_STAGE_FAILED" == "true" ]] \
  && [[ " ${FAILED_STEPS[*]-} " == *" pi "* ]] \
  && [[ "$PI_STAGE_FAILURE_REASON" == *".pi/mcp.json merge failed"* ]] \
  && echo "$_pi_log" | grep -qF "pi: .pi/mcp.json merge failed"; then
  _pass "malformed .pi/mcp.json: Pi failure recorded (flag, reason, record_fail pi), merge_mcp_json returns 0"
else
  echo "$_pi_log"
  _fail "malformed .pi/mcp.json: Pi failure recorded (flag, reason, record_fail pi), merge_mcp_json returns 0"
fi
if [[ -f "${TARGET_DIR}/.cursor/mcp.json" ]] && [[ "$(cat "${TARGET_DIR}/.pi/mcp.json")" == "{not-json" ]]; then
  _pass "malformed .pi/mcp.json: .cursor/mcp.json still written, .pi/mcp.json left as it was"
else
  _fail "malformed .pi/mcp.json: .cursor/mcp.json still written, .pi/mcp.json left as it was"
fi

# Case 7e: Pi stage already failed → .pi/mcp.json merge skipped.
rm -rf "${TARGET_DIR}/.cursor" "${TARGET_DIR}/.pi"
PI_STAGE_FAILED="true"
merge_mcp_json 2>/dev/null
if [[ -f "${TARGET_DIR}/.cursor/mcp.json" ]] && [[ ! -e "${TARGET_DIR}/.pi/mcp.json" ]]; then
  _pass "Pi stage already failed: .pi/mcp.json merge skipped, Cursor still written"
else
  _fail "Pi stage already failed: .pi/mcp.json merge skipped, Cursor still written"
fi
PI_STAGE_FAILED="false"
PI_STAGE_FAILURE_REASON=""

# Case 7f: a catalog server whose command / args carry a host variable Pi
# never expands there (here ${workspaceFolder}) fails the Pi merge instead of
# writing an entry that cannot start.
_pinned="$(mktemp -d)"
mkdir -p "${_pinned}/templates"
node -e '
  const fs = require("fs");
  const t = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
  t.mcpServers.context7.args = ["-y", "@upstash/context7-mcp@latest", "--root", "${workspaceFolder}"];
  fs.writeFileSync(process.argv[2], JSON.stringify(t, null, 2));
' "${REPO_ROOT}/templates/mcp.json" "${_pinned}/templates/mcp.json"
_saved_home="$COLLECTIONS_HOME"
COLLECTIONS_HOME="$_pinned"
rm -rf "${TARGET_DIR}/.cursor" "${TARGET_DIR}/.pi"
SELECTED_AGENTS="cursor,pi"
MCP_SELECTED_IDS="eversis-collections,context7"
FAILED_STEPS=()
_pi_log="$(merge_mcp_json 2>&1)" || true
merge_mcp_json >/dev/null 2>&1 || true
if [[ "$PI_STAGE_FAILED" == "true" ]] && [[ ! -e "${TARGET_DIR}/.pi/mcp.json" ]] \
  && echo "$_pi_log" | grep -qF "host variable Pi does not expand" \
  && echo "$_pi_log" | grep -qF "context7"; then
  _pass "pi: \${workspaceFolder} in a catalog server's args fails the Pi merge (no .pi/mcp.json written)"
else
  echo "$_pi_log"
  _fail "pi: \${workspaceFolder} in a catalog server's args fails the Pi merge (no .pi/mcp.json written)"
fi
COLLECTIONS_HOME="$_saved_home"
rm -rf "$_pinned"
PI_STAGE_FAILED="false"
PI_STAGE_FAILURE_REASON=""
unset _pinned _saved_home
unset SELECTED_AGENTS VENDOR_MODE MCP_SELECTED_IDS _rc _pi_log

echo ""
echo "  ✅  All ${PASS} mcp-merge unit tests passed."
