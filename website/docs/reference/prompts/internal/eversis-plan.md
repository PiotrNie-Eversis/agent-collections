---
sidebar_position: 10
title: "Plan"
slug: plan
prompt_role: "Architect"
prompt_description: "Prepare detailed implementation plan for given feature."
upstream_agent: "eversis-architect"
---
# eversis-plan

:::info
Not invoked directly by users. To trigger implementation planning, use the [eversis-implement](../public/implement) public prompt — the [Engineering Manager](../../agents/engineering-manager.md) will automatically delegate to the [Architect](../../agents/architect.md) when a plan is needed.
:::

**Agent:** Architect 
**File:** `.cursor/prompts/internal/eversis-plan.md`

Creates a detailed, phased implementation plan from the research context.

## How It's Triggered

```text
@eversis-implement
<JIRA_ID or task description>
```

In **Cursor**, attach the **Implement** prompt (`eversis-implement`) from the path above; the Engineering Manager delegates to this internal prompt when the workflow requires it.

The Engineering Manager identifies that no implementation plan exists and delegates planning to the Architect automatically.

## What It Does

1. **Analyzes context** — Reviews the `.research.md` file and cross-checks with best practices.
2. **Analyzes tech stack** — Identifies domain-specific best practices.
3. **Verifies current implementation** — Searches the codebase for existing components, functions, and utilities related to the feature.
4. **Persists technical context** — Captures project conventions, standards, and test commands in the plan's **Technical Context** section for downstream implementers.
5. **Designs the solution** — Uses `eversis-architecture-designing` for architecture and trade-offs.
6. **Authors the plan** — Delegates structure, WIG, tasks, and DoD rules to `eversis-creating-implementation-plans`.
7. **Addresses security and scope** — Security considerations, acceptance criteria, and out-of-scope improvements.

## Skills Loaded

- `eversis-architecture-designing` — Architecture design process.
- `eversis-creating-implementation-plans` — Plan template, structure, and definition-of-done rules (`plan.example.md`).
- `eversis-codebase-analysing` — Analyze existing codebase.
- `eversis-implementation-gap-analysing` — Verify what exists vs what needs to be built.
- `eversis-technical-context-discovering` — Understand project conventions and patterns.
- `eversis-sql-and-database-understanding` — When the feature involves database changes.

## Output

A `.plan.md` file placed in `docs/specs/<task-name>/` (or `specifications/<task-name>/`):

```text
docs/specs/
 user-authentication/
 user-authentication.research.md
 user-authentication.plan.md ← new
```

The plan includes Wildly Important Goal, Technical Context, checklist-style phases, tasks with `[CREATE]`/`[MODIFY]`/`[REUSE]` action types, `Files:` per task, acceptance criteria, and security considerations.

After human review of the plan draft, the Engineering Manager delegates plan validation via [`eversis-review-plan.md`](./review-plan).

:::tip
Review the plan thoroughly. Confirm scope, phases, and acceptance criteria before plan validation and implementation.
:::

---

## Executable prompt (attach in Cursor)

Analyze the feature context for the provided task or Jira ID and prepare a detailed implementation plan that a software engineer can follow step by step to deliver the feature.

Use the required skills to understand the feature, design the solution, and author the plan artifact.

The file outcome should be a markdown file named after the task Jira ID in kebab-case format or after task name (if no Jira task provided) with `.plan.md` suffix (e.g., `user-authentication.plan.md`). Place it in `docs/specs/` (or your team's `specifications/` folder) under a folder named after the issue ID or the shortened task name in kebab-case format.

## Required Skills

Before starting, load and follow these skills:

- `eversis-architecture-designing` - for the architecture design process
- `eversis-creating-implementation-plans` - for the plan structure, definition-of-done rules, and output template (`plan.example.md`)
- `eversis-codebase-analysing` - for analyzing the existing codebase
- `eversis-implementation-gap-analysing` - for verifying what exists vs what needs to be built
- `eversis-technical-context-discovering` - for understanding project conventions and patterns
- `eversis-sql-and-database-understanding` - when the feature involves database schema design, data model changes, migrations, or query-heavy implementation

## Workflow

1. **Analyze context**: Review the feature context file (`.research.md`) thoroughly to understand the requirements and scope. Cross-check with industry, domain, and company best practices.
2. **Analyze tech stack**: Understand the project's tech stack, industry, and domain to identify best practices for implementation.
3. **Verify current implementation**: Before planning, perform a thorough analysis of the existing codebase:
 - Use semantic search to find components, functions, hooks, utilities, or files related to the feature requirements.
 - Identify what is already implemented and functional.
 - Identify what exists but needs modification or extension.
 - Identify what needs to be created from scratch.
 - Document findings in the "Current Implementation Analysis" section.
4. **Persist technical context**: During steps 2–3, capture all discovered project conventions, coding standards, architecture patterns, tech stack details, testing patterns, and relevant project rules. Save them in the **"Technical Context"** section of the plan file. This section is critical — downstream implementation agents will read it to avoid redundant codebase analysis. Be thorough: include framework conventions, naming patterns, test commands, linting rules, and any project-specific standards.
5. **Understand project standards**: Review project best practices and quality standards (check `AGENTS.md`, `.cursor/rules/`, and `docs/context/`). Incorporate findings into the "Technical Context" section.
6. **Design the solution architecture using `eversis-architecture-designing`**: Design the solution architecture (components, interactions, data flows, trade-offs) before structuring it into a plan.
7. **Create the implementation plan using `eversis-creating-implementation-plans`**: Delegate ALL plan content to `eversis-creating-implementation-plans`, including task definition, security considerations, UI verification where applicable, the plan save pattern, bug-fix planning, scope control, and duplication avoidance.

In case of any ambiguities or missing information for the planning, ask for clarification before finalizing the plan.

Update the plan file after each interaction if new information is gathered.

<!-- Eversis port; upstream: eversis-plan:v3 -->
