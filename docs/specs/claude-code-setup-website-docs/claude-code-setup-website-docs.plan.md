# claude-code-setup-website-docs - Implementation Plan

## Task Details

| Field            | Value                   |
| ---------------- | ----------------------- |
| Jira ID          | brak |
| Title            | Synchronizacja `website/docs/**` z parytetem Claude Code (F1–F11 z `claude-code-setup`) |
| Description      | 8 stron w `website/docs/` opisuje Claude Code w sposób nieaktualny wobec zaimplementowanego `claude-code-setup.plan.md` — głównie: `AGENTS.md` zamiast `.claude/CLAUDE.md` (F7), brak `.claude/commands/`, brak natywnego `.claude/skills/`, i jedno miejsce (`mcp-setup.md`) aktywnie zaprzeczające działającej już funkcji MCP. |
| Priority         | Średnia (dokumentacja, nie blokuje funkcjonalności; ale `mcp-setup.md` aktywnie wprowadza w błąd) |
| Related Research | [`claude-code-setup-website-docs.research.md`](./claude-code-setup-website-docs.research.md) |

## Wildly Important Goal

**Goal**: Każde stwierdzenie o Claude Code w `website/docs/**` odpowiada rzeczywistemu zachowaniu frameworka po `claude-code-setup.plan.md` (fazy A–H) — bez śladu po `AGENTS.md`-jako-Claude-surface, z `.claude/commands/` i natywnym `.claude/skills/` wymienionymi wszędzie tam, gdzie wymieniony jest odpowiednik Cursora.

**Success Measure**: `grep -rn 'AGENTS.md' website/docs/getting-started/ website/docs/framework-reference.md website/docs/isolation.md` nie zwraca żadnego wystąpienia w kontekście "customise Claude Code here"; `mcp-setup.md` nie zawiera już zdania sugerującego brak pełnej parytetu MCP; `npm run website:build` przechodzi bez błędów.

**Do NOT touch / do NOT add**: treść niedotycząca Claude Code · `docs/architecture/**` i `adapters/claude/README.md` (już poprawione w `claude-code-setup.plan.md`) · hosting/publikacja strony (nadal lokalny build, MVP) · struktura sidebarów / nawigacji · `website/docs/prompts/**` i `website/docs/skills/**` (W11 z research — osobny, znacznie większy problem: cała ta gałąź odwołuje się do przedrebrandingowego układu `.cursor/prompts/`/`.cursor/skills/`/`@eversis-*`, niezwiązanego z Claude Code) · nowe zależności npm.

## Proposed Solution

Osiem niezależnych, mechanicznych korekt tekstu — jedna na plik — plus obowiązkowa faza code review. Żadna zmiana nie dotyka kodu, configów ani struktury strony; weryfikacja to `grep` (obecność/brak konkretnego stwierdzenia) + `npm run website:build` (Docusaurus nie failuje na złożonym markdownie/linkach).

Trzy powtarzające się wzorce korekty (patrz research §4), stosowane konsekwentnie we wszystkich plikach:

1. **`AGENTS.md` → `.claude/CLAUDE.md`** wszędzie, gdzie tekst mówi "tu dostosuj Claude Code" (F7).
2. **Dopisanie `.claude/commands/`** obok każdej wzmianki `.cursor/commands/` dla parytetu.
3. **Dopisanie natywnego `.claude/skills/`** (z zaznaczeniem, że to przewaga nad Cursorem, nie tylko parytet) tam, gdzie skille dla Claude Code są dziś opisane jako "tylko przez MCP".

Plus jedna nieszablonowa korekta: `mcp-setup.md` §"Claude Code note" — przepisanie zdania, które dziś aktywnie zaprzecza działającej funkcji (W5), na krótkie potwierdzenie parytetu (Q2=b z research).

<!-- Plan nie zawiera kodu — wyłącznie edycje treści Markdown. -->

## Current Implementation Analysis

### Already Implemented

- `docs/architecture/adapter-mapping.md`, `docs/architecture/isolation-strategy.md`, `adapters/claude/README.md` — już poprawione w `claude-code-setup.plan.md` (fazy C, E, G) i służą jako wzorzec "jak wygląda poprawna wersja tego samego faktu" dla tego planu.
- `claude-code-setup-website-docs.research.md` — pełny katalog W1–W11 z numerami linii, klasyfikacją ważności i rozstrzygniętymi Q1–Q4.

### To Be Modified

- `website/docs/isolation.md` — tabela "Multi-agent MVP" (W1).
- `website/docs/framework-reference.md` — linie 65, 76 (W2, W3).
- `website/docs/intro.md` — linia 41 (W4).
- `website/docs/getting-started/mcp-setup.md` — linie 27, 74-76 (W5, W6).
- `website/docs/getting-started/prerequisites.md` — linia 15 (W7).
- `website/docs/getting-started/installation.md` — linia 89, sekcja "4. Skills and prompts (MVP)" (W8, W8a).
- `website/docs/getting-started/migration-from-cursor-collections.md` — linie 42-43, 51, tabela "Capability matrix" 57-65 (W9, W9a, W9b).
- `website/docs/getting-started/quick-wins.md` — linia 9 (W10).

### To Be Created

Brak nowych plików.

## Open Questions

| #   | Question   | Answer   | Status                |
| --- | ---------- | -------- | --------------------- |
| 1   | Zakres korekt: minimalny czy z nową treścią? | (a) minimalne, punktowe poprawki | ✅ Resolved |
| 2   | `mcp-setup.md` "Claude Code note": usunąć czy przepisać? | (b) przepisać na potwierdzenie parytetu | ✅ Resolved |
| 3   | Czy `quick-wins.md` (W10) w zakresie? | (a) tak | ✅ Resolved |
| 4   | Czy istnieje `website/docs/architecture/` (duplikat)? | Nie istnieje — zweryfikowane `find website/docs -type d` | ✅ Resolved |

Pełne uzasadnienie: [`claude-code-setup-website-docs.research.md`](./claude-code-setup-website-docs.research.md) §5.

## Technical Context

### Project Instructions

- Ten sam Delivery Standard co framework (`.ai/rules/orchestration/spec-driven-development.md`) — research zaakceptowany przez maintainera 2026-08-12 (Q1–Q4 rozstrzygnięte), plan wymaga zatwierdzenia przed egzekucją.

### Architecture & Patterns

- `website/` to Docusaurus 3 (TypeScript config `docusaurus.config.ts`), treść w `website/docs/**/*.md` z frontmatterem `sidebar_position` / `title` / `slug`.
- Strona buduje się **lokalnie**, brak produkcyjnego hostingu w MVP (`framework-reference.md:18-20`) — nie ma ryzyka wdrożenia na żywo, tylko lokalna spójność.
- Dokumentacja frameworka jest wyłącznie po angielsku (`framework-reference.md:12`: "Consumer documentation is written in **English**") — poprawki tekstu **muszą** zostać po angielsku, mimo że ten plan i research są po polsku na życzenie maintainera.

### Tech Stack

- Docusaurus 3, Node.js (już zainstalowane `website/node_modules`).
- `npm run website:build` (`npm --prefix website run build`) — jedyna dostępna komenda jakości dla tej zmiany (brak linta dedykowanego pod markdown w tym repo).

### Code Style & Standards

- Tabele Markdown wyrównane wizualnie jak w istniejących plikach (nie jest to wymuszane narzędziem, ale zachować spójność z resztą pliku przy edycji tabel).
- Nie zmieniać frontmatteru (`sidebar_position`, `slug`, `title`) — poza zakresem.

### Testing Patterns

- Brak testów jednostkowych dla treści Markdown. Weryfikacja: `grep` (deterministyczne, per-task) + `npm run website:build` (per-phase, łapie złamany markdown/broken linki wewnętrzne, jeśli Docusaurus je waliduje).

### Database Patterns

Nie dotyczy.

### Additional Context

- Każdy task poniżej cytuje dokładny stary tekst (do usunięcia/zastąpienia) i nowy tekst (kierunek), żeby uniknąć niejednoznaczności przy dosłownie tej samej frazie występującej w kilku plikach (np. `AGENTS.md` → `.claude/CLAUDE.md` powtarza się 4×).

## Implementation Plan

### Phase 1: Korekty treści Claude Code w `website/docs/**`

**Goal**: Zamyka W1–W10 z research — każde stwierdzenie o Claude Code w ośmiu stronach odpowiada rzeczywistości po `claude-code-setup.plan.md`.

**Description**: Osiem niezależnych tasków, jeden na plik. Kolejność dowolna (brak zależności między plikami) — ułożona od najpoważniejszego (W5, aktywnie wprowadzające w błąd) do najlżejszego (W10, doprecyzowanie).

**Verification:** `npm run website:build`

#### Task 1.1 - [MODIFY] `website/docs/getting-started/mcp-setup.md`

**Description**: (W5, Krytyczna) Zastąpić sekcję "Claude Code note" (linie 74-76) — dziś mówi "not a full Cursor MCP parity matrix", co jest nieprawdą po Fazie A `claude-code-setup.plan.md` — krótkim potwierdzeniem parytetu (Q2=b): Claude Code dostaje `.mcp.json` tym samym mechanizmem merge co `.cursor/mcp.json`, ze składnią natywną dla Claude (`${VAR}`, brak `${env:...}`). (W6, Średnia) Doprecyzować linię 27 ("installer merges this into `.cursor/mcp.json`") — dodać, że ten sam config merguje się też do `.mcp.json` dla Claude Code.

**Files:** `website/docs/getting-started/mcp-setup.md` (modify)

**Definition of Done**:

- [x] `grep -qF 'not a full Cursor MCP parity matrix' website/docs/getting-started/mcp-setup.md` **nie** znajduje dopasowania (stare zdanie usunięte)
- [x] Plik zawiera zdanie potwierdzające, że Claude Code ma `.mcp.json` z parytetem funkcjonalnym wobec `.cursor/mcp.json`
- [x] Run `npm run website:build`

**Clues**: Punkt odniesienia dla poprawnego opisu mechanizmu: `docs/specs/claude-code-setup/claude-code-setup.plan.md` Faza A (Task A.1-A.2) i `scripts/lib/setup-agent-collections/mcp-merge.sh`.

#### Task 1.2 - [MODIFY] `website/docs/framework-reference.md`

**Description**: (W3, Wysoka) Linia 76: `"**Claude Code** — root \`CLAUDE.md\`; skills via MCP / \`AGENTS.md\`."` → zastąpić opisem obejmującym `.claude/commands/`, `.claude/rules/`, natywny `.claude/skills/`, oraz `.claude/CLAUDE.md` zamiast `AGENTS.md`. (W2, Niska) Linia 65: dopisać, że `/eversis-*` po synchronizacji istnieje też jako `.claude/commands/` dla Claude Code, nie tylko `.cursor/commands/` dla Cursora.

**Files:** `website/docs/framework-reference.md` (modify)

**Definition of Done**:

- [x] `grep -qF 'AGENTS.md' website/docs/framework-reference.md` — jeśli dopasowanie istnieje, musi być w kontekście importu (`@AGENTS.md`) lub innym niż "gdzie dostosować Claude Code", nie jako jedyne miejsce customizacji
- [x] Plik wspomina `.claude/commands/` i `.claude/skills/` w sekcji "Multi-agent and isolation"
- [x] Run `npm run website:build`

#### Task 1.3 - [MODIFY] `website/docs/isolation.md`

**Description**: (W1, Średnia) Tabela "Multi-agent MVP" (linia 47-53) — wiersz `Claude Code` rozszerzyć o `.claude/commands/`, `.claude/rules/` w kolumnie "Packaging" i natywny `.claude/skills/` w kolumnie "Skills" (dziś: tylko "MCP / read `.ai/skills`").

**Files:** `website/docs/isolation.md` (modify)

**Definition of Done**:

- [x] Wiersz `Claude Code` w tabeli "Multi-agent MVP" wymienia `.claude/commands/`, `.claude/rules/`, i natywny `.claude/skills/`
- [x] Run `npm run website:build`

#### Task 1.4 - [MODIFY] `website/docs/intro.md`

**Description**: (W4, Niska) Linia 41: `"Cursor may generate thin /eversis-* shims under .cursor/commands/ via the adapter (DHI-598)."` — dopisać, że Claude Code ma ten sam mechanizm (`.claude/commands/`).

**Files:** `website/docs/intro.md` (modify)

**Definition of Done**:

- [x] Linia o `/eversis-*` shims wspomina zarówno `.cursor/commands/`, jak i `.claude/commands/`
- [x] Run `npm run website:build`

#### Task 1.5 - [MODIFY] `website/docs/getting-started/prerequisites.md`

**Description**: (W7, Wysoka) Tabela "Agent tools" (linia 15): `"**Claude Code** | Shipped adapter: root CLAUDE.md from core rules; skills via MCP / AGENTS.md"` → zastąpić opisem z `.claude/commands/`, natywnym `.claude/skills/`, i `.claude/CLAUDE.md` zamiast `AGENTS.md`.

**Files:** `website/docs/getting-started/prerequisites.md` (modify)

**Definition of Done**:

- [x] Wiersz `Claude Code` w tabeli "Agent tools" nie zawiera już `AGENTS.md` jako miejsca customizacji
- [x] Wiersz wspomina natywny `.claude/skills/` i `.claude/commands/`
- [x] Run `npm run website:build`

#### Task 1.6 - [MODIFY] `website/docs/getting-started/installation.md`

**Description**: (W8, Wysoka) Tabela "Customising stack (Cursor vs Claude)" (linia 84-89): wiersz `Claude Code | AGENTS.md (do not hand-edit generated CLAUDE.md)` → `.claude/CLAUDE.md`. (W8a, Wysoka) Sekcja "4. Skills and prompts (MVP)" (linie 91-95): dopisać `.claude/commands/` obok istniejącego opisu `.cursor/commands/`, i dopisać natywny `.claude/skills/` z jednym zdaniem zaznaczającym, że to przewaga nad Cursorem (który świadomie nie ma mirrora `.cursor/skills`).

**Files:** `website/docs/getting-started/installation.md` (modify)

**Definition of Done**:

- [x] `grep -qF 'AGENTS.md (do not hand-edit' website/docs/getting-started/installation.md` **nie** znajduje dopasowania
- [x] Tabela "Customising stack" wskazuje `.claude/CLAUDE.md` dla Claude Code
- [x] Sekcja "4. Skills and prompts (MVP)" wspomina `.claude/commands/` i natywny `.claude/skills/`
- [x] Run `npm run website:build`

#### Task 1.7 - [MODIFY] `website/docs/getting-started/migration-from-cursor-collections.md`

**Description**: (W9, Wysoka) Linia 43: `"Claude stack in AGENTS.md"` → `.claude/CLAUDE.md`. (W9a, Średnia) Tabela "Ownership model" (linia 51): dopisać `.claude/commands/eversis-*.md`, `.claude/rules/*.md` obok `.cursor/rules/eversis-*.mdc` / `CLAUDE.md` w wierszu "Generated (adapters)". (W9b, Krytyczna) Tabela "Capability matrix (Cursor vs Claude MVP)" (linie 55-65) — przepisać wiersze `Skills` i `Slash commands` dla kolumny Claude Code (dziś: "instructional load via AGENTS.md" i "Claude Code uses prompt ids / CLAUDE.md" — oba nieaktualne), dopisać wiersz dla ustawień/`permissions` (`.claude/settings.json`, dziś brak odpowiednika mimo że `.claudeignore` już jest wymieniony w wierszu "Ignore triad").

**Files:** `website/docs/getting-started/migration-from-cursor-collections.md` (modify)

**Definition of Done**:

- [x] `grep -qF 'Claude stack in AGENTS.md' website/docs/getting-started/migration-from-cursor-collections.md` **nie** znajduje dopasowania
- [x] Wiersz `Skills` w tabeli "Capability matrix" wspomina natywny `.claude/skills/`, nie tylko MCP/`AGENTS.md`
- [x] Wiersz `Slash commands` w tej samej tabeli potwierdza, że Claude Code ma natywne `.claude/commands/`, nie tylko "prompt ids"
- [x] Tabela "Capability matrix" ma nowy wiersz dla ustawień/`permissions` (`.claude/settings.json`)
- [x] Run `npm run website:build`

**Clues**: Ta tabela ma najwięcej nieaktualnych stwierdzeń naraz (research W9b) — warto przepisać cały blok Skills/Slash-commands/Settings za jednym razem zamiast punktowo, żeby zachować spójność kolumn.

#### Task 1.8 - [MODIFY] `website/docs/getting-started/quick-wins.md`

**Description**: (W10, Niska, w zakresie po Q3=a) Linia 9 (tip box): dopisać jedno zdanie kontrastujące — `.cursor/skills` mirror świadomie nie istnieje (bez zmian), ale Claude Code ma od `claude-code-setup.plan.md` natywny `.claude/skills/`, więc zdanie "this MVP does not ship a full `.cursor/skills` mirror" nie powinno być czytane jako uogólnienie na cały framework.

**Files:** `website/docs/getting-started/quick-wins.md` (modify)

**Definition of Done**:

- [x] Tip box na początku pliku zawiera zdanie odróżniające brak `.cursor/skills` (Cursor, bez zmian) od istniejącego natywnego `.claude/skills/` (Claude Code)
- [x] Run `npm run website:build`

### Phase 2: Code Review

**Goal**: Finalna weryfikacja jakości przed Fine.

**Description**: Finalne uruchomienie **Code Reviewer** przez `eversis-review.md` na pełnej zmianie Fazy 1. Zakres: zgodność faktów z `claude-code-setup.plan.md` (nie wprowadzić nowej nieścisłości przy poprawianiu starej), brak edycji poza ośmioma wymienionymi plikami, dokumentacja pozostaje w języku angielskim.

**Verification:** `npm run website:build`

#### Task 2.1 - [REUSE] Code review przez Code Reviewer

**Description**: Uruchomić **Code Reviewer** via `eversis-review.md` na pełnym diffie ośmiu plików z Fazy 1.

**Files:** wszystkie pliki z Fazy 1 (reuse)

**Definition of Done**:

- [x] Run `npm run website:build` — zielone
- [x] Code review passes bez blockerów
- [x] Wynik review udokumentowany w Changelogu tego planu

## Security Considerations

- Brak — wyłącznie zmiany treści dokumentacji statycznej, bez kodu wykonywalnego, sekretów, ani danych wejściowych użytkownika.

## Quality Assurance

- [ ] Żaden z 8 plików nie zawiera już `AGENTS.md` jako jedynego miejsca customizacji Claude Code
- [ ] Każda wzmianka `.cursor/commands/` ma odpowiadającą wzmiankę `.claude/commands/` w tym samym kontekście (gdzie dotyczy Claude Code)
- [ ] Każda wzmianka skilli dla Claude Code wspomina natywny `.claude/skills/`, nie tylko MCP
- [ ] `mcp-setup.md` nie zawiera już zdania sugerującego brak pełnego wsparcia MCP dla Claude Code
- [ ] `npm run website:build` przechodzi bez błędów
- [ ] Dokumentacja pozostaje wyłącznie w języku angielskim (zgodnie z `framework-reference.md:12`)

## Improvements (Out of Scope)

- **W11** — `website/docs/prompts/**` i `website/docs/skills/**` (90+ plików) odwołują się do przedrebrandingowego układu `.cursor/prompts/`, `.cursor/skills/`, składni `@eversis-*` — niezwiązane z Claude Code, dotyczy całego modelu narzędziowego strony. Osobne, znacznie większe zadanie — wymaga własnego research.
- Automatyzacja synchronizacji `website/docs/` z `.ai/prompts/` / `.ai/skills/` (żeby uniknąć przyszłego rozjazdu jak W11) — poza zakresem, wymaga decyzji architektonicznej.
- Publikacja/hosting strony — nadal poza MVP.

## Changelog

| Date       | Change Description   |
| ---------- | --------------------- |
| 2026-08-12 | Initial plan created — Faza 1 (8 tasków, jeden na plik) + Faza 2 (code review), na bazie `claude-code-setup-website-docs.research.md`, Q1-Q4 rozstrzygnięte przez maintainera |
| 2026-08-12 | Faza 1 zaimplementowana — 8/8 plików poprawionych (W1-W10), wszystkie DoD-grep przeszły, `npm run website:build` zielony. |
| 2026-08-12 | Faza 2 — code review skalował do pełnego wielo-agentowego przeglądu całego niezacommitowanego diffu sesji (nie tylko tych 8 plików Markdown, ponieważ nic w tej sesji nie było jeszcze zacommitowane). Ten task Markdown-only nie miał żadnych findingów; wszystkie 4 naprawione findingi (w tym jeden security-krytyczny w `vendor.sh`) dotyczyły wcześniejszego `claude-code-setup.plan.md` — udokumentowane tam. `npm run website:build` pozostał zielony po całej sesji poprawek. |
