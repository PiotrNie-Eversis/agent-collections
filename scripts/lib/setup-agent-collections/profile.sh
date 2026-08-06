#!/usr/bin/env bash
# lib/setup-agent-collections/profile.sh — domain profile axis (manifest-driven).

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
