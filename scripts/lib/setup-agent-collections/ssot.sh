#!/usr/bin/env bash
# lib/setup-agent-collections/ssot.sh — domain-context SSOT scaffolding + best-effort
# initial seed (Question 3 / Question 13, global-domain-context-ssot.research.md).
#
# Two independent steps, both idempotent:
#   1. scaffold_ssot_project — always creates docs/context/<project>/INDEX.md.
#   2. seed_ssot_global      — if ARG_SSOT_SOURCE is set, best-effort `git subtree add`
#                              into docs/context/global/. Never blocks the install on
#                              failure (offline, unreachable remote, no branch yet) —
#                              only warns with the exact recovery command.

# Lower-case, kebab-case $1 (the same rule for every slug source below).
_ssot_kebab() {
  printf '%s\n' "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//'
}

# The slug recorded in install-selection.json (ssot.projectContextPath =
# docs/context/<slug>/), so an upgrade scaffolds the folder the record names
# instead of a second one. Prints nothing when there is no usable record.
_ssot_recorded_slug() {
  local sel="${TARGET_DIR}/.agent-collections/install-selection.json"
  [[ -f "$sel" ]] || return 0
  command -v node >/dev/null 2>&1 || return 0
  node -e '
    let j;
    try { j = JSON.parse(require("fs").readFileSync(process.argv[1], "utf8")); } catch { process.exit(0); }
    const p = j && j.ssot && j.ssot.projectContextPath;
    const m = typeof p === "string" ? p.trim().match(/^docs\/context\/([^/]+)\/?$/) : null;
    if (m) process.stdout.write(m[1]);
  ' "$sel" 2>/dev/null || true
}

# When TARGET_DIR is the toplevel of a *linked* git worktree (git
# worktree add ../proj-feature), print the main worktree's folder name, so
# every worktree of one project shares docs/context/<project>/. A linked
# worktree has a --git-dir (…/.git/worktrees/<name>) different from its
# --git-common-dir. A target below the toplevel (monorepo package) keeps its own
# basename: that name is the same in every worktree. Prints nothing otherwise
# (not a repo, no git, main worktree, subdirectory).
_ssot_linked_worktree_main_name() {
  command -v git >/dev/null 2>&1 || return 0
  local git_dir common_dir top target
  git_dir="$(git -C "$TARGET_DIR" rev-parse --git-dir 2>/dev/null)" || return 0
  common_dir="$(git -C "$TARGET_DIR" rev-parse --git-common-dir 2>/dev/null)" || return 0
  top="$(git -C "$TARGET_DIR" rev-parse --show-toplevel 2>/dev/null)" || return 0
  # Relative results (older git, Git Bash) are relative to TARGET_DIR.
  git_dir="$(cd "$TARGET_DIR" && cd "$git_dir" 2>/dev/null && pwd -P)" || return 0
  common_dir="$(cd "$TARGET_DIR" && cd "$common_dir" 2>/dev/null && pwd -P)" || return 0
  top="$(cd "$top" 2>/dev/null && pwd -P)" || return 0
  target="$(cd "$TARGET_DIR" && pwd -P)" || return 0
  [[ "$git_dir" != "$common_dir" ]] || return 0
  [[ "$top" == "$target" ]] || return 0
  local name
  if [[ "$(basename "$common_dir")" == ".git" ]]; then
    name="$(basename "$(dirname "$common_dir")")"
  else
    # Bare main repository: <name>.git or <name>; a hidden bare dir
    # (proj/.bare, the "bare repo + worktrees" layout) names its parent.
    name="$(basename "$common_dir")"
    case "$name" in
      .*) name="$(basename "$(dirname "$common_dir")")" ;;
      *) name="${name%.git}" ;;
    esac
  fi
  printf '%s' "$name"
}

_ssot_project_slug() {
  # Precedence: explicit --project-name → SSOT_PROJECT_SLUG env
  # (explicit, kept for compatibility) → the recorded ssot.projectContextPath
  # → the main worktree's name when TARGET_DIR is a linked worktree's toplevel
  # → the target dir's basename. Every derived name is lower-cased and
  # kebab-cased. The basename mirrors how <project> already resolves for
  # docs/context/<project>/task-baseline.md (Jira key or workshop folder name) —
  # here there is no Jira key at install time, so the repo's own name is the
  # closest stable, install-time-available equivalent.
  if [[ "${ARG_PROJECT_NAME_PASSED:-false}" == "true" ]] && [[ -n "${ARG_PROJECT_NAME:-}" ]]; then
    _ssot_kebab "$ARG_PROJECT_NAME"
    return 0
  fi
  if [[ -n "${SSOT_PROJECT_SLUG:-}" ]]; then
    local from_env
    from_env="$(_ssot_kebab "$SSOT_PROJECT_SLUG")"
    if [[ -n "$from_env" ]]; then
      echo "$from_env"
      return 0
    fi
  fi
  local recorded
  recorded="$(_ssot_recorded_slug)"
  if [[ -n "$recorded" ]]; then
    echo "$recorded"
    return 0
  fi
  local main_name
  main_name="$(_ssot_linked_worktree_main_name)"
  if [[ -n "$main_name" ]]; then
    main_name="$(_ssot_kebab "$main_name")"
    if [[ -n "$main_name" ]]; then
      # stderr: stdout is the slug the caller captures.
      log_info "Using main project name '${main_name}' for docs/context/ (linked worktree '$(basename "$TARGET_DIR")'; pass --project-name to override)." >&2
      echo "$main_name"
      return 0
    fi
  fi
  _ssot_kebab "$(basename "${TARGET_DIR}")"
}

scaffold_ssot_project() {
  # An explicit name (--project-name, or SSOT_PROJECT_SLUG set before
  # this run) is also written to the record by write_install_selection, so the
  # scaffolded folder and ssot.projectContextPath never disagree. Decided here,
  # before SSOT_PROJECT_SLUG is overwritten with the resolved slug below.
  SSOT_PROJECT_NAME_EXPLICIT="false"
  if { [[ "${ARG_PROJECT_NAME_PASSED:-false}" == "true" ]] && [[ -n "$(_ssot_kebab "${ARG_PROJECT_NAME:-}")" ]]; } || \
     [[ -n "$(_ssot_kebab "${SSOT_PROJECT_SLUG:-}")" ]]; then
    SSOT_PROJECT_NAME_EXPLICIT="true"
  fi
  export SSOT_PROJECT_NAME_EXPLICIT
  local slug
  slug="$(_ssot_project_slug)"
  export SSOT_PROJECT_SLUG="$slug"

  local dir="${TARGET_DIR}/docs/context/${slug}"
  local index="${dir}/INDEX.md"
  mkdir -p "$dir"

  if [[ -f "$index" ]]; then
    log_info "docs/context/${slug}/INDEX.md already exists — not overwritten (project-owned)."
    return 0
  fi

  cat > "$index" <<INDEX_EOF
# ${slug} — domain knowledge index

One line per component. Keep this file small (~200 lines) — full description lives in
each component's own \`index.md\`, never here.

| Component | One-line summary |
|---|---|
INDEX_EOF
  log_ok "Created docs/context/${slug}/INDEX.md."
}

seed_ssot_global() {
  local repo="${ARG_SSOT_SOURCE:-}"
  if [[ -z "$repo" ]]; then
    log_info "No --ssot-source given — skipping domain-context seed (docs/context/global/ will not exist until eversis_context_sync is run manually)."
    return 0
  fi

  local branch="${ARG_SSOT_BRANCH:-main}"
  local prefix="docs/context/global"
  local target_dir="${TARGET_DIR}/${prefix}"

  if [[ -d "$target_dir" ]]; then
    log_info "${prefix}/ already exists — not re-seeding (run eversis_context_sync to refresh)."
    return 0
  fi

  if ! command -v git >/dev/null 2>&1; then
    log_warn "git not found — cannot seed domain-context. Recover later with:"
    log_warn "  git -C \"${TARGET_DIR}\" subtree add --prefix=${prefix} \"${repo}\" \"${branch}\" --squash"
    return 0
  fi

  if ! git -C "${TARGET_DIR}" ls-remote --exit-code "$repo" "$branch" >/dev/null 2>&1; then
    log_warn "domain-context (${repo}) is unreachable right now — installation continues without it."
    log_warn "Once you have access, run:"
    log_warn "  git -C \"${TARGET_DIR}\" subtree add --prefix=${prefix} \"${repo}\" \"${branch}\" --squash"
    return 0
  fi

  if git -C "${TARGET_DIR}" subtree add --prefix="$prefix" "$repo" "$branch" --squash >/dev/null 2>&1; then
    log_ok "Seeded ${prefix}/ from ${repo} (${branch})."
  else
    log_warn "git subtree add failed — installation continues without domain-context."
    log_warn "Recover with:"
    log_warn "  git -C \"${TARGET_DIR}\" subtree add --prefix=${prefix} \"${repo}\" \"${branch}\" --squash"
  fi
  return 0
}

# Phase 4 / Question 1 / Question 7: --confluence-space-key is optional and never
# blocks. The installer only records the key for later reference — it never calls
# Confluence itself (that happens via the atlassian MCP, inside an agent session
# running the eversis-import-confluence-knowledge skill, manually, when the human
# chooses to).
note_confluence_space_key() {
  local key="${ARG_CONFLUENCE_SPACE_KEY:-}"
  if [[ -z "$key" ]]; then
    log_info "No --confluence-space-key given — starting empty; run the eversis-import-confluence-knowledge skill later to seed from Confluence."
    return 0
  fi
  log_ok "Recorded Confluence space key '${key}' — run the eversis-import-confluence-knowledge skill in an agent session to import it (not run automatically by this installer)."
  return 0
}
