#!/usr/bin/env bash
# lib/setup-agent-collections/mcp-prompt.sh — resolve MCP server selection (interactive or flags).
# Sourced after common.sh; requires LIB_DIR, TARGET_DIR, COLLECTIONS_HOME.

readonly MCP_SERVER_LIST="${LIB_DIR}/mcp-server-list.json"
readonly MCP_PROMPT_MJS="${LIB_DIR}/mcp-prompt.mjs"
readonly MCP_PROMPT_TOGGLE_MJS="${LIB_DIR}/mcp-prompt-toggle.mjs"

_is_interactive_terminal() {
  [[ -t 1 ]]
}

_validate_mcp_server_ids() {
  local csv="$1"
  local id
  IFS=',' read -ra _mcp_ids <<< "$csv"
  for id in "${_mcp_ids[@]}"; do
    id="${id// /}"
    [[ -z "$id" ]] && continue
    if ! node -e "
      const fs = require('fs');
      const list = JSON.parse(fs.readFileSync(process.argv[1], 'utf8'));
      if (!list.servers.includes(process.argv[2])) process.exit(1);
    " "$MCP_SERVER_LIST" "$id" 2>/dev/null; then
      die "Unknown MCP server id: '${id}'. Allowed ids are listed in ${MCP_SERVER_LIST}"
    fi
  done
}

_run_mcp_toggle_prompt() {
  # stdout = CSV only; UI is written to stderr by mcp-prompt-toggle.mjs
  local selected_csv="" exit_code=0

  selected_csv="$(node "$MCP_PROMPT_TOGGLE_MJS" "$MCP_SERVER_LIST")" || exit_code=$?
  if [[ "$exit_code" -eq 130 ]]; then
    die "Setup cancelled."
  fi
  if [[ "$exit_code" -ne 0 ]] || [[ -z "$selected_csv" ]]; then
    die "MCP server selection failed."
  fi

  MCP_SELECTED_IDS="${selected_csv//$'\n'/}"
  _validate_mcp_server_ids "$MCP_SELECTED_IDS"
  export MCP_SELECTED_IDS MCP_CONFIGURED_SERVERS="$MCP_SELECTED_IDS"
}

_ensure_mcp_prompt_deps() {
  local deps_marker="${LIB_DIR}/node_modules/@inquirer/prompts/package.json"
  [[ -f "$deps_marker" ]] && return 0
  require_cmd npm "Install Node.js/npm from https://nodejs.org"
  log_info "Installing MCP prompt UI dependencies (one-time) …"
  (cd "$LIB_DIR" && npm install --omit=dev --no-audit --no-fund --silent) \
    || return 1
  return 0
}

_run_checkbox_mcp_prompt() {
  local selected_csv="" exit_code=0

  selected_csv="$(node "$MCP_PROMPT_MJS" "$MCP_SERVER_LIST")" || exit_code=$?
  if [[ "$exit_code" -eq 130 ]]; then
    die "Setup cancelled."
  fi
  if [[ "$exit_code" -ne 0 ]] || [[ -z "$selected_csv" ]]; then
    return 1
  fi

  MCP_SELECTED_IDS="${selected_csv//$'\n'/}"
  _validate_mcp_server_ids "$MCP_SELECTED_IDS"
  export MCP_SELECTED_IDS MCP_CONFIGURED_SERVERS="$MCP_SELECTED_IDS"
  return 0
}

_run_interactive_mcp_prompt() {
  require_cmd node "Install Node.js ≥ 18 from https://nodejs.org"

  if [[ "${MCP_PROMPT_UI:-checkbox}" != "toggle" ]]; then
    if _ensure_mcp_prompt_deps && _run_checkbox_mcp_prompt; then
      return 0
    fi
    log_info "Checkbox UI unavailable — using number toggle list (type numbers like 1,3,11)."
  fi

  _run_mcp_toggle_prompt
}

_resolve_mcp_selection() {
  local mcp_file="${TARGET_DIR}/.cursor/mcp.json"
  local default_minimal="eversis-collections"

  if [[ -n "${MCP_SELECTED_IDS:-}" ]]; then
    _validate_mcp_server_ids "$MCP_SELECTED_IDS"
    export MCP_CONFIGURED_SERVERS="$MCP_SELECTED_IDS"
    return 0
  fi

  if [[ -n "${ARG_MCP_SERVERS:-}" ]]; then
    MCP_SELECTED_IDS="${ARG_MCP_SERVERS// /}"
    _validate_mcp_server_ids "$MCP_SELECTED_IDS"
    export MCP_SELECTED_IDS MCP_CONFIGURED_SERVERS="$MCP_SELECTED_IDS"
    return 0
  fi

  if [[ "${ARG_NON_INTERACTIVE:-false}" == "true" ]]; then
    MCP_SELECTED_IDS="$default_minimal"
    export MCP_SELECTED_IDS MCP_CONFIGURED_SERVERS="$MCP_SELECTED_IDS"
    return 0
  fi

  if [[ "${ARG_BUILD_MCP:-false}" == "true" ]] && _is_interactive_terminal; then
    _run_interactive_mcp_prompt
    return 0
  fi

  if [[ -f "$mcp_file" ]]; then
    MCP_SELECTED_IDS="$default_minimal"
    export MCP_SELECTED_IDS MCP_CONFIGURED_SERVERS="$MCP_SELECTED_IDS"
    return 0
  fi

  if [[ "${ARG_BUILD_MCP:-false}" != "true" ]]; then
    MCP_SELECTED_IDS="$default_minimal"
    export MCP_SELECTED_IDS MCP_CONFIGURED_SERVERS="$MCP_SELECTED_IDS"
    return 0
  fi

  log_warn "Non-interactive terminal — configuring only ${default_minimal} in mcp.json."
  log_info "Run from an interactive terminal, or pass --mcp-servers=id1,id2 for non-interactive selection."
  MCP_SELECTED_IDS="$default_minimal"
  export MCP_SELECTED_IDS MCP_CONFIGURED_SERVERS="$MCP_SELECTED_IDS"
}
