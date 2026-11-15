---
sidebar_position: 2
title: Standard Flow
---

# Standard Flow

The standard workflow is used for backend and fullstack tasks. The Engineering Manager orchestrates delivery via **Quick Flow** or **Full Flow** (see [Orchestrating Implementation](../../reference/skills/orchestrating-implementation)).

## Quick Flow vs Full Flow

At the start of `@eversis-implement`, the Engineering Manager inspects existing specs and outputs the **Implement readiness** block as the **first content** — four required lines (Flow / Research / Plan / Next gate) plus optional `Resume`, `Context`, and `Reason` (the orchestration skill is the norm for any further optional line, including `Audit`) — then assesses complexity and **recommends Quick or Full in chat**. You may override the recommendation.

Attach **`@docs/specs/<key>-<topic>/<key>-<topic>.plan.md`** when research and plan already exist **and pass the adequacy checklist** — the EM skips recreating them and enters the **implement phase**. If scope changed (new QA comment, new AC), use **DELTA** / **REFRESH**.

| | Quick Flow | Full Flow |
| --- | --- | --- |
| **Best for** | Narrow bugfixes and small changes (typically ≤3 files, one domain) | Cross-domain work, ambiguity, new modules, architecture changes |
| **Skips** | Full research → plan → plan review when criteria are met | Nothing — runs the full pipeline below |
| **Path** | Implement → quality checks → code review (same run) → **Fine** + QA draft | Research → approve research → plan → plan review → approve plan → implement → code review (same run) → **Fine** + QA draft |
| **Hard rule** | — | **Any Figma link or `[REUSE]` UI verification task forces Full Flow** |

Normative criteria and routing live in **`eversis-orchestrating-implementation`** — not duplicated here.

## Full Flow (step-by-step)

The Engineering Manager orchestrates the full cycle: research → approve research → plan → plan review → approve plan → implement → code review (same run) → **Fine** + QA draft.

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
- **What it does:** Gathers all available information about the task from the codebase, Jira, Confluence, Figma, `docs/context/` (durable domain knowledge — see [Domain Context (SSOT)](../../domain-context)), and other sources.
- **What it produces:** A `.research.md` file with task summary, assumptions, open questions, and suggested next steps. **DELTA** updates the existing file (Changelog + new section) in the same session.
- **Your action:** Review the generated research document. Verify accuracy. The Engineering Manager asks for confirmation before proceeding.

#### Planning Phase (internal)

- **When:** Only if Implement readiness shows **Plan: CREATE** or **REFRESH** (no actionable plan, or scope changed).
- **Delegated to:** Architect
- **What it does:** Creates a multi-step implementation plan grouped into phases and tasks aligned with your repo structure.
- **What it produces:** A `.plan.md` file with checklist-style phases that can be executed by specialized agents.
- **Your action:** The plan is shown to you after plan review (next block). Review the plan and the review summary together and approve them in one step. Confirm scope, phases, and acceptance criteria.

#### Plan Review Phase (internal)

- **Delegated to:** Plan Reviewer
- **What it does:** Stress-tests the plan against the research file, codebase assumptions, feasibility, and project patterns before you see it. Plan review stops the run only on blockers; warnings and unproven assumptions are listed in the review summary.
- **What it produces:** A `<key>-<topic>.plan-review.md` file saved alongside the plan in the same `docs/specs/<key>-<topic>/` directory (or `specifications/<key>-<topic>/`).
- **Then:** You approve the plan together with the review summary. This is the one plan approval gate, after plan review; implementation starts right after it. If you ask for changes, the plan goes back through plan review, and you see what changed and approve again. Outside that, the agent asks again only when your approval is missing or the plan changed after you approved it.

#### Implementation Phase

- **Delegated to:** Software Engineer, Prompt Engineer, DevOps Engineer, E2E Engineer (based on task type)
- **What it does:** Executes the plan by delegating to specialized agents. Tracks progress and runs quality checks after each task.
- **What it produces:** Concrete code modifications applied by delegated agents.
- **Optional:** You can check code changes after each phase; the run does not wait for you. Code review runs next in the same run, then Fine.

#### Review Phase (internal)

- **Delegated to:** Code Reviewer — in the same run, in a separate context from the one that wrote the code.
- **What it does:** Reviews the implementation against the plan and requirements. Highlights security, reliability, performance, and maintainability concerns.
- **On BLOCKER:** The Engineering Manager asks you before changing the reviewed solution, routes the fix, then re-runs a full review.
- **On PASS:** The Engineering Manager declares **Fine** and writes the QA comment draft in the same response.

:::tip
If `.research.md` and `.plan.md` exist **and pass the adequacy checklist** for the current scope, the Engineering Manager skips that phase. File existence alone is not enough — stale research (e.g. a new QA comment on a different bug) requires **DELTA**. If the `.plan-review.md` verdict is `APPROVED`, or `REVISIONS NEEDED` with no BLOCKER finding, and the plan is unchanged since that review, the plan review step is skipped.
:::

:::note Mandatory QA comment draft after Fine
When the Engineering Manager declares **Fine**, it **always produces a QA comment draft in the same response** following the **[Fine Handoff](../../reference/skills/fine-handoff)** skill (`eversis-fine-handoff`). Review the draft, edit if needed, then paste it into Jira or ask the agent to post it via Atlassian MCP. When there is a promotion candidate, Fine also drafts a domain-knowledge promotion for `docs/context/<project>/`, and when that candidate has `confluence_url`, an As-Is Pack comment as well — see [Workflow Overview](./overview#status-fine--handoff) for the full set.
:::

### Optional: standalone review

```text
@eversis-review <JIRA_ID or task description>
# or: /eversis-review <JIRA_ID or task description>
```

Code review already runs inside `@eversis-implement`, so you do not need this step to finish a normal run. Use it for a review-only chat or a re-review. If you say `pause before review` or `review later` during Implement, the run stops after implementation and quality checks; you then run `/eversis-review` yourself.

- **Agent:** Code Reviewer
- **What it does:** Reviews the final implementation against the plan and requirements. Highlights security, reliability, performance, and maintainability concerns.
- **What it produces:** Structured review with clear pass/blockers/suggestions.

## Example End-to-End Usage

### Quick Flow (small fix)

```text
1⃣️ @eversis-implement <task description>
   ↳ 🔀 Engineering Manager recommends Quick Flow — you confirm
   ↳ 💻 Delegate implementation → run quality checks
   ↳ 🔍 Code review in the same run
   ↳ 🔧 On BLOCKER: the agent asks before changing, fixes, then reviews again
   ↳ 🏁 PASS → Fine + QA comment draft in the same response
```

### Full Flow (default for larger work)

```text
1⃣️ /eversis-implement <JIRA_ID or task description>
   ↳ 🔍 Engineering Manager delegates to Context Engineer for research
   ↳ 📖 Review the generated research document
   ↳ ✅ Approve research
   ↳ 🧱 Engineering Manager delegates to Architect for planning
   ↳ 🧪 Engineering Manager delegates to Plan Reviewer for plan review
   ↳ 📖 Review the plan and the `.plan-review.md` summary together
   ↳ ✅ Approve plan
   ↳ 💻 Engineering Manager delegates implementation to specialized agents, with quality checks after each task
   ↳ 🔍 Code review in the same run
   ↳ 🔧 On BLOCKER: the agent asks before changing, fixes, then reviews again
   ↳ 🏁 PASS → Fine + QA comment draft in the same response

Optional: /eversis-review <JIRA_ID or task description> for a review-only chat or a re-review
   (or say `pause before review` / `review later` to stop Implement before code review)
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
