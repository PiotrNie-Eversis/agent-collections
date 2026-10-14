---
sidebar_position: 4
title: Quick Wins
---

# Quick Wins

:::tip From theory to practice
Each scenario maps a real need to prompts and skills. Prefer MCP **`eversis_skills_get`** (or read `.ai/skills/*/SKILL.md`). Both adapters also mirror skills under `.cursor/skills/` and `.claude/skills/` for direct file read — do **not** register `.cursor/skills` as Cursor **Agent Skills** UI. Claude Code can use its native `.claude/skills/` mirror without MCP.
:::

---

## Product / BA — workshop to backlog

**When:** You have a raw transcript and need a Jira-ready backlog.

```text
Load prompt eversis-analyze-materials
(paste transcript or attach materials)
```

| Step | What happens |
|------|----------------|
| Clean transcript | Skill `eversis-transcript-processing` |
| Extract epics/stories | `eversis-task-extracting` |
| Quality passes | `eversis-task-quality-reviewing` |
| Jira format | `eversis-jira-task-formatting` — human gates before create |

**Value:** Structured backlog with review gates instead of days of manual extraction.

---

## Engineering Manager — implement a ticket

**When:** You have a Jira key or task description.

```text
Load / attach eversis-implement
TASK-123
```

| Step | What happens |
|------|----------------|
| Readiness block | Flow / Research / Plan / Next gate |
| Research → plan | Specs under `docs/specs/<issue-kebab>/` with human gates |
| Implement | Delegated by domain; stack policy governs which skills load |
| Fine | QA comment **draft** — publish only after human approval |

**Key skills:** `eversis-orchestrating-implementation`, `eversis-fine-handoff`, domain skills allowed by the project stack rule.

---

## Multi-agent monorepo — scope without noise

**When:** Frontend and backend live in different trees; Cursor and Claude both installed.

1. Install with `--agents=cursor,claude` and a suitable `--profile`.
2. Keep framework abstract paths (`apps/web`, `apps/api`); map local names (`portal`, `cms`, …) in **consumer** overlay / `docs/context/<project>/` (a structured store, not free-form notes — see [Domain Context (SSOT)](../domain-context)) — do not hardcode client names into framework profiles.
3. Confirm ignore triad excludes other tools’ packaging (see [isolation strategy](../isolation)).

**Value:** Each session sees the right shelf, not the whole library (WNF-03).

---

## Domain context — check what the installer already set up

**When:** You just installed the framework and want to confirm domain context (see [Domain Context (SSOT)](../domain-context)) is working before relying on it during Implement.

```text
List domain context components (eversis_context_list)
```

| Step | What happens |
|------|----------------|
| Confirm scaffold | `docs/context/<project>/INDEX.md` exists — created on every install, empty until an agent promotes a finding into it |
| List components | `eversis_context_list` returns any project or global components already present |
| Optional: pull shared knowledge | `eversis_context_sync` refreshes `docs/context/global/` from the team's `domain-context` repo, if one was configured with `--ssot-source` |

**Value:** Confirms the mechanism is live without waiting for the first Fine turn to surface a durable fact.

---

## Migrating from Agent Collections

**When:** You already use `setup-cursor-local.sh` / `CURSOR_COLLECTIONS_HOME`.

Follow **[Migration from Cursor Collections](../advanced/migration-from-cursor-collections)** — cutover, ownership, rollback, capability matrix. Docs channels stay fully separate (no shared docs portal).

---

## Maintainers — refresh adapters

```bash
cd "$AGENT_COLLECTIONS_HOME"
npm run sync:adapters
npm run sync:adapters:check
npm run mcp:test
```

**Value:** Generated Cursor rules and `CLAUDE.md` stay aligned with `.ai/` SSOT.
