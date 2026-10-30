# AC-81 spec folder - Analysis Result

## Task Details

| Field | Value |
|---|---|
| Jira ID | AC-81 |
| Title | Ujednolicić nazwę katalogu spec do klucz-temat |
| Description | Agents that create a spec folder for a ticket must name it from the ticket key plus a short topic, so the folder shows what the work is about and research, plan, and plan-review files land in that same place. Some framework instructions still tell the agent to use the key alone or a generic task name. The agent follows that older instruction and creates a key-only folder, even though the key-plus-topic convention has been canonical since September 2026. |
| Priority | Medium |
| Reporter | Piotr Niemirski |
| Created Date | 2026-10-15 |
| Due Date | Not set |
| Labels | agent-collections, spec-folder |
| Estimated Effort | Not set |

Status: In Progress. Issue type: Task. No parent, subtasks, issue links, or comments. Jira description is in Polish; this research states it in English.

Jira names the spec folder for this task: `docs/specs/ac-81-spec-folder/`, with `ac-81-spec-folder.research.md` required before the plan and `ac-81-spec-folder.plan.md` required before implementation. Full spec-driven development. Do not start implementation without approved research and plan.

## Business Impact

A key-only folder hides the topic. After it exists, spec-folder lookup keeps that folder and refuses to create the key-plus-topic sibling beside it. Later research, plan, and plan-review files are then stuck in the unnamed folder. Unifying the instructions that create those files stops new key-only folders at the source. Existing key-only folders stay valid under the lookup rule. Consumer projects that already have folders are not rewritten by hand; they pick up new wording when their templates are synced.

## Gathered Information

### Knowledge Base & Task Management Tools

Jira AC-81 (cloud `eversis.atlassian.net`, issue `139250`), fetched 2026-10-15. No Confluence link, attachment, or Figma link.

Acceptance criteria on the ticket:

- No prompt or skill that creates a ticket's research, plan, or plan review tells the agent to create a key-only folder or a `<task-name>` folder.
- AGENTS and stack templates, and the framework README, state `docs/specs/<klucz>-<temat>/`.
- The research file name and the plan file name repeat the folder name.
- Workshop paths that have no ticket key stay as they are.
- After the prompt source changes, documentation-site copies stay in sync with the prompts.

In scope (ticket list):

- `.ai/prompts/internal/eversis-review-plan.md`
- `.ai/prompts/internal/eversis-plan.md`
- `.ai/prompts/public/eversis-implement.md` (the artifacts sentence only; the lookup paragraph stays)
- `.ai/skills/eversis-architecture-designing/SKILL.md`
- `.ai/skills/eversis-creating-implementation-plans/SKILL.md`
- `.ai/skills/eversis-creating-implementation-plans/plan-review.example.md`
- `.ai/skills/eversis-promote-domain-knowledge/SKILL.md`
- `AGENTS.md`
- `README.md`
- `templates/AGENTS.template.md`
- `templates/eversis-project-stack.example.mdc`
- `docs/architecture/agents-md-standard.md`
- `docs/plans/README.md`
- `website/docs/getting-started/quick-wins.md`
- `website/docs/main-flow/workflow/standard-flow.md`
- `website/docs/main-flow/team-guides/project-manager.md`
- `website/docs/reference/agents/plan-reviewer.md`

Out of scope (ticket):

- Workshop folders `docs/specs/<workshop-name>/` and `docs/specs/<workshop-topic>/` (brief, extracted tasks, jira-tasks).
- The lookup rule that keeps an existing key-only folder.
- Hand-editing spec folders already created in consumer projects.

`docs/context/agent-collections/INDEX.md` indexes two components (`readiness-contract`, `jira-backlog-hierarchy`). Neither is the spec-folder naming convention. `last_audit` is absent. Domain knowledge for this task is the spec-driven-development rule, not an index component.

### Codebase

This repository is the Agent Collections framework: markdown SSOT under `.ai/`, adapters that package it, an installer, and a Docusaurus site. There is no application backend or frontend in this task.

Canonical convention, already in force since commit `03b216f` (AC-32, 24 September 2026), in `.ai/rules/orchestration/spec-driven-development.md` and `docs/specs/README.md`:

- Folder: `docs/specs/<key>-<topic>/`. The topic is at most three hyphen-separated words. Example: `docs/specs/ac-2-context-management/`.
- Research and plan file names repeat the folder name.
- A name that puts the topic before the key is not the pattern.
- Lookup in `.ai/skills/eversis-orchestrating-implementation/SKILL.md`: if `docs/specs/<key>/` already exists, use it. Zero hits: create `docs/specs/<key>-<topic>/`. Do not create a key-only folder beside a topic folder.

`.ai/prompts/internal/eversis-research.md` already follows that convention. The plan and plan-review prompts do not.

What the listed sources still say (verified in the tree on 2026-10-15):

| Source | Stale instruction |
|---|---|
| `.ai/prompts/internal/eversis-plan.md` | Output path `docs/specs/<task-name>/`, example folder `user-authentication/` with no ticket key, and executable text: folder named after the issue ID or the shortened task name |
| `.ai/prompts/internal/eversis-review-plan.md` | Save `{task-name}.plan-review.md` under `docs/specs/<task-name>/` |
| `.ai/prompts/public/eversis-implement.md` | Artifacts bullet: `docs/specs/<task-name>/`. The lookup paragraph already says `<key>-<topic>` and must stay |
| `.ai/skills/eversis-architecture-designing/SKILL.md` | Save under `docs/specs/<task-name>/`. Same file also says artifacts live under `docs/specs/<task>/` |
| `.ai/skills/eversis-creating-implementation-plans/SKILL.md` | `docs/specs/{task-name-or-id}/{task-name}.plan.md` |
| `.ai/skills/eversis-creating-implementation-plans/plan-review.example.md` | `docs/specs/<task-name>/<task-name>.plan.md` and the matching research path |
| `.ai/skills/eversis-promote-domain-knowledge/SKILL.md` | `related_specs` example `docs/specs/<task-kebab>/` |
| `AGENTS.md`, `README.md`, `templates/AGENTS.template.md`, `templates/eversis-project-stack.example.mdc`, `docs/plans/README.md`, `docs/architecture/agents-md-standard.md`, `website/docs/getting-started/quick-wins.md` | `docs/specs/<issue-kebab>/` and, where present, `<issue-kebab>.research.md` / `<issue-kebab>.plan.md` |
| `website/docs/main-flow/workflow/standard-flow.md` | `docs/specs/<task-name>/` and also `@docs/specs/<issue>/*.plan.md` |
| `website/docs/main-flow/team-guides/project-manager.md` | `docs/specs/<task>/*.plan.md` and `docs/specs/<task>/` |
| `website/docs/reference/agents/plan-reviewer.md` | `{task-name}.plan-review.md` in `docs/specs/<task-name>/` |
| `docs/architecture/agents-md-standard.md` | Listed `<issue-kebab>` rows, plus a separate `docs/specs/<issue>/` cell |

`<issue-kebab>` does not say "key, then topic". An agent can satisfy it with the key alone. That is the older instruction the ticket describes.

Generated copies, not hand-edited. They repeat the stale prompt text today and must be regenerated from `.ai/prompts/` after the source edit:

- `website/docs/reference/prompts/**` via `npm run sync:website-docs` (`node adapters/website/generate-prompts.mjs`). Check with `npm run sync:website-docs:check`.
- `.cursor/commands/eversis-*.md` via the Cursor adapter (`npm run sync:adapters`).
- `.claude/commands/eversis-*.md` via the Claude adapter in the same sync. The ticket names Cursor commands. Claude command shims are the same prompt text and go stale if only Cursor is regenerated.

Website skill pages under `website/docs/reference/skills/` are summaries, not full skill copies. A search there found no `<task-name>`, `<issue-kebab>`, or `<task-kebab>` path tokens. The skills check only verifies that each skill id is mentioned and that the overview count matches. It does not copy skill body paths.

`plan.example.md` uses `<task-name>` as a plan title and as task titles. Those are not folder paths. The ticket does not list that file. Leave the titles alone unless a path instruction is added there.

Workshop paths that must stay (no ticket key):

- `docs/specs/<workshop-name>/` and `docs/specs/<workshop-topic>/` in `eversis-analyze-materials`, `eversis-task-extracting`, `eversis-task-quality-reviewing`, `eversis-jira-task-formatting`, and the matching website pages.
- `docs/specs/<project-or-topic>/jira-tasks.md` in `eversis-jira-task-formatting` (no ticket key).

Adjacent surfaces the ticket list does not name:

- `.cursor/rules/eversis-project-stack.mdc` repeats the template sentence `docs/specs/<issue-kebab>/`. Agents in this repository read this file, not the template. It is the same sentence the ticket asks the stack template to change.
- `.ai/prompts/public/eversis-repo-docs-writer.md` has an example `@docs/specs/<task>/plan.md`. That prompt does not create research, plan, or plan review, so it is outside the first acceptance criterion.
- `scripts/lib/setup-agent-collections/scaffolding.sh` writes `<issue-kebab>` into the AGENTS.md fallback (only when `templates/AGENTS.template.md` is missing) and, on every fresh install that lacks the files, into `docs/specs/README.md` and `docs/plans/README.md`. The specs README example is `docs/specs/my-feature/` with `my-feature.research.md` and `my-feature.plan.md` (topic, no key). No installer test asserts these strings. See Question 1.

Lookup, `.ai/prompts/internal/eversis-research.md`, `.ai/rules/orchestration/spec-driven-development.md`, and `docs/specs/README.md` already state `<key>-<topic>`. Do not weaken the rule that an existing key-only folder is kept.

Working interpretation of the Polish acceptance token: English files keep `docs/specs/<key>-<topic>/` from the canonical rule. The ticket's own Delivery Standard block uses `docs/specs/ac-81-spec-folder/`, which is that pattern. Do not put the Polish placeholder `<klucz>-<temat>` into English docs. File names repeat the folder name (`<key>-<topic>.research.md`, `<key>-<topic>.plan.md`, and the plan review `<key>-<topic>.plan-review.md`).

In this repository, `docs/specs/*/` story folders are gitignored. This research file is a local artifact. `docs/specs/README.md` stays tracked.

### Relevant Links

- https://eversis.atlassian.net/browse/AC-81 — this task
- `.ai/rules/orchestration/spec-driven-development.md` — canonical folder and file-name convention
- `docs/specs/README.md` — the same convention for humans
- `.ai/skills/eversis-orchestrating-implementation/SKILL.md` — spec folder lookup (keep the key-only exception)
- Commit `03b216f` — AC-32, convention introduced 24 September 2026

### Relevant Charts & Diagrams

```text
Agent reads plan or plan-review prompt
        |
        v
Creates docs/specs/<key>/     (stale instruction)
        |
        v
Lookup finds exact <key>/ and keeps it
        |
        v
Does not create docs/specs/<key>-<topic>/
        |
        v
Research, plan, and plan review stay in the key-only folder
```

Target:

```text
No existing <key>/ and no <key>-<topic>/
        |
        v
Create docs/specs/<key>-<topic>/
        |
        v
<key>-<topic>.research.md
<key>-<topic>.plan.md
<key>-<topic>.plan-review.md
```

## Current Implementation Status

### Existing Components

- Spec-driven development rule — `.ai/rules/orchestration/spec-driven-development.md` — can be reused (already `<key>-<topic>`)
- Spec folder lookup — `.ai/skills/eversis-orchestrating-implementation/SKILL.md` — can be reused (do not change the keep-existing-key-only rule)
- Research prompt — `.ai/prompts/internal/eversis-research.md` — can be reused (already tells the agent to create `<key>-<topic>` and to repeat the folder name)
- Plan prompt — `.ai/prompts/internal/eversis-plan.md` — needs modification
- Plan-review prompt — `.ai/prompts/internal/eversis-review-plan.md` — needs modification
- Implement prompt artifacts sentence — `.ai/prompts/public/eversis-implement.md` — needs modification (lookup paragraph stays)
- Architecture-designing skill — `.ai/skills/eversis-architecture-designing/SKILL.md` — needs modification (both `<task-name>` and `<task>` path lines)
- Creating-implementation-plans skill — `.ai/skills/eversis-creating-implementation-plans/SKILL.md` and `plan-review.example.md` — needs modification
- Promote-domain-knowledge skill — `.ai/skills/eversis-promote-domain-knowledge/SKILL.md` — needs modification (`related_specs` example only)
- Human docs and templates listed on the ticket — needs modification (`<issue-kebab>`, `<task-name>`, `<task>`, `<issue>`)
- Prompt website pages, Cursor command shims, Claude command shims — needs extension by regeneration, not by hand edits
- Workshop artifact paths — can be reused (leave unchanged)
- Installer scaffolding heredocs — `scripts/lib/setup-agent-collections/scaffolding.sh` — needs modification (Question 1: include)

### Key Files and Directories

- `.ai/prompts/internal/eversis-plan.md` — still names the folder from the issue id or a shortened task name, and shows `user-authentication/` with no key
- `.ai/prompts/internal/eversis-review-plan.md` — still saves `{task-name}.plan-review.md` under `docs/specs/<task-name>/`
- `.ai/rules/orchestration/spec-driven-development.md` — target wording already present; use it as the phrase to copy
- `scripts/lib/setup-agent-collections/scaffolding.sh` — fresh-install README text still uses `<issue-kebab>` and `my-feature/`
- `.cursor/rules/eversis-project-stack.mdc` — this repo's live stack policy still says `<issue-kebab>`
- `adapters/sync.mjs`, `adapters/cursor/generate.mjs`, `adapters/claude/generate-commands.mjs`, `adapters/website/generate-prompts.mjs` — generators for command shims and prompt docs

## Gap Analysis

The ticket's change list matches the prompts and skills that still create or point at a `<task-name>` or key-only folder. Two extra lines inside already-listed files must travel with those edits: `docs/specs/<task>/` in the architecture-designing skill, and `docs/specs/<issue>/` in `agents-md-standard.md` and `standard-flow.md`. The live stack rule in this repo repeats the template sentence and should change with the template, or agents here keep reading `<issue-kebab>`.

Placeholder language is settled by the ticket itself: the Delivery Standard block on AC-81 uses `docs/specs/ac-81-spec-folder/`, and the canonical rule already uses English `<key>-<topic>`. English edits use that token. Research, plan, and plan-review file names repeat the folder name.

One scope choice is still open.

### Question 1

#### Should `scripts/lib/setup-agent-collections/scaffolding.sh` change in this task?

Answered. Include it.

The ticket does not name this file. It is not a prompt or a skill. On a new consumer install it writes `docs/specs/README.md` and `docs/plans/README.md` when those files are absent, and it writes an AGENTS.md fallback only when `templates/AGENTS.template.md` is missing. Those heredocs still say `docs/specs/<issue-kebab>/`. The specs README example is `docs/specs/my-feature/` (no ticket key). Out of scope covers hand-fixing folders that already exist in consumer projects.

Closing phrase: `Selected option(s) approve-include` (option label: "Approve research and include scaffolding.sh (recommended)"). Change the three heredoc sentences and replace the `my-feature` example with `ac-2-context-management`. Do not rewrite existing consumer folders.

### Question 2

#### Which placeholder should English files use for the folder pattern?

Answered from the ticket and the canonical rule. Use `docs/specs/<key>-<topic>/`. File names repeat that folder name. Do not insert `<klucz>-<temat>` into English sources. The Polish acceptance line is the same convention described in the reporter's language.

## Human gates

1. ~~Approve research~~ — done (`Selected option(s) approve-include`)
2. Approve plan (once written)
3. Implement → Review → Fine
