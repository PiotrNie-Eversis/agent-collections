# TASK-515 — Delivery index (traceability)

Maps epic **TASK-515** Jira keys to implementation waves, primary deliverables on `main`, and spec folders where they exist.

**SDD note (CQ2):** Wave-level research/plans (`task-515.wave-c.*`, `task-515.wave-d.*`) plus this index **replace** mandatory retroactive per-story folders for TASK-530 and TASK-532–540. Story-specific specs exist where noted below.

**Last updated:** 2026-08-11 (epic close-out implement)

## Waves

| Wave | Theme | Jira keys |
|------|-------|-----------|
| A | Core extraction | TASK-516–522 |
| B | Adapters + isolation contract | TASK-523–529, TASK-531 |
| C | Self-contained distribution | TASK-533–538, TASK-530, TASK-532, TASK-521, TASK-537 |
| D | Docs + validation | TASK-539–542, TASK-541, TASK-540 |
| Follow-on | Cursor slash emit | TASK-598 |
| Close-out | Q6 + governance | TASK-515 (`task-515.close-out.plan.md`) |

## Story → deliverable map

| Jira | Title (short) | Wave | Primary paths on `main` | Spec folder |
|------|---------------|------|-------------------------|-------------|
| TASK-516 | Inventory legacy assets | A | `docs/specs/cursor-collection-migration/` | `cursor-collection-migration/` |
| TASK-517 | Core directory structure | A | `.ai/README.md`, `.ai/rules/` | `task-517/` |
| TASK-518 | Orchestration rules → core | A | `.ai/rules/orchestration/` | `task-518/` |
| TASK-519 | Domain rules → core | A | `.ai/rules/{frontend,backend,...}/` | `task-519/` |
| TASK-520 | Skills/prompts → core | A | `.ai/skills/`, `.ai/prompts/` | `task-520/` |
| TASK-521 | Versioning contract | A/C | `README.md`, `CHANGELOG.md` | `task-521/` |
| TASK-522 | SDD mandatory | A | `.ai/rules/orchestration/spec-driven-development.md` | `task-522/` |
| TASK-523 | Adapter mapping spec | B | `docs/architecture/adapter-mapping.md` | `task-523/` |
| TASK-524 | Cursor adapter | B | `adapters/cursor/`, `.cursor/rules/` | `task-524/` |
| TASK-525 | OpenCode placeholder | B | `adapters/opencode/`, `opencode.jsonc` | `task-525/` |
| TASK-526 | Claude adapter | B | `adapters/claude/`, `CLAUDE.md` | `task-526/` (PL plan) |
| TASK-527 | Adapter sync tooling | B | `adapters/sync.mjs` | `task-527/` (PL plan) |
| TASK-528 | Isolation strategy | B | `docs/architecture/isolation-strategy.md` | `task-528/` |
| TASK-529 | Ignore triad | B | `.cursorignore`, `.claudeignore`, `.opencodeignore` | `task-529/` |
| TASK-530 | Monorepo glob scoping | C | `adapters/profiles/area-*.yaml`, installer area apply | Wave C plan (waiver) |
| TASK-531 | AGENTS.md template | B | `templates/AGENTS.template.md`, `docs/architecture/agents-md-standard.md` | `task-531/` |
| TASK-532 | Reference AGENTS.md | C | `AGENTS.md` | Wave C plan (waiver) |
| TASK-533 | Self-contained bootstrap | C | No CC symlinks; full `.ai/` on disk | Wave C plan (waiver) |
| TASK-534 | Multi-tool installer | C | `scripts/setup-agent-collections.sh` | Wave C plan (waiver) |
| TASK-535 | Port MCP | C | `mcp/eversis-collections-mcp/` | Wave C plan (waiver) |
| TASK-536 | Modular profiles | C | `adapters/profiles/{frontend,backend,fullstack}.yaml` | Wave C plan (waiver) |
| TASK-537 | Upgrade path docs | C | README upgrade contract, `install-selection.md` | Wave C plan (waiver) |
| TASK-538 | Install wizard | C | `agents-prompt.mjs`, `mcp-prompt.*`, selection JSON | Wave C plan (waiver) |
| TASK-539 | Migration guide | D | `website/docs/getting-started/migration-from-cursor-collections.md` | Wave D plan (waiver) |
| TASK-540 | Docusaurus migrate | D | `website/` | Wave D plan (waiver) |
| TASK-541 | README / getting started | D | `README.md`, `website/docs/getting-started/` | `task-541/` |
| TASK-542 | EOG pilot | D | `docs/context/eog/` | `task-542/` |
| TASK-598 | Cursor slash commands | Follow-on | `adapters/cursor/generate.mjs`, `.cursor/commands/` | `task-598/` |
| TASK-515 | Epic close-out | Close-out | Q6 `.ai/` links, delivery-index, deselect prune | `task-515/` |

## Residual (not blocking close-out code)

| Item | Owner | Notes |
|------|-------|-------|
| Q5 dual-agent sessions | Human (TASK-542 Phase C) | `docs/context/eog/pilot-evidence.md` checklist |
| SemVer tag `v0.1.0` | Human (O1 OK) | After review PASS — git tag on repo |
| Jira status sync | Human (CQ5) | Align TASK-516–542 with delivered state |
| Public docs hosting | Deferred | Wave D Q3 |

## Related

- Epic research: [`docs/specs/task-515/task-515.research.md`](../../specs/task-515/task-515.research.md)
- Close-out plan: [`docs/specs/task-515/task-515.close-out.plan.md`](../../specs/task-515/task-515.close-out.plan.md)
- Task baseline: [`task-baseline.md`](./task-baseline.md)
