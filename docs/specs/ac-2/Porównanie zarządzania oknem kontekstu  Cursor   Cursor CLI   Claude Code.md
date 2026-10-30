# Zarządzanie oknem kontekstu: Cursor IDE vs Cursor CLI vs Claude Code

**Cel:** podstawa decyzji o regule 14 (zero-kompaktacja) w AC-2, po recenzji iteracji 4 z punktu widzenia Cursora.
**Data:** 2026-09-21
**Metoda:** oficjalna dokumentacja obu platform, uzupełniona forum Cursora tam, gdzie dokumentacja milczy. Źródła przy każdym wierszu.

---

## 1. Tabela porównawcza

| Zdolność | Cursor IDE (Composer) | Cursor CLI | Claude Code |
| -------- | --------------------- | ---------- | ----------- |
| **Człowiek widzi zapełnienie okna** | Tak — wskaźnik % w composerze, po rozwinięciu wykres kołowy, dokładna wartość po najechaniu ([forum Cursora](https://forum.cursor.com/t/context-window-usage/139957)) | Nieudokumentowane | Tak — `/context` daje rozbiórkę po kategoriach, listę wczytanych `CLAUDE.md`, pliki pamięci i sugestie optymalizacji ([Claude Code Docs](https://code.claude.com/docs/en/context-window)) |
| **Agent widzi zapełnienie okna** | **Nie** — nieudokumentowane jako wystawione modelowi; `context_usage_percent` istnieje tylko na wejściu hooka `preCompact` ([Cursor Docs — Hooks](https://cursor.com/docs/hooks)) | **Nie** | **Nie** — dokumentacja nie wystawia tej liczby modelowi |
| **Próg auto-kompaktacji konfigurowalny** | Nieudokumentowany; auto-streszczanie „po dojściu do limitu okna" ([changelog 1.6](https://cursor.com/changelog/1-6)) | j.w. | **Tak** — `/autocompact 500k` ustawia, jak pełne ma być okno przed automatyczną kompaktacją ([Claude Code Docs](https://code.claude.com/docs/en/context-window)) |
| **Da się zablokować kompaktację** | **Nie** — `preCompact` jest obserwacyjny, „cannot block or modify the compaction behavior" ([Cursor Docs](https://cursor.com/docs/hooks)) | j.w. | **Tak** — `PreCompact` blokuje przez exit code `2` albo JSON `"decision": "block"`. Zastrzeżenie: jeśli kompaktacja była reaktywna (po błędzie limitu z API), blokada powoduje wysypanie żądania ([Claude Code Docs — Hooks](https://code.claude.com/docs/en/hooks)) |
| **Ręczna kompaktacja** | `/summarize` wprowadzone w 1.6 — zwalnia miejsce bez nowego czatu ([changelog 1.6](https://cursor.com/changelog/1-6)). ⚠️ Aktualna strona dokumentacji wymienia `/side`, `/btw`, `/goal`, `/loop` i **nie** wymienia `/summarize` — możliwa zmiana, sprawdzić w swojej wersji | j.w. | `/compact [instrukcje]` — z ukierunkowaniem streszczenia, np. `/compact focus on the auth bug fix`; plus `/clear`, `/rewind` („Summarize from here" / „up to here"), `/export` ([Claude Code Docs](https://code.claude.com/docs/en/sessions)) |
| **Agent sam kończy sesję** | Nie | Nie | Nie |
| **Programowe tworzenie/wznawianie sesji** | Nie | **Tak** — `agent create-chat` zwraca ID nowego czatu, `agent resume`, `agent ls`, `--resume [chatId]`, `--continue` ([Cursor Docs — Parameters](https://cursor.com/docs/cli/reference/parameters)) | **Tak, najbogatsze** — `claude --continue`, `--resume <name\|id\|ścieżka .jsonl>`, `/resume`, `--fork-session`, `/fork`, `/branch`, oraz `claude -p --resume <id> --output-format json "…"` ([Claude Code Docs — Sessions](https://code.claude.com/docs/en/sessions)) |
| **Wstrzykiwanie kontekstu na starcie sesji** | `sessionStart` → `additional_context`; **niedostępny w cloud agents** ([Cursor Docs](https://cursor.com/docs/hooks)) | Prawdopodobnie tak — źródło zewnętrzne podaje `sessionStart`, `beforeSubmitPrompt`, `stop`, `sessionEnd` od CLI v0.45+ ([hindsight.vectorize.io](https://hindsight.vectorize.io/blog/2026/06/12/cursor-persistent-memory)); dokumentacja potwierdza dla CLI tylko `workspaceOpen` — **do weryfikacji** | **Tak, z rozróżnieniem źródła** — `SessionStart` z `source` = `startup` / `resume` / `clear` / `compact` / `fork`; zwraca `additionalContext`, `initialUserMessage` (w trybie `-p`), `sessionTitle`, `watchPaths`, `reloadSkills` ([Claude Code Docs — Hooks](https://code.claude.com/docs/en/hooks)) |
| **Hook po kompaktacji** | Brak | Brak | `PostCompact` — dostaje `compact_summary`; nie może wpłynąć na wynik. Plus `SessionStart` z `source: compact`, którego wyjście wchodzi do skompaktowanego kontekstu |
| **Kompaktacja kończy sesję** | Nie | Nie | **Nie** — jawnie udokumentowane |
| **Co przetrwa kompaktację** | Nieudokumentowane | Nieudokumentowane | **Szczegółowo udokumentowane** — patrz sekcja 3 |

> **Aneks (2026-09-21):** do porównania doszło czwarte środowisko — **Pi Agent** ([pi.dev](https://pi.dev/)). Wypada inaczej niż oba powyższe i zmienia wnioski z sekcji 2 i 5. Patrz sekcja 7.

---

## 2. Główny wniosek: trigger „okno ~50%" jest nieobserwowalny dla agenta w **obu** środowiskach

Recenzja iteracji 4 zapisała to jako problem Cursora („procent zapełnienia okna nie jest na Cursorze widoczny"). Dane pokazują coś innego i szerszego:

- Na Cursorze procent **jest** widoczny — ale **dla człowieka**, w composerze.
- W Claude Code jest widoczny jeszcze lepiej — `/context`, z rozbiórką po kategoriach.
- **W żadnym z trzech środowisk nie jest udokumentowany jako dostępny modelowi w pętli.**

Reguła 14 jest instrukcją dla agenta. Instrukcja „gdy okno osiągnie około połowy, zapisz `CHECKPOINT:` i zakończ sesję" wymaga od agenta reakcji na sygnał, którego agent nie potrafi odczytać — nigdzie, nie tylko na Cursorze. To nie jest reguła trudna do przestrzegania; to reguła **niewykonalna jako instrukcja dla modelu**, a wykonalna wyłącznie jako (a) dyscyplina operatora patrzącego na licznik, albo (b) automatyzacja na hookach poza pętlą agenta.

Konsekwencja dla decyzji: nie ma sensu rozstrzygać precedencji dla triggera, który i tak nie odpali. Trigger okna trzeba przenieść z warstwy reguły do warstwy konfiguracji/operatora, niezależnie od tego, jak rozstrzygniecie pozostałe dwa.

---

## 3. Asymetria, której jedna reguła nie pokryje

Framework generuje adaptery dla Cursora **i** Claude Code z jednego źródła w `.ai/`. Ale mechanika kompaktacji różni się fundamentalnie:

**Claude Code daje kontrolę.** Próg jest konfigurowalny (`/autocompact`), kompaktację można zablokować (`PreCompact` exit 2), ręczną można ukierunkować (`/compact focus on …`), a po kompaktacji można dostrzyknąć kontekst (`SessionStart` z `source: compact`).

**Cursor daje obserwację.** `preCompact` widzi procent i nadchodzącą kompaktację, ale jej nie zatrzyma. Nie ma udokumentowanego sposobu ustawienia progu.

Czyli cel „wyprzedź kompaktację" w Claude Code jest **ustawieniem**, a na Cursorze **dyscypliną człowieka**. Jedno zdanie reguły nie wyrazi obu.

---

## 4. Co osłabia przesłankę całej Fazy 3

Research uzasadniał Fazę 3 tym, że automatyczna kompaktacja „po cichu porzuca bieżące zadanie". W Claude Code to założenie jest w dużej mierze nieaktualne — platforma sama odbudowuje kontekst po kompaktacji ([Claude Code Docs — Explore the context window](https://code.claude.com/docs/en/context-window)):

| Mechanizm | Zachowanie po kompaktacji |
| --------- | ------------------------- |
| Kompaktacja a sesja | **Nie kończy sesji** |
| `CLAUDE.md` z korzenia projektu i reguły bez zakresu | Wstrzykiwane ponownie **z dysku** |
| Plan napisany w plan mode | Wstrzykiwany ponownie z dysku |
| Auto memory | Wstrzykiwana ponownie z dysku |
| Ciała wywołanych skilli | Wstrzykiwane ponownie — limit **5 000 tokenów na skill**, **25 000 łącznie**, najstarsze odpadają pierwsze |
| Pliki czytane/edytowane | Do **5** ponownie czytanych, najświeżej modyfikowane pierwsze; plik powyżej 5 000 tokenów wraca jako sama ścieżka (`Referenced file`) |
| Reguły z `paths:` we frontmatterze | **Streszczane, nie odtwarzane** — trzeba usunąć `paths:` albo przenieść do korzeniowego `CLAUDE.md` |
| Zagnieżdżone `CLAUDE.md` | Wczytywane ponownie dopiero przy czytaniu pliku z danego podkatalogu |
| Kontekst dodany wcześniej przez hooki | Streszczany razem z rozmową |
| Podsumowanie zachowuje | Żądania i intencję użytkownika, kluczowe koncepcje techniczne, pliki i istotne fragmenty kodu, błędy i sposób naprawy, **zadania oczekujące**, bieżącą pracę |

Zwłaszcza dwa wiersze: plan wraca z dysku, a „pending tasks" są explicite w tym, co zachowuje podsumowanie. Ryzyko, przed którym broni Faza 3, jest w Claude Code realnie mniejsze, niż założył research. Na Cursorze — nieudokumentowane, więc nieznane.

### Dwa wnioski uboczne, wykraczające poza AC-2

**(a) Kolejność treści w `SKILL.md` ma znaczenie mierzalne.** Przy ponownym wstrzykiwaniu po kompaktacji duże skille są **obcinane, a obcinanie zachowuje początek pliku**. Dokumentacja wprost zaleca umieszczać najważniejsze instrukcje blisko góry `SKILL.md`. To dotyczy wszystkich skilli `eversis-*`, nie tylko tych z AC-2 — tani, przekrojowy zysk.

**(b) Reguły z `paths:` nie przeżywają kompaktacji.** Jeśli którakolwiek reguła orkiestracji frameworka polega na frontmatterze `paths:`, po kompaktacji przestaje obowiązywać. Warte audytu `.ai/rules/`.

---

## 5. Rekomendowane kolejne kroki

### Decyzja 1 — trigger okna wypada z reguły agenta

Przeredagować trigger 1 z instrukcji dla agenta na dwie ścieżki zależne od środowiska:

- **Claude Code:** ustawić okno auto-kompaktacji (`/autocompact`) na wartość dającą zapas; kompaktacja przestaje być zagrożeniem, bo nie kończy sesji i odbudowuje `CLAUDE.md`, plan oraz skille.
- **Cursor:** wskazówka dla operatora — „zakończ sesję, gdy licznik w composerze przekroczy ~50%". Reguła przestaje udawać, że agent to wykryje.

### Decyzja 2 — licznik 5-10 liczony od zatwierdzenia planu

To jedyny z trzech triggerów, który agent naprawdę potrafi policzyć sam, więc staje się rdzeniem reguły. Twoja obserwacja, że bramki zatwierdzenia researchu i planu zużywają budżet przed pierwszą linią kodu, rozstrzyga interpretację: liczyć **wymiany po zatwierdzeniu planu**, nie całą sesję Composera.

### Decyzja 3 — Continuity wygrywa ze wszystkimi triggerami w Review i Fine

Nie tylko trzeci trigger na ostatnim zadaniu, jak w obecnej rewizji. Przerwanie Review checkpointem niszczy właściwość, której Faza 4 wymaga — recenzję w osobnym, spójnym kontekście. Zapisać jako precedencję wprost, nie jako wyjątek jednego przypadku.

### Decyzja 4 — „zakończ sesję" wymaga dopisania kroku wznowienia

Żadne z trzech środowisk nie pozwala agentowi zamknąć czatu. Reguła musi powiedzieć, co robi **operator**: w Cursorze nowy czat i `/eversis-implement` ze wskazaniem planu; w Cursor CLI `agent create-chat`; w Claude Code `claude --continue` albo `--resume`. Bez tego „zakończ sesję" jest instrukcją bez wykonawcy.

### Osobny ticket — automatyzacja na hookach

Poza zakresem AC-2 (plan deklaruje brak kodu aplikacji, a `.cursor/hooks` i `.claude/hooks` to nowa powierzchnia), ale to właściwe docelowe rozwiązanie:

- **Claude Code:** `PreCompact` blokujący kompaktację przy `trigger: auto`, plus `SessionStart` z `source: compact` i `resume` wstrzykujący wpis `CHECKPOINT:` do kontekstu. Wznowienie przestaje być zachowaniem wymaganym od modelu i staje się faktem infrastrukturalnym — co unieważnia całą złożoność wokół wartości/linii `Resume`.
- **Cursor:** `sessionStart` → `additional_context` z tym samym wpisem; kompaktacji zablokować nie można, więc `preCompact` służy tylko do zalogowania i ostrzeżenia operatora przez `user_message`.

### Osobny, tani ticket — higiena skilli pod kompaktację

Przenieść najważniejsze instrukcje na górę każdego `SKILL.md` (obcinanie zachowuje początek) i zaudytować `.ai/rules/` pod kątem reguł z `paths:`, które po kompaktacji przestają obowiązywać.

---

## 6. Czego nie udało się ustalić

- Czy `/summarize` nadal istnieje w Cursorze — changelog 1.6 je wprowadza, aktualna strona dokumentacji o sumaryzacji go nie wymienia.
- Czy hooki `sessionStart`/`sessionEnd` działają w Cursor CLI — dokumentacja potwierdza dla CLI tylko `workspaceOpen`; źródło zewnętrzne podaje cztery hooki od v0.45+.
- Czy Cursor pozwala ustawić próg auto-kompaktacji — nieudokumentowane; wątki na forum sugerują, że nie i że domyślny próg bywa za późny albo liczony od błędnie założonego rozmiaru okna dla modeli custom.
- Numeryczne progi auto-kompaktacji w Claude Code per model — dokumentacja odsyła do „Default auto-compact thresholds", nie podaje ich na stronie, którą czytałem.

---

## 7. Aneks: Pi Agent

Pi to minimalny terminalowy harness rozszerzany przez ekstensje w TypeScript, skille, szablony promptów i paczki npm ([pi.dev](https://pi.dev/docs/latest)). Instrukcje projektowe wczytuje z `AGENTS.md`. W zarządzaniu oknem kontekstu wypada lepiej niż Cursor i Claude Code w **trzech** wymiarach krytycznych dla reguły 14.

### 7.1 Agent widzi własne zużycie kontekstu

To jedyne z czterech środowisk, gdzie zapełnienie okna jest wystawione **agentowi jako narzędzie**. Paczka `pi-context-tools` daje dwa narzędzia ([katalog paczek Pi](https://pi.dev/packages/pi-context-tools)):

| Narzędzie | Działanie |
| --- | --- |
| `context_info` | Raportuje bieżące zużycie kontekstu — liczbę tokenów i dane o dostępnym oknie |
| `compact_context` | Uruchamia kompaktację bieżącej sesji, bez potrzeby ręcznego `/compact` przez użytkownika |

To znosi główny zarzut z sekcji 2 — w Pi reguła „gdy okno osiągnie połowę, zrób X" **jest** wykonalna jako instrukcja dla modelu, bo model ma czym zmierzyć warunek i czym zadziałać. Dla człowieka to samo pokazuje `/session` (plik sesji, ID, liczba wiadomości, tokeny, koszt).

### 7.2 Próg jest konfigurowalny, w tym per projekt

Warunek wbudowanego triggera jest jawny ([Pi — Compaction](https://pi.dev/docs/latest/compaction)):

```
contextTokens > contextWindow - reserveTokens
```

Konfiguracja leży w `~/.pi/agent/settings.json` **albo `<projekt>/.pi/settings.json`** — czyli da się ją wersjonować w repo:

```json
{
  "compaction": {
    "enabled": true,
    "reserveTokens": 16384,
    "keepRecentTokens": 20000,
    "modelOverrides": {
      "some-provider/big-model": { "reserveTokens": 400000 }
    }
  }
}
```

Domyślnie `reserveTokens` = `16384`, `keepRecentTokens` = `20000`. Przy oknie 1M domyślny margines daje trigger dopiero około **98%** okna. Udokumentowany przykład override: `reserveTokens: 400000` na modelu 1M odpala kompaktację powyżej **600K** tokenów. Są też `modelOverrides` z kluczami `provider/modelId`, a ustawienia globalne i projektowe scalają się rekurencyjnie.

⚠️ **Zastrzeżenie:** `reserveTokens` pełni podwójną rolę — poza progiem wyznacza też limit długości streszczenia i jest przycinany przez maksymalną liczbę tokenów wyjściowych modelu. Ustawianie go na połowę okna tylko po to, żeby uzyskać trigger 50%, jest więc nadużyciem tego klucza. Czysta droga do dokładnie 50% to ścieżka z 7.3.

### 7.3 Trigger 50% istnieje już jako gotowa ekstensja

`pi-rolling-compaction` to jednoplikowa ekstensja, której **domyślnym progiem jest 50% okna** ([Piagent — mapa zasobów](https://piagent.fyi/map/pi-rolling-compaction/)). Mechanika:

- nasłuchuje zdarzenia `agent_settled`,
- odczytuje `ctx.getContextUsage()`,
- wywołuje `ctx.compact()` po przekroczeniu progu.

Próg ustawia się zmienną `PI_AUTOCOMPACT_THRESHOLD` (np. `0.5`) albo stałą `THRESHOLD_PERCENT` w pliku ekstensji. Instalacja to skopiowanie jednego pliku do `~/.pi/agent/extensions/`, a test jednorazowy: `pi -e ./rolling-compaction.ts`. Hardening ma już zrobiony: odroczenie do `before_agent_start`, traktowanie `session_compact` jako jedynego sygnału sukcesu, 3-minutowy bezpiecznik i strażnik pętli.

Efekt jakościowy jest ważniejszy niż sam próg: Pi wplata poprzednie streszczenie w każdą kolejną kompaktację, więc powtarzalne odpalanie przy 50% daje **kroczące streszczenie** — stara praca zostaje skompresowana, świeża zostaje dosłowna. Instrukcje streszczania pokrywają cele, decyzje z uzasadnieniem, stan zadań, pliki tknięte z rozróżnieniem czytane/modyfikowane oraz następne kroki. Alternatywy w katalogu: `@thunstack/auto-compact` i `pi-ultra-compact`.

### 7.4 Kompaktację można anulować **i podmienić**

Zdarzenie `session_before_compact` odpala się przed kompaktacją automatyczną i przed `/compact`, z polem `reason` = `"manual"` / `"threshold"` / `"overflow"`. Handler może:

```ts
return { cancel: true };
```

albo dostarczyć własną treść kompaktacji:

```ts
return { compaction: {
  summary: "…",
  firstKeptEntryId: preparation.firstKeptEntryId,
  tokensBefore: preparation.tokensBefore,
  details: { /* dowolne dane */ }
}};
```

To **więcej** niż daje Claude Code, którego `PreCompact` potrafi wyłącznie zablokować. Handler dostaje m.in. `preparation.messagesToSummarize`, `previousSummary`, `fileOps`, `tokensBefore`, `firstKeptEntryId`, `settings` (już po nałożeniu override'ów modelu), `branchEntries`, `customInstructions` i `AbortSignal`. Jest też `session_compact_failed` z `aborted` i `willRetry`. Całkowite wyłączenie: `compaction.enabled: false` — ręczne `/compact` dalej działa.

### 7.5 Sesje

Sesje zapisują się automatycznie do `~/.pi/agent/sessions/`, po katalogu roboczym, jako JSONL **o strukturze drzewa** — każdy wpis ma `id` i `parentId`, a plik zawiera także wpisy kompaktacji i streszczeń gałęzi ([Pi — Sessions](https://pi.dev/docs/latest/sessions)). Sterowanie: `pi -c`, `pi -r`, `pi --session <ścieżka|id>`, `pi --fork <ścieżka|id>`, `pi --name`, `pi --no-session`; wewnątrz sesji `/resume`, `/new`, `/tree`, `/fork`, `/clone`, `/compact [prompt]`, `/export`, `/session`.

Istotne dla wznawiania: `/tree` pozwala wrócić do dowolnego wcześniejszego punktu **w tym samym pliku sesji** i kontynuować, bez zakładania nowej sesji. To alternatywa dla całego wzorca „zakończ sesję i wznów z `CHECKPOINT:`".

### 7.6 Co to zmienia w decyzji o regule 14

W Pi cel reguły 14 rozpada się na dwie możliwości, obie tańsze niż to, co planuje AC-2:

1. **Reguła zostaje regułą dla agenta** — bo `context_info` czyni warunek 50% obserwowalnym, a `compact_context` daje agentowi środek działania. To jedyne środowisko, w którym pierwotny zamysł reguły 14 działa bez zmian.
2. **Reguła znika** — `pi-rolling-compaction` sprawia, że kompaktacja przy 50% staje się rutyną z kroczącym streszczeniem, a nie zdarzeniem, przed którym trzeba się ratować checkpointem. Nie ma czego wyprzedzać.

Druga opcja jest mocniejsza: zamiast reguły w pięciu plikach dostajesz jeden plik ekstensji i wpis w `.pi/settings.json` w repo.

### 7.7 Czego nie ustaliłem o Pi

- Czy `context_info` zwraca gotowy procent, czy tylko liczbę tokenów i rozmiar okna do samodzielnego przeliczenia — dokumentacja paczki nie wymienia pól.
- Czy `reserveTokens` ustawiony na połowę okna faktycznie przesuwa trigger, czy zostaje przycięty przez limit tokenów wyjściowych modelu.
- Czy framework ma w ogóle generować adapter dla Pi — to decyzja produktowa, nie techniczna.
