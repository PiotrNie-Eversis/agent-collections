---
sidebar_position: 4
title: Domain Context (SSOT)
slug: /domain-context
---

# Domain Context (SSOT)

Generic AI tools don't know your team's business rules or codebase conventions — they either re-explain the same thing every session, or someone writes it into a custom skill or prompt (see [Extending the framework](./use-cases#extending-the-framework)). **Domain context** is a cheaper alternative for the common case: durable facts (a confirmed business rule, a reusable integration pattern) that an agent discovers while working get written into a plain-Markdown store, `docs/context/`, so the next session — in this project or another one — reads them instead of rediscovering them.

**SSOT** (single source of truth) here means one durable fact lives in exactly one file, not copy-pasted across tasks or repos.

## Two layers

`docs/context/` has two layers, both plain Markdown, both readable with normal file tools — no special search tool required.

| Layer | Path | Owned by | How it gets there |
|-------|------|----------|--------------------|
| Project | `docs/context/<project>/` | This repository | `INDEX.md` is scaffolded by the installer on every install; component files are written by agents during Fine (see [Workflow Overview](./workflow/overview#status-fine--handoff)) |
| Global | `docs/context/global/` | A dedicated `domain-context` GitLab project, shared across repos in the same group | Seeded best-effort at install time, refreshed later via `eversis_context_sync` — a **subtree** (a Git mechanism that copies another repository's history into a subfolder of this one) pull, not a live link |

**Project wins on conflict.** When a component exists in both layers, reading it (`eversis_context_get`) returns the project version — the global layer is a shared default, not an override.

## How it's distributed

<figure>
  <img src="/img/domain-context-knowledge-propagation.svg" alt="Knowledge propagation: a GitLab group containing the domain-context repo and consumer projects, each with a project-owned docs/context layer and a subtree-synced global layer" />
  <figcaption><em>One <code>domain-context</code> repo per GitLab group fans out into every consumer project's <code>docs/context/global/</code> via <code>subtree pull --squash</code> — one-way, on request, never automatic. Each consumer keeps its own <code>docs/context/&lt;project&gt;/</code> layer natively, untouched by the sync.</em></figcaption>
</figure>

**Legend:** blue = the SSOT source repository; green = content delivered into a consumer repo via `subtree`; yellow = content native to that consumer repo. Sync is **manual and one-way** — running `eversis_context_sync` in one consumer repo does not affect any other; there is no automatic fan-out or push-back from a consumer into `domain-context`.

## Reading it — budget-aware, not a full-directory scan

An agent doing Research reads `docs/context/<project>/INDEX.md` first, matches the task's topic to **one** listed component, and reads only that component's file — never the whole `docs/context/` tree by default. Full procedure: [Orchestrating Implementation](./skills/orchestrating-implementation).

## Tools and skills

Three MCP tools (part of the `eversis-collections` server — see [full inventory](./integrations/eversis-collections#domain-context)):

- **`eversis_context_list`** — list known components across both layers.
- **`eversis_context_get`** — read one named component (project first, then global); marks the file's `last_consulted` field.
- **`eversis_context_sync`** — pull the latest `domain-context` content into `docs/context/global/`.

Three skills write and maintain this content: `eversis-promote-domain-knowledge` (the Fine second draft), `eversis-import-confluence-knowledge` (seed from an existing Confluence page, on request), and `eversis-audit-domain-knowledge` (periodic review — keep, update, consolidate, replace, or delete each entry).

## Publishing to the global layer

Writing to `domain-context` happens through the GitLab REST API (branch + commit + merge request), never a local checkout, and always behind the same two-phase human gate as the QA comment draft: a labeled draft first, publication only after explicit approval. It requires a `GITLAB_TOKEN` with write access, provided by the agent's runtime environment — the installer never generates, stores, or requests this token (see [Install Selection Schema](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/docs/architecture/install-selection.md)).

Canonical detail: [`docs/architecture/agents-md-standard.md`](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/docs/architecture/agents-md-standard.md) (the `docs/context`/`docs/plans`/`docs/specs` triad) and [`docs/architecture/install-selection.md`](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/docs/architecture/install-selection.md) (the `ssot.*` install schema) in the repository.
