# Cursor Collection Migration — Quality Review Report

## Review Context

| Field | Value |
|---|---|
| Review Date | 2026-07-30 |
| Source Task List | `extracted-tasks.md` (Gate 1 approved) |
| Additional Sources | `intent-brief.md`; BRD; Jira DHI-515; legacy `setup-cursor-local.sh` MCP prompt |
| Review Mode | Full |
| Passes Run | A–J |
| Work Streams Reviewed | 6 |
| Stories Reviewed | 27 |
| Total Suggestions | 5 |
| Accepted | 4 |
| Rejected | 1 |

---

## Disposition Summary (Gate 1.5 closed)

| ID | Target | Action | Decision |
|----|--------|--------|----------|
| S-01 | Story 5.6 | ADD_ACCEPTANCE_CRITERION — partial failure + idempotent re-run | ✅ Accepted |
| S-02 | Story 5.6 | ADD_ACCEPTANCE_CRITERION — remove/change agent & MCP cleanup | ✅ Accepted |
| S-03 | Story 5.6 | ADD_ACCEPTANCE_CRITERION — guard unavailable adapters | ✅ Accepted |
| S-04 | Story 5.5 | ADD_ACCEPTANCE_CRITERION — upgrade reuses install selection | ✅ Accepted |
| S-05 | Story 6.4 | ADD_ACCEPTANCE_CRITERION — cross-repo doc pointer | ❌ Rejected — docs fully separated |

**Gate 1.5 closed:** 2026-07-30 — remaining Low findings deferred; proceed to Jira formatting.

---

## Domain Model

### Actors

| Actor | Work Streams | Key Capabilities |
|---|---|---|
| Framework maintainer | 1, 2, 4, 5, 6 | Extract core, build adapters, ship installer, docs site |
| Tech lead / EM | 1.7, 5, 6 | Choose agents/MCP/profile; enforce spec-driven delivery |
| Frontend developer | 2, 3 | Use Cursor adapter with scoped context |
| Backend developer | 2, 3 | Use Claude Code adapter with scoped context |
| EOG monorepo owner | 3, 6.3 | Pilot install and isolation validation |
| Consumer project owner | 1.6, 5.5 | Upgrade without losing local customizations |

### Entities

| Entity | Created In | Read In | Updated In | Deactivated/Deleted In |
|---|---|---|---|---|
| Core SSOT / rules | 1.2–1.5 | 2.x, 4.x, 5.x | 1.6, 5.5 | — (gap?) |
| Tool adapter output | 2.2–2.4 | 3.x, 5.6 | 2.5, 5.6 re-run | Partial (5.6 add-only) |
| Ignore files | 3.2 | 3.3, 5.6 | 2.5 sync | — |
| AGENTS.md | 4.1–4.2 | All agents | 5.2 install | — |
| Install selection (agents + MCP + profile) | 5.6 | 5.5 upgrade | 5.6 re-run (add agents) | — (remove/change gap) |
| Spec artifacts (research/plan) | 1.7 / inherited | Implement | DELTA/REFRESH | — |
| Docs site | 6.4 | Consumers | — | — |

### Key Relationships

- Adapters depend on Core SSOT being present and classified
- Install wizard depends on adapter generators existing for selected agents
- Isolation ignore files depend on which agents were selected
- Pilot (EOG) depends on installer + wizard + scoping
- Upgrade depends on recorded install selection state

---

## Suggestions

### Work Stream 5: Distribution & Replication

#### S-01 · High · ADD_ACCEPTANCE_CRITERION

**Target**: Story 5.6 — Interactive bash install wizard — AI agent and MCP selection

**Finding** (Pass H: Error State and Edge Case Coverage):
The wizard covers happy-path selection and re-run to *add* agents, but does not specify what happens when install fails partway (e.g. adapter generation succeeds, MCP merge fails) or how the user recovers a half-configured project.

**Proposed Change**:
Add to Story 5.6 acceptance criteria:
- [ ] GIVEN install fails after partial changes WHEN the wizard exits THEN it lists completed vs failed steps and points to recovery (re-run same selections, or documented rollback)
- [ ] GIVEN a re-run with the same agent/MCP/profile selections WHEN prior steps already succeeded THEN those steps are skipped or reapplied safely without duplicating or corrupting config

**Decision**: ✅ Accepted — applied to `extracted-tasks.md` Story 5.6

---

#### S-02 · High · ADD_ACCEPTANCE_CRITERION

**Target**: Story 5.6 — Interactive bash install wizard — AI agent and MCP selection

**Finding** (Pass A: Entity Lifecycle Completeness):
Install selection (agents + MCP) can be *created* and *extended* (add agents), but there is no clear story for *changing* or *removing* a previously selected agent or MCP server set. Upgrade (5.5) preserves customizations but does not define deselection.

**Proposed Change**:
Add to Story 5.6 acceptance criteria:
- [ ] GIVEN a previously installed agent WHEN the user re-runs install with that agent omitted (interactive or `--agents`) THEN the wizard either removes that adapter's generated outputs with an explicit confirm step, or documents that removal is a manual/out-of-band action — never silently leaves stale adapters undocumented
- [ ] GIVEN a change to the MCP server set WHEN re-run completes THEN `.cursor/mcp.json` (or equivalent) matches the new selection without leaving orphaned server entries from the prior set unless the user opts to keep them

**Decision**: ✅ Accepted — applied to `extracted-tasks.md` Story 5.6

---

#### S-03 · Medium · ADD_ACCEPTANCE_CRITERION

**Target**: Story 5.6 — Interactive bash install wizard — AI agent and MCP selection

**Finding** (Pass E: Precondition Guards):
The wizard can offer Claude Code, OpenCode placeholder, or Multi-agent before those adapters exist (Stories 2.2–2.4). Selecting an unavailable adapter would produce a broken install with no clear guard.

**Proposed Change**:
Add to Story 5.6 acceptance criteria:
- [ ] GIVEN the user selects an agent whose adapter is not yet available in this framework version WHEN install runs THEN the wizard blocks that choice (or offers placeholder-only with explicit warning) and does not claim a full adapter was installed
- [ ] GIVEN Multi-agent or OpenCode placeholder WHEN only a subset of adapters is shipped THEN the summary lists what was installed vs deferred

**Decision**: ✅ Accepted — applied to `extracted-tasks.md` Story 5.6

---

#### S-04 · Medium · ADD_ACCEPTANCE_CRITERION

**Target**: Story 5.5 — Document consumer upgrade path from central framework

**Finding** (Pass B: Cross-Feature State Validation):
Story 5.2/5.6 record which agents and MCP servers were selected, but Story 5.5 (upgrade) does not require reading that recorded selection. Upgrades could regenerate the wrong adapter set or drop MCP choices.

**Proposed Change**:
Add to Story 5.5 acceptance criteria:
- [ ] GIVEN a consumer with a recorded install selection (agents, MCP servers, domain profile) WHEN upgrade/sync runs THEN the process reuses that selection by default (unless the user explicitly changes it)
- [ ] GIVEN the recorded selection file is missing or corrupt WHEN upgrade runs THEN the process fails safely with guidance to re-run the install wizard — it does not silently invent a full multi-agent install

**Decision**: ✅ Accepted — applied to `extracted-tasks.md` Story 5.5

---

#### S-05 · Medium · ADD_ACCEPTANCE_CRITERION

**Target**: Story 6.4 — Migrate and rebrand Docusaurus documentation site

**Finding** (Pass F / dual-channel continuity):
Q3 keeps `cursor-collections` as a separate Cursor distribution channel. Story 6.4 migrates the docs site to `agent-collections`, but does not require the legacy channel to point consumers to the new docs — risk of split-brain documentation.

**Proposed Change**:
Add to Story 6.4 acceptance criteria:
- [ ] GIVEN `cursor-collections` remains a distribution channel WHEN the docs site lives in `agent-collections` THEN `cursor-collections` ships a clear pointer or redirect (README and/or site stub) to the Agent Collections documentation home
- [ ] GIVEN a consumer following Cursor-only install docs WHEN they land on the legacy channel THEN they can reach multi-agent / Agent Collections docs in one hop without hunting GitHub

**Decision**: ❌ Rejected — stakeholder: documentation of `agent-collections` and `cursor-collections` must be **fully separated**; no pointers, redirects, or doc channels connecting the repositories

---

## Gate 1.5 status

**Closed** — High/Medium suggestions resolved (S-01–S-04 accepted; S-05 rejected). Remaining findings Low — deferred.

Next: `jira-tasks.md` formatted; awaiting **Gate 2** push approval.
