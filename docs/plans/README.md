# plans

Optional location for **flat implementation plans** as `*.md` files (scope, rationale, steps, risks).

## Agent Collections policy

Prefer the Implement workflow under **`docs/specs/<key>-<topic>/<key>-<topic>.plan.md`** (with `<key>-<topic>.research.md` / `<key>-<topic>.plan-review.md`) — see [`docs/specs/README.md`](../specs/README.md).

Use `docs/plans/` only for legacy or ad-hoc flat plans when the team chooses not to use a specs folder.

## Framework repository

In **this** monorepo, all story work under `docs/specs/*/` is **local-only** (gitignored), regardless of ticket prefix. Keep this README committed so the **docs triad** (`docs/context/`, `docs/plans/`, `docs/specs/`) matches cursor-collections scaffolding expectations.

**Consumer projects** may add and commit their own `docs/plans/` layout as needed.
