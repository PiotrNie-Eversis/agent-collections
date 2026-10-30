# Website docs — `skills/**` i `prompts/**` na modelu SSOT `.ai/` (research)

| Pole | Wartość |
|------|---------|
| Zadanie | Audyt i naprawa `website/docs/skills/**` i `website/docs/prompts/**` — strony opisują framework sprzed modelu SSOT `.ai/` + adaptery (Cursor/Claude Code/OpenCode), jakby jedyną powierzchnią było `.cursor/` |
| Jira | Follow-up bez własnego ID — zapisany jako otwarty follow-up w `global-domain-context-ssot-website-docs.plan.md` §"Improvements (Out of Scope)" i w `.research.md` tego samego zadania, Q2, jako **W11** |
| Status | **Zatwierdzony — Q1-Q6 rozstrzygnięte przez stakeholdera 2026-08-27 (Q1=b, Q2=b, Q3=a, Q4=a, Q5=a, Q6=a); zob. plan** |
| Powiązane | [`../global-domain-context-ssot-website-docs/global-domain-context-ssot-website-docs.research.md`](../global-domain-context-ssot-website-docs/global-domain-context-ssot-website-docs.research.md) (§"Sprawdzone, bez osobnego numeru" i Q2 — pierwotne zgłoszenie W11), [`../global-domain-context-ssot-website-docs/global-domain-context-ssot-website-docs.plan.md`](../global-domain-context-ssot-website-docs/global-domain-context-ssot-website-docs.plan.md) (§"Improvements (Out of Scope)" — sekwencja: W11 najpierw, potem poprawka liczby skilli + 3 nowe strony), [`../claude-code-setup-website-docs/claude-code-setup-website-docs.research.md`](../claude-code-setup-website-docs/claude-code-setup-website-docs.research.md) (pierwotne odkrycie W11 przy audycie W1-W10) |
| Data | 2026-08-26 |
| Język | polski (kontynuacja konwencji dwóch powiązanych researchów) |
| Wzorzec strukturalny | ten sam co poprzednie audyty `website/docs/**`: grep → pełny odczyt reprezentatywnej próbki → wzorzec błędu (klasy, nie tylko pojedyncze linie) → tabela liczb → otwarte pytania → zakres do Planu |

---

## 1. Cel i zakres

**Pytanie:** czy `website/docs/skills/**` i `website/docs/prompts/**` (77 plików) opisują framework zgodnie z rzeczywistym modelem — kanoniczna treść pod `.ai/` (rules, skills, prompts), skonsumowana przez **trzy** adaptery (`adapters/cursor/`, `adapters/claude/`, `adapters/opencode/` — placeholder) przez `npm run sync:adapters` — czy nadal jako jedyny, "natywny" model Cursor (`.cursor/skills/`, `.cursor/prompts/`, `@` attachment, `.cursor/rules/*.mdc`)?

**W zakresie:** wyłącznie `website/docs/skills/**` (44 pliki) i `website/docs/prompts/**` (33 pliki, licząc `overview.md` + 3× `_category_.json`) — łącznie 77 plików.

**Poza zakresem:** wszystko poza tymi dwoma drzewami (już pokryte przez `global-domain-context-ssot-website-docs.plan.md`, obecnie po Implement/Review PASS, przed Fine).

**Metoda:** `grep -rl '\.cursor/\|\.claude/\|@eversis-'` po obu drzewach, pełny odczyt reprezentatywnej próbki (8 plików pokrywających wszystkie znalezione klasy), krzyżowa weryfikacja z rzeczywistym stanem repo: `README.md`, `adapters/{cursor,claude,opencode}/`, `adapters/sync.mjs`, `website/package.json`, root `package.json`, liczba plików pod `.ai/skills/`, `.ai/prompts/{public,internal}/`.

---

## 2. Stan wyjściowy — potwierdzony model (ground truth z `README.md` i realnej struktury repo)

| Element | Rzeczywisty stan (2026-08-26) |
|---|---|
| Kanoniczna treść | `.ai/` (rules, skills, prompts) — **"Adapters, the installer, and MCP consume that content — they do not own it"** (`README.md:25`) |
| Adaptery | **trzy**: `adapters/cursor/`, `adapters/claude/` (generuje `.claude/commands/` przez `generate-commands.mjs`), `adapters/opencode/` (placeholder) — nie tylko Cursor |
| Mechanizm sync | `npm run sync:adapters` (`adapters/sync.mjs`) — odświeża `.cursor/rules/*.mdc` i `.claude/commands/*.md` z `.ai/`; **usuwa orphany** (`README.md:348`) |
| `.cursor/skills/`, `.cursor/prompts/` | **Nie istnieją jako pełne lustro** — `README.md:159`: *"This distribution does **not** ship a full mirror of skills/prompts under `.cursor/skills` or `.cursor/prompts`. The Cursor adapter **does** generate thin slash shims under `.cursor/commands/`"* |
| Liczba skilli | **48** folderów pod `.ai/skills/*/` |
| Liczba promptów public | **16** pod `.ai/prompts/public/*.md` |
| Liczba promptów internal | **12** pod `.ai/prompts/internal/*.md` (razem **28**, nie licząc `overview.md`) |
| Sync `website/docs/prompts/`↔`.ai/prompts/` | **Nie istnieje żaden skrypt** — `website/package.json` ma wyłącznie `sync-changelog`; root `package.json` ma `sync:adapters` (→ `.cursor/`, `.claude/`), nie `website/docs/` |
| Wywołanie promptów w tym repo (Claude Code, ten wątek) | `.ai/prompts/public/eversis-implement.md` przez `Skill`/adapter Claude Code (`/eversis-implement`), **nie** `@` attachment Cursor |

**Wniosek:** to nie jest "kilka nieaktualnych ścieżek" — `website/docs/skills/**` i `website/docs/prompts/**` opisują architekturę, która **nigdy nie miała pełnego lustra na dysku** (Cursor-only "mirror" nie istnieje w MVP) i **nie ma dziś żadnego mechanizmu synchronizacji** ze źródłem `.ai/`, mimo że jedna ze stron (`prompts/overview.md`) explicite twierdzi, że taki mechanizm (`sync-prompts`) istnieje i jest uruchamiany przy `npm run build`. `README.md:209` linkuje do `website/docs/prompts/overview.md` jako "full catalog" — czytelnik odsyłany z aktualnego, poprawnego README trafia na stronę opisującą nieistniejący już model.

---

## 3. Skala — 73 z 77 plików dotkniętych

```
grep -rl '\.cursor/\|\.claude/\|@eversis-' website/docs/skills website/docs/prompts
→ 73 plików (44−1=43 w skills/ [bez _category_.json], 28 w prompts/public+internal, 1 overview.md, minus... patrz rozbicie niżej)
```

| Drzewo | Plików ogółem | Dotkniętych | Niedotknięte |
|---|---|---|---|
| `website/docs/skills/` | 44 | 43 (wszystkie oprócz `_category_.json`) | `_category_.json` |
| `website/docs/prompts/public/` | 16 | 16 | — |
| `website/docs/prompts/internal/` | 12 | 12 | — |
| `website/docs/prompts/` (root) | 2 (`overview.md`, `_category_.json`) | 1 (`overview.md`) | `_category_.json` |
| `website/docs/prompts/{public,internal}/_category_.json` | 2 | 0 | oba |
| **Razem** | **77** | **73** | **4** (same `_category_.json`) |

To nie jest wybiórczy zestaw — **każda** merytoryczna strona w obu drzewach jest dotknięta w jakimś stopniu. Pełna lista 73 plików: zob. §7 Źródła (odtwarzalne jednym poleceniem `grep`).

---

## 4. Wzorzec błędu — pięć powtarzających się klas (nie 73 unikalne znaleziska)

### P1 — Ścieżka kanoniczna podana jako `.cursor/...` zamiast `.ai/...`

Powtórzone niemal identycznie na **każdej** z 73 stron, np.:
- `skills/creating-prompts.md:8`: `**Folder:** `.cursor/skills/eversis-creating-prompts/`` — realna lokalizacja to `.ai/skills/eversis-creating-prompts/`.
- `prompts/internal/eversis-research.md:16`: `**File:** `.cursor/prompts/internal/eversis-research.md`` — realnie `.ai/prompts/internal/eversis-research.md`.
- `skills/overview.md:8`: *"Skills are stored in `.cursor/skills/`."*

**Mechaniczna poprawka:** `.cursor/skills/` → `.ai/skills/`, `.cursor/prompts/` → `.ai/prompts/` — ale **nie** czyste find-replace, bo część zdań buduje wokół tego całą narrację "Cursor to jedyny host" (patrz P3).

### P2 — Nieistniejący mechanizm auto-sync do `website/docs/`

`prompts/overview.md:9` (jedyne źródło tego twierdzenia, ale wysokiej dźwigni — strona-indeks całego drzewa `prompts/`):
> *"From the repository's `website/` directory, `npm run start` and `npm run build` run **`sync-prompts`** first, copying these files into `website/docs/prompts/`... The generated `eversis-*.md` copies there are gitignored and are listed in `.cursorignore`"*

Potwierdzone jako fałszywe: `website/package.json` nie ma skryptu `sync-prompts`; te pliki **nie są gitignored** (są śledzone przez git, w przeciwnym razie by tu nie istniały do audytu) ani wpisane w `.cursorignore` pod tym kątem. To pojedyncze zdanie, ale krytyczne — czytelnik szukający "skąd biorą się te pliki" dostaje fałszywy, nieistniejący mechanizm zamiast prawdy: **są ręcznie utrzymywaną, osobną kopią bez automatycznej synchronizacji.**

### P3 — Cursor przedstawiony jako jedyny/domyślny host, Claude Code nieobecny

- `prompts/overview.md:7`: *"This framework includes **12 public prompts** — Markdown workflow definitions for **Cursor** (Chat or Agent)."*
- `prompts/overview.md:11-17`: `@` attachment i `/` project command opisane jako "Two equivalent options" — oba **Cursor-specyficzne**; brak wzmianki o `Skill`/`/eversis-*` w Claude Code (mechanizm, którym faktycznie działa **ten** wątek).
- `skills/creating-prompts.md:11`: *"**`.cursor/prompts/public/eversis-*.md`**"* — jako jedyna lokalizacja.
- `skills/overview.md:151`: Loading Priority, punkt 1 — *"**`.cursor/rules/*.mdc`** (highest priority for behavior)"* — pomija `.ai/rules/` jako SSOT i `adapters/claude/` jako równoległy adapter.

Zgodne z zasadą repo-poziomu z `CLAUDE.md` (root, sekcja "How to use prompts and skills"): *"Do not expect `.cursor/commands` or Cursor `@` attachment as the only entry — those are Cursor-channel packaging."* — obie strony łamią dokładnie tę zasadę, publicznie, dla całej publiczności docs site (nie tylko wewnętrznego `CLAUDE.md`).

### P4 — Nieaktualne liczby (skille, prompty)

Zob. tabela w §5 — "43 reusable skills" i "12 public prompts" to dziś 48 i 16 (+12 internal = 28).

### P5 — Nieaktualna konwencja lokalizacji artefaktów (`specifications/` zamiast `docs/specs/`)

`prompts/internal/eversis-research.md:48-54`:
```
A `.research.md` file placed in `specifications/<task-name>/`:
specifications/
  user-authentication/
    user-authentication.research.md
```
Realna, dziś obowiązująca konwencja (`spec-driven-development.md`, i cały ten wątek): `docs/specs/<issue-kebab>/<issue-kebab>.research.md`. To osobna, niezależna od P1-P4 klasa błędu — nie ścieżka pliku frameworka, tylko konwencja **wyjściowa** promptu. Nie sprawdzono systematycznie, czy powtarza się w innych plikach `prompts/internal/*` (`eversis-plan.md` to najbardziej prawdopodobny kolejny nosiciel — nieprzeczytany w tym audycie, do weryfikacji w Planie).

---

## 5. Numeryczne rozbieżności do poprawienia

| Strona | Twierdzenie dziś | Stan faktyczny | Delta |
|---|---|---|---|
| `skills/overview.md:8` | "43 reusable skills" | 48 folderów pod `.ai/skills/` | +5 |
| `prompts/overview.md:7` | "12 public prompts" | 16 pod `.ai/prompts/public/` | +4 |
| `prompts/overview.md` | (brak wzmianki o internal) | 12 pod `.ai/prompts/internal/` | nowa kategoria do domknięcia liczbowego |

**5 brakujących stron skilli** (żaden z tych identyfikatorów nie występuje pod żadną nazwą w `website/docs/skills/*.md`, zweryfikowane `grep` po treści, nie tylko nazwach plików):

| Skill | Pochodzenie | Uwaga |
|---|---|---|
| `eversis-promote-domain-knowledge` | nowy, z `global-domain-context-ssot.plan.md` Faza 1-6 | część pierwotnego zgłoszenia Q2 |
| `eversis-import-confluence-knowledge` | jw. | jw. |
| `eversis-audit-domain-knowledge` | jw. | jw. |
| `eversis-ba-docs-planner` | starszy, niezwiązany z SSOT | **nowe znalezisko tego auditu** — nie było wymienione w pierwotnym Q2; ma już stronę **jako prompt** (`prompts/public/eversis-ba-docs-planner.md`), ale nie jako skill |
| `eversis-ba-docs-writer` | jw. | jw. — też ma stronę promptu, nie skilla |

**Pre-existing, jawnie odnotowany, nie-nowy gap (poza zakresem tego audytu, tylko dla kontekstu):** `eversis-implementing-backend` — `skills/implementing-filters.md:27` i `skills/overview.md:27` już dziś mówią wprost *"no docs page yet"*. Nie wliczony do "48 vs 43", bo już jest jawnie oznaczony jako świadomy brak, a nie fakt do skorygowania.

---

## 6. Otwarte pytania (do rozstrzygnięcia przed Planem)

| # | Pytanie | Opcje | Rekomendacja |
|---|---|---|---|
| **Q1** | Naprawa treściowa 73 stron — sam find-replace ścieżek (P1, P4) wystarczy, czy każda strona wymaga też usunięcia ramy "Cursor-only" (P3) i sprawdzenia P2/P5 lokalnie? | (a) tylko P1+P4, mechanicznie · (b) P1-P5 na każdej dotkniętej stronie, dopasowane do lokalnego kontekstu | **(b)** — P3 to nie kosmetyka: strona aktywnie sprzeczna z `CLAUDE.md` i myląca dla większości czytelników tego repo (Claude Code), nie tylko dla Cursor |
| **Q2** | Czy w tym samym Planie budować realny mechanizm sync `website/docs/{skills,prompts}/` ↔ `.ai/`, żeby ten dryft nie powrócił, czy tylko naprawić treść ręcznie (jak poprzedni Plan zrobił dla `website/docs/**` reszty)? | (a) tylko naprawa treści, ręcznie, bez nowego skryptu · (b) rozszerzyć `adapters/sync.mjs` (lub nowy skrypt) o generowanie tych stron z `.ai/` | Bez rekomendacji — (b) eliminuje dryft trwale, ale to osobny, znacznie większy projekt inżynierski (parser Markdown→Docusaurus frontmatter, 77 plików, nie tylko `.mdc`/`.md` 1:1 jak dzisiejszy `sync:adapters`); (a) jest szybsze, ale odtwarza dokładnie ten sam problem przy następnej zmianie `.ai/` |
| **Q3** | Czy naprawić `prompts/overview.md:9` (fałszywe `sync-prompts`) opisem "ręcznie utrzymywana kopia, brak auto-sync" (prawda dziś), czy dopiero po odpowiedzi na Q2 — jeśli Q2=b, zdanie opisze **nowy**, rzeczywisty mechanizm zamiast obecnego stanu? | (a) opisać dzisiejszy stan (ręczna kopia) niezależnie od Q2 · (b) poczekać na Q2, opisać docelowy stan | **(a)** — nawet jeśli Q2=b, mechanizm sync to osobna faza; strona nie powinna przez cały czas trwania tej pracy kłamać o istniejącym dziś skrypcie |
| **Q4** | 5 brakujących stron skilli (§5) — czy wszystkie 5 wchodzą do tego Planu, czy tylko 3 pierwotnie zgłoszone w Q2 (`promote-domain-knowledge`, `import-confluence-knowledge`, `audit-domain-knowledge`), a `ba-docs-planner`/`ba-docs-writer` zostają jako osobny, jeszcze inny follow-up? | (a) wszystkich 5 razem, skoro już wykryte · (b) tylko 3 pierwotne, `ba-docs-*` osobno | Bez rekomendacji — (a) mniejszy narzut koordynacyjny (jeden Plan zamiast dwóch dla tej samej klasy problemu), (b) trzyma się dokładnie pierwotnego zakresu Q2, unika rozszerzania Planu w trakcie Research |
| **Q5** | P5 (`specifications/` vs `docs/specs/` w `eversis-research.md`) — czy Plan dostaje zadanie systematycznie sprawdzić **wszystkie** 12 stron `prompts/internal/*` pod kątem tej samej nieaktualnej konwencji (nieprzeczytane w tym Research), czy zakres ogranicza się do jednego potwierdzonego znaleziska? | (a) systematyczne sprawdzenie wszystkich 12 · (b) tylko potwierdzone `eversis-research.md` | **(a)** — tania weryfikacja (12 krótkich plików), a P5 to inna klasa błędu niż P1-P4; niesprawdzenie reszty zostawiłoby ślepą plamkę identyczną do tej, którą ten follow-up właśnie naprawia gdzie indziej |
| **Q6** | Rozmiar — jeden duży Plan na 73+5 stron, czy podział na sekwencyjne pod-Plany (np. najpierw `prompts/**` 28+1 stron, potem `skills/**` 43+5 stron), żeby review każdego Planu był ogarnialny? | (a) jeden Plan · (b) dwa sekwencyjne Plany (prompts, potem skills) | Bez rekomendacji — zależy od tego, ile naraz stakeholder chce recenzować; poprzedni Plan tego samego wątku (30 znalezisk, 20 plików) był jednym Planem, ale to zadanie jest ~2.5× większe |

**Human gate: Research czeka na odpowiedzi Q1-Q6 przed przejściem do Plan.**

**Rozstrzygnięcia (2026-08-27):** Q1=b (P1-P5 na każdej stronie, dopasowane do kontekstu) · Q2=b (realny mechanizm sync, nie tylko ręczna naprawa) · Q3=a (naprawić fałszywe `sync-prompts` opisem dzisiejszego stanu, niezależnie od kolejności Q2) · Q4=a (wszystkich 5 brakujących stron skilli razem) · Q5=a (systematyczne sprawdzenie wszystkich 12 `prompts/internal/*`) · Q6=a (jeden Plan).

### Addendum — dwa nowe znaleziska odkryte podczas pisania Planu (poza pierwotnym zakresem §1, ale bezpośrednio wymagane przez Q2=b)

Podczas projektowania mechanizmu sync (Q2=b) sprawdzono, czy regenerowanie stron z `.ai/prompts/**` automatycznie naprawi wszystkie 73 znaleziska. Nie w pełni — dwa błędy siedzą w samym **źródle SSOT** (`.ai/`), nie tylko w kopii `website/docs/`, więc regeneracja wiernie odtworzyłaby błędną treść:

- **`.ai/prompts/internal/eversis-research.md:48`** — sekcja "Output" mówi wyłącznie `specifications/<task-name>/`, pomijając `docs/specs/<issue-kebab>/` (podczas gdy sekcja "Executable prompt" niżej w tym samym pliku, linia 68, poprawnie podaje `docs/specs/` jako pierwszą opcję). To ten sam wzorzec błędu co P5 (§4), ale w pliku SSOT, nie w kopii website. Wymaga sprawdzenia pozostałych 11 plików `prompts/internal/*` w ramach Q5 — nie tylko website, także `.ai/` źródło.
- **`.ai/skills/eversis-creating-prompts/SKILL.md:115,117,128,130,176`** — kanoniczny skill (nie strona website) opisuje `sync-prompts` i `scripts/lib/prompt-link-rewrite.mjs` jako istniejący mechanizm ("gitignored... listed in `.cursorignore`"). Żadne z nich nie istnieje w repo. To ten sam błąd co P2 (§4), ale w pliku instruującym przyszłych autorów promptów — jeśli Plan zbuduje realny generator (Q2=b) pod inną nazwą/mechanizmem (np. `sync:website-docs`, committed output, nie gitignored — zgodnie z istniejącym wzorcem `sync:adapters`/`.cursor/rules/`/`.claude/commands/`, które **są** trackowane w git), ten plik natychmiast stanie się nieaktualny ponownie, jeśli nie zostanie zaktualizowany w tym samym Planie.

Oba mieszczą się w zakresie Planu jako bezpośrednia, wąska konsekwencja Q2=b (mechanizm sync musi czytać poprawne źródło i być poprawnie udokumentowany) — nie jako rozszerzenie zakresu do niepowiązanych plików. Osobno wykryto (zob. Plan, Improvements — poza zakresem): `website/docs/integrations/eversis-collections.md` i `CHANGELOG.md`/`website/src/pages/changelog.md` też wspominają `sync-prompts`, ale pierwszy był już w zakresie innego, zamkniętego Planu, a drugie to zapis historyczny (changelog) — nie do przepisywania.

---

## 7. Źródła

**Metoda:** `grep -rl '\.cursor/\|\.claude/\|@eversis-' website/docs/skills website/docs/prompts` (73/77 trafień), pełny odczyt 8 reprezentatywnych plików (`skills/overview.md`, `skills/creating-prompts.md`, `prompts/overview.md`, `prompts/internal/eversis-research.md`, plus liczenie wzorca po pozostałych przez `grep -c`), krzyżowa weryfikacja z `README.md`, `adapters/cursor/`, `adapters/claude/`, `adapters/opencode/`, `adapters/sync.mjs` (przez listing, nie pełny odczyt — poza zakresem tego audytu treściowego), `website/package.json`, root `package.json`, liczba plików `.ai/skills/*/`, `.ai/prompts/{public,internal}/*.md`.

**Pełna lista 73 dotkniętych plików** (odtwarzalna: `grep -rl '\.cursor/\|\.claude/\|@eversis-' website/docs/skills website/docs/prompts`):

`prompts/`: `overview.md` · `internal/eversis-deploy-kubernetes.md` · `internal/eversis-engineer-prompt.md` · `internal/eversis-implement-common-task.md` · `internal/eversis-implement-e2e.md` · `internal/eversis-implement-observability.md` · `internal/eversis-implement-pipeline.md` · `internal/eversis-implement-terraform.md` · `internal/eversis-implement-ui-common-task.md` · `internal/eversis-implement-ui.md` · `internal/eversis-plan.md` · `internal/eversis-research.md` · `internal/eversis-review-plan.md` · `public/eversis-analyze-aws-costs.md` · `public/eversis-analyze-gcp-costs.md` · `public/eversis-analyze-materials.md` · `public/eversis-audit-infrastructure.md` · `public/eversis-ba-docs-planner.md` · `public/eversis-ba-docs-writer.md` · `public/eversis-create-custom-agent.md` · `public/eversis-create-custom-instructions.md` · `public/eversis-create-custom-prompt.md` · `public/eversis-create-custom-skill.md` · `public/eversis-implement.md` · `public/eversis-qa-workflow.md` · `public/eversis-repo-docs-writer.md` · `public/eversis-review-codebase.md` · `public/eversis-review-ui.md` · `public/eversis-review.md`

`skills/`: `overview.md` · `accessibility-auditing.md` · `analyzing-bugs.md` · `analyzing-regression-risk.md` · `architecture-design.md` · `ci-cd-implementation.md` · `cloud-cost-optimization.md` · `code-review.md` · `codebase-analysis.md` · `creating-agents.md` · `creating-implementation-plans.md` · `creating-instructions.md` · `creating-prompts.md` · `creating-skills.md` · `e2e-testing.md` · `ensuring-accessibility.md` · `fine-handoff.md` · `frontend-implementation.md` · `functional-testing.md` · `implementation-gap-analysis.md` · `implementing-filters.md` · `implementing-forms.md` · `jira-task-formatting.md` · `kubernetes-implementation.md` · `multi-cloud-architecture.md` · `observability-implementation.md` · `optimizing-frontend.md` · `orchestrating-implementation.md` · `planning-tests.md` · `prompt-engineering.md` · `qa-workflow.md` · `reviewing-frontend.md` · `secrets-management.md` · `sql-and-database.md` · `task-analysis.md` · `task-extraction.md` · `task-quality-review.md` · `technical-context-discovery.md` · `terraform-modules.md` · `transcript-processing.md` · `ui-verification.md` · `verifying-acceptance-criteria.md` · `writing-hooks.md` · `writing-repo-documentation.md`

**Referencja stanu "po" (ground truth):** `README.md` (root) — sekcje "Canonical content lives under `.ai/`" (linia 25), "MVP note" o `.cursor/skills`/`.cursor/prompts` (linia 159), `sync:adapters` (linie 147-152, 348).
