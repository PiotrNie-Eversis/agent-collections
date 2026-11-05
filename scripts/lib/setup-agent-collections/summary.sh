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
  local pi_selected=false pi_failed=false
  echo ",${agents_csv}," | grep -q ',pi,' && pi_selected=true
  [[ "${PI_STAGE_FAILED:-false}" == "true" ]] && pi_failed=true
  if [[ "$pi_failed" == "true" ]]; then
    echo "${_BOLD}${_YELLOW}agent-collections setup completed with failures (pi)${_RESET}"
  else
    echo "${_BOLD}${_GREEN}agent-collections setup complete${_RESET}"
  fi
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
  if [[ "$pi_failed" == "true" ]]; then
    echo "  ${_RED}Pi:${_RESET}            FAILED — ${PI_STAGE_FAILURE_REASON:-see the pi error above}"
    echo "                 Other agents were installed; pi is not in the recorded selection."
    echo "                 Fix the cause, then re-run with the same --agents (the run exits 1)."
    echo ""
  elif [[ "$pi_selected" == "true" ]] && ! command -v pi >/dev/null 2>&1; then
    echo "  ${_YELLOW}Pi:${_RESET}            'pi' CLI not found on PATH — .pi/ was generated; install the Pi"
    echo "                 coding agent (npm i -g @earendil-works/pi-coding-agent) to use it."
    echo ""
  fi

  echo "${_BOLD}Next steps:${_RESET}"
  echo ""

  if echo ",${agents_csv}," | grep -q ',cursor,'; then
    echo "  ${step}. Customise .cursor/rules/eversis-project-stack.mdc (Cursor stack / skills policy)"
    step=$((step + 1))
  fi

  if echo ",${agents_csv}," | grep -q ',claude,'; then
    echo "  ${step}. Customise .claude/CLAUDE.md (Claude stack / skills policy)"
    echo "     Do not hand-edit generated CLAUDE.md; it is overwritten on adapter sync."
    step=$((step + 1))
  fi

  if [[ "$pi_selected" == "true" ]] && [[ "$pi_failed" != "true" ]]; then
    echo "  ${step}. Start pi in the project root and grant project trust (Pi loads .pi/ only for trusted projects)"
    echo "     Run /reload in an open Pi session after every re-sync."
    step=$((step + 1))
    echo "  ${step}. Customise .cursor/rules/eversis-project-stack.mdc — once it differs from the template, the"
    echo "     next sync appends it to .pi/APPEND_SYSTEM.md (Pi stack / skills policy)"
    step=$((step + 1))
    echo "  ${step}. Keep a root AGENTS.md so Pi does not also load CLAUDE.md as its context file"
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

  # AGENTS.md is the shared orientation map (both Cursor and Claude read it —
  # Claude only via the @../AGENTS.md import seeded into .claude/CLAUDE.md),
  # so this reminder always applies, not just when Claude is deselected.
  echo "  ${step}. Review AGENTS.md — shared orientation map (never auto-overwritten on re-run)"
  step=$((step + 1))

  if [[ -n "${MCP_USER_OVERLAP_IDS:-}" ]]; then
    echo "  ${step}. Cursor User MCP overlaps catalog ids (${MCP_USER_OVERLAP_IDS}) — remove those ids from ~/.cursor/mcp.json (Settings badge User). Installer did not edit the User file."
    step=$((step + 1))
  fi

  echo ""
  echo "Deselection: re-run with an explicit, smaller --mcp-servers / --agents list to refresh"
  echo "managed entries. --upgrade / --sync without those flags keeps what is installed (existing"
  echo "MCP entries stay unchanged; agents with generated files stay selected). With an explicit"
  echo "--mcp-servers, unlisted catalog servers are pruned; adapter sync removes orphan generated"
  echo "slash commands and scoped rules. When Claude is explicitly omitted, framework-generated"
  echo "CLAUDE.md, .claudeignore, .claude/commands/, .claude/rules/, and .claude/skills/ are"
  echo "removed if present. When Pi is explicitly omitted, framework-generated .pi/APPEND_SYSTEM.md,"
  echo ".pi/prompts/eversis-*.md, .pi/skills/eversis-* (framework skills and eversis-rule-* role"
  echo "skills), .pi/extensions/eversis-context-budget.ts, .pi/extensions/eversis-process-rules.ts"
  echo "and .pi/eversis-state/ are removed; .pi/settings.json and .pi/mcp.json stay. See README"
  echo "upgrade / recovery notes."
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
}
