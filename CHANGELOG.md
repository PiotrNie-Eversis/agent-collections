# Changelog

All notable changes to **Agent Collections** (`agent-collections`) are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Policy

- **Release unit:** one SemVer git tag on this repository (core `.ai/`, plus adapters / installer / MCP when present).
- **Breaking changes:** every breaking release **must** include a **Migration** subsection with consumer steps (see [README](./README.md) upgrade contract).
- **Project-owned paths** are never overwritten by upgrade tooling without explicit opt-in (see README).

## [0.0.1] — 2026-08-05

Placeholder pre-distribution version. Self-contained bootstrap and installer are not included yet. Cursor rules adapter generator is present under `adapters/cursor/`.

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
- **Cursor adapter (DHI-524)** — `adapters/cursor/` with `rule-map.yaml` and zero-deps `generate.mjs` (`node adapters/cursor/generate.mjs`, optional `--out`); generates framework `.cursor/rules/*.mdc` from `.ai/rules` (replaces symlink bootstrap for mapped rules; BA Docs symlinks and consumer `eversis-project-stack.mdc` left untouched)

### Migration

No consumer migration required for `0.0.1` (first placeholder). When upgrading from a future `0.0.x` / `0.1.x` with breaking changes, follow the **Migration** notes in that release and the [README](./README.md) upgrade modes.
