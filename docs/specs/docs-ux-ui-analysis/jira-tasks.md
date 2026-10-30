# docs-ux-ui-analysis — Jira-Ready Tasks

Source: `extracted-tasks.md` (Gate 1 approved 2026-09-04) + `quality-review.md` (4/4 suggestions accepted).

**Target Jira project**: DHI (DAWIS HSOM Internal)
**Target parent**: New Epic (created by this push, replacing the earlier DHI-515 assumption — DHI-515 is status "Done")
**Issue type for the 10 children**: `Task` (confirmed by stakeholder 2026-09-04, matching DHI-515's existing convention). The story-numbering (1.1, 1.2, ... 3.3) and benchmark "Story" template/fields are kept for backlog-structuring purposes locally; all 10 are created in Jira as issue type `Task`.
**Push approval**: Confirmed by stakeholder 2026-09-04 — create the new Epic and all 10 Tasks in one batch.

---

## Epic: Documentation Site: UX/UI Restructuring (Intent-Based IA)

**Jira Key**: DHI-641
**Status**: To Do
**Priority**: Highest

**Description**:
```
h2. Overview

Restructure the Agent Collections Docusaurus documentation site (/docs) from an artifact-type navigation model (Agents / Prompts / Skills / Integrations / Workflow / Team Guides) to an intent-based model (what the reader is trying to do), and re-sequence dense first-screen and reference content to lead with plain language. Based on an external UX/UI benchmark report comparing this site against the AI Hero /skills page.

h2. Business Value

New readers currently must learn the framework's internal taxonomy (SSOT, adapters, MCP, rules vs. prompts vs. skills) before they can find the page relevant to their goal, and face three divergent installation sequences depending on which page they land on. This epic removes that friction, reducing the risk that first-time evaluators abandon the framework as "too complex" before reaching real content.

h2. Success Metrics

* Top-level sidebar reduced from 13+ artifact-type sections to roughly 4-5 intent-based clusters
* Exactly one canonical installation sequence exists across the site
* Docs Introduction leads with plain-language problem/fix framing before technical vocabulary
* Agents/Skills/Prompts overview pages use one consistent one-line entry template
```

**Acceptance Criteria**:
```
(/) Sidebar navigation is reorganized into intent-based clusters (Getting Started / Main Flow / Reference / Advanced-CTO) with no content dropped
(/) Every grouped section names an explicit recommended starting page
(/) Docs Introduction opens with plain-language problem/fix framing before SSOT/adapters/MCP terminology, and those terms carry first-use explanations
(/) Framework Reference page is broken into single-concept sections with visual pacing
(/) Agents/Skills/Prompts overview entries follow one consistent one-line template
(/) Exactly one canonical installation checklist exists; other pages link to it instead of repeating divergent steps
(/) Docs Introduction carries a pipeline diagram, outcome framing, and a verified (non-fabricated) trust signal ported from the marketing homepage
```

**Labels**: `documentation`, `ux-ui`, `workshop-2026-09-04`

---

### Story 1.1: Reader can navigate the sidebar by intent instead of artifact type

**Parent**: Documentation Site: UX/UI Restructuring (Intent-Based IA)
**Jira Key**: DHI-642
**Status**: To Do
**Priority**: Highest
**Sizing Guidance**: Large (13+)

**Description**:
```
h2. Context

This story is part of the [Documentation Site: UX/UI Restructuring (Intent-Based IA)] epic — sub-track: Restructure documentation navigation by user intent. It is the foundational IA change the rest of the epic builds on.

h2. Source Context

Report "UX/UI Analysis: Agent Collections Documentation vs. AI Hero Benchmark", "Recommended UX/UI Changes" §1, p.3; corroborated by the "Structural Comparison" table ("Primary organizing principle", "Sidebar depth"), p.2.

h2. User Story

As a first-time reader of the documentation site, I want the sidebar organized by what I'm trying to do (get started / follow the day-to-day workflow / look something up / go deep as a technical decision-maker) instead of by internal artifact type, so that I can find the relevant page without first learning the framework's architecture.

h2. Requirements

# Replace the current artifact-type sidebar (Agents / Prompts / Skills / Integrations / Workflow / Team Guides / etc.) with roughly 4-5 intent-based clusters (e.g. Getting Started, The Main Flow, Reference, Advanced/CTO)
# Every existing page currently under Agents, Prompts, Skills, and Integrations remains reachable from the new taxonomy — regroup, do not delete
# Decide and document a placement for the "Team Guides" section (shipped after the source report was written) as part of this restructuring — deferred decision, implementer's call, revisit later
# Preserve or redirect existing inbound links (README, other docs pages, external references, search index) that point at current artifact-type paths

h2. Delivery Standard

This story follows full spec-driven development (mandatory under Agent Collections / epic TASK-515 when applicable).

* Spec folder: docs/specs/<issue-kebab>/
* Research: <issue-kebab>.research.md — required before plan
* Plan: <issue-kebab>.plan.md — required before implementation
* Implement: load eversis-implement (approved plan attached)
* Review: load eversis-review before Done
* Fine: QA comment draft per eversis-fine-handoff

Do not start implementation without approved research and plan artifacts.

Optional (Cursor): you may also attach the same prompts with @eversis-implement / @eversis-review if your project surfaces those files in Cursor.

h2. Technical Notes

Docusaurus sidebar/folder regrouping under website/docs/ (sidebars.ts uses a single autogenerated tree keyed on folder structure — no separate sidebar config edit implied). No new tooling required.
```

**Acceptance Criteria**:
```
(/) Top-level sidebar contains roughly 4-5 clusters organized by user intent rather than by artifact type
(/) A reader following the day-to-day Ideate to Review loop lands in a single cluster covering that entire flow, without cross-referencing Agents/Prompts/Skills/Integrations separately
(/) Every existing page under Agents, Prompts, Skills, and Integrations is reachable from the new taxonomy
(/) Existing inbound links to current artifact-type paths are preserved or redirected so they don't break
```

**Labels**: `documentation`, `ux-ui`, `nav-ia`, `workshop-2026-09-04`

---

### Story 1.2: Reader sees an explicit "start here" recommendation in every section

**Parent**: Documentation Site: UX/UI Restructuring (Intent-Based IA)
**Jira Key**: DHI-643
**Status**: To Do
**Priority**: High
**Sizing Guidance**: Small (1-3)

**Description**:
```
h2. Context

This story is part of the [Documentation Site: UX/UI Restructuring (Intent-Based IA)] epic — sub-track: Restructure documentation navigation by user intent. It depends on Story 1.1's new clusters existing.

h2. Source Context

Report, "Recommended UX/UI Changes" §5, p.4; benchmark pattern in "Why AI Hero's Skills Page Reads Easily" ("Start with /grill-with-docs"), p.2.

h2. User Story

As a reader entering a documentation section for the first time, I want an explicit recommended starting page called out in that section, so that I don't have to guess the right order to read pages in.

h2. Requirements

# Every intent-based cluster from Story 1.1 names one explicit recommended starting page in its landing content
# Getting Started, Agents, and Use Cases sections specifically (named in the source report as currently lacking this) show a clear indication of priority or recommended reading order

h2. Delivery Standard

This story follows full spec-driven development (mandatory under Agent Collections / epic TASK-515 when applicable).

* Spec folder: docs/specs/<issue-kebab>/
* Research: <issue-kebab>.research.md — required before plan
* Plan: <issue-kebab>.plan.md — required before implementation
* Implement: load eversis-implement (approved plan attached)
* Review: load eversis-review before Done
* Fine: QA comment draft per eversis-fine-handoff

Do not start implementation without approved research and plan artifacts.

Optional (Cursor): you may also attach the same prompts with @eversis-implement / @eversis-review if your project surfaces those files in Cursor.

h2. Technical Notes

No specific technical considerations discussed.
```

**Acceptance Criteria**:
```
(/) Every intent-based cluster names one explicit recommended starting page
(/) Getting Started, Agents, and Use Cases sections show a clear indication of priority/recommended order
```

**Labels**: `documentation`, `ux-ui`, `nav-ia`, `workshop-2026-09-04`

---

### Story 1.3: CTO or beginner reader can choose their path from the first screen

**Parent**: Documentation Site: UX/UI Restructuring (Intent-Based IA)
**Jira Key**: DHI-644
**Status**: To Do
**Priority**: Medium
**Sizing Guidance**: Medium (5-8)

**Description**:
```
h2. Context

This story is part of the [Documentation Site: UX/UI Restructuring (Intent-Based IA)] epic — sub-track: Restructure documentation navigation by user intent.

h2. Source Context

Report, "Recommended UX/UI Changes" §8, p.4.

h2. User Story

As a technical decision-maker evaluating the framework, I want to be offered a choice between a beginner path and a CTO-focused path on the very first screen, so that I land on content suited to my goal instead of one undifferentiated architecture-first narrative.

h2. Requirements

# Docs Introduction page presents an explicit choice between a beginner-oriented path and the existing "For CTOs" content on first load, similar in spirit to AI Hero's "What do you want to do?" card grid
# The existing for-ctos.md page is surfaced from this first-screen choice, not only reachable via the sidebar

h2. Delivery Standard

This story follows full spec-driven development (mandatory under Agent Collections / epic TASK-515 when applicable).

* Spec folder: docs/specs/<issue-kebab>/
* Research: <issue-kebab>.research.md — required before plan
* Plan: <issue-kebab>.plan.md — required before implementation
* Implement: load eversis-implement (approved plan attached)
* Review: load eversis-review before Done
* Fine: QA comment draft per eversis-fine-handoff

Do not start implementation without approved research and plan artifacts.

Optional (Cursor): you may also attach the same prompts with @eversis-implement / @eversis-review if your project surfaces those files in Cursor.

h2. Technical Notes

No specific technical considerations discussed.
```

**Acceptance Criteria**:
```
(/) Docs Introduction page presents an explicit beginner vs. CTO choice on first load
(/) The choice surfaces the existing for-ctos.md content directly, not only via the sidebar
```

**Labels**: `documentation`, `ux-ui`, `nav-ia`, `workshop-2026-09-04`

---

### Story 2.1: Reader sees plain-language framing before technical vocabulary on the Introduction page

**Parent**: Documentation Site: UX/UI Restructuring (Intent-Based IA)
**Jira Key**: DHI-645
**Status**: To Do
**Priority**: High
**Sizing Guidance**: Medium (5-8)

**Description**:
```
h2. Context

This story is part of the [Documentation Site: UX/UI Restructuring (Intent-Based IA)] epic — sub-track: Simplify first-screen language and content density.

h2. Source Context

Report, "Recommended UX/UI Changes" §2, p.3; contrast example in "Why AI Hero's Skills Page Reads Easily" ("An agent is only as good as the process you give it..."), p.2; problem described in "Current State of Agent Collections Docs" §1, p.1.

h2. User Story

As a new visitor to the docs site, I want the Introduction page to open with a plain-language statement of the problem and the fix, so that I understand the value before I'm asked to absorb framework-specific terminology.

h2. Requirements

# Rewrite the Introduction page opening so the first one or two sentences state the problem and the fix in plain language, before any framework-specific terminology
# Move the "What this framework provides" reference table (currently in paragraph two) lower on the page, after the plain-language framing

h2. Delivery Standard

This story follows full spec-driven development (mandatory under Agent Collections / epic TASK-515 when applicable).

* Spec folder: docs/specs/<issue-kebab>/
* Research: <issue-kebab>.research.md — required before plan
* Plan: <issue-kebab>.plan.md — required before implementation
* Implement: load eversis-implement (approved plan attached)
* Review: load eversis-review before Done
* Fine: QA comment draft per eversis-fine-handoff

Do not start implementation without approved research and plan artifacts.

Optional (Cursor): you may also attach the same prompts with @eversis-implement / @eversis-review if your project surfaces those files in Cursor.

h2. Technical Notes

No specific technical considerations discussed.
```

**Acceptance Criteria**:
```
(/) First one or two sentences of the Introduction page state the problem and fix in plain language before any framework-specific terminology appears
(/) The "What this framework provides" table is positioned after the plain-language framing, as reference material rather than the first thing a reader sees
```

**Labels**: `documentation`, `ux-ui`, `content-density`, `workshop-2026-09-04`

---

### Story 2.2: Reader sees an explanation the first time SSOT, adapters, or MCP is used

**Parent**: Documentation Site: UX/UI Restructuring (Intent-Based IA)
**Jira Key**: DHI-646
**Status**: To Do
**Priority**: Medium
**Sizing Guidance**: Medium (5-8)

**Description**:
```
h2. Context

This story is part of the [Documentation Site: UX/UI Restructuring (Intent-Based IA)] epic — sub-track: Simplify first-screen language and content density.

h2. Source Context

Report, "Recommended UX/UI Changes" §2, p.3-4 ("Terms like SSOT, adapters, and MCP should carry inline tooltips or a linked glossary on first use").

h2. User Story

As a reader encountering framework-specific terms (SSOT, adapters, MCP) for the first time, I want an inline explanation or a link to a glossary at first use, so that I'm not expected to already know the framework's internal taxonomy.

h2. Requirements

# Create a glossary page/section (or designate an existing page) as the link target — none currently exists
# Every page that uses SSOT, adapters, or MCP carries either an inline explanation, a tooltip, or a link to the glossary the first time the term appears on that page
# Glossary entries are plain-language definitions, not pages that assume prior familiarity

h2. Delivery Standard

This story follows full spec-driven development (mandatory under Agent Collections / epic TASK-515 when applicable).

* Spec folder: docs/specs/<issue-kebab>/
* Research: <issue-kebab>.research.md — required before plan
* Plan: <issue-kebab>.plan.md — required before implementation
* Implement: load eversis-implement (approved plan attached)
* Review: load eversis-review before Done
* Fine: QA comment draft per eversis-fine-handoff

Do not start implementation without approved research and plan artifacts.

Optional (Cursor): you may also attach the same prompts with @eversis-implement / @eversis-review if your project surfaces those files in Cursor.

h2. Technical Notes

No specific technical considerations discussed.
```

**Acceptance Criteria**:
```
(/) A glossary page/section exists as the link target before any inline links are added
(/) SSOT, adapters, and MCP each carry an inline explanation, tooltip, or glossary link on first use per page
(/) Following a glossary link reaches a plain-language definition
```

**Labels**: `documentation`, `ux-ui`, `content-density`, `workshop-2026-09-04`

---

### Story 2.3: Reader can scan the Framework Reference page as single-concept sections

**Parent**: Documentation Site: UX/UI Restructuring (Intent-Based IA)
**Jira Key**: DHI-647
**Status**: To Do
**Priority**: Medium
**Sizing Guidance**: Medium (5-8)

**Description**:
```
h2. Context

This story is part of the [Documentation Site: UX/UI Restructuring (Intent-Based IA)] epic — sub-track: Simplify first-screen language and content density.

h2. Source Context

Report, "Current State of Agent Collections Docs" §3, p.1; "Recommended UX/UI Changes" §6, p.4.

h2. User Story

As a reader of the Framework Reference page, I want each distinct concept (model table, concept table, install snippet) presented in its own clearly separated section, so that I'm not asked to absorb six distinct concept types in one unbroken scroll.

h2. Requirements

# Split the Model table, the Core/Adapter/Consumer/Related-product table, and the bash install snippet into their own subsections, each with a heading and a short intro sentence
# Add visible separation/whitespace between subsections

h2. Delivery Standard

This story follows full spec-driven development (mandatory under Agent Collections / epic TASK-515 when applicable).

* Spec folder: docs/specs/<issue-kebab>/
* Research: <issue-kebab>.research.md — required before plan
* Plan: <issue-kebab>.plan.md — required before implementation
* Implement: load eversis-implement (approved plan attached)
* Review: load eversis-review before Done
* Fine: QA comment draft per eversis-fine-handoff

Do not start implementation without approved research and plan artifacts.

Optional (Cursor): you may also attach the same prompts with @eversis-implement / @eversis-review if your project surfaces those files in Cursor.

h2. Technical Notes

Content re-sequencing only — no new page-layout mechanism implied by the source report.
```

**Acceptance Criteria**:
```
(/) Model table, Core/Adapter/Consumer/Related-product table, and install snippet each have their own subsection with a heading and intro sentence
(/) A reader can locate a specific concept without reading unrelated sections first
```

**Labels**: `documentation`, `ux-ui`, `content-density`, `workshop-2026-09-04`

---

### Story 2.4: Reader scans Agents/Skills/Prompts overview entries in one consistent format

**Parent**: Documentation Site: UX/UI Restructuring (Intent-Based IA)
**Jira Key**: DHI-648
**Status**: To Do
**Priority**: High
**Sizing Guidance**: Medium (5-8)

**Description**:
```
h2. Context

This story is part of the [Documentation Site: UX/UI Restructuring (Intent-Based IA)] epic — sub-track: Simplify first-screen language and content density.

h2. Source Context

Report, "Recommended UX/UI Changes" §3, p.4; benchmark pattern in "Why AI Hero's Skills Page Reads Easily" ("slash-command name, bolded skill title, one short sentence describing the outcome"), p.2.

h2. User Story

As a reader browsing the Agents, Skills, or Prompts overview pages, I want every entry to follow the same short template (name, bolded title, one clause describing the outcome), so that I can scan the list quickly instead of parsing inconsistent paragraph-vs-bare-name formatting.

h2. Requirements

# Apply one consistent entry template (name — bolded title — one clause outcome) across the Agents Overview and Skills Overview pages
# Apply the same template to the Prompts Overview page so all three are consistent
# Do not begin this story until the related content-accuracy audit (docs/specs/website-docs-skills-prompts-sync/) has landed corrections for the pages this story touches — or explicitly descope to formatting-only changes that don't depend on that audit

h2. Delivery Standard

This story follows full spec-driven development (mandatory under Agent Collections / epic TASK-515 when applicable).

* Spec folder: docs/specs/<issue-kebab>/
* Research: <issue-kebab>.research.md — required before plan
* Plan: <issue-kebab>.plan.md — required before implementation
* Implement: load eversis-implement (approved plan attached)
* Review: load eversis-review before Done
* Fine: QA comment draft per eversis-fine-handoff

Do not start implementation without approved research and plan artifacts.

Optional (Cursor): you may also attach the same prompts with @eversis-implement / @eversis-review if your project surfaces those files in Cursor.

h2. Technical Notes

Sequencing dependency: coordinate with the (separate, non-Jira-ticketed) website-docs-skills-prompts-sync content-accuracy audit, which touches the same Agents/Skills/Prompts pages.
```

**Acceptance Criteria**:
```
(/) Agents Overview and Skills Overview pages use one consistent pattern: name — bolded title — one clause outcome
(/) The same template is applied to the Prompts Overview page
(/) This story does not proceed until the related content-accuracy audit has landed for the pages it touches, or is explicitly descoped to formatting-only changes
```

**Labels**: `documentation`, `ux-ui`, `content-density`, `workshop-2026-09-04`

---

### Story 3.1: Reader follows one canonical installation checklist regardless of entry page

**Parent**: Documentation Site: UX/UI Restructuring (Intent-Based IA)
**Jira Key**: DHI-649
**Status**: To Do
**Priority**: High
**Sizing Guidance**: Medium (5-8)

**Description**:
```
h2. Context

This story is part of the [Documentation Site: UX/UI Restructuring (Intent-Based IA)] epic — sub-track: Consolidate onboarding and bring landing-page strengths into docs.

h2. Source Context

Report, "Why AI Hero's Skills Page Reads Easily", p.2 (describes the three divergent sequences); "Recommended UX/UI Changes" §4, p.4; root cause "Fragmented, duplicated onboarding", p.3.

h2. User Story

As a returning user setting up the framework, I want a single canonical installation checklist that every page links to, so that I don't have to reconcile three different sequences with different step counts depending on which page I land on.

h2. Requirements

# Designate the Start Here page's "First successful install checklist" as the single canonical sequence
# Replace the Framework-reference git clone/export snippet and the homepage six-step "Set up once" sequence with a link/redirect to the canonical checklist, rather than a separate divergent list
# Ensure every page that references installation shows the same step count and the same command

h2. Delivery Standard

This story follows full spec-driven development (mandatory under Agent Collections / epic TASK-515 when applicable).

* Spec folder: docs/specs/<issue-kebab>/
* Research: <issue-kebab>.research.md — required before plan
* Plan: <issue-kebab>.plan.md — required before implementation
* Implement: load eversis-implement (approved plan attached)
* Review: load eversis-review before Done
* Fine: QA comment draft per eversis-fine-handoff

Do not start implementation without approved research and plan artifacts.

Optional (Cursor): you may also attach the same prompts with @eversis-implement / @eversis-review if your project surfaces those files in Cursor.

h2. Technical Notes

Content consolidation only — no change to the underlying install script/command itself.
```

**Acceptance Criteria**:
```
(/) The Start Here page's checklist is the single canonical installation sequence
(/) The Framework-reference and homepage sequences are replaced with a link/redirect to the canonical checklist
(/) Every page referencing installation shows the same step count and command
```

**Labels**: `documentation`, `ux-ui`, `onboarding`, `workshop-2026-09-04`

---

### Story 3.2: Reader sees the homepage's pipeline diagram and outcome framing on the docs Introduction

**Parent**: Documentation Site: UX/UI Restructuring (Intent-Based IA)
**Jira Key**: DHI-650
**Status**: To Do
**Priority**: Medium
**Sizing Guidance**: Small (1-3)

**Description**:
```
h2. Context

This story is part of the [Documentation Site: UX/UI Restructuring (Intent-Based IA)] epic — sub-track: Consolidate onboarding and bring landing-page strengths into docs.

h2. Source Context

Report, "Current State of Agent Collections Docs" §4, p.1; "Recommended UX/UI Changes" §7, p.4.

h2. User Story

As a reader who clicks from the marketing homepage into /docs, I want the same pipeline visual and outcome framing (e.g. "~15 min vs 1-2 days") to carry into the docs Introduction, so that the value proposition I saw on the homepage doesn't disappear the moment I enter the docs.

h2. Requirements

# Port a condensed version of the homepage's pipeline diagram into the docs Introduction page
# Port the "~15 min vs 1-2 days"-style outcome framing into the same page
# Provide an accessible text alternative (alt text or an adjacent plain-language summary) for the diagram for readers who cannot see it

h2. Delivery Standard

This story follows full spec-driven development (mandatory under Agent Collections / epic TASK-515 when applicable).

* Spec folder: docs/specs/<issue-kebab>/
* Research: <issue-kebab>.research.md — required before plan
* Plan: <issue-kebab>.plan.md — required before implementation
* Implement: load eversis-implement (approved plan attached)
* Review: load eversis-review before Done
* Fine: QA comment draft per eversis-fine-handoff

Do not start implementation without approved research and plan artifacts.

Optional (Cursor): you may also attach the same prompts with @eversis-implement / @eversis-review if your project surfaces those files in Cursor.

h2. Technical Notes

Does not require abandoning Docusaurus or existing content — re-sequencing and porting existing homepage components only.
```

**Acceptance Criteria**:
```
(/) A condensed version of the homepage pipeline diagram appears on the docs Introduction
(/) The "~15 min vs 1-2 days"-style outcome framing appears on the same page
(/) A reader who cannot see the diagram (screen reader, image load failure) is given an equivalent text alternative
```

**Labels**: `documentation`, `ux-ui`, `onboarding`, `workshop-2026-09-04`

---

### Story 3.3: Reader sees a verified trust signal on the docs Introduction

**Parent**: Documentation Site: UX/UI Restructuring (Intent-Based IA)
**Jira Key**: DHI-651
**Status**: To Do
**Priority**: Low
**Sizing Guidance**: Small (1-3)

**Description**:
```
h2. Context

This story is part of the [Documentation Site: UX/UI Restructuring (Intent-Based IA)] epic — sub-track: Consolidate onboarding and bring landing-page strengths into docs. Light extension of Story 3.2 — reuses the same ported content as a trust cue.

h2. Source Context

Report, "Structural Comparison" table, "Social proof / trust signal" row, p.2; "Why AI Hero's Skills Page Reads Easily" §3, p.2. Resolved 2026-09-04 (stakeholder decision, on BA recommendation): no fabricated stars/installs/trained-engineers figure — this is an internal, non-public project with no equivalent metric available.

h2. User Story

As a first-time reader evaluating whether to invest time in this framework, I want to see a concrete, verified trust signal on the docs Introduction, so that I have some validation before committing to the onboarding path.

h2. Requirements

# Display the already-verified time-savings framing ("~15 min vs 1-2 days", ported in Story 3.2) as a trust cue near the installation call-to-action
# Do not introduce a new, unverified metric (no fabricated star count, install count, or "engineers trained" figure)
# If a real numeric adoption signal becomes available later (e.g. teams onboarded, specs delivered via the framework), treat it as a separate future follow-up, not a rework of this story

h2. Delivery Standard

This story follows full spec-driven development (mandatory under Agent Collections / epic TASK-515 when applicable).

* Spec folder: docs/specs/<issue-kebab>/
* Research: <issue-kebab>.research.md — required before plan
* Plan: <issue-kebab>.plan.md — required before implementation
* Implement: load eversis-implement (approved plan attached)
* Review: load eversis-review before Done
* Fine: QA comment draft per eversis-fine-handoff

Do not start implementation without approved research and plan artifacts.

Optional (Cursor): you may also attach the same prompts with @eversis-implement / @eversis-review if your project surfaces those files in Cursor.

h2. Technical Notes

No specific technical considerations discussed.
```

**Acceptance Criteria**:
```
(/) The docs Introduction displays at least one concrete, verified trust signal near the installation call-to-action
(/) That signal reuses the already-verified time-savings framing rather than a fabricated metric
```

**Labels**: `documentation`, `ux-ui`, `onboarding`, `workshop-2026-09-04`

---

## Completeness Check

| # | Task | Required Fields Populated | Business Language Only | Verifiable AC | Notes |
|---|---|---|---|---|---|
| Epic | Documentation Site: UX/UI Restructuring | ✅ | ✅ | ✅ | New parent, no protected status |
| 1.1 | Sidebar navigation by intent | ✅ | ✅ | ✅ | — |
| 1.2 | "Start here" signposting | ✅ | ✅ | ✅ | — |
| 1.3 | CTO/beginner fork | ✅ | ✅ | ✅ | — |
| 2.1 | Plain-language Introduction framing | ✅ | ✅ | ✅ | — |
| 2.2 | Glossary/first-use explanations | ✅ | ✅ | ✅ | — |
| 2.3 | Framework Reference pacing | ✅ | ✅ | ✅ | — |
| 2.4 | Uniform overview list template | ✅ | ✅ | ✅ | Gated on external audit — see Requirements |
| 3.1 | Canonical install checklist | ✅ | ✅ | ✅ | — |
| 3.2 | Pipeline diagram + outcome framing | ✅ | ✅ | ✅ | — |
| 3.3 | Trust signal | ✅ | ✅ | ✅ | Uses verified data only, per resolved open question |

All 11 tasks (1 epic + 10 stories) are complete against the benchmark template. No `TBD` fields.
