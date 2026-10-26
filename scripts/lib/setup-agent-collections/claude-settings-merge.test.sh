#!/usr/bin/env bash
# claude-settings-merge.test.sh — unit tests for merge_claude_settings()
# (.claude/settings.json seed-once + permissions.deny/enabledMcpjsonServers
# refresh-every-run split, Q8 in claude-code-setup.plan.md).
#
# Usage (from repo root):
#   bash scripts/lib/setup-agent-collections/claude-settings-merge.test.sh

set -euo pipefail

LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${LIB_DIR}/../../.." && pwd)"

PASS=0
FAIL=0

_pass() { echo "  ✓ $1"; PASS=$(( PASS + 1 )); }
_fail() { echo "  ✗ $1"; FAIL=$(( FAIL + 1 )); exit 1; }

COLLECTIONS_HOME="$REPO_ROOT"
TARGET_DIR="$(mktemp -d)"
trap 'rm -rf "$TARGET_DIR"' EXIT

SELECTED_AGENTS="claude"
MCP_CONFIGURED_SERVERS="eversis-collections"

# shellcheck source=common.sh
source "${LIB_DIR}/common.sh"
# shellcheck source=claude-settings-merge.sh
source "${LIB_DIR}/claude-settings-merge.sh"

echo "claude-settings-merge.sh unit tests"
echo ""

# Case 1: not selected — no-op, no file written.
SELECTED_AGENTS="cursor"
merge_claude_settings
if [[ ! -f "${TARGET_DIR}/.claude/settings.json" ]]; then
  _pass "claude not selected: no .claude/settings.json written"
else
  _fail "claude not selected: no .claude/settings.json written"
fi
SELECTED_AGENTS="claude"

# Case 2: seed-once — first run creates the file from the template.
merge_claude_settings
if [[ -f "${TARGET_DIR}/.claude/settings.json" ]]; then
  _pass "first run seeds .claude/settings.json"
else
  _fail "first run seeds .claude/settings.json"
fi
if grep -qF '"eversis-collections"' "${TARGET_DIR}/.claude/settings.json"; then
  _pass "seeded file has enabledMcpjsonServers"
else
  _fail "seeded file has enabledMcpjsonServers"
fi
if grep -qF '"allow"' "${TARGET_DIR}/.claude/settings.json"; then
  _pass "seeded file carries the template's permissions.allow"
else
  _fail "seeded file carries the template's permissions.allow"
fi

# Case 3: hand-edited foreign key survives a re-run; deny/enabledMcpjsonServers refresh.
node -e '
  const fs = require("fs");
  const path = process.argv[1];
  const j = JSON.parse(fs.readFileSync(path, "utf8"));
  j.model = "opus";
  fs.writeFileSync(path, JSON.stringify(j, null, 2) + "\n");
' "${TARGET_DIR}/.claude/settings.json"
MCP_CONFIGURED_SERVERS="eversis-collections,context7"
merge_claude_settings
if grep -qF '"model": "opus"' "${TARGET_DIR}/.claude/settings.json"; then
  _pass "hand-added foreign key (model) survives re-run"
else
  _fail "hand-added foreign key (model) survives re-run"
fi
if grep -qF '"context7"' "${TARGET_DIR}/.claude/settings.json"; then
  _pass "enabledMcpjsonServers refreshed on re-run"
else
  _fail "enabledMcpjsonServers refreshed on re-run"
fi

# Case 4: permissions.deny is regenerated from .claudeignore path classes.
cat > "${TARGET_DIR}/.claudeignore" <<'EOF'
# secrets / build
node_modules/
.env
*.pem

# other-tool packaging
.cursor/
EOF
merge_claude_settings
DENY_JSON="${TARGET_DIR}/.claude/settings.json"
if grep -qF 'Read(./**/node_modules/**)' "$DENY_JSON" && \
   grep -qF 'Read(./**/.env)' "$DENY_JSON" && \
   grep -qF 'Read(./**/*.pem)' "$DENY_JSON" && \
   grep -qF 'Read(./**/.cursor/**)' "$DENY_JSON"; then
  _pass "permissions.deny regenerated from .claudeignore classes"
else
  _fail "permissions.deny regenerated from .claudeignore classes"
fi
if node -e "JSON.parse(require('fs').readFileSync('${DENY_JSON}','utf8'))" 2>/dev/null; then
  _pass "final .claude/settings.json is valid JSON"
else
  _fail "final .claude/settings.json is valid JSON"
fi

# Case 5: leading-slash (root-anchored) .claudeignore patterns must not
# produce a malformed "./" + "/x" double-slash glob.
cat > "${TARGET_DIR}/.claudeignore" <<'EOF'
/dist/
/secrets.env
EOF
merge_claude_settings
if grep -qF 'Read(./dist/**)' "$DENY_JSON" && grep -qF 'Read(./secrets.env)' "$DENY_JSON"; then
  _pass "leading-slash .claudeignore patterns produce single-slash globs"
else
  _fail "leading-slash .claudeignore patterns produce single-slash globs"
fi
if grep -qF './/' "$DENY_JSON"; then
  _fail "no double-slash glob in permissions.deny"
else
  _pass "no double-slash glob in permissions.deny"
fi

# Case 6 (AC-99): preserve mode unions catalog ids already in .mcp.json into
# enabledMcpjsonServers (selection order first); non-catalog ids are ignored.
cat > "${TARGET_DIR}/.mcp.json" <<'EOF'
{ "mcpServers": { "atlassian": { "type": "http" }, "eversis-collections": {}, "my-private-server": {} } }
EOF
_enabled() {
  node -e "const j=JSON.parse(require('fs').readFileSync(process.argv[1],'utf8')); console.log((j.enabledMcpjsonServers||[]).join(','))" \
    "${TARGET_DIR}/.claude/settings.json"
}
MCP_CONFIGURED_SERVERS="eversis-collections,context7"
MCP_PRESERVE_EXISTING="true"
merge_claude_settings
if [[ "$(_enabled)" == "eversis-collections,context7,atlassian" ]]; then
  _pass "preserve: enabledMcpjsonServers = selection + catalog ids in .mcp.json"
else
  _fail "preserve: enabledMcpjsonServers = selection + catalog ids in .mcp.json (got: $(_enabled))"
fi

MCP_PRESERVE_EXISTING="false"
merge_claude_settings
if [[ "$(_enabled)" == "eversis-collections,context7" ]]; then
  _pass "preserve=false: enabledMcpjsonServers = selection only"
else
  _fail "preserve=false: enabledMcpjsonServers = selection only (got: $(_enabled))"
fi

# Missing / invalid .mcp.json in preserve mode falls back to the selection.
echo '{ not json' > "${TARGET_DIR}/.mcp.json"
MCP_PRESERVE_EXISTING="true"
merge_claude_settings
if [[ "$(_enabled)" == "eversis-collections,context7" ]]; then
  _pass "preserve: invalid .mcp.json falls back to selection only"
else
  _fail "preserve: invalid .mcp.json falls back to selection only (got: $(_enabled))"
fi
rm -f "${TARGET_DIR}/.mcp.json"
merge_claude_settings
if [[ "$(_enabled)" == "eversis-collections,context7" ]]; then
  _pass "preserve: missing .mcp.json falls back to selection only"
else
  _fail "preserve: missing .mcp.json falls back to selection only (got: $(_enabled))"
fi
unset MCP_PRESERVE_EXISTING

echo ""
echo "  ✅  All ${PASS} claude-settings-merge unit tests passed."
