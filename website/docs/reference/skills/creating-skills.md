---
sidebar_position: 17
title: Creating Skills
---

# Creating Skills

**Folder:** `.cursor/skills/eversis-creating-skills/`
**Used by:** Framework maintainers (customization track)

Provides naming conventions (gerund form), description guidelines, body structure, progressive disclosure patterns, templates, and validation checklists for creating new skills (`SKILL.md`).

## Core Design Principles

- **Conciseness** — The context window is a shared resource. Only add context the LLM doesn't already have.
- **Progressive disclosure** — Discovery tier (~100 tokens): name + description. Activation tier (&lt;5000 tokens): full SKILL.md body. Resource tier (on demand): templates, examples.
- **Separation of concerns** — A skill defines HOW to perform a task. It must NOT define WHO the agent is (agent territory) or WHAT triggers the workflow (prompt territory).

## Naming Conventions

- Skill directories use gerund form: `eversis-<gerund-subject>/` (e.g., `eversis-code-reviewing/`, `eversis-creating-prompts/`)
- The `name` field in SKILL.md frontmatter must match the directory name
- The `eversis-` prefix identifies topic packages in **Agent Collections** (this monorepo)

## Skill Folder Structure

```
eversis-<gerund-subject>/
├── SKILL.md            # Main skill file (required)
├── <name>.example.md   # Example output (optional)
└── <name>.template.md  # Output template (optional)
```

## Validation Checklist

- Directory name uses gerund form with `eversis-` prefix
- `name` field in frontmatter matches directory name
- Description includes WHAT, WHEN, and **Do NOT use when** (domain/stack skills)
- Body includes **When to use / When NOT to use** for domain-specific skills
- Body stays under 5000 tokens
- No personality or behavioral content (agent territory)
- No project-specific conventions (instructions territory)

## Connected Skills

- `eversis-creating-agents` — For creating agents that load this skill.
- `eversis-creating-prompts` — For creating prompts that trigger workflows using this skill.
