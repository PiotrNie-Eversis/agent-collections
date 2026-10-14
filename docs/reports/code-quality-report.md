# Code Quality Report - agent-collections

## Overview

| Field | Value |
|---|---|
| Repository | agent-collections |
| Repository Type | Framework monorepo (`.ai/`, `adapters/`, `mcp/`, `website/`, `scripts/`) |
| Date | 2026-10-13 |
| Layers/Apps Analyzed | **Focused delivery audit:** Epic [AC-36](https://eversis.atlassian.net/browse/AC-36) (Prerequisites clarity) vs live docs — not a full-repo dead-code sweep |
| Prompt | `/eversis-review-codebase` with user focus: *sprawdź czy epic AC-36 został w pełni wdrożony* |

## Executive Summary

**Verdict: content for AC-36 is fully implemented in the docs; the Jira epic/tasks are not closed.**

All four active child **Tasks** under AC-36 (AC-47, AC-48, AC-49, AC-46) plus the post-implement **VS Code delta** are present on `website/docs/getting-started/prerequisites.mdx`. Plan acceptance criteria in `docs/specs/ac-36-prerequisites-clarity/` are checked. `npm run website:build` previously passed for this work.

**Caveats (not missing Prerequisites copy):**

1. **Jira hygiene** — Epic AC-36 and Tasks AC-46–AC-49 remain **Backlog** while superseded Stories AC-39–AC-42 are **Done**. Board state does not reflect delivery.
2. **Start here alignment** — AC-36 originally lengthened Start here step 1 (Node / VS Code / accounts). Epic [AC-56](https://eversis.atlassian.net/browse/AC-56) later **intentionally shortened** Start here into a role map and pushed detail back to Prerequisites. That is by design for AC-56, not a regression of Prerequisites itself. Start here no longer repeats the full AC-36 VS Code / Node essay (Developer tab still points readers to Prerequisites for Node notes).

Out of AC-36 scope and **not** claimed done: AC-37 (Docker enterprise), AC-38 (TOC / troubleshooting).

---

## Findings by Layer/App

### AC-36 delivery audit (`website/docs/getting-started/`, Jira AC)

#### Dead Code

| # | Severity | Type | Location | Description |
|---|---|---|---|---|
| — | — | — | — | No dead-code pass for this focused audit. |

#### Duplications

| # | Severity | Type | Locations | Description | Recommendation |
|---|---|---|---|---|---|
| 1 | 🟢 | Docs overlap (historical) | `prerequisites.mdx`, former Start here step 1 | AC-36 briefly duplicated Prerequisites detail on Start here; AC-56 removed that duplication. | Keep Prerequisites as SSOT for tool detail; keep Start here as map (current AC-56 shape). |

#### Improvement Opportunities

| # | Severity | Category | Location | Description | Recommendation |
|---|---|---|---|---|---|
| 1 | 🟡 | Process / Jira | AC-36, AC-46–AC-49 | Content delivered; epic and active Tasks still **Backlog**. | Transition Tasks → Done (or verify then Done) and close Epic AC-36 when children are Done. |
| 2 | 🟢 | Traceability | `ac-36-prerequisites-clarity.plan.md` | Plan AC “Start here step 1 matches Node/Claude / VS Code” is stale relative to AC-56 rewrite. | Add Changelog note on AC-36 plan: Start here alignment **superseded by AC-56** (detail stays on Prerequisites). |
| 3 | 🟢 | Docs | `start-here.mdx` QA/BA tab | Short Prerequisites step names AI editor, Docker, Git but not VS Code (AC-56 intent). | No change required for AC-36 if Prerequisites remains SSOT; optional one-line “Claude Code path: see VS Code on Prerequisites” only if product wants it on the map. |

---

## AC matrix (epic scope)

| Source requirement | Evidence | Status |
|---|---|---|
| Cursor = GUI; Claude Code = CLI | `prerequisites.mdx` L21–22 (`How you use it` column) | ✅ Met |
| Recommend Cursor first if uncomfortable with terminal | Tip L13–14 | ✅ Met |
| Cursor-only: Node not required; Claude Code may need Node LTS | Node `:::info` L104–109; Claude Code install steps L45–46, L79–80 | ✅ Met |
| MCP developer Node requirement intact | L109 | ✅ Met |
| Cursor + Anthropic account / Tech Lead or IT | Table L21–22 (`Account before install`) | ✅ Met |
| Open Terminal / PowerShell before verification | L114–133 | ✅ Met |
| VS Code recommended for Claude Code QA path + official extension docs | Table L23; tip L14; macOS/Windows steps L48, L81; link `code.claude.com/docs/en/vs-code` | ✅ Met (delta) |
| Start here aligned with Node/Claude/VS Code messaging | `start-here.mdx` — short pointer + Developer tab “Node.js notes if you use Claude Code”; detail on Prerequisites | ⚠️ **Superseded by AC-56** (intentional shorten) |
| `npm run website:build` | Plan DoD / prior Implement session | ✅ Previously verified |

### Jira children under AC-36

| Key | Type | Summary | Jira status | Content in repo |
|---|---|---|---|---|
| AC-47 | Task (active) | GUI vs CLI | Backlog | ✅ Implemented |
| AC-48 | Task (active) | Node vs Cursor/Claude | Backlog | ✅ Implemented |
| AC-49 | Task (active) | AI accounts | Backlog | ✅ Implemented |
| AC-46 | Task (active) | Open terminal | Backlog | ✅ Implemented |
| AC-40 / AC-39 / AC-41 / AC-42 | Story (superseded) | Same scope as above | Done | N/A (duplicates) |
| AC-36 | Epic | Non-technical reader clarity | Backlog | Content ✅ / board ❌ |

---

## Architecture Observations

- Prerequisites MDX is the correct SSOT for install detail after AC-56.
- AC-36 and AC-56 are correctly related in product terms (Relates in Jira); closing AC-36 should not wait on AC-56 unless the team wants Start here essay alignment as part of AC-36 DoD — workshop/AC-56 explicitly reversed that.

## Summary

| Category | 🔴 Critical | 🟡 Important | 🟢 Nice to Have | Total |
|---|---|---|---|---|
| Dead Code | 0 | 0 | 0 | 0 |
| Duplications | 0 | 0 | 1 | 1 |
| Improvements | 0 | 1 | 2 | 3 |
| **Total** | **0** | **1** | **3** | **4** |

## Recommended Action Plan

### Immediate (Critical)

None for docs content.

### Short-term (Important)

1. ~~**Close Jira for AC-36**~~ — done 2026-10-14: AC-46–49 + AC-36 → Done.
2. ~~Comment on AC-36~~ — posted (docs shipped; Start here → AC-56).

### Long-term (Nice to Have)

1. Changelog note on `ac-36-prerequisites-clarity.plan.md` that Start here ACs were superseded by AC-56.
2. Continue AC-37 / AC-38 for remaining Prerequisites workshop gaps (Docker enterprise, TOC/troubleshooting).

---

## Bottom line

| Question | Answer |
|---|---|
| Czy **treść** epika AC-36 jest w pełni wdrożona? | **Tak** — Prerequisites (+ delta VS Code). |
| Czy **Jira** pokazuje epik jako ukończony? | **Tak** (od 2026-10-14) — AC-36 i taski AC-46–49 → Done. |
| Czy Start here nadal zawiera pełny esej z AC-36? | **Nie** — celowo skrócone w AC-56; szczegóły na Prerequisites. |
