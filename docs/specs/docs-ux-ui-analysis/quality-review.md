# docs-ux-ui-analysis — Quality Review Report

## Review Context

| Field | Value |
|---|---|
| Review Date | 2026-09-04 |
| Source Task List | `extracted-tasks.md` (Gate 1 approved 2026-09-04) |
| Additional Sources | `intent-brief.md`; source report `UX_UI Analysis_ Agent Collections Documentation.pdf` |
| Review Mode | Lite (3 epics, 10 stories — under the Lite threshold) |
| Passes Run | A, B, E, H, I |
| Epics Reviewed | 3 |
| Stories Reviewed | 10 |
| Total Suggestions | 4 |
| Accepted | 4 |
| Rejected | 0 |

---

## Domain Model

This backlog is a documentation-IA/content restructuring, not a data-entity application — "entities" below are content/structural artifacts the stories create or modify, not business records.

### Actors

| Actor | Epics Involved | Key Capabilities |
|---|---|---|
| First-time reader | 1, 2, 3 | Navigates by intent, reads plain-language framing, follows the canonical install checklist |
| Returning user | 1, 3 | Re-installs/updates via the canonical checklist, expects a stable sidebar |
| Technical decision-maker (CTO) | 1 | Chooses the CTO-focused path from the first-screen fork |
| Docs maintainer / docs-writer agent | 1, 2, 3 | Implements the IA restructuring, content rewrites, glossary, and template |

### Entities

| Entity | Created In | Read In | Updated In | Deactivated/Migrated In |
|---|---|---|---|---|
| Sidebar taxonomy (intent-based clusters) | 1.1 | 1.1, 1.2, 1.3 | 1.1 (ongoing) | 1.1 — old taxonomy retired (gap found: redirect handling — see S-02) |
| "Start here" signpost | 1.2 | 1.2 | — | — |
| CTO/beginner fork | 1.3 | 1.3 | — | — |
| Introduction page (plain-language framing) | 2.1 | 2.1, 3.2, 3.3 | 2.1 | — |
| Glossary / jargon explanations | — (gap found — see S-01) | 2.2 | — | — |
| Framework Reference page (restructured) | 2.3 | 2.3 | — | — |
| Overview list-item template (Agents/Skills/Prompts) | 2.4 | 2.4 | — | — |
| Canonical install checklist | 3.1 | 3.1 | — | 3.1 — old sequences retired/redirected |
| Pipeline diagram + time-savings framing (ported) | 3.2 | 3.2, 3.3 | — | — |
| Trust signal | 3.3 | 3.3 | — | — |

### Key Relationships

- The Sidebar taxonomy (1.1) is a prerequisite for the "Start here" signpost (1.2) and, loosely, the CTO/beginner fork (1.3).
- The Overview list-item template (2.4) shares surface area with the separate, non-Jira-ticketed `website-docs-skills-prompts-sync` content-accuracy audit — validated in 2.4 via S-04.
- The Trust signal (3.3) reuses the Pipeline diagram + time-savings framing (3.2) rather than sourcing new data.

---

## Suggestions

### Epic 1: Restructure documentation navigation by user intent

#### S-02 · High · ADD_ACCEPTANCE_CRITERION

**Target**: Story 1.1 — Replace artifact-type sidebar taxonomy with intent-based clusters

**Finding** (Pass A: Entity Lifecycle Completeness — retirement step):
Regrouping pages changes their paths, but the story didn't address what happens to existing inbound links (README, other docs pages, external references, search engine index) pointing at the current artifact-type paths.

**Proposed Change**:
Add to Story 1.1 acceptance criteria:
- [ ] GIVEN existing inbound links point at current artifact-type paths WHEN pages are regrouped THEN paths are preserved or redirects are put in place so existing links don't break.

**Decision**: ✅ Accepted

---

### Epic 2: Simplify first-screen language and content density

#### S-01 · High · ADD_ACCEPTANCE_CRITERION

**Target**: Story 2.2 — Add first-use explanations for SSOT, adapters, and MCP

**Finding** (Pass A: Entity Lifecycle Completeness):
Story 2.2 requires linking jargon to "a glossary entry," but no story in the backlog actually creates that glossary — the link target didn't exist anywhere in scope.

**Proposed Change**:
Add to Story 2.2 acceptance criteria:
- [ ] GIVEN no glossary currently exists WHEN this story is implemented THEN a glossary page/section is created (or an existing page is designated) as the link target before any inline links are added.

**Decision**: ✅ Accepted

---

#### S-04 · Medium · ADD_ACCEPTANCE_CRITERION

**Target**: Story 2.4 — Adopt a uniform one-line template for Agents/Skills/Prompts overview list items

**Finding** (Pass B: Cross-Feature State Validation):
Story 2.4 already noted a sequencing dependency on the separate `website-docs-skills-prompts-sync` content-accuracy audit (Dependencies table), but no acceptance criterion actually gated on it — the formatting pass could ship on top of known-inaccurate content.

**Proposed Change**:
Add to Story 2.4 acceptance criteria:
- [ ] GIVEN the `website-docs-skills-prompts-sync` content-accuracy audit is still open WHEN this story is scheduled THEN it does not proceed until that audit's corrections have landed for the pages it touches, or is explicitly descoped to formatting-only changes that don't depend on unresolved content accuracy.

**Decision**: ✅ Accepted

---

### Epic 3: Consolidate onboarding and bring landing-page strengths into docs

#### S-03 · Medium · ADD_ACCEPTANCE_CRITERION

**Target**: Story 3.2 — Port the homepage's pipeline diagram and time-savings framing into the docs Introduction

**Finding** (Pass H: Error State and Edge Case Coverage):
The ported diagram is a purely visual asset; no acceptance criterion addressed what a reader using a screen reader (or with images failing to load) sees instead.

**Proposed Change**:
Add to Story 3.2 acceptance criteria:
- [ ] GIVEN a reader who cannot see the diagram (screen reader, image load failure) WHEN it's ported into the docs Introduction THEN an equivalent text alternative (alt text or an adjacent plain-language summary) is provided.

**Decision**: ✅ Accepted

---

## Passes With No Findings

- **Pass E (Precondition Guards)**: No genuine software-style precondition gaps — a Docusaurus content site has no login/account state to guard against.
- **Pass I (Notification and Communication Gaps)**: Not applicable — no state change in this backlog affects an actor other than the one reading the page; there is no cross-actor notification need.

## Applied Changes Summary

| # | Suggestion | Action | Target |
|---|---|---|---|
| S-01 | Glossary has no creation story despite being linked | ADD_ACCEPTANCE_CRITERION | Story 2.2 |
| S-02 | No redirect/broken-link handling for regrouped sidebar paths | ADD_ACCEPTANCE_CRITERION | Story 1.1 |
| S-03 | Ported diagram has no accessible text alternative | ADD_ACCEPTANCE_CRITERION | Story 3.2 |
| S-04 | Template pass didn't gate on the related content-accuracy audit | ADD_ACCEPTANCE_CRITERION | Story 2.4 |

**Updated Totals**: 3 epics (unchanged), 10 stories (unchanged — 4 stories gained one acceptance criterion each)

## Rejected Suggestions

None.
