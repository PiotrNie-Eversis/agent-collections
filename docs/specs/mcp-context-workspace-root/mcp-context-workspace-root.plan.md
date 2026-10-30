# mcp-context-workspace-root - Implementation Plan

## Task Details

| Field            | Value                   |
| ---------------- | ----------------------- |
| Jira ID          | [DHI-630](https://eversis.atlassian.net/browse/DHI-630) follow-up (relates [WUP-695](https://eversis.atlassian.net/browse/WUP-695) Q5) |
| Title            | `eversis_context_*` musi rozwiązywać projekt konsumenta, a nie drzewo vendora |
| Description      | Nanieść na `ssot` poprawkę katalogu `/workspace`, parsowanie linków markdown w INDEX oraz emisję hostowego `CONSUMER_PROJECT_ROOT` przez merger instalatora. Nie cherry-pickować Sternika `15f4e28`. |
| Priority         | High |
| Related Research | [mcp-context-workspace-root.research.md](./mcp-context-workspace-root.research.md) |

## Wildly Important Goal

**Goal**: Narzędzia `eversis_context_list` / `get` / `sync` u konsumenta z vendored Compose wskazują katalog projektu (tam, gdzie jest `install-selection.json`), a nie drzewo vendora, i przyjmują goły identyfikator komponentu nawet gdy INDEX ma link markdown.

**Success Measure**: Testy MCP pokrywają mount `/workspace` bez pliku selection oraz wiersz INDEX `[name](./name/index.md)`; merger emituje `env.CONSUMER_PROJECT_ROOT` (Cursor i Claude); dokumentacja nie uczy już, że `${PWD}` wystarczy.

**Do NOT touch / do NOT add**:
- cherry-pick commita `15f4e28` / zmiana gałęzi innej niż `ssot`
- aplikacje produktowe, Sternik poza tym repo (jego `.cursor/mcp.json` jest już poprawiony w WUP-695)
- nowy skills (`/repo`, `AGENT_COLLECTIONS_HOME`)
- nowy klucz Jira, nowe zależności npm, UI / Figma / BA Docs

## Proposed Solution

Trzy warstwy, które muszą ze sobą grać — sama zmiana `context.ts` albo samego szablonu MCP nie naprawia Błędu 1:

1. **Host MCP** — wpis `eversis-collections` dostaje `env.CONSUMER_PROJECT_ROOT` (token IDE = folder konsumenta). To emituje **merger**, nie ręczna edycja JSON.
2. **Compose** — wolumen `${CONSUMER_PROJECT_ROOT:-${PWD}}:/workspace` interpolowany na hoście; w kontenerze `CONSUMER_PROJECT_ROOT=/workspace`.
3. **Runtime MCP** — `resolveWorkspaceRoot` używa `/workspace` tylko gdy leży tam `.agent-collections/install-selection.json`; pierwsza kolumna INDEX zrzuca `[tekst](url)` do `tekst`. Strażnik `getContext` (`/` i `..`) zostaje.

```text
Host MCP env CONSUMER_PROJECT_ROOT = folder workspace konsumenta
        │  docker compose interpoluje wolumen
        ▼
${CONSUMER_PROJECT_ROOT:-${PWD}}:/workspace
        │  env w kontenerze CONSUMER_PROJECT_ROOT=/workspace
        ▼
resolveWorkspaceRootFrom(env, "/workspace", cwd)
        │  użyj /workspace tylko, gdy istnieje tam install-selection.json
        ▼
eversis_context_list / get / sync
```

Seam (kontrakt, bez ciała):

```ts
function resolveWorkspaceRootFrom(
  env: NodeJS.Dict<string | undefined>,
  workspaceMount: string,
  cwd: string,
): string
```

Kolejność: (1) `env.CONSUMER_PROJECT_ROOT`, jeśli katalog zawiera `install-selection.json`; (2) `workspaceMount` pod tym samym warunkiem; (3) `cwd`. `resolveWorkspaceRoot()` woła ten helper z `process.env`, `"/workspace"`, `process.cwd()`.

Hostowe tokeny (oba tryby: relative vendor i absolute local):

| Host | `env.CONSUMER_PROJECT_ROOT` |
|------|-----------------------------|
| Cursor | `${workspaceFolder}` |
| Claude | `${CLAUDE_PROJECT_DIR:-.}` (bez `${workspaceFolder}`) |

## Current Implementation Analysis

### Already Implemented

- `listContext` / `getContext` / `syncContext` — `mcp/eversis-collections-mcp/src/context.ts` — narzędzia kontekstu; strażnik path traversal w `getContext` zostaje
- Fixture `setRoot()` / `makeConsumerRoot()` — `mcp/eversis-collections-mcp/tests/context.test.ts` — istniejące testy ustawiają `CONSUMER_PROJECT_ROOT`; rozszerzyć, nie zastępować
- Merger host branching Cursor vs Claude — `scripts/lib/setup-agent-collections/mcp-merge.mjs` — przebudowa `command`/`args`/`type` zostaje; dodać `env`
- `_assert_docker_entry` — `scripts/lib/setup-agent-collections/mcp-merge.test.sh` — asercja ścieżki `-f`; zmienić warunek `env`
- Szablon serwerów MCP — `templates/mcp.json` — katalog serwerów; merger i tak nadpisuje wpis `eversis-collections`
- Smoke instalatora — `scripts/setup-agent-collections.test.sh` — nie zabrania `env` poza grepem `${env:` w Claude

### To Be Modified

- `resolveWorkspaceRoot` / `readIndexComponents` — `mcp/eversis-collections-mcp/src/context.ts` — root tylko z selection; zrzucanie linku INDEX
- Testy kontekstu — `mcp/eversis-collections-mcp/tests/context.test.ts` — mount bez selection; INDEX z markdown linkiem; goła nazwa nadal działa
- `docker-compose.yml` — bind + env w kontenerze; komentarz o `${PWD}` jest nieaktualny
- `mcp-merge.mjs` — obiekt `eversis-collections` musi zawierać `env.CONSUMER_PROJECT_ROOT`
- `mcp-merge.test.sh` — wymagać `env`, nie zabraniać; zaktualizować labele „no env block”
- `templates/mcp.json` — dodać hostowe `env` (dokumentacja / kopia ręczna; SSOT wygenerowanego pliku = merger)
- `README.md`, `website/docs/getting-started/mcp-setup.md`, `website/docs/integrations/eversis-collections.md` — kontrakt `CONSUMER_PROJECT_ROOT`, nie gołe `${PWD}`
- `CHANGELOG.md` — `[Unreleased]` / Fixed + krótka Migration

### To Be Created

- Nic nowego jako osobny pakiet. Ewentualny helper `resolveWorkspaceRootFrom` i zrzucanie linku INDEX żyją w istniejącym `context.ts` (albo tuż obok, w tym samym module).

## Open Questions

| #   | Question   | Answer   | Status                |
| --- | ---------- | -------- | --------------------- |
| 1   | Docelowa gałąź git? | `ssot` | ✅ Resolved (`Q1. OK;`) |
| 2   | Cherry-pick `15f4e28` czy re-apply? | Re-apply na bieżący HEAD `ssot`; bez cherry-pick | ✅ Resolved (`Q2. OK;`) |
| 3   | Czy `mcp-merge.mjs` w zakresie? | Tak; asercja ma wymagać `env.CONSUMER_PROJECT_ROOT` | ✅ Resolved (`Q3. OK;`) |
| 4   | Docs / CHANGELOG w tym zgłoszeniu? | Tak | ✅ Resolved (`Q4. OK;`) |
| 5   | Strip INDEX markdown w tym zgłoszeniu? | Tak | ✅ Resolved (`Q5. OK;`) |
| 6   | Nowy klucz Jira? | Nie; kontynuacja DHI-630 | ✅ Resolved (`Q6. OK;`) |

## Technical Context

Project conventions, coding standards, and patterns discovered during planning. Downstream agents MUST read this section instead of re-discovering the same context.

### Project Instructions

- `AGENTS.md` — framework repo; jakość z root `package.json`; specy w `docs/specs/<issue-kebab>/` (tu gitignore)
- `.cursor/rules/eversis-project-stack.mdc` — komendy: `npm run mcp:build`, `npm run mcp:test`, `bash scripts/setup-agent-collections.test.sh`, `npm run website:changelog:check`; skill `eversis-writing-repo-documentation` przy README/CHANGELOG/docs; **nie** ładować frontend/backend/filters/BA Docs
- `.cursor/rules/eversis-testing-and-terminal.mdc` — po zmianie kodu: lint/typecheck/test z stack policy
- Implementacja na gałęzi `ssot` w `/Users/piotrniemirski/Documents/Projects/agent-collections`. Push na `origin/ssot` tylko po jawnym OK

### Architecture & Patterns

- Skills: `AGENT_COLLECTIONS_HOME` / mount `.:/repo`. Kontekst domenowy: osobny mount `/workspace` i `CONSUMER_PROJECT_ROOT` — nie mieszać
- Instalator: `mcp-merge.mjs` **zastępuje cały** wpis `eversis-collections`; klon z `templates/mcp.json` nie przetrwa. `env` musi trafić do przebudowanego obiektu
- Cursor: `${workspaceFolder}`, `${env:AGENT_COLLECTIONS_HOME}`. Claude: `${CLAUDE_PROJECT_DIR:-.}`, `${VAR:-default}`, bez `${env:…}` i bez `${workspaceFolder}`
- INDEX: pierwsza kolumna = identyfikator katalogu `docs/context/<projekt>/<id>/index.md`

### Tech Stack

- MCP: TypeScript, Node ≥18, `node:test` + `tsx` (`mcp/eversis-collections-mcp/package.json`)
- Installer: Bash + Node `*.mjs`
- Docs site: Docusaurus; `CHANGELOG.md` jest SSOT, `website/src/pages/changelog.md` generuje `scripts/sync-changelog.mjs`
- Compose: Docker Compose bind + `environment`

### Code Style & Standards

- Testy MCP: `node:assert/strict`, `test()` z `node:test`, tempdir + `setRoot`/`restoreRoot` w `finally`
- Błędy: konkretny `Error` (np. `install-selection.json not found under …`, `Invalid component name`) — nie połykać
- Nie dodawać zależności npm bez zgody

### Testing Patterns

- MCP: `npm run mcp:test` (z roota; woła `context.test.ts`). Typecheck: `npm run mcp:build`
- Merger: `bash scripts/lib/setup-agent-collections/mcp-merge.test.sh`
- Smoke instalatora (po zmianie mergera): `bash scripts/setup-agent-collections.test.sh`
- Changelog: `npm run website:changelog:check` (po wpisie w `CHANGELOG.md`; w razie driftu `npm run website:changelog:sync`)
- Nie ma lint-skryptu dla samego MCP poza `tsc`

### Database Patterns

- Nie dotyczy — brak zmian bazy.

### Additional Context

- Prototyp Sternika `15f4e28` jest tylko referencją; rodzic `f110dbc`, nie nakładać na `dc12ecc`
- Istniejące testy MCP **nigdy** nie pokrywają `/workspace` bez selection — to luka, nie regresja do zachowania
- `_assert_docker_entry` dziś kończy się `if ("env" in e) process.exit(1)` i komentarzem, że hostowe env nie jest potrzebne (prawda tylko dla `/repo`)
- Q4: routing dokumentacji → prompt `eversis-repo-docs-writer` / skill `eversis-writing-repo-documentation` (treść docs, nie kod produktu)

## Implementation Plan

### Phase 1: Runtime MCP (root + INDEX)

**Goal**: `eversis_context_*` nie traktuje gołego `/workspace` jako konsumenta i akceptuje identyfikator z linku markdown w INDEX.

**Description**: Błąd 1 (obrona w `resolveWorkspaceRoot`) i Błąd 2 (strip INDEX) w jednym module. Bez Compose/mergera runtime w Dockerze nadal może dostać zły mount — stąd Faza 2. Najpierw zachowanie i testy, które dziś nie istnieją.

**Verification:** `npm run mcp:test` oraz `npm run mcp:build`

#### Task 1.1 - [MODIFY] resolveWorkspaceRoot tylko przy install-selection.json

**Description**: Wydzielić `resolveWorkspaceRootFrom` i zmienić priorytet katalogu głównego tak, by `/workspace` (oraz `CONSUMER_PROJECT_ROOT`) były używane wyłącznie, gdy zawierają `.agent-collections/install-selection.json`. Dodać test: `CONSUMER_PROJECT_ROOT` wyłączone, podstawiony mount bez selection → nie ten katalog; mount z selection → ten katalog. Istniejące testy z `setRoot()` nadal przechodzą.

**Files:** `mcp/eversis-collections-mcp/src/context.ts` (modify), `mcp/eversis-collections-mcp/tests/context.test.ts` (modify)

**Definition of Done**:

- [x] `resolveWorkspaceRootFrom` jest wywoływane z `process.env`, `"/workspace"`, `process.cwd()`
- [x] Katalog bez `install-selection.json` nie jest wybierany jako root, nawet gdy istnieje jako mount
- [x] `mcp/eversis-collections-mcp/tests/context.test.ts` zawiera przypadek mountu bez selection i z selection
- [x] Run `npm run mcp:test`
- [x] Run `npm run mcp:build`

**Stop Rule:** Nie cherry-pickować `15f4e28`. Nie usuwać strażnika `getContext` (`/` / `..`).

**Clues**: Dziś `if (fs.existsSync("/workspace")) return "/workspace"` bez selection. Testy produkcyjne nie mogą polegać na prawdziwym `/workspace` w CI — wstrzyknąć `workspaceMount` (tempdir). `findRepoRoot` w `resolveRoot.ts` to inny problem (skills) — nie ruszać.

#### Task 1.2 - [MODIFY] zrzucanie linku markdown w pierwszej kolumnie INDEX

**Description**: `readIndexComponents` ma z komórki `[checkout](./checkout/index.md)` zrobić `checkout`. Goła nazwa (`| checkout |`) bez zmiany. `listContext` zwraca identyfikator; `getContext("checkout")` znajduje plik. Po stripie strażnik `/` / `..` nadal odrzuca złośliwe nazwy.

**Files:** `mcp/eversis-collections-mcp/src/context.ts` (modify — Task 1.1), `mcp/eversis-collections-mcp/tests/context.test.ts` (modify — Task 1.1)

**Definition of Done**:

- [x] Test: INDEX z `| [checkout](./checkout/index.md) |` → `listContext` ma `component === "checkout"` i `getContext("checkout")` nie rzuca `Invalid component name`
- [x] Test: goła nazwa `| checkout |` nadal działa
- [x] Run `npm run mcp:test`

**Stop Rule:** Nie zmieniać kontraktu gołego identyfikatora na „akceptuj ścieżki z `/`”.

**Clues**: Regex wiersza: `/^\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*$/`. Strip tylko składni `[text](url)`, nie całego markdowna. Nagłówki `Component` / `---` nadal pomijać.

### Phase 2: Compose + installer env

**Goal**: Host i kontener dostarczają `CONSUMER_PROJECT_ROOT`, a `--upgrade --sync` nie kasuje tego kontraktu.

**Description**: Faza 1 broni złego mountu; ta faza sprawia, że dobry mount w ogóle powstaje. Merger jest SSOT wygenerowanego MCP JSON.

**Verification:** `bash scripts/lib/setup-agent-collections/mcp-merge.test.sh` oraz `bash scripts/setup-agent-collections.test.sh`

#### Task 2.1 - [MODIFY] bind-mount i env w docker-compose.yml

**Description**: Wolumen projektu: `${CONSUMER_PROJECT_ROOT:-${PWD}}:/workspace`. W `environment` serwisu: istniejące `AGENT_COLLECTIONS_HOME=/repo` plus `CONSUMER_PROJECT_ROOT=/workspace`. Zaktualizować komentarz nagłówkowy — nie twierdzić, że cwd procesu Compose zawsze = konsument.

**Files:** `docker-compose.yml` (modify)

**Definition of Done**:

- [x] W `docker-compose.yml` wolumen workspace używa `${CONSUMER_PROJECT_ROOT:-${PWD}}`, nie gołego `${PWD}`
- [x] Serwis `eversis-collections` ustawia `CONSUMER_PROJECT_ROOT: /workspace`
- [x] Komentarz nie uczy, że samo `${PWD}` wystarczy przy `-f vendor/…/docker-compose.yml`

**Stop Rule:** Nie zmieniać bindu `.:/repo` ani `AGENT_COLLECTIONS_HOME: /repo`.

**Clues**: Interpolacja `${CONSUMER_PROJECT_ROOT}` dzieje się na hoście (env procesu `docker`), nie w kontenerze. In-container `/workspace` to już zinterpolowana ścieżka.

#### Task 2.2 - [MODIFY] merger emituje env.CONSUMER_PROJECT_ROOT

**Description**: W przebudowanym obiekcie `eversis-collections` dodać `env.CONSUMER_PROJECT_ROOT` (tokeny z tabeli w Proposed Solution). `templates/mcp.json` też dostać `env` (kopia ręczna). `_assert_docker_entry` **wymaga** `env.CONSUMER_PROJECT_ROOT` o oczekiwanej wartości; usunąć `if ("env" in e) process.exit(1)` i labele „no env block”. Claude nadal bez `${env:` i `${workspaceFolder}` w args/`env`.

**Files:** `scripts/lib/setup-agent-collections/mcp-merge.mjs` (modify), `scripts/lib/setup-agent-collections/mcp-merge.test.sh` (modify), `templates/mcp.json` (modify)

**Definition of Done**:

- [x] Cursor (relative i absolute): `mcpServers["eversis-collections"].env.CONSUMER_PROJECT_ROOT` === `${workspaceFolder}`
- [x] Claude (relative i absolute): ta sama wartość === `${CLAUDE_PROJECT_DIR:-.}`
- [x] `_assert_docker_entry` pada, gdy brak `env` albo zły token
- [x] `templates/mcp.json` ma `env.CONSUMER_PROJECT_ROOT` na wpisie `eversis-collections`
- [x] Run `bash scripts/lib/setup-agent-collections/mcp-merge.test.sh`
- [x] Run `bash scripts/setup-agent-collections.test.sh`

**Stop Rule:** Nie polegać na klonie z szablonu — merger i tak nadpisuje cały wpis. Nie dawać Claude `${workspaceFolder}`.

**Clues**: Blok ok. linii 81–85 w `mcp-merge.mjs` buduje `{ command, args, type }` — tu dodać `env`. Case 2/3 testów wprost mówią „no env block”. Smoke `setup-agent-collections.test.sh` grepuje `${env:` tylko w Claude `.mcp.json` (args `-f`) — nie psuć tego; hostowe env Claude to `${CLAUDE_PROJECT_DIR:-.}`.

### Phase 3: Dokumentacja i CHANGELOG

**Goal**: Konsument wie, że domenowy kontekst wymaga hostowego `CONSUMER_PROJECT_ROOT` (installer albo ręczne env), a nie samego `${PWD}`.

**Description**: Q4. Routing: Repo Docs Writer (`eversis-repo-docs-writer` + `eversis-writing-repo-documentation`). Opisać zachowanie po Fazach 1–2, nie stary kontrakt.

**Verification:** `npm run website:changelog:check`

#### Task 3.1 - [MODIFY] README, website MCP docs, CHANGELOG

**Description**: Zastąpić naukę `${PWD}:/workspace` kontraktem `CONSUMER_PROJECT_ROOT`. CHANGELOG `[Unreleased]` / Fixed + krótka Migration: istniejący konsument ustawia hostowe env albo ponownie uruchamia instalator (`--upgrade --sync`). Zsynchronizować stronę changelogu, jeśli check wykaże drift.

**Files:** `README.md` (modify), `website/docs/getting-started/mcp-setup.md` (modify), `website/docs/integrations/eversis-collections.md` (modify), `CHANGELOG.md` (modify)

**Definition of Done**:

- [x] `README.md` nie twierdzi, że domenowy kontekst wymaga wyłącznie `${PWD}:/workspace`
- [x] `website/docs/getting-started/mcp-setup.md` (sekcja „Domain context needs the project volume”) opisuje `CONSUMER_PROJECT_ROOT` i fallback `${PWD}`; ostrożność „silent wrong directory” zaktualizowana albo usunięta, jeśli Faza 1 zamienia ciszę w błąd selection
- [x] `website/docs/integrations/eversis-collections.md` zgodna z tym kontraktem
- [x] `CHANGELOG.md` `[Unreleased]` ma Fixed oraz Migration z krokiem dla istniejących konsumentów
- [x] Run `npm run website:changelog:check`

**Stop Rule:** Nie edytować `website/src/pages/changelog.md` ręcznie (generowany). Nie ruszać `.ai/` skills/prompts w tym zadaniu.

**Clues**: Miejsca `${PWD}`: `README.md` ok. 286; `mcp-setup.md` ok. 66–79; `eversis-collections.md` ok. 214 i 222. Policy CHANGELOG: Breaking/Migration w root `CHANGELOG.md`. Po edycji: `npm run website:changelog:sync` jeśli `--check` padnie.

### Phase 4: Code Review

**Goal**: Niezależna weryfikacja, że trzy warstwy (runtime, Compose/merger, docs) realizują WIG bez osłabienia path traversal i skills `/repo`.

**Description**: Końcowa weryfikacja pełnej implementacji. Faza obowiązkowa, zawsze ostatnia.

**Verification:** `npm run mcp:test` oraz `npm run mcp:build` oraz `bash scripts/lib/setup-agent-collections/mcp-merge.test.sh`

#### Task 4.1 - [REUSE] Code review by Code Reviewer

**Description**: Run **Code Reviewer** via `eversis-review.md` to review the complete implementation. Pass e2e test execution to that agent — do not run e2e tests outside this review.

**Files:** `mcp/eversis-collections-mcp/src/context.ts` (reuse), `mcp/eversis-collections-mcp/tests/context.test.ts` (reuse), `docker-compose.yml` (reuse), `scripts/lib/setup-agent-collections/mcp-merge.mjs` (reuse), `scripts/lib/setup-agent-collections/mcp-merge.test.sh` (reuse), `templates/mcp.json` (reuse), `README.md` (reuse), `website/docs/getting-started/mcp-setup.md` (reuse), `website/docs/integrations/eversis-collections.md` (reuse), `CHANGELOG.md` (reuse)

**Definition of Done**:

- [x] Run `npm run mcp:test`
- [x] Run `npm run mcp:build`
- [x] Run `bash scripts/lib/setup-agent-collections/mcp-merge.test.sh`
- [x] Code review passes with no blocking findings
- [x] Review outcome documented in Changelog

**Stop Rule:** Self-review implementującego kontekstu nie liczy się jako PASS.

**Clues**: Ryzyka: merger znowu gubi `env`; Claude dostał `${workspaceFolder}`; `/workspace` używany bez selection; strip INDEX psuje nagłówki tabeli; osłabiony strażnik `getContext`; docs nadal uczą `${PWD}`.

## Security Considerations

- `CONSUMER_PROJECT_ROOT` to ścieżka katalogu projektu, nie sekret — nie logować zbędnie, nie wkładać w obraz Dockera z hosta poza bind-mount
- Strażnik `getContext` (`..` i `/`) zostaje; strip INDEX nie może pozwolić na `../` w identyfikatorze
- Tokeny IDE (`${workspaceFolder}`, `${CLAUDE_PROJECT_DIR:-.}`) są interpolowane przez host MCP, nie przez nasz kod — nie ewaluować ich w Node
- Skills nadal czytają tylko `/repo`; kontekst nie może spaść na drzewo vendora z `.ai/` i uznać go za `docs/context` konsumenta

## Quality Assurance

Acceptance criteria checklist to verify the implementation meets the defined requirements:

- [x] Gdy `/workspace` istnieje, ale nie ma `install-selection.json`, `eversis_context_list` nie przyjmuje tego katalogu jako root
- [x] Gdy host ustawia `CONSUMER_PROJECT_ROOT` na katalog konsumenta (z selection), list/get/sync działają
- [x] INDEX `| [checkout](./checkout/index.md) |` → `getContext("checkout")` działa; goła nazwa nadal działa
- [x] `mcp-merge` (Cursor i Claude, relative i absolute) emituje poprawny `env.CONSUMER_PROJECT_ROOT`; `--upgrade --sync` nie kasuje `env`
- [x] `docker-compose.yml` montuje `${CONSUMER_PROJECT_ROOT:-${PWD}}:/workspace` i ustawia in-container `CONSUMER_PROJECT_ROOT=/workspace`
- [x] README + website MCP docs + CHANGELOG `[Unreleased]` (Fixed + Migration) opisują nowy kontrakt
- [x] `npm run mcp:test`, `npm run mcp:build`, `bash scripts/lib/setup-agent-collections/mcp-merge.test.sh` przechodzą

## Improvements (Out of Scope)

- Osobny ticket DHI, jeśli QA będzie chciało osobnego klucza od kontynuacji DHI-630
- Backport / bump podmodułu Sternika po wylądowaniu na `origin/ssot` (poza tym repo)
- Zmiana WORKDIR obrazu MCP (`/app`) — nie jest rootem kontekstu po tej poprawce
- Automatyczne wykrywanie konsumenta walk-upem od cwd poza `install-selection.json`

## Human gates

1. ~~Approve research~~ — done (`Gap Analysis: Q1. OK; Q2. OK; Q3. OK; Q4. OK; Q5. OK; Q6. OK;`)
2. ~~Approve this plan~~ — done (`Plan is ok. Implement`)
3. ~~Implement → Review → Fine~~ — done (review PASS, Fine this turn)

## Code Review Findings

**Reviewer:** Code Reviewer (`eversis-review`, delegated context — not implementer self-review)  
**Date:** 2026-09-02  
**Verdict:** PASS (zero BLOCKER; every visible DoD/AC checkbox verified)

### STRICT FORBIDDEN

| Constraint | Result |
| ---------- | ------ |
| Scope | All modified files are in the plan (generated `website/src/pages/changelog.md` via changelog sync). `resolveRoot.ts` / skills `/repo` untouched. No new npm dependencies. |
| Documentation comments | Module comment in `context.ts` kept; docker-compose header rewritten as Task 2.1 required (not silently shortened). |
| Dependencies | No `package.json` / lockfile changes. |

### Plan clues (re-checked)

| Clue | Result |
| ---- | ------ |
| Merger drops `env` | `_assert_docker_entry` now **requires** `env.CONSUMER_PROJECT_ROOT`; Cursor/Claude × relative/absolute all emit the correct token. |
| Claude got `${workspaceFolder}` | Claude `.mcp.json` grepped: no `${env:` and no `workspaceFolder`; env token is `${CLAUDE_PROJECT_DIR:-.}`. |
| `/workspace` used without selection | `resolveWorkspaceRootFrom` returns cwd unless `install-selection.json` is present on env root or mount. |
| INDEX strip breaks table headers | Skip of `Component` / `---` still runs **after** strip; test INDEX includes header rows. |
| Weakened `getContext` path-traversal | Guard `..` / `/` unchanged; existing `../../etc` test still passes. Strip uses link **text**, not URL. |
| Docs still teach `${PWD}` as sufficient | README / mcp-setup / eversis-collections / CHANGELOG describe `CONSUMER_PROJECT_ROOT` with `${PWD}` as fallback only. |

### Quality commands (re-run this review)

| Command | Result |
| ------- | ------ |
| `npm run mcp:test` | PASS (23/23) |
| `npm run mcp:build` | PASS (`tsc`) |
| `bash scripts/lib/setup-agent-collections/mcp-merge.test.sh` | PASS (13 tests) |
| `bash scripts/setup-agent-collections.test.sh` | PASS (`[smoke] PASS`) |
| `npm run website:changelog:check` | PASS |

### BLOCKER

None.

### SUGGESTION

1. `website/docs/integrations/eversis-collections.md` “Workspace (this repository)” JSON snippet still omits `env.CONSUMER_PROJECT_ROOT`. Surrounding prose is correct; a copy-paste of that block would skip host env (PWD fallback often works for this repo’s own checkout).
2. `templates/mcp.json` env token is Cursor `${workspaceFolder}` only. Merger overwrites the whole `eversis-collections` entry per host, so generated Claude JSON is fine; a manual template copy into Claude would not expand that token.
3. INDEX markdown-link test does not assert `list.length === 1` (leaked header rows would not fail unless named `checkout`). Existing skip logic still holds for `Component` / `---`.
4. When `/workspace` lacks selection, the error path is **cwd** (container WORKDIR, typically `/app`), so the message is `install-selection.json not found under /app` rather than under `/workspace`. Docs that mention `install-selection.json not found` remain accurate.

## Changelog

| Date   | Change Description   |
| ------ | -------------------- |
| 2026-09-02 | Initial plan created (Q1–Q6 locked; re-apply on `ssot`; merger + INDEX + docs in scope) |
| 2026-09-02 | Implementation complete (Phases 1–3). Awaiting code review. |
| 2026-09-02 | Code review PASS (delegated Code Reviewer). Zero BLOCKER; all DoD/AC checkboxes verified. Four SUGGESTION items (JSON snippet without env; template Cursor-only token; INDEX list.length assertion; error path uses cwd). Quality commands re-run and passing. |
| 2026-09-02 | Fine. |
