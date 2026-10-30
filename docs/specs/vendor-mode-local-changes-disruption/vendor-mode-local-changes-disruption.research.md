# Vendor-mode local changes disruption - Analysis Result

## Task Details

| Field | Value |
|---|---|
| Jira ID | n/a (ad-hoc analysis; no matching ticket for `framework-home.txt` / vendor home marker) |
| Title | Analyse uncommitted local changes for disruption of framework operation in vendor mode |
| Description | Review the working-tree diff (installer home marker + tests + changelog) against the vendor (`submodule` / `copy`) contract: MCP compose paths, adapter `--framework-prefix`, skills linking, `COLLECTIONS_HOME` reassignment, gitignore, upgrade `--sync`. Decide whether the change breaks vendor consumers or only fixes hygiene. |
| Priority | Analysis-only (gate before any further installer work) |
| Reporter | Human (chat, `/eversis-implement przeanalizuj …`) |
| Created Date | 2026-08-31 |
| Due Date | n/a |
| Labels | installer, vendor-mode, analysis-only |
| Estimated Effort | Analysis complete; optional follow-up plan is small (tests/wiring) unless vendorMode persistence on non-upgrade re-runs is in scope |

## Business Impact

**Verdict: the uncommitted changes do not disrupt vendor-mode runtime.** They stop a machine-absolute path from being written into a vendor consumer (and delete leftovers from older installers). That is a hygiene fix, not a behaviour change for MCP, adapters, or skills.

Vendor mode is the team default (`--vendor submodule` / `copy`). Previously the installer always wrote `.agent-collections/framework-home.txt` with `echo "${COLLECTIONS_HOME}"` (an absolute path). In vendor mode `manage_gitignore()` **removes** the local gitignore block that would have ignored that file, so the marker was committable and machine-specific. The new code skips the write (and `rm -f` leftovers) when `VENDOR_MODE` is `submodule` or `copy`.

Nothing in this repository or the MCP package **reads** `framework-home.txt`. Vendor SSOT remains `vendor/agent-collections` via `vendor.sh` reassignment of `COLLECTIONS_HOME`. MCP relative compose paths, Claude `${CLAUDE_PROJECT_DIR:-.}/vendor/agent-collections/docker-compose.yml`, Cursor `${workspaceFolder}/vendor/agent-collections/docker-compose.yml`, and `_resolve_framework_prefix` are unchanged.

Shipping this as-is reduces the chance a vendor consumer commits a laptop path. Residual risk is that a **non-upgrade re-run without `--vendor`** still treats the target as local (pre-existing) and would rewrite the marker; that path is not introduced by this diff.

## Gathered Information

### Knowledge Base & Task Management Tools

- Jira (`eversis.atlassian.net`): no dedicated issue for `framework-home.txt` / “Vendor install home marker”. Nearby installer work is historical (DHI-534 install mechanism, DHI-541 docs) or unrelated (DUA-475 SDD). Treat this as local uncommitted work on branch `ssot`, not a ticketed story.
- Confluence / Figma: not applicable.
- User request (literal intent): *przeanalizuj lokalne zmiany pod kątem zakłócenia pracy frameworku w trybie vendor*.

### Codebase

Working tree at analysis time (branch `ssot`):

| Path | Change |
| --- | --- |
| `scripts/lib/setup-agent-collections/link-framework.sh` | Extract `_write_or_clear_framework_home`; vendor `submodule`/`copy` deletes marker and returns; otherwise writes `COLLECTIONS_HOME` |
| `scripts/lib/setup-agent-collections/framework-home.test.sh` | New unit tests (local write; copy/submodule leftover delete). Ran 2026-08-31: 3/3 pass |
| `scripts/setup-agent-collections.test.sh` | After `--vendor=copy` Claude install: fail if `framework-home.txt` exists |
| `CHANGELOG.md` | Unreleased Fixed bullet for vendor install home marker |
| `website/src/pages/changelog.md` | Same bullet (hand-edited; site page is normally generated from root CHANGELOG) |

**HEAD behaviour (before this diff):** `link_framework_files` always `mkdir` + `echo "${COLLECTIONS_HOME}" > …/framework-home.txt` after adapter sync / Claude skills. Comment said “relative pointer”; value was always absolute `pwd`.

**How vendor mode actually finds the framework (unchanged by this diff):**

1. `run_vendor_setup` → `COLLECTIONS_HOME="$TARGET_DIR/vendor/agent-collections"` for submodule/copy.
2. `_run_adapter_sync` runs `node adapters/sync.mjs` from that home; `_resolve_framework_prefix` emits a repo-relative prefix when `VENDOR_MODE` is submodule/copy (not from `framework-home.txt`).
3. `merge_mcp_json` sets `MCP_USE_RELATIVE=true` on the same `VENDOR_MODE` test; compose `-f` is in-repo `vendor/agent-collections/docker-compose.yml`.
4. Upgrade `--sync` reloads `vendorMode` from `install-selection.json` (`local` is mapped to empty string so later checks treat it as local).
5. `gitignore.sh` strips the local ignore block in vendor mode (including `.agent-collections/framework-home.txt`), which is why writing the marker there was a leak.

**Readers of `framework-home.txt`:** grep across repo + `mcp/` — write sites and tests/changelog/gitignore only. MCP env is `AGENT_COLLECTIONS_HOME` / baked `/repo` in Compose, not this file.

**Pre-existing vendor gap (not caused by this diff, still relevant):** smoke re-runs the Claude vendor-copy target later **without** `--vendor` and **without** `--upgrade` (`scripts/setup-agent-collections.test.sh` deselect-Claude block). That invocation: `VENDOR_MODE` unset → `run_vendor_setup` logs “local” → `write_install_selection` records `vendorMode: local` → new helper **writes** the marker again. The new smoke assertion runs **before** that re-run, so it would not catch rewrite. This is installer session isolation (`ARG_VENDOR` not reloaded unless upgrade/sync selection path), not a regression unique to `_write_or_clear_framework_home`.

**Test wiring:** quality command is `bash scripts/setup-agent-collections.test.sh` (`npm run installer:smoke`). Sibling unit files (`gitignore.test.sh`, `vendor-sync-skew.test.sh`) are also standalone and not invoked by smoke. The new unit test follows that pattern; leftover-deletion is therefore not in CI unless someone runs the file explicitly.

**Changelog process:** `eversis-writing-repo-documentation` says edit root `CHANGELOG.md` only and run `scripts/sync-changelog.mjs`. Dual hand-edit of `website/src/pages/changelog.md` is consistent today but can drift; not a vendor runtime issue.

### Relevant Links

- [docs/architecture/install-selection.md](../../architecture/install-selection.md) — `.agent-collections/install-selection.json` is the upgrade record; `framework-home.txt` is not in the schema
- [README.md](../../../README.md) — vendor modes; `AGENT_COLLECTIONS_HOME` for local MCP
- [scripts/lib/setup-agent-collections/vendor.sh](../../../scripts/lib/setup-agent-collections/vendor.sh) — `COLLECTIONS_HOME` reassignment
- [scripts/lib/setup-agent-collections/mcp-merge.sh](../../../scripts/lib/setup-agent-collections/mcp-merge.sh) — relative MCP when vendored
- [scripts/lib/setup-agent-collections/gitignore.sh](../../../scripts/lib/setup-agent-collections/gitignore.sh) — vendor removes local ignore block

### Relevant Charts & Diagrams

```text
Vendor install / --upgrade --sync (VENDOR_MODE=submodule|copy)
  vendor.sh → COLLECTIONS_HOME=vendor/agent-collections
  link_framework_files
    align_vendor_sync_cli_or_die
    adapters/sync.mjs --framework-prefix <relative>
    _write_or_clear_framework_home → rm framework-home.txt   ← this diff
  merge_mcp_json (relative compose under vendor/)
  write_install_selection (vendorMode preserved)

Non-upgrade re-run without --vendor (pre-existing)
  VENDOR_MODE empty → treated as local
  _write_or_clear_framework_home → WRITES marker
  selection vendorMode may become "local"
```

## Current Implementation Status

### Existing Components

- `_write_or_clear_framework_home` — `scripts/lib/setup-agent-collections/link-framework.sh` — **needs modification already applied locally**; vendor skip + leftover delete
- `link_framework_files` — same file — **can be reused**; only the home-marker tail changed
- `_resolve_framework_prefix` / `_run_adapter_sync` / `_link_claude_skills` — **can be reused**; not in the diff
- `run_vendor_setup` / `load_selection_or_fail` / `merge_mcp_json` — **can be reused**; still the real vendor home contract
- `manage_gitignore` — **can be reused**; vendor still un-ignores the marker path, which is why not writing it matters
- Smoke `setup-agent-collections.test.sh` — **needs extension** if leftover-delete or post-deselect marker absence should be CI-gated
- `framework-home.test.sh` — **new**; passes locally; not wired into `installer:smoke`

### Key Files and Directories

- `scripts/lib/setup-agent-collections/link-framework.sh` — the only product behaviour change
- `scripts/lib/setup-agent-collections/framework-home.test.sh` — unit coverage of write vs delete
- `scripts/setup-agent-collections.test.sh` — vendor-copy negative assertion (pre-deselect only)
- `scripts/lib/setup-agent-collections/vendor.sh` — vendor home SSOT
- `scripts/lib/setup-agent-collections/upgrade.sh` — how `--upgrade` restores `VENDOR_MODE`
- `CHANGELOG.md` / `website/src/pages/changelog.md` — docs, not runtime

## Gap Analysis

All missing information and gaps in task description, together with provided answers.

### Question 1
#### Does any vendor runtime path read `.agent-collections/framework-home.txt` so deleting it would break MCP, skills, or adapter sync?
No. Repo-wide grep (including `mcp/`) shows writers, gitignore, tests, and changelog only. Vendor home is `COLLECTIONS_HOME` after `vendor.sh`, MCP relative `-f vendor/agent-collections/docker-compose.yml`, and `--framework-prefix` from `_resolve_framework_prefix`.

### Question 2
#### Does this diff change adapter sync, submodule skew alignment, or Claude skills linking in vendor mode?
No. `align_vendor_sync_cli_or_die`, `_run_adapter_sync`, `_prune_deselected_agents`, `_seed_stack_rule`, and `_link_claude_skills` are untouched. The new call sits after those steps.

### Question 3
#### Can `--upgrade --sync` on an existing vendor consumer still function after leftover deletion?
Yes for framework operation: upgrade loads `vendorMode` from `install-selection.json`, `run_vendor_setup` still repoints `COLLECTIONS_HOME`, then the new helper deletes a leftover marker. If a consumer had **committed** the marker, the next upgrade would delete a tracked file in the worktree (intended cleanup of a machine path). Teams that never used the file (nothing reads it) see no functional change.

### Question 4
#### Is local mode still intact?
Yes by design: empty `VENDOR_MODE` (and literal `local` after selection write) still writes the gitignored pointer. Unit test covers empty `VENDOR_MODE`. Smoke first target is local (`--link-mode=copy` without `--vendor`) but does **not** assert the file exists.

### Question 5
#### Could the change re-break vendor hygiene on a common re-run path?
Yes, incompletely: a full installer re-run **without** `--upgrade`/`--sync` selection load and **without** `--vendor` does not set `VENDOR_MODE`, so the helper writes the marker (same as HEAD always did). This is a pre-existing session-isolation issue; this diff does not fix it and smoke does not assert after the deselect re-run. Not a new vendor runtime break.

### Question 6
#### Should website changelog be hand-edited?
Process gap only: SSOT is `CHANGELOG.md`; `website/src/pages/changelog.md` should be generated via `node scripts/sync-changelog.mjs`. Dual edit is currently matching; run `npm run website:changelog:check` before merge. Unrelated to vendor runtime.

## Human gates

Numbered list of every human-approval gate this task passes through, in order. Strike through a gate once closed, and quote the user's literal closing phrase — do not paraphrase — as evidence:

1. ~~Approve research~~ — done (`I approve the research make the plan`)
2. Approve plan (once written)
3. ~~Implement → Review → Fine~~ — done (`OK IMPLEMENT`)
