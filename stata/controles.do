* Controleer de Stata-logica voor de synthetische sociale-integratieanalyse.
clear all
set more off

import delimited using "data/synthetische_sociale_integratie.csv", clear varnames(1) numericcols(_all)

* Ruwe dataset en sleutels.
assert _N == 500
isid nomem_encr
assert inrange(nomem_encr, 1, 500)

* Ruwe codes volgens de workshop-specificatie.
assert inrange(cs08a283, 0, 10) | cs08a283 == 999 | missing(cs08a283)
foreach v in cs08a284 cs08a285 cs08a286 cs08a287 cs08a288 cs08a289 {
    assert inrange(`v', 1, 3) | missing(`v')
}
foreach v in cs08a290 cs08a291 cs08a292 {
    assert inrange(`v', 1, 9) | missing(`v')
}

* Verplichte bijzondere codes in de synthetische data.
count if cs08a283 == 999
assert r(N) >= 1
count if cs08a290 == 8 | cs08a291 == 8 | cs08a292 == 8
assert r(N) >= 1
count if cs08a290 == 9 | cs08a291 == 9 | cs08a292 == 9
assert r(N) >= 1

* Cleaning en schaalscores opnieuw afleiden voor controle.
clonevar tevredenheid = cs08a283
replace tevredenheid = . if tevredenheid == 999
assert inrange(tevredenheid, 0, 10) | missing(tevredenheid)
assert missing(tevredenheid) if cs08a283 == 999

gen cs08a284_e = 3 - cs08a284 if inrange(cs08a284, 1, 3)
gen cs08a285_e = cs08a285 - 1 if inrange(cs08a285, 1, 3)
gen cs08a286_e = cs08a286 - 1 if inrange(cs08a286, 1, 3)
gen cs08a287_e = cs08a287 - 1 if inrange(cs08a287, 1, 3)
gen cs08a288_e = 3 - cs08a288 if inrange(cs08a288, 1, 3)
gen cs08a289_e = 3 - cs08a289 if inrange(cs08a289, 1, 3)

egen n_eenzaamheid = rownonmiss(cs08a284_e cs08a285_e cs08a286_e cs08a287_e cs08a288_e cs08a289_e)
egen eenzaamheid_score = rowtotal(cs08a284_e cs08a285_e cs08a286_e cs08a287_e cs08a288_e cs08a289_e)
replace eenzaamheid_score = . if n_eenzaamheid < 6
assert inrange(eenzaamheid_score, 0, 12) | missing(eenzaamheid_score)
assert missing(eenzaamheid_score) if n_eenzaamheid < 6
assert !missing(eenzaamheid_score) if n_eenzaamheid == 6

foreach v in cs08a290 cs08a291 cs08a292 {
    clonevar `v'_schoon = `v'
    replace `v'_schoon = . if inlist(`v'_schoon, 8, 9)
    assert inrange(`v'_schoon, 1, 7) | missing(`v'_schoon)
    assert missing(`v'_schoon) if inlist(`v', 8, 9)
    gen `v'_r = 8 - `v'_schoon if inrange(`v'_schoon, 1, 7)
}

egen n_contact = rownonmiss(cs08a290_r cs08a291_r cs08a292_r)
egen contactfrequentie_gem = rowmean(cs08a290_r cs08a291_r cs08a292_r)
replace contactfrequentie_gem = . if n_contact < 3
assert inrange(contactfrequentie_gem, 1, 7) | missing(contactfrequentie_gem)
assert missing(contactfrequentie_gem) if n_contact < 3
assert !missing(contactfrequentie_gem) if n_contact == 3

* Regressievariabelen en complete cases.
confirm variable tevredenheid
confirm variable eenzaamheid_score
confirm variable contactfrequentie_gem
count if !missing(tevredenheid, eenzaamheid_score, contactfrequentie_gem)
assert r(N) >= 300

* Output van stata/analyse.do moet bestaan nadat de deelnemer die do-file lokaal draaide.
confirm file "output/stata_descriptives.csv"
confirm file "output/stata_regressie.csv"
