# Passaggio di consegne tra sessioni

*Si aggiorna a ogni passaggio importante. Lo storico è in [`diario-automatico.md`](diario-automatico.md).*

**Aggiornato:** 2026-11-02, step G6e chiuso (release v0.39.0 in `main`): Siculi con tutti gli edifici nel loro stile. Prossimo: G6f Sicani.

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
2. **Rifinitura grafica G6**, un popolo per step con un subagente (24 edifici: porcile, macelleria, apiario, caseificio, argillaio, fornace, saline, tessitura, pescatore, frantoio, uliveto, vigneto, cantina, ortolano, agrumeto, pesca_spada, miniera_ferro, miniera_argento, zecca, armaiolo, porto, carbonaia, fonderia, fabbro): Brettii fatti (G6a); prossimo G6b Romani, poi Saraceni, Normanni, Siculi, Sicani. Dopo ognuno aggiungere il popolo a `COMPLETI` in `tools/test/test_aspetto.gd`.

## Problemi irrisolti

- Musica ancora segnaposto (domanda aperta).
- Chi è Rocco della Lira (domanda aperta; provvisorio: Italo).
- iPhone: serve un Mac (domanda aperta).
- Esito delle GitHub Actions non verificabile da qui (`gh` assente).
- Frombolieri dei Brettii giocabili ancora con i colori rossi da nemici.
