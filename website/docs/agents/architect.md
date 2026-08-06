---
sidebar_position: 2
title: Architect
---

# Architect Agent

**Rule pack (canonical template):** `.cursor/rules/eversis-role-architect.mdc` — add when you split Architect behavior out of core packs; **not shipped** in this repository (planning runs via delegated [Plan](../prompts/internal/plan) prompt and `eversis-architecture-designing` skill).  
**Delegated prompt:** [Plan](../prompts/internal/plan) (via `@eversis-implement` — [Implement](../prompts/public/implement))

The Architect designs technical solutions and implementation plans from approved research, turning requirements into phased, executable work.

## Responsibilities

- Solution architecture: components, interactions, data flow.
- Implementation plans with phases, tasks, Technical Context, and clear definition of done.
- Alignment with requirements, practices, and quality expectations.
- Security and QA considerations at design time.
- Clarifying ambiguities with product/analysis context.

## What it produces

- **Solution architecture** — Components, interactions, data flow.
- **Implementation plan** — Phased tasks and checkpoints.
- **Test strategy** — Automated testing focus (no manual QA scripts).
- **Security considerations** — What implementers must address.
- **Quality assurance** — Standards for the implementation pass.

## What it does NOT do

- Does not implement application code or edit files outside research/plan artifacts.
- Does not run build, test, lint, or deployment commands — specifies them in the plan for implementers and reviewers.

## Tools (typical)

| Tool | Usage |
| --- | --- |
| **Atlassian** | Gather requirements from Jira issues and Confluence pages |
| **Context7** | Evaluate libraries, verify compatibility, search integration patterns |
| **Figma** | Translate visual requirements into technical specifications  |
| **PDF Reader** | Read and extract content from PDF requirement documents  |
| **Sequential Thinking** | Design complex architectures, evaluate trade-offs, break down features |
| **Terminal** | **Read-only** — inspect command output when needed; do not run build, test, lint, or deploy from the Architect turn |
| **Cursor Agent** | Read, search, and edit workspace files (research/plan artifacts only) |
| **Todo** | Track task progress with structured checklists |

## Skills (Eversis naming)

- [eversis-architecture-designing](../skills/architecture-design) — Solution design, components, data flows.
- [eversis-creating-implementation-plans](../skills/creating-implementation-plans) — Plan template, WIG, Technical Context, phased tasks, and DoD rules.
- [eversis-codebase-analysing](../skills/codebase-analysis) — Analyze current architecture, components, and patterns.
- [eversis-implementation-gap-analysing](../skills/implementation-gap-analysis) — Focus the plan on necessary changes without duplicating existing work.
- [eversis-technical-context-discovering](../skills/technical-context-discovery) — Establish project conventions and patterns before designing.
- [eversis-sql-and-database-understanding](../skills/sql-and-database) — Database schema design, indexing strategies, transaction patterns.
- [eversis-designing-multi-cloud-architecture](../skills/multi-cloud-architecture) — Cross-provider infrastructure design and service selection across AWS, Azure, and GCP.
- [eversis-optimizing-cloud-cost](../skills/cloud-cost-optimization) — Cost implications of architectural decisions, pricing model comparison.
- [eversis-implementing-ci-cd](../skills/ci-cd-implementation) — CI/CD pipeline design, deployment strategies, delivery workflows.
- [eversis-implementing-terraform-modules](../skills/terraform-modules) — IaC structure, Terraform module hierarchy, Terragrunt patterns.
- [eversis-managing-secrets](../skills/secrets-management) — Secrets management, credential rotation, vault integration.
- [eversis-implementing-kubernetes](../skills/kubernetes-implementation) — K8s workload configurations, scaling strategies, Helm chart structure.
- [eversis-implementing-observability](../skills/observability-implementation) — Monitoring architecture, SLO frameworks, alerting, distributed tracing.
- [eversis-engineering-prompts](../skills/prompt-engineering) — LLM prompt architecture: prompt template strategy, system prompt design, few-shot vs zero-shot decisions.

## Handoffs

After human approval of the plan draft, the [Plan Reviewer](./plan-reviewer) stress-tests the plan via internal [Review Plan](../prompts/internal/review-plan). After verdict `APPROVED`, implementation runs through **`@eversis-implement`** ([Implement](../prompts/public/implement)) and the [Engineering Manager](./engineering-manager), including UI flows via [Implement UI](../prompts/internal/implement-ui) when Figma is in scope.
