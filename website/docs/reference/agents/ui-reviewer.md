---
sidebar_position: 5
title: UI Reviewer
---

# UI Reviewer Agent

**Rule pack (canonical template):** `.cursor/rules/eversis-role-ui-reviewer.mdc` — **not shipped** in agent-collections; behavior via `@eversis-review-ui`.  
**Primary prompt:** `@eversis-review-ui` (docs: [Review UI](../prompts/public/review-ui))

The UI Reviewer performs **read-only** verification comparing implemented UI against **Figma** designs and reports differences. It can be run **directly** by a user (attach **`@eversis-review-ui`**) or **during the UI implementation loop** with the [Software Engineer](./software-engineer). It does **not** fix product code.

## Responsibilities

- Getting the **EXPECTED** design state from Figma via the Figma MCP.
- Getting the **ACTUAL** implementation state from the running app via Playwright.
- Comparing both using measured data — never by reading code or comparing mentally.
- Producing a structured report with differences found following the verification order.
- Reporting tool failures transparently with LOW confidence when data is incomplete.

## Verification areas

| Category | Checks |
| --- | --- |
| **Structure** | Containers, nesting, grouping |
| **Dimensions** | Width, height, spacing, gaps |
| **Visual** | Typography, colors, radii, shadows, backgrounds |
| **Components** | Correct variants, tokens, states |

## Workflow

1. Extract design specifications from Figma (`fileKey` + `nodeId` from URL).
2. Capture current implementation state via Playwright (accessibility tree and screenshots).
3. Compare expected vs actual values.
4. Produce a **PASS/FAIL** report with a difference table showing exact values.

:::info Read-only
The UI Reviewer never modifies code. It only reports differences so the [Software Engineer](./software-engineer) (via **`@eversis-implement`** — [Implement](../prompts/public/implement) — and [Implement UI](../prompts/internal/implement-ui)) can fix them. When called in a loop, each pass is independent.
:::

## Tool Access

| Tool | Usage |
| --- | --- |
| **Context7** | Look up design system documentation and UI library guidelines |
| **Figma** | Get EXPECTED design state — spacing, typography, colors, dimensions |
| **Playwright** | Get ACTUAL implementation state — accessibility tree and screenshots |
| **Sequential Thinking** | Analyze complex layout discrepancies, evaluate tolerance decisions |
| **Terminal** | Run commands to verify application state |
| **Cursor Agent** | Read supporting code paths when required |
| **Todo** | Track verification progress with structured checklists |

## Skills Loaded

- [eversis-ui-verifying](../skills/ui-verification) — Verification criteria, structure checklist, severity definitions, and tolerances.

## Handoffs

After verification, the UI Reviewer can hand off to:

- **Software Engineer** — **`@eversis-implement`** ([Implement](../prompts/public/implement); start UI implementation according to the plan).
- **Software Engineer** — **`@eversis-implement`** ([Implement](../prompts/public/implement); implement UI fixes based on the verification report).
- **Code Reviewer** — **`@eversis-review`** ([Review](../prompts/public/review); proceed to code review if PASS).
