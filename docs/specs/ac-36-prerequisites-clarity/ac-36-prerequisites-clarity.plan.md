# ac-36-prerequisites-clarity — Plan

**Epic:** AC-36 — Prerequisites: Non-technical reader clarity

## Phases

### Phase 1 — Prerequisites copy (AC-47, AC-48, AC-49, AC-46)

1. Update quick requirements table: GUI vs CLI labels; account expectations in quick requirements area.
2. Strengthen role tip: recommend **Cursor first** for readers uncomfortable with the terminal.
3. Expand Node.js optional block and Claude Code tab notes: Cursor-only skips Node; Claude Code npm/quickstart **may** require Node LTS.
4. Add **Open a terminal** subsection immediately before verification command table (macOS Terminal, Windows PowerShell).
5. Align `start-here.md` checklist step 1 with Node/Claude messaging.

### Phase 1b — Delta: VS Code for Claude Code (AC-47)

6. Add **VS Code** to quick requirements as optional for Cursor-only, **recommended for QA on the Claude Code path** (desktop host + Claude Code extension; CLI still required).
7. Mention VS Code install in Claude Code OS tab steps; clarify footer that legacy `chat.*Locations` is unrelated.
8. Align `start-here.md` step 1 with the VS Code note.

### Phase 2 — Verify

- `npm run website:build`

## Acceptance criteria (epic)

- [x] Cursor labeled GUI; Claude Code labeled CLI in quick requirements.
- [x] Page recommends starting with Cursor for non-terminal readers.
- [x] Cursor-only path states Node.js not required; Claude Code path states Node LTS may be required.
- [x] MCP developer Node requirement unchanged.
- [x] Start here step 1 matches Prerequisites Node/Claude messaging. *(Later superseded by AC-56 onboarding map — detail stays on Prerequisites.)*
- [x] Quick requirements mention Cursor and Anthropic account needs; advise Tech Lead/IT for org seats.
- [x] Check your setup preceded by macOS Terminal and Windows PowerShell open instructions.
- [x] `npm run website:build` passes.
- [x] Claude Code path documents **VS Code** as a recommended desktop host for QA (extension + CLI); Cursor-only path does not require VS Code.
- [x] Start here step 1 mentions VS Code only in the Claude Code context. *(Later superseded by AC-56 — Start here no longer repeats the VS Code essay.)*

## Definition of done

- [x] Phase 1 complete
- [x] Phase 2 complete
- [x] Code review PASS

## Changelog

| Date | Author | Change |
| --- | --- | --- |
| 2026-10-13 | eversis-implement | CREATE |
| 2026-10-13 | eversis-review | Code review PASS; AC checked |
| 2026-10-13 | eversis-implement | REFRESH Phase 1b — VS Code delta for Claude Code QA path; implemented |
| 2026-10-13 | eversis-implement | Point VS Code steps to https://code.claude.com/docs/en/vs-code |
| 2026-10-14 | eversis-implement | Jira close: AC-46–49 + AC-36 Done; Start here ACs noted superseded by AC-56 |

## Code Review Findings

**Verdict: PASS** (2026-10-13)

| Severity | Finding |
| --- | --- |
| — | No blockers. Copy meets epic AC; build verified. |

**Suggestions:** None required for AC-36 scope. Docker enterprise callout and TOC/troubleshooting remain AC-37/AC-38.
