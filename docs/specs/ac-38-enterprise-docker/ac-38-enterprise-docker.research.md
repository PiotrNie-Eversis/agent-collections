# ac-38-enterprise-docker — Research

**Jira:** [AC-38](https://eversis.atlassian.net/browse/AC-38) (Epic — Prerequisites: Enterprise Docker install reality)  
**Active child task:** [AC-52](https://eversis.atlassian.net/browse/AC-52)  
**Superseded Story (Done / duplicate):** AC-43  
**Workshop source:** `docs/specs/ac-35-prerequisites-post-review/` (Gate 1–2 approved 2026-10-13; Docker alternatives decision locked)  
**Sibling epic (same page, separate delivery):** [AC-37](https://eversis.atlassian.net/browse/AC-37) — page UX / recovery (`docs/specs/ac-37-page-ux-recovery/`)

> **Label correction:** Older AC-36 notes and `code-quality-report.md` swapped epic summaries. Live Jira is SSOT: **AC-38 = enterprise Docker**; **AC-37 = TOC + troubleshooting**.

## Task Details

| Field | Value |
|---|---|
| Jira ID | AC-38 |
| Title | Prerequisites: Enterprise Docker install reality |
| Type | Epic (Backlog) |
| Priority | High |
| Labels | `ac-35-follow-up`, `documentation`, `getting-started` |
| Success metrics (epic) | Corporate QA/BA know to involve IT before assuming Docker Desktop is allowed |

## Problem

Prerequisites points readers at Docker Desktop install links and mentions “corporate laptops often need IT approval” in the matrix, but does **not** warn about administrator rights, paid Docker Desktop licensing at company scale, or IT-approved alternative runtimes that still need `docker compose` for Agent Collections MCP.

## Scope (this epic only)

| Task | Jira | Primary deliverable |
| --- | --- | --- |
| Docker admin / license / alternatives callout | AC-52 | `:::warning` (or equivalent) on `prerequisites.mdx` near Docker install guidance; Docker Desktop remains primary path in OS tabs |

**Out of scope:** Changing installer scripts, MCP image, or Compose behavior; validating every alternative runtime in CI; endorsing a specific vendor; Linux tab; AC-37 TOC/troubleshooting.

## Acceptance criteria (from AC-52)

- Warning states **administrator rights** are typically required on Windows and macOS.
- Page states Docker Desktop may require a **paid subscription** at certain company sizes; reader should **confirm license/policy with IT** before installing.
- If IT blocks Docker Desktop: name examples (**Rancher Desktop**, **Podman Desktop**, **OrbStack** on Mac) and require confirming **`docker compose`** support for MCP setup.
- Docker Desktop remains the **primary documented install path** in OS tabs; plain-language full sentences.

## Affected paths

- `website/docs/getting-started/prerequisites.mdx` — Docker matrix row + macOS/Windows Docker sections (add callout once, preferably before or above OS tabs so both tabs share it)
- Optional cross-link only: `installation.md` / `mcp-setup.md` already assume Docker — **no requirement** to rewrite those in this epic unless plan adds a one-line pointer

## Root cause

AC-35 documented the golden path (Docker Desktop) for non-developers. Workshop finding 3: corporate reality (admin + license + alternatives) was deferred to this follow-up epic.

## Constraints

- Informational only — do not procure licenses or automate IT workflows.
- Alternatives are **examples**, not a supported matrix; disclaimer that IT must approve and tool must support `docker compose` as used in MCP docs.
- Link official Docker subscription / install docs where helpful.
- No new npm dependencies; `npm run website:build` must pass.
- Plain language per AC-35.

## Current implementation status

| Component | Path | Status |
|---|---|---|
| Docker matrix row | `prerequisites.mdx` L24 | Partial — mentions IT approval only |
| macOS / Windows Docker steps | `prerequisites.mdx` | Golden path only — no admin/license/alternatives callout |
| Docker info box (framework notes) | `prerequisites.mdx` ~L151 | Skills-server explanation only |

## Workshop decisions (already locked — do not reopen)

| Question | Decision | Date |
|---|---|---|
| Docker alternatives in callout? | **IT first**, plus short named examples (Rancher Desktop, Podman Desktop, OrbStack on Mac); OS tabs stay Docker Desktop–first; must support `docker compose` | 2026-10-13 |

## Gap Analysis

### Question 1
#### Placement of the corporate Docker callout?
**Answer (locked):** One shared `:::warning` **above** the OS install tabs so both macOS and Windows readers see it once.  
Evidence: proposed default kept; closed together with AC-37 research approval / combined-delivery choice (2026-10-14).

### Question 2
#### Deliver with AC-37 in one Implement thread?
**Answer (locked):** Yes — plan phases **AC-38 (High) then AC-37 (Medium)** on the same MDX page; one build.  
Evidence: AC-37 Q3 — user `Q3. Implement with AC-38;` (2026-10-14).

## Open questions (blocking)

None — Q1–Q2 locked 2026-10-14.

## Human gates

1. ~~Approve research~~ — done (AC-37 `Q1. OK;` / `Q2. OK;` / `Q3. Implement with AC-38;` + AC-38 defaults locked)
2. Approve plan (once written)
3. Implement → Review → Fine

## Changelog

| Date | Author | Change |
| --- | --- | --- |
| 2026-10-14 | eversis-implement | CREATE from workshop + live Jira AC-38 / AC-52; corrected epic label vs AC-36 notes |
| 2026-10-14 | eversis-implement | Gap Q1–Q2 locked; combined delivery with AC-37; proceed to plan |
