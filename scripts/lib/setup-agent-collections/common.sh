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

# Prints the command that runs this installer, as the person types it in the
# project root, for every message that tells the person what to run: the Pi
# hand-port stop message (legacy-pi.sh), the "Recovery:" hint of
# _print_partial_fail below, and the two missing / invalid selection messages
# of load_selection_or_fail (upgrade.sh). Every path check uses resolved
# paths: SCRIPT_DIR is logical (pwd) while TARGET_DIR from git rev-parse is
# physical (macOS /var vs /private/var, symlinked project folders).
#   - Inside the project (relative-path.mjs, realpath on both sides, from
#     TARGET_DIR to the script succeeds with no leading ../ and no absolute
#     path): the project-relative path, for example
#     bash vendor/agent-collections/scripts/setup-agent-collections.sh.
#   - Otherwise, when AGENT_COLLECTIONS_HOME resolves to the framework folder
#     that holds this script: bash "$AGENT_COLLECTIONS_HOME/scripts/…", left
#     for the person's shell to expand.
#   - Otherwise, and also when node or relative-path.mjs fails: the quoted
#     absolute path of the running script.
_installer_command() {
  local script_dir="${SETUP_SCRIPT_DIR:-}"
  if [[ -z "$script_dir" ]]; then
    printf '%s' "bash scripts/setup-agent-collections.sh"
    return 0
  fi
  local script="${script_dir}/setup-agent-collections.sh" rel=""
  if [[ -n "${LIB_DIR:-}" ]] && command -v node >/dev/null 2>&1; then
    rel="$(node "${LIB_DIR}/relative-path.mjs" "$TARGET_DIR" "$script" 2>/dev/null)" || rel=""
  fi
  case "$rel" in
    ""|..|../*|/*) ;;
    *)
      if [[ "$rel" =~ ^[A-Za-z0-9._/+-]+$ ]]; then
        printf 'bash %s' "$rel"
      else
        printf 'bash "%s"' "$(_shell_dq_escape "$rel")"
      fi
      return 0
      ;;
  esac
  if [[ -n "${AGENT_COLLECTIONS_HOME:-}" ]]; then
    local home_real framework_real
    home_real="$(cd -P "${AGENT_COLLECTIONS_HOME}" 2>/dev/null && pwd -P)" || home_real=""
    framework_real="$(cd -P "${script_dir}/.." 2>/dev/null && pwd -P)" || framework_real=""
    if [[ -n "$home_real" ]] && [[ "$home_real" == "$framework_real" ]]; then
      # shellcheck disable=SC2016
      printf '%s' 'bash "$AGENT_COLLECTIONS_HOME/scripts/setup-agent-collections.sh"'
      return 0
    fi
  fi
  printf 'bash "%s"' "$(_shell_dq_escape "$script")"
}

# Prints $1 escaped for use inside double quotes in a shell command:
# backslash, double quote, dollar sign and backtick get a backslash.
_shell_dq_escape() {
  printf '%s' "$1" | sed 's/[\\"$`]/\\&/g'
}

# Prints the --vendor / --link-mode flags the person typed, each with a
# leading space, so a printed re-run command keeps them (a failed vendored
# install must not be re-run in local mode). Only the *_PASSED markers decide:
# ARG_LINK_MODE defaults to "auto" and ARG_VENDOR can be filled from the
# record, so their values cannot tell a typed flag from a default. $1 is the
# --vendor value to print; "true" (a bare --vendor not resolved yet) prints
# a bare --vendor. Prints nothing when neither flag was typed.
_typed_vendor_link_flags() {
  local vendor="${1:-}" out=""
  if [[ "${ARG_VENDOR_PASSED:-false}" == "true" ]]; then
    if [[ "$vendor" == "true" ]]; then
      out=" --vendor"
    else
      out=" --vendor=${vendor}"
    fi
  fi
  if [[ "${ARG_LINK_MODE_PASSED:-false}" == "true" ]]; then
    out="${out} --link-mode=${ARG_LINK_MODE:-}"
  fi
  printf '%s' "$out"
}

# Prints the re-run command of the "Recovery:" hint. What the command must
# carry depends on where this run's selection came from, so there are two
# rules:
#   - The run reused install-selection.json (SELECTION_FROM_RECORD=true, set
#     by load_selection_or_fail): --upgrade --sync --non-interactive plus only
#     the selection flags the person typed. The record supplies the rest.
#     Printing resolved values would be harmful: an explicit --mcp-servers
#     turns off MCP preserve mode (existing entries rewritten, hand-added
#     catalog servers pruned) and an explicit --agents turns on agent pruning.
#     One exception: after a Pi stage failure the record is written without
#     pi, so --agents carries this run's agents (pi included) and the re-run
#     retries Pi.
#   - Fresh install (no record reused): --sync --non-interactive with this
#     run's agents, MCP servers and profile. Per field: the resolved value,
#     else the typed flag (spaces stripped), else a named placeholder
#     (<agents>, <mcp-servers>, <profile>); when a placeholder is printed, one
#     more line names the placeholders to fill in.
# Both rules add --vendor / --link-mode when the person typed them, with the
# resolved VENDOR_MODE (a bare --vendor resolves to submodule or to the
# person's choice), else ARG_VENDOR when the vendor step has not resolved it.
# Every variable is read with ${VAR:-}: the function also runs from a unit
# check that sources this file alone under set -u.
_print_recovery_command() {
  local installer extra
  installer="$(_installer_command)"
  extra="$(_typed_vendor_link_flags "${VENDOR_MODE:-${ARG_VENDOR:-}}")"

  if [[ "${SELECTION_FROM_RECORD:-false}" == "true" ]]; then
    local flags="" agents="${ARG_AGENTS:-}"
    if [[ "${PI_STAGE_FAILED:-false}" == "true" ]] && [[ -n "${SELECTED_AGENTS:-}" ]]; then
      agents="${SELECTED_AGENTS}"
    fi
    if [[ -n "$agents" ]]; then
      flags="${flags} --agents=${agents// /}"
    fi
    if [[ -n "${ARG_MCP_SERVERS:-}" ]]; then
      flags="${flags} --mcp-servers=${ARG_MCP_SERVERS// /}"
    fi
    if [[ -n "${ARG_PROFILE:-}" ]]; then
      flags="${flags} --profile=${ARG_PROFILE// /}"
    fi
    echo "  ${installer} --upgrade --sync --non-interactive${flags}${extra}"
    return 0
  fi

  local agents="${SELECTED_AGENTS:-${ARG_AGENTS:-}}"
  local mcp="${MCP_SELECTED_IDS:-${ARG_MCP_SERVERS:-}}"
  local profile="${DOMAIN_PROFILE:-${ARG_PROFILE:-}}"
  local missing=()
  agents="${agents// /}"
  mcp="${mcp// /}"
  profile="${profile// /}"
  if [[ -z "$agents" ]]; then
    agents="<agents>"
    missing+=("<agents>")
  fi
  if [[ -z "$mcp" ]]; then
    mcp="<mcp-servers>"
    missing+=("<mcp-servers>")
  fi
  if [[ -z "$profile" ]]; then
    profile="<profile>"
    missing+=("<profile>")
  fi
  echo "  ${installer} --sync --non-interactive \\"
  echo "    --agents=${agents} --mcp-servers=${mcp} --profile=${profile}${extra}"
  case "${#missing[@]}" in
    0) ;;
    1) echo "  Replace ${missing[0]} with your value (the run stopped before it was set)." ;;
    2) echo "  Replace ${missing[0]} and ${missing[1]} with your values (the run stopped before they were set)." ;;
    *) echo "  Replace ${missing[0]}, ${missing[1]} and ${missing[2]} with your values (the run stopped before they were set)." ;;
  esac
  return 0
}

# Prints which steps completed and which failed, then the "Recovery:" hint
# with a re-run command (_print_recovery_command). Does nothing when no step
# failed, so a run without failures never starts node for the installer path.
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
  _print_recovery_command
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
