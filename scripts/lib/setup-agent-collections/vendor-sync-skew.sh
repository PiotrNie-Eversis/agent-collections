#!/usr/bin/env bash
# lib/setup-agent-collections/vendor-sync-skew.sh — probe vendored adapters/sync.mjs
# for flags the launched installer will pass; align a clean submodule or die.
#
# Sourced by setup-agent-collections.sh after link-framework.sh (uses
# _resolve_framework_prefix at runtime). Never git checkout --force / reset --hard.

# Extra CLI flag *names* _run_adapter_sync will append (not values).
# Tests may set ADAPTER_SYNC_EXTRA_FLAGS=(--framework-prefix) to bypass prefix resolve.
_adapter_sync_extra_flag_names() {
  if declare -p ADAPTER_SYNC_EXTRA_FLAGS >/dev/null 2>&1; then
    local f
    for f in "${ADAPTER_SYNC_EXTRA_FLAGS[@]}"; do
      [[ -n "$f" ]] && printf '%s\n' "$f"
    done
    return 0
  fi
  local prefix=""
  if declare -F _resolve_framework_prefix >/dev/null 2>&1; then
    prefix="$(_resolve_framework_prefix)" || true
  fi
  if [[ -n "$prefix" ]]; then
    printf '%s\n' "--framework-prefix"
  fi
}

# True if vendored sync.mjs documents/accepts the flag (--help, else source grep).
_sync_mjs_supports_flag() {
  local sync_mjs="$1"
  local flag="$2"
  [[ -f "$sync_mjs" ]] || return 1
  if command -v node >/dev/null 2>&1; then
    if node "$sync_mjs" --help 2>/dev/null | grep -F -- "$flag" >/dev/null 2>&1; then
      return 0
    fi
    return 1
  fi
  grep -F -- "$flag" "$sync_mjs" >/dev/null 2>&1
}

_vendor_sync_worktree_dirty() {
  local vendor_dir="$1"
  local porcelain
  porcelain="$(git -C "$vendor_dir" status --porcelain 2>/dev/null || true)"
  [[ -n "$porcelain" ]]
}

_installer_framework_sha() {
  git -C "${INSTALLER_FRAMEWORK_HOME}" rev-parse HEAD
}

_vendor_sync_skew_message() {
  local flag="$1"
  local reason="$2"
  local installer_sha="${3:-unknown}"
  local vendor_sha="${4:-unknown}"
  local installer_home="${INSTALLER_FRAMEWORK_HOME:-unknown}"
  local vendor_home="${COLLECTIONS_HOME:-unknown}"

  cat <<EOF
The vendor submodule is behind the launched installer.

  Launched installer: ${installer_home} (${installer_sha})
  Vendored pin:       ${vendor_home} (${vendor_sha})
  Rejected CLI flag:  ${flag}
  Reason:             ${reason}

The launched installer will pass ${flag} into adapters/sync.mjs, but the
vendored copy does not accept it. Stopping before Node prints
"unknown argument". Will not git checkout --force or reset --hard.

Recover (from the consumer repo):
  git -C "${vendor_home}" fetch origin
  git -C "${vendor_home}" checkout ${installer_sha}
  git add vendor/agent-collections

Then re-run:
  bash "\${AGENT_COLLECTIONS_HOME}/scripts/setup-agent-collections.sh" --upgrade --sync --non-interactive
EOF
}

# Attempt checkout of installer HEAD in COLLECTIONS_HOME.
# Returns 0 if checkout succeeded (or SHA already at HEAD).
# Returns 1 if dirty (no checkout). Dies on missing git / missing SHA after fetch.
_align_clean_vendor_to_installer_head() {
  local vendor_dir="${COLLECTIONS_HOME}"
  local flag="$1"
  local installer_sha vendor_sha

  if [[ -z "${INSTALLER_FRAMEWORK_HOME:-}" ]]; then
    die "INSTALLER_FRAMEWORK_HOME is unset — cannot align submodule sync.mjs."
  fi
  if ! git -C "$INSTALLER_FRAMEWORK_HOME" rev-parse --git-dir >/dev/null 2>&1; then
    installer_sha="unknown"
    vendor_sha="$(git -C "$vendor_dir" rev-parse HEAD 2>/dev/null || echo unknown)"
    die "$(_vendor_sync_skew_message "$flag" "launched installer is not a git directory" "$installer_sha" "$vendor_sha")"
  fi
  installer_sha="$(_installer_framework_sha)"

  if ! git -C "$vendor_dir" rev-parse --git-dir >/dev/null 2>&1; then
    die "$(_vendor_sync_skew_message "$flag" "vendor path is not a git directory" "$installer_sha" "unknown")"
  fi
  vendor_sha="$(git -C "$vendor_dir" rev-parse HEAD 2>/dev/null || echo unknown)"

  if _vendor_sync_worktree_dirty "$vendor_dir"; then
    return 1
  fi

  if [[ "$vendor_sha" == "$installer_sha" ]]; then
    return 0
  fi

  if ! git -C "$vendor_dir" cat-file -t "$installer_sha" >/dev/null 2>&1; then
    log_info "Fetching ${installer_sha} into submodule ${vendor_dir} …"
    if ! git -C "$vendor_dir" fetch origin "$installer_sha" 2>/dev/null; then
      if ! git -C "$vendor_dir" fetch origin; then
        die "$(_vendor_sync_skew_message "$flag" "SHA missing from vendor object db and git fetch origin failed" "$installer_sha" "$vendor_sha")"
      fi
    fi
  fi

  if ! git -C "$vendor_dir" cat-file -t "$installer_sha" >/dev/null 2>&1; then
    die "$(_vendor_sync_skew_message "$flag" "SHA still missing after git fetch origin" "$installer_sha" "$vendor_sha")"
  fi

  git -C "$vendor_dir" checkout "$installer_sha" \
    || die "$(_vendor_sync_skew_message "$flag" "git checkout failed (not forced)" "$installer_sha" "$vendor_sha")"
  log_ok "Aligned vendor submodule ${vendor_dir} to launched installer SHA ${installer_sha}."
  return 0
}

# Product guard: on --upgrade/--sync + submodule, never call an old sync.mjs with new flags.
align_vendor_sync_cli_or_die() {
  [[ "${VENDOR_MODE:-}" == "submodule" ]] || return 0
  [[ "${ARG_UPGRADE:-false}" == "true" || "${ARG_SYNC:-false}" == "true" ]] || return 0

  local -a flags=()
  local line
  while IFS= read -r line; do
    [[ -n "$line" ]] && flags+=("$line")
  done < <(_adapter_sync_extra_flag_names)
  [[ ${#flags[@]} -gt 0 ]] || return 0

  local sync_mjs="${COLLECTIONS_HOME}/adapters/sync.mjs"
  local -a missing=()
  local f
  for f in "${flags[@]}"; do
    if ! _sync_mjs_supports_flag "$sync_mjs" "$f"; then
      missing+=("$f")
    fi
  done
  [[ ${#missing[@]} -eq 0 ]] && return 0

  local flag_list="${missing[*]}"
  local installer_sha vendor_sha
  installer_sha="$(git -C "${INSTALLER_FRAMEWORK_HOME:-/}" rev-parse HEAD 2>/dev/null || echo unknown)"
  vendor_sha="$(git -C "${COLLECTIONS_HOME:-/}" rev-parse HEAD 2>/dev/null || echo unknown)"

  if _align_clean_vendor_to_installer_head "$flag_list"; then
    # Re-probe after align; still missing → die (wrong SHA / fetch of an old tree).
    missing=()
    for f in "${flags[@]}"; do
      if ! _sync_mjs_supports_flag "${COLLECTIONS_HOME}/adapters/sync.mjs" "$f"; then
        missing+=("$f")
      fi
    done
    if [[ ${#missing[@]} -eq 0 ]]; then
      return 0
    fi
    flag_list="${missing[*]}"
    die "$(_vendor_sync_skew_message "$flag_list" "aligned pin still lacks flag" "$installer_sha" "$(git -C "${COLLECTIONS_HOME}" rev-parse HEAD 2>/dev/null || echo unknown)")"
  fi

  die "$(_vendor_sync_skew_message "$flag_list" "dirty vendor worktree — commit or stash, then checkout" "$installer_sha" "$vendor_sha")"
}
