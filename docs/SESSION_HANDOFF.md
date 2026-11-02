# Passaggio di consegne tra sessioni

*Si aggiorna a ogni passaggio importante. Lo storico è in [`diario-automatico.md`](diario-automatico.md).*

**Aggiornato:** 2026-11-02, step 40 chiuso (release v0.57.0 in `main`): grafica di guerra; **Fase 7 finita**. Prima gli step 36a (costruttori al cantiere) e 36b (voce di re Italo), chiesti dal proprietario. Prossimo: musica nuova (anche di guerra) e chiusura con la versione 1.0. Ogni step: worktree in C:/Users/User/Projects/tdc-wt/step-NN-nome, modelli con un subagente, test nuovo, tutti i test a gruppi (sotto i 10 minuti l'uno), versione +0.01, documenti (roadmap, «Avanzamento» in fondo a piano-imperivm.md, DEVELOPMENT_STATUS, CLAUDE.md, diario), merge e push. Il proprietario: «continua, non ti fermare; se hai dubbi vai avanti con altro».

## Ultimo obiettivo affrontato

**Step 40 — grafica di guerra** (v0.57.0): modelli dei villaggi indigeni (`VillaggiIndigeni.sprite_di()`), macerie delle mura crollate (`Edificio._disegna_mura`); test `test_grafica_guerra`. GitHub: workflow in un solo job su Windows senza artifact; l'esito si legge dal ramo `ci-esito`.

## Stato generale

Fasi 1, 2, 3, 4 (tranne l'iPhone, rimandato) e 6 fatte; Fase 7 finita (step 30–40, 36a e 36b). Otto popoli giocabili, quattro mappe, cinque campagne. Sette popoli giocabili, tre mappe (Costa ionica, Monteleone, Zancle), quattro campagne (Greci, Soglia, Sicilia, epilogo), sfide.

## Prossimo

1. **Musica nuova**: in attesa del permesso per scaricare FluidSynth e il soundfont.
2. Poi poi la musica nuova (con una musica di guerra), poi la chiusura (versione 1.0).

## Problemi irrisolti

- Musica ancora segnaposto (deciso come rifarla, da fare); manca la musica di guerra.
- Esito delle GitHub Actions non verificabile da qui (`gh` assente).
