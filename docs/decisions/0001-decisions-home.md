# 0001-decisions-home

| Field | Value |
| ----- | ----- |
| id | 0001-decisions-home |
| title | Architecture decisions live under docs/decisions/, read via INDEX.md then at most 1–2 files. |
| date | 2026-09-22 |
| who | Piotr Niemirski |
| source | docs/specs/ac-2/ac-2.research.md Question 16 |

## context

Delivery work produces architecture choices that must survive beyond a single research or plan write-up. Domain knowledge already has a home under `docs/context/`; decisions need a separate, durable catalog that a later Implement run can open without reading every historical task folder. Consumer product decision logs must not be copied into this framework repository.

## decision

The home for architecture decisions is `docs/decisions/`. A later Implement run reads `docs/decisions/INDEX.md` (always safe, one line per decision), then loads at most 1–2 full decision files. That read sits beside the existing `docs/context/` domain-knowledge router; `docs/context/<project>/INDEX.md` remains the only router for reference knowledge. When a human asks during delivery (research, plan, or Implement) to record a decision, the file is written in the working tree under `docs/decisions/` (skill `eversis-record-decision`). Earth Online As-Is Pack decision-log rows stay out of this framework repo — they belong in the consumer repo.
