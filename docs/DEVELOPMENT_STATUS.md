# Stato dello sviluppo

*Aggiornato il 2026-11-01. Fonte del piano completo: [`roadmap.md`](roadmap.md). Registro cronologico dettagliato: [`diario-automatico.md`](diario-automatico.md).*

## Completato (in `main`)

Ultima release: **v0.27.0** (step 22). Tutti i test automatici passano (23 script in `tools/test/`).

| Fase | Step | Contenuto |
|---|---|---|
| 1 — Il villaggio vive | 00, G1, 01–05, M1, G2, 06–11 | fondamenta e installer, studio grafico, mappa, costruzione, strade, trasporto, prima catena, audio (musica segnaposto), grafica livello 2, cibo (campi, allevamenti, pesca), metallo e attrezzi, popolazione e pannelli, salvataggio, stagioni, Greci completi (36 edifici, agorà) |
| 2 — Guerra e avversario | 12–15 | territorio per proprietario, torri e castello presidiati, soldati e conquista, i Brettii controllati dal computer, scelta della modalità (pace / pace poi guerra / guerra) |
| 3 — La storia | 16–18 | tutorial «Il naufragio», campagna dei Greci (6 missioni, sblocco progressivo), mappa della Calabria con la forma reale |
| 4 — Gli altri popoli | 19–22 | Brettii, Romani, Saraceni e Normanni giocabili nella partita libera (`src/core/popoli.gd`; Brettii: pecificio e pece; Romani: laterizi e tegole, legionari, portatori +15%; Saraceni: seta, cavalieri leggeri, campi irrigati ×1,5; Normanni: cavalli e mastio, cavalieri pesanti, confini +2) |
| Vibo Valentia | V1–V3 | mappa di gioco «Monteleone» (96×96) con la costa vera da Pizzo a Nicotera, scelta nel menu e dalla mappa della Calabria; 11 monumenti sbloccati in ordine a traguardi, posati al loro posto, con vantaggi; partite senza fine verificate (2 ore di gioco stabili) |

Ultime modifiche significative (step 22): Normanni in `Popoli.DATI` (contro i Saraceni, cavalieri pesanti, `"confini": 2` usato da `Villaggio._ricalcola_territorio()`), `allevamento_cavalli` (grano e acqua → cavalli) e `mastio` (costa 2 cavalli, raggio 13, 10 soldati); le guardie dei forti hanno l'aspetto del soldato del proprio popolo (`Lavoratore`); 20 modelli nuovi; test `test_normanni`.

## In sviluppo

- **Step 23 — campagna finale «La Soglia»** (Fase 4): da progettare.

## Da fare (in ordine)

1. **Fase 4**: campagna finale «La Soglia» (i cinque popoli giocabili sono fatti), poi versione iPhone, campagna finale «La Soglia», versione iPhone.
2. **Fase 6**: la Sicilia (mappa reale, Siculi e Sicani, campagna «Il fuoco sotto la montagna», navi sullo Stretto).
3. **Fase 5** (Coral Island): solo dopo le domande al proprietario.

## Bug e limiti noti

- **Musica segnaposto** (sintetizzata): la domanda su come fare la musica vera è aperta in [`domande-per-il-proprietario.md`](domande-per-il-proprietario.md).
- **Compilazioni su GitHub non verificate da qui**: `gh` non è installato; i push partono, l'esito delle Actions va guardato su GitHub.
- Animali degli allevamenti fermi nel modello (non si muovono).
- Le rocce sono finite e i boschi naturali non ricrescono da soli: per giocare ore servono guardaboschi accanto ai boscaioli e cave nuove quando le rocce finiscono (voluto, come in Settlers).
- La costa è lontana dal villaggio iniziale: per pescatore e barca servono 1–2 torri verso il mare.
- Le materie prime grezze (olive, tronchi…) non hanno tetto di scorta: solo pozzo e trasformatori si fermano.
- Con una sola strada verso il magazzino si formano code (normale: il giocatore aggiunge strade).
- Sulla mappa di Monteleone i Brettii mettono entrambi gli avamposti sul Poro (le Serre sono troppo ripide e boscose).
- Normanni giocabili: 15 edifici con l'aspetto normanno, gli altri greco.
- Saraceni giocabili: 15 edifici con l'aspetto saraceno, gli altri greco; la noria non c'è ancora (scelta provvisoria).
- Romani giocabili: 15 edifici con l'aspetto romano, gli altri greco; il cantiere stradale non c'è ancora (scelta provvisoria).
- I Brettii giocabili: 16 edifici hanno l'aspetto brettio, gli altri (miniere, zecca, fonderia, vigneto…) per ora quello greco; i frombolieri hanno ancora i colori rossi di quando erano solo nemici; la campagna resta dei Greci.
- Gli altri popoli hanno solo torri (non un villaggio completo): arriverà con la Fase 4.

## Prossima attività consigliata

Progettare lo **step 23 — campagna finale «La Soglia»**: rileggere `docs/storia.md` (il Sigillo, i cinque frammenti, il Mercante, la Soglia) e scrivere il piano delle missioni in `docs/`. Le missioni usano `Missione.MISSIONI` (obiettivi generici) e la mappa della Calabria; serve probabilmente poter giocare una missione con un popolo diverso dai Greci (`Impostazioni.popolo` oggi è forzato ai Greci per la campagna).
