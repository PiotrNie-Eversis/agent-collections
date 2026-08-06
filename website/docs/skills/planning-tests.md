---
sidebar_position: 36
title: Planning Tests
---

# Planning Tests

**Folder:** `.cursor/skills/eversis-planning-tests/`  
**Used by:** [`@eversis-qa-workflow`](../workflow/qa-workflow) — phases 1–2 (test plan, test cases)

Generates structured test plans and executable test cases from acceptance criteria, with edge-case detection and environment matrix coverage.

## Connected skills

- `eversis-functional-testing` — templates (`test-plan.example.md`, `test-cases.example.md`)
- `eversis-verifying-acceptance-criteria` — AC gap analysis after implementation
- `eversis-analyzing-regression-risk` — regression scope (phase 3)

## AC gate

If acceptance criteria are missing or untestable, stop and redirect to `@eversis-analyze-materials` — QA does not invent AC.
