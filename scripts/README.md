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

EOG / team default vendor mode: **`--vendor submodule`**.

See root [README.md](../README.md) for modes, upgrade (`--upgrade`), and selection schema.
