# Passaggio di consegne tra sessioni

**Aggiornamento 2026-11-04 — Fase 8 implementata e verificata:** repository in `work/terre-di-calabria`, worktree `work/tdc-step-43`, branch `feature/fase-8-rifiniture`, basato su `c586388`. Versione impostata a 1.1.0. Implementati gli step 43–53 della roadmap e le richieste collegate: interfaccia e menu pausa/audio, produzione/magazzini e priorità, mercato e acquisti, pionieri, raccoglitore di porcini, mappe estese, dettagli ambientali e salvataggio compatibile. I coloni liberi sono assegnati alle abitazioni; i nuovi nati vi restano e chi viene chiamato parte dalla propria casa. Aggiunti 35 atlas vettoriali animati con otto direzioni, strumenti e merci. Importazione Godot e test di aspetto, atlas dei coloni, coloni in casa, salvataggio, stagioni, territorio, indigeni e simulazione Greci/agorà passati. La simulazione dell'agorà ha venduto olio, vino e altre merci e ha completato un acquisto di ferro. Tenere il lavoro sul ramo feature, senza modificare `main` né pubblicare release.

*Si aggiorna a ogni passaggio importante. Lo storico è in [`diario-automatico.md`](diario-automatico.md).*

**Aggiornato:** 2026-11-03, versione 1.0.0 in `main`. Il proprietario ha chiesto la **Fase 8 «Rifiniture alla Settlers»** (step 43–51 in `docs/roadmap.md`, decisioni in `docs/decisioni.md`): si fanno in ordine, una versione 1.x per step. Ogni lavoro: worktree in C:/Users/User/Projects/tdc-wt/<ramo>, test nuovo, tutti i test a gruppi, versione, documenti, merge e push; esito della compilazione dal ramo `ci-esito`.

## Ultimo obiettivo affrontato

**Chiusura — versione 1.0.0**: crediti completi nel menu (grafica, suoni, voce e musica originali; FluidSynth e GeneralUser GS; fatti storici), README della 1.0, prova completa di tutte le 28 missioni con il giocatore automatico di `test_campagna.gd` (riepilogo qui sotto).

### Prova completa (giocatore automatico, 28 missioni)

- Nessun errore di script in nessuna missione.
- Compiute dal giocatore automatico: le 6 dei Greci; soglia_velo, soglia_frammenti, soglia_scelta; fuoco_traversata, fuoco_etna; sfida_alluvione; annibale_sbarco.
- Trovato e corretto: nella mappa del Bruzio il porto di Crotone era fuori dai primi confini (prima missione di Annibale impossibile senza una torre): villaggio e approdo spostati, sperone di roccia dentro i confini.
- Non compiute per limiti del giocatore automatico (non sa fare la guerra, i doni ai villaggi, né far crescere oltre 100 coloni in 20 minuti di gioco), con gli obiettivi raggiunti fin lì: soglia_sigillo, fuoco_zancle (il secondo magazzino non trova spazio perché il giocatore automatico riempie di case le zone piane), fuoco_vasai, fuoco_eolie, fuoco_cuore, ultimo_canto, sfida_200, sfida_seta e le missioni di guerra di Annibale (2–8; il lacinio arriva al lusso, il marchesato al castello). Queste parti sono coperte dai test dedicati (test_soglia, test_fuoco, test_finale, test_sfide, test_annibale, test_schiere, test_assedi).

## Stato generale

Fasi 1, 2, 3, 4 (tranne l'iPhone, rimandato) e 6 fatte; Fase 7 finita (step 30–40, 36a e 36b). Otto popoli giocabili, quattro mappe, cinque campagne. Sette popoli giocabili, tre mappe (Costa ionica, Monteleone, Zancle), quattro campagne (Greci, Soglia, Sicilia, epilogo), sfide.

## Prossimo

1. Versione 1.0.0 fatta. Si riparte da `docs/idee-future.md` quando il proprietario lo chiede.
2. Dopo poi la musica nuova (con una musica di guerra), poi la chiusura (versione 1.0).

## Problemi irrisolti

- Esito delle GitHub Actions non verificabile da qui (`gh` assente).
