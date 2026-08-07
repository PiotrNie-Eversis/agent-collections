# Agent instructions

Short orientation map for AI agents working in this repository: where areas live, which framework roles exist, and how to enter Agent Collections workflows.

## Framework

This consumer project uses **Agent Collections**.

- **Local mode:** Core SSOT is `$AGENT_COLLECTIONS_HOME/.ai/` (not copied into this repo). Enable MCP **`eversis-collections`**.
- **Submodule / copy mode:** SSOT may live under `vendor/agent-collections/.ai/` — still prefer MCP for skills.
- **Prompts:** load by stable id (e.g. `eversis-implement`) under the framework `.ai/prompts/` tree.
- **Orchestration:** `.ai/rules/orchestration/agent-core.md` + **`spec-driven-development.md`** (via framework home).
- **Path policy:** do not commit machine-local absolute paths; use `$AGENT_COLLECTIONS_HOME` or relative in-repo paths.

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
- Canonical rule: `$AGENT_COLLECTIONS_HOME/.ai/rules/orchestration/spec-driven-development.md` (or under `vendor/agent-collections/` when vendored)

## Project specifics

<!-- Replace this section with project-specific agent instructions. -->
<!-- Cursor: stack commands / lint targets belong in `.cursor/rules/eversis-project-stack.mdc`. -->
<!-- Claude Code: put stack, areas, and skills policy here in AGENTS.md (Claude does not load Cursor .mdc rules). -->
<!-- Do not hand-edit generated CLAUDE.md. -->

---

## Channel notes (Cursor)

Optional. Ignored by non-Cursor tools.

On the **Cursor** channel, Implement can be started with either:

- `/eversis-implement` — Cursor command (when `.cursor/commands/` is scaffolded)
- `@eversis-implement` — attach the prompt by file stem

Both refer to the same prompt id `eversis-implement`. Prefer the neutral id in shared docs; use `/` or `@` as Cursor UX convenience.
