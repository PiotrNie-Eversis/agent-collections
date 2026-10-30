# Pi Agent support — Extracted Tasks

## Workshop Summary

| Field | Value |
|---|---|
| Workshop Date | 2026-09-21 |
| Participants | Requestor (chat) |
| Source Materials | Chat request; [https://pi.dev/](https://pi.dev/); [Pi documentation](https://pi.dev/docs); adapter mapping; Jira AC and DHI |
| Intent Brief | `docs/specs/pi-agent-support/intent-brief.md` (Approved 2026-09-21) |
| Project Baseline Used | `docs/context/agent-collections/task-baseline.md` |
| Total Epics | 1 |
| Total Stories | 1 |

The requestor asked for **one ticket** on the AC board. Epic and story below are the breakdown; Jira creation uses a single Task that carries this story.

## Epics Overview

| # | Epic Title | Stories Count | Priority |
|---|-----------|---------------|----------|
| 1 | Full Pi Agent support | 1 | Medium |

## Epic 1: Full Pi Agent support

**Business Description**: Teams that work in Pi can install Agent Collections and use its rules, skills, and prompt templates in a Pi session, at the same kind of support Cursor and Claude Code already have. The framework stays one shared core; Pi is another way to use it.

**Success Criteria**:
- A person can choose Pi when installing Agent Collections and then use the framework’s rules, skills, and prompt templates in Pi.
- A long Implement session in Pi compacts at about half the context window before the current task is dropped. Cursor and Claude Code do not use that window-fill trigger.
- Docs and the install choice list name Pi as a supported agent and say what that install provides.
- Teams that do not choose Pi are unaffected.

### Story 1.1: Team can use Agent Collections in Pi

**User Story**: As a team using Pi, I want to install Agent Collections for Pi so that the same rules, skills, and prompts are available in a Pi session, and a long session compacts at about 50% of the context window before the current task is lost.

**Source**: Chat request 2026-09-21 (“Dodanie pełnej obsługi PI Agent”, [https://pi.dev/](https://pi.dev/)); approved intent brief. Pi customization surfaces used as scope boundary: skills, prompt templates, and project instructions ([Pi documentation](https://pi.dev/docs)).

**Acceptance Criteria**:
- [ ] GIVEN a person installs Agent Collections and chooses Pi WHEN installation finishes THEN a Pi session can use the framework’s rules, skills, and prompt templates
- [ ] GIVEN Pi is a supported choice WHEN a reader opens the install guidance or the public docs THEN Pi is listed as a supported agent and the page says what the install provides
- [ ] GIVEN a person installs Agent Collections and does not choose Pi WHEN installation finishes THEN Pi packaging is not added and the other selected agents still work
- [ ] GIVEN a person chooses Pi and Pi setup cannot be completed WHEN installation finishes THEN they see a clear failure and any other agents they selected are unaffected
- [ ] GIVEN an Implement session is running in Pi WHEN the context window reaches about half its capacity THEN the session compacts under that ~50% budget before the current task is dropped
- [ ] GIVEN an Implement session is running in Cursor or Claude Code WHEN the context window fills THEN that session does not checkpoint or end because of window fill

**Additional Acceptance Checks**:
- Support is shipped and usable, not a config-only placeholder.

**High-Level Technical Notes**: AC-2 plan (`docs/specs/ac-2/ac-2.plan.md`), Open Question 6 and Improvements: restore the ~50% session budget only on Pi, using host usage visibility (`context_info`) and Pi’s existing 50% extension (`pi-rolling-compaction`), plus the Pi install settings that follow when that host is installed. Do not add the window-percent trigger back to rule 14 for Cursor or Claude Code.

**Priority**: Medium

## Dependencies

| Task | Depends On | Type | Notes |
|------|-----------|------|-------|
| Story 1.1 | — | — | No blocking dependency. Cursor and Claude Code adapters already exist and stay as they are. |

## Assumptions

| # | Assumption | Confidence | Impact if Wrong |
|---|-----------|------------|-----------------|
| 1 | “Full support” means a shipped Pi adapter for rules, skills, prompt templates, install selection, and docs. | High | If the requestor also wants Pi extensions for MCP, sub-agents, or plan mode, those become new stories. |
| 2 | One Jira Task on project AC is the requested delivery, not an epic plus child stories. | High | A later split can parent follow-on stories under a new epic. |
| 3 | Priority is Medium because the request did not rank it against current AC work. | Medium | Reprioritize in Jira if this should jump the context-flow backlog. |

## Out of Scope

Items explicitly excluded from this task breakdown:
- Promoting OpenCode from placeholder to full support
- Rewriting the vendor-neutral framework core
- Pi themes, custom model or provider catalogs, embedding Pi in another app, and sandbox setup
- Building capabilities Pi does not ship (MCP, sub-agents, plan mode, permission prompts, built-in to-dos, background shell)
- Changing the delivery workflow

## Open Questions for Stakeholders

| # | Question | Context | Impact |
|---|----------|---------|--------|
| — | None | Gate 0 approved with the scope above | — |

---

# Scope extension 2026-10-27 — cost-predictable model access and token economy in Pi

| Field | Value |
|---|---|
| Date | 2026-10-27 |
| Source Materials | “GitHub Copilot Pro a koszty API.md” (Gemini chat export); Jira AC-14 (In Progress, sub-task AC-21) |
| Intent Brief | `intent-brief.md` → section “Scope extension … (2026-10-27)”, Gate 0 Approved 2026-10-27 |
| Delivery | Four standalone Jira **Tasks** in project AC (no parent; AC-14 is a Task, so it cannot be their parent), each linked to AC-14 as *is blocked by*. AC-14 story and acceptance criteria stay unchanged, except one narrowed Out of Scope line (see below). Changed from Sub-tasks on 2026-10-27 at requestor’s request, in line with `docs/context/agent-collections/jira-backlog-hierarchy` (Sub-task is never the leaf on the AC board). |
| Total Stories | 4 |
| Quality Review | Lite, 2026-10-27 — S-01 – S-06 accepted (see `quality-review.md`) |

## Epic 1 (continued): Full Pi Agent support

**Added success criterion**: A team using Agent Collections in Pi can keep model spend predictable and its workspace contained: it signs in with a flat-rate subscription, Implement sessions spend little context, heavy files stay out of reach, and the agent can run in an isolated workspace.

### Story 1.2: Team signs Pi in with a subscription and keeps model costs predictable

**User Story**: As a team using Pi, I want guidance on signing Pi in with a flat-rate subscription and choosing models per task so that agent work never produces an unexpected pay-per-token bill and the monthly allowance lasts.

**Source**: Material sections 1–2 and 6–7 (“Copilot Pro vs konto/API Anthropic”, “Na ile … wystarcza pula”, “Jak optymalnie dobierać modele”); requestor note that a Claude subscription through Pi still bills extra usage while Codex Pro does not.

**Acceptance Criteria**:
- [ ] GIVEN a reader opens the Pi guide WHEN they look for how to connect a model THEN the guide shows how to sign Pi in with a subscription account (at least GitHub Copilot) and explains how that differs from a pay-per-token API key
- [ ] GIVEN a reader follows the guide WHEN they reach billing safety THEN the guide tells them how to check that paid overage is off, and what happens in Pi when the allowance runs out
- [ ] GIVEN a reader plans an Implement session in Pi WHEN they read the model-choice section THEN they see which model tier to use for exploration, for implementation, and for one-off hard problems, and that the heaviest tier should not run in an agent loop
- [ ] GIVEN the guide states plan prices, allowance sizes, or overage rates WHEN it is published THEN each figure links to an official vendor page and carries the date it was checked
- [ ] GIVEN a provider’s subscription is billed as extra usage when used through Pi WHEN the reader compares options THEN the guide says so instead of presenting it as flat-rate
- [ ] GIVEN the subscription allowance runs out during an Implement session in Pi WHEN the person opens the guide THEN it explains how to recognize the quota error, how to continue (switch to a model included in the plan, or wait for the next period), and how to resume from the last plan checkpoint without losing work

**High-Level Technical Notes**: Figures in the source chat are unverified and contradict each other (300 requests vs ~1,500 credits). Confirm in Research from official GitHub and Pi docs: plan tiers, how Pi’s Copilot sign-in is metered (per prompt vs per model call), overage price, which models each plan allows, and whether the provider terms allow third-party harness use. Pi’s built-in subscription sign-in is not a “custom provider catalog”, so the current AC-14 Out of Scope line still holds.

**Priority**: Medium

### Story 1.3: Pi sessions follow token-economy rules that keep the delivery workflow intact

**User Story**: As a team using Pi on a subscription allowance, I want the Pi install to ship rules that keep context and output small so that a long Implement session uses fewer credits without skipping tests, review, or the Fine handoff.

**Source**: Material section “Przygotuj zestaw reguł systemowych … oszczędne zużycie kontekstu i tokenów”; section 3 of “Jak optymalnie dobierać modele” (fix-loop limit, short sessions); Gate 0 decision: Pi-only, aligned with core.

**Acceptance Criteria**:
- [ ] GIVEN a person installs Agent Collections and chooses Pi WHEN a Pi session starts THEN token-economy rules are active in that session: targeted reads, no blind whole-repo sweeps, no reading of build output or lockfiles, diff-sized edits, and batched tool calls
- [ ] GIVEN an Implement session in Pi fails the same fix repeatedly WHEN it reaches the attempt limit THEN it stops, states the error and the approaches tried, and asks the person how to continue
- [ ] GIVEN the person asks for information found in an excluded or very large file WHEN the agent handles the request THEN it does not load the whole file, says why, and uses a targeted alternative (dependency manifest, a search for the specific entry, or a line range); it goes further only after the person confirms
- [ ] GIVEN an Implement session in Pi finishes a substantive change WHEN quality checks are due THEN lint, typecheck, and tests still run as the framework requires, and the token rules do not cut them
- [ ] GIVEN an Implement session in Pi reaches Review and Fine WHEN it reports results THEN the review findings and the QA comment draft are still produced in full
- [ ] GIVEN a person installs Agent Collections for Cursor or Claude Code only WHEN installation finishes THEN those hosts do not receive the Pi token-economy rules
- [ ] GIVEN Pi is installed and the framework is upgraded WHEN the upgrade finishes THEN the Pi token-economy rules match the new version and the person’s own project instructions are untouched

**High-Level Technical Notes**: The source rule set conflicts with the core in three places: “run only the touched test file” vs `testing-and-terminal`, “no closing summaries” vs Fine QA draft, “stop after 2 attempts” vs Implement/Review continuity. Adapt the wording so the token limits cover exploration and output size, not the delivery workflow. These rules go in Pi packaging, not in the shared `.ai/` core.

**Priority**: Medium

### Story 1.4: Pi install keeps heavy and secret files out of the agent’s reach

**User Story**: As a team using Pi, I want the install to exclude dependencies, lockfiles, build output, logs, media, and secrets from what the agent can search and read so that a single request cannot pull in tens of thousands of wasted tokens or expose secrets.

**Source**: Material sections “Jak przygotować reguły wykluczania plików”, “Jak szybko przetestować … pliki wykluczone”, “Co zrobić, jeśli agent … nadal widzi”, “Jak ograniczyć … polecenia w powłoce”.

**Acceptance Criteria**:
- [ ] GIVEN a person installs Agent Collections and chooses Pi WHEN installation finishes THEN a default exclusion list covers dependencies, lockfiles, build output, logs, media and archives, source maps and minified files, and secret files (keeping an example env file readable)
- [ ] GIVEN the project already has its own exclusion file WHEN the Pi install runs THEN the person’s existing entries are kept, not overwritten
- [ ] GIVEN Pi and another agent are installed WHEN the shared exclusion list changes THEN Pi and the other agents exclude the same files
- [ ] GIVEN the person added their own entries to the exclusion list WHEN the framework is upgraded THEN those entries are kept and the framework’s default entries are refreshed
- [ ] GIVEN a reader follows the Pi guide WHEN they run the documented canary check (a marker file inside an excluded folder, then ask the agent to find it) THEN the guide says what a passing and a failing result look like
- [ ] GIVEN the canary check fails WHEN the reader opens the troubleshooting section THEN it lists the next steps: files still tracked by git, a stale index, a tool that ignores the exclusion file, shell reads that bypass it
- [ ] GIVEN Pi can run shell commands WHEN a reader looks for how to limit that THEN the guide shows how to require approval before running or remove the shell tool, and states what Pi itself supports

**High-Level Technical Notes**: The framework already delivers synchronized ignore files across hosts (DHI-528 – DHI-530, Done). Add Pi to that mechanism instead of keeping a separate list, so Pi, Cursor and Claude Code don’t drift apart. Confirm in Research which exclusion files Pi’s read and search tools respect, and whether Pi has an approval mode or tool allow-list (AC-14 notes Pi ships no permission prompts, so this may be docs-only or extension-based).

**Priority**: Medium

### Story 1.5: Team can run the Pi agent in an isolated workspace with restricted network

**User Story**: As a team that lets the Pi agent run commands, I want a documented, ready-to-use isolated workspace with no admin rights, resource limits, and network access limited to package registries so that the agent cannot change my machine, read my personal files, or send code outside.

**Source**: Material sections “Jak przygotować prosty plik devcontainer.json”, “Jak odciąć lub ograniczyć dostęp do internetu”, “Jak przepuszczać ruch … tylko do domen rejestrów”, “Jak przetestować … czy proxy faktycznie blokuje”; Gate 0 decision to include D in AC-14.

**Acceptance Criteria**:
- [ ] GIVEN a reader wants to isolate the Pi agent WHEN they open the Pi guide THEN they find a ready isolated-workspace setup where the agent runs without admin rights, cannot raise its privileges, and has CPU and memory limits
- [ ] GIVEN a reader opens the isolated-workspace section WHEN they do not have the required container runtime THEN the guide lists the prerequisites before the setup steps, and starting the workspace without them ends with a clear message instead of a half-configured environment
- [ ] GIVEN the isolated workspace is running WHEN the agent tries to read files outside the project folder (home directory, SSH keys) THEN those files are not visible
- [ ] GIVEN the guide offers network options WHEN the reader chooses one THEN they can pick no network, internal-only (local services such as a database), or package registries only (npm, PyPI)
- [ ] GIVEN the registries-only option is active WHEN the agent installs a package from npm or PyPI THEN it succeeds, and WHEN it contacts any other site, or tries to bypass the proxy THEN the request is refused or times out
- [ ] GIVEN the registries-only network is active WHEN a Pi session sends a prompt to its configured model provider and uses the framework’s skill server THEN both work, and every other address stays blocked
- [ ] GIVEN a reader set up the isolated workspace WHEN they run the documented checks THEN each check states the expected pass result, and the guide shows how to see allowed and blocked requests
- [ ] GIVEN a team does not use the isolated workspace WHEN they install Agent Collections for Pi THEN nothing about their normal install changes

**High-Level Technical Notes**: Opt-in setup (Dev Container + Docker Compose, allow-list forward proxy), shipped as a documented template, not forced on every Pi install. The Pi model provider endpoint (e.g. GitHub Copilot API) must also be on the allow-list, or the agent cannot reach its model — the source chat misses this. Pin container image versions instead of `latest`. Applies to Pi but is largely host-neutral; note it for later reuse by other hosts.

**Priority**: Low

## Dependencies

| Task | Depends On | Type | Notes |
|------|-----------|------|-------|
| Story 1.2 – 1.5 | Story 1.1 (AC-14 core Pi install) | Blocks | Pi packaging and the Pi guide must exist first |
| Story 1.4 | DHI-528 – DHI-530 | Relates | Delivered (Done): synchronized ignore files; Pi is added to that mechanism |
| Story 1.5 | Story 1.2 | Relates | Registries-only network must also allow the model provider chosen in 1.2 |
| Story 1.3 | AC-21 | Relates | Both shape context use in long Pi sessions (~50% budget vs token rules) |

## Assumptions

| # | Assumption | Confidence | Impact if Wrong |
|---|-----------|------------|-----------------|
| 1 | Pi’s built-in GitHub Copilot sign-in draws from the subscription allowance and never bills overage while the spending limit is $0. | Medium | If metering differs (e.g. each model call counts), Story 1.2 guidance and model tiering change; verify in Research. |
| 2 | Pricing figures in the source chat are not reliable and will be replaced with dated, linked figures from vendor pages. | High | — |
| 3 | The isolated workspace is opt-in documentation plus a template, not a default part of every Pi install. | High | If it must be default, Story 1.5 needs install-flow AC and failure handling. |
| 4 | Each story is delivered as a standalone Task on project AC, linked to AC-14 (*is blocked by*), per the AC backlog hierarchy rule. | High | If an Epic should group AC-14 and these Tasks, create it and set it as their parent. |

## Change to AC-14 (needed by Gate 0)

- AC-14 **Out of Scope** currently says “… embedding Pi in another app, and sandbox setup”. Narrow it to: “… embedding Pi in another app; sandbox setup beyond the opt-in isolated workspace (tracked as its own Task, Story 1.5)”. No other change to AC-14 description or acceptance criteria.

## Out of Scope (extension)

- Token-economy rules for Cursor or Claude Code (Pi-only by decision)
- Comparing or recommending vendors beyond the facts needed to keep Pi costs predictable
- Automatic cost tracking or usage dashboards inside Agent Collections
- Making the isolated workspace mandatory

## Open Questions for Stakeholders

| # | Question | Context | Impact |
|---|----------|---------|--------|
| — | None blocking | Vendor facts (pricing, metering, terms) are Research items inside Story 1.2 | — |
