# setup-framework-prefix-unknown-arg - Analysis Result

**Origin:** Local installer failure when running `setup-agent-collections.sh --upgrade --sync` from `$AGENT_COLLECTIONS_HOME` against EOG’s pinned `vendor/agent-collections` submodule.  
**Related Jira:** none (developer-tooling / installer).  
**Workflow:** Research **approved** (gap answers locked 2026-08-13). Plan: **B + A**, verification **`--upgrade --sync`**.

---

## Task Details

| Field | Value |
|---|---|
| Jira ID | none |
| Title | `adapters/sync.mjs failed` — `unknown argument: --framework-prefix` |
| Description | Running `bash "$AGENT_COLLECTIONS_HOME/scripts/setup-agent-collections.sh" --upgrade --sync --non-interactive` (and the same script with `--vendor submodule`) fails at adapter sync with `error: unknown argument: --framework-prefix`. |
| Priority | High for local Agent Collections install/upgrade on EOG; does not block product (portal/CMS) delivery |
| Reporter | Developer (EOG workspace, branch `agent-collections`) |
| Created Date | 2026-08-13 |
| Due Date | n/a |
| Labels | agent-collections, installer, submodule, version-skew |
| Estimated Effort | Immediate workaround: small (bump submodule pin). Product fix in installer: small–medium (detect skew / bump pin / call matching `sync.mjs`). |

---

## Business Impact

- **`--upgrade --sync` cannot complete** on this machine while the documented command is used from a newer local clone (`AGENT_COLLECTIONS_HOME`) against an older submodule pin.
- Claude/Cursor adapter regeneration, MCP merge, and remaining installer steps **never run** after the fail (setup exits at `link-framework` / `_run_adapter_sync`).
- The failure message does **not** mention version skew, so it looks like a broken CLI rather than a pin that was not updated.
- Docs currently tell consumers to run exactly this command after a framework update (`website/docs/getting-started/installation.md` §5), which reproduces the bug whenever HOME is ahead of the submodule and `--framework-prefix` exists only on HOME.

---

## Gathered Information

### Knowledge Base & Task Management Tools

| Source | Finding |
|---|---|
| Terminal `1.txt` (this session) | Three consecutive runs fail at the same line: `error: unknown argument: --framework-prefix` then `[agent-setup ERROR] adapters/sync.mjs failed.` |
| `.agent-collections/install-selection.json` | `vendorMode: "submodule"`, `frameworkVersion: "0.0.1"`, recorded `2026-08-10`. `--upgrade` reloads this and sets `ARG_VENDOR=submodule`. |
| agent-collections spec `claude-code-setup` | `--framework-prefix` was added for Claude Code vendored installs (Tasks B.1–B.3, 2026-08-12). Flag is new relative to the EOG submodule pin. |
| Installer docs (`installation.md` §5) | Upgrade command is the one the user ran. Alignment table says **vendor submodule: update submodule to tag → then `--upgrade --sync`**. The script does **not** perform that submodule update. |

No Jira ticket for this failure.

### Codebase

**Reproduced:** `node vendor/agent-collections/adapters/sync.mjs --out /tmp --agents cursor,claude --framework-prefix vendor/agent-collections` prints the same `error: unknown argument: --framework-prefix` (exit 1). The HOME clone’s `sync.mjs --help` documents the flag.

**Root cause (two trees, one process):**

1. The user launches the **newer installer bash** from `$AGENT_COLLECTIONS_HOME` (`/Users/piotrniemirski/Documents/Projects/agent-collections`, HEAD `95b3969`).
2. `LIB_DIR` is bound to that clone (`SCRIPT_DIR/lib/setup-agent-collections`). `link-framework.sh` there **does** pass `--framework-prefix` into `adapters/sync.mjs` when `COLLECTIONS_HOME != TARGET_DIR`.
3. `run_vendor_setup` → `setup_vendor_submodule` sees `.gitmodules` already has `vendor/agent-collections`, logs “already present — skipping add”, then **re-points** `COLLECTIONS_HOME` to `eog/vendor/agent-collections`.
4. `_run_adapter_sync` then executes **`${COLLECTIONS_HOME}/adapters/sync.mjs`** — the **older** file at submodule pin `c996bb7` (2026-08-10 era: BA Docs `validate_docx`). That CLI only accepts `--out`, `--agents`, `--check`, `--help`. Unknown args hit `fail(\`unknown argument: ${arg}\`)`.
5. `--upgrade --sync` does **not** `git submodule update` / retarget the pin. Docs say the human must bump the submodule first; the installer does not enforce or do it.

```text
AGENT_COLLECTIONS_HOME (95b3969, has --framework-prefix)
  └─ scripts/setup-agent-collections.sh          ← launched
       source lib/.../link-framework.sh          ← NEW bash, adds --framework-prefix
       run_vendor_setup()
         COLLECTIONS_HOME := eog/vendor/agent-collections   ← OLD pin c996bb7
       _run_adapter_sync()
         node ${COLLECTIONS_HOME}/adapters/sync.mjs --framework-prefix …  ← OLD node CLI → fail
```

**Version facts (2026-08-13):**

| Tree | SHA | `--framework-prefix` in `adapters/sync.mjs` |
|---|---|---|
| `$AGENT_COLLECTIONS_HOME` | `95b3969` (`main`) | yes (since `8cacec3`, 2026-08-12) |
| `eog/vendor/agent-collections` | `c996bb7` (gitlink + checked-out HEAD) | **no** |

HOME is **6 commits** ahead of the pin. The flag commit `8cacec3` is **not** an ancestor of `c996bb7`.

Commits on HOME not in the pin:

- `449174c` DHI-515 docs links
- `0119b64` changelog sync scripts
- `f559041` Vercel config / docs
- `8cacec3` Claude Code + `--framework-prefix` (**this failure**)
- `df3fb82` Claude Code docs
- `95b3969` summary/test/logging for Claude

**Why `--upgrade --sync` still takes the vendor path:** `upgrade.sh` maps `install-selection.json` `vendorMode: "submodule"` back to `ARG_VENDOR`, so `run_vendor_setup` always re-points `COLLECTIONS_HOME` even when the user only asked to refresh adapters.

**Not the cause:**

- Missing Node / missing `sync.mjs` (file exists; parse fails first).
- MCP build (`MCP dist already present — skipping build` before the fail).
- Submodule add (`already present — skipping add` is expected).
- Dirty files under `vendor/agent-collections` in eog’s working tree: even the on-disk `sync.mjs` has no `--framework-prefix` (confirmed by grep + reproduce).

### Relevant Links

- Installer entry: `$AGENT_COLLECTIONS_HOME/scripts/setup-agent-collections.sh`
- Vendor re-point: `scripts/lib/setup-agent-collections/vendor.sh` (`setup_vendor_submodule`, `COLLECTIONS_HOME="$vendor_dir"`)
- Flag injection: `scripts/lib/setup-agent-collections/link-framework.sh` (`_run_adapter_sync`, `_resolve_framework_prefix`)
- Old CLI reject: `vendor/agent-collections/adapters/sync.mjs` `parseArgs()` → `fail(\`unknown argument: ${arg}\`)`
- New CLI accept: `$AGENT_COLLECTIONS_HOME/adapters/sync.mjs` (`--framework-prefix`)
- Feature origin: [`../claude-code-setup/claude-code-setup.plan.md`](../claude-code-setup/claude-code-setup.plan.md) Tasks B.1–B.3
- Documented upgrade: [`../../../website/docs/getting-started/installation.md`](../../../website/docs/getting-started/installation.md) §5 (“Update submodule to tag → `--upgrade --sync`”)

### Relevant Charts & Diagrams

See the ASCII flow under **Codebase**. No Figma.

---

## Current Implementation Status

### Existing Components

- `setup-agent-collections.sh` — can be reused; sources libs from **the launched script’s tree**, not from the vendored pin after re-point.
- `vendor.sh` `setup_vendor_submodule` — **needs modification** if the product fix is “installer must bump or refuse skew”: today it only skips `git submodule add` when `.gitmodules` already lists the path.
- `link-framework.sh` `_run_adapter_sync` — **needs modification** if the product fix is “call HOME’s `sync.mjs`” or “omit `--framework-prefix` when the target CLI lacks it”.
- `adapters/sync.mjs` (pin `c996bb7`) — **needs replacement via submodule bump** to a SHA that includes `8cacec3` (or later), not a local patch in eog.
- `install-selection.json` — can be reused; `frameworkVersion` is still `"0.0.1"` on both trees, so it **cannot** detect this skew.

### Key Files and Directories

- `eog/.gitmodules` — `vendor/agent-collections` → `https://github.com/PiotrNie-Eversis/agent-collections.git`
- `eog/.git` gitlink `160000` → `c996bb7`
- `eog/vendor/agent-collections/adapters/sync.mjs` — old CLI (fail site)
- `eog/vendor/agent-collections/scripts/lib/setup-agent-collections/link-framework.sh` — old `_run_adapter_sync` (no `--framework-prefix`); **not** the file that ran
- `$AGENT_COLLECTIONS_HOME/scripts/lib/setup-agent-collections/link-framework.sh` — new `_run_adapter_sync` (the file that ran)
- `eog/.agent-collections/install-selection.json` — `vendorMode: submodule`

---

## Gap Analysis

All missing information and gaps in task description, together with provided answers.

### Question 1

#### Is this an EOG product bug or an Agent Collections installer bug?

**Installer / pin mismatch**, not portal/CMS. EOG is a consumer with a **stale submodule pin**. The installer **mixes** new bash from `$AGENT_COLLECTIONS_HOME` with old Node from `vendor/agent-collections` and has **no skew check**. Immediate unblock is on the consumer (update gitlink). A durable fix belongs in **agent-collections** so `--upgrade --sync` from a newer HOME cannot call an older `sync.mjs` with new flags.

### Question 2

#### What should a human do now vs after a plan?

**Locked (2026-08-13):** **B + A**, then verify with **`--upgrade --sync`**. Option **C** out of scope.

| Option | Decision |
|---|---|
| **B** (agent-collections) | Product guard in the **launched** installer. After vendor re-point, before adapter sync: if the installer will pass CLI flags that vendored `adapters/sync.mjs` does not accept, then on `--upgrade` / `--sync` + `vendorMode=submodule` + **clean** vendor worktree → checkout the launching framework SHA into `vendor/agent-collections` and continue; otherwise **die** with an explicit “submodule behind installer” message (paths, SHAs, flag name, exact git commands). Never wipe a dirty vendor tree. |
| **A** (eog) | Bump the `vendor/agent-collections` gitlink to a SHA that includes `--framework-prefix` (and B once B exists on that SHA). Consumer pin change only — no portal/CMS edits. |
| Verification | From eog: `bash "$AGENT_COLLECTIONS_HOME/scripts/setup-agent-collections.sh" --upgrade --sync --non-interactive` completes (no `unknown argument: --framework-prefix`). |
| **C** | Not chosen. Keep executing `${COLLECTIONS_HOME}/adapters/sync.mjs` so generated adapters follow the **pinned** vendor copy after align/bump. |

**Not a substitute for the plan:** a one-off local checkout of `95b3969` without B still unblocks today’s fail, but the next HOME-ahead-of-pin flag will fail the same way.

### Question 3

#### Does `frameworkVersion: "0.0.1"` help?

No. Both trees report `0.0.1`. SemVer in selection JSON cannot detect this skew until the framework actually bumps version on the Claude/`--framework-prefix` work.

---

## Independent verification (2026-08-13, `/eversis-implement`)

Re-checked on this machine against live trees. **Bug still present. Root cause unchanged.**

| Check | Result |
|---|---|
| HOME HEAD | `95b3969` (`main`, also on `origin/main`) |
| EOG gitlink + checked-out vendor HEAD | `c996bb7` (`160000` in `eog`) |
| `8cacec3` ancestor of HOME | yes |
| `8cacec3` ancestor of pin | **no** |
| HOME `adapters/sync.mjs --help` | documents `--framework-prefix` |
| Pin `adapters/sync.mjs --help` | does **not** mention the flag |
| Reproduce | `node eog/vendor/agent-collections/adapters/sync.mjs --out /tmp --agents cursor,claude --framework-prefix vendor/agent-collections` → `error: unknown argument: --framework-prefix` (exit 1) |
| HOME `link-framework.sh` | still appends `--framework-prefix` when prefix is non-empty (`args+=` at line 189) |
| Pin `link-framework.sh` | **no** `--framework-prefix` (not the file that runs when HOME installer is launched) |
| `setup_vendor_submodule` | skip-add when `.gitmodules` lists the path, then `COLLECTIONS_HOME="$vendor_dir"` |
| `upgrade.sh` | `vendorMode: "submodule"` → `ARG_VENDOR` restored; `--upgrade --sync` still takes the vendor path |
| `frameworkVersion` | `"0.0.1"` on HOME `package.json` and EOG `install-selection.json` |
| EOG selection | `agents: cursor,claude`; `vendorMode: submodule`; `recordedAt: 2026-08-10` |
| Pin object db has `95b3969`? | **no** — B must `git fetch` origin before checkout |
| Vendor porcelain | **empty** (clean). Earlier “may already be dirty” snapshot is **stale** as of this verification. Phase 4 auto-checkout is unblocked on dirtiness. |

Call chain still matches the ASCII flow in **Codebase**. `LIB_DIR` is bound to the launched script (`SCRIPT_DIR/lib/...`). `maybe_build_mcp` still runs **before** `link_framework_files` / `_run_adapter_sync`.

Consumer path used: `/Users/piotrniemirski/Documents/Projects/eog`. Full `--upgrade --sync` was **not** re-run (it would `mkdir` `.cursor/rules` before the fail); isolated `sync.mjs` reproduce is sufficient.

---

## Suggested next steps

1. ~~Human approves this research.~~ Done (Q1–Q3 locked). Independent verification 2026-08-13 confirms the same AC and root cause.
2. ~~Decide A vs B vs C.~~ Locked: **B + A**; verify with `--upgrade --sync`; **C** out of scope.
3. Human reviews `setup-framework-prefix-unknown-arg.plan-review.md`, then approves `setup-framework-prefix-unknown-arg.plan.md` before implementation.
4. Do **not** treat a local submodule bump as “the installer is fixed” unless B is in the launched installer tree.
5. On implement: fetch origin inside the vendor clone before checkout — pin object db currently lacks `95b3969`.

---

## Changelog

| Date | Change |
|---|---|
| 2026-08-13 | Initial research: reproduced fail; identified HOME installer vs pinned `sync.mjs` skew. |
| 2026-08-13 | Gap answers locked: Q1 OK; Q2 = B + A + `--upgrade --sync` (C out); Q3 OK. |
| 2026-08-13 | Moved from eog `docs/specs/` into this framework repo (installer SSOT). |
| 2026-08-13 | DELTA: independent verification — fail still reproduces on pin `c996bb7`; vendor worktree now **clean**; vendor object db lacks HOME `95b3969` (fetch required). |
