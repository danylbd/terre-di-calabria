# Passaggio di consegne tra sessioni

*Si aggiorna a ogni passaggio importante. Lo storico è in [`diario-automatico.md`](diario-automatico.md).*

**Aggiornato:** 2026-11-01, step V2 chiuso (release v0.22.0 in `main`).

## Ultimo obiettivo affrontato

**Step V2 — monumenti di Monteleone**: fatto e unito a `main`.
- `src/storia/monumenti.gd`: `CATALOGO` (id = nome dello sprite, casella, traguardo, vantaggio, effetto), `traguardo_raggiunto()`, `sblocca(id, in_silenzio, posto)`, `_doni()` a ogni cambio di stagione, `posti`, `prodotti` (ducati e pesce spada di tutta la partita), `tempo_senza_perdite`.
- `Villaggio.vantaggi`: "confini" (+raggio), "nascita" e "lavoro" (moltiplicano i tempi), "duelli" (+probabilità in `Guerra._fine_duello`). Segnali nuovi `Logistica.prodotta(tipo)` e `Guerra.forte_perso`.
- Salvataggio: chiave `"monumenti"` (ottenuti con la casella, prodotti, senza_perdite). Pannello del villaggio: elenco dei monumenti e prossimo traguardo.
- 11 modelli 3D in `tools/studio/modelli.gd` (mura_greche, tempio_proserpina, porto_santa_venere, foro_valentia, castello_normanno, duomo, chiesa_rosario, valentianum, tonnara_bivona, castello_pizzo, santa_maria_isola).
- Test `tools/test/test_monumenti.gd`. Tutti i 18 test OK.

## Prossimo: step V3 — partite senza fine

Verificare che si possa giocare per ore: test lungo accelerato su Monteleone (molti edifici, molte merci) che misuri nodi, merci in viaggio, tempo per fotogramma e memoria; correggere quello che cresce senza limite (per esempio `logistica.storia`, sprite di decori, colonni in cammino). Controllare che dopo l'ultima missione della campagna e dopo l'ultimo monumento la partita continui (niente schermata di fine obbligata).

## Problemi irrisolti

- Musica ancora segnaposto (domanda aperta al proprietario).
- Esito delle GitHub Actions non verificabile da qui (`gh` assente).

## Da dove riprendere

Aprire il ramo `step-v3-senza-fine` in un worktree e scrivere il test di durata.
