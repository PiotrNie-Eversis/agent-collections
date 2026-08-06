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
- Customise **eversis-project-stack** for this repo.
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
}
