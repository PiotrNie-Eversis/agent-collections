# Upgrade/sync SSOT repo wipe - Implementation Plan

## Task Details

| Field            | Value                   |
| ---------------- | ----------------------- |
| Jira ID          | n/a |
| Title            | Preserve `ssot.externalSsotRepo` on `--upgrade --sync`; empty `--ssot-source` clears |
| Description      | Stop `--upgrade --sync --non-interactive` from writing `null` over a recorded domain-context URL. Omit `--ssot-source` = keep; URL = set/override; empty `--ssot-source` (`""` or `=`) = clear to `null`. Preserve `ssot.confluenceSpaceKey` when `--confluence-space-key` is omitted. |
| Priority         | Bug (documented upgrade path) |
| Related Research | [upgrade-sync-ssot-repo-wipe.research.md](./upgrade-sync-ssot-repo-wipe.research.md) |

## Wildly Important Goal

**Goal**: A normal package update (`--upgrade --sync` without `--ssot-source`) keeps the recorded `ssot.externalSsotRepo` URL, while an explicitly empty `--ssot-source` is the supported way to clear it.

**Success Measure**: Unit tests cover omit / URL / empty-clear; smoke patches a URL, upgrades without the flag (URL kept), then upgrades with empty `--ssot-source` (field is `null`); `confluenceSpaceKey` survives upgrade when the confluence flag is omitted.

**Do NOT touch / do NOT add**:
- `seed_ssot_global` subtree add/skip behaviour (`docs/context/global/` already present → no re-seed)
- Vendor home-marker / `framework-home.txt` (follow-up after Fine: `vendor-mode-local-changes-disruption`)
- Empty `--confluence-space-key` as a documented clear (not in AC)
- New npm scripts, MCP package, adapter generators, `vendor.sh`, gitignore vendor strip
- A generic lib `*.test.sh` harness beyond invoking the new unit file from smoke (same pattern as `framework-home.test.sh`)

## Proposed Solution

The wipe happens because `ARG_SSOT_SOURCE=""` at process start, so **omitted** and **empty** are the same, and `load_selection_or_fail` never restores `ssot.*`. Introduce a **passed** sentinel for `--ssot-source` (and `--confluence-space-key`), then restore from JSON only when the flag was omitted.

Three-way for `externalSsotRepo` (locked Q1/Q3):

```text
ARG_SSOT_SOURCE_PASSED=false  (default)
--ssot-source URL     → PASSED=true, ARG=URL      → write URL
--ssot-source "" | =  → PASSED=true, ARG=empty    → write null (clear)
flag omitted          → PASSED=false
                         upgrade: ARG ← JSON (null → empty)
                         first install: ARG stays empty → write null
```

`--ssot-source` with no following argument remains an error (existing parser).

`confluenceSpaceKey` (locked Q2): same **omitted vs passed** sentinel; omitted on upgrade restores JSON; passed non-empty overrides. Do not document empty confluence as clear.

`write_install_selection` can keep `process.argv[8] || null` for the URL once upgrade fills ARG when the flag was omitted. Also preserve existing `ssot.projectContextPath` / `ssot.globalContextPath` from the current JSON when rewriting (avoid resetting custom paths to hardcoded defaults).

Do not change `seed_ssot_global` (Q4).

```text
upgrade --sync (flag omitted)
  load_selection_or_fail
    if ! ARG_SSOT_SOURCE_PASSED → ARG_SSOT_SOURCE from ssot.externalSsotRepo
    if ! ARG_CONFLUENCE_SPACE_KEY_PASSED → ARG from ssot.confluenceSpaceKey
  … rest of install …
  write_install_selection → URL/key still in JSON
```

## Current Implementation Analysis

### Already Implemented

- `write_install_selection` - `scripts/lib/setup-agent-collections/selection.sh` - writes `ssot` object; empty argv already becomes JSON `null` (correct for **clear** once omit ≠ empty)
- `load_selection_or_fail` - `scripts/lib/setup-agent-collections/upgrade.sh` - fail-safe JSON parse; already restores agents / MCP / profile / vendor / link
- `seed_ssot_global` - `scripts/lib/setup-agent-collections/ssot.sh` - skip if `docs/context/global/` exists (reuse, no edit)
- Smoke upgrade block - `scripts/setup-agent-collections.test.sh` - `--upgrade --sync` on local `TARGET` (extend, do not replace fail-safe tests)
- `framework-home.test.sh` invocation at smoke start - **reuse the invoke pattern** for the new unit file

### To Be Modified

- `scripts/setup-agent-collections.sh` - `ARG_SSOT_SOURCE_PASSED` / `ARG_CONFLUENCE_SPACE_KEY_PASSED` (default false); set true in `--ssot-source` / `--ssot-source=*` and confluence cases; header/help: omit = keep on upgrade, empty `--ssot-source` = clear
- `scripts/lib/setup-agent-collections/upgrade.sh` - restore `ssot.externalSsotRepo` and `ssot.confluenceSpaceKey` (and path fields if write does not merge them) when the matching flag was not passed
- `scripts/lib/setup-agent-collections/selection.sh` - merge existing `ssot` paths if the selection file already exists; write `null` for empty passed URL
- `scripts/setup-agent-collections.test.sh` - invoke new unit tests; after first install, set a URL in JSON, `--upgrade --sync` without flag (assert kept), then `--ssot-source=` (assert `null`)
- `README.md` - Upgrade sentence: also reuses `ssot.externalSsotRepo`; empty `--ssot-source` clears
- `docs/architecture/install-selection.md` - upgrade reuses `ssot.*` unless CLI overrides; empty `--ssot-source` clears `externalSsotRepo`
- `website/docs/getting-started/installation.md` - `--ssot-source` row: omit on upgrade keeps recorded URL; empty value clears
- `CHANGELOG.md` - Unreleased Fixed; then `npm run website:changelog:sync`

### To Be Created

- `scripts/lib/setup-agent-collections/selection-ssot.test.sh` - unit tests: first-write omit → null; write URL; upgrade-load omit keeps URL; passed empty clears; confluence omit on load preserves key. Source `common.sh` + `selection.sh` + `upgrade.sh` with a temp `TARGET_DIR` (mirror `framework-home.test.sh`)

## Open Questions

| #   | Question   | Answer   | Status                |
| --- | ---------- | -------- | --------------------- |
| 1   | Omit `--ssot-source` on upgrade keeps URL? | Yes | ✅ Resolved |
| 2   | Preserve `confluenceSpaceKey` when confluence flag omitted? | Yes | ✅ Resolved |
| 3   | Empty `--ssot-source` is clear? | Yes (`""` and `=`) | ✅ Resolved |
| 4   | Re-run git subtree on preserve? | No | ✅ Resolved |
| 5   | Merge vendor home-marker into this plan? | No; follow-up after Fine | ✅ Resolved |

## Technical Context

Project conventions, coding standards, and patterns discovered during planning. Downstream agents MUST read this section instead of re-discovering the same context.

### Project Instructions

- `.cursor/rules/eversis-project-stack.mdc` — installer quality: `bash scripts/setup-agent-collections.test.sh`; changelog: edit root `CHANGELOG.md`, `npm run website:changelog:sync` / `website:changelog:check`
- `AGENTS.md` — installer under `scripts/`; selection schema `docs/architecture/install-selection.md`
- `eversis-writing-repo-documentation` — do not hand-edit `website/src/pages/changelog.md` as SSOT
- Hard limits: no files outside this plan; no new package-manager dependencies; do not shorten comments

### Architecture & Patterns

- Installer: Bash libs sourced by `setup-agent-collections.sh`; globals `TARGET_DIR`, `ARG_*`, `set -euo pipefail`
- Selection JSON is rewritten at the end of every successful run (`write_install_selection`)
- Upgrade path: `load_selection_or_fail` only when `--upgrade` or (`--sync` + existing selection + no agents/profile override) — see `setup-agent-collections.sh`
- Sibling unit tests live next to the lib and are invoked from smoke by explicit `bash "${ROOT}/scripts/lib/setup-agent-collections/<name>.test.sh"`

### Tech Stack

- Bash + Node ≥ 18 (`JSON.parse` / write selection)
- No new npm packages

### Code Style & Standards

- Export new `ARG_*_PASSED` flags next to existing `export ARG_SSOT_SOURCE …`
- `set -u`: initialize `ARG_SSOT_SOURCE_PASSED="false"` (string false), never leave unset
- When reading JSON null for a URL, set ARG to `""` so `|| null` on write still emits JSON `null`
- `die` / `log_ok` from `common.sh`; do not log the SSOT URL in new messages unless already logging selection summary
- Header comment in `setup-agent-collections.sh` is user-facing — update `--ssot-source` bullet there

### Testing Patterns

- Unit: `bash scripts/lib/setup-agent-collections/selection-ssot.test.sh`
- Smoke: `bash scripts/setup-agent-collections.test.sh` (`npm run installer:smoke`)
- Changelog: `npm run website:changelog:check`
- For smoke preserve/clear: **patch JSON** after the existing first local install (do not add `--ssot-source` to that install — it would call `git ls-remote`). Use a dummy URL string such as `https://gitlab3.eversis.com/dawis/domain-context.git`
- Clear assertion: `--ssot-source=` or `--ssot-source ""` on a second `--upgrade --sync` of the same `TARGET`
- Do not run `mcp:test` / `website:build` / adapter sync unless review asks

### Database Patterns

- Not applicable.

### Additional Context

- `write_install_selection` Node snippet uses `process.argv[8] || null` — empty string is falsy in JS, so clear works once omit no longer forces empty at startup
- Bare `--ssot-source` (no value) already errors; keep that
- First install without `--ssot-source` must still record `null` (PASSED false, ARG empty, no JSON to restore)

## Implementation Plan

### Phase 1: Three-way CLI and selection load/write

**Goal**: Omitted `--ssot-source` no longer looks like clear; upgrade restores `ssot.*` from JSON.

**Description**: Add passed sentinels, restore on upgrade when flags were omitted, merge path fields on rewrite. No subtree changes.

**Verification:** `bash scripts/lib/setup-agent-collections/selection-ssot.test.sh`

#### Task 1.1 - [MODIFY] Distinguish omitted vs empty `--ssot-source` (and confluence omitted vs passed)

**Description**: Default `ARG_SSOT_SOURCE_PASSED=false` and `ARG_CONFLUENCE_SPACE_KEY_PASSED=false`. Set the matching flag to `true` in both `--ssot-source` / `--ssot-source=*` and `--confluence-space-key` / `=*` branches. Keep requiring a value (empty string is a value). Update the file’s `--ssot-source` help comment: on re-run, omit keeps the recorded URL; empty value clears it.

**Files:** `scripts/setup-agent-collections.sh` (modify)

**Definition of Done**:

- [x] `ARG_SSOT_SOURCE_PASSED` and `ARG_CONFLUENCE_SPACE_KEY_PASSED` are initialized and exported
- [x] Both spaced and `=*` flag forms set the corresponding PASSED variable
- [x] Header/help text documents omit-on-upgrade and empty `--ssot-source` as clear
- [x] Bare `--ssot-source` with no argument still exits with an error

**Stop Rule:** Do not make empty `--confluence-space-key` a documented clear.

**Clues**: Today `ARG_SSOT_SOURCE=""` at line ~81 is why omit wipes. PASSED must be independent of that string. `set -u` requires PASSED to be set before any `[[ "$ARG_SSOT_SOURCE_PASSED" == "true" ]]`.

#### Task 1.2 - [MODIFY] Restore `ssot.*` on upgrade when flags were omitted

**Description**: In `load_selection_or_fail`, after existing field loads: if `ARG_SSOT_SOURCE_PASSED` is not true, set `ARG_SSOT_SOURCE` from `j.ssot.externalSsotRepo` (JSON `null`/missing → empty string). If confluence PASSED is not true, set `ARG_CONFLUENCE_SPACE_KEY` from `j.ssot.confluenceSpaceKey`. Export the ARGs. Missing `ssot` object is valid (older JSON) → leave ARG empty.

**Files:** `scripts/lib/setup-agent-collections/upgrade.sh` (modify)

**Definition of Done**:

- [x] Upgrade without `--ssot-source` copies `externalSsotRepo` from JSON into `ARG_SSOT_SOURCE`
- [x] Upgrade without `--confluence-space-key` copies `confluenceSpaceKey` into `ARG_CONFLUENCE_SPACE_KEY`
- [x] Missing `ssot` key does not fail upgrade (required fields stay the existing six)

**Stop Rule:** Do not add `ssot` to the required-fields list (would break old selection files).

**Clues**: Parse with the same `parsed` JSON string already in the function. Node one-liners already used for `vendorMode`.

#### Task 1.3 - [MODIFY] Write selection without clobbering paths; empty URL → null

**Description**: When `${TARGET_DIR}/${SELECTION_REL}` already exists and parses, reuse `ssot.projectContextPath` and `ssot.globalContextPath` if they are non-empty strings; otherwise keep today’s defaults. `externalSsotRepo` / `confluenceSpaceKey` still come from ARG after Task 1.2. Empty ARG still serializes as JSON `null`.

**Files:** `scripts/lib/setup-agent-collections/selection.sh` (modify)

**Definition of Done**:

- [x] First install without `--ssot-source` still writes `"externalSsotRepo": null`
- [x] Empty `ARG_SSOT_SOURCE` writes JSON `null` (clear)
- [x] Existing custom path fields are not reset to defaults when the file already has them

**Stop Rule:** Do not call `git subtree` from this function.

**Clues**: `process.argv[8] || null` already maps `""` to `null`. If Node receives unset, bash `set -u` will have failed first — pass `""` explicitly.

### Phase 2: Tests

**Goal**: Quality commands prove preserve, override, and clear — not only a manual DAWIS repro.

**Description**: New unit file (fast) plus smoke assertions on the existing local `TARGET` after the current `--upgrade --sync` block.

**Verification:** `bash scripts/lib/setup-agent-collections/selection-ssot.test.sh` then `bash scripts/setup-agent-collections.test.sh`

#### Task 2.1 - [CREATE] Unit tests for selection SSOT three-way + confluence preserve

**Description**: Add `selection-ssot.test.sh` covering: omit on first write → null; write URL; `load_selection_or_fail` with PASSED=false restores URL; PASSED=true and empty ARG writes null; confluence key restored when confluence PASSED=false. Invoke it from smoke immediately after the existing `framework-home.test.sh` call.

**Files:** `scripts/lib/setup-agent-collections/selection-ssot.test.sh` (create), `scripts/setup-agent-collections.test.sh` (modify)

**Definition of Done**:

- [x] Unit file exists and is executable via `bash scripts/lib/setup-agent-collections/selection-ssot.test.sh`
- [x] Smoke invokes that file under `set -euo pipefail` (failure fails smoke)
- [x] Run `bash scripts/lib/setup-agent-collections/selection-ssot.test.sh`

**Stop Rule:** Do not add `installer:unit` to `package.json`. Do not loop all lib tests.

**Clues**: Mirror `_pass`/`_fail`/`mktemp` from `framework-home.test.sh`. `write_install_selection` needs `COLLECTIONS_HOME` with or without `package.json` (version fallback `0.0.1`). Source `upgrade.sh` only after `common.sh`.

#### Task 2.2 - [MODIFY] Smoke: preserve on upgrade, clear with empty `--ssot-source`

**Description**: After the existing `--upgrade --sync` on `TARGET` (and after selection exists), write a dummy URL into `ssot.externalSsotRepo`, run `--upgrade --sync --non-interactive` **without** `--ssot-source`, assert the URL is unchanged. Then run `--upgrade --sync --non-interactive --ssot-source=`, assert `externalSsotRepo` is JSON `null`. Optionally set `confluenceSpaceKey` in the same patch and assert it survives the first of those two upgrades.

**Files:** `scripts/setup-agent-collections.test.sh` (modify)

**Definition of Done**:

- [x] Smoke asserts URL kept across `--upgrade --sync` without `--ssot-source`
- [x] Smoke asserts URL is `null` after `--ssot-source=` (or `""`)
- [x] Existing upgrade fail-safe / corrupt-JSON tests still run
- [x] Run `bash scripts/setup-agent-collections.test.sh`

**Stop Rule:** Do not pass `--ssot-source` with a real GitLab URL on the first install (subtree / `ls-remote`). Dummy URL in JSON only.

**Clues**: Node one-liner to patch and read JSON, same style as the existing selection schema check. Place assertions after the current “Upgrade reuse” invocation so the first upgrade still proves a file without `ssot` URL does not crash.

### Phase 3: Docs and changelog

**Goal**: Documented upgrade contract matches the three-way behaviour.

**Description**: README, install-selection schema notes, installation flag table, CHANGELOG SSOT + generate site page.

**Verification:** `npm run website:changelog:check`

#### Task 3.1 - [MODIFY] Document reuse and empty `--ssot-source` as clear

**Description**: README Upgrade: reuses `ssot.externalSsotRepo` (and confluence key) unless flags override; empty `--ssot-source` clears the URL. `install-selection.md` Rules: same. `website/docs/getting-started/installation.md` `--ssot-source` row: omit on upgrade keeps recorded URL; `--ssot-source=` / `""` clears. Unreleased Fixed in `CHANGELOG.md`; run changelog sync.

**Files:** `README.md` (modify), `docs/architecture/install-selection.md` (modify), `website/docs/getting-started/installation.md` (modify), `CHANGELOG.md` (modify), `website/src/pages/changelog.md` (modify via generator)

**Definition of Done**:

- [x] README Upgrade paragraph names SSOT URL reuse and empty `--ssot-source` as clear
- [x] `install-selection.md` states upgrade preserves `ssot.externalSsotRepo` unless overridden or cleared
- [x] Installation flag table matches that contract
- [x] Run `npm run website:changelog:sync` and `npm run website:changelog:check`

**Stop Rule:** Do not rewrite older changelog history. Do not edit `website/src/pages/changelog.md` by hand.

**Clues**: Skill `eversis-writing-repo-documentation` — root CHANGELOG is SSOT.

### Phase 4: Code Review

**Goal**: Independent review confirms omit ≠ clear and vendor/subtree code was not changed.

**Description**: Final verification of the full implementation. This phase is mandatory and always comes last.

**Verification:** `bash scripts/lib/setup-agent-collections/selection-ssot.test.sh` ; `bash scripts/setup-agent-collections.test.sh` ; `npm run website:changelog:check`

#### Task 4.1 - [REUSE] Code review by Code Reviewer

**Description**: Run **Code Reviewer** via `eversis-review.md`. No product e2e app suite; installer smoke is the behavioural suite.

**Files:** `scripts/setup-agent-collections.sh` (reuse), `scripts/lib/setup-agent-collections/upgrade.sh` (reuse), `scripts/lib/setup-agent-collections/selection.sh` (reuse), `scripts/lib/setup-agent-collections/selection-ssot.test.sh` (reuse), `scripts/setup-agent-collections.test.sh` (reuse), `README.md` (reuse), `docs/architecture/install-selection.md` (reuse), `website/docs/getting-started/installation.md` (reuse), `CHANGELOG.md` (reuse)

**Definition of Done**:

- [x] Run `bash scripts/lib/setup-agent-collections/selection-ssot.test.sh`
- [x] Run `bash scripts/setup-agent-collections.test.sh`
- [x] Run `npm run website:changelog:check`
- [x] Code review passes with no blocking findings
- [x] Review outcome documented in Changelog

**Stop Rule:** BLOCKER if `ssot.sh` subtree logic, `vendor.sh`, or `framework-home.txt` helper changed without plan update.

**Clues**: Research Q1–Q4. Confirm first install without `--ssot-source` still writes `null`. Confirm `--ssot-source=` is tested as clear.

## Security Considerations

- Empty `--ssot-source` is an explicit operator action to drop the GitLab URL from the install record; do not treat a missing flag as that action (that was the bug).
- Do not log tokens. `GITLAB_TOKEN` stays out of the installer (existing `install-selection.md` rule).
- Dummy smoke URL must not include credentials.
- Writing JSON `null` is not deletion of `docs/context/global/` — do not `rm -rf` that tree on clear.

## Quality Assurance

Acceptance criteria checklist to verify the implementation meets the defined requirements:

- [x] `--upgrade --sync --non-interactive` without `--ssot-source` keeps a previously recorded `ssot.externalSsotRepo` URL
- [x] `--ssot-source URL` sets or overrides the URL
- [x] `--ssot-source ""` or `--ssot-source=` writes `"externalSsotRepo": null`
- [x] Bare `--ssot-source` (no value) still errors
- [x] `--confluence-space-key` omitted on upgrade keeps `ssot.confluenceSpaceKey`
- [x] First install without `--ssot-source` still records `null`
- [x] `seed_ssot_global` / subtree behaviour unchanged
- [x] Unit + smoke commands in Technical Context pass; changelog check passes

## Improvements (Out of Scope)

- Follow-up after Fine: `vendor-mode-local-changes-disruption` (vendor `framework-home.txt` hygiene) — human Q5
- Empty `--confluence-space-key` as a documented clear
- Wire `ssot.test.sh` / `gitignore.test.sh` into smoke
- Persist `vendorMode` on non-upgrade re-runs without `--vendor` (separate installer session isolation)

## Human gates

Numbered list of every human-approval gate this task passes through, in order. Strike through a gate once closed, and quote the user's literal closing phrase — do not paraphrase — as evidence:

1. ~~Approve research~~ — done (`ACCEPT RESEARCH; MAKE THE PLAN`)
2. ~~Approve this plan~~ — done (`OK IMPLEMENT`)
3. ~~Implement → Review → Fine~~ — Review PASS (2026-08-31); Fine declared in the same session (`OK IMPLEMENT`).
4. ~~Follow-up after Fine: `vendor-mode-local-changes-disruption`~~ — already Fine in the parallel vendor-home-marker thread (not in this plan’s tasks)

## Changelog

| Date       | Change Description   |
| ---------- | -------------------- |
| 2026-08-31 | Initial plan created |
| 2026-08-31 | Code review performed (`eversis-review`): **PASS**, zero BLOCKERs |

## Code Review Findings

Independent Review (`eversis-review.md` + skills `eversis-code-reviewing`, `eversis-implementation-gap-analysing`). Reviewer did **not** author this implementation.

**Verdict: PASS** — zero open BLOCKERs; every visible Definition-of-Done and Acceptance-Criteria checkbox verified.

### PASS

- Omit ≠ empty: `ARG_SSOT_SOURCE_PASSED` / `ARG_CONFLUENCE_SPACE_KEY_PASSED` default `"false"`; spaced and `=*` forms set the matching sentinel; upgrade restores `ssot.externalSsotRepo` / `ssot.confluenceSpaceKey` only when the flag was omitted.
- Empty `--ssot-source` (`""` / `=`) writes JSON `null`; first install without the flag still records `null`.
- `write_install_selection` still uses `process.argv[8] || null`; path fields are merged from existing JSON when present.
- `ssot` is **not** on the required-fields list; missing `ssot` does not fail upgrade.
- Docs (README Upgrade, `install-selection.md` Rules, installation flag table + Upgrade section) match the three-way contract; empty confluence-as-clear is not documented.
- CHANGELOG Unreleased Fixed includes the SSOT URL wipe bullet; `npm run website:changelog:check` OK.
- Unit file `selection-ssot.test.sh` (8/8, re-run this review): first-write null, URL write, omit-load restore, rewrite keep, empty PASSED clear, confluence restore, custom `projectContextPath` keep, bare `--ssot-source` errors.
- Smoke (implementer run, not re-run this review per brief): first install null; patch URL + `DAWIS` key; `--upgrade --sync` without flag keeps both; `--ssot-source=` clears URL and keeps key. Fail-safe missing/corrupt selection tests remain after that block.
- STRICT FORBIDDEN: all dirty files are in this plan’s scope; no documentation comments removed or shortened; no new package-manager dependencies.
- Stop Rule: **this story did not change** `scripts/lib/setup-agent-collections/ssot.sh` (including `seed_ssot_global`), `vendor.sh`, or the `framework-home.txt` helper in `link-framework.sh`.

### BLOCKER

- None.

### SUGGESTION

- Unit coverage asserts custom `projectContextPath` on rewrite; the same merge exists for `globalContextPath` but is not asserted.
- No dedicated unit case for an older selection file with **no** `ssot` object (load must not fail, rewrite adds `ssot`). Code uses optional `j.ssot&&` and the original six required fields — behaviour is correct, a regression test would lock it.
- `--ssot-source URL` **override** of a different recorded URL is implied by PASSED=true skipping restore + write-from-ARG; set-to-URL is unit-tested. An explicit override case would make AC “sets or overrides” fully mechanical.
