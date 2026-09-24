#!/usr/bin/env bash
# Installer-owned wrapper for vendored Claude Code eversis-collections MCP.
# Derives the consumer root from this script's location (parent of scripts/),
# not from PWD or caller environment.
set -euo pipefail

_script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_consumer_root="$(cd "${_script_dir}/.." && pwd)"
_compose_file="${_consumer_root}/vendor/agent-collections/docker-compose.yml"

if [[ ! -f "$_compose_file" ]]; then
  echo "run-eversis-collections-mcp: missing compose file: ${_compose_file}" >&2
  exit 1
fi

export CONSUMER_PROJECT_ROOT="$_consumer_root"
exec docker compose -f "$_compose_file" run --rm -T eversis-collections
