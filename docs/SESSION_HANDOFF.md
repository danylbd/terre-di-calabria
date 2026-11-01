# Passaggio di consegne tra sessioni

*Si aggiorna a ogni passaggio importante (fine di uno step, prima di una pausa o di una compattazione). Sovrascrivere questa pagina: lo storico è in [`diario-automatico.md`](diario-automatico.md).*

**Aggiornato:** 2026-11-01, dopo lo step 18 (release v0.20.0).

## Ultimo obiettivo affrontato

1. Step 18: mappa della Calabria con la forma reale (`src/main/mappa_calabria.gd`), ducati, piani per Monteleone e Sicilia. **Chiuso e unito a `main`.**
2. Richiesta del proprietario: sistema di memoria persistente del progetto. **In corso** sul ramo `memoria-progetto` (worktree `C:\Users\User\Projects\tdc-wt\memoria-progetto`).

## File modificati (ramo `memoria-progetto`)

- Nuovi: `docs/PROJECT_MEMORY.md`, `docs/DEVELOPMENT_STATUS.md`, `docs/DECISIONS.md`, `docs/SESSION_HANDOFF.md`.
- `CLAUDE.md` riordinato: istruzioni permanenti e regole di continuità; le note tecniche per step sono state spostate (complete) in `PROJECT_MEMORY.md`.
- Nessuna modifica al comportamento del gioco.

## Test

Ultima esecuzione completa (step 18, `main` 364ecd3): **16 test su 16 OK** (catena, audio, cibo, allevamenti, colture, metallo, popolazione, salvataggio, stagioni, greci, territorio, guerra, avversario, modalità, missione, campagna).

## Problemi irrisolti

- Musica ancora segnaposto (domanda aperta al proprietario).
- Esito delle GitHub Actions non verificabile da qui (`gh` assente).

## Da dove riprendere

1. Se il ramo `memoria-progetto` non è ancora unito: verificare i link dei documenti, commit, merge `--no-ff` in `main`, push.
2. Poi **step V1 — mappa di Monteleone**: creare il ramo `step-v1-monteleone` (worktree in `C:\Users\User\Projects\tdc-wt\`), leggere [`monteleone.md`](monteleone.md), scrivere la variante «monteleone» del generatore di mappa (`src/mappa/generatore_mappa.gd`), aggiungerla al menu «Nuova partita», test e screenshot.
