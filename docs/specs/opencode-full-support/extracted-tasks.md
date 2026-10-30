# OpenCode full support — Extracted Tasks

## Workshop Summary

| Field | Value |
|---|---|
| Workshop Date | 2026-09-21 |
| Participants | Piotr Niemirski (request owner) |
| Source Materials | User request “Dodanie pełnej obsługi Open Code”; [OpenCode](https://opencode.ai/); approved `intent-brief.md`; current placeholder packaging; `docs/context/agent-collections/task-baseline.md` |
| Intent Brief | `docs/specs/opencode-full-support/intent-brief.md` (Gate 0 Approved 2026-09-21) |
| Project Baseline Used | `docs/context/agent-collections/task-baseline.md` |
| Total Epics | 1 |
| Total Stories | 7 |

## Epics Overview

| # | Epic Title | Stories Count | Priority |
|---|-----------|---------------|----------|
| 1 | OpenCode as a supported Agent Collections channel | 7 | High |

## Epic 1: OpenCode as a supported Agent Collections channel

**Business Description**: Teams that work in OpenCode get the same Agent Collections delivery experience they already have in Cursor and Claude Code. Install, documentation, and day-to-day sessions treat OpenCode as a supported agent instead of a placeholder.

**Success Criteria**:
- A consumer can install Agent Collections for OpenCode and is not told the agent is unfinished.
- An OpenCode session follows the framework delivery standard and can use the same rules, prompts, and skills as the other supported agents.
- Public docs describe OpenCode as supported.
- When the shared framework core changes, the OpenCode setup stays aligned.
- OpenCode sessions stay isolated from Cursor and Claude Code packaging.

### Story 1.1: Consumer can install Agent Collections for OpenCode as a supported agent

**User Story**: As a consumer team lead, I want to choose OpenCode during installation and receive a supported Agent Collections setup, so that my team can adopt OpenCode without being warned that the agent is only a placeholder.

**Source**: Approved intent brief — “In Scope” (install-time selection); baseline TASK-525 (placeholder only, not this outcome).

**Acceptance Criteria**:
- [ ] GIVEN a consumer is installing Agent Collections WHEN they choose OpenCode THEN the installer treats OpenCode as a supported agent, in the same class as Cursor and Claude Code
- [ ] GIVEN the installer offers OpenCode WHEN the consumer reads the choice THEN the label does not say the agent is a placeholder or an unfinished adapter
- [ ] GIVEN installation for OpenCode completes WHEN the consumer opens the project in OpenCode THEN Agent Collections is ready to use without a separate manual copy of framework files

**High-Level Technical Notes**: None

**Priority**: High

### Story 1.2: OpenCode session follows the same delivery standard

**User Story**: As an engineer using OpenCode, I want the session to follow the Agent Collections delivery standard, so that research, planning, implementation, review, and handoff behave the same as on the other supported agents.

**Source**: Approved intent brief — “In Scope” (session loads rules and follows Ideate → Research → Plan → Implement → Review → Fine).

**Acceptance Criteria**:
- [ ] GIVEN Agent Collections is installed for OpenCode WHEN an engineer starts a session THEN the session loads the framework delivery rules
- [ ] GIVEN those rules are loaded WHEN the engineer runs a delivery workflow THEN the session expects the same stage order and human approval gates as Cursor and Claude Code
- [ ] GIVEN the shared delivery rules change in the framework core WHEN OpenCode is set up again THEN the session follows the updated rules

**High-Level Technical Notes**: None

**Priority**: High

### Story 1.3: Engineer can start the same framework prompts in OpenCode

**User Story**: As an engineer using OpenCode, I want to start the same Agent Collections prompts I use on the other agents, so that I do not keep a second set of instructions only for OpenCode.

**Source**: Approved intent brief — “In Scope” (prompts load in an OpenCode session); parity bar confirmed with Gate 0 (same class of outcomes as Claude Code, including prompts).

**Acceptance Criteria**:
- [ ] GIVEN Agent Collections is installed for OpenCode WHEN the engineer looks for framework prompts THEN the same public prompts are available as on Claude Code
- [ ] GIVEN a public prompt exists in the framework WHEN the engineer starts it in OpenCode THEN the session follows that prompt
- [ ] GIVEN a new public prompt is added to the framework WHEN OpenCode is set up again THEN that prompt is available without a hand-maintained OpenCode-only copy

**High-Level Technical Notes**: None

**Priority**: High

### Story 1.4: Engineer can use the same framework skills in OpenCode

**User Story**: As an engineer using OpenCode, I want to use the same Agent Collections skills as on the other supported agents, so that domain guidance stays consistent no matter which agent the team picked.

**Source**: Approved intent brief — “In Scope” (skills load in an OpenCode session); parity bar confirmed with Gate 0.

**Acceptance Criteria**:
- [ ] GIVEN Agent Collections is installed for OpenCode WHEN the engineer needs a framework skill THEN that skill is available in the session
- [ ] GIVEN the consumer stack policy says a skill should not load WHEN the engineer works in OpenCode THEN that skill stays out of scope the same way it does on the other agents
- [ ] GIVEN a skill is added or updated in the framework WHEN OpenCode is set up again THEN the session uses the updated skill

**High-Level Technical Notes**: None

**Priority**: High

### Story 1.5: Reader sees OpenCode described as a supported agent

**User Story**: As a reader of the getting-started docs, I want OpenCode described as a supported agent, so that I can tell it is a real choice and not an unfinished extra.

**Source**: Approved intent brief — “In Scope” (getting-started docs and the public adapter description stop calling OpenCode a placeholder).

**Acceptance Criteria**:
- [ ] GIVEN a reader opens the getting-started or installation docs WHEN they look up supported agents THEN OpenCode is listed with Cursor and Claude Code
- [ ] GIVEN those pages WHEN the reader looks for status wording THEN they do not describe OpenCode as a placeholder or as “not a full adapter”
- [ ] GIVEN the public description of what each agent receives WHEN the reader compares channels THEN OpenCode’s description matches the supported outcomes (rules, prompts, and skills), not the old stub

**High-Level Technical Notes**: None

**Priority**: Medium

### Story 1.6: OpenCode setup stays aligned when the shared framework changes

**User Story**: As a framework maintainer, I want the OpenCode setup to be produced from the shared core whenever that core changes, so that OpenCode does not drift behind Cursor and Claude Code.

**Source**: Approved intent brief — “In Scope” (packaging stays generated from the shared core; core stays vendor-neutral). Baseline TASK-525 shipped a hand-maintained stub only.

**Acceptance Criteria**:
- [ ] GIVEN the shared framework core changes WHEN maintainers refresh agent packaging THEN the OpenCode setup updates together with the Cursor and Claude Code setups
- [ ] GIVEN that refresh WHEN someone compares the OpenCode setup with the core THEN OpenCode packaging reflects the core and does not require a separate hand copy
- [ ] GIVEN the refresh WHEN someone inspects the shared core THEN the core text is still vendor-neutral and has not been rewritten into an OpenCode-specific format

**High-Level Technical Notes**: The current OpenCode config is a hand-maintained placeholder. This story is the business outcome that replaces that hand copy. No OpenCode-only product features are in scope.

**Priority**: High

### Story 1.7: OpenCode session stays isolated from the other agents

**User Story**: As a consumer team lead, I want an OpenCode session to ignore Cursor and Claude Code packaging, and those agents to ignore OpenCode packaging, so that each tool only sees its own Agent Collections setup.

**Source**: Approved intent brief — “In Scope” (existing cross-tool isolation stays).

**Acceptance Criteria**:
- [ ] GIVEN a project has Agent Collections installed for more than one agent WHEN an engineer works in OpenCode THEN the session does not load Cursor or Claude Code packaging
- [ ] GIVEN the same project WHEN an engineer works in Cursor or Claude Code THEN that session does not load OpenCode packaging
- [ ] GIVEN OpenCode becomes a supported agent WHEN isolation is checked THEN the existing separation still holds

**High-Level Technical Notes**: None

**Priority**: Medium

## Dependencies

| Task | Depends On | Type | Notes |
|------|-----------|------|-------|
| Story 1.2 | Story 1.6 | Blocked by | Delivery rules in OpenCode come from the generated setup, not a one-off copy |
| Story 1.3 | Story 1.6 | Blocked by | Prompts stay available after core changes only if packaging is generated |
| Story 1.4 | Story 1.6 | Blocked by | Skills stay available after core changes only if packaging is generated |
| Story 1.1 | Story 1.2 | Blocked by | The installer should offer OpenCode as supported only once a session can follow the delivery standard |
| Story 1.5 | Story 1.1 | Blocked by | Docs should call OpenCode supported only once install matches that claim |
| Story 1.7 | Story 1.6 | Related to | Isolation must still hold after packaging is generated; it does not block the first generated setup |
| Story 1.3 | Story 1.2 | Related to | Prompts assume the delivery rules are already in the session |
| Story 1.4 | Story 1.2 | Related to | Skills assume the delivery rules are already in the session |

## Assumptions

| # | Assumption | Confidence | Impact if Wrong |
|---|-----------|------------|-----------------|
| 1 | “Supported” means the same class of outcomes as Claude Code today: delivery rules, public prompts, skills, a real install choice, and docs that do not say placeholder. | High | Extra OpenCode-only capabilities would need new stories; a thinner bar would drop stories 1.3 and 1.4 |
| 2 | The new epic is created in Jira project DHI as a sibling of the finished epic DHI-515, not as its child. | High | Push would target the wrong parent |
| 3 | Historical TASK-525 stays closed as the placeholder manifest. This breakdown does not reopen it. | High | Overlap review would need a delta on the old item instead of a new epic |
| 4 | One epic is enough. Install, session behavior, docs, generation, and isolation are stories under that epic. | High | A second epic would be needed if docs or isolation should be funded separately |

## Out of Scope

Items explicitly excluded from this task breakdown:
- The OpenCode product itself (models, Zen, accounts, share links, desktop app)
- Rewriting the shared core into an OpenCode-specific format
- OpenCode-only capabilities with no Cursor or Claude Code equivalent (custom agent modes, permission policies, provider login)
- Re-opening finished epic DHI-515 or the docs UX epic DHI-641
- Changing the historical placeholder task TASK-525

## Open Questions for Stakeholders

| # | Question | Context | Impact |
|---|----------|---------|--------|
| — | None | Gate 0 approval closed the parity bar and the DHI sibling-epic home | — |
