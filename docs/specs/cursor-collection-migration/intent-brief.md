# Cursor Collection Migration — Intent Brief

## Workshop Summary

| Field | Value |
|---|---|
| Workshop Date | 2026-07-30 |
| Participants | Piotr Niemirski (reporter / product owner) |
| Source Materials | BRD `Cursor-Collection-migration.md`; Jira epic [DHI-515](https://eversis.atlassian.net/browse/DHI-515); codebase analysis of `cursor-collections` and `agent-collections` |
| Prepared By | eversis-analyze-materials (Business Analyst) |

## Goal

Transform the Cursor-centric **Cursor Collections** framework into a vendor-agnostic **Agent Collections** standard that preserves proven rules, prompts, and skills as a single source of truth while supporting Cursor, Claude Code CLI, and future agents (OpenCode). The outcome must be enterprise-ready: replicable across monorepos and teams in under five minutes, with collision-free context isolation and a clear upgrade path from the central framework repository.

## In Scope

- Extraction of core neutral rules from `cursor-collections` into `agent-collections` (`.ai/` or equivalent SSOT)
- Domain-organized core rules (frontend, backend, shared-types, devops, architecture, shared orchestration)
- Tool adapters: Cursor (`.cursor/rules/*.mdc`), Claude Code (`CLAUDE.md`), OpenCode placeholder manifest
- Synchronized ignore files (`.cursorignore`, `.claudeignore`, `.opencodeignore`) and monorepo glob scoping
- Standardized agnostic `AGENTS.md` as monorepo context map and role matrix
- Distribution model: self-contained repo, bash/CLI install bootstrap, modular profiles (Frontend-only, Backend-only, Fullstack Monorepo)
- **Interactive install wizard:** choose AI agent adapter(s) (Cursor / Claude Code / OpenCode placeholder / multi) **and** MCP server set for the target project
- Migration documentation and pilot validation in the **EOG** enterprise monorepo
- Porting framework MCP server and install scripts from `cursor-collections` where they remain part of the deliverable standard
- **Docusaurus documentation site** migration from `cursor-collections` to `agent-collections`, with full rebrand from Cursor Collections to Agent Collections
- **Mandatory delivery standard:** every story under DHI-515 is executed using **full spec-driven development** (research → plan → implement → review, with human gates and `docs/specs/<issue-kebab>/` artifacts)

## Delivery Standard (mandatory for all DHI-515 stories)

All implementation work under epic **DHI-515** follows the Eversis **spec-driven development** lifecycle. This is non-negotiable for every story pushed to Jira.

| Phase | Artifact / action | Gate |
|-------|-------------------|------|
| **Ideate** | Backlog story + acceptance criteria (this session) | Gate 1 / Jira push approval |
| **Research** | `docs/specs/<issue-kebab>/<issue-kebab>.research.md` | Human approval before plan |
| **Plan** | `docs/specs/<issue-kebab>/<issue-kebab>.plan.md` | Human approval before implementation |
| **Implement** | Code/config/docs changes via `@eversis-implement` | Adequacy checklist; no broad edits without approved plan |
| **Review** | `@eversis-review` (PASS / BLOCKER / SUGGESTION) | Before declaring Fine |
| **Fine** | QA comment draft per `eversis-fine-handoff` | Human approval before Jira publication |

**Spec folder convention:** `docs/specs/<issue-kebab>/` (e.g. `docs/specs/dhi-516-core-structure/` for Jira key DHI-516).

**Jira story descriptions** must include a **Delivery Standard** section referencing this lifecycle so assignees cannot start implementation without research and plan artifacts.

## Out of Scope

- Full OpenCode adapter implementation (placeholder/manifest only per BRD)
- Rewriting business or architectural rule content — migration and neutralization, not re-authoring
- Consumer product application code (frontend/backend features in EOG or other products beyond framework install validation)
- Deprecation or archival of `cursor-collections` — it **remains a separate Cursor-specific distribution channel** (code/install); **documentation stays fully independent** (no cross-repo doc links)
- Story point estimation and sprint planning (team refinement)

## Key Stakeholders / Actors

- **Platform / framework maintainer** — owns `agent-collections`, core SSOT, adapters, and distribution
- **Frontend team** — consumes Cursor adapter with scoped frontend context in monorepo
- **Backend team** — consumes Claude Code adapter with scoped backend/system context
- **Enterprise monorepo owner** — deploys modular profiles and validates isolation in production layout
- **Engineering Manager / tech lead** — approves project-specific stack rules and module selection at install time

## Candidate Epics (work streams under DHI-515)

| # | Work stream | Rationale |
|---|-------------|-----------|
| 1 | **Core Rules Extraction** | BRD Phase 1 / WF-01 / Filar 1 — SSOT from legacy assets |
| 2 | **Multi-Agent Adapters** | BRD Phase 2 / WF-02 / Filar 2 — Cursor, Claude, OpenCode interface |
| 3 | **Context Isolation** | BRD WF-03 — collision-free multi-agent monorepo |
| 4 | **AGENTS.md Standard** | BRD WF-04 — agnostic context map for all agents |
| 5 | **Distribution & Replication** | BRD Phase 3 / WF-05 / Filar 3 — install, modules, upgrade |
| 6 | **Documentation & Validation** | BRD Phase 3 milestones + WNF-03 context performance proof |

## Baseline Overlap / Existing Backlog Notes

- **Jira parent epic:** [DHI-515](https://eversis.atlassian.net/browse/DHI-515) — *Multi-Agent AI Context Isolation & Standard* (no child issues yet)
- **Project baseline:** `docs/context/<project>/task-baseline.md` — **None** (first backlog session for this initiative)
- **`agent-collections` repo state:** Early scaffold — local Cursor rules copied, skills/prompts/commands symlinked to sibling `cursor-collections`; no `.ai/` core, no adapters, no install scripts
- **`cursor-collections` legacy assets:** 8 rules, 45 skills, 28 prompts, 8 commands, MCP server, `setup-cursor-local.sh`, Docusaurus website

## Resolved Decisions (2026-07-30)

| # | Question | Decision |
|---|----------|----------|
| Q1 | Docusaurus site location and branding | **Migrate** the Docusaurus site to `agent-collections`; rebrand all references from Cursor Collections → Agent Collections |
| Q2 | Phase 3 pilot monorepo | **EOG** (Earth Observation Gateway; frontend `portal/`, backend `cms/`, existing Cursor Collections install via `scripts/setup-cursor-local.sh`) |
| Q3 | `cursor-collections` post-migration role | **Remain a separate Cursor-specific distribution channel** (code/install) — not deprecated; coexists with `agent-collections` as the multi-agent SSOT |
| Q4 | Delivery standard for all DHI-515 work | **Full spec-driven development mandatory** — every story requires `docs/specs/<issue-kebab>/` with `*.research.md` and `*.plan.md`, human gates, `@eversis-implement`, `@eversis-review`, Fine handoff; Jira descriptions must include Delivery Standard section |
| Q5 | Bash install wizard scope | Installer must let the user choose **AI agent adapter(s)** for the project **and** **MCP servers** (extend legacy `--mcp-servers` / interactive MCP prompt; add agent selection axis) |
| Q6 | Documentation coupling | **Fully separated** — `agent-collections` and `cursor-collections` documentation must not connect via pointers, redirects, or shared doc channels |

## Gate 0 Approval

| Decision | Notes |
|---|---|
| **Skipped — materials unambiguous** | Structured BRD with WF/WNF IDs, three-phase roadmap, and explicit target repo; Jira epic DHI-515 aligns with BRD goal. No conflicting sources. Confirmed skip 2026-07-30. |
