---
name: eversis-promote-domain-knowledge
description: "Evaluates whether a just-finished task produced durable, cross-task domain knowledge (a convention, a confirmed business rule, a reusable integration pattern) and, if so, prepares a promotion draft for the Fine turn (eversis-fine-handoff). Writes to docs/context/<project>/ only after explicit human approval, via GitLab REST API — never a local domain-context checkout. Use at the end of Implement/Review, before declaring Fine."
user-invocable: false
---

# Promoting Domain Knowledge

Runs at the end of Implement/Review, before Fine (`global-domain-context-ssot.research.md`, Question 10). Decides whether anything from the just-finished task is worth a durable entry in `docs/context/<project>/`, and if so, prepares the draft that `eversis-fine-handoff` shows as its optional second draft. Never writes without explicit human approval of that specific draft.

<principles>
<no-new-gate>
This skill never creates a separate human gate. Its output is exclusively the second, optional draft inside the existing Fine turn — see `eversis-fine-handoff.md`. If there is nothing worth promoting, produce no output at all; do not force a draft to justify running this skill.
</no-new-gate>
<no-local-checkout>
Writes go through the GitLab REST API (Branches → Commits with multiple file actions → Merge Requests) against the target repository (`docs/context/<project>/` in the current consumer repo, or `domain-context` for a later project → global promotion). Never clone or maintain a local checkout of `domain-context` to prepare a write — a cached checkout used only for authoring commits would itself go stale between invocations, reintroducing the exact staleness problem the read-side design (Question 6) already solved. Requires a `GITLAB_TOKEN` environment variable with `api` scope (see `docs/architecture/install-selection.md`).
</no-local-checkout>
</principles>

## Step 1 — Is this cross-task?

Ask: would a **different** task, in the future, benefit from knowing this — not "could this theoretically matter someday," but "is this a named convention, a confirmed business rule, or a reusable pattern."

**Promote (yes) — examples:**
- A named team/repo convention ("MRs in this repo must reference the Jira key").
- A confirmed, durable business rule ("prices always round up to the nearest 0.05 in the local currency").
- An integration pattern that will be reused (a new payment provider's auth flow, a new external API's error-handling shape).

**Do not promote (no) — examples:**
- Renaming a variable or function.
- Fixing a typo in a translation string.
- A one-off tuning choice specific to this task (e.g. raising a timeout for one slow external call) — **unless** the same tuning choice shows up again in an unrelated task (see the second-occurrence rule below).

**Second-occurrence rule for borderline cases.** When a decision is not obviously repo-wide on its own (unlike the convention example above), do not promote on the first occurrence. Check the target component's existing file (Step 2) for a similar prior note. If one exists, this is the second occurrence — promote now, appending to the existing entry. If not, skip promotion this time; a single, isolated event is not yet a pattern. This reduces false positives without requiring the agent to predict the future on the first sighting.

If nothing in the task clears this bar, stop here — produce no draft.

## Step 2 — Find the existing component file, don't assume a new one

Before drafting a new file, look for an existing `docs/context/<project>/<component>/index.md` that already covers this area:

- Match by `code_paths` in existing files' frontmatter against the paths this task actually touched.
- If no `code_paths` match, match by component name (the functional area the task worked in — see the naming rule below).

If a match exists, the promotion **extends** that file — see Step 4. If not, this is a new component.

## Step 3 — `<domena>` = component, not a loose business topic

Name the directory after the functional component/feature (`checkout-flow`, `pricing-engine`), not an abstract business category (`business-rules`). Component names correlate with `code_paths`, which is what makes Step 2's matching and later agent read-time lookup (`agent-core.md` Research step) actually work — a business-topic name has no equivalent anchor.

## Step 4 — Draft the entry

**New component** — `docs/context/<project>/<component>/index.md`:

```yaml
---
scope: project
source: agent-discovered
status: approved
last_updated: "<ISO date>"
tags: [<relevant tags>]
code_paths: ["<glob or path>"]
confluence_url: null
related_specs: ["docs/specs/<task-kebab>/"]
---
```

`status` allowed values are `draft`, `proposed`, `approved`, `deprecated`, and `superseded`. This skill writes only `status: approved` when the draft is committed. It does not write `draft` or `proposed`. Those two names stay the existing chat gate, not a stored file state. `deprecated` and `superseded` are written by the audit skill, not by this one.

Followed by a short, current-state description (what it is, how it works today) — not a diff, not a changelog entry.

**Existing component** — update in place:
- Overwrite the descriptive body with the current, accurate state (never accumulate old and new descriptions side by side).
- Append `docs/specs/<task-kebab>/` to `related_specs` (a growing list, one line per task — never remove or reorder prior entries here).
- If `related_specs` now exceeds ~15-20 entries, move all but the most recent 5-10 into `<component>/changelog.md` (create it if absent), leaving one line in `index.md`: "Starsza historia: zobacz `changelog.md`." Reuse this repo's own `CHANGELOG.md` idiom (append-only, never rewritten) — do not invent a different format.
- Copy an existing `confluence_url` into the draft and leave it unchanged; do not replace a null or missing URL with a guessed Pack link.
- Update the component's one-line row in `docs/context/<project>/INDEX.md` if the summary changed; add a new row if this is a new component.
- Set `status: approved` on the committed file. Do not write `draft` or `proposed`.

Do not set `last_consulted` here — that field is maintained automatically by `eversis_context_get` on read, not by this skill on write.

## Step 5 — Present the draft, wait for approval

Hand the prepared file content (path + frontmatter + body, and the `INDEX.md`/`changelog.md` diff if applicable) to `eversis-fine-handoff` as the second draft. Do not write anything until that specific draft is explicitly approved — approval of the QA comment draft in the same turn does not approve this one.

## Step 6 — Write, only after approval

1. `GET` the current `INDEX.md` (and the component file, if updating) via the GitLab Files API to confirm you are not overwriting a change made since the draft was prepared.
2. Create a branch from the target repo's default branch.
3. `POST` a single commit with all changed files as one set of file actions (component `index.md`, `INDEX.md`, `changelog.md` if applicable) — one atomic commit, not several.
4. Open a merge request.

This is the only step that touches the remote repository. Steps 1-5 are read-only/local reasoning.

## Later, separate step — project → global promotion

Everything above writes to `docs/context/<project>/` (this repo). Promoting further, from this repo's own knowledge into the shared `domain-context` GitLab project (so other consumer repos in the same group can see it too), is a distinct, later action using the same GitLab API mechanism (Step 6) but targeting `domain-context` instead — it is not automatic and not part of this same Fine turn. See `global-domain-context-ssot.research.md`, Question 2.
