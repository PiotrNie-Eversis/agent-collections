---
name: eversis-architecture-designing
description: Design the architecture to solve a given task. Propose the solutions to be used to deliver the task following the best practices and standards.
---

# Architecture Design

This skill helps you design the architecture that follows best practices and solves the actual business goal.

## Architecture Design Process

Use the checklist below and track your progress:

```
Analysis progress:
- [ ] Step 1: Understand the goal of the task
- [ ] Step 2: Analyse the current codebase
- [ ] Step 3: Ask questions about ambiguous parts
- [ ] Step 4: Design a solution
- [ ] Step 5: Author the implementation plan (via eversis-creating-implementation-plans)
```

**Step 1: Understand the goal of the task**
Thoroughly process the conversation history and task `*.research.md` file to fully understand the business goal of the task.

If the task or research file references PDF documents (technical specifications, API documentation, architecture documents, compliance requirements), use the `pdf-reader` tool to extract and review their content.

**Step 2: Analyse the current codebase**
Perform a current codebase analysis to get a full picture of a current system in a context of the task.
Make sure to understand the project and domain best practices.

**Step 3: Ask questions about ambiguous parts**
After getting a full picture of the codebase and the task, ask any remaining questions.
Don't continue until you get all of the answers.

**Step 4: Design a solution**
Based on your findings design a solution architecture.

Follow the best security and software design patterns.

Your goal is to design a solution that is not over-engineered and easy to comprehend by developers, that is at the same time scalable, secure and easy to maintain.

The example patterns you should check (but you are not limited to only use those):

- Don't repeat yourself
- Keep It Simple Stupid
- Domain Driven Design
- Test Driven Design
- Modular Architecture / Hexagonal Architecture / Layered Architecture
- Queue / Messaging systems
- Single Responsibility
- CQRS

Make sure to follow the best UI/UX patterns:

- Atomic Design
- Accessibility patterns (WCAG)

Make sure to follow security best practices like OWASP TOP10

The design has to meet quality assurance criteria, meaning it has to be fully tested using combination of e2e, unit and integration tests.

Don't duplicate any work.

Use `eversis-implementation-gap-analysing` to verify what was already implemented and what should be added. Feed findings into the plan's Current Implementation Analysis section.

**Step 5: Author the implementation plan**

Do **not** duplicate plan-structure rules here. Load and follow **`eversis-creating-implementation-plans`** for:

- Wildly Important Goal, Technical Context, phased tasks, `Files:` per task, Stop Rules, and runnable DoD commands
- Mandatory code review, UI verification, and prompt-engineering cross-cutting tasks
- Saving the plan with `plan.example.md` under `docs/specs/<key>-<topic>/` (or `specifications/<key>-<topic>/`) as `<key>-<topic>.plan.md`. The topic is at most three hyphen-separated words.

After the plan is saved, it is stress-tested by the Plan Reviewer via [`eversis-review-plan.md`](../../../.ai/prompts/internal/eversis-review-plan.md) before implementation begins.

## Terminal and implementation boundaries

The Architect role is **design-only**. During architecture design and plan authoring:

- **Do** use read-only inspection — file search, codebase analysis skills, MCP reads (Jira, Figma, PDF, Context7).
- **Do not** run build, test, lint, typecheck, or deployment commands from the Architect turn — those belong to implementers and the Code Reviewer per the plan's verification phases.
- **Do not** edit application source code — only research/plan artifacts under `docs/specs/<key>-<topic>/` (or `specifications/<key>-<topic>/`).
- **Do** specify which fast checks and full test suites each plan phase and the final review phase should run; delegate execution to `eversis-implement` and `eversis-review`.

This prevents the Architect from implementing or validating code during planning while still producing runnable DoD commands in the plan.

## Connected Skills

- `eversis-creating-implementation-plans` — owns plan template, structure, and definition-of-done rules
- `eversis-codebase-analysing` - for analyzing the existing architecture, components, and patterns
- `eversis-implementation-gap-analysing` - for verifying what was already implemented and what should be added
- `eversis-technical-context-discovering` - for establishing project conventions and existing patterns before designing
- `eversis-sql-and-database-understanding` - for designing database schemas, data models, normalisation strategies, and indexing as part of the solution architecture
