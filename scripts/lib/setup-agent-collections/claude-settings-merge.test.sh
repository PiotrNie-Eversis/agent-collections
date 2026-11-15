#!/usr/bin/env bash
# claude-settings-merge.test.sh — unit tests for merge_claude_settings()
# (.claude/settings.json seed-once + permissions.deny/enabledMcpjsonServers
# refresh-every-run split, Q8 in claude-code-setup.plan.md), the framework
# spec artifact hook entries (PreToolUse on Bash and PostToolUse on
# Write|Edit|MultiEdit|Bash), and remove_claude_framework_hook().
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

# Framework hook entries (spec artifact guard): one PreToolUse (Bash) and one
# PostToolUse (Write|Edit|MultiEdit|Bash), present only with their launcher,
# consumer hooks kept.
SETTINGS="${TARGET_DIR}/.claude/settings.json"
LAUNCHER="${TARGET_DIR}/.claude/hooks/eversis-validate-spec.cjs"
FW_COMMAND='node "${CLAUDE_PROJECT_DIR}/.claude/hooks/eversis-validate-spec.cjs"'
FW_PRE='Bash'
FW_POST='Write|Edit|MultiEdit|Bash'
# Prints one line per owned event, then the hook event keys:
#   PreToolUse=<framework entry count>:<its matcher>:<matchers in order>
#   PostToolUse=<framework entry count>:<its matcher>:<matchers in order>
#   keys=<hook event keys in order>
# Matchers in order are joined with ";" (a matcher may contain "|"); the
# framework entry is shown as "FW[<matcher>]" so its position is visible.
_hooks_summary() {
  node -e '
    const j = JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"));
    const isFw = (e) => (e.hooks || []).some((h) => String(h.command).includes(".claude/hooks/eversis-validate-spec.cjs"));
    const out = [];
    for (const ev of ["PreToolUse", "PostToolUse"]) {
      const arr = (j.hooks && j.hooks[ev]) || [];
      const fw = arr.filter(isFw);
      const ok = fw.length === 1 && fw[0].hooks.length === 1 && fw[0].hooks[0].type === "command" && fw[0].hooks[0].command === process.argv[2];
      const order = arr.map((e) => (isFw(e) ? `FW[${e.matcher}]` : e.matcher)).join(";");
      out.push(`${ev}=${fw.length}:${fw.length ? fw[0].matcher + (ok ? "" : "(bad command)") : ""}:${order}`);
    }
    out.push(`keys=${Object.keys(j.hooks || {}).join(",")}`);
    console.log(out.join(" "));
  ' "$SETTINGS" "$FW_COMMAND"
}

rm -f "$SETTINGS"
mkdir -p "$(dirname "$LAUNCHER")"
echo '// launcher stub' > "$LAUNCHER"
merge_claude_settings
WANT="PreToolUse=1:${FW_PRE}:FW[${FW_PRE}] PostToolUse=1:${FW_POST}:FW[${FW_POST}] keys=PreToolUse,PostToolUse"
if [[ "$(_hooks_summary)" == "$WANT" ]]; then
  _pass "hook: launcher present → new file gets one framework PreToolUse and one PostToolUse entry"
else
  _fail "hook: launcher present → new file gets one framework PreToolUse and one PostToolUse entry (got: $(_hooks_summary))"
fi

# An existing file without any hooks (the empty-settings case) gets both.
echo '{}' > "$SETTINGS"
merge_claude_settings
if [[ "$(_hooks_summary)" == "$WANT" ]]; then
  _pass "hook: launcher present → empty settings file gets both framework entries"
else
  _fail "hook: launcher present → empty settings file gets both framework entries (got: $(_hooks_summary))"
fi

cp "$SETTINGS" "${TARGET_DIR}/settings.first"
merge_claude_settings
if cmp -s "$SETTINGS" "${TARGET_DIR}/settings.first"; then
  _pass "hook: second run is byte-identical"
else
  _fail "hook: second run is byte-identical"
fi

# Upgrade: an older install has only the single PostToolUse framework entry
# with matcher Write|Edit|MultiEdit, between consumer entries.
node -e '
  const fs = require("fs");
  const p = process.argv[1];
  const j = JSON.parse(fs.readFileSync(p, "utf8"));
  j.hooks = {
    PostToolUse: [
      { matcher: "Read", hooks: [{ type: "command", command: "echo consumer-before" }] },
      { matcher: "Write|Edit|MultiEdit", hooks: [{ type: "command", command: process.argv[2] }] },
      { matcher: "Glob", hooks: [{ type: "command", command: "echo consumer-after" }] },
    ],
  };
  fs.writeFileSync(p, JSON.stringify(j, null, 2) + "\n");
' "$SETTINGS" "$FW_COMMAND"
merge_claude_settings
if [[ "$(_hooks_summary)" == "PreToolUse=1:${FW_PRE}:FW[${FW_PRE}] PostToolUse=1:${FW_POST}:Read;FW[${FW_POST}];Glob keys=PostToolUse,PreToolUse" ]]; then
  _pass "hook: old single Write|Edit|MultiEdit entry upgraded in place, one PreToolUse entry added, no duplicates"
else
  _fail "hook: old single Write|Edit|MultiEdit entry upgraded in place, one PreToolUse entry added, no duplicates (got: $(_hooks_summary))"
fi
cp "$SETTINGS" "${TARGET_DIR}/settings.upgraded"
merge_claude_settings
if cmp -s "$SETTINGS" "${TARGET_DIR}/settings.upgraded"; then
  _pass "hook: re-run after the upgrade is byte-identical"
else
  _fail "hook: re-run after the upgrade is byte-identical"
fi

# Consumer hooks around stale framework entries (old matchers) in both events,
# including a consumer PreToolUse Bash hook.
node -e '
  const fs = require("fs");
  const p = process.argv[1];
  const j = JSON.parse(fs.readFileSync(p, "utf8"));
  j.hooks = {
    PreToolUse: [
      { matcher: "Bash", hooks: [{ type: "command", command: "echo pre" }] },
      { matcher: "Bash|Write", hooks: [{ type: "command", command: "node .claude/hooks/eversis-validate-spec.cjs" }] },
      { matcher: "Read", hooks: [{ type: "command", command: "echo pre-last" }] },
    ],
    PostToolUse: [
      { matcher: "Bash", hooks: [{ type: "command", command: "echo consumer-first" }] },
      { matcher: "Write", hooks: [{ type: "command", command: "node .claude/hooks/eversis-validate-spec.cjs" }] },
      { matcher: "Read", hooks: [{ type: "command", command: "echo consumer-last" }] },
    ],
  };
  fs.writeFileSync(p, JSON.stringify(j, null, 2) + "\n");
' "$SETTINGS"
merge_claude_settings
if [[ "$(_hooks_summary)" == "PreToolUse=1:${FW_PRE}:Bash;FW[${FW_PRE}];Read PostToolUse=1:${FW_POST}:Bash;FW[${FW_POST}];Read keys=PreToolUse,PostToolUse" ]]; then
  _pass "hook: stale framework entries replaced in place, consumer PreToolUse and PostToolUse kept in order"
else
  _fail "hook: stale framework entries replaced in place, consumer PreToolUse and PostToolUse kept in order (got: $(_hooks_summary))"
fi
grep -qF 'echo consumer-first' "$SETTINGS" && grep -qF 'echo consumer-last' "$SETTINGS" \
  && grep -qF 'echo pre' "$SETTINGS" && grep -qF 'echo pre-last' "$SETTINGS" \
  && _pass "hook: consumer hook commands unchanged" \
  || _fail "hook: consumer hook commands unchanged"

# A consumer PreToolUse Bash hook with no framework entry yet: the framework
# entry is appended after it.
node -e '
  const fs = require("fs");
  const p = process.argv[1];
  const j = JSON.parse(fs.readFileSync(p, "utf8"));
  j.hooks = {
    PreToolUse: [{ matcher: "Bash", hooks: [{ type: "command", command: "echo pre-only" }] }],
    PostToolUse: [{ matcher: "Edit", hooks: [{ type: "command", command: "echo post-only" }] }],
  };
  fs.writeFileSync(p, JSON.stringify(j, null, 2) + "\n");
' "$SETTINGS"
merge_claude_settings
if [[ "$(_hooks_summary)" == "PreToolUse=1:${FW_PRE}:Bash;FW[${FW_PRE}] PostToolUse=1:${FW_POST}:Edit;FW[${FW_POST}] keys=PreToolUse,PostToolUse" ]]; then
  _pass "hook: consumer PreToolUse Bash and PostToolUse hooks kept first, framework entries appended"
else
  _fail "hook: consumer PreToolUse Bash and PostToolUse hooks kept first, framework entries appended (got: $(_hooks_summary))"
fi

# Back to the mixed file for the removal cases.
node -e '
  const fs = require("fs");
  const p = process.argv[1];
  const j = JSON.parse(fs.readFileSync(p, "utf8"));
  j.hooks = {
    PreToolUse: [
      { matcher: "Bash", hooks: [{ type: "command", command: "echo pre" }] },
      { matcher: "Bash", hooks: [{ type: "command", command: process.argv[2] }] },
    ],
    PostToolUse: [
      { matcher: "Bash", hooks: [{ type: "command", command: "echo consumer-first" }] },
      { matcher: "Write|Edit|MultiEdit|Bash", hooks: [{ type: "command", command: process.argv[2] }] },
      { matcher: "Read", hooks: [{ type: "command", command: "echo consumer-last" }] },
    ],
  };
  fs.writeFileSync(p, JSON.stringify(j, null, 2) + "\n");
' "$SETTINGS" "$FW_COMMAND"

# Launcher absent → both framework entries removed, consumer hooks stay.
rm -f "$LAUNCHER"
merge_claude_settings
KEPT="PreToolUse=0::Bash PostToolUse=0::Bash;Read keys=PreToolUse,PostToolUse"
if [[ "$(_hooks_summary)" == "$KEPT" ]]; then
  _pass "hook: launcher absent → both framework entries removed, consumer hooks kept"
else
  _fail "hook: launcher absent → both framework entries removed, consumer hooks kept (got: $(_hooks_summary))"
fi
merge_claude_settings
if [[ "$(_hooks_summary)" == "$KEPT" ]]; then
  _pass "hook: launcher absent → no framework entry added"
else
  _fail "hook: launcher absent → no framework entry added (got: $(_hooks_summary))"
fi

# Launcher absent, framework PreToolUse alone in its array next to a consumer
# PostToolUse → the emptied PreToolUse key is dropped, hooks stays.
node -e '
  const fs = require("fs");
  const p = process.argv[1];
  const j = JSON.parse(fs.readFileSync(p, "utf8"));
  j.hooks = {
    PreToolUse: [{ matcher: "Bash", hooks: [{ type: "command", command: process.argv[2] }] }],
    PostToolUse: [
      { matcher: "Write|Edit|MultiEdit|Bash", hooks: [{ type: "command", command: process.argv[2] }] },
      { matcher: "Read", hooks: [{ type: "command", command: "echo consumer-last" }] },
    ],
  };
  fs.writeFileSync(p, JSON.stringify(j, null, 2) + "\n");
' "$SETTINGS" "$FW_COMMAND"
merge_claude_settings
if [[ "$(_hooks_summary)" == "PreToolUse=0:: PostToolUse=0::Read keys=PostToolUse" ]]; then
  _pass "hook: removal that empties PreToolUse drops that key, consumer PostToolUse kept"
else
  _fail "hook: removal that empties PreToolUse drops that key, consumer PostToolUse kept (got: $(_hooks_summary))"
fi

# Launcher absent and only the framework entries → emptied hooks key dropped.
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
  _pass "hook: removal that empties PreToolUse and PostToolUse drops the hooks key"
else
  _fail "hook: removal that empties PreToolUse and PostToolUse drops the hooks key"
fi

# Non-array event values and "hooks": [] are refused, like a non-object
# "permissions"; the file is left untouched.
echo '// launcher stub' > "$LAUNCHER"
_refused() {
  # $1 = JSON value for hooks, $2 = expected message fragment, $3 = test name
  node -e '
    const fs = require("fs");
    const p = process.argv[1];
    const j = JSON.parse(fs.readFileSync(p, "utf8"));
    j.hooks = JSON.parse(process.argv[2]);
    fs.writeFileSync(p, JSON.stringify(j, null, 2) + "\n");
  ' "$SETTINGS" "$1"
  cp "$SETTINGS" "${TARGET_DIR}/settings.refused"
  local err="${TARGET_DIR}/hook-refused.err"
  if ( merge_claude_settings ) >/dev/null 2>"$err"; then
    _fail "$3"
  elif grep -qF "$2" "$err" && cmp -s "$SETTINGS" "${TARGET_DIR}/settings.refused"; then
    _pass "$3"
  else
    _fail "$3 ($(cat "$err"))"
  fi
}
_refused '[]' '"hooks" is not an object' \
  "hook: \"hooks\": [] is refused with a clear message, file untouched"
_refused '{"PreToolUse": {}}' '"hooks.PreToolUse" is not an array' \
  "hook: \"PreToolUse\": {} is refused with a clear message, file untouched"
_refused '{"PostToolUse": {}}' '"hooks.PostToolUse" is not an array' \
  "hook: \"PostToolUse\": {} is refused with a clear message, file untouched"
_refused '{"PreToolUse": [], "PostToolUse": "x"}' '"hooks.PostToolUse" is not an array' \
  "hook: non-array PostToolUse next to a valid PreToolUse is refused, file untouched"

# CS_MODE=remove-hook (Claude deselected): only the framework entries go.
cat > "$SETTINGS" <<'JSON'
{
  "permissions": { "allow": ["Read", "Bash(make *)"], "deny": ["Read(./secret/**)"], "ask": ["Bash(git push*)"] },
  "enabledMcpjsonServers": ["eversis-collections", "my-private-server"],
  "hooks": {
    "PreToolUse": [
      { "matcher": "Bash", "hooks": [ { "type": "command", "command": "echo consumer-pre" } ] },
      { "matcher": "Bash", "hooks": [ { "type": "command", "command": "node \"${CLAUDE_PROJECT_DIR}/.claude/hooks/eversis-validate-spec.cjs\"" } ] }
    ],
    "PostToolUse": [
      { "matcher": "Write|Edit|MultiEdit|Bash", "hooks": [ { "type": "command", "command": "node \"${CLAUDE_PROJECT_DIR}/.claude/hooks/eversis-validate-spec.cjs\"" } ] },
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
if [[ "$(_hooks_summary)" == "PreToolUse=0::Bash PostToolUse=0::Bash keys=PreToolUse,PostToolUse" ]] && [[ "$(_keys_json)" == "$KEYS_BEFORE" ]]; then
  _pass "remove-hook: both framework entries removed, consumer hooks kept; permissions and enabledMcpjsonServers identical"
else
  _fail "remove-hook: both framework entries removed, consumer hooks kept; permissions and enabledMcpjsonServers identical (got: $(_hooks_summary); $(_keys_json))"
fi
cp "$SETTINGS" "${TARGET_DIR}/settings.removed"
remove_claude_framework_hook >/dev/null
if cmp -s "$SETTINGS" "${TARGET_DIR}/settings.removed"; then
  _pass "remove-hook: no framework entry → file not rewritten"
else
  _fail "remove-hook: no framework entry → file not rewritten"
fi

# remove-hook on a file whose hooks are only the framework entries → the
# emptied event arrays and the hooks key are dropped.
cat > "$SETTINGS" <<'JSON'
{
  "model": "opus",
  "hooks": {
    "PreToolUse": [
      { "matcher": "Bash", "hooks": [ { "type": "command", "command": "node \"${CLAUDE_PROJECT_DIR}/.claude/hooks/eversis-validate-spec.cjs\"" } ] }
    ],
    "PostToolUse": [
      { "matcher": "Write|Edit|MultiEdit|Bash", "hooks": [ { "type": "command", "command": "node \"${CLAUDE_PROJECT_DIR}/.claude/hooks/eversis-validate-spec.cjs\"" } ] }
    ]
  }
}
JSON
remove_claude_framework_hook >/dev/null
if [[ "$(node -e 'console.log(JSON.stringify(JSON.parse(require("fs").readFileSync(process.argv[1],"utf8"))))' "$SETTINGS")" == '{"model":"opus"}' ]]; then
  _pass "remove-hook: emptied PreToolUse, PostToolUse and hooks keys dropped"
else
  _fail "remove-hook: emptied PreToolUse, PostToolUse and hooks keys dropped (got: $(cat "$SETTINGS"))"
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
