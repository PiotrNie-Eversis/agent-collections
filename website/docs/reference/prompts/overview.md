---
sidebar_position: 1
title: Prompts Overview
---

# Prompts Overview

This framework includes **16 public prompts** and **12 internal prompts** — Markdown workflow definitions loaded by stable id under **`.ai/prompts/`**. **Canonical sources** live under `.ai/prompts/public/` and `.ai/prompts/internal/` as `eversis-*.md` files; the content on this page is copied verbatim from there.

**How to invoke — three adapters, not just Cursor:**

- **Claude Code:** stable prompt id as a slash command (e.g. **`/eversis-implement`**) generated under `.claude/commands/` by the Claude adapter — this is how prompts are triggered outside Cursor.
- **Cursor `@` attachment:** type **`@`** and the file stem (e.g. **`@eversis-implement`**). Cursor resolves the file by name.
- **Cursor `/` project command:** thin `.cursor/commands/eversis-*.md` shims (Cursor adapter) that point back at the SSOT file under `.ai/prompts/`.

Public prompts are user-facing entry points; internal prompts are delegated to automatically by the Engineering Manager during `/eversis-implement` — you do not attach them directly.

**Documentation site:** this page and every page under `prompts/public/` and `prompts/internal/` are **generated** from `.ai/prompts/**` by `node adapters/website/generate-prompts.mjs` (`npm run sync:website-docs`). The generated files are **committed to git** (not gitignored) — same convention as `.cursor/rules/*.mdc` and `.claude/commands/*.md` under `adapters/sync.mjs`. Run `npm run sync:website-docs:check` to detect drift; do not hand-edit files under this generated tree — edit the `.ai/prompts/` source and regenerate.

## Public Prompts

| Prompt | Role | Description |
| --- | --- | --- |
| [eversis-implement](./public/implement) | Engineering Manager | Implement feature according to the plan. |
| [eversis-review](./public/review) | Code reviewer | Check the implementation against the plan and feature context. |
| [eversis-review-ui](./public/review-ui) | UI reviewer | Single-pass UI verification: compare implementation against Figma and report differences. |
| [eversis-review-codebase](./public/review-codebase) | Architect | Perform a comprehensive code quality analysis: dead code, duplications, and improvement opportunities. |
| [eversis-analyze-materials](./public/analyze-materials) | Business analyst | Process discovery workshop materials and create Jira-ready epics and user stories, or iterate on an existing Jira backlog. |
| [eversis-ba-docs-planner](./public/ba-docs-planner) | BA Docs (Word) planner | Build docs-update-plan.md from Confluence rules, a Jira release, and summary.md — for .docx chapters. |
| [eversis-ba-docs-writer](./public/ba-docs-writer) | BA Docs (Word) writer | Apply docs-update-plan.md to .docx via eversis-collections MCP — not README or website markdown. |
| [eversis-create-custom-agent](./public/create-custom-agent) | Cursor customization orchestrator | Create new Cursor role packaging — typically `.ai/rules/` plus optional Cursor adapter `.mdc` packaging and optional agent docs. Researches existing rules, designs the role, and validates against the eversis-creating-agents skill. |
| [eversis-repo-docs-writer](./public/repo-docs-writer) | Repo Docs writer | Author or update repository documentation (README, CHANGELOG, docs/, website/) — not Word .docx. |
| [eversis-create-custom-skill](./public/create-custom-skill) | Cursor customization orchestrator | Create a new Agent Skill: SKILL.md under .ai/skills/ with gerund-style folder name. Follows eversis-creating-skills. |
| [eversis-qa-workflow](./public/qa-workflow) | QA practice | Single QA entrypoint — test planning, regression, AC verification, bug reports, quality health, and accessibility audits. |
| [eversis-create-custom-prompt](./public/create-custom-prompt) | Cursor customization orchestrator | Create a new attachable prompt as .ai/prompts/public\|internal/eversis-*.md with Docusaurus frontmatter. Analyzes existing prompts for patterns and validates using eversis-creating-prompts. |
| [eversis-audit-infrastructure](./public/audit-infrastructure) | DevOps engineer | Audit infrastructure for security gaps, cost waste, and best practices violations. |
| [eversis-create-custom-instructions](./public/create-custom-instructions) | Cursor customization orchestrator | Create or extend project instructions for Cursor: AGENTS.md, .cursor/rules, optional RULE.md. Follows eversis-creating-instructions. |
| [eversis-analyze-aws-costs](./public/analyze-aws-costs) | DevOps engineer | Perform a comprehensive AWS cost optimization and tagging compliance audit — checks IaC code first, then validates everything against live infrastructure via API. |
| [eversis-analyze-gcp-costs](./public/analyze-gcp-costs) | DevOps engineer | Perform a comprehensive GCP cost optimization and labeling compliance audit — checks IaC code first, then validates everything against live infrastructure via API. |

## Internal Prompts

Not invoked directly by users — delegated to automatically during `/eversis-implement` when the workflow requires them.

| Prompt | Role | Description |
| --- | --- | --- |
| [eversis-implement-common-task](./internal/implement-common-task) | Software engineer | Implement common feature according to the plan. |
| [eversis-implement-ui-common-task](./internal/implement-ui-common-task) | Software engineer | Implement UI feature according to the plan with frontend-specific setup and design reference handling. |
| [eversis-implement-e2e](./internal/implement-e2e) | E2E engineer | Create, maintain, and execute E2E tests for given feature or user story. |
| [eversis-implement-ui](./internal/implement-ui) | Engineering Manager | Implement UI feature according to the plan, orchestrating iterative Figma verification until pixel-perfect. |
| [eversis-research](./internal/research) | Context engineer | Prepare a context for a specific task or feature from a context engineering perspective. |
| [eversis-plan](./internal/plan) | Architect | Prepare detailed implementation plan for given feature. |
| [eversis-engineer-prompt](./internal/engineer-prompt) | Prompt engineer | Design, optimize, audit, or review LLM application prompts for quality, security, and consistency. |
| [eversis-review-plan](./internal/review-plan) | Plan Reviewer | Stress-test an implementation plan before coding begins. |
| [eversis-deploy-kubernetes](./internal/deploy-kubernetes) | DevOps engineer | Create Kubernetes deployments, Helm charts, and configure workload resources. |
| [eversis-implement-terraform](./internal/implement-terraform) | DevOps engineer | Create Terraform modules and provision cloud infrastructure safely. |
| [eversis-implement-pipeline](./internal/implement-pipeline) | DevOps engineer | Create or modify CI/CD pipelines with deployment stages and environment protection. |
| [eversis-implement-observability](./internal/implement-observability) | DevOps engineer | Implement observability solutions including metrics, logs, traces, and alerting. |

## Input Format

All prompts accept either:

- A **Jira ticket ID** (with context attached in chat)
- A **task description** (e.g. add pagination to the user list API)

The agent adapts based on the input type.

<!-- GENERATED by adapters/website/generate-prompts.mjs from .ai/prompts/ — do not edit; run `npm run sync:website-docs` -->
