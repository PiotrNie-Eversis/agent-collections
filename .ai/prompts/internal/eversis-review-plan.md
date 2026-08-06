---
sidebar_position: 11
title: "Review Plan"
slug: review-plan
prompt_role: "Plan Reviewer"
prompt_description: "Stress-test an implementation plan before coding begins."
upstream_agent: "eversis-plan-reviewer"
---
# eversis-review-plan

:::info
Not invoked directly by users. To trigger plan validation, use [eversis-implement](../public/eversis-implement.md) — the Engineering Manager delegates to the Plan Reviewer after the Architect produces or updates a plan (unless an approved `.plan-review.md` already exists and the plan is unchanged).
:::

**Agent:** Plan Reviewer 
**File:** `.ai/prompts/internal/eversis-review-plan.md`

Stress-tests implementation plans for likely failure modes, hidden assumptions, and costly rework before code is written.

## How It's Triggered

```text
eversis-implement
<JIRA_ID or task description>
```

The Engineering Manager attaches this internal prompt after the Architect creates or updates a `.plan.md` file and the human has reviewed the plan draft. Skip when `{task-name}.plan-review.md` exists with verdict `APPROVED` and the plan file is unchanged since that review.

## What It Does

1. Reads the research file first so the review stays grounded in requirements.
2. Reads the plan and checks phases, tasks, Technical Context, and definitions of done.
3. Runs challenge-domain, failure-mode, assumption, codebase-reality, and sequencing passes.
4. Surfaces substantive execution risks (target 5–10 when evidence supports them).
5. Saves a failure-oriented review report with binary verdict `APPROVED` or `REVISIONS NEEDED`.
6. On `REVISIONS NEEDED`, returns findings to the Architect for revision (max **3** review iterations, then escalate to the human).

## Skills Loaded

- `eversis-architecture-designing` — Evaluate architectural shape, phasing, and trade-offs.
- `eversis-creating-implementation-plans` — Verify plan template, structure, and definition-of-done rules.
- `eversis-codebase-analysing` — Verify plan references against actual codebase state.
- `eversis-technical-context-discovering` — Check pattern consistency against established conventions.
- `eversis-implementation-gap-analysing` — Validate what exists vs what the plan proposes.
- `eversis-sql-and-database-understanding` — When the plan includes schema, migration, indexing, or query changes.

## Output

A `.plan-review.md` file in `docs/specs/<task-name>/` (or your team's `specifications/<task-name>/`) alongside the plan.

---

## Executable prompt (attach in Cursor)

Stress-test the implementation plan for the provided task. Assume the architect likely produced a basically correct plan, then look for the strongest reasons it could still fail in implementation, create expensive rework, or give false confidence. The primary deliverable is the full structured review document saved as `{task-name}.plan-review.md` alongside the plan in the same specifications directory (`docs/specs/<task-name>/` or `specifications/<task-name>/`).

## Required Skills

Before starting, load and follow these skills:

- `eversis-architecture-designing` — evaluate whether the proposed shape, phasing, and trade-offs are likely to fail in execution or create costly rework
- `eversis-creating-implementation-plans` — verify the plan complies with the owned plan template, structure, and definition-of-done rules
- `eversis-codebase-analysing` — verify critical references, dependencies, and abstractions against actual codebase state
- `eversis-technical-context-discovering` — check repo conventions or established abstractions only when they materially affect execution risk
- `eversis-implementation-gap-analysing` — validate what exists vs what the plan assumes must already be available
- `eversis-sql-and-database-understanding` — when the plan includes schema changes, migrations, data backfills, indexing, or query risks

## Challenge Domains

You MUST actively probe every domain on every review, even when the conclusion is that no issue was detected:

- **Technology and stack decisions** — choices that differ from research context, prior iterations, team expertise, or established project patterns
- **Irreversible or high-cost decisions** — database engine, primary framework, deployment model, vendor lock-in, data model shape
- **Contradictions with research or prior context** — deviations from research or established direction without explicit justification
- **Scope gaps and silent omissions** — requirements from research with no tasks, flows mentioned but not planned
- **Cross-cutting decisions that propagate** — auth model, API contract shape, state management, shared code strategy, CI/CD assumptions
- **Build vs buy vs reuse** — building from scratch when libraries exist, or new dependencies when project patterns already solve the problem

## Workflow

1. **Read the research file** (`.research.md`) — understand requirements, acceptance criteria, and constraints the plan must address.

2. **Read the plan file** (`.plan.md`) — understand architecture, phases, tasks, and definitions of done. Stop immediately if any row in `## Open Questions` has Status = `❓ Open`; this is a blocker and review cannot proceed until the architect resolves it.

3. **Challenge-domains pass** — For each challenge domain above, explicitly state whether an issue was found or not. Pay special attention to technology/stack choices that deviate from research context or prior iterations.

4. **Failure-modes pass** — Find the strongest reasons the plan may fail during implementation or cause major rework. Prioritize integration mismatches, unsafe migrations, coordination traps, weak rollout strategies, and brittle task breakdowns.

5. **Hidden-assumptions pass** — Identify assumptions unproven in this repository (files, abstractions, contracts, environment behavior, team coordination, data shape).

6. **Codebase-reality pass** — For every critical file, component, function, class, abstraction, or dependency the plan relies on: search the codebase, read the file, and flag references that do not match reality.

7. **Sequencing-and-feasibility pass** — Identify order-of-operations traps, risky migrations, rollback gaps, coordination issues, and test or rollout blind spots.

8. **Execution-critical decision gate** — Before final verdict, check for unresolved provider, vendor, stack, framework, auth, privacy, security, integration-contract, or migration-prerequisite decisions on the critical path.

9. **Decision-and-revision-history handling** — Always build and maintain a `Decision and Revision History` section as a compact chronological Markdown table (oldest to newest), including on the first review iteration. On later iterations, read the existing `.plan-review.md` first and update the table. Prefer appending new rows; keep cells phrase-length.

10. **Produce the report and binary verdict** — Save the full failure-oriented review report with final verdict (`APPROVED` or `REVISIONS NEEDED`) as `{task-name}.plan-review.md` in the same specifications directory as the plan.

## Review Requirements

- Target 5–10 substantive findings when the evidence supports them; if fewer are found, state why the plan appears unusually robust.
- Attribute at least 2–3 findings to the challenge-domains pass when the evidence supports them.
- Do not pad the report with cosmetic, wording, or style-only notes.
- Flag any `❓ Open` item in the plan's `## Open Questions` table as a blocker.
- Treat unexplained deviations from research context or prior established direction as likely `BLOCKERS` until justified.
- Never modify the plan — only produce review reports.
- Never approve a plan with unresolved `BLOCKER` findings or execution-critical open decisions.

<output-specification>
Save the full structured review report as `{task-name}.plan-review.md` alongside the plan. Structure:

- `# Plan Review: {plan-file-name}`
- Reviewed plan path, research file path, review date, and verdict (`APPROVED` or `REVISIONS NEEDED`)
- Summary counts for blockers, warnings, and suggestions
- `Challenge Domains` — one entry per domain with finding or explicit `no issue` note
- `Decision and Revision History` — compact Markdown table: `Date`, `Iteration`, `Decision / Topic`, `Problem / Challenge`, `Plan Decision / Change`, `Status`
- `Top Failure Modes`
- `Unproven Assumptions`
- `Most Likely Rework Triggers`
- `Questions the Architect Must Answer Before Coding`
- Findings grouped under `BLOCKERS`, `WARNINGS`, and `SUGGESTIONS`
- `Verdict` — `APPROVED` or `REVISIONS NEEDED`
</output-specification>

See also `.ai/skills/eversis-creating-implementation-plans/plan-review.example.md` for a skeleton (or MCP `eversis_skills_get` for `eversis-creating-implementation-plans`).

<!-- Eversis port; upstream: eversis-review-plan:v2 -->
