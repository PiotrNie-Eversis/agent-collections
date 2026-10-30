# SSOT branch in install selection — Intent Brief

## Workshop Summary

| Field | Value |
|---|---|
| Workshop Date | 2026-10-13 |
| Participants | Framework maintainer (this chat) |
| Source Materials | Chat: whether `--ssot-branch` is stored; decision that the branch should be remembered next to the repo URL. A branch name such as `master` is an example for one domain-context only — each project stores its own name |
| Prepared By | Business Analyst (`eversis-analyze-materials`) |

## Goal

Each project remembers the domain-context branch it was installed with. That name is chosen per project and can differ from one shared repository to another. Later refreshes reuse the stored name. When install does not name a branch, the record uses `main`.

## In Scope

- Remember the domain-context branch chosen at install, in the same install record that already stores the repository URL.
- Reuse that remembered branch on a later upgrade or sync when no new branch is given.
- Use that remembered branch when someone refreshes shared knowledge and does not name a branch for that one refresh.
- Keep today's behaviour for installs that never name a branch: assume `main`.

## Out of Scope

- Re-seeding an already imported `docs/context/global/` tree in a consumer project.
- Renaming or deleting branches on the domain-context repository.
- Pinning knowledge to a tag or a specific commit.
- Changing how knowledge is published back to the shared repository.
- A framework-wide branch name. `master` on one domain-context is not the name other projects must use.

## Key Stakeholders / Actors

- Person installing Agent Collections — chooses the branch once and expects later refreshes to follow it.
- Person refreshing shared domain knowledge — should not have to recall which branch the project was seeded from.

## Candidate Epics

- Remember the domain-context branch with the install — one outcome: the branch travels with the recorded repository URL.

## Baseline Overlap / Existing Backlog Notes

- Jira project **AC** has no open epic for install-record fields. **AC-4** (Context flow on AC website) is website guides only.
- **AC-2** (context architecture) and **AC-28** (optional Confluence import at install) are Done and do not cover remembering the branch.
- No `docs/context/<project>/task-baseline.md` in the framework repo.

## Open Questions

- None for scope. Parent epic in Jira is an assumption: a new story in project AC, not a child of AC-4.

## Gate 0 Approval

| Decision | Notes |
|---|---|
| Skipped — materials unambiguous | 2026-10-13. The chat decided the branch must be stored per project. A later correction: a name such as `master` applies only to one domain-context, not to every install. |
