---
sidebar_position: 4
title: Orchestrating Implementation
---

# Orchestrating Implementation

**Folder:** `.cursor/skills/eversis-orchestrating-implementation/`  
**Used by:** Engineering Manager via [`eversis-implement`](../prompts/public/implement)

Canonical workflow owner for the Implement phase. The public **`@eversis-implement`** prompt is a thin trigger; this skill contains the full orchestration procedure.

## Progress checklist

```text
- [ ] Step 0: Create flow-start todos
- [ ] Step 1: Select Quick Flow or Full Flow + Implement readiness block
- [ ] Step 2: Write the upfront execution plan
- [ ] Step 3: Run the selected flow
- [ ] Step 4: Close validation and review gates
- [ ] Step 5: Declare Fine and produce QA comment draft
```

## Implement readiness (mandatory first output)

Before creating artifacts, delegating, or writing product code, inspect `docs/specs/<issue>/` and any `@`-attached plan/research paths. **Output at the start of the first response** the readiness block below (including Quick Flow, QA follow-ups, and handoff continuations):

```text
## Implement readiness
- **Flow:** Quick | Full | QA follow-up
- **Research:** SKIP (<path>) | CREATE | DELTA (<reason>)
- **Plan:** SKIP (<path>) | CREATE | REFRESH (<reason>)
- **Next gate:** Awaiting approval before code | Awaiting approval before plan | Proceeding (<one-line reason>)
```

### Readiness output contract (hard)

- First content in the message MUST be the readiness block — no other heading or analysis before it.
- Heading exactly: `## Implement readiness` (no issue key suffix).
- Exactly four bullet lines: Flow, Research, Plan, Next gate — optional fifth `Reason:` line.
- Do not substitute narrative summaries or A/B/C menus for the block.

Normative detail lives in **`.cursor/skills/eversis-orchestrating-implementation/SKILL.md`** — do not duplicate the full contract here.

| Value | Meaning |
| --- | --- |
| **SKIP** | Existing artifact **adequately** covers current scope (adequacy checklist passed) |
| **CREATE** | No adequate artifact — write a new file |
| **DELTA** | Research exists but scope grew or checklist failed — **update the research file** in the same session |
| **REFRESH** | Plan exists but needs new tasks/phases for changed scope |

**Proceeding** is allowed when artifacts are ready **and** the user attached an approved plan, gave a QA fix list, or explicitly asked to implement. Otherwise use **Awaiting approval**.

### Adequacy checklist

Before `Research: SKIP` when `*.research.md` exists, verify: (1) latest QA comment / AC reflected, (2) root cause and paths match, (3) open questions do not block this scope, (4) plan tasks cover the fix if a plan exists. Any failure → **DELTA** or **REFRESH**, not SKIP.

Pure analysis can be done **without** `/eversis-implement`. When the user **does** invoke implement with analyze/research intent → Full + Plan SKIP (analysis-only) + research file in the same session.

You do **not** need to type “Research” in the prompt — the agent inspects the folder and attached `@*.plan.md` automatically ([Entry signals](../prompts/public/implement) in the Implement prompt).

## Entry signals (automatic)

| Signal | Default |
| --- | --- |
| No `*.research.md` / `*.plan.md` | Full Flow → create missing artifacts → human gate |
| `@*.plan.md` + adequate `*.research.md` (checklist pass) | Implement phase — **SKIP** new research/plan |
| QA comment / bugfix / retest / needs verification | Run adequacy checklist vs latest QA comment or AC |
| Research adequate for current scope | Research **SKIP**; Plan **SKIP** or **REFRESH** |
| Research stale vs current QA/AC | **Research: DELTA** → update file in same session |
| Plan exists but does not cover current fix | **Plan: REFRESH** → human gate |
| Analyze / research intent via `/eversis-implement` | Full; CREATE \| DELTA; Plan SKIP (analysis-only); gate before plan |
| Narrow fix, ≤3 files, adequacy pass | Quick Flow allowed |

## Quick vs Full

| | Quick Flow | Full Flow |
| --- | --- | --- |
| **When** | Narrow scope, ≤3 files, no ambiguity, no Figma/UI, planning readiness met | Cross-domain, ambiguous, missing/inadequate research/plan, >3 files, or any Figma/UI |
| **Skips** | Full research/plan/plan-review when criteria met and artifacts exist | Nothing — runs research → plan → plan validation → execution when gaps exist |
| **Ends with** | Validation → `@eversis-review` → Fine + fine-handoff | Per-task execution → UI gate → review → Fine + fine-handoff |

**Hard rule:** Any Figma or `[REUSE]` UI verification task **forces Full Flow**.

The Engineering Manager recommends a flow in chat; the user may override.

## Full Flow highlights

1. **Check existing artifacts first** — adequacy checklist before SKIP; create or DELTA when missing or stale.
2. Human plan review → Plan Reviewer (`@eversis-review-plan`) → max 3 iterations.
3. Use plan **Technical Context** when populated; otherwise delegate codebase discovery.
4. Route each plan task via the execution routing table (Software Engineer, DevOps, E2E, Prompt Engineer, UI Reviewer).
5. **Domain skills gate** — load stack-specific skills only when `eversis-project-stack.mdc` § Agent skills policy and the plan allow it.
6. Enforce per-item UI verification before code review.
7. Declare **Fine** and produce QA comment draft via `eversis-fine-handoff` in the same response.

## Connected Skills

- `eversis-fine-handoff` — mandatory QA comment draft on Fine
- `eversis-creating-implementation-plans` — plan structure and readiness
- `eversis-technical-context-discovering` — when to skip redundant discovery
- `eversis-ui-verifying` — UI verification gate standards
- `eversis-code-reviewing` — final review gate
