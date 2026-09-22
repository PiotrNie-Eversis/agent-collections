---
name: eversis-record-decision
description: "Human asks during research, plan, or Implement to record an architecture decision; writes a local file under docs/decisions/ and one INDEX row. Not a Fine draft. Not a GitLab write."
user-invocable: true
---

# Recording an Architecture Decision

Creates a durable decision file under `docs/decisions/` when a human asks during research, plan, or Implement. Opposite of `eversis-promote-domain-knowledge` (Fine-time, GitLab API, domain facts): this skill writes a local working-tree file only, and only on explicit human request.

<principles>
<human-asked-only>
Run only when a human asks to record an architecture decision during research, plan, or Implement. If they did not ask, write nothing. Most tasks produce no decision file — that is normal.
</human-asked-only>
<local-working-tree-only>
Write only under `docs/decisions/` in the current repo working tree. Do not call the GitLab API, do not use `GITLAB_TOKEN`, do not open a merge request, and do not wait for Fine.
</local-working-tree-only>
</principles>

## Required fields

Every decision file must include all seven fields. If any is missing, ask the human. Do not invent `who`.

| Field | Rule |
| ----- | ---- |
| `id` | Lowercase kebab-case, unique in `docs/decisions/`, stable once written |
| `title` | One sentence; this is the index row text |
| `date` | ISO date (YYYY-MM-DD) |
| `context` | Why a choice was needed |
| `decision` | What was chosen |
| `who` | Person who made or confirmed the decision — ask if unknown |
| `source` | Spec path, ticket, or conversation that closed the choice |

There is **no** `status` field. Do not add one.

## Process

1. Confirm the human asked to record a decision during research, plan, or Implement. If not, stop.
2. Collect all seven required fields. Ask for any that are missing. Do not invent `who`.
3. Verify `id` is lowercase kebab-case and that `docs/decisions/<id>.md` does not already exist.
4. Write `docs/decisions/<id>.md` with the seven fields (and short prose under `context` / `decision` as needed).
5. Add exactly one row to `docs/decisions/INDEX.md` — columns `id` and `title` only.

## Forbidden

- Writing when the human did not ask
- Writing outside `docs/decisions/`
- GitLab API / `GITLAB_TOKEN` / merge-request writes
- Producing a Fine draft or waiting for Fine
- Adding a `status` field
- Writing under `docs/context/`
- Filing the decision via `eversis-promote-domain-knowledge`
- Copying Earth Online As-Is Pack decision-log rows into the framework repo

## What this skill does NOT do

- Does not add a prompt under `.ai/prompts/`
- Does not edit the MCP server (skill folders are discovered automatically)
- Does not run at Fine and does not replace the QA comment draft
