# Plan Review: ac-14-pi-agent-support.plan.md

**Reviewed plan:** `docs/specs/ac-14-pi-agent-support/ac-14-pi-agent-support.plan.md`  
**Research file:** `docs/specs/ac-14-pi-agent-support/ac-14-pi-agent-support.research.md`  
**Review date:** 2026-10-30 (iteration 1), 2026-10-30 (iteration 2)  
**Verdict:** `APPROVED` (iteration 2)

**Summary (iteration 2):** 0 blockers · 1 warning (new, N-W1) · 3 suggestions (new, N-S1 – N-S3). All iteration-1 findings are resolved (see below).  
**Summary (iteration 1):** 3 blockers · 8 warnings · 6 suggestions

Open Questions gate: all 8 rows are `✅ Resolved`, so the review can go ahead. Human-approved research decisions Q1–Q7 are not challenged. The findings below cover only how the plan carries them out.

## Iteration 2 — Status of Iteration-1 Findings

| Finding | Status | Where the revised plan addresses it |
| ------- | ------ | ----------------------------------- |
| B1 compaction aborts the run | **Resolved** | Proposed Solution §3, Additional Context `plan.md:143-144`, Task 1.2 (`:181-198`). I checked the mechanism against Pi 1.4.0 (details below). Sending the continuation after a *final* turn is a new risk, covered in N-W1. |
| B2 unquoted YAML front matter | **Resolved** | `plan.md:37`, Task 1.1 (`:160`, DoD `:169`), Task 1.3 `": "` fixture |
| B3 empty `SELECTED_AGENTS` → cursor | **Resolved** | `plan.md:33`, Task 3.2 (`:254,257`, DoD `:264-265`), Clues `:271`, smoke (a)/(e) `:311` |
| W1 `--check` design | **Resolved** | Task 2.1 (`:221`, DoD `:229`); Phase 2 verification now `--agents cursor,pi` for both write and check (`:217`) |
| W2 `$N` substitution | **Resolved** | `plan.md:37`, Task 1.1 (`:160`, DoD `:170`). Refinement suggested in N-S1. |
| W3 mirror helper prunes role skills / isolation | **Resolved** | Task 3.2 (`:255-257`, DoD `:266`) |
| W4 Pi MCP merge and headline isolation | **Resolved** | Task 3.3 (`:275`, DoD `:282`), Task 3.5 headline (`:299`), smoke (f) |
| W5 vendor-pin probe | **Resolved** | New Task 3.4 (`:286-295`) |
| W6 Pi MCP variable rules | **Resolved** | Task 3.3 Pi-specific branch with walk-up to `.pi/` (`:275`, DoD `:281`) |
| W7 `node --test` directory argument | **Resolved** | `plan.md:132,156,196,209,368` |
| W8 MCP docs pages | **Resolved** | Task 4.3 (`:351-357`) |
| S1 Pi map parity | **Resolved** | Task 2.1 (`:221`) |
| S2 automated Pi load check | **Resolved** | Task 5.1 (`:370-382`) uses `pi --approve` and `pi mcp list`, with a Stop Rule that moves the check to QA. If Pi has no CLI command that only loads resources, Pi's own `dist` loaders can be run through `node -e` as a fallback. |
| S3 computed counts | **Resolved** | Goal `:15`, diagram `:45`, smoke (a) `:311` |
| S4 Pi-only stack seed | **Resolved** | Task 1.1 skips the unmodified seed (`:35,160`). Seeds made from◊ an older template version are not caught; see N-S2. |
| S5 README host notes | **Resolved** | Task 4.1 DoD (`:334-335`), Additional Context `:145` |
| S6 prompt-quality read | **Resolved** | Task 5.2 (`:386`) |

**New Pi API claims I verified (Pi 1.4.0 `dist/`):**

- **`pi.sendUserMessage` options.** The signature is `{ deliverAs?: "steer" | "followUp"; expandPromptTemplates?: boolean }` (`dist/core/extensions/types.d.ts:1267-1270`). `expandPromptTemplates` defaults to `false` (`agent-session.js:1908,1932`), so passing `false` explicitly is harmless.
- **Timing of `onComplete`.** It runs only after `compact()` resolves. `compact()` calls `_clearManualCompactionState()` before it returns (`agent-session.js:2320`), so `prompt()` does not hit its "Cannot submit a prompt while compaction is in progress" guard (`:1648-1650`).
- **The continuation starts a new run.** The session is idle after the abort (`abort()` waits for idle, `:1971-1981`). The message therefore starts a fresh run through `_startRun` (`:1693`).
- **When `deliverAs` matters.** It is used only while the agent is streaming. Without it, a streaming session throws "Agent is already processing" (`:1663-1675`).
- **Idle check.** `ctx.isIdle()` exists (`types.d.ts:236`), so the plan's "fall back to `followUp` if not idle" branch can be implemented.
- **Errors from the extension call.** The `sendUserMessage` binding is fire-and-forget. Errors reach only `runner.emitError` (`agent-session.js:2774-2781`), so `onComplete` cannot tell whether the continuation actually started.

Evidence base: Pi 1.4.0 at `~/.nvm/versions/node/v24.16.0/lib/node_modules/@earendil-works/pi-coding-agent/` (docs, `dist/`), the sternik-kariery benchmark (`scripts/gen-pi-adapter.mjs`, `scripts/pi-rule-map.yaml`, `.pi/`), and the repository files listed per finding. Baseline `node adapters/sync.mjs --check` is green.

## Challenge Domains

| Domain | Result |
| ------ | ------ |
| Technology and stack decisions | **Issue (B1).** The extension design calls `ctx.compact()` on `turn_end`. In Pi 1.4.0 that call first aborts the running agent turn and does not resume it (`dist/core/agent-session.js:2230-2231`, `willRetry: false`). The rest of the stack choice (zero-dep ESM generator, jiti `.ts` extension, built-in MCP) matches Pi docs. |
| Irreversible or high-cost decisions | No issue. The new consumer-visible names (`.pi/skills/eversis-rule-*`, `.pi/extensions/eversis-context-budget.ts`, the `EVERSIS_CONTEXT_BUDGET_PERCENT` env var) are cheap to change before release. |
| Contradictions with research or prior context | Minor. The plan inherits the research count of "51" skills, but there are 50 (S3). The plan also adds an unresearched "Claude-style rewrite" for Pi MCP that does not fit Pi's variable rules (W6). Otherwise the plan is consistent with Q1–Q7. |
| Scope gaps and silent omissions | **Issue.** Three gaps. The per-host MCP docs pages are missing from Phase 4 (W8). The vendor-submodule skew guard does not cover the new agent id (W5). Pi's MCP merge failure is not isolated, which affects AC4 (W4). |
| Cross-cutting decisions that propagate | **Issue (B3, W3).** The installer-wide `${SELECTED_AGENTS:-cursor}` default turns an empty agent list into Cursor. The shared skills-mirror helper's stale-prune would delete the Pi role skills. |
| Build vs buy vs reuse | **Issue (B2, W2).** Porting the benchmark generator brings two of its bugs: unquoted YAML `description` and unescaped `$N` text. Both are verified against Pi's own parser and substitution code. |

## Decision and Revision History

| Date | Iteration | Decision / Topic | Problem / Challenge | Plan Decision / Change | Status |
| ---- | --------- | ---------------- | ------------------- | ---------------------- | ------ |
| 2026-10-30 | 1 | Q1–Q7 research answers | Human-approved | Not re-litigated | kept |
| 2026-10-30 | 1 | AC5 extension trigger (`turn_end` + `ctx.compact`) | `ctx.compact` aborts the in-flight run, no resume | Specify a continuation or an idle-boundary mechanism (B1) | open |
| 2026-10-30 | 1 | Prompt front matter port | Unquoted `description:` with `: ` → Pi drops 4/28 prompts | Quote the scalar; parse-test it (B2) | open |
| 2026-10-30 | 1 | Pi failure isolation via mutating `SELECTED_AGENTS` | Empty list falls back to `cursor` everywhere | Use a separate flag; handle Pi-only (B3) | open |
| 2026-10-30 | 1 | `sync.mjs --check` for Pi | Phase 2 verification fails as written; overlay causes false drift | Delegate to the Pi generator's own `--check` (W1) | open |
| 2026-10-30 | 1 | `node --test adapters/pi/` | Directory argument fails on Node 24 | Use a glob (W7) | open |
| 2026-10-30 | 2 | AC5 continuation (B1) | Run aborted by `ctx.compact` | `onComplete` → one `pi.sendUserMessage`, `followUp` when not idle; unknown/first reading counts as crossing | resolved |
| 2026-10-30 | 2 | Front matter / `$` neutralisation (B2, W2) | Dropped prompts, mangled amounts | JSON-quoted values; `$`→`＄`; parse + regex tests | resolved |
| 2026-10-30 | 2 | Installer isolation (B3, W3, W4, W5) | Cursor fallback, role-skill prune, MCP `die`, stale pin | `PI_STAGE_FAILED` flag, isolated Pi stage incl. MCP, `eversis-rule-*` prune exclusion, Task 3.4 probe | resolved |
| 2026-10-30 | 2 | Sync check / MCP / tests / docs (W1, W6, W7, W8) | False drift, Claude MCP rewrite, test command, docs gaps | Agents-scoped check delegating to the Pi generator; Pi MCP branch; glob; two docs pages added | resolved |
| 2026-10-30 | 2 | Continuation after a *final* turn (N-W1) | An unsolicited user-role run after the agent stopped at a gate or question | Send the continuation only when the interrupted turn had tool calls | open (warning) |

## Top Failure Modes

- **AC5 regresses into "Pi stops working at 50%".** The extension aborts the Implement run in the middle of a task on every 50% crossing, and the user must re-prompt. The `shouldCompact` unit tests stay green while the session behaviour is broken (B1).
- **AC1 silently incomplete.** Four generated prompts (`eversis-create-custom-instructions`, `eversis-review-ui`, `eversis-create-custom-skill`, `eversis-review-codebase`) fail Pi's front-matter parse and are skipped with only a warning. File-count DoD checks still report 28 (B2).
- **`--agents=pi` alone produces a Cursor install record.** This happens either on the happy path, through an empty `--agents` list for the non-Pi sync, or on Pi failure, after `pi` is removed from `SELECTED_AGENTS` (B3).
- **Role skills deleted on every re-run.** The generic mirror helper's stale-prune removes `.pi/skills/eversis-rule-*`. They come back only if the Pi stage succeeds afterwards (W3).
- **Cost-analysis prompts corrupted.** Pi's `$N` substitution turns `$140` / `$820` example amounts into empty strings (W2).

## Unproven Assumptions

- `ctx.compact()` on `turn_end` lets the current task continue after compaction. **Disproven** for Pi 1.4.0: it aborts the run (`agent-session.js:1971-1981`, `2230-2231`).
- Benchmark front-matter emission is valid YAML for every prompt. **Disproven**: Pi's `parseFrontmatter` rejects `description: Create or extend project instructions for Cursor: AGENTS.md…` with "Nested mappings are not allowed in compact mappings".
- `node --test adapters/pi/` runs the suites. **Disproven** on Node 24.16.0 (`Cannot find module …/adapters/pi`).
- Pi trust approval cannot be automated (Task 5.1 Stop Rule). **Disproven**: `--approve` / `--no-approve` apply first (`docs/security.md:61,82`).
- `.ai/skills` holds 51 skill packages. It holds **50**; the 51st entry is `README.md`.
- The Claude MCP rewrite (`${workspaceFolder}` → `${CLAUDE_PROJECT_DIR:-.}`) is meaningful in Pi. Pi expands `${VAR}` only in `env`/`headers` (`docs/mcp.md:81`), and `CLAUDE_PROJECT_DIR` is not set by Pi.

## Most Likely Rework Triggers

- The extension mechanism (B1): the choice between a continuation message, a boundary compaction draft, or an idle trigger changes the extension shape and its tests.
- Installer stage ordering and agent-list handling (B3, W3, W4): this touches `link-framework.sh`, `setup-agent-collections.sh`, `mcp-merge.sh` and the smoke cases together.
- The `sync.mjs --check` design for Pi (W1): it affects Phase 2 DoD and any future CI job.

## Questions the Architect Must Answer Before Coding

1. After the extension triggers compaction, how does the interrupted Implement run continue? Options: `pi.sendUserMessage(…)` in `onComplete`, a `compaction` boundary draft with `continue: true`, or triggering only at an idle boundary. How is that verified?
2. On Pi failure with `--agents=pi` only, what does the installer record and print? What is passed to the non-Pi sync when no non-Pi agent is selected?
3. Does `sync.mjs --check --agents …` gate the Cursor and Claude checks by `--agents`, or only add Pi? How does the stack overlay avoid false drift when generators run into a temp dir?
4. Where do the Pi skills mirror and the Pi deselect pruning run: inside the isolated Pi stage, or in `link_framework_files`?

## BLOCKERS

### B1: Context-budget extension aborts the running Implement turn (AC5)

Plan Task 1.2 (`plan.md:175`) registers `turn_end` and calls `ctx.compact({ customInstructions })`. In Pi 1.4.0 the extension `compact` binding calls `AgentSession.compact()` (`dist/core/agent-session.js:2831-2836`). That method starts with `await this.abort()` (`:2230-2231`), which aborts the active agent run and waits for idle (`:1971-1981`). Manual compaction emits `willRetry: false`, so nothing resumes. `turn_end` fires between turns of a multi-turn tool loop (`docs/extensions.md:87,154`). So each 50% crossing in the middle of an Implement task stops the agent, and the user has to prompt again. AC5 says compaction "runs before the current task is dropped". As designed, it drops the in-flight work. The plan's tests only cover the pure `shouldCompact` table, so they cannot catch this.

Two related gaps in the same design:

- `ctx.getContextUsage()` can return `undefined`, not only `percent: null` (`dist/core/extensions/types.d.ts:248`).
- Crossing-only semantics treat `null`/`undefined` as the previous value, which never fires. A session resumed or reloaded already above 50% therefore never compacts at the budget.

**Action (plan change):** In Task 1.2, pick and specify one continuation mechanism:

- (a) Keep `ctx.compact`, and in `onComplete` call `pi.sendUserMessage("Continue the current plan task from the compaction summary.")` (guarded so it runs only when the abort interrupted a run).
- (b) Return a `compaction` entry draft plus `continue: true` from the `turn_end` actionable boundary (`docs/extensions.md:230`, `types.d.ts:770-795`). This option requires generating the summary inside the extension.
- (c) Trigger only at `agent_before_settle` or `agent_settled` (idle), and accept overshoot inside one run.

Also add these to the DoD:

- `shouldCompact(undefined|null, x>=threshold)` fires once on the first observation above threshold.
- A table case for the `undefined` usage object.
- A QA checklist item (not DoD) that confirms in a real Pi session that work continues after compaction.

### B2: Ported prompt front matter is invalid YAML for 4 of 28 prompts (AC1/AC7)

Task 1.1 says to port the benchmark (`plan.md:171`). The benchmark writes `description: ${description}` unquoted after stripping quotes (`sternik-kariery/scripts/gen-pi-adapter.mjs:213-219`). Four SSOT descriptions contain `": "`:

- `.ai/prompts/public/eversis-create-custom-instructions.md:6`
- `eversis-review-ui.md:6`
- `eversis-create-custom-skill.md:6`
- `eversis-review-codebase.md:6`

Pi's own parser (`dist/utils/frontmatter.js` `parseFrontmatter`) throws on the benchmark's output for these files ("Nested mappings are not allowed in compact mappings"). `loadTemplateFromFile` then records a warning and returns `template: null` (`dist/core/prompt-templates.js:99-105`), so the slash command does not exist. The benchmark tree `sternik-kariery/.pi/prompts/eversis-create-custom-instructions.md:2` already has this defect. The same risk applies to role-skill `description` values.

**Action (plan change):**

- Task 1.1: emit every front-matter scalar (`description`, `argument-hint`, role-skill `name`/`description`) as a JSON-quoted string (`JSON.stringify`, which is valid YAML).
- Task 1.1 DoD: add "every generated `.pi/prompts/*.md` and `.pi/skills/eversis-rule-*/SKILL.md` front matter round-trips through a strict YAML-subset check, and the test fixture includes a description containing `: `".
- Task 5.1: add "no prompt-template parse warnings".

### B3: Pi-only selection collapses to Cursor via the `${SELECTED_AGENTS:-cursor}` default (AC3/AC4)

Task 3.2 (`plan.md:240`) does two things:

- It excludes `pi` from `_run_adapter_sync`.
- On Pi failure, it removes `pi` from `SELECTED_AGENTS` "for the rest of the run".

With `--agents=pi`, both produce an empty list. The installer's idiom maps an empty list to Cursor in many places:

- `link-framework.sh:278` (`_run_adapter_sync`)
- `link-framework.sh:44,98,124`
- `mcp-merge.sh:33` (writes `.cursor/mcp.json`)
- `ignore-triad.sh:9` (writes `.cursorignore`)
- `selection.sh:20` (records `"agents": ["cursor"]`)
- `summary.sh:10`

On the happy path, the result depends on how the filtered list is built:

- If the code reuses the `:-cursor` default, a Pi-only install also generates Cursor output. Smoke case (a), "no `.cursor/` generated output", then fails.
- If it passes an empty `--agents ""`, `sync.mjs` exits with "`--agents requires a comma-separated list`" (`adapters/sync.mjs:83-85`), and `_run_adapter_sync` `die`s, killing the whole install.

On the failure path, a failed Pi-only install is recorded as a Cursor install, and the next `--upgrade` keeps it that way. Smoke case (d) uses `cursor,pi` only, so neither path is tested.

**Action (plan change):**

- Task 3.2: skip `_run_adapter_sync` entirely when no non-Pi agent is selected. Never fall back to `cursor` for the filtered list.
- On Pi failure, do not mutate `SELECTED_AGENTS`. Set `PI_STAGE_FAILED=true` and filter `pi` out only in `write_install_selection`, the Pi MCP merge guard and the summary.
- When `pi` was the only agent, record the failure and exit 1 right after the Pi stage, so no fallback-to-Cursor steps run.
- Task 3.5: add cases (f) `--agents=pi` (assert no marker-bearing `.cursor/`/`.claude/` files, no `.cursor/mcp.json`, selection `["pi"]`) and (g) induced failure with `--agents=pi` (exit 1, selection does not contain `cursor`, no `.cursor/mcp.json`).

## WARNINGS

### W1: `sync.mjs --check` design for Pi fails the plan's own Phase 2 verification and gives false drift

`runCheck` always generates and compares Cursor and Claude output, and it ignores `--agents` (`adapters/sync.mjs:460-650`). Task 2.1 keeps that behaviour ("leaving Cursor/Claude checks as today"). The Phase 2 verification then runs `node adapters/sync.mjs --agents cursor,pi --out "$TMP"` followed by `--check --agents pi --out "$TMP"` (`plan.md:205,217`). Nothing writes Claude output into `$TMP`, so the check reports `CLAUDE.md: missing on disk` and exits 1 (`compareFiles`, `:310-313`).

Separately, if Pi is checked the same way as the others (generate into a temp dir, then compare), the stack overlay reads `<out>/.cursor/rules/eversis-project-stack.mdc`. That file does not exist in the temp dir, so every consumer with a seeded stack file reports `.pi/APPEND_SYSTEM.md` drift.

**Action:** In Task 2.1, specify that the Pi check delegates to `adapters/pi/generate.mjs --check --out <compareRoot> [--framework-prefix …]`. Also gate the Cursor and Claude checks by `--agents` when `--agents` is passed explicitly, and leave the default unchanged. Alternatively, change the Phase 2 verification to `--agents cursor,claude,pi` for both write and check. Add a DoD line: "`--check` on a target with a stack overlay reports no drift".

### W2: Pi `$N` substitution corrupts generated prompt text

Pi substitutes `$<digits>`, `$@`, `$ARGUMENTS`, `${N:-…}` and `${@:N}` anywhere in a template body, and offers no escape (`dist/core/prompt-templates.js:62-83`). `$140` resolves to `args[139] ?? ""`. The SSOT bodies contain dollar amounts in example tables:

- `.ai/prompts/public/eversis-analyze-aws-costs.md:170-171`
- `.ai/prompts/public/eversis-analyze-gcp-costs.md:175-176`

These are inside the executable section and become empty in Pi. The benchmark has the same defect (`sternik-kariery/.pi/prompts/eversis-analyze-aws-costs.md:128`).

**Action:** In Task 1.1, make the generator neutralise these tokens in the executable body, but not in the trailing `$ARGUMENTS` line. Replace `$` before a digit or `@`, and `${`, with `&#36;` or the word `USD`. Add a Task 1.3 test: "no generated prompt body matches `/\$(\d|@|\{(\d|@|ARGUMENTS))/` except the final `$ARGUMENTS` line".

### W3: The shared skills-mirror helper deletes Pi role skills, and Pi mirror placement escapes isolation

`_link_claude_skills` and `_link_cursor_skills` stale-prune every `eversis-*` entry not present in `.ai/skills` (`link-framework.sh:209-226,255-270`). Task 3.2 asks for a single helper with "identical behaviour" for `.pi/skills`. That would remove the generated `.pi/skills/eversis-rule-*` directories on every run, and they are restored only if the Pi stage later succeeds.

Two more problems with placement:

- If the Pi mirror and `_prune_deselected_pi` run inside `link_framework_files` (as the other mirrors do), a Pi-caused failure, such as the smoke (d) `.pi`-is-a-file case, is never reported as `pi`.
- `set -e` is suppressed inside functions called from a `… || { … }` list, so `mkdir`/`ln` errors there pass silently.

**Action:** In Task 3.2, give the helper an exclude pattern (`eversis-rule-*`) for stale-prune. Move the Pi mirror and Pi deselect pruning into the isolated Pi stage, and check each command's status explicitly (`|| return 1`). Add a DoD line: "after a second install run, `.pi/skills/eversis-rule-*` count is 3 and was not re-created (mtime unchanged or log shows no removal)".

### W4: AC4 isolation covers only Pi generation, not Pi MCP merge or the summary

`_merge_mcp_json_for_host` `die`s on merge or JSON failure (`mcp-merge.sh:98,101`), and the call site is fail-fast (`setup-agent-collections.sh:290`). An invalid hand-edited `.pi/mcp.json` therefore aborts the rest of the install (ignore, claude-settings, scaffold, selection) and is reported as `mcp-merge`, not `pi`. In addition, `print_summary` always prints a green "agent-collections setup complete" headline (`summary.sh:18-20`), even though the plan prints it before exit 1.

**Action:**

- Task 3.3: run the Pi MCP merge last, and wrap it so a failure becomes `record_fail "pi"` with the same isolation as Task 3.2.
- Task 3.4: when the Pi stage failed, print a headline such as "setup completed with failures (pi)" and the cause.
- Add a smoke case with a malformed pre-existing `.pi/mcp.json`.

### W5: The vendor-submodule skew guard does not cover the new `pi` agent id

`align_vendor_sync_cli_or_die` probes only flag names (`vendor-sync-skew.sh:10-25,131-171`). On `--upgrade`/`--sync` with a submodule pinned before AC-14, the vendored `sync.mjs` rejects `--agents pi` ("unknown agent id: pi", `adapters/sync.mjs:93-95`), and `adapters/pi/` is missing. With the Task 3.2 isolation, every such upgrade reports a Pi failure instead of aligning the clean pin as the guard does for flags.

**Action:** In Task 3.2, make `pi` part of the probe when it is selected: check that `node sync.mjs --help` lists `pi` and that `adapters/pi/generate.mjs` exists. Reuse `_align_clean_vendor_to_installer_head`, and for a dirty pin, print the skew message with "Rejected agent id: pi". Add a line to `vendor-sync-skew.test.sh` (modify, add it to Files).

### W6: The Pi MCP entry rules are borrowed from Claude and do not match Pi's expansion rules

Task 3.3 (`plan.md:255`) says to apply the Claude-style rewrite to other catalog servers. That rewrite maps `${workspaceFolder}` to `${CLAUDE_PROJECT_DIR:-.}` (`mcp-merge.mjs:139-147`). Pi:

- expands `${VAR}` only in `env`/`headers` (`docs/mcp.md:81`);
- does not document the `:-default` syntax;
- never sets `CLAUDE_PROJECT_DIR`.

Local mode takes `CONSUMER_PROJECT_ROOT` from `$PWD`. Stdio servers inherit Pi's working directory (`docs/mcp.md:62`), so starting `pi` in a subdirectory mounts the wrong root. The vendored locator walks upward, but the local variant does not.

**Action:** In Task 3.3, define a Pi-specific rewrite:

- `${env:X}` → `${X}`, only inside `env`/`headers`.
- Any `${…}` left in `command`/`args` is a `fail`.
- `${workspaceFolder}` is resolved by the bash locator.

For local mode, walk up from `$PWD` to the nearest directory containing `.pi/` (or the git root) before setting `CONSUMER_PROJECT_ROOT`. Extend the DoD: "`.pi/mcp.json` contains no `CLAUDE_PROJECT_DIR`, no `${` in any `command`/`args`", and, as an optional check when Pi is installed, `pi mcp list` on the smoke target.

### W7: The `node --test adapters/pi/` verification command does not run

On Node 24.16.0, `node --test <dir>/` exits with `Cannot find module '<dir>'`. This was reproduced in a scratch directory, where `node --test 'sub/*.test.mjs'` passed, including a `.ts` import. The plan uses the directory form in the Phase 1 Verification, Task 1.2 DoD, Task 1.3 DoD and Phase 5 Verification (`plan.md:129,151,184,197,335`).

**Action:** Replace every occurrence with `node --test 'adapters/pi/*.test.mjs'`. In Technical Context, state that `context-budget.test.mjs` needs Node ≥ 22.18 for `.ts` import, or keep `shouldCompact` in a `.mjs` module that the `.ts` asset re-exports.

### W8: Phase 4 misses per-host MCP documentation (AC2)

`website/docs/getting-started/mcp-setup.mdx` has per-host tabs (Cursor `.cursor/mcp.json` at `:109-124`, Claude Code `.mcp.json` at `:126-137`) and a per-host syntax note (`:73`). `website/docs/reference/integrations/eversis-collections.md:226-227` lists how each host sets `CONSUMER_PROJECT_ROOT`. Neither file is in Task 4.3, so readers get no Pi `.pi/mcp.json`, trust or `pi mcp list` guidance.

**Action:** Add both files to Task 4.3 Files, with a DoD line: "mcp-setup.mdx has a Pi tab naming `.pi/mcp.json`, project trust and `pi mcp list`; integrations page names Pi's `CONSUMER_PROJECT_ROOT` mechanism".

## SUGGESTIONS

### S1: Include the Pi rule map in id/source parity

`assertIdSourceParity` covers only the Cursor and Claude maps (`adapters/sync.mjs:250-274`). Add `adapters/pi/rule-map.yaml`, with `target: none` still counting as present, so a new `.ai/rules` entry cannot silently miss Pi.

### S2: Make Task 5.1 deterministic and DoD-compliant

The plan skill forbids manual QA steps in a DoD (`.ai/skills/eversis-creating-implementation-plans/SKILL.md`, definition-of-done rules). Trust can be automated with `pi --approve` (`docs/security.md:61,82`). Run the check against the installed Pi package's own loaders (`dist/utils/frontmatter.js`, `dist/core/prompt-templates.js`, `dist/core/skills.js`) with `node -e`, without adding a dependency, plus `pi mcp list`. Move the live-session check (AC5 continuation) to the Quality Assurance list.

### S3: Fix the "51 skills" count

`.ai/skills` contains 50 `eversis-*` packages plus `README.md`. Update the Goal (`plan.md:15`), diagram (`:43`) and smoke (a) (`:279`) to assert computed parity with `ls -d .ai/skills/eversis-*`, not a literal.

### S4: Pi-only installs seed a Cursor stack file and push template text always-on

`_seed_stack_rule` runs unconditionally (`link-framework.sh:24-41,323`). On a Pi-only install it creates `.cursor/rules/eversis-project-stack.mdc` from the template, and Q4 then appends that placeholder text to `APPEND_SYSTEM.md`. Smoke (a)'s "no `.cursor/` output" assertion must therefore be marker-based. The summary should tell Pi-only users that this file feeds Pi.

### S5: Note host side effects in the Pi README

Three points belong in the README:

- A project `.pi/APPEND_SYSTEM.md` replaces, and does not combine with, `~/.pi/agent/APPEND_SYSTEM.md` (`docs/configuration.md:39`).
- `.pi/extensions/*.ts` with an unresolved `import type` may be picked up by a consumer's TypeScript or ESLint config. Consider a `// @ts-nocheck` header or a README note.
- `.pi/` is not in this repo's `.gitignore`, so a contributor running `node adapters/sync.mjs --agents pi` at the framework root writes an untracked `.pi/`. Either gitignore it or refuse Pi writes on the framework root.

### S6: Treat the compaction `customInstructions` as an LLM prompt

The summary instructions decide what survives compaction. The plan skill's mandatory content asks for a `[REUSE]` prompt-engineering task (`eversis-engineer-prompt`) for LLM application prompts. Add one after Task 1.2, or state why it is not needed.

## Iteration 2 — New Findings

### BLOCKERS

None.

### WARNINGS

#### N-W1: The continuation message can start an unsolicited run after the agent has already stopped (gate safety)

Task 1.2 (`plan.md:185`) sends `CONTINUATION_MESSAGE` on every successful compaction. `turn_end` also fires on the **last** turn of a run, when the assistant replies without tool calls. In this framework that is exactly the turn where the agent stops at a human gate ("Next gate: Awaiting approval before code"), asks a question, or finishes.

If that final turn crosses 50%, the extension does three things:

1. It compacts. The abort is a no-op at that point.
2. It injects a **user-role** message: "resume the current plan task".
3. Through `sendUserMessage` → `_startRun` (`agent-session.js:1693`), it starts a new run that nobody asked for.

The message text says "do not pass an open human gate". Even so, a user-role "resume" right after a gate stop is the kind of ambiguous reply that the gate-closing rule (`engineering-manager.md` self-check; skill `eversis-orchestrating-implementation`) asks agents not to treat as approval. It also spends a model call when no work was interrupted.

The fake-context test in the Task 1.2 DoD (`:194`) asserts exactly one `sendUserMessage` per crossing. As written, it would lock this behaviour in.

**Plan change (Task 1.2):**

- Record whether the interrupted turn would have continued: `event.toolResults.length > 0`, meaning the assistant issued tool calls and the loop was going to make another request.
- Send `CONTINUATION_MESSAGE` from `onComplete` only in that case. When it is false, compact without any continuation and show a UI notice only.
- Use `ctx.isIdle()` to choose between a plain send and `deliverAs: "followUp"`.
- Add to the DoD: "final-turn crossing (no tool results) → one `compact()`, zero `sendUserMessage`".

### SUGGESTIONS

#### N-S1: Narrow `$` neutralisation to Pi's actual substitution pattern

Task 1.1 replaces `$` before **any** `${`, and its DoD regex `/\$(\d|@|\{|ARGUMENTS)/` (`plan.md:170`) also applies to the generator-written SSOT pointer. Local mode resolves `--framework-prefix` to the literal `${AGENT_COLLECTIONS_HOME}` (`link-framework.sh:180`), so the pointer would become `＄{AGENT_COLLECTIONS_HOME}/.ai/prompts/…`. That is no longer a recognisable env-var path.

Pi only substitutes `${N:-…}`, `${@…}`, `${ARGUMENTS:-…}`, `$N`, `$@` and `$ARGUMENTS` (`prompt-templates.js:63`). Neutralise exactly that pattern, or exempt the SSOT pointer line, and align the DoD regex.

#### N-S2: Detect seeds made from older stack templates

The unmodified-seed check is a byte compare against the current `templates/eversis-project-stack.example.mdc`. That template has changed in at least two commits (`3047412`, `eb6b332`). A consumer seeded from an older version would count as "customised", and its `<!-- TODO -->` placeholder text would go always-on.

Also skip the overlay when the file still contains the template sentinels: the `description: "Project stack — replace with your product stack…"` front matter, or `<!-- TODO` placeholders.

#### N-S3: State the fallback for Task 5.1

If Pi has no CLI command that only loads resources, Task 5.1 could run Pi's own `dist/utils/frontmatter.js`, `dist/core/prompt-templates.js` and `dist/core/skills.js` loaders through `node -e` against the smoke target. That needs no new dependency and keeps the check automated rather than moving it to QA.

## Verdict

`APPROVED` (iteration 2): there are no blockers or execution-critical decisions left open. **N-W1** has a small, local fix: one condition in Task 1.2 and one DoD line. Apply it before Phase 1 is implemented, and record it in the plan Changelog. N-S1 – N-S3 are optional.

Iteration 1 verdict: `REVISIONS NEEDED`.
