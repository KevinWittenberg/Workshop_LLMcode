# Analyseer de synthetische sociale-integratiedata.

clean_analyse_data <- function(rawdata) {
  analysedata <- rawdata

  analysedata$tevredenheid <- ifelse(
    analysedata$cs08a283 == 999,
    NA_real_,
    analysedata$cs08a283
  )

  negatieve_items <- c("cs08a284", "cs08a288", "cs08a289")
  positieve_items <- c("cs08a285", "cs08a286", "cs08a287")

  for (v in negatieve_items) {
    analysedata[[paste0(v, "_e")]] <- ifelse(
      analysedata[[v]] %in% 1:3,
      3 - analysedata[[v]],
      NA_real_
    )
  }

  for (v in positieve_items) {
    analysedata[[paste0(v, "_e")]] <- ifelse(
      analysedata[[v]] %in% 1:3,
      analysedata[[v]] - 1,
      NA_real_
    )
  }

  score_items <- paste0(
    c("cs08a284", "cs08a285", "cs08a286", "cs08a287", "cs08a288", "cs08a289"),
    "_e"
  )
  compleet_eenzaamheid <- complete.cases(analysedata[score_items])
  analysedata$eenzaamheid_score <- NA_real_
  analysedata$eenzaamheid_score[compleet_eenzaamheid] <- rowSums(
    analysedata[compleet_eenzaamheid, score_items]
  )

  contact_items <- c("cs08a290", "cs08a291", "cs08a292")
  for (v in contact_items) {
    schoon <- ifelse(analysedata[[v]] %in% c(8, 9), NA_real_, analysedata[[v]])
    schoon <- ifelse(schoon %in% 1:7, schoon, NA_real_)
    analysedata[[paste0(v, "_r")]] <- 8 - schoon
  }

  contact_r <- paste0(contact_items, "_r")
  compleet_contact <- complete.cases(analysedata[contact_r])
  analysedata$contactfrequentie_gem <- NA_real_
  analysedata$contactfrequentie_gem[compleet_contact] <- rowMeans(
    analysedata[compleet_contact, contact_r]
  )

  analysedata
}

maak_descriptives <- function(analysedata) {
  analysevariabelen <- c("tevredenheid", "eenzaamheid_score", "contactfrequentie_gem")

  do.call(
    rbind,
    lapply(analysevariabelen, function(v) {
      waarden <- analysedata[[v]]
      geldige_waarden <- waarden[!is.na(waarden)]
      data.frame(
        variabele = v,
        n = length(geldige_waarden),
        gemiddelde = mean(geldige_waarden),
        standaarddeviatie = sd(geldige_waarden),
        minimum = min(geldige_waarden),
        maximum = max(geldige_waarden),
        row.names = NULL
      )
    })
  )
}

maak_regressie <- function(analysedata) {
  modeldata <- analysedata[complete.cases(
    analysedata[c("tevredenheid", "eenzaamheid_score", "contactfrequentie_gem")]
  ), ]
  model <- lm(tevredenheid ~ eenzaamheid_score + contactfrequentie_gem, data = modeldata)
  model_samenvatting <- summary(model)
  coefficienten <- as.data.frame(model_samenvatting$coefficients)

  data.frame(
    term = rownames(coefficienten),
    schatting = coefficienten[["Estimate"]],
    standaardfout = coefficienten[["Std. Error"]],
    t_waarde = coefficienten[["t value"]],
    p_waarde = coefficienten[["Pr(>|t|)"]],
    n = nobs(model),
    row.names = NULL
  )
}

run_analyse <- function(
    input_path = "data/synthetische_sociale_integratie.csv",
    descriptives_path = "output/r_descriptives.csv",
    regressie_path = "output/r_regressie.csv") {
  rawdata <- read.csv(input_path, na.strings = c(""))
  analysedata <- clean_analyse_data(rawdata)
  descriptives <- maak_descriptives(analysedata)
  regressie <- maak_regressie(analysedata)

  dir.create(dirname(descriptives_path), recursive = TRUE, showWarnings = FALSE)
  write.csv(descriptives, descriptives_path, row.names = FALSE)
  write.csv(regressie, regressie_path, row.names = FALSE)

  list(
    rawdata = rawdata,
    analysedata = analysedata,
    descriptives = descriptives,
    regressie = regressie,
    model_terms = setdiff(regressie$term, "(Intercept)"),
    regressie_n = unique(regressie$n)
  )
}
