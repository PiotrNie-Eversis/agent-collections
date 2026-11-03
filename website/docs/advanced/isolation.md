---
sidebar_position: 3
title: Isolation and context reduction
slug: /isolation
---

# Isolation and context reduction

Agent Collections isolates AI context across **tools** and **areas** so sessions stay focused and token use stays bounded (WNF-03).

Canonical detail: [`docs/architecture/isolation-strategy.md`](https://gitlab3.eversis.com/eversis-ai/agent-collections/-/blob/master/docs/architecture/isolation-strategy.md) in the repository.

## Two axes

| Axis                     | Meaning                                                                                                                               |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------- |
| **Cross-tool packaging** | Each installed tool indexes its own packaging and excludes others (ignore triad: `.cursorignore`, `.claudeignore`, `.opencodeignore`) |
| **Area / path scoping**  | Profiles narrow to frontend-scope / backend-scope / fullstack via path globs — **independent** of which tool you chose                |

**Invariant:** Do not hard-code “Frontend must use Cursor” or “Backend must use Claude”. Area profiles control **paths**; the installer / user controls **tools**.

## Abstract layout

Framework docs and profiles use open-source names only:

| Class        | Abstract paths                                  |
| ------------ | ----------------------------------------------- |
| Frontend     | `apps/web/**`                                   |
| Backend      | `apps/api/**`                                   |
| Shared libs  | `packages/**` (narrow)                          |
| Light shared | `docs/**`, `scripts/**`                         |
| Heavy infra  | charts, large vendor dumps, … — default exclude |

Consumers whose folders differ (for example a portal tree and a CMS/API tree) map those names in **consumer-owned** overlays / `docs/context/` — do **not** commit client names into framework `adapters/profiles/`. `docs/context/` itself has a defined shape, not free-form notes: `docs/context/<project>/INDEX.md` (always scaffolded on install) plus one file per component, and an optional `docs/context/global/` synced from a shared `domain-context` repo — see [Domain Context (SSOT)](./domain-context).

## WNF-03 (context reduction)

Target: **≥30%** less material vs an unscoped baseline, measured with the §7.2 proxy (file count, tree size, or approximate token weight of text files).

1. Define unscoped set \(U\) (apps + packages + docs + scripts + infra typically visible; exclude secrets/build/`node_modules`).
2. Define scoped set \(S\) (area profile + light shared + own-tool packaging − other-tool packaging − heavy infra).
3. Reduction ≈ \(1 - |S|/|U|\). Document the proxy used.
4. If below 30%, record a **justified estimate** and a plan to tighten profiles / ignores.

Empirical pilot notes live under `docs/context/<project>/` when present.

## Multi-agent MVP

| Tool        | Packaging                                                  | Skills                                                |
| ----------- | ---------------------------------------------------------- | ----------------------------------------------------- |
| Cursor      | `.cursor/rules/*.mdc`, `.cursor/commands/*.md`             | MCP → `.ai/skills`                                    |
| Claude Code | `CLAUDE.md`, `.claude/rules/*.md`, `.claude/commands/*.md` | Native `.claude/skills/` (linked by installer) or MCP |
| OpenCode    | Placeholder config                                         | Deferred                                              |

See also [adapter mapping](https://gitlab3.eversis.com/eversis-ai/agent-collections/-/blob/master/docs/architecture/adapter-mapping.md) and [Migration](./advanced/migration-from-cursor-collections).
