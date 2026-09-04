---
sidebar_position: 4
title: "Implement"
slug: implement
prompt_role: "Engineering Manager"
prompt_description: "Implement feature according to the plan."
upstream_agent: "eversis-engineering-manager"
---

# eversis-implement

**Agent:** Engineering Manager
**File:** `.cursor/prompts/public/eversis-implement.md`

Thin trigger for implementation delivery. The canonical orchestration workflow lives in the **`eversis-orchestrating-implementation`** skill — load it via MCP (`eversis_skills_get`) or read `.cursor/skills/eversis-orchestrating-implementation/SKILL.md`.

## Usage

```text
@eversis-implement
<JIRA_ID or task description — if applicable>
```

Or use the `/eversis-implement` project command (type `/` in Chat or Agent).

Attach **`@eversis-engineering-manager`** (`.cursor/rules/eversis-engineering-manager.mdc`) when running this workflow.

## What It Does

Delegates to **`eversis-orchestrating-implementation`**, which owns:

- **Quick vs Full flow** selection (Figma/UI always forces Full)
- Research → plan → plan validation → implementation → review gates
- Per-task todos, routing table, and UI verification gate
- **Fine** + mandatory QA comment draft via `eversis-fine-handoff`

Load **`eversis-orchestrating-implementation`** for the full workflow (docs: `website/docs/skills/orchestrating-implementation.md`).

## Output

- `*.research.md`, `*.plan.md`, `*.plan-review.md` under `docs/specs/<task-name>/` **when a gap exists** (not required on every run)
- **Implement readiness** block in the first agent response (Flow / Research / Plan / Next gate)
- Code changes applied by delegated agents
- Updated plan checkboxes and Changelog entries
- Code review findings
- QA comment draft labeled `Draft QA comment — review before posting to Jira` on **Fine**

---

## Executable prompt (attach in Cursor)

Start implementation delivery for a feature based on a task description, Jira item, or implementation plan. This prompt is a thin trigger — the workflow is defined in **`eversis-orchestrating-implementation`**.

**Attach:** `@eversis-engineering-manager` (`.cursor/rules/eversis-engineering-manager.mdc`).

**Required skill:** Load and follow **`eversis-orchestrating-implementation`** (MCP `eversis_skills_get` or `.cursor/skills/eversis-orchestrating-implementation/SKILL.md`).

**Input:** Provide at least one of: task description, Jira ID, or `*.plan.md`. Include `*.research.md` when available. You do **not** need to type “Research” — the agent inspects existing artifacts and decides automatically (see **Entry signals** below).

**Artifacts:** Create `*.research.md`, `*.plan.md`, and `*.plan-review.md` only when a gap exists — not on every run. Existing files in `docs/specs/<issue-or-task-kebab>/` may satisfy readiness.

**Workflow:** Start at Step 0 in `eversis-orchestrating-implementation` and follow that skill through Step 5 (Fine + `eversis-fine-handoff` in the same response). Do not duplicate orchestration steps in this prompt.

### Entry signals (automatic — no extra keywords required)

Before research, planning, or code, inspect `docs/specs/<issue>/` (or paths attached with `@`):

| Signal | Default |
| --- | --- |
| No `*.research.md` / `*.plan.md` | Full Flow → create missing artifacts → human gate |
| `@*.plan.md` + adequate `*.research.md` (adequacy checklist pass) | Implement phase — **SKIP** new research/plan |
| QA comment / bugfix / retest / needs verification | Run **adequacy checklist** on existing artifacts vs latest QA comment or AC |
| Research + plan adequate for current comment/AC | Implement phase — Research **SKIP**, Plan **SKIP** or **REFRESH** if tasks missing |
| Research exists but does **not** cover current comment/AC | **Research: DELTA** — update `*.research.md` (Changelog) in same session → human gate |
| Plan exists but does **not** cover current fix | **Plan: REFRESH** → human gate |
| User asks to **research**, **analyze**, **przeanalizuj**, **bug analysis**, **last QA comment** (via `/eversis-implement`) | **Flow: Full**; **Research: CREATE \| DELTA**; **Plan: SKIP (analysis-only — plan after research approval)**; **Next gate: Awaiting approval before plan**; write/update `*.research.md` in same session; no A/B/C menu |
| Narrow fix, obvious solution, ≤3 files, plan/context ready, adequacy pass | Quick Flow allowed (orchestration skill Step 1) |

**First response (mandatory):** Output the **exact four-line** Implement readiness block from orchestration skill Step 1 as the **first content** before any artifact creation or code. Never skip it — even in Quick Flow or when continuing a thread. See **Readiness output contract** in the skill.

<!-- Eversis port; upstream: eversis-implement:v2 + eversis-orchestrating-implementation -->
