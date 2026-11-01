# Passaggio di consegne tra sessioni

*Si aggiorna a ogni passaggio importante. Lo storico è in [`diario-automatico.md`](diario-automatico.md).*

**Aggiornato:** 2026-11-02, step 35 chiuso (release v0.50.0 in `main`): navi da guerra e traversate. Fase 7 «Le guerre di Annibale» in corso (step 30–35 fatti). Prossimo: step 36, assedi (ariete e onagro), poi 37 Cartaginesi con elefanti, 38 mappa del Bruzio, 39 campagna di Annibale, 40 grafica di guerra. Ogni step: worktree in C:/Users/User/Projects/tdc-wt/step-NN-nome, modelli con un subagente, test nuovo, tutti i test a gruppi (sotto i 10 minuti l'uno), versione +0.01, documenti (roadmap, «Avanzamento» in fondo a piano-imperivm.md, DEVELOPMENT_STATUS, CLAUDE.md, diario), merge e push.

## Ultimo obiettivo affrontato

**Step 29 — epilogo «L'ultimo canto»**, fatto e unito a `main`. Note in `docs/ultimo_canto.md`.
- `src/storia/missione.gd`: `CAMPAGNA_FINALE`, missione `ultimo_canto` (con `"costa": true`), finali con la rivelazione di Rocco.
- `src/mappa/generatore_mappa.gd`: `_spiana(d, centro, raggio, riva)` e `_vertice_sul_mare()`; approdo a Vibo Marina.
- Catalogo: porto con `vicino_mare` 5; `Lavoratore` cerca l'acqua entro 7 caselle.
- `tools/test/test_campagna.gd`: il bot riprova a piazzare gli edifici (`_falliti`). Test `tools/test/test_finale.gd`. Tutti i 30 test OK.

## Stato generale

Fasi 1, 2, 3, 4 (tranne l'esportazione iPhone) e 6 fatte. Sette popoli giocabili, tre mappe (Costa ionica, Monteleone, Zancle), quattro campagne (Greci, Soglia, Sicilia, epilogo).

## Prossimo

1. Scrivere in `domande-per-il-proprietario.md` le domande per la **Fase 5** (idee da Coral Island: cosa piace, cosa prendere).
2. **Rifinitura grafica G6**: fatta (G6a–G6f): ogni popolo ha tutti gli edifici nel suo stile; `tools/test/test_aspetto.gd` lo controlla.
3. Sfide: fatte (`docs/sfide.md`). Poi: bilanciamento (vedi `DEVELOPMENT_STATUS.md`).

## Problemi irrisolti

- Musica ancora segnaposto (domanda aperta).
- Chi è Rocco della Lira (domanda aperta; provvisorio: Italo).
- iPhone: serve un Mac (domanda aperta).
- Esito delle GitHub Actions non verificabile da qui (`gh` assente).
