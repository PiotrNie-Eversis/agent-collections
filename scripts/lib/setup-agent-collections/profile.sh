#!/usr/bin/env bash
# lib/setup-agent-collections/profile.sh — domain profile axis (manifest-driven).

readonly PROFILE_PROMPT_MJS="${LIB_DIR}/profile-prompt.mjs"

_is_interactive_profile_terminal() {
  [[ -t 1 ]]
}

_run_select_profile_prompt() {
  local selected="" exit_code=0

  selected="$(node "$PROFILE_PROMPT_MJS")" || exit_code=$?
  if [[ "$exit_code" -eq 130 ]]; then
    die "Setup cancelled."
  fi
  if [[ "$exit_code" -ne 0 ]] || [[ -z "$selected" ]]; then
    return 1
  fi

  DOMAIN_PROFILE="${selected//$'\n'/}"
  _validate_profile "$DOMAIN_PROFILE"
  export DOMAIN_PROFILE
  return 0
}

_run_numbered_profile_prompt() {
  echo ""
  echo "${_BOLD}Select domain profile:${_RESET}"
  echo "  1) frontend  — FE-oriented rules/skills"
  echo "  2) backend   — BE-oriented rules/skills"
  echo "  3) fullstack — full set + monorepo area scoping defaults"
  echo ""
  local choice=""
  read -r -p "Enter choice [3]: " choice
  case "${choice:-3}" in
    1) DOMAIN_PROFILE="frontend" ;;
    2) DOMAIN_PROFILE="backend" ;;
    *) DOMAIN_PROFILE="fullstack" ;;
  esac
  export DOMAIN_PROFILE
}

_run_interactive_profile_prompt() {
  require_cmd node "Install Node.js ≥ 18 from https://nodejs.org"

  if _ensure_inquirer_prompt_deps && _run_select_profile_prompt; then
    return 0
  fi

  log_info "Select UI unavailable — using numbered menu."
  _run_numbered_profile_prompt
}

resolve_domain_profile() {
  if [[ -n "${DOMAIN_PROFILE:-}" ]]; then
    _validate_profile "$DOMAIN_PROFILE"
    export DOMAIN_PROFILE
    return 0
  fi

  if [[ -n "${ARG_PROFILE:-}" ]]; then
    DOMAIN_PROFILE="${ARG_PROFILE}"
    _validate_profile "$DOMAIN_PROFILE"
    export DOMAIN_PROFILE
    return 0
  fi

  if [[ "${ARG_NON_INTERACTIVE:-false}" == "true" ]]; then
    DOMAIN_PROFILE="fullstack"
    export DOMAIN_PROFILE
    log_info "Non-interactive default profile: fullstack"
    return 0
  fi

  if _is_interactive_profile_terminal; then
    _run_interactive_profile_prompt
  else
    DOMAIN_PROFILE="fullstack"
    export DOMAIN_PROFILE
    log_warn "Non-interactive terminal — defaulting profile to fullstack."
    log_info "Pass --profile=frontend|backend|fullstack for non-interactive selection."
  fi
}

_validate_profile() {
  local p="$1"
  case "$p" in
    frontend|backend|fullstack) : ;;
    *) die "Unknown --profile '${p}'. Allowed: frontend, backend, fullstack" ;;
  esac
  local manifest="${COLLECTIONS_HOME}/adapters/profiles/${p}.yaml"
  [[ -f "$manifest" ]] || die "Domain profile manifest missing: ${manifest}"
}

apply_domain_profile() {
  # Record allowlist path for selection; materialisation is via MCP + sync (skills stay in .ai/).
  local manifest="${COLLECTIONS_HOME}/adapters/profiles/${DOMAIN_PROFILE}.yaml"
  [[ -f "$manifest" ]] || die "Missing profile manifest: ${manifest}"
  PROFILE_MANIFEST="$manifest"
  export PROFILE_MANIFEST
  # Optional: write consumer hint file (project-owned-ish; create-if-absent).
  local hint_dir="${TARGET_DIR}/.agent-collections"
  mkdir -p "$hint_dir"
  local hint="${hint_dir}/domain-profile.txt"
  echo "${DOMAIN_PROFILE}" > "$hint"
  log_ok "Domain profile: ${DOMAIN_PROFILE} (manifest: adapters/profiles/${DOMAIN_PROFILE}.yaml)"
  return 0
}
