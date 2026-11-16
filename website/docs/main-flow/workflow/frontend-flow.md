---
sidebar_position: 3
title: Frontend Flow
---

# Frontend Flow

For UI-heavy tasks with Figma designs, use the specialized frontend workflow. This extends the standard flow with iterative Figma verification to ensure the implementation matches the design within tolerance.

:::warning Full Flow required
Any Figma involvement or `[REUSE]` UI verification task **disqualifies Quick Flow**. The Engineering Manager must run **Full Flow** (research → approve research → plan → plan review → approve plan → implement with per-item UI verification → code review → Fine).
:::

## Command Sequence

```text
1️⃣ @eversis-implement <JIRA_ID or task description>  (or /eversis-implement)
   ↳ 🔀 Engineering Manager recommends Full Flow (Figma/UI — Quick not allowed)
   ↳ 🔍 Engineering Manager delegates to Context Engineer for research
   ↳ 📖 Review research doc – verify Figma links, requirements
   ↳ ✅ Approve research
   ↳ 🧱 Engineering Manager delegates to Architect for planning
   ↳ 🧪 Engineering Manager delegates to Plan Reviewer via @eversis-review-plan for plan review
   ↳ 📖 Review the plan and review summary – check component breakdown, design references
   ↳ ✅ Approve plan — plan and review summary together
   ↳ 💻 Engineering Manager delegates UI tasks to Software Engineer
   ↳ 🔄 Engineering Manager calls /eversis-review-ui in a loop until PASS or escalation
   ↳ 📖 You can check the UI Verification Summary and the UI in the browser (optional; the run does not wait)
   ↳ 🔍 Code review in the same run – code quality, a11y, performance
   ↳ 🔧 On BLOCKER: the agent asks before changing, fixes, then reviews again
   ↳ 🏁 PASS → Fine + QA comment draft

Optional: @eversis-review <JIRA_ID or task description> (or /eversis-review) for a review-only chat or a re-review
   (or say `pause before review` / `review later` to stop Implement before code review)
```

:::note Mandatory QA comment draft after Fine
When the Engineering Manager declares **Fine**, it **always produces a QA comment draft in the same response** following the **[Fine Handoff](../../reference/skills/fine-handoff)** skill (`eversis-fine-handoff`). Review the draft, edit if needed, then paste it into Jira or ask the agent to post it via Atlassian MCP. When there is a promotion candidate, Fine also drafts a domain-knowledge promotion for `docs/context/<project>/`, and when that candidate has `confluence_url`, an As-Is Pack comment as well — more context: [Workflow Overview](./overview#status-fine--handoff).
:::

## How the Verification Loop Works

1. The Engineering Manager delegates a UI component implementation to the Software Engineer via the internal `/eversis-implement-ui` prompt.
2. After the Software Engineer completes, the Engineering Manager calls `/eversis-review-ui` to perform **single-pass verification** (read-only).
3. `/eversis-review-ui` uses **Figma MCP** (EXPECTED) + **Playwright MCP** (ACTUAL) → returns PASS or FAIL with diff table.
4. If FAIL → the Engineering Manager delegates the fix to the Software Engineer and calls `/eversis-review-ui` again.
5. Repeats until PASS or max **5 iterations** (then escalates to the developer).

## What `/eversis-review-ui` Does

- Single-pass, **read-only** verification — does not modify code.
- Uses **Figma MCP** to extract design specifications (spacing, typography, colors, dimensions).
- Uses **Playwright MCP** to capture the current implementation state.
- Returns a structured report: **PASS/FAIL** + difference table with exact values.
- Covers: structure (containers, nesting), dimensions (width, height, spacing), visual (typography, colors, radii), and components (variants, tokens, states).

## What `/eversis-implement-ui` Does

:::info Internal Prompt
`/eversis-implement-ui` is an internal prompt — not invoked directly by users. It is triggered automatically by `/eversis-implement` when the plan contains UI tasks with Figma references.
:::

- Orchestrated by the **Engineering Manager** agent, which delegates to the Software Engineer and UI Reviewer.
- Implements UI components following the plan.
- Runs **iterative verification loop** with the **UI Reviewer** role after each component.
- **Fixes mismatches** by delegating fixes back to the Software Engineer based on subagent reports.
- Escalates after 5 failed iterations with a detailed report.
- Produces a **UI Verification Summary** before handing off to code review.

## Required Skills

The frontend flow loads these specialized skills:

- **eversis-implementing-frontend** — Component patterns, design system usage, composition, and performance guidelines.
- **eversis-ui-verifying** — Verification criteria, tolerances, severity definitions, and what constitutes PASS/FAIL.
- **eversis-ensuring-accessibility** — WCAG 2.1 AA compliance, semantic HTML, ARIA, keyboard navigation.
- **eversis-technical-context-discovering** — Project conventions and coding standards.

:::warning Important
The automated Figma verification loop helps catch visual mismatches, but it does not replace manual review. Always visually inspect the implemented UI in the browser, test interactions, and verify responsive behavior yourself.
:::
