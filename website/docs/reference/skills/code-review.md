---
sidebar_position: 3
title: Code Review
---

# Code Review

**Folder:** `.cursor/skills/eversis-code-reviewing/`  
**Used by:** Code Reviewer

Provides a structured 11-step code review process covering correctness, quality, security, testing, and scalability. Enforces **STRICT FORBIDDEN** scope, documentation, and dependency checks from `eversis-code-reviewer.mdc`.

## 11-Step Review Checklist

1. **Understand the task** — Read research and plan files.
2. **Understand the plan** — Verify implementation matches the planned approach.
3. **Review implementation** — Check correctness, code quality, adherence to standards; flag STRICT FORBIDDEN violations as **BLOCKER**.
4. **Verify tests** — Ensure critical paths are covered (unit, integration, e2e).
5. **Run unit tests** — Execute and verify passing.
6. **Run integration tests** — Execute and verify passing.
7. **Run e2e tests** — Execute and verify passing.
8. **Best practices** — Check SOLID, SRP, DDD, DRY, KISS; flag N+1 queries, in-memory pagination, and missing integration coverage at service boundaries.
9. **Static analysis** — Run linters, formatters, type checks.
10. **Security** — Validate against OWASP TOP10.
11. **Scalability** — Assess horizontal scaling, statelessness, computational complexity.

## Integration test coverage

Treat missing integration coverage as a substantive finding when correctness depends on:

- Real database semantics, transactions, or migrations
- Queues, webhooks, or external service boundaries
- SQL or ORM behavior that unit mocks cannot validate

Unit tests alone are not sufficient for those paths. The reviewer should run integration tests when the project provides them and flag gaps when boundaries are untested.

## Review Focus Areas

| Area | What It Covers |
|---|---|
| **Correctness** | Code functions as intended, meets requirements |
| **Code Quality** | Clean, efficient, maintainable, low cognitive complexity |
| **Security** | OWASP TOP10 validation, no vulnerabilities |
| **Testing** | Critical paths covered; integration tests at real boundaries |
| **Scalability** | Horizontal scaling, statelessness, Big O analysis |
| **Acceptance Criteria** | Each item from the plan verified individually |
| **STRICT FORBIDDEN** | Scope, documentation comments, new dependencies |

## Connected Skills

- `eversis-implementation-gap-analysing` — Compare implementation against the plan.
- `eversis-technical-context-discovering` — Review against project conventions.
- `eversis-sql-and-database-understanding` — Review database-related code quality.
