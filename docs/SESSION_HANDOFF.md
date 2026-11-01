# Passaggio di consegne tra sessioni

*Si aggiorna a ogni passaggio importante. Lo storico è in [`diario-automatico.md`](diario-automatico.md).*

**Aggiornato:** 2026-11-01, step V3 chiuso (release v0.23.0 in `main`). Le richieste del proprietario su Monteleone (mappa, monumenti, ducati, partite senza limite) sono tutte fatte.

## Ultimi step

- **V1** mappa di Monteleone (`GeneratoreMappa.genera_monteleone`, `Impostazioni.mappa`, `Salvataggio.mappa_di`).
- **V2** monumenti (`src/storia/monumenti.gd`, `Villaggio.vantaggi`, segnali `Logistica.prodotta` e `Guerra.forte_perso`, 11 modelli 3D).
- **V3** partite senza fine: `tools/test/test_durata.gd` (2 ore di gioco stabili). Nessun cambio al codice del gioco.

## Prossimo: Fase 4, step 19 — Brettii giocabili

Da progettare: villaggio dei Brettii (edifici con aspetto proprio, economia simile ai Greci con differenze), scelta del popolo nella partita libera, colori e confini, modelli 3D (subagente). Leggere prima le parti di `docs/design.md` e `docs/storia.md` sui Brettii; scrivere il piano in `docs/` prima del codice.

## Problemi irrisolti

- Musica ancora segnaposto (domanda aperta al proprietario).
- Esito delle GitHub Actions non verificabile da qui (`gh` assente).
- Sulla mappa di Monteleone i Brettii mettono entrambi gli avamposti sul Poro.

## Da dove riprendere

Aprire il ramo `step-19-brettii` in un worktree e cominciare dal piano.
