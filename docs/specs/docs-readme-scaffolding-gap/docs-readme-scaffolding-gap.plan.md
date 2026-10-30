# docs-readme-scaffolding-gap - Implementation Plan

## Task Details

| Field            | Value |
| ---------------- | ----- |
| Jira ID          | none |
| Title            | Installer scaffolds `docs/context/` and `docs/plans/` as empty directories — no `README.md`, unlike `docs/specs/` |
| Description      | `scaffold_project()` writes a `README.md` only for `docs/specs/`; `docs/context/` and `docs/plans/` get `mkdir -p` only. Add matching README scaffolds for both, switch all three guards from directory-existence to file-existence so re-running the installer (`--upgrade`/`--sync`) backfills missing READMEs into already-scaffolded projects, add unit test coverage, and dogfood the fix in this repo. |
| Priority         | Medium (documentation/consistency gap; contradicts the framework's own documented install contract) |
| Related Research | [`docs-readme-scaffolding-gap.research.md`](./docs-readme-scaffolding-gap.research.md) |

## Wildly Important Goal

**Goal**: Every project scaffolded (or re-synced) by `setup-agent-collections.sh` has all three docs-triad folders — `docs/context/`, `docs/plans/`, `docs/specs/` — carrying a top-level `README.md`, matching the framework's own documented install contract (`docs/architecture/agents-md-standard.md` AC #3).

**Success Measure**: A fresh install creates `docs/context/README.md` and `docs/plans/README.md` (in addition to the existing `docs/specs/README.md`). Re-running the installer against a project that already has `docs/context/`/`docs/plans/` directories but no README backfills the missing files without touching any other content in those folders or overwriting a README a human already customized. New unit tests in `scaffolding.test.sh` cover both cases. This repo's own `docs/context/README.md` exists.

**Do NOT touch / do NOT add**:

- `docs/context/agent-collections/README.md` or any other **per-subfolder** README (e.g. mirroring `docs/context/eog/README.md`) — Q2 locked the scope to **top-level only**; per-project subfolder READMEs are a separate, later concern (noted in research as a possible follow-up, not part of this fix)
- The content of `docs/plans/README.md` or `docs/specs/README.md` **in this repo** — both already exist (hand-authored, richer than the generic installer scaffold text) and must not be overwritten; the installer's file-existence guard change must not retrigger a write against them
- Running the installer against `/Users/piotrniemirski/Documents/Projects/user-profile` (the originally-reported project) — that is a separate action in a different repo the user runs themselves after this fix ships; out of scope for this plan
- `website/docs/getting-started/installation.md` — documenting `--gitignore-agent-artifacts` in prose is a pre-existing separate gap identified in research; not part of this fix
- New npm dependencies

## Proposed Solution

Four steps:

1. **Fix `scaffold_project()`** in `scripts/lib/setup-agent-collections/scaffolding.sh`: switch all three triad branches (`docs/specs`, `docs/context`, `docs/plans`) to guard on **file existence** (`[[ ! -f "$readme_path" ]]`) instead of directory existence, and add the missing `README.md` heredoc content for `docs/context` and `docs/plans` (generic, project-agnostic text — no framework-repo-specific wording, mirroring the existing `docs/specs` heredoc's style). Since `scaffold_project` already runs unconditionally on every install **and** every `--upgrade`/`--sync` run (confirmed: single call site, `scripts/setup-agent-collections.sh:239`, no conditional), this file-existence guard is sufficient to make backfill automatic — no new "upgrade mode" branch is needed.
2. **Add unit tests** — new `scripts/lib/setup-agent-collections/scaffolding.test.sh`, following the existing sourcing pattern used by `gitignore.test.sh` (source `common.sh` + `scaffolding.sh`, temp `TARGET_DIR`, call the function directly, assert with `_pass`/`_fail`).
3. **Dogfood in this repo** — create `docs/context/README.md` here directly (this repo doesn't have one yet either — confirmed in research), reusing the same generic content plus a short "Framework repository" note (matching the existing pattern in `docs/plans/README.md` / `docs/specs/README.md`) stating this repo does not apply `--gitignore-agent-artifacts` to itself.
4. **`CHANGELOG.md`** — new `Unreleased` → `Fixed` bullet.

## Current Implementation Analysis

### Already Implemented

- `scripts/lib/setup-agent-collections/scaffolding.sh` `scaffold_project()` (lines 4–56) — `docs/specs/` branch (dir + README, dir-existence guard); `docs/context`/`docs/plans` loop (`mkdir -p` only, no README); **needs modification**
- `scripts/setup-agent-collections.sh:239` — calls `scaffold_project` unconditionally on every run including `--upgrade`/`--sync` (confirmed in research); **no change needed**, this is what makes the file-existence-guard fix sufficient for backfill
- `docs/plans/README.md`, `docs/specs/README.md` (this repo) — already exist, hand-authored, richer than installer heredoc; **no change needed**
- `scripts/lib/setup-agent-collections/gitignore.test.sh` — reusable pattern (source `common.sh` + target lib file, temp dir, `_pass`/`_fail`) for the new test file
- `docs/architecture/agents-md-standard.md` — already documents the target end state (Install contract AC #3); **no change needed**, code conforms to the doc, not vice versa

### To Be Modified

- `scripts/lib/setup-agent-collections/scaffolding.sh` — guard fix (3 branches) + new heredoc content (2 branches)
- `CHANGELOG.md` — new `Unreleased` → `Fixed` bullet

### To Be Created

- `scripts/lib/setup-agent-collections/scaffolding.test.sh` — new unit test file
- `docs/context/README.md` (this repo) — new file
- Assertions added to `scripts/setup-agent-collections.test.sh` (existing file, additive)

## Open Questions

| # | Question | Answer | Status |
| --- | --- | --- | --- |
| 1 | Fix scope: installer-only, or also backfill existing installs? | Option C: fix installer **and** make `--upgrade`/`--sync` backfill missing READMEs | ✅ Resolved |
| 2 | README granularity: top-level only, or per-subfolder? | Top-level only (`docs/context/README.md`, `docs/plans/README.md`) | ✅ Resolved |
| 3 | Content source for the new `docs/context/README.md`? | Adapt cursor-collections' `docs/context/README.md` as structural model; rewrite the gitignore-policy section to match agent-collections' actual opt-in (`--gitignore-agent-artifacts`) behavior; neutralize Cursor-only `@`-attach phrasing; drop the dead link to an undocumented installation-doc section | ✅ Resolved |

## Technical Context

### Project Instructions

- Research approved 2026-08-14 (Q1–Q3 locked); this plan requires human approval before broad changes per the Delivery Standard
- This is framework self-improvement work in `agent-collections` itself (installer script + self-hosted docs), not a consumer-project change

### Architecture & Patterns

- "Create if absent, never overwrite" is the established idiom in `scaffold_project()` already (used for `AGENTS.md` and `.claude/CLAUDE.md`, guarded by `[[ ! -f ... ]]`) — the `docs/specs/` branch is the one outlier using a directory-existence guard instead; this fix aligns all three triad branches to the same file-existence idiom already proven correct elsewhere in the same function
- `scaffold_project` has one call site (`scripts/setup-agent-collections.sh:239`) run on every invocation (fresh install, `--upgrade`, `--sync`) — no branching by mode exists or is needed

### Tech Stack

- Bash (`set -euo pipefail` style, matching sibling lib files)
- No new tooling; existing `common.sh` helpers (`log_ok`, `log_info`)

### Code Style & Standards

- Heredoc content style should mirror the existing `docs/specs` heredoc in the same function (plain Markdown, no framework-repo-specific wording — that belongs only in this repo's own committed copy, added by hand in Phase 3, same as `docs/specs/README.md`'s "This repository" section is hand-added beyond the installer's generic heredoc)
- Test file style should mirror `gitignore.test.sh` exactly: `_pass`/`_fail` helpers, temp `TARGET_DIR` with `trap ... EXIT`, minimal env exports before sourcing

### Testing Patterns

- New `scripts/lib/setup-agent-collections/scaffolding.test.sh`, run manually the same way as its siblings (`bash scripts/lib/setup-agent-collections/scaffolding.test.sh`) — none of the existing per-lib test files are wired into `package.json` or CI (verified: `installer:smoke` only runs the top-level `setup-agent-collections.test.sh`); not adding wiring here is consistent with existing practice, not a new gap
- Existing `scripts/setup-agent-collections.test.sh` (`npm run installer:smoke`) — add minimal assertions for the two new README files in the first `TARGET` block

### Database Patterns

- N/A

### Additional Context

- Evidence from research: `docs/context/agent-collections/` (this repo) currently has no README while `docs/context/eog/` does — that inconsistency is a **per-subfolder** gap, explicitly out of scope per Q2 (top-level only); not touched by this plan
- The reported symptom in `/Users/piotrniemirski/Documents/Projects/user-profile` is fixed **for future re-installs** of that project by this change, but this plan does not itself run the installer against that project (separate repo, separate action)

## Implementation Plan

### Phase 1: Fix `scaffold_project()`

**Goal**: All three triad folders get a README on fresh install, and missing READMEs are backfilled on any re-run (`--upgrade`/`--sync`) without touching existing custom content.

**Description**: Refactor the function so each of the three branches (`docs/specs`, `docs/context`, `docs/plans`) follows the same shape: ensure the directory exists (`mkdir -p`, safe to repeat), then guard the README write on **file** existence, then write + `log_ok`.

**Verification:** Run the installer against a fresh temp target — all three READMEs exist. Pre-create `docs/context/` and `docs/plans/` as empty directories (no README) in a second temp target, run the installer again — the missing READMEs appear, and any pre-existing unrelated file in those directories is untouched. Pre-create a custom `docs/context/README.md` with sentinel content, run the installer — content is byte-identical after (not overwritten).

#### Task 1.1 - [MODIFY] Switch `docs/specs` guard to file-existence

**Description**: In `scaffold_project()`, change `if [[ ! -d "$specs_dir" ]]; then mkdir -p "$specs_dir"; cat > "$specs_readme" ...; fi` to: always `mkdir -p "$specs_dir"` (idempotent, no guard needed for the directory itself), then guard only the `cat > "$specs_readme"` write on `if [[ ! -f "$specs_readme" ]]; then ... fi`. Keep the existing heredoc content and the `log_ok "Created docs/specs/ directory."` message (adjust wording to "Created docs/specs/README.md." since the directory may already have existed).

**Files:** `scripts/lib/setup-agent-collections/scaffolding.sh` (modify)

**Definition of Done**:

- [x] `docs/specs/` directory creation no longer gates the README write
- [x] README write is guarded by `[[ ! -f "$specs_readme" ]]`
- [x] Existing heredoc content unchanged (byte-for-byte)
- [x] Re-running against a target where `docs/specs/README.md` already exists does not modify it (verified via checksum before/after in the new test)

**Stop Rule:** Do not change the heredoc's Markdown content in this task — content changes for `docs/context`/`docs/plans` only happen in Task 1.2; this task is guard-logic only.

**Clues**: `docs/plans/README.md` and `docs/specs/README.md` in this repo already exist and must remain untouched by this change — the guard fix is what protects them (file exists → skip write), not any new special-casing.

#### Task 1.2 - [MODIFY] Add `docs/context` and `docs/plans` README scaffolds

**Description**: Replace the bare `for d in docs/context docs/plans; do mkdir -p ...; done` loop with two explicit blocks (mirroring the `docs/specs` shape from Task 1.1): `mkdir -p`, guard on `[[ ! -f "$readme_path" ]]`, write heredoc content, `log_ok`.

`docs/plans/README.md` heredoc content (generic, no framework-repo-specific wording):

```markdown
# plans

Optional location for **flat implementation plans** as `*.md` files (scope, rationale, steps, risks).

Prefer the Implement workflow under `docs/specs/<issue-kebab>/*.plan.md` (with `*.research.md` / `*.plan-review.md`) — see [`docs/specs/README.md`](../specs/README.md).

Use `docs/plans/` only for legacy or ad-hoc flat plans when the team chooses not to use a specs folder.
```

`docs/context/README.md` heredoc content (adapted from cursor-collections per Q3 — generic, gitignore section rewritten to agent-collections' actual opt-in behavior, Cursor `@`-attach phrasing kept as a secondary note):

```markdown
# context

Internal knowledge for this project: architecture notes, ADRs, wiki sync exports, onboarding. Use clear filenames under `docs/context/<project>/`.

**Task baseline (workshop continuity):** `docs/context/<project>/task-baseline.md` — optional epic/story index refreshed after a successful Jira push from prompt `eversis-analyze-materials`.

Referenced by research/plan steps. Attach it by path in your tool (e.g. Cursor `@docs/context/<project>/`).

Part of the project deliverables triad with [`docs/plans/`](../plans/) and [`docs/specs/`](../specs/).

By default this folder is committed like any other project doc. Projects installed with `--gitignore-agent-artifacts` gitignore `docs/context/*/` subfolders instead (local baselines/exports stay off git); only this `README.md` stays tracked in that mode.
```

**Files:** `scripts/lib/setup-agent-collections/scaffolding.sh` (modify)

**Definition of Done**:

- [x] `docs/context/README.md` and `docs/plans/README.md` are written on fresh install
- [x] Both writes are guarded by file existence, not directory existence
- [x] `log_ok` message emitted for each, matching the existing style
- [x] Re-running against a target with pre-existing empty `docs/context/`/`docs/plans/` directories (no README) creates the missing files
- [x] Re-running against a target with a custom `docs/context/README.md` does not overwrite it

**Stop Rule:** Do not add per-subfolder (`docs/context/<project>/README.md`) scaffolding — Q2 locked top-level only. Do not include framework-repo-specific wording ("this monorepo", "agent-collections does not...") in the installer heredoc — that belongs only in this repo's own committed file (Phase 3), not the generic scaffold text shipped to every consumer.

**Clues**: `docs/specs`'s existing heredoc (post Task 1.1) is the shape to match — same indentation/heredoc-quoting style (`<<'README_EOF'` with quoted delimiter to prevent variable expansion).

### Phase 2: Unit test coverage

**Goal**: The guard-fix and backfill behavior are regression-tested, not just manually verified.

**Description**: New `scaffolding.test.sh` following the `gitignore.test.sh` sourcing pattern; minimal additive assertions in the existing smoke test.

**Verification:** `bash scripts/lib/setup-agent-collections/scaffolding.test.sh` exits 0, all cases pass. `npm run installer:smoke` still exits 0.

#### Task 2.1 - [CREATE] `scripts/lib/setup-agent-collections/scaffolding.test.sh`

**Description**: Source `common.sh` + `scaffolding.sh` with a temp `TARGET_DIR` (and `COLLECTIONS_HOME` pointed at repo root, `SELECTED_AGENTS=""` to skip the Claude-specific seed branch). Cases:

1. **Fresh scaffold** — empty `TARGET_DIR`, call `scaffold_project`, assert `docs/context/README.md`, `docs/plans/README.md`, `docs/specs/README.md` all exist and are non-empty.
2. **Backfill on re-run** — pre-`mkdir -p` `docs/context` and `docs/plans` (no README) in a fresh temp dir, call `scaffold_project`, assert the two READMEs now exist.
3. **Never overwrite** — pre-write a sentinel `docs/context/README.md` (e.g. `# custom`) in a fresh temp dir, call `scaffold_project`, assert the file content is unchanged (still `# custom`) after the call.
4. **Idempotent directory creation** — call `scaffold_project` twice in a row on the same `TARGET_DIR`, assert no error and no content change on the second call (covers `docs/specs`'s `mkdir -p` no longer being guarded by the old `[[ ! -d ]]` check).

**Files:** `scripts/lib/setup-agent-collections/scaffolding.test.sh` (create)

**Definition of Done**:

- [x] All 4 cases implemented with `_pass`/`_fail` helpers matching `gitignore.test.sh` style
- [x] Script is executable / runnable via `bash scripts/lib/setup-agent-collections/scaffolding.test.sh`
- [x] All cases pass locally

**Stop Rule:** Do not add npm-script or CI wiring for this file — none of the sibling `*.test.sh` files in this directory are wired in either; adding it only for this new file would be an inconsistent, out-of-scope change.

**Clues**: `gitignore.test.sh:9-27` is the exact sourcing/setup pattern to copy (`LIB_DIR`, `REPO_ROOT`, `_pass`/`_fail`, temp `TARGET_DIR` with `trap ... EXIT`).

#### Task 2.2 - [MODIFY] Add README assertions to the top-level smoke test

**Description**: In `scripts/setup-agent-collections.test.sh`, immediately after the existing `[[ -f "${TARGET}/.agent-collections/area-profile.txt" ]]` check, add:

```bash
[[ -f "${TARGET}/docs/context/README.md" ]] || { echo "FAIL: missing docs/context/README.md"; exit 1; }
[[ -f "${TARGET}/docs/plans/README.md" ]] || { echo "FAIL: missing docs/plans/README.md"; exit 1; }
```

**Files:** `scripts/setup-agent-collections.test.sh` (modify)

**Definition of Done**:

- [x] Two new assertions added in the existing `TARGET` block
- [x] `npm run installer:smoke` passes

**Stop Rule:** Do not duplicate the same assertions into the second (`TARGET_CLAUDE`) block — one coverage point for this behavior is sufficient; that block exists to test Claude-specific adapter output, not scaffolding.

### Phase 3: Dogfood this repo

**Goal**: This repo's own `docs/context/` has a `README.md`, closing the exact gap the user found, in the framework's own tree.

**Description**: Create `docs/context/README.md` directly in this repo (not via running the installer against itself — the repo-root guard in `setup-agent-collections.sh:200-204` explicitly forbids that). Content = the same generic text from Task 1.2, plus a short repo-specific addendum matching the existing pattern in `docs/plans/README.md` / `docs/specs/README.md`.

**Verification:** `docs/context/README.md` exists at repo root context folder; content includes both the generic scaffold text and the repo-specific note; `docs/plans/README.md` and `docs/specs/README.md` are unchanged (diff empty).

#### Task 3.1 - [CREATE] `docs/context/README.md` (this repo)

**Description**: Write the file using Task 1.2's generic content, plus an appended section:

```markdown
## Framework repository (`agent-collections`)

This repo does not apply `--gitignore-agent-artifacts` to itself — `docs/context/*/` subfolders here (e.g. `agent-collections/`, `eog/`) are committed as reference material, unlike a consumer project that opts into the local-only pattern.

**Consumer projects** may commit `docs/context/` by default, or opt in to gitignoring `docs/context/*/` subfolders with `--gitignore-agent-artifacts`.
```

**Files:** `docs/context/README.md` (create)

**Definition of Done**:

- [x] File exists with the generic scaffold content plus the repo-specific addendum
- [x] `docs/plans/README.md`, `docs/specs/README.md` unchanged
- [x] Links (`../plans/`, `../specs/`) resolve correctly from `docs/context/README.md`'s location

**Stop Rule:** Do not create or modify any `docs/context/<project>/README.md` (per-subfolder) — out of scope per Q2.

### Phase 4: Changelog

**Goal**: The fix is recorded in the SSOT changelog.

**Description**: One bullet under `## [Unreleased]` → `### Fixed`.

**Verification:** `npm run website:changelog:check` exits 0 (sync first if needed).

#### Task 4.1 - [MODIFY] `CHANGELOG.md` Unreleased

**Description**: Add a bullet describing the scaffolding gap and the fix (installer now scaffolds + backfills `docs/context/README.md` and `docs/plans/README.md`, matching existing `docs/specs/README.md` behavior).

**Files:** `CHANGELOG.md` (modify), `website/src/pages/changelog.md` (modify only if sync is required)

**Definition of Done**:

- [x] `Unreleased` → `Fixed` has a bullet naming the gap and the fix
- [x] `npm run website:changelog:check` exits 0

**Stop Rule:** Do not edit any historical (dated/tagged) changelog entry.

### Phase 5: Code Review

**Goal**: Independent review confirms the guard-fix doesn't touch existing README content anywhere, the new heredoc content is accurate, and test coverage is real (not vacuous).

**Description**: Final verification of the full change set. Mandatory, always last.

**Verification:** `bash scripts/lib/setup-agent-collections/scaffolding.test.sh`; `npm run installer:smoke`; `npm run website:changelog:check`.

#### Task 5.1 - [REUSE] Code review by Code Reviewer

**Description**: Run **Code Reviewer** via `eversis-review.md` on `scaffolding.sh`, the new `scaffolding.test.sh`, the smoke-test additions, the new `docs/context/README.md`, and the `CHANGELOG.md` bullet.

**Files:** `scripts/lib/setup-agent-collections/scaffolding.sh` (reuse), `scripts/lib/setup-agent-collections/scaffolding.test.sh` (reuse), `scripts/setup-agent-collections.test.sh` (reuse), `docs/context/README.md` (reuse), `CHANGELOG.md` (reuse)

**Definition of Done**:

- [x] Code review passes with no blocking findings
- [x] Confirms no pre-existing README (`docs/plans/README.md`, `docs/specs/README.md` in this repo, or any consumer project's customized README) can be overwritten by the guard fix
- [x] Confirms new heredoc content has no framework-repo-specific wording leaking into the generic installer scaffold
- [x] Review outcome documented in Changelog below

**Stop Rule:** BLOCKER on any change that could overwrite an existing project-owned README, or on per-subfolder README scaffolding (out of Q2 scope).

## Security Considerations

- Pure filesystem writes (heredoc `README.md` content), no secrets, no network, no destructive operations
- File-existence guard is strictly more conservative than the current directory-existence guard for `docs/specs` (fewer cases where a write is skipped that shouldn't be), and identically safe for the new `docs/context`/`docs/plans` branches

## Quality Assurance

Acceptance criteria checklist to verify the implementation meets the defined requirements:

- [x] Fresh install creates `docs/context/README.md`, `docs/plans/README.md`, `docs/specs/README.md`
- [x] Re-run against a target with existing README-less `docs/context`/`docs/plans` directories backfills the missing files
- [x] Re-run against a target with a custom `docs/context/README.md` does not overwrite it
- [x] `docs/plans/README.md` and `docs/specs/README.md` in this repo are unchanged
- [x] `docs/context/README.md` exists in this repo
- [x] `bash scripts/lib/setup-agent-collections/scaffolding.test.sh` passes
- [x] `npm run installer:smoke` passes
- [x] `npm run website:changelog:check` exits 0
- [x] No per-subfolder README scaffolding was added (Q2 scope)

## Improvements (Out of Scope)

- Per-subfolder READMEs (e.g. `docs/context/agent-collections/README.md` to match `docs/context/eog/README.md`) — Q2 locked top-level only
- Documenting `--gitignore-agent-artifacts` in `website/docs/getting-started/installation.md` — pre-existing separate doc gap identified in research, not required for this fix
- Running the installer against `/Users/piotrniemirski/Documents/Projects/user-profile` to apply the backfill there — separate repo, separate action for the user to take after this ships

## Changelog

| Date       | Change Description |
| ---------- | ------------------- |
| 2026-08-14 | Initial plan: fix `scaffold_project()` guard logic (file-existence, all 3 triad branches) + add `docs/context`/`docs/plans` README heredocs, unit test coverage, dogfood this repo's own `docs/context/README.md`, `CHANGELOG.md` entry. |
| 2026-08-14 | Implemented all 5 phases. Code review PASS — no blockers. |

## Code Review Findings

**Date:** 2026-08-14
**Verdict:** PASS
**Summary:** 0 blockers · 0 suggestions

### STRICT FORBIDDEN

- **Scope:** All 6 changed/created files match the plan exactly — `scripts/lib/setup-agent-collections/scaffolding.sh`, `CHANGELOG.md`, `scripts/setup-agent-collections.test.sh` (modified); `scripts/lib/setup-agent-collections/scaffolding.test.sh`, `docs/context/README.md` (created); `website/src/pages/changelog.md` (regenerated output, via `npm run website:changelog:sync`, not hand-edited). No per-subfolder README was added (Q2 scope respected). No file under `/Users/piotrniemirski/Documents/Projects/user-profile` was touched.
- **Documentation comments:** None removed — this task only adds new README content and a new guard-logic shape; no existing doc content was deleted or shortened. `docs/plans/README.md` and `docs/specs/README.md` (both pre-existing, hand-authored) are byte-unchanged (confirmed: `git status` shows no modification to either).
- **Dependencies:** No new package-manager entries.

### Correctness

- `scaffold_project()`'s three triad branches now share one shape: `mkdir -p` (unconditional, idempotent) → `[[ ! -f "$readme" ]]` guard → heredoc write → `log_ok`. Verified via `scaffolding.test.sh`: fresh install creates all 3 READMEs; pre-existing README-less directories get backfilled; a pre-existing custom `docs/context/README.md` is left byte-identical after a second run; calling `scaffold_project` twice produces identical checksums (idempotent).
- Confirmed `scaffold_project` has a single call site (`scripts/setup-agent-collections.sh:239`) run unconditionally on every invocation including `--upgrade`/`--sync` — the file-existence guard change is sufficient to satisfy Q1 (Option C, backfill via upgrade) with no new branching logic.
- New heredoc content for `docs/context`/`docs/plans` is generic (no "this monorepo" framework-repo-specific wording), matching the existing `docs/specs` heredoc's style — confirmed by re-reading both new blocks in the diff.
- This repo's own `docs/context/README.md` was added directly (not via the installer, which refuses to run against its own source checkout per `setup-agent-collections.sh:200-204`) — content matches the generic scaffold text plus the planned "Framework repository" addendum.

### Security

- Pure filesystem writes (heredoc `README.md` content via `mkdir -p` + `cat >`), no secrets, no network calls, no destructive operations. The guard-logic change is strictly more conservative than before (file-existence is a narrower "already done" condition than directory-existence), so no scenario exists where the new code overwrites a file the old code would have preserved.

### Testing

- `bash scripts/lib/setup-agent-collections/scaffolding.test.sh` — 4/4 pass (fresh scaffold, backfill, never-overwrite, idempotent), exit 0.
- `npm run installer:smoke` — full end-to-end install (including the 2 new assertions in `setup-agent-collections.test.sh`) — `[smoke] PASS`, exit 0.
- `npm run website:changelog:check` — exit 0, no drift after `website:changelog:sync`.
- One typo caught and fixed during review: a stray lowercase sentence-start ("...one. this repo's own...") in the `CHANGELOG.md` bullet — corrected to "This repo's own...", website changelog re-synced.

### SUGGESTIONS

None.

No BLOCKERS.
