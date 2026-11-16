---
sidebar_position: 13
title: "Create custom agent"
slug: create-custom-agent
prompt_role: "Cursor customization orchestrator"
prompt_description: "Create new Cursor role packaging — typically `.ai/rules/` plus optional Cursor adapter `.mdc` packaging and optional agent docs. Researches existing rules, designs the role, and validates against the eversis-creating-agents skill."
---

# eversis-create-custom-agent

**Role:** [Cursor customization orchestrator](../../../website/docs/reference/agents/cursor-customization-orchestrator.md) (workflow pattern)  
**File:** `.ai/prompts/public/eversis-create-custom-agent.md`

Creates **role behavior**: prefer core guidance under **`.ai/rules/`** (neutral Markdown); Cursor adapter may generate **`.cursor/rules/eversis-*.mdc`** (YAML frontmatter, scoped globs) plus optional **documentation** under `website/docs/reference/agents/` in this monorepo. This repository does **not** ship GitHub Copilot `*.agent.md` files.

## Usage

```text
eversis-create-custom-agent
<role requirements or description>
```

In **Cursor**, attach the file above (or open it and reference it with `@`) plus your context.

## What it does

1. **Research** — Review existing **`.ai/rules/`** (and adapter `.mdc` if present) and [AGENTS.md](../../../AGENTS.md) for patterns; optionally read the [Agents overview](../../../website/docs/reference/agents/overview.md).
2. **Clarify** — Scope, responsibilities, which prompts attach this rule, and globs (`alwaysApply` vs `globs`).
3. **Design** — File name (`.ai/rules/<area>/<role>.md`, no `eversis-` prefix), description, section outline, and how the role composes with `eversis-agent-core`.
4. **Create** — Write the rule as neutral Markdown under `.ai/rules/` (and short agent doc if needed) following **`eversis-creating-agents`** (skill path: `.ai/skills/eversis-creating-agents/SKILL.md`).
5. **Register** — Add the rule to `adapters/cursor/rule-map.yaml`, `adapters/claude/rule-map.yaml` and `adapters/pi/rule-map.yaml` with the activation choice per host (always / globs / on demand), then run `npm run sync:adapters` and `npm run sync:adapters:check`.
6. **Review** — Check consistency, length, overlap with other rules, and that the rule appears in every host output.

## Skills loaded

- `eversis-creating-agents` (as **eversis-creating-agents** when copied to user skills) — structure and checklists
- `eversis-technical-context-discovering` — project conventions
- `eversis-codebase-analysing` — pattern discovery

## Output

New or updated **`.ai/rules/`** content and its entries in the three `rule-map.yaml` files (the adapters generate `.mdc` and the other host outputs) (and optional doc under `website/docs/reference/agents/` for this framework).

For large efforts, follow the phased **research → create → review** pattern in [Cursor customization orchestrator](../../../website/docs/reference/agents/cursor-customization-orchestrator.md).

---

## Executable prompt (attach in Cursor)

You are helping the user add a **new role** to their agent setup (core under `.ai/rules/`; Cursor adapter may use `.cursor/rules/`).

1. Load **`eversis-creating-agents`** from `.ai/skills/eversis-creating-agents/SKILL.md` and follow its workflow.
2. Read existing rules in **`.ai/rules/`** (and adapter packaging if present) to match tone, heading and section order.
3. Propose a **single-purpose** rule file `.ai/rules/<area>/<role>.md` (neutral Markdown, no `eversis-` prefix — the adapters add it); avoid duplicating `eversis-agent-core`. Do not hand-write `.cursor/rules/*.mdc`.
4. Register the rule in `adapters/cursor/rule-map.yaml`, `adapters/claude/rule-map.yaml` and `adapters/pi/rule-map.yaml` (same `id` and `source`; activation per host as in the skill's Step 9), then run `npm run sync:adapters` and `npm run sync:adapters:check`. The check fails on a rule file that no map lists (unless it is in `adapters/rules-not-emitted.yaml`); still confirm the rule appears in each host output.
5. After authoring, self-review: activation (`alwaysApply` / `globs`) correct, `description` accurate, no conflicting always-on rules.
6. If the user’s message is incomplete, ask clarifying questions before writing files.

<!-- Eversis port; upstream: eversis-create-custom-agent -->
