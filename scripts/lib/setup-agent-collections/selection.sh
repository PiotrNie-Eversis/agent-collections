#!/usr/bin/env bash
# lib/setup-agent-collections/selection.sh — write/read install-selection.json (Q3).

SELECTION_REL=".agent-collections/install-selection.json"

write_install_selection() {
  local out="${TARGET_DIR}/${SELECTION_REL}"
  mkdir -p "$(dirname "$out")"
  require_cmd node "Install Node.js 22 or newer"

  local version="0.0.1"
  if [[ -f "${COLLECTIONS_HOME}/package.json" ]]; then
    version="$(node -e "console.log(JSON.parse(require('fs').readFileSync(process.argv[1],'utf8')).version||'0.0.1')" "${COLLECTIONS_HOME}/package.json")"
  fi

  local vendor_mode="${VENDOR_MODE:-local}"
  [[ -z "$vendor_mode" ]] && vendor_mode="local"
  local link_mode="${EFFECTIVE_LINK_MODE:-${ARG_LINK_MODE:-auto}}"
  local agents_json
  # A failed Pi stage leaves pi out of the record so a later
  # --upgrade does not treat a broken Pi install as selected. SELECTED_AGENTS
  # itself is never edited (an empty list would fall back to cursor).
  local drop_pi="false"
  [[ "${PI_STAGE_FAILED:-false}" == "true" ]] && drop_pi="true"
  agents_json="$(node -e "console.log(JSON.stringify(String(process.argv[1]||'cursor').split(',').map(s=>s.trim()).filter(Boolean).filter(s=>!(process.argv[2]==='true'&&s==='pi'))))" "${SELECTED_AGENTS:-cursor}" "$drop_pi")"
  # deselectedAgents: ["pi"] only when this run decided the person explicitly
  # dropped Pi (PI_DESELECTED, set by decide_pi_deselect in legacy-pi.sh). The
  # record is rewritten from scratch, so this is also how the field is carried
  # forward (decide_pi_deselect keeps the recorded value on a run without
  # --agents) and cleared. With "false" the key is left out, so records of
  # projects that never dropped Pi keep the same shape as before.
  local deselected_json="[]"
  [[ "${PI_DESELECTED:-false}" == "true" ]] && deselected_json='["pi"]'
  local mcp_json
  mcp_json="$(node -e "console.log(JSON.stringify(String(process.argv[1]||'eversis-collections').split(',').map(s=>s.trim()).filter(Boolean)))" "${MCP_SELECTED_IDS:-eversis-collections}")"

  local ssot_repo="${ARG_SSOT_SOURCE:-}"
  local project_context_path="docs/context/${SSOT_PROJECT_SLUG:-project}/"
  local global_context_path="docs/context/global/"
  if [[ -f "$out" ]]; then
    local existing_project existing_global
    existing_project="$(node -e "const j=JSON.parse(require('fs').readFileSync(process.argv[1],'utf8')); const p=j.ssot&&j.ssot.projectContextPath; if (typeof p==='string' && p.trim()) process.stdout.write(p);" "$out")" || true
    existing_global="$(node -e "const j=JSON.parse(require('fs').readFileSync(process.argv[1],'utf8')); const p=j.ssot&&j.ssot.globalContextPath; if (typeof p==='string' && p.trim()) process.stdout.write(p);" "$out")" || true
    # An explicit name — --project-name, or SSOT_PROJECT_SLUG set
    # before the run (SSOT_PROJECT_NAME_EXPLICIT, from scaffold_ssot_project) —
    # replaces the recorded path (same per-field contract as the other flags);
    # omitted, the record is kept.
    if [[ "${ARG_PROJECT_NAME_PASSED:-false}" != "true" ]] && \
       [[ "${SSOT_PROJECT_NAME_EXPLICIT:-false}" != "true" ]] && \
       [[ -n "$existing_project" ]]; then
      project_context_path="$existing_project"
    fi
    [[ -n "$existing_global" ]] && global_context_path="$existing_global"
  fi

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
      ssot: {
        externalSsotRepo: process.argv[8] || null,
        projectContextPath: process.argv[9],
        globalContextPath: process.argv[10],
        confluenceSpaceKey: process.argv[11] || null,
      },
    };
    const deselected = JSON.parse(process.argv[12]);
    if (deselected.length > 0) sel.deselectedAgents = deselected;
    fs.writeFileSync(process.argv[7], JSON.stringify(sel, null, 2) + '\n');
  " "$version" "$agents_json" "$mcp_json" "${DOMAIN_PROFILE:-fullstack}" "$vendor_mode" "$link_mode" "$out" \
    "$ssot_repo" "$project_context_path" "$global_context_path" "${ARG_CONFLUENCE_SPACE_KEY:-}" \
    "$deselected_json"

  log_ok "Wrote ${SELECTION_REL}"
  return 0
}
