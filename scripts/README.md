# scripts/

Consumer install / upgrade entry for **Agent Collections**.

| Path | Role |
|------|------|
| `setup-agent-collections.sh` | Main installer CLI (local / submodule / copy) |
| `setup-agent-collections.test.sh` | Non-interactive smoke test |
| `lib/setup-agent-collections/` | Shared bash/node helpers |
| `release-to-master.sh` | Publish `develop` to `master` as a filtered snapshot (maintainers) |
| `release-to-master.test.sh` | Tests for the release script and `.githooks/pre-commit` |
| `lib/release-paths.sh` | Reads `.release-exclude` (work-only paths) for the release script and hook |
| `check-release-tree.sh` | Fails when a commit carries `.release-exclude` paths (CI guard for `master`) |
| `pi-load-check.mjs` | Pi load check: installs the framework for Pi into a temp project and fails when Pi does not load a generated prompt, skill or extension, or reports a `.pi/mcp.json` config error (`npm run pi:load-check`; details in [`adapters/pi/README.md`](../adapters/pi/README.md) "Load check") |
| `pi-load-check.test.mjs` | Tests for the Pi load check (`node --test scripts/pi-load-check.test.mjs`; integration tests need `pi` on PATH) |

## Branches and releases (framework repository)

- **`develop`** is the working branch. It also tracks work-only material: `docs/specs/`, `docs/context/<project>/`, `docs/reports/`, `docs/plans/`, `docs/decisions/` entries (full list: [`.release-exclude`](../.release-exclude)).
- **`master`** is production and carries only the framework core (consumers vendor it). It is **never merged** from `develop`.
- **Release:** from any branch except `master`, run

  ```bash
  bash scripts/release-to-master.sh --dry-run   # preview
  bash scripts/release-to-master.sh             # one "release: develop@<sha>" commit on local master
  git push origin master
  ```

  The script copies the `develop` tree, removes the `.release-exclude` paths, and commits it on top of `master` (single parent), so deletions and renames carry over and work-only docs never do. It stops when `master` has commits that are neither releases nor in `develop` (a hotfix made only on `master`); bring them into `develop`, or pass `--allow-diverged` to overwrite them.
- **Guard:** enable the hook once per clone with `git config core.hooksPath .githooks`. On `master`/`main` it rejects commits that stage `.release-exclude` paths (READMEs stay allowed).
- **CI guard:** `.gitlab-ci.yml` runs `scripts/check-release-tree.sh` on every `master` pipeline and fails it when work-only paths are present (e.g. a push made without the hook). It detects and alerts; it cannot reject the push. To clean up, make sure the change is on `develop`, then release with `--allow-diverged`.
- **Branch protection (GitLab):** protect only `master` — *Allowed to merge: No one*, *Allowed to push and merge: Maintainers*, *Allowed to force push: off*.

## Pi load check in CI

`.gitlab-ci.yml` has a `verify` stage with two jobs. Each installs Node 22 and Pi (`npm install -g --ignore-scripts`), runs `node --test scripts/pi-load-check.test.mjs`, then `node scripts/pi-load-check.mjs`, then the Pi adapter unit tests (`node --test 'adapters/pi/*.test.mjs'`, which need Node 22.18 or later) and `node --test adapters/pi/process-rules.integration.mjs`. That last test starts Pi with a local stub model, no keys and a temp `HOME`, and fails when the process rules section does not reach the request (AC-134). The job log starts the report with `Pi <version> (pinned)` or `Pi <version> (latest)`.

- **`pi-load-check:pinned`** runs Pi `PI_VERSION_PINNED` (now `1.5.0`) on merge requests and on `develop` pushes that change a watched path: `adapters/pi/**`, `.ai/prompts/**`, `.ai/skills/**`, `.ai/rules/**`, `adapters/sync.mjs`, `scripts/setup-agent-collections.sh`, `scripts/lib/setup-agent-collections/**`, `templates/mcp.json`, `scripts/pi-load-check*.mjs`, `package.json`, `.gitlab-ci.yml`.
- **`pi-load-check:latest`** runs the latest Pi release in scheduled pipelines and when someone with Developer access or higher starts a pipeline from the web UI (**Build → Pipelines → Run pipeline**). The job has no secrets or write tokens.

**Weekly schedule (one-time setup, Maintainer):** in GitLab, open **CI/CD → Schedules** (newer versions: **Build → Pipeline schedules**) and create a weekly schedule with target branch **`develop`**. Never target `master`: its pipeline runs the release guard. GitLab e-mails the schedule owner when the run fails.

**Bumping the pin:** after a passing `latest` run on a newer Pi, bump `PI_VERSION_PINNED` in `.gitlab-ci.yml` and the tested range in `adapters/pi/README.md` (Requirements) and `website/docs/getting-started/installation.mdx` (Pi section) in a separate MR. When the `latest` run fails, keep the pin and fix the framework (or report the Pi issue) first.

## Quick start

From a **consumer** git repo (not this framework tree):

```bash
export AGENT_COLLECTIONS_HOME=/path/to/agent-collections
bash "$AGENT_COLLECTIONS_HOME/scripts/setup-agent-collections.sh" \
  --build-mcp --non-interactive \
  --agents=cursor \
  --mcp-servers=eversis-collections \
  --profile=fullstack
```

Or without relying on env expansion:

```bash
bash /path/to/agent-collections/scripts/setup-agent-collections.sh \
  --collections-home /path/to/agent-collections \
  --non-interactive --agents=cursor --mcp-servers=eversis-collections \
  --profile=fullstack
```

TASK / team default vendor mode: **`--vendor submodule`**. After clone, teammates run `git submodule update --init --recursive`. `--upgrade --sync` aligns a **clean** vendor submodule to the launching installer SHA (or fails with recovery git commands if the pin is dirty).

See root [README.md](../README.md) for modes, upgrade (`--upgrade`), selection schema (`.agent-collections/`), and **deselection / recovery** (MCP prune, Claude surface cleanup, slash-command orphans).
