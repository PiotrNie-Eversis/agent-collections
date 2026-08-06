---
name: eversis-ba-docs-writer
description: "Apply an approved docs-update-plan.md to a Word .docx file via eversis-collections MCP. BA Docs (Word) channel only — not README, CHANGELOG, or website markdown (use eversis-repo-docs-writer when available)."
---

# eversis-ba-docs-writer

## When to use

Use this skill when applying an **approved** `docs-update-plan.md` to a **Word `.docx`** file via **eversis-collections MCP** (BA Docs / Business Manager Docs playbook).

**Do not use** for repository markdown (README, CHANGELOG, `website/docs`, `/docs`) — that is the **Repo Docs** channel (`eversis-repo-docs-writer` when shipped).

Load it before any Writer run that touches Word documents.

Do **not** start writing until the BA has explicitly approved the plan (the Planner produces a draft; Writer does not auto-run).

## Workflow

### Step 0 — Backup (MANDATORY — no exceptions)

```
Call backup_docx(docx_path).
Log the backup path in your response: "Backup: <path>"
Do NOT proceed if backup_docx returns an error. Report the error and stop.
```

This is the **first** action in every Writer session, before any edits.

### Step 1 — Pre-flight when plan is UNVERIFIED

If the plan header contains `plan_status: UNVERIFIED` or the UNVERIFIED warning block is present:

```
Call inspect_document(docx_path).
If status = "ERROR"  → stop. Report error to user. Do not edit.
If status = "WARNINGS" → log all warnings, continue with caution.
Compare sections_count with the plan's section list.
If mismatch → warn the user, show delta, ask for confirmation before editing.
```

If `plan_status: VERIFIED` and `inspect_document` was called by Planner — proceed to Step 2.

### Step 2 — Per-section iteration

For each section in `docs-update-plan.md`, in plan order:

**a) Identify content type**

Call `list_section_elements(docx_path, chapter_id)`.

Note the returned `content_type`:
- `TEXT-SAFE`
- `TABLE-CONTAINS`
- `IMAGE-CONTAINS`
- `MIXED`

**b) Route by content type**

| `content_type` | Default tool | Conditions |
|---|---|---|
| `TEXT-SAFE` | `append_chapter` | Use `update_chapter` **only** when the plan **explicitly** says `REPLACE` |
| `TABLE-CONTAINS` | `update_table_cell` | **NEVER** call `append_chapter` or `update_chapter` on TABLE-CONTAINS without explicit human approval |
| `IMAGE-CONTAINS` | `append_chapter` with `requires_graphics_review: true` | Do **not** remove existing paragraphs containing images |
| `MIXED` | `update_table_cell` | Treat as TABLE-CONTAINS (most conservative) |

**c) After each edit — verify**

```
Call read_chapter(docx_path, chapter_id).
Confirm the new content is present in the returned text.
If not present → stop, report the discrepancy, do not continue to next section.
```

### Step 3 — Graphics flag handling

For sections annotated `[WYMAGA_AKTUALIZACJI_GRAFIKI]`:

1. Append the placeholder text using `append_chapter` with `requires_graphics_review: true`.
2. Do **not** delete existing paragraphs that contain images (`w:drawing` nodes).
3. After writing, add to the summary: "Section `<chapter_id>` has been flagged — manual diagram update required."

### Step 4 — Session summary

After processing all sections, output:

```
Sections updated:   N
Sections skipped (TABLE-CONTAINS — manual):  N
Sections flagged for graphics:  N

Reminder: Visually verify tables, numbering, and diagrams in MS Word before uploading to SharePoint.
```

List any section that was skipped with a brief reason so the BA knows what requires manual attention.

## Decision table (quick reference)

```
content_type       → tool to use
TEXT-SAFE          → append_chapter          (update_chapter only if plan says REPLACE)
TABLE-CONTAINS     → update_table_cell        (FORBIDDEN: append_chapter, update_chapter)
IMAGE-CONTAINS     → append_chapter           (requires_graphics_review: true; keep existing images)
MIXED              → update_table_cell        (treat as TABLE-CONTAINS)
```

## Constraints

- `backup_docx` is **always** the first call. No edits without a successful backup.
- `update_chapter` **destroys** all existing paragraph content in the section body (paragraphs, inline images). It does NOT remove tables (`w:tbl`), but it orphans them. Never call `update_chapter` without checking `content_type` first.
- **FORBIDDEN:** Calling `update_chapter` or `append_chapter` on a `TABLE-CONTAINS` section without explicit human approval in the same session.
- Always call `read_chapter` after every edit to verify content was written correctly.
- Do not commit secrets or credentials. `upload_to_sharepoint` may be unimplemented — document limitations instead of faking success.
- Do not proceed past Step 0 if `backup_docx` fails — the risk of data loss without a backup is unacceptable.
- Do not run `eversis-ba-docs-planner` yourself — the plan must already be approved before Writer starts.
