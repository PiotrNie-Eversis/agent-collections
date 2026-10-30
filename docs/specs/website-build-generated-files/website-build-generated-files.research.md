# Website build generated-file drift - Analysis Result

## Task Details

| Field | Value |
|---|---|
| Jira ID | (none — local analysis) |
| Title | Stop website `prebuild` from dirtying generated changelog and prompt pages |
| Description | After `cd website && yarn build` / `npm run website:build`, git shows modifications to `website/src/pages/changelog.md`, `website/docs/reference/prompts/public/eversis-create-custom-agent.md`, and `website/docs/reference/prompts/public/eversis-create-custom-instructions.md`. Root cause: generators hardcode GitLab blob branch `main` while this repo and the committed copies use `master`. Chosen fix: option A — point generators at `master` so regeneration is a no-op. |
| Priority | Low (working-tree noise; not a Docusaurus runtime failure) |
| Reporter | Piotr Niemirski |
| Created Date | 2026-09-07 |
| Due Date | — |
| Labels | docs-site, generated-files, prebuild |
| Estimated Effort | Small — two generator string changes plus regenerate/check |

## Business Impact

Maintainers see unexpected diffs after a local docs build and may mix generated URL rewrites into unrelated MRs. The `/changelog` page and prompt reference pages are **committed generated copies**; if they drift from the generators, CI checks (`npm run website:changelog:check`, `npm run sync:website-docs:check`) fail, and every `prebuild` dirties the working tree. The URL rewrite also points GitLab blob links at branch `main` while this repository's default branch is `master`.

## Gathered Information

### Knowledge Base & Task Management Tools
No Jira issue was attached. Analysis is from the user's `/eversis-implement` question and the local git working tree after a website build.

### Codebase
`website/package.json` runs a **prebuild** (and **prestart**) hook: `npm run sync-changelog && npm run sync-docs`. That is why a normal Docusaurus build writes markdown files before compiling.

1. **`scripts/sync-changelog.mjs`** — SSOT is root `CHANGELOG.md`. It writes `website/src/pages/changelog.md` with a generated frontmatter tip, then rewrites `./README.md` links to an absolute GitLab blob URL. The blob base is hardcoded:

   `https://gitlab3.eversis.com/eversis-ai/agent-collections/-/blob/main`

2. **`adapters/website/generate.mjs`** → **`adapters/website/generate-prompts.mjs`** — SSOT is `.ai/prompts/**`. It copies every prompt into `website/docs/reference/prompts/{public,internal}/` and rewrites repo-root links (for example `../../../AGENTS.md`) to GitLab blob/tree URLs with **`/main/`** hardcoded in `rewriteCrossTreeLinks`.

Only files whose **committed** text differs from **fresh generator output** show up in `git status`. After the 2026-09-07 build, that was exactly these three files. The content delta in all three is the same: `/-/blob/master/` → `/-/blob/main/` (changelog also rewrites the generated tip's CHANGELOG.md link).

Commit `035ae13` (`docs: reorganize documentation structure and update links for consistency`) introduced `generate-prompts.mjs` with `/main/` and changed `sync-changelog.mjs` from a GitHub `blob/main` URL to the GitLab `/-/blob/main` URL. Committed generated copies (and many hand-written `website/docs/**` pages) still use `blob/master`.

`git remote` / `origin/HEAD` for this clone: **`origin/master`**. There is no `origin/main` in the local remote-tracking branches (`master`, `mcp-docker`, `ssot`). Regenerating toward `main` therefore does not match the published default branch.

This is **by design that prebuild regenerates committed copies**. It is **not** Docusaurus randomly editing docs. The surprise is stale committed output plus a `master` vs `main` mismatch in the generators.

### Relevant Links
- `website/package.json` — `prebuild` / `prestart` scripts
- `scripts/sync-changelog.mjs` — changelog page generator + `--check`
- `adapters/website/generate.mjs` — prompts generator orchestrator
- `adapters/website/generate-prompts.mjs` — `rewriteCrossTreeLinks` (`/-/${kind}/main/`)
- Root `package.json` — `website:changelog:check`, `sync:website-docs:check`
- `.ai/skills/eversis-creating-prompts/SKILL.md` — generated prompt pages are committed; do not hand-edit them
- `website/docs/main-flow/workflow/repo-docs.md` — changelog SSOT + `prebuild` note

### Relevant Charts & Diagrams
```text
yarn/npm website build
  → prebuild: sync-changelog.mjs     → website/src/pages/changelog.md
  → prebuild: adapters/website/generate.mjs
       → generate-prompts.mjs        → website/docs/reference/prompts/** (from .ai/prompts/**)
  → docusaurus build
```

## Current Implementation Status

### Existing Components
- Changelog sync CLI — `scripts/sync-changelog.mjs` — can be reused; branch name in `GITHUB_BLOB` needs modification if the default branch stays `master`
- Website prompts generator — `adapters/website/generate-prompts.mjs` — can be reused; `/main/` in `rewriteCrossTreeLinks` needs modification if the default branch stays `master`
- Website docs adapter CLI — `adapters/website/generate.mjs` — can be reused; write vs `--check` already implemented
- Drift checks — `npm run website:changelog:check`, `npm run sync:website-docs:check` — can be reused; they will fail today because committed copies still say `master` while generators emit `main`

### Key Files and Directories
- `website/package.json` — `prebuild` always regenerates the files above
- `website/src/pages/changelog.md` — generated; do not hand-edit
- `website/docs/reference/prompts/public/eversis-create-custom-agent.md` — generated copy of `.ai/prompts/public/eversis-create-custom-agent.md`
- `website/docs/reference/prompts/public/eversis-create-custom-instructions.md` — generated copy of `.ai/prompts/public/eversis-create-custom-instructions.md`
- `.ai/prompts/public/eversis-create-custom-*.md` — SSOT still uses relative `../../../AGENTS.md`; the GitLab URL appears only after generation

## Gap Analysis

All missing information and gaps in task description, together with provided answers.

### Question 1
#### Is this analysis-only, or should a follow-up change stop the dirty working tree?
Answer: Stop the dirty working tree. Literal: `stop the dirty working tree;`

### Question 2
#### If a fix is wanted, which branch name should generated GitLab blob/tree URLs use?
Answer: **A.** Change generators to `master` (matches this repo) and leave committed copies as they are (or regenerate; should become a no-op if they already say `master`). Literal: `Q2. A;`

Rejected for this task:

- **B.** Keep generators on `main` and commit the three regenerated files.
- **C.** Discard local diffs and leave generator/`master` mismatch in place.

## Human gates

Numbered list of every human-approval gate this task passes through, in order. Strike through a gate once closed, and quote the user's literal closing phrase — do not paraphrase — as evidence:

1. ~~Approve research~~ — done (`Gap Analysis
Q1. stop the dirty working tree;
Q2. A;

Update the research and make the plan;`)
2. Approve plan (once written)
3. Implement → Review → Fine

## Changelog

| Date | Change Description |
| --- | --- |
| 2026-09-07 | Initial analysis: `prebuild` regenerates committed copies; delta is `blob/master` → `blob/main`. |
| 2026-09-07 | DELTA: Q1/Q2 locked — stop dirty tree via option A (generators use `master`). Scope is now a fix, not analysis-only. |
