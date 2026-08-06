# OpenCode adapter (placeholder)

Stub OpenCode packaging for Agent Collections. Points OpenCode at core rules under `.ai/rules` via `instructions` globs. **Not** a shipped / production adapter.

Mapping contract: [`docs/architecture/adapter-mapping.md`](../../docs/architecture/adapter-mapping.md) §6.  
Public docs: [Rules](https://opencode.ai/docs/rules) · [Config](https://opencode.ai/docs/config).

## Status

```text
adapter: opencode
maturity: placeholder
emits: opencode.jsonc (instructions → .ai/rules globs); optional AGENTS.md pointer
does_not_emit: full skill/prompt mirrors, ignore triad, production-grade agent profiles
```

## Files

| Path | Role |
|------|------|
| `adapters/opencode/opencode.jsonc` | **Canonical** stub config (JSONC + PLACEHOLDER comment) |
| `opencode.jsonc` (repo root) | Identical demo copy for this framework repo |

When you change the stub, update **both** files so they stay identical (`cmp -s opencode.jsonc adapters/opencode/opencode.jsonc`). There is no generator — hand sync only.

## Core unchanged (invariant)

OpenCode format evolution is handled **only** in this adapter layer (`adapters/opencode/` + root `opencode.jsonc`). Do **not** rewrite `.ai/rules` content to match OpenCode. Core remains the vendor-neutral SSOT.

## Dual surface

OpenCode loads:

1. **`instructions`** from `opencode.jsonc` (globs under `.ai/rules/<domain>/*.md` — may include domain `README.md` files; refine when a shipped adapter exists)
2. Root **`AGENTS.md`** when present (combined with instructions per OpenCode docs)

This story does **not** edit root `AGENTS.md` (standardization → DHI-531 / DHI-532).

## Isolation / ignore checklist (Story 3.2)

Minimal Cursor exclusion is already in root `.cursorignore` (`adapters/opencode/`, `opencode.jsonc`). Full synchronized triad is **DHI-529**:

| Path / pattern | Cursor | Claude | OpenCode |
|----------------|--------|--------|----------|
| `adapters/opencode/` | exclude (done in DHI-525) | exclude | (n/a — own adapter) |
| `opencode.jsonc` | exclude (done in DHI-525) | exclude | load as config |
| Future `.opencodeignore` | — | — | DHI-529 |

## Out of scope here

- Generator / sync CLI (DHI-527)
- Claude `CLAUDE.md` (DHI-526)
- Full `.claudeignore` / `.opencodeignore` triad (DHI-528–529)
- Agent profiles / permissions keys beyond `$schema` + `instructions`
