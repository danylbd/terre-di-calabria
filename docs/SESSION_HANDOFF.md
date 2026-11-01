# Passaggio di consegne tra sessioni

*Si aggiorna a ogni passaggio importante. Lo storico è in [`diario-automatico.md`](diario-automatico.md).*

**Aggiornato:** 2026-11-02, step 25 chiuso (release v0.30.0 in `main`).

## Ultimo obiettivo affrontato

**Step 25 — mappa «Zancle e l'Etna»** (Fase 6), fatto e unito a `main`.
- `src/mappa/generatore_mappa.gd`: `COSTA_SICILIA`, `COSTA_CALABRIA`, `LUOGHI_ZANCLE`, `ETNA`, `genera_zancle()`, `_distanza_segmento()`; `_distanza_costa(p, coste, terre)` generale; `crea()` con `match`.
- `partita.gd`: direzioni dei nemici per la mappa `zancle`. `mappa_calabria.gd`: pulsante «Gioca a Zancle».
- Test `tools/test/test_zancle.gd`. Tutti i 26 test OK.

## Prossimo: step 26 — Siculi e Sicani

Due popoli nuovi (piano da scrivere in `docs/siculi_sicani.md`), stesso schema dei popoli calabresi. Idee: Siculi vasai e pastori (edificio unico: la bottega del vasaio di Pantalica; merce: ceramiche), Sicani della montagna (edificio unico: la cava di ossidiana/pomice? oppure sale di roccia); soldati e modelli con un subagente.

## Problemi irrisolti

- Musica ancora segnaposto (domanda aperta).
- Chi è Rocco della Lira (domanda aperta).
- iPhone: serve un Mac (domanda aperta).
- Esito delle GitHub Actions non verificabile da qui (`gh` assente).
- Frombolieri dei Brettii giocabili ancora con i colori rossi da nemici.

## Da dove riprendere

Aprire il ramo `step-26-siculi-sicani` e scrivere il piano.
