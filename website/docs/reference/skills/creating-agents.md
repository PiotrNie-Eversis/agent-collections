---
sidebar_position: 16
title: Creating role rules
---

# Creating role rules

**Folder:** `.ai/skills/eversis-creating-agents/`  
**Used by:** Framework maintainers (customization track)

Build **role behavior rules** under **`.ai/rules/`** (SSOT — the Cursor adapter may emit **`.cursor/rules/eversis-*.mdc`**; the Claude Code adapter generates **`CLAUDE.md`**) that define **role behavior** (who/when), not full workflows. Optional narrative docs: **`website/docs/agents/`**. This monorepo does **not** use `.github/agents/*.agent.md`.

## Principles

- **Separation of concerns** — Rules = stable role and boundaries; **skills** = HOW; **prompts** = runnable workflow under **`.ai/prompts/`**.
- **XML-style sections** — The underlying skill may still use XML-like tags in the **body** for structure; rule files have no frontmatter: `description` and the activation (`alwaysApply`, `globs`, on demand) live in the rule's entry in the adapters' `rule-map.yaml` files, and the Cursor adapter writes them into the generated `.mdc`.

## Rule structure (typical)

| Layer           | Purpose                                                                                 |
| --------------- | --------------------------------------------------------------------------------------- |
| **Heading**     | `# <Role>` — the file `.ai/rules/<area>/<role>.md` has no `eversis-` prefix and no frontmatter |
| **Role**        | Responsibilities, tone, when to stop for human review                                   |
| **Skills**      | Which `eversis-*` skills apply by name (references only)                                |
| **Tools**       | Behavioral guidance for MCP / terminal (not a declarative tool manifest in frontmatter) |

## Validation

- Not duplicating `eversis-agent-core.mdc` or stack rules
- Globs are minimal and accurate
- Registered in `adapters/cursor/rule-map.yaml`, `adapters/claude/rule-map.yaml` and `adapters/pi/rule-map.yaml` (same `id` and `source`), then `npm run sync:adapters` and `npm run sync:adapters:check`; the check fails on a rule file under `.ai/rules/` that no map lists (unless `adapters/rules-not-emitted.yaml` lists it with a reason), and you still confirm the rule appears in each host output

## See also

- [Framework reference](../../framework) — packaging and mappings
