* Analyseer synthetische sociale-integratiedata in Stata.
clear all
set more off

capture mkdir output

import delimited using "data/synthetische_sociale_integratie.csv", clear varnames(1) numericcols(_all)

* Basiscontroles op ruwe data.
assert _N == 500
isid nomem_encr
assert inrange(nomem_encr, 1, 500)
assert inrange(cs08a283, 0, 10) | cs08a283 == 999 | missing(cs08a283)
foreach v in cs08a284 cs08a285 cs08a286 cs08a287 cs08a288 cs08a289 {
    assert inrange(`v', 1, 3) | missing(`v')
}
foreach v in cs08a290 cs08a291 cs08a292 {
    assert inrange(`v', 1, 9) | missing(`v')
}

* Tevredenheid: 999 is een bijzondere missingcode.
clonevar tevredenheid = cs08a283
replace tevredenheid = . if tevredenheid == 999
assert inrange(tevredenheid, 0, 10) | missing(tevredenheid)

* Eenzaamheid: negatieve en positieve items krijgen dezelfde richting.
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

* Contactfrequentie: 8 en 9 zijn missing, daarna schaal omdraaien.
foreach v in cs08a290 cs08a291 cs08a292 {
    clonevar `v'_schoon = `v'
    replace `v'_schoon = . if inlist(`v'_schoon, 8, 9)
    assert inrange(`v'_schoon, 1, 7) | missing(`v'_schoon)
    gen `v'_r = 8 - `v'_schoon if inrange(`v'_schoon, 1, 7)
}

egen n_contact = rownonmiss(cs08a290_r cs08a291_r cs08a292_r)
egen contactfrequentie_gem = rowmean(cs08a290_r cs08a291_r cs08a292_r)
replace contactfrequentie_gem = . if n_contact < 3
assert inrange(contactfrequentie_gem, 1, 7) | missing(contactfrequentie_gem)
assert missing(contactfrequentie_gem) if n_contact < 3
assert !missing(contactfrequentie_gem) if n_contact == 3

* Beschrijvende statistiek in hetzelfde formaat als de R-output.
tempname desc_handle
postfile `desc_handle' str32 variabele double n gemiddelde standaarddeviatie minimum maximum using "output/stata_descriptives.dta", replace
foreach v in tevredenheid eenzaamheid_score contactfrequentie_gem {
    quietly summarize `v'
    post `desc_handle' ("`v'") (r(N)) (r(mean)) (r(sd)) (r(min)) (r(max))
}
postclose `desc_handle'
preserve
use "output/stata_descriptives.dta", clear
export delimited using "output/stata_descriptives.csv", replace
restore
erase "output/stata_descriptives.dta"

* Regressie op complete cases; Stata gebruikt listwise deletion bij regress.
count if !missing(tevredenheid, eenzaamheid_score, contactfrequentie_gem)
assert r(N) >= 300
regress tevredenheid eenzaamheid_score contactfrequentie_gem

matrix b = e(b)
matrix v = e(V)
local n = e(N)
local df = e(df_r)

tempname reg_handle
postfile `reg_handle' str32 term double schatting standaardfout t_waarde p_waarde n using "output/stata_regressie.dta", replace
foreach term in _cons eenzaamheid_score contactfrequentie_gem {
    local kolom = colnumb(b, "`term'")
    local estimate = b[1, `kolom']
    local se = sqrt(v[`kolom', `kolom'])
    local t = `estimate' / `se'
    local p = 2 * ttail(`df', abs(`t'))
    local naam = cond("`term'" == "_cons", "(Intercept)", "`term'")
    post `reg_handle' ("`naam'") (`estimate') (`se') (`t') (`p') (`n')
}
postclose `reg_handle'
preserve
use "output/stata_regressie.dta", clear
export delimited using "output/stata_regressie.csv", replace
restore
erase "output/stata_regressie.dta"

confirm file "output/stata_descriptives.csv"
confirm file "output/stata_regressie.csv"
