# Stato dello sviluppo

*Aggiornato il 2026-11-01. Fonte del piano completo: [`roadmap.md`](roadmap.md). Registro cronologico dettagliato: [`diario-automatico.md`](diario-automatico.md).*

## Completato (in `main`)

Ultima release: **v0.30.0** (step 25). Tutti i test automatici passano (26 script in `tools/test/`).

| Fase | Step | Contenuto |
|---|---|---|
| 1 — Il villaggio vive | 00, G1, 01–05, M1, G2, 06–11 | fondamenta e installer, studio grafico, mappa, costruzione, strade, trasporto, prima catena, audio (musica segnaposto), grafica livello 2, cibo (campi, allevamenti, pesca), metallo e attrezzi, popolazione e pannelli, salvataggio, stagioni, Greci completi (36 edifici, agorà) |
| 2 — Guerra e avversario | 12–15 | territorio per proprietario, torri e castello presidiati, soldati e conquista, i Brettii controllati dal computer, scelta della modalità (pace / pace poi guerra / guerra) |
| 3 — La storia | 16–18 | tutorial «Il naufragio», campagna dei Greci (6 missioni, sblocco progressivo), mappa della Calabria con la forma reale |
| 4 — Gli altri popoli | 19–23 | Brettii, Romani, Saraceni e Normanni giocabili nella partita libera (`src/core/popoli.gd`; Brettii: pecificio e pece; Romani: laterizi e tegole, legionari, portatori +15%; Saraceni: seta, cavalieri leggeri, campi irrigati ×1,5; Normanni: cavalli e mastio, cavalieri pesanti, confini +2); campagna finale «La Soglia» (4 missioni, due finali) |
| Vibo Valentia | V1–V3 | mappa di gioco «Monteleone» (96×96) con la costa vera da Pizzo a Nicotera, scelta nel menu e dalla mappa della Calabria; 11 monumenti sbloccati in ordine a traguardi, posati al loro posto, con vantaggi; partite senza fine verificate (2 ore di gioco stabili) |

Ultime modifiche significative (step 25, Fase 6): mappa di gioco «Zancle e l'Etna» (`GeneratoreMappa.genera_zancle()`, 96×96, coste vere di Sicilia e Calabria: Milazzo, Messina, lo Stretto largo 5 caselle, Taormina, l'Etna innevato con la terra nera, Catania; Peloritani e Nebrodi); `_distanza_costa()` ora accetta più coste e terre; pulsante «Gioca a Zancle» sulla mappa della Calabria; test `test_zancle`. Prima: comandi touch (step 24).

## In sviluppo

- **Step 24 — versione iPhone** (Fase 4): comandi touch fatti; esportazione iOS in attesa della risposta sul Mac. Si è passati alla **Fase 6 (Sicilia)**: step 25 fatto, prossimo lo step 26 (Siculi e Sicani).

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

**Step 26 — Siculi e Sicani** (Fase 6): due popoli nuovi dell'isola, con lo stesso schema dei cinque calabresi (`Popoli.DATI`, edificio unico, merce speciale, soldato, abilità, modelli `<tipo>_siculi` / `<tipo>_sicani` con un subagente). Da `storia.md`: Siculi pastori e vasai dell'interno (Pantalica), Sicani gente delle montagne a ovest. Scrivere prima il piano in `docs/siculi_sicani.md`.
