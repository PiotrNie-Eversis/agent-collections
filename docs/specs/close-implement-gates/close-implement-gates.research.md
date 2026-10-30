# Close Implement gates — Analysis Result

## Task Details

| Field | Value |
|---|---|
| Jira ID | None for this cleanup. It records close-out on AC-16, AC-17, AC-22, AC-23, and AC-25, then corrects documents that still describe the pre-AC-26 session stop. |
| Title | Close five Implement gates and align the leftover session-policy sentences |
| Description | Five child plans already have review PASS, and their checkpoints are consumed by a later `RESUMED:` row. Human gate 3 still reads as if Implement has not started (AC-23’s gate line is already struck, but the QA draft is not in the plan). A new `/eversis-implement` on those tickets would not emit `Resume` and could redo finished work. After the gates are closed, three documents (plus the rule 14 heading and the `readiness-contract` note, in the same change) must match the live AC-26 contract: a checkpoint does not end the chat. Separately, add `source: manual` to the audit skill’s empty-`code_paths` exception before anyone runs `eversis-audit-domain-knowledge`. Mark the stale AC-20 plan review and the missing `*.plan-review.md` files as history. Do not open a new Implement on the five tickets. Do not post QA comments to Jira until the person says to publish. |
| Priority | High — an open gate 3 plus a consumed checkpoint disagree, and an audit run today can Delete a hand-entered fact |
| Reporter | Piotr (this chat) |
| Created Date | 2026-09-23 |
| Due Date | — |
| Labels | continuity, human-gates, domain-knowledge |
| Estimated Effort | Documentation and plan-record edits only. No product behavior change beyond the audit exception and the rule 14 heading. |

## Business Impact

A later Implement session trusts Human gate 3. While that gate is open, the session treats a finished ticket as not started. Because `RESUMED:` already consumed `CHECKPOINT:`, that session also gets no `Resume` line, so it has no instruction to continue from the finished task. Closing the gate with the existing QA draft removes that false start.

The skill already matches Continuity: the same turn writes `RESUMED:` and the session continues. Plans and the public page that still say “open a new chat” or “remain undecided” will put the hard stop back if an agent treats them as the live contract.

The project index counter is already past its threshold (`tasks_since_audit: 8`, `audit_due_after: 5`). The audit skill’s Delete path treats an empty `code_paths` as “the code is gone”, except for `source: confluence` and `source: docs-specs-cluster`. A hand-entered fact (`source: manual`, `code_paths: []`) is outside that exception. The exception has to include `manual` before that audit runs.

## Gathered Information

### Knowledge Base & Task Management Tools

The request was given in this chat. It points at `code-quality-report.md` (2026-09-23) and at the local plans under `docs/specs/`. Jira was not opened. The person said not to publish, and not to start a new Implement on AC-16, AC-17, AC-22, AC-23, or AC-25. Local plans and prior chats are the record of what already shipped.

QA drafts already exist in prior chats. None of the five plans contain that draft text.

| Ticket | Chat | Gate 3 on disk now | Changelog after review |
|---|---|---|---|
| AC-16 | `1fc78672-fa67-42ae-948f-61f42334bfa8` | Open. Research and plan gates struck (`"Research is ok. Make the plan for AC-16"`, `"Plan is ok. Implement"`). | Review PASS 2026-09-22. No `CHECKPOINT:`. |
| AC-17 | `d3429214-7101-4f29-ac1f-bce0bc1f7bfb` | Open. Text: “human will start this in a new window”. | `CHECKPOINT:` then `RESUMED:` (2026-09-22), then review PASS. |
| AC-22 | `0fdf119d-d2ee-4a2d-8c5d-db2ff33695ed` | Open. Text: “w nowym oknie. Ten czat nie implementuje.” | Several `CHECKPOINT:` / `RESUMED:` pairs, then review PASS on the second pass. |
| AC-23 | `d547786a-a973-4514-bbf9-15e049fc9ef6` | Already struck: “done (review PASS, Fine this session)”. The QA draft is not in the plan. | Two `CHECKPOINT:` / `RESUMED:` pairs, then review PASS. Latest checkpoint is consumed. |
| AC-25 | `a064e39f-8856-4287-803f-a84e5f7f63a8` | Open. Research and plan gates struck. | Newest changelog row is review PASS. No `CHECKPOINT:`. |

AC-18, AC-19, AC-20, AC-24, and AC-26 already struck their implement gates. This task does not reopen them.

`docs/specs/*/` is gitignored in this repository. Edits to those plans stay local.

### Codebase

Live session contract (AC-26), already in `.ai/skills/eversis-orchestrating-implementation/SKILL.md` rule 14: one trigger (the current plan task is completed and tested, further tasks remain, and the session is not already in Review or Fine). That turn writes `CHECKPOINT:` and then `RESUMED:`, and the session continues. The agent does not tell the person to open a new session and does not end the turn. Rule 13 still sends the last task straight to Fine. Step 1 emits `Resume` only for an unconsumed checkpoint. A later `RESUMED:` consumes it. On the five tickets above, every checkpoint is consumed, so this session correctly omits `Resume`.

Re-read on 2026-09-23 after the first research draft. Four of the session-policy edits are already on disk:

- `docs/specs/ac-2/ac-2.plan.md` Human gate 3 no longer says “remain undecided”. It records the AC-26 contract: one completed-and-tested trigger while further tasks remain, same-turn `RESUMED:`, the session continues through Review and Fine, rule 13 on the last task, no exchange-count trigger, and no instruction to open a new chat. Suggestion S1 is marked historical and says not to restore a new-chat sentence into the skill.
- `docs/specs/ac-19/ac-19.plan.md` Human gates already include the superseded note: the sentence „Otwórz nową sesję Implement, wskaż ten plan i nie wznawiaj bieżącego czatu.” was removed from rule 14, and it must not be put back. Success Measure, Proposed Solution, and the checked DoD lines still quote that sentence as the historical record of what AC-19 shipped. That history stays. The skill is not edited to restore it.
- `website/docs/reference/domain-context.md` checkpoint blurb (AC-19 / AC-26) already matches the Implement diagram under it: the same turn writes `RESUMED` and this session continues, unless the person asks to stop. The row does not update the project index.
- Rule 14’s heading in `.ai/skills/eversis-orchestrating-implementation/SKILL.md` is already “Checkpoint handoff note (session continues)”. The old heading “Zero-compaction session budget” is gone. The paragraph still opens with the trigger, then says not to end the turn.

What point 2 still changes: `docs/context/agent-collections/readiness-contract/index.md`. It is still accurate that the block’s shape lives in two Layer A files and that `Resume` is not a value of `Flow`. It does not yet say that an AC-26 checkpoint does not end the session and that the same turn writes `RESUMED`. That sentence is added with the rest of point 2, which on current disk means this note is the remaining edit. Layer A/B and the two-column index rule stay.

Audit exception (`.ai/skills/eversis-audit-domain-knowledge/SKILL.md`): empty or absent `code_paths` on `source: confluence` or `source: docs-specs-cluster` means “not mapped to code yet” — signal `Update`, never `Delete`. The exception explicitly does not apply to `source: agent-discovered`. It does not mention `source: manual`. `eversis-add-domain-knowledge` writes `source: manual` and `code_paths: []` when the fact names no paths.

Index frontmatter (`docs/context/agent-collections/INDEX.md`): one component (`readiness-contract`), `tasks_since_audit: 8`, `audit_due_after: 5`, no `last_audit`. The readiness `Audit` line for that shape is `never` (no `last_audit` date). The stored counter is still past the threshold, so running the audit skill now is the moment the `manual` exception has to already be in place. This task does not run that audit.

Plan-review history:

- `docs/specs/ac-20/ac-20.plan-review.md` verdict is still `REVISIONS NEEDED`. The domain-context page it asked for is already shipped, and AC-20’s implement gate is struck. Do not re-implement the page.
- No `*.plan-review.md` for AC-16, AC-17, AC-18, AC-22, AC-23, or AC-24. Those plans were accepted by a human “Plan is ok” (or the equivalent quoted phrase). AC-19, AC-25, and AC-26 have `APPROVED` plan reviews. AC-2 has its own review files and is not in the “missing file” set.

`eversis_context_list` failed (`install-selection.json` not found under `/app`). The component count used here is the one row in `docs/context/agent-collections/INDEX.md`.

### Relevant Links

- `code-quality-report.md` — the 2026-09-23 review this request closes the critical and short-term items of
- `docs/specs/ac-26/ac-26.plan.md` — live contract: same-turn `RESUMED:`, session continues
- `.ai/skills/eversis-orchestrating-implementation/SKILL.md` — rule 14 and the checkpoint scan
- `.ai/skills/eversis-fine-handoff/SKILL.md` — QA draft shape; publication stays behind a later human OK
- `website/docs/reference/domain-context.md` — checkpoint blurb versus Implement diagram

### Relevant Charts & Diagrams

The Implement diagram on `website/docs/reference/domain-context.md` is the picture the checkpoint blurb must match: when further tasks remain, the same turn writes a `CHECKPOINT` row and then `RESUMED`, and this session continues. No index write.

## Current Implementation Status

### Existing Components

- Orchestration skill rule 14 — `.ai/skills/eversis-orchestrating-implementation/SKILL.md` — heading already renamed; body already continues the session
- Engineering-manager rule — `.ai/rules/orchestration/engineering-manager.md` — can be reused; already says the session that writes `CHECKPOINT:` also writes `RESUMED:` and continues
- Five child plans — `docs/specs/ac-16|17|22|23|25/*.plan.md` — needs extension (paste the existing QA draft, strike gate 3 where it is still open)
- Parent plan gate and S1 — `docs/specs/ac-2/ac-2.plan.md` — already records the AC-26 contract; no further session-policy edit
- AC-19 plan — `docs/specs/ac-19/ac-19.plan.md` — superseded note already present; historical operator sentence stays in the plan body
- Public checkpoint blurb — `website/docs/reference/domain-context.md` — already matches the Implement diagram
- Readiness-contract note — `docs/context/agent-collections/readiness-contract/index.md` — needs the AC-26 sentence; Layer A/B and “`Resume` is not a `Flow` value” stay
- Audit skill — `.ai/skills/eversis-audit-domain-knowledge/SKILL.md` — needs extension (`source: manual` joins the empty-`code_paths` exception)
- AC-20 plan review and plans with no review file — historical annotation only

### Key Files and Directories

- `docs/specs/ac-16/ac-16.plan.md` — open gate 3, review PASS, chat QA draft not pasted
- `docs/specs/ac-17/ac-17.plan.md` — open gate 3 still says a new window
- `docs/specs/ac-22/ac-22.plan.md` — open gate 3 still says this chat does not implement
- `docs/specs/ac-23/ac-23.plan.md` — gate 3 already struck; QA draft still only in chat
- `docs/specs/ac-25/ac-25.plan.md` — open gate 3, review PASS, no checkpoint
- `docs/specs/ac-2/ac-2.plan.md` — gate 3 and S1 already state AC-26; suggestion S2 still describes the old “last changelog row” scan as a live bug
- `docs/specs/ac-19/ac-19.plan.md` — superseded note under Human gates; Polish operator sentence kept above as history
- `docs/specs/ac-20/ac-20.plan-review.md` — `REVISIONS NEEDED` after the page shipped
- `website/docs/reference/domain-context.md` — checkpoint blurb already matches the diagram
- `.ai/skills/eversis-orchestrating-implementation/SKILL.md` — rule 14 heading already “Checkpoint handoff note (session continues)”
- `.ai/skills/eversis-audit-domain-knowledge/SKILL.md` — Delete exception
- `docs/context/agent-collections/readiness-contract/index.md` — Layer A/B note, no AC-26 yet
- `docs/context/agent-collections/INDEX.md` — counter 8, threshold 5, no `last_audit`

## Gap Analysis

All missing information and gaps in the task description, together with provided answers.

### Question 1

#### Should a new Implement run on AC-16, AC-17, AC-22, AC-23, or AC-25?

No. Confirmed 2026-09-23 (`Question 1. OK`). Review already passed. Paste the chat QA draft into each plan and strike gate 3 where it is still open. AC-23’s gate line is already struck; still paste the chat draft into that plan. Do not add another `CHECKPOINT:`. Do not publish any of those comments to Jira until the person explicitly says to publish.

### Question 2

#### Which sentences are in scope for the session-policy fix, and when does `readiness-contract` change?

Accepted with the research (`Research is ok`, 2026-09-23). Explained earlier the same day (`Question 2: Wyjaśnij dokładnie`).

Point 2 does not rewrite the skill’s session behavior. The skill already continues the session. The edits are records around that skill, and only where the record is still the old policy.

Already on disk, so this task does not edit them again:

- `docs/specs/ac-2/ac-2.plan.md` gate 3 and suggestion S1 already state the AC-26 contract and forbid putting a new-chat sentence back into the skill.
- `docs/specs/ac-19/ac-19.plan.md` already has the superseded note under Human gates. The Polish sentence stays in Success Measure and Proposed Solution as the history of what AC-19 shipped. The skill does not get that sentence back.
- `website/docs/reference/domain-context.md` checkpoint blurb already says the same thing as the Implement diagram: the same turn writes `RESUMED` and this session continues. The row does not update the project index.
- Rule 14’s heading is already “Checkpoint handoff note (session continues)”.

Still to write, in the same change as the five gate close-outs (not before them, and not as a separate earlier edit): one AC-26 sentence in `docs/context/agent-collections/readiness-contract/index.md`. Keep the Layer A/B split. Keep “`Resume` is not a `Flow` value”. Keep the two-column index rule. Add that a checkpoint does not end the session and that the same turn writes `RESUMED`.

### Question 3

#### Should this task run `eversis-audit-domain-knowledge`?

No. Confirmed 2026-09-23 (`Question 3: No`). Before anyone runs it, add `source: manual` to the empty-`code_paths` exception (signal `Update`, never `Delete`), alongside `confluence` and `docs-specs-cluster`. Leave the existing exclusion of `source: agent-discovered` as it is. This task does not start the audit.

### Question 4

#### What happens to the AC-20 `REVISIONS NEEDED` review and the missing plan-review files?

Mark them as history only. Confirmed 2026-09-23 (`Question 4: OK`). Do not open implementation to satisfy the old AC-20 review, and do not treat a missing `*.plan-review.md` as “plan review still required.” The missing files are AC-16, AC-17, AC-18, AC-22, AC-23, and AC-24. Do not change the AC-20 verdict from `REVISIONS NEEDED` to `APPROVED`.

### Question 5

#### What is left for a later, smaller ticket?

Accepted with the research (`Research is ok`, 2026-09-23). Explained earlier the same day (`Question 5: Wyjaśnij dokładniel`).

The later ticket is only the two long-term notes in `code-quality-report.md`, plus one stale suggestion that this request did not name:

1. Crash check. If a session dies after the `CHECKPOINT:` row and before the `RESUMED:` row, a new window should emit `Resume` and continue that task instead of starting it over. That path is the only reason the scan exists. This task does not kill a session to prove it.
2. Future-edit habit. When the readiness block changes again, edit both Layer A files (the skill and `engineering-manager.md`) in one task and run `npm run sync:adapters:check`. They match today. This task does not merge them into one file.
3. `docs/specs/ac-2/ac-2.plan.md` suggestion S2 still says a fresh Implement looks only at the latest changelog row and will restart. The live scan already walks backward to the latest unconsumed `CHECKPOINT:`. Rewriting S2 is history cleanup, not part of point 2.

Not in that later ticket, and not in this one: posting the five QA drafts to Jira, and running `eversis-audit-domain-knowledge`. Both wait for a separate explicit request. The quality report’s green notes (Resume stays unused when the turn finishes; the block is defined twice on purpose) are not defects to fix.

## Human gates

1. ~~Approve research~~ — done (`Research is ok`)
2. Approve plan (once written)
3. Implement → Review → Fine
