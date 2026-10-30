# start-here-onboarding-ux — Quality Review Report

## Review Context

| Field | Value |
|---|---|
| Review Date | 2026-10-13 |
| Source Task List | `extracted-tasks.md` (Gate 1 approved) |
| Additional Sources | `cleaned-transcript.md`, `intent-brief.md`, live `start-here.md`, AC-35/AC-36 overlap |
| Review Mode | Lite |
| Passes Run | A, B, E, H, I |
| Epics Reviewed | 2 |
| Stories Reviewed | 5 |
| Total Suggestions | 3 |
| Accepted | 3 |
| Rejected | 0 |
| Pending | 0 |

---

## Domain Model

### Actors

| Actor | Epics Involved | Key Capabilities |
|---|---|---|
| QA / BA / PO | 1, 2 | Choose path, open Prerequisites/Installation, confirm success |
| Developer / QA Tech | 1 | Cursor or Claude Code path |
| Maintainer / MCP developer | 1 | MCP setup / Node depth |
| Documentation maintainer | 1, 2 | Edit Start here, verify links and build |

### Entities

| Entity | Created In | Read In | Updated In | Deactivated/Deleted In |
|---|---|---|---|---|
| Start here page content | Stories 1.1–1.4 | All readers | Same | — |
| Role path (table/tabs) | Story 1.2 | Story 1.2 | Story 1.2 | Replaces dual checklists |
| Success criteria block | Story 1.3 | Story 1.3 | Story 1.3 | — |
| Internal doc links | Story 2.1 | All | Story 2.1 + Epic 1 rewrite | — |

### Key Relationships

- Start here must **point to** Prerequisites/Installation without re-owning their prose (Stories 1.1, 1.2).
- Role path for QA/BA should not skip Prerequisites before Installation (Pass E).
- Link integrity re-verified after rewrite (Story 2.1 depends on Epic 1).

---

## Suggestions

### Epic 1: Start here — onboarding map rewrite

#### S-01 · High · ADD_ACCEPTANCE_CRITERION

**Target**: Story 1.2 — Role-based path instead of two unlabeled checklists

**Finding** (Pass E: Precondition guards):
Role table could send QA/BA straight to Installation and skip Prerequisites.

**Proposed Change**:
Add AC: QA/BA/PO path links Prerequisites before or together with Installation.

**Decision**: ✅ Accepted — applied to `extracted-tasks.md` 2026-10-13.

#### S-02 · High · ADD_ACCEPTANCE_CRITERION

**Target**: Story 1.1 — Short Prerequisites pointer on Start here

**Finding** (Pass B/H): Shortening could leave only a naked link; scanners need the three tools named inline.

**Proposed Change**:
Add AC: short step still names AI editor, Docker Desktop, and Git before the link.

**Decision**: ✅ Accepted — applied to `extracted-tasks.md` 2026-10-13.

---

### Cross-cutting

#### S-03 · Medium · JIRA_STRUCTURE

**Target**: Jira push (Gate 2)

**Finding** (Pass I / traceability):
Start here rewrite continues/corrects onboarding work after AC-36 Prerequisites clarity.

**Proposed Change**:
Label `start-here-onboarding`; **Relates to** [AC-36](https://eversis.atlassian.net/browse/AC-36) on epics.

**Decision**: ✅ Accepted — human confirmed Relates to **AC-36** (2026-10-13).

---

## Summary

Lite review complete. S-01 and S-02 applied to `extracted-tasks.md`. S-03 applies at Gate 2 push (Relates to AC-36, label `start-here-onboarding`).
