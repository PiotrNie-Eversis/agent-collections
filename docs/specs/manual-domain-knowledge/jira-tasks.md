# Manual domain knowledge — Jira-ready tasks

No Jira epic. Gate 0 decided the deliverable is one subtask of AC-2. The work-stream title below is local only.

## Completeness

| Task | Required fields | Notes |
|---|---|---|
| Story 1.1 | Complete | Issue type is Sub-task, parent AC-2, by Gate 0. Priority Medium. No TBD fields. |

---

### Story 1.1: Framework user can draft a domain fact without closing a ticket

**Parent**: AC-2 (existing task; not a new epic)
**Issue Type**: Sub-task
**Jira Key**: AC-22
**Status**: Backlog
**Assignee**: Piotr Niemirski
**Priority**: Medium
**Sizing Guidance**: Small (1-3)

**Description**:

```
h2. Context

This story is part of AC-2 (context and knowledge). A person who already knows a durable fact can ask for a draft in project domain knowledge without waiting for a ticket to close.

h2. Source Context

Intent brief docs/specs/manual-domain-knowledge/intent-brief.md (Gate 0 approved 2026-09-21). Extracted story 1.1 after quality review S-01, S-02, and S-03.

h2. User Story

As a framework user, I want to start a command that drafts a durable fact into project domain knowledge, so that a later session can read it without waiting for a ticket to close.

h2. Requirements

# The person starts a new command on purpose. Close-out promotion stays a separate procedure and stays out of the command menu.
# A durable fact is a team convention, a confirmed business rule, or a reusable pattern. A one-off detail produces no draft.
# The draft shows the topic and the index row. Nothing is written until that specific draft is approved.
# An existing matching topic is extended. A second topic is not created for the same fact.
# After approval, the project knowledge files change in the working tree and the person commits. The agent does not open a merge request.
# A rejected or unapproved draft leaves the project knowledge files unchanged.
# If the project knowledge index is missing, the agent says so and does not create a second place to store the fact.
# After the commit, a later session finds that one topic from the index.
# The public description of how knowledge is saved lists this command separately from close-out promotion, Confluence import, and periodic cleanup.
# Hand-editing the knowledge files remains possible.

h2. Delivery Standard

This story follows full spec-driven development.

* Spec folder: docs/specs/<issue-kebab>/
* Research: <issue-kebab>.research.md — required before plan
* Plan: <issue-kebab>.plan.md — required before implementation
* Implement: load eversis-implement (approved plan attached)
* Review: load eversis-review before Done
* Fine: QA comment draft per eversis-fine-handoff

Do not start implementation without approved research and plan artifacts.

h2. Technical Notes

New skill eversis-add-domain-knowledge, started by the person (user-invocable). Same topic shape as close-out promotion. Write is a local edit, not the GitLab merge-request path used when promotion publishes.
```

**Acceptance Criteria**:

```
(/) GIVEN a person starts the new command with a team convention, a confirmed business rule, or a reusable pattern WHEN they ask for a draft THEN the agent shows the topic and the index row and does not write yet.
(/) GIVEN the fact is a one-off detail WHEN they ask THEN no draft is produced.
(/) GIVEN a matching topic already exists WHEN the fact belongs there THEN the draft extends that topic instead of adding a second one.
(/) GIVEN the person approves that specific draft WHEN the write happens THEN the project knowledge files change in the working tree and the person commits. The agent does not open a merge request.
(/) GIVEN the person rejects the draft or does not approve it WHEN the turn ends THEN the project knowledge files are unchanged.
(/) GIVEN the project knowledge index is missing WHEN the person starts the command THEN the agent says so and does not create a second place to store the fact.
(/) GIVEN the approved fact has been committed WHEN a later session looks up that topic THEN it finds that one topic from the index.
(/) GIVEN a ticket is closing WHEN promotion runs THEN it still uses the existing close-out procedure, and that procedure is not a command the person starts.
(/) GIVEN the public description of how knowledge is saved WHEN a reader looks it up THEN this command is listed separately from close-out promotion, Confluence import, and periodic cleanup.
```

**Labels**: `domain-knowledge`, `follow-up`, `workshop-2026-09-21`
