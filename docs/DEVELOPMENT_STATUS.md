# Stato dello sviluppo

*Aggiornato il 2026-11-01. Fonte del piano completo: [`roadmap.md`](roadmap.md). Registro cronologico dettagliato: [`diario-automatico.md`](diario-automatico.md).*

## Completato (in `main`)

Ultima release: **v0.20.0** (step 18). Tutti i test automatici passano (16 script in `tools/test/`).

| Fase | Step | Contenuto |
|---|---|---|
| 1 — Il villaggio vive | 00, G1, 01–05, M1, G2, 06–11 | fondamenta e installer, studio grafico, mappa, costruzione, strade, trasporto, prima catena, audio (musica segnaposto), grafica livello 2, cibo (campi, allevamenti, pesca), metallo e attrezzi, popolazione e pannelli, salvataggio, stagioni, Greci completi (36 edifici, agorà) |
| 2 — Guerra e avversario | 12–15 | territorio per proprietario, torri e castello presidiati, soldati e conquista, i Brettii controllati dal computer, scelta della modalità (pace / pace poi guerra / guerra) |
| 3 — La storia | 16–18 | tutorial «Il naufragio», campagna dei Greci (6 missioni, sblocco progressivo), mappa della Calabria con la forma reale |

Ultime modifiche significative (step 18): mappa della campagna dalla geografia reale; le monete si chiamano **ducati** (anche nei salvataggi vecchi); piani per Monteleone e per la Sicilia nei documenti.

## In sviluppo

- **Step V1 — mappa di Monteleone (Vibo Valentia)**: non ancora iniziato nel codice (ramo previsto `step-v1-monteleone`). Piano in [`monteleone.md`](monteleone.md).
- **Sistema di memoria del progetto** (questi documenti): ramo `memoria-progetto`.

## Da fare (in ordine)

1. **V1** mappa di Monteleone: nuovo generatore con costa e rilievi del Vibonese (Pizzo, Vibo Marina, Bivona, Tropea, Capo Vaticano, Monte Poro, Mesima, Serre); scelta nel menu.
2. **V2** monumenti di Monteleone: 11 monumenti sbloccati a traguardi, posati al loro posto, con vantaggi (tabella in `monteleone.md`).
3. **V3** partite senza fine: verificare che dopo l'ultima missione si continui; prestazioni per partite di ore.
4. **Fase 4**: Brettii, Romani, Saraceni, Normanni giocabili, campagna finale «La Soglia», versione iPhone.
5. **Fase 6**: la Sicilia (mappa reale, Siculi e Sicani, campagna «Il fuoco sotto la montagna», navi sullo Stretto).
6. **Fase 5** (Coral Island): solo dopo le domande al proprietario.

## Bug e limiti noti

- **Musica segnaposto** (sintetizzata): la domanda su come fare la musica vera è aperta in [`domande-per-il-proprietario.md`](domande-per-il-proprietario.md).
- **Compilazioni su GitHub non verificate da qui**: `gh` non è installato; i push partono, l'esito delle Actions va guardato su GitHub.
- Animali degli allevamenti fermi nel modello (non si muovono).
- La costa è lontana dal villaggio iniziale: per pescatore e barca servono 1–2 torri verso il mare.
- Le materie prime grezze (olive, tronchi…) non hanno tetto di scorta: solo pozzo e trasformatori si fermano.
- Con una sola strada verso il magazzino si formano code (normale: il giocatore aggiunge strade).
- Gli altri popoli hanno solo torri (non un villaggio completo): arriverà con la Fase 4.

## Prossima attività consigliata

Chiudere il ramo `memoria-progetto`, poi aprire **step V1** (mappa di Monteleone) seguendo `monteleone.md`.
