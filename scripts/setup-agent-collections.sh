#!/usr/bin/env bash
# setup-agent-collections.sh — install Agent Collections into a consumer project.
#
# Usage:
#   bash scripts/setup-agent-collections.sh [OPTIONS]
#
# Options:
#   --build-mcp               Force rebuild of the MCP server (npm install + build).
#                             Without this flag, build still runs when dist/index.js
#                             is missing. Does not control the interactive MCP wizard.
#   --collections-home DIR    Path to agent-collections checkout.
#                             Overrides AGENT_COLLECTIONS_HOME env var and OS default.
#                             Prefer this (or a prior export) over bare
#                             $AGENT_COLLECTIONS_HOME/scripts/... when env may be unset.
#   --target DIR              Target project directory.
#                             Default: interactive (git root vs cwd) or git root.
#   --vendor submodule|copy   Vendor the framework into this repository.
#                             Default: local (framework lives outside repo).
#                             EOG default recommendation: submodule.
#   --link-mode auto|symlink|copy
#                             How to materialise generated adapter outputs.
#                             auto = symlink on Unix, copy on Windows (default).
#   --sync                    Re-run and refresh framework-managed surfaces.
#   --upgrade                 Reuse .agent-collections/install-selection.json (fail-safe).
#   --non-interactive         Skip all prompts; use defaults / flags.
#   --force                   Allow setup even when COLLECTIONS_HOME looks incomplete.
#   --gitignore-agent-artifacts
#                             Local mode only: gitignore docs/specs/*/ and docs/context/*/.
#   --mcp-servers LIST        Comma-separated MCP server ids (non-interactive).
#   --agents LIST             Comma-separated agent adapters: cursor,claude,opencode
#                             (opencode is placeholder-only).
#   --profile NAME            Domain profile: frontend | backend | fullstack
#   --help                    Show this help and exit.
#
# Environment variables:
#   AGENT_COLLECTIONS_HOME      Canonical path to agent-collections checkout.
#   AGENT_COLLECTIONS_REPO_URL  Git URL to clone from (default: upstream GitHub repo).
#
# Examples:
#   bash /path/to/agent-collections/scripts/setup-agent-collections.sh \
#     --collections-home /path/to/agent-collections \
#     --non-interactive --agents=cursor --mcp-servers=eversis-collections \
#     --profile=fullstack
#
#   export AGENT_COLLECTIONS_HOME=~/src/agent-collections
#   bash "$AGENT_COLLECTIONS_HOME/scripts/setup-agent-collections.sh" \
#     --vendor submodule
#
#   bash "$AGENT_COLLECTIONS_HOME/scripts/setup-agent-collections.sh" --upgrade --sync
#
# Interactive installs prompt for agents, domain profile, and MCP servers on a TTY
# (no --build-mcp required for the MCP checklist).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/lib/setup-agent-collections"

ARG_BUILD_MCP="false"
ARG_COLLECTIONS_HOME=""
ARG_TARGET=""
ARG_VENDOR=""
ARG_LINK_MODE="auto"
ARG_SYNC="false"
ARG_UPGRADE="false"
ARG_NON_INTERACTIVE="false"
ARG_FORCE="false"
ARG_GITIGNORE_AGENT_ARTIFACTS="false"
ARG_MCP_SERVERS=""
ARG_AGENTS=""
ARG_PROFILE=""

export ARG_BUILD_MCP ARG_COLLECTIONS_HOME ARG_TARGET ARG_VENDOR ARG_LINK_MODE \
       ARG_SYNC ARG_UPGRADE ARG_NON_INTERACTIVE ARG_FORCE \
       ARG_GITIGNORE_AGENT_ARTIFACTS ARG_MCP_SERVERS ARG_AGENTS ARG_PROFILE \
       SETUP_SCRIPT_DIR="${SCRIPT_DIR}" LIB_DIR="${LIB_DIR}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --build-mcp) ARG_BUILD_MCP="true"; shift ;;
    --collections-home)
      [[ $# -lt 2 ]] && { echo "ERROR: --collections-home requires a value" >&2; exit 1; }
      ARG_COLLECTIONS_HOME="$2"; shift 2 ;;
    --collections-home=*) ARG_COLLECTIONS_HOME="${1#*=}"; shift ;;
    --target)
      [[ $# -lt 2 ]] && { echo "ERROR: --target requires a value" >&2; exit 1; }
      ARG_TARGET="$2"; shift 2 ;;
    --target=*) ARG_TARGET="${1#*=}"; shift ;;
    --vendor)
      if [[ $# -ge 2 ]] && [[ "$2" != --* ]]; then
        ARG_VENDOR="$2"; shift 2
      else
        ARG_VENDOR="true"; shift
      fi ;;
    --vendor=*) ARG_VENDOR="${1#*=}"; shift ;;
    --link-mode)
      [[ $# -lt 2 ]] && { echo "ERROR: --link-mode requires a value" >&2; exit 1; }
      ARG_LINK_MODE="$2"; shift 2 ;;
    --link-mode=*) ARG_LINK_MODE="${1#*=}"; shift ;;
    --sync) ARG_SYNC="true"; shift ;;
    --upgrade) ARG_UPGRADE="true"; shift ;;
    --non-interactive) ARG_NON_INTERACTIVE="true"; shift ;;
    --force) ARG_FORCE="true"; shift ;;
    --gitignore-agent-artifacts) ARG_GITIGNORE_AGENT_ARTIFACTS="true"; shift ;;
    --mcp-servers)
      [[ $# -lt 2 ]] && { echo "ERROR: --mcp-servers requires a value" >&2; exit 1; }
      ARG_MCP_SERVERS="$2"; shift 2 ;;
    --mcp-servers=*) ARG_MCP_SERVERS="${1#*=}"; shift ;;
    --agents)
      [[ $# -lt 2 ]] && { echo "ERROR: --agents requires a value" >&2; exit 1; }
      ARG_AGENTS="$2"; shift 2 ;;
    --agents=*) ARG_AGENTS="${1#*=}"; shift ;;
    --profile)
      [[ $# -lt 2 ]] && { echo "ERROR: --profile requires a value" >&2; exit 1; }
      ARG_PROFILE="$2"; shift 2 ;;
    --profile=*) ARG_PROFILE="${1#*=}"; shift ;;
    --help|-h)
      awk '/^# setup-agent-collections.sh/,/^[^#]/ { if ($0 ~ /^#/) { sub(/^# ?/, ""); print } }' "$0"
      exit 0 ;;
    *)
      echo "ERROR: Unknown option: $1" >&2
      echo "Run with --help for usage." >&2
      exit 1 ;;
  esac
done

case "$ARG_LINK_MODE" in
  auto|symlink|copy) : ;;
  *) echo "ERROR: --link-mode must be auto, symlink, or copy (got: '${ARG_LINK_MODE}')" >&2; exit 1 ;;
esac

if [[ -n "$ARG_VENDOR" ]] && [[ "$ARG_VENDOR" != "true" ]]; then
  case "$ARG_VENDOR" in
    submodule|copy) : ;;
    *) echo "ERROR: --vendor must be 'submodule' or 'copy' (got: '${ARG_VENDOR}')" >&2; exit 1 ;;
  esac
fi

# shellcheck source=lib/setup-agent-collections/common.sh
source "${LIB_DIR}/common.sh"
# shellcheck source=lib/setup-agent-collections/paths.sh
source "${LIB_DIR}/paths.sh"
# shellcheck source=lib/setup-agent-collections/git-target.sh
source "${LIB_DIR}/git-target.sh"
# shellcheck source=lib/setup-agent-collections/build-mcp.sh
source "${LIB_DIR}/build-mcp.sh"
# shellcheck source=lib/setup-agent-collections/vendor.sh
source "${LIB_DIR}/vendor.sh"
# shellcheck source=lib/setup-agent-collections/agents.sh
source "${LIB_DIR}/agents.sh"
# shellcheck source=lib/setup-agent-collections/profile.sh
source "${LIB_DIR}/profile.sh"
# shellcheck source=lib/setup-agent-collections/link-framework.sh
source "${LIB_DIR}/link-framework.sh"
# shellcheck source=lib/setup-agent-collections/mcp-prompt.sh
source "${LIB_DIR}/mcp-prompt.sh"
# shellcheck source=lib/setup-agent-collections/mcp-merge.sh
source "${LIB_DIR}/mcp-merge.sh"
# shellcheck source=lib/setup-agent-collections/gitignore.sh
source "${LIB_DIR}/gitignore.sh"
# shellcheck source=lib/setup-agent-collections/ignore-triad.sh
source "${LIB_DIR}/ignore-triad.sh"
# shellcheck source=lib/setup-agent-collections/claude-settings-merge.sh
source "${LIB_DIR}/claude-settings-merge.sh"
# shellcheck source=lib/setup-agent-collections/scaffolding.sh
source "${LIB_DIR}/scaffolding.sh"
# shellcheck source=lib/setup-agent-collections/selection.sh
source "${LIB_DIR}/selection.sh"
# shellcheck source=lib/setup-agent-collections/upgrade.sh
source "${LIB_DIR}/upgrade.sh"
# shellcheck source=lib/setup-agent-collections/area-scope.sh
source "${LIB_DIR}/area-scope.sh"
# shellcheck source=lib/setup-agent-collections/summary.sh
source "${LIB_DIR}/summary.sh"

COMPLETED_STEPS=()
FAILED_STEPS=()
record_ok() { COMPLETED_STEPS+=("$1"); }
record_fail() { FAILED_STEPS+=("$1"); }

log_info "Starting agent-collections setup …"
detect_os

# Upgrade path: load selection first (fail-safe).
if [[ "$ARG_UPGRADE" == "true" ]] || { [[ "$ARG_SYNC" == "true" ]] && [[ -z "$ARG_AGENTS$ARG_PROFILE$ARG_MCP_SERVERS" ]]; }; then
  # Resolve target early for selection read when --target given; else after resolve_target_dir.
  :
fi

resolve_collections_home
ensure_framework_checkout
resolve_target_dir

_script_repo_root="$(cd "${SCRIPT_DIR}/.." && pwd)"
_resolved_target="$(cd "${TARGET_DIR}" && pwd)"
if [[ "$_resolved_target" == "$_script_repo_root" ]]; then
  die "Target directory is the agent-collections source repo (${_script_repo_root}).
  Run from your consumer project, or pass --target ~/your-project."
fi
unset _script_repo_root _resolved_target

if [[ "$ARG_UPGRADE" == "true" ]] || { [[ "$ARG_SYNC" == "true" ]] && [[ -f "${TARGET_DIR}/.agent-collections/install-selection.json" ]] && [[ -z "${ARG_AGENTS}" ]] && [[ -z "${ARG_PROFILE}" ]]; }; then
  load_selection_or_fail
fi

run_vendor_setup || { record_fail "vendor"; _print_partial_fail; exit 1; }
record_ok "vendor"

resolve_agents_selection
resolve_domain_profile

maybe_build_mcp "$COLLECTIONS_HOME" || { record_fail "build-mcp"; _print_partial_fail; exit 1; }
record_ok "build-mcp"

link_framework_files || { record_fail "link-framework"; _print_partial_fail; exit 1; }
record_ok "link-framework"

apply_domain_profile || { record_fail "domain-profile"; _print_partial_fail; exit 1; }
record_ok "domain-profile"

apply_area_scope || { record_fail "area-scope"; _print_partial_fail; exit 1; }
record_ok "area-scope"

_resolve_mcp_selection
merge_mcp_json || { record_fail "mcp-merge"; _print_partial_fail; exit 1; }
record_ok "mcp-merge"

manage_gitignore
merge_ignore_triad || true
record_ok "ignore"

merge_claude_settings || { record_fail "claude-settings"; _print_partial_fail; exit 1; }
record_ok "claude-settings"

scaffold_project
record_ok "scaffold"

write_install_selection || { record_fail "selection"; _print_partial_fail; exit 1; }
record_ok "selection"

print_summary
_print_partial_fail  # no-op if empty failures
log_ok "Done."
