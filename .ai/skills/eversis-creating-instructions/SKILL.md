---
name: eversis-creating-instructions
description: "Create project instructions for Agent Collections: AGENTS.md, `.ai/rules/` (adapters may add `.cursor/rules/*.mdc`), optional per-folder RULE.md. No GitHub copilot-instructions.md in this framework."
user-invokable: false
---

# Creating instructions

Helps place **declarative rules** in the right surface for **Agent Collections**: **AGENTS.md**, **`.ai/rules/`** (Cursor adapter may emit **`.cursor/rules/eversis-*.mdc`**), and optional scoped `RULE.md` files. Use **skills** for procedural how-to, not long policies.

## Instruction surfaces (this framework)

| Surface                  | Location                                                                     | When to use                                              |
| ------------------------ | ---------------------------------------------------------------------------- | -------------------------------------------------------- |
| **AGENTS.md**            | Repo root                                                                    | Short map: where prompts live, which rules to read first |
| **Project stack / core** | consumer project-stack rule (project-owned; not `.ai/` SSOT)                                    | Stack, commands, test/lint invocations                   |
| **Always-on core**       | `.ai/rules/orchestration/agent-core.md`                                       | Relay workflow, human gates, quality bar                 |
| **Role rules**           | `.ai/rules/` role files (e.g. `orchestration/engineering-manager.md`); adapters may emit `.mdc`      | When to behave as which role                             |
| **Scoped**               | `globs` in a `.mdc` or a folder `RULE.md` (if your Cursor build supports it) | Directory- or file-type-specific constraints             |

**Deprecated for this repo:** `.github/copilot-instructions.md` and Copilot `*.instructions.md` — do not add them here.

## Instructions vs skills (unchanged idea)

| Content                                                | Belongs in…                                |
| ------------------------------------------------------ | ------------------------------------------ |
| Project rule (“always use pnpm”, “no console in prod”) | `AGENTS.md` / `.mdc`                       |
| Step-by-step workflow (how to run a migration review)  | `SKILL.md` under `.ai/skills/`         |
| Runnable task text                                     | `.ai/prompts/public/eversis-*.md` |

## Process

1. **Discover** — Read `AGENTS.md` and existing `.ai/rules/` (plus any adapter `.mdc` packaging if present).
2. **Choose surface** — Constitution-level → project-owned stack rule + `AGENTS.md` pointers. Narrow scope → domain rule under `.ai/rules/` (adapter may add `globs` in `.mdc`).
3. **Write** — Short bullets; point to skills for long procedures.
4. **Validate** — No duplicate always-on rules; no procedural novel-length content.

Templates (rename concepts, not paths):

- [`assets/cursor-project-constitution.template.md`](./assets/cursor-project-constitution.template.md) — starting outline for “stack + commands + non-obvious rules”
- [`assets/scoped-conventions.template.md`](./assets/scoped-conventions.template.md) — scoped rules when using globs

## Connected skills

- `eversis-creating-agents` — role **rules** (`.ai/rules/`; optional `.mdc` packaging) vs long instructions
- `eversis-creating-skills` — procedural vs declarative boundary
- `eversis-creating-prompts` — prompts should reference rules, not restate the constitution
- `eversis-technical-context-discovering` — where to look first
- `eversis-codebase-analysing` — mirror existing instruction style
