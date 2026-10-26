---
name: eversis-creating-implementation-plans
description: "Creates implementation plan documents (*.plan.md) that break a designed solution into phases and verifiable tasks. Owns the plan template (plan.example.md), plan structure rules, and task definition-of-done rules. Use when authoring, revising, or structuring an implementation plan for any feature or task."
user-invocable: false
---

# Creating Implementation Plans

This skill turns a designed solution into a phased, verifiable implementation plan document.

<principles>
<plan-structure-ownership>
This skill is the single owner of the plan template (`./plan.example.md`), the plan-structure procedure, and the definition-of-done rules for implementation plans. Other skills and agents MUST reference this skill instead of duplicating plan-structure rules.
</plan-structure-ownership>
<goal-hierarchy>
Every plan defines one Wildly Important Goal, stated explicitly as the single most important outcome the whole plan must achieve. The Wildly Important Goal section must keep that main goal as one sentence on a labeled `**Goal**:` line, and also include an explicit Success Measure plus a Do NOT touch / do NOT add list to reduce scope creep. Every phase defines a Goal that clearly advances the Wildly Important Goal, followed by a Description that explains the broader why for reviewers and implementors. The plan itself, after the Wildly Important Goal, also includes a description of the overall approach.
</goal-hierarchy>
<open-questions-dispatch-gate>
Plans must not be dispatched to an implementor while any Open Questions row has Status = ❓ Open; unresolved questions must be routed back to the Architect before execution.
</open-questions-dispatch-gate>
<executable-slots-dispatch-gate>
Plans must not be dispatched to an implementor while any executable slot still contains an angle-bracket placeholder or any assumed-default command. Verification fields, DoD command items, and file/spec path arguments must be resolved from Technical Context or the task's app stack before dispatch. This gate applies only to executable slots; instructional angle-bracket placeholders elsewhere in the template are allowed.
</executable-slots-dispatch-gate>
<no-real-code>
The plan must not contain real implementation code or full implementation bodies/function logic. Pseudo-code is allowed only to explain genuinely complicated algorithms or ideas, and task-boundary seam artifacts such as type definitions, function signatures, DTOs, interfaces, and API shapes are allowed when they clarify the contract without supplying implementation bodies. Diagrams, explanations, and the Technical Context chapter content are allowed and encouraged.
</no-real-code>
</principles>

## Plan Creation Process

Before drafting, read [`./plan.example.md`](./plan.example.md) in full first — it is the canonical structure every plan must follow.

1. Confirm inputs: a designed solution, typically from `eversis-architecture-designing`, plus task research and context. Do not design the solution here; this skill structures an already-designed solution into a plan.
2. Define the Wildly Important Goal and the plan description.
3. Divide the work into small phases. Each phase must have a Goal, a Description, a `**Verification:**` field listing the exact fast-running checks to run after the phase completes, and a list of tasks with checkboxes. Source checks from Technical Context → Tech Stack / Testing Patterns rather than assuming Node/npm.
4. Define each task with Description, `**Files:**`, Definition of Done, optional `**Stop Rule:**`, and optional Clues. Label each file `create`, `modify`, or `reuse`; add inline back-references when a file was produced in an earlier task.
5. Add the mandatory cross-cutting tasks required by the plan rules.
6. Save the plan following `./plan.example.md` exactly. Do not add or remove sections.

<definition-of-done-rules>
Each task must include a definition of done as a checkbox list with at least one objectively reviewer-verifiable check.
When a task changes code, include at least one runnable command from Technical Context → Tech Stack / Testing Patterns, matched to the app the task's Files belong to (never assume Node/npm by default).
For docs/config/content tasks with no runnable command, use a deterministic inspectable check (for example `docs/<file>.md contains an "## Usage" section`).
Definition of done must not include deployment steps, manual QA steps, or steps a code reviewer cannot verify during review.
</definition-of-done-rules>

<mandatory-plan-content>
- End with a code review phase handled by **Code Reviewer** via [`eversis-review.md`](../../../.ai/prompts/public/eversis-review.md). Pass e2e execution to that agent; do not run e2e from the plan author level.
- For Figma-based UI, follow each implementation task with a `[REUSE]` UI verification task for **UI Reviewer** via [`eversis-review-ui.md`](../../../.ai/prompts/public/eversis-review-ui.md). Include the Figma URL. Let the Engineering Manager orchestrate the verify-fix loop.
- For LLM application prompts, add a `[REUSE]` prompt engineering task via [`eversis-engineer-prompt.md`](../../../.ai/prompts/internal/eversis-engineer-prompt.md).
- Do not provide deployment plans, code pushing instructions, or repository code review instructions.
</mandatory-plan-content>

<plan-content-rules>
- Capture security considerations relevant to the implementation.
- Save the plan as `docs/specs/<key>-<topic>/<key>-<topic>.plan.md` (or `specifications/<key>-<topic>/<key>-<topic>.plan.md` when that is the team convention). The topic is at most three hyphen-separated words.
- For bug fixes, include reproduction, root-cause analysis, and a fix verified by tests.
- Plan only the current task. Record prerequisite and follow-up work in `Improvements`.
- Reuse or modify existing code whenever possible per `Current Implementation Analysis`.
</plan-content-rules>

## Connected Skills

- `eversis-architecture-designing` — designs the solution this skill turns into a plan
- `eversis-implementation-gap-analysing` — verifies what was already implemented before planning new work
- `eversis-technical-context-discovering` — populates the plan's Technical Context section
