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
