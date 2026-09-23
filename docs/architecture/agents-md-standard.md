# AGENTS.md standard

Normative standard for the root **`AGENTS.md`** orientation file in Agent Collections (BRD WF-04).

**Related:** copyable consumer template [`templates/AGENTS.template.md`](../../templates/AGENTS.template.md). Reference fill for this repository is out of scope here (see the repository's own `AGENTS.md`). Isolation orientation role: [`isolation-strategy.md`](./isolation-strategy.md) §7.3. OpenCode dual surface note: [`adapter-mapping.md`](./adapter-mapping.md) §6.2.

## Purpose

`AGENTS.md` is a **small, high-value context map** for any AI agent (Cursor, Claude Code, OpenCode, others). It tells the agent where project areas live, which framework roles exist, and how to enter the Delivery Standard — without dumping the whole monorepo into the session.

It is **not** a constitution, stack doc, or procedural skill. Put stack/commands in the consumer project-stack rule; put how-to in skills; put long policies in `.ai/rules/`.

## Language

**English only** for all framework product content (templates, standards, rules, skills, prompts, README, AGENTS). Do not ship Polish or bilingual framework mirrors.

## Required structure

Every `AGENTS.md` produced from this standard (template, install seed, or reference) MUST include these sections in order:

| # | Section | Required | Content |
|---|---------|----------|---------|
| 1 | Title + intro | Yes | Heading **Agent instructions** (no tool name in the title). 1–2 sentences: orientation map for agents. |
| 2 | Framework | Yes | Pointers to `.ai/` (rules, skills, prompts), adapters, sync entry, MCP server id `eversis-collections`, primary prompt ids, SDD / orchestration entry. |
| 3 | Project deliverables | Yes | Four paths: `docs/context/`, `docs/plans/`, `docs/specs/`, `docs/decisions/` (see below). |
| 4 | Monorepo / Areas | Yes | Table or list: area → path → note. Use HTML comment placeholders until filled. |
| 5 | Role matrix | Yes | Framework **agent** roles only (see Role matrix). One line per role: purpose + entry (prompt/rule id). |
| 6 | Delivery Standard | Recommended | Short pointer to `docs/specs/<issue-kebab>/` and Research → Plan → Implement → Review → Fine gates. |
| 7 | Project specifics | Yes | Consumer-owned overrides; start empty with HTML comment placeholders. |
| 8 | Channel notes (Cursor) | Optional appendix | Cursor-only UX (`/` commands, `@` attach). Must not be required to understand the map. |

## Project deliverables

When working with the framework in **any** repository, agent/project deliverables use the same folders as cursor-collections:

| Path | Role |
|------|------|
| `docs/context/` | Internal knowledge, architecture notes, task baselines (`docs/context/<project>/…`) |
| `docs/plans/` | Legacy/flat plans if used; prefer `docs/specs/<issue>/` for Implement workflow plans |
| `docs/specs/` | SDD research / plan / plan-review artifacts (`docs/specs/<issue-kebab>/`) |
| `docs/decisions/` | Architecture decisions — one file per decision plus `INDEX.md` |

**Framework repository note:** all `docs/specs/*/` subfolders are **gitignored** (local-only story work on the framework itself), regardless of naming. They are not the published product surface. Committed standards and templates live elsewhere (this file, `templates/`).

## Role matrix

Include the **framework agent roles** used by orchestration (not a separate human-stakeholder matrix). Human / team ownership belongs in **Monorepo / Areas** or **Project specifics**.

Minimum set (one line each):

| Role | Entry (neutral) |
|------|-----------------|
| Business Analyst | prompt `eversis-analyze-materials` |
| Engineering Manager | prompt `eversis-implement` + rule `engineering-manager` |
| Context Engineer | prompt `eversis-research` |
| Architect | prompt `eversis-plan` |
| Plan Reviewer | prompt `eversis-review-plan` |
| Software Engineer | prompts `eversis-implement-common-task` / UI variant |
| DevOps Engineer | prompts `eversis-implement-{terraform,pipeline,observability,…}` |
| E2E Engineer | prompt `eversis-implement-e2e` |
| Prompt Engineer | prompt `eversis-engineer-prompt` |
| UI Reviewer | prompt `eversis-review-ui` |
| Code Reviewer | prompt `eversis-review` + rule `code-reviewer` |
| Repo Docs Writer | prompt `eversis-repo-docs-writer` |
| Framework customization | prompts `eversis-create-custom-*` |
| BA Docs planner/writer | optional — consumer policy |

Prefer names like **Framework customization** over legacy `cursor-customization-*` labels.

## Neutralization dictionary (AC #2)

The **main body** MUST NOT use Cursor-only instructions as the primary form. Use neutral equivalents:

| Avoid as primary | Prefer |
|------------------|--------|
| `@eversis-implement` (only) | prompt id `eversis-implement` |
| “attach with `@`” as the only way to load prompts | “load prompt by stable id under `.ai/prompts/`” |
| `.cursor/rules/*.mdc` as SSOT | `.ai/rules/…`; note that an adapter may emit tool packaging |
| `.cursor/mcp.json` as the only MCP path | enable MCP server **`eversis-collections`** (config path is per tool) |
| Title “Agent instructions (Cursor)” | “Agent instructions” |

Cursor `/` slash commands and `@` attach remain valid **on the Cursor channel**; document them only in **Channel notes (Cursor)** (or equivalent appendix), alongside the neutral prompt id.

## Channel notes (Cursor)

Optional appendix. When present, it SHOULD state that on Cursor both of the following start Implement (parity with cursor-collections):

- `/eversis-implement` — Cursor command (when commands are scaffolded by the Cursor adapter)
- `@eversis-implement` — prompt attach by file stem

Other tools ignore this appendix.

## Install contract (AC #3)

For future installer / bootstrap (Work Stream 5; **not implemented in this standard**):

| Rule | Detail |
|------|--------|
| Source | `templates/AGENTS.template.md` in this repository |
| Destination | consumer repo root `AGENTS.md` |
| Semantics | **Create if absent**; **never overwrite** an existing `AGENTS.md` without explicit consumer opt-in |
| Placeholders | HTML comments `<!-- … -->` for Areas and Project specifics; consumers fill locally |
| Also scaffold | Prefer creating `docs/context/`, `docs/plans/`, `docs/specs/` (with README scaffolds) when missing, and `docs/decisions/` (README + `INDEX.md`) when missing |

Verification of this story’s AC #3 is by **documented contract + template file**, not by running an installer CLI.

## Boundary with the AGENTS.md reference fill

| Item | Delivers |
|-------|----------|
| **This standard** | Standard + template + root `AGENTS.md` **restructured** to template shape with placeholders / short pointers |
| **AGENTS.md reference fill** | Complete **reference** `AGENTS.md` for `agent-collections` (filled areas, maintainer roles, install entry points) |

## Out of scope here

- Installer / wizard wiring
- Adapter generators and `adapters/sync.mjs` behavior
- Ignore triad / monorepo path globs
- Rewriting legacy `cursor-collections` AGENTS
- Long stack, lint, or test command lists (project-stack rule)

## Related

- Template: [`templates/AGENTS.template.md`](../../templates/AGENTS.template.md)
- Creating instructions skill: `.ai/skills/eversis-creating-instructions/SKILL.md`
- Specs guide: [`docs/specs/README.md`](../specs/README.md)
