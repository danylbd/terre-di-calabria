# Roadmap — Terre di Calabria

Ogni step ha un suo ramo `step-XX-nome`, lavorato in un worktree separato. Quando lo step ti piace lo uniamo a `main` e GitHub crea un nuovo `Setup.exe`. Le decisioni di fondo sono in [`decisioni.md`](decisioni.md).

## Fase 1 — Il villaggio vive (Greci, modalità pace)

| Step | Nome | Cosa si vede alla fine | Stato |
|---|---|---|---|
| 00 | Fondamenta | Progetto, design, storia, schermata iniziale, installer | fatto |
| G1 | Studio grafico | Rendering 3D → sprite; primi edifici greci, alberi, portatore animato | fatto |
| 01 | La mappa | Terreno dipinto continuo (prato, bosco, sabbia, mare, monti), alberi, camera con mouse e tastiera, zoom | fatto |
| 02 | Costruire | Menu edifici, piazzamento sulla griglia, confini del territorio | fatto |
| 03 | Strade e bandierine | Disegnare strade, rete di bandierine, un portatore per tratto | fatto |
| 04 | Trasporto | Le merci viaggiano di bandierina in bandierina; i cantieri crescono con i materiali consegnati | fatto |
| 05 | Prima catena | Boscaiolo abbatte gli alberi, guardaboschi ripianta, segheria fa assi, cava estrae pietra: tutto portato dai portatori | fatto |
| M1 | Musica e suoni | Primi 3 brani (orchestra + strumenti calabresi), suoni di lavoro e natura | fatto (musica segnaposto sintetizzata, da sostituire: vedi domande) |
| G2 | Grafica livello 2 | Edifici grandi e vissuti (2×2, magazzino 3×3), castagni, querce, pini laricio, ulivi, fiori e funghi, terreno saturo | fatto |
| 06 | Cibo: campi, allevamenti, pesca | Coltivazioni (grano, vite, ortaggi, cipolla rossa, agrumi), allevamenti (maiali, pecore, capre, api), pesca dalla costa e pesce spada con la barca; mulino, forno, macelleria, caseificio | fatto |
| 07 | Metallo | Miniere, fonderia, fabbro, attrezzi, nuovi mestieri | fatto |
| 08 | Popolazione e statistiche | Abitazioni, crescita, pannelli informativi | fatto |
| 09 | Salvataggio | Salvare e caricare | fatto |
| 10 | Stagioni | Inverno con neve, raccolti stagionali | fatto |
| 11 | Greci completi | Tutti i circa 30 edifici, olio e commercio, agorà | fatto |

## Fase 2 — La guerra e l'avversario

| Step | Nome | Stato |
|---|---|---|
| 12 | Territorio e torri | fatto |
| 13 | Soldati e conquista | fatto |
| 14 | Avversario controllato dal computer | fatto |
| 15 | Scelta all'avvio: solo pace / solo guerra / pace poi guerra | fatto |

## Fase 3 — La storia

| Step | Nome | Stato |
|---|---|---|
| 16 | Tutorial: «Il naufragio» (prima missione dei Greci) | fatto |
| 17 | Campagna dei Greci (6 missioni) con Rocco della Lira | fatto |
| 18 | Mappa della Calabria con la forma reale | fatto |
| V1 | Mappa di Monteleone (Vibo Valentia): mappa di gioco con Monteleone sul colle, Vibo Marina, Pizzo, Bivona, Tropea, Capo Vaticano, Monte Poro, valle del Mesima, Serre; costa rifatta simile a quella vera (vedi [`monteleone.md`](monteleone.md)) | fatto (v0.21.0) |
| V2 | Monumenti di Monteleone: monumenti tipici sbloccati a ogni traguardo e posati al loro posto sulla mappa (mura greche, tempio, castello normanno-svevo, Duomo, Valentianum, Bivona, Pizzo, Tropea...) | fatto (v0.22.0) |
| V3 | Partite senza fine: campagne e missioni senza limite di tempo: dopo l'ultima missione si continua; prestazioni per partite di ore | fatto (v0.23.0) |

## Fase 4 — Gli altri popoli e il finale

| Step | Nome | Stato |
|---|---|---|
| 19 | Brettii giocabili nella partita libera: aspetto proprio, pecificio e pece, frombolieri, passo svelto nei boschi, nemici greci (vedi [`brettii.md`](brettii.md)) | fatto (v0.24.0) |
| 20 | Romani giocabili: aspetto proprio, fornace dei laterizi e tegole, legionari, strade lastricate, nemici brettii (vedi [`romani.md`](romani.md)) | fatto (v0.25.0) |
| 21 | Saraceni giocabili: aspetto proprio, bachicoltura e filanda (seta), cavalieri leggeri, campi irrigati, nemici romani (vedi [`saraceni.md`](saraceni.md)) | fatto (v0.26.0) |
| 22 | Normanni giocabili: aspetto proprio, allevamento di cavalli e mastio, cavalieri pesanti, confini più larghi, nemici saraceni (vedi [`normanni.md`](normanni.md)) | fatto (v0.27.0) |
| 23 | Campagna finale «La Soglia»: 4 missioni a Monteleone con il popolo scelto, scelta «unire o conquistare», due finali (vedi [`soglia.md`](soglia.md)) | fatto (v0.28.0) |
| 24 | Versione iPhone | in corso: comandi touch fatti (v0.29.0); esportazione iOS in attesa di un Mac (domanda al proprietario) |

L'ordine può cambiare strada facendo: è un progetto da fare con calma.

## Fase 6 — Oltre lo Stretto: la Sicilia (prolungamento della storia)

Piano: vedi [`storia.md`](storia.md), «Il seguito in Sicilia».

| Step | Nome | Stato |
|---|---|---|
| 25 | Mappa della Sicilia con la forma reale: mappa di gioco «Zancle e l'Etna» (Milazzo, Messina, lo Stretto con la punta della Calabria, Taormina, l'Etna, Catania) | fatto (v0.30.0); le Eolie sulla mappa della campagna (v0.43.0); Siracusa e Palermo restano fuori dal foglio della Calabria |
| 26 | Nuovi popoli dell'isola: Siculi (vasaio e ceramiche, pastori) e Sicani (ossidiana, montanari), giocabili (vedi [`siculi_sicani.md`](siculi_sicani.md)) | fatto (v0.31.0) |
| 27 | Campagna «Il fuoco sotto la montagna» (6 missioni a Zancle con il popolo della Soglia, cenere dell'Etna, due finali; vedi [`fuoco.md`](fuoco.md)) | fatto (v0.32.0) |
| 28 | Lo Stretto: porto, nave a vela che attraversa lo Stretto fino a un altro porto o va al largo, commercio delle anfore (vedi [`stretto.md`](stretto.md)) | fatto (v0.33.0) |
| 29 | Finale nuovo: epilogo «L'ultimo canto» (il Sigillo torna per mare sulla Soglia, il Mercante chiama Rocco «padre»: Rocco è Italo, scelta provvisoria) (vedi [`ultimo_canto.md`](ultimo_canto.md)) | fatto (v0.34.0) |

## Extra

| Step | Nome | Stato |
|---|---|---|
| Sfide | Tre sfide senza sconfitta, con il record del tempo (vedi [`sfide.md`](sfide.md)) | fatto (v0.41.0) |

## Fase 7 — «Le guerre di Annibale» (idee da Imperivm, piano del 2026-11-02)

Piano completo: [`piano-imperivm.md`](piano-imperivm.md). Si aggiunge sopra l'economia di oggi senza toglierla.

| Step | Nome | Stato |
|---|---|---|
| 30 | Villaggi indigeni da unire o conquistare | fatto (v0.45.0) |
| 31 | Condottieri e schiere (controllo diretto) | fatto (v0.46.0) |
| 32 | Cibo, morale ed esperienza | fatto (v0.47.0) |
| 33 | Tipi di unità (fanteria, tiratori, cavalleria) | fatto (v0.48.0) |
| 34 | Abilità dei condottieri | fatto (v0.49.0) |
| 35 | Navi da guerra e traversate delle schiere | fatto (v0.50.0) |
| 36a | Costruttori al cantiere (come in Settlers) | fatto (v0.51.0) |
| 36b | Voce di re Italo (sillabe inventate, libere da diritti) | fatto (v0.52.0) |
| 36 | Assedi (ariete, onagro) | fatto (v0.53.0) |
| 37 | I Cartaginesi (ottavo popolo, elefanti) | fatto (v0.54.0) |
| 38 | Mappa «Il Bruzio di Annibale» | fatto (v0.55.0) |
| 39 | Campagna «Annibale nel Bruzio» (dai due lati) | fatto (v0.56.0) |
| 40 | Rifinitura grafica di guerra | fatto (v0.57.0) |

## Per finire il gioco (dopo la Fase 7)

| Cosa | Stato |
|---|---|
| Musica nuova (FluidSynth + soundfont libero, brani originali) | fatto (v0.58.0): mattino, lavoro, sera e guerra |
| Chiusura: prova completa, bilanciamento finale, versione 1.0 | fatto (v1.0.0) |

## Fase 8 — Rifiniture alla Settlers (richieste del proprietario del 2026-11-03, versioni 1.x)

| Step | Cosa | Stato |
|---|---|---|
| 43 | Interfaccia: tutto schermo, menu di costruzione richiudibile, nome del villaggio cambiabile, legenda dei tasti nascondibile, zoom regolabile con un pulsante, via il pulsante «Bandierina» | fatto (v1.1.0) |
| 44 | Montagna: sui monti solo miniere, cava e torri (e si possono allargare i confini sui monti) | fatto (v1.1.0) |
| 45 | Torri: due soldati per torre, i confini si allargano solo quando i soldati entrano | fatto (v1.1.0) |
| 46 | Stagioni di un'ora di gioco l'una; suono della segheria più adatto; bandierine nascoste quando la strada è collegata | fatto (v1.1.0) |
| 47 | Economia: ogni bottega accumula fuori, in ordine, le sue merci (fino a 50, poi si ferma); magazzini da 200 merci, uno ogni 50 coloni | fatto (v1.1.0) |
| 48 | Abitazioni con comignoli e fumo | fatto (v1.1.0) |
| 49 | Casa dei pionieri e pionieri che allargano i confini, come in Settlers | fatto (v1.1.0) |
| 50 | Mappe molto più grandi, la telecamera si ferma prima del bordo | fatto (v1.1.0) |
| 51 | Mappa più interessante: rocche antiche in rovina, villaggi abbandonati e altri dettagli | fatto (v1.1.0) |
| 52 | Coloni più dettagliati: atlas animati con otto direzioni, abiti, merci e attrezzi | fatto (v1.1.0) |
| 53 | Partita pacifica più dinamica: esplorare rovine e trovare ricompense | fatto (v1.1.0) |
| 54 | Correzioni emerse dalle schermate: accesso alternativo agli edifici, bandierine nascoste, menu Costruisci richiudibile, area edificabile ampliata e personaggi/animazioni rifiniti | fatto (v1.1.1) |
| 55 | Bug raccolti dopo la release: riapertura del menu Costruisci, andatura naturale dei coloni e nomi dei luoghi solo al passaggio del cursore | in corso; release in attesa del completamento della raccolta bug |

## Fase 5 — rimandata a una versione successiva

La modalità «Vita del villaggio» (idee da Coral Island) e la versione iPhone non fanno parte di questa versione (decisione del 2026-11-02): sono in [`idee-future.md`](idee-future.md).
