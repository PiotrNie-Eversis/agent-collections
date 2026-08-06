# Agent Collections

A **vendor-neutral** multi-agent product engineering framework — rules, prompts, skills, adapters, and MCP — so teams can move work from idea to reviewed delivery with clear human checkpoints.

**Ideate → Research → Plan → Implement → Review → Fine** — one Delivery Standard, end to end.

Maintained by [Eversis](https://eversis.com).

**Status:** Self-contained distribution MVP (`v0.0.1`). A fresh clone works without a sibling [Cursor Collections](https://github.com/PiotrNie-Eversis/cursor-collections) checkout. That product remains a **separate** Cursor channel — it does **not** share SemVer or a docs portal with Agent Collections.

---

## Who this is for

- **Business analysts / product** — turn workshop materials into structured backlog items with review before anything is pushed to Jira.
- **Engineers / tech leads** — research, plan, and implement in small steps with acceptance checks and a structured code review.
- **Anyone new to the project** — this README is the map; deeper playbooks live under `website/docs/` (build locally — public hosting is deferred).

You do **not** need to know the folder layout to start. Start with a workflow below, then install when you are ready.

---

## What this repository provides

Canonical content lives under **`.ai/`**. Adapters, the installer, and MCP **consume** that content — they do not own it.

### Ideate — Requirements & planning

- **Rules** — Business Analyst behavior (attach on demand).
- **Prompts** — `eversis-analyze-materials` (optional Cursor `@` attach when surfaced).
- **Skills** — task analysis, transcript processing, task extraction, Jira formatting.

### Implement — Architecture & delivery

- **Rules** — always-on agent core; Engineering Manager for orchestration.
- **Prompts** — `eversis-implement` (research → plan → code, with human gates).
- **Skills** — orchestration, architecture, technical context, domain implementation (per project stack policy).

### Quality — Review & testing

- **Rules** — Code Reviewer (PASS / BLOCKER / SUGGESTION).
- **Prompts** — `eversis-review`, `eversis-review-ui`, `eversis-review-codebase`.
- **Skills** — code review, UI verification, E2E testing.

### Framework customization

- **Prompts** — `eversis-create-custom-*` under `.ai/prompts/public/`.
- **Skills** — creating rules, skills, prompts, and project instructions.

### Infrastructure

- **Adapters** — Cursor, Claude Code, and OpenCode (placeholder) under `adapters/`.
- **MCP** — local **`eversis-collections`** skills server plus optional Atlassian, Figma, Context7, Playwright, and related integrations.
- **Installer** — `scripts/setup-agent-collections.sh` (local / submodule / copy).

> **Why the `eversis-` prefix?** Artifact ids use `eversis-` (e.g. `eversis-implement`) so they do not collide with your project-specific rules, skills, and prompts.

---

## Prerequisites

- **Agent tool:** [Cursor](https://cursor.com/) and/or Claude Code (OpenCode packaging is placeholder only).
- **Node.js** ≥ 18 — to build the local **`eversis-collections`** MCP package.
- **Git** — clone and consumer install.

Recommended: capable models (Claude Sonnet or GPT-4 class) for structured rules and prompts.

---

## Supported workflows

Rules and prompts work best **in order**, with **your review** at each gate.

> **Ideate → Research → Plan → Implement → Review → Fine**

### Phase 1: Ideate — Requirements & planning

- Turns workshop transcripts, designs, and documents into structured work items.
- Runs quality review before Jira formatting.
- Uses human gates before any Jira sync — nothing is pushed without your approval.
- Writes artifacts under `docs/specs/` in the consumer project.

### Phase 2: Implement — Architecture & delivery

- Produces research (`*.research.md`) and a phased plan (`*.plan.md`) with acceptance checks when needed.
- Changes code in small, reviewable steps — scoped to the task.
- Declares **Fine** when agent work is done and drafts a **QA comment** for your review before anyone posts it to a ticket tracker.

| Step | Load / attach | What happens |
| ---- | ------------- | ------------ |
| Implement | `eversis-implement` (optional `@eversis-implement` in Cursor) | Engineering Manager orchestrates research → plan → implementation; Fine + QA draft |
| Review | `eversis-review` | Structured code review — PASS / BLOCKER / SUGGESTION |

### Phase 3: Review — Quality & testing

- Structured review against acceptance criteria, security, and reliability.
- Optional UI vs Figma checks (`eversis-review-ui`) and Playwright E2E when the plan includes them.
- Codebase-wide analysis via `eversis-review-codebase` when you need a health pass.

More variants (workshop-only, UI + Figma, E2E, BA Word docs): [workflow overview](./website/docs/workflow/overview.md).

### Example: Full lifecycle (standard flow)

```text
IDEATE
1) eversis-analyze-materials <transcript + workshop materials>
  ↳ Review extracted tasks and quality findings
  ↳ Approve gates before any Jira sync

IMPLEMENT
2) eversis-implement <JIRA_ID or task description>
  ↳ Review the research document
  ↳ Confirm to proceed to planning
  ↳ Review the implementation plan (phases + acceptance checks)
  ↳ Confirm scope before broad code changes
  ↳ Review code after each phase
  ↳ Agent declares Fine — QA comment draft; approve before posting to Jira

REVIEW
3) eversis-review <JIRA_ID or task description>
  ↳ Review findings
  ↳ Address blockers before merging
```

You can run any flow with a **Jira ticket ID** or a **free-form task description**.

> **Important:** Each step needs your review. Open the generated documents, iterate until they look right, and treat every agent output as a **draft** until you approve the next gate. AI assistance does not replace human judgment.

---

## Quick start (this repository)

1. Clone this repository (no sibling framework required).
2. Export the framework home for MCP:

```bash
export AGENT_COLLECTIONS_HOME="$(pwd)"
```

3. Build MCP (skills discoverability):

```bash
npm run mcp:install && npm run mcp:build
```

4. Refresh adapter surfaces (after changing `.ai/` rules or adapter maps):

```bash
npm run sync:adapters
# drift check:
npm run sync:adapters:check
```

5. Enable MCP server **`eversis-collections`** (see [`templates/mcp.json`](./templates/mcp.json)) — or read `.ai/skills/*/SKILL.md` / load prompts by stable id under `.ai/prompts/`.

6. Try a short task: load **`eversis-implement`** with a ticket id or a sentence describing the work.

**MVP note:** This distribution does **not** ship a full mirror of skills/prompts under `.cursor/skills` or `.cursor/prompts`, and does **not** generate slash-commands under `.cursor/commands/`. Prefer MCP + load-by-id / optional `@` attach.

First successful install checklist: [Start here](./website/docs/getting-started/start-here.md).

---

## Install into a consumer project

```bash
export AGENT_COLLECTIONS_HOME=/path/to/agent-collections
bash "$AGENT_COLLECTIONS_HOME/scripts/setup-agent-collections.sh" \
  --build-mcp --non-interactive \
  --agents=cursor \
  --mcp-servers=eversis-collections \
  --profile=fullstack
```

### Vendor modes

| Mode | Flag | Notes |
|------|------|-------|
| **Local** | (default) | Framework stays outside the consumer repo; set `AGENT_COLLECTIONS_HOME` |
| **Submodule** | `--vendor submodule` | **EOG / team default** |
| **Copy** | `--vendor copy` | Vendors tree under `vendor/agent-collections/` |

Useful flags: `--link-mode auto|symlink|copy`, `--sync`, `--upgrade`, `--agents`, `--mcp-servers`, `--profile frontend|backend|fullstack`.

Interactive wizard prompts for agents × MCP × domain profile. Re-runs are idempotent; partial failures list completed vs failed steps with recovery hints.

Selection is recorded at `.agent-collections/install-selection.json` (schema: [`docs/architecture/install-selection.md`](./docs/architecture/install-selection.md)).

Full install guide (including Windows): [Installation](./website/docs/getting-started/installation.md).

Migrating from Cursor Collections (`setup-cursor-local.sh` / `CURSOR_COLLECTIONS_HOME`): [Migration guide](./website/docs/getting-started/migration-from-cursor-collections.md).

### Upgrade

```bash
bash scripts/setup-agent-collections.sh --upgrade --sync --non-interactive
```

Reuses agents / MCP / profile / vendor / link from selection. Missing or corrupt selection **fails** with wizard instructions (no invented full install). Project-owned paths are not overwritten without opt-in (see below).

---

## Public prompts at a glance

Prompt bodies live under **`.ai/prompts/public/`**. Full catalog: [prompts overview](./website/docs/prompts/overview.md).

| Workflow | Stable id (optional Cursor `@` attach) |
| -------- | -------------------------------------- |
| Workshop → Jira | `eversis-analyze-materials` |
| Implement | `eversis-implement` |
| Code review | `eversis-review` |
| UI vs Figma | `eversis-review-ui` |
| Codebase health | `eversis-review-codebase` |
| Infra audit | `eversis-audit-infrastructure` |
| AWS / GCP cost | `eversis-analyze-aws-costs`, `eversis-analyze-gcp-costs` |
| BA docs — plan / write | `eversis-ba-docs-planner`, `eversis-ba-docs-writer` |
| Create rules / skills / prompts | `eversis-create-custom-*` |

Internal delegation prompts (research, plan, implement-ui, …) live under **`.ai/prompts/internal/`**.

---

## Agents

Roles are expressed as **rules**, **prompts**, and **skills**, organized by lifecycle phase. Full roster: [agents overview](./website/docs/agents/overview.md). Entry map for this repo: [`AGENTS.md`](./AGENTS.md).

### Product ideation

**Business Analyst** — Workshop materials → Jira-ready epics and stories, with human gates before sync.  
**Invoke:** `eversis-analyze-materials`.

### Development

| Role | Focus | Invoke |
| ---- | ----- | ------ |
| **Context Engineer** | Research doc (`*.research.md`) — approve before planning | via `eversis-implement` |
| **Architect** | Implementation plan (`*.plan.md`) — approve before broad code | via `eversis-implement` |
| **Engineering Manager** | Orchestrates Implement end to end; Fine + QA draft | `eversis-implement` |
| **Software Engineer** | Implements the agreed plan | delegated from Implement |
| **DevOps Engineer** | Infra, CI/CD, observability | delegated `eversis-implement-*` |
| **Prompt Engineer** | LLM application prompts (runtime), not Cursor packaging | delegated |
| **E2E Engineer** | Playwright journeys | delegated `eversis-implement-e2e` |

### Quality

| Role | Focus | Invoke |
| ---- | ----- | ------ |
| **Code Reviewer** | PASS / BLOCKER / SUGGESTION | `eversis-review` |
| **UI Reviewer** | Figma EXPECTED vs browser ACTUAL (read-only) | `eversis-review-ui` |

### Customization

**Create-custom** prompts (`eversis-create-custom-*`) extend rules, skills, prompts, and project instructions.

---

## MCP setup

MCP unlocks Jira, Figma, library docs, browser automation, and procedural skills. Seed config: [`templates/mcp.json`](./templates/mcp.json). Playbook: [MCP setup](./website/docs/getting-started/mcp-setup.md).

### Option 1 — User profile (recommended)

Best when you want the same tools **across projects**.

1. Command Palette → **MCP: Open User Configuration**.
2. Merge the `mcpServers` object from [`templates/mcp.json`](./templates/mcp.json) into your user config.
3. Ensure `AGENT_COLLECTIONS_HOME` points at your Agent Collections checkout.

### Option 2 — Workspace configuration

Use when tools should apply **only to one project** (copy or generate workspace MCP config via the installer).

### Build local server: `eversis-collections`

```bash
cd mcp/eversis-collections-mcp
npm install && npm run build
# or from repo root:
npm run mcp:install && npm run mcp:build
```

Enable **`eversis-collections`** in Settings → MCP and restart the agent tool.

- **Skills** — `eversis_skills_list` / `eversis_skills_get` load `.ai/skills/`
- **Word tools** — used by BA docs prompts when that workflow is in scope
- Tool reference: [`mcp/eversis-collections-mcp/README.md`](./mcp/eversis-collections-mcp/README.md)

### What each MCP is used for

| Server | Typical use |
| ------ | ----------- |
| **eversis-collections** | Skills + (optional) Word chapter tools |
| **Atlassian** | Jira / Confluence for implement, review, research |
| **Figma** | Design context for UI implement / UI review |
| **Context7** | Up-to-date library documentation |
| **Playwright** | Browser checks and E2E-style interaction |
| **Sequential Thinking** | Structured reasoning on complex analysis |
| **PDF Reader** | Workshop PDFs for analyze-materials |

Some servers need **API keys or OAuth** — follow each provider’s docs. After restart, confirm tools appear (e.g. `eversis_skills_list`). Disable servers you do not use.

---

## Versioning

| Rule | Detail |
|------|--------|
| Scheme | [Semantic Versioning](https://semver.org/) on this repository |
| First placeholder | **`v0.0.1`** |
| Release unit | One git tag covers core (`.ai/`), adapters, installer, and MCP **together** — not a separate npm package for `.ai/` in MVP |
| Pinning | Consumers pin via **git tag**, **submodule ref**, or installer `--collections-home` |
| Changelog | Root [`CHANGELOG.md`](./CHANGELOG.md) — Keep a Changelog + SemVer |

Breaking releases **must** include a **Migration** subsection in `CHANGELOG.md` with concrete consumer steps.

## Upgrade contract

When moving from framework version **N** to **N+1**:

| Mode | When to use | What to do |
|------|-------------|------------|
| **Local sync** | Shared checkout of this repo | Pull/check out target tag; refresh consumer via installer `--upgrade --sync` or re-link |
| **Submodule bump** | Framework vendored as submodule | Update submodule to tag, then `setup-agent-collections.sh --upgrade --sync` |
| **CLI upgrade** | Installer present | `--upgrade` reuses `.agent-collections/install-selection.json` |

### Project-owned files (never overwrite without opt-in)

| Path / class | Why |
|--------------|-----|
| `eversis-project-stack` (project rule) | Consumer-owned stack and skills policy |
| `docs/context/` | Project context and task baselines |
| `docs/plans/` | Optional flat plans |
| `docs/specs/` | Project research / plan artifacts |
| Local `AGENTS.md` (once created) | Project-specific agent instructions |
| `.env*`, secrets, credentials | Security |
| Local ignore / MCP fragments outside documented merge | Consumer environment choices |
| `.agent-collections/install-selection.json` | Install record (upgrade reads; does not wipe) |

---

## Delivery standard (spec-driven development)

```text
Ideate → Research → Plan → Implement → Review → Fine
```

| Artifact | Path |
|----------|------|
| Spec folder | `docs/specs/<issue-kebab>/` |
| Research | `<issue-kebab>.research.md` (approve before plan) |
| Plan | `<issue-kebab>.plan.md` (approve before implement) |

Primary prompt entry = stable ids (`eversis-implement`, `eversis-review`). Optional (Cursor): `@`-attach when your project surfaces those files. Slash `/eversis-*` commands are **not** MVP.

---

## Layout

```text
.ai/                 # SSOT — rules, skills, prompts
adapters/             # cursor, claude, opencode + sync.mjs + profiles/
mcp/                  # eversis-collections-mcp (skills from .ai/skills)
scripts/              # setup-agent-collections.sh
templates/            # AGENTS, stack, mcp.json seeds
documentation/        # Framework reference (agent-collection.md)
website/              # Docusaurus docs site (local build; hosting deferred)
AGENTS.md             # Reference agent entry map
docs/architecture/    # Mapping, isolation, AGENTS standard, selection, WF/WNF
```

---

## Maintainers

1. Clone this repository; read [`.ai/README.md`](./.ai/README.md) and [`AGENTS.md`](./AGENTS.md).
2. Run `npm run sync:adapters` after changing `.ai/rules` or `adapters/*/rule-map.yaml`.
3. Run `npm run mcp:test` after MCP changes.
4. Run `bash scripts/setup-agent-collections.test.sh` after installer changes.
5. Run `npm run website:build` (or `cd website && npm run build`) after docs site changes.

---

## Related documentation

| Resource | Purpose |
| -------- | ------- |
| [Start here](./website/docs/getting-started/start-here.md) | First successful install checklist |
| [Prerequisites](./website/docs/getting-started/prerequisites.md) | Tooling requirements |
| [Installation](./website/docs/getting-started/installation.md) | Consumer install (incl. Windows) |
| [MCP setup](./website/docs/getting-started/mcp-setup.md) | Workspace vs user MCP |
| [Quick wins](./website/docs/getting-started/quick-wins.md) | Short practical scenarios |
| [Migration from Cursor Collections](./website/docs/getting-started/migration-from-cursor-collections.md) | Cut over from `CURSOR_COLLECTIONS_HOME` |
| [Workflow overview](./website/docs/workflow/overview.md) | Lifecycle variants |
| [`AGENTS.md`](./AGENTS.md) | Agent entry map for this repository |
| [Framework reference](./documentation/agent-collection.md) | Authoritative short guide |
| [Requirements traceability](./docs/architecture/requirements-traceability.md) | WF / WNF → docs / stories |
| [MCP package README](./mcp/eversis-collections-mcp/README.md) | Skills + Word tools reference |
| [`CHANGELOG.md`](./CHANGELOG.md) | Notable changes |

**Docs site:** source under `website/`. Build locally with `cd website && npm install && npm run build`. **Public hosting is deferred** — there is no production docs URL in this MVP.

---

© 2026 [Eversis](https://eversis.com)
