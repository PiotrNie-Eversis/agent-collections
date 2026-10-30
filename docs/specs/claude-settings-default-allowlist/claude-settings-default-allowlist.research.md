# claude-settings-default-allowlist - Analysis Result

**Origin:** User request (this session) — after moving legacy tool names to current ones in the repo's own `.claude/settings.json` and asking how to auto-allow `git commit -m *`, user asked whether these `permissions.ask` commands are worth promoting to `permissions.allow` **for all users of the framework**, not just this repo.
**Related Jira:** none (framework governance / DX decision, not DHI-scoped).
**Workflow:** Research drafted this session — awaiting human decision on Gap Analysis questions before any plan.

---

## Task Details

| Field | Value |
|---|---|
| Jira ID | none |
| Title | Should `permissions.ask` entries (esp. `Bash(git commit -m *)`) become `permissions.allow` in the framework-wide template, so every consumer project gets them un-prompted by default? |
| Description | Root `.claude/settings.json` (this repo's own dev config) lists ~30 command patterns under `permissions.ask` — git write ops, package-manager run/test, linters, safe file reads. User asked for analysis of whether these should be auto-allowed, and specifically whether that should apply to **all users in the framework** (i.e. the shared template every consumer install is seeded from), not just this repo. |
| Priority | Low-Medium — DX/friction question, not blocking; but a wrong default here ships silently to every future consumer install |
| Reporter | User, this session |
| Created Date | 2026-08-14 |
| Due Date | n/a |
| Labels | agent-collections, claude-code, permissions, governance, dx |
| Estimated Effort | Small if scope stays doc/template-only; no app code involved |

---

## Business Impact

- **Two settings files, two audiences, already established this session:**
  - `.claude/settings.json` (repo root) — dev config for people working **on** this framework repo itself. Not read by the setup pipeline at all.
  - `templates/claude-settings.json` — the seed every **consumer** project's `.claude/settings.json` is generated from on first install (see Gathered Information).
  - The user's question spans both: their own root file is already decided (previous turns, `ask`-only, legacy tool names fixed). This analysis is about whether to also change the **template**, which has blast radius across every downstream adopter.
- **A template default is a silent, framework-wide security posture decision.** Every team that runs the installer with Claude selected inherits whatever `permissions.allow` ships in the template on their first run. They don't see this analysis, don't opt in individually, and may not audit `.claude/settings.json` before their first agent session.
- **This repo's own instructions (`CLAUDE.md` → "Executing actions with care") explicitly argue against blanket pre-authorization:** *"A user approving an action... once does NOT mean they approve it in all contexts... unless actions are authorized in advance in durable instructions."* A framework-shipped `allow` entry **is** exactly that kind of durable, pre-emptive authorization — for users who never individually granted it.

---

## Gathered Information

### Codebase

- **`.claude/settings.json`** (repo root, committed this session) — `permissions.ask` only, ~30 patterns: file-inspection tools (`Glob`, `Grep`, `LS`, `Read`, `Edit`), git (`status*`, `diff*`, `log*`, `branch*`, `add *`, `commit -m *`, `checkout -b *`, `switch *`), package managers (`npm/pnpm/yarn/bun run *`, `*test*`, `npx *`), linters (`prettier`, `eslint`, `tsc`, `biome`), and safe unix reads (`cat`, `find`, `grep`, `pwd`, `which`, `mkdir -p`, `touch`). No `permissions.allow` key present at all.
- **`templates/claude-settings.json`** — the actual framework-wide default. Currently minimal: `enabledMcpjsonServers: []`, `permissions.deny: []`, `permissions.allow: ["Bash(git status)", "Bash(git diff *)", "Bash(git log *)"]` — read-only inspection only. No `ask` key. Everything else (including `git commit`, `npm run`, `npx`) is left to Claude Code's own unconfigured default (prompts per the CLI's session permission mode).
- **`scripts/lib/setup-agent-collections/claude-settings-merge.mjs`** (read this session, lines 1-13 docblock + logic): merge semantics are explicit and load-bearing for this decision —
  - **First run** (consumer has no `.claude/settings.json`): file is seeded **entirely** from `templates/claude-settings.json`, including whatever `permissions.allow` it has at that time.
  - **Every subsequent run** (upgrade/re-setup): only `permissions.deny` (rebuilt from `.claudeignore`) and `enabledMcpjsonServers` are regenerated. `permissions.allow`, `permissions.ask`, and any hand-added keys are **left untouched**.
  - Consequence: widening the template's `allow` list is a **first-impression-only** decision — it does not retroactively force-push into existing consumer installs on upgrade, only shapes what brand-new adopters get by default.
- **`scripts/lib/setup-agent-collections/claude-settings-merge.sh`** — confirms the merge only runs `if SELECTED_AGENTS includes claude`, and only for the `claude` adapter; other adapters (Cursor, etc.) are unaffected by this template either way.
- No `permissions.ask` key exists anywhere in `templates/claude-settings.json` today — the repo-root file's `ask`-only approach and the template's `allow`-only approach are two different philosophies currently coexisting, not yet reconciled.

### Key files and directories

- `templates/claude-settings.json` — the actual decision surface if the answer is "yes, framework-wide."
- `.claude/settings.json` (repo root) — already decided this session (ask-only, legacy names fixed, committed in `5db5b06`); not in scope to change again here.
- `scripts/lib/setup-agent-collections/claude-settings-merge.mjs` / `.sh` — merge logic; confirms one-time-seed-only semantics.
- `scripts/lib/setup-agent-collections/claude-settings-merge.test.sh` — existing test coverage asserts seed-once behavior and `permissions.deny`/`enabledMcpjsonServers` refresh; would need new assertions if `allow` content changes.
- `.ai/rules/orchestration/agent-core.md` → "Executing actions with care" (embedded in `CLAUDE.md`) — the framework's own stated philosophy on pre-authorization scope, directly relevant to whether a template-level blanket allow is consistent with the framework's own rules.

---

## Current Implementation Status

### Existing Components

- `templates/claude-settings.json` — present, intentionally narrow (read-only `allow` only); would need modification if the answer is "widen it."
- `claude-settings-merge.mjs` — present, no changes needed regardless of the answer (merge semantics already support widening the seed safely).
- No existing test or doc currently argues *for* or *against* a broader default — this is a fresh policy question, not a regression.

---

## Gap Analysis

### Question 1

#### Should any `permissions.ask` commands from the repo's own settings move to `permissions.allow` in `templates/claude-settings.json` (framework-wide default for all consumers)?

| Option | Effect | Trade-off |
|---|---|---|
| **A — Keep template as-is (read-only allow only)** | No template change. Consumers keep prompting for every mutating command until they individually opt in, same as this repo's own root settings do today. | Safest default; consistent with `CLAUDE.md`'s own "confirm before consequential actions" philosophy applied to unknown downstream users. Cost: every new adopter re-derives the same friction this session just walked through, with no framework guidance on how to reduce it. |
| **B — Widen template's `allow` to include clearly side-effect-free reads only** (`Bash(cat *)`, `Bash(find *)`, `Bash(grep *)`, `Bash(pwd)`, `Bash(which *)`) | Mirrors the already-allowed `git status/diff/log` philosophy: zero mutation, zero blast radius, matches what most shells let any script run unprompted anyway. | Low risk, modest friction reduction. Does not touch the more contentious ones (`git commit -m *`, `npm run *`, `npx *`). |
| **C — Widen template's `allow` to include mutating dev-loop commands** (`git add *`, `git commit -m *`, `npm/pnpm/yarn/bun run *`, `npx *`, linters) | Matches what the user is using for this repo's own root settings (still `ask`, not `allow`, there — see below) if promoted further. | **Not recommended.** These have real blast radius (`npx *` executes arbitrary published packages; `git commit -m *` writes history without a human seeing it first) and the framework has no visibility into the risk tolerance, compliance posture, or team maturity of any given downstream consumer. Baking this into the shared template pre-authorizes it for everyone, silently, on first install — directly at odds with `CLAUDE.md`'s own scoping rule that approval "stands for the scope specified, not beyond," applied here to a scope (all future consumers) nobody individually granted. |
| **D — Document the pattern instead of changing the template** | Template stays as Option A. Add a short note (README or setup docs) showing consumers *how* to move specific commands to `allow` in their own project's `.claude/settings.json` after install, with the risk trade-off spelled out (mirrors the explanation already given to the user this session). | No blast-radius change; puts the decision in the hands of the team that actually knows their own risk tolerance, which is where `CLAUDE.md`'s "human gates" philosophy already says it belongs. Slightly higher friction than B/C for teams that would have wanted it, but they self-select into more permissions rather than inheriting them. |

**Recommendation: B + D combined.** Widen the template's `allow` list to the handful of genuinely side-effect-free unix reads already proven safe by the existing `git status/diff/log` precedent, and add brief documentation on how a team opts into more (`git commit -m *`, `npm run *`, etc.) themselves. Do **not** add mutating or arbitrary-code-execution commands (`git commit`, `git add`, `npm run`, `npx`, linters that can have plugin/config-driven side effects) to the framework-wide default — that decision has too much variance across consumer projects to be made once, centrally, for everyone.

**Not locked — awaiting human decision** before any plan is written.

### Question 2

#### If Option B or C is chosen, does it require updating `claude-settings-merge.test.sh`?

Yes, mechanically — the test currently asserts specific `allow`/`ask` content (`grep -qF '"allow"'` at test.sh:57, further checks around lines 57-78 per earlier read). Any change to `templates/claude-settings.json`'s `allow` array needs the corresponding assertions updated in the same change, or the test will pass vacuously or fail on the new content. This is plan-scope mechanics, not a further research gap — flagging only so the plan doesn't miss it.

### Question 3

#### Does this decision affect the repo's own root `.claude/settings.json` (already committed this session)?

No. That file is dev-only config for people working on this framework repo, entirely decoupled from `templates/claude-settings.json` (confirmed in the prior turn's analysis and re-confirmed by reading the merge script — the merge pipeline never reads the repo-root file). This question is scoped to the **template** only; the repo-root file needs no further change regardless of the answer here, unless the user separately wants to also promote entries there from `ask` to `allow` for their own local convenience (a different, already-answered question from earlier in this session).

---

## Suggested next steps

1. Human decides Question 1 (A/B/C/D above — recommendation is B+D).
2. If B or D (or both) are approved: write `claude-settings-default-allowlist.plan.md` covering the `templates/claude-settings.json` edit (if B), the doc addition (if D), and the `claude-settings-merge.test.sh` assertion update (if B).
3. If C is wanted despite the recommendation against it: flag explicitly in the plan-approval conversation as a deliberate risk-acceptance decision, not a default.

---

## Changelog

| Date | Change |
|---|---|
| 2026-08-14 | Initial research: distinguished repo-root `.claude/settings.json` (dev-only, already decided) from `templates/claude-settings.json` (framework-wide seed for all consumers); confirmed merge semantics are seed-once for `allow`/`ask` (safe to widen without force-pushing to existing installs); recommended B+D (widen only side-effect-free reads, document opt-in path for mutating commands) over blanket-allowing `git commit -m *` / `npm run *` / `npx *` framework-wide. |
