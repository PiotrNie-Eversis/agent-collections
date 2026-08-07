#!/usr/bin/env bash
# lib/setup-agent-collections/common.sh — shared constants, colours, logging helpers.

set -euo pipefail

if [[ -t 1 ]] && command -v tput >/dev/null 2>&1; then
  _BOLD=$(tput bold)
  _GREEN=$(tput setaf 2)
  _YELLOW=$(tput setaf 3)
  _RED=$(tput setaf 1)
  _CYAN=$(tput setaf 6)
  _RESET=$(tput sgr0)
else
  _BOLD="" _GREEN="" _YELLOW="" _RED="" _CYAN="" _RESET=""
fi

log_info()    { echo "${_CYAN}[agent-setup]${_RESET} $*"; }
log_ok()      { echo "${_GREEN}[agent-setup]${_RESET} $*"; }
log_warn()    { echo "${_YELLOW}[agent-setup WARN]${_RESET} $*" >&2; }
log_error()   { echo "${_RED}[agent-setup ERROR]${_RESET} $*" >&2; }
die()         { log_error "$*"; exit 1; }

_print_partial_fail() {
  if [[ ${#FAILED_STEPS[@]:-0} -eq 0 ]]; then
    return 0
  fi
  echo ""
  log_error "Partial failure — completed vs failed:"
  local s
  for s in "${COMPLETED_STEPS[@]:-}"; do
    [[ -n "$s" ]] && echo "  completed: ${s}"
  done
  for s in "${FAILED_STEPS[@]:-}"; do
    [[ -n "$s" ]] && echo "  failed:    ${s}"
  done
  echo ""
  echo "Recovery: fix the failed step, then re-run with the same flags (idempotent)."
  echo "  bash scripts/setup-agent-collections.sh --sync --non-interactive \\"
  echo "    --agents=\${agents} --mcp-servers=\${mcp} --profile=\${profile}"
}

detect_os() {
  case "${OSTYPE:-}" in
    darwin*) OS_TYPE="macos" ;;
    msys*|cygwin*|mingw*) OS_TYPE="windows" ;;
    *)
      if [[ "$(uname -s 2>/dev/null)" == MINGW* ]] || [[ "$(uname -s 2>/dev/null)" == CYGWIN* ]]; then
        OS_TYPE="windows"
      else
        OS_TYPE="linux"
      fi
      ;;
  esac
  readonly OS_TYPE
}

default_collections_home() {
  local os="${OS_TYPE:-}"
  case "$os" in
    macos|linux) echo "${HOME}/.local/share/agent-collections" ;;
    windows)
      local appdata="${LOCALAPPDATA:-${APPDATA:-}}"
      if [[ -n "$appdata" ]]; then
        echo "${appdata}/agent-collections"
      else
        echo "${HOME}/agent-collections"
      fi
      ;;
    *) echo "${HOME}/.local/share/agent-collections" ;;
  esac
}

require_cmd() {
  local cmd="$1" hint="${2:-}"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    if [[ -n "$hint" ]]; then
      die "Required command '${cmd}' not found. ${hint}"
    else
      die "Required command '${cmd}' not found."
    fi
  fi
}

_ensure_inquirer_prompt_deps() {
  # Shared by agents + MCP checkbox prompts (LIB_DIR set by setup entrypoint).
  local deps_marker="${LIB_DIR}/node_modules/@inquirer/prompts/package.json"
  [[ -f "$deps_marker" ]] && return 0
  require_cmd npm "Install Node.js/npm from https://nodejs.org"
  log_info "Installing installer prompt UI dependencies (one-time) …"
  (cd "$LIB_DIR" && npm install --omit=dev --no-audit --no-fund --silent) \
    || return 1
  return 0
}

# Back-compat alias used by older MCP prompt call sites.
_ensure_mcp_prompt_deps() {
  _ensure_inquirer_prompt_deps
}
