# AC-2 - Implementation Plan

## Task Details

| Field            | Value                   |
| ---------------- | ----------------------- |
| Jira ID          | AC-2 |
| Title            | Define a context-and-knowledge-management architecture for agent-collections (Phase 1: bounded context router) |
| Description      | Tighten the domain-knowledge read path (`docs/context/<project>/INDEX.md` → one component → capped `docs/specs/` discovery/consumption), unify the component-file granularity contract so every write path emits something the router can read, wire a visible empty-INDEX signal into Implement readiness, extend the framework's existing Confluence-first bootstrap skill with a raw-history fallback for maintenance-project adoption, and add a session-budget rule so long-running sessions end cleanly before automatic compaction instead of risking the current task. Scope is Phases 1-3 of the 7-phase architecture recorded in the research; Phases 4-7 are explicitly deferred to future tickets. |
| Priority         | High |
| Related Research | `docs/specs/ac-2/ac-2.research.md` (approved — "Research jest ok"; Question 10 DELTA accepted `"Accept DELTA"`, 2026-09-21) |
| Related Plan Review | Iteration 1: `docs/specs/ac-2/Plan Review  ac-2.plan.md` (5 blockers + 5 warnings, closed). Iteration 2: `docs/specs/ac-2/Plan Review (iteracja 2)  ac-2.plan.md` (1 blocker + 3 warnings, closed). Both independently re-verified against the live repo before each revision. |

## Wildly Important Goal

**Goal**: An agent running `/eversis-implement` on any project reads domain knowledge through a bounded, budgeted path (`INDEX.md` → one component → capped discovery/consumption of `docs/specs/`), every existing write path into `docs/context/` emits a file shape that path can actually resolve, and, in a long-running Implement session, the agent writes state and ends the session before automatic compaction can silently drop the current task.

**Success Measure**: `agent-core.md`'s read-budget rule explicitly distinguishes discovery (unrestricted) from consumption (capped at 1-2 files) with no fallback loophole; `eversis-import-confluence-knowledge` writes `<component>/index.md` (not `<domena>/<temat>.md`) so `eversis_context_get` can resolve everything it produces, with explicit empty `code_paths`/`related_specs` so `eversis-audit-domain-knowledge` never misreads a fresh import as `Delete`; `docs/context/README.md` names `INDEX.md` as the mandatory router; the Implement readiness block's Layer A files (`engineering-manager.md`, `eversis-orchestrating-implementation/SKILL.md`) surface an empty-INDEX `Context` signal and an independent `Resume` line for zero-compaction checkpoints — `Resume` is its own optional line, never a `Flow` value, so resuming never loses the session's governing `Flow` declaration; a zero-compaction rule exists in `eversis-orchestrating-implementation` whose agent triggers are the exchange count and "task completed+tested while further tasks remain", with explicit precedence over the existing "proceed to Fine on PASS" rule for a plan's last task, and which does **not** tell the agent to react to context-window percent on Cursor or Claude Code; `eversis-import-confluence-knowledge` gains a `docs/specs/`-clustering fallback for As-Is-Pack-uncovered modules; and `npm run sync:adapters:check` passes with every change propagated to the generated Cursor and Claude Code adapters.

**Do NOT touch / do NOT add**:
- Phases 4-7 from the research (typ `decisions`/ADR, knowledge status lifecycle, retrieval levels 2-4, As-Is Pack sync draft in Fine) — each is a separate, future Jira ticket per the research's explicit staging decision.
- An `Audit` (tasks-since-last-audit) readiness line — no persistence mechanism exists for it anywhere in the codebase; deferred to the future Phase 5 ticket, which already touches the same frontmatter/workflow surface (Plan Review B4; confirmed with the reporter).
- A brand-new bootstrap skill — the framework already has `eversis-import-confluence-knowledge`, which already does the Confluence-first half of the design; this plan extends it instead of shipping a second, competing mechanism (Plan Review B1; confirmed with the reporter).
- `eversis-promote-domain-knowledge`'s target path — verified already correct (`docs/context/<project>/<component>/index.md`), do not change it.
- `mcp/eversis-collections-mcp` (TypeScript source) — `eversis_context_list`/`get`/`sync` already implemented and unchanged by this plan.
- Any `INDEX.md` row gaining a third column — the parser at `context.ts:114` silently drops any row that isn't exactly two columns; per-component metadata belongs in the component file's frontmatter, never a new column (Plan Review B3).
- A new `context-pack.yaml` or any other parallel per-run manifest file format (research Question 3: rejected in favour of extending the existing Implement readiness block).
- A multi-process coordinator/worker runtime (research Question 5: Agent-tool role delegation already satisfies the needed pattern).
- Executing the extended `eversis-import-confluence-knowledge` process against any specific consumer repo (e.g. EOG) — that is the consumer repo's own follow-up task, not part of this plan's Definition of Done.
- Broader public-docs-site documentation of the full Phase 1-7 architecture beyond the one wording fix in `domain-context.md` — left as an explicit open item for the reporter (see Open Questions).
- A context-window ~50% trigger in the agent rule for Cursor IDE, Cursor CLI, or Claude Code — the agent cannot observe window fill there, so the instruction is misleading (research DELTA 2026-09-21, approved). PI Agent is the follow-up, not this plan.
- PI Agent install work (`context_info`, `pi-rolling-compaction`, `.pi/settings.json`) — follow-up when that host is installed, not part of this plan's Definition of Done.

## Proposed Solution

Three phases, each a narrow, additive change to existing files — no new file formats, no new top-level directories, no app code, and (after plan review) no new skill package either:

**Phase 1** tightens the read-budget rule already present in `agent-core.md` (lines 30-36) by replacing its single ambiguous fallback clause with an explicit two-cost model: *discovery* (grep/glob for filenames or topic matches across `docs/specs/**`, always allowed, loads no content) versus *consumption* (loading full file content, capped at 1-2 files total, whether the match came from `INDEX.md`'s `related_specs` or from discovery). This removes the loophole identified in research Question 7, where "fall back to `docs/specs/` when the component has no entry yet" was, in practice, the default case (an empty `INDEX.md`) rather than the exception. Phase 1 also closes a router gap plan review found independently: the framework's existing `eversis-import-confluence-knowledge` skill writes `docs/context/<project>/<domena>/<temat>.md`, a shape `eversis_context_get` cannot resolve (it only resolves `<component>/index.md`) — so Phase 1 fixes that skill's target path before Phase 2 adds more content through it, and updates the two docs pages (public site + in-repo `docs/context/README.md`) that describe the router.

**Phase 2** makes Phase 1's tightened router self-correcting instead of silently degrading again — a visible signal (in the existing Implement readiness block's Layer A, now correctly holding the block's actual definition rather than duplicated across all five contract files) when `INDEX.md` is empty — and closes the one real gap in the framework's *existing* Confluence-first bootstrap mechanism (`eversis-import-confluence-knowledge`, already Confluence-first, already one-time/manual, already writing `INDEX.md` rows) rather than building a second, competing skill: a `docs/specs/`-clustering fallback for modules an As-Is Pack does not cover, plus a "no As-Is Pack at all" branch. Plan review found this existing skill during its own verification pass — the research's Question 9 conclusion that a "trzeci, dziś nieistniejący mechanizm" was needed was itself a re-derivation of a decision DHI-630 had already made and shipped; this plan corrects that instead of repeating it.

**Phase 3** adds a new orchestration rule for the Implement step: when either of two agent-observable signals fires first — 5-10 prompt/response exchanges, or the task reaching a completed-and-tested state while further tasks remain in the plan (this rule explicitly defers to "proceed to Fine on PASS" for a plan's *last* task — the two would otherwise contradict each other) — the agent writes a structured checkpoint into the plan's existing Changelog field and ends the session cleanly, rather than continuing toward the harness's automatic compaction. A context-window ~50% signal is **not** one of those triggers for Cursor or Claude Code (research DELTA 2026-09-21): the agent cannot read window fill on those hosts, and stating it in the rule is misleading. That signal returns only as a PI Agent follow-up. A new, independent `Resume` line on the readiness block (Layer A only — never a `Flow` value, so a resumed session keeps its governing `Flow` declaration, e.g. `Full`) is how a fresh session recognizes and reads that checkpoint — closing a gap plan review found in the original design: nothing previously defined how a fresh session would know to resume instead of restarting from scratch. Task 2.1 (Phase 2) introduces the `Resume` line's existence in the readiness contract; Task 3.1 (this phase) defines the `CHECKPOINT:` format it reads — each references the other, so neither is independently verifiable until both land; Phase 4's review covers the pair together.

```text
Phase 1                              Phase 2 (Layer A: 2 files)             Phase 3
--------                             --------                               --------
agent-core.md                    →   engineering-manager.md +           →   eversis-orchestrating-
(read budget: discovery              orchestrating-implementation           implementation.md
 vs consumption split)                (+ Context line, + independent        (+ zero-compaction rule:
     |                                 Resume line — never a Flow            turns | done+tested;
eversis-import-confluence-             value; Audit deferred to a            no window% for Cursor/Claude)
knowledge/SKILL.md                     future Phase 5 ticket)                 → CHECKPOINT: entry in
(fix component-file path:                    |                                Changelog → end session,
 <component>/index.md,               eversis-import-confluence-               resumed via Resume: line
 not <domena>/<temat>.md)             knowledge/SKILL.md                     (independent of Flow)
     |                                (+ docs/specs/ clustering
docs/context/README.md +              fallback, + no-As-Is-Pack
domain-context.md                     branch, + bootstrap-report
(wording fixes: router +              example, both two-column)
 discovery/consumption split)
```

`eversis-import-confluence-knowledge/SKILL.md` is touched in both Phase 1 (path-shape fix) and Phase 2 (new fallback content) — Phase 2's Task 2.2 builds on Phase 1's Task 1.2, not on the file's original state.

Full 7-phase target diagram (this plan covers the top of it only): `docs/specs/ac-2/ac-2.research.md`, "Relevant Charts & Diagrams", Diagram 2.

## Current Implementation Analysis

### Already Implemented

- Read-budget rule (partial, needs tightening) - `.ai/rules/orchestration/agent-core.md:30-36`
- `eversis_context_list` / `eversis_context_get` / `eversis_context_sync` MCP tools - `mcp/eversis-collections-mcp/src/{server.ts,context.ts}` - reused unchanged
- `eversis-promote-domain-knowledge` skill, correct target path - `.ai/skills/eversis-promote-domain-knowledge/SKILL.md` - reused unchanged
- `eversis-audit-domain-knowledge` skill (Keep/Update/Consolidate/Replace/Delete), currently unwired - `.ai/skills/eversis-audit-domain-knowledge/SKILL.md` - **narrowly touched** (Task 1.2, one sentence on `code_paths`/`Delete` — Plan Review B6), otherwise reused unchanged; its "since last audit" persistence gap is real but deferred to Phase 5, not fixed here
- `eversis-import-confluence-knowledge` skill (Confluence-first bootstrap, already writes `INDEX.md` rows) - `.ai/skills/eversis-import-confluence-knowledge/SKILL.md` - **extended, not replaced** — found during plan review; the plan's original Open Question 3 never considered it (see corrected Open Question 3 below)
- Implement readiness block contract, normatively 4 required lines - the *wording* is asserted in **five** files (`.ai/rules/orchestration/engineering-manager.md`, `.ai/rules/orchestration/spec-driven-development.md`, `.ai/rules/orchestration/README.md`, `.ai/prompts/public/eversis-implement.md`, `.ai/skills/eversis-orchestrating-implementation/SKILL.md`), but the block's literal *shape* is defined only in the first and last of those (Layer A) - the new `Resume` and `Context` lines land there only; the other three (Layer B) only get reworded line-count phrasing
- Plan `Changelog` field (target for zero-compaction checkpoints) - `.ai/skills/eversis-creating-implementation-plans/plan.example.md` - reused, given a documented checkpoint sub-format (not restructured)
- Adapter generation pipeline (`.ai/` → Cursor rules + Claude Code `CLAUDE.md`) - `adapters/sync.mjs`, `adapters/claude/generate.mjs`, `adapters/cursor/generate.mjs` - reused unchanged, run after every `.ai/` edit

### To Be Modified

- `.ai/rules/orchestration/agent-core.md` - discovery/consumption split, narrowed fallback clause
- `.ai/skills/eversis-import-confluence-knowledge/SKILL.md` - Phase 1: fix component-file target path, explicit empty `code_paths`/`related_specs`; Phase 2: add `docs/specs/` clustering fallback, no-As-Is-Pack branch, Step 6 pessimism correction
- `.ai/skills/eversis-audit-domain-knowledge/SKILL.md` - one sentence: empty/absent `code_paths` on a `source: confluence` component signals `Update`, never `Delete` (Plan Review B6 — the one narrow touch to a skill otherwise left alone)
- `docs/context/README.md` - name `INDEX.md` as the mandatory router, state its two-column format
- `website/docs/reference/domain-context.md` - correct the router description to mention the discovery/consumption split
- **Readiness-contract Layer A** (define the literal block, gain the new `Resume` and `Context` optional lines — `Resume` is independent, never a `Flow` value): `.ai/rules/orchestration/engineering-manager.md`, `.ai/skills/eversis-orchestrating-implementation/SKILL.md` — plus updated self-checks and `Reason`-line ordinal wording (Plan Review W6, W7)
- **Readiness-contract Layer B** (delegate to Layer A today; only reword their line-count description, never gain a duplicated block definition): `.ai/rules/orchestration/spec-driven-development.md`, `.ai/rules/orchestration/README.md`, `.ai/prompts/public/eversis-implement.md` (Plan Review W6 — an earlier draft of this plan wrongly required identical wording across all five)

### To Be Created

- `.ai/skills/eversis-import-confluence-knowledge/bootstrap-report.example.md` - worked example of the `docs/specs/`-fallback output (component rows from both an As-Is Pack module and raw `docs/specs/` clustering), for a human to review before writing anything

## Open Questions

| # | Question | Answer | Status |
| --- | --- | --- | --- |
| 1 | Should the full Phase 1-7 architecture be documented on the public website, or only the small Phase-1 wording fix in `domain-context.md`? | This plan does only the small fix (Task 1.4). Full documentation of Phases 1-7 is recommended as a separate, future ticket (matches the DHI-641/DHI-652/DHI-653 precedent of dedicated docs-IA tickets) — left as an explicit open item in the Jira ticket for the reporter to confirm before or independently of this plan. | ✅ Resolved (for this plan's scope) |
| 2 | Where should the new zero-compaction orchestration rule live — `agent-core.md` (always-on, every phase) or `eversis-orchestrating-implementation` (Implement-phase-specific)? | `eversis-orchestrating-implementation`, "Execution rules and gates" section — the rule only applies while a session is actively implementing, matching that section's existing numbered in-Implement rules (1-13, verified). `agent-core.md` stays a lifecycle-wide, phase-agnostic file. | ✅ Resolved |
| 3 | Should the bootstrap mechanism be a new skill, or a new mode of `eversis-promote-domain-knowledge` / `eversis-audit-domain-knowledge`? | **Corrected during plan review (2026-09-21) — this question itself was framed wrong.** It compared only `promote` and `audit` and never considered the one existing skill that actually matches: `eversis-import-confluence-knowledge` — already Confluence-first, already one-time/manual (`user-invocable: true`), already writes `INDEX.md` rows at its own Step 5. Extend that skill (Task 2.2) instead of creating a new one; the only genuinely missing capability is the `docs/specs/` clustering fallback and the no-As-Is-Pack branch. | ✅ Resolved (corrected) |
| 4 | Does the `Audit` readiness signal ship with real persistence, an approximate heuristic, or get deferred? | **Deferred to the future Phase 5 ticket** (confirmed with the reporter, 2026-09-21) — no mechanism anywhere persists "tasks since last audit" (`eversis-audit-domain-knowledge` is `user-invocable: true` with no orchestration trigger that could stamp a run), and Phase 5 (status lifecycle) already touches the same frontmatter/workflow surface. Only the zero-cost `Context: N components` signal (backed by `listContext().length`, no MCP change needed) ships in this plan. | ✅ Resolved |
| 5 | How does a fresh session know to resume a zero-compaction checkpoint instead of restarting from scratch? | **Corrected after code review + independent logical-analysis pass (2026-09-21) — the first answer to this question shipped a category error.** `Resume` is an **independent optional line** on the readiness block (`- **Resume:** CHECKPOINT <date>`), not a value of `Flow` — a `Flow` enum value would have made `Resume` mutually exclusive with `Full` (this plan's own required flow), losing the governing-flow declaration on exactly the sessions meant to resume it. Read against a `CHECKPOINT:`-prefixed entry in the plan's `Changelog`. This ties Task 2.1 (introduces the `Resume` line, Layer A only — 2 files, not five) and Task 3.1 (defines the `CHECKPOINT:` format it reads) into one coherent change; each task references the other, so neither is independently verifiable until both land — Phase 4's review covers the pair together (see Technical Context → Architecture & Patterns for the corrected Layer A/B split). | ✅ Resolved (corrected) |
| 6 | Should rule 14 tell the agent to checkpoint when the context window is ~50% full? | **No, for Cursor IDE, Cursor CLI, and Claude Code.** The agent cannot observe window fill on those hosts (comparison note, 2026-09-21; research DELTA, approved "Research is ok"). Naming the trigger in the agent rule is misleading. Task 3.2 removes it from the landed rule. It returns only as a follow-up when PI Agent is installed (`context_info` / `pi-rolling-compaction`). This row does not decide the exchange-count window, Continuity precedence beyond the last task, or the operator sentence for opening a new chat. | ✅ Resolved |
| 7 | Should the live Jira AC-2 Description be rewritten to match shipped Phases 1–3? | **Yes.** Question 10 (`ac-2.research.md`) recorded the Description as stale; the reporter accepted that DELTA (`"Accept DELTA"`, 2026-09-21). Phase 5 updates **only** the `description` field. Do not reopen promote-skill tightening, `changelog.md` mandatory rollover, audit-counter persistence, `eversis-fine-handoff`, or `AGENTS.md` — those stay out of this ticket (Improvements / Phase 5 Do NOT). | ✅ Resolved |

## Technical Context

Project conventions, coding standards, and patterns discovered during planning. Downstream agents MUST read this section instead of re-discovering the same context.

### Project Instructions

- `.ai/rules/orchestration/*.md` are the canonical (SSOT) rule sources; Cursor rules (`.cursor/rules/`) and Claude Code's `CLAUDE.md` are **generated** from them by `adapters/sync.mjs` — never hand-edit generated output, only the `.ai/` source, then run the generator.
- This framework repository gitignores all `docs/specs/*/` subfolders except `README.md` (local-only story work) — `docs/specs/ac-2/` (this folder) will not be committed; the committed surface for this plan's changes is `.ai/`, `docs/context/README.md`, `website/`.

### Architecture & Patterns

- Skill files: YAML frontmatter (`name`, `description`, `user-invocable`) + Markdown body, validated by the `eversis_skills_validate` MCP tool. Optional companion `*.example.md` files show a worked output (e.g. `eversis-promote-domain-knowledge/knowledge-entry.example.md`) — follow this pattern for `bootstrap-report.example.md`.
- **The Implement readiness block's line-count wording is a normative contract asserted in five separate files, not two** (an earlier draft of this plan assumed two — verified wrong during plan review), but the contract splits into two layers, not one homogeneous set (Plan Review iteration 2, W6): **Layer A** (`engineering-manager.md`, `eversis-orchestrating-implementation/SKILL.md`) defines the literal block — its shape, the `Flow` enum, optional lines — and is the only place a shape change (new line, new enum value) lands. **Layer B** (`spec-driven-development.md`, `orchestration/README.md`, `eversis-implement.md`) only references the line count in prose and delegates the actual definition to Layer A / Step 1 — it never gains new content, only reworded line-count phrasing. A block-**shape** change (e.g. a new optional line) touches Layer A only; a **wording** change confirming "four required lines" reads correctly touches all five. The single verified check: `grep -rniE 'exact four-line|exactly four bullet|exactly four' .ai/` returns zero (the closed-at-four phrasing is retired everywhere), and `grep -l 'four required lines' <all five file paths>` lists all five. `engineering-manager.md`'s self-check #2 and the orchestrating-implementation skill's equivalent self-check (both Layer A) must be updated in the same task as any Layer A shape change, or an agent following its own self-check would reject its own correct, extended output.
- **`docs/context/<project>/INDEX.md` rows MUST remain exactly two columns** (`| component | one-line summary |`). `mcp/eversis-collections-mcp/src/context.ts:114`'s parser regex (`/^\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*$/`) is anchored immediately after the second column; any row with a third column fails to match and is silently dropped (`continue`, no error, no log) — the component then simply disappears from `eversis_context_list`. Per-component metadata belongs in the component file's own frontmatter (`upsertFrontmatterField()`, `context.ts:72`, already exists for exactly this), never as an `INDEX.md` column.
- **`eversis_context_get`'s `getContext()` (`context.ts:179`) resolves exactly one path shape**: `<projectContextPath>/<component>/index.md` (and the equivalent under `globalContextPath`). Any write path that emits a different granularity (e.g. `eversis-import-confluence-knowledge`'s original `<domena>/<temat>.md`, one file per Confluence section) produces content the router cannot reach — `getContext()` throws `No docs/context entry for component "<x>"` for anything else. Task 1.2 fixes the one skill in this plan's blast radius that violated this. **Write paths covered by this invariant as of AC-2**: `eversis-promote-domain-knowledge` (Step 4), `eversis-import-confluence-knowledge` (Step 4), `eversis-audit-domain-knowledge` (in-place edit of existing files, no new-file write). Any future skill writing to `docs/context/` appends itself to this list (Plan Review S5).
- `.ai/skills/eversis-orchestrating-implementation/SKILL.md`'s "Execution rules and gates" section is a flat, numbered list of in-Implement behavioral rules, verified numbered **1-13** — new Implement-phase rules are appended there (rule 14 is the correct next number), not invented as a new section.

### Tech Stack

- Node.js, zero-npm-dependency scripts (`adapters/sync.mjs`, `adapters/website/generate.mjs`); no package manager install needed to run them.
- No compiled application code is touched by this plan — Phase 1-3 scope is entirely Markdown rules/skills/docs. `mcp/eversis-collections-mcp` (TypeScript) is explicitly out of scope (already implements everything this plan needs — `listContext()` already returns an array, no MCP change required for the `Context` signal).

### Code Style & Standards

- English for orchestration rule files (`agent-core.md`, `engineering-manager.md`, `eversis-orchestrating-implementation/SKILL.md`, `eversis-import-confluence-knowledge/SKILL.md`) — matches their current language, do not switch to Polish.
- Skill frontmatter fields exactly as `eversis_skills_validate` expects: `name`, `description`, `user-invocable` (boolean). Do not change `eversis-import-confluence-knowledge`'s existing frontmatter values in Task 2.2 — only its body content.

### Testing Patterns

- `npm run sync:adapters:check` — verifies the generated Cursor/Claude Code adapters match the `.ai/` source; run after every `.ai/rules` or `.ai/skills` edit in this plan. Run `npm run sync:adapters` first (no `--check`) to actually regenerate, then `--check` to confirm no drift remains.
- `eversis_skills_validate` (MCP tool, `eversis-collections-mcp` server) — validates a skill directory's structure/frontmatter; run against `.ai/skills/eversis-import-confluence-knowledge/` after Task 2.2.
- **This repo cannot self-test Task 2.1's `N > 0` branch as-is**: `docs/context/agent-collections/` (this repo's own project-level context dir) has no `INDEX.md` today — only `task-baseline.md` and `delivery-index.md` — because `docs/context/*/` subfolders are gitignored here (see `docs/context/README.md`, "Framework repository" section), so `listContext()` returns `[]`. Both branches are reachable, but only **sequentially, in this order**: (1) confirm the `0` branch against the repo's current state (no `INDEX.md`), *then* (2) add a local, uncommitted two-row `INDEX.md` fixture under `docs/context/agent-collections/` and confirm the `N > 0` branch against it. Do not skip straight to (2) — the `0` branch has no separate fixture of its own; the absence of one **is** the test.
- No unit/e2e test suite applies to this plan's scope (rules, skills, and docs — not application code).

### Database Patterns

- N/A — no database involved in this plan's scope.

### Additional Context

- This plan's scope is strictly Phases 1-3 of the 7-phase staging table in `ac-2.research.md`, Question 9 — Phases 4-7 are explicitly out of scope, each a separate future Jira ticket per the research's recorded human decision. The `Audit` readiness signal (deferred per Open Question 4) is a new addition to what Phase 5 will need to cover.
- `eversis-promote-domain-knowledge`'s target path (`docs/context/<project>/<component>/index.md`) was verified during research to already match DHI-630's approved plan — no change needed; do not "fix" it. This is the correct structural model Task 1.2 brings `eversis-import-confluence-knowledge` into line with.
- `eversis-import-confluence-knowledge`'s own principles block already cites `global-domain-context-ssot.research.md, Question 1` as the source of its one-time-not-live design — this plan's Task 2.2 extends that lineage rather than starting a parallel one.

## Implementation Plan

### Phase 1: Router + read budget + write-path granularity fix

**Goal**: Replace the single, loophole-prone fallback clause in the domain-knowledge read-budget rule with an explicit discovery/consumption split, and make every existing write path into `docs/context/` emit a file shape the router can actually resolve.

**Description**: `agent-core.md`'s existing 4-step read order (lines 30-36) already tells an agent to read `INDEX.md` first, then one component, then `related_specs` sparingly. Its last sentence does not distinguish a cheap filename search from an expensive full-content read, letting both through under the same permission — this phase splits that into two named costs. Separately, plan review found that `eversis-import-confluence-knowledge` (the framework's existing Confluence-seed skill) writes a file granularity `eversis_context_get` cannot resolve; fixing that here, before Phase 2 adds more content through the same skill, keeps the two phases from compounding the same defect. Two documentation pages (public site + in-repo README) are updated to describe the corrected router.

**Verification:** `npm run sync:adapters:check`

#### Task 1.1 - [MODIFY] Split the read-budget fallback into discovery vs. consumption

**Description**: Rewrite the numbered read-order list in `agent-core.md` (the "When reading `docs/context/` for domain knowledge..." block) so its final step names two distinct actions instead of one fallback: **discovery** (grep/glob across `docs/specs/**` for filenames or topic matches — always allowed, loads no file content) and **consumption** (loading the full content of any matched file, or of a `related_specs`/`confluence_url` entry) — capped at 1-2 files total regardless of which route produced the match. Explicitly reject `docs/plan/INDEX.md` / `docs/plans/INDEX.md` as an alternative router path (there must be exactly one: `docs/context/<project>/INDEX.md`, plus `docs/context/global/INDEX.md` when the topic is not local).

**Files:** `.ai/rules/orchestration/agent-core.md` (modify)

**Definition of Done**:

- [x] The read-order block contains the words "discovery" and "consumption" as two distinct, separately described actions (not a single merged fallback sentence)
- [x] The consumption description states a cap of 1-2 files, applying identically whether the match came from `related_specs`/`confluence_url` or from discovery
- [x] The block states explicitly that no other in-repo router (`docs/plan/INDEX.md`, `docs/plans/INDEX.md`) is used
- [x] Run `npm run sync:adapters` then `npm run sync:adapters:check` — zero drift between `.ai/rules/orchestration/agent-core.md` and the generated Cursor/Claude Code output

**Clues**: The exact current wording to replace is at `agent-core.md:30-36` (research `ac-2.research.md` Question 7 quotes it verbatim). Keep steps 1-3 of the existing numbered list unchanged — only step 4 (the fallback) changes.

#### Task 1.2 - [MODIFY] Unify the component-file granularity contract in `eversis-import-confluence-knowledge`, and stop empty `code_paths` from reading as `Delete`

**Description**: Correct Process Step 4 of `eversis-import-confluence-knowledge/SKILL.md` so it writes `docs/context/<project>/<component>/index.md` — consolidating every Confluence section that belongs to the same functional component into one file — instead of `docs/context/<project>/<domena>/<temat>.md` (one file per section). This makes the skill's output shape match `getContext()`'s single resolvable path and `eversis-promote-domain-knowledge`'s already-correct convention (Plan Review B5). Content written before this fix would otherwise be invisible to `eversis_context_get`, silently undermining the very router Phase 1 tightens.

This fix has a second-order consequence plan review caught (B6): once import-skill output lands at `<component>/index.md`, it becomes visible to `eversis-audit-domain-knowledge`'s Step 1 iteration for the first time — but `eversis-promote-domain-knowledge`'s Step 4 frontmatter includes `code_paths` and `related_specs`, while `eversis-import-confluence-knowledge`'s Step 4 does not. The audit skill's own Delete criterion is "`code_paths` point at nothing" — an absent or empty `code_paths` array reads as exactly that, misclassifying freshly-imported, never-stale knowledge for deletion. Close this in the same task: (a) make Step 4 emit `code_paths: []` and `related_specs: []` explicitly (present, not omitted), with an instruction to populate `code_paths` when the source As-Is Pack section names code modules; (b) add one sentence to `eversis-audit-domain-knowledge` Step 1 stating that an empty or absent `code_paths` on a `source: confluence` component means "not yet mapped to code," never a `Delete` signal — the correct outcome is `Update` (map the paths), not deletion. This is the one place this plan opens `eversis-audit-domain-knowledge`, previously declared untouched — narrowly, for this one sentence.

**Files:** `.ai/skills/eversis-import-confluence-knowledge/SKILL.md` (modify), `.ai/skills/eversis-audit-domain-knowledge/SKILL.md` (modify — one sentence only)

**Definition of Done**:

- [x] Process Step 4 of `eversis-import-confluence-knowledge` states the target path as `docs/context/<project>/<component>/index.md`, not `<domena>/<temat>.md`
- [x] Step 4 explicitly instructs consolidating multiple Confluence sections describing the same functional component into one file, rather than one file per section
- [x] Step 4 states that `code_paths: []` and `related_specs: []` are written explicitly (present, empty arrays), not omitted, and instructs populating `code_paths` when the source section names code modules
- [x] `eversis-audit-domain-knowledge` Step 1 states that empty/absent `code_paths` on a `source: confluence` component signals `Update` (needs mapping), never `Delete`
- [x] `eversis_skills_validate` on both `.ai/skills/eversis-import-confluence-knowledge/` and `.ai/skills/eversis-audit-domain-knowledge/` returns zero errors
- [x] Run `npm run sync:adapters` then `npm run sync:adapters:check` — zero drift

**Clues**: Beyond the one-sentence `code_paths`/`Delete` fix, do not otherwise touch `eversis-audit-domain-knowledge`'s Keep/Update/Consolidate/Replace/Delete logic — everything else in that skill stays as-is. Do not touch Steps 1-3, 5, 6 of `eversis-import-confluence-knowledge` in this task; Task 2.2 (Phase 2) extends Steps 5-6 separately, building on this task's result.

#### Task 1.3 - [MODIFY] Name `INDEX.md` as the mandatory router in `docs/context/README.md`

**Description**: `docs/context/README.md` (the file a human or agent actually reads while scaffolding a new project's `docs/context/<project>/`) currently says only "use clear filenames" and documents `task-baseline.md` — the word `INDEX.md` does not appear anywhere in it. Add two sentences naming `INDEX.md` as the one mandatory router and stating its required two-column format, closing the adoption gap the research found in EOG (0 rows after 28 closed tasks) at the point of first contact, not only at read time (Plan Review W2).

**Files:** `docs/context/README.md` (modify)

**Definition of Done**:

- [x] The file names `INDEX.md` explicitly as the mandatory router for this directory
- [x] The file states the two-column format (`| component | one-line summary |`), matching Technical Context → Architecture & Patterns
- [x] No other section of the file is restructured (small, additive fix only)

**Clues**: This file is not part of the generated-adapter pipeline — no `sync:adapters:check` needed for this task alone, but the two-column wording here must stay identical to Task 1.1's `agent-core.md` wording and Task 2.2's example rows.

#### Task 1.4 - [MODIFY] Correct the public docs page for the router

**Description**: `website/docs/reference/domain-context.md` already correctly describes the two-layer `docs/context/` structure (project + global, both flat, no `/knowledge/` segment) — it just doesn't yet describe the discovery/consumption split from Task 1.1. Add a short paragraph or table row covering it, consistent with the corrected `agent-core.md` wording.

**Files:** `website/docs/reference/domain-context.md` (modify — reuse existing page structure, do not restructure the page)

**Definition of Done**:

- [x] The page mentions both "discovery" and "consumption" (or equivalent plain-language phrasing) as distinct costs, matching Task 1.1's split
- [x] No other section of the page is restructured or removed (small, additive wording fix only — per the research's explicit scope decision to keep the broader Phase 1-7 documentation out of this ticket)

**Clues**: This page is hand-authored, not generated — `adapters/website/generate.mjs` does not reference it, so no `sync:website-docs:check` run is needed for this task.

### Phase 2: Enforced hygiene signal + bootstrap fallback extension

**Goal**: Make Phase 1's tightened router self-correcting rather than silently degrading again — surface when `INDEX.md` is empty — and give the framework's existing Confluence-first bootstrap skill the one capability it is missing, instead of building a second, competing mechanism.

**Description**: Plan review found that the original design of this phase was built on two mistaken premises: that the Implement readiness contract lives in two files (it lives in five), and that no bootstrap mechanism exists (`eversis-import-confluence-knowledge` already does the Confluence-first half). This phase corrects both: it extends the readiness block's `Context` signal and new `Resume` value across all five contract files, and it extends `eversis-import-confluence-knowledge` (already Confluence-first, already one-time/manual, already writing `INDEX.md` rows, and as of Phase 1 already writing the correct file granularity) with the one thing it is missing — a `docs/specs/`-clustering fallback for modules an As-Is Pack does not cover, and a branch for projects with no As-Is Pack at all. The previously-planned `Audit` (tasks-since-last-audit) line is deliberately **not** part of this phase — no mechanism anywhere persists that count, so it would have shipped inert; it is deferred to the future Phase 5 ticket (Open Question 4, confirmed with the reporter).

**Verification:** `eversis_skills_validate` on `.ai/skills/eversis-import-confluence-knowledge/`; `npm run sync:adapters:check`; plus a local, uncommitted two-row `INDEX.md` fixture under `docs/context/agent-collections/` to smoke-test `eversis_context_list` and both branches of the `Context` line (this repo's own context dir has none today — see Technical Context → Testing Patterns).

#### Task 2.1 - [MODIFY] Extend the readiness contract: `Resume` + `Context` optional lines on Layer A, reworded line-count language on Layer B

**Description**: The five files that touch the Implement readiness contract split into two layers, not one homogeneous set (Plan Review W6 — an earlier draft of this plan wrongly required "identically across all five," which would have forced duplicating the block's literal definition into three files that today deliberately delegate it). **Layer A** (`engineering-manager.md`, `eversis-orchestrating-implementation/SKILL.md`) contains the literal block — `Flow:` enum, bullet lines, the existing "Optional fifth line: `Reason:`" — and is where the new content actually lands: one new optional `Context` line (reporting `docs/context/<project>/INDEX.md`'s component count via `listContext().length`, flagging `0` as a visible-but-non-blocking signal, no CI/git gate, consistent with DHI-630's earlier staleness decision) and one new, **independent** optional `Resume` line (`- **Resume:** CHECKPOINT <date>`), read against a `CHECKPOINT:`-prefixed entry in the plan's `Changelog` (the format Task 3.1, Phase 3, defines). **`Resume` is not a `Flow` value** — an earlier version of this task added it to the `Flow` enum, a category error caught independently by code review and a logical-analysis pass after implementation: `Flow` answers "which workflow" (`Quick`/`Full`/`QA follow-up`), `Resume` answers "is this a continuation," and collapsing them into one enum made `Resume` mutually exclusive with `Full` — this plan's own required flow — so a resumed session would have had no way to still declare `Full`. A separate line keeps the two independent and lets a resumed session carry its own date. Because `Reason` already exists as an optional fifth line in both Layer A files (Plan Review W7), rephrase "Optional fifth line" so the optional additions (`Resume`, `Context`, `Reason`) are described as a set, not a fixed ordinal position — none is uniquely "fifth" once more than one can appear. Update both files' self-checks so neither would reject the block's own new, correct output. **Layer B** (`spec-driven-development.md`, `orchestration/README.md`, `prompts/public/eversis-implement.md`) only references the block's line count today (never enumerates `Flow`'s values) — reword their "four-line" / "exact four-line" phrasing to describe the block as having four required lines plus optional signals, preserving their existing delegation to Layer A / Step 1, and add no new content there.

**Files:** `.ai/rules/orchestration/engineering-manager.md` (modify — Layer A), `.ai/skills/eversis-orchestrating-implementation/SKILL.md` (modify — Layer A), `.ai/rules/orchestration/spec-driven-development.md` (modify — Layer B, wording only), `.ai/rules/orchestration/README.md` (modify — Layer B, wording only), `.ai/prompts/public/eversis-implement.md` (modify — Layer B, wording only)

**Definition of Done**:

- [x] Layer A: both `engineering-manager.md` and `eversis-orchestrating-implementation/SKILL.md` show the same new optional `Resume` line and the same new optional `Context` line, worded identically between the two; `Resume` is **not** a `Flow` enum value — `Flow`'s three values (`Quick`/`Full`/`QA follow-up`) are unchanged
- [x] Layer A: both files' "Optional fifth line" wording is rephrased to describe optional additions (`Resume`, `Context`, `Reason`) as a set, not a fixed ordinal position
- [x] Layer A: `engineering-manager.md`'s self-check #2 and `eversis-orchestrating-implementation/SKILL.md`'s equivalent self-check are updated to list the new optional additions (`Resume`, `Context`) — `Resume` is an independent line, not a new `Flow` value; `Flow`'s enum is unchanged at three values (wording corrected post re-review — see Changelog, "Full re-review performed" entry)
- [x] Layer B: each of the three files is reworded to describe the block as "four required lines plus optional signals" (or equivalent), with no duplicated block definition and no change to their existing delegation to Layer A / Step 1
- [x] `grep -rniE 'exact four-line|exactly four bullet|exactly four' .ai/` returns **zero** matches (the closed-at-four phrasing is fully retired, not merely reworded elsewhere)
- [x] `grep -l 'four required lines' .ai/rules/orchestration/engineering-manager.md .ai/skills/eversis-orchestrating-implementation/SKILL.md .ai/rules/orchestration/spec-driven-development.md .ai/rules/orchestration/README.md .ai/prompts/public/eversis-implement.md` lists all five files (each contains **at least one** occurrence — natural repetition, e.g. a self-check restating it, is fine; the earlier plan draft's "once each" was itself over-specified and is not the real invariant)
- [x] The `Context` line's documented example shows the "0 components" case with no CI/git block language nearby
- [x] Run `npm run sync:adapters` then `npm run sync:adapters:check` — zero drift

**Stop Rule:** If expressing the `Context`/`Resume` additions cleanly on Layer A would need more than 2 new optional additions **beyond the existing `Reason` line**, stop and flag it — that would be a bigger readiness-contract change than this task's scope.

**Clues**: `Audit` (tasks-since-last-audit) is deliberately not part of this task — see Improvements (Out of Scope), deferred to a future Phase 5 ticket per Open Question 4.

#### Task 2.2 - [MODIFY] Extend `eversis-import-confluence-knowledge` with the `docs/specs/` clustering fallback

**Description**: `eversis-import-confluence-knowledge` already implements the Confluence-first half of a bootstrap mechanism (Process Steps 1-5, and as of Task 1.2 writing the correct file granularity). Add: (a) a fallback that clusters raw `docs/specs/*/` folders by the code paths or topics they touch, applying the same cross-task-worthiness judgment `eversis-promote-domain-knowledge` Step 1 already uses, for any module the As-Is Pack itself flags as undocumented; (b) a "no As-Is Pack at all" branch that runs the same `docs/specs/` clustering as the sole source when `ssot.confluenceSpaceKey` is null and no equivalent structured doc exists; (c) a `bootstrap-report.example.md` companion showing a complete worked example, with at least one candidate row sourced from an As-Is Pack module and one from raw `docs/specs/` clustering, using two-column `INDEX.md` row examples per the Technical Context invariant. Also correct the skill's existing Step 6 pessimism ("very likely still mostly template placeholders") to note this is project-dependent, not universal — this plan's own research verified the opposite for a real As-Is Pack (4/6 sections complete, a ready 10-module map, 3 fully described modules) (Plan Review S3). State explicitly, as the skill already does for its Confluence-only path, that running any of this against a specific consumer repo's actual data remains that repo's own follow-up task, never part of an `agent-collections` ticket's Definition of Done.

**Files:** `.ai/skills/eversis-import-confluence-knowledge/SKILL.md` (modify — path shape already corrected by Task 1.2), `.ai/skills/eversis-import-confluence-knowledge/bootstrap-report.example.md` (create)

**Definition of Done**:

- [x] `SKILL.md` describes the `docs/specs/` clustering fallback for As-Is-Pack-uncovered modules, using the same cross-task-worthiness criteria as `eversis-promote-domain-knowledge` Step 1
- [x] `SKILL.md` describes the "no As-Is Pack at all" branch as a distinct, named case, not an implicit fallthrough
- [x] `SKILL.md` Step 6 (now Step 7) states the "mostly template placeholders" assumption is project-dependent, citing a real, populated As-Is Pack as a counter-example
- [x] `SKILL.md` states explicitly that running this process against a specific consumer repo's data is that repo's own task, never this framework's Definition of Done
- [x] `bootstrap-report.example.md` contains at least 3 candidate component rows: at least one sourced from a hypothetical As-Is Pack module, at least one from raw `docs/specs/` clustering, all shown as two-column `INDEX.md` rows (`| component | one-line summary |`) per Technical Context's invariant
- [x] `eversis_skills_validate` on `.ai/skills/eversis-import-confluence-knowledge/` returns zero errors
- [x] Run `npm run sync:adapters` then `npm run sync:adapters:check` — zero drift

**Clues**: Do not rename the skill or change its frontmatter `name`/`user-invocable` fields — both are already correct for this capability (`user-invocable: true`, already Confluence-sourced, already one-time/manual).

### Phase 3: Session budget / zero-compaction discipline

**Goal**: Stop automatic compaction from being the thing that silently drops the current task during a long Implement session — give the agent an explicit, earlier off-ramp, with a defined way for a fresh session to resume instead of restarting from scratch.

**Description**: Research first converged on three end-session triggers (window ~50%, 5-10 exchanges, task completed+tested while further tasks remain). The approved research DELTA (2026-09-21) removes the window trigger from the agent rule for Cursor and Claude Code: the agent cannot observe window fill there, so the instruction is misleading. What remains in this phase is two agent-observable triggers — 5-10 prompt/response exchanges, or the current task reaching a completed-and-tested state while further tasks remain in the plan (deferring to "proceed to Fine on PASS" for a plan's last task). On either trigger (first one wins), write a `CHECKPOINT:`-prefixed entry to the plan's existing `Changelog` field (distinguishable from the table's other traffic — e.g. execution rule 12's solution-change entries) and end the session; a fresh session recognizes and resumes from that entry via the independent `Resume` line Task 2.1 adds to the readiness block (Layer A only — never a `Flow` value). Task 3.1 landed the rule including the window trigger; Task 3.2 removes that clause. A short adjoining note records that Agent-tool role delegation already provides the "ephemeral, stateless subagent" property this pattern needs — no separate multi-process architecture required. The ~50% signal is a PI Agent follow-up (Improvements), not text in the rule.

**Verification:** `npm run sync:adapters:check`

#### Task 3.1 - [MODIFY] Add the zero-compaction session rule and its Changelog checkpoint format

**Description**: Append a new numbered rule to `eversis-orchestrating-implementation/SKILL.md`'s "Execution rules and gates" section (this becomes rule 14). The agent triggers that remain after Task 3.2 are the exchange count and "completed+tested while further tasks remain" — not context-window percent. The first landing of this task also named a ~50% window trigger; Task 3.2 deletes that clause, and this task must not be re-run in a way that puts it back. Because the plan's `Changelog` field (`plan.example.md:224-227`) is a plain two-column `Date | Change Description` table with no structured place for a checkpoint, define a short sub-format for the `Change Description` cell — a `CHECKPOINT:` prefix followed by a state summary, the changed-files list, and the next step, on one row — so checkpoint entries stay distinguishable from ordinary entries (Plan Review W1). State that the independent `Resume` line on the readiness block (Task 2.1 — never a `Flow` value) is how a fresh session recognizes and reads this checkpoint. **Resolve the precedence conflict with rule 13** ("Proceed to Fine on PASS"), caught after implementation by an independent logical-analysis pass: for a plan's *last* task, the "task completed+tested" trigger and rule 13 fire simultaneously and prescribe opposite actions (end the session vs. proceed to Fine). State explicitly that rule 13 governs when the completed task is the plan's last one — the third trigger only applies "while further tasks remain in the plan." Add one adjoining sentence documenting that Agent-tool-based role delegation already satisfies the ephemeral-stateless-subagent property this pattern needs.

**Files:** `.ai/skills/eversis-orchestrating-implementation/SKILL.md` (modify)

**Definition of Done**:

- [x] As landed, the rule named three triggers (context window ~50%, 5-10 exchanges, task completed+tested while further tasks remain) as independently sufficient (OR, not AND). **Superseded by Task 3.2:** the window trigger must not remain in the rule. This checked box records what was first written, not permission to keep the ~50% clause.
- [x] The new rule defines the `CHECKPOINT:`-prefixed sub-format for the plan `Changelog`'s `Change Description` cell, distinguishable from rule 12's existing entries
- [x] The new rule states that the independent `Resume` line on the readiness block (Task 2.1 — not a `Flow` value) is how a fresh session recognizes and reads the checkpoint
- [x] The new rule explicitly states rule 13 takes precedence for a plan's last task — no contradictory instruction for the case where "task completed+tested" and "review passed" are both true at once
- [x] The adjoining note references Agent-tool role delegation (EM → Architect → Software Engineer) and states no separate multi-process architecture is required
- [x] Run `npm run sync:adapters` then `npm run sync:adapters:check` — zero drift

**Stop Rule:** If adding this rule would require renumbering more than the existing numbered list's trailing entries, stop and confirm placement before proceeding — do not silently renumber unrelated rules.

**Clues**: Verified: the list is numbered 1-13 as of this plan, ending "13. Proceed to Fine on PASS" — rule 14 is the correct next number. The "~50%" clause this task originally required is withdrawn by Task 3.2; do not treat a checked box above as permission to keep that clause.

#### Task 3.2 - [MODIFY] Remove the context-window ~50% trigger from rule 14

**Description**: Rule 14, as landed by Task 3.1, still tells the agent to checkpoint when "the context window reaching roughly half its capacity." Delete that trigger from the agent instruction. Do not replace it with an operator hint, a `/autocompact` step, or a hook. Leave the other two triggers (5-10 exchanges; task completed+tested while further tasks remain) and the existing rule-13 precedence for the plan's last task. Do not mention PI Agent in the skill. The reason is the approved research DELTA: on Cursor IDE, Cursor CLI, and Claude Code the model cannot read window fill, so the sentence is misleading. Restoring a ~50% trigger is a follow-up for a PI Agent install only (see Improvements).

**Files:** `.ai/skills/eversis-orchestrating-implementation/SKILL.md` (modify — rule 14 already added by Task 3.1)

**Definition of Done**:

- [x] Rule 14 does not instruct the agent to write `CHECKPOINT:` or end the session because the context window is about half full, or on any other window-fill percentage
- [x] Rule 14 still names the exchange-count trigger and the "completed+tested while further tasks remain" trigger as independently sufficient, and still states that rule 13 governs when that completed task is the plan's last task
- [x] Rule 14 does not name PI Agent, `context_info`, or `pi-rolling-compaction`
- [x] Run `npm run sync:adapters` then `npm run sync:adapters:check` — zero drift

**Clues**: One sentence deletion plus a trigger-count wording fix ("two" not "three"). Do not reopen the `Resume` / `Flow` split, the detection preamble, or the last-task precedence sentence.

### Phase 4: Code Review

**Goal**: Independently verify Phases 1-3 land together as one coherent, internally consistent change before Fine — the same isolation requirement already applied to every other Implement session in this framework.

**Description**: Final verification of the complete Phase 1-3 implementation. This phase is the last **code** gate. Ticket-text hygiene after the approved Question 10 DELTA is Phase 5 (Jira `description` only — no `.ai/` edits).

**Verification:** `npm run sync:adapters:check`

#### Task 4.1 - [REUSE] Code review by Code Reviewer

**Description**: Run **Code Reviewer** via `eversis-review.md` to review the complete Phase 1-3 implementation as a genuinely separate context from whichever context implemented it (self-review does not satisfy this gate). Confirm every Definition of Done checkbox above is actually verified, not just present, before declaring PASS.

**Files:** `.ai/rules/orchestration/agent-core.md` (reuse), `.ai/skills/eversis-import-confluence-knowledge/SKILL.md` (reuse), `.ai/skills/eversis-audit-domain-knowledge/SKILL.md` (reuse), `docs/context/README.md` (reuse), `website/docs/reference/domain-context.md` (reuse), `.ai/rules/orchestration/engineering-manager.md` (reuse), `.ai/rules/orchestration/spec-driven-development.md` (reuse), `.ai/rules/orchestration/README.md` (reuse), `.ai/prompts/public/eversis-implement.md` (reuse), `.ai/skills/eversis-orchestrating-implementation/SKILL.md` (reuse)

**Definition of Done**:

- [x] Run `npm run sync:adapters:check` — zero drift across all changed `.ai/` files
- [x] Code review of Task 3.2 passes with no open BLOCKER findings (the earlier PASS covered Tasks 1.1–3.1 only; it does not cover removal of the ~50% trigger)
- [x] Review outcome documented in this plan's Changelog

**Stop Rule:** If the same BLOCKER survives 3 full review passes, stop and escalate to the human instead of cycling further (mirrors the plan-review iteration cap already used elsewhere in this framework).

**Clues**: Check specifically for (a) accidental scope creep into Phases 4-7 (typ `decisions`, status lifecycle, retrieval levels 2-4, As-Is Pack sync) — none of the files above should reference building any of those, only referencing them as deferred/future; (b) on rejection of any phase, revert the `.ai/` source for that phase and re-run `npm run sync:adapters` — never hand-edit or selectively revert generated adapter output (Plan Review W5).

### Phase 5: Align Jira AC-2 Description with shipped implementation

**Goal**: The live Jira AC-2 `description` field states what Phases 1–3 actually shipped, not the pre-plan-review / pre-~50%-DELTA wording.

**Description**: Research Question 10 (accepted `"Accept DELTA"`) showed the ticket Description still claims an audit-counter readiness line, a new bootstrap skill, three zero-compaction triggers including window ~50%, exact-four-line readiness, and a Technical Notes touch list that includes `eversis-fine-handoff` / `AGENTS.md`. None of that is the shipped `.ai/` state. This phase replaces **only** field `description` on issue `AC-2` (cloud `24d9ed05-5d0a-4228-ae1a-8e5f10122f36`). No `.ai/` files, no status transition, no QA comment, no other Jira fields. Copy the appendix text below; do not invent a second draft.

**Verification:** After an explicit human `"publish to Jira"`, `getJiraIssue` on `AC-2` (`responseContentFormat: markdown`) shows the Phase 2/3 wording from the appendix and does not present `turns-since-audit`, `window ~50%`, or “new skill” as live requirements of this ticket.

#### Task 5.1 - [MODIFY] Replace Jira AC-2 Description with the appendix draft

**Description**: Call `editJiraIssue` with `cloudId` `24d9ed05-5d0a-4228-ae1a-8e5f10122f36`, `issueIdOrKey` `AC-2`, and `fields.description` set to the **Appendix — Jira AC-2 Description (shipped)** block at the end of this plan. Do this only after (1) this Phase 5 plan is approved and (2) the reporter says **publish to Jira** in a later turn. If either signal is missing, stop.

**Files:** Jira issue `AC-2` field `description` (modify via Atlassian `editJiraIssue`) — not a repository file. `docs/specs/ac-2/ac-2.research.md` (reuse — Question 10 + Human gates already record the DELTA).

**Definition of Done**:

- [x] `editJiraIssue` was not called in the same turn that only wrote or approved this plan
- [x] After the explicit publish turn: `getJiraIssue` `fields.description` contains `Context: N components` and `two independent triggers` (or equivalent two-trigger wording)
- [x] After publish: the same description does **not** list window `~50%`, `turns since last audit`, or “new skill or new mode” as requirements of this ticket
- [x] `status`, `summary`, comments, and labels are unchanged by this task
- [x] No `.ai/`, adapter, website, or `eversis-promote-domain-knowledge` file is edited

**Stop Rule:** If the reporter approves the plan but does not say publish / post / `editJiraIssue`, leave the ticket untouched.

**Clues**: Keep Goal and the Phase 1–3 vs 4–7 split. Move promote-tightening and mandatory `changelog.md` rollover out of this ticket’s Requirements (they were never implemented; plan left promote untouched). Do not fold logical-review S1–S4 (Continuity vs 5–10, Resume scan, `docs-specs-cluster` Delete, website prompt page) into the Description as if they shipped.

#### Task 5.2 - [REUSE] Confirm Description vs Question 10 table

**Description**: Re-read Question 10’s alignment table in `ac-2.research.md` against the published Description. Every row marked **Stale** or **Not done** must no longer appear as a live requirement. Rows marked **Aligned** must remain.

**Files:** `docs/specs/ac-2/ac-2.research.md` (reuse), Jira `AC-2` `description` (reuse)

**Definition of Done**:

- [x] Each Question 10 “Stale / Not done / Stale mechanism name / Stale process line” cell is either rewritten to shipped wording or explicitly deferred (Phases 4–7 / Improvements)
- [x] Result recorded in this plan’s Changelog (one row: published / not published)

## Security Considerations

- The extended `eversis-import-confluence-knowledge` skill (Task 2.2) must remain manual/one-time and produce a report for human review — it must not gain any automatic-write or scheduled-run capability as part of this extension, matching its own existing `<one-time-not-live>` principle and `eversis-promote-domain-knowledge`'s human-gate pattern. This is a Definition of Done item, not an afterthought.
- The `Context` readiness signal (Task 2.1) is visibility-only (chat/session output) — it must not be phrased in a way that implies a CI/git block exists, since none is being added here (consistent with DHI-630's earlier, explicit rejection of a staleness CI gate).

## Quality Assurance

Acceptance criteria checklist to verify the implementation meets the defined requirements (mirrors the Phase 1-3 Acceptance Criteria published on the Jira ticket, updated per plan review):

- [x] `/eversis-implement` on a ticket with existing domain knowledge reads INDEX, then at most one component file, and never loads the full content of more than 1-2 `docs/specs/` matches (discovery/grep remains unrestricted)
- [x] A feature with many historical specs is navigated via `related_specs` (1-2 live paths) or `changelog.md`, never every `*.research.md` in the tree
- [x] Cursor and Claude Code host instructions name the same INDEX path and the same discovery/consumption budget after `npm run sync:adapters`
- [x] `eversis-import-confluence-knowledge` writes `docs/context/<project>/<component>/index.md`, matching `eversis_context_get`'s single resolvable path, with `code_paths`/`related_specs` present as explicit empty arrays
- [x] A `source: confluence` component with empty `code_paths` is classified `Update` by `eversis-audit-domain-knowledge`, never `Delete`
- [x] After Fine, INDEX/component promotion is still offered exactly as today (unchanged) — the router stays one-line-per-component
- [x] `docs/plan/INDEX.md` / `docs/plans/INDEX.md` are explicitly rejected as routers in `agent-core.md`
- [x] A project's `INDEX.md` component count is surfaced in the Implement readiness block when relevant, never silently (audit staleness explicitly deferred to Phase 5, not shipped inert here)
- [x] The Implement readiness block's independent `Resume` line and `Context` line appear identically across the two Layer-A files, and `Resume` is never a `Flow` enum value; the three Layer-B files describe the line count without duplicating the block definition
- [x] `eversis-import-confluence-knowledge`'s extended process specifies checking a Confluence As-Is Pack before raw `docs/specs/` clustering
- [x] A local `docs/context/agent-collections/INDEX.md` fixture confirms both branches (`0` and `N > 0`) of the `Context` signal — exercised via `readIndexComponents`'s exact regex/parse logic (`context.ts:109-121`), since the full MCP call chain additionally requires `.agent-collections/install-selection.json`, a pre-existing environmental gap in this repo unrelated to any task in this plan and correctly left untouched
- [x] An active Implement session ending on either remaining agent trigger (exchange count, or completed+tested while further tasks remain — with rule 13 taking precedence over that second trigger for a plan's last task) writes a `CHECKPOINT:` entry to the plan `Changelog` and ends the session, and a session with a `Resume:` line reads it back. The rule does not end the session on context-window percent for Cursor or Claude Code.
- [x] Jira AC-2 `description` matches the shipped Phase 1–3 contract in the Phase 5 appendix (no audit-counter AC, no ~50% trigger, no new bootstrap skill) — unchecked until Task 5.1 publishes

## Improvements (Out of Scope)

- Phase 4 — a `docs/decisions/` (or `docs/context/<project>/decisions/`) ADR home, seeded from EOG's As-Is Pack Decision log. Separate, future Jira ticket.
- Phase 5 — full `draft/proposed/approved/deprecated/superseded` status lifecycle on `docs/context/` entries, **now also including the `Audit` (tasks-since-last-audit) readiness-signal persistence deferred from this plan's Phase 2** (Open Question 4). Separate, future Jira ticket (may combine with Phase 4).
- Phase 6 — full-text/semantic/graph retrieval (levels 2-4). Dormant follow-up, not a ticket, until one of the three explicit trigger conditions in the research (Question 4) is met.
- Phase 7 — a third Fine draft suggesting As-Is Pack Confluence updates. Separate, future Jira ticket, opened after Phases 2 and 4 both land.
- Broader public-website documentation of the full Phase 1-7 architecture (Context Pack concept mapping, decisions/ADR type, As-Is Pack sync) beyond the one small wording fix in Task 1.4 — recommended as its own future ticket; left open for the reporter to confirm (see Open Questions #1).
- Executing the extended `eversis-import-confluence-knowledge` process (Task 2.2) against any specific consumer repo's actual `docs/specs/` history or Confluence page — each consumer repo's own adoption task, not this plan's.
- A separate, standalone bootstrap skill — deliberately not created; the plan extends the existing `eversis-import-confluence-knowledge` instead (Open Question 3, corrected).
- **PI Agent context-window trigger** — when a PI Agent install exists, restore a ~50% session budget there, because that host exposes usage to the agent (`context_info`) and already ships a 50% extension (`pi-rolling-compaction`). Not part of AC-2. Do not add it to rule 14 for Cursor or Claude Code in the meantime. Source: `docs/specs/ac-2/Porównanie zarządzania oknem kontekstu  Cursor   Cursor CLI   Claude Code.md`, section 7, and research DELTA Question 5 (approved 2026-09-21).
- Tighten Fine promotion so agents “actually run it,” and make `changelog.md` rollover mandatory at threshold — left in `eversis-promote-domain-knowledge` as today’s optional ~15–20 behaviour. Not reopened by Phase 5.
- Logical-review leftovers S1–S4 (5–10 vs Continuity, Resume scan-not-last-row, `source: docs-specs-cluster` + empty `code_paths`, generated website “exact four-line”) — not part of the Description rewrite.

## Human gates

**Required flow: Full Flow.** This plan spans 4 phases, 10 files across `.ai/rules/`, `.ai/skills/`, `docs/context/`, and `website/`, and creates one new companion file — well past the 3-file Quick Flow ceiling and involving cross-cutting orchestration-contract changes. Do not enter via Quick Flow (Plan Review S1).

1. ~~Approve research~~ — done (`"Research jest ok"`, including the 2026-09-21 DELTA that drops the ~50% agent trigger for Cursor and Claude Code). ~~Question 10 (Jira vs shipped)~~ — done (`"Accept DELTA"`).
2. ~~Approve the original plan~~ — done (`"approve plan"`, post plan-review iteration 2). ~~Approve the Task 3.2 refresh~~ — done (`"Ok, implement"`).
3. ~~Implement Task 3.2 → Review → Fine~~ — done for the window-trigger removal. Session-budget leftovers later settled by AC-26: one completed-and-tested trigger while further tasks remain; same turn writes `RESUMED:`; the session continues (including Review and Fine); rule 13 governs the last task. No exchange-count trigger; do not tell the person to open a new chat.
4. ~~Approve Phase 5~~ — done (`"Plan is ok"`). ~~publish to Jira~~ — done (`"Publish to Jira"`, 2026-09-21). Description field only; status still **In Progress**.

## Changelog

| Date       | Change Description   |
| ---------- | --------------------- |
| 2026-09-18 | Initial plan created, scoped to Phases 1-3 per approved research |
| 2026-09-21 | Revised per plan review iteration 1 (`Plan Review  ac-2.plan.md`, verdict REVISIONS NEEDED, 5 blockers + 5 warnings, all independently re-verified against the live repo). Task 2.2 rewritten from [CREATE] new skill to [MODIFY] `eversis-import-confluence-knowledge` (B1, reporter-confirmed); readiness-contract tasks extended from 2 files to 5 (B2); `INDEX.md` two-column invariant recorded in Technical Context (B3); `Audit` readiness line dropped from Phase 2, deferred to future Phase 5 ticket (B4, reporter-confirmed); new Task 1.2 added to fix `eversis-import-confluence-knowledge`'s component-file granularity (B5); `Resume` value on `Flow` + `Changelog` checkpoint sub-format added to define the session-resume path (W1); new Task 1.3 added for `docs/context/README.md` (W2); local `INDEX.md` fixture added to Phase 2 Verification (W3); Technical Context path typo fixed (W4); rollback guidance added to Phase 4 (W5); Full Flow requirement stated explicitly in Human gates (S1); Step 6 pessimism correction folded into Task 2.2 (S3). |
| 2026-09-21 | Revised per plan review iteration 2 (`Plan Review (iteracja 2)  ac-2.plan.md`, verdict REVISIONS NEEDED, 1 blocker + 3 warnings, all independently re-verified against the live repo; 13/13 iteration-1 findings confirmed closed). Task 1.2 extended to also fix `eversis-import-confluence-knowledge`'s missing `code_paths`/`related_specs` and add one narrow sentence to `eversis-audit-domain-knowledge` preventing freshly-imported knowledge from misreading as `Delete` (B6, reporter-confirmed full fix over accept-the-risk option). Task 2.1 DoD split into Layer A (2 files defining the literal block: gain `Context` + `Resume`, reworded `Reason`-line ordinal language) and Layer B (3 files that only delegate: reworded line-count phrasing only, no duplicated block definition) — the previous "identical across all five" requirement was itself unworkable and a regression risk (W6, W7); three stale "Task 1.3" references corrected to "Task 1.2" (W8); write-path registry and diagram ordering fixed (S5, S6). |
| 2026-09-21 | **Code review performed (Phase 4, Task 4.1)**, run as a genuinely separate context from implementation, per `eversis-review.md`. Verdict: **PASS, 0 BLOCKER findings, 5 SUGGESTION findings.** All Task 1.1-3.1 Definition of Done checkboxes and all Quality Assurance Acceptance Criteria checkboxes independently re-verified against live file contents (not trusted as pre-checked) and confirmed genuinely true; none required unchecking. `npm run sync:adapters` + `npm run sync:adapters:check` re-run live: zero drift. `eversis_skills_validate` re-run live: `ok: true`, 0 errors (2 pre-existing warnings on unrelated skills). Scope discipline confirmed: `eversis-promote-domain-knowledge` untouched, no `docs/decisions/`, no `context-pack.yaml`, no status-lifecycle frontmatter fields added. `docs/context/agent-collections/INDEX.md` fixture confirmed gitignored and untracked. See "Code Review Findings" section at the end of this file for full detail, including a previously unflagged `docs/specs/ac-2/Analiza logiczna  ac-2.plan.md` (a third, uncommitted plan-consistency pass, dated the same day as plan-review iteration 2 but never folded into this plan's own Changelog) whose two substantive findings (the `Resume`-as-`Flow`-value category error, and the rule 14 / rule 13 precedence gap for a plan's final task) are carried into this review as SUGGESTIONS 1 and 2. |
| 2026-09-21 | **Fast-follow fix, reporter-directed** ("Napraw teraz, potem pełny re-review"): both SUGGESTION-1 and SUGGESTION-2 from the code review above, and all 6 findings from `Analiza logiczna  ac-2.plan.md` (now fully reconciled — read for the first time this round, after an earlier misread of the reporter's request to analyze it), fixed. **Code fix 1** (`.ai/rules/orchestration/engineering-manager.md`, `.ai/skills/eversis-orchestrating-implementation/SKILL.md`): `Resume` changed from a `Flow` enum value to an independent optional `- **Resume:** CHECKPOINT <date>` line — `Flow`'s enum reverts to `Quick \| Full \| QA follow-up`; a resumed session now keeps its governing `Flow` declaration. **Code fix 2** (`eversis-orchestrating-implementation/SKILL.md`, rule 14): added explicit precedence — rule 13 ("Proceed to Fine on PASS") governs when the completed-and-tested task is the plan's last task; the third trigger now reads "while further tasks remain in the plan." Both re-validated: `eversis_skills_validate` → 0 errors; `npm run sync:adapters` + `:check` → zero drift; `grep` confirms zero remaining `Flow: Resume` references in `.ai/`. **Documentation fix** (this plan file only, no further `.ai/` changes): resolved the 6:2 stale-narrative inconsistency around the Layer A/B model across all 6 flagged locations (Success Measure, Proposed Solution diagram + Phase 2/3 prose, Already Implemented, Open Question 5, Technical Context invariant — the last also collapsing the two contradictory `grep` invariant definitions into one verified check); noted the Task 2.1 ↔ Task 3.1 circular-reference-until-both-land structure explicitly in Phase 3's Proposed Solution prose; corrected the Phase 2 Verification fixture note to state the required sequential order (`0` branch first, against current repo state; `N > 0` second, against the added fixture); extended Success Measure to cover Task 1.2's B6 fix and Task 1.3. Relevant plan Definition of Done / Acceptance Criteria checkboxes updated to match. A fresh, full (not spot-check) code review follows this entry, per Execution rule 10. |
| 2026-09-21 | **Full re-review performed (second pass, genuinely separate session from the fast-follow fix)**, per Execution rule 10 ("re-run the complete review... a partial or spot-check re-review does not count"). Verdict: **PASS — 0 BLOCKER, 3 SUGGESTION** (2 carried/refined, 1 new). Every Task 1.1-3.1 Definition of Done checkbox and every Quality Assurance Acceptance Criteria checkbox independently re-verified from scratch against live file contents (none trusted from prior checkmarks). One DoD checkbox unchecked as stale (Task 2.1, item 3 — "...and the new `Flow` value" no longer describes anything true post-fast-follow-fix, since `Flow`'s enum has no new value anymore). Eight previously-unchecked Quality Assurance items (lines then 324-331, 333) independently confirmed true via static rule-content verification — the only verification method available for a Markdown-rules framework with no app-level test suite (Testing Patterns already states this) — and checked; this resolves an inconsistency where the prior review's prose claimed "all confirmed genuinely true" while 8 of 11 AC boxes remained unchecked. Both fast-follow fixes (Resume as independent line, rule 13/14 precedence) re-confirmed correct and complete. `npm run sync:adapters` + `:check` re-run live: zero drift. `eversis_skills_validate` re-run live: `ok: true`, 0 errors (same 2 pre-existing unrelated warnings). `git check-ignore`/`git status` re-confirm the `docs/context/agent-collections/INDEX.md` fixture is gitignored and untracked (now present on disk with 2 rows, confirming the `N > 0` branch). Scope discipline re-confirmed: no `docs/decisions/`, no `context-pack.yaml`, no status-lifecycle frontmatter, `eversis-promote-domain-knowledge` untouched. One genuine, still-open design gap carried forward from the original SUGGESTION 1 (its detection-trigger half, not its category-error half, which the fast-follow fix did resolve) and one new plan-hygiene finding (the stale DoD text above) — see "Code Review Findings — Re-Review" section for full detail. |
| 2026-09-21 | **Final micro-fix, reporter-directed** ("Dodaj teraz, jedno zdanie"): closed both of the re-review's remaining SUGGESTIONs. **Code fix** (`eversis-orchestrating-implementation/SKILL.md`, "Implement readiness (mandatory first output)"): added the missing detection trigger — before outputting the readiness block, check the plan's `Changelog` for its most recent entry; if it is an unresumed `CHECKPOINT:` entry, emit `- **Resume:** CHECKPOINT <date>` rather than treating the thread as a fresh start. Closes the detection-trigger half of the original SUGGESTION 1 (the category-error half was already closed by the earlier fast-follow fix). **Documentation fix** (this plan file only): Task 2.1 DoD item 3's stale "...and the new `Flow` value" wording corrected to describe the actual, current design (`Resume`/`Context` as independent optional lines; `Flow`'s enum unchanged at three values) and re-checked, since the underlying implementation was already correct — only the criterion's wording had lagged behind it. Re-validated live: `eversis_skills_validate` → 0 errors; `npm run sync:adapters` + `:check` → zero drift. All Definition of Done and Quality Assurance checkboxes in this plan are now checked. Proceeding to Fine in this same session per Continuity (default) — zero open BLOCKER findings and every visible checkbox verified checked. |
| 2026-09-21 | **Plan refresh after approved research DELTA** ("Research is ok. Update plan"). Dropped the context-window ~50% trigger from the agent rule for Cursor IDE, Cursor CLI, and Claude Code (Open Question 6). Added Task 3.2 to delete that clause from the already-landed rule 14. Success Measure, Proposed Solution, Phase 3 description, and the session-budget acceptance check now describe two agent-observable triggers. PI Agent (`context_info` / `pi-rolling-compaction`) recorded under Improvements and under Do NOT add. Task 3.2 and the matching acceptance check are unchecked because the skill still contains the old clause. No `.ai/` edit in this refresh. |
| 2026-09-21 | **Task 3.2 implemented** ("Ok, implement"). Rule 14 in `eversis-orchestrating-implementation/SKILL.md` now has two triggers (5-10 exchanges; completed+tested while further tasks remain) and states that context-window fill is not a trigger. No PI Agent wording in the rule. `npm run sync:adapters` + `:check` → zero drift. Separate review of rule 14: PASS, 0 BLOCKER. |
| 2026-09-21 | **Logical-gap re-review** (`/eversis-review`, separate session from implementation). Verdict: **not PASS — 1 BLOCKER, 4 SUGGESTION.** Prior Resume-as-`Flow` and rule-13-precedence defects confirmed still closed. New BLOCKER: `eversis-import-confluence-knowledge` `<split-not-copy>` still orders one file per Confluence section, which contradicts Task 1.2 / Step 4 (`<component>/index.md`, consolidate). See "Code Review Findings — Logical-gap pass". |
| 2026-09-21 | **B1 fixed** (QA follow-up). Rewrote `<split-not-copy>` and the “per-topic” sentence in `<one-time-not-live>` so both match Step 4: one `docs/context/<project>/<component>/index.md` per component, consolidate sections, never one file per Confluence heading. `eversis_skills_validate` → 0 errors. |
| 2026-09-21 | **Plan refresh after Question 10** (`"Accept DELTA"`). Added Phase 5 + appendix: Jira `description` rewrite to match shipped Phases 1–3. No `editJiraIssue` in this turn. |
| 2026-09-21 | **Phase 5 published** (`"Plan is ok. Publish to Jira"`). `editJiraIssue` on AC-2 `description` only (updated 2026-09-21T21:34:56+0200). Status remains In Progress. Summary, labels, comments unchanged. Task 5.2: Question 10 stale rows rewritten to shipped wording or deferred. |
| 2026-09-23 | **Appendix labeled as the 2026-09-21 publish snapshot.** The heading no longer says shipped. The sentence above the fence states that session behavior in that snapshot was replaced by AC-26, and that this appendix must not be published again. The fenced description was not edited. Jira was not written. |

## Code Review Findings

**Reviewer context:** Genuinely separate session from whichever context implemented Phases 1-3 — no self-review. Every Definition of Done checkbox (Tasks 1.1-3.1) and every Quality Assurance Acceptance Criteria checkbox was independently re-verified against the live file contents of this repo (not trusted because it was already checked); the pre-existing checkmarks were treated as unverified claims throughout. All were confirmed genuinely true — **no checkbox required unchecking**. Task 4.1's own three Definition of Done items are checked above as part of performing this review.

**Verdict: PASS — 0 BLOCKER, 5 SUGGESTION.**

### Verification performed (commands actually re-run, not assumed from the plan's checkmarks)

- `npm run sync:adapters` then `npm run sync:adapters:check` — **zero drift**, confirmed live (`adapter sync check: OK (no drift; id/source parity OK)`).
- `mcp__eversis-collections__eversis_skills_validate` — **`ok: true`, 0 errors**, 48 skills scanned. 2 pre-existing warnings (`eversis-implementing-backend`, `eversis-sql-and-database-understanding` — body line-count recommendations), both unrelated to any file this plan touches.
- `grep -rniE 'exact four-line|exactly four bullet|exactly four' .ai/` — **zero matches** (Task 2.1 DoD item).
- `grep -l 'four required lines' <all five contract files>` — **lists all five** (Task 2.1 DoD item).
- `grep -rniE 'four[- ]line|exactly four' .ai/` — also **zero matches** (the Technical Context section's own, differently-worded invariant check) — both of the plan's two textually-different grep definitions for "the closed-at-four phrasing is retired" agree on the live result.
- `git check-ignore -v docs/context/agent-collections/INDEX.md` → matched by `docs/context/*/` — **confirmed gitignored**; `git status --short docs/context/agent-collections/` → empty — **confirmed untracked**.
- `git diff HEAD --stat -- .ai/skills/eversis-promote-domain-knowledge/` → empty — **confirmed untouched**, per the plan's explicit "Do NOT touch" list.
- Searched the full diff for `docs/decisions/`, `context-pack.yaml`, and status-lifecycle vocabulary (`draft/proposed/approved/deprecated/superseded` used as an enum) — **none found**; the only hits are unrelated, ordinary English uses of "draft" and "approved" already present in the framework's existing human-gate language.
- Read `eversis-import-confluence-knowledge/SKILL.md` in full (post-change) and `bootstrap-report.example.md` in full — both match Task 1.2/2.2's Definition of Done line for line (component-path granularity, explicit empty `code_paths`/`related_specs`, the `docs/specs/` clustering fallback and "No As-Is Pack at all" as a distinct labeled section, the corrected Step 7 pessimism paragraph citing the real EOG As-Is Pack counter-example, and 3 candidate `INDEX.md` rows in the example file — 2 Confluence-sourced, 1 `docs/specs/`-cluster-sourced, all two-column).
- Read `eversis-audit-domain-knowledge/SKILL.md`'s change in full context: the new sentence is narrowly scoped to `source: confluence` with empty/absent `code_paths` only — a `source: agent-discovered` component with genuinely-gone `code_paths` still falls through to the unmodified general rule (`Delete` when all paths are gone). Confirmed this does not weaken the Delete signal for the case it was never meant to touch.
- Read the full numbered "Execution rules and gates" list (1-14) in `eversis-orchestrating-implementation/SKILL.md` — rule 14 is additive at the correct next ordinal, explicitly distinguishes its `CHECKPOINT:` entries from rule 12's ordinary Changelog entries, and states its three triggers as "first one wins" (OR, not AND) — see SUGGESTION 2 below for a precedence gap this rule has with rule 13, not a numbering or OR/AND defect.

### SUGGESTION 1 — `Resume` as a value of the `Flow` enum is a type/category error, not a separate concern from `Flow`

`Flow` answers "which workflow" (`Quick | Full | QA follow-up`); `Resume` answers "is this a continuation" — an independent, orthogonal question, now folded into the same enum as a fourth, mutually-exclusive value. Two concrete consequences, both real, neither hypothetical:

1. This plan's own **Human gates** section states "**Required flow: Full Flow**" for AC-2 itself. A session resuming an AC-2 checkpoint would have to emit `Flow: Resume`, which has no way to *also* carry "and it's Full" — the Full-Flow behavior (3-file ceiling awareness, plan-validation requirement, no Quick-Flow entry) has nothing to attach to once the enum value is spent on `Resume`.
2. `eversis-implement.md`'s "Entry signals" table (Layer B, wording-only per Task 2.1's own scope restriction) is keyed by scenario, and nothing in Step 1 of `eversis-orchestrating-implementation` (Layer A, the file that actually owns flow selection) tells an agent *how* to detect a `CHECKPOINT:` Changelog entry and choose `Flow: Resume` over `Full`/`Quick` at readiness time — rule 14's own text ("A fresh session recognizes this via `Flow: Resume`") is the only place this is asserted, and it is circular: it describes what the value means once chosen, not the trigger condition for choosing it. Confirmed via `grep -n "Resume" .ai/skills/eversis-orchestrating-implementation/SKILL.md .ai/rules/orchestration/engineering-manager.md .ai/prompts/public/eversis-implement.md` — every hit is a definition, none is a detection rule.

Not a BLOCKER under this review's definition: it does not fail any AC item as literally worded (AC item 9 asks only that `Context`/`Resume` "appear identically across the two Layer-A files," which they do, word for word), and it does not reintroduce a bug this plan was written to fix — it is new content, faithfully implementing what Task 2.1 specifies. But it is a genuine design defect that will resurface the first time a session actually tries to resume a checkpoint. **A prior, uncommitted plan-consistency pass already caught this independently** (`docs/specs/ac-2/Analiza logiczna  ac-2.plan.md`, finding 2, same date as plan-review iteration 2) and proposed the cheaper fix: a separate optional line — `- **Resume:** CHECKPOINT <date> | none` — alongside `Context`/`Reason`, leaving `Flow` untouched and its declared value (e.g. `Full`) intact across a resume. That finding was never folded into this plan's Changelog or DoD and does not appear to have been acted on. Recommend a fast-follow fix before this mechanism is ever exercised for real, rather than waiting for a live resume to surface it.

### SUGGESTION 2 — New rule 14 (zero-compaction) has no stated precedence against existing rule 13 (Proceed to Fine on PASS) when a task is both the plan's last task and completed-and-tested

Rule 14's third trigger is "the current task reaching a completed-and-tested state." Rule 13 already governs exactly that state for the case where the *whole plan* just passed review ("Proceed to Fine on PASS"). For a plan's final task, both conditions can be true simultaneously, and the two rules prescribe opposite actions — end the session (14) vs. continue into Fine in the same turn (13, and the framework's own Continuity default). The implemented wording ("When any fires **while the task is not yet complete**...") gestures at a distinction between a sub-task and the overall ticket, but does not spell out which "task" is meant or state that rule 13 takes precedence at the final task — an implementer reading rule 14 immediately after rule 13 (as written, back to back) has no explicit tiebreak. Also flagged independently by the same uncommitted "Analiza logiczna" pass (finding 5), which proposed either narrowing trigger 3 to "and further tasks remain in the plan" or adding an explicit precedence sentence. Neither made it into the implemented rule 14 or Task 3.1's Definition of Done. Not a BLOCKER (no AC item asserts this precedence; nothing here reintroduces a previously-fixed bug), but worth a fast-follow clarification for the same reason as SUGGESTION 1 — better to fix in text now than to have two rules actually contradict each other mid-session later.

### SUGGESTION 3 — The plan's own narrative sections still assert the pre-plan-review "all five files, identically" model that Task 2.1 correctly replaced with the two-layer (Layer A / Layer B) model

Six places in this plan document (Success Measure, l.18; Proposed Solution Phase 2, l.38; Proposed Solution Phase 3, l.40; Already Implemented, l.74; Open Question 5, l.100; Technical Context invariant, l.114) still read "identically across all five files" / "all five to be extended identically," contradicting Task 2.1's own (correct, and correctly implemented) Layer A/Layer B split, and contradicting the Quality Assurance Acceptance Criteria checklist (which already states the two-layer model correctly). This is a plan-hygiene defect, not an implementation defect — the actual `.ai/` files match the two-layer model, not the stale narrative — so it does not affect this review's PASS verdict. Flagged because a future ticket reading this plan linearly hits the stale claim four times before reaching the correct one, exactly the failure mode plan-review iteration 1's own B2 finding was about. Also independently caught by the uncommitted "Analiza logiczna" pass (finding 1). Low-cost fix: a follow-up edit pass on this plan file's prose only — no code or `.ai/` content changes needed.

### SUGGESTION 4 — A third, uncommitted plan-review document exists and was never reconciled into this plan's Changelog

`docs/specs/ac-2/Analiza logiczna  ac-2.plan.md` (dated the same day as plan-review iteration 2) is a logical-consistency pass over the plan that produced 2 substantive findings (folded into SUGGESTIONS 1 and 2 above) plus 4 lower-severity/documentation findings (its own items 1, 3, 4, 6a, 6b) that this review did not separately re-litigate, since none affect the live `.ai/` file contents this review is scoped to. Worth surfacing because the plan's Changelog names and reconciles plan-review iterations 1 and 2 explicitly but is silent on this third pass — a reader trusting the Changelog as the complete revision history would not know this document exists. Recommend either folding its remaining open items into a future plan revision's Changelog, or explicitly marking it superseded/no-action if the reporter judges it out of scope for AC-2.

### SUGGESTION 5 — Minor: two textually different grep definitions for the same "closed-at-four phrasing is retired" invariant

Technical Context (l.114) specifies `grep -rniE 'four[- ]line|exactly four' .ai/` → zero; Task 2.1's Definition of Done (l.237, now shifted by this review's edits) specifies `grep -rniE 'exact four-line|exactly four bullet|exactly four' .ai/` → zero. Both patterns return zero against the live repo (verified above), so there is no practical defect today — but the two different operational definitions of the same named invariant, in the same document, is worth collapsing into one the next time this plan file is touched, so a future partial fix doesn't pass one check while silently failing the other.

---

*Prior to this review, `docs/specs/ac-2/Analiza logiczna  ac-2.plan.md` also flagged that Task 2.2's Definition of Done (5. clustering fallback, no-As-Is-Pack branch) looked incomplete on a first pass — its own "Czego nie potwierdziłem" section retracted that suspicion after a full re-read, confirming both items present. This review's own independent read of the live `SKILL.md` (see Verification performed, above) reaches the same conclusion: both are present, confirmed.*

## Code Review Findings — Re-Review (2026-09-21, second pass)

**Reviewer context:** A genuinely separate session from the fast-follow fix above, per Execution rule 10's explicit requirement — "re-run the complete review... a partial or spot-check re-review does not count." Every Task 1.1-3.1 Definition of Done checkbox and every Quality Assurance Acceptance Criteria checkbox was independently re-verified against the current, live file contents of this repo, from scratch — none trusted because a prior pass had already checked it, including items the first code review pass above had explicitly confirmed. This is scoped as the mandatory full re-review requested after the two headline fast-follow fixes (the `Resume`/`Flow` category error and the rule 13/14 precedence gap), not a spot-check of just those two fixes.

**Verdict: PASS — 0 BLOCKER, 3 SUGGESTION (1 carried forward and narrowed, 1 explicitly superseded, 1 new).**

### Verification performed (commands actually re-run this pass, not assumed from any prior review's narrative)

- `npm run sync:adapters` then `npm run sync:adapters:check` — **zero drift**, confirmed live (`adapter sync check: OK (no drift; id/source parity OK)`).
- `mcp__eversis-collections__eversis_skills_validate` — **`ok: true`, 0 errors**, 48 skills scanned; same 2 pre-existing warnings as before (`eversis-implementing-backend`, `eversis-sql-and-database-understanding`), both unrelated to this plan.
- `grep -rniE 'exact four-line|exactly four bullet|exactly four' .ai/` — **zero matches**, re-confirmed live.
- `grep -l 'four required lines' <all five contract files>` — **lists all five**, re-confirmed live.
- `grep -rniE 'four[- ]line|exactly four' .ai/` (the Technical Context section's textually-different invariant check) — **also zero**, both definitions still agree (see SUGGESTION 3 below on why one of the two should still be retired).
- `grep -n "Flow: Resume\|Flow.*Resume value\|QA follow-up | Resume" .ai/` and a broader sweep for `Resume` beside the `Flow:` enum line — **zero real hits**; both Layer A files' `Flow:` line reads exactly `Quick | Full | QA follow-up`, unchanged from before this plan, confirmed by direct read of both files.
- `git check-ignore -v docs/context/agent-collections/INDEX.md` → matched by `docs/context/*/` — **confirmed gitignored**. The fixture now exists on disk (2 rows: `example-a`, `example-b`) — `git status --short docs/context/agent-collections/` → empty — **confirmed untracked**. Read the fixture directly and traced it against `readIndexComponents()` (`mcp/eversis-collections-mcp/src/context.ts:109-121`): its header/separator-skipping regex correctly yields exactly 2 components from this fixture, independently confirming the `N > 0` branch mechanics. The `0` branch (repo's prior state, before this fixture was added) is not independently re-testable now without deleting a plan artifact — out of this review's scope — so that half of AC item "both branches" rests on the documented sequential-order claim from the prior pass, not on a fresh run by this review.
- `git diff HEAD --stat -- .ai/skills/eversis-promote-domain-knowledge/` → empty — **confirmed untouched**.
- Searched the full diff for `docs/decisions/`, `context-pack.yaml`, and status-lifecycle vocabulary as an enum — **none found**; `ls docs/` confirms no `decisions/` directory exists in this repo at all.
- Read `agent-core.md`, `engineering-manager.md`, `eversis-orchestrating-implementation/SKILL.md`, `eversis-import-confluence-knowledge/SKILL.md`, `eversis-audit-domain-knowledge/SKILL.md`, `docs/context/README.md`, `website/docs/reference/domain-context.md`, and `bootstrap-report.example.md` in full via `git diff HEAD` against each, not excerpts — every Task 1.1-3.1 Definition of Done line checked against the actual current wording, not the plan's own paraphrase of it.
- Read all six of this plan's narrative locations previously flagged as stale (Success Measure l.18, Proposed Solution Phase 2 l.38 / Phase 3 l.40, Already Implemented l.74, Open Question 5 l.100, Technical Context invariant l.114) plus the two Changelog entries describing the fast-follow fix — confirmed none still assert "identically across all five files" or describe `Resume` as a `Flow` value as a live claim (the only remaining occurrences of that phrase are inside quotes, correctly describing the superseded design, in Task 2.1's own Description, in SUGGESTION 3's finding text, and in the Changelog's fast-follow entry — all clearly historical, not current).

### SUGGESTION 1 (carried forward, narrowed) — The `Resume`-line detection trigger is still unstated; only the category-error half of the original finding was fixed

The prior full review's SUGGESTION 1 had two independent parts. **Part 1** (Resume folded into the `Flow` enum as a mutually-exclusive value, breaking `Full` on resume) **is fixed** — confirmed above: `Flow`'s enum is back to `Quick | Full | QA follow-up` in both Layer A files, and `Resume` is now a genuinely independent optional line. **Part 2 was not addressed by the fast-follow fix and remains exactly as originally described**: nothing in Step 1 of `eversis-orchestrating-implementation` (the "Implement readiness (mandatory first output)" section, which only says to "inspect `docs/specs/<issue>/` and any `@`-attached plan/research paths") tells an agent *when* to check the plan's `Changelog` for a `CHECKPOINT:` entry, or that finding one is the trigger for emitting a `- **Resume:** CHECKPOINT <date>` line. Rule 14's own text ("A fresh session recognizes an unresumed checkpoint via a `Resume: CHECKPOINT <date>` line in the Implement readiness block... and resumes from that entry") still only describes what the line *means* once present — it is still circular about the actual detection step, exactly as the original finding said. Confirmed via direct read of the "Implement readiness (mandatory first output)" section (`eversis-orchestrating-implementation/SKILL.md`) and both self-checks in `engineering-manager.md` — neither mentions checking the Changelog for a `CHECKPOINT:` entry as part of assembling the readiness block.

Not a BLOCKER, for the same reason as before: no DoD or AC item as literally worded requires the detection trigger to be spelled out — Task 3.1's DoD item 3 only requires the rule to *state* that the `Resume` line is how a fresh session recognizes the checkpoint, which it does. But this is the harder, more consequential half of the original finding (a session that never learns to look for the checkpoint will never emit `Resume` in the first place, regardless of how well-specified the line's meaning is once present) and it survived a full implementation cycle unaddressed while the easier, more visible half was fixed. Recommend closing this explicitly before the checkpoint mechanism is ever exercised for real — a one-sentence addition to Step 1 ("when inspecting the plan file, check its `Changelog` for an unresumed `CHECKPOINT:` entry; if found, include a `Resume:` line") would fully close it.

### SUGGESTION 2 (superseded — confirmed fixed, kept for changelog continuity)

The prior review's SUGGESTION 2 (rule 14 vs. rule 13 precedence for a plan's last task) is **fully resolved**. Rule 14 now reads: "**Precedence over rule 13:** when the completed-and-tested task is the plan's **last** task, rule 13 governs instead — proceed to Fine in the same turn; do not end the session on a checkpoint," and the third trigger itself is narrowed to "while further tasks remain in the plan" — closing the ambiguity at its source rather than only adding a tiebreak sentence. No further action needed; retained here only so a reader following the Changelog does not wonder whether this finding was silently dropped.

### SUGGESTION 3 (new) — Task 2.1's own Definition of Done, item 3, is now stale and was left unchecked by this review

Task 2.1's Definition of Done (the line "Layer A: `engineering-manager.md`'s self-check #2 and `eversis-orchestrating-implementation/SKILL.md`'s equivalent self-check are updated to list both optional additions and **the new `Flow` value**") describes the *pre-fast-follow-fix* design, where `Resume` was a fourth `Flow` value. Read against the current, corrected files: both self-checks correctly list the optional additions (`Resume`, `Context`, `Reason`) but — correctly — do **not** list any new `Flow` value, because none exists anymore; `Flow` is unchanged at three values. The DoD line's literal text can no longer be satisfied without reintroducing the bug the fast-follow fix just removed, so this review left it **unchecked** rather than either checking a claim that is no longer true or silently leaving stale prior-checked state uncorrected. Per this framework's own review-prompt contract, DoD/AC checkbox *text* cannot be edited during a review — only the checkbox state — so this is flagged here as the actionable item: a future light-touch edit to this one DoD line's wording (drop "and the new `Flow` value") would let it be checked truthfully. This is the same class of plan-hygiene gap as the prior review's SUGGESTION 3/5 (stale narrative surviving a design correction) — not a BLOCKER, since the actual `.ai/` implementation is correct; only this one plan-file sentence lags behind it.

### Other checkbox changes made by this re-review

Eight Quality Assurance Acceptance Criteria items (the `/eversis-implement` read-order behavior, the `related_specs`/`changelog.md` navigation behavior, the Cursor/Claude adapter parity item, the `eversis-import-confluence-knowledge` path/array item, the `source: confluence` + empty `code_paths` → `Update` item, the unchanged-promotion item, the `docs/plan(s)/INDEX.md` rejection item, and the `Context` line visibility item) were left **unchecked** by every prior pass despite the first full review's own prose claiming "all confirmed genuinely true — no checkbox required unchecking." This re-review independently confirmed each is true at the level of verification actually available for this plan's scope (static rule-content correctness — the plan's own Testing Patterns section already states no unit/e2e suite applies here, so a live end-to-end `/eversis-implement` behavioral run is not a verification method this or any prior review pass had access to either) and checked them, resolving that inconsistency rather than repeating it. This is a process-hygiene finding about the review trail, not a defect in the implementation itself.

## Code Review Findings — Task 3.2 (2026-09-21)

**Reviewer context:** Separate pass from the edit of rule 14, scoped only to Task 3.2. Verdict: **PASS — 0 BLOCKER.**

Rule 14 now names two triggers (5-10 exchanges; completed-and-tested while further tasks remain), states that context-window fill is not a trigger, keeps rule 13's precedence on the plan's last task, and does not name PI Agent. `npm run sync:adapters` and `sync:adapters:check` returned zero drift. Task 3.2's four Definition of Done boxes and the session-budget acceptance check are checked on that evidence.

## Code Review Findings — Logical-gap pass (2026-09-21)

**Reviewer context:** Standalone `/eversis-review` against `ac-2.plan.md`, asked to find logical gaps. Separate session from whoever implemented Phases 1–3 and Task 3.2. Every DoD/AC checkbox was re-read as an unverified claim. Literal Step/file wording still matches the checked boxes (this pass does not uncheck them). The shipped **rules contradict each other** in one place that previous passes did not open.

**Verdict: not PASS — 1 BLOCKER · 4 SUGGESTION.**

### Verification performed this pass

- Read live `.ai/rules/orchestration/agent-core.md`, `engineering-manager.md`, `spec-driven-development.md`, `orchestration/README.md`, `.ai/prompts/public/eversis-implement.md`, `.ai/skills/eversis-orchestrating-implementation/SKILL.md`, `eversis-import-confluence-knowledge/SKILL.md`, `eversis-audit-domain-knowledge/SKILL.md`, `bootstrap-report.example.md`, `docs/context/README.md`, `website/docs/reference/domain-context.md`.
- Compared generated Cursor packaging: `.cursor/rules/eversis-agent-core.mdc`, `eversis-engineering-manager.mdc`, `eversis-spec-driven-development.mdc`, `.cursor/commands/eversis-implement.md` — same INDEX path, discovery/consumption split, four-required-plus-optional wording, `Resume` as an optional line (not a `Flow` value). Live `npm run sync:adapters:check` could not be re-run in this session (generator writes a temp dir outside the workspace).
- `eversis_skills_validate` on `eversis-import-confluence-knowledge` and `eversis-audit-domain-knowledge`: `ok: true`, 0 errors (2 pre-existing line-count warnings on unrelated skills).
- `grep -rniE 'exact four-line|exactly four bullet|exactly four' .ai/` → zero. `grep -l 'four required lines'` on the five contract files → all five.
- `Flow:` enum in both Layer A files is `Quick | Full | QA follow-up`. Resume detection preamble exists in the skill Step 1 block.
- `docs/context/agent-collections/INDEX.md` exists, gitignored, one data row (`readiness-contract`). `readIndexComponents` two-column regex would yield `N = 1`. Not the two-row `example-a` / `example-b` fixture named in an earlier review note.
- `eversis-promote-domain-knowledge` not in the AC-2 commit surface. No `docs/decisions/`, no `context-pack.yaml`.

Closed from earlier reviews (re-confirmed, not re-opened): Resume is not a `Flow` value; rule 13 beats rule 14 on the plan’s last task; `~50%` window fill is not a trigger.

### BLOCKERS

#### B1: `<split-not-copy>` undoes Task 1.2 — the skill orders two incompatible file shapes

`.ai/skills/eversis-import-confluence-knowledge/SKILL.md` principles block (lines 15–17):

> Do not create a single file that copies the whole page. **Split it into one file per logical section** (e.g. "Cel biznesowy", "Mapa modułów", "Known Issues", "Decision log" …).

Process Step 4 (the Task 1.2 fix, lines 36–43):

> write **one file per component** at `docs/context/<project>/<component>/index.md` … **Consolidate every section belonging to the same component into that one file; do not create a separate file per Confluence section.**

Those two instructions cannot both be followed. An agent that obeys the principle (it is first, and tagged as a principle) recreates the pre-AC-2 shape: one file per Confluence heading. `eversis_context_get` still resolves only `<component>/index.md`. That is the exact router hole Task 1.2 and plan-review B5 existed to close.

`<one-time-not-live>` still talks about “per-topic file granularity,” which pulls the same old model.

Step 4’s DoD text is locally true, so the checkbox stays checked. The **skill as a whole** is not internally consistent. This is a correctness defect in the shipped write path, not plan wording.

**Action:** Rewrite `<split-not-copy>` (and the “per-topic” clause) to match Step 4: split the page by **component**, one `index.md` per component, never one file per Confluence section. Do not leave the old principle in place as a second SSOT.

### SUGGESTIONS

#### S1: Rule 14’s 5–10 exchange trigger still fights Continuity in the same skill

`eversis-orchestrating-implementation/SKILL.md` Continuity (default): after implementation, run Review then Fine **in the same session**. Rule 14: first of (5–10 exchanges, or done+tested with more tasks left) → `CHECKPOINT:` and **end the session**.

On a typical Cursor Full Flow (this ticket: research gate, plan gate, then 10 files), 5–10 exchanges fire **before** Continuity starts. The agent is told to stop; Continuity is told to stay. At the time of this review the Human gates still listed that gap; AC-26 later closed it (one completed-and-tested trigger, same-turn `RESUMED:`, session continues; no exchange-count trigger; no “open a new chat” instruction). Task 3.2 deliberately kept the 5–10 trigger, so this was not an implementation miss against the then-current DoD — it was a leftover contradiction in the shipped skill until AC-26.

**Action (historical; closed by AC-26):** Either exclude Review→Fine from the 5–10 trigger, or raise/drop the exchange cap. Do not leave two hard rules pointing opposite ways. Do not restore a new-chat operator sentence into the skill.

#### S2: Resume detection looks only at the *latest* Changelog row

Step 1: “check the plan’s `Changelog` for the **most recent** entry: if it starts with `CHECKPOINT:` and no later entry records that task’s completion.” Any later row that is not a completion — rule 12 solution-change, a plan-review note, “code review performed” — hides an unresumed checkpoint. This plan’s own Changelog is already a long table of such rows. A fresh `/eversis-implement` will emit no `Resume:` line and restart.

**Action:** Scan for the latest `CHECKPOINT:` that is not followed by an explicit completion/resume-consumed marker, not “is the last row a checkpoint?”

#### S3: `source: docs-specs-cluster` with empty `code_paths` still reads as `Delete`

Task 1.2 closed `source: confluence` + empty `code_paths` → `Update`. Step 6 writes `source: docs-specs-cluster` and only *optionally* fills `code_paths` (topic clustering may have none). `eversis-audit-domain-knowledge` Step 1’s exception is scoped to `source: confluence` only. Fresh cluster seeds with empty `code_paths` match “all paths are gone” → `Delete`.

**Action:** Extend the exception to `source: docs-specs-cluster` (or any bootstrap `source` that is allowed to ship `code_paths: []`).

#### S4: Generated website prompt page still asserts the retired four-line contract

`.ai/prompts/public/eversis-implement.md` (Layer B) says “four required lines plus optional signals.” The generated copy `website/docs/reference/prompts/public/eversis-implement.md` still says “**exact four-line**.” Hand-authored `website/docs/main-flow/workflow/standard-flow.md` and `website/docs/reference/agents/engineering-manager.md` say the same. Task 2.1 Verification only runs `sync:adapters:check`, not `sync:website-docs:check`. Cursor users who read the docs site, not the slash file, keep the old contract.

**Action:** Run `npm run sync:website-docs` for the generated prompt page. Broader hand-authored site copy can stay under Open Question 1.

### Checkbox state

No DoD/AC boxes were unchecked. Literal file wording still satisfies each checked line. B1 is a contradiction **between** two true statements in the same skill, which no single checkbox covers. S1’s exchange-count gap and the new-chat sentence were later closed by AC-26 (Human gates). That later contract is not used to uncheck the boxes from this review.

## Appendix — Jira AC-2 Description (2026-09-21 publish snapshot)

This fenced block is the AC-2 description published on 2026-09-21. It is a historical snapshot. Session behavior inside it — two triggers (5–10 exchanges, or the task completed and tested while further tasks remain) and ending the session — was replaced by AC-26. The live contract is rule 14 in `.ai/skills/eversis-orchestrating-implementation/SKILL.md`: one completed-and-tested trigger while further tasks remain, the same turn writes `RESUMED:`, and the session continues through Review and Fine. Do not publish this appendix again.

```markdown
## Context

Agent Collections already splits **durable domain knowledge** (`docs/context/<project>/`) from **per-task SDD** (`docs/specs/<issue-kebab>/`). Orchestration already says: read `INDEX.md` first, then **one** component file, then at most 1–2 `related_specs` — never the whole `docs/specs/` tree.

In practice agents still glob/grep historical `*.research.md` / `*.plan.md`. Those files are long. Loading many of them fills the window and triggers compaction, which then drops the _current_ task.

**Scope of this ticket was broadened during research (2026-09-18).** What started as a narrow router fix turned out to be one piece of a larger, unresolved question: does `agent-collections` have a coherent architecture for context and knowledge across the whole development lifecycle, or a set of mechanisms built at different times (DHI-630, AC-1, this ticket) that were never mapped together? Research (`docs/specs/ac-2/ac-2.research.md`) answers this by mapping MEGA.dev and Przeprogramowani against the existing router, promote skill, audit skill, and plan/review/Fine artifacts, and against the EOG cold-start (`INDEX.md` empty after 28 closed specs). Question 10 (2026-09-21, accepted) then aligned this Description with what Phases 1–3 actually shipped.

**Implement in the agent-collections framework.** Consumers pick it up via submodule / vendor bump.

## Goal

Define and adopt a coherent context-and-knowledge-management architecture for the `agent-collections` development lifecycle. The bounded INDEX router (the original scope of this ticket) is **Phase 1** of that architecture, not the whole of it. This ticket's implementation covers Phases 1–3 below; Phases 4–7 are recorded here as backlog for future tickets, not built now.

## Phased scope

| Phase | Scope | In this ticket's Plan? |
| --- | --- | --- |
| **1. Router + read budget** | Agents locate feature knowledge through a small, always-cheap `INDEX.md`, then one component file, then at most 1–2 current specs. **Discovery** (grep/glob for filenames/matches in `docs/specs/**`) stays always allowed — cheap, no content loaded. **Consumption** (loading full file content) is capped at 1–2 files, the same budget as `related_specs`, regardless of whether the match came from INDEX or from discovery. Never a loop that loads every matched file's content. Write paths into `docs/context/` emit `<component>/index.md` so `eversis_context_get` can resolve them (`eversis-import-confluence-knowledge` was corrected to this shape; `eversis-promote-domain-knowledge` already used it). | **Yes — shipped** |
| **2. Visible INDEX signal + bootstrap mechanism** | Surface a non-blocking `Context: N components indexed` line on the Implement readiness block (Layer A). **Do not** ship a “tasks since last audit” counter — no persistence exists; that signal is deferred to the future Phase 5 ticket. **Extend** the existing `eversis-import-confluence-knowledge` skill (not a new skill): Confluence As-Is Pack first, `docs/specs/` clustering fallback, no-As-Is-Pack branch. Running the bootstrap against a consumer repo (e.g. EOG) is that repo's adoption task, not this ticket's DoD. | **Yes (mechanism), No (execution against any consumer repo) — shipped** |
| **3. Session budget / zero-compaction discipline** | Two independent, OR-combined agent-observable triggers: 5–10 prompt/response exchanges, or the current task completed+tested **while further tasks remain**. On trigger, write a `CHECKPOINT:` row to the plan Changelog and end the session; a fresh session may emit optional `- **Resume:** CHECKPOINT <date>` (never a `Flow` value). Rule 13 (Fine on PASS) wins when the completed task is the plan's last task. Context-window ~50% is **not** a trigger for Cursor or Claude Code (agent cannot observe window fill). PI Agent is a follow-up. Document that Agent-tool role delegation already satisfies ephemeral stateless subagents — no multi-process rebuild. | **Yes — shipped** |
| **4.** `decisions` / ADR type | Durable home for architectural decisions. Seed: EOG As-Is Pack Decision log. | **No — separate Jira ticket after this one closes** |
| **5. Knowledge status lifecycle** | `draft → proposed → approved → deprecated → superseded`, **including** the deferred “tasks since last audit” persistence. | **No — separate Jira ticket (may combine with Phase 4)** |
| **6. Retrieval levels 2–4** | Full-text / semantic / graph. Revisit when INDEX volume or a second consumer makes one-line selection stop scaling. | **No — dormant follow-up until a trigger condition is met** |
| **7. Sync** `docs/context/` → As-Is Pack (Confluence) | Optional Fine draft as a Confluence comment, never a page edit. Depends on Phases 2 and 4. | **No — separate Jira ticket after Phases 2 and 4 land** |

## AS-IS: odkrywanie wiedzy po `/eversis-implement <TASK-ID>` (Phase 1 detail)

Opis stanu obecnego (prescribed vs praktyka). Referencja dla research i planu tego taska.

### Przepływ ogólny

1. `/eversis-implement TASK-123` → Engineering Manager + skill `eversis-orchestrating-implementation`
2. Step 0: todos
3. Step 1: inspekcja `docs/specs/<task-kebab>/` + blok **Implement readiness** (cztery wymagane linie: Flow, Research, Plan, Next gate; opcjonalnie Resume / Context / Reason)
4. Full Flow (domyślnie) lub Quick Flow (wąski scope, ≤3 pliki, bez Figma/UI)
5. Research → Plan → Implement → Review → Fine

Agent **nie zaczyna od kodu** — najpierw ocenia istniejące artefakty SDD.

### Faza 1 — pierwsze sekundy (lokalna inspekcja)

```text
docs/specs/<task-kebab>/
├── <task>.research.md
├── <task>.plan.md
└── <task>.plan-review.md
```

Na tej podstawie: Research **SKIP | CREATE | DELTA**, Plan **SKIP | CREATE | REFRESH** (checklist adequacy). Źródło: folder **bieżącego** zadania + pliki `@`-dołączone.

### Faza 2 — Research (gdy brak adekwatnego `*.research.md`)

Procedura `eversis-research` / skill `eversis-task-analysing` — **zalecana kolejność**:

| Krok | Źródło | Co agent zbiera |
| --- | --- | --- |
| 0 | `docs/specs/<task>/` | Czy research/plan już istnieją |
| 1 | Jira MCP | Opis, AC, komentarze QA, epic, subtaski, linki |
| 2 | `docs/context/` | `INDEX.md` → **jeden** plik komponentu → discovery (tanie) → konsumpcja max 1–2 |
| 3 | Confluence / PDF / Figma | Z linków w Jirze; **As-Is Pack sprawdzany jako preferowane źródło bootstrapu, gdy INDEX cienki/pusty** |
| 4 | Kod | grep + `eversis-codebase-analysing` |
| 5 | Luki | Pytania do człowieka |
| 6 | Zapis | `docs/specs/<task>/<task>.research.md` → **bramka: approve research** |

MCP `eversis_context_list` → `eversis_context_get` = zamierzony tani path (lista → jeden plik). **Confirmed implemented** in `mcp/eversis-collections-mcp/src/{server.ts,context.ts}`; unchanged by this ticket.

Reguły hosta (Cursor: `.cursor/rules/`, generated commands; Claude Code: `CLAUDE.md`) wstrzykiwane z `.ai/` przez `npm run sync:adapters`.

### Faza 3 — Plan (Architect)

| Źródło | Rola |
| --- | --- |
| `*.research.md` | Scope, AC, otwarte pytania |
| `eversis-plan` | Fazy, pliki, DoD |
| Technical Context w planie | Stack, testy, konwencje |
| `eversis-review-codebase` | Gdy Technical Context pusty |
| `eversis-review-plan` | `.plan-review.md` → **bramka: approve plan** |

Wynik: `docs/specs/<task>/<task>.plan.md`.

### Faza 4 — Implement

Software Engineer (lub inny route z planu) dostaje **zatwierdzony plan** + Technical Context — nie zbiera wiedzy od zera. Odkrycia w trakcie → Changelog w planie (**Phase 3 tego ticketu czyni ten Changelog też celem zero-compaction handoff**).

### Faza 5 — Fine

Skill `eversis-promote-domain-knowledge`: trwałe fakty → draft `docs/context/<project>/<component>/index.md` (ścieżka już poprawna) + wiersz w `INDEX.md` — **tylko po akceptacji** w Fine. Ten ticket **nie** zaostrza promocji ani nie czyni rollover `changelog.md` obowiązkowym — obie rzeczy zostają w obecnym skillu (opcjonalny rollover ~15–20). Docelowo (po Fazach 4 i 7) dołączają: draft decyzji (ADR) i draft sugestii dla As-Is Pack — każdy osobno gated.

### Problem (motywacja Phase 1)

**Poza zaleceniami** agenci często:

* robią grep/glob `docs/specs/**` **i ładują treść** wielu wyników (nie sam grep — to zostaje dozwolone),
* wczytują wiele starych `*.plan.md`,
* omijają pusty `INDEX.md`,
* wypełniają okno kontekstu → kompresja → ginie **bieżące** TASK-123.

Framework **nie mówi**: „przeszukaj wszystkie specy". Mówi: INDEX → jeden komponent → bieżący ticket, discovery tanio / konsumpcja budżetowana. Phase 1 ma to **egzekwować**; Phase 3 dodaje zawór bezpieczeństwa dla sytuacji, gdy mimo to sesja urośnie.

### Mapa źródeł wiedzy (skrót)

| Warstwa | Ścieżka | Kiedy | Trwałość |
| --- | --- | --- | --- |
| Ticket | Jira MCP | Research | SSOT backlogu |
| SDD bieżącego zadania | `docs/specs/<task>/` | od Step 1 | kontrakt implementacji |
| Wiedza domenowa | `docs/context/<project>/` | Research (INDEX) | cross-task |
| Confluence As-Is Pack | Research (gdy INDEX cienki/pusty) | bootstrap, human-owned | cross-task, poza repo |
| Kod | obszary repo | Research + Implement | prawda runtime |
| Reguły hosta | rules / AGENTS.md / CLAUDE.md | zawsze | konwencje repo |
| Stare specy innych zadań | `docs/specs/*/` | discovery zawsze, konsumpcja budżetowana | historia |

## TO-BE: przepływ po wdrożeniu AC-1 + AC-2 Phase 1–3

Pełny diagram docelowego przepływu (Fazy 1–7): `docs/specs/ac-2/ac-2.research.md`, "Relevant Charts & Diagrams", Diagram 2.

### AS-IS vs TO-BE (skrót)

| Etap | Teraz (przed AC-2) | Po poprawce (shipped) |
| --- | --- | --- |
| Inspekcja startowa | `docs/specs/<task>/` + często grep całego `docs/specs/**`, ładując treść | Discovery zawsze tanie; konsumpcja budżetowana (1-2 pliki) |
| Wiedza domenowa | `INDEX.md` często pusty / omijany | **Obowiązkowy** pierwszy krok: INDEX → 1 komponent; widoczny `Context: N components` (bez licznika audytu) |
| Bootstrap dla projektów maintenance | Brak mechanizmu na zimny start | Rozszerzony `eversis-import-confluence-knowledge`: As-Is Pack pierwsze, `docs/specs/` fallback |
| Rozmiar wątku | Auto-compaction gdy okno się zapełni | Faza 3: dwa triggery (5–10 wymian **lub** zadanie ukończone+przetestowane przy kolejnych taskach) → `CHECKPOINT:` + koniec sesji; `Resume` jako osobna linia |
| Artefakty BA | Obok SDD w `docs/specs/` (AC-1) | `docs/jira-board/<PROJECT>/` (gitignore) |
| Po Fine | Promocja do context bywa pomijana | Promocja bez zmian w tym tickecie (skill nietknięty) |
| Decyzje architektoniczne | Giną w zamkniętych research/plan | Faza 4 (osobny ticket) |
| As-Is Pack (Confluence) | Aktualizowany ręcznie | Faza 7 (osobny ticket) |

## Requirements

### Phase 1 — router (discovery/consumption split)

1. Keep **one** in-repo router: `docs/context/<project>/INDEX.md` (and `docs/context/global/INDEX.md` when the topic is not local). Do **not** add `docs/plan/INDEX.md` or `docs/plans/INDEX.md` as a parallel map.
2. INDEX stays small (one line per component). Bodies live in `docs/context/<project>/<component>/index.md`. `eversis-import-confluence-knowledge` writes that same path (one file per component, consolidate Confluence sections; never one file per heading). `related_specs` points at the current SDD folder; older entries may roll to `changelog.md` (existing optional behaviour in `eversis-promote-domain-knowledge` — **not** made mandatory in this ticket).
3. Encode a **hard read budget** in orchestration + generated Cursor/Claude host instructions, split into two distinct costs:
    * **Discovery** (grep/glob for filenames or topic matches across `docs/specs/**`) — always allowed, cheap, loads no content.
    * **Consumption** (loading the full content of a matched or `related_specs`-listed file) — capped at 1–2 files total.
    * Forbidden: a loop that loads the full content of every discovery match, or dumping Fine artifacts into the router.
    * Narrow the fallback clause in `agent-core.md` to state the discovery/consumption split explicitly.
4. Empty INDEX is a failure mode, not a consumer choice — surfaced as a soft, visible `Context: N components` line in the Implement readiness block, not a CI/git block.
5. Do not invent a second spec-pointer catalog besides `related_specs` / existing `changelog.md`.
6. Generated host adapters (Cursor rules/commands, Claude Code `CLAUDE.md`) name the same INDEX path and the same discovery/consumption split. This ticket does **not** edit `AGENTS.md` or `eversis-fine-handoff`.
7. Do not copy Copilot Collections' "gitignore all specifications" or "-meta repo" as the primary fix.

### Phase 2 — INDEX signal + bootstrap mechanism

8. Optional readiness line `- **Context:** <N> components indexed` (or `0 components indexed`) from `eversis_context_list` / `INDEX.md` row count. Visibility only. **No** “tasks since last audit” line in this ticket.
9. **Extend** `eversis-import-confluence-knowledge` (do not create a new skill): As-Is Pack first when one exists; fall back to clustering raw `docs/specs/` for uncovered modules; distinct no-As-Is-Pack branch. Design and ship the mechanism; do not execute it against a consumer repo. One audit-skill sentence: `source: confluence` + empty `code_paths` → `Update`, never `Delete`. Do not wire `eversis-audit-domain-knowledge` into orchestration.

### Phase 3 — session budget / zero-compaction discipline

10. Orchestration rule 14 in `eversis-orchestrating-implementation` (not `agent-core.md` / SDD): two independent OR triggers — 5–10 exchanges, or completed+tested while further tasks remain. On trigger: `CHECKPOINT:` in the plan Changelog and end the session. Fresh session: optional `Resume` line, independent of `Flow`. Last-task Fine (rule 13) takes precedence. No window-percent trigger for Cursor or Claude Code.
11. Document (no runtime change) that Agent-tool role delegation already provides ephemeral, stateless subagent context per call.

## Delivery Standard

This story follows full spec-driven development (mandatory under Agent Collections).

* Spec folder: `docs/specs/ac-2/`
* Research: `ac-2.research.md` — approved ("Research jest ok", 2026-09-18); DELTA ~50% approved; Question 10 (Description vs shipped) accepted 2026-09-21
* Plan: `ac-2.plan.md` — Phases 1–3 implemented; Phase 5 is this Description refresh
* Implement: load `eversis-implement` (approved plan attached)
* Review: runs inside the Implement session by default (`eversis-review`); standalone `/eversis-review` is optional
* Fine: QA comment draft per `eversis-fine-handoff` (same turn as Fine); publish to tracker only with explicit human OK

## Technical Notes

Shipped touch list (Phases 1–3):

* `.ai/rules/orchestration/agent-core.md` — discovery/consumption split; reject `docs/plan(s)/INDEX.md`
* `.ai/skills/eversis-import-confluence-knowledge` — `<component>/index.md`, As-Is-first + `docs/specs/` fallback + no-As-Is branch; `bootstrap-report.example.md`
* `.ai/skills/eversis-audit-domain-knowledge` — one sentence (`source: confluence` + empty `code_paths` → Update)
* Layer A readiness: `engineering-manager.md`, `eversis-orchestrating-implementation` — `Context`, independent `Resume`, rule 14 (two triggers)
* Layer B: line-count wording only (`spec-driven-development.md`, orchestration `README.md`, `eversis-implement.md`)
* `docs/context/README.md`, `website/docs/reference/domain-context.md` — router wording
* Generated Cursor / Claude adapters via `npm run sync:adapters`

Explicitly **not** touched: `eversis-promote-domain-knowledge`, `eversis-fine-handoff`, `AGENTS.md`, MCP TypeScript source.

Deferred (Phase 4–7): `docs/decisions/` / ADR; status-lifecycle + audit-counter persistence; retrieval 2–4; As-Is Pack sync draft; PI Agent ~50% trigger.

## Acceptance Criteria

### Phase 1

* GIVEN `/eversis-implement` on a ticket WHEN domain knowledge exists THEN the agent reads INDEX, then at most one component file, and does not load the full content of more than 1–2 `docs/specs/` matches (discovery/grep for matches remains unrestricted)
* GIVEN a feature with many historical specs WHEN the agent needs prior intent THEN it follows `related_specs` (1–2 live paths) or `changelog.md`, not every `*.research.md` in the tree
* GIVEN Cursor and Claude Code WHEN host instructions are generated THEN both name the same INDEX path and the same discovery/consumption budget
* GIVEN Fine WHEN durable knowledge was produced THEN INDEX / component promotion is still offered by the existing (unchanged) promote skill; the router stays one-line-per-component
* GIVEN a proposal to add `docs/plan/INDEX.md` WHEN implementing this task THEN that path is rejected in favour of `docs/context/<project>/INDEX.md`

### Phase 2

* GIVEN a project's `docs/context/<project>/INDEX.md` WHEN Implement readiness is emitted THEN the block may show `Context: N components indexed` (or `0`) instead of staying silent — not a tasks-since-audit count
* GIVEN the bootstrap mechanism WHEN a target repo has a Confluence As-Is Pack THEN the extended `eversis-import-confluence-knowledge` skill specifies checking it before raw `docs/specs/` clustering (the mechanism is designed, not run, as part of this ticket's DoD)

### Phase 3

* GIVEN an active implementation session WHEN either remaining trigger (5–10 exchanges, or task completed+tested while further tasks remain) fires first THEN the agent writes a `CHECKPOINT:` to the plan Changelog and ends the session instead of continuing toward automatic compaction — except on the plan's last task, where Fine proceeds in the same turn. Window ~50% is not a trigger on Cursor or Claude Code.
```
