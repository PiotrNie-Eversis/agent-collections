# ac-72-installation-ux - Implementation Plan

## Task Details

| Field            | Value |
| ---------------- | ----- |
| Jira ID          | AC-72 (Epic) + AC-73–AC-79 (Tasks) |
| Title            | Getting Started Installation: guided onboarding and DevEx recovery |
| Description      | Single-page docs rewrite of Installation covering all seven child Tasks; MDX + OS Tabs; text-only verify; explicit `--mcp-servers=eversis-collections`; demote `/tmp` sample under Verification; defer flags/submodule/maintainer below happy path. |
| Priority         | Highest |
| Related Research | [ac-72-installation-ux.research.md](./ac-72-installation-ux.research.md) |
| Workshop input   | `docs/specs/installation-ux-recovery/` (Gate 1 approved) |

## Wildly Important Goal

**Goal**: A non-developer can install Agent Collections into a consumer project in three main steps, recognize success, and move to MCP Setup—without reading the full CLI flag table or submodule internals.

**Success Measure**: AC-73–AC-79 acceptance criteria are met on the published Getting Started Installation page; page IA matches the workshop order; `npm run website:build` passes; Fine QA comment includes a per-ticket summary for AC-73 through AC-79.

**Do NOT touch / do NOT add**:
- Installer scripts, vendor modes behavior, or MCP/Docker runtime (docs-only unless a product bug is discovered)
- Full rewrite of Prerequisites (AC-37/AC-38), MCP Setup (AC-63), Start here, or Quick Wins beyond inbound/outbound link accuracy
- Screenshots / `website/static/img/getting-started/installation/` (Gap Q3: text-only)
- Non-English page copy
- Broader DHI-641 IA (sidebar clusters, Introduction framing, etc.)
- Full PowerShell installer scripting (Git Bash primary; PowerShell env note only)
- New npm dependencies

## Proposed Solution

Rewrite Getting Started Installation as one MDX page (convert `installation.md` → `installation.mdx`) with this IA:

```text
what this is (3-step framing) + Prerequisites tip
  → mental model (framework once vs consumer project + do-not-run-in-framework warning)
  → Step 1 download + AGENT_COLLECTIONS_HOME (OS tabs: macOS/Linux | Windows Git Bash)
  → Step 2 recommended install in project (OS tabs + Docker tip + --profile tip)
  → Step 3 verify (artifacts + recovery + optional /tmp sample + link MCP Setup)
  → Upgrade & Sync
  → Advanced (<details>: vendor/submodule, full flags, maintainer adapter sync, seed knowledge)
```

1. **Scaffold** — MDX frontmatter (`sidebar_position: 2`, `toc_max_heading_level: 2`), Tabs imports, replace `.md` so route `/docs/getting-started/installation` stays.
2. **AC-73 / AC-74** — Three-step framing; Prerequisites tip (not Start-here primary CTA); framework vs consumer mental model + explicit warning.
3. **AC-75 / AC-76** — OS Tabs for clone/env and install; one recommended command with **explicit** `--mcp-servers=eversis-collections` (Gap Q4); Docker tip; `--profile` plain-language tip; no flag table in Step 2.
4. **AC-77 / AC-78 / AC-79** — Verification artifacts + recovery + next MCP Setup; demote `/tmp` sample optional near Verification (Gap Q5); Upgrade below happy path; Advanced `<details>` for flags/submodule/maintainer; preserve stable heading ids (`{#vendor-modes}`, `{#seed-existing-project-knowledge-optional}`); slim TOC via `toc_max_heading_level: 2` + bold in-tab labels.
5. **Inbound path strings** — Update hard-coded `installation.md` references in README / architecture / documentation tables to `.mdx` where they point at the file on disk; keep extensionless route links as-is.
6. **Build + Review** — `npm run website:build`; Code Reviewer via `eversis-review`; Fine with **QA summary per AC-73…AC-79**.

Route docs implementation via Repo Docs Writer patterns (`eversis-writing-repo-documentation`). No Figma / no `[REUSE]` UI verification.

## Current Implementation Analysis

### Already Implemented

- Installation page (Markdown) — `website/docs/getting-started/installation.md` — clone, maintainer step, bootstrap + flags table, skills, upgrade, submodule advanced, buried `/tmp` smoke test, seed knowledge
- Prerequisites — `website/docs/getting-started/prerequisites.mdx` — Docker / tooling tip-link target
- MCP Setup — `website/docs/getting-started/mcp-setup.mdx` — next-step after verify (sibling recovery pattern)
- Tabs / TOC pattern — `prerequisites.mdx`, `mcp-setup.mdx` — reuse `@theme/Tabs`, `toc_max_heading_level: 2`, OS `groupId`
- Installer SSOT — `scripts/setup-agent-collections.sh` — reference for accurate flags only

### To Be Modified

- `website/docs/getting-started/installation.md` → replace with `installation.mdx` — full IA rewrite
- Hard-coded file-path mentions of `installation.md` (route links without extension stay valid):
  - `README.md`
  - `docs/architecture/requirements-traceability.md`
  - `documentation/agent-collection.md`
- Inbound anchors that must keep resolving after IA move:
  - `{#vendor-modes}` — linked from `website/docs/reference/domain-context.md`
  - `{#seed-existing-project-knowledge-optional}` — linked from `website/docs/getting-started/start-here.mdx`
  - Section references such as “Installation §4” in `website/docs/reference/integrations/eversis-collections.md` — retarget wording/href if section numbers change

### To Be Created

- `website/docs/getting-started/installation.mdx` — new MDX SSOT for the page (after `.md` removal)

## Open Questions

| # | Question | Answer | Status |
| --- | --- | --- | --- |
| 1 | Delivery unit | Whole epic AC-73–AC-79; Fine QA summary per child ticket | ✅ Resolved |
| 2 | MDX + Tabs | Convert to `.mdx`; OS Tabs; `toc_max_heading_level: 2` | ✅ Resolved |
| 3 | Screenshots | Text-only | ✅ Resolved |
| 4 | `--mcp-servers` on recommended command | Keep explicit `--mcp-servers=eversis-collections` | ✅ Resolved |
| 5 | `/tmp` sample | Demote optional under/near Verification | ✅ Resolved |
| 6 | CQR follow-up scope | **A** — Important docs only (IMP-1 sweep, IMP-2, IMP-4; verify-only; skip NTH + Jira) | ✅ Resolved (`Q6. A;`) |

## Technical Context

### Project Instructions

- `AGENTS.md` — framework repo; website docs under `website/docs/`
- `.cursor/rules/eversis-project-stack.mdc` — quality: `npm run website:build`; load `eversis-writing-repo-documentation` for docs (not BA Docs / frontend skills)
- Delivery Standard — specs under `docs/specs/<key>-<topic>/`
- `jira-backlog-hierarchy` — implementable leaves are Tasks; epic plan may still deliver the whole page and close AC-73–AC-79 together

### Architecture & Patterns

- Docusaurus MDX; Getting Started pages use admonitions (`:::tip` / `:::info` / `:::warning` / `:::caution`) and `@theme/Tabs` / `TabItem`
- Prefer `toc_max_heading_level: 2` and **bold** labels inside tabs (not `###`) so “On this page” stays ~4–5 major sections
- Doc id / route from basename: `installation.mdx` keeps `/docs/getting-started/installation`
- Relative links use `./installation` (no extension) elsewhere — route-safe; file-path references in README/architecture need `.mdx`

### Tech Stack

- Docusaurus site under `website/`
- Repo root: `npm run website:build`

### Code Style & Standards

- English SSOT; plain language, full sentences (match Prerequisites / MCP Setup recovery tone)
- Recommended install command must include: `--build-mcp --non-interactive --agents=cursor,claude --mcp-servers=eversis-collections --profile=fullstack`
- Do not invent CLI flags; relocate existing flag meanings into Advanced `<details>` accurately
- Windows happy path = Git Bash; PowerShell only for `$env:AGENT_COLLECTIONS_HOME=...` note
- Explicit warning: do not run the installer inside the `agent-collections` framework checkout

### Testing Patterns

- Docs: `npm run website:build` from repo root
- Inspectable checks: frontmatter keys; section headings in IA order; Tabs `groupId="operating-system"`; verify artifacts listed; Advanced `<details>` present; inbound `#vendor-modes` and `#seed-existing-project-knowledge-optional` resolve; no new image assets under installation static path; “On this page” roughly 4–5 H2s

### Database Patterns

- N/A

### Additional Context

- Child Task map: AC-73 framing · AC-74 mental model · AC-75 OS clone/env · AC-76 recommended install · AC-77 verify · AC-78 advanced/maintainer deferral · AC-79 slim TOC
- Workshop polish source: `docs/specs/installation-ux-recovery/source-ux-audit.md` proposed MDX outline (English rewrite required)
- Stack policy: do **not** load `eversis-implementing-frontend` / BA Docs for this work
- Skills MVP / seed knowledge content may move under Advanced or a short aside — keep seed heading id stable

## Implementation Plan

### Phase 1: MDX scaffold + framing + mental model (AC-73, AC-74)

**Goal**: Page opens as a three-step install path with a clear framework-vs-project model before any commands.

**Description**: Convert to MDX with TOC cap and Tabs imports. Lead with three-step framing and Prerequisites tip (not Start-here primary CTA). Add mental model + do-not-run-in-framework warning before Step 1.

**Verification:** File is `installation.mdx` (no leftover competing `installation.md`); frontmatter has `toc_max_heading_level: 2`; intro states ~three steps; mental model + warning appear before first command blocks.

#### Task 1.1 - [CREATE] Convert Installation to MDX scaffold

**Description**: Create `website/docs/getting-started/installation.mdx` with frontmatter (`sidebar_position: 2`, `title: Installation`, `toc_max_heading_level: 2`), import Tabs/TabItem, and remove `installation.md` so only one doc id remains. Skeleton H2 headings follow the workshop IA (placeholders OK until later phases fill them).

**Files:** `website/docs/getting-started/installation.mdx` (create), `website/docs/getting-started/installation.md` (delete / replace)

**Definition of Done**:

- [x] Only `installation.mdx` exists under `website/docs/getting-started/` for this page (no duplicate `.md`)
- [x] Frontmatter includes `toc_max_heading_level: 2` and `sidebar_position: 2`
- [x] File imports `@theme/Tabs` and `@theme/TabItem`

**Clues**: Mirror `prerequisites.mdx` / `mcp-setup.mdx` import style. Keep route id `installation`.

#### Task 1.2 - [MODIFY] Three-step framing + mental model (AC-73, AC-74)

**Description**: Opening copy: install into your project in about three steps. Prerequisites tip links Docker/tooling as a prerequisite (not a Start-here bounce as primary CTA; Start here may remain secondary). Explicit two-part model: (A) download framework once; (B) run installer in consumer/business project. Warning not to run the installer from inside the framework checkout. Explain `AGENT_COLLECTIONS_HOME` in plain language.

**Files:** `website/docs/getting-started/installation.mdx` (modify — Task 1.1)

**Definition of Done**:

- [x] Top of page states ~three-step install framing
- [x] Prerequisites is tip/link, not the dominant first CTA back to Start here
- [x] Framework-once vs consumer-project model is explicit before Step 1 commands
- [x] Visible warning: do not run installer inside `agent-collections` checkout
- [x] Primary heading order is download → install → verify (not maintainers → flags → sample last)

**Clues**: Current “Curated path → Start here” info callout must not remain the primary opening CTA.

### Phase 2: OS tabs + recommended install (AC-75, AC-76)

**Goal**: Reader can clone/set env and run one recommended install command with OS-appropriate samples.

**Description**: Step 1 OS Tabs for clone + `AGENT_COLLECTIONS_HOME` (Windows = Git Bash primary + short PowerShell env note). Step 2 matching OS Tabs with one recommended command (explicit `--mcp-servers=eversis-collections`), Docker tip, `--profile` tip. No full flag table or vendor modes in Step 2.

**Verification:** `groupId="operating-system"` Tabs in Steps 1–2; recommended command includes `--mcp-servers=eversis-collections`; flag table absent from Step 2; in-tab labels are bold/non-`###`.

#### Task 2.1 - [MODIFY] Step 1 OS-specific clone and environment (AC-75)

**Description**: Step 1: download framework once. Tabs: macOS/Linux default; Windows directs to Git Bash with working paths (`/c/...`). Include short PowerShell note for setting `AGENT_COLLECTIONS_HOME` only (not full PowerShell installer). Keep clone URL accurate to current docs.

**Files:** `website/docs/getting-started/installation.mdx` (modify — Phase 1)

**Definition of Done**:

- [x] Step 1 has macOS/Linux and Windows Tabs (`groupId="operating-system"`)
- [x] Windows tab instructs Git Bash as the primary path for these steps
- [x] PowerShell env note for `AGENT_COLLECTIONS_HOME` is present without a full PowerShell installer path
- [x] macOS/Linux clone + `export AGENT_COLLECTIONS_HOME=...` examples are copy-pasteable
- [x] In-tab labels use bold (or non-`###`) so TOC stays clean

**Clues**: Reuse clone URL from current page; workshop Polish template is tone/IA only.

#### Task 2.2 - [MODIFY] Step 2 recommended install command (AC-76)

**Description**: Step 2: `cd` to consumer project (not framework) and run one recommended non-interactive command with `--build-mcp --non-interactive --agents=cursor,claude --mcp-servers=eversis-collections --profile=fullstack`. Matching OS Tabs or “same shell / Git Bash” guidance. Docker Desktop/Engine must be running tip → Prerequisites + failure symptom. Plain-language `--profile` tip (`fullstack` recommended). Do not require `--vendor`, `--ssot-source`, or `--confluence-space-key` on the default path. Label as recommended for most users / non-developers.

**Files:** `website/docs/getting-started/installation.mdx` (modify — Task 2.1)

**Definition of Done**:

- [x] One default recommended command is the visible Step 2 path
- [x] Command includes explicit `--mcp-servers=eversis-collections` (Gap Q4)
- [x] Docker-running tip links to Prerequisites with a recognizable failure symptom
- [x] Default path does not require vendor/ssot/confluence flags
- [x] `--profile` tip explains fullstack / frontend / backend in plain language
- [x] Useful-flags table is not inside Step 2

**Clues**: Align with live installer SSOT; current page command block is the flag source of truth.

### Phase 3: Verify, upgrade, advanced, TOC (AC-77, AC-78, AC-79)

**Goal**: Reader can confirm success, self-recover, then find upgrade/advanced content without TOC noise; maintainer/flags content is below the happy path.

**Description**: Step 3 verification (artifacts + exit success + recovery + next MCP Setup); optional `/tmp` sample near Verification; Upgrade section; Advanced `<details>` (vendor/submodule, full flags, maintainer sync); preserve inbound heading ids; move Skills MVP / seed as needed under Advanced with stable seed id; confirm slim TOC.

**Verification:** Verify section lists selection file + context INDEX + clean exit; recovery checklist present; MCP Setup next link; `/tmp` not a prominent post-Upgrade section; maintainer `sync:adapters` not a numbered happy-path step; `{#vendor-modes}` and `{#seed-existing-project-knowledge-optional}` resolve; roughly 4–5 major H2s in TOC.

#### Task 3.1 - [MODIFY] Verification + optional sample + next MCP Setup (AC-77, Gap Q5)

**Description**: Step 3: success = `.agent-collections/install-selection.json` present; `docs/context/<project>/INDEX.md` exists/created; installer finished without critical errors (plain language / exit 0). Short recovery checklist (correct project folder, `AGENT_COLLECTIONS_HOME` set, Docker running / Prerequisites). Clear next-step link to MCP Setup. Demote “First successful install” `/tmp` walkthrough to optional under/near Verification (not the only smoke test; not a late prominent section after Upgrade).

**Files:** `website/docs/getting-started/installation.mdx` (modify — Phase 2)

**Definition of Done**:

- [x] Verification lists selection file and context INDEX success signals
- [x] Clean installer completion is stated in plain language
- [x] Short failure recovery checklist is present
- [x] Next-step link to MCP Setup appears after successful verification
- [x] `/tmp` sample is optional under/near Verification (not the only verify path; not post-Upgrade primary)
- [x] No new files under `website/static/img/getting-started/installation/`

**Clues**: Current § “First successful install” content can be shortened when demoted.

#### Task 3.2 - [MODIFY] Upgrade + Advanced deferral + slim TOC (AC-78, AC-79)

**Description**: Below happy path: Upgrade & Sync with `--upgrade --sync --non-interactive` and note that local rules are preserved where the product already does so. Advanced `<details>`: vendor/submodule workflow (preserve `{#vendor-modes}` on a visible heading or details summary target that inbound links resolve); full useful-flags table relocated from old Step 3; maintainer open-framework / `npm run sync:adapters` guidance (not numbered steps 1–3). Relocate Skills MVP / seed knowledge without breaking `{#seed-existing-project-knowledge-optional}`. Ensure major H2 count is ~4–5 (happy path steps may be one H2 each or grouped — prefer: framing is intro; Step 1; Step 2; Step 3; Upgrade; Advanced). Update hard-coded `installation.md` path strings in README / requirements-traceability / documentation table. Fix “Installation §4” style references in `eversis-collections.md` if section numbers no longer match.

**Files:**
- `website/docs/getting-started/installation.mdx` (modify — Task 3.1)
- `README.md` (modify — only where `installation.md` is hard-coded)
- `docs/architecture/requirements-traceability.md` (modify — only where `installation.md` is hard-coded)
- `documentation/agent-collection.md` (modify — only where `installation.md` is hard-coded)
- `website/docs/reference/integrations/eversis-collections.md` (modify — only if § reference must change)
- `website/docs/reference/domain-context.md` / `website/docs/getting-started/start-here.mdx` (modify — only if anchors must change)

**Definition of Done**:

- [x] Numbered happy path never requires open-framework / `npm run sync:adapters`
- [x] Upgrade section exists below verify with upgrade command
- [x] Advanced contains submodule/vendor and full useful-flags content in collapsible or clearly labeled advanced blocks
- [x] Maintainer adapter-sync guidance is advanced/end only
- [x] `{#vendor-modes}` and `{#seed-existing-project-knowledge-optional}` still resolve (or inbound hrefs updated in same task)
- [x] “On this page” shows roughly 4–5 major sections (`toc_max_heading_level: 2` + no `###` spam in tabs)
- [x] Hard-coded `installation.md` file paths updated to `.mdx` where they point at disk paths

**Clues**: Prefer preserving heading ids over mass link edits. Prefer linking Prerequisites for Docker recovery rather than duplicating AC-37/AC-38.

### Phase 4: Website build verification

**Goal**: Confirm the docs site builds after the rewrite.

**Description**: Run the repo docs build and fix any MDX/import/link errors introduced by this plan.

**Verification:** `npm run website:build` exits 0.

#### Task 4.1 - [REUSE] Run website build

**Description**: From repo root, run `npm run website:build`. Fix only failures caused by this page rewrite (broken MDX, missing imports, dead anchors).

**Files:** `website/docs/getting-started/installation.mdx` (reuse / modify if build fails), inbound docs from Task 3.2 if needed

**Definition of Done**:

- [x] Run `npm run website:build` (exit 0)
- [x] Build does not report MDX errors for `installation`

**Clues**: Do not change Docusaurus theme or add dependencies.

### Phase 5: Code Review

**Goal**: Independent review confirms AC-73–AC-79 criteria and docs quality before Fine.

**Description**: Mandatory final gate. Code Reviewer via `eversis-review`. On PASS, Fine with per-ticket QA summaries.

**Verification:** `npm run website:build`; review PASS (zero BLOCKERs; QA checklist verified).

#### Task 5.1 - [REUSE] Code review by Code Reviewer

**Description**: Run **Code Reviewer** via `eversis-review.md` on the Installation rewrite and any inbound link/path edits. Verify Quality Assurance checkboxes below (per child Task). Document outcome in Changelog. Do not declare Fine until PASS.

**Files:** `website/docs/getting-started/installation.mdx` (reuse), inbound files touched in Task 3.2 (reuse)

**Definition of Done**:

- [x] Run `npm run website:build`
- [x] Code review passes with no blocking findings
- [x] Every Quality Assurance item for AC-73–AC-79 is checked or explicitly deferred with user approval
- [x] Review outcome documented in Changelog

**Clues**: Fine handoff must include a short QA summary **per** AC-73, AC-74, AC-75, AC-76, AC-77, AC-78, AC-79 (plus epic AC-72 rollup if useful).

## Security Considerations

- Docs must not embed secrets, API tokens, or personal machine paths as examples; use placeholders (`~/projects/...`, `/c/projects/...`, `/path/to/agent-collections`).
- Do not invent installer flags or suggest insecure workarounds (e.g. disabling Docker requirements).
- Keep Confluence/ssot flags out of the default path; when mentioned in Advanced, clarify they record keys / seed URLs and do not call Confluence during install.

## Quality Assurance

### Epic AC-72

- [x] Page IA: framing → mental model → download → install → verify → upgrade → advanced → next MCP Setup
- [x] Page copy is English
- [x] Maintainer / full flags / submodule not in numbered happy path
- [x] `npm run website:build` passes

### AC-73 — Three-step framing

- [x] Opening states ~three-step install
- [x] Prerequisites is tip/link, not Start-here primary CTA loop
- [x] Primary path ordered download → install → verify

### AC-74 — Framework vs consumer project

- [x] Two-part mental model explicit before commands
- [x] Warning not to run installer inside framework checkout
- [x] `AGENT_COLLECTIONS_HOME` explained in plain language

### AC-75 — OS-specific clone/env

- [x] macOS/Linux vs Windows Tabs present
- [x] Windows Git Bash primary; PowerShell env note only
- [x] In-tab labels do not spam TOC

### AC-76 — Recommended install

- [x] One default command; includes `--mcp-servers=eversis-collections`
- [x] Docker tip → Prerequisites
- [x] No vendor/ssot/confluence required on default path
- [x] `--profile` tip in plain language

### AC-77 — Verification

- [x] Selection file + context INDEX + clean exit defined
- [x] Short recovery checklist present
- [x] Next link to MCP Setup
- [x] `/tmp` sample optional under/near Verification only

### AC-78 — Advanced / maintainer deferral

- [x] No numbered maintainer/open-framework/sync:adapters step in happy path
- [x] Upgrade below happy path
- [x] Advanced holds submodule/vendor + full flags + maintainer guidance

### AC-79 — Slim TOC

- [x] Roughly 4–5 major “On this page” sections
- [x] `toc_max_heading_level: 2` (and/or no `###` inside tabs)
- [x] Build does not reintroduce dense TOC regression

## Code Review Findings

**Verdict:** PASS (independent Code Reviewer, 2026-10-14)

**BLOCKERs:** none

**SUGGESTIONs:**
1. Align Windows tab labels across Step 1 and Step 2 — **applied** (both `Windows (Git Bash)`).
2. Advanced Skills MVP note about Cursor skill mirrors may need a later accuracy refresh — deferred (out of AC-72 acceptance).
3. Optional second witness build — implementer `npm run website:build` exit 0 accepted.

## Improvements (Out of Scope)

- Screenshot set for verification / recovery
- Full PowerShell installer documentation tabs
- Installer CLI behavior changes
- Rewriting Prerequisites / MCP Setup / Start here beyond link accuracy
- DHI-641 broader docs IA
- Non-English published docs
- Video walkthroughs
- CQR Nice to Have NTH-5/6/7 (OS path note, extra flag rows, CLAUDE.md vs AGENTS.md) — skipped (Q6 = A)
- Jira board transitions for AC-72…AC-79 — process after QA accepts (CQR Improvements #3)

### Phase 6: Code-quality Important polish (DELTA — Q6 = A)

**Goal**: Close Short-term Important docs findings from `docs/reports/code-quality-report.md` without expanding into Nice to Have or Jira transitions.

**Description**: Docs-only edits for Skills MVP accuracy (site sweep), Installation↔README default-command clarity, and Domain Context relative links. Confirm verify-only dead/dup rows.

**Verification:** Stale “no `.cursor/skills` mirror / MCP-only” claims gone from listed files; Installation clarifies vs README sample; `domain-context.md` uses `../getting-started/…`; `npm run website:build` exit 0.

#### Task 6.1 - [MODIFY] Fix Skills MVP wording (IMP-1)

**Description**: Replace the inaccurate “MVP does not ship a full `.cursor/skills` mirror / Cursor skills stay MCP-only” claim with: relative skill mirrors exist under `.cursor/skills/eversis-*` (framework + installer); prefer MCP `eversis_skills_*` / load-by-id for discovery; do **not** register `.cursor/skills` as Cursor **Agent Skills** UI; prompt slash shims under `.cursor/commands/` / `.claude/commands/` remain. Update all siblings in the Q6-A sweep list.

**Files:**
- `website/docs/getting-started/installation.mdx` (modify)
- `README.md` (modify — MVP note ~L161)
- `website/docs/intro.md` (modify — Skills and prompts MVP)
- `website/docs/getting-started/quick-wins.md` (modify — intro paragraph)
- `website/docs/reference/framework-reference.md` (modify — MVP skills line)

**Definition of Done**:

- [ ] None of the listed files claim Cursor has no `.cursor/skills` mirror or “skills stay MCP-only” as the whole story
- [ ] Each updated passage states mirrors exist and must not be registered as Agent Skills UI
- [ ] Prompt slash-shim note (`commands/`) preserved where it already existed

**Clues**: Match tone of `AGENTS.md` Channel notes / skills overview. Do **not** edit historical `CHANGELOG.md` / generated `website/src/pages/changelog.md`. Out of this task: `prerequisites.mdx`, `documentation/agent-collection.md`, `migration-from-cursor-collections.md` (same stale phrase may remain — optional later).

#### Task 6.2 - [MODIFY] Clarify Installation vs README install defaults (IMP-2)

**Description**: On Installation Step 2, add one short note that the README shows a Cursor-only minimal sample (`--agents=cursor`, `--build-mcp` optional) while this page’s recommended command installs Cursor + Claude with `--build-mcp`. On README install section, keep the minimal sample but ensure the existing “Full install guide (including Windows)” pointer remains visible near the sample (strengthen if needed).

**Files:** `website/docs/getting-started/installation.mdx` (modify — Task 6.1), `README.md` (modify — Task 6.1)

**Definition of Done**:

- [ ] Installation Step 2 explains the relationship to the README minimal sample
- [ ] README still points readers to Installation for the full guided / Windows path
- [ ] Recommended Installation command flags unchanged (`--agents=cursor,claude`, `--mcp-servers=eversis-collections`, `--build-mcp`)

**Clues**: Prefer clarify over rewriting README to match Installation exactly (both remain valid).

#### Task 6.3 - [REUSE] Verify Domain Context links (IMP-4 — false positive)

**Description**: CQR suggested changing `./getting-started/…` to `../getting-started/…` from the on-disk `reference/` folder. The page publishes at slug **`/domain-context`** (sibling of `/docs/getting-started/…` in URL space). `../getting-started/` resolves to `/getting-started/…` and **fails** `website:build` broken-link check. Keep `./getting-started/…`.

**Files:** `website/docs/reference/domain-context.md` (reuse — no edit)

**Definition of Done**:

- [x] Links remain `./getting-started/installation#vendor-modes` and `./getting-started/mcp-setup#…`
- [x] `npm run website:build` passes with those hrefs (verified after failed `../` attempt)

**Clues**: Prefer absolute `/docs/getting-started/…` only if a future slug change breaks `./getting-started/`.

#### Task 6.4 - [REUSE] Verify-only CQR rows + website build

**Description**: Confirm dead-code rows (no `installation.md`, no screenshot dir) and by-design duplications (Docker tips / Start here) unchanged. Run `npm run website:build`.

**Files:** `website/docs/getting-started/installation.mdx` (reuse), inbound files from 6.1–6.3 (reuse)

**Definition of Done**:

- [ ] Confirm `installation.md` still absent; no `website/static/img/getting-started/installation/`
- [ ] Confirm Docker tip / Start here overlap left as-is (no merge)
- [ ] Run `npm run website:build` (exit 0)

**Clues**: Clear webpack/`.docusaurus` caches only if ENOSPC recurs.

#### Task 6.5 - [REUSE] Code review by Code Reviewer

**Description**: Independent review of Phase 6 edits only (plus confirm verify-only). On PASS, Fine with a short polish QA note on AC-72 (children optional one-liner pointing to epic).

**Files:** files touched in Tasks 6.1–6.3 (reuse)

**Definition of Done**:

- [ ] Run `npm run website:build`
- [ ] Code review passes with no blocking findings
- [ ] Phase 6 QA checklist below verified
- [ ] Review outcome documented in Changelog

**Clues**: Do not re-litigate AC-73–AC-79 happy-path AC unless a regression appears.

## Quality Assurance — Phase 6 (CQR Important)

- [x] IMP-1: Skills MVP wording accurate on Installation + README + intro + quick-wins + framework-reference
- [x] IMP-2: Installation↔README defaults relationship explicit; Installation recommended flags unchanged
- [x] IMP-4: Verified `./getting-started/…` correct for slug `/domain-context` (`../` breaks build — CQR false positive)
- [x] VERIFY: no leftover `installation.md` / installation screenshot dir; Docker/Start here dups untouched
- [x] `npm run website:build` exit 0
- [x] NTH-5/6/7 and Jira transitions **not** done (Q6 = A)

## Human gates

1. ~~Approve research~~ — done (`Q4. keep explicit; research ok — make the plan`)
2. ~~Approve this plan~~ — done (`Plan is ok. Implement`) for original rewrite
3. ~~Implement → Review → Fine~~ — original AC-73…AC-79 delivery complete
4. ~~Approve research DELTA~~ — done (`Q6. A; research ok — make the plan`)
5. ~~Approve this refreshed plan (Phase 6)~~ — done (`plan ok — implement`)
6. ~~Implement Phase 6 → Review → Fine~~ — done (review PASS)

## Changelog

| Date | Change Description |
| --- | --- |
| 2026-10-14 | Initial plan created from approved research (Q1–Q5 locked); whole-epic Installation MDX rewrite AC-73–AC-79 |
| 2026-10-14 | Plan approved (`Plan is ok. Implement`); implementation started |
| 2026-10-14 | Implementation complete; `npm run website:build` exit 0; Code review PASS; Fine |
| 2026-10-14 | **REFRESH** — Phase 6 CQR Important polish (Q6 = A): IMP-1 Skills wording sweep, IMP-2 defaults clarify, IMP-4 domain-context links, verify-only + build + review |
| 2026-10-14 | Phase 6 implemented; IMP-4 false positive (keep `./getting-started/` for slug `/domain-context`); `website:build` exit 0; Code review PASS; Fine |
