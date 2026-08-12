# website-changelog-sync - Analysis Result

## Task Details

| Field | Value |
|---|---|
| Jira ID | N/A (ad-hoc `/eversis-implement` analysis) |
| Title | Docs site `/changelog` not aligned with root `CHANGELOG.md` |
| Description | Investigate why https://agent-collections.vercel.app/changelog is not automatically updated and kept in sync with repository root `CHANGELOG.md`. |
| Priority | Medium (docs UX / release communication) |
| Reporter | User (chat) |
| Created Date | 2026-08-12 |
| Due Date | N/A |
| Labels | docs, website, changelog, docusaurus |
| Estimated Effort | Small–medium (wire sync + one-time content cutover; optional CI check) |

## Business Impact

The public docs site is a primary discovery surface for Agent Collections. A stale `/changelog` page undermines release trust: visitors see an outdated (and partly pre-migration / cursor-collections-era) history while the SemVer contract lives only in root `CHANGELOG.md`. Aligning them reduces dual-maintenance and matches the stated “canonical source” note already on the page.

## Gathered Information

### Knowledge Base & Task Management Tools

- No Jira ID supplied for this thread.
- Live page snapshot captured from https://agent-collections.vercel.app/changelog (uploaded chat artifact) matches the committed site page content (date headings starting `2026-07-29`), not root `CHANGELOG.md`.

### Codebase

**Two distinct changelog artifacts exist:**

| Artifact | Role | Format | Auto-sync? |
|---|---|---|---|
| `CHANGELOG.md` (repo root) | Canonical Keep a Changelog + SemVer SSOT | `## [Unreleased]`, `## [0.0.1] — 2026-08-05`, Policy section | N/A (source) |
| `website/src/pages/changelog.md` | Docusaurus custom page served at `/changelog` | Date headings (`## 2026-07-29`, …); ~605 lines of older/migration-era narrative | **No** |

**Explicit design of the site page (not a bug in the note):**

```markdown
:::note
The canonical source for this changelog is [CHANGELOG.md](...) in the repository root.
This page is a snapshot — check the repository for the latest entries.
:::
```

That note documents intentional dual maintenance: the site page is a **manual snapshot**, not a generated view of the root file.

**Navbar wiring:** `website/docusaurus.config.ts` links `to: "/changelog"` → `website/src/pages/changelog.md` (Docusaurus `src/pages/` route). Nothing points the route at root `CHANGELOG.md`.

**No sync pipeline for changelog:**

- `website/package.json` scripts are only `start` / `build` / `serve` / `clear` — no `sync-changelog`, no prebuild copy from `../CHANGELOG.md`.
- Repo root has `website:build` → `npm --prefix website run build` only.
- Only sync tooling found under adapters: `adapters/sync.mjs` (rules/adapters), not docs changelog.
- Docs elsewhere still mention `sync-prompts` / `sync-framework-doc` (MCP allowlist / website docs), but **changelog is not among them**, and current `website/package.json` does not even wire `sync-prompts` into `build`.

**Content divergence (observed 2026-08-12):**

| | Root `CHANGELOG.md` | Site `website/src/pages/changelog.md` / live Vercel |
|---|---|---|
| Size | ~72 lines | ~605 lines |
| Headings | Policy, `[Unreleased]`, `[0.0.1] — 2026-08-05` | Dated entries `2026-07-29` … earlier (cursor-collections lineage) |
| Agent Collections SemVer / DHI-515 / DHI-598 Unreleased | Present | Absent |
| Pre-rebrand dated history | Absent (rewritten for Agent Collections) | Present (bulk of page) |

**Hosting context:** Root README still says docs site is “local build; **hosting deferred**”, yet `agent-collections.vercel.app` is live. Deploy appears to publish whatever is in `website/` at build time — including the stale snapshot page. Updating root `CHANGELOG.md` alone never changes the Vercel page unless `website/src/pages/changelog.md` is updated (or generated) and the site is redeployed.

### Relevant Links

- https://agent-collections.vercel.app/changelog — live stale page
- `CHANGELOG.md` — canonical SemVer changelog
- `website/src/pages/changelog.md` — site snapshot page
- `website/docusaurus.config.ts` — navbar `/changelog`
- README tree note: `website/` “local build; hosting deferred”

### Relevant Charts & Diagrams

```text
Author edits root CHANGELOG.md
        │
        ▼
   [no sync step]
        │
        X  website/src/pages/changelog.md  (manual / inherited snapshot)
        │
        ▼
   docusaurus build → Vercel → /changelog
```

Desired (if approved later):

```text
Author edits root CHANGELOG.md
        │
        ▼
   prebuild sync / import
        │
        ▼
   website page or MDX import of root SSOT
        │
        ▼
   docusaurus build → Vercel → /changelog
```

## Current Implementation Status

### Existing Components

- Root SemVer changelog — `CHANGELOG.md` — **SSOT to extend** with preserved prior-history section (Variant B)
- Site changelog page — `website/src/pages/changelog.md` — **generate from root** (today: independent snapshot ≈ retargeted CC site page)
- Navbar entry — `website/docusaurus.config.ts` — **reuse** (`/changelog`)
- CC reference — sibling `cursor-collections`: dual-file snapshot + `vercel.json`; sync scripts for prompts/framework-doc only; changelog **not** synced; parity check **skips** site changelog
- Agent Collections `website/package.json` — no `prebuild` sync hooks (unlike CC)

### Key Files and Directories

- `CHANGELOG.md` — canonical content authors update today
- `website/src/pages/changelog.md` — what Vercel actually serves
- `website/package.json` — build scripts (no changelog sync)
- `package.json` (`website:build`) — root entry to docs build
- `website/docusaurus.config.ts` — `/changelog` nav
- `.ai/skills/eversis-writing-repo-documentation/SKILL.md` — documents updating `CHANGELOG.md`; does not require dual-write to the site page

## Gap Analysis

### Question 1

#### Should `/changelog` become a generated view of root `CHANGELOG.md` only (drop dated cursor-collections history from the public page), or should historical dated entries be preserved as a separate archive section?

**Answer (human, 2026-08-12):** **Preserve the historical entries in both** (root `CHANGELOG.md` and the site `/changelog` page). See **Analysis: preserve history in both** below.

**Lock (human, 2026-08-12):** **Variant B** — one SSOT, two surfaces (site generated from root). Variant A rejected.

### Question 2

#### Preferred technical approach once sync is required? / How did cursor-collections handle this?

**Answer (human asked how CC worked; research filled):** Cursor Collections **did not auto-sync** changelog either. See **How it worked in cursor-collections** below.

**Lock (human, 2026-08-12):** **Single editable SSOT at root** (`CHANGELOG.md`) containing SemVer **and** preserved prior history; site page is generated/synced from that SSOT — not dual-write.

Plan approach (locked): **Build-time copy / transform** — `prebuild`/`prestart` write `website/src/pages/changelog.md` from root (Docusaurus front matter + generated-source note); committed generated file + **`--check` drift gate**. Manual dual-write and import-only-without-sync are out.

### Question 3

#### Is Vercel deploy already tied to this repo’s `main` (or another branch), and should a CI check fail when site changelog drifts from root?

**Answer (human, 2026-08-12):** **CORRECT** — treat live Vercel as real; plan must include deploy awareness and a **drift check** (site changelog must not diverge from root SSOT). Note: this repo currently has **no committed `vercel.json`** (unlike cursor-collections); dashboard config may still build `website/`. Plan should add or document deploy contract as needed.

### Question 4

#### Is this work in scope for a follow-up implement plan in this thread after research approval?

**Answer (human, 2026-08-12):** **CORRECT** — yes; write plan after research approval, then implement.

---

## Analysis: preserve history in both

### What the idea means

Keep the **dated pre-Agent-Collections narrative** (the long `## YYYY-MM-DD` history currently on the site page / inherited from cursor-collections) visible in:

1. **Root** `CHANGELOG.md` (git / SemVer / consumer upgrade surface), and  
2. **Site** `/changelog` (public docs).

That is **not** the same as “two independently edited files forever.” There are two implementations:

| Variant | Root | Site | Auto-aligned? | Verdict |
|---|---|---|---|---|
| **A. Dual-edit both files** | SemVer + history (hand) | Same content (hand) | Only if humans never miss a file | **Weak** — recreates CC failure mode |
| **B. One SSOT, two surfaces** | SemVer **+** merged history (only edit here) | Generated copy / include of root | Yes (sync + drift CI) | **Strong** — satisfies “in both” without dual maintenance |

**Research recommendation:** Variant **B**. “Preserve in both” = both **surfaces** show the history; only **one** file is authored.

**Human confirmation:** Variant **B** approved (2026-08-12).

### Pros of preserving history (content)

- Product continuity across the cursor-collections → Agent Collections rebrand; public visitors still see how workflows/skills evolved.
- Root changelog becomes a full lineage document, not only post-`0.0.1` SemVer notes.
- Matches user intent: do not drop the dated archive when fixing sync.

### Cons / risks (especially Variant A)

- **Format clash:** root today is SemVer (`[Unreleased]`, `[0.0.1] — date` + Policy); history is **date-headed** Keep-a-Changelog. Merging needs a clear section boundary (e.g. `## Prior history (cursor-collections lineage)` after SemVer releases).
- **Attribution:** many historical bullets describe `.cursor/`-centric or cursor-collections paths; they need a banner that pre-`0.0.1` entries are lineage/migration history, not Agent Collections SemVer releases.
- **Link rewrite:** AC site page is already a near-copy of CC’s site page with GitHub URLs retargeted to `agent-collections` (and some path renames). Root merge must use **Agent Collections** paths / avoid broken `.cursor/skills` deep-links where SSOT is now `.ai/`.
- **Size:** ~600+ lines of history on the public page; acceptable if structured with a clear “current releases” vs “prior history” split.
- **CC already proved dual-edit fails:** even in cursor-collections, root (773 lines) and site (605 lines) **did not match** — site omitted several date sections present in root (`2026-06-22`, `06-07`, `06-05`, …). A parity gate **explicitly skipped** the site changelog.

### Recommended content shape (for later plan)

```text
# Changelog
## Policy                    ← Agent Collections SemVer contract
## [Unreleased]
## [0.0.1] — 2026-08-05
## Prior history             ← preserved dated entries (from current site / CC lineage)
## YYYY-MM-DD
…
```

Both root and generated site page show that full document. Authors only append under Unreleased / new SemVer sections going forward; history is frozen or rarely amended.

### Decision needed only if rejecting Variant B

~~If the human insists on Variant A…~~ **Closed** — human chose Variant B (2026-08-12).

---

## How it worked in cursor-collections

Investigated sibling repo `/Users/piotrniemirski/Documents/Projects/cursor-collections` (2026-08-12).

### Architecture (same dual-file pattern)

| Piece | Behavior |
|---|---|
| Root `CHANGELOG.md` | Date-based Keep a Changelog; **canonical** per site note |
| `website/src/pages/changelog.md` | Separate Docusaurus page; note: “This page is a **snapshot**” |
| Auto sync changelog? | **No** — no `sync-changelog` script |
| What *did* sync on `prebuild`/`prestart` | `sync-prompts`, `sync-framework-doc` only (`sync-docs-assets`) |
| Parity CI | `check-readme-site-parity.mjs` — **skips** `website/src/pages/changelog.md` |
| Deploy | Committed `vercel.json`: `cd website && npm install && npm run build` → `website/build` |

### Operational model

1. Humans / Repo Docs were expected to update **root** changelog (and often the site page) when shipping docs-visible changes.
2. The site page was a **curated snapshot**, not a byte-for-byte mirror — shorter, rewritten bullets, some dates missing vs root.
3. Drift was **tolerated by tooling** (changelog excluded from parity checks).
4. Agent Collections inherited the **site snapshot file** (content ≈ CC site page with repo URL / naming retargets) while **rewriting root** to SemVer Agent Collections releases — which made the disconnect worse and more visible.

### Implication for Agent Collections

“Make it work like cursor-collections” **cannot** mean “auto-update,” because CC never auto-updated changelog. The upgrade vs CC should be: **keep the history content**, but **replace dual-edit + snapshot disclaimer** with **root SSOT + generate site + drift check** (and optionally add `vercel.json` like CC).

## Root cause (summary)

The live docs changelog is **not wired to** `CHANGELOG.md`. It is a **separate, hand-maintained Docusaurus page** that still contains older dated history and an explicit “snapshot” disclaimer. There is **no sync script, no prebuild import, and no CI drift check**. Updating the root changelog therefore cannot update https://agent-collections.vercel.app/changelog until the site page is regenerated/replaced and the site redeployed. This pattern was **inherited from cursor-collections**, which also used dual files without changelog sync.

## Suggested next steps (after research approval)

1. ~~Confirm Variant B~~ — **done** (human locked B + root SSOT, 2026-08-12).
2. Write `*.plan.md`: merge history into root; `sync-changelog` + prebuild; drift `--check`; `vercel.json`; replace “snapshot” note with generated-source tip.
3. Implement after plan approval; verify local `website:build` and post-deploy `/changelog` shows SemVer **and** prior history.

## Changelog

| Date | Change |
|---|---|
| 2026-08-12 | Initial research — root cause: dual artifact + no sync; live page matches stale `website/src/pages/changelog.md` |
| 2026-08-12 | DELTA — Q1 preserve history in both (analysis + Variant A/B); Q2 CC behavior (no auto-sync; curated snapshot; parity skip); Q3/Q4 CORRECT |
| 2026-08-12 | DELTA — Human locks: Variant **B**; single editable SSOT at root; proceed to plan |
