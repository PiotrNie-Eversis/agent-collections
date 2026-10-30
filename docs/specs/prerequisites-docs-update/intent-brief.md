# Intent brief — Prerequisites page (public docs)

## Goal

Make the **Prerequisites** page on the Agent Collections documentation site easy to follow for **non-developer roles** (QA, BA, PM) while keeping accurate guidance for engineers.

## In scope

- Restructure `website/docs/getting-started/prerequisites.md` for scanability (plain language, “who needs what”, checklists).
- Add **official download / install links** for Cursor, Claude Code, Docker, Node.js, and Git.
- Add **macOS and Windows** installation paths (and note Linux where relevant) for each required tool.
- Clarify **end-user vs MCP developer** Node.js requirement (already hinted on page; make explicit for non-technical readers).
- Align cross-links with [Start here](./../../website/docs/getting-started/start-here.md) checklist wording.

## Out of scope

- Rewriting Installation or MCP setup playbooks (link to them only).
- Implementing installer or MCP behavior changes.
- Translating the whole docs site to Polish.

## Stakeholders

- QA / BA / PM — primary readers for onboarding verification.
- Engineers — maintainers of Docusaurus docs.

## Baseline overlap

- Jira **AC** project: no open or closed issue whose summary/description targets **Prerequisites** page refresh (searched 2026-10-13).
- Related done work: **AC-20** (context architecture on public site), **AC-23** (docs metadata) — different scope.

## Gate 0 approval

**Skipped — materials unambiguous.** Request specifies page, gaps (links, OS install steps, non-technical clarity), and target project **AC**.

## Source

- User request (workshop-style materials), 2026-10-13.
- **UX audit:** `Raport_UX_i_audyt_techniczny_strony_Prerequisites.md` (2026-10-13) — drives AC-35 refresh.
- Repo baseline: `website/docs/getting-started/prerequisites.md`.
