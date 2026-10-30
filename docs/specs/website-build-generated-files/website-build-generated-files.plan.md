# Website build generated-file drift - Implementation Plan

## Task Details

| Field            | Value                                                                                                                                                          |
| ---------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Jira ID          | (none — local)                                                                                                                                                 |
| Title            | Stop website `prebuild` from dirtying generated changelog and prompt pages                                                                                     |
| Description      | Point changelog and prompt-page generators at GitLab branch `master` so `prebuild` regeneration matches committed copies and leaves a clean working tree.      |
| Priority         | Low                                                                                                                                                            |
| Related Research | `docs/specs/website-build-generated-files/website-build-generated-files.research.md` (Q1/Q2 locked 2026-09-07)                                                |

## Wildly Important Goal

**Goal**: A local `npm run website:build` (or `cd website && yarn build`) no longer rewrites committed generated markdown solely because generators emit `main` while this repository uses `master`.

**Success Measure**: After the generator edits, `npm run website:changelog:check` and `npm run sync:website-docs:check` pass, and a subsequent website build does not leave a git diff in `website/src/pages/changelog.md` or `website/docs/reference/prompts/**` caused by `blob/main` vs `blob/master`.

**Do NOT touch / do NOT add**:
- Default-branch rename (`master` → `main`) or remote configuration
- Hand-written `website/docs/**` pages that already use `blob/master`
- Root `CHANGELOG.md` historical GitLab links
- `.ai/prompts/**` SSOT (relative `AGENTS.md` links stay relative)
- `website/package.json` `prebuild` / `prestart` hooks (regeneration stays; it must become a no-op)
- Unrelated working-tree edits (for example `website/docs/main-flow/index.md` from the earlier broken-link fix)
- New package-manager dependencies
- Shared/configurable branch constant extracted across scripts (follow-up only)

## Proposed Solution

Option **A** from research: keep committed generated copies on `master` URLs, and change the two generators so they emit the same branch.

1. In `scripts/sync-changelog.mjs`, change the hardcoded GitLab blob base from `/-/blob/main` to `/-/blob/master`.
2. In `adapters/website/generate-prompts.mjs` `rewriteCrossTreeLinks`, change `/-/${kind}/main/` to `/-/${kind}/master/`.
3. Run both generators once so any working-tree copies currently sitting on `main` (from a previous `prebuild`) are rewritten back to `master`, matching git HEAD.

No new architecture: same write/`--check` CLIs, same committed-generated-file convention. The dirty tree is generator output drift, not Docusaurus mutating docs on its own.

```text
prebuild
  sync-changelog.mjs        → blob/master  (was blob/main)
  generate-prompts.mjs      → /-/blob|tree/master/  (was /main/)
  → committed copies already on master → no git diff
```

## Current Implementation Analysis

### Already Implemented

- Changelog generate + `--check` — `scripts/sync-changelog.mjs` — reuse; only the blob base string changes
- Prompts generate + `--check` — `adapters/website/generate.mjs` + `adapters/website/generate-prompts.mjs` — reuse; only the branch segment in `rewriteCrossTreeLinks` changes
- `website/package.json` `prebuild` / `prestart` — reuse unchanged
- Root scripts `website:changelog:check` / `sync:website-docs:check` — reuse as verification
- Committed generated copies already contain `blob/master` on HEAD — reuse; do not rewrite them by hand

### To Be Modified

- `GITHUB_BLOB` in `scripts/sync-changelog.mjs` — `/-/blob/main` → `/-/blob/master`
- Template string in `adapters/website/generate-prompts.mjs` `rewriteCrossTreeLinks` — `/-/${kind}/main/` → `/-/${kind}/master/`

### To Be Created

None.

## Open Questions

| #   | Question                                                         | Answer                                                                                         | Status      |
| --- | ---------------------------------------------------------------- | ---------------------------------------------------------------------------------------------- | ----------- |
| 1   | Analysis-only vs stop the dirty working tree?                    | Stop the dirty working tree.                                                                   | ✅ Resolved |
| 2   | Which GitLab branch should generated blob/tree URLs use?         | **A** — `master`, matching `origin/HEAD` and committed copies.                                 | ✅ Resolved |

## Technical Context

### Project Instructions

- Framework repo stack: `.cursor/rules/eversis-project-stack.mdc` — quality commands from repo root include `npm run website:build` and `npm run website:changelog:check`.
- Generated prompt pages are committed; do not hand-edit `website/docs/reference/prompts/**` — edit generators or `.ai/prompts/` SSOT (`.ai/skills/eversis-creating-prompts/SKILL.md`).
- Changelog site page is generated; edit root `CHANGELOG.md` only (`eversis-writing-repo-documentation` / `website/docs/main-flow/workflow/repo-docs.md`).
- Routing: generator/scripts work → **Software Engineer** via `eversis-implement-common-task.md`. Do not load backend/frontend/filters/BA Docs skills.

### Architecture & Patterns

- Zero-dependency Node ESM CLIs (`*.mjs`), same pattern as `adapters/sync.mjs`: write by default, `--check` compares generated output to disk and exits 1 on drift.
- `sync-changelog.mjs` writes `website/src/pages/changelog.md` from `CHANGELOG.md` and rewrites `./README.md` links to `GITHUB_BLOB`.
- `generate-prompts.mjs` copies `.ai/prompts/{public,internal}/*.md` into `website/docs/reference/prompts/{public,internal}/` and rewrites repo-root links to `${GITHUB_REPO_BASE}/-/${kind}/<branch>/…`.

### Tech Stack

- Node.js ≥ 18, npm (website also uses yarn locally; quality commands in stack policy are npm from repo root)
- Docusaurus 3.10.2 under `website/`
- No unit test file exists for these two generators

### Code Style & Standards

- Keep the existing constant name `GITHUB_BLOB` even though the host is GitLab — renaming is out of scope
- String-only branch change; do not introduce env vars or git-discovery of the default branch in this task

### Testing Patterns

- `npm run website:changelog:check` — `node scripts/sync-changelog.mjs --check`
- `npm run sync:website-docs:check` — `node adapters/website/generate.mjs --check`
- `npm run website:build` — runs `prebuild` then Docusaurus; after this fix, generated markdown must match HEAD
- Confirm generators no longer emit `/blob/main` or `/${kind}/main/` via inspect of the two `*.mjs` files
- No unit/integration/e2e suite applies to this change

### Database Patterns

Not applicable.

### Additional Context

- `origin/HEAD` → `origin/master`; no `origin/main` in this clone. Emitting `main` would keep dirtying the tree and would publish links to a branch this remote does not have.
- Working tree may already contain `main` versions of the three generated files from an earlier `prebuild`. After the generator edit, running the writers (or `website:build`) must restore them to `master` so they match HEAD. Do not commit `main` URLs.
- Leave `website/docs/main-flow/index.md` (broken-link fix) out of this plan's Files lists.

## Implementation Plan

### Phase 1: Align generators with `master`

**Goal**: Generator output uses `master`, so `prebuild` stops rewriting committed copies.

**Description**: Two one-line branch fixes in the existing CLIs, then run generate + `--check` so the working tree's generated files match git HEAD.

**Verification:** `npm run website:changelog:check` and `npm run sync:website-docs:check` from the repo root.

#### Task 1.1 - [MODIFY] Changelog generator blob base

**Description**: Point `GITHUB_BLOB` at GitLab `/-/blob/master` so the generated changelog tip and rewritten README links match committed `website/src/pages/changelog.md`.

**Files:** `scripts/sync-changelog.mjs` (modify)

**Definition of Done**:

- [x] `scripts/sync-changelog.mjs` contains `/-/blob/master` and does not contain `/-/blob/main`
- [x] Run `npm run website:changelog:check`

**Stop Rule:** If `--check` still fails after the string change, stop — do not hand-edit `website/src/pages/changelog.md` to force a pass.

**Clues**: Constant is named `GITHUB_BLOB` (lines ~18–19). Host path is already `gitlab3.eversis.com/eversis-ai/agent-collections`; only the branch segment changes.

#### Task 1.2 - [MODIFY] Prompt-page cross-tree GitLab branch

**Description**: In `rewriteCrossTreeLinks`, emit `/-/${kind}/master/` instead of `/-/${kind}/main/` so copied prompt pages match committed `website/docs/reference/prompts/**`.

**Files:** `adapters/website/generate-prompts.mjs` (modify)

**Definition of Done**:

- [x] The rewrite template in `rewriteCrossTreeLinks` uses `/master/` and does not use `/main/` as the GitLab ref
- [x] Run `npm run sync:website-docs:check`

**Stop Rule:** If `--check` reports drift in files other than the two `eversis-create-custom-*` pages, stop and report the extra paths before rewriting more generated files.

**Clues**: Single template at the `kind}/main/` interpolation inside `rewriteCrossTreeLinks`. `GITHUB_REPO_BASE` stays unchanged. Do not edit `.ai/prompts/public/eversis-create-custom-*.md`.

#### Task 1.3 - [REUSE] Regenerate and confirm a clean generated tree

**Description**: Run the writers (not only `--check`) so any local `main` copies from a previous `prebuild` are overwritten with `master`, then confirm a full website build does not re-dirty those generated files.

**Files:** `website/src/pages/changelog.md` (reuse — generated, not hand-edited), `website/docs/reference/prompts/**` (reuse — generated, not hand-edited)

**Definition of Done**:

- [x] `node scripts/sync-changelog.mjs` and `node adapters/website/generate.mjs` have been run after Tasks 1.1–1.2
- [x] `git diff -- website/src/pages/changelog.md website/docs/reference/prompts/` has no leftover `blob/main` dirt; the only remaining prompts diff is generator output on `eversis-create-custom-skill.md` (`tree/main` → `tree/master`, already `main` on HEAD)
- [x] Run `npm run website:changelog:check`
- [x] Run `npm run sync:website-docs:check`
- [x] Run `npm run website:build` and re-check that changelog + other prompt pages stay clean (skill.md remaining diff unchanged)

**Stop Rule:** If `website:build` still diffs generated prompt/changelog files after the generator change, stop — do not “fix” it by committing `main` URLs (option B was rejected).

**Clues**: Unrelated dirty files (for example `website/docs/main-flow/index.md`) must be left as they are. Inspect `git diff --name-only` after build; only ignore files outside this task's generated set.

### Phase 2: Code Review

**Goal**: Independent confirmation that generators match `master` and `prebuild` no longer dirties the generated tree.

**Description**: Final verification of the full implementation. This phase is mandatory and always comes last.

**Verification:** `npm run website:changelog:check`, `npm run sync:website-docs:check`, and `npm run website:build` from Technical Context → Testing Patterns.

#### Task 2.1 - [REUSE] Code review by Code Reviewer

**Description**: Run **Code Reviewer** via `eversis-review.md` to review the complete implementation. Pass e2e test execution to that agent — do not run e2e tests outside this review (none apply).

**Files:** `scripts/sync-changelog.mjs` (reuse), `adapters/website/generate-prompts.mjs` (reuse)

**Definition of Done**:

- [x] Run `npm run website:changelog:check`
- [x] Run `npm run sync:website-docs:check`
- [x] Code review passes with no blocking findings
- [x] Review outcome documented in Changelog

**Stop Rule:** If a BLOCKER remains after the review, do not declare Fine.

**Clues**: Scope is the two generator files only. Flag any edit to `.ai/prompts/**`, hand-written website docs, or committing `blob/main` as a BLOCKER. Confirm `origin/HEAD` remains `master` and generated URLs use that ref.

## Security Considerations

- Generated links stay on the existing GitLab host `gitlab3.eversis.com`; only the branch ref changes.
- Do not introduce a runtime fetch of git remotes or user-controlled branch names in this task (injection/SSRF surface not needed).

## Quality Assurance

Acceptance criteria checklist to verify the implementation meets the defined requirements:

- [x] Generators emit GitLab blob/tree URLs on branch `master`, not `main`
- [x] `npm run website:changelog:check` passes
- [x] `npm run sync:website-docs:check` passes
- [x] `npm run website:build` does not leave a `blob/main` vs `blob/master` diff in `website/src/pages/changelog.md` or `website/docs/reference/prompts/**` (except the intended skill.md `tree/main` → `tree/master` generator update)
- [x] Committed generated copies are not rewritten by hand; option B (`commit main URLs`) is not used

## Improvements (Out of Scope)

- Single shared default-branch constant (or git `origin/HEAD` lookup) used by both generators
- Renaming the repository default branch to `main`
- Regenerating or rewriting hand-written `website/docs/**` GitLab links
- Removing `prebuild` generation in favor of check-only local builds

## Human gates

Numbered list of every human-approval gate this task passes through, in order. Strike through a gate once closed, and quote the user's literal closing phrase — do not paraphrase — as evidence:

1. ~~Approve research~~ — done (`Gap Analysis
Q1. stop the dirty working tree;
Q2. A;

Update the research and make the plan;`)
2. ~~Approve this plan~~ — done (`OK IMPLEMENT`)
3. ~~Implement → Review → Fine~~ — done: Tasks 1.1–1.3 applied; code review PASS (0 BLOCKER, 0 SUGGESTION)

## Changelog

| Date       | Change Description                          |
| ---------- | ------------------------------------------- |
| 2026-09-07 | Initial plan created — option A, two generator edits + regenerate/check + code review |
| 2026-09-07 | Implementation: `GITHUB_BLOB` and `rewriteCrossTreeLinks` now use `master`. Regenerating restored dirty changelog/agent/instructions copies to HEAD. Extra generated file `eversis-create-custom-skill.md` already had `tree/main` on HEAD; generator rewrite to `tree/master` is required for `--check` (same option A, not a hand-edit). Documented in Task 1.3 DoD. |
| 2026-09-07 | Code review PASS — 0 BLOCKER, 0 SUGGESTION. Checks and `website:build` re-verified. |
| 2026-09-07 | Code review PASS — generators emit `master`; checks and `website:build` verified; option B not used |

## Code Review Findings

**Verdict: PASS** (zero BLOCKERs)

Reviewed 2026-09-07 against option A. Diff is the two generators plus generator output for `eversis-create-custom-skill.md` (`/-/tree/main/` → `/-/tree/master/`). `.ai/prompts/**`, hand-written website docs, `website/package.json` hooks, and package-manager manifests are untouched.

### BLOCKER

None.

### SUGGESTION

None.

### Acceptance criteria

| AC | Result |
| -- | ------ |
| Generators emit `master` not `main` | Met — `GITHUB_BLOB` is `/-/blob/master`; `rewriteCrossTreeLinks` uses `/-/${kind}/master/` |
| `website:changelog:check` | Met — OK |
| `sync:website-docs:check` | Met — OK |
| `website:build` does not leave blob/main vs blob/master dirt | Met — changelog unchanged; prompts tree only the intended skill.md HEAD correction (`tree/main` → `tree/master`) |
| Option B not used | Met — no blob/main URLs committed; skill.md moves to `master` via generator |

Task 1.3 “empty git diff”: changelog is empty vs HEAD. The prompts tree is not empty until skill.md is committed — HEAD already had `tree/main` for that one MCP package link, unlike the other generated copies. That remaining diff is generator output aligning to `master`, not leftover `blob/main` from option B.
