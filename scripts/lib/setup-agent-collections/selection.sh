#!/usr/bin/env bash
# lib/setup-agent-collections/selection.sh — write/read install-selection.json (Q3).

SELECTION_REL=".agent-collections/install-selection.json"

write_install_selection() {
  local out="${TARGET_DIR}/${SELECTION_REL}"
  mkdir -p "$(dirname "$out")"
  require_cmd node "Install Node.js ≥ 18"

  local version="0.0.1"
  if [[ -f "${COLLECTIONS_HOME}/package.json" ]]; then
    version="$(node -e "console.log(JSON.parse(require('fs').readFileSync(process.argv[1],'utf8')).version||'0.0.1')" "${COLLECTIONS_HOME}/package.json")"
  fi

  local vendor_mode="${VENDOR_MODE:-local}"
  [[ -z "$vendor_mode" ]] && vendor_mode="local"
  local link_mode="${EFFECTIVE_LINK_MODE:-${ARG_LINK_MODE:-auto}}"
  local agents_json
  agents_json="$(node -e "console.log(JSON.stringify(String(process.argv[1]||'cursor').split(',').map(s=>s.trim()).filter(Boolean)))" "${SELECTED_AGENTS:-cursor}")"
  local mcp_json
  mcp_json="$(node -e "console.log(JSON.stringify(String(process.argv[1]||'eversis-collections').split(',').map(s=>s.trim()).filter(Boolean)))" "${MCP_SELECTED_IDS:-eversis-collections}")"

  node -e "
    const fs = require('fs');
    const sel = {
      frameworkVersion: process.argv[1],
      agents: JSON.parse(process.argv[2]),
      mcpServers: JSON.parse(process.argv[3]),
      domainProfile: process.argv[4],
      vendorMode: process.argv[5],
      linkMode: process.argv[6],
      recordedAt: new Date().toISOString(),
    };
    fs.writeFileSync(process.argv[7], JSON.stringify(sel, null, 2) + '\n');
  " "$version" "$agents_json" "$mcp_json" "${DOMAIN_PROFILE:-fullstack}" "$vendor_mode" "$link_mode" "$out"

  log_ok "Wrote ${SELECTION_REL}"
  return 0
}
