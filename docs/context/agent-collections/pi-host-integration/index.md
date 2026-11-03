---
scope: project
source: manual
status: approved
last_updated: "2026-11-03"
tags: [pi, adapter, host-integration, context-budget, mcp]
code_paths:
  - adapters/pi/
  - scripts/lib/setup-agent-collections/mcp-merge.mjs
confluence_url: null
related_specs:
  - docs/specs/ac-14-pi-agent-support/
---

# Pi host integration facts (Pi 1.4.0)

Verified against the installed Pi source during AC-14. Re-check on Pi upgrades.

- **Project trust:** `.pi/` (settings, prompts, skills, extensions, mcp.json) loads only after project trust; context files (`AGENTS.md` etc.) load without trust. Non-interactive: `pi --approve` (not accepted by `pi mcp list`).
- **Context files:** one per directory, first match of `AGENTS.override.md` > `AGENTS.md` > `AGENTS.MD` > `CLAUDE.md` > `CLAUDE.MD` (`dist/core/resource-loader.js`).
- **Prompt templates:** Pi substitutes `$<digit>`, `$@`, `$ARGUMENTS`, `${…}` anywhere in the body with no escape — neutralise literal `$` (we use `＄`). Front-matter values containing `": "` must be quoted or the prompt is silently dropped.
- **Skills:** name collisions keep the first discovered and only warn — never emit a skill whose name equals a framework skill.
- **Compaction:** `ctx.compact()` aborts the running turn and never resumes it; an extension must send its own continuation (`pi.sendUserMessage`), and only when the interrupted turn had tool results (never after a final/gate turn). `getContextUsage()` may be `undefined`, and `percent` is `null` right after compaction. There is no `context_info` tool and no `pi-rolling-compaction` package.
- **MCP:** built-in; `${VAR}` expands only in `env`/`headers`, never in `command`/`args` — use a `bash -c` script for path resolution.
- **System prompt:** project `.pi/APPEND_SYSTEM.md` replaces (does not combine with) the user-level one.
