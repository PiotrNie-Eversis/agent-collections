# Chrome DevTools MCP — Quality Review Report

## Review Context

| Field | Value |
|---|---|
| Review Date | 2026-10-15 |
| Source Task List | `extracted-tasks.md` (Gate 1 approved) |
| Additional Sources | `intent-brief.md` (Gate 0 approved). No transcript. Jira board not requested. |
| Review Mode | Lite |
| Passes Run | A, B, E, H, I |
| Epics Reviewed | 3 |
| Stories Reviewed | 6 |
| Total Suggestions | 4 |
| Accepted | 4 |
| Rejected | 0 |

Passes A (entity lifecycle), B (cross-feature state), and I (notifications) produced no suggestions. The catalog entry is created in story 1.1 and explained in story 1.2; opting out is the deactivation path. Stories 2.2, 3.1, and 3.2 already branch on whether the integration is enabled. No second actor needs a notification when the catalog changes.

---

## Domain Model

### Actors

| Actor | Epics Involved | Key Capabilities |
|---|---|---|
| Framework maintainer | 1 | Offers Chrome DevTools as an optional, off-by-default catalog entry |
| Consumer choosing integrations | 1 | Reads the catalog and opts in with Chrome installed |
| UI reviewer | 2 | Verifies a running screen against a design with Playwright |
| E2E engineer | 2 | Explores flows with Playwright |
| Software engineer | 2, 3 | Uses Chrome DevTools for console, network, trace, and Lighthouse only when it is enabled; still needs a performance baseline when it is not |

### Entities

| Entity | Created In | Read In | Updated In | Deactivated/Deleted In |
|---|---|---|---|---|
| Chrome DevTools catalog entry | 1.1 | 1.2, 2.2, 3.1, 3.2 | — | Not selected at install (1.1) |
| Playwright catalog entry | Already shipped | 1.1, 2.1, 2.2 | — | — |
| Browser job-split guidance | 2.2 | 3.1, 3.2 | — | — |
| Performance-skill measurement rule | 3.1, 3.2 | 3.1, 3.2 | — | — |

### Key Relationships

- The performance skill depends on the catalog entry being enabled and Chrome being able to start — guarded in stories 3.1, 3.2, and 2.2.
- UI verification depends on the Playwright entry staying unchanged — guarded in stories 1.1 and 2.1.
- Diagnosis must not fall through to Playwright when Chrome DevTools is enabled but Chrome cannot start — guarded in story 2.2.

---

## Suggestions

### Epic 1: Optional Chrome DevTools catalog entry

#### S-01 · High · ADD_ACCEPTANCE_CRITERION

**Target**: Story 1.2 — Catalog explains purpose, Chrome-only support, and privacy opt-outs

**Finding** (Pass H: Error State and Edge Case Coverage):
The page says the server is Chrome-only, but not that Chrome must be installed, nor what the consumer sees when they opt in without it. The server then fails to start.

**Proposed Change**:
Add to Story 1.2 acceptance criteria:
- [ ] GIVEN a consumer opens the Chrome DevTools catalog page WHEN they check requirements THEN the page states that current stable Chrome or Chrome for Testing must be installed.
- [ ] GIVEN the consumer opted in AND Chrome is not installed WHEN an agent tries to use the integration THEN the documented outcome is that the integration cannot start until Chrome is installed.

**Decision**: ✅ Accepted

---

### Epic 2: Browser job split in agent guidance

#### S-02 · High · ADD_ACCEPTANCE_CRITERION

**Target**: Story 2.2 — Diagnosis and performance name Chrome DevTools only as the opt-in tool

**Finding** (Pass H: Error State and Edge Case Coverage):
The story covers enabled and disabled states. It does not cover the enabled state when Chrome cannot start. An agent could then use Playwright for console, network, or trace work.

**Proposed Change**:
Add to Story 2.2 acceptance criteria:
- [ ] GIVEN Chrome DevTools is enabled AND Chrome cannot be started WHEN the agent needs console, network, trace, or Lighthouse evidence THEN the guidance tells the agent to report that blocker and not to use Playwright as a substitute for that diagnosis.

**Decision**: ✅ Accepted

---

### Epic 3: Frontend performance uses a trace only when enabled

#### S-03 · High · ADD_ACCEPTANCE_CRITERION

**Target**: Story 3.1 — Performance skill records a trace when Chrome DevTools is enabled

**Finding** (Pass H: Error State and Edge Case Coverage):
The story requires a trace before optimization, but not the outcome when the recording fails. The agent could still present optimizations as if a baseline existed.

**Proposed Change**:
Add to Story 3.1 acceptance criteria:
- [ ] GIVEN Chrome DevTools is enabled AND a performance trace cannot be recorded WHEN the agent follows the frontend performance skill THEN it reports that the measurement failed and does not present optimizations as if a baseline existed.

**Decision**: ✅ Accepted

---

#### S-04 · High · ADD_ACCEPTANCE_CRITERION

**Target**: Story 3.2 — Performance skill does not call Chrome DevTools when it is off

**Finding** (Pass E: Precondition Guards):
The disabled path forbids calling the missing tool and still requires a baseline. It does not tell the engineer in the session that a performance trace becomes available after opting in.

**Proposed Change**:
Add to Story 3.2 acceptance criteria:
- [ ] GIVEN Chrome DevTools is not enabled WHEN the agent follows the frontend performance skill THEN it tells the engineer that a performance trace is available after opting in, and it still does not call Chrome DevTools tools.

**Decision**: ✅ Accepted

---

## Applied Changes Summary

| # | Suggestion | Action | Target |
|---|---|---|---|
| S-01 | Document the Chrome install prerequisite and the failure when it is missing | ADD_ACCEPTANCE_CRITERION | Story 1.2 |
| S-02 | Do not substitute Playwright when enabled Chrome cannot start | ADD_ACCEPTANCE_CRITERION | Story 2.2 |
| S-03 | Report a failed trace and do not optimize as if a baseline existed | ADD_ACCEPTANCE_CRITERION | Story 3.1 |
| S-04 | On the disabled path, say that opt-in unlocks a trace, without calling the tool | ADD_ACCEPTANCE_CRITERION | Story 3.2 |

**Updated Totals**: 3 epics (unchanged), 6 stories (unchanged, 4 stories gained acceptance criteria)

## Rejected Suggestions

| # | Suggestion | Confidence | Reason |
|---|---|---|---|
| — | None | — | — |
