#!/usr/bin/env bash
# lib/setup-agent-collections/mcp-user-overlap.sh — warn-only Cursor User vs project catalog overlap.
# Never writes ~/.cursor/mcp.json. Sourced after common.sh and mcp-merge.sh.

# Override for tests: AGENT_COLLECTIONS_USER_MCP=/path/to/fixture.json
# Default: $HOME/.cursor/mcp.json (Cursor Settings → MCP badge "User").

warn_user_mcp_catalog_overlap() {
  MCP_USER_OVERLAP_IDS=""
  export MCP_USER_OVERLAP_IDS

  if ! echo ",${SELECTED_AGENTS:-cursor}," | grep -q ',cursor,'; then
    return 0
  fi

  local user_mcp="${AGENT_COLLECTIONS_USER_MCP:-${HOME}/.cursor/mcp.json}"
  [[ -f "$user_mcp" ]] || return 0

  local selected="${MCP_SELECTED_IDS:-eversis-collections}"
  local overlap=""
  overlap="$(
    node -e '
      const fs = require("fs");
      const path = process.argv[1];
      const selected = process.argv[2].split(",").map((s) => s.trim()).filter(Boolean);
      let data;
      try {
        data = JSON.parse(fs.readFileSync(path, "utf8"));
      } catch {
        process.exit(0);
      }
      const servers = (data && data.mcpServers && typeof data.mcpServers === "object")
        ? data.mcpServers
        : {};
      const ids = selected.filter((id) => Object.prototype.hasOwnProperty.call(servers, id));
      if (ids.length) process.stdout.write(ids.join(","));
    ' "$user_mcp" "$selected"
  )" || return 0

  [[ -z "$overlap" ]] && return 0

  MCP_USER_OVERLAP_IDS="$overlap"
  export MCP_USER_OVERLAP_IDS

  local project_label
  project_label="$(basename "${TARGET_DIR:-.}")"

  log_warn "Cursor User MCP already has catalog server(s): ${overlap}"
  log_warn "Cursor Settings → MCP will show each of those twice: badge User vs ${project_label}."
  log_warn "Keep catalog ids in the project .cursor/mcp.json only. Leave User config (~/.cursor/mcp.json) for personal servers."
  log_warn "Command Palette → MCP: Open User Configuration — remove the overlapping ids. This installer does not edit the User file."
}
