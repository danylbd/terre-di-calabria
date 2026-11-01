# Passaggio di consegne tra sessioni

*Si aggiorna a ogni passaggio importante. Lo storico è in [`diario-automatico.md`](diario-automatico.md).*

**Aggiornato:** 2026-11-01, step V1 chiuso (release v0.21.0 in `main`).

## Ultimo obiettivo affrontato

**Step V1 — mappa di Monteleone**: fatto e unito a `main`.
- `src/mappa/generatore_mappa.gd`: `MAPPE`, `crea(mappa, seme)`, `genera_monteleone()` con `COSTA_MONTELEONE`, `LUOGHI_MONTELEONE`, `COLLI_MONTELEONE`, lago; `_radura()` e `_mare_piatto()` in comune.
- `src/mappa/dati_mappa.gd`: `luoghi` (nome → casella). `src/mappa/partita.gd`: `mappa`, `_mappa_da_usare()`, `_metti_nomi_luoghi()`, direzioni dei Brettii per mappa.
- `src/core/impostazioni.gd`: `mappa`. `src/core/salvataggio.gd`: chiave `"mappa"`, `mappa_di()`.
- `src/main/title_screen.gd`: scelta della mappa in «Nuova partita». `src/main/mappa_calabria.gd`: pulsante «Gioca a Monteleone».
- Test nuovo `tools/test/test_monteleone.gd` (estende test_catena). Tutti i 17 test OK.

## Prossimo: step V2 — monumenti di Monteleone

Tabella degli 11 monumenti, traguardi e vantaggi in `docs/monteleone.md`; caselle dei luoghi in `GeneratoreMappa.LUOGHI_MONTELEONE`. Idea: un catalogo dei monumenti (traguardo → monumento, casella, vantaggio), un controllo dei traguardi nella partita su Monteleone, posa dell'edificio-monumento (modello 3D nuovo per ognuno in `tools/studio/modelli.gd`, rendering con lo studio e poi `--import`), salvataggio dei monumenti ottenuti, avviso e pannello «Monumenti».

## Problemi irrisolti

- Musica ancora segnaposto (domanda aperta al proprietario).
- Esito delle GitHub Actions non verificabile da qui (`gh` assente).

## Da dove riprendere

Aprire il ramo `step-v2-monumenti` in un worktree e cominciare dal catalogo dei monumenti.
