# Spec-driven development (Delivery Standard)

Mandatory delivery contract for Agent Collections (and consumer projects that adopt this framework). Vendor-neutral: use **stable prompt ids** and file paths under `.ai/` / `docs/specs/` — do not require a specific IDE attach syntax.

## Lifecycle

```text
Ideate
  → Research   → human gate (approve research before plan)
  → Plan       → human gate (approve plan before broad code)
Implement      → focused changes + quality commands
Review         → independent check (PASS / BLOCKER / SUGGESTION)
Fine           → QA comment draft same turn; publish only with explicit human OK
```

Plain-language stages map to Ideate (clarify + Research + Plan), Implement (code), and Review (quality). **Research** and **Plan** are first-class gates, not optional chat notes.

Quick Flow may SKIP new research/plan **only** after the **adequacy checklist** in skill `eversis-orchestrating-implementation` passes. File existence alone is never enough to SKIP.

## Human gates

- Required **research** (`*.research.md`) must be human-approved before planning starts.
- Required **plan** (`*.plan.md`) must be human-approved before broad implementation.
- Agent outputs are **drafts** until the relevant gate is confirmed.
- **Fine** produces a QA comment **draft** in the same turn (`fine-handoff.md` / skill `eversis-fine-handoff`). Posting to a ticket tracker needs **explicit** human approval — never automatic.

## Spec folder and artifacts

| Item | Convention |
|------|------------|
| Folder | `docs/specs/<issue-kebab>/` (e.g. `docs/specs/dhi-522/`) |
| Research | `<issue-kebab>.research.md` — before plan when Full / SDD applies |
| Plan | `<issue-kebab>.plan.md` — before implementation when Full / SDD applies |
| Optional | `*.plan-review.md`, manifests, inventory notes as the story requires |

Do **not** start implementation without approved research and plan artifacts when this Delivery Standard applies.

### This framework repository vs consumers

- In **`agent-collections`**, story folders matching `docs/specs/dhi-*/` are **gitignored** (local agent artifacts; MVP committed docs are README / CHANGELOG / `.ai/`).
- **Consumer projects** choose whether to commit or ignore their own `docs/specs/` — the folder convention stays the same either way.

## Delivery Standard (copy into Jira / story descriptions)

```text
## Delivery Standard

This story follows full spec-driven development (mandatory under Agent Collections / epic DHI-515 when applicable).

* Spec folder: docs/specs/<issue-kebab>/
* Research: <issue-kebab>.research.md — required before plan
* Plan: <issue-kebab>.plan.md — required before implementation
* Implement: load eversis-implement (approved plan attached)
* Review: load eversis-review before Done
* Fine: QA comment draft per eversis-fine-handoff

Do not start implementation without approved research and plan artifacts.

Optional (Cursor): you may also attach the same prompts with @eversis-implement / @eversis-review if your project surfaces those files in Cursor.
```

Primary entry = stable prompt id / file under `.ai/prompts/`. The Cursor `@` line is optional UX only.

## Implement readiness and adequacy

When running **Implement** (`eversis-implement`):

1. Output the **Implement readiness** four-line block first (see `engineering-manager.md`).
2. Run the **adequacy checklist** before any `Research: SKIP` or `Plan: SKIP` when artifacts already exist — owned by skill `eversis-orchestrating-implementation` (do not duplicate the full checklist here).

## Related

- [`agent-core.md`](./agent-core.md) — always-on lifecycle, hard limits, skills discovery
- [`engineering-manager.md`](./engineering-manager.md) — readiness block and gates
- [`fine-handoff.md`](./fine-handoff.md) — Fine → QA draft contract
- Skill: `eversis-orchestrating-implementation`
- Prompts: `eversis-implement`, `eversis-review`
