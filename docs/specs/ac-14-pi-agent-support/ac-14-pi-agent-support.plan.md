# AC-14 pi agent support - Implementation Plan

## Task Details

| Field            | Value |
| ---------------- | ----- |
| Jira ID          | AC-14 |
| Title            | Add full Pi Agent support |
| Description      | Ship Pi as a third full agent adapter generated from `.ai/` SSOT: installer choice, rules / skills / prompt templates in a Pi session, MCP, and a Pi-only ~50% context budget. Cursor / Claude Code keep "no window-fill trigger". |
| Priority         | Medium |
| Related Research | [`ac-14-pi-agent-support.research.md`](./ac-14-pi-agent-support.research.md) |

## Wildly Important Goal

**Goal**: A person who runs the installer with `--agents=pi` (alone or with Cursor / Claude) gets a working Pi setup — always-on rules, role rules, all framework skills (50 today; counts are computed, never hard-coded), 28 slash commands, `eversis-collections` MCP, and compaction at ~50% of the context window — regenerated from `.ai/` by `adapters/sync.mjs`.

**Success Measure**: `npm run installer:smoke` passes new cases for `--agents=pi` alone (vendored copy), `--agents=cursor,pi`, Pi deselect, upgrade, an induced Pi failure with `--agents=cursor,pi` that leaves Cursor output intact, an induced Pi failure with `--agents=pi` alone, and a malformed `.pi/mcp.json`; `node adapters/sync.mjs --check` stays green; Pi 1.4.0 lists the generated prompts and skills when started in a smoke-installed project.

**Do NOT touch / do NOT add**:
- `.ai/rules/**` and `.ai/skills/**` bodies — in particular rule 14 of `eversis-orchestrating-implementation` (no window-percent text, no Pi mention; AC6).
- Pi ignore file / `.piignore`-style exclusions (AC-113), subscription sign-in or model settings (AC-111), token-economy trimming of always-on rules (AC-112), sandbox / isolated workspace (AC-114).
- OpenCode adapter changes; Pi themes, providers, model catalogs.
- New npm dependencies (generator and extension are zero-dependency; extension uses `import type` only).
- Committing a `.pi/` tree into this framework repository (Pi is opt-in; self-host default stays `cursor,claude`).

## Proposed Solution

Port the proven sternik-kariery consumer generator (`scripts/gen-pi-adapter.mjs` + `pi-rule-map.yaml`) into the framework as a native adapter `adapters/pi/`, wired into `adapters/sync.mjs` and the installer exactly like Claude, with four differences driven by the approved research answers:

1. **Skills (Q1):** the installer mirrors `.ai/skills/eversis-*` into `.pi/skills/` (symlink or copy, stale-prune, deselect-prune) — the same contract as `.claude/skills/` and `.cursor/skills/`.
2. **Role rules (Q2):** role rules that are not already framework skills become `.pi/skills/eversis-rule-<name>/SKILL.md` (distinct id → no collision). `fine-handoff` is **not** emitted as a role skill because `.pi/skills/eversis-fine-handoff/` (framework skill) is already mirrored. Always-on rules go to `.pi/APPEND_SYSTEM.md`, whose header maps the rule ids used in prompts (`eversis-engineering-manager`, …) to the Pi skill names.
3. **Context budget (Q3):** a framework-shipped project extension `.pi/extensions/eversis-context-budget.ts` compacts on `turn_end` once `ctx.getContextUsage().percent` crosses the threshold (default 50, env override), with summary instructions that keep the active plan path, current plan task and latest `CHECKPOINT:` row. Pi's `ctx.compact()` **aborts the running agent turn and never resumes it** (`dist/core/agent-session.js` `compact()` → `abort()`), so on successful compaction the extension sends one continuation user message (`pi.sendUserMessage`, `expandPromptTemplates: false`) telling the agent to resume the current plan task from the summary. `.pi/settings.json` is seeded once (consumer-owned afterwards).
4. **Failure isolation (Q5):** the installer runs **everything Pi-specific** — generation, skills mirror, deselect pruning and the `.pi/mcp.json` merge — as an isolated Pi stage. A Pi failure sets `PI_STAGE_FAILED=true` (it does **not** edit `SELECTED_AGENTS`, whose empty value defaults to `cursor` across the installer), prints a dedicated `pi` failure with its cause, keeps other agents' output, omits `pi` from the recorded selection, shows a "completed with failures (pi)" headline, and exits 1 at the end. When Pi is the only selected agent the run exits 1 right after the failed Pi stage. A missing `pi` CLI is a summary warning only.

Project-stack overlay (Q4): when the target has `.cursor/rules/eversis-project-stack.mdc` **and its content differs from the unmodified framework template** (`templates/eversis-project-stack.example.mdc`), its body (front matter stripped) is appended to `APPEND_SYSTEM.md`; an unmodified seed is skipped so template placeholder text never becomes always-on.

Prompt bodies are made Pi-safe: front-matter values are written as JSON-quoted strings (Pi's YAML parser rejects unquoted values containing `": "`, which silently drops 4 of the 28 prompts in the benchmark), and Pi's template substitution (`$<digit>`, `$@`, `$ARGUMENTS`, `${…}` — no escape syntax exists) is neutralised in SSOT body text by replacing that `$` with `＄` (U+FF04), leaving only the final `**User input for this run:** $ARGUMENTS` line live. SSOT pointers in prompts use `--framework-prefix` (Q7). `CLAUDE.md` double-loading (Q6) is documented, not changed.

```text
.ai/rules/** ──(adapters/pi/rule-map.yaml)──▶ adapters/pi/generate.mjs ─┬─▶ .pi/APPEND_SYSTEM.md             (always-on + stack overlay)
.ai/prompts/{public,internal}/eversis-*.md ─────────────────────────────┼─▶ .pi/prompts/eversis-*.md          (28, $ARGUMENTS)
adapters/pi/assets/ ────────────────────────────────────────────────────┼─▶ .pi/skills/eversis-rule-*/SKILL.md (role rules)
                                                                        ├─▶ .pi/extensions/eversis-context-budget.ts
                                                                        └─▶ .pi/settings.json                  (seed once)
.ai/skills/eversis-* ──(installer mirror)───────────────────────────────────▶ .pi/skills/eversis-*/            (50)
templates/mcp.json ──(mcp-merge, MCP_HOST=pi)────────────────────────────────▶ .pi/mcp.json
```

Pi surface contract (verified, Pi 1.4.0): project `.pi/` loads after project trust; prompts take `description` / `argument-hint` front matter and `$ARGUMENTS`, and substitute `$<digit>`, `$@`, `${…}` anywhere in the body with no escape; skills follow Agent Skills (`name` ≤ 64, `description` ≤ 1024; first-discovered wins on collision); extensions are `.ts` loaded by jiti; `ctx.compact()` aborts the current run without resuming; MCP is built-in with `mcpServers` format; `env` / `headers` expand `${VAR}`, `command` / `args` do not.

## Current Implementation Analysis

### Already Implemented

- Benchmark generator - `sternik-kariery/scripts/gen-pi-adapter.mjs` - YAML mini-parser, front-matter strip, executable-section extraction, `emit()` with `--check`, marker-gated orphan cleanup
- Claude command generator - `adapters/claude/generate-commands.mjs` - repo-root discovery, `--out`, `--framework-prefix`, deny-list, GENERATED marker idiom
- Sync runner - `adapters/sync.mjs` - `runGenerator`, `parseArgs`, `runWrite`, `runCheck`
- Skills mirror (installer) - `scripts/lib/setup-agent-collections/link-framework.sh` - `_link_claude_skills`, `_link_cursor_skills`, `_make_symlink`, `_prune_marker_gated_dir`, `_resolve_framework_prefix`
- MCP merge - `scripts/lib/setup-agent-collections/mcp-merge.{sh,mjs}` - per-host merge, preserve mode, vendored wrapper `templates/run-eversis-collections-mcp.sh`
- Upgrade detection - `scripts/lib/setup-agent-collections/upgrade.sh` - `detect_installed_agents`
- Pi compaction example - Pi `examples/extensions/trigger-compact.ts` - `turn_end` + `ctx.getContextUsage()` + `ctx.compact()`
- Rule 14 (no window trigger) - `.ai/skills/eversis-orchestrating-implementation/SKILL.md` - satisfies AC6 unchanged

### To Be Modified

- `adapters/sync.mjs` - accept `pi` agent id; run Pi generator last in `runWrite` when selected; `--check` covers Pi when `--agents` includes `pi`; usage text
- `scripts/lib/setup-agent-collections/agents.sh` + `agents-prompt.mjs` - `pi` in allow-list, checkbox, numbered menu
- `scripts/lib/setup-agent-collections/link-framework.sh` - separate Pi sync stage with failure isolation; generic skills-mirror helper used by Claude / Cursor / Pi; Pi deselect pruning
- `scripts/lib/setup-agent-collections/mcp-merge.sh` + `mcp-merge.mjs` - `pi` host → `.pi/mcp.json`; bash-locator `eversis-collections` entry; vendored wrapper also for Pi; drop `inputs`
- `scripts/lib/setup-agent-collections/upgrade.sh` - `detect_installed_agents` recognises Pi
- `scripts/lib/setup-agent-collections/summary.sh` - Pi line, next steps, Pi failure / CLI warning, deselect text
- `scripts/setup-agent-collections.sh` - Pi stage wiring, `PI_STAGE_FAILED` flag and deferred non-zero exit on Pi failure
- `scripts/lib/setup-agent-collections/vendor-sync-skew.sh` - probe must also cover the `pi` agent id / `adapters/pi/` so an older vendored pin is realigned instead of rejecting `--agents pi`
- `scripts/setup-agent-collections.test.sh`, `scripts/lib/setup-agent-collections/{mcp-merge,vendor-sync-skew}.test.sh` - new cases
- Docs: `adapters/README.md`, `docs/architecture/adapter-mapping.md`, `README.md`, `AGENTS.md`, `website/docs/intro.md`, `website/docs/getting-started/{installation.mdx,start-here.mdx,prerequisites.mdx,mcp-setup.mdx}`, `website/docs/reference/framework-reference.md`, `website/docs/reference/integrations/eversis-collections.md`, `CHANGELOG.md`

### To Be Created

- `adapters/pi/generate.mjs` - Pi generator (APPEND_SYSTEM, role skills, prompts, extension, settings seed, orphan cleanup, `--check`)
- `adapters/pi/rule-map.yaml` - `append_system` / `skill` targets for the 7 framework rules
- `adapters/pi/assets/eversis-context-budget.ts` - context-budget extension (source copied by the generator)
- `adapters/pi/assets/settings.json` - seed for `.pi/settings.json`
- `adapters/pi/generate.test.mjs`, `adapters/pi/context-budget.test.mjs` - `node:test` suites
- `adapters/pi/README.md` - adapter doc (surfaces, trust, `/reload`, CLAUDE.md note)

## Open Questions

| # | Question | Answer | Status |
|---|---|---|---|
| 1 | Skills surface | Mirror `.ai/skills/eversis-*` into `.pi/skills/` like Claude / Cursor | ✅ Resolved (research Q1) |
| 2 | Role-rule name collision | Distinct `eversis-rule-<name>` ids; no `fine-handoff` role skill | ✅ Resolved (research Q2) |
| 3 | ~50% budget mechanism | Project extension on `turn_end` using `getContextUsage().percent` + `compact()` | ✅ Resolved (research Q3) |
| 4 | Consumer overlays | Append `eversis-project-stack` when present; nothing else | ✅ Resolved (research Q4) |
| 5 | Failure isolation | Separate Pi stage; dedicated failure; others kept; non-zero exit; missing CLI = warning | ✅ Resolved (research Q5) |
| 6 | `CLAUDE.md` double-load | Document only; trimming → AC-112 | ✅ Resolved (research Q6) |
| 7 | SSOT pointer prefix | Reuse `--framework-prefix` | ✅ Resolved (research Q7) |
| 8 | Which rules are always-on vs role skills? | Always-on: `agent-core`, `testing-and-terminal`, `accessibility` (UI note). Role skills: `engineering-manager`, `code-reviewer`, `spec-driven-development`. `fine-handoff` → framework skill mirror only. Mirrors benchmark map | ✅ Resolved (plan) |

## Technical Context

### Project Instructions

- `CLAUDE.md` / `AGENTS.md` — Agent Collections lifecycle; hard limits: stay in plan scope, never shorten doc comments, no new package-manager deps.
- `adapters/README.md` + `docs/architecture/adapter-mapping.md` — adapters **consume** `.ai/`; never edit `.ai/rules` for host packaging; generated files carry a GENERATED marker and are pruned only when the marker matches.
- `docs/context/agent-collections/` — no component covers adapters; `readiness-contract` unaffected.

### Architecture & Patterns

- Generators are zero-dependency ESM (`node:fs`, `node:path`, `node:url`), find repo root by `.ai/` + `adapters/`, accept `--out <dir>` and `--framework-prefix <path>`, support `--check` (no writes, exit 1 on drift).
- GENERATED marker per generator (`<!-- GENERATED by adapters/pi/generate.mjs — do not edit; re-run the generator -->`; `//` comment form in `.ts`). Orphan cleanup and installer deselect pruning are **marker-gated** — hand-made files are never removed.
- Consumer-owned files are seeded once and never overwritten (`_seed_stack_rule` pattern) → `.pi/settings.json`.
- Installer libs: `scripts/lib/setup-agent-collections/<area>.sh` sourced by `setup-agent-collections.sh`; agent guards use `echo ",${SELECTED_AGENTS}," | grep -q ',pi,'`; steps report with `record_ok` / `record_fail`.
- Host config files (`.cursor/mcp.json`, `.mcp.json`, now `.pi/mcp.json`) are left in place on deselect (convention, `setup-agent-collections.test.sh` note).

### Tech Stack

- Node ≥ 18 for installer/generators (repo `engines` in consumers; dev machine Node 24.16.0); bash (macOS + Linux; Windows via junction in `_make_symlink`).
- Pi target: `@earendil-works/pi-coding-agent` 1.4.0 (`pi --version`), docs in its `docs/` folder.
- npm scripts in root `package.json`: `sync:adapters`, `sync:adapters:check`, `installer:smoke`, `sync:website-docs[:check]`, `website:build`.

### Code Style & Standards

- Match surrounding style: generator JS uses double quotes + semicolons (`adapters/*/generate*.mjs`); installer `.mjs` libs use single quotes; bash uses `local`, `[[ ]]`, `log_info|log_ok|log_warn|die`.
- Header doc comment on every new script (purpose, usage, zero deps) like `adapters/claude/generate-commands.mjs`.
- Errors: generators `fail(message)` → stderr + exit 1 with the missing path named.

### Testing Patterns

- Installer smoke: `npm run installer:smoke` (`scripts/setup-agent-collections.test.sh`, temp targets, `--non-interactive --vendor=copy`).
- Lib tests: `bash scripts/lib/setup-agent-collections/mcp-merge.test.sh`, `upgrade-preserve.test.sh`.
- Adapter drift: `node adapters/sync.mjs --check` (+ `--agents pi --out <tmp>` for Pi).
- New unit tests: `node --test 'adapters/pi/*.test.mjs'` (a bare directory argument fails on Node 24 with "Cannot find module"). Importing the `.ts` extension in tests relies on native type stripping (Node ≥ 22.18; dev machine 24.16.0) — tests are dev-only, the installer keeps Node ≥ 18.
- Docs: `npm run sync:website-docs:check`, `npm run website:build`.
- No lint script in repo; `shellcheck` not installed — `bash -n` on changed `.sh` files.

### Database Patterns

- N/A

### Additional Context

- Pi loads `.pi/` only after **project trust**; `AGENTS.md` / `CLAUDE.md` load without trust. Users run `/reload` after a re-sync in an open session.
- `ctx.getContextUsage()` returns `undefined` when no model / window is known and `percent: null` right after compaction — treat both as "unknown"; the next known reading is compared as if the previous one were below the threshold (so a resumed session that starts above 50% still compacts once).
- `ctx.compact()` aborts the running turn and does not continue it — the extension must send the continuation message itself (`pi.sendUserMessage`).
- Project `.pi/APPEND_SYSTEM.md` replaces (not combines with) a user's `~/.pi/agent/APPEND_SYSTEM.md` — document in the Pi README.
- Benchmark reference: `/Users/piotrniemirski/Documents/repos/WUP/sternik-kariery` (`scripts/gen-pi-adapter.mjs`, `scripts/pi-rule-map.yaml`, `.pi/`).

## Implementation Plan

### Phase 1: Pi adapter generator

**Goal**: `.ai/` can be turned into a complete, drift-checkable, Pi-loadable `.pi/` tree without the installer.

**Description**: Create `adapters/pi/` from the benchmark generator, adapted to framework conventions (repo-root discovery, `--out`, `--framework-prefix`, Claude-style marker), the distinct role-skill ids, Pi-safe prompt output, the stack overlay, the extension and the settings seed.

**Verification:** `node --test 'adapters/pi/*.test.mjs'`; `node adapters/pi/generate.mjs --out "$TMP" && node adapters/pi/generate.mjs --out "$TMP" --check`

#### Task 1.1 - [CREATE] Pi rule map and generator

**Description**: Create `rule-map.yaml` (all 7 framework rules with the same `id` / `source` pairs as `adapters/claude/rule-map.yaml`; `target: append_system | skill | none`, optional `ui_note`, `description`, `skill_id`) and `generate.mjs` producing `.pi/APPEND_SYSTEM.md`, `.pi/skills/eversis-rule-*/SKILL.md`, `.pi/prompts/eversis-*.md`. Map: `append_system` = agent-core, testing-and-terminal, accessibility (`ui_note`); `skill` = engineering-manager, code-reviewer, spec-driven-development (`skill_id: eversis-rule-<name>`); `none` = fine-handoff (served by the mirrored framework skill). APPEND_SYSTEM header lists slash commands, skill locations and the rule-id → skill-name mapping (`eversis-engineering-manager` → `/skill:eversis-rule-engineering-manager`, `eversis-fine-handoff` → framework skill `eversis-fine-handoff`). Prompts: `description` from `prompt_description` front matter, `argument-hint`, SSOT pointer via `--framework-prefix`, executable section, trailing `**User input for this run:** $ARGUMENTS`; honour `adapters/claude/command-deny.yaml` (reuse the file, do not duplicate). **All front-matter values** (prompts and skills) are emitted as JSON-quoted strings. **Body neutralisation:** in every emitted prompt body (everything except the final `$ARGUMENTS` line) replace `$` with `＄` (U+FF04) only where it starts a pattern Pi substitutes (`dist/core/prompt-templates.js:63`: `$<digit>`, `$@`, `$ARGUMENTS`, `${…}`); the SSOT pointer line is excluded so local-mode `${AGENT_COLLECTIONS_HOME}` pointers stay readable. Stack overlay appended when `<out>/.cursor/rules/eversis-project-stack.mdc` exists **and** differs from `templates/eversis-project-stack.example.mdc` (byte compare after newline normalisation) **and** carries none of the template's placeholder markers (e.g. `<!-- TODO`, the "replace with your product stack" description) — this also catches seeds from older template versions; otherwise log a one-line hint.

**Files:** `adapters/pi/rule-map.yaml` (create), `adapters/pi/generate.mjs` (create)

**Definition of Done**:

- [x] Generates one prompt per non-denied `.ai/prompts/{public,internal}/eversis-*.md` (28 today), 3 role skills, 1 `APPEND_SYSTEM.md` containing agent-core, testing-and-terminal and accessibility (with UI note)
- [x] No generated skill id equals any `.ai/skills/eversis-*` directory name (asserted at generation time → `fail`)
- [x] Role skill `name` ≤ 64 chars and `description` ≤ 1024 chars (asserted)
- [x] Every emitted front matter parses as YAML with the expected keys, including SSOT descriptions that contain `": "`
- [x] No emitted prompt body matches Pi's substitution pattern outside the final input line and the SSOT pointer line
- [x] `--check` exits 1 and names each drifted / orphan file; exits 0 on a fresh tree
- [x] Orphan cleanup removes only files with the Pi GENERATED marker in `.pi/prompts/` and `.pi/skills/eversis-rule-*`
- [x] Run `node adapters/pi/generate.mjs --out "$TMP" && node adapters/pi/generate.mjs --out "$TMP" --check`

**Stop Rule:** If any `.ai/prompts` file lacks `prompt_description` and has no usable first line, stop and report instead of inventing descriptions.

**Clues**: Port `parseMap`, `stripFrontMatterAndMarker`, `emit`, `cleanupOrphans` from the benchmark; take `findRepoRoot`, arg parsing and `--framework-prefix` handling from `adapters/claude/generate-commands.mjs`. The benchmark's GENERATED marker text must change to the adapter path. Affected SSOT descriptions with `": "`: `eversis-create-custom-instructions`, `eversis-review-ui`, `eversis-create-custom-skill`, `eversis-review-codebase` (line 6 each); dollar amounts in `eversis-analyze-aws-costs` (~170) and `eversis-analyze-gcp-costs` (~175). Pi's template substitution: `dist/core/prompt-templates.js:62-83`.

#### Task 1.2 - [CREATE] Context-budget extension and settings seed

**Description**: Create the extension asset and settings seed; generator copies the extension to `.pi/extensions/eversis-context-budget.ts` (marker-gated, regenerated) and seeds `.pi/settings.json` only when absent. Extension exports:
- `resolveThreshold(env)` — integer 1–95 from `EVERSIS_CONTEXT_BUDGET_PERCENT`, else 50.
- `shouldCompact(previousPercent, currentPercent, threshold)` — true when `currentPercent >= threshold` and `previousPercent` is below the threshold **or unknown** (`null` / `undefined`); false when `currentPercent` is unknown.
- `CONTINUATION_MESSAGE` and `COMPACTION_INSTRUCTIONS` constants.
- default factory: on `turn_end` read `ctx.getContextUsage()` (may be `undefined`), track the last known percent, and when `shouldCompact` and no compaction is in flight call `ctx.compact({ customInstructions: COMPACTION_INSTRUCTIONS, onComplete, onError })`. The handler records whether the crossing turn had tool calls (`event.toolResults.length > 0`). `onComplete` sends **one** continuation via `pi.sendUserMessage(CONTINUATION_MESSAGE)` — plain send when `ctx.isIdle()`, else `deliverAs: "followUp"` — **only when the crossing turn had tool results** (the agent was mid-task and the abort interrupted it). A crossing on a final turn (no tool results: the agent finished, asked a question or stopped at a human gate) compacts and shows a UI notice only, so no unrequested run starts and nothing can be read as gate approval; `onError` notifies and clears the in-flight flag. After compaction the tracked percent resets to unknown. UI notify only when `ctx.hasUI`. No network, file writes or shell.
Compaction instructions keep: active `docs/specs/**/*.plan.md` path, current plan task id and state, latest `CHECKPOINT:` / `RESUMED:` rows, the open human gate, and the next step. Continuation message: resume the current plan task from the compaction summary, re-read the plan file before editing, do not restart finished tasks, do not pass an open human gate. Settings seed: `$schema` only (compaction stays enabled by default).

**Files:** `adapters/pi/assets/eversis-context-budget.ts` (create), `adapters/pi/assets/settings.json` (create), `adapters/pi/generate.mjs` (modify — created in Task 1.1)

**Definition of Done**:

- [x] Extension uses `import type` only from `@earendil-works/pi-coding-agent` (no runtime dependency)
- [x] `shouldCompact` covers: below → above fires; above → above does not; unknown → above fires; any → unknown does not; threshold override and invalid override fall back to 50
- [x] Factory test with a fake `pi` / `ctx`: mid-task crossing (tool results present) → exactly one `compact()` call and, on `onComplete`, exactly one `sendUserMessage`; final-turn crossing (no tool results) → one `compact()`, zero `sendUserMessage`; a second `turn_end` while in flight does not call `compact()` again; `onError` sends no continuation
- [x] Existing `.pi/settings.json` is byte-identical after generation; `--check` does not report it
- [x] Run `node --test 'adapters/pi/*.test.mjs'`

**Clues**: Pi `examples/extensions/trigger-compact.ts`; `docs/extensions.md` (`turn_end`, `ctx.compact`, `ctx.getContextUsage`); `dist/core/agent-session.js` `compact()` calls `abort()` first; `pi.sendUserMessage` options in `dist/core/extensions/types.d.ts` (~line 1267).

#### Task 1.3 - [CREATE] Generator and extension tests

**Description**: `node:test` suites: generator into a temp dir (computed counts, ids, marker, YAML front-matter parse incl. a `": "` fixture, `$` neutralisation regex, `--check` drift + orphan detection, hand-made file in `.pi/prompts/` survives cleanup, settings seed preserved, stack overlay on (customised) / off (absent or unmodified template), `--framework-prefix` in SSOT pointer); extension `resolveThreshold` / `shouldCompact` tables and fake-context factory test. YAML parsing in tests uses a minimal front-matter check (keys + JSON-string values via `JSON.parse`) — no new dependency.

**Files:** `adapters/pi/generate.test.mjs` (create), `adapters/pi/context-budget.test.mjs` (create)

**Definition of Done**:

- [x] Both suites pass
- [x] Run `node --test 'adapters/pi/*.test.mjs'`

### Phase 2: Sync integration

**Goal**: `adapters/sync.mjs --agents …,pi` produces and checks Pi output alongside the other adapters.

**Description**: Register `pi` in `sync.mjs` without changing defaults (`cursor,claude`).

**Verification:** `node adapters/sync.mjs --check`; `node adapters/sync.mjs --agents cursor,pi --out "$TMP"` then `node adapters/sync.mjs --check --agents cursor,pi --out "$TMP"`

#### Task 2.1 - [MODIFY] Register Pi in adapters/sync.mjs

**Description**: Allow `pi` in `--agents`; in `runWrite` run the Pi generator **last** (after Cursor / Claude / OpenCode) passing `--out` and `--framework-prefix`. In `runCheck`: when `--agents` is omitted keep today's behaviour exactly (Cursor + Claude); when given, check only the named agents — Cursor / Claude via the existing comparisons, Pi by delegating to `adapters/pi/generate.mjs --check --out <compareRoot>` (no temp-dir comparison, so the stack overlay is evaluated against the real target). Extend the id/source parity assertion to the Pi rule map (every Claude `id`/`source` pair present in the Pi map). Update usage text and header comment.

**Files:** `adapters/sync.mjs` (modify)

**Definition of Done**:

- [x] `node adapters/sync.mjs --check` output unchanged for this repo (no `.pi/` created here)
- [x] Pi generator failure exits non-zero **after** Cursor / Claude outputs are written
- [x] `--check --agents cursor,pi --out "$TMP"` passes on a fresh `cursor,pi` write and does not report missing Claude output
- [x] Run `node adapters/sync.mjs --check` and the `--out "$TMP"` write + check pair

### Phase 3: Installer support

**Goal**: The installer offers Pi, installs it, isolates every Pi failure and removes it cleanly on deselect.

**Description**: Wire Pi through agent selection, an isolated Pi stage (sync, skills mirror, pruning, MCP), vendor-pin probing, upgrade detection and summary.

**Verification:** `bash -n` on changed `.sh`; `bash scripts/lib/setup-agent-collections/mcp-merge.test.sh`; `bash scripts/lib/setup-agent-collections/vendor-sync-skew.test.sh`; `npm run installer:smoke`

#### Task 3.1 - [MODIFY] Agent selection

**Description**: Add `pi` to `_validate_agents`, the checkbox (`pi — Pi coding agent (pi.dev)`), and numbered menu options (append "Pi only" and "Cursor + Claude + Pi"; existing option numbers 1–5 unchanged); update header help (`--agents LIST`).

**Files:** `scripts/lib/setup-agent-collections/agents.sh` (modify), `scripts/lib/setup-agent-collections/agents-prompt.mjs` (modify), `scripts/setup-agent-collections.sh` (modify — help text)

**Definition of Done**:

- [x] `--agents=pi`, `--agents=cursor,claude,pi` validate; unknown ids still fail with the allowed list incl. `pi`
- [x] Run `bash -n scripts/lib/setup-agent-collections/agents.sh`

#### Task 3.2 - [MODIFY] Isolated Pi stage: sync, skills mirror, pruning

**Description**:
- `_run_adapter_sync` passes only the non-Pi agents; when none remain (Pi-only install) it is **skipped** (never called with an empty `--agents`).
- Replace the bodies of `_link_claude_skills` / `_link_cursor_skills` with one `_link_agent_skills <agent> <dst-rel>` helper (identical behaviour + log text); its stale-prune skips `eversis-rule-*` entries; it returns non-zero on any failed link / copy.
- New `run_pi_stage` (in `link-framework.sh`, called from `setup-agent-collections.sh` after `link_framework_files`): when `pi` is selected → `_run_pi_adapter_sync` (same prefix handling, `--agents pi`, returns non-zero instead of `die`) then `_link_agent_skills pi .pi/skills`; when not selected → `_prune_deselected_pi` (marker-gated removal of `.pi/APPEND_SYSTEM.md`, `.pi/prompts/eversis-*.md`, `.pi/skills/eversis-rule-*`, `.pi/extensions/eversis-context-budget.ts`, and `eversis-*` mirror entries in `.pi/skills/`; keep `.pi/settings.json` and `.pi/mcp.json`). Every sub-step's return code is checked explicitly (`set -e` is inactive inside `||`).
- On failure: `PI_STAGE_FAILED=true` + `PI_STAGE_FAILURE_REASON`, `record_fail "pi"`, clear log line naming the cause. `SELECTED_AGENTS` is **not** modified. If `pi` is the only selected agent: print the partial-failure report and exit 1 immediately. Otherwise continue; later Pi-specific steps (Pi MCP merge) are skipped when `PI_STAGE_FAILED=true`; `write_install_selection` omits `pi` when `PI_STAGE_FAILED=true`; after `print_summary` exit 1.

**Files:** `scripts/lib/setup-agent-collections/link-framework.sh` (modify), `scripts/lib/setup-agent-collections/selection.sh` (modify), `scripts/setup-agent-collections.sh` (modify)

**Definition of Done**:

- [x] Existing Claude / Cursor smoke assertions pass unchanged (refactor is behaviour-preserving)
- [x] Pi failure with `cursor,pi` → `pi` failure line; `.cursor/` output present; selection agents `["cursor"]`; exit 1
- [x] Pi failure with `pi` alone → exit 1; no `.cursor/` generated output; no selection recording `cursor`
- [x] Pi deselect removes only marker-gated / `eversis-*` Pi files; role skills survive the skills-mirror stale-prune
- [x] Run `bash -n` on changed files and `npm run installer:smoke`

**Stop Rule:** If the skills-helper refactor changes any existing smoke assertion, revert to a separate `_link_pi_skills` function and note it in the Changelog.

**Clues**: Empty `SELECTED_AGENTS` defaults to `cursor` at `link-framework.sh:44,98,124,278`, `mcp-merge.sh:33`, `ignore-triad.sh:9`, `selection.sh:20`, `summary.sh:10` — this is why the failure is a flag, not a list edit. `_seed_stack_rule` still seeds `.cursor/rules/eversis-project-stack.mdc` on Pi-only installs (unchanged); the generator skips the unmodified seed (Task 1.1).

#### Task 3.3 - [MODIFY] Pi MCP merge (isolated)

**Description**: `merge_mcp_json` handles Pi in its own guarded call (`MCP_HOST=pi`, `.pi/mcp.json`): skipped when `PI_STAGE_FAILED=true`; a merge / validation failure for Pi (e.g. malformed existing `.pi/mcp.json`) sets `PI_STAGE_FAILED` + reason and `record_fail "pi"` instead of `die`, leaving Cursor / Claude files written. In `mcp-merge.mjs` add a **Pi-specific** branch (not the Claude rewrite): `eversis-collections` is a `bash -c` locator that walks up from `$PWD` to the nearest directory containing `.pi/` (project root) — vendored → exec `<root>/scripts/run-eversis-collections-mcp.sh` (wrapper copied for Pi too — extend the `host == claude` condition); local → `CONSUMER_PROJECT_ROOT=<root> exec docker compose -f "${AGENT_COLLECTIONS_HOME:-<resolved>}/docker-compose.yml" run --rm -T eversis-collections` where the `${…}` lives **inside** the bash script string evaluated by bash, not as a Pi-expanded token. Other catalog servers: copy as-is; drop `inputs`; after building, fail the Pi merge if any `command` / `args` value still contains `${workspaceFolder}`, `${env:` or `CLAUDE_PROJECT_DIR` (bash-script strings for `eversis-collections` are exempt from the generic `${` check only for the `AGENT_COLLECTIONS_HOME` default).

**Files:** `scripts/lib/setup-agent-collections/mcp-merge.sh` (modify), `scripts/lib/setup-agent-collections/mcp-merge.mjs` (modify), `scripts/lib/setup-agent-collections/mcp-merge.test.sh` (modify)

**Definition of Done**:

- [x] New test cases: Pi vendored and Pi local produce valid JSON with the expected `eversis-collections` shape, no `inputs`, no `${workspaceFolder}` / `${env:` / `CLAUDE_PROJECT_DIR`
- [x] Malformed existing `.pi/mcp.json` → Pi failure recorded, `.cursor/mcp.json` still written, run exits 1 at the end
- [x] Existing Cursor / Claude cases unchanged
- [x] Run `bash scripts/lib/setup-agent-collections/mcp-merge.test.sh`

#### Task 3.4 - [MODIFY] Vendor-pin probe for the Pi agent id

**Description**: `vendor-sync-skew.sh` currently probes only CLI flag names; extend the probe so a vendored pin whose `adapters/sync.mjs` rejects `--agents pi` (or lacks `adapters/pi/generate.mjs`) is treated as skewed and realigned like today's flag skew.

**Files:** `scripts/lib/setup-agent-collections/vendor-sync-skew.sh` (modify), `scripts/lib/setup-agent-collections/vendor-sync-skew.test.sh` (modify)

**Definition of Done**:

- [x] New test case: old pin without Pi + `--agents=pi` → realigned (or clear error when realignment is not possible), never a raw `unknown agent id: pi`
- [x] Run `bash scripts/lib/setup-agent-collections/vendor-sync-skew.test.sh`

#### Task 3.5 - [MODIFY] Upgrade detection and summary

**Description**: `detect_installed_agents` adds `pi` when `.pi/APPEND_SYSTEM.md` carries the Pi marker. Summary: headline "agent-collections setup completed with failures (pi)" when `PI_STAGE_FAILED=true` (reason shown); Pi next steps (start `pi` in the project, grant project trust, `/reload` after re-sync, customise the project-stack file to have it appended, keep a root `AGENTS.md` so Pi does not also load `CLAUDE.md`); warning when `pi` CLI is not on `PATH`; deselect paragraph names Pi surfaces.

**Files:** `scripts/lib/setup-agent-collections/upgrade.sh` (modify), `scripts/lib/setup-agent-collections/summary.sh` (modify)

**Definition of Done**:

- [x] `--upgrade` on a Pi install keeps `pi` selected
- [x] Missing `pi` CLI yields a warning, exit 0
- [x] Run `bash -n` on both files and `npm run installer:smoke`

#### Task 3.6 - [MODIFY] Installer smoke coverage

**Description**: Add smoke cases: (a) `--agents=pi --vendor=copy` → `.pi/APPEND_SYSTEM.md`, prompt count = non-denied SSOT prompt count, 3 role skills, `.pi/skills/` mirror parity with `.ai/skills/eversis-*` (computed), extension, settings seed, `.pi/mcp.json`, no `.cursor/commands` / `.claude/` generated output, selection `["pi"]`; (b) `--agents=cursor,pi`; (c) re-run with `--agents=cursor` prunes Pi generated files, keeps `.pi/settings.json` and `.pi/mcp.json`; (d) induced generation failure — pre-create `<target>/.pi` as a regular file — with `--agents=cursor,pi`: exit 1, `pi` failure in output, Cursor output present, selection `["cursor"]`; (e) same induced failure with `--agents=pi` alone: exit 1, no selection listing `cursor`; (f) malformed `<target>/.pi/mcp.json` with `--agents=cursor,pi`: exit 1, `pi` failure, `.cursor/mcp.json` written; (g) `--upgrade` keeps Pi.

**Files:** `scripts/setup-agent-collections.test.sh` (modify)

**Definition of Done**:

- [x] All new and existing smoke cases pass
- [x] Run `npm run installer:smoke`

### Phase 4: Documentation

**Goal**: Readers see Pi as a supported agent and what its install provides (AC2).

**Description**: Delegated to Repo Docs Writer (`eversis-repo-docs-writer`). Docs say what is installed, project trust, `/reload`, the ~50% budget (Pi-only, why Cursor / Claude differ, continuation after compaction), MCP (`.pi/mcp.json`, `pi mcp list`), `CLAUDE.md` note, and that ignore files / subscription / sandbox come in AC-111 – AC-114.

**Verification:** `npm run sync:website-docs:check`; `npm run website:changelog:check`; `npm run website:build`

#### Task 4.1 - [CREATE] adapters/pi/README.md

**Files:** `adapters/pi/README.md` (create)

**Definition of Done**:

- [x] Lists every emitted surface, generator usage, markers, trust / reload, budget env var, `$`→`＄` neutralisation, stack-overlay rule
- [x] Notes: project `APPEND_SYSTEM.md` replaces a user-level one; the extension's `import type` may need excluding from a consumer's TS / ESLint config; review the extension before granting trust
- [x] Run `npm run sync:website-docs:check`

#### Task 4.2 - [MODIFY] Architecture and adapter docs

**Description**: `docs/architecture/adapter-mapping.md`: emit-matrix row, new "Pi adapter mapping" section, maturity `shipped`, §9 checklist line. `adapters/README.md`: per-adapter table + sync note.

**Files:** `docs/architecture/adapter-mapping.md` (modify), `adapters/README.md` (modify)

**Definition of Done**:

- [x] Pi listed with emitted paths; OpenCode text unchanged
- [x] Run `npm run sync:website-docs:check`

#### Task 4.3 - [MODIFY] Public docs and changelog

**Description**: Name Pi as a supported agent and the install choice in `README.md`, `AGENTS.md`, `website/docs/intro.md`, `website/docs/getting-started/{installation.mdx,start-here.mdx,prerequisites.mdx}` (Pi CLI as an optional prerequisite), `website/docs/getting-started/mcp-setup.mdx` (Pi tab: `.pi/mcp.json`, project trust, `pi mcp list`), `website/docs/reference/integrations/eversis-collections.md` (per-host list ~226-227), `website/docs/reference/framework-reference.md`; `CHANGELOG.md` Unreleased entry (AC-14); run `website:changelog:sync` if the changelog page is generated.

**Files:** `README.md`, `AGENTS.md`, `website/docs/intro.md`, `website/docs/getting-started/installation.mdx`, `website/docs/getting-started/start-here.mdx`, `website/docs/getting-started/prerequisites.mdx`, `website/docs/getting-started/mcp-setup.mdx`, `website/docs/reference/integrations/eversis-collections.md`, `website/docs/reference/framework-reference.md`, `CHANGELOG.md` (modify)

**Definition of Done**:

- [x] Every page that lists supported agents or per-host MCP setup lists Pi and states what its install provides
- [x] Run `npm run website:changelog:check` and `npm run website:build`

**Stop Rule:** Pages listing agents only as migration history (`website/docs/advanced/migration-from-cursor-collections.md`, `isolation.md`) are not changed unless they claim a complete supported-agent list.

### Phase 5: Code Review

**Goal**: Independent verification that AC1–AC7 hold and the hard limits are respected.

**Description**: Final verification of the full implementation. This phase is mandatory and always comes last.

**Verification:** `node --test 'adapters/pi/*.test.mjs'`; `node adapters/sync.mjs --check`; `bash scripts/lib/setup-agent-collections/mcp-merge.test.sh`; `bash scripts/lib/setup-agent-collections/vendor-sync-skew.test.sh`; `npm run installer:smoke`; `npm run website:build`

#### Task 5.1 - [REUSE] Automated Pi load check

**Description**: In a smoke-installed temp project (`--agents=pi --vendor=copy`), use Pi's own CLI to confirm the generated tree loads without warnings — trust granted non-interactively (e.g. `pi --approve`; confirm the exact flag in Pi `docs/cli.md`), resource / skill / prompt / extension diagnostics, and `pi mcp list` for `.pi/mcp.json` parsing. No model call is required; if a check would need a model, use a command that only loads resources. Record the commands and output in the Changelog.

**Files:** none (verification only)

**Definition of Done**:

- [x] No skill-collision, malformed-front-matter, prompt-template or extension-load warnings for the generated tree; all 28 prompts visible
- [x] `pi mcp list` parses `.pi/mcp.json` (connection state of Docker-backed servers is informational)
- [x] Result documented in Changelog

**Stop Rule:** If Pi offers no non-interactive CLI to list loaded resources, drive Pi's own resource loaders from its installed `dist` via `node -e` instead; only if that also fails, record it and move the session check to the QA draft — never bypass or fake trust.

#### Task 5.2 - [REUSE] Code review by Code Reviewer

**Description**: Run **Code Reviewer** via `eversis-review.md` (separate context) against this plan, the research, and AC1–AC7, including a prompt-quality read of `COMPACTION_INSTRUCTIONS` / `CONTINUATION_MESSAGE`.

**Files:** all files from Phases 1–4 (reuse)

**Definition of Done**:

- [x] Run the Phase 5 verification commands
- [x] Code review passes with no blocking findings
- [x] Review outcome documented in Changelog

**Clues**: Risk areas — refactor of the shared skills-mirror helper; `PI_STAGE_FAILED` paths; MCP `bash -c` quoting; marker-gated pruning never deleting hand-made `.pi/` files; continuation after compaction; `.ai/` untouched (`git diff --stat -- .ai/` empty).

## Security Considerations

- Generated `.pi/extensions/*.ts` runs inside Pi with full user privileges once project trust is granted — keep it minimal (no network, no file writes, no shell), document it in the README so teams can review before trusting.
- `.pi/mcp.json` must not contain secrets; `bash -c` locator only executes the committed wrapper script or `docker compose` on the framework compose file.
- Deselect / orphan pruning is marker-gated so consumer-authored Pi files are never deleted.
- Heavy / secret file exclusion is **not** provided by AC-14 (AC-113) — state this in docs.

## Quality Assurance

- [x] AC1 — `--agents=pi` install: a Pi session lists `/eversis-*` prompts, framework skills, role-rule skills; APPEND_SYSTEM rules active
- [x] AC2 — README, AGENTS.md, website getting-started and adapter docs list Pi and what the install provides
- [x] AC3 — install without `pi`: no `.pi/` generated files; re-run without `pi` prunes them; Cursor / Claude unaffected
- [x] AC4 — induced Pi failure (generation or `.pi/mcp.json`), with other agents and alone: clear `pi` failure, exit 1, other agents' output intact, selection excludes `pi`
- [x] AC5 — extension compacts once on crossing 50% and resumes the interrupted task (`shouldCompact` + fake-context tests; Pi load check)
- [x] AC6 — `git diff -- .ai/` empty; rule 14 still says window fill is not a trigger
- [x] AC7 — generator + installer + sync check + docs shipped; no placeholder maturity

## Improvements (Out of Scope)

- Commit a Pi skills mirror / `.pi/` for framework self-host dogfooding (would need `.gitignore` and `--check` default changes).
- Package the context-budget extension as a Pi package (npm / git) instead of a copied file.
- Trim always-on rules for Pi (AC-112), Pi ignore file (AC-113), subscription sign-in (AC-111), isolated workspace (AC-114).
- CI job running `node adapters/sync.mjs --check --agents cursor,claude,pi --out <tmp>`.

## Human gates

1. ~~Approve research~~ — done (`Q1. Recommendation OK; Q2. Recommendation ok; Q3. Recommendation ok; Q4. Recommendation ok; Q5. Recommendation ok; Q6. Recommendation ok; Q7. Recommendation ok;`)
2. ~~Approve this plan~~ — done (`Najpierw przejdź przez eversis-review-plan i następnie implent`; plan review iteration 2 verdict APPROVED)
3. Implement → Review → Fine

## Changelog

| Date | Change Description |
| ---------- | -------------------- |
| 2026-10-30 | Initial plan created from approved research (Q1–Q7 recommendations accepted). |
| 2026-10-30 | Revised after plan review iteration 1 (REVISIONS NEEDED): B1 compaction continuation via `pi.sendUserMessage` + unknown/first-reading crossing; B2 JSON-quoted front matter; B3 `PI_STAGE_FAILED` flag, Pi-only paths; W1 Pi check via generator `--check`, agents-scoped check; W2 `$`→`＄` neutralisation; W3 Pi mirror/pruning inside isolated Pi stage, `eversis-rule-*` excluded from stale-prune; W4 isolated Pi MCP merge + failure headline; W5 vendor-pin probe (Task 3.4); W6 Pi-specific MCP branch; W7 `node --test 'adapters/pi/*.test.mjs'`; W8 `mcp-setup.mdx`, `integrations/eversis-collections.md`; S1 Pi map parity; S2 automated Pi load check; S3 computed counts (50 skills); S4 unmodified stack seed skipped; S5 README notes; S6 prompt-quality read in review. |
| 2026-10-30 | Plan review iteration 2: APPROVED. Applied N-W1 (continuation only after a mid-task crossing with tool results; final-turn crossing compacts without a continuation; `ctx.isIdle()` selects send mode), N-S1 (neutralise only Pi substitution patterns; SSOT pointer line excluded), N-S2 (skip stack overlay when template placeholder markers remain), N-S3 (Pi `dist` loaders fallback for Task 5.1). |
| 2026-10-30 | CHECKPOINT: Phase 1 (Tasks 1.1–1.3) and Phase 2 (Task 2.1) done and verified — `node --test 'adapters/pi/*.test.mjs'` 20/20 pass; `adapters/pi/generate.mjs --out <tmp>` + `--check` OK (28 prompts, 3 role skills, APPEND_SYSTEM, extension, settings seed); `node adapters/sync.mjs --check` output identical to HEAD, no `.pi/` in repo; `sync.mjs --agents cursor,pi --out <tmp>` write + `--check` OK. Changed: `adapters/pi/{rule-map.yaml,generate.mjs,generate.test.mjs,context-budget.test.mjs,assets/eversis-context-budget.ts,assets/settings.json}` (new), `adapters/sync.mjs` (modified). Notes: prompts without `## Executable prompt` (`eversis-ba-docs-planner`, `eversis-ba-docs-writer`) emit the whole SSOT body (benchmark behaviour); Pi `fine-handoff` row is `target: none` + `skill_id: eversis-fine-handoff`. Next: Phase 3 (installer). |
| 2026-10-30 | RESUMED: orchestrator session continues from the CHECKPOINT above with Phase 3 (installer). |
| 2026-10-30 | CHECKPOINT: Phase 3 (Tasks 3.1–3.6) done and verified — `bash -n` OK on all 11 changed `.sh`; `mcp-merge.test.sh` 51/51 (36 existing + 15 Pi); `vendor-sync-skew.test.sh` 14/14 (8 existing + 6 Pi); `upgrade-preserve` 38/38, `selection-ssot` 8/8, `framework-home` 3/3, `scaffolding`, `ssot`, `claude-settings-merge`, `run-eversis-collections-mcp` pass (`gitignore.test.sh` fails on HEAD too — `_ensure_artifacts_subblock` missing in untouched `gitignore.sh`, out of scope); `npm run installer:smoke` PASS incl. new cases a, a2 (re-run: role skills not stale-pruned), b, c, d, e, f, g; `node adapters/sync.mjs --check` OK. Changed: `scripts/setup-agent-collections.sh`, `scripts/setup-agent-collections.test.sh`, `scripts/lib/setup-agent-collections/{agents.sh,agents-prompt.mjs,link-framework.sh,selection.sh,mcp-merge.sh,mcp-merge.mjs,mcp-merge.test.sh,vendor-sync-skew.sh,vendor-sync-skew.test.sh,upgrade.sh,summary.sh}`. Notes: shared `_link_agent_skills <agent> <dst-rel> [prune-exclude-glob]` (Pi passes `eversis-rule-*`; Claude / Cursor keep identical behaviour, Stop Rule not triggered); Pi MCP locator fails with a stderr message when no `.pi/` is found above `$PWD` (local and vendored); a Pi MCP failure with `--agents=pi` alone also exits 1 right after the merge (no selection written). Next: Phase 4 (docs). |
| 2026-10-30 | RESUMED: orchestrator session continues from the CHECKPOINT above with Phase 4 (documentation). |
| 2026-10-30 | Phase 4 (Tasks 4.1–4.3) done by Repo Docs Writer — created `adapters/pi/README.md` (surfaces, generator usage, markers, `$`→`＄`, stack overlay, context budget, MCP locator, installer stage / deselect, trust, `/reload`, user-level `APPEND_SYSTEM.md`, TS/ESLint exclusion, extension review, `AGENTS.md` vs `CLAUDE.md`, AC-111–AC-114 out of scope); `docs/architecture/adapter-mapping.md` (Pi emit-matrix row, new §6A Pi adapter mapping — numbered 6A so external §6 OpenCode references stay valid — maturity `shipped`, §7/§8 notes, §9 checklist line); `adapters/README.md` (Pi sync note + per-adapter row); `README.md`, `AGENTS.md` (+ Pi channel notes), `website/docs/intro.md`, `getting-started/{installation.mdx (new "Add the Pi coding agent" + context-budget sections, flag table, verify step), start-here.mdx, prerequisites.mdx (Pi CLI optional row, Node.js, `pi --version`), mcp-setup.mdx (Pi tab: `.pi/mcp.json`, trust, `pi mcp list`)}`, `reference/integrations/eversis-collections.md`, `reference/framework-reference.md`; `website/docs/advanced/isolation.md` gets a Pi row under the plan's Stop Rule (its Multi-agent MVP table lists every tool); `migration-from-cursor-collections.md` unchanged (Cursor-vs-Claude matrix). `CHANGELOG.md` Unreleased › Added entry for AC-14 + `website/src/pages/changelog.md` regenerated. Verified: `npm run sync:website-docs:check` OK; `npm run website:changelog:check` OK; `npm run website:build` SUCCESS. OpenCode text unchanged. Next: Phase 5 (review). |
| 2026-10-31 | Task 5.1 done (orchestrator). Temp project installed with `--agents=pi --vendor=copy` (exit 0). `pi --mode rpc --approve --no-session` + `get_commands`: 28 `eversis-*` prompts, 53 skills (50 framework + `eversis-rule-{code-reviewer,engineering-manager,spec-driven-development}`), stderr empty, no extension/resource error events. `pi mcp list` has no `--approve` and would need a write to the user-global `~/.pi/agent/trust.json`, so per the Stop Rule fallback `.pi/mcp.json` was validated with Pi's own `dist/extensions/mcp/config.js` `loadMcpConfig({ projectTrusted: true })` and an empty agent dir: `errors: []`, `eversis-collections` = `bash -c` locator. Also verified `dist/core/resource-loader.js:116`: one context file per directory, order `AGENTS.override.md` > `AGENTS.md` > `CLAUDE.md` (research Q6 precedence confirmed). |
| 2026-11-03 | Task 5.2 code review (Code Reviewer, independent): **NOT PASS — 1 BLOCKER**. B1: `adapters/pi/generate.mjs` `emit()` (~596–622) silently overwrites a pre-existing hand-made (marker-less) `.pi/APPEND_SYSTEM.md`, `.pi/prompts/eversis-<id>.md`, `.pi/skills/eversis-rule-*/SKILL.md` or `.pi/extensions/eversis-context-budget.ts` — reproduced (hand-made APPEND_SYSTEM.md lost, no warning); contradicts the generator header (line 29 "Hand-made files under .pi/ are never touched") and the AC-99 `backupForeignClaudeMd` convention. Fix: back up a regular marker-less target to `<name>.pre-agent-collections.bak` (timestamped when a differing backup exists) with a warning before writing, plus a `generate.test.mjs` case. Suggestions: post-compaction re-fire on small windows; continuation fallback when no plan exists; `}` in local Pi MCP bash default. Verified green: `node --test 'adapters/pi/*.test.mjs'` 20/20; `node adapters/sync.mjs --check` OK; `mcp-merge.test.sh` 51/51; `vendor-sync-skew.test.sh` 14/14; `upgrade-preserve.test.sh` 38/38; `npm run installer:smoke` PASS; `npm run website:build` SUCCESS; `git diff --stat -- .ai/` empty; no package.json changes. Task 5.2 DoD left unticked until B1 is fixed and re-reviewed. |
| 2026-11-03 | Rule 12 solution change — code-review fixes B1 + S1–S3 (Software Engineer). Human approval: "Go ahead with fix plus suggestions 1-3.". **B1:** `adapters/pi/generate.mjs` `createEmitter().emit` now calls `backupHandMadeTarget()` in write mode before replacing a target: a regular, marker-less file is copied byte-identical to `<name>.pre-agent-collections.bak` (timestamped `<name>.pre-agent-collections.<YYYYMMDDTHHMMSS>.bak` when a differing backup exists; identical backup reused) with `warning: backed up hand-made <rel> to <backup rel>` on stderr; marker-bearing files and symlinks get no backup; `--check` unchanged; `.pi/settings.json` still seed-only. Header comment corrected (follows `backupForeignClaudeMd` convention). `generate.test.mjs` +3 cases (hand-made APPEND_SYSTEM + prompt backed up byte-identical with warning, second run no new backup, timestamped backup on a differing re-edit; marker-bearing / symlink no backup; `--check` writes no backup). **S1:** `eversis-context-budget.ts` — `shouldCompact` stays pure with an optional `{ afterCompaction }` argument; the factory sets `justCompacted` in `onComplete`, so the first known reading after an extension-triggered compaction only sets a baseline (no compaction + continuation loop on small windows); first-ever unknown→above still fires. **S2:** `CONTINUATION_MESSAGE` adds "If there is no active plan, continue the interrupted task from the compaction summary." (gate wording intact). `context-budget.test.mjs` +3 cases. **S3:** `mcp-merge.mjs` Pi local locator — a framework path containing `}`, `"`, `$`, backtick or `\` is assigned single-quoted to `ac_home='…'` and the default becomes `${AGENT_COLLECTIONS_HOME:-$ac_home}` (bash keeps a backslash before `}` in a double-quoted default, so escaping could not work); plain paths keep the inline default; the Pi host-variable check also strips the `ac_home='…';` prefix. `mcp-merge.test.sh` +3 cases (path with ``} " $ ` '`` reaches `docker compose -f` byte-exact with `AGENT_COLLECTIONS_HOME` unset; env override still wins; no Pi host-variable false positive). `adapters/pi/README.md` updated (backup, post-compaction baseline, no-plan fallback, path indirection). Verified: `node --test 'adapters/pi/*.test.mjs'` 26/26; `node adapters/sync.mjs --check` OK; `mcp-merge.test.sh` 54/54; `npm run installer:smoke` PASS; `npm run sync:website-docs:check` OK; manual B1 repro in scratchpad shows both backups + warnings, second run no new backup, `--check` OK. Task 5.2 DoD left unticked pending re-review. |
| 2026-11-03 | Code review pass 2 (Code Reviewer, full re-review): **PASS — 0 BLOCKERs**. B1 closed: reproduced hand-made `.pi/APPEND_SYSTEM.md` + `.pi/prompts/eversis-implement.md` → byte-identical `*.pre-agent-collections.bak` + `warning:` on stderr; re-run creates no new backup; differing re-edit → timestamped backup; symlinked extension replaced without backup (link target untouched); `--check` writes no backup; Pi loaders ignore `.bak` (prompts `.md` only, extensions `.ts`/`.js` only). S1 verified (post-compaction reading is a baseline only; no compaction loop; first unknown→above still fires). S2 verified (no-plan fallback; gate wording intact). S3 verified by executing generated `bash -c` with a stub `docker`: plain path inline, `/opt/we}ird $x "q" it's \`b\`` resolved exactly via single-quoted `ac_home`; Pi host-variable check accepts it. All DoD items and AC1–AC7 re-verified across the full change set (incl. fresh `--agents=cursor,claude` install → no `.pi/`). STRICT FORBIDDEN: in scope; no doc comments removed/shortened; no new deps; `git diff --stat -- .ai/` empty. Commands: `node --test 'adapters/pi/*.test.mjs'` 26/26; `node adapters/sync.mjs --check` OK; `sync.mjs --agents cursor,pi --out` write+check OK; `generate.mjs --out` + `--check` OK; `bash -n` on 11 changed `.sh` OK; `mcp-merge.test.sh` 54/54; `vendor-sync-skew.test.sh` 14/14; `upgrade-preserve.test.sh` 38/38; `npm run installer:smoke` PASS; `npm run website:build` SUCCESS. Suggestion (non-blocking): a backup of a hand-made `eversis-rule-*/SKILL.md` lives inside the role-skill dir, which Pi deselect / orphan cleanup removes whole. Task 5.2 DoD and QA AC1–AC7 ticked. |
| 2026-11-03 | Fine declared (orchestrator) after code review pass 2 PASS. QA comment draft produced for human review; not posted to Jira. `docs/context/agent-collections/INDEX.md` tasks_since_audit 0 → 1. |
