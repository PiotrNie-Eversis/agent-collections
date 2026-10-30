# Analiza logiczna: ac-2.plan.md

**Analizowany plan:** `docs/specs/ac-2/ac-2.plan.md` (rewizja po iteracji 2, 359 linii)
**Data:** 2026-09-21
**Zakres:** spójność wewnętrzna, poprawność wnioskowania, zależności, wykonalność kryteriów. **Nie** ponowny audyt faktów o kodzie — te zweryfikowałem w iteracjach 1-2.

**Podsumowanie:** 1 sprzeczność wewnętrzna o dużym zasięgu · 1 błąd kategorialny w projekcie · 1 zależność cykliczna · 2 niewykonalne kryteria · 1 nierozstrzygnięty konflikt reguł · 2 drobne

Wszystkie 4 findingi iteracji 2 (B6, W6, W7, W8) są domknięte w treści tasków — potwierdzone. Poniższe to defekty wnioskowania, w większości powstałe przy wprowadzaniu tych właśnie poprawek.

---

## 1. Sprzeczność wewnętrzna: poprawka W6 została zastosowana w 2 miejscach i pominięta w 6

To jest ten sam błąd, którego wykrycie było treścią B2 — popełniony przez dokument, który o nim traktuje.

Task 2.1 i sekcja „To Be Modified" (l. 85-86) opisują **model dwuwarstwowy**: Layer A (2 pliki) dostaje linię `Context` i wartość `Resume`, Layer B (3 pliki) dostaje **wyłącznie** przeredagowanie sformułowania o liczbie linii, „and add no new content there".

Sześć innych miejsc nadal twierdzi model sprzed poprawki:

| Linia | Sekcja | Treść |
| ----- | ------ | ----- |
| 18 | **Success Measure** | „…surfaces an empty-INDEX signal and a `Resume` path…, **identically across all five files** that assert the block's contract" |
| 38 | Proposed Solution, Faza 2 | „…now correctly extended **across all five files** that assert its contract, not two" |
| 40 | Proposed Solution, Faza 3 | „…since both changes **touch the same five files**" |
| 74 | Already Implemented | „**all five to be extended identically** with 2 new optional additions" |
| 100 | Pytanie otwarte 5 | „…one coherent change **across the same five files**" |
| 221 | Opis Fazy 2 | „it extends the readiness block's `Context` signal and new `Resume` value **across all five contract files**" |

Najpoważniejsza jest linia 18. **Success Measure jest kryterium akceptacji na poziomie WIG** — implementacja wykonana dokładnie zgodnie z Taskiem 2.1 formalnie **nie spełnia** miary sukcesu własnego planu. Druga w kolejności jest linia 74: dosłownie przepisuje wymóg, który Task 2.1 nazywa „unworkable and a regression risk".

Do tego linia 114 (Kontekst techniczny) formułuje regułę: „Every change to the block's shape must touch **all five** in the same task". Po wprowadzeniu podziału na warstwy to zdanie jest fałszywe dla zmian treści — na pięć plików rozciąga się wyłącznie asercja o liczbie linii, nie specyfikacja bloku. Zdanie jest zapisane jako niezmiennik, więc przyszły ticket weźmie je za obowiązujące i odtworzy dokładnie tę duplikację, której W6 zapobiegał.

**Dlaczego to istotne, a nie kosmetyczne**: implementer czytający plan liniowo trafia najpierw na Success Measure (l. 18), potem na opis rozwiązania (l. 38, 40), potem na l. 74, a dopiero w linii 227 na model rzeczywisty. Cztery pierwsze kontakty z tą decyzją podają wersję nieaktualną. Stosunek 6:2 na rzecz wersji błędnej.

**Działanie:** przepisać wszystkie sześć miejsc na model dwuwarstwowy, a linię 114 przeformułować na: „Asercja o liczbie linii rozciąga się na pięć plików; definicja bloku żyje wyłącznie w Layer A (`engineering-manager.md`, `eversis-orchestrating-implementation/SKILL.md`). Zmiana kształtu bloku dotyka Layer A; zmiana deklarowanej liczby linii dotyka wszystkich pięciu."

---

## 2. Błąd kategorialny: `Resume` nie jest wartością `Flow`

`Flow` odpowiada na pytanie **„jaki przepływ pracy"** — `Quick | Full | QA follow-up`. `Resume` odpowiada na pytanie **„czy to kontynuacja"**. To dwa niezależne wymiary, a plan wstawia drugi jako wartość enuma pierwszego, czyniąc je wzajemnie wykluczającymi.

Konsekwencja jest natychmiastowa i widoczna w tym samym dokumencie. Bramki ludzkie (l. 346) stanowią: „**Required flow: Full Flow.**" Sesja wznawiająca checkpoint AC-2 musiałaby wyemitować `Flow: Resume` — **tracąc deklarację `Full`**, która jest tym, co steruje zachowaniem (pułap 3 plików, wymóg walidacji planu, brak wejścia przez Quick). Sesja po wznowieniu nie ma jak zadeklarować, że nadal obowiązuje ją Full Flow. Informacja ginie dokładnie w miejscu, które według planu ma być bramką.

Drugi skutek wiąże się z podziałem na warstwy: `prompts/public/eversis-implement.md:79` zawiera tabelę routingu kluczowaną **wartościami `Flow`** (wiersz przypisujący `Flow: Full` dla żądań analizy). Nowa wartość enuma wymagałaby tam reguły routingu — ale Task 2.1 jawnie zakazuje dodawania treści do Layer B („add no new content there"). Decyzja projektowa i podział A/B są więc w konflikcie: albo `Resume` nie jest wartością `Flow`, albo Layer B musi dostać treść.

**Działanie:** rozdzielić wymiary. Albo osobna opcjonalna linia — `- **Resume:** CHECKPOINT <data> | none` — obok `Reason` i `Context` (co jest spójne z poprawką W7, bo opcjonalne dodatki są już opisane jako zbiór, nie pozycja porządkowa), albo modyfikator: `Flow: Full (resumed)`. Pierwsza opcja jest czystsza, nie rusza enuma, nie wymaga zmian routingu w Layer B i przy okazji pozwala nieść w checkpointcie datę, czego wartość enuma nie potrafi.

To jedyny finding w tej analizie dotyczący samego projektu, a nie redakcji. Reszta to spójność dokumentu.

---

## 3. Zależność cykliczna między Taskiem 2.1 (Faza 2) i Taskiem 3.1 (Faza 3)

- Task 2.1 wprowadza `Resume`, „read against a `CHECKPOINT:`-prefixed entry in the plan's `Changelog` **(the format Task 3.1, Phase 3, defines)**".
- Task 3.1 definiuje format i w DoD wymaga stwierdzenia, że „the `Resume` value on the readiness block's `Flow` line **(Task 2.1)** is how a fresh session recognizes and reads this checkpoint".

Każdy task wskazuje drugi jako źródło swojej semantyki, a fazy wykonują się 1 → 2 → 3. Na koniec Fazy 2 `Resume` referuje format, który jeszcze nie istnieje. Każda faza ma własną sekcję **Verification:**, co implikuje niezależną weryfikowalność — a Fazy 2 nie da się w tym punkcie zweryfikować sensownie: DoD Taska 2.1 nie zawiera ani jednej pozycji o formacie checkpointu, bo należy on do Taska 3.1.

Faza 4 recenzuje całość razem, więc nie jest to defekt blokujący dostawę. Jest to defekt **struktury planu**: cykl przebiega przez granicę faz, a plan nigdzie go nie odnotowuje — inaczej niż w przypadku pary 1.2 → 2.2, gdzie zależność kolejnościowa jest jawnie zapisana (l. 61).

**Działanie** (jedna z trzech, wszystkie tanie):
- przenieść wprowadzenie `Resume` z Taska 2.1 do Taska 3.1 (trafia razem z formatem, który go definiuje);
- albo zdefiniować podformat `CHECKPOINT:` w Tasku 2.1, a Taskowi 3.1 zostawić samą regułę 14;
- albo zostawić jak jest i dopisać w Fazie 2 jedno zdanie: „`Resume` jest niekompletne do końca Fazy 3; Faza 2 nie jest samodzielnie weryfikowalna w tym punkcie".

---

## 4. Kryterium DoD Taska 2.1 jest wewnętrznie sprzeczne i częściowo niewykonywalne

Linia 237 zawiera trzy problemy:

**(a) Sprzeczność z pozycją sąsiednią.** Pozycja o Layer B (l. 236) wymaga przeredagowania na „four required lines plus optional signals" **„(or equivalent)"**. Pozycja z linii 237 wymaga, by `grep -rn 'four required lines' .ai/` zwrócił „exactly the five files listed above, **once each**, in their target form". Dopuszczenie sformułowania równoważnego i wymaganie dosłownego ciągu dokładnie pięć razy wzajemnie się wykluczają. Implementer korzystający z „or equivalent" nie przejdzie grepa; implementer celujący w grepa nie ma swobody, którą daje mu pozycja wyżej.

**(b) Pierwsza połowa nie jest wykonalna jako polecenie.** Zapis `grep -rn '<pięć ścieżek połączonych |>'`-scoped check szuka tych ścieżek **jako tekstu w treści plików**, nie ogranicza zakresu przeszukiwania do tych plików. Do zawężenia zakresu służą argumenty pozycyjne albo `--include`. Pozycja jest przedstawiona jako bramka mechaniczna, a w obecnym zapisie nie da się jej uruchomić.

**(c) Dwie konkurencyjne specyfikacje tej samej bramki.** Kontekst techniczny (l. 114) prescriptuje `grep -rniE 'four[- ]line|exactly four' .ai/` → zero. DoD (l. 237) prescriptuje `grep -rniE 'exact four-line|exactly four bullet' .ai/` → zero. Wzorce nie są równoważne: pierwszy złapie także „four-line block" w plikach Layer B, drugi nie. Ten sam niezmiennik ma w jednym dokumencie dwie różne definicje operacyjne, a przy zapisie z l. 114 stan docelowy „four required lines" prawdopodobnie sam siebie nie przepuści (zawiera „four" i — w zależności od redakcji — może trafić we wzorzec `four[- ]line`).

**Działanie:** zredukować do jednego, wykonalnego kryterium. Propozycja: wypisać tabelę pięć plików × docelowe sformułowanie, i jedną pozycję DoD: „`grep -rniE 'exact four-line|exactly four bullet|four-line block' .ai/` zwraca zero; każdy z pięciu plików zawiera swoje docelowe sformułowanie z tabeli powyżej". Usunąć wzorzec z l. 114 albo zrównać go z DoD — nie zostawiać dwóch.

---

## 5. Nierozstrzygnięty konflikt między nową regułą 14 i istniejącą regułą 13

Trzeci trigger reguły 14 to „the task reaching a **completed-and-tested** state", a skutkiem jest: zapisz checkpoint i **zakończ sesję**. Istniejąca reguła 13 tej samej numerowanej listy brzmi: „**Proceed to Fine on PASS**".

Dla ostatniego taska w planie oba warunki są spełnione jednocześnie i nakazują przeciwne działania: reguła 13 każe przejść do Fine, reguła 14 każe zakończyć sesję. Plan nie ustala precedencji ani nie rozróżnia „task" od „całość ticketu" — a to rozróżnienie jest tu nośne, bo dla tasków niekońcowych konfliktu nie ma.

Stop Rule Taska 3.1 zabezpiecza wyłącznie przed przenumerowaniem listy, czyli przed kolizją składniową. Kolizji semantycznej z regułą, która stoi bezpośrednio przed nową, nie adresuje. Jest to dokładnie ta klasa defektu, którą produkuje dopisywanie reguły na koniec listy bez przeczytania jej poprzedniczki.

**Działanie:** zawęzić trzeci trigger do „task completed+tested **and further tasks remain in the plan**", albo dopisać do reguły 14 zdanie o precedencji: „gdy ukończony task jest ostatnim w planie, reguła 13 ma pierwszeństwo — przejdź do Fine, nie kończ sesji checkpointem". Dodać odpowiednią pozycję do DoD Taska 3.1.

---

## 6. Drobne

**6a. Fixture w Weryfikacji Fazy 2 nie testuje obu gałęzi, tylko jedną.** Zapis mówi o „two-row `INDEX.md` fixture … to smoke-test `eversis_context_list` and **both branches** of the `Context` line". Fixture dwuwierszowy daje wyłącznie gałąź `N > 0`. Gałąź `0` daje **obecny stan repo** (brak `INDEX.md`), co Kontekst techniczny sam stwierdza w l. 135. Obie gałęzie są osiągalne, ale tylko sekwencyjnie i we właściwej kolejności. Poprawka redakcyjna: „najpierw zweryfikować gałąź `0` na obecnym stanie, następnie dodać fixture i zweryfikować `N > 0`".

**6b. Success Measure nie pokrywa dwóch dostarczanych zmian.** Wymienia sześć warunków, wśród nich brak: (i) połowy `code_paths`/`related_specs` z Taska 1.2 i zdania w `eversis-audit-domain-knowledge` (czyli całego B6, najnowszego blockera), (ii) Taska 1.3 (`docs/context/README.md` nazywa `INDEX.md` routerem). Kryteria akceptacji w sekcji Quality Assurance pokrywają oba (l. 325-326 i dalej), więc luka jest tylko w mierze nadrzędnej — ale to ta sama linia, która już niesie sprzeczność z punktu 1, więc warto poprawić jednym przejściem.

---

## Czego nie potwierdziłem

Podejrzewałem, że rewizja zgubiła dwie pierwsze pozycje DoD Taska 2.2 (fallback klastrujący i gałąź braku As-Is Packa — czyli główne deliverable Fazy 2). **Nieprawda** — DoD Taska 2.2 jest kompletne, ma siedem pozycji, obie obecne. Mój pierwszy wycinek pliku uciął nagłówek i dwie pozycje, co wyglądało na regresję edycyjną. Odnotowuję, bo gdyby to przeszło do wniosków, byłby to zarzut fałszywy.

---

## Ocena

Warstwa merytoryczna planu jest w tym momencie solidna: diagnozy są zweryfikowane, dekompozycja tasków stabilna, etapowanie zdyscyplinowane, a historia decyzji zapisana na poziomie, który realnie blokuje ponowne wyprowadzanie tych samych wniosków. Findingi 3, 4, 5 i 6 to dług redakcyjno-strukturalny; wszystkie do usunięcia edycjami w miejscu, bez ruszania dekompozycji.

Dwa wymagają decyzji, nie korekty:

**Punkt 1** — sprzeczność 6:2 wokół modelu warstwowego. Sama w sobie łatwa do naprawienia, ale warta chwili refleksji jako zjawisko: plan wykrył, że kontrakt asertowany w pięciu plikach był aktualizowany w dwóch, a następnie wprowadził własną poprawkę do tego wykrycia w dwóch miejscach, zostawiając sześć nieaktualnych. Powtarzalność tego wzorca sugeruje, że brakującym elementem jest nie staranność, a mechanizm: przy każdej rewizji planu warto przelecieć grepem terminy nośne decyzji (`all five`, `identically`, `Task 1.x`) i sprawdzić, czy wszystkie wystąpienia mówią to samo. To tanie i wychwyciłoby też W8 z poprzedniej iteracji.

**Punkt 2** — `Resume` jako wartość `Flow` to błąd typowania, który kosztuje utratę deklaracji `Full Flow` przy wznowieniu i wchodzi w konflikt z zakazem dodawania treści do Layer B. Osobna opcjonalna linia rozwiązuje jedno i drugie, jest tańsza w implementacji i lepiej komponuje się z poprawką W7, która i tak przekształca opcjonalne dodatki w zbiór. Rekomenduję zmianę przed zatwierdzeniem — po wejściu kontraktu readiness korekta enuma będzie znowu dotykać pięciu plików.
