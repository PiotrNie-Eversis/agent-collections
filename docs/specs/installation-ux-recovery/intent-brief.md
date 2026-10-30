# installation-ux-recovery — Intent Brief

## Workshop Summary

| Field | Value |
|---|---|
| Workshop Date | 2026-10-14 |
| Participants | Documentation / DevEx analysis (report author); BA extraction session (Piotr Niemirski) |
| Source Materials | UX/IA/readability audit for `/docs/getting-started/installation` (uploaded attachment → `source-ux-audit.md`); current page `website/docs/getting-started/installation.md`; baseline `docs/context/agent-collections/task-baseline.md`; sibling workshop pattern `docs/specs/mcp-setup-ux-recovery/` |
| Prepared By | eversis-analyze-materials (Business Analyst) |

## Goal

Make the Getting Started **Installation** page usable as a short install path for readers of different technical levels (QA, BA, PO, Developer). Today it is accurate as an engineering reference but inverted and overloaded as onboarding: the happy path is buried, Windows users are blocked by Unix-only samples, and maintainer/CLI-reference content mixes into numbered steps. The outcome is a three-step guided install (download once → install into project → verify) with OS tabs, one default command, early success signals, and advanced topics deferred below the fold.

## In Scope

- Rewrite / restructure the docs page at `/docs/getting-started/installation` for readability, information architecture, and DevEx.
- Clear intro CTA: install in ~3 steps; stop the primary “go back to Start here” loop as the first message.
- Explicit mental model: framework checkout (once on the machine) vs consumer project (where the installer runs).
- OS-specific command tabs: macOS/Linux vs Windows (Git Bash primary; optional short PowerShell env note).
- Main path: prepare framework → run recommended installer in the project → verify success → link to MCP Setup.
- Progressive disclosure: one default install command for most users; full CLI flag table and vendor/submodule detail in collapsible / advanced sections.
- Remove maintainer “open framework / sync adapters” from the numbered happy path.
- Early “how to recognize success” / smoke-test cues (e.g. `install-selection.json`, context `INDEX.md`).
- Slim TOC (`toc_max_heading_level: 2`, ~4–5 major sections).
- Keep commands and flags aligned with the real installer SSOT (do not invent flags or contradict `setup-agent-collections.sh`).

## Out of Scope

- Changing installer script behavior, vendor modes, or MCP/Docker runtime (docs-only unless a later Implement ticket finds a product bug).
- Full redesign of Prerequisites (AC-37 / AC-38) or MCP Setup (AC-63) pages — link only.
- Broader docs IA under DHI-641 (sidebar clusters, Introduction framing) beyond this page’s local TOC/structure.
- Polish (or other) locale for the published page — docs SSOT is always English (audit template language is source material only).
- Video walkthroughs or redesign of Start here / onboarding map (AC-56) beyond consistent next-step links.

## Key Stakeholders / Actors

- QA / Business Analyst / Product Owner — need a short path, default command, and clear success without learning every CLI flag.
- Developer / technical QA — may need upgrade and optional vendor/submodule paths after first success.
- Framework maintainer — adapter sync / open-framework content; must not dominate the default path.
- Docs / DevEx owners — own the Docusaurus page and Getting Started funnel.

## Candidate Epics

- **Installation page: guided onboarding and DevEx recovery** — single epic covering IA rewrite, OS tabs, mental model, default command + progressive disclosure, verification, and deferred advanced sections for `/docs/getting-started/installation`.

## Baseline Overlap / Existing Backlog Notes

- **AC-63** (MCP Setup UX recovery) — sibling Getting Started page; Installation should end with a clear next link to MCP Setup, not duplicate MCP content.
- **AC-37 / AC-38** — Prerequisites page UX + enterprise Docker; Installation should tip-link Prerequisites (Docker running), not rework that page.
- **DHI-649** (canonical installation checklist across entry pages) — related continuity; this epic is **page-specific** for Installation and should be a **new epic in project AC** (same convention as AC-63), with a Relates link to DHI-649 / DHI-641 if desired — not parented under DHI-641 unless stakeholders insist.
- **DHI-641** — broader docs UX/UI restructuring; complementary, different grain.
- No baseline row specifically for an Installation-page rewrite (unlike AC-63 for mcp-setup).
- AC board convention: Epic → **Task** (not Story) for implementable work.

## Open Questions

None remaining after Gate 1 (2026-10-14).

## Gate 0 Approval

| Decision | Notes |
|---|---|
| Skipped — materials unambiguous | 2026-10-14 — Structured UX audit with explicit problem diagnosis, recommendation matrix, and a proposed MDX outline; scope limited to one docs page; no conflicting sources beyond English SSOT vs Polish draft wording (captured as assumption / Gate 1 default). |

## Gate 1 Decisions (2026-10-14)

| Decision | Resolution |
|---|---|
| Epic + 7 stories | Approved as presented |
| Jira parent | **New epic in project AC** (standalone; may Relates to DHI-641 / DHI-649 / AC-37 / AC-63) |
| Windows path | **Git Bash primary** + short PowerShell env note (not full PowerShell installer tabs) |
| Page language | **English only** — docs SSOT is always English |
