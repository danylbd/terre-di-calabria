# Passaggio di consegne tra sessioni

*Si aggiorna a ogni passaggio importante. Lo storico è in [`diario-automatico.md`](diario-automatico.md).*

**Aggiornato:** 2026-11-02, step 23 chiuso (release v0.28.0 in `main`).

## Ultimo obiettivo affrontato

**Step 23 — campagna finale «La Soglia»**, fatto e unito a `main`. Piano in `docs/soglia.md`.
- `src/storia/missione.gd`: `CAMPAGNA_SOGLIA` (soglia_velo, soglia_frammenti, soglia_scelta, soglia_sigillo), prove `lusso`, `conquiste`, `forti`, `una_tra`; progressi `popolo_soglia` e `finale`; `prossima_soglia()`, `racconto_finale()`.
- `partita._popolo_da_usare()`: missioni con `"popolo": "scelto"`. `mappa_calabria.gd`: pulsante «La Soglia» e pannello di scelta del popolo.
- Test `tools/test/test_soglia.gd`; `test_campagna` (bot) ora costruisce tutte le case che servono. Tutti i 24 test OK.

## Prossimo: step 24 — iPhone (prima parte, senza Mac)

Comandi touch e interfaccia per schermi piccoli; l'esportazione iOS aspetta la risposta del proprietario (domanda del 2026-11-02). Se lo step si blocca, Fase 6 (Sicilia).

## Problemi irrisolti

- Musica ancora segnaposto (domanda aperta al proprietario).
- Chi è Rocco della Lira (domanda aperta; nel finale ora è solo suggerito che sia Italo).
- Versione iPhone: serve un Mac (domanda aperta).
- Esito delle GitHub Actions non verificabile da qui (`gh` assente).
- Frombolieri dei Brettii giocabili ancora con i colori rossi da nemici.

## Da dove riprendere

Aprire il ramo `step-24-touch` e leggere `src/mappa/camera_mappa.gd` e `_unhandled_input` di `partita.gd` per i comandi touch.
