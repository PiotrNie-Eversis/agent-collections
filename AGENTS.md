# Agent instructions

Short orientation map for AI agents in the **Agent Collections** framework repository. Core SSOT lives under **`.ai/`**.

## Framework

- **Core SSOT:** `.ai/` — rules, skills, prompts (see [`.ai/README.md`](./.ai/README.md))
- **Adapters:** [`adapters/`](./adapters/) — Cursor, Claude Code, OpenCode placeholder; refresh with `node adapters/sync.mjs`
- **Orchestration:** [`.ai/rules/orchestration/agent-core.md`](./.ai/rules/orchestration/agent-core.md) + [`spec-driven-development.md`](./.ai/rules/orchestration/spec-driven-development.md); load `engineering-manager` for Implement
- **Prompts:** load by stable id under [`.ai/prompts/`](./.ai/prompts/) (e.g. `eversis-implement`, `eversis-review`)
- **Skills:** MCP server **`eversis-collections`** when enabled; otherwise read `.ai/skills/*/SKILL.md`
- **AGENTS standard / template:** [`docs/architecture/agents-md-standard.md`](./docs/architecture/agents-md-standard.md), [`templates/AGENTS.template.md`](./templates/AGENTS.template.md)
- **Versioning / upgrade:** [`README.md`](./README.md), [`CHANGELOG.md`](./CHANGELOG.md)
- **Isolation / adapters:** [`docs/architecture/isolation-strategy.md`](./docs/architecture/isolation-strategy.md), [`docs/architecture/adapter-mapping.md`](./docs/architecture/adapter-mapping.md)

## Project deliverables

| Path | Role |
|------|------|
| [`docs/context/`](./docs/context/) | Internal knowledge, task baselines |
| [`docs/plans/`](./docs/plans/) | Optional flat plans; prefer specs for Implement |
| [`docs/specs/`](./docs/specs/) | SDD research / plan (`docs/specs/<issue-kebab>/`; `dhi-*` local-only / gitignored in this repo) |

## Monorepo / Areas

| Area | Path | Notes |
|------|------|-------|
| Core SSOT | `.ai/` | Rules, skills, prompts |
| Adapters | `adapters/` | Tool packaging + `sync.mjs` |
| Architecture docs | `docs/architecture/` | Mapping, isolation, AGENTS standard |
| <!-- more areas --> | <!-- path --> | <!-- DHI-532: complete reference fill --> |

## Role matrix

| Role | Responsibility | Entry |
|------|----------------|-------|
| Business Analyst | Ideate / workshop → Jira-ready backlog | prompt `eversis-analyze-materials` |
| Engineering Manager | Orchestrate Implement | prompt `eversis-implement` + rule `engineering-manager` |
| Context Engineer | Research (`*.research.md`) | prompt `eversis-research` |
| Architect | Plan (`*.plan.md`) | prompt `eversis-plan` |
| Plan Reviewer | Validate plan | prompt `eversis-review-plan` |
| Software Engineer | Implementation tasks | prompts `eversis-implement-common-task` / UI variant |
| DevOps Engineer | Infra / CI / observability | prompts `eversis-implement-{terraform,pipeline,observability,…}` |
| E2E Engineer | End-to-end tests | prompt `eversis-implement-e2e` |
| Prompt Engineer | LLM application prompts | prompt `eversis-engineer-prompt` |
| UI Reviewer | UI verification | prompt `eversis-review-ui` |
| Code Reviewer | Code review gate | prompt `eversis-review` + rule `code-reviewer` |
| Repo Docs Writer | README, CHANGELOG, docs | prompt `eversis-repo-docs-writer` |
| Framework customization | Extend rules / skills / prompts | prompts `eversis-create-custom-*` |
| BA Docs planner/writer | Word `.docx` (optional) | prompts `eversis-ba-docs-*` — consumer policy |

## Delivery Standard

```text
Ideate → Research → Plan → Implement → Review → Fine
```

- Spec folder: `docs/specs/<issue-kebab>/` — see [`docs/specs/README.md`](./docs/specs/README.md)
- Canonical rule: [`.ai/rules/orchestration/spec-driven-development.md`](./.ai/rules/orchestration/spec-driven-development.md)

## Project specifics

<!-- Framework-repo-specific notes; full reference fill → DHI-532. -->
<!-- Stack / quality commands → consumer or local project-stack rule. -->

---

## Channel notes (Cursor)

Optional. Ignored by non-Cursor tools.

On the **Cursor** channel, Implement can be started with either:

- `/eversis-implement` — Cursor command (when `.cursor/commands/` is scaffolded)
- `@eversis-implement` — attach the prompt by file stem

Both refer to prompt id `eversis-implement`. Temporary Cursor scaffold may still reference a sibling cursor-collections checkout under `.cursor/` until self-contained bootstrap lands.
