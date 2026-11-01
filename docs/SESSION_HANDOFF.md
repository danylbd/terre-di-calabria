# Passaggio di consegne tra sessioni

*Si aggiorna a ogni passaggio importante. Lo storico è in [`diario-automatico.md`](diario-automatico.md).*

**Aggiornato:** 2026-11-02, step 21 chiuso (release v0.26.0 in `main`).

## Ultimo obiettivo affrontato

**Step 21 — Saraceni giocabili** (Fase 4), fatto e unito a `main`. Piano in `docs/saraceni.md`.
- `Popoli.DATI["saraceni"]` (nemici romani, `cavaliere_leggero`, `"irriga": true`), `Popoli.irriga()`, `IRRIGAZIONE`, `RAGGIO_IRRIGAZIONE`.
- `RisorseNaturali.semina()` segna il campo `"irrigato"`; la crescita dei campi lo usa; `_acqua_entro()`.
- Catalogo: `bachicoltura` (→ bozzoli) e `filanda` (bozzoli → seta), merce `seta` in `LUSSO`.
- Modelli nella sezione SARACENI di `tools/studio/modelli.gd`. Test `tools/test/test_saraceni.gd`. Tutti i 22 test OK.

## Prossimo: step 22 — Normanni

Stesso schema (piano in `docs/normanni.md`). Da `design.md`: allevamento dei cavalli, edificio unico Mastio, cavaliere pesante, torri e castelli che espandono il territorio più lontano; aspetto in `grafica.md` (torri squadrate). Nemici: i Saraceni.

## Problemi irrisolti

- Musica ancora segnaposto (domanda aperta al proprietario).
- Esito delle GitHub Actions non verificabile da qui (`gh` assente).
- Frombolieri dei Brettii giocabili ancora con i colori rossi da nemici.

## Da dove riprendere

Aprire il ramo `step-22-normanni` in un worktree e scrivere `docs/normanni.md`.
