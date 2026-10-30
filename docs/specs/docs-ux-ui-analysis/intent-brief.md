# docs-ux-ui-analysis — Intent Brief

## Workshop Summary

| Field | Value |
|---|---|
| Workshop Date | 2026-09-04 |
| Participants | User (Piotr Niemirski) — requested via `/eversis-analyze-materials` |
| Source Materials | `UX_UI Analysis_ Agent Collections Documentation.pdf` (4 pages, single external report: "UX/UI Analysis: Agent Collections Documentation vs. AI Hero Benchmark") |
| Prepared By | Business Analyst agent (Agent Collections) |

## Goal

Turn the findings of a UX/UI benchmark report — comparing the Agent Collections Docusaurus documentation site (`/docs`) against the AI Hero `/skills` page — into a Jira-ready backlog under epic **DHI-515** ("Multi-Agent AI Context Isolation & Standard"). The report's core finding: the docs site explains the system architecture-first (SSOT, adapters, MCP) instead of task-first (what does the reader want to do), producing a deep, artifact-typed sidebar and fragmented onboarding that AI Hero avoids through intent-based grouping and strict content pacing.

## In Scope

- Restructuring the `website/docs/` sidebar/navigation from artifact-type grouping (Agents / Prompts / Skills / Integrations / Workflow / Team Guides) to user-intent grouping (Getting Started / Main Flow / Reference / Advanced-CTO).
- Rewriting the Introduction/Framework-reference first-screen content to lead with plain-language problem framing before technical vocabulary (SSOT, adapters, MCP).
- Consolidating the three divergent installation/onboarding sequences (Framework reference page, homepage, Start Here page) into one canonical checklist.
- Adding explicit "start here" / recommended-next-step signposting to grouped sections.
- Standardizing list-item formatting (Agents Overview, Skills Overview, Prompts Overview pages) to a single one-line template.
- Breaking the dense `framework-reference.md` page into shorter, single-concept sections with visual pacing.
- Porting stronger landing-page patterns (pipeline diagram, time-savings framing, trust signals) into the `/docs` Introduction.
- Introducing an early "For CTOs" / "For beginners" fork on the docs entry screen.

## Out of Scope

- Any change to the AI Hero site itself (external benchmark reference only, not a target for this backlog).
- Visual/graphic redesign (new color scheme, illustrations, branding) — the report explicitly frames its recommendations as structural/content-ordering changes, not a visual redesign.
- Marketing homepage changes beyond identifying patterns worth porting *into* `/docs` — the homepage itself is described in the report as already doing several things well and is not a target for rework.
- Non-UX findings (no functional/backend defects were reported).

## Key Stakeholders / Actors

- **New/first-time framework user** — the primary persona the report evaluates onboarding and navigation against.
- **Technical decision-maker (CTO)** — persona referenced by the "For CTOs" fork recommendation.
- **Docs maintainers (Business Analyst / Docs writer agents)** — will implement the resulting stories via `eversis-repo-docs-writer`.

## Candidate Epics

- **Restructure documentation navigation by user intent** — sidebar/IA overhaul from artifact-type to intent-based grouping, "start here" signposting, CTO/beginner fork.
- **Simplify first-screen language and content density** — plain-language framing, glossary for jargon, breaking up dense reference pages, uniform list-item template.
- **Consolidate onboarding and bring landing-page strengths into docs** — single canonical install checklist, pipeline diagram + trust signals ported into `/docs`.

## Baseline Overlap / Existing Backlog Notes

- `docs/context/agent-collections/task-baseline.md` is stale (last refreshed 2026-07-31, still uses the retired `TASK-` prefix; current epic is tracked as **DHI-515** in Jira with children DHI-516–542, DHI-598, DHI-603, DHI-604, DHI-630). No baseline entry currently covers documentation IA/navigation restructuring — this is new scope, not a duplicate of tracked work.
- Existing local (non-Jira-ticketed) docs specs reviewed for overlap — none conflict with this backlog:
  - `docs/specs/docs-playbooks-section/` — added the new "Team Guides" sidebar section (already live under `website/docs/team-guides/`). Related but not duplicative: the intent-based IA restructuring recommended here would need to fold "Team Guides" into whichever new top-level cluster it belongs under (flagged as an open question below).
  - `docs/specs/docs-architecture-necessity/` — verified `docs/architecture/` (repo-root docs, not the Docusaurus site) is necessary; unrelated tree.
  - `docs/specs/docs-readme-scaffolding-gap/` — installer scaffolding gap for `docs/context/`/`docs/plans/` READMEs; unrelated to the Docusaurus site.
  - `docs/specs/website-docs-skills-prompts-sync/` — content-accuracy audit of `website/docs/skills/**` and `website/docs/prompts/**` against the real SSOT/adapter model; a content-correctness concern, not IA/navigation. Sequencing note: that audit's corrections should land before or alongside the "uniform one-line template" story here, since both touch the same pages.
- A quick structural check confirms the report's sidebar claim: `website/docs/` currently has 13 top-level entries (`agents`, `domain-context.md`, `for-ctos.md`, `framework-reference.md`, `getting-started`, `integrations`, `intro.md`, `isolation.md`, `prompts`, `skills`, `team-guides`, `use-cases.md`, `workflow`), confirming the report's "13+ top-level sections" figure is current, not stale.

## Open Questions

Resolved by the stakeholder on 2026-09-04 — see `extracted-tasks.md` §"Open Questions for Stakeholders" for full detail:

- ~~Team Guides placement in the new IA~~ → **Deferred as a follow-up**, not a blocker; implementer picks a reasonable initial placement in Story 1.1.
- ~~Trust-signal data source for Story 3.3~~ → **Resolved**: reuse the already-verified homepage time-savings framing rather than fabricating a stars/installs/trained-engineers figure (this is an internal, non-public project).
- (Added during Gate 1) ~~Whether DHI-515 is still the correct parent epic~~ → **Resolved**: DHI-515 is status "Done"; a new, separate Epic will be created in project DHI as the parent instead.

## Gate 0 Approval

| Decision | Notes |
|---|---|
| Skipped — materials unambiguous | Single, self-contained 4-page report with an explicit, numbered "Recommended UX/UI Changes" section (8 concrete recommendations) and clear source attribution throughout. No conflicting materials, no transcript to reconcile. User's own instruction ("turn it into tickets under DHI-515") confirms scope and destination epic. Two open questions above are placement/data-source details for stakeholder review during Gate 1, not scope ambiguity that would block extraction. |
