# Spec folder naming — Jira Tasks

AC-2 is a Task. A child under it is a Sub-task, same as AC-22. Local stories stay in `extracted-tasks.md`. They are not separate Jira issues.

## Sub-task 1: Name new spec folders with the ticket key and a short topic

| Field | Value |
|---|---|
| Summary | Name new spec folders with the ticket key and a short topic |
| Issue Type | Sub-task |
| Parent | AC-2 |
| Priority | Medium |
| Labels | specs, naming, workshop-2026-09-24 |
| Sizing guidance | Small (team estimates during refinement) |
| Jira Key | [AC-32](https://eversis.atlassian.net/browse/AC-32) |
| Status | Backlog |

### Description

## Overview

New spec folders and their research and plan files put the ticket key first and a topic of at most three words after it. Implement, given only the key, opens that folder and does not create a second key-only folder. The first heading of a new research file states the topic.

## Business Value

A folder named only `ac-2` cannot be judged in a name search. A folder that starts with the topic breaks the lookup Implement already uses. This task makes the written rule, the lookup, and the research heading agree.

## User Story

As a maintainer, I want a new spec folder named with the ticket key and a short topic so that the folder can be found by the key and recognized by the topic.

## Requirements

1. The Delivery Standard example starts with the ticket key and continues with at most three topic words, in the shape `ac-2-context-management`. Research and plan file names repeat that folder name. The block copied into Jira uses the same shape. `docs/specs/README.md` does not contradict it. A topic-first name is not the example.
2. Given `ac-2-context-management` and no `ac-2` folder, Implement for AC-2 uses the topic folder and does not create `docs/specs/ac-2/`. Two folders that start with the same key stop the session and ask which one, instead of picking in silence or creating a third.
3. The research template's first heading includes a topic. Existing research files whose heading is only the key stay unchanged.

## Source Context

Gate 0 approved 2026-09-24. Story 1.1 approved the same day, including the three-word cap. The user asked for one ticket under AC-2. Local artifacts: `docs/specs/spec-folder-naming/`.

## Out of Scope

* Renaming existing spec folders
* Rewriting headings inside existing research files
* An `INDEX.md` row per ticket, or a change to when promotion runs
* Topic-first folder names

## Delivery Standard

This story follows full spec-driven development (mandatory under Agent Collections).

* Spec folder: `docs/specs/spec-folder-naming/`
* Research: `spec-folder-naming.research.md` — required before plan
* Plan: `spec-folder-naming.plan.md` — required before implementation
* Implement: load `eversis-implement` (approved plan attached)
* Review: runs inside the Implement session by default (`eversis-review`); standalone `/eversis-review` is optional
* Fine: QA comment draft per `eversis-fine-handoff` (same turn as Fine); publish to tracker only with explicit human OK

Do not start implementation without approved research and plan artifacts.

Optional (Cursor): you may also attach the same prompts with `@eversis-implement` / `@eversis-review` if the project surfaces those files in Cursor.

## Technical Notes

The convention text is in `.ai/rules/orchestration/spec-driven-development.md`, including the Delivery Standard copy block, and in `docs/specs/README.md`. The lookup is the Implement readiness step that inspects `docs/specs/<issue>/`. The research template heading is `# <TASK_NAME> - Analysis Result` in `eversis-task-analysing`.

## Acceptance Criteria

* GIVEN the Delivery Standard WHEN a reader looks up a spec folder THEN the example starts with the ticket key and has at most three topic words after it, in the shape `ac-2-context-management`
* GIVEN that standard WHEN a reader looks up research and plan file names THEN those names repeat the folder name
* GIVEN the block copied into a Jira description WHEN a reader looks at the spec folder line THEN it uses that same shape
* GIVEN `docs/specs/README.md` WHEN a reader compares it with the standard THEN it states the same shape
* GIVEN a topic-first example WHEN a reader checks the standard THEN that shape is not the one shown
* GIVEN a folder named `ac-2-context-management` and no folder named `ac-2` WHEN Implement starts for AC-2 THEN that topic folder is used and `docs/specs/ac-2/` is not created
* GIVEN two folders whose names start with the same key WHEN Implement starts for that key THEN the session asks which folder, instead of picking one in silence or creating a third
* GIVEN the research template WHEN a new research file is created THEN the first heading includes a topic
* GIVEN an existing research file whose heading is only the key WHEN this convention is adopted THEN that file is left unchanged

### Completeness

| Task | Required fields | Notes |
|---|---|---|
| Sub-task 1 | Summary, description, acceptance criteria, priority, parent | Parent AC-2. Issue type Sub-task because AC-2 is a Task. |
