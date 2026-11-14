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
  if [[ ${#FAILED_STEPS[@]} -eq 0 ]]; then
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

# Node version policy shared by the installer and --doctor. Below the runnable
# floor the framework scripts fail to parse (a SyntaxError that the vendor
# flag probes would otherwise misreport as a stale vendor pin). Between the
# runnable floor and the supported floor Node is end-of-life and untested.
# The supported floor matches the CI image.
NODE_MIN_RUNNABLE_MAJOR=18
NODE_MIN_SUPPORTED_MAJOR=22

# Prints "<status> <version>" for the node first on PATH and never dies, so a
# read-only check (--doctor) can report it next to other checks.
#   status:  ok | warn | error
#   version: the dotted version, "missing" (no node on PATH) or "unknown"
#            (the version query failed or printed something unexpected)
# The query is `node -p process.versions.node`: it parses on any Node release,
# and test stubs recognise it. Always returns 0.
node_version_status() {
  if ! command -v node >/dev/null 2>&1; then
    echo "error missing"
    return 0
  fi
  local version major
  version="$(node -p process.versions.node 2>/dev/null | head -n 1 | tr -d '[:space:]')" || version=""
  if [[ ! "$version" =~ ^[0-9]+(\.[0-9]+)*$ ]]; then
    echo "error unknown"
    return 0
  fi
  major="${version%%.*}"
  if (( major < NODE_MIN_RUNNABLE_MAJOR )); then
    echo "error ${version}"
  elif (( major < NODE_MIN_SUPPORTED_MAJOR )); then
    echo "warn ${version}"
  else
    echo "ok ${version}"
  fi
  return 0
}

# Prints how to put a newer Node first on PATH (nvm, or a Windows install
# under Git Bash). Shared by require_node_version and --doctor.
node_version_hint() {
  echo "Put Node ${NODE_MIN_SUPPORTED_MAJOR} or newer first on PATH and re-run, for example \`nvm install ${NODE_MIN_SUPPORTED_MAJOR} && nvm use ${NODE_MIN_SUPPORTED_MAJOR}\`, or in Git Bash \`export PATH=\"/c/Program Files/nodejs:\$PATH\"\`. Check with \`node --version\`."
}

# Dies when node is missing, unreadable or older than the runnable floor, and
# warns when it is end-of-life (runnable but older than the supported floor).
# Called once by the entry script before any other step runs Node.
require_node_version() {
  local status version
  read -r status version <<< "$(node_version_status)"
  case "$status" in
    ok) return 0 ;;
    warn)
      log_warn "Node ${version} is end-of-life and not tested; use Node ${NODE_MIN_SUPPORTED_MAJOR} or newer."
      return 0
      ;;
  esac
  case "$version" in
    missing)
      die "Required command 'node' not found. Install Node.js ${NODE_MIN_SUPPORTED_MAJOR} or newer from https://nodejs.org. $(node_version_hint)"
      ;;
    unknown)
      die "Could not read the Node version (\`node -p process.versions.node\` failed); Agent Collections needs Node ${NODE_MIN_SUPPORTED_MAJOR} or newer. $(node_version_hint)"
      ;;
    *)
      die "Node ${version} found, Agent Collections needs Node ${NODE_MIN_SUPPORTED_MAJOR} or newer. $(node_version_hint)"
      ;;
  esac
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
