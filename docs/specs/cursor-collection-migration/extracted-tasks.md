# Cursor Collection Migration — Extracted Tasks

## Workshop Summary

| Field | Value |
|---|---|
| Workshop Date | 2026-07-30 |
| Participants | Piotr Niemirski |
| Source Materials | BRD `Cursor-Collection-migration.md`; Jira epic DHI-515; codebase analysis of `cursor-collections` and `agent-collections` |
| Intent Brief | [intent-brief.md](./intent-brief.md) |
| Jira Parent Epic | **DHI-515** — Multi-Agent AI Context Isolation & Standard |
| Project Baseline Used | None |
| Total Work Streams | 6 |
| Total Stories | 27 |
| Delivery Standard | **Full spec-driven development** — mandatory for every story (see below) |

## Epics Overview

| # | Work Stream | Stories | Priority | Jira Parent |
|---|-------------|---------|----------|-------------|
| 1 | Core Rules Extraction | 7 | Critical | DHI-515 |
| 2 | Multi-Agent Adapters | 5 | Critical | DHI-515 |
| 3 | Context Isolation | 3 | High | DHI-515 |
| 4 | AGENTS.md Standard | 2 | High | DHI-515 |
| 5 | Distribution & Replication | 6 | High | DHI-515 |
| 6 | Documentation & Validation | 4 | Medium | DHI-515 |

---

## Mandatory Delivery Standard (all stories)

**Every story under DHI-515 inherits the following.** Jira descriptions must include a **Delivery Standard** section with this content (not optional).

### Spec-driven lifecycle

| Step | Required artifact / action | Human gate |
|------|---------------------------|------------|
| 1. Research | `docs/specs/<issue-kebab>/<issue-kebab>.research.md` — context, assumptions, open questions, links to Jira AC | Approval before plan |
| 2. Plan | `docs/specs/<issue-kebab>/<issue-kebab>.plan.md` — phases, risks, acceptance checks | Approval before implementation |
| 3. Implement | `@eversis-implement` with Jira key + `@*.plan.md`; adequacy checklist before Research/Plan SKIP | Gates per `eversis-agent-core` |
| 4. Review | `@eversis-review` — PASS / BLOCKER / SUGGESTION | Before Fine |
| 5. Fine | QA comment draft (`eversis-fine-handoff`) | Human approval before Jira QA post |

**Folder naming:** `<issue-kebab>` = Jira key lowercased (e.g. `DHI-516` → `dhi-516-core-structure` or `dhi-516`).

### Inherited acceptance criteria (applies to every story unless noted)

- [ ] GIVEN a story in **To Do** WHEN an assignee starts work THEN a spec folder `docs/specs/<issue-kebab>/` exists before any implementation edits
- [ ] GIVEN the spec folder WHEN research completes THEN `<issue-kebab>.research.md` is written and approved before planning begins
- [ ] GIVEN approved research WHEN planning completes THEN `<issue-kebab>.plan.md` is written and approved before `@eversis-implement` execution
- [ ] GIVEN implementation complete WHEN the story is marked done THEN `@eversis-review` has been run and blockers resolved
- [ ] GIVEN review PASS WHEN closing the story THEN a Fine QA comment draft exists per `eversis-fine-handoff`

### Jira description template (include in every story)

Each Jira story description must contain these sections in addition to Context, User Story, and Requirements:

```
h2. Delivery Standard

This story follows *full spec-driven development* (mandatory under epic DHI-515).

* Spec folder: docs/specs/<issue-kebab>/
* Research: <issue-kebab>.research.md — required before plan
* Plan: <issue-kebab>.plan.md — required before implementation
* Implement: @eversis-implement with approved plan attached
* Review: @eversis-review before Done
* Fine: QA comment draft per eversis-fine-handoff

Do not start implementation without approved research and plan artifacts.
```

---

## Work Stream 1: Core Rules Extraction

**Business Description**: Preserve the proven knowledge accumulated in Cursor Collections by extracting it into a vendor-neutral core layer. This work stream establishes the single source of truth (SSOT) that all tool adapters will consume, organized by domain so teams receive only relevant guidance.

**Success Criteria**:
- All framework rules, skills, and prompts from `cursor-collections` are inventoried and classified
- Core neutral rules exist in `agent-collections` without Cursor-specific references
- Domain folders cover frontend, backend, shared-types, devops, architecture, and shared orchestration
- A documented upgrade contract allows consumer projects to pull framework updates
- Spec-driven development (research → plan → implement → review) is encoded as the mandatory delivery standard

### Story 1.1: Inventory legacy Cursor Collections assets

**User Story**: As a framework maintainer, I want a complete inventory of rules, skills, prompts, commands, and scripts in `cursor-collections` so that nothing is lost during migration.

**Source**: BRD §2 (current vs target state); codebase analysis — 8 rules, 45 skills, 28 prompts, 8 commands, MCP, install scripts

**Acceptance Criteria**:
- [ ] GIVEN the `cursor-collections` repository WHEN an asset inventory is produced THEN every rule, skill, prompt, command, script, and MCP component is listed with path and purpose
- [ ] GIVEN the inventory WHEN each asset is classified THEN it is tagged as Core (vendor-neutral), Cursor-specific, or Deprecated
- [ ] GIVEN the inventory WHEN reviewed by the framework maintainer THEN gaps versus the BRD scope (WF-01 through WF-05) are explicitly noted

**High-Level Technical Notes**: None

**Priority**: Critical

### Story 1.2: Define core neutral rules directory structure

**User Story**: As a framework maintainer, I want a defined `.ai/` (or equivalent) directory layout so that all neutral rules have a consistent, domain-scoped home.

**Source**: BRD WF-01.1, WF-01.2; Filar 1

**Acceptance Criteria**:
- [ ] GIVEN the BRD domain requirements WHEN the core structure is documented THEN folders exist for at least frontend, backend, shared-types, devops, architecture, and shared orchestration
- [ ] GIVEN the structure definition WHEN a sample rule file is placed THEN it uses neutral Markdown without Cursor/Claude-specific front matter
- [ ] GIVEN the structure WHEN reviewed THEN it explains how skills, prompts, and orchestration contracts map into the core (not only `.mdc` rules)

**High-Level Technical Notes**: Discussed `.ai/` as designated source catalog per BRD

**Priority**: Critical

### Story 1.3: Extract shared orchestration rules to core

**User Story**: As an engineering manager using any AI agent, I want shared workflow rules (Ideate → Implement → Review, quality gates, handoff contracts) in the core layer so that orchestration behavior is consistent regardless of tool.

**Source**: BRD Filar 1; `cursor-collections` rules — `eversis-agent-core.mdc`, orchestration skills

**Acceptance Criteria**:
- [ ] GIVEN legacy orchestration rules in `cursor-collections` WHEN extraction completes THEN equivalent neutral rules exist in the core without Cursor-specific paths or `@` attachment syntax
- [ ] GIVEN the extracted orchestration rules WHEN read by a non-technical stakeholder THEN the Ideate → Implement → Review lifecycle and human gate expectations are clear
- [ ] GIVEN the core orchestration rules WHEN compared to legacy THEN no mandatory workflow step from the legacy framework is silently dropped

**High-Level Technical Notes**: Includes agent-core lifecycle, Fine handoff contract, testing discipline

**Priority**: Critical

### Story 1.4: Extract domain-scoped core rules

**User Story**: As a team lead, I want coding, architecture, and quality rules organized by domain in the core so that frontend and backend teams receive guidance relevant to their area without cross-noise.

**Source**: BRD WF-01.2; legacy rules — `eversis-code-reviewer`, `eversis-testing-and-terminal`, domain skills

**Acceptance Criteria**:
- [ ] GIVEN domain folders in the core WHEN rules are migrated THEN frontend, backend, devops, architecture, and shared-types each contain at least the rules derived from legacy equivalents
- [ ] GIVEN a domain rule WHEN reviewed THEN it contains no references to a specific IDE, CLI, or vendor UI
- [ ] GIVEN two domains with overlapping guidance WHEN consolidated THEN duplication is minimized while domain scoping is preserved

**High-Level Technical Notes**: Neutralize globs/scoping metadata — scoping moves to adapters (Story 2.2)

**Priority**: Critical

### Story 1.5: Port skills and prompts to core-neutral storage

**User Story**: As a framework maintainer, I want skills and prompts stored in the core in a tool-neutral format so that adapters can surface them without maintaining 45×N copies by hand.

**Source**: BRD Filar 1; codebase analysis — 45 skills, 28 prompts in `cursor-collections`

**Acceptance Criteria**:
- [ ] GIVEN legacy skills and prompts WHEN ported THEN they reside under the core directory structure with stable identifiers resolvable by MCP or adapter tooling
- [ ] GIVEN a ported skill WHEN its body is read THEN procedural steps and output contracts remain intact but Cursor-only invocation paths are abstracted
- [ ] GIVEN the ported catalog WHEN counted THEN all skills and prompts marked Core in Story 1.1 are accounted for or explicitly deferred with rationale

**High-Level Technical Notes**: MCP skill resolution logic from `eversis-collections-mcp` is in scope for port (see Story 5.4)

**Priority**: Critical

### Story 1.6: Establish core versioning and upgrade contract

**User Story**: As a consumer project owner, I want a documented way to upgrade from the central `agent-collections` framework so that improvements propagate without re-installing from scratch.

**Source**: BRD WNF-02; WF-05.1

**Acceptance Criteria**:
- [ ] GIVEN a consumer project on framework version N WHEN version N+1 is published THEN an documented upgrade path exists (sync, submodule bump, or CLI upgrade)
- [ ] GIVEN the upgrade contract WHEN applied THEN project-owned files (e.g. project stack, local context) are never overwritten without explicit opt-in
- [ ] GIVEN a breaking change WHEN released THEN it is noted in framework changelog with migration steps

**High-Level Technical Notes**: None

**Priority**: High

### Story 1.7: Encode spec-driven development as mandatory delivery standard

**User Story**: As an engineering manager, I want spec-driven development encoded in the core rules, AGENTS.md, and Jira story template so that every DHI-515 delivery follows Research → Plan → Implement → Review with human gates.

**Source**: Stakeholder requirement (2026-07-30); `eversis-agent-core.mdc`; `docs/specs/README.md`; cursor-collections workflow docs

**Acceptance Criteria**:
- [ ] GIVEN core orchestration rules WHEN migrated THEN the Ideate → Research → Plan → Implement → Review lifecycle and human gates are documented in vendor-neutral form
- [ ] GIVEN the framework WHEN installed in a consumer project THEN `docs/specs/<issue-kebab>/` convention and required artifacts (`*.research.md`, `*.plan.md`) are documented in AGENTS.md and getting-started material
- [ ] GIVEN a Jira story template WHEN used for DHI-515 children THEN every description includes the **Delivery Standard** section (spec folder, artifacts, `@eversis-implement`, `@eversis-review`, Fine handoff)
- [ ] GIVEN `@eversis-implement` WHEN invoked on any DHI-515 story THEN Implement readiness enforces adequacy checklist before Research/Plan SKIP

**High-Level Technical Notes**: Cross-cutting standard — all 26 stories inherit Mandatory Delivery Standard AC; this story makes it framework-native

**Priority**: Critical

---

**Business Description**: Translate the neutral core into native formats for each AI tool. Teams keep their preferred toolchain while reading the same underlying standards.

**Success Criteria**:
- Cursor receives `.cursor/rules/*.mdc` generated from core with globs and descriptions
- Claude Code receives a tailored `CLAUDE.md` for CLI and system-layer work
- OpenCode integration point exists without requiring core changes
- Adapter generation is repeatable via tooling, not manual copy-paste

### Story 2.1: Define adapter architecture and mapping specification

**User Story**: As a framework architect, I want a written adapter mapping specification so that every core rule knows how it transforms into each tool's native format.

**Source**: BRD WF-02; Filar 2

**Acceptance Criteria**:
- [ ] GIVEN the core SSOT WHEN the mapping spec is complete THEN it defines field mapping for Cursor (globs, description, alwaysApply), Claude Code (scope, commands), and OpenCode (manifest placeholder)
- [ ] GIVEN a core rule WHEN processed through the spec THEN the output structure is unambiguous for implementers of Story 2.2–2.4
- [ ] GIVEN the spec WHEN reviewed THEN it states which core artifacts each adapter emits (rules only vs rules + prompts + skills summaries)

**High-Level Technical Notes**: None

**Priority**: Critical

### Story 2.2: Implement Cursor adapter

**User Story**: As a frontend developer using Cursor, I want `.cursor/rules/*.mdc` files generated from the core so that I get the same standards as today without maintaining duplicate rule files.

**Source**: BRD WF-02.1; legacy `.cursor/rules/` in both repos

**Acceptance Criteria**:
- [ ] GIVEN core rules with domain scope WHEN the Cursor adapter runs THEN `.cursor/rules/*.mdc` files are generated with appropriate `globs` and `description` front matter
- [ ] GIVEN the generated rules WHEN loaded in Cursor THEN orchestration, code quality, and project-stack customization behave equivalently to the legacy framework for a reference project
- [ ] GIVEN a core rule update WHEN the adapter re-runs THEN Cursor rules update without manual editing of generated files

**High-Level Technical Notes**: Replaces current symlink-only approach in `agent-collections`

**Priority**: Critical

### Story 2.3: Implement Claude Code adapter

**User Story**: As a backend developer using Claude Code CLI, I want a `CLAUDE.md` generated from the core so that CLI sessions follow the same architectural and quality standards as Cursor users.

**Source**: BRD WF-02.2; Filar 2

**Acceptance Criteria**:
- [ ] GIVEN core rules and backend-relevant domains WHEN the Claude adapter runs THEN a `CLAUDE.md` is produced with directory scope, CLI-oriented instructions, and system-layer guidance
- [ ] GIVEN the generated `CLAUDE.md` WHEN a backend task is started in Claude Code THEN the agent receives sufficient context without loading Cursor-specific files
- [ ] GIVEN monorepo layout WHEN scoped THEN backend paths are included and unrelated frontend/tool config paths are excluded per isolation rules (Work Stream 3)

**High-Level Technical Notes**: None

**Priority**: Critical

### Story 2.4: Define OpenCode future adapter manifest

**User Story**: As a framework maintainer, I want an OpenCode adapter placeholder so that future integration does not require rewriting the core.

**Source**: BRD WF-02.3; target-state diagram (OpenCode)

**Acceptance Criteria**:
- [ ] GIVEN the adapter architecture WHEN OpenCode support is stubbed THEN a manifest/config template exists documenting expected fields and core mapping hooks
- [ ] GIVEN the placeholder WHEN reviewed THEN it is clear the core remains unchanged when OpenCode format evolves
- [ ] GIVEN repository structure WHEN inspected THEN OpenCode adapter files are excluded from other agents' indexes (see Story 3.2)

**High-Level Technical Notes**: Implementation deferred; structure and interface only

**Priority**: Medium

### Story 2.5: Build adapter sync and generation tooling

**User Story**: As a framework maintainer, I want a single command to regenerate all adapters from core so that updates stay synchronized across tools.

**Source**: BRD Filar 2; legacy `setup-cursor-local.sh` / sync scripts

**Acceptance Criteria**:
- [ ] GIVEN updated core rules WHEN the sync command runs THEN Cursor and Claude outputs regenerate deterministically
- [ ] GIVEN a consumer project WHEN sync runs THEN only generated adapter outputs change; project-owned configuration is preserved
- [ ] GIVEN CI or local validation WHEN sync completes THEN a diff or validation step confirms no drift between core and adapters

**High-Level Technical Notes**: May extend or replace legacy `sync-prompts.mjs` patterns

**Priority**: High

---

## Work Stream 3: Context Isolation

**Business Description**: Prevent context collisions when multiple AI tools operate in the same enterprise monorepo. Each agent sees only what it needs; tool-specific configuration stays invisible to others.

**Success Criteria**:
- Synchronized ignore files ship with the framework
- Cross-tool config files are excluded from competing agents' indexes
- Monorepo teams can scope rules by path globs without overlap

### Story 3.1: Define cross-tool ignore and scoping strategy

**User Story**: As an enterprise monorepo owner, I want a documented isolation strategy so that Frontend and Backend teams can use different AI tools without context overlap.

**Source**: BRD WF-03; WNF-03; Jira DHI-515 description (collision-free standard)

**Acceptance Criteria**:
- [ ] GIVEN the monorepo use case WHEN the strategy is documented THEN it defines what each tool indexes, what is excluded, and how team boundaries map to globs
- [ ] GIVEN the strategy WHEN applied to a reference layout THEN Cursor, Claude, and future OpenCode each have non-overlapping default visibility rules
- [ ] GIVEN the strategy WHEN reviewed THEN it targets 30–50% context reduction versus unscoped loading (WNF-03)

**High-Level Technical Notes**: None

**Priority**: High

### Story 3.2: Deliver synchronized ignore files

**User Story**: As a developer, I want `.cursorignore`, `.claudeignore`, and `.opencodeignore` provided by the framework so that exclusion rules stay consistent across tools.

**Source**: BRD WF-03.1, WF-03.2

**Acceptance Criteria**:
- [ ] GIVEN framework installation WHEN complete THEN all three ignore files are present with synchronized exclusion patterns
- [ ] GIVEN Cursor-specific paths (e.g. `.cursor/rules` generated stubs) WHEN Claude Code indexes the repo THEN those paths are excluded from Claude's context
- [ ] GIVEN Claude-specific paths (e.g. `CLAUDE.md` fragments or Claude config) WHEN Cursor indexes THEN those paths are excluded from Cursor's context

**High-Level Technical Notes**: Extends existing `.cursorignore` in `agent-collections`

**Priority**: High

### Story 3.3: Implement monorepo glob scoping for team isolation

**User Story**: As a monorepo team lead, I want rules scoped by directory globs so that frontend agents do not load backend rules and vice versa.

**Source**: BRD §2 (Monorepo scalability); WF-02.1 globs; Jira DHI-515 (Frontend and Backend teams)

**Acceptance Criteria**:
- [ ] GIVEN a monorepo with `apps/web` and `apps/api` WHEN frontend profile is installed THEN generated Cursor rules apply only to frontend paths
- [ ] GIVEN the same monorepo WHEN backend profile is installed THEN Claude context emphasizes backend paths and excludes frontend-only artifacts
- [ ] GIVEN overlapping shared packages WHEN scoped THEN shared-types/domain rules apply to both without duplicating full stack rules

**High-Level Technical Notes**: Depends on adapter globs (Story 2.2, 2.3) and install profiles (Story 5.3)

**Priority**: High

---

## Work Stream 4: AGENTS.md Standard

**Business Description**: Provide a single agnostic entry point that maps monorepo areas and role responsibilities for every agent, supporting RAG and session context.

**Success Criteria**:
- `AGENTS.md` template is tool-neutral and documents monorepo map and role matrix
- `agent-collections` ships a complete reference `AGENTS.md`, not a stub

### Story 4.1: Define agnostic AGENTS.md template and role matrix

**User Story**: As an AI agent in any tool, I want a standard `AGENTS.md` format so that I can locate project areas, roles, and framework entry points consistently.

**Source**: BRD WF-04.1, WF-04.2; legacy `AGENTS.md` and `AGENTS.stub.md` in `cursor-collections`

**Acceptance Criteria**:
- [ ] GIVEN the template WHEN used in a monorepo THEN it includes areas/paths, role responsibilities, framework references, and project-specific override section
- [ ] GIVEN the template WHEN read THEN it contains no Cursor-only MCP or `@` prompt instructions without neutral equivalents
- [ ] GIVEN install/bootstrap WHEN run THEN consumers receive the template pre-filled with placeholders for project specifics

**High-Level Technical Notes**: Replaces minimal stub in current `agent-collections/AGENTS.md`

**Priority**: High

### Story 4.2: Publish reference AGENTS.md for agent-collections

**User Story**: As a framework consumer, I want the `agent-collections` repository itself to demonstrate a complete `AGENTS.md` so that I can copy the pattern into my project.

**Source**: BRD WF-04; current stub `agent-collections/AGENTS.md`

**Acceptance Criteria**:
- [ ] GIVEN the `agent-collections` repo WHEN opened THEN `AGENTS.md` describes framework areas, maintainer roles, adapter locations, and install entry points
- [ ] GIVEN a new consumer WHEN they read reference `AGENTS.md` THEN they understand how to customize the project-specific section without breaking framework symlinks or generated files
- [ ] GIVEN multiple agents WHEN any loads `AGENTS.md` THEN it serves as the agreed context map (RAG / session bootstrap)

**High-Level Technical Notes**: None

**Priority**: High

---

## Work Stream 5: Distribution & Replication

**Business Description**: Make the framework deployable to any enterprise project in under five minutes with selectable modules, replacing manual file copying and sibling-repo symlinks.

**Success Criteria**:
- `agent-collections` is self-contained (WF-05.1)
- Install mechanism supports module selection (WF-05.2)
- Bash/CLI wizard selects **AI agent adapter(s)** and **MCP servers** for the target project
- MCP and legacy install capabilities are ported or superseded

### Story 5.1: Bootstrap self-contained agent-collections repository

**User Story**: As a framework maintainer, I want `agent-collections` to be a complete, self-sufficient source template so that consumers do not depend on a sibling `cursor-collections` checkout.

**Source**: BRD WF-05.1; GitHub repo https://github.com/PiotrNie-Eversis/agent-collections; current symlink scaffold

**Acceptance Criteria**:
- [ ] GIVEN a fresh clone of `agent-collections` WHEN inspected THEN core, adapters, scripts, and documentation exist without symlinks to `cursor-collections`
- [ ] GIVEN the repository WHEN compared to BRD THEN it satisfies WF-01 through WF-04 deliverables at minimum viable level
- [ ] GIVEN GitHub repository WHEN published THEN README explains purpose, layout, and quick start

**High-Level Technical Notes**: Removes current `../../cursor-collections` symlink dependency

**Priority**: Critical

### Story 5.2: Deliver multi-tool installation mechanism

**User Story**: As a tech lead onboarding a new project, I want to initialize Agent Collections in under five minutes so that my team can adopt the standard without manual configuration.

**Source**: BRD Filar 3 (< 5 min deployment); WF-05; legacy `setup-cursor-local.sh`; stakeholder Q5 — agent + MCP selection

**Acceptance Criteria**:
- [ ] GIVEN a new or existing project WHEN the install command runs THEN core, selected adapters, ignore files, and `AGENTS.md` template are applied
- [ ] GIVEN installation WHEN timed on a reference project THEN complete setup takes under five minutes excluding network clone
- [ ] GIVEN install modes WHEN documented THEN at least local and vendor (submodule/copy) paths are supported analogous to legacy script
- [ ] GIVEN interactive or flag-driven install WHEN completed THEN the project records which **AI agent adapter(s)** and **MCP servers** were selected (for upgrade/sync later)

**High-Level Technical Notes**: Generalize `setup-cursor-local.sh` to multi-tool; agent/MCP wizard detailed in Story 5.6

**Priority**: Critical

### Story 5.3: Implement modular deployment profiles

**User Story**: As a tech lead, I want to choose domain modules (Frontend-only, Backend-only, Fullstack Monorepo) independently from which AI agents the project uses so that teams receive the right rules and adapters without coupling domain to a single tool.

**Source**: BRD WF-05.2; stakeholder Q5

**Acceptance Criteria**:
- [ ] GIVEN install prompts or flags WHEN the user selects Frontend-only THEN only frontend core domains are deployed (adapter choice remains a separate axis — Story 5.6)
- [ ] GIVEN Backend-only selection WHEN install completes THEN backend core domains are deployed without the full frontend skill catalog
- [ ] GIVEN Fullstack Monorepo selection WHEN install completes THEN all domains are deployed with monorepo scoping defaults
- [ ] GIVEN a domain profile WHEN combined with agent selection THEN only adapters chosen in Story 5.6 are generated/installed for that profile

**High-Level Technical Notes**: Domain profile ≠ agent choice; both axes required at install

**Priority**: High

### Story 5.4: Port framework MCP server to agent-collections

**User Story**: As a Cursor user, I want the eversis-collections MCP server available from `agent-collections` so that skill discovery and runtime tools continue to work after migration.

**Source**: Codebase analysis — `mcp/eversis-collections-mcp/` in `cursor-collections`; `agent-collections/.cursor/mcp.json`

**Acceptance Criteria**:
- [ ] GIVEN MCP server source WHEN ported THEN it resolves skills from the new core path layout
- [ ] GIVEN `.cursor/mcp.json` in a consumer project WHEN configured THEN MCP starts using `agent-collections` home without `cursor-collections` env var
- [ ] GIVEN skill list tools WHEN invoked THEN all ported skills from Story 1.5 are discoverable

**High-Level Technical Notes**: Update `CURSOR_COLLECTIONS_HOME` or successor variable naming

**Priority**: High

### Story 5.5: Document consumer upgrade path from central framework

**User Story**: As a project maintainer with an installed framework, I want clear upgrade steps when `agent-collections` releases a new version so that I stay current with minimal risk.

**Source**: BRD WNF-02; Story 1.6 upgrade contract

**Acceptance Criteria**:
- [ ] GIVEN an installed consumer WHEN a minor framework version is published THEN upgrade steps are documented and tested on a sample project
- [ ] GIVEN project-local customizations WHEN upgrading THEN the process preserves `eversis-project-stack`, `docs/context/`, and `docs/specs/` artifacts
- [ ] GIVEN upgrade documentation WHEN followed THEN regenerated adapters match the new core without orphaned legacy files
- [ ] GIVEN a consumer with a recorded install selection (agents, MCP servers, domain profile) WHEN upgrade/sync runs THEN the process reuses that selection by default (unless the user explicitly changes it)
- [ ] GIVEN the recorded selection file is missing or corrupt WHEN upgrade runs THEN the process fails safely with guidance to re-run the install wizard — it does not silently invent a full multi-agent install

**High-Level Technical Notes**: Pairs with Story 1.6 and install selection from Stories 5.2 / 5.6

**Priority**: Medium

### Story 5.6: Interactive bash install wizard — AI agent and MCP selection

**User Story**: As a tech lead setting up a project, I want the bash installer to ask which AI agent(s) will be used and which MCP servers to enable so that the project gets the right adapters and tool integrations without post-install manual wiring.

**Source**: Stakeholder feedback (2026-07-30); legacy `setup-cursor-local.sh` MCP prompt (`--mcp-servers`, `mcp-prompt.sh`); BRD Filar 2–3 / WF-05

**Acceptance Criteria**:
- [ ] GIVEN interactive install WHEN started THEN the wizard prompts for **AI agent adapter(s)** with at least: Cursor only, Claude Code only, Cursor + Claude Code, OpenCode placeholder (future), Multi-agent (all available)
- [ ] GIVEN agent selection WHEN confirmed THEN only corresponding adapter outputs are installed (e.g. Cursor → `.cursor/rules` + Cursor ignore; Claude → `CLAUDE.md` + `.claudeignore`; multi → combined set with isolation files)
- [ ] GIVEN interactive install WHEN MCP step runs THEN the user can select from the curated MCP server catalog (extend legacy `mcp-server-list.json` / `--mcp-servers`) and merge into the tool-appropriate config (e.g. `.cursor/mcp.json` for Cursor)
- [ ] GIVEN `--non-interactive` WHEN flags are provided THEN `--agents` (or equivalent) and `--mcp-servers` reproduce the same outcome without prompts
- [ ] GIVEN install complete WHEN summarized THEN the console reports selected agents, MCP servers, domain profile, and vendor/link mode
- [ ] GIVEN a project that later adds an agent WHEN re-running install/sync with additional `--agents` THEN missing adapters are added without wiping prior MCP or project-owned config
- [ ] GIVEN install fails after partial changes WHEN the wizard exits THEN it lists completed vs failed steps and points to recovery (re-run same selections, or documented rollback)
- [ ] GIVEN a re-run with the same agent/MCP/profile selections WHEN prior steps already succeeded THEN those steps are skipped or reapplied safely without duplicating or corrupting config
- [ ] GIVEN a previously installed agent WHEN re-run omits it THEN either remove generated adapter outputs with explicit confirm, or document removal as manual — never leave stale adapters undocumented
- [ ] GIVEN MCP set changes WHEN re-run completes THEN config matches the new set (no orphaned servers unless user opts to keep them)
- [ ] GIVEN the user selects an agent whose adapter is not yet available in this framework version WHEN install runs THEN the wizard blocks that choice (or offers placeholder-only with explicit warning) and does not claim a full adapter was installed
- [ ] GIVEN Multi-agent or OpenCode placeholder WHEN only a subset of adapters is shipped THEN the summary lists what was installed vs deferred

**High-Level Technical Notes**: Extends legacy interactive MCP selection; agent axis is new. Prefer bash wizard parity with existing `setup-cursor-local.sh` UX.

**Priority**: Critical

---

## Work Stream 6: Documentation & Validation

**Business Description**: Complete the migration with guides, reference documentation, and proof that the framework works in a real enterprise monorepo with measurable context efficiency.

**Success Criteria**:
- Migration guide lives in `agent-collections` and explains cutover from Cursor Collections without linking the two doc sites
- Docusaurus site runs from `agent-collections` with Agent Collections branding; **no documentation coupling** to `cursor-collections`
- Pilot deployment succeeds in the **EOG** monorepo
- Context reduction target (WNF-03) is measured or estimated with evidence

### Story 6.1: Write migration guide from Cursor Collections

**User Story**: As a team already on Cursor Collections, I want a step-by-step migration guide (published in Agent Collections) so that I can move to Agent Collections without losing project context or custom rules.

**Source**: BRD §6 Phase 3; resolved Q3 — separate distribution; Q6 — fully separated documentation

**Acceptance Criteria**:
- [ ] GIVEN an existing `cursor-collections` consumer WHEN following the Agent Collections migration guide THEN they end on `agent-collections` with equivalent or improved multi-agent capability
- [ ] GIVEN the guide WHEN it covers rollback THEN teams can revert if critical gaps are found during pilot
- [ ] GIVEN custom project rules WHEN migrating THEN the guide explains what stays local vs what becomes core vs generated adapter output
- [ ] GIVEN separate distribution channels WHEN documented THEN `cursor-collections` and `agent-collections` are described as independent products — the guide does **not** establish ongoing documentation links, redirects, or shared doc portals between the two repositories

**High-Level Technical Notes**: Migration guide is authored and hosted only under `agent-collections`; no cross-repo doc channel

**Priority**: High

### Story 6.2: Publish README and getting-started documentation

**User Story**: As a new adopter, I want README and getting-started docs in `agent-collections` so that I understand architecture, install, and daily workflow without reading the full BRD.

**Source**: BRD §6 Phase 3 (complete README and migration guide); legacy `documentation/cursor-collection.md` and Docusaurus site

**Acceptance Criteria**:
- [ ] GIVEN the repository README WHEN read THEN it explains vision, core/adapters model, install command, and links to migration guide
- [ ] GIVEN getting-started doc WHEN followed THEN a developer completes first successful install on a sample project
- [ ] GIVEN documentation WHEN compared to BRD THEN all WF requirements are traceable to a doc section or story deliverable

**High-Level Technical Notes**: Repo-local markdown docs; full Docusaurus site covered in Story 6.4

**Priority**: Medium

### Story 6.4: Migrate and rebrand Docusaurus documentation site

**User Story**: As a framework adopter, I want the full Agent Collections documentation site in `agent-collections` so that guides, skills catalog, and workflow docs reflect the multi-agent brand and live alongside the SSOT repo.

**Source**: Resolved Q1; legacy `website/` and `documentation/cursor-collection.md` in `cursor-collections`

**Acceptance Criteria**:
- [ ] GIVEN the Docusaurus site in `cursor-collections` WHEN migrated THEN it runs from `agent-collections/website/` with equivalent or improved navigation and content coverage
- [ ] GIVEN all site content WHEN reviewed THEN references to "Cursor Collections" are rebranded to "Agent Collections" (titles, URLs where applicable, getting-started paths, framework naming)
- [ ] GIVEN the multi-agent architecture WHEN documented on the site THEN core/adapters model, Claude Code, and isolation strategy are explained alongside Cursor workflows
- [ ] GIVEN deployment configuration WHEN migrated THEN hosting (e.g. Vercel) points to `agent-collections` and the site builds successfully from the new repo
- [ ] GIVEN documentation separation policy WHEN the site ships THEN Agent Collections docs contain **no** redirects, deep-links, or "see also" channels into `cursor-collections` documentation (and vice versa is out of scope for this story — legacy docs remain independent)

**High-Level Technical Notes**: Fully separated documentation; no cross-repo doc pointers (stakeholder Q6)

**Priority**: High

### Story 6.3: Pilot deployment and context isolation validation

**User Story**: As an enterprise stakeholder, I want a pilot deployment in the EOG monorepo with measured context reduction so that I have confidence the standard works before wide rollout.

**Source**: BRD §6 Phase 3; resolved Q2 — EOG pilot; WNF-03; Jira DHI-515

**Acceptance Criteria**:
- [ ] GIVEN the **EOG** monorepo (`eog` — `portal/` frontend, `cms/` backend) WHEN Agent Collections is installed THEN Frontend (Cursor) and Backend (Claude Code) teams operate without reported context collisions for an agreed pilot period
- [ ] GIVEN EOG's existing `cursor-collections` install (`scripts/setup-cursor-local.sh`) WHEN migrated to Agent Collections THEN the pilot documents upgrade steps and validates no regression in daily Cursor workflows during transition
- [ ] GIVEN baseline unscoped context size WHEN compared to scoped install THEN documented evidence shows ≥30% reduction in loaded context at session start OR a justified estimate with measurement plan
- [ ] GIVEN pilot completion WHEN reviewed THEN findings feed backlog fixes, migration guide updates, and EOG-specific notes in `docs/context/eog/` if applicable

**High-Level Technical Notes**: EOG is the designated enterprise monorepo pilot per stakeholder decision 2026-07-30

**Priority**: Medium

---

## Dependencies

| Task | Depends On | Type | Notes |
|------|-----------|------|-------|
| Story 1.3–1.5 | Story 1.1, 1.2 | Blocked by | Inventory and structure before extraction |
| Story 1.7 | Story 1.3 | Blocked by | Delivery standard builds on orchestration core rules |
| Story 1.6 | Story 1.5 | Blocked by | Upgrade contract needs ported catalog |
| Story 2.1 | Story 1.2 | Blocked by | Mapping spec requires core structure |
| Story 2.2–2.3 | Story 2.1, 1.4 | Blocked by | Adapters need core rules and mapping spec |
| Story 2.5 | Story 2.2, 2.3 | Blocked by | Sync tooling generates existing adapters |
| Story 3.2 | Story 3.1 | Blocked by | Ignore files follow isolation strategy |
| Story 3.3 | Story 2.2, 2.3, 5.3 | Blocked by | Glob scoping needs adapters and profiles |
| Story 4.2 | Story 4.1 | Blocked by | Reference file uses template |
| Story 5.1 | Story 1.5, 2.2 | Blocked by | Self-contained repo needs core + Cursor adapter minimum |
| Story 5.2 | Story 5.1, 2.5, 3.2, 4.1 | Blocked by | Installer bundles adapters, ignores, AGENTS template |
| Story 5.3 | Story 5.2 | Blocked by | Profiles extend installer |
| Story 5.6 | Story 5.2, 2.2, 2.3 | Blocked by | Wizard needs base installer + adapter outputs to generate |
| Story 5.3 | Story 5.6 | Related to | Domain profile and agent selection are independent install axes |
| Story 5.4 | Story 1.5 | Blocked by | MCP resolves ported skills |
| Story 5.5 | Story 1.6, 5.2 | Blocked by | Consumer upgrade needs contract + installer |
| Story 6.1 | Story 5.1 | Blocked by | Migration guide documents actual layout |
| Story 6.4 | Story 5.1, 6.2 | Blocked by | Site content depends on stable repo layout and README/getting-started |
| Story 6.3 | Story 5.2, 5.3, 5.6, 3.3 | Blocked by | Pilot requires working install, wizard, and scoping |
| Work Stream 2 | Work Stream 1 | Blocked by | Adapters consume core |
| Work Stream 5 | Work Streams 1–4 | Blocked by | Distribution packages prior deliverables |
| Work Stream 6 | Work Stream 5 | Blocked by | Validation needs deployable framework |

## Assumptions

| # | Assumption | Confidence | Impact if Wrong |
|---|-----------|------------|-----------------|
| 1 | DHI-515 remains the single Jira Epic; work streams become Stories linked to it (not sub-epics) | High | Jira structure would need reformatting |
| 2 | `.ai/` is the preferred core directory name unless implementation chooses an equivalent | Medium | Story 1.2 acceptance criteria need path update |
| 3 | Cursor and Claude Code are the two primary adapters for MVP; OpenCode is placeholder only | High | Scope expands if OpenCode MVP is required |
| 4 | MCP server remains part of the Cursor workflow deliverable | High | Story 5.4 descoped; Cursor skill discovery breaks |
| 5 | EOG (`eog` repo) is the designated Phase 3 pilot monorepo | High | Story 6.3 scoped to EOG layout (`portal/`, `cms/`) |
| 6 | `cursor-collections` remains a separate Cursor-only **code/distribution** channel; **documentation is fully separated** (no cross-repo doc links/redirects) | High | Stories 6.1, 6.4; S-05 rejected |
| 8 | Bash installer has two independent selection axes: **AI agent adapter(s)** and **MCP servers**, plus domain profile (Frontend / Backend / Fullstack) | High | Story 5.6; Stories 5.2–5.3 updated |

## Out of Scope

Items explicitly excluded from this task breakdown:
- Full OpenCode adapter implementation (placeholder only per BRD WF-02.3)
- Rewriting rule content — extraction and neutralization only
- Deprecation or archival of `cursor-collections` (remains separate Cursor distribution channel)
- Cross-repository documentation links, redirects, or shared doc portals between `agent-collections` and `cursor-collections`
- EOG product feature work beyond framework install/isolation validation
- Sprint planning, story points, and release dates

## Resolved Decisions (2026-07-30)

| # | Question | Decision | Affected stories |
|---|----------|----------|------------------|
| Q1 | Docusaurus site | Migrate to `agent-collections`; rebrand Cursor Collections → Agent Collections | 6.2, **6.4** (new) |
| Q2 | Pilot monorepo | **EOG** — `eog` repo (`portal/`, `cms/`, existing Cursor Collections consumer) | 6.3 |
| Q3 | `cursor-collections` fate | **Separate Cursor-specific distribution channel** (code/install coexist; not deprecated) | 6.1 |
| Q6 | Documentation coupling | **Fully separated** — no pointers, redirects, or doc channels between `agent-collections` and `cursor-collections` | 6.1, 6.4; S-05 rejected |
| Q4 | Delivery standard | **Full spec-driven development mandatory** for every DHI-515 story; Jira descriptions include Delivery Standard section | All stories; Story 1.7 |
| Q5 | Bash install wizard | Select **AI agent adapter(s)** + **MCP servers** (+ domain profile); interactive and `--non-interactive` flags | Stories 5.2, 5.3, **5.6** |
