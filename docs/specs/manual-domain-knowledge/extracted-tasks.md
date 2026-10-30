# Manual domain knowledge — Extracted Tasks

## Workshop Summary

| Field | Value |
|---|---|
| Workshop Date | 2026-09-21 |
| Participants | Piotr Niemirski; agent (Business Analyst) |
| Source Materials | Approved intent brief `docs/specs/manual-domain-knowledge/intent-brief.md`. Chat 2026-09-21. Jira children of AC-2 (AC-16–AC-21). |
| Intent Brief | `docs/specs/manual-domain-knowledge/intent-brief.md` (Gate 0 Approved 2026-09-21) |
| Project Baseline Used | None |
| Total Epics | 1 (work stream only — Jira issue is a subtask of AC-2, not a new epic) |
| Total Stories | 1 |

## Epics Overview

| # | Epic Title | Stories Count | Priority |
|---|-----------|---------------|----------|
| 1 | Manual domain-knowledge draft | 1 | Medium |

## Epic 1: Manual domain-knowledge draft

**Business Description**: A person who already knows a durable fact can ask the agent to draft it into this project's domain knowledge without waiting for a ticket to close. The next session can read that fact the same way it reads facts captured at close-out. Close-out promotion stays the path for facts discovered while finishing a ticket.

**Success Criteria**:
- A person can start the new procedure on purpose and receive a draft, with no write until they approve that draft.
- An approved draft changes the project knowledge files in the working tree, including the index row, and the person commits.
- Closing a ticket still uses the existing promotion procedure, which stays out of the command menu.

### Story 1.1: Draft a domain fact without closing a ticket

**User Story**: As a framework user, I want to start a command that drafts a durable fact into project domain knowledge, so that a later session can read it without waiting for a ticket to close.

**Source**: Intent brief Goal and In Scope; chat 2026-09-21 decisions (new skill, working-tree write, parent AC-2).

**Acceptance Criteria**:
- [ ] GIVEN a person starts the new command with a team convention, a confirmed business rule, or a reusable pattern WHEN they ask for a draft THEN the agent shows the topic and the index row and does not write yet.
- [ ] GIVEN the fact is a one-off detail WHEN they ask THEN no draft is produced.
- [ ] GIVEN a matching topic already exists WHEN the fact belongs there THEN the draft extends that topic instead of adding a second one.
- [ ] GIVEN the person approves that specific draft WHEN the write happens THEN the project knowledge files change in the working tree and the person commits. The agent does not open a merge request.
- [ ] GIVEN the person rejects the draft or does not approve it WHEN the turn ends THEN the project knowledge files are unchanged.
- [ ] GIVEN the project knowledge index is missing WHEN the person starts the command THEN the agent says so and does not create a second place to store the fact.
- [ ] GIVEN the approved fact has been committed WHEN a later session looks up that topic THEN it finds that one topic from the index.
- [ ] GIVEN a ticket is closing WHEN promotion runs THEN it still uses the existing close-out procedure, and that procedure is not a command the person starts.
- [ ] GIVEN the public description of how knowledge is saved WHEN a reader looks it up THEN this command is listed separately from close-out promotion, Confluence import, and periodic cleanup.

**Additional Acceptance Checks**:
- The Jira issue is a subtask of AC-2, not a new epic.
- Hand-editing the knowledge files remains possible. This command does not replace it.

**High-Level Technical Notes**: New skill `eversis-add-domain-knowledge`, started by the person (`user-invocable`). Same topic shape as close-out promotion. Write is a local edit, not the GitLab merge-request path used when promotion publishes.

**Priority**: Medium

## Dependencies

| Task | Depends On | Type | Notes |
|------|-----------|------|-------|
| Story 1.1 | AC-20 | Related to | AC-20 documents the knowledge model. This story adds a path that page should describe as current once it exists. AC-20 does not have to ship first. |
| Story 1.1 | Close-out promotion | Related to | Must not turn close-out promotion into a user-started command. |

## Assumptions

| # | Assumption | Confidence | Impact if Wrong |
|---|-----------|------------|-----------------|
| 1 | "2. ok" means the working-tree edit (the option named first), not a GitLab merge request. | High | The approval criterion flips from "person commits" to "agent opens a merge request". |

## Out of Scope

Items explicitly excluded from this task breakdown:
- Changing close-out promotion into a command, or merging this procedure into that skill.
- Publishing into the shared group knowledge repository in the same action.
- Confluence import, periodic cleanup, status lifecycle, As-Is Pack suggestions, decisions log, session handoff, and the PI Agent window checkpoint (AC-16–AC-21, or already shipped).
- Running the new command against a consumer repository as part of framework delivery.

## Open Questions for Stakeholders

| # | Question | Context | Impact |
|---|----------|---------|--------|
| — | None | Gate 0 decisions recorded | — |
