# Research: nieudana próba aktualizacji frameworka agent-collections (perspektywa konsumenta `user-profile`)

## Changelog

- **2026-08-14 — DELTA (kontynuacja research).** Zweryfikowano aktualny stan `main` (`HEAD e19121c`, ten sam commit co working tree `agent-collections`): Ustalenie 1 i 2 nadal reprodukowalne, żadna z opisanych luk nie została jeszcze naprawiona. Dodano **Ustalenie 3** (mechanizm auto-resolve `COLLECTIONS_HOME` w `resolve_collections_home()`) i rozszerzono zakres Ustalenia 1 o drugą lokalizację tej samej luki w `README.md` (tabela "Upgrade contract"). Częściowa odpowiedź na Otwarte pytanie 2 poniżej.

## Zadanie

Przeanalizować nieudaną próbę aktualizacji frameworka **agent-collections**, zgłoszoną z poziomu projektu konsumenckiego `user-profile` (tryb vendorowania: submodule):

```
➜  user-profile git:(agent-collections) bash scripts/setup-agent-collections.sh --upgrade --sync --non-interactive
bash: scripts/setup-agent-collections.sh: No such file or directory
➜  user-profile git:(agent-collections) git submodule update --init --recursive
```

> Ten plik trafił tu (`docs/specs/` w repozytorium `agent-collections`) po przeniesieniu z `docs/specs/` konsumenta `user-profile` — oba ustalenia poniżej dotyczą tego repozytorium (README, przepływ submodule), a nie kodu `user-profile`.

## Fakty o środowisku (stan w `user-profile` w momencie analizy)

- Tryb vendorowania: **submodule** (`.agent-collections/install-selection.json` w `user-profile`: `"vendorMode": "submodule"`, `"linkMode": "symlink"`).
- Zapisane `AGENT_COLLECTIONS_HOME`: `.agent-collections/framework-home.txt` → `<user-profile>/vendor/agent-collections` (czyli checkout tego repozytorium jako submoduł).
- `.gitmodules` w `user-profile`: `vendor/agent-collections` → `https://github.com/PiotrNie-Eversis/agent-collections.git`.
- W katalogu głównym `user-profile` w ogóle nie ma katalogu `scripts/` — istnieje tylko `vendor/agent-collections/scripts/` (czyli `scripts/` tego repozytorium, wypięte jako submoduł).

## Ustalenie 1 — błędna ścieżka wywołania w README (dlaczego zawiodła pierwsza komenda)

`scripts/setup-agent-collections.sh` istnieje wyłącznie w tym repozytorium (`agent-collections`), pod ścieżką `scripts/setup-agent-collections.sh`. W trybie vendorowania **submodule** u konsumenta nie ma kopii ani symlinka tego skryptu w katalogu głównym repozytorium konsumenckiego — instalator linkuje/kopiuje do repozytorium konsumenta wyłącznie *zawartość* frameworka (`.ai/`, rules, skills), a nie sam skrypt instalatora.

Komenda, którą uruchomił użytkownik w `user-profile`, została skopiowana dosłownie z **`README.md`** tego repozytorium, sekcja **"### Upgrade"** (`README.md:199`):

```bash
bash scripts/setup-agent-collections.sh --upgrade --sync --non-interactive
```

Ta linijka nie ma żadnego kwalifikatora ścieżki i jest myląca poza checkoutem/klonem tego repozytorium. Dla porównania, sekcja 40 linijek wyżej, **"## Install into a consumer project"** (`README.md:169`), poprawnie kwalifikuje wywołanie:

```bash
export AGENT_COLLECTIONS_HOME=/path/to/agent-collections
bash "$AGENT_COLLECTIONS_HOME/scripts/setup-agent-collections.sh" \
  --non-interactive --agents=cursor --mcp-servers=eversis-collections --profile=fullstack
```

**To jest realna luka w dokumentacji `README.md` tego repozytorium**, a nie błąd konsumenta: podsekcja "Upgrade" pomija prefiks `$AGENT_COLLECTIONS_HOME` (lub jawny prefiks `vendor/agent-collections/` dla konsumentów w trybie submodule), którego używają wszystkie pozostałe przykłady wywołań w tym samym pliku. Skopiowanie tej komendy 1:1 do konsumenta w trybie submodule z założenia kończy się błędem.

**Poprawne wywołanie dla konsumenta w trybie submodule** (tak jak `user-profile`, zgodnie z zapisanym u niego `framework-home.txt`):

```bash
bash vendor/agent-collections/scripts/setup-agent-collections.sh --upgrade --sync --non-interactive
# odpowiednik:
export AGENT_COLLECTIONS_HOME="$(cat .agent-collections/framework-home.txt)"
bash "$AGENT_COLLECTIONS_HOME/scripts/setup-agent-collections.sh" --upgrade --sync --non-interactive
```

## Ustalenie 2 — `git submodule update --init --recursive` nie wykonuje aktualizacji, a submoduł u konsumenta już zdryfował

Dwa osobne problemy, łatwe do pomylenia:

**2a. Niedopasowanie zakresu.** `git submodule update --init --recursive` (uruchomione w `user-profile`) jedynie checkoutuje ten commit tego repozytorium, który aktualnie jest zapisany w indeksie superprojektu (`user-profile`) dla `vendor/agent-collections`. Komenda ta **nie**:
- pobiera/przechodzi na nowsze wydanie frameworka,
- ponownie uruchamia `--sync` (regeneracja adapterów, linkowanie skilli `.claude/`, regeneracja `CLAUDE.md`) — logikę, którą dostarcza `scripts/setup-agent-collections.sh` z tego repozytorium,
- aktualizuje `.agent-collections/install-selection.json` po stronie konsumenta.

Uruchomienie jej po nieudanym wywołaniu skryptu było rozsądnym odruchem naprawczym ("upewnijmy się, że submoduł jest zainicjalizowany"), ale nie może zastąpić kroku `--upgrade --sync` instalatora dostarczanego przez to repozytorium. Nawet w pełni udany `submodule update` u konsumenta pozostawiłby wygenerowane po jego stronie pliki (root `CLAUDE.md`, `.claude/skills/`, `.claude/commands/eversis-*.md`, shimy `.cursor/`) nieaktualne względem tego, jaki commit tego repozytorium jest wypięty.

**2b. Checkout tego repozytorium w `user-profile` jest obecnie do przodu względem tego, co zacommitowane jako pin w `user-profile`, w sposób obchodzący standardowy proces.**
Stan zweryfikowany w `user-profile` w momencie analizy:

| | commit (w tym repozytorium, `agent-collections`) |
|---|---|
| Zapisany w `HEAD` superprojektu `user-profile` (`git ls-tree HEAD -- vendor/agent-collections`) | `1502308a` |
| Faktyczny `HEAD` working tree submodułu u konsumenta | `e19121c8` (10 commitów do przodu, fast-forward względem `1502308a`) |

`git status` w `user-profile` potwierdza to jako **niezacommitowaną zmianę** po stronie konsumenta:
```
modified:   vendor/agent-collections (new commits)
```

Reflog checkoutu tego repozytorium w `user-profile` tłumaczy jak do tego doszło:
```
e19121c HEAD@{0}: pull --tags origin main: Fast-forward
1502308 HEAD@{1}: pull --tags origin main: Fast-forward
95b3969 HEAD@{2}: pull --tags origin main: Fast-forward
df3fb82 HEAD@{3}: clone: from https://github.com/PiotrNie-Eversis/agent-collections.git
```

W `user-profile` trzykrotnie uruchomiono `git pull` **bezpośrednio wewnątrz `vendor/agent-collections/`** (na lokalnym branchu `main`, który śledzi `origin/main` tego repozytorium), zamiast przejść przez udokumentowany w `README.md` przepływ "Submodule bump" (tabela "Upgrade contract": *zaktualizuj submoduł do docelowego tagu/commita, następnie uruchom instalator `--upgrade --sync`, następnie zacommituj wynikowy bump gitlinka w superprojekcie*). `1502308a` odpowiada SHA, które commit `323fbe1` w `user-profile` ("DUA-475 chore(agent-collections): update submodule to latest commit") wypiął w tamtym repozytorium — więc jeden z tych trzech pulli miał miejsce już po tym commicie, przesuwając checkout do przodu względem ostatnio zacommitowanego pinu, bez odpowiadającego mu commita po stronie `user-profile`.

Efekt netto: wskaźnik submodułu w `user-profile` znajduje się w nieaktualnym/niezacommitowanym stanie, który nie odpowiada żadnemu commitowi w historii `user-profile`. Gdyby ktokolwiek inny z zespołu `user-profile` uruchomił teraz `git submodule update --init --recursive`, checkout zostałby cofnięty do `1502308a`, po cichu porzucając dodatkowe 10 commitów obecnie wypiętych lokalnie — klasyczny "wypadek" związany z submodułami gita (`git pull` wewnątrz submodułu przesuwa jego branch, ale nigdy nie aktualizuje gitlinka ani historii superprojektu).

## Ustalenie 1 (rozszerzenie) — ta sama luka istnieje w drugiej lokalizacji README

Weryfikacja na `HEAD e19121c` pokazuje, że niekwalifikowana forma komendy `--upgrade` nie ogranicza się do sekcji "### Upgrade" (`README.md:199`). Ten sam wzorzec występuje też w tabeli **"Upgrade contract"** (`README.md:319-329`), wiersz **"Submodule bump"**:

```
| **Submodule bump** | Framework vendored as submodule | Update submodule to tag, then `setup-agent-collections.sh --upgrade --sync` |
```

Ta tabela jest jedynym miejscem w README, które explicite nazywa tryb "Submodule bump" jako osobną ścieżkę — a mimo to podaje dokładnie tę samą niekwalifikowaną komendę co sekcja "### Upgrade". Naprawa Ustalenia 1 musi objąć **obie lokalizacje**, inaczej tabela "Upgrade contract" będzie nadal prowadzić konsumentów w trybie submodule na tę samą ścieżkę błędu.

Potwierdzono też, że w całym README nie ma żadnego ostrzeżenia przed `git pull` bezpośrednio wewnątrz katalogu submodułu (`grep -n "git pull" README.md` → brak wyników) — przesłanka dla Ustalenia 2 pozostaje aktualna.

## Ustalenie 3 — auto-resolve `COLLECTIONS_HOME` upraszcza rekomendowaną poprawkę (odpowiedź na Otwarte pytanie 2)

Analiza `scripts/lib/setup-agent-collections/paths.sh` (`resolve_collections_home()`, linie 6-34) pokazuje mechanizm nieudokumentowany w README, istotny dla treści poprawki:

```bash
# resolve_collections_home() — gdy brak --collections-home i brak AGENT_COLLECTIONS_HOME:
script_root="$(cd "${SETUP_SCRIPT_DIR}/.." && pwd)"   # katalog nadrzędny względem scripts/, czyli fizyczna lokalizacja wywołanego skryptu
if [[ -d "${script_root}/.ai/skills" ]]; then
  COLLECTIONS_HOME="$script_root"                      # self-checkout detection
fi
```

`SETUP_SCRIPT_DIR` to katalog, w którym **fizycznie znajduje się wywołany skrypt** (`SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"`), nie katalog roboczy powłoki. W konsekwencji: jeśli konsument w trybie submodule wywoła skrypt pod jego **prawdziwą ścieżką** —

```bash
bash vendor/agent-collections/scripts/setup-agent-collections.sh --upgrade --sync --non-interactive
```

— `resolve_collections_home()` sam wykryje `script_root = vendor/agent-collections` (bo zawiera `.ai/skills`) i ustawi `COLLECTIONS_HOME` na tę ścieżkę **automatycznie, bez potrzeby ręcznego `export AGENT_COLLECTIONS_HOME=...`**.

**Konsekwencja dla Ustalenia 1 / Opcji 1:** wariant z jawnym `export AGENT_COLLECTIONS_HOME="$(cat .agent-collections/framework-home.txt)"`, pokazany w oryginalnym Ustaleniu 1 jako "odpowiednik", jest technicznie poprawny, ale **nadmiarowy** dla trybu submodule — wystarczy sama kwalifikowana ścieżka wywołania (`vendor/agent-collections/scripts/setup-agent-collections.sh ...`). To upraszcza treść planowanej poprawki README: minimalna, wystarczająca forma dla submodule to jedna linijka z prefiksem ścieżki, bez dodatkowego kroku `export`.

Częściowo odpowiada to na **Otwarte pytanie 2**: skoro sam prefiks ścieżki wystarcza (auto-resolve już działa), rekomendacja dla treści poprawionej sekcji "### Upgrade" to pokazać **jeden zunifikowany wzorzec** — `bash "$AGENT_COLLECTIONS_HOME/scripts/setup-agent-collections.sh" --upgrade --sync ...` z komentarzem, że w trybie submodule `AGENT_COLLECTIONS_HOME` można podstawić bezpośrednio ścieżką `vendor/agent-collections` (lub jawnie wywołać skrypt pod tą ścieżką bez `export`) — zamiast dublować dwa osobne, w pełni wypisane warianty. Ostateczna decyzja co do formy nadal należy do człowieka (patrz Otwarte pytania).

## Dlaczego te dwa objawy są ze sobą powiązane

Oba wynikają z tej samej, leżącej u podstaw luki w **tym repozytorium**: nie ma jednej udokumentowanej, działającej komendy "upgrade" dla konsumentów w trybie **submodule** — a to zgodnie z `README.md` (tabela "Vendor modes") jest deklarowany domyślny tryb dla zespołów ("**TASK / team default**"). Ogólny przykład `--upgrade --sync` w sekcji "Upgrade" zakłada tryb local (`AGENT_COLLECTIONS_HOME` ustawiony na checkout poza repozytorium konsumenta) albo fizyczną obecność skryptu instalatora w katalogu głównym konsumenta — żadne z tych założeń nie zachodzi w trybie submodule. Druga komenda użytkownika w `user-profile` była próbą obejścia pierwszego błędu za pomocą surowego gita — czyli dokładnie tego wzorca, przed którym ostrzega dokumentacja samego frameworka (ad hoc komendy na submodule z pominięciem instalatora).

## Opcje na dalej (do etapu Plan, nierozstrzygnięte tutaj)

1. **Naprawa w tym repozytorium (`agent-collections`)**: doprecyzować **obie** lokalizacje w `README.md` — sekcję "### Upgrade" (linia ok. 199) **i** wiersz "Submodule bump" tabeli "Upgrade contract" (linia ok. 326, patrz Ustalenie 1 — rozszerzenie) — tak by dla trybu submodule jawnie pokazywały ścieżkę względem `AGENT_COLLECTIONS_HOME` lub `vendor/agent-collections/`, analogicznie do sekcji "Install into a consumer project" wyżej w tym samym pliku. Dzięki auto-resolve w `resolve_collections_home()` (Ustalenie 3) wystarczy pokazać kwalifikowaną ścieżkę wywołania — nie trzeba osobno dokumentować kroku `export AGENT_COLLECTIONS_HOME=...` dla trybu submodule. Rozważyć też dopisanie ostrzeżenia przed uruchamianiem `git pull` bezpośrednio wewnątrz katalogu submodułu (poza przepływem "Submodule bump") — to właśnie ta praktyka doprowadziła do dryfu opisanego w Ustaleniu 2b.
2. **Po stronie konsumenta (`user-profile`)**: po naprawieniu README, w `user-profile` trzeba będzie ręcznie zdecydować, czy zresetować checkout submodułu do ostatnio zacommitowanego pinu (`1502308a`) i wykonać upgrade na czysto, czy zaakceptować obecny zdryfowany stan (`e19121c8`) i zacommitować ten bump gitlinka — to już nie jest zadanie tego repozytorium, tylko `user-profile` (użytkownik zadeklarował, że wykona tę aktualizację samodzielnie po naprawie).
3. Rozważyć, czy warto dodać w `README.md` / dokumentacji instalatora jawne odesłanie do `.agent-collections/framework-home.txt` jako źródła prawdy o ścieżce instalatora dla konsumentów w trybie submodule/local. **Zaktualizowana ocena po Ustaleniu 3:** niższy priorytet niż pierwotnie — skoro `resolve_collections_home()` już auto-wykrywa `COLLECTIONS_HOME` z fizycznej ścieżki wywołanego skryptu, `framework-home.txt` nie jest niezbędny do poprawnego działania `--upgrade` w trybie submodule; pozostaje przydatny wyłącznie jako pomoc diagnostyczna / dokumentacyjna, nie jako wymagany krok.

## Otwarte pytania do człowieka

- Czy naprawa README (Ustalenie 1) obejmuje też dodanie ostrzeżenia/blokady przed `git pull` bezpośrednio w katalogu submodułu (Ustalenie 2), czy to osobny wątek?
- Docelowa treść poprawionej sekcji "### Upgrade" — czy ma pokazywać wariant `$AGENT_COLLECTIONS_HOME`, wariant `vendor/agent-collections/` dla submodule, czy oba warianty obok siebie (tak jak sekcja "Install into a consumer project")? **Częściowo zaadresowane w Ustaleniu 3:** techniczne uzasadnienie wskazuje na jeden zunifikowany wzorzec z prefiksem ścieżki (auto-resolve czyni osobny wariant `export` zbędnym dla submodule) — ale wybór finalnej redakcji (jeden wzorzec vs. dwa warianty jak w "Install into a consumer project") nadal wymaga decyzji człowieka.
- Czy poprawka w tabeli "Upgrade contract" (Ustalenie 1 — rozszerzenie) powinna wejść w tym samym PR co poprawka sekcji "### Upgrade", czy to celowo osobne miejsce w dokumencie i warto je aktualizować niezależnie?
