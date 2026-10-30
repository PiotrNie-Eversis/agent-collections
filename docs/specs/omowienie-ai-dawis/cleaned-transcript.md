# Omówienie postępów AI w DAWIS — Cleaned Transcript

## Meeting Metadata

| Field | Value |
|---|---|
| Date | Nie podana w transkrypcji |
| Duration | Nieoznaczona znacznikami czasu; rozmowa statusowa przed urlopem Piotra |
| Topic | Status pracy (DAWIS i okolice) oraz discovery: jak w Agents Collection dzielić pracę frontend–backend |
| Context | Rozmowa przed urlopem Piotra. Po krótkim statusie (Sternik, DAWIS, przetargi, wypuszczenie zmiany w Agents Collection) rozmówca podnosi ten sam problem z PIÓW i KOS: współpraca frontend–backend przy Agents Collection. Druga część to oficjalna zasada utrzymania: nie robić zadań na zapas i nie aktualizować paczek prewencyjnie. |

## Participants

| Name | Role |
|---|---|
| Piotr | Autor Agents Collection; przed urlopem domyka DAWIS, Sternik i zmianę zarządzania kontekstem. Na spotkaniu proponuje checkpointy oraz agenta pytań do epika. |
| Rozmówca (nie nazwany w transkrypcji) | Pyta o zakres pracy Piotra, opisuje problem podziału zadań na PIÓW i KOS, ustala tymczasowy tryb „na czuja” i ogłasza zasadę utrzymania. Zapowiada przekazanie jej team leaderom, PM-om i Nazarowi. |
| Nazar | Nieobecny. Wspomniany jako osoba, do której zgłasza się zadania utrzymaniowe wyglądające na zbędne. Świadomy zasady w kontekście DAWIS. |
| Konrad | Nieobecny. Frontend na PIÓW; rozwój. Korzysta z Agents Collection i przekazuje uwagi Karolowi. |
| Karol | Nieobecny. Backend na PIÓW. Jeszcze nie korzysta z Agents Collection. W modelu tymczasowym dostaje zadania, w których przeważa backend. |
| Szymon | Nieobecny. Wspomniany przy analogicznym problemie na KOS. |
| Andrzej | Nieobecny. Backend na KOS. Jeszcze nie korzysta z Agents Collection. Przykład adresata pytań w komentarzu Jira. |
| Mateusz | Nieobecny. Dodany do wspólnego kanału o Agents Collection. Wspomniany też jako autor starego zgłoszenia (logowanie), którego nie należy wyciągać „z szafy”. |
| Maczek, Gdzik (zapis transkrypcji: „Maczka Gdzika”) | Nieobecni. Dodani do wspólnego kanału razem z Mateuszem. Imion nie doprecyzowano. |
| Miniuś Gdańsk (zapis transkrypcji) | Nieobecny. Zlecił aktualizację przetargów; zostały trzy endpointy. |

## Executive Summary

Rozmówca pyta, jak najsprawniej dzielić zadania frontendowe i backendowe w Agents Collection, skoro na PIÓW i KOS jedna osoba (zwykle frontend) przygotowuje pracę, a druga (backend, jeszcze bez Agents Collection) musi ją skomentować, zanim da się ją dokończyć. Obie strony mają zostawać w projekcie: frontend nie powinien robić całego backendu, backend nie powinien robić całego frontu. Piotr opisuje checkpointy w researchu i planie oraz pomysł agenta, który na epiku znajduje pytania bez odpowiedzi i adresuje je w Jirze do właściwej osoby. Ustalono, że docelowy mechanizm jest tematem discovery po urlopie; do tego czasu zadanie idzie najpierw do tej strony, której jest więcej. Osobno obowiązuje zasada utrzymania: nie robić zadań niepotrzebnych do ciągłości działania i nie aktualizować paczek tylko dlatego, że wyszła nowa wersja.

## Discussion Topics

### Status przed urlopem (poza głównym discovery)

- Sternik jest w porządku; Piotr ogarnia go sam.
- Na DAWIS Piotr aktualizuje dokumentację i kilka krótkich zadań (około pół dnia); planuje domknąć je tego dnia. Innych tematów wdrożeniowych nie ma. DAWIS składa się z aplikacji, które są na Piotrze.
- Piotr wypuścił większą zmianę w Agents Collection: zarządzanie kontekstem oraz „Syspak” (zapis niejednoznaczny), żeby mechanizm działał na projektach. Wypróbował to na DAWIS. Decyzje architektoniczne są doczytywane przy researchu i planie. Liczy, że zadziała tak samo na innych projektach. Informację o zmianie przekaże na wspólnym kanale.
- Do wspólnego miejsca dopisani zostali Maczek, Gdzik i Mateusz, żeby nie rozdzielać informacji na osobny czat tylko dla Mateusza.
- Aktualizacja przetargów dla Miniusia Gdańska jest zrobiona. Zostały trzy endpointy. Jeśli Piotr nie zdąży przed urlopem, dokończy po urlopie; raport i tak trafi do odbiorcy. Dwa tygodnie urlopu mają wystarczyć jako wsad na ten czas.

### Dyskusja o Agents Collection — problem podziału frontend–backend

- Ten sam problem jest na PIÓW i na KOS. Na PIÓW Konrad robi zadanie w Agents Collection, przekazuje uwagi Karolowi, Karol odpowiada, i dopiero wtedy Konrad może dokończyć zadanie, nanosząc uwagi. Na KOS analogicznie Szymon i Andrzej.
- Karol i Andrzej jeszcze nie korzystają z Agents Collection. Rozmówca spotka się z nimi i pomoże zainstalować.
- Oczekiwany sposób pracy: frontendowiec i backendowiec zawsze są w projekcie i patrzą na zmiany swoim okiem. Frontend nie robi całego backendu i nie zostawia sprawy. Backend nie robi całego frontu, bo rozjedzie się na RWD albo przeglądarce.
- Rozmówca ma trzy pomysły omówione z zespołem i pyta Piotra, autora Agents Collection, o sprawniejszy podział. Piotr mierzył się z podobnym problemem: jak dzielić pracę w researchu i planie, gdy agent się wywali albo dwie osoby pracują na tym samym researchu i nie powinny sobie wchodzić w drogę.

### Propozycje podziału zadań

Trzy pomysły rozmówcy, dla zadań utrzymaniowych i rozwojowych na PIÓW, KOS i DAWIS:

- Utrzymanie kontra rozwój. Przykład: Karol bierze zadania utrzymaniowe, Konrad rozwojowe. Gdy Konrad potrzebuje czegoś od Karola, pokazuje merge request i dostaje odpowiedź — tak jak teraz. W drugą stronę Karol pyta Konrada, czy poprawić coś na frontendzie, żeby zadania szły równolegle.
- Triaż na wejściu. Gdy wpada zadanie, na BM albo na statusie określa się, czy jest bardziej backendowe, czy frontendowe, i ownerem zostaje Karol albo Konrad.
- Dwa zadania z jednego. Zadanie rozbija się na frontend i backend. Najpierw zawsze idzie do backendowca: robi cały background. Frontend dobudowuje swoją część na podstawie tego kontekstu i researchu. Zastrzeżenie rozmówcy: rola frontendu wtedy maleje, bo backend wymyśla funkcjonalność.

Problem, który ten trzeci model utrwala:

- Pod epikiem są zadanie backendowe i frontendowe. Frontend nie może zacząć, dopóki backend nie zrobi swojej działki, więc czeka i odpytuje.
- Kto ma więcej roboty: osoba, która opisze, wypromptuje i przegada zadanie z AI, zostawia gotowy research, plan i kontekst. Druga osoba (np. Konrad) realizuje frontend „na podstawie tego, co przygotował backend” i nie może wymyślać, bo musi być tak, jak backend jest zrobiony.
- Rozmówca nazywa to rozdwojeniem: jak pogodzić dwie osoby w Agents Collection, żeby było najszybciej i najsensowniej.
- Piotr: jeśli pracują dwie osoby, budowanie kontekstu (research) zaczyna backend i zostawia research oraz plan. Frontend startuje już z tym kontekstem. Przy starcie zadania pliki researchu i planu są sprawdzane, czy epik już został zaczęty; jeśli tak, czytane jest to, co zostało zrobione.

Tymczasowe ustalenie (nie docelowy mechanizm):

- To jest discovery. Przed urlopem i w trakcie urlopu nikt się tym nie zajmuje.
- Na pierwszy rzut: jeśli wychodzi więcej backendu, zadanie idzie najpierw do backendowca (na PIÓW: Karol). Jeśli więcej frontendu — do frontu. Na razie „na czuja”.
- Docelowe uszycie tego pod Agents Collection zostaje jako temat do powrotu po urlopie. Rozmówca może coś wymyślić, gdy Piotra nie będzie. Piotr ma zostawić sobie punkt, żeby do tego wrócić; po urlopie nie jest to pierwsza rzecz, o której będzie myślał.

Niesymetryczne obciążenie „architekta”:

- Rozmówca rozumie Agents Collection tak, że zadanie najpierw idzie do nadrzędnego dewelopera (przykład PIÓW: Karol). On rozwiązuje swoją część i odsyła resztę (Konrad dokleja frontend, wypychają całość). Efekt: ta osoba robi właściwie każde zadanie i jest przeciążona. Podział jest niesymetryczny, a zespół chce go trochę wyrównać.
- Piotr: architekt nie jest potrzebny do każdej decyzji. Przy zadaniu w większości backendowym trafia ono do backendowca, który podejmuje grube decyzje (baza, encje). Przy zadaniu do rozkminienia na logikę research może przygotować analityk biznesowy w ścieraniu pytań i odpowiedzi; Konrad siada potem do pracy, bo decyzje są już podjęte.
- Są też zadania ściśle frontendowe i ściśle backendowe (dorobienie logów w serwisie; kontrast, który nie działa pod WCAG). Takie zadania też wymagają podziału. Na razie i tak „na czuja”.

### Mechanizm checkpointów w researchu

- W aktualizacji, którą Piotr właśnie wypuścił, system sam dodaje checkpoint tego, co zostało zrobione, gdy trwa research albo plan.
- Gdy praca dotyczy frontu i backendu, można postawić checkpoint: teraz część frontendowa (tylko zadania frontendowe), a checkpoint na zadania backendowe zostawić i wypchnąć do repozytorium.
- Przykład: Konrad pracuje nad frontendem. Pytania do backendu przekazuje do plików researchu (raczej researchu niż planu), w stronę backendu. Wypycha plik nawet wtedy, gdy research jest tylko na określonym poziomie („pytania do backendu”). Karol obiera ten plik i kontynuuje.
- Według idei druga osoba zaczyna od tego momentu: system czyta checkpoint, zaczyna pracę nad backendem i zmienia flagę fragmentu na resumed (fragment jest w trakcie pracy). Działa to wymiennie.
- Drugi powód checkpointów, poza podziałem ról: przy złożonym problemie Piotr wymienia z agentem kilkadziesiąt wiadomości, zanim zrozumie, co agent chce zrobić. Okno kontekstu w Cursorze dochodzi do około 99%, potem kompresja ucina wcześniejsze ustalenia. Po pracy warsztatowej przełącza okno i pokazuje tylko plik; agent widzi, od którego momentu zacząć.
- Rozmówca pyta, czy to nie jest w kontrze do założenia Agents Collection, żeby robić zadania full stackowo.
- Piotr: zwykle tak, ale w Claude i Cursorze jakość zależy od okna kontekstu. Research i planowanie dokładają wiedzę i zapychają kontekst. Poniżej około 50% często można klepnąć plan i przejść do implementacji. Dla jakości czasem lepiej otworzyć nowe okno i poprosić o kontynuację researchu albo planu. Sam tak robi: po akceptacji planu nie zaczyna implementacji w tym samym oknie, tylko wkleja link do planu w nowym oknie. Agent doczytuje plan ze świeżym kontekstem, bez całego tła wiadomości, które bywa pomocne albo nie.

### Agent do analizy epików i pytań bez odpowiedzi

- Po pierwszych testach backend nie korzysta z Agents Collection. Przekonanie Andrzeja i Karola jest rolą rozmówcy. Standardy ze strony standardów, robione własnymi agentami, mają działać tak jak standardy Agents Collection — osobną sprawą jest, czy będą je stosować.
- Drugi problem z tych testów: kto powinien iść pierwszy, kto buduje więcej kontekstu i kto kogo odpytuje.
- Propozycja Piotra na pierwszy rzut, gdy ktoś chce zacząć: wziąć epik i puścić agenta do analizy, żeby wypluł otwarte pytania, na które nie ma jeszcze odpowiedzi.
- Da się to zautomatyzować: przy istniejącym epiku analiza (raz dziennie albo raz w tygodniu) zostawia otwarte pytania.
- Pytania trzeba zaadresować. Przykład potrzeby backendu: jak będą wyglądać endpointy, jakie parametry, jaka struktura bazy. Epik opisuje funkcjonalność, ale nie ma szczegółowej analizy.
- Agent wypycha analizę i adresuje autora. W komentarzach Jira może wskazać konkretną osobę przypisaną do podzadania (przykład: Andrzej, zadanie bardziej backendowe).
- Agent ma wykrywać słabe punkty. Padły istniejące wejścia: review planu, review codebase, review UI (dla frontu). Trzeba to dopracować, żeby znajdował pytania bez odpowiedzi i adresował je do właściwych osób — w zadaniu głównym albo w podzadaniach.
- Rozmówca: ktoś i tak musi odpalić Agents Collection, chyba że powstanie automat. Piotr przychyla się do automatu. Zostaje to w discovery, nie przed urlopem. Rozmówca widzi w tym ciekawy user story do późniejszego uszycia.

### Komentarze i notatki jako podstawa dalszej pracy

- Gdy backend (przykład: Andrzej) ustosunkuje się do pytań, frontend może zacząć pracę: ma notatkę, czyli komentarz.
- Frontend wczytuje epik razem z tymi odpowiedziami i może zacząć research. Część pracy da się zacząć już na tym etapie, bez czekania na pełne domknięcie backendu.
- Rozmówca zostawia temat Piotrowi (jest notetaker). Poprosi o udostępnienie zapisu i zostawia zadanie na później. Temat nadaje się na późniejszą rozmowę na czacie.
- Ustalenie końcowe tej nitki: na razie dzielą „na czuja”; Piotr ma pomyśleć, jak pogodzić dwie role, żeby to miało sens. Nie przed urlopem i nie w trakcie.

### Ograniczenie zadań utrzymaniowych do niezbędnych

- Rozmówca będzie o tym mówił team leaderom oraz jutro PM-om i prosi o to samo Piotra. Mniejsza liczba godzin na utrzymanie nie wynika tylko z pracy z AI.
- Utrzymanie ma utrzymywać projekt w stanie, w jakim jest, i w stanie niepogorszonym. Nie polepszać go niepotrzebnie. Reagować na to, co się dzieje w projekcie.
- Przykład zbędnej pracy: Nazar wyciąga sprawę sprzed dwóch lat (Mateusz znalazł, że coś źle się loguje). Klient tego nie widzi i nie zgłosił. To nie jest potrzebne do ciągłości działania. Takie zadanie zgłaszać Nazarowi.
- Nowa polityka: nie robić zadań na zaś — poprawianie metody, ładniejsze pisanie kodu, wyciąganie „brudów z szafy”.
- Nazar jest świadomy tej zasady w DAWIS; rozmówca już z nim gadał i powie to jeszcze jawnie. To zasada must, żeby utrzymać mniejszą alokację i nie generować niepotrzebnej pracy.
- Jeśli Piotr widzi, że ktoś robi albo przymierza się do takiego zadania, zgłasza to Nazarowi. Wtedy zapada decyzja: może się okazać, że zadanie jest wyjątkowo niezbędne w innym miejscu.

### Aktualizacje i krytyczne poprawki

- Update’ów paczek też nie robić na zaś tylko dlatego, że wyszła nowa wersja.
- Robić je, gdy jest krytyczna podatność, albo gdy projekt tego wymaga.
- Wcześniej aktualizacje bywały dwa razy do roku; teraz raczej raz, chyba że jest podatność albo wymóg projektu.
- To ogólna, oficjalna zasada przy mniejszej alokacji. Nazar już o niej wie.

### Domknięcie operacyjne

- Jutro bez statusu. Piotr pisze krótkiego maila albo wiadomość na czacie tylko wtedy, gdy coś wymaga uwagi. Jeśli wszystko jest pod kontrolą, nie musi — po jego stronie jest sam DAWIS.
- Piotr chciał wysłać podsumowanie tego, co jest do zrobienia. Rozmówca ma podsumowanie z notetakera i podeśle zapis. Prosi, żeby Piotr pomyślał o pogodzeniu dwóch ról w Agents Collection.

## Key Decisions

| # | Decision | Made By | Conditions / Caveats |
|---|----------|---------|---------------------|
| 1 | Informacje o Agents Collection idą w jedno miejsce, nie na osobny czat tylko dla Mateusza | Piotr i rozmówca | Do kanału dopisani Maczek, Gdzik i Mateusz (zapis imion niepewny) |
| 2 | Docelowy podział frontend–backend w Agents Collection zostaje discovery do po urlopie | Rozmówca, Piotr się zgadza | Nie przed urlopem i nie w trakcie. Piotr wraca do tego później, nie jako pierwsza rzecz po urlopie |
| 3 | Do czasu docelowego mechanizmu: zadanie idzie najpierw tam, gdzie jest go więcej (backend albo frontend) | Rozmówca | „Na czuja”. Na PIÓW więcej backendu oznacza najpierw Karol |
| 4 | Zadań utrzymaniowych niepotrzebnych do ciągłości działania się nie robi | Rozmówca | Zgłaszać Nazarowi; wyjątek, gdy w innym miejscu okażą się niezbędne. Nazar świadomy w DAWIS. Zasada must przy mniejszej alokacji |
| 5 | Paczek nie aktualizować prewencyjnie przy nowej wersji | Rozmówca | Aktualizacja przy krytycznej podatności albo gdy projekt wymaga. Wcześniej ok. dwa razy do roku, teraz raczej raz |

## Action Items

| # | Action | Assigned To | Deadline |
|---|--------|-------------|----------|
| 1 | Domknąć dokumentację DAWIS i krótkie zadania | Piotr | Tego dnia, przed urlopem |
| 2 | Podać na wspólnym kanale, co zmieniło się w zarządzaniu kontekstem Agents Collection | Piotr | „Zaraz” / przy wypuszczeniu zmiany |
| 3 | Dokończyć trzy endpointy przy aktualizacji przetargów, jeśli nie zdąży przed urlopem; raport i tak idzie | Piotr | Po urlopie, jeśli nie zdąży wcześniej |
| 4 | Pomóc Karolowi i Andrzejowi zainstalować Agents Collection | Rozmówca | Niepodany |
| 5 | Udostępnić zapis notetakera | Rozmówca | „Zaraz” |
| 6 | Wrócić do user story: jak pogodzić rolę frontend i backend w Agents Collection | Piotr | Po urlopie, nie w pierwszej kolejności |
| 7 | Powiedzieć team leaderom i PM-om o zasadzie utrzymania; powtórzyć Nazarowi jawnie | Rozmówca | PM-om jutro |
| 8 | Zgłaszać Nazarowi zadania utrzymaniowe wyglądające na zbędne (w tym aktualizacje paczek na zaś) | Piotr | Bieżąco |
| 9 | Napisać maila albo wiadomość na czacie tylko wtedy, gdy coś wymaga uwagi; jutro bez statusu | Piotr | Jutro, warunkowo |

## Open Questions

| # | Question | Raised By | Notes |
|---|----------|-----------|-------|
| 1 | Który model podziału przyjąć: utrzymanie/rozwój, triaż ownera, czy rozbicie na dwa zadania z backendem pierwszym? | Rozmówca | Trzy pomysły omówione z zespołem. Żaden nie został wybrany jako docelowy. Tymczasowo „na czuja” |
| 2 | Czy checkpoint w researchu nie jest w kontrze do full stackowego zadania w Agents Collection? | Rozmówca | Piotr: zwykle full stack, ale jakość przy pełnym oknie kontekstu bywa gorsza; świeże okno z plikiem planu/researchu bywa lepsze. Nie zamknięte jako zasada produktu |
| 3 | Kto idzie pierwszy, kto buduje więcej kontekstu i kto kogo odpytuje? | Rozmówca | Boi się, że frontend tylko wykonuje research backendu i nie może wymyślać. Boi się też, że „architekt” robi każde zadanie |
| 4 | Czy architekt jest potrzebny przy każdym zadaniu? | Piotr | Czasem grube decyzje backendu (baza, encje). Czasem research może przygotować analityk. Są zadania ściśle FE i ściśle BE |
| 5 | Do kogo adresować pytania bez odpowiedzi na epiku i jak często ma lecieć analiza? | Rozmówca i Piotr | Kierunek: komentarz Jira do osoby przypisanej (backend albo frontend). Częstotliwość rzucona: raz dziennie albo raz w tygodniu. Automat kontra ręczne odpalenie — skłonność do automatu, bez projektu |
| 6 | Czy Karol i Andrzej będą stosować standardy, gdy już zainstalują narzędzie? | Rozmówca | Backend w pierwszych testach nie korzystał. Osobne od pytania, czy standardy technicznie zadziałają |

## Preserved Context

> „Mimo wszystko chciałbym, żeby gdzieś tam frontendowiec i backendowiec zawsze byli w tym projekcie, żeby swoim okiem gdzieś patrzyli na te zmiany (…) żeby to nie poszło tak, że frontendowiec robi cały backend (…) i w drugą stronę, żeby backendowiec nie robił też frontu, bo pewnie mu się rozjedzie na jakiejś RWD czy przeglądarce.”
> — Rozmówca, regarding podział ról

> „Trzecim pomysłem było to, żeby tworzyć dwa zadania. (…) Najpierw idzie zawsze do back-endowca, back-end robi ten cały background i potem front-end budowuje już na podstawie tego kontekstu, na podstawie tego researchu cały front-end. Ale wtedy jakby ta rola frontendu się tutaj moim zdaniem dużo zmniejsza. No bo to backendowiec jakby wymyśla funkcjonalność.”
> — Rozmówca, regarding rozbicie zadania na pół

> „W momencie, kiedy robimy research albo już plan, to system sam dodaje na przykład checkpoint tego, co zostało zrobione. (…) możemy dać taki checkpoint, że w tym momencie chcemy zrobić tą część front-endową (…) i zostawić checkpoint na zadania back-endowe i wypchnąć to (…) do repozytorium. (…) System to czyta, sprawdza, że dobra, tu jest checkpoint. Zaczyna pracę nad backendem i zamienia to na resumed.”
> — Piotr, regarding checkpointy

> „Czy to też troszkę jakby nie jest w kontrze do tego założenia Agents Collection, żeby robić full stackowo zadania?”
> — Rozmówca, regarding checkpointy i pełny stos

> „Idealne było ewentualnie, no na pierwszy taki rzut, jeżeli ktoś by chciał zacząć, tak? No to wziąć sobie tego epika, przeanalizować go, tu mu puścić (…) agenta do analizy (…). Żeby wypluł w ogóle do epika otwarte pytania, tak? Na które nie ma odpowiedzi jeszcze. (…) raz w tygodniu, raz dziennie może przelecieć po prostu taka analiza.”
> — Piotr, regarding agent pytań

> „Nawet mógłby wtedy zaadresować konkretną osobę, która jest przypisana. (…) w komentarzach zaadresować po prostu pytania do konkretnych osób. (…) jeżeli Andrzej by się tu przykładowo tak ustosunkował (…), no to wtedy Frontend już by mógł zacząć (…). Już część (…) już by mógłby zacząć pracę.”
> — Piotr, regarding komentarze Jira

> „Na początek możemy po prostu dać takie zadanie, że jeżeli wychodzi na to, że jest więcej backendów, idzie najpierw do Karola, czy tam do backendowca. Jeżeli więcej frontendów, to do tego. Tak na razie może zostać.”
> — Rozmówca, regarding tryb tymczasowy

> „Faza maintenance projektu polega na tym, żeby utrzymywać projekt w takim stanie, w jakim jest i niepokorszonym, ale też nie polepszać go jakby niepotrzebnie. (…) Zgodnie z nową polityką nie robimy takich zadań na zaś.”
> — Rozmówca, regarding utrzymanie

> „Jakieś update’y, paczek. Też żeby nie robić na zaś, że o wyszła nowa wersja, zaktualizujmy, tylko jak jest jakaś krytyczna podatność. (…) jeżeli projekt wymaga, to też trzeba to zrobić.”
> — Rozmówca, regarding aktualizacje
