# Claude Code Editor/Terminal Prerequisite — Intent Brief

## Workshop Summary

| Field | Value |
|---|---|
| Workshop Date | Not stated in transcript export (see Open Questions in cleaned transcript) |
| Participants | Piotr Niemirski (maintainer), Katarzyna Bogdanowicz (analyst / hands-on tester) |
| Source Materials | `cleaned-transcript.md` (this workshop); current `website/docs/getting-started/prerequisites.md` and `website/docs/getting-started/installation.md`; prior related research `docs/specs/claude-code-setup-website-docs/claude-code-setup-website-docs.research.md` (checked for overlap — see Baseline Overlap) |
| Prepared By | Claude (eversis-analyze-materials) |

## Goal

Close a real onboarding gap a first-time Claude Code user (Katarzyna) hit: **Prerequisites** and **Installation** currently describe Cursor and Claude Code as if they need the same minimum tooling, but Claude Code additionally needs a standalone code editor and/or terminal to actually be launched and used — Cursor does not. Document this asymmetry clearly enough that a newcomer following the getting-started docs doesn't get stuck the way Katarzyna did.

## In Scope

- `website/docs/getting-started/prerequisites.md` — the "Agent tools" table/section: state explicitly that Claude Code requires a separate code editor and/or terminal to run, while Cursor does not (it is self-contained).
- `website/docs/getting-started/installation.md` — wherever the doc walks a newcomer through first opening/using Claude Code, add the same editor/terminal expectation so the reader isn't surprised mid-install.
- Naming at least one concrete example path (e.g., VS Code, or "any external terminal, including one built into an editor") so the requirement is actionable, not just a vague warning.

## Out of Scope

- The longer-term shared tooling / Confluence-Jira integration vision discussed later in the session (28:11–31:41) — this is an exploratory future direction with no committed scope, owner, or timeline; it is not a documentation defect and does not belong in this docs-focused workshop.
- Any change to the already-resolved `AGENTS.md` → `.claude/CLAUDE.md`, `.claude/commands/`, or native `.claude/skills/` documentation gaps — these were a separate, already-completed audit (`claude-code-setup-website-docs`) and the current doc content confirms they are already fixed. Re-touching them is out of scope here.
- Any content in `website/docs/prompts/**` or `website/docs/skills/**` (flagged as a separate, much larger legacy-docs problem in the prior audit, W11) — not this workshop's concern.

## Key Stakeholders / Actors

- **Newcomer / first-time Claude Code user** (represented by Katarzyna in this session) — needs the prerequisite stated before they hit the gap, not after.
- **Framework maintainer** (Piotr) — owns the getting-started docs and committed in-session to updating them.
- **Cursor users** — unaffected; the fix must not overstate or generalize the requirement to Cursor.

## Candidate Epics

- **Getting-Started Docs: Claude Code Editor/Terminal Prerequisite** — the only epic-sized unit of work identified; small enough that it may end up as a single story rather than a full epic (see quality review / Jira formatting for final sizing).

## Baseline Overlap / Existing Backlog Notes

- Checked `docs/context/agent-collections/task-baseline.md` and the prior `claude-code-setup-website-docs` research/plan (both already implemented, per current doc content) for overlap — **no overlap found**. That prior work fixed unrelated inaccuracies (`AGENTS.md` vs `.claude/CLAUDE.md`, missing `.claude/commands/`, missing native `.claude/skills/` mentions).
- Baseline entry `DHI-649` ("Reader follows one canonical installation checklist regardless of entry page", `docs/specs/docs-ux-ui-analysis/`) is about navigation/structure across entry pages, not the editor/terminal content gap — reviewed, no overlap.
- This is a **new, narrow** documentation gap not previously tracked anywhere in the baseline.

## Open Questions

- ~~Katarzyna's promised session notes have not been provided yet~~ — **Resolved by maintainer**: `workshop-transcription.md` (the file processed into `cleaned-transcript.md`) *is* the complete session material referenced in Action Item 1. No separate notes file is pending; this brief is based on the full available source.
- ~~Should the docs recommend a single default editor, or stay tool-agnostic?~~ — **Resolved by maintainer**: requirements must be **distinguished per vendor/tool** wherever relevant (e.g., Cursor: none; Claude Code: editor/terminal required; future editors: documented individually as they're added) rather than picking one single recommended editor. Naming VS Code as *an* example remains fine, but the framing must stay per-vendor, not "the" recommended default.

## Gate 0 Approval

| Decision | Notes |
|---|---|
| **Approved** | Maintainer resolved both open questions directly (2026-09-18): confirmed the provided transcript is the complete source material (no pending follow-up notes), and confirmed the doc fix must distinguish requirements per vendor/tool. Proceeding to extraction. |
