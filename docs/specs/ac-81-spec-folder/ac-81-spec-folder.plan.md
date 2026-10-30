# AC-81 spec folder - Implementation Plan

## Task Details

| Field            | Value                   |
| ---------------- | ----------------------- |
| Jira ID          | AC-81 |
| Title            | Ujednolicić nazwę katalogu spec do klucz-temat |
| Description      | Make every instruction that creates a ticket's research, plan, or plan review name the folder `docs/specs/<key>-<topic>/` and repeat that folder name in the file names. |
| Priority         | Medium |
| Related Research | `docs/specs/ac-81-spec-folder/ac-81-spec-folder.research.md` |

## Wildly Important Goal

**Goal**: An agent creating the first spec artifact for a ticket follows `docs/specs/<key>-<topic>/` and names the research, plan, and plan-review files with that same folder name.

**Success Measure**: No prompt or skill that creates those artifacts still tells the agent to use a key-only folder or a `<task-name>` folder, the listed human docs and templates use `<key>-<topic>`, workshop paths are unchanged, and generated prompt copies match the edited sources.

**Do NOT touch / do NOT add**:

- Spec-folder lookup, including the rule that an existing `docs/specs/<key>/` is kept
- Workshop paths `docs/specs/<workshop-name>/`, `docs/specs/<workshop-topic>/`, and `docs/specs/<project-or-topic>/`
- `plan.example.md` title placeholders that say `<task-name>` and are not folder paths
- `.ai/prompts/public/eversis-repo-docs-writer.md`
- Existing spec folders in this repo or in consumer projects
- Hand edits under `website/docs/reference/prompts/`, `.cursor/commands/`, or `.claude/commands/`

## Proposed Solution

Use one wording contract, copied from `.ai/rules/orchestration/spec-driven-development.md`, everywhere this task edits a ticket-spec path:

- Folder: `docs/specs/<key>-<topic>/`. The topic is at most three hyphen-separated words.
- Files: `<key>-<topic>.research.md`, `<key>-<topic>.plan.md`, `<key>-<topic>.plan-review.md`.
- Example to paste where a sample tree is shown: `docs/specs/ac-2-context-management/` with `ac-2-context-management.research.md`, `ac-2-context-management.plan.md`, and `ac-2-context-management.plan-review.md`.
- Where a sentence also offers `specifications/` as the team's folder, use `specifications/<key>-<topic>/` with the same file names. Do not leave `<task-name>` on that alternate root.

Edit the source files in `.ai/`, the human docs, the templates, this repo's stack rule, the installer heredocs, and `CHANGELOG.md`. Then regenerate prompt copies and command shims. Do not hand-edit generated trees.

One Software Engineer pass owns every wording edit so the token stays identical. Load `eversis-writing-repo-documentation` for the README, CHANGELOG, `docs/`, and `website/docs` pages. Route that pass through `eversis-implement-common-task`. Do not route the path renames through `eversis-engineer-prompt`; these are existing instruction files, not a new application prompt.

```text
.ai prompts and skills  -->  human docs, templates, installer, CHANGELOG
        |                                      |
        v                                      v
npm run sync:adapters          npm run website:changelog:sync
npm run sync:website-docs      npm run website:changelog:check
        |
        v
generated prompt pages and command shims match the sources
```

## Current Implementation Analysis

### Already Implemented

- Canonical convention — `.ai/rules/orchestration/spec-driven-development.md` — `docs/specs/<key>-<topic>/` and file names that repeat the folder name
- Human copy of that convention — `docs/specs/README.md`
- Lookup that keeps an existing key-only folder — `.ai/skills/eversis-orchestrating-implementation/SKILL.md`
- Research prompt — `.ai/prompts/internal/eversis-research.md` — already tells the agent to create `<key>-<topic>`
- Prompt and command generators — `adapters/sync.mjs`, `adapters/website/generate-prompts.mjs`, `adapters/cursor/generate.mjs`, `adapters/claude/generate-commands.mjs`

### To Be Modified

- Plan prompt — `.ai/prompts/internal/eversis-plan.md` — replace `docs/specs/<task-name>/`, the `user-authentication/` sample tree, and the executable line that names the folder after the issue id or a shortened task name
- Plan-review prompt — `.ai/prompts/internal/eversis-review-plan.md` — replace `docs/specs/<task-name>/` and `{task-name}.plan-review.md` when that name is the artifact file
- Implement prompt — `.ai/prompts/public/eversis-implement.md` — replace only the artifacts bullet that says `docs/specs/<task-name>/`. Leave every lookup paragraph as it is
- Architecture-designing skill — `.ai/skills/eversis-architecture-designing/SKILL.md` — replace both `docs/specs/<task-name>/` and `docs/specs/<task>/`
- Creating-implementation-plans skill — `.ai/skills/eversis-creating-implementation-plans/SKILL.md` — replace `docs/specs/{task-name-or-id}/{task-name}.plan.md`
- Plan-review example — `.ai/skills/eversis-creating-implementation-plans/plan-review.example.md` — replace the two `docs/specs/<task-name>/<task-name>.*` path lines. Leave the H1 `<task-name>` title placeholder
- Promote-domain-knowledge skill — `.ai/skills/eversis-promote-domain-knowledge/SKILL.md` — replace `docs/specs/<task-kebab>/` in the `related_specs` example and the append instruction
- Framework entry and templates — `AGENTS.md`, `README.md`, `templates/AGENTS.template.md`, `templates/eversis-project-stack.example.mdc`, `.cursor/rules/eversis-project-stack.mdc` — replace `<issue-kebab>` used as the spec folder or as the research/plan file name
- Architecture and plans docs — `docs/architecture/agents-md-standard.md`, `docs/plans/README.md` — replace `<issue-kebab>` and the Implement-workflow `docs/specs/<issue>/` cell
- Website pages edited by hand — `website/docs/getting-started/quick-wins.md`, `website/docs/main-flow/workflow/standard-flow.md`, `website/docs/main-flow/team-guides/project-manager.md`, `website/docs/reference/agents/plan-reviewer.md`
- Installer heredocs — `scripts/lib/setup-agent-collections/scaffolding.sh` — three `<issue-kebab>` sentences and the `my-feature` example
- Changelog — `CHANGELOG.md` — one Unreleased Fixed bullet. Not a breaking change. No Migration subsection

### To Be Created

- None. Generated prompt pages and command shims are rewritten by the existing sync commands.

## Open Questions

| #   | Question   | Answer   | Status                |
| --- | ---------- | -------- | --------------------- |
| 1   | Should `scripts/lib/setup-agent-collections/scaffolding.sh` change in this task? | Yes. Include the three heredoc sentences and replace `my-feature` with `ac-2-context-management`. Do not rewrite existing consumer folders. Closing phrase: `Selected option(s) approve-include`. | ✅ Resolved |
| 2   | Which placeholder should English files use? | `docs/specs/<key>-<topic>/`. File names repeat the folder name. Do not insert `<klucz>-<temat>`. | ✅ Resolved |

## Technical Context

Project conventions, coding standards, and patterns discovered during planning. Downstream agents MUST read this section instead of re-discovering the same context.

### Project Instructions

- `AGENTS.md` — framework SSOT is `.ai/`; specs live under `docs/specs/`; quality commands are listed in Project specifics
- `.cursor/rules/eversis-project-stack.mdc` — this repo's stack policy. Quality commands below. Do not load `eversis-implementing-frontend`, `eversis-implementing-backend`, or BA Docs skills
- `.ai/rules/orchestration/spec-driven-development.md` — source of the folder sentence to copy. Do not edit it in this task
- `.ai/skills/eversis-orchestrating-implementation/SKILL.md` — lookup. Do not edit it in this task
- `.ai/skills/eversis-writing-repo-documentation/SKILL.md` — load for README, CHANGELOG, `docs/`, and `website/docs` edits. Edit root `CHANGELOG.md` only. Regenerate the site page with `npm run website:changelog:sync`, then run `npm run website:changelog:check`. Do not hand-edit `website/src/pages/changelog.md`

### Architecture & Patterns

- Agent-facing instructions live in `.ai/prompts/` and `.ai/skills/`. Adapters generate `.cursor/commands/`, `.claude/commands/`, and `website/docs/reference/prompts/` from the prompts. Generated files carry a "GENERATED" or "do not edit" notice. Edit the source, then sync
- `.cursor/rules/eversis-project-stack.mdc` is maintained for this repository. It is not produced from `templates/eversis-project-stack.example.mdc` by the adapter sync. Change both so they match
- `scripts/lib/setup-agent-collections/scaffolding.sh` writes consumer `docs/specs/README.md` and `docs/plans/README.md` only when the file is absent. It does not overwrite an existing file. The AGENTS.md heredoc runs only when `templates/AGENTS.template.md` is missing
- `docs/specs/*/` story folders in this repository are gitignored. The plan and research stay local

### Tech Stack

- Node adapters (`adapters/sync.mjs`, `adapters/website/generate.mjs`) and Bash installer (`scripts/`)
- Package manager: npm. Scripts live in the root `package.json`
- No application runtime, database, or UI framework is involved

### Code Style & Standards

- Keep existing sentence structure. Replace the stale path token. Do not rewrite neighboring paragraphs
- English placeholder: `<key>-<topic>`. Topic length stays "at most three hyphen-separated words" where the sentence already states a limit, and add that limit only where a sample would otherwise look unbounded
- Do not remove documentation comments or generated-file banners

### Testing Patterns

Content checks (docs tasks; no unit-test runner for these markdown files):

- Stale agent paths, expect no matches: `rg -n 'docs/specs/<task-name>|docs/specs/\{task-name-or-id\}|docs/specs/<task-kebab>|docs/specs/<task>/|specifications/<task-name>|specifications/<task>/|specifications/\{task-name-or-id\}|user-authentication|\{task-name\}\.plan-review|folder named after the issue ID' .ai/prompts/internal/eversis-plan.md .ai/prompts/internal/eversis-review-plan.md .ai/prompts/public/eversis-implement.md .ai/skills/eversis-architecture-designing/SKILL.md .ai/skills/eversis-creating-implementation-plans .ai/skills/eversis-promote-domain-knowledge/SKILL.md`
- Lookup contract still present in `.ai/prompts/public/eversis-implement.md`, expect matches on both: `rg -n 'docs/specs/<key>/' .ai/prompts/public/eversis-implement.md` and `rg -n 'hit is used' .ai/prompts/public/eversis-implement.md`. `docs/specs/<key>/` is the keep-existing-folder literal. It is not the same string as `docs/specs/<key>-<topic>/`. A match on `<key>-<topic>` does not prove the lookup paragraphs survived
- Stale human and installer tokens, expect no matches: `rg -n '<issue-kebab>|my-feature|docs/specs/<task-name>|docs/specs/<task>/|docs/specs/<issue>|specifications/<task-name>|\{task-name\}\.plan-review' AGENTS.md README.md templates/AGENTS.template.md templates/eversis-project-stack.example.mdc .cursor/rules/eversis-project-stack.mdc docs/architecture/agents-md-standard.md docs/plans/README.md website/docs/getting-started/quick-wins.md website/docs/main-flow/workflow/standard-flow.md website/docs/main-flow/team-guides/project-manager.md website/docs/reference/agents/plan-reviewer.md scripts/lib/setup-agent-collections/scaffolding.sh`
- Workshop paths still present, expect matches: `rg -n 'docs/specs/<workshop-name>/|docs/specs/<workshop-topic>/' .ai/prompts/public/eversis-analyze-materials.md .ai/skills/eversis-task-extracting/SKILL.md .ai/skills/eversis-jira-task-formatting/SKILL.md`

Quality commands from this repo's stack, run from the repo root after the matching edits:

- `npm run sync:adapters`
- `npm run sync:adapters:check`
- `npm run sync:website-docs`
- `npm run sync:website-docs:check`
- `npm run website:changelog:sync`
- `npm run website:changelog:check`
- `npm run installer:smoke`

Do not run `npm run mcp:build`, `npm run mcp:test`, or `npm run website:build` for this task. Those targets do not cover the wording change.

### Database Patterns

- Not applicable. This task does not touch a database.

### Additional Context

- Jira AC-81 acceptance criteria are the checklist in Quality Assurance below
- Generated copies that still say `docs/specs/<task-name>/` before Phase 3 are expected. Phase 1 and Phase 2 checks are limited to the source paths above
- `website/docs/reference/skills/` does not currently repeat the stale folder tokens. Do not add a spec-folder paragraph there

## Implementation Plan

### Phase 1: Agent instructions that create the folder

**Goal**: The prompts and skills an agent reads when it creates research, plan, or plan review tell it to create `docs/specs/<key>-<topic>/` and to repeat that name in the file.

**Description**: Replace the stale path sentences in the seven agent sources. Leave lookup paragraphs, workshop paths, and `plan.example.md` titles alone. This phase advances the goal because these files are what the agent follows when the folder does not exist yet.

**Verification:** the stale-agent-path search in Technical Context exits with no matches. Both lookup searches in Technical Context (`docs/specs/<key>/` and `hit is used`) still match `.ai/prompts/public/eversis-implement.md`. Do not use a search for `docs/specs/<key>-<topic>/` as proof that lookup survived.

#### Task 1.1 - [MODIFY] Plan and plan-review prompts

**Description**: Point both prompts at `<key>-<topic>` and at file names that repeat the folder name. In the plan prompt, replace the sample tree and the executable sentence that says the folder is named after the issue id or a shortened task name. In the plan-review prompt, replace the directory and the `{task-name}.plan-review.md` artifact name, including the skip-when-approved sentence that uses that file name.

**Files:** `.ai/prompts/internal/eversis-plan.md` (modify), `.ai/prompts/internal/eversis-review-plan.md` (modify)

**Definition of Done**:

- [x] `.ai/prompts/internal/eversis-plan.md` tells the agent to create `docs/specs/<key>-<topic>/` and shows `ac-2-context-management` as the sample tree, with the research and plan file names repeating that folder name
- [x] `.ai/prompts/internal/eversis-review-plan.md` saves `<key>-<topic>.plan-review.md` in that same folder
- [x] Neither file contains `docs/specs/<task-name>/`, `specifications/<task-name>/`, `user-authentication`, `{task-name}.plan-review.md`, or the sentence "folder named after the issue ID"
- [x] `rg -n 'docs/specs/<task-name>|specifications/<task-name>|user-authentication|\{task-name\}\.plan-review|folder named after the issue ID' .ai/prompts/internal/eversis-plan.md .ai/prompts/internal/eversis-review-plan.md` exits with no matches

**Clues**: The plan prompt's lookup is not in this file. The stale text is the Output section (including `specifications/<task-name>/`) and the Executable prompt paragraph that starts "The file outcome should be a markdown file named after the task Jira ID". That paragraph is the only slice copied into `.cursor/commands/eversis-plan.md` and `.claude/commands/eversis-plan.md`. The plan-review prompt uses `{task-name}.plan-review.md` in the skip sentence, the output section, workflow step 10, and the output specification.

#### Task 1.2 - [MODIFY] Implement prompt artifacts bullet

**Description**: Change the single artifacts bullet that says research, plan, and plan-review files live under `docs/specs/<task-name>/`. Do not edit the Spec folder lookup paragraphs in the same file.

**Files:** `.ai/prompts/public/eversis-implement.md` (modify)

**Definition of Done**:

- [x] The artifacts bullet uses `docs/specs/<key>-<topic>/`
- [x] The lookup paragraphs still say exact `docs/specs/<key>/` wins and that one `<key>-<topic>` hit is reused
- [x] `rg -n 'docs/specs/<task-name>' .ai/prompts/public/eversis-implement.md` exits with no matches
- [x] `rg -n 'docs/specs/<key>/' .ai/prompts/public/eversis-implement.md` matches
- [x] `rg -n 'hit is used' .ai/prompts/public/eversis-implement.md` matches
- [x] A match on `docs/specs/<key>-<topic>/` is not used as the lookup proof. That string is absent from this file today. After this task it belongs on the artifacts bullet only

**Stop Rule:** Stop if the only remaining `<task-name>` hits are inside generated copies outside `.ai/prompts/public/eversis-implement.md`. Those are Phase 3.

#### Task 1.3 - [MODIFY] Plan-authoring skills and plan-review example

**Description**: Update the save-path lines in the architecture-designing skill, the creating-implementation-plans skill, and `plan-review.example.md`. Include the architecture skill's `docs/specs/<task>/` line, not only `docs/specs/<task-name>/`. Leave `plan.example.md` title placeholders unchanged.

**Files:** `.ai/skills/eversis-architecture-designing/SKILL.md` (modify), `.ai/skills/eversis-creating-implementation-plans/SKILL.md` (modify), `.ai/skills/eversis-creating-implementation-plans/plan-review.example.md` (modify), `.ai/skills/eversis-creating-implementation-plans/plan.example.md` (reuse)

**Definition of Done**:

- [x] The three modified files tell the author to save under `docs/specs/<key>-<topic>/` with the file name repeating the folder name
- [x] `plan.example.md` is unchanged
- [x] `rg -n 'docs/specs/<task-name>|docs/specs/\{task-name-or-id\}|docs/specs/<task>/|specifications/<task-name>|specifications/<task>/|specifications/\{task-name-or-id\}' .ai/skills/eversis-architecture-designing/SKILL.md .ai/skills/eversis-creating-implementation-plans` exits with no matches

**Clues**: `plan-review.example.md` H1 may keep `# Plan Review: <task-name>.plan.md` because that placeholder is a title, not a directory. The two path lines under it must change.

#### Task 1.4 - [MODIFY] Domain-knowledge related_specs example

**Description**: Change the `related_specs` example and the append instruction from `docs/specs/<task-kebab>/` to `docs/specs/<key>-<topic>/`. Do not change how the list is appended.

**Files:** `.ai/skills/eversis-promote-domain-knowledge/SKILL.md` (modify), `.ai/skills/eversis-promote-domain-knowledge/knowledge-entry.example.md` (reuse)

**Definition of Done**:

- [x] Both `related_specs` mentions in `SKILL.md` use `docs/specs/<key>-<topic>/`
- [x] `rg -n '<task-kebab>' .ai/skills/eversis-promote-domain-knowledge/SKILL.md` exits with no matches
- [x] `knowledge-entry.example.md` is unchanged. Its topic-only sample folders (`new-payment-provider`, `refactor-validation`) stay out of this task

### Phase 2: Human docs, templates, installer, changelog

**Goal**: A person reading the framework README, AGENTS, stack template, website guides, or a freshly scaffolded specs README sees the same `<key>-<topic>` folder the agent is told to create.

**Description**: Replace `<issue-kebab>`, `<task>`, `<task-name>`, and `<issue>` where they denote a ticket spec folder. Add one changelog bullet. Load `eversis-writing-repo-documentation` for this phase. This phase advances the goal because these texts are what humans and new installs follow when the agent sources are not open.

**Verification:** the stale human-and-installer search in Technical Context exits with no matches, and `npm run website:changelog:check` passes after `npm run website:changelog:sync`.

#### Task 2.1 - [MODIFY] AGENTS, README, templates, and this repo's stack rule

**Description**: Replace spec-folder tokens and the matching research/plan file-name tokens with `<key>-<topic>`. Keep the surrounding Delivery Standard sentences. Change `.cursor/rules/eversis-project-stack.mdc` in the same way as the template, because adapter sync does not copy the template over that rule.

**Files:** `AGENTS.md` (modify), `README.md` (modify), `templates/AGENTS.template.md` (modify), `templates/eversis-project-stack.example.mdc` (modify), `.cursor/rules/eversis-project-stack.mdc` (modify)

**Definition of Done**:

- [x] Each file's spec-folder sentence uses `docs/specs/<key>-<topic>/`
- [x] Where a research or plan file name is shown, it is `<key>-<topic>.research.md` or `<key>-<topic>.plan.md`
- [x] `rg -n '<issue-kebab>' AGENTS.md README.md templates/AGENTS.template.md templates/eversis-project-stack.example.mdc .cursor/rules/eversis-project-stack.mdc` exits with no matches

#### Task 2.2 - [MODIFY] Architecture doc, plans README, and hand-written website pages

**Description**: Update the pages the ticket lists, plus the extra `<issue>` cell in `agents-md-standard.md` and the `@docs/specs/<issue>/*.plan.md` example in `standard-flow.md`. Use `docs/specs/<key>-<topic>/`. In `project-manager.md`, replace `docs/specs/<task>/`. In `plan-reviewer.md`, use `<key>-<topic>.plan-review.md` inside `docs/specs/<key>-<topic>/`.

**Files:** `docs/architecture/agents-md-standard.md` (modify), `docs/plans/README.md` (modify), `website/docs/getting-started/quick-wins.md` (modify), `website/docs/main-flow/workflow/standard-flow.md` (modify), `website/docs/main-flow/team-guides/project-manager.md` (modify), `website/docs/reference/agents/plan-reviewer.md` (modify)

**Definition of Done**:

- [x] None of these files uses `<issue-kebab>`, `docs/specs/<task-name>/`, `docs/specs/<task>/`, `docs/specs/<issue>/`, `specifications/<task-name>/`, or `{task-name}.plan-review.md` for a ticket spec artifact
- [x] `rg -n '<issue-kebab>|docs/specs/<task-name>|docs/specs/<task>/|docs/specs/<issue>|specifications/<task-name>|\{task-name\}\.plan-review' docs/architecture/agents-md-standard.md docs/plans/README.md website/docs/getting-started/quick-wins.md website/docs/main-flow/workflow/standard-flow.md website/docs/main-flow/team-guides/project-manager.md website/docs/reference/agents/plan-reviewer.md` exits with no matches

**Clues**: `docs/specs/<issue-kebab>` contains the substring `docs/specs/<issue`, so the command above also covers that token. Do not change workshop pages.

#### Task 2.3 - [MODIFY] Installer scaffolding heredocs

**Description**: In `scaffold_project`, change the AGENTS.md fallback Delivery Standard line, the specs README naming line, and the plans README prefer-workflow line from `<issue-kebab>` to `<key>-<topic>`. Replace the specs README sample tree `my-feature/` with `ac-2-context-management/` and file names that repeat that folder name. Do not change the "write only if missing" behavior.

**Files:** `scripts/lib/setup-agent-collections/scaffolding.sh` (modify)

**Definition of Done**:

- [x] The three heredocs use `docs/specs/<key>-<topic>/`
- [x] The specs README sample is `docs/specs/ac-2-context-management/` with `ac-2-context-management.research.md` and `ac-2-context-management.plan.md`
- [x] `rg -n '<issue-kebab>|my-feature' scripts/lib/setup-agent-collections/scaffolding.sh` exits with no matches

#### Task 2.4 - [MODIFY] Changelog bullet

**Description**: Add one bullet under `## [Unreleased]` → `### Fixed` in the root changelog. State that ticket spec instructions now use `docs/specs/<key>-<topic>/` with file names that repeat the folder name, that an existing key-only folder is still kept by lookup, and that a new install's specs README teaches the new example. Do not add a Migration subsection. Do not hand-edit `website/src/pages/changelog.md`. Regenerate it with the sync script.

**Files:** `CHANGELOG.md` (modify), `website/src/pages/changelog.md` (modify — generated in this task by `npm run website:changelog:sync`)

**Definition of Done**:

- [x] `CHANGELOG.md` contains an Unreleased Fixed bullet that names `docs/specs/<key>-<topic>/`
- [x] `npm run website:changelog:sync` completes
- [x] `npm run website:changelog:check` passes

### Phase 3: Regenerated prompt copies and command shims

**Goal**: The copies an agent or a reader can open outside `.ai/prompts/` match the sources edited in Phase 1.

**Description**: Run the existing generators. Do not hand-edit the generated trees. This phase advances the goal because a stale command shim would still tell the agent to create `docs/specs/<task-name>/`.

**Verification:** `npm run sync:adapters:check` and `npm run sync:website-docs:check` pass, and `npm run installer:smoke` passes.

#### Task 3.1 - [MODIFY] Sync adapters and website prompt pages

**Description**: From the repo root, run `npm run sync:adapters` and `npm run sync:website-docs`. Confirm the checks pass. Confirm the installer smoke test still passes after the scaffolding heredoc change.

**Files:** `.cursor/commands/` (modify — generated in this task), `.claude/commands/` (modify — generated in this task), `website/docs/reference/prompts/` (modify — generated in this task)

**Definition of Done**:

- [x] `npm run sync:adapters` completes
- [x] `npm run sync:website-docs` completes
- [x] `npm run sync:adapters:check` passes
- [x] `npm run sync:website-docs:check` passes
- [x] `npm run installer:smoke` passes
- [x] `rg -n 'docs/specs/<task-name>|specifications/<task-name>|user-authentication|folder named after the issue ID|\{task-name\}\.plan-review' website/docs/reference/prompts/internal/eversis-plan.md website/docs/reference/prompts/internal/eversis-review-plan.md website/docs/reference/prompts/public/eversis-implement.md .cursor/commands/eversis-plan.md .claude/commands/eversis-plan.md .cursor/commands/eversis-review-plan.md .claude/commands/eversis-review-plan.md .cursor/commands/eversis-implement.md .claude/commands/eversis-implement.md` exits with no matches

**Stop Rule:** Stop if a check fails for a reason outside the wording change. Do not hand-edit generated files to force the check green.

**Clues**: `npm run sync:website-docs` also runs the skills existence check. Do not add skill pages to satisfy it; it should already pass.

### Phase 4: Code Review

**Goal**: An independent review confirms the wording contract is complete and the out-of-scope paths are untouched, so the Wildly Important Goal is not declared on an incomplete edit.

**Description**: Final verification of the full implementation. This phase is mandatory and always comes last. Delegate to Code Reviewer via `eversis-review.md` in a separate context from the implementer. There is no e2e suite for this docs change. Pass the content checks and the quality commands in Technical Context instead.

**Verification:** `npm run sync:adapters:check`, `npm run sync:website-docs:check`, `npm run website:changelog:check`, and `npm run installer:smoke` pass, and the stale-agent-path search plus the stale human-and-installer search from Technical Context both exit with no matches.

#### Task 4.1 - [REUSE] Code review by Code Reviewer

**Description**: Run **Code Reviewer** via `eversis-review.md` on the complete wording change. Reviewer checks the Quality Assurance list and confirms workshop paths and lookup text were not edited.

**Files:** `.ai/prompts/internal/eversis-plan.md` (reuse), `.ai/prompts/internal/eversis-review-plan.md` (reuse), `.ai/prompts/public/eversis-implement.md` (reuse), `.ai/skills/eversis-architecture-designing/SKILL.md` (reuse), `.ai/skills/eversis-creating-implementation-plans/SKILL.md` (reuse), `.ai/skills/eversis-creating-implementation-plans/plan-review.example.md` (reuse), `.ai/skills/eversis-promote-domain-knowledge/SKILL.md` (reuse), `AGENTS.md` (reuse), `README.md` (reuse), `templates/AGENTS.template.md` (reuse), `templates/eversis-project-stack.example.mdc` (reuse), `.cursor/rules/eversis-project-stack.mdc` (reuse), `docs/architecture/agents-md-standard.md` (reuse), `docs/plans/README.md` (reuse), `website/docs/getting-started/quick-wins.md` (reuse), `website/docs/main-flow/workflow/standard-flow.md` (reuse), `website/docs/main-flow/team-guides/project-manager.md` (reuse), `website/docs/reference/agents/plan-reviewer.md` (reuse), `scripts/lib/setup-agent-collections/scaffolding.sh` (reuse), `CHANGELOG.md` (reuse)

**Definition of Done**:

- [x] The stale-agent-path search and the stale human-and-installer search from Technical Context both exit with no matches
- [x] Both lookup searches (`docs/specs/<key>/` and `hit is used`) still match `.ai/prompts/public/eversis-implement.md`
- [x] `npm run sync:adapters:check` passes
- [x] `npm run sync:website-docs:check` passes
- [x] `npm run website:changelog:check` passes
- [x] `npm run installer:smoke` passes
- [x] Code review passes with no blocking findings
- [x] Review outcome documented in Changelog

**Clues**: No Figma and no UI verification. No application e2e. Blocking means a ticket spec path still teaches a key-only folder or `<task-name>`, a workshop path was changed, or lookup was weakened.

## Security Considerations

- Documentation and installer text only. No credentials, no new dependencies, no change to auth or to which folders the installer overwrites.
- Keeping the "write README only if missing" behavior avoids replacing a consumer project's existing specs README during upgrade.
- Keeping lookup's key-only exception avoids sending an agent to create a second folder beside one that already holds the work.

## Quality Assurance

Acceptance criteria checklist to verify the implementation meets the defined requirements:

- [x] No prompt or skill that creates a ticket's research, plan, or plan review tells the agent to create a key-only folder or a `<task-name>` folder
- [x] `AGENTS.md`, `templates/AGENTS.template.md`, `templates/eversis-project-stack.example.mdc`, `.cursor/rules/eversis-project-stack.mdc`, and `README.md` state `docs/specs/<key>-<topic>/`
- [x] Research, plan, and plan-review file names are described as repeating the folder name
- [x] Workshop paths `docs/specs/<workshop-name>/` and `docs/specs/<workshop-topic>/` are unchanged
- [x] `website/docs/reference/prompts/` matches `.ai/prompts/` after `npm run sync:website-docs`, and `.cursor/commands/` and `.claude/commands/` match after `npm run sync:adapters`
- [x] `scripts/lib/setup-agent-collections/scaffolding.sh` teaches `docs/specs/<key>-<topic>/` and the `ac-2-context-management` example
- [x] Lookup text that keeps an existing `docs/specs/<key>/` is unchanged

## Improvements (Out of Scope)

- `.ai/prompts/public/eversis-repo-docs-writer.md` still has an example `@docs/specs/<task>/plan.md`. That prompt does not create research, plan, or plan review.
- `plan.example.md` still uses `<task-name>` as a plan title and as task titles.
- `.ai/skills/eversis-promote-domain-knowledge/knowledge-entry.example.md` still shows topic-only sample folders (`new-payment-provider`, `refactor-validation`). Those lines are not the `<task-kebab>` instructions in `SKILL.md`.
- Website skill summary pages do not restate the folder convention. They also do not currently teach the old token.
- Existing consumer spec folders and existing consumer `docs/specs/README.md` files are not rewritten. The installer does not overwrite a README that is already there.
- Key-only folders that already exist stay in place. Lookup still selects them.

## Human gates

1. ~~Approve research~~ — done (`Selected option(s) approve-include`)
2. ~~Approve this plan~~ — done (`Selected option(s) approve-plan`)
3. ~~Implement → Review → Fine~~ — done. Review verdict PASS. Fine declared in this session (`Plan is ok. Do not start implementation yet` was the earlier hold).

## Changelog

| Date   | Change Description   |
| ------ | -------------------- |
| 2026-10-15 | Initial plan created. Research approved with installer heredocs in scope (`Selected option(s) approve-include`). |
| 2026-10-15 | Plan draft approved (`Selected option(s) approve-plan`). Plan review iteration 1 returned `REVISIONS NEEDED` (B1, W1, W2, W3). Checks now target the lookup literals `docs/specs/<key>/` and `hit is used`, the executable plan sentence, `specifications/` alternates, `{task-name}.plan-review.md`, plan command shims, and `npm run website:changelog:sync` before the changelog check. `knowledge-entry.example.md` stays unchanged on purpose. |
| 2026-10-15 | Revised plan accepted. Implementation not started (`Plan is ok. Do not start implementation yet`). |
| 2026-10-15 | CHECKPOINT: Phases 1–3 are complete and tested. Stale-token searches exited with no matches. `sync:adapters:check`, `sync:website-docs:check`, `website:changelog:check`, and `installer:smoke` passed. Sources changed: plan, plan-review, and implement prompts; architecture-designing, creating-implementation-plans, plan-review.example.md, promote-domain-knowledge; AGENTS.md, README.md, both templates, the stack rule, agents-md-standard.md, plans README, four website pages, scaffolding.sh, CHANGELOG.md. Generated: command shims, website prompt pages, website changelog page. Next step: Task 4.1 independent code review. |
| 2026-10-15 | RESUMED: This session continues with Task 4.1 code review. |
| 2026-10-15 | Code review passed. No blocking findings. Stale-token searches exited with no matches. Lookup literals `docs/specs/<key>/` and `hit is used` still match `eversis-implement.md`. Workshop paths unchanged. `sync:adapters:check`, `sync:website-docs:check`, `website:changelog:check`, and `installer:smoke` passed. |

## Code Review Findings

**Verdict: PASS.** No open BLOCKER findings. Every Definition of Done checkbox in tasks 1.1–4.1 and every Quality Assurance checkbox is verified and checked. Product sources were not edited in this review.

### BLOCKER

None.

### SUGGESTION

None.

### What was reviewed

Uncommitted wording diff, 28 files, all inside the plan. The implement prompt change is the artifacts bullet only. Generated command shims, website prompt pages, and `website/src/pages/changelog.md` match that wording. `.cursor/commands/eversis-implement.md` and `.claude/commands/eversis-implement.md` did not change because the executable slice has no artifacts bullet; `sync:adapters:check` confirms they still match the source.

Confirmed not edited: lookup paragraphs in `.ai/prompts/public/eversis-implement.md`, `.ai/skills/eversis-orchestrating-implementation/SKILL.md`, `.ai/rules/orchestration/spec-driven-development.md`, workshop paths, `plan.example.md`, `knowledge-entry.example.md`, `.ai/prompts/public/eversis-repo-docs-writer.md`. Scaffolding still writes `AGENTS.md`, `docs/specs/README.md`, and `docs/plans/README.md` only when the file is absent. No new dependencies. No documentation comments or generated banners removed.

Out of scope leftovers remain and are not findings: `eversis-repo-docs-writer.md` still has `@docs/specs/<task>/plan.md`; `plan.example.md` still uses `<task-name>` as titles; `knowledge-entry.example.md` still shows topic-only sample folders.

### Commands (repo root, 2026-10-15)

| Check | Result |
| --- | --- |
| Stale agent paths | exit 1, no matches |
| `docs/specs/<key>/` on `eversis-implement.md` | exit 0, lines 61 and 69 |
| `hit is used` on `eversis-implement.md` | exit 0, lines 61 and 69 |
| Stale human and installer tokens | exit 1, no matches |
| Workshop paths | exit 0, matches in analyze-materials, task-extracting, and jira-task-formatting |
| Generated shim stale tokens | exit 1, no matches |
| `npm run sync:adapters:check` | pass (`adapter sync check: OK`) |
| `npm run sync:website-docs:check` | pass (`website docs prompts check: OK`, skills 50/50) |
| `npm run website:changelog:check` | pass (`sync-changelog --check: OK`) |
| `npm run installer:smoke` | pass (`[smoke] PASS`) |

`docs/specs/<key>-<topic>/` in `eversis-implement.md` is only the artifacts bullet (line 42). It was not used as lookup proof.
