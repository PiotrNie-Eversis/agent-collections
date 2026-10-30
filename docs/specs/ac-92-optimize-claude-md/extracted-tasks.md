# ac-92-optimize-claude-md - Extracted Tasks

## Workshop Summary

| Field | Value |
|---|---|
| Workshop Date | 2026-10-30 (desk analysis, no workshop) |
| Participants | Piotr Niemirski |
| Source Materials | [S1] PostHog — "Your AGENTS.md is holding you back"; [S2] ColdTea — AGENTS.md field study (100 most-starred repos); [S3] Jira AC-92 + AC-93–AC-98; [S4] open AC backlog; [S5] repo `CLAUDE.md`, `AGENTS.md`, AGENTS template and standard |
| Intent Brief | [`intent-brief.md`](./intent-brief.md) — Gate 0 Approved 2026-10-30 |
| Project Baseline Used | `docs/context/agent-collections/task-baseline.md`, `docs/context/agent-collections/jira-backlog-hierarchy/` |
| Total Epics | 1 (new) |
| Total Stories | 1 (AC-92, re-typed Task → Story) |
| Total Tasks | 10 — 6 existing (AC-93–AC-98, re-typed Sub-task → Task; AC-94 and AC-98 extended) + 4 new (A, B, C, D) |

Hierarchy (AC rule): Epic → Story AC-92 → Tasks AC-93–AC-98; Epic → Tasks A, B, C, D.

## Epics Overview

| # | Epic Title | Children | Priority |
|---|-----------|----------|----------|
| 1 | Agent instruction files: lean and accurate | Story AC-92 (+6 Tasks), Tasks A, B, C, D | High |

## Epic 1: Agent instruction files: lean and accurate

**Business Description**: Every agent session starts by reading instruction files. Field reports show that extra or stale lines now make agents work worse, not better. This epic makes the framework's instruction files short, justified line by line, checked after each change, and kept accurate over time — in this repository and in consumer installs.

**Success Criteria**:
- `CLAUDE.md` is a thin root (≤ 257 lines) and every always-on rule in it names the failure it prevents.
- A stored set of regression prompts is re-run whenever the startup instructions change.
- Maintainers have a routine to re-check instruction files after tool or framework upgrades.
- `AGENTS.md` and its template read as an operating manual: exact commands, structure, boundaries.

### Story 1.1 (AC-92): Claude Code: Thin-root CLAUDE.md with phase rules loaded on demand

**Change type**: Existing ticket — re-type Task → Story; move under Epic 1. Description unchanged except the AC line "All 6 sub-tasks are Done" → "All 6 child Tasks are Done".

**User Story**: As a Claude Code user, I want a short startup instruction file that holds only always-needed rules so that every session starts lighter and the agent follows one clear set of gates and limits.

**Source**: S3 (AC-92 as created 2026-10-19); S1 (progressive disclosure, removal over addition); S2 (keep it short, link instead of repeat); hierarchy rule (leaf must be Task/Bug).

**Acceptance Criteria**: unchanged from AC-92, with the wording fix above.

**High-Level Technical Notes**: None (Jira re-type only).

**Priority**: High

#### Task 1.1.1 (AC-93): Claude Code user starts sessions without phase-only rules loaded

**Change type**: Re-type Sub-task → Task, parent AC-92. Content unchanged.

**Priority**: High

#### Task 1.1.2 (AC-94): Claude Code user gets the lifecycle, gates and hard limits stated once — **extended**

**Change type**: Re-type Sub-task → Task, parent AC-92. Add the requirements and AC below to the existing ones.

**User Story (extended)**: As a Claude Code user, I want the lifecycle, human gates and hard limits stated once, and every remaining always-on rule to earn its place, so that the agent follows one clear rule set without lines that no longer prevent anything.

**Source**: S3 (AC-94); S1 ("For each line, if you can't name the failure it prevents, delete it"; shift from rules and repetition to judgment); S2 (90% of files use must/always/never); repo: 37 lines in `CLAUDE.md` use must/never/always/do not.

**Added requirements**:
6. Each always-on rule kept in `CLAUDE.md` has a recorded reason — the failure it prevents — in a committed file outside `docs/specs/`, next to the Claude generator configuration; a rule with no nameable failure is removed or moved to the skill that needs it.
7. Strong words (must / never / always / do not) are kept only for the human gates and the three hard limits; other rules use plain directive wording.

**Added Acceptance Criteria**:
- [ ] GIVEN the condensed `CLAUDE.md` WHEN a maintainer opens the repository on a fresh clone THEN a committed file outside `docs/specs/` lists every always-on rule with the failure it prevents, and the generated `CLAUDE.md` does not contain these reasons
- [ ] GIVEN a rule for which no failure can be named WHEN the core is condensed THEN the rule is removed from `CLAUDE.md` or moved to the skill or prompt that uses it, and the reasons file records where it went
- [ ] GIVEN the condensed `CLAUDE.md` WHEN a reader scans it THEN must / never / always / do not appear only in human-gate and hard-limit statements

**High-Level Technical Notes**: Reasons live in a committed file next to the Claude generator configuration (research picks the exact location), not in `CLAUDE.md` itself (the file must stay short) and not only in the research artifact (`docs/specs/` is gitignored on `master`). New always-on rules are added together with their reason. *(QR S-01)*

**Priority**: High

#### Task 1.1.3 (AC-95): Agent finds phase procedures in the skills that run them

**Change type**: Re-type Sub-task → Task, parent AC-92. Content unchanged.

**Priority**: High

#### Task 1.1.4 (AC-96): Consumer team keeps a working install with the thin root

**Change type**: Re-type Sub-task → Task, parent AC-92. Content unchanged.

**Priority**: High

#### Task 1.1.5 (AC-97): Maintainer gets an automated guard on the startup file

**Change type**: Re-type Sub-task → Task, parent AC-92. Content unchanged.

**Priority**: Medium

#### Task 1.1.6 (AC-98): Maintainer can show Claude Code still follows the gates — **extended**

**Change type**: Re-type Sub-task → Task, parent AC-92. Replace requirement 4 and add the AC below.

**User Story (extended)**: As a framework maintainer, I want a stored, repeatable set of check prompts for a fresh Claude Code session so that I can show the thinner file kept gates, hard limits and the Fine handoff — now and after every later change to the startup instructions.

**Source**: S3 (AC-98); S1 ("Test context like code"; save prompts that caused failures and re-run them on every AGENTS.md edit); repo: `docs/specs/` is gitignored in this repository, so prompts stored only there are lost.

**Changed requirement**:
4. Prompts and expected results are stored in a committed file outside `docs/specs/`; observed results for this run are recorded in the spec folder.

**Added requirements**:
5. The maintainer docs say when to re-run the set: any change to the generated `CLAUDE.md`, `agent-core.md`, or the Claude generator.
6. When an agent mistake is traced to a missing or wrong instruction, the triggering prompt is added to the set.
7. The prompt set is also run in a consumer project installed with `--vendor copy` from the local, unpushed framework working tree, before the change is pushed; the maintainer docs say so.

**Added Acceptance Criteria**:
- [ ] GIVEN a consumer project installed with `--vendor copy` from the local, unpushed framework working tree WHEN the maintainer runs the prompt set in a fresh Claude Code session there THEN readiness block, hard limits and the Fine QA draft behave as in the self-host run, and observed results are recorded for both runs
- [ ] GIVEN the maintainer docs WHEN a maintainer prepares to push a change to the startup instructions THEN they are told to run the consumer check with `--vendor copy` before pushing (`--vendor submodule` needs pushed commits)
- [ ] GIVEN a prompt in the set WHEN its observed result differs from the expected result THEN the change is not pushed until the instruction is fixed, or the expected result is updated on purpose with a one-line reason recorded next to it *(QR S-02)*
- [ ] GIVEN an always-on rule is removed on purpose WHEN the change is prepared THEN the prompts that only checked that rule are removed from the set, or their expected result is updated, in the same change *(QR S-03)*
- [ ] GIVEN the check is done WHEN a maintainer opens the repository on a fresh clone THEN the prompt set with expected results is present (committed, not under `docs/specs/`)
- [ ] GIVEN a later change to `CLAUDE.md`, `agent-core.md` or the Claude generator WHEN the maintainer reads the maintainer docs THEN they are told to re-run the prompt set before merging
- [ ] GIVEN an agent mistake traced to an instruction gap WHEN it is fixed THEN the maintainer docs say to add the triggering prompt and its expected result to the set

**High-Level Technical Notes**: Manual run stays manual; an automated evaluator is out of scope. `--vendor copy` copies the local `COLLECTIONS_HOME` working tree (incl. uncommitted changes) into `vendor/agent-collections/` (`scripts/lib/setup-agent-collections/vendor.sh`); research confirms exact flags. Use a throwaway branch or clone of the consumer project.

**Priority**: Medium

### Task 1.2 (new, A): Maintainer re-checks instruction files after each upgrade

**User Story**: As a framework maintainer, I want a short routine to run after a Claude Code or framework upgrade so that instruction lines that went stale or became unnecessary are found before agents act on them.

**Source**: S1 (run `/doctor` after each upgrade: ~350 tokens trimmed from a 1,780-token file, 3 plugins + 3 skills disabled ≈ 6K tokens/session; stale merge-queue line → 21 h of wrong agent behaviour, `/doctor` cannot see non-code state).

**Acceptance Criteria**:
- [ ] GIVEN a Claude Code or framework upgrade WHEN the maintainer opens the maintainer docs THEN a checklist tells them to run the built-in health check and review its token, plugin and skill findings
- [ ] GIVEN the checklist WHEN the maintainer follows it THEN it asks them to re-read every instruction line that describes state not visible in code (process, CI, merge rules, external services) and confirm it is still true
- [ ] GIVEN the routine is done WHEN the maintainer records it THEN a dated entry is added to a committed review log next to the rule-reasons file (AC-94), listing what was removed or changed, or "no change" *(QR S-06)*
- [ ] GIVEN a consumer team reads the upgrade guide WHEN they finish an upgrade THEN the guide points them to the same checklist for their own instruction files

**Additional Acceptance Checks**:
- The checklist fits on one screen.

**High-Level Technical Notes**: `/doctor` is a Claude Code built-in; the routine is documentation, no new tooling.

**Priority**: Medium

### Task 1.3 (new, B): Agent reports instruction friction at Fine

**User Story**: As a framework maintainer, I want the agent to note at Fine which instructions were missing, wrong or confusing, and which skills it loaded, so that real problems in the instruction files surface from daily use instead of guesswork.

**Source**: S1 (Wizard's final instruction asks what information would have prevented failures or wasted turns; PR template asks agents to name skills invoked; feedback is clustered and verified before any fix).

**Acceptance Criteria**:
- [ ] GIVEN a task reaches Fine WHEN the agent hit a missing, wrong or conflicting instruction during the run THEN the Fine turn includes a short, labeled note naming the instruction and the turns it cost
- [ ] GIVEN a task reaches Fine with no such problem WHEN the agent hands off THEN no friction note is added (no empty section)
- [ ] GIVEN the friction note is shown WHEN the human reads it THEN it also lists the skills loaded in the session
- [ ] GIVEN a friction note WHEN it is produced THEN it is a draft only: it is not posted to Jira, not written to any file, and no rule changes without the human's approval
- [ ] GIVEN the QA comment draft WHEN the friction note exists THEN the QA draft is unchanged (the note is separate)

**High-Level Technical Notes**: Lives in `eversis-fine-handoff`; follows the same "own approval" pattern as the optional promotion draft.

**Priority**: Medium

### Task 1.4 (new, C): AGENTS.md reads as an operating manual

**User Story**: As an agent or engineer opening this repository or a consumer project, I want `AGENTS.md` to give exact commands, where things live, and clear boundaries so that I can build, test and verify changes without guessing or following stale lines.

**Source**: S2 (operating manual, not policy; fenced commands incl. single test — present in only 25% of top repos; boundaries tied to real failures, e.g. "Do not claim that an interrupted or timed-out test passed", "Never delete, weaken, or rewrite a test to make a change pass"; link instead of repeat; ≈ two pages); repo: `AGENTS.md` lists commands inline, no single-test command, lists deprecated `docs/plans/` (AC-3) and outdated `task-*` gitignore wording.

**Acceptance Criteria**:
- [ ] GIVEN `AGENTS.md` in this repository WHEN a reader looks for commands THEN install, adapter sync/check, MCP build/test, installer smoke test, website build and how to run a single test are in fenced code blocks
- [ ] GIVEN `AGENTS.md` WHEN a reader looks for boundaries THEN it states that interrupted or timed-out tests are never reported as passed and that tests are never deleted or weakened to make a change pass
- [ ] GIVEN `AGENTS.md` WHEN it is compared with the repository THEN it no longer lists `docs/plans/` as a deliverable and describes `docs/specs/` gitignore scope as it is today
- [ ] GIVEN `templates/AGENTS.template.md` and `docs/architecture/agents-md-standard.md` WHEN a consumer team builds its own `AGENTS.md` THEN both ask for fenced commands incl. single test, a structure map, and the same two testing boundaries
- [ ] GIVEN the refreshed files WHEN their length is checked THEN `AGENTS.md` stays at or below its current 89 lines and links to deeper docs instead of repeating them
- [ ] GIVEN the template changes ship WHEN a consumer reads `CHANGELOG.md` THEN an entry lists what changed in `templates/AGENTS.template.md` (fenced commands incl. single test, the two testing boundaries), says that an existing project `AGENTS.md` is not overwritten, and tells the team how to adopt the changes by hand *(QR S-04)*

**High-Level Technical Notes**: Hard limits (scope, doc comments, dependencies) already live in `agent-core.md`; this Task adds the two testing boundaries to `AGENTS.md` and the template only. The installer creates `AGENTS.md` from the template only when missing (`scripts/lib/setup-agent-collections/scaffolding.sh`); consumer `.claude/CLAUDE.md` imports `@../AGENTS.md`, so its length also counts toward every Claude Code session's startup context. *(QR S-04)* Single-test commands are given per test suite (MCP: `node --import tsx/esm --test tests/<file>.test.ts` in `mcp/eversis-collections-mcp/`; generator test from AC-97; installer smoke test runs whole), in a form verified to work in this repo; the test-command section is finalized once AC-97 adds the root test script, the rest of the Task does not wait. *(QR S-05)*

**Priority**: High

### Task 1.5 (new, D): Reader learns why and how the framework slimmed its agent instruction files

**User Story**: As a reader of the Agent Collections blog (framework user, tech lead, consumer team), I want a technical write-up of why instruction files were slimmed and how the framework keeps them accurate so that I understand the change and can apply the same practice to my own project's `CLAUDE.md` / `AGENTS.md`.

**Source**: Gate 1 request (2026-10-30); S1, S2 (findings to cite); AC-31 (blog for framework change write-ups); existing post `website/blog/2026-09-24-context-reads-session-and-upgrade-contract.md` (format reference).

**Acceptance Criteria**:
- [ ] GIVEN the post is published WHEN a reader opens `/blog` THEN a new post explains the problem (startup instructions read every session; extra or stale lines make agents worse) with the before / after size of `CLAUDE.md` measured on the shipped version
- [ ] GIVEN the post WHEN a reader looks for the reasoning THEN it cites the PostHog and ColdTea articles by name with links, quoting only short passages
- [ ] GIVEN the post WHEN a reader looks for how the framework applies it THEN it covers the thin root with phase rules loaded on demand, the "name the failure each line prevents" rule, the stored regression prompt set, and the pre-push consumer check with `--vendor copy`
- [ ] GIVEN parts of the epic are not Done at publication WHEN the post mentions them THEN they are marked as planned, not described as shipped
- [ ] GIVEN a consumer reader WHEN they reach the end of the post THEN a short checklist tells them how to apply the same practice to their own instruction files
- [ ] GIVEN the post is added WHEN `npm run website:build` runs THEN the build passes

**Additional Acceptance Checks**:
- Follows the existing blog post format (frontmatter `title` / `description` / `slug`, `<!-- truncate -->` after the intro); English.

**High-Level Technical Notes**: Numbers (lines, approximate tokens) are taken from the shipped files, not from the AC-92 targets.

**Priority**: Low

## Dependencies

| Task | Depends On | Type | Notes |
|------|-----------|------|-------|
| AC-93, AC-94 | AC-95 | Blocked by | Unchanged from AC-92 |
| AC-96, AC-97 | AC-93, AC-94 | Blocked by | Unchanged from AC-92 |
| AC-98 | AC-93–AC-97 | Blocked by | Unchanged from AC-92 |
| Task 1.2 (A) | AC-98 | Related to | Routine points to the stored prompt set for re-checks |
| Task 1.3 (B) | AC-95 | Related to | Both edit `eversis-fine-handoff`; avoid parallel edits |
| Task 1.4 (C) | AC-3 | Related to | AC-3 deprecates `docs/plans/`; C removes it from `AGENTS.md` |
| Task 1.4 (C) | AC-97 | Related to | AC-97 adds the root test script that C's single-test command refers to *(QR S-05)* |
| AC-92 | AC-80 | Related to | Existing link, unchanged |
| Task 1.5 (D) | AC-92 | Blocked by | Post needs the shipped `CLAUDE.md` numbers and mechanisms |
| Task 1.5 (D) | AC-31 | Related to | Blog for framework change write-ups |

## Assumptions

| # | Assumption | Confidence | Impact if Wrong |
|---|-----------|------------|-----------------|
| 1 | ~~Re-typing AC-93–AC-98 to Task keeps their keys~~ — superseded 2026-10-30 at formatting: per `jira-backlog-hierarchy`, AC-93–AC-98 are replaced by new Tasks T1–T6 (parent = Epic, Relates AC-92); old Sub-tasks linked Duplicate, commented, closed Done | — | Keys change; see `jira-tasks.md` |
| 2 | AC-92 can be re-typed Task → Story in project AC | Medium | If Story is not allowed, AC-92 stays a Task directly under the Epic and AC-93–AC-98 become sibling Tasks under the Epic with "Blocks" links |
| 3 | `/doctor` remains available in Claude Code | High | Task A names the current health-check command instead |

## Out of Scope

- Automated LLM evaluator on sample projects (S1 `wizard-ci` / `pr-evaluator`) — too heavy for now.
- Edits to `.ai/rules/*.md` and `.cursor/rules/*.mdc` inside AC-92 (option B unchanged).
- Changing skill allowlists — `adapters/profiles/*.yaml` already filter installed skills.

## Open Questions for Stakeholders

None — resolved at Gate 0.
