# docs-ux-ui-analysis - Extracted Tasks

## Workshop Summary

| Field | Value |
|---|---|
| Workshop Date | 2026-09-04 |
| Participants | User (Piotr Niemirski) |
| Source Materials | `UX_UI Analysis_ Agent Collections Documentation.pdf` ("UX/UI Analysis: Agent Collections Documentation vs. AI Hero Benchmark", 4 pages) |
| Intent Brief | `intent-brief.md` (Gate 0: Skipped — materials unambiguous) |
| Project Baseline Used | `docs/context/agent-collections/task-baseline.md` (stale — see Baseline Overlap notes in intent brief) |
| Target Jira Parent | **New Epic (to be created in project DHI)** — decided 2026-09-04, replaces the earlier DHI-515 assumption because DHI-515 is status "Done" |
| Total Epics | 3 |
| Total Stories | 10 |

## Epics Overview

| # | Epic Title | Stories Count | Priority |
|---|-----------|---------------|----------|
| 1 | Restructure documentation navigation by user intent | 3 | High |
| 2 | Simplify first-screen language and content density | 4 | High |
| 3 | Consolidate onboarding and bring landing-page strengths into docs | 3 | Medium |

## Epic 1: Restructure documentation navigation by user intent

**Business Description**: Readers currently have to understand the framework's internal taxonomy (rules vs. prompts vs. adapters vs. MCP) before they can find the right page, because the sidebar groups by artifact type across 13+ top-level sections. This epic regroups navigation around what a reader is trying to do (getting started, day-to-day flow, reference lookup, advanced/CTO topics), matching the benchmark's task-oriented model.

**Success Criteria**:
- A first-time reader can identify the section relevant to their current goal without first learning the framework's internal vocabulary.
- Top-level sidebar entries are reduced from 13+ to roughly 4-5 intent-based clusters.
- Every grouped section names a recommended starting point.

### Story 1.1: Replace artifact-type sidebar taxonomy with intent-based clusters

**User Story**: As a first-time reader of the documentation site, I want the sidebar organized by what I'm trying to do (get started / follow the day-to-day workflow / look something up / go deep as a technical decision-maker) instead of by internal artifact type, so that I can find the relevant page without first learning the framework's architecture.

**Source**: Report, "Recommended UX/UI Changes" §1 ("Restructure navigation by user intent, not artifact type"), p.3; corroborated by "Structural Comparison" table row "Primary organizing principle" and "Sidebar depth", p.2.

**Acceptance Criteria**:
- [ ] GIVEN the current sidebar (Introduction, Framework reference, Getting Started, Isolation and context reduction, Workflow, Team Guides, Agents, Domain Context, Prompts, Skills, Integrations, Use Cases, For CTOs) WHEN the navigation is restructured THEN the top-level sidebar contains roughly 4-5 clusters organized by user intent (e.g. Getting Started, The Main Flow, Reference, Advanced/CTO) rather than by artifact type.
- [ ] GIVEN a reader who wants to run their day-to-day Ideate → Implement → Review loop WHEN they open the sidebar THEN they land in a single cluster that covers that entire flow, without needing to cross-reference Agents/Prompts/Skills/Integrations separately.
- [ ] GIVEN existing pages under Agents, Prompts, Skills, and Integrations WHEN the restructuring is complete THEN every existing page is reachable from the new taxonomy (no content is dropped, only regrouped).
- [ ] GIVEN existing inbound links (README, other docs pages, external references, search engine index) point at current artifact-type paths WHEN pages are regrouped THEN paths are preserved or redirects are put in place so existing links don't break. *(added — Quality Review S-02, Pass A: Entity Lifecycle Completeness)*

**Additional Acceptance Checks**:
- Placement of the "Team Guides" section (shipped after the report was written) is a **deferred follow-up**, not a Gate 1 blocker (decided 2026-09-04) — implementer picks a reasonable initial placement; revisit as a follow-up note once the stakeholder has time to weigh in (see `intent-brief.md` Open Questions).

**High-Level Technical Notes**: None — this is a Docusaurus sidebar/folder regrouping under `website/docs/`, no new tooling implied by the report.

**Priority**: Critical

### Story 1.2: Add explicit "start here" signposting to every grouped section

**User Story**: As a reader entering a documentation section for the first time, I want an explicit recommended starting page called out in that section, so that I don't have to guess the right order to read pages in.

**Source**: Report, "Recommended UX/UI Changes" §5 ("Add explicit 'start here' signposting..."), p.4; benchmark pattern described in "Why AI Hero's Skills Page Reads Easily" ("Start with /grill-with-docs"), p.2.

**Acceptance Criteria**:
- [ ] GIVEN the new intent-based clusters from Story 1.1 WHEN a reader opens any cluster THEN that cluster's landing content names one explicit recommended starting page (e.g. "Start with ...").
- [ ] GIVEN the Getting Started, Agents, and Use Cases sections specifically (named in the report as currently lacking this) WHEN this story is complete THEN each shows a clear indication of priority or recommended reading order.

**High-Level Technical Notes**: None.

**Priority**: High

### Story 1.3: Introduce a persistent "For CTOs" / "For beginners" fork on the first screen

**User Story**: As a technical decision-maker evaluating the framework, I want to be offered a choice between a beginner path and a CTO-focused path on the very first screen, so that I land on content suited to my goal instead of one undifferentiated architecture-first narrative.

**Source**: Report, "Recommended UX/UI Changes" §8 ("Introduce a persistent 'For CTOs' / 'For beginners' fork early"), p.4.

**Acceptance Criteria**:
- [ ] GIVEN the docs Introduction page WHEN a reader first lands on it THEN they are presented with an explicit choice between a beginner-oriented path and the existing "For CTOs" content, similar in spirit to AI Hero's "What do you want to do?" card grid.
- [ ] GIVEN the existing `for-ctos.md` page WHEN this fork is added THEN it is surfaced from this first-screen choice rather than only being reachable via the sidebar.

**High-Level Technical Notes**: None.

**Priority**: Medium

## Epic 2: Simplify first-screen language and content density

**Business Description**: Multiple entry pages (Introduction, Framework reference, Start Here) front-load dense technical vocabulary (SSOT, adapters, MCP, "vendor-neutral multi-agent product engineering framework") and stack several distinct concept types on a single unbroken page. This epic re-sequences those pages to lead with plain-language framing, explains jargon on first use, and paces dense reference content so it doesn't overwhelm readers — technical or not.

**Success Criteria**:
- A reader unfamiliar with the framework's internal vocabulary can understand the problem/value proposition before encountering SSOT/adapter/MCP terminology.
- No single page compresses more than one or two distinct concept types (diagram, table, code block, prose) without a visual break.
- List-style overview pages (Agents, Skills, Prompts) follow one consistent, scannable template.

### Story 2.1: Move plain-language problem/fix framing above technical vocabulary on the Introduction page

**User Story**: As a new visitor to the docs site, I want the Introduction page to open with a plain-language statement of the problem and the fix, so that I understand the value before I'm asked to absorb framework-specific terminology.

**Source**: Report, "Recommended UX/UI Changes" §2 ("Move plain-language framing above technical vocabulary"), p.3; contrast example in "Why AI Hero's Skills Page Reads Easily" ("An agent is only as good as the process you give it..."), p.2; problem described in "Current State of Agent Collections Docs" §1, p.1.

**Acceptance Criteria**:
- [ ] GIVEN the current Introduction page (which opens with "vendor-neutral multi-agent product engineering framework" and a markdown reference table in paragraph two) WHEN it is rewritten THEN the first one or two sentences state the problem and the fix in plain language, before any framework-specific terminology appears.
- [ ] GIVEN the "What this framework provides" reference table currently in paragraph two WHEN the page is restructured THEN that table is moved lower on the page, after the plain-language framing, as reference material rather than the first thing a reader sees.

**High-Level Technical Notes**: None.

**Priority**: High

### Story 2.2: Add first-use explanations for SSOT, adapters, and MCP

**User Story**: As a reader encountering framework-specific terms (SSOT, adapters, MCP) for the first time, I want an inline explanation or a link to a glossary at first use, so that I'm not expected to already know the framework's internal taxonomy.

**Source**: Report, "Recommended UX/UI Changes" §2 (same paragraph as Story 2.1, "Terms like SSOT, adapters, and MCP should carry inline tooltips or a linked glossary on first use"), p.3-4.

**Acceptance Criteria**:
- [ ] GIVEN a page that uses the terms SSOT, adapters, or MCP WHEN the term appears for the first time on that page THEN it carries either an inline explanation, a tooltip, or a link to a glossary entry.
- [ ] GIVEN a reader who follows the glossary link THEN they reach a plain-language definition, not another page that assumes prior familiarity.
- [ ] GIVEN no glossary currently exists WHEN this story is implemented THEN a glossary page/section is created (or an existing page is designated) as the link target before any inline links are added. *(added — Quality Review S-01, Pass A: Entity Lifecycle Completeness)*

**High-Level Technical Notes**: None.

**Priority**: Medium

### Story 2.3: Break the Framework Reference page into shorter, single-concept sections

**User Story**: As a reader of the Framework Reference page, I want each distinct concept (model table, concept table, install snippet) presented in its own clearly separated section, so that I'm not asked to absorb six distinct concept types in one unbroken scroll.

**Source**: Report, "Current State of Agent Collections Docs" §3 (describes six distinct concept types compressed into one page), p.1; "Recommended UX/UI Changes" §6 ("Break dense reference pages into shorter, single-concept pages with visual pacing"), p.4.

**Acceptance Criteria**:
- [ ] GIVEN the current Framework Reference page (which stacks a Model table, a second Core/Adapter/Consumer/Related-product table, and a bash install snippet with no visual pacing) WHEN it is restructured THEN each of these gets its own subsection with a heading, a short intro sentence, and visible separation from the next.
- [ ] GIVEN a technically sophisticated reader WHEN they scan the restructured page THEN they can locate a specific concept (e.g. the Model table) without reading unrelated sections first.

**High-Level Technical Notes**: None — report frames this as content re-sequencing, not a new page-layout mechanism.

**Priority**: Medium

### Story 2.4: Adopt a uniform one-line template for Agents/Skills/Prompts overview list items

**User Story**: As a reader browsing the Agents, Skills, or Prompts overview pages, I want every entry to follow the same short template (name, bolded title, one clause describing the outcome), so that I can scan the list quickly instead of parsing inconsistent paragraph-vs-bare-name formatting.

**Source**: Report, "Recommended UX/UI Changes" §3 ("Adopt a uniform one-line template for list items"), p.4; benchmark pattern in "Why AI Hero's Skills Page Reads Easily" ("slash-command name, bolded skill title, one short sentence describing the outcome"), p.2.

**Acceptance Criteria**:
- [ ] GIVEN the Agents Overview and Skills Overview pages (currently varying between full paragraphs and bare names with no description) WHEN this story is complete THEN every entry follows one consistent pattern: name — bolded title — one clause describing the outcome.
- [ ] GIVEN this template is applied THEN it is used consistently across Agents, Skills, and Prompts overview pages (not only one of the three).
- [ ] GIVEN the `docs/specs/website-docs-skills-prompts-sync/` content-accuracy audit is still open WHEN this story is scheduled THEN it does not proceed until that audit's corrections have landed for the pages it touches, or is explicitly descoped to formatting-only changes that don't depend on unresolved content accuracy. *(added — Quality Review S-04, Pass B: Cross-Feature State Validation)*

**Additional Acceptance Checks**:
- Sequencing note (see `intent-brief.md` Baseline Overlap): coordinate with the existing `docs/specs/website-docs-skills-prompts-sync/` content-accuracy audit, since both touch the same Agents/Skills/Prompts pages — that audit's corrections should land before or alongside this formatting pass to avoid rework.

**High-Level Technical Notes**: None.

**Priority**: High

## Epic 3: Consolidate onboarding and bring landing-page strengths into docs

**Business Description**: Installation/onboarding instructions currently appear in three different forms across three pages (Framework reference, homepage, Start Here), forcing returning users to reconcile slightly different sequences on every visit. Separately, the marketing homepage already uses patterns — a pipeline diagram, concrete time-savings numbers, trust signals — that make it more compelling than the docs section it links into. This epic picks one canonical onboarding path and ports the homepage's stronger patterns into the docs Introduction.

**Success Criteria**:
- Exactly one installation sequence exists across the site; all other pages link to it rather than repeating a divergent version.
- The docs Introduction carries the same credibility signals (pipeline visual, outcome framing, trust signal) that currently only appear on the marketing homepage.

### Story 3.1: Consolidate three divergent install sequences into one canonical checklist

**User Story**: As a returning user setting up the framework, I want a single canonical installation checklist that every page links to, so that I don't have to reconcile three different sequences with different step counts depending on which page I land on.

**Source**: Report, "Why AI Hero's Skills Page Reads Easily" (describes the three divergent sequences: git clone/export snippet on Framework page, six-step "Set up once" on homepage, five-step "First successful install checklist" on Getting Started page), p.2; "Recommended UX/UI Changes" §4 ("Consolidate onboarding into one canonical checklist"), p.4; root cause "Fragmented, duplicated onboarding", p.3.

**Acceptance Criteria**:
- [ ] GIVEN the three existing install sequences (Framework page git clone/export snippet, homepage six-step "Set up once", Start Here five-step "First successful install checklist") WHEN this story is complete THEN the "First successful install checklist" on the Start Here page is the single canonical sequence, and the other two are replaced with a link/redirect to it rather than a separate, divergent list of steps.
- [ ] GIVEN a reader on any page that references installation WHEN they follow the instructions THEN they see the same step count and the same command every time.

**High-Level Technical Notes**: None — content consolidation, not a change to the underlying install script/command itself.

**Priority**: High

### Story 3.2: Port the homepage's pipeline diagram and time-savings framing into the docs Introduction

**User Story**: As a reader who clicks from the marketing homepage into `/docs`, I want the same pipeline visual and outcome framing (e.g. "~15 min vs 1-2 days") to carry into the docs Introduction, so that the value proposition I saw on the homepage doesn't disappear the moment I enter the docs.

**Source**: Report, "Current State of Agent Collections Docs" §4 (describes the homepage's pipeline diagram, agent cards, and time-savings callouts not carrying into `/docs`), p.1; "Recommended UX/UI Changes" §7 ("Bring the landing page's stronger patterns into the docs"), p.4.

**Acceptance Criteria**:
- [ ] GIVEN the marketing homepage's visual pipeline diagram and "~15 min vs 1-2 days"-style outcome framing WHEN the docs Introduction is updated THEN a condensed version of that same diagram and framing appears on the Introduction page.
- [ ] GIVEN a reader who visits the homepage first and then clicks into `/docs` WHEN they land on the Introduction THEN the visual/tonal continuity is preserved rather than dropping into a plain architecture-first narrative.
- [ ] GIVEN a reader who cannot see the diagram (screen reader, image load failure) WHEN it's ported into the docs Introduction THEN an equivalent text alternative (alt text or an adjacent plain-language summary) is provided. *(added — Quality Review S-03, Pass H: Error State and Edge Case Coverage)*

**High-Level Technical Notes**: None — report notes this does not require abandoning Docusaurus or existing content, only re-sequencing and porting existing homepage components.

**Priority**: Medium

### Story 3.3: Add a trust/social-proof signal to the docs Introduction

**User Story**: As a first-time reader evaluating whether to invest time in this framework, I want to see a concrete trust signal (comparable to AI Hero's GitHub star count and "engineers trained" figure) on the docs Introduction, so that I have external validation before committing to the onboarding path.

**Source**: Report, "Structural Comparison" table row "Social proof / trust signal" ("Time-savings estimates on landing page only, absent from docs" vs. AI Hero's "GitHub star count + 'Engineers trained: 8,500+' on homepage"), p.2; "Why AI Hero's Skills Page Reads Easily" §3, p.2.

**Acceptance Criteria**:
- [ ] GIVEN the docs Introduction page currently has no trust/social-proof signal WHEN this story is complete THEN it displays at least one concrete, verified trust signal near the installation call-to-action.
- [ ] GIVEN no confirmed external metric exists for this project (no public GitHub star count or "engineers trained" figure — this is an internal Eversis framework, not a public open-source project) WHEN the signal is chosen THEN it reuses the **already-verified** time-savings framing ("~15 min vs 1-2 days") that Story 3.2 ports from the marketing homepage, rather than introducing a new, unverified metric.

**Additional Acceptance Checks**:
- **Resolved 2026-09-04** (stakeholder decision, on BA recommendation): do not fabricate a stars/installs/trained-engineers figure. Since this is an internal, not public-facing, project, no equivalent to AI Hero's GitHub star count is available or meaningful. Reuse the confirmed time-savings framing already on the homepage as the trust signal; this effectively makes Story 3.3 a light extension of Story 3.2 (same source content, applied as a trust cue rather than only outcome framing). If a future numeric adoption signal becomes available (e.g. teams onboarded, specs delivered via the framework), it can be added later as a separate, real-data-backed follow-up — not a rework of this story.

**High-Level Technical Notes**: None.

**Priority**: Low

## Dependencies

| Task | Depends On | Type | Notes |
|------|-----------|------|-------|
| Story 1.2 | Story 1.1 | Blocked by | Signposting needs the new intent-based clusters to exist before "start here" labels can be added to them. |
| Story 1.3 | Story 1.1 | Related to | The CTO/beginner fork should reflect the same clusters introduced by the sidebar restructuring, though it can be scoped independently. |
| Story 2.4 | `docs/specs/website-docs-skills-prompts-sync/` (existing, non-Jira-ticketed audit) | Related to | Both touch the same Agents/Skills/Prompts overview pages — content-accuracy corrections from that audit should land before or alongside the formatting pass here. |
| Story 3.1 | Story 1.2 | Related to | Both concern consistent signposting/onboarding guidance; not a hard block. |
| Epic 2 | Epic 1 | Related to | Content-density and navigation work touch overlapping pages (Introduction, Framework reference); sequencing within a single delivery wave is recommended but not a hard dependency. |

## Assumptions

| # | Assumption | Confidence | Impact if Wrong |
|---|-----------|------------|-----------------|
| 1 | The Start Here page's "First successful install checklist" is the correct canonical sequence to keep (vs. the homepage or Framework-reference version) — the report doesn't explicitly rank the three, but describes this one as "explicitly designed as the onboarding path." | Medium | If a different sequence should be canonical, Story 3.1's acceptance criteria need to name a different source page. |
| 2 | "Team Guides" placement within the new intent-based IA (Story 1.1) is left as an implementation-time decision unless the stakeholder answers the open question first. | Medium | Could require rework of the new sidebar clusters if the stakeholder wants it placed differently after Story 1.1 ships. |
| 3 | ~~This backlog should be pushed under Jira epic DHI-515~~ — **superseded 2026-09-04**: stakeholder decided to create a **new, separate Epic** in project DHI instead, since DHI-515 is status "Done". Epic title/key to be finalized during Jira formatting (Gate 2). | High | N/A — resolved. |

## Out of Scope

Items explicitly excluded from this task breakdown:
- Visual/graphic redesign (colors, illustrations, branding) — report explicitly frames its recommendations as structural/content-ordering, not visual redesign.
- Changes to the AI Hero site — external benchmark reference only.
- Marketing homepage rework — the report treats the homepage as already strong; only *porting* its patterns into `/docs` is in scope (Epic 3).
- Any functional/non-UX defect — none were reported in this material.

## Open Questions for Stakeholders

All three original questions were addressed by the stakeholder on 2026-09-04 — see below. Q1 is deferred as a **follow-up** (not a Gate 1/2 blocker); Q2 and Q3 are **resolved**.

| # | Question | Context | Status |
|---|----------|---------|--------|
| 1 | Should "Team Guides" become its own top-level cluster in the new intent-based IA, or fold into "Main Flow" / "Reference"? | Team Guides shipped after this report was written, so it isn't addressed by the source material. | **Deferred — follow-up.** Implementer picks a reasonable initial placement for Story 1.1; revisit later, not tracked as a separate ticket for now. |
| 2 | What real data should back the trust/social-proof signal in Story 3.3? | The report cites AI Hero's star count and "engineers trained" figure, but no equivalent exists for this internal, non-public project. | **Resolved.** Reuse the already-verified homepage time-savings framing (see Story 3.3) instead of fabricating a metric. |
| 3 | Confirm DHI-515 is still the correct parent epic given its Jira status is "Done". | See former Assumption 3. | **Resolved.** Create a new, separate Epic in project DHI as the parent instead of DHI-515. |
