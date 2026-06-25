# AGENTS.md

## Doel van dit repository

Dit repository bevat een kleine toy-analyse voor een workshop over het verantwoord gebruiken van Codex bij R- en Stata-syntax.

De analyse werkt uitsluitend met synthetische data. Gebruik nooit echte onderzoeksdata, persoonsgegevens, geheime sleutels of vertrouwelijke projectinformatie.

## Manier van werken

- Werk vanuit de hoofdmap van het repository.
- Lees eerst `README.md`, `analyseopdracht.md` en `codebook/subset_variabelen.md`.
- Bekijk bestaande R- en Stata-bestanden voordat je ze wijzigt.
- Vraag de gebruiker om verduidelijking wanneer de opdracht, scope of gewenste aanpak onduidelijk is.
- Maak voor inhoudelijke of technische wijzigingen eerst een kort plan.
- Werk in kleine, controleerbare stappen.
- Beperk wijzigingen tot de gevraagde taak.
- Verander de inhoudelijke operationalisering alleen wanneer de gebruiker daar expliciet om vraagt.
- Gebruik relatieve paden vanaf de hoofdmap.

## Tests en controles

- Schrijf of behoud controles voordat je de analyse uitbreidt.
- Voor R: voer de pipeline uit wanneer R beschikbaar is en herstel fouten totdat de gevraagde R-tests slagen.
- Voor Stata: schrijf standaard Stata-code en controleer die statisch tegen de R-logica, maar claim geen Stata-uitvoering tenzij Stata werkelijk lokaal is uitgevoerd.
- Verzwak tests, asserts of inhoudelijke eisen niet om de code te laten slagen.

## Commits

Als dit een git-repository is, stel dan na een afgeronde, controleerbare stap een commit voor. Maak geen commit zonder expliciete toestemming van de gebruiker.

## Toon en rapportage

- Schrijf helder, concreet en kort.
- Benoem welke bestanden zijn gemaakt of aangepast.
- Benoem welke opdrachten zijn uitgevoerd.
- Meld eerlijk welke controles zijn geslaagd en welke nog lokaal moeten worden uitgevoerd.
- Maak duidelijk onderscheid tussen uitgevoerde R-tests, statische Stata-controle en Stata-code die de gebruiker nog zelf moet draaien.
