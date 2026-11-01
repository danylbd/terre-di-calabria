# Passaggio di consegne tra sessioni

*Si aggiorna a ogni passaggio importante. Lo storico è in [`diario-automatico.md`](diario-automatico.md).*

**Aggiornato:** 2026-11-02, step 22 chiuso (release v0.27.0 in `main`). Tutti e cinque i popoli sono giocabili nella partita libera.

## Ultimo obiettivo affrontato

**Step 22 — Normanni giocabili** (Fase 4), fatto e unito a `main`. Piano in `docs/normanni.md`.
- `Popoli.DATI["normanni"]` (nemici saraceni, `cavaliere_pesante`, `"confini": 2`), `Popoli.confini()` in `Villaggio._ricalcola_territorio()`.
- Catalogo: `allevamento_cavalli`, `mastio` (costa cavalli), merce `cavalli`. `Lavoratore`: la guardia prende il soldato del proprio popolo.
- Modelli nella sezione NORMANNI di `tools/studio/modelli.gd`. Test `tools/test/test_normanni.gd`. Tutti i 23 test OK.
- Coppie di nemici: Greci ↔ Brettii, Romani → Brettii, Saraceni → Romani, Normanni → Saraceni.

## Prossimo: step 23 — campagna finale «La Soglia»

Da progettare in `docs/` (piano delle missioni) partendo da `docs/storia.md`. Probabilmente servirà che una missione possa scegliere il popolo del giocatore (`"popolo"` nei dati della missione, usato da `partita._popolo_da_usare()`).

## Problemi irrisolti

- Musica ancora segnaposto (domanda aperta al proprietario).
- Esito delle GitHub Actions non verificabile da qui (`gh` assente).
- Frombolieri dei Brettii giocabili ancora con i colori rossi da nemici.
- Step 24 (versione iPhone) richiede un Mac con Xcode: da chiedere al proprietario quando ci si arriva.

## Da dove riprendere

Leggere in `docs/storia.md` la parte sulla Soglia e sul Sigillo e scrivere il piano dello step 23.
