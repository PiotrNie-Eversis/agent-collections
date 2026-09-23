---
sidebar_position: 1
title: Skills Overview
---

# Skills Overview

Agent Collections includes **50 reusable skills** — knowledge modules that provide specialized domain expertise, structured processes, and quality templates. They encode tested best practices for every phase of the product lifecycle. Skills are stored under **`.ai/skills/`** (SSOT). At install time, the setup script mirrors every skill package into a local, host-native path for **both** supported adapters — `.claude/skills/<id>/SKILL.md` for Claude Code and `.cursor/skills/<id>/SKILL.md` for Cursor (symlink or copy, kept in sync on re-run) — so a direct file read works for either host without MCP. Prefer the **`eversis-collections` MCP** server (**`eversis_skills_list`**, **`eversis_skills_get`**, **`eversis_skill_run_script`** for allowlisted per-skill scripts, and related tools) when it's running, after building [`mcp/eversis-collections-mcp/`](../integrations/overview) — the per-host mirror is a plain local-file fallback, not a registration of the folder as Cursor's or Claude Code's native **Agent Skills** UI path.

## How Skills Work

Each skill folder contains a `SKILL.md` file with:

- **Domain-specific guidelines** — Best practices, checklists, and processes.
- **Templates** — Example output formats (e.g., `plan.example.md`, `research.example.md`).
- **Connected skills** — References to other skills that complement or support this one.

When an agent needs specialized procedures, it can pull **`SKILL.md` content** via **MCP** (e.g. `eversis_skills_get`), run **allowlisted automation** under a skill via **`eversis_skill_run_script`** when one is registered for that topic, or follow rules and prompts. Multiple skills can be combined for tasks spanning different domains.

**OSS consumers:** the full skill tree is vendored, but **`eversis-project-stack.mdc` § Agent skills policy** defines which skills apply to your project. See [Installation](../../getting-started/installation) and [Framework reference](../../framework) (Agent skills policy).

### Skill classes (framework)

| Class             | Load default                            | Examples                                                        |
| ----------------- | --------------------------------------- | --------------------------------------------------------------- |
| Universal         | When task-relevant                      | `eversis-fine-handoff`, `eversis-code-reviewing`                |
| Stack             | When stack rule + task match            | `eversis-implementing-frontend`, `eversis-implementing-backend` |
| Domain / optional | Only when stack policy or plan requires | `eversis-implementing-filters`, `eversis-ba-docs-*`             |

## Available Skills

> **Note:** The skill links below are for human browsing and overview only. Agents must use the `eversis-collections` MCP tools or read the `.ai/skills/*/SKILL.md` files directly for normative procedures.

### 📋 Ideate skills

- **[eversis-task-analysing](./task-analysis)** — gathers context and research for a task.
- **[eversis-transcript-processing](./transcript-processing)** — cleans and structures raw workshop transcripts.
- **[eversis-task-extracting](./task-extraction)** — extracts epics and stories from workshop materials.
- **[eversis-task-quality-reviewing](./task-quality-review)** — runs quality analysis on extracted task lists.
- **[eversis-jira-task-formatting](./jira-task-formatting)** — formats and pushes tasks to Jira.
- **[eversis-ba-docs-planner](./ba-docs-planner)** — plans Word `.docx` chapter updates from a Jira release.
- **[eversis-ba-docs-writer](./ba-docs-writer)** — applies an approved docs-update-plan to a Word `.docx` file.

| Skill                                                    | Description                                                              | Used By                        |
| -------------------------------------------------------- | ------------------------------------------------------------------------ | ------------------------------ |
| [eversis-task-analysing](./task-analysis)                | Task context gathering and research                                      | Context Engineer, E2E Engineer |
| [eversis-transcript-processing](./transcript-processing) | Workshop transcript cleaning and structuring                             | Business Analyst               |
| [eversis-task-extracting](./task-extraction)             | Epic and user story extraction from workshop materials                   | Business Analyst               |
| [eversis-task-quality-reviewing](./task-quality-review)  | Quality analysis for extracted task lists                                | Business Analyst               |
| [eversis-jira-task-formatting](./jira-task-formatting)   | Jira-ready task formatting and import/push management                    | Business Analyst               |
| [eversis-ba-docs-planner](./ba-docs-planner)             | Plan Word `.docx` chapter updates from a Jira release + Confluence rules | Business Analyst               |
| [eversis-ba-docs-writer](./ba-docs-writer)               | Apply an approved docs-update-plan.md to a Word `.docx` file             | Business Analyst               |

### 🛠 Implement skills

- **[eversis-orchestrating-implementation](./orchestrating-implementation)** — orchestrates the Implement phase end to end.
- **[eversis-architecture-designing](./architecture-design)** — designs solution architecture.
- **eversis-record-decision** — writes one architecture decision under `docs/decisions/` when a person asks during research, plan, or Implement.
- **[eversis-creating-implementation-plans](./creating-implementation-plans)** — structures a designed solution into a phased plan.
- **[eversis-technical-context-discovering](./technical-context-discovery)** — discovers project conventions and patterns.
- **[eversis-implementing-frontend](./frontend-implementation)** — applies UI component and design-token patterns.
- **[eversis-implementing-filters](./implementing-filters)** — builds URL-synced filter lists.
- **[eversis-implementing-forms](./implementing-forms)** — structures form architecture and validation.
- **[eversis-writing-hooks](./writing-hooks)** — builds custom hook/composable patterns.
- **[eversis-ensuring-accessibility](./ensuring-accessibility)** — checks WCAG 2.1 AA compliance.
- **[eversis-optimizing-frontend](./optimizing-frontend)** — optimizes rendering and bundle size.
- **[eversis-implementation-gap-analysing](./implementation-gap-analysis)** — compares the plan against the current codebase state.
- **[eversis-sql-and-database-understanding](./sql-and-database)** — applies database and ORM standards.
- **[eversis-codebase-analysing](./codebase-analysis)** — maps codebase structure and dependencies.
- **[eversis-writing-repo-documentation](./writing-repo-documentation)** — writes README, CHANGELOG, and docs-site content.
- **[eversis-engineering-prompts](./prompt-engineering)** — designs and secures LLM application prompts.
- **[eversis-promote-domain-knowledge](./promote-domain-knowledge)** — drafts durable facts into `docs/context/` at Fine.
- **[eversis-import-confluence-knowledge](./import-confluence-knowledge)** — seeds `docs/context/` from a Confluence AS-IS Pack.
- **[eversis-audit-domain-knowledge](./audit-domain-knowledge)** — periodically reviews `docs/context/` for drift.
- **[eversis-add-domain-knowledge](./add-domain-knowledge)** — drafts one durable project-knowledge fact when no ticket is closing; writes locally only after that draft is approved.

| Skill                                                                    | Description                                                                    | Used By                            |
| ------------------------------------------------------------------------ | ------------------------------------------------------------------------------ | ---------------------------------- |
| [eversis-orchestrating-implementation](./orchestrating-implementation)   | Implement-phase orchestration: Quick vs Full, routing, gates, Fine handoff     | Engineering Manager                |
| [eversis-architecture-designing](./architecture-design)                  | Solution architecture design                                                   | Architect                          |
| [eversis-creating-implementation-plans](./creating-implementation-plans) | Plan template, WIG, Technical Context, phased tasks, DoD rules                 | Architect, Plan Reviewer           |
| [eversis-technical-context-discovering](./technical-context-discovery)   | Project conventions and pattern discovery                                      | Architect, CR, SE, E2E, CE         |
| [eversis-implementing-frontend](./frontend-implementation)               | UI component patterns, composition, design tokens                              | Software Engineer                  |
| [eversis-implementing-filters](./implementing-filters)                   | URL-synced filter lists (Next + REST); stack policy required                   | Software Engineer                  |
| [eversis-implementing-forms](./implementing-forms)                       | Form architecture, schema validation, multi-step flows                         | Software Engineer                  |
| [eversis-writing-hooks](./writing-hooks)                                 | Custom hook/composable patterns, lifecycle, testing                            | Software Engineer                  |
| [eversis-ensuring-accessibility](./ensuring-accessibility)               | WCAG 2.1 AA compliance, semantic HTML, ARIA, keyboard nav                      | Software Engineer                  |
| [eversis-optimizing-frontend](./optimizing-frontend)                     | Rendering optimization, code splitting, bundle size                            | Software Engineer                  |
| [eversis-implementation-gap-analysing](./implementation-gap-analysis)    | Gap analysis between plan and current state                                    | Architect, CR, SE                  |
| [eversis-sql-and-database-understanding](./sql-and-database)             | Database engineering standards and ORM integration                             | Architect, CR, SE                  |
| [eversis-codebase-analysing](./codebase-analysis)                        | Deep codebase analysis and dependency mapping                                  | Architect, BA, CE, SE              |
| [eversis-writing-repo-documentation](./writing-repo-documentation)       | Repository docs: README, CHANGELOG, docs site                                  | Repo Docs writer, EM delegate      |
| [eversis-engineering-prompts](./prompt-engineering)                      | LLM prompt design, optimization, security, and evaluation                      | PE, SE, Architect, CR              |
| [eversis-promote-domain-knowledge](./promote-domain-knowledge)           | Optional Fine-turn draft promoting durable cross-task facts to `docs/context/` | Engineering Manager                |
| [eversis-import-confluence-knowledge](./import-confluence-knowledge)     | One-time seed of `docs/context/<project>/` from a Confluence AS-IS Pack page   | Business Analyst, Context Engineer |
| [eversis-audit-domain-knowledge](./audit-domain-knowledge)               | Periodic Keep/Update/Consolidate/Replace/Delete review of `docs/context/`      | Anyone (scheduled)                 |
| [eversis-add-domain-knowledge](./add-domain-knowledge)                   | Person-started draft of one durable fact into `docs/context/<project>/` when no ticket is closing; local write after approval | the person (on request)            |
| eversis-record-decision                                                  | Writes one local architecture decision under `docs/decisions/` when a person asks | anyone during research, plan, or Implement |

### ☁️ Cloud & Infrastructure Skills

- **[eversis-implementing-ci-cd](./ci-cd-implementation)** — designs CI/CD pipelines and deployment strategies.
- **[eversis-implementing-kubernetes](./kubernetes-implementation)** — builds Kubernetes deployments and Helm charts.
- **[eversis-implementing-terraform-modules](./terraform-modules)** — writes reusable Terraform modules.
- **[eversis-implementing-observability](./observability-implementation)** — sets up logging, monitoring, and tracing.
- **[eversis-managing-secrets](./secrets-management)** — manages secrets across cloud and Kubernetes.
- **[eversis-optimizing-cloud-cost](./cloud-cost-optimization)** — finds cloud cost savings via rightsizing and tagging.
- **[eversis-designing-multi-cloud-architecture](./multi-cloud-architecture)** — designs architecture across AWS, Azure, GCP.

| Skill                                                                    | Description                                                                       | Used By                    |
| ------------------------------------------------------------------------ | --------------------------------------------------------------------------------- | -------------------------- |
| [eversis-implementing-ci-cd](./ci-cd-implementation)                     | CI/CD pipeline design patterns and deployment strategies                          | DevOps Engineer            |
| [eversis-implementing-kubernetes](./kubernetes-implementation)           | Kubernetes deployment patterns, Helm charts, and cluster management               | DevOps Engineer            |
| [eversis-implementing-terraform-modules](./terraform-modules)            | Reusable Terraform modules for AWS, Azure, and GCP infrastructure                 | DevOps Engineer            |
| [eversis-implementing-observability](./observability-implementation)     | Observability patterns for logging, monitoring, alerting, and distributed tracing | DevOps Engineer            |
| [eversis-managing-secrets](./secrets-management)                         | Secrets management patterns for cloud and Kubernetes environments                 | DevOps Engineer            |
| [eversis-optimizing-cloud-cost](./cloud-cost-optimization)               | Cloud cost optimization through rightsizing, tagging, and spending analysis       | DevOps Engineer            |
| [eversis-designing-multi-cloud-architecture](./multi-cloud-architecture) | Multi-cloud architecture design across AWS, Azure, and GCP                        | DevOps Engineer, Architect |

### ✅ Quality Skills

- **[eversis-code-reviewing](./code-review)** — runs the structured code review process.
- **[eversis-reviewing-frontend](./reviewing-frontend)** — reviews frontend components, hooks, and a11y.
- **[eversis-ui-verifying](./ui-verification)** — verifies the UI against Figma.
- **[eversis-e2e-testing](./e2e-testing)** — writes and verifies Playwright E2E tests.
- **[eversis-fine-handoff](./fine-handoff)** — drafts the mandatory QA comment after Fine.
- **[QA practice overview](./qa-workflow)** — single entry point for test planning, regression, and quality health.
- **[eversis-planning-tests](./planning-tests)** — builds test plans from acceptance criteria.
- **[eversis-analyzing-regression-risk](./analyzing-regression-risk)** — scopes regression suites from change context.
- **[eversis-verifying-acceptance-criteria](./verifying-acceptance-criteria)** — checks implementation against AC.
- **[eversis-analyzing-bugs](./analyzing-bugs)** — builds quality dashboards from Jira defect history.
- **[eversis-accessibility-auditing](./accessibility-auditing)** — runs WCAG 2.2 AA audit reports.
- **[eversis-functional-testing](./functional-testing)** — provides shared QA templates and severity matrix.

| Skill                                                                    | Description                                                                                | Used By                 |
| ------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------ | ----------------------- |
| [eversis-code-reviewing](./code-review)                                  | Structured code review process                                                             | Code Reviewer           |
| [eversis-reviewing-frontend](./reviewing-frontend)                       | Frontend-specific review: components, hooks, rendering, a11y                               | Code Reviewer           |
| [eversis-ui-verifying](./ui-verification)                                | Figma vs implementation verification criteria                                              | UI Reviewer, SE         |
| [eversis-e2e-testing](./e2e-testing)                                     | Playwright E2E testing patterns and verification                                           | E2E Engineer            |
| [eversis-fine-handoff](./fine-handoff)                                   | Mandatory QA comment draft after Fine (Implement handoff); human approves before Jira post | Anyone (post-implement) |
| [QA practice overview](./qa-workflow)                                    | `@eversis-qa-workflow` — test plans, regression, AC verify, quality health                 | QA / anyone             |
| [eversis-planning-tests](./planning-tests)                               | Test plans and test cases from acceptance criteria                                         | QA workflow             |
| [eversis-analyzing-regression-risk](./analyzing-regression-risk)         | Regression scope and suites from change context                                            | QA workflow             |
| [eversis-verifying-acceptance-criteria](./verifying-acceptance-criteria) | AC gap table vs implementation                                                             | QA workflow             |
| [eversis-analyzing-bugs](./analyzing-bugs)                               | Quality health dashboards from Jira defect history                                         | QA workflow             |
| [eversis-accessibility-auditing](./accessibility-auditing)               | WCAG 2.2 AA audit reports (manual QA)                                                      | QA workflow             |
| [eversis-functional-testing](./functional-testing)                       | Shared QA templates and severity matrix                                                    | QA workflow             |

### ⚙️ Framework customization skills

- **[eversis-creating-agents](./creating-agents)** — creates Cursor rules and role docs.
- **[eversis-creating-skills](./creating-skills)** — creates new `SKILL.md` packages.
- **[eversis-creating-prompts](./creating-prompts)** — creates attachable repo prompts.
- **[eversis-creating-instructions](./creating-instructions)** — writes project instructions (`AGENTS.md`, rules).

| Skill                                                    | Description                                  | Used By              |
| -------------------------------------------------------- | -------------------------------------------- | -------------------- |
| [eversis-creating-agents](./creating-agents)             | Creating Cursor rules (`.mdc`) and role docs | Framework maintainer |
| [eversis-creating-skills](./creating-skills)             | Creating custom skills (SKILL.md)            | Framework maintainer |
| [eversis-creating-prompts](./creating-prompts)           | Creating attachable repo prompts (Markdown)  | Framework maintainer |
| [eversis-creating-instructions](./creating-instructions) | Project instructions (AGENTS.md, rules)      | Framework maintainer |

## Agent–Skill Matrix

| Skill                                      | BA  | CE  | Architect | SE  | PE  | CR  | UI Reviewer | E2E | DevOps | Customize |
| ------------------------------------------ | --- | --- | --------- | --- | --- | --- | ----------- | --- | ------ | --------- |
| eversis-architecture-designing             |     |     | ✅        |     |     |     |             |     |        |           |
| eversis-audit-domain-knowledge             |     |     |           |     |     |     |             |     |        |           |
| eversis-ba-docs-planner                    | ✅  |     |           |     |     |     |             |     |        |           |
| eversis-ba-docs-writer                     | ✅  |     |           |     |     |     |             |     |        |           |
| eversis-creating-implementation-plans      |     |     | ✅        |     |     |     |             |     |        |           |
| eversis-code-reviewing                     |     |     |           |     | ✅  | ✅  |             |     |        |           |
| eversis-codebase-analysing                 | ✅  | ✅  | ✅        | ✅  |     |     |             |     | ✅     | ✅        |
| eversis-creating-agents                    |     |     |           |     |     |     |             |     |        | ✅        |
| eversis-creating-instructions              |     |     |           |     |     |     |             |     |        | ✅        |
| eversis-creating-prompts                   |     |     |           |     |     |     |             |     |        | ✅        |
| eversis-creating-skills                    |     |     |           |     |     |     |             |     |        | ✅        |
| eversis-designing-multi-cloud-architecture |     |     | ✅        |     |     |     |             |     | ✅     |           |
| eversis-e2e-testing                        |     |     |           |     |     |     |             | ✅  |        |           |
| eversis-engineering-prompts                |     |     | ✅        | ✅  | ✅  | ✅  |             |     |        |           |
| eversis-ensuring-accessibility             |     |     |           | ✅  |     |     |             |     |        |           |
| eversis-implementing-ci-cd                 |     |     | ✅        |     |     |     |             |     | ✅     |           |
| eversis-implementing-forms                 |     |     |           | ✅  |     |     |             |     |        |           |
| eversis-implementing-frontend              |     |     |           | ✅  |     |     |             |     |        |           |
| eversis-implementing-filters               |     |     |           | ✅  |     |     |             |     |        |           |
| eversis-implementing-kubernetes            |     |     | ✅        |     |     |     |             |     | ✅     |           |
| eversis-implementing-observability         |     |     | ✅        |     |     |     |             |     | ✅     |           |
| eversis-implementing-terraform-modules     |     |     | ✅        |     |     |     |             |     | ✅     |           |
| eversis-implementation-gap-analysing       |     |     | ✅        | ✅  |     | ✅  |             |     |        |           |
| eversis-import-confluence-knowledge        | ✅  | ✅  |           |     |     |     |             |     |        |           |
| eversis-jira-task-formatting               | ✅  |     |           |     |     |     |             |     |        |           |
| eversis-managing-secrets                   |     |     | ✅        |     |     |     |             |     | ✅     |           |
| eversis-optimizing-cloud-cost              |     |     | ✅        |     |     |     |             |     | ✅     |           |
| eversis-optimizing-frontend                |     |     |           | ✅  |     |     |             |     |        |           |
| eversis-fine-handoff                       |     |     |           | ✅  |     | ✅  |             | ✅  |        |           |
| eversis-promote-domain-knowledge           |     |     |           |     |     |     |             |     |        |           |
| eversis-record-decision                    |     |     |           |     |     |     |             |     |        |           |
| eversis-planning-tests                     |     |     |           |     |     |     |             |     |        |           |
| eversis-analyzing-regression-risk          |     |     |           |     |     |     |             |     |        |           |
| eversis-verifying-acceptance-criteria      |     |     |           |     |     |     |             |     |        |           |
| eversis-analyzing-bugs                     |     |     |           |     |     |     |             |     |        |           |
| eversis-accessibility-auditing             |     |     |           |     |     |     |             |     |        |           |
| eversis-add-domain-knowledge             |     |     |           |     |     |     |             |     |        |           |
| eversis-functional-testing                 |     |     |           |     |     |     |             |     |        |           |
| eversis-reviewing-frontend                 |     |     |           |     |     | ✅  |             |     |        |           |
| eversis-sql-and-database-understanding     |     |     | ✅        | ✅  |     | ✅  |             |     |        |           |
| eversis-task-analysing                     |     | ✅  |           |     |     |     |             | ✅  |        |           |
| eversis-task-extracting                    | ✅  |     |           |     |     |     |             |     |        |           |
| eversis-task-quality-reviewing             | ✅  |     |           |     |     |     |             |     |        |           |
| eversis-technical-context-discovering      |     | ✅  | ✅        | ✅  | ✅  | ✅  |             | ✅  | ✅     | ✅        |
| eversis-transcript-processing              | ✅  |     |           |     |     |     |             |     |        |           |
| eversis-ui-verifying                       |     |     |           | ✅  |     |     | ✅          |     |        |           |
| eversis-writing-hooks                      |     |     |           | ✅  |     |     |             |     |        |           |

## Loading Priority

Skills follow a strict priority hierarchy:

1. **Project constitution** — [AGENTS.md](https://gitlab3.eversis.com/eversis-ai/agent-collections/-/blob/master/AGENTS.md) and **`.ai/rules/`** (SSOT; the Cursor adapter emits **`.cursor/rules/*.mdc`**, the Claude Code adapter generates **`CLAUDE.md`**) — highest priority for behavior.
2. **Existing codebase patterns** — replicate established conventions.
3. **Skill guidelines** — domain best practices and templates.
4. **External documentation** — framework docs, OWASP, industry standards.

This ensures consistency: existing patterns are never overridden unless explicitly requested.
