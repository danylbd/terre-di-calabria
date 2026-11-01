# Passaggio di consegne tra sessioni

*Si aggiorna a ogni passaggio importante. Lo storico è in [`diario-automatico.md`](diario-automatico.md).*

**Aggiornato:** 2026-11-01, step 19 chiuso (release v0.24.0 in `main`).

## Ultimo obiettivo affrontato

**Step 19 — Brettii giocabili** (Fase 4), fatto e unito a `main`. Piano e scelte in `docs/brettii.md`.
- `src/core/popoli.gd`: dati dei popoli, `Popoli.giocatore` (lo fissa `partita._popolo_da_usare()`), `sprite()`, `soldati()`, `torre_nemica()`, `testo()`.
- Catalogo: chiave `"popolo"` (agora: greci, pecificio: brettii), merce `pece` in `LUSSO`; `della_categoria(cat, popolo)`.
- `Edificio._finisci`, `Guerra` (fogli dei soldati), `Avversario`, `partita._metti_brettii`, menu, pannelli: secondo il popolo. `Colono.agile` per i portatori brettii.
- Salvataggio: `"popolo"`, `Salvataggio.popolo_di()`. Menu: «Con chi?» (`_scelta()` in title_screen.gd, riusabile).
- 16 modelli `<tipo>_brettii` + `pecificio` + `merce_pece` in `tools/studio/modelli.gd` (sezione BRETTII).
- Test `tools/test/test_brettii.gd`. Tutti i 20 test OK.

## Prossimo: step 20 — Romani

Stesso schema dei Brettii. Da decidere nel piano (`docs/romani.md`): nemici di chi gioca i Romani (oggi le coppie sono Greci ↔ Brettii: serve un nemico per popolo in `Popoli.DATI`, per esempio Romani contro Brettii), catena dei laterizi (argilla → mattoni → tegole: argillaio e fornace esistono già), cantiere stradale, legionario (modello nuovo), abilità sulle strade.

## Problemi irrisolti

- Musica ancora segnaposto (domanda aperta al proprietario).
- Esito delle GitHub Actions non verificabile da qui (`gh` assente).
- Frombolieri dei Brettii giocabili ancora con i colori rossi da nemici.

## Da dove riprendere

Aprire il ramo `step-20-romani` in un worktree e scrivere `docs/romani.md`.
