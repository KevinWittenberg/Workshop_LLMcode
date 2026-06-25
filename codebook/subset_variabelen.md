# Subset variabelen: sociale integratie

## Bron en gebruik

Deze workshop gebruikt een kleine selectie uit het codeboek *Social Integration and Leisure, LISS Core Study, Wave 1*.

Dit bestand is een compacte, geparafraseerde projectspecificatie. Het is leidend voor de workshopcode. De synthetische data zijn fictief en mogen niet als echte LISS-data worden geïnterpreteerd.

## 1. Identificatie

| Variabele | Betekenis | Codering in workshop |
|---|---|---|
| `nomem_encr` | Respondentnummer | Uniek synthetisch geheel getal 1–500 |

Het workshopbestand bevat geen echte versleutelde respondentnummers.

## 2. Uitkomstvariabele

### `cs08a283` — tevredenheid met sociale contacten

De respondent geeft een score voor tevredenheid met sociale contacten.

| Ruwe waarde | Betekenis |
|---:|---|
| 0 | helemaal niet tevreden |
| 1–9 | tussenliggende score |
| 10 | helemaal tevreden |
| 999 | weet niet |

Cleaning:

- 0–10 blijven geldig;
- 999 wordt missing;
- lege waarden blijven missing.

R:

```r
tevredenheid <- ifelse(cs08a283 == 999, NA_real_, cs08a283)
```

Stata:

```stata
clonevar tevredenheid = cs08a283
replace tevredenheid = . if tevredenheid == 999
assert inrange(tevredenheid, 0, 10) | missing(tevredenheid)
```

## 3. Items voor eenzaamheid

Alle zes items gebruiken dezelfde ruwe antwoordcategorieën:

| Ruwe waarde | Betekenis |
|---:|---|
| 1 | ja |
| 2 | min of meer |
| 3 | nee |

| Variabele | Verkorte omschrijving | Richting |
|---|---|---|
| `cs08a284` | leegte ervaren | negatief |
| `cs08a285` | mensen om op terug te vallen | positief |
| `cs08a286` | mensen volledig kunnen vertrouwen | positief |
| `cs08a287` | mensen met wie men zich nauw verbonden voelt | positief |
| `cs08a288` | mensen om zich heen missen | negatief |
| `cs08a289` | zich in de steek gelaten voelen | negatief |

### Hercodering

Negatieve items:

| Ruw | Score |
|---:|---:|
| 1 | 2 |
| 2 | 1 |
| 3 | 0 |

Positieve items:

| Ruw | Score |
|---:|---:|
| 1 | 0 |
| 2 | 1 |
| 3 | 2 |

Een hogere score betekent steeds meer eenzaamheid.

### R-voorbeeld

```r
negatieve_items <- c("cs08a284", "cs08a288", "cs08a289")
positieve_items <- c("cs08a285", "cs08a286", "cs08a287")

for (v in negatieve_items) {
  analysedata[[paste0(v, "_e")]] <- 3 - analysedata[[v]]
}

for (v in positieve_items) {
  analysedata[[paste0(v, "_e")]] <- analysedata[[v]] - 1
}

score_items <- paste0(
  c("cs08a284", "cs08a285", "cs08a286",
    "cs08a287", "cs08a288", "cs08a289"),
  "_e"
)

compleet <- complete.cases(analysedata[score_items])
analysedata$eenzaamheid_score <- NA_real_
analysedata$eenzaamheid_score[compleet] <-
  rowSums(analysedata[compleet, score_items])
```

### Stata-voorbeeld

```stata
gen cs08a284_e = 3 - cs08a284
gen cs08a285_e = cs08a285 - 1
gen cs08a286_e = cs08a286 - 1
gen cs08a287_e = cs08a287 - 1
gen cs08a288_e = 3 - cs08a288
gen cs08a289_e = 3 - cs08a289

egen n_eenzaamheid = rownonmiss( ///
    cs08a284_e cs08a285_e cs08a286_e ///
    cs08a287_e cs08a288_e cs08a289_e)

egen eenzaamheid_score = rowtotal( ///
    cs08a284_e cs08a285_e cs08a286_e ///
    cs08a287_e cs08a288_e cs08a289_e)

replace eenzaamheid_score = . if n_eenzaamheid < 6
assert inrange(eenzaamheid_score, 0, 12) | missing(eenzaamheid_score)
```

### Definitie workshopscore

```text
eenzaamheid_score =
  cs08a284_e +
  cs08a285_e +
  cs08a286_e +
  cs08a287_e +
  cs08a288_e +
  cs08a289_e
```

Bereken de score alleen bij zes geldige antwoorden.

Geldig bereik: 0–12.

> Deze workshopoperationalisering is bedoeld als programmeeroefening. Zij wordt niet gepresenteerd als een officiële of gevalideerde LISS-schaal.

## 4. Contactfrequentie

| Variabele | Activiteit |
|---|---|
| `cs08a290` | een avond met familie buiten het eigen huishouden |
| `cs08a291` | een avond met iemand uit de buurt |
| `cs08a292` | een avond met vrienden buiten de buurt |

De drie items gebruiken dezelfde codering:

| Ruwe waarde | Betekenis |
|---:|---|
| 1 | bijna elke dag |
| 2 | een of twee keer per week |
| 3 | enkele keren per maand |
| 4 | ongeveer eenmaal per maand |
| 5 | enkele keren per jaar |
| 6 | ongeveer eenmaal per jaar |
| 7 | nooit |
| 8 | weet niet |
| 9 | niet van toepassing |

Cleaning:

- 1–7 zijn geldig;
- 8 en 9 worden missing;
- lege waarden blijven missing.

Draai de geldige schaal om met:

```text
omgekeerde score = 8 - ruwe score
```

Daarna loopt de schaal van 1 = nooit tot 7 = bijna elke dag.

### R-voorbeeld

```r
contact_items <- c("cs08a290", "cs08a291", "cs08a292")

for (v in contact_items) {
  schoon <- ifelse(
    analysedata[[v]] %in% c(8, 9),
    NA_real_,
    analysedata[[v]]
  )
  analysedata[[paste0(v, "_r")]] <- 8 - schoon
}

contact_r <- paste0(contact_items, "_r")
compleet_contact <- complete.cases(analysedata[contact_r])

analysedata$contactfrequentie_gem <- NA_real_
analysedata$contactfrequentie_gem[compleet_contact] <-
  rowMeans(analysedata[compleet_contact, contact_r])
```

### Stata-voorbeeld

```stata
foreach v in cs08a290 cs08a291 cs08a292 {
    clonevar `v'_schoon = `v'
    replace `v'_schoon = . if inlist(`v'_schoon, 8, 9)
    gen `v'_r = 8 - `v'_schoon
}

egen n_contact = rownonmiss(cs08a290_r cs08a291_r cs08a292_r)
egen contactfrequentie_gem = rowmean(cs08a290_r cs08a291_r cs08a292_r)
replace contactfrequentie_gem = . if n_contact < 3

assert inrange(contactfrequentie_gem, 1, 7) | ///
    missing(contactfrequentie_gem)
```

## 5. Analysevariabelen

De uiteindelijke analyse gebruikt:

| Naam in analyse | Afleiding | Bereik |
|---|---|---:|
| `tevredenheid` | `cs08a283`, met 999 als missing | 0–10 |
| `eenzaamheid_score` | som van zes gehercodeerde items | 0–12 |
| `contactfrequentie_gem` | gemiddelde van drie omgekeerde contactitems | 1–7 |

## 6. Beschrijvende statistiek

Maak voor de drie analysevariabelen:

- aantal geldige observaties;
- gemiddelde;
- standaarddeviatie;
- minimum;
- maximum.

R-output:

```text
output/r_descriptives.csv
```

Stata-output:

```text
output/stata_descriptives.csv
```

## 7. Regressiemodel

Schat:

```text
tevredenheid =
  intercept +
  eenzaamheid_score +
  contactfrequentie_gem +
  fout
```

R:

```r
model <- lm(
  tevredenheid ~ eenzaamheid_score + contactfrequentie_gem,
  data = analysedata
)
```

Stata:

```stata
regress tevredenheid eenzaamheid_score contactfrequentie_gem
```

Gebruik in beide talen complete cases.

## 8. Minimale inhoudelijke controles

### R

```r
stopifnot(
  all(is.na(analysedata$tevredenheid) |
        analysedata$tevredenheid >= 0 &
        analysedata$tevredenheid <= 10),
  all(is.na(analysedata$eenzaamheid_score) |
        analysedata$eenzaamheid_score >= 0 &
        analysedata$eenzaamheid_score <= 12),
  all(is.na(analysedata$contactfrequentie_gem) |
        analysedata$contactfrequentie_gem >= 1 &
        analysedata$contactfrequentie_gem <= 7)
)
```

### Stata

```stata
assert inrange(tevredenheid, 0, 10) | missing(tevredenheid)
assert inrange(eenzaamheid_score, 0, 12) | missing(eenzaamheid_score)
assert inrange(contactfrequentie_gem, 1, 7) | ///
    missing(contactfrequentie_gem)
```

Controleer daarnaast in beide talen dat samengestelde scores alleen bestaan wanneer alle benodigde bronitems geldig zijn.
