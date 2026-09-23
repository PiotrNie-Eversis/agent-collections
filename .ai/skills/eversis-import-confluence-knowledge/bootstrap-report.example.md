# Example — bootstrap report (Confluence-first path, with `docs/specs/` fallback)

A hypothetical project `proj` with a populated As-Is Pack covering most modules, plus a `docs/specs/` history that fills the one gap the page itself flags. This is the draft handed to the human for approval — nothing below is written until approved.

## Candidate `INDEX.md` rows (two columns only)

```markdown
| auth | WSO2 OAuth2/OIDC login and SSO for services requiring user identity |
| faq-collections | FAQ and keywords library, synced with FEDEO |
| dashboard | Metrics dashboard reading cached values from a headless CMS API |
```

## Candidate component files

### `docs/context/proj/auth/index.md` — sourced from the As-Is Pack

```yaml
---
scope: project
source: confluence
status: approved
confluence_url: "https://example.atlassian.net/wiki/spaces/PROJ/pages/123456/As-is+Pack#Authentication"
last_updated: "2026-09-21"
tags: [auth, sso]
code_paths: []
related_specs: []
---
```

```markdown
# Auth (WSO2 OAuth2/OIDC)

Login and SSO for services requiring user identity, backed by the WSO2 identity
provider. Recent known issues (per the As-Is Pack "Known Issues" section):
intermittent HTTP 500 on the OAuth callback route, and a sign-out flow that
masks a 500 as a silent failure.
```

`code_paths` is empty because the As-Is Pack section names the integration, not
specific source files — a later task fills it in as the code is actually
touched (Step 4).

### `docs/context/proj/faq-collections/index.md` — sourced from the As-Is Pack

```yaml
---
scope: project
source: confluence
status: approved
confluence_url: "https://example.atlassian.net/wiki/spaces/PROJ/pages/123456/As-is+Pack#FAQ"
last_updated: "2026-09-21"
tags: [faq, content]
code_paths: []
related_specs: []
---
```

```markdown
# FAQ Collections

FAQ content management, synchronized with FEDEO's Data Description Pages.
Frontend renders FAQs both as a standalone section and embedded in article
and catalog pages.
```

### `docs/context/proj/dashboard/index.md` — sourced from `docs/specs/` clustering (Step 6 fallback)

The As-Is Pack's module map marks "Dashboard" as `❌ brak` (no documentation) — the page has no section to split, so this component is clustered from raw task history instead:

```yaml
---
scope: project
source: docs-specs-cluster
status: approved
confluence_url: null
last_updated: "2026-09-21"
tags: [dashboard, metrics]
code_paths: ["src/dashboard/**"]
related_specs:
  - "docs/specs/dashboard-visibility-improvement/"
  - "docs/specs/dashboard-data-integration/"
---
```

```markdown
# Dashboard

Reads cached metric values from a headless CMS API rather than querying the
metrics source directly — a separate, unrelated sync process keeps the cache
current. Metrics split into single-value tiles and bar-chart series depending
on a `displayType` field per metric.

Clustered from two `docs/specs/` tasks that both touched `src/dashboard/**`
and independently described the same read path — meets the cross-task
worthiness bar (`eversis-promote-domain-knowledge` Step 1) on the second
occurrence.
```

## Skipped, not promoted

- As-Is Pack section "Learn & Discover" — still a template placeholder (`{{...}}`), no content to import.
- Module "Analytics/Matomo" — As-Is Pack marks it `❌ brak` and no `docs/specs/` folder in this repo touches an analytics/Matomo path; nothing to cluster. Reported as a genuine coverage gap, not silently dropped.
