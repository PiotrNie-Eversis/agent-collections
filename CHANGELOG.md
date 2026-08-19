# Changelog

All notable changes to **Agent Collections** (`agent-collections`) are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Policy

- **Release unit:** one SemVer git tag on this repository (core `.ai/`, plus adapters / installer / MCP when present).
- **Breaking changes:** every breaking release **must** include a **Migration** subsection with consumer steps (see [README](./README.md) upgrade contract).
- **Project-owned paths** are never overwritten by upgrade tooling without explicit opt-in (see README).

## [Unreleased]

### Fixed

- **Installer submodule skew (`--framework-prefix`)** — `--upgrade --sync` no longer passes new `adapters/sync.mjs` flags into an older vendor pin (`unknown argument: --framework-prefix`). A clean submodule is aligned to the launching installer SHA; a dirty pin or missing SHA fails with recovery git commands (never `checkout --force`)
- **Vercel docs deploy** — `vercel.json` install/build paths are relative to the dashboard Root Directory `website` (no nested `cd website`); matches prior agent-collections.vercel.app config
- **`docs/specs/` gitignore scope** — `.gitignore` only excluded `docs/specs/task-*/`, so local research/plan folders from non-TASK work (ad-hoc analysis, framework self-improvement) were not ignored and could be committed by mistake. Broadened to `docs/specs/*/` (all subfolders local-only, regardless of ticket prefix); untracked three already-committed leaked folders (`cursor-collection-migration/`, `pilot-feedback-framework-deltas/`, `website-changelog-sync/`) going forward — kept on disk, not purged from history
- **`docs/context/` gitignore scope** — this repo committed `docs/context/agent-collections/` (TASK-515 delivery-index traceability) and `docs/context/eog/` (TASK-542 pilot evidence) as reference material instead of applying its own `--gitignore-agent-artifacts` pattern to itself. Broadened `.gitignore` to `docs/context/*/` (same pattern already applied to `docs/specs/*/`); untracked both folders going forward — kept on disk, not purged from history. Reworded the 2 live references that cited `docs/context/eog/` as a browsable repo path (`isolation-strategy.md`, migration guide)
- **Docs-triad README scaffolding** — the installer only wrote a `README.md` for `docs/specs/`; `docs/context/` and `docs/plans/` were scaffolded as empty directories, contradicting the framework's own documented install contract. `scaffold_project()` now writes all three, and re-running the installer (`--upgrade`/`--sync`) backfills any README missing from a previously-scaffolded project without overwriting an existing (project-owned) one. This repo's own `docs/context/README.md` was added directly (the installer refuses to run against its own source checkout)
- **`eversis-code-reviewing` discovery** — the skill's `description` had no explicit trigger/exclusion clause, so keyword-based skill routing (e.g. a plain "review this" request) could match a host's generic, non-framework code-review tooling instead, skipping the spec/plan-driven Review stage (research/plan check, STRICT FORBIDDEN constraints, project test suite). Reworded the description to name the Implement/Review-session trigger explicitly and add a host-neutral "Do NOT use" clause (ad-hoc diff review / auto-fix / inline PR comments) so it stays accurate across Claude Code, Cursor, and OpenCode instead of hardcoding one host's tool name
- **`eversis-creating-skills` / `eversis-create-custom-*` host-exclusivity claims** — `eversis-creating-skills/SKILL.md`'s `description` and consumption paragraph, and `eversis-create-custom-skill.md`'s body, asserted Cursor+MCP as the *only* way skills are listed/read/consumed — false for Claude Code, which discovers `.ai/skills/eversis-*` natively via symlinked `.claude/skills/` with no MCP involved (same bug class as the `eversis-code-reviewing` fix above). `eversis-create-custom-instructions.md` additionally claimed "this repository is Cursor-only", contradicted by this repo's own `AGENTS.md` and Claude Code adapter. Reworded all four to name the current host's native mechanism or the `eversis-collections` MCP, depending on the adapter, without hardcoding a single host as exclusive. Also dropped the dead pre-rebrand `<!-- Cursor Collections -->` footer comment from all 4 `eversis-create-custom-*` prompts (no functional role, legacy framework name); the `prompt_role: "Cursor customization orchestrator"` frontmatter and its role link were left untouched — verified as a genuinely Cursor-specific workflow pattern, not a host-neutrality bug

### Added

- **Docs changelog sync** — Root `CHANGELOG.md` is the single editable SSOT (SemVer + prior history); `website/src/pages/changelog.md` is generated via `scripts/sync-changelog.mjs` (`prestart`/`prebuild`); `--check` drift gate; `vercel.json` for docs deploy
- **TASK-515 close-out** — Q6 hygiene: retarget `.ai/` deep-links from `cursor-collections` to Agent Collections paths; `docs/context/agent-collections/delivery-index.md` traceability (CQ2 waiver); installer Claude deselect prune for generated `CLAUDE.md` / `.claudeignore`; area profiles drop generic `charts/**` exclude (consumer overlay for true infra); targeted website SSOT wording (`.ai/prompts`, slash commands)
- **Installer UX (TASK-515 umbrella)** — Interactive agents checkbox + domain-profile select (`agents-prompt.mjs`, `profile-prompt.mjs`); shared inquirer deps helper
- **TASK-598** — Cursor adapter emits thin slash commands under `.cursor/commands/eversis-*.md` from `.ai/prompts/{public,internal}/` (HYBRID: SSOT pointer + optional Executable section); deny list `adapters/cursor/command-deny.yaml`; included in `sync:adapters:check`
- **TASK-598 follow-up** — Slash command files put `prompt_description` as the first paragraph for Cursor `/` menu summary; GENERATED marker moved to end of file
- **Wave D — docs + validation (TASK-515 / 541, 539, 540, 542)**
  - Getting-started guides under `website/docs/getting-started/` (CC-analog stems) + migration from Cursor Collections
  - Framework reference `documentation/agent-collection.md` and WF/WNF `docs/architecture/requirements-traceability.md`
  - Docusaurus site under `website/` (rebrand Agent Collections; Vercel at agent-collections.vercel.app; changelog generated from root SSOT)
  - EOG pilot context / WNF-03 measurement notes under `docs/context/eog/`
- **Wave C — self-contained distribution (TASK-515 / 533–538, 530, 532; 521 verify)**
  - Bootstrap without sibling `cursor-collections` symlinks (skills/prompts/commands + BA Docs rule links removed; Q1: no full `.cursor` skills mirror)
  - MCP package `mcp/eversis-collections-mcp/` resolving `.ai/skills` via `AGENT_COLLECTIONS_HOME` (Q2; no `CURSOR_COLLECTIONS_HOME` in default template)
  - Installer `scripts/setup-agent-collections.sh` (local / submodule / copy) with selection `.agent-collections/install-selection.json` (Q3)
  - Domain profiles `adapters/profiles/{frontend,backend,fullstack}.yaml` (Q4) + area profiles `area-*-scope.yaml` / `area-fullstack.yaml` (TASK-530)
  - Wizard axes `--agents` / `--mcp-servers` / `--profile` + `--non-interactive`; upgrade `--upgrade` with fail-safe (TASK-537 / S-01…S-04)
  - Reference `AGENTS.md` filled (TASK-532); install selection schema doc
  - Root scripts: `mcp:build`, `mcp:test`, `installer:smoke`

### Changed

- **TASK-515 Continuity** — Implement sessions auto-run `eversis-review` then Fine + QA draft in-session (no wait for human `/eversis-review`); opt-out: `pause before review` / `review later`; SDD gate table + agent-core / orchestration skill / Channel notes aligned
- **Installer Next steps** — agent-aware (Cursor stack `.mdc` vs Claude `AGENTS.md`); vendor submodule/copy marked done + teammate `git submodule update --init --recursive`; local mode clarifies no in-repo `.ai/`
- **MCP wizard** — interactive MCP server selection no longer requires `--build-mcp` (`--build-mcp` = force rebuild only; missing `dist` still builds)
- **Installer docs** — `.agent-collections/` purpose, `--collections-home` one-liners, Claude vs Cursor stack customisation (`install-selection.md`, getting-started, Claude adapter README, root README)
- **TASK-598** — Docs updated: adapter-mapping emit matrix, Cursor adapter README, README / AGENTS Channel notes for `/eversis-*`
- **TASK-541** — Root README rewritten for human-first documentation UX (progressive disclosure: hero → workflows with human gates → quick start → install/upgrade facts), aligned with cursor-collections README pattern while keeping Agent Collections facts (`AGENT_COLLECTIONS_HOME`, adapters, MVP limits)
- README links getting-started + migration; documents deferred docs hosting
- README quick start is self-contained; upgrade CLI path implemented via installer
- Adapter sync accepts `--agents cursor,claude,opencode` (OpenCode remains placeholder)

## [0.0.1] — 2026-08-05

Placeholder pre-distribution version. Self-contained bootstrap and installer are not included yet. Cursor rules adapter generator is present under `adapters/cursor/`; Claude Code adapter under `adapters/claude/` (root `CLAUDE.md`); OpenCode placeholder under `adapters/opencode/`; umbrella sync CLI at `adapters/sync.mjs`.

### Added

- **Core SSOT (`.ai/`)** — Wave A foundation:
  - Inventory and directory structure for Agent Collections core
  - Orchestration rules under `.ai/rules/orchestration/`
  - Domain rules under `.ai/rules/{frontend,backend,devops,architecture,shared-types}/`
  - Skill packages (45) under `.ai/skills/` and prompts (16 public + 12 internal) under `.ai/prompts/`
- **Versioning and upgrade contract** — documented in root `README.md` (local sync, submodule bump, CLI upgrade forward-ref; project-owned opt-in rules)
- **Local-only story specs** — `docs/specs/task-*/` gitignored for MVP (research/plan stay on disk, not published with the framework tree)
- **Mandatory spec-driven development (Delivery Standard)** — `.ai/rules/orchestration/spec-driven-development.md` (+ pointer from `agent-core`); documented in README / AGENTS / `docs/specs/README.md`; Jira story template block in `eversis-jira-task-formatting` (stable prompt ids + optional Cursor attach note)
- **Adapter mapping specification** — canonical architecture/mapping doc at `docs/architecture/adapter-mapping.md` (Cursor / Claude / OpenCode field maps, emit matrix, `rule-map` contract); pointer from `.ai/README.md` (TASK-523)
- **Isolation strategy (TASK-528)** — canonical cross-tool ignore and area-scoping strategy at `docs/architecture/isolation-strategy.md` (packaging matrix, area profiles, WNF-03 estimation + orientation-without-noise); pointer from `adapter-mapping.md` / `.ai/README.md`; path globs remain TASK-530
- **Synchronized ignore triad (TASK-529)** — root `.cursorignore`, `.claudeignore`, and `.opencodeignore` with shared secrets/build + cross-tool packaging classes (§4); checklist in `isolation-strategy.md` §8.1; no heavy-infra/`apps/**` in framework root; `adapters/sync.mjs` unchanged; future installer merges missing classes without wipe (opt-in)
- **Cursor adapter (TASK-524)** — `adapters/cursor/` with `rule-map.yaml` and zero-deps `generate.mjs` (`node adapters/cursor/generate.mjs`, optional `--out`); generates framework `.cursor/rules/*.mdc` from `.ai/rules` (replaces symlink bootstrap for mapped rules; BA Docs symlinks and consumer `eversis-project-stack.mdc` left untouched)
- **OpenCode adapter placeholder (TASK-525)** — `adapters/opencode/` + root `opencode.jsonc` (`$schema` + `instructions` globs → `.ai/rules`); maturity `placeholder` only (not a shipped adapter); minimal Cursor exclusion in `.cursorignore` (full ignore triad → TASK-529)
- **Claude Code adapter (TASK-526)** — `adapters/claude/` with `rule-map.yaml` and zero-deps `generate.mjs` (`node adapters/claude/generate.mjs`, optional `--out`); generates root `CLAUDE.md` (H2 per mapped rule, full inline; id/source parity with Cursor map); ignore / monorepo isolation deferred to TASK-528–530
- **Adapter sync CLI (TASK-527)** — `adapters/sync.mjs` (+ `package.json` scripts `sync:adapters` / `sync:adapters:check`) regenerates Cursor then Claude deterministically; `--check` validates no drift and Cursor↔Claude id/source map parity; does not touch project-owned stack / BA Doc symlinks; OpenCode out of sync MVP

### Migration

No consumer migration required for `0.0.1` (first placeholder). When upgrading from a future `0.0.x` / `0.1.x` with breaking changes, follow the **Migration** notes in that release and the [README](./README.md) upgrade modes.

## Prior history (cursor-collections lineage)

Entries below predate Agent Collections SemVer releases (`0.0.1` and later). They preserve the dated Keep a Changelog narrative from the cursor-collections → Agent Collections migration era for continuity. They are **not** SemVer tags of this repository.

## 2026-07-29

### Fixed

- **Framework `.gitignore`** — removed consumer-local ignore block so framework `.cursor/` product paths and `mcp.json` stage normally; consumer setup still writes that block for app repos.
- **SDLC diagram** — light connector opacity `0.5` for visible phase continuity.
- **GCP Gcloud docs** — troubleshooting for `gcloud executable not found` (install SDK / PATH).

### Changed

- **Implement readiness review suggestions** — Standard Flow first-content + Research DELTA; English **needs verification** QA signal; Plan REFRESH in mirror; agent-core Plan adequacy; `AGENTS.md` pointer. See [Orchestrating Implementation](/docs/skills/orchestrating-implementation).
- **Implement readiness P0 hardening** — exact four-line readiness block as first content; adequacy checklist before Research SKIP; updated QA/bugfix and analyze entry signals; same-session research file for CREATE/DELTA. See [Orchestrating Implementation](/docs/skills/orchestrating-implementation).
- **Workflow Overview** — Implement Role/Prompt bullets aligned with Ideate and Review; Quick/Full table kept.

## 2026-07-28

### Changed

- **Implement readiness:** `@eversis-implement` / `/eversis-implement` — mandatory first-response readiness block; entry signals skip Ideate when plan + research exist. See [Orchestrating Implementation](/docs/skills/orchestrating-implementation).

## 2026-06-19

### Added

- **Implementing filters (Phase I):** `eversis-implementing-filters` — Next.js URL-sync for filterable lists; Nest flat Zod variant; gated by Agent skills policy. Docs: [implementing-filters](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/website/docs/skills/implementing-filters.md).
- **Agent skills policy (OSS governance):** stack template, agent-core, orchestration, and docs — mitigates wrong skill activation across consumer projects.

### Changed

- **Agent artifacts local-only (framework repo)** — `docs/specs/*/`, `docs/context/*/`, and `docs/plans/*` (except README) gitignored; normative BA Docs spec on [business-docs-workflow](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/website/docs/specs/business-docs-workflow.md).
- **Breaking:** Skill rename **`eversis-qa-comment`** → **`eversis-fine-handoff`** — same Fine-turn QA comment draft contract; new docs page [Fine Handoff](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/website/docs/skills/fine-handoff.md). See [CHANGELOG.md](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/CHANGELOG.md) for consumer migration steps.

## 2026-05-13

### Removed

- **Legacy standalone docs MCP packages** — Deleted `mcp/eversis-docs-mcp/` (Python) and `mcp/eversis-docs-mcp-node/` (Node). Business Manager Docs `.docx` tools ship only via [`mcp/eversis-collections-mcp/`](https://github.com/PiotrNie-Eversis/agent-collections/tree/main/mcp/eversis-collections-mcp) and **`eversis-collections`** in **`.cursor/mcp.json`**.

### Added

- **`.cursor/commands/`** — New directory with four thin Cursor `/` project command files (`eversis-implement.md`, `eversis-review.md`, `eversis-analyze-materials.md`, `eversis-review-ui.md`). Each delegates to the canonical `.cursor/prompts/public/*.md` without duplicating workflow bodies. Type `/` in Cursor Chat or Agent to invoke from the dropdown.
- **Business Manager Docs (Word)** — Public prompts **`eversis-ba-docs-planner`** / **`eversis-ba-docs-writer`** ([**`eversis-ba-docs-planner.md`**](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/.cursor/prompts/public/eversis-ba-docs-planner.md), [**`eversis-ba-docs-writer.md`**](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/.cursor/prompts/public/eversis-ba-docs-writer.md)) with attach-on-demand rules [**`eversis-ba-docs-planner.mdc`**](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/.cursor/rules/eversis-ba-docs-planner.mdc) / [**`eversis-ba-docs-writer.mdc`**](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/.cursor/rules/eversis-ba-docs-writer.mdc). Uses the same **`eversis-collections`** MCP `.docx` tools (no separate docs server in Cursor config).
- **`eversis-collections` MCP — `.docx` chapter tools** — `generate_summary_map`, `read_chapter`, `update_chapter`, `upload_to_sharepoint` (stub); implementation under [`mcp/eversis-collections-mcp/src/docx/`](https://github.com/PiotrNie-Eversis/agent-collections/tree/main/mcp/eversis-collections-mcp/src/docx); tests in [`chapters.test.ts`](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/mcp/eversis-collections-mcp/tests/chapters.test.ts).
- **Business Docs normative spec** — [`website/docs/specs/business-docs-workflow.md`](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/website/docs/specs/business-docs-workflow.md) (BA Word workflow requirements; migrated from local `docs/specs/` in 2026-06-19).
- [**`website/docs/workflow/business-manager-docs.md`**](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/website/docs/workflow/business-manager-docs.md) — docs site workflow page.

### Changed

- [**`eversis-implement.md`**](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/.cursor/prompts/public/eversis-implement.md), [**`eversis-review.md`**](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/.cursor/prompts/public/eversis-review.md), [**`eversis-analyze-materials.md`**](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/.cursor/prompts/public/eversis-analyze-materials.md), [**`eversis-review-ui.md`**](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/.cursor/prompts/public/eversis-review-ui.md) — Usage section updated to document both `@` attachment and the new `/eversis-*` project command as equivalent invocations.
- [**`documentation/agent-collection.md`**](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/documentation/agent-collection.md) — "How to run a prompt" section: added step 3 for `/` project commands; slash naming clarification distinguishing Docusaurus URL slugs from vendor-neutral multi-agent `.cursor/commands/`.
- **`website/docs/intro.md`** — Intro updated: `@` attachment and `/eversis-*` project commands are the two valid Cursor invocations.
- **`website/docs/prompts/overview.md`** — "How to invoke" block with comparison table of `/` commands and `@` equivalents.
- **`website/src/components/SdlcDiagram/index.tsx`** — `aria-label` updated for `@` or `/eversis-*` project commands.
- [**`eversis-creating-prompts/SKILL.md`**](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/.cursor/skills/eversis-creating-prompts/SKILL.md) — Step 7 extended with guidance on thin `.cursor/commands/` siblings; Step 8 checklist item added.
- [**`documentation/agent-collection.md`**](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/documentation/agent-collection.md) — Clarified SSOT policy for agents vs. human-facing `website/docs/`; Business Manager Docs / Word tooling cross-links.
- **`README.md`** — Phase table (`@` / `/`, **Business Manager Docs** row), quick start (**MCP** step documents `.docx` tools), prompts table (**`eversis-ba-docs-*`**), **MCP servers** / **Summary** for Word tools on **`eversis-collections`**; QA comment references (`SKILL.md` primary; website links optional).
- **`website/docs/skills/overview.md`** — Notice blockquote: skills catalog is human browsing only; agents use MCP or `SKILL.md`.
- **`website/docs/workflow/overview.md`** — "Status: Fine" link points to `eversis-qa-comment` `SKILL.md`.
- **`.cursor/commands/`** — Added `eversis-ba-docs-planner.md` and `eversis-ba-docs-writer.md`; six thin `/` commands total.
- [**`AGENTS.md`**](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/AGENTS.md) — `.docx` chapter tools on **`eversis-collections`** and BA docs prompts (single MCP for skills + Word tooling).
- [**`mcp/eversis-collections-mcp/README.md`**](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/mcp/eversis-collections-mcp/README.md) — Tool table and dependencies for `.docx` chapter tools (`JSZip`, `@xmldom/xmldom`).
- [**`docs/specs/README.md`**](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/docs/specs/README.md) — Index entry for business-docs-workflow spec folder.
- **`website/docs/getting-started/mcp-setup.md`**, **`website/docs/integrations/overview.md`**, **`website/docusaurus.config.ts`**, **`website/package.json`** / **`website/README.md`** — Docs site navigation and MCP copy aligned with unified **`eversis-collections`** Word tools where applicable.

## 2026-05-11

### Changed

- **`eversis-qa-comment`** skill ([`.cursor/skills/eversis-qa-comment/SKILL.md`](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/.cursor/skills/eversis-qa-comment/SKILL.md)) — **mandatory** QA comment draft on **Fine** (no longer optional); two-phase human gate: draft in Fine turn, Atlassian MCP `addCommentToJiraIssue` only after explicit approval; expanded readability rules (Before / After framing, jargon gloss, outcome-first ordering). Breaking: adopting teams should expect a QA draft artifact on every Fine.
- **`qa-comment.example.md`** — added "avoid vs prefer" contrast section using an OAuth callback scenario to illustrate human-readable bullet writing.
- [**`eversis-engineering-manager.mdc`**](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/.cursor/rules/eversis-engineering-manager.mdc) — QA Handoff Policy: Fine always produces the draft in the same turn; Atlassian MCP call requires explicit human approval.
- [**`eversis-agent-core.mdc`**](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/.cursor/rules/eversis-agent-core.mdc) — added step 5 to Orchestration: QA draft is a required Fine output; Jira publication requires human approval.
- [**`eversis-implement.md`**](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/.cursor/prompts/public/eversis-implement.md) — added workflow step 10 (Fine + QA draft) and updated "What It Does" list.
- **Workflow docs** — [Overview](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/website/docs/workflow/overview.md) **Status: Fine** updated; [Standard](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/website/docs/workflow/standard-flow.md), [Frontend](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/website/docs/workflow/frontend-flow.md), and [E2E](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/website/docs/workflow/e2e-flow.md) — optional tip replaced with mandatory QA draft note.
- [**`website/docs/skills/qa-comment.md`**](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/website/docs/skills/qa-comment.md) — rewritten: user story, readability expectations, Atlassian MCP publishing instructions.
- **`website/docs/skills/overview.md`** — `eversis-qa-comment` table row updated to **mandatory draft after Fine**.
- **`README.md`** — QA section updated to mandatory draft after Fine; Atlassian MCP posting described.
- **`CHANGELOG.md`** — this entry also in root changelog.
- [**`documentation/agent-collection.md`**](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/documentation/agent-collection.md) — QA handoff subsection added under Part A Workflow.

## 2026-05-05

### Added

- **`docs/plans/`** directory with [`docs/plans/README.md`](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/docs/plans/README.md) and a local plan file for `.mdc` frontmatter `globs` normalization (plan file no longer committed after 2026-06-19 local-only policy).

### Changed

- [**`.cursor/rules/eversis-accessibility.mdc`**](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/.cursor/rules/eversis-accessibility.mdc) — `globs` field converted from a comma-separated string to a **YAML list** to match the canonical template and be unambiguous across Cursor versions.
- **`documentation/agent-collection.md`** — rules format section now documents the three `.mdc` activation modes: `alwaysApply: true`, `globs: [...]` YAML list, and `globs: []` / `alwaysApply: false` (role rules attached on demand with `@`).
- [**`.cursor/skills/eversis-creating-agents/SKILL.md`**](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/.cursor/skills/eversis-creating-agents/SKILL.md) — frontmatter table extended with the three-mode reference and a note that `globs` must be a YAML list with `**/` prefixed patterns.
- **`README.md`** — step 3 of "Getting started" mentions the three `.mdc` rule modes with a link to the framework doc; "Using this framework in another repository" step 3 mentions `docs/plans/`.
- [**`.cursor/rules/eversis-code-reviewer.mdc`**](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/.cursor/rules/eversis-code-reviewer.mdc) — added `## STRICT FORBIDDEN` section with three hard limits (file scope, documentation comments, new package-manager dependencies); violations classify as **BLOCKER** in the PASS / BLOCKER / SUGGESTION output.
- [**`.cursor/rules/eversis-agent-core.mdc`**](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/.cursor/rules/eversis-agent-core.mdc) — added `## Hard limits (implement)` mirroring the same three prohibitions so they apply during implementation (`alwaysApply: true`), not only at review.
- [**`.cursor/skills/eversis-code-reviewing/SKILL.md`**](https://github.com/PiotrNie-Eversis/agent-collections/tree/main/.cursor/skills/eversis-code-reviewing) — Step 3 extended with mandatory verification of the three `STRICT FORBIDDEN` constraints (scope, documentation comments, dependencies).
- **`README.md`** — Roles and documentation section notes the `STRICT FORBIDDEN` limits and their cross-rule enforcement.
- [**`.cursor/rules/eversis-agent-core.mdc`**](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/.cursor/rules/eversis-agent-core.mdc) — added `## Skills discovery` section: before broad implementation the agent checks `.cursor/skills/` for a domain-matching package; prefers `eversis-collections` MCP tools (`eversis_skills_list` / `eversis_skills_get`) when available, otherwise reads `SKILL.md` directly; reinforces that the folder must not be registered as Cursor Agent Skills.
- [**`README.md`**](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/README.md) — Skills section extended with a Discovery bullet explaining the `eversis-agent-core.mdc` skills-check behavior.

## 2026-05-04

### Added

- Skill **`eversis-qa-comment`** under [`.cursor/skills/eversis-qa-comment/`](https://github.com/PiotrNie-Eversis/agent-collections/tree/main/.cursor/skills/eversis-qa-comment) — manual, English **QA / Jira** comment after orchestration reaches **Fine**; few-shot template **`qa-comment.example.md`**; consumed via **`eversis-collections` MCP** (`eversis_skills_get`). Agents **suggest** use when appropriate and **do not** run the skill automatically.
- Documentation: **[QA Comment](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/website/docs/skills/qa-comment.md)** skill page (usage, rules, example output, link to canonical few-shot in repo).

### Changed

- [ **`eversis-engineering-manager.mdc`**](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/.cursor/rules/eversis-engineering-manager.mdc) — **QA Handoff Policy** (Fine → suggest `eversis-qa-comment`, never auto-invoke).
- **Workflow docs** — [Overview](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/website/docs/workflow/overview.md) (**Status: Fine** + optional QA comment); [Standard](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/website/docs/workflow/standard-flow.md), [Frontend](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/website/docs/workflow/frontend-flow.md), and [E2E](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/website/docs/workflow/e2e-flow.md) flows — aligned tips for optional QA handoff.
- **[Skills overview](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/website/docs/skills/overview.md)** — `eversis-qa-comment` in Quality table and agent–skill matrix; total skills **33**.
- **[README](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/README.md)** — optional QA handoff after Implement / Fine, standard-flow example line, Skills and Summary mentions.

## 2026-04-23

### Changed (breaking for repository layout and permalinks)

- Moved all **`eversis-*` skill packages** from **`.github/skills/`** to **`.cursor/skills/`** so rules, prompts, and skills for Cursor live under **`.cursor/`**. The **`eversis-collections` MCP** finds the repo by walking to **`.cursor/skills`**. If you set **`EVERSIS_COLLECTIONS_ROOT`**, it must point to a checkout that contains **`.cursor/skills`**. **GitHub** URLs that used **`/tree/.../.github/skills/...`** are invalid; use **`/tree/.../.cursor/skills/...`**.

### Changed (breaking for deep links and MCP `skillId` values)

- Renamed all **`.github/skills/eversis-*`** topic directories to **`.github/skills/eversis-*/`**. (Skill packages were under **`.github/skills/`** at the time; they have since been moved to **`.cursor/skills/`** — see above.)

## 2026-04-22

### Removed (breaking)

- **`.github/prompts/`**, **`.github/internal-prompts/`**, and **`.github/agents/`** — the repository is **multi-agent**. Prompts live under **`.cursor/prompts/`** (attach with `@`); copies for this documentation site are generated under `website/docs/prompts/` via **`sync-prompts`**. Role behavior is expressed with **`.cursor/rules/eversis-*.mdc`** and **[AGENTS.md](https://github.com/PiotrNie-Eversis/agent-collections/blob/main/AGENTS.md)**. As of **2026-04-23**, skills live under **`.cursor/skills/eversis-*/`**; consume them in Agent through the **`eversis-collections` MCP** (not a separate **Agent Skills** UI path).

### Changed

- Rebranded documentation and the Docusaurus site to **Agent Collections**; installation and prerequisites describe **Cursor** (no legacy non-Cursor assistants or VS Code `chat.*Locations` for prompts/agents).
- Updated **README**, **documentation/agent-collection.md**, **.cursor/rules** copy, and skills (**creating-\*** and **technical-context-discovering**) for Cursor outputs; replaced legacy instruction templates under **eversis-creating-instructions** with Cursor-oriented templates.
- Renamed **website** package to **`agent-collections-docs`**.

## 2026-04-10

### Changed

- `/eversis-implement` prompt — Fixed chronic UI verification skipping: added mandatory UI task inventory at plan review (step 2), proactive dev server URL collection before implementation (step 3), elevated `[REUSE]` UI verification to a prominent task type with explicit delegation instructions (step 6), added mandatory UI Verification Gate before code review (step 8), and explicit code review delegation step (step 9); references `eversis-implement-ui.prompt.md` for full verification workflow instead of duplicating it
- Engineering Manager agent (`eversis-engineering-manager`) — Added "UI Verification Enforcement" subsection with 4-point checklist (inventory at plan review, early dev server URL collection, process in order, gate code review); strengthened `eversis-ui-reviewer` delegation with mandatory emphasis and "never skip" guardrail
- UI Reviewer agent (`eversis-ui-reviewer`) — Added "Tool-to-URL mapping" rule clarifying that all Figma data (URLs, node IDs, file keys) must go through `figma` tool and Playwright is only for dev server navigation

## 2026-04-01

### Changed

- Renamed Figma MCP server key from `figma-mcp-server` to `figma` across all agents, prompts, skills, MCP configuration, and documentation — aligns with Figma's recommended server naming in their official docs

## 2026-03-30

### Added

- Backend development skill `eversis-implementing-backend`

### Changed

- Updated `eversis-implementing-backend` skill reference in `eversis-software-engineer` agent
- Updated `eversis-implementing-backend` as a conditional skill in `implement` prompt for backend API tasks

## 2026-03-20

### Changed

- `/eversis-implement` prompt — Now auto-detects missing context and missing plan; delegates to `eversis-context-engineer` for research and `eversis-architect` for planning before implementation, with user confirmation between phases
- `/eversis-plan` prompt — Moved from public `.github/prompts/` to internal `.github/internal-prompts/`; no longer invoked directly by users — the Engineering Manager delegates to the Architect automatically when a plan is needed
- `/eversis-research` prompt — Moved from public `.github/prompts/` to internal `.github/internal-prompts/`; no longer invoked directly by users — the Engineering Manager delegates to the Context Engineer automatically when research is needed
- Engineering Manager agent (`eversis-engineering-manager`) — Added `eversis-context-engineer` to subagents; added structured workflow to decide between research, planning, and implementation phases; added delegation rules for `eversis-context-engineer` (missing context) and `eversis-architect` (missing plan); added Sequential Thinking usage for phase routing decisions
- Business Analyst agent (`eversis-business-analyst`) — Replaced "Deep-dive Research per Task" and "Prepare Implementation Plan" handoff buttons with single "Start Implementation" handoff routing to Engineering Manager
- Context Engineer agent (`eversis-context-engineer`) — Replaced "Prepare Implementation Plan" handoff button with "Start Implementation" handoff routing to Engineering Manager
- Updated website documentation: moved `/eversis-plan` and `/eversis-research` prompt pages from public to internal section; updated agents overview, prompts overview, workflow docs, and getting started pages

## 2026-03-17

### Added

- Engineering Manager agent (`eversis-engineering-manager`) — Orchestrates the implementation phase by delegating tasks to specialized agents (Software Engineer, E2E Engineer, DevOps Engineer, Architect, Code Reviewer, UI Reviewer) based on the implementation plan; uses Sequential Thinking for ambiguous routing; auto-triggers code review if no review phase is defined; tracks progress via plan checkboxes
- Internal prompts directory (`.github/internal-prompts/`) — Agent-only prompts not visible in the slash command menu, used exclusively for sub-agent delegation by the Engineering Manager
- Internal prompt `eversis-implement-common-task` — Base implementation workflow for Software Engineer delegated tasks (backend and non-Figma frontend)
- Internal prompt `eversis-implement-ui-common-task` — Extends `eversis-implement-common-task` with UI-specific behaviors for Figma-based frontend tasks
- Internal prompt `eversis-implement-ui` — Full UI implementation + verification loop orchestration for the Engineering Manager
- Documentation page for the Engineering Manager agent on the website
- Documentation pages for all new internal prompts on the website

### Changed

- `/eversis-implement` prompt — Rewritten to route through the Engineering Manager agent instead of Software Engineer; now delegates tasks to specialized agents based on plan task types (`[CREATE]`, `[MODIFY]`, `[REUSE]`)
- Architect agent (`eversis-architect`) — Handoff now routes to Engineering Manager instead of Software Engineer; removed "Start UI Implementation" handoff button (consolidated into single "Start Implementation"); reformatted tools list YAML; updated plan template to include `[REUSE]` UI verification tasks delegated to `eversis-ui-reviewer`
- Architecture Designing skill (`eversis-architecture-designing`) — Updated plan phases to run only fast tests/checks per phase (unit, integration, linters, build); added code review phase requirement using `eversis-code-reviewer` with `eversis-review.prompt.md`; added `[REUSE]` UI verification task pattern for Figma-based features
- UI Reviewer agent (`eversis-ui-reviewer`) — Removed "Start UI Implementation" and "Implement UI Fixes" handoff buttons (Engineering Manager now owns the verify-fix loop); added explicit dev server URL confirmation requirement; added authentication/login screen detection and escalation; added "reading source code is NOT verification" guardrail
- Code Reviewer agent (`eversis-code-reviewer`) — Added explicit mention of e2e tests alongside unit and integration tests in verification requirements
- Software Engineer agent (`eversis-software-engineer`) — Removed `atlassian/search` from tool access (Atlassian context now gathered by Engineering Manager)
- `/eversis-plan` prompt — Minor update
- `/eversis-review-ui` prompt — Minor update
- `/eversis-review` prompt — Minor update
- Prompts reorganized into public and internal categories on the documentation website with separate sidebar sections
- Moved 7 infrastructure/DevOps prompts from public `.github/prompts/` to internal `.github/internal-prompts/` (`eversis-deploy-kubernetes`, `eversis-implement-e2e`, `eversis-implement-observability`, `eversis-implement-pipeline`, `eversis-implement-terraform`)
- Updated agents overview documentation with Engineering Manager in the handoff diagram and agent summary table
- Updated prompts overview documentation with public/internal prompt distinction and delegation table
- Updated workflow documentation (standard flow, frontend flow, e2e flow) to reflect Engineering Manager orchestration

### Removed

- `/eversis-implement-ui` public prompt — Consolidated into `/eversis-implement`; UI implementation is now handled internally by the Engineering Manager's delegation to Software Engineer + UI Reviewer
- `/eversis-clean-transcript` prompt — Removed (functionality available through `/eversis-analyze-materials`)
- `/eversis-create-jira-tasks` prompt — Removed (functionality available through `/eversis-analyze-materials`)

## 2026-03-08

### Added

- Ensuring Accessibility skill (`eversis-ensuring-accessibility`) — WCAG 2.1 AA compliance, semantic HTML, ARIA patterns, keyboard navigation, focus management, screen reader support, and color contrast requirements
- Implementing Forms skill (`eversis-implementing-forms`) — Form architecture, schema-based validation, field composition, error handling, multi-step form flows, and accessible form patterns
- Frontend Optimization skill (`eversis-optimizing-frontend`) — Rendering optimization, code splitting, memoization strategies, bundle size control, asset optimization, and memory management with React-specific reference patterns
- Frontend Review skill (`eversis-reviewing-frontend`) — Frontend-specific code review criteria: component anti-patterns, hooks quality, rendering correctness, accessibility and performance spot-checks, module organization with React-specific reference checklist
- Writing Hooks skill (`eversis-writing-hooks`) — Custom hook and composable patterns: naming, composition, stable return shapes, lifecycle cleanup, and testing strategies with React-specific reference patterns
- React-specific reference files (`references/react-patterns.md`) for implementing-frontend, optimizing-frontend, reviewing-frontend, and writing-hooks skills
- Documentation pages for all 5 new skills on the website

### Changed

- Software Engineer agent (`eversis-software-engineer`) — Added 4 new frontend skills to skills list (`eversis-implementing-forms`, `eversis-writing-hooks`, `eversis-ensuring-accessibility`, `eversis-optimizing-frontend`); added `eversis-ui-reviewer` as subagent for verification delegation; reformatted tools list
- Code Reviewer agent (`eversis-code-reviewer`) — Added `eversis-reviewing-frontend` skill for frontend-specific review criteria
- UI Reviewer agent (`eversis-ui-reviewer`) — Rewritten to emphasize subagent usage pattern, mandatory tool-based verification (never mental comparison), transparent error reporting with LOW confidence; reformatted tools list
- Frontend Implementation skill (`eversis-implementing-frontend`) — Refactored to focus on component patterns and composition, moved accessibility to dedicated `eversis-ensuring-accessibility` skill; added React-specific reference file
- UI Verification skill (`eversis-ui-verifying`) — Rewritten with 5-step verification process, verification order (stop on first CRITICAL failure), and improved report format
- `/eversis-implement-ui` prompt — Rewritten to use `eversis-ui-reviewer` as subagent (not `/eversis-review-ui` prompt call); added `eversis-ensuring-accessibility` skill; clarified that SE must never verify UI itself
- `/eversis-review-ui` prompt — Simplified to delegate entirely to `eversis-ui-verifying` skill workflow; fixed "all differences" wording to align with skill's stop-on-critical-failure rule
- Updated website documentation for Software Engineer, Code Reviewer, UI Reviewer agents and `/eversis-implement-ui`, `/eversis-review-ui` prompts
- Updated skills overview: skill count 25 → 30, added new skills to Development and Quality tables, updated agent–skill matrix
- Fixed Architect agent docs — added 7 missing skills (multi-cloud, cloud cost, CI/CD, Terraform, secrets, Kubernetes, observability)
- Fixed DevOps Engineer agent docs — added missing `eversis-codebase-analysing` skill
- Fixed Frontend Flow workflow docs — added `eversis-ensuring-accessibility` to required skills, updated subagent terminology

## 2026-03-06

### Added

- DevOps Engineer agent (`eversis-devops-engineer`) — Senior DevOps Engineer and Consultant persona specializing in Golden Paths, automation, and Cloud governance; mandatory architect sub-agent delegation for all design decisions; multi-cloud guardrails with FinOps alerts (>10% cost increase triggers alert); three-option output strategy (Golden Path, Cost-Optimized, Velocity); mandatory skill-loading chains for 8 task types; tools include AWS API MCP, AWS Docs MCP, GCP gcloud/observability/storage MCPs, Context7, Sequential Thinking
- Multi-Cloud Architecture skill (`eversis-designing-multi-cloud-architecture`) for selecting and integrating services across AWS, Azure, and GCP with service comparison and multi-cloud pattern references
- CI/CD Implementation skill (`eversis-implementing-ci-cd`) for pipeline design patterns and deployment strategies
- Kubernetes Implementation skill (`eversis-implementing-kubernetes`) for deployment patterns, Helm charts, and cluster management
- Observability Implementation skill (`eversis-implementing-observability`) for logging, monitoring, alerting, and distributed tracing patterns
- Terraform Modules skill (`eversis-implementing-terraform-modules`) for reusable Terraform modules across AWS, Azure, and GCP with per-cloud module references
- Secrets Management skill (`eversis-managing-secrets`) for secrets management patterns in cloud and Kubernetes environments
- Cloud Cost Optimization skill (`eversis-optimizing-cloud-cost`) for rightsizing, tagging strategies, and spending analysis with tagging standards reference
- AWS cost analysis prompt (`/eversis-analyze-aws-costs`) for cost optimization and tagging compliance audit with hybrid IaC + live API approach
- GCP cost analysis prompt (`/eversis-analyze-gcp-costs`) for cost optimization and labeling compliance audit with hybrid IaC + live API approach
- Infrastructure audit prompt (`/eversis-audit-infrastructure`) for multi-scope audit (AWS/Azure/GCP/K8s/CI-CD) covering security, cost, and best practices
- Kubernetes deployment prompt (`/eversis-deploy-kubernetes`) for deployments, Helm charts, and workload configurations
- CI/CD pipeline prompt (`/eversis-implement-pipeline`) for pipelines with deployment stages and environment protection
- Terraform implementation prompt (`/eversis-implement-terraform`) for Terraform modules and cloud infrastructure provisioning
- Observability implementation prompt (`/eversis-implement-observability`) for metrics, logs, traces, and alerting solutions

### Changed

- Updated Architect agent (`eversis-architect`) with handoff to DevOps Engineer for infrastructure implementation
- Renamed 7 new infrastructure skill directories with `eversis-` prefix (continuation of 2026-03-05 prefix migration)
- Renamed 7 new infrastructure prompt files with `eversis-` prefix
- Updated all skill cross-references in architect agent, devops engineer agent, and all 7 infrastructure SKILL.md files
- Updated all skill references in 7 infrastructure prompt files

## 2026-03-05

### Changed

- Added `eversis-` prefix to all Cursor customization artifacts to prevent naming collisions when used alongside project-specific customizations
- Renamed all 18 skill directories to include `eversis-` prefix (e.g., `code-reviewing` → `eversis-code-reviewing`, `creating-agents` → `eversis-creating-agents`)
- Renamed all 15 prompt files to include `eversis-` prefix (e.g., `/create-custom-agent` → `/eversis-create-custom-agent`, `/implement` → `/eversis-implement`)
- Renamed worker agents to include `eversis-` prefix: `cursor-customization-researcher` → `eversis-cursor-customization-researcher`, `cursor-customization-artifact-creator` → `eversis-cursor-customization-artifact-creator`, `cursor-customization-artifact-reviewer` → `eversis-cursor-customization-artifact-reviewer`
- Updated all cross-references between artifacts to use prefixed names

### Added

- Naming convention instruction (`.github/instructions/naming-conventions.instructions.md`) enforcing `eversis-` prefix on all artifact filenames, frontmatter names, and cross-references
- `eversis-` prefix explanation note in README for external users

## 2026-03-02

### Added

- Custom agent creation prompt (`/create-custom-agent`) for creating new `.agent.md` files via the orchestrator — researches existing patterns, guides design decisions, creates and validates the agent file
- Custom skill creation prompt (`/create-custom-skill`) for creating new `SKILL.md` files via the orchestrator — enforces gerund naming, creates supporting resources alongside the skill file
- Custom prompt creation prompt (`/create-custom-prompt`) for creating new `.prompt.md` files via the orchestrator — identifies correct agent routing, ensures prompt follows established patterns
- Custom instructions creation prompt (`/create-custom-instructions`) for creating new `.instructions.md` or `project-instructions.md` files via the orchestrator — helps decide between repo-level and file-scoped instructions

### Changed

- Creating Agents, Creating Skills, Creating Prompts, and Creating Instructions skills marked as internal (agent-only) — hidden from the slash command menu via `user-invokable: false` in SKILL.md frontmatter while remaining accessible to agents
- New `/create-custom-*` prompts serve as the recommended user-facing entry points for Cursor customization workflows, replacing direct skill invocation

## 2026-03-01

### Changed

- Restructured README around the full product development lifecycle: Product Ideation → Development → Quality
- Reorganized Agents, Skills, and Prompts sections into lifecycle phase groups (Product Ideation, Development, Quality)
- Moved Context Engineer from Product Ideation to Development agents
- Renamed "Backlog" phase to "Product Ideation" across the entire README
- Updated workflow examples to show `/research` under Development (not Product Ideation)
- Replaced flat prompt/agent listings with per-phase tables in "Using This Repository" section
- Updated Summary to reflect full lifecycle framing
- Renamed agent: `eversis-workshop-analyst` → `eversis-business-analyst`
- Renamed agent: `eversis-business-analyst` → `eversis-context-engineer` (old Business Analyst became Context Engineer)
- Renamed prompt: `/workshop-analyze` → `/analyze-materials`
- Renamed prompt: `/transcript-clean` → `/clean-transcript`
- Renamed prompt: `/code-quality-check` → `/review-codebase`
- Renamed prompt: `/e2e` → `/implement-e2e`
- Renamed skill: `task-extraction` → `task-extracting`
- Renamed skill: `task-quality-review` → `task-quality-reviewing`
- Renamed skill: `frontend-implementation` → `implementing-frontend`
- Renamed skill: `ui-verification` → `ui-verifying`
- Renamed skill: `architecture-design` → `architecture-designing`
- Renamed skill: `code-review` → `code-reviewing`
- Renamed skill: `codebase-analysis` → `codebase-analysing`
- Renamed skill: `implementation-gap-analysis` → `implementation-gap-analysing`
- Renamed skill: `task-analysis` → `task-analysing`

## 2026-02-27

### Added

- Cursor customization engineer agent (`eversis-cursor-customization-engineer`) for designing, creating, reviewing, and improving all GitHub Cursor customization artifacts — custom agents, skills, prompts, and instructions
- Cursor customization orchestrator agent (`eversis-cursor-customization-orchestrator`) for coordinating complex, multi-step Cursor customization engineering tasks by decomposing work into focused subtasks and delegating to specialized workers
- Cursor customization researcher worker agent (`cursor-customization-researcher`) for gathering, analyzing, and summarizing information from codebases and documentation — read-only research specialist for orchestrator delegation
- Cursor customization artifact creator worker agent (`cursor-customization-artifact-creator`) for building and modifying Cursor customization artifacts based on detailed specifications — creation specialist for orchestrator delegation
- Cursor customization artifact reviewer worker agent (`cursor-customization-artifact-reviewer`) for evaluating Cursor customization artifacts against best practices, workspace consistency, and structural correctness — review specialist for orchestrator delegation
- Orchestrator pattern documentation (`docs/orchestrator-pattern.md`) describing the orchestrator + specialized workers architecture as an alternative to monolithic agents, addressing context window degradation in complex multi-step tasks
- Creating Agents skill (`creating-agents`) with agent file template, structural conventions, and validation checklist for building `.agent.md` files
- Creating Skills skill (`creating-skills`) with naming conventions, body structure guidelines, progressive disclosure patterns, templates, and examples for building `SKILL.md` files
- Creating Prompts skill (`creating-prompts`) with prompt file template, workflow focus guidelines, and validation checklist for building `.prompt.md` files
- Creating Instructions skill (`creating-instructions`) with templates for repository-level and granular instruction files, decision framework for instruction vs. skill placement

### Changed

- Adopted gerund-form naming convention (`verb-ing` + `object`) as the standard for all skill directories, documented in README and enforced by the Creating Skills skill
- Existing skills will be adapted to follow the new gerund-form naming convention in separate upcoming pull requests

## 2026-02-24

### Added

- Workshop Analyst agent (`eversis-workshop-analyst`) for converting discovery workshop materials (transcripts, designs, codebase context) into Jira-ready epics and user stories
- Transcript Processing skill (`transcript-processing`) for cleaning raw workshop/meeting transcripts and extracting structured business-relevant content
- Task Extraction skill (`task-extraction`) for identifying and structuring epics and user stories from workshop materials
- Task Quality Review skill (`task-quality-review`) for analyzing extracted tasks for quality gaps, missing edge cases, and improvement opportunities
- Jira Task Formatting skill (`jira-task-formatting`) for transforming extracted tasks into Jira-ready format with field mapping and markdown compatibility
- Workshop analysis prompts: `/workshop-analyze`, `/transcript-clean`, `/create-jira-tasks`

## 2026-02-18

### Added

- SQL & Database engineering skill covering schema design (naming conventions, primary key strategies, data types, normalisation), performant SQL writing, indexing strategies, join optimisation, locking mechanics, transactions, query debugging with EXPLAIN ANALYZE, and ORM integration (TypeORM, Prisma, Doctrine, Eloquent, Entity Framework, Hibernate, GORM). Applies to PostgreSQL, MySQL, MariaDB, SQL Server, and Oracle

## 2026-02-17

### Added

- Frontend Implementation skill (`frontend-implementation`) for accessibility, design system usage, component patterns, and performance guidelines
- UI Verification skill (`ui-verification`) for verification criteria, tolerances, checklists, and severity definitions

### Changed

- Consolidated `eversis-frontend-software-engineer` agent into `eversis-software-engineer` - frontend capabilities are now handled via skills
- Updated `eversis-software-engineer` tool guidelines with frontend-specific scenarios (Figma, Playwright, design tokens)
- Made skills tool-agnostic by removing hardcoded tool names
- Refactored `implement-ui.prompt.md` and `review-ui.prompt.md` to reference skills instead of duplicating content

### Removed

- `eversis-frontend-software-engineer` agent (replaced by `eversis-software-engineer` + frontend skills)

## 2026-02-15

### Added

- Code quality check prompt (`/code-quality-check`) for comprehensive repository analysis covering dead code detection, duplication identification, improvement opportunities, and architecture review

## 2026-02-08

### Added

- Technical context discovery skill for codebase exploration and understanding

### Changed

- Refactored agents, prompts, and skills to follow a consistent standard
- Improved architecture-design plan example with expanded detail
- Updated implementation-gap-analysis and task-analysis examples
- Streamlined agent definitions by extracting workflow logic into prompts and skills

## 2026-02-07

### Added

- Skills support for modular, domain-specific agent capabilities (architecture-design, code-review, codebase-analysis, e2e-testing, implementation-gap-analysis, task-analysis)

### Changed

- Cleaned up repository structure

## 2026-02-05

### Changed

- Switched default model to Claude Opus 4.6
- Updated documentation for VS Code 1.109 compatibility

## 2026-02-03

### Removed

- GitHub MCP integration
- Cursor Spaces usage from agents

## 2026-01-29

### Fixed

- Updated tool names to follow new VS Code naming pattern

## 2026-01-21

### Fixed

- Updated Atlassian MCP URL to new recommended endpoint

## 2026-01-15

### Changed

- Removed "(Preview)" label from model names in all prompt files for consistency

## 2026-01-08

### Changed

- Updated package name

## 2026-01-07

### Changed

- Updated agent tools for improved functionality and testing capabilities

## 2025-12-18

### Added

- Frontend Software Engineer agent with UI implementation workflow
- UI implementation prompt with iterative UI verification process

## 2025-12-16

### Changed

- Standardized tool names across all agents

## 2025-12-15

### Changed

- Separated workflow instructions from agent identity definitions

## 2025-12-12

### Added

- Language consistency guidelines for agents

### Changed

- Code reviewer now runs automatically after implementation

## 2025-12-11

### Added

- external license requirement documentation

## 2025-12-10

### Changed

- Updated review prompt model to Claude Opus 4.5

## 2025-12-08

### Added

- Domain-specific Cursor Spaces support for agents
- Code reviewer as a subagent of the software engineer

## 2025-12-02

### Added

- VS Code version requirement documentation (1.99+)

### Changed

- Generalized software engineer agent (previously backend-specific)
- Standardized agent descriptions and enforced instructions usage
- Switched agents to use Claude Opus

## 2025-11-28

### Added

- Figma MCP Server integration for UI verification
- Git-committer agent with automated commit message generation

## 2025-11-26

### Added

- `eversis-` prefix for all agent names for namespace consistency
- Atlassian resource accessibility checks

## 2025-11-23

### Added

- Detailed MCP tool usage guidelines for all agents (Context7, Playwright, Figma, Atlassian)

## 2025-11-21

### Added

- Sequential Thinking MCP integration for complex problem-solving
- Data Engineer agent

## 2025-11-20

### Added

- MCP server configurations (Playwright, Context7, Figma Dev Mode, Atlassian)
- UI/Figma verification agent and review workflow
- Frontend Software Engineer agent (initial base)

## 2025-11-19

### Added

- MCP configuration for workspace and user-level setups
- LICENSE file and updated README

## 2025-11-14

### Added

- Agent-based architecture with handoffs (Architect, Business Analyst, Software Engineer, Code Reviewer)

### Changed

- Updated models to GPT-5.1 across prompts
- Specified Figma MCP usage in research workflow

## 2025-11-05

### Changed

- Planning prompt now focuses on tasks only, excluding improvements

## 2025-11-03

### Added

- New operational mode and additional tools

## 2025-10-31

### Changed

- Narrowed Atlassian/Jira access scope
- Enhanced planning and research prompts with implementation analysis guidelines

## 2025-10-29

### Added

- Plan prompt with task-specific implementation focus

## 2025-10-28

### Added

- Initial project setup with EditorConfig, Prettier, Husky, and project tooling configurations
- Automated commit message generation prompt
- Security review configuration and documentation
