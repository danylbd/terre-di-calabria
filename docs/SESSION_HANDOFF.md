# Passaggio di consegne tra sessioni

*Si aggiorna a ogni passaggio importante. Lo storico è in [`diario-automatico.md`](diario-automatico.md).*

**Aggiornato:** 2026-11-02, step 24 (prima parte: comandi touch) unito a `main`, release v0.29.0.

## Ultimo obiettivo affrontato

**Step 24 — iPhone, prima parte**: comandi touch.
- `src/mappa/camera_mappa.gd`: `_tocco()` (un dito trascina, due dita zoom), `tocco_mosso`, `tocco_lungo_fatto`, segnale `tocco_lungo`.
- `src/mappa/partita.gd`: clic da dito (`InputEvent.DEVICE_ID_EMULATION`) al rilascio; `_annulla()`; i clic usano `mb.position`.
- Test `tools/test/test_touch.gd`. Tutti i 25 test OK.
- L'esportazione iOS aspetta la risposta del proprietario (serve un Mac): domanda del 2026-11-02.

## Prossimo: Fase 6 — la Sicilia (step 25)

Leggere le righe della Fase 6 in `docs/roadmap.md` e il seguito «Il fuoco sotto la montagna» in `docs/storia.md`; scrivere il piano dello step 25.

## Problemi irrisolti

- Musica ancora segnaposto (domanda aperta).
- Chi è Rocco della Lira (domanda aperta).
- iPhone: serve un Mac (domanda aperta).
- Esito delle GitHub Actions non verificabile da qui (`gh` assente).
- Frombolieri dei Brettii giocabili ancora con i colori rossi da nemici.

## Da dove riprendere

Aprire il ramo dello step 25 e scrivere il piano della Sicilia.
