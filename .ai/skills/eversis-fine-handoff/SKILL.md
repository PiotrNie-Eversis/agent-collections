---
name: eversis-fine-handoff
description: "Mandatory QA comment draft after Fine (Implement handoff). Agent outputs a labeled draft; human approves or rewrites; optionally post to Jira via Atlassian MCP only after explicit human approval. No file/line refs in Main Changes. Not a full QA workflow — use eversis-qa-workflow for test plans and regression."
---

# Fine Handoff — QA Comment Draft

## Objective

Generate a clear, human-friendly summary for the QA department in English. This skill **must** be executed in the **same turn** the orchestrating agent declares **"Fine"** (implementation complete). The output is always a **labeled draft** — the human reviews, edits, and decides how to publish it.

This skill covers **Implement handoff only** (one Jira comment draft). For full test planning, regression, or AC gap analysis, use **`eversis-qa-workflow`** and related QA skills — do not expand this draft into a full test plan.

## When to run

**Mandatory.** When the Engineering Manager (or any orchestrating role) declares **"Fine"**, produce the full QA comment draft before treating the session as closed. Do not wait to be asked.

Prefer loading this skill via the **`eversis-collections` MCP** (`eversis_skills_get`) when the server is running; otherwise follow this file directly.

## Two-phase human gate

### Phase 1 — Draft output (Fine turn)

- Begin the comment with a clearly labeled header: `**Draft QA comment — review before posting to Jira**`
- Output the full comment body (structure below) in the same response.
- Do **not** post to Jira in this turn, even if you have the Atlassian MCP available.

### Phase 2 — Publishing (later turn, explicit only)

- Only call `addCommentToJiraIssue` (Atlassian MCP) when the human **explicitly** approves posting (e.g. "post this", "add to ticket PROJ-123", "looks good, send it").
- Use the **approved or human-edited** body as `commentBody` — never the unreviewed draft.
- Required args: `issueIdOrKey` (e.g. `TASK-396`), `commentBody` (markdown), `cloudId` (from `getAccessibleAtlassianResources` or the ticket URL the human provides — do not invent).
- Set `contentFormat: "markdown"` when the server supports it.
- If the issue key is ambiguous, confirm with the human before posting.

## Readability rules

These rules exist because QA engineers are **not** reading the codebase. They need to understand the change from the outside.

### Main Changes — write for a non-developer

- Describe **what the user experiences** and **what changed in behavior**, not what the code does internally.
- Use **Before / After** or **Given / When / Then** framing for behavior changes (especially helpful for auth flows, error states, and redirects).
- When you must mention a technical term (OAuth error codes, HTTP status codes, etc.), follow it immediately with a **one-line plain-language gloss** in parentheses: `login_required (the user must sign in again)`.
- **Order**: lead with the most user-visible outcomes; push edge cases and error handling to the bottom.
- Keep bullet points short — one clear idea per bullet, written as a complete thought.

### Forbidden in Main Changes

- File paths, function names, class names, line numbers.
- Code snippets.
- Internal implementation notes.

Keep all technical depth in **Automation & Technical Notes** only.

## Output structure

```
**Draft QA comment — review before posting to Jira**

---

### 📝 QA Summary

**Task Context:** <one sentence describing the feature or fix being shipped>

**Main Changes:**
- <What changed for users / what they will see differently>
- ...

---

**✅ Verification List:**

**Manual Testing:**
- [ ] <Step to reproduce or verify the change>
- [ ] ...

**Automation & Technical Notes:**
- **Selectors**: <data-testid or CSS selectors relevant to the change>
- **API**: <endpoints added or changed, with method and expected response>
- **Error Handling**: <relevant error codes, status codes, or messages>
```

## Publishing

After the human approves or rewrites the draft, they may either:

- **Copy-paste** into the Jira issue directly, or
- **Instruct the agent** to post via Atlassian MCP: "Post the comment above to TASK-396 on eversis.atlassian.net."

The agent then calls `addCommentToJiraIssue` with the **approved** body. It never posts automatically or in the same turn as the draft.

## Example

See **`fine-handoff.example.md`** in this folder for a full few-shot template.
