---
sidebar_position: 12
title: "BA Docs (Word) — Writer"
slug: ba-docs-writer
prompt_role: "BA Docs (Word) writer"
prompt_description: "Apply docs-update-plan.md to .docx via eversis-collections MCP — not README or website markdown."
upstream_agent: "eversis-ba-docs-writer"
---
# eversis-ba-docs-writer

**Role:** BA Docs (Word) writer  
**File:** `.cursor/prompts/public/eversis-ba-docs-writer.md`

Applies an **approved** `docs-update-plan.md` to **Word `.docx`** files using **eversis-collections MCP** (`.docx` tools — do not paste whole documents into chat).

:::note Not Repo Docs
For **repository** documentation (README, CHANGELOG, `website/docs`, markdown under `/docs`), use **`@eversis-repo-docs-writer`** — typically delegated from `@eversis-implement`. This prompt is **only** for the **Business Manager Docs (Word)** playbook.
:::

## Usage

```text
@eversis-ba-docs-writer
@docs-update-plan.md | path to .docx
```

Attach the **approved** plan. Optionally attach **`.cursor/rules/eversis-ba-docs-writer.mdc`** and **`.cursor/skills/eversis-ba-docs-writer/SKILL.md`**. Ensure **eversis-collections** MCP is enabled (includes `.docx` tools). Enable **Atlassian** only if you need to re-fetch context — Writer normally does not edit Confluence rules.

<workflow>

1. **Human gate** — Confirm `docs-update-plan.md` is **accepted by the BA** after Planner. If not confirmed, **stop** and ask to approve or revise the plan first. Check `plan_status`:
   - `VERIFIED` → proceed to step 2
   - `UNVERIFIED` → run `inspect_document` first (step 1b)

1b. **Inspect (UNVERIFIED only)** — Call `inspect_document(docx_path)`.
    Verify `sections_count` matches plan section list. On `ERROR` → stop and report. On `WARNINGS` → log and continue.

2. **Backup** — Call `backup_docx(docx_path)`. Log backup path in response: `"Backup: <path>"`. Do NOT proceed if backup fails.

3. **Iterate the plan** — For each section in `docs-update-plan.md`:
   a. Call `list_section_elements(docx_path, chapter_id)` → get `content_type`
   b. Route by `content_type`:
      - `TEXT-SAFE`        → `append_chapter` (default); `update_chapter` only if plan says `REPLACE`
      - `TABLE-CONTAINS`   → `update_table_cell` (append_row or cell update per plan); FORBIDDEN: `append_chapter` or `update_chapter` without explicit human approval
      - `IMAGE-CONTAINS`   → `append_chapter` + `requires_graphics_review: true`; do NOT remove existing image paragraphs
      - `MIXED`            → treat as `TABLE-CONTAINS`
   c. After each edit → call `read_chapter(docx_path, chapter_id)` to verify new content is present

4. **Graphics flag** — Sections annotated `[WYMAGA_AKTUALIZACJI_GRAFIKI]`: insert placeholder, flag for human. Remind the human that diagrams require a manual update in Word.

5. **Finish** — Output session summary:
   - Sections updated / skipped (TABLE-CONTAINS — manual) / flagged for graphics
   - Remind human: "Visually verify tables, numbering, and diagrams in MS Word before uploading to SharePoint."

</workflow>

## Related

- **Planner prompt:** `@eversis-ba-docs-planner`
- **Writer skill:** `.cursor/skills/eversis-ba-docs-writer/SKILL.md`
- **Spec:** `docs/specs/business-docs-workflow/business-docs-workflow.spec.md`

<!-- Eversis — BA documentation relay -->
