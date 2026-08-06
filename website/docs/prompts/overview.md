---
sidebar_position: 1
title: Prompts Overview
---

# Prompts Overview

This framework includes **12 public prompts** — Markdown workflow definitions for **Cursor** (Chat or Agent). **Canonical sources** live under `.cursor/prompts/public/` as `eversis-*.md` files.

**How to invoke:** Two equivalent options in Chat or Agent:

- **`@` attachment (preferred):** Type **`@`** and the **file stem** (e.g. **`@eversis-implement`**, **`@eversis-review`**). Cursor resolves the file by name; use a full repo path only if the picker does not disambiguate.
- **`/` project command:** Type **`/`** and select from the dropdown. This repo ships thin `.cursor/commands/eversis-*.md` delegates for the four primary SDLC prompts — they read and execute the canonical prompt file automatically.

| `/` project command | Equivalent `@` attachment | Workflow |
| --- | --- | --- |
| `/eversis-analyze-materials` | `@eversis-analyze-materials` | Ideate — workshop → Jira stories |
| `/eversis-implement` | `@eversis-implement` | Implement — research → plan → code |
| `/eversis-review` | `@eversis-review` | Review — code quality against plan |
| `/eversis-review-ui` | `@eversis-review-ui` | Review — Figma vs implementation |

> Use **`@`** attachment or the **`/eversis-*`** project commands above — both load the same canonical `.cursor/prompts/public/` files.

The first column in the tables below lists each **prompt by file stem** (links go to the catalog page).

**Documentation site:** From the repository’s **`website/`** directory, `npm run start` and `npm run build` run **`sync-prompts`** first, copying these files into `website/docs/prompts/` for Docusaurus. The generated `eversis-*.md` copies there are gitignored and are listed in **`.cursorignore`** so they are not double-indexed next to the sources under **`.cursor/prompts/`.**

## How Prompts Work

Each prompt file defines:

- **Role** — Who executes the workflow (conceptual; backed by **rules** in `.cursor/rules/` when you use them).
- **Description** — Short summary of the workflow’s purpose.
- **Instructions** — Detailed steps, required skills, and output format.

In **Cursor**, the **attachable body** is the Markdown file. The **Executable prompt** section at the bottom of each catalog page is the full body to follow in Agent mode.

## Public Prompts

These are the user-facing prompts. Doc paths use stable URLs (`slug`); files on disk are `eversis-*.md`.

### Product Ideation

| Prompt | Description |
| --- | --- |
| [eversis-analyze-materials](./public/analyze-materials) | Process workshop materials into Jira-ready epics and stories |

### Development

| Prompt | Description |
| --- | --- |
| [eversis-implement](./public/implement) | Orchestrate research → plan → implementation |

### Quality

| Prompt | Description |
| --- | --- |
| [eversis-review](./public/review) | Review implementation against plan and standards |
| [eversis-review-ui](./public/review-ui) | Single-pass Figma vs implementation comparison |
| [eversis-review-codebase](./public/review-codebase) | Comprehensive code quality analysis |

### Framework customization

| Prompt | Description |
| --- | --- |
| [eversis-create-custom-agent](./public/create-custom-agent) | New Cursor rules / role documentation |
| [eversis-create-custom-skill](./public/create-custom-skill) | New Agent Skill (SKILL.md) |
| [eversis-create-custom-prompt](./public/create-custom-prompt) | New attachable prompt Markdown |
| [eversis-create-custom-instructions](./public/create-custom-instructions) | AGENTS.md and project instruction layout |

### Infrastructure and cost

| Prompt | Description |
| --- | --- |
| [eversis-audit-infrastructure](./public/audit-infrastructure) | Infra security and best-practices audit |
| [eversis-analyze-aws-costs](./public/analyze-aws-costs) | AWS cost and tagging compliance |
| [eversis-analyze-gcp-costs](./public/analyze-gcp-costs) | GCP cost and labeling compliance |

## Delegation via Implement

When you run **[eversis-implement](./public/implement)** (attach the file), the workflow describes how the **Engineering Manager** pattern delegates research, planning, and implementation. You do not need to open every internal prompt by hand — follow the public `eversis-implement.md` body; it references **`.cursor/prompts/internal/`** when needed.

| Phase | Delegated to (conceptual) |
| --- | --- |
| Research | Context Engineer (see [internal research](./internal/research)) |
| Planning | Architect (see [internal plan](./internal/plan)) |
| Implementation | Software Engineer, Prompt Engineer, DevOps, E2E, etc. (per task) |
| UI verification | UI Reviewer and internal UI prompts as applicable |

## Input Format

All prompts accept either:

- A **Jira ticket ID** (with context attached in chat)
- A **task description** (e.g. add pagination to the user list API)

The agent adapts based on the input type.
