---
sidebar_position: 19
title: Creating Instructions
---

# Creating instructions

**Folder:** `.cursor/skills/eversis-creating-instructions/`  
**Used by:** Framework maintainers (customization track)

Helps place **declarative rules** for **Cursor**: **[AGENTS.md](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/AGENTS.md)**, **`.cursor/rules/eversis-*.mdc`**, and optional scoped rules — not legacy repo-root instruction files outside **`.cursor/`**.

## Instruction types (Cursor)

| Aspect            | Project constitution                                  | Scoped                                                    |
| ----------------- | ----------------------------------------------------- | --------------------------------------------------------- |
| **Typical files** | `AGENTS.md` + `eversis-project-stack.mdc`             | `eversis-*.mdc` with `globs` (or team `RULE.md` patterns) |
| **Frontmatter**   | Rules use YAML: `description`, `globs`, `alwaysApply` | Same                                                      |
| **Applied when**  | Always-on or stack-wide                               | When matching files are in context                        |

## Instructions vs skills

| Content                                   | Belongs in…                         |
| ----------------------------------------- | ----------------------------------- |
| Stack, commands, non-obvious global rules | `AGENTS.md` / `.mdc`                |
| Step-by-step procedures                   | `SKILL.md` under `.ai/skills/` |
| Runnable workflow text                    | `.ai/prompts/**/eversis-*.md` (optional `/eversis-*` slash shim) |

## Validation checklist

- No duplicated always-on rules across many `.mdc` files
- No long procedural content (use skills)
- Templates: see `.cursor/skills/eversis-creating-instructions/assets/`

## Connected skills

- `eversis-creating-agents` — role rules vs long prose
- `eversis-creating-skills` — instruction vs skill boundary
- `eversis-creating-prompts` — prompts reference rules, not duplicate them
