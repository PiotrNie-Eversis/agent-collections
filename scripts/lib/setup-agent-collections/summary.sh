#!/usr/bin/env bash
# lib/setup-agent-collections/summary.sh

print_summary() {
  local mode="local"
  [[ -n "${VENDOR_MODE:-}" ]] && mode="vendor (${VENDOR_MODE})"

  local effective_link="${EFFECTIVE_LINK_MODE:-${ARG_LINK_MODE:-auto}}"
  local configured="${MCP_CONFIGURED_SERVERS:-eversis-collections}"
  local agents_csv="${SELECTED_AGENTS:-cursor}"
  local step=1
  local is_local=true
  if [[ -n "${VENDOR_MODE:-}" ]] && [[ "${VENDOR_MODE}" != "local" ]]; then
    is_local=false
  fi

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "${_BOLD}${_GREEN}agent-collections setup complete${_RESET}"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "  Mode:          ${mode}"
  echo "  Link mode:     ${effective_link}"
  echo "  Agents:        ${agents_csv}"
  echo "  Profile:       ${DOMAIN_PROFILE:-fullstack}"
  echo "  Area scope:    ${AREA_PROFILE_ID:-n/a}"
  echo "  MCP servers:   ${configured}"
  echo "  Framework:     ${COLLECTIONS_HOME}"
  echo "  Target:        ${TARGET_DIR}"
  echo "  Selection:     ${TARGET_DIR}/.agent-collections/install-selection.json"
  echo ""
  if echo ",${agents_csv}," | grep -q ',opencode,'; then
    echo "  ${_YELLOW}OpenCode:${_RESET} placeholder-only — not a full adapter."
    echo ""
  fi

  echo "${_BOLD}Next steps:${_RESET}"
  echo ""

  if echo ",${agents_csv}," | grep -q ',cursor,'; then
    echo "  ${step}. Customise .cursor/rules/eversis-project-stack.mdc (Cursor stack / skills policy)"
    step=$((step + 1))
  fi

  if echo ",${agents_csv}," | grep -q ',claude,'; then
    echo "  ${step}. Customise AGENTS.md (stack / areas / skills policy — Claude + shared map)"
    echo "     Do not hand-edit generated CLAUDE.md; it is overwritten on adapter sync."
    step=$((step + 1))
  fi

  if [[ "$is_local" == "true" ]]; then
    echo "  ${step}. Export AGENT_COLLECTIONS_HOME=\"${COLLECTIONS_HOME}\" (required in local mode)"
    step=$((step + 1))
    echo "  ${step}. Enable MCP eversis-collections / restart the IDE"
    echo "     Skills resolve from \$AGENT_COLLECTIONS_HOME/.ai/skills (not an in-repo .ai/ tree)"
    step=$((step + 1))
  else
    echo "  ${step}. (Done) Framework is at vendor/agent-collections (mode: ${VENDOR_MODE}) — no further install action"
    step=$((step + 1))
    if [[ "${VENDOR_MODE}" == "submodule" ]]; then
      echo "  ${step}. Teammates after clone: git submodule update --init --recursive"
      step=$((step + 1))
    fi
    echo "  ${step}. Enable MCP eversis-collections / restart the IDE"
    echo "     Skills resolve from vendor/agent-collections/.ai/skills (or \$AGENT_COLLECTIONS_HOME if set)"
    step=$((step + 1))
  fi

  # Always remind AGENTS exists when cursor-only (Claude step already covers customise)
  if ! echo ",${agents_csv}," | grep -q ',claude,'; then
    echo "  ${step}. Review AGENTS.md (never auto-overwritten on re-run)"
    step=$((step + 1))
  fi

  echo ""
  echo "Deselection: re-run with a smaller --mcp-servers / --agents list to refresh managed"
  echo "entries. MCP catalog servers are pruned automatically; adapter sync removes orphan"
  echo "generated slash commands. When Claude is omitted, framework-generated CLAUDE.md and"
  echo ".claudeignore are removed if present. See README upgrade / recovery notes."
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
}
