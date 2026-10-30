# ac-92-optimize-claude-md — Quality Review Report

## Review Context

| Field | Value |
|---|---|
| Review Date | 2026-10-30 |
| Source Task List | `extracted-tasks.md` (Gate 1 approved 2026-10-30) |
| Additional Sources | `intent-brief.md`; Jira project AC (open backlog, AC-92 + AC-93–AC-98); repo: `scripts/lib/setup-agent-collections/scaffolding.sh`, `package.json`, `mcp/eversis-collections-mcp/package.json`, `.gitignore` |
| Review Mode | Lite (1 epic, 1 story, 10 tasks) |
| Passes Run | A, B, E, H, I |
| Epics Reviewed | 1 |
| Stories Reviewed | 1 Story + 10 Tasks (AC-93, AC-95, AC-96, AC-97 unchanged except re-type; no findings) |
| Total Suggestions | 6 |
| Accepted | 6 |
| Rejected | 0 |

---

## Domain Model

### Actors

| Actor | Epics Involved | Key Capabilities |
|---|---|---|
| Claude Code user (framework / consumer) | 1 | Starts sessions on the generated `CLAUDE.md` |
| Framework maintainer | 1 | Edits rules and generator, runs prompt set, runs upkeep routine, reviews friction notes |
| Consumer project team | 1 | Owns its `AGENTS.md` and `.claude/CLAUDE.md`; installs via `--vendor` |
| Agent | 1 | Follows instructions; emits friction note at Fine |
| Blog reader | 1 | Reads the write-up |

### Entities

| Entity | Created In | Read In | Updated In | Deactivated/Deleted In |
|---|---|---|---|---|
| Generated `CLAUDE.md` | AC-93/AC-94 | every session | AC-94, later edits | — |
| Rule reasons file | AC-94 (S-01) | Task A, later edits | AC-94 (new rule + reason) | AC-94 (rule removed → reason removed) |
| Regression prompt set | AC-98 | AC-98 re-runs, Task A | AC-98 (add on failure; S-02 deliberate update) | AC-98 (S-03) |
| Upkeep review log | Task A (S-06) | Task A | Task A | — (append-only) |
| Friction note | Task B | human at Fine | — (draft) | — (not stored) |
| `AGENTS.md` / template / standard | existing | every session (consumer import) | Task C | — |
| Blog post | Task D | blog readers | — | — |

### Key Relationships

- Rule reasons file ↔ `CLAUDE.md` rules ↔ prompt set: one rule, one reason, its prompts — added and removed together (S-01, S-03).
- Consumer `AGENTS.md` depends on the template but is never overwritten — consumers learn of changes only via CHANGELOG (S-04).
- Task C single-test command depends on AC-97 adding the root test script (S-05).

---

## Suggestions

### Epic 1: Agent instruction files: lean and accurate

#### S-01 · High · MODIFY_STORY

**Target**: Task 1.1.2 (AC-94) — lifecycle, gates and hard limits stated once

**Finding** (Pass A: Entity Lifecycle Completeness):
Rule reasons were to live in the research artifact under `docs/specs/`, which is gitignored on `master`; reasons would be lost for later edits and the Task A review.

**Proposed Change**:
Requirement 6 and AC: reasons live in a committed file outside `docs/specs/`, next to the Claude generator configuration; not inside `CLAUDE.md`; new always-on rules are added together with their reason.

**Decision**: ✅ Accepted

---

#### S-02 · High · ADD_ACCEPTANCE_CRITERION

**Target**: Task 1.1.6 (AC-98) — Claude Code still follows the gates

**Finding** (Pass H: Error State and Edge Case Coverage):
No rule for what happens when an observed result differs from the expected one.

**Proposed Change**:
- [ ] GIVEN a prompt in the set WHEN its observed result differs from the expected result THEN the change is not pushed until the instruction is fixed, or the expected result is updated on purpose with a one-line reason recorded next to it

**Decision**: ✅ Accepted

---

#### S-03 · Medium · ADD_ACCEPTANCE_CRITERION

**Target**: Task 1.1.6 (AC-98)

**Finding** (Pass A: Entity Lifecycle Completeness):
The prompt set had an "add" rule but no "remove" rule; prompts for deliberately removed rules would fail falsely or block the removal.

**Proposed Change**:
- [ ] GIVEN an always-on rule is removed on purpose WHEN the change is prepared THEN the prompts that only checked that rule are removed from the set, or their expected result is updated, in the same change

**Decision**: ✅ Accepted

---

#### S-04 · High · ADD_ACCEPTANCE_CRITERION

**Target**: Task 1.4 (C) — AGENTS.md reads as an operating manual

**Finding** (Pass I: Notification and Communication Gaps):
The installer never overwrites an existing project `AGENTS.md`, so consumers do not receive template changes unless told; consumer `.claude/CLAUDE.md` imports `@../AGENTS.md`, so its length counts toward startup context.

**Proposed Change**:
- [ ] GIVEN the template changes ship WHEN a consumer reads `CHANGELOG.md` THEN an entry lists what changed in `templates/AGENTS.template.md`, says that an existing project `AGENTS.md` is not overwritten, and tells the team how to adopt the changes by hand

Plus technical note on the consumer import.

**Decision**: ✅ Accepted

---

#### S-05 · Medium · ADD_TECHNICAL_NOTE

**Target**: Task 1.4 (C)

**Finding** (Pass B: Cross-Feature State Validation):
Task C asks for a single-test command, but the root `package.json` has no test script until AC-97; MCP tests run a fixed file list.

**Proposed Change**:
Technical note: single-test commands per suite (MCP, AC-97 generator test, installer smoke test), verified in this repo; test-command section finalized after AC-97. Dependency: Task C Related to AC-97.

**Decision**: ✅ Accepted

---

#### S-06 · Medium · ADD_ACCEPTANCE_CRITERION

**Target**: Task 1.2 (A) — maintainer re-checks instruction files after each upgrade

**Finding** (Pass A: Entity Lifecycle Completeness):
The dated review entry had no defined, durable location.

**Proposed Change** (option b chosen over CHANGELOG):
- [ ] GIVEN the routine is done WHEN the maintainer records it THEN a dated entry is added to a committed review log next to the rule-reasons file (AC-94), listing what was removed or changed, or "no change"

**Decision**: ✅ Accepted (option b)

---

## Applied Changes Summary

| # | Suggestion | Action | Target |
|---|---|---|---|
| S-01 | Rule reasons in a committed file next to the generator | MODIFY_STORY | AC-94 |
| S-02 | Failed prompt blocks push unless expected result updated with reason | ADD_ACCEPTANCE_CRITERION | AC-98 |
| S-03 | Remove or update prompts when a rule is removed | ADD_ACCEPTANCE_CRITERION | AC-98 |
| S-04 | CHANGELOG tells consumers about template changes | ADD_ACCEPTANCE_CRITERION + note | Task C |
| S-05 | Per-suite single-test commands; relate to AC-97 | ADD_TECHNICAL_NOTE + dependency | Task C |
| S-06 | Review log next to the reasons file | ADD_ACCEPTANCE_CRITERION | Task A |

**Updated Totals**: 1 epic (new), 1 story (AC-92, re-typed), 10 tasks (6 existing incl. 2 extended, 4 new); no items added by the review.

## Rejected Suggestions

None.
