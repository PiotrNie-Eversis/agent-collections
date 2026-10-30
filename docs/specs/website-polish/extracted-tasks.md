# Język polski na stronie dokumentacji — Extracted Tasks

## Workshop Summary

| Field | Value |
|---|---|
| Workshop Date | 2026-09-23 |
| Participants | Zleceniodawca (czat) |
| Source Materials | Prośba użytkownika; analiza `website/` (Docusaurus 3.10, ~140 stron docs, ~85k słów łącznie z UI i changelogiem); `intent-brief.md` |
| Intent Brief | `docs/specs/website-polish/intent-brief.md` (Gate 0: **Approved — cała strona**) |
| Project Baseline Used | None |
| Total Epics | 8 |
| Total Stories | 24 |

## Epics Overview

| # | Epic Title | Stories Count | Priority |
|---|-----------|---------------|----------|
| 1 | Infrastruktura wielojęzyczności Docusaurus | 3 | Critical |
| 2 | Polski interfejs stały (menu, stopka, strona główna) | 3 | Critical |
| 3 | Polska dokumentacja przewodnikowa | 4 | High |
| 4 | Polska referencja kuratorska | 4 | High |
| 5 | Polska referencja promptów i pipeline sync | 3 | Critical |
| 6 | Polski dziennik zmian | 2 | High |
| 7 | Wyszukiwanie, SEO i weryfikacja buildu | 3 | High |
| 8 | Proces utrzymania tłumaczeń | 2 | High |

---

## Epic 1: Infrastruktura wielojęzyczności Docusaurus

**Business Description**: Umożliwia czytelnikowi wybór polskiego obok angielskiego na tej samej stronie dokumentacji, bez osobnej witryny. Angielski pozostaje domyślny; polski ma własne adresy URL zgodne ze standardem Docusaurus.

**Success Criteria**:
- Strona buduje się z dwoma locale: `en` (domyślny) i `pl`.
- Czytelnik widzi przełącznik języka i może przejść między wersjami tej samej strony.
- Struktura katalogów polskich tłumaczeń jest udokumentowana dla opiekuna docs.

### Story 1.1: Włączenie locale polskiego w konfiguracji strony

**User Story**: Jako czytelnik dokumentacji, chcę mieć dostęp do polskiej wersji strony obok angielskiej, aby czytać treść w preferowanym języku.

**Source**: Analiza `website/docusaurus.config.ts` (obecnie `locales: ['en']`); decyzja Gate 0 — cała strona.

**Acceptance Criteria**:
- [ ] GIVEN konfiguracja Docusaurus WHEN locale `pl` jest dodany obok `en` THEN build produkuje artefakty dla obu języków bez błędów krytycznych.
- [ ] GIVEN angielski jako `defaultLocale` WHEN czytelnik wchodzi na stronę bez prefiksu języka THEN widzi wersję angielską.
- [ ] GIVEN polski locale WHEN czytelnik wchodzi pod prefiksem `/pl/` THEN widzi polską wersję (lub placeholder dla stron jeszcze nietłumaczonych — do wypełnienia w kolejnych story).

**High-Level Technical Notes**: Docusaurus i18n — katalog `website/i18n/pl/` dla docs, pages, theme.

**Priority**: Critical

### Story 1.2: Przełącznik języka w nawigacji

**User Story**: Jako czytelnik, chcę przełączać język z poziomu menu, aby nie musieć ręcznie edytować adresu URL.

**Source**: Analiza `docusaurus.config.ts` — brak `localeDropdown` w navbar; Gate 0.

**Acceptance Criteria**:
- [ ] GIVEN czytelnik na dowolnej stronie docs WHEN otwiera przełącznik języka THEN widzi co najmniej „English” i „Polski”.
- [ ] GIVEN czytelnik na stronie z polskim odpowiednikiem WHEN wybiera drugi język THEN trafia na tę samą stronę logiczną w drugim locale (zachowanie Docusaurus fallback, gdy brak tłumaczenia).
- [ ] GIVEN wersja mobilna WHEN czytelnik otwiera menu THEN przełącznik języka jest dostępny i czytelny.

**High-Level Technical Notes**: `type: 'localeDropdown'` w `themeConfig.navbar.items`.

**Priority**: Critical

### Story 1.3: Dokumentacja struktury tłumaczeń dla opiekuna docs

**User Story**: Jako opiekun dokumentacji, chcę wiedzieć, gdzie dodawać i edytować polskie pliki, aby utrzymać spójność z angielską wersją.

**Source**: Analiza repozytorium — brak `website/i18n/`; brak instrukcji i18n w `website/README.md`.

**Acceptance Criteria**:
- [ ] GIVEN nowy opiekun docs WHEN czyta dokumentację projektu THEN rozumie mapowanie: angielski SSOT → polski katalog i18n (docs, pages, `code.json`).
- [ ] GIVEN zasada terminologii WHEN opiekun dodaje tłumaczenie THEN wie, że identyfikatory promptów/skilli i bloki kodu pozostają po angielsku.
- [ ] GIVEN zmiana w angielskiej stronie WHEN opiekun aktualizuje docs THEN wie, który polski plik wymaga aktualizacji.

**High-Level Technical Notes**: Rozdział w `website/README.md` lub osobna strona docs „Contributing translations”.

**Priority**: High

---

## Epic 2: Polski interfejs stały (menu, stopka, strona główna)

**Business Description**: Elementy widoczne na każdej stronie i na landing page są po polsku, gdy czytelnik wybrał polski — pierwsze wrażenie i nawigacja nie wymagają angielskiego.

**Success Criteria**:
- Menu, stopka i metadane strony (tytuł, opis) mają polskie warianty.
- Strona główna (`/`) w locale `pl` prezentuje te same sekcje co angielska, w języku polskim.

### Story 2.1: Polskie etykiety menu, stopki i motywu

**User Story**: Jako czytelnik po polsku, chcę widzieć polskie etykiety w menu i stopce, aby nawigować bez tłumaczenia w głowie.

**Source**: `docusaurus.config.ts` — etykiety „Docs”, „Get started”, „The Main Flow”, „Reference”, „Advanced / CTO”, „Changelog”; footer links.

**Acceptance Criteria**:
- [ ] GIVEN locale `pl` WHEN czytelnik otwiera dowolną stronę THEN etykiety pozycji menu (Docs, Get started, The Main Flow, Reference, Advanced / CTO, Changelog) są po polsku.
- [ ] GIVEN locale `pl` WHEN czytelnik scrolluje do stopki THEN linki i tekst copyright są po polsku (lub zgodnie ze stylem — nazwa produktu może pozostać „Agent Collections”).
- [ ] GIVEN wbudowane komunikaty Docusaurus (np. „Edit this page”, paginacja) WHEN locale `pl` THEN są przetłumaczone przez `i18n/pl/code.json`.

**Priority**: Critical

### Story 2.2: Polska strona główna (komponenty React)

**User Story**: Jako potencjalny użytkownik frameworka czytający po polsku, chcę zrozumieć wartość produktu ze strony głównej w moim języku.

**Source**: `website/src/components/*` — HeroSection, HomepageFeatures, WorkflowShowcase, QuickWins, SocialProof, GettingStartedSection (~3k słów UI copy).

**Acceptance Criteria**:
- [ ] GIVEN locale `pl` WHEN czytelnik wchodzi na `/pl/` THEN wszystkie sekcje landing page (hero, features, workflow, quick wins, social proof, getting started) wyświetlają polski tekst.
- [ ] GIVEN polska strona główna WHEN czytelnik klika CTA / linki THEN trafia na polskie odpowiedniki stron docs (lub angielski fallback z jasnym sygnałem, dopóki tłumaczenie docs nie istnieje).
- [ ] GIVEN nazwy własne (Agent Collections, nazwy promptów) WHEN wyświetlane na PL THEN pozostają w oryginale angielskim tam, gdzie to identyfikatory techniczne.

**High-Level Technical Notes**: `@docusaurus/Translate`, `<Translate>`, lub pliki `code.json` + osobne pliki treści per locale.

**Priority**: Critical

### Story 2.3: Polskie metadane SEO i Open Graph per locale

**User Story**: Jako czytelnik udostępniający link po polsku, chcę, aby podgląd linku (tytuł, opis) był po polsku.

**Source**: `docusaurus.config.ts` — `title`, `tagline`, `themeConfig.metadata`, `themeConfig.image` alt texts.

**Acceptance Criteria**:
- [ ] GIVEN locale `pl` WHEN czytelnik udostępnia stronę główną THEN Open Graph / Twitter title i description są po polsku.
- [ ] GIVEN locale `pl` WHEN wyszukiwarka indeksuje stronę THEN `html lang="pl"` jest ustawiony poprawnie.
- [ ] GIVEN oba locale WHEN sitemap jest generowany THEN zawiera wpisy dla `en` i `pl` z poprawnymi hreflang (Docusaurus default).

**Priority**: Medium

---

## Epic 3: Polska dokumentacja przewodnikowa

**Business Description**: Przewodniki dla nowych użytkowników i opis głównego przepływu pracy są w pełni po polsku — to ~27 stron, ~17k słów, najczęściej czytana ścieżka onboardingu.

**Success Criteria**:
- Wszystkie strony w `getting-started/`, `main-flow/`, `advanced/` oraz `intro.md` mają polskie odpowiedniki.
- Linki wewnętrzne w polskich plikach wskazują na polskie strony docelowe.

### Story 3.1: Polski „Getting started” (5 stron)

**User Story**: Jako nowy użytkownik czytający po polsku, chcę przejść instalację i pierwsze kroki w moim języku.

**Source**: `website/docs/getting-started/` — start-here, installation, prerequisites, mcp-setup, quick-wins (~3,5k słów).

**Acceptance Criteria**:
- [ ] GIVEN locale `pl` WHEN czytelnik otwiera sekcję Getting started THEN każda z 5 stron ma polską treść merytoryczną.
- [ ] GIVEN polska strona instalacji WHEN zawiera komendy shell / ścieżki THEN komendy i ścieżki pozostają identyczne jak w EN.
- [ ] GIVEN polskie strony WHEN czytelnik klika linki wewnętrzne THEN trafia na polskie odpowiedniki w tej samej sekcji lub referencji.

**Priority**: High

### Story 3.2: Polski „Main flow” (17 stron)

**User Story**: Jako członek zespołu produktowego po polsku, chcę zrozumieć metodologię Ideate → Implement → Review → Fine w moim języku.

**Source**: `website/docs/main-flow/` — index, use-cases, team-guides, workflow (~11k słów).

**Acceptance Criteria**:
- [ ] GIVEN locale `pl` WHEN czytelnik przegląda Main flow THEN wszystkie 17 stron ma polską treść.
- [ ] GIVEN diagramy Mermaid / schematy WHEN wyświetlane na PL THEN etykiety w diagramach są po polsku (tam, gdzie niosą znaczenie biznesowe).
- [ ] GIVEN nazwy ról (Business Analyst, Engineering Manager) WHEN pierwsze wystąpienie THEN mają polski opis roli przy zachowaniu angielskiej nazwy w nawiasie, jeśli to nazwy używane w promptach.

**Priority**: High

### Story 3.3: Polska sekcja „Advanced / CTO” (4 strony)

**User Story**: Jako lider techniczny czytający po polsku, chcę zrozumieć izolację, migrację i perspektywę CTO bez barier językowych.

**Source**: `website/docs/advanced/` — for-ctos, isolation, migration-from-cursor-collections, index (~2,5k słów).

**Acceptance Criteria**:
- [ ] GIVEN locale `pl` WHEN czytelnik otwiera Advanced THEN wszystkie 4 strony są po polsku.
- [ ] GIVEN terminy architektoniczne (submodule, adapter) WHEN używane THEN są spójne z glosariuszem PL (Story 4.4).

**Priority**: High

### Story 3.4: Polski wstęp do dokumentacji (`intro.md`)

**User Story**: Jako czytelnik wchodzący przez `/docs/`, chcę od razu zrozumieć strukturę dokumentacji po polsku.

**Source**: `website/docs/intro.md` (~476 słów).

**Acceptance Criteria**:
- [ ] GIVEN locale `pl` WHEN czytelnik otwiera `/pl/docs/` THEN intro jest po polsku i linkuje do polskich sekcji.
- [ ] GIVEN intro PL WHEN wymienia ścieżki w repozytorium THEN ścieżki pozostają angielskie (faktyczne nazwy folderów).

**Priority**: High

---

## Epic 4: Polska referencja kuratorska

**Business Description**: Kuratorskie strony referencyjne (skille, agenci, integracje, słownik) — ~80 stron, ~43k słów — są po polsku. To strony pisane ręcznie pod czytelnika, nie kopiowane 1:1 ze skilli agenta.

**Success Criteria**:
- Każda strona w `reference/skills/`, `reference/agents/`, `reference/integrations/` oraz strony indeksowe i glossary ma polski odpowiednik.
- Liczby i listy skilli/promptów w overview pozostają zgodne z faktycznym stanem repozytorium.

### Story 4.1: Polska referencja skilli (~50 stron)

**User Story**: Jako developer szukający skilla po polsku, chcę przeczytać krótki opis skilla w moim języku, zachowując identyfikator `eversis-*` po angielsku.

**Source**: `website/docs/reference/skills/` (~15k słów); `adapters/website/check-skills.mjs` — strony kuratorskie, nie generowane z SKILL.md.

**Acceptance Criteria**:
- [ ] GIVEN locale `pl` WHEN czytelnik otwiera Skills overview THEN strona jest po polsku i deklaruje poprawną liczbę skilli.
- [ ] GIVEN każdy skill WHEN czytelnik otwiera stronę PL THEN widzi polski opis „kiedy używać”, przy identyfikatorze skill w oryginale.
- [ ] GIVEN check-skills WHEN uruchamiany po dodaniu PL THEN nadal przechodzi (liczba/id skilli niezależna od języka treści).

**Priority**: High

### Story 4.2: Polska referencja agentów (~17 stron)

**User Story**: Jako PM lub tech lead po polsku, chcę zrozumieć rolę każdego agenta w frameworku.

**Source**: `website/docs/reference/agents/` (~8,5k słów).

**Acceptance Criteria**:
- [ ] GIVEN locale `pl` WHEN czytelnik otwiera Agents overview THEN lista agentów i opisy ról są po polsku.
- [ ] GIVEN strona agenta WHEN zawiera link do promptu THEN link prowadzi do polskiej strony promptu (Epic 5).

**Priority**: High

### Story 4.3: Polska referencja integracji (~13 stron)

**User Story**: Jako integrator MCP po polsku, chcę wiedzieć, jak skonfigurować integracje (Atlassian, Figma, Playwright itd.) czytając po polsku.

**Source**: `website/docs/reference/integrations/` (~5k słów).

**Acceptance Criteria**:
- [ ] GIVEN locale `pl` WHEN czytelnik otwiera Integrations THEN overview i każda strona integracji są po polsku.
- [ ] GIVEN instrukcje konfiguracji WHEN zawierają nazwy env vars / pakiety THEN pozostają po angielsku.

**Priority**: High

### Story 4.4: Polskie strony indeksowe referencji i glosariusz

**User Story**: Jako czytelnik po polsku, chcę mieć spójny słownik terminów frameworka, aby różne sekcje używały tych samych polskich odpowiedników.

**Source**: `website/docs/reference/index.md`, `glossary.md`, `prompts/overview.md` (część kuratorska — tabele generowane; treść otoczenia).

**Acceptance Criteria**:
- [ ] GIVEN locale `pl` WHEN czytelnik otwiera Reference index THEN strona jest po polsku.
- [ ] GIVEN glossary PL WHEN zawiera hasło THEN ma ustalony polski odpowiednik używany konsekwentnie w innych story (np. „spec-driven development” → ustalone tłumaczenie).
- [ ] GIVEN reference index WHEN linkuje do podsekcji THEN linki prowadzą do locale `pl`.

**Priority**: High

---

## Epic 5: Polska referencja promptów i pipeline sync

**Business Description**: ~29 stron promptów (~25k słów) są generowane z `.ai/prompts/` przez `adapters/website/generate-prompts.mjs`. Pełna polonizacja wymaga procesu, który nie gubi tłumaczeń przy każdej regeneracji angielskiej wersji.

**Success Criteria**:
- Wszystkie strony promptów (public + internal) i overview mają polskie odpowiedniki.
- Po `npm run sync:website-docs` polskie strony promptów nie są cicho nadpisywane ani nie rozjechane bez sygnału w CI.

### Story 5.1: Strategia utrzymania polskich stron promptów przy regeneracji EN

**User Story**: Jako opiekun docs, chcę jasnej reguły, gdzie żyje polski tekst promptów, aby regeneracja angielskich stron nie kasowała tłumaczeń.

**Source**: `adapters/website/generate-prompts.mjs` — kopiuje angielski SSOT do `website/docs/`; marker GENERATED; brak i18n.

**Acceptance Criteria**:
- [ ] GIVEN decyzja architektoniczna WHEN zatwierdzona THEN udokumentowano jedną z dróg: (A) polskie pliki wyłącznie w `website/i18n/pl/docusaurus-plugin-content-docs/current/...`, EN generator nietknięty; (B) rozszerzenie generatora o opcjonalny krok tłumaczenia; (C) osobny skrypt sync PL po EN.
- [ ] GIVEN nowy prompt dodany do `.ai/prompts/` WHEN sync EN THEN checklist wymaga dodania/aktualizacji polskiego odpowiednika.
- [ ] GIVEN zmiana treści promptu EN WHEN sync THEN opiekun wie, że PL wymaga aktualizacji (powiązanie ze Story 8.1).

**High-Level Technical Notes**: Preferowany wariant biznesowy: (A) i18n mirror — EN pozostaje SSOT build default; PL w i18n nie jest nadpisywany przez generator.

**Priority**: Critical

### Story 5.2: Polskie tłumaczenie wszystkich stron promptów

**User Story**: Jako użytkownik Cursor po polsku, chcę przeczytać opis promptu `eversis-implement` (i pozostałych) po polsku, zachowując identyfikator i ścieżkę SSOT po angielsku.

**Source**: `website/docs/reference/prompts/` — 29 stron + overview (~25k słów).

**Acceptance Criteria**:
- [ ] GIVEN locale `pl` WHEN czytelnik otwiera Prompts overview THEN katalog promptów (public/internal) jest po polsku z poprawnymi liczbami.
- [ ] GIVEN każdy prompt public i internal WHEN otwarty w PL THEN opis roli, „What it does”, workflow i sekcja Executable są po polsku; identyfikator `eversis-*` i ścieżki `.ai/prompts/` bez zmian.
- [ ] GIVEN bloki kodu / przykłady użycia WHEN wyświetlane THEN pozostają po angielsku.

**Priority**: High

### Story 5.3: Kontrola spójności PL promptów z EN po sync

**User Story**: Jako maintainer repozytorium, chcę, aby CI wykrywał brak polskiej strony promptu po dodaniu nowego promptu EN.

**Source**: `npm run sync:website-docs:check`; analogia do `check-skills.mjs`.

**Acceptance Criteria**:
- [ ] GIVEN nowy plik EN w `website/docs/reference/prompts/` WHEN brak odpowiednika PL w i18n THEN check kończy się błędem z listą brakujących ścieżek.
- [ ] GIVEN pełny zestaw PL WHEN check THEN przechodzi w `npm run sync:website-docs:check` lub dedykowanym `website:i18n:check`.
- [ ] GIVEN dokumentacja WHEN opiekun czyta README THEN wie, jak uruchomić check lokalnie przed commitem.

**Priority**: High

---

## Epic 6: Polski dziennik zmian

**Business Description**: Strona Changelog (~7,5k słów) jest generowana z root `CHANGELOG.md`. Polska wersja musi być utrzymywana przy każdej zmianie historii wydań.

**Success Criteria**:
- Czytelnik PL widzi changelog po polsku pod `/pl/changelog/`.
- Proces aktualizacji PL jest powiązany z istniejącym `scripts/sync-changelog.mjs`.

### Story 6.1: Proces sync polskiego changeloga

**User Story**: Jako opiekun docs, chcę wiedzieć, skąd pochodzi polski changelog i kiedy go odświeżyć po edycji `CHANGELOG.md`.

**Source**: `scripts/sync-changelog.mjs` → `website/src/pages/changelog.md`; `prestart`/`prebuild` w website.

**Acceptance Criteria**:
- [ ] GIVEN zmiana w root `CHANGELOG.md` WHEN maintainer publikuje release THEN dokumentacja opisuje krok aktualizacji PL (ręczny tłumaczony plik w i18n pages LUB rozszerzony skrypt sync).
- [ ] GIVEN angielski changelog WHEN generowany ze skryptu THEN polski nie jest nadpisywany przez ten sam skrypt bez osobnego źródła PL.
- [ ] GIVEN brak aktualizacji PL WHEN EN changelog się zmienił THEN check (Story 8.2) sygnalizuje drift.

**Priority**: High

### Story 6.2: Początkowe tłumaczenie changeloga na polski

**User Story**: Jako użytkownik po polsku, chcę czytać historię wydań frameworka w moim języku.

**Source**: `website/src/pages/changelog.md` / root `CHANGELOG.md` (~7,5k słów).

**Acceptance Criteria**:
- [ ] GIVEN locale `pl` WHEN czytelnik otwiera Changelog THEN widzi polską treść obejmującą aktualne sekcje z root CHANGELOG.
- [ ] GIVEN wpisy wersji WHEN zawierają linki do plików repo THEN linki pozostają poprawne (GitLab blob URLs).
- [ ] GIVEN tip „Source of truth” WHEN wyświetlany THEN informuje po polsku, że SSOT to angielski `CHANGELOG.md`.

**Priority**: Medium

---

## Epic 7: Wyszukiwanie, SEO i weryfikacja buildu

**Business Description**: Wyszukiwarka lokalna i build CI muszą działać dla obu języków — inaczej polska wersja jest trudna do odkrycia i łamie linki.

**Success Criteria**:
- Wyszukiwarka zwraca wyniki po polskiej treści.
- `npm run website:build` przechodzi z `onBrokenLinks: 'throw'` dla obu locale.

### Story 7.1: Indeks wyszukiwania dla locale polskiego

**User Story**: Jako czytelnik po polsku, chcę wyszukiwać dokumentację po polskich słowach kluczowych.

**Source**: `@easyops-cn/docusaurus-search-local` w `docusaurus.config.ts`.

**Acceptance Criteria**:
- [ ] GIVEN locale `pl` WHEN czytelnik wpisuje polskie hasło (np. „instalacja”) THEN wyszukiwarka zwraca trafne strony PL.
- [ ] GIVEN locale `en` WHEN wyszukiwanie THEN indeks EN nie miesza się z PL (osobne indeksy per locale).
- [ ] GIVEN build produkcyjny WHEN deploy THEN search assets dla `pl` są generowane.

**Priority**: High

### Story 7.2: Build i walidacja linków dla obu języków

**User Story**: Jako maintainer, chcę, aby CI łapał zepsute linki w polskiej dokumentacji tak samo jak w angielskiej.

**Source**: `onBrokenLinks: 'throw'`; `npm run website:build` w project stack.

**Acceptance Criteria**:
- [ ] GIVEN pełny zestaw tłumaczeń PL WHEN `npm run website:build` THEN build kończy się sukcesem.
- [ ] GIVEN polski link wewnętrzny do nieistniejącej strony WHEN build THEN build failuje z czytelnym komunikatem.
- [ ] GIVEN quality commands w README/stack WHEN opiekun uruchamia pipeline THEN build website jest wymagany po zmianach i18n.

**Priority**: Critical

### Story 7.3: Spójność sidebar i nawigacji między locale

**User Story**: Jako czytelnik, chcę, aby struktura menu docs była taka sama w EN i PL, z polskimi tytułami stron.

**Source**: `website/sidebars.ts`; frontmatter `title` w plikach MD.

**Acceptance Criteria**:
- [ ] GIVEN sidebar WHEN locale `pl` THEN ta sama hierarchia kategorii co EN z polskimi tytułami (z frontmatter lub tłumaczeń).
- [ ] GIVEN sortowanie skilli alfabetyczne WHEN locale `pl` THEN sortowanie według polskiego tytułu lub ustalonej reguły (udokumentowanej).
- [ ] GIVEN breadcrumbs WHEN locale `pl` THEN etykiety ścieżki są po polsku.

**Priority**: Medium

---

## Epic 8: Proces utrzymania tłumaczeń

**Business Description**: ~85k słów to jednorazowy koszt tłumaczenia plus ciągły koszt utrzymania przy każdej zmianie angielskiej docs. Bez procesu polska wersja szybko stanie się nieaktualna.

**Success Criteria**:
- Istnieje glosariusz i zasady tłumaczenia.
- CI lub check manualny wykrywa rozjazd EN vs PL po zmianach w docs.

### Story 8.1: Glosariusz i przewodnik stylu tłumaczeń

**User Story**: Jako tłumacz (osoba lub agent), chcę spójnych reguł terminologii, aby cała strona brzmiała jednolicie.

**Source**: `website/docs/reference/glossary.md`; decyzja Gate 0 — identyfikatory po EN.

**Acceptance Criteria**:
- [ ] GIVEN glosariusz PL WHEN zawiera min. 30 kluczowych terminów frameworka THEN każdy ma zatwierdzony polski odpowiednik i kontekst użycia.
- [ ] GIVEN reguła „identyfikatory po angielsku” WHEN tłumacz pracuje nad promptami/skillami THEN nie tłumaczy `eversis-*`, nazw plików, env vars.
- [ ] GIVEN nowy termin WHEN pojawia się w EN docs THEN proces opisuje, jak dodać go do glosariusza.

**Priority**: High

### Story 8.2: Wykrywanie rozjazdu tłumaczeń (drift) w CI

**User Story**: Jako opiekun docs, chcę automatycznego sygnału, gdy angielska strona się zmieniła, a polska nie.

**Source**: Brak obecnego mechanizmu; analogia `sync:website-docs:check`, `website:changelog:check`.

**Acceptance Criteria**:
- [ ] GIVEN zmiana w pliku EN docs WHEN brak odpowiadającej zmiany mtime/hash PL THEN check raportuje listę stron do aktualizacji (minimalnie: obecność pliku PL dla każdego EN).
- [ ] GIVEN pełna synchronizacja WHEN check THEN przechodzi w pipeline jakości repozytorium.
- [ ] GIVEN dokumentacja WHEN opiekun aktualizuje EN THEN wie, że PR powinien obejmować PL lub ticket follow-up.

**Priority**: High

---

## Dependencies

| Task | Depends On | Type | Notes |
|------|-----------|------|-------|
| Story 1.2 | Story 1.1 | Blocked by | Przełącznik wymaga włączonego locale `pl` |
| Story 2.1 | Story 1.1 | Blocked by | Tłumaczenia theme wymagają i18n |
| Story 2.2 | Story 1.1 | Blocked by | Landing page PL wymaga locale |
| Story 3.x–4.x | Story 1.1, 8.1 | Blocked by | Treść docs PL w i18n; glosariusz przed masowym tłumaczeniem referencji |
| Story 5.2 | Story 5.1 | Blocked by | Strategia sync przed masowym tłumaczeniem promptów |
| Story 5.3 | Story 5.1, 5.2 | Blocked by | Check wymaga ustalonej lokalizacji plików PL |
| Story 6.2 | Story 6.1 | Blocked by | Proces sync przed pełnym tłumaczeniem changelog |
| Story 7.1 | Story 3.x–6.x (częściowo) | Related to | Search sensowne dopiero gdy jest treść PL |
| Story 7.2 | Wszystkie story treści | Blocked by | Pełny build PL na końcu fali tłumaczeń |
| Story 4.2 | Story 5.2 | Related to | Linki agent → prompt powinny iść do PL prompt pages |
| Epic 8 | Epic 1 | Related to | Utrzymanie równolegle do delivery treści |

## Assumptions

| # | Assumption | Confidence | Impact if Wrong |
|---|-----------|------------|-----------------|
| 1 | Polskie pliki docs żyją w `website/i18n/pl/`, angielskie w `website/docs/` — generator promptów nie dotyka i18n | High | Trzeba przeprojektować Epic 5 |
| 2 | Tłumaczenie wykonuje zespół wewnętrzny lub agent w iteracjach; ~85k słów to wielo-PR-owa dostawa | High | Harmonogram i koszt rosną |
| 3 | Automatyczne tłumaczenie maszynowe wymaga review human/agent przed merge | Medium | Jakość PL może być niska bez review |
| 4 | Locale dropdown wystarczy; auto-detect z przeglądarki nie jest wymagany w v1 | Medium | Story 1.2 rozszerzyć o `localeDetection` |
| 5 | Root CHANGELOG pozostaje po angielsku; PL changelog to osobny artefakt utrzymywany ręcznie/półautomatycznie | High | Story 6.1 wymaga innego modelu |

## Out of Scope

Items explicitly excluded from this task breakdown:
- Tłumaczenie `.ai/prompts/`, `.ai/skills/`, `.cursor/rules/` — SSOT agentów pozostaje EN
- Inne locale niż `pl`
- Tłumaczenie root README, CHANGELOG SSOT (tylko strona www changelog)
- Zmiana treści merytorycznej lub reorganizacja docs — wyłącznie język

## Open Questions for Stakeholders

| # | Question | Context | Impact |
|---|----------|---------|--------|
| 1 | Kto jest właścicielem utrzymania PL (osoba/rotacja)? | Epic 8 — bez ownera drift jest pewny | Brak odpowiedzialności za aktualizacje |
| 2 | Czy włączyć `localeDetection` (auto PL dla przeglądarki PL)? | Story 1.1 / Open question z brief | UX pierwszej wizyty |
| 3 | Czy tłumaczenie masowe robi agent w jednym epicie, czy fale per sekcja? | ~85k słów | Plan sprintów i review |

## Effort Snapshot (informacyjny, nie story points)

| Obszar | Pliki | ~Słowa | Uwagi |
|--------|-------|--------|-------|
| Przewodniki | 27 | 17k | Ręczne/kuratorskie |
| Referencja kuratorska | 84 | 43k | Skills/agents/integrations/glossary |
| Prompty (generated EN) | 29 | 25k | Wymaga Story 5.1 + i18n mirror |
| Changelog | 1 | 7,5k | Sync workflow |
| UI (homepage + theme) | 11 komponentów | 3k | React + code.json |
| **Razem** | **~140+ UI** | **~85k** | Wieloetapowa dostawa zalecana |

## Suggested Delivery Phases (dla planowania implementacji — poza Gate 1)

1. **Faza A (Critical path)**: Epic 1 + 2 + Story 5.1 + Story 7.2 (szkielet PL)
2. **Faza B (Onboarding)**: Epic 3 + Story 8.1 (glosariusz)
3. **Faza C (Reference)**: Epic 4 + Epic 5 (reszta)
4. **Faza D (Changelog + polish)**: Epic 6 + Epic 7 (search, sidebar) + Epic 8 (CI drift)
