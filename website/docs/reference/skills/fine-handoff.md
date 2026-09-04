---
sidebar_position: 33
title: Fine Handoff
---

# Fine Handoff (QA comment draft)

**Skill:** `eversis-fine-handoff`  
**Folder:** `.ai/skills/eversis-fine-handoff/`

This skill bridges communication between developers and Quality Assurance at the **end of Implement**. It generates a clear, English-language summary of changes written specifically for people who will **test the feature**, not read the code.

The skill name reflects **when** it runs (status **Fine**), not the full QA practice layer. For test plans, regression, and formal AC verification, use **[`@eversis-qa-workflow`](../../main-flow/workflow/qa-workflow)** and its supporting skills.

## How it fits the workflow

When the Engineering Manager declares **Fine** (implementation complete), the agent **must** produce the QA comment draft **in the same response** — it is not optional. The draft is labeled clearly so you know it has not yet been posted.

The user story looks like this:

1. **Agent declares Fine** → outputs a labeled draft QA comment.
2. **You review** the draft, edit it if needed, or replace it with your own text.
3. **You publish** — either copy-paste into Jira, or tell the agent to post it via Atlassian MCP.

## Readability expectations

The **Main Changes** section is written for QA engineers and non-developers. It describes what the user sees and experiences, not what the code does. Technical depth (selectors, API endpoints, error codes) is reserved for the **Automation & Technical Notes** section.

Good bullet: "After a failed sign-in, the user is now redirected to the login page and returned to their original destination afterwards."

Not useful: "Authorization error responses from the provider are handled explicitly and are no longer treated the same as a normal post-logout redirect without a code."

## Publishing to Jira

### Option A — Copy-paste

Copy the approved text from the draft and paste it into the Jira issue's **Add comment** field.

### Option B — Post via Atlassian MCP

If you have the Atlassian MCP configured in your workspace, you can ask the agent to post after you have approved the text:

> Post the comment above to TASK-396 on eversis.atlassian.net.

The agent then calls `addCommentToJiraIssue` with:
- `issueIdOrKey` — the ticket key you specify (e.g. `TASK-396`)
- `commentBody` — the **approved** text, verbatim
- `cloudId` — resolved from `getAccessibleAtlassianResources` or derived from the site URL you provide (the agent will not invent this)
- `contentFormat: "markdown"` when supported

The agent never posts in the **same turn** as declaring Fine, and never posts without your explicit instruction.

## Why English?

To keep international tools such as Jira consistent and to ensure all stakeholders can follow verification steps.

## Rules for the Agent

- Write Main Changes for a non-developer: describe behavior, not implementation.
- No file paths, function names, or line numbers in Main Changes.
- Use Before / After or Given / When / Then framing for behavior changes.
- If a technical term is unavoidable, add a plain-language gloss in parentheses.
- Keep technical depth in Automation & Technical Notes only.

## Example output

Below is an illustrative comment for a hypothetical MFA-in-settings task. An actual run should match this shape: **Main Changes** (behavioral, no file paths) plus a **Verification List** (manual steps and automation notes).

### 📝 QA Summary

**Task Context:** Implementation of multi-factor authentication (MFA) toggle in user settings.

**Main Changes:**
- Added a new section in User Settings to manage security preferences.
- Implemented a toggle switch to enable/disable MFA via Email.
- Updated the login flow to challenge the user for a code if MFA is active.
- Added descriptive error messages for invalid or expired MFA codes.

---

**✅ Verification List:**

**Manual Testing:**
- [ ] Navigate to Settings -> Security and verify the MFA toggle is visible.
- [ ] Enable MFA and logout. Verify that the system asks for an email code during the next login.
- [ ] Test the "Resend Code" functionality to ensure it triggers a new email.
- [ ] Verify that disabling MFA removes the extra step during login.

**Automation & Technical Notes:**
- **Selectors**: The MFA toggle can be targeted via `data-testid="mfa-toggle-switch"`.
- **API**: New endpoint `POST /api/v1/auth/mfa/verify` handles code validation.
- **Error Handling**: Invalid codes return a `422 Unprocessable Entity` with a `code_expired` or `code_invalid` reason.

The canonical few-shot template (including a readability contrast example for auth flows) is [`fine-handoff.example.md`](https://gitlab3.eversis.com/eversis-ai/agent-collections/-/blob/main/.ai/skills/eversis-fine-handoff/fine-handoff.example.md) under `.ai/skills/eversis-fine-handoff/`.
