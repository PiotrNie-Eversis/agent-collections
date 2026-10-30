# upstream-copilot-comparison — Materials Analysis

Comparison of the current **copilot-collections** upstream (TheSoftwareHouse) with **Agent Collections** (this repo), and recommendations for the framework's future direction.

## Sources

| Source | Version / state |
|---|---|
| `https://github.com/TheSoftwareHouse/copilot-collections` | `master` @ `b7b6b04` (2026-10-13); last process change in CHANGELOG dated 2026-08-05 |
| `agent-collections` | `master` @ `035912f` (2026-10-30) |
| Baseline | `docs/context/agent-collections/task-baseline.md` (refreshed 2026-10-27) |

No transcript was provided; materials are the two codebases plus their CHANGELOGs.

## 1. Inventory at a glance

| Area | copilot-collections | Agent Collections |
|---|---|---|
| Target host | GitHub Copilot in VS Code only | Host-neutral SSOT `.ai/` + adapters: Claude Code, Cursor, OpenCode, Pi |
| Packaging | `.github/agents` (25), `.github/prompts` (13 public), `.github/internal-prompts` (13), `.github/skills` (35), 1 `.instructions.md` | `.ai/rules/` (6 domains), `.ai/prompts/public` (16), `.ai/prompts/internal` (12), `.ai/skills` (51) |
| Roles | First-class **agent files** with tool allowlists, subagent rosters, per-agent `model:` arrays, `user-invocable` | Roles are **rules** (`engineering-manager.md`, `code-reviewer.md`…) loaded into the host's main agent; no per-role tools/model |
| Distribution | Clone/copy + VS Code settings; `.vscode/mcp.json` | Installer `setup-agent-collections.sh` (profiles, vendor modes, `--upgrade --sync`), SemVer CHANGELOG with Migration sections |
| MCP | Third-party servers only | Own `eversis-collections-mcp` (skills, domain context, docx/SharePoint) + catalog template |
| Docs site | Docusaurus: agents, workflow, use-cases, for-CTOs, new homepage (Oct 2026) | Docusaurus: intent-based IA (getting-started, main-flow, advanced, reference) |

## 2. Shared skills — divergence

Of 33 shared skills, 18 differ only by the prefix/branding line (effectively in sync). Material divergence:

| Skill | Nature of divergence |
|---|---|
| `orchestrating-implementation` | Biggest fork. Upstream: Full Flow only, Human Approval record, Approval Gate Separation, Implementation Discussion Boundary, 3-implementor routing. Ours: Quick/Full + adequacy checklist, readiness block, gate-closing rule, Checkpoint/RESUMED, Continuity Review→Fine, QA draft |
| `ui-verifying` | Upstream rewrote (Jul 2026) to **playwright-cli** capture: auth pre-step, render stabilization, artifact directory contract, exit codes, strict PASS gate, `toHaveScreenshot` tripwire. Ours is the older Playwright-MCP version (198 vs 361 lines) |
| `creating-instructions`, `creating-prompts`, `creating-agents` | Intentional: ours target `.ai/` + adapters, upstream targets `.github/*.md` Copilot formats |
| `implementing-backend` | Cosmetic (branding, tree formatting) |
| `creating-implementation-plans` | Both have open-questions and executable-slot dispatch gates. Upstream adds `## Human Approval` revision record; ours adds `## Human gates` list with quoted closing phrase |
| `jira-task-formatting`, `task-extracting` | Minor; ours adds baseline/post-push details |

## 3. Upstream-only capabilities (candidates to adopt)

| # | Capability | Upstream date | Gap in Agent Collections |
|---|---|---|---|
| U1 | **Revision-bound Human Approval record** in the plan (`Plan Revision`, `PENDING/APPROVED/CHANGES_REQUESTED/STOPPED`, `Approved Revision`, UTC timestamp, validity predicate); material change resets approval | 2026-07-22 → 08-05 | We rely on a quoted phrase in `## Human gates`. No revision number, so a plan edited after approval still looks approved; a fresh session cannot check approval mechanically |
| U2 | **Revision-bound plan-review verdict** (`reviewed-plan-revision`), reviewer output fenced away from approval/consent wording, one review per plan lifecycle | 2026-07-31 → 08-04 | Our `.plan-review.md` verdict is not tied to a plan revision |
| U3 | **Fail-closed precondition in every execution owner** (implementor checks approval before any file edit) | 2026-07-22/27 | Our check lives only in the orchestrator; delegated implement prompts don't re-check |
| U4 | **Strict, cheap plan-implementor** (one task, exactly as written, stop-and-report) as default route for low-risk seams; separate UI engineer | 2026-06-22 | We route by internal prompt, not by implementor strictness/cost |
| U5 | **Per-role model routing** with cross-provider fallback arrays and cost rationale | 2026-05 → 07 | No model guidance per role; Claude Code/OpenCode support per-subagent `model`, unused |
| U6 | **CLI-first UI capture** (`playwright-cli` skill + `ui-capture-worker`), deterministic artifacts and exit codes | 2026-07-08 | Ours still uses Playwright MCP and model-side comparison |
| U7 | **BA orchestrator + 5 internal workers** (transcript, analysis, extraction, quality, formatting) keeping gates and Jira writes in the orchestrator | 2026-06-01 | Our `eversis-analyze-materials` is one prompt; long workshops fill one context |
| U8 | **`/explore-materials`** public prompt → `workshop-context-summary.md` | 2026-06-01 | `eversis-task-extracting` already references Explore Mode and the summary file, but no prompt exists — a dangling reference |
| U9 | **Copilot-engineering orchestrator + researcher/creator/reviewer workers** for authoring framework artifacts | 2026-02-27 | Our `eversis-create-custom-*` prompts are single-context |
| U10 | **Implementation Discussion Boundary** (delivery starts in a new discussion, reusing persisted approval) | 2026-08-04 | Partly opposite to our Continuity + Checkpoint model — evaluate, don't copy |
| U11 | **Quick Flow removal** | 2026-08-04 | We keep Quick Flow behind adequacy checklist — evaluate with pilot data |

## 4. Agent Collections–only capabilities (our differentiators)

| # | Capability | Notes |
|---|---|---|
| A1 | Multi-host SSOT + adapters (Claude Code, Cursor, OpenCode, Pi) + `sync:adapters:check` | Core strategic difference; upstream is Copilot-locked |
| A2 | Installer, domain profiles, vendor modes, upgrade/sync contract, SemVer + Migration | Upstream has no upgrade story for consumers |
| A3 | Domain-knowledge lifecycle: `docs/context/<project>/INDEX.md` router, add/promote/audit/import-Confluence skills, MCP context tools, `docs/decisions/` + `eversis-record-decision` | No equivalent upstream |
| A4 | Delivery Standard: readiness block, adequacy checklist, spec-folder lookup, gate-closing rule, Checkpoint/RESUMED, Review Continuity with PASS predicate and 3-pass cap | Upstream converged on stricter approval records but not on readiness/adequacy |
| A5 | Fine handoff: QA comment draft, domain-promotion draft, As-Is Pack Confluence comment draft | No equivalent upstream |
| A6 | QA suite: `eversis-qa-workflow`, test planning, regression risk, AC verification, bug analysis, accessibility audit | Not present in the current upstream tree |
| A7 | BA Docs (Word): `.docx` planner/writer via MCP, SharePoint upload | No equivalent upstream |
| A8 | `eversis-implementing-filters` | Ours only |

## 5. Structural observations

1. **No upstream sync ledger.** Prompt footers say `upstream: eversis-…:v3` (self-referential names, no upstream commit SHA). We cannot say mechanically which upstream changes since the fork are absorbed. Today's check had to be done by diffing trees.
2. **Roles without isolation.** Several of our rules demand isolation ("Code Review must run as a genuinely separate delegated context"), but adapters emit no subagent definitions (`.claude/agents/`, OpenCode `agent` entries). Isolation depends on the model choosing to delegate. Upstream gets this from agent files.
3. **Upstream is moving toward hard state in artifacts** (revision numbers, enums, timestamps, predicates) and away from conversational inference. We moved in the same direction (quoted closing phrase), but less far.
4. **Convergent duplicates.** `writing-documentation` (upstream) ≈ `writing-repo-documentation` (ours), and both have a technical-writer path. This is the same capability with a different name.

## 6. Recommendations (prioritized)

| Priority | Recommendation | Basis | Effort |
|---|---|---|---|
| P1 | **Adopt a revision-bound Human Approval record** in `plan.example.md` (and research), keeping our quoted-phrase evidence as the `Note`. Bind `.plan-review.md` verdict to the revision. Readiness block reads it on resume | U1, U2, A4 | M |
| P1 | **Generate real subagents from role rules** in the Claude Code and OpenCode adapters (tools allowlist, optional `model`), starting with Code Reviewer, UI Reviewer, and Plan Implementor, so isolation is structural | §5.2, U3, U4 | L |
| P1 | **Create an upstream sync ledger** (`docs/context/agent-collections/upstream-sync.md` or similar): last reviewed upstream SHA, per-change decision Adopt / Adapt / Reject + reason. Make it a recurring audit | §5.1 | S |
| P2 | **Port CLI-first UI capture** (`playwright-cli` skill, capture contract, exit codes) as an optional path next to MCP; host-neutral since it is Bash-driven | U6 | M |
| P2 | **Add `eversis-explore-materials`** public prompt to close the dangling Explore Mode reference | U8 | S |
| P2 | **Fail-closed approval precondition** in internal implement prompts (`eversis-implement-common-task`, `-ui`, `-e2e`, `-terraform`, …) | U3 | S |
| P2 | **Model-routing guidance per role** as an optional profile field (adapters emit it where the host supports it); no hard model names in SSOT | U5 | M |
| P3 | **BA worker split** for `eversis-analyze-materials` (transcript / extraction / quality / formatting as subagents), after P1 subagent generation exists | U7 | M |
| P3 | **Evaluate Quick Flow and Discussion Boundary** with pilot evidence before changing anything; record outcome with `eversis-record-decision` | U10, U11 | S |
| P3 | **Contribute back** host-neutral pieces upstream (domain-knowledge lifecycle, Fine QA draft, QA suite) or at least publish a positioning page (Agent Collections vs copilot-collections) on the docs site | A3–A6 | S–M |

### Explicitly not recommended

- Copying per-agent hard-coded model names into `.ai/` — they change monthly upstream (4 re-assignments May–Aug 2026) and are host-specific.
- Re-adopting Copilot-only packaging (`.github/agents`, `vscode/askQuestions`) — a Copilot adapter would be the host-neutral route if demand appears.
