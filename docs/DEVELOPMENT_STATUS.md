# Stato dello sviluppo

*Aggiornato il 2026-11-01. Fonte del piano completo: [`roadmap.md`](roadmap.md). Registro cronologico dettagliato: [`diario-automatico.md`](diario-automatico.md).*

## Completato (in `main`)

Ultima release: **v0.44.0** (frombolieri). Tutti i test automatici passano (32 script in `tools/test/`).

| Fase | Step | Contenuto |
|---|---|---|
| 1 — Il villaggio vive | 00, G1, 01–05, M1, G2, 06–11 | fondamenta e installer, studio grafico, mappa, costruzione, strade, trasporto, prima catena, audio (musica segnaposto), grafica livello 2, cibo (campi, allevamenti, pesca), metallo e attrezzi, popolazione e pannelli, salvataggio, stagioni, Greci completi (36 edifici, agorà) |
| 2 — Guerra e avversario | 12–15 | territorio per proprietario, torri e castello presidiati, soldati e conquista, i Brettii controllati dal computer, scelta della modalità (pace / pace poi guerra / guerra) |
| 3 — La storia | 16–18 | tutorial «Il naufragio», campagna dei Greci (6 missioni, sblocco progressivo), mappa della Calabria con la forma reale |
| 4 — Gli altri popoli | 19–23 | Brettii, Romani, Saraceni e Normanni giocabili nella partita libera (`src/core/popoli.gd`; Brettii: pecificio e pece; Romani: laterizi e tegole, legionari, portatori +15%; Saraceni: seta, cavalieri leggeri, campi irrigati ×1,5; Normanni: cavalli e mastio, cavalieri pesanti, confini +2); campagna finale «La Soglia» (4 missioni, due finali) |
| Vibo Valentia | V1–V3 | mappa di gioco «Monteleone» (96×96) con la costa vera da Pizzo a Nicotera, scelta nel menu e dalla mappa della Calabria; 11 monumenti sbloccati in ordine a traguardi, posati al loro posto, con vantaggi; partite senza fine verificate (2 ore di gioco stabili) |

Ultime modifiche significative (v0.44.0): i Brettii del giocatore hanno i colori del giocatore (`brettio_giocatore`, `Popoli.DATI[...]["soldati_giocatore"]`); quelli nemici restano rossi. Prima: le Eolie sulla mappa della campagna (v0.43.0).

## In sviluppo

- **Step 24 — versione iPhone** (Fase 4): comandi touch fatti; esportazione iOS in attesa della risposta sul Mac. Si è passati alla **Fase 6 (Sicilia)**: step 25–29 fatti (mappa di Zancle, Siculi e Sicani, campagna siciliana, navi e porti, epilogo): **Fase 6 finita**.

## Da fare (in ordine)

1. **Fase 4**: esportazione iPhone (in attesa della risposta sul Mac), campagna finale «La Soglia», versione iPhone.
2. **Fase 6**: la Sicilia (mappa reale, Siculi e Sicani, campagna «Il fuoco sotto la montagna», navi sullo Stretto).
3. **Fase 5** (Coral Island): solo dopo le domande al proprietario.

## Bug e limiti noti

- **Musica segnaposto**: deciso come rifarla (FluidSynth + soundfont libero, brani originali), da fare.
- **Compilazioni su GitHub non verificate da qui**: `gh` non è installato; i push partono, l'esito delle Actions va guardato su GitHub.
- Animali degli allevamenti fermi nel modello (non si muovono).
- Le rocce sono finite e i boschi naturali non ricrescono da soli: per giocare ore servono guardaboschi accanto ai boscaioli e cave nuove quando le rocce finiscono (voluto, come in Settlers).
- La costa è lontana dal villaggio iniziale: per pescatore e barca servono 1–2 torri verso il mare.
- Le materie prime grezze (olive, tronchi…) non hanno tetto di scorta: solo pozzo e trasformatori si fermano.
- Con una sola strada verso il magazzino si formano code (normale: il giocatore aggiunge strade).
- Sulla mappa di Monteleone i Brettii mettono entrambi gli avamposti sul Poro (le Serre sono troppo ripide e boscose).

## Prossima attività consigliata

**Fase 7 — «Le guerre di Annibale»** (idee da Imperivm, richiesta del proprietario del 2026-11-02): piano in `docs/piano-imperivm.md`. Cominciare dallo **step 30 (villaggi indigeni)**, che non dipende dalle domande aperte; poi condottieri e schiere (step 31) quando il proprietario conferma il controllo diretto (o, se non risponde, con il controllo diretto come scelta provvisoria).
Il proprietario ha risposto a tutte le domande (vedi `decisioni.md`): Fase 7 con controllo diretto e Cartaginesi con elefanti, poi Fase 5 come modalità «Vita del villaggio»; musica con FluidSynth; iPhone rimandato.
