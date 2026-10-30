# setup-framework-prefix-unknown-arg - Implementation Plan

## Task Details

| Field            | Value |
| ---------------- | ----- |
| Jira ID          | none |
| Title            | Installer submodule skew: `--framework-prefix` unknown argument |
| Description      | Launched installer bash (newer `$AGENT_COLLECTIONS_HOME`) passes `--framework-prefix` into pinned `vendor/agent-collections/adapters/sync.mjs` (older SHA). Fix: product guard in the installer (B) plus EOG gitlink bump (A); prove with `--upgrade --sync`. |
| Priority         | High (blocks Agent Collections upgrade on EOG; not portal/CMS) |
| Related Research | [setup-framework-prefix-unknown-arg.research.md](./setup-framework-prefix-unknown-arg.research.md) |

## Wildly Important Goal

**Goal**: `--upgrade --sync` from a newer Agent Collections clone against an older `vendor/agent-collections` pin either aligns the pin or fails with an actionable skew message — never `unknown argument: --framework-prefix`.

**Success Measure**: From the eog repo, `bash "$AGENT_COLLECTIONS_HOME/scripts/setup-agent-collections.sh" --upgrade --sync --non-interactive` exits 0; a unit test proves dirty/old vendored `sync.mjs` dies with “submodule behind installer” (not `unknown argument`).

**Do NOT touch / do NOT add**:

- Portal, CMS, handbooks, e2e, charts
- Option C (run `sync.mjs` from `SCRIPT_DIR` instead of vendored `COLLECTIONS_HOME`)
- Bumping `frameworkVersion` / SemVer solely to detect skew
- Auto-checkout when the vendor worktree is dirty
- New npm dependencies
- Force-push / history rewrite of either repo

## Proposed Solution

Two repos, one flow. **B first** (guard lives in the bash that is sourced from the launched clone), **A second** (EOG records the pin), **`--upgrade --sync` last** (acceptance).

```text
resolve_collections_home  →  INSTALLER_FRAMEWORK_HOME := COLLECTIONS_HOME
run_vendor_setup          →  COLLECTIONS_HOME := target/vendor/agent-collections
align or die (B)          →  if installer will pass flags vendored sync.mjs lacks:
                               upgrade|sync + submodule + clean → checkout installer HEAD
                               else die (SHAs, flag, git commands)
_run_adapter_sync         →  node ${COLLECTIONS_HOME}/adapters/sync.mjs …   (pin SSOT, not C)
```

**B (agent-collections):** Save the launching framework path before `vendor.sh` overwrites `COLLECTIONS_HOME`. Before `_run_adapter_sync`, probe every extra flag the installer will pass (today: `--framework-prefix` when prefix is non-empty) against vendored `adapters/sync.mjs`. On mismatch with `VENDOR_MODE=submodule` and `--upgrade` or `--sync`, if `git status --porcelain` in the vendor dir is empty, `git checkout` the SHA of `INSTALLER_FRAMEWORK_HOME` and continue; otherwise `die` with a message that names both trees, both SHAs, the rejected flag, and the checkout commands. Copy and local modes stay unchanged (copy already rsyncs from the installer tree; local runs `sync.mjs` from the same tree).

**A (eog):** Set `vendor/agent-collections` gitlink to a SHA that contains `--framework-prefix` (minimum `8cacec3`; target = installer `HEAD` after B is on that SHA). Do not discard unexpected dirty files in the submodule without a stop.

**C:** Out of scope — generated adapters must follow the **pinned** vendor copy after align/bump.

## Current Implementation Analysis

### Already Implemented

- `setup-agent-collections.sh` — `$AGENT_COLLECTIONS_HOME/scripts/setup-agent-collections.sh` — sources `LIB_DIR` from the **launched** script; sequence `run_vendor_setup` then `link_framework_files`
- `setup_vendor_submodule` — `scripts/lib/setup-agent-collections/vendor.sh` — skip add when `.gitmodules` lists the path; always sets `COLLECTIONS_HOME` to `vendor/agent-collections`
- `_run_adapter_sync` / `_resolve_framework_prefix` — `scripts/lib/setup-agent-collections/link-framework.sh` — passes `--framework-prefix` when `COLLECTIONS_HOME != TARGET_DIR`
- `parseArgs` — `adapters/sync.mjs` (HOME `95b3969`) — accepts `--framework-prefix`; pin `c996bb7` does not
- `load_selection_or_fail` — `scripts/lib/setup-agent-collections/upgrade.sh` — restores `vendorMode=submodule` on `--upgrade`
- Lib unit-test pattern — `scripts/lib/setup-agent-collections/gitignore.test.sh` — source lib, `_pass`/`_fail`, temp fixtures
- Installer smoke — `scripts/setup-agent-collections.test.sh` / `npm run installer:smoke`
- Docs upgrade table — `website/docs/getting-started/installation.md` §5 — says update submodule **then** `--upgrade --sync`, but the script does not do the update

### To Be Modified

- `scripts/setup-agent-collections.sh` — export `INSTALLER_FRAMEWORK_HOME` after `resolve_collections_home` / `ensure_framework_checkout`, before `run_vendor_setup`
- `scripts/lib/setup-agent-collections/vendor.sh` or `link-framework.sh` — skew detect + align-or-die immediately before `_run_adapter_sync` (prefer `link-framework.sh` next to `_run_adapter_sync`, or `vendor.sh` after re-point; one owner, not both)
- `website/docs/getting-started/installation.md` — submodule row: `--upgrade --sync` aligns a **clean** pin to the launching SHA; dirty pin fails with commands
- `scripts/README.md` — one-line pointer to the same contract
- `CHANGELOG.md` — Unreleased Fixed entry (SSOT for `npm run website:changelog:sync`)

### To Be Created

- Skew helper(s) in installer lib — flag probe, dirty check, checkout-or-die (names in implementation; no duplicate copies)
- `scripts/lib/setup-agent-collections/vendor-sync-skew.test.sh` — unit tests for probe + die message + skip-when-supported
- EOG gitlink update for `vendor/agent-collections` (consumer pin only)

## Open Questions

| #   | Question | Answer | Status |
| --- | -------- | ------ | ------ |
| 1   | EOG product vs installer? | Installer / pin mismatch, not portal/CMS | ✅ Resolved |
| 2   | A vs B vs C? | **B + A**; verify `--upgrade --sync`; **C** out | ✅ Resolved |
| 3   | Use `frameworkVersion` for skew? | No — both trees are `0.0.1` | ✅ Resolved |
| 4   | Auto-checkout vs fail-only? | Auto-checkout **only** on `--upgrade`/`--sync` + submodule + **clean** worktree; else die with commands | ✅ Resolved |
| 5   | Where to implement B? | Agent Collections clone that is **launched** (`$AGENT_COLLECTIONS_HOME`), not eog product trees | ✅ Resolved |

## Technical Context

### Project Instructions

- This repo: [`.cursor/rules/eversis-project-stack.mdc`](../../../.cursor/rules/eversis-project-stack.mdc) — installer quality commands below; load `eversis-writing-repo-documentation` for CHANGELOG / installation docs; `eversis-creating-skills` is in-policy for this framework repo
- Consumer (EOG) stack: no product-app edits (`portal/`, `cms/`, …); Phase 4/5 only touch the `vendor/agent-collections` gitlink and installer-managed adapter outputs
- Delivery Standard: research approved; this plan must be human-approved before code
- Consumer pin: `eog/.gitmodules` path `vendor/agent-collections` → `https://github.com/PiotrNie-Eversis/agent-collections.git`

### Architecture & Patterns

- Bash installer libs under `scripts/lib/setup-agent-collections/`; `die` / `log_info` / `log_ok` from `common.sh`
- Node adapters are **not** sourced from `LIB_DIR`; `_run_adapter_sync` runs `node "${COLLECTIONS_HOME}/adapters/sync.mjs"`
- `COLLECTIONS_HOME` is overwritten on vendor submodule/copy — any “launcher tree” pointer must be saved **before** `run_vendor_setup`
- Flag probe must be generic (any extra arg `_run_adapter_sync` will append), not a one-off `--framework-prefix` string hardcoded as the only future flag
- Checkout target SHA = `git -C "$INSTALLER_FRAMEWORK_HOME" rev-parse HEAD` (local path the user launched), not an untrusted URL

### Tech Stack

- Bash (`set -euo pipefail`) + Node ≥ 18 for `sync.mjs` (zero npm deps in adapters)
- Git submodule gitlink (`160000`)
- Docs: Markdown + Docusaurus `website/`; changelog SSOT is root `CHANGELOG.md`

### Code Style & Standards

- Match existing installer messages: `[agent-setup]` / `[agent-setup ERROR]` via `log_*` / `die`
- `die` text must include recovery commands (same idea as `_print_partial_fail`)
- Do not `git checkout --force` / `git reset --hard` on a dirty vendor worktree

### Testing Patterns

- Lib unit tests: `bash scripts/lib/setup-agent-collections/<name>.test.sh` from **agent-collections repo root** (`gitignore.test.sh` pattern)
- Installer smoke (heavier, MCP build): `bash scripts/setup-agent-collections.test.sh` or `npm run installer:smoke`
- Changelog drift: `npm run website:changelog:check` after `CHANGELOG.md` edits (sync with `npm run website:changelog:sync` if the generated page is in scope)
- EOG acceptance (from eog root): `bash "$AGENT_COLLECTIONS_HOME/scripts/setup-agent-collections.sh" --upgrade --sync --non-interactive`
- Reproduce old fail (must be gone after A): `node vendor/agent-collections/adapters/sync.mjs --help` mentions `--framework-prefix`

### Database Patterns

- N/A

### Additional Context

- Snapshot 2026-08-13: HOME `95b3969` has the flag; eog pin `c996bb7` does not; HOME is 6 commits ahead; flag since `8cacec3`
- EOG `vendor/agent-collections` may already be **dirty** (uncommitted submodule files). Phase 4 must inspect porcelain before checkout
- `install-selection.json` `vendorMode` is `submodule` — `--upgrade` always re-points `COLLECTIONS_HOME`
- Implement B in `$AGENT_COLLECTIONS_HOME` so the next `--upgrade --sync` invocation sources the new bash even before the pin contains B

## Implementation Plan

### Phase 1: Installer guard (B)

**Goal**: The launched installer never calls a vendored `sync.mjs` with flags that file cannot parse.

**Description**: Persist the launcher framework path, probe extra sync CLI flags against the file that will actually run, then align a clean submodule or die with an actionable message.

**Verification:** From agent-collections repo root: `grep -n INSTALLER_FRAMEWORK_HOME scripts/setup-agent-collections.sh` is non-empty and appears before `run_vendor_setup`; `grep -n INSTALLER_FRAMEWORK_HOME scripts/lib/setup-agent-collections/link-framework.sh` is non-empty.

#### Task 1.1 - [MODIFY] Remember the launching framework home

**Description**: After `resolve_collections_home` and `ensure_framework_checkout`, export `INSTALLER_FRAMEWORK_HOME` as the current `COLLECTIONS_HOME` (absolute). `run_vendor_setup` may then re-point `COLLECTIONS_HOME` to `vendor/agent-collections`.

**Files:** `scripts/setup-agent-collections.sh` (modify)

**Definition of Done**:

- [x] `INSTALLER_FRAMEWORK_HOME` is exported before `run_vendor_setup`
- [x] After a submodule skip-add path, `INSTALLER_FRAMEWORK_HOME` still points at the launched clone, while `COLLECTIONS_HOME` points at `vendor/agent-collections`
- [x] `grep -n INSTALLER_FRAMEWORK_HOME scripts/setup-agent-collections.sh` shows the assignment before `run_vendor_setup`

**Stop Rule:** Do not use `AGENT_COLLECTIONS_HOME` env alone — `--collections-home` and script-root resolution must be captured too.

**Clues**: `resolve_collections_home` in `paths.sh` already prefers CLI, then env, then `SETUP_SCRIPT_DIR/..`.

#### Task 1.2 - [MODIFY] Probe flags, align clean submodule, or die

**Description**: Immediately before `_run_adapter_sync`, if extra args will be passed (non-empty framework prefix → `--framework-prefix`), check that `${COLLECTIONS_HOME}/adapters/sync.mjs` contains each extra flag. On mismatch and `VENDOR_MODE=submodule` and (`ARG_UPGRADE` or `ARG_SYNC`) and empty `git -C "$COLLECTIONS_HOME" status --porcelain`: checkout `git -C "$INSTALLER_FRAMEWORK_HOME" rev-parse HEAD` in the vendor dir (fetch from origin if the SHA is missing). If checkout cannot proceed (dirty, missing SHA, not a git dir): `die` with launched path+SHA, vendored path+SHA, flag name, and the exact `git fetch` / `git checkout` commands. Do not `--force`.

**Files:** `scripts/lib/setup-agent-collections/link-framework.sh` (modify), `scripts/lib/setup-agent-collections/vendor.sh` (reuse — do not duplicate the guard)

**Definition of Done**:

- [x] `_run_adapter_sync` is not reached when vendored `sync.mjs` lacks a flag the installer will pass, unless align succeeded
- [x] Dirty vendor: `die` text contains `submodule` and the flag name and does **not** run `git checkout`
- [x] Clean align path logs that the vendor SHA was updated, then calls existing `_run_adapter_sync`
- [x] Local and `copy` vendor modes do not checkout (copy already refreshes files; local has no pin skew)

**Stop Rule:** If align would need `reset --hard` or wiping uncommitted vendor files, stop at `die` — never add a force path in this task.

**Clues**: Keep executing `${COLLECTIONS_HOME}/adapters/sync.mjs` after align (not `SCRIPT_DIR/../adapters/sync.mjs`). Probe via the file contents or `--help` text of **that** `sync.mjs`, not `frameworkVersion`.

### Phase 2: Unit tests (B)

**Goal**: Skew behaviour is reviewer-verifiable without a full MCP smoke install.

**Description**: Add a lib test in the existing `_pass`/`_fail` style with temp fake `sync.mjs` files (with and without `--framework-prefix`) and a fake dirty vs clean git dir where practical.

**Verification:** `bash scripts/lib/setup-agent-collections/vendor-sync-skew.test.sh` from agent-collections repo root exits 0.

#### Task 2.1 - [CREATE] `vendor-sync-skew.test.sh`

**Description**: Cover: (1) probe false when `sync.mjs` has no `--framework-prefix`; (2) probe true when it does; (3) die-message contract for mismatch (substring `submodule` + flag); (4) no checkout attempted when porcelain is non-empty (assert by using a stub or by checking the function returns before git). Source the same lib files Task 1.2 modified.

**Files:** `scripts/lib/setup-agent-collections/vendor-sync-skew.test.sh` (create), helpers from Task 1.2 (reuse)

**Definition of Done**:

- [x] Test file exists next to `gitignore.test.sh`
- [x] Run `bash scripts/lib/setup-agent-collections/vendor-sync-skew.test.sh` from agent-collections repo root — exit 0
- [x] At least one case fails the script if the die message is only `unknown argument: --framework-prefix`

**Stop Rule:** Do not fold this into `setup-agent-collections.test.sh` (too slow / MCP). Optional smoke extension is Improvements.

**Clues**: `gitignore.test.sh` sets `LIB_DIR`, sources `common.sh`, uses `mktemp` + trap.

### Phase 3: Docs (B)

**Goal**: Upgrade docs match what the script actually does.

**Description**: Replace “human must bump pin, then `--upgrade --sync`” with “`--upgrade --sync` aligns a clean submodule to the launching SHA; dirty or missing SHA fails with commands”. Record the fix in CHANGELOG SSOT.

**Verification:** `grep -n 'clean' website/docs/getting-started/installation.md` shows the submodule align contract; `npm run website:changelog:check` from agent-collections repo root after changelog sync if `CHANGELOG.md` changed.

#### Task 3.1 - [MODIFY] Installation + scripts README

**Description**: Update the “Keeping consumers aligned” submodule row and the upgrade prose so they describe align-or-die. One sentence in `scripts/README.md`.

**Files:** `website/docs/getting-started/installation.md` (modify), `scripts/README.md` (modify)

**Definition of Done**:

- [x] Submodule row no longer implies the script never updates the pin
- [x] Dirty-worktree failure is documented
- [x] Internal links in those files still resolve (paths that already exist)

**Stop Rule:** Do not rewrite unrelated getting-started pages.

**Clues**: Section heading is `## 5. Upgrade` in `installation.md`.

#### Task 3.2 - [MODIFY] CHANGELOG Unreleased

**Description**: Add a **Fixed** bullet under `## [Unreleased]` describing installer submodule skew (`unknown argument` vs align-or-die). If the website page is generated from this file, run changelog sync.

**Files:** `CHANGELOG.md` (modify), `website/src/pages/changelog.md` (modify only if generated by the sync script in this repo)

**Definition of Done**:

- [x] Unreleased Fixed bullet names `--framework-prefix` / submodule skew
- [x] Run `npm run website:changelog:sync` then `npm run website:changelog:check` from agent-collections repo root — exit 0

**Stop Rule:** Do not invent a SemVer tag or bump `package.json` version (`0.0.1` stays).

**Clues**: Root `CHANGELOG.md` is SSOT; `scripts/sync-changelog.mjs` generates the website page.

### Phase 4: EOG pin (A)

**Goal**: EOG’s gitlink points at a framework SHA that understands `--framework-prefix` (and includes B if that SHA already has it).

**Description**: Inspect submodule dirtiness, then move `vendor/agent-collections` to the launching clone’s `HEAD` (or origin SHA equivalent). Stage only the gitlink unless the human asked to commit.

**Verification:** `git -C vendor/agent-collections rev-parse HEAD` equals the intended SHA; `grep -n framework-prefix vendor/agent-collections/adapters/sync.mjs` is non-empty.

#### Task 4.1 - [MODIFY] Bump `vendor/agent-collections` gitlink

**Description**: In eog, `git -C vendor/agent-collections status --porcelain`. If dirty with unexpected files, stop (do not checkout). If clean (or the human confirmed discarding known leftover), fetch/checkout the SHA of `$AGENT_COLLECTIONS_HOME` HEAD. `git add vendor/agent-collections` in eog. Do not commit unless the user asks.

**Files:** `eog` gitlink `vendor/agent-collections` (modify), `eog/.gitmodules` (reuse)

**Definition of Done**:

- [x] `git submodule status vendor/agent-collections` shows a SHA whose `adapters/sync.mjs` contains `--framework-prefix`
- [x] `node vendor/agent-collections/adapters/sync.mjs --help` prints `--framework-prefix`
- [x] eog product paths (`portal/`, `cms/`, …) are untouched

**Stop Rule:** Non-empty unexpected porcelain in the submodule → stop and report the file list; do not `checkout --force`.

**Clues**: Current pin `c996bb7` is an ancestor of HOME `95b3969`; flag commit is `8cacec3`. Prefer HOME `HEAD` after Phases 1–3 so the pin can include B.

### Phase 5: Acceptance `--upgrade --sync`

**Goal**: The original terminal failure is gone on this machine.

**Description**: Re-run the exact command from the bug report against eog. Adapter sync must complete; later installer steps may continue (MCP merge, etc.).

**Verification:** Command below exits 0; log has `Adapter sync complete` (or equivalent `log_ok`) and no `unknown argument: --framework-prefix`.

#### Task 5.1 - [REUSE] Run upgrade sync on eog

**Description**: From eog root, run the documented upgrade command using the HOME installer that contains B.

**Files:** eog `.agent-collections/install-selection.json` (reuse), generated adapter outputs under `.cursor/` / `CLAUDE.md` as the installer already manages (reuse)

**Definition of Done**:

- [x] Run `bash "$AGENT_COLLECTIONS_HOME/scripts/setup-agent-collections.sh" --upgrade --sync --non-interactive` from eog root — exit 0
- [x] Output does not contain `unknown argument: --framework-prefix`
- [x] Output does not contain `adapters/sync.mjs failed`

**Stop Rule:** If the command still dies on a dirty vendor tree with the **new** skew message, that is B working — finish Task 4.1 first, then re-run this task. If it still prints `unknown argument`, B did not run from HOME (wrong script path) — stop.

**Clues**: Selection already has `vendorMode: submodule`; `--upgrade` reloads it.

### Phase 6: Code Review

**Goal**: Independent review confirms B does not force-checkout dirty trees and A did not edit product apps.

**Description**: Final verification of the full implementation. This phase is mandatory and always comes last.

**Verification:** `bash scripts/lib/setup-agent-collections/vendor-sync-skew.test.sh` from agent-collections repo root; `npm run website:changelog:check` if Phase 3.2 changed changelog.

#### Task 6.1 - [REUSE] Code review by Code Reviewer

**Description**: Run **Code Reviewer** via `eversis-review.md` on installer lib + tests + docs + eog gitlink only. Pass e2e execution to that agent — do not run e2e from the plan author level.

**Files:** `scripts/setup-agent-collections.sh` (reuse), `scripts/lib/setup-agent-collections/link-framework.sh` (reuse), `scripts/lib/setup-agent-collections/vendor-sync-skew.test.sh` (reuse), `CHANGELOG.md` (reuse), eog `vendor/agent-collections` gitlink (reuse)

**Definition of Done**:

- [x] Run `bash scripts/lib/setup-agent-collections/vendor-sync-skew.test.sh` from agent-collections repo root
- [x] Code review passes with no blocking findings
- [x] Review outcome documented in Changelog below

**Stop Rule:** BLOCKER on force-checkout, Option C sneaking in, or eog product-file edits.

**Clues**: Risk areas: `COLLECTIONS_HOME` overwrite order; dirty submodule; probing `sync.mjs` from the wrong tree.

## Security Considerations

- Checkout only a SHA from `git rev-parse` of the local `INSTALLER_FRAMEWORK_HOME` the user launched — do not take a SHA from install-selection JSON or remote input without that local resolve
- Never `git reset --hard` / `checkout --force` on consumer vendor trees (data loss)
- Do not log or copy secrets; installer logs are paths and SHAs only
- Submodule URL stays the existing `.gitmodules` origin; do not retarget to an arbitrary remote in this task

## Quality Assurance

Acceptance criteria checklist to verify the implementation meets the defined requirements:

- [x] Reproduced old fail is gone: `--upgrade --sync --non-interactive` from eog using `$AGENT_COLLECTIONS_HOME` installer exits 0
- [x] Vendored `adapters/sync.mjs --help` documents `--framework-prefix`
- [x] Dirty vendor + skew → installer `die` mentions submodule / flag / recovery git commands, not `unknown argument`
- [x] Clean vendor + `--upgrade`/`--sync` + skew → pin moves to installer HEAD, then adapter sync runs
- [x] No eog product application files changed
- [x] `vendor-sync-skew.test.sh` passes
- [x] CHANGELOG Unreleased Fixed records the skew fix; website changelog check passes if sync is required

## Improvements (Out of Scope)

- Option C: run `sync.mjs` from `SCRIPT_DIR/../adapters/` (pin vs live HOME SSOT)
- SemVer / `frameworkVersion` bump as a skew signal
- Full installer smoke case that adds a real git submodule and an old `sync.mjs` fixture
- Auto-stash of dirty vendor files
- Teaching `sync.mjs` to ignore unknown flags (would hide skew instead of aligning the pin)

## Changelog

| Date       | Change Description |
| ---------- | ------------------ |
| 2026-08-13 | Initial plan: B (align-or-die in launched installer) + A (EOG gitlink) + `--upgrade --sync` acceptance; C out of scope. |
| 2026-08-13 | Moved from eog `docs/specs/` into this framework repo; in-repo file paths are now repo-relative. |
| 2026-08-13 | Implemented B (guard + tests + docs) and A (EOG gitlink `c996bb7` → `95b3969`, staged, not committed). `--upgrade --sync` on eog exit 0. |
| 2026-08-13 | Code review PASS — no blockers. Guard lives in `vendor-sync-skew.sh`, called from `link-framework.sh` before `_run_adapter_sync`. Pin `95b3969` has the flag but not uncommitted B (B runs from launched HOME tree). |

## Code Review Findings

**Date:** 2026-08-13  
**Verdict:** PASS  
**Summary:** 0 blockers · 2 suggestions

### STRICT FORBIDDEN

- **Scope:** In-repo edits are installer + docs/changelog + spec artifacts. EOG: gitlink `vendor/agent-collections` only among product-adjacent paths; `portal/` and `cms/` unchanged. `--upgrade --sync` also refreshed installer-managed adapter/MCP/ignore surfaces (in plan Task 5.1).
- **Documentation comments:** None removed.
- **Dependencies:** No new package-manager entries.

### Correctness

Guard probes vendored `sync.mjs --help`, aligns a clean submodule to `git -C INSTALLER_FRAMEWORK_HOME rev-parse HEAD` (fetch if needed), or `die`s with submodule + flag + recovery commands. `_run_adapter_sync` still executes `${COLLECTIONS_HOME}/adapters/sync.mjs` (not Option C). Dirty path unit-tested (HEAD unchanged). Live `--upgrade --sync` on eog: exit 0, `Adapter sync complete`, no `unknown argument`.

### Security

Checkout SHA is only from local `rev-parse` of the launched tree. No `--force` / `reset --hard`. Submodule URL unchanged.

### Testing

`bash scripts/lib/setup-agent-collections/vendor-sync-skew.test.sh` — 8 passed. `npm run website:changelog:check` — OK.

### SUGGESTIONS

- Align still runs after `maybe_build_mcp`, so MCP dist can stay on the old pin unless `--build-mcp` is passed (plan-review W1).
- EOG gitlink is staged at `95b3969` (has `--framework-prefix`) but does not contain uncommitted B. After this framework change is committed, bump the pin again if the vendor copy should carry the guard too.

No BLOCKERS.
