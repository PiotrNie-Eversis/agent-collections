# TASK-542 — EOG pilot evidence pack

**Date:** 2026-08-06 (survey) · **Updated:** 2026-08-07 (live install + Phase A/B implement)  
**Consumer surveyed:** EOG monorepo (local clone)  
**Framework:** Agent Collections via `AGENT_COLLECTIONS_HOME` (**local** vendor mode for Q5)

## Scope delivered

| Item | Status |
|------|--------|
| Consumer overlay documentation (`portal`/`cms` → abstract classes) | **Done** — [README.md](./README.md) |
| WNF-03 §7.2 file-count proxy (U vs S) | **Done** — numbers below (≥30%) |
| Collision checklist (template + known baseline from survey) | **Done** — below (update after Q5 sessions) |
| Upgrade runbook | **Done** — [upgrade-runbook.md](./upgrade-runbook.md) |
| Migration guide refresh pointer | **Done** — getting-started migration (EOG section) |
| Live installer run inside EOG | **Done (local)** — branch `agent-collections`; cursor+claude; fullstack; MCP on `AGENT_COLLECTIONS_HOME` |
| Consumer **2a** heavy-infra ignore overlay | **Reverted (2026-08-07)** — `charts/` + handbooks are active apps; `# eog-pilot-overlay` removed; area-scope no longer excludes `charts/**` |
| EOG `AGENTS.md` + `eversis-project-stack.mdc` customization | **Done** (pilot implement 2026-08-07) |
| Submodule pin to SemVer tag | **Deferred** — after Q5 (research Q1) |
| ≥5 business days or ≥3+3 FE/BE agent sessions | **Scheduled** — start **2026-08-10**, owner **Piotr Niemirski** |

## WNF-03 proxy measurement (Q6)

**Method:** isolation-strategy §7.2 — **file count** of text-ish files (exclude `node_modules`, `dist`, `build`, `.next`, `.git`, binary/media suffixes).

**Unscoped set \(U\):** all countable files under the EOG monorepo root after excludes → **4035**.

**Scoped sets \(S\):**

| Area (consumer map) | Paths in \(S\) | \|S\| | Reduction \(1 - \|S\|/\|U\|\) |
|---------------------|----------------|------|-------------------------------|
| Frontend-scope ≈ portal | `portal/**` + `docs/**` + `scripts/**` | 748 | **81.5%** |
| Backend-scope ≈ cms | `cms/**` + `docs/**` + `scripts/**` | 1448 | **64.1%** |

**Verdict:** Both areas meet the **≥30%** WNF-03 target under this proxy. Heavy infra trees (nginx sidecars, charts, databases, handbooks, load-test, …) dominate the unscoped remainder — aligning with §6 defaults.

**Caveats:** Proxy is file count, not IDE token telemetry. EOG treats `charts/` and handbook trees as **product apps**, not heavy infra — do not exclude them from Cursor indexing.

## Collision checklist (Q5)

Use during the human pilot window (≥5 business days **or** ≥3 Cursor FE + ≥3 Claude BE sessions).  
**Window:** starts **2026-08-10** · **Owner:** Piotr Niemirski

| Check | Pass criteria | Status (2026-08-07) |
|-------|---------------|---------------------|
| MCP skills env | `eversis-collections` uses `AGENT_COLLECTIONS_HOME` only | **Pass (config)** — live `mcp.json` cut over; confirm Cursor env + `eversis_skills_list` in-session |
| Other-tool packaging | Claude does not index `.cursor/**`; Cursor does not treat `CLAUDE.md` as primary dump | Dual-agent installed; **verify in Q5 sessions** |
| Area leak | FE session does not pull large unrelated trees by default | Soft session discipline; **no** hard product-app excludes |
| Infra noise | True sidecars (nginx/DB) optional | **No blanket product exclude** — charts/handbooks must stay visible |
| Dual installer conflict | No parallel `setup-cursor-local.sh` + Agent Collections skills path | Deprecation note in EOG `AGENTS.md` / README — **verify no dual use in Q5** |

**Incidents:** none recorded yet (Q5 not started).

## Residual steps

1. ~~Live installer + MCP env cutover~~ — done (local).  
2. ~~Consumer ignore overlay~~ — **reverted**; keep product apps (`charts/`, handbooks) indexable.  
3. ~~Customize AGENTS + project-stack~~ — done.  
4. **Q5 sessions** from 2026-08-10 — fill checklist outcomes above.  
5. **Submodule + SemVer pin** after Q5 (team-ready).  
6. Optional: delete residual LF-named (`\n`) directory in EOG if still present (F7).  
7. Feed new findings into [findings-backlog.md](./findings-backlog.md).

## D8–D11 mapping

| AC | Evidence |
|----|----------|
| D8 | Overlay + checklist; live dual-agent period = Q5 from 2026-08-10 |
| D9 | [upgrade-runbook.md](./upgrade-runbook.md) |
| D10 | Proxy ≥30% both areas (table above) |
| D11 | This folder + migration guide EOG section + findings backlog |
