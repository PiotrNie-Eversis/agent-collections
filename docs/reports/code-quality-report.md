# Code Quality Report - agent-collections

## Overview

| Field | Value |
|---|---|
| Repository | agent-collections |
| Repository Type | Framework monorepo (`.ai/`, `adapters/`, `mcp/`, `website/`, `scripts/`) |
| Date | 2026-10-14 |
| Layers/Apps Analyzed | **Focused delivery audit:** Story [AC-35](https://eversis.atlassian.net/browse/AC-35) (Prerequisites UX overhaul) and live follow-up content on the same page (AC-36 / AC-37 / AC-38 leaf tasks) |
| Prompt | `/eversis-review-codebase` with user focus: *AC-35 — przeanalizuj wdrożenie; jeśli OK — QA summary per zadanie* |

## Executive Summary

**Verdict: AC-35 implementation is OK (PASS).** The public Prerequisites page meets the original six acceptance criteria. `npm run website:build` exits **0** (verified 2026-10-14). Legacy `prerequisites.md` is gone; the route is served by `prerequisites.mdx`.

Post-deploy follow-ups from the AC-35 workshop are already present on the same page: GUI/CLI clarity and accounts (AC-36 / AC-46–49), TOC + troubleshooting (AC-37 / AC-50–51), and enterprise Docker warning (AC-38 / AC-52). Leaf Tasks for those follow-ups are **Done** in Jira. **AC-35 itself remains Backlog** despite delivered content — board hygiene gap only.

No critical dead code, no duplications that block shipping, and no scope creep into installer/MCP runtime. Remaining items are process (close AC-35; optionally close epics AC-37 / AC-38 whose children are Done) and optional polish (replace illustrative screenshots with org-branded captures later).

---

## Findings by Layer/App

### Website docs — Prerequisites (`website/docs/getting-started/`)

#### Dead Code

| # | Severity | Type | Location | Description |
|---|---|---|---|---|
| 1 | 🟢 | Orphan file | (absent) `website/docs/getting-started/prerequisites.md` | Legacy markdown correctly removed after MDX cutover — no duplicate doc ID risk. |
| 2 | 🟢 | Static assets | `website/static/img/getting-started/prerequisites/.DS_Store` | macOS metadata file in static image folder; not referenced by docs. | Remove from VCS / add ignore if it keeps reappearing. |

#### Duplications

| # | Severity | Type | Locations | Description | Recommendation |
|---|---|---|---|---|---|
| 1 | 🟢 | Docs overlap (by design) | `prerequisites.mdx`, `start-here.mdx` | Start here (AC-56) short-points to Prerequisites for tool detail; Prerequisites remains SSOT. | Keep this split; do not re-expand Start here with full AC-35 matrix. |
| 2 | 🟢 | Repeated vendor links | Matrix + OS tabs in `prerequisites.mdx` | Official Cursor / Claude / Docker / Git links appear in matrix and again in tab steps. | Acceptable for onboarding UX; no merge needed. |

#### Improvement Opportunities

| # | Severity | Category | Location | Description | Recommendation |
|---|---|---|---|---|---|
| 1 | 🟡 | Process / Jira | AC-35 | Content and build gate met; Story still **Backlog**. | Transition AC-35 → Done after QA accepts the draft below. |
| 2 | 🟡 | Process / Jira | AC-37, AC-38 | Child Tasks AC-50–52 are **Done**; epics still **Backlog**. | Close epics when product agrees children complete the epic DoD. |
| 3 | 🟢 | Docs polish | Common problems screenshots | Illustrative / schematic images (plan-allowed). | Optional later: replace with org-branded captures. |
| 4 | 🟢 | Docs | `prerequisites.mdx` matrix | Wide table (6 columns) may wrap heavily on mobile. | Monitor in browser; split “Account” into a subsection only if QA reports scanability issues. |

---

## AC-35 acceptance matrix

| Acceptance criterion | Evidence | Status |
|---|---|---|
| Quick matrix: official links for Cursor, Claude Code, Docker Desktop, Git, Node.js | `prerequisites.mdx` Quick requirements table (also adds VS Code for Claude Code path — additive, not a gap) | ✅ Met |
| macOS / Windows tabs with GUI-first steps; Apple Silicon/Intel; WSL2 warning | OS `<Tabs groupId="operating-system">`; Docker Mac chip choice; Windows WSL `:::warning` | ✅ Met |
| Role tip + Node section: Node not required for typical QA/BA (Cursor-only) | Tip L14–16; Node `:::info` L115–121 | ✅ Met |
| Verification: commands + example outputs + Installation CTA | Check your setup table + link to Installation | ✅ Met |
| Framework depth (domain-context, Compose) below main path | Framework notes after Common problems; MCP setup links | ✅ Met |
| `npm run website:build` | Exit 0 on 2026-10-14 | ✅ Met |
| Start here aligned (Node not peer-required for all roles) | `start-here.mdx` role tabs; Node only on Developer / Claude notes | ✅ Met (shape owned by AC-56; detail SSOT on Prerequisites) |

### Related leaf tasks (same page; already Done)

| Key | Summary | Jira | Content |
|---|---|---|---|
| AC-47 | Cursor GUI vs Claude Code CLI | Done | ✅ |
| AC-48 | Node vs Cursor / Claude paths | Done | ✅ |
| AC-49 | Cursor / Anthropic accounts | Done | ✅ |
| AC-46 | Open Terminal / PowerShell | Done | ✅ |
| AC-50 | Clean TOC | Done | ✅ (`toc_max_heading_level: 2` + bold in-tab labels) |
| AC-51 | Common problems + screenshots | Done | ✅ (3 scenarios + 3 webp assets) |
| AC-52 | Docker admin / license / IT alternatives | Done | ✅ |

---

## Architecture Observations

- Docs-only change on the Docusaurus site; first-class MDX Tabs usage is appropriate and build-safe.
- Prerequisites is the onboarding SSOT; Start here is a role map (AC-56) — healthy separation of concerns.
- No circular dependencies or new npm packages introduced by AC-35.
- Out of scope correctly respected: no installer, MCP image, or Linux tab changes.

## Summary

| Category | 🔴 Critical | 🟡 Important | 🟢 Nice to Have | Total |
|---|---|---|---|---|
| Dead Code | 0 | 0 | 2 | 2 |
| Duplications | 0 | 0 | 2 | 2 |
| Improvements | 0 | 2 | 2 | 4 |
| **Total** | **0** | **2** | **6** | **8** |

## Recommended Action Plan

### Immediate (Critical)

1. None.

### Short-term (Important)

1. Post QA drafts (below) after human review; move **AC-35** to Done.
2. Close epics **AC-37** and **AC-38** if child Tasks satisfy epic DoD.

### Long-term (Nice to Have)

1. Drop `.DS_Store` from the prerequisites image folder if tracked.
2. Optionally refresh troubleshooting screenshots with branded captures.
3. Revisit matrix width on small viewports only if QA flags it.
