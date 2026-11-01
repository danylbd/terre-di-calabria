# Passaggio di consegne tra sessioni

*Si aggiorna a ogni passaggio importante. Lo storico è in [`diario-automatico.md`](diario-automatico.md).*

**Aggiornato:** 2026-11-02, Eolie sulla mappa della campagna (release v0.43.0 in `main`). Tutto quello che non dipende dal proprietario è fatto; restano piccole rifiniture (colori dei frombolieri) e le domande aperte (Fase 5, musica, iPhone, Rocco).

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
- Frombolieri dei Brettii giocabili ancora con i colori rossi da nemici.
