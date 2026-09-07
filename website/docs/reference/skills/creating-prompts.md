---
sidebar_position: 18
title: Creating prompts
---

# Creating prompts

**Folder:** `.ai/skills/eversis-creating-prompts/`  
**Used by:** Framework maintainers (customization track)

Create **attachable Markdown prompts** — **`.ai/prompts/public/eversis-*.md`** and **`internal/eversis-*.md`** — with Docusaurus frontmatter. Not `.github/prompts/*.prompt.md` (removed).

## Principles

- **Prompt** = workflow steps, artifacts, human gates, which rules to load (`.ai/rules/`; Cursor users may `@`-attach the adapter's `.mdc` form)
- **Rules** = `.ai/rules/` for stable behavior (SSOT; Cursor adapter emits `.cursor/rules/eversis-*.mdc`, Claude Code adapter generates `CLAUDE.md`)
- **Skills** = `.ai/skills/eversis-*/SKILL.md` for procedures

## Frontmatter (this site)

| Field | Purpose |
| --- | --- |
| `title`, `slug`, `sidebar_position` | Docs |
| `prompt_role`, `prompt_description` | Catalog |

## Validation

- Links to internal prompts use repo-relative paths
- No embedded stack constitution (use `AGENTS.md` / `eversis-project-stack.mdc`)

## See also

- [Prompts overview](../prompts/overview.md)
