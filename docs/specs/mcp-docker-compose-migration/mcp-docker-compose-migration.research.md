# Research — Impact of commit b27c4bf (MCP server → Docker Compose)

## Task Context

Analyze commit `b27c4bf` (`feat(mcp): run eversis-collections MCP server via Docker Compose`) to determine:

1. What consumer projects that vendor Agent Collections under `vendor/agent-collections/` (submodule or copy mode) must do to pick up this change.
2. What is stale or missing in root `README.md` and `website/docs/` regarding installation and package-update instructions — beyond what the commit itself already touched.

Analysis-only per Implement readiness routing (`przeanalizuj` entry signal) — no code changes in this session. Plan follows after this research is approved.

## Summary of commit b27c4bf

- Adds root `docker-compose.yml` (bind-mounts its own directory to `/repo`, hardcodes `AGENT_COLLECTIONS_HOME=/repo` in-container) and a multi-stage `mcp/eversis-collections-mcp/Dockerfile` (+ `.dockerignore`).
- `templates/mcp.json`, `scripts/lib/setup-agent-collections/mcp-merge.mjs`, and `scripts/lib/setup-agent-collections/build-mcp.sh` now generate/build a `docker compose -f <path>/docker-compose.yml run --rm -T eversis-collections` stdio entry instead of `node dist/index.js`.
- `scripts/lib/setup-agent-collections/vendor.sh` (`setup_vendor_copy`) now also copies root `docker-compose.yml` into `vendor/agent-collections/docker-compose.yml` (it sits outside the existing `src_dirs` list, so it needed an explicit copy step).
- `--build-mcp` now requires `docker` and checks/builds a Docker image instead of checking for `dist/index.js`.
- CHANGELOG.md already carries a **Migration** subsection (breaking-change policy compliant).
- Docs already updated *by this commit*: `website/docs/getting-started/mcp-setup.md`, `website/docs/getting-started/prerequisites.md`, `website/docs/integrations/eversis-collections.md`, `website/docs/integrations/overview.md`.
- Root `package.json` was **not** touched — `mcp:build` / `mcp:install` / `mcp:test` scripts are unchanged (`npm --prefix mcp/eversis-collections-mcp ...`) and remain the **contributor dev-loop** commands only (per the new CHANGELOG wording), not the run path.

## A. Impact on consumer projects vendoring under `vendor/agent-collections/`

Traced via `mcp-merge.sh` (`useRelative` is true whenever `VENDOR_MODE` is `submodule` **or** `copy` — same relative Compose path is generated for both: `${workspaceFolder}/vendor/agent-collections/docker-compose.yml` for Cursor, `${CLAUDE_PROJECT_DIR:-.}/vendor/agent-collections/docker-compose.yml` for Claude).

### Submodule mode (`--vendor submodule`)

- `docker-compose.yml`/`Dockerfile` become available automatically **once the submodule pin is bumped** to a commit at/after `b27c4bf` — no vendor-copy step is involved for submodule mode.
- **Gap found:** `scripts/lib/setup-agent-collections/vendor-sync-skew.sh` (`align_vendor_sync_cli_or_die`) only auto-checks-out the installer's HEAD SHA into the vendored submodule when it detects a **CLI-flag skew** in `adapters/sync.mjs` (currently only the `--framework-prefix` flag). This Docker Compose change does **not** add such a flag, so `--upgrade --sync` will **not** automatically bump an existing submodule pin to pick it up.
- **Consumer steps required:**
  1. `cd vendor/agent-collections && git fetch origin && git checkout <tag-or-sha-at-or-after-b27c4bf>` (or `git submodule update --remote` if tracking a branch), then `git add vendor/agent-collections` and commit the pin bump in the consumer repo.
  2. Install **Docker Engine + Compose v2** on every machine that runs the agent tool (CI included, if MCP is exercised there).
  3. Re-run `bash vendor/agent-collections/scripts/setup-agent-collections.sh --upgrade --sync --build-mcp --non-interactive` (reuses `.agent-collections/install-selection.json`) to both build the Docker image and rewrite `.mcp.json` / `.cursor/mcp.json`'s `eversis-collections` entry to the `docker compose ... run --rm -T` shape.
  4. Optional cleanup: remove any locally-built `vendor/agent-collections/mcp/eversis-collections-mcp/dist/` from the old flow (no longer read).

### Copy mode (`--vendor copy`)

- `setup_vendor_copy` (in `vendor.sh`) unconditionally re-copies `docker-compose.yml` (and the existing `src_dirs` tree) **every time it runs** — including during `--upgrade --sync` — so a copy-mode consumer picks up the new file automatically, provided the **source** framework checkout that `AGENT_COLLECTIONS_HOME` / `--collections-home` points at has itself been updated to `b27c4bf`+ first.
- **Consumer steps required:**
  1. Update the local `agent-collections` clone used as the installer source (`git pull` / checkout the new tag) — this is the copy *source*, separate from the consumer's `vendor/agent-collections/` copy.
  2. Install Docker Engine + Compose v2.
  3. Re-run `setup-agent-collections.sh --upgrade --sync --build-mcp --non-interactive` (or `--vendor copy --build-mcp` per the existing installation.md table) — this re-copies `vendor/agent-collections/` (including the new `docker-compose.yml`, `Dockerfile`, `.dockerignore`, updated `scripts/`, `templates/`) and rewrites the MCP entry.
  4. Same optional `dist/` cleanup as above.

### Both modes — shared

- Hand-maintained (non-installer) `.mcp.json` / `.cursor/mcp.json` entries must be edited manually to the new shape (CHANGELOG migration note already says this).
- No consumer-owned files (`docs/context/`, `docs/specs/`, stack rule, `AGENTS.md`, secrets) are touched by this change — no conflict risk there.
- Root `package.json` in a copy-mode vendor tree is still copied (`setup_vendor_copy` preserves it), but it is irrelevant to the new run path — only relevant if the consumer team develops the MCP package itself.

## B. Stale/missing README.md and website/ content (not touched by b27c4bf)

The commit updated 4 website pages and `templates/mcp.json`/CHANGELOG, but left the following **inconsistent with the new Docker-based flow**:

| File | Location | Issue |
|---|---|---|
| `README.md` | Prerequisites (~L60–66) | Still lists only "Node.js ≥ 18 — to build the local `eversis-collections` MCP package" as a prerequisite; no Docker Engine/Compose v2 mention, and doesn't clarify Node is now dev-only. |
| `README.md` | Quick start step 3 (~L140–144) | `npm run mcp:install && npm run mcp:build` presented as how to "Build MCP (skills discoverability)" — this no longer builds the artifact the generated MCP entry runs; should be `docker compose build eversis-collections` (per updated `prerequisites.md`/`mcp-setup.md`). |
| `README.md` | "Build local server: eversis-collections" (~L276–283) | Same stale `cd mcp/eversis-collections-mcp && npm install && npm run build` / `npm run mcp:install && npm run mcp:build` guidance as the canonical build step. |
| `README.md` | Maintainers list (~L389–395) | `npm run mcp:test` step has no accompanying `docker compose build eversis-collections` verification step for maintainers validating the new runtime path. |
| `website/docs/getting-started/start-here.md` | Checklist item 1 (~L22) | "Cursor and/or Claude Code, **Node.js ≥ 18**, Git" — omits Docker Engine + Compose v2, which `prerequisites.md` (already updated by this commit) now lists as required to *run* the server. |
| `website/docs/getting-started/installation.md` | `--build-mcp` flag table (~L61) | Describes it as "Force rebuild of `mcp/eversis-collections-mcp` (also builds when `dist` is missing)" — stale; `build-mcp.sh` now checks/builds a Docker image (`docker image inspect`), not `dist/index.js`. |
| `website/docs/getting-started/installation.md` | "Keeping consumers aligned" table (~L108–115) | "Local + symlink" row says "rebuild MCP" (ambiguous post-Docker); "Vendor submodule" row describes only the CLI-flag-skew auto-align — doesn't mention that a submodule pin must still be bumped manually to receive *this* class of framework change (see §A gap above). |
| `mcp/eversis-collections-mcp/README.md` | Quick section (~L9–14) | Still documents `npm install && npm run build` and states the "default entry uses `${env:AGENT_COLLECTIONS_HOME}/mcp/eversis-collections-mcp/dist/index.js`" — this is the pre-Docker default and is now wrong; referenced from root README's "Tool reference" link. |

Not stale (already correctly updated by b27c4bf, verified): `website/docs/getting-started/mcp-setup.md`, `website/docs/getting-started/prerequisites.md`, `website/docs/integrations/eversis-collections.md`, `website/docs/integrations/overview.md`, `templates/mcp.json`, `CHANGELOG.md`.

## Decisions (resolved by human, 2026-08-21)

**Q1 — Fix `mcp/eversis-collections-mcp/README.md`?** **YES.** In scope for the plan even though it's outside the two explicitly named targets (README.md / website/) — it's directly linked from root README's "Tool reference" and is factually wrong post-commit (still shows `npm install && npm run build` and the pre-Docker default entry).

**Q2 — Add a `docker compose build eversis-collections` verification step to README.md's Maintainers checklist?** **Recommendation: YES, add it — alongside, not instead of, `npm run mcp:test`.**
- Rationale: `npm run mcp:test` only exercises the Node/npm dev-loop (unit tests against `src/`). The Dockerfile is a separate, independently-breakable artifact — multi-stage `COPY` paths, base-image pin, non-root user setup, `npm install --omit=dev` — none of which `mcp:test` touches. A maintainer changing `mcp/eversis-collections-mcp/` (or the Dockerfile itself) needs a command that actually proves the image still builds, otherwise a broken Dockerfile ships silently until a consumer's `--build-mcp` fails.
- Concrete addition: a 6th Maintainers step — `docker compose build eversis-collections` after MCP changes, run from repo root (same as consumers would run it), not folded into step 3 (`npm run mcp:test`).

**Q3 — Make `installation.md` readable for a non-technical person.** See dedicated recommendations below; plan should apply these as a restructure, not just a wording pass.

### Q3 — `installation.md` non-technical readability recommendations

Current file mixes first-time-install steps with maintainer-grade mechanics (SHA alignment, CLI-flag skew, submodule pin internals) at the same heading level and register — a non-technical reader hits `git checkout <sha>` reasoning before they've even run one command. Recommended restructure:

1. **Add a 2–3 sentence plain-language intro** above "## 1. Clone the framework": what installing does (turns on the assistant's built-in tools/skills for this project) and *why Docker now matters* ("the built-in skills tool now runs inside a small self-contained app called Docker, so it needs to be installed and running before setup"). No jargon (`stdio`, `compose`, `dist`) in this paragraph.
2. **Add a `:::tip New to Docker?` Docusaurus admonition** near the first Docker-relevant step (Prerequisites link and/or the `--build-mcp` step): one line on what Docker Desktop is, a link to the download page, and how to confirm it's running before continuing (e.g. "look for the whale icon in your menu bar" — friendlier than `docker ps`).
3. **Gloss jargon at first use, inline, instead of assuming prior knowledge** — e.g. "pin (the exact version your project is locked to)", "SHA (a unique ID for one specific version)". Keep the existing flag tables (already terse/scannable) but don't let undefined terms leak into prose a first-time reader follows top-to-bottom.
4. **Move deep mechanics into a clearly separated, skippable section** — wrap the submodule CLI-flag-skew explanation and "Keeping consumers aligned" table's more technical rows under a heading like "Advanced: keeping a team submodule in sync" (or a `<details>` block) with a one-line "skip this unless your team vendors the framework as a submodule" pointer, so a first-time / non-technical reader's linear read never has to parse it.
5. **Keep the "First successful install" copy-paste block prominent** (it already is, but consider a top-of-page anchor/link to it) for readers who just want to run commands end-to-end, separate from readers who want to understand each step.
6. **Add an explicit "is Docker running?" checkpoint** immediately before the first command that needs it, framed as a checkbox/step rather than assuming the reader will self-diagnose a Docker daemon error.

## Recommendation

Plan should cover, scoped to docs only (no further code changes — `b27c4bf` code changes are already complete and consistent):

- Update `README.md`: Prerequisites (Docker + Node dev-only), Quick start step 3, "Build local server" section, and Maintainers checklist (+ new `docker compose build eversis-collections` step per Q2).
- Update `website/docs/getting-started/start-here.md` checklist item 1.
- Restructure `website/docs/getting-started/installation.md` per the Q3 recommendations above (plain-language intro, Docker tip admonition, jargon glosses, "Advanced" section for submodule/SHA mechanics, Docker-running checkpoint) — not just fixing the stale `--build-mcp` description and "Keeping consumers aligned" table wording, but reorganizing for the non-technical audience.
- Update `mcp/eversis-collections-mcp/README.md` build/entry documentation (Q1: confirmed in scope).
- No changes needed to already-updated website pages, `templates/mcp.json`, installer scripts, or CHANGELOG.
