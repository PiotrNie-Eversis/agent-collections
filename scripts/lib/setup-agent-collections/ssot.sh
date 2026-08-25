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

_ssot_project_slug() {
  # Prefer an explicit override; otherwise derive from the target dir's basename,
  # lower-cased and kebab-cased. This mirrors how <project> already resolves for
  # docs/context/<project>/task-baseline.md (Jira key or workshop folder name) —
  # here there is no Jira key at install time, so the repo's own name is the
  # closest stable, install-time-available equivalent.
  if [[ -n "${SSOT_PROJECT_SLUG:-}" ]]; then
    echo "$SSOT_PROJECT_SLUG"
    return 0
  fi
  local base
  base="$(basename "${TARGET_DIR}")"
  echo "$base" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//'
}

scaffold_ssot_project() {
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
