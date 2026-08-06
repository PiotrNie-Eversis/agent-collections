---
sidebar_position: 5
title: Software Engineer
---

# Software Engineer Agent

**Rule pack (canonical template):** `.cursor/rules/eversis-role-software-engineer.mdc` — **not shipped** in agent-collections; behavior via `@eversis-implement` internal delegates.  
**Delegated prompts:** [Implement common task](../prompts/internal/implement-common-task), [Implement UI common task](../prompts/internal/implement-ui-common-task), and related paths composed from **`@eversis-implement`** ([Implement](../prompts/public/implement))

The Software Engineer agent implements software solutions based on provided requirements and technical designs. It executes against implementation plans created by the Architect.

## Responsibilities

- Implementing code changes following the plan step by step.
- Writing clean, efficient, and maintainable code.
- Following best practices and coding standards.
- Adhering to security considerations and quality assurance guidelines from the plan.
- Reviewing own code to ensure it meets requirements.
- Communicating with the Architect when ambiguities arise.

## Key Behaviors

- **Strictly follows the plan** — Does not deviate unless explicitly instructed.
- **No dead code** — Does not create unused functions or future-only code.
- **No unnecessary files** — Focus on delivering required changes efficiently.
- **Well-documented** — Includes comments and documentation for future maintainability.

## Tool Access

| Tool | Usage |
| --- | --- |
| **Atlassian** | Search for task requirements and related context (search only) |
| **Context7** | Search API documentation, find solutions to errors, research best practices |
| **Figma** | Extract design specifications for frontend tasks |
| **Playwright** | Verify UI implementation by interacting with the running application |
| **Sequential Thinking** | Implement complex algorithms, debug issues, plan refactoring |
| **Terminal** | Run build tools, tests, linters, and scripts (`eversis-testing-and-terminal.mdc`) |
| **Cursor Agent** | Read, modify, and search workspace files |
| **Todo** | Track implementation progress with structured checklists |

## Skills Loaded

- [eversis-technical-context-discovering](../skills/technical-context-discovery) — Establish project conventions and patterns before implementing.
- [eversis-implementation-gap-analysing](../skills/implementation-gap-analysis) — Verify what exists vs what needs to be built.
- [eversis-codebase-analysing](../skills/codebase-analysis) — Understand existing architecture for complex features.
- [eversis-implementing-frontend](../skills/frontend-implementation) — Component patterns, composition, design tokens, Figma-to-code workflow.
- [eversis-implementing-forms](../skills/implementing-forms) — Schema validation, field composition, error handling, multi-step form flows.
- [eversis-writing-hooks](../skills/writing-hooks) — Custom hooks: naming, composition, stable returns, effect cleanup, testing.
- [eversis-ensuring-accessibility](../skills/ensuring-accessibility) — WCAG 2.1 AA compliance: semantic HTML, ARIA, keyboard navigation, focus management.
- [eversis-optimizing-frontend](../skills/optimizing-frontend) — Code splitting, memoization, bundle size, rendering optimization, memory management.
- [eversis-ui-verifying](../skills/ui-verification) — Tolerances and structure checklist for Figma verification.
- [eversis-sql-and-database-understanding](../skills/sql-and-database) — SQL queries, database schemas, migrations, ORM patterns.
- [eversis-engineering-prompts](../skills/prompt-engineering) — LLM prompt design: structure patterns, optimization, security, templates.

## Handoffs

After completing implementation, the Software Engineer can hand off to:

- **Code Reviewer** — **`@eversis-review`** ([Review](../prompts/public/review); review implementation against the plan)
- **E2E Engineer** — when the plan delegates test work via [Implement E2E](../prompts/internal/implement-e2e)
