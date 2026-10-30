# cursor-only-mislabel - Implementation Plan

## Task Details

| Field            | Value                   |
| ---------------- | ----------------------- |
| Jira ID          | none |
| Title            | Remove false `(Cursor-only)` / Cursor-exclusive host labels from 2 orchestration skill files and their published Docusaurus mirror |
| Description      | `eversis-orchestrating-implementation/SKILL.md` labels its Step 5 (Fine + QA draft) `(Cursor-only)` in 3 places, `eversis-technical-context-discovering/SKILL.md` labels its Step 1 (project instruction discovery) as Cursor-specific in 3 places, and its published Docusaurus mirror `website/docs/skills/technical-context-discovery.md` carries the same Step 1 mislabel in 1 more place (added via plan-review iteration 1, W1) — all three steps/sections are actually host-neutral and each label is contradicted by other files in the same framework (see Related Research). This is the third through sixth confirmed instances of the same host-exclusivity bug class in this repo (7 lines, 3 files). |
| Priority         | Low-Medium |
| Related Research | [`cursor-only-mislabel.research.md`](./cursor-only-mislabel.research.md) |

## Wildly Important Goal

**Goal**: Remove the false Cursor-exclusivity framing from all 7 confirmed lines across the 3 affected files so every fixed step/section reads as the host-neutral behavior it actually is.

**Success Measure**: A case-insensitive grep for `cursor-only` and for the literal string `Check Cursor project instructions` returns zero matches in `.ai/skills/eversis-orchestrating-implementation/SKILL.md` and `.ai/skills/eversis-technical-context-discovering/SKILL.md`; a grep for `Discover project instructions (Cursor)` returns zero matches in `website/docs/skills/technical-context-discovery.md`; all three files' surrounding meaning, step numbering, and cross-references are otherwise unchanged.

**Do NOT touch / do NOT add**: Do not edit `eversis-creating-prompts/SKILL.md`'s "Cursor markdown" framing (flagged in research as a separate, out-of-scope candidate needing its own human decision — different in shape from this ticket's per-step mislabeling, not folded in). Do not edit `website/docs/skills/technical-context-discovery.md:8`'s `**Folder:** .cursor/skills/...` line or any other content in that file beyond line 28 — only the confirmed same-bug-class line is in scope, not a general audit of that page. Do not touch any `.claude/commands/*` or `.cursor/commands/*` generated files (research confirmed skills are not compiled into adapter commands — no `sync:adapters` run needed). Do not touch any other file. Do not add a lint/audit rule for this bug class (not requested; would be new scope beyond the reported fix).

## Proposed Solution

Two plain text edits, same style as both this bug class's prior fixes (`8ef063e` and this ticket's own Q1 decision): name the behavior plainly and drop the host qualifier, rather than replacing it with a differently-scoped claim.

1. **`eversis-orchestrating-implementation/SKILL.md`** — remove `(Cursor-only)` from the todo template line, the Step 5 heading, and the Connected Skills bullet (3 lines), with no replacement text. This matches Option A locked in research Q1, and keeps Step 5 consistent with Steps 0-4 in the same file, none of which carry a host qualifier.
2. **`eversis-technical-context-discovering/SKILL.md`** — reword the 3 Step 1 lines that currently name "Cursor" as the subject of the step, so the step reads as project-instruction discovery in general (the step's own body already reads the host-neutral `AGENTS.md` first and treats `.cursor/rules/*.mdc` as one input among several, not the subject).
3. **`website/docs/skills/technical-context-discovery.md`** — reword the 1 heading line that mirrors the same false framing as #2 above, added to scope per plan-review iteration 1 (W1) and the human's explicit fold-in decision. This is the Docusaurus-published counterpart of the skill fixed in #2 — same bug class, same reword style, kept minimal (only the flagged heading; not a general audit of that page).

No diagrams needed — this is a same-shape, three-file text substitution with no control-flow or architectural change.

## Current Implementation Analysis

### Already Implemented

- Host-neutral phrasing pattern for this exact behavior — `.ai/skills/eversis-fine-handoff/SKILL.md:3`, `.ai/rules/orchestration/agent-core.md`, `.ai/rules/orchestration/fine-handoff.md`, `.ai/rules/orchestration/spec-driven-development.md` — all describe the Fine + QA-draft step with zero Cursor scoping. Use as the reference tone for Task 1.1.
- Precedent fix pattern — commit `8ef063e` (2026-08-19) already fixed the same bug class in `eversis-creating-skills` / `eversis-create-custom-*` by naming the current host's native mechanism generically instead of asserting exclusivity. Use as the reference tone for both tasks.
- Host-neutral `AGENTS.md` framing — `.ai/README.md:45` documents `AGENTS.md` as the instruction surface consumed by Cursor **and** Claude Code (via `CLAUDE.md`), not a Cursor-only artifact. `eversis-technical-context-discovering/SKILL.md`'s own Step 1 body already reads `AGENTS.md` first — only the labels (todo line, heading, "ALWAYS check first... (Cursor)" clause) are wrong.

### To Be Modified

- Step 5 todo template — `.ai/skills/eversis-orchestrating-implementation/SKILL.md:36` — `- [ ] Step 5: Declare Fine and produce QA comment draft (Cursor-only)` → drop `(Cursor-only)`.
- Step 5 section heading — `.ai/skills/eversis-orchestrating-implementation/SKILL.md:253` (corrected from an earlier line-253→250 drift caused by intervening commit `f312f73`, 2026-08-20; exact quoted text unaffected) — `### Step 5 - Declare Fine and produce QA comment draft (Cursor-only)` → drop `(Cursor-only)`.
- Connected Skills bullet — `.ai/skills/eversis-orchestrating-implementation/SKILL.md:267` (corrected from `264`, same drift as above) — `` - `eversis-fine-handoff` — mandatory QA comment draft on Fine (Cursor-only) `` → drop `(Cursor-only)`.
- Step 1 todo template — `.ai/skills/eversis-technical-context-discovering/SKILL.md:23` — `- [ ] Step 1: Check Cursor project instructions and rules` → reword to drop the Cursor-exclusive framing (e.g. `- [ ] Step 1: Check project instructions and rules`).
- Step 1 section heading — `.ai/skills/eversis-technical-context-discovering/SKILL.md:29` — `**Step 1: Check Cursor project instructions and rules**` → matching reword.
- Step 1 body clause — `.ai/skills/eversis-technical-context-discovering/SKILL.md:31` — `**ALWAYS check first** for project-level guidance (Cursor):` → drop the `(Cursor)` parenthetical (the bullets immediately below already name `AGENTS.md`, `.cursor/rules/*.mdc`, and `RULE.md` individually, so the parenthetical is redundant as well as inaccurate).
- Step 1 heading — `website/docs/skills/technical-context-discovery.md:28` — `### Step 1: Discover project instructions (Cursor)` → drop the `(Cursor)` parenthetical (the body immediately below already lists `AGENTS.md`, `.cursor/rules/*.mdc`, and `RULE.md` individually — same redundant-and-inaccurate shape as the `.ai/skills/` counterpart above; this is the published Docusaurus mirror of that same step).

### To Be Created

- None — this task only edits existing lines in existing files.

## Open Questions

| #   | Question   | Answer   | Status                |
| --- | ---------- | -------- | --------------------- |
| 1   | What should the Q1 fix be (remove vs. reword vs. no-op) for `eversis-orchestrating-implementation/SKILL.md`? | **A** — plain removal, no replacement text (locked in research) | ✅ Resolved |
| 2   | Should this ticket include a broader sweep for other host-exclusivity phrasing? | **B** — yes; sweep run inline during research, surfaced the `eversis-technical-context-discovering` instance now in this plan's scope | ✅ Resolved |
| 3   | Should the `eversis-creating-prompts/SKILL.md` "Cursor markdown" whole-skill framing be folded into this fix? | Out of scope for this plan — different shape of issue (whole-skill framing vs. mislabeled step); needs its own human decision if pursued | ✅ Resolved (excluded) |
| 4   | Plan-review iteration 1 (W1) found `website/docs/skills/technical-context-discovery.md:28` as an undiscovered 4th instance, outside research's `.ai/`-only sweep and outside the original plan scope — fold in or exclude? | **Fold in** — added as Task 1.3 | ✅ Resolved |

## Technical Context

Project conventions, coding standards, and patterns discovered during planning. Downstream agents MUST read this section instead of re-discovering the same context.

### Project Instructions

- This repo's own `CLAUDE.md` (root) is the Claude Code entry point; it embeds `agent-core.md`, `engineering-manager.md`, `testing-and-terminal.md`, `code-reviewer.md`, `fine-handoff.md`, `spec-driven-development.md` and already instructs host-neutral behavior for every step this plan touches — no project-specific override applies beyond those files (already reflected in this plan's Proposed Solution).
- `.ai/README.md` is this repo's own SSOT statement: `.ai/` is the vendor-neutral source of truth; Cursor, Claude Code, and OpenCode are consuming adapters, not owners of canonical content. Both files this plan touches live under `.ai/skills/` and must stay consistent with that framing.

### Architecture & Patterns

- This is a documentation/content-only repo tree (`.ai/skills/<topic>/SKILL.md`, flat Markdown files with YAML frontmatter). No application code, build step, or runtime for these files.
- `.ai/skills/` is **not** synced or regenerated into adapter output (confirmed in research: `eversis-creating-prompts/SKILL.md:153` — "`.ai/skills/` are not synced"; skills are consumed live via MCP `eversis_skills_get` or direct file read). No `npm run sync:adapters` step is required for this fix.

### Tech Stack

- Markdown files, no language runtime for this task. Repo has a root `package.json` with scripts limited to `sync:adapters(:check)`, `mcp:build`, `mcp:test`, `installer:smoke`, `website:build`, `website:changelog:sync(:check)` — none apply to `.ai/skills/*.md` edits.

### Code Style & Standards

- Match existing `SKILL.md` Markdown conventions in both files: fenced-code todo-list blocks, `###`/`####` headings, bullet lists with bold lead terms. Do not change heading levels, list structure, or step numbering — only the flagged words/phrases.
- Follow the host-neutral phrasing precedent from `8ef063e` and from the reference files listed in Current Implementation Analysis → Already Implemented: name the behavior plainly; do not hardcode a single host as the subject.

### Testing Patterns

- No automated test suite covers `.ai/skills/*.md` content (confirmed: no lint/markdown-check script in `package.json` targets this tree).
- Verification for this task is grep-based and deterministic (see each task's Definition of Done) — this satisfies the plan-content-rule for docs/content tasks with no runnable command.

### Database Patterns

- Not applicable.

### Additional Context

- Both files are `user-invocable: false` skills loaded by other rules/skills at runtime (`engineering-manager.md` references `eversis-orchestrating-implementation`; multiple `*-implement-*` prompts and skills reference `eversis-technical-context-discovering`). Edits must preserve exact heading text used elsewhere for cross-references — confirmed via grep in Task 1.1/1.2 Definition of Done that no other file quotes the removed parentheticals **verbatim**. This is a verbatim-only check scoped to `.ai/`; it does not establish that no other file expresses the same bug class in different words (see Human gates note on `website/docs/skills/` below — plan-review iteration 1, W1).

## Implementation Plan

### Phase 1: Remove the false Cursor-exclusivity labels

**Goal**: Close out the Wildly Important Goal directly — both mislabeled steps read as host-neutral in both files.

**Description**: Three independent, same-shape text edits (no shared code, no ordering dependency between the files). Each task is a direct line substitution per Current Implementation Analysis → To Be Modified. Task 1.3 was added after plan-review iteration 1 (W1) surfaced a 4th same-bug-class instance outside research's original `.ai/`-only sweep; the human explicitly chose to fold it in rather than defer it.

**Verification:** `grep -rniE "cursor-only" .ai/skills/eversis-orchestrating-implementation/SKILL.md`, `grep -rniE "check cursor project" .ai/skills/eversis-technical-context-discovering/SKILL.md`, and `grep -rniE "discover project instructions \(cursor\)" website/docs/skills/technical-context-discovery.md` — all three must return no matches after the edits.

#### Task 1.1 - [MODIFY] Remove `(Cursor-only)` from `eversis-orchestrating-implementation/SKILL.md`

**Description**: Remove the `(Cursor-only)` parenthetical from the Step 5 todo-template line, the Step 5 section heading, and the Connected Skills bullet referencing `eversis-fine-handoff`. No replacement text — matches Option A locked in research Q1. Do not alter Steps 0-4 or any other content in this file.

**Files:** `.ai/skills/eversis-orchestrating-implementation/SKILL.md` (modify)

**Definition of Done**:

- [x] Lines 36, 253, and 267 no longer contain `(Cursor-only)`; step numbering, heading levels, and surrounding text are otherwise unchanged. (Corrected from originally-cited 250/264 — plan-review iteration 1 found an intervening same-day commit, `f312f73`, shifted these two lines by +3; exact quoted text was unaffected, only line numbers drifted. Match by exact quoted text, not by line number, if any further drift is suspected at execution time.)
- [x] Run `grep -rniE "cursor-only" .ai/skills/eversis-orchestrating-implementation/SKILL.md` and confirm zero matches.
- [x] Run `grep -rn "Step 5" .ai/skills/eversis-orchestrating-implementation/SKILL.md` and confirm the todo line (`:36`) and heading (currently `:253`, verify at execution time) still exist with matching step text minus the removed parenthetical.

**Stop Rule:** If any other file in the repo is found to express this same bug class — a step or capability wrongly framed as Cursor-specific, whether via a verbatim `(Cursor-only)` tag or a differently-worded equivalent — stop and flag it instead of silently expanding or silently ignoring scope. (Broadened per plan-review iteration 1, W2: a verbatim-only check would not have caught this plan's own Task 1.2 target, which is itself a paraphrase.)

**Clues**: Reference tone from `agent-core.md`, `fine-handoff.md`, `spec-driven-development.md`, and `eversis-fine-handoff/SKILL.md:3` — all describe this same step with zero Cursor scoping.

#### Task 1.2 - [MODIFY] Reword Cursor-exclusive Step 1 framing in `eversis-technical-context-discovering/SKILL.md`

**Description**: Reword the Step 1 todo-template line, section heading, and "ALWAYS check first" clause so the step is framed as project-instruction discovery in general, not a Cursor-specific step. Keep `.cursor/rules/*.mdc` in the existing bullet list below (line 34) unchanged — it stays as one of several inputs, which is already accurate; only the 3 lines that name Cursor as the step's subject change. Do not alter Steps 2-4 or any other content in this file.

**Files:** `.ai/skills/eversis-technical-context-discovering/SKILL.md` (modify)

**Definition of Done**:

- [x] Lines 23, 29, and 31 no longer name "Cursor" as the subject of Step 1 (todo line, heading, and "ALWAYS check first" clause reworded per To Be Modified); the bullet list below (lines 33-36, including the `.cursor/rules/*.mdc` bullet) is unchanged.
- [x] Run `grep -rniE "check cursor project" .ai/skills/eversis-technical-context-discovering/SKILL.md` and confirm zero matches.
- [x] Run `grep -n "Step 1" .ai/skills/eversis-technical-context-discovering/SKILL.md` and confirm the todo line (`:23`) and heading (`:29`) still exist with matching step text minus the Cursor-exclusive framing.

**Stop Rule:** If rewording Step 1's heading would require renumbering or restructuring Steps 2-4, stop and escalate instead of expanding the edit beyond the 3 flagged lines.

**Clues**: The step's own body already reads `AGENTS.md` first (host-neutral, per `.ai/README.md:45`) before listing `.cursor/rules/*.mdc` — the reword only needs to match what the step already does, not change its behavior.

#### Task 1.3 - [MODIFY] Reword Cursor-exclusive Step 1 heading in `website/docs/skills/technical-context-discovery.md`

**Description**: Reword the Step 1 heading (the published Docusaurus mirror of Task 1.2's skill) to drop the `(Cursor)` parenthetical, matching Task 1.2's reword style. Added to scope via plan-review iteration 1 (W1) and the human's explicit fold-in decision. Do not touch line 8 (`**Folder:** .cursor/skills/...`) or any other content on this page — only the flagged heading is in scope, per Do NOT touch.

**Files:** `website/docs/skills/technical-context-discovery.md` (modify)

**Definition of Done**:

- [x] Line 28 no longer contains `(Cursor)`; the body below (lines 30-34, listing `AGENTS.md`, `.cursor/rules/*.mdc`, `RULE.md`) is unchanged; line 8's `**Folder:**` line is unchanged.
- [x] Run `grep -rniE "discover project instructions \(cursor\)" website/docs/skills/technical-context-discovery.md` and confirm zero matches.
- [x] Run `grep -n "Step 1" website/docs/skills/technical-context-discovery.md` and confirm the heading still exists at (or near) line 28 with matching step text minus the removed parenthetical.

**Stop Rule:** If fixing this heading is found to require a Docusaurus build/link-check step beyond the grep checks above (e.g. `website/build` or `validate-cursor-markdown-links.mjs` failing because of this edit), stop and confirm with the user before adding a build step to this plan's scope.

**Clues**: This file is the published-docs counterpart of `eversis-technical-context-discovering/SKILL.md` (Task 1.2) — same step, same false framing, same fix shape. Confirmed manually authored, not generated: no `scripts/` or `adapters/` sync script references `website/docs/skills/`, and its `git log` shows a single commit (`71c6dae`, initial Docusaurus content add) with no subsequent sync commits — safe to hand-edit directly.

### Phase 2: Code Review

**Goal**: Independently verify both text edits match the locked research decisions and introduce no unintended drift before declaring Fine.

**Description**: Final verification of the full three-file change. This phase is mandatory and always comes last.

**Verification:** `grep -rniE "cursor-only" .ai/skills/eversis-orchestrating-implementation/SKILL.md` and `grep -rniE "check cursor project" .ai/skills/eversis-technical-context-discovering/SKILL.md` (both zero matches) plus a manual diff read of both files.

#### Task 2.1 - [REUSE] Code review by Code Reviewer

**Description**: Run **Code Reviewer** via `eversis-review.md` to review the complete three-file diff against this plan and the locked research decisions (Q1 → A, Q2 → B, plus the Task 1.3 fold-in decision from plan-review iteration 1). No e2e tests apply to this task (docs-only change).

**Files:** `.ai/skills/eversis-orchestrating-implementation/SKILL.md` (reuse), `.ai/skills/eversis-technical-context-discovering/SKILL.md` (reuse), `website/docs/skills/technical-context-discovery.md` (reuse)

**Definition of Done**:

- [x] Run `grep -rniE "cursor-only" .ai/skills/eversis-orchestrating-implementation/SKILL.md`, `grep -rniE "check cursor project" .ai/skills/eversis-technical-context-discovering/SKILL.md`, and `grep -rniE "discover project instructions \(cursor\)" website/docs/skills/technical-context-discovery.md` — all three zero matches.
- [x] Code review passes with no blocking findings.
- [x] Review outcome documented in Changelog.

**Stop Rule:** If review finds a third file with the same bug class not covered by research's broader sweep, stop and confirm scope expansion with the user before fixing it in this same plan.

**Clues**: Review scope is intentionally narrow — 7 lines, 3 files, no logic change. The main review risk is accidental over-editing (e.g. touching Steps 0-4 or 2-4, the `.cursor/rules/*.mdc` bullet that should stay unchanged, or line 8's `**Folder:**` line in the Docusaurus file).

## Security Considerations

- None — plain-text documentation edit, no secrets, no executable content, no adapter regeneration, no dependency changes.

## Quality Assurance

Acceptance criteria checklist to verify the implementation meets the defined requirements:

- [x] `eversis-orchestrating-implementation/SKILL.md` no longer labels Step 5 `(Cursor-only)` anywhere (todo line, heading, Connected Skills bullet).
- [x] `eversis-technical-context-discovering/SKILL.md` no longer frames Step 1 as Cursor-specific (todo line, heading, "ALWAYS check first" clause).
- [x] `website/docs/skills/technical-context-discovery.md` no longer frames Step 1 as Cursor-specific (heading, line 28).
- [x] None of the 3 files' step numbering, structure, or unrelated content changed.
- [x] No adapter regeneration (`sync:adapters`) run or required.
- [x] `eversis-creating-prompts/SKILL.md` left untouched (out of scope per this plan's Do NOT touch clause).

## Improvements (Out of Scope)

- Deciding whether `eversis-creating-prompts/SKILL.md`'s whole-skill "Cursor markdown" framing should be reworded — flagged in research as a differently-shaped issue (whole-skill purpose framing vs. a mislabeled step) that needs its own human decision, potentially its own research file, before any fix is planned.
- Adding a repo-wide lint/CI check that scans `.ai/` for host-exclusivity language drift on every change — research noted no such systematic check exists today and all 4 known instances (2 prior, 2 in this ticket) were caught by manual inspection during unrelated work.

## Human gates

Numbered list of every human-approval gate this task passes through, in order. Strike through a gate once closed, and quote the user's literal closing phrase — do not paraphrase — as evidence:

1. ~~Approve research~~ — done (`"RESEARCH IS OK, NOW MAKE THE PLAN"`)
2. ~~Approve this plan~~ — done (`"I approve this plan"`; revised scope re-confirmed via `"yes, proceed"` after plan-review iteration 2 and the Task 1.3 fold-in decision)
3. ~~Implement → Review → Fine~~ — done (Tasks 1.1-1.3 implemented and verified; Code Review PASS, 0 blockers)

## Changelog

| Date   | Change Description   |
| ------ | -------------------- |
| 2026-08-20 | Initial plan created — 2 phases, 3 tasks, covering both confirmed fix sites from research (Q1 → A: `eversis-orchestrating-implementation/SKILL.md`; Q2 → B broader sweep finding: `eversis-technical-context-discovering/SKILL.md`). All Open Questions resolved from research; `eversis-creating-prompts` framing explicitly excluded per Do NOT touch. |
| 2026-08-20 | Plan-review iteration 1 (`cursor-only-mislabel.plan-review.md`) returned REVISIONS NEEDED (1 blocker, 2 warnings, 2 suggestions). Fixed in this revision: **B1** — corrected stale Task 1.1 line citations (250→253, 264→267; intervening same-day commit `f312f73` shifted the file, exact quoted text unaffected) in To Be Modified and Task 1.1 DoD. **W2** — broadened Task 1.1's Stop Rule from verbatim-quote-only to "same bug class, worded differently or not." **S1** — added a scope caveat to the Additional Context "no other file quotes verbatim" claim. **W1** (undiscovered same-bug-class instance in `website/docs/skills/technical-context-discovery.md:28`, outside both research's `.ai/`-scoped sweep and this plan's stated scope) is a human scope decision, not a plan-author fix — pending human answer before re-review. |
| 2026-08-20 | Human resolved W1: **fold in**. Added Task 1.3 (`website/docs/skills/technical-context-discovery.md:28`, same reword shape as Task 1.2) to Phase 1; confirmed the file is manually authored, not sync-generated, via `git log` + no matching `scripts/`/`adapters/` sync reference. Updated Wildly Important Goal (6→7 lines, 2→3 files), Success Measure, Do NOT touch, To Be Modified, Open Questions (#4 resolved), Phase 1 Description/Verification, Task 2.1 Files/DoD, and Quality Assurance checklist accordingly. Ready for plan-review iteration 2. |
| 2026-08-20 | Plan-review iteration 2 returned **APPROVED** (0 blockers, 2 warnings, 2 suggestions). All iteration-1 items re-verified fixed against current disk state. Fixed both new cosmetic warnings: Task Details Title/Description and Phase 2's Description/Clues still read "2 files/6 lines" despite Tasks 1.1-1.3/2.1 already reflecting 3 files/7 lines — updated both to match. Plan is approved and execution-ready pending final human confirmation to proceed (Planning sequence step 12 — plan was materially changed since the human's original approval). |
| 2026-08-20 | Human confirmed execution (`"yes, proceed"`). Tasks 1.1 and 1.2 delegated to Software Engineer (both `.ai/skills/*.md` edits); Task 1.3 delegated to Repo Docs Writer (`website/docs/skills/*.md` edit) — independent, run in parallel. All 3 tasks completed exactly per Definition of Done; `git diff` confirmed only the 7 intended lines changed across the 3 files, no incidental drift. Code Review ran as a genuinely separate context (did not write the edits) — **PASS**, 0 blockers, 0 suggestions: diff matches plan exactly, all 3 grep verifications zero matches, `eversis-creating-prompts/SKILL.md` untouched, no stale cross-references found repo-wide. All Definition of Done and Quality Assurance checkboxes marked complete; Human gates 2 and 3 closed. Declaring **Fine**. |
