# Cursor skill invocation - Analysis Result

## Task Details

| Field | Value |
|---|---|
| Jira ID | none |
| Title | Why `eversis-add-domain-knowledge` cannot be invoked from Cursor chat, and how installation should mention `eversis-import-confluence-knowledge` |
| Description | Person asked, via `/eversis-implement`, why `eversis-add-domain-knowledge` cannot be invoked from chat, and to check `website/docs/getting-started/installation.md` for the best place to add `eversis-import-confluence-knowledge` to the install steps. |
| Priority | unset |
| Reporter | person in chat |
| Created Date | 2026-09-23 |
| Due Date | unset |
| Labels | cursor, skills, installation, domain-context |
| Estimated Effort | small docs correction once scope is confirmed |

## Business Impact

Person-started domain-knowledge skills are documented as `user-invocable: true`, but in this framework checkout they do not appear in the Cursor `/` menu. People following the installation page are also told that Cursor has no `.cursor/skills` mirror, which no longer matches the installer. That blocks the intended path for adding a durable fact and for the one-time Confluence seed.

## Gathered Information

### Knowledge Base & Task Management Tools

No Jira issue was attached. Domain-context behavior is documented in `website/docs/reference/domain-context.md` and `website/docs/reference/skills/add-domain-knowledge.md`. Installation is documented in `website/docs/getting-started/installation.md`.

### Codebase

`eversis-add-domain-knowledge` exists only as a skill at `.ai/skills/eversis-add-domain-knowledge/SKILL.md`. Frontmatter sets `user-invocable: true`. The same flag is `true` on `eversis-import-confluence-knowledge`, `eversis-audit-domain-knowledge`, and `eversis-record-decision`.

Cursor chat `/` commands in this repo are the 28 files under `.cursor/commands/`. The Cursor adapter generates those only from `.ai/prompts/{public,internal}/` (`adapters/cursor/README.md`, TASK-598). There is no prompt named `eversis-add-domain-knowledge`, so there is no `.cursor/commands/eversis-add-domain-knowledge.md`.

`user-invocable` is not read by the command generator. The installer test treats it as a menu-hiding flag on the copied skill file (`scripts/setup-agent-collections.test.sh`): `user-invocable: false` must survive the copy into `.cursor/skills/` and `.claude/skills/`.

The installer mirrors every `.ai/skills/eversis-*` package into the **consumer** project's `.cursor/skills/` when `cursor` is selected, and into `.claude/skills/` when `claude` is selected (`scripts/lib/setup-agent-collections/link-framework.sh`, `_link_cursor_skills` / `_link_claude_skills`). This framework checkout is not that consumer. `.cursor/skills/` and `.claude/skills/` are absent here. Cursor's available skill list for this session does not include `eversis-add-domain-knowledge`.

Published install copy is stale relative to that installer:

- `website/docs/getting-started/installation.md` section 4 says this MVP does not ship a `.cursor/skills` mirror and that Cursor skills stay MCP-only.
- `website/docs/getting-started/quick-wins.md` and `prerequisites.md` say the same.
- Root `AGENTS.md` says the full `.cursor/skills` mirror is not shipped.

`--confluence-space-key` on the installation page only records `ssot.confluenceSpaceKey`. The page states the installer never calls Confluence. The import itself is the separate skill `eversis-import-confluence-knowledge`, already described as a manual one-time seed in `website/docs/reference/domain-context.md`.

### Relevant Links

- `.ai/skills/eversis-add-domain-knowledge/SKILL.md` — person-started skill, `user-invocable: true`
- `website/docs/getting-started/installation.md` — install steps; Confluence flag only records a key
- `scripts/lib/setup-agent-collections/link-framework.sh` — consumer skill mirror into `.cursor/skills/` and `.claude/skills/`
- `docs/architecture/adapter-mapping.md` — Cursor slash shims come from prompts; skill emit is described as MCP resolution

### Relevant Charts & Diagrams

```text
Person types / in Cursor chat
        |
        +-- .cursor/commands/*.md     <-- generated from .ai/prompts only
        |                                 (no add-domain-knowledge prompt)
        |
        +-- .cursor/skills/*/SKILL.md <-- installer mirror on a consumer
                                          absent in this framework checkout
                                          user-invocable: true would show here

.ai/skills/eversis-add-domain-knowledge/SKILL.md
        exists, but Cursor's / menu does not scan .ai/skills/
```

## Current Implementation Status

### Existing Components

- `eversis-add-domain-knowledge` — `.ai/skills/eversis-add-domain-knowledge/SKILL.md` — can be reused; not wired into Cursor `/` in this checkout
- Cursor command generator — `adapters/cursor/generate.mjs` — generates prompt shims only; needs no change for skill invocation
- Installer skill mirror — `scripts/lib/setup-agent-collections/link-framework.sh` — already links skills for a consumer; does not run against the framework repo itself
- Installation page — `website/docs/getting-started/installation.md` — needs modification; still says Cursor has no `.cursor/skills` mirror, and does not say when to run the Confluence import skill

### Key Files and Directories

- `.ai/skills/eversis-add-domain-knowledge/SKILL.md` — skill body and `user-invocable: true`
- `.cursor/commands/` — Cursor `/` prompt shims; skill is not among them
- `website/docs/getting-started/installation.md` — section 4 and the `--confluence-space-key` row
- `AGENTS.md` — Channel notes still say the `.cursor/skills` mirror is not shipped

## Gap Analysis

The skill cannot be invoked from this chat because Cursor's `/` menu does not read `.ai/skills/`. It reads `.cursor/commands/` (prompts) and `.cursor/skills/` (installer mirror, with `user-invocable` controlling visibility). This checkout has the skill only under `.ai/skills/`, and it has no matching prompt shim.

On a consumer project after `setup-agent-collections.sh --agents=cursor`, the same skill is linked to `.cursor/skills/eversis-add-domain-knowledge/` and should appear in `/` because `user-invocable: true`. The installation page currently tells the opposite.

`eversis-import-confluence-knowledge` should not be added as an installer step that calls Confluence. The installer already records the space key and must keep not calling Confluence. The install page should say, after the flag table, that the one-time seed is a separate chat command once the skill mirror exists: `/eversis-import-confluence-knowledge`. That command is available in a consumer Cursor or Claude session, not from `.ai/skills/` alone.

### Question 1
#### Should the follow-up change only the docs (installation, quick-wins, prerequisites, AGENTS.md), or also make these skills invocable inside the framework checkout itself?
Superseded by the 2026-10-13 delta Question 1. The person asked to improve visibility, not only to document it.

### Question 2
#### Confirm the Confluence install wording: record the key at install time, and tell the person to run `/eversis-import-confluence-knowledge` afterwards in the consumer project — not from inside the installer.
Out of scope for the 2026-10-13 request. Leave unanswered until a docs pass is explicitly in scope. Do not fold it into the visibility fix.

## Delta — 2026-10-13 — Cursor visibility inventory

The person asked, via `/eversis-implement`, to improve visibility of `eversis-add-domain-knowledge` in Cursor and to analyze visibility of the other skills. Jira AC-35 is a different story (Prerequisites page UX). It was not used as the spec folder.

### What is visible in this Cursor session

This framework checkout still has no `.cursor/skills/` directory and no `.claude/skills/` directory. `.cursor/commands/` has 28 prompt shims. None of them is `eversis-add-domain-knowledge`, `eversis-import-confluence-knowledge`, `eversis-audit-domain-knowledge`, or `eversis-record-decision`. There is no matching file under `.ai/prompts/` either, so the command generator cannot emit those names.

Cursor's skill catalog for this session contains no `eversis-*` skill. Cursor discovers project skills from `.cursor/skills/`, not from `.ai/skills/`. The skill file exists and sets `user-invocable: true`. That flag is not enough for Cursor to list it while the project skill directory is absent.

Published copy is still stale against the installer. `website/docs/getting-started/installation.md` and `quick-wins.md` still say this MVP does not ship a `.cursor/skills` mirror and that Cursor skills stay MCP-only. `AGENTS.md` says the same. The installer already links every `.ai/skills/eversis-*` package into the consumer `.cursor/skills/` when `cursor` is selected (`_link_cursor_skills` in `scripts/lib/setup-agent-collections/link-framework.sh`).

A local consumer tree at `DAWIS/eog` has 50 `.cursor/skills/eversis-*` symlinks dated 2026-10-13, including `eversis-add-domain-knowledge`. `vendor/agent-collections/` in that tree is an empty directory, so those symlinks do not resolve. That is an incomplete vendor checkout, not evidence that the linker points at the wrong relative path when the vendor tree is populated.

### Inventory of `.ai/skills/*/SKILL.md` (50 packages)

| `user-invocable` | Count | Cursor `/` expectation if `.cursor/skills/` exists and Cursor honors the flag the way Claude does |
| --- | ---: | --- |
| `true` | 4 | Shown. These are the person-started skills. |
| `false` | 13 | Hidden from the menu, still readable by the model. |
| absent | 33 | Treated as shown. Claude hides a skill only when the flag is `false` (`adapters/claude/README.md`). |

Person-started (`true`):

| Skill | Name length | `disable-model-invocation` | `.cursor/commands` shim |
| --- | ---: | --- | --- |
| `eversis-add-domain-knowledge` | 28 | absent | no |
| `eversis-audit-domain-knowledge` | 30 | absent | no |
| `eversis-import-confluence-knowledge` | 35 | absent | no |
| `eversis-record-decision` | 23 | absent | no |

Hidden on purpose (`false`): `eversis-accessibility-auditing`, `eversis-analyzing-bugs`, `eversis-analyzing-regression-risk`, `eversis-creating-implementation-plans`, `eversis-functional-testing`, `eversis-implementing-filters`, `eversis-orchestrating-implementation`, `eversis-planning-tests`, `eversis-promote-domain-knowledge`, `eversis-task-extracting`, `eversis-task-quality-reviewing`, `eversis-verifying-acceptance-criteria`, `eversis-writing-repo-documentation`.

Flag absent (33), so a full mirror would surface them next to the four person-started skills: `eversis-architecture-designing`, `eversis-ba-docs-planner`, `eversis-ba-docs-writer`, `eversis-code-reviewing`, `eversis-codebase-analysing`, `eversis-creating-agents`, `eversis-creating-instructions`, `eversis-creating-prompts`, `eversis-creating-skills`, `eversis-designing-multi-cloud-architecture`, `eversis-e2e-testing`, `eversis-engineering-prompts`, `eversis-ensuring-accessibility`, `eversis-fine-handoff`, `eversis-implementation-gap-analysing`, `eversis-implementing-backend`, `eversis-implementing-ci-cd`, `eversis-implementing-forms`, `eversis-implementing-frontend`, `eversis-implementing-kubernetes`, `eversis-implementing-observability`, `eversis-implementing-terraform-modules`, `eversis-jira-task-formatting`, `eversis-managing-secrets`, `eversis-optimizing-cloud-cost`, `eversis-optimizing-frontend`, `eversis-reviewing-frontend`, `eversis-sql-and-database-understanding`, `eversis-task-analysing`, `eversis-technical-context-discovering`, `eversis-transcript-processing`, `eversis-ui-verifying`, `eversis-writing-hooks`.

No skill sets `disable-model-invocation`. Cursor's skill authoring guide uses that flag so a skill loads only when the person names it. Without it, a skill that Cursor has indexed is also eligible for automatic selection from its `description`.

Name length is not the blocker. Cursor's limit is 64 characters. `eversis-add-domain-knowledge` is 28. The creating-skills guide prefers names under 20 because the name becomes the slash command. 28 is valid.

### Why `eversis-add-domain-knowledge` is invisible here

```text
Person types / in this framework checkout
        |
        +-- .cursor/commands/*.md     28 prompt shims; this skill is not a prompt
        |
        +-- .cursor/skills/           directory does not exist in this checkout
        |
        +-- .ai/skills/.../SKILL.md   SSOT exists, user-invocable: true
                                      Cursor does not scan this path
```

On a consumer install with Cursor selected and a populated framework home, the installer already creates `.cursor/skills/eversis-add-domain-knowledge`. Visibility in this framework checkout is a separate gap: the installer does not link skills into the framework repo itself.

### Question 1 (2026-10-13)
#### Where should `eversis-add-domain-knowledge` become visible?
Answered by the person on 2026-10-13: both the framework checkout and installed projects, and both Claude and Cursor. A skill-directory mirror on one host is not the fix.

### Question 2 (2026-10-13)
#### Which other skills should get the same slash-command shim?
Withdrawn. After the EOG vendor checkout, `eversis-add-domain-knowledge` is visible with no command shim. Hosts list the skill from `.cursor/skills/` and `.claude/skills/` once the symlink target exists.

### Question 3 (2026-10-13)
#### Should person-started skills also set `disable-model-invocation: true`?
Deferred. Not required for the menu once the vendor tree is checked out.

## Delta — 2026-10-13 — both hosts, framework and installs

The person corrected the scope: `eversis-add-domain-knowledge` is absent from the menu in the framework checkout and in projects where the framework is installed, in Claude and in Cursor.

The menu entry people can already type, such as `/eversis-implement`, is a generated command file. Both generators read only `.ai/prompts/{public,internal}/`:

- Cursor writes `.cursor/commands/<id>.md` (`adapters/cursor/generate.mjs`)
- Claude writes `.claude/commands/<id>.md` (`adapters/claude/generate-commands.mjs`)

`eversis-add-domain-knowledge` is a skill, not a prompt. Neither generator emits a command for it. The same is true for the other three `user-invocable: true` skills.

Checked local trees:

| Tree | `.cursor/skills` or `.claude/skills` entry | Command shim |
| --- | --- | --- |
| This framework checkout | Neither skills directory exists | No `.cursor/commands/eversis-add-domain-knowledge.md`. No `.claude/commands/` entry either |
| `Documents/repos/agent-collections` | `.claude/skills/` exists and does not contain this skill | Not a command |
| `DAWIS/eog` | 50 symlinks, including this skill; `vendor/agent-collections/` is empty, so the symlink does not resolve | No command file |
| `WUP/sternik-kariery`, `DAWIS/eop`, `DAWIS/user-profile` | This skill directory is not there | No command file |
| `n8n_tenders_automation` | Symlink resolves in both `.cursor/skills/` and `.claude/skills/`; frontmatter is `user-invocable: true` | No `.cursor/commands/` file and no `.claude/commands/` file |

Claude Code does list a project skill from `.claude/skills/<name>/SKILL.md` as `/<name>` when `user-invocable` is not `false`, and it follows a symlinked skill folder ([Claude Code skills](https://code.claude.com/docs/en/skills)). On `n8n_tenders_automation` that file resolves, so a Claude session started in that repo can still fail to match what the person sees if they are looking at the generated command list. Cursor's `/` list in this framework is the 28 prompt shims. A resolving `.cursor/skills/` entry on `n8n_tenders_automation` did not create a `/` command file.

The spelling `user-invokable` (with an a) appears only on `eversis-creating-agents`, `eversis-creating-skills`, `eversis-creating-prompts`, and `eversis-creating-instructions`, all set `false`. `eversis-add-domain-knowledge` uses the field Claude documents, `user-invocable: true`. That flag is not what puts a name into `.cursor/commands/` or `.claude/commands/`.

Fix that covers the reported surfaces: teach both command generators to emit a shim for each skill whose frontmatter sets `user-invocable: true`, using the same vendored-path rewrite Claude already applies to prompt shims. Prompt commands stay as they are. Skills with `user-invocable: false` stay off the menu.

## Delta — 2026-10-13 — EOG vendor checkout makes the skill visible

The person checked out `vendor/agent-collections` in EOG. `eversis-add-domain-knowledge` is then visible. The command-shim recommendation above is withdrawn.

Verified after that checkout:

- Submodule status is ` f5a146cf` (`remotes/origin/HEAD`). The leading space means the worktree matches the pin. The pin did not move.
- `.cursor/skills/eversis-add-domain-knowledge/SKILL.md` and `.claude/skills/eversis-add-domain-knowledge/SKILL.md` both resolve. Frontmatter is still `user-invocable: true`.
- `.cursor/commands/eversis-add-domain-knowledge.md` and `.claude/commands/eversis-add-domain-knowledge.md` are still absent.

Cursor and Claude list this skill from the skills mirror when the vendored `SKILL.md` is on disk. An empty `vendor/agent-collections/` leaves the symlink in place and the menu entry missing. `git submodule update --init` on that pin is the consumer repair.

This framework checkout still has no `.cursor/skills/` and no `.claude/skills/`. Working inside agent-collections itself still has no menu entry for the skill. That is separate from the EOG checkout.

## Human gates

1. ~~Approve this research delta~~ — done. Consumer installs: populate `vendor/agent-collections`. Framework checkout: yes, add a `.cursor/skills/` and `.claude/skills/` mirror (2026-10-13).
2. Approve plan (once written)
3. Implement → Review → Fine

## Changelog

| Date | Author | Change |
|------|--------|--------|
| 2026-09-23 | Agent (eversis-implement) | Initial research: why `eversis-add-domain-knowledge` is absent from Cursor `/` in this checkout, and where install docs should mention the Confluence import skill |
| 2026-10-13 | Agent (eversis-implement) | Delta: inventory of all 50 skills (`true` 4, `false` 13, flag absent 33); no `disable-model-invocation`; docs still deny the consumer `.cursor/skills` mirror; AC-35 excluded as a different story |
| 2026-10-13 | Agent (eversis-implement) | Correction: missing in Claude and Cursor, in this checkout and in installed projects. Cause is no command shim from either generator. Question 1 closed. |
| 2026-10-13 | Agent (eversis-implement) | EOG vendor checkout at pin `f5a146c` makes the skill visible with no command shim. Shim recommendation withdrawn. Framework checkout still has no skills mirror. |
| 2026-10-13 | Person | Approved a `.cursor/skills/` and `.claude/skills/` mirror in this framework repository. |
