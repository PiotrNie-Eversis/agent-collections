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

  if [[ ! -d "$specs_dir" ]]; then
    mkdir -p "$specs_dir"
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
    log_ok "Created docs/specs/ directory."
  fi

  for d in docs/context docs/plans; do
    if [[ ! -d "${target}/${d}" ]]; then
      mkdir -p "${target}/${d}"
    fi
  done

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
    {
      echo "@AGENTS.md"
      echo ""
      cat "$template"
    } > "$claude_md_dst"
  else
    cp "$template" "$claude_md_dst"
  fi
  log_ok "Created .claude/CLAUDE.md — review and customise for your project."
}
