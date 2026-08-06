# DHI-542 — EOG pilot evidence pack

**Date:** 2026-08-06  
**Consumer path surveyed:** `/Users/piotrniemirski/Documents/Projects/eog` (read-only survey + proxy measurement)  
**Framework:** Agent Collections at local checkout (Wave D implement session)

## Scope delivered in this repository

| Item | Status |
|------|--------|
| Consumer overlay documentation (`portal`/`cms` → abstract classes) | **Done** — [README.md](./README.md) |
| WNF-03 §7.2 file-count proxy (U vs S) | **Done** — numbers below (≥30%) |
| Collision checklist (template + known baseline from survey) | **Done** — below |
| Upgrade runbook | **Done** — [upgrade-runbook.md](./upgrade-runbook.md) |
| Migration guide refresh pointer | **Done** — see getting-started migration (EOG section) |
| Live installer run + submodule pin inside EOG | **Residual** — out-of-repo; blocked from this workspace session (see Residual) |
| ≥5 business days or ≥3+3 FE/BE agent sessions | **Residual** — requires human-led pilot window (Q5) |

## WNF-03 proxy measurement (Q6)

**Method:** isolation-strategy §7.2 — **file count** of text-ish files (exclude `node_modules`, `dist`, `build`, `.next`, `.git`, binary/media suffixes).

**Unscoped set \(U\):** all countable files under the EOG monorepo root after excludes → **4035**.

**Scoped sets \(S\):**

| Area (consumer map) | Paths in \(S\) | \|S\| | Reduction \(1 - \|S\|/\|U\|\) |
|---------------------|----------------|------|-------------------------------|
| Frontend-scope ≈ portal | `portal/**` + `docs/**` + `scripts/**` | 748 | **81.5%** |
| Backend-scope ≈ cms | `cms/**` + `docs/**` + `scripts/**` | 1448 | **64.1%** |

**Verdict:** Both areas meet the **≥30%** WNF-03 target under this proxy. Heavy infra trees (nginx sidecars, charts, databases, handbooks, load-test, …) dominate the unscoped remainder — aligning with §6 defaults.

**Caveats:** Proxy is file count, not IDE token telemetry. Own-tool vs other-tool packaging deltas are small relative to infra volume; still apply the ignore triad when both Cursor and Claude are installed.

## Collision checklist (Q5)

Use during the human pilot window (≥5 business days **or** ≥3 Cursor FE + ≥3 Claude BE sessions):

| Check | Pass criteria | Survey baseline (2026-08-06) |
|-------|---------------|------------------------------|
| MCP skills env | `eversis-collections` uses `AGENT_COLLECTIONS_HOME` only | **Fail until cutover** — EOG still references `CURSOR_COLLECTIONS_HOME` in `.cursor/mcp.json` |
| Other-tool packaging | Claude does not index `.cursor/**`; Cursor does not index `CLAUDE.md` as primary dump | Not verified in live session — verify after dual-agent install |
| Area leak | FE session does not pull large `cms/**` trees by default | Overlay documented; live session residual |
| Infra noise | Heavy infra not in default indexed set | Supported by proxy (U≫S) |
| Dual installer conflict | No parallel `setup-cursor-local.sh` + Agent Collections skills path | Residual until cutover |

**Incidents:** none recorded in this implement session (no live dual-agent sessions executed here).

## Residual out-of-repo steps (honest)

1. On an EOG **pilot branch**, add `agent-collections` as submodule (or local `AGENT_COLLECTIONS_HOME`) pinned to a SemVer tag.
2. Run `setup-agent-collections.sh --agents=cursor,claude --profile=fullstack --build-mcp` (team: `--vendor submodule`).
3. Replace `CURSOR_COLLECTIONS_HOME` → `AGENT_COLLECTIONS_HOME` in MCP; keep other EOG MCP servers.
4. Apply consumer ignore overlay for `portal`/`cms` vs heavy infra (do not edit framework profiles).
5. Execute Q5 session quota; fill collision checklist results into this file.
6. Feed any new findings into [findings-backlog.md](./findings-backlog.md) and the migration guide.

## D8–D11 mapping

| AC | Evidence |
|----|----------|
| D8 | Overlay + checklist ready; live dual-agent period = residual |
| D9 | [upgrade-runbook.md](./upgrade-runbook.md) |
| D10 | Proxy ≥30% both areas (table above) |
| D11 | This folder + migration guide EOG section + findings backlog draft |
