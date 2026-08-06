---
sidebar_position: 3
title: Creating Implementation Plans
---

# Creating Implementation Plans

**Folder:** `.cursor/skills/eversis-creating-implementation-plans/`  
**Used by:** Architect via [`eversis-plan`](../prompts/internal/plan); consulted by Plan Reviewer via [`eversis-review-plan`](../prompts/internal/review-plan)

Turns a designed solution into a phased, verifiable implementation plan.

## Process

### Step 1: Confirm Inputs

Start from a designed solution, usually produced by `eversis-architecture-designing`, plus task research and any supporting context. Do not redesign the solution here.

### Step 2: Define the Wildly Important Goal

State one explicit Wildly Important Goal for the whole plan as a single sentence, plus an explicit Success Measure and a Do NOT touch / do NOT add list of non-goals to curb scope creep. Add a short description of the overall approach.

### Step 3: Break the Work into Phases

Divide the work into small phases. Each phase needs a Goal, a Description, a `**Verification:**` field listing the exact fast-running commands to run after the phase completes, and tasks with checkboxes. Source commands from Technical Context — never assume Node/npm by default.

### Step 4: Define Each Task

Give every task a Description, a `**Files:**` field, a Definition of Done checklist, optional `**Stop Rule:**`, and optional Clues. Label each file `create`, `modify`, or `reuse`. When a file was produced in an earlier task, add an inline back-reference such as `(modify — created in Task 1.1)`.

### Step 5: Add Mandatory Cross-Cutting Tasks

Include the required shared tasks for code review, UI verification, and prompt engineering when those domains apply.

### Step 6: Save the Plan Using the Template

Write the plan as a document that follows `plan.example.md` exactly. Do not add or remove sections from the template.

## Key Rules

| Area | Rule |
| --- | --- |
| Goal hierarchy | One Wildly Important Goal per plan, with Success Measure and Do NOT touch / do NOT add list. Every phase has Goal, Description, and `**Verification:**`. Every task has Description, `**Files:**`, DoD, and optional Clues. |
| Technical Context | Persist project conventions, test commands, and patterns during planning so implementers do not re-discover them. |
| Definition of Done | Each task's DoD must include at least one reviewer-verifiable check — preferably a runnable command from Technical Context. No deployment steps or manual QA. |
| No real code | No production implementation bodies. Seam artifacts (types, signatures, DTOs) are allowed to clarify contracts. |
| Open-questions gate | No dispatch while any `## Open Questions` row has Status `❓ Open`. |
| Mandatory cross-cutting tasks | End with code review via `@eversis-review`. Add `[REUSE]` UI verification for Figma-based UI via `@eversis-review-ui`, and prompt engineering tasks when LLM prompts are in scope. |

## Templates

- [`plan.example.md`](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/.cursor/skills/eversis-creating-implementation-plans/plan.example.md) — canonical plan structure
- [`plan-review.example.md`](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/.cursor/skills/eversis-creating-implementation-plans/plan-review.example.md) — plan review report skeleton

## Connected Skills

- `eversis-architecture-designing` — designs the solution this skill turns into a plan
- `eversis-implementation-gap-analysing` — verifies what was already implemented before planning new work
- `eversis-technical-context-discovering` — populates the plan's Technical Context section
