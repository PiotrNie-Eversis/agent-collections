#!/usr/bin/env bash
# lib/setup-agent-collections/build-mcp.sh

_mcp_dir_for() {
  echo "${1}/mcp/eversis-collections-mcp"
}

maybe_build_mcp() {
  local base_dir="${1:-${COLLECTIONS_HOME}}"
  local mcp_dir
  mcp_dir="$(_mcp_dir_for "$base_dir")"
  local dist_index="${mcp_dir}/dist/index.js"

  if [[ ! -d "$mcp_dir" ]]; then
    die "MCP directory not found: ${mcp_dir}. Is '${base_dir}' a valid agent-collections checkout?"
  fi

  if [[ -f "$dist_index" ]] && [[ "${ARG_BUILD_MCP:-false}" != "true" ]]; then
    log_ok "MCP dist already present — skipping build (pass --build-mcp to force rebuild)."
    return 0
  fi

  require_cmd node "Install Node.js ≥ 18 from https://nodejs.org"
  require_cmd npm "npm comes bundled with Node.js"

  log_info "Building MCP server in ${mcp_dir} …"
  (cd "$mcp_dir" && npm install && npm run build) \
    || die "MCP build failed. Check the output above for details."
  log_ok "MCP build complete → ${dist_index}"
}
