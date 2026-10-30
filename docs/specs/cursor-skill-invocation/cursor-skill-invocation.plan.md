# cursor-skill-invocation - Implementation Plan

## Task Details

| Field            | Value                                                                 |
| ---------------- | --------------------------------------------------------------------- |
| Jira ID          | none                                                                  |
| Title            | Framework checkout skills mirror for Cursor and Claude                |
| Description      | Commit a `.cursor/skills/` and `.claude/skills/` symlink mirror of `.ai/skills/eversis-*` in this repository so `eversis-add-domain-knowledge` is visible when working in the framework checkout. |
| Priority         | Medium                                                                |
| Related Research | `docs/specs/cursor-skill-invocation/cursor-skill-invocation.research.md` |

## Wildly Important Goal

**Goal**: A clone of this repository lists `eversis-add-domain-knowledge` from the Cursor and Claude project skill directories, the same way EOG does after `vendor/agent-collections` is checked out.

**Success Measure**: Every `.ai/skills/eversis-*/SKILL.md` has a relative symlink under both `.cursor/skills/` and `.claude/skills/`, `npm run sync:adapters:check` fails when that set drifts, and `eversis-add-domain-knowledge/SKILL.md` resolves through both links.

**Do NOT touch / do NOT add**: Command shims for skills, `user-invocable` or `disable-model-invocation` edits, consumer installer link targets, EOG or other consumer checkouts, AC-35 prerequisites, Confluence install wording.

## Proposed Solution

Commit relative symlinks in this repository:

```text
.cursor/skills/<name> -> ../../.ai/skills/<name>
.claude/skills/<name> -> ../../.ai/skills/<name>
```

`<name>` is each directory `.ai/skills/eversis-*`. The link target is the existing skill package. Skill bodies stay in `.ai/skills/`.

`adapters/sync.mjs` refreshes that mirror only when it writes the framework root (the default run, and `--check` against that root). A run with `--out` pointing at a consumer directory does not create these links there. Consumer projects already get their mirror from `scripts/lib/setup-agent-collections/link-framework.sh`, aimed at the vendored tree.

`npm run sync:adapters:check` fails when a skill directory has no symlink, when a symlink points somewhere else, or when a leftover `eversis-*` entry has no matching `.ai/skills/` directory.

Update the sentences that say this repository does not ship `.cursor/skills/`. Leave consumer install steps as they are.

```text
.ai/skills/eversis-add-domain-knowledge/SKILL.md
        ^
        | relative symlink
        |
.cursor/skills/eversis-add-domain-knowledge
.claude/skills/eversis-add-domain-knowledge
```

## Current Implementation Analysis

### Already Implemented

- Skill SSOT — `.ai/skills/eversis-add-domain-knowledge/SKILL.md` — `user-invocable: true`; reuse unchanged
- Consumer mirror — `scripts/lib/setup-agent-collections/link-framework.sh` (`_link_cursor_skills`, `_link_claude_skills`) — links every `eversis-*` package into the consumer; do not retarget
- Adapter sync — `adapters/sync.mjs` — already regenerates rules and command shims and supports `--check`
- Installer smoke — `scripts/setup-agent-collections.test.sh` — already asserts a consumer `.cursor/skills/` copy matches SSOT

### To Be Modified

- `adapters/sync.mjs` — refresh and check the framework-root skills symlinks
- `AGENTS.md` — Channel notes currently say the `.cursor/skills` mirror is not shipped
- `adapters/cursor/README.md` — exceptions table lists `.cursor/skills/` as outside Cursor emit

### To Be Created

- `.cursor/skills/eversis-*` — one relative symlink per skill package
- `.claude/skills/eversis-*` — one relative symlink per skill package

### To Be Removed

- None. Stale `eversis-*` symlinks are removed only when the matching `.ai/skills/` directory is gone.

## Open Questions

| #   | Question | Answer | Status |
| --- | -------- | ------ | ------ |
| 1   | Mirror this framework checkout? | Yes. Both `.cursor/skills/` and `.claude/skills/`. | ✅ Resolved |
| 2   | Emit slash-command shims for skills? | No. EOG shows the skill from the skills directory with no command file. | ✅ Resolved |

## Technical Context

Project conventions, coding standards, and patterns discovered during planning. Downstream agents MUST read this section instead of re-discovering the same context.

### Project Instructions

- `.cursor/rules/eversis-project-stack.mdc` — after this change run `npm run sync:adapters` and `npm run sync:adapters:check` from the repo root
- `AGENTS.md` — `.ai/` remains the skill SSOT

### Architecture & Patterns

- Skill packages live under `.ai/skills/eversis-<name>/SKILL.md`
- Cursor and Claude discover project skills from `.cursor/skills/<name>/SKILL.md` and `.claude/skills/<name>/SKILL.md`
- From `.cursor/skills/<name>` or `.claude/skills/<name>`, the relative target `../../.ai/skills/<name>` stays inside this repository
- Consumer `--out` sync must not write that relative target into a project whose `.ai/skills/` is absent. The installer owns the consumer mirror

### Tech Stack

- Node.js stdlib for `adapters/sync.mjs` (no new dependencies)
- Git stores the symlinks; do not copy `SKILL.md` into the mirror

### Code Style & Standards

- Match existing `adapters/sync.mjs` style: zero npm dependencies, fail with a clear message in `--check`
- Symlink names match the skill directory names exactly

### Testing Patterns

- `npm run sync:adapters` then `npm run sync:adapters:check` from the repo root
- Confirm `eversis-add-domain-knowledge/SKILL.md` is readable through both symlinks (`test -f` on the link path)
- Do not require `npm run installer:smoke` unless `link-framework.sh` changes. This plan does not change it

### Database Patterns

- N/A

### Additional Context

- EOG pin `f5a146c` already contains this skill. Visibility there started when `vendor/agent-collections` was checked out. This plan does not bump consumer pins
- There are 50 skill packages. The mirror includes all of them, matching the installer, including packages with `user-invocable: false`

## Implementation Plan

### Phase 1: Framework-root skills symlinks

**Goal**: This checkout exposes every skill package to Cursor and Claude.

**Description**: Add a framework-root-only refresh in `adapters/sync.mjs` and generate the symlink set.

**Verification:** `npm run sync:adapters:check`

#### Task 1.1 - [MODIFY] Refresh the mirror from sync

**Description**: When sync runs for the framework root, create or replace `.cursor/skills/<name>` and `.claude/skills/<name>` as relative symlinks to `../../.ai/skills/<name>` for every `.ai/skills/eversis-*` directory. Remove `eversis-*` entries that no longer exist under `.ai/skills/`. Skip this step when `--out` is a different directory.

**Files:** `adapters/sync.mjs` (modify)

**Definition of Done**:

- [x] Default `node adapters/sync.mjs` writes both mirrors in the repo root
- [x] `node adapters/sync.mjs --out <other-dir>` does not create `.cursor/skills` or `.claude/skills` in that other directory
- [x] Each link is relative and resolves to that skill's `SKILL.md`

**Clues**: Installer prune loop in `_link_cursor_skills` / `_link_claude_skills` is the consumer equivalent. Do not call it against this repo with `COLLECTIONS_HOME` equal to a vendor path.

#### Task 1.2 - [CREATE] Commit the symlink set

**Description**: Run the refresh and leave the symlinks in the worktree so a clone contains them. Include `eversis-add-domain-knowledge`.

**Files:** `.cursor/skills/eversis-*` (create), `.claude/skills/eversis-*` (create)

**Definition of Done**:

- [x] `.cursor/skills/eversis-add-domain-knowledge/SKILL.md` and `.claude/skills/eversis-add-domain-knowledge/SKILL.md` are readable
- [x] The number of `eversis-*` entries in each mirror equals the number of `.ai/skills/eversis-*` directories

### Phase 2: Drift check

**Goal**: A new or removed skill cannot leave the mirror stale.

**Description**: `--check` compares the on-disk symlink set with `.ai/skills/eversis-*` and exits non-zero on mismatch.

**Verification:** `npm run sync:adapters:check`

#### Task 2.1 - [MODIFY] Fail sync check on skills-mirror drift

**Description**: Extend `adapters/sync.mjs --check` so a missing symlink, a wrong target, or an orphan `eversis-*` entry fails the check. A clean tree exits 0.

**Files:** `adapters/sync.mjs` (modify)

**Definition of Done**:

- [x] `npm run sync:adapters:check` exits 0 on the generated tree
- [x] The check reports the skill name when a link is missing or points at the wrong path

### Phase 3: Docs that deny the mirror

**Goal**: Repository entry points describe the framework-root mirror.

**Description**: Replace the claims that this repository does not ship `.cursor/skills/`. Do not rewrite the consumer install guide.

**Verification:** `npm run sync:adapters:check`

#### Task 3.1 - [MODIFY] AGENTS.md and Cursor adapter README

**Description**: State that this repository commits `.cursor/skills/` and `.claude/skills/` as relative symlinks to `.ai/skills/`, refreshed by `npm run sync:adapters`. Keep the statement that command shims still come from `.ai/prompts/`.

**Files:** `AGENTS.md` (modify), `adapters/cursor/README.md` (modify)

**Definition of Done**:

- [x] Neither file says this repository ships no `.cursor/skills/` mirror
- [x] `npm run sync:adapters:check` exits 0

### Phase 4: Code review

**Goal**: Confirm the mirror matches SSOT before Fine.

**Description**: Review the symlink set, the `--out` exclusion, and the doc sentences.

**Verification:** `npm run sync:adapters:check`

#### Task 4.1 - [REUSE] Code review

**Description**: Run Code Reviewer via `eversis-review` on the sync change, the symlink set, and the two doc edits.

**Files:** `adapters/sync.mjs` (reuse), `.cursor/skills/` (reuse), `.claude/skills/` (reuse), `AGENTS.md` (reuse), `adapters/cursor/README.md` (reuse)

**Definition of Done**:

- [x] `npm run sync:adapters:check` exits 0
- [x] Review has no blocking findings

## Security Considerations

- Symlinks must stay relative and must not point outside this repository (`../../.ai/skills/<name>` only).
- `--out` to another project must not publish this repository's `.ai/skills` path into that project.

## Quality Assurance

- [x] GIVEN this framework checkout WHEN Cursor or Claude reads project skills THEN `eversis-add-domain-knowledge/SKILL.md` resolves from both `.cursor/skills/` and `.claude/skills/`.
- [x] GIVEN every `.ai/skills/eversis-*` directory WHEN the mirror is generated THEN both skill directories contain a symlink of the same name.
- [x] GIVEN a skill directory added or removed WHEN `npm run sync:adapters:check` runs before the mirror is refreshed THEN the check exits non-zero.
- [x] GIVEN `node adapters/sync.mjs --out <other-dir>` WHEN that directory is not the framework root THEN it gains no `.cursor/skills` or `.claude/skills` entries from this step.

## Improvements (Out of Scope)

- Slash-command files for skills
- Frontmatter edits (`user-invocable`, `disable-model-invocation`)
- Changing `link-framework.sh` consumer targets
- Checking out or bumping `vendor/agent-collections` in EOG or other products
- Installation page rewrite

## Human gates

1. ~~Approve research~~ — done, including the framework-root mirror
2. ~~Approve this plan~~ — done
3. ~~Implement → Review → Fine~~ — done

## Changelog

| Date       | Change Description |
| ---------- | ------------------ |
| 2026-10-13 | Initial plan. Framework-root relative symlinks for `.cursor/skills/` and `.claude/skills/`. Command shims withdrawn. |
| 2026-10-13 | Implemented: sync refresh + check, 50/50 mirrors, AGENTS.md + Cursor README. Review PASS. |
