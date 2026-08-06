---
sidebar_position: 14
title: Task Quality Review
---

# Task Quality Review

**Folder:** `.cursor/skills/eversis-task-quality-reviewing/`  
**Used by:** Business Analyst via [`eversis-analyze-materials`](../prompts/public/analyze-materials) (Gate 1.5)

Systematic quality analysis on a Gate 1-approved task list (`extracted-tasks.md`) to identify gaps, missing edge cases, and improvement opportunities. Produces structured suggestions the user accepts or rejects individually.

## Review modes

| Mode | Use when | Active passes |
| --- | --- | --- |
| **Lite** | Default for small workshops (~≤3 epics, ~≤12 stories) unless user requests Full | A, B, E, H, I |
| **Full** | Larger workshops, regulated domains, high-risk scope, or user requests deeper review | A–J |

Tasks with status **Done**, **Cancelled**, or **PO APPROVE** are excluded from analysis (protected status filter).

## What it produces

- **Suggestions** — Improvement proposals with confidence (High / Medium / Low) and action type
- **Domain model** — Actors, entities (lifecycle map), relationships
- **`quality-review.md`** — Audit trail per `quality-review.example.md`
- **Updated `extracted-tasks.md`** — In-place updates for accepted suggestions only

## Analysis passes

| Pass | Category | Confidence default |
| --- | --- | --- |
| A | Entity Lifecycle Completeness | High |
| B | Cross-Feature State Validation | High |
| C | Bulk Operation Idempotency | High |
| D | Actor Dashboard Completeness | Medium |
| E | Precondition Guards | High |
| F | Third-Party Boundary Clarity | Medium |
| G | Platform Operations Perspective | Medium |
| H | Error State & Edge Case Coverage | High |
| I | Notification & Communication Gaps | High |
| J | Domain-Specific Research | Low–Medium |

## Suggestion action types

| Action | Meaning |
| --- | --- |
| `ADD_ACCEPTANCE_CRITERION` | Add a verifiable condition to an existing story |
| `MODIFY_STORY` | Expand an existing story's scope |
| `ADD_TECHNICAL_NOTE` | Clarify without changing functional scope |
| `NEW_STORY` | Add uncovered functionality under an epic |
| `NEW_EPIC` | Add a major capability area (rare) |

## Process (summary)

1. Load `extracted-tasks.md` and source materials; select Lite or Full mode.
2. Optionally enrich from Jira board (read-only).
3. Build domain model (actors, entities, relationships).
4. Run active analysis passes; respect protected status filter.
5. Classify findings into structured suggestions.
6. **Gate 1.5** — Present **one suggestion per chat turn** for accept/reject.
7. Apply accepted changes to `extracted-tasks.md`.
8. Save `quality-review.md` under `docs/specs/<workshop-name>/` (or `specifications/<workshop-name>/`).

## Templates

- `quality-review.example.md` in the skill folder — canonical report structure

## Connected skills

- `eversis-task-extracting` — upstream extracted tasks
- `eversis-jira-task-formatting` — downstream Jira formatting after Gate 1.5
