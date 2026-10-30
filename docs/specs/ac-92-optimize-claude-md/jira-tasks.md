# Agent instruction files (AC-92 follow-up) — Jira-ready tasks

Formatted from `extracted-tasks.md` after Gate 1 and Gate 1.5 (2026-10-30). Local markdown; Jira markup inside description blocks is applied when issues are created or updated.

Backlog rules: `docs/context/agent-collections/jira-backlog-hierarchy/` — the leaf is a Task/Bug; Story and Task share one hierarchy level in AC, so **Story → Task is an issue link**, not the `parent` field; Sub-tasks used as the leaf are replaced by new Tasks (old ones linked Duplicate, commented, closed Done). Decision 2026-10-30: replace AC-93–AC-98 per the rule.

Target hierarchy:

```text
Epic (new) "Agent instruction files: lean and accurate"
├── Story AC-92 (re-typed Task → Story, parent = Epic)
│     └─ linked (Relates) ── Tasks T1–T6 (new, parent = Epic; replace AC-93–AC-98)
├── Task A (new) — upkeep after upgrades
├── Task B (new) — friction note at Fine
├── Task C (new) — AGENTS.md operating manual
└── Task D (new) — blog post
Old Sub-tasks AC-93–AC-98 → Duplicate link to T1–T6, comment, close Done
```

## Sync summary (Gate 2 preview)

| Action | Items | Count |
|---|---|---|
| CREATE | Epic; T1–T6 (replace AC-93–AC-98); Tasks A, B, C, D | 11 |
| UPDATE | AC-92 — issue type Task → Story, parent → Epic, AC line "All 6 sub-tasks are Done" → "All 6 linked Tasks are Done" | 1 |
| CLOSE | AC-93–AC-98 — link Duplicate → T1–T6, comment, transition Done | 6 |
| LINKS | T1–T6 Relates AC-92; Blocks between T1–T6 (as today); Task B Relates T3; Task C Relates AC-3, T5; Task D blocked by AC-92, Relates AC-31; Task A Relates T6 | — |
| SKIPPED | none (no protected statuses) | 0 |

## Completeness

| Item | Required fields | Priority | Notes |
|---|---|---|---|
| Epic | Complete | High | — |
| AC-92 | Complete (existing) | High | Re-type + one AC wording change only |
| T1 (← AC-93) | Complete | High | Content unchanged |
| T2 (← AC-94) | Complete | High | Extended (Gate 1, QR S-01) |
| T3 (← AC-95) | Complete | High | Content unchanged |
| T4 (← AC-96) | Complete | High | Content unchanged |
| T5 (← AC-97) | Complete | Medium | Content unchanged |
| T6 (← AC-98) | Complete | Medium | Extended (Gate 1, vendor copy, QR S-02, S-03) |
| Task A | Complete | Medium | QR S-06 |
| Task B | Complete | Medium | — |
| Task C | Complete | High | QR S-04, S-05 |
| Task D | Complete | Low | Spec folder name set after key is known |

Labels used: `agent-collections`, `claude-code`, `instruction-files`, `token-budget`, `analyze-2026-10-30` (+ AC-92's existing labels kept).

---

### Epic: Agent instruction files: lean and accurate

**Issue Type**: Epic
**Jira Key**: —
**Status**: —
**Priority**: High

**Description**:
```
h2. Overview

Every agent session starts by reading instruction files (CLAUDE.md, AGENTS.md). Field reports show that extra or stale lines now make agents work worse, not better. This epic makes the framework's instruction files short, justified line by line, checked after every change, and kept accurate over time — in this repository and in consumer installs.

h2. Business Value

Lighter sessions (fewer startup tokens), fewer agent mistakes caused by outdated or conflicting rules, and a repeatable way to prove that slimming did not weaken human gates. Consumer teams get the same practice for their own files.

h2. Success Metrics

* Generated CLAUDE.md is at most 257 lines (from 396) and every always-on rule has a recorded reason
* A stored regression prompt set is re-run before any change to the startup instructions is pushed
* Maintainers run a short upkeep routine after each Claude Code or framework upgrade
* AGENTS.md and its template give exact commands, structure and testing boundaries

h2. Sources

* PostHog — "Your AGENTS.md is holding you back": https://newsletter.posthog.com/p/your-agentsmd-is-holding-you-back
* ColdTea — AGENTS.md field study (100 most-starred repos): https://www.coldtea.ai/blog/agents-md-field-study
* Analysis: docs/specs/ac-92-optimize-claude-md/intent-brief.md
```

**Acceptance Criteria**:
```
(/) Story AC-92 and all linked Tasks are Done
(/) Tasks for upkeep routine, Fine friction note, AGENTS.md refresh and blog post are Done
```

**Labels**: `agent-collections`, `claude-code`, `instruction-files`, `token-budget`, `analyze-2026-10-30`

---

### Story: Claude Code: Thin-root CLAUDE.md with phase rules loaded on demand

**Parent**: Agent instruction files: lean and accurate
**Issue Type**: Story (re-typed from Task)
**Jira Key**: AC-92
**Status**: Backlog
**Priority**: High

**Change**: issue type Task → Story; parent → new Epic; description unchanged except Acceptance Criteria line "All 6 sub-tasks are Done" → "All 6 linked Tasks are Done". Existing labels and the AC-80 link stay.

---

### Task T1: Claude Code user starts sessions without phase-only rules loaded

**Parent**: Agent instruction files: lean and accurate · **Links**: Relates AC-92; Duplicate of → closes AC-93; Blocked by T3
**Issue Type**: Task
**Jira Key**: —
**Status**: —
**Priority**: High
**Sizing Guidance**: Medium (5-8)

**Description**: AC-93 description copied unchanged, with the first Context line changed to: "Part of Story AC-92 (thin-root CLAUDE.md); replaces Sub-task AC-93. Blocked by T3 (skills/prompts must hold the procedures first)." Requirements, Technical Notes and Acceptance Criteria as in AC-93.

**Labels**: `agent-collections`, `claude-code`, `instruction-files`, `token-budget`

---

### Task T2: Claude Code user gets the lifecycle, gates and hard limits stated once

**Parent**: Agent instruction files: lean and accurate · **Links**: Relates AC-92; Duplicate of → closes AC-94; Blocked by T3
**Issue Type**: Task
**Jira Key**: —
**Status**: —
**Priority**: High
**Sizing Guidance**: Medium (5-8)

**Description**:
```
h2. Context

Part of Story AC-92 (thin-root CLAUDE.md); replaces Sub-task AC-94. Condenses the always-on core so each rule appears once, and makes every remaining always-on rule earn its place. Blocked by T3.

h2. User Story

As a Claude Code user, I want the lifecycle, human gates and hard limits stated once, and every remaining always-on rule to earn its place, so that the agent follows one clear rule set without lines that no longer prevent anything.

h2. Requirements

# One table or list covers Ideate → Research → Plan → Implement → Review → Fine and which stages need human approval.
# One hard-limits list (scope, documentation comments, dependencies), applying in Implement and as BLOCKERs in Review.
# A short readiness statement: the four required lines come first in an Implement run; the skill holds the full contract.
# A plain-language implementation request (no slash command) still routes to the orchestration flow.
# All links in CLAUDE.md resolve from the repository root.
# Each always-on rule kept in CLAUDE.md has a recorded reason — the failure it prevents — in a committed file outside docs/specs/, next to the Claude generator configuration; a rule with no nameable failure is removed or moved to the skill that needs it.
# Strong words (must / never / always / do not) are kept only for the human gates and the three hard limits; other rules use plain directive wording.

h2. Technical Notes

agent-core.md is not edited (option B), so the Claude adapter produces the condensed core. Research picks the mechanism (section selection from the source vs. a Claude-specific template) and how drift from agent-core.md is caught (see T5). Rule reasons live in a committed file next to the generator configuration (research picks the location) — not in CLAUDE.md (must stay short) and not only in the research artifact (docs/specs/ is gitignored on master). New always-on rules are added together with their reason. Source: PostHog — "For each line, if you can't name the failure it prevents, delete it."
```

**Acceptance Criteria**:
```
(/) GIVEN CLAUDE.md is generated WHEN a reader looks for the lifecycle and human gates THEN they are stated once, covering all six stages and which need human approval
(/) GIVEN CLAUDE.md is generated WHEN a reader looks for hard limits THEN one list states the three limits and says they apply in Implement and are BLOCKERs in Review
(/) GIVEN the startup file mentions the Implement readiness block WHEN a reader reads it THEN it names the four required lines (Flow, Research, Plan, Next gate) and points to the skill for the full contract
(/) GIVEN the startup file links to another file WHEN the link is followed from the repository root THEN it resolves
(/) GIVEN a user asks for implementation work without /eversis-implement WHEN the agent reads CLAUDE.md THEN it is told to load eversis-implement / eversis-orchestrating-implementation first and to emit "## Implement readiness" before any code
(/) Every gate in the current file is still stated in CLAUDE.md or owned by a skill or prompt that CLAUDE.md names
(/) GIVEN the condensed CLAUDE.md WHEN a maintainer opens the repository on a fresh clone THEN a committed file outside docs/specs/ lists every always-on rule with the failure it prevents, and the generated CLAUDE.md does not contain these reasons
(/) GIVEN a rule for which no failure can be named WHEN the core is condensed THEN the rule is removed from CLAUDE.md or moved to the skill or prompt that uses it, and the reasons file records where it went
(/) GIVEN the condensed CLAUDE.md WHEN a reader scans it THEN must / never / always / do not appear only in human-gate and hard-limit statements
```

**Labels**: `agent-collections`, `claude-code`, `instruction-files`, `token-budget`

---

### Task T3: Agent finds phase procedures in the skills that run them

**Parent**: Agent instruction files: lean and accurate · **Links**: Relates AC-92; Duplicate of → closes AC-95; Blocks T1, T2
**Issue Type**: Task
**Jira Key**: —
**Status**: —
**Priority**: High
**Sizing Guidance**: Small (1-3)

**Description**: AC-95 description copied unchanged, with the first Context line changed to: "Part of Story AC-92 (thin-root CLAUDE.md); replaces Sub-task AC-95. Must land before T1 and T2." Requirements, Technical Notes and Acceptance Criteria as in AC-95.

**Labels**: `agent-collections`, `claude-code`, `instruction-files`, `token-budget`

---

### Task T4: Consumer team keeps a working install with the thin root

**Parent**: Agent instruction files: lean and accurate · **Links**: Relates AC-92; Duplicate of → closes AC-96; Blocked by T1, T2
**Issue Type**: Task
**Jira Key**: —
**Status**: —
**Priority**: High
**Sizing Guidance**: Medium (5-8)

**Description**: AC-96 description copied unchanged, with the first Context line changed to: "Part of Story AC-92 (thin-root CLAUDE.md); replaces Sub-task AC-96. Blocked by T1 and T2." Requirements, Technical Notes and Acceptance Criteria as in AC-96.

**Labels**: `agent-collections`, `claude-code`, `instruction-files`, `token-budget`

---

### Task T5: Maintainer gets an automated guard on the startup file

**Parent**: Agent instruction files: lean and accurate · **Links**: Relates AC-92; Duplicate of → closes AC-97; Blocked by T1, T2
**Issue Type**: Task
**Jira Key**: —
**Status**: —
**Priority**: Medium
**Sizing Guidance**: Small (1-3)

**Description**: AC-97 description copied unchanged, with the first Context line changed to: "Part of Story AC-92 (thin-root CLAUDE.md); replaces Sub-task AC-97. Blocked by T1 and T2." Requirements, Technical Notes and Acceptance Criteria as in AC-97.

**Labels**: `agent-collections`, `claude-code`, `instruction-files`, `token-budget`

---

### Task T6: Maintainer can show Claude Code still follows the gates

**Parent**: Agent instruction files: lean and accurate · **Links**: Relates AC-92; Duplicate of → closes AC-98; Blocked by T1–T5
**Issue Type**: Task
**Jira Key**: —
**Status**: —
**Priority**: Medium
**Sizing Guidance**: Medium (5-8)

**Description**:
```
h2. Context

Part of Story AC-92 (thin-root CLAUDE.md); replaces Sub-task AC-98. Behavioral check on the regenerated file, turned into a stored, repeatable prompt set. Runs after T1–T5.

h2. User Story

As a framework maintainer, I want a stored, repeatable set of check prompts for a fresh Claude Code session so that I can show the thinner file kept gates, hard limits and the Fine handoff — now and after every later change to the startup instructions.

h2. Requirements

# Readiness block appears first via /eversis-implement and via a plain-language request.
# Hard limits hold: out-of-plan edit, new dependency, removing a documentation comment.
# Fine produces the labeled QA draft and does not post to Jira.
# Prompts and expected results are stored in a committed file outside docs/specs/; observed results for this run are recorded in the spec folder (docs/specs/ac-92-optimize-claude-md/).
# The maintainer docs say when to re-run the set: any change to the generated CLAUDE.md, agent-core.md, or the Claude generator.
# When an agent mistake is traced to a missing or wrong instruction, the triggering prompt is added to the set.
# The prompt set is also run in a consumer project installed with --vendor copy from the local, unpushed framework working tree, before the change is pushed; the maintainer docs say so.

h2. Technical Notes

Manual run; where possible, run the same prompts on the pre-change file for comparison. An automated evaluator is out of scope. --vendor copy copies the local working tree (incl. uncommitted changes) into vendor/agent-collections/; --vendor submodule needs pushed commits. Research confirms exact flags. Use a throwaway branch or clone of the consumer project. Source: PostHog — "test context like code".
```

**Acceptance Criteria**:
```
(/) GIVEN a fresh session on the regenerated file WHEN the user starts /eversis-implement on a sample task THEN the first content is "## Implement readiness" with Flow, Research, Plan and Next gate
(/) GIVEN a fresh session WHEN the user asks for implementation in plain words without the slash command THEN the first content is still "## Implement readiness" with the four lines
(/) GIVEN an approved plan WHEN the user asks for an out-of-plan edit, a new dependency, or removal of a documentation comment THEN the agent declines or asks for explicit approval
(/) GIVEN an implementation reaches Fine WHEN the agent hands off THEN it outputs the labeled QA comment draft and does not post to Jira
(/) GIVEN the check is done WHEN a reviewer reads the spec folder THEN observed results are recorded for each case
(/) GIVEN the check is done WHEN a maintainer opens the repository on a fresh clone THEN the prompt set with expected results is present (committed, not under docs/specs/)
(/) GIVEN a later change to CLAUDE.md, agent-core.md or the Claude generator WHEN the maintainer reads the maintainer docs THEN they are told to re-run the prompt set before merging
(/) GIVEN an agent mistake traced to an instruction gap WHEN it is fixed THEN the maintainer docs say to add the triggering prompt and its expected result to the set
(/) GIVEN a consumer project installed with --vendor copy from the local, unpushed framework working tree WHEN the maintainer runs the prompt set in a fresh Claude Code session there THEN readiness block, hard limits and the Fine QA draft behave as in the self-host run, and observed results are recorded for both runs
(/) GIVEN the maintainer docs WHEN a maintainer prepares to push a change to the startup instructions THEN they are told to run the consumer check with --vendor copy before pushing
(/) GIVEN a prompt in the set WHEN its observed result differs from the expected result THEN the change is not pushed until the instruction is fixed, or the expected result is updated on purpose with a one-line reason recorded next to it
(/) GIVEN an always-on rule is removed on purpose WHEN the change is prepared THEN the prompts that only checked that rule are removed from the set, or their expected result is updated, in the same change
```

**Labels**: `agent-collections`, `claude-code`, `instruction-files`, `token-budget`

---

### Task A: Maintainer re-checks instruction files after each upgrade

**Parent**: Agent instruction files: lean and accurate · **Links**: Relates T6
**Issue Type**: Task
**Jira Key**: —
**Status**: —
**Priority**: Medium
**Sizing Guidance**: Small (1-3)

**Description**:
```
h2. Context

Part of epic "Agent instruction files: lean and accurate". Keeps instruction files accurate after the AC-92 slimming: tool upgrades change what models need, and lines about non-code state go stale silently.

h2. User Story

As a framework maintainer, I want a short routine to run after a Claude Code or framework upgrade so that instruction lines that went stale or became unnecessary are found before agents act on them.

h2. Requirements

# A one-screen checklist in the maintainer docs, run after each Claude Code or framework upgrade.
# Step: run the built-in health check (/doctor) and review its token, plugin and skill findings.
# Step: re-read every instruction line that describes state not visible in code (process, CI, merge rules, external services) and confirm it is still true.
# Step: record a dated entry in a committed review log next to the rule-reasons file (from AC-92), listing what was removed or changed, or "no change".
# The consumer upgrade guide points to the same checklist for consumer instruction files.

h2. Delivery Standard

This story follows full spec-driven development (mandatory under Agent Collections when applicable).

* Spec folder: docs/specs/<key>-instruction-upkeep/
* Research: <key>-instruction-upkeep.research.md — required before plan
* Plan: <key>-instruction-upkeep.plan.md — required before implementation
* Implement: load eversis-implement (approved plan attached)
* Review: runs inside the Implement session by default (eversis-review); standalone /eversis-review is optional
* Fine: QA comment draft per eversis-fine-handoff (same turn as Fine); publish to tracker only with explicit human OK

Do not start implementation without approved research and plan artifacts.

h2. Technical Notes

Documentation only; no new tooling. Source: PostHog — /doctor trimmed ~350 tokens from a 1,780-token file and suggested disabling 3 plugins + 3 skills (~6K tokens/session); a stale merge-queue line led to 21 h of wrong agent behaviour that /doctor could not detect.
```

**Acceptance Criteria**:
```
(/) GIVEN a Claude Code or framework upgrade WHEN the maintainer opens the maintainer docs THEN a checklist tells them to run the built-in health check and review its token, plugin and skill findings
(/) GIVEN the checklist WHEN the maintainer follows it THEN it asks them to re-read every instruction line that describes state not visible in code and confirm it is still true
(/) GIVEN the routine is done WHEN the maintainer records it THEN a dated entry is added to a committed review log next to the rule-reasons file, listing what was removed or changed, or "no change"
(/) GIVEN a consumer team reads the upgrade guide WHEN they finish an upgrade THEN the guide points them to the same checklist for their own instruction files
(/) The checklist fits on one screen
```

**Labels**: `agent-collections`, `claude-code`, `instruction-files`, `analyze-2026-10-30`

---

### Task B: Agent reports instruction friction at Fine

**Parent**: Agent instruction files: lean and accurate · **Links**: Relates T3 (both edit eversis-fine-handoff)
**Issue Type**: Task
**Jira Key**: —
**Status**: —
**Priority**: Medium
**Sizing Guidance**: Small (1-3)

**Description**:
```
h2. Context

Part of epic "Agent instruction files: lean and accurate". Surfaces real instruction problems from daily use instead of guesswork.

h2. User Story

As a framework maintainer, I want the agent to note at Fine which instructions were missing, wrong or confusing, and which skills it loaded, so that real problems in the instruction files surface from daily use instead of guesswork.

h2. Requirements

# When the agent hit a missing, wrong or conflicting instruction during the run, the Fine turn includes a short, labeled friction note naming the instruction and the turns it cost.
# No problem → no note (no empty section).
# The note lists the skills loaded in the session.
# The note is a draft only: not posted to Jira, not written to any file; no rule changes without human approval.
# The QA comment draft is unchanged; the note is separate.

h2. Delivery Standard

This story follows full spec-driven development (mandatory under Agent Collections when applicable).

* Spec folder: docs/specs/<key>-fine-friction-note/
* Research: <key>-fine-friction-note.research.md — required before plan
* Plan: <key>-fine-friction-note.plan.md — required before implementation
* Implement: load eversis-implement (approved plan attached)
* Review: runs inside the Implement session by default (eversis-review); standalone /eversis-review is optional
* Fine: QA comment draft per eversis-fine-handoff (same turn as Fine); publish to tracker only with explicit human OK

Do not start implementation without approved research and plan artifacts.

h2. Technical Notes

Lives in eversis-fine-handoff; follows the "own approval" pattern of the optional domain-knowledge promotion draft. Coordinate with T3 (also edits eversis-fine-handoff). Source: PostHog — Wizard's final instruction asks what information would have prevented failures; PR template asks agents to name skills invoked; reports are verified before fixes.
```

**Acceptance Criteria**:
```
(/) GIVEN a task reaches Fine WHEN the agent hit a missing, wrong or conflicting instruction during the run THEN the Fine turn includes a short, labeled note naming the instruction and the turns it cost
(/) GIVEN a task reaches Fine with no such problem WHEN the agent hands off THEN no friction note is added
(/) GIVEN the friction note is shown WHEN the human reads it THEN it also lists the skills loaded in the session
(/) GIVEN a friction note WHEN it is produced THEN it is a draft only: not posted to Jira, not written to any file, and no rule changes without the human's approval
(/) GIVEN the QA comment draft WHEN the friction note exists THEN the QA draft is unchanged
```

**Labels**: `agent-collections`, `claude-code`, `instruction-files`, `analyze-2026-10-30`

---

### Task C: AGENTS.md reads as an operating manual

**Parent**: Agent instruction files: lean and accurate · **Links**: Relates AC-3; Relates T5
**Issue Type**: Task
**Jira Key**: —
**Status**: —
**Priority**: High
**Sizing Guidance**: Medium (5-8)

**Description**:
```
h2. Context

Part of epic "Agent instruction files: lean and accurate". Brings AGENTS.md, its consumer template and the AGENTS.md standard in line with what the largest repositories put in theirs.

h2. User Story

As an agent or engineer opening this repository or a consumer project, I want AGENTS.md to give exact commands, where things live, and clear boundaries so that I can build, test and verify changes without guessing or following stale lines.

h2. Requirements

# AGENTS.md lists install, adapter sync/check, MCP build/test, installer smoke test, website build and how to run a single test, in fenced code blocks.
# AGENTS.md states two testing boundaries: interrupted or timed-out tests are never reported as passed; tests are never deleted or weakened to make a change pass.
# Stale lines are removed: docs/plans/ as a deliverable (see AC-3); docs/specs/ gitignore scope described as it is today.
# templates/AGENTS.template.md and docs/architecture/agents-md-standard.md ask for the same: fenced commands incl. single test, a structure map, the two testing boundaries.
# AGENTS.md stays at or below its current 89 lines and links to deeper docs instead of repeating them.
# CHANGELOG tells consumers what changed in the template, that an existing project AGENTS.md is not overwritten, and how to adopt the changes by hand.

h2. Delivery Standard

This story follows full spec-driven development (mandatory under Agent Collections when applicable).

* Spec folder: docs/specs/<key>-agents-md-manual/
* Research: <key>-agents-md-manual.research.md — required before plan
* Plan: <key>-agents-md-manual.plan.md — required before implementation
* Implement: load eversis-implement (approved plan attached)
* Review: runs inside the Implement session by default (eversis-review); standalone /eversis-review is optional
* Fine: QA comment draft per eversis-fine-handoff (same turn as Fine); publish to tracker only with explicit human OK

Do not start implementation without approved research and plan artifacts.

h2. Technical Notes

Hard limits (scope, doc comments, dependencies) stay in agent-core.md; this Task adds only the two testing boundaries. The installer creates AGENTS.md from the template only when missing (scripts/lib/setup-agent-collections/scaffolding.sh); consumer .claude/CLAUDE.md imports @../AGENTS.md, so its length counts toward every Claude Code session's startup context. Single-test commands per suite (MCP: node --import tsx/esm --test tests/<file>.test.ts in mcp/eversis-collections-mcp/; generator test from T5; installer smoke test runs whole), verified in this repo; the test-command section is finalized once T5 adds the root test script. Source: ColdTea field study — operating manual over policy; single-test command in only 25% of top repos; boundaries tied to real failures.
```

**Acceptance Criteria**:
```
(/) GIVEN AGENTS.md in this repository WHEN a reader looks for commands THEN install, adapter sync/check, MCP build/test, installer smoke test, website build and how to run a single test are in fenced code blocks
(/) GIVEN AGENTS.md WHEN a reader looks for boundaries THEN it states that interrupted or timed-out tests are never reported as passed and that tests are never deleted or weakened to make a change pass
(/) GIVEN AGENTS.md WHEN it is compared with the repository THEN it no longer lists docs/plans/ as a deliverable and describes docs/specs/ gitignore scope as it is today
(/) GIVEN templates/AGENTS.template.md and docs/architecture/agents-md-standard.md WHEN a consumer team builds its own AGENTS.md THEN both ask for fenced commands incl. single test, a structure map, and the same two testing boundaries
(/) GIVEN the refreshed files WHEN their length is checked THEN AGENTS.md stays at or below its current 89 lines and links to deeper docs instead of repeating them
(/) GIVEN the template changes ship WHEN a consumer reads CHANGELOG.md THEN an entry lists what changed in templates/AGENTS.template.md, says that an existing project AGENTS.md is not overwritten, and tells the team how to adopt the changes by hand
```

**Labels**: `agent-collections`, `instruction-files`, `analyze-2026-10-30`

---

### Task D: Reader learns why and how the framework slimmed its agent instruction files

**Parent**: Agent instruction files: lean and accurate · **Links**: Blocked by AC-92; Relates AC-31
**Issue Type**: Task
**Jira Key**: —
**Status**: —
**Priority**: Low
**Sizing Guidance**: Small (1-3)

**Description**:
```
h2. Context

Part of epic "Agent instruction files: lean and accurate". Technical write-up on the docs-site blog (AC-31) after AC-92 ships.

h2. User Story

As a reader of the Agent Collections blog (framework user, tech lead, consumer team), I want a technical write-up of why instruction files were slimmed and how the framework keeps them accurate so that I understand the change and can apply the same practice to my own project's CLAUDE.md / AGENTS.md.

h2. Requirements

# The post explains the problem (startup instructions read every session; extra or stale lines make agents worse) with before / after size of CLAUDE.md measured on the shipped version.
# It cites the PostHog and ColdTea articles by name with links, quoting only short passages.
# It covers the thin root with phase rules on demand, the "name the failure each line prevents" rule, the stored regression prompt set, and the pre-push consumer check with --vendor copy.
# Parts of the epic not Done at publication are marked as planned.
# It ends with a short checklist for consumers.
# It follows the existing blog post format (frontmatter title / description / slug, truncate marker after the intro); English.

h2. Delivery Standard

This story follows full spec-driven development (mandatory under Agent Collections when applicable).

* Spec folder: docs/specs/<key>-instruction-files-post/
* Research: <key>-instruction-files-post.research.md — required before plan
* Plan: <key>-instruction-files-post.plan.md — required before implementation
* Implement: load eversis-implement (approved plan attached)
* Review: runs inside the Implement session by default (eversis-review); standalone /eversis-review is optional
* Fine: QA comment draft per eversis-fine-handoff (same turn as Fine); publish to tracker only with explicit human OK

Do not start implementation without approved research and plan artifacts.

h2. Technical Notes

Numbers (lines, approximate tokens) are taken from the shipped files, not from the AC-92 targets. Format reference: website/blog/2026-09-24-context-reads-session-and-upgrade-contract.md.
```

**Acceptance Criteria**:
```
(/) GIVEN the post is published WHEN a reader opens /blog THEN a new post explains the problem with the before / after size of CLAUDE.md measured on the shipped version
(/) GIVEN the post WHEN a reader looks for the reasoning THEN it cites the PostHog and ColdTea articles by name with links, quoting only short passages
(/) GIVEN the post WHEN a reader looks for how the framework applies it THEN it covers the thin root, the "name the failure each line prevents" rule, the stored regression prompt set, and the pre-push consumer check with --vendor copy
(/) GIVEN parts of the epic are not Done at publication WHEN the post mentions them THEN they are marked as planned, not described as shipped
(/) GIVEN a consumer reader WHEN they reach the end of the post THEN a short checklist tells them how to apply the same practice
(/) GIVEN the post is added WHEN npm run website:build runs THEN the build passes
```

**Labels**: `agent-collections`, `instruction-files`, `blog`, `analyze-2026-10-30`

---

## Old Sub-tasks to close (after T1–T6 exist)

| Old | New | Link | Comment | Transition |
|---|---|---|---|---|
| AC-93 | T1 | Duplicate | "Replaced by <T1> per AC hierarchy rule (Sub-task is not a leaf). Content unchanged." | Done |
| AC-94 | T2 | Duplicate | "Replaced by <T2> per AC hierarchy rule; extended (rule reasons, wording)." | Done |
| AC-95 | T3 | Duplicate | "Replaced by <T3> per AC hierarchy rule. Content unchanged." | Done |
| AC-96 | T4 | Duplicate | "Replaced by <T4> per AC hierarchy rule. Content unchanged." | Done |
| AC-97 | T5 | Duplicate | "Replaced by <T5> per AC hierarchy rule. Content unchanged." | Done |
| AC-98 | T6 | Duplicate | "Replaced by <T6> per AC hierarchy rule; extended (stored prompt set, vendor copy check)." | Done |
