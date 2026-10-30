# Spec folder naming — Intent Brief

## Workshop Summary

| Field | Value |
|---|---|
| Workshop Date | 2026-09-24 |
| Participants | Piotr Niemirski |
| Source Materials | Written recommendation on spec folder names; Delivery Standard in `.ai/rules/orchestration/spec-driven-development.md` (`docs/specs/<issue-kebab>/`, example `task-522`); research template heading `# <TASK_NAME> - Analysis Result`; task baseline `docs/context/agent-collections/task-baseline.md` (refreshed 2026-09-24). |
| Prepared By | Business analyst (eversis-analyze-materials) |

## Goal

An agent that only has a ticket key can still open the right spec folder, and an agent that only has a topic word can see that folder in a name search. The key stays first. The topic is a short suffix. The first heading of the research file states the topic, not only the key.

## Recommended approach

New spec folders and their research and plan files use one kebab: ticket key, then a short topic.

| Piece | Shape |
|---|---|
| Folder | `docs/specs/ac-2-context-management/` |
| Research | `ac-2-context-management.research.md` |
| Plan | `ac-2-context-management.plan.md` |
| First heading | Names the topic. `# AC-2 - Analysis Result` alone does not. |

`context-ac-2-management` stays out. Implement looks up `docs/specs/<issue-kebab>/` from the key. The rule and that lookup have to agree: given AC-2, the agent resolves a folder whose name starts with `ac-2` and does not create a second `docs/specs/ac-2/` beside `docs/specs/ac-2-context-management/`.

The naming rule in `spec-driven-development.md` is in scope. The source text calls that edit a separate decision from renaming folders that already exist. This brief treats the rule edit as the work, and the rename of old folders as out of scope.

An `INDEX.md` row is unchanged. A folder name labels one ticket. Promotion into the index still happens only when a fact should outlive that ticket.

## In Scope

- The naming rule for new spec folders and for the research and plan files inside them: key first, short topic after.
- The first heading of a new research file states the topic.
- Implement, given only a ticket key, opens the one matching folder and does not create a key-only duplicate.
- The same shape in the Delivery Standard text that stories copy into Jira.

## Out of Scope

- Renaming existing `docs/specs/` folders, including `ac-2`, `ac-31`, and `blog`.
- A row in `INDEX.md` for every ticket, or any change to when promotion runs.
- Topic-first names.
- Rewriting the bodies of old research files so their headings gain a topic.

## Key Stakeholders / Actors

- Person who starts Implement with a ticket key — the existing folder must still be found.
- Agent searching specs by a topic word — the folder name should match.
- Maintainer of the Delivery Standard — the written rule and the lookup stay the same shape.
- Piotr Niemirski — approves this scope before any Jira ticket.

## Candidate Epics

- Spec names carry a topic after the ticket key — rule, file names, and the Implement lookup. Rationale: a key-only folder cannot be judged in a name search, and a topic-first folder breaks the key lookup.
- Research titles state the topic — the first heading is part of the same convention. Rationale: the source says the heading is what grep actually uses.

These can be one task in project AC if that board shape is chosen again. Extraction waits for Gate 0.

## Baseline Overlap / Existing Backlog Notes

- No naming-convention item in `docs/context/agent-collections/task-baseline.md`.
- AC-31 is the docs-site blog. It does not cover spec folder names. Its own folder remains as it is.

## Open Questions

- None that block the recommendation above. Confirm Gate 0 includes the rule edit and the Implement lookup, and excludes renaming old folders.

## Assumptions

- The topic suffix is at most three kebab words, chosen when the folder is created. A sentence belongs in the first heading, not in the path.
- One ticket has one spec folder. A second folder for the same key is a mistake.
- Workshop folders that are not a ticket (this brief's own `spec-folder-naming`) may stay topic-only. The key-first rule applies when a Jira key exists.

## Gate 0 Approval

| Decision | Notes |
|---|---|
| Approved | 2026-09-24. Piotr Niemirski confirmed the spec-driven-development change (convention text only: key, then a short topic) and the rest of this brief with "Ok". |
