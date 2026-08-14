#!/usr/bin/env bash
# lib/setup-agent-collections/scaffolding.sh

scaffold_project() {
  local target="$TARGET_DIR"
  local agents_dst="${target}/AGENTS.md"
  local specs_dir="${target}/docs/specs"
  local specs_readme="${specs_dir}/README.md"

  if [[ ! -f "$agents_dst" ]]; then
    local agents_src="${COLLECTIONS_HOME}/templates/AGENTS.template.md"
    if [[ -f "$agents_src" ]]; then
      cp "$agents_src" "$agents_dst"
    else
      cat > "$agents_dst" <<'AGENTS_EOF'
# Agent instructions

This project uses Agent Collections (`.ai/` SSOT via `AGENT_COLLECTIONS_HOME` / vendor).

- Enable MCP server **eversis-collections**.
- Cursor: customise **`.cursor/rules/eversis-project-stack.mdc`**.
- Claude Code: customise **`.claude/CLAUDE.md`** (do not hand-edit generated `CLAUDE.md`) — Claude Code does not read this `AGENTS.md` file on its own unless `.claude/CLAUDE.md` imports it with `@AGENTS.md`.
- Delivery Standard: Research → Plan → Implement → Review → Fine under `docs/specs/<issue-kebab>/`.
AGENTS_EOF
    fi
    log_ok "Created AGENTS.md — review and customise for your project."
  else
    log_info "AGENTS.md already exists — not overwritten (project-owned)."
  fi

  mkdir -p "$specs_dir"
  if [[ ! -f "$specs_readme" ]]; then
    cat > "$specs_readme" <<'README_EOF'
# specs

Feature research and implementation plan artifacts for this project.

Naming convention: `docs/specs/<issue-kebab>/`

```
docs/specs/my-feature/
  my-feature.research.md
  my-feature.plan.md
```
README_EOF
    log_ok "Created docs/specs/README.md."
  fi

  local context_dir="${target}/docs/context"
  local context_readme="${context_dir}/README.md"
  mkdir -p "$context_dir"
  if [[ ! -f "$context_readme" ]]; then
    cat > "$context_readme" <<'README_EOF'
# context

Internal knowledge for this project: architecture notes, ADRs, wiki sync exports, onboarding. Use clear filenames under `docs/context/<project>/`.

**Task baseline (workshop continuity):** `docs/context/<project>/task-baseline.md` — optional epic/story index refreshed after a successful Jira push from prompt `eversis-analyze-materials`.

Referenced by research/plan steps. Attach it by path in your tool (e.g. Cursor `@docs/context/<project>/`).

Part of the project deliverables triad with [`docs/plans/`](../plans/) and [`docs/specs/`](../specs/).

By default this folder is committed like any other project doc. Projects installed with `--gitignore-agent-artifacts` gitignore `docs/context/*/` subfolders instead (local baselines/exports stay off git); only this `README.md` stays tracked in that mode.
README_EOF
    log_ok "Created docs/context/README.md."
  fi

  local plans_dir="${target}/docs/plans"
  local plans_readme="${plans_dir}/README.md"
  mkdir -p "$plans_dir"
  if [[ ! -f "$plans_readme" ]]; then
    cat > "$plans_readme" <<'README_EOF'
# plans

Optional location for **flat implementation plans** as `*.md` files (scope, rationale, steps, risks).

Prefer the Implement workflow under `docs/specs/<issue-kebab>/*.plan.md` (with `*.research.md` / `*.plan-review.md`) — see [`docs/specs/README.md`](../specs/README.md).

Use `docs/plans/` only for legacy or ad-hoc flat plans when the team chooses not to use a specs folder.
README_EOF
    log_ok "Created docs/plans/README.md."
  fi

  _seed_claude_project_md "$target" "$agents_dst"
}

# Consumer-owned Claude Code surface — the .claude/CLAUDE.md analog of
# Cursor's eversis-project-stack.mdc (closes F7: root CLAUDE.md is
# regenerated every sync run, so it can never safely hold consumer stack
# notes; AGENTS.md is not auto-read by Claude Code unless imported).
_seed_claude_project_md() {
  local target="$1" agents_dst="$2"
  if ! echo ",${SELECTED_AGENTS:-}," | grep -q ',claude,'; then
    return 0
  fi

  local claude_md_dst="${target}/.claude/CLAUDE.md"
  if [[ -f "$claude_md_dst" ]]; then
    log_info ".claude/CLAUDE.md already exists — not overwritten (project-owned)."
    return 0
  fi

  local template="${COLLECTIONS_HOME}/templates/claude-CLAUDE.template.md"
  [[ -f "$template" ]] || { log_warn "No .claude/CLAUDE.md template found — create ${claude_md_dst} manually."; return 0; }

  mkdir -p "$(dirname "$claude_md_dst")"
  if [[ -f "$agents_dst" ]]; then
    # Claude Code resolves @-imports relative to the FILE containing the
    # import, not the working directory (confirmed against code.claude.com/
    # docs/en/memory) — .claude/CLAUDE.md lives one level below the repo
    # root where AGENTS.md lives, so the import must be @../AGENTS.md, not
    # the bare @AGENTS.md that would resolve to a nonexistent .claude/AGENTS.md.
    {
      echo "@../AGENTS.md"
      echo ""
      cat "$template"
    } > "$claude_md_dst"
  else
    cp "$template" "$claude_md_dst"
  fi
  log_ok "Created .claude/CLAUDE.md — review and customise for your project."
}
