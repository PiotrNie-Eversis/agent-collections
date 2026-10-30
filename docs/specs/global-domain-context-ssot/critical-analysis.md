# Analiza krytyczna — `global-domain-context-ssot-v2.md`

## Metadane

| Pole | Wartość |
|---|---|
| Źródło | Google Drive: `AI_agents/Agent Collections/global-domain-context-ssot-v2.md` |
| Analiza wykonana | 2026-08-24 |
| Kontekst | Dokument opisuje research + plan (v2, z dodaną Fazą 8) dla mechanizmu trwałej, współdzielonej pamięci domenowej (SSOT) w topologii multi-repo enterprise (GitLab Group `DAWIS` grupujący projekty `EOG`/`EOP`/`WUP`), w ramach frameworka agent-collections |
| Powiązanie | Kandydat na podzadanie epika [DHI-515](https://eversis.atlassian.net/browse/DHI-515) — zob. `docs/specs/dhi-515/dhi-515.research.md` |
| Gate 0 | Skipped — materiał jednoznaczny (pojedynczy dokument, jasno zakresowany, brak potrzeby dodatkowego brief'u intencji) |

## Streszczenie dokumentu

Dokument identyfikuje realną lukę: framework nie ma warstwy dla wiedzy faktograficznej o aplikacji (business rules, konwencje, decyzje architektoniczne), odrębnej od pamięci per-zadanie (`docs/specs/`) i wiedzy proceduralnej (`.ai/skills/`). Proponuje nową kategorię `.ai/context/` + `docs/context/`, mechanizm MCP discovery (`eversis_context_list/get/search`), obligatoryjny seed z Confluence, oraz — w nowej Fazie 8 — rozwiązanie problemu strukturalnego: GitLab Group nie przechowuje plików, więc potrzebne są dwa dedykowane projekty (`agent-collections-config`, `domain-context`) dostarczane do repozytoriów konsumenckich przez `git subtree --squash`.

## Mocne strony

1. **Trafna diagnoza luki** — porównanie z `.cursor/rules/*.mdc` (4 statyczne tryby), Auto Memory Claude Code (lokalna, niecommitowana) i limitem ~200 linii `CLAUDE.md` jest konkretne i weryfikowalne, nie ogólnikowe.
2. **Faza 8 poprawnie identyfikuje realny błąd projektowy** — GitLab Group rzeczywiście nie jest repozytorium i nie przechowuje plików. To krytyczny blocker, który w wersji 1 dokumentu (bez Fazy 8) skutkowałby planem niemożliwym do fizycznej realizacji. Naprawa (dwa dedykowane projekty) jest trafna.
3. **Rozdzielenie config vs domain-context wg cyklu życia** — uzasadnienie (różne uprawnienia, czystszy review, różna częstotliwość zmian) jest solidne i zgodne z dobrą praktyką repo-splitting.
4. **Świadomy wybór `subtree --squash` zamiast submodułu** — uzasadnienie (submoduł wymaga jawnego `--recurse-submodules`, inaczej cichy pusty katalog) trafnie adresuje Wymaganie 9 i jest zgodne ze znanym zachowaniem gita.
5. **Dobra higiena spec-a** — frontmatter, Definition of Done, Otwarte pytania, Ryzyka jako osobna sekcja na każdym etapie.

## Krytyczne luki i ryzyka

1. **Brak ścieżki powrotnej (write-path) dla promocji wiedzy — niespójność z Fazą 7.**
   Faza 5 opisuje, że agent w `EOG` wykrywa wzorzec i proponuje promocję do SSOT; Faza 7 zakłada, że po zatwierdzeniu "wiedza jest dostępna w kolejnej sesji zarówno w EOG, jak i na poziomie DAWIS oraz w innym repo (WUP), **bez ręcznej synchronizacji plików**". To sprzeczne z mechanizmem wybranym w Fazie 8: `git subtree --squash` ma dobrze znany, bolesny `subtree push` (historia squashowana, fan-out do wielu repo-konsumentów wymaga per-repo PR). Dokument specyfikuje tylko ścieżkę odczytu (pull), nie ścieżkę zapisu (promocja lokalna → `domain-context` → redystrybucja do EOP/WUP). To jest największa dziura w planie — bez niej Faza 5 i Faza 7 nie są wykonalne tak, jak opisano.

2. **Wersjonowanie SSOT względem kodu pozostaje otwarte, mimo że plan już zakłada implementację.** Pytanie "jak wersjonować wiedzę SSOT względem wersji kodu" jest w sekcji Otwarte pytania, ale Fazy 1–8 (w tym Definition of Done) nie blokują się na jego rozstrzygnięciu. To ryzyko sekwencjonowania: zespół może zacząć budować mechanizm dostawy (Faza 8) zanim ustali, czy wiedza jest "latest" czy pinowana — zmiana odpowiedzi później oznacza przeróbkę CI i subtree flow.

3. **Konflikt scalania po fizycznym wylądowaniu subtree w repo konsumenckim nie jest zdefiniowany.** Faza 1 opisuje hierarchię project > global na poziomie *logicznym* (dwa osobne indeksy). Ale po `subtree pull --squash`, katalog `domain-context` fizycznie ląduje **wewnątrz** repo `EOG`, obok natywnych plików projektowych. Dokument nie precyzuje konwencji ścieżek/metadanych, po której `eversis_context_get` odróżni "to przyszło z subtree (global)" od "to jest natywne dla EOG (project)" — bez tego algorytm nadpisywania z Fazy 1 nie ma jak działać w praktyce.

4. **Próg staleness w CI to placeholder bez uzasadnienia i bez działania naprawczego.** "np. 14 dni" nie jest poparte żadną analizą; a jedynym skutkiem przekroczenia progu jest "ostrzeżenie w pipeline". Skoro cały problem, który Faza 8 ma rozwiązać, to *cicha degradacja kontekstu* — ostrzeżenie, które nikt nie czyta, odtwarza dokładnie to ryzyko, przed którym dokument przestrzega w Wymaganiu 9.

5. **Import z Confluence jako obligatoryjny blocker instalacji jest ryzykiem adopcyjnym.** Nowy projekt bez istniejącej przestrzeni Confluence (np. greenfield) nie może w ogóle zainstalować frameworka wg Fazy 4 ("brak flagi kończy instalację błędem"). Brak trybu "start pusty, zaimportuj później".

6. **Potencjalna kolizja z istniejącą konwencją `docs/context/<project>/task-baseline.md`.** W repo `agent-collections` już istnieje i jest aktywnie używany `docs/context/agent-collections/task-baseline.md` (indeks epik/story, odświeżany po Jira push wg `eversis-jira-task-formatting`). Dokument SSOT-v2 proponuje `docs/context/` jako **nową**, równoległą kategorię (wiedza domenowa, nie baseline zadań) — cel jest inny, ale nazwa katalogu się pokrywa. Bez jawnego rozgraniczenia (np. `docs/context/<project>/knowledge/` vs `docs/context/<project>/task-baseline.md`) rośnie ryzyko pomyłki narzędziowej (agent czytający zły plik) i konfliktu ścieżek przy subtree pull.

7. **Brak planu wycofania (rollback) błędnie zapromowanej wiedzy.** Jeśli wpis `source: agent-discovered` okaże się błędny po tym, jak trafił przez subtree do EOG/EOP/WUP, nie ma opisanej procedury odwołania — przy squashowanej historii subtree "revert" nie jest trywialny.

8. **Kontrola przed wyciekiem sekretów opiera się wyłącznie na human gate.** Sekcja Bezpieczeństwo słusznie flaguje ryzyko, ale jedynym mechanizmem jest przegląd człowieka przy promocji — brak choćby lekkiego automatycznego skanu (pre-commit / CI) jako drugiej linii obrony, mimo że human-only review jest znanym słabym punktem w innych kontekstach (code review, ticket comments).

## Ocena ogólna

Dokument jest solidny na poziomie diagnozy problemu i pierwszej warstwy rozwiązania (struktura katalogów, MCP tools, obligatoryjny Confluence seed) oraz poprawnie łata krytyczny błąd strukturalny z wersji 1 (Faza 8 — GitLab Group nie przechowuje plików). Największym ryzykiem dla wykonalności jest **niedookreślona ścieżka zapisu** (promocja wiedzy → redystrybucja subtree) — to blokuje dokładnie ten scenariusz testowy, który dokument sam sobie stawia jako kryterium akceptacji Fazy 7. Rekomendacja: przed przejściem do Implement, doprecyzować w osobnym Research/Plan (lub jako Faza 9) mechanizm write-back dla `domain-context`, konwencję odróżniania project/global po subtree pull, oraz rozstrzygnąć pytanie o wersjonowanie — reszta (Fazy 1–4, 6) jest gotowa do zaplanowania per-story.
