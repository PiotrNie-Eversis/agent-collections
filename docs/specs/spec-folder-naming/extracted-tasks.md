# Spec folder naming - Extracted Tasks

## Workshop Summary

| Field | Value |
|---|---|
| Workshop Date | 2026-09-24 |
| Participants | Piotr Niemirski |
| Source Materials | `cleaned-transcript.md`; approved `intent-brief.md`; `.ai/rules/orchestration/spec-driven-development.md` |
| Intent Brief | `docs/specs/spec-folder-naming/intent-brief.md` (Gate 0 approved 2026-09-24) |
| Project Baseline Used | `docs/context/agent-collections/task-baseline.md` (refreshed 2026-09-24) |
| Total Epics | 1 |
| Total Stories | 3 |
| Jira delivery | One Sub-task under AC-2. Gate 1: Story 1.1 approved 2026-09-24, including the three-word topic cap. The same reply asks for the whole breakdown as that one child ticket. |

## Epics Overview

| # | Epic Title | Stories Count | Priority |
|---|-----------|---------------|----------|
| 1 | New spec folders carry a topic after the ticket key | 3 | Medium |

## Epic 1: New spec folders carry a topic after the ticket key

**Business Description**: A new research or plan folder can be found by its ticket key and recognized by its topic. The key stays at the front of the name. Existing folders are left as they are. An index row for durable facts is a separate act.

**Success Criteria**:
- A person can read the Delivery Standard and see the key-then-topic shape, with an example that is not only a ticket key.
- Starting Implement with a ticket key still opens the one existing folder for that key.
- A new research file's first heading states the topic.

### Story 1.1: Delivery Standard shows the key-then-topic name

**User Story**: As a maintainer, I want the Delivery Standard to show a spec folder name with the ticket key first and a short topic after it, so that new work does not use a key-only name or a topic-first name.

**Source**: Intent brief "Recommended approach"; cleaned transcript "Recommended name shape"; `spec-driven-development.md` folder and file rows and the Jira copy block.

**Acceptance Criteria**:
- [ ] GIVEN the Delivery Standard WHEN a reader looks up where a spec folder goes THEN the example name starts with the ticket key and continues with a short topic, in the shape `ac-2-context-management`.
- [ ] GIVEN that same standard WHEN a reader looks up the research and plan file names THEN those names repeat the folder name, not the key alone.
- [ ] GIVEN the block copied into a Jira description WHEN a reader looks at the spec folder line THEN it uses that same shape.
- [ ] GIVEN a topic-first example such as `context-ac-2-management` WHEN a reader checks the standard THEN that shape is not the one shown.
- [ ] GIVEN a new folder name WHEN the topic suffix is chosen THEN it is at most three words after the key. A longer phrase goes in the first heading, not in the path.

**Additional Acceptance Checks**:
- `docs/specs/README.md` states the same shape, so the in-repo readme does not contradict the rule.

**High-Level Technical Notes**: The convention text lives in `.ai/rules/orchestration/spec-driven-development.md`, including the Delivery Standard copy block. The public specs readme repeats it.

**Priority**: Medium

### Story 1.2: Implement opens the topic folder from the ticket key alone

**User Story**: As a person starting Implement with only a ticket key, I want the existing spec folder for that key to be found, so that a second key-only folder is not created beside it.

**Source**: Intent brief "Implement, given only a ticket key"; cleaned transcript "a folder that does not start with that path looks missing".

**Acceptance Criteria**:
- [ ] GIVEN a folder named `ac-2-context-management` and no folder named `ac-2` WHEN Implement starts for AC-2 THEN that topic folder is the one used for the research and the plan.
- [ ] GIVEN that same situation WHEN Implement starts THEN a new `docs/specs/ac-2/` folder is not created.
- [ ] GIVEN two folders whose names start with the same key WHEN Implement starts for that key THEN the session stops and asks which folder, instead of picking one in silence or creating a third.

**High-Level Technical Notes**: The lookup is the Implement readiness step that inspects `docs/specs/<issue>/`. The written path and this lookup have to accept a key prefix plus a topic suffix.

**Priority**: Medium

### Story 1.3: A new research file's first heading states the topic

**User Story**: As an agent deciding whether an old spec is useful, I want the first heading to state the topic, so that a heading which is only the ticket key is not the pattern for new files.

**Source**: Intent brief "First heading"; cleaned transcript "A first heading that is only `# AC-2 - Analysis Result` does not help".

**Acceptance Criteria**:
- [ ] GIVEN the research template WHEN a new research file is created THEN the template's first heading includes a topic, not only the ticket key and the words "Analysis Result".
- [ ] GIVEN an existing research file whose heading is only the key WHEN this convention is adopted THEN that file is left unchanged.

**High-Level Technical Notes**: The current template heading is `# <TASK_NAME> - Analysis Result` in `eversis-task-analysing`.

**Priority**: Medium

## Dependencies

| Task | Depends On | Type | Notes |
|------|-----------|------|-------|
| Story 1.2 | Story 1.1 | Related to | The lookup should follow the shape the standard documents. It does not have to wait for the doc edit to be designed. |
| Story 1.3 | Story 1.1 | Related to | The heading and the folder name are one convention. Neither blocks the other. |

## Assumptions

| # | Assumption | Confidence | Impact if Wrong |
|---|-----------|------------|-----------------|
| 1 | One Jira key maps to one spec folder. | High | Story 1.2's "ask which folder" case becomes the normal case and needs a sharper rule. |
| 2 | Workshop folders with no Jira key may stay topic-only. | High | Those folders would also need a fake key. |
| 3 | The topic suffix is at most three kebab words. A sentence stays in the first heading. | High | A longer allowed suffix would make Story 1.1's length check wrong. |

## Out of Scope

Items explicitly excluded from this task breakdown:
- Renaming existing spec folders (`ac-2`, `ac-31`, `blog`, and the rest).
- Rewriting headings inside existing research files.
- Adding an `INDEX.md` row per ticket, or changing when promotion runs.
- Topic-first folder names.

## Open Questions for Stakeholders

| # | Question | Context | Impact |
|---|----------|---------|--------|
| 1 | None. | Gate 0 approved the convention text, the lookup, and the heading. Old folders stay. | — |
