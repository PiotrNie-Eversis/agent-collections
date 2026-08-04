# DHI-516 — Asset inventory (`cursor-collections`)

## Metadata

| Field | Value |
|-------|-------|
| Jira | [DHI-516](https://eversis.atlassian.net/browse/DHI-516) |
| Source repo | `/Users/piotrniemirski/Documents/Projects/cursor-collections` |
| Inventory date | 2026-08-04 |
| Taxonomy | Core \| Cursor-specific \| Deprecated (from `dhi-516.research.md`) |
| Scope note | `node_modules` and build `dist` artifacts are **not** inventoried file-by-file |

## Summary counts

| Category | Count |
|----------|------:|
| Rules | 8 |
| Skills | 45 |
| Prompts (public) | 16 |
| Prompts (internal) | 12 |
| Prompts (total) | 28 |
| Commands | 8 |
| Scripts (excl. node_modules) | see Scripts section |
| MCP components | see MCP section |
| Docs entrypoints + website/docs files | 4 entrypoints + **120** `website/docs` md/mdx |

## Rules

| Path | Category | Purpose | Classification | Target hint |
|------|----------|---------|----------------|-------------|
| `.cursor/rules/eversis-accessibility.mdc` | rule | Accessibility expectations for UI work. | Core | adapters/cursor/ (packaging) + .ai/rules/ (neutral content) |
| `.cursor/rules/eversis-agent-core.mdc` | rule | Core agent lifecycle (Ideate→Implement→Review), skills policy, hard limits. | Core | adapters/cursor/ (packaging) + .ai/rules/ (neutral content) |
| `.cursor/rules/eversis-ba-docs-planner.mdc` | rule | BA Docs planner role for Word release docs workflow. | Core | adapters/cursor/ (packaging) + .ai/rules/ (neutral content) |
| `.cursor/rules/eversis-ba-docs-writer.mdc` | rule | BA Docs writer role for Word release docs workflow. | Core | adapters/cursor/ (packaging) + .ai/rules/ (neutral content) |
| `.cursor/rules/eversis-code-reviewer.mdc` | rule | Code review standards and forbidden changes during review. | Core | adapters/cursor/ (packaging) + .ai/rules/ (neutral content) |
| `.cursor/rules/eversis-engineering-manager.mdc` | rule | Engineering Manager attach rule for @eversis-implement orchestration. | Core | adapters/cursor/ (packaging) + .ai/rules/ (neutral content) |
| `.cursor/rules/eversis-project-stack.mdc` | rule | Per-project stack/skills policy template (consumer-owned, not framework SSOT). | Core | consumer template / not framework SSOT |
| `.cursor/rules/eversis-testing-and-terminal.mdc` | rule | Post-change lint/test/typecheck discipline. | Core | adapters/cursor/ (packaging) + .ai/rules/ (neutral content) |

## Skills

| Path | Category | Purpose | Classification | Target hint |
|------|----------|---------|----------------|-------------|
| `.cursor/skills/eversis-accessibility-auditing/` | skill | WCAG 2.2 Level AA accessibility auditing using POUR methodology, automated tools, and manual testing checklists. Generates technical audit reports and business-facing summaries. Us… | Core | .ai/skills/ |
| `.cursor/skills/eversis-analyzing-bugs/` | skill | Quality health report creation from Jira data — defect density by feature area, regression risk indicators, bug age analysis, creation vs resolution trends, and recommended testing… | Core | .ai/skills/ |
| `.cursor/skills/eversis-analyzing-regression-risk/` | skill | Regression scope analysis from code changes, Jira context, and documentation. Produces risk-classified regression checklists and structured test suites. Use when analyzing regressi… | Core | .ai/skills/ |
| `.cursor/skills/eversis-architecture-designing/` | skill | Design the architecture to solve a given task. Propose the solutions to be used to deliver the task following the best practices and standards. | Core | .ai/skills/ |
| `.cursor/skills/eversis-ba-docs-planner/` | skill | Plan Word .docx chapter updates from a Jira release + Confluence rules. BA Docs (Word) planner — produces docs-update-plan.md; not repo markdown. | Core | .ai/skills/ |
| `.cursor/skills/eversis-ba-docs-writer/` | skill | Apply an approved docs-update-plan.md to a Word .docx file via eversis-collections MCP. BA Docs (Word) channel only — not README, CHANGELOG, or website markdown (use eversis-repo-d… | Core | .ai/skills/ |
| `.cursor/skills/eversis-code-reviewing/` | skill | Perform code review. Quality analysis. Acceptance criteria verification. Best practices review. | Core | .ai/skills/ |
| `.cursor/skills/eversis-codebase-analysing/` | skill | Analyse the codebase of the system. Look for dependencies. Understand how the business logic is implemented. Look for duplications. | Core | .ai/skills/ |
| `.cursor/skills/eversis-creating-agents/` | skill | Create Cursor project rules for roles: .cursor/rules/eversis-*.mdc (YAML: description, globs, alwaysApply). Maps legacy agent-identity content into rule bodies; use with skills and… | Core | .ai/skills/ |
| `.cursor/skills/eversis-creating-implementation-plans/` | skill | Creates implementation plan documents (*.plan.md) that break a designed solution into phases and verifiable tasks. Owns the plan template (plan.example.md), plan structure rules, a… | Core | .ai/skills/ |
| `.cursor/skills/eversis-creating-instructions/` | skill | Create project instructions for Cursor: AGENTS.md, .cursor/rules/*.mdc, optional per-folder RULE.md. No GitHub copilot-instructions.md in this framework. | Core | .ai/skills/ |
| `.cursor/skills/eversis-creating-prompts/` | skill | Create attachable Cursor prompts: .cursor/prompts/public/internal/eversis-*.md (Docusaurus frontmatter + body). Replaces legacy .github/prompts/*.prompt.md. Use when creating or re… | Core | .ai/skills/ |
| `.cursor/skills/eversis-creating-skills/` | skill | Create new Cursor Agent Skills (SKILL.md) under .cursor/skills/eversis-*. Provides naming (gerund), description, body structure, progressive disclosure, templates, validation. For … | Core | .ai/skills/ |
| `.cursor/skills/eversis-designing-multi-cloud-architecture/` | skill | Design multi-cloud architectures using a decision framework to select and integrate services across AWS, Azure, and GCP. Use when building multi-cloud systems, avoiding vendor lock… | Core | .ai/skills/ |
| `.cursor/skills/eversis-e2e-testing/` | skill | E2E testing patterns, verification procedures, and CI readiness checklists using Playwright. Use for writing, debugging, or reviewing end-to-end tests, fixing flaky tests, creating… | Core | .ai/skills/ |
| `.cursor/skills/eversis-engineering-prompts/` | skill | LLM prompt engineering patterns: structure, optimization, security, templates, evaluation, and anti-patterns. Use when designing, writing, optimizing, or reviewing prompts for LLM … | Core | .ai/skills/ |
| `.cursor/skills/eversis-ensuring-accessibility/` | skill | WCAG 2.1 AA compliance, semantic HTML, ARIA patterns, keyboard navigation, focus management, screen reader support, and color contrast requirements. Use when implementing accessibl… | Core | .ai/skills/ |
| `.cursor/skills/eversis-fine-handoff/` | skill | Mandatory QA comment draft after Fine (Implement handoff). Agent outputs a labeled draft; human approves or rewrites; optionally post to Jira via Atlassian MCP only after explicit … | Core | .ai/skills/ |
| `.cursor/skills/eversis-functional-testing/` | skill | Shared QA foundations — severity matrix, bug report template, and test plan templates. Referenced by eversis-planning-tests, eversis-analyzing-regression-risk, and eversis-verifyin… | Core | .ai/skills/ |
| `.cursor/skills/eversis-implementation-gap-analysing/` | skill | Implementation gap analysis. Verify what has to be implemented. Verify what was implemented. Compare plan to current state. | Core | .ai/skills/ |
| `.cursor/skills/eversis-implementing-backend/` | skill | Backend service implementation patterns, standards, and procedures. Use for building REST/GraphQL APIs, implementing CRUD endpoints, database handling, authentication, testing stra… | Core | .ai/skills/ |
| `.cursor/skills/eversis-implementing-ci-cd/` | skill | CI/CD pipeline design patterns and deployment strategies. Use when designing pipelines, implementing deployment strategies, or setting up automated delivery. | Core | .ai/skills/ |
| `.cursor/skills/eversis-implementing-filters/` | skill | URL-synced filter lists for Next.js (App Router preferred) with shareable query state aligned to REST list APIs. Use when AC requires public/admin list pages with filters persisted… | Core | .ai/skills/ |
| `.cursor/skills/eversis-implementing-forms/` | skill | Form architecture, schema-based validation, field composition, error handling, multi-step form flows, and accessible form patterns. Use when building forms, implementing validation… | Core | .ai/skills/ |
| `.cursor/skills/eversis-implementing-frontend/` | skill | Frontend component patterns, composition, design token integration, barrel file organization, error handling, and Figma-to-code workflow. Use when implementing UI components, trans… | Core | .ai/skills/ |
| `.cursor/skills/eversis-implementing-kubernetes/` | skill | Kubernetes deployment patterns, Helm charts, and cluster management. Use when deploying applications to K8s, designing workload configurations, implementing scaling strategies, or … | Core | .ai/skills/ |
| `.cursor/skills/eversis-implementing-observability/` | skill | Observability patterns for logging, monitoring, alerting, and distributed tracing. Use when implementing metrics collection, log aggregation, alerting rules, or distributed tracing… | Core | .ai/skills/ |
| `.cursor/skills/eversis-implementing-terraform-modules/` | skill | Build reusable Terraform modules for AWS, Azure, and GCP infrastructure following infrastructure-as-code best practices. Use when creating infrastructure modules, standardizing clo… | Core | .ai/skills/ |
| `.cursor/skills/eversis-jira-task-formatting/` | skill | Transform extracted epics and user stories into Jira-ready format following a benchmark template. Handles field mapping, formatting for Jira markdown compatibility, two-gate user r… | Core | .ai/skills/ |
| `.cursor/skills/eversis-managing-secrets/` | skill | Secrets management patterns for cloud and Kubernetes environments. Use when implementing secure credential storage, rotation, or CI/CD authentication. | Core | .ai/skills/ |
| `.cursor/skills/eversis-optimizing-cloud-cost/` | skill | Optimize cloud costs through resource rightsizing, tagging strategies, reserved instances, and spending analysis. Use when reducing cloud expenses, analyzing infrastructure costs, … | Core | .ai/skills/ |
| `.cursor/skills/eversis-optimizing-frontend/` | skill | Frontend rendering optimization, code splitting, memoization strategies, bundle size control, asset optimization, and memory management. Use when optimizing component rendering, re… | Core | .ai/skills/ |
| `.cursor/skills/eversis-orchestrating-implementation/` | skill | Owns the canonical implementation orchestration workflow for feature implementation, including flow selection, planning readiness, delegated execution routing, todo control, and re… | Core | .ai/skills/ |
| `.cursor/skills/eversis-planning-tests/` | skill | Test plan generation from acceptance criteria with edge-case detection, environment matrix, and template-enforced output. Use when creating test plans, detecting edge cases, or ext… | Core | .ai/skills/ |
| `.cursor/skills/eversis-reviewing-frontend/` | skill | Frontend-specific code review criteria, component anti-patterns, hooks quality, rendering correctness, accessibility and performance spot-checks, and module organization issues. Us… | Core | .ai/skills/ |
| `.cursor/skills/eversis-sql-and-database-understanding/` | skill | SQL writing and database engineering patterns, standards, and procedures. Use for designing database schemas, writing performant SQL queries, normalisation strategies, indexing, jo… | Core | .ai/skills/ |
| `.cursor/skills/eversis-task-analysing/` | skill | Analyse task description, performs gap analysis, expand the context for the task, analyse the current state of the system in the context of the task, helps build PRD, creates a con… | Core | .ai/skills/ |
| `.cursor/skills/eversis-task-extracting/` | skill | Identify and structure epics and user stories from workshop materials (cleaned transcripts, Figma designs, codebase analysis, and other documents). Produces a business-oriented tas… | Core | .ai/skills/ |
| `.cursor/skills/eversis-task-quality-reviewing/` | skill | Analyze extracted epics and user stories for quality gaps, missing edge cases, and improvement opportunities. Runs domain-agnostic analysis passes, optionally enriches findings wit… | Core | .ai/skills/ |
| `.cursor/skills/eversis-technical-context-discovering/` | skill | Discover and establish technical context before implementing any feature. Prioritize project instructions, existing codebase patterns, and external documentation in that order. Use… | Core | .ai/skills/ |
| `.cursor/skills/eversis-transcript-processing/` | skill | Clean raw workshop or meeting transcripts from small talk, filler words, and off-topic tangents. Extract and structure business-relevant content into a standardized format with dis… | Core | .ai/skills/ |
| `.cursor/skills/eversis-ui-verifying/` | skill | UI verification criteria, structure checklists, severity definitions, and tolerance rules for comparing implementations against Figma designs. Use for verifying UI matches design, … | Core | .ai/skills/ |
| `.cursor/skills/eversis-verifying-acceptance-criteria/` | skill | Compare implementation against stated Acceptance Criteria to identify gaps, deviations, or unimplemented requirements. Use when verifying implementation completeness against AC or … | Core | .ai/skills/ |
| `.cursor/skills/eversis-writing-hooks/` | skill | Custom hook and composable patterns — naming, composition, stable return shapes, lifecycle cleanup, and testing strategies. Use when writing reusable logic units (React hooks, Vue … | Core | .ai/skills/ |
| `.cursor/skills/eversis-writing-repo-documentation/` | skill | Authors and updates repository documentation — README, CHANGELOG, in-repo docs, and the published documentation site. Covers structure, docs-site build expectations, and the write-… | Core | .ai/skills/ |

## Prompts

Framework convention (preserve in Agent Collections / DHI-517+): **`public/`** = user-facing entrypoints (`@` / slash commands); **`internal/`** = EM-routed delegation prompts (not primary user entrypoints).

### Public (16)

| Path | Category | Purpose | Classification | Target hint |
|------|----------|---------|----------------|-------------|
| `.cursor/prompts/public/eversis-analyze-aws-costs.md` | prompt | User-facing cost analysis (AWS). | Core | .ai/prompts/public/ |
| `.cursor/prompts/public/eversis-analyze-gcp-costs.md` | prompt | User-facing cost analysis (GCP). | Core | .ai/prompts/public/ |
| `.cursor/prompts/public/eversis-analyze-materials.md` | prompt | User-facing Ideate / materials → backlog. | Core | .ai/prompts/public/ |
| `.cursor/prompts/public/eversis-audit-infrastructure.md` | prompt | User-facing infrastructure audit. | Core | .ai/prompts/public/ |
| `.cursor/prompts/public/eversis-ba-docs-planner.md` | prompt | User-facing BA docs planning. | Core | .ai/prompts/public/ |
| `.cursor/prompts/public/eversis-ba-docs-writer.md` | prompt | User-facing BA docs writing. | Core | .ai/prompts/public/ |
| `.cursor/prompts/public/eversis-create-custom-agent.md` | prompt | User-facing framework customization (agent). | Core | .ai/prompts/public/ |
| `.cursor/prompts/public/eversis-create-custom-instructions.md` | prompt | User-facing framework customization (instructions). | Core | .ai/prompts/public/ |
| `.cursor/prompts/public/eversis-create-custom-prompt.md` | prompt | User-facing framework customization (prompt). | Core | .ai/prompts/public/ |
| `.cursor/prompts/public/eversis-create-custom-skill.md` | prompt | User-facing framework customization (skill). | Core | .ai/prompts/public/ |
| `.cursor/prompts/public/eversis-implement.md` | prompt | User-facing Implement orchestration entrypoint. | Core | .ai/prompts/public/ |
| `.cursor/prompts/public/eversis-qa-workflow.md` | prompt | User-facing QA workflow. | Core | .ai/prompts/public/ |
| `.cursor/prompts/public/eversis-repo-docs-writer.md` | prompt | User-facing repo documentation writer. | Core | .ai/prompts/public/ |
| `.cursor/prompts/public/eversis-review-codebase.md` | prompt | User-facing codebase review. | Core | .ai/prompts/public/ |
| `.cursor/prompts/public/eversis-review-ui.md` | prompt | User-facing UI review. | Core | .ai/prompts/public/ |
| `.cursor/prompts/public/eversis-review.md` | prompt | User-facing code review entrypoint. | Core | .ai/prompts/public/ |

### Internal (12)

| Path | Category | Purpose | Classification | Target hint |
|------|----------|---------|----------------|-------------|
| `.cursor/prompts/internal/eversis-deploy-kubernetes.md` | prompt | EM-delegated Kubernetes deploy implementation. | Core | .ai/prompts/internal/ |
| `.cursor/prompts/internal/eversis-engineer-prompt.md` | prompt | EM-delegated generic engineer prompt. | Core | .ai/prompts/internal/ |
| `.cursor/prompts/internal/eversis-implement-common-task.md` | prompt | EM-delegated common-task implementation. | Core | .ai/prompts/internal/ |
| `.cursor/prompts/internal/eversis-implement-e2e.md` | prompt | EM-delegated E2E implementation. | Core | .ai/prompts/internal/ |
| `.cursor/prompts/internal/eversis-implement-observability.md` | prompt | EM-delegated observability implementation. | Core | .ai/prompts/internal/ |
| `.cursor/prompts/internal/eversis-implement-pipeline.md` | prompt | EM-delegated pipeline implementation. | Core | .ai/prompts/internal/ |
| `.cursor/prompts/internal/eversis-implement-terraform.md` | prompt | EM-delegated Terraform implementation. | Core | .ai/prompts/internal/ |
| `.cursor/prompts/internal/eversis-implement-ui-common-task.md` | prompt | EM-delegated UI common-task implementation. | Core | .ai/prompts/internal/ |
| `.cursor/prompts/internal/eversis-implement-ui.md` | prompt | EM-delegated UI implementation. | Core | .ai/prompts/internal/ |
| `.cursor/prompts/internal/eversis-plan.md` | prompt | EM-delegated implementation planning. | Core | .ai/prompts/internal/ |
| `.cursor/prompts/internal/eversis-research.md` | prompt | EM-delegated research / context gathering. | Core | .ai/prompts/internal/ |
| `.cursor/prompts/internal/eversis-review-plan.md` | prompt | EM-delegated plan review. | Core | .ai/prompts/internal/ |

## Commands

| Path | Category | Purpose | Classification | Target hint |
|------|----------|---------|----------------|-------------|
| `.cursor/commands/eversis-analyze-materials.md` | command | Shim to public analyze-materials prompt. | Cursor-specific | adapters/cursor/ (or cursor-collections channel) |
| `.cursor/commands/eversis-ba-docs-planner.md` | command | Shim to public BA docs planner prompt. | Cursor-specific | adapters/cursor/ (or cursor-collections channel) |
| `.cursor/commands/eversis-ba-docs-writer.md` | command | Shim to public BA docs writer prompt. | Cursor-specific | adapters/cursor/ (or cursor-collections channel) |
| `.cursor/commands/eversis-implement.md` | command | Shim to public implement prompt. | Cursor-specific | adapters/cursor/ (or cursor-collections channel) |
| `.cursor/commands/eversis-qa-workflow.md` | command | Shim to public QA workflow prompt. | Cursor-specific | adapters/cursor/ (or cursor-collections channel) |
| `.cursor/commands/eversis-repo-docs-writer.md` | command | Shim to public repo docs writer prompt. | Cursor-specific | adapters/cursor/ (or cursor-collections channel) |
| `.cursor/commands/eversis-review-ui.md` | command | Shim to public UI review prompt. | Cursor-specific | adapters/cursor/ (or cursor-collections channel) |
| `.cursor/commands/eversis-review.md` | command | Shim to public code review prompt. | Cursor-specific | adapters/cursor/ (or cursor-collections channel) |

## Scripts

| Path | Category | Purpose | Classification | Target hint |
|------|----------|---------|----------------|-------------|
| `scripts/check-readme-site-parity.mjs` | script | Checks README vs website docs parity. | Cursor-specific | port/adapt with Agent Collections naming |
| `scripts/lib/setup-cursor-local/build-mcp.sh` | script | Setup-cursor-local shell helper `build-mcp.sh`. | Cursor-specific | evolve → scripts/setup-agent-*.sh (DHI-534/538); keep as migration source |
| `scripts/lib/setup-cursor-local/common.sh` | script | Setup-cursor-local shell helper `common.sh`. | Cursor-specific | evolve → scripts/setup-agent-*.sh (DHI-534/538); keep as migration source |
| `scripts/lib/setup-cursor-local/git-target.sh` | script | Setup-cursor-local shell helper `git-target.sh`. | Cursor-specific | evolve → scripts/setup-agent-*.sh (DHI-534/538); keep as migration source |
| `scripts/lib/setup-cursor-local/gitignore.sh` | script | Setup-cursor-local shell helper `gitignore.sh`. | Cursor-specific | evolve → scripts/setup-agent-*.sh (DHI-534/538); keep as migration source |
| `scripts/lib/setup-cursor-local/gitignore.test.sh` | script | Setup-cursor-local shell helper `gitignore.test.sh`. | Cursor-specific | evolve → scripts/setup-agent-*.sh (DHI-534/538); keep as migration source |
| `scripts/lib/setup-cursor-local/link-framework.sh` | script | Setup-cursor-local shell helper `link-framework.sh`. | Cursor-specific | evolve → scripts/setup-agent-*.sh (DHI-534/538); keep as migration source |
| `scripts/lib/setup-cursor-local/mcp-merge.mjs` | script | Setup-cursor-local Node helper `mcp-merge.mjs`. | Cursor-specific | evolve → scripts/setup-agent-*.sh (DHI-534/538); keep as migration source |
| `scripts/lib/setup-cursor-local/mcp-merge.sh` | script | Setup-cursor-local shell helper `mcp-merge.sh`. | Cursor-specific | evolve → scripts/setup-agent-*.sh (DHI-534/538); keep as migration source |
| `scripts/lib/setup-cursor-local/mcp-prompt-toggle.mjs` | script | Setup-cursor-local Node helper `mcp-prompt-toggle.mjs`. | Cursor-specific | evolve → scripts/setup-agent-*.sh (DHI-534/538); keep as migration source |
| `scripts/lib/setup-cursor-local/mcp-prompt.mjs` | script | Setup-cursor-local Node helper `mcp-prompt.mjs`. | Cursor-specific | evolve → scripts/setup-agent-*.sh (DHI-534/538); keep as migration source |
| `scripts/lib/setup-cursor-local/mcp-prompt.sh` | script | Setup-cursor-local shell helper `mcp-prompt.sh`. | Cursor-specific | evolve → scripts/setup-agent-*.sh (DHI-534/538); keep as migration source |
| `scripts/lib/setup-cursor-local/mcp-server-list.json` | script | Setup-cursor-local config/data `mcp-server-list.json`. | Cursor-specific | evolve → scripts/setup-agent-*.sh (DHI-534/538); keep as migration source |
| `scripts/lib/setup-cursor-local/package-lock.json` | script | Setup-cursor-local config/data `package-lock.json`. | Cursor-specific | evolve → scripts/setup-agent-*.sh (DHI-534/538); keep as migration source |
| `scripts/lib/setup-cursor-local/package.json` | script | Setup-cursor-local config/data `package.json`. | Cursor-specific | evolve → scripts/setup-agent-*.sh (DHI-534/538); keep as migration source |
| `scripts/lib/setup-cursor-local/paths.sh` | script | Setup-cursor-local shell helper `paths.sh`. | Cursor-specific | evolve → scripts/setup-agent-*.sh (DHI-534/538); keep as migration source |
| `scripts/lib/setup-cursor-local/relative-path.mjs` | script | Setup-cursor-local Node helper `relative-path.mjs`. | Cursor-specific | evolve → scripts/setup-agent-*.sh (DHI-534/538); keep as migration source |
| `scripts/lib/setup-cursor-local/scaffolding.sh` | script | Setup-cursor-local shell helper `scaffolding.sh`. | Cursor-specific | evolve → scripts/setup-agent-*.sh (DHI-534/538); keep as migration source |
| `scripts/lib/setup-cursor-local/summary.sh` | script | Setup-cursor-local shell helper `summary.sh`. | Cursor-specific | evolve → scripts/setup-agent-*.sh (DHI-534/538); keep as migration source |
| `scripts/lib/setup-cursor-local/vendor.sh` | script | Setup-cursor-local shell helper `vendor.sh`. | Cursor-specific | evolve → scripts/setup-agent-*.sh (DHI-534/538); keep as migration source |
| `scripts/setup-cursor-local.sh` | script | Primary consumer install script (vendor/link/MCP); Cursor-centric source for multi-agent installer. | Cursor-specific | evolve → scripts/setup-agent-*.sh (DHI-534/538); keep as migration source |
| `scripts/setup-cursor-local.test.sh` | script | Shell tests for setup-cursor-local. | Cursor-specific | evolve → scripts/setup-agent-*.sh (DHI-534/538); keep as migration source |
| `scripts/sync-framework-doc.mjs` | script | Syncs framework documentation. | Cursor-specific | port/adapt with Agent Collections naming |
| `scripts/sync-prompts.mjs` | script | Syncs prompt artifacts between locations. | Cursor-specific | port/adapt with Agent Collections naming |
| `scripts/validate-cursor-markdown-links.mjs` | script | Validates markdown links in Cursor framework docs. | Cursor-specific | port/adapt with Agent Collections naming |
| `scripts/validate-cursor-markdown-links.test.mjs` | script | Tests for markdown link validator. | Cursor-specific | port/adapt with Agent Collections naming |

**Scripts row count (excl. node_modules):** 26

## MCP

| Path | Category | Purpose | Classification | Target hint |
|------|----------|---------|----------------|-------------|
| `mcp/eversis-collections-mcp/package.json` | mcp | Package manifest for eversis-collections MCP server. | Core | mcp/ in agent-collections (DHI-535); resolve skills from .ai/ |
| `mcp/eversis-collections-mcp/README.md` | mcp | MCP package documentation and usage. | Core | mcp/ in agent-collections (DHI-535); resolve skills from .ai/ |
| `mcp/eversis-collections-mcp/src/cli.ts` | mcp | MCP TypeScript/source module `cli.ts`. | Core | mcp/ in agent-collections (DHI-535); resolve skills from .ai/ |
| `mcp/eversis-collections-mcp/src/docx/chapters.ts` | mcp | MCP TypeScript/source module `chapters.ts`. | Core | mcp/ in agent-collections (DHI-535); resolve skills from .ai/ |
| `mcp/eversis-collections-mcp/src/docx/docx-io.ts` | mcp | MCP TypeScript/source module `docx-io.ts`. | Core | mcp/ in agent-collections (DHI-535); resolve skills from .ai/ |
| `mcp/eversis-collections-mcp/src/docx/tools.ts` | mcp | MCP TypeScript/source module `tools.ts`. | Core | mcp/ in agent-collections (DHI-535); resolve skills from .ai/ |
| `mcp/eversis-collections-mcp/src/frontmatter.ts` | mcp | MCP TypeScript/source module `frontmatter.ts`. | Core | mcp/ in agent-collections (DHI-535); resolve skills from .ai/ |
| `mcp/eversis-collections-mcp/src/index.ts` | mcp | MCP TypeScript/source module `index.ts`. | Core | mcp/ in agent-collections (DHI-535); resolve skills from .ai/ |
| `mcp/eversis-collections-mcp/src/repoScripts.ts` | mcp | MCP TypeScript/source module `repoScripts.ts`. | Core | mcp/ in agent-collections (DHI-535); resolve skills from .ai/ |
| `mcp/eversis-collections-mcp/src/resolveRoot.ts` | mcp | MCP TypeScript/source module `resolveRoot.ts`. | Core | mcp/ in agent-collections (DHI-535); resolve skills from .ai/ |
| `mcp/eversis-collections-mcp/src/server.ts` | mcp | MCP TypeScript/source module `server.ts`. | Core | mcp/ in agent-collections (DHI-535); resolve skills from .ai/ |
| `mcp/eversis-collections-mcp/src/skillScripts.ts` | mcp | MCP TypeScript/source module `skillScripts.ts`. | Core | mcp/ in agent-collections (DHI-535); resolve skills from .ai/ |
| `mcp/eversis-collections-mcp/src/skills.ts` | mcp | MCP TypeScript/source module `skills.ts`. | Core | mcp/ in agent-collections (DHI-535); resolve skills from .ai/ |
| `mcp/eversis-collections-mcp/src/validate.ts` | mcp | MCP TypeScript/source module `validate.ts`. | Core | mcp/ in agent-collections (DHI-535); resolve skills from .ai/ |

**Note:** `node_modules/` and build `dist/` under the MCP package are excluded from per-file inventory (plan Open Question #3).

## Docs

| Path | Category | Purpose | Classification | Target hint |
|------|----------|---------|----------------|-------------|
| `documentation/cursor-collection.md` | docs | Authoritative framework guide (Parts A–D); migrate/rebrand under Agent Collections (DHI-540). | Core | .ai/ or documentation/ + website (DHI-540); no cross-links to cursor-collections docs |
| `AGENTS.md` | docs | Agent entry / context map (Cursor-leaning today); becomes agnostic template (DHI-531/532). | Core | AGENTS.md template + reference |
| `README.md` | docs | Repository README / getting started for Cursor Collections. | Core | agent-collections README (DHI-541) |
| `CHANGELOG.md` | docs | Framework changelog. | Core | agent-collections CHANGELOG (semver releases) |
| `website/docs/**/*.md(x) (120 files)` | docs | Docusaurus docs site content. First-level entries: agents, for-ctos.md, framework-reference.md, getting-started, integrations, intro.md, prompts, skills, specs, use-cases.md, workflow. Full site migrate/rebrand = DHI-540. | Core | agent-collections/website/ (DHI-540) |

## BRD gaps (WF-01–WF-05)

| WF | Legacy status (`cursor-collections`) | Gap for Agent Collections |
|----|--------------------------------------|---------------------------|
| **WF-01** Core SSOT | No `.ai/`; rules/skills/prompts live under Cursor-centric `.cursor/` | Need neutral core directory and neutralization (DHI-517–520) |
| **WF-02** Adapters | Cursor only (`.mdc`, commands, MCP config) | No Claude `CLAUDE.md` adapter; OpenCode stub missing (DHI-523–527) |
| **WF-03** Isolation | Partial `.cursorignore` only | No synchronized `.claudeignore` / `.opencodeignore` triad (DHI-528–529) |
| **WF-04** AGENTS.md | Present but Cursor-centric | Not agnostic monorepo/role matrix (DHI-531–532) |
| **WF-05** Distribution | `setup-cursor-local.sh` (MCP select, vendor/link) | `agent-collections` not self-contained; no AI-agent selection axis (DHI-533–538) |

## Maintainer review checklist

Verified against live tree at `/Users/piotrniemirski/Documents/Projects/cursor-collections` on **2026-08-04** (agent + maintainer review session).

- [x] Row counts verified against live tree: rules 8, skills 45, prompts 16 public + 12 internal (=28), commands 8
- [x] Prompts keep `public/` vs `internal/` split in inventory and target hints (`.ai/prompts/public|internal/`)
- [x] Classification follows taxonomy (skills default Core; commands Cursor-specific; no invented Deprecated)
- [x] BRD WF-01 through WF-05 gaps reviewed and **accepted** by maintainer
- [x] Ready to start **DHI-517** (`.ai/` structure) using Core-tagged assets as input
- [x] Confirmed inventory source is `cursor-collections` (not `agent-collections` symlinks)

## Changelog

| Date | Change |
|------|--------|
| 2026-08-04 | Initial inventory created for DHI-516 implement |
| 2026-08-04 | Prompts split into Public (16) / Internal (12); target hints → `.ai/prompts/public|internal/` |
| 2026-08-04 | Maintainer checklist: counts, prompt split, taxonomy, source verified; WF accept + DHI-517 gate open |
| 2026-08-04 | Maintainer checklist complete (WF-01–05 accepted; DHI-517 research started) |
