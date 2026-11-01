# Stato dello sviluppo

*Aggiornato il 2026-11-01. Fonte del piano completo: [`roadmap.md`](roadmap.md). Registro cronologico dettagliato: [`diario-automatico.md`](diario-automatico.md).*

## Completato (in `main`)

Ultima release: **v0.24.0** (step 19). Tutti i test automatici passano (20 script in `tools/test/`).

| Fase | Step | Contenuto |
|---|---|---|
| 1 — Il villaggio vive | 00, G1, 01–05, M1, G2, 06–11 | fondamenta e installer, studio grafico, mappa, costruzione, strade, trasporto, prima catena, audio (musica segnaposto), grafica livello 2, cibo (campi, allevamenti, pesca), metallo e attrezzi, popolazione e pannelli, salvataggio, stagioni, Greci completi (36 edifici, agorà) |
| 2 — Guerra e avversario | 12–15 | territorio per proprietario, torri e castello presidiati, soldati e conquista, i Brettii controllati dal computer, scelta della modalità (pace / pace poi guerra / guerra) |
| 3 — La storia | 16–18 | tutorial «Il naufragio», campagna dei Greci (6 missioni, sblocco progressivo), mappa della Calabria con la forma reale |
| 4 — Gli altri popoli | 19 | Brettii giocabili nella partita libera (`src/core/popoli.gd`, 16 modelli brettii, pecificio e pece) |
| Vibo Valentia | V1–V3 | mappa di gioco «Monteleone» (96×96) con la costa vera da Pizzo a Nicotera, scelta nel menu e dalla mappa della Calabria; 11 monumenti sbloccati in ordine a traguardi, posati al loro posto, con vantaggi; partite senza fine verificate (2 ore di gioco stabili) |

Ultime modifiche significative (step 19): `Popoli` (popolo del giocatore e dei nemici, sprite per popolo, soldati, torre nemica, testi), `Impostazioni.popolo` e scelta «Con chi?» nel menu, edifici unici per popolo (`"popolo"` nel catalogo: agorà greca, pecificio brettio), merce `pece` (lusso), portatori brettii più veloci su bosco e quota > 60, nemici greci con torri `torre`, popolo nel salvataggio (`Salvataggio.popolo_di`); test `test_brettii`.

## In sviluppo

- **Step 20 — i Romani** (Fase 4): da aprire.

## Da fare (in ordine)

1. **Fase 4**: Romani, Saraceni, Normanni giocabili (i Brettii sono fatti), campagna finale «La Soglia», versione iPhone.
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
- I Brettii giocabili: 16 edifici hanno l'aspetto brettio, gli altri (miniere, zecca, fonderia, vigneto…) per ora quello greco; i frombolieri hanno ancora i colori rossi di quando erano solo nemici; la campagna resta dei Greci.
- Gli altri popoli hanno solo torri (non un villaggio completo): arriverà con la Fase 4.

## Prossima attività consigliata

Aprire lo **step 20 — Romani** con lo stesso schema dei Brettii (`docs/brettii.md` come modello): voce in `Popoli.DATI`, edificio unico «Cantiere stradale» e catena dei laterizi (argilla → mattoni → tegole), legionario, abilità «strade lastricate: portatori più rapidi», modelli `<tipo>_romani` (subagente). Serve generalizzare i nemici: con più popoli, chi è il nemico di chi (oggi Greci ↔ Brettii).
