# Sample: delivery lifecycle

> **Sample only (DHI-517).** This file demonstrates neutral Markdown rule format for `.ai/rules/`. It is **not** the production orchestration rule set. Full extraction and neutralization of legacy agent-core / Engineering Manager content is **DHI-518**.

## Lifecycle

Work follows three stages. Treat each major deliverable as a **draft** until a human approves.

1. **Ideate** — Clarify intent, extract tasks, and agree scope before large design or code changes.
2. **Implement** — Research context, plan the work, execute against the approved plan, then review.
3. **Review** — Independent quality check; resolve blockers before calling the work done.

## Human gates

- Approve **research** before planning when the story requires a research artifact.
- Approve the **implementation plan** before broad code or structural changes.
- Do not treat agent output as final without human confirmation of the relevant gate.

## Orchestration contracts (sketch)

- Prefer complete changes over placeholders.
- After substantive edits, run the project’s lint / typecheck / tests when they exist.
- When implementation is complete, produce a Fine handoff summary for QA (draft for human review before any ticket publication).

## Format notes

- Plain Markdown only — no IDE-specific front matter in core rule files.
- Tool packaging (Cursor rules, Claude project files, slash commands) belongs in **adapters**, not in this sample.
