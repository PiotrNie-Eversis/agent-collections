# docs-readme-scaffolding-gap - Analysis Result

**Origin:** User request (this session) — user observed that after installing `agent-collections` into `/Users/piotrniemirski/Documents/Projects/user-profile`, the `docs/*` subfolders are missing `README.md` files.
**Related Jira:** none (framework installer bug, not consumer-project-scoped).
**Workflow:** Research **approved** (gap answers locked 2026-08-14: Q1 = C, Q2 = top-level only, Q3 = adapt cursor-collections model). Plan: modify installer + `--upgrade`/`--sync` backfill + new top-level READMEs + test coverage.

---

## Task Details

| Field | Value |
|---|---|
| Jira ID | none |
| Title | Installer scaffolds `docs/context/` and `docs/plans/` as empty directories — no `README.md`, unlike `docs/specs/` |
| Description | `scaffold_project()` in `scripts/lib/setup-agent-collections/scaffolding.sh` creates the "docs triad" (`docs/context/`, `docs/plans/`, `docs/specs/`) on install, but only writes a `README.md` for `docs/specs/`. `docs/context/` and `docs/plans/` get `mkdir -p` only. |
| Priority | Medium — cosmetic/documentation gap, not functionality-blocking, but contradicts the framework's own documented triad contract |
| Reporter | User, this session |
| Created Date | 2026-08-14 |
| Due Date | n/a |
| Labels | agent-collections, installer, scaffolding, documentation |
| Estimated Effort | Small — add two README template blocks (or template files) to the scaffolding script |

---

## Business Impact

- **Confirmed in the reported consumer project.** `user-profile/docs/` has `context/`, `plans/`, and `specs/` subfolders. Only `docs/specs/README.md` exists; `docs/context/` and `docs/plans/` contain no `README.md` at all (verified via directory listing).
- **Reproduces inside the framework's own repo.** `agent-collections/docs/context/agent-collections/` has no `README.md` (only `delivery-index.md`, `task-baseline.md`), while a sibling folder `agent-collections/docs/context/eog/` *does* have one — an inconsistency that shows the gap isn't unique to `user-profile`, and that any existing `docs/context/*/README.md` files were added by hand, not by tooling.
- **Contradicts the framework's own stated contract.** `docs/architecture/agents-md-standard.md` §"Install contract (AC #3)" explicitly states: *"Also scaffold: Prefer creating `docs/context/`, `docs/plans/`, `docs/specs/` (with README scaffolds) when missing — same triad."* The installer does not honor this for two of the three folders.
- **The framework's own `docs/plans/README.md` asserts the expectation that is being violated.** It says: *"Keep this README committed so the **docs triad** (`docs/context/`, `docs/plans/`, `docs/specs/`) matches cursor-collections scaffolding expectations."* That sentence presumes `docs/context/` also carries a scaffolded README — it does not, anywhere the installer has run.
- **User-facing consequence:** a consumer opening a freshly-installed project sees `docs/specs/` explained (naming convention, triad role) but `docs/context/` and `docs/plans/` as silent empty folders with no in-repo explanation of their purpose or the `docs/specs/` vs `docs/plans/` distinction — undermining the "orientation map" goal the triad is meant to serve.

---

## Gathered Information

### Codebase

- **`scripts/lib/setup-agent-collections/scaffolding.sh`** (`scaffold_project()`, lines 4–56) — the actual enforcement point:
  - Lines 31–47: creates `docs/specs/` **and** writes `docs/specs/README.md` with real content (naming convention, example tree) — guarded by `if [[ ! -d "$specs_dir" ]]`.
  - Lines 49–53:
    ```bash
    for d in docs/context docs/plans; do
      if [[ ! -d "${target}/${d}" ]]; then
        mkdir -p "${target}/${d}"
      fi
    done
    ```
    Only `mkdir -p` — no README content, no template lookup, no `log_ok` message (the `docs/specs/` branch has a `log_ok "Created docs/specs/ directory."` line; this loop has none).
- **`docs/architecture/agents-md-standard.md`** §"Install contract (AC #3)" (line 102) — normative statement that scaffolding should include README content for all three triad folders. Table also marks this section: *"For future installer / bootstrap (Work Stream 5; **not implemented in TASK-531**)"* — i.e. the standard itself flags that the full install contract (including README scaffolds for context/plans) was known to be incomplete at the time that doc was written, and the gap was never closed.
- **`docs/specs/README.md`** (framework repo, tracked) — has real content and explicitly names the triad and links to `agents-md-standard.md`.
- **`docs/plans/README.md`** (framework repo, tracked) — has real content, explicitly says it exists to keep the triad's "scaffolding expectations" intact — but this file itself was hand-authored (git log shows it landed via commits `e54eb18` "Restructure AGENTS.md and enhance project documentation" and `bfe7174`, not via the installer script), confirming the installer never produces it.
- **`templates/` directory** (`AGENTS.template.md`, `claude-CLAUDE.template.md`, `claude-settings.json`, `eversis-project-stack.example.mdc`, `mcp.json`) — no `docs-context-README.template.md` or `docs-plans-README.template.md` exists. The `docs/specs/README.md` content in `scaffold_project()` is an inline heredoc, not a template file either — so there's no existing template asset to simply "point" the missing scaffolds at; new content has to be authored either as inline heredocs (matching the `docs/specs/` pattern) or as new template files (a small structural choice for planning).

### Verification performed this session

| Check | Result |
|---|---|
| `find user-profile/docs -maxdepth 3` | `docs/context/` and `docs/plans/` have no `README.md`; `docs/specs/README.md` exists |
| `find agent-collections/docs/{context,plans,specs}` (framework repo, self-hosted) | Same pattern: `docs/context/agent-collections/` has no README; `docs/context/eog/` has one (hand-added); `docs/plans/README.md` and `docs/specs/README.md` exist |
| `git log --oneline -- docs/plans/README.md` | Landed via doc-restructuring commits, not the installer script — confirms no automated path currently produces it |
| `grep` for `scaffold\|docs/context\|docs/plans` in `scripts/setup-agent-collections.test.sh` | No matches — **zero test coverage** for `scaffold_project()`'s directory/README behavior |
| Search for a `docs/context` or `docs/plans` README template file under `templates/` | None found |

### Key files and directories

- `scripts/lib/setup-agent-collections/scaffolding.sh:49-53` — the exact gap; needs a README-writing branch for `docs/context` and `docs/plans`, mirroring the `docs/specs` branch's guard (`if [[ ! -f ... ]]`, write-once, `log_ok` message).
- `docs/architecture/agents-md-standard.md:92-104` — normative install contract; already describes the target behavior, so the fix is "make code match doc," not "invent new policy."
- `docs/plans/README.md` and `docs/specs/README.md` (framework repo) — existing, hand-authored content that can serve as the model/source for what the new `docs/context/README.md` and `docs/plans/README.md` scaffold text should say (the `docs/specs/` version already matches; `docs/plans/` already has good content in *this* repo that could become the scaffold text; `docs/context/` has no equivalent anywhere to crib from — needs original content).
- `scripts/setup-agent-collections.test.sh` — no existing scaffolding tests; a fix should add coverage (create-if-missing, don't-overwrite-if-exists, matching the untested-but-implied contract for `docs/specs/`).

---

## Current Implementation Status

### Existing Components

- `scaffold_project()` — present, partially implements the triad (specs: dir + README; context/plans: dir only); **needs modification**.
- `docs/architecture/agents-md-standard.md` — present, already documents the intended end state; **no change needed** (code should conform to it, not the reverse).
- No automated tests for scaffolding behavior — **gap**, not "existing component to modify."

---

## Gap Analysis

### Question 1

#### Should `docs/context/README.md` and `docs/plans/README.md` be added only going forward (new installs / next `--upgrade` run), or also backfilled into already-scaffolded projects (including this framework repo's own `docs/context/agent-collections/` and the reported `user-profile`)?

| Option | Effect |
|---|---|
| **A — Fix installer only (going forward)** | New `setup-agent-collections.sh` runs and fresh installs get both READMEs. Existing installs (including `user-profile` and this repo's own `docs/context/agent-collections/`) stay as-is unless a human re-runs `--upgrade`/`--sync` or adds the files by hand. Matches the script's existing "create if absent, never overwrite" idiom used elsewhere in the same file (`AGENTS.md`, `.claude/CLAUDE.md`). |
| **B — Fix installer + backfill this repo now** | Same installer fix, plus manually add `docs/context/agent-collections/README.md` (or a generic `docs/context/README.md` if scaffolding targets the top-level folder rather than per-subfolder) in this repo during the same change, since this repo self-hosts and should demonstrate its own contract. |
| **C — Fix installer + also patch `--upgrade`/`--sync` to backfill any consumer project** | Broadest fix: running `--upgrade` on an existing install (like `user-profile`) would also create the missing READMEs there, closing the gap for the user's actual reported project without them re-running full setup. |

No recommendation forced — this is a plan-scope sequencing/scope decision, not something research should silently pick. Flagging for the plan-approval conversation.

**Locked (2026-08-14): Option C.** Fix `scaffold_project()` for future installs **and** patch the `--upgrade`/`--sync` path so re-running setup on an existing install (including `user-profile` and this repo's own `docs/context/agent-collections/`) backfills the missing top-level READMEs without requiring a full reinstall.

### Question 2

#### Should the missing README go at `docs/context/README.md` (top-level, one file) or per-subfolder (e.g. `docs/context/<project>/README.md`, mirroring `docs/context/eog/README.md` which the human added manually)?

The scaffolding loop (`scaffolding.sh:49-53`) only knows about `docs/context` and `docs/plans` as top-level paths — it has no knowledge of per-project subfolders like `agent-collections/` or `eog/` (those are created ad hoc by later `eversis-research` runs, not by `scaffold_project()`). So the installer can only reasonably scaffold a **top-level** `docs/context/README.md` explaining the folder's purpose and pointing to the triad — not a README per future subfolder, which doesn't exist yet at install time.

**Locked (2026-08-14): Top-level only.** `docs/context/README.md` and `docs/plans/README.md`, written at install time, matching how `docs/specs/README.md` already works (one top-level file, subfolders created later by workflow runs).

### Question 3

#### What content should `docs/context/README.md` say, since (unlike `docs/plans/`) no existing hand-authored version exists anywhere in the codebase to reuse?

`docs/architecture/agents-md-standard.md` already defines the role: *"Internal knowledge, architecture notes, task baselines (`docs/context/<project>/…`)."* Candidate content mirrors the tone/structure of the existing `docs/plans/README.md` and `docs/specs/README.md` (purpose, naming convention `docs/context/<project>/`, pointer to the triad and `agents-md-standard.md`). Exact wording is plan/implementation detail, not a research gap — flagging only that "no prior art to copy" (unlike `docs/plans/`) makes this the one truly new piece of content.

**User-supplied candidate source:** cursor-collections' own `docs/context/README.md` — <https://github.com/PiotrNie-Eversis/cursor-collections/tree/main/docs/context> — fetched this session (`gh api repos/PiotrNie-Eversis/cursor-collections/contents/docs/context/README.md`):

```markdown
# Context (`docs/context/`)

Place **internal knowledge** here: architecture notes, ADRs, wiki sync exports, onboarding. Use clear filenames.

**Task baseline (workshop continuity):** `docs/context/<project>/task-baseline.md` — optional epic/story index refreshed after successful Jira push from `@eversis-analyze-materials`. See [Jira Task Formatting](../../website/docs/skills/jira-task-formatting.md#step-9-baseline-refresh).

Referenced by research/plan steps and `@docs/context/` in Cursor.

## Framework repository policy (Cursor Collections)

In **this** monorepo, **`docs/context/*/` subfolders are gitignored** — project baselines, ADR folders, and wiki exports stay **local** and are not pushed. Only this **`README.md`** remains committed under `docs/context/`.

- Use `@docs/context/<project>/` in Cursor as today; files remain on disk.
- Share approved context via Confluence, Jira, or team exports — not via git in this repo.

**Consumer projects** may commit `docs/context/` by default. Opt in to the same local-only pattern with **`--gitignore-agent-artifacts`** (see [installation](../../website/docs/getting-started/installation.md)).
```

Verified against the current agent-collections codebase (this session):

- **Task baseline pointer is portable as-is** — `docs/context/<project>/task-baseline.md` convention and `website/docs/skills/jira-task-formatting.md` (with a step 9 baseline-refresh section) both already exist in agent-collections unchanged.
- **The "Framework repository policy" section is NOT portable as written.** cursor-collections gitignores `docs/context/*/` unconditionally in its own framework repo. agent-collections does not: `git ls-files docs/context/` shows `docs/context/agent-collections/*` and `docs/context/eog/*` are tracked/committed in *this* repo today. What agent-collections actually implements is more granular: `docs/specs/*/` is unconditionally local-only (`.gitignore:8`), while `docs/context/*/` is gitignored **only when a consumer opts in** via `--gitignore-agent-artifacts` (confirmed in `scripts/lib/setup-agent-collections/gitignore.sh:18-19`, `_artifact_gitignore_lines`) — and this repo does not apply that flag to itself. Copying cursor-collections' unconditional-gitignore claim verbatim would misdescribe agent-collections' actual behavior.
- **The `--gitignore-agent-artifacts` link target doesn't exist in prose yet.** `grep -rl "gitignore-agent-artifacts" **/*.md` (excluding node_modules) returns zero matches — the flag exists in `scripts/lib/setup-agent-collections/gitignore.sh` and `scripts/setup-agent-collections.sh` but `website/docs/getting-started/installation.md` never documents it by name. The new README should describe the opt-in behavior in its own words rather than link to a doc section that doesn't exist.
- **Cursor-only phrasing needs neutralizing** — `@docs/context/` in Cursor" as a primary instruction conflicts with `docs/architecture/agents-md-standard.md`'s neutralization dictionary (avoid `@`-attach as the only way to reference a path; state the neutral form first, Cursor as an aside).

**Locked (2026-08-14): Adapt, not copy.** Use the cursor-collections README as the structural model (purpose line → task-baseline pointer → "referenced by" line → repo policy note), but rewrite the "Framework repository policy" section to describe agent-collections' actual opt-in (`--gitignore-agent-artifacts`) behavior, phrase the Cursor `@`-attach mention as a secondary/neutral note per the neutralization dictionary, and drop or rephrase the dead link to an undocumented installation-doc section.

---

## Suggested next steps

1. ~~Human approves this research.~~ Done (Q1–Q3 locked 2026-08-14).
2. Human reviews and approves `docs-readme-scaffolding-gap.plan.md` before implementation.
3. Plan should also decide whether to fix the pre-existing inconsistency in this repo (`docs/context/agent-collections/` missing a README while `docs/context/eog/` has one) as part of the same change or as a follow-up.

---

## Changelog

| Date | Change |
|---|---|
| 2026-08-14 | Initial research: confirmed `scaffold_project()` in `scripts/lib/setup-agent-collections/scaffolding.sh` only writes `README.md` for `docs/specs/`, leaving `docs/context/` and `docs/plans/` as empty `mkdir -p` targets. Reproduced in both the reported `user-profile` project and this framework's own self-hosted `docs/` tree. Found the framework's own `docs/architecture/agents-md-standard.md` already documents the intended "README scaffolds for all three" contract (Install contract AC #3) but flags it as not implemented. No test coverage exists for scaffolding behavior. Raised three open questions (backfill scope, README granularity, new `docs/context/README.md` content) for plan-stage decision. |
| 2026-08-14 | Gap answers locked: Q1 = C (fix installer + `--upgrade`/`--sync` backfill); Q2 = top-level only (`docs/context/README.md`, `docs/plans/README.md`); Q3 = adapt cursor-collections' `docs/context/README.md` as structural model, with the "Framework repository policy" section rewritten to match agent-collections' actual opt-in (`--gitignore-agent-artifacts`) behavior instead of cursor-collections' unconditional gitignore, Cursor `@`-attach phrasing neutralized, and the dead `installation.md` link dropped/rephrased since that flag isn't documented in prose anywhere yet. |
| 2026-08-14 | Plan implemented (see `docs-readme-scaffolding-gap.plan.md`): `scaffold_project()` fixed, unit tests added, this repo's `docs/context/README.md` created, `CHANGELOG.md` updated. Code review PASS. |
