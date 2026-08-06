---
sidebar_position: 6
title: Code Reviewer
---

# Code Reviewer Agent

**Rule pack (canonical template):** `.cursor/rules/eversis-role-code-reviewer.mdc`  
**In this repository:** attach **`.cursor/rules/eversis-code-reviewer.mdc`** when running **`@eversis-review`** (docs: [Review](../prompts/public/review)).

The Code Reviewer agent performs structured code reviews against the implementation plan, requirements, and project standards.

## Responsibilities

- Verifying code **correctness** — functions as intended, meets requirements.
- Checking **code quality** — clean, efficient, maintainable, follows standards.
- Identifying **security** vulnerabilities and verifying proper security measures.
- Verifying **testing** — appropriate tests covering necessary scenarios.
- Ensuring **documentation** — well-documented code with comments.
- Checking **acceptance criteria** — verifying each item from the plan's checklist.

## Review Process

1. Read coding guidelines from **`.cursor/rules/`** (especially `eversis-project-stack.mdc`), **`AGENTS.md`**, and `docs/context/` / `docs/specs/` when present.
2. Understand project coding standards and best practices.
3. Load relevant **Eversis** skills for the review domain.
4. Run all necessary checks and tests (tests, lint, typecheck as appropriate; see `eversis-testing-and-terminal.mdc`).
5. Produce a structured review with findings categorized by severity (**PASS / BLOCKER / SUGGESTION** or equivalent).

## What It Produces

A structured review containing:

- **Pass/Blocker/Suggestion** classification for each finding.
- Acceptance criteria verification (each item checked individually).
- Security, reliability, performance, and maintainability analysis.
- Recommended actions for each blocker.

## Tool Access

| Tool | Usage |
| --- | --- |
| **Atlassian** | Verify requirements and context from Jira or Confluence |
| **Context7** | Verify framework API usage, check for known vulnerabilities |
| **Figma** | Verify frontend implementation matches visual designs |
| **Sequential Thinking** | Analyze complex security vulnerabilities, performance bottlenecks, race conditions |
| **Terminal** | Run tests, linters, and build commands for verification |
| **Cursor Agent** | Read, modify, and search workspace files; navigate the diff |
| **Todo** | Track review progress with structured checklists |

## Skills Loaded

- [eversis-code-reviewing](../skills/code-review) — Structured review process covering correctness, quality, security, testing, and scalability.
- [eversis-reviewing-frontend](../skills/reviewing-frontend) — Frontend-specific review: component quality, hooks correctness, rendering, accessibility and performance spot-checks.
- [eversis-implementation-gap-analysing](../skills/implementation-gap-analysis) — Compare implementation against the plan and verify completeness.
- [eversis-technical-context-discovering](../skills/technical-context-discovery) — Understand project conventions and patterns.
- [eversis-sql-and-database-understanding](../skills/sql-and-database) — Review database-related code for SQL quality, indexes, migrations, and ORM usage.
- [eversis-engineering-prompts](../skills/prompt-engineering) — Review LLM prompt code: injection defenses, delimiter separation, output format specification, prompt file and LLM client usage patterns.

## Handoffs

After review, the Code Reviewer can hand off to:

- **Software Engineer** / **Engineering Manager** — **`@eversis-implement`** ([Implement](../prompts/public/implement); implement changes requested after code review). See [Software Engineer](./software-engineer) and [Engineering Manager](./engineering-manager).
