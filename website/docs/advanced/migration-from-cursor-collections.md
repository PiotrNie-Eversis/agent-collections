---
sidebar_position: 5
title: Migration from Cursor Collections
---

# Migration from Cursor Collections

Safe cutover from **Cursor Collections** to **Agent Collections** without coupling documentation channels. This guide names the sibling product and installer only as migration facts — it does **not** deep-link to a legacy docs site or shared portal.

## When to migrate

- You need **multi-agent** packaging (Cursor + Claude MVP) from one SemVer-tagged core (`.ai/`).
- You want installer selection, domain/area profiles, and `AGENT_COLLECTIONS_HOME`-based MCP.
- You are ready to treat Cursor Collections as a **separate channel** (dual-channel code OK; **docs fully independent**).

Stay on Cursor Collections if your org only needs Cursor-only packaging and has not approved Agent Collections yet.

## Prerequisites

1. Pin a **SemVer tag** of `agent-collections` (or a known commit) for the pilot.
2. Prefer **vendor submodule** for team repos (recommended team default); local path is fine for individual developers.
3. Inventory consumer customizations: project stack rule, `AGENTS.md`, `docs/context/`, MCP servers beyond collections, ignore overlays.
4. Note current env: `CURSOR_COLLECTIONS_HOME` and any `setup-cursor-local.sh` automation.

## Cutover steps

1. **Add Agent Collections** — clone or submodule to a pinned tag; export `AGENT_COLLECTIONS_HOME`.
2. **Branch the consumer** — rollback-friendly pilot branch.
3. **Run the Agent Collections installer** (example):

```bash
export AGENT_COLLECTIONS_HOME=/path/to/agent-collections
bash "$AGENT_COLLECTIONS_HOME/scripts/setup-agent-collections.sh" \
  --vendor submodule --build-mcp --non-interactive \
  --agents=cursor,claude \
  --mcp-servers=eversis-collections \
  --profile=fullstack
```

4. **MCP env cutover** — replace `CURSOR_COLLECTIONS_HOME` with **`AGENT_COLLECTIONS_HOME`** in MCP config for `eversis-collections`. Keep other MCP servers (Atlassian, Figma, …) unless you intentionally drop them.
5. **Stop dual skills paths** — do not point the same skills server at both frameworks. Remove or ignore obsolete Cursor Collections symlinks for skills/prompts if the installer replaced them.
6. **Verify** — `.agent-collections/install-selection.json` present; `eversis_skills_list` works; Cursor rules and/or `CLAUDE.md` present as selected; first Implement session succeeds. For submodule installs, teammates need `git submodule update --init --recursive`.
7. **Document** — update consumer runbooks; Cursor stack in `eversis-project-stack.mdc`, Claude stack in `.claude/CLAUDE.md` (seeded once, never overwritten — Claude Code does not auto-read `AGENTS.md`); deprecate `setup-cursor-local.sh` for this repo when cutover is accepted.

## Ownership model (local / core / generated)

| Layer                       | Owns                                                                              | Examples                                                                                                                | Upgrade behavior                                                                                                                               |
| --------------------------- | --------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| **Local (consumer)**        | Project policy and product context                                                | Stack rule, `docs/context                                                                                               | plans                                                                                                                                          | specs`, local `AGENTS.md`, secrets, custom ignore overlays | **Never** overwritten without opt-in — `docs/context/PROJECT/INDEX.md` is the one exception, actively scaffolded by the installer |
| **Core (framework SSOT)**   | Vendor-neutral content                                                            | `.ai/rules`, `.ai/skills`, `.ai/prompts`                                                                                | Updated by pulling/tagging `agent-collections`                                                                                                 |
| **Generated (adapters)**    | Tool packaging from core                                                          | `.cursor/rules/eversis-*.mdc`, `.cursor/commands/*.md`, root `CLAUDE.md`, `.claude/rules/*.md`, `.claude/commands/*.md` | Regenerated via `sync:adapters` / installer `--sync` — do not hand-edit as SSOT                                                                |
| **Shared (domain-context)** | Cross-repo domain knowledge, not owned by this consumer or by `agent-collections` | `docs/context/global/` (see [Domain Context (SSOT)](../domain-context))                                                 | Refreshed via `eversis_context_sync` — a `git subtree pull` from a separate `domain-context` GitLab project, distinct from both Local and Core |

Selection file `.agent-collections/install-selection.json` is **consumer install metadata** (read by `--upgrade`; not wiped casually).

## Capability matrix (Cursor vs Claude MVP)

| Capability             | Cursor                                                                     | Claude Code                                                                                                                                |
| ---------------------- | -------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| Core rules packaging   | Generated `.cursor/rules/*.mdc`                                            | Root `CLAUDE.md` (mapped rules) + `.claude/rules/*.md` (glob-scoped rules, `paths:` frontmatter)                                           |
| Skills                 | MCP `eversis-collections` → `.ai/skills` (no full `.cursor/skills` mirror) | **Native** `.claude/skills/eversis-*/` (linked by the installer, no MCP required) — Claude Code has a fuller skills story here than Cursor |
| Prompts                | Stable id / optional `@` attach                                            | Load by id; project notes belong in `.claude/CLAUDE.md`, not `AGENTS.md` (Claude Code does not auto-read it)                               |
| Slash commands         | Thin `.cursor/commands/` from `.ai/prompts` (TASK-598)                     | Thin `.claude/commands/` from `.ai/prompts` — same generator contract, `/eversis-*` after sync                                             |
| Ignore triad           | `.cursorignore`                                                            | `.claudeignore` — class source only; Claude Code enforces via `.claude/settings.json` `permissions.deny` (not `.claudeignore` directly)    |
| Settings / permissions | N/A                                                                        | `.claude/settings.json` — `permissions.deny` generated from `.claudeignore` classes, `enabledMcpjsonServers` from MCP selection            |
| Area profiles          | Path scope via installer profile                                           | Same path profiles (tool-agnostic)                                                                                                         |
| Domain context         | MCP `eversis-collections` → `eversis_context_get`/`list`/`sync`            | Same MCP tools (tool-agnostic — identical mechanism for both)                                                                              |
| OpenCode               | Placeholder only                                                           | —                                                                                                                                          |

Full mapping: [`docs/architecture/adapter-mapping.md`](https://gitlab3.eversis.com/eversis-ai/agent-collections/-/blob/master/docs/architecture/adapter-mapping.md).

## Consumer monorepo overlay (Q7)

Framework area profiles use **abstract** paths (`apps/web/**`, `apps/api/**`). Consumers whose trees differ (for example frontend under `portal/`, backend under `cms/`) map those names in **consumer-owned** ignore overlays and/or `docs/context/` — **do not** commit client folder names into `adapters/profiles/` in the framework repository.

## Rollback

1. Check out the pre-pilot consumer branch (or revert the install commit).
2. Restore previous MCP config and `CURSOR_COLLECTIONS_HOME` if you still need Cursor Collections for that repo.
3. Remove or deinit the `agent-collections` submodule if vendored.
4. Re-run the legacy Cursor Collections installer only if your team still maintains that channel.

Rollback does **not** require deleting the Agent Collections clone on disk.

## Enterprise-oriented upgrade runbook (legacy → Agent Collections)

Typical enterprise cutover from `setup-cursor-local.sh` / `CURSOR_COLLECTIONS_HOME`:

1. Pin `agent-collections` tag; add submodule under `vendor/agent-collections` (or local path for solo trials).
2. Install with `--agents=cursor,claude` and `--profile` matching your work (often `fullstack` + consumer overlay for portal/cms-class trees).
3. Switch MCP skills server env to `AGENT_COLLECTIONS_HOME`.
4. Run isolation collision checklist (other tool packaging indexed? wrong area tree attached?).
5. Measure WNF-03 with the §7.2 proxy (file count or approx tokens) for scoped vs unscoped — target ≥30% reduction or record a justified estimate + improvement plan.
6. Feed findings back into this guide and optional `docs/context/` notes — **without** linking to a Cursor Collections docs portal.

**Pilot snapshot (2026-08-07):** A file-count proxy for a portal/cms-class monorepo layout measured frontend≈portal and backend≈cms proxy reductions **above 30%** vs full monorepo unscoped file count. Live **local** installer + MCP `AGENT_COLLECTIONS_HOME` cutover and consumer **2a** infra overlay were recorded in the pilot's evidence pack; **Q5 dual-agent sessions** start **2026-08-10**; submodule SemVer pin remains a post-Q5 residual.

Pilot measurement templates and evidence are kept locally by the consumer team, not published in this repository.

## Anti-patterns

- Deep-linking Agent Collections docs to a Cursor Collections **docs site** or shared documentation portal.
- Hardcoding client area names into framework `adapters/profiles/*.yaml`.
- Leaving both `CURSOR_COLLECTIONS_HOME` and `AGENT_COLLECTIONS_HOME` wired to different trees for the same MCP skills entry.
- Editing generated `.mdc` / `CLAUDE.md` as if they were SSOT instead of regenerating from `.ai/`.

## Next

- [Installation](../getting-started/installation)
- [MCP setup](../getting-started/mcp-setup)
- [Start here](../getting-started/start-here)
