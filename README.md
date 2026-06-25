# Workshop AI-syntax voor R en Stata

Dit repository is een downloadbare template voor een workshop over werken met LLM's bij statistische syntax. Deelnemers bouwen stap voor stap een kleine analyse in R en Stata op basis van synthetische data.

De workshop laat bewust twee workflows naast elkaar zien:

- In R kan Codex bestanden maken, code uitvoeren, testfouten lezen en itereren tot de pipeline slaagt.
- In Stata kan Codex do-files schrijven en statisch controleren, maar deelnemers draaien de code zelf lokaal in Stata.

## Inhoud

```text
AGENTS.md
analyseopdracht.md
codebook/subset_variabelen.md
```

Tijdens de opdracht laat je Codex de ontbrekende mappen en bestanden maken, zoals `R/`, `stata/`, `data/` en `output/`.

## Voorbereiding

Je hebt nodig:

- Codex of een vergelijkbare code-agent;
- R met `Rscript` op je PATH;
- Stata voor de lokale Stata-validatie;
- een editor of terminal vanuit de hoofdmap van dit repository.

Er worden geen echte onderzoeksdata gebruikt. De data worden synthetisch gegenereerd door R.

## Starten

1. Open dit repository in Codex.
2. Lees `analyseopdracht.md`.
3. Begin bij de eerste prompt en werk de stappen op volgorde door.
4. Laat Codex R uitvoeren met `Rscript R/run_all.R`.
5. Draai de Stata-do-files daarna zelf lokaal:

```stata
do stata/analyse.do
do stata/controles.do
```

## Belangrijk

De synthetische resultaten zijn geen inhoudelijke bevindingen. De opdracht gaat over workflow: specificeren, testen, uitvoeren, controleren en eerlijk rapporteren wat wel en niet is gevalideerd.
