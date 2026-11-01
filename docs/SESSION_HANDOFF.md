# Passaggio di consegne tra sessioni

*Si aggiorna a ogni passaggio importante. Lo storico è in [`diario-automatico.md`](diario-automatico.md).*

**Aggiornato:** 2026-11-02, step 28 chiuso (release v0.33.0 in `main`).

## Ultimo obiettivo affrontato

**Step 28 — lo Stretto: navi e porti** (Fase 6), fatto e unito a `main`. Note in `docs/stretto.md`.
- `src/mappa/lavoratore.gd`: stato `NAVIGA`, `_salpa()`, `rotta_nave()`, `_rotta_sul_mare()`, `_meta_al_largo()`, `_acqua_vicina()`, `_rotta_libera()`; foglio `nave` sull'acqua per il porto.
- Catalogo: `porto` (anfore → ducati, vicino al mare). Modelli `porto` e `nave` in `tools/studio/modelli.gd`.
- Test `tools/test/test_stretto.gd`. Tutti i 29 test OK.

## Prossimo: step 29 — finale nuovo

Il Mercante senza Volto e l'ultimo segreto del Sigillo. Dipende in parte dalla domanda aperta «chi è Rocco della Lira».

## Problemi irrisolti

- Musica ancora segnaposto (domanda aperta).
- Chi è Rocco della Lira (domanda aperta).
- iPhone: serve un Mac (domanda aperta).
- Esito delle GitHub Actions non verificabile da qui (`gh` assente).
- Frombolieri dei Brettii giocabili ancora con i colori rossi da nemici.

## Da dove riprendere

Aprire il ramo `step-29-finale` e scrivere il piano dell'epilogo.
