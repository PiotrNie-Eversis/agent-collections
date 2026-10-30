# Plan Review (iteracja 2): ac-2.plan.md

**Recenzowany plan:** `docs/specs/ac-2/ac-2.plan.md` (rewizja z 2026-09-21, 353 linie — poprzednio 290)
**Poprzednie review:** `docs/specs/ac-2/ac-2.plan-review.md` (iteracja 1: 5 blockerów, 5 warningów, 3 sugestie)
**Data review:** 2026-09-21
**Werdykt:** `REVISIONS NEEDED` — zakres wąski, wyłącznie edycje w miejscu, bez przeplanowania

**Podsumowanie:** 13/13 findingów iteracji 1 domkniętych · 1 nowy blocker · 3 nowe warningi · 2 sugestie

Wszystkie findingi ponownie zweryfikowane względem dostarczonego archiwum źródeł (`.ai/`, `mcp/eversis-collections-mcp/src/`, `docs/`). Numeracja linii odnosi się do tego archiwum i do zrewidowanego planu.

## Status findingów z iteracji 1

| # | Finding | Status | Dowód w zrewidowanym planie |
| --- | --- | --- | --- |
| B1 | Task 2.2 duplikuje istniejący `eversis-import-confluence-knowledge` | ✅ Domknięty | Task 2.2 przepisany na `[MODIFY]`; pytanie otwarte 3 jawnie oznaczone jako źle sformułowane i poprawione; „brand-new bootstrap skill" na liście „nie dodawać" (l. 23); wpisane też do Ulepszeń (l. 338) |
| B2 | Kontrakt „four-line" w 5 plikach, plan dotykał 2 | ⚠️ Domknięty, ale nadkorygowany | Wszystkie 5 plików w „To Be Modified" i w Tasku 2.1; niezmiennik w Kontekście technicznym (l. 116) z ostrzeżeniem, że sam `grep 'four-line'` nie znajduje wariantu „exactly four". Patrz **W6** i **W7** |
| B3 | Dwukolumnowy parser `INDEX.md` cicho gubi wiersze | ✅ Domknięty | Zakaz na liście „nie dodawać" (l. 26) + pełne uzasadnienie z regexem i wskazaniem `upsertFrontmatterField()` jako właściwego miejsca (l. 117); wymuszone w DoD Taska 2.2 |
| B4 | Linia `Audit` bez nośnika danych | ✅ Domknięty | Usunięta z Fazy 2, pytanie otwarte 4 rozstrzygnięte na odłożenie, przeniesiona do Fazy 5 w Ulepszeniach (l. 333), potwierdzone z reporterem |
| B5 | `getContext()` nie rozwiązuje `<domena>/<temat>.md` | ✅ Domknięty | Nowy Task 1.2; niezmiennik ścieżki w Kontekście technicznym (l. 118); kryterium akceptacji (l. 321). Patrz jednak **B6** — naprawa jest połowiczna |
| W1 | `Changelog` nie nadaje się na checkpoint; brak protokołu wznowienia | ✅ Domknięty | Podformat `CHECKPOINT:` + wartość `Resume` na `Flow`; pytanie otwarte 5 dodane i rozstrzygnięte; Task 3.1 jawnie wiąże się z Taskiem 2.1 |
| W2 | `docs/context/README.md` nie zna `INDEX.md` | ✅ Domknięty | Nowy Task 1.3 |
| W3 | Task 2.1 nietestowalny w tym repo | ✅ Domknięty | Fixture w Weryfikacji Fazy 2 + Wzorce testowania (l. 135) + kryterium akceptacji (l. 327) |
| W4 | Zła ścieżka w Kontekście technicznym | ✅ Domknięty | `.ai/skills/eversis-orchestrating-implementation/SKILL.md` (l. 88) |
| W5 | Brak rollbacku adapterów | ✅ Domknięty | Wskazówki Fazy 4, punkt (b) |
| S1 | Nie zadeklarowany Full Flow | ✅ Domknięty | Bramki ludzkie, l. 342 |
| S2 | Zły wzorzec do naśladowania dla Taska 2.2 | ✅ Nieaktualny | Rozwiązany przez B1 — nie ma już nowego skilla do modelowania |
| S3 | Pesymizm kroku 6 sprzeczny z researchem | ✅ Domknięty | Wpleciony w opis i DoD Taska 2.2 |

Jakość rewizji jest wysoka i nietypowo uczciwa: plan nie tylko wprowadził poprawki, ale zapisał **dlaczego** pierwotne przesłanki były błędne — w tym to, że research ponownie wyprowadził decyzję DHI-630 (l. 38) i że pytanie otwarte 3 było źle postawione (l. 100). To jest dokładnie ta warstwa, która zapobiega trzeciemu odkrywaniu tego samego. Poniższe findingi to konsekwencje samej rewizji, nie powrót starych.

## BLOCKERS

### B6: Task 1.2 ujednolica ścieżkę, ale nie schemat frontmatteru — co zamienia niewidoczność na ryzyko błędnego `Delete`

Task 1.2 poprawnie sprowadza `eversis-import-confluence-knowledge` do `<component>/index.md`. Ale dwie ścieżki zapisu do `docs/context/` piszą **różne schematy frontmatteru**, a Task 1.2 tego nie dotyka:

| Pole | `eversis-promote-domain-knowledge` (krok 4) | `eversis-import-confluence-knowledge` (krok 4) |
| ---- | ------------------------------------------ | ---------------------------------------------- |
| `scope` | ✅ | ✅ |
| `source` | `agent-discovered` | `confluence` |
| `last_updated` | ✅ | ✅ |
| `tags` | ✅ | ✅ |
| `confluence_url` | ✅ (`null`) | ✅ |
| **`code_paths`** | ✅ | ❌ **brak** |
| **`related_specs`** | ✅ | ❌ **brak** |

`eversis-audit-domain-knowledge` krok 1 iteruje dokładnie po `docs/context/<project>/<component>/index.md` i opiera swoje dwa najmocniejsze sygnały właśnie na tych dwóch brakujących polach: „Check whether every path in `code_paths` still exists in the repo. Any that don't are a strong signal toward `Update` (if some paths are gone) or **`Delete` (if all are gone)**", oraz skanowanie `related_specs` pod `Consolidate`. Krok 3 (kontrola under-triggeringu) działa wyłącznie „for components with active `code_paths`".

Kluczowe: **przed** Taskiem 1.2 pliki z importu leżały pod `<domena>/<temat>.md`, więc były niewidoczne nie tylko dla `getContext()`, ale i dla iteracji audytu. **Po** Tasku 1.2 lądują dokładnie tam, gdzie audyt patrzy — stają się widoczne, wciąż nie mając pól, których audyt potrzebuje. Dla komponentu zaimportowanego z Confluence zbiór „wszystkich ścieżek z `code_paths`, które nadal istnieją" jest pusty w sensie próżnym, co przy dosłownym czytaniu reguły jest sygnałem `Delete` — dla wiedzy, która właśnie została zaimportowana i nigdy nie była nieaktualna. Do tego `last_consulted` jest z definicji nieustawione (`touchLastConsulted()` odpala się tylko z `getContext()`), co skill wymienia jako drugi sygnał w stronę `Replace`/`Delete`.

Task 1.2 rozwiązuje więc połowę B5: treść staje się **osiągalna**, ale jednocześnie staje się **audytowalna źle**. Plan jawnie deklaruje, że `eversis-audit-domain-knowledge` jest „reused unchanged, not otherwise touched by this plan" (l. 72) — co przy Tasku 1.2 przestaje być bezpieczne założenie.

**Działanie** (małe, dwa punkty):
1. Dodać do DoD Taska 1.2: krok 4 `eversis-import-confluence-knowledge` emituje `code_paths: []` i `related_specs: []` jako jawne, obecne-ale-puste pola (nie pominięte), a treść kroku 4 instruuje wypełnienie `code_paths`, gdy sekcja As-Is Packa wskazuje moduły kodu.
2. Dodać jedno zdanie do `eversis-audit-domain-knowledge` krok 1: puste lub nieobecne `code_paths` przy `source: confluence` oznacza „jeszcze niezmapowane na kod", nigdy sygnał `Delete` — właściwym wynikiem jest `Update` (domapować ścieżki). To otwiera ten skill w zakresie tego planu na jedno zdanie; alternatywnie ograniczyć się do punktu 1 i zapisać ryzyko jako jawnie akceptowane do Fazy 5.

## WARNINGS

### W6: DoD #1 Taska 2.1 jest niewykonalne i jest regresją SSOT

Pięć plików kontraktu nie jest jednorodne — dzieli się na dwie warstwy, co rewizja potraktowała jednym wymogiem „identycznie we wszystkich pięciu":

**Warstwa A — definiują blok (potrzebują linii `Context` i wartości `Resume`):**
- `engineering-manager.md:13-23` — dosłowny blok w bloku kodu, enum `Flow:` w linii 17, plus „Optional fifth line: `- **Reason:** …`"
- `eversis-orchestrating-implementation/SKILL.md:86-98` — dosłowny blok, enum `Flow:` w linii 86, „exactly four bullet lines" w 96, „Optional fifth line" w 97

**Warstwa B — tylko odsyłają do liczby, jawnie delegując definicję:**
- `spec-driven-development.md:77` — „Output the **Implement readiness** four-line block first **(see `engineering-manager.md`)**"
- `prompts/public/eversis-implement.md:82` — „the **exact four-line** Implement readiness block **from orchestration skill Step 1**… See **Readiness output contract** in the skill"
- `orchestration/README.md:26` — jeden punkt w numerowanej liście-indeksie: „Implement readiness four-line block as first content on Implement entry"

Sprawdzone bezpośrednio: ciąg `Flow:` z enumem wartości występuje **tylko w 2 z 5 plików** (`engineering-manager.md:17`, `SKILL.md:86`). W trzech plikach warstwy B nie ma czego rozszerzać o `Resume` — nie wymieniają wartości `Flow` w ogóle.

DoD #1 („Wszystkie pięć plików pokazuje tę samą opcjonalną linię `Context` i tę samą wartość `Resume` dodaną do `Flow`, sformułowane identycznie między plikami") jest więc albo niewykonalne, albo — jeśli implementer weźmie je dosłownie — wymusza **zduplikowanie specyfikacji bloku do trzech plików, które dziś świadomie ją delegują**. To zniszczyłoby istniejącą strukturę jedna-definicja/wiele-referencji i stworzyłoby dokładnie ten problem rozproszonej asercji, którego wykrycie było treścią B2. W planie, którego całą przesłanką jest SSOT, byłaby to regresja wprowadzona przez poprawkę.

**Działanie:** rozbić DoD #1 na dwie warstwy:
- Warstwa A (2 pliki): dodać opcjonalną linię `Context` do dosłownego bloku i wartość `Resume` do enumu `Flow`, identycznie w obu.
- Warstwa B (3 pliki): **tylko** zmienić sformułowanie liczby („four-line" / „exact four-line" → np. „readiness block (four required lines plus optional signals)"), zachowując istniejącą delegację do `engineering-manager.md` / Step 1 skilla. Nie dodawać tam definicji bloku.

To jest zresztą tańsze niż wersja obecna i ściślej odpowiada temu, co B2 faktycznie stwierdzało: asercją rozproszoną na 5 plików jest **liczba linii**, a nie cała specyfikacja bloku.

### W7: Już istniejąca opcjonalna piąta linia `Reason` jest nieuwzględniona — i częściowo łagodzi B2

Oba pliki warstwy A zawierają dziś zdanie: „Optional fifth line: `- **Reason:** …`" (`engineering-manager.md:23`, `eversis-orchestrating-implementation/SKILL.md:97`). Dwie konsekwencje, jedna na korzyść planu, jedna nie:

**Na korzyść — korekta mojego własnego findingu z iteracji 1.** Kontrakt nigdy nie był domknięty na czterech liniach w sensie absolutnym; już dziś obowiązuje „cztery wymagane + jedna opcjonalna". B2 był więc łagodniejszy, niż go opisałem: plan nie otwiera zamkniętego kontraktu, tylko dodaje drugi i trzeci element do istniejącego już mechanizmu rozszerzeń. Ryzyko sprzeczności wewnątrz `.ai/` pozostaje realne (sformułowania „exact four-line" w plikach warstwy B), ale kategoria zmiany jest mniejsza. Odnotowuję to jako korektę, nie jako obronę pierwotnej oceny.

**Nie na korzyść.** Dodanie linii `Context` czyni sformułowanie „Optional **fifth** line" porządkowo błędnym w tych samych dwóch plikach — `Context` będzie piątą albo szóstą linią w zależności od obecności `Reason`, a `Reason` przestaje być jednoznacznie „piąta". Task 2.1 nie wspomina o `Reason` w ogóle: ani w opisie, ani w DoD, ani we Wskazówkach. To ta sama klasa pominięcia co B2, o jeden poziom niżej — asercja o pozycji, nie o liczbie.

Dodatkowo Stop Rule Taska 2.1 („więcej niż 2 nowe opcjonalne dodatki do istniejącego kształtu bloku") liczy od zera, ignorując, że jeden opcjonalny dodatek już istnieje. Przy dosłownym odczycie próg jest o jeden za wysoki.

**Działanie:** dodać do DoD Taska 2.1: „sformułowanie o `Reason` w `engineering-manager.md` i `eversis-orchestrating-implementation/SKILL.md` nie odwołuje się już do stałej pozycji porządkowej (»fifth«) — opcjonalne linie są opisane jako zbiór (`Reason`, `Context`), nie jako numerowana pozycja". Przeformułować Stop Rule na „więcej niż 2 nowe opcjonalne linie **ponad istniejącą** `Reason`".

### W8: Trzy nieaktualne odwołania do numeru taska (off-by-one po przenumerowaniu)

Zrewidowany plan wskazuje na **Task 1.3** jako ten, który naprawia ścieżkę `eversis-import-confluence-knowledge`, w trzech miejscach:

- l. 61: „Task 2.2 builds on Phase 1's **Task 1.3**, not on the file's original state"
- l. 118: „**Task 1.3** fixes the one skill in this plan's blast radius that violated this"
- l. 145: „This is the correct structural model **Task 1.3** brings `eversis-import-confluence-knowledge` into line with"

Faktycznie robi to **Task 1.2**; Task 1.3 dotyczy `docs/context/README.md`. Poprawnie odwołują się tylko dwa miejsca: linia Files w Tasku 2.2 („path shape already corrected by Task 1.2") i Wskazówki Taska 1.2. Wygląda to na ślad wstawienia nowego taska jako 1.3, a potem przenumerowania — stosunek 3:2 na korzyść błędnej wersji.

To nie jest kosmetyka: linia 61 jest jedynym zdaniem deklarującym **zależność kolejnościową między fazami**, a implementer wchodzący przez nią otworzy `docs/context/README.md` w poszukiwaniu naprawy ścieżki skilla.

**Działanie:** zamienić `Task 1.3` → `Task 1.2` w liniach 61, 118, 145.

## SUGGESTIONS

### S4: DoD #3 Taska 2.1 przestało być sprawdzalne mechanicznie

Poprzednio kryterium brzmiało „grep zwraca zero". Teraz: „`grep -rniE 'four[- ]line|exactly four' .ai/` zwraca zero **normatywnych asercji**, że blok jest zamknięty na stałych czterech liniach (wzmianki o czterech *wymaganych* liniach… są w porządku)". Rozróżnienie jest merytorycznie słuszne — cztery linie pozostają wymagane — ale zamienia sprawdzenie binarne w ocenę uznaniową, wykonywaną przez tego samego agenta, który właśnie pisał te sformułowania.

**Propozycja:** zamienić na kryterium przeliczalne: wypisać pięć oczekiwanych trafień z docelowym sformułowaniem per plik i wymagać, by grep zwrócił dokładnie te pięć, każde w zapisanej, docelowej formie. Przy rozbiciu z W6 ta lista jest krótka i naturalnie wynika z podziału na warstwy.

### S5: Wyliczyć ścieżki zapisu objęte celem Fazy 1

Cel Fazy 1 mówi „make **every existing** write path into `docs/context/` emit a file shape the router can actually resolve". Sprawdzone: zapisujące są `eversis-promote-domain-knowledge` (zgodny), `eversis-import-confluence-knowledge` (naprawiany Taskiem 1.2) i `eversis-audit-domain-knowledge` (edytuje w miejscu, usuwa wiersz `INDEX.md` przy `Delete`). Twierdzenie jest więc prawdziwe — ale „every" bez listy nie daje przyszłemu skillowi żadnego punktu odniesienia.

**Propozycja:** dopisać w Kontekście technicznym, obok niezmiennika ścieżki (l. 118), jedno zdanie: „Ścieżki zapisu objęte tym niezmiennikiem na moment AC-2: `eversis-promote-domain-knowledge` (krok 4), `eversis-import-confluence-knowledge` (krok 4), `eversis-audit-domain-knowledge` (edycja w miejscu). Każdy nowy skill zapisujący do `docs/context/` dopisuje się do tej listy." Zamienia to niezmiennik w rejestr, który da się sprawdzić, zamiast stwierdzenia ilościowego, które starzeje się cicho.

### S6: Kolejność w diagramie vs numeracja tasków

Diagram (l. 55-58) wymienia „`domain-context.md` + `docs/context/README.md`", podczas gdy taski numerują je odwrotnie (1.3 = `README.md`, 1.4 = `domain-context.md`). Trywialne, ale przy W8 warto przejrzeć wszystkie odwołania krzyżowe w jednym przebiegu.

## Werdykt

`REVISIONS NEEDED` — ale kategoria jest zupełnie inna niż w iteracji 1.

Iteracja 1 kwestionowała przesłanki: plan zakładał, że mechanizm nie istnieje (istniał), że kontrakt żyje w dwóch plikach (w pięciu) i że sygnał `Audit` ma skąd czerpać dane (nie miał). Ta rewizja te przesłanki naprawiła, a co ważniejsze — **zapisała, dlaczego były błędne**, wraz z ustaleniem, że research ponownie wyprowadził już podjętą decyzję DHI-630. Architektura, etapowanie i dyscyplina zakresowa są teraz spójne i weryfikowalne.

Pozostałe findingi to skutki uboczne samej poprawki, nie nawroty:

1. **B6** — ujednolicenie ścieżki bez ujednolicenia frontmatteru zamienia cichą niewidoczność w ryzyko błędnej klasyfikacji `Delete` w audycie. Wymaga decyzji, bo dotyka skilla zadeklarowanego jako nietykany.
2. **W6** — jednolity wymóg „identycznie w pięciu plikach" jest niewykonalny dla trzech z nich i groziłby zduplikowaniem definicji bloku, czyli regresją SSOT.
3. **W7** — istniejąca opcjonalna linia `Reason` jest nieuwzględniona; łagodzi to B2 (odnotowane jako korekta iteracji 1), ale zostawia dwie asercje porządkowe do poprawienia.
4. **W8** — trzy odwołania wskazują Task 1.3 tam, gdzie chodzi o Task 1.2, w tym jedyne zdanie o zależności między fazami.

Wszystkie cztery to edycje w miejscu w samym dokumentie planu (plus jedno zdanie w `eversis-audit-domain-knowledge`, jeśli B6 zostanie rozwiązane opcją pełną). Żadna nie wymaga przeplanowania fazy ani zmiany dekompozycji tasków. Po ich wprowadzeniu plan jest gotowy do zatwierdzenia.
