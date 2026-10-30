# Jira-ready — DHI-630

**Status (2026-08-25):** Research w pełni rozstrzygnięte (13/13 pytań Gap Analysis zaakceptowanych przez stakeholdera) i zatwierdzone. Plan wdrożenia (7 faz) napisany, czeka na zatwierdzenie przed Implement. Treść poniżej zastępuje poprzednią wersję (przed Research) — kilka założeń z pierwotnej analizy krytycznej okazało się nieaktualnych po dokładnej analizie (zob. zmiany niżej) i zostało poprawionych, nie tylko "domkniętych".

---

## DHI-630

| Pole | Wartość |
|---|---|
| **Key** | DHI-630 |
| **Project** | DHI |
| **Issue type** | Task |
| **Powiązanie** | `Relates` do DHI-603 ("[DAWIS] Spec-Driven Development Process") — nie strukturalny subtask; próba reparentingu do DHI-515/DHI-603 odrzucona przez Jira (ograniczenie hierarchii issue type, wymaga ręcznej konwersji przez Move issue wizard, jeśli pożądana) |
| **Assignee** | piotrniemirski |
| **Summary** | Global domain-context SSOT dla multi-repo enterprise topology (DAWIS/EOG/EOP/User Area) |
| **Labels** | ssot, multi-repo, gitlab, context-isolation |
| **Priority** | High |

### Description

**Task Context:** Framework agent-collections nie ma dziś warstwy pamięci dla wiedzy faktograficznej o aplikacji ("jak działa moduł X", "dlaczego wybrano Y nie Z"), współdzielonej między repozytoriami w topologii GitLab Grupa (`DAWIS`) → Projekty (`EOG`/`EOP`/`User Area`). Mechanizm dostarcza dwupoziomową (project + global) warstwę SSOT, czytaną i pisaną przez agentów AI, bez naruszania zasady Core/Consumer frameworka i bez wymuszania ceremonii nieproporcjonalnej do faktycznego (niskiego) ryzyka nieaktualności wiedzy.

**Zakres (in scope), po rozstrzygnięciu Research:**
- `docs/context/<project>/<domena>/<temat>.md` (wiedza domenowa, płasko, project-level) + `docs/context/global/<domena>/<temat>.md` (subtree pull z `domain-context`, dedykowany katalog-sibling) — **nie** nowy top-level folder `docs/knowledge/`, **nie** `.ai/context/`; oba mieszczą się w normatywnej triadzie `docs/context/`/`docs/plans/`/`docs/specs/`.
- `<domena>` = komponent/funkcjonalność (np. `checkout-flow/`), nie luźny temat biznesowy — ułatwia odkrywalność, bo koreluje z `code_paths` z frontmatteru.
- Frontmatter: `scope`, `source`, `last_updated`, `tags`, `related_specs` (rosnąca lista linków, nie pojedyncze odniesienie), `code_paths` (nowe), `confluence_url` (nowe), `last_consulted` (nowe — faza Obserwacji).
- `.agent-collections/ssot.json` z `externalSsotRepo`/`projectContextPath`/`globalContextPath`; instalator scaffolduje `docs/context/<project>/INDEX.md` zawsze i próbuje best-effort `git subtree add` przy instalacji (nie blokuje przy braku sieci/dostępu).
- Rozszerzenie `eversis-collections-mcp` o `eversis_context_get`/`list`/`sync` — **bez** `eversis_context_search` (jawnie odrzucone: agenci Claude Code/Cursor radzą sobie natywnym Read/Glob/Grep przy limicie ~200 linii `INDEX.md`).
- Import Confluence AS-IS przez istniejący `atlassian` MCP — **opcjonalny** (`--confluence-space-key` nieobowiązkowy), instalacja bez klucza kończy się sukcesem w trybie "pusty start".
- Skill `eversis-promote-domain-knowledge` — promocja wiedzy z konkretną heurystyką (jawne konwencje/reguły biznesowe/wzorce integracji = TAK; detale implementacyjne = NIE; promocja przy drugim wystąpieniu dla przypadków granicznych), zapis przez GitLab REST API (Branches/Commits multi-action/Merge Requests) **bez lokalnego checkoutu** `domain-context`. Human gate = **rozszerzenie istniejącego Fine** (drugi, siostrzany draft), nie nowy, osobny gate.
- Dystrybucja `domain-context` → `EOG`/`EOP`/`User Area`: `subtree pull`, tryb **"latest"** (bez SemVer/tagowania — świadomie odrzucone, częsty cykl zmian), synchronizacja **manualna** (`eversis_context_sync`, jedna komenda) — **bez** blokującego CI/bota push-on-merge (świadomie odrzucone: ryzyko staleness jest wyłącznie jakością draftu agenta, zawsze pod ludzkim review).
- Skill `eversis-audit-domain-knowledge` — cykliczny przegląd (Keep/Update/Consolidate/Replace/Delete) wykorzystujący `last_consulted`.

**Poza zakresem (out of scope):**
- Pełna implementacja OpenCode adaptera dla tego mechanizmu.
- Ciągła (nie jednorazowa) synchronizacja z Confluence.
- Usunięcie/zmiana `docs/context/<project>/task-baseline.md` (Step 11, `eversis-jira-task-formatting`) — pozostaje bez zmian, współistnieje jako rodzeństwo.
- Generalizacja przykładów `EOG-1234`/DAWIS w `eversis-ba-docs-planner/SKILL.md` — potwierdzona, ale osobny task.
- Provisioning tokenu GitLab dla promocji `project → global` — zakładany jako już istniejący, poza zakresem instalatora.

**Rozstrzygnięcia z Research, które zmieniły pierwotną analizę krytyczną (nie tylko ją domknęły):**
1. **Write-path doprecyzowany:** PR wprost do `domain-context` przez GitLab API (bez checkoutu), nie `subtree push` — usuwa cały problem rekonstrukcji historii squasha.
2. **Konwencja project/global ustalona:** `docs/context/<project>/` (project) vs `docs/context/global/` (subtree) — nie koliduje z `task-baseline.md`, nie wymaga nowego top-level folderu.
3. **Kolizja z `task-baseline.md` zamknięta bez zmiany żadnego z dwóch mechanizmów** — normatywny standard frameworka (`agents-md-standard.md`) już dziś nazywa `docs/context/` jako miejsce "internal knowledge, architecture notes" — oba typy treści współistnieją jako rodzeństwo.
4. **CI staleness — próg i blokada odrzucone.** Pełna analiza reperkusji nie znalazła żadnego skutku o wadze uzasadniającej blokadę; widoczność przenosi się na moment odczytu przez agenta (`eversis_context_get`), sync pozostaje manualny.
5. **Wersjonowanie:** tryb "latest", bez SemVer — `domain-context` ma zbyt częsty cykl zmian dla tagowania per promocję.
6. **Nowe, wcześniej nienazwane ustalenie:** instalacja frameworka powinna best-effort zasilić `docs/context/global/` od razu (Question 13) — inaczej świeżo zainstalowane repo ma całkowicie pusty katalog, nie tylko nieaktualny, do czasu pierwszego manualnego syncu.

Pełna analiza wszystkich 13 pytań: [`global-domain-context-ssot.research.md`](./global-domain-context-ssot.research.md). Plan wdrożenia (7 faz): [`global-domain-context-ssot.plan.md`](./global-domain-context-ssot.plan.md).

### Acceptance Criteria (Given/When/Then)

- **AC1 (discovery):** GIVEN agent pracuje w repo `EOG` z zainstalowanym mechanizmem, WHEN wywołuje `eversis_context_get`/`list`, THEN otrzymuje treść project (jeśli istnieje) lub global (fallback) z adnotacją źródła i staleness, bez `eversis_context_search`.
- **AC2 (fizyczna obecność od razu po instalacji):** GIVEN świeża instalacja `setup-agent-collections.sh` z `--ssot-source` wskazującym osiągalny `domain-context`, WHEN instalacja się kończy, THEN `docs/context/global/` jest już wypełnione — bez dodatkowego, ręcznego kroku dewelopera.
- **AC3 (write-path bez ręcznej synchronizacji na poziomie zapisu):** GIVEN agent w `EOG` proponuje promocję wiedzy i człowiek zatwierdza ją w turze Fine, WHEN zmiana ma trafić do `docs/context/<project>/`, THEN zapis następuje przez GitLab API bez lokalnego checkoutu, w tym samym, atomowym commicie co aktualizacja `INDEX.md`.
- **AC4 (Confluence seed opcjonalny, nieblokujący):** GIVEN instalacja bez `--confluence-space-key`, WHEN instalator kończy pracę, THEN instalacja kończy się sukcesem w trybie "pusty start" z jasnym ostrzeżeniem, nie błędem.
- **AC5 (staleness widoczna, nieblokująca):** GIVEN `docs/context/global/` nie był odświeżany od dłuższego czasu, WHEN agent wywołuje `eversis_context_get`, THEN odpowiedź zawiera adnotację "N dni/commitów opóźnienia", ale żaden `git commit`/`push`/merge nie jest blokowany.
- **AC6 (izolacja frameworka — Question 9):** GIVEN historia git `agent-collections` po zamknięciu tej story, WHEN przeszukiwana jest pod kątem treści specyficznej dla DAWIS/EOG, THEN zwraca zero wyników — treść `domain-context`/`agent-collections-config` żyje wyłącznie w projektach GitLab `DAWIS` i repo-konsumenckich.

---

## Delivery Standard

This story follows full spec-driven development (mandatory under Agent Collections / epic DHI-515 when applicable).

* Spec folder: `docs/specs/global-domain-context-ssot/`
* Research: [`global-domain-context-ssot.research.md`](./global-domain-context-ssot.research.md) — **zaakceptowane przez stakeholdera 2026-08-25**, 13/13 pytań rozstrzygniętych
* Plan: [`global-domain-context-ssot.plan.md`](./global-domain-context-ssot.plan.md) — napisany (7 faz), **czeka na zatwierdzenie** przed Implement
* Implement: load `eversis-implement` (po zatwierdzeniu planu)
* Review: runs inside the Implement session by default (`eversis-review`); standalone `/eversis-review` is optional
* Fine: QA comment draft **i** (jeśli dotyczy) draft promocji wiedzy, per `eversis-fine-handoff` (ten sam turn); publikacja do trackera tylko z jawną zgodą człowieka

Do not start implementation without approved plan (research already approved).

## Source traceability

- Jira: DHI-630 (Task, `Relates` do DHI-603), assignee piotrniemirski
- Research: `docs/specs/global-domain-context-ssot/global-domain-context-ssot.research.md` (13 pytań, wszystkie rozstrzygnięte 2026-08-25)
- Plan: `docs/specs/global-domain-context-ssot/global-domain-context-ssot.plan.md` (7 faz)
- Źródłowy dokument (punkt wyjścia analizy, nie już-aktualna specyfikacja): Google Drive `AI_agents/Agent Collections/global-domain-context-ssot-v2.md`
- Parent epic research: `docs/specs/dhi-515/dhi-515.research.md`
