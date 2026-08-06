---
name: eversis-writing-repo-documentation
description: Authors and updates repository documentation — README, CHANGELOG, in-repo docs, and the published documentation site. Covers structure, docs-site build expectations, and the write-vs-review boundary. Use when creating or editing documentation content without touching product code.
user-invocable: false
---

# Writing Repository Documentation

Owns **repository** documentation (not Word `.docx`): authors clear, accurate, well-structured content and keeps the documentation set internally consistent. README, CHANGELOG, `docs/`, `docs/specs/`, and the published documentation site (`website/` in this framework) are the targets of that ownership.

**Not BA Docs (Word):** For regulated or release `.docx` maintenance, use **`eversis-ba-docs-planner`** / **`eversis-ba-docs-writer`** and MCP `.docx` chapter tools — never this skill.

## Core Design Principles

**Documentation scope.** This skill owns repository documentation broadly — content only, never product code. It never writes or edits application source, configuration logic, tests, or infrastructure. When documentation must describe code behavior, read the code to describe it accurately, but do not modify it. If documentation cannot be written without first changing code, stop and report the dependency instead of editing code.

**Accuracy over volume.** Verify every factual claim — file paths, command names, option flags, version numbers, link targets — against the repository before writing. Prefer a short, correct page over a long, speculative one.

**Structure mirrors neighbors.** New pages mirror sibling files in the same directory: heading order, frontmatter fields, link style, and section naming.

**Links must resolve.** Internal documentation links must resolve. A broken internal link is a build failure, not a cosmetic issue. Only link to pages that exist or that you create in the same task.

## Writing for Busy Readers

- Front-load the conclusion or most important information.
- Use headings, lists, and tables only when they improve navigation.
- Write short sentences, plain words, one idea per paragraph, active voice.
- State purpose and relevance early; end with clear next steps when helpful.

## Documentation Targets

| Target | Location | Conventions |
| --- | --- | --- |
| README | repo root `README.md` and nested `README.md` | Plain Markdown; match existing tone |
| CHANGELOG | `CHANGELOG.md` | Append in existing format; do not rewrite history |
| In-repo docs | `docs/`, `docs/specs/`, `docs/context/` | Plain Markdown; follow neighbors |
| Documentation site | `website/docs/` (Docusaurus) | Frontmatter (`sidebar_position`, `title`); links must pass validate + build |

## Workflow

```text
Documentation progress:
- [ ] Step 1: Identify the documentation target and audience
- [ ] Step 2: Gather accurate source facts
- [ ] Step 3: Match the neighboring structure
- [ ] Step 4: Write or update the content
- [ ] Step 5: Validate links and the docs build
```

**Step 1: Identify the documentation target and audience.** Determine which target type the task touches, who the reader is, and what they need to accomplish. Confirm the change is documentation-only.

**Step 2: Gather accurate source facts.** Read relevant code, configuration, and existing documentation. Do not document behavior you have not confirmed.

**Step 3: Match the neighboring structure.** Open sibling pages in the same directory and mirror frontmatter, heading order, and link conventions.

**Step 4: Write or update the content.** Keep edits scoped to the documentation files named in the task. Do not touch product code, tests, or infrastructure. When working from `*.plan.md`, update progress and Definition of Done checkboxes only for the delegated scope.

**Step 5: Validate links and the documentation build.** Run quality commands from **`eversis-project-stack.mdc`** (or the consumer project's stack rule). For **cursor-collections** and repos mirroring it:

```bash
node scripts/validate-cursor-markdown-links.mjs --context=source
cd website && npm run build
```

For README, CHANGELOG, and `docs/` without a site, verify referenced paths manually. Fix issues before handing off.

## Write vs. Review

This skill writes and updates documentation. It does not perform formal code review or design review. When a documentation change depends on a product-code change, report the dependency to the Engineering Manager rather than making the code change.

## Connected Skills

- `eversis-technical-context-discovering` — confirm project conventions and documentation patterns before writing
- `eversis-codebase-analysing` — read code or artifacts the documentation must describe accurately
- `eversis-creating-instructions` — keep declarative rules in `.mdc` / `AGENTS.md` rather than narrative docs when appropriate
