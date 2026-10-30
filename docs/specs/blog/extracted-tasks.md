# Blog - Extracted Tasks

## Workshop Summary

| Field | Value |
|---|---|
| Workshop Date | 2026-09-24 |
| Participants | Piotr Niemirski |
| Source Materials | `cleaned-transcript.md`; approved `intent-brief.md`; [Next.js security update, 22 September 2026](https://nextjs.org/blog/nextjs-security-update-september-22-2026); AC-2 team announcement (notice only, not the post body); docs site changelog and navbar |
| Intent Brief | `docs/specs/blog/intent-brief.md` (Gate 0 approved 2026-09-24) |
| Project Baseline Used | `docs/context/agent-collections/task-baseline.md` (refreshed 2026-09-21) |
| Total Epics | 3 |
| Total Stories | 4 |
| Jira delivery | One Task in project AC. Gate 1: Story 1.1 approved 2026-09-24. The same reply folds the whole breakdown into that single ticket (board convention matches AC-14 and AC-15). |

## Epics Overview

| # | Epic Title | Stories Count | Priority |
|---|-----------|---------------|----------|
| 1 | Reader can find technical change posts on the docs site | 2 | High |
| 2 | Authors follow a rule that keeps a post from repeating the team notice | 1 | High |
| 3 | First post explains the AC-2 change in technical terms | 1 | High |

## Epic 1: Reader can find technical change posts on the docs site

**Business Description**: The documentation site gains a blog for technical write-ups of framework changes. A reader can open it from the header, read a post, and find posts through search. The changelog stays the complete version ledger.

**Success Criteria**:
- A reader reaches the blog from the docs site header without leaving the site.
- A post shows its title, date, and author, and links to the matching changelog entry.
- Site search can return a blog post.

### Story 1.1: Reader can open the blog from the docs site

**User Story**: As a reader of the docs site, I want a blog next to the changelog so that I can open a technical write-up of a framework change.

**Source**: Intent brief "Blog section on the docs site"; cleaned transcript "A blog for technical change posts"; task baseline DHI-653 (navbar belongs to the docs information-architecture epic).

**Acceptance Criteria**:
- [ ] GIVEN the docs site header WHEN a reader looks for recent technical write-ups THEN a Blog entry is available beside Changelog.
- [ ] GIVEN the Blog entry WHEN the reader opens it THEN they see a list of posts with title and date, newest first.
- [ ] GIVEN a post in that list WHEN the reader opens it THEN they see the title, the date, the author, and the body.
- [ ] GIVEN the existing Docs, Get started, The Main Flow, Reference, and Advanced / CTO entries WHEN the Blog entry is added THEN those entries stay in place.

**Additional Acceptance Checks**:
- The changelog page remains the generated ledger. The blog does not replace it.

**High-Level Technical Notes**: The site is the existing Docusaurus docs site. The blog capability is currently switched off. Header changes should be checked against DHI-653 so the blog link sits with Changelog rather than inside the four docs clusters.

**Priority**: High

### Story 1.2: Reader can find a blog post through site search

**User Story**: As a reader, I want site search to include blog posts so that I can find a technical write-up without knowing the blog exists.

**Source**: Intent brief in-scope item "Navbar and search".

**Acceptance Criteria**:
- [ ] GIVEN a published post WHEN a reader searches for a distinctive phrase from that post THEN the post appears in the site search results.
- [ ] GIVEN the existing docs WHEN a reader searches for a docs phrase THEN docs results still appear.

**High-Level Technical Notes**: Site search currently does not index a blog.

**Priority**: Medium

## Epic 2: Authors follow a rule that keeps a post from repeating the team notice

**Business Description**: Before a post is published, the author checks it against a short rule. The post explains the mechanism. The team message keeps the role checklist, the how-to lines, and the upgrade commands.

**Success Criteria**:
- An author can tell, from the rule alone, whether a change deserves a post.
- An author can tell, from the rule alone, that pasting the team message into the post is not allowed.

### Story 2.1: Maintainer has a publishing rule for technical change posts

**User Story**: As a maintainer, I want a written publishing rule so that a blog post deepens the team notice instead of repeating it.

**Source**: Intent brief "Recommended approach" and Gate 0 approval ("Ten podział jest ok"); cleaned transcript "Blog post versus the team message".

**Acceptance Criteria**:
- [ ] GIVEN a framework change WHEN a maintainer decides whether to write a post THEN the rule says a post is for a mechanism worth explaining, and a one-line fix stays in the changelog only.
- [ ] GIVEN a post draft WHEN the maintainer checks the rule THEN the draft must cover what changed, why the previous behavior was a problem, how it behaves now (including limits), what did not change, and a link to the changelog entry.
- [ ] GIVEN a team message that already listed roles, chat commands, and upgrade scripts WHEN the maintainer checks the rule THEN copying those blocks into the post is not acceptable.
- [ ] GIVEN a draft WHEN it is published THEN a human has approved that draft first.

**High-Level Technical Notes**: None.

**Priority**: High

## Epic 3: First post explains the AC-2 change in technical terms

**Business Description**: The first post is a technical account of the AC-2 framework update. Readers who saw the team notice learn how the four mechanisms behave and where they stop. Readers who did not see the notice can still understand the change from the post alone.

**Success Criteria**:
- One published post covers the four mechanisms from the approved brief.
- A reader who compares the post with the team message does not find the same role checklist or the same upgrade scripts.

### Story 3.1: Reader can read how the AC-2 update behaves

**User Story**: As a reader who uses Agent Collections, I want a technical account of the AC-2 update so that I understand the limits of context reads, session continuity, the split between business rules and architecture decisions, and the upgrade contract.

**Source**: Intent brief "The first post deepens the AC-2 update"; cleaned transcript "AC-2 team announcement" (topics only) and "Blog post versus the team message".

**Acceptance Criteria**:
- [ ] GIVEN the published post WHEN a reader looks for context behavior THEN it explains that project knowledge is read as one matching topic, old specs can be found by name, and the full text of at most one or two spec files is opened.
- [ ] GIVEN the published post WHEN a reader looks for session behavior THEN it explains that a finished plan task records a checkpoint and the same session continues through the remaining tasks, review, and the QA draft, and that a new chat is for a session that actually stopped.
- [ ] GIVEN the published post WHEN a reader looks for where knowledge is stored THEN it explains that business rules and architecture decisions are written in different places, on different requests, and that nothing is published to Confluence without an explicit human approval.
- [ ] GIVEN the published post WHEN a reader looks for the upgrade contract THEN it states which project-owned paths stay untouched, that a missing decisions folder is added, and that a submodule layout and a plain file copy are different update paths.
- [ ] GIVEN the team message WHEN a reader compares it with the post THEN the post does not repeat the role sections, the chat how-to lines, or the two upgrade command blocks.
- [ ] GIVEN the post WHEN a reader wants the version ledger THEN the post links to the changelog entry for this change.
- [ ] GIVEN the post WHEN it goes live THEN a human has approved the text, and the wording matches the behavior that actually shipped.

**Additional Acceptance Checks**:
- The post is in English.
- The post names its author and date.
- The post stands alone for a reader who never received the team message.

**High-Level Technical Notes**: None beyond the mechanisms already named in the approved brief. Do not treat the team message as copy to paste.

**Priority**: High

## Dependencies

| Task | Depends On | Type | Notes |
|------|-----------|------|-------|
| Story 3.1 | Story 1.1 | Blocked by | The AC-2 post needs a blog page to be published on. |
| Story 3.1 | Story 2.1 | Blocked by | The post is written against the publishing rule so it does not repeat the notice. |
| Story 1.2 | Story 1.1 | Related to | Search indexing applies once a post exists to find. |
| Story 1.1 | DHI-653 | Related to | The navbar already has an information-architecture task. The blog link is an addition beside Changelog, not a redesign of the docs clusters. |

## Assumptions

| # | Assumption | Confidence | Impact if Wrong |
|---|-----------|------------|-----------------|
| 1 | Posts are in English because the docs site is English only. The Gate 0 reply approved the three-layer split and did not correct the English recommendation. | Medium | A Polish post, or a Polish blog beside an English site, would be a new story. |
| 2 | The four mechanisms in Story 3.1 are the whole first post. | High | Another mechanism from AC-2 would be added to that story's acceptance criteria, not a second post. |
| 3 | The publishing rule is a maintainer checklist used before approval. It does not need to be a public docs page. | Medium | If the team wants the rule visible to every reader, Story 2.1 grows a public page. |
| 4 | AC-29 is not part of this breakdown. | High | A later workshop adds a second post. |

## Out of Scope

Items explicitly excluded from this task breakdown:
- Republishing the AC-2 team message (role blocks, chat commands, upgrade scripts).
- Replacing or hand-editing the generated changelog.
- A blog post for every changelog bullet.
- Generating posts from agent transcripts or publishing them at the end of an implementation session.
- Comments, newsletter, or a separate content system.
- Translating the whole docs site into Polish.
- Redesigning the docs information architecture (DHI-641), beyond adding the Blog entry beside Changelog.
- A post about the AC-29 Claude Code mount.

## Open Questions for Stakeholders

| # | Question | Context | Impact |
|---|----------|---------|--------|
| 1 | None. Language is recorded as Assumption 1. | Gate 0 approved the split. English was recommended in the same turn and not corrected. | If English is wrong, say so before Story 3.1 is written. |
