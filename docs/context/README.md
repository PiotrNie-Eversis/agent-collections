# context

Internal knowledge for this project: architecture notes, ADRs, wiki sync exports, onboarding. Use clear filenames under `docs/context/<project>/`.

**Task baseline (workshop continuity):** `docs/context/<project>/task-baseline.md` — optional epic/story index refreshed after a successful Jira push from prompt `eversis-analyze-materials`.

Referenced by research/plan steps. Attach it by path in your tool (e.g. Cursor `@docs/context/<project>/`).

Part of the project deliverables triad with [`docs/plans/`](../plans/) and [`docs/specs/`](../specs/).

By default this folder is committed like any other project doc. Projects installed with `--gitignore-agent-artifacts` gitignore `docs/context/*/` subfolders instead (local baselines/exports stay off git); only this `README.md` stays tracked in that mode.

## Framework repository (`agent-collections`)

This repo does not apply `--gitignore-agent-artifacts` to itself — `docs/context/*/` subfolders here (e.g. `agent-collections/`) are committed as reference material, unlike a consumer project that opts into the local-only pattern.

**Consumer projects** may commit `docs/context/` by default, or opt in to gitignoring `docs/context/*/` subfolders with `--gitignore-agent-artifacts`.
