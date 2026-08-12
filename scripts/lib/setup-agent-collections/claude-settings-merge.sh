#!/usr/bin/env bash
# lib/setup-agent-collections/claude-settings-merge.sh

merge_claude_settings() {
  if ! echo ",${SELECTED_AGENTS:-}," | grep -q ',claude,'; then
    return 0
  fi
  require_cmd node "Install Node.js ≥ 18 from https://nodejs.org"

  local settings_file="${TARGET_DIR}/.claude/settings.json"
  local template_path="${COLLECTIONS_HOME}/templates/claude-settings.json"
  local merge_mjs="${LIB_DIR}/claude-settings-merge.mjs"

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
    node "$merge_mjs"
  )" || die "Failed to build/merge ${settings_file}."

  echo "$merged" | node -e "JSON.parse(require('fs').readFileSync(0,'utf8'))" \
    || die "Merged ${settings_file} is not valid JSON — aborting."

  echo "$merged" > "$settings_file"
  log_ok "Wrote ${settings_file} (permissions.deny + enabledMcpjsonServers refreshed)."
}
