# MCP Docker Compose Docs Migration - Implementation Plan

## Task Details

| Field            | Value                                                                                     |
| ----------------- | ------------------------------------------------------------------------------------------ |
| Jira ID          | N/A — ad-hoc analysis task                                                                |
| Title            | Update README.md / website/ / MCP package README for the Docker Compose MCP runtime        |
| Description      | Commit `b27c4bf` moved the `eversis-collections` MCP server to a Docker Compose runtime; several docs were updated in that commit but `README.md`, `website/docs/getting-started/start-here.md`, `website/docs/getting-started/installation.md`, and `mcp/eversis-collections-mcp/README.md` were not, and now describe a stale `node`/`npm` build flow. |
| Priority         | Normal (docs accuracy — no runtime bug)                                                    |
| Related Research | [`mcp-docker-compose-migration.research.md`](./mcp-docker-compose-migration.research.md)   |

## Wildly Important Goal

**Goal**: Every doc a new or existing consumer reads to install/run/upgrade the `eversis-collections` MCP server accurately describes the Docker Compose runtime, with `installation.md` restructured to be readable by a non-technical person.

**Success Measure**: No remaining reference to `npm run mcp:install`/`npm run mcp:build`/`node dist/index.js` as the way to build or run the server in `README.md`, `website/docs/getting-started/start-here.md`, `website/docs/getting-started/installation.md`, or `mcp/eversis-collections-mcp/README.md`; `installation.md` opens with a plain-language explanation and isolates submodule/SHA mechanics into a clearly separated section.

**Do NOT touch / do NOT add**: No changes to `templates/mcp.json`, installer scripts (`scripts/lib/setup-agent-collections/*`), `CHANGELOG.md`, or the 4 website pages already updated by `b27c4bf` (`mcp-setup.md`, `prerequisites.md`, `integrations/eversis-collections.md`, `integrations/overview.md`) — these are already correct per research. No new MCP servers, no code/script changes, no new dependencies.

## Proposed Solution

Pure documentation edit across 4 files, driven directly by the research's Decisions section (Q1–Q3, human-approved). No architecture or code design is involved — the "design" is the resolved research recommendations:

1. **`README.md`** — swap the four stale `node`/`npm` build mentions (Prerequisites, Quick start step 3, "Build local server" section, Maintainers checklist) for the Docker Compose equivalents, matching the wording already used in the already-updated `website/docs/getting-started/prerequisites.md` and `mcp-setup.md`.
2. **`website/docs/getting-started/start-here.md`** — add Docker to the prerequisites checklist item.
3. **`website/docs/getting-started/installation.md`** — two kinds of edits: (a) fix the stale `--build-mcp` description and "Keeping consumers aligned" table wording; (b) restructure per the Q3 recommendations (plain-language intro, `:::tip New to Docker?` admonition, jargon glosses, an "Advanced" section housing the submodule/SHA/CLI-flag-skew mechanics, an explicit "is Docker running?" checkpoint).
4. **`mcp/eversis-collections-mcp/README.md`** — replace the `npm install && npm run build` quick-start and the stale "default entry" sentence with the Docker Compose equivalents.

No diagrams needed — this is prose/command-block editing, not a system design.

## Current Implementation Analysis

### Already Implemented

- `docker-compose.yml` — repo root — the Compose service the docs must describe (unchanged by this plan).
- `mcp/eversis-collections-mcp/Dockerfile` — multi-stage build the docs must describe (unchanged by this plan).
- `website/docs/getting-started/mcp-setup.md`, `prerequisites.md`, `website/docs/integrations/eversis-collections.md`, `website/docs/integrations/overview.md` — already correctly describe the Docker Compose flow (source of the exact wording/command blocks to reuse for consistency).
- `templates/mcp.json` — already emits the `docker compose ... run --rm -T eversis-collections` entry (reference for the exact `args` array shown in docs code blocks).

### To Be Modified

- `README.md` — `~L60–66` (Prerequisites), `~L140–144` (Quick start step 3), `~L276–283` (Build local server), `~L389–395` (Maintainers checklist).
- `website/docs/getting-started/start-here.md` — `~L22` (prerequisites checklist item).
- `website/docs/getting-started/installation.md` — `~L61` (`--build-mcp` flag description), `~L108–115` ("Keeping consumers aligned" table), plus a structural rewrite of the top-of-file flow (new intro + admonition + "Advanced" section placement) per Q3.
- `mcp/eversis-collections-mcp/README.md` — `~L9–14` (quick-start commands + default-entry sentence).

### To Be Created

- None — no new files. `installation.md`'s restructure may add a new subsection heading ("Advanced: keeping a team submodule in sync" or similar) but this is a section within the existing file, not a new file.

## Open Questions

None — Q1, Q2, and Q3 raised during research were resolved by the human and recorded in the research file's Decisions section before this plan was authored.

## Technical Context

### Project Instructions

- `agent-core.md` hard limits: no edits outside task/plan scope, no silent removal/shortening of documentation comments, no new dependencies — all respected (docs-only, additive/corrective edits, zero dependencies).
- `spec-driven-development.md`: this plan follows Research → Plan → Implement → Review → Fine; `docs/specs/mcp-docker-compose-migration/` is gitignored in this repo (framework self-instructions: all `docs/specs/*/` story folders are local-only here).

### Architecture & Patterns

- Docs live in two families: root single-file docs (`README.md`, `mcp/eversis-collections-mcp/README.md`) with no build step, and Docusaurus pages under `website/docs/**/*.md` with Docusaurus admonition syntax (`:::info`, `:::tip`, `:::caution`) already used throughout (e.g. `installation.md` L8 `:::info Curated path`).
- Existing docs consistently show the MCP entry as a fenced ```json code block with a `"eversis-collections": { "command": "docker", "args": [...] }` shape — reuse this exact shape (see `website/docs/integrations/overview.md` and `mcp-setup.md`) rather than inventing new formatting.

### Tech Stack

- Docs site: Docusaurus 3.10.2 (`website/`), Node ≥ 18 (`website/package.json` engines).
- No markdown linter configured in this repo — the only automated doc-quality gate is a successful Docusaurus build (`website:build`) plus the changelog-drift check (`website:changelog:check`, unrelated to this task since `CHANGELOG.md` is out of scope here).

### Code Style & Standards

- Existing docs use sentence-style prose with bold key terms, backticked file/command names, and Docusaurus admonitions for callouts — match this style, do not introduce a different tone/format.
- Root `README.md` uses `>` blockquotes for one-line callouts (e.g. `> **Important:** ...`) — prefer this over Docusaurus admonition syntax in `README.md` itself (GitHub-flavored markdown, no Docusaurus renderer).

### Testing Patterns

- Website changes: `npm run website:build` (repo root) or `cd website && npm run build` — Docusaurus build fails on broken internal links/refs, which is the deterministic check available for `start-here.md` / `installation.md`.
- Root `README.md` / `mcp/eversis-collections-mcp/README.md`: no build step exists; verify via `grep` for the presence of corrected strings and the absence of stale strings (deterministic, reviewer-runnable).

### Additional Context

- Exact "already correct" wording to mirror (do not diverge from these phrasings without reason):
  - `website/docs/getting-started/prerequisites.md` — "## Docker" section: "**Docker Engine + Compose v2** are required to **run** the local `eversis-collections` MCP server... `docker compose build eversis-collections` ... **Node.js ≥ 18** is required only to **develop** the `eversis-collections` MCP package itself..."
  - `website/docs/getting-started/mcp-setup.md` step 2: "Build the Docker Compose image (requires Docker Engine + Compose v2 — see [Prerequisites](./prerequisites)): ... `docker compose build eversis-collections`"

## Implementation Plan

### Phase 1: Root `README.md` — replace stale Node/npm MCP build guidance

**Goal**: Every root-README instruction for building/running the `eversis-collections` MCP server matches the Docker Compose flow already documented in `prerequisites.md`/`mcp-setup.md`.

**Description**: Four locations in `README.md` still tell the reader to run `npm run mcp:install && npm run mcp:build` or `cd mcp/eversis-collections-mcp && npm install && npm run build` as the way to make the MCP server usable. Since `b27c4bf`, that no longer builds the artifact the generated `.mcp.json`/`.cursor/mcp.json` entry runs — the entry now invokes `docker compose ... run --rm -T eversis-collections`, and the image must be built with `docker compose build eversis-collections`. Update Prerequisites, Quick start step 3, the "Build local server" section, and add a Docker build verification step to the Maintainers checklist (per research Q2 — additive, not a replacement for `npm run mcp:test`).

**Verification:** `grep -n "docker compose build eversis-collections" README.md` shows 2+ matches; `grep -n "mcp:install && npm run mcp:build\|npm install && npm run build" README.md` (outside of the now-corrected Maintainers dev-loop mention, if any remains for `mcp:test`) shows no leftover build-instruction matches.

#### Task 1.1 - [MODIFY] Prerequisites section

**Description**: Replace "Node.js ≥ 18 — to build the local `eversis-collections` MCP package" with a Docker Engine + Compose v2 requirement (to run), and clarify Node.js ≥ 18 is needed only to develop the MCP package — matching `prerequisites.md`'s already-updated wording.

**Files:** `README.md` (modify)

**Definition of Done**:

- [x] `README.md`'s Prerequisites list includes "Docker Engine" and "Compose v2" as a requirement to run `eversis-collections`
- [x] `README.md`'s Prerequisites list states Node.js ≥ 18 is needed only to develop the MCP package, not to run it
- [x] Run `grep -n "Docker Engine" README.md` — at least one match in the Prerequisites section

**Clues**: Mirror `website/docs/getting-started/prerequisites.md`'s "## Docker" / "## Node.js" wording for consistency across docs.

#### Task 1.2 - [MODIFY] Quick start step 3

**Description**: Replace the "Build MCP (skills discoverability)" step's `npm run mcp:install && npm run mcp:build` command with `docker compose build eversis-collections`, and reword the step heading/prose if it currently implies an npm-only flow.

**Files:** `README.md` (modify)

**Definition of Done**:

- [x] Quick start step 3's fenced command block shows `docker compose build eversis-collections`
- [x] The stale `npm run mcp:install && npm run mcp:build` command no longer appears in this step
- [x] Run `grep -n "npm run mcp:install && npm run mcp:build" README.md` — no match remaining in the Quick start section

**Clues**: Existing step numbering/surrounding steps (export `AGENT_COLLECTIONS_HOME`, refresh adapters) must stay intact — only the build command and its prose change.

#### Task 1.3 - [MODIFY] "Build local server: eversis-collections" section

**Description**: Replace both `cd mcp/eversis-collections-mcp && npm install && npm run build` and the repo-root alias `npm run mcp:install && npm run mcp:build` with `docker compose build eversis-collections`, matching the fenced code block style used in `mcp-setup.md`.

**Files:** `README.md` (modify)

**Definition of Done**:

- [x] The "Build local server" section's fenced command block shows `docker compose build eversis-collections`
- [x] No `npm install && npm run build` or `npm run mcp:install && npm run mcp:build` remains in this section
- [x] Run `grep -c "docker compose build eversis-collections" README.md` returns ≥ 2 (Quick start + this section)

**Clues**: This section currently also links to `mcp/eversis-collections-mcp/README.md` as "Tool reference" — leave that link intact (fixed in Phase 3).

#### Task 1.4 - [MODIFY] Maintainers checklist

**Description**: Add a new Maintainers step: `docker compose build eversis-collections` after MCP package changes, as its own checklist item (per research Q2 recommendation) — additive alongside the existing `npm run mcp:test` step, not replacing it.

**Files:** `README.md` (modify)

**Definition of Done**:

- [x] Maintainers numbered list contains a step running `docker compose build eversis-collections` after MCP changes, distinct from the existing `npm run mcp:test` step
- [x] Run `grep -n "docker compose build eversis-collections" README.md` — a match exists in the Maintainers section (in addition to Quick start / Build local server matches)

**Clues**: Insert immediately after (or as a sub-bullet of) the existing "Run `npm run mcp:test` after MCP changes" step so both dev-loop checks are adjacent.

### Phase 2: `start-here.md` and `installation.md` — Docker prerequisite + non-technical restructure

**Goal**: A first-time, non-technical reader following `installation.md` top-to-bottom understands why Docker matters before hitting any command, and never has to parse submodule/SHA internals unless they choose to.

**Description**: `start-here.md`'s prerequisites checklist item still lists only "Node.js ≥ 18" (no Docker). `installation.md` has two problems: a stale `--build-mcp` description (says it checks for `dist`, should say Docker image) and a "Keeping consumers aligned" table that doesn't flag the submodule-pin gap found in research §A; and, per research Q3, the file's structure and register are maintainer-grade throughout, which is unfriendly to a non-technical first-time installer. Apply the Q3 restructure: plain-language intro, `:::tip New to Docker?` admonition, inline jargon glosses, an "Advanced" section housing the CLI-flag-skew/submodule-pin mechanics, and an explicit "is Docker running?" checkpoint before the first Docker command.

**Verification:** Run `npm run website:build` (repo root) — Docusaurus build succeeds with no broken links/refs introduced by the edits.

#### Task 2.1 - [MODIFY] `start-here.md` prerequisites checklist

**Description**: Update checklist item 1 to include Docker Engine + Compose v2 alongside Cursor/Claude Code/Node.js/Git.

**Files:** `website/docs/getting-started/start-here.md` (modify)

**Definition of Done**:

- [x] Checklist item 1 lists Docker Engine + Compose v2 as a prerequisite
- [x] Run `grep -n "Docker" website/docs/getting-started/start-here.md` — at least one match in the checklist item

**Clues**: Keep the existing numbered-checklist format; this is a one-line addition, not a restructure (restructuring is scoped to `installation.md` only per Q3).

#### Task 2.2 - [MODIFY] `installation.md` — fix stale `--build-mcp` description and alignment table

**Description**: Update the `--build-mcp` flag-table row (currently: "Force rebuild of `mcp/eversis-collections-mcp` (also builds when `dist` is missing)") to describe the Docker image check (`docker image inspect`) instead of `dist`. Update the "Keeping consumers aligned" table's "Local + symlink" row wording (avoid ambiguous "rebuild MCP") and "Vendor submodule" row to note that a submodule pin must still be bumped manually to receive framework changes that aren't a CLI-flag skew (per research §A gap).

**Files:** `website/docs/getting-started/installation.md` (modify)

**Definition of Done**:

- [x] `--build-mcp` row describes checking/building a Docker image, not `dist/index.js`
- [x] "Vendor submodule" row in "Keeping consumers aligned" notes manual pin-bump is required for non-CLI-flag framework changes
- [x] Run `grep -n "dist.*missing\|dist/index" website/docs/getting-started/installation.md` — no match remains

**Clues**: Reuse `scripts/lib/setup-agent-collections/build-mcp.sh`'s actual check (`docker compose -f "$compose_file" config --images ...` + `docker image inspect`) as the factual basis, phrased in plain language for this table.

#### Task 2.3 - [MODIFY] `installation.md` — non-technical restructure (Q3)

**Description**: Apply the research's Q3 recommendations as a structural edit:
1. Add a 2–3 sentence plain-language intro above "## 1. Clone the framework" (what installing does; why Docker matters now) — no jargon (`stdio`, `compose`, `dist`).
2. Add a `:::tip New to Docker?` admonition near the first Docker-relevant step: what Docker Desktop is, a download link, and a friendly "confirm it's running" cue (e.g. menu-bar whale icon) instead of a raw `docker ps` command.
3. Gloss "pin" and "SHA" inline at first use in prose (not just in tables).
4. Move the CLI-flag-skew / submodule-pin mechanics (currently inline under "5. Upgrade" and "Keeping consumers aligned") into a separated "Advanced: keeping a team submodule in sync" subsection with a one-line "skip this unless your team vendors the framework as a submodule" pointer.
5. Add an explicit "is Docker running?" checkpoint immediately before the first command that needs Docker.

**Files:** `website/docs/getting-started/installation.md` (modify)

**Definition of Done**:

- [x] File opens with a plain-language paragraph (no `stdio`/`compose`/`dist` jargon) before the first numbered section
- [x] A `:::tip` (or `:::info`) admonition mentioning Docker Desktop appears before the first Docker command in the main flow
- [x] "pin" and "SHA" each have an inline gloss at first prose use
- [x] A distinctly-headed "Advanced" (or `<details>`) section contains the submodule CLI-flag-skew / SHA-alignment mechanics, separated from the main linear flow
- [x] An explicit Docker-running checkpoint appears before the first `docker`/`--build-mcp` command a first-time reader reaches
- [x] Run `npm run website:build` (repo root) — succeeds with no new broken-link/ref errors

**Stop Rule:** If restructuring risks breaking any existing anchor links referenced from other pages (e.g. `start-here.md` links to `./installation`), keep heading anchors stable (do not rename existing `##`/`###` headings referenced elsewhere) — only add new headings/sections.

**Clues**: Check `grep -rn "installation#" website/docs/ README.md` before renaming any heading, to avoid breaking anchor links from other pages.

### Phase 3: `mcp/eversis-collections-mcp/README.md` — fix stale build/entry docs

**Goal**: The MCP package's own README (linked from root README's "Tool reference") matches the Docker Compose runtime instead of contradicting it.

**Description**: This file was not touched by `b27c4bf` and still shows `npm install && npm run build` as the quick-start and states the default MCP entry is `${env:AGENT_COLLECTIONS_HOME}/mcp/eversis-collections-mcp/dist/index.js` — both factually wrong now. Per research Q1 (human-confirmed in scope), replace with the Docker Compose equivalents, keeping a short dev-loop note (`npm install && npm run build`/`npm test` still valid for package development, per CHANGELOG wording) clearly separated from "how the server actually runs for consumers."

**Verification:** `grep -n "dist/index.js\|npm install\s*$" mcp/eversis-collections-mcp/README.md` — the "default entry" sentence and the bare quick-start no longer describe the pre-Docker path unqualified.

#### Task 3.1 - [MODIFY] Quick-start and default-entry sections

**Description**: Update the quick-start block: keep `npm install && npm run build` only if reframed as "for package development" (matching CHANGELOG's "Node.js ≥18 remains required only for developing the package" wording), and replace "default entry uses `${env:AGENT_COLLECTIONS_HOME}/mcp/eversis-collections-mcp/dist/index.js`" with the Docker Compose entry shape shown in `templates/mcp.json`.

**Files:** `mcp/eversis-collections-mcp/README.md` (modify)

**Definition of Done**:

- [x] The "default entry" sentence describes `docker compose -f .../docker-compose.yml run --rm -T eversis-collections`, not `dist/index.js`
- [x] Any retained `npm install && npm run build` mention is explicitly framed as package-development-only, not the way to make the server runnable for consumers
- [x] Run `grep -n "dist/index.js" mcp/eversis-collections-mcp/README.md` — no unqualified match remains (or none at all)

**Clues**: Reuse the exact `args` array from `templates/mcp.json` (`"compose", "-f", ..., "run", "--rm", "-T", "eversis-collections"`) for consistency with every other doc already updated by `b27c4bf`.

### Phase 4: Code Review

**Goal**: Independent verification that all four files are internally consistent with each other and with the already-updated docs from `b27c4bf`, before declaring the doc migration Fine.

**Description**: Final verification of the complete documentation update. This phase is mandatory and always comes last.

**Verification:** Run `npm run website:build` (repo root) — succeeds; `grep -rn "mcp:install && npm run mcp:build\|dist/index.js" README.md mcp/eversis-collections-mcp/README.md website/docs/getting-started/start-here.md website/docs/getting-started/installation.md` returns no unqualified matches.

#### Task 4.1 - [REUSE] Code review by Code Reviewer

**Description**: Run **Code Reviewer** via `eversis-review.md` to review the complete documentation update across all 4 files for accuracy against `docker-compose.yml`/`Dockerfile`/`templates/mcp.json` and for internal consistency with the 4 docs already updated by `b27c4bf`.

**Files:** `README.md` (reuse), `website/docs/getting-started/start-here.md` (reuse), `website/docs/getting-started/installation.md` (reuse), `mcp/eversis-collections-mcp/README.md` (reuse)

**Definition of Done**:

- [x] Run `npm run website:build` (repo root)
- [x] Code review passes with no blocking findings
- [x] Review outcome documented in Changelog (this plan's Changelog table, below)

**Clues**: No STRICT FORBIDDEN scope risk expected (docs-only, no dependency/comment-removal changes) — review should focus on factual accuracy and cross-doc consistency, not the Hard Limits checks.

## Security Considerations

- None specific to this task — no code, no secrets, no dependency changes. The only "security-adjacent" note already exists in `docker-compose.yml`'s comments (non-root container user in the Dockerfile) and is out of scope to alter here.

## Quality Assurance

- [x] No remaining reference to `npm run mcp:install`/`npm run mcp:build`/bare `npm install && npm run build` as the way to make the `eversis-collections` MCP server runnable, in any of the 4 target files
- [x] No remaining reference to `dist/index.js` as the MCP entry's runtime path in any of the 4 target files
- [x] `README.md` Prerequisites, Quick start, "Build local server", and Maintainers sections all show `docker compose build eversis-collections`
- [x] `start-here.md` prerequisites checklist mentions Docker
- [x] `installation.md` opens with a plain-language intro, has a Docker tip admonition, glosses "pin"/"SHA" at first use, isolates submodule/SHA mechanics in an "Advanced" section, and has an explicit Docker-running checkpoint
- [x] `mcp/eversis-collections-mcp/README.md` shows the Docker Compose entry as the default, with any retained npm commands clearly scoped to package development
- [x] `npm run website:build` succeeds
- [x] No edits made to `templates/mcp.json`, installer scripts, `CHANGELOG.md`, or the 4 already-updated website pages

## Improvements (Out of Scope)

- A general (not Docker-change-specific) callout in `installation.md`'s "Vendor submodule" row that **any** framework change requiring a new file/behavior needs a manual submodule pin bump unless it happens to trip the CLI-flag-skew check — this plan adds a note for *this* change's context per Q3/Task 2.2, but a more general reusable phrasing is left for a future docs pass if the team wants it.
- Adding a markdown linter / doc-link checker to CI so staleness like this (docs not updated alongside a code change) is caught automatically — flagged as a process gap by this analysis, not part of this docs-only plan.

## Code Review Findings

**Reviewed:** all 4 target files (`README.md`, `website/docs/getting-started/start-here.md`, `website/docs/getting-started/installation.md`, `mcp/eversis-collections-mcp/README.md`) against `docker-compose.yml`, `mcp/eversis-collections-mcp/Dockerfile`, `templates/mcp.json`, and the 4 already-correct pages from `b27c4bf`.

**Verdict: PASS** (one minor finding, fixed during review — no blockers remain).

- **Cross-file accuracy**: every `docker compose build eversis-collections` / `docker compose ... run --rm -T eversis-collections` string added matches the actual service name in `docker-compose.yml` and the exact `args` array in `templates/mcp.json` — no invented flags or paths.
- **Consistency with already-correct docs**: wording in `README.md` Prerequisites and `mcp/eversis-collections-mcp/README.md` mirrors the phrasing already used in `prerequisites.md`/`mcp-setup.md` (Docker to run, Node ≥18 to develop only) — no divergent explanations introduced.
- **Scope**: `git status` confirms only the 4 target files changed, plus `website/src/pages/changelog.md` — the latter is a generated file rewritten by `npm run website:changelog:sync` (part of the `website:build` prebuild step) picking up pre-existing drift from root `CHANGELOG.md`; not a manual edit and not one of the "do not touch" files (that restriction is on the root `CHANGELOG.md`, untouched). No edits to `templates/mcp.json`, installer scripts, or the 4 already-updated website pages.
- **`installation.md` restructure (Q3)**: plain-language intro, `:::tip New to Docker?` admonition, "Advanced: keeping a team submodule in sync" section, and Docker-running checkpoint all present and read correctly; `npm run website:build` succeeds twice with no broken-link or broken-anchor warnings (checked explicitly — `onBrokenLinks: "throw"` in `docusaurus.config.ts`, and a `grep -i "warn"` on build output found nothing).
- **Finding (fixed during review)**: Task 2.3's DoD required "pin" glossed at first prose use, but the true first occurrence — "Pin consumers to a **SemVer git tag**..." (pre-existing line, now L24) — predated the gloss added at the Vendor modes table (L60). Fixed by adding an inline `(lock)` gloss at L24 itself. Re-ran `npm run website:build` after the fix — still succeeds.
- **Security**: no code, secrets, or dependency changes; nothing to flag.

No BLOCKER or open SUGGESTION findings remain.

## Changelog

| Date       | Change Description   |
| ---------- | --------------------- |
| 2026-08-21 | Initial plan created from approved research (Q1–Q3 decisions incorporated) |
| 2026-08-21 | Implemented all 4 phases; code review performed — PASS, one minor gloss-placement gap found and fixed during review (see Code Review Findings) |
