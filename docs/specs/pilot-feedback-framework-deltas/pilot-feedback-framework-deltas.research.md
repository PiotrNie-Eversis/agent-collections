# Installer & area-profile UX deltas - Analysis Result

## Task Details

| Field | Value |
|---|---|
| Jira ID | **DHI-515** (Epic parent — file umbrella Story under this Epic) |
| Title | Installer messaging, interactive UX, and MCP wizard defaults |
| Source | `/eversis-implement` analysis — install/support feedback 2026-08-07 |
| Priority | Medium (UX / correctness of defaults) |
| Spec folder | `docs/specs/pilot-feedback-framework-deltas/` |
| Estimated Effort | Small–Medium (P0 + P2 + P3; P1.1 N/A this umbrella) |

## Business Impact

Consumer installs exposed gaps between **installer messaging / defaults** and **how teams work** (submodule, Claude Code, product trees whose names collide with generic “infra” excludes). Closing these in **agent-collections** reduces support load, failed MCP setups, and accidental exclusion of real application trees.

## Gathered Information

### Feedback themes

| # | Theme | Signal | Framework implication |
|---|--------|--------|------------------------|
| T1 | `AGENT_COLLECTIONS_HOME` unset → `/scripts/...` | Install one-liner fails when env empty | Docs/examples need `--collections-home` / early fail |
| T2 | Interactive agents/profile UX (Space/Enter) | Wanted parity with cursor-collections | **Implemented on disk, not committed** — `agents-prompt.mjs`, `profile-prompt.mjs` |
| T3 | MCP checkbox only with `--build-mcp` | Surprised without flag | Gate in `mcp-prompt.sh` ties interactive MCP to `--build-mcp` |
| T4 | Missing `.ai` in consumer (local mode) | Expected in-repo `.ai` | Summary partially clarifies; still easy to misread |
| T5 | Default area exclude `charts/**` | Consumer app trees named `charts/` get excluded | `area-fullstack.yaml` name collision |
| T6 | `.agent-collections/` folder | Unexpected vs cursor-collections | Needed for `--upgrade`; under-documented |
| T7 | Submodule “next step” text | Read as actionable work | Summary presents vendored path as a todo |
| T8 | Customise `eversis-project-stack.mdc` vs Claude | Claude does not load `.cursor/rules` | Summary always step 1 = Cursor stack file |
| T9 | Path policy | No machine-local absolutes in committed docs | Keep enforcing in docs/research |
| T10 | Team vendor mode | Prefer submodule for teams | Summary should document teammate `git submodule update --init --recursive` |

### Codebase (current)

| Area | State |
|------|--------|
| Installer summary | `scripts/lib/setup-agent-collections/summary.sh` — steps still confusing |
| Agents/profile prompts | New `*-prompt.mjs` on disk; **uncommitted** |
| MCP interactive | Still requires `--build-mcp` + TTY |
| Area fullstack exclude | `adapters/profiles/area-fullstack.yaml` → `charts/**` |
| AGENTS template | Local/vendor wording improved (in progress / uncommitted) |
| Selection dir | `.agent-collections/install-selection.json` — by design (`docs/architecture/install-selection.md`) |

### Relevant Links

- `docs/architecture/install-selection.md` — why `.agent-collections` exists  
- `docs/architecture/isolation-strategy.md` §6 — heavy infra class (abstract)  
- `adapters/claude/README.md` — consumer stack not in `CLAUDE.md`; Cursor-owned `.mdc`

## Proposed changes (agent-collections only)

### P0 — Ship / finish

| ID | Change | Why | Likely files |
|----|--------|-----|--------------|
| **P0.1** | Commit + CHANGELOG: interactive agents checkbox + profile select UI | Requested; matches cursor-collections | `agents.sh`, `profile.sh`, `*-prompt.mjs`, `common.sh` |
| **P0.2** | Rewrite installer **Next steps** (action-oriented, agent-aware) | T7/T8 | `summary.sh` |

**P0.2 suggested step logic:**

```text
If cursor in SELECTED_AGENTS:
  N. Customise .cursor/rules/eversis-project-stack.mdc
If claude in SELECTED_AGENTS:
  N. Customise AGENTS.md (stack / areas / skills policy — Claude + shared map)
If vendorMode is submodule|copy:
  N. (Done) Framework is at vendor/agent-collections — no further action for installer
  N+1. Teammates after clone: git submodule update --init --recursive
Else local:
  N. Export AGENT_COLLECTIONS_HOME=…
Enable MCP / restart (path hint by mode)
```

### P1 — Area-profile defaults

| ID | Change | Status |
|----|--------|--------|
| **P1.1** | Change default `charts/**` exclude in `area-fullstack.yaml` | **N/A for this umbrella (Q2)** — defer; do not include in plan/PR |

### P2 — Installer behavior

| ID | Change | Why |
|----|--------|-----|
| **P2.1** | Interactive MCP selection without requiring `--build-mcp` (still build when dist missing) | Wizard expected whenever interactive; `--build-mcp` = force rebuild |
| **P2.2** | Guard / document empty `AGENT_COLLECTIONS_HOME` for one-liner installs | Fail clear or require `--collections-home` |

### P3 — Docs

| ID | Change | Why |
|----|--------|-----|
| **P3.1** | Document `.agent-collections/` purpose (install selection / upgrade) | T6 |
| **P3.2** | Document Claude: stack in `AGENTS.md`, not Cursor stack `.mdc` | T8 |
| **P3.3** | Document teammate submodule init in getting-started / migration | T10 |
| **P3.4** | Optional: align `scaffolding.sh` copy with summary | Consistency |

### P4 — Optional / later

| ID | Change | Why |
|----|--------|-----|
| **P4.1** | Slim `.agent-collections` to selection-only or relocate | Cosmetic; not required |
| **P4.2** | Generic heavy-infra exclude pack | Optional later; independent of this umbrella (P1.1 deferred) |

## Gap Analysis

### Question 1
#### Scope: one umbrella story or split tickets?
**Locked:** **U1** — single umbrella Story (installer UX + summary + MCP gate + docs). Parent Epic: [DHI-515](https://eversis.atlassian.net/browse/DHI-515).

### Question 2
#### P1.1 — remove vs rename `charts/**`?
**Locked:** **NOT APPLICABLE** — out of this umbrella; leave `area-fullstack.yaml` unchanged for this workstream.

### Question 3
#### P2.1 — decouple MCP UI from `--build-mcp`?
**Locked:** **YES**

### Question 4
#### Bundle P0.1 + P0.2 in one PR?
**Locked:** **Same PR** (include P2.1 + P3 docs in that PR unless plan phases say otherwise)

### Question 5
#### Create Jira issues from this list?
**Locked:** Track under **DHI-515** (Epic: *Multi-Agent AI Context Isolation & Standard*). Create one child Story for this umbrella after research/plan approval (not auto-published).

## Out of scope

- Consumer product application code (handled in the consumer repo directly)  
- **P1.1** `charts/**` area-profile default change (Q2 N/A)  
- Changing Q7 (no client folder names in framework area profiles)  
- P4 optional later items  

## Suggested next steps

1. ~~Human locks Q1–Q5.~~ **Done 2026-08-07.**  
2. ~~Approve this research~~ — plan authored 2026-08-07.  
3. Human **approve** [`pilot-feedback-framework-deltas.plan.md`](./pilot-feedback-framework-deltas.plan.md).  
4. On plan approval: create DHI child Story under Epic DHI-515 (explicit human OK), then implement (same PR).  

## Open questions for human (lock before plan)

- [x] Q1 — **U1** umbrella  
- [x] Q2 — **N/A** (P1.1 deferred)  
- [x] Q3 — **Yes** decouple MCP UI  
- [x] Q4 — **Same PR**  
- [x] Q5 — **DHI-515** Epic parent  

**Gate:** Approve plan → implement.

## Changelog

| Date | Change |
|------|--------|
| 2026-08-07 | **CREATE** — framework deltas from install feedback |
| 2026-08-07 | **DELTA** — strip consumer-repo specifics; research is agent-collections-only |
| 2026-08-07 | **DELTA** — locks: U1, P1.1 N/A, MCP Yes, Same PR, Jira DHI-515 |
| 2026-08-07 | **DELTA** — research approved for planning; plan file created |
