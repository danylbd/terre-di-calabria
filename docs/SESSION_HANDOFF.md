# Passaggio di consegne tra sessioni

*Si aggiorna a ogni passaggio importante. Lo storico è in [`diario-automatico.md`](diario-automatico.md).*

**Aggiornato:** 2026-11-02, step 27 chiuso (release v0.32.0 in `main`).

## Ultimo obiettivo affrontato

**Step 27 — campagna «Il fuoco sotto la montagna»** (Fase 6), fatto e unito a `main`. Piano in `docs/fuoco.md`.
- `src/storia/missione.gd`: `CAMPAGNA_FUOCO`, `CAMPAGNE`, `prossima(campagna)`, `sbloccata()` generale, evento `lava`; sei missioni nuove.
- `src/main/mappa_calabria.gd`: pulsante «Il fuoco sotto la montagna» (`_fuoco`, `FUOCO`).
- `tools/test/test_campagna.gd` (bot): obiettivo `strada`, più edifici dello stesso tipo. Test nuovo `tools/test/test_fuoco.gd`. Tutti i 28 test OK.

## Prossimo: step 28 — lo Stretto: navi, porti e traversate

Piano da scrivere in `docs/stretto.md`: edificio porto, nave tra due porti che porta merci attraverso il mare; partire da `barca_remi` e dalla barca del pesce spada (`Lavoratore`, `RisorseNaturali.posto_al_largo`).

## Problemi irrisolti

- Musica ancora segnaposto (domanda aperta).
- Chi è Rocco della Lira (domanda aperta).
- iPhone: serve un Mac (domanda aperta).
- Esito delle GitHub Actions non verificabile da qui (`gh` assente).
- Frombolieri dei Brettii giocabili ancora con i colori rossi da nemici.

## Da dove riprendere

Aprire il ramo `step-28-stretto` e studiare come la barca del pesce spada va al largo.
