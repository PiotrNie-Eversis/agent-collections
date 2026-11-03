# Agent Collections

Shipping with AI agents usually means picking between speed and control — let them run loose and quality drifts, or review every step and lose the speed. Agent Collections is a structured workflow that keeps both: agents move fast inside a repeatable process, and you approve the results at the points that matter.

Under the hood, it's a **vendor-neutral** multi-agent product engineering framework — rules, prompts, skills, adapters, and MCP — so teams can move work from idea to reviewed delivery with clear human checkpoints.

**Ideate → Research → Plan → Implement → Review → Fine** — one Delivery Standard, end to end.

Maintained by [Eversis](https://eversis.com).

**Status:** Self-contained distribution MVP (`v0.0.1`). A fresh clone works without a sibling [Cursor Collections](https://github.com/PiotrNie-Eversis/cursor-collections) checkout. That product remains a **separate** Cursor channel — it does **not** share SemVer or a docs portal with Agent Collections.

---

## Who this is for

- **Business analysts / product** — turn workshop materials into structured backlog items with review before anything is pushed to Jira.
- **Engineers / tech leads** — research, plan, and implement in small steps with acceptance checks and a structured code review.
- **Anyone new to the project** — this README is the map; deeper playbooks live under `website/docs/` (also published at [agent-collections.vercel.app](https://agent-collections.vercel.app)).

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
- **Skills** — orchestration, architecture, technical context, domain implementation (per project stack policy), domain-knowledge promotion/import/audit (`eversis-promote-domain-knowledge`, `eversis-import-confluence-knowledge`, `eversis-audit-domain-knowledge`).

### Quality — Review & testing

- **Rules** — Code Reviewer (PASS / BLOCKER / SUGGESTION).
- **Prompts** — `eversis-review`, `eversis-review-ui`, `eversis-review-codebase`.
- **Skills** — code review, UI verification, E2E testing.

### Framework customization

- **Prompts** — `eversis-create-custom-*` under `.ai/prompts/public/`.
- **Skills** — creating rules, skills, prompts, and project instructions.

### Infrastructure

- **Adapters** — Cursor, Claude Code, Pi (opt-in), and OpenCode (placeholder) under `adapters/`.
- **MCP** — local **`eversis-collections`** skills server plus optional Atlassian, Figma, Context7, Playwright, and related integrations.
- **Installer** — `scripts/setup-agent-collections.sh` (local / submodule / copy).

> **Why the `eversis-` prefix?** Artifact ids use `eversis-` (e.g. `eversis-implement`) so they do not collide with your project-specific rules, skills, and prompts.

---

## Prerequisites

- **Agent tool:** [Cursor](https://cursor.com/), Claude Code and/or the [Pi coding agent](https://pi.dev/) (`npm i -g @earendil-works/pi-coding-agent`) (OpenCode packaging is placeholder only).
- **Docker Engine + Compose v2** — to **run** the local **`eversis-collections`** MCP server.
- **Node.js** ≥ 18 — needed only to **develop** the **`eversis-collections`** MCP package itself, not to run it.
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
- Declares **Fine** when agent work is done and drafts a **QA comment** for your review before anyone posts it to a ticket tracker — plus, when the task surfaced durable domain knowledge (a convention, a confirmed business rule), a second, independent draft proposing to save it under `docs/context/`.

| Step | Load / attach | What happens |
| ---- | ------------- | ------------ |
| Implement | `eversis-implement` (optional `@eversis-implement` in Cursor) | Engineering Manager orchestrates research → plan → implementation; Fine + QA draft |
| Review | `eversis-review` | Structured code review — PASS / BLOCKER / SUGGESTION |

### Phase 3: Review — Quality & testing

- Structured review against acceptance criteria, security, and reliability.
- Optional UI vs Figma checks (`eversis-review-ui`) and Playwright E2E when the plan includes them.
- Codebase-wide analysis via `eversis-review-codebase` when you need a health pass.

More variants (workshop-only, UI + Figma, E2E, BA Word docs): [workflow overview](./website/docs/main-flow/workflow/overview.md).

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

3. Build the MCP Docker image (skills discoverability):

```bash
docker compose build eversis-collections
```

4. Refresh adapter surfaces (after changing `.ai/` rules or adapter maps):

```bash
npm run sync:adapters
# drift check:
npm run sync:adapters:check
```

5. Enable MCP server **`eversis-collections`** (see [`templates/mcp.json`](./templates/mcp.json)) — or read `.ai/skills/*/SKILL.md` / load prompts by stable id under `.ai/prompts/`.

6. Try a short task: load **`eversis-implement`** with a ticket id or a sentence describing the work.

**Skills UX:** Prefer MCP **`eversis-collections`** + load-by-id under `.ai/skills/` / `.ai/prompts/`. Both adapters also mirror skill packages under `.cursor/skills/eversis-*` and `.claude/skills/eversis-*` (and `.pi/skills/eversis-*` when Pi is selected) (framework sync / installer) for direct file read or `@` attach — do **not** register `.cursor/skills` as Cursor **Agent Skills** UI. The Cursor adapter generates thin `/eversis-*` slash shims under `.cursor/commands/` from `.ai/prompts` (stable id remains SSOT).

First successful install checklist: [Start here](./website/docs/getting-started/start-here.md).

---

## Install into a consumer project

```bash
# Prefer export first, or pass --collections-home (avoids `/scripts/...` when env is unset)
export AGENT_COLLECTIONS_HOME=/path/to/agent-collections
bash "$AGENT_COLLECTIONS_HOME/scripts/setup-agent-collections.sh" \
  --non-interactive \
  --agents=cursor \
  --mcp-servers=eversis-collections \
  --profile=fullstack
# Optional: --build-mcp to force MCP package rebuild (also builds when dist is missing)
# Guided path (Cursor+Claude, OS tabs, verify): website/docs/getting-started/installation.mdx
```

### Vendor modes

| Mode | Flag | Notes |
|------|------|-------|
| **Local** | (default) | Framework stays outside the consumer repo; set `AGENT_COLLECTIONS_HOME` |
| **Submodule** | `--vendor submodule` | **TASK / team default** — teammates: `git submodule update --init --recursive` |
| **Copy** | `--vendor copy` | Vendors tree under `vendor/agent-collections/` |

Useful flags: `--collections-home`, `--link-mode auto|symlink|copy`, `--sync`, `--upgrade`, `--agents`, `--mcp-servers`, `--profile frontend|backend|fullstack`, `--build-mcp` (force MCP rebuild), `--ssot-source URL` / `--ssot-branch NAME` (seed `docs/context/global/` from a shared domain-context repo, best-effort — never blocks install), `--confluence-space-key KEY` (optional — records the key; a person runs `eversis-import-confluence-knowledge` later).

Interactive wizard (TTY) prompts for agents × domain profile × MCP servers — **no `--build-mcp` required** for the MCP checklist. Re-runs are idempotent; partial failures list completed vs failed steps with recovery hints.

Selection is recorded at `.agent-collections/install-selection.json` (schema: [`docs/architecture/install-selection.md`](./docs/architecture/install-selection.md)) — required for `--upgrade`.

**Stack customisation:** Cursor → `.cursor/rules/eversis-project-stack.mdc`; Claude Code → `AGENTS.md` (do not hand-edit generated `CLAUDE.md`); Pi → the same `eversis-project-stack.mdc`, appended to `.pi/APPEND_SYSTEM.md` once it differs from the template.
Full install guide (including Windows): [Installation](./website/docs/getting-started/installation.mdx).

Migrating from Cursor Collections (`setup-cursor-local.sh` / `CURSOR_COLLECTIONS_HOME`): [Migration guide](./website/docs/advanced/migration-from-cursor-collections.md).

### Pi coding agent (opt-in)

Add `pi` to `--agents` (for example `--agents=cursor,claude,pi`, or `--agents=pi` alone; interactive menu `6) Pi only` / `7) Cursor + Claude + Pi`). The installer then writes, from `.ai/`:

- `.pi/APPEND_SYSTEM.md` — always-on rules (agent core, testing and terminal, accessibility).
- `.pi/prompts/eversis-*.md` — `/eversis-*` slash commands.
- `.pi/skills/eversis-*/` — framework skills mirror, plus `eversis-rule-*` role-rule skills.
- `.pi/extensions/eversis-context-budget.ts` — compacts the session once when context use crosses 50% (`EVERSIS_CONTEXT_BUDGET_PERCENT`, 1–95) and resumes an interrupted task. Pi-only: Cursor and Claude Code keep "window fill is not a trigger".
- `.pi/settings.json` (seeded once) and `.pi/mcp.json` (`eversis-collections`; check with `pi mcp list`).

Start `pi` in the project root and grant **project trust** (Pi loads `.pi/` only for trusted projects); run `/reload` after a re-sync. Keep a root `AGENTS.md` so Pi does not also load `CLAUDE.md`. Pi runs as an isolated install stage: a Pi failure keeps the other agents' output, leaves `pi` out of the recorded selection and exits 1 (`agent-collections setup completed with failures (pi)`). A missing `pi` CLI is only a warning. Pi ignore files, subscription sign-in and an isolated workspace are not part of this release. Details: [`adapters/pi/README.md`](./adapters/pi/README.md).

### Upgrade

```bash
bash scripts/setup-agent-collections.sh --upgrade --sync --non-interactive
```

Reuses agents / MCP / profile / vendor / link / `ssot.externalSsotRepo` (and `ssot.confluenceSpaceKey`) from selection. Omit `--ssot-source` to keep the recorded domain-context URL; pass an empty value (`--ssot-source ""` or `--ssot-source=`) to clear it. Missing or corrupt selection **fails** with wizard instructions (no invented full install). Project-owned paths are not overwritten without opt-in (see below).

Per-field contract (`--upgrade`, and `--sync` whenever the record exists): an explicit `--agents`, `--mcp-servers`, `--profile`, `--vendor` or `--link-mode` **replaces** the recorded value (spaces in lists are ignored); an omitted flag **keeps** it. An explicit empty `--vendor=` (or `--vendor ""`) also counts as an override and switches a recorded `submodule` / `copy` install to `local` mode. Without `--agents`, adapters whose framework-generated files are already on disk (marker-bearing `CLAUDE.md` / `.claude/commands/eversis-*.md`, `.cursor/commands/eversis-*.md` / `.cursor/rules/eversis-*.mdc`, `.pi/APPEND_SYSTEM.md`) are kept even if the record lacks them; a hand-written `CLAUDE.md` does not enable Claude.

Without `--mcp-servers` the run is in **preserve mode**: every server already in `.cursor/mcp.json` and `.mcp.json` (and `.pi/mcp.json` for Pi) stays in its own file with its config unchanged (only `eversis-collections` is regenerated, because its command depends on host, vendor mode and framework path); recorded servers missing from a file are added from the template; nothing is removed, and Claude keeps catalog servers found in `.mcp.json` enabled. Preserved-only servers are **not** written back to the record. To re-template servers or deselect them, pass the full list explicitly with `--mcp-servers`. This also applies to entries written by older installers in Cursor-only syntax (`${env:X}`, `${workspaceFolder}`) in `.mcp.json`: preserve mode keeps them as they are, and only an explicit `--mcp-servers` run rewrites them into Claude Code syntax.

---

## Public prompts at a glance

Prompt bodies live under **`.ai/prompts/public/`**. Full catalog: [prompts overview](./website/docs/reference/prompts/overview.md).

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

Roles are expressed as **rules**, **prompts**, and **skills**, organized by lifecycle phase. Full roster: [agents overview](./website/docs/reference/agents/overview.md). Entry map for this repo: [`AGENTS.md`](./AGENTS.md).

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

MCP (Model Context Protocol) unlocks Jira, Figma, library docs, browser automation, and procedural skills. Seed config: [`templates/mcp.json`](./templates/mcp.json). Playbook: [MCP setup](./website/docs/getting-started/mcp-setup.mdx).

### Default — workspace configuration (installer)

The installer writes catalog servers into the **project** file (`.cursor/mcp.json` for Cursor, `.mcp.json` for Claude Code, `.pi/mcp.json` for Pi). Cursor Settings → MCP labels that copy with the **project folder name**.

Do **not** also merge those same catalog ids into Cursor **User** config (`~/.cursor/mcp.json`, badge **User**). Cursor loads both files; Settings shows **User vs** the project folder name for each duplicate, and two processes start (`eversis-collections` would then point at the wrong tree).

If the installer warns that User MCP already has catalog ids, remove those ids from the User file. The installer never edits `~/.cursor/mcp.json`.

### Personal tools — User profile

Keep User MCP for tools that are yours across every repo (not the Agent Collections catalog). Command Palette → **MCP: Open User Configuration**.

### Build local server: `eversis-collections`

```bash
docker compose build eversis-collections
```

Enable **`eversis-collections`** in Settings → MCP and restart the agent tool.

- **Skills** — `eversis_skills_list` / `eversis_skills_get` load `.ai/skills/`
- **Domain context** — `eversis_context_get` / `eversis_context_list` / `eversis_context_sync` read/refresh consumer-project domain knowledge under `docs/context/` (project-level and shared `domain-context`, when configured with `--ssot-source`); requires the consumer project mounted as `/workspace` via `CONSUMER_PROJECT_ROOT`, not just `AGENT_COLLECTIONS_HOME`. Cursor: the installer writes `${workspaceFolder}` into MCP `env`. Vendored Claude Code: committed `scripts/run-eversis-collections-mcp.sh` sets `CONSUMER_PROJECT_ROOT` from the script location (parent of `scripts/`). Absolute (non-vendored) Claude Code still uses MCP `env` `${CLAUDE_PROJECT_DIR:-.}`. Pi: a `bash -c` locator walks up from `$PWD` to the directory containing `.pi/` and sets `CONSUMER_PROJECT_ROOT` there (vendored: via the same wrapper script). Compose falls back to `${PWD}` only when that root is unset
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
| Changelog | Root [`CHANGELOG.md`](./CHANGELOG.md) — Keep a Changelog + SemVer; docs site `/changelog` is **generated** from this file (`node scripts/sync-changelog.mjs`) |

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
| `docs/context/` | Project context, task baselines, and domain knowledge — `docs/context/<project>/<component>/` (project-owned) plus `docs/context/global/` (subtree-pulled from a shared `domain-context` repo, when configured) |
| `docs/plans/` | Optional flat plans |
| `docs/specs/` | Project research / plan artifacts |
| Local `AGENTS.md` (once created) | Project-specific agent instructions |
| `.env*`, secrets, credentials | Security |
| Local ignore / MCP fragments outside documented merge | Consumer environment choices |
| `.agent-collections/install-selection.json` | Install record (upgrade reads; does not wipe) |

### Deselection and recovery

Re-run the installer with a **smaller** `--agents` or `--mcp-servers` list (or change selections in the interactive wizard). Deselection needs the **explicit** flag — `--upgrade` / `--sync` without it keeps what is already installed (see [Upgrade](#upgrade)):

| What changed | Behavior |
|--------------|----------|
| **MCP servers** | With an explicit `--mcp-servers`, framework-managed (catalog) entries not in the list are **removed** from `.cursor/mcp.json` and `.mcp.json`, and listed ones are re-templated (consumer-added servers outside the catalog are kept). Without `--mcp-servers` on upgrade / sync, existing entries in both files are kept unchanged. |
| **Slash commands** | `npm run sync:adapters` / installer adapter sync **removes orphan** generated `eversis-*.md` under `.cursor/commands/`. |
| **Claude omitted** | Framework-generated **`CLAUDE.md`** and triad **`.claudeignore`** are removed when Claude is not in `--agents` (project-edited files are left in place). On upgrade / sync without `--agents`, Claude stays selected while generated Claude files exist. |
| **Pi omitted** | When Pi is explicitly omitted from `--agents`, framework-generated `.pi/APPEND_SYSTEM.md`, `.pi/prompts/eversis-*.md`, `.pi/skills/eversis-*` (framework skills and `eversis-rule-*` role skills) and `.pi/extensions/eversis-context-budget.ts` are removed; `.pi/settings.json`, `.pi/mcp.json` and hand-written files stay. On upgrade / sync without `--agents`, Pi stays selected while the generated `.pi/APPEND_SYSTEM.md` exists. |
| **Hand-written `CLAUDE.md`** | When Claude is enabled and a root `CLAUDE.md` lacks the generator marker, it is copied to **`CLAUDE.md.pre-agent-collections.bak`** (or a timestamped `.bak` if a different backup already exists) before regeneration, with a warning. Move project-specific instructions into `.claude/CLAUDE.md`; do not commit the `.bak`. |
| **Cursor rules** | Regenerated for the remaining agents; **`eversis-project-stack.mdc`** is never overwritten without opt-in. When Cursor is explicitly omitted from `--agents`, framework-generated `.cursor/rules/eversis-*.mdc` and `.cursor/commands/eversis-*.md` (generator marker) are removed; `eversis-project-stack.mdc` and hand-written files stay. |

If install fails partway, fix the reported step and re-run with the same flags (idempotent).

---

## Delivery standard (spec-driven development)

```text
Ideate → Research → Plan → Implement → Review → Fine
```

| Artifact | Path |
|----------|------|
| Spec folder | `docs/specs/<key>-<topic>/` |
| Research | `<key>-<topic>.research.md` (approve before plan) |
| Plan | `<key>-<topic>.plan.md` (approve before implement) |

Primary prompt entry = stable ids (`eversis-implement`, `eversis-review`). Optional (Cursor): `@`-attach when your project surfaces those files, or `/eversis-*` when `.cursor/commands/` has been generated by the Cursor adapter.

---

## Layout

```text
.ai/                 # SSOT — rules, skills, prompts
adapters/             # cursor, claude, pi, opencode + sync.mjs + profiles/
mcp/                  # eversis-collections-mcp (skills from .ai/skills)
scripts/              # setup-agent-collections.sh
templates/            # AGENTS, stack, mcp.json seeds
documentation/        # Framework reference (agent-collection.md)
website/              # Docusaurus docs site (Vercel: agent-collections.vercel.app)
AGENTS.md             # Reference agent entry map
docs/architecture/    # Mapping, isolation, AGENTS standard, selection, WF/WNF
```

---

## Maintainers

1. Clone this repository; read [`.ai/README.md`](./.ai/README.md) and [`AGENTS.md`](./AGENTS.md).
2. Run `npm run sync:adapters` after changing `.ai/rules` or `adapters/*/rule-map.yaml`.
3. Run `npm run mcp:test` after MCP changes.
4. Run `docker compose build eversis-collections` after MCP changes — verifies the Docker image the generated MCP entry actually runs still builds (`npm run mcp:test` alone only exercises the Node dev-loop).
5. Run `bash scripts/setup-agent-collections.test.sh` after installer changes.
6. Run `npm run website:build` (or `cd website && npm run build`) after docs site changes.

---

## Related documentation

Grouped the same way the docs site itself is now organized — by what you're trying to do, not by artifact type.

### Getting Started

| Resource | Purpose |
| -------- | ------- |
| [Start here](./website/docs/getting-started/start-here.md) | First successful install checklist |
| [Prerequisites](./website/docs/getting-started/prerequisites.md) | Tooling requirements |
| [Installation](./website/docs/getting-started/installation.mdx) | Consumer install (incl. Windows) |
| [MCP setup](./website/docs/getting-started/mcp-setup.mdx) | Workspace vs user MCP |
| [Quick wins](./website/docs/getting-started/quick-wins.md) | Short practical scenarios |

### The Main Flow

| Resource | Purpose |
| -------- | ------- |
| [Workflow overview](./website/docs/main-flow/workflow/overview.md) | Lifecycle variants |

### Reference

| Resource | Purpose |
| -------- | ------- |
| [Reference index](./website/docs/reference/index.md) | Agents, Skills, Prompts, Integrations, Domain Context, and Glossary — one browsable index |

### Advanced / CTO

| Resource | Purpose |
| -------- | ------- |
| [Migration from Cursor Collections](./website/docs/advanced/migration-from-cursor-collections.md) | Cut over from `CURSOR_COLLECTIONS_HOME` |

### In this repository

| Resource | Purpose |
| -------- | ------- |
| [`AGENTS.md`](./AGENTS.md) | Agent entry map for this repository |
| [Framework reference](./documentation/agent-collection.md) | Authoritative short guide |
| [Requirements traceability](./docs/architecture/requirements-traceability.md) | WF / WNF → docs / stories |
| [MCP package README](./mcp/eversis-collections-mcp/README.md) | Skills + Word tools reference |
| [`CHANGELOG.md`](./CHANGELOG.md) | Notable changes |

**Docs site:** source under `website/`. Build locally with `npm run website:build` (or `cd website && npm install && npm run build`). Hosted at [agent-collections.vercel.app](https://agent-collections.vercel.app). Vercel **Root Directory** must be `website` (dashboard); root [`vercel.json`](./vercel.json) uses paths relative to that folder (`npm run build` → `build/`). The `/changelog` page is generated from root [`CHANGELOG.md`](./CHANGELOG.md) — edit the root file only, then run `npm run website:changelog:sync` (or rely on `prebuild`). Drift check: `npm run website:changelog:check`.

---

© 2026 [Eversis](https://eversis.com)
