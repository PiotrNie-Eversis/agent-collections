# Plan Review: cursor-only-mislabel.plan.md

**Reviewed plan:** `docs/specs/cursor-only-mislabel/cursor-only-mislabel.plan.md`
**Research file:** `docs/specs/cursor-only-mislabel/cursor-only-mislabel.research.md`
**Review date:** 2026-08-20 (iteration 2)
**Verdict:** `APPROVED`

**Summary:** 0 blockers · 2 warnings · 2 suggestions

Iteration 1 returned REVISIONS NEEDED (1 blocker, 2 warnings, 2 suggestions). All four items were addressed in the revised plan and are independently re-verified below against current file content: **B1** (stale line numbers) is fixed and confirmed correct; **W1** (undiscovered `website/docs/skills/` instance) was resolved by explicit human fold-in decision, added as Task 1.3, and its citation/quoted text is confirmed accurate; **W2** (narrow Stop Rule) is fixed; **S1** (scope-caveat wording) is fixed. This full re-review (not a diff spot-check) found no new blockers. It did find two new, non-blocking WARNINGS: the plan's top-of-document Task Details (Title/Description) and the Phase 2 header (Goal/Description/Verification/Stop Rule/Clues) were not updated when Task 1.3 was folded in, so they still describe a "2 files / 6 lines" scope even though every task-level section (1.1, 1.2, 1.3, 2.1) correctly reflects 3 files / 7 lines. Since the authoritative, actually-executed instructions (Task 1.1–1.3 bodies, Task 1.1–1.3 Definitions of Done, Task 2.1 Files/DoD) are all internally consistent and verified accurate against the current repo state, these are documentation-consistency cleanup items, not execution blockers.

## Challenge Domains

| Domain | Result |
| ------ | ------ |
| Technology and stack decisions | No issue — plain Markdown text edit, no stack, tooling, or dependency choice involved. |
| Irreversible or high-cost decisions | No issue — trivially revertible, git-tracked text change; no migration, deployment, or data impact. |
| Contradictions with research or prior context | No issue for the locked Q1/Q2 decisions the plan implements faithfully. Note: `cursor-only-mislabel.research.md` was not updated to record the Task 1.3 scope expansion (that decision was made via plan-review iteration 1 + human fold-in, not via a research Changelog entry) — a minor provenance gap, not a contradiction (see W-carryover note below; not re-raised as a fresh finding since it does not affect what gets edited). |
| Scope gaps and silent omissions | **Resolved from iteration 1.** `website/docs/skills/technical-context-discovery.md:28` is now in scope as Task 1.3. **New, smaller-scope issue found** — see W3/W4: two document sections (Task Details, Phase 2 header) were not updated to reflect the 3-file scope. |
| Cross-cutting decisions that propagate | No issue — the three edited files are independent, with no shared cross-reference; repo-wide verbatim sweep (this iteration) confirms no other **live** framework file quotes either target parenthetical verbatim — all other `cursor-only`/`(Cursor)` hits are in historical `docs/specs/*` narrative for unrelated tickets, not files this fix must touch. |
| Build vs buy vs reuse | Not applicable — no component being built, bought, or reused; text edit only. |

## Decision and Revision History

| Date | Iteration | Decision / Topic | Problem / Challenge | Plan Decision / Change | Status |
| ---- | --------- | ---------------- | ------------------- | ---------------------- | ------ |
| 2026-08-20 | 1 | Plan review (iteration 1) | Stale line-number citations for File 1 (B1); undiscovered same-bug-class instance in `website/docs/skills/` (W1); narrow Stop Rule (W2); over-broad completeness wording (S1) | Flagged for Architect correction before execution; verdict REVISIONS NEEDED | Resolved |
| 2026-08-20 | 2 | B1 re-verification | Plan cited lines 250/264; actual heading/bullet at 253/267 | Plan corrected to 253/267; re-verified against current file (270 lines, clean tree) — exact match | Resolved |
| 2026-08-20 | 2 | W1 re-verification | Same-bug-class instance outside `.ai/` scope, undecided | Human chose fold-in; Task 1.3 added for `website/docs/skills/technical-context-discovery.md:28`; re-verified quoted text, surrounding lines 8/30-34, and single-commit (`71c6dae`) manual-authorship claim — all accurate | Resolved |
| 2026-08-20 | 2 | W2 re-verification | Task 1.1 Stop Rule verbatim-only, would miss paraphrased drift | Stop Rule reworded to cover "same bug class... worded differently or not" | Resolved |
| 2026-08-20 | 2 | S1 re-verification | Additional Context claim read as over-broad completeness guarantee | Scope caveat sentence added, pointing to the verbatim/`.ai/`-only limitation | Resolved |
| 2026-08-20 | 2 | New finding: Task Details staleness | Title still says "2 orchestration skill files"; Description still says "third and fourth confirmed instances" with no mention of Task 1.3's file | Not yet fixed — see W3 | Open |
| 2026-08-20 | 2 | New finding: Phase 2 header staleness | Phase 2 Goal/Description/Verification/Stop Rule/Clues still describe "two-file"/"6 lines"/"both files" scope; Verification line omits the Task 1.3 grep check that Task 2.1's own DoD (correctly) includes | Not yet fixed — see W4 | Open |

## Top Failure Modes

- A reviewer or reader relies on the plan's Task Details table or Phase 2's "Verification:" line as the authoritative scope/check summary (both still say "2 files" and list only 2 of the 3 grep checks) instead of drilling into Task 1.3 and Task 2.1's own (correct) Definition of Done — under-verifying at exactly the review/Fine gate, even though the actual task instructions are complete and correct.
- None of the line-number, quoted-text, or file-existence risks from iteration 1 remain live — re-verified against current disk state, not just the diff.

## Unproven Assumptions

- None material remain for the edit itself. One soft assumption carried forward: `website/docs/skills/technical-context-discovery.md` is manually authored, not sync-generated — re-verified this iteration (`git log --all` shows only the single initial-add commit `71c6dae`; no `scripts/` or `adapters/` file references `website/docs/skills/`) and found accurate, so this assumption is now confirmed rather than unproven.

## Most Likely Rework Triggers

- Updating Task Details Title/Description and Phase 2 Goal/Description/Verification/Stop Rule/Clues to say "3 files / 7 lines" instead of "2 files / 6 lines" — trivial, cosmetic, does not require re-review once done.
- None of the substantive iteration-1 rework triggers (line numbers, undiscovered instance) remain; both were fixed and are re-verified accurate against the current repo state.

## Questions the Architect Must Answer Before Coding

- None execution-blocking. Optional cleanup: should Task Details and Phase 2's header text be synced to the 3-file scope before execution, or is it acceptable to leave as post-hoc narrative drift since every task-level instruction (the part that's actually executed) is already correct and consistent?

## BLOCKERS

None. B1 from iteration 1 is fixed and re-verified: `.ai/skills/eversis-orchestrating-implementation/SKILL.md` currently has the todo line at 36, the Step 5 heading at 253, and the Connected Skills bullet at 267 — exactly matching the plan's corrected To Be Modified and Task 1.1 citations, with a clean working tree (no further drift since the correction).

## WARNINGS

### W3: Task Details (Title, Description) not updated for the 3-file scope

The plan's top-of-document Task Details table still reads:

- **Title:** "Remove false `(Cursor-only)` / Cursor-exclusive host labels from **2 orchestration skill files**"
- **Description:** describes only the two `.ai/skills/` files and says "This is the **third and fourth** confirmed instances of the same host-exclusivity bug class in this repo" — no mention of `website/docs/skills/technical-context-discovery.md` or Task 1.3.

Every other Task 1.3-related section (Wildly Important Goal, Success Measure, Do NOT touch, To Be Modified, Open Questions #4, Proposed Solution item 3, Phase 1 Description, Task 1.3 itself, Quality Assurance) was correctly updated — this table was the one section missed. Low practical impact (it's a summary field, not an execution instruction), but it is the first thing a reader or a future audit would check for scope, and it currently undercounts the fix by one file/instance.

**Action needed:** Update Title to "...from 3 files (2 orchestration skills + 1 published docs mirror)" or similar, and extend Description to mention Task 1.3's file and count it as the "fourth and fifth" (or however the Architect wants to number it) confirmed instance.

### W4: Phase 2 header (Goal/Description/Verification/Stop Rule/Clues) not updated for the 3-file scope

Task 2.1's own **Files** list and **Definition of Done** were correctly updated to include all three files and all three grep checks. However, the surrounding Phase 2 section header was not:

- **Goal:** "Independently verify **both text edits**..."
- **Description:** "Final verification of the full **two-file change**."
- **Verification:** lists only the two `.ai/skills/` grep commands — omits the Task 1.3 grep (`discover project instructions \(cursor\)` against `website/docs/skills/technical-context-discovery.md`) that Task 2.1's own DoD correctly includes two paragraphs later.
- Task 2.1's **Stop Rule** ("If review finds a **third file** with the same bug class not covered by research's broader sweep, stop and confirm scope expansion...") is now stale/self-contradictory in context — a third file with exactly that shape (found outside research's sweep) already happened and was already resolved as Task 1.3, but the Stop Rule reads as if that scenario hasn't occurred yet.
- Task 2.1's **Clues** still says "Review scope is intentionally narrow — **6 lines, 2 files**, no logic change" — should be 7 lines, 3 files.

This is not a functional gap (Task 2.1's own DoD, immediately below, is complete and correct, so a Code Reviewer following the task-level checklist will not under-verify), but it is an internal inconsistency within Phase 2 that could confuse a reviewer who anchors on the Phase-level summary line instead of the Task 2.1 DoD.

**Action needed:** Update Phase 2's Goal/Description to "three text edits"/"three-file change," add the missing grep to the Phase-level Verification line, and update Task 2.1's Stop Rule and Clues to reflect that the "third file" scenario already occurred and was resolved (or reword the Stop Rule to anticipate a *fourth* undiscovered instance instead).

## SUGGESTIONS

### S3: Consider a research Changelog entry for the Task 1.3 scope expansion

`cursor-only-mislabel.research.md`'s Gap Analysis (Q2 → B) and Broader sweep results section still describe the sweep and its findings as scoped to `.ai/` with exactly one additional instance found (`eversis-technical-context-discovering/SKILL.md`). The `website/docs/skills/technical-context-discovery.md` instance and the human's fold-in decision exist only in the plan's Changelog, not in research's. This is not a defect in the plan under review, and research approval is not being re-litigated here, but for traceability it would be reasonable for research to gain a short Changelog line noting the iteration-1 finding and its resolution, since research is the document of record for "how many confirmed instances exist."

### S4 (carried forward, still valid): Minor line-count note for `eversis-technical-context-discovering/SKILL.md`

Re-confirmed this iteration: `wc -l` reports 86 while the file's last numbered line is 87 (no trailing newline) — cosmetic only, no content drift since `e54eb18` (2026-08-06). No action needed.

## Verdict

`APPROVED`

Rationale: all iteration-1 findings (1 blocker, 2 warnings, 1 suggestion) are fixed and independently re-verified against current on-disk content across all three target files — exact quoted text, exact line numbers, exact surrounding context, and the manual-authorship claim for the new file all check out. No execution-critical open decisions remain (Open Questions table fully resolved) and no new blockers were found in this full re-review. The two new warnings (W3, W4) are documentation-consistency cleanup in non-executed summary/header text, not defects in the actual edit instructions (Tasks 1.1–1.3) or their verification (Task 2.1 DoD) — recommended before execution for clarity, but not required to gate it.
