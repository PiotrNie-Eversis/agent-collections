#!/usr/bin/env bash
# lib/setup-agent-collections/vendor.sh — --vendor submodule | copy.

readonly VENDOR_PATH="vendor/agent-collections"

_resolve_vendor_mode() {
  VENDOR_MODE="${ARG_VENDOR:-}"

  if [[ -z "$VENDOR_MODE" ]]; then
    return 0
  fi

  if [[ "$VENDOR_MODE" == "true" ]]; then
    if [[ "${ARG_NON_INTERACTIVE:-false}" == "true" ]]; then
      # Epik Q2: EOG default = submodule; non-interactive bare --vendor → submodule.
      VENDOR_MODE="submodule"
      log_info "--vendor without value in --non-interactive mode → defaulting to 'submodule'."
    else
      echo ""
      echo "${_BOLD}Select vendor strategy:${_RESET}"
      echo "  1) submodule — adds agent-collections as a Git submodule (recommended / EOG default)"
      echo "  2) copy      — copies framework files into vendor/ (no submodule)"
      echo ""
      local choice=""
      read -r -p "Enter choice [1]: " choice
      case "${choice:-1}" in
        2) VENDOR_MODE="copy" ;;
        *) VENDOR_MODE="submodule" ;;
      esac
    fi
  fi

  if [[ "$VENDOR_MODE" != "submodule" ]] && [[ "$VENDOR_MODE" != "copy" ]]; then
    die "--vendor must be 'submodule' or 'copy', got: '${VENDOR_MODE}'"
  fi
  export VENDOR_MODE
}

setup_vendor_submodule() {
  require_cmd git "Install Git from https://git-scm.com"
  local vendor_dir="${TARGET_DIR}/${VENDOR_PATH}"
  local repo_url="${AGENT_COLLECTIONS_REPO_URL:-${DEFAULT_REPO_URL:-}}"

  if [[ -z "$repo_url" ]]; then
    repo_url="$(git -C "${COLLECTIONS_HOME}" remote get-url origin 2>/dev/null)" \
      || die "Cannot determine repository URL. Set AGENT_COLLECTIONS_REPO_URL."
  fi

  if grep -q "path = ${VENDOR_PATH}" "${TARGET_DIR}/.gitmodules" 2>/dev/null; then
    log_ok "Submodule '${VENDOR_PATH}' already present — skipping add."
  else
    log_info "Adding submodule ${repo_url} → ${VENDOR_PATH} …"
    (cd "$TARGET_DIR" && git submodule add "$repo_url" "$VENDOR_PATH") \
      || die "git submodule add failed."
    log_ok "Submodule added: ${vendor_dir}"
  fi

  COLLECTIONS_HOME="$vendor_dir"
  export COLLECTIONS_HOME
}

setup_vendor_copy() {
  local vendor_dir="${TARGET_DIR}/${VENDOR_PATH}"
  local src_dirs=(
    ".ai"
    "adapters"
    "mcp/eversis-collections-mcp"
    "scripts"
    "templates"
    "docs/architecture"
  )

  log_info "Copying framework into ${vendor_dir} …"
  mkdir -p "$vendor_dir"

  local d
  for d in "${src_dirs[@]}"; do
    local src="${COLLECTIONS_HOME}/${d}"
    local dst="${vendor_dir}/${d}"
    if [[ ! -e "$src" ]]; then
      log_warn "Skip missing source: ${src}"
      continue
    fi
    mkdir -p "$(dirname "$dst")"
    if command -v rsync >/dev/null 2>&1; then
      rsync -a --delete --exclude=node_modules/ --exclude=.git/ --exclude=dist/ "$src/" "$dst/" 2>/dev/null \
        || rsync -a --exclude=node_modules/ --exclude=.git/ --exclude=dist/ "$src" "$(dirname "$dst")/"
    else
      rm -rf "$dst"
      cp -R "$src" "$dst"
    fi
  done

  # Preserve package.json for sync scripts when present.
  if [[ -f "${COLLECTIONS_HOME}/package.json" ]]; then
    cp "${COLLECTIONS_HOME}/package.json" "${vendor_dir}/package.json"
  fi

  COLLECTIONS_HOME="$vendor_dir"
  export COLLECTIONS_HOME
  log_ok "Vendor copy ready at ${vendor_dir}"
}

run_vendor_setup() {
  _resolve_vendor_mode
  case "${VENDOR_MODE:-}" in
    submodule) setup_vendor_submodule ;;
    copy) setup_vendor_copy ;;
    *) log_info "Vendor mode: local (framework outside target)." ;;
  esac
  return 0
}
