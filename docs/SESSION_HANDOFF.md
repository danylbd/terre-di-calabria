# Passaggio di consegne tra sessioni

*Si aggiorna a ogni passaggio importante. Lo storico è in [`diario-automatico.md`](diario-automatico.md).*

**Aggiornato:** 2026-11-02, step 36 chiuso (release v0.53.0 in `main`): assedi con ariete e onagro. Prima gli step 36a (costruttori al cantiere) e 36b (voce di re Italo), chiesti dal proprietario. Prossimo: step 37 Cartaginesi con elefanti, poi 38 mappa del Bruzio, 39 campagna di Annibale, 40 grafica di guerra, poi musica nuova (anche di guerra) e chiusura con la versione 1.0. Ogni step: worktree in C:/Users/User/Projects/tdc-wt/step-NN-nome, modelli con un subagente, test nuovo, tutti i test a gruppi (sotto i 10 minuti l'uno), versione +0.01, documenti (roadmap, «Avanzamento» in fondo a piano-imperivm.md, DEVELOPMENT_STATUS, CLAUDE.md, diario), merge e push. Il proprietario: «continua, non ti fermare; se hai dubbi vai avanti con altro».

## Ultimo obiettivo affrontato

**Step 36 — assedi** (v0.53.0): mura delle torri nemiche (`Edificio.mura`, `Schiere._rinforza_mura`, `_colpisci_mura`), macchine dell'armaiolo (`Schiere.MACCHINE`, `costruisci_macchina`, `_onagro`, `_avanza_massi`), pulsanti in `pannello_edificio.gd`; test `test_assedi`.

## Stato generale

Fasi 1, 2, 3, 4 (tranne l'iPhone, rimandato) e 6 fatte; Fase 7 step 30–36, 36a e 36b fatti. Sette popoli giocabili, tre mappe (Costa ionica, Monteleone, Zancle), quattro campagne (Greci, Soglia, Sicilia, epilogo), sfide.

## Prossimo

1. **Step 37 — i Cartaginesi** con gli elefanti: vedi `DEVELOPMENT_STATUS.md`.
2. Step 38–40, poi la musica nuova (con una musica di guerra), poi la chiusura (versione 1.0).

## Problemi irrisolti

- Musica ancora segnaposto (deciso come rifarla, da fare); manca la musica di guerra.
- Esito delle GitHub Actions non verificabile da qui (`gh` assente).
