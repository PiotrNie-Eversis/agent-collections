# AC-72 installation ux - Analysis Result

## Task Details

| Field | Value |
|---|---|
| Jira ID | [AC-72](https://eversis.atlassian.net/browse/AC-72) (Epic) |
| Child Tasks | [AC-73](https://eversis.atlassian.net/browse/AC-73)–[AC-79](https://eversis.atlassian.net/browse/AC-79) |
| Title | Getting Started Installation: guided onboarding and DevEx recovery |
| Description | Rewrite Getting Started Installation so QA/BA/PO/Developer readers can download the framework once, run one recommended installer command in their project, and verify success—without treating maintainer tooling, full CLI flags, or submodule internals as part of the numbered happy path |
| Priority | Highest |
| Reporter | Piotr Niemirski |
| Created Date | 2026-10-14 |
| Due Date | — |
| Labels | `documentation`, `getting-started`, `installation`, `workshop-2026-10-14` |
| Status | Backlog |
| Estimated Effort | Docs-only page rewrite (7 Tasks; single page IA) |
| Workshop source | `docs/specs/installation-ux-recovery/` (Gate 1 approved 2026-10-14; pushed as AC-72 / AC-73–AC-79) |
| Related | [AC-63](https://eversis.atlassian.net/browse/AC-63) (MCP Setup — next step); [AC-37](https://eversis.atlassian.net/browse/AC-37) / [AC-38](https://eversis.atlassian.net/browse/AC-38) (Prerequisites); DHI-649 (canonical install checklist); DHI-641 (broader docs UX — related, not parent) |

## Business Impact

Installation is the first actionable Getting Started step after Prerequisites. Today the page reads like an engineering reference: the happy path is buried under maintainer steps and a dense CLI flag table, Windows users hit Unix-only samples, and smoke-test cues sit at the bottom. A guided English page (download once → install into project → verify → upgrade / advanced deferred → link to MCP Setup) shortens time-to-first-success and reduces support load for non-developers while keeping advanced accuracy for developers and maintainers.

## Gathered Information

### Knowledge Base & Task Management Tools

- **Live Jira:** Epic AC-72 with seven Tasks (AC-73–AC-79), all Backlog. Hierarchy matches `jira-backlog-hierarchy` (Epic → Task). Relates links to AC-63, AC-37, AC-38, DHI-649 per workshop push record. Blocks: AC-74→AC-76, AC-75→AC-76, AC-76→AC-77.
- **Workshop pack** (`docs/specs/installation-ux-recovery/`):
  - `intent-brief.md` — Gate 0 skipped; Gate 1 locked (new AC epic; Git Bash primary + PowerShell env note; English SSOT).
  - `extracted-tasks.md` — 7 stories with AC, dependencies, assumptions.
  - `source-ux-audit.md` — Polish-language UX/IA audit + proposed MDX outline (source material only; published page stays English).
  - `jira-tasks.md` — push record (AC-72 / AC-73–AC-79).
  - `quality-review.md` — Lite review; S-01–S-03 accepted.
- **Domain knowledge:** `jira-backlog-hierarchy` — last implementable level is Task/Bug. Implement may plan the epic as one page delivery while closing child Tasks (same pattern as AC-63).
- **Sibling epic:** AC-63 MCP Setup recovery already delivered guided MDX (`mcp-setup.mdx`); Installation should end with a clear next link to MCP Setup and not duplicate MCP content.

### Codebase

- **Target page:** `website/docs/getting-started/installation.md` (sidebar_position 2, ~173 lines). Current structure:
  1. Intro + “Curated path → Start here” info callout (primary bounce to Start here)
  2. Clone the framework (Unix-only)
  3. Open the framework (optional for maintainers) — numbered step 2
  4. Bootstrap a consumer project — non-interactive example + vendor modes + **Useful flags** table (~12 flags) + submodule teammates + stack customise
  5. Skills and prompts (MVP)
  6. Upgrade (+ keeping consumers aligned)
  7. Advanced: team submodule sync
  8. First successful install (sample `/tmp`) — buried smoke test
  9. Seed existing project knowledge (optional)
- **Pain vs workshop IA:** inverted flow; no OS tabs; maintainer step in happy path; flag table in Step 3; verification only in §8; TOC noise from many `###` headings; Unix-only samples.
- **Patterns to reuse:**
  - `prerequisites.mdx` — `toc_max_heading_level: 2`, `<Tabs groupId="operating-system">`, plain-language callouts
  - `mcp-setup.mdx` — sibling Getting Started recovery (Tabs + slim TOC + verify + next links)
  - `start-here.mdx` — role Tabs; Installation should not loop readers back there as the first CTA
- **Installer SSOT:** `scripts/setup-agent-collections.sh`. Live recommended non-interactive example on the page:

```bash
bash "$AGENT_COLLECTIONS_HOME/scripts/setup-agent-collections.sh" \
  --build-mcp --non-interactive \
  --agents=cursor,claude \
  --mcp-servers=eversis-collections \
  --profile=fullstack
```

  Workshop MDX template omits `--mcp-servers` (installer defaults to `eversis-collections` in non-interactive when omitted). Implement must not invent flags; prefer live installer/README truth when templates disagree.
- **Success artifacts (product truth):** `.agent-collections/install-selection.json`; `docs/context/<project>/INDEX.md` created if missing on install.
- **Quality gate for docs:** `npm run website:build` (and `npm run website:changelog:check` only if release notes change).

### Relevant Links

- https://eversis.atlassian.net/browse/AC-72 — Epic
- https://eversis.atlassian.net/browse/AC-73 … AC-79 — Child Tasks
- `/docs/getting-started/installation` — published route (Docusaurus)
- `docs/specs/installation-ux-recovery/` — workshop SSOT for requirements
- Prerequisites: `website/docs/getting-started/prerequisites.mdx`
- MCP Setup (next step): `website/docs/getting-started/mcp-setup.mdx`
- Install selection schema: `docs/architecture/install-selection.md`

### Relevant Charts & Diagrams

Recommended page IA (workshop / epic success metrics):

```text
what this is (3-step framing + Prerequisites tip)
  → mental model (framework once vs consumer project)
  → Step 1 download + AGENT_COLLECTIONS_HOME (OS tabs)
  → Step 2 recommended install in project (OS tabs + --profile tip + Docker tip)
  → Step 3 verify (artifacts + recovery + link MCP Setup)
  → Upgrade & Sync
  → Advanced (<details>: submodule, full flags, maintainer adapter sync)
```

## Current Implementation Status

### Existing Components

- Installation page — `website/docs/getting-started/installation.md` — **needs modification** (full IA rewrite; likely rename to `.mdx` for Tabs)
- Prerequisites — `website/docs/getting-started/prerequisites.mdx` — **reuse** (Docker / tooling tip-link only)
- MCP Setup — `website/docs/getting-started/mcp-setup.mdx` — **reuse** (outbound next-step link only)
- Start here — `website/docs/getting-started/start-here.mdx` — **reuse** as secondary cross-link, not primary opening CTA
- Installer SSOT — `scripts/setup-agent-collections.sh` — **reference only** (docs-only epic; no installer changes unless a product bug is discovered)

### Key Files and Directories

- `website/docs/getting-started/installation.md` — primary deliverable (may become `.mdx`)
- `website/docs/getting-started/prerequisites.mdx` / `mcp-setup.mdx` / `start-here.mdx` — inbound/outbound links
- `docs/specs/installation-ux-recovery/*` — requirements input (not the Implement spec folder)
- `docs/architecture/install-selection.md` — selection-file reference for verification wording

## Gap Analysis

### Question 1
#### Delivery unit for this `/eversis-implement AC-72` thread: rewrite the whole Installation page covering AC-73–AC-79 in one plan, or implement a single child Task first (e.g. AC-73 only)?
**Answer (locked):** Whole epic as one page delivery (AC-73–AC-79). Fine / QA handoff must include a **QA summary per child ticket** (AC-73 through AC-79), not only the epic.  
Evidence: user `Q1. OK;` (2026-10-14) — accepts recommendation.

### Question 2
#### Convert `installation.md` → `installation.mdx` with Docusaurus Tabs (`groupId="operating-system"` for macOS/Linux vs Windows), plus `toc_max_heading_level: 2` so in-tab labels do not spam TOC?
**Answer (locked):** Yes — convert to `.mdx` with OS Tabs and `toc_max_heading_level: 2`, mirroring Prerequisites / MCP Setup.  
Evidence: user `q2. ok;` (2026-10-14).

### Question 3
#### Verification / recovery visuals: text-only callouts + short checklist (no new screenshots), or agent-created screenshots under `website/static/img/getting-started/installation/`?
**Answer (locked):** Text-only (callouts + short checklist). No new screenshots / no `website/static/img/getting-started/installation/` for v1.  
Evidence: user `q3. text-only;` (2026-10-14).

### Question 4
#### Default recommended install command: keep live-page flags including `--mcp-servers=eversis-collections`, or omit `--mcp-servers` when the installer already defaults to that server in `--non-interactive` (workshop template)?
**Answer (locked):** Keep explicit `--mcp-servers=eversis-collections` on the recommended install command (copy-paste clarity).  
Evidence: user `Q4. keep explicit; research ok — make the plan` (2026-10-14).

### Question 5
#### “First successful install” `/tmp` sample: demote to Advanced/aside under Verification (optional illustration), or keep as a prominent subsection after Upgrade?
**Answer (locked):** Demote to optional under/near Verification; Story 1.5 artifact checks remain the mandatory smoke path.  
Evidence: user `q4. demote to optional under/near Verification;` (2026-10-14) — maps to this Q5 (user renumbered; content matches Q5 recommendation).

## Open questions (blocking)

None — Q1–Q6 locked 2026-10-14.

## Human gates

1. ~~Approve research~~ — done (`Q4. keep explicit; research ok — make the plan`) for original epic rewrite
2. ~~Approve plan~~ / ~~Implement → Review → Fine~~ — original AC-73…AC-79 delivery complete (Implement review PASS; QA comments posted)
3. ~~Approve research DELTA~~ — done (`Q6. A; research ok — make the plan`)
4. Approve refreshed plan → Implement → Review → Fine

## Changelog

| Date | Author | Change |
|---|---|---|
| 2026-10-14 | eversis-implement | CREATE — Jira AC-72 + children AC-73–AC-79; workshop `installation-ux-recovery`; current `installation.md` baseline; Gap Q1–Q5 open |
| 2026-10-14 | eversis-implement | Gap Q1–Q3 + Q5 locked (`Q1. OK;` `q2. ok;` `q3. text-only;` user `q4` treated as research Q5 demote); **Q4 (mcp-servers flag) still open** |
| 2026-10-14 | eversis-implement | Gap Q4 locked (`Q4. keep explicit;`); research approved (`research ok — make the plan`) — plan next |
| 2026-10-14 | eversis-implement | **DELTA** — `docs/reports/code-quality-report.md` AC-72 focused audit; inventory Important + Nice to Have; Gap Q6 open |
| 2026-10-14 | eversis-implement | Gap Q6 locked (`Q6. A;`); research DELTA approved — plan REFRESH next |

---

## DELTA — Code quality follow-up (2026-10-14)

**Trigger:** `/eversis-implement AC-72` + `@docs/reports/code-quality-report.md`.

**Source:** `docs/reports/code-quality-report.md` (Focused delivery audit, verdict PASS). Summary: **0 Critical**, **5 Important** (including process/Jira), **8 Nice to Have** (some verify-only / by-design).

**Out of scope for docs Implement unless human expands:**

| Report item | Why excluded by default |
| --- | --- |
| Improvements #3 (🟡) — Transition AC-72…AC-79 in Jira | Process / board hygiene after QA accepts — not a docs edit |
| Improvements #8 (🟢) — ENOSPC / disk during build | Local DevEx note only |
| Duplications #2–#3 (🟢) — Docker tips / Start here overlap | Explicitly **by design — keep** |
| Dead Code #1–#2 (🟢) | Verify-only — already correct (no `.md`, no screenshot dir) |

### Inventory — actionable docs items

| ID | Report section | Location | Default action | Notes |
| --- | --- | --- | --- | --- |
| IMP-1 | Improvements #1 (🟡) | `installation.mdx` L235–237 (+ stale copies in README / intro / quick-wins / framework-reference) | **Implement** wording fix on Installation; **optional sweep** of sibling pages | Accurate: mirrors exist; do not register as Agent Skills UI; Cursor discovery still MCP-first |
| IMP-2 | Improvements #2 (🟡) + Dup #1 | `installation.mdx` Step 2 vs `README.md` sample | **Implement** — clarify or align `--agents` / `--build-mcp` | Prefer clarify on Installation + one README pointer to Installation for Windows/OS tabs |
| IMP-4 | Improvements #4 (🟡) | `domain-context.md` L76 (+ sibling mcp-setup relative if present) | **Verify keep `./getting-started/…`** | Page slug `/domain-context` makes `./getting-started/` correct in URL space; `../getting-started/` fails `website:build` (CQR false positive) |
| NTH-5 | Improvements #5 (🟢) | Installation / MCP Setup / Prerequisites Windows path | Optional note | Git Bash for installer vs PowerShell for Compose |
| NTH-6 | Improvements #6 (🟢) | Advanced flag table | Optional `--help` note or extra rows | `--force`, `--gitignore-agent-artifacts` |
| NTH-7 | Improvements #7 (🟢) | Claude customise path | Optional | Prefer `.claude/CLAUDE.md` vs AGENTS.md confusion |
| VERIFY-D1/D2 | Dead Code 🟢 | absent `.md` / screenshot dir | **Verify only** | Confirm stays gone |
| VERIFY-Dup2/3 | Duplications 🟢 | Docker / Start here | **Verify only** | Do not merge |

### Proposed solution (docs-only, pending Q6)

1. Rewrite Advanced Skills MVP bullet on `installation.mdx` (and sibling stale sentences if Q6 includes site sweep).
2. Cross-explain Installation recommended command vs README Cursor-only minimal sample (and optional README → Installation for Windows tabs).
3. Fix Domain Context relative links to Installation (and MCP Setup if same bug).
4. Optional NTH polish only if Q6 includes Nice to Have.
5. Quality gate: `npm run website:build`. No installer changes. No Jira transitions in Implement.

### Gap Analysis (DELTA)

### Question 6
#### Scope of this code-quality follow-up for AC-72?
**Answer (locked):** **A. Important docs only** — IMP-1 (Installation + sibling Skills sentence sweep), IMP-2 (defaults clarify), IMP-4 (domain-context links). Verify-only dead/dup rows. Skip NTH-5/6/7. Skip Jira transitions.  
Evidence: user `Q6. A; research ok — make the plan` (2026-10-14).
