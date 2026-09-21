# context

Internal knowledge for this project: architecture notes, ADRs, wiki sync exports, onboarding. Use clear filenames under `docs/context/<project>/`.

**`docs/context/<project>/INDEX.md` is the one mandatory router** an agent reads first, before any component file — one line per component, exactly two columns (`| component | one-line summary |`; a third column is silently dropped by the tooling that reads it, so per-component metadata belongs in that component's own file, not a new column). Each row's component name links to its own `docs/context/<project>/<component>/index.md`. Create `INDEX.md` when scaffolding this directory, even before any component exists.

**Task baseline (workshop continuity):** `docs/context/<project>/task-baseline.md` — optional epic/story index refreshed after a successful Jira push from prompt `eversis-analyze-materials`.

Referenced by research/plan steps. Attach it by path in your tool (e.g. Cursor `@docs/context/<project>/`).

Part of the project deliverables triad with [`docs/plans/`](../plans/) and [`docs/specs/`](../specs/).

By default this folder is committed like any other project doc. Projects installed with `--gitignore-agent-artifacts` gitignore `docs/context/*/` subfolders instead (local baselines/exports stay off git); only this `README.md` stays tracked in that mode.

## Framework repository (`agent-collections`)

This repo applies the same local-only pattern to itself that `--gitignore-agent-artifacts` gives consumer projects — `docs/context/*/` subfolders here (e.g. `agent-collections/`) are gitignored; only this `README.md` stays tracked. Same treatment already applied to `docs/specs/*/` (see `CHANGELOG.md`).

**Consumer projects** may commit `docs/context/` by default, or opt in to gitignoring `docs/context/*/` subfolders with `--gitignore-agent-artifacts`.
