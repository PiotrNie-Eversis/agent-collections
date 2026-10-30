# SSOT branch in install selection - Extracted Tasks

## Workshop Summary

| Field | Value |
|---|---|
| Workshop Date | 2026-10-13 |
| Participants | Framework maintainer (this chat) |
| Source Materials | Chat decision that the domain-context branch should be stored beside the repository URL. Correction: the stored name is whatever that project chose; one repository using `master` does not set the name for others |
| Intent Brief | `docs/specs/ssot-branch-in-selection/intent-brief.md` |
| Project Baseline Used | None |
| Total Epics | 1 |
| Total Stories | 1 |

## Epics Overview

| # | Epic Title | Stories Count | Priority |
|---|-----------|---------------|----------|
| 1 | Remember the domain-context branch with the install | 1 | High |

## Epic 1: Remember the domain-context branch with the install

**Business Description**: People who install Agent Collections against a shared knowledge repository need the branch they chose for that project to stick. The name is not fixed by the framework: one domain-context may use `master`, another a different name. Today the repository address is remembered and the branch is not, so a later refresh can follow `main` even when that project was set up from another branch.

**Success Criteria**:
- After install, the install record shows the branch name that this project chose.
- Two projects can store two different branch names.
- A later refresh that does not name a branch uses the name stored for that project.
- Projects that never name a branch still follow `main`.

### Story 1.1: Install remembers the domain-context branch

**User Story**: As a person installing Agent Collections, I want the domain-context branch saved with the install settings so that later refreshes use the same branch without me repeating it.

**Source**: Chat 2026-10-13 — `--ssot-branch` is not written to `.agent-collections/install-selection.json`; agreed the branch should be stored next to `externalSsotRepo`. Follow-up: a concrete name (for example `master` on one domain-context) is local to that project.

**Acceptance Criteria**:
- [ ] GIVEN an install that names a branch WHEN the install record is written THEN the record stores that exact name
- [ ] GIVEN two installs that name different branches WHEN both records are written THEN each record keeps its own name
- [ ] GIVEN an install that does not name a branch WHEN the install record is written THEN the recorded branch is `main`
- [ ] GIVEN a project whose recorded branch is not `main` WHEN upgrade or sync runs without a new branch THEN the record still has that project's name
- [ ] GIVEN a recorded branch WHEN shared knowledge is refreshed without naming a branch THEN the refresh uses the name stored for that project
- [ ] GIVEN a recorded branch WHEN a single refresh names a different branch THEN that refresh uses the named branch and does not require the stored value to change

**Additional Acceptance Checks**:
- An existing install record that has no branch field keeps working and is treated as `main` until the next install or upgrade writes the field.
- The framework does not treat any one non-default name, including `master`, as the branch every project must use.

**High-Level Technical Notes**: Field belongs on `ssot` in `.agent-collections/install-selection.json`, beside `externalSsotRepo`. Installer flag remains `--ssot-branch` and accepts whatever name that project uses. `eversis_context_sync` reads the stored branch when the call does not pass one. The only framework default is `main`, used when no branch was given.

**Priority**: High

## Dependencies

| Task | Depends On | Type | Notes |
|------|-----------|------|-------|
| Story 1.1 | — | — | No blocker in the current AC backlog |

## Assumptions

| # | Assumption | Confidence | Impact if Wrong |
|---|-----------|------------|-----------------|
| 1 | This is a new story in Jira project AC, not a child of epic AC-4 | High | The issue would be re-parented under a different epic |
| 2 | Issue type is Story | Medium | Maintainer may want a Task instead, matching some recent AC items |
| 3 | Field name is `ssot.branch` | Medium | A different name would only change the record shape, not the outcome |

## Out of Scope

Items explicitly excluded from this task breakdown:
- Re-running the first import of `docs/context/global/` in an already seeded project
- Changing branches on the domain-context GitLab project
- Pinning the refresh to a tag or commit
- Publishing knowledge back to the shared repository
- Hard-coding one branch name, such as `master`, for every consumer. That name is valid only for the domain-context that actually uses it

## Open Questions for Stakeholders

| # | Question | Context | Impact |
|---|----------|---------|--------|
| — | None | Scope was confirmed in chat | — |
