---
sidebar_position: 16
title: Creating role rules
---

# Creating role rules (`.mdc`)

**Folder:** `.cursor/skills/eversis-creating-agents/`  
**Used by:** Framework maintainers (customization track)

Build **Cursor project rules** — **`.cursor/rules/eversis-*.mdc`** — that define **role behavior** (who/when), not full workflows. Optional narrative docs: **`website/docs/agents/`**. This monorepo does **not** use `.github/agents/*.agent.md`.

## Principles

- **Separation of concerns** — Rules = stable role and boundaries; **skills** = HOW; **prompts** = runnable workflow under **`.cursor/prompts/`**.
- **XML-style sections** — The underlying skill may still use XML-like tags in the **body** for structure; YAML frontmatter is for Cursor (`description`, `globs`, `alwaysApply`).

## Rule structure (typical)

| Layer           | Purpose                                                              |
| --------------- | -------------------------------------------------------------------- |
| **Frontmatter** | `description`, `globs` or `alwaysApply`                              |
| **Role**        | Responsibilities, tone, when to stop for human review                |
| **Skills**      | Which `eversis-*` skills apply by name (references only)                 |
| **Tools**       | Behavioral guidance for MCP / terminal (not a declarative tool manifest in frontmatter) |

## Validation

- Not duplicating `eversis-agent-core.mdc` or stack rules
- Globs are minimal and accurate

## See also

- [Framework reference](../framework) — packaging and mappings (source: `documentation/agent-collection.md` on [GitHub](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/documentation/agent-collection.md))
