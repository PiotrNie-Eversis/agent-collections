# Agent Collections

Vendor-neutral multi-agent framework core (SSOT under `.ai/`). Adapters, installer, and MCP consume this repository; they do not own the canonical content.

**Status:** Pre-distribution MVP (`v0.0.1`). Core rules, skills, and prompts are present. Adapters, self-contained bootstrap, and installer are not shipped yet.

**Related channel:** [Cursor Collections](https://github.com/PiotrNie-Eversis/cursor-collections) remains a separate Cursor distribution. It does **not** share SemVer with Agent Collections.

## Versioning

| Rule | Detail |
|------|--------|
| Scheme | [Semantic Versioning](https://semver.org/) on this repository |
| First placeholder | **`v0.0.1`** (until self-contained distribution / installer land) |
| Release unit | One git tag covers core (`.ai/`), adapters, installer, and MCP **together** when those pieces exist — not a separate npm package for `.ai/` in MVP |
| Pinning | Consumers pin via **git tag**, **submodule ref**, or (later) installer `--version` |
| Changelog | Root [`CHANGELOG.md`](./CHANGELOG.md) — Keep a Changelog + SemVer |

Breaking releases **must** include a **Migration** subsection in `CHANGELOG.md` with concrete consumer steps.

## Upgrade contract

When moving from framework version **N** to **N+1**, use one of these documented paths:

| Mode | When to use | What to do (MVP) |
|------|-------------|------------------|
| **Local sync** | Shared / sibling checkout of this repo | Pull or check out the target tag/commit in the framework checkout; re-link or refresh consumer references to that checkout |
| **Submodule bump** | Framework vendored as a git submodule | Update the submodule to the target tag (`git fetch` + checkout tag / `git submodule update`), then refresh generated adapter surfaces when adapters exist |
| **CLI upgrade** | After the Agent Collections installer exists | Run the installer/upgrade command for the target version (forward-compatible; **not implemented in this repository yet** — see distribution stories) |

Until the installer ships, prefer **local sync** or **submodule bump**. Re-installing from scratch is unnecessary if you only need a newer framework revision.

### Project-owned files (never overwrite without opt-in)

Upgrade and sync **must not** overwrite these without an **explicit** consumer opt-in (flag, prompt, or manual merge):

| Path / class | Why |
|--------------|-----|
| `eversis-project-stack` (project rule / stack template) | Consumer-owned stack and skills policy |
| `docs/context/` | Project context and task baselines |
| `docs/specs/` | Project research / plan / local agent artifacts |
| Local `AGENTS.md` extensions beyond the framework template | Project-specific agent instructions |
| `.env*`, secrets, credentials | Security |
| Local ignore / MCP fragments outside a documented framework merge | Consumer environment choices |

**Framework-managed** content (may be refreshed on upgrade once adapters/installer exist): material derived from `.ai/`, framework skill/prompt packages, and generated adapter outputs — unless a later upgrade tool marks a path as locally modified.

### Specs and research (local only)

Story specs under `docs/specs/dhi-*/` are **local agent artifacts** in MVP (gitignored). They are not part of the published framework documentation surface. Committed docs for versioning/upgrade are this README and `CHANGELOG.md` only.

## Layout (core)

```text
.ai/                 # SSOT — rules, skills, prompts
AGENTS.md            # Short agent entry map for this repo
README.md            # This file — versioning & upgrade contract
CHANGELOG.md         # Release history and migration notes
```

See [`.ai/README.md`](./.ai/README.md) for the core mapping contract.

## Getting started (developers)

1. Clone this repository.
2. Read `.ai/README.md` and work under `.ai/` as the source of truth.
3. Do not treat sibling `cursor-collections` symlinks under `.cursor/` (if present) as the long-term SSOT — they are a temporary scaffold.

Installer, multi-agent wizard, and production upgrade CLI land in later stories.
