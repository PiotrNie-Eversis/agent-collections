#!/usr/bin/env bash
# lib/setup-agent-collections/upgrade.sh — reuse selection; fail-safe on missing/corrupt.

load_selection_or_fail() {
  local sel_file="${TARGET_DIR}/.agent-collections/install-selection.json"
  if [[ ! -f "$sel_file" ]]; then
    die "Upgrade/sync requires ${sel_file}.
  File is missing. Run the interactive wizard (or non-interactive install) first:
    bash scripts/setup-agent-collections.sh --non-interactive \\
      --agents=cursor --mcp-servers=eversis-collections --profile=fullstack --build-mcp
  Do not invent a full multi-agent install without an explicit selection."
  fi

  require_cmd node "Install Node.js ≥ 18"
  local parsed
  if ! parsed="$(node -e "
    const fs = require('fs');
    const p = process.argv[1];
    let j;
    try { j = JSON.parse(fs.readFileSync(p, 'utf8')); }
    catch (e) { console.error('corrupt'); process.exit(2); }
    const required = ['frameworkVersion','agents','mcpServers','domainProfile','vendorMode','linkMode'];
    for (const k of required) {
      if (j[k] === undefined || j[k] === null) { console.error('missing:'+k); process.exit(3); }
    }
    if (!Array.isArray(j.agents) || !Array.isArray(j.mcpServers)) { console.error('bad arrays'); process.exit(3); }
    console.log(JSON.stringify(j));
  " "$sel_file")"; then
    die "Upgrade failed: install-selection.json is missing required fields or invalid JSON.
  Re-run the wizard to recreate selection:
    bash scripts/setup-agent-collections.sh --non-interactive --agents=cursor --mcp-servers=eversis-collections --profile=fullstack"
  fi

  SELECTED_AGENTS="$(node -e "const j=JSON.parse(process.argv[1]); console.log(j.agents.join(','))" "$parsed")"
  MCP_SELECTED_IDS="$(node -e "const j=JSON.parse(process.argv[1]); console.log(j.mcpServers.join(','))" "$parsed")"
  # Per-field contract (same as ssot.* below): an explicit flag replaces the
  # recorded value, an omitted flag keeps it. Flag values are space-stripped
  # so "--agents=cursor, claude" still matches the ',claude,' guards used by
  # link-framework.sh / mcp-merge.sh / claude-settings-merge.sh.
  if [[ -n "${ARG_AGENTS:-}" ]]; then
    SELECTED_AGENTS="${ARG_AGENTS// /}"
  else
    # A short record (older installer, a teammate's flag set, a manual edit)
    # must not make this run prune adapter surfaces the framework already
    # installed here. Only generator markers count as evidence — see
    # detect_installed_agents — so a hand-written CLAUDE.md never enables Claude.
    local detected="" added="" agent=""
    detected="$(detect_installed_agents)"
    for agent in ${detected//,/ }; do
      case ",${SELECTED_AGENTS}," in
        *,"$agent",*) ;;
        *)
          SELECTED_AGENTS="${SELECTED_AGENTS:+${SELECTED_AGENTS},}${agent}"
          added="${added:+${added},}${agent}"
          ;;
      esac
    done
    if [[ -n "$added" ]]; then
      log_info "Kept already-installed agent(s) not in install-selection.json: ${added} (generator markers found)."
    fi
  fi
  # MCP: an explicit --mcp-servers is the documented refresh / deselect path
  # (re-template selected ids, prune deselected catalog ids). Without it the
  # record is reused and mcp-merge.mjs / claude-settings-merge.mjs run in
  # preserve mode: entries already in each host file are kept as they are and
  # are NOT written back to the record (MCP_SELECTED_IDS stays the selection).
  if [[ -n "${ARG_MCP_SERVERS:-}" ]]; then
    MCP_SELECTED_IDS="${ARG_MCP_SERVERS// /}"
    MCP_PRESERVE_EXISTING="false"
  else
    MCP_PRESERVE_EXISTING="true"
  fi
  if [[ -n "${ARG_PROFILE:-}" ]]; then
    DOMAIN_PROFILE="${ARG_PROFILE// /}"
  else
    DOMAIN_PROFILE="$(node -e "const j=JSON.parse(process.argv[1]); console.log(j.domainProfile)" "$parsed")"
  fi
  # --vendor / --link-mode follow the same per-field contract. ARG_VENDOR
  # defaults to "" and ARG_LINK_MODE to "auto", so only the *_PASSED markers
  # tell an explicit flag from the default. An explicit --vendor (incl. bare
  # "true") is left for _resolve_vendor_mode (run_vendor_setup) to resolve.
  if [[ "${ARG_VENDOR_PASSED:-false}" == "true" ]]; then
    VENDOR_MODE="${ARG_VENDOR}"
  else
    VENDOR_MODE="$(node -e "const j=JSON.parse(process.argv[1]); console.log(j.vendorMode==='local'?'':j.vendorMode)" "$parsed")"
    ARG_VENDOR="${VENDOR_MODE}"
  fi
  if [[ "${ARG_LINK_MODE_PASSED:-false}" != "true" ]]; then
    ARG_LINK_MODE="$(node -e "const j=JSON.parse(process.argv[1]); console.log(j.linkMode||'auto')" "$parsed")"
  fi
  if [[ "${ARG_SSOT_SOURCE_PASSED:-false}" != "true" ]]; then
    ARG_SSOT_SOURCE="$(node -e "const j=JSON.parse(process.argv[1]); const u=j.ssot&&j.ssot.externalSsotRepo; console.log(u==null||u===undefined?'':String(u))" "$parsed")"
  fi
  if [[ "${ARG_CONFLUENCE_SPACE_KEY_PASSED:-false}" != "true" ]]; then
    ARG_CONFLUENCE_SPACE_KEY="$(node -e "const j=JSON.parse(process.argv[1]); const k=j.ssot&&j.ssot.confluenceSpaceKey; console.log(k==null||k===undefined?'':String(k))" "$parsed")"
  fi
  export SELECTED_AGENTS MCP_SELECTED_IDS DOMAIN_PROFILE VENDOR_MODE ARG_VENDOR ARG_LINK_MODE \
    ARG_SSOT_SOURCE ARG_CONFLUENCE_SPACE_KEY MCP_PRESERVE_EXISTING \
    MCP_CONFIGURED_SERVERS="$MCP_SELECTED_IDS"
  log_ok "Loaded install selection (agents=${SELECTED_AGENTS}, profile=${DOMAIN_PROFILE}, mcp=${MCP_SELECTED_IDS}, preserve-existing-mcp=${MCP_PRESERVE_EXISTING})"
}

# Prints a CSV of agents whose framework-generated surfaces already exist in
# TARGET_DIR. Only generator markers count as evidence: a hand-written root
# CLAUDE.md, or the project-owned eversis-project-stack.mdc (no marker), never
# does — so detection cannot turn on an adapter the framework did not install.
detect_installed_agents() {
  local found="" f=""
  if [[ -f "${TARGET_DIR}/CLAUDE.md" ]] && \
     grep -qF 'GENERATED by adapters/claude/generate.mjs' "${TARGET_DIR}/CLAUDE.md" 2>/dev/null; then
    found="claude"
  else
    for f in "${TARGET_DIR}/.claude/commands"/eversis-*.md; do
      [[ -f "$f" ]] || continue
      if grep -qF 'GENERATED by adapters/claude/generate-commands.mjs' "$f" 2>/dev/null; then
        found="claude"
        break
      fi
    done
  fi
  for f in "${TARGET_DIR}/.cursor/commands"/eversis-*.md "${TARGET_DIR}/.cursor/rules"/eversis-*.mdc; do
    [[ -f "$f" ]] || continue
    if grep -qF 'GENERATED by adapters/cursor/generate.mjs' "$f" 2>/dev/null; then
      found="${found:+${found},}cursor"
      break
    fi
  done
  # Pi (AC-14): the generated always-on file carries the Pi generator marker.
  if [[ -f "${TARGET_DIR}/.pi/APPEND_SYSTEM.md" ]] && \
     grep -qF 'GENERATED by adapters/pi/generate.mjs' "${TARGET_DIR}/.pi/APPEND_SYSTEM.md" 2>/dev/null; then
    found="${found:+${found},}pi"
  fi
  printf '%s' "$found"
}
