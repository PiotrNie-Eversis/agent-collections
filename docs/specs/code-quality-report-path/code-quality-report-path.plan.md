# code-quality-report-path - Implementation Plan

## Task Details

| Field            | Value                                                                                         |
| ---------------- | --------------------------------------------------------------------------------------------- |
| Jira ID          | [AC-62](https://eversis.atlassian.net/browse/AC-62)                                            |
| Title            | Move `code-quality-report.md` output to `docs/reports/`                                       |
| Description      | Update `eversis-review-codebase` path SSOT, scaffold `docs/reports/`, MOVE existing root file |
| Priority         | Medium                                                                                        |
| Related Research | [`code-quality-report-path.research.md`](./code-quality-report-path.research.md)              |

## Wildly Important Goal

**Goal**: Agents writing via `eversis-review-codebase` save `code-quality-report.md` under `docs/reports/`, not the repository root.

**Success Measure**: Prompt SSOT + generated website copy say `docs/reports/code-quality-report.md`; root file is gone; report exists at the new path; `npm run sync:website-docs:check` and `npm run website:changelog:check` pass.

**Do NOT touch / do NOT add**: skill `eversis-codebase-analysing` path/template; dated multi-run report history; gitignore for `docs/reports/`; product application code; BA Docs / `.docx` flows.

## Proposed Solution

Locked decisions from research (user): **Q1 = B**, **Q2 = MOVE**, **Q3 = OK** (root visibility acknowledged, superseded).

1. Change `.ai/prompts/public/eversis-review-codebase.md` Output + Phase 4 from “repository root” to `docs/reports/code-quality-report.md`.
2. Create `docs/reports/README.md` describing the folder (agent-generated reports; overwrite last run; not SDD specs).
3. `git mv` (or equivalent) root `code-quality-report.md` → `docs/reports/code-quality-report.md`.
4. Regenerate website prompt docs via `npm run sync:website-docs`.
5. Document in root `CHANGELOG.md` + sync site changelog; add `docs/reports/` to `AGENTS.md` Project deliverables.
6. Cursor command shim already omits a hard-coded path (generic “markdown report file”) — re-run `npm run sync:adapters` only if generator regenerates that file from SSOT Executable; verify shim still correct.

```text
Before:  ./code-quality-report.md
After:   docs/reports/code-quality-report.md
SSOT:    .ai/prompts/public/eversis-review-codebase.md
Mirror:  website/docs/reference/prompts/public/eversis-review-codebase.md (generated)
```

## Current Implementation Analysis

### Already Implemented

- `eversis-review-codebase` prompt body and report template — `.ai/prompts/public/eversis-review-codebase.md`
- Website generator — `adapters/website/generate-prompts.mjs` / `npm run sync:website-docs`
- Cursor thin command — `.cursor/commands/eversis-review-codebase.md` (points to SSOT; no root path)
- Existing AC-36 audit content — root `code-quality-report.md`

### To Be Modified

- `.ai/prompts/public/eversis-review-codebase.md` — Output + Phase 4 path wording (two places)
- `website/docs/reference/prompts/public/eversis-review-codebase.md` — regenerate only (do not hand-edit)
- `AGENTS.md` — add `docs/reports/` to Project deliverables
- `CHANGELOG.md` — note path change + migration of existing report
- `website/src/pages/changelog.md` — via `npm run website:changelog:sync` (do not hand-edit)

### To Be Created

- `docs/reports/README.md` — folder convention
- `docs/reports/code-quality-report.md` — via MOVE from root

## Open Questions

| #   | Question | Answer | Status |
| --- | -------- | ------ | ------ |
| 1   | Target path under `docs/`? | B — `docs/reports/code-quality-report.md` | ✅ Resolved |
| 2   | Existing root file? | MOVE | ✅ Resolved |
| 3   | Root-visibility rationale for consumers? | OK — superseded; document in CHANGELOG | ✅ Resolved |

## Technical Context

### Project Instructions

- `.cursor/rules/eversis-project-stack.mdc` — framework repo; quality commands include `sync:adapters`, `sync:website-docs`, `website:changelog:check`
- `AGENTS.md` — `.ai/` SSOT; website prompt pages generated; deliverables triad + `docs/decisions/`
- Skill policy: load `eversis-writing-repo-documentation` for README/CHANGELOG/`docs/` edits; do **not** load BA Docs skills

### Architecture & Patterns

- Prompt SSOT: `.ai/prompts/public/*.md`
- Published prompt pages: generated under `website/docs/reference/prompts/` — edit source, run `npm run sync:website-docs`
- Cursor commands: thin HYBRID shims from `adapters/cursor/generate.mjs` (`npm run sync:adapters`)
- Agent deliverables live under `docs/` (`context/`, `plans/`, `specs/`, `decisions/`); `reports/` is a new sibling bucket for non-SDD generated reports

### Tech Stack

- Markdown SSOT + Node generators (`adapters/website/generate.mjs`, `adapters/sync.mjs`, `scripts/sync-changelog.mjs`)
- Package manager: npm (repo root)

### Code Style & Standards

- Prefer complete path strings in prompts (no ambiguous “repo root”)
- Do not hand-edit generated website prompt pages or `website/src/pages/changelog.md`
- Mirror neighbor README tone (`docs/plans/README.md`, `docs/specs/README.md`)

### Testing Patterns

- `npm run sync:website-docs:check` — prompt docs drift
- `npm run website:changelog:check` — changelog sync drift
- `npm run sync:adapters:check` — adapter/command drift (if adapters touched)
- Docs/content DoD: inspectable path strings and file presence (no unit tests for this change)

### Database Patterns

- N/A

### Additional Context

- Do **not** add `docs/reports/` to `.gitignore` (unlike `docs/specs/*/`)
- Skill `eversis-codebase-analysing` unchanged (defers to caller output path)
- Root `code-quality-report.md` is currently modified in the working tree — MOVE preserves content

## Implementation Plan

### Phase 1: Prompt SSOT + docs/reports scaffold + MOVE

**Goal**: Canonical path and on-disk layout match `docs/reports/code-quality-report.md`.

**Description**: Update the prompt, create the reports folder README, move the existing root report.

**Verification:** `rg -n 'repository root|docs/reports/code-quality-report' .ai/prompts/public/eversis-review-codebase.md`; `test ! -f code-quality-report.md && test -f docs/reports/code-quality-report.md && test -f docs/reports/README.md`

#### Task 1.1 - [MODIFY] Prompt output path in SSOT

**Description**: Replace both “repository root” / root-save instructions with `docs/reports/code-quality-report.md` in Output and Phase 4 of `eversis-review-codebase`.

**Files:** `.ai/prompts/public/eversis-review-codebase.md` (modify)

**Definition of Done**:

- [x] Output section names `docs/reports/code-quality-report.md` (no “repository root” for this file)
- [x] Phase 4 step saves to `docs/reports/code-quality-report.md`
- [x] `rg -n 'repository root' .ai/prompts/public/eversis-review-codebase.md` returns no matches for the report path (or only historical notes if any — prefer zero)

**Clues**: Two known sites ≈ lines 79 and 169; keep report template structure unchanged.

#### Task 1.2 - [CREATE] `docs/reports/README.md`

**Description**: Document purpose: agent-generated reports (starting with codebase quality); fixed filename overwrite; not part of SDD `docs/specs/`; consumers may adopt the same path.

**Files:** `docs/reports/README.md` (create)

**Definition of Done**:

- [x] README exists and states the canonical path `docs/reports/code-quality-report.md`
- [x] README states this folder is for non-SDD generated reports (distinct from `docs/specs/`)

**Clues**: Tone/structure like `docs/plans/README.md`.

#### Task 1.3 - [MODIFY] MOVE root report into `docs/reports/`

**Description**: Move `code-quality-report.md` from repo root to `docs/reports/code-quality-report.md` (prefer `git mv` if tracked; else filesystem move). Do not leave a root stub.

**Files:** `code-quality-report.md` (modify → relocate), `docs/reports/code-quality-report.md` (create via move)

**Definition of Done**:

- [x] `test ! -e code-quality-report.md` at repository root
- [x] `test -f docs/reports/code-quality-report.md`
- [x] File still starts with `# Code Quality Report` (content preserved)

**Stop Rule:** If content was intentionally emptied, stop and ask before overwriting.

### Phase 2: Sync generated docs + orientation pointers

**Goal**: Published docs and agent orientation match the new path.

**Description**: Regenerate website prompt pages, update CHANGELOG and AGENTS deliverables, sync changelog page.

**Verification:** `npm run sync:website-docs:check`; `npm run website:changelog:check`; `rg -n 'docs/reports/code-quality-report' website/docs/reference/prompts/public/eversis-review-codebase.md AGENTS.md CHANGELOG.md`

#### Task 2.1 - [MODIFY] Regenerate website prompt reference

**Description**: Run `npm run sync:website-docs` so the published `eversis-review-codebase` page matches SSOT. Do not hand-edit the generated file.

**Files:** `website/docs/reference/prompts/public/eversis-review-codebase.md` (modify — generated)

**Definition of Done**:

- [x] Generated page contains `docs/reports/code-quality-report.md`
- [x] Generated page does not instruct saving the report to the repository root
- [x] Run `npm run sync:website-docs:check`

#### Task 2.2 - [MODIFY] AGENTS.md deliverables + CHANGELOG

**Description**: Add `docs/reports/` to Project deliverables in `AGENTS.md`. Append a CHANGELOG entry explaining the path move and that root visibility is superseded. Sync `website/src/pages/changelog.md` via script.

**Files:** `AGENTS.md` (modify), `CHANGELOG.md` (modify), `website/src/pages/changelog.md` (modify — generated via sync)

**Definition of Done**:

- [x] `AGENTS.md` lists `docs/reports/` with a one-line role (agent-generated reports)
- [x] `CHANGELOG.md` mentions `eversis-review-codebase` → `docs/reports/code-quality-report.md`
- [x] Run `npm run website:changelog:sync` then `npm run website:changelog:check`

**Clues**: Edit root `CHANGELOG.md` only; never hand-edit `website/src/pages/changelog.md`.

#### Task 2.3 - [REUSE] Verify Cursor command shim

**Description**: Confirm `.cursor/commands/eversis-review-codebase.md` still points at SSOT and does not hard-code repository root. Run `npm run sync:adapters` only if needed to refresh; then `npm run sync:adapters:check`.

**Files:** `.cursor/commands/eversis-review-codebase.md` (reuse)

**Definition of Done**:

- [x] Shim SSOT path is `.ai/prompts/public/eversis-review-codebase.md`
- [x] Shim does not say “repository root” for the report
- [x] Run `npm run sync:adapters:check`

### Phase 3: Code Review

**Goal**: Independent review confirms path consistency and no leftover root instructions.

**Description**: Final verification of the full implementation. Mandatory last phase.

**Verification:** `npm run sync:website-docs:check`; `npm run website:changelog:check`; `npm run sync:adapters:check`

#### Task 3.1 - [REUSE] Code review by Code Reviewer

**Description**: Run **Code Reviewer** via `eversis-review.md` on the prompt/docs/MOVE change set. Confirm no root-path leftovers for this report and generators were used correctly.

**Files:** `.ai/prompts/public/eversis-review-codebase.md` (reuse), `docs/reports/README.md` (reuse), `docs/reports/code-quality-report.md` (reuse), `AGENTS.md` (reuse), `CHANGELOG.md` (reuse)

**Definition of Done**:

- [x] Run `npm run sync:website-docs:check`
- [x] Run `npm run website:changelog:check`
- [x] Code review passes with no blocking findings
- [x] Review outcome documented in Changelog

**Clues**: Grep whole repo for `code-quality-report.md` path strings; expect `docs/reports/` only (plus research/plan history).

## Security Considerations

- No secrets in the moved report; treat as normal markdown docs.
- Do not broaden `.gitignore` in a way that hides sensitive future reports without team agreement — out of scope.

## Quality Assurance

- [x] Prompt SSOT instructs `docs/reports/code-quality-report.md`
- [x] Website generated prompt page matches SSOT
- [x] Root `code-quality-report.md` does not exist
- [x] `docs/reports/code-quality-report.md` exists with preserved content
- [x] `docs/reports/README.md` documents the convention
- [x] `AGENTS.md` lists `docs/reports/`
- [x] CHANGELOG documents the change; site changelog check passes
- [x] Adapter check passes

## Improvements (Out of Scope)

- Dated / multi-run report filenames under `docs/reports/`
- Aligning standalone `eversis-codebase-analysing` example report path
- Installer scaffolding of empty `docs/reports/` in consumer projects
- Recording an ADR under `docs/decisions/` (optional follow-up if product wants formal decision log)

## Human gates

1. ~~Approve research~~ — done (`Q1. B.` / `Q2. MOVE;` / `Q3. OK;`)
2. ~~Approve this plan~~ — done (`Plan is ok.`)
3. ~~Create Jira ticket~~ — done ([AC-62](https://eversis.atlassian.net/browse/AC-62); `Create a ticket before implementation`)
4. ~~Implement → Review → Fine~~ — Implement 2026-10-14; Review PASS; Fine same session

## Changelog

| Date       | Change Description                                      |
| ---------- | ------------------------------------------------------- |
| 2026-10-14 | Initial plan created (path B, MOVE, Q3 OK locked)       |
| 2026-10-14 | Plan approved; Jira Task AC-62 created; implement deferred until after ticket |
| 2026-10-14 | Implemented AC-62; Review PASS (AC/DoD verified); Fine |
