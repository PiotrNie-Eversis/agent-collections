---
sidebar_position: 8
title: QA Workflow
---

# QA Workflow

Use **`@eversis-qa-workflow`** for **manual QA practice**: test plans, test cases, regression scope, acceptance-criteria verification, bug reports, quality health dashboards, and accessibility audits.

This is a **separate layer** from Implement **Fine handoff** and from **automated E2E**:

| Layer | Prompt | When |
| ----- | ------ | ---- |
| **Fine handoff** | `@eversis-fine-handoff` (via `@eversis-implement`) | End of Implement — mandatory Jira comment **draft** |
| **QA practice** | `@eversis-qa-workflow` | Test planning, regression, AC gaps, quality health |
| **E2E automation** | `@eversis-implement` (E2E tasks) | Playwright test **implementation** |

:::tip Word vs Repo vs QA
- **BA Docs (Word):** `@eversis-ba-docs-planner` / writer — `.docx` only
- **Repo Docs:** `@eversis-repo-docs-writer` — README / `website/docs`
- **QA workflow:** this page — test artifacts and Jira/Confluence delivery
:::

## When to use it

- Before or after delivery: build a test plan from acceptance criteria.
- Before release: regression scope from a ticket or sprint.
- During verification: AC gap table against implementation.
- Ongoing: quality health report from Jira bug history.
- Compliance: accessibility audit (WCAG 2.2 AA) on a URL or flow.

## Quick flows

```text
@eversis-qa-workflow plan testing PROJ-123
@eversis-qa-workflow test cases PROJ-123
@eversis-qa-workflow regression PROJ-123
@eversis-qa-workflow verify ac PROJ-123
@eversis-qa-workflow report bug
@eversis-qa-workflow test report PROJ-123
@eversis-qa-workflow quality health PROJ
@eversis-qa-workflow audit accessibility https://example.com/settings
```

Without a keyword, the agent runs the **full phased workflow** with checkpoints.

## Skills loaded (on demand)

| Skill | Purpose |
| ----- | ------- |
| [eversis-planning-tests](../skills/planning-tests) | Test plans and test cases |
| [eversis-analyzing-regression-risk](../skills/analyzing-regression-risk) | Regression scope and suites |
| [eversis-verifying-acceptance-criteria](../skills/verifying-acceptance-criteria) | AC verification table |
| [eversis-analyzing-bugs](../skills/analyzing-bugs) | Quality health from Jira |
| [eversis-accessibility-auditing](../skills/accessibility-auditing) | WCAG audit reports |
| [eversis-functional-testing](../skills/functional-testing) | Shared templates and severity matrix |

## AC completeness gate

If acceptance criteria are missing or too vague to test, the workflow **stops** and points to **`@eversis-analyze-materials`** for backlog refinement — QA does not invent AC.

## Delivery

Artifacts can go to **chat**, **local files**, **Jira** (description or comment), or **Confluence**. When using Jira/Confluence, enable **Atlassian MCP** and confirm delivery with real issue keys or page links from tool responses.

## Connecting to other flows

```text
@eversis-analyze-materials  →  (refined AC)
@eversis-implement          →  code + @eversis-fine-handoff at Fine
@eversis-qa-workflow        →  test plan / regression / AC verify
@eversis-review             →  structured code review (separate from QA practice)
```

:::warning Important
QA workflow output is a **draft** until humans approve. Do not treat Go/No-Go or audit reports as sign-off without human review.
:::
