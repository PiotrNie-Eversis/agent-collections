# Vendor-mode local changes disruption - Implementation Plan

## Task Details

| Field            | Value                   |
| ---------------- | ----------------------- |
| Jira ID          | n/a (ad-hoc; no ticket) |
| Title            | Ship vendor home-marker hygiene without disrupting vendor-mode runtime |
| Description      | Finish the uncommitted installer change so `--vendor submodule\|copy` (and `--upgrade --sync` of those installs) never writes or leaves `.agent-collections/framework-home.txt`, keep local mode writing the gitignored pointer, wire the new unit test into the installer quality command, add a local-mode smoke assertion, and generate the docs-site changelog from root SSOT. |
| Priority         | Hygiene fix (vendor default install) |
| Related Research | [vendor-mode-local-changes-disruption.research.md](./vendor-mode-local-changes-disruption.research.md) |

## Wildly Important Goal

**Goal**: Vendor-mode install and `--upgrade --sync` never persist a machine-absolute `.agent-collections/framework-home.txt`, while local mode still writes that gitignored pointer and vendor MCP/adapter/skills resolution stays unchanged.

**Success Measure**: `bash scripts/lib/setup-agent-collections/framework-home.test.sh` and `bash scripts/setup-agent-collections.test.sh` both pass; smoke proves local install writes the marker and `--vendor=copy` does not; `npm run website:changelog:check` passes after changelog sync.

**Do NOT touch / do NOT add**:
- MCP merge, `docker-compose.yml`, adapter `--framework-prefix`, `vendor.sh` `COLLECTIONS_HOME` reassignment, submodule skew alignment
- Persisting `vendorMode` on a non-upgrade re-run without `--vendor` (pre-existing session isolation; see Improvements)
- A generic runner for every `scripts/lib/setup-agent-collections/*.test.sh`
- New package-manager dependencies, adapter generators, MCP package, or `docs/architecture/` schema changes
- Rewriting `gitignore.sh` vendor strip of the local ignore block

## Proposed Solution

Research concluded the working-tree helper is a hygiene fix, not a runtime break: nothing reads `framework-home.txt`. Keep `_write_or_clear_framework_home` as the single write/clear site. Vendor (`VENDOR_MODE` `submodule` or `copy`) deletes the marker; any other mode writes `COLLECTIONS_HOME`. Do not invent a second home-resolution path.

Close the two ship gaps from research without expanding installer session semantics:

1. **Quality command coverage** — invoke the new unit file from `scripts/setup-agent-collections.test.sh` (same command as `npm run installer:smoke` / stack policy). Add a **local-mode positive** assertion on the first smoke target (file exists and contains `COLLECTIONS_HOME`). Keep the existing vendor-copy **negative** assertion. Do not assert marker absence after the deselect-Claude re-run: that invocation omits `--vendor` and `--upgrade`, so it is the documented pre-existing local demotion path.
2. **Changelog SSOT** — keep the Unreleased Fixed bullet in root `CHANGELOG.md` only; regenerate `website/src/pages/changelog.md` with `npm run website:changelog:sync` so the site page is not a second hand-edited source.

```text
link_framework_files (unchanged order)
  → align_vendor_sync_cli_or_die
  → adapter sync / prune / stack seed / Claude skills
  → _write_or_clear_framework_home
        VENDOR_MODE in {submodule, copy} → rm -f framework-home.txt
        else → write COLLECTIONS_HOME (local; gitignored)

MCP / --framework-prefix / vendor/agent-collections  →  not this helper
```

## Current Implementation Analysis

### Already Implemented

- `_write_or_clear_framework_home` - `scripts/lib/setup-agent-collections/link-framework.sh` - vendor skip + leftover `rm -f`; local write of `COLLECTIONS_HOME`
- `link_framework_files` call site - same file - already calls the helper after Claude skills
- Vendor-copy negative assertion - `scripts/setup-agent-collections.test.sh` - fails if marker exists after `--vendor=copy` Claude install (before deselect re-run)
- Unit cases (local write, copy leftover delete, submodule leftover delete) - `scripts/lib/setup-agent-collections/framework-home.test.sh` - passes when run directly; not invoked by smoke yet
- Unreleased changelog bullet - `CHANGELOG.md` - wording matches the intended contract
- `_resolve_framework_prefix`, `_run_adapter_sync`, `run_vendor_setup`, `merge_mcp_json`, `load_selection_or_fail`, `manage_gitignore` - installer lib - vendor home SSOT; must be reused, not redesigned

### To Be Modified

- `scripts/setup-agent-collections.test.sh` - invoke `framework-home.test.sh` before (or as the first step of) smoke; assert the **local** first target wrote `framework-home.txt`
- `website/src/pages/changelog.md` - stop treating it as a hand-edit; regenerate from root CHANGELOG via `scripts/sync-changelog.mjs`

### To Be Created

- None. Do not add a new npm script or a shared unit-test harness in this task.

## Open Questions

| #   | Question   | Answer   | Status                |
| --- | ---------- | -------- | --------------------- |
| 1   | Does vendor runtime read `framework-home.txt`? | No. Vendor home is `COLLECTIONS_HOME` after `vendor.sh`; MCP uses relative compose under `vendor/agent-collections`. | ✅ Resolved |
| 2   | Include non-upgrade re-run `vendorMode` persistence? | No. Pre-existing; record under Improvements. This plan only ships the helper + tests + changelog SSOT. | ✅ Resolved |
| 3   | How to run the new unit test in the quality bar? | Call `bash scripts/lib/setup-agent-collections/framework-home.test.sh` from `scripts/setup-agent-collections.test.sh` (the stack-policy installer command). Do not add `installer:unit`. | ✅ Resolved |
| 4   | Assert marker absence after deselect-Claude re-run? | No. That re-run has no `--vendor`/`--upgrade`; asserting absence would encode a contract the installer does not keep today. | ✅ Resolved |

## Technical Context

Project conventions, coding standards, and patterns discovered during planning. Downstream agents MUST read this section instead of re-discovering the same context.

### Project Instructions

- `.cursor/rules/eversis-project-stack.mdc` — installer quality command is `bash scripts/setup-agent-collections.test.sh` (`npm run installer:smoke`); changelog: edit root `CHANGELOG.md`, then `npm run website:changelog:sync` / `website:changelog:check`; no new package-manager dependencies without agreement
- `AGENTS.md` — installer lives under `scripts/`; vendor SSOT is `vendor/agent-collections` when vendored
- `.ai/skills/eversis-writing-repo-documentation/SKILL.md` — `website/src/pages/changelog.md` is generated; do not hand-maintain it as SSOT
- Hard limits (agent-core / implement): do not edit files outside this plan; do not silently shorten comments

### Architecture & Patterns

- Installer is Bash libs sourced by `scripts/setup-agent-collections.sh`; globals `TARGET_DIR`, `COLLECTIONS_HOME`, `VENDOR_MODE`
- `VENDOR_MODE` empty or `local` means local (framework outside the consumer). Upgrade maps JSON `vendorMode === 'local'` to empty string (`upgrade.sh`)
- Vendor gitignore **removes** the local block that would ignore `framework-home.txt` — that is why vendor must not write the file
- Sibling lib tests (`gitignore.test.sh`, `vendor-sync-skew.test.sh`) are standalone; this task wires **only** `framework-home.test.sh` into smoke, not a new convention for all lib tests

### Tech Stack

- Installer: Bash (`set -euo pipefail`), Node ≥ 18 only where existing scripts already call it
- Docs site changelog: `node scripts/sync-changelog.mjs`
- No new npm packages

### Code Style & Standards

- Lib headers: `# lib/setup-agent-collections/<name>.sh — …`
- Logging via `common.sh` (`log_info` / `log_ok` / `log_warn` / `die`); this helper currently does not log (keep it quiet unless a warn is already used nearby)
- `rm -f` only the marker file name; do not `rm -rf` `.agent-collections/` (selection JSON lives there)
- Vendor checks: `[[ "${VENDOR_MODE:-}" == "submodule" ]] || [[ "${VENDOR_MODE:-}" == "copy" ]]` — match `link-framework.sh` / `gitignore.sh` / `mcp-merge.sh`, do not treat `local` as vendor

### Testing Patterns

- Unit: `bash scripts/lib/setup-agent-collections/framework-home.test.sh` — sources `common.sh` + `link-framework.sh`, temp `TARGET_DIR`, `_pass` / `_fail`
- Smoke: `bash scripts/setup-agent-collections.test.sh` — also `npm run installer:smoke`
- Changelog: `npm run website:changelog:check`
- Do not run `npm run mcp:test`, `website:build`, or adapter sync unless a later review asks; this task does not touch those trees
- Smoke first target is **local** (no `--vendor`); Claude target is `--vendor=copy`. Deselect re-run later on the Claude target is **not** vendor-mode for `VENDOR_MODE`.

### Database Patterns

- Not applicable (no database).

### Additional Context

- Research verdict: shipping the helper does not disrupt vendor MCP/adapters/skills
- If a consumer committed `framework-home.txt`, next `--upgrade --sync` with this installer deletes it from the worktree (intended)
- `docs/specs/*/` is gitignored in this framework repo; plan/research stay local-only

## Implementation Plan

### Phase 1: Keep the vendor/local home-marker contract

**Goal**: Confirm the single write/clear helper is the shipped behaviour and that vendor runtime paths stay untouched.

**Description**: The working tree already extracts `_write_or_clear_framework_home`. Implementer verifies it matches the contract (vendor delete, local write) and does not expand into MCP, prefix, or `vendor.sh`. No redesign.

**Verification:** `bash scripts/lib/setup-agent-collections/framework-home.test.sh`

#### Task 1.1 - [REUSE] Confirm `_write_or_clear_framework_home` contract

**Description**: Keep the helper in `link-framework.sh` as the only writer/clearer of `framework-home.txt`. Edit only if the file no longer matches: vendor `submodule`/`copy` → `rm -f` marker and return; otherwise write `COLLECTIONS_HOME`. Do not add logging that prints machine paths into install logs unless already present.

**Files:** `scripts/lib/setup-agent-collections/link-framework.sh` (reuse; modify only if contract drifted)

**Definition of Done**:

- [x] `link_framework_files` calls `_write_or_clear_framework_home` after `_link_claude_skills` and does not write the marker inline
- [x] Vendor branch uses `VENDOR_MODE` `submodule` or `copy` only (same predicate as `gitignore.sh` / `mcp-merge.sh`)
- [x] Local branch writes exactly one line: `COLLECTIONS_HOME`
- [x] Run `bash scripts/lib/setup-agent-collections/framework-home.test.sh`

**Stop Rule:** If a change to MCP compose paths, `--framework-prefix`, or `vendor.sh` appears necessary, stop and update this plan — that is out of scope.

**Clues**: HEAD used to always `echo "${COLLECTIONS_HOME}"` after skills. Comment on HEAD said “relative pointer” but the value was always absolute; do not restore a relative write. Function may be defined after `link_framework_files` (Bash allows that once the file is fully sourced).

### Phase 2: Installer quality coverage

**Goal**: The stack-policy installer command proves local write, vendor non-write, and leftover delete — not only an unwired unit file.

**Description**: Invoke the unit test from smoke. Add a local-mode positive assertion on the first consumer target. Leave the existing vendor-copy negative assertion where it is (after `--vendor=copy`, before deselect).

**Verification:** `bash scripts/lib/setup-agent-collections/framework-home.test.sh` then `bash scripts/setup-agent-collections.test.sh`

#### Task 2.1 - [MODIFY] Invoke home-marker unit tests from smoke

**Description**: At the start of `scripts/setup-agent-collections.test.sh` (after `ROOT` is set, before the first consumer install), run `bash "${ROOT}/scripts/lib/setup-agent-collections/framework-home.test.sh"` so `npm run installer:smoke` cannot pass if leftover-delete regressions.

**Files:** `scripts/setup-agent-collections.test.sh` (modify), `scripts/lib/setup-agent-collections/framework-home.test.sh` (reuse)

**Definition of Done**:

- [x] Smoke script contains an explicit invocation of `scripts/lib/setup-agent-collections/framework-home.test.sh`
- [x] Failure of the unit file fails smoke (`set -euo pipefail` or explicit `|| exit 1`)
- [x] Run `bash scripts/lib/setup-agent-collections/framework-home.test.sh`

**Stop Rule:** Do not add a new `package.json` script or a loop over all `*.test.sh` in `lib/`.

**Clues**: Unit file uses `mktemp` and a trap; it does not need smoke’s `TARGET`. Keep it independent.

#### Task 2.2 - [MODIFY] Assert local smoke target writes the marker

**Description**: After the first (local, no `--vendor`) install succeeds and selection JSON is checked, assert `${TARGET}/.agent-collections/framework-home.txt` exists and contains the framework home used for that run (`--collections-home "$ROOT"`, resolved absolute). Do not add a post-deselect absence assertion on `TARGET_CLAUDE`.

**Files:** `scripts/setup-agent-collections.test.sh` (modify)

**Definition of Done**:

- [x] Local `TARGET` assertion: marker file exists after the first install
- [x] Existing vendor-copy assertion remains: `TARGET_CLAUDE` must not have the marker after `--vendor=copy`
- [x] Run `bash scripts/setup-agent-collections.test.sh`

**Stop Rule:** If the local assertion fails because `ROOT` vs `COLLECTIONS_HOME` path form differs (symlink vs `pwd`), compare with `cd "$ROOT" && pwd` rather than loosening to “file exists with any content”.

**Clues**: First install flags are `--collections-home "$ROOT"` without `--vendor`. Claude install already has the negative check around the “Next steps” greps.

### Phase 3: Changelog SSOT

**Goal**: Document the fix once in root CHANGELOG; site page is generated.

**Description**: Keep the Unreleased Fixed bullet on vendor install home marker in `CHANGELOG.md`. Regenerate the Docusaurus page; do not keep a parallel hand-edit.

**Verification:** `npm run website:changelog:check`

#### Task 3.1 - [MODIFY] Sync website changelog from root SSOT

**Description**: Confirm `CHANGELOG.md` Unreleased Fixed still describes: vendor submodule/copy does not write `framework-home.txt`; leftovers deleted; local still writes the gitignored pointer. Run changelog sync so `website/src/pages/changelog.md` matches the generator.

**Files:** `CHANGELOG.md` (reuse; modify only if wording is wrong), `website/src/pages/changelog.md` (modify via generator)

**Definition of Done**:

- [x] Root `CHANGELOG.md` contains the vendor install home marker Fixed bullet under Unreleased
- [x] `website/src/pages/changelog.md` is produced by `npm run website:changelog:sync` (not an independent wording fork)
- [x] Run `npm run website:changelog:check`

**Stop Rule:** Do not edit `website/docs/**` or rewrite older changelog history.

**Clues**: Skill `eversis-writing-repo-documentation` — SSOT is root CHANGELOG; `scripts/sync-changelog.mjs` rewrites the site page.

### Phase 4: Code Review

**Goal**: Independent review confirms vendor runtime is untouched and tests match the contract.

**Description**: Final verification of the full implementation. This phase is mandatory and always comes last.

**Verification:** `bash scripts/lib/setup-agent-collections/framework-home.test.sh` ; `bash scripts/setup-agent-collections.test.sh` ; `npm run website:changelog:check`

#### Task 4.1 - [REUSE] Code review by Code Reviewer

**Description**: Run **Code Reviewer** via `eversis-review.md` to review the complete implementation. Pass e2e test execution to that agent — do not run e2e tests outside this review. There is no product e2e suite for the installer; use the installer smoke command as the behavioural suite.

**Files:** `scripts/lib/setup-agent-collections/link-framework.sh` (reuse), `scripts/lib/setup-agent-collections/framework-home.test.sh` (reuse), `scripts/setup-agent-collections.test.sh` (reuse), `CHANGELOG.md` (reuse), `website/src/pages/changelog.md` (reuse)

**Definition of Done**:

- [x] Run `bash scripts/lib/setup-agent-collections/framework-home.test.sh`
- [x] Run `bash scripts/setup-agent-collections.test.sh`
- [x] Run `npm run website:changelog:check`
- [x] Code review passes with no blocking findings
- [x] Review outcome documented in Changelog

**Stop Rule:** BLOCKER if vendor MCP relative compose, `--framework-prefix`, or `COLLECTIONS_HOME` reassignment in `vendor.sh` was changed without plan update.

**Clues**: Review against research Q1–Q4. Confirm smoke still does not claim vendorMode survives the deselect re-run.

## Security Considerations

- Do not persist machine-absolute filesystem paths in vendor consumer trees (those trees often commit `.agent-collections/` metadata). That is the point of this change.
- `rm -f` only `.agent-collections/framework-home.txt`; never delete `install-selection.json` or the directory.
- Do not log `COLLECTIONS_HOME` in new installer output as part of this task (reduces accidental copy-paste of host paths into tickets).
- Do not add `git checkout --force` / `reset --hard` (existing submodule-skew rule).

## Quality Assurance

Acceptance criteria checklist to verify the implementation meets the defined requirements:

- [x] `--vendor submodule` and `--vendor copy` (and `--upgrade --sync` of those) do not create `.agent-collections/framework-home.txt`; leftovers from older installers are removed
- [x] Local install (no `--vendor`) still writes gitignored `framework-home.txt` with `COLLECTIONS_HOME`
- [x] MCP compose paths, adapter `--framework-prefix`, and `vendor/agent-collections` home reassignment are unchanged
- [x] `bash scripts/lib/setup-agent-collections/framework-home.test.sh` is invoked from `scripts/setup-agent-collections.test.sh` and both pass
- [x] Smoke asserts local marker present and vendor-copy marker absent (pre-deselect)
- [x] `npm run website:changelog:check` passes; site changelog is generated from root `CHANGELOG.md`

## Improvements (Out of Scope)

- Persist `vendorMode` from `install-selection.json` on a full installer re-run that is not `--upgrade`/`--sync` and does not pass `--vendor` (deselect-Claude smoke path currently demotes vendor → local and would rewrite the marker)
- Wire `gitignore.test.sh` and `vendor-sync-skew.test.sh` into smoke or add `installer:unit`
- Document `framework-home.txt` in `docs/architecture/install-selection.md` (file is intentionally not in the selection schema)
- Consumer migration note if a team committed the marker (upgrade deletes it; optional README one-liner)

## Human gates

Numbered list of every human-approval gate this task passes through, in order. Strike through a gate once closed, and quote the user's literal closing phrase — do not paraphrase — as evidence:

1. ~~Approve research~~ — done (`I approve the research make the plan`)
2. ~~Approve this plan~~ — done (`OK IMPLEMENT`)
3. ~~Implement → Review → Fine~~ — done (`OK IMPLEMENT` → review PASS)

## Code Review Findings

**Verdict:** PASS (independent reviewer; zero BLOCKER)

**BLOCKER:** none

**SUGGESTION** (not implemented; do not block Fine):

1. Optional unit case: empty tree + vendor mode must not create the marker (leftover-delete cases already fail a write-instead-of-rm bug).
2. Align smoke negative check with unit tests (`! -e` vs `-f`) for a non-regular leftover named `framework-home.txt`.
3. No smoke for `--vendor=submodule` or vendor `--upgrade --sync` — same helper; acceptable for this plan.

STRICT FORBIDDEN: in-scope files only; comments expanded not shortened; no new package-manager dependencies. MCP / `vendor.sh` / `--framework-prefix` untouched.

## Changelog

| Date       | Change Description   |
| ---------- | -------------------- |
| 2026-08-31 | Initial plan created |
| 2026-08-31 | Implemented: smoke invokes unit tests; local marker assertion; changelog SSOT sync |
| 2026-08-31 | Code review PASS (independent); Fine |
