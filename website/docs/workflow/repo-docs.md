---
sidebar_position: 7
title: Repo Docs
---

# Repo Docs

Use this workflow when you need to **author or update repository documentation** after implementation — README, CHANGELOG, `docs/`, or the published documentation site (`website/docs/`). This is **markdown in git**, not Word `.docx`.

It is typically **delegated from `@eversis-implement`** when the implementation plan includes a documentation-only task. You can also run **`@eversis-repo-docs-writer`** standalone with an explicit file list or plan section.

:::tip How this differs from Business Manager Docs
**[Business Manager Docs](./business-manager-docs)** updates **Word `.docx`** files via MCP chapter tools after a Jira release.

**Repo Docs** updates **repository markdown** — README, CHANGELOG, `docs/specs/`, Docusaurus pages — with link validation and docs build. **No** `.docx` tools.
:::

## When to Use It

- The implementation plan includes a task to document delivered changes in README, CHANGELOG, or the docs site.
- A feature shipped and readers need updated setup, workflow, or integration pages.
- You need consistent post-Implement documentation without mixing Word release docs.

## Architecture

| Piece | Role |
| ----- | ---- |
| **`@eversis-implement`** | Engineering Manager routes documentation-only plan tasks to Repo Docs writer |
| **`@eversis-repo-docs-writer`** | Public prompt — bounded documentation task + validation |
| **`eversis-writing-repo-documentation`** | Skill — structure, accuracy, build expectations, exclusions |
| **Quality gates** | `validate-cursor-links` + `npm run build` (when `website/` changes) per `eversis-project-stack.mdc` |

## Documentation channels (Word vs Repo)

| Channel | Prompts | Format | Typical trigger |
| ------- | ------- | ------ | ---------------- |
| **BA Docs (Word)** | `@eversis-ba-docs-planner` → `@eversis-ba-docs-writer` | `.docx` | Jira release + Confluence rules |
| **Repo Docs** | `@eversis-repo-docs-writer` (or EM delegate) | README, CHANGELOG, `docs/`, `website/docs` | Plan task after Implement |

## Command Sequence

```text
1️⃣ @eversis-implement <task>
   ↳ Plan includes documentation task (README / CHANGELOG / website/docs)
   ↳ EM delegates to Repo Docs writer with task slice + Technical Context

2️⃣ @eversis-repo-docs-writer (delegated or standalone)
   ↳ 📖 Gather facts from code and existing docs
   ↳ ✍️ Update named markdown files only
   ↳ ✅ validate-cursor-links + npm run build (when applicable)

3️⃣ Gate — Human review
   ↳ 📖 Review doc diffs for accuracy and tone
   ↳ ✅ Merge when satisfied
```

## Workflow Diagram

```
┌─────────────────────────────┐
│  @eversis-implement         │
│  (plan with doc task)       │
└──────────┬──────────────────┘
           ▼
┌─────────────────────────────┐
│  Repo Docs Writer           │
│  @eversis-repo-docs-writer  │
└──────────┬──────────────────┘
           ▼
┌─────────────────────────────┐
│  Validate + build           │
│  (links / Docusaurus)       │
└──────────┬──────────────────┘
           ▼
┌─────────────────────────────┐
│  ★ Human reviews markdown   │
└─────────────────────────────┘
```

## Connecting to Other Flows

- **Code delivery** — [`eversis-implement`](./standard-flow) produces the changes Repo Docs describes.
- **Word release docs** — separate playbook: [Business Manager Docs](./business-manager-docs).
- **Code review** — `@eversis-review` validates product code; Repo Docs does not replace review.

:::warning Important
Repo Docs writer **never** edits product code. If documentation cannot be written without a code change, report the dependency to the Engineering Manager instead of expanding scope.
:::
