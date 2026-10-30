# Chrome DevTools MCP — Jira-ready tasks

Formatted from `extracted-tasks.md` after Gate 1 and Gate 1.5. Local markdown. Jira wiki markup inside description blocks is applied only when issues are created.

No `docs/context/<project>/INDEX.md` exists in this repository, so no project backlog rules overrode the benchmark. Child issues are **Task**, not Story, per formatting review.

Titles follow the benchmark (`<Domain>: <Capability>` for epics, `<Actor> can <action>` for tasks). Priorities are unchanged. Jira keys are empty until a push.

## Completeness

| Task | Required fields | Priority | Notes |
|---|---|---|---|
| Epic 1 | Complete | High | — |
| Task 1.1 | Complete | High | Additional catalog-count check kept under acceptance criteria |
| Task 1.2 | Complete | High | — |
| Epic 2 | Complete | High | — |
| Task 2.1 | Complete | High | — |
| Task 2.2 | Complete | High | — |
| Epic 3 | Complete | Medium | — |
| Task 3.1 | Complete | Medium | — |
| Task 3.2 | Complete | Medium | — |

---

### Epic: Integrations: Optional Chrome DevTools for diagnosis and performance

**Issue Type**: Epic
**Jira Key**: AC-91
**Status**: Backlog
**Priority**: High

**Description**:
```
h2. Overview

One delivery for optional Chrome DevTools in the Agent Collections catalog. Consumers can opt in for live Chrome diagnosis and performance evidence. The integration stays off unless selected. Agents keep Playwright for UI verification and use Chrome DevTools only when it is enabled. The frontend performance skill records a trace only in that case.

h2. Business Value

Teams that need console, network, and performance evidence can turn one integration on. Everyone else is not given a second browser by default, and Playwright stays the browser used to verify UI.

h2. Success Metrics

* The install choice exists and is not selected by default
* Guidance keeps Playwright for UI verification and names Chrome DevTools only when it is enabled
* The performance skill records a trace when the integration is on and does not call it when it is off
```

**Acceptance Criteria**:
```
(/) A consumer who does not choose Chrome DevTools does not get it enabled
(/) Design checks and flow exploration still name Playwright
(/) With Chrome DevTools enabled, optimization advice cites a performance trace or reports that the trace failed
```

**Labels**: `integration`, `mcp`, `workshop-2026-10-15`

---

### Story: Integrations: Optional Chrome DevTools catalog entry

**Parent**: Integrations: Optional Chrome DevTools for diagnosis and performance
**Issue Type**: Story
**Jira Key**: AC-82
**Status**: Backlog
**Priority**: High

**Description**:
```
h2. Overview

A consumer can choose Chrome DevTools as an extra integration when they need live Chrome diagnosis and performance evidence. It stays off unless they opt in. The catalog states the Chrome-only limit and the privacy opt-outs that ship with the entry.

h2. Business Value

Teams that need console, network, and performance evidence can turn the integration on. Everyone else is not given a second browser by default, and Playwright stays the browser used to verify UI.

h2. Success Metrics

* The install choice exists and is not selected by default
* A reader can tell what the integration is for, that it does not replace Playwright, and that usage statistics and field-performance lookup are off in the catalog template
* Playwright remains available exactly as it is today
```

**Acceptance Criteria**:
```
(/) A consumer who does not choose Chrome DevTools does not get it enabled
(/) The catalog explains purpose, Chrome-only support, the Chrome install requirement, and the privacy opt-outs
(/) The Playwright catalog entry is unchanged
```

**Labels**: `integration`, `mcp`, `workshop-2026-10-15`

---

### Task 1.1: Maintainer can offer Chrome DevTools as an opt-in integration

**Parent**: Integrations: Optional Chrome DevTools catalog entry
**Issue Type**: Sub-task
**Jira Key**: AC-85
**Status**: Backlog
**Priority**: High
**Sizing Guidance**: Medium (5-8)

**Description**:
```
h2. Context

This task is part of the [Integrations: Optional Chrome DevTools catalog entry] epic. It adds the integration to the installer choices and the shared template without turning it on for everyone.

h2. Source Context

Intent brief recommendation and in-scope catalog decision. Installer list scripts/lib/setup-agent-collections/mcp-server-list.json (default checked server is only eversis-collections). Template templates/mcp.json.

h2. User Story

As a framework maintainer, I want Chrome DevTools offered as an optional integration that stays off unless a consumer selects it, so that teams who need console, network, and performance evidence can enable it without forcing a second browser on everyone else.

h2. Requirements

# A fresh install leaves Chrome DevTools disabled unless the consumer selects it
# The installer list shows Chrome DevTools as a choice outside the default-checked set
# The shared template turns off usage statistics and CrUX field-data lookup for this entry
# The Playwright entry in that template stays as it is
# The integrations overview counts the new server once, with purpose "runtime diagnosis and performance in Chrome", for the Software Engineer doing frontend performance and debugging

h2. Delivery Standard

This task follows full spec-driven development (mandatory under Agent Collections / epic TASK-515 when applicable).

* Spec folder: docs/specs/chrome-devtools-mcp/
* Research: chrome-devtools-mcp.research.md — required before plan
* Plan: chrome-devtools-mcp.plan.md — required before implementation
* Implement: load eversis-implement (approved plan attached)
* Review: runs inside the Implement session by default (eversis-review); standalone /eversis-review is optional
* Fine: QA comment draft per eversis-fine-handoff (same turn as Fine); publish to tracker only with explicit human OK

Do not start implementation without approved research and plan artifacts.

Optional (Cursor): you may also attach the same prompts with @eversis-implement / @eversis-review if your project surfaces those files in Cursor.

h2. Technical Notes

Package chrome-devtools-mcp via npx, same pattern as other local servers. Flags discussed: --no-usage-statistics and --no-performance-crux. Full server, not slim mode, because slim mode drops the diagnosis and performance tools that justify the entry.
```

**Acceptance Criteria**:
```
(/) GIVEN a fresh install selection WHEN the consumer does not choose Chrome DevTools THEN the integration is not enabled
(/) GIVEN the installer server list WHEN a consumer looks for optional integrations THEN Chrome DevTools appears as a choice and is not in the default-checked set
(/) GIVEN the shared MCP template WHEN Chrome DevTools is configured THEN the entry pins opt-out of usage statistics and opt-out of CrUX field-data lookup
(/) GIVEN the same template WHEN Playwright is compared before and after THEN the Playwright entry is unchanged
(/) The catalog count of external integrations and the overview table include the new server once, with purpose "runtime diagnosis and performance in Chrome" and users Software Engineer (frontend performance and debugging)
```

**Labels**: `integration`, `mcp`, `workshop-2026-10-15`

---

### Task 1.2: Consumer can read what Chrome DevTools is for before opting in

**Parent**: Integrations: Optional Chrome DevTools catalog entry
**Issue Type**: Sub-task
**Jira Key**: AC-86
**Status**: Backlog
**Priority**: High
**Sizing Guidance**: Medium (5-8)

**Description**:
```
h2. Context

This task is part of the [Integrations: Optional Chrome DevTools catalog entry] epic. It gives the consumer a catalog page and a getting-started mention so they know when to turn the integration on.

h2. Source Context

Intent brief capability split and privacy constraints. Pattern of the Playwright integration page and the getting-started optional integrations list. Quality review S-01 added the Chrome install prerequisite.

h2. User Story

As a consumer choosing integrations, I want a catalog page that states what Chrome DevTools is for and what it is not, so that I can opt in without mistaking it for the UI verification browser.

h2. Requirements

# The integrations overview lists Chrome DevTools as optional and still lists Playwright for browser automation and UI verification
# The Chrome DevTools page names console, network, performance trace, and Lighthouse as the reasons to enable it
# The page states Chrome-only support, that page content is visible to the agent, and that statistics and CrUX lookup are off in the catalog template
# The getting-started optional list includes Chrome DevTools and labels it as not required to start
# The page states that current stable Chrome or Chrome for Testing must be installed
# The page states that opting in without Chrome means the integration cannot start until Chrome is installed

h2. Delivery Standard

This task follows full spec-driven development (mandatory under Agent Collections / epic TASK-515 when applicable).

* Spec folder: docs/specs/chrome-devtools-mcp/
* Research: chrome-devtools-mcp.research.md — required before plan
* Plan: chrome-devtools-mcp.plan.md — required before implementation
* Implement: load eversis-implement (approved plan attached)
* Review: runs inside the Implement session by default (eversis-review); standalone /eversis-review is optional
* Fine: QA comment draft per eversis-fine-handoff (same turn as Fine); publish to tracker only with explicit human OK

Do not start implementation without approved research and plan artifacts.

Optional (Cursor): you may also attach the same prompts with @eversis-implement / @eversis-review if your project surfaces those files in Cursor.

h2. Technical Notes

Heap snapshots, extensions, and PWA tools exist on the server but are not the reason for the catalog entry. The page names them only as out of the default job, not as workflows to start.
```

**Acceptance Criteria**:
```
(/) GIVEN the integrations overview WHEN a reader opens it THEN Chrome DevTools is listed as optional, with Playwright still listed for browser automation and UI verification
(/) GIVEN the Chrome DevTools integration page WHEN a reader opens it THEN they see console, network, performance trace, and Lighthouse as the reasons to enable it
(/) GIVEN that page WHEN a reader looks for limits THEN they see Chrome-only support, that page content is visible to the agent, and that statistics and CrUX lookup are off in the catalog template
(/) GIVEN the getting-started optional integrations list WHEN a reader scans it THEN Chrome DevTools appears next to the other optional servers and is labeled as not required to start
(/) GIVEN a consumer opens the Chrome DevTools catalog page WHEN they check requirements THEN the page states that current stable Chrome or Chrome for Testing must be installed
(/) GIVEN the consumer opted in AND Chrome is not installed WHEN an agent tries to use the integration THEN the documented outcome is that the integration cannot start until Chrome is installed
```

**Labels**: `integration`, `mcp`, `documentation`, `workshop-2026-10-15`

---

### Story: Agent guidance: Browser job split for verification and diagnosis

**Parent**: Integrations: Optional Chrome DevTools for diagnosis and performance
**Issue Type**: Story
**Jira Key**: AC-83
**Status**: Backlog
**Priority**: High

**Description**:
```
h2. Overview

Agents keep Playwright for checking a running UI against a design and for exploring flows. Chrome DevTools is used only when it is enabled, and only for console, network, performance, and Lighthouse. The two roles stay distinct so a second browser does not replace the verification path.

h2. Business Value

UI review and end-to-end exploration keep a stable browser. Diagnosis and performance use Chrome DevTools only for consumers who opted in, including when that browser cannot start.

h2. Success Metrics

* UI review and E2E exploration guidance still name Playwright
* Guidance that mentions Chrome DevTools also says it does not replace that verification path
* No guidance tells an agent to call Chrome DevTools when the consumer has not enabled it
```

**Acceptance Criteria**:
```
(/) Design checks and flow exploration still name Playwright after Chrome DevTools is in the catalog
(/) Console, network, trace, and Lighthouse guidance names Chrome DevTools only when that integration is enabled
(/) When Chrome cannot start, guidance reports the blocker and does not send that diagnosis to Playwright
```

**Labels**: `integration`, `documentation`, `workshop-2026-10-15`

---

### Task 2.1: UI reviewer can keep verifying screens with Playwright

**Parent**: Agent guidance: Browser job split for verification and diagnosis
**Issue Type**: Sub-task
**Jira Key**: AC-87
**Status**: Backlog
**Priority**: High
**Sizing Guidance**: Small (1-3)

**Description**:
```
h2. Context

This task is part of the [Agent guidance: Browser job split for verification and diagnosis] epic. It keeps design checks and flow exploration on Playwright when Chrome DevTools is added to the catalog.

h2. Source Context

Intent brief out of scope: do not replace Playwright, the UI Reviewer contract, or E2E execution. Playwright integration page agent table. Prompts eversis-review-ui and eversis-implement-e2e.

h2. User Story

As a UI reviewer, I want design-to-page checks and flow exploration to keep using Playwright, so that adding Chrome DevTools does not change how a screen is verified.

h2. Requirements

# UI review guidance still names Playwright as the browser for the running screen
# E2E exploration guidance still names Playwright as the interactive browser
# Those guides do not tell the agent to switch the verification browser to Chrome DevTools

h2. Delivery Standard

This task follows full spec-driven development (mandatory under Agent Collections / epic TASK-515 when applicable).

* Spec folder: docs/specs/chrome-devtools-mcp/
* Research: chrome-devtools-mcp.research.md — required before plan
* Plan: chrome-devtools-mcp.plan.md — required before implementation
* Implement: load eversis-implement (approved plan attached)
* Review: runs inside the Implement session by default (eversis-review); standalone /eversis-review is optional
* Fine: QA comment draft per eversis-fine-handoff (same turn as Fine); publish to tracker only with explicit human OK

Do not start implementation without approved research and plan artifacts.

Optional (Cursor): you may also attach the same prompts with @eversis-implement / @eversis-review if your project surfaces those files in Cursor.

h2. Technical Notes

No new technical approach was discussed. UI review and E2E exploration keep the Playwright contract already named in those guides.
```

**Acceptance Criteria**:
```
(/) GIVEN the UI review guidance WHEN an agent verifies a running screen against a design THEN the browser named for the actual page is still Playwright
(/) GIVEN the E2E exploration guidance WHEN an agent inspects the UI to understand a flow THEN the interactive browser named there is still Playwright
(/) GIVEN those guides WHEN Chrome DevTools is added to the catalog THEN they do not instruct the agent to switch the verification browser
```

**Labels**: `integration`, `documentation`, `playwright`, `workshop-2026-10-15`

---

### Task 2.2: Engineer can follow a written split of browser jobs

**Parent**: Agent guidance: Browser job split for verification and diagnosis
**Issue Type**: Sub-task
**Jira Key**: AC-88
**Status**: Backlog
**Priority**: High
**Sizing Guidance**: Small (1-3)

**Description**:
```
h2. Context

This task is part of the [Agent guidance: Browser job split for verification and diagnosis] epic. It writes down when an engineer uses Chrome DevTools and when they use Playwright.

h2. Source Context

Intent brief capability split. Quality review S-02 added the case where Chrome DevTools is enabled but Chrome cannot start.

h2. User Story

As a software engineer, I want a written split of browser jobs, so that I use Chrome DevTools for console, network, traces, and Lighthouse, and Playwright when I am checking UI or exploring a flow.

h2. Requirements

# Enabled Chrome DevTools is the tool for a failed request, a console error, a slow load, or an audit
# Design comparison and flow exploration stay on Playwright
# Disabled Chrome DevTools is not called
# If Chrome DevTools is enabled and Chrome cannot start, the agent reports that blocker and does not use Playwright as the substitute for console, network, trace, or Lighthouse
# The split is on the Chrome DevTools integration page and in the Playwright page usage notes, and both entries agree

h2. Delivery Standard

This task follows full spec-driven development (mandatory under Agent Collections / epic TASK-515 when applicable).

* Spec folder: docs/specs/chrome-devtools-mcp/
* Research: chrome-devtools-mcp.research.md — required before plan
* Plan: chrome-devtools-mcp.plan.md — required before implementation
* Implement: load eversis-implement (approved plan attached)
* Review: runs inside the Implement session by default (eversis-review); standalone /eversis-review is optional
* Fine: QA comment draft per eversis-fine-handoff (same turn as Fine); publish to tracker only with explicit human OK

Do not start implementation without approved research and plan artifacts.

Optional (Cursor): you may also attach the same prompts with @eversis-implement / @eversis-review if your project surfaces those files in Cursor.

h2. Technical Notes

Place the split on the Chrome DevTools integration page and in the Playwright page usage notes so both entries agree.
```

**Acceptance Criteria**:
```
(/) GIVEN Chrome DevTools is enabled WHEN an agent investigates a failed request, a console error, a slow load, or an audit THEN the guidance points at Chrome DevTools
(/) GIVEN the same guidance WHEN the task is a design comparison or flow exploration THEN the guidance points at Playwright
(/) GIVEN Chrome DevTools is not enabled WHEN an agent reads that guidance THEN it does not tell the agent to call the missing integration
(/) GIVEN Chrome DevTools is enabled AND Chrome cannot be started WHEN the agent needs console, network, trace, or Lighthouse evidence THEN the guidance tells the agent to report that blocker and not to use Playwright as a substitute for that diagnosis
```

**Labels**: `integration`, `documentation`, `workshop-2026-10-15`

---

### Story: Frontend performance: Trace only when Chrome DevTools is enabled

**Parent**: Integrations: Optional Chrome DevTools for diagnosis and performance
**Issue Type**: Story
**Jira Key**: AC-84
**Status**: Backlog
**Priority**: Medium

**Description**:
```
h2. Overview

The frontend performance skill already requires a measurement before optimization, but it tells the agent to use browser devtools with no tool attached. When the consumer has enabled Chrome DevTools, the skill uses a performance trace. When they have not, the skill still requires a baseline and does not pretend the tool is there.

h2. Business Value

Optimization advice is tied to a recording from the Chrome Performance panel when that integration is on. Projects that did not opt in are not sent to a missing tool, and they are told that opting in unlocks the trace.

h2. Success Metrics

* An enabled integration produces a trace-based baseline before optimization advice
* A missing integration does not cause the agent to call Chrome DevTools tools
* The skill still refuses optimization without some measured baseline
* A failed trace is reported and is not treated as a baseline
```

**Acceptance Criteria**:
```
(/) With Chrome DevTools enabled, optimization advice cites a performance trace or reports that the trace failed
(/) With Chrome DevTools disabled, the skill does not call it and still requires a measured baseline
(/) The disabled path tells the engineer that a trace is available after opting in
```

**Labels**: `performance`, `documentation`, `workshop-2026-10-15`

---

### Task 3.1: Engineer can get a performance trace before optimization advice

**Parent**: Frontend performance: Trace only when Chrome DevTools is enabled
**Issue Type**: Sub-task
**Jira Key**: AC-89
**Status**: Backlog
**Priority**: Medium
**Sizing Guidance**: Medium (5-8)

**Description**:
```
h2. Context

This task is part of the [Frontend performance: Trace only when Chrome DevTools is enabled] epic. It makes the performance skill record a Chrome Performance panel trace before suggesting changes, when the integration is on.

h2. Source Context

Intent brief candidate epic for the frontend performance skill. Skill eversis-optimizing-frontend, step "Measure current performance". Quality review S-03 added the failed-trace outcome. "Trace" means a Chrome Performance panel recording.

h2. User Story

As a software engineer optimizing a slow page, I want the performance skill to record a Chrome performance trace before suggesting changes, so that the advice is tied to evidence instead of an unmeasured DevTools reminder.

h2. Requirements

# When Chrome DevTools is enabled and a page is slow or a performance change is requested, the skill records a performance trace and reads the insight before proposing optimizations
# The recommendation cites the trace finding, for example LCP or a long task
# The skill still says not to optimize without that measurement
# When the trace cannot be recorded, the skill reports the failed measurement and does not present optimizations as if a baseline existed

h2. Delivery Standard

This task follows full spec-driven development (mandatory under Agent Collections / epic TASK-515 when applicable).

* Spec folder: docs/specs/chrome-devtools-mcp/
* Research: chrome-devtools-mcp.research.md — required before plan
* Plan: chrome-devtools-mcp.plan.md — required before implementation
* Implement: load eversis-implement (approved plan attached)
* Review: runs inside the Implement session by default (eversis-review); standalone /eversis-review is optional
* Fine: QA comment draft per eversis-fine-handoff (same turn as Fine); publish to tracker only with explicit human OK

Do not start implementation without approved research and plan artifacts.

Optional (Cursor): you may also attach the same prompts with @eversis-implement / @eversis-review if your project surfaces those files in Cursor.

h2. Technical Notes

Use the performance trace tools. Lighthouse remains available for a broader audit. The skill's required measurement is the trace, matching the current LCP, CLS, and INP baseline language.
```

**Acceptance Criteria**:
```
(/) GIVEN Chrome DevTools is enabled AND a page is slow or a performance change is requested WHEN the agent follows the frontend performance skill THEN it records a performance trace and reads the insight before proposing optimizations
(/) GIVEN that trace WHEN the agent reports a recommendation THEN the recommendation cites the trace finding (for example LCP or a long task), not only a code inspection
(/) GIVEN the skill text WHEN Chrome DevTools is the measurement tool THEN the skill still says not to optimize without that measurement
(/) GIVEN Chrome DevTools is enabled AND a performance trace cannot be recorded WHEN the agent follows the frontend performance skill THEN it reports that the measurement failed and does not present optimizations as if a baseline existed
```

**Labels**: `performance`, `documentation`, `workshop-2026-10-15`

---

### Task 3.2: Engineer can optimize without a missing Chrome DevTools tool

**Parent**: Frontend performance: Trace only when Chrome DevTools is enabled
**Issue Type**: Sub-task
**Jira Key**: AC-90
**Status**: Backlog
**Priority**: Medium
**Sizing Guidance**: Small (1-3)

**Description**:
```
h2. Context

This task is part of the [Frontend performance: Trace only when Chrome DevTools is enabled] epic. It keeps the performance skill from calling Chrome DevTools on projects that did not enable it.

h2. Source Context

Intent brief: performance guidance applies only when the server is enabled. Boundary with task 3.1. Quality review S-04 added the opt-in explanation on the disabled path.

h2. User Story

As a software engineer on a project that did not enable Chrome DevTools, I want the performance skill to demand a baseline without calling that integration, so that the agent does not fail on a tool the project never turned on.

h2. Requirements

# When Chrome DevTools is not enabled, the skill does not call its tools
# The skill still requires a measured baseline by whatever means the project already has
# The enabled path and the disabled path are mutually exclusive
# The disabled path tells the engineer that a performance trace is available after opting in, and still does not call the tools

h2. Delivery Standard

This task follows full spec-driven development (mandatory under Agent Collections / epic TASK-515 when applicable).

* Spec folder: docs/specs/chrome-devtools-mcp/
* Research: chrome-devtools-mcp.research.md — required before plan
* Plan: chrome-devtools-mcp.plan.md — required before implementation
* Implement: load eversis-implement (approved plan attached)
* Review: runs inside the Implement session by default (eversis-review); standalone /eversis-review is optional
* Fine: QA comment draft per eversis-fine-handoff (same turn as Fine); publish to tracker only with explicit human OK

Do not start implementation without approved research and plan artifacts.

Optional (Cursor): you may also attach the same prompts with @eversis-implement / @eversis-review if your project surfaces those files in Cursor.

h2. Technical Notes

No specific technical considerations discussed.
```

**Acceptance Criteria**:
```
(/) GIVEN Chrome DevTools is not enabled WHEN the agent follows the frontend performance skill THEN it does not call Chrome DevTools tools
(/) GIVEN the same situation WHEN the agent would otherwise optimize immediately THEN the skill still requires a measured baseline by whatever means the project already has
(/) GIVEN the skill text WHEN both states are described THEN the enabled path and the disabled path are mutually exclusive
(/) GIVEN Chrome DevTools is not enabled WHEN the agent follows the frontend performance skill THEN it tells the engineer that a performance trace is available after opting in, and it still does not call Chrome DevTools tools
```

**Labels**: `performance`, `documentation`, `workshop-2026-10-15`
