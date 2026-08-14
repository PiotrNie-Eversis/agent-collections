# Requirements traceability (WF / WNF)

Maps wildly important functional (WF) and non-functional (WNF) goals for Agent Collections to documentation and Wave D stories. Inspectable from the root README and [getting-started start-here](../../website/docs/getting-started/start-here.md).

| ID | Intent (summary) | Primary docs | Story / wave |
|----|------------------|--------------|--------------|
| **WF-01** | Vendor-neutral core (`.ai/`) with tool adapters | [Framework reference](../../documentation/agent-collection.md), [adapter mapping](./adapter-mapping.md), [AGENTS.md](../../AGENTS.md) | Waves A–C; docs TASK-541 |
| **WF-02** | Consumer install (local / submodule / copy) + selection | [Installation](../../website/docs/getting-started/installation.md), [install-selection](./install-selection.md), README | Wave C; TASK-541 |
| **WF-03** | Skills discoverability via MCP + `AGENT_COLLECTIONS_HOME` | [MCP setup](../../website/docs/getting-started/mcp-setup.md), MCP package README | Wave C; TASK-541 |
| **WF-04** | Multi-agent packaging (Cursor + Claude MVP; OpenCode placeholder) | [Prerequisites](../../website/docs/getting-started/prerequisites.md), [adapter mapping](./adapter-mapping.md), [migration guide](../../website/docs/getting-started/migration-from-cursor-collections.md) | Waves B–D; TASK-539 |
| **WF-05** | Spec-driven delivery (research → plan → implement → review → Fine) | README Delivery standard, [AGENTS.md](../../AGENTS.md), orchestration rules under `.ai/rules/orchestration/` | Framework-wide; TASK-541 |
| **WNF-02** | Cross-tool packaging isolation (ignore triad) | [Isolation strategy](./isolation-strategy.md) §4 | TASK-528/529; pilot TASK-542 |
| **WNF-03** | Context reduction ≥30% vs unscoped (proxy §7.2) or justified estimate | [Isolation strategy](./isolation-strategy.md) §7, migration / EOG context | TASK-542 |

## Notes

- Docs site public URL / hosting: **deferred** (Wave D Q3) — local `website` build only.
- Consumer-specific area names map via overlay; framework keeps abstract `apps/web` / `apps/api`.
