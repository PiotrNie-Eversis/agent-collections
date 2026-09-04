---
sidebar_position: 2
title: Business Analyst
---

# Business Analyst Agent

**Rule pack (canonical template):** `.cursor/rules/eversis-role-business-analyst.mdc` — **not shipped** in agent-collections; behavior via `@eversis-analyze-materials` and BA skills.  
**Primary prompt:** `@eversis-analyze-materials` (docs: [Analyze materials](../prompts/public/analyze-materials))

The Business Analyst role converts discovery workshop materials (transcripts, Figma, codebase context) into structured, Jira-ready epics and user stories. It can also import and iterate on existing Jira backlogs.

## Responsibilities

- Processing raw workshop transcripts — cleaning, structuring, and extracting key decisions.
- Analyzing Figma/FigJam designs for functional requirements and user flows.
- Extracting epics and user stories from all processed materials.
- Running quality review passes to identify gaps and missing edge cases.
- Formatting tasks for Jira using a benchmark template.
- Post-push Jira read-back verification and project baseline refresh.
- Managing a multi-gate review process before pushing to Jira.
- Importing existing Jira backlogs for local iteration and improvement.

## What it produces

Markdown artifacts under `docs/specs/<workshop-name>/` (or `specifications/<workshop-name>/`):

- **`cleaned-transcript.md`** — Structured transcript with topics, decisions, action items, and open questions.
- **`intent-brief.md`** — Gate 0 scope brief (goal, in/out of scope, candidate epics); may record skip when materials are unambiguous.
- **`extracted-tasks.md`** — Epics and user stories with **Source** traceability and scenario acceptance criteria.
- **`quality-review.md`** — Quality review with suggestions and dispositions.
- **`jira-tasks.md`** — Jira-ready tasks per the benchmark template.

**Project continuity** (refreshed after successful Jira push):

- **`docs/context/<project>/task-baseline.md`** — Epic/story index keyed by Jira Key for future workshop overlap checks. Lives alongside `INDEX.md` in the same directory but is a separate, sibling file — not one of the components `INDEX.md` indexes (see [Domain Context (SSOT)](../../domain-context)).

## What it does NOT do

- Does not produce technical specifications or architecture decisions (use the [Architect](./architect) for that).
- Does not produce detailed requirement research or gap analysis (use the [Context Engineer](./context-engineer) for that).
- Does not create implementation plans, test plans, or deployment plans.
- Does not estimate story points (provides sizing guidance only).

## Three-Gate Review Process

The Business Analyst enforces a strict review process — no data is pushed to Jira without explicit user approval:

| Gate | When | What |
|---|---|---|
| **Gate 0** | After intent brief (optional) | Approve scope brief, or skip when materials are unambiguous (record skip in `intent-brief.md`) |
| **Gate 1** | After task extraction | User reviews the epic/story breakdown |
| **Gate 1.5** | After quality review | User accepts or rejects **individual** improvement suggestions (**one per chat turn**); Lite or Full review mode per skill |
| **Gate 2** | After Jira formatting | User reviews final formatted tasks before Jira push |

## Tool Access

| Tool | Usage |
|---|---|
| **Atlassian** | Create/update Jira issues, fetch existing backlogs, link stories to epics |
| **Figma** | Analyze workshop designs, wireframes, and FigJam boards for functional requirements |
| **PDF Reader** | Read and extract content from PDF workshop materials |
| **Sequential Thinking** | Analyze complex discussions, resolve conflicts between materials, plan task structure |
| **Cursor Agent** | Read, search, and edit workspace files |
| **Todo** | Track task progress with structured checklists |

## Skills Loaded

- [eversis-transcript-processing](../skills/transcript-processing) — Clean raw transcripts, structure by topics, extract decisions and action items.
- [eversis-task-extracting](../skills/task-extraction) — Intent brief (Gate 0), epics/stories with source traceability.
- [eversis-task-quality-reviewing](../skills/task-quality-review) — Run analysis passes to find gaps, edge cases, and improvements.
- [eversis-jira-task-formatting](../skills/jira-task-formatting) — Format tasks for Jira, manage review gates, handle import mode.
- [eversis-codebase-analysing](../skills/codebase-analysis) — Understand existing system context when relevant to task scope.

## Handoffs

After workshop analysis, continue with [Engineering Manager](./engineering-manager) by attaching **`@eversis-implement`** ([Implement](../prompts/public/implement); research and planning run before broad code changes per `eversis-agent-core.mdc`).
