# Chrome DevTools MCP — Extracted Tasks

## Workshop Summary

| Field | Value |
|---|---|
| Workshop Date | 2026-10-15 |
| Participants | Product owner (request), Business Analyst (draft) |
| Source Materials | Chrome DevTools MCP blog and Chrome DevTools for agents docs; chrome-devtools-mcp tool reference; Agent Collections integration catalog (overview, Playwright page, MCP template, installer server list, getting-started optional integrations) |
| Intent Brief | `docs/specs/chrome-devtools-mcp/intent-brief.md` (Gate 0 Approved 2026-10-15) |
| Project Baseline Used | None |
| Total Epics | 3 |
| Total Stories | 6 |

## Epics Overview

| # | Epic Title | Stories Count | Priority |
|---|-----------|---------------|----------|
| 1 | Optional Chrome DevTools catalog entry | 2 | High |
| 2 | Browser job split in agent guidance | 2 | High |
| 3 | Frontend performance uses a trace only when enabled | 2 | Medium |

## Epic 1: Optional Chrome DevTools catalog entry

**Business Description**: A consumer can choose Chrome DevTools as an extra integration when they need live Chrome diagnosis and performance evidence. It stays off unless they opt in, and the catalog states the Chrome-only limit and the privacy opt-outs that ship with the entry.

**Success Criteria**:
- The install choice exists and is not selected by default.
- A reader can tell what the integration is for, that it does not replace Playwright, and how statistics and field-performance lookup are turned off.
- Playwright remains available exactly as it is today.

### Story 1.1: Consumer can opt in to Chrome DevTools without it turning on by default

**User Story**: As a framework maintainer, I want Chrome DevTools offered as an optional integration that stays off unless a consumer selects it, so that teams who need console, network, and performance evidence can enable it without forcing a second browser on everyone else.

**Source**: Intent brief recommendation and in-scope catalog decision; installer list `scripts/lib/setup-agent-collections/mcp-server-list.json` (`defaultChecked` is only `eversis-collections`); template `templates/mcp.json`.

**Acceptance Criteria**:
- [ ] GIVEN a fresh install selection WHEN the consumer does not choose Chrome DevTools THEN the integration is not enabled.
- [ ] GIVEN the installer server list WHEN a consumer looks for optional integrations THEN Chrome DevTools appears as a choice and is not in the default-checked set.
- [ ] GIVEN the shared MCP template WHEN Chrome DevTools is configured THEN the entry pins opt-out of usage statistics and opt-out of CrUX field-data lookup.
- [ ] GIVEN the same template WHEN Playwright is compared before and after THEN the Playwright entry is unchanged.

**Additional Acceptance Checks**:
- The catalog count of external integrations and the overview table include the new server once, with purpose “runtime diagnosis and performance in Chrome” and users Software Engineer (frontend performance and debugging).

**High-Level Technical Notes**: Package `chrome-devtools-mcp` via `npx`, same pattern as other stdio servers. Flags discussed: `--no-usage-statistics` and `--no-performance-crux`. Full server, not `--slim`, because slim drops the diagnosis and performance tools that justify the entry.

**Priority**: High

**Gate 1**: Approved 2026-10-15. Opt-out of usage statistics and CrUX stays in the template.

### Story 1.2: Catalog explains purpose, Chrome-only support, and privacy opt-outs

**User Story**: As a consumer choosing integrations, I want a catalog page that states what Chrome DevTools is for and what it is not, so that I can opt in without mistaking it for the UI verification browser.

**Source**: Intent brief capability split and privacy constraints; pattern of `website/docs/reference/integrations/playwright.md` and `website/docs/getting-started/mcp-setup.mdx` optional list.

**Acceptance Criteria**:
- [ ] GIVEN the integrations overview WHEN a reader opens it THEN Chrome DevTools is listed as optional, with Playwright still listed for browser automation and UI verification.
- [ ] GIVEN the Chrome DevTools integration page WHEN a reader opens it THEN they see console, network, performance trace, and Lighthouse as the reasons to enable it.
- [ ] GIVEN that page WHEN a reader looks for limits THEN they see Chrome-only support, that page content is visible to the agent, and that statistics and CrUX lookup are off in the catalog template.
- [ ] GIVEN the getting-started optional integrations list WHEN a reader scans it THEN Chrome DevTools appears next to the other optional servers and is labeled as not required to start.
- [ ] GIVEN a consumer opens the Chrome DevTools catalog page WHEN they check requirements THEN the page states that current stable Chrome or Chrome for Testing must be installed.
- [ ] GIVEN the consumer opted in AND Chrome is not installed WHEN an agent tries to use the integration THEN the documented outcome is that the integration cannot start until Chrome is installed.

**High-Level Technical Notes**: Heap snapshots, extensions, and PWA tools exist on the server but are not the reason for the catalog entry. The page names them only as out of the default job, not as workflows to start.

**Priority**: High

**Gate 1**: Approved 2026-10-15.

## Epic 2: Browser job split in agent guidance

**Business Description**: Agents keep Playwright for checking a running UI against a design and for exploring flows. Chrome DevTools is used only when it is enabled, and only for console, network, performance, and Lighthouse. The two roles stay distinct so a second browser does not replace the verification path.

**Success Criteria**:
- UI review and E2E exploration guidance still name Playwright.
- Guidance that mentions Chrome DevTools also says it does not replace that verification path.
- No guidance tells an agent to call Chrome DevTools when the consumer has not enabled it.

### Story 2.1: UI verification and E2E exploration stay on Playwright

**User Story**: As a UI reviewer, I want design-to-page checks and flow exploration to keep using Playwright, so that adding Chrome DevTools does not change how a screen is verified.

**Source**: Intent brief out of scope (do not replace Playwright, UI Reviewer contract, or E2E execution); `website/docs/reference/integrations/playwright.md` agent table; prompts `eversis-review-ui` and `eversis-implement-e2e`.

**Acceptance Criteria**:
- [ ] GIVEN the UI review guidance WHEN an agent verifies a running screen against a design THEN the browser named for the actual page is still Playwright.
- [ ] GIVEN the E2E exploration guidance WHEN an agent inspects the UI to understand a flow THEN the interactive browser named there is still Playwright.
- [ ] GIVEN those guides WHEN Chrome DevTools is added to the catalog THEN they do not instruct the agent to switch the verification browser.

**High-Level Technical Notes**: None beyond the existing Playwright contract already named in those guides.

**Priority**: High

**Gate 1**: Approved 2026-10-15.

### Story 2.2: Diagnosis and performance name Chrome DevTools only as the opt-in tool

**User Story**: As a software engineer, I want a written split of browser jobs, so that I use Chrome DevTools for console, network, traces, and Lighthouse, and Playwright when I am checking UI or exploring a flow.

**Source**: Intent brief capability split table; candidate epic “Browser job split in agent guidance”.

**Acceptance Criteria**:
- [ ] GIVEN Chrome DevTools is enabled WHEN an agent investigates a failed request, a console error, a slow load, or an audit THEN the guidance points at Chrome DevTools.
- [ ] GIVEN the same guidance WHEN the task is a design comparison or flow exploration THEN the guidance points at Playwright.
- [ ] GIVEN Chrome DevTools is not enabled WHEN an agent reads that guidance THEN it does not tell the agent to call the missing integration.
- [ ] GIVEN Chrome DevTools is enabled AND Chrome cannot be started WHEN the agent needs console, network, trace, or Lighthouse evidence THEN the guidance tells the agent to report that blocker and not to use Playwright as a substitute for that diagnosis.

**High-Level Technical Notes**: Place the split on the Chrome DevTools integration page and in the Playwright page usage notes so both entries agree.

**Priority**: High

**Gate 1**: Approved 2026-10-15.

## Epic 3: Frontend performance uses a trace only when enabled

**Business Description**: The frontend performance skill already requires a measurement before optimization, but it tells the agent to use browser devtools with no tool attached. When the consumer has enabled Chrome DevTools, the skill should use a performance trace. When they have not, the skill still requires a baseline and must not pretend the tool is there.

**Success Criteria**:
- An enabled integration produces a trace-based baseline before optimization advice.
- A missing integration does not cause the agent to call Chrome DevTools tools.
- The skill still refuses optimization without some measured baseline.

### Story 3.1: Performance skill records a trace when Chrome DevTools is enabled

**User Story**: As a software engineer optimizing a slow page, I want the performance skill to record a Chrome performance trace before suggesting changes, so that the advice is tied to evidence instead of an unmeasured DevTools reminder.

**Source**: Intent brief candidate epic “Frontend performance skill uses a trace when the server is present”; skill `eversis-optimizing-frontend` step “Measure current performance”; Chrome DevTools tools `performance_start_trace` and `performance_analyze_insight`.

**Acceptance Criteria**:
- [ ] GIVEN Chrome DevTools is enabled AND a page is slow or a performance change is requested WHEN the agent follows the frontend performance skill THEN it records a performance trace and reads the insight before proposing optimizations.
- [ ] GIVEN that trace WHEN the agent reports a recommendation THEN the recommendation cites the trace finding (for example LCP or a long task), not only a code inspection.
- [ ] GIVEN the skill text WHEN Chrome DevTools is the measurement tool THEN the skill still says not to optimize without that measurement.
- [ ] GIVEN Chrome DevTools is enabled AND a performance trace cannot be recorded WHEN the agent follows the frontend performance skill THEN it reports that the measurement failed and does not present optimizations as if a baseline existed.

**High-Level Technical Notes**: Use the performance trace tools. Lighthouse remains available for a broader audit; the skill’s required measurement is the trace, matching the current LCP / CLS / INP baseline language.

**Priority**: Medium

**Gate 1**: Approved 2026-10-15. “Ślad” means a Chrome Performance panel recording.

### Story 3.2: Performance skill does not call Chrome DevTools when it is off

**User Story**: As a software engineer on a project that did not enable Chrome DevTools, I want the performance skill to demand a baseline without calling that integration, so that the agent does not fail on a tool the project never turned on.

**Source**: Intent brief in-scope line that performance guidance applies only when the server is enabled; story 3.1 boundary.

**Acceptance Criteria**:
- [ ] GIVEN Chrome DevTools is not enabled WHEN the agent follows the frontend performance skill THEN it does not call Chrome DevTools tools.
- [ ] GIVEN the same situation WHEN the agent would otherwise optimize immediately THEN the skill still requires a measured baseline by whatever means the project already has.
- [ ] GIVEN the skill text WHEN both states are described THEN the enabled path and the disabled path are mutually exclusive.
- [ ] GIVEN Chrome DevTools is not enabled WHEN the agent follows the frontend performance skill THEN it tells the engineer that a performance trace is available after opting in, and it still does not call Chrome DevTools tools.

**High-Level Technical Notes**: None.

**Priority**: Medium

**Gate 1**: Approved 2026-10-15.

## Dependencies

| Task | Depends On | Type | Notes |
|------|-----------|------|-------|
| Story 1.2 | Story 1.1 | Related to | The page describes the same entry the template and installer offer. |
| Story 2.1 | Story 1.1 | Related to | Confirmation that the existing Playwright path is untouched when the new entry lands. |
| Story 2.2 | Story 1.2 | Blocked by | The job split is published on the catalog pages story 1.2 creates. |
| Story 3.1 | Story 2.2 | Blocked by | The skill should point at Chrome DevTools only after the job split says when that is allowed. |
| Story 3.2 | Story 3.1 | Related to | Same skill, opposite enablement state. |
| Epic 2 | Epic 1 | Blocked by | Guidance names a catalog entry that must exist. |
| Epic 3 | Epic 2 | Blocked by | The skill follows the job split. |

## Assumptions

| # | Assumption | Confidence | Impact if Wrong |
|---|-----------|------------|-----------------|
| 1 | The catalog entry ships the full server, not `--slim`. Slim keeps navigation and snapshots and drops the diagnosis and performance tools that justify adding a second browser. | High | Story 1.1 flags and story 1.2 capability list would shrink to a Playwright duplicate and the epic should be dropped. |
| 2 | Heap snapshots, extensions, and PWA flows are named only as outside the default job, not as supported workflows on the integration page. | Medium | Story 1.2 page outline grows if stakeholders want those called out as supported. |
| 3 | The entry is published on the same surfaces as the other optional servers: installer list, MCP template, integrations overview, a dedicated integration page, and the getting-started optional list. All hosts the installer already configures. | High | A Cursor-only slice would drop the installer list and non-Cursor docs from stories 1.1 and 1.2. |
| 4 | Usage statistics and CrUX lookup are off in the template by default. | High | Story 1.1 acceptance criteria change if the catalog ships Google’s defaults instead. |

## Out of Scope

Items explicitly excluded from this task breakdown:
- Replacing Playwright for UI verification, Figma comparison, or E2E exploration.
- Turning Chrome DevTools on by default.
- Cursor’s built-in browser. That is a host tool, not a catalog integration.
- Chrome extension, PWA, Android, and WebMCP workflows as deliverables.
- Running E2E suites through either MCP server. Test execution stays in the terminal.
- Jira creation. Gate 2 is still required.

## Open Questions for Stakeholders

| # | Question | Context | Impact |
|---|----------|---------|--------|
| 1 | None that block extraction. Slim versus full, advanced tools, and host coverage are recorded as assumptions above. | Gate 0 approval fixed the product decision; these three shape the page, not whether the entry exists. | Correct the assumption in Gate 1 if any row is wrong. |

## Gate 1 Approval

| Decision | Notes |
|---|---|
| Approved | 2026-10-15. Stories 1.1–3.2 approved individually. No additional tasks. |
