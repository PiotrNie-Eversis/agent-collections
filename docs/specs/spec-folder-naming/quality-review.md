# Spec folder naming — Quality Review Report

## Review Context

| Field | Value |
|---|---|
| Review Date | 2026-09-24 |
| Source Task List | `extracted-tasks.md` (Story 1.1 approved, including the three-word topic cap; user asked for one ticket under AC-2) |
| Additional Sources | `cleaned-transcript.md`, `intent-brief.md` (Gate 0 approved) |
| Review Mode | Lite |
| Passes Run | A, B, E, H, I |
| Epics Reviewed | 1 |
| Stories Reviewed | 3 |
| Total Suggestions | 0 |
| Accepted | 0 |
| Rejected | 0 |

---

## Domain Model

### Actors

| Actor | Epics Involved | Key Capabilities |
|---|---|---|
| Maintainer | 1 | Reads the Delivery Standard and names a new spec folder |
| Person starting Implement | 1 | Opens the existing folder from a ticket key alone |
| Agent searching by topic | 1 | Matches a folder name and a research heading |

### Entities

| Entity | Created In | Read In | Updated In | Deactivated/Deleted In |
|---|---|---|---|---|
| Spec folder name | Story 1.1 | Story 1.2 | — | — |
| Research heading | Story 1.3 | Story 1.2 (when choosing a file) | — | — |

### Key Relationships

- The Implement lookup uses the shape Story 1.1 documents. Two folders for one key stop the session instead of creating a third.
- The heading states the topic the folder suffix only labels. Existing files are not rewritten.

---

## Suggestions

No suggestions.

Passes that were considered and produced no change:

- **Pass A.** Renaming or deleting an old folder is out of scope. A new name is created with the folder.
- **Pass B / E.** Story 1.2 already guards the missing-folder and the two-folder cases.
- **Pass H.** A topic longer than three words is rejected by Story 1.1. A key-only folder is the old shape and is not created beside a topic folder.
- **Pass I.** No second person has to be notified when a folder is named.

---

## Summary of Changes Applied

No changes applied to `extracted-tasks.md` from this review.

The Jira shape is one Sub-task under AC-2, because AC-2 is a Task and its existing children (such as AC-22) are Sub-tasks. That is the user's "pod AC-2", not a quality-review suggestion.
