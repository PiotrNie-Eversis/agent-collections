#!/usr/bin/env bash
# lib/setup-agent-collections/build-mcp.sh

_mcp_dir_for() {
  echo "${1}/mcp/eversis-collections-mcp"
}

maybe_build_mcp() {
  local base_dir="${1:-${COLLECTIONS_HOME}}"
  local mcp_dir
  mcp_dir="$(_mcp_dir_for "$base_dir")"
  local compose_file="${base_dir}/docker-compose.yml"

  if [[ ! -d "$mcp_dir" ]]; then
    die "MCP directory not found: ${mcp_dir}. Is '${base_dir}' a valid agent-collections checkout?"
  fi
  if [[ ! -f "$compose_file" ]]; then
    die "docker-compose.yml not found: ${compose_file}. Is '${base_dir}' a valid agent-collections checkout?"
  fi

  require_cmd docker "Install Docker Engine (with Compose v2) from https://docs.docker.com/get-docker/"

  local image_tag
  image_tag="$(docker compose -f "$compose_file" config --images eversis-collections 2>/dev/null)"

  if [[ -n "$image_tag" ]] && docker image inspect "$image_tag" >/dev/null 2>&1 \
    && [[ "${ARG_BUILD_MCP:-false}" != "true" ]]; then
    log_ok "MCP image already built (${image_tag}) — skipping build (pass --build-mcp to force rebuild)."
    return 0
  fi

  log_info "Building MCP server image via Docker Compose (${compose_file}) …"
  docker compose -f "$compose_file" build eversis-collections \
    || die "MCP build failed. Check the output above for details."
  log_ok "MCP build complete — image ready for docker compose run."
}
