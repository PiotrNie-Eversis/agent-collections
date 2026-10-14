# reports

Agent-generated reports that are **not** Delivery Standard research/plan artifacts.

## Agent Collections policy

Use this folder for outputs from standalone analysis prompts (for example `/eversis-review-codebase`). Prefer a **fixed filename** that each run overwrites, so the latest report is easy to find.

| Artifact | Canonical path |
|----------|----------------|
| Code quality report | [`code-quality-report.md`](./code-quality-report.md) |

Do **not** put these under `docs/specs/` — specs hold SDD research and implementation plans only.

## Framework repository

In **this** monorepo, `docs/reports/` is trackable (not gitignored), unlike `docs/specs/*/`. Keep this README committed so the path stays discoverable next to `docs/context/`, `docs/plans/`, `docs/specs/`, and `docs/decisions/`.

**Consumer projects** may adopt the same path when they run `eversis-review-codebase`.
