#!/usr/bin/env bash
# claude-settings-merge.test.sh — unit tests for merge_claude_settings()
# (.claude/settings.json seed-once + permissions.deny/enabledMcpjsonServers
# refresh-every-run split, Q8 in claude-code-setup.plan.md), the framework
# PostToolUse spec artifact hook entry, and remove_claude_framework_hook().
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

# Case 6: preserve mode unions catalog ids already in .mcp.json into
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

# Framework PostToolUse hook entry (spec artifact guard): present only with
# its launcher, one entry, consumer hooks kept.
SETTINGS="${TARGET_DIR}/.claude/settings.json"
LAUNCHER="${TARGET_DIR}/.claude/hooks/eversis-validate-spec.cjs"
FW_COMMAND='node "${CLAUDE_PROJECT_DIR}/.claude/hooks/eversis-validate-spec.cjs"'
# Prints: <framework entry count>|<its matcher>|<PostToolUse matchers in order>|<hook event keys>
_hooks_summary() {
  node -e '
    const j = JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"));
    const post = (j.hooks && j.hooks.PostToolUse) || [];
    const fw = post.filter((e) => (e.hooks || []).some((h) => String(h.command).includes(".claude/hooks/eversis-validate-spec.cjs")));
    const ok = fw.length === 1 && fw[0].hooks.length === 1 && fw[0].hooks[0].type === "command" && fw[0].hooks[0].command === process.argv[2];
    console.log([fw.length, fw.length ? fw[0].matcher + (ok ? "" : "(bad command)") : "", post.map((e) => e.matcher).join(","), Object.keys(j.hooks || {}).join(",")].join("|"));
  ' "$SETTINGS" "$FW_COMMAND"
}

rm -f "$SETTINGS"
mkdir -p "$(dirname "$LAUNCHER")"
echo '// launcher stub' > "$LAUNCHER"
merge_claude_settings
if [[ "$(_hooks_summary)" == "1|Write|Edit|MultiEdit|Write|Edit|MultiEdit|PostToolUse" ]]; then
  _pass "hook: launcher present → new file gets one framework PostToolUse entry"
else
  _fail "hook: launcher present → new file gets one framework PostToolUse entry (got: $(_hooks_summary))"
fi

cp "$SETTINGS" "${TARGET_DIR}/settings.first"
merge_claude_settings
if cmp -s "$SETTINGS" "${TARGET_DIR}/settings.first"; then
  _pass "hook: second run is byte-identical"
else
  _fail "hook: second run is byte-identical"
fi

# Consumer hooks around a stale framework entry (old matcher).
node -e '
  const fs = require("fs");
  const p = process.argv[1];
  const j = JSON.parse(fs.readFileSync(p, "utf8"));
  j.hooks = {
    PreToolUse: [{ matcher: "Bash", hooks: [{ type: "command", command: "echo pre" }] }],
    PostToolUse: [
      { matcher: "Bash", hooks: [{ type: "command", command: "echo consumer-first" }] },
      { matcher: "Write", hooks: [{ type: "command", command: "node .claude/hooks/eversis-validate-spec.cjs" }] },
      { matcher: "Read", hooks: [{ type: "command", command: "echo consumer-last" }] },
    ],
  };
  fs.writeFileSync(p, JSON.stringify(j, null, 2) + "\n");
' "$SETTINGS"
merge_claude_settings
if [[ "$(_hooks_summary)" == "1|Write|Edit|MultiEdit|Bash,Write|Edit|MultiEdit,Read|PreToolUse,PostToolUse" ]]; then
  _pass "hook: stale framework entry replaced in place, consumer PostToolUse and PreToolUse kept in order"
else
  _fail "hook: stale framework entry replaced in place, consumer PostToolUse and PreToolUse kept in order (got: $(_hooks_summary))"
fi
grep -qF 'echo consumer-first' "$SETTINGS" && grep -qF 'echo consumer-last' "$SETTINGS" && grep -qF 'echo pre' "$SETTINGS" \
  && _pass "hook: consumer hook commands unchanged" \
  || _fail "hook: consumer hook commands unchanged"

# Launcher absent → framework entry removed, consumer hooks stay.
rm -f "$LAUNCHER"
merge_claude_settings
if [[ "$(_hooks_summary)" == "0||Bash,Read|PreToolUse,PostToolUse" ]]; then
  _pass "hook: launcher absent → framework entry removed, consumer hooks kept"
else
  _fail "hook: launcher absent → framework entry removed, consumer hooks kept (got: $(_hooks_summary))"
fi
merge_claude_settings
if [[ "$(_hooks_summary)" == "0||Bash,Read|PreToolUse,PostToolUse" ]]; then
  _pass "hook: launcher absent → no framework entry added"
else
  _fail "hook: launcher absent → no framework entry added (got: $(_hooks_summary))"
fi

# Launcher absent and only the framework entry → emptied hooks key dropped.
echo '// launcher stub' > "$LAUNCHER"
node -e '
  const fs = require("fs");
  const p = process.argv[1];
  const j = JSON.parse(fs.readFileSync(p, "utf8"));
  delete j.hooks;
  fs.writeFileSync(p, JSON.stringify(j, null, 2) + "\n");
' "$SETTINGS"
merge_claude_settings
rm -f "$LAUNCHER"
merge_claude_settings
if node -e 'const j=JSON.parse(require("fs").readFileSync(process.argv[1],"utf8")); process.exit("hooks" in j ? 1 : 0)' "$SETTINGS"; then
  _pass "hook: removal that empties PostToolUse drops the hooks key"
else
  _fail "hook: removal that empties PostToolUse drops the hooks key"
fi

# "hooks": [] is refused, like a non-object "permissions".
node -e '
  const fs = require("fs");
  const p = process.argv[1];
  const j = JSON.parse(fs.readFileSync(p, "utf8"));
  j.hooks = [];
  fs.writeFileSync(p, JSON.stringify(j, null, 2) + "\n");
' "$SETTINGS"
echo '// launcher stub' > "$LAUNCHER"
cp "$SETTINGS" "${TARGET_DIR}/settings.array"
HOOK_ERR="${TARGET_DIR}/hook-array.err"
if ( merge_claude_settings ) >/dev/null 2>"$HOOK_ERR"; then
  _fail "hook: \"hooks\": [] is refused"
elif grep -qF '"hooks" is not an object' "$HOOK_ERR" && cmp -s "$SETTINGS" "${TARGET_DIR}/settings.array"; then
  _pass "hook: \"hooks\": [] is refused with a clear message, file untouched"
else
  _fail "hook: \"hooks\": [] is refused with a clear message, file untouched ($(cat "$HOOK_ERR"))"
fi

# CS_MODE=remove-hook (Claude deselected): only the framework entry goes.
cat > "$SETTINGS" <<'JSON'
{
  "permissions": { "allow": ["Read", "Bash(make *)"], "deny": ["Read(./secret/**)"], "ask": ["Bash(git push*)"] },
  "enabledMcpjsonServers": ["eversis-collections", "my-private-server"],
  "hooks": {
    "PostToolUse": [
      { "matcher": "Write|Edit|MultiEdit", "hooks": [ { "type": "command", "command": "node \"${CLAUDE_PROJECT_DIR}/.claude/hooks/eversis-validate-spec.cjs\"" } ] },
      { "matcher": "Bash", "hooks": [ { "type": "command", "command": "echo consumer" } ] }
    ]
  }
}
JSON
_keys_json() {
  node -e 'const j=JSON.parse(require("fs").readFileSync(process.argv[1],"utf8")); console.log(JSON.stringify([j.permissions, j.enabledMcpjsonServers]))' "$SETTINGS"
}
KEYS_BEFORE="$(_keys_json)"
remove_claude_framework_hook >/dev/null
if [[ "$(_hooks_summary)" == "0||Bash|PostToolUse" ]] && [[ "$(_keys_json)" == "$KEYS_BEFORE" ]]; then
  _pass "remove-hook: only the framework entry removed; permissions and enabledMcpjsonServers identical"
else
  _fail "remove-hook: only the framework entry removed; permissions and enabledMcpjsonServers identical (got: $(_hooks_summary); $(_keys_json))"
fi
cp "$SETTINGS" "${TARGET_DIR}/settings.removed"
remove_claude_framework_hook >/dev/null
if cmp -s "$SETTINGS" "${TARGET_DIR}/settings.removed"; then
  _pass "remove-hook: no framework entry → file not rewritten"
else
  _fail "remove-hook: no framework entry → file not rewritten"
fi
rm -f "$SETTINGS"
remove_claude_framework_hook >/dev/null
if [[ ! -e "$SETTINGS" ]]; then
  _pass "remove-hook: absent settings file stays absent"
else
  _fail "remove-hook: absent settings file stays absent"
fi
rm -f "$LAUNCHER"

echo ""
echo "  ✅  All ${PASS} claude-settings-merge unit tests passed."
