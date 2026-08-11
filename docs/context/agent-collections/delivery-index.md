# DHI-515 — Delivery index (traceability)

Maps epic **DHI-515** Jira keys to implementation waves, primary deliverables on `main`, and spec folders where they exist.

**SDD note (CQ2):** Wave-level research/plans (`dhi-515.wave-c.*`, `dhi-515.wave-d.*`) plus this index **replace** mandatory retroactive per-story folders for DHI-530 and DHI-532–540. Story-specific specs exist where noted below.

**Last updated:** 2026-08-11 (epic close-out implement)

## Waves

| Wave | Theme | Jira keys |
|------|-------|-----------|
| A | Core extraction | DHI-516–522 |
| B | Adapters + isolation contract | DHI-523–529, DHI-531 |
| C | Self-contained distribution | DHI-533–538, DHI-530, DHI-532, DHI-521, DHI-537 |
| D | Docs + validation | DHI-539–542, DHI-541, DHI-540 |
| Follow-on | Cursor slash emit | DHI-598 |
| Close-out | Q6 + governance | DHI-515 (`dhi-515.close-out.plan.md`) |

## Story → deliverable map

| Jira | Title (short) | Wave | Primary paths on `main` | Spec folder |
|------|---------------|------|-------------------------|-------------|
| DHI-516 | Inventory legacy assets | A | `docs/specs/cursor-collection-migration/` | `cursor-collection-migration/` |
| DHI-517 | Core directory structure | A | `.ai/README.md`, `.ai/rules/` | `dhi-517/` |
| DHI-518 | Orchestration rules → core | A | `.ai/rules/orchestration/` | `dhi-518/` |
| DHI-519 | Domain rules → core | A | `.ai/rules/{frontend,backend,...}/` | `dhi-519/` |
| DHI-520 | Skills/prompts → core | A | `.ai/skills/`, `.ai/prompts/` | `dhi-520/` |
| DHI-521 | Versioning contract | A/C | `README.md`, `CHANGELOG.md` | `dhi-521/` |
| DHI-522 | SDD mandatory | A | `.ai/rules/orchestration/spec-driven-development.md` | `dhi-522/` |
| DHI-523 | Adapter mapping spec | B | `docs/architecture/adapter-mapping.md` | `dhi-523/` |
| DHI-524 | Cursor adapter | B | `adapters/cursor/`, `.cursor/rules/` | `dhi-524/` |
| DHI-525 | OpenCode placeholder | B | `adapters/opencode/`, `opencode.jsonc` | `dhi-525/` |
| DHI-526 | Claude adapter | B | `adapters/claude/`, `CLAUDE.md` | `dhi-526/` (PL plan) |
| DHI-527 | Adapter sync tooling | B | `adapters/sync.mjs` | `dhi-527/` (PL plan) |
| DHI-528 | Isolation strategy | B | `docs/architecture/isolation-strategy.md` | `dhi-528/` |
| DHI-529 | Ignore triad | B | `.cursorignore`, `.claudeignore`, `.opencodeignore` | `dhi-529/` |
| DHI-530 | Monorepo glob scoping | C | `adapters/profiles/area-*.yaml`, installer area apply | Wave C plan (waiver) |
| DHI-531 | AGENTS.md template | B | `templates/AGENTS.template.md`, `docs/architecture/agents-md-standard.md` | `dhi-531/` |
| DHI-532 | Reference AGENTS.md | C | `AGENTS.md` | Wave C plan (waiver) |
| DHI-533 | Self-contained bootstrap | C | No CC symlinks; full `.ai/` on disk | Wave C plan (waiver) |
| DHI-534 | Multi-tool installer | C | `scripts/setup-agent-collections.sh` | Wave C plan (waiver) |
| DHI-535 | Port MCP | C | `mcp/eversis-collections-mcp/` | Wave C plan (waiver) |
| DHI-536 | Modular profiles | C | `adapters/profiles/{frontend,backend,fullstack}.yaml` | Wave C plan (waiver) |
| DHI-537 | Upgrade path docs | C | README upgrade contract, `install-selection.md` | Wave C plan (waiver) |
| DHI-538 | Install wizard | C | `agents-prompt.mjs`, `mcp-prompt.*`, selection JSON | Wave C plan (waiver) |
| DHI-539 | Migration guide | D | `website/docs/getting-started/migration-from-cursor-collections.md` | Wave D plan (waiver) |
| DHI-540 | Docusaurus migrate | D | `website/` | Wave D plan (waiver) |
| DHI-541 | README / getting started | D | `README.md`, `website/docs/getting-started/` | `dhi-541/` |
| DHI-542 | EOG pilot | D | `docs/context/eog/` | `dhi-542/` |
| DHI-598 | Cursor slash commands | Follow-on | `adapters/cursor/generate.mjs`, `.cursor/commands/` | `dhi-598/` |
| DHI-515 | Epic close-out | Close-out | Q6 `.ai/` links, delivery-index, deselect prune | `dhi-515/` |

## Residual (not blocking close-out code)

| Item | Owner | Notes |
|------|-------|-------|
| Q5 dual-agent sessions | Human (DHI-542 Phase C) | `docs/context/eog/pilot-evidence.md` checklist |
| SemVer tag `v0.1.0` | Human (O1 OK) | After review PASS — git tag on repo |
| Jira status sync | Human (CQ5) | Align DHI-516–542 with delivered state |
| Public docs hosting | Deferred | Wave D Q3 |

## Related

- Epic research: [`docs/specs/dhi-515/dhi-515.research.md`](../../specs/dhi-515/dhi-515.research.md)
- Close-out plan: [`docs/specs/dhi-515/dhi-515.close-out.plan.md`](../../specs/dhi-515/dhi-515.close-out.plan.md)
- Task baseline: [`task-baseline.md`](./task-baseline.md)
