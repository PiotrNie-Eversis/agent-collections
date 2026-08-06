#!/usr/bin/env bash
# lib/setup-cursor-local/git-target.sh — detect git root, resolve target dir.
# Sourced after common.sh.

resolve_target_dir() {
  # Sets global TARGET_DIR (absolute path, must be a directory).
  # Priority: --target CLI arg > interactive prompt > git root > cwd.

  local cli_target="${ARG_TARGET:-}"

  if [[ -n "$cli_target" ]]; then
    TARGET_DIR="$(cd "$cli_target" && pwd)" || die "Cannot access --target directory: ${cli_target}"
    export TARGET_DIR
    return 0
  fi

  require_cmd git "Install Git from https://git-scm.com"

  local git_root
  git_root="$(git rev-parse --show-toplevel 2>/dev/null)" || true

  if [[ -z "$git_root" ]]; then
    log_warn "Not inside a git repository — using current directory as target."
    TARGET_DIR="$(pwd)"
    export TARGET_DIR
    return 0
  fi

  local cwd
  cwd="$(pwd)"

  # If we're already at the root, no prompt needed.
  if [[ "$cwd" == "$git_root" ]]; then
    TARGET_DIR="$git_root"
    export TARGET_DIR
    return 0
  fi

  # Monorepo case: cwd is a sub-directory of the repo root.
  if [[ "${ARG_NON_INTERACTIVE:-false}" == "true" ]]; then
    log_info "Monorepo detected — using git root (--non-interactive): ${git_root}"
    TARGET_DIR="$git_root"
    export TARGET_DIR
    return 0
  fi

  # Interactive prompt (default timeout 10 s → option 1).
  echo ""
  echo "${_BOLD}Monorepo detected.${_RESET} Where should cursor-collections be installed?"
  echo "  1) Repository root (recommended): ${git_root}"
  echo "  2) Current directory:              ${cwd}"
  echo ""

  local choice=""
  if read -r -t 10 -p "Enter choice [1]: " choice 2>/dev/null; then
    : # user typed something
  else
    echo ""
    log_info "No input — defaulting to repository root."
    choice="1"
  fi

  case "${choice:-1}" in
    2) TARGET_DIR="$cwd" ;;
    *) TARGET_DIR="$git_root" ;;
  esac
  export TARGET_DIR
}
