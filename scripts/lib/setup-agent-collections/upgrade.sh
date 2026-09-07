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
  DOMAIN_PROFILE="$(node -e "const j=JSON.parse(process.argv[1]); console.log(j.domainProfile)" "$parsed")"
  VENDOR_MODE="$(node -e "const j=JSON.parse(process.argv[1]); console.log(j.vendorMode==='local'?'':j.vendorMode)" "$parsed")"
  ARG_VENDOR="${VENDOR_MODE}"
  ARG_LINK_MODE="$(node -e "const j=JSON.parse(process.argv[1]); console.log(j.linkMode||'auto')" "$parsed")"
  if [[ "${ARG_SSOT_SOURCE_PASSED:-false}" != "true" ]]; then
    ARG_SSOT_SOURCE="$(node -e "const j=JSON.parse(process.argv[1]); const u=j.ssot&&j.ssot.externalSsotRepo; console.log(u==null||u===undefined?'':String(u))" "$parsed")"
  fi
  if [[ "${ARG_CONFLUENCE_SPACE_KEY_PASSED:-false}" != "true" ]]; then
    ARG_CONFLUENCE_SPACE_KEY="$(node -e "const j=JSON.parse(process.argv[1]); const k=j.ssot&&j.ssot.confluenceSpaceKey; console.log(k==null||k===undefined?'':String(k))" "$parsed")"
  fi
  export SELECTED_AGENTS MCP_SELECTED_IDS DOMAIN_PROFILE VENDOR_MODE ARG_VENDOR ARG_LINK_MODE \
    ARG_SSOT_SOURCE ARG_CONFLUENCE_SPACE_KEY MCP_CONFIGURED_SERVERS="$MCP_SELECTED_IDS"
  log_ok "Loaded install selection (agents=${SELECTED_AGENTS}, profile=${DOMAIN_PROFILE}, mcp=${MCP_SELECTED_IDS})"
}
