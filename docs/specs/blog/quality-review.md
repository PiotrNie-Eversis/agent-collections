# Blog — Quality Review Report

## Review Context

| Field | Value |
|---|---|
| Review Date | 2026-09-24 |
| Source Task List | `extracted-tasks.md` (Story 1.1 approved; user directed the whole breakdown into one Jira Task) |
| Additional Sources | `cleaned-transcript.md`, `intent-brief.md` (Gate 0 approved) |
| Review Mode | Lite |
| Passes Run | A, B, E, H, I |
| Epics Reviewed | 3 |
| Stories Reviewed | 4 |
| Total Suggestions | 0 |
| Accepted | 0 |
| Rejected | 0 |

---

## Domain Model

### Actors

| Actor | Epics Involved | Key Capabilities |
|---|---|---|
| Reader | 1, 3 | Opens the blog, reads a post, finds it in search |
| Maintainer | 2, 3 | Applies the publishing rule, writes the post, gets human approval before it goes live |

### Entities

| Entity | Created In | Read In | Updated In | Deactivated/Deleted In |
|---|---|---|---|---|
| Blog section | Story 1.1 | Story 1.1, Story 1.2 | — | — |
| Technical change post | Story 3.1 | Story 1.1, Story 1.2 | — | — |
| Publishing rule | Story 2.1 | Story 3.1 | — | — |
| Changelog entry | — (already exists) | Story 3.1 | — | — |

### Key Relationships

- A technical change post is listed in the blog section — Story 1.1 and Story 3.1 ship together in one ticket, so the section does not go live empty.
- Story 3.1 depends on the publishing rule — the post must deepen the team notice and must not repeat it. Covered in Story 3.1 acceptance criteria.
- The post points at a changelog entry. The changelog itself is out of scope for edits.

---

## Suggestions

No suggestions.

Passes that were considered and produced no change:

- **Pass A (lifecycle).** A later edit of a post is the same as editing any other page on this docs site. Deleting a post was not discussed. Neither becomes a story.
- **Pass B / E (state and preconditions).** Human approval before publish, and the ban on copying the team message, are already acceptance criteria on Stories 2.1 and 3.1.
- **Pass H (empty and error states).** An empty blog does not ship: the first post is in the same ticket as the section. A failed search is ordinary site search, already required to keep returning docs.
- **Pass I (notification).** The team message is the notice. A separate alert when the post goes live was excluded (no newsletter).

---

## Summary of Changes Applied

No changes applied to `extracted-tasks.md` from this review.

The Jira shape is one Task, by the user's instruction on 2026-09-24, not by a quality-review suggestion.
