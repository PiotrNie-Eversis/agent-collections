# start-here-onboarding-ux — Extracted Tasks

## Workshop Summary

| Field | Value |
|---|---|
| Workshop Date | 2026-10-13 |
| Participants | UX reviewer; documentation maintainers |
| Source Materials | `cleaned-transcript.md`; `start-here.md`; intent brief |
| Intent Brief | `intent-brief.md` (Gate 0 skipped) |
| Project Baseline Used | None (overlap noted with AC-35/AC-36 Start here step 1 expansion) |
| Total Epics | 2 |
| Total Stories | 5 |

## Epics Overview

| # | Epic Title | Stories Count | Priority |
|---|-----------|---------------|----------|
| 1 | Start here — onboarding map rewrite | 4 | High |
| 2 | Start here — link integrity | 1 | High |

---

## Epic 1: Start here — onboarding map rewrite

**Business Description:** Non-technical readers (QA, BA, PO) and maintainers get a short, role-aware Start here page that acts as a map: what to do first, which path is theirs, how to know install succeeded, and where to go next — without repeating Prerequisites or exposing shell jargon on the critical path.

**Success Criteria:**

- A first-time QA/BA can choose their path and reach Installation/Prerequisites without reading a paragraph-length checklist item.
- Maintainers still find MCP / deeper links without competing unlabeled checklists.
- Page tip (“map, not encyclopedia”) matches the actual layout.

### Story 1.1: Short Prerequisites pointer on Start here

**User Story:** As a **QA or BA** opening Start here, I want the first step to be a short link to Prerequisites, so that I am not blocked by a wall of text that belongs on another page.

**Source:** Cleaned transcript — “Checklist item 1 is a wall of text”; recommendation mockup Step 1.

**Acceptance Criteria:**

- [ ] GIVEN Start here WHEN a reader scans the first onboarding step THEN the step is at most **two short sentences** plus a link to Prerequisites.
- [ ] GIVEN the short Prerequisites step WHEN a reader scans it without opening Prerequisites THEN the copy still names an **AI editor** (Cursor and/or Claude Code), **Docker Desktop**, and **Git** in at most two sentences before the link.
- [ ] GIVEN Prerequisites detail (GUI/CLI, Node, VS Code, accounts) WHEN Start here is updated THEN that detail is **not** duplicated inline on Start here.
- [ ] GIVEN English docs SSOT WHEN copy is written THEN sentences are full and plain language.

**High-Level Technical Notes:** Edit `website/docs/getting-started/start-here.md` only for this story.

**Priority:** High

### Story 1.2: Role-based path instead of two unlabeled checklists

**User Story:** As a **QA, BA, or PO**, I want Start here to show which install path is for me versus maintainers, so that I do not guess between “First successful install” and “Setup checklist (maintainers)”.

**Source:** Cleaned transcript — “Two competing checklists”; mockup role table.

**Acceptance Criteria:**

- [ ] GIVEN a first-time reader WHEN they open Start here THEN they see an explicit **role-based** choice (table and/or tabs) covering at least: **QA/BA/PO**, **developer / QA tech**, and **maintainer / MCP**.
- [ ] GIVEN QA/BA/PO WHEN they follow their row/path THEN they are directed to **Cursor-first** Prerequisites and Installation (not maintainer MCP depth as the default).
- [ ] GIVEN a QA/BA/PO reader WHEN they follow their role path THEN the path links **Prerequisites before or together with** Installation (they are not sent only to Installation as the first action).
- [ ] GIVEN maintainer / MCP WHEN they follow their path THEN they are directed to MCP setup / Node expectations without requiring QA readers to parse the same list.
- [ ] GIVEN the previous dual checklists WHEN the redesign ships THEN unlabeled competing “First successful install” vs “Setup checklist (maintainers)” sections are **removed or replaced** by the role-based structure.

**High-Level Technical Notes:** Prefer a **Markdown role table** (Gate 0 default); Tabs allowed if implementers choose MDX. Do not invent new installer modes.

**Priority:** High

### Story 1.3: Plain-language success criteria and next steps

**User Story:** As a **QA or BA**, I want a short “you’re done when…” checklist in everyday language, so that I know install worked without interpreting shell flags and MCP jargon on Start here.

**Source:** Cleaned transcript — jargon barrier; mockup “Kryteria sukcesu” and “Kolejne kroki”.

**Acceptance Criteria:**

- [ ] GIVEN Start here WHEN a reader finishes the guided path THEN the page lists **success criteria** in plain language (installer finished without error; expected project folders/files present; first AI prompt/`@eversis-implement` responds).
- [ ] GIVEN shell flags, `export`, submodule/copy modes, and MCP skill internals WHEN they appear THEN they are **not** required reading on Start here (details stay on Installation / MCP setup).
- [ ] GIVEN successful install WHEN the reader looks for what to do next THEN Start here links to **Quick wins** and **Main Flow / workflow overview** (or equivalent) as primary next steps.

**High-Level Technical Notes:** May keep one short “first prompt” line; avoid packing `--build-mcp --non-interactive` into the map page.

**Priority:** High

### Story 1.4: Remove redundant “In this section” and demote encyclopedic footer

**User Story:** As a **documentation reader**, I want Start here free of duplicate navigation lists, so that the page stays short and I use the sidebar / next-page controls instead.

**Source:** Cleaned transcript — “In this section” redundancy; mockup omits canonical GitLab block from primary path.

**Acceptance Criteria:**

- [ ] GIVEN Start here WHEN the redesign ships THEN the **In this section** list is removed (or proven non-redundant if intentionally kept — default: remove).
- [ ] GIVEN Requirements traceability and GitLab README/AGENTS links WHEN the redesign ships THEN they are **demoted** (moved to Framework reference only, or a clearly labeled maintainers/canonical note — not mixed into the primary onboarding steps).
- [ ] GIVEN sidebar and Previous/Next WHEN a reader navigates THEN they can still reach Prerequisites, Installation, MCP setup, and Quick wins.

**High-Level Technical Notes:** Coordinate with Story 1.2/1.3 so primary CTAs remain.

**Priority:** Medium

---

## Epic 2: Start here — link integrity

**Business Description:** Readers clicking Start here internal links land on the correct docs pages in both local preview and production — no `…/start-here/prerequisites` 404s.

**Success Criteria:**

- Spot-check of Start here internal docs links returns HTTP 200 (or correct client route) for Prerequisites, Installation, MCP setup, Quick wins, Domain Context, Framework, Main Flow.

### Story 2.1: Site-absolute internal links on Start here

**User Story:** As a **reader using local docs preview or production**, I want Start here links to open the real sibling pages, so that I am not stuck on 404 URLs under `/start-here/…`.

**Source:** Cleaned transcript — broken internal links; live incident 2026-10-13 (relative `./` + trailing slash).

**Acceptance Criteria:**

- [ ] GIVEN Start here WHEN internal docs links are inspected THEN they use **site-absolute** paths under `/docs/…` (or another Docusaurus-safe form that does not resolve under `/start-here/`).
- [ ] GIVEN local `yarn start` with a trailing-slash URL WHEN the reader clicks Prerequisites, Installation, MCP setup, Quick wins, Domain Context, and Framework reference THEN each target loads (no 404).
- [ ] GIVEN `npm run website:build` WHEN the story is Done THEN the build passes.

**High-Level Technical Notes:** Partial fix already on disk (absolute links). Treat as **verify + harden** any remaining relatives after Epic 1 rewrite.

**Priority:** High

---

## Dependencies

| Task | Depends On | Type | Notes |
|------|-----------|------|-------|
| Story 1.3 | Story 1.2 | Related to | Success criteria sit after role path |
| Story 1.4 | Story 1.2 | Related to | Remove lists after new structure exists |
| Story 2.1 | Story 1.1–1.4 | Related to | Re-verify links after rewrite |

## Assumptions

| # | Assumption | Confidence | Impact if Wrong |
|---|-----------|------------|-----------------|
| 1 | English remains SSOT; Polish mockup is intent only | High | Add i18n story |
| 2 | Role **table** is enough (Tabs optional) | Medium | Switch to Tabs in implement |
| 3 | Installation “copy-paste for QA” is out of this workshop | Medium | Expand epic or add AC-xx follow-up |
| 4 | Absolute `/docs/...` links are the chosen link strategy | High | Alternative: trailingSlash config — still verify |

## Out of Scope

- Prerequisites / Installation / MCP full rewrites.
- Installer or MCP runtime changes.
- Full Polish docs site.

## Human gates (workflow)

1. ~~Gate 0~~ — Skipped (see `intent-brief.md`)
2. ~~Gate 1 — Approve extracted tasks~~ — done (`gate 1 ok`)
3. ~~Gate 1.5 — Quality review~~ — done (S-01, S-02, S-03 accepted)
4. ~~Gate 2 — Jira push~~ — done 2026-10-13 (AC-55…AC-61; Relates AC-36)
