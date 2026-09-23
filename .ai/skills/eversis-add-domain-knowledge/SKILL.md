---
name: eversis-add-domain-knowledge
description: "Person-started draft of one durable fact into project knowledge under docs/context/<project>/ when the person already knows a convention, confirmed business rule, or reusable pattern and no ticket is closing. Shows a draft of the component file and INDEX.md row, writes only after that draft is approved, as a local working-tree edit the person commits. Not Fine close-out promotion (eversis-promote-domain-knowledge)."
user-invocable: true
---

# Adding Domain Knowledge

A person starts this skill on purpose to draft one durable project-knowledge fact into `docs/context/<project>/` when they already know the fact and no ticket is closing. It is not Fine close-out promotion (`eversis-promote-domain-knowledge`). After the person approves the specific draft, this skill edits only the working tree and stops — the person commits.

<principles>
<person-started-not-fine>
This skill runs only when the person starts it. It is not part of Implement/Review/Fine. Close-out promotion stays `eversis-promote-domain-knowledge` (`user-invocable: false`), still writes through GitLab at Fine, and is unchanged by this skill.
</person-started-not-fine>
<draft-gate-then-local-write>
Show the draft (proposed component file plus the two-column index row) and wait. Write nothing until that specific draft is explicitly approved. On approval, write only working-tree files under `docs/context/<project>/`. Do not open a merge request and do not run `git commit`.
</draft-gate-then-local-write>
<same-store-no-second-index>
Project knowledge lives under the path from `ssot.projectContextPath` and its `INDEX.md`. Do not invent the project folder from the repository name. Do not create a second store, a second index, or a directory when `INDEX.md` is missing.
</same-store-no-second-index>
</principles>

## Process

1. **Resolve the project path.** Read `ssot.projectContextPath` from `.agent-collections/install-selection.json`. Do not invent the project folder from the repository name.

2. **Require the index.** If `<projectContextPath>/INDEX.md` does not exist, say so and stop. Do not create the directory, a second index, or another store. An index that exists with zero data rows is not missing; the first approved topic adds a row.

3. **Accept only durable facts.** Accept a fact only when it is a team convention, a confirmed business rule, or a reusable pattern — the same bar as `eversis-promote-domain-knowledge` Step 1:

   **Accept (yes) — examples:**
   - A named team/repo convention ("MRs in this repo must reference the Jira key").
   - A confirmed, durable business rule ("prices always round up to the nearest 0.05 in the local currency").
   - An integration pattern that will be reused (a new payment provider's auth flow, a new external API's error-handling shape).

   **Reject (no) — examples:**
   - Renaming a variable or function.
   - Fixing a typo in a translation string.
   - A one-off tuning choice (e.g. raising a timeout for one slow external call).

   Do **not** apply promotion's second-occurrence rule: the person is already asserting a durable fact, and starting this command is not itself proof. If the fact fails the bar, stop with no draft and no write.

4. **Match or propose one component.** Look for an existing `docs/context/<project>/<component>/index.md` the way promotion Step 2 does:
   - Match by `code_paths` in existing files' frontmatter against the paths the fact names.
   - If no `code_paths` match, match by component name (the functional area — see naming below).

   If a match exists, the draft **extends** that file. If not, propose one new component named after a functional area (`checkout-flow`, `pricing-engine`), never a bucket such as `business-rules`. The draft shows that name so the person can correct it before approval. Empty `code_paths` is allowed.

5. **Show the draft and wait.** The draft is the proposed component file plus the two-column index row (`| component | one-line summary |`). Write nothing in this step.

   **New component** — `docs/context/<project>/<component>/index.md`:

   ```yaml
   ---
   scope: project
   source: manual
   status: approved
   last_updated: "<ISO date>"
   tags: [<relevant tags>]
   code_paths: []
   confluence_url: null
   related_specs: []
   ---
   ```

   `code_paths` is filled when the fact names paths; otherwise it is an explicit empty array. `related_specs` stays an explicit empty array. Do not point every fact at `docs/specs/ac-22/`.

   Followed by a short, current-state description (what it is, how it works today) — not a diff, not a changelog entry.

   **Existing component** — update in place:
   - Overwrite the descriptive body with the current, accurate state (never accumulate old and new descriptions side by side).
   - Keep existing `related_specs` and existing `source` (so a Confluence seed does not become `manual`).
   - Set `status: approved` and update `last_updated`.
   - Do not set `last_consulted` — that field is maintained automatically by `eversis_context_get` on read, not by this skill on write.

   `status` allowed values are `draft`, `proposed`, `approved`, `deprecated`, and `superseded`. This skill writes only `status: approved` on the file that lands on disk. `draft` and `proposed` stay the chat gate, not a stored file state. `deprecated` and `superseded` stay with the audit skill.

6. **Reject or no approval → unchanged.** If the person rejects the draft or the turn ends without approval of that specific draft, leave every project-knowledge file unchanged.

7. **Approve → write working tree only.** If the person approves that draft, write only the working-tree files: the component `index.md`, and the `INDEX.md` row when the summary is new or changed. The index stays two columns: `| component | one-line summary |`. Stop. Do not run `git commit`, do not create a branch, and do not call GitLab. The person commits.

## What this skill does NOT do

- Does not open a merge request and does not call the GitLab API. Does not read or require `GITLAB_TOKEN`.
- Does not run `git commit` and does not create a branch. The person commits.
- Does not create a second store, a second index, or a directory when `INDEX.md` is missing.
- Does not apply the second-occurrence rule.
- Does not write `draft` or `proposed` onto disk.
- Does not edit `docs/context/global/` or publish into the shared `domain-context` repository.
- Does not change `eversis-promote-domain-knowledge`. Close-out promotion stays `user-invocable: false` and still writes through GitLab at Fine.
- Does not set `last_consulted`.
- Does not change gitignore.
- Does not run this command against a consumer repository as part of delivering the skill.
