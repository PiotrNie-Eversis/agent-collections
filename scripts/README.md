# scripts/

Consumer install / upgrade entry for **Agent Collections**.

| Path | Role |
|------|------|
| `setup-agent-collections.sh` | Main installer CLI (local / submodule / copy) |
| `setup-agent-collections.test.sh` | Non-interactive smoke test |
| `lib/setup-agent-collections/` | Shared bash/node helpers |

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

EOG / team default vendor mode: **`--vendor submodule`**. After clone, teammates run `git submodule update --init --recursive`. `--upgrade --sync` aligns a **clean** vendor submodule to the launching installer SHA (or fails with recovery git commands if the pin is dirty).

See root [README.md](../README.md) for modes, upgrade (`--upgrade`), selection schema (`.agent-collections/`), and **deselection / recovery** (MCP prune, Claude surface cleanup, slash-command orphans).
