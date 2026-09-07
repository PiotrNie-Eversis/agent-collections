# Fine handoff — QA comment draft

## Objective

When implementation is declared **Fine**, produce a clear, human-friendly QA summary in English. The output is always a **labeled draft** — the human reviews, edits, and decides how to publish it.

This contract covers **Implement handoff only** (one ticket comment draft). For full test planning or regression, use the QA workflow prompt/skill (`eversis-qa-workflow`) — do not expand this draft into a full test plan.

The detailed skill package is **`eversis-fine-handoff`** (body lands under `.ai/skills/` in TASK-520). Until then, follow this contract and load the skill via MCP or adapter-resolved path when available.

## When to run

**Mandatory.** When the Engineering Manager (or any orchestrating role) declares **Fine**, produce the full QA comment draft in the **same turn** before treating the session as closed. Do not wait to be asked.

## Two-phase human gate

### Phase 1 — Draft output (Fine turn)

- Begin with the header: `**Draft QA comment — review before posting to Jira**`
- Output the full comment body (structure below) in the same response.
- Do **not** post to the issue tracker in that turn, even if an issue-tracker MCP is available.

### Phase 2 — Publishing (later turn, explicit only)

- Publish only when the human **explicitly** approves (e.g. “post this”, “add to ticket PROJ-123”).
- Use the **approved or human-edited** body — never the unreviewed draft blindly if the human changed it.
- Confirm the issue key if ambiguous.

## Optional second draft — domain-knowledge promotion

When `eversis-promote-domain-knowledge` (see that skill) determines the task produced a durable, cross-task fact (a convention, a confirmed business rule, a reusable integration pattern — not a one-off implementation detail), add a **second, independent draft** in the same Fine turn, alongside the QA comment draft:

- Begin it with its own header: `**Draft: domain-knowledge promotion to docs/context/<project>/ — approve before writing**`
- Show the proposed file path, the frontmatter, and the content to be written.
- This draft has its **own** approval — approving or rejecting the QA comment draft has no effect on this one, and vice versa. Only write to `docs/context/<project>/` after this specific draft is explicitly approved.
- If `eversis-promote-domain-knowledge` finds nothing worth promoting for this task, do not add this draft at all — the QA comment draft alone is a complete, valid Fine turn (this is the common case, not an exception).
- Publication mechanism once approved: GitLab REST API (Branches → Commits with multiple file actions → Merge Requests), never a local checkout of `domain-context` (see `eversis-promote-domain-knowledge`).

## Readability rules

QA readers are **not** reading the codebase. They need the change from the outside.

### Main Changes — write for a non-developer

- Describe **what users experience** and **what changed in behavior**, not internal implementation.
- Prefer Before/After or Given/When/Then for behavior changes.
- Gloss technical terms in plain language when needed.
- Lead with the most user-visible outcomes.

### Forbidden in Main Changes

- File paths, function names, class names, line numbers
- Code snippets
- Internal implementation notes

Keep technical depth in **Automation & Technical Notes** only.

## Output structure

```text
**Draft QA comment — review before posting to Jira**

---

### QA Summary

**Task Context:** <one sentence>

**Main Changes:**
- <user-visible change>
- ...

---

**Verification List:**

**Manual Testing:**
- [ ] <verification step>
- ...

**Automation & Technical Notes:**
- **Selectors**: ...
- **API**: ...
- **Error Handling**: ...
```
