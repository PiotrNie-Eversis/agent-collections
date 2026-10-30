# ac-36-prerequisites-clarity — Research

**Jira:** [AC-36](https://eversis.atlassian.net/browse/AC-36) (Epic — Non-technical reader clarity)  
**Child tasks:** AC-47, AC-48, AC-49, AC-46  
**Workshop source:** `docs/specs/ac-35-prerequisites-post-review/` (Gate 1–2 approved 2026-10-13)

## Problem

After AC-35, the Prerequisites page still leaves QA/BA/PO readers surprised by CLI-only Claude Code, Node.js on the Claude Code path, missing LLM account guidance, and no pointer to open Terminal/PowerShell before verification commands.

### Delta (2026-10-13) — VS Code for Claude Code path

Post-implement feedback: for QA who choose **Claude Code**, a **VS Code** install is often needed so work happens in a desktop editor with the Claude Code extension, not only in Terminal/PowerShell. Cursor-only path stays unchanged (VS Code not required). Clarify that the existing footer about VS Code `chat.*Locations` refers to legacy Copilot setup, not this Claude Code host path.

## Scope (this epic only)

| Story | Jira (expected) | Primary file |
| --- | --- | --- |
| GUI vs CLI + Cursor-first | AC-47 | `website/docs/getting-started/prerequisites.mdx` |
| Node.js vs Claude Code vs Cursor-only | AC-48 | `prerequisites.mdx`, `start-here.md` |
| AI accounts | AC-49 | `prerequisites.mdx` |
| Open terminal before verification | AC-46 | `prerequisites.mdx` |
| VS Code optional host for Claude Code (QA) | AC-47 delta | `prerequisites.mdx`, `start-here.md` |

**Out of scope:** AC-37 (Docker enterprise), AC-38 (TOC/troubleshooting) — separate epics.

## Affected paths

- `website/docs/getting-started/prerequisites.mdx` (SSOT page; `.md` removed)
- `website/docs/getting-started/start-here.md` (checklist step 1 alignment)

## Root cause

Copy optimized for developers; matrix treated Claude Code like a desktop app; Node `:::info` did not tie npm/quickstart Claude Code to Node LTS; verification assumed terminal literacy.

## Constraints

- Plain language, full sentences (AC-35 doc standard).
- No new npm dependencies; `npm run website:build` must pass.
- Vendor links stay official (Cursor, Anthropic, nodejs.org).

## Open questions

None blocking implementation (resolved in `intent-brief.md` 2026-10-13). VS Code delta confirmed by human 2026-10-13.

## Changelog

| Date | Author | Change |
| --- | --- | --- |
| 2026-10-13 | eversis-implement | CREATE from ac-35 workshop artifacts |
| 2026-10-13 | eversis-implement | DELTA — VS Code optional/recommended for Claude Code QA path |
| 2026-10-13 | eversis-implement | DELTA — link official Claude Code VS Code extension docs (`code.claude.com/docs/en/vs-code`) |
