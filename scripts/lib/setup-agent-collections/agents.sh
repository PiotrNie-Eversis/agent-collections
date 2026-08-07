#!/usr/bin/env bash
# lib/setup-agent-collections/agents.sh — agents axis (Cursor / Claude / OpenCode).

readonly AGENTS_PROMPT_MJS="${LIB_DIR}/agents-prompt.mjs"

_is_interactive_agents_terminal() {
  [[ -t 1 ]]
}

_run_checkbox_agents_prompt() {
  local selected_csv="" exit_code=0

  selected_csv="$(node "$AGENTS_PROMPT_MJS")" || exit_code=$?
  if [[ "$exit_code" -eq 130 ]]; then
    die "Setup cancelled."
  fi
  if [[ "$exit_code" -ne 0 ]] || [[ -z "$selected_csv" ]]; then
    return 1
  fi

  SELECTED_AGENTS="${selected_csv//$'\n'/}"
  _validate_agents "$SELECTED_AGENTS"
  export SELECTED_AGENTS
  return 0
}

_run_numbered_agents_prompt() {
  echo ""
  echo "${_BOLD}Select agent adapters:${_RESET}"
  echo "  1) Cursor only"
  echo "  2) Claude Code only"
  echo "  3) Cursor + Claude"
  echo "  4) OpenCode placeholder only (warning: not a full adapter)"
  echo "  5) Multi-agent (Cursor + Claude + OpenCode placeholder)"
  echo ""
  local choice=""
  read -r -p "Enter choice [1]: " choice
  case "${choice:-1}" in
    2) SELECTED_AGENTS="claude" ;;
    3) SELECTED_AGENTS="cursor,claude" ;;
    4)
      SELECTED_AGENTS="opencode"
      log_warn "OpenCode is placeholder-only (maturity=placeholder). Not a shipped full adapter."
      ;;
    5)
      SELECTED_AGENTS="cursor,claude,opencode"
      log_warn "OpenCode included as placeholder-only."
      ;;
    *) SELECTED_AGENTS="cursor" ;;
  esac
  export SELECTED_AGENTS
}

_run_interactive_agents_prompt() {
  require_cmd node "Install Node.js ≥ 18 from https://nodejs.org"

  if _ensure_inquirer_prompt_deps && _run_checkbox_agents_prompt; then
    return 0
  fi

  log_info "Checkbox UI unavailable — using numbered menu."
  _run_numbered_agents_prompt
}

resolve_agents_selection() {
  # Sets SELECTED_AGENTS CSV: cursor,claude,opencode
  if [[ -n "${SELECTED_AGENTS:-}" ]]; then
    _validate_agents "$SELECTED_AGENTS"
    export SELECTED_AGENTS
    return 0
  fi

  if [[ -n "${ARG_AGENTS:-}" ]]; then
    SELECTED_AGENTS="${ARG_AGENTS// /}"
    _validate_agents "$SELECTED_AGENTS"
    export SELECTED_AGENTS
    return 0
  fi

  if [[ "${ARG_NON_INTERACTIVE:-false}" == "true" ]]; then
    SELECTED_AGENTS="cursor"
    export SELECTED_AGENTS
    log_info "Non-interactive default agents: cursor"
    return 0
  fi

  if _is_interactive_agents_terminal; then
    _run_interactive_agents_prompt
  else
    SELECTED_AGENTS="cursor"
    export SELECTED_AGENTS
    log_warn "Non-interactive terminal — defaulting agents to cursor."
    log_info "Pass --agents=cursor,claude for non-interactive multi-agent selection."
  fi
}

_validate_agents() {
  local csv="$1"
  local id
  IFS=',' read -ra _ids <<< "$csv"
  for id in "${_ids[@]}"; do
    id="${id// /}"
    [[ -z "$id" ]] && continue
    case "$id" in
      cursor|claude|opencode) : ;;
      *) die "Unknown agent id '${id}'. Allowed: cursor, claude, opencode" ;;
    esac
  done
  if echo ",${csv}," | grep -q ',opencode,'; then
    log_warn "OpenCode adapter is placeholder-only — see docs/architecture/adapter-mapping.md §6.3"
  fi
}
