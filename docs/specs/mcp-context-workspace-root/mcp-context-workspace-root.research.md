# mcp-context-workspace-root - Analysis Result

## Changelog

| Data | Zmiana |
|------|--------|
| 2026-09-01 | Research i plan wdrożenia poprawki `/workspace` po stronie konsumenta w oryginalnym repozytorium `eversis-ai/agent-collections` (gałąź `ssot`). Problem wykryty przy WUP-695; kontynuacja DHI-630. |
| 2026-09-02 | DELTA: przepisanie treści researchu poprawną polszczyzną. Zakres merytoryczny i decyzje bez zmian. |
| 2026-09-02 | DELTA: rozwinięcie Błędu 2 (INDEX) — konkretny przykład, dlaczego link markdown w pierwszej kolumnie psuje `getContext`. |
| 2026-09-02 | DELTA: rozwinięcie luki instalatora — dlaczego ręczna edycja Sternika nie wystarcza i merger musi emitować `env`. |
| 2026-09-02 | Gap Analysis Q1–Q6 locked (`Q1. OK;` … `Q6. OK;`). |

## Task Details

| Field | Value |
|---|---|
| Jira ID | [DHI-630](https://eversis.atlassian.net/browse/DHI-630) — kontynuacja (powiązane z [WUP-695](https://eversis.atlassian.net/browse/WUP-695) Q5) |
| Title | `eversis_context_*` musi rozwiązywać projekt konsumenta, a nie drzewo vendora |
| Description | W Cursorze polecenie `docker compose -f vendor/agent-collections/docker-compose.yml` często ma `PWD` równe katalogowi pliku Compose (framework / vendor), a nie katalogowi głównemu konsumenta. Wtedy `eversis_context_list` kończy się błędem `install-selection.json not found under /workspace`. Wiersze INDEX zapisane jako linki markdown psują też `eversis_context_get`. Poprawkę należy wnieść do oryginalnego repozytorium Agent Collections na gałęzi `ssot`. |
| Priority | Wysoki |
| Reporter | Piotr Niemirski |
| Created Date | 2026-09-01 |
| Due Date | — |
| Labels | mcp, domain-context, ssot, docker |
| Estimated Effort | Mały (MCP + merge instalatora + dokumentacja; bez aplikacji produktowych) |

## Business Impact

DHI-630 dostarczyło narzędzia `eversis_context_get`, `eversis_context_list` i `eversis_context_sync`, dzięki którym agenci mogą czytać wspólną wiedzę domenową. U konsumenta z vendored frameworkiem (Sternik) te narzędzia nie widzą `.agent-collections/install-selection.json`, gdy drugi mount Dockera wskazuje drzewo vendora. Skills nadal działają (`/repo`); narzędzia kontekstu — nie.

Dopóki poprawka nie trafi na `origin/ssot`, każdy konsument vendoringujący to repozytorium dziedziczy błąd, a globalnej warstwy z WUP-695 nie da się wylistować z typowej sesji Cursor.

## Gathered Information

### Knowledge Base & Task Management Tools

- [DHI-630](https://eversis.atlassian.net/browse/DHI-630) Global Domain Context SSOT — In Progress; komentarz QA z 25 sierpnia 2026 nadal dokumentuje kontrakt `${PWD}:/workspace`.
- [WUP-695](https://eversis.atlassian.net/browse/WUP-695) ziarno konsumenckie; luka Q5: *«W ZAKRESIE. Naprawa w oryginalnym repo agents-collections;»*
- Spec Sternika: `sternik-kariery/docs/specs/domain-context-ssot/` (prototyp fazy 1). Lokalny commit podmodułu `15f4e28` na **detached HEAD** od `f110dbc` — **nie** jest na `origin/ssot` (`dc12ecc` na dzień 1 września 2026).

### Codebase

**Ten checkout:** `/Users/piotrniemirski/Documents/Projects/agent-collections`, gałąź **`ssot`** = `origin/ssot` @ `dc12ecc`. Stan czysty. **Nie zawiera** prototypu ze Sternika.

**Błąd 1 — katalog główny workspace**

```text
Cursor: docker compose -f ${workspaceFolder}/vendor/agent-collections/docker-compose.yml run …
katalog pliku Compose     = vendor/agent-collections
${PWD} przy starcie Compose  = często ten katalog vendora, a nie konsumenta
wolumen ${PWD}:/workspace    = drzewo vendora (brak .agent-collections/install-selection.json)
context.ts: jeśli istnieje /workspace → użyj go (nawet bez pliku selection)
→ eversis_context_list rzuca wyjątek
```

`resolveWorkspaceRoot()` obecnie: `CONSUMER_PROJECT_ROOT`, jeśli ścieżka istnieje; w przeciwnym razie **dowolny** `/workspace`; w ostateczności `cwd`. Testy ustawiają `CONSUMER_PROJECT_ROOT` przez `setRoot()`; nigdy nie pokrywają przypadku, w którym `/workspace` nie jest katalogiem konsumenta.

Powiązanie w `docker-compose.yml`: `${PWD}:/workspace`. W kontenerze ustawione jest wyłącznie `AGENT_COLLECTIONS_HOME=/repo`.

**Błąd 2 — pierwsza kolumna INDEX**

Kontrakt: pierwsza kolumna `INDEX.md` to **goły identyfikator** komponentu (np. `checkout`). Z niego składa się ścieżka pliku: `docs/context/<projekt>/<identyfikator>/index.md`. `eversis_context_list` zwraca ten identyfikator, a `eversis_context_get` otwiera plik pod tą nazwą.

Sternik (i każdy INDEX pisany jak spis treści) wstawia w tę kolumnę **link markdown** zamiast gołej nazwy:

```markdown
| Component | Summary |
| --- | --- |
| [checkout](./checkout/index.md) | Płatność i koszyk |
```

`readIndexComponents` nie parsuje linku — bierze całą komórkę jako `component`:

```text
component = "[checkout](./checkout/index.md)"
```

W środku tej „nazwy” jest `/` (ścieżka `./checkout/index.md`). `getContext` ma strażnika przed path traversal:

```ts
if (component.includes("..") || component.includes("/")) {
  throw new Error("Invalid component name");
}
```

Skutek: `eversis_context_list` wypisuje komponenty, ale `eversis_context_get` na tej nazwie rzuca `Invalid component name`. Nawet bez strażnika plik nie zostałby znaleziony — szukano by katalogu dosłownie nazwanego `[checkout](./checkout/index.md)`.

Wiersz z gołą nazwą (`| checkout |`) działa. Poprawka: przed użyciem komórki zdjąć składnię `[tekst](url)` i zostawić `tekst` (identyfikator).

**Luka instalatora (nieobecna w ręcznej edycji Sternika)**

To nie jest trzeci błąd w `context.ts`. To luka w **tym, kto zapisuje `.cursor/mcp.json` / `.mcp.json` u konsumenta**.

Łańcuch, którego wymaga poprawka Błędu 1:

1. Host MCP (Cursor / Claude) przy starcie `docker compose` musi mieć w środowisku `CONSUMER_PROJECT_ROOT` = katalog projektu konsumenta.
2. Compose interpoluje wolumen `${CONSUMER_PROJECT_ROOT:-${PWD}}:/workspace` **na hoście** (z env procesu `docker`, nie z wnętrza kontenera).
3. W kontenerze ustawiamy `CONSUMER_PROJECT_ROOT=/workspace`, żeby `resolveWorkspaceRoot()` nie zgadywał z `PWD`.

Punkt 1 realizuje blok `env` we wpisie serwera MCP, np.:

```json
"eversis-collections": {
  "command": "docker",
  "args": ["compose", "-f", "…/docker-compose.yml", "run", "--rm", "-T", "eversis-collections"],
  "env": {
    "CONSUMER_PROJECT_ROOT": "${workspaceFolder}"
  }
}
```

Sternik zrobił to **ręcznie** w swoim `.cursor/mcp.json` (WUP-695). Prototyp w vendored `15f4e28` ruszył `context.ts` i Compose — **nie ruszył** `mcp-merge.mjs`.

Instalator nie kopiuje szablonu 1:1. `mcp-merge.mjs` **zastępuje cały** wpis `eversis-collections` obiektem z samymi `command` / `args` / `type` — **bez `env`**:

```js
picked['eversis-collections'] = {
  command: 'docker',
  args: ['compose', '-f', cmdPath, 'run', '--rm', '-T', 'eversis-collections'],
  type: 'stdio',
};
```

Test `_assert_docker_entry` w `mcp-merge.test.sh` **wymaga** braku `env` (`if ("env" in e) process.exit(1)`). Komentarz mówi, że hostowe env nie jest potrzebne, bo `AGENT_COLLECTIONS_HOME=/repo` jest hardcoded w Compose. To prawda dla skills (`/repo`). Dla narzędzi kontekstu (`/workspace`) — nie: bez hostowego `CONSUMER_PROJECT_ROOT` Compose znów bierze `PWD` = katalog vendora.

Skutek:

- Sama zmiana `templates/mcp.json` nic nie daje — merger i tak nadpisuje wpis i wyrzuca `env`.
- `setup-agent-collections.sh --upgrade --sync` **zetrze** ręczną poprawkę Sternika i przywróci Błąd 1.
- Każdy nowy konsument dostanie JSON bez `env`.

Dlatego merger jest w zakresie. Musi emitować hostowe `CONSUMER_PROJECT_ROOT`, a asercja testu ma wymagać `env.CONSUMER_PROJECT_ROOT`, a nie zabraniać `env`:

| Host | Względny vendor | Bezwzględny (lokalny collections home) |
|------|-----------------|----------------------------------------|
| Cursor | `${workspaceFolder}` | `${workspaceFolder}` (folder IDE = konsument) |
| Claude | `${CLAUDE_PROJECT_DIR:-.}` | ten sam token (Claude nie rozwija `${workspaceFolder}`) |

**Nie cherry-pickować `15f4e28` na ten `ssot`.** Ten commit ma rodzica `f110dbc`; `ssot` ma późniejsze pinezki i commity instalatora (`dc12ecc`). Zachowanie należy ponownie nanieść na bieżący HEAD oraz dodać instalator i dokumentację, których prototyp pominął.

### Relevant Links

- `docs/specs/global-domain-context-ssot/` — oryginalny projekt SSOT (Q2/6 zakładały, że cwd MCP = konsument)
- `docs/specs/mcp-docker-compose-migration/` — migracja Docker stdio; udokumentowany kontrakt `${PWD}:/workspace`
- `website/docs/getting-started/mcp-setup.md` — „Domain context needs the project volume”
- `website/docs/integrations/eversis-collections.md` — to samo założenie
- Prototyp (tylko jako referencja): `sternik-kariery/vendor/agent-collections`, commit `15f4e28`

### Relevant Charts & Diagrams

```text
Host MCP env CONSUMER_PROJECT_ROOT = folder workspace konsumenta
        │  docker compose interpoluje wolumen
        ▼
${CONSUMER_PROJECT_ROOT:-${PWD}}:/workspace
        │  env w kontenerze CONSUMER_PROJECT_ROOT=/workspace
        ▼
resolveWorkspaceRootFrom(env, "/workspace", cwd)
        │  użyj /workspace tylko, gdy istnieje tam install-selection.json
        ▼
eversis_context_list / get / sync
```

## Current Implementation Status

### Existing Components

- `listContext` / `getContext` / `syncContext` — `mcp/eversis-collections-mcp/src/context.ts` — do ponownego użycia; rozszerzyć rozwiązywanie katalogu głównego i parsowanie INDEX
- Testy — `mcp/eversis-collections-mcp/tests/context.test.ts` — do ponownego użycia; dodać przypadki mountu workspace i linków markdown
- Compose — `docker-compose.yml` — zmienić bind-mount i env w kontenerze
- Szablon — `templates/mcp.json` — dodać hostowe `env` (merger pozostaje SSOT dla plików generowanych)
- Merger — `scripts/lib/setup-agent-collections/mcp-merge.mjs` — **musi** dodać `env`; obecne testy tego zabraniają
- Docs / README — nadal uczą, że `${PWD}` wystarczy — do zmiany

### Key Files and Directories

- `/Users/piotrniemirski/Documents/Projects/agent-collections/` — tu implementacja, gałąź `ssot`
- `mcp/eversis-collections-mcp/src/context.ts`
- `scripts/lib/setup-agent-collections/mcp-merge.mjs` oraz `mcp-merge.test.sh`
- `website/docs/getting-started/mcp-setup.md`, `website/docs/integrations/eversis-collections.md`
- Poza tym repozytorium: Sternik `.cursor/mcp.json` (już poprawiony w WUP-695)

## Gap Analysis

Lock (2026-09-02): `Gap Analysis: Q1. OK; Q2. OK; Q3. OK; Q4. OK; Q5. OK; Q6. OK;`

### Question 1
#### Docelowa gałąź git w oryginalnym repozytorium?
**Rekomendacja:** `ssot` (ten checkout śledzi `origin/ssot`; podmoduł Sternika jest udokumentowany jako `ssot`).
**Decyzja (dla planu):** `ssot`. Cytat intencji: research i plan implementacji w `@…/Projects/agent-collections`.
**Status:** ✅ Resolved — `Q1. OK;`

### Question 2
#### Cherry-pick Sternika `15f4e28` czy ponowne naniesienie na bieżący HEAD `ssot`?
**Rekomendacja:** ponownie nanieść na `dc12ecc` (nie cherry-pickować commita z rodzicem `f110dbc`).
**Decyzja:** ponowne naniesienie oraz rozszerzenie o merge instalatora (prototyp nie ruszał `mcp-merge.mjs`).
**Status:** ✅ Resolved — `Q2. OK;`

### Question 3
#### Czy `mcp-merge.mjs` instalatora jest w zakresie?
Bez tej zmiany `--upgrade --sync` regeneruje JSON MCP **bez** `CONSUMER_PROJECT_ROOT`, a bind Compose znów spada na `PWD`.
**Decyzja:** w zakresie. Zaktualizować `_assert_docker_entry`, tak aby wymagało `env.CONSUMER_PROJECT_ROOT`, a nie zabraniało `env`.
**Status:** ✅ Resolved — `Q3. OK;`

### Question 4
#### Website / README / CHANGELOG w tym samym zgłoszeniu?
Obecna dokumentacja opisuje zepsuty kontrakt `${PWD}` oraz ostrzeżenie o „cichym złym katalogu”.
**Decyzja:** tak — ten sam plan (skill `eversis-writing-repo-documentation`). CHANGELOG `[Unreleased]` / Fixed oraz krótka nota migracyjna dla istniejących konsumentów (ustawić hostowe env albo ponownie uruchomić instalator).
**Status:** ✅ Resolved — `Q4. OK;`

### Question 5
#### Usuwanie linków markdown z INDEX w tym samym zgłoszeniu?
WUP-695 Q5: ten sam `context.ts`. `getContext` odrzuca `/`.
**Decyzja:** tak.
**Status:** ✅ Resolved — `Q5. OK;`

### Question 6
#### Nowy klucz Jira czy tylko komentarz do DHI-630?
**Rekomendacja:** utrzymać ten spec jako kontynuację DHI-630; opcjonalnie osobny bug DHI, jeśli QA będzie chciało osobnego zgłoszenia. Nie blokować implementacji na nowym kluczu.
**Decyzja:** pole Jira = kontynuacja DHI-630; nowy klucz nie jest potrzebny, żeby zacząć.
**Status:** ✅ Resolved — `Q6. OK;`

## Human gates

1. ~~Approve research~~ — done (`Gap Analysis: Q1. OK; Q2. OK; Q3. OK; Q4. OK; Q5. OK; Q6. OK;`)
2. Approve plan (po napisaniu)
3. Implement → Review → Fine (w `/Users/piotrniemirski/Documents/Projects/agent-collections` na `ssot`)
4. Publikacja na `origin/ssot` — tylko po jawnym OK (reguły git użytkownika)
