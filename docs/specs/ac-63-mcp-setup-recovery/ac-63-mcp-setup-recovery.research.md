# AC-63 mcp setup recovery - Analysis Result

## Task Details

| Field | Value |
|---|---|
| Jira ID | [AC-63](https://eversis.atlassian.net/browse/AC-63) (Epic) |
| Child Tasks | [AC-64](https://eversis.atlassian.net/browse/AC-64)–[AC-71](https://eversis.atlassian.net/browse/AC-71) |
| Title | Getting Started MCP Setup: guided onboarding and DevEx recovery |
| Description | Rewrite Getting Started MCP Setup so QA/BA/PO/Developer readers can configure core `eversis-collections`, connect Cursor or Claude Code, verify success, and recover—without treating optional MCPs as blockers |
| Priority | Highest |
| Reporter | Piotr Niemirski |
| Created Date | 2026-10-14 |
| Due Date | — |
| Labels | `documentation`, `getting-started`, `mcp-setup`, `workshop-2026-10-14` |
| Status | Backlog |
| Estimated Effort | Docs-only page rewrite (8 Tasks; single page IA) |
| Workshop source | `docs/specs/mcp-setup-ux-recovery/` (Gate 1 approved 2026-10-14; pushed as AC-63 / AC-64–AC-71) |
| Related | [AC-37](https://eversis.atlassian.net/browse/AC-37) / [AC-38](https://eversis.atlassian.net/browse/AC-38) (Prerequisites); DHI-641 (related docs UX, not parent) |

## Business Impact

MCP Setup is the most technical Getting Started step. Mixed jargon, mixed clients, and optional integrations block non-developers and slow developers. A guided English page that leads with a mental model, role path, core-first setup, verification, and troubleshooting reduces onboarding failure and support load while keeping optional integrations clearly later.

## Gathered Information

### Knowledge Base & Task Management Tools

- **Live Jira:** Epic AC-63 with eight Tasks (AC-64–AC-71), all Backlog. Hierarchy matches `jira-backlog-hierarchy` (Epic → Task). No comments or attachments on the epic at research time.
- **Workshop pack** (`docs/specs/mcp-setup-ux-recovery/`):
  - `intent-brief.md` — Gate 0 skipped; Gate 1 locked (Claude Desktop out of v1; English SSOT; new AC epic).
  - `extracted-tasks.md` — 8 stories with AC, dependencies, assumptions.
  - `jira-tasks.md` — push record (AC-63 / AC-64–AC-71).
  - `quality-review.md` — Lite review; S-01–S-04 accepted (Prerequisites callout; verification next links; installer vs duplicate User MCP).
- **Baseline:** `docs/context/agent-collections/task-baseline.md` lists AC-63 under Current Epics with workshop folder pointer.
- **Domain knowledge:** `jira-backlog-hierarchy` — last implementable level is Task/Bug, not Epic or Story. Implement may still plan the epic as one page delivery while closing child Tasks.

### Codebase

- Target page: `website/docs/getting-started/mcp-setup.md` (sidebar_position 3). Current structure: At a glance (env + compose build + JSON snippet) → env cutover table → MCP catalog → domain-context volume deep-dive (`./repo` vs `/workspace`) → Verify (short) → Installer merge → Claude Code note → Next links.
- Pain vs workshop IA: no plain MCP analogy first; catalog and advanced volume/env content sit before role guidance; Cursor vs Claude Code mixed; optional servers not clearly “later”; troubleshooting fragmented (caution blocks + short Verify), not a symptom→fix table; Claude Desktop not explicitly disclaimed.
- Patterns to reuse from sibling Getting Started pages:
  - `prerequisites.mdx` — `toc_max_heading_level: 2`, `@theme/Tabs` / `TabItem`, plain-language callouts, link-out to recovery.
  - `start-here.mdx` — role Tabs (`groupId="start-here-role"`).
- Command SSOT on the live page already uses `AGENT_COLLECTIONS_HOME` + `docker compose build/run eversis-collections` (not legacy `CURSOR_COLLECTIONS_HOME` as primary). Workshop audit `docker run` snippets are UX examples only — Implement must keep Compose/installer truth.
- Quality gate for docs: `npm run website:build` (and changelog check if release notes change).

### Relevant Links

- https://eversis.atlassian.net/browse/AC-63 — Epic
- https://eversis.atlassian.net/browse/AC-64 … AC-71 — Child Tasks
- `/docs/getting-started/mcp-setup` — published route (Docusaurus)
- `docs/specs/mcp-setup-ux-recovery/` — workshop SSOT for requirements
- Prerequisites (AC-37/AC-38): `website/docs/getting-started/prerequisites.mdx`

### Relevant Charts & Diagrams

Recommended page IA (workshop / epic success metrics):

```text
what MCP is → role path → core server (Step 1) → connect editor (tabs)
  → verify → project folder note → optional integrations → troubleshooting → next links
```

## Current Implementation Status

### Existing Components

- MCP Setup page — `website/docs/getting-started/mcp-setup.md` — **needs modification** (full IA rewrite; likely rename to `.mdx` for Tabs)
- Prerequisites recovery — `website/docs/getting-started/prerequisites.mdx` — **reuse** (link for Docker Engine / Windows recovery; do not duplicate AC-37/AC-38 content)
- Installer / Compose SSOT — `scripts/setup-agent-collections.sh`, `docker-compose.yml`, `templates/mcp.json` — **reference only** (docs-only epic; no installer/runtime changes unless a product bug is discovered)
- Domain Context docs — `website/docs/.../domain-context` (linked from current volume section) — **reuse** for deep detail; MCP Setup keeps plain-language folder note

### Key Files and Directories

- `website/docs/getting-started/mcp-setup.md` — primary deliverable
- `website/docs/getting-started/prerequisites.mdx` — link target for Engine-running precondition
- `website/docs/getting-started/quick-wins.md` / `start-here.mdx` — next-step links
- `docs/specs/mcp-setup-ux-recovery/*` — requirements input (not the Implement spec folder)
- Screenshots path — **out of scope for v1** (Gap Q3: text-only)

## Gap Analysis

### Question 1
#### Delivery unit for this `/eversis-implement AC-63` thread: rewrite the whole page covering AC-64–AC-71 in one plan, or implement a single child Task first (e.g. AC-64 only)?
**Answer (locked):** Whole epic as one page delivery (AC-64–AC-71). Fine / QA handoff must include a **QA summary per child ticket** (AC-64 through AC-71), not only the epic.  
Evidence: user `Q1. WHOLE EPIC, qa summary per ticket;` (2026-10-14).

### Question 2
#### Convert `mcp-setup.md` → `mcp-setup.mdx` with Docusaurus Tabs (`mcp-client` for Cursor | Claude Code; OS tabs for Step 1), plus `toc_max_heading_level: 2` so in-tab headings do not spam TOC?
**Answer (locked):** Yes — convert to `.mdx` with client/OS Tabs and `toc_max_heading_level: 2`, mirroring Prerequisites / Start here.  
Evidence: user `Q2. Yes;` (2026-10-14).

### Question 3
#### Verification / troubleshooting visuals: text-only callouts + table (no new screenshots), or agent-created illustrative screenshots under `website/static/img/getting-started/mcp-setup/`?
**Answer (locked):** Text-only (callouts + troubleshooting table). No new screenshots / no `website/static/img/getting-started/mcp-setup/` for v1.  
Evidence: user `Q3. TEXT ONLY;` (2026-10-14).

### Question 4
#### Env cutover (`CURSOR_COLLECTIONS_HOME` → `AGENT_COLLECTIONS_HOME`) and deep volume/mount detail: collapse into Troubleshooting / advanced callout after core path, or keep a shortened cutover table in-flow after Step 1?
**Answer (locked):** Demote after core path — shorten cutover and volume/mount detail into Troubleshooting / advanced callout; do not lead the page with them.  
Evidence: user `Q4. Recommendation ok;` (2026-10-14).

## Open questions (blocking)

None — Q1–Q5 locked 2026-10-14.

## Human gates

1. ~~Approve research~~ — done (`Research is ok. Make the plan`) for original epic rewrite
2. ~~Approve plan~~ / ~~Implement → Review → Fine~~ — original AC-64…AC-71 delivery complete (code-quality report PASS)
3. ~~Approve research DELTA~~ — done (`Q5. OK;`) — nice-to-have polish / verify pass from `docs/reports/code-quality-report.md`
4. Approve refreshed plan for NTH tasks → Implement → Review → Fine (QA draft for polish pass)

---

## DELTA — Code quality nice-to-have verify (2026-10-14)

**Trigger:** `/eversis-implement AC-63` + `@docs/reports/code-quality-report.md` + **verify all nice-to-have**.

**Source:** `docs/reports/code-quality-report.md` (Focused delivery audit, verdict PASS). Summary counts **8 Nice to Have** (2 Dead Code + 2 Duplications-by-design + 4 Improvements). Long-term action plan lists 4 NTH bullets.

**Out of scope for this DELTA (Important / Short-term — not requested):**

| Report item | Why excluded |
| --- | --- |
| Improvements #1 (🟡) — Claude-safe JSON / Cursor\|Claude sample tab | Severity Important, not Nice to Have |
| Improvements #2 (🟡) — Transition AC-64–AC-71 / AC-63 in Jira | Process / board hygiene |
| Duplications #1 (🟡) — Trim advanced volume → Reference pointer | Severity Important |

### Inventory — all 🟢 Nice to Have

| ID | Report section | Location | Action for this pass | Live check (2026-10-14) |
| --- | --- | --- | --- | --- |
| NTH-D1 | Dead Code #1 | (absent) `mcp-setup.md` | **Verify only** — confirm legacy file stays gone | ✅ Absent |
| NTH-D2 | Dead Code #2 | (absent) `website/static/img/getting-started/mcp-setup/` | **Verify only** — no screenshot dir | ✅ Absent |
| NTH-Dup2 | Duplications #2 | Cursor caution + Troubleshooting row | **Verify only** — keep both (by design) | ✅ Present; no merge |
| NTH-Dup3 | Duplications #3 | Role table vs `start-here.mdx` | **Verify only** — do not merge | ✅ Keep separate |
| NTH-I3 | Improvements #3 | `mcp-setup.mdx` L14–28 | **Implement** — move Prerequisites `:::warning` under the role table (diagram parity; DoD still: callout before Step 1) | Warning currently **above** role table (L18–20) |
| NTH-I4 | Improvements #4 | L38–82 | **Implement** — merge OS env + build into **one** Tabs group (`groupId` e.g. `mcp-os`) so readers do not switch OS twice | Two groups: `mcp-os-env`, `mcp-os-build` |
| NTH-I5 | Improvements #5 | Claude Code tab L142 | **Implement** — primary verify = open/trust `.mcp.json`; demote `claude mcp list` to optional | Still primary example in step 2 |
| NTH-I6 | Improvements #6 | `CHANGELOG.md` / `website/src/pages/changelog.md` | **Verify only** — leave historical `mcp-setup.md` strings | ✅ Historical cites remain; do not rewrite |

### Proposed solution (docs-only)

Single file touch: `website/docs/getting-started/mcp-setup.mdx`.

1. Reorder: tip → role table → Prerequisites warning → Step 1… (callout remains before Step 1).
2. One OS Tabs block per OS containing env export + `docker compose build` (and Windows engine note under Windows tab).
3. Claude Code connect step: lead with open/trust project `.mcp.json`; parenthetical or trailing optional `claude mcp list`.
4. No changelog / Reference / Important-item edits in this pass.

**Quality gate:** `npm run website:build`. Route via Repo Docs Writer patterns. No Figma / no installer changes.

### Gap Analysis (DELTA)

### Question 5
#### Scope of “verify all nice-to-have”: implement actionable NTH-I3/I4/I5 + confirm verify-only rows, or audit-only (no MDX edits)?
**Answer (locked):** Implement NTH-I3, NTH-I4, NTH-I5; confirm NTH-D1/D2, NTH-Dup2/Dup3, NTH-I6 with no file changes. Exclude Important findings unless human expands scope.  
Evidence: user `Q5. OK;` (2026-10-14).

## Changelog

| Date | Author | Change |
| --- | --- | --- |
| 2026-10-14 | eversis-implement | CREATE — Jira AC-63 + children AC-64–AC-71; workshop `mcp-setup-ux-recovery`; current `mcp-setup.md` baseline; Gap Q1–Q4 open |
| 2026-10-14 | eversis-implement | Gap Q1–Q4 locked (whole epic + per-ticket QA; MDX/Tabs; text-only; demote cutover/volume) — awaiting research approval |
| 2026-10-14 | eversis-implement | Research approved (`Research is ok. Make the plan`); plan authored in same thread |
| 2026-10-14 | eversis-implement | **DELTA** — code-quality-report nice-to-have verify/polish; inventory NTH-D1…I6; Important items explicitly out of scope; Q5 default implement I3/I4/I5 |
| 2026-10-14 | eversis-implement | Q5 locked (`Q5. OK;`); research DELTA approved — plan REFRESH next |
