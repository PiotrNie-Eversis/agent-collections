# Code Quality Report - agent-collections

## Overview

| Field | Value |
|---|---|
| Repository | agent-collections |
| Repository Type | Framework monorepo (`.ai/`, `adapters/`, `mcp/`, `website/`, `scripts/`) |
| Date | 2026-10-14 |
| Layers/Apps Analyzed | **Focused delivery audit:** Epic [AC-72](https://eversis.atlassian.net/browse/AC-72) (Getting Started Installation) and Tasks AC-73–AC-79 |
| Prompt | `/eversis-review-codebase` with user focus: *AC-72* |
| Spec | `docs/specs/ac-72-installation-ux/` |
| Primary deliverable | `website/docs/getting-started/installation.mdx` |

## Executive Summary

**Verdict: AC-72 implementation is OK (PASS).** The Getting Started Installation page was rewritten as MDX with the workshop IA (three-step framing → mental model → download → install → verify → upgrade → advanced). Legacy `installation.md` is removed; the route stays `/docs/getting-started/installation`. `npm run website:build` exited **0** in the Implement session. Independent Implement review was **PASS** (zero blockers). QA summaries were posted on AC-72 and AC-73–AC-79.

No critical dead code and no product/runtime scope creep (docs-only). Remaining findings are accuracy (Advanced Skills “no `.cursor/skills` mirror” claim vs committed/installer mirrors), intentional README↔Installation command duplication with slightly different recommended `--agents` defaults, a pre-existing relative link shape in Domain Context, small OS-path consistency across Getting Started pages, and board hygiene (tickets still Backlog while content is delivered).

---

## Findings by Layer/App

### Website docs — Installation (`website/docs/getting-started/`)

#### Dead Code

| # | Severity | Type | Location | Description |
|---|---|---|---|---|
| 1 | 🟢 | Orphan file | (absent) `website/docs/getting-started/installation.md` | Legacy markdown correctly removed after MDX cutover — no duplicate doc ID risk. |
| 2 | 🟢 | Static assets | (absent) `website/static/img/getting-started/installation/` | Plan Gap Q3 (text-only) honored; no empty screenshot directory left behind. |

#### Duplications

| # | Severity | Type | Locations | Description | Recommendation |
|---|---|---|---|---|---|
| 1 | 🟡 | Near-duplicate install SSOT | `installation.mdx` L84–88 / L212–226; `README.md` ~L168–188; `documentation/agent-collection.md` ~L45–52; `framework-reference.md` ~L51–57 | Recommended installer block + vendor/flags overlap across Getting Started, README, and Reference. Installation is the guided page; README remains the engineer-facing short form. | Keep Installation as the long guided path; optionally add one sentence in README pointing to Installation for Windows/OS tabs; align `--agents` default wording (see Improvements #1). |
| 2 | 🟢 | Docker tip (by design) | `installation.mdx` L15–16, L74–76, L130; `prerequisites.mdx`; `mcp-setup.mdx` | Docker-must-be-running is restated at Prerequisites, Installation Step 2, and MCP Setup. | Keep — each page needs its own precondition tip; do not merge into one page. |
| 3 | 🟢 | Start here install bullets (by design) | `start-here.mdx` L26–50; `installation.mdx` Steps 1–3 | Start here maps the journey; Installation owns the steps. | Do not merge; keep Start here short. |

#### Improvement Opportunities

| # | Severity | Category | Location | Description | Recommendation |
|---|---|---|---|---|---|
| 1 | 🟡 | Accuracy / docs drift | `installation.mdx` L235–237 (Advanced Skills MVP) | Text claims the MVP does **not** ship a full mirror under `.cursor/skills` and that Cursor skills stay MCP-only. The framework repo commits `.cursor/skills/eversis-*` symlinks; the installer links consumer mirrors; `AGENTS.md` / skills overview describe mirrors + “do not register as Agent Skills UI.” | Rewrite to: mirrors exist for load-by-path / `@` attach; do **not** register `.cursor/skills` as Cursor Agent Skills UI; runtime discovery for Cursor remains MCP-first. Same stale sentence also appears in README / intro / quick-wins / framework-reference (broader than AC-72). |
| 2 | 🟡 | Consistency / defaults | `installation.mdx` L84–88 vs `README.md` L172–177 | Installation recommends `--agents=cursor,claude` + `--build-mcp`; README sample uses `--agents=cursor` and treats `--build-mcp` as optional. Both are valid; first-time readers may wonder which is “the” default. | Add one clarifying line on Installation (“README shows a Cursor-only minimal sample”) **or** align README sample to the Installation recommended command. |
| 3 | 🟡 | Process / Jira | AC-72…AC-79 | Content + build + Implement review PASS; QA comments posted. Tickets were still **Backlog** at audit time. | Transition AC-73–AC-79 (and epic AC-72 when children Done) after QA accepts. |
| 4 | 🟡 | Pre-existing link path | `website/docs/reference/domain-context.md` L76 | Relative href `./getting-started/installation#vendor-modes` is wrong from `reference/` (should be `../getting-started/…`). Anchor id `{#vendor-modes}` on Installation is correct. | Fix Domain Context (and sibling `./getting-started/mcp-setup#…` if present) to `../getting-started/…`. Out of AC-72 happy-path scope but affects inbound vendor-modes navigation. |
| 5 | 🟢 | UX / OS path consistency | `installation.mdx` Windows tabs (Git Bash); `mcp-setup.mdx` Windows tab (PowerShell compose); `prerequisites.mdx` PowerShell-first | Installation correctly requires Git Bash for the Bash installer; MCP Setup Windows env/build is PowerShell. Different `groupId`s (`operating-system` vs `mcp-os`) so OS choice does not sync across pages. | Optional: note on Installation Step 2 that MCP Setup may show PowerShell for Compose; or document Git Bash vs PowerShell roles once in Prerequisites. |
| 6 | 🟢 | Completeness / flags | `installation.mdx` L212–226 | Advanced flag table omits installer flags `--force`, `--gitignore-agent-artifacts`, `--help` (present in `setup-agent-collections.sh`). | Optional: add rows or a “see `--help`” note under Advanced. Not required for AC-72 AC. |
| 7 | 🟢 | Stack customise note | `installation.mdx` L243 vs `README.md` ~L194 | Installation: Claude customise → `.claude/CLAUDE.md`. README sometimes points Claude readers at `AGENTS.md`. | Prefer CLAUDE.md as Application default; keep AGENTS.md as framework SSOT for maintainers. |
| 8 | 🟢 | Disk / build ops | Implement session | First `website:build` hit `ENOSPC`; succeeded after clearing `website/node_modules/.cache` / `.docusaurus` / `build`. | Not a docs defect; note for local DevEx if disk is tight. |

### Inbound path / reference updates (AC-72 touch set)

| # | Severity | Category | Location | Description | Recommendation |
|---|---|---|---|---|---|
| 1 | 🟢 | Path strings updated | `README.md`, `requirements-traceability.md`, `documentation/agent-collection.md` | Hard-coded `installation.md` → `.mdx` updated in AC-72. | Done. |
| 2 | 🟢 | Section retarget | `eversis-collections.md` L235 | “Installation §4” → Step 2 anchor. | Done. |
| 3 | 🟢 | Stale neighbors (out of scope) | README / traceability `start-here.md`, `prerequisites.md` path strings | Similar `.md` vs `.mdx` naming leftovers for sibling pages. | Separate cleanup; not introduced by AC-72 Installation rewrite. |

---

## Architecture Observations

- **Docs-only epic:** No installer, Compose, or MCP runtime changes — correct boundary for AC-72.
- **IA match:** Five H2s with `toc_max_heading_level: 2` (Step 1–3, Upgrade & Sync, Advanced options) matches AC-79 intent; Vendor modes / Seed are H3 with stable ids for inbound links.
- **Progressive disclosure:** Happy path no longer includes maintainer `sync:adapters` or the full flag table — workshop goal met.
- **SSOT tension:** Guided Installation vs README short-form will always overlap; the actionable issue is **default-command wording drift** (`cursor,claude` + `--build-mcp` vs Cursor-only optional build), not the existence of two pages.
- **Accuracy debt beyond AC-72:** The “no `.cursor/skills` mirror” sentence is duplicated site-wide and conflicts with TASK-598 / installer reality — worth a small follow-up docs pass across Getting Started + README.

---

## Summary

| Category | 🔴 Critical | 🟡 Important | 🟢 Nice to Have | Total |
|---|---|---|---|---|
| Dead Code | 0 | 0 | 2 | 2 |
| Duplications | 0 | 1 | 2 | 3 |
| Improvements | 0 | 4 | 4 | 8 |
| **Total** | **0** | **5** | **8** | **13** |

Counts include inbound/path rows that are informational (🟢 done) under Improvements neighbors; actionable Important items are: Skills MVP accuracy, README defaults alignment, Jira transitions, Domain Context relative link.

## Recommended Action Plan

### Immediate (Critical)

1. None.

### Short-term (Important)

1. Fix Advanced Skills MVP wording in `installation.mdx` (and prefer a follow-up sweep of the same stale sentence in README / intro / quick-wins / framework-reference).
2. Align or explicitly cross-explain Installation vs README recommended `--agents` / `--build-mcp` samples.
3. Fix `domain-context.md` relative links to Installation / MCP Setup (`../getting-started/…`).
4. After QA accepts, transition AC-73–AC-79 (then AC-72) out of Backlog.

### Long-term (Nice to Have)

1. Clarify Git Bash (installer) vs PowerShell (Compose) roles across Prerequisites / Installation / MCP Setup.
2. Optionally extend Advanced flag table with `--force` / `--gitignore-agent-artifacts` / `--help`.
3. Harmonize Claude customise path notes (CLAUDE.md vs AGENTS.md) between Installation and README.
4. Keep Start here / Docker tip duplications as-is (by design).
