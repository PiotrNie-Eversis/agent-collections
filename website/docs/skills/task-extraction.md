---
sidebar_position: 13
title: Task Extraction
---

# Task Extraction

**Folder:** `.cursor/skills/eversis-task-extracting/`  
**Used by:** Business Analyst via [`eversis-analyze-materials`](../prompts/public/analyze-materials)

Identifies and structures epics and user stories from workshop materials. Produces an **intent brief** (Gate 0), then a business-oriented backlog with **source traceability** and scenario-based acceptance criteria.

## What It Produces

- **`intent-brief.md`** — Scope brief approved or skipped at Gate 0 (see `intent-brief.example.md`)
- **Epics** — Work streams with business descriptions and success criteria
- **User stories** — `As a… I want… So that…` with **Source** field and `GIVEN / WHEN / THEN` criteria
- **Dependencies**, **assumptions**, **open questions**

## Gate 0 (intent brief)

| Situation | Gate 0 behavior |
| --- | --- |
| Ambiguous or conflicting materials | Present `intent-brief.md`; iterate until **Approved** |
| Clear, aligned structured requirements | **Skip** — record `Skipped — materials unambiguous` in brief; confirm in chat |

Artifact path: `docs/specs/<workshop-name>/intent-brief.md` (or `specifications/<workshop-name>/`).

## Process (summary)

1. Gather materials (transcript, Figma, codebase, baseline if present).
2. Draft `intent-brief.md`.
3. Gate 0 — approve or skip.
4. Identify epics and break into stories with source traceability.
5. Map dependencies; document assumptions and out-of-scope items.
6. Clarify ambiguities (one question per chat turn).
7. Gate 1 — present each story for validation.
8. Save `intent-brief.md` and `extracted-tasks.md`.

## Templates

- `intent-brief.example.md` — Gate 0 scope brief
- `extracted-tasks.example.md` — Epics, stories, Source, scenario AC

## Connected Skills

- `eversis-transcript-processing` — cleaned transcript input
- `eversis-codebase-analysing` — existing system context
- `eversis-task-analysing` — business-context exploration before extraction
