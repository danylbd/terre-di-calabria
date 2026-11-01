# Stato dello sviluppo

*Aggiornato il 2026-11-01. Fonte del piano completo: [`roadmap.md`](roadmap.md). Registro cronologico dettagliato: [`diario-automatico.md`](diario-automatico.md).*

## Completato (in `main`)

Ultima release: **v0.33.0** (step 28). Tutti i test automatici passano (29 script in `tools/test/`).

| Fase | Step | Contenuto |
|---|---|---|
| 1 — Il villaggio vive | 00, G1, 01–05, M1, G2, 06–11 | fondamenta e installer, studio grafico, mappa, costruzione, strade, trasporto, prima catena, audio (musica segnaposto), grafica livello 2, cibo (campi, allevamenti, pesca), metallo e attrezzi, popolazione e pannelli, salvataggio, stagioni, Greci completi (36 edifici, agorà) |
| 2 — Guerra e avversario | 12–15 | territorio per proprietario, torri e castello presidiati, soldati e conquista, i Brettii controllati dal computer, scelta della modalità (pace / pace poi guerra / guerra) |
| 3 — La storia | 16–18 | tutorial «Il naufragio», campagna dei Greci (6 missioni, sblocco progressivo), mappa della Calabria con la forma reale |
| 4 — Gli altri popoli | 19–23 | Brettii, Romani, Saraceni e Normanni giocabili nella partita libera (`src/core/popoli.gd`; Brettii: pecificio e pece; Romani: laterizi e tegole, legionari, portatori +15%; Saraceni: seta, cavalieri leggeri, campi irrigati ×1,5; Normanni: cavalli e mastio, cavalieri pesanti, confini +2); campagna finale «La Soglia» (4 missioni, due finali) |
| Vibo Valentia | V1–V3 | mappa di gioco «Monteleone» (96×96) con la costa vera da Pizzo a Nicotera, scelta nel menu e dalla mappa della Calabria; 11 monumenti sbloccati in ordine a traguardi, posati al loro posto, con vantaggi; partite senza fine verificate (2 ore di gioco stabili) |

Ultime modifiche significative (step 28, Fase 6): porto e nave a vela (`Lavoratore` con lo stato `NAVIGA`, rotta sul mare casella per casella fino a un altro porto, altrimenti al largo; commercio delle anfore in ducati), modelli `porto` e `nave`; test `test_stretto`. Prima: campagna «Il fuoco sotto la montagna» (step 27).

## In sviluppo

- **Step 24 — versione iPhone** (Fase 4): comandi touch fatti; esportazione iOS in attesa della risposta sul Mac. Si è passati alla **Fase 6 (Sicilia)**: step 25–28 fatti (mappa di Zancle, Siculi e Sicani, campagna siciliana, navi e porti), prossimo lo step 29 (finale nuovo).

## Da fare (in ordine)

1. **Fase 4**: esportazione iPhone (in attesa della risposta sul Mac), campagna finale «La Soglia», versione iPhone.
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

**Step 29 — finale nuovo: il Mercante senza Volto e l'ultimo segreto del Sigillo** (Fase 6). Dipende dalla risposta del proprietario su chi è Rocco della Lira (domanda aperta): intanto si può preparare la parte che non dipende da quella risposta (una missione epilogo dopo «Il cuore del fuoco», per esempio il ritorno del Sigillo intero sulla Soglia). Se la risposta non arriva, scegliere l'idea già scritta in `storia.md` (Rocco è Italo) segnandola come provvisoria in `decisioni.md`.
