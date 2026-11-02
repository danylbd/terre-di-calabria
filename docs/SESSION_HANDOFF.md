# Passaggio di consegne tra sessioni

*Si aggiorna a ogni passaggio importante. Lo storico è in [`diario-automatico.md`](diario-automatico.md).*

**Aggiornato:** 2026-11-02, step 37 chiuso (release v0.54.0 in `main`): i Cartaginesi, ottavo popolo, con gli elefanti. Prima gli step 36a (costruttori al cantiere) e 36b (voce di re Italo), chiesti dal proprietario. Prossimo: step 38 mappa del Bruzio, 39 campagna di Annibale, 40 grafica di guerra, poi musica nuova (anche di guerra) e chiusura con la versione 1.0. Ogni step: worktree in C:/Users/User/Projects/tdc-wt/step-NN-nome, modelli con un subagente, test nuovo, tutti i test a gruppi (sotto i 10 minuti l'uno), versione +0.01, documenti (roadmap, «Avanzamento» in fondo a piano-imperivm.md, DEVELOPMENT_STATUS, CLAUDE.md, diario), merge e push. Il proprietario: «continua, non ti fermare; se hai dubbi vai avanti con altro».

## Ultimo obiettivo affrontato

**Step 37 — i Cartaginesi** (v0.54.0): `Popoli.DATI["cartaginesi"]`, `tintoria_porpora`, `stalla_elefanti`, elefante da guerra in `Schiere.MACCHINE`; modelli in `tools/studio/modelli_cartaginesi_*.gd` (lo studio unisce `catalogo_extra()` di ogni `modelli_*.gd`); test `test_cartaginesi`.

## Stato generale

Fasi 1, 2, 3, 4 (tranne l'iPhone, rimandato) e 6 fatte; Fase 7 step 30–37, 36a e 36b fatti. Otto popoli giocabili. Sette popoli giocabili, tre mappe (Costa ionica, Monteleone, Zancle), quattro campagne (Greci, Soglia, Sicilia, epilogo), sfide.

## Prossimo

1. **Step 38 — mappa «Il Bruzio di Annibale»**: vedi `DEVELOPMENT_STATUS.md`.
2. Step 39–40, poi la musica nuova (con una musica di guerra), poi la chiusura (versione 1.0).

## Problemi irrisolti

- Musica ancora segnaposto (deciso come rifarla, da fare); manca la musica di guerra.
- Esito delle GitHub Actions non verificabile da qui (`gh` assente).
