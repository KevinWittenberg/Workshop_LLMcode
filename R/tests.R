# Tests voor de synthetische sociale-integratieanalyse.

assert_true <- function(conditie, melding) {
  if (!isTRUE(conditie)) {
    stop(melding, call. = FALSE)
  }
}

assert_all <- function(conditie, melding) {
  if (!all(conditie, na.rm = FALSE)) {
    stop(melding, call. = FALSE)
  }
}

run_tests <- function(resultaat) {
  rawdata <- resultaat$rawdata
  analysedata <- resultaat$analysedata

  verwachte_variabelen <- c(
    "nomem_encr", "cs08a283", "cs08a284", "cs08a285", "cs08a286",
    "cs08a287", "cs08a288", "cs08a289", "cs08a290", "cs08a291", "cs08a292"
  )

  assert_true(nrow(rawdata) == 500, "Ruwe dataset moet exact 500 rijen bevatten.")
  assert_true(identical(names(rawdata), verwachte_variabelen), "Ruwe dataset bevat niet exact de afgesproken variabelen.")
  assert_true(!any(is.na(rawdata$nomem_encr)), "nomem_encr mag geen missings bevatten.")
  assert_true(length(unique(rawdata$nomem_encr)) == 500, "nomem_encr moet uniek zijn.")
  assert_true(identical(rawdata$nomem_encr, seq_len(500)), "nomem_encr moet lopen van 1 tot en met 500.")

  assert_all(is.na(rawdata$cs08a283) | rawdata$cs08a283 %in% c(0:10, 999), "cs08a283 bevat ongeldige ruwe codes.")

  eenzaamheid_items <- c("cs08a284", "cs08a285", "cs08a286", "cs08a287", "cs08a288", "cs08a289")
  for (v in eenzaamheid_items) {
    assert_all(is.na(rawdata[[v]]) | rawdata[[v]] %in% 1:3, paste(v, "bevat ongeldige ruwe codes."))
  }

  contact_items <- c("cs08a290", "cs08a291", "cs08a292")
  for (v in contact_items) {
    assert_all(is.na(rawdata[[v]]) | rawdata[[v]] %in% 1:9, paste(v, "bevat ongeldige ruwe codes."))
  }

  assert_true(any(rawdata$cs08a283 == 999, na.rm = TRUE), "Synthetische data moeten minimaal één 999 bevatten bij cs08a283.")
  assert_true(any(rawdata[contact_items] == 8, na.rm = TRUE), "Synthetische data moeten minimaal één 8 bevatten bij contactitems.")
  assert_true(any(rawdata[contact_items] == 9, na.rm = TRUE), "Synthetische data moeten minimaal één 9 bevatten bij contactitems.")
  assert_true(any(is.na(rawdata)), "Synthetische data moeten minimaal één echte lege waarde bevatten.")

  assert_all(is.na(analysedata$tevredenheid) | analysedata$tevredenheid >= 0 & analysedata$tevredenheid <= 10, "tevredenheid ligt buiten 0-10.")
  assert_true(all(is.na(analysedata$tevredenheid[rawdata$cs08a283 == 999])), "999 moet missing worden in tevredenheid.")

  assert_all(is.na(analysedata$eenzaamheid_score) | analysedata$eenzaamheid_score >= 0 & analysedata$eenzaamheid_score <= 12, "eenzaamheid_score ligt buiten 0-12.")
  assert_all(is.na(analysedata$contactfrequentie_gem) | analysedata$contactfrequentie_gem >= 1 & analysedata$contactfrequentie_gem <= 7, "contactfrequentie_gem ligt buiten 1-7.")

  score_items <- paste0(eenzaamheid_items, "_e")
  compleet_eenzaamheid <- complete.cases(analysedata[score_items])
  assert_true(all(!is.na(analysedata$eenzaamheid_score[compleet_eenzaamheid])), "eenzaamheid_score ontbreekt bij complete bronitems.")
  assert_true(all(is.na(analysedata$eenzaamheid_score[!compleet_eenzaamheid])), "eenzaamheid_score is gevuld bij incomplete bronitems.")

  contact_r <- paste0(contact_items, "_r")
  compleet_contact <- complete.cases(analysedata[contact_r])
  assert_true(all(!is.na(analysedata$contactfrequentie_gem[compleet_contact])), "contactfrequentie_gem ontbreekt bij complete bronitems.")
  assert_true(all(is.na(analysedata$contactfrequentie_gem[!compleet_contact])), "contactfrequentie_gem is gevuld bij incomplete bronitems.")

  for (v in contact_items) {
    r_v <- paste0(v, "_r")
    bijzondere_code <- rawdata[[v]] %in% c(8, 9)
    assert_true(all(is.na(analysedata[[r_v]][bijzondere_code])), paste("8 en 9 moeten missing worden voor", v))
  }

  assert_true(setequal(resultaat$model_terms, c("eenzaamheid_score", "contactfrequentie_gem")), "Regressiemodel bevat niet exact de afgesproken voorspellers.")
  assert_true(length(resultaat$regressie_n) == 1 && resultaat$regressie_n >= 300, "Regressie moet minimaal 300 complete observaties gebruiken.")

  assert_true(file.exists("output/r_descriptives.csv") && file.info("output/r_descriptives.csv")$size > 0, "output/r_descriptives.csv ontbreekt of is leeg.")
  assert_true(file.exists("output/r_regressie.csv") && file.info("output/r_regressie.csv")$size > 0, "output/r_regressie.csv ontbreekt of is leeg.")

  eerste <- generate_synthetic_data(tempfile(fileext = ".csv"))
  tweede <- generate_synthetic_data(tempfile(fileext = ".csv"))
  assert_true(identical(eerste, tweede), "Dezelfde seed moet dezelfde synthetische dataset opleveren.")

  TRUE
}
