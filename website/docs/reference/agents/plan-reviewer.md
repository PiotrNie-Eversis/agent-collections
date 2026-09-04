---
sidebar_position: 2
title: Plan Reviewer
---

# Plan Reviewer Agent

**Delegated prompt:** [Review Plan](../prompts/internal/review-plan) (via `@eversis-implement` after the Architect produces or updates a plan)

The Plan Reviewer is an internal role that stress-tests implementation plans before code is written. It challenges the plan for likely failure modes, hidden assumptions, sequencing traps, integration mismatches, migration and data risks, and false confidence in testing.

## Responsibilities

- Stress-testing the plan against the research context to expose likely failure modes.
- Checking that referenced files, functions, classes, integrations, and patterns actually exist in the codebase.
- Surfacing hidden assumptions, sequencing traps, dependency order issues, and migration or data risks.
- Challenging integration boundaries, rework risk, and false confidence in test coverage.
- Producing a structured approval or revision report for the Architect.

## What It Produces

- A failure-oriented review report with a binary verdict (`APPROVED` or `REVISIONS NEEDED`), top risks, assumptions, rework triggers, and any blocking gaps.
- The report is saved as `{task-name}.plan-review.md` alongside the plan in `docs/specs/<task-name>/` (or `specifications/<task-name>/`).

## Tool Access

| Tool | Usage |
| --- | --- |
| Context7 | Verify framework or library assumptions when the plan references them |
| Sequential Thinking | Evaluate trade-offs, phase ordering, and over-engineering risk |
| Cursor Agent | Inspect the plan, research file, rules, and referenced code |

## Skills Loaded

- `eversis-architecture-designing` — Evaluate architectural shape, phase coherence, and trade-offs.
- `eversis-creating-implementation-plans` — Verify plan template, structure, and definition-of-done compliance.
- `eversis-codebase-analysing` — Verify plan references against the actual codebase.
- `eversis-technical-context-discovering` — Check pattern consistency against established conventions.
- `eversis-implementation-gap-analysing` — Compare what exists with what the plan proposes.
- `eversis-sql-and-database-understanding` — When the plan includes database schema, migration, or query changes.

## How It Is Used

- It is not invoked directly by users.
- The Engineering Manager delegates plan validation via `@eversis-review-plan` after the human reviews the plan draft.
- If the reviewer returns `REVISIONS NEEDED`, the plan goes back to the Architect and is re-reviewed until approved or escalated (max 3 iterations).
- Skip validation when `{task-name}.plan-review.md` already has verdict `APPROVED` and the plan file is unchanged.

## Handoffs

- **From** [Architect](./architect) — `.plan.md` ready for validation.
- **To** [Architect](./architect) — when revisions are required.
- **To** [Engineering Manager](./engineering-manager) — when verdict is `APPROVED` and implementation may proceed.
