# Upgrade/sync wipes externalSsotRepo - Analysis Result

## Task Details

| Field | Value |
|---|---|
| Jira ID | n/a (consumer bug report via `/eversis-implement`) |
| Title | `--upgrade --sync` clears `ssot.externalSsotRepo` unless `--ssot-source` is passed every time |
| Description | Updating Agent Collections in other consumer folders requires repeating `--ssot-source "https://gitlab3.eversis.com/dawis/domain-context.git"`. Without that flag, `bash "$AGENT_COLLECTIONS_HOME/scripts/setup-agent-collections.sh" --upgrade --sync --non-interactive` writes `null` over the recorded URL in `.agent-collections/install-selection.json` (`ssot.externalSsotRepo`). |
| Priority | Bug — breaks domain-context promotion / shared SSOT on the documented upgrade path |
| Reporter | Human (chat) |
| Created Date | 2026-08-31 |
| Due Date | n/a |
| Labels | installer, upgrade, ssot, install-selection |
| Estimated Effort | Small (distinguish omitted vs empty `--ssot-source`; preserve `ssot.*` on upgrade; unit/smoke). Same-class preserve of `confluenceSpaceKey`. Empty `--ssot-source` is the supported clear. After Fine: vendor home-marker follow-up (separate spec). |

## Business Impact

DAWIS / other consumers pin a shared `domain-context` GitLab URL at first install. Upgrade is supposed to **reuse** the install record (README: agents / MCP / profile / vendor / link) without re-prompting. Today `ssot.externalSsotRepo` is **not** loaded from that record and is rewritten from the empty CLI default (`ARG_SSOT_SOURCE=""` → JSON `null`).

Effects:

- Teams must pass `--ssot-source` on every `--upgrade --sync` in every repo, or the URL disappears.
- `eversis-promote-domain-knowledge` and related skills treat a null `externalSsotRepo` as “this project does not participate in shared domain-context SSOT”.
- The subtree under `docs/context/global/` may still exist (seed is skipped when the directory is already there), so the tree can look fine while the install record is wrong — a silent contract break.

This is a hygiene/contract bug on the **documented** upgrade command, not a vendor-mode issue (separate spec: `vendor-mode-local-changes-disruption`).

## Gathered Information

### Knowledge Base & Task Management Tools

- No Jira key provided. Search not required for this installer-local bug.
- User-stated AC (locked 2026-08-31): `--upgrade --sync --non-interactive` **must not** remove a previously recorded `externalSsotRepo` URL; repeating `--ssot-source` is not required for a normal package update. Passing **empty** `--ssot-source` (`--ssot-source ""` or `--ssot-source=`) **clears** the field to `null`. `confluenceSpaceKey` is preserved the same way (omit = keep; explicit value = override). After Fine of this fix, continue vendor `framework-home.txt` hygiene as a **follow-up** (spec `vendor-mode-local-changes-disruption`), not in this plan.

### Codebase

**Reproduction (from code, matches the report):**

1. First install with `--ssot-source https://gitlab3.eversis.com/dawis/domain-context.git` → `write_install_selection` sets `ssot.externalSsotRepo` to that URL.
2. Later: `--upgrade --sync --non-interactive` **without** `--ssot-source`.
3. `load_selection_or_fail` restores agents, MCP, profile, vendor, link — **not** `ssot.*`.
4. `ARG_SSOT_SOURCE` stays `""` (CLI default in `setup-agent-collections.sh`).
5. End of run: `write_install_selection` does `externalSsotRepo: process.argv[8] || null` → **`null`**.

**Root cause:** upgrade reuses only a subset of selection fields. `write_install_selection` always treats CLI `--ssot-source` / `--confluence-space-key` as the sole source for `ssot.externalSsotRepo` and `ssot.confluenceSpaceKey`. Today `ARG_SSOT_SOURCE=""` at process start, so **omitted** and **empty** are the same string — the wipe bug and the new “empty means clear” contract cannot both be implemented until the parser records whether the flag was **passed**.

```text
load_selection_or_fail
  reads: agents, mcpServers, domainProfile, vendorMode, linkMode
  does NOT read: ssot.externalSsotRepo, ssot.confluenceSpaceKey,
                 ssot.projectContextPath, ssot.globalContextPath

write_install_selection
  externalSsotRepo    ← ARG_SSOT_SOURCE (empty on upgrade unless flag repeated)
  confluenceSpaceKey  ← ARG_CONFLUENCE_SPACE_KEY (same wipe class)
  project/global paths ← hardcoded defaults every rewrite
```

**Same-class wipe:** `ssot.confluenceSpaceKey` is recorded for `eversis-import-confluence-knowledge` and is cleared the same way. In scope for the same fix (preserve unless CLI override).

**Not the same bug:** `seed_ssot_global` already no-ops when `docs/context/global/` exists. Upgrade without `--ssot-source` does **not** delete the subtree; it only corrupts the JSON record. Do not change subtree behaviour in this task unless tests prove otherwise.

**Intended contract (locked):**

| CLI | `ssot.externalSsotRepo` after write |
| --- | --- |
| Flag omitted (typical `--upgrade --sync`) | Keep previous JSON value (or `null` if never set) |
| `--ssot-source <url>` | Set / override to that URL |
| `--ssot-source ""` or `--ssot-source=` | **Clear** → `null` (human-locked Q3) |

`--ssot-source` with no argument at all stays an error (parser already requires a value). First install with omitted flag still records `null`. `--confluence-space-key`: omit = preserve on upgrade; passing a value overrides. Empty confluence-as-clear is **not** in this AC.

README Upgrade should list `ssot.externalSsotRepo` among reused fields, and document empty `--ssot-source` as clear.

**Tests:** no `selection.test.sh`. Smoke upgrades a **local** target that never had `--ssot-source`, so it cannot catch this wipe. `ssot.test.sh` covers seed/scaffold only.

### Relevant Links

- [docs/architecture/install-selection.md](../../architecture/install-selection.md) — `ssot.externalSsotRepo` schema
- [README.md](../../../README.md) — Upgrade command (does not list SSOT as reused)
- [website/docs/domain-context.md](../../../website/docs/domain-context.md) — `--ssot-source` per consumer repo
- [scripts/lib/setup-agent-collections/upgrade.sh](../../../scripts/lib/setup-agent-collections/upgrade.sh)
- [scripts/lib/setup-agent-collections/selection.sh](../../../scripts/lib/setup-agent-collections/selection.sh)

### Relevant Charts & Diagrams

```text
First install
  --ssot-source URL → ARG_SSOT_SOURCE=URL → JSON.ssot.externalSsotRepo = URL

Documented upgrade (bug)
  --upgrade --sync --non-interactive
  load_selection_or_fail  → agents/mcp/profile/vendor/link only
  ARG_SSOT_SOURCE still ""
  write_install_selection → externalSsotRepo = null   ← wipe

Expected upgrade (three-way)
  flag omitted              → keep JSON URL
  --ssot-source URL         → override
  --ssot-source ""  or  =   → write null (clear)
```

## Current Implementation Status

### Existing Components

- CLI parser — `scripts/setup-agent-collections.sh` — **needs modification**: distinguish omitted `--ssot-source` from explicitly empty (e.g. unset vs `""`, or `ARG_SSOT_SOURCE_SET=true`); do not initialize the URL ARG so that omitted looks like clear
- `load_selection_or_fail` — `scripts/lib/setup-agent-collections/upgrade.sh` — **needs extension**: when `--ssot-source` was omitted, restore `ssot.externalSsotRepo` (and `confluenceSpaceKey` / path fields) from JSON
- `write_install_selection` — `scripts/lib/setup-agent-collections/selection.sh` — **needs modification**: omitted → keep/restore; explicit empty → `null`; URL → that string. Today `process.argv[8] || null` already maps empty to `null` (correct for **clear** once omitted is no longer empty-by-default)
- `seed_ssot_global` / `note_confluence_space_key` — `scripts/lib/setup-agent-collections/ssot.sh` — **can be reused**; skip-if-exists already correct
- Smoke `scripts/setup-agent-collections.test.sh` — **needs extension**: (1) install or seed JSON with a URL, `--upgrade --sync` without the flag, assert URL kept; (2) `--ssot-source ""` (or `=`) on upgrade, assert `null`
- `ssot.test.sh` — **can be reused** for seed behaviour; selection wipe is a different module

### Key Files and Directories

- `scripts/lib/setup-agent-collections/upgrade.sh` — incomplete selection load
- `scripts/lib/setup-agent-collections/selection.sh` — rewrite from CLI only
- `scripts/setup-agent-collections.sh` — `ARG_SSOT_SOURCE=""` default
- `docs/architecture/install-selection.md` / README Upgrade — should list `ssot.externalSsotRepo` among reused fields after the fix
- `scripts/setup-agent-collections.test.sh` — upgrade reuse coverage

## Gap Analysis

All missing information and gaps in task description, together with provided answers.

### Question 1
#### Should `--upgrade --sync` without `--ssot-source` keep the URL already in `install-selection.json`?
Yes. Human: `Q1. YES`. Omit flag = preserve. Non-empty `--ssot-source` still overrides.

### Question 2
#### Should `ssot.confluenceSpaceKey` be preserved the same way?
Yes. Human: `Q2. YES`. Omit `--confluence-space-key` on upgrade = keep recorded key; passing a value overrides.

### Question 3
#### Is there a supported way to *clear* a recorded URL (set back to null) without editing JSON by hand?
Yes — **empty `--ssot-source` means clear.** Human: `Q3. DEFINE PASSING THE EMPTY --ssot-source AS CLEAR`. Forms: `--ssot-source ""` and `--ssot-source=`. Bare `--ssot-source` (no value) remains an error. Implementation must not treat “flag omitted” as empty.

### Question 4
#### Must upgrade re-run `git subtree` when the URL is preserved?
No. Human: `Q4. OK`. `seed_ssot_global` already skips when `docs/context/global/` exists. JSON-only fix.

### Question 5
#### Is this the same work as vendor `framework-home.txt` hygiene?
No — keep a separate spec. Human: `Q5. ADD AS THE FOLLOW-UP AFTER FINE`. After Fine of **this** SSOT-wipe fix, the next follow-up is `vendor-mode-local-changes-disruption` (vendor home marker). Do not merge those files into this plan.

## Human gates

Numbered list of every human-approval gate this task passes through, in order. Strike through a gate once closed, and quote the user's literal closing phrase — do not paraphrase — as evidence:

1. ~~Approve research~~ — done (`ACCEPT RESEARCH; MAKE THE PLAN`)
2. Approve plan (once written)
3. Implement → Review → Fine
4. Follow-up after Fine: `vendor-mode-local-changes-disruption` (vendor home-marker hygiene) — not part of this plan’s implementation tasks

## Changelog

| Date | Change |
| --- | --- |
| 2026-08-31 | Initial research (wipe root cause) |
| 2026-08-31 | DELTA: locked Q1–Q5 from human (`Q1. YES`; `Q2. YES`; `Q3. DEFINE PASSING THE EMPTY --ssot-source AS CLEAR`; `Q4. OK`; `Q5. ADD AS THE FOLLOW-UP AFTER FINE`) |
