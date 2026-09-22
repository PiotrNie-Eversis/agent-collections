# Example — new component entry

`docs/context/proj/checkout-flow/index.md`

```yaml
---
scope: project
source: agent-discovered
status: approved
last_updated: "2026-08-25"
tags: [checkout, payments]
code_paths: ["src/checkout/**", "src/payments/providers/**"]
confluence_url: null
related_specs: ["docs/specs/new-payment-provider/"]
---
```

```markdown
# Checkout flow

Checkout validates the cart, then hands off to whichever payment provider is
active for the account's region (`src/payments/providers/`). Each provider
implements the same `PaymentProvider` interface — `authorize`, `capture`,
`refund` — so adding a new one never touches `src/checkout/` itself.

New providers register themselves in `src/payments/providers/index.ts`; no
other file needs to change.
```

`docs/context/proj/INDEX.md` gains one row:

```markdown
| checkout-flow | Cart validation + pluggable payment provider handoff |
```

---

# Example — second occurrence, appending to an existing entry

Same file, three months later, after `docs/specs/refactor-validation/` reused
the same pattern:

```yaml
---
scope: project
source: agent-discovered
status: approved
last_updated: "2026-11-10"
tags: [checkout, payments, validation]
code_paths: ["src/checkout/**", "src/payments/providers/**"]
confluence_url: null
related_specs:
  - "docs/specs/new-payment-provider/"
  - "docs/specs/refactor-validation/"
---
```

The descriptive body is **overwritten** to reflect the current state (including whatever `refactor-validation` changed) — `related_specs` is the only part that accumulates.
