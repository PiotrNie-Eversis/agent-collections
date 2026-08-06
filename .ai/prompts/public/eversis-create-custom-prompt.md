---
sidebar_position: 15
title: "Create custom prompt"
slug: create-custom-prompt
prompt_role: "Cursor customization orchestrator"
prompt_description: "Create a new attachable prompt as .ai/prompts/public|internal/eversis-*.md with Docusaurus frontmatter. Analyzes existing prompts for patterns and validates using eversis-creating-prompts."
---
# eversis-create-custom-prompt

**Role:** [Cursor customization orchestrator](../../../website/docs/agents/cursor-customization-orchestrator.md)  
**File:** `.ai/prompts/public/eversis-create-custom-prompt.md`

Creates a **new Markdown prompt** in **`.ai/prompts/public/`** (or **`internal/`** if orchestration-only). Prompts in this framework are **attachable files**, not Copilot `*.prompt.md` or slash-command shims.

## Usage

```text
eversis-create-custom-prompt
<prompt requirements or description>
```

## What it does

1. **Research** — Read existing **`eversis-*.md`** in `.ai/prompts/public/` and `internal/` for frontmatter (`sidebar_position`, `slug`, `title`, `prompt_role`, `prompt_description`) and body structure.
2. **Clarify** — User goals, which **rules** to attach with the prompt, and whether the prompt is public or internal.
3. **Create** — Add the Markdown file; follow **`eversis-creating-prompts`** (`.ai/skills/eversis-creating-prompts/SKILL.md`).
4. **Review** — Check links, slugs, and that internal prompts are only referenced from public orchestration prompts.

## Output

A new **`.ai/prompts/public/eversis-*.md`** (or **`internal/eversis-*.md`**) file.

## Skills loaded

- `eversis-creating-prompts`
- `eversis-technical-context-discovering`
- `eversis-codebase-analysing`

---

## Executable prompt (attach in Cursor)

1. Open `.ai/skills/eversis-creating-prompts/SKILL.md` and follow its template and validation steps.
2. Use **`.ai/prompts/public/eversis-implement.md`** (or another prompt) as a structural reference for sections and “Executable prompt” blocks.
3. For routing in narrative text, refer to **conceptual roles** and **`.ai/rules/`** — not to deleted Copilot agent IDs.
4. Add the new file to the docs sidebar if this monorepo publishes the site (`sidebars.ts`).

<!-- Cursor Collections -->
