# Implement → Review → Fine continuity - Analysis Result

## Task Details

| Field | Value |
|---|---|
| Jira ID | **DHI-515** (Epic parent — child Story on plan approval / explicit OK) |
| Title | Orchestration continuity: auto-run Review then Fine after Implement |
| Source | Pilot / Implement sessions 2026-08-07 — agent stops after code and waits for `/eversis-review` |
| Priority | High (Delivery Standard friction; every Implement thread) |
| Spec folder | `docs/specs/dhi-515-implement-review-continuity/` |
| Estimated Effort | Small (SSOT wording + adapter sync + Channel notes) |

## Business Impact

Engineering Managers (and Cursor users) finish implementation, then **stall** waiting for a human to attach `/eversis-review`, even though the orchestration skill already requires **delegate review → Fine** in-session. That breaks the intended Delivery Standard loop, inflates turn count, and makes Fine feel optional. Aligning SSOT wording removes a false human gate without weakening Research/Plan approvals or Jira publish control.

## Gathered Information

### Root cause

| Source | Current wording / behavior | Effect |
|--------|----------------------------|--------|
| `.ai/rules/orchestration/agent-core.md` § Orchestration step 4 | **“Offer or request** the Review prompt” | Agents end the turn and ask the human to run `/eversis-review` |
| `.ai/skills/eversis-orchestrating-implementation` Quick + Full | **Delegate** `eversis-review` → on PASS go to Step 5 Fine | Intended auto continuity |
| `.ai/rules/orchestration/spec-driven-development.md` | Human gates listed for **Research** and **Plan** only | Review is a stage, not a human approval gate |
| Cursor `/eversis-review` command | Looks like a standalone entry | Reinforces “separate session / human must invoke” |
| Generated `.cursor/rules/eversis-agent-core.mdc` | Mirrors agent-core “Offer or request” | Cursor always-on rules teach the wrong stop |

### What must stay human-gated

- Approve research before plan  
- Approve plan before broad code  
- Confirm before changing a **reviewed** solution after BLOCKERs (existing orchestration rule)  
- Publish QA comment / Jira transition — **never** automatic  
- Opt-out (Continuity): user says **pause before review** or **review later** (only these two canonical phrases)  

### Related artifacts

- Prompt `eversis-implement` — says review gates + Fine in output, but does not forbid stopping for human Review  
- Prompt `eversis-review` — remains valid for **standalone** / re-review / review-only chats  
- `fine-handoff.md` / `eversis-fine-handoff` — Fine + QA draft same turn (already correct once Review runs)  
- Jira Delivery Standard block in SDD — “Review: load eversis-review before Done” reads as human attach  

### Out of scope

- Changing Research/Plan human gates  
- Auto-posting to Jira  
- Removing standalone `/eversis-review`  
- Consumer product code  
- Installer UX (separate umbrella under DHI-515: `pilot-feedback-framework-deltas`)  

## Proposed changes

| ID | Change | Files |
|----|--------|-------|
| **C1** | Replace “Offer or request” with **same-session execute/delegate** Review; then Fine on PASS | `agent-core.md` (+ sync → `.mdc`) |
| **C2** | Add **Continuity (default)** + **Opt-out** under Step 4 / execution rules | `eversis-orchestrating-implementation/SKILL.md` (+ website mirror if present) |
| **C3** | Explicit gate table: Review = **not** a human approval gate; Continuity note | `spec-driven-development.md` (+ sync `.mdc`) |
| **C4** | Jira Delivery Standard copy: Review runs **inside** Implement session by default; `/eversis-review` optional standalone | `spec-driven-development.md` |
| **C5** | `eversis-implement` executable/workflow: after code + checks, run Review then Fine same session unless opt-out | `.ai/prompts/public/eversis-implement.md` (+ command regenerate) |
| **C6** | Channel notes: `/eversis-implement` embeds Review+Fine; `/eversis-review` = standalone | `AGENTS.md` and/or `adapters/cursor/README.md` |
| **C7** | `npm run sync:adapters` after rule/prompt SSOT edits | adapters + `.cursor/rules` / `.cursor/commands` |

## Gap Analysis

### Question 1
#### Default: auto Review → Fine after Implement (no wait for human `/eversis-review`)?
**Locked (from analysis approval path):** **YES**

### Question 2
#### Opt-out phrases?
**Locked:** **YES** — canonical opt-out phrases only:
- `pause before review`
- `review later`

(Do **not** treat broader synonyms as required SSOT; agents may accept close paraphrases in chat, but docs list these two.)

### Question 3
#### Bundle all SSOT + sync in one PR under Epic DHI-515?
**Locked:** **YES** (Same PR)

### Question 4
#### Create Jira child Story under DHI-515?
**Locked:** **YES** — after plan approval, with explicit human OK to publish issue (do not auto-create in research turn)

### Question 5
#### Also refresh website docs skill page if it duplicates orchestration?
**Locked:** **YES if file duplicates** — update `website/docs/skills/orchestrating-implementation.md` only when it paraphrases Continuity / Step 4; otherwise leave or add a one-line pointer to the skill SSOT.

## Open questions for human (optional before implement)

- [x] Q1 — Auto continuity **YES**  
- [x] Q2 — Opt-out **YES** — phrases: `pause before review` / `review later`  
- [x] Q3 — Same PR **YES**  
- [x] Q4 — Jira child under DHI-515 **YES** (publish on explicit OK)  
- [x] Q5 — Website skill page **YES if duplicates**  

**Gate:** Approve research → approve plan → implement.

## Suggested next steps

1. ~~Human locks Q1–Q5.~~ **Done 2026-08-07.**  
2. Human **approve** this research + [`dhi-515-implement-review-continuity.plan.md`](./dhi-515-implement-review-continuity.plan.md).  
3. Create child Story under [DHI-515](https://eversis.atlassian.net/browse/DHI-515) on explicit OK.  
4. Implement C1–C7; sync adapters; review → Fine (continuity applies to that implement too).

## Changelog

| Date | Change |
|------|--------|
| 2026-08-07 | **CREATE** — continuity gap: agent-core “Offer or request” vs orchestration Delegate→Fine |
| 2026-08-07 | **DELTA** — locks Q1–Q4 from user request to author under DHI-515; plan co-authored |
| 2026-08-07 | **DELTA** — Q2 phrases locked (`pause before review` / `review later`); Q5 YES if duplicates |
