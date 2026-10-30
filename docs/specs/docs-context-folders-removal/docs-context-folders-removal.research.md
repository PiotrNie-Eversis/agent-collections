# docs-context-folders-removal - Analysis Result

**Origin:** User request (this session, via `/eversis-implement @docs/context/agent-collections & @docs/context/eog`) — analyze how to safely remove these two folders from the repo.
**Related Jira:** TASK-515 (epic close-out traceability lives in `docs/context/agent-collections/`), TASK-542 (EOG pilot; its evidence pack lives in `docs/context/eog/`). Not itself a scoped Jira task.
**Workflow:** Research drafted this session. Finding is **not** "safe to remove now" for either folder — see Conclusion. No plan follows unless the human wants to act on the preconditions below.

---

## Task Details

| Field | Value |
|---|---|
| Jira ID | none (repo governance / documentation audit) |
| Title | Can `docs/context/agent-collections/` and `docs/context/eog/` be safely removed? |
| Description | User asked for analysis of how to safely remove the two named project subfolders under `docs/context/`. |
| Priority | Low — audit, not a bug or blocker |
| Reporter | User, this session |
| Created Date | 2026-08-14 |
| Due Date | n/a |
| Labels | agent-collections, documentation, governance, audit |
| Estimated Effort | N/A — analysis only |

---

## Business Impact

- If removed cleanly, the repo sheds two project-specific context folders that (per `docs/context/README.md`) are committed as "reference material," reducing repo surface.
- If removed **prematurely**, the repo loses: (a) the only committed traceability index for the closed TASK-515 epic (waiver record for several stories that skipped per-story spec folders), and (b) the live evidence pack for an **in-progress** pilot (TASK-542 Q5 window), plus breaks several already-published external links (docs site, GitHub blob links in the migration guide).

---

## Gathered Information

### Folder contents (read this session)

**`docs/context/agent-collections/`** (2 files):

| File | Purpose |
|---|---|
| `task-baseline.md` | Epic/story index for TASK-515 — table of all TASK-516–542 children, status "To Do" (Jira status not synced to delivered state per `delivery-index.md`'s own residual list), session archive index |
| `delivery-index.md` | TASK-515 traceability: Jira key → wave → delivered path on `main` → spec folder. Explicitly states it **replaces** mandatory retroactive per-story folders for TASK-530, 532–540 ("CQ2 waiver") — i.e., for those stories this file is the *only* record of what was delivered where |

**`docs/context/eog/`** (4 files):

| File | Purpose |
|---|---|
| `README.md` | EOG consumer area-overlay mapping (portal↔frontend, cms↔backend), install posture notes |
| `pilot-evidence.md` | TASK-542 WNF-03 proxy measurements, collision checklist, **residual steps** — item 4 "Q5 sessions from 2026-08-10 — fill checklist outcomes above" is still open; item 5 "Submodule + SemVer pin after Q5" also open |
| `upgrade-runbook.md` | Legacy Cursor Collections → Agent Collections migration steps specific to EOG |
| `findings-backlog.md` | Draft backlog notes (not read in full — not load-bearing for this question) |

Both folders are **intentionally committed**, not gitignored: `docs/context/README.md` states this repo does not apply `--gitignore-agent-artifacts` to itself, and names `agent-collections/` explicitly as an example kept "as reference material."

### Cross-reference check

Ran a repo-wide search (excluding the folders' own internal cross-links) for `docs/context/agent-collections` and `docs/context/eog`.

**Structural / generic references to `docs/context/` itself** (README.md, AGENTS.md, CLAUDE.md, `.ai/rules/`, `.ai/skills/`, website docs, install scripts) — these describe the folder pattern, not these two specific subfolders. Removing the two named subfolders does **not** break these; `docs/context/README.md` and the pattern survive independently. The installer (`scripts/lib/setup-agent-collections/scaffolding.sh`, and its tests) only scaffolds/checks `docs/context/README.md` — it has no code path that creates or depends on an `agent-collections/` or `eog/` subfolder existing.

**Specific references that would break or go stale:**

| File | Reference | Effect of removal |
|---|---|---|
| `docs/architecture/isolation-strategy.md:128` | Cites `docs/context/eog/` pilot notes as the evidentiary basis for *not* excluding `charts/**` from default area profiles | A canonical architecture doc (confirmed load-bearing in the prior `docs-architecture-necessity` research) would cite a removed folder as its evidence source |
| `website/docs/getting-started/migration-from-cursor-collections.md:94,96` | Live GitHub blob link to `docs/context/eog/README.md`, plus prose citing pilot measurement numbers "under `docs/context/eog/`" | Published docs-site page would contain a dead GitHub link and unverifiable claims once the folder is gone from `main` |
| `website/docs/isolation.md:45` | "Empirical pilot notes live under `docs/context/eog/` when present." | Already hedged ("when present") — degrades gracefully, not a hard break |
| `docs/context/agent-collections/delivery-index.md:50,58` (self) | Points TASK-542 deliverable and the open Q5 residual item at `docs/context/eog/` | Internal self-reference; moot if this file is also removed, but stale if only `eog/` is removed and `delivery-index.md` is kept |
| `CHANGELOG.md:26,34`, `website/src/pages/changelog.md` (generated mirror) | Historical changelog entries naming both paths | Changelog entries are a record of *what happened*, not live links — acceptable to remain stale (same pattern already accepted for other historical entries in this repo) |

No script, test, or installer logic reads either folder's file contents (only `docs/context/README.md` is asserted on). Removal is a **pure documentation/traceability** decision, not a functional one.

### TASK-542 EOG pilot status (is it actually finished?)

`pilot-evidence.md` records the Q5 human pilot window as **starting 2026-08-10**, requiring "≥5 business days or ≥3+3 Cursor FE + Claude BE sessions," with the collision checklist still marked "Incidents: none recorded yet (Q5 not started)" at the file's last edit (2026-08-07, before the window opened). Today's date is 2026-08-14 — four calendar days into the window, likely fewer business days. Residual steps 4 ("fill checklist outcomes") and 5 ("submodule + SemVer pin, after Q5") are explicitly marked open, not done. There is no evidence in the repo that this session's Q5 window has been closed out or the checklist filled in.

### TASK-515 epic status

`task-baseline.md`'s own table still shows Jira status "To Do" for all child tasks, while `delivery-index.md` (same folder) shows most waves already delivered on `main` and flags "Jira status sync — Human (CQ5) — Align TASK-516–542 with delivered state" as a residual item. The epic's Jira record and this folder are the **only** place the wave-level delivery mapping exists in committed form for the CQ2-waived stories (TASK-530, 532–540) — there is no equivalent content duplicated elsewhere in the repo (checked `CHANGELOG.md`: it lists deliverables but not the Jira-key → spec-folder mapping table).

---

## Current Implementation Status

No implementation involved — this is a verification-only analysis. Both folders exist, are committed, and are actively cited by at least one canonical architecture doc and one published docs-site page.

---

## Gap Analysis

### Question 1

#### Is it safe to remove `docs/context/agent-collections/` now?

| Consideration | Finding |
|---|---|
| Installer/script dependency | None — safe on that axis |
| External live references | Self-contained mostly; no external (non-`docs/context`) file links directly into this folder's files by path, only the generic `docs/context/` pattern |
| Content uniqueness | **Not safe** — `delivery-index.md` is the sole committed record of the TASK-515 CQ2 waiver (which stories skip per-story spec folders and why) and the wave → path traceability table; no duplicate exists elsewhere |
| Residual/open items | `task-baseline.md` and `delivery-index.md` both list unresolved human follow-ups (Jira status sync, SemVer tag) that reference this folder as their tracking location |

**Not safe to remove now.** The content is not duplicated anywhere else in the repo; removing it deletes the only record of why several TASK-515 stories have no per-story spec folder and loses the wave/delivery map for a still not-fully-closed-out epic (Jira status not yet synced).

### Question 2

#### Is it safe to remove `docs/context/eog/` now?

| Consideration | Finding |
|---|---|
| Installer/script dependency | None — safe on that axis |
| External live references | `isolation-strategy.md` (canonical architecture doc) and a published website page (with a GitHub blob link) both cite this folder directly by path |
| Pilot completeness | **Not safe** — the TASK-542 Q5 human pilot window opened 2026-08-10 and, per the file's own residual checklist, has not been marked complete; today is only 2026-08-14 |
| Content uniqueness | Sole location for WNF-03 proxy measurements and the collision checklist; not duplicated |

**Not safe to remove now.** Removing an active pilot's evidence pack mid-collection would destroy data the pilot is still gathering, and would leave `isolation-strategy.md` (load-bearing per the prior `docs-architecture-necessity` research) citing a source that no longer exists, plus a dead link on the published docs site.

### Question 3

#### What would make removal safe later, and what's the mechanism?

Assuming the human wants to revisit this after both blockers clear:

| Precondition | Owner | Status |
|---|---|---|
| Q5 pilot window closes, `pilot-evidence.md` checklist filled in | Human (Piotr, per file) | Open |
| TASK-515 Jira status synced to delivered state (CQ5) | Human | Open |
| SemVer tag `v0.1.0` cut | Human | Open |
| Decide fate of the *content*, not just the folder — e.g. fold the delivery-index traceability table into `CHANGELOG.md` (which already lacks the Jira-key→path mapping), or fold pilot conclusions into `isolation-strategy.md`'s own body instead of citing an external folder | Not yet decided | n/a |
| Update the 2–3 live references (`isolation-strategy.md:128`, migration guide GitHub link + prose) to point at wherever the content lands (or remove the citations if the underlying claim is restated inline) | Follow-up implementation task | n/a |

Mechanically, once preconditions are met, removal is a small, well-scoped change (delete 2 files + delete 4 files, edit 2–3 referencing files) — well under Quick Flow's 3-file threshold is not met (≥5 files touched), so it would run as Full Flow with a short plan, not Quick Flow.

---

## Conclusion

**Neither folder is safe to remove right now.** `docs/context/agent-collections/` holds the only committed TASK-515 delivery-traceability record (no duplicate exists); `docs/context/eog/` is an **active** pilot evidence pack (Q5 window open since 2026-08-10, not yet closed out) that a canonical architecture doc and a published docs-site page both cite by path. Removing either today would destroy source-of-truth content and break/degrade live references.

**Not locked — awaiting human decision** on whether to:
- (A) leave both folders as-is until Q5 closes and TASK-515 Jira sync completes, then revisit, or
- (B) proceed now anyway, accepting the loss of the delivery-index traceability content and the in-progress pilot evidence (would need explicit approval given the "no edits outside scope without approval" and content-preservation concerns above), or
- (C) something narrower — e.g. archive (move, don't delete) rather than remove.

---

## Suggested next steps (superseded — see DELTA below for current recommendation)

1. ~~No removal in this session — the evidence above argues against it.~~
2. ~~If the human wants to proceed anyway (option B), that requires an explicit override of the findings here before a `*.plan.md` is written.~~
3. ~~If the human prefers option A, revisit this research (DELTA) once Q5 closes and re-run the Question 1–2 checks.~~ — superseded: user proposed a fourth option (make local) not covered by A/B/C, see below.

---

## DELTA — 2026-08-14: "Make local" (gitignore) instead of remove

**Trigger:** User answered all three Gap Analysis questions with the same proposal: *"make these folders local? This is open-source project. Nobody else needs to know about the implementation epic."* This is a new option (call it **D**) not covered by the original A/B/C — untrack rather than delete, motivated by open-source audience concerns rather than content-preservation concerns.

### Does "make local" actually fit this repo's own pattern?

Yes — exactly. `docs/context/README.md` and `scripts/lib/setup-agent-collections/gitignore.sh` already implement this as a first-class installer feature for **consumer** projects: the `--gitignore-agent-artifacts` flag adds `docs/specs/*/` and `docs/context/*/` to `.gitignore` (via `_artifact_gitignore_lines()`), leaving only `docs/context/README.md` tracked. `docs/context/README.md:15` explicitly notes *"This repo does not apply `--gitignore-agent-artifacts` to itself."* Option D is simply flipping this repo to use, on itself, the exact mechanism it already ships for everyone else — not a new pattern.

### What Option D resolves from Q1/Q2, and what it does not

| Concern from Q1/Q2 | Resolved by "make local"? |
|---|---|
| Content-preservation (delivery-index traceability, pilot evidence) | **Yes** — untracking (`git rm --cached` + `.gitignore`) leaves the files on disk. Nothing is destroyed; the user keeps working local copies for personal/team reference. |
| `isolation-strategy.md:128` citing `docs/context/eog/` by path | **No** — once untracked, that path no longer exists in the tracked repo (or on GitHub going forward), so the citation still goes stale. Same follow-up edit needed as under outright deletion. |
| Migration guide's live GitHub blob link to `docs/context/eog/README.md` | **No** — same reasoning; the link 404s once the file is untracked and a fresh commit is pushed. Needs the same follow-up edit as deletion. |
| "Nobody else needs to know about the implementation epic" | **Partially — see critical caveat below.** |

### Critical caveat: this repo is already public, and history already contains this content

Checked before writing this DELTA:

- `git remote -v` → `origin` is `github.com-eversis:PiotrNie-Eversis/agent-collections.git`, and local `main` tracks `origin/main` with no unpushed commits on these paths — i.e. this is a **published, public GitHub repo**, not a private/pre-release one.
- Both folders already have multi-commit history on `main`: `docs/context/agent-collections/{task-baseline,delivery-index}.md` across `7a5efab`, `449174c`, `8add375`; `docs/context/eog/README.md` across `5d9954d`, `6368f16`, `8add375`. One of those commit **messages** itself is `DHI-515 Update links in documentation...` — the internal Jira project key is already sitting in plain text in pushed commit history.

This means there are two materially different things "make local" could mean, with very different risk:

| Flavor | Mechanism | Effect | Risk |
|---|---|---|---|
| **D1 — Untrack going forward** | `git rm --cached` on both folders' files, add `docs/context/agent-collections/*` and `docs/context/eog/*` to `.gitignore` (reusing `_artifact_gitignore_lines()` pattern), keep files on local disk | Stops **future** commits/pushes from including this content; GitHub's current file browser for `main` no longer shows these paths after the commit lands | Low — reversible, no force-push, no history rewrite, matches existing repo conventions (Git Safety Protocol default) |
| **D2 — Also scrub git history** | Rewrite history (`git filter-repo` or equivalent) to remove all past commits' copies of these files, then force-push `main` | Actually satisfies "nobody else needs to know" for anyone who wasn't already watching the repo | High — rewrites shared SHAs on a public repo, requires force-push, can break any existing forks/clones/CI referencing old commits; this is a destructive, hard-to-reverse operation this session will not perform without a separate, explicit confirmation naming the risk |

**D1 alone does not fully achieve "nobody else needs to know about the implementation epic"** — anyone who already has the repo cloned, or checks GitHub's commit history / uses `git log`, can still see every file and the `DHI-515` commit message. D1 only stops the *current* file tree from showing it and prevents further updates from being public. If full historical erasure is the actual goal, that is D2 and is a separate, much riskier decision.

### Recommendation

**D1**, not as a full solution to "nobody else needs to know" but as the correct, low-risk move given this repo's own conventions and the Git Safety Protocol's preference against destructive/history-rewriting operations. Concretely, for each folder:

- `docs/context/agent-collections/`: `git rm --cached delivery-index.md task-baseline.md`, add `docs/context/agent-collections/*` to `.gitignore`'s artifacts block, keep both files on disk locally (resolves the Q1 content-preservation blocker entirely — the traceability record isn't lost, just no longer published).
- `docs/context/eog/`: same treatment for its 4 files. Still need to update `isolation-strategy.md:128` and the migration guide's GitHub link/prose (Q2 blocker only half-resolved by D1 — those 2–3 references still need edits regardless of D1 vs full delete, since the path disappears from the public tree either way).
- TASK-542 Q5 pilot-in-progress concern (originally a "not safe to remove" blocker) becomes largely moot under D1: the pilot evidence isn't destroyed, just no longer public, so there's no urgency to wait for the window to close.
- D2 (history scrub) is **not recommended** to bundle into the same change — flag it as a separate, explicitly-confirmed decision if the user wants it, given the force-push/fork-breaking risk on a public repo.

**Not locked — awaiting human confirmation**: proceed with **D1 only** (untrack + `.gitignore`, keep local, update the 2–3 live citations), or does the user actually want **D2** (history scrub) despite the added risk, or a hybrid?

---

## Changelog

| Date | Change |
|---|---|
| 2026-08-14 | Initial research entry: inventoried both folders, cross-referenced repo-wide, found `docs/context/eog/` pilot (TASK-542 Q5) still open and `docs/context/agent-collections/delivery-index.md` holds the sole TASK-515 CQ2-waiver traceability record. Conclusion: not safe to remove either folder now; documented preconditions for a future safe removal. Awaiting human decision. |
| 2026-08-14 | DELTA: user proposed making both folders local (gitignored) instead of removed, for open-source audience reasons. Confirmed this reuses the repo's own existing `--gitignore-agent-artifacts` mechanism. Found this resolves the content-preservation blockers from Q1/Q2 (files stay on disk) but does **not** resolve the 2–3 live citations (`isolation-strategy.md`, migration guide) which still need edits either way, and does **not** fully achieve "nobody else knows" because the repo is already public with these files in pushed git history (confirmed via `git remote -v` and per-file `git log`, including a commit message literally containing `DHI-515`). Split into D1 (untrack going forward, low-risk) vs D2 (rewrite history, high-risk, requires separate explicit confirmation). Recommended D1. Awaiting human confirmation on D1 vs D2 vs hybrid before planning. |
