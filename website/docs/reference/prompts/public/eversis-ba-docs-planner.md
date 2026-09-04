---
sidebar_position: 11
title: "BA Docs (Word) — Planner"
slug: ba-docs-planner
prompt_role: "BA Docs (Word) planner"
prompt_description: "Build docs-update-plan.md from Confluence rules, a Jira release, and summary.md — for .docx chapters."
upstream_agent: "eversis-ba-docs-planner"
---
# eversis-ba-docs-planner

**Role:** BA Docs (Word) planner  
**File:** `.cursor/prompts/public/eversis-ba-docs-planner.md`

Produces `docs-update-plan.md`: which document chapters to update after a release, aligned with **Confluence** documentation rules and **Jira** release scope. Annotates each section with `content_type` classification (TEXT-SAFE / TABLE-CONTAINS / IMAGE-CONTAINS) when `.docx` is available.

## Usage

```text
@eversis-ba-docs-planner
<Jira release id or version> | Confluence page title for doc rules | path or @ to summary.md
```

In **Cursor**, attach this prompt. Optionally attach **`.cursor/rules/eversis-ba-docs-planner.mdc`** and **`.cursor/skills/eversis-ba-docs-planner/SKILL.md`**. Enable **Atlassian MCP** (Jira + Confluence) and **eversis-collections MCP** if a `.docx` path will be used.

<workflow>

1. **Human gate (planning)** — Treat this run as producing a **draft** artifact. The BA must **review and approve** `docs-update-plan.md` before anyone runs **`@eversis-ba-docs-writer`** (same relay idea as `eversis-agent-core.mdc`: no execution on unapproved plan).

2. **Confluence first (critical)** — Using Atlassian MCP, read the Confluence page the user named (documentation definitions / update rules). Use it as the **decision matrix** (N/A docs, version rules, formatting expectations).

3. **Jira release** — Fetch issues linked to the release the user specified; filter to what affects **business / regulatory documentation** per the Confluence rules.

4. **Map to `summary.md`** — When `.docx` path is available:
   a. Call `inspect_document(docx_path)` → capture `sections_count` and per-section `content_type`.
   b. Compare `sections_count` with `summary.md` row count. If difference > 5%:
      → warn user, show mismatched sections, ask for confirmation before continuing.
   c. Annotate each chapter entry in `docs-update-plan.md` with `content_type`:
      - `[TEXT-SAFE]` — Writer may use `append_chapter` freely
      - `[TABLE — użyj update_table_cell]` — Writer must use `update_table_cell`
      - `[IMAGE — append + graphics flag]` — Writer uses `append_chapter` + graphics placeholder
   d. Set `plan_status: VERIFIED`.

   When only `summary.md` available (no `.docx`):
   a. Proceed with mapping using `summary.md` chapter ids.
   b. Set `plan_status: UNVERIFIED`.
   c. Insert at the **top** of the plan — verbatim:
      `⚠ UNVERIFIED — Writer MUST run inspect_document(docx_path) before first edit.`

5. **Write `docs-update-plan.md`** — Structured markdown: per chapter (or `chapter_id`), short **what to change**, `content_type` annotation, and add **`[WYMAGA_AKTUALIZACJI_GRAFIKI]`** where UML/Visio/architecture diagrams need a human pass.

6. **Stop** — Output the file path or full content of `docs-update-plan.md` and remind the human: **do not start Writer until this plan is accepted.**

</workflow>

## Related

- **Spec:** `docs/specs/business-docs-workflow/business-docs-workflow.spec.md`
- **Writer prompt:** `@eversis-ba-docs-writer`
- **Planner skill:** `.cursor/skills/eversis-ba-docs-planner/SKILL.md`

<!-- Eversis — BA documentation relay -->
