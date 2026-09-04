---
sidebar_position: 7
title: E2E Engineer
---

# E2E Engineer Agent

**Rule pack (canonical template):** `.cursor/rules/eversis-role-e2e-engineer.mdc` — **not shipped** in agent-collections; behavior via [Implement E2E](../prompts/internal/implement-e2e) delegate.  
**Delegated prompt:** [Implement E2E](../prompts/internal/implement-e2e) (via **`@eversis-implement`** — [Implement](../prompts/public/implement))

The E2E Engineer creates, maintains, and debugs end-to-end tests using **Playwright**. It produces reliable, maintainable, and meaningful test suites with accessibility-first locators, stable flows, and CI-ready runs.

## Responsibilities

- Analyzing the application and designing test scenarios.
- Implementing Page Objects with accessibility-first locators.
- Writing comprehensive test files with proper structure.
- Verifying tests pass consistently (3+ consecutive passes) in headless mode.
- Debugging flaky tests and ensuring CI readiness.
- Reporting bugs discovered during testing.

## Testing Standards

| Standard | Approach |
| --- | --- |
| **Locators** | Use `getByRole`, `getByLabel`, `getByText`. Avoid CSS selectors. `getByTestId` only as fallback. |
| **Synchronization** | Built-in auto-waiting assertions. No `waitForTimeout()`. No `networkidle`. |
| **Test Data** | Dynamic data with timestamps/UUIDs. No state dependency between tests. |
| **Security** | Never hardcode credentials. Use environment variables. |
| **Naming** | `should [behavior] when [condition]` pattern. |
| **Isolation** | Tests must not depend on state left by previous tests. |

## Key Behaviors

- **Non-interactive** — Makes reasonable decisions and documents them.
- **Strictly follows the plan** — Does not deviate unless explicitly instructed.
- **No dead code** — Does not create unused test helpers or future-only tests.
- **3+ consecutive passes** — Required before tests are considered stable.

## Tool Access

| Tool | Usage |
| --- | --- |
| **Atlassian** | Search for related test requirements and context (search only) |
| **Context7** | Search Playwright API docs (library ID: `/microsoft/playwright.dev`) |
| **Figma** | Understand expected UI behavior, extract labels for locator strategies |
| **Playwright MCP** | Inspect actual page state, discover locators, understand UI structure |
| **Sequential Thinking** | Analyze complex test scenarios, debug flaky tests, plan mocking strategies |
| **Terminal** | Run Playwright tests, install dependencies, execute scripts |
| **Cursor Agent** | Read, modify, and search workspace files (tests, fixtures, config) |
| **Todo** | Track testing progress with structured checklists |

## Skills Loaded

- [eversis-task-analysing](../skills/task-analysis) — Determine context sources and gather requirements.
- [eversis-e2e-testing](../skills/e2e-testing) — Test structure patterns, Page Object conventions, mocking strategies, verification loop.
- [eversis-technical-context-discovering](../skills/technical-context-discovery) — Project conventions and test patterns.

## Handoffs

After discovering critical bugs, the E2E Engineer can hand off to:

- **Software Engineer** — **`@eversis-implement`** ([Implement](../prompts/public/implement); fix the bug discovered during E2E testing).
