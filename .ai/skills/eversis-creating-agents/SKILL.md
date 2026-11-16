---
name: eversis-creating-agents
description: "Create Agent Collections role rules under .ai/rules/ (neutral Markdown). Cursor adapters may also emit .cursor/rules/eversis-*.mdc packaging. Maps legacy agent-identity content into rule bodies; use with skills and .ai/prompts. Not .github/agents."
user-invocable: false
---

# Creating agents (role rules)

Creates well-structured **role rules** that define **who/when** behavior for Agent Collections. Enforces separation of concerns: **rules** = who/when, **skills** = how, **prompts** = runnable workflow text under **`.ai/prompts/`**.

> **SSOT:** Prefer **`.ai/rules/`** (neutral Markdown). A **Cursor adapter** may generate **`.cursor/rules/eversis-*.mdc`** (YAML `description` / `globs` / `alwaysApply`) for Cursor UX. This repository does not ship `.github/agents/*.agent.md`.

## Core Design Principles

<principles>
<separation-of-concerns>
A **role rule** defines WHO the model should “be” when the rule applies. It must NOT define HOW a full multi-step workflow runs end-to-end (that lives in **skills** and **prompts**).

- **Rule / role** = behavior, responsibilities, and boundaries (`.ai/rules/`; adapters may package as `.mdc`)
- **Skills** = reusable workflows (`SKILL.md` under `.ai/skills/`)
- **Prompts** = markdown under `.ai/prompts/public/` and `internal/`
</separation-of-concerns>

<xml-syntax>
All structured content inside the agent body MUST use XML-like tags for explicit structure. This ensures reliable parsing across all LLM model tiers.

Use Markdown only for inline formatting (bold, code blocks, tables, lists) within XML sections.
</xml-syntax>

<minimal-scope>
An agent should only describe what is necessary for its specific role. Avoid duplicating instructions that belong in skills, **AGENTS.md**, or other rules under **`.ai/rules/`**.
</minimal-scope>
</principles>

## Creation Process

Use the checklist below and track your progress:

```
Creation progress:
- [ ] Step 1: Define the agent's purpose
- [ ] Step 2: Write the agent role and responsibilities
- [ ] Step 3: Determine tools and write tool usage guidelines
- [ ] Step 4: Determine skills and write skills usage guidelines
- [ ] Step 5: Configure handoffs (if applicable)
- [ ] Step 6: Add domain standards (if applicable)
- [ ] Step 7: Add constraints (if applicable)
- [ ] Step 8: Assemble the agent file using the template
- [ ] Step 9: Register the rule in the adapter maps
- [ ] Step 10: Validate the agent file
```

**Step 1: Define the agent's purpose**

Answer these questions before writing anything:
- What specific role does this agent fulfill? (e.g., architect, reviewer, engineer)
- What problems does it solve?
- What is the agent's primary focus area?
- Which other agents does it collaborate with?
- What makes this agent distinct from existing agents?

**Step 2: Write the agent role and responsibilities**

Write the `<agent-role>` section. This is the core of the agent. It must describe:
- A clear role statement starting with "Role: You are..."
- The agent's primary responsibilities and focus areas
- The agent's behavioral guidelines (how it approaches work)
- Skip-level instructions for skill and tool usage (always check skills first, always use tools to gather context)

Follow the pattern from existing agents. Keep the role focused. Do not include workflow-specific steps — those belong in skills.

**Step 3: Tools and execution**

In Cursor, tool access is **not** configured in the rule file the same way as legacy Copilot `tools:` arrays. Instead, document **when to use MCP, terminal, or repo search** inside `<tool-usage>` as *behavioral guidance* for the Agent. Be explicit: read-only review roles should avoid destructive commands.

**Step 4: Determine skills and write skills usage guidelines**

Review available skills and select those the agent should load:
- For each skill, write a short entry explaining WHEN to use it
- Use the format: `skill-name` - brief description of when to use it

Do not duplicate skill content in the agent file. The agent only references skills.

**Step 5: Handoffs (if applicable)**

Describe how this role **passes work** to another (e.g. “after research, stop for approval before plan”). In Cursor, handoffs are **narrative** in the rule and in public prompts — not `handoffs` YAML in `.mdc` (legacy Copilot). Link to the next prompt or rule with file paths.

**Step 6: Add domain standards (if applicable)**

If the agent's role requires enforcing domain-specific standards (e.g., testing conventions, security rules, UI patterns), add a `<domain-standards>` section. This section is optional and should only appear when the agent genuinely needs domain-specific rules that are NOT covered by skills.

**Step 7: Add constraints (if applicable)**

If the agent has specific limitations or anti-patterns to avoid, add a `<constraints>` section. Common constraints include:
- What the agent must NOT produce (e.g., "don't create implementation plans")
- Scope boundaries (e.g., "don't provide deployment instructions")
- Delegation rules (e.g., "escalate architectural decisions to the architect")

**Step 8: Assemble the rule file using the template**

Use `./agent.template.md` as a **structural** guide: produce **`.ai/rules/<area>/<role>.md`** (neutral Markdown, no frontmatter, starting with a `# <Role>` heading), for example `.ai/rules/orchestration/agent-core.md` or `.ai/rules/architecture/code-reviewer.md`. Do **not** add an `eversis-` prefix to the file name: the adapters add it on emit (rule id `eversis-<role>`, outputs such as `.cursor/rules/eversis-<role>.mdc`). Do **not** write `.cursor/rules/*.mdc` or `.github/agents/` by hand.

**Step 9: Register the rule in the adapter maps**

A rule under `.ai/rules/` reaches a host only through its `rule-map.yaml`. Packaging metadata lives in the maps, not in the rule file. Add one entry with the same `id` (`eversis-<role>`) and `source` (`.ai/rules/<area>/<role>.md`) to all three maps, choosing the activation per host:

| Map | Fields | Activation choice |
|---|---|---|
| `adapters/cursor/rule-map.yaml` | `id`, `source`, `output: .cursor/rules/eversis-<role>.mdc`, `description` | Always: `alwaysApply: true` (keep rare). Globs: `globs:` as a YAML list of patterns. On demand: `globs: []` and `alwaysApply: false`. |
| `adapters/claude/rule-map.yaml` | `id`, `source` only (Cursor packaging fields are rejected) | Derived: a section in `CLAUDE.md`, or `.claude/rules/eversis-<role>.md` with `paths:` when the Cursor entry has non-empty `globs`. |
| `adapters/pi/rule-map.yaml` | `id`, `source`, `target`; with `target: skill` also `skill_id` and `description` (at most 1024 characters) | On demand: `target: skill` with `skill_id: eversis-rule-<role>` (kebab-case, at most 64 characters, unique, and not the name of an `.ai/skills/eversis-*` directory), written as a role skill under `.pi/skills/`; optional `ui_note`, `review_context_note`, `process_bundle: true` (added with the process rules after an `eversis-*` command or while a plan is active). Or `target: none`: Pi emits nothing for the rule; an optional `skill_id` names the existing framework skill that already carries the content. |

Then run `npm run sync:adapters` and `npm run sync:adapters:check`.

The sync check compares generated files with the maps; it does **not** report a rule file that no map lists. A rule left out of the maps is silently not emitted, so confirm the output exists (Step 10).

**Step 10: Validate the agent file**

Verify the agent file against this checklist:
- [ ] The file is `.ai/rules/<area>/<role>.md` without an `eversis-` prefix and without frontmatter
- [ ] The Cursor map entry has a concise `description` and exactly one activation choice (`alwaysApply: true`, a `globs` list, or `globs: []` with `alwaysApply: false`)
- [ ] All three `rule-map.yaml` files list the rule with the same `id` and `source`
- [ ] `npm run sync:adapters:check` passes
- [ ] The rule appears in every host output: `.cursor/rules/eversis-<role>.mdc`; a `## eversis-<role>` section in `CLAUDE.md` or `.claude/rules/eversis-<role>.md`; and, for Pi with `target: skill`, `.pi/skills/eversis-rule-<role>/SKILL.md` (check with `node adapters/sync.mjs --agents cursor,claude,pi --out <tmp-dir>`)
- [ ] Tool usage is documented in `<tool-usage>` (behavioral, not a Copilot tool manifest)
- [ ] All skills referenced in `<skills-usage>` are existing skills in the project
- [ ] XML-like tags are properly opened and closed
- [ ] No workflow-specific instructions are embedded (those belong in skills)
- [ ] No coding standards are embedded (those belong in `AGENTS.md` or the project stack policy, `eversis-project-stack`)
- [ ] Role is focused and distinct from existing rules
- [ ] Handoffs (if present) name the next **prompt** or **rule** to use

## Rule file structure

### Frontmatter (Cursor)

These fields are set in the rule's entry in `adapters/cursor/rule-map.yaml` (Step 9); the Cursor adapter writes them into the generated `.mdc` frontmatter.

| Field | Required | Description |
|---|---|---|
| `description` | **Yes** | Short description; used for rule pickers and context. |
| `globs` | No | File patterns when the rule is auto-attached. Use a **YAML list** (one pattern per line, e.g. `- "**/*.tsx"`). |
| `alwaysApply` | No | `true` for always-on core behavior (use sparingly). |

**Three activation modes — choose one per rule:**

| Mode | When | Example rules |
|------|------|---------------|
| `alwaysApply: true` | Core behaviors present in every session. Keep minimal. | `eversis-agent-core.mdc`, `eversis-project-stack.mdc` |
| `globs: [...]` (YAML list) | Technology or layer-specific standards; activates when matching files are open. Prefix with `**/` for recursive matching. | `eversis-accessibility.mdc` |
| `globs: []`, `alwaysApply: false` | Role rules attached on demand with `@` in a prompt or Chat. | `eversis-engineering-manager.mdc`, `eversis-code-reviewer.mdc` |

### Body Sections

| Section | Required | Purpose |
|---|---|---|
| `<agent-role>` | **Yes** | Role definition, responsibilities, behavioral guidelines. |
| `<skills-usage>` | **Yes** | List of skills the agent uses with guidance for each. |
| `<tool-usage>` | **Yes** | Tool access rules and usage guidelines per tool. |
| `<domain-standards>` | No | Domain-specific standards and rules the agent enforces. |
| `<collaboration>` | No | Interaction patterns with other agents or team members. |
| `<constraints>` | No | Explicit limitations and anti-patterns for the agent. |
| `<output-format>` | No | Expected structure or format of the agent's deliverables. |

## XML Syntax Guidelines

All body content in the agent file must use XML-like tags for structure. Rules:

1. Every section uses a matching opening and closing tag: `<section-name>` ... `</section-name>`
2. Tags use lowercase-kebab-case naming
3. Nesting is allowed for sub-sections: `<tool>` inside `<tool-usage>`
4. Markdown formatting (bold, lists, tables, code blocks) is used inside XML tags for content
5. Avoid XML attributes for structural content — use nested tags or Markdown content instead. Exception: identifier attributes (e.g., `<tool name="...">`) are acceptable when they improve readability.

Example structure:
```xml
<agent-role>
Role: You are a...
</agent-role>

<tool-usage>
<tool name="context7">
- **MUST use when**: ...
- **SHOULD NOT use for**: ...
</tool>
</tool-usage>
```

## Connected Skills

- `eversis-creating-prompts` - to understand how prompts reference agents and ensure agents don't overlap with prompt responsibilities
- `eversis-creating-skills` - to ensure this skill's own structure follows the canonical skill creation requirements
- `eversis-technical-context-discovering` - to understand existing agent patterns in the project before creating a new one
- `eversis-codebase-analysing` - to analyze existing agents and identify patterns to follow
- `eversis-creating-instructions` - to understand when coding standards and project conventions belong in instruction files rather than agent definitions
