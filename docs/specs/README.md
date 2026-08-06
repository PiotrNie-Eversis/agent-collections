# specs

Feature **research** and **implementation plan** artifacts for Agent Collections delivery (mandatory Delivery Standard).

Part of the project deliverables triad with [`docs/context/`](../context/) and [`docs/plans/`](../plans/) — see [`docs/architecture/agents-md-standard.md`](../architecture/agents-md-standard.md).

Canonical rule: [`.ai/rules/orchestration/spec-driven-development.md`](../../.ai/rules/orchestration/spec-driven-development.md).

## Naming convention

`docs/specs/<issue-kebab>/`

```text
docs/specs/my-feature/
  my-feature.research.md
  my-feature.plan.md
```

| Artifact | When |
|----------|------|
| `*.research.md` | Before plan (Full / SDD); human approve before planning |
| `*.plan.md` | Before implementation; human approve before broad code |
| `*.plan-review.md` | Optional plan validation |

Do **not** start implementation without approved research and plan when SDD applies.

**Implement** entry (`eversis-implement`) must run the **adequacy checklist** before Research/Plan SKIP — see skill `eversis-orchestrating-implementation`.

## This repository (`agent-collections`)

Folders matching `docs/specs/dhi-*/` are **gitignored** (local-only MVP). Keep working copies on disk for active stories; they are not published with the framework tree.

## Consumer projects

Use the same `docs/specs/<issue-kebab>/` convention. Whether those folders are committed or gitignored is a **project choice** — document it in your stack / AGENTS if needed.
