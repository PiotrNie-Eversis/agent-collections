# promote-skill-cursor-packaging - Implementation Plan

## Task Details

| Field            | Value                   |
| ---------------- | ----------------------- |
| Jira ID          | none |
| Title            | Fix Cursor-side skill/prompt reachability in vendored installs: (A) prefix-correct `.cursor/commands/*.md` SSOT pointers like the Claude adapter already does, and (B) add a `.cursor/skills/` mirror matching the existing `.claude/skills/` mirror |
| Description      | In a vendored (submodule/copy) Cursor-only consumer install, `eversis-promote-domain-knowledge` (and, more generally, any skill) is unreachable through any local mechanism: no `.cursor/skills/` mirror exists (Claude gets one via `_link_claude_skills()`, Cursor doesn't), and every `.cursor/commands/*.md` SSOT pointer + `.cursor/rules/*.mdc` skill reference to `.ai/...` is left unprefixed, so it resolves to a path that doesn't exist at the consumer root (real path is under `vendor/agent-collections/.ai/...`). Claude's equivalent files are correctly prefixed via `--framework-prefix`, which `adapters/sync.mjs` currently restricts to "the Claude generator only". MCP ends up as the only working path for Cursor, with no working local fallback. |
| Priority         | Medium |
| Related Research | [`promote-skill-cursor-packaging.research.md`](./promote-skill-cursor-packaging.research.md) |

## Wildly Important Goal

**Goal**: Restore Cursor-side reachability parity with Claude for skills and prompts in vendored consumer installs — (A) `.cursor/commands/*.md` SSOT pointers resolve correctly under a vendored install, and (B) a `.cursor/skills/` mirror exists, matching `.claude/skills/`'s structure and lifecycle exactly.

**Success Measure**: In a vendored fixture install (`--vendor copy|submodule`, `--agents cursor`), (1) every generated `.cursor/commands/*.md` file's `**SSOT:**` line points at an existing file on disk; (2) `.cursor/skills/eversis-promote-domain-knowledge/SKILL.md` exists and its content matches `.ai/skills/eversis-promote-domain-knowledge/SKILL.md` byte-for-byte; (3) deselecting Cursor removes the `eversis-*` entries from `.cursor/skills/`, same as Claude's existing behavior; (4) this repo's own self-host (`agent-collections`) is unaffected — no `--framework-prefix` is passed for self-host, so generated output there is unchanged.

**Do NOT touch / do NOT add**:
- Do not attempt to prefix-correct `.ai/skills/` / `.ai/rules/` references embedded **inside rule body text** copied verbatim from `.ai/rules/**/*.md` into `.cursor/rules/*.mdc` (e.g. `agent-core.md`'s own line "Skill packages belong under `.ai/skills/eversis-<topic>/`"). Confirmed in research: Claude's own embedded rule body text has the exact same unprefixed pattern in `CLAUDE.md` — this is shared, pre-existing, and out of scope for parity with Claude, not a new Cursor-specific gap. Fixing it would need a source-text templating mechanism (placeholder tokens substituted at generation time) that doesn't exist for either adapter today — a separate, larger design question, not this ticket.
- Do not add `.cursor/skills/` or `.cursor/prompts/` cleanup-on-Cursor-deselect for anything beyond the new `.cursor/skills/` mirror itself (i.e. do not also retrofit missing deselect-pruning for `.cursor/rules/*.mdc` / `.cursor/commands/*.md` — confirmed in research that this pruning gap already exists today for Cursor deselection and is unrelated to this ticket's reachability bug).
- Do not change `opencode`'s adapter output — out of scope, not investigated.
- Do not add a `.cursor/skills/` equivalent of Cursor's native "Agent Skills" UI registration (per `website/docs/reference/skills/overview.md:8`, this repo deliberately does not register the folder as that UI's path) — this plan only adds a plain, locally-readable file mirror for text-based fallback reads, not a UI integration.

## Proposed Solution

Two independent fixes, landing together since both were locked in research (Option A+B), but implementable and reviewable as separate phases:

1. **(Phase 1, Option A) Prefix-correct Cursor's generated SSOT pointers.** Extend `adapters/cursor/generate.mjs` with the same `--framework-prefix` argument Claude's generators already accept (`adapters/claude/generate.mjs`, `adapters/claude/generate-commands.mjs`), applied to the one place Cursor emits a `.ai/...` path as generated (not verbatim-copied) text: the `**SSOT:**` line in each `.cursor/commands/*.md` file. Update `adapters/sync.mjs` to pass `--framework-prefix` to the Cursor generator too (both `runCheck` and `runWrite`), instead of restricting it to Claude.
2. **(Phase 2, Option B) Add a `.cursor/skills/` mirror.** Add `_link_cursor_skills()` to `scripts/lib/setup-agent-collections/link-framework.sh`, structurally identical to the existing `_link_claude_skills()` (same symlink/copy mode, same stale-entry pruning), wired into `link_framework_files()` when `cursor` is a selected agent. Add matching deselect-pruning (mirroring the existing `.claude/skills/` block in `_prune_deselected_agents()`) for when Cursor is later deselected.
3. **(Phase 3) Documentation touch-up.** Update `website/docs/reference/skills/overview.md:8` and `agent-core.md` § Skills discovery to describe the corrected, current state (both hosts get a local skills mirror; Cursor's generated pointers are vendor-path-correct) instead of the pre-fix picture.
4. **(Phase 4) Code Review** — mandatory, final phase.

No architecture diagram needed — both code changes are narrow, additive functions following an existing, working sibling implementation almost line-for-line.

## Current Implementation Analysis

### Already Implemented

- `adapters/claude/generate.mjs` / `generate-commands.mjs` — the exact `--framework-prefix` pattern to replicate: arg parsing (`parseArgs`), `assertSafeFrameworkPrefix()` validation (no absolute path, no `..` escape), and applying it to a generated string via a small `withPrefix`/`ssotPath` helper. Use as the direct template for Phase 1.
- `scripts/lib/setup-agent-collections/link-framework.sh` `_link_claude_skills()` (lines 132-176) — the exact mirror-linking pattern to replicate for Cursor: iterate `${COLLECTIONS_HOME}/.ai/skills/eversis-*`, symlink or copy per `${EFFECTIVE_LINK_MODE}`, prune stale destination entries. Use as the direct template for Phase 2.
- `_prune_deselected_agents()` (lines 43-88), specifically the `.claude/skills` block (lines 60-75) — the exact deselect-pruning pattern to replicate for `.cursor/skills`.
- `scripts/setup-agent-collections.test.sh` lines 122-130 and 163-170 — existing assertions for `.claude/skills/` content parity and deselect-pruning; use as the direct template for the new Cursor-side test assertions.

### To Be Modified

- `adapters/cursor/generate.mjs` — add `--framework-prefix` parsing (mirroring `adapters/claude/generate.mjs`'s `parseArgs`/`assertSafeFrameworkPrefix`); thread the resolved prefix into `buildCommandContent()` so the `**SSOT:** \`${prompt.sourceRel}\`` line becomes `**SSOT:** \`${frameworkPrefix}/${prompt.sourceRel}\`` when a prefix is set (empty prefix ⇒ unchanged, self-host behavior), exactly mirroring `adapters/claude/generate-commands.mjs`'s `ssotPath` construction (lines ~294-295 there).
- `adapters/sync.mjs` — `runCheck()` (~line 341) and `runWrite()` (~line 539): pass the same `frameworkPrefix`-derived extra args to the Cursor generator call that Claude's calls already receive, instead of Cursor's call always getting `[]`. Update the `--help` text (~line 114) to drop "Claude generator only" and describe both.
- `scripts/lib/setup-agent-collections/link-framework.sh` — `link_framework_files()` (~line 198-223): replace the `# Q1: do NOT mirror .cursor/skills|prompts|commands` comment (now superseded for the skills half) with a call to the new `_link_cursor_skills()`, and a note that commands/prompts remain intentionally un-mirrored (only skills are gaining a mirror, per the locked A+B scope — `.cursor/commands/*.md` already exists via the Phase 1 fix path, so no separate "commands mirror" is being added). `_prune_deselected_agents()` (~line 43-88): add a `.cursor/skills` pruning block, structurally identical to the existing `.claude/skills` block, gated on `cursor` absent from `--agents`.
- `website/docs/reference/skills/overview.md:8` and `.ai/rules/orchestration/agent-core.md` § Skills discovery: update wording to state both hosts get a local skills mirror at install time, and that Cursor's generated SSOT/command pointers are vendor-path-correct.

### To Be Created

- `_link_cursor_skills()` function in `link-framework.sh` (new function, same file as the modification above).
- New assertions in `scripts/setup-agent-collections.test.sh` for: `.cursor/skills/eversis-promote-domain-knowledge/SKILL.md` existing and matching SSOT content; `.cursor/skills/eversis-*` pruning on Cursor deselect; a vendored-fixture `.cursor/commands/*.md` SSOT line resolving to an existing file when `--framework-prefix` is set.

## Open Questions

| #   | Question   | Answer   | Status                |
| --- | ---------- | -------- | --------------------- |
| 1   | Fix scope: root-cause path fix alone (A), or also add a `.cursor/skills/` mirror (B)? | **A+B** (locked by human, this session) | ✅ Resolved |
| 2   | Should rule-body-embedded `.ai/skills/` mentions (inside `.cursor/rules/*.mdc`, copied verbatim from `.ai/rules/**`) also be prefix-corrected? | **No** — out of scope; Claude has the identical unprefixed pattern in `CLAUDE.md` today, so fixing only Cursor would be inconsistent, and a real fix needs a source-templating mechanism neither adapter has (see Do NOT touch) | ✅ Resolved (excluded) |
| 3   | Should `.cursor/rules/*.mdc` / `.cursor/commands/*.md` also get deselect-pruning when Cursor is deselected (a pre-existing, unrelated gap noticed during research)? | **No** — out of scope for this ticket; only the new `.cursor/skills/` mirror gets deselect-pruning, matching what's actually being added | ✅ Resolved (excluded) |

## Technical Context

Project conventions, coding standards, and patterns discovered during planning. Downstream agents MUST read this section instead of re-discovering the same context.

### Project Instructions

- This repo is `agent-collections` itself — self-host, `COLLECTIONS_HOME == TARGET_DIR`. `--framework-prefix` must stay empty for self-host generation (see `_resolve_framework_prefix()` in `link-framework.sh:106-130`, already correct and unchanged by this plan) — verify Phase 1/2 changes produce byte-identical output for this repo's own `.cursor/` and `.claude/` when no prefix is passed.
- Root `AGENTS.md` and `.ai/rules/orchestration/*.md` are the SSOT rule content; `.cursor/rules/*.mdc` and `CLAUDE.md` are both generated from it via `adapters/*/rule-map.yaml`. Do not hand-edit generated files (`GENERATED_MARKER` comment present in each) — only their `.ai/` sources or the generator scripts.

### Architecture & Patterns

- Both adapter generators (`adapters/cursor/generate.mjs`, `adapters/claude/generate.mjs`) are zero-dependency Node scripts with hand-rolled arg parsing (no `commander`/`yargs`) — match this style exactly; do not introduce a new dependency for `--framework-prefix` parsing (Claude's `assertSafeFrameworkPrefix()` is ~10 lines, copy the pattern, don't add a package).
- `adapters/sync.mjs` orchestrates both generators via `spawnSync` + `runGenerator()` (a shared helper already parameterized with `extraArgs`) — Phase 1's `sync.mjs` change is passing an already-existing `extraArgs` value to an already-generic call site, not new plumbing.
- `link-framework.sh` functions are small, single-purpose, prefixed `_` (private to the file), called in sequence from `link_framework_files()`. `_link_cursor_skills()` must follow `_link_claude_skills()`'s exact shape (guard on agent selection → mkdir dest → loop source dirs → symlink/copy → prune stale) for consistency and reviewability.

### Tech Stack

- Node.js ≥ 18 (adapter generators), Bash (installer scripts, macOS/Linux; Windows uses `cmd //c mklink /J` inside `_make_symlink`, already implemented, unchanged by this plan).
- `npm run sync:adapters` / `sync:adapters:check` (root `package.json`) run `adapters/sync.mjs` — use `:check` to verify no drift after Phase 1's generator change, before touching any committed generated files.

### Code Style & Standards

- Match `adapters/claude/generate.mjs`'s existing comment style for the `--framework-prefix` design rationale (see its lines 19-27) — add an equivalent comment block in `adapters/cursor/generate.mjs` explaining why the prefix only applies to the generated SSOT line, not rule body content (ties to Open Question 2's resolution).
- Bash: follow `link-framework.sh`'s existing `local` variable declarations, `log_ok`/`log_info`/`log_warn` helpers (defined in `common.sh`), and comment-above-function documentation style.

### Testing Patterns

- `scripts/setup-agent-collections.test.sh` is a single, sequential Bash test script (no framework) that runs the real installer end-to-end against a scratch target directory and asserts on the resulting filesystem state with `grep`/`diff`/`[[ -f ]]` checks, `exit 1` on failure. New assertions append to this file near the existing `.claude/skills/` assertions (lines ~122-170), following the same style.
- `adapters/sync.mjs --check` compares fresh generation output against what's on disk (drift detection) — run after any generator change, against this repo's own self-host tree (empty prefix) to confirm no unintended output change.
- No unit-test framework for the `.mjs` generators themselves (confirmed: no `*.test.mjs` exists for `adapters/cursor/generate.mjs` or `adapters/claude/generate.mjs` today) — verification is via `--check` drift comparison and the installer test script, matching existing project convention; do not introduce a new test runner for this plan.

### Database Patterns

- Not applicable.

### Additional Context

- `eversis-promote-domain-knowledge` specifically has no `.cursor/commands/*.md` entry (it's `user-invocable: false`, commands are only generated from `.ai/prompts/*`) — Phase 1's fix does not create one (out of scope, would change `user-invocable` semantics); Phase 1 fixes the SSOT paths for the ~30 prompts that *do* have commands, and Phase 2's skills mirror is what actually restores a working local path for this specific skill.
- `mcp-server-list.json` / MCP selection is a separate, already-independent install choice (`mcpServers` field in `install-selection.json`) — this plan does not touch MCP wiring; MCP remains a valid, working path when configured, this plan just stops it being the *only* one for Cursor.

## Implementation Plan

### Phase 1: Prefix-correct Cursor's generated command SSOT pointers

**Goal**: Every `.cursor/commands/*.md` file's `**SSOT:**` line resolves to a real file in a vendored install, matching what `.claude/commands/*.md` already does.

**Description**: Add `--framework-prefix` support to `adapters/cursor/generate.mjs`, threaded only into the generated SSOT line (not rule body content — see Open Question 2). Update `adapters/sync.mjs` to pass it through to the Cursor generator in both `runCheck` and `runWrite`.

**Verification:** `npm run sync:adapters:check` (self-host, empty prefix, must show zero drift) — then `node adapters/sync.mjs --out <scratch-dir> --agents cursor --framework-prefix vendor/agent-collections` and confirm every `<scratch-dir>/.cursor/commands/*.md` SSOT line starts with `vendor/agent-collections/`.

#### Task 1.1 - [MODIFY] Add `--framework-prefix` to `adapters/cursor/generate.mjs`

**Description**: Add `parseArgs` support for `--framework-prefix` (copy `assertSafeFrameworkPrefix()` from `adapters/claude/generate.mjs` verbatim — same validation rules apply). Thread the resolved prefix through `main()` → `generateCommands()` → `writeCommand()` → `buildCommandContent()`, applying it only to the `**SSOT:**` line exactly as `adapters/claude/generate-commands.mjs` does (`ssotPath = frameworkPrefix ? \`${frameworkPrefix}/${prompt.sourceRel}\` : prompt.sourceRel`). Do not apply any prefix to rule-body content in `writeRule()`/`buildFrontMatter()` (Open Question 2).

**Files:** `adapters/cursor/generate.mjs` (modify)

**Definition of Done**:

- [ ] `node adapters/cursor/generate.mjs --help` documents `--framework-prefix`.
- [ ] `node adapters/cursor/generate.mjs --framework-prefix vendor/agent-collections --out <scratch>` produces `.cursor/commands/eversis-implement.md` with `**SSOT:** \`vendor/agent-collections/.ai/prompts/public/eversis-implement.md\``.
- [ ] `node adapters/cursor/generate.mjs --out <scratch>` (no prefix) produces the exact same `.cursor/commands/*.md` and `.cursor/rules/*.mdc` content as before this change (self-host / unprefixed case unaffected) — diff against current committed `.cursor/` in this repo shows zero changes.
- [ ] `.cursor/rules/*.mdc` output is byte-identical with and without `--framework-prefix` (prefix must not leak into rule bodies).

**Stop Rule:** If applying the prefix would require changing `writeRule()`/rule body content (not just the commands' SSOT line), stop — that's Open Question 2 territory, explicitly out of scope.

**Clues**: `adapters/claude/generate-commands.mjs` lines ~60-70 (`assertSafeFrameworkPrefix`), ~88-96 (arg parsing), ~294-295 (`ssotPath` construction) are the exact lines to mirror.

#### Task 1.2 - [MODIFY] Pass `--framework-prefix` through to the Cursor generator in `adapters/sync.mjs`

**Description**: In `runCheck()` (~line 328-345) and `runWrite()` (~line 535-539), compute a `cursorExtraArgs` value the same way `claudeExtraArgs` is already computed, and pass it to the Cursor `runGenerator()` call (currently called with no extra args in both places). Update the `--help` text (~line 114) so it no longer says "Claude generator only".

**Files:** `adapters/sync.mjs` (modify)

**Definition of Done**:

- [ ] `runCheck()` and `runWrite()` both pass `--framework-prefix` to the Cursor generator call when `frameworkPrefix` is non-empty, identically to how they already do for Claude.
- [ ] `npm run sync:adapters:check` (this repo, self-host, no prefix argument) passes with zero drift — confirms the change is a no-op for self-host.
- [ ] `--help` output no longer says `--framework-prefix` is Claude-only; describes both generators.

**Stop Rule:** If `--check` mode's temp-dir comparison (`runCheck`, lines 328-420ish) needs structural changes beyond passing the extra arg (e.g. because Cursor's `--check` drift comparison logic assumes no prefix anywhere else), stop and confirm before restructuring `runCheck`.

**Clues**: Lines 341-351 (`runCheck`) and 537-552 (`runWrite`) are the two call sites; both already have a working `claudeExtraArgs` pattern one line above to copy.

### Phase 2: Add the `.cursor/skills/` mirror

**Goal**: `.cursor/skills/<name>/` exists for every framework skill in a Cursor-selected install, matching `.claude/skills/` exactly (content, link mode, stale-pruning, deselect-pruning).

**Description**: New `_link_cursor_skills()` function in `link-framework.sh`, wired into `link_framework_files()`, plus matching deselect-pruning.

**Verification:** Run the installer against a scratch target with `--agents cursor` (no claude): confirm `.cursor/skills/eversis-promote-domain-knowledge/SKILL.md` exists and matches `.ai/skills/eversis-promote-domain-knowledge/SKILL.md`. Re-run with `--agents claude` only (deselecting cursor): confirm `.cursor/skills/eversis-*` entries are removed.

#### Task 2.1 - [CREATE] `_link_cursor_skills()` in `link-framework.sh`

**Description**: New function, placed immediately after `_link_claude_skills()`, identical structure: guard on `cursor` in `${SELECTED_AGENTS:-}`; source `${COLLECTIONS_HOME}/.ai/skills`; destination `${TARGET_DIR}/.cursor/skills`; loop `eversis-*` source dirs, symlink (`_make_symlink`) or copy per `${EFFECTIVE_LINK_MODE:-symlink}`; prune destination entries with no matching source (same `keep_names` accumulator pattern). Reuse `_make_symlink` as-is (already generic, not Claude-specific).

**Files:** `scripts/lib/setup-agent-collections/link-framework.sh` (modify — new function)

**Definition of Done**:

- [ ] `_link_cursor_skills()` exists, structurally parallel to `_link_claude_skills()` (same guard/loop/prune shape), targeting `.cursor/skills` instead of `.claude/skills`.
- [ ] Function is idempotent — running it twice in a row produces the same end state (matches `_link_claude_skills()`'s existing idempotency, inherited by copying its pattern).
- [ ] `log_ok` message on completion follows the existing `"Linked N skill package(s) into .cursor/skills/ (mode: ...)"` style.

**Stop Rule:** If `_make_symlink()` needs any Cursor-specific change to work correctly for `.cursor/skills/*`, stop — it's currently host-agnostic (just src/dst paths) and should not need modification; a need to modify it signals a wrong assumption about the function's generality.

**Clues**: `link-framework.sh:132-176` (`_link_claude_skills`) is the line-for-line template.

#### Task 2.2 - [MODIFY] Wire `_link_cursor_skills()` into `link_framework_files()` and remove the stale "Q1" comment

**Description**: In `link_framework_files()` (~line 198-223), add a call to `_link_cursor_skills()` alongside the existing `_link_claude_skills()` call. Replace the `# Q1: do NOT mirror .cursor/skills|prompts|commands — skills via MCP + .ai/` comment with an accurate one reflecting the new state (skills now mirrored for both hosts; commands/prompts remain un-mirrored by design, since Phase 1 already gives Cursor a working, correctly-pathed command surface without needing a literal mirror).

**Files:** `scripts/lib/setup-agent-collections/link-framework.sh` (modify)

**Definition of Done**:

- [ ] `link_framework_files()` calls `_link_cursor_skills()` (order relative to `_link_claude_skills()` does not matter — both are independent).
- [ ] The stale "Q1: do NOT mirror .cursor/skills" comment is replaced, not left contradicting the new code.
- [ ] Full installer run (`scripts/setup-agent-collections.sh`, or the test script's harness) with default agents (`cursor,claude`) succeeds and produces both `.claude/skills/` and `.cursor/skills/` with matching `eversis-*` entries.

**Stop Rule:** None beyond the shared Phase 2 verification above.

**Clues**: `link-framework.sh:198-223` is `link_framework_files()`; the comment to replace is on line 212.

#### Task 2.3 - [MODIFY] Add `.cursor/skills` deselect-pruning to `_prune_deselected_agents()`

**Description**: Add a block mirroring the existing `.claude/skills` pruning block (lines 60-75) but gated on `cursor` being absent from `${SELECTED_AGENTS:-cursor}` instead of `claude`. Note: `_prune_deselected_agents()` is currently named/scoped around Claude deselection specifically (early-return if Claude *is* selected) — this task adds a **second, independent** guarded block for the Cursor-skills case within the same function (or a small sibling function called from the same place), since the two deselection conditions are orthogonal (either agent can be deselected independently) and only the skills-mirror pruning is in scope (per Open Question 3 — not rules/commands pruning).

**Files:** `scripts/lib/setup-agent-collections/link-framework.sh` (modify)

**Definition of Done**:

- [ ] Running the installer with `--agents claude` only (Cursor deselected) removes all `eversis-*` entries from `.cursor/skills/` on an existing target that previously had them, and logs a message matching the existing `.claude/skills/` deselect-pruning message style.
- [ ] Running with `--agents cursor` only (Claude deselected) still correctly prunes `.claude/skills/` (existing behavior unchanged).
- [ ] Running with both agents selected prunes neither.

**Stop Rule:** If this requires restructuring `_prune_deselected_agents()`'s overall guard logic (not just adding a parallel block), stop and confirm the restructuring approach before proceeding — the function's current shape assumes a single "Claude deselected" condition throughout.

**Clues**: Lines 43-88 (`_prune_deselected_agents`), specifically 60-75 (the `.claude/skills` block) — same removal-by-name-prefix pattern (`for entry in "$claude_skills"/eversis-*`), applied to `${TARGET_DIR}/.cursor/skills`.

#### Task 2.4 - [CREATE] Installer test coverage for `.cursor/skills/`

**Description**: Add assertions to `scripts/setup-agent-collections.test.sh`, mirroring the existing `.claude/skills/` assertions at lines 122-130 (content-parity check for `eversis-promote-domain-knowledge` specifically, per this ticket's original report) and 163-170 (deselect-pruning check), targeting `.cursor/skills/` instead.

**Files:** `scripts/setup-agent-collections.test.sh` (modify)

**Definition of Done**:

- [ ] New assertion: `.cursor/skills/eversis-promote-domain-knowledge/SKILL.md` exists in a `cursor`-selected install and its content matches `.ai/skills/eversis-promote-domain-knowledge/SKILL.md` byte-for-byte (including `user-invocable: false` frontmatter, per the existing Claude-side check's pattern).
- [ ] New assertion: deselecting Cursor removes `.cursor/skills/eversis-*` entries.
- [ ] `bash scripts/setup-agent-collections.test.sh` passes end-to-end (all existing + new assertions).

**Stop Rule:** None.

**Clues**: `scripts/setup-agent-collections.test.sh:97-98, 122-130, 163-170` — direct templates.

### Phase 3: Documentation touch-up

**Goal**: Docs describe the corrected, current state rather than the pre-fix picture.

**Description**: Small wording updates only — no behavior change in this phase.

**Verification:** Manual read-through; no automated check (docs-only).

#### Task 3.1 - [MODIFY] Update skills-packaging docs to reflect the fix

**Description**: `website/docs/reference/skills/overview.md:8` and `.ai/rules/orchestration/agent-core.md` § Skills discovery: state plainly that both Claude Code and Cursor consumers get an install-time local skills mirror (`.claude/skills/` and `.cursor/skills/` respectively), and that generated Cursor command/rule SSOT pointers are vendor-path-correct in vendored installs. Keep the existing "MCP preferred, do not treat this as a vendor-specific 'Agent Skills' UI registration" framing — this fix does not change that stance, only closes the reachability gap.

**Files:** `website/docs/reference/skills/overview.md` (modify), `.ai/rules/orchestration/agent-core.md` (modify)

**Definition of Done**:

- [ ] `overview.md:8` no longer implies only Claude gets a local mirror.
- [ ] `agent-core.md` § Skills discovery point 5 reflects the corrected state.
- [ ] `npm run sync:adapters` re-run after this edit (since `agent-core.md` is a rule source feeding both `CLAUDE.md` and `.cursor/rules/eversis-agent-core.mdc`) — confirm both regenerate cleanly with the new wording.

**Stop Rule:** None.

**Clues**: Exact current wording quoted in research's Gathered Information / Business Impact sections.

### Phase 4: Code Review

**Goal**: Independently verify Phases 1-3 match this plan and the locked research decision (A+B) before declaring Fine.

**Description**: Mandatory final phase.

**Verification:** `npm run sync:adapters:check` (zero drift for self-host), `bash scripts/setup-agent-collections.test.sh` (all pass), manual diff read of all modified files.

#### Task 4.1 - [REUSE] Code review by Code Reviewer

**Description**: Run **Code Reviewer** via `eversis-review.md` against the full diff (2 generator/installer scripts, 1 installer test file, 2 doc files) against this plan and the locked research decision.

**Files:** `adapters/cursor/generate.mjs`, `adapters/sync.mjs`, `scripts/lib/setup-agent-collections/link-framework.sh`, `scripts/setup-agent-collections.test.sh`, `website/docs/reference/skills/overview.md`, `.ai/rules/orchestration/agent-core.md` (all reuse)

**Definition of Done**:

- [ ] `npm run sync:adapters:check` passes (zero drift for this repo's own self-host generation).
- [ ] `bash scripts/setup-agent-collections.test.sh` passes.
- [ ] Code review passes with no blocking findings.
- [ ] Review outcome documented in Changelog.

**Stop Rule:** If review finds the self-host `.cursor/` or `.claude/` output in this repo has drifted (i.e. `sync:adapters:check` fails), stop — that means the prefix logic leaked into the empty-prefix/self-host path, a regression, not a pre-existing issue.

**Clues**: The main review risk is the empty-prefix (self-host) case regressing — verify explicitly, not just the new vendored-prefix behavior.

## Security Considerations

- `assertSafeFrameworkPrefix()` (copied from the existing Claude implementation) already rejects absolute paths and `..` traversal in the `--framework-prefix` value — no new validation gap introduced, same guarantee extended to a second generator.
- `_make_symlink()` (reused as-is for Task 2.1) already resolves relative symlink targets safely (via `relative-path.mjs`) — no new symlink-target validation needed since the function isn't being modified.
- No new external dependencies, no new network calls, no new secrets handling.

## Quality Assurance

Acceptance criteria checklist to verify the implementation meets the defined requirements:

- [ ] `.cursor/commands/*.md` SSOT lines resolve correctly in a vendored install (Phase 1).
- [ ] `.cursor/skills/eversis-promote-domain-knowledge/SKILL.md` exists and matches SSOT in a Cursor-selected install (Phase 2).
- [ ] Deselecting Cursor prunes `.cursor/skills/eversis-*`; deselecting Claude still prunes `.claude/skills/eversis-*` (both, Phase 2).
- [ ] This repo's own self-host generation (`npm run sync:adapters:check`) shows zero drift after all changes (Phases 1-3).
- [ ] `bash scripts/setup-agent-collections.test.sh` passes with the new assertions included.
- [ ] Docs (`overview.md`, `agent-core.md`) describe the corrected state (Phase 3).
- [ ] Rule-body-embedded `.ai/skills/` mentions remain unprefixed (unchanged, matching Claude) — confirmed not accidentally "fixed" in a way that diverges from Claude's equally-unprefixed pattern (Open Question 2).

## Improvements (Out of Scope)

- Prefix-correcting rule-body-embedded `.ai/...` references (shared by both adapters) — would need a source-text templating mechanism; a real fix but a materially different, larger design than this ticket (Open Question 2).
- Adding `.cursor/rules/*.mdc` / `.cursor/commands/*.md` deselect-pruning for Cursor (a separate, pre-existing gap noticed during research, unrelated to reachability) (Open Question 3).
- Extending any of this to the `opencode` adapter (placeholder-only today, not investigated).

## Human gates

Numbered list of every human-approval gate this task passes through, in order. Strike through a gate once closed, and quote the user's literal closing phrase — do not paraphrase — as evidence:

1. ~~Approve research~~ — scope locked via `"Q1. A+B;"` (answering the plan-scope question posed at the end of research)
2. Approve this plan — _pending_
3. Implement → Review → Fine — _pending_

## Changelog

| Date   | Change Description   |
| ------ | -------------------- |
| 2026-09-09 | Initial plan created — 4 phases (Cursor SSOT prefix fix, `.cursor/skills/` mirror, docs touch-up, code review), covering the locked A+B scope from research. Traced exact implementation shape from existing, working sibling code (`adapters/claude/generate-commands.mjs`'s `--framework-prefix` handling; `link-framework.sh`'s `_link_claude_skills()`). Scoped out rule-body-embedded path references and Cursor rules/commands deselect-pruning as separate, pre-existing gaps not part of this ticket (Open Questions 2-3). Awaiting human approval before implementation. |
