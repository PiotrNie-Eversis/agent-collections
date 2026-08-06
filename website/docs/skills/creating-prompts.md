---
sidebar_position: 18
title: Creating prompts
---

# Creating prompts

**Folder:** `.cursor/skills/eversis-creating-prompts/`  
**Used by:** Framework maintainers (customization track)

Create **attachable Markdown prompts** — **`.cursor/prompts/public/eversis-*.md`** and **`internal/eversis-*.md`** — with Docusaurus frontmatter. Not `.github/prompts/*.prompt.md` (removed).

## Principles

- **Prompt** = workflow steps, artifacts, human gates, `@` paths for rules to attach
- **Rules** = `.cursor/rules/eversis-*.mdc` for stable behavior
- **Skills** = `.cursor/skills/eversis-*/SKILL.md` for procedures

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
