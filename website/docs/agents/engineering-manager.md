---
sidebar_position: 4
title: Engineering Manager
---

# Engineering Manager Agent

**Rule pack (canonical template):** `.cursor/rules/eversis-role-engineering-manager.mdc`  
**In this repository:** attach **`.cursor/rules/eversis-engineering-manager.mdc`** when running **`@eversis-implement`** (docs: [Implement](../prompts/public/implement)).

The Engineering Manager orchestrates the **Implement** phase via **`eversis-orchestrating-implementation`** (loaded when you run **`@eversis-implement`**). It does not replace implementers — it follows the approved plan, delegates work by task type, and enforces human gates from **`eversis-agent-core.mdc`**.

## Delegation flow

```
Implementation plan
        │
        ▼
┌──────────────────────┐
│ Engineering Manager   │ ← Reads plan, delegates tasks
└──────────┬───────────┘
           │
     ┌─────┼─────┬─────┬─────┬─────┬─────┐
     ▼     ▼     ▼     ▼     ▼     ▼     ▼
    SE   E2E  DevOps Arch  CR   UIR   PE
```

The Engineering Manager is bound to the public prompt **`@eversis-implement`**. The canonical workflow lives in [Orchestrating Implementation](../skills/orchestrating-implementation) (`eversis-orchestrating-implementation` skill): Quick vs Full selection, planning readiness, task routing, UI verification gate, and Fine handoff.

## Agent Delegation

| Role | Handles | When used |
| --- | --- | --- |
| **Software Engineer** | Application code, features, bug fixes | Task involves writing or modifying application code |
| **E2E Engineer** | Playwright E2E | Task requires writing or updating E2E test suites |
| **DevOps Engineer** | Infrastructure, CI/CD, deployments | Task involves infrastructure changes or pipeline configuration |
| **Architect** | Codebase analysis, technical context, planning | Before implementation when plan or Technical Context is missing (via [Plan](../prompts/internal/plan)) |
| **Plan Reviewer** | Plan stress-test before coding | After human plan review, before broad implementation (via [Review Plan](../prompts/internal/review-plan)) |
| **Code Reviewer** | Code quality, best practices | After implementation completes, or when no review phase is defined |
| **Prompt Engineer** | LLM application prompts | Task involves designing, optimizing, or securing LLM prompts |
| **UI Reviewer** | Figma verification, visual correctness | After UI implementation, to verify against design specifications |

## How to Use

Attach **`@eversis-implement`**, optionally **`@.cursor/rules/eversis-engineering-manager.mdc`**, plus ticket text and `@docs/specs/` / `@docs/context/` as needed. In the IDE, internal delegates live under `.cursor/prompts/internal/`; on the docs site see [Research](../prompts/internal/research), [Plan](../prompts/internal/plan), [Implement UI](../prompts/internal/implement-ui), and related implement prompts.

See also the [Implement](../prompts/public/implement) workflow documentation page. On **Fine**, produce a QA comment draft per [eversis-fine-handoff](../skills/fine-handoff).

## Tool Access

| Tool | Usage |
| --- | --- |
| **Atlassian** | Gathers Jira tickets and Confluence documentation for task context |
| **Sequential Thinking** | Decides which agent to delegate to when the task type is ambiguous |
| **Terminal** | Runs commands to verify environment state |
| **Cursor Agent** | Navigates the codebase and implementation plan |
| **Todo** | Tracks task completion within the plan |

## Key Behaviors

- **Delegates every task** — Never writes code itself; all implementation is routed to specialized agents.
- **Routes based on task type** — Application code → Software Engineer, E2E tests → E2E Engineer, infrastructure → DevOps Engineer, LLM prompts → Prompt Engineer.
- **Packages context automatically** — Each delegation includes structured context from the implementation plan.
- **Runs plan validation** — Delegates to the [Plan Reviewer](./plan-reviewer) after human plan review unless an approved `.plan-review.md` already exists.
- **Uses Technical Context from the plan** — Skips redundant codebase discovery when the plan's Technical Context section is thorough.
- **Runs codebase analysis when needed** — Invokes the [Architect](./architect) when Technical Context is incomplete.
- **Respects human gates** — Stops for approval after research, after planning, and after plan validation before broad code changes (`eversis-agent-core.mdc`).
- **Outputs Implement readiness first** — On every `@eversis-implement` / `/eversis-implement` run, the **exact four-line** readiness block is the **first content** (Flow / Research / Plan / Next gate; optional Reason) before artifacts or code. Runs **adequacy checklist** before Research SKIP when artifacts exist (orchestration skill Step 1).
- **Auto-triggers Code Reviewer** — Automatically runs the Code Reviewer at the end of implementation if no review phase is defined in the plan.
- **Tracks progress** — Updates plan checkboxes after each completed task.
- **Asks before deviating** — Requests user confirmation before deviating from the implementation plan.
- **Uses Sequential Thinking for ambiguous routing** — When the task type doesn't clearly map to one agent, uses the Sequential Thinking tool to reason through the delegation decision.

## Handoffs

- **From** [Architect](./architect) — execution against the signed-off plan.
- **To** [Code Reviewer](./code-reviewer) — **`@eversis-review`** ([Review](../prompts/public/review)) with **`eversis-code-reviewer.mdc`** when appropriate.
- **To** [UI Reviewer](./ui-reviewer) — **`@eversis-review-ui`** ([Review UI](../prompts/public/review-ui)) for visual verification.
