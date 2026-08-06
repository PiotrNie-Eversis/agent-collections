#!/usr/bin/env bash
# lib/setup-agent-collections/summary.sh

print_summary() {
  local mode="local"
  [[ -n "${VENDOR_MODE:-}" ]] && mode="vendor (${VENDOR_MODE})"

  local effective_link="${EFFECTIVE_LINK_MODE:-${ARG_LINK_MODE:-auto}}"
  local mcp_file="${TARGET_DIR}/.cursor/mcp.json"
  local configured="${MCP_CONFIGURED_SERVERS:-eversis-collections}"

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "${_BOLD}${_GREEN}agent-collections setup complete${_RESET}"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "  Mode:          ${mode}"
  echo "  Link mode:     ${effective_link}"
  echo "  Agents:        ${SELECTED_AGENTS:-cursor}"
  echo "  Profile:       ${DOMAIN_PROFILE:-fullstack}"
  echo "  Area scope:    ${AREA_PROFILE_ID:-n/a}"
  echo "  MCP servers:   ${configured}"
  echo "  Framework:     ${COLLECTIONS_HOME}"
  echo "  Target:        ${TARGET_DIR}"
  echo "  Selection:     ${TARGET_DIR}/.agent-collections/install-selection.json"
  echo ""
  if echo ",${SELECTED_AGENTS:-}," | grep -q ',opencode,'; then
    echo "  ${_YELLOW}OpenCode:${_RESET} placeholder-only — not a full adapter."
    echo ""
  fi
  echo "${_BOLD}Next steps:${_RESET}"
  echo ""
  echo "  1. Customise .cursor/rules/eversis-project-stack.mdc"
  echo "  2. Export AGENT_COLLECTIONS_HOME=\"${COLLECTIONS_HOME}\" (local mode)"
  echo "  3. Enable MCP in Cursor / restart; skills load from .ai/skills via eversis-collections"
  echo "  4. Review AGENTS.md (never auto-overwritten)"
  echo ""
  echo "Deselection: re-run with a smaller --mcp-servers / --agents list to refresh managed"
  echo "entries, or manually edit .cursor/mcp.json. See README recovery notes."
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
}
