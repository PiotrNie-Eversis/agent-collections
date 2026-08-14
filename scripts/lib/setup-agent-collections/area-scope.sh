#!/usr/bin/env bash
# lib/setup-agent-collections/area-scope.sh — monorepo area profiles (TASK-530).

apply_area_scope() {
  # Map domain profile → default area scope id (isolation §5).
  local area_id="fullstack"
  case "${DOMAIN_PROFILE:-fullstack}" in
    frontend) area_id="frontend-scope" ;;
    backend) area_id="backend-scope" ;;
    fullstack) area_id="fullstack" ;;
  esac

  local area_manifest="${COLLECTIONS_HOME}/adapters/profiles/area-${area_id}.yaml"
  # fullstack area file may be named area-fullstack.yaml
  if [[ ! -f "$area_manifest" ]]; then
    area_manifest="${COLLECTIONS_HOME}/adapters/profiles/area-${area_id//-scope/}.yaml"
  fi
  if [[ "$area_id" == "fullstack" ]]; then
    area_manifest="${COLLECTIONS_HOME}/adapters/profiles/area-fullstack.yaml"
  elif [[ "$area_id" == "frontend-scope" ]]; then
    area_manifest="${COLLECTIONS_HOME}/adapters/profiles/area-frontend-scope.yaml"
  elif [[ "$area_id" == "backend-scope" ]]; then
    area_manifest="${COLLECTIONS_HOME}/adapters/profiles/area-backend-scope.yaml"
  fi

  [[ -f "$area_manifest" ]] || die "Area profile missing: ${area_manifest}"

  mkdir -p "${TARGET_DIR}/.agent-collections"
  echo "${area_id}" > "${TARGET_DIR}/.agent-collections/area-profile.txt"
  cp "$area_manifest" "${TARGET_DIR}/.agent-collections/area-profile.yaml"

  # Apply exclude patterns into consumer ignore files (merge, never wipe).
  require_cmd node "Install Node.js ≥ 18"
  node "${LIB_DIR}/apply-area-ignore.mjs" \
    --target "${TARGET_DIR}" \
    --area-manifest "$area_manifest" \
    --agents "${SELECTED_AGENTS:-cursor}" \
    || die "Failed to apply area ignore patterns."

  # Claude guidance snippet when claude selected
  if echo ",${SELECTED_AGENTS:-}," | grep -q ',claude,'; then
    _append_claude_area_guidance "$area_id"
  fi

  AREA_PROFILE_ID="$area_id"
  export AREA_PROFILE_ID
  log_ok "Area profile: ${area_id}"
  return 0
}

_append_claude_area_guidance() {
  local area_id="$1"
  local claude="${TARGET_DIR}/CLAUDE.md"
  [[ -f "$claude" ]] || return 0
  if grep -q "<!-- agent-collections-area-scope -->" "$claude" 2>/dev/null; then
    # Refresh block
    local tmp
    tmp="$(mktemp)"
    awk '/<!-- agent-collections-area-scope -->/{skip=1} /<!-- \/agent-collections-area-scope -->/{skip=0; next} !skip{print}' "$claude" > "$tmp"
    mv "$tmp" "$claude"
  fi
  {
    echo ""
    echo "<!-- agent-collections-area-scope -->"
    echo "## Area scope (${area_id})"
    echo ""
    case "$area_id" in
      frontend-scope)
        echo "Prefer \`apps/web/**\`, shared packages, \`docs/**\`, \`scripts/**\`. De-emphasize \`apps/api/**\` and heavy infra."
        ;;
      backend-scope)
        echo "Prefer \`apps/api/**\`, shared packages, \`docs/**\`, \`scripts/**\`. De-emphasize \`apps/web/**\` and heavy infra."
        ;;
      *)
        echo "Fullstack scope: \`apps/web/**\` + \`apps/api/**\` + light shared. Exclude heavy infra by default."
        ;;
    esac
    echo "<!-- /agent-collections-area-scope -->"
  } >> "$claude"
}
