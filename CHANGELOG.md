# Changelog

All notable changes to **Agent Collections** (`agent-collections`) are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Policy

- **Release unit:** one SemVer git tag on this repository (core `.ai/`, plus adapters / installer / MCP when present).
- **Breaking changes:** every breaking release **must** include a **Migration** subsection with consumer steps (see [README](./README.md) upgrade contract).
- **Project-owned paths** are never overwritten by upgrade tooling without explicit opt-in (see README).

## [Unreleased]

### Added

- **Wave D — docs + validation (DHI-515 / 541, 539, 540, 542)**
  - Getting-started guides under `website/docs/getting-started/` (CC-analog stems) + migration from Cursor Collections
  - Framework reference `documentation/agent-collection.md` and WF/WNF `docs/architecture/requirements-traceability.md`
  - Docusaurus site under `website/` (rebrand Agent Collections; local build; **public hosting deferred**)
  - EOG pilot context / WNF-03 measurement notes under `docs/context/eog/`
- **Wave C — self-contained distribution (DHI-515 / 533–538, 530, 532; 521 verify)**
  - Bootstrap without sibling `cursor-collections` symlinks (skills/prompts/commands + BA Docs rule links removed; Q1: no full `.cursor` skills mirror)
  - MCP package `mcp/eversis-collections-mcp/` resolving `.ai/skills` via `AGENT_COLLECTIONS_HOME` (Q2; no `CURSOR_COLLECTIONS_HOME` in default template)
  - Installer `scripts/setup-agent-collections.sh` (local / submodule / copy) with selection `.agent-collections/install-selection.json` (Q3)
  - Domain profiles `adapters/profiles/{frontend,backend,fullstack}.yaml` (Q4) + area profiles `area-*-scope.yaml` / `area-fullstack.yaml` (DHI-530)
  - Wizard axes `--agents` / `--mcp-servers` / `--profile` + `--non-interactive`; upgrade `--upgrade` with fail-safe (DHI-537 / S-01…S-04)
  - Reference `AGENTS.md` filled (DHI-532); install selection schema doc
  - Root scripts: `mcp:build`, `mcp:test`, `installer:smoke`

### Changed

- **DHI-541** — Root README rewritten for human-first documentation UX (progressive disclosure: hero → workflows with human gates → quick start → install/upgrade facts), aligned with cursor-collections README pattern while keeping Agent Collections facts (`AGENT_COLLECTIONS_HOME`, adapters, MVP limits)
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
- **Local-only story specs** — `docs/specs/dhi-*/` gitignored for MVP (research/plan stay on disk, not published with the framework tree)
- **Mandatory spec-driven development (Delivery Standard)** — `.ai/rules/orchestration/spec-driven-development.md` (+ pointer from `agent-core`); documented in README / AGENTS / `docs/specs/README.md`; Jira story template block in `eversis-jira-task-formatting` (stable prompt ids + optional Cursor attach note)
- **Adapter mapping specification** — canonical architecture/mapping doc at `docs/architecture/adapter-mapping.md` (Cursor / Claude / OpenCode field maps, emit matrix, `rule-map` contract); pointer from `.ai/README.md` (DHI-523)
- **Isolation strategy (DHI-528)** — canonical cross-tool ignore and area-scoping strategy at `docs/architecture/isolation-strategy.md` (packaging matrix, area profiles, WNF-03 estimation + orientation-without-noise); pointer from `adapter-mapping.md` / `.ai/README.md`; path globs remain DHI-530
- **Synchronized ignore triad (DHI-529)** — root `.cursorignore`, `.claudeignore`, and `.opencodeignore` with shared secrets/build + cross-tool packaging classes (§4); checklist in `isolation-strategy.md` §8.1; no heavy-infra/`apps/**` in framework root; `adapters/sync.mjs` unchanged; future installer merges missing classes without wipe (opt-in)
- **Cursor adapter (DHI-524)** — `adapters/cursor/` with `rule-map.yaml` and zero-deps `generate.mjs` (`node adapters/cursor/generate.mjs`, optional `--out`); generates framework `.cursor/rules/*.mdc` from `.ai/rules` (replaces symlink bootstrap for mapped rules; BA Docs symlinks and consumer `eversis-project-stack.mdc` left untouched)
- **OpenCode adapter placeholder (DHI-525)** — `adapters/opencode/` + root `opencode.jsonc` (`$schema` + `instructions` globs → `.ai/rules`); maturity `placeholder` only (not a shipped adapter); minimal Cursor exclusion in `.cursorignore` (full ignore triad → DHI-529)
- **Claude Code adapter (DHI-526)** — `adapters/claude/` with `rule-map.yaml` and zero-deps `generate.mjs` (`node adapters/claude/generate.mjs`, optional `--out`); generates root `CLAUDE.md` (H2 per mapped rule, full inline; id/source parity with Cursor map); ignore / monorepo isolation deferred to DHI-528–530
- **Adapter sync CLI (DHI-527)** — `adapters/sync.mjs` (+ `package.json` scripts `sync:adapters` / `sync:adapters:check`) regenerates Cursor then Claude deterministically; `--check` validates no drift and Cursor↔Claude id/source map parity; does not touch project-owned stack / BA Doc symlinks; OpenCode out of sync MVP

### Migration

No consumer migration required for `0.0.1` (first placeholder). When upgrading from a future `0.0.x` / `0.1.x` with breaking changes, follow the **Migration** notes in that release and the [README](./README.md) upgrade modes.
