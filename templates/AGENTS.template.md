# Agent instructions

Short orientation map for AI agents working in this repository: where areas live, which framework roles exist, and how to enter Agent Collections workflows.

## Framework

- **Core SSOT:** `.ai/` — rules, skills, prompts (see `.ai/README.md`)
- **Adapters:** `adapters/` — tool packaging (Cursor, Claude Code, OpenCode placeholder); refresh with `node adapters/sync.mjs`
- **Orchestration:** start with `.ai/rules/orchestration/agent-core.md` and **`spec-driven-development.md`**; load `engineering-manager` for Implement
- **Prompts:** load by stable id under `.ai/prompts/` (e.g. `eversis-implement`, `eversis-review`)
- **Skills:** MCP server **`eversis-collections`** (`eversis_skills_list` / `eversis_skills_get`) when enabled; otherwise read `.ai/skills/*/SKILL.md`
- **AGENTS standard:** `docs/architecture/agents-md-standard.md`
- **Versioning / upgrade:** root `README.md` and `CHANGELOG.md`

## Project deliverables

Use these folders for agent/project artifacts (same triad as cursor-collections):

| Path | Role |
|------|------|
| `docs/context/` | Internal knowledge, architecture notes, task baselines |
| `docs/plans/` | Optional flat plans; prefer specs for Implement workflow |
| `docs/specs/` | SDD research / plan / plan-review (`docs/specs/<issue-kebab>/`) |

## Monorepo / Areas

| Area | Path | Notes |
|------|------|-------|
| <!-- e.g. Frontend --> | <!-- e.g. apps/web --> | <!-- ownership / scope hint --> |
| <!-- e.g. Backend --> | <!-- e.g. apps/api --> | <!-- ownership / scope hint --> |
| <!-- e.g. Shared --> | <!-- e.g. packages/* --> | <!-- ownership / scope hint --> |

## Role matrix

| Role | Responsibility | Entry |
|------|----------------|-------|
| Business Analyst | Ideate / workshop → Jira-ready backlog | prompt `eversis-analyze-materials` |
| Engineering Manager | Orchestrate Implement (research → plan → execute → review) | prompt `eversis-implement` + rule `engineering-manager` |
| Context Engineer | Research artifact (`*.research.md`) | prompt `eversis-research` |
| Architect | Implementation plan (`*.plan.md`) | prompt `eversis-plan` |
| Plan Reviewer | Validate plan before execution | prompt `eversis-review-plan` |
| Software Engineer | Application / UI implementation tasks | prompts `eversis-implement-common-task` / UI variant |
| DevOps Engineer | Terraform, pipeline, observability, K8s deploy | prompts `eversis-implement-{terraform,pipeline,observability,…}` |
| E2E Engineer | End-to-end tests | prompt `eversis-implement-e2e` |
| Prompt Engineer | LLM application prompts | prompt `eversis-engineer-prompt` |
| UI Reviewer | Figma / UI verification | prompt `eversis-review-ui` |
| Code Reviewer | Code review gate | prompt `eversis-review` + rule `code-reviewer` |
| Repo Docs Writer | README, CHANGELOG, in-repo docs | prompt `eversis-repo-docs-writer` |
| Framework customization | Extend rules / skills / prompts / instructions | prompts `eversis-create-custom-*` |
| BA Docs planner/writer | Word `.docx` release docs (optional) | prompts `eversis-ba-docs-*` — consumer policy |

## Delivery Standard

Mandatory for framework and consumer deliveries that opt into SDD:

```text
Ideate → Research → Plan → Implement → Review → Fine
```

- Spec folder: `docs/specs/<issue-kebab>/`
- Research: `<issue-kebab>.research.md` (approve before plan)
- Plan: `<issue-kebab>.plan.md` (approve before implement)
- Canonical rule: `.ai/rules/orchestration/spec-driven-development.md`

## Project specifics

<!-- Replace this section with project-specific agent instructions. -->
<!-- Stack commands and lint/test invocations belong in the consumer project-stack rule, not here. -->

---

## Channel notes (Cursor)

Optional. Ignored by non-Cursor tools.

On the **Cursor** channel, Implement can be started with either:

- `/eversis-implement` — Cursor command (when `.cursor/commands/` is scaffolded)
- `@eversis-implement` — attach the prompt by file stem

Both refer to the same prompt id `eversis-implement`. Prefer the neutral id in shared docs; use `/` or `@` as Cursor UX convenience.
