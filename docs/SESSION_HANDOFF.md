# Passaggio di consegne tra sessioni

*Si aggiorna a ogni passaggio importante. Lo storico è in [`diario-automatico.md`](diario-automatico.md).*

**Aggiornato:** 2026-11-02, step 35 chiuso (release v0.50.0 in `main`): navi da guerra e traversate. Fase 7 «Le guerre di Annibale» in corso (step 30–35 fatti). Prossimo: step 36, assedi (ariete e onagro), poi 37 Cartaginesi con elefanti, 38 mappa del Bruzio, 39 campagna di Annibale, 40 grafica di guerra. Ogni step: worktree in C:/Users/User/Projects/tdc-wt/step-NN-nome, modelli con un subagente, test nuovo, tutti i test a gruppi (sotto i 10 minuti l'uno), versione +0.01, documenti (roadmap, «Avanzamento» in fondo a piano-imperivm.md, DEVELOPMENT_STATUS, CLAUDE.md, diario), merge e push.

## Ultimo obiettivo affrontato

**Step 36a — costruttori al cantiere** (v0.51.0), chiesto dal proprietario: `src/mappa/costruttore.gd`, `Villaggio._manda_costruttore()`, `Edificio.costruttore_al_lavoro()`; test `test_costruttori`. Suoni di lavoro più vicini (`Audio.DISTANZA_MAX` 1000). Prima: Fase 5 rimandata in `idee-future.md`.

## Stato generale

Fasi 1, 2, 3, 4 (tranne l'iPhone, rimandato) e 6 fatte; Fase 7 step 30–35 e 36a fatti. Sette popoli giocabili, tre mappe (Costa ionica, Monteleone, Zancle), quattro campagne (Greci, Soglia, Sicilia, epilogo), sfide.

## Prossimo

1. **Step 36 — assedi** (ariete e onagro, mura dei castelli nemici): vedi `DEVELOPMENT_STATUS.md`.
2. Step 37–40, poi la musica nuova, poi la chiusura (versione 1.0).

## Problemi irrisolti

- Musica ancora segnaposto (deciso come rifarla, da fare); manca la musica di guerra.
- Voce di re Italo libera da diritti: vedi `domande-per-il-proprietario.md`.
- Esito delle GitHub Actions non verificabile da qui (`gh` assente).
