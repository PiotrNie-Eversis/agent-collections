---
sidebar_position: 5
title: Workshop Analysis Flow
---

# Workshop Analysis Flow

For converting discovery workshop materials into structured, Jira-ready epics and user stories, use the Workshop Analysis workflow. This takes raw workshop outputs (transcripts, designs, notes) and produces a validated backlog ready for team refinement.

## Command Sequence

```text
1️⃣ /eversis-analyze-materials <workshop materials>
   ↳ 📝 Agent processes transcript — cleans, structures, extracts decisions
   ↳ 📖 Review cleaned transcript for accuracy
   ↳ 🔍 Agent analyzes Figma designs and codebase context
   ↳ 📋 Agent drafts intent-brief.md (scope, exclusions, candidate epics)

2️⃣ Gate 0 — Intent Review (optional)
   ↳ 📖 When materials are ambiguous — approve scope brief
   ↳ ⏭️ When unambiguous — skip with note in intent-brief.md

3️⃣ Task Extraction
   ↳ 📋 Agent extracts epics and user stories (Source traceability, scenario AC)
   ↳ 📄 → extracted-tasks.md

4️⃣ Gate 1 — Task Review
   ↳ 📖 Review extracted tasks — check epic/story breakdown
   ↳ ✅ Approve, or request splits/merges/removals

5️⃣ Gate 1.5 — Quality Review (automatic, Lite or Full mode)
   ↳ 🔍 Agent runs analysis passes for gaps and edge cases
   ↳ 📖 Review each suggestion — accept or reject individually
   ↳ ✅ Agent applies accepted suggestions to the task list

6️⃣ Gate 2 — Jira Push Approval
   ↳ 📖 Review final formatted tasks
   ↳ ✅ Confirm target Jira project and approve push
   ↳ 🚀 Agent creates/updates issues in Jira

7️⃣ Post-push verification
   ↳ 🔍 Read back Jira issues — verify summary, links, AC, status

8️⃣ Baseline refresh
   ↳ 📁 Update `docs/context/<project>/task-baseline.md`
   ↳ 🔗 Index workshop session at `docs/specs/<workshop-name>/`
```

## Workflow Diagram

```
┌─────────────────────────────┐
│  Raw Workshop Materials     │
│  (transcript, Figma, notes) │
└──────────┬──────────────────┘
           ▼
┌─────────────────────────────┐
│  Transcript Processing      │
│  → cleaned-transcript.md    │
└──────────┬──────────────────┘
           ▼
┌─────────────────────────────┐
│  Intent Brief               │
│  → intent-brief.md          │
└──────────┬──────────────────┘
           ▼
┌─────────────────────────────┐
│  ★ Gate 0: Intent Review    │
│  (optional — skip if clear) │
└──────────┬──────────────────┘
           ▼
┌─────────────────────────────┐
│  Task Extraction            │
│  → extracted-tasks.md       │
└──────────┬──────────────────┘
           ▼
┌─────────────────────────────┐
│  ★ Gate 1: User Review      │
└──────────┬──────────────────┘
           ▼
┌─────────────────────────────┐
│  Quality Review (Lite/Full) │
│  → quality-review.md        │
└──────────┬──────────────────┘
           ▼
┌─────────────────────────────┐
│  ★ Gate 1.5: Accept/Reject  │
└──────────┬──────────────────┘
           ▼
┌─────────────────────────────┐
│  Jira Formatting            │
│  → jira-tasks.md            │
└──────────┬──────────────────┘
           ▼
┌─────────────────────────────┐
│  ★ Gate 2: Push Approval    │
└──────────┬──────────────────┘
           ▼
┌─────────────────────────────┐
│  Push to Jira               │
│  (create epics → stories)   │
└──────────┬──────────────────┘
           ▼
┌─────────────────────────────┐
│  Post-push verification     │
│  (read-back from Jira)      │
└──────────┬──────────────────┘
           ▼
┌─────────────────────────────┐
│  Baseline refresh           │
│  → docs/context/<project>/  │
│    task-baseline.md         │
└─────────────────────────────┘
```

## Quality Review Passes

The quality review step runs domain-agnostic analysis passes (**Lite**: A, B, E, H, I; **Full**: A–J) against the approved task list. Suggestions are presented **one at a time** for accept/reject at Gate 1.5. See [Task Quality Review](../skills/task-quality-review).

| Pass | Category | What It Checks |
|---|---|---|
| A | Entity Lifecycle | CRUD completeness for every business entity |
| B | Cross-Feature State | State validation when features consume shared entities |
| C | Bulk Operations | Idempotency and partial failure handling for batch operations |
| D | Actor Dashboards | Metrics, configuration, and history for management interfaces |
| E | Precondition Guards | Feature dependencies and prerequisite enforcement |
| F | Third-Party Boundaries | External system integration clarity and failure modes |
| G | Platform Operations | Admin/operator tooling and monitoring capabilities |
| H | Error States | Failure, empty, and boundary condition coverage |
| I | Notifications | Communication gaps when state changes affect other actors |
| J | Domain Research | Industry-specific patterns and compliance requirements |

## Import Mode

To iterate on an existing Jira backlog instead of workshop materials:

```text
/eversis-analyze-materials PROJ-123
```

The agent fetches existing issues from Jira, converts them into the local format, then runs quality review and formatting. Changes can be pushed back to Jira individually or in batch. Import mode skips transcript processing, intent brief, and extraction.

## Connecting to the Standard Flow

After workshop analysis, individual tasks can flow into the standard delivery workflow:

```text
/eversis-analyze-materials  →  /eversis-implement PROJ-123  →  /eversis-review
```

Use the **Deep-dive Research per Task** handoff to transition a specific task to the Context Engineer for detailed requirements gathering, or the **Prepare Implementation Plan** handoff to send it to the Architect.

:::warning Important
Gate 0 may be skipped when workshop materials are unambiguous — the skip must be recorded in `intent-brief.md`. Gates 1, 1.5, and 2 require your review and approval. The Business Analyst produces business-oriented outputs — validate that the extracted tasks accurately reflect workshop discussions and that no critical topics were missed. AI assistance does not replace stakeholder judgment.
:::
