# Genereer synthetische sociale-integratiedata voor de workshop.

generate_synthetic_data <- function(output_path = "data/synthetische_sociale_integratie.csv") {
  set.seed(20260618)

  n <- 500
  nomem_encr <- seq_len(n)
  integratie <- rnorm(n)

  # Tevredenheid: hogere latente integratie geeft gemiddeld meer tevredenheid.
  tevredenheid_latent <- 5.5 + 1.7 * integratie + rnorm(n, sd = 1.6)
  cs08a283 <- pmin(10, pmax(0, round(tevredenheid_latent)))

  # Eenzaamheidsitems: negatieve items vaker "ja" bij lagere integratie;
  # positieve items vaker "ja" bij hogere integratie.
  kans_hoog_eenzaam <- plogis(-integratie)
  kans_laag_eenzaam <- plogis(integratie)

  maak_item <- function(kans_ja) {
    score <- ifelse(
      runif(n) < kans_ja,
      sample(c(1, 2), n, replace = TRUE, prob = c(0.70, 0.30)),
      sample(c(2, 3), n, replace = TRUE, prob = c(0.25, 0.75))
    )
    as.integer(score)
  }

  cs08a284 <- maak_item(kans_hoog_eenzaam)
  cs08a288 <- maak_item(kans_hoog_eenzaam)
  cs08a289 <- maak_item(kans_hoog_eenzaam)
  cs08a285 <- maak_item(kans_laag_eenzaam)
  cs08a286 <- maak_item(kans_laag_eenzaam)
  cs08a287 <- maak_item(kans_laag_eenzaam)

  # Contactitems: hogere integratie geeft vaker contact, dus lagere ruwe codes.
  maak_contact <- function() {
    contact_latent <- 4.4 - 1.25 * integratie + rnorm(n, sd = 1.3)
    as.integer(pmin(7, pmax(1, round(contact_latent))))
  }

  cs08a290 <- maak_contact()
  cs08a291 <- maak_contact()
  cs08a292 <- maak_contact()

  rawdata <- data.frame(
    nomem_encr = nomem_encr,
    cs08a283 = cs08a283,
    cs08a284 = cs08a284,
    cs08a285 = cs08a285,
    cs08a286 = cs08a286,
    cs08a287 = cs08a287,
    cs08a288 = cs08a288,
    cs08a289 = cs08a289,
    cs08a290 = cs08a290,
    cs08a291 = cs08a291,
    cs08a292 = cs08a292
  )

  # Voeg verplichte speciale codes en echte lege waarden toe.
  rawdata$cs08a283[c(17, 101, 309)] <- 999
  rawdata$cs08a290[c(23, 205)] <- 8
  rawdata$cs08a291[c(37, 220)] <- 9
  rawdata$cs08a292[c(44, 260)] <- 8

  missing_posities <- list(
    c(58, "cs08a283"),
    c(76, "cs08a284"),
    c(88, "cs08a287"),
    c(121, "cs08a290"),
    c(142, "cs08a292")
  )

  for (positie in missing_posities) {
    rawdata[as.integer(positie[1]), positie[2]] <- NA_integer_
  }

  dir.create(dirname(output_path), recursive = TRUE, showWarnings = FALSE)
  write.csv(rawdata, output_path, row.names = FALSE, na = "")
  rawdata
}
