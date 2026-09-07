---
name: eversis-audit-domain-knowledge
description: "Periodic review of docs/context/<project>/ component files, classifying each into Keep/Update/Consolidate/Replace/Delete using last_consulted and code_paths as signals. Run manually on a schedule the team chooses (starting point: quarterly) — never automatically, never part of a single task's Fine turn."
user-invocable: true
---

# Auditing Domain Knowledge

Closes the feedback loop that `eversis-promote-domain-knowledge` cannot close by itself: whether knowledge that was written is still accurate, and whether some of it has quietly stopped mattering (`global-domain-context-ssot.research.md`, Question 12(b)). Runs on a schedule the team picks — this skill does not decide or enforce a cadence, it only defines what happens when a human or a scheduled agent session runs it.

<principles>
<closed-outcome-set>
Every component file gets exactly one of the five outcomes below — never an open-ended "does this still look right?" judgment. A closed set is what makes this repeatable across many files without drifting into inconsistent, ad-hoc calls each time.
</closed-outcome-set>
<existing-knowledge-only>
This audit reviews files that already exist. It does not, by itself, guarantee detection of topics that were never promoted (under-triggering in `eversis-promote-domain-knowledge`, Step 1) — see the optional docs/specs/ sampling step below for a partial, best-effort mitigation, not a guarantee.
</existing-knowledge-only>
</principles>

## The five outcomes

| Outcome | When | Action |
|---|---|---|
| Keep | Description is still accurate and useful | No change |
| Update | Accurate but incomplete (e.g. `code_paths` no longer match after a refactor) | Fill in the missing detail |
| Consolidate | `related_specs`/`changelog.md` contains duplicate entries for the same lesson | Merge duplicates into one entry |
| Replace | Description is stale/outdated (e.g. the component was redesigned) | Rewrite with the current state |
| Delete | The component no longer exists (`code_paths` point at nothing) | Remove the file, remove its `INDEX.md` row |

## Process

1. For each `docs/context/<project>/<component>/index.md`:
   - Check `last_consulted` (maintained automatically by `eversis_context_get` — see `mcp/eversis-collections-mcp/src/context.ts`). No value, or a very old one relative to the component's `related_specs` activity, is a signal toward `Replace`/`Delete`, not proof by itself — confirm before deleting.
   - Check whether every path in `code_paths` still exists in the repo. Any that don't are a strong signal toward `Update` (if some paths are gone) or `Delete` (if all are gone).
   - Skim `related_specs`/`changelog.md` for repeated, near-identical entries — a `Consolidate` candidate.
   - Otherwise, read the description against the current code briefly to confirm `Keep` vs. `Replace`.
2. Record the outcome and, for anything other than `Keep`, apply the action directly (this is normal file editing, not a promotion — no GitLab API round-trip is needed for a project-level audit fix, since it is a plain commit to the current repo like any other change).
3. Optional, best-effort under-triggering check: for components with active `code_paths`, sample `docs/specs/` folders created since the last audit that touch the same paths, and check whether any contain a repeated topic with no corresponding mention in the component file. This does not guarantee detection — it is a cheap, additional signal to take at the same time as the audit, not a separate mechanism.

## What this skill does NOT do

- Does not run automatically after every task (that is `eversis-promote-domain-knowledge`, a different mechanism).
- Does not decide the audit frequency — that is a team/Plan-level configuration choice (a starting point of quarterly is reasonable but not enforced here).
- Does not touch `domain-context` (global) directly — a `Replace`/`Delete` found here concerns this repo's own `docs/context/<project>/` copy; if the same issue exists in `docs/context/global/`, propose a promotion the normal way instead of editing the subtree-pulled copy directly (edits there would be overwritten by the next `eversis_context_sync`).
