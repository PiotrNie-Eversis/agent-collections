# website favicon - Analysis Result

## Task Details

| Field | Value |
|---|---|
| Jira ID | — (local request; no ticket key) |
| Title | Add favicon on the documentation site |
| Description | Make the Agent Collections Docusaurus site show a browser tab favicon. User request (PL): „dodaj favicon na stronie”. |
| Priority | Low |
| Reporter | Piotr Niemirski (chat) |
| Created Date | 2026-10-14 |
| Due Date | — |
| Labels | `website`, `branding`, `docusaurus` |
| Estimated Effort | ≤1 file config change if existing asset is accepted; asset work only if replacement is required |

## Business Impact

Browser tabs and bookmarks currently lack a site icon, so the docs site looks unfinished and is harder to spot among open tabs. Wiring the existing brand favicon improves recognition for `https://agent-collections.vercel.app` and local `yarn start` without changing content.

## Gathered Information

### Knowledge Base & Task Management Tools

- No Jira / Confluence ticket attached. Scope comes from the Implement chat request only.
- `docs/context/` has no project INDEX / components in this environment (MCP `eversis_context_list` unavailable; no `docs/context/*/INDEX.md` present). Domain knowledge not required for this change.

### Codebase

- **Docs site:** Docusaurus under `website/` (`website/docusaurus.config.ts`).
- **Asset already present:** `website/static/img/favicon.ico` (~15 KB; Windows ICO with 48×48 and 32×32 32-bit icons). Updated in commit `f5a146c` (“Update favicon, logo, and OpenGraph images…”).
- **Config gap:** `website/docusaurus.config.ts` has `title`, `url`, `baseUrl`, Open Graph / metadata under `themeConfig`, and navbar logo (`logo-white.svg`) — but **no top-level `favicon` field**. Git history for that file never contained `favicon` (asset was refreshed; wiring was never added).
- **Static URL path:** Docusaurus serves `static/` at site root, so the file is available as `/img/favicon.ico`. Browsers’ default probe for `/favicon.ico` will **not** find it unless config (or a root `static/favicon.ico`) points them there.
- **Related brand assets (out of scope unless requested):** `website/static/img/logo-white.svg`, `website/static/img/opengraph.png`.
- **Quality gate:** `npm run website:build` (from repo root / stack policy).

### Relevant Links

- https://agent-collections.vercel.app — production docs origin (`url` in config)
- Docusaurus config field: top-level `favicon: 'img/favicon.ico'` (path relative to `static/`)

### Relevant Charts & Diagrams

None.

## Current Implementation Status

### Existing Components

- Favicon binary — `website/static/img/favicon.ico` — **can be reused** (brand asset already committed)
- Site config — `website/docusaurus.config.ts` — **needs modification** (add `favicon` property)
- Optional apple-touch / SVG icons — **not present**; not required for classic tab favicon

### Key Files and Directories

- `website/docusaurus.config.ts` — declare favicon path for `<link rel="icon">` injection
- `website/static/img/favicon.ico` — existing icon asset
- `website/static/img/logo-white.svg` — navbar logo (reference only)
- `website/static/img/opengraph.png` — social preview (already separate from favicon)

## Gap Analysis

### Question 1
#### Is the existing `website/static/img/favicon.ico` the intended brand icon, or should it be replaced with a new design?
**Answer:** Reuse existing asset. Human: „Grafika jest prawidłowa, chodzi mi tylko o dodanie linku w head strony”.

### Question 2
#### Is scope limited to the classic browser favicon (Docusaurus `favicon` config), or should we also add apple-touch-icon / PNG / SVG variants?
**Answer:** Head link only — wire Docusaurus `favicon` so the page `<head>` includes the icon link. No new formats.

### Question 3
#### Any Jira key to attach for Fine / QA handoff?
**Assumption (default):** Local-only delivery under `docs/specs/website-favicon/`; no ticket publish unless a key is provided later.

## Human gates

1. ~~Approve research~~ — done (`Grafika jest prawidłowa, chodzi mi tylko o dodanie linku w head strony`)
2. Approve plan (once written)
3. Implement → Review → Fine

## Suggested acceptance criteria (for plan)

1. `website/docusaurus.config.ts` sets `favicon` to the static path of the brand ICO (expected: `'img/favicon.ico'`).
2. Built / served HTML includes a favicon link resolving to that asset (no 404).
3. Browser tab for the docs site shows the icon (local `yarn start` and production after deploy).
4. No unrelated branding or docs content changes.
