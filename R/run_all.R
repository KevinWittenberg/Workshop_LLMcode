# Draai de volledige R-pipeline voor de workshopanalyse.

source("R/generate_synthetic_data.R")
source("R/analyse.R")
source("R/tests.R")

cat("Genereer synthetische data...\n")
generate_synthetic_data("data/synthetische_sociale_integratie.csv")

cat("Voer analyse uit...\n")
resultaat <- run_analyse(
  input_path = "data/synthetische_sociale_integratie.csv",
  descriptives_path = "output/r_descriptives.csv",
  regressie_path = "output/r_regressie.csv"
)

cat("Voer tests uit...\n")
run_tests(resultaat)

cat("R-pipeline geslaagd: data, analyse, output en tests zijn afgerond.\n")
