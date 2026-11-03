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

  # Pi (AC-14): its own guarded call, run last. Skipped when the Pi stage
  # already failed; a Pi merge / validation failure (e.g. a malformed
  # existing .pi/mcp.json) marks the Pi stage failed instead of dying, so the
  # Cursor / Claude files above stay written and the install continues.
  if echo ",${SELECTED_AGENTS:-}," | grep -q ',pi,'; then
    if [[ "${PI_STAGE_FAILED:-false}" == "true" ]]; then
      log_warn "Skipping .pi/mcp.json merge — the Pi stage already failed."
    else
      PI_MCP_FAILURE_REASON=""
      if ! _merge_mcp_json_for_host pi "${TARGET_DIR}/.pi/mcp.json" \
        "$use_relative" "$template_path" "$server_list" "$merge_mjs" "$dist_index"; then
        mark_pi_stage_failed ".pi/mcp.json merge failed: ${PI_MCP_FAILURE_REASON:-see the [mcp-merge] message above}"
      fi
    fi
  fi
  return 0
}

# Pi host failures return 1 (with PI_MCP_FAILURE_REASON) so the caller can
# isolate them; every other host keeps the original die.
_mcp_merge_host_fail() {
  local host="$1" msg="$2"
  if [[ "$host" == "pi" ]]; then
    PI_MCP_FAILURE_REASON="$msg"
    log_error "$msg"
    return 1
  fi
  die "$msg"
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

  if ! mkdir -p "$(dirname "$mcp_file")"; then
    _mcp_merge_host_fail "$host" "Cannot create the directory for ${mcp_file}."
    return 1
  fi

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
  )" || { _mcp_merge_host_fail "$host" "Failed to build/merge ${mcp_file}."; return 1; }

  echo "$merged" | node -e "JSON.parse(require('fs').readFileSync(0,'utf8'))" \
    || { _mcp_merge_host_fail "$host" "Merged ${mcp_file} is not valid JSON — aborting."; return 1; }

  if ! echo "$merged" > "$mcp_file"; then
    _mcp_merge_host_fail "$host" "Cannot write ${mcp_file}."
    return 1
  fi
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
  # Vendored Pi (AC-14) execs the same wrapper from its own bash -c locator.
  if { [[ "$host" == "claude" ]] || [[ "$host" == "pi" ]]; } && [[ "$use_relative" == "true" ]]; then
    local wrapper_src=""
    if ! wrapper_src="$(_resolve_wrapper_template)"; then
      _mcp_merge_host_fail "$host" "Wrapper template not found. Looked in INSTALLER_FRAMEWORK_HOME (${INSTALLER_FRAMEWORK_HOME:-unset}), the setup script tree, and COLLECTIONS_HOME (${COLLECTIONS_HOME})."
      return 1
    fi
    if [[ "$host" == "pi" ]]; then
      { mkdir -p "${TARGET_DIR}/scripts" \
        && cp "$wrapper_src" "${TARGET_DIR}/scripts/run-eversis-collections-mcp.sh" \
        && chmod +x "${TARGET_DIR}/scripts/run-eversis-collections-mcp.sh"; } \
        || { _mcp_merge_host_fail "$host" "Cannot write ${TARGET_DIR}/scripts/run-eversis-collections-mcp.sh."; return 1; }
    else
      mkdir -p "${TARGET_DIR}/scripts"
      cp "$wrapper_src" "${TARGET_DIR}/scripts/run-eversis-collections-mcp.sh"
      chmod +x "${TARGET_DIR}/scripts/run-eversis-collections-mcp.sh"
    fi
    log_ok "Wrote ${TARGET_DIR}/scripts/run-eversis-collections-mcp.sh"
  fi
  return 0
}
