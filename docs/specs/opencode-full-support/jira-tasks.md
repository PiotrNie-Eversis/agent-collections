# OpenCode full support — Jira Tasks

Board convention on project AC for this kind of request is a single **Task** (see AC-14, “Add full Pi Agent support”). The approved scope is pushed as one task. The seven-story breakdown in `extracted-tasks.md` stays local.

## Task: Add full OpenCode support

**Jira Key**: AC-15
**Status**: Backlog
**Issue Type**: Task
**Priority**: High
**Parent**: —
**Labels**: `adapter`, `opencode`, `workshop-2026-09-21`
**Sizing guidance**: Large (team estimates during refinement)

**Description**:

```
## Overview

Promote OpenCode from a placeholder to a supported agent in Agent Collections. A team that chooses OpenCode at install can use the framework’s rules, prompts, and skills in an OpenCode session, in the same way Cursor and Claude Code users already can.

## Business Value

Teams that work in [OpenCode](https://opencode.ai/) only get a placeholder today. Cursor and Claude Code are shipped agents. This task makes OpenCode a supported channel without a second copy of the framework.

## User Story

As a team using OpenCode, I want to install Agent Collections for OpenCode so that the same delivery rules, prompts, and skills are available in an OpenCode session.

## Requirements

1. A person installing Agent Collections can choose OpenCode, and the choice is presented as a supported agent, not a placeholder.
2. After that choice, an OpenCode session follows the same delivery standard and can use the framework’s rules, public prompts, and skills.
3. Public docs and the install choice list name OpenCode as a supported agent and say what the install provides.
4. The OpenCode setup is produced from the shared core when that core changes. The core stays vendor-neutral.
5. An OpenCode session does not load Cursor or Claude Code packaging, and those agents do not load OpenCode packaging.
6. Choosing not to include OpenCode leaves other selected agents unchanged.

## Source Context

Chat request 2026-09-21, “Dodanie pełnej obsługi Open Code”, https://opencode.ai/. Approved intent brief: `docs/specs/opencode-full-support/intent-brief.md`. Story 1.1 approved in chat before push.

## Out of Scope

* The OpenCode product itself (models, Zen, accounts, share links, desktop app)
* Rewriting the shared core into an OpenCode-specific format
* OpenCode-only capabilities with no Cursor or Claude Code equivalent (custom agent modes, permission policies, provider login)
* Pi Agent support (AC-14)

## Delivery Standard

This story follows full spec-driven development (mandatory under Agent Collections).

* Spec folder: `docs/specs/<issue-kebab>/`
* Research: `<issue-kebab>.research.md` — required before plan
* Plan: `<issue-kebab>.plan.md` — required before implementation
* Implement: load `eversis-implement` (approved plan attached)
* Review: runs inside the Implement session by default (`eversis-review`); standalone `/eversis-review` is optional
* Fine: QA comment draft per `eversis-fine-handoff` (same turn as Fine); publish to tracker only with explicit human OK

Do not start implementation without approved research and plan artifacts.

Optional (Cursor): you may also attach the same prompts with `@eversis-implement` / `@eversis-review` if the project surfaces those files in Cursor.

## Technical Notes

OpenCode is a placeholder today (historical TASK-525). No OpenCode-only product features were discussed. Target product: [OpenCode](https://opencode.ai/).

## Acceptance Criteria

* GIVEN a person installs Agent Collections and chooses OpenCode WHEN installation finishes THEN the installer treats OpenCode as a supported agent and an OpenCode session can use the framework’s rules, prompts, and skills
* GIVEN the installer offers OpenCode WHEN the person reads the choice THEN the label does not say the agent is a placeholder
* GIVEN OpenCode is a supported choice WHEN a reader opens the install guidance or the public docs THEN OpenCode is listed with Cursor and Claude Code as a supported agent
* GIVEN the shared framework core changes WHEN agent packaging is refreshed THEN the OpenCode setup updates with the other agents and the core text stays vendor-neutral
* GIVEN a project has more than one agent installed WHEN someone works in OpenCode THEN that session does not load Cursor or Claude Code packaging, and those agents do not load OpenCode packaging
* GIVEN a person installs Agent Collections and does not choose OpenCode WHEN installation finishes THEN OpenCode packaging is not added and the other selected agents still work
```

## Completeness

| Task | Required fields | Notes |
|---|---|---|
| Add full OpenCode support | Complete | Single Task, matching AC-14. Priority High from the approved epic. |
