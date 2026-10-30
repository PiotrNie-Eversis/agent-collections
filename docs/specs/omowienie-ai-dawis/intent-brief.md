# Omówienie postępów AI w DAWIS — Intent Brief

## Workshop Summary

| Field | Value |
|---|---|
| Workshop Date | Nie podana w transkrypcji |
| Participants | Piotr; rozmówca nienazwany w transkrypcji. Wspominani, nieobecni: Nazar, Konrad, Karol, Szymon, Andrzej, Mateusz, Maczek i Gdzik (zapis niepewny), Miniuś Gdańsk |
| Source Materials | `cleaned-transcript.md` z pliku „Omówienie postępów AI w DAWIS.txt”. Kąt analizy wskazany przy starcie: podział frontend–backend, checkpointy, agent pytań do epika, komentarze jako kontekst, zasada utrzymania i aktualizacji |
| Prepared By | Business Analyst (eversis-analyze-materials) |

## Goal

Ustalić, jak w Agents Collection dwie role — frontend i backend — mają współpracować przy jednym epiku, zamiast robić nawzajem całą drugą warstwę albo czekać na ręczną wymianę uwag. Drugi, niezależny cel rozmowy: utrzymać mniejszą alokację na utrzymanie przez odrzucanie zadań i aktualizacji, które nie są niezbędne do ciągłości działania.

## In Scope

- Zasada współpracy: frontend i backend zostają przy zmianie i patrzą na nią swoim okiem. Frontend nie domyka sam całego backendu. Backend nie domyka sam całego frontu (ryzyko RWD i przeglądarek).
- Trzy omawiane modele podziału: (1) osobno utrzymanie i rozwój, z odpytywaniem przez merge request, (2) triaż na wejściu, czy zadanie jest bardziej backendowe czy frontendowe, i jeden owner, (3) rozbicie na dwa zadania, backend pierwszy, frontend na podstawie jego researchu i kontekstu.
- Checkpoint w researchu i planie: system zapisuje, co już zrobiono; część frontendową można wypchnąć, a checkpoint backendowy zostawić drugiej osobie. Wznowienie od checkpointu (flaga resumed) i świeże okno z plikiem, gdy okno kontekstu jest pełne.
- Agent analizy epika: wykrywa pytania bez odpowiedzi (endpointy, parametry, struktura danych, słabe punkty) i adresuje je w komentarzu Jira do osoby przypisanej do właściwej strony. Po odpowiedzi frontend może zacząć research, nie czekając na pełne domknięcie backendu.
- Tymczasowa reguła operacyjna do czasu docelowego mechanizmu: zadanie idzie najpierw tam, gdzie jest go więcej.
- Zasada utrzymania: nie robić zadań na zapas (porządkowanie kodu, stare ustalenia niewidoczne dla klienta). Takie zadania zgłaszać Nazarowi. Wyjątek, gdy są niezbędna gdzie indziej.
- Aktualizacje paczek według potrzeby: krytyczna podatność albo wymóg projektu. Nie przy każdej nowej wersji.

## Out of Scope

- Docelowy wybór jednego z trzech modeli podziału. Rozmowa zostawia to jako discovery po urlopie Piotra. Przed urlopem i w trakcie urlopu nikt tego nie projektuje i nie wdraża.
- Wdrożenie Karola i Andrzeja w Agents Collection (rozmówca pomoże zainstalować). To działanie operacyjne, nie zakres tego briefu produktowego.
- Status Sternika, domknięcie dokumentacji DAWIS i trzech endpointów przetargów. To bieżąca praca Piotra przed urlopem, nie epik z tej rozmowy.
- Szczegóły techniczne „Syspaka” i zarządzania kontekstem, które Piotr już wypuścił. Na spotkaniu jest tylko status, bez nowych wymagań.
- Szacowanie, sprint i to, kto jest architektem w każdym projekcie poza przykładem PIÓW (Karol) i KOS (Andrzej).

## Key Stakeholders / Actors

- Frontendowiec (przykład: Konrad na PIÓW) — rozwój; dziś startuje zadanie w Agents Collection i czeka na uwagi backendu. Ma zachować wpływ na funkcjonalność, nie tylko wykonać research backendu.
- Backendowiec (przykład: Karol na PIÓW, Andrzej na KOS) — jeszcze nie korzysta z Agents Collection. Odbiorca pytań o kontrakt, parametry i dane. Przy zadaniu w większości backendowym podejmuje decyzje o kształcie tej warstwy.
- Autor Agents Collection (Piotr) — proponuje checkpointy i agenta pytań; po urlopie wraca do tematu pogodzenia obu ról.
- Rozmówca nienazwany — pilnuje, żeby obie role zostały w projekcie, ogłasza tryb tymczasowy i zasadę utrzymania.
- Analityk biznesowy — przy zadaniu „do rozkminienia na logikę” może przygotować research pytaniami i odpowiedziami, zanim siądzie do niego frontend.
- Nazar — dostaje zgłoszenia zadań utrzymaniowych, które wyglądają na zbędne, i uczestniczy w decyzji, czy jednak są niezbędne.
- Zespół utrzymania DAWIS — ma stosować zasadę „nie na zaś” i nie robić prewencyjnych aktualizacji paczek.

## Candidate Epics

- Współpraca frontend–backend przy jednym zadaniu — trzy modele są na stole; wspólna wartość to oba oczy na zmianie i brak sytuacji, w której jedna rola robi całą drugą warstwę. Docelowy model nie został wybrany.
- Checkpoint przekazania researchu między rolami — da się oddać drugiej osobie plik z miejsca, w którym skończyła pierwsza, łącznie z pytaniami, i wznowić pracę bez uciętego okna rozmowy.
- Pytania bez odpowiedzi na epiku — analiza sama znajduje braki (w tym kontrakt backendu) i kieruje je do właściwej osoby w Jirze, żeby druga rola mogła zacząć na komentarzu, a nie na pełnym domknięciu.
- Utrzymanie tylko tego, co niezbędne — osobny strumień operacyjny, nie mechanizm Agents Collection: zadania na zapas i aktualizacje bez podatności albo wymogu projektu nie wchodzą do roboty; sporne zgłasza się Nazarowi.

## Baseline Overlap / Existing Backlog Notes

- Brak `docs/context/<project>/task-baseline.md` w tym repozytorium. Nie ma z czym zbić nakładania się backlogu.
- W frameworku jest już checkpoint planu przy implementacji (`CHECKPOINT` / `RESUMED` w changelogu planu, przekazanie stanu między sesjami agenta). Rozmowa mówi o czymś szerszym: checkpoint w researchu rozdzielony na część frontendową i backendową, wypychany do repozytorium i obierany przez drugą osobę. Tego podziału ról w materiale nie utożsamiam z istniejącym checkpointem sesji.
- Padły nazwy istniejących wejść analizy: review planu, review codebase, review UI. Rozmowa traktuje je jako coś, co trzeba dopracować pod pytania bez odpowiedzi i adresowanie osób w Jirze, a nie jako gotowy automat dzienny lub tygodniowy.

## Open Questions

- Który z trzech modeli podziału jest docelowy, a który zostaje tylko opisem problemu? Tryb „więcej backendu → najpierw backend” jest tymczasowy i nie rozstrzyga user story.
- Czy checkpoint frontend/backend ma zastąpić zadanie full stack, czy tylko odciążać pełne okno kontekstu, gdy pracuje jedna osoba?
- Kto buduje pierwszy kontekst, gdy zadanie nie jest „w większości backendowe”: backend, frontend, czy analityk?
- Pytania agenta: automat (raz dziennie czy raz w tygodniu) czy uruchomienie ręczne, i czy komentarz ląduje w epiku, czy w podzadaniu?
- Zasada utrzymania i aktualizacji: czy ma powstać z niej osobny epik w backlogu Agents Collection / DAWIS, czy zostaje regułą operacyjną poza Jirą tej rozmowy?
- Data spotkania i imię rozmówcy nie padły w transkrypcji.

## Gate 0 Approval

| Decision | Notes |
|---|---|
| Pending — awaiting approval | Materiały są niejednoznaczne co do zakresu backlogu: trzy modele podziału bez wyboru, mechanizm odłożony na po urlopie, a zasada utrzymania jest regułą operacyjną obok produktu Agents Collection. Ekstrakcja epików i story startuje po zatwierdzeniu tego briefu. |
