#!/usr/bin/env bash
# lib/setup-agent-collections/paths.sh — resolve AGENT_COLLECTIONS_HOME + clone.

readonly DEFAULT_REPO_URL="https://github.com/PiotrNie-Eversis/agent-collections.git"

resolve_collections_home() {
  local cli_home="${ARG_COLLECTIONS_HOME:-}"

  if [[ -n "$cli_home" ]]; then
    COLLECTIONS_HOME="$(cd "$cli_home" 2>/dev/null && pwd || echo "$cli_home")"
  elif [[ -n "${AGENT_COLLECTIONS_HOME:-}" ]]; then
    COLLECTIONS_HOME="$(cd "${AGENT_COLLECTIONS_HOME}" 2>/dev/null && pwd || echo "${AGENT_COLLECTIONS_HOME}")"
  else
    # Prefer the checkout that hosts this script when it looks like the framework.
    local script_root
    script_root="$(cd "${SETUP_SCRIPT_DIR}/.." && pwd)"
    if [[ -d "${script_root}/.ai/skills" ]]; then
      COLLECTIONS_HOME="$script_root"
    else
      COLLECTIONS_HOME="$(default_collections_home)"
    fi
  fi

  # Guard empty / root-like paths (e.g. one-liner with unset AGENT_COLLECTIONS_HOME
  # expanding to `/scripts/...` never reaches us — but empty CLI/env still can).
  if [[ -z "${COLLECTIONS_HOME:-}" ]] || [[ "${COLLECTIONS_HOME}" == "/" ]]; then
    die "AGENT_COLLECTIONS_HOME is empty or invalid.
  Pass --collections-home /path/to/agent-collections
  or: export AGENT_COLLECTIONS_HOME=/path/to/agent-collections
  then: bash \"\$AGENT_COLLECTIONS_HOME/scripts/setup-agent-collections.sh\" …"
  fi

  export COLLECTIONS_HOME
}

ensure_framework_checkout() {
  local home="$COLLECTIONS_HOME"
  local skills_marker="${home}/.ai/skills"

  if [[ -d "$skills_marker" ]]; then
    log_ok "Framework found at: ${home}"
    return 0
  fi

  if [[ -d "$home" ]]; then
    if [[ "${ARG_FORCE:-false}" == "true" ]]; then
      log_warn "Directory exists but has no .ai/skills — proceeding anyway (--force)."
      return 0
    fi
    die "Directory '${home}' exists but does not contain .ai/skills.
  Pass --collections-home /path/to/agent-collections or set AGENT_COLLECTIONS_HOME to a valid checkout."
  fi

  require_cmd git "Install Git from https://git-scm.com"

  local repo_url="${AGENT_COLLECTIONS_REPO_URL:-${DEFAULT_REPO_URL}}"
  log_info "Cloning agent-collections from ${repo_url} → ${home} …"
  git clone --depth 1 "$repo_url" "$home" || die "git clone failed."
  log_ok "Cloned to ${home}"
}
