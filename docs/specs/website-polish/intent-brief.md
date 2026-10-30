# Język polski na stronie dokumentacji — Intent Brief

## Workshop Summary

| Field | Value |
|---|---|
| Workshop Date | 2026-09-23 |
| Participants | Zleceniodawca (czat); brak transkryptu warsztatu |
| Source Materials | Prośba: „przeanalizuj możliwość dodania języka polskiego do website/”; analiza obecnej strony dokumentacji (brak Figma, PDF, baseline) |
| Prepared By | Business Analyst (eversis-analyze-materials) |

Transkrypt nie został dostarczony — krok czyszczenia transkryptu pominięty.

## Goal

Umożliwić osobom czytającym publiczną dokumentację Agent Collections pracę po polsku, bez zmiany języka, w jakim działają agenci i źródło prawdy frameworka. Pierwsza wersja ma objąć ścieżkę czytelnika (strona główna, nawigacja i przewodniki), a angielski ma zostać językiem domyślnym i językiem źródeł.

## In Scope

- **Cała strona dokumentacji** — wszystkie ~140 stron docs, strona główna, dziennik zmian, menu, stopka.
- Wybór języka (przełącznik) oraz polskie adresy stron; angielski pozostaje domyślny.
- Polska wersja przewodników (start, główny przepływ, zaawansowane), całej referencji (skille, agenci, integracje, prompty, słownik) oraz dziennika zmian.
- Pipeline utrzymania polskich stron promptów przy regeneracji z angielskiego źródła (`.ai/prompts/` → `website/docs/`).
- Wyszukiwanie po polskiej treści oraz weryfikacja buildu dla obu języków.
- Zasada: identyfikatory (`eversis-implement`), nazwy plików, bloki kodu i ścieżki repozytorium zostają po angielsku na polskich stronach.

## Out of Scope

- Tłumaczenie źródeł frameworka dla agentów (`.ai/prompts/`, `.ai/skills/`, reguły). Agenci dalej pracują na angielskim SSOT.
- Inne języki niż polski.
- Tłumaczenie poza `website/` (root README, CHANGELOG SSOT, kod, adaptery) — z wyjątkiem rozszerzeń pipeline’u sync pod polską stronę.
- Zmiana merytoryki dokumentacji — tylko język prezentacji dla czytelnika.

## Key Stakeholders / Actors

- Czytelnik dokumentacji po polsku — chce zrozumieć framework bez czytania całości po angielsku.
- Opiekun dokumentacji — decyduje, co jest tłumaczone i jak polska wersja nadąża za zmianami angielskiej.
- Zespół frameworka — angielskie źródło prawdy agentów ma zostać nietknięte.

## Current State (z analizy strony)

- Strona jest publiczna (dokumentacja Docusaurus) i dziś wyłącznie angielska.
- Ustawienie języka istnieje, ale włączony jest tylko angielski. Nie ma przełącznika języka ani katalogu polskich stron.
- Około 140 stron dokumentacji, ~75 tys. słów, plus strona główna i dziennik zmian (~7,5 tys. słów).
- Największa część to referencja (~57 tys. słów): prompty (~25 tys., odtwarzane z angielskiego źródła), skille, agenci, integracje.
- Przewodniki czytelnika (start, główny przepływ, zaawansowane) to ~17 tys. słów — wyraźnie mniejszy i stabilniejszy zakres.
- Wyszukiwanie indeksuje obecne, angielskie strony.

Wniosek biznesowy: dodanie polskiego jest możliwe na tej samej stronie. Koszt nie leży w przełączniku języka, tylko w tym, **które** strony tłumaczyć i **kto** utrzymuje polski w zgodzie z angielskim przy kolejnych zmianach.

## Candidate Epics

- Wybór języka na stronie — czytelnik przełącza angielski i polski; angielski zostaje domyślny.
- Polska ścieżka czytelnika — strona główna, menu, stopka oraz przewodniki start / główny przepływ / zaawansowane.
- Polska referencja kuratorska — skille, agenci, integracje, słownik; bez stron promptów odtwarzanych ze źródła. Kandydat na późniejszą falę, nie na pierwszy zakres, dopóki Gate 0 tego nie włączy.
- Utrzymanie tłumaczeń — przy zmianie angielskiej strony objętej zakresem powstaje ślad, że polska wersja wymaga aktualizacji.
- Wyszukiwanie po polsku — zapytanie po polsku znajduje polskie strony z pierwszej wersji.

## Baseline Overlap / Existing Backlog Notes

- Brak `docs/context/<project>/task-baseline.md` i brak wcześniejszego backlogu w `docs/specs/` dla tego tematu.
- Folder `docs/specs/*/` w tym repozytorium jest lokalny (gitignore). Ten brief nie trafia do historii gita, dopóki zespół świadomie go nie opublikuje.

## Assumptions

- Angielski pozostaje językiem domyślnym. Polski jest wyborem czytelnika, nie zastępuje angielskiego.
- Tłumaczenie wykonuje zespół (lub agent w kolejnym etapie po zatwierdzeniu backlogu). Brief nie zakłada zewnętrznego biura tłumaczeń.
- Nazwy własne produktu, identyfikatory (`eversis-implement` itd.) i bloki kodu zostają po angielsku.

## Open Questions

- Kto odpowiada za aktualizację polskiego, gdy zmieni się angielska strona objęta zakresem?
- Czy polski ma się włączać automatycznie według języka przeglądarki, czy tylko po jawnym wyborze w przełączniku?

## Gate 0 Approval

| Decision | Notes |
|---|---|
| **Approved** | 2026-09-23 — użytkownik wybrał **całą stronę** (przewodniki + referencja + prompty + dziennik zmian + UI). |
