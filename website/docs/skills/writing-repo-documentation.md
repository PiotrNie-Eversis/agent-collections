---
sidebar_position: 34
title: Writing Repo Documentation
---

# Writing Repo Documentation

**Folder:** `.cursor/skills/eversis-writing-repo-documentation/`  
**Used by:** Repo Docs writer via [`eversis-repo-docs-writer`](../prompts/public/repo-docs-writer)

Authors and updates **repository** documentation without touching product code. README, CHANGELOG, in-repo `docs/`, and the published documentation site are the targets.

:::note Not BA Docs
For **Word `.docx`** maintenance, use [BA Docs planner](../prompts/public/ba-docs-planner) / [BA Docs writer](../prompts/public/ba-docs-writer) — not this skill.
:::

## Documentation Targets

| Target | Location | Conventions |
| --- | --- | --- |
| **README** | repo root and nested `README.md` | Plain Markdown; consistent with existing file |
| **CHANGELOG** | `CHANGELOG.md` | Append in existing format; do not rewrite history |
| **In-repo docs** | `docs/`, `docs/specs/`, `docs/context/` | Plain Markdown; follow neighbors |
| **Documentation site** | `website/docs/` | Docusaurus frontmatter; internal links must resolve |

## Process

1. **Identify target and audience** — Confirm documentation-only scope.
2. **Gather accurate facts** — Read code and config; verify paths and commands.
3. **Match neighboring structure** — Mirror sibling pages' frontmatter and headings.
4. **Write or update** — Stay within files named in the task; update plan checkboxes when delegated.
5. **Validate** — Run `validate-cursor-links` and `npm run build` when the docs site changes (see `eversis-project-stack.mdc`).

## Write vs. Review

This skill writes documentation; it does not perform code review. Report dependencies on product-code changes to the orchestrator.

## Connected Skills

- `eversis-technical-context-discovering` — project conventions before writing
- `eversis-codebase-analysing` — understand what the docs must describe
- `eversis-creating-instructions` — declarative rules vs narrative docs
