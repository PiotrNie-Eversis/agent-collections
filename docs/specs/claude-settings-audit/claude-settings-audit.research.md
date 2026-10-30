# claude-settings-audit - Analysis Result

**Origin:** User request (this session, Polish: "przeanalizuj aktualne ustawienia pliku") — analyze the current state of the repo-root `.claude/settings.json` after several rounds of edits this session (JSON-comment parse-failure fix, `ask`→`allow` switch, and further external edits adding a `deny` block and new patterns).
**Related Jira:** none (framework/repo governance, not DHI-scoped).
**Workflow:** Research drafted this session — awaiting human decision on Gap Analysis questions before any plan.

---

## Task Details

| Field | Value |
|---|---|
| Jira ID | none |
| Title | Audit the current content of `.claude/settings.json` (repo root) for correctness and risk, after this session's edits |
| Description | The file has been edited several times this session (by me and, per system reminders, externally by the user/a linter). Current state adds a `deny` list and broadens several `allow` patterns beyond what was reviewed earlier. User asked for a fresh analysis of the file as it stands now. |
| Priority | Medium — the file governs unprompted command execution in this repo; a scope regression here has real blast radius |
| Reporter | User, this session |
| Created Date | 2026-08-14 |
| Due Date | n/a |
| Labels | agent-collections, claude-code, permissions, security-review |
| Estimated Effort | Small — targeted edits to one JSON file, no app code |

---

## Business Impact

- This file directly controls which shell commands and tools execute **without a confirmation prompt** in this repo. Overly broad patterns here mean an agent (or the user, via autocomplete/copy-paste of a suggested command) can trigger a destructive operation with zero checkpoint.
- The file has drifted quickly across this session (ask-only → allow-only → broadened git scope → deny list added) without an end-to-end re-review of the combined effect. That's exactly the condition under which an unintended broad match slips in unnoticed.
- Two of the broadened patterns (`git commit *`, `git checkout *`) now cover sub-commands this repo's own baseline instructions single out by name as requiring a checkpoint before running (`git checkout` for discarding uncommitted work; amend-style commits are explicitly restricted to "only when the user explicitly requests it").

---

## Gathered Information

### Current file content (read this session)

```json
{
  "permissions": {
    "allow": [
      "Glob", "Grep", "LS", "Read", "View", "Edit", "Replace", "Write",
      "FileWrite", "FileRead", "FileEdit", "FileReplace",
      "Bash(git status*)", "Bash(git diff*)", "Bash(git log*)", "Bash(git show*)",
      "Bash(git branch*)", "Bash(git add *)", "Bash(git commit *)",
      "Bash(git checkout *)", "Bash(git switch *)",
      "Bash(npm run *)", "Bash(npm test*)", "Bash(npm list*)",
      "Bash(pnpm run *)", "Bash(pnpm test*)", "Bash(yarn run *)", "Bash(yarn test*)",
      "Bash(bun run *)", "Bash(bun test*)", "Bash(npx *)", "Bash(node *)",
      "Bash(prettier *)", "Bash(eslint *)", "Bash(tsc*)", "Bash(biome *)",
      "Bash(cat *)", "Bash(find *)", "Bash(grep *)", "Bash(pwd)", "Bash(which *)",
      "Bash(mkdir -p *)", "Bash(touch *)", "Bash(head *)", "Bash(tail *)"
    ],
    "deny": [
      "Bash(rm -rf /*)", "Bash(rm -rf ~*)", "Bash(sudo *)",
      "Bash(git push --force*)", "Bash(git reset --hard*)", "Bash(git clean -fdx*)"
    ]
  }
}
```

### Diff against the version I last fixed (this session, `Write` immediately before this request)

| Change | Detail |
|---|---|
| Added | `View`, `Replace` (legacy tool names, re-added after I'd removed them as dead/superseded earlier this session) |
| Added | `Write`, `FileWrite`, `FileRead`, `FileEdit`, `FileReplace` |
| Broadened | `git commit -m *` → `git commit *` (drops the `-m` restriction) |
| Broadened | `git checkout -b *` → `git checkout *` (drops the `-b`-only restriction) |
| Added | `Bash(git show*)`, `Bash(head *)`, `Bash(tail *)` |
| Added | entire `permissions.deny` block (6 patterns) — did not exist before |

### Cross-reference: this repo's own stated command-safety rules

The base system instructions for this session (not this file, but the operating rules Claude Code itself runs under) call out, by name, exactly two of the newly-broadened patterns as needing a checkpoint:
- *"NEVER run destructive git commands (push --force, reset --hard, checkout ., restore ., clean -f, branch -D) unless the user explicitly requests these actions."* — `git checkout` (bare, or with `--`/`.` targets) is named explicitly here as destructive (discards uncommitted work), alongside `reset --hard` and `clean -f`, both of which **are** in this file's `deny` list. `checkout` is not.
- *"CRITICAL: Always create NEW commits rather than amending... unless the user explicitly requests a git amend."* — `git commit *` (vs. the prior `git commit -m *`) now also unprompted-allows `git commit --amend`.
- *"In a git repository, run git status before any command that could discard uncommitted work (git checkout/restore/reset/clean...)"* — groups `checkout` with `reset`/`clean` as a class. This file denies two of the three and allows the third unprompted.

### Tool-name entries: which ones actually correspond to a real tool in this environment

| Entry | Status |
|---|---|
| `Glob`, `Grep`, `LS`, `Read`, `Edit`, `Write` | Match current tool names — effective. |
| `View` | Legacy pre-rename name for `Read`. Dead — matches no current tool, harmless but stale. |
| `Replace` | Legacy pre-rename name for `Edit`. Dead — same as above. |
| `FileWrite`, `FileRead`, `FileEdit`, `FileReplace` | Do not correspond to any tool name in this or any known Claude Code version. Dead entries — inert, but their presence could mislead a future reader into thinking they cover something real. |

### Deny-list coverage check

- `rm -rf /*`, `rm -rf ~*`, `sudo *`, `git push --force*`, `git reset --hard*`, `git clean -fdx*` are all genuinely high-blast-radius and correctly denied.
- Gap: `git clean -fdx*` is denied but plain `git clean -fd*` / `git clean -f*` (still deletes untracked files, no `-x`) is not explicitly denied — falls through to default (prompt) only because it's also not in `allow`, so no immediate risk, just an inconsistent boundary vs. the explicit deny.
- Gap: nothing in `deny` addresses the `git checkout` / `git commit --amend` broadening identified above — `allow` wins for those since there's no overlapping `deny` entry.

---

## Current Implementation Status

Single file, `.claude/settings.json` (repo root). No app code involved. No test coverage exists for this file's content (it's dev-environment config, not shipped to consumers — separate from `templates/claude-settings.json`, already established in the prior `claude-settings-default-allowlist` research this session).

---

## Gap Analysis

### Question 1

#### Should `git checkout *` and `git commit *` be narrowed back, or should matching `deny` entries be added?

| Option | Effect | Trade-off |
|---|---|---|
| **A — Narrow the `allow` patterns back** (`git checkout -b *` only; `git commit -m *` only) | Restores the exact scope reviewed earlier this session. | Simplest, matches what was already deliberately chosen once. Loses the (possibly intended) convenience of unprompted plain `git checkout <branch>` / `git commit --amend`. |
| **B — Keep broad `allow`, add targeted `deny` entries** (`git checkout -- *`, `git checkout .`, `git commit --amend*`) | Keeps branch-switch and non-amend commit variants unprompted, blocks only the specifically destructive/history-editing sub-cases. | More precise, but `deny` pattern coverage for `checkout` is easy to get wrong (many ways to write "discard working tree changes" — `checkout .`, `checkout -- .`, `checkout -- <file>`, `checkout HEAD -- <path>`); risk of an uncovered variant slipping through. |
| **C — Leave as-is** | No change. | Not recommended — leaves a known gap against this repo's own explicitly stated git-safety rules, for no stated benefit (no indication the broadening to bare `checkout`/`commit` was a deliberate, reasoned choice vs. an incidental widen). |

**Recommendation: A.** The narrower scope was already the deliberately-reviewed state earlier this session; nothing in the conversation indicates the further broadening to bare `git checkout *` / `git commit *` was an intentional, considered choice (vs. B's harder-to-get-right deny patterns). Narrowing is the lower-risk fix.

**Locked (2026-08-14): Option A.** Reverted to `git checkout -b *` and `git commit -m *`.

### Question 2

#### Should the dead/non-existent tool-name entries (`View`, `Replace`, `FileWrite`, `FileRead`, `FileEdit`, `FileReplace`) be removed?

These match no real tool in this or any known Claude Code version — they're inert. Two options:

| Option | Effect |
|---|---|
| **A — Remove them (recommended)** | Cleaner file; avoids a future reader assuming these names cover something real. |
| **B — Leave them** | Harmless today, but silently stale if it turns out they *did* correspond to some other client/version's naming the user intends to also support. |

**Recommendation: A**, unless there's a specific other tool/client in mind that actually uses those names — flagging for human confirmation rather than assuming.

**Locked (2026-08-14): Option A.** Removed `View`, `Replace`, `FileWrite`, `FileRead`, `FileEdit`, `FileReplace`.

### Question 3

#### Should `git clean -fd*` / `git clean -f*` (without `-x`) be added to `deny` for consistency with `git clean -fdx*`?

Currently a non-issue in practice (neither is in `allow`, so both prompt by default), but the `deny` list's own stated intent — block destructive git ops — is inconsistently scoped (blocks the `-fdx` variant specifically, not the class). Low priority; worth a one-line addition (`Bash(git clean -f*)`) for completeness if Question 1/2 changes are being made anyway.

**Locked (2026-08-14): Approved.** Replaced `Bash(git clean -fdx*)` with the broader `Bash(git clean -f*)` (superset — covers `-f`, `-fd`, `-fdx`, etc. in one entry rather than two overlapping ones).

---

## Suggested next steps

1. Human decides Questions 1–3 above.
2. If any changes are approved: write `claude-settings-audit.plan.md` (or, given the small size, this may qualify for Quick Flow — narrow fix, single file, ≤3 files touched, adequacy already established by this research) covering the specific edits to `.claude/settings.json`.
3. No test/doc updates needed elsewhere — this file is dev-only, decoupled from `templates/claude-settings.json` (confirmed in the prior `claude-settings-default-allowlist` research).

---

## Changelog

| Date | Change |
|---|---|
| 2026-08-14 | Initial audit of `.claude/settings.json` as it stands after this session's edits: flagged `git checkout *` / `git commit *` broadening as inconsistent with this repo's own explicit git-safety rules (checkout/amend named alongside reset --hard/clean -fdx, which *are* denied); flagged 6 dead tool-name entries (`View`, `Replace`, `FileWrite`, `FileRead`, `FileEdit`, `FileReplace`); flagged inconsistent `git clean` deny coverage. Recommended narrowing the two git patterns back and removing dead entries, pending human confirmation. |
| 2026-08-14 | Gap answers locked: Q1 = A (narrowed `git checkout *`→`git checkout -b *`, `git commit *`→`git commit -m *`); Q2 = A (removed 6 dead tool-name entries); Q3 = approved (replaced `git clean -fdx*` deny with broader `git clean -f*`). Implemented directly (Quick Flow — single file, adequacy established). `.claude/settings.json` re-validated as parseable JSON (39 allow, 6 deny entries). |
| 2026-08-19 | DELTA — new angle: analyzed today's uncommitted diff (git status: `M .claude/settings.json`) specifically for **Claude Code workflow fluency in daily use** (prompt friction), not security/correctness. See "2026-08-19 — Fluency analysis of uncommitted diff" below. Analysis-only; no plan requested yet. |

---

## 2026-08-19 — Fluency analysis of uncommitted diff

**Scope of this pass:** the file already carries uncommitted local edits (not covered by the 2026-08-14 entries above). This pass asks a narrower question than the prior audit: does the *current* diff reduce or increase permission-prompt friction for everyday Claude Code use in this repo?

### The diff

```diff
-      "Bash(cd ./* && git log*)",
-      "Bash(cd ./* && git status*)",
-      "Bash(cd ./* 2>/dev/null || cd ./*; pwd; git status*)",
-      "Bash(cd ./* && git diff *)",
-      "Bash(cd ./* && git show*)",
-      "Bash(cd ./* && git branch*)",
-      "Bash(cd ./* && git * | grep *)",
-      "Bash(cd ./* && git * ; echo *)",
-      "Bash(git -C ./* status*)",
-      "Bash(git -C ./* diff*)",
-      "Bash(git -C ./* log*)",
-      "Bash(git -C ./* show*)",
+      "Bash(git status*)",
+      "Bash(git diff*)",
+      "Bash(git log*)",
       "Bash(git show*)",
       "Bash(git branch*)",
       "Bash(git add *)",
-      "Bash(git diff *)",
       "Bash(git commit -m *)",
       "Bash(git checkout -b *)",
       "Bash(git switch *)",
+      "Bash(git -C * diff*)",
       ...
-      "Bash(yarn tsc *)",
-      "Bash(yarn jest *)",
       "Bash(yarn lint *)",
+      "Bash(yarn build *)",
       ...
-      "Bash(tail *)"
+      "Bash(tail *)",
+      "Bash(cd *)",
+      "Bash(ls *)"
```

### Finding 1 — Dropping the `cd ./* && git …` compound patterns is a fluency win, not a regression

These 8 removed entries were trying to allowlist the *anti-pattern* this same environment's own base instructions warn against: "never prepend `cd <current-directory>` to a git command — git already operates on the current working tree, and the compound triggers a permission prompt." The old patterns were a workaround for that friction, and a fragile one — each was a distinct fixed string shape (`cd ./* && git status*`, a `2>/dev/null ||` fallback variant, a `| grep *` variant, a `; echo *` variant) that only matched the exact compound shape it was written for. Any new compound shape (a different `&&` chain, a different fallback) would still prompt.

Replacing them with bare `git status*` / `git diff*` / `git log*` fixes the root cause instead of special-casing symptoms: since the Bash tool's cwd persists across calls, a plain `git status` already operates on the right tree without a `cd` prefix, and now runs unprompted regardless of which compound shape someone might otherwise have typed. Net effect: **fewer prompts**, and the two-call pattern (`cd <dir>` then bare `git status`) that's now enabled by the new blanket `Bash(cd *)` entry is exactly the shape the base instructions recommend in place of the compound.

### Finding 2 — `git -C * diff*` is the one `-C` variant kept, and it's inconsistent

The old four `git -C ./* {status,diff,log,show}*` entries all get collapsed into a single `git -C * diff*`. That's a real narrowing, not just a rewrite: `git -C <path> status`, `git -C <path> log`, and `git -C <path> show` now fall through to a prompt (no longer allowlisted), while `git -C <path> diff` for an *arbitrary* path (the old entries were anchored to `./*`, the new one is not) stays unprompted. If the multi-directory git workflow the old patterns existed for is still in play (e.g. this repo's `packages/*` or `mcp/*` subtrees), this is a friction regression for 3 of 4 commands and an inconsistent one — no evident reason `diff` should be privileged over `status`/`log`/`show` for a non-cwd repo. Worth confirming whether that workflow is still needed; if not, this is dead weight either way.

### Finding 3 — `yarn tsc *` / `yarn jest *` dropped, `yarn build *` added

Checked this repo for actual usage: no `package.json` in the tree defines a `tsc` or `jest` yarn script (only `mcp/eversis-collections-mcp/package.json` has a plain `"build": "tsc"`, unrelated to a `yarn tsc` invocation). Bare `Bash(tsc*)` is already allowlisted separately, so direct `npx tsc` / `tsc` still runs unprompted — only the specific `yarn tsc …` / `yarn jest …` invocation shape now prompts, and nothing in this repo currently types that shape. **Low real-world impact here**, though a consumer project that scripts `"tsc": "tsc"` / `"jest": "jest"` in `package.json` and is used as a template target would see new prompts for those two commands. Adding `yarn build *` closes a real gap (build wasn't previously allowlisted at all) and is an unambiguous fluency improvement.

### Finding 4 — `Bash(cd *)` and `Bash(ls *)` added

Both are net positive for daily flow: `ls *` is a common, low-risk, frequently-needed lookup that had no prior blanket allow (only `find *` did). `cd *` alone changing directory is not itself a destructive or disclosive action (per the base instructions' own reversibility framing — a `cd` is trivially reversible and affects nothing outside the local shell), and it's what makes Finding 1's two-step replacement pattern (`cd <dir>` + bare git command) actually friction-free. No corresponding `deny` entry is affected since none of the denied patterns are `cd`-only.

### Net assessment

The diff is a **net fluency improvement**: it removes 8 fragile compound-command entries that were compensating for an anti-pattern this environment's own instructions warn against, replaces them with a more robust bare-command approach, and adds two clear gaps (`yarn build`, `ls`). The one open question is Finding 2 — whether the narrowed `git -C` coverage (diff-only, arbitrary path) still serves whatever multi-directory workflow the original four `-C ./*` entries existed for, or whether that workflow is gone and the single remaining entry is itself now dead weight.

### Gap Analysis (this pass)

#### Question 4

**Is the multi-directory `git -C <path>` workflow (that motivated the original 4 entries) still needed day-to-day in this repo?**

| Option | Effect |
|---|---|
| **A — No, drop `git -C * diff*` too** | Removes the one remaining inconsistent entry; any multi-directory git check falls back to `cd <dir>` + bare command (already unprompted per Finding 1). Simplest, fully consistent. |
| **B — Keep, and restore `status`/`log`/`show` alongside `diff`** | Restores parity across the four git read commands for arbitrary-path use, at the cost of 3 more allow entries. |
| **C — Leave as-is (diff-only)** | No change; the asymmetry (diff allowed, status/log/show not) persists with no stated reason. |

**Locked (2026-08-19): Option A.** Drop `git -C * diff*` — no multi-directory `git -C` workflow confirmed as needed; falls back to `cd <dir>` + bare command (already unprompted per Finding 1).

---
