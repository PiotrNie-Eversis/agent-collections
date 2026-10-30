# Implement → Review → Fine continuity - Implementation Plan

**Status:** Fine (2026-08-07) — Review PASS  
**Jira:** Child Story under Epic [DHI-515](https://eversis.atlassian.net/browse/DHI-515) (create on explicit human OK)  
**Research:** [`dhi-515-implement-review-continuity.research.md`](./dhi-515-implement-review-continuity.research.md)  
**Research locks:** Auto continuity YES · Opt-out `pause before review` / `review later` · Same PR · DHI-515 child · Q5 website YES if duplicates  

### Changelog (implement)

| Date | Change |
|------|--------|
| 2026-08-07 | OK IMPLEMENT; Phases 1–5; sync:adapters:check OK; Review PASS → Fine |

## Overview

Align orchestration SSOT so that after approved Implement work and green checks, the Engineering Manager **runs `eversis-review` in the same session** and on **PASS** declares **Fine + QA draft in the same turn**, without waiting for the human to invoke `/eversis-review`. Keep Research/Plan human gates, BLOCKER confirm-before-fix, Jira publish gate, and standalone review command.

## Technical Context

| Item | Detail |
|------|--------|
| SSOT rules | `.ai/rules/orchestration/agent-core.md`, `spec-driven-development.md`, `engineering-manager.md` |
| Skill | `.ai/skills/eversis-orchestrating-implementation/SKILL.md` |
| Prompt | `.ai/prompts/public/eversis-implement.md` |
| Packaging | `npm run sync:adapters` + `sync:adapters:check` |
| Docs | `AGENTS.md`, `adapters/cursor/README.md`, `website/docs/skills/orchestrating-implementation.md` |
| Quality | `npm run sync:adapters:check` PASS |

## Acceptance criteria checklist

- [x] GIVEN Implement session after code + checks WHEN no opt-out THEN agent runs `eversis-review` without asking human to attach `/eversis-review`
- [x] GIVEN review PASS WHEN Fine path THEN Fine + QA draft in same turn (existing fine-handoff)
- [x] GIVEN user says `pause before review` or `review later` WHEN after implement THEN agent stops before review (no auto Fine)
- [x] GIVEN Research/Plan WHEN Delivery Standard THEN human gates unchanged
- [x] GIVEN BLOCKER review WHEN fix needed THEN still confirm before changing reviewed solution
- [x] GIVEN Jira publish WHEN Fine THEN still requires explicit human OK
- [x] GIVEN `npm run sync:adapters:check` WHEN Done THEN exit 0
- [x] GIVEN generated `eversis-agent-core.mdc` WHEN synced THEN no “Offer or request” Review stop
- [x] Delivery Standard: research approved → plan approved → implement → review → Fine

## Definition of done

1. Phases 1–4 complete — **done**  
2. Acceptance criteria checked — **done**  
3. Review PASS + Fine QA draft — **this turn**  
4. Single PR; Jira child under DHI-515 when human OK  

## Code Review Findings

**Verdict: PASS** (2026-08-07)

| Severity | Finding | Resolution |
|----------|---------|------------|
| — | No BLOCKERs | — |
| SUGGESTION | Continuity is documentation/SSOT only — no automated test that agents stop asking for `/eversis-review` | Acceptable; behavior enforced by always-on rules + skill |
| NOTE | `docs/specs/dhi-*/` remains gitignored | Local SDD artifacts by design |
| NOTE | Scope limited to orchestration SSOT + generated packaging + Channel notes | STRICT FORBIDDEN OK |

STRICT FORBIDDEN: scope OK; no silent comment stripping; no new package deps.

## Human gates

1. ~~Approve research~~  
2. ~~Approve plan~~ — OK IMPLEMENT 2026-08-07  
3. Explicit OK to create Jira Story under DHI-515  
4. Explicit OK to commit / PR  

## Changelog

| Date | Change |
|------|--------|
| 2026-08-07 | **CREATE** — plan from continuity research under Epic DHI-515 |
| 2026-08-07 | **DELTA** — Q2 opt-out phrases narrowed; Q5 conditional website sync |
| 2026-08-07 | **DELTA** — implemented; sync check OK; Review PASS; Fine |
