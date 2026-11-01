# Passaggio di consegne tra sessioni

*Si aggiorna a ogni passaggio importante. Lo storico è in [`diario-automatico.md`](diario-automatico.md).*

**Aggiornato:** 2026-11-02, step 20 chiuso (release v0.25.0 in `main`).

## Ultimo obiettivo affrontato

**Step 20 — Romani giocabili** (Fase 4), fatto e unito a `main`. Piano in `docs/romani.md`.
- `Popoli.DATI["romani"]` (nemici brettii, soldati legionario, `passo` 1,15), `Popoli.passo()`, `Popoli.sprite()` valido per ogni popolo.
- Catalogo: `laterizi` (popolo romani), merce `tegole` in `LUSSO`; `ReteStrade._manda_portatore` moltiplica la velocità per `Popoli.passo()`.
- Modelli in `tools/studio/modelli.gd` (sezione ROMANI): 15 edifici `<tipo>_romani`, `laterizi`, `merce_tegole`, `legionario` e `legionario_lotta`.
- Test `tools/test/test_romani.gd`. Tutti i 21 test OK.

## Prossimo: step 21 — Saraceni

Stesso schema (piano in `docs/saraceni.md`). Da `design.md`: catena della seta (gelso → bachi → filanda), edificio unico Noria, cavaliere leggero, abilità «campi irrigati più produttivi vicino ai fiumi»; aspetto in `grafica.md` (cupole e archi).

## Problemi irrisolti

- Musica ancora segnaposto (domanda aperta al proprietario).
- Esito delle GitHub Actions non verificabile da qui (`gh` assente).
- Frombolieri dei Brettii giocabili ancora con i colori rossi da nemici.

## Da dove riprendere

Aprire il ramo `step-21-saraceni` in un worktree e scrivere `docs/saraceni.md`.
