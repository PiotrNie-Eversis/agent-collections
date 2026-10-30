# Manual domain knowledge — Quality Review Report

## Review Context

| Field | Value |
|---|---|
| Review Date | 2026-09-21 |
| Source Task List | `extracted-tasks.md` (Gate 1 approved) |
| Additional Sources | `intent-brief.md` (Gate 0 approved). Jira AC-2 children AC-16–AC-21 (read earlier this session). No transcript. |
| Review Mode | Lite |
| Passes Run | A, B, E, H, I |
| Epics Reviewed | 1 |
| Stories Reviewed | 1 |
| Total Suggestions | 3 |
| Accepted | 3 |
| Rejected | 0 |

Lite mode: one work stream, one story, low delivery risk. Passes C, D, F, G, and J were not run.

Dropped without a suggestion: deleting or retiring a topic (Pass A) is the existing audit, called out of scope. Notifying another person (Pass I) does not apply — the other actor is a later session that reads the file.

---

## Domain Model

### Actors

| Actor | Epics Involved | Key Capabilities |
|---|---|---|
| Framework user | 1 | Starts the command, approves or rejects the draft, commits the files |
| Later session | 1 | Reads one saved topic from the index |
| Close-out promotion | 1 | Still drafts facts found while finishing a ticket; not started as a command |

### Entities

| Entity | Created In | Read In | Updated In | Deactivated/Deleted In |
|---|---|---|---|---|
| Domain topic | Story 1.1 (new topic, after approval) | Later session (benefit of 1.1; not its own criterion yet) | Story 1.1 (extend an existing topic) | — (audit, out of scope) |
| Draft | Story 1.1 | Story 1.1 (shown before write) | — | Discarded when not approved (not yet a criterion) |
| Index row | Story 1.1 | Later session | Story 1.1 | — |

### Key Relationships

- A domain topic is reachable only through its index row — covered in the draft, not yet as a later-session outcome.
- A draft must be approved before it becomes a topic. Rejection is not yet explicit.
- Close-out promotion writes the same files and must stay a separate procedure — already a criterion on Story 1.1.

---

## Suggestions

### Epic 1: Manual domain-knowledge draft

#### S-01 · High · ADD_ACCEPTANCE_CRITERION

**Target**: Story 1.1 — Draft a domain fact without closing a ticket

**Finding** (Pass H: Error State and Edge Case Coverage):
The story says a write happens only after approval. It does not say what happens when the person rejects the draft or stops without approving it.

**Proposed Change**:
Add to Story 1.1 acceptance criteria:
- [ ] GIVEN the person rejects the draft or does not approve it WHEN the turn ends THEN the project knowledge files are unchanged.

**Decision**: ✅ Accepted

---

#### S-02 · High · ADD_ACCEPTANCE_CRITERION

**Target**: Story 1.1 — Draft a domain fact without closing a ticket

**Finding** (Pass H: Error State and Edge Case Coverage):
The story assumes the project knowledge index is already there. It does not say what the person sees when that index is missing.

**Proposed Change**:
Add to Story 1.1 acceptance criteria:
- [ ] GIVEN the project knowledge index is missing WHEN the person starts the command THEN the agent says so and does not create a second place to store the fact.

**Decision**: ✅ Accepted

---

#### S-03 · High · ADD_ACCEPTANCE_CRITERION

**Target**: Story 1.1 — Draft a domain fact without closing a ticket

**Finding** (Pass A: Entity Lifecycle Completeness):
The reason for the story is that a later session can read the fact. No criterion checks that outcome after the person commits.

**Proposed Change**:
Add to Story 1.1 acceptance criteria:
- [ ] GIVEN the approved fact has been committed WHEN a later session looks up that topic THEN it finds that one topic from the index.

**Decision**: ✅ Accepted

---

## Summary of Changes Applied

- S-01 accepted. Story 1.1 gained a criterion: a rejected or unapproved draft leaves the project knowledge files unchanged.
- S-02 accepted. Story 1.1 gained a criterion: a missing project knowledge index is reported, and the agent does not create a second store.
- S-03 accepted. Story 1.1 gained a criterion: after the commit, a later session finds that one topic from the index.
