---
name: eversis-ba-docs-planner
description: "Plan Word .docx chapter updates from a Jira release + Confluence rules. BA Docs (Word) planner — produces docs-update-plan.md; not repo markdown."
---

# eversis-ba-docs-planner

## When to use

Use this skill when producing a **`docs-update-plan.md`** that maps Jira release issues to `.docx` chapter sections. Apply it before handing off to the Writer — the plan must be BA-approved before the Writer acts.

Load this skill before starting any planning run that involves `.docx` documentation (DAWIS SDD, EOE release notes, or any project that uses `summary.md` + chapter_id scheme).

## Workflow

### Step 1 — Pre-flight: inspect document (when `.docx` path is available)

Call `inspect_document(docx_path)`.

- If `status: "ERROR"` → **stop**. Report the error to the user. Do not continue planning.
- If `status: "WARNINGS"` → log all warnings and continue. Annotate plan header with warnings.
- Compare `sections_count` from `inspect_document` with the row count in `summary.md`.
  - If the difference > 5% → **warn the user**, show the delta, and **ask for confirmation** before continuing.
- Capture `sections_summary` — you will use it for section classification in Step 3.

### Step 1b — Pre-flight: summary only (no `.docx` available)

If only `summary.md` is available (no `.docx` path provided):

- Mark the plan header: `plan_status: UNVERIFIED`
- Insert the following block at the **top** of `docs-update-plan.md`, verbatim:

```
⚠ UNVERIFIED — Writer MUST run inspect_document(docx_path) before first edit.
```

### Step 2 — Confluence rules

Using Atlassian MCP, fetch the Confluence documentation rules page provided by the user. Extract:
- Which documents require updates for this release type
- Version numbering and metadata rules
- Formatting expectations (diagrams, tables, placeholders)

This page is the **decision matrix** — do not invent policy.

### Step 3 — Jira release mapping

Fetch Jira issues linked to the release. Filter to issues that affect **business or regulatory documentation** per the Confluence rules. For each relevant issue:
- Extract the affected section(s)
- Describe what needs to change (business-language, not code)

### Step 4 — Section classification

For each section in the plan, assign `content_type` based on `inspect_document` output:

| `content_type` | Meaning | Plan annotation |
|---|---|---|
| `TEXT-SAFE` | No tables or images — safe to edit with `append_chapter` | `[TEXT-SAFE]` |
| `TABLE-CONTAINS` | Section has tables — Writer must use `update_table_cell` | `[TABLE — użyj update_table_cell]` |
| `IMAGE-CONTAINS` | Section has inline images/drawings | `[IMAGE — append + graphics flag]` |
| `MIXED` | Tables and images present — treat as TABLE-CONTAINS | `[TABLE — użyj update_table_cell]` |

**Examples:**
- `sec-0` in DAWIS SDD (Amendment Status Sheet, Change Record) → `TABLE-CONTAINS` → annotate `[TABLE — użyj update_table_cell]`
- Typical requirements body section → `TEXT-SAFE` → Writer may use `append_chapter` freely
- Architecture overview section with UML diagram → `IMAGE-CONTAINS` → append + `[WYMAGA_AKTUALIZACJI_GRAFIKI]`

When `.docx` is not available (UNVERIFIED plan), leave `content_type` blank and add a note: _"Classify after inspect_document at write time."_

### Step 5 — Write `docs-update-plan.md`

Produce a structured markdown file with the following per-section entries:
- `chapter_id` from `summary.md`
- Section title
- `content_type` annotation (from Step 4)
- What to change (business-language description)
- Linked Jira issues
- `[WYMAGA_AKTUALIZACJI_GRAFIKI]` flag where diagrams need a manual pass

Set header field:
- `plan_status: VERIFIED` — when `inspect_document` was successfully called
- `plan_status: UNVERIFIED` — when only `summary.md` was used

### Step 6 — Stop for BA approval

Output the plan and **stop**. Remind the user:

> Do not start `eversis-ba-docs-writer` until this plan is reviewed and explicitly approved by the BA.

Do **not** invoke the Writer agent in this turn.

## Output format

```markdown
---
plan_status: VERIFIED | UNVERIFIED
docx_path: /path/to/file.docx   # omit if UNVERIFIED
sections_count: 196             # from inspect_document
generated: 2026-06-03
---

# docs-update-plan.md — <Release ID>

⚠ UNVERIFIED — Writer MUST run inspect_document(docx_path) before first edit.
<!-- include only when plan_status = UNVERIFIED -->

## Sections to update

### sec-0 — Preamble [TABLE — użyj update_table_cell]
**content_type:** TABLE-CONTAINS
**Jira:** EOG-1234, EOG-1235
**Change:** Append new row to Change Record table: version, date, description.

### sec-12 — Architecture Overview [IMAGE — append + graphics flag]
**content_type:** IMAGE-CONTAINS
**Jira:** EOG-1240
**Change:** Append updated component description. [WYMAGA_AKTUALIZACJI_GRAFIKI]

### sec-27 — Data Processing [TEXT-SAFE]
**content_type:** TEXT-SAFE
**Jira:** EOG-1242
**Change:** Replace paragraph 3 with updated processing rules.
```

## Constraints

- Do not edit `.docx` files — Planner is **read-only** relative to documents.
- Do not run Writer (`eversis-ba-docs-writer`) — hand off only after explicit BA approval.
- Do not claim `plan_status: VERIFIED` unless `inspect_document` was actually called and returned `status: "READY"` or `"WARNINGS"`.
- Do not invent section `content_type` — derive it from `inspect_document` output only. When unknown, leave blank with UNVERIFIED note.
- Do not change Confluence policy pages — read-only use only.
- The UNVERIFIED warning block must be inserted **verbatim** at the top of the plan when `plan_status: UNVERIFIED`.
