#!/usr/bin/env bash
# lib/setup-agent-collections/mcp-merge.sh

merge_mcp_json() {
  require_cmd node "Install Node.js ≥ 18 from https://nodejs.org"

  local cursor_dir="${TARGET_DIR}/.cursor"
  local mcp_file="${cursor_dir}/mcp.json"
  local mcp_pkg_dir="${COLLECTIONS_HOME}/mcp/eversis-collections-mcp"
  local dist_index="${mcp_pkg_dir}/dist/index.js"
  local template_path="${COLLECTIONS_HOME}/templates/mcp.json"
  if [[ ! -f "$template_path" ]]; then
    template_path="${COLLECTIONS_HOME}/.cursor/mcp.json"
  fi
  if [[ ! -f "$template_path" ]] && [[ -n "${SETUP_SCRIPT_DIR:-}" ]]; then
    local _fallback="${SETUP_SCRIPT_DIR}/../templates/mcp.json"
    [[ -f "$_fallback" ]] && template_path="$_fallback"
  fi
  local server_list="${LIB_DIR}/mcp-server-list.json"
  local merge_mjs="${LIB_DIR}/mcp-merge.mjs"

  [[ -f "$template_path" ]] || die "Framework MCP template not found (templates/mcp.json)."
  [[ -f "$server_list" ]]    || die "MCP server list not found: ${server_list}"
  [[ -f "$merge_mjs" ]]       || die "MCP merge script not found: ${merge_mjs}"

  mkdir -p "$cursor_dir"

  local use_relative="false"
  if [[ "${VENDOR_MODE:-}" == "submodule" ]] || [[ "${VENDOR_MODE:-}" == "copy" ]]; then
    use_relative="true"
  fi

  local existing_json="{}"
  if [[ -f "$mcp_file" ]]; then
    existing_json="$(cat "$mcp_file")"
  fi

  local merged
  merged="$(
    MCP_TARGET_DIR="$TARGET_DIR" \
    MCP_DIST_INDEX="$dist_index" \
    MCP_COLLECTIONS_HOME="$COLLECTIONS_HOME" \
    MCP_USE_RELATIVE="$use_relative" \
    MCP_EXISTING_JSON="$existing_json" \
    MCP_SELECTED_IDS="${MCP_SELECTED_IDS:-eversis-collections}" \
    MCP_TEMPLATE_PATH="$template_path" \
    MCP_SERVER_LIST_PATH="$server_list" \
    node "$merge_mjs"
  )" || die "Failed to build/merge mcp.json."

  echo "$merged" | node -e "JSON.parse(require('fs').readFileSync(0,'utf8'))" \
    || die "Merged mcp.json is not valid JSON — aborting."

  echo "$merged" > "$mcp_file"
  export MCP_CONFIGURED_SERVERS="${MCP_SELECTED_IDS:-eversis-collections}"
  log_ok "Wrote ${mcp_file} (servers: ${MCP_SELECTED_IDS:-eversis-collections})"
}
