# Plan Review: ac-2-description-snapshot.plan.md

**Reviewed plan:** `docs/specs/ac-2-description-snapshot/ac-2-description-snapshot.plan.md`  
**Research file:** `docs/specs/ac-2-description-snapshot/ac-2-description-snapshot.research.md`  
**Review date:** 2026-09-23  
**Verdict:** `APPROVED`

**Summary:** 0 blockers · 2 warnings · 2 suggestions

## Challenge Domains

| Domain | Result |
| ------ | ------ |
| Technology and stack decisions | no issue — local Markdown edit only; no runtime, package, or adapter stack choice |
| Irreversible or high-cost decisions | no issue — no Jira write, no `.ai/` edit; labeling is reversible; refusing republish is the intended safety move |
| Contradictions with research or prior context | no issue — matches research Q1/Q2 (fence stays, no Jira / Layer A / AC-27 paste); Human gate 3 and live rule 14 already state AC-26; appendix still contains `5–10 prompt/response exchanges` |
| Scope gaps and silent omissions | **finding (W1)** — research names three pre-AC-26 sites inside the fence; plan DoD/Success Measure only prove one unique substring survives |
| Cross-cutting decisions that propagate | **finding (W2)** — Phase 5 Task 5.1 still instructs `editJiraIssue` from the appendix when someone says publish; snapshot note forbids republish; plan does not call out that historical path |
| Build vs buy vs reuse | no issue — reuses existing `ac-2.plan.md` appendix; no new skill, dependency, or duplicate artifact |

## Decision and Revision History

| Date | Iteration | Decision / Topic | Problem / Challenge | Plan Decision / Change | Status |
| ---- | --------- | ---------------- | ------------------- | ---------------------- | ------ |
| 2026-09-23 | 1 | Fence rewrite vs label | Would destroying the 2026-09-21 publish text make the appendix look current? | Keep fence byte-for-byte; label outside; AC-26 named as replacement | kept |
| 2026-09-23 | 1 | Jira / Layer A / AC-27 | Republish or side edits would restore hard stop or widen scope | Explicit Do NOT; no `editJiraIssue`; no `.ai/` | kept |
| 2026-09-23 | 1 | Verification substring | Prove Phase 3 publish wording survived without rewriting the note | Require `5–10 prompt/response exchanges` only inside fence; forbid it in the note | kept |
| 2026-09-23 | 1 | Plan review (this pass) | Human already said `Ok, implement`; still need failure-mode review before code | Verdict APPROVED; W1–W2 / S1–S2 recorded; no plan file edit by reviewer | resolved |

## Top Failure Modes

- Implementor “aligns” Requirement 10 and/or the Phase 3 acceptance check inside the fence to AC-26 while leaving the Phase 3 table substring intact — all current `rg` DoD checks still pass.
- A later session re-runs Phase 5 Task 5.1 (`editJiraIssue` from the appendix) after the human says publish, restoring the hard-stop description to Jira despite the new snapshot note.
- Careless replace accidentally edits the opening fence line or first table rows; gitignored `docs/specs/` gives no `git diff` safety net, and DoD never hashes the fence.

## Unproven Assumptions

- The implementor will treat Phase 5 Task 5.1 as historical completed work and will not re-execute it against the renamed appendix.
- Manual Code Review (Task 2.1) will catch any fence-body edit that the substring-only DoD misses.
- The en-dash form `5–10` in verification commands matches the live fence (verified this review: Phase 3 table row ~622).

## Most Likely Rework Triggers

- DoD passes while research’s “three sites unchanged” intent fails → rework to restore fence and tighten verification.
- Accidental Jira write during Implement → out-of-scope incident; plan Stop Rule already forbids it, but Task 5.1 prose still teaches the call.
- Review BLOCKER for any fence change → restore pre-edit fence text before other fixes (already in Task 2.1 Stop Rule).

## Questions the Architect Must Answer Before Coding

- None that block coding. Optional: whether to add fence sentinels / Task 5.1 historical Clue as plan deltas in a follow-up edit (see WARNINGS / SUGGESTIONS) without widening implementation scope into Task 5.1 body edits.

## BLOCKERS

None.

Open Questions table: both rows `✅ Resolved`. No execution-critical provider/stack/migration decision on the path. Reality check passed: Human gate 3 (~413) already states the AC-26 contract; appendix heading still `(shipped)` with copy-ready intro (~597–599); fenced body contains `5–10 prompt/response exchanges` (~622); Changelog ends with 2026-09-21 Phase 5 publish (~432); live rule 14 matches the plan’s AC-26 summary.

## WARNINGS

### W1: Fence integrity DoD covers one of three research-critical sites

Research explicitly lists three places inside the fence that still describe the pre-AC-26 stop: Phase 3 table (~622), Requirement 10 (~754), and Phase 3 acceptance (~801). The plan’s Success Measure and `rg` suite only require survival of `5–10 prompt/response exchanges`, which appears in the Phase 3 table row only (Requirement 10 / Phase 3 AC use shorter `5–10 exchanges` wording). The plan text claims that search “proves the published Phase 3 row was not rewritten,” which understates the research constraint (any character inside the fence). Combined with gitignored specs, an implementor could rewrite the other two sites and still pass Task 1.1 DoD.

**Action needed (optional before coding, recommended):** Add at least one more inspectable sentinel from Requirement 10 and from the Phase 3 acceptance line (or a fence line-count / checksum step) to Technical Context → Testing Patterns and Task 1.1 DoD. Does not require widening the edit surface.

### W2: Residual Phase 5 Task 5.1 publish path still invites `editJiraIssue`

After this plan lands, the appendix note will say do not publish again, but Task 5.1 (~342–356) still says: on explicit **publish to Jira**, set `fields.description` from the appendix (still named `(shipped)` in that task text). Human gate 4 already records the 2026-09-21 publish as done. Leaving Task 5.1 untouched matches research scope, yet it remains the strongest in-file path to recreate the exact failure this task exists to prevent.

**Action needed (optional before coding):** Without editing Task 5.1 in `ac-2.plan.md`, add an explicit Clue / Stop Rule / Improvements bullet in *this* plan: Task 5.1 is historical; do not re-run it; a future Jira update must be a separate ticket with AC-26 session wording, not a republish of this snapshot.

## SUGGESTIONS

### S1: Name Task 5.1 in Task 1.1 Clues

One sentence in Task 1.1 Clues: “Do not reopen Phase 5 Task 5.1; heading rename is intentional; snapshot note supersedes the old copy-ready publish invitation.” Cheap coordination insurance for the Implementor and Code Reviewer.

### S2: Dual-check the note vs fence on the long substring

Task 1.1 DoD already forbids `5–10 prompt/response exchanges` in the note. Consider also asserting the note *does* contain the shorter phrase `5–10 exchanges` (as in Proposed Solution) so a truncated note that omits the historical trigger summary fails loudly.

## Verdict

`APPROVED`

Fewer than five findings: the plan is unusually robust for this scope — one-file, no stack choice, Open Questions closed, Do NOT list matches research, verification commands are concrete (no angle-bracket executable placeholders), mandatory Code Review phase is present, and live Human gate 3 / rule 14 / appendix substring all match the architect’s claims. Remaining risks are verification depth and a historical republish path left intentionally untouched; neither blocks starting Task 1.1.
