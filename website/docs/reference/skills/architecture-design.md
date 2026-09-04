---
sidebar_position: 2
title: Architecture Design
---

# Architecture Design

**Folder:** `.cursor/skills/eversis-architecture-designing/`  
**Used by:** Architect

Provides a structured 5-step process for designing solution architecture. Plan authoring is delegated to **`eversis-creating-implementation-plans`** — see [Creating Implementation Plans](./creating-implementation-plans).

## Process

### Step 1: Understand the Business Goal

Analyze the task requirements and business context to ensure the solution addresses the actual problem.

### Step 2: Analyse the Codebase

Use the `eversis-codebase-analysing` and `eversis-implementation-gap-analysing` skills to understand existing architecture and identify what needs to change.

### Step 3: Ask Clarifying Questions

Identify ambiguities and missing information before committing to a design.

### Step 4: Design the Solution

Create the architecture following established patterns and principles.

### Step 5: Author the Plan

Load **`eversis-creating-implementation-plans`** to produce the `.plan.md` artifact using `plan.example.md`. The Plan Reviewer validates the plan via `@eversis-review-plan` before implementation.

## Enforced Patterns

| Category | Patterns |
|---|---|
| **Software Design** | DRY, KISS, DDD, TDD, CQRS, SOLID |
| **Architecture** | Hexagonal, Layered, Modular |
| **UI/UX** | Atomic Design, WCAG |
| **Security** | OWASP TOP10 |

## Connected Skills

- `eversis-creating-implementation-plans` — plan template, structure, and definition-of-done rules
- `eversis-codebase-analysing` — Understand existing architecture.
- `eversis-implementation-gap-analysing` — Focus on necessary changes only.
- `eversis-technical-context-discovering` — Establish project conventions.
- `eversis-sql-and-database-understanding` — Database schema and data model design.
