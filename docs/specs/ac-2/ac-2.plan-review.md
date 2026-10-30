# Plan Review: ac-2.plan.md

**Reviewed plan:** `docs/specs/ac-2/ac-2.plan.md`  
**Research file:** `docs/specs/ac-2/ac-2.research.md`  
**Review date:** 2026-09-21  
**Verdict:** `REVISIONS NEEDED`  
**Lens:** Cursor host — `/eversis-implement`, always-on `agent-core.md`, required skill `eversis-orchestrating-implementation`.  
**Iteration:** 4. Iterations 1–2 stay closed. Iteration 3’s B2 is closed. Iteration 3’s B1 is only half closed. This is past the plan-review cap of 3 iterations — escalate the remaining decision to the human (see Verdict).

**Summary:** 1 blocker · 4 warnings · 2 suggestions

Open Questions: all five rows are `✅ Resolved`. No `❓ Open` gate.

Codebase checks for this pass: `eversis-orchestrating-implementation/SKILL.md` (readiness preamble + rule 14), `engineering-manager.md`, `.ai/prompts/public/eversis-implement.md`, `.cursor/commands/eversis-implement.md`, `agent-core.md` steps 4–5, research Diagram 2 and Question 5, `context.ts` `readIndexComponents`, and the generated website prompt page.

## Challenge Domains

| Domain | Result |
| ------ | ------ |
| Technology and stack decisions | **W4** — `Context` is specified only via `eversis_context_list` / `listContext()`. Cursor without that MCP still has `INDEX.md` on disk. `~50%` window fill (inside **B1**) is still not a signal this repo exposes. Markdown + `sync:adapters` is otherwise the right stack. |
| Irreversible or high-cost decisions | No issue. `Resume` is no longer a `Flow` enum value, so a later correction does not rewrite the workflow selector. `CHECKPOINT:` is an additive Changelog prefix. |
| Contradictions with research or prior context | **B1** — Research Diagram 2 sends `zadanie gotowe + przetestowane` to `review_stage` in the same flow, and sends a new session only when the task is **not yet done**. Question 5 instead ORs three end-session triggers, including done+tested. The plan follows Question 5 for intermediate tasks and Diagram 2 / Continuity only for the plan’s last task. Triggers 1–2 (`~50%`, 5–10 session exchanges) still end the session during in-session Review. |
| Scope gaps and silent omissions | **W1**, **W2**, **B1** — Phase 2’s Description still says to spread a `Resume` value across all five contract files. Task 2.1’s verification never runs `sync:website-docs`, and the generated prompt page still says “exact four-line”. Rule 14 never states the Cursor sentence that tells the human to open a new chat. |
| Cross-cutting decisions that propagate | **B1**, **W3** — Continuity (always-on `agent-core.md` steps 4–5, slash-command Executable section, rule 13) and rule 14 are one session contract. Precedence is written for trigger 3 vs rule 13 only. Resume detection treats “the most recent Changelog row” as the checkpoint, so any later row hides it. |
| Build vs buy vs reuse | No issue. Task 2.2 still extends `eversis-import-confluence-knowledge`. MCP TypeScript stays out of scope. `context.ts` still drops any INDEX row that is not exactly two columns. |

## Decision and Revision History

| Date | Iteration | Decision / Topic | Problem / Challenge | Plan Decision / Change | Status |
| ---- | --------- | ---------------- | ------------------- | ---------------------- | ------ |
| 2026-09-21 | 1 | Task 2.2 — new bootstrap skill | Existing import skill already covers Confluence-first | Rewrite Task 2.2 as `[MODIFY]` | resolved |
| 2026-09-21 | 1 | Task 2.1 — readiness block | Contract asserted in 5 files, plan touched 2 | Extend file list; later split Layer A / Layer B | resolved |
| 2026-09-21 | 1 | Task 2.1 — `Audit` line | No persistence for tasks-since-last-audit | Defer to future Phase 5 | resolved |
| 2026-09-21 | 1 | `INDEX.md` schema | Two-column parser drops extra columns | Forbid a third column | resolved |
| 2026-09-21 | 1 | Component file naming | Import wrote `<domena>/<temat>.md` | Task 1.2 unifies on `<component>/index.md` | resolved |
| 2026-09-21 | 2 | Task 1.2 frontmatter vs audit `Delete` | Import files visible to audit without `code_paths` | Emit empty arrays; one audit sentence | resolved |
| 2026-09-21 | 2 | “Identically across all five” | Would duplicate the block into Layer B | Layer A owns the block; Layer B rewords the count | resolved in Task 2.1; **still open in Phase 2 Description** (this iteration W1) |
| 2026-09-21 | 2 | Optional `Reason` line | “Fifth line” breaks once more optionals exist | Describe optional lines as a set | resolved |
| 2026-09-21 | 3 | Phase 3 vs Cursor Continuity | End-session triggers fight same-session Review→Fine | Last-task deferral to rule 13 added; 5–10 and `~50%` unchanged | partial — **B1 still open** |
| 2026-09-21 | 3 | `Resume` as `Flow` value | Resume erased Full vs Quick and had no detection rule | Independent `Resume:` line; skill Step 1 checks Changelog | resolved |
| 2026-09-21 | 4 | Triggers 1–2 vs Continuity | 5–10 session exchanges and `~50%` still end the session during Review; no Cursor off-ramp text | (this review) Human must choose precedence; do not start iteration 5 without that choice | open |

## Top Failure Modes

- **A Cursor Full Flow hits rule 14 before Review can finish.** `agent-core.md` steps 4–5 and the `/eversis-implement` Executable section require Review then Fine in the same Composer session. Rule 14 counts “5–10 prompt/response exchanges in the current session” with no reset at Implement start. Research approval and plan approval already consume that budget. The first Implement turns are therefore already over the cap. Precedence saves only the case “last task is already completed-and-tested.” It does not save Review while that task is still in progress, and it does not save triggers 1–2 at all. The agent is told to write `CHECKPOINT:` and end the session.
- **“End the session” does not reset Cursor.** Composer stays open until the human starts a new chat. Rule 14 and Task 3.1 never give the one-line instruction (“start a new `/eversis-implement` and `@` this plan”). The user keeps typing. Automatic compaction still happens. The checkpoint file write does not achieve Phase 3’s goal.
- **A checkpoint stops being visible as soon as the Changelog grows.** Detection (skill readiness preamble; plan Changelog micro-fix) keys off the **most recent** row starting with `CHECKPOINT:`. The clause “no later entry records completion” can never match when that row is already the last one. This plan’s own Changelog is a sequence of non-checkpoint rows. One rule-12 or review note after a checkpoint makes the next session emit `Flow: Full` and start over.

## Unproven Assumptions

- That a Cursor agent can observe “context window ~50%.” Nothing in `agent-core.md`, the slash command, or `eversis-collections` exposes remaining window capacity.
- That “end the session” is something the agent can do. It is not. The plan never specifies the user-facing sentence.
- That 5–10 exchanges counted across the **whole** Composer session is safe on this framework. Full Flow human gates plus Continuity routinely pass that count before code, and again before Fine.
- That `eversis_context_list` is up whenever the `Context` line is required. A missing MCP call is not the same fact as an empty `INDEX.md`.
- That “most recent Changelog row” is a stable resume key. It is not, once any later row is appended.

## Most Likely Rework Triggers

- First real Cursor `/eversis-implement` that reaches Review in the same chat, crosses 5–10 exchanges, and checkpoints instead of Fine.
- First resume after someone appends a normal Changelog row under `CHECKPOINT:` and the next chat ignores the handoff.
- A reader of Phase 2’s Description who copies `Resume` into the three Layer B files, recreating the iteration-1 duplication.
- A Cursor user who follows `website/docs/reference/prompts/public/eversis-implement.md` (“exact four-line”) and drops `Resume` / `Context`. The slash command itself is already updated.

## Questions the Architect Must Answer Before Coding

These are for the **human**, not another unattended architect pass (iteration cap).

- When a session is in Review or Fine, do triggers 1 and 2 (`~50%`, 5–10 exchanges) still end the session, or does Continuity / rule 13 win for every trigger? State it in Task 3.1’s Definition of Done, not only for trigger 3.
- Is the 5–10 count the whole Composer session, or only exchanges after plan approval while implementation is in progress? Diagram 2 places the monitor inside Implement, after human gates.
- What single sentence must the agent print so a human opens a **new** Cursor chat? “End the session” is not a host action.
- Is `~50%` in scope on Cursor? If it is not observable, drop it or mark it best-effort and non-blocking.

## BLOCKERS

### B1: Session-budget triggers 1 and 2 still pre-empt Cursor Continuity, and the off-ramp is not executable

Task 3.1 and rule 14 (live skill, “Execution rules and gates” item 14) still treat three triggers as independently sufficient, first one wins:

1. context window roughly half full,
2. 5–10 prompt/response exchanges in the **current session**,
3. current task completed-and-tested **while further tasks remain**.

The iteration-3 fix landed, and it is real: trigger 3 no longer fights rule 13 on the plan’s **last** task, and the live rule says to proceed to Fine in that one case. That matches the last-task half of research Diagram 2 (`zadanie gotowe + przetestowane` → `review_stage`) and `agent-core.md` steps 4–5.

It does not cover the rest of the same collision.

- Triggers 1 and 2 are still OR-sufficient **during** Review. Precedence text applies when the last task is already completed-and-tested. Review runs before that predicate is true. A Full Flow chat is usually past 5–10 exchanges by then, because research approval and plan approval happened in the same Composer session. Rule 14 then says write `CHECKPOINT:` and end the session — the opposite of the slash command’s Continuity paragraph (“run `eversis-review` in the same session, then on PASS declare Fine in the same response”).
- The 5–10 counter is not scoped to Implement-phase work. Diagram 2 draws the monitor inside `implement_stage`, on the edge “task **not yet** done.” Counting the whole session makes the trigger true at the moment Implement is allowed to start.
- `~50%` is not observable on Cursor (no rule, command, or MCP tool). Task 3.1’s Definition of Done still requires naming it as an independent trigger, so an implementer either guesses a fill level or ignores the only other mechanical trigger’s collision with Continuity.
- Neither Task 3.1 nor rule 14 tells the human to open a new `/eversis-implement` and attach the plan. Without that sentence, writing `CHECKPOINT:` does not stop compaction.

**Action (human decision, then a plan edit):** Pick one precedence model and write it into Task 3.1’s Definition of Done and rule 14.

- Continuity wins whenever the session is in Review or Fine, for **all three** triggers, not only trigger 3 on the last task.
- The 5–10 count applies only while implementation of a non-final task is in progress, after the plan-approval gate, or it is raised enough that a normal Full Flow can finish Review.
- `~50%` is dropped for Cursor, or marked best-effort and forbidden from ending the session by itself.
- The rule includes one user-facing line: start a new `/eversis-implement` and `@` the plan.

Do not treat the last-task sentence already in rule 14 as closing this. It does not bind triggers 1–2, and it does not bind Review before the task is marked complete.

## WARNINGS

### W1: Phase 2 Description still tells the implementer to spread `Resume` across all five files

Task 2.1, the Success Measure, Open Question 5, and the Proposed Solution correctly keep `Resume` and `Context` on Layer A only, and they correctly say `Resume` is not a `Flow` value.

Phase 2’s own **Description** (plan, the paragraph under “Phase 2: Enforced hygiene signal…”) still says the phase “extends the readiness block’s `Context` signal and new `Resume` value across all five contract files.” That is the pre-iteration-2 model. Someone who follows the phase description and not the task will duplicate the block into `eversis-implement.md`, `spec-driven-development.md`, and `orchestration/README.md`.

**Action:** Replace that one sentence so it matches Task 2.1. No `.ai/` change.

### W2: Task 2.1 never regenerates the website prompt page, which still says “exact four-line”

`.ai/prompts/public/eversis-implement.md` and `.cursor/commands/eversis-implement.md` say “four required lines plus optional signals.” `adapters/website/generate-prompts.mjs` copies the public prompt to `website/docs/reference/prompts/public/eversis-implement.md`. That committed page still says “Output the **exact four-line** Implement readiness block.” The same retired phrase is still in hand-authored `website/docs/main-flow/workflow/standard-flow.md` and `website/docs/reference/agents/engineering-manager.md`.

Task 2.1’s verification is only `npm run sync:adapters` / `sync:adapters:check`. `npm run sync:website-docs` exists and is the generator for the prompt page. The slash command tells agents to prefer `.ai/` over the docs site, so this is not the runtime contract — it is the page Cursor users read when they follow the site.

**Action:** Add `npm run sync:website-docs` and `sync:website-docs:check` to Task 2.1 (and Phase 4) verification, and either regenerate or explicitly exclude the two hand-authored pages with a reason.

### W3: Resume detection keys off the latest Changelog row, so the handoff disappears

The skill’s readiness preamble (and the plan Changelog entry that specified it) says: check the **most recent** Changelog entry; if it starts with `CHECKPOINT:` and no later entry records that task’s completion, emit `Resume:`.

If the latest row is `CHECKPOINT:`, there is no later row, so the second clause does nothing. If any later row exists — rule 12, a review note, a “resumed” line — the latest row is not `CHECKPOINT:`, and the next session does not resume. This plan’s Changelog is exactly that shape: many non-checkpoint rows after each other.

**Action:** Define detection as “the latest row whose description starts with `CHECKPOINT:` and that has no later row marking that checkpoint consumed,” and name what a consumed marker looks like. Put that sentence in Task 2.1 or Task 3.1’s Definition of Done so a later edit that “aligns the skill to the DoD” cannot delete it. Today the sentence exists in the skill and in the Changelog narrative, not in a task checkbox.

### W4: `Context: 0 components` is specified only through MCP

Task 2.1 and both Layer A files tell the agent to use `eversis_context_list` / `listContext().length`. `readIndexComponents` in `mcp/eversis-collections-mcp/src/context.ts` reads `INDEX.md` only when that server runs. A Cursor session without the MCP server cannot distinguish “server not connected” from “INDEX is empty,” and the empty-INDEX signal is the point of Phase 2.

**Action:** One sentence on the `Context` line: if the MCP tool is unavailable, count data rows in `docs/context/<project>/INDEX.md` by the same two-column shape, and do not report `0` merely because the tool call failed.

## SUGGESTIONS

### S1: Mirror the Changelog check into `engineering-manager.md` self-check 1

The detection sentence lives in the orchestration skill’s readiness preamble. `engineering-manager.md` tells the agent to inspect `docs/specs/<issue>/` and says `Resume` is present “when a fresh session recognizes” a checkpoint, pointing at the skill. Self-check 1 does not mention `CHECKPOINT:`. `/eversis-implement` does require the skill, so the slash path can see the rule. A one-line addition to self-check 1 would keep the two Layer A files from drifting on the trigger.

### S2: Say how a Cursor user invokes the bootstrap skill

`eversis-import-confluence-knowledge` is `user-invocable: true` and has no `.cursor/commands` shim. Task 2.2’s Definition of Done is satisfied by the skill text. A Cursor consumer with `Context: 0 components` has no slash command for it. One sentence under “When to run” — `@` the `SKILL.md` or call `eversis_skills_get` — closes that without a new prompt.

## Verdict

`REVISIONS NEEDED`

Iterations 1–2 remain closed. Iteration 3’s **B2 is closed**: `Resume` is an optional line, `Flow` stays `Quick | Full | QA follow-up`, and the orchestration skill’s readiness preamble tells the agent to look for `CHECKPOINT:` before emitting the block. Confirmed in `engineering-manager.md` and `eversis-orchestrating-implementation/SKILL.md`.

**B1 is not closed.** The last-task vs rule 13 sentence is in the plan and in rule 14. Triggers 1–2 still end a Cursor session during Review, the 5–10 count includes pre-Implement gate turns, `~50%` is not observable, and there is still no instruction that makes the human open a new chat.

This is review iteration 4. The prompt caps plan-review loops at 3, then the human decides. Do not send the plan back for another architect-only pass. The open choice is the precedence model in the B1 action list. After that choice is written into Task 3.1, a single targeted re-review of B1 (and W1–W3 if they are edited in the same pass) is enough. W4 and the suggestions do not block that decision.
