# AC-2 description snapshot - Implementation Plan

## Task Details

| Field            | Value                   |
| ---------------- | ----------------------- |
| Jira ID          | None. Local follow-up on the published AC-2 description. Do not open or edit the Jira issue. |
| Title            | Label the AC-2 Jira appendix as the 2026-09-21 publish snapshot |
| Description      | Human gate 3 in `docs/specs/ac-2/ac-2.plan.md` already names the AC-26 session contract. The appendix “Jira AC-2 Description (shipped)” is the text published to Jira on 2026-09-21. Inside that fence, Phase 3, requirement 10, and the Phase 3 acceptance check still say two triggers (5–10 exchanges, or completed and tested) and that the agent ends the session. Label the appendix as that snapshot and state that AC-26 replaced its session behavior. Leave the fenced body as published. Do not publish the appendix again. |
| Priority         | Important |
| Related Research | `docs/specs/ac-2-description-snapshot/ac-2-description-snapshot.research.md` (approved — "Reasearch is ok. Make the plan") |

## Wildly Important Goal

**Goal**: A reader of `docs/specs/ac-2/ac-2.plan.md` can tell that the Jira appendix is the 2026-09-21 publish snapshot and that AC-26 replaced the session behavior inside it.

**Success Measure**: The appendix heading names the 2026-09-21 publish snapshot, a note above the fence states that AC-26 replaced the two-trigger end-the-session behavior and that this appendix must not be published again, and the fenced description still contains the published sentence `5–10 prompt/response exchanges`.

**Do NOT touch / do NOT add**:
- Any character inside the fenced description (from the opening ` ```markdown ` through the closing fence).
- Human gates, Suggestion S1, and the rest of `ac-2.plan.md` outside the appendix heading, the one intro sentence under that heading, and one new Changelog row.
- `.ai/` skills and rules, including rule 14 and `engineering-manager.md`.
- `website/docs/`, `code-quality-report.md`, `docs/specs/ac-27/ac-27.plan.md`.
- A Jira write (`editJiraIssue` or a comment). The AC-27 QA draft. A Layer A shape edit.
- `npm run sync:adapters` — no generated adapter input changes.

## Proposed Solution

Replace the appendix heading and the single sentence under it. Leave the fenced block byte-for-byte.

Current heading: `## Appendix — Jira AC-2 Description (shipped)`.

Current sentence under it: `Copy-ready replacement for field `description` only. Do not publish until the reporter says **publish to Jira**.`

That sentence still invites a later publish of the old contract. Replace the heading and that sentence with:

```text
## Appendix — Jira AC-2 Description (2026-09-21 publish snapshot)

This fenced block is the AC-2 description published on 2026-09-21. It is a historical snapshot. Session behavior inside it — two triggers (5–10 exchanges, or the task completed and tested while further tasks remain) and ending the session — was replaced by AC-26. The live contract is rule 14 in `.ai/skills/eversis-orchestrating-implementation/SKILL.md`: one completed-and-tested trigger while further tasks remain, the same turn writes `RESUMED:`, and the session continues through Review and Fine. Do not publish this appendix again.
```

The note must not contain the substring `5–10 prompt/response exchanges`. That substring stays only inside the fence, so a search for it proves the published Phase 3 row was not rewritten.

Add one Changelog row on `ac-2.plan.md`, dated 2026-09-23, stating that the appendix was labeled as the 2026-09-21 publish snapshot and that its session behavior was replaced by AC-26, with no Jira write.

```text
heading + snapshot note
        |
        v
+-------------------------------+
| fenced description (unchanged)|
| Phase 3, req 10, Phase 3 AC  |
| still say: end the session   |
+-------------------------------+
```

## Current Implementation Analysis

### Already Implemented

- AC-26 session contract — `.ai/skills/eversis-orchestrating-implementation/SKILL.md` rule 14 — one completed-and-tested trigger, same-turn `RESUMED:`, session continues
- Human gate 3 — `docs/specs/ac-2/ac-2.plan.md` — already records that contract; leave it
- Suggestion S1 — same file — already marked historical and closed by AC-26; leave it
- Published fence — same file, appendix — the 2026-09-21 description text, including `5–10 prompt/response exchanges`

### To Be Modified

- Appendix heading and the intro sentence under it — `docs/specs/ac-2/ac-2.plan.md` — rename to the 2026-09-21 publish snapshot and replace the “copy-ready / publish when told” sentence with the snapshot note
- Changelog — same file — one new row recording the label and that Jira was not written

### To Be Created

- None. This plan file is the planning artifact. The implementation does not add a file.

## Open Questions

| #   | Question   | Answer   | Status                |
| --- | ---------- | -------- | --------------------- |
| 1   | Should the fenced description be rewritten so Phase 3, requirement 10, and the acceptance check match AC-26? | No. The fence stays as published. The label sits outside it. | ✅ Resolved ("OK") |
| 2   | Should this task update the Jira description, paste the AC-27 QA draft, or edit the two Layer A files? | No. Those three stay out of this task. | ✅ Resolved ("Reasearch is ok. Make the plan") |

## Technical Context

Project conventions, coding standards, and patterns discovered during planning. Downstream agents MUST read this section instead of re-discovering the same context.

### Project Instructions

- `AGENTS.md` — framework repo; spec folder is `docs/specs/<issue-kebab>/`; `docs/specs/*/` except `docs/specs/README.md` is gitignored, so this edit stays local
- `.cursor/rules/eversis-project-stack.mdc` — no product app in this repo; do not load backend, frontend, filter, or BA Docs skills for this task
- `.ai/rules/orchestration/spec-driven-development.md` — research and plan gates before implementation; this plan is the implementation contract after approval

### Architecture & Patterns

- Session contract SSOT is rule 14 in `.ai/skills/eversis-orchestrating-implementation/SKILL.md`. Plans quote it; they do not restate a second contract inside a published snapshot.
- `docs/specs/ac-2/ac-2.plan.md` already separates current Human gates from historical review notes. This task uses the same pattern for the Jira appendix: current note outside, historical text inside the fence.
- Naming: one spec folder `docs/specs/ac-2-description-snapshot/` holds this research and this plan. The file being edited is the existing AC-2 plan, not a copy of the appendix.

### Tech Stack

- Markdown plans under `docs/specs/`. No application runtime.
- Package manager for the framework is npm, used by adapter sync and the docs site. This task does not change inputs to those commands.

### Code Style & Standards

- Plan changelog rows are a date plus one Change Description cell. Match the existing table in `ac-2.plan.md`.
- Quote the user’s gate-closing phrase literally. The research approval phrase is `Reasearch is ok. Make the plan`.
- Do not shorten existing documentation comments or historical review text.

### Testing Patterns

- No unit, integration, or e2e suite covers `docs/specs/ac-2/ac-2.plan.md`. It is gitignored local markdown.
- Verification is an inspect of that file. Commands, from the repo root:

```bash
rg -n "Appendix — Jira AC-2 Description \(2026-09-21 publish snapshot\)" docs/specs/ac-2/ac-2.plan.md
rg -n "Do not publish this appendix again" docs/specs/ac-2/ac-2.plan.md
rg -n "5–10 prompt/response exchanges" docs/specs/ac-2/ac-2.plan.md
rg -n "Copy-ready replacement for field" docs/specs/ac-2/ac-2.plan.md
```

- The first two commands must match. The third must match inside the fence and must not match the new snapshot note. The fourth must not match.
- Do not run `npm run sync:adapters`, `npm run mcp:test`, or `npm run website:build` for this edit.

### Database Patterns

- Not applicable. No database, migration, or schema.

### Additional Context

- `eversis_context_list` fails in this repo without `.agent-collections/install-selection.json`. Domain knowledge for this task is the one INDEX row `readiness-contract`, already aligned with AC-26. Do not edit it.
- `close-implement-gates` left `ac-2.plan.md` alone because Human gate 3 was already correct. This task still must not edit that gate.

## Implementation Plan

### Phase 1: Label the snapshot

**Goal**: The appendix heading and the sentence above the fence identify the 2026-09-21 publish and point session behavior at AC-26, which is the Wildly Important Goal.

**Description**: One edit in `docs/specs/ac-2/ac-2.plan.md`. The fenced description stays the historical publish. The old “copy-ready / publish when the reporter says publish” sentence is removed so the file no longer offers that publish.

**Verification:** Run the four `rg` commands in Technical Context → Testing Patterns.

#### Task 1.1 - [MODIFY] Label the Jira appendix

**Description**: Replace the appendix heading and the intro sentence with the snapshot heading and note from Proposed Solution. Append one Changelog row dated 2026-09-23. Do not change the fenced body.

**Files:** `docs/specs/ac-2/ac-2.plan.md` (modify)

**Definition of Done**:

- [x] The heading is `## Appendix — Jira AC-2 Description (2026-09-21 publish snapshot)`
- [x] The sentence directly under that heading contains `was replaced by AC-26` and `Do not publish this appendix again`
- [x] That sentence does not contain `5–10 prompt/response exchanges`
- [x] The fenced body still contains `5–10 prompt/response exchanges`
- [x] `Copy-ready replacement for field` is absent from the file
- [x] The Changelog has a 2026-09-23 row that records the snapshot label and that Jira was not written
- [x] Human gate 3 and Suggestion S1 are unchanged
- [x] Run the four `rg` commands in Technical Context → Testing Patterns

**Stop Rule:** Stop if the edit would change any line inside the fenced description, or if it would require a Jira call.

**Clues**: Heading and intro sentence are at `docs/specs/ac-2/ac-2.plan.md` around lines 597–599. The fence opens on the next line. Phase 3 of the table inside the fence is the carrier of `5–10 prompt/response exchanges`. Changelog table is under `## Changelog`, last row is the 2026-09-21 Phase 5 publish.

### Phase 2: Code Review

**Goal**: An independent review confirms the snapshot label is present and the published fence is intact, so the Wildly Important Goal is not met by rewriting history.

**Description**: Final verification of the one-file edit. This phase is mandatory and always comes last. There is no e2e suite for this gitignored plan file. The reviewer re-reads the heading, the note, and the fence.

**Verification:** Re-run the four `rg` commands in Technical Context → Testing Patterns.

#### Task 2.1 - [REUSE] Code review by Code Reviewer

**Description**: Run **Code Reviewer** via `eversis-review.md` on the appendix label only. Pass e2e execution to that agent. The applicable check is the four `rg` commands; there is no project e2e target for `docs/specs/ac-2/ac-2.plan.md`.

**Files:** `docs/specs/ac-2/ac-2.plan.md` (reuse)

**Definition of Done**:

- [x] Run the four `rg` commands in Technical Context → Testing Patterns
- [x] Code review passes with no blocking findings
- [x] Review outcome documented in this plan’s Changelog

**Stop Rule:** Stop if the review finds the fenced body was edited. Restore the fence from the pre-edit text before any other fix.

**Clues**: Scope is the appendix heading, the snapshot note, and one Changelog row. A BLOCKER is any change inside the fence, any Jira write, or a note that still says the appendix is the current shipped description.

## Security Considerations

- Do not call Jira or any other external publisher. The risk in this task is republishing a stale instruction, not a secret in the file.
- The appendix contains no credentials. Do not add any.

## Quality Assurance

Acceptance criteria checklist to verify the implementation meets the defined requirements:

- [x] GIVEN `docs/specs/ac-2/ac-2.plan.md` WHEN the appendix heading is read THEN it says `2026-09-21 publish snapshot`
- [x] GIVEN the sentence under that heading WHEN it is read THEN it states that the fenced session behavior was replaced by AC-26 and that the appendix must not be published again
- [x] GIVEN the fenced description WHEN it is searched THEN `5–10 prompt/response exchanges` is still present, and the snapshot note does not contain that substring
- [x] GIVEN the file WHEN it is searched THEN `Copy-ready replacement for field` is absent
- [x] GIVEN this task WHEN it finishes THEN Jira AC-2 was not updated

## Improvements (Out of Scope)

- A later, explicit “publish to Jira” that would replace the AC-2 description with the AC-26 session contract. Not this task.
- Pasting the AC-27 QA draft into `docs/specs/ac-27/ac-27.plan.md` if that draft is recovered from the Implement chat that wrote it.
- Editing the two Layer A files together on the next readiness-block shape change.
- Suggestion S4 from the AC-2 logical-gap review (`npm run sync:website-docs` and hand-authored site copy). Not this task.

## Human gates

1. ~~Approve research~~ — done (`Reasearch is ok. Make the plan`)
2. ~~Approve this plan~~ — done (`Ok, implement`)
3. ~~Implement → Review → Fine~~ — done (review PASS, Fine this turn)

## Code Review Findings

**Reviewer context:** Second full Code Reviewer pass (not a spot check) on Task 1.1 / Task 2.1 (`eversis-review` + `eversis-code-reviewing` + `eversis-implementation-gap-analysing`). No database / LLM prompt review. No Jira tools called. `docs/specs/ac-2/ac-2.plan.md` was not edited by this review. Only this snapshot plan was updated.

**Verdict: PASS — 0 BLOCKER, 0 open SUGGESTION that blocks DoD.**

### Prior B1 disposition (first pass)

First-pass **B1** (fence SHA-256 mismatch vs `2893bf1d…`) is an **oracle error**, not a fence edit. Digest `2893bf1d` was computed only through the first nested `` ``` `` fence, not through the outer `` ```markdown `` close. The approved plan’s Definition of Done does **not** require any SHA-256. This second pass does **not** re-open B1: the fenced body still carries the historical end-the-session sentences; AC-26 wording sits only in the snapshot note outside the fence (no `was replaced by AC-26` / `RESUMED:` / live-contract rewrite inside the fence).

### Re-checked (Task 1.1 DoD + QA + required checks — second full pass)

| Check | Result |
| ----- | ------ |
| Heading exactly `## Appendix — Jira AC-2 Description (2026-09-21 publish snapshot)` | PASS (L598) |
| Sentence under heading contains `was replaced by AC-26` and `Do not publish this appendix again` | PASS (L600) |
| That sentence does **not** contain substring `5–10 prompt/response exchanges` | PASS (note uses `5–10 exchanges` only; full substring absent) |
| Fenced body still contains `5–10 prompt/response exchanges` | PASS (L623 Phase 3 table row only; `rg` match exclusive to fence) |
| Fence rewritten / historical end-the-session sentences missing / AC-26 inserted inside fence | PASS — not rewritten (outer fence L602–L803; req 10 + Phase 3 AC intact; no AC-26 note text inside fence) |
| SHA-256 integrity vs `2893bf1d…` | **Not a DoD item** — prior B1 closed as oracle error (truncated span); not re-opened |
| `Copy-ready replacement for field` absent | PASS (`rg` exit 1) |
| Changelog 2026-09-23 row records snapshot label + Jira not written | PASS (L433) |
| Human gate 3 not turned back into a current new-chat / exchange-count instruction | PASS (L413 — AC-26 contract; no exchange-count; do not tell person to open a new chat) |
| Suggestion S1 not turned back into a current new-chat instruction | PASS (L568–574 — historical; closed by AC-26) |
| Requirement 10 inside fence still says end the session | PASS (L755 `end the session`) |
| Phase 3 acceptance inside fence still says ends the session | PASS (L802 `ends the session`) |
| Four `rg` commands (Testing Patterns) | PASS as specified (1–2 match; 3 matches fence only; 4 no match) |
| No Jira tool in this change / this review | PASS (reviewer did not call Jira) |

Every Task 1.1 Definition of Done checkbox and every Quality Assurance checkbox was re-verified from the file (checkmarks not trusted). All stated criteria are true. Task 2.1 DoD “no blocking findings” is checked on this PASS.

### BLOCKER

None.

### STRICT FORBIDDEN

- Scope: Task 1.1 touched only `docs/specs/ac-2/ac-2.plan.md`; this review edits only this snapshot plan. No `.ai/` edits. No new dependencies. No Jira calls.

## Changelog

| Date   | Change Description   |
| ------ | -------------------- |
| 2026-09-23 | Initial plan created |
| 2026-09-23 | CHECKPOINT: Task 1.1 labeled the appendix in `docs/specs/ac-2/ac-2.plan.md`. Digest `2893bf1d` was only the span through the first nested fence, and that span was unchanged; it is not the outer-fence digest. Four `rg` checks passed. Next: Task 2.1 code review. |
| 2026-09-23 | RESUMED: This session continues into code review and Fine. |
| 2026-09-23 | Code review (Task 2.1): verdict **not PASS — 1 BLOCKER, 1 SUGGESTION**. Full outer fence SHA-256 mismatch vs expected `2893bf1d…` (computed `e961565d…` with trailing NL). Four `rg` checks re-passed. Jira not called. |
| 2026-09-23 | Second full code review (Task 2.1): verdict **PASS — 0 BLOCKER**. Prior B1 closed as oracle error (digest `2893bf1d` was nested-fence span only; DoD requires no SHA-256). Fence not rewritten; Requirement 10 and Phase 3 AC still end the session. All Task 1.1 DoD + QA items re-verified true. Four `rg` checks re-passed. Jira not called. |
| 2026-09-23 | Fine. QA comment drafted in the session and copied below. Not posted to Jira. `tasks_since_audit` on `docs/context/agent-collections/INDEX.md` incremented from 11 to 12. |

## Draft QA comment — review before posting to Jira

**Draft QA comment — review before posting to Jira**

---

### 📝 QA Summary

**Task Context:** The saved copy of the AC-2 ticket description is now marked as a historical snapshot, so a later publish does not bring back the old “end the session” rule.

**Main Changes:**
- The appendix title now says it is the description published on 21 September 2026, not the current contract.
- A note above that old text says the session rule inside it was replaced by AC-26 (the chat continues after a checkpoint) and that this appendix must not be published again.
- The old description text itself is unchanged, including the sentences that tell an agent to end the session.
- The AC-2 ticket in Jira was not updated.

---

**✅ Verification List:**

**Manual Testing:**
- [ ] Open the AC-2 plan appendix and confirm the title says “2026-09-21 publish snapshot”.
- [ ] Confirm the note above the old text says the session behavior was replaced by AC-26 and must not be published again.
- [ ] Confirm the old text still says the agent ends the session on a 5–10 exchange count or when a task is finished and tested.
- [ ] Confirm the AC-2 Jira description was not edited in this task.

**Automation & Technical Notes:**
- **Selectors**: none (no UI)
- **API**: none
- **Error Handling**: none; Jira was not called

