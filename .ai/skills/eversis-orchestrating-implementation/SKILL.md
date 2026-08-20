---
name: eversis-orchestrating-implementation
description: Owns the canonical implementation orchestration workflow for feature implementation, including flow selection, planning readiness, delegated execution routing, todo control, and review gates. Use when handling implementation orchestration, eversis-implement, or feature implementation workflows that must coordinate specialized agents without writing product code directly.
user-invocable: false
---

# Orchestrating Implementation

This skill is the canonical workflow owner for implementation orchestration in the Engineering Manager role. It selects the right flow, prepares execution context, routes delegated work, and closes quality gates without writing product code itself.

<principles>
<canonical-source-of-truth>
This skill is the single canonical source of truth for the implementation-orchestration workflow. Keep flow selection, planning readiness, task routing, todo protocol, execution-plan steps, and review gates here rather than duplicating them in agents or prompts.
</canonical-source-of-truth>

<never-writes-product-code>
This skill never writes product code itself. It orchestrates delegation, validation, review, and escalation.
</never-writes-product-code>

<todo-role>
The todo list is the progress-control surface. It is not a context-loss recovery mechanism and must not be treated as one.
</todo-role>
</principles>

## Workflow

Use the checklist below and keep it synchronized with the todo list:

```text
Implementation orchestration progress:
- [ ] Step 0: Create flow-start todos
- [ ] Step 1: Select Quick Flow or Full Flow
- [ ] Step 2: Write the upfront execution plan
- [ ] Step 3: Run the selected flow
- [ ] Step 4: Close validation and review gates
- [ ] Step 5: Declare Fine and produce QA comment draft
```

### Step 0 - Start with todos

- Create todos at the start of the selected flow.
- In Quick Flow, create one todo per orchestration action.
- In Full Flow, create one todo per plan task, per review loop, per `[REUSE]` UI verification item, and per final gate.
- Consult the todo list before each action.
- Mark the matching todo complete immediately after the action finishes.
- If scope changes, update the execution plan first, then synchronize the todo list.

### Step 1 - Assess complexity and recommend a flow

Use the following decision rules before any delegation.

**Quick Flow is allowed only when every check below passes:**

| Check | Quick Flow pass condition |
| --- | --- |
| Scope width | Narrow, single-domain change with one clear implementation owner |
| Solution clarity | Solution path is obvious from the task, approved plan, or existing context |
| File impact | Likely to touch 3 files or fewer |
| Ambiguity | No major ambiguity, contradiction, or unresolved tradeoff |
| Planning readiness | No missing research gap and no missing plan gap for the work being attempted |
| UI/Figma involvement | No Figma reference, no `[REUSE]` UI verification task, and no UI-verification requirement |

**Full Flow is required when any check below is true:**

| Trigger | Full Flow condition |
| --- | --- |
| Cross-domain work | Work spans multiple domains, multiple agents, or architectural boundaries |
| Ambiguity | Requirements, constraints, or acceptance criteria are incomplete or unclear |
| Research gap | Required context is missing or no **adequate** `*.research.md` exists for the current scope (file existence alone is insufficient — run adequacy checklist) |
| Plan gap | No actionable `*.plan.md` exists for the current task |
| Larger scope | Likely to touch more than 3 files or requires phased execution |
| UI/Figma involvement | Any Figma involvement or UI-verification involvement exists |

**Hard exclusion:** any Figma or UI-verification involvement immediately disqualifies Quick Flow.

Recommend Quick Flow or Full Flow in chat with a short reason, and allow the user to override the recommendation.

#### Implement readiness (mandatory first output)

Before creating artifacts, delegating, or writing product code, inspect `docs/specs/<issue>/` and any `@`-attached plan/research paths. Then **output at the start of the first response** the readiness block below (including Quick Flow and QA follow-ups). Do not skip it when continuing a summarized or handoff thread.

**Note for maintainers:** “output at the start of the first response” means the block is the **first content** in the assistant message — not physical printing.

```text
## Implement readiness
- **Flow:** Quick | Full | QA follow-up
- **Research:** SKIP (<path>) | CREATE | DELTA (<reason>)
- **Plan:** SKIP (<path>) | CREATE | REFRESH (<reason>)
- **Next gate:** Awaiting approval before code | Awaiting approval before plan | Proceeding (<one-line reason>)
```

#### Readiness output contract (hard)

- The **first content** in the first assistant message MUST be the readiness block — no other heading, Jira recap, or analysis before it.
- Use heading exactly: `## Implement readiness` (no issue key or suffix on the heading line).
- Include **exactly four** bullet lines: Flow, Research, Plan, Next gate — in that order.
- Optional fifth line after the block: `- **Reason:** …` (one line: why this Flow / Research decision).
- Do **not** substitute a narrative summary or A/B/C option menu for the block.

#### Gate-closing rule (hard)

A declared `Next gate` closes only when the user's next message **directly responds to that specific gate** — not merely because the user replied to something else in the thread (e.g., locking research Gap Analysis answers closes the *research* gate, not a later Plan or Quick Flow gate).

- **Once a `Next gate` is declared, stop — every time, not only for Quick Flow reclassification.** Do not perform any implementation action, file edit, delegation, or further workflow progression in that same turn or response, regardless of what user message initiated this turn — including a message that correctly triggered writing the very artifact the new gate now covers (e.g., an instruction to write a plan is not retroactive approval to implement it once written). Applies to every declared gate in a thread (Plan, code, Quick Flow acceptance, review→Fine), not only the readiness block in the first response.
- Treat only an explicit answer to the declared gate, arriving in the user's **next** turn *after* that gate was declared, as the acceptance signal — not silence, not an unrelated reply, not a message sent before the gate existed, not the absence of objection.
- **When the self-check's answer isn't a clean yes, ask before proceeding — but only for a plausible-but-uncertain approval attempt, not for every non-approval message.** If the user's reply could plausibly be read as approval but isn't unambiguous, do not infer approval from that plausible reading — ask the user an explicit clarifying question (the current environment's interactive-question mechanism where one is available, or a plain clarifying chat message otherwise) before treating the gate as closed. This does **not** apply to replies that are clearly something else — an answered question, a requested change to the plan/research, a clarification, or ordinary discussion. Handle those directly (answer, edit, discuss) and leave the gate open for a later, genuine closing reply — do not additionally ask "are you approving?" when it's already obvious the reply wasn't an approval attempt at all.

#### Adequacy checklist

Run **before** setting `Research: SKIP` or `Plan: SKIP` when a `*.research.md` or `*.plan.md` already exists (bugfix, QA comment, retest, or attached `@` artifact).

1. **Latest QA comment / AC** — Does the research reflect the **same** problem as the latest Jira QA comment or user-stated acceptance criteria? If not → `Research: DELTA`.
2. **Root cause and paths** — Do affected modules/files in research match the current report? If not → `Research: DELTA`.
3. **Open questions** — Do unresolved questions in research block fixing **this** scope? If yes → `Research: DELTA` or `CREATE` (not SKIP).
4. **Plan coverage** — If a plan exists, do its tasks cover the current fix? If not → `Plan: REFRESH`.

Document checklist outcome in `Reason:` or in the DELTA reason string.

| Checklist result | Research | Plan |
| --- | --- | --- |
| All checks pass | **SKIP** (`<path>`) | **SKIP** or implement |
| Scope changed / stale artifact | **DELTA** (reason) | **REFRESH** or **CREATE** |
| No research file | **CREATE** | **CREATE** |

#### Analysis-only via `/eversis-implement`

Pure analysis can be done **without** `/eversis-implement` (chat + `@docs/specs/…`, Jira, manual research files). When the user **does** invoke `/eversis-implement` with analysis intent (e.g. research, analyze, przeanalizuj, bug analysis, last QA comment):

- **Flow:** Full
- **Research:** CREATE | DELTA
- **Plan:** SKIP (analysis-only — plan after research approval)
- **Next gate:** Awaiting approval before plan

Write or update `*.research.md` in the **same session** before ending the turn. Do **not** offer A/B/C menus instead of the artifact.

#### Rules

- **SKIP** only when existing `*.research.md` / `*.plan.md` **adequately covers the current scope** (adequacy checklist passed), not merely because the file exists.
- **CREATE** when no adequate artifact exists for the current scope.
- **DELTA** when research exists but scope grew, the file addresses a **different** bugfix iteration, or the adequacy checklist fails — **update the research file** (Changelog + new section) in the same session; chat-only notes are insufficient except for trivial documentation typos.
- **REFRESH** when the plan exists but does not cover the current fix.
- **Proceeding** is allowed when artifacts are ready **and** the user attached an approved plan, gave a QA fix list, or explicitly asked to implement; otherwise use **Awaiting approval** (before plan or before code as appropriate).
- **Consumer project rules** (e.g. project-specific Jira bugfix supplements) **extend** this workflow — they do **not** override the readiness block, adequacy checklist, or human gates.

#### Research artifact (same session)

When readiness shows **Research: CREATE** or **DELTA**, the turn MUST end with an updated `*.research.md` on disk. The EM may run the `eversis-research` procedure inline in the same turn; deferring the file to a later turn without user approval is a workflow breach.

### Step 2 - Write the upfront execution plan

Write the full ordered agent + prompt call sequence before the first delegation.

- Do this immediately after flow selection.
- In Full Flow, do it again after plan approval and before execution starts.
- The sequence must cover every planned delegation, review, validation checkpoint, and UI verification item.
- Keep the execution plan synchronized with the todo list whenever order or scope changes.

## Quick Flow

Use Quick Flow only if Step 1 passed every Quick criterion and the user selected or accepted it (see **Gate-closing rule** above — acceptance must be explicit, in response to a direct proposal, never inferred).

1. **Delegate implementation** — Delegate to **Software Engineer** via [`eversis-implement-common-task.md`](../../../.ai/prompts/internal/eversis-implement-common-task.md).
2. **Run validation checks** — After implementation, run the appropriate checks for the affected area (see `eversis-project-stack.mdc` / `eversis-testing-and-terminal.mdc`).
3. **Delegate code review** — Delegate to **Code Reviewer** via [`eversis-review.md`](../../../.ai/prompts/public/eversis-review.md).
4. **Handle review results explicitly:**
   - If review passes with no required changes, proceed to Step 5 (Fine).
   - If review requests changes, ask for confirmation before changing the reviewed solution.
   - After confirmation, route fixes back to Software Engineer, run affected validation again, and re-run review when the fix is material.
5. **Abort Quick Flow if hidden complexity appears** — If ambiguity, cross-domain work, plan gaps, or any Figma/UI-verification need appears during execution, stop Quick Flow, rewrite the execution plan, and restart in Full Flow.

### Continuity (default) — code review → Fine

After implementation and validation checks (Quick or Full):

1. **Default:** Run code review in the **same session** (`eversis-review`). Do **not** set Next gate to “awaiting human to attach `/eversis-review`” and do **not** end the turn solely to wait for that attach.
2. On review **PASS** — defined as zero open BLOCKER findings **and** every visible Definition-of-Done and Acceptance-Criteria checkbox verified checked, not an unqualified "looks fine" (see Execution rules and gates below) — proceed immediately to Step 5 (**Fine** + QA draft in the **same response**).
3. **Opt-out** — only if the user explicitly said **`pause before review`** or **`review later`**: stop after implementation/validation and wait for the human before running code review / Fine.
4. Standalone `/eversis-review` (or attach) remains valid for review-only chats and re-review; it is not required to close a normal Implement thread.

## Full Flow

### Planning readiness

Check the current state before creating or executing any plan.

| Artifact or signal | Treat as ready when | If not ready |
| --- | --- | --- |
| `*.research.md` | It exists for the current task, **passes the adequacy checklist**, and contains enough context for the current scope | Delegate to **Context Engineer** with [`eversis-research.md`](../../../.ai/prompts/internal/eversis-research.md) or DELTA update |
| `*.plan.md` | It exists for the current task and contains ordered, actionable tasks that can be delegated | Delegate to **Architect** with [`eversis-plan.md`](../../../.ai/prompts/internal/eversis-plan.md) |
| Technical Context | The plan has a populated **Technical Context** section with conventions, patterns, stack, and testing guidance relevant to implementation | Delegate to **Architect** with [`eversis-review-codebase.md`](../../../.ai/prompts/public/eversis-review-codebase.md) to populate Technical Context in the plan |
| Plan approval state | `{task}.plan-review.md` has verdict `APPROVED` and the plan is unchanged since that review | Skip re-review |

### Planning sequence

1. **Check for existing research and plan files** — Inspect current `*.research.md` and `*.plan.md` state first.
2. **Adequacy check** — When artifacts exist, run the adequacy checklist; set Research/Plan to SKIP, DELTA, REFRESH, or CREATE before delegating.
3. **Fill missing context when needed** — If research is missing or inadequate after the checklist, delegate to Context Engineer with `eversis-research.md` or update the research file in the same session.
4. **Create or refresh the plan when needed** — If the plan is missing, stale, or not actionable, delegate to Architect with `eversis-plan.md`.
5. **Human plan review** — Ask the user to review scope, phases, and acceptance criteria before plan validation.
6. **Review the plan before execution** — Delegate to **Plan Reviewer** with [`eversis-review-plan.md`](../../../.ai/prompts/internal/eversis-review-plan.md) unless an approved `.plan-review.md` exists and the plan is unchanged.
7. **Run the review loop with hard limits:**
   - `*.plan-review.md` remains the source of truth.
   - If the verdict is `REVISIONS NEEDED`, send the review back to Architect and re-run review.
   - Stop after a maximum of **3** plan-review iterations and escalate to the user if blockers remain.
8. **Create execution todos from the plan** — Create todos per plan task, not just per phase.
9. **Capture UI inventory early** — Find every `[REUSE]` UI task and every Figma URL in the plan and research files.
10. **Ask for the dev server URL when UI tasks exist** — If the UI inventory is non-empty, ask the user in chat for the dev server URL before execution starts. Do not guess from port scans.
11. **Apply the Technical Context rule** — If the plan already contains populated Technical Context, use it and skip rediscovery; otherwise delegate to Architect with `eversis-review-codebase.md`.
12. **Conditional confirmation before execution** — Ask for confirmation before moving from planning to execution when the plan was newly created, materially changed, escalated, or not yet approved for execution in the current thread.
13. **Rewrite the upfront execution plan after approval** — Expand the ordered agent + prompt call sequence from the approved plan before the first implementation task starts.

### Execution routing

Process tasks in plan order. Consult the todo list before each task and update the plan and todo list after each completed task.

| Task type or tag | Delegate to | Prompt to use | Notes |
| --- | --- | --- | --- |
| app code | Software Engineer | [`eversis-implement-common-task.md`](../../../.ai/prompts/internal/eversis-implement-common-task.md) | Standard implementation work |
| UI with Figma | Software Engineer | [`eversis-implement-ui-common-task.md`](../../../.ai/prompts/internal/eversis-implement-ui-common-task.md) | Figma-based UI implementation |
| E2E | E2E Engineer | [`eversis-implement-e2e.md`](../../../.ai/prompts/internal/eversis-implement-e2e.md) | End-to-end test work |
| infra/Terraform | DevOps Engineer | [`eversis-implement-terraform.md`](../../../.ai/prompts/internal/eversis-implement-terraform.md) | Terraform changes |
| Kubernetes/deploy | DevOps Engineer | [`eversis-deploy-kubernetes.md`](../../../.ai/prompts/internal/eversis-deploy-kubernetes.md) | Deployment or Kubernetes work |
| CI/CD | DevOps Engineer | [`eversis-implement-pipeline.md`](../../../.ai/prompts/internal/eversis-implement-pipeline.md) | Pipeline work |
| observability | DevOps Engineer | [`eversis-implement-observability.md`](../../../.ai/prompts/internal/eversis-implement-observability.md) | Logging, metrics, or tracing |
| LLM prompts | Prompt Engineer | [`eversis-engineer-prompt.md`](../../../.ai/prompts/internal/eversis-engineer-prompt.md) | Prompt-engineering tasks |
| repo documentation | Repo Docs Writer | [`eversis-repo-docs-writer.md`](../../../.ai/prompts/public/eversis-repo-docs-writer.md) | README, CHANGELOG, `docs/`, `website/docs` only — not `.docx` |
| `[REUSE]` UI verification | UI Reviewer | [`eversis-review-ui.md`](../../../.ai/prompts/public/eversis-review-ui.md) | Review each UI item individually; do not batch |
| `[REUSE]` other | per the task definition | — | Execute as defined; delegate to the matching implementer only when new product code is required |

### Execution rules and gates

1. **Stay inside the approved plan** — If execution requires a material deviation, stop and get confirmation before changing direction.
2. **Delegate by route, not by instinct** — Use the routing table; pass the plan section, Technical Context, and latest outputs.
3. **Domain skills gate** — Before `eversis_skills_get` for stack-specific skills (frontend, backend, filters, BA Docs, etc.), confirm **`eversis-project-stack.mdc` § Agent skills policy** and the approved plan allow that skill. Do not load domain skills from task keywords alone.
4. **Update after every task** — After each task, update plan checkboxes, the matching todo, and run appropriate checks.
5. **Run checks after every task** — Lint, build, unit/integration tests, E2E, or infrastructure validation as appropriate for the changed area.
6. **Handle `[REUSE]` UI verification as a per-item loop:**
   - Process each `[REUSE]` UI verification task one item at a time in plan order.
   - Delegate each item to UI Reviewer with `eversis-review-ui.md`, passing Figma URL, dev server URL, and component or section name.
   - Use [`eversis-implement-ui.md`](../../../.ai/prompts/internal/eversis-implement-ui.md) as the workflow reference for the verify-fix loop.
   - Mark each item **PASSED** or **ESCALATED**. Never batch multiple UI verification items into one review step.
7. **Enforce the UI verification gate** — Do not start code review until every `[REUSE]` UI verification item has been individually passed or escalated with explicit user approval.
8. **Run code review after the UI gate clears** — Delegate to Code Reviewer with `eversis-review.md` only after the UI verification gate passes or is explicitly escalated per item. Apply **Continuity (default)** above — do not wait for a separate human `/eversis-review` attach unless opt-out. **Code Review must run as a genuinely separate delegated context from whichever context implemented the fix — self-review (the same context that wrote the code also declaring PASS on it) is not verification**, mirroring the UI verification gate's own isolation requirement (`eversis-implement-ui.md:57`, "Mental comparison or code reading is not verification").
9. **Confirm before changing a reviewed solution** — If code review finds issues, ask for confirmation before changing the reviewed solution.
10. **Route review fixes back through the correct implementer, then re-run a full review, with hard limits:**
    - After confirmation, delegate fixes through the routing table and run affected checks.
    - Re-run the **complete** review (every Definition-of-Done and Acceptance-Criteria item, not only the item that was fixed) before PASS can be declared again — a partial or spot-check re-review does not count.
    - If the same BLOCKER survives **3** full review passes, stop cycling and escalate to the user instead of continuing silently or declaring PASS anyway — mirroring the plan-review loop's iteration cap (Planning sequence, above).
11. **Treat direct implementation as a workflow violation** — If the orchestrator starts writing product code directly, stop and return to delegated execution.
12. **Record solution changes in the plan Changelog** — When the approved solution changes during implementation, document it in the plan file's Changelog with timestamps after confirmation.
13. **Proceed to Fine on PASS** — When review passes — per the PASS definition in Continuity (default) above — execute Step 5 in the same turn (unless Continuity opt-out).

### Step 5 - Declare Fine and produce QA comment draft

When all validation and review gates pass:

1. Declare **Fine** explicitly.
2. In the **same response**, produce the QA comment draft following **`eversis-fine-handoff`** (MCP `eversis_skills_get` or `.ai/skills/eversis-fine-handoff/SKILL.md`).
3. Label: `**Draft QA comment — review before posting to Jira**`.
4. Do **not** post to Jira in this turn. Only use Atlassian MCP after explicit human approval.

## Connected Skills

- `eversis-technical-context-discovering` — when existing Technical Context is sufficient vs when discovery should be delegated
- `eversis-code-reviewing` — final review gate standards
- `eversis-ui-verifying` — verification standard behind the per-item UI review gate
- `eversis-fine-handoff` — mandatory QA comment draft on Fine
- `eversis-writing-repo-documentation` — repository documentation tasks delegated from the plan
- `eversis-task-analysing` — whether research context is complete before planning
- `eversis-creating-implementation-plans` — plan structure and planning readiness signals
