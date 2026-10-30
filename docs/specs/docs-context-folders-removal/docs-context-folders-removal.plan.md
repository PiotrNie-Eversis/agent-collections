# docs-context-folders-removal - Implementation Plan

## Task Details

| Field            | Value                   |
| ---------------- | ----------------------- |
| Jira ID          | none (repo governance / documentation audit) |
| Title            | Untrack `docs/context/agent-collections/` and `docs/context/eog/` (D1: local-only, no history rewrite) |
| Description      | Stop publishing these two project-context subfolders going forward, keeping their content on local disk, and fix the live doc references that currently cite them by path. |
| Priority         | Low — governance/hygiene, not a bug or blocker |
| Related Research | [`docs-context-folders-removal.research.md`](./docs-context-folders-removal.research.md) |

## Wildly Important Goal

**Goal**: `docs/context/agent-collections/` and `docs/context/eog/` are removed from git tracking (index + future commits) while their file contents remain intact on local disk, and every doc that currently cites these paths by URL/path no longer points at a broken or misleading location.

**Success Measure**: `git ls-files docs/context/` returns only `docs/context/README.md`; `git status` shows the 6 files as untracked (not deleted) with their content unchanged on disk; no remaining live reference (outside `CHANGELOG.md` history and this spec folder) links to `docs/context/agent-collections/*` or `docs/context/eog/*` as if it were part of the public tree.

**Do NOT touch / do NOT add**: Do not rewrite git history (D2, out of scope per research DELTA — explicitly deferred). Do not delete file contents — this is untrack-only, files stay on disk. Do not touch the unrelated pre-existing uncommitted change in `README.md` (submodule vendor-mode label wording) already present in the working tree before this task started. Do not touch `website/docs/isolation.md:45` (already hedged with "when present", degrades gracefully, no change needed).

## Proposed Solution

Reuse the repo's own existing `--gitignore-agent-artifacts` mechanism (`scripts/lib/setup-agent-collections/gitignore.sh` → `_artifact_gitignore_lines()`, which already emits `docs/context/*/`) by applying that same pattern directly in this repo's own root `.gitignore`, then untrack the currently-committed files with `git rm --cached` (index-only removal — working-tree files are untouched). This mirrors the precedent already set in this repo for `docs/specs/*/` (see `CHANGELOG.md` "Unreleased → Fixed → `docs/specs/` gitignore scope": broadened the ignore pattern and "untracked three already-committed leaked folders... going forward — kept on disk, not purged from history"). No new mechanism is introduced.

Two documents make live claims that assume `docs/context/eog/` is part of the public tracked tree (a canonical architecture doc and a published docs-site page); both get reworded to state the finding/measurement inline instead of pointing at a path that will no longer resolve on GitHub. `docs/context/README.md` itself documents this repo's *opt-out* of the local-only pattern — that statement flips to describe the new posture.

## Current Implementation Analysis

### Already Implemented

- `_artifact_gitignore_lines()` — `scripts/lib/setup-agent-collections/gitignore.sh:16-21` — emits `docs/specs/*/` and `docs/context/*/`; already the canonical ignore pattern for "agent artifacts," just not applied to this repo's own `.gitignore` today.
- `docs/specs/*/` root-level ignore precedent — `.gitignore:7-8` — identical mechanism already live in this repo for the sibling `docs/specs/` triad member; the `CHANGELOG.md` entry documenting that change is the direct template for this task's own changelog entry.

### To Be Modified

- `.gitignore` (root) — add `docs/context/*/` block (mirrors existing `docs/specs/*/` block).
- `docs/context/agent-collections/{delivery-index.md,task-baseline.md}` and `docs/context/eog/{README.md,pilot-evidence.md,upgrade-runbook.md,findings-backlog.md}` — untrack via `git rm --cached`; **no content changes**.
- `docs/context/README.md` — flip the "this repo does not apply `--gitignore-agent-artifacts` to itself" statement (lines 11, 15, 17) to describe the new posture.
- `docs/architecture/isolation-strategy.md:128` — reword the `docs/context/eog/` citation so the sentence stands on its own without depending on a path that's no longer in the tracked tree.
- `website/docs/getting-started/migration-from-cursor-collections.md:94,96` — remove/replace the GitHub blob link to `docs/context/eog/README.md` and adjust the pointer prose; keep the already-inline measurement numbers (they don't depend on the link).
- `CHANGELOG.md` — add an `[Unreleased] → Fixed` entry following the exact style of the existing `docs/specs/` gitignore-scope entry.

### To Be Created

None — this task creates no new files (only the already-created research/plan pair in this spec folder).

## Open Questions

| #   | Question   | Answer   | Status                |
| --- | ---------- | -------- | --------------------- |
| 1   | D1 (untrack only) vs D2 (rewrite history) vs hybrid? | D1 only — confirmed by user via `AskUserQuestion` this session | ✅ Resolved |
| 2   | Should `.gitignore` use the exact wildcard `docs/context/*/` (covers future subfolders too) or list the two current folder names explicitly? | Use the wildcard — it's the literal pattern the installer already ships (`_artifact_gitignore_lines()`), matches the `docs/specs/*/` precedent one line above it in the same file, and needs no future edit if another project subfolder is added later | ✅ Resolved |
| 3   | Commit these changes, or leave as working-tree changes for human review? | Leave uncommitted — global instruction: only commit when the user explicitly asks | ✅ Resolved |

## Technical Context

### Project Instructions

- `.ai/rules/orchestration/agent-core.md` — Hard limits: no edits outside task scope without approval, no dependency additions. This task adds no dependencies and its file list above is the full scope.
- Git Safety Protocol (global): never `git add -A`/`-u`; stage files by explicit path; never force-push or rewrite history without explicit user request (D2 is explicitly out of scope here).

### Architecture & Patterns

- `docs/context/`, `docs/specs/`, `docs/plans/` form the "docs triad" (`docs/architecture/agents-md-standard.md`). `docs/specs/*/` is already local-only in this repo; this task brings `docs/context/*/` in line with the same posture, `docs/plans/` is unaffected (out of scope, not mentioned in the research).
- `docs/context/README.md` is the one file in the triad's context leg that must always stay tracked (per the existing installer/scaffolding pattern — only the README survives `--gitignore-agent-artifacts`).

### Tech Stack

- Plain Markdown + a single `.gitignore` edit + `git rm --cached`. No build/lint/test tooling runs against `docs/**` content directly, but the shell test suite under `scripts/lib/setup-agent-collections/*.test.sh` asserts on `.gitignore` *pattern* behavior in scaffolded consumer projects (not on this repo's own root `.gitignore` — confirmed no test reads this repo's root `.gitignore` file directly).

### Code Style & Standards

- Follow existing Markdown table/prose conventions already present in each edited file (no new formatting conventions introduced).

### Testing Patterns

- No automated test covers this repo's own root `.gitignore` or `docs/context/` tracking state. Verification is manual: `git ls-files docs/context/`, `git status`, and confirming untracked files still exist on disk with unchanged content (`git diff` against the pre-removal blob, or a byte comparison, is not needed since `git rm --cached` never touches the working tree).
- Optionally run the existing suite to confirm no regression: `bash scripts/lib/setup-agent-collections/gitignore.test.sh` and `bash scripts/lib/setup-agent-collections/scaffolding.test.sh` (both operate on temp scaffolded dirs, unaffected by this repo's own `.gitignore`, but cheap to run as a sanity check since they exercise the same `_artifact_gitignore_lines()` function this task relies on).

### Database Patterns

N/A.

### Additional Context

- Precedent entry to mirror for the `CHANGELOG.md` addition: `CHANGELOG.md` "Unreleased → Fixed → `docs/specs/` gitignore scope" (broadened pattern + "untracked three already-committed leaked folders... going forward — kept on disk, not purged from history").
- `website/src/pages/changelog.md` is a **generated mirror** of `CHANGELOG.md` (`scripts/sync-changelog.mjs`) — do not hand-edit it; regenerate or leave for the sync script/CI, per existing repo convention. Not a task in this plan (no build step is being run here); flagged so the implementer doesn't hand-edit the generated file by mistake.

## Implementation Plan

### Phase 1: Untrack the two folders

**Goal**: Stop future commits from including these files while preserving their content on disk.

**Description**: Extend `.gitignore` with the same artifact pattern the installer already ships for consumer projects, then remove the 6 files from git's index only.

**Verification:** `git ls-files docs/context/` → only `README.md`; `ls docs/context/agent-collections/ docs/context/eog/` → files still present on disk; `git status` shows them as untracked, not deleted.

#### Task 1.1 - [MODIFY] Add `docs/context/*/` to root `.gitignore`

**Description**: Add a block mirroring the existing `docs/specs/*/` entry (`.gitignore:7-8`), e.g. under its own comment header, ignoring `docs/context/*/` so `README.md` at that level stays tracked but any subfolder (current or future) does not.

**Files:** `.gitignore` (modify)

**Definition of Done**:

- [ ] `.gitignore` contains a `docs/context/*/` pattern, placed near the existing `docs/specs/*/` entry with a matching comment style
- [ ] `git check-ignore -v docs/context/agent-collections/delivery-index.md docs/context/eog/README.md` confirms both paths now match the new rule
- [ ] `docs/context/README.md` itself is **not** matched by the new pattern (still trackable)

**Stop Rule:** none.

#### Task 1.2 - [MODIFY] Untrack the 6 files with `git rm --cached`

**Description**: Run `git rm --cached` (explicit file list, not `-r` on a path that could sweep in unrelated files) for the two `agent-collections/` files and four `eog/` files, so they leave the git index but remain on disk.

**Files:** `docs/context/agent-collections/delivery-index.md` (untrack), `docs/context/agent-collections/task-baseline.md` (untrack), `docs/context/eog/README.md` (untrack), `docs/context/eog/pilot-evidence.md` (untrack), `docs/context/eog/upgrade-runbook.md` (untrack), `docs/context/eog/findings-backlog.md` (untrack)

**Definition of Done**:

- [ ] `git ls-files docs/context/` returns only `docs/context/README.md`
- [ ] All 6 files still exist on disk with unchanged content (`git status` shows them as untracked additions, not as deleted)

**Stop Rule:** If `git rm --cached` reports any file as already having working-tree modifications that would be discarded, stop and confirm with the user before proceeding (it should not, since this is an index-only operation, but verify before running).

### Phase 2: Fix live references

**Goal**: No published doc implies these paths are still part of the public, browsable repo tree.

**Description**: Three docs currently cite these folders as if they're live GitHub paths; reword each so the underlying claim (measurement, rationale, folder purpose) stands without depending on a path that 404s after Phase 1.

**Verification:** Manual read-through of each edited file's surrounding paragraph for sense; `grep -n "docs/context/eog\|docs/context/agent-collections" docs/architecture/isolation-strategy.md website/docs/getting-started/migration-from-cursor-collections.md docs/context/README.md` to confirm the edits landed where expected.

#### Task 2.1 - [MODIFY] Reword `docs/architecture/isolation-strategy.md:128` citation

**Description**: The sentence currently reads "...Use a consumer ignore overlay for genuine infra trees (see `docs/context/eog/` pilot notes)." Reword so it doesn't cite a path no longer in the tracked tree — e.g. state the empirical basis inline (EOG pilot found `charts/**` and handbook trees are product apps, not infra sidecars) rather than pointing readers at a folder they can't open in a fresh clone.

**Files:** `docs/architecture/isolation-strategy.md` (modify)

**Definition of Done**:

- [ ] Line 128's parenthetical no longer implies `docs/context/eog/` is browsable in the tracked repo
- [ ] The sentence still reads coherently and preserves the underlying rationale for the `charts/**` exclusion decision

**Stop Rule:** none.

#### Task 2.2 - [MODIFY] Fix migration guide's `docs/context/eog/` link + prose

**Description**: `website/docs/getting-started/migration-from-cursor-collections.md:94` has a live GitHub blob link `https://github.com/.../docs/context/eog/README.md`; line 96 says "Pilot measurement templates and residual out-of-repo steps: see `docs/context/eog/` in this repository." Remove or replace the dead link (the already-inline "above 30%" measurement numbers on the same line don't depend on it), and reword line 96 to not promise a browsable in-repo path (e.g. note the pilot evidence is kept locally by the EOG team, not published in this repo).

**Files:** `website/docs/getting-started/migration-from-cursor-collections.md` (modify)

**Definition of Done**:

- [ ] No remaining `github.com/.../docs/context/eog/...` hyperlink in this file
- [ ] Line 96's prose no longer claims the folder is visible "in this repository"
- [ ] The measurement numbers and pilot narrative already stated inline remain intact

**Stop Rule:** none.

#### Task 2.3 - [MODIFY] Flip `docs/context/README.md`'s self-description

**Description**: Lines 11/15/17 currently state this repo "does not apply `--gitignore-agent-artifacts` to itself" and that `agent-collections/` is "committed as reference material." Update to describe the new posture: this repo's `docs/context/*/` subfolders are now local-only, same as a consumer project using `--gitignore-agent-artifacts`, while `docs/context/README.md` itself stays tracked.

**Files:** `docs/context/README.md` (modify)

**Definition of Done**:

- [ ] No remaining claim that this repo keeps `docs/context/*/` subfolders committed as reference material
- [ ] Text accurately reflects Phase 1's outcome (untracked, kept locally)

**Stop Rule:** none.

### Phase 3: Record the change

**Goal**: The change is discoverable the same way every other notable repo change is (via `CHANGELOG.md`), matching the existing `docs/specs/` gitignore-scope precedent.

**Description**: Add one `[Unreleased] → Fixed` bullet documenting the untrack, styled like the existing `docs/specs/` entry immediately above it.

**Verification:** `grep -n "docs/context" CHANGELOG.md` shows the new entry.

#### Task 3.1 - [MODIFY] Add `CHANGELOG.md` entry

**Description**: Add a bullet under `## [Unreleased]` → `### Fixed`, next to the existing `docs/specs/` gitignore-scope entry, describing: `docs/context/agent-collections/` and `docs/context/eog/` untracked (kept on disk, not purged from history — D1, no history rewrite); `.gitignore` broadened with `docs/context/*/`; `isolation-strategy.md` and the migration guide references reworded.

**Files:** `CHANGELOG.md` (modify)

**Definition of Done**:

- [ ] New bullet present under `[Unreleased] → Fixed`, in the same style/voice as neighboring entries
- [ ] Bullet mentions both folder names and that content is kept locally (not purged from history)

**Stop Rule:** none. Do **not** hand-edit `website/src/pages/changelog.md` (generated mirror) — out of scope for this task.

### Phase 4: Code Review

**Goal**: Independent check that Phases 1–3 match this plan and the research's D1 recommendation before declaring the task Fine.

**Description**: Final verification of the full change set. Mandatory, always last.

**Verification:** Re-run `git ls-files docs/context/` and the grep checks from Phases 1–2.

#### Task 4.1 - [REUSE] Code review

**Description**: Review the complete diff (`.gitignore`, `docs/context/README.md`, `docs/architecture/isolation-strategy.md`, `website/docs/getting-started/migration-from-cursor-collections.md`, `CHANGELOG.md`, plus the 6 untracked-but-present files) against this plan and the research's D1 scope. Confirm no D2 (history-rewrite) action was taken and no file outside the listed scope was touched.

**Files:** all files listed in Phases 1–3 (reuse)

**Definition of Done**:

- [ ] Diff matches plan scope exactly — no extra files touched (in particular, the pre-existing unrelated uncommitted `README.md` change is untouched)
- [ ] No git history rewrite occurred
- [ ] Review outcome documented in this plan's Changelog

**Stop Rule:** If review finds any file outside plan scope was modified, stop and revert that specific change before declaring Fine.

## Security Considerations

- None specific to this change — it reduces public exposure of internal delivery/pilot notes going forward (aligned with the user's open-source-audience motivation), with the explicit caveat (documented in research) that already-pushed git history is unaffected by this plan (D1 only).

## Quality Assurance

- [ ] `git ls-files docs/context/` returns only `README.md`
- [ ] All 6 previously-tracked files still exist on disk, byte-identical to before
- [ ] No live doc (outside `CHANGELOG.md` and this spec folder) links to `docs/context/agent-collections/*` or `docs/context/eog/*` as a browsable repo path
- [ ] `CHANGELOG.md` documents the change
- [ ] Pre-existing unrelated `README.md` working-tree change is untouched
- [ ] No git history rewrite performed

## Improvements (Out of Scope)

- D2 (git history rewrite to fully erase past commits containing these files) — explicitly deferred per research DELTA; would need a separate explicit confirmation given the force-push/fork-breaking risk on a public repo.
- `website/docs/isolation.md:45` — already hedged ("when present"), no change needed.
- Revisiting whether `docs/context/agent-collections/delivery-index.md`'s traceability content should eventually be folded into `CHANGELOG.md` as a more durable home — noted in the research's "Question 3" preconditions table, not required for D1.

## Changelog

| Date   | Change Description   |
| ------ | --------------------- |
| 2026-08-14 | Initial plan created from `docs-context-folders-removal.research.md` DELTA (D1 confirmed by user via AskUserQuestion) |
| 2026-08-14 | Implemented all 4 phases. `.gitignore` broadened; 6 files untracked (`git rm --cached`, confirmed present on disk); `isolation-strategy.md`, migration guide, and `docs/context/README.md` reworded; `CHANGELOG.md` entry added. `gitignore.test.sh` hit a pre-existing, unrelated failure (`_ensure_artifacts_subblock: command not found` — function doesn't exist in `gitignore.sh`; confirmed via `git diff`/`git log` that neither file was touched this session or in this task's scope) — not fixed, out of plan scope. `scaffolding.test.sh` passed 4/4. Final diff review: exactly the 6 planned modify-files + 6 untracked files touched; pre-existing unrelated `README.md` change (EOG→TASK vendor label) untouched; no history rewrite (`git log` unchanged). Review: PASS. |
