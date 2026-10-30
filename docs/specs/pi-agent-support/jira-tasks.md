# Pi Agent support — Jira Tasks

Target project: **AC**  
Board: [AC board 1471](https://eversis.atlassian.net/jira/software/c/projects/AC/boards/1471)

Sync summary before push: **1 CREATE** (single Task). **0 UPDATE**. **0 SKIP**.

The requestor asked for one ticket. Epic 1 and Story 1.1 are carried by that Task.

## Completeness

| Task | Required fields | Status |
|---|---|---|
| Task: Add full Pi Agent support | Summary, description, acceptance criteria, priority, labels | Complete |

---

### Task: Add full Pi Agent support

**Jira Key**: AC-14
**Status**: Backlog
**Issue Type**: Task
**Priority**: Medium
**Labels**: `pi-agent`, `adapter`, `workshop-2026-09-21`
**Parent**: —
**Sizing guidance**: Large (suggestion only; team estimates in refinement)

**Description**:

## Overview

Add Pi as a shipped agent in Agent Collections. A team that chooses Pi at install can use the framework’s rules, skills, and prompt templates in a Pi session, in the same way Cursor and Claude Code users already can. A long Implement session in Pi also keeps a context budget of about 50%, which AC-2 deferred to this host.

## Business Value

Teams that work in [Pi](https://pi.dev/) cannot use Agent Collections today. Cursor and Claude Code are shipped agents. OpenCode is only a placeholder. This task makes Pi a supported agent without a second copy of the framework. On Pi, compaction at about half the context window can run before the current task is dropped, because that host can see how full the window is. Cursor and Claude Code stay without that trigger.

## User Story

As a team using Pi, I want to install Agent Collections for Pi so that the same rules, skills, and prompts are available in a Pi session, and a long session compacts at about 50% of the context window before the current task is lost.

## Requirements

1. A person installing Agent Collections can choose Pi.
2. After that choice, a Pi session can use the framework’s rules, skills, and prompt templates.
3. Public docs and the install choice list name Pi as a supported agent and say what the install provides.
4. Choosing not to include Pi leaves other selected agents unchanged.
5. If Pi setup cannot be completed, the person sees a clear failure and other selected agents are unaffected.
6. A long Implement session in Pi keeps a context budget of about 50%: Pi can see how full the window is, and compaction at that level runs before the current task is dropped.
7. Cursor and Claude Code sessions do not checkpoint or end because of context-window fill. That trigger stays off those hosts, as AC-2 already decided.

## Source Context

Chat request 2026-09-21, “Dodanie pełnej obsługi PI Agent”, [https://pi.dev/](https://pi.dev/). Approved intent brief: `docs/specs/pi-agent-support/intent-brief.md`.

Context-budget addition 2026-09-21: AC-2 plan (`docs/specs/ac-2/ac-2.plan.md`), Open Question 6 and Improvements (“PI Agent context-window trigger”). AC-2 removed the ~50% trigger from the shared Implement rule because Cursor and Claude Code cannot observe window fill. The same plan records the follow-up on Pi: the host exposes usage (`context_info`) and already ships a 50% extension (`pi-rolling-compaction`).

## Out of Scope

- Promoting OpenCode from placeholder to full support
- Rewriting the vendor-neutral framework core
- Pi themes, custom model or provider catalogs, embedding Pi in another app, and sandbox setup
- Building capabilities Pi does not ship (MCP, sub-agents, plan mode, permission prompts, built-in to-dos, background shell)
- A context-window percent trigger in the Cursor or Claude Code Implement rule

## Delivery Standard

This story follows full spec-driven development (mandatory under Agent Collections).

- Spec folder: `docs/specs/<issue-kebab>/`
- Research: `<issue-kebab>.research.md` — required before plan
- Plan: `<issue-kebab>.plan.md` — required before implementation
- Implement: load `eversis-implement` (approved plan attached)
- Review: runs inside the Implement session by default (`eversis-review`); standalone `/eversis-review` is optional
- Fine: QA comment draft per `eversis-fine-handoff` (same turn as Fine); publish to tracker only with explicit human OK

Do not start implementation without approved research and plan artifacts.

Optional (Cursor): you may also attach the same prompts with `@eversis-implement` / `@eversis-review` if the project surfaces those files in Cursor.

## Technical Notes

Target product: [Pi](https://pi.dev/).

The ~50% budget is Pi-only, per the approved AC-2 plan. Pi exposes window usage to the agent (`context_info`) and ships `pi-rolling-compaction` at 50%. Install settings for that host (including `.pi/settings.json`) belong with this ticket. Do not put a window-fill percent back into the shared Implement rule used by Cursor and Claude Code.

## Acceptance Criteria

- [ ] GIVEN a person installs Agent Collections and chooses Pi WHEN installation finishes THEN a Pi session can use the framework’s rules, skills, and prompt templates
- [ ] GIVEN Pi is a supported choice WHEN a reader opens the install guidance or the public docs THEN Pi is listed as a supported agent and the page says what the install provides
- [ ] GIVEN a person installs Agent Collections and does not choose Pi WHEN installation finishes THEN Pi packaging is not added and the other selected agents still work
- [ ] GIVEN a person chooses Pi and Pi setup cannot be completed WHEN installation finishes THEN they see a clear failure and any other agents they selected are unaffected
- [ ] GIVEN an Implement session is running in Pi WHEN the context window reaches about half its capacity THEN the session compacts under that ~50% budget before the current task is dropped
- [ ] GIVEN an Implement session is running in Cursor or Claude Code WHEN the context window fills THEN that session does not checkpoint or end because of window fill
- [ ] Support is shipped and usable, not a config-only placeholder

---

# Scope extension 2026-10-27 — Jira Tasks

Target project: **AC**  
Board: [AC board 1471](https://eversis.atlassian.net/jira/software/c/projects/AC/boards/1471)

Sync summary before push: **4 CREATE** (Tasks). **1 UPDATE** (AC-14: one Out of Scope line). **0 SKIP**.

Issue type **Task** (not Sub-task), per requestor and `docs/context/agent-collections/jira-backlog-hierarchy`. AC-14 is a Task, so it cannot be their Jira parent: each new Task gets **no parent** and an issue link **AC-14 blocks <new Task>**. Story 1.4 also gets **Relates** links to DHI-529 (synchronized ignore files, Done).

Created 2026-10-27: AC-111, AC-112, AC-113, AC-114. Spec folders use the lowercase key (e.g. `docs/specs/ac-111-pi-subscription-costs/`).

## Completeness

| Task | Required fields | Status |
|---|---|---|
| Team signs Pi in with a subscription and keeps model costs predictable | Summary, description, acceptance criteria, priority, labels, links | Complete |
| Pi sessions use token-economy rules without skipping tests, review, or Fine | Summary, description, acceptance criteria, priority, labels, links | Complete |
| Pi install keeps heavy and secret files out of the agent's reach | Summary, description, acceptance criteria, priority, labels, links | Complete |
| Team can run the Pi agent in an isolated workspace with restricted network | Summary, description, acceptance criteria, priority, labels, links | Complete |
| AC-14 Out of Scope update | One line changed | Complete |

---

### Task: Team signs Pi in with a subscription and keeps model costs predictable

**Jira Key**: AC-111
**Status**: Backlog
**Issue Type**: Task
**Priority**: Medium
**Labels**: `pi-agent`, `cost-control`, `docs`, `workshop-2026-10-27`
**Parent**: AC-115 (Epic: Full Pi Agent support); linked: AC-14 *blocks* this Task
**Assignee**: Piotr Niemirski
**Source Story**: Story 1.2 in `extracted-tasks.md`
**Sizing guidance**: Medium (suggestion only; team estimates in refinement)

**Description**:

## Overview

Add a Pi guide section on connecting models through a flat-rate subscription (at least GitHub Copilot) instead of a pay-per-token API key, keeping paid overage off, and choosing a model tier per Implement stage.

## Business Value

Pay-per-token API access made agent work in Pi very expensive and unpredictable. A subscription sign-in caps spend at the plan price, and model tiering makes the monthly allowance last. Teams need verified, dated facts — not chat estimates — to choose a plan.

## User Story

As a team using Pi, I want guidance on signing Pi in with a flat-rate subscription and choosing models per task so that agent work never produces an unexpected pay-per-token bill and the monthly allowance lasts.

## Requirements

1. The Pi guide shows how to sign Pi in with a subscription account (at least GitHub Copilot) and how this differs from an API key.
2. The guide explains how to check that paid overage is off and what happens when the allowance runs out.
3. The guide recommends a model tier for exploration, for implementation, and for one-off hard problems, and warns against running the heaviest tier in an agent loop.
4. Every price, allowance, or overage figure links to an official vendor page and carries the date it was checked.
5. Providers whose subscription is billed as extra usage when used through Pi are described as such.
6. The guide explains how to recognize a quota error mid-session, how to continue, and how to resume from the last plan checkpoint.

## Source Context

Material: “GitHub Copilot Pro a koszty API.md” (exported Gemini chat, 2026-10-27). Material sections 1–2 and 6–7 (“Copilot Pro vs konto/API Anthropic”, “Na ile … wystarcza pula”, “Jak optymalnie dobierać modele”); requestor note that a Claude subscription through Pi still bills extra usage while Codex Pro does not. Extends AC-14 (Add full Pi Agent support). Approved scope: `docs/specs/pi-agent-support/intent-brief.md` → “Scope extension … (2026-10-27)”; quality review `docs/specs/pi-agent-support/quality-review.md`.

## Delivery Standard

This story follows full spec-driven development (mandatory under Agent Collections).

- Spec folder: `docs/specs/ac-111-pi-subscription-costs/`
- Research: `ac-111-pi-subscription-costs.research.md` — required before plan
- Plan: `ac-111-pi-subscription-costs.plan.md` — required before implementation
- Implement: load `eversis-implement` (approved plan attached)
- Review: runs inside the Implement session by default (`eversis-review`); standalone `/eversis-review` is optional
- Fine: QA comment draft per `eversis-fine-handoff` (same turn as Fine); publish to tracker only with explicit human OK

Do not start implementation without approved research and plan artifacts.

## Technical Notes

Figures in the source chat are unverified and contradict each other (300 requests vs ~1,500 credits). Confirm in Research from official GitHub and Pi docs: plan tiers, how Pi’s Copilot sign-in is metered (per prompt vs per model call), overage price, which models each plan allows, and whether the provider terms allow third-party harness use. Pi’s built-in subscription sign-in is not a “custom provider catalog”, so the current AC-14 Out of Scope line still holds.

## Acceptance Criteria

- [ ] GIVEN a reader opens the Pi guide WHEN they look for how to connect a model THEN the guide shows how to sign Pi in with a subscription account (at least GitHub Copilot) and explains how that differs from a pay-per-token API key
- [ ] GIVEN a reader follows the guide WHEN they reach billing safety THEN the guide tells them how to check that paid overage is off, and what happens in Pi when the allowance runs out
- [ ] GIVEN a reader plans an Implement session in Pi WHEN they read the model-choice section THEN they see which model tier to use for exploration, for implementation, and for one-off hard problems, and that the heaviest tier should not run in an agent loop
- [ ] GIVEN the guide states plan prices, allowance sizes, or overage rates WHEN it is published THEN each figure links to an official vendor page and carries the date it was checked
- [ ] GIVEN a provider’s subscription is billed as extra usage when used through Pi WHEN the reader compares options THEN the guide says so instead of presenting it as flat-rate
- [ ] GIVEN the subscription allowance runs out during an Implement session in Pi WHEN the person opens the guide THEN it explains how to recognize the quota error, how to continue (switch to a model included in the plan, or wait for the next period), and how to resume from the last plan checkpoint without losing work

---

### Task: Pi sessions use token-economy rules without skipping tests, review, or Fine

**Jira Key**: AC-112
**Status**: Backlog
**Issue Type**: Task
**Priority**: Medium
**Labels**: `pi-agent`, `token-economy`, `adapter`, `workshop-2026-10-27`
**Parent**: AC-115 (Epic: Full Pi Agent support); linked: AC-14 *blocks* this Task
**Assignee**: Piotr Niemirski
**Source Story**: Story 1.3 in `extracted-tasks.md`
**Sizing guidance**: Medium (suggestion only; team estimates in refinement)

**Description**:

## Overview

Ship a Pi-only set of token-economy rules with the Pi install: targeted reads, no blind repository sweeps, no build output or lockfiles, diff-sized edits, batched tool calls, and a fix-attempt limit — aligned with the framework core so quality checks, Review, and the Fine QA draft still run.

## Business Value

On a subscription allowance, every wasted read or repeated fix loop costs credits. The rule set proposed in the source material would cut lint/tests, summaries, and the QA draft; this task keeps the savings and the delivery workflow.

## User Story

As a team using Pi on a subscription allowance, I want the Pi install to ship rules that keep context and output small so that a long Implement session uses fewer credits without skipping tests, review, or the Fine handoff.

## Requirements

1. A Pi session started after a Pi install applies the token-economy rules.
2. A repeated failing fix stops at the attempt limit with the error, the approaches tried, and a question to the person.
3. A request for data in an excluded or very large file gets a targeted alternative; a full read happens only after the person confirms.
4. Lint, typecheck, and tests still run as the framework requires.
5. Review findings and the Fine QA comment draft are still produced in full.
6. Cursor-only or Claude Code-only installs do not receive these rules.
7. A framework upgrade refreshes the Pi rules and leaves the person's own project instructions untouched.

## Source Context

Material: “GitHub Copilot Pro a koszty API.md” (exported Gemini chat, 2026-10-27). Material section “Przygotuj zestaw reguł systemowych … oszczędne zużycie kontekstu i tokenów”; section 3 of “Jak optymalnie dobierać modele” (fix-loop limit, short sessions); Gate 0 decision: Pi-only, aligned with core. Extends AC-14 (Add full Pi Agent support). Approved scope: `docs/specs/pi-agent-support/intent-brief.md` → “Scope extension … (2026-10-27)”; quality review `docs/specs/pi-agent-support/quality-review.md`.

## Delivery Standard

This story follows full spec-driven development (mandatory under Agent Collections).

- Spec folder: `docs/specs/ac-112-pi-token-rules/`
- Research: `ac-112-pi-token-rules.research.md` — required before plan
- Plan: `ac-112-pi-token-rules.plan.md` — required before implementation
- Implement: load `eversis-implement` (approved plan attached)
- Review: runs inside the Implement session by default (`eversis-review`); standalone `/eversis-review` is optional
- Fine: QA comment draft per `eversis-fine-handoff` (same turn as Fine); publish to tracker only with explicit human OK

Do not start implementation without approved research and plan artifacts.

## Technical Notes

The source rule set conflicts with the core in three places: “run only the touched test file” vs `testing-and-terminal`, “no closing summaries” vs Fine QA draft, “stop after 2 attempts” vs Implement/Review continuity. Adapt the wording so the token limits cover exploration and output size, not the delivery workflow. These rules go in Pi packaging, not in the shared `.ai/` core.

## Acceptance Criteria

- [ ] GIVEN a person installs Agent Collections and chooses Pi WHEN a Pi session starts THEN token-economy rules are active in that session: targeted reads, no blind whole-repo sweeps, no reading of build output or lockfiles, diff-sized edits, and batched tool calls
- [ ] GIVEN an Implement session in Pi fails the same fix repeatedly WHEN it reaches the attempt limit THEN it stops, states the error and the approaches tried, and asks the person how to continue
- [ ] GIVEN the person asks for information found in an excluded or very large file WHEN the agent handles the request THEN it does not load the whole file, says why, and uses a targeted alternative (dependency manifest, a search for the specific entry, or a line range); it goes further only after the person confirms
- [ ] GIVEN an Implement session in Pi finishes a substantive change WHEN quality checks are due THEN lint, typecheck, and tests still run as the framework requires, and the token rules do not cut them
- [ ] GIVEN an Implement session in Pi reaches Review and Fine WHEN it reports results THEN the review findings and the QA comment draft are still produced in full
- [ ] GIVEN a person installs Agent Collections for Cursor or Claude Code only WHEN installation finishes THEN those hosts do not receive the Pi token-economy rules
- [ ] GIVEN Pi is installed and the framework is upgraded WHEN the upgrade finishes THEN the Pi token-economy rules match the new version and the person’s own project instructions are untouched

---

### Task: Pi install keeps heavy and secret files out of the agent's reach

**Jira Key**: AC-113
**Status**: Backlog
**Issue Type**: Task
**Priority**: Medium
**Labels**: `pi-agent`, `token-economy`, `security`, `workshop-2026-10-27`
**Parent**: AC-115 (Epic: Full Pi Agent support); linked: AC-14 *blocks* this Task
**Assignee**: Piotr Niemirski
**Source Story**: Story 1.4 in `extracted-tasks.md`
**Sizing guidance**: Medium (suggestion only; team estimates in refinement)

**Description**:

## Overview

Add Pi to the framework's synchronized ignore files so a Pi install excludes dependencies, lockfiles, build output, logs, media, and secrets from what the agent searches and reads. Document a canary check, troubleshooting steps, and how to limit shell access in Pi.

## Business Value

A single lockfile read can pull 100k+ tokens into one request and burn a large part of the allowance; secret files must never reach the model. Reusing the delivered synchronized ignore files keeps Pi, Cursor, and Claude Code consistent.

## User Story

As a team using Pi, I want the install to exclude dependencies, lockfiles, build output, logs, media, and secrets from what the agent can search and read so that a single request cannot pull in tens of thousands of wasted tokens or expose secrets.

## Requirements

1. A Pi install provides a default exclusion list for dependencies, lockfiles, build output, logs, media and archives, source maps and minified files, and secrets (an example env file stays readable).
2. Existing exclusion entries in the project are kept.
3. Pi and other installed agents exclude the same files when the shared list changes.
4. A framework upgrade keeps the person's own entries and refreshes the default ones.
5. The guide documents a canary check with passing and failing outcomes.
6. The guide lists troubleshooting steps when the canary check fails.
7. The guide shows how to limit shell access in Pi and states what Pi itself supports.

## Source Context

Material: “GitHub Copilot Pro a koszty API.md” (exported Gemini chat, 2026-10-27). Material sections “Jak przygotować reguły wykluczania plików”, “Jak szybko przetestować … pliki wykluczone”, “Co zrobić, jeśli agent … nadal widzi”, “Jak ograniczyć … polecenia w powłoce”. Extends AC-14 (Add full Pi Agent support). Approved scope: `docs/specs/pi-agent-support/intent-brief.md` → “Scope extension … (2026-10-27)”; quality review `docs/specs/pi-agent-support/quality-review.md`.

## Delivery Standard

This story follows full spec-driven development (mandatory under Agent Collections).

- Spec folder: `docs/specs/ac-113-pi-file-exclusions/`
- Research: `ac-113-pi-file-exclusions.research.md` — required before plan
- Plan: `ac-113-pi-file-exclusions.plan.md` — required before implementation
- Implement: load `eversis-implement` (approved plan attached)
- Review: runs inside the Implement session by default (`eversis-review`); standalone `/eversis-review` is optional
- Fine: QA comment draft per `eversis-fine-handoff` (same turn as Fine); publish to tracker only with explicit human OK

Do not start implementation without approved research and plan artifacts.

## Technical Notes

The framework already delivers synchronized ignore files across hosts (DHI-528 – DHI-530, Done). Add Pi to that mechanism instead of keeping a separate list, so Pi, Cursor and Claude Code don’t drift apart. Confirm in Research which exclusion files Pi’s read and search tools respect, and whether Pi has an approval mode or tool allow-list (AC-14 notes Pi ships no permission prompts, so this may be docs-only or extension-based).

## Acceptance Criteria

- [ ] GIVEN a person installs Agent Collections and chooses Pi WHEN installation finishes THEN a default exclusion list covers dependencies, lockfiles, build output, logs, media and archives, source maps and minified files, and secret files (keeping an example env file readable)
- [ ] GIVEN the project already has its own exclusion file WHEN the Pi install runs THEN the person’s existing entries are kept, not overwritten
- [ ] GIVEN Pi and another agent are installed WHEN the shared exclusion list changes THEN Pi and the other agents exclude the same files
- [ ] GIVEN the person added their own entries to the exclusion list WHEN the framework is upgraded THEN those entries are kept and the framework’s default entries are refreshed
- [ ] GIVEN a reader follows the Pi guide WHEN they run the documented canary check (a marker file inside an excluded folder, then ask the agent to find it) THEN the guide says what a passing and a failing result look like
- [ ] GIVEN the canary check fails WHEN the reader opens the troubleshooting section THEN it lists the next steps: files still tracked by git, a stale index, a tool that ignores the exclusion file, shell reads that bypass it
- [ ] GIVEN Pi can run shell commands WHEN a reader looks for how to limit that THEN the guide shows how to require approval before running or remove the shell tool, and states what Pi itself supports

---

### Task: Team can run the Pi agent in an isolated workspace with restricted network

**Jira Key**: AC-114
**Status**: Backlog
**Issue Type**: Task
**Priority**: Low
**Labels**: `pi-agent`, `security`, `sandbox`, `workshop-2026-10-27`
**Parent**: AC-115 (Epic: Full Pi Agent support); linked: AC-14 *blocks* this Task
**Assignee**: Piotr Niemirski
**Source Story**: Story 1.5 in `extracted-tasks.md`
**Sizing guidance**: Large (suggestion only; team estimates in refinement)

**Description**:

## Overview

Provide an opt-in, documented isolated workspace for Pi: no admin rights, no privilege escalation, CPU and memory limits, no access to files outside the project, and a choice of network modes (none, internal-only, package registries only) with verification checks.

## Business Value

Teams that let the agent run commands need confidence it cannot change their machine, read personal files or keys, or send code outside. A ready template removes per-team setup work and keeps it optional.

## User Story

As a team that lets the Pi agent run commands, I want a documented, ready-to-use isolated workspace with no admin rights, resource limits, and network access limited to package registries so that the agent cannot change my machine, read my personal files, or send code outside.

## Requirements

1. The Pi guide provides a ready isolated-workspace setup without admin rights, without privilege escalation, and with CPU and memory limits.
2. Prerequisites (container runtime) are listed before the setup steps; starting without them ends with a clear message.
3. Files outside the project folder are not visible inside the workspace.
4. Network modes: none, internal-only, or package registries only (npm, PyPI).
5. In registries-only mode, package installs work, other sites and proxy bypass attempts are refused or time out, and the model provider and framework skill server stay reachable.
6. Each documented check states the expected pass result; the guide shows how to see allowed and blocked requests.
7. Teams that do not use the isolated workspace see no change to their Pi install.

## Source Context

Material: “GitHub Copilot Pro a koszty API.md” (exported Gemini chat, 2026-10-27). Material sections “Jak przygotować prosty plik devcontainer.json”, “Jak odciąć lub ograniczyć dostęp do internetu”, “Jak przepuszczać ruch … tylko do domen rejestrów”, “Jak przetestować … czy proxy faktycznie blokuje”; Gate 0 decision to include D in AC-14. Extends AC-14 (Add full Pi Agent support). Approved scope: `docs/specs/pi-agent-support/intent-brief.md` → “Scope extension … (2026-10-27)”; quality review `docs/specs/pi-agent-support/quality-review.md`.

## Delivery Standard

This story follows full spec-driven development (mandatory under Agent Collections).

- Spec folder: `docs/specs/ac-114-pi-isolated-workspace/`
- Research: `ac-114-pi-isolated-workspace.research.md` — required before plan
- Plan: `ac-114-pi-isolated-workspace.plan.md` — required before implementation
- Implement: load `eversis-implement` (approved plan attached)
- Review: runs inside the Implement session by default (`eversis-review`); standalone `/eversis-review` is optional
- Fine: QA comment draft per `eversis-fine-handoff` (same turn as Fine); publish to tracker only with explicit human OK

Do not start implementation without approved research and plan artifacts.

## Technical Notes

Opt-in setup (Dev Container + Docker Compose, allow-list forward proxy), shipped as a documented template, not forced on every Pi install. The Pi model provider endpoint (e.g. GitHub Copilot API) must also be on the allow-list, or the agent cannot reach its model — the source chat misses this. Pin container image versions instead of `latest`. Applies to Pi but is largely host-neutral; note it for later reuse by other hosts.

## Acceptance Criteria

- [ ] GIVEN a reader wants to isolate the Pi agent WHEN they open the Pi guide THEN they find a ready isolated-workspace setup where the agent runs without admin rights, cannot raise its privileges, and has CPU and memory limits
- [ ] GIVEN a reader opens the isolated-workspace section WHEN they do not have the required container runtime THEN the guide lists the prerequisites before the setup steps, and starting the workspace without them ends with a clear message instead of a half-configured environment
- [ ] GIVEN the isolated workspace is running WHEN the agent tries to read files outside the project folder (home directory, SSH keys) THEN those files are not visible
- [ ] GIVEN the guide offers network options WHEN the reader chooses one THEN they can pick no network, internal-only (local services such as a database), or package registries only (npm, PyPI)
- [ ] GIVEN the registries-only option is active WHEN the agent installs a package from npm or PyPI THEN it succeeds, and WHEN it contacts any other site, or tries to bypass the proxy THEN the request is refused or times out
- [ ] GIVEN the registries-only network is active WHEN a Pi session sends a prompt to its configured model provider and uses the framework’s skill server THEN both work, and every other address stays blocked
- [ ] GIVEN a reader set up the isolated workspace WHEN they run the documented checks THEN each check states the expected pass result, and the guide shows how to see allowed and blocked requests
- [ ] GIVEN a team does not use the isolated workspace WHEN they install Agent Collections for Pi THEN nothing about their normal install changes

---

### Update: AC-14 — Add full Pi Agent support

**Jira Key**: AC-14
**Status**: In Progress (not protected)
**Change**: Out of Scope, third bullet only. All other fields unchanged.

Before:

- Pi themes, custom model or provider catalogs, embedding Pi in another app, and sandbox setup

After:

- Pi themes, custom model or provider catalogs, embedding Pi in another app; sandbox setup beyond the opt-in isolated workspace (tracked as its own Task: AC-114)


---

### Epic: Full Pi Agent support

**Jira Key**: AC-115
**Issue Type**: Epic
**Status**: Backlog
**Assignee**: Piotr Niemirski
**Children**: AC-14, AC-111, AC-112, AC-113, AC-114

Added 2026-10-27 after push, at requestor's request to put AC-111 – AC-114 "under AC-14". AC-14 is a Task and cannot parent Tasks, so an Epic now groups AC-14 and the four Tasks as siblings (AC backlog rule: Epic → Task). The *AC-14 blocks* links stay. AC-21 (Sub-task of AC-14) is unchanged. Verified via JQL `parent = AC-115` (5 children, all assigned to Piotr Niemirski).
