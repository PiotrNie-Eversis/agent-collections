---
sidebar_position: 1
title: Workflow Overview
---

# Workflow Overview

**Agent Collections** covers the **full product lifecycle**:

> **Ideate → Research → Plan → Implement → Review → Fine**

Attach **`@eversis-implement`** (or `/eversis-implement`) for the Implement phase — research, planning, code review and Fine all run inside that flow. Each phase produces documented artifacts with **human gates** where the prompts require them.

:::tip The relay race
Each phase passes a reviewed deliverable to the next. Workshop materials feed the backlog; the Engineering Manager orchestrates research, planning, and implementation; implementation feeds review.
:::

## The phases

### 1. Ideate

- **Role:** Business Analyst
- **Prompt:** `@eversis-analyze-materials`
- Workshop materials → Jira-ready epics and stories with acceptance criteria.
- **Gates:** Gate 1, Gate 1.5, and Gate 2 before Jira sync — see [Workshop Analysis Flow](./workshop-flow).

### 2. Implement

- **Role:** Engineering Manager (delegates Context Engineer, Architect, Plan Reviewer, implementers, Code Reviewer)
- **Prompt:** `@eversis-implement` with a Jira ID, task description, or `@docs/specs/.../*.plan.md`
- The EM’s **first response** is always an **Implement readiness** block (Flow / Research / Plan / Next gate) — before any artifacts or code. See [Orchestrating Implementation](../../reference/skills/orchestrating-implementation#implement-readiness-mandatory-first-output).
- **Entry signals** — existing adequate `*.research.md` + attached plan (after **adequacy checklist**) → skip new research/plan. No need to type “Research” in the prompt. Pure analysis without implement is also valid (chat + specs).

#### Flow selection

At Step 0 the EM recommends **Quick** or **Full** (you may override). See [Orchestrating Implementation](../../reference/skills/orchestrating-implementation).

| Flow      | Steps                                                                                                                         | When to use                            |
| --------- | ----------------------------------------------------------------------------------------------------------------------------- | -------------------------------------- |
| **Quick** | implement → quality checks → code review (same run) → **Fine** + QA draft                                                     | Criteria pass, artifacts exist         |
| **Full**  | research → approve research → plan → plan review → approve plan → code + quality checks → code review (same run) → **Fine** + QA draft | Artifacts missing or scope requires it |

:::info Quick vs Full
**Hard exclusion:** Figma, UI verification tasks, cross-domain work, or likely >3 files → **Full Flow only**. Quick is for narrow, low-risk fixes after you confirm the EM recommendation.
:::

- **Produces:** `*.research.md`, `*.plan.md`, `*.plan-review.md` **when a gap exists**; code changes; Implement readiness summary in chat.

### 3. Review

- **Role:** Code Reviewer
- **Runs:** inside the `@eversis-implement` run, after implementation and quality checks and before **Fine**, in a separate context. It is not a human approval gate.
- Structured review — PASS / BLOCKER / SUGGESTION. On BLOCKER the Engineering Manager asks you before changing the reviewed solution, then re-runs a full review. On PASS it declares **Fine**.
- **Optional:** attach `@eversis-review` yourself for a review-only chat or a re-review. Say `pause before review` or `review later` during Implement to stop before code review and run `@eversis-review` later.

## Implement → Review

| Step                         | Attach               | What happens                                                                                              |
| ---------------------------- | -------------------- | --------------------------------------------------------------------------------------------------------- |
| Implement (Quick)            | `@eversis-implement` | EM: implement → quality checks → review → Fine + QA draft                                                 |
| Implement (Full)             | `@eversis-implement` | EM: research → approve research → plan → plan review → approve plan → implementation → quality checks → review → Fine + QA draft |
| Review (optional, standalone) | `@eversis-review`    | Separate pass for review-only chats or re-review                                                          |

## Status: Fine — handoff

When Implement is complete, the Engineering Manager declares **Fine** and **must** output a **QA comment draft in the same response** (not a separate turn). Normative procedure: [`.cursor/skills/eversis-fine-handoff/SKILL.md`](https://gitlab3.eversis.com/eversis-ai/agent-collections/-/blob/master/.cursor/skills/eversis-fine-handoff/SKILL.md) or MCP `eversis_skills_get` for `eversis-fine-handoff`. Onboarding overview: [Fine Handoff](../../reference/skills/fine-handoff).

The draft is labeled **`Draft QA comment — review before posting to Jira`**. Post to Jira only after you approve (copy-paste or explicit Atlassian MCP instruction).

### Domain-knowledge promotion

So that a durable fact learned during one task (a confirmed business rule, a reusable integration pattern — not a one-off implementation detail) survives beyond that single task and beyond a single repo, Fine can also produce a **second, independent draft**: a proposal to write that fact into `docs/context/<project>/` (the project's own **domain knowledge** store — durable notes about the codebase and business rules, separate from per-task history). Most tasks do **not** produce this kind of finding — it appears only when the task actually surfaces one.

This second draft is labeled **`Draft: domain-knowledge promotion to docs/context/<project>/ — approve before writing`** and has its **own** approval: accepting or rejecting the QA comment draft has no effect on it, and vice versa. Once approved, it is written to **this repo** (`docs/context/<project>/`). Sharing the same fact with other repos (the group `domain-context` GitLab project) is a **later, optional** step — see [Domain Context — Tools and skills](../../domain-context#tools-and-skills).

### As-Is Pack comment

When that promotion targets a component whose frontmatter has `confluence_url`, Fine also drafts an **inline comment** on the matching As-Is Pack heading (a Confluence section that maps the component to documented as-is state). The section owner comes from the `Właściciel sekcji:` line directly under that heading; if the line or the person is missing, the owner field is empty. Publishing is a **later, separate approval** and does **not** edit the page body.

This draft is labeled **`Draft: As-Is Pack comment — approve before posting to Confluence`**. Without a promotion candidate, or when `confluence_url` is null, Fine stays on the QA draft alone or QA plus promotion — it does not take the Pack-comment branch.

import PeleDiagram from '@site/src/components/PeleDiagram';

export const fineFlow = `flowchart TD
    review["Code review<br/>PASS"] --> fine["Fine<br/>ready for QA"]
    fine --> qa["QA comment draft (always)"]
    qa --> gate1{"You approve<br/>the QA draft?"}
    gate1 -- yes --> jira["Published:<br/>Jira comment"]
    fine --> check{"Durable, cross-task<br/>knowledge?<br/>(most tasks: no)"}
    check -- Yes --> promo["Second draft:<br/>domain-knowledge<br/>promotion"]
    promo --> gate2{"You approve<br/>the promotion?<br/>(own decision)"}
    gate2 -- yes --> project["Published:<br/>docs/context/<br/>in this repo"]
    promo --> packcheck{"Target has<br/>confluence_url?"}
    packcheck -- Yes --> pack["Third draft:<br/>As-Is Pack<br/>comment"]
    pack --> gate3{"You approve<br/>the comment?<br/>(own decision)"}
    gate3 -- yes --> confluence["Published:<br/>inline comment<br/>in Confluence"]`;

<PeleDiagram
  id="fine-handoff-flow"
  source={fineFlow}
  label="Fine handoff: after code review passes, the agent declares Fine and always writes a QA comment draft; it is posted to Jira only after you approve it. When the task found durable, cross-task knowledge, a second draft proposes a domain-knowledge promotion, written to docs/context/ for the project in this repo only after its own approval; most tasks have no second draft. When the promotion target has a confluence_url, a third draft proposes an inline As-Is Pack comment, posted to Confluence only after its own approval, with the page body unchanged."
/>

## Workflow diagram

import SdlcDiagram from '@site/src/components/SdlcDiagram';

<SdlcDiagram />

## Human approval gates

:::warning Important
You approve three things: the research, the plan, and posting the Fine QA comment to the ticket. Code review runs in the same Implement session and needs no separate approval. AI output is always a draft until you approve it.
:::

## Workflow variants

| Variant                                              | Entry                                            | Use when                                                    |
| ---------------------------------------------------- | ------------------------------------------------ | ----------------------------------------------------------- |
| **Standard flow**                                    | `@eversis-implement` (review runs inside)        | Backend / fullstack — Quick or Full at Step 0               |
| **UI + Figma**                                       | `@eversis-implement` + `@eversis-review-ui` loop | Design-driven UI                                            |
| **[Workshop analysis](./workshop-flow)**             | `@eversis-analyze-materials`                     | Workshop → Jira only                                        |
| **[E2E testing](./e2e-flow)**                        | `@eversis-implement` (E2E tasks in plan)         | Playwright coverage                                         |
| **[Business Manager Docs](./business-manager-docs)** | `@eversis-ba-docs-planner` → writer              | Word `.docx` release docs                                   |
| **[Repo Docs](./repo-docs)**                         | `@eversis-repo-docs-writer` (or EM delegate)     | README, CHANGELOG, `website/docs` after Implement           |
| **[QA workflow](./qa-workflow)**                     | `@eversis-qa-workflow`                           | Manual test planning, regression, AC verify, quality health |

:::info Standard flow
Full step-by-step: [Standard Flow](./standard-flow) — **Quick vs Full** at Step 0, then research, plan, implement and review — you approve the research and the plan.
:::

:::info Frontend / UI flow
Figma-driven UI with verification loop: [Frontend Flow](./frontend-flow) — includes the 5-step UI verification loop (`@eversis-review-ui`).
:::

:::info Workshop analysis
Ideate-only with Gates 1, 1.5, 2: [Workshop Analysis Flow](./workshop-flow).
:::

:::info E2E testing
Playwright work inside Implement: [E2E Testing Flow](./e2e-flow).
:::

:::info Repo Docs
Repository markdown after Implement: [Repo Docs](./repo-docs) — `@eversis-repo-docs-writer` (not Word `.docx`).
:::

:::info QA workflow
Manual QA practice (separate from Fine handoff): [QA Workflow](./qa-workflow) — `@eversis-qa-workflow`.
:::

:::info Business Manager Docs
Word `.docx` via `eversis-collections` MCP: [Business Manager Docs](./business-manager-docs).
:::

## Workflow playbooks

- [Standard Flow](./standard-flow)
- [Frontend Flow](./frontend-flow)
- [Workshop Analysis Flow](./workshop-flow)
- [E2E Testing Flow](./e2e-flow)
- [Business Manager Docs](./business-manager-docs)
- [Repo Docs](./repo-docs)
- [QA Workflow](./qa-workflow)
