# Chrome DevTools MCP — Intent Brief

## Workshop Summary

| Field | Value |
|---|---|
| Workshop Date | 2026-10-15 |
| Participants | Product owner (request), Business Analyst (draft) |
| Source Materials | [Chrome DevTools MCP blog](https://developer.chrome.com/blog/chrome-devtools-mcp) (23 Sep 2025; page notes the server is now part of Chrome DevTools for agents); [Chrome DevTools for agents](https://developer.chrome.com/docs/devtools/agents); [chrome-devtools-mcp README and tool reference](https://github.com/ChromeDevTools/chrome-devtools-mcp); Agent Collections catalog: `website/docs/reference/integrations/overview.md`, `playwright.md`, `templates/mcp.json`, `scripts/lib/setup-agent-collections/mcp-server-list.json` |
| Prepared By | Business Analyst (`eversis-analyze-materials`) |

## Goal

Decide whether Chrome DevTools MCP belongs in the Agent Collections integration catalog next to the existing optional servers, and on what terms, so frontend debugging and performance work can use live Chrome evidence without duplicating the browser role Playwright already fills.

## Recommendation (analysis outcome)

**Add it as an optional, off-by-default catalog integration. Do not replace Playwright. Do not turn it on by default.**

Playwright MCP stays the browser for UI verification, Figma comparison, and E2E exploration. Chrome DevTools MCP fills a gap the catalog does not cover today: console and network diagnosis, performance traces (including LCP-style insight), Lighthouse audits, and memory snapshots — the work `eversis-optimizing-frontend` currently asks the agent to do in DevTools without a tool.

## In Scope

- A product decision: optional catalog entry alongside the current 11 external MCP servers plus the local Agent Collections server.
- Clear split of jobs: Playwright for structured UI verification; Chrome DevTools for runtime diagnosis and performance.
- Privacy and vendor constraints that must travel with any catalog entry: Chrome-only support, browser content exposed to the agent, Google usage statistics on by default (opt out with `--no-usage-statistics`), optional CrUX lookup unless `--no-performance-crux` is set.
- Candidate follow-up work only after this brief is approved: catalog config, installer list, integration page, and guidance in the frontend performance skill so agents know when to use which browser.

## Out of Scope

- Replacing Playwright MCP, the UI Reviewer contract, or E2E test execution (terminal `playwright test` stays the test runner).
- Enabling the server by default. Today only `eversis-collections` is default-checked.
- Cursor’s built-in browser (`cursor-ide-browser`). That is a host tool, not a catalog integration.
- Chrome extension, PWA, Android, or WebMCP workflows from the full tool list.
- Writing Jira issues or changing installer code before Gate 0 approval.

## Key Stakeholders / Actors

- **Software Engineer (frontend)** — needs console, network, and layout evidence when a running page misbehaves.
- **UI Reviewer** — keeps Playwright plus Figma as the verification pair; should not switch browsers for pixel and accessibility-tree checks.
- **E2E Engineer** — keeps Playwright for locator discovery; Chrome DevTools is not the cross-browser test stack.
- **Framework maintainer** — owns the catalog, installer selection, and docs so a second browser does not become a silent default.
- **Consumer project** — opts in during install; pays the cost of a second local Chrome process and a large tool list.

## Capability split (why both can coexist)

| Job | Already covered | Chrome DevTools MCP adds |
|---|---|---|
| Click, fill, navigate, snapshot, screenshot | Playwright MCP; also the Cursor host browser in Cursor sessions | Same class of automation (Puppeteer). Overlap, not a reason to add it. |
| Figma vs running UI | Playwright is named in `eversis-review-ui` and `eversis-ui-verifying` | No. Switching this contract would churn every UI review. |
| Console errors, failed requests, CORS | Not in the Playwright integration page | `list_console_messages`, `list_network_requests` |
| “Why is this slow?” / LCP | `eversis-optimizing-frontend` says “use browser devtools” with no MCP | `performance_start_trace`, `performance_analyze_insight`, `lighthouse_audit` |
| Memory leaks | Not in the catalog | Heap snapshot tools (heavy; keep out of the default prompt path) |
| Cross-browser | Playwright | Officially Chrome / Chrome for Testing only |

## Risks if added without a boundary

- Agents open two browsers and disagree about which snapshot is “the page”.
- The full tool list is large (automation plus performance, memory, extensions, PWA). That competes with context already used by Playwright.
- Usage statistics and page content leave the machine unless the catalog pins opt-out flags.
- A Chrome-only server cannot stand in for E2E that must cover more than Chrome.

## Candidate Epics

- **Optional Chrome DevTools catalog entry** — install selection, `templates/mcp.json`, and an integration page, off by default, with statistics and CrUX opt-out flags documented.
- **Browser job split in agent guidance** — Playwright remains verification and E2E exploration; Chrome DevTools is the tool for console, network, trace, and Lighthouse when the consumer opted in.
- **Frontend performance skill uses a trace when the server is present** — `eversis-optimizing-frontend` stops telling the agent to “open DevTools” with no tool, and names the trace only when `chrome-devtools` is enabled.

## Baseline Overlap / Existing Backlog Notes

- No `docs/context/<project>/task-baseline.md` in this repository.
- Overlap is the existing **Playwright** integration (`playwright` in `mcp-server-list.json` and `templates/mcp.json`; docs under `website/docs/reference/integrations/playwright.md`). It is optional and not default-checked.
- Related skills that mention a browser without this server: `eversis-ui-verifying` (Playwright, keep), `eversis-optimizing-frontend` (DevTools in prose, gap), `eversis-accessibility-auditing` (prefers the editor browser, then Playwright).

## Open Questions

- Should the first catalog entry ship the full server or `--slim` (navigation and snapshots only, which mostly duplicates Playwright)?
- Should heap, extension, and PWA tools be mentioned as advanced, or omitted from the integration page so agents are not steered there?
- Is the audience Cursor-only catalog docs, or every host the installer configures?

## Gate 0 Approval

| Decision | Notes |
|---|---|
| Approved | 2026-10-15. Human approved the scope: optional catalog entry, off by default, with opt-out flags; Playwright unchanged; frontend performance guidance only when the server is enabled. |
