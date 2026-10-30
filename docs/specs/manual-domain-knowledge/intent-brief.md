# Manual domain knowledge — Intent Brief

## Workshop Summary

| Field | Value |
|---|---|
| Workshop Date | 2026-09-21 |
| Participants | Piotr Niemirski; agent (Business Analyst) |
| Source Materials | Chat 2026-09-21 (promote skill is not a slash command; a person still needs a way to add a fact by hand). Existing procedures: promote at close-out, one-time Confluence import, periodic audit. Jira children of AC-2 (AC-16–AC-21). Public domain-context page. No transcript. No `task-baseline.md`. |
| Prepared By | Agent (eversis-analyze-materials) |

## Goal

A person who already knows a durable fact — a team convention, a confirmed business rule, or a reusable pattern — can ask the agent to draft it into the project's domain knowledge without waiting for a ticket to close. The draft uses the same topic shape the next session already knows how to read. Nothing is written until that person approves the draft.

## In Scope

- A new procedure the person starts on purpose (a new skill file, visible as a command). It is not the close-out promotion.
- Drafting a new topic, or extending a topic that already exists, under this repository's project knowledge (`docs/context/<project>/`), including the index row so a later session can find it.
- The same approval rule as close-out: show the draft, write only after an explicit yes for that draft.
- A short public-docs note so the three existing write paths and this fourth path stay distinguishable.
- One Jira story under AC-2, if Gate 0 is approved. No new epic.

## Out of Scope

- Turning the existing close-out promotion into a command the person starts. That procedure stays tied to the end of a ticket and stays out of the command menu.
- Replacing hand-editing. The knowledge files are ordinary Markdown; a person can still edit them and commit.
- One-time import from Confluence, periodic cleanup, a status lifecycle, As-Is Pack suggestions, a decisions log, session handoff, and PI Agent. Those are AC-16–AC-21 or already shipped.
- Publishing a fact into the shared group repository (`domain-context`) in the same action. That remains a later, separate publish.
- Running this against a consumer repository as part of delivering the framework.

## Key Stakeholders / Actors

- Framework user — wants to record a fact they already know, outside a closing ticket.
- Engineering Manager / close-out — keeps owning automatic promotion when a finished ticket produced a durable fact.
- Later Implement session — reads one matching topic; depends on the index row staying accurate.

## Candidate Epics

- Manual domain-knowledge draft — one story, not an epic. Rationale: the gap is a missing start path. Import and audit are already commands a person starts; promotion at close-out is not, and should not become one.

## Baseline Overlap / Existing Backlog Notes

- No `docs/context/<project>/task-baseline.md` in this repo.
- AC-2 children in Backlog do not cover this gap:
  - AC-16 decisions home, AC-17 As-Is suggestion, AC-18 status and audit signal, AC-19 session handoff, AC-20 public architecture map, AC-21 PI Agent window checkpoint.
- AC-20 documents the model. If this story ships, that page should mention the manual path as current behavior, not as a future phase. AC-20 does not itself add the procedure.
- Close-out promotion already writes the same files after a ticket. This story adds the case where there is no ticket.

## Decisions (2026-09-21)

- New skill the person invokes. Close-out promotion stays unchanged and out of the command menu.
- After approval, the write is a normal edit in the working tree. The person commits. The agent does not open a GitLab merge request.
- Jira parent: subtask of AC-2.

## Open Questions

- None.

## Gate 0 Approval

| Decision | Notes |
|---|---|
| Approved | 2026-09-21. Piotr Niemirski: new skill; working-tree write; parent AC-2. Brief accepted. |
