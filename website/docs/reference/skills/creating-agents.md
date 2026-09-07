---
sidebar_position: 16
title: Creating role rules
---

# Creating role rules (`.mdc`)

**Folder:** `.ai/skills/eversis-creating-agents/`  
**Used by:** Framework maintainers (customization track)

Build **role behavior rules** under **`.ai/rules/`** (SSOT — the Cursor adapter may emit **`.cursor/rules/eversis-*.mdc`**; the Claude Code adapter generates **`CLAUDE.md`**) that define **role behavior** (who/when), not full workflows. Optional narrative docs: **`website/docs/agents/`**. This monorepo does **not** use `.github/agents/*.agent.md`.

## Principles

- **Separation of concerns** — Rules = stable role and boundaries; **skills** = HOW; **prompts** = runnable workflow under **`.ai/prompts/`**.
- **XML-style sections** — The underlying skill may still use XML-like tags in the **body** for structure; YAML frontmatter (`description`, `globs`, `alwaysApply`) is what adapters key off of (e.g. Cursor's `.mdc`).

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

- [Framework reference](../../framework) — packaging and mappings (source: `documentation/agent-collection.md` on [GitHub](https://gitlab3.eversis.com/eversis-ai/agent-collections/-/blob/main/documentation/agent-collection.md))
