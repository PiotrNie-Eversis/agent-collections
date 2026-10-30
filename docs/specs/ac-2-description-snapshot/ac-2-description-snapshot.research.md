# AC-2 description snapshot — Analysis Result

## Task Details

| Field | Value |
|---|---|
| Jira ID | None. This is a local follow-up on the already-published AC-2 description. Do not open or edit the Jira issue in this task. |
| Title | Label the AC-2 Jira appendix as the 2026-09-21 publish snapshot |
| Description | The second code-quality pass (2026-09-23) found one important leftover. Human gates in `docs/specs/ac-2/ac-2.plan.md` already name the AC-26 session contract. The appendix “Jira AC-2 Description (shipped)” is the text that was published as the AC-2 description on 2026-09-21. That block still says Phase 3 has two triggers (5–10 exchanges, or completed and tested) and that the agent ends the session. Requirement 10 and the Phase 3 acceptance check repeat that. The live skill does not. Label the appendix as that publish snapshot, and state that its session behavior was replaced by AC-26. Do not publish the appendix again. |
| Priority | Important — republishing the appendix would put the hard stop back into the Jira description |
| Reporter | Piotr (this chat), from `code-quality-report.md` (2026-09-23 re-review) |
| Created Date | 2026-09-23 |
| Due Date | — |
| Labels | continuity, ac-2, jira-description |
| Estimated Effort | One local plan-file edit. No `.ai/` change, no adapter sync, no Jira write. |

## Business Impact

AC-2’s Jira description is what a later agent reads when it opens the ticket. The live rule already continues the session after a checkpoint. The published description still tells the agent to stop on an exchange count. Leaving the appendix unlabeled makes that old text look like the current contract, because the heading still says “shipped”. A label that names the 2026-09-21 snapshot, and names AC-26 as the replacement for session behavior, keeps the historical publish record and stops a later “publish to Jira” from restoring the hard stop.

## Gathered Information

### Knowledge Base & Task Management Tools

The request is `/eversis-implement` with `code-quality-report.md` attached. Jira was not opened. The report’s short-term action is the whole of this task. Its critical section is empty. Its long-term items are out of scope here (see Gap Analysis).

`close-implement-gates` was told not to edit `ac-2.plan.md`, because the Human gates section was already correct. This task does not reopen those gates. It only labels the appendix that ticket left untouched.

AC-2 description was published on 2026-09-21 (`editJiraIssue` on the description field only; status stayed In Progress). That publish is recorded in the plan changelog. This task does not call Jira.

### Codebase

Live session contract, already in `.ai/skills/eversis-orchestrating-implementation/SKILL.md` rule 14 (“Checkpoint handoff note (session continues)”): one trigger — the current plan task is completed and tested, further tasks remain, and the session is not already in Review or Fine. That turn writes `CHECKPOINT:` and then `RESUMED:`, and the session continues through Review and Fine unless the person asks to stop. There is no exchange-count trigger. The agent does not tell the person to open a new session and does not end the turn. Rule 13 still sends the plan’s last task straight to Fine. `Resume` is an optional readiness line, not a `Flow` value.

`docs/specs/ac-2/ac-2.plan.md` Human gate 3 (around line 413) already records that AC-26 contract. Suggestion S1 in the same file is marked historical and closed by AC-26.

The appendix starts at the heading “Appendix — Jira AC-2 Description (shipped)” (around line 597). The fenced block is the copy-ready description. Three places inside that fence still describe the pre-AC-26 session stop:

- Phase 3 row of the phased-scope table (around line 622): two triggers, write `CHECKPOINT:` and end the session.
- Requirement 10 (around line 754): the same two triggers and “end the session”.
- Phase 3 acceptance check (around line 801): the same two triggers and “ends the session”.

The AS-IS vs TO-BE row for thread size (around line 725) says the same thing. It is part of the published snapshot, not a fourth instruction to rewrite.

`docs/specs/*/` is gitignored in this repository. The edit stays local.

`eversis_context_list` failed (`install-selection.json` not found under `/app`). `docs/context/agent-collections/INDEX.md` has one component (`readiness-contract`). Frontmatter: `tasks_since_audit: 11`, `audit_due_after: 5`, no `last_audit`. This task does not run the audit and does not change the counter.

No `CHECKPOINT:` row exists for this new spec folder. This session is not a resume.

### Relevant Links

- `code-quality-report.md` — 2026-09-23 re-review; short-term item 1 is this task
- `docs/specs/ac-2/ac-2.plan.md` — Human gate 3 (current) versus the Jira appendix (2026-09-21 snapshot)
- `.ai/skills/eversis-orchestrating-implementation/SKILL.md` — rule 14, the live session contract
- `docs/specs/close-implement-gates/close-implement-gates.research.md` — prior decision to leave `ac-2.plan.md` alone because Human gates were already correct

### Relevant Charts & Diagrams

```text
Human gate 3 (ac-2.plan.md)     → AC-26: one trigger, same-turn RESUMED, session continues
Live skill rule 14              → same contract
Jira appendix (fenced block)    → 2026-09-21 publish: 5–10 exchanges OR done+tested, end the session
This task                       → label that fence as the snapshot; do not republish; do not rewrite the fence
```

## Current Implementation Status

### Existing Components

- AC-2 plan Human gates — `docs/specs/ac-2/ac-2.plan.md` — can be reused; already state the AC-26 contract; do not edit
- Jira description appendix — `docs/specs/ac-2/ac-2.plan.md` — needs a snapshot label; fenced body stays as published
- Rule 14 — `.ai/skills/eversis-orchestrating-implementation/SKILL.md` — can be reused; already the live contract; do not edit
- Engineering-manager readiness block — `.ai/rules/orchestration/engineering-manager.md` — can be reused; aligned with the skill; do not edit in this task

### Key Files and Directories

- `docs/specs/ac-2/ac-2.plan.md` — the only file this task changes, and only by a label on the appendix
- `code-quality-report.md` — source of the finding; not edited
- `docs/specs/ac-27/ac-27.plan.md` — mentioned by the report’s long-term item; not this task
- `.ai/skills/eversis-orchestrating-implementation/SKILL.md` — cited as the replacement contract; not edited

## Gap Analysis

### Question 1

#### Should the fenced description be rewritten so Phase 3, requirement 10, and the acceptance check match AC-26?

No. The fence is the text that was published on 2026-09-21. Rewriting it would destroy the snapshot and make the appendix look current again. The label sits outside the fence: this block is the 2026-09-21 publish snapshot, and its session behavior (5–10 exchanges, end the session) was replaced by AC-26. The sentences inside the fence stay as published.

Answered 2026-09-23: "OK".

### Question 2

#### Should this task update the Jira description, paste the AC-27 QA draft, or edit the two Layer A files?

No. The report says not to publish the appendix again. A Jira field update would be a separate “publish to Jira”, and this task must not perform it. The AC-27 draft is pasted only when that draft is still in the Implement chat that produced it; this chat does not contain it. The Layer A pair stays as it is until the next readiness-block shape change, which this task is not.

Covered by research approval 2026-09-23: "Reasearch is ok. Make the plan".

## Human gates

1. ~~Approve research~~ — done (`Reasearch is ok. Make the plan`)
2. ~~Approve plan (once written)~~ — done (`Ok, implement`)
3. ~~Implement → Review → Fine~~ — done (review PASS, Fine this turn)
