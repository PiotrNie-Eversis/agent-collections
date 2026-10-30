# mcp-setup-ux-recovery — Intent Brief

## Workshop Summary

| Field | Value |
|---|---|
| Workshop Date | 2026-10-14 |
| Participants | Documentation / DevEx analysis (report author); BA extraction session |
| Source Materials | UX/IA/DevEx audit report for `/docs/getting-started/mcp-setup` (uploaded attachment); current page `website/docs/getting-started/mcp-setup.md`; baseline `docs/context/agent-collections/task-baseline.md` |
| Prepared By | eversis-analyze-materials (Business Analyst) |

## Goal

Make the Getting Started **MCP Setup** page usable for readers of different technical levels (QA, BA, PO, Developer). Today it is the most critical and most technical step in onboarding; the audit finds missing mental model, mixed client instructions, opaque env/path guidance, and no clear success/failure loop. The outcome is a guided, role-aware page that gets a first successful `eversis-collections` connection without forcing optional integrations.

## In Scope

- Rewrite / restructure the docs page at `/docs/getting-started/mcp-setup` for readability, information architecture, and DevEx.
- Plain-language explanation of what MCP is and why the local skills server matters.
- Role-based “which path do I take?” guidance (QA/BA/PO vs Developer vs framework maintainer).
- Ordered flow: core server first → connect editor → verify → working-directory note → optional integrations → troubleshooting.
- Separate instructions per AI client (Cursor, Claude Code, Claude Desktop) and OS where paths/commands differ (macOS vs Windows).
- Clear separation of required core server vs optional external MCP servers (Jira, Figma, Playwright, etc.).
- Visual / checklist success criteria and a troubleshooting table for common failures.
- Keep commands and env names aligned with the real installer and current framework SSOT (do not ship outdated `CURSOR_COLLECTIONS_HOME` or invented one-liners that contradict Compose-based setup).

## Out of Scope

- Changing MCP server runtime behavior, Docker image internals, or installer merge logic (docs-only unless a later Implement ticket discovers a product bug).
- Full redesign of other Getting Started pages (Prerequisites is covered by AC-37 / AC-38; Quick Wins / Main Flow only as “next step” links).
- Implementing or documenting every optional third-party MCP in depth on this page (pointer to Reference is enough).
- Polish (or other) locale for this page — docs SSOT is always English.
- Broad docs IA epic DHI-641 work unrelated to this page (sidebar clusters, Introduction framing, etc.).
- First-class Claude Desktop setup tab in v1 (unsupported Getting Started path; one-line disclaimer only).

## Key Stakeholders / Actors

- QA / Business Analyst / Product Owner — need a clickable Cursor path and plain language.
- Developer / technical QA — may use Cursor or Claude Code and optional integrations.
- Framework maintainer — advanced local/Node path; lowest priority on this page.
- Docs / DevEx owners — own the Docusaurus page and Getting Started funnel.

## Candidate Epics

- **MCP Setup page: guided onboarding and DevEx recovery** — single epic covering IA rewrite, client/OS tabs, verification, optional-vs-core separation, and troubleshooting for `/docs/getting-started/mcp-setup`.

## Baseline Overlap / Existing Backlog Notes

- **DHI-641** (Documentation Site: UX/UI Restructuring) — related docs UX epic; this work is page-specific and should be a **new epic** (likely project **AC**), not a vague child of DHI-641 unless stakeholders prefer parenting under DHI.
- **AC-37 / AC-38** — Prerequisites page UX + Docker enterprise path; complementary Getting Started work, different page. MCP Setup should link to Prerequisites for Docker Engine, not duplicate that recovery content.
- No existing Jira item in `task-baseline.md` specifically for mcp-setup page rewrite.
- AC board convention: Epic → **Task** (not Story) for implementable work.

## Open Questions

- None remaining after Gate 1 (2026-10-14).

## Gate 0 Approval

| Decision | Notes |
|---|---|
| Skipped — materials unambiguous | 2026-10-14 — Structured UX audit with explicit problem diagnosis, IA outline, and acceptance-oriented recommendations; scope limited to one docs page; no conflicting sources beyond command-detail alignment with current Compose/`AGENT_COLLECTIONS_HOME` SSOT (captured as assumption). |

## Gate 1 Decisions (2026-10-14)

| Decision | Resolution |
|---|---|
| Epic + 8 stories | Approved as presented |
| Claude Desktop tab in v1 | **No** — add one line: “Claude Desktop is not a supported Getting Started path yet.” |
| Jira parent | **New epic in project AC** (standalone; may relate to DHI-641 / AC-37 but not parented under them) |
| Page language | **English only** — docs SSOT is always English |
