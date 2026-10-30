# Blog — Intent Brief

## Workshop Summary

| Field | Value |
|---|---|
| Workshop Date | 2026-09-24 |
| Participants | Piotr Niemirski |
| Source Materials | Written request; [Next.js security update, 22 September 2026](https://nextjs.org/blog/nextjs-security-update-september-22-2026); follow-up with the AC-2 team announcement and its UX review; docs site (`website/`, changelog page, navbar); task baseline `docs/context/agent-collections/task-baseline.md` (refreshed 2026-09-21). Session `7f2a79fb-9722-4225-a9ed-2be642f0cf05` was cited and not found. The AC-2 message replaces it as the content source. |
| Prepared By | Business analyst (eversis-analyze-materials) |

## Goal

Give readers a technical write-up of a framework change that the team message only announced. The post explains how the change behaves and where its boundaries are. It does not reprint the message.

## Recommended approach

Three layers, each with a different job. A blog post that repeats the team message fails this brief.

| Layer | Job | Already exists |
|---|---|---|
| Team message | Short notice. Who should scan which part, the action, the upgrade commands, the failure FAQ. The AC-2 UX review (role split, no triple retelling, distinct command blocks) applies here. | Sent by the maintainer. Not a page on the docs site. |
| Changelog | Complete SemVer ledger, including small fixes. Generated from root `CHANGELOG.md`. | Yes — navbar **Changelog** |
| Blog | Technical discussion of a change that deserves more than the notice. Problem, behavior, boundaries, what stayed the same. | No — Docusaurus blog is off |

The message is the source of *which* change matters. The post adds what the message had no room for: why the old behavior caused the problem, what the new behavior actually does, and which cases it does not cover. Commands and role how-tos stay in the message. The post may name an action when the technical point requires it. It does not walk the reader through the same checklist again.

A post earns a place when the change has a mechanism worth explaining (a read limit, a session rule, a split between two kinds of knowledge, an upgrade contract). A one-line fix stays in the changelog only.

Each post uses one shape, in the spirit of the [Next.js security update](https://nextjs.org/blog/nextjs-security-update-september-22-2026): dated, authored, scoped, and specific about what is and is not affected.

1. **What changed**, in technical terms, in a few sentences.
2. **Why** the previous behavior was a problem.
3. **How it behaves now**, including the limits (what is read, what is skipped, what a human must still approve).
4. **What did not change**, so a reader does not invent a wider fix.
5. A link to the changelog entry. The team message is not pasted underneath.

The first post deepens the AC-2 update. The message already told BA, Dev, and QA what to type and how to upgrade. The post explains the four mechanisms behind that note:

- Context reads: one matching topic from project knowledge, name-only search of old specs, full text of at most one or two spec files.
- Session continuity: a finished plan task records a checkpoint and continues through the remaining tasks, review, and QA in the same session. A new chat is for a session that actually died.
- Two stores: business rules and architecture decisions are written in different places and by different requests. Neither is published to Confluence without an explicit human approval.
- Upgrade contract: which project-owned paths the installer leaves alone, and that a submodule layout and a plain copy are different update paths. The post states that contract. It does not reprint the two bash blocks from the message.

The section (listing, post page, navbar entry next to Changelog, search) ships with this writing rule and that first post. A person writes the post and a human approves it before it goes live. AC-29 is not this pilot.

## In Scope

- A public blog section on the existing documentation site.
- The writing rule above: technical discussion that deepens a team notice and does not repeat it.
- The first post: a technical account of the AC-2 mechanisms (context reads, session continuity, separate decision store, upgrade contract).
- Navbar and search so a reader can find posts without hunting.
- Human approval before a post goes live.

## Out of Scope

- Republishing a team message as a blog post (same role blocks, the same how-to lines, the same upgrade scripts).
- Replacing or hand-editing the generated changelog.
- Publishing a post for every changelog bullet.
- Generating posts from agent transcripts or auto-posting at the end of an Implement session.
- Comments, newsletter, RSS marketing, or a separate CMS.
- A second locale for the whole documentation site. Language of the blog posts is the open Gate 0 item below, not a full site translation.
- Reworking the docs information architecture from epic DHI-641, except adding the blog entry in the navbar.

## Key Stakeholders / Actors

- Developer or tech lead who already saw the team note — reads the post to understand the mechanism and the boundaries.
- Business analyst or QA — reads the post when they need the same technical account, not a second copy of their role checklist.
- Maintainer who ships the framework change — writes the technical discussion from the change, using the team message only as the list of topics already announced.
- Piotr Niemirski — approves scope now, and later approves individual posts before publish.

## Candidate Epics

- Blog section on the docs site — listing, post page, navbar, search. Rationale: the section does not exist; the changelog cannot carry this narrative.
- Editorial rule for a technical change post — what changed, why, how it behaves now, what did not change, changelog link. The team message stays the notice. Rationale: a post that repeats the notice does not justify a blog.
- First post: technical account of the AC-2 update — context reads, session continuity, decisions kept apart from business rules, upgrade contract. Rationale: the message already covered roles and commands; the post has to add the mechanism.

## Baseline Overlap / Existing Backlog Notes

- No blog or changelog-narrative item in `docs/context/agent-collections/task-baseline.md`.
- Changelog sync is already shipped (root `CHANGELOG.md` is the source; the site page is generated). This proposal does not reopen that work.
- Epic DHI-641 (Documentation Site: UX/UI Restructuring) and DHI-653 (navbar aligned to the docs information architecture) own the header. A new navbar item should be checked against that epic so the blog link does not fight the four-cluster docs navigation. DHI-641 does not cover a blog.

## Open Questions

- None at Gate 0. Post language stays the assumption below.

## Assumptions

- Readers include people who already received the team message. The post must still stand alone for someone who did not.
- The changelog remains the complete record. The blog does not duplicate it, and it does not duplicate the message.
- The four AC-2 mechanisms listed above are the right depth for the first post. Wording is checked against the shipped behavior before publish.
- AC-29 is out of this pilot. It can be a later post if that fix needs the same treatment.
- Posts are in English, matching the docs site. The Polish team message stays the notice. Stated with the Gate 0 recommendation and not corrected.

## Gate 0 Approval

| Decision | Notes |
|---|---|
| Approved | 2026-09-24. Piotr Niemirski: the three-layer split is OK (team message = notice, changelog = ledger, blog = technical discussion that deepens the notice and must not repeat it). |
