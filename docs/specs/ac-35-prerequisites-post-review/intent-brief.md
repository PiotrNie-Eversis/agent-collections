# ac-35-prerequisites-post-review — Intent Brief

## Workshop Summary

| Field | Value |
|---|---|
| Workshop Date | 2026-10-13 |
| Participants | Post-deploy reviewer (QA/BA perspective); Agent Collections maintainers |
| Source Materials | User-provided post-deploy analysis (Polish); live `website/docs/getting-started/prerequisites.mdx`; parent delivery AC-35 |
| Prepared By | eversis-analyze-materials (Business Analyst workflow) |

## Goal

Close **cognitive, technical, and UX gaps** on the Prerequisites page so QA, BA, and PO readers can install tools and verify setup **without surprise CLI installs, license blocks, or duplicate navigation**, while keeping plain-language, full-sentence documentation.

## In Scope

- Copy and structure updates to **Prerequisites** (`prerequisites.mdx`) and aligned **Start here** bullets if messaging changes.
- GUI vs CLI clarity for Cursor and Claude Code.
- Node.js dependency explained in the context of **Claude Code install choice**, not only “MCP developers.”
- Corporate Docker Desktop **admin + license** callout (informational; not procuring licenses).
- TOC fix for tabbed install sections.
- “How to open a terminal” before verification.
- Short troubleshooting section (≥3 common scenarios) with **text and screenshots**.
- Docker callout: **IT-first**, plus **named alternatives** IT may approve (not a product endorsement).
- AI account / subscription requirements in the requirements area.
- `npm run website:build` before Done.

## Out of Scope

- Changing installer scripts, MCP Docker image, or Compose behavior.
- Validating or supporting every alternative runtime in installer/MCP docs (only Docker Desktop remains the **documented golden path**).
- Linux install tab.
- Full Polish translation of the docs site (English remains SSOT).
- Procurement or IT workflow automation.

## Key Stakeholders / Actors

- **QA / BA / PO** — primary readers; must not hit CLI/licensing dead ends without warning.
- **Documentation maintainers** — implement MDX/Docusaurus changes.
- **IT / Tech Lead** — supplies corporate Docker policy and LLM account guidance (referenced, not implemented in product).

## Candidate Epics

- **Prerequisites — non-technical clarity** — GUI/CLI, Node path, LLM accounts, terminal how-to.
- **Prerequisites — enterprise install reality** — Docker admin and license callout.
- **Prerequisites — page UX quality** — TOC deduplication, troubleshooting.

## Baseline Overlap / Existing Backlog Notes

- **AC-35** delivered the first IA overhaul (matrix, tabs, verification). This engagement is a **follow-up hardening** pass, not a redo of AC-35 scope.
- No `docs/context/<project>/task-baseline.md` in repo.

## Open Questions (resolved)

| Question | Decision | Date |
|---|---|---|
| Docker alternatives in callout? | **IT first**, plus **short named examples** (Rancher Desktop, Podman Desktop, OrbStack on Mac) with disclaimer that IT must approve and the tool must support **`docker compose`** as used in MCP setup docs. OS tabs stay Docker Desktop–first. | 2026-10-13 |
| Troubleshooting format? | **Text + screenshots** (store images under `website/static/img/getting-started/prerequisites/` or equivalent; alt text required). | 2026-10-13 |

## Gate 0 Approval

| Decision | Notes |
|---|---|
| Skipped — materials unambiguous | Analysis enumerates seven concrete gaps with recommendations; parent story AC-35 and current MDX are clear. Skip recorded 2026-10-13. |
