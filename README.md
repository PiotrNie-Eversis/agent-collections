# Agent Collections

Vendor-neutral **multi-agent** product engineering framework. Canonical content lives under **`.ai/`**. Adapters, installer, and MCP consume this repository; they do not own the SSOT.

**Status:** Self-contained distribution MVP (`v0.0.1`). Fresh clone works without a sibling Cursor Collections checkout.

**Related channel:** [Cursor Collections](https://github.com/PiotrNie-Eversis/cursor-collections) remains a separate Cursor distribution. It does **not** share SemVer with Agent Collections. Documentation channels are **fully independent** (no shared docs portal).

## Vision (core + adapters)

```text
.ai/          SSOT — rules, skills, prompts
adapters/     Cursor · Claude Code · OpenCode (placeholder) + sync + profiles
mcp/          eversis-collections-mcp → skills from .ai/skills
scripts/      setup-agent-collections.sh (local / submodule / copy)
```

Delivery standard: **Ideate → Research → Plan → Implement → Review → Fine**.

## Getting started

| Guide | Path |
|-------|------|
| **Start here** (first successful install) | [`website/docs/getting-started/start-here.md`](./website/docs/getting-started/start-here.md) |
| Prerequisites | [`website/docs/getting-started/prerequisites.md`](./website/docs/getting-started/prerequisites.md) |
| Installation | [`website/docs/getting-started/installation.md`](./website/docs/getting-started/installation.md) |
| MCP setup | [`website/docs/getting-started/mcp-setup.md`](./website/docs/getting-started/mcp-setup.md) |
| Quick wins | [`website/docs/getting-started/quick-wins.md`](./website/docs/getting-started/quick-wins.md) |
| **Migration from Cursor Collections** | [`website/docs/getting-started/migration-from-cursor-collections.md`](./website/docs/getting-started/migration-from-cursor-collections.md) |
| Framework reference | [`documentation/agent-collection.md`](./documentation/agent-collection.md) |
| WF / WNF traceability | [`docs/architecture/requirements-traceability.md`](./docs/architecture/requirements-traceability.md) |

**Docs site:** source under `website/` (Docusaurus). Build locally with `cd website && npm install && npm run build`. **Public hosting is deferred** (out-of-band) — there is no production docs URL in this MVP.

## Quick start (developers)

1. Clone this repository (no sibling framework required).
2. Export the framework home for MCP:

```bash
export AGENT_COLLECTIONS_HOME="$(pwd)"
```

3. Build MCP (skills discoverability):

```bash
npm run mcp:install && npm run mcp:build
```

4. Refresh adapter surfaces:

```bash
npm run sync:adapters
# drift check:
npm run sync:adapters:check
```

5. Load skills via MCP server **`eversis-collections`** (see `templates/mcp.json`) or read `.ai/skills/*/SKILL.md` / attach prompts by stable id under `.ai/prompts/`.

**Note (Q1):** This MVP does **not** ship a full mirror of skills/prompts under `.cursor/skills` or `.cursor/prompts`, and does **not** generate slash-commands under `.cursor/commands/`. Prefer MCP + load-by-id / `@` attach.

## Install into a consumer project

```bash
export AGENT_COLLECTIONS_HOME=/path/to/agent-collections
bash "$AGENT_COLLECTIONS_HOME/scripts/setup-agent-collections.sh" \
  --build-mcp --non-interactive \
  --agents=cursor \
  --mcp-servers=eversis-collections \
  --profile=fullstack
```

### Vendor modes

| Mode | Flag | Notes |
|------|------|-------|
| **Local** | (default) | Framework stays outside the consumer repo; set `AGENT_COLLECTIONS_HOME` |
| **Submodule** | `--vendor submodule` | **EOG / team default** |
| **Copy** | `--vendor copy` | Vendors tree under `vendor/agent-collections/` |

Other useful flags: `--link-mode auto|symlink|copy`, `--sync`, `--upgrade`, `--agents`, `--mcp-servers`, `--profile frontend|backend|fullstack`.

Interactive wizard prompts for agents × MCP × domain profile. Re-runs are idempotent; partial failures list completed vs failed steps with recovery hints.

Selection is recorded at `.agent-collections/install-selection.json` (schema: [`docs/architecture/install-selection.md`](./docs/architecture/install-selection.md)).

### Upgrade

```bash
bash scripts/setup-agent-collections.sh --upgrade --sync --non-interactive
```

Reuses agents / MCP / profile / vendor / link from selection. Missing or corrupt selection **fails** with wizard instructions (no invented full install). Project-owned paths (stack rule, `docs/context|plans|specs`, local `AGENTS.md`, secrets) are not overwritten without opt-in.

Migrating from Cursor Collections (`setup-cursor-local.sh` / `CURSOR_COLLECTIONS_HOME`): see the [migration guide](./website/docs/getting-started/migration-from-cursor-collections.md).

## Versioning

| Rule | Detail |
|------|--------|
| Scheme | [Semantic Versioning](https://semver.org/) on this repository |
| First placeholder | **`v0.0.1`** |
| Release unit | One git tag covers core (`.ai/`), adapters, installer, and MCP **together** — not a separate npm package for `.ai/` in MVP |
| Pinning | Consumers pin via **git tag**, **submodule ref**, or installer `--collections-home` |
| Changelog | Root [`CHANGELOG.md`](./CHANGELOG.md) — Keep a Changelog + SemVer |

Breaking releases **must** include a **Migration** subsection in `CHANGELOG.md` with concrete consumer steps.

## Upgrade contract

When moving from framework version **N** to **N+1**, use one of these documented paths:

| Mode | When to use | What to do |
|------|-------------|------------|
| **Local sync** | Shared checkout of this repo | Pull/check out target tag; refresh consumer via installer `--upgrade --sync` or re-link |
| **Submodule bump** | Framework vendored as submodule | Update submodule to tag, then `setup-agent-collections.sh --upgrade --sync` |
| **CLI upgrade** | Installer present | `--upgrade` reuses `.agent-collections/install-selection.json` |

### Project-owned files (never overwrite without opt-in)

| Path / class | Why |
|--------------|-----|
| `eversis-project-stack` (project rule) | Consumer-owned stack and skills policy |
| `docs/context/` | Project context and task baselines |
| `docs/plans/` | Optional flat plans |
| `docs/specs/` | Project research / plan artifacts |
| Local `AGENTS.md` (once created) | Project-specific agent instructions |
| `.env*`, secrets, credentials | Security |
| Local ignore / MCP fragments outside documented merge | Consumer environment choices |
| `.agent-collections/install-selection.json` | Install record (upgrade reads; does not wipe) |

## Delivery standard (spec-driven development)

```text
Ideate → Research → Plan → Implement → Review → Fine
```

| Artifact | Path |
|----------|------|
| Spec folder | `docs/specs/<issue-kebab>/` |
| Research | `<issue-kebab>.research.md` (approve before plan) |
| Plan | `<issue-kebab>.plan.md` (approve before implement) |

Primary prompt entry = stable ids (`eversis-implement`, `eversis-review`). Optional (Cursor): `@`-attach the same files if your project surfaces them. Slash `/eversis-*` commands are not MVP.

## Layout

```text
.ai/                 # SSOT — rules, skills, prompts
adapters/             # cursor, claude, opencode + sync.mjs + profiles/
mcp/                  # eversis-collections-mcp (skills from .ai/skills)
scripts/              # setup-agent-collections.sh
templates/            # AGENTS, stack, mcp.json seeds
documentation/        # Framework reference (agent-collection.md)
website/              # Docusaurus docs site (local build; hosting deferred)
AGENTS.md             # Reference agent entry map
docs/architecture/    # Mapping, isolation, AGENTS standard, selection, WF/WNF
```

## Getting started (maintainers)

1. Clone this repository.
2. Read `.ai/README.md` and root [`AGENTS.md`](./AGENTS.md).
3. Run `npm run sync:adapters` after changing `.ai/rules` or `adapters/*/rule-map.yaml`.
4. Run `npm run mcp:test` after MCP changes.
5. Run `bash scripts/setup-agent-collections.test.sh` after installer changes.
6. Run `npm run website:build` (or `cd website && npm run build`) after docs site changes.
