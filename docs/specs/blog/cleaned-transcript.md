# Blog — Cleaned Transcript

## Meeting Metadata

| Field | Value |
|---|---|
| Date | 2026-09-24 |
| Duration | Single written request (not a timed meeting) |
| Topic | Technical blog section on the Agent Collections documentation site |
| Context | Ideate request via `eversis-analyze-materials`. The requester wants a blog on the public docs site for technical posts about recent project changes, in the style of the Next.js security-update post. A follow-up message supplies the real announcement this blog should be able to carry: a team note about the AC-2 framework update, plus a UX review of that note. |

## Participants

| Name | Role |
|---|---|
| Piotr Niemirski | Requester |

## Executive Summary

The requester wants a blog section on the documentation site, dedicated to technical posts that explain recent changes in Agent Collections. The reference for tone is the Next.js post [Next.js Security Update for a Critical Upstream Issue](https://nextjs.org/blog/nextjs-security-update-september-22-2026) (22 September 2026). The reference for structure is a Polish team announcement about the AC-2 framework update, rewritten after a UX review so each role (BA, Dev, QA) sees its own impact and the matching action once, followed by upgrade commands and a short failure FAQ.

## Discussion Topics

### A blog for technical change posts

- Add a blog section under `website/`, separate from the existing documentation pages.
- Posts should describe recent changes in the project.
- The section is for technical writing, not a general marketing blog.

### Reference style: Next.js change posts

- The liked example states, in order: what shipped, which versions, who is affected, what the impact is, and the exact upgrade command.
- It separates severity and scope (Node.js `ImageResponse` in `next/og` on Next.js `>=16.2.0 <16.3.6`) from what is not affected (Edge `ImageResponse`; Next.js 15.x gets hardening only, not the remote-code-execution issue).
- Authors are named. The post is dated. It links the framework advisory and the upstream advisory.
- It is a narrative about one notable issue, not a list of every change in the release.

### Prior session as subject-matter context

- The requester pointed at session `7f2a79fb-9722-4225-a9ed-2be642f0cf05` as optional context.
- That id is not present under this project's agent transcripts or elsewhere under the local Cursor data that was searched.
- The follow-up supplies the missing subject: a team message about changes delivered under AC-2, not the AC-29 Claude Code mount thread.

### AC-2 team announcement and its UX review

- The requester shared a UX review of a technical team message, then a rewritten version of that message.
- What already works: split by role (BA, Dev, QA), concrete pairs of examples (a technical decision such as Postgres vs Redis, versus a domain rule such as rounding prices to 0.05), and bash commands the reader can copy.
- Problem A — the same four or five capabilities were told three times (what changed, then by role, then how to use). Readers start skipping. "How to use" belongs inside the role section.
- Problem B — the non-submodule upgrade block repeated the submodule commands (`cd vendor/agent-collections`, `git checkout`, `git add vendor/...`). A plain file copy is not a git repo, so those commands fail with `fatal: not a git repository`. The rewritten version uses two different command blocks.
- Problem C — mixed greeting ("Cześć Everyone"), typos, and a cut-off word. The rewritten greeting is "Cześć wszystkim".
- Recommended order: two-sentence inverted-pyramid opening; what changes per role with the action inline; upgrade instructions for developers and leads; a short FAQ for failures (dirty submodule, missing `install-selection.json`, restart the IDE, commit so the team gets the config).
- The rewritten announcement says the update orders context handling: the agent does not fill its window with old task history, implementation sessions are not stopped artificially, and technical decisions are separate from business rules. Upgrade targets repos that use `vendor/agent-collections/`, does not overwrite project-owned paths, and adds `docs/decisions/` when it is missing.
- Role-specific actions named in the rewrite: BA adds a domain fact with an approval preview and may get a Confluence comment draft that a human publishes; developers record an architecture decision and continue a plan through checkpoint, tests, review, and QA in one session; QA still receives a Fine draft, and a knowledge-review reminder appears after five tasks.

### What the site already publishes

- The docs site is Docusaurus, English only, at `https://agent-collections.vercel.app`.
- A Changelog page already exists in the navbar. It is generated from root `CHANGELOG.md` (Keep a Changelog, SemVer). Editors are told not to hand-edit the generated page.
- The Docusaurus blog is switched off (`blog: false`). Site search does not index a blog.
- The task baseline has no blog item. The closest overlap is epic DHI-641 (documentation site UX/UI, intent-based information architecture), including DHI-653 (align the header navbar with the docs information architecture).

### Blog post versus the team message

- The blog post must deepen what was already sent. It must not repeat the message.
- Blog posts are a technical discussion of the changes.
- The role split, copy-paste commands, and FAQ belong to the team note. They are not the outline of the post.

## Key Decisions

| # | Decision | Made By | Conditions / Caveats |
|---|----------|---------|---------------------|
| 1 | Three layers stay separate: the team message is the notice, the changelog is the full ledger, the blog is a technical discussion that deepens the notice and must not repeat it. | Piotr Niemirski | Approved 2026-09-24 ("Ten podział jest ok"). |

## Action Items

| # | Action | Assigned To | Deadline |
|---|--------|-------------|----------|
| 1 | Propose an approach and record it as an intent brief for review before any backlog extraction. | Analyst | This session |

## Open Questions

| # | Question | Raised By | Notes |
|---|----------|-----------|-------|
| 1 | Which session was meant by `7f2a79fb-9722-4225-a9ed-2be642f0cf05`? | Analyst | Id not found. Superseded as the content source by the AC-2 team message in the follow-up. |
| 2 | Should the public docs blog publish this announcement in Polish, as written for the team, or in English, matching the rest of the site? | Analyst | The draft is Polish. The site locale is English only. |

## Preserved Context

> "chciałbym w website/ utworzyć sekcję blogowa, która byłaby dedykowana wpisom technicznym opisującą ostatnie zmiany w projekcie."
> — Piotr Niemirski, regarding the requested section

> "Bardzo podoba mi się styl wpisów dokumentujący zmiany w next.js"
> — Piotr Niemirski, regarding [the 22 September 2026 Next.js security update](https://nextjs.org/blog/nextjs-security-update-september-22-2026)

> "Kontekstem może być ostatnia sesja: 7f2a79fb-9722-4225-a9ed-2be642f0cf05."
> — Piotr Niemirski, regarding source material for the kind of change a post would cover

> "Podział na role (BA, Dev, QA): To strzał w dziesiątkę. Każdy od razu wie, do którego akapitu przewinąć stronę."
> — Piotr Niemirski, regarding what already works in the AC-2 announcement

> "Sekcję „Jak skorzystać” warto zintegrować bezpośrednio z rolami lub z listą zmian."
> — Piotr Niemirski, regarding the triple-redundancy problem

> "Krótki wstęp (Inverted Pyramid)… Co to zmienia dla Ciebie (Perspektywa ról)… Instrukcja aktualizacji… Wskazówki / FAQ."
> — Piotr Niemirski, regarding the recommended message architecture

> "Pamiętaj, że wpis blogowy ma pogłębiać to zostało wysłane w wiadomości, to nie może być powtórzenie. Wpisy na blogu mają być technicznym omówieniem zmian."
> — Piotr Niemirski, regarding the blog versus the team message
