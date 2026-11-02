# Passaggio di consegne tra sessioni

*Si aggiorna a ogni passaggio importante. Lo storico è in [`diario-automatico.md`](diario-automatico.md).*

**Aggiornato:** 2026-11-02, musica nuova (release v0.58.0 in `main`): quattro brani originali con FluidSynth e GeneralUser GS, la musica di guerra in battaglia. Fase 7 finita. Prima gli step 36a (costruttori al cantiere) e 36b (voce di re Italo), chiesti dal proprietario. Prossimo: chiusura con la versione 1.0. Ogni step: worktree in C:/Users/User/Projects/tdc-wt/step-NN-nome, modelli con un subagente, test nuovo, tutti i test a gruppi (sotto i 10 minuti l'uno), versione +0.01, documenti (roadmap, «Avanzamento» in fondo a piano-imperivm.md, DEVELOPMENT_STATUS, CLAUDE.md, diario), merge e push. Il proprietario: «continua, non ti fermare; se hai dubbi vai avanti con altro».

## Ultimo obiettivo affrontato

**Musica nuova** (v0.58.0): `tools/suoni/musica_fluid.py` scrive i brani come MIDI e li fa suonare a FluidSynth con GeneralUser GS (programmi in `C:\Users\User\Tools`, variabili `FLUIDSYNTH` e `SOUNDFONT`); `assets/musica/{mattino,lavoro,sera,guerra}.ogg` (i vecchi WAV segnaposto tolti); `Guerra.in_battaglia()`, `Partita._aggiorna_musica()` (musica di guerra in battaglia, poi 25 s di calma); test `test_musica`.

## Stato generale

Fasi 1, 2, 3, 4 (tranne l'iPhone, rimandato) e 6 fatte; Fase 7 finita (step 30–40, 36a e 36b). Otto popoli giocabili, quattro mappe, cinque campagne. Sette popoli giocabili, tre mappe (Costa ionica, Monteleone, Zancle), quattro campagne (Greci, Soglia, Sicilia, epilogo), sfide.

## Prossimo

1. **Chiusura — versione 1.0**: vedi `DEVELOPMENT_STATUS.md`.
2. Dopo poi la musica nuova (con una musica di guerra), poi la chiusura (versione 1.0).

## Problemi irrisolti

- Esito delle GitHub Actions non verificabile da qui (`gh` assente).
