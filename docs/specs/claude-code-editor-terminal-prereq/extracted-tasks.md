# Claude Code Editor/Terminal Prerequisite - Extracted Tasks

## Workshop Summary

| Field | Value |
|---|---|
| Workshop Date | Not stated in source transcript |
| Participants | Piotr Niemirski, Katarzyna Bogdanowicz |
| Source Materials | `cleaned-transcript.md` (full source: `workshop-transcription.md`); current `website/docs/getting-started/prerequisites.md` and `website/docs/getting-started/installation.md` |
| Intent Brief | `intent-brief.md` — Gate 0 Approved |
| Project Baseline Used | `docs/context/agent-collections/task-baseline.md` — checked, no overlapping entry |
| Total Epics | 1 |
| Total Stories | 2 |

## Epics Overview

| # | Epic Title | Stories Count | Priority |
|---|-----------|---------------|----------|
| 1 | Getting-Started Docs: Claude Code Editor/Terminal Prerequisite | 2 | Medium |

## Epic 1: Getting-Started Docs: Claude Code Editor/Terminal Prerequisite

**Business Description**: Prerequisites and Installation currently document Cursor and Claude Code as if they need the same minimum tooling. In practice, Cursor is self-contained while Claude Code additionally requires a standalone code editor and/or terminal to be launched and used at all — a gap a real first-time user (Katarzyna) hit while onboarding. This epic makes the getting-started docs state tooling requirements **per agent tool/vendor**, so a newcomer picks up the right expectation before they get stuck.

**Success Criteria**:
- A newcomer reading Prerequisites can tell, per tool, whether an extra editor/terminal is needed — without having to discover it by trial and error.
- Installation's Claude Code path does not leave a reader stuck without an editor/terminal open at the point they'd first try to use it.
- Wording between the two documents is consistent (no contradiction).

### Story 1.1: State the per-vendor editor/terminal requirement in Prerequisites

**User Story**: As a first-time Claude Code user reading the Prerequisites page, I want to see clearly that Claude Code requires a separate code editor and/or terminal (while Cursor does not), so that I don't get stuck trying to launch Claude Code without one.

**Source**: `cleaned-transcript.md` → "Getting started: Cursor vs. Claude Code" discussion topic; Preserved Context quotes at 0:28–0:54 ("this is the missing step... you actually pointed out. It's missing here" / "In Cursor's case this isn't a problem; in Claude Code's case we need some kind of code editor, or alternatively a terminal — it could be Visual Studio Code, it could be some external terminal, even one built in").

**Acceptance Criteria**:
- [ ] GIVEN the "Agent tools" table/section in `prerequisites.md` WHEN a reader compares Cursor and Claude Code THEN the doc explicitly states Cursor is self-contained and Claude Code additionally requires a standalone code editor and/or terminal to run.
- [ ] GIVEN a reader who has never used Claude Code WHEN they read the requirement THEN at least one concrete example is given (e.g., VS Code, or any external terminal — including one built into an editor).
- [ ] GIVEN the OpenCode row (currently "Placeholder only — not a full shipped adapter") WHEN the editor/terminal requirement is documented THEN OpenCode is not asserted to share the same requirement — the note stays scoped to tools that are actually shipped adapters today (Cursor, Claude Code).

**High-Level Technical Notes**: None — workshop discussion was about onboarding UX/documentation only, not implementation.

**Priority**: Medium

### Story 1.2: Carry the same requirement through the Installation walkthrough

**User Story**: As a first-time Claude Code user following the Installation page, I want to be told, at or before the point I'd first open/launch Claude Code, that I need a separate code editor and/or terminal, so that I don't hit a dead end mid-install.

**Source**: `cleaned-transcript.md` → same discussion topic and Preserved Context as Story 1.1; cross-referenced against current `installation.md` content, which does not mention this requirement anywhere in the Claude Code path.

**Acceptance Criteria**:
- [ ] GIVEN the Claude Code path through `installation.md` WHEN a reader reaches the point where they would first open/launch Claude Code THEN the doc states they need a separate code editor and/or terminal, distinguished from the Cursor path (which needs neither).
- [ ] GIVEN the existing per-tool comparison content in `installation.md` (e.g., "Customising stack (Cursor vs Claude)") WHEN a reader compares the two tools THEN the editor/terminal wording is consistent with `prerequisites.md` — no contradicting phrasing between the two docs.

**High-Level Technical Notes**: None.

**Priority**: Medium

## Dependencies

| Task | Depends On | Type | Notes |
|------|-----------|------|-------|
| Story 1.2 | Story 1.1 | Related to | Both state the same requirement; wording should be written consistently, but neither blocks the other — they can be implemented in either order or together. |

## Assumptions

| # | Assumption | Confidence | Impact if Wrong |
|---|-----------|------------|-----------------|
| 1 | "Distinguish by every vendor" (maintainer's Gate 0 answer) refers to the existing "Agent tools" table structure in `prerequisites.md` (Cursor / Claude Code / OpenCode rows), not a separate new taxonomy. | High | If wrong, the acceptance criteria would need to target a different section/structure than the existing tools table. |
| 2 | Naming VS Code as one example editor is acceptable and does not imply it as the single mandated/recommended tool (per maintainer's answer to keep it per-vendor, not a single default). | High | If wrong, the story would need to drop the specific example and stay fully generic ("a code editor of your choice"). |

## Out of Scope

Items explicitly excluded from this task breakdown:
- The longer-term shared tooling / Confluence–Jira integration vision discussed later in the same session (28:11–31:41) — exploratory, no committed scope/owner/timeline.
- Already-resolved `AGENTS.md` → `.claude/CLAUDE.md`, `.claude/commands/`, and native `.claude/skills/` documentation gaps — separate, already-completed audit (`claude-code-setup-website-docs`); current doc content confirms these are already fixed.
- `website/docs/prompts/**` and `website/docs/skills/**` — flagged in a prior audit (W11) as a separate, much larger legacy-docs problem; not this workshop's concern.

## Open Questions for Stakeholders

None remaining — both open items from `intent-brief.md` were resolved directly by the maintainer during Gate 0.
