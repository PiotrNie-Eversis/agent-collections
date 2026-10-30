# ac-37-page-ux-recovery - Implementation Plan

## Task Details

| Field            | Value |
| ---------------- | ----- |
| Jira ID          | AC-37 |
| Title            | Prerequisites: Page UX and recovery |
| Description      | TOC dedupe (AC-50) + troubleshooting with screenshots (AC-51). **Canonical execution plan lives with AC-38** (combined thread). |
| Priority         | Medium |
| Related Research | [ac-37-page-ux-recovery.research.md](./ac-37-page-ux-recovery.research.md) |
| Canonical plan   | [../ac-38-enterprise-docker/ac-38-enterprise-docker.plan.md](../ac-38-enterprise-docker/ac-38-enterprise-docker.plan.md) |

## Wildly Important Goal

**Goal**: Prerequisites side navigation stays clean and readers can self-recover from common install/verification failures.

**Success Measure**: AC-50 and AC-51 acceptance criteria met as executed in Phases 2–4 of the canonical AC-38 combined plan.

**Do NOT touch / do NOT add**: See canonical plan. Do not maintain a second divergent task list here.

## Proposed Solution

Execute **Phases 2–4** (and shared Phase 5 review) of [`ac-38-enterprise-docker.plan.md`](../ac-38-enterprise-docker/ac-38-enterprise-docker.plan.md) after Phase 1 (AC-52). This file exists for Jira/spec-folder traceability only.

## Current Implementation Analysis

See canonical plan.

## Open Questions

| # | Question | Answer | Status |
| --- | --- | --- | --- |
| 1–3 | See research | Locked 2026-10-14 | ✅ Resolved |

## Technical Context

See canonical plan — same MDX page and `npm run website:build`.

## Implementation Plan

### Phase 1: Defer to canonical combined plan

**Goal**: Avoid duplicate task checkboxes that drift from AC-38 delivery order.

**Description**: All AC-37 tasks are Phase 2 (TOC), Phase 3 (screenshots + Common problems), Phase 4 (build), and Phase 5 (review) in the AC-38 plan.

**Verification:** Canonical plan Phases 2–5 DoD checkboxes.

#### Task 1.1 - [REUSE] Follow canonical plan Phases 2–5

**Description**: Implement AC-50 / AC-51 only via the combined plan; update checkboxes there.

**Files:** `docs/specs/ac-38-enterprise-docker/ac-38-enterprise-docker.plan.md` (reuse)

**Definition of Done**:

- [x] AC-50 and AC-51 Quality Assurance items checked in the canonical plan
- [x] Run `npm run website:build` as part of canonical Phase 4

## Security Considerations

See canonical plan (screenshot hygiene).

## Quality Assurance

- [x] AC-50 TOC criteria (canonical QA list)
- [x] AC-51 troubleshooting criteria (canonical QA list)

## Improvements (Out of Scope)

See canonical plan.

## Human gates

1. ~~Approve research~~ — done (`Q1. OK;` / `Q2. OK;` / `Q3. Implement with AC-38;`)
2. ~~Approve canonical plan~~ — done (`Plan is ok. Implement`)
3. ~~Implement → Review → Fine~~ — done 2026-10-14

## Changelog

| Date | Change Description |
| ------ | -------------------- |
| 2026-10-14 | Pointer plan created; execution owned by AC-38 combined plan |
| 2026-10-14 | Canonical plan Phases 2–5 complete; AC-50/AC-51 QA checked |
