# Claude Code — parytet adaptera i kontrakt setupu (research)

| Pole | Wartość |
|------|---------|
| Zadanie | Analiza wsparcia Claude Code w Agent Collections + kontrakt konfiguracji projektu konsumenckiego |
| Jira | brak (research poprzedza założenie ticketów) |
| Status | Zaimplementowane (`claude-code-setup.plan.md`, fazy A-J, Fine 2026-08-13) — F12 (DELTA 2026-08-13, znalezione po realnej instalacji `--vendor submodule` u konsumenta) zamknięte w Fazie I |
| Wersja frameworka | 0.0.1 |
| Data | 2026-08-12 (DELTA: 2026-08-13) |
| Język | polski (na życzenie maintainera); nazewnictwo pliku zgodne z Delivery Standard |

> **Zasada zakresu:** dokument opisuje wyłącznie framework. Bez nazw projektów konsumenckich (reguła open-source DHI-528). Dowody są repo-relatywne wobec katalogu `agent-collections`. Ścieżki konsumenckie występują jako `<consumer-root>` i `vendor/agent-collections/`.

---

## 1. Cel i zakres

**Pytanie:** czy Agent Collections realnie działa pod Claude Code na poziomie porównywalnym z Cursorem, a jeśli nie — co dokładnie musi dostarczyć framework, żeby projekt konsumencki dał się skonfigurować?

**W zakresie:** adapter Claude, instalator, wiring MCP, triada ignore, kontrakt ładowania promptów i skilli, kontrakt setupu konsumenta.

**Poza zakresem:** OpenCode (status `placeholder`), zmiany treści w `.ai/rules`, hooki, packaging pluginów, Claude Code na CI.

---

## 2. Stan obecny — co emituje adapter Claude

Adapter Claude (DHI-526/527) generuje **dokładnie jeden plik**: root `CLAUDE.md`, złożony z siedmiu reguł rdzenia wklejonych w całości jako sekcje H2.

| Element | Cursor | Claude Code | OpenCode |
|---------|--------|-------------|----------|
| Reguły (7 plików rdzenia) | `.cursor/rules/*.mdc` z `globs` + `alwaysApply` | wszystko inline w `CLAUDE.md` | globy `instructions` w `opencode.jsonc` |
| Slash commands (28 promptów) | **`.cursor/commands/*.md`** (DHI-598) | **brak** | brak |
| Skille (45 pakietów) | MCP `eversis_skills_*` | MCP `eversis_skills_*` | — |
| Wpis MCP | `.cursor/mcp.json` (pisany przez instalator) | **brak** | — |
| Plik ignore | `.cursorignore` | `.claudeignore` (patrz [F5](#f5--claudeignore-jest-no-opem--wysoka)) | `.opencodeignore` |
| Scoping po ścieżkach | `globs:` we froncie `.mdc` | **brak** (odroczone do DHI-530) | — |

Źródła: [`adapters/claude/rule-map.yaml`](../../../adapters/claude/rule-map.yaml), [`adapters/claude/generate.mjs`](../../../adapters/claude/generate.mjs), [`adapters/sync.mjs`](../../../adapters/sync.mjs), [`docs/architecture/adapter-mapping.md`](../../architecture/adapter-mapping.md) §5.

Świadome wyłączenia deklaruje `adapters/claude/README.md:42-51`: mirrory skilli/promptów, `.claude/rules/`, natywne skille i komendy Claude — wszystko „deferred" na mocy DHI-523 / DHI-526 Q1=A.

**Wniosek nadrzędny:** adapter jest kompletny w tym, co deklaruje, ale deklaruje bardzo wąski zakres. Cursor dostaje trzy powierzchnie (reguły + komendy + MCP), Claude Code jedną — i to tę, która w projekcie konsumenckim **nie ma działającego wskaźnika na prompty i skille**.

---

## 3. Co Claude Code potrafi natywnie (weryfikacja wobec dokumentacji)

Zweryfikowane 2026-08-12 wobec `code.claude.com/docs`:

| Mechanizm | Ścieżka | Uwagi istotne dla frameworka |
|-----------|---------|------------------------------|
| Instrukcje projektu | `./CLAUDE.md` lub `./.claude/CLAUDE.md` | ładowane w całości co sesję; **zalecane <200 linii** — dłuższe obniżają adherence |
| Import | `@ścieżka` w CLAUDE.md | maks. 4 skoki; ładowany przy starcie; import spoza katalogu roboczego wymaga zgody w dialogu |
| Reguły z path-scopingiem | `.claude/rules/*.md` z frontmatterem `paths:` | **odpowiednik `globs:` z Cursora** — istnieje dziś, nie jest odroczony |
| Slash commands | `.claude/commands/<n>.md` → `/n` | frontmatter opcjonalny; brak `description` → bierze pierwszy akapit |
| Agent Skills | `.claude/skills/<id>/SKILL.md` → `/id` | frontmatter `name`, `description`, `user-invocable`, `paths`, `allowed-tools`, `disable-model-invocation`, `context: fork`… |
| MCP projektowe | `.mcp.json` w root (klucz `mcpServers`) | ekspansja `${VAR}` i `${VAR:-default}` w `command`, `args`, `env`, `url`, `headers` |
| Zatwierdzanie MCP | `enableAllProjectMcpServers` / `enabledMcpjsonServers` w `.claude/settings.json` | w niezaufanym folderze ignorowane do czasu akceptacji dialogu trust |
| Wykluczanie plików | `permissions.deny: ["Read(./ścieżka/**)"]` | **nie ma `.claudeignore`** |
| Wykluczanie CLAUDE.md przodków | `claudeMdExcludes` (glob na ścieżki absolutne) | dla monorepo |
| Migracja z innego agenta | `/import`, `/init` | `/init` czyta `.cursor/rules/` i `.cursorrules`; `/import` przenosi AGENTS.md, MCP, komendy, subagenty, skille |

Dwa fakty przewracają założenia adaptera:

1. **Komendy i skille zostały scalone.** `.claude/commands/deploy.md` i `.claude/skills/deploy/SKILL.md` dają to samo `/deploy`. Skille dodają katalog na pliki towarzyszące, progressive disclosure i automatyczne ładowanie przez model.
2. **Format `SKILL.md` frameworka jest identyczny z natywnym.** `.ai/skills/eversis-orchestrating-implementation/SKILL.md` ma frontmatter `name` / `description` / `user-invocable: false` — dokładnie klucze, które Claude Code akceptuje. Zero konwersji.

Trzy rzeczy uznane w adapterze za „deferred" są dziś dostępne: `.claude/rules/` z `paths:`, `.claude/skills/`, oraz scalenie komend ze skillami. Odroczenie było trafne w momencie DHI-526 — dziś jest nieaktualne.

Źródła: [Memory](https://code.claude.com/docs/en/memory) · [Settings](https://code.claude.com/docs/en/settings) · [Skills](https://code.claude.com/docs/en/skills) · [MCP](https://code.claude.com/docs/en/mcp).

---

## 4. Luki i ustalenia (F1–F11)

### F1 — brak generatora slash commands dla Claude Code · **Wysoka**

Cursor: 28 plików w `.cursor/commands/` (DHI-598). Claude Code: 0. [`adapter-mapping.md`](../../architecture/adapter-mapping.md) §5.1 mówi wprost: *„Native Claude command files are **deferred**"*, a wejściem mają być „instructional lines" w `CLAUDE.md`.

Skutek: w Cursorze użytkownik pisze `/eversis-implement`. W Claude Code musi opisać zadanie prozą i liczyć, że agent sam znajdzie plik promptu — którego (F11) nie ma pod ścieżką podaną w `CLAUDE.md`.

### F2 — 45 skilli nieeksponowanych natywnie · **Wysoka**

`.ai/skills/<id>/SKILL.md` jest gotowym pakietem Agent Skills. Framework wymaga MCP albo ręcznego `Read`. Emit lub symlink do `.claude/skills/` dałby autouzupełnianie, ładowanie na żądanie i wybór przez model — bez zmian w treści skilli.

Uwaga projektowa: `user-invocable: false` w `eversis-orchestrating-implementation` zachowa się poprawnie (skill nie zaśmieci menu `/`, a model go załaduje) — zgodnie z intencją rdzenia.

### F3 — instalator nigdy nie konfiguruje MCP dla Claude Code · **Krytyczna**

[`scripts/lib/setup-agent-collections/mcp-merge.sh:7-8`](../../../scripts/lib/setup-agent-collections/mcp-merge.sh) hardkoduje cel:

```bash
local cursor_dir="${TARGET_DIR}/.cursor"
local mcp_file="${cursor_dir}/mcp.json"
```

`merge_mcp_json` jest wołane bezwarunkowo w [`setup-agent-collections.sh:223`](../../../scripts/setup-agent-collections.sh), niezależnie od `--agents`. Instalacja `--agents=claude` zapisuje konfigurację MCP wyłącznie do `.cursor/mcp.json` — pliku, którego Claude Code nie czyta. Kończy się to zerem serwerów MCP i logiem `Wrote .../.cursor/mcp.json`, który czyta się jak sukces.

Konsekwencja łańcuchowa: brak MCP → brak `eversis_skills_list` / `eversis_skills_get` → krok 3 „Skills discovery" z [`agent-core.md`](../../../.ai/rules/orchestration/agent-core.md) (wklejony do `CLAUDE.md`) jest niewykonalny, a krok 4 („otherwise read the matching `SKILL.md`") trafia na F11.

### F4 — `templates/mcp.json` używa składni, której Claude Code nie rozumie · **Wysoka**

[`templates/mcp.json`](../../../templates/mcp.json) używa `${env:AGENT_COLLECTIONS_HOME}` — to składnia zmiennych VS Code / Cursora. Claude Code obsługuje wyłącznie `${VAR}` i `${VAR:-default}`. Przy braku ekspansji Claude Code **nie failuje głośno**: loguje ostrzeżenie o brakującej zmiennej i przekazuje dosłowny tekst `${env:...}` jako argument, więc `node` dostaje nieistniejącą ścieżkę.

Dodatkowo szablon zawiera pole `inputs: []` (VS Code), w `.mcp.json` ignorowane. Szablon jest dziś de facto Cursor/VS-Code-only, choć `mcp/eversis-collections-mcp/README.md` przedstawia go jako neutralny seed dla „other MCP hosts".

### F5 — `.claudeignore` jest no-opem · **Wysoka**

DHI-529 dostarczył triadę `.cursorignore` / `.claudeignore` / `.opencodeignore` jako implementację strategii izolacji (DHI-528). **Claude Code nie obsługuje `.claudeignore`** — to od dawna otwarty feature request ([#579](https://github.com/anthropics/claude-code/issues/579), [#4160](https://github.com/anthropics/claude-code/issues/4160), [#29455](https://github.com/anthropics/claude-code/issues/29455)), a zgłoszenie [#36163](https://github.com/anthropics/claude-code/issues/36163) potwierdza, że plik nie blokuje odczytu.

Dwa miejsca w dokumentacji architektury opierają się na nieprawdziwym założeniu:

- [`isolation-strategy.md:109`](../../architecture/isolation-strategy.md) — *„Claude Code MVP is a single root `CLAUDE.md`; path isolation leans on `.claudeignore` + session guidance until richer native scoping exists."*
- `isolation-strategy.md` §8.1 — checklista klas wymaganych w `.claudeignore`, w całości bezskuteczna.

Natywne odpowiedniki: `permissions.deny` z wzorcami `Read(...)` (twarda blokada narzędzia, nie tylko filtr kontekstu) oraz `claudeMdExcludes` (pomijanie `CLAUDE.md` przodków w monorepo). Cel DHI-528 „redukcja kontekstu 30–50%" nie jest po stronie Claude realizowany, a WNF-03 nie ma dla Claude prawdziwego mechanizmu do zmierzenia.

### F6 — `CLAUDE.md` przekracza zalecany rozmiar · **Średnia**

349 linii / ~19 KB w tym repozytorium, wobec zalecanych <200 linii. Generator wkleja pełne ciała siedmiu reguł, w tym `eversis-accessibility`, która w Cursorze jest scope'owana globami `**/*.tsx`, `**/*.jsx`, `**/*.vue`, `**/*.html`, `**/*.svelte` ([`adapters/cursor/rule-map.yaml`](../../../adapters/cursor/rule-map.yaml)), a w Claude Code ładuje się w każdej sesji — również przy pracy nad infrastrukturą czy SQL-em.

`.claude/rules/` z `paths:` mapuje się 1:1 na kolumnę `globs` mapy Cursora i rozwiązuje jednocześnie F6 oraz część celu izolacji z F5.

### F7 — pętla AGENTS.md · **Średnia**

`adapters/claude/README.md:56` kieruje: *„Put consumer stack, area map, and skills policy in **`AGENTS.md`**"*. Tymczasem Claude Code **nie czyta AGENTS.md** — trzeba go zaimportować przez `@AGENTS.md` w `CLAUDE.md` albo podlinkować symlinkiem. A `CLAUDE.md` jest generowany i nadpisywany przy każdym `sync:adapters` (`generate.mjs` usuwa plik przed zapisem), więc nie ma gdzie wpisać importu.

Instalator zapowiada AGENTS.md w komunikacie scaffoldingu (`scripts/lib/setup-agent-collections/scaffolding.sh:22`), ale nie dostarcza mostka do Claude Code. Kontrakt trzeba domknąć — najprościej wskazując `.claude/CLAUDE.md` jako powierzchnię własną konsumenta (Claude Code ładuje oba pliki, a generator dotyka tylko roota).

### F8 — brak emitowanego `.claude/settings.json` · **Średnia**

Framework nie dostarcza szablonu ustawień projektowych. Brakuje `enabledMcpjsonServers` (albo `enableAllProjectMcpServers`), allowlisty uprawnień dla powtarzalnych komend jakości z [`testing-and-terminal.md`](../../../.ai/rules/orchestration/testing-and-terminal.md), oraz `permissions.deny` zastępującego `.claudeignore`. Efekt po stronie konsumenta: ręczne klikanie zgód w każdej sesji i brak zatwierdzonych serwerów MCP po instalacji.

### F9 — rozwiązywanie roota przez MCP jest kruche w układzie vendorowanym · **Średnia**

[`mcp/eversis-collections-mcp/src/resolveRoot.ts`](../../../mcp/eversis-collections-mcp/src/resolveRoot.ts) idzie w górę drzewa w poszukiwaniu `.ai/skills`, a gdy nie znajdzie — sięga po `AGENT_COLLECTIONS_HOME` i rzuca wyjątek, jeśli zmiennej nie ma.

W projekcie konsumenckim root nie zawiera `.ai/` (patrz F11), więc walk-up zawsze zawodzi i wszystko wisi na zmiennej środowiskowej. Wpis `eversis-collections` generowany przez merge nie zawsze przekazuje blok `env`, a hosty GUI (VS Code / Cursor odpalone z launchera) nie widzą eksportów z profilu shella → serwer skilli pada. Poprawka jest jednolinijkowa: przekazać `env` jawnie albo wskazać ścieżkę względną do vendorowanego katalogu.

### F10 — `sync:adapters --check` nie pokryje przyszłych artefaktów Claude · **Niska**

[`adapters/sync.mjs`](../../../adapters/sync.mjs) sprawdza drift `.cursor/rules/*.mdc`, `.cursor/commands/eversis-*.md` i `CLAUDE.md`, plus parytet `id`/`source` między mapami. Dla `.cursor/commands/` wykrywa też **sieroty** (plik na dysku z markerem GENERATED, którego świeża generacja nie wyprodukowała). Jeśli dojdą `.claude/commands/` lub `.claude/skills/`, trzeba dołożyć analogiczne porównanie i detekcję sierot — inaczej stary artefakt zostanie po zmianie nazwy promptu.

### F11 — wygenerowany `CLAUDE.md` wskazuje ścieżki nieistniejące w konsumencie · **Krytyczna**

Sekcja „How to use prompts and skills" (hardkodowana w [`adapters/claude/generate.mjs:19-27`](../../../adapters/claude/generate.mjs)) instruuje:

> *Load public prompts by stable id under `.ai/prompts/public/` … otherwise read `.ai/skills/<id>/SKILL.md`*

W **żadnym** trybie instalacji `.ai/` nie ląduje w roocie konsumenta:

| `--vendor` | Gdzie jest `.ai/` | Root konsumenta ma `.ai/`? |
|-----------|-------------------|---------------------------|
| `local` (domyślny) | poza repozytorium, pod `AGENT_COLLECTIONS_HOME` | nie |
| `submodule` | `vendor/agent-collections/.ai/` | nie |
| `copy` | `vendor/agent-collections/.ai/` (`vendor.sh:65`) | nie |

`link-framework.sh:89` potwierdza intencję: *„do NOT mirror `.cursor/skills|prompts|commands` — skills via MCP + `.ai/`"*. Cursor tego nie odczuwa, bo dostaje wygenerowane `.cursor/rules/` i `.cursor/commands/`. Claude Code dostaje instrukcję prowadzącą donikąd — a ten sam fałszywy trop powtarza się kilkanaście razy w treści reguł wklejonych do `CLAUDE.md` (każde `.ai/skills/…`, `.ai/prompts/…`).

To jest, obok F3, główny powód, dla którego Claude Code „nie widzi" frameworka po instalacji. Generator musi znać prefiks frameworka względem roota konsumenta i przepisywać te ścieżki.

---

### F12 — instalator drukuje przestarzały krok "Customise AGENTS.md" dla Claude, bez wskazania `.claude/CLAUDE.md` · **Wysoka** — DELTA 2026-08-13

**Reason (DELTA):** znalezione w realnym, zewnętrznym transkrypcie instalacji `bash setup-agent-collections.sh --vendor submodule` (`--agents cursor,claude`) u konsumenta — pierwszy raz, gdy pełny instalator uruchomiono poza scratch-testami tej sesji. `scripts/lib/setup-agent-collections/summary.sh` nie było w zakresie `claude-code-setup.plan.md` (nie figuruje w żadnej liście "To Be Modified" faz A-H) i pozostało nietknięte — potwierdzone: `git diff --stat scripts/lib/setup-agent-collections/summary.sh` puste na commit bazowy tej sesji.

`print_summary()` (`summary.sh:44-47`) drukuje dla gałęzi `claude ∈ SELECTED_AGENTS`:

```text
Customise AGENTS.md (stack / areas / skills policy — Claude + shared map)
Do not hand-edit generated CLAUDE.md; it is overwritten on adapter sync.
```

To jest dokładnie wzorzec błędu z **F7** ("pętla AGENTS.md" — Claude Code nie czyta `AGENTS.md` automatycznie), zamknięty w kodzie generującym (`scaffolding.sh` Faza G) i w dokumentacji (README/`adapter-mapping.md`/`isolation-strategy.md`), ale **przeoczony w tym jednym miejscu**: statyczny tekst "Next steps" wypisywany na końcu instalacji. Konsument czytający ten output — jedyny tekst, jaki faktycznie widzi po instalacji — trafia z powrotem na `AGENTS.md` jako rzekome miejsce customizacji Claude, mimo że `_seed_claude_project_md` (Faza G) już utworzył `.claude/CLAUDE.md` w tym samym uruchomieniu (widoczne w tym samym transkrypcie: `[agent-setup] Created .claude/CLAUDE.md — review and customise for your project.` — linia bezpośrednio nad "Next steps").

Dodatkowo (ten sam finding, niższa dotkliwość): sekcja "Deselection" na końcu podsumowania (`summary.sh:77-81`) wspomina tylko pruning `CLAUDE.md` / `.claudeignore` / osieroconych slash commands — nie wspomina, że Faza D/H tej samej sesji dodały analogiczny pruning dla `.claude/commands/`, `.claude/rules/`, i `.claude/skills/` przy deselekcji Claude. Statyczny tekst nie nadążył za rozszerzonym zakresem prune.

**Konsekwencja:** to jest dziś **jedyne** pozostałe miejsce w całym drzewie `scripts/lib/setup-agent-collections/*.sh` z aktywnym stwierdzeniem "Customise AGENTS.md" jako celu dla Claude — potwierdzone przez `grep -rn "AGENTS.md" scripts/lib/setup-agent-collections/*.sh` (poza `summary.sh:46`, jedyne inne trafienia to `scaffolding.sh`, wszystkie poprawne/kontekstowe).

**Weryfikacja end-to-end na `<consumer-root>` (2026-08-13):** przejrzano na żywo pełny wynik tej samej instalacji `--vendor submodule --agents cursor,claude --profile fullstack` u realnego konsumenta (monorepo wielomodułowe — Next.js + JHipster/Angular/Spring Boot + Lit web component). Wszystko poza F12 potwierdzone **poprawne**:

- `.mcp.json` — składnia natywna Claude (`${CLAUDE_PROJECT_DIR:-.}`, jawny `env.AGENT_COLLECTIONS_HOME`), zero `${env:...}` / `${workspaceFolder}` (F3, F4, F9 — zamknięte)
- `.claude/CLAUDE.md` — pierwsza linia `@../AGENTS.md` (poprawna ścieżka względna), plik już rozbudowany przez konsumenta (stack/quality-commands/area-map) — seed-once działa (F7 — zamknięte)
- Root `CLAUDE.md` — sekcja "How to use prompts and skills" poprawnie prefiksowana `vendor/agent-collections/.ai/...`; blok `<!-- agent-collections-area-scope -->` (niezwiązany z tym planem) nadal poprawnie doklejony na końcu — brak regresji (F11 — zamknięte)
- `.claude/commands/` — 28 plików, `argument-hint:` obecny, parytet liczebny z `.cursor/commands/` (28) (F1 — zamknięte)
- `.claude/rules/eversis-accessibility.md` — frontmatter `paths:` poprawny, marker na górze (F6 — zamknięte)
- `.claude/skills/` — 45 symlinków, wszystkie rozwiązują się do `vendor/agent-collections/.ai/skills/...`, treść bit-identyczna ze źródłem (`cmp` czysty) (F2 — zamknięte)
- `.claude/settings.json` — `permissions.deny` zawiera pełny zestaw klas sekretów/build, `enabledMcpjsonServers` zgodny z wyborem instalacyjnym (F5, F8 — zamknięte)
- `AGENTS.md` — treść współdzielonej mapy orientacyjnej (`templates/AGENTS.template.md`), **bez** błędnego stwierdzenia "customize Claude here" (ta linia była poprawiona w tej samej sesji w samym szablonie)

**Wniosek:** F12 jest jedyną realną rozbieżnością między zaimplementowanym kodem a tym, co widzi konsument — potwierdzone na pełnym, złożonym, rzeczywistym monorepo, nie tylko na scratch-testach tej sesji.

## 5. Kontrakt setupu konsumenta (docelowo emitowany)

Poniższe artefakty są dziś wynikiem ręcznej pracy w projekcie konsumenckim. **Celem planu jest, żeby emitował je instalator / adapter** — sekcja służy jako specyfikacja wyjścia dla faz A–E oraz jako runbook przejściowy.

Notacja: `<consumer-root>` = root projektu konsumenckiego; `vendor/agent-collections/` = ścieżka vendorowania (`submodule` / `copy`). W trybie `local` zamień ją na `${AGENT_COLLECTIONS_HOME}`.

### 5.1 `.mcp.json` w roocie konsumenta

Zamyka F3, F4, F9. Ścieżki względne, żeby nie zależeć od zmiennej środowiskowej niewidocznej dla hostów GUI.

```jsonc
{
  "mcpServers": {
    "eversis-collections": {
      "type": "stdio",
      "command": "node",
      "args": ["${CLAUDE_PROJECT_DIR:-.}/vendor/agent-collections/mcp/eversis-collections-mcp/dist/index.js"],
      "env": {
        "AGENT_COLLECTIONS_HOME": "${CLAUDE_PROJECT_DIR:-.}/vendor/agent-collections"
      }
    },
    "context7": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp@latest"]
    },
    "sequential-thinking": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
    },
    "playwright": {
      "type": "stdio",
      "command": "npx",
      "args": ["@playwright/mcp@latest"]
    },
    "figma":     { "type": "http", "url": "https://mcp.figma.com/mcp" },
    "atlassian": { "type": "http", "url": "https://mcp.atlassian.com/v1/mcp" }
  }
}
```

Transformacje wymagane wobec [`templates/mcp.json`](../../../templates/mcp.json):

| Szablon (Cursor / VS Code) | `.mcp.json` (Claude Code) |
|---|---|
| `${env:AGENT_COLLECTIONS_HOME}` | `${AGENT_COLLECTIONS_HOME}` lub ścieżka względna z `${CLAUDE_PROJECT_DIR:-.}` |
| `"inputs": []` | pominięte |
| brak `env` przy `eversis-collections` | jawny `env` (F9) |
| `${workspaceFolder}` | `${CLAUDE_PROJECT_DIR:-.}` |

Warunek wstępny: zbudowany serwer skilli (`maybe_build_mcp` w instalatorze, albo `npm --prefix …/mcp/eversis-collections-mcp install && … run build`).

### 5.2 `.claude/settings.json`

Zamyka F5, F8. Plik projektowy (commitowany); osobiste wyjątki idą do gitignorowanego `.claude/settings.local.json`.

```jsonc
{
  "enabledMcpjsonServers": [
    "eversis-collections", "context7", "sequential-thinking",
    "playwright", "figma", "atlassian"
  ],
  "permissions": {
    "deny": [
      "Read(./.cursor/**)",
      "Read(./**/node_modules/**)",
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./**/*.pem)",
      "Read(./**/*.key)",
      "Read(./**/*.secret)"
    ],
    "allow": ["Bash(git status)", "Bash(git diff *)", "Bash(git log *)"]
  }
}
```

Blok `deny` to klasy z §8.1 `isolation-strategy.md` przepisane na mechanizm, który faktycznie działa. Klasy build-only (`dist/`, `build/`, `.next/`, `coverage/`) są opcjonalne — Claude Code nie indeksuje repozytorium z wyprzedzeniem, więc ich wartość jest mniejsza niż w Cursorze. Area-profile'owe globy (DHI-530) wchodzą do tego samego bloku.

### 5.3 `.claude/commands/` — slash commands z promptów

Zamyka F1 i (przez akapit o vendorze) F11. Cienkie pliki-wskaźniki; treść zostaje w SSOT pod `.ai/prompts/`.

Kształt jednego wygenerowanego pliku:

```markdown
---
description: <prompt_description z frontmatteru promptu>
argument-hint: [JIRA_ID lub opis zadania]
---

Wczytaj i wykonaj prompt Agent Collections z pliku
`vendor/agent-collections/.ai/prompts/public/eversis-implement.md`.

Traktuj ten plik jako SSOT. Wszystkie ścieżki `.ai/...` w regułach i promptach
rozwiązuj względem `vendor/agent-collections/`.

ARGUMENTY: $ARGUMENTS
```

Generator: iteracja po `.ai/prompts/{public,internal}/eversis-*.md`, `description` z pola `prompt_description`, marker GENERATED na końcu pliku (poprawka UX z DHI-598: marker na początku wyciekał do opisu w menu). Deny-lista analogiczna do [`adapters/cursor/command-deny.yaml`](../../../adapters/cursor/command-deny.yaml).

### 5.4 `.claude/skills/` — skille natywnie

Zamyka F2. Format jest zgodny, więc wystarczy linkowanie katalogów `.ai/skills/eversis-*/` (symlink przy `submodule`, kopia przy `copy` / Windows — ta sama decyzja co `EFFECTIVE_LINK_MODE` w `link-framework.sh`).

Weryfikacja: `eversis-orchestrating-implementation` **nie powinien** pojawić się w menu `/` (`user-invocable: false`), ale model musi móc go załadować.

### 5.5 `.claude/CLAUDE.md` — powierzchnia własna konsumenta

Zamyka F7. Claude Code ładuje `./CLAUDE.md` **i** `./.claude/CLAUDE.md`; generator dotyka tylko roota, więc `.claude/CLAUDE.md` jest bezpiecznym miejscem na treść projektową — odpowiednik `eversis-project-stack.mdc` z kanału Cursor.

Minimalna zawartość seedowana przez instalator: rozwiązywanie ścieżek frameworka (`vendor/…`), wskaźnik `@AGENTS.md` gdy plik istnieje, oraz nagłówek na stack i komendy jakości.

### 5.6 Weryfikacja (kontrakt akceptacyjny)

| Sprawdzenie | Oczekiwane |
|---|---|
| `/context` | pod **Memory files** widać `CLAUDE.md` i `.claude/CLAUDE.md` |
| `/mcp` | `eversis-collections` = connected; hosty HTTP connected po OAuth |
| `/status` | aktywne źródła ustawień zawierają `.claude/settings.json` |
| `claude mcp list` | brak ostrzeżeń o nierozwiniętych zmiennych |
| menu `/` | komendy `eversis-*` z 5.3; skille z 5.4; **bez** `eversis-orchestrating-implementation` |
| `eversis_skills_list` | zwraca pełny zestaw skilli |
| dowolny prompt `eversis-*` | agent trafia do pliku SSOT bez pytania o ścieżkę |

**Uwaga migracyjna:** w projekcie z wygenerowanym `CLAUDE.md` **nie uruchamiać `/init`** — nadpisuje plik zarządzany przez adapter. `/import` jest bezpieczniejszą ścieżką dla przenoszenia konfiguracji z innego agenta.

### 5.7 Mapa Cursor → Claude Code (do dokumentacji)

| Cursor | Claude Code |
|---|---|
| `@eversis-implement` / `/eversis-implement` | `/eversis-implement` (po 5.3) |
| `.cursor/rules/*.mdc`, `alwaysApply: true` | sekcje w `CLAUDE.md` |
| `.mdc` z `globs:` | `.claude/rules/*.md` z `paths:` (faza F) |
| `.cursorignore` | `permissions.deny` w `.claude/settings.json` |
| `.cursor/mcp.json` | `.mcp.json` w roocie |
| `.cursor/commands/` | `.claude/commands/` albo `.claude/skills/` |
| `eversis-project-stack.mdc` | `.claude/CLAUDE.md` |

---

## 6. Otwarte pytania (do decyzji przed planem)

| # | Pytanie | Opcje | Rekomendacja |
|---|---------|-------|--------------|
| **Q1** | Czy adapter Claude ma emitować slash commands? | (a) `.claude/commands/*.md` — symetrycznie do DHI-598 · (b) `.claude/skills/eversis-*/SKILL.md` — natywniej, daje autoładowanie · (c) nie emitować | **(a)** — minimalna zmiana, parytet 1:1 z Cursorem, generator prawie identyczny |
| **Q2** | Jak wystawić 45 skilli? | (a) generator kopiujący do `.claude/skills/` · (b) linkowanie z instalatora wg `EFFECTIVE_LINK_MODE` · (c) status quo (tylko MCP) | **(b)** — reużywa istniejącą decyzję symlink/kopia i nie tworzy drugiego źródła prawdy |
| **Q3** | Rozbić `CLAUDE.md` na `.claude/rules/` z `paths:`? | (a) tak, przenieść reguły z globami (dziś: accessibility) · (b) zostawić monolit | **(a)** — zamyka F6 i przywraca parytet z kolumną `globs` mapy Cursora |
| **Q4** | Co z `.claudeignore`? | (a) usunąć i zastąpić emitowanym `permissions.deny` · (b) zostawić i udokumentować jako no-op · (c) zostawić jako źródło klas, z którego generujemy `deny` | **(c)** — jedno źródło prawdy klas ścieżek, bez łamania DHI-529, plus działający efekt |
| **Q5** | Czy instalator ma pisać `.mcp.json`? | (a) tak, gdy `claude` ∈ `--agents` · (b) tylko dokumentacja | **(a)** — F3 jest blokerem instalacji Claude-only |
| **Q6** | Czy `templates/mcp.json` rozbić per-host? | (a) jeden szablon + transformacja składni w merge · (b) `templates/mcp.cursor.json` + `templates/mcp.claude.json` | **(a)** — `${env:X}` → `${X}` to prosta podmiana przy zapisie; jeden katalog serwerów |
| **Q7** | Jak naprawić ścieżki `.ai/...` (F11)? | (a) generator przyjmuje prefiks frameworka i przepisuje sekcję How-to · (b) instalator dopisuje sekcję o `vendor/` · (c) symlink `.ai` → `vendor/agent-collections/.ai` w konsumencie | **(a)** — deterministyczne i sprawdzalne przez `--check`; (c) rozwiązuje też treść reguł, ale zaśmieca root konsumenta |
| **Q8** | Czyją własnością jest `.claude/settings.json`? | (a) framework seeduje raz i nie nadpisuje (jak `eversis-project-stack.mdc`) · (b) framework merge'uje sekcje oznaczone markerami (jak triada ignore) | **(b)** dla `permissions.deny` i `enabledMcpjsonServers`, **(a)** dla pozostałych kluczy |

---

## 7. Proponowany zakres planu

Kolejność podyktowana zależnościami — F3 i F11 blokują wszystko inne.

| Faza | Treść | Zamyka |
|------|-------|--------|
| **A** | `merge_mcp_json` respektuje `--agents`; zapis `.mcp.json` z konwersją składni; jawny `env` dla `eversis-collections` | F3, F4, F9 |
| **B** | Generator Claude przyjmuje prefiks frameworka i przepisuje sekcję „How to use prompts and skills" na ścieżki realne w konsumencie | F11 |
| **C** | Emit `.claude/commands/` z `.ai/prompts/**` (port DHI-598) + rozszerzenie `sync.mjs --check` o drift i sieroty | F1, F10 |
| **D** | Emit / linkowanie `.claude/skills/` | F2 |
| **E** | Szablon `.claude/settings.json` z `permissions.deny` generowanym z klas `.claudeignore`; korekta `isolation-strategy.md` §4 / §8.1 / w. 109 | F5, F8 |
| **F** | Przeniesienie reguł z globami do `.claude/rules/` z `paths:`; skrócenie `CLAUDE.md` pod <200 linii | F6 |
| **G** | Domknięcie kontraktu AGENTS.md ↔ `.claude/CLAUDE.md` w `adapters/claude/README.md` i `adapter-mapping.md` §5; aktualizacja tabeli „Exceptions" (trzy pozycje przestały być deferred) | F7 |

Fazy A–D dają Claude Code parytet użytkowy z Cursorem. E–G to jakość kontekstu i porządek dokumentacyjny. Każda faza wymaga wpisu w `CHANGELOG.md` i przejścia `npm run sync:adapters:check`.

---

## 8. Źródła

**Kod frameworka:** `adapters/claude/{README.md,generate.mjs,rule-map.yaml}` · `adapters/cursor/{rule-map.yaml,command-deny.yaml}` · `adapters/sync.mjs` · `scripts/setup-agent-collections.sh` · `scripts/lib/setup-agent-collections/{mcp-merge.sh,mcp-merge.mjs,link-framework.sh,vendor.sh,scaffolding.sh,area-scope.sh}` · `mcp/eversis-collections-mcp/src/resolveRoot.ts` · `templates/mcp.json` · `.claudeignore` · `CLAUDE.md`.

**Dokumentacja architektury:** `docs/architecture/adapter-mapping.md` §5–6 · `docs/architecture/isolation-strategy.md` §4 / §8.1 / w. 109 · `docs/architecture/agents-md-standard.md` · specyfikacje DHI-523/526/527/528/529/531/598.

**Dokumentacja Claude Code** (weryfikacja 2026-08-12): [Memory](https://code.claude.com/docs/en/memory) · [Settings](https://code.claude.com/docs/en/settings) · [Skills](https://code.claude.com/docs/en/skills) · [MCP](https://code.claude.com/docs/en/mcp).

**`.claudeignore` — potwierdzenie braku wsparcia:** [#579](https://github.com/anthropics/claude-code/issues/579) · [#4160](https://github.com/anthropics/claude-code/issues/4160) · [#29455](https://github.com/anthropics/claude-code/issues/29455) · [#36163](https://github.com/anthropics/claude-code/issues/36163).
