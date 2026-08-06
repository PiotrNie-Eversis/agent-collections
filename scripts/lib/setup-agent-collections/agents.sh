#!/usr/bin/env bash
# lib/setup-agent-collections/agents.sh — agents axis (Cursor / Claude / OpenCode).

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
