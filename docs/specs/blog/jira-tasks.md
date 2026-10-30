# Blog — Jira Tasks

Board convention for project AC: one Task for the whole workshop (same as AC-14 and AC-15). Local epics and stories stay in `extracted-tasks.md` as the breakdown. They are not separate Jira issues.

## Task 1: Publish a technical blog for framework change write-ups

| Field | Value |
|---|---|
| Summary | Publish a technical blog for framework change write-ups |
| Issue Type | Task |
| Parent | — |
| Priority | High |
| Labels | website, docs, blog, workshop-2026-09-24 |
| Sizing guidance | Medium (team estimates during refinement) |
| Jira Key | [AC-31](https://eversis.atlassian.net/browse/AC-31) |
| Status | Backlog |

### Description

## Overview

The docs site gains a blog for technical write-ups of framework changes. A post explains how a change behaves and where it stops. It does not reprint the team notice, and it does not replace the changelog.

## Business Value

The team notice is short on purpose: roles, what to type, upgrade commands. Readers who need the mechanism have nowhere to go except that notice or the version ledger. This task gives them a technical account, starting with the AC-2 update.

## User Story

As a reader of the docs site, I want a technical write-up of a framework change so that I understand how it behaves without reading the team notice again.

## Requirements

1. The docs site header offers a Blog entry beside Changelog. Docs, Get started, The Main Flow, Reference, and Advanced / CTO stay where they are.
2. The blog lists posts by title and date, newest first. A post shows its title, date, author, and body.
3. Site search returns a published post and still returns docs.
4. A maintainer has a publishing rule: a post is for a mechanism worth explaining; a one-line fix stays in the changelog only. The draft covers what changed, why the previous behavior was a problem, how it behaves now (including limits), what did not change, and a link to the changelog. Copying the team message (role blocks, chat how-to lines, upgrade scripts) into the post is not acceptable. A human approves the draft before it goes live.
5. The first post is a technical account of the AC-2 update, in English, and it stands alone for someone who never received the team message.

## Source Context

Gate 0 approved 2026-09-24: team message = notice, changelog = ledger, blog = technical discussion that deepens the notice. Story 1.1 approved the same day. The user then asked for the whole breakdown as one Task in project AC. Intent brief and stories: `docs/specs/blog/`.

## Out of Scope

* Republishing the AC-2 team message
* Replacing or hand-editing the generated changelog
* A post for every changelog bullet
* Generating posts from agent transcripts
* Comments, newsletter, or a separate content system
* Translating the whole docs site
* Redesigning the docs information architecture (DHI-641), beyond the Blog entry beside Changelog
* A post about AC-29

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

The docs site already has a generated Changelog page. The blog capability on that site is currently off, and site search does not index a blog. The Blog link should sit with Changelog, not inside the four docs clusters (DHI-653). The first post states the upgrade contract. It does not paste the two command blocks from the team message.

## Acceptance Criteria

* GIVEN the docs site header WHEN a reader looks for a technical write-up THEN a Blog entry is available beside Changelog, and the existing docs entries stay in place
* GIVEN the Blog entry WHEN the reader opens it THEN they see a list of posts with title and date, newest first
* GIVEN a post in that list WHEN the reader opens it THEN they see the title, the date, the author, and the body
* GIVEN a published post WHEN a reader searches for a distinctive phrase from that post THEN the post appears in site search, and a docs phrase still returns docs
* GIVEN a framework change WHEN a maintainer decides whether to write a post THEN a one-line fix stays in the changelog only, and a mechanism worth explaining can get a post
* GIVEN a post draft WHEN the maintainer checks it THEN it covers what changed, why the previous behavior was a problem, how it behaves now including limits, what did not change, and a link to the changelog entry
* GIVEN the AC-2 team message WHEN a reader compares it with the first post THEN the post does not repeat the role sections, the chat how-to lines, or the two upgrade command blocks
* GIVEN the first post WHEN a reader looks for context behavior THEN it explains one matching topic from project knowledge, name-only search of old specs, and full text of at most one or two spec files
* GIVEN the first post WHEN a reader looks for session behavior THEN it explains that a finished plan task records a checkpoint and the same session continues through the remaining tasks, review, and the QA draft, and that a new chat is for a session that actually stopped
* GIVEN the first post WHEN a reader looks for where knowledge is stored THEN it explains that business rules and architecture decisions are written in different places, on different requests, and that nothing is published to Confluence without an explicit human approval
* GIVEN the first post WHEN a reader looks for the upgrade contract THEN it states which project-owned paths stay untouched, that a missing decisions folder is added, and that a submodule layout and a plain file copy are different update paths
* GIVEN the first post WHEN it goes live THEN a human has approved the text, the wording matches the behavior that shipped, the post is in English, and it stands alone without the team message

### Completeness

| Task | Required fields | Notes |
|---|---|---|
| Task 1 | Summary, description, acceptance criteria, priority, labels | Single Task by user request. No parent epic. |
