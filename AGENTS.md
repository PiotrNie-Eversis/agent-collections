# Agent instructions

Short orientation map for AI agents in the **Agent Collections** framework repository. Core SSOT lives under **`.ai/`**.

## Framework

- **Core SSOT:** `.ai/` — rules, skills, prompts (see [`.ai/README.md`](./.ai/README.md))
- **Adapters:** [`adapters/`](./adapters/) — Cursor, Claude Code, OpenCode placeholder; refresh with `node adapters/sync.mjs` (optional `--agents cursor,claude`)
- **Domain / area profiles:** [`adapters/profiles/`](./adapters/profiles/) — Frontend / Backend / Fullstack + area globs
- **Installer:** [`scripts/setup-agent-collections.sh`](./scripts/setup-agent-collections.sh) — local / submodule / copy; selection at `.agent-collections/install-selection.json`
- **MCP:** package [`mcp/eversis-collections-mcp/`](./mcp/eversis-collections-mcp/); server id **`eversis-collections`**; env **`AGENT_COLLECTIONS_HOME`**; skills resolve from `.ai/skills/`
- **Orchestration:** [`.ai/rules/orchestration/agent-core.md`](./.ai/rules/orchestration/agent-core.md) + [`spec-driven-development.md`](./.ai/rules/orchestration/spec-driven-development.md); load `engineering-manager` for Implement
- **Prompts:** load by stable id under [`.ai/prompts/`](./.ai/prompts/) (e.g. `eversis-implement`, `eversis-review`)
- **Skills:** MCP **`eversis-collections`** when enabled; otherwise read `.ai/skills/*/SKILL.md`
- **AGENTS standard / template:** [`docs/architecture/agents-md-standard.md`](./docs/architecture/agents-md-standard.md), [`templates/AGENTS.template.md`](./templates/AGENTS.template.md)
- **Versioning / upgrade:** [`README.md`](./README.md), [`CHANGELOG.md`](./CHANGELOG.md), install selection [`docs/architecture/install-selection.md`](./docs/architecture/install-selection.md)
- **Isolation / adapters:** [`docs/architecture/isolation-strategy.md`](./docs/architecture/isolation-strategy.md), [`docs/architecture/adapter-mapping.md`](./docs/architecture/adapter-mapping.md)

## Project deliverables

| Path | Role |
|------|------|
| [`docs/context/`](./docs/context/) | Internal knowledge, task baselines |
| [`docs/plans/`](./docs/plans/) | Optional flat plans; prefer specs for Implement |
| [`docs/specs/`](./docs/specs/) | SDD research / plan (`docs/specs/<issue-kebab>/`; `task-*` local-only / gitignored in this repo) |
| [`docs/decisions/`](./docs/decisions/) | Architecture decisions — one file per decision plus `INDEX.md` |

## Monorepo / Areas

| Area | Path | Notes |
|------|------|-------|
| Core SSOT | `.ai/` | Rules, skills, prompts |
| Adapters | `adapters/` | Tool packaging + `sync.mjs` + `profiles/` |
| MCP | `mcp/eversis-collections-mcp/` | Skills MCP; build with `npm run mcp:build` |
| Installer | `scripts/` | `setup-agent-collections.sh` + lib |
| Templates | `templates/` | AGENTS / stack / MCP seed |
| Architecture docs | `docs/architecture/` | Mapping, isolation, AGENTS standard, selection schema |

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

- This repository is the **framework** product (not a consumer app). Stack policy: [`.cursor/rules/eversis-project-stack.mdc`](./.cursor/rules/eversis-project-stack.mdc).
- Quality commands: `npm run sync:adapters`, `npm run sync:adapters:check`, `npm run mcp:build`, `npm run mcp:test`, installer smoke `bash scripts/setup-agent-collections.test.sh`, `npm run website:build`, `npm run website:changelog:check`.
- Skills UX: MCP + `.ai/` load-by-id / `@` attach. Cursor also emits thin `/eversis-*` shims under `.cursor/commands/` (TASK-598); full `.cursor/skills|prompts` mirror is **not** shipped.
- BA Docs skills: **Do not load** in this framework repo unless a plan explicitly requires them.

---

## Channel notes (Cursor)

Optional. Ignored by non-Cursor tools.

On the **Cursor** channel, Implement can be started by stable id, `@` attach, or slash command:

- Primary entry remains prompt id **`eversis-implement`** under `.ai/prompts/public/`
- `@eversis-implement` — attach when the file is surfaced in the picker (prefer `.ai/prompts/…` over docs-site copies)
- `/eversis-implement` — project command from generated `.cursor/commands/eversis-implement.md` (after `npm run sync:adapters`)
- **Continuity:** a normal `/eversis-implement` thread runs **Review then Fine** in-session after code (no separate human `/eversis-review` required to close Delivery Standard). Opt-out: say `pause before review` or `review later`.
- `/eversis-review` — **standalone** code review (or re-review); optional when you want a review-only chat

Slash files are thin HYBRID shims (SSOT pointer + Executable section). They are **not** used by Claude Code.
