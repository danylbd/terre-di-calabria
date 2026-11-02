# Stato dello sviluppo

*Aggiornato il 2026-11-01. Fonte del piano completo: [`roadmap.md`](roadmap.md). Registro cronologico dettagliato: [`diario-automatico.md`](diario-automatico.md).*

## Completato (in `main`)

Ultima release: **v0.50.0** (step 35). Tutti i test automatici passano (38 script in `tools/test/`).

| Fase | Step | Contenuto |
|---|---|---|
| 1 — Il villaggio vive | 00, G1, 01–05, M1, G2, 06–11 | fondamenta e installer, studio grafico, mappa, costruzione, strade, trasporto, prima catena, audio (musica segnaposto), grafica livello 2, cibo (campi, allevamenti, pesca), metallo e attrezzi, popolazione e pannelli, salvataggio, stagioni, Greci completi (36 edifici, agorà) |
| 2 — Guerra e avversario | 12–15 | territorio per proprietario, torri e castello presidiati, soldati e conquista, i Brettii controllati dal computer, scelta della modalità (pace / pace poi guerra / guerra) |
| 3 — La storia | 16–18 | tutorial «Il naufragio», campagna dei Greci (6 missioni, sblocco progressivo), mappa della Calabria con la forma reale |
| 4 — Gli altri popoli | 19–23 | Brettii, Romani, Saraceni e Normanni giocabili nella partita libera (`src/core/popoli.gd`; Brettii: pecificio e pece; Romani: laterizi e tegole, legionari, portatori +15%; Saraceni: seta, cavalieri leggeri, campi irrigati ×1,5; Normanni: cavalli e mastio, cavalieri pesanti, confini +2); campagna finale «La Soglia» (4 missioni, due finali) |
| Vibo Valentia | V1–V3 | mappa di gioco «Monteleone» (96×96) con la costa vera da Pizzo a Nicotera, scelta nel menu e dalla mappa della Calabria; 11 monumenti sbloccati in ordine a traguardi, posati al loro posto, con vantaggi; partite senza fine verificate (2 ore di gioco stabili) |

Ultime modifiche significative (step 35, Fase 7): traversate delle schiere per mare tra due nostri porti e navi da guerra che bersagliano le torri nemiche sulla costa (`Mare`, `NaviGuerra`), bireme disegnata; test `test_navi`. Prima: abilità dei condottieri (step 34).

## In sviluppo

- **Fase 7 «Le guerre di Annibale»**: step 30–35 fatti, più gli step 36a (costruttori al cantiere, v0.51.0), 36b (voce di re Italo, v0.52.0) 36 (assedi, v0.53.0) 37 (Cartaginesi, v0.54.0) 38 (mappa del Bruzio, v0.55.0) e 39 (campagna di Annibale, v0.56.0).

## Da fare (in ordine) per finire questa versione del gioco

1. **Fase 7**: 38 mappa del Bruzio, 39 campagna di Annibale, 40 grafica di guerra.
2. **Musica nuova** (FluidSynth + soundfont libero, brani originali).
3. **Chiusura**: prova completa, bilanciamento finale, versione 1.0.

Rimandati a una versione successiva (decisione del 2026-11-02): Fase 5 «Vita del villaggio» e iPhone, in [`idee-future.md`](idee-future.md).

## Bug e limiti noti

- **Musica segnaposto**: deciso come rifarla (FluidSynth + soundfont libero, brani originali), da fare. Manca una musica di guerra.
- **Compilazioni su GitHub non verificate da qui**: `gh` non è installato; i push partono, l'esito delle Actions va guardato su GitHub.
- Animali degli allevamenti fermi nel modello (non si muovono).
- Le rocce sono finite e i boschi naturali non ricrescono da soli: per giocare ore servono guardaboschi accanto ai boscaioli e cave nuove quando le rocce finiscono (voluto, come in Settlers).
- La costa è lontana dal villaggio iniziale: per pescatore e barca servono 1–2 torri verso il mare.
- Le materie prime grezze (olive, tronchi…) non hanno tetto di scorta: solo pozzo e trasformatori si fermano.
- Con una sola strada verso il magazzino si formano code (normale: il giocatore aggiunge strade).
- Sulla mappa di Monteleone i Brettii mettono entrambi gli avamposti sul Poro (le Serre sono troppo ripide e boscose).

## Prossima attività consigliata

**Step 40 — rifinitura grafica di guerra** (Fase 7, `docs/piano-imperivm.md`): modelli veri dei villaggi indigeni (oggi usano sprite di edifici esistenti), segni sulla mappa per le mura e gli assedi, effetti di battaglia più ricchi; poi la musica nuova (anche di guerra) e la chiusura con la versione 1.0.
