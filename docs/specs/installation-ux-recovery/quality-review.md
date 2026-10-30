# installation-ux-recovery — Quality Review Report

## Review Context

| Field | Value |
|---|---|
| Review Date | 2026-10-14 |
| Source Task List | `extracted-tasks.md` (Gate 1 approved) |
| Additional Sources | UX audit `source-ux-audit.md`; current `website/docs/getting-started/installation.md`; `intent-brief.md`; baseline `docs/context/agent-collections/task-baseline.md` |
| Review Mode | Lite |
| Passes Run | A, B, E, H, I |
| Epics Reviewed | 1 |
| Stories Reviewed | 7 |
| Total Suggestions | 3 |
| Accepted | 3 |
| Rejected | 0 |

---

## Domain Model

### Actors

| Actor | Epics Involved | Key Capabilities |
|---|---|---|
| QA / BA / Product Owner | 1 | Follow 3-step install; default command; recognize success |
| Developer / technical QA | 1 | Same happy path; upgrade / vendor later |
| Framework maintainer | 1 | Adapter sync / open-framework only in advanced |

### Entities

| Entity | Created In | Read In | Updated In | Deactivated/Deleted In |
|---|---|---|---|---|
| Installation page (docs) | 1.1–1.7 (rewrite) | All stories | All stories | — |
| Framework checkout (`AGENT_COLLECTIONS_HOME`) | 1.2, 1.3 | 1.4 | — | — |
| Consumer install selection | 1.4 | 1.5 | 1.6 (upgrade) | — |
| Context INDEX scaffold | 1.4 | 1.5 | — | — |

### Key Relationships

- Install command (1.4) depends on mental model (1.2) and OS path (1.3).
- Verification (1.5) depends on recommended install (1.4).
- Prerequisites / Docker Engine enable `--build-mcp` install — precondition guard candidate (S-01).
- Failed verification should route to short recovery cues (S-02).
- Wrong working directory / unset home is a common failure (audit §2.D) — S-03.

---

## Suggestions

### Epic 1: Installation page: guided onboarding and DevEx recovery

#### S-01 · High · ADD_ACCEPTANCE_CRITERION

**Target**: Story 1.4 — Reader runs one recommended install command in their project

**Finding** (Pass E: Precondition Guards):
Step 2’s recommended command includes `--build-mcp`. Story 1.1 links Prerequisites at the top, but Step 2 itself does not restate that Docker must already be running. Cold readers who jump to the command can fail without a local recovery cue.

**Proposed Change**:
Add to Story 1.4 acceptance criteria:
- [ ] GIVEN I am about to run the recommended install command WHEN I read Step 2 THEN I see a clear reminder that Docker Desktop/Engine must be running (with a link to Prerequisites), and what failure symptom means Docker is not ready.

**Decision**: ✅ Accepted

---

#### S-02 · High · ADD_ACCEPTANCE_CRITERION

**Target**: Story 1.5 — Reader verifies that installation succeeded

**Finding** (Pass H: Error State & Edge Case Coverage):
Verification covers success artifacts and next-step to MCP Setup, but not what to do when checks fail.

**Proposed Change**:
Add to Story 1.5 acceptance criteria:
- [ ] GIVEN verification fails (missing selection file, missing context INDEX, or installer error) WHEN I read Verification THEN I see a short recovery checklist (at least: correct project folder, `AGENT_COLLECTIONS_HOME` set, Docker running / Prerequisites) before being left only with a next-step to MCP Setup.

**Decision**: ✅ Accepted

---

#### S-03 · Medium · ADD_ACCEPTANCE_CRITERION

**Target**: Story 1.2 — Reader understands framework vs consumer project

**Finding** (Pass B / H — audit §2.D):
The audit calls out running the installer inside the framework repo as a frequent mistake. Story 1.2 explains the two folders but does not require an explicit anti-pattern warning.

**Proposed Change**:
Add to Story 1.2 acceptance criteria:
- [ ] GIVEN I might confuse the two folders WHEN I read the mental-model section THEN I see an explicit warning not to run the installer from inside the `agent-collections` framework checkout.

**Decision**: ✅ Accepted

---

## Pass Notes (no suggestion)

| Pass | Result |
|---|---|
| A | N/A for docs-page rewrite — no product CRUD entity lifecycle gaps |
| I | N/A — documentation page; no actor-to-actor notifications |

---

## Changes Applied to Task List

| Suggestion | Change |
|---|---|
| S-01 | Story 1.4 — added Docker/Prerequisites precondition AC before recommended install command |
| S-02 | Story 1.5 — added short recovery checklist AC when verification fails |
| S-03 | Story 1.2 — added explicit warning AC not to run installer inside framework checkout |

## Summary

Lite review: **3/3 accepted**, 0 rejected. `extracted-tasks.md` updated in place. Ready for Jira formatting after user confirms the updated task list.
