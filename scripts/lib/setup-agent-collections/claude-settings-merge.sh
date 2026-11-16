#!/usr/bin/env bash
# lib/setup-agent-collections/claude-settings-merge.sh

merge_claude_settings() {
  if ! echo ",${SELECTED_AGENTS:-}," | grep -q ',claude,'; then
    return 0
  fi
  require_cmd node "Install Node.js 22 or newer from https://nodejs.org"

  local settings_file="${TARGET_DIR}/.claude/settings.json"
  local template_path="${COLLECTIONS_HOME}/templates/claude-settings.json"
  local merge_mjs="${LIB_DIR}/claude-settings-merge.mjs"
  # Written by the adapter sync (link_framework_files) earlier in the run;
  # the merge adds the framework PreToolUse (Bash) and PostToolUse
  # (Write|Edit|MultiEdit|Bash) entries only when it exists.
  local hook_launcher="${TARGET_DIR}/.claude/hooks/eversis-validate-spec.cjs"

  # Prefer this consumer's own merged .claudeignore (written earlier in the
  # same run by merge_ignore_triad); fall back to the framework's copy for
  # self-host or edge cases where the target one is missing.
  local claudeignore_path="${TARGET_DIR}/.claudeignore"
  if [[ ! -f "$claudeignore_path" ]]; then
    claudeignore_path="${COLLECTIONS_HOME}/.claudeignore"
  fi

  [[ -f "$template_path" ]] || die "Framework Claude settings template not found (templates/claude-settings.json)."
  [[ -f "$merge_mjs" ]]     || die "Claude settings merge script not found: ${merge_mjs}"

  mkdir -p "$(dirname "$settings_file")"

  local existing_json=""
  if [[ -f "$settings_file" ]]; then
    existing_json="$(cat "$settings_file")"
  fi

  local merged
  merged="$(
    CS_EXISTING_JSON="$existing_json" \
    CS_TEMPLATE_PATH="$template_path" \
    CS_CLAUDEIGNORE_PATH="$claudeignore_path" \
    CS_MCP_SERVER_IDS="${MCP_CONFIGURED_SERVERS:-eversis-collections}" \
    CS_PRESERVE_EXISTING="${MCP_PRESERVE_EXISTING:-false}" \
    CS_MCP_JSON_PATH="${TARGET_DIR}/.mcp.json" \
    CS_SERVER_LIST_PATH="${LIB_DIR}/mcp-server-list.json" \
    CS_HOOK_LAUNCHER_PATH="$hook_launcher" \
    node "$merge_mjs"
  )" || die "Failed to build/merge ${settings_file}."

  echo "$merged" | node -e "JSON.parse(require('fs').readFileSync(0,'utf8'))" \
    || die "Merged ${settings_file} is not valid JSON — aborting."

  echo "$merged" > "$settings_file"
  if [[ -f "$hook_launcher" ]]; then
    log_ok "Wrote ${settings_file} (permissions.deny + enabledMcpjsonServers + spec artifact hook entries PreToolUse + PostToolUse refreshed)."
  else
    log_ok "Wrote ${settings_file} (permissions.deny + enabledMcpjsonServers refreshed; no hook launcher in .claude/hooks/, framework hook entries not set)."
  fi
}

# Claude deselected: drop only the framework PreToolUse and PostToolUse
# entries (and a PreToolUse / PostToolUse / hooks key the removal empties)
# from .claude/settings.json.
# permissions, enabledMcpjsonServers and every consumer hook stay as they
# are. No-op when the file is absent; the file is rewritten only when an
# entry was there.
remove_claude_framework_hook() {
  local settings_file="${TARGET_DIR}/.claude/settings.json"
  [[ -f "$settings_file" ]] || return 0
  require_cmd node "Install Node.js 22 or newer from https://nodejs.org"
  local merge_mjs="${LIB_DIR}/claude-settings-merge.mjs"
  [[ -f "$merge_mjs" ]] || die "Claude settings merge script not found: ${merge_mjs}"

  local existing_json updated
  existing_json="$(cat "$settings_file")"
  updated="$(
    CS_MODE=remove-hook \
    CS_EXISTING_JSON="$existing_json" \
    node "$merge_mjs"
  )" || die "Failed to remove the framework hook entries from ${settings_file}."

  [[ -n "$updated" ]] || return 0
  local before after
  before="$(printf '%s' "$existing_json" | node -e "process.stdout.write(JSON.stringify(JSON.parse(require('fs').readFileSync(0,'utf8'))))")" \
    || die "${settings_file} is not valid JSON."
  after="$(printf '%s' "$updated" | node -e "process.stdout.write(JSON.stringify(JSON.parse(require('fs').readFileSync(0,'utf8'))))")" \
    || die "Updated ${settings_file} is not valid JSON — aborting."
  [[ "$before" == "$after" ]] && return 0

  echo "$updated" > "$settings_file"
  log_ok "Removed the framework spec artifact hook from ${settings_file} (Claude not in --agents)."
}
