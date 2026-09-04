---
sidebar_position: 15
title: Jira Task Formatting
---

# Jira Task Formatting

**Folder:** `.cursor/skills/eversis-jira-task-formatting/`  
**Used by:** Business Analyst

Transforms extracted epics and user stories into Jira-ready format following a benchmark template. Handles field mapping, Jira markdown compatibility, two-gate user review, and Jira issue creation via Atlassian tools. Also supports importing existing Jira issues for local iteration.

## Process

### Step 1: Load Template and Tasks

Load the benchmark template (`jira-task.example.md`) and the extracted tasks document (`extracted-tasks.md`).

### Step 2: Format Epics

For each epic, create a Jira-ready entry with:
- Summary (title) following naming conventions.
- Structured description with business overview, value statement, and success metrics.
- Acceptance criteria and labels.
- Priority mapping (Critical → Highest, High → High, etc.).

### Step 3: Format Stories

For each story, create a Jira-ready entry with:
- Summary following naming conventions.
- Structured description with context, user story format, requirements, and technical notes.
- Acceptance criteria as Jira-compatible checklists.
- Sizing guidance (Small / Medium / Large).
- Parent epic reference and labels.

### Step 4: Validate Completeness

Cross-check all tasks against the benchmark template for required fields, structure, and consistency.

### Step 5: Formatting Review (Gate 2 - Part 1)

Present formatted output to the user. Review any changes made during formatting.

### Step 6: Save Output

Save the Jira-ready tasks to `docs/specs/<workshop-name>/jira-tasks.md` (or `specifications/<workshop-name>/`).

### Step 7: Push Approval (Gate 2 - Part 2)

Confirm target Jira project, get explicit approval, then create/update issues in Jira.

### Step 8: Post-push verification

After a successful sync, read back created or updated Jira issues via Atlassian MCP. Verify summary, parent epic linkage, acceptance criteria, description sections, and status against local `jira-tasks.md`. Surface mismatches before claiming the push is verified.

### Step 9: Baseline refresh

When verification succeeds, refresh `docs/context/<project>/task-baseline.md` (see `task-baseline.example.md` in the skill folder):

| When to refresh | What happens |
| --- | --- |
| After successful workshop push | Merge verified epics/stories by Jira Key; index session at `docs/specs/<workshop-name>/` |
| After Import Mode | Optional — seed or update baseline from fetched Jira state |
| Before next workshop | Load existing baseline during intent brief and extraction for overlap checks |

**Merge rules:** Jira Key is primary identity; replace same-key rows with latest verified content; preserve protected statuses (Done, Cancelled, PO APPROVE) as read from Jira.

## Import Mode

An alternative entry point for working with existing Jira backlogs:

1. **Identify target** — Jira project key, specific epic keys, or JQL query.
2. **Fetch issues** — Pull epics and their child stories from Jira.
3. **Map to template** — Convert Jira fields to the benchmark format.
4. **Generate local file** — Create `jira-tasks.md` with Jira keys pre-populated.
5. **User review** — Present imported tasks for validation.

After import, changes can be pushed back to Jira individually or in batch.

## Jira Markdown Compatibility

When creating issues in Jira, the skill converts standard markdown to Jira format:

| Standard Markdown | Jira Format |
|---|---|
| `## Heading` | `h2. Heading` |
| `**bold**` | `*bold*` |
| `*italic*` | `_italic_` |
| `- item` | `* item` |
| `1. item` | `# item` |
| `` `code` `` | `{code}...{code}` |

:::note
The local markdown file uses standard markdown formatting. Jira-specific formatting is applied only when creating the actual issues.
:::

## Per-Change Modification Flow

When the user modifies a specific task outside the main workflow:

1. Update the local `jira-tasks.md` first.
2. Ask the user whether to push the change to Jira now.
3. If yes, update the specific Jira issue using its key.
4. If no, the change remains local until the next batch push.

## Protected Status Guard

Tasks with a protected status (**Done**, **Cancelled**, or **PO APPROVE**) cannot be modified. The guard is enforced at every processing step:

- **Formatting** — Protected tasks are preserved exactly as imported. No reformatting, rewriting, or field changes. Marked with a `🔒` indicator.
- **Validation** — Completeness checks are skipped for protected tasks; their content is not subject to benchmark compliance.
- **User Review** — Protected tasks are not flagged for user attention; their fields are read-only.
- **Per-Change Modifications** — If a user requests changes to a protected task, the agent informs them the task cannot be modified and suggests updating the status in Jira first, then re-importing.
- **Import** — After mapping fields, each imported task's status is checked. Protected tasks are marked as read-only with a `🔒` indicator and preserved as-is.

## Connected Skills

- `eversis-task-extracting` — Provides the extracted tasks used as input for formatting.
- `eversis-task-quality-reviewing` — Refines the task list before formatting.
