# claude-code-setup - Implementation Plan

## Task Details

| Field            | Value                   |
| ---------------- | ----------------------- |
| Jira ID          | brak (research poprzedza założenie ticketów) |
| Title            | Claude Code — parytet adaptera i kontrakt setupu projektu konsumenckiego |
| Description      | Zamknięcie luk F1–F11 zidentyfikowanych w research: instalator nie konfiguruje Claude Code (MCP, komendy, skille, settings), wygenerowany `CLAUDE.md` wskazuje nieistniejące ścieżki, brak path-scopingu i `.claudeignore` jest no-opem. |
| Priority         | Wysoka (F3, F11 — krytyczne blokery parytetu Claude Code) |
| Related Research | [`claude-code-setup.research.md`](./claude-code-setup.research.md) |

## Wildly Important Goal

**Goal**: Instalacja `--agents=claude` (lub `claude` w zestawie `--agents`) w projekcie konsumenckim daje działający, natywnie odkrywalny zestaw: MCP (`.mcp.json`), slash commands (`.claude/commands/`), skille (`.claude/skills/`), ustawienia (`.claude/settings.json`) i poprawne odnośniki do promptów/skilli we frameworku — bez ręcznej pracy dzisiejszego runbooka z §5 research.

**Success Measure**: Świeży `bash scripts/setup-agent-collections.sh --non-interactive --agents=claude ...` w scratch-repo przechodzi kontrakt akceptacyjny z research §5.6 (MCP połączone, komendy i skille widoczne, `CLAUDE.md` bez ścieżek `.ai/...` donikąd), a `npm run sync:adapters:check` pozostaje zielony w tym repozytorium.

**Do NOT touch / do NOT add**: adapter OpenCode (status `placeholder`) · treść merytoryczna reguł `.ai/rules/**` (poza przeniesieniem, nie edycją, reguły `eversis-accessibility` w fazie F) · hooki Claude Code · packaging pluginów · Claude Code na CI · pełna kompresja `CLAUDE.md` poniżej 200 linii (poza rulami z `globs`) · zmiany w `mcp/eversis-collections-mcp/src/resolveRoot.ts` (F9 zamykane po stronie generowania configu, nie resolvera) · nowe zależności npm.

## Proposed Solution

Siedem faz (A–G z research, w tej samej kolejności zależności) plus obowiązkowa faza code review. Każda faza zamyka jeden lub więcej findingów F1–F11 i jest niezależnie weryfikowalna (`npm run sync:adapters:check`, `bash scripts/setup-agent-collections.test.sh`, nowe testy jednostkowe skryptów lib w stylu `gitignore.test.sh`).

Zasada przewodnia: **jeden `.ai/` SSOT, wiele wygenerowanych/zlinkowanych powierzchni**. Nie duplikujemy treści promptów/skilli/reguł — generujemy cienkie wskaźniki (`.claude/commands/*.md`) albo linkujemy katalogi (`.claude/skills/*`), analogicznie do już istniejącego wzorca `.cursor/commands/` (DHI-598) i `_make_symlink` w `link-framework.sh`.

```text
COLLECTIONS_HOME (.ai/, adapters/, templates/, scripts/)
        │
        ├─ adapters/sync.mjs ──┬─ adapters/cursor/generate.mjs   → .cursor/rules, .cursor/commands (bez zmian)
        │                      └─ adapters/claude/generate.mjs   → CLAUDE.md (H2, bez globowanych) [B,F]
        │                                                         → .claude/commands/*.md (nowe)     [C]
        │                                                         → .claude/rules/*.md (nowe, paths:) [F]
        │
        ├─ scripts/lib/setup-agent-collections/
        │     mcp-merge.sh(+.mjs)        → .mcp.json (nowe, obok .cursor/mcp.json) [A]
        │     link-framework.sh          → .claude/skills/* (symlink/copy)         [D]
        │     claude-settings-merge.sh   → .claude/settings.json (nowe)            [E]
        │     scaffolding.sh             → .claude/CLAUDE.md (seed-once)           [G]
        │
        └─ docs/architecture/{isolation-strategy,adapter-mapping}.md, adapters/claude/README.md — korekty [E,G]
```

Transformacje configu (Faza A) są **przy zapisie**, nie przez osobny szablon per-host (Q6=a z research): jeden `templates/mcp.json`, `mcp-merge.mjs` dostaje parametr hosta i robi podmianę składni (`${env:X}` → `${X}`/`${CLAUDE_PROJECT_DIR:-.}`, drop `inputs`, jawny `env` dla `eversis-collections`).

<!-- Note: plan nie zawiera realnego kodu implementacyjnego; sygnatury/kontrakty (nazwy flag CLI, nazwy zmiennych env, kształt JSON) są dozwolone jako task-boundary seams. -->

## Current Implementation Analysis

### Already Implemented

- `merge_mcp_json()` — `scripts/lib/setup-agent-collections/mcp-merge.sh:4-57` — merguje `templates/mcp.json` do `.cursor/mcp.json` przez `mcp-merge.mjs`; **wyłącznie Cursor**, brak rozgałęzienia po `SELECTED_AGENTS`.
- `_make_symlink()` — `scripts/lib/setup-agent-collections/link-framework.sh:6-22` — gotowy prymityw symlink/copy (Windows junction / relative symlink / absolute fallback), gotowy do reużycia dla `.claude/skills/`.
- `EFFECTIVE_LINK_MODE` — `link-framework.sh:76-83` — liczony, ale dziś **nieużywany** (brak konsumenta) — pierwszy realny konsument powstaje w Fazie D.
- `_prune_deselected_agents()` — `link-framework.sh:43-60` — bezpieczne usuwanie artefaktów po markerze GENERATED, wzorzec do rozszerzenia w Fazie D.
- Wzorzec warunku po agencie: `echo ",${SELECTED_AGENTS:-}," | grep -q ',claude,'` — już użyty w `area-scope.sh:41-43` (`_append_claude_area_guidance`) i `link-framework.sh` — kanoniczny idiom do powielenia w fazach A, D, E.
- `adapters/cursor/generate.mjs:317-484` — kompletny generator `.cursor/commands/*.md` z DHI-598: `loadCommandDeny()`, `discoverPromptCommands()`, `extractPromptMeta()`, `extractExecutableSection()`, `buildCommandContent()` (marker GENERATED **na końcu pliku** — świadoma poprawka UX), `cleanupOrphanCommands()` (orphan-detekcja bramkowana markerem). To jest źródło do portu w Fazie C.
- `adapters/sync.mjs:308-401 (runCheck)` — drift-check + orphan-detekcja dla `.cursor/rules/*.mdc`, `.cursor/commands/eversis-*.md`, `CLAUDE.md`; `assertIdSourceParity()` (226-254) dla parytetu map Cursor/Claude.
- `area-scope.sh:51-80 (_append_claude_area_guidance)` — istniejący wzorzec merge sekcji znacznikowej (`<!-- agent-collections-area-scope -->`) w `CLAUDE.md` — wzorzec do naśladowania dla merge `.claude/settings.json` w Fazie E.
- `scripts/lib/setup-agent-collections/gitignore.test.sh` — wzorzec testu jednostkowego lib (source lib bezpośrednio, `_pass`/`_fail`, fixture przez heredoc) — szablon dla nowych testów w fazach A/D/E.
- `.claudeignore` (root, 26 linii) — dwie oznaczone klasy (`secrets/build`, `other-tool packaging`) — źródło prawdy do generowania `permissions.deny` w Fazie E.

### To Be Modified

- `scripts/lib/setup-agent-collections/mcp-merge.sh` — dodać gałąź `claude` obok istniejącej (niezmienionej) gałęzi `cursor`. **[A]**
- `scripts/lib/setup-agent-collections/mcp-merge.mjs` — parametr hosta + transformacja składni env. **[A]**
- `adapters/claude/generate.mjs` — flaga `--framework-prefix`, dynamiczna sekcja How-to, wyłączenie rul z `globs` z pętli H2. **[B, F]**
- `adapters/sync.mjs` — przekazanie `--framework-prefix`, wywołanie generatora `.claude/commands/`, rozszerzenie `runCheck()` o `.claude/commands/*.md` i `.claude/rules/*.md`. **[B, C, F]**
- `scripts/lib/setup-agent-collections/link-framework.sh` — `_run_adapter_sync()` (prefix), nowa pętla linkowania skilli w `link_framework_files()`, rozszerzenie `_prune_deselected_agents()`. **[B, D]**
- `scripts/setup-agent-collections.sh` — nowe wywołanie `merge_claude_settings` w sekwencji (linia ~226-227 sąsiedztwo). **[E]**
- `scripts/lib/setup-agent-collections/scaffolding.sh` — seed `.claude/CLAUDE.md` (copy-if-absent). **[G]**
- `adapters/claude/rule-map.yaml` — usunięcie/oznaczenie `eversis-accessibility` jako emitowanej przez `.claude/rules/`, nie H2. **[F]**
- `adapters/claude/README.md` — tabela "Generated rule ids", tabela "Exceptions", akapit "Consumer project notes" (AGENTS.md ↔ `.claude/CLAUDE.md`). **[F, G]**
- `docs/architecture/isolation-strategy.md` §4, §8.1, linia 109. **[E]**
- `docs/architecture/adapter-mapping.md` §5.1 ("native Claude command files are deferred"), §2 (emit matrix, wiersz Claude). **[C, G]**
- `scripts/lib/setup-agent-collections/summary.sh` — linia "Customise" dla Claude (`AGENTS.md` → `.claude/CLAUDE.md`), odblokowanie zawsze-drukowanego przypomnienia AGENTS.md, aktualizacja akapitu "Deselection". **[I — DELTA 2026-08-13, F12]**

### To Be Created

- `.mcp.json` (w konsumencie, root) — generowany, nie w tym repo (self-host nie potrzebuje submodułu). **[A]**
- `adapters/claude/command-deny.yaml` — analog `adapters/cursor/command-deny.yaml`. **[C]**
- Generator komend Claude (nowy plik `adapters/claude/generate-commands.mjs` albo funkcja w `generate.mjs`). **[C]**
- `templates/claude-settings.json` — szablon `.claude/settings.json`. **[E]**
- `scripts/lib/setup-agent-collections/claude-settings-merge.sh` (+ mały `.mjs` merge helper) — merge znacznikowy `permissions.deny`/`enabledMcpjsonServers`. **[E]**
- `templates/claude-CLAUDE.template.md` — seed dla `.claude/CLAUDE.md`. **[G]**
- Testy jednostkowe: `mcp-merge.test.sh`, rozszerzenie `setup-agent-collections.test.sh` o asercje `--agents=claude`. **[A, B, D, E]**

## Open Questions

| #   | Question   | Answer   | Status                |
| --- | ---------- | -------- | --------------------- |
| 1   | Czy adapter Claude ma emitować slash commands? | (a) `.claude/commands/*.md` — parytet 1:1 z Cursorem | ✅ Resolved |
| 2   | Jak wystawić 45 skilli? | (b) linkowanie z instalatora wg `EFFECTIVE_LINK_MODE` | ✅ Resolved |
| 3   | Rozbić `CLAUDE.md` na `.claude/rules/` z `paths:`? | (a) tak, przenieść reguły z globami (dziś: `eversis-accessibility`) | ✅ Resolved |
| 4   | Co z `.claudeignore`? | (c) zostawić jako źródło klas, generować z niego `permissions.deny` | ✅ Resolved |
| 5   | Czy instalator ma pisać `.mcp.json`? | (a) tak, gdy `claude` ∈ `--agents` | ✅ Resolved |
| 6   | Czy `templates/mcp.json` rozbić per-host? | (a) jeden szablon + transformacja składni przy zapisie | ✅ Resolved |
| 7   | Jak naprawić ścieżki `.ai/...` (F11)? | (a) generator przyjmuje prefiks frameworka i przepisuje sekcję How-to | ✅ Resolved |
| 8   | Czyją własnością jest `.claude/settings.json`? | (b) merge znacznikowy dla `permissions.deny`/`enabledMcpjsonServers`, (a) seed-once dla reszty | ✅ Resolved |

Odpowiedzi przyjęte z rekomendacji research §6. **Do zatwierdzenia przez człowieka razem z resztą planu** — jeśli maintainer chce innej opcji dla któregoś Q, plan wymaga rewizji przed dalszym review/egzekucją.

## Technical Context

### Project Instructions

- `.ai/rules/orchestration/{agent-core,spec-driven-development,engineering-manager}.md` — Delivery Standard: Ideate → Research → Plan → Implement → Review → Fine, human gate przed planem i przed szeroką implementacją. Ten plan wymaga zatwierdzenia człowieka przed egzekucją (Full Flow).
- `.ai/skills/eversis-creating-implementation-plans/SKILL.md` — właściciel struktury planu (`plan.example.md`), zasad DoD, bramki Open Questions/executable slots.

### Architecture & Patterns

- Framework ma trzy adaptery (`adapters/{cursor,claude,opencode}/`) generowane z jednego rdzenia `.ai/rules/**` + jednej mapy `rule-map.yaml` per adapter (parytet `id`/`source` wymuszony przez `assertIdSourceParity()`).
- Instalator to biblioteka bash `scripts/lib/setup-agent-collections/*.sh` sourcowana z `scripts/setup-agent-collections.sh`, jedna funkcja = jeden krok, każdy krok rejestrowany przez `record_ok`/`record_fail` i widoczny w `print_summary`.
- Kanoniczny idiom warunku po agencie: `echo ",${SELECTED_AGENTS:-}," | grep -q ',<agent>,'`.
- Node-side generatory (`adapters/*/generate.mjs`, `adapters/sync.mjs`) są zero-dependency (tylko stdlib `fs`/`path`), własny minimalny parser YAML — **nie wprowadzać** `js-yaml` ani innych zależności (hard limit: brak nowych zależności bez zgody).
- Marker GENERATED (`<!-- GENERATED by adapters/... — do not edit; re-run the generator -->`) bramkuje orphan-detekcję i bezpieczne nadpisywanie; pliki bez markera (project-owned) nigdy nie są nadpisywane/kasowane.

### Tech Stack

- Node.js ≥18 (stdlib only) dla generatorów i mergerów.
- Bash (`set -euo pipefail` idiom) dla warstwy instalatora.
- Root `package.json` scripts: `sync:adapters`, `sync:adapters:check`, `mcp:build`, `mcp:test`, `installer:smoke`.

### Code Style & Standards

- Generatory: `fail(message)` + `process.exit(1)` na błąd walidacji, nigdy throw nieobsłużony.
- Skrypty bash: funkcje z prefiksem `_` dla prywatnych helperów (np. `_make_symlink`, `_prune_deselected_agents`); publiczne entry points bez prefiksu (`merge_mcp_json`, `link_framework_files`).
- Ścieżki repo-relatywne walidowane przez `assertSafeRepoRelative()` (`adapters/claude/generate.mjs:159-171`) — reużyć tego wzorca przy nowych ścieżkach wejściowych z configu, nie duplikować.

### Testing Patterns

- `bash scripts/setup-agent-collections.test.sh` (`npm run installer:smoke`) — end-to-end smoke w scratch git repo, `[[ -f ... ]] || { echo FAIL; exit 1; }` + `node -e` asercje JSON.
- `bash scripts/lib/setup-agent-collections/gitignore.test.sh` — test jednostkowy lib, source bezpośredni, `_pass`/`_fail` counters, fixture heredoc — **wzorzec do skopiowania** dla `mcp-merge.test.sh` i ekwiwalentów w fazach D/E.
- `npm run sync:adapters:check` — drift + parytet id/source; musi pozostać zielony po każdej fazie dotykającej `adapters/`.
- `npm run mcp:test` (`node --import tsx/esm --test`) — dotyczy wyłącznie `mcp/eversis-collections-mcp`; ten plan go **nie** rusza (resolveRoot.ts poza zakresem), więc wystarczy upewnić się, że pozostaje zielony bez zmian.

### Database Patterns

Nie dotyczy (brak bazy danych w tym zadaniu).

### Additional Context

- `.ai/skills/eversis-code-reviewing` — standard finalnego code review (Faza H).
- Ten plan dotyczy wyłącznie repozytorium frameworka `agent-collections` — bez nazw/danych projektów konsumenckich (reguła DHI-528, jak w research).

## Implementation Plan

### Phase A: `.mcp.json` dla Claude Code — instalator honoruje `--agents`

**Goal**: Instalacja `--agents=claude` produkuje działający `.mcp.json` w roocie konsumenta zamiast milcząco pisać tylko `.cursor/mcp.json`.

**Description**: Zamyka F3 (instalator nigdy nie konfiguruje MCP dla Claude), F4 (składnia `${env:X}` niezrozumiała dla Claude Code) i F9 (kruchy resolveRoot bez jawnego `env`). Rozwiązanie: rozgałęzienie w `mcp-merge.sh` po `SELECTED_AGENTS` (istniejący idiom), transformacja składni w `mcp-merge.mjs` sterowana nowym parametrem hosta, jeden wspólny `templates/mcp.json` (Q6=a).

**Verification:** `bash scripts/setup-agent-collections.test.sh` · `bash scripts/lib/setup-agent-collections/mcp-merge.test.sh` · `npm run sync:adapters:check`

#### Task A.1 - [MODIFY] `mcp-merge.sh` — rozgałęzienie po agencie

**Description**: Owinąć istniejącą logikę Cursor (`cursor_dir`/`mcp_file`, `mcp-merge.sh:7-8`) w guard `echo ",${SELECTED_AGENTS:-}," | grep -q ',cursor,'`; dodać równoległą gałąź `claude`: cel `${TARGET_DIR}/.mcp.json`, wywołanie `node "$merge_mjs"` z dodatkowym `MCP_HOST=claude` w env, zachowując istniejącą walidację JSON (`node -e` parse check) i `record_ok`/`log_ok`.

**Files:** `scripts/lib/setup-agent-collections/mcp-merge.sh` (modify)

**Definition of Done**:

- [x] `merge_mcp_json()` pisze `.cursor/mcp.json` gdy `cursor` ∈ `SELECTED_AGENTS` (zachowanie niezmienione) i `.mcp.json` gdy `claude` ∈ `SELECTED_AGENTS`, niezależnie od siebie (oba mogą wystąpić razem)
- [x] Run `bash scripts/lib/setup-agent-collections/mcp-merge.test.sh` (Task A.4)

**Clues**: Wzorzec guardu identyczny jak `area-scope.sh:41-43`. Nie zmieniać zachowania dla `SELECTED_AGENTS` bez `claude` — musi być bit-identyczne z dzisiejszym.

#### Task A.2 - [MODIFY] `mcp-merge.mjs` — transformacja składni per host

**Description**: Dodać parametr hosta (odczyt `process.env.MCP_HOST`, domyślnie `cursor`) sterujący post-processingiem scalonego JSON przed zapisem: gdy `host === "claude"` → (1) rekurencyjnie zamienić `${env:VAR}` na `${VAR}` w wartościach string, (2) usunąć klucz top-level `inputs`, (3) dla wpisu `mcpServers.eversis-collections` wymusić jawny obiekt `env` zawierający `AGENT_COLLECTIONS_HOME` (jeśli brak — dodać, wartość z `MCP_COLLECTIONS_HOME`/relatywna per `MCP_USE_RELATIVE`), (4) podmienić `${workspaceFolder}` na `${CLAUDE_PROJECT_DIR:-.}`.

**Files:** `scripts/lib/setup-agent-collections/mcp-merge.mjs` (modify)

**Definition of Done**:

- [x] Dla `MCP_HOST=claude` wyjściowy JSON nie zawiera podciągu `${env:` ani klucza `inputs`; `mcpServers.eversis-collections.env.AGENT_COLLECTIONS_HOME` jest ustawione
- [x] Dla `MCP_HOST` nieustawionego/`cursor` wyjście identyczne jak przed zmianą (regresja zero)
- [x] Run `bash scripts/lib/setup-agent-collections/mcp-merge.test.sh`

**Stop Rule:** Jeśli transformacja wymaga parsowania zagnieżdżonych wyrażeń `${...:-...}` poza prostą podmianą tekstową — zatrzymać się i eskalować do człowieka (ryzyko błędnej interpretacji defaultów).

#### Task A.3 - [REUSE] `scripts/setup-agent-collections.sh` — bez zmian w sekwencji

**Description**: Potwierdzić, że istniejące wywołanie `merge_mcp_json` (linia 223) nie wymaga zmian — cała logika per-agent żyje wewnątrz `mcp-merge.sh` (Task A.1). Zadanie weryfikacyjne, nie implementacyjne.

**Files:** `scripts/setup-agent-collections.sh` (reuse)

**Definition of Done**:

- [x] `grep -n 'merge_mcp_json' scripts/setup-agent-collections.sh` nadal wskazuje dokładnie jedno wywołanie, bez nowych warunków `if`

#### Task A.4 - [CREATE] `mcp-merge.test.sh` — test jednostkowy

**Description**: Nowy test w stylu `gitignore.test.sh`: source `common.sh` + `mcp-merge.sh` bezpośrednio, uruchomić `merge_mcp_json` dla `SELECTED_AGENTS="claude"` w scratch dir i asercje na wygenerowanym `.mcp.json` (brak `${env:`, obecność `env.AGENT_COLLECTIONS_HOME`), następnie dla `SELECTED_AGENTS="cursor,claude"` — oba pliki istnieją i są poprawnym JSON.

**Files:** `scripts/lib/setup-agent-collections/mcp-merge.test.sh` (create)

**Definition of Done**:

- [x] Plik zawiera min. 3 asercje (`_pass`/`_fail` counters jak w `gitignore.test.sh`): tylko-cursor, tylko-claude, oba
- [x] Run `bash scripts/lib/setup-agent-collections/mcp-merge.test.sh` kończy się exit 0

#### Task A.5 - [MODIFY] `scripts/setup-agent-collections.test.sh` — smoke z `--agents=claude`

**Description**: Rozszerzyć istniejący smoke test o drugi (krótszy) scratch-repo run z `--non-interactive --agents=claude --mcp-servers=eversis-collections --link-mode=copy`, asercja `[[ -f "$TARGET/.mcp.json" ]]` i `node -e` sprawdzenie braku `${env:` w treści.

**Files:** `scripts/setup-agent-collections.test.sh` (modify)

**Definition of Done**:

- [x] Nowy blok asercji dla `--agents=claude` obecny i przechodzi
- [x] Run `bash scripts/setup-agent-collections.test.sh` (pełny, budżet <300s zachowany)

### Phase B: generator Claude przepisuje ścieżki `.ai/...` na realne w konsumencie

**Goal**: Zamyka F11 — najpoważniejszą przyczynę, dla której Claude Code "nie widzi" frameworka po instalacji.

**Description**: `adapters/claude/generate.mjs` dostaje parametr `--framework-prefix`, którym instalator (przez `_run_adapter_sync`) przekazuje relatywną ścieżkę od `TARGET_DIR` do katalogu zawierającego `.ai/` (pusty/`.` w self-hostowanym repo frameworka, `vendor/agent-collections` w trybie `submodule`/`copy`, wyliczona ścieżka do `AGENT_COLLECTIONS_HOME` w trybie `local`). Sekcja "How to use prompts and skills" jest budowana dynamicznie zamiast jako stały string.

**Verification:** `npm run sync:adapters:check` · `bash scripts/setup-agent-collections.test.sh`

#### Task B.1 - [MODIFY] `adapters/claude/generate.mjs` — dynamiczna sekcja How-to

**Description**: Zastąpić stały `HOW_TO_SECTION` funkcją `buildHowToSection(frameworkPrefix)`, która podmienia każde wystąpienie `.ai/prompts/public/`, `.ai/prompts/internal/`, `.ai/skills/<id>/SKILL.md` na wariant z prefiksem (np. `vendor/agent-collections/.ai/prompts/public/`) gdy `frameworkPrefix` jest niepuste; dodać nowy CLI arg `--framework-prefix <path>` w `parseArgs()` (domyślnie `""`), walidowany przez `assertSafeRepoRelative()` (istniejąca funkcja, linia ~159).

**Files:** `adapters/claude/generate.mjs` (modify)

**Definition of Done**:

- [x] `node adapters/claude/generate.mjs` bez `--framework-prefix` produkuje identyczny `CLAUDE.md` jak dziś (self-host, brak regresji)
- [x] `node adapters/claude/generate.mjs --framework-prefix vendor/agent-collections --out <tmp>` produkuje sekcję How-to z prefiksowanymi ścieżkami
- [x] Run `npm run sync:adapters:check`

**Clues**: `assertSafeRepoRelative` już istnieje w tym pliku (linia 159) — reużyć, nie duplikować walidacji path traversal.

#### Task B.2 - [MODIFY] `adapters/sync.mjs` — przekazanie `--framework-prefix`

**Description**: Dodać opcjonalny CLI arg `--framework-prefix <path>` do `sync.mjs`, przekazywany do `runGenerator(CLAUDE_GENERATE, ...)` w `runWrite()` i (dla spójności self-check) w `runCheck()` przy generowaniu do tmp dir. Domyślnie puste (self-host).

**Files:** `adapters/sync.mjs` (modify)

**Definition of Done**:

- [x] `node adapters/sync.mjs` (bez flagi) zachowuje dzisiejsze zachowanie 1:1
- [x] `node adapters/sync.mjs --check` nadal zielony w tym repo
- [x] Run `npm run sync:adapters:check`

#### Task B.3 - [MODIFY] `link-framework.sh` — `_run_adapter_sync()` liczy prefiks

**Description**: W `_run_adapter_sync()` (linie 62-73) wyliczyć relatywną ścieżkę od `TARGET_DIR` do `COLLECTIONS_HOME` przez istniejący `node "${LIB_DIR}/relative-path.mjs"` (już używany w `_make_symlink`) i przekazać jako `--framework-prefix` do wywołania `adapters/sync.mjs`; gdy `COLLECTIONS_HOME == TARGET_DIR` (self-host) — pominąć flagę.

**Files:** `scripts/lib/setup-agent-collections/link-framework.sh` (modify)

**Definition of Done**:

- [x] `_run_adapter_sync()` przekazuje `--framework-prefix` tylko gdy `COLLECTIONS_HOME != TARGET_DIR`
- [x] Run `bash scripts/setup-agent-collections.test.sh`

#### Task B.4 - [MODIFY] `scripts/setup-agent-collections.test.sh` — asercja ścieżek wygenerowanych

**Description**: W scratch-repo run z `--vendor=copy --agents=claude`, dodać asercję że wygenerowany `CLAUDE.md` zawiera `vendor/agent-collections/.ai/prompts/public/` (nie gołe `.ai/prompts/public/` bez prefiksu).

**Files:** `scripts/setup-agent-collections.test.sh` (modify — ten sam plik co Task A.5, back-reference)

**Definition of Done**:

- [x] `grep -qF 'vendor/agent-collections/.ai/prompts/public/' "$TARGET/CLAUDE.md"` w teście
- [x] Run `bash scripts/setup-agent-collections.test.sh`

### Phase C: `.claude/commands/` — slash commands z promptów (port DHI-598)

**Goal**: Zamyka F1 — parytet 1:1 z Cursorem dla wywołania `/eversis-implement` w Claude Code.

**Description**: Port generatora komend z `adapters/cursor/generate.mjs:317-484` na `.claude/commands/`, reużywając kształt z research §5.3 (frontmatter `description` + `argument-hint`, treść = wskaźnik do SSOT rozwiązywany przez `--framework-prefix` z Fazy B). Rozszerzenie `sync.mjs --check` o drift + orphan-detekcję analogiczną do bloku `.cursor/commands/` (linie 334-377).

**Verification:** `npm run sync:adapters:check` · `bash scripts/setup-agent-collections.test.sh`

#### Task C.1 - [CREATE] `adapters/claude/command-deny.yaml`

**Description**: Kopia kształtu `adapters/cursor/command-deny.yaml` (`version: 1`, `deny: []`).

**Files:** `adapters/claude/command-deny.yaml` (create)

**Definition of Done**:

- [x] Plik parsowalny tym samym minimalnym parserem YAML co `command-deny.yaml` Cursora (`version: 1`, `deny: []`)

#### Task C.2 - [CREATE] Generator komend Claude

**Description**: Nowy moduł (`adapters/claude/generate-commands.mjs`, importowany z `adapters/claude/generate.mjs` albo wywoływany osobno z `sync.mjs`) portujący `discoverPromptCommands()`, `extractPromptMeta()`, `extractExecutableSection()`, `buildCommandContent()`, `writeCommand()`, `cleanupOrphanCommands()` z `adapters/cursor/generate.mjs`. Różnice wobec Cursora: katalog docelowy `.claude/commands/`, frontmatter `description` + `argument-hint: [JIRA_ID lub opis zadania]` (bez `description-mdc`/`globs`), treść wskaźnika rozwiązuje ścieżkę SSOT przez `frameworkPrefix` (Faza B), marker GENERATED **na końcu pliku** (ta sama poprawka UX co DHI-598 dla Cursora — zapobiega wyciekowi markera do opisu w menu `/`).

**Files:** `adapters/claude/generate-commands.mjs` (create), `adapters/claude/command-deny.yaml` (reuse — Task C.1)

**Definition of Done**:

- [x] Dla każdego `.ai/prompts/{public,internal}/eversis-*.md` niepomijanego przez deny-listę powstaje `.claude/commands/<id>.md`
- [x] Marker GENERATED jest ostatnią linią pliku (nie pierwszą)
- [x] Run `npm run sync:adapters:check`

**Stop Rule:** Jeśli duplikat `id` wystąpi między `public`/`internal` (tak jak w istniejącym Cursor-side guard) — fail loud, tak jak `adapters/cursor/generate.mjs`, nie ciche pominięcie.

#### Task C.3 - [MODIFY] `adapters/sync.mjs` — wywołanie generatora + drift/orphan `.claude/commands/`

**Description**: W `runWrite()` wywołać nowy generator komend Claude gdy `claude` ∈ selected. W `runCheck()` dodać blok analogiczny do linii 334-377 (cursor commands): porównanie oczekiwanych vs aktualnych `.claude/commands/eversis-*.md` przez `compareFiles()`, plus orphan-detekcja bramkowana obecnością `GENERATED by adapters/claude/generate-commands.mjs` w treści pliku na dysku.

**Files:** `adapters/sync.mjs` (modify)

**Definition of Done**:

- [x] `runCheck()` zgłasza drift, jeśli ręcznie zmodyfikuje się wygenerowany plik `.claude/commands/eversis-implement.md` w katalogu porównania
- [x] `runCheck()` zgłasza orphan, jeśli osierocony wygenerowany plik zostanie na dysku po zmianie deny-listy
- [x] Run `npm run sync:adapters:check`

#### Task C.4 - [MODIFY] `docs/architecture/adapter-mapping.md` §5.1, §2

**Description**: Zaktualizować zdanie "Native Claude command files are **deferred**" (linia 194) na opis rzeczywistego emitu (`.claude/commands/*.md`, treść = wskaźnik do SSOT); zaktualizować wiersz Claude Code w macierzy emit (§2) z "Commands: instructional… deferred" na "Commands: `.claude/commands/*.md` (shipped)".

**Files:** `docs/architecture/adapter-mapping.md` (modify)

**Definition of Done**:

- [x] `grep -q 'deferred' docs/architecture/adapter-mapping.md` już nie dotyczy komend Claude (weryfikacja ręczna diffu — brak automatycznej negacji, opisowa)
- [x] `docs/architecture/adapter-mapping.md` zawiera frazę `.claude/commands/` w opisie emitu Claude Code

### Phase D: `.claude/skills/` — natywne odkrywanie 45 skilli

**Goal**: Zamyka F2 — model Claude Code odkrywa i ładuje skille bez MCP, zachowując `user-invocable: false` tam gdzie skill nie powinien pojawić się w menu `/`.

**Description**: Reużycie `EFFECTIVE_LINK_MODE`/`_make_symlink()` z `link-framework.sh` (Q2=b) — pierwszy realny konsument tej ścieżki kodu.

**Verification:** `bash scripts/setup-agent-collections.test.sh`

#### Task D.1 - [MODIFY] `link-framework.sh` — pętla linkowania skilli

**Description**: W `link_framework_files()`, po istniejących krokach, dodać: gdy `echo ",${SELECTED_AGENTS:-}," | grep -q ',claude,'`, iterować katalogi `${COLLECTIONS_HOME}/.ai/skills/eversis-*/`, dla każdego wywołać `_make_symlink "$src" "${TARGET_DIR}/.claude/skills/$(basename "$src")"` gdy `EFFECTIVE_LINK_MODE == symlink`, inaczej `cp -R "$src" "${TARGET_DIR}/.claude/skills/$(basename "$src")"` (po `rm -rf` celu, idempotentnie).

**Files:** `scripts/lib/setup-agent-collections/link-framework.sh` (modify)

**Definition of Done**:

- [x] Po instalacji z `--agents=claude --link-mode=symlink`, `.claude/skills/eversis-orchestrating-implementation/SKILL.md` istnieje i jest symlinkiem (lub kopią o identycznej treści dla `copy`/Windows) wskazującym na `.ai/skills/eversis-orchestrating-implementation/SKILL.md`
- [x] `grep -q 'user-invocable: false' .claude/skills/eversis-orchestrating-implementation/SKILL.md` (treść nienaruszona)
- [x] Run `bash scripts/setup-agent-collections.test.sh`

**Clues**: `_make_symlink` już obsługuje Windows junction i relative-path fallback — nie pisać nowej implementacji linkowania.

#### Task D.2 - [MODIFY] `_prune_deselected_agents()` — sprzątanie `.claude/skills/`

**Description**: Rozszerzyć istniejącą funkcję (linie 43-60) o usuwanie `${TARGET_DIR}/.claude/skills/eversis-*` gdy `claude` nie jest w `SELECTED_AGENTS` — katalog jest w całości własnością frameworka (zawsze generowany/linkowany), więc bezpieczne pełne usunięcie bez markera per-plik (w przeciwieństwie do `CLAUDE.md`/`.claudeignore`, które mogą zawierać ręczne fragmenty).

**Files:** `scripts/lib/setup-agent-collections/link-framework.sh` (modify — ten sam plik, back-reference do Task D.1)

**Definition of Done**:

- [x] Ponowna instalacja z `--agents=cursor` (bez `claude`) po wcześniejszej instalacji z `claude` usuwa `.claude/skills/`
- [x] Run `bash scripts/setup-agent-collections.test.sh`

#### Task D.3 - [MODIFY] `scripts/setup-agent-collections.test.sh` — asercja treści skilla

**Description**: Dodać do scratch-repo run z `--agents=claude` asercję `cmp` (lub `diff -q`) między `.ai/skills/eversis-agent-core/SKILL.md` (źródło) a `.claude/skills/eversis-agent-core/SKILL.md` (wynik) — zero rozbieżności treści.

**Files:** `scripts/setup-agent-collections.test.sh` (modify — back-reference do Task A.5/B.4)

**Definition of Done**:

- [x] `cmp -s` (exit 0) między źródłem a wynikiem w teście
- [x] Run `bash scripts/setup-agent-collections.test.sh`

#### Task D.4 - [REUSE] weryfikacja menu `/` (dokumentacyjna)

**Description**: Udokumentować w `adapters/claude/README.md` (sekcja istniejąca lub nowa) oczekiwanie z research §5.6: `eversis-orchestrating-implementation` **nie** pojawia się w menu `/` (bo `user-invocable: false`), ale model go ładuje — deterministyczne przez `grep` na frontmatterze, nie przez ręczne testowanie UI w tym planie.

**Files:** `adapters/claude/README.md` (modify)

**Definition of Done**:

- [x] `adapters/claude/README.md` zawiera zdanie o `user-invocable: false` i menu `/` dla `.claude/skills/`

### Phase E: `.claude/settings.json` + korekta `.claudeignore`/isolation-strategy

**Goal**: Zamyka F5 (`.claudeignore` no-op) i F8 (brak `.claude/settings.json`) — realny mechanizm egzekwowany przez Claude Code zamiast dokumentacyjnej fikcji.

**Description**: `permissions.deny` generowany z klas `.claudeignore` (Q4=c — jedno źródło prawdy klas, bez łamania DHI-529), `enabledMcpjsonServers` z listy serwerów wybranych w Fazie A. Merge znacznikowy dla obu (Q8=b), reszta pliku seed-once (Q8=a). Korekta dokumentacji architektury, żeby nie opisywała nieprawdziwego mechanizmu.

**Verification:** `bash scripts/setup-agent-collections.test.sh` · `bash scripts/lib/setup-agent-collections/claude-settings-merge.test.sh`

#### Task E.1 - [CREATE] `templates/claude-settings.json`

**Description**: Szablon seed z pustym/przykładowym `enabledMcpjsonServers` i `permissions.deny`/`allow` w kształcie z research §5.2 (bloki `Read(./.cursor/**)`, `Read(./**/node_modules/**)`, `Read(./.env)`, `Read(./.env.*)`, `Read(./**/*.pem)`, `Read(./**/*.key)`, `Read(./**/*.secret)`; `allow`: `Bash(git status)`, `Bash(git diff *)`, `Bash(git log *)`).

**Files:** `templates/claude-settings.json` (create)

**Definition of Done**:

- [x] `node -e "JSON.parse(require('fs').readFileSync('templates/claude-settings.json'))"` parsuje bez błędu
- [x] Zawiera klucze `enabledMcpjsonServers`, `permissions.deny`, `permissions.allow`

#### Task E.2 - [CREATE] `claude-settings-merge.sh` (+ helper `.mjs`)

**Description**: Nowa funkcja `merge_claude_settings()` wołana tylko gdy `claude` ∈ `SELECTED_AGENTS`: (1) jeśli `${TARGET_DIR}/.claude/settings.json` nie istnieje — kopiuje `templates/claude-settings.json` (seed-once); (2) jeśli istnieje — merguje **wyłącznie** klucze `permissions.deny` i `enabledMcpjsonServers` przez mały Node helper (analog `_append_claude_area_guidance`, ale operujący na JSON, nie tekście: wczytaj, zastąp te dwa klucze wygenerowaną zawartością, zapisz z zachowaniem reszty). `permissions.deny` generowany z klas w `.claudeignore` (parsowanie linii spoza komentarzy, mapowanie ścieżki na `Read(./<path>)`).

**Files:** `scripts/lib/setup-agent-collections/claude-settings-merge.sh` (create), `scripts/lib/setup-agent-collections/claude-settings-merge.mjs` (create)

**Definition of Done**:

- [x] Pierwsza instalacja (`.claude/settings.json` nieobecny) tworzy plik z Task E.1
- [x] Druga instalacja z ręcznie dodanym własnym kluczem (np. `"model": "..."`.) w `.claude/settings.json` zachowuje ten klucz po merge, a `permissions.deny`/`enabledMcpjsonServers` są odświeżone
- [x] Run `bash scripts/lib/setup-agent-collections/claude-settings-merge.test.sh` (Task E.5)

**Stop Rule:** Jeśli merge JSON napotka nie-obiektowy `permissions` (np. string) w istniejącym pliku — zatrzymać się i zgłosić błąd użytkownikowi, nie nadpisywać milcząco.

#### Task E.3 - [MODIFY] `scripts/setup-agent-collections.sh` — wpięcie kroku

**Description**: Dodać wywołanie `merge_claude_settings` w sekwencji, po `merge_ignore_triad` (linia ~227) a przed `scaffold_project` (linia ~230), z tym samym wzorcem `record_ok`/`record_fail` co sąsiednie kroki.

**Files:** `scripts/setup-agent-collections.sh` (modify)

**Definition of Done**:

- [x] Nowy krok widoczny w `print_summary` jako `claude-settings` (ok/fail)
- [x] Run `bash scripts/setup-agent-collections.test.sh`

#### Task E.4 - [MODIFY] `docs/architecture/isolation-strategy.md`

**Description**: Poprawić linię 109 (usunąć fałszywe założenie "path isolation leans on `.claudeignore`") i §8.1 (dodać adnotację, że dla Claude Code realnym mechanizmem jest `permissions.deny` w `.claude/settings.json`, a `.claudeignore` pozostaje wyłącznie źródłem klas ścieżek, nie działającym filtrem).

**Files:** `docs/architecture/isolation-strategy.md` (modify)

**Definition of Done**:

- [x] Linia dawniej pod nr 109 nie zawiera już twierdzenia, że `.claudeignore` realizuje izolację dla Claude Code
- [x] §8.1 zawiera odniesienie do `permissions.deny` jako mechanizmu egzekwowanego

#### Task E.5 - [CREATE] `claude-settings-merge.test.sh`

**Description**: Test jednostkowy w stylu `gitignore.test.sh` dla `merge_claude_settings()` — trzy przypadki z Task E.2 DoD.

**Files:** `scripts/lib/setup-agent-collections/claude-settings-merge.test.sh` (create)

**Definition of Done**:

- [x] Min. 3 asercje (seed-once, merge z zachowaniem obcych kluczy, poprawny JSON po merge)
- [x] Run `bash scripts/lib/setup-agent-collections/claude-settings-merge.test.sh` exit 0

### Phase F: `.claude/rules/` z `paths:` dla reguł globowanych + porządek `CLAUDE.md`

**Goal**: Zamyka F6 — `eversis-accessibility` (jedyna dziś reguła z `globs` po stronie Cursora) ładuje się tylko dla plików frontendowych, nie w każdej sesji Claude Code.

**Description**: Reguły bez `globs` w Cursor rule-map zostają w `CLAUDE.md` jako H2 (bez zmian); reguła(y) z `globs` przenoszą się do `.claude/rules/<id>.md` z frontmatterem `paths:` przeniesionym 1:1 z kolumny `globs` mapy Cursora. **Nie** deklarujemy pełnej kompresji `CLAUDE.md` poniżej 200 linii jako acceptance criterion tej fazy — po usunięciu `eversis-accessibility` (~14 linii z 349) plik nadal będzie znacznie powyżej rekomendacji; dalsza kompresja jest poza zakresem (patrz Improvements).

**Verification:** `npm run sync:adapters:check`

#### Task F.1 - [MODIFY] `adapters/claude/rule-map.yaml` + `adapters/claude/generate.mjs` — emit `.claude/rules/`

**Description**: Dodać w `adapters/claude/generate.mjs` drugą pętlę emitu: dla reguł, których `id` ma odpowiednik z niepustym `globs:` w `adapters/cursor/rule-map.yaml` (dziś: `eversis-accessibility`), zamiast dopisywać H2 do `CLAUDE.md`, zapisać `.claude/rules/<id>.md` z frontmatterem `paths: [<globs z Cursora, przepisane 1:1>]` i pełnym ciałem reguły (ta sama treść źródłowa `.ai/rules/frontend/accessibility.md` — bez zmian merytorycznych, tylko inny kontener).

**Files:** `adapters/claude/generate.mjs` (modify), `adapters/claude/rule-map.yaml` (reuse — czytane, nieedytowane; źródło `globs` czytane z `adapters/cursor/rule-map.yaml`)

**Definition of Done**:

- [x] `.claude/rules/eversis-accessibility.md` istnieje po `node adapters/claude/generate.mjs`, z frontmatterem `paths:` identycznym (po transformacji `globs:` → `paths:`) jak `globs:` w `adapters/cursor/rule-map.yaml` dla `eversis-accessibility`
- [x] `CLAUDE.md` nie zawiera już sekcji `## eversis-accessibility`
- [x] Treść reguły w `.claude/rules/eversis-accessibility.md` jest bit-identyczna z `.ai/rules/frontend/accessibility.md` (brak silent truncation — hard limit frameworka)
- [x] Run `npm run sync:adapters:check`

**Clues**: Nie kopiować treści ręcznie — czytać to samo źródło (`rule.source` z mapy), tak jak dziś robi to pętla H2.

#### Task F.2 - [MODIFY] `adapters/sync.mjs` — drift/orphan `.claude/rules/`

**Description**: Rozszerzyć `runCheck()` o blok analogiczny do `.cursor/commands/`/`.claude/commands/` (Task C.3): drift przez `compareFiles()` dla oczekiwanych `.claude/rules/*.md`, orphan-detekcja bramkowana markerem GENERATED w treści na dysku.

**Files:** `adapters/sync.mjs` (modify — ten sam plik co Task B.2/C.3)

**Definition of Done**:

- [x] `runCheck()` wykrywa drift przy ręcznej edycji `.claude/rules/eversis-accessibility.md`
- [x] Run `npm run sync:adapters:check`

#### Task F.3 - [REUSE] pomiar `CLAUDE.md` po zmianie

**Description**: Zadanie weryfikacyjne (bez zmian kodu) — potwierdzić liczbę linii po Fazie F i udokumentować wynik w Changelogu tego planu, bez fałszywego twierdzenia o osiągnięciu progu <200.

**Files:** `CLAUDE.md` (reuse)

**Definition of Done**:

- [x] `wc -l < CLAUDE.md` zwraca wartość mniejszą niż 349 (spadek potwierdzony) — wynik zanotowany w Changelogu, **nie** wymagane <200

#### Task F.4 - [MODIFY] `adapters/claude/README.md` — tabela "Generated rule ids"

**Description**: Dodać kolumnę/adnotację wskazującą, że `eversis-accessibility` jest emitowana jako `.claude/rules/eversis-accessibility.md` (z `paths:`), nie jako sekcja H2 w `CLAUDE.md`.

**Files:** `adapters/claude/README.md` (modify)

**Definition of Done**:

- [x] Tabela "Generated rule ids" zawiera adnotację o `.claude/rules/` dla `eversis-accessibility`

#### Task F.5 - [REUSE] Aktualizacja mapy Cursor→Claude w research (informacyjne, poza kodem)

**Description**: Brak zmian plikowych — potwierdzić w Changelogu planu, że wiersz "`.mdc` z `globs:` → `.claude/rules/*.md` z `paths:` (faza F)" z research §5.7 jest teraz zaimplementowany, nie tylko planowany.

**Files:** — (reuse, dokumentacyjne potwierdzenie w Changelogu planu)

**Definition of Done**:

- [x] Wpis w Changelogu tego planu potwierdzający zamknięcie wiersza §5.7 dla `globs:`/`paths:`

### Phase G: kontrakt AGENTS.md ↔ `.claude/CLAUDE.md`

**Goal**: Zamyka F7 — pętla, w której `adapters/claude/README.md` każe pisać do AGENTS.md, którego Claude Code nie czyta, a wygenerowany `CLAUDE.md` jest nadpisywany co sync.

**Description**: `.claude/CLAUDE.md` staje się udokumentowaną, seedowaną raz (nigdy generowaną/nadpisywaną) powierzchnią własną konsumenta — analog `eversis-project-stack.mdc` z kanału Cursor. Aktualizacja dokumentacji architektury, żeby opisywała rzeczywisty stan po fazach C, D, F (trzy pozycje przestały być "deferred").

**Verification:** deterministyczne `grep`/inspekcja treści (brak runnable command dla zmian czysto dokumentacyjnych, zgodnie z zasadą DoD dla zadań doc/config)

#### Task G.1 - [CREATE] `templates/claude-CLAUDE.template.md`

**Description**: Minimalna treść seed: nagłówek na stack projektu, wskaźnik `@AGENTS.md` (komentarz warunkowy — instalator dopisze go tylko gdy `AGENTS.md` istnieje, patrz Task G.2), sekcja na komendy jakości, jedno zdanie wyjaśniające że ten plik **nie** jest generowany i można go swobodnie edytować.

**Files:** `templates/claude-CLAUDE.template.md` (create)

**Definition of Done**:

- [x] Plik zawiera nagłówek `# Project` (lub analog) i sekcję `## Quality commands`
- [x] Plik **nie** zawiera markera GENERATED (odróżnienie od plików frameworka)

#### Task G.2 - [MODIFY] `scaffolding.sh` — seed `.claude/CLAUDE.md`

**Description**: W `scaffold_project()`, gdy `echo ",${SELECTED_AGENTS:-}," | grep -q ',claude,'` i `${TARGET_DIR}/.claude/CLAUDE.md` nie istnieje: skopiować `templates/claude-CLAUDE.template.md`, dopisując linię `@AGENTS.md` na początku treści tylko jeśli `${TARGET_DIR}/AGENTS.md` istnieje (ten sam copy-if-absent idiom co dla `AGENTS.md` w tej samej funkcji).

**Files:** `scripts/lib/setup-agent-collections/scaffolding.sh` (modify)

**Definition of Done**:

- [x] Świeża instalacja z `--agents=claude` tworzy `.claude/CLAUDE.md` gdy nie istniał
- [x] Ponowna instalacja (`--upgrade`) **nie** nadpisuje ręcznie zmienionego `.claude/CLAUDE.md`
- [x] Run `bash scripts/setup-agent-collections.test.sh`

#### Task G.3 - [MODIFY] `adapters/claude/README.md` — korekta kontraktu

**Description**: Zamienić akapit "Put consumer stack, area map, and skills policy in **AGENTS.md**" (linia 56) na opis dwupowierzchniowy: AGENTS.md = wspólna orientacja (wszystkie narzędzia, wymaga `@AGENTS.md` importu żeby Claude Code go widział), `.claude/CLAUDE.md` = powierzchnia własna konsumenta dla Claude Code (nigdy nadpisywana przez adapter, seedowana raz).

**Files:** `adapters/claude/README.md` (modify)

**Definition of Done**:

- [x] `adapters/claude/README.md` zawiera frazę `.claude/CLAUDE.md` w kontekście "consumer-owned" / "never overwritten"
- [x] Usunięte mylące zdanie sugerujące AGENTS.md jako jedyne miejsce na stack projektu dla Claude Code

#### Task G.4 - [MODIFY] `adapters/claude/README.md` — tabela "Exceptions (not generated)"

**Description**: Zaktualizować wiersze `.claude/rules/`, native Claude skills/commands — po fazach C/D/F te trzy pozycje **nie** są już "deferred"; dodać nowy wiersz `.claude/CLAUDE.md` → "Seeded once (scaffolding), never generated/overwritten".

**Files:** `adapters/claude/README.md` (modify — ten sam plik co Task G.3, back-reference)

**Definition of Done**:

- [x] Tabela "Exceptions" nie zawiera już `.claude/rules/`, native skills, native commands jako "Deferred"
- [x] Nowy wiersz `.claude/CLAUDE.md` obecny w tabeli

#### Task G.5 - [MODIFY] `docs/architecture/adapter-mapping.md` §5, §7

**Description**: Dopisać `.claude/CLAUDE.md` do mapy pól §5 (jako "consumer-owned surface, seeded not generated") i zaktualizować legendę maturity (§7) jeśli status Claude Code MVP się zmienił po fazach A-G (np. z `shipped (narrow)` na `shipped`).

**Files:** `docs/architecture/adapter-mapping.md` (modify — ten sam plik co Task C.4, back-reference)

**Definition of Done**:

- [x] §5 zawiera wzmiankę o `.claude/CLAUDE.md`
- [x] Diff §7 odzwierciedla realny stan po fazach A-G (opisowe, bez automatycznej asercji)

### Phase H: Code Review

**Goal**: Finalna weryfikacja jakości całej zmiany przed Fine — obowiązkowa faza kończąca każdy plan w tym frameworku.

**Description**: Finalne uruchomienie **Code Reviewer** przez `eversis-review.md` na pełnej zmianie faz A-G. Nie uruchamiać testów E2E poza tą fazą.

**Verification:** `npm run sync:adapters:check` · `bash scripts/setup-agent-collections.test.sh` · `bash scripts/lib/setup-agent-collections/{gitignore,mcp-merge,claude-settings-merge}.test.sh` · `npm run mcp:test` (regresja — brak zmian oczekiwanych)

#### Task H.1 - [REUSE] Code review przez Code Reviewer

**Description**: Uruchomić **Code Reviewer** via `eversis-review.md` na pełnym diffie faz A-G. Zakres: zgodność ze standardem, brak nowych zależności npm, brak edycji poza planowanym zakresem, brak silent truncation treści reguł (Task F.1 DoD), brak zerwania self-hosted `npm run sync:adapters:check`.

**Files:** wszystkie pliki zmodyfikowane/utworzone w Fazach A-G (reuse)

**Definition of Done**:

- [x] Run `npm run sync:adapters:check` — zielone
- [x] Code review passes bez blockerów
- [x] Wynik review udokumentowany w Changelogu tego planu

### Phase I: F12 — poprawka "Next steps" instalatora (DELTA po Fine)

**Goal**: Konsument czytający output instalatora widzi poprawną instrukcję dla Claude Code (`.claude/CLAUDE.md`, nie `AGENTS.md`) i aktualny opis pruningu przy deselekcji.

**Description**: `scripts/lib/setup-agent-collections/summary.sh` nie był w zakresie żadnej z faz A-H (nie figuruje w "To Be Modified" żadnej) i pozostał z przedsesyjnym, błędnym tekstem — wykryte dopiero przy realnej instalacji `--vendor submodule` u konsumenta (F12 w research, DELTA 2026-08-13). Dwie niezależne, mechaniczne poprawki w tym samym pliku: (1) linia "Customise AGENTS.md" dla gałęzi Claude → `.claude/CLAUDE.md`, z AGENTS.md przeniesionym do osobnego, zawsze drukowanego przypomnienia (dziś drukowane tylko gdy Claude **nie** jest wybrany — błąd, bo AGENTS.md jest współdzielone, nie Cursor-specific); (2) akapit "Deselection" nie wspomina pruningu `.claude/commands/` / `.claude/rules/` / `.claude/skills/` dodanego w Fazach C/D/H.

**Verification:** `npm run sync:adapters:check` · `bash scripts/setup-agent-collections.test.sh`

#### Task I.1 - [MODIFY] `summary.sh` — poprawka linii "Customise" dla Claude + odblokowanie przypomnienia o AGENTS.md

**Description**: W gałęzi `claude ∈ SELECTED_AGENTS` (`summary.sh:44-47`) zamienić `"Customise AGENTS.md (stack / areas / skills policy — Claude + shared map)"` na `"Customise .claude/CLAUDE.md (Claude stack / skills policy)"` (ten sam wzorzec zdania co linia Cursora tuż nad nią), zachowując ostrzeżenie "Do not hand-edit generated CLAUDE.md". Usunąć warunek `if ! echo ",${agents_csv}," | grep -q ',claude,'` wokół linii "Review AGENTS.md" (`summary.sh:69-72`) — drukować ją **zawsze** (AGENTS.md jest współdzielone między Cursor i Claude, nie Cursor-specific ani warunkowe na braku Claude), z komentarzem doprecyzowującym rolę pliku.

**Files:** `scripts/lib/setup-agent-collections/summary.sh` (modify)

**Definition of Done**:

- [x] `grep -qF 'Customise AGENTS.md' scripts/lib/setup-agent-collections/summary.sh` **nie** znajduje dopasowania
- [x] `grep -qF 'Customise .claude/CLAUDE.md' scripts/lib/setup-agent-collections/summary.sh` znajduje dopasowanie
- [x] Świeża instalacja `--agents=claude` (scratch dir) drukuje linię `.claude/CLAUDE.md` **i** osobną linię przypominającą o `AGENTS.md`
- [x] Świeża instalacja `--agents=cursor` (bez Claude) nadal drukuje przypomnienie o `AGENTS.md` (regresja zero względem dzisiejszego zachowania cursor-only)
- [x] Run `bash scripts/setup-agent-collections.test.sh`

#### Task I.2 - [MODIFY] `summary.sh` — aktualizacja akapitu "Deselection"

**Description**: Rozszerzyć statyczny tekst "Deselection" (`summary.sh:77-81`) o wzmiankę pruningu `.claude/commands/`, `.claude/rules/`, `.claude/skills/` — dziś wspomina tylko `CLAUDE.md` / `.claudeignore` / osierocone slash commands, mimo że Fazy C/D/H tej samej sesji rozszerzyły faktyczny zakres pruningu.

**Files:** `scripts/lib/setup-agent-collections/summary.sh` (modify — ten sam plik co Task I.1)

**Definition of Done**:

- [x] Akapit "Deselection" wymienia `.claude/commands/`, `.claude/rules/`, i `.claude/skills/` obok `CLAUDE.md` / `.claudeignore`
- [x] Run `bash scripts/setup-agent-collections.test.sh`

#### Task I.3 - [MODIFY] `setup-agent-collections.test.sh` — test regresyjny dla F12

**Description**: Dodać asercję do istniejącego bloku `--agents=claude` (ten sam `TARGET_CLAUDE` co testy Faz A-D): przechwycić stdout instalatora (już uruchamianego w teście) i sprawdzić, że output zawiera `.claude/CLAUDE.md` w sekcji Next steps, nie zawiera już `Customise AGENTS.md`, oraz że output zawiera wzmiankę `.claude/skills/` w akapicie Deselection.

**Files:** `scripts/setup-agent-collections.test.sh` (modify)

**Definition of Done**:

- [x] Nowe asercje obecne i przechodzą dla instalacji `--agents=claude`
- [x] Run `bash scripts/setup-agent-collections.test.sh` (pełny, budżet <300s zachowany)

### Phase J: Code Review (F12)

**Goal**: Finalna weryfikacja jakości poprawki F12 przed Fine.

**Description**: Lekka faza review — zmiana ograniczona do jednego pliku bash (tekst) + jednego testu. Uruchomić **Code Reviewer** przez `eversis-review.md` na diffie Fazy I.

**Verification:** `npm run sync:adapters:check` · `bash scripts/setup-agent-collections.test.sh`

#### Task J.1 - [REUSE] Code review przez Code Reviewer

**Description**: Uruchomić **Code Reviewer** via `eversis-review.md` na diffie Fazy I (`summary.sh`, `setup-agent-collections.test.sh`). Zakres: brak regresji dla `--agents=cursor` (linia AGENTS.md nadal poprawna), brak edycji poza `summary.sh`/testem, brak nowych zależności.

**Files:** `scripts/lib/setup-agent-collections/summary.sh`, `scripts/setup-agent-collections.test.sh` (reuse)

**Definition of Done**:

- [x] Run `npm run sync:adapters:check` — zielone
- [x] Code review passes bez blockerów
- [x] Wynik review udokumentowany w Changelogu tego planu

## Security Considerations

- **Path traversal przy linkowaniu skilli (Faza D)**: pętla linkowania musi budować cel wyłącznie wewnątrz `${TARGET_DIR}/.claude/skills/` z nazwy katalogu źródłowego (`basename`), nigdy z danych wejściowych użytkownika — reużyć wzorca `assertUnderRoot`-podobnego (już istnieje w `mcp/eversis-collections-mcp/src/resolveRoot.ts:41-48`, analogiczna guard-logika, nie import międzypakietowy) zamiast pisać nową implementację bez walidacji.
- **`permissions.deny` nie może regresować do zbyt wąskiej listy**: merge znacznikowy (Task E.2) musi w pełni zastępować sekcję `deny`, nie sumować z poprzednią zawartością w sposób, który mógłby przypadkiem zawęzić ją do mniej restrykcyjnej listy przy błędnym mergu — test E.5 musi pokrywać ten przypadek.
- **`.mcp.json`/`.claude/settings.json` w konsumencie mogą trafić do gita**: nie wprowadzać w nich sekretów w postaci literałów — wyłącznie referencje do zmiennych środowiskowych (`${VAR}`), zgodnie z dzisiejszym wzorcem `.cursor/mcp.json`. Zero zmian w tej zasadzie.
- **Brak nowych zależności npm** (hard limit frameworka) — wszystkie transformacje JSON/YAML w Node pozostają na stdlib, tak jak dziś.
- **Nie kasować project-owned plików bez markera** — każda nowa funkcja prune/cleanup (Task D.2) musi zachować bramkowanie po własności frameworka (katalog `.claude/skills/` jest w całości generowany, ale `.claude/CLAUDE.md`, `.claude/settings.json` poza znacznikowanymi sekcjami — nigdy).

## Quality Assurance

Zgodnie z kontraktem akceptacyjnym z research §5.6:

- [ ] `/context` w Claude Code pokazuje pod **Memory files** zarówno `CLAUDE.md`, jak i `.claude/CLAUDE.md`
- [ ] `/mcp` pokazuje `eversis-collections` jako connected po instalacji `--agents=claude`
- [ ] `/status` pokazuje `.claude/settings.json` wśród aktywnych źródeł ustawień
- [ ] `claude mcp list` nie zgłasza ostrzeżeń o nierozwiniętych zmiennych (`${env:...}`)
- [ ] Menu `/` pokazuje komendy `eversis-*` (Faza C) i skille (Faza D) z `.claude/skills/`, **bez** `eversis-orchestrating-implementation`
- [ ] `eversis_skills_list` (MCP) nadal zwraca pełny zestaw skilli — regresja zero
- [ ] Dowolny prompt `eversis-*` wywołany jako `/eversis-implement` w świeżo zainstalowanym konsumencie trafia do pliku SSOT bez pytania o ścieżkę (ręczna weryfikacja manualna — poza automatycznym DoD, bo wymaga żywej sesji Claude Code; udokumentować wynik w Fine/QA draft, nie w tym checkboksie)

## Improvements (Out of Scope)

- Kompresja `CLAUDE.md` poniżej rekomendowanych <200 linii (Faza F usuwa tylko regułę(y) z `globs`; pełne rozbicie `eversis-fine-handoff`/`eversis-spec-driven-development` na osobne pliki referencyjne to odrębna decyzja projektowa).
- Adapter OpenCode (status `placeholder`) — poza zakresem tego planu.
- Claude Code na CI, hooki, packaging pluginów — jawnie poza zakresem research.
- Monorepo area/path globs poza istniejącymi profilami (DHI-530) — obszar §4/§9 `isolation-strategy.md`, osobny plan.
- Wiring `gitignore.test.sh` i nowych testów jednostkowych lib do `package.json` jako osobne npm scripts (dziś uruchamiane bezpośrednio przez `bash <path>`, zgodnie z istniejącym wzorcem) — kosmetyczne, nie blokuje tego planu.

## Changelog

| Date       | Change Description   |
| ---------- | --------------------- |
| 2026-08-12 | Initial plan created — fazy A-H, na bazie `claude-code-setup.research.md`, decyzje Q1-Q8 przyjęte z rekomendacji research |
| 2026-08-12 | Plan review (self-run, `claude-code-setup.plan-review.md`) — **APPROVED**, 0 blockerów, 2 warningi (framework-prefix threading do C.3, mcp-merge.test.sh izolacja) — oba zaadresowane inline podczas implementacji, bez rewizji planu |
| 2026-08-12 | Fazy A-G zaimplementowane w tej samej sesji. §5.7 mapa Cursor→Claude z research (`globs:` → `.claude/rules/*.md` z `paths:`) — **zamknięte** w Fazie F (`adapters/claude/generate.mjs` czyta `globs` z `adapters/cursor/rule-map.yaml`, routuje `eversis-accessibility` do `.claude/rules/eversis-accessibility.md`, `CLAUDE.md` spadł z 349 do 334 linii — spadek potwierdzony, próg <200 świadomie nieosiągnięty, patrz Improvements) |
| 2026-08-12 | Weryfikacja: `npm run sync:adapters:check` zielony (self-host), `bash scripts/setup-agent-collections.test.sh` PASS (oba cele: `--agents=cursor` i `--agents=claude --vendor=copy`), nowe testy jednostkowe `mcp-merge.test.sh` (9/9) i `claude-settings-merge.test.sh` (8/8) zielone, `npm run mcp:test` bez regresji (10/10, nietknięty przez ten plan). Przy okazji wykryto niepowiązaną, wcześniej istniejącą usterkę w `gitignore.test.sh` (odwołuje się do nieistniejącej funkcji `_ensure_artifacts_subblock`) — poza zakresem tego planu, niezgłoszona do naprawy |
| 2026-08-12 | Faza H — code review (skill `code-review`, effort high) na pełnym diffie A-G. 3 CONFIRMED findings naprawione inline: (1) `_prune_deselected_agents` nie usuwała osieroconych `.claude/commands/*.md` / `.claude/rules/*.md` przy deselekcji Claude, bo ich cleanup żył wyłącznie jako efekt uboczny generatorów, które przy deselekcji się nie uruchamiają — dodano `_prune_marker_gated_dir` + test regresyjny w `setup-agent-collections.test.sh`; (2) `_resolve_framework_prefix` po cichu połykała błąd `relative-path.mjs` w trybie vendored, degradując do niezresolvowanych ścieżek `.ai/...` bez ostrzeżenia — dodano `log_warn`; (3) `claude-settings-merge.mjs` emitował martwy wzorzec dla linii negacji `!pattern` w `.claudeignore` zamiast pominąć — dodano guard. 1 finding (duplikacja `cleanupOrphanScopedRules`/`cleanupOrphanCommands` między dwoma self-executing CLI generatorami) świadomie pozostawiony — zgodny z istniejącym wzorcem zero-dependency/no-cross-import we frameworku (ten sam kształt duplikacji już istnieje między `adapters/cursor/generate.mjs` i portem w `adapters/claude/`). Pełna suita zielona po poprawkach. |
| 2026-08-12 | **Drugi, niezależny przebieg code review** (uruchomiony przy okazji Fazy 2 planu `claude-code-setup-website-docs` — skill `code-review` eskalował do pełnego wielo-agentowego przeglądu **całego** niezacommitowanego diffu, bo nic w tej sesji nie zostało jeszcze zacommitowane). 4 dodatkowe CONFIRMED findings naprawione: (1) **[Krytyczne, security]** `vendor.sh`'s `setup_vendor_copy()` nigdy nie kopiował triady ignore (`.claudeignore` i in.) do `vendor/agent-collections/` — pod `--vendor=copy --agents=claude` skutkowało to **pustym** `permissions.deny` w `.claude/settings.json` (zero ochrony sekretów), bo `merge-ignore-triad.mjs` czyta wzorce z `${COLLECTIONS_HOME}/.claudeignore`, a `COLLECTIONS_HOME` jest w tym trybie repointowane na wektorowany katalog. Błąd **poprzedzał** tę sesję (nie wprowadzony przez Fazę E), ale to Faza E po raz pierwszy uczyniła `.claudeignore` bezpieczeństwowo istotnym dla Claude Code (wcześniej no-op, F5) — naprawiono w `vendor.sh`, zweryfikowano end-to-end (`permissions.deny` zawiera teraz `.env`/`*.pem`/`*.key`/`*.secret` pod `--vendor=copy`). (2) `scaffolding.sh`'s `_seed_claude_project_md` pisał bare `@AGENTS.md` w `.claude/CLAUDE.md`, ale Claude Code rozwiązuje importy `@` względem katalogu pliku importującego (potwierdzone przez `WebFetch` na `code.claude.com/docs/en/memory`), więc z `.claude/` import wskazywałby na nieistniejący `.claude/AGENTS.md` — naprawiono na `@../AGENTS.md`, dodano test regresyjny. (3) `claude-settings-merge.mjs` produkował zdeformowany glob z podwójnym slashem (`.//dist/**`) dla wzorców `.claudeignore` z wiodącym `/` (styl gitignore root-anchor) — naprawiono, dodano test regresyjny. (4) `_link_claude_skills` nigdy nie usuwała `.claude/skills/eversis-*/` dla pakietów usuniętych/zmienionych nazwy w `.ai/skills/` (tylko dodawała nowe) — dodano pruning analogiczny do już istniejącego dla commands/rules. Dodatkowo: `templates/claude-settings.json` uproszczony (`enabledMcpjsonServers`/`deny` na `[]`) — oba pola są **zawsze** nadpisywane przez merge, więc konkretne wartości w szablonie były martwą, mylącą treścią. **Fałszywie pozytywny finding odrzucony:** jeden z agentów przeglądu twierdził, że `.claude/rules/*.md` z frontmatterem `paths:` to "wymyślony", nie-natywny mechanizm Claude Code — zweryfikowane bezpośrednio przeciwko `code.claude.com/docs/en/memory` (`WebFetch`): mechanizm jest w pełni udokumentowany i zaimplementowany dokładnie tak, jak w Fazie F. Kilkanaście dodatkowych findingów (duplikacja kodu, sekwencyjne zamiast równoległe `spawnSync`, nadmiarowa walidacja JSON przez drugi proces `node`) świadomie pozostawione — sugestie stylu/wydajności zgodne z istniejącym wzorcem frameworka, nie błędy. Pełna suita (bash -n, `mcp-merge.test.sh` 9/9, `claude-settings-merge.test.sh` 10/10, `sync:adapters:check`, pełny smoke instalatora, ręczna weryfikacja `--vendor=copy`) zielona po poprawkach. |
| 2026-08-13 | **Plan REFRESH — F12 (DELTA w research)**: realna instalacja `--vendor submodule --agents cursor,claude` u konsumenta (poza scratch-testami tej sesji) ujawniła, że `scripts/lib/setup-agent-collections/summary.sh` — jedyny plik z żadnej fazy A-H, którego nie dotknięto — nadal drukuje przestarzałą instrukcję "Customise AGENTS.md" dla Claude zamiast `.claude/CLAUDE.md`. Pełna weryfikacja end-to-end na tym samym realnym, złożonym monorepo (Next.js + JHipster/Angular/Spring Boot + Lit) potwierdziła: wszystko poza F12 działa poprawnie (`.mcp.json`, `.claude/CLAUDE.md` treść i import, root `CLAUDE.md` prefiks, 28/28 parytet komend, `.claude/rules/`, 45/45 symlinków skilli z parytetem treści, `.claude/settings.json` deny/enabled). Dodano Fazę I (poprawka `summary.sh` — linia Claude + odblokowanie zawsze-drukowanego przypomnienia AGENTS.md + aktualizacja akapitu Deselection) i Fazę J (Code Review) jako nowy, mniejszy przyrost do tego samego planu. |
| 2026-08-13 | Fazy I-J zaimplementowane. `summary.sh`: linia "Customise AGENTS.md" → "Customise .claude/CLAUDE.md" dla gałęzi Claude; usunięto warunek `if ! claude` wokół przypomnienia "Review AGENTS.md" (teraz zawsze drukowane — plik jest współdzielony, nie Cursor-specific); akapit "Deselection" rozszerzony o `.claude/commands/`, `.claude/rules/`, `.claude/skills/`. Test regresyjny w `setup-agent-collections.test.sh`: przechwytuje stdout instalatora (`tee` + `pipefail`, exit code instalatora zachowany), asercje na dokładny tekst. Faza J — code review self-run (bez ponownego wywołania skilla `code-review`, żeby uniknąć powtórnej eskalacji do przeglądu całego niezacommitowanego diffu z poprzedniej sesji): diff obu plików przejrzany ręcznie, zero blockerów, zero scope creep, brak nowych zależności. Pełna suita zielona: `sync:adapters:check`, pełny smoke instalatora (w tym nowe asercje F12), `mcp-merge.test.sh` 9/9, `claude-settings-merge.test.sh` 10/10, `mcp:test` 10/10. |
