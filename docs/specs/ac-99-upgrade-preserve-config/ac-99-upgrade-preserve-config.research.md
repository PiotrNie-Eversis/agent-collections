# AC-99 Upgrade preserves installed config - Analysis Result

## Task Details

| Field | Value |
|---|---|
| Jira ID | [AC-99](https://eversis.atlassian.net/browse/AC-99) |
| Title | Installer --upgrade removes or overwrites already-installed MCP servers and CLAUDE.md |
| Description | `setup-agent-collections.sh --upgrade --sync --non-interactive` trusts only `.agent-collections/install-selection.json`. When the record lists fewer agents / MCP servers than the project has, the run treats the missing items as deselected and prunes them (catalog MCP entries, generated `CLAUDE.md` and other Claude surfaces). |
| Priority | High (data loss on the documented upgrade command) |
| Reporter / Assignee | Piotr Niemirski |
| Created Date | 2026-10-20 |
| Labels | agent-collections, installer |
| Estimated Effort | Medium — installer bash + `mcp-merge.mjs` + `claude-settings-merge.mjs`, unit tests, README / install-selection docs |

## Business Impact

Consumers run the documented upgrade command after every framework bump. Today a short or stale install record silently removes MCP servers the team configured and deletes the generated Claude surfaces, so Claude Code loses its instructions and tools until someone notices and reinstalls with the full flag set. The uncommitted fix attempt in `upgrade.sh` stops the reported deletion but introduces a worse case: a hand-written `CLAUDE.md` is now overwritten.

## Gathered Information

### Knowledge Base & Task Management Tools

- Jira AC-99 (Bug, High) — acceptance criteria copied below; description lists 7 review findings.
- Local review report: `docs/reports/code-quality-report.md` (2026-10-20, findings + reproduction S1–S4).
- `docs/context/agent-collections/INDEX.md` — 2 components (`readiness-contract`, `jira-backlog-hierarchy`); neither covers the installer.
- `docs/decisions/INDEX.md` — only `0001-decisions-home`; no installer decision recorded.
- Precedent (same bug class, same function): `docs/specs/upgrade-sync-ssot-repo-wipe/` — upgrade reused only a subset of the record and the rewrite wiped `ssot.*`. Fixed by "omit = keep, explicit flag = override" with `*_PASSED` markers. This task applies the same contract to agents / MCP / profile.

**Acceptance criteria (AC-99):**

1. `--upgrade --sync --non-interactive` keeps every catalog MCP server already present in `.cursor/mcp.json` and `.mcp.json`, each in its own host file, with its existing config unchanged.
2. A framework-generated `CLAUDE.md` and the other Claude surfaces are kept on upgrade even when the record lacks `claude`.
3. A hand-written `CLAUDE.md` is never overwritten or deleted, and does not by itself enable the Claude adapter.
4. Explicit `--agents` / `--mcp-servers` (including values with spaces) replace the record; deselection still works through these flags.
5. Unit tests cover the cases above.
6. README Upgrade / Deselection sections and `install-selection.md` describe the final behaviour.

### Codebase

**Call path (`scripts/setup-agent-collections.sh`):**

```text
L251  if --upgrade || (--sync && record exists && no --agents && no --profile)
        load_selection_or_fail            # upgrade.sh  → SELECTED_AGENTS, MCP_SELECTED_IDS, DOMAIN_PROFILE …
L258  resolve_agents_selection            # agents.sh   → early return when SELECTED_AGENTS set (no space strip)
L259  resolve_domain_profile              # profile.sh  → early return when DOMAIN_PROFILE set
L264  link_framework_files                # link-framework.sh
        _run_adapter_sync                 #   adapters/sync.mjs → claude generate.mjs writes CLAUDE.md
        _prune_deselected_agents          #   claude ∉ agents → rm generated CLAUDE.md, .claudeignore,
                                          #   .claude/skills/eversis-*, .claude/commands|rules (marker-gated)
        _prune_deselected_cursor_skills
L270  apply_area_scope                    # appends area block to CLAUDE.md when claude ∈ agents
L273  _resolve_mcp_selection              # mcp-prompt.sh → early return when MCP_SELECTED_IDS set
L274  merge_mcp_json                      # mcp-merge.sh/.mjs per host (cursor default, claude only if selected)
L281  merge_claude_settings               # enabledMcpjsonServers := MCP_CONFIGURED_SERVERS (replaced)
L292  write_install_selection             # record := SELECTED_AGENTS, MCP_SELECTED_IDS, DOMAIN_PROFILE
```

**Destructive points (root cause):**

| Location | What it removes / overwrites | Trigger |
|---|---|---|
| `link-framework.sh:43-88` `_prune_deselected_agents` | generated `CLAUDE.md`, triad `.claudeignore`, `.claude/skills/eversis-*`, generated `.claude/commands/*`, `.claude/rules/*` | `claude ∉ SELECTED_AGENTS` |
| `mcp-merge.mjs:145-155` | catalog ids in existing file not in selection → **deleted**; selected ids → **replaced** by template (`{...kept, ...picked}`) | every run |
| `claude-settings-merge.mjs:102-105` | `enabledMcpjsonServers` replaced by the selection list | every run with claude |
| `adapters/claude/generate.mjs:414-428` `writeClaudeMd` | root `CLAUDE.md` unlinked and rewritten, **no marker check** | `claude ∈ agents` |

On upgrade, `SELECTED_AGENTS` / `MCP_SELECTED_IDS` come only from the record, so any drift between the record and disk turns into deletion. Drift sources: records written by older installers, hand-added catalog servers, a teammate's install with a different flag set, manual edits of the record.

**Uncommitted fix attempt** (`scripts/lib/setup-agent-collections/upgrade.sh:36-81`, +46 lines): unions `claude` when `CLAUDE.md` exists and unions catalog ids found in either MCP file into the global selection; explicit `--agents` / `--mcp-servers` replace. Reproduced behaviour (scratch harness sourcing `common.sh` + `upgrade.sh`):

| Scenario | Result | AC |
|---|---|---|
| S1 hand-written `CLAUDE.md`, record `["cursor"]` | `agents=[cursor,claude]` → generator overwrites user file | ✗ AC3 |
| S2 `--agents="cursor, claude"` | `agents=[cursor, claude]` → `',claude,'` misses → Claude surfaces pruned | ✗ AC4 |
| S3 `atlassian` only in `.mcp.json` | added to global selection → written to `.cursor/mcp.json` too, config replaced by template | ✗ AC1 |
| S4 generated `CLAUDE.md`, record `["cursor"]` | `agents=[cursor,claude]` → kept | ✓ AC2 |

Other gaps confirmed in code:

- Detected ids are written back by `write_install_selection` → record only grows; README "Deselection and recovery" (`README.md:344-353`) and `summary.sh:82` describe automatic pruning.
- `--profile` ignored on `--upgrade` (`DOMAIN_PROFILE` set before `resolve_domain_profile`).
- `--sync --agents=…` without `--upgrade` skips the record (L251) → MCP falls back to `eversis-collections` default and prunes other catalog servers (pre-existing; outside AC1 which names `--upgrade --sync`).
- `enabledMcpjsonServers`: even if `.mcp.json` keeps a server, Claude settings would not enable it unless it is in the selection.
- `eversis-collections` entry **must** be regenerated on every run: its command depends on host, vendor mode and `COLLECTIONS_HOME` (`mcp-merge.mjs:60-115`).

**Existing tests:**

- `scripts/lib/setup-agent-collections/selection-ssot.test.sh` — sources `upgrade.sh` directly, no Docker; 8/8 pass with the uncommitted diff.
- `mcp-merge.test.sh` — runs `mcp-merge.mjs` via env vars, host branching; natural home for preserve-mode cases.
- `claude-settings-merge.test.sh` — natural home for the `enabledMcpjsonServers` case.
- `scripts/setup-agent-collections.test.sh` — end-to-end, needs Docker/MCP image; upgrade block at L318-358 checks `ssot.*` only.

### Technical Context (installer)

- Bash `set -euo pipefail`; lib modules are sourced; small Node helpers either inline `node -e` or `.mjs` next to the shell file. New logic with branching should go to `.mjs` (testable), following `mcp-merge.mjs`.
- Marker strings used for ownership: `GENERATED by adapters/claude/generate.mjs`, `GENERATED by adapters/claude/generate-commands.mjs`, `Agent Collections ignore triad`.
- Contract precedent: "omit = keep recorded value, explicit flag = override, explicit empty = clear" (`ARG_SSOT_SOURCE_PASSED`).
- No new npm dependencies needed.

## Gap Analysis

### Identified Gaps

1. **Where to preserve** — two options:
   - **A (in the uncommitted diff): widen the selection** in `upgrade.sh`. Simple, but global (cross-host leak), ratchets the record, and still replaces config with the template.
   - **B (recommended): preserve at the destructive points.** Keep the record as the user's choice; on upgrade without explicit flags, run in *preserve mode*: `mcp-merge.mjs` keeps existing catalog entries of **that host's file** untouched (except `eversis-collections`, always regenerated); `claude-settings-merge.mjs` unions existing `.mcp.json` catalog ids into `enabledMcpjsonServers`; agents are unioned only with **marker-detected** framework installs. Record is not widened with preserved MCP ids.
2. **Agent detection** — evidence that Claude is framework-installed: root `CLAUDE.md` with generator marker, or `.claude/commands/eversis-*.md` with commands marker. A hand-written `CLAUDE.md` alone is not evidence. Same question for Cursor (`.cursor/commands/eversis-*.md` generated) — today only the Cursor skills mirror is pruned.
3. **Selected-but-customised servers** — AC1 says "existing config unchanged". Today even servers *in* the record get re-templated on every run. Preserve mode should keep the existing entry for any non-`eversis-collections` id already present in that host file, whether recorded or not; template only fills ids missing from the file.
4. **`--profile` override on upgrade** — same class (flag ignored); not in AC but listed in AC-99 item 6.
5. **`--sync` without `--upgrade` + `--agents`/`--mcp-servers`** — pre-existing path that prunes; listed in AC-99 item 6.
6. **Generator guard** — `generate.mjs` refusing to overwrite a marker-less `CLAUDE.md` is defense in depth, but touches `adapters/` (framework self-host also uses it).

### Clarifying Questions

1. Approve approach **B** (preserve at destructive points, record not widened) and drop the current `upgrade.sh` union logic for MCP? — *Recommended: yes.*
2. In preserve mode, keep the existing entry also for servers that **are** in the record (AC1 "config unchanged"), regenerating only `eversis-collections`? — *Recommended: yes.*
3. Include marker-gated Cursor detection (keep `cursor` when generated `.cursor/commands/eversis-*` exist), or Claude only? — *Recommended: include; same 5 lines.*
4. Include `--profile` override and the `--sync --agents=…` record-load path in this ticket, or split into a follow-up Task? — *Recommended: `--profile` in scope (one line); `--sync` path as a follow-up Task.*
5. Include the `generate.mjs` marker guard here, or follow-up? — *Recommended: follow-up Task (different module, needs its own escape hatch for first-time takeover of an existing `CLAUDE.md`).*

### Decisions (locked 2026-10-20)

| Gap | Decision |
|---|---|
| 1 | Approach **B** — preserve at destructive points; record is not widened with detected MCP ids. |
| 2 | Marker-based agent detection (Claude and Cursor); hand-written `CLAUDE.md` is not evidence. |
| 3 | Preserve mode keeps every existing non-`eversis-collections` entry of a host file (recorded or not); template only fills missing ids; refresh via explicit `--mcp-servers`. |
| 4 | Explicit `--profile` overrides the record on upgrade/sync. |
| 5 | `--sync` with an existing record loads it; each of agents / MCP / profile: flag overrides, omitted → record. Preserve mode whenever `--mcp-servers` is not passed and a record was loaded. |
| 6 | `generate.mjs`: marker-less root `CLAUDE.md` → copy to `CLAUDE.md.pre-agent-collections.bak`, warn, then write. In AC-99. |

## Proposed Scope

| File | Change |
|---|---|
| `scripts/lib/setup-agent-collections/upgrade.sh` | Replace uncommitted union block: explicit flags override (with space strip, incl. `--profile`); otherwise set `INSTALL_PRESERVE_EXISTING=true` and union marker-detected agents. |
| `scripts/lib/setup-agent-collections/mcp-merge.sh` / `mcp-merge.mjs` | Pass `MCP_PRESERVE_EXISTING`; in preserve mode keep existing catalog entries of this host untouched, regenerate `eversis-collections`, add missing selected ids from template. |
| `scripts/lib/setup-agent-collections/claude-settings-merge.sh` / `.mjs` | In preserve mode, `enabledMcpjsonServers` = selection ∪ catalog ids present in `.mcp.json`. |
| tests: `selection-ssot.test.sh` (or new `upgrade-preserve.test.sh`), `mcp-merge.test.sh`, `claude-settings-merge.test.sh` | AC1–AC4 cases incl. S1–S4. |
| `README.md`, `docs/architecture/install-selection.md`, `summary.sh` | Upgrade / deselection contract. |

## Changelog

| Date | Change Description |
|---|---|
| 2026-10-20 | Initial research (CREATE) from AC-99, review report and S1–S4 reproduction. |
| 2026-10-20 | Human: Gap 2 (marker-based agent detection) accepted. Gaps 1, 3, 4, 5, 6 — explanation requested; still open. |
| 2026-10-20 | Human locked all gaps (`1. B; 3. OK; 4. OK; 5. OK; 6. B w AC-99;`): Gap 1 → approach B; Gap 3 → preserve existing entries incl. recorded ones, regenerate only `eversis-collections` (template refresh via explicit `--mcp-servers`); Gap 4 → `--profile` override in scope; Gap 5 → `--sync` loads the record per field, in scope; Gap 6 → `generate.mjs` backs up a marker-less `CLAUDE.md` to `CLAUDE.md.pre-agent-collections.bak` and warns, in scope. Gap 2 and Cursor marker detection accepted. Research gate closed. |
