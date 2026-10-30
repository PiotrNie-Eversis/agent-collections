# docs-specs-gitignore-scope - Implementation Plan

## Task Details

| Field            | Value |
| ---------------- | ----- |
| Jira ID          | none |
| Title            | `docs/specs/dhi-*/` gitignore pattern misses non-DHI analysis, leaking internal artifacts into the OSS repo |
| Description      | `.gitignore` only excludes `docs/specs/dhi-*/`. Broaden to `docs/specs/*/`, untrack the 3 already-committed non-DHI leaked folders (keep working-tree copies, no history rewrite), and update the docs that state the narrower rule as fact. |
| Priority         | Medium (governance/hygiene; already caused repeated real leaks) |
| Related Research | [`docs-specs-gitignore-scope.research.md`](./docs-specs-gitignore-scope.research.md) |

## Wildly Important Goal

**Goal**: No spec/research/plan folder under `docs/specs/`, regardless of the originating ticket prefix (or lack of one), can ever be committed to the public `agent-collections` repo again — `CHANGELOG.md` remains the only durable, published record of what changed.

**Success Measure**: `git check-ignore -v docs/specs/claude-code-setup/ docs/specs/claude-code-setup-website-docs/ docs/specs/setup-framework-prefix-unknown-arg/` matches all three (exit `0`); `git ls-files docs/specs/` returns only `docs/specs/README.md`; `git status --porcelain docs/specs/` is empty; `npm run sync:adapters:check` stays green after `spec-driven-development.md` changes.

**Do NOT touch / do NOT add**:

- Contents of the 3 leaked folders (`cursor-collection-migration/`, `pilot-feedback-framework-deltas/`, `website-changelog-sync/`) — untrack only, keep working-tree files as-is, no edits to their content
- Git history / any rewrite, rebase, or `filter-repo` on already-committed commits (Q2 locked as "untrack going forward" only)
- The dead `docs/specs/dhi-*/` cross-links in `.ai/README.md`, `.ai/prompts/README.md`, `.ai/skills/README.md`, `docs/context/agent-collections/delivery-index.md` — separate pre-existing problem (links into gitignored folders), out of scope
- Historical `CHANGELOG.md` entries (e.g. the `0.0.1` entry describing the original `dhi-*` rule) — changelog history is not rewritten, only a new `Unreleased` entry is added
- `CLAUDE.md` — generated file; edit the `.ai/rules/orchestration/spec-driven-development.md` source and regenerate via `npm run sync:adapters`, never hand-edit the output
- New npm dependencies

## Proposed Solution

Three mechanical steps, in this order (ignore rule first so untracking immediately lands the folders in "ignored" state rather than "untracked"):

1. **`.gitignore`**: replace `docs/specs/dhi-*/` with `docs/specs/*/` (directory-only glob; `docs/specs/README.md` is a file, unaffected).
2. **Untrack the 3 leaked folders**: `git rm -r --cached docs/specs/cursor-collection-migration docs/specs/pilot-feedback-framework-deltas docs/specs/website-changelog-sync` — removes them from the index only, working-tree files stay on disk.
3. **Docs**: update every place that states "`docs/specs/dhi-*/` is gitignored" as fact to instead say "all `docs/specs/*/` subfolders are gitignored, regardless of ticket prefix" — `docs/specs/README.md`, `.ai/rules/orchestration/spec-driven-development.md` (then `npm run sync:adapters` to regenerate `CLAUDE.md`), `docs/plans/README.md`, `docs/architecture/agents-md-standard.md` — plus a new `CHANGELOG.md` `Unreleased` → `Fixed` entry.

## Current Implementation Analysis

### Already Implemented

- `.gitignore:7-8` — narrow `docs/specs/dhi-*/` rule; **needs modification**
- `docs/specs/README.md` "This repository (`agent-collections`)" section — states the narrow rule; **needs modification**
- `.ai/rules/orchestration/spec-driven-development.md` "This framework repository vs consumers" section — states the narrow rule, flows into `CLAUDE.md`; **needs modification**
- `docs/plans/README.md` line 13 — states the narrow rule; **needs modification**
- `docs/architecture/agents-md-standard.md` line 42 — states the narrow rule; **needs modification**
- `CHANGELOG.md` `[Unreleased]` section — present, has existing `### Fixed` subsection to append to
- `adapters/claude/generate.mjs` / `npm run sync:adapters` — regenerates `CLAUDE.md` from `.ai/rules/**`; reusable as-is, no code change needed

### To Be Modified

- `.gitignore` — pattern broaden
- `docs/specs/README.md` — wording
- `.ai/rules/orchestration/spec-driven-development.md` — wording (source of truth; regenerate `CLAUDE.md` after)
- `docs/plans/README.md` — wording
- `docs/architecture/agents-md-standard.md` — wording
- `CHANGELOG.md` — new `Unreleased` → `Fixed` bullet
- `CLAUDE.md` — regenerated output only (via `npm run sync:adapters`, not hand-edited)
- Git index (not a file) — untrack 3 folders via `git rm -r --cached`

### To Be Created

- Nothing (no new files; this is a scope-tightening + doc-accuracy fix)

## Open Questions

| # | Question | Answer | Status |
| --- | --- | --- | --- |
| 1 | What should the `.gitignore` rule match? | Option A: `docs/specs/*/` (all subfolders, no prefix dependency) | ✅ Resolved |
| 2 | Does broadening `.gitignore` retroactively fix the 3 already-committed folders? | No — untrack going forward via `git rm -r --cached`; no history rewrite | ✅ Resolved |
| 3 | Should convention docs be updated in the same change? | Yes | ✅ Resolved |

## Technical Context

### Project Instructions

- This repo: framework self-improvement work, not a DHI ticket — matches the exact gap this fix closes
- Delivery Standard: research approved 2026-08-14; this plan must be human-approved before broad changes (none of the edits here are "broad" — single-line `.gitignore` change, index-only untrack, wording-only doc edits — but the gate still applies per policy)
- `CLAUDE.md` is generated from `.ai/rules/**` via `adapters/claude/generate.mjs`; any change to rule content must go through the `.ai/rules/` source + `npm run sync:adapters`, never a direct edit to root `CLAUDE.md`

### Architecture & Patterns

- Root `CHANGELOG.md` is the changelog SSOT; `website/src/pages/changelog.md` is generated via `scripts/sync-changelog.mjs` (`npm run website:changelog:sync` / `:check`) — this task's change doesn't require touching the generated page unless the check fails
- `docs/specs/<issue-kebab>/` naming convention is unaffected by this fix — only the gitignore scope and its documentation change

### Tech Stack

- Plain `.gitignore` glob syntax (no tooling)
- Git index operations (`git rm --cached`)
- Markdown docs
- Node ≥ 18 for `adapters/sync.mjs` (zero npm deps)

### Code Style & Standards

- Match existing `.gitignore` comment style (`# … — local only (MVP; …)`)
- Doc wording should mirror the existing tone/phrasing in each file rather than introducing a new convention description style

### Testing Patterns

- `git check-ignore -v <path>` per folder — verifies the new pattern
- `git ls-files docs/specs/` — verifies untrack succeeded and nothing else regressed
- `git status --porcelain docs/specs/` — verifies leaked folders no longer surface as untracked (now ignored) and nothing else is dirty
- `npm run sync:adapters:check` — verifies `CLAUDE.md` regeneration matches the edited `.ai/rules/orchestration/spec-driven-development.md` (no drift)
- `npm run website:changelog:check` — only if `CHANGELOG.md` edit requires the generated page to be re-synced

### Database Patterns

- N/A

### Additional Context

- Evidence gathered in research: `git ls-files docs/specs/` → `cursor-collection-migration/`, `pilot-feedback-framework-deltas/`, `website-changelog-sync/` tracked; `git status --porcelain docs/specs/` → `claude-code-setup/`, `claude-code-setup-website-docs/`, `setup-framework-prefix-unknown-arg/` untracked and unignored
- `docs/specs/dhi-*/` folders do not currently exist on disk — the narrow rule is presently protecting nothing in this working tree

## Implementation Plan

### Phase 1: Broaden `.gitignore`

**Goal**: Every `docs/specs/` subfolder is ignored by git, regardless of naming.

**Description**: Replace the `dhi-*`-only glob with an all-subfolders glob; keep the folder-only trailing slash so `docs/specs/README.md` stays tracked.

**Verification:** `git check-ignore -v docs/specs/claude-code-setup/ docs/specs/claude-code-setup-website-docs/ docs/specs/setup-framework-prefix-unknown-arg/` matches all three; `git check-ignore docs/specs/README.md` exits non-zero (still tracked/not ignored).

#### Task 1.1 - [MODIFY] Widen the ignore glob

**Description**: In `.gitignore`, change `docs/specs/dhi-*/` to `docs/specs/*/`. Update the adjacent comment to drop the DHI-specific framing (e.g. `# Agent specs / research / plan — local only (MVP; DHI-521)` → `# Agent specs / research / plan — local only (MVP)`, since the rule is no longer ticket-prefix-specific).

**Files:** `.gitignore` (modify)

**Definition of Done**:

- [x] `.gitignore` line reads `docs/specs/*/`
- [x] `git check-ignore -v docs/specs/claude-code-setup/ docs/specs/claude-code-setup-website-docs/ docs/specs/setup-framework-prefix-unknown-arg/` shows all three matched by the new line
- [x] `git check-ignore docs/specs/README.md` still exits non-zero (file, not matched by the directory-only glob)

**Stop Rule:** Do not add a `!docs/specs/README.md` negation — it is unnecessary since the glob is directory-only (trailing slash) and README.md is a file.

**Clues**: Existing pattern already uses a trailing slash for directory-only matching; keep that convention.

### Phase 2: Untrack the 3 leaked folders

**Goal**: The 3 already-committed non-DHI spec folders stop appearing in future commits/diffs while their working-tree copies remain on disk.

**Description**: Remove from the git index only (`--cached`), never delete the files. Run Phase 1 first so the paths land in "ignored" state immediately after untracking (not "untracked" clutter in `git status`).

**Verification:** `git ls-files docs/specs/` returns only `docs/specs/README.md`; `ls docs/specs/cursor-collection-migration/ docs/specs/pilot-feedback-framework-deltas/ docs/specs/website-changelog-sync/` still show their files on disk; `git status --porcelain docs/specs/` is empty.

#### Task 2.1 - [MODIFY] `git rm --cached` the 3 folders

**Description**: `git rm -r --cached docs/specs/cursor-collection-migration docs/specs/pilot-feedback-framework-deltas docs/specs/website-changelog-sync`. Do not pass `-f`/`--force` unless git reports the files as unexpectedly modified relative to HEAD (they should be clean, since no content edits are planned for them).

**Files:** `docs/specs/cursor-collection-migration/` (untrack, keep on disk), `docs/specs/pilot-feedback-framework-deltas/` (untrack, keep on disk), `docs/specs/website-changelog-sync/` (untrack, keep on disk)

**Definition of Done**:

- [x] `git ls-files docs/specs/` no longer lists any file under the 3 folders
- [x] All original files still exist unmodified on disk (byte-identical to `HEAD` per code review — `git status --porcelain docs/specs/` currently shows staged `D` entries pre-commit; resolves to empty once committed, since the paths then match the new ignore rule)
- [x] No other path outside `docs/specs/` appears in the same `git rm --cached` diff

**Stop Rule:** If `git rm --cached` reports any file as locally modified in a way not explained by this task, stop and report — do not force-remove uninspected changes.

**Clues**: `git rm --cached` (no `-f`) fails loudly if the working-tree content differs from the index, which is the desired safety check here.

### Phase 3: Update convention docs + changelog

**Goal**: Every doc that states the gitignore rule matches what `.gitignore` now actually does.

**Description**: Reword the `dhi-*`-only claims to the all-subfolders rule in the 4 identified docs, regenerate `CLAUDE.md` from the updated rule source, and record the fix in `CHANGELOG.md`.

**Verification:** `grep -rn "dhi-\*/" docs/specs/README.md docs/plans/README.md docs/architecture/agents-md-standard.md .ai/rules/orchestration/spec-driven-development.md` returns no "is/are gitignored" claim tied to `dhi-*` alone; `npm run sync:adapters:check` exits 0; `npm run website:changelog:check` exits 0 (sync first if needed).

#### Task 3.1 - [MODIFY] `docs/specs/README.md`

**Description**: In "This repository (`agent-collections`)", replace "Folders matching `docs/specs/dhi-*/` are gitignored (local-only MVP)." with wording stating all `docs/specs/*/` subfolders are gitignored regardless of naming/ticket prefix.

**Files:** `docs/specs/README.md` (modify)

**Definition of Done**:

- [x] Sentence no longer implies only `dhi-*` folders are ignored
- [x] Rest of the file (naming convention table, consumer-projects section) untouched

**Stop Rule:** Do not restructure the file beyond this sentence.

#### Task 3.2 - [MODIFY] `.ai/rules/orchestration/spec-driven-development.md` + regenerate `CLAUDE.md`

**Description**: In "This framework repository vs consumers", replace "story folders matching `docs/specs/dhi-*/` are gitignored" with the all-subfolders wording. Then run `npm run sync:adapters` to regenerate root `CLAUDE.md` from the updated rule source.

**Files:** `.ai/rules/orchestration/spec-driven-development.md` (modify), `CLAUDE.md` (regenerated output, do not hand-edit)

**Definition of Done**:

- [x] `.ai/rules/orchestration/spec-driven-development.md` sentence updated
- [x] `npm run sync:adapters` run after the edit; `CLAUDE.md` reflects the new wording
- [x] `npm run sync:adapters:check` exits 0 (no drift)

**Stop Rule:** Never hand-edit `CLAUDE.md` directly — always go through the source rule + sync script.

**Clues**: `adapters/claude/generate.mjs` is the generator invoked by `sync:adapters`.

#### Task 3.3 - [MODIFY] `docs/plans/README.md`

**Description**: Update line 13's "story work under `docs/specs/dhi-*/` is often local-only (gitignored)" to reflect that all `docs/specs/*/` story work is local-only, not just DHI-prefixed folders.

**Files:** `docs/plans/README.md` (modify)

**Definition of Done**:

- [x] Sentence no longer scoped to `dhi-*` only

**Stop Rule:** Do not touch the rest of the docs-triad explanation in this file.

#### Task 3.4 - [MODIFY] `docs/architecture/agents-md-standard.md`

**Description**: Update line 42's "folders such as `docs/specs/dhi-*/` may be gitignored" to state the full `docs/specs/*/` scope.

**Files:** `docs/architecture/agents-md-standard.md` (modify)

**Definition of Done**:

- [x] Sentence no longer scoped to `dhi-*` only

**Stop Rule:** Do not touch unrelated sections of this standards doc.

#### Task 3.5 - [MODIFY] `CHANGELOG.md` Unreleased

**Description**: Add a bullet under `## [Unreleased]` → `### Fixed` describing the gitignore scope fix and the untrack of the 3 leaked folders (no history rewrite). Run `npm run website:changelog:sync` + `:check` only if the generated website page needs to follow.

**Files:** `CHANGELOG.md` (modify), `website/src/pages/changelog.md` (modify only if sync is required)

**Definition of Done**:

- [x] `Unreleased` → `Fixed` has a bullet naming the gitignore scope fix and the 3 untracked folders
- [x] `npm run website:changelog:check` exits 0

**Stop Rule:** Do not edit any historical (dated/tagged) changelog entry — this is an `Unreleased` addition only.

### Phase 4: Code Review

**Goal**: Independent review confirms no content was altered in the untracked folders, no history was rewritten, and doc wording matches the shipped `.gitignore` rule.

**Description**: Final verification of the full change set. This phase is mandatory and always comes last.

**Verification:** `git check-ignore -v docs/specs/*/`-style spot check on all 6 known spec folders; `npm run sync:adapters:check`; `npm run website:changelog:check` if Phase 3.5 touched the generated page.

#### Task 4.1 - [REUSE] Code review by Code Reviewer

**Description**: Run **Code Reviewer** via `eversis-review.md` on `.gitignore`, the 4 doc edits, the regenerated `CLAUDE.md`, and the `CHANGELOG.md` bullet, plus the `git rm --cached` diff for the 3 folders.

**Files:** `.gitignore` (reuse), `docs/specs/README.md` (reuse), `.ai/rules/orchestration/spec-driven-development.md` (reuse), `CLAUDE.md` (reuse), `docs/plans/README.md` (reuse), `docs/architecture/agents-md-standard.md` (reuse), `CHANGELOG.md` (reuse)

**Definition of Done**:

- [x] Code review passes with no blocking findings
- [x] Confirms the 3 untracked folders' working-tree content is byte-identical to before (no accidental edits)
- [x] Confirms no `git log`/history-altering command was run
- [x] Review outcome documented in Changelog below

**Stop Rule:** BLOCKER on any content change inside the 3 untracked folders, any history-rewriting git command, or a hand-edit to `CLAUDE.md`.

## Security Considerations

- `git rm --cached` is index-only; no destructive filesystem operation
- No history rewrite, no force-push — this plan explicitly excludes that path (Q2 locked)
- No secrets or credentials involved

## Quality Assurance

Acceptance criteria checklist to verify the implementation meets the defined requirements:

- [x] `.gitignore` matches all `docs/specs/*/` subfolders; `docs/specs/README.md` remains tracked
- [x] `git ls-files docs/specs/` returns only `docs/specs/README.md`
- [x] Working-tree content of the 3 previously-tracked folders is unchanged on disk (byte-identical to `HEAD`, verified per-file)
- [x] `git status --porcelain docs/specs/` — currently shows staged `D` entries (pre-commit); resolves empty once committed (paths then match the new ignore rule)
- [x] `docs/specs/README.md`, `.ai/rules/orchestration/spec-driven-development.md`, `docs/plans/README.md`, `docs/architecture/agents-md-standard.md` no longer claim a `dhi-*`-only rule
- [x] `CLAUDE.md` regenerated via `npm run sync:adapters`; `npm run sync:adapters:check` exits 0
- [x] `CHANGELOG.md` `Unreleased` → `Fixed` records the fix; `npm run website:changelog:check` exits 0
- [x] No git history rewrite occurred

## Improvements (Out of Scope)

- Fixing the dead `docs/specs/dhi-*/` cross-links in `.ai/README.md`, `.ai/prompts/README.md`, `.ai/skills/README.md`, `docs/context/agent-collections/delivery-index.md` (separate problem: links into gitignored folders)
- A pre-commit hook or CI check that actively blocks commits touching `docs/specs/*/` (belt-and-suspenders beyond the gitignore fix; not requested)
- Purging the 3 folders from git history (explicitly declined — Q2)

## Changelog

| Date       | Change Description |
| ---------- | ------------------- |
| 2026-08-14 | Initial plan: broaden `.gitignore` to `docs/specs/*/`, untrack 3 leaked folders (index-only, no history rewrite), update 4 convention docs + `CHANGELOG.md` Unreleased. |
| 2026-08-14 | Implemented all 4 phases. Code review PASS — no blockers. |

## Code Review Findings

**Date:** 2026-08-14
**Verdict:** PASS
**Summary:** 0 blockers · 0 suggestions

### STRICT FORBIDDEN

- **Scope:** All 9 changed files are within plan scope (`.gitignore`, `docs/specs/README.md`, `.ai/rules/orchestration/spec-driven-development.md`, `docs/plans/README.md`, `docs/architecture/agents-md-standard.md`, `CHANGELOG.md`) plus their expected generated outputs (`CLAUDE.md`, `.cursor/rules/eversis-spec-driven-development.mdc`, `website/src/pages/changelog.md`). The 3 `git rm --cached` folders match exactly the plan's Phase 2 list; no other path touched. `.claude/settings.json` (untracked, pre-existing) was not created or modified by this work.
- **Documentation comments:** None removed — all 4 doc edits are single-sentence wording swaps (`dhi-*` → `*/`), rest of each file untouched.
- **Dependencies:** No new package-manager entries.

### Correctness

- `git check-ignore -v` confirms the new `docs/specs/*/` pattern matches all 3 previously-leaking folders and does not match `docs/specs/README.md`.
- `git rm -r --cached` is index-only: diffed each of the 10 affected files (`git show HEAD:<path>` vs. working-tree copy) — byte-identical. No content was altered.
- No commit was created and no history-rewriting command (`rebase`, `filter-repo`, `reset --hard`, force-push) was run this session — confirmed via `git reflog` (unchanged) and `git status` (no rebase/merge state). Matches the Q2-locked "untrack going forward only" decision.
- `CLAUDE.md` and `.cursor/rules/eversis-spec-driven-development.mdc` were regenerated via `npm run sync:adapters` (never hand-edited) and carry the updated wording; `npm run sync:adapters:check` confirms zero drift.
- `website/src/pages/changelog.md` was regenerated via `npm run website:changelog:sync`; `npm run website:changelog:check` confirms zero drift.
- Doc wording is accurate in all 4 hand-edited files and consistent with the shipped `.gitignore` rule (spot-checked full diffs).

### Security

- No secrets, credentials, or destructive operations involved. `git rm --cached` does not touch the filesystem content.

### Testing

- `git check-ignore -v` (3 folders + README.md) — as expected.
- `git ls-files docs/specs/` — only `README.md`.
- `npm run sync:adapters:check` — exit 0, no drift.
- `npm run website:changelog:check` — exit 0, no drift.

### SUGGESTIONS

None.

No BLOCKERS.
