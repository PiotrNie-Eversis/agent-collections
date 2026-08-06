---
sidebar_position: 2
title: Standard Flow
---

# Standard Flow

The standard workflow is used for backend and fullstack tasks. The Engineering Manager orchestrates delivery via **Quick Flow** or **Full Flow** (see [Orchestrating Implementation](../skills/orchestrating-implementation)).

## Quick Flow vs Full Flow

At the start of `@eversis-implement`, the Engineering Manager inspects existing specs and outputs the **exact four-line** **Implement readiness** block as the **first content** (Flow / Research / Plan / Next gate), then assesses complexity and **recommends Quick or Full in chat**. You may override the recommendation.

Attach **`@docs/specs/<issue>/*.plan.md`** when research and plan already exist **and pass the adequacy checklist** — the EM skips recreating them and enters the **implement phase**. If scope changed (new QA comment, new AC), use **DELTA** / **REFRESH**.

| | Quick Flow | Full Flow |
| --- | --- | --- |
| **Best for** | Narrow bugfixes and small changes (typically ≤3 files, one domain) | Cross-domain work, ambiguity, new modules, architecture changes |
| **Skips** | Full research → plan → plan validation when criteria are met | Nothing — runs the full pipeline below |
| **Path** | Implement → quality checks → `@eversis-review` → **Fine** + QA draft | Research → plan → plan validation → implement → review → **Fine** + QA draft |
| **Hard rule** | — | **Any Figma link or `[REUSE]` UI verification task forces Full Flow** |

Normative criteria and routing live in **`eversis-orchestrating-implementation`** — not duplicated here.

## Full Flow (step-by-step)

The Engineering Manager orchestrates the full cycle: research → plan → plan validation → implement → review.

## Step-by-Step Command Sequence

### 1. Implement

```text
@eversis-implement <JIRA_ID or task description>
# or: /eversis-implement <JIRA_ID or task description>
```

The Engineering Manager automatically handles the full development cycle:

#### Research Phase (internal)

- **When:** Only if Implement readiness shows **Research: CREATE** or **DELTA** (no adequate `*.research.md`, or existing research is stale for current scope).
- **Delegated to:** Context Engineer
- **What it does:** Gathers all available information about the task from the codebase, Jira, Confluence, Figma, and other sources.
- **What it produces:** A `.research.md` file with task summary, assumptions, open questions, and suggested next steps. **DELTA** updates the existing file (Changelog + new section) in the same session.
- **Your action:** Review the generated research document. Verify accuracy. The Engineering Manager asks for confirmation before proceeding.

#### Planning Phase (internal)

- **When:** Only if Implement readiness shows **Plan: CREATE** or **REFRESH** (no actionable plan, or scope changed).
- **Delegated to:** Architect
- **What it does:** Creates a multi-step implementation plan grouped into phases and tasks aligned with your repo structure.
- **What it produces:** A `.plan.md` file with checklist-style phases that can be executed by specialized agents.
- **Your action:** Review the implementation plan. Confirm scope, phases, and acceptance criteria.

#### Plan Validation Phase (internal)

- **Delegated to:** Plan Reviewer
- **What it does:** Stress-tests the plan against the research file, codebase assumptions, feasibility, and project patterns before implementation begins.
- **What it produces:** A `.plan-review.md` file saved alongside the plan in the same `docs/specs/<task-name>/` directory (or `specifications/<task-name>/`).
- **Your action:** Review the implementation plan and review summary together. Confirm the approved plan before implementation begins.

#### Implementation Phase

- **Delegated to:** Software Engineer, Prompt Engineer, DevOps Engineer, E2E Engineer (based on task type)
- **What it does:** Executes the plan by delegating to specialized agents. Tracks progress and runs quality checks after each task.
- **What it produces:** Concrete code modifications applied by delegated agents.
- **Your action:** Review code changes after each phase. Test functionality. Verify against the plan.

:::tip
If `.research.md` and `.plan.md` exist **and pass the adequacy checklist** for the current scope, the Engineering Manager skips that phase. File existence alone is not enough — stale research (e.g. a new QA comment on a different bug) requires **DELTA**. If a `.plan.md` is already approved and unchanged since the last review, the plan validation step is skipped.
:::

:::note Mandatory QA comment draft after Fine
When the Engineering Manager declares **Fine**, it **always produces a QA comment draft in the same response** following the **[Fine Handoff](../skills/fine-handoff)** skill (`eversis-fine-handoff`). Review the draft, edit if needed, then paste it into Jira or ask the agent to post it via Atlassian MCP. See [Workflow Overview](./overview) for how **Fine** fits the lifecycle.
:::

### 2. Review

```text
@eversis-review <JIRA_ID or task description>
# or: /eversis-review <JIRA_ID or task description>
```

- **Agent:** Code Reviewer
- **What it does:** Reviews the final implementation against the plan and requirements. Highlights security, reliability, performance, and maintainability concerns.
- **What it produces:** Structured review with clear pass/blockers/suggestions.
- **Your action:** Review findings and recommendations. Address all blockers before merging.

## Example End-to-End Usage

### Quick Flow (small fix)

```text
1⃣️ @eversis-implement <task description>
   ↳ 🔀 Engineering Manager recommends Quick Flow — you confirm
   ↳ 💻 Delegate implementation → run quality checks
   ↳ 🔍 @eversis-review
   ↳ ✅ Address blockers; Fine + QA comment draft in same response
```

### Full Flow (default for larger work)

```text
1⃣️ /eversis-implement <JIRA_ID or task description>
   ↳ 🔍 Engineering Manager delegates to Context Engineer for research
   ↳ 📖 Review the generated research document
   ↳ ✅ Confirm to proceed to planning
   ↳ 🧱 Engineering Manager delegates to Architect for planning
   ↳ 📖 Review the implementation plan
   ↳ ✅ Confirm scope, phases, and acceptance criteria
   ↳ 🧪 Engineering Manager delegates to Plan Reviewer for plan validation
   ↳ 📖 Review the plan and `.plan-review.md` summary
   ↳ ✅ Confirm the approved plan before implementation begins
   ↳ 💻 Engineering Manager delegates implementation to specialized agents
   ↳ 📖 Review code changes after each phase
   ↳ ✅ Test functionality, verify against plan

2⃣️ /eversis-review   <JIRA_ID or task description>
   ↳ 📖 Review findings and recommendations
   ↳ ✅ Address blockers before merging
```

## Input Flexibility

You can run the same flow with either:

- A **Jira ticket ID** (e.g., `PROJ-123`) — the agent will pull context from Jira automatically via the Atlassian MCP.
- A **free-form task description** (e.g., `"Add pagination to the user list API"`) — the agent will work from the description and codebase analysis.

## Task Labeling: CREATE / MODIFY / REUSE

Every task in an implementation plan is labeled with one of three action types. This helps developers understand the scope and impact of each task at a glance:

| Label | Meaning | Example |
|---|---|---|
| **CREATE** | New code that doesn't exist yet | "Create a new `UserService` class" |
| **MODIFY** | Change existing code | "Update the `getUsers` endpoint to support pagination" |
| **REUSE** | Use existing code as-is, no changes needed | "Reuse the existing `AuthMiddleware` for the new route" |

These labels are assigned during the **Plan** phase by the Architect agent. During the **Implement** phase, the Software Engineer agent uses them to understand what needs to be built from scratch, what needs careful modification of existing logic, and what can be leveraged without changes.
