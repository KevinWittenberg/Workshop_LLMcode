# Analyseopdracht: Codex gebruiken voor R en Stata

Deze workshop laat zien hoe je een LLM gebruikt om statistische syntax te ontwerpen, te controleren en te documenteren. Het voorbeeld is klein: een synthetische sociale-integratieanalyse die in R en Stata dezelfde logica moet volgen.

De kracht van Codex is vooral zichtbaar bij R: Codex kan bestanden maken, R zelf draaien, fouten lezen en opnieuw proberen. Bij Stata ligt de nadruk op goede syntax, controles en lokale validatie door de deelnemer.

## 1. Context voor deelnemers

We werken met een toy-project, niet met echte onderzoeksdata. De synthetische uitkomsten zijn alleen bedoeld om code en controles te oefenen.

Onderzoeksvraag:

> In hoeverre hangen gevoelens van eenzaamheid en de frequentie van sociale contacten samen met de tevredenheid over sociale contacten?

Gebruik alleen deze variabelen:

- `nomem_encr`
- `cs08a283` tot en met `cs08a292`

De compacte codebook-specificatie staat in `codebook/subset_variabelen.md`.

## 2. Klassieke LLM-vraag

Begin buiten Codex of in een gewone chat. Het doel is niet meteen code, maar begrip: wat moet de analyse doen en waar kunnen fouten ontstaan?

Kopieer deze prompt:

```text
Ik volg een workshop over het maken en controleren van R- en Stata-syntax met hulp van een LLM.

Ik wil een kleine synthetische analyse maken over sociale integratie. De analyse gebruikt een tevredenheidsscore, zes eenzaamheidsitems en drie contactfrequentie-items. Leg in gewone taal uit:

1. welke stappen ik logisch moet zetten van ruwe data naar regressie;
2. welke keuzes ik expliciet moet vastleggen voordat ik code laat maken;
3. welke fouten vaak ontstaan bij missings, schaalscores en R/Stata-verschillen;
4. welke tests of controles ik minimaal zou willen hebben.

Geef nog geen volledige code. Stel eerst vragen als er iets ontbreekt.
```

## 3. Codex laten landen in het project

Nu ga je naar Codex. Laat Codex eerst de repo lezen en jou teruggeven wat het denkt dat de opdracht is. Er wordt nog niets geïmplementeerd.

Kopieer deze prompt:

```text
Lees eerst de bestanden in deze repo, in ieder geval README.md, AGENTS.md, analyseopdracht.md en codebook/subset_variabelen.md.

Vat daarna kort samen:

1. wat het doel van dit toy-project is;
2. welke bestanden Codex uiteindelijk waarschijnlijk moet maken;
3. welke inhoudelijke regels uit het codebook belangrijk zijn;
4. welke onderdelen in R uitgevoerd kunnen worden;
5. welke onderdelen voor Stata alleen statisch gecontroleerd kunnen worden totdat ik ze lokaal draai.

Implementeer nog niets. Stel gerichte vragen als iets in de opdracht onduidelijk is.
```

## 4. Plan maken met tests eerst

De beste Codex-workflow begint met alignment en daarna een concreet plan. Vraag expliciet om verwachte gedragingen, tests en acceptatiecriteria.

Kopieer deze prompt:

```text
Maak een implementatieplan voor dit project, maar wijzig nog geen bestanden.

Het plan moet tests en controles eerst behandelen. Beschrijf concreet:

1. welke R-bestanden je gaat maken;
2. welke Stata-bestanden je gaat maken;
3. hoe de synthetische data worden gegenereerd;
4. hoe cleaning, schaalscores, descriptives en regressie in R en Stata gelijk blijven;
5. welke R-tests moeten slagen;
6. welke Stata-controles in de do-files moeten staan;
7. welke outputbestanden verwacht worden;
8. hoe je rapporteert wat wel en niet is uitgevoerd.

Let op: R mag je zelf uitvoeren met `Rscript R/run_all.R`. Stata mag je niet als uitgevoerd rapporteren tenzij Stata werkelijk beschikbaar is en de do-files echt zijn gedraaid.
```

## 5. Inhoudelijke specificatie

Deze regels zijn de bron voor de code. Als Codex iets anders voorstelt, moet het dat expliciet melden en niet stil aanpassen.

### Te maken bestanden

R:

```text
R/generate_synthetic_data.R
R/analyse.R
R/tests.R
R/run_all.R
```

Stata:

```text
stata/analyse.do
stata/controles.do
```

Data en output:

```text
data/synthetische_sociale_integratie.csv
output/r_descriptives.csv
output/r_regressie.csv
output/stata_descriptives.csv
output/stata_regressie.csv
```

De Stata-output ontstaat pas nadat de deelnemer de do-files lokaal in Stata uitvoert.

### Synthetische data

Genereer in R exact 500 fictieve respondenten met:

```r
set.seed(20260618)
```

Gebruik `nomem_encr` als uniek synthetisch respondentnummer van 1 tot en met 500.

De data moeten:

- uitsluitend de geselecteerde variabelen bevatten;
- de officiële ruwe antwoordcodes volgen;
- een kleine hoeveelheid missings bevatten;
- minimaal één waarde `999` bevatten bij `cs08a283`;
- minimaal één waarde `8` en één waarde `9` bevatten bij de contactitems;
- minimaal één echte lege waarde bevatten;
- een plausibele, kunstmatig gemaakte samenhang bevatten.

Een geschikte aanpak is een latente synthetische sociale-integratievariabele. Hogere integratie hangt dan samen met hogere tevredenheid, minder eenzaamheid en vaker sociaal contact. Gebruik geen echte records en kopieer geen echte verdelingen uit het codebook.

### Cleaning

`cs08a283`:

- 0-10 zijn geldig;
- 999 wordt missing;
- lege waarden blijven missing.

Contactitems `cs08a290`, `cs08a291` en `cs08a292`:

- 1-7 zijn geldig;
- 8 en 9 worden missing;
- lege waarden blijven missing.

### Eenzaamheidsscore

Gebruik `cs08a284` tot en met `cs08a289`.

Negatieve items:

- `cs08a284`
- `cs08a288`
- `cs08a289`

Codering:

- 1 wordt 2
- 2 wordt 1
- 3 wordt 0

Positieve items:

- `cs08a285`
- `cs08a286`
- `cs08a287`

Codering:

- 1 wordt 0
- 2 wordt 1
- 3 wordt 2

Bereken `eenzaamheid_score` alleen wanneer alle zes items geldig en niet-missing zijn. De geldige score loopt van 0 tot en met 12. Een hogere score betekent meer eenzaamheid.

### Contactfrequentie

Gebruik `cs08a290`, `cs08a291` en `cs08a292`.

Draai geldige waarden 1-7 om met:

```text
nieuwe waarde = 8 - oorspronkelijke waarde
```

Daarmee betekent een hogere waarde vaker contact. Bereken `contactfrequentie_gem` als het gemiddelde van de drie omgekeerde items, maar alleen wanneer alle drie beschikbaar zijn. De geldige score loopt van 1 tot en met 7.

### Descriptives en regressie

Maak in beide talen een descriptieve tabel met minimaal:

- variabelenaam;
- aantal geldige observaties;
- gemiddelde;
- standaarddeviatie;
- minimum;
- maximum.

Neem minimaal op:

- `tevredenheid`;
- `eenzaamheid_score`;
- `contactfrequentie_gem`.

Schat in beide talen hetzelfde lineaire model met complete cases:

```text
tevredenheid = eenzaamheid_score + contactfrequentie_gem
```

Maak een regressietabel met minimaal:

- term;
- schatting;
- standaardfout;
- t-waarde;
- p-waarde;
- aantal gebruikte observaties.

## 6. R laten maken, draaien en verbeteren

Hier zie je het voordeel van Codex met R: Codex kan de bestanden maken, de pipeline draaien, foutmeldingen lezen en zelfstandig repareren.

Kopieer deze prompt:

```text
Implementeer nu alleen het R-deel van de opdracht.

Maak of update:

- R/generate_synthetic_data.R
- R/analyse.R
- R/tests.R
- R/run_all.R

Werk met base R waar dat redelijk kan. Gebruik alleen relatieve paden vanaf de hoofdmap.

Schrijf eerst de tests in R/tests.R en implementeer daarna de generator en analyse. De volledige pipeline moet vanaf de hoofdmap draaien met:

Rscript R/run_all.R

R/run_all.R moet:

1. de synthetische data genereren;
2. de analyse uitvoeren;
3. outputbestanden opslaan;
4. alle tests uitvoeren;
5. stoppen met foutstatus als een test faalt;
6. een korte succesmelding tonen als alles slaagt.

Voer `Rscript R/run_all.R` zelf uit. Lees eventuele fouten, herstel ze zonder tests of inhoudelijke eisen af te zwakken, en herhaal totdat alle R-tests slagen.

Rapporteer kort welke bestanden je hebt gemaakt of aangepast, welke opdracht je hebt uitgevoerd, welke tests zijn geslaagd en welke output is geproduceerd.
```

### Minimale R-tests

De R-tests controleren minimaal:

1. de ruwe synthetische dataset bevat exact 500 rijen;
2. `nomem_encr` is uniek en nergens missing;
3. alle ruwe waarden vallen binnen de afgesproken codes;
4. de synthetische data bevatten minimaal één `999`, één `8`, één `9` en minimaal één lege waarde;
5. na cleaning komen `999`, `8` en `9` niet meer als geldige analysewaarden voor;
6. `eenzaamheid_score` ligt tussen 0 en 12;
7. `contactfrequentie_gem` ligt tussen 1 en 7;
8. beide samengestelde scores zijn alleen gevuld bij complete bronitems;
9. het regressiemodel bevat exact de afgesproken voorspellers;
10. er zijn minimaal 300 complete observaties voor de regressie;
11. de R-outputbestanden bestaan en zijn niet leeg;
12. dezelfde seed levert dezelfde synthetische dataset op.

Tests mogen niet worden verwijderd of afgezwakt om de pipeline te laten slagen.

## 7. R-iteratie na fouten

Gebruik deze prompt als de pipeline faalt of de output verdacht is. Het doel is diagnose, niet creatief herschrijven.

Kopieer deze prompt:

```text
De R-pipeline faalt of levert verdachte output op.

Lees de foutmelding en de relevante R-bestanden. Leg kort uit:

1. welke test of stap faalt;
2. wat waarschijnlijk de oorzaak is;
3. welke minimale wijziging je gaat doen.

Pas daarna de code aan. Verander de inhoudelijke operationalisering niet en verzwak geen tests. Draai opnieuw:

Rscript R/run_all.R

Herhaal dit totdat de R-pipeline slaagt of totdat je precies kunt uitleggen waarom je vastloopt.
```

## 8. Stata-code laten maken

Codex kan Stata-code goed schrijven en vergelijken met de R-logica, maar Stata wordt meestal niet in deze omgeving uitgevoerd. De prompt moet daarom gaan over correcte do-files en statische controle, niet over doen alsof de code al lokaal is getest.

Kopieer deze prompt:

```text
Implementeer nu het Stata-deel van de opdracht op basis van de werkende R-logica.

Maak of update:

- stata/analyse.do
- stata/controles.do

Gebruik alleen standaard Stata-commando's en relatieve paden vanaf de hoofdmap. Stata mag geen aparte dataset genereren: stata/analyse.do leest dezelfde CSV als R:

import delimited using "data/synthetische_sociale_integratie.csv", clear

stata/analyse.do moet dezelfde cleaning, schaalscores, descriptives en regressie uitvoeren als R, en schrijven naar:

- output/stata_descriptives.csv
- output/stata_regressie.csv

stata/controles.do moet controleerbare assert-regels bevatten en stoppen wanneer een cruciale controle faalt.

Controleer de Stata-code statisch tegen de werkende R-code. Claim niet dat Stata is uitgevoerd tenzij je Stata echt hebt kunnen draaien. Rapporteer expliciet welke controles de deelnemer lokaal nog moet uitvoeren.
```

### Minimale Stata-controles

Neem minimaal controles op voor:

- 500 ingelezen rijen;
- unieke `nomem_encr`;
- toegestane ruwe codes;
- correcte omzetting van bijzondere missingcodes;
- bereik van beide samengestelde scores;
- scores alleen bij complete bronitems;
- voldoende complete regressie-observaties;
- aanwezigheid van de afgesproken regressievariabelen;
- bestaan van de afgesproken outputbestanden.

Gebruik waar mogelijk `assert`. Laat het do-file stoppen wanneer een cruciale controle faalt.

## 9. Stata lokaal valideren

Deze stap doet de deelnemer zelf in Stata. Geef de foutmelding terug aan Codex als er iets breekt.

Voer lokaal uit vanaf de hoofdmap:

```stata
do stata/analyse.do
do stata/controles.do
```

Als Stata een foutmelding geeft, kopieer deze prompt terug naar Codex:

```text
Ik heb de Stata-code lokaal uitgevoerd vanaf de hoofdmap.

Deze opdracht gaf een fout:

[plak hier de exacte Stata-opdracht]

Deze foutmelding kreeg ik:

[plak hier de exacte Stata-foutmelding en eventueel de regels erboven]

Lees de Stata-do-files en vergelijk ze met de werkende R-code. Leg kort uit wat de oorzaak is, pas de Stata-code minimaal aan, en vertel welke lokale Stata-opdrachten ik opnieuw moet uitvoeren.

Claim niet dat de Stata-code bij jou is getest.
```

## 10. Code laten uitleggen en annoteren

Deze prompt is bedoeld voor een bestaand R- of Stata-bestand. De beste uitleg is kort, controleert aannames en geeft daarna een bruikbaar geannoteerd bestand terug.

Kopieer deze prompt:

```text
Leg dit codebestand uit en maak een geannoteerde versie.

Bestand:

[vul hier het pad in, bijvoorbeeld stata/analyse.do]

Werkwijze:

1. Lees eerst het bestand en de relevante opdrachtcontext.
2. Geef een korte uitleg van de kernsecties: inlezen, cleaning, schaalscores, output, model en controles.
3. Benoem aannames, risico's en plekken waar R en Stata verschillend kunnen uitpakken.
4. Verander het gedrag van de code niet.
5. Voeg korte, nuttige commentaarregels toe in dezelfde stijl als het bestand.
6. Geef daarna het volledig geannoteerde bestand terug of pas het bestand aan als ik daar expliciet om vraag.

Houd de uitleg praktisch. Vermijd lange algemene tekst.
```

## 11. Acceptatiecriteria

De opdracht is klaar wanneer:

- alle gevraagde R- en Stata-bestanden bestaan;
- `Rscript R/run_all.R` zonder fout eindigt;
- alle verplichte R-tests slagen;
- de R-outputbestanden bestaan en niet leeg zijn;
- R en Stata dezelfde cleaning- en scoringsregels gebruiken;
- Stata een zelfstandig analyse- en controlescript heeft;
- de agent niet beweert dat Stata is uitgevoerd wanneer dat niet zo is;
- alle code korte Nederlandstalige comments bevat;
- alle paden relatief zijn;
- geen echte data zijn gebruikt.

## 12. Eindrapportage

Vraag Codex na implementatie om maximaal tien punten:

```text
Geef een korte eindrapportage met maximaal tien punten.

Noem:

1. gemaakte en gewijzigde bestanden;
2. gebruikte R-opdracht;
3. resultaat van de R-tests;
4. gemaakte R-output;
5. manier waarop R en Stata gelijk zijn gehouden;
6. onderdelen die alleen statisch voor Stata zijn gecontroleerd;
7. exacte lokale Stata-opdrachten die ik nog moet uitvoeren;
8. resterende beperkingen of aandachtspunten.

Claim nooit dat Stata is getest wanneer dat niet werkelijk in Stata is uitgevoerd.
```
