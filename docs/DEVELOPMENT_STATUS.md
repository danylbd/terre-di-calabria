# Stato dello sviluppo

*Aggiornato il 2026-11-01. Fonte del piano completo: [`roadmap.md`](roadmap.md). Registro cronologico dettagliato: [`diario-automatico.md`](diario-automatico.md).*

## Completato (in `main`)

Ultima release: **v0.22.0** (step V2). Tutti i test automatici passano (18 script in `tools/test/`).

| Fase | Step | Contenuto |
|---|---|---|
| 1 — Il villaggio vive | 00, G1, 01–05, M1, G2, 06–11 | fondamenta e installer, studio grafico, mappa, costruzione, strade, trasporto, prima catena, audio (musica segnaposto), grafica livello 2, cibo (campi, allevamenti, pesca), metallo e attrezzi, popolazione e pannelli, salvataggio, stagioni, Greci completi (36 edifici, agorà) |
| 2 — Guerra e avversario | 12–15 | territorio per proprietario, torri e castello presidiati, soldati e conquista, i Brettii controllati dal computer, scelta della modalità (pace / pace poi guerra / guerra) |
| 3 — La storia | 16–18 | tutorial «Il naufragio», campagna dei Greci (6 missioni, sblocco progressivo), mappa della Calabria con la forma reale |
| Vibo Valentia | V1–V2 | mappa di gioco «Monteleone» (96×96) con la costa vera da Pizzo a Nicotera, scelta nel menu e dalla mappa della Calabria; 11 monumenti sbloccati in ordine a traguardi, posati al loro posto, con vantaggi |

Ultime modifiche significative (step V2): `src/storia/monumenti.gd` (catalogo, traguardi in ordine, posa su 2×2 caselle libere vicino al luogo vero, doni a ogni stagione); `Villaggio.vantaggi` (confini, nascita, lavoro, duelli) usato da villaggio, lavoratore e guerra; segnali `Logistica.prodotta` e `Guerra.forte_perso`; monumenti nel salvataggio e nel pannello del villaggio; 11 modelli 3D nuovi; test `test_monumenti`.

## In sviluppo

- **Step V3 — partite senza fine**: da aprire (ramo `step-v3-senza-fine`).

## Da fare (in ordine)

1. **V3** partite senza fine: verificare che dopo l'ultima missione si continui; prestazioni per partite di ore.
2. **Fase 4**: Brettii, Romani, Saraceni, Normanni giocabili, campagna finale «La Soglia», versione iPhone.
3. **Fase 6**: la Sicilia (mappa reale, Siculi e Sicani, campagna «Il fuoco sotto la montagna», navi sullo Stretto).
4. **Fase 5** (Coral Island): solo dopo le domande al proprietario.

## Bug e limiti noti

- **Musica segnaposto** (sintetizzata): la domanda su come fare la musica vera è aperta in [`domande-per-il-proprietario.md`](domande-per-il-proprietario.md).
- **Compilazioni su GitHub non verificate da qui**: `gh` non è installato; i push partono, l'esito delle Actions va guardato su GitHub.
- Animali degli allevamenti fermi nel modello (non si muovono).
- La costa è lontana dal villaggio iniziale: per pescatore e barca servono 1–2 torri verso il mare.
- Le materie prime grezze (olive, tronchi…) non hanno tetto di scorta: solo pozzo e trasformatori si fermano.
- Con una sola strada verso il magazzino si formano code (normale: il giocatore aggiunge strade).
- Sulla mappa di Monteleone i Brettii mettono entrambi gli avamposti sul Poro (le Serre sono troppo ripide e boscose).
- Gli altri popoli hanno solo torri (non un villaggio completo): arriverà con la Fase 4.

## Prossima attività consigliata

Aprire **step V3** (partite senza fine): partita lunga accelerata su Monteleone, misurare prestazioni (nodi, merci, FPS) e memoria dopo ore di gioco, controllare che dopo l'ultima missione e l'ultimo monumento si possa continuare.
