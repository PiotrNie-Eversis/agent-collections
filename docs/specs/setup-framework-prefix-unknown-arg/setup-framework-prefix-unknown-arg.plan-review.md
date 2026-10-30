# Plan Review: setup-framework-prefix-unknown-arg.plan.md

**Reviewed plan:** `docs/specs/setup-framework-prefix-unknown-arg/setup-framework-prefix-unknown-arg.plan.md`  
**Research file:** `docs/specs/setup-framework-prefix-unknown-arg/setup-framework-prefix-unknown-arg.research.md`  
**Review date:** 2026-08-13  
**Verdict:** `APPROVED`

**Summary:** 0 blockers · 5 warnings · 4 suggestions

Independent `/eversis-implement` verification confirmed the bug and the two-tree mix against live HOME `95b3969` and EOG pin `c996bb7`. Open Questions in the plan are all ✅ Resolved. No Figma / UI verification. Plan template sections are present; no `❓ Open` rows; no executable angle-bracket placeholders.

## Challenge Domains

| Domain | Result |
| ------ | ------ |
| Technology and stack decisions | **No issue.** Bash installer libs + `git` checkout of a locally resolved SHA + existing `die`/`log_*` + `gitignore.test.sh` unit-test pattern. Matches research and this repo’s stack policy. No new npm dependencies. |
| Irreversible or high-cost decisions | **Issue found**, see W5. Auto-checkout of the **launching clone’s HEAD** into a consumer submodule is a gitlink mutation (not a tag pin). Research locked this; Phase 3 updates docs. Not a blocker because it is the chosen product contract, but it is the highest-cost behaviour in the plan. |
| Contradictions with research or prior context | **No issue.** Plan is **B + A**, verification `--upgrade --sync`, **C out of scope**, no `frameworkVersion` skew signal — matches locked Q1–Q3. |
| Scope gaps and silent omissions | **Issue found**, see W2. Guard is gated on `--upgrade` / `--sync` only. The same skip-add + new-flag mix also happens on a full `--vendor submodule` re-run without those flags. Research explicitly scoped the guard; still a residual fail path. |
| Cross-cutting decisions that propagate | **Issue found**, see W1 and S2. (1) Align placed immediately before `_run_adapter_sync` runs **after** `maybe_build_mcp`. (2) `INSTALLER_FRAMEWORK_HOME := COLLECTIONS_HOME` after resolve, which can diverge from `SCRIPT_DIR/..` when `--collections-home` points at a different tree than the launched script. |
| Build vs buy vs reuse | **No issue.** Reuses `die` / `log_*`, vendor skip-add, `_run_adapter_sync`, and the lib unit-test harness. Correctly rejects Option C (run HOME `sync.mjs`) so generated adapters stay pin-SSOT after align. |

## Decision and Revision History

| Date | Iteration | Decision / Topic | Problem / Challenge | Plan Decision / Change | Status |
| ---- | --------- | ---------------- | ------------------- | ---------------------- | ------ |
| 2026-08-13 | 1 | B + A vs C | HOME bash vs pinned `sync.mjs` mix | Product guard in launched installer (align-or-die) + EOG gitlink bump; keep executing vendored `sync.mjs` | kept |
| 2026-08-13 | 1 | Auto-checkout vs fail-only | Stale pin vs dirty consumer tree | Checkout installer HEAD only on `--upgrade`/`--sync` + submodule + **clean** porcelain; else `die` with commands; never `--force` | kept |
| 2026-08-13 | 1 | Skew signal | `frameworkVersion` is `0.0.1` on both trees | Probe extra CLI flags against vendored `sync.mjs`, not SemVer | kept |
| 2026-08-13 | 1 | Guard owner | `COLLECTIONS_HOME` overwritten in `vendor.sh` | Save `INSTALLER_FRAMEWORK_HOME` before `run_vendor_setup`; implement probe/align in `link-framework.sh` (one owner) | kept |
| 2026-08-13 | 1 | Live verification | Confirm bug + plan vs current trees | Bug reproduced; vendor porcelain now **clean**; pin object db lacks `95b3969` (fetch required). Warnings W1–W5 recorded; no plan text change in this review | open (non-blocking) |

## Top Failure Modes

- **Missing objects in the submodule** — EOG `vendor/agent-collections` object db does **not** contain `95b3969`. A bare `git checkout` of installer HEAD fails until `git fetch` from origin. Plan text mentions fetch; Task 1.2 DoD does not require it.
- **Align too late for MCP** — `setup-agent-collections.sh` runs `maybe_build_mcp "$COLLECTIONS_HOME"` **before** `link_framework_files`. If the guard lives next to `_run_adapter_sync`, adapter sync can succeed on the new pin while MCP dist stays the old pin (`MCP dist already present — skipping build`). Out of scope for *this* fail, but the same `--upgrade --sync` command will leave MCP skewed.
- **Dirty-tree stop vs current machine** — Research warned the vendor tree might be dirty. Independent verification shows **empty porcelain**. Phase 4/5 can take the clean align path; implementers must still inspect porcelain at execution time, not trust the old snapshot.
- **Out-of-repo Phases 4–5** — A and acceptance run in `/Users/piotrniemirski/Documents/Projects/eog`, not this framework git repo. A framework PR can ship B (Phases 1–3) while A remains a consumer follow-up.
- **Wrong launcher SHA** — If `--collections-home` and the launched script tree differ, saving `COLLECTIONS_HOME` after resolve aligns the pin to the *resolved* tree, while `--framework-prefix` still comes from `LIB_DIR` (script tree). Documented EOG invocation uses the same path for both.

## Unproven Assumptions

- **Fetch will succeed** — HOME `95b3969` is on `origin/main`; vendor origin is the same GitHub repo (`PiotrNie-Eversis/agent-collections`). Fetch should work on this machine; not proven in a dry-run (review did not mutate eog).
- **Parent gitlink staging** — `git -C vendor/agent-collections checkout <SHA>` updates the worktree; eog’s index still holds `c996bb7` until Task 4.1 `git add`. Assumed the implementer treats the dirty gitlink as A’s job, not as a failed upgrade.
- **Generic flag probe** — Plan requires probing “every extra arg `_run_adapter_sync` will append”, not a hardcoded `--framework-prefix` only. No helper exists yet; shape is left to implementation (file grep vs `--help`).

## Most Likely Rework Triggers

- Putting the guard in `link-framework.sh` then discovering MCP (or a later pre-sync step) must also see the aligned pin → move the guard to `vendor.sh` after re-point (plan already allows either owner).
- Probe-by-`grep` of `sync.mjs` source matching a comment or string that `parseArgs` does not accept → false “supported”, then `unknown argument` again.
- Treating Phase 5 `--upgrade --sync` as the framework CI gate → cannot run in this repo’s smoke test without a fixture submodule.

## Questions the Architect Must Answer Before Coding

None that block coding. Implementer should pick (plan already allows both):

1. Guard owner: `link-framework.sh` (plan preference) vs `vendor.sh` after re-point (runs before `maybe_build_mcp` — see W1).
2. Probe mechanism: vendored `sync.mjs --help` text vs source `grep` (see S1).

Default if unanswered: follow the plan as written (`link-framework.sh` + file/help probe + fetch-if-missing).

## BLOCKERS

None.

## WARNINGS

### W1: Align-or-die after `maybe_build_mcp` leaves MCP on the old pin

`scripts/setup-agent-collections.sh` order is `run_vendor_setup` → `maybe_build_mcp "$COLLECTIONS_HOME"` → `link_framework_files` → `_run_adapter_sync`. Task 1.2 places the guard immediately before `_run_adapter_sync`. Documented `--upgrade --sync` does **not** pass `--build-mcp`, so `maybe_build_mcp` skips when `dist/index.js` exists.

This does not cause `unknown argument: --framework-prefix`. After a successful align, adapters follow the new SHA while MCP dist can remain `c996bb7`. Prefer implementing the guard in `vendor.sh` after re-point (plan already lists that as an allowed owner) so MCP and sync see the same tree. If keeping `link-framework.sh`, log that MCP was not rebuilt.

### W2: Guard does not cover skip-add without `--upgrade` / `--sync`

`setup_vendor_submodule` skip-add + `COLLECTIONS_HOME` re-point runs for any `VENDOR_MODE=submodule` invocation. A re-run of `--vendor submodule --non-interactive …` without `--upgrade`/`--sync` still injects `--framework-prefix` from HOME bash into pin `sync.mjs`.

Research locked the guard to `--upgrade`/`--sync`. Residual fail path is accepted scope; do not silently widen it in implementation. Docs (Phase 3) should not claim *every* installer invocation aligns the pin.

### W3: Task 1.2 DoD omits the fetch-missing-SHA path that this machine requires

Live check: `git -C eog/vendor/agent-collections cat-file -t 95b3969` fails. Plan description says “fetch from origin if the SHA is missing”; Definition of Done only covers dirty-die, clean-align log, and local/copy skip.

Add a DoD/test bullet: when the SHA is absent from the vendor object db, the helper fetches (or `die`s with the exact `git fetch` / `git checkout` commands) and does not call `checkout` first. Unit test 2.1 should cover “missing SHA → no checkout / die contains fetch”.

### W4: Phases 4–5 are consumer-repo work, not this framework tree

Task 4.1 / 5.1 operate on `/Users/piotrniemirski/Documents/Projects/eog` (`vendor/agent-collections` gitlink + `--upgrade --sync`). They cannot be the merge gate for an agent-collections PR. Ship B (Phases 1–3 + unit test + changelog) in this repo; treat A + live `--upgrade --sync` as machine acceptance. Task 6.1 should not require the eog gitlink to be in the framework diff.

### W5: Auto-checkout pins the consumer to launcher HEAD, not a release tag

Current docs (`installation.md` §5) say “Update submodule to tag → `--upgrade --sync`”. B checkouts `git -C "$INSTALLER_FRAMEWORK_HOME" rev-parse HEAD`. On this machine that is `95b3969` (unreleased `0.0.1` main), which is correct to unblock the flag, but teammates can only fetch it because it is already on `origin/main`. Phase 3 must state that the pin follows the **launching clone’s HEAD**, not “latest tag”. Do not checkout an unpushed local-only SHA without the existing missing-SHA `die`.

## SUGGESTIONS

### S1: Probe via `node sync.mjs --help`, not source `grep`

`parseArgs` on pin `c996bb7` only accepts `--out` / `--agents` / `--check` / `--help` and `fail(\`unknown argument: ${arg}\`)`. Grep of file text is enough today (`--framework-prefix` is absent). `--help` output is the actual CLI contract and stays correct if flags move out of `sync.mjs`. Prefer help-text probe for the “generic extra flags” requirement.

### S2: Bind `INSTALLER_FRAMEWORK_HOME` to the launched script tree

Task 1.1 Stop Rule correctly rejects env-only `AGENT_COLLECTIONS_HOME`. Safer default: `$(cd "$SCRIPT_DIR/.." && pwd)` — that tree sourced `link-framework.sh` and injects `--framework-prefix`. Documented EOG command uses the same path as `resolve_collections_home`; capturing both and `die`ing if they differ would catch `--collections-home` skew.

### S3: Give Task 1.2 a runnable DoD command

Creating-implementation-plans: code-changing tasks need a command from Technical Context. Task 1.2 DoD is behavioural only; the runnable check is Task 2.1. Either add `bash scripts/lib/setup-agent-collections/vendor-sync-skew.test.sh` to 1.2 DoD (after 2.1 exists) or state explicitly that 1.2 is complete only when 2.1 passes.

### S4: Drop the stale dirty-tree snapshot from execution clues

Independent verification: EOG vendor porcelain is **empty**. Plan Additional Context still says the tree “may already be dirty”. Keep the *rule* (inspect porcelain, never `--force`); do not assume dirtiness on this machine. Clean tree means B can auto-checkout once fetch succeeds.

## Verdict

`APPROVED`

Root cause, locked B+A, file paths, `COLLECTIONS_HOME` overwrite order, dirty-tree stop, Option C exclusion, and tests/docs/changelog phasing are sound and match the live installer. Warnings are execution notes (guard placement vs MCP, fetch DoD, eog vs this repo, residual non-upgrade path, HEAD vs tag). They do not require a plan rewrite before coding if the implementer: fetches before checkout, inspects porcelain at run time, and treats Phases 4–5 as consumer acceptance.
