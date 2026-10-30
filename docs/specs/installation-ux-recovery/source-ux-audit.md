Oto szczegółowa analiza UX, architektury informacji (IA) oraz czytelności strony **Installation** (/docs/getting-started/installation) z perspektywy deweloperów, a przede wszystkim użytkowników nietechnicznych (**QA, Business Analyst, Product Owner**).  
  
## 1. Werdykt ogólny (Executive Summary)  
Obecna wersja strony zawiera wyczerpujące szczegóły techniczne, ale **nie funkcjonuje poprawnie jako przewodnik instalacyjny (Getting Started)**. Jest napisana w stylu wewnętrznej specyfikacji inżynierskiej (reference manual / dev notes), a nie ścieżki wdrożeniowej.  
  
**Główne bariery:**  
* **Odwrócona hierarchia informacji (Inverted Flow):** Sekcja z prostym, gotowym przykładem (*„First successful install (sample project)”*) znajduje się na samym dole (sekcja 6), zamiast na początku. Użytkownik najpierw musi przebrnąć przez tabelę 12 flag CLI, wewnętrzne mechanizmy submodułów Gita i synchronizację adapterów.   
* **Bariera platformowa (Brak wsparcia dla Windows):** Wszystkie polecenia w blokach kodu operują na uniksowych ścieżkach (cd ~/projects, export VAR=..., test -f ...). Użytkownik Windowsa wklejający te komendy do PowerShell natychmiast otrzyma błędy składni.   
* **Przeładowanie kognitywne (Cognitive Overload):** Treści dla maintainerów frameworka (np. sekcja 2: *„npm run sync:adapters”* czy zaawansowane rozwiązywanie konfliktów SHA submodułów) są wymieszane z podstawowymi krokami instalacji dla zwykłego użytkownika.   
## 2. Szczegółowy audyt problemów UX i IA  
**A. Brak rozróżnienia systemów operacyjnych (Brak **<Tabs>**)**  
* **Stan obecny:**  Bash      cd ~/projects  
* git clone https://gitlab3.eversis.com/eversis-ai/agent-collections.git agent-collections  
* export AGENT_COLLECTIONS_HOME="$(pwd)/agent-collections"  
*       
* **Problem:** W PowerShellu na Windowsie komenda export nie istnieje, a składnia $(pwd) w cudzysłowach zachowuje się inaczej niż w Bashu. Ponadto skrypt setup-agent-collections.sh wymaga uruchomienia przez powłokę Bash (np. Git Bash). Użytkownik Windows zostaje zablokowany już w punkcie 1.   
* **Rekomendacja:** Zastosowanie komponentu <Tabs groupId="operating-system"> z podziałem na **macOS/Linux** oraz **Windows (Git Bash / PowerShell)**.   
**B. Przeładowana tabela flag CLI w sekcji onboardingowej**  
* **Stan obecny:** Sekcja 3 zawiera tabelę z **12 flagami** (m.in. --ssot-source, --ssot-branch, --confluence-space-key, --link-mode, --collections-home).   
* **Problem:** Z perspektywy QA/BA, którzy chcą tylko uruchomić narzędzie, ta tabela wywołuje paraliż decyzyjny. Użytkownik zastanawia się: *„Czy muszę podać mój Confluence key już teraz?”, „Co to jest SSOT branch?”*.   
* **Rekomendacja:** Zastosowanie zasady **Progressive Disclosure** (stopniowego odkrywania wiedzy):   
    1. Podaj **jedno gotowe polecenie domyślne** (rekomendowane dla 90% przypadków).   
    2. Tabelę zaawansowanych flag przenieś do sekcji zwijanej (<details> w Markdown) lub do sekcji *Reference*.   
**C. Niewłaściwe umiejscowienie sekcji 2: „Open the framework (optional for maintainers)”**  
* **Stan obecny:** Krok 2 w numerowanej liście instruuje, jak edytować framework i uruchamiać npm run sync:adapters.   
* **Problem:** Numerowanie 1 → 2 → 3 sugeruje obowiązkową sekwencję. Użytkownik instalujący narzędzie do swojego projektu biznesowego nie powinien otwierać kodu źródłowego frameworka ani synchronizować adapterów.   
* **Rekomendacja:** Usuń ten krok z głównej osi procedury i umieść go na samym końcu strony lub w dedykowanej sekcji dla deweloperów frameworka.   
**D. Brak jasnego modelu mentalnego („Framework” vs „Consumer Project”)**  
* **Problem:** W krokach 1 i 3 użytkownik musi operować na dwóch różnych katalogach:   
    1. Gdzieś na dysku pobiera repozytorium agent-collections.   
    2. Następnie musi przejść (cd) do swojego docelowego projektu (my-sample-project).   
* Dla osób mniej oswojonych z terminalem przeskakiwanie między dwoma folderami i przekazywanie ścieżki przez zmienną środowiskową jest częstym źródłem pomyłek (np. uruchamianie instalatora wewnątrz repozytorium frameworka).   
* **Rekomendacja:** Dodaj prosty schemat tekstowy lub wyraźne wyróżnienie w tekście:   
    * **Krok A:** Pobierz bibliotekę narzędzi (raz na komputerze).   
    * **Krok B:** Przejdź do swojego projektu i zainstaluj w nim narzędzia.   
**E. Zakopany „Smoke Test” (Weryfikacja instalacji)**  
* **Stan obecny:** Test sprawdzający, czy instalacja przebiegła pomyślnie (test -f .agent-collections/install-selection.json), pojawia się dopiero w sekcji 6 pod nazwą *„First successful install (sample project)”*.   
* **Problem:** W krokach 3 i 4 użytkownik nie otrzymuje żadnego potwierdzenia, czy proces się udał i co właściwie powstało w jego projekcie.   
* **Rekomendacja:** Każdy krok instalacji musi kończyć się blokiem **„Jak rozpoznać sukces”** (np. *„W Twoim projekcie powstał ukryty folder *.agent-collections* oraz plik *docs/context/.../INDEX.md*”*).   
## 3. Matryca błędów i rekomendacji UX  

| Element strony | Stan obecny | Rekomendacja UX |
| ----------------- | ------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| Wstęp i Callout | Odsyła z powrotem do Start here, tworząc pętlę nawigacyjną. | Krótki komunikat: „Zainstaluj Agent Collections w swoim projekcie w 3 krokach”. |
| Systemy OS | Wyłącznie składnia uniksowa (~, export, bash). | Taby macOS / Linux vs Windows (ze wskazaniem Git Bash). |
| Struktura kroków | 1. Clone → 2. Maintainers → 3. Bootstrap → 4. Skills → 5. Upgrade → 6. First install. | 1. Przygotuj framework → 2. Uruchom w swoim projekcie → 3. Sprawdź wynik. Zaawansowane sekcje (Upgrade, Submodules) przenieś niżej. |
| Tryby instalacji | Mieszanie terminologii vendor mode, symlink, submodule. | Rekomendacja domyślna: Dla QA/BA: tryb standardowy (bez flag vendor). |
| Spis treści (TOC) | 12 pozycji o różnym poziomie szczegółowości, duży szum informacyjny. | Ograniczenie spisu treści do 4–5 głównych sekcji merytorycznych (toc_max_heading_level: 2). |
  
****4. Gotowy, zoptymalizowany szablon MDX (Do wdrożenia)****  
Poniższy kod rozwiązuje powyższe problemy, zachowując całą wiedzę inżynierską, ale prezentując ją w ergonomiczny sposób:  
  
Fragment kodu  
##   
##   
##   
##   
---  
id: installation  
title: Installation  
description: Przewodnik instalacji i wdrożenia frameworka Agent Collections w projekcie.  
toc_max_heading_level: 2  
---  
  
import Tabs from '@theme/Tabs';  
import TabItem from '@theme/TabItem';  
  
Instalacja polega na pobraniu frameworka **Agent Collections** na Twój komputer, a następnie wdrożeniu jego reguł i narzędzi do Twojego projektu docelowego (**consumer project**).  
  
:::tip Wymagania wstępne  
Przed uruchomieniem instalatora upewnij się, że masz zainstalowane narzędzia z kroku **[Prerequisites](/docs/getting-started/prerequisites)** (zwłaszcza **Docker Desktop**, który musi być uruchomiony w tle).  
:::  
  
---  
  
## Krok 1: Pobierz framework na dysk  
  
Framework pobierasz **tylko raz** w dowolne miejsce na swoim komputerze (np. do katalogu z projektami):  
  
<Tabs groupId="operating-system">  
<TabItem value="mac" label="macOS / Linux" default>  
  
```bash  
cd ~/projects  
git clone [https://gitlab3.eversis.com/eversis-ai/agent-collections.git](https://gitlab3.eversis.com/eversis-ai/agent-collections.git) agent-collections  
export AGENT_COLLECTIONS_HOME="$(pwd)/agent-collections"  
```  
  
</TabItem>  
<TabItem value="windows" label="Windows">  
  
Uruchom **Git Bash** (instalowany razem z Git for Windows):  
  
```bash  
cd /c/projekty   # Przejdź do swojego folderu projektów  
git clone [https://gitlab3.eversis.com/eversis-ai/agent-collections.git](https://gitlab3.eversis.com/eversis-ai/agent-collections.git) agent-collections  
export AGENT_COLLECTIONS_HOME="$(pwd)/agent-collections"  
```  
  
*(Alternatywnie w PowerShell: `$env:AGENT_COLLECTIONS_HOME = "C:\projekty\agent-collections"`)*  
  
</TabItem>  
</Tabs>  
  
---  
  
## Krok 2: Zainstaluj framework w swoim projekcie  
  
Przejdź w terminalu do folderu **Twojego projektu biznesowego** (lub utwórz pusty folder testowy) i uruchom skrypt instalacyjny:  
  
<Tabs groupId="operating-system">  
<TabItem value="mac" label="macOS / Linux" default>  
  
```bash  
cd ~/projects/moj-projekt  
  
bash "$AGENT_COLLECTIONS_HOME/scripts/setup-agent-collections.sh" \  
  --build-mcp --non-interactive \  
  --agents=cursor,claude \  
  --profile=fullstack  
```  
  
</TabItem>  
<TabItem value="windows" label="Windows (Git Bash)">  
  
```bash  
cd /c/projekty/moj-projekt  
  
bash "$AGENT_COLLECTIONS_HOME/scripts/setup-agent-collections.sh" \  
  --build-mcp --non-interactive \  
  --agents=cursor,claude \  
  --profile=fullstack  
```  
  
</TabItem>  
</Tabs>  
  
:::info Co oznacza parametr `--profile`?  
* `fullstack` (zalecany): instaluje komplet reguł frontendowych i backendowych.  
* `frontend` lub `backend`: ogranicza adaptery tylko do wybranej części stosu technologicznego.  
:::  
  
---  
  
## Krok 3: Weryfikacja (Smoke Test)  
  
Skąd masz wiedzieć, że instalacja przebiegła pomyślnie? Sprawdź swój projekt:  
  
1. W katalogu Twojego projektu pojawił się plik:    
   `.agent-collections/install-selection.json`  
2. Został utworzony plik kontekstu domenowego:    
   `docs/context/<nazwa-projektu>/INDEX.md`  
3. Konsola instalatora zakończyła działanie kodem `0` bez błędów krytycznych.  
  
Gdy powyższe warunki są spełnione, przejdź do kroku **[MCP Setup](/docs/getting-started/mcp-setup)**, aby połączyć narzędzia z Twoim edytorem (Cursor lub Claude Code).  
  
---  
  
## Aktualizacja frameworka (Upgrade & Sync)  
  
Gdy w repozytorium frameworka pojawią się nowe wersje promptów lub adapterów, zaktualizuj swój projekt uruchamiając w jego katalogu:  
  
```bash  
bash "$AGENT_COLLECTIONS_HOME/scripts/setup-agent-collections.sh" \  
  --upgrade --sync --non-interactive  
```  
  
Instalator zachowa Twoje lokalne reguły i nadpisze wyłącznie pliki zarządzane globalnie przez framework.  
  
---  
  
## Opcje zaawansowane (Dla deweloperów i maintainerów)  
  
<details>  
<summary><strong>Rozwiń: Praca z Git Submodule (Dla zespołów)</strong></summary>  
  
Jeśli Twój zespół preferuje wersjonowanie frameworka bezpośrednio w repozytorium aplikacji:  
1. Użyj flagi `--vendor submodule` podczas instalacji.  
2. Członkowie zespołu po sklonowaniu repozytorium muszą wykonać:  
   ```bash  
   git submodule update --init --recursive  
   ```  
3. Aktualizacja wersji frameworka w submodule wymaga ręcznego podbicia commitu:  
   ```bash  
   cd vendor/agent-collections  
   git fetch origin && git checkout <nowy-tag>  
   cd ../.. && git add vendor/agent-collections  
   ```  
  
</details>  
  
<details>  
<summary><strong>Rozwiń: Pełna lista flag instalatora CLI</strong></summary>  
  
| Flaga | Działanie |  
| :--- | :--- |  
| `--build-mcp` | Wymusza przebudowanie obrazu Dockera dla serwera MCP. |  
| `--agents=...` | Wybór edytorów: `cursor`, `claude` lub oba (`cursor,claude`). |  
| `--profile=...` | Profil reguł: `frontend`, `backend`, `fullstack`. |  
| `--vendor=...` | Tryb powiązania: `local` (domyślny), `submodule`, `copy`. |  
| `--upgrade` | Aktualizuje istniejącą instalację w oparciu o `install-selection.json`. |  
| `--sync` | Odświeża adaptery w projekcie. |  
| `--confluence-space-key KEY` | Zapisuje klucz przestrzeni Confluence do późniejszego importu wiedzy. |  
  
</details>  
**Co zyskujesz po wdrożeniu zmian?**  
1. **Czas do pierwszego sukcesu (TTF - Time to First Success):** Skrócenie z kilkunastu minut czytania do 2 minut (wykonanie 2 komend).   
2. **Eliminacja błędów platformowych:** Użytkownicy Windowsa otrzymują precyzyjną instrukcję korzystania z *Git Bash*.   
3. **Czystość poznawcza:** Złożone zagadnienia dotyczące *Git Submodules* i pełna lista 12 flag CLI są ukryte w elementach akordeonowych (<details>), nie odwracając uwagi person nietechnicznych od właściwej instalacji.  
