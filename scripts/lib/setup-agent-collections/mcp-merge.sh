#!/usr/bin/env bash
# lib/setup-agent-collections/mcp-merge.sh

merge_mcp_json() {
  require_cmd node "Install Node.js ≥ 18 from https://nodejs.org"

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

  local use_relative="false"
  if [[ "${VENDOR_MODE:-}" == "submodule" ]] || [[ "${VENDOR_MODE:-}" == "copy" ]]; then
    use_relative="true"
  fi

  # Cursor keeps today's unconditional-by-default behaviour (defaults to
  # selected when SELECTED_AGENTS is unset, matching the pre-existing
  # single-host script and the ${SELECTED_AGENTS:-cursor} idiom already used
  # by link-framework.sh's _run_adapter_sync).
  if echo ",${SELECTED_AGENTS:-cursor}," | grep -q ',cursor,'; then
    _merge_mcp_json_for_host cursor "${TARGET_DIR}/.cursor/mcp.json" \
      "$use_relative" "$template_path" "$server_list" "$merge_mjs" "$dist_index"
  fi

  # Claude Code only gets .mcp.json when explicitly selected — no implicit
  # default, matching the ',claude,' guard idiom in area-scope.sh.
  if echo ",${SELECTED_AGENTS:-}," | grep -q ',claude,'; then
    _merge_mcp_json_for_host claude "${TARGET_DIR}/.mcp.json" \
      "$use_relative" "$template_path" "$server_list" "$merge_mjs" "$dist_index"
  fi

  warn_user_mcp_catalog_overlap
}

# Prefer the checkout that is actually executing this installer. A vendored
# submodule pin lags that checkout until the consumer bumps it.
_resolve_wrapper_template() {
  local candidate=""
  if [[ -n "${INSTALLER_FRAMEWORK_HOME:-}" ]]; then
    candidate="${INSTALLER_FRAMEWORK_HOME}/templates/run-eversis-collections-mcp.sh"
    if [[ -f "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  fi
  if [[ -n "${SETUP_SCRIPT_DIR:-}" ]]; then
    candidate="$(cd "${SETUP_SCRIPT_DIR}/.." && pwd)/templates/run-eversis-collections-mcp.sh"
    if [[ -f "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  fi
  candidate="${COLLECTIONS_HOME}/templates/run-eversis-collections-mcp.sh"
  if [[ -f "$candidate" ]]; then
    printf '%s\n' "$candidate"
    return 0
  fi
  return 1
}

_merge_mcp_json_for_host() {
  local host="$1" mcp_file="$2" use_relative="$3" template_path="$4" \
        server_list="$5" merge_mjs="$6" dist_index="$7"

  mkdir -p "$(dirname "$mcp_file")"

  local existing_json="{}"
  if [[ -f "$mcp_file" ]]; then
    existing_json="$(cat "$mcp_file")"
  fi

  local merged
  merged="$(
    MCP_HOST="$host" \
    MCP_TARGET_DIR="$TARGET_DIR" \
    MCP_DIST_INDEX="$dist_index" \
    MCP_COLLECTIONS_HOME="$COLLECTIONS_HOME" \
    MCP_USE_RELATIVE="$use_relative" \
    MCP_EXISTING_JSON="$existing_json" \
    MCP_SELECTED_IDS="${MCP_SELECTED_IDS:-eversis-collections}" \
    MCP_TEMPLATE_PATH="$template_path" \
    MCP_SERVER_LIST_PATH="$server_list" \
    MCP_PRESERVE_EXISTING="${MCP_PRESERVE_EXISTING:-false}" \
    node "$merge_mjs"
  )" || die "Failed to build/merge ${mcp_file}."

  echo "$merged" | node -e "JSON.parse(require('fs').readFileSync(0,'utf8'))" \
    || die "Merged ${mcp_file} is not valid JSON — aborting."

  echo "$merged" > "$mcp_file"
  # Stays the selection even in preserve mode — preserved-only ids are not
  # part of the record; claude-settings-merge.mjs unions them for Claude.
  export MCP_CONFIGURED_SERVERS="${MCP_SELECTED_IDS:-eversis-collections}"
  if [[ "${MCP_PRESERVE_EXISTING:-false}" == "true" ]]; then
    log_ok "Wrote ${mcp_file} (selected: ${MCP_SELECTED_IDS:-eversis-collections}; existing entries preserved)"
  else
    log_ok "Wrote ${mcp_file} (servers: ${MCP_SELECTED_IDS:-eversis-collections})"
  fi

  # Vendored Claude: commit a BASH_SOURCE-based wrapper next to .mcp.json so
  # the bash -c locator can exec a path that does not depend on cwd.
  # Submodule upgrades repoint COLLECTIONS_HOME at the pinned vendor tree,
  # which does not contain this template until that pin moves. The running
  # installer (INSTALLER_FRAMEWORK_HOME / this script's repo) does.
  if [[ "$host" == "claude" ]] && [[ "$use_relative" == "true" ]]; then
    local wrapper_src=""
    if ! wrapper_src="$(_resolve_wrapper_template)"; then
      die "Wrapper template not found. Looked in INSTALLER_FRAMEWORK_HOME (${INSTALLER_FRAMEWORK_HOME:-unset}), the setup script tree, and COLLECTIONS_HOME (${COLLECTIONS_HOME})."
    fi
    mkdir -p "${TARGET_DIR}/scripts"
    cp "$wrapper_src" "${TARGET_DIR}/scripts/run-eversis-collections-mcp.sh"
    chmod +x "${TARGET_DIR}/scripts/run-eversis-collections-mcp.sh"
    log_ok "Wrote ${TARGET_DIR}/scripts/run-eversis-collections-mcp.sh"
  fi
}
