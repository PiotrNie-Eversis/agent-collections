# decisions

Catalog of architecture decisions for this repository. One markdown file per decision; the index lists them in two columns (`id`, `title`).

## Record fields

Each decision file uses these fields (no `status` field):

| Field | Meaning |
| ----- | ------- |
| `id` | Stable lowercase kebab-case identifier (also the filename stem) |
| `title` | One-sentence summary shown in the index |
| `date` | When the decision was recorded (ISO date) |
| `context` | Why a choice was needed |
| `decision` | What was chosen |
| `who` | Who made or confirmed the decision |
| `source` | Where the decision was agreed (spec, ticket, conversation) |

## Index

[`INDEX.md`](./INDEX.md) is the bounded entry point: two columns only (`id`, `title`). A later Implement run reads the index, then at most 1–2 full decision files.

## Consumer content stays out of this repo

Earth Online As-Is Pack decision-log rows are **not** stored in this framework repository. They belong in the consumer repo that owns that product.
