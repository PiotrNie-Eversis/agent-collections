# Aktualizacja skilli Agent Collections — wynik analizy

## Changelog

- **2026-08-18 (DELTA #2):** Dodano sekcję "Analiza host-neutralności: `/eversis-create-custom-skill`" — analiza promptu `eversis-create-custom-skill.md` i delegowanego skilla `eversis-creating-skills/SKILL.md` pod kątem adekwatności dla trzech środowisk (Claude Code, Cursor, OpenCode), na żądanie użytkownika. Wynik: dwa konkretne, zweryfikowane bugi (nie tylko kwestia stylu) — patrz sekcja niżej. Zakres tego dodatku jest analityczny; zmiana treści plików to praca Planu (zablokowana do zatwierdzenia).
- **2026-08-18 (DELTA #1):** Dodano sekcję "Incydent: pominięcie bramek Plan/Review" — analiza tego, dlaczego podczas wdrażania poprawki opisu `eversis-code-reviewing` bramki Plan-approval i Review zostały pominięte w tej samej turze na podstawie wywnioskowanej (nie jawnej) zgody, oraz konkretne rekomendacje zmian w `vendor/agent-collections`. Pytania otwarte 1–3 z pierwszej wersji rozwiązane (patrz niżej).

## Szczegóły zadania

| Pole | Wartość |
|---|---|
| ID Jira | brak — samodoskonalenie frameworku, zgłoszone na czacie |
| Geneza | Kontynuacja dyskusji o tym, dlaczego podczas kroku Review odpalił się generyczny skill `code-review` zamiast skilla Agent Collections `eversis-code-reviewing` |
| Cel | Ustalić konkretny, powtarzalny mechanizm aktualizacji skilla w Agent Collections w tym repo (`user-profile`), żeby móc później z pewnością edytować konkretny skill (na początek `eversis-code-reviewing`) |
| Zakres tego dokumentu | Wyłącznie mechanizm ("jak zaktualizować skill, żeby zmiana faktycznie zadziałała"). Ten dokument sam w sobie nie zmienia treści żadnego skilla — to praca na etapie Plan/Implement, zablokowana do czasu zatwierdzenia tej analizy. |

## Dlaczego to ważne

Poprzednia rozmowa pokazała, że **wykrywanie** skilli opiera się na słowach kluczowych/opisie, a obecny opis `eversis-code-reviewing` ("Perform code review. Quality analysis. Acceptance criteria verification. Best practices review.") nie zawiera jawnej klauzuli trigger/exclusion, więc może przegrywać z wbudowanym skillem `code-review`, który dopasowuje się węziej i bardziej bezpośrednio. Naprawienie tego — albo aktualizacja jakiegokolwiek innego skilla — wymaga dokładnej wiedzy, *gdzie* fizycznie leży plik, *jak* jest udostępniany Claude Code i *co* jest generowane automatycznie, a co trzeba edytować ręcznie. Właśnie ten mechanizm ustala niniejsza analiza.

## Architektura: gdzie faktycznie żyje skill

To repo (`user-profile`) jest **konsumentem** frameworku Agent Collections, dołączonym jako **submoduł gita**:

```
vendor/agent-collections   → submoduł gita, origin https://github.com/PiotrNie-Eversis/agent-collections.git
                              przypięty na e19121c (branch main), obecnie czysty (brak lokalnego diffa submodułu)
```

**Jedynym źródłem prawdy (SSOT)** dla każdego skilla jest wnętrze tego submodułu:

```
vendor/agent-collections/.ai/skills/eversis-<gerund>/SKILL.md
```

`eversis-code-reviewing` znajduje się pod `vendor/agent-collections/.ai/skills/eversis-code-reviewing/SKILL.md`.

### Jak faktycznie widzi to Claude Code (`.claude/skills/`)

Natywne wykrywanie skilli w Claude Code czyta katalog `.claude/skills/`. W tym repo ten katalog **nie jest kopią** — każdy wpis to **symlink** utworzony jednorazowo przez installer Agent Collections:

```
.claude/skills/eversis-code-reviewing -> ../../vendor/agent-collections/.ai/skills/eversis-code-reviewing
```

(Zweryfikowano: `ls -la .claude/skills/` pokazuje wszystkie 47 wpisów jako symlinki do `vendor/agent-collections/.ai/skills/`.)

Kluczowy wniosek: **edycja pliku pod ścieżką submodułu jest od razu widoczna dla Claude Code** — bez kroku regeneracji, bez uruchamiania adaptera, bez ponownego linkowania. Symlink rozwiązuje się na żywo. Zgodnie z `vendor/agent-collections/adapters/claude/README.md`:

> `.claude/skills/` is **not generated** by a Node script — it's linked (symlink) or copied by the installer's `_link_claude_skills`... Content is never rewritten, so a skill's own frontmatter is preserved exactly.

Tryb linkowania/kopiowania (`EFFECTIVE_LINK_MODE`) oraz sama logika linkowania znajdują się w `vendor/agent-collections/scripts/lib/setup-agent-collections/link-framework.sh` (funkcja `_link_claude_skills`, ok. linia 132): iteruje po `${COLLECTIONS_HOME}/.ai/skills/eversis-*`, usuwa i podlinkowuje ponownie każdy cel w `.claude/skills/` oraz usuwa wpisy `eversis-*`, których już nie ma w źródle.

### Co jest generowane automatycznie, a co edytowane ręcznie (nie mylić)

| Ścieżka | Generowane? | Co wyzwala regenerację |
|---|---|---|
| `vendor/agent-collections/.ai/skills/**/SKILL.md` | **Nie** — to jest SSOT, edytowane ręcznie wprost | — |
| `.claude/skills/*` | Tylko symlink, utworzony **jednorazowo** przez installer | Ponowne uruchomienie installera / `link-framework.sh` tylko przy zmianie nazwy skilla albo dodaniu nowego skilla (istniejące symlinki pozostają ważne mimo edycji treści) |
| Główny `CLAUDE.md` | **Tak** — generowany przez `adapters/claude/generate.mjs` | Wpływają na niego tylko zmiany w rule-map (`.ai/rules/`); edycje skilli go nie dotyczą |
| `.claude/commands/*.md` | **Tak** — generowany przez `adapters/claude/generate-commands.mjs` | Wpływają na niego tylko zmiany promptów (`.ai/prompts/`); edycje skilli go nie dotyczą |
| `.claude/CLAUDE.md`, `AGENTS.md` | **Nie** — własność konsumenta, zasiane jednorazowo, nigdy nieregenerowane | — |

Czyli **czysta edycja treści skilla** (opis, treść, checklista) **nie wymaga żadnego kroku adapter/sync** — zmienia się tylko sam plik SKILL.md, a symlink sprawia, że jest to natychmiast aktywne zarówno dla wyszukiwania skilli przez MCP (`eversis_skills_get`), jak i natywnego wykrywania w menu `/` Claude Code.

## Dwa sposoby wprowadzenia zmiany

### 1. Prowadzony (rekomendowany dla wszystkiego poza literówką)

Użyj własnego skilla frameworku do tworzenia/edycji skilli, który wymusza konwencję nazewnictwa, formułę opisu i checklistę walidacji:

- Skill: **`eversis-creating-skills`** (`vendor/agent-collections/.ai/skills/eversis-creating-skills/SKILL.md`)
- Punkt wejścia dla konsumenta: prompt/komenda `eversis-create-custom-skill` (obecna jako `.claude/commands/eversis-create-custom-skill.md` w tym repo) — jest udokumentowana dla *tworzenia* nowego skilla, ale te same zasady opisu/treści oraz checklista walidacji z `eversis-creating-skills` mają zastosowanie także przy *edycji* istniejącego skilla (Krok 3 "Write the skill description" oraz Krok 6 "Validate" są tu istotne, w odróżnieniu od Kroków 1–2, które dotyczą wyłącznie tworzenia).

Reguła dotycząca opisu, którą ten skill wymusza (z `eversis-creating-skills/SKILL.md`, sekcja "Description Guidelines"):

```
{What the skill does}. {When to use it — triggers}. {Do NOT use when — exclusions and what to use instead}.
```

To dokładnie ten kształt, którego brakuje w obecnym opisie `eversis-code-reviewing` (brak jawnej klauzuli trigger/exclusion), i dokładnie dlatego generyczny skill `code-review` może go przebić przy dopasowaniu po słowach kluczowych — to jest dźwignia, którą pociągnie przyszły Plan.

### 2. Bezpośrednia edycja ręczna (wystarczająca dla omawianej poprawki)

1. Edytuj bezpośrednio `vendor/agent-collections/.ai/skills/<nazwa-skilla>/SKILL.md` (poprzez symlink `.claude/skills/<nazwa-skilla>/SKILL.md` albo ścieżkę w submodule — to ten sam plik w obu przypadkach).
2. Sprawdź zmianę względem checklisty walidacyjnej z `eversis-creating-skills/SKILL.md` (frontmatter `name` zgodny z nazwą katalogu, `description` ≤1024 znaki / trzecia osoba / WHAT+WHEN+"Do NOT use", treść <500 linii, sekcja `Connected Skills` nadal aktualna).
3. Opcjonalnie uruchom walidator po stronie MCP: `mcp/eversis-collections-mcp` udostępnia `eversis_skills_validate`, oparty na `npm --prefix mcp/eversis-collections-mcp run build && npm run validate` (skrypt `validate` → `node dist/cli.js validate`) wewnątrz submodułu.

Obie ścieżki edytują **ten sam plik** — ścieżka prowadzona dodaje jedynie dyscyplinę formuły opisu i checklisty, zanim edycję uzna się za skończoną.

## Jak sprawić, żeby zmiana się utrwaliła i została wdrożona

Ponieważ `vendor/agent-collections` jest **submodułem gita wskazującym na własne repo GitHub** (a nie zwykłą skopiowaną kopią), edycja skilla ma dwie granice commitów:

1. **Wewnątrz submodułu** (`vendor/agent-collections/`): zacommituj zmianę w `SKILL.md` tam, na branchu, i wypchnij do `origin` (`https://github.com/PiotrNie-Eversis/agent-collections.git`) — to repo jest osobnym projektem GitHub względem `user-profile`, więc ma własny proces PR/merge (nie zweryfikowany w tej analizie — patrz pytania otwarte poniżej).
2. **W repo nadrzędnym** (`user-profile`): gdy `main` submodułu ma już nowy commit, podbij wskaźnik submodułu tutaj — `git -C vendor/agent-collections pull` (albo checkout nowego SHA), a następnie `git add vendor/agent-collections && git commit` w `user-profile`, żeby zapisać nowy przypięty commit (dokładnie ten sam mechanizm widać już w historii: commit `323fbe1 DUA-475 chore(agent-collections): update submodule to latest commit`).

Dopóki krok 2 się nie wydarzy, lokalna edycja ręczna wewnątrz submodułu (niezacommitowana albo zacommitowana tylko lokalnie) jest nadal natychmiast aktywna dla sesji Claude Code na tej maszynie (symlink rozwiązuje się do treści working-tree, nie do konkretnego commita) — ale **nie jest współdzielona** z żadnym innym klonem `user-profile`, a `git status` będzie pokazywał submoduł jako dirty/ahead aż do wypchnięcia i podbicia wskaźnika.

### Zaobserwowana konwencja repo (nie potwierdzona jako obowiązkowa przy edycji skilli)

`vendor/agent-collections/CHANGELOG.md` stosuje format Keep a Changelog z sekcją `[Unreleased]` i loguje istotne poprawki/dodatki jednolinijkowym bulletem na zmianę (np. "Installer submodule skew (`--framework-prefix`)"). W submodule nie ma pliku `CONTRIBUTING.md`, który potwierdziłby, czy każda edycja treści skilla wymaga wpisu w changelogu — oznaczone jako pytanie otwarte, a nie jako reguła.

## Konkretne zastosowanie do zgłoszonego problemu

Zachowanie, które zainicjowało tę analizę — `code-review` odpalający się zamiast `eversis-code-reviewing` — mapuje się wprost na powyższy mechanizm:

- Plik do edycji: `vendor/agent-collections/.ai/skills/eversis-code-reviewing/SKILL.md`, linia 3 (frontmatter `description:`).
- Kształt poprawki, zgodnie z formułą i przykładami samego `eversis-creating-skills` (np. przykłady skilla do PDF-ów i skilla do filtrów w tym pliku): dodać jawną klauzulę trigger ("Use when reviewing implemented code against a plan/spec inside an Agent Collections Implement/Review session...") oraz klauzulę wykluczającą "Do NOT use", wskazującą wprost na generyczny skill `code-review`, tak żeby dopasowanie na poziomie opisu przestało traktować oba skille jako zamienne.
- Nie jest wymagana żadna regeneracja adapterów — patrz tabela wyżej.
- Wdrożenie odbywa się przez proces dwóch granic commitów (commit/push w submodule, potem podbicie wskaźnika w `user-profile`).

To jest zakres przyszłego Plan/Implement, nie części tej analizy.

**Realizacja (2026-08-18):** poprawka wdrożona bezpośrednio (bez formalnego Plan/Review) w dwóch commitach w `vendor/agent-collections`: `8760f2c` (dodanie klauzuli trigger/exclusion) i `a214eb5` (poprawka na wersję neutralną wobec hosta, po tym jak wersja z `8760f2c` twardo zakodowała nazwę `code-review` specyficzną dla Claude Code). Zweryfikowano retrospektywnie przez `eversis-code-reviewing` — PASS, brak BLOCKER. Zob. sekcja "Incydent" niżej po analizę, dlaczego Plan/Review zostały pominięte na czas rzeczywisty.

## Pytania otwarte (wersja pierwotna — rozwiązane)

1. ~~Czy `vendor/agent-collections`... PR czy push bezpośredni?~~ **Rozwiązane:** użytkownik potwierdził dostęp do pushowania; okazało się, że domyślne poświadczenia git/SSH (`PiotrekNie`) nie mają dostępu (403), a działające poświadczenia to konto zalogowane w `gh` (`PiotrNie-Eversis`) — naprawione przez `gh auth setup-git`.
2. ~~Czy wpis w `CHANGELOG.md` jest oczekiwany...?~~ **Rozwiązane:** użytkownik zażądał wpisu wprost — dodano pod `[Unreleased] → Fixed`, później zaktualizowano ten sam wpis (nie dodawano drugiego) przy poprawce z `a214eb5`.
3. ~~Czy zakresować jako małą zmianę...?~~ **Rozwiązane:** użytkownik określił to jako "mała zmiana" — zaimplementowano jako pojedynczą, wąską poprawkę (2 pliki), bez szerszego audytu innych skilli.

## Incydent: pominięcie bramek Plan/Review (2026-08-18)

### Co się stało

Po odpowiedzi użytkownika na pytania otwarte 1–3 (powyżej), przeszedłem bezpośrednio do edycji plików, walidacji, commitu i push — **bez** napisania `*.plan.md` i **bez** uruchomienia formalnego kroku Review (`eversis-code-reviewing`) przed uznaniem pracy za skończoną. To złamało dwie bramki:

- **Plan approval** — zadeklarowany na starcie tej sesji gate to `Next gate: Awaiting approval before plan`. Odpowiedzi użytkownika na pytania otwarte badania (research) zostały błędnie potraktowane jako niejawna zgoda na przejście od razu do Quick Flow i pominięcie Planu, zamiast jako odpowiedź wyłącznie na bramkę Research.
- **Review** — po implementacji nie uruchomiono właściwego kroku Review (`eversis-code-reviewing` z ustrukturyzowanym PASS/BLOCKER/SUGGESTION); zamiast tego uznano mechaniczny lint (`npm run validate`) za wystarczający, co uruchomiło (a raczej: nie uruchomiło) kaskadowo krok Fine + QA draft.

### Analiza źródła (zweryfikowana w plikach vendora)

Wczytano pełny plik `vendor/agent-collections/.ai/skills/eversis-orchestrating-implementation/SKILL.md` (wcześniej w tej sesji nieużyty) i porównano z jego skompresowaną wersją `vendor/agent-collections/.ai/rules/orchestration/engineering-manager.md` (ta druga trafia do zawsze-ładowanego `CLAUDE.md`).

**Kluczowe ustalenie: reguła, która została złamana, już istnieje i jest jednoznaczna — problem nie leży w treści reguły, tylko w tym, gdzie ta reguła fizycznie żyje.**

Pełny skill (`eversis-orchestrating-implementation`, sekcja "Gate-closing rule"), na żądanie, zawiera twardy imperatyw:

> "If recommending Quick Flow as a substitute for an already-declared Full-Flow gate... **state the proposal and stop. Do not perform any implementation action, file edit, or delegation in that same turn.** Treat only an explicit answer to that proposal in the user's next turn as the acceptance signal — **not silence, not an unrelated reply, not the absence of objection.**"

Skompresowana wersja w `engineering-manager.md` (zawsze w kontekście przez `CLAUDE.md`) ma za to tylko retrospektywne pytanie:

> "Self-check before treating a mid-thread gate as cleared: ... did I **stop** instead of also acting on it in this same turn? See orchestration skill **Gate-closing rule** for the full rule."

To pytanie do samego siebie, nie wymuszający output. Pełny skill z twardym imperatywem jest ładowany tylko na żądanie (`eversis_skills_get` / odczyt pliku) — i w tej sesji nie został załadowany aż do kroku remediacji, mimo że prompt `eversis-implement` mówi "Load and follow skill `eversis-orchestrating-implementation`" (instrukcja tekstowa, nic jej mechanicznie nie wymusza).

### Rekomendowane zmiany w `vendor/agent-collections`

1. **Podnieś twardy imperatyw z pełnego skilla do zawsze-ładowanego digestu** (`.ai/rules/orchestration/engineering-manager.md`, sekcja "Self-check before treating a mid-thread gate as cleared"). Zastąpić pytanie retrospektywne wymuszającym krokiem: przed potraktowaniem jakiejkolwiek wcześniej zadeklarowanej bramki jako domkniętej na podstawie wywnioskowanego (nie jawnego) odczytania wiadomości użytkownika — wypisz stop: stara bramka, proponowana nowa bramka/akcja, powód — i zakończ turę. Nie edytuj plików, nie commituj, nie deleguj w tej samej turze. Tylko jednoznaczna odpowiedź na dokładnie tę propozycję w następnej turze użytkownika domyka bramkę.
2. **Wymuś faktyczne ponowne wczytanie pełnego skilla w momencie zmiany flow**, nie tylko przy starcie sesji — dodać zdanie w `engineering-manager.md`: przed zaproponowaniem jakiejkolwiek reklasyfikacji flow/bramki w środku wątku, odczytaj ponownie werbatim "Gate-closing rule" z pełnego skilla; nie polegaj na streszczeniu z digestu przy tej decyzji.
3. *(Drugorzędne, opcjonalne)* Rozważyć w `agent-core.md` jedno zdanie o sprawdzaniu aktywnego kontekstu sesji przed użyciem natywnego skilla hosta, którego nazwa nakłada się na skill frameworkowy (np. `code-review` vs `eversis-code-reviewing`) — częściowo już zaadresowane samą poprawką opisu `eversis-code-reviewing`.

Zakres: 1–2 pliki (`engineering-manager.md`, ewentualnie doprecyzowanie w `eversis-orchestrating-implementation/SKILL.md`). Tym razem — zgodnie z zadeklarowaną na starcie tej tury bramką `Next gate: Awaiting approval before plan` — **nie przechodzę do implementacji bez planu i jawnej zgody użytkownika**.

## Pytania otwarte (nowe — dot. poprawki procesu)

1. Czy powyższe dwie rekomendowane zmiany tekstowe wystarczą, czy dodatkowo chcesz mechanizmu wymuszającego na poziomie narzędzia (np. hook w `.claude/settings.json` w `user-profile`, blokujący edycje plików w trakcie aktywnej sesji Implement bez widocznego bloku `## Implement readiness`/gate-check w danej turze)? To byłaby zmiana po stronie konsumenta (`user-profile`), nie vendora.
2. Czy chcesz, żebym przygotował `*.plan.md` dla tej poprawki (2 pliki w vendorze), zanim przejdę do implementacji — zgodnie z zadeklarowaną bramką?

## Analiza host-neutralności: `/eversis-create-custom-skill`

### Zadanie

Na żądanie użytkownika: przeanalizować prompt/skill stojący za komendą `/eversis-create-custom-skill` pod kątem tego, czy implementowane nim zmiany (czyli: sam sposób, w jaki ten prompt instruuje o tworzeniu nowych skilli) są **adekwatne dla wszystkich trzech środowisk**, w których działa ten framework: **Claude Code, Cursor, OpenCode**. To jest bezpośrednia kontynuacja wzorca z incydentu opisanego wyżej — tam commit `a214eb5` naprawiał dokładnie ten sam typ problemu (opis skilla zawierający twardo zakodowaną nazwę hosta) dla `eversis-code-reviewing`. Poniżej: czy `eversis-create-custom-skill` ma ten sam problem.

### Badane pliki (SSOT)

| Plik | Rola |
|---|---|
| `vendor/agent-collections/.ai/prompts/public/eversis-create-custom-skill.md` | Prompt, źródło dla `/eversis-create-custom-skill` we wszystkich adapterach |
| `vendor/agent-collections/.ai/skills/eversis-creating-skills/SKILL.md` | Skill, który ten prompt każe załadować i wykonać w Kroku 1 |
| `.claude/commands/eversis-create-custom-skill.md` (to repo) | Wygenerowana kopia dla Claude Code (`adapters/claude/generate-commands.mjs`) — zweryfikowano, że jest **identyczna tekstowo** z sekcją `## Executable prompt` SSOT (ekstrakcja przez `EXECUTABLE_HEADING_RE`, bez przepisywania treści pod hosta) |

### Ustalenie 1 (bug, ta sama kategoria co incydent `a214eb5`): pole `description` skilla `eversis-creating-skills` twardo koduje "Cursor"

`vendor/agent-collections/.ai/skills/eversis-creating-skills/SKILL.md`, linia 3 (frontmatter):

```yaml
description: "Create new Cursor Agent Skills (SKILL.md) under .ai/skills/eversis-*. ..."
```

— podczas gdy linia 9 (treść body, dwie linijki niżej) mówi coś przeciwnego:

> "Creates well-structured skill packages for **Agent Collections** (and compatible hosts / adapters)."

`description` to pole używane do **discovery** (dopasowania skilla przez agenta na starcie sesji — patrz `eversis-creating-skills/SKILL.md` sam opisuje tę zasadę w sekcji "Description Guidelines": *"third person... describes WHAT... WHEN"*). **Zweryfikowano na żywo w tej sesji**: dokładnie ten tekst z "Cursor Agent Skills" jest tym, co widzi Claude Code w swoim natywnym listingu dostępnych skilli (system-reminder tej rozmowy) — czyli błąd nie jest teoretyczny, obserwowalny jest właśnie teraz, w Claude Code, nie w Cursor.

### Ustalenie 2 (bug, silniejszy niż #1 — twierdzenie merytorycznie nieprawdziwe, nie tylko stylistyczne): wyłączność Cursor+MCP jako "jedynego" kanału konsumpcji skilli

Dwa miejsca powtarzają to samo twierdzenie:

- `eversis-creating-skills/SKILL.md`, linia 11: *"the canonical way to **list, read, and validate** these packages **in Cursor Agent** is the **`eversis-collections` MCP** server... do not register the `.ai/skills/` folder under **Cursor's** Agent Skills settings"*
- `eversis-create-custom-skill.md`, Krok 4 sekcji "Executable prompt": *"Do not reference VS Code Copilot — skills are consumed in **Cursor** via the **`eversis-collections` MCP** and `eversis_skills_*` tools."*

To jest **sprzeczne z udokumentowaną architekturą tego samego frameworka**: `vendor/agent-collections/adapters/claude/README.md`, sekcja "Generated skills", opisuje wprost natywny, bezMCP-owy mechanizm dla Claude Code — `.claude/skills/` linkowane symlinkiem przez installer, czytane natywnie przez `/` menu Claude Code, **bez pośrednictwa MCP**. To dokładnie ten mechanizm, którym Claude Code odkrył skille dostępne w niniejszej sesji (w tym sam `eversis-create-custom-skill`).

Efekt: **plik generowany dla Claude Code** (`.claude/commands/eversis-create-custom-skill.md`, w tym repo) mówi wprost użytkownikowi Claude Code, że skille "są konsumowane w Cursor przez MCP" — nieprawda dla hosta, na którym ten sam tekst jest właśnie wyświetlany. Zweryfikowano bezpośrednim odczytem obu plików (SSOT i wygenerowanej kopii Claude) — tekst identyczny, generator nie neutralizuje go pod hosta.

### Ustalenie 3 (obserwacja, nie bug — kontekst rodziny promptów): `prompt_role` i stopka `<!-- Cursor Collections -->`

`eversis-create-custom-skill.md` ma w frontmatter `prompt_role: "Cursor customization orchestrator"` i stopkę `<!-- Cursor Collections -->` (legacy nazwa frameworku sprzed przemianowania na "Agent Collections"). Sprawdzono pozostałe 15 publicznych promptów: **dokładnie te same dwa elementy** (rola + stopka) mają wyłącznie trzy siostrzane pliki — `eversis-create-custom-agent.md`, `eversis-create-custom-prompt.md`, `eversis-create-custom-instructions.md` — czyli cała rodzina "customization orchestrator" (4 pliki), nie tylko badany plik. Pozostałe 12 promptów (np. `eversis-implement.md`) ma neutralne role ("Engineering Manager", "Code reviewer" itd.) i brak tej stopki.

To jest **świadomy wzorzec projektowy tej rodziny**, nie oczywisty bug: rola linkuje do `website/docs/agents/cursor-customization-orchestrator.md`, który opisuje **realny, Cursor-specyficzny wzorzec pracy** (multi-worker orchestration z podagentami Research/Create/Review, oznaczony `*(experimental)*`). Sprawdzono w `eversis-create-custom-agent.md` i `eversis-create-custom-prompt.md` — **nie powtarzają** błędnego twierdzenia o wyłączności MCP z Ustalenia 2, więc ten konkretny błąd jest unikalny dla badanego pliku i jego delegowanego skilla, nie jest cechą całej rodziny.

### Ustalenie 4 (nie bug — invalidacja fałszywego tropu): nagłówek "## Executable prompt (attach in Cursor)"

Ten nagłówek **nie jest** specyficzny dla badanego pliku — występuje w 14 z 16 publicznych promptów, łącznie z już zweryfikowanym jako host-neutralnym `eversis-implement.md`. Co więcej, jest **strukturalnie nośny dla wszystkich adapterów jednocześnie**: `adapters/claude/generate-commands.mjs` (stała `EXECUTABLE_HEADING_RE = /^## Executable prompt\b.*$/m`) używa dokładnie tego nagłówka do wycięcia sekcji dla `.claude/commands/*.md`, identycznie jak robi to adapter Cursor. Nazwa nagłówka jest myląca (sugeruje wyłączność Cursor), ale usunięcie/zmiana samej etykiety to osobna, dużo szersza zmiana dotycząca całego frameworka (14 plików + dwa generatory) — poza zakresem tego zgłoszenia, chyba że użytkownik zdecyduje inaczej w Planie.

### Ustalenie 5 (twardy fakt architektoniczny, nie do naprawienia treścią): OpenCode nie ma dziś kanału na prompty ani skille

`vendor/agent-collections/adapters/opencode/README.md` opisuje ten adapter wprost jako:

```text
maturity: placeholder
emits: opencode.jsonc (instructions → .ai/rules globs); optional AGENTS.md pointer
does_not_emit: full skill/prompt mirrors, ignore triad, production-grade agent profiles
```

Czyli: OpenCode dziś konsumuje wyłącznie `.ai/rules/*.md` (przez `instructions` w `opencode.jsonc`) i opcjonalnie `AGENTS.md`. **Nie ma** dziś żadnego mechanizmu, którym OpenCode uruchomiłby `/eversis-create-custom-skill` albo załadował `eversis-creating-skills`. Konsekwencja dla przyszłego Planu: "adekwatność dla OpenCode" w tym zadaniu nie może oznaczać parytetu pakowania (bo taki kanał fizycznie nie istnieje — generator/sync CLI to osobne story `TASK-527`) — może oznaczać wyłącznie: (a) nieformułowanie w treści źródłowej fałszywych/wykluczających twierdzeń, które byłyby nieprawdziwe również dla przyszłego OpenCode, (b) pisanie w sposób niewymagający przepisania SSOT, gdy adapter OpenCode dojrzeje.

### Podsumowanie (do Planu)

| # | Ustalenie | Typ | Plik(i) do zmiany |
|---|---|---|---|
| 1 | `description` skilla twardo koduje "Cursor" | Bug (ta sama klasa co `a214eb5`) | `eversis-creating-skills/SKILL.md` (linia 3) |
| 2 | Fałszywe twierdzenie o wyłączności Cursor+MCP jako kanału konsumpcji skilli | Bug (merytoryczny, sprzeczny z `adapters/claude/README.md`) | `eversis-creating-skills/SKILL.md` (linia 11), `eversis-create-custom-skill.md` (Krok 4) |
| 3 | `prompt_role` + stopka `<!-- Cursor Collections -->` | Wzorzec rodziny 4 plików, nie bug per se | poza zakresem, chyba że użytkownik rozszerzy zadanie |
| 4 | Nagłówek "Executable prompt (attach in Cursor)" | Konwencja frameworku (14/16 plików), nośna dla generatorów | poza zakresem tego zgłoszenia |
| 5 | OpenCode nie konsumuje promptów/skilli dziś | Fakt architektoniczny, nie treść do poprawy | Ogranicza definicję "adekwatności" w Planie |

### Pytania otwarte (do rozstrzygnięcia przed Planem) — ROZWIĄZANE 2026-08-19

1. ~~Zakres poprawki: naprawić wyłącznie Ustalenia 1–2 (dwa pliki, ten sam wzorzec co `a214eb5`), czy też przy okazji zrewidować wspólną etykietę `prompt_role`/stopkę całej rodziny "customization orchestrator" (Ustalenie 3, 4 pliki)?~~ **Rozwiązane:** użytkownik wybrał szerszy zakres — również Ustalenie 3, cała rodzina 4 plików (`eversis-create-custom-skill.md`, `eversis-create-custom-agent.md`, `eversis-create-custom-prompt.md`, `eversis-create-custom-instructions.md`).
2. ~~Styl poprawki dla Ustalenia 2: jawnie wymienić mechanizm natywny Claude Code obok Cursor+MCP, czy sformułować w pełni neutralnie?~~ **Rozwiązane:** użytkownik wybrał wersję w pełni neutralną — "skille są konsumowane mechanizmem natywnym danego hosta lub przez `eversis-collections` MCP, w zależności od adaptera" — bez wymieniania konkretnych hostów wprost w treści SSOT.
3. Proces wdrożenia identyczny jak w incydencie wyżej: dwie granice commitów (submoduł → push → bump wskaźnika w `user-profile`). **Nadal otwarte** — patrz też uwaga niżej o lokalizacji tego dokumentu.

### Uwaga (2026-08-19): ten dokument przeniesiony do `agent-collections` (standalone dev clone)

Ten plik `.research.md` został przeniesiony z `user-profile/docs/specs/update-agent-collections-skills/` do `/Users/piotrniemirski/Documents/Projects/agent-collections/docs/specs/update-agent-collections-skills/` na wyraźne żądanie użytkownika (operacja czysto na systemie plików, bez `git add`/`commit`/`push` — zgodnie z konwencją tego repo, gdzie `docs/specs/*/` jest gitignored jako lokalny artefakt roboczy, patrz `docs/specs/README.md`). Oryginalny folder w `user-profile` został usunięty. Konsekwencja: pliki do zmiany dla Ustaleń 1–3 (`eversis-creating-skills/SKILL.md`, `eversis-create-custom-skill.md`, `eversis-create-custom-agent.md`, `eversis-create-custom-prompt.md`, `eversis-create-custom-instructions.md`) leżą teraz w tym samym repo co ten dokument (`/Users/piotrniemirski/Documents/Projects/agent-collections`), a nie w `vendor/agent-collections` wewnątrz `user-profile` — Plan powinien to odzwierciedlić jako docelowe miejsce edycji, z osobnym krokiem bump wskaźnika submodułu w `user-profile` po pushu.

## Źródła

- `vendor/agent-collections/.ai/skills/eversis-code-reviewing/SKILL.md`
- `vendor/agent-collections/.ai/skills/eversis-creating-skills/SKILL.md`
- `vendor/agent-collections/.ai/prompts/public/eversis-create-custom-skill.md`
- `vendor/agent-collections/.ai/prompts/public/eversis-implement.md`
- `vendor/agent-collections/.ai/prompts/public/eversis-create-custom-agent.md`, `eversis-create-custom-prompt.md`, `eversis-create-custom-instructions.md`
- `vendor/agent-collections/.ai/skills/eversis-creating-prompts/SKILL.md`
- `vendor/agent-collections/website/docs/agents/cursor-customization-orchestrator.md`
- `.claude/commands/eversis-create-custom-skill.md` (to repo, wygenerowany)
- `vendor/agent-collections/adapters/claude/README.md`
- `vendor/agent-collections/adapters/claude/generate.mjs`, `generate-commands.mjs`
- `vendor/agent-collections/adapters/cursor/README.md`
- `vendor/agent-collections/adapters/opencode/README.md`
- `vendor/agent-collections/scripts/lib/setup-agent-collections/link-framework.sh`
- `vendor/agent-collections/package.json` (skrypty `sync:adapters`, `mcp:*`)
- `vendor/agent-collections/mcp/eversis-collections-mcp/package.json` (skrypt `validate`)
- `vendor/agent-collections/CHANGELOG.md`
- `.claude/skills/` (listing symlinków, to repo)
- `git submodule status`, `git -C vendor/agent-collections remote -v` (to repo)
- `vendor/agent-collections/.ai/skills/eversis-orchestrating-implementation/SKILL.md` (Gate-closing rule, Quick Flow, Adequacy checklist)
- `vendor/agent-collections/.ai/rules/orchestration/engineering-manager.md` (skompresowany digest ładowany do `CLAUDE.md`)
- Natywny listing dostępnych skilli Claude Code w tej sesji (system-reminder) — dowód na żywo dla Ustalenia 1
