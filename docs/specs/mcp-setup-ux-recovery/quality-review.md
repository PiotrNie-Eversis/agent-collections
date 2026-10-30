# mcp-setup-ux-recovery — Quality Review Report

## Review Context

| Field | Value |
|---|---|
| Review Date | 2026-10-14 |
| Source Task List | `extracted-tasks.md` (Gate 1 approved) |
| Additional Sources | UX audit attachment for `/docs/getting-started/mcp-setup`; current `website/docs/getting-started/mcp-setup.md`; `intent-brief.md`; baseline `docs/context/agent-collections/task-baseline.md` |
| Review Mode | Lite |
| Passes Run | A, B, E, H, I |
| Epics Reviewed | 1 |
| Stories Reviewed | 8 |
| Total Suggestions | 4 |
| Accepted | 4 |
| Rejected | 0 |

---

## Domain Model

### Actors

| Actor | Epics Involved | Key Capabilities |
|---|---|---|
| QA / BA / Product Owner | 1 | Follow Cursor-first core MCP setup; verify success; self-recover |
| Developer / technical QA | 1 | Cursor or Claude Code path; optional integrations later |
| Framework maintainer | 1 | Advanced path labeled only; not primary Getting Started |

### Entities

| Entity | Created In | Read In | Updated In | Deactivated/Deleted In |
|---|---|---|---|---|
| MCP Setup page (docs) | 1.1–1.8 (rewrite) | All stories | All stories | — |
| Core `eversis-collections` connection | 1.3, 1.4 | 1.5, 1.6 | 1.4 (enable vs duplicate) | 1.8 (remove duplicate) |
| Optional MCP integrations | 1.7 (documented) | 1.7 | — | — |
| Troubleshooting knowledge | 1.8 | 1.5, 1.8 | — | — |

### Key Relationships

- Core server connection depends on Prerequisites / Docker Engine — guarded in Story 1.3 (S-01).
- Verification (1.5) depends on client connect (1.4); failure routes to Troubleshooting (1.8).
- Installer-written project MCP config and manual GUI add must not conflict — Stories 1.4 + 1.8 (S-03, S-04).
- Optional integrations must not block first core success — Story 1.7.

---

## Suggestions

### Epic 1: MCP Setup page: guided onboarding and DevEx recovery

#### S-01 · High · ADD_ACCEPTANCE_CRITERION

**Target**: Story 1.3 — Reader can complete core local server setup first

**Finding** (Pass E: Precondition Guards):
Setup assumes Docker Engine and Prerequisites are already done. Without a top-of-page callout, cold readers may start Step 1 unprepared.

**Proposed Change**:
Add to Story 1.3 acceptance criteria:
- [ ] GIVEN I open MCP Setup before finishing Prerequisites WHEN I read the top of the page THEN I see a clear link/callout that Docker Engine (and the Prerequisites checklist) must be ready before Step 1.

**Decision**: ✅ Accepted

---

#### S-02 · High · ADD_ACCEPTANCE_CRITERION

**Target**: Story 1.5 — Reader verifies that MCP connected successfully

**Finding** (Pass H / IA gap):
Audit ends with Quick Wins / Main Flow links; verification had no AC that success hands the reader a clear next Getting Started step.

**Proposed Change**:
Add to Story 1.5 acceptance criteria:
- [ ] GIVEN verification succeeds WHEN I reach the end of the verification (or page footer) THEN I see clear next-step links to continue Getting Started (at least Quick Wins; Main Flow optional if that route stays in the IA).

**Decision**: ✅ Accepted

---

#### S-03 · High · ADD_ACCEPTANCE_CRITERION

**Target**: Story 1.4 — Reader connects the core server in their AI editor via client tabs

**Finding** (Pass B: Cross-Feature State Validation):
Audit emphasizes manual GUI add; installer already writes project MCP config. Without guidance, readers create duplicate User vs project `eversis-collections` entries.

**Proposed Change**:
Add to Story 1.4 acceptance criteria:
- [ ] GIVEN the installer already wrote the project MCP config WHEN I follow the Cursor (or Claude Code) connect steps THEN the page tells me whether to enable the existing entry, avoid duplicating it in User settings, or only add manually when the installer was not used — so I do not end up with two conflicting `eversis-collections` servers.

**Decision**: ✅ Accepted

---

#### S-04 · High · ADD_ACCEPTANCE_CRITERION

**Target**: Story 1.8 — Reader can self-recover via a troubleshooting table

**Finding** (Pass H: Error State & Edge Case Coverage):
S-03 prevents duplicates in happy path; readers who already duplicated need a Troubleshooting row with symptom → fix.

**Proposed Change**:
Add to Story 1.8 acceptance criteria:
- [ ] GIVEN I see two `eversis-collections` entries, wrong project tree, or flaky disconnect after “adding” the server again WHEN I open Troubleshooting THEN a row covers duplicate User vs project MCP config and tells me to keep the installer/project entry and remove the duplicate.

**Decision**: ✅ Accepted

---

### Pass notes (no further suggestions)

| Pass | Result |
|---|---|
| A (Entity Lifecycle) | N/A — docs page rewrite, not CRUD domain entities |
| I (Notifications) | N/A — no cross-actor state notifications |

---

## Applied Changes Summary

| # | Suggestion | Action | Target |
|---|---|---|---|
| S-01 | Prerequisites callout at page top | ADD_ACCEPTANCE_CRITERION | Story 1.3 |
| S-02 | Next-step links after verification | ADD_ACCEPTANCE_CRITERION | Story 1.5 |
| S-03 | Installer vs manual GUI — no duplicate servers | ADD_ACCEPTANCE_CRITERION | Story 1.4 |
| S-04 | Troubleshooting row for duplicate MCP | ADD_ACCEPTANCE_CRITERION | Story 1.8 |

**Updated Totals**: 1 epic, 8 stories (4 stories modified with new ACs; 0 new stories)

## Rejected Suggestions

| # | Suggestion | Confidence | Reason |
|---|---|---|---|
| — | None | — | — |
