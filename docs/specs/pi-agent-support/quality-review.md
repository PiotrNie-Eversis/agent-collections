# Pi Agent support — Quality Review Report

## Review Context

| Field | Value |
|---|---|
| Review Date | 2026-09-21 |
| Source Task List | `extracted-tasks.md` (single story; requestor approved the brief and asked to create the ticket immediately) |
| Additional Sources | Approved `intent-brief.md`; Jira project AC (no Pi overlap); [Pi documentation](https://pi.dev/docs) |
| Review Mode | Lite |
| Passes Run | A, B, E, H, I |
| Epics Reviewed | 1 |
| Stories Reviewed | 1 |
| Total Suggestions | 0 |
| Accepted | 0 |
| Rejected | 0 |

---

## Domain Model

### Actors

| Actor | Epics Involved | Key Capabilities |
|---|---|---|
| Team using Pi | 1 | Install Agent Collections with Pi selected and use rules, skills, and prompt templates in a Pi session |
| Reader of the docs | 1 | See that Pi is supported and what the install provides |
| Framework maintainer | 1 | Ship Pi as a supported agent without a second copy of the core |

### Entities

| Entity | Created In | Read In | Updated In | Deactivated/Deleted In |
|---|---|---|---|---|
| Pi as a supported agent | Story 1.1 | Story 1.1 (docs and install list) | — | — (removal is out of scope) |

### Key Relationships

- Pi support depends on the existing framework core staying the source of rules, skills, and prompts — consumed, not rewritten, in Story 1.1.
- Install choice gates whether Pi packaging is present — guarded in Story 1.1 (opt-out and failed setup).

---

## Pass Notes

- **A Entity lifecycle**: Creation and reading are in Story 1.1. Update and removal are not a managed catalog in this request; no suggestion.
- **B Cross-feature state**: No second feature consumes Pi support. No suggestion.
- **E Precondition guards**: Opt-out and failed setup are acceptance criteria on Story 1.1. No suggestion.
- **H Error and edge cases**: Failed Pi setup and “Pi not chosen” are acceptance criteria. No suggestion.
- **I Notifications**: No state change affects a second person who must be notified. No suggestion.

## Suggestions

None.

## Changes Applied

None. `extracted-tasks.md` is unchanged by this review.

---

# Scope extension 2026-10-27 — Quality Review

## Review Context

| Field | Value |
|---|---|
| Review Date | 2026-10-27 |
| Source Task List | `extracted-tasks.md` → “Scope extension 2026-10-27” (Stories 1.2 – 1.5, Gate 1 approved 2026-10-27) |
| Additional Sources | `intent-brief.md` extension (Gate 0 Approved 2026-10-27); “GitHub Copilot Pro a koszty API.md”; Jira AC-14, AC-21, DHI-528 – DHI-530 |
| Review Mode | Lite |
| Passes Run | A, B, E, H, I |
| Stories Reviewed | 4 |
| Total Suggestions | 6 |
| Accepted | 6 |
| Rejected | 0 |

## Jira Context

- DHI-528, DHI-529 (“Deliver synchronized ignore files”), DHI-530 are **Done** under DHI-515 (Done). The “deferred” note for ignore files is out of date. Story 1.4 extends the delivered mechanism.
- AC-21 (Sub-task of AC-14, In Progress) sets the sub-task convention for the new stories.
- No other AC issue covers Pi costs, token rules, exclusions, or sandboxing.

## Domain Model

| Actor | Stories | Key Capabilities |
|---|---|---|
| Team using Pi | 1.2 – 1.5 | Signs Pi in, runs Implement sessions, edits exclusions, opts into the isolated workspace |
| Framework maintainer | 1.3, 1.4 | Owns Pi packaging defaults and upgrades |
| Docs reader | 1.2, 1.4, 1.5 | Follows the Pi guide and its verification checks |

| Entity | Created In | Read In | Updated In | Removed In |
|---|---|---|---|---|
| Subscription sign-in (provider) | 1.2 | 1.2, 1.5 | 1.2 (switch model / provider) | — (vendor-side) |
| Token-economy rule set (Pi) | 1.3 install | 1.3 sessions | 1.3 upgrade (S-02) | AC-14 (Pi not chosen) |
| Exclusion list | 1.4 install | 1.4 canary | 1.4 shared change + upgrade (S-01, S-02) | AC-14 (Pi not chosen) |
| Isolated workspace template | 1.5 | 1.5 checks | — (opt-in, user-owned) | — (user stops using it) |

## Suggestions and Decisions

| ID | Story | Pass | Confidence | Action | Summary | Decision |
|---|---|---|---|---|---|---|
| S-01 | 1.4 | B + Jira | High | MODIFY_STORY | Add Pi to the delivered synchronized ignore files (DHI-528 – 530 Done); AC for the same exclusions across agents | Accepted |
| S-02 | 1.3, 1.4 | A | High | ADD_ACCEPTANCE_CRITERION | Upgrade refreshes Pi token rules and default exclusions; person’s own instructions and entries kept | Accepted |
| S-03 | 1.5 | B | High | ADD_ACCEPTANCE_CRITERION | Registries-only network still reaches the model provider and the framework skill server | Accepted |
| S-04 | 1.3 | H | Medium | ADD_ACCEPTANCE_CRITERION | Request for data in an excluded or large file → targeted alternative, full read only after confirmation | Accepted |
| S-05 | 1.2 | I + H | Medium | ADD_ACCEPTANCE_CRITERION | Allowance runs out mid-session → guide covers recognizing it, continuing, resuming from the last checkpoint | Accepted |
| S-06 | 1.5 | E | Medium | ADD_ACCEPTANCE_CRITERION | Container runtime prerequisites listed first; clear message when missing | Accepted |

## Changes Applied to `extracted-tasks.md`

- Story 1.2: +1 AC (S-05)
- Story 1.3: +2 AC (S-02, S-04)
- Story 1.4: +2 AC (S-01, S-02); technical note rewritten (S-01); Dependencies row updated (S-01)
- Story 1.5: +2 AC (S-03, S-06)
- `intent-brief.md`: DHI-528 – 530 status corrected to Done (S-01)
