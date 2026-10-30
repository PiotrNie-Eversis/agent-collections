---
scope: project
source: manual
status: approved
last_updated: "2026-10-20"
tags: [jira, backlog, business-analysis, eversis-analyze-materials]
code_paths:
  - docs/context/agent-collections/
confluence_url: null
related_specs:
  - docs/specs/ac-35-prerequisites-post-review/
---

# Jira backlog hierarchy (Agent Collections)

Project-specific rules live **only** under `docs/context/` — not in framework skills under `.ai/skills/`. Before Jira push (`eversis-jira-task-formatting`) or backlog formatting after `eversis-analyze-materials`, read this component from `docs/context/agent-collections/INDEX.md`.

## Standard (project AC)

The **last ticket level** — the one engineers implement, review, and close — is always a **Task** or a **Bug**. Higher levels group work; they are never the implementable leaf.

Allowed shapes:

- **Epic → Task / Bug**
- **Story → Task / Bug**
- **Epic → Story → Task / Bug**

Not allowed:

- **Story** as the last level (a Story with no Task or Bug under it).
- **Sub-task** as the last level under a Task or Story. Split the work into separate Tasks / Bugs instead.

If workshop extraction produces user stories, either keep them as Stories **and** add the implementable Tasks / Bugs under them, or convert them to Tasks (Bugs for defects) under the Epic. Keep user-story wording in the description.

## Rationale

Tasks and bugs are the team's delivery unit: they match implement, review, and Fine, and carry the spec folder, QA comment, and acceptance criteria. Stories may group related Tasks / Bugs, but a Story or Sub-task as the leaf hides the delivery unit.

## When the board does not match

A Story without a Task / Bug under it, or Sub-tasks used as the leaf: create the Task or Bug with the same parent and acceptance criteria, link **Duplicate** or **Relates** to the old item, comment on it, and close it (Done), so the backlog shows Tasks / Bugs as the actionable items.

## Jira note

In the AC project, Story and Task are both standard issue types at the same hierarchy level, so a Task cannot use a Story as its Jira `parent` field. Express **Story → Task / Bug** with an issue link (or the board's own grouping) when the native parent field does not allow it.

## Labels and traceability

Workshop batches may still use labels such as `ac-35-follow-up`. Spec folder references in descriptions stay unchanged.

## Changelog

| Date | Change |
|---|---|
| 2026-10-13 | Initial rule: Epic → Task/Bug; never Story as the last level. |
| 2026-10-20 | Audit (Replace): Story allowed as a grouping level above Task/Bug; Sub-task not allowed as the last level. Human: "Task/Bug powinien być ostatnim ticketem na liście, np. Epik -> Task/Bug, Stories -> Task/Bug, Epik -> Stories -> Task/Bug". |
