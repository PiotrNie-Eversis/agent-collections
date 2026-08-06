---
sidebar_position: 10
title: "Analyze materials"
slug: analyze-materials
prompt_role: "Business analyst"
prompt_description: "Process discovery workshop materials and create Jira-ready epics and user stories, or iterate on an existing Jira backlog."
upstream_agent: "eversis-business-analyst"
---
# eversis-analyze-materials

**Agent:** Business Analyst 
**File:** `.cursor/prompts/public/eversis-analyze-materials.md`

Processes discovery workshop materials and converts them into structured, Jira-ready epics and user stories. Can also import an existing Jira backlog for local iteration.

## Usage

```text
@eversis-analyze-materials
<workshop materials or Jira project key>
```

Or use the `/eversis-analyze-materials` project command (type `/` in Chat or Agent — requires `.cursor/commands/` from this repo).

In **Cursor**, attach the file above (or open it and reference it with `@`) plus your ticket text and context.

## What It Does

### Standard Workflow (workshop materials provided)

1. **Process transcript** — Cleans raw transcript using `eversis-transcript-processing`.
2. **Analyze additional materials** — Reviews Figma (MCP), codebase (`eversis-codebase-analysing`), PDFs, and other references.
3. **Draft intent brief** — Synthesizes `intent-brief.md` (goal, scope, exclusions, candidate epics) via `eversis-task-extracting`.
4. **Gate 0 — Intent review (optional)** — Present brief for approval when materials are ambiguous; **skip** when scope is already clear (record `Skipped — materials unambiguous` in the brief).
5. **Extract tasks** — Epics and stories with **Source** traceability and scenario acceptance criteria → `extracted-tasks.md`.
6. **Gate 1 — Task review** — User validates epic/story breakdown.
7. **Quality review** — Lite or Full passes (`eversis-task-quality-reviewing`).
8. **Gate 1.5 — Suggestion review** — One suggestion per chat turn; saves `quality-review.md`.
9. **Format for Jira** — `eversis-jira-task-formatting` → `jira-tasks.md`.
10. **Gate 2 — Push approval** — User confirms before Jira sync.
11. **Push to Jira** — Creates/updates issues; reports keys.
12. **Post-push verification** — Read back Jira issues; verify summary, parent links, AC, status.
13. **Baseline refresh** — Update `docs/context/<project>/task-baseline.md` after successful verification.

### Import Mode (Jira project key provided)

Skips transcript processing, intent brief, and extraction. Fetches existing backlog, then quality review and formatting.

## Skills Loaded

- `eversis-transcript-processing` — Clean and structure raw transcripts.
- `eversis-task-extracting` — Intent brief, Gate 0, epics/stories with source traceability.
- `eversis-task-quality-reviewing` — Gap analysis (Lite/Full).
- `eversis-jira-task-formatting` — Jira formatting and push.
- `eversis-codebase-analysing` — Codebase context when relevant.
- `eversis-task-analysing` — Optional business-context exploration before extraction.

## Output

Artifacts under `docs/specs/<workshop-name>/` (or `specifications/<workshop-name>/`):

```text
docs/specs/user-onboarding/
 cleaned-transcript.md
 intent-brief.md ← Gate 0 scope brief
 extracted-tasks.md
 quality-review.md
 jira-tasks.md
```

**Project continuity baseline** (optional, refreshed after successful Jira push):

```text
docs/context/<project>/
 task-baseline.md ← epic/story index for future workshops
```

:::tip Review gates
**Gate 0** is optional when materials are unambiguous (skip noted in `intent-brief.md`). **Gates 1, 1.5, and 2** are mandatory before Jira push.
:::

---

## Executable prompt (attach in Cursor)

Analyze the provided workshop materials (transcripts, Figma designs, PDF documents, codebase context, or other reference documents) and convert them into structured, Jira-ready epics and user stories. Alternatively, import an existing Jira backlog for local iteration and improvement.

Save markdown artifacts under `docs/specs/<workshop-topic>/` (or your team's `specifications/` folder):

- `cleaned-transcript.md` — Cleaned and structured transcript
- `intent-brief.md` — Scope brief (Gate 0); required before extraction
- `extracted-tasks.md` — Epics and stories (updated after quality review)
- `quality-review.md` — Quality review report
- `jira-tasks.md` — Final Jira-ready tasks

## Required Skills

Before starting, load and follow these skills in order:

- `eversis-transcript-processing` — cleaning and structuring raw transcripts
- `eversis-task-extracting` — intent brief, Gate 0, extraction with source traceability
- `eversis-task-quality-reviewing` — gap analysis (Lite/Full)
- `eversis-jira-task-formatting` — Jira formatting and push
- `eversis-codebase-analysing` — existing codebase when relevant
- `eversis-task-analysing` — optional business-context exploration

## Workflow

Determine the entry point based on what the user provides:

**If the user provides existing Jira issue keys or a project key instead of workshop materials**, skip transcript processing, intent brief, and extraction. Use `eversis-jira-task-formatting` **Import Mode**. Then proceed to quality review and formatting.

**Standard workflow (workshop materials provided):**

1. **Process transcript**: If a raw transcript is provided, clean it with `eversis-transcript-processing`. Save as `cleaned-transcript.md`.
2. **Analyze additional materials**: Review Figma (`figma` MCP), PDFs (`pdf-reader`), codebase (`eversis-codebase-analysing`), and other references.
3. **Draft intent brief**: Using `eversis-task-extracting`, synthesize `intent-brief.md` (goal, in/out of scope, stakeholders, candidate epics, baseline overlap, open questions). Follow `intent-brief.example.md`.
4. **Review Gate 0 (optional)**:
 - **When ambiguous** — Present the intent brief; iterate until **Approved**.
 - **When unambiguous** — Record `Skipped — materials unambiguous` in **Gate 0 Approval** with rationale; confirm skip in chat.
 - Do not extract until Gate 0 is Approved or Skipped per above.
5. **Extract tasks**: Using `eversis-task-extracting` and the approved/skipped intent brief, produce `extracted-tasks.md` with **Source** per story and `GIVEN / WHEN / THEN` acceptance criteria.
6. **Review Gate 1**: Present the task list; iterate until approved.
7. **Quality review**: `eversis-task-quality-reviewing` (Lite or Full) — automatic after Gate 1.
8. **Review Gate 1.5**: One suggestion per chat turn; apply accepted changes; save `quality-review.md`.
9. **Confirm updated tasks**: Summarize changes; proceed when user confirms.
10. **Format for Jira**: `eversis-jira-task-formatting` → `jira-tasks.md` (preserve source traceability).
11. **Review Gate 2**: Confirm target Jira project; get explicit push approval.
12. **Push to Jira**: Create/update issues; report keys.
13. **Post-push verification**: Using `eversis-jira-task-formatting` Step 10, read back created/updated Jira issues. Verify summary, parent epic linkage, acceptance criteria, description sections, and status. Surface mismatches before claiming success.
14. **Baseline refresh**: When verification succeeds, refresh `docs/context/<project>/task-baseline.md` per `eversis-jira-task-formatting` Step 11. Index the workshop session folder (`docs/specs/<workshop-topic>/`) in the baseline Session Archive Index.

**Before extraction (standard workflow):** If `docs/context/<project>/task-baseline.md` exists, load it during material analysis and intent brief for overlap and continuity notes.

## Important

- Output must be **business-oriented** — no technical implementation details beyond what was discussed.
- Ask the user in chat when confidence is low about scope, priority, or intent.
- Gate 0 may be skipped only when materials are unambiguous — document the skip in `intent-brief.md`.
- Gates 1, 1.5, and 2 are mandatory — no Jira push without explicit approval.
- Gate 1.5 runs automatically after Gate 1; user accepts/rejects suggestions individually.
- Imported Jira backlogs still go through quality review.
- Post-push verification and baseline refresh run after every successful Jira sync (standard workflow and batch push).
- If no transcript is provided, skip transcript processing and proceed from intent brief / extraction as appropriate.

Follow template structures from each skill strictly.

<!-- Eversis port; upstream: eversis-analyze-materials:v3 + optional Gate 0 -->
