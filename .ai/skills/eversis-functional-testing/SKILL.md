---
name: eversis-functional-testing
user-invocable: false
description: "Shared QA foundations — severity matrix, bug report template, and test plan templates. Referenced by eversis-planning-tests, eversis-analyzing-regression-risk, and eversis-verifying-acceptance-criteria."
---

# Functional Testing — Shared Foundations

This skill provides shared templates and reference material used across the QA skill family. For specific workflows, use the focused skills listed below.

## Skill Index

| Capability | Skill | Trigger |
|-----------|-------|---------|
| Test plan generation + edge cases | `eversis-planning-tests` | `eversis-qa-workflow plan testing` |
| Regression scope analysis | `eversis-analyzing-regression-risk` | `eversis-qa-workflow regression` |
| AC verification | `eversis-verifying-acceptance-criteria` | `eversis-qa-workflow verify ac` |
| Quality health reports | `eversis-analyzing-bugs` | `eversis-qa-workflow quality health` |
| Accessibility auditing | `eversis-accessibility-auditing` | `eversis-qa-workflow audit accessibility` |

**Not the same as Fine handoff:** `eversis-fine-handoff` runs at the end of Implement (one Jira comment draft). This skill family covers test planning, regression, AC verification, and quality reporting — a separate QA practice layer.

## Severity Matrix

| Severity | Definition | Blocks Release? |
|----------|-----------|-----------------|
| 🔴 **Critical** | Feature is broken/unusable, data loss, or security vulnerability | Yes |
| 🟠 **High** | Major functionality impaired, no workaround available | Should block |
| 🟡 **Medium** | Functionality impaired but a workaround exists | Fix before next release |
| 🔵 **Low** | Cosmetic issue or minor UX inconsistency | Fix when convenient |

> **Note**: For accessibility audit severity, see `eversis-accessibility-auditing` which uses Critical/Serious/Moderate/Minor aligned with axe-core.

## Bug Reporting

When reporting bugs found during testing, use the bug report template at `./examples/bug-report.example.md`. The template structures reports with severity classification, numbered steps to reproduce, actual vs expected behavior, and environment details.

## Templates

This directory contains shared templates referenced by the focused skills (all in `./examples/`):

| Template | Used by |
|----------|---------|
| `test-plan.example.md` | `eversis-planning-tests` |
| `test-cases.example.md` | `eversis-planning-tests`, `eversis-analyzing-regression-risk` |
| `regression-test-suite.example.md` | `eversis-analyzing-regression-risk` |
| `regression-scope.example.md` | `eversis-analyzing-regression-risk` |
| `bug-report.example.md` | All QA skills |
| `test-report.example.md` | QA orchestrator |
