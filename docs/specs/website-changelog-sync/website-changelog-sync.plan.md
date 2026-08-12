# website-changelog-sync - Implementation Plan

**Status:** Fine (2026-08-12) — Review PASS

## Task Details

| Field            | Value |
| ---------------- | ----- |
| Jira ID          | N/A (ad-hoc) |
| Title            | Align docs site `/changelog` with root `CHANGELOG.md` (Variant B) |
| Description      | Make root `CHANGELOG.md` the single editable SSOT (SemVer + preserved prior history); generate `website/src/pages/changelog.md` on build; fail on drift; document Vercel deploy contract. |
| Priority         | Medium |
| Related Research | [`website-changelog-sync.research.md`](./website-changelog-sync.research.md) |

**Research locks:** Variant **B** · single editable SSOT at root · build-time sync + `--check` · preserve dated history · Q3 drift/deploy · Q4 implement in this thread

## Wildly Important Goal

**Goal**: After a root `CHANGELOG.md` edit and a docs site build/deploy, https://agent-collections.vercel.app/changelog shows the same SemVer releases and preserved prior history without hand-editing the site page.

**Success Measure**: `website` `prebuild` regenerates `/changelog` from root; `sync-changelog --check` (or equivalent) exits non-zero on drift; built page contains `[Unreleased]` / `[0.0.1]` **and** a dated prior-history section sourced from today’s site archive.

**Do NOT touch / do NOT add**:

- Product skills / adapters / MCP tool behavior (except optional allowlist note if a root script is registered)
- Re-litigating Variant A (dual hand-edit)
- Backfilling missing CC-root-only date sections that never appeared on the AC site page (optional later)
- Rewriting historical bullet prose for style (only path/link hygiene required for the merge)
- Publishing to Jira / force-push / unrelated README redesign

## Proposed Solution

**Variant B — one authoring file, two surfaces.**

1. **Extend root `CHANGELOG.md`** with a clearly labeled **Prior history (cursor-collections lineage)** section after SemVer releases. History body = current `website/src/pages/changelog.md` dated sections (already Agent Collections URL-retargeted), minus the page’s snapshot note / duplicate H1 boilerplate.
2. **Add `scripts/sync-changelog.mjs`** (patterned on cursor-collections `sync-framework-doc.mjs`): read root → write `website/src/pages/changelog.md` with Docusaurus front matter + tip that the page is **generated** from root (not a manual snapshot). Support default write mode and `--check` (exit 1 if would change).
3. **Wire `website/package.json`**: `prestart` / `prebuild` run sync; add npm scripts; root `package.json` convenience scripts (`website:changelog:sync`, `website:changelog:check`).
4. **Commit the generated page** so the tree stays reviewable; `--check` prevents silent hand-edits from drifting.
5. **Add root `vercel.json`** mirroring cursor-collections (`website` install/build → `website/build`) so deploy always runs `prebuild` sync.
6. **Docs touch**: README hosting line; short note in repo-docs / writing-repo-documentation that changelog edits are **root-only**.

```text
Author → CHANGELOG.md (only)
            │
            ▼
   sync-changelog.mjs  (+ --check in CI / local)
            │
            ▼
   website/src/pages/changelog.md (generated)
            │
   prebuild → docusaurus → Vercel /changelog
```

## Current Implementation Analysis

### Already Implemented

- Root SemVer changelog — `CHANGELOG.md` — Policy, `[Unreleased]`, `[0.0.1]`
- Site route + nav — `website/src/pages/changelog.md`, `website/docusaurus.config.ts` (`to: "/changelog"`)
- Root build entry — `package.json` → `website:build`
- CC reference pattern — sibling `cursor-collections/scripts/sync-framework-doc.mjs` + `website` `prebuild` (prompts/framework-doc only; **not** changelog)

### To Be Modified

- `CHANGELOG.md` — append Prior history section from current site dated content
- `website/src/pages/changelog.md` — become generated output (replace snapshot disclaimer)
- `website/package.json` — `prestart` / `prebuild` + sync scripts
- Root `package.json` — sync/check script aliases
- `README.md` — hosting deferred → Vercel; changelog SSOT sentence
- `.ai/skills/eversis-writing-repo-documentation/SKILL.md` (and/or website mirror if committed) — root-only changelog rule
- Optional: `website/docs/workflow/repo-docs.md` — one line on changelog SSOT

### To Be Created

- `scripts/sync-changelog.mjs` — generate site page from root; `--check` mode
- `vercel.json` — website build/output contract (align with CC)

## Open Questions

| # | Question | Answer | Status |
| --- | --- | --- | --- |
| 1 | Variant A vs B? | B | ✅ Resolved |
| 2 | Editable SSOT location? | Root `CHANGELOG.md` only | ✅ Resolved |
| 3 | History source for first merge? | Current AC `website/src/pages/changelog.md` dated sections (not fuller CC root) | ✅ Resolved |
| 4 | Drift check + live Vercel? | Yes | ✅ Resolved |
| 5 | Commit generated `changelog.md`? | Yes (reviewable + `--check`) | ✅ Resolved |

## Technical Context

### Project Instructions

- Framework repo; stack policy: [`.cursor/rules/eversis-project-stack.mdc`](../../../.cursor/rules/eversis-project-stack.mdc) — load `eversis-writing-repo-documentation` for docs; do **not** load frontend/filters/BA Docs skills.
- Delivery Standard / specs: `docs/specs/<issue-kebab>/`.
- Agents entry: [`AGENTS.md`](../../../AGENTS.md) — quality commands include `website:build`.

### Architecture & Patterns

- Docusaurus 3 under `website/`; custom pages in `website/src/pages/`.
- Root markdown SSOT with optional generated website copies (CC used this for framework-reference; AC will use it for changelog).
- Zero-deps Node ESM scripts under `scripts/` preferred (match adapters / CC sync scripts).

### Tech Stack

- Node ≥18; website: `@docusaurus/core` 3.10.2, React 19.
- Root scripts: npm; no Nx.

### Code Style & Standards

- Keep a Changelog + SemVer for Agent Collections releases; dated `## YYYY-MM-DD` only under Prior history.
- Generated page must include YAML front matter `title: Changelog`.
- No machine-local absolute paths in committed docs.
- Do not add package-manager dependencies for the sync script.

### Testing Patterns

| Check | Command |
| --- | --- |
| Sync write | `node scripts/sync-changelog.mjs` |
| Drift | `node scripts/sync-changelog.mjs --check` |
| Site build | `npm run website:build` (from repo root; runs `prebuild` sync once wired) |
| Optional smoke | Inspect `website/build/changelog/index.html` (or serve) for `[Unreleased]` and Prior history heading |

No unit test harness required unless implementor adds a tiny node assert script; `--check` is the primary gate.

### Database Patterns

- N/A

### Additional Context

- Live site currently serves the stale snapshot; AC has **no** committed `vercel.json` today (CC does).
- MCP `eversis_repo_run_script` allowlist today is adapter-oriented; **do not** expand MCP allowlist unless plan execution explicitly needs it (out of default scope).
- History merge: strip site front matter / `# Changelog` / snapshot `:::note` / Keep-a-Changelog intro duplicates when appending under Prior history; keep dated `##` sections as-is aside from broken-link fixes if cheap.

## Implementation Plan

### Phase 1: Merge prior history into root SSOT

**Goal**: Root `CHANGELOG.md` becomes the complete narrative (SemVer + preserved history) so a single file can feed the site.

**Description**: Append a Prior history section after `[0.0.1]` using dated content from the current site page. Add a short banner that pre-SemVer entries are lineage from cursor-collections / pre-`0.0.1`, not Agent Collections release tags.

**Verification:** `rg -n "^## \\[Unreleased\\]|^## \\[0\\.0\\.1\\]|^## Prior history|^## 2026-07-29" CHANGELOG.md` shows SemVer headings and at least one dated history heading.

#### Task 1.1 - [MODIFY] Append Prior history to `CHANGELOG.md`

**Description**: Merge dated sections from `website/src/pages/changelog.md` into root under `## Prior history (cursor-collections lineage)` (or equivalent exact title used consistently by sync docs). Do not remove existing Policy / Unreleased / 0.0.1 content. Optionally add one Unreleased bullet noting site changelog sync (or defer that bullet to Phase 3 docs).

**Files:** `CHANGELOG.md` (modify), `website/src/pages/changelog.md` (reuse as history source only)

**Definition of Done**:

- [x] Root file still starts with Policy + `[Unreleased]` + `[0.0.1]`
- [x] Prior history section exists and includes `## 2026-07-29` (and subsequent dated sections from the site source)
- [x] No duplicate `# Changelog` / snapshot note inside the history body
- [x] Inspect: `rg -n "^## " CHANGELOG.md` lists SemVer headings before dated headings

**Clues**: Prefer AC site page over CC root for URL retargets already done; do not invent missing CC-only dates.

### Phase 2: Sync script + website build hooks + drift check

**Goal**: Site page is generated from root; drift is detectable before/without relying on humans.

**Description**: Add `scripts/sync-changelog.mjs`, wire website lifecycle scripts, regenerate the page once, and ensure `--check` fails if the committed generated file is hand-edited out of sync.

**Verification:** `node scripts/sync-changelog.mjs && node scripts/sync-changelog.mjs --check` exits 0; after a deliberate site-page edit, `--check` exits non-zero; `npm run website:build` succeeds.

#### Task 2.1 - [CREATE] `scripts/sync-changelog.mjs`

**Description**: Zero-deps Node ESM script: read `CHANGELOG.md`, emit Docusaurus page to `website/src/pages/changelog.md` with front matter and a tip that root is SSOT / page is generated. Implement `--check` (compare to existing output; exit 1 on mismatch without writing, or write-to-temp and diff).

**Files:** `scripts/sync-changelog.mjs` (create)

**Definition of Done**:

- [x] `node scripts/sync-changelog.mjs` writes `website/src/pages/changelog.md`
- [x] Output includes `title: Changelog` front matter and generated-source tip (not “manual snapshot”)
- [x] Body reflects root SemVer + Prior history content
- [x] `node scripts/sync-changelog.mjs --check` exits 0 when in sync
- [x] No new npm dependencies

**Clues**: Mirror structure/style of `cursor-collections/scripts/sync-framework-doc.mjs` (front matter + tip + copy); keep relative imports via `import.meta.url`.

#### Task 2.2 - [MODIFY] Wire npm scripts and regenerate committed page

**Description**: Add website `prestart`/`prebuild` (and named sync scripts); add root aliases; run sync once so committed `website/src/pages/changelog.md` matches root.

**Files:** `website/package.json` (modify), `package.json` (modify), `website/src/pages/changelog.md` (modify — generated)

**Definition of Done**:

- [x] `website` `prebuild` / `prestart` invoke changelog sync
- [x] Root scripts include sync and `--check` entrypoints (names may be `website:changelog:sync` / `website:changelog:check`)
- [x] Committed site page no longer claims to be a manual snapshot
- [x] `npm run website:build` completes successfully from repo root

**Stop Rule:** If Docusaurus rejects generated markdown (MDX issues), fix transform (e.g. fence/escape) before expanding scope.

### Phase 3: Deploy contract + authoring docs

**Goal**: Vercel builds always regenerate from SSOT; humans know to edit only root.

**Description**: Add `vercel.json`; update README / repo-docs skill notes for SSOT and hosting.

**Verification:** `vercel.json` present with website build/output; README mentions Vercel + root changelog SSOT; `node scripts/sync-changelog.mjs --check` still 0.

#### Task 3.1 - [CREATE] `vercel.json`

**Description**: Match cursor-collections contract: install/build in `website/`, output `website/build`, so `prebuild` sync runs on deploy.

**Files:** `vercel.json` (create)

**Definition of Done**:

- [x] `buildCommand` / `outputDirectory` / `installCommand` target `website`
- [x] File is valid JSON

**Clues**: CC reference: `{"buildCommand":"cd website && npm install && npm run build","outputDirectory":"website/build","installCommand":"cd website && npm install"}`

#### Task 3.2 - [MODIFY] Document root-only changelog authoring

**Description**: Update human-facing docs so Repo Docs / maintainers edit `CHANGELOG.md` only and run sync (or rely on prebuild). Correct README “hosting deferred” if still present.

**Files:** `README.md` (modify), `.ai/skills/eversis-writing-repo-documentation/SKILL.md` (modify), `website/docs/workflow/repo-docs.md` (modify — if present and still accurate)

**Definition of Done**:

- [x] README states docs site hosting (Vercel) and that `/changelog` is generated from root
- [x] Writing-repo-documentation skill states changelog SSOT = root; do not hand-edit generated site page
- [x] `node scripts/sync-changelog.mjs --check` exits 0 after doc edits (docs must not require changing generated page)

**Clues**: Stack policy allows `eversis-writing-repo-documentation` for this phase.

### Phase 4: Code Review

**Goal**: Independent review confirms sync correctness, no dual-SSOT regression, and quality commands pass.

**Description**: Mandatory final gate via Code Reviewer.

**Verification:** `node scripts/sync-changelog.mjs --check` and `npm run website:build`

#### Task 4.1 - [REUSE] Code review by Code Reviewer

**Description**: Run **Code Reviewer** via `eversis-review.md` on the full diff (script, changelog merge, website hooks, vercel.json, docs).

**Files:** `scripts/sync-changelog.mjs` (reuse), `CHANGELOG.md` (reuse), `website/src/pages/changelog.md` (reuse), `website/package.json` (reuse), `vercel.json` (reuse), `README.md` (reuse)

**Definition of Done**:

- [x] Run `node scripts/sync-changelog.mjs --check`
- [x] Run `npm run website:build`
- [x] Code review passes with no blocking findings
- [x] Review outcome documented in this plan Changelog

**Clues**: Focus on “hand-edit site page” footguns, MDX breakage, and whether Prior history banner is clear.

## Security Considerations

- Sync script must only read/write fixed relative paths under the repo (no user-controlled path args that escape the tree).
- Do not embed secrets; changelog is public.
- Generated page may contain many external GitHub links — keep https only; no `javascript:` URLs.
- `vercel.json` must not broaden install beyond `website/` needs.

## Quality Assurance

- [x] Root `CHANGELOG.md` is the only file humans edit for changelog content
- [x] Site `/changelog` shows SemVer sections and Prior history after build
- [x] `sync-changelog --check` fails if generated page is manually diverged
- [x] `npm run website:build` succeeds with `prebuild` sync
- [x] `vercel.json` defines website build output for deploy
- [x] Snapshot/manual-disclaimer wording removed from the live page source
- [x] README / skill docs describe root-only authoring

## Improvements (Out of Scope)

- Backfill dated sections present in CC root but omitted from the AC site snapshot
- Restore full CC `sync-prompts` / `sync-framework-doc` pipeline in Agent Collections
- Add MCP `eversis_repo_run_script` allowlist entry for changelog sync
- Automated Playwright assert against production URL in CI
- SemVer automation / release tooling


## Code Review Findings

**Verdict:** PASS

### STRICT FORBIDDEN
- Scope: all changed files match the approved plan (changelog SSOT, sync script, website hooks, vercel.json, docs).
- Documentation comments: N/A (no JSDoc stripping).
- Dependencies: no new package-manager dependencies.

### Findings
- **PASS** — Root SSOT includes SemVer + Prior history; generated site page tip replaces snapshot disclaimer.
- **PASS** — `scripts/sync-changelog.mjs` fixed paths only; `--check` drift gate verified.
- **PASS** — `website` `prebuild`/`prestart` sync; `npm run website:build` succeeded; built `/changelog` contains Unreleased + Prior history.
- **PASS** — `vercel.json` matches cursor-collections website deploy contract.
- **SUGGESTION** — Optionally add `website:changelog:check` to `.cursor/rules/eversis-project-stack.mdc` quality commands (AGENTS.md already lists it).
- **SUGGESTION** — After merge, confirm Vercel dashboard respects repo `vercel.json` (or override) so production redeploys regenerate `/changelog`.

## Changelog

| Date | Change Description |
| ------ | -------------------- |
| 2026-08-12 | Initial plan created — Variant B, root SSOT, sync + drift + vercel.json |
| 2026-08-12 | Phases 1–3 implemented; `website:build` + `--check` OK |
| 2026-08-12 | `eversis-review` PASS → Fine |
