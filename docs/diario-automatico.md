# Diario dei turni automatici

Memoria tra un turno automatico e l'altro: in fondo l'ultimo turno.

## 2026-10-31 20:00 — step 05 prima catena
- Scritto `tools/test/test_catena.gd`: piazza boscaiolo, cava, segheria, guardaboschi, li collega e accelera il tempo. Risultato OK: alberi abbattuti, pietra estratta, 8 alberelli piantati, assi della segheria e pietra arrivano al magazzino.
- Trovato collo di bottiglia: il portatore rientrava sempre a metà tratto anche con una merce di ritorno già in attesa. Ora la riprende subito (`portatore.gd: puo_prendere`): assi in 6 minuti di gioco da 22 a 31.
- Screenshot in `docs/immagini/step05-catena.png`. Versione 0.6.0, roadmap e CLAUDE.md aggiornati, step unito a `main`.
- Resta / da tenere d'occhio: con una sola strada verso il magazzino si formano code (normale, il giocatore aggiunge strade). I tronchi del boscaiolo vanno al magazzino quando la segheria ha già 4 tronchi in arrivo: corretto ma fa fare giri in più.
- Prossimo: step M1 musica e suoni.

## 2026-10-31 20:30 — step M1 musica e suoni (inizio)
- Creato ramo `step-m1-musica` e worktree. Sul PC mancano numpy, ffmpeg, fluidsynth, soundfont.
- Scritta la domanda in `docs/domande-per-il-proprietario.md` (come produrre la musica; raccomandata opzione 1: FluidSynth + soundfont libero).
- Prossimo turno, senza aspettare la risposta: sistema audio in Godot (bus Musica/Effetti/Ambiente, lettore musica con dissolvenza, suoni posizionali dei lavoratori) e suoni di lavoro/natura sintetizzati con Python standard (`wave`, `math`) in `tools/suoni/`.

## 2026-10-31 20:45 — step M1 completato (sessione principale, lavoro continuo)
- Su richiesta del proprietario: turno orario disattivato (eliminarlo va fatto da una sessione normale), si lavora solo dalla sessione principale.
- Adottato il lavoro della sessione oraria (audio.gd, suoni.py, suoni di lavoro e interfaccia); aggiunta la classe `Suono` perché l'identificatore `Audio` rompeva i test con `--script`.
- Musica segnaposto (3 brani, `tools/suoni/musica.py`), scaletta, tasto M, cicale. test_audio e test_catena OK; il gioco parte senza errori audio.
- Versione 0.7.0, merge in main. Prossimo: step 06 cibo.

## 2026-10-31 21:15 — step 06 cibo, pezzo 1 (pane e pesce)
- Fattoria (contadino semina fino a 8 campi, crescono in 4 fasi, miete → grano), mulino (farina), forno (farina + acqua → pane), pozzo (acqua solo se serve: `Logistica.serve()`), pescatore (pesce dalla riva, si esaurisce e torna). Lavoratore generalizzato: `_lavora_dentro()` vale per segheria, mulino, forno, pozzo.
- Sprite nuovi (studio opengl3): 4 edifici, campo_1..4, stoppie, 5 merci, 4 carichi del portatore, contadino e pescatore. Suoni falce, tuffo, macina.
- Corretto bug in `rete_strade.gd` (_percorso_tra_uscite: array senza tipo).
- test_cibo OK (pane 10, pesce 19 in 10 minuti di gioco), test_catena OK. Screenshot `docs/immagini/step06-cibo*.png`.
- Resta per lo step 06: allevamenti (maiali, pecore, capre, api) con macelleria e caseificio; vite, orto/cipolla, agrumi; barca per il pesce spada; olive per il frantoio.

## 2026-10-31 21:45 — step 06 cibo, pezzo 2 (allevamenti)
- Porcile (grano + acqua → maiali), macelleria (carne), ovile (acqua → latte e lana a turno: `produce` può essere un elenco), capraio (latte), apiario (miele), caseificio (latte → formaggio). Campo `durata` nel catalogo per i tempi di lavoro.
- Modelli con animali (maiali, pecore, capre) nei recinti; merci e carichi nuovi. Barra delle scorte: legno e pietra sempre, le altre merci solo quando ci sono, e si ricentra.
- test_allevamenti OK (carne, lana, formaggio, miele al magazzino). Screenshot `docs/immagini/step06-allevamenti.png`.
- Resta: vite/cantina, orto e cipolla, agrumi, olive per il frantoio, barca per il pesce spada. Animali fermi nel modello (in futuro: animali che si muovono).

## 2026-10-31 22:30 — step 06 completato
- Pezzo 3: colture generiche (vigneto, ortolano, agrumeto con vite e agrumi perenni), cantina, raccoglitore di olive + frantoio, barca del pesce spada (rema sull'acqua). Pescatore e barca solo vicino al mare.
- Tutti i test OK: catena, audio, cibo, allevamenti, colture. Versione 0.8.0, merge in main.
- Note per il futuro: olive e altre materie prime non hanno tetto (solo il pozzo si ferma); animali fermi nei modelli; la costa è lontana dal villaggio iniziale (servono 2 torri).
- Prossimo: step 07 metallo.

## 2026-10-31 23:15 — step 07 metallo completato
- Miniera di ferro (sulla roccia, anche sopra i massi; giacimenti nascosti che si esauriscono; i minatori mangiano pane/pesce/carne/formaggio/ortaggi/cipolle), carbonaia, fonderia, fabbro.
- Attrezzi: ogni artigiano porta il suo dal magazzino (scorte iniziali); il fabbro forgia prima quello che manca. Barra: voce unica "Attrezzi" con il dettaglio nel suggerimento.
- Chi trasforma si ferma oltre 12 in magazzino se nessuno chiede (la carbonaia non brucia più tutti i tronchi).
- Lezione: dopo lo studio serve `--import`, altrimenti gli edifici nuovi sono invisibili (successo nel primo screenshot).
- Tutti i 6 test OK. Versione 0.9.0, merge in main. Prossimo: step 08 popolazione e statistiche.

## 2026-10-31 23:50 — step 08 popolazione e statistiche completato
- Coloni contati: 40 all'inizio, posti dalle abitazioni (8) e dal magazzino (24); portatori e lavoratori prendono un colono, demolendo tornano liberi; strade ed edifici aspettano se i coloni finiscono.
- Le case fanno nascere coloni ogni 40 s (20 s consumando vino, agrumi o miele); il nuovo colono cammina fino al magazzino.
- Pannello edificio (clic: stato, perché è fermo, ingressi, produzione, strada da qui, demolisci) e pannello villaggio (tasto I / pulsante). Barra: "Coloni N / M".
- Tutti i 7 test OK. Versione 0.10.0, merge in main. Prossimo: step 09 salvataggio.

## 2026-11-01 00:30 — step 09 salvataggio completato
- `Salvataggio.salva/carica` (JSON): natura (alberi con posizione e crescita, massi, campi, ceppi, pesce, olive, giacimenti), edifici e cantieri, bandierine, strade (con o senza portatore), merci in viaggio, scorte, coloni, statistiche, camera.
- F5/F9, salvataggio automatico con Esc e alla chiusura, "Continua la partita" nel menu iniziale. Tolta la scritta "step G2" dalla versione nel titolo.
- test_salvataggio: tutto identico dopo il caricamento e la partita continua a produrre. Tutti gli 8 test OK. Versione 0.11.0. Prossimo: step 10 stagioni.

## 2026-11-01 01:15 — step 10 stagioni completato
- Calendario di 4 stagioni (5 minuti l'una), si parte in primavera. Crescita per stagione di grano, orto, vite, agrumi, alberelli, olive; d'inverno niente semina e api a riposo.
- Neve nello shader del terreno, fiocchi che cadono, castagni e querce gialli d'autunno e spogli d'inverno, luce che cambia; cicale solo d'estate, più vento d'inverno. Stagione e anno nella barra e nel pannello.
- Calendario nel salvataggio. Tutti i 9 test OK. Versione 0.12.0. Prossimo: step 11 Greci completi.

## 2026-11-01 02:10 — step 11 Greci completi (Fase 1 finita)
- 7 edifici nuovi (36 in tutto): argillaio, fornace, saline, tessitura, miniera d'argento, zecca, agorà (3×3, edificio unico dei Greci).
- Agorà: vende olio, vino, stoffa, anfore, pesce spada, miele, formaggio, sale, agrumi per monete (prezzi favorevoli); compra la merce scelta nel pannello. Le monete non hanno tetto di scorta.
- Generalizzato il gruppo "una qualsiasi" (`CatalogoEdifici.gruppo`). Versione 0.13.0. Prossimo: step 12 territorio e torri.

## 2026-11-01 03:00 — step 12 territorio e torri
- Territorio con proprietario per casella; i confini altrui non si rubano senza conquista. Torre e castello (nuovo, 3×3) allargano solo con la guardia dentro (nuovo sprite "guardia" con elmo, scudo e lancia).
- Confine che si ritira: edifici fuori bruciano, strade e bandierine fuori spariscono. Pali di confine colorati per popolo; cerchio dei nuovi confini mentre si piazza un forte. Messaggi di demolizione resi neutri.
- Fase 2 della roadmap ora ha la colonna Stato. Versione 0.14.0. Prossimo: step 13 soldati e conquista.
- Bug trovato dai test: un produttore si fermava se alla sua bandierina c'erano 3+ merci di passaggio (incrocio trafficato). Ora `merci_in_uscita` conta solo le merci prodotte da quell'edificio (`Merce.origine`).

## 2026-11-01 04:00 — step 13 soldati e conquista
- Armaiolo (lingotti + assi → armi), caserma (un colono libero + armi → oplita di riserva), forti che ospitano soldati (torre 3, castello 8): i soldati della riserva li raggiungono a piedi.
- Due avamposti dei Brettii a inizio partita (sprite: torre di legno e paglia, guerriero con pelliccia). Attacco dal pannello del forte ("Attacca", poi clic sulla torre nemica): duelli alla porta (suono "scontro"), conquista → la torre diventa nostra con i vincitori dentro.
- Bug trovato: più attaccanti conquistavano la stessa torre nello stesso istante (tre torri sovrapposte). Corretto.
- Test: test_guerra (con strade non più lunghe di 14 caselle). Versione 0.15.0. Prossimo: step 14 avversario controllato dal computer.

## 2026-11-01 04:50 — step 14 avversario
- I Brettii giocati dal computer: alzano torri nuove ai margini del loro territorio, rispettano una tregua di 15 minuti, poi attaccano il nostro forte più debole alla loro portata se sono più numerosi; se vincono il forte brucia e diventa loro (perdiamo i confini e gli edifici fuori).
- guerra.gd generalizzato ai due lati; nuovo sprite "brettio" che cammina; stato dell'avversario nel salvataggio.
- Corretto un errore con edifici già distrutti assegnati a variabili con tipo. Versione 0.16.0. Prossimo: step 15 scelta della modalità all'avvio.

## 2026-11-01 05:20 — step 15 modalità all'avvio (Fase 2 finita)
- «Nuova partita» apre la scelta: Solo pace (niente Brettii), Pace poi guerra (guerra dichiarata a 60 coloni o dopo 40 minuti, con 2 minuti di preavviso), Solo guerra (avamposti con 4 difensori, tregua di 4 minuti).
- Modalità e stato della guerra nel salvataggio e nel pannello del villaggio. Versione 0.17.0. Prossimo: step 16 tutorial «Il naufragio».

## 2026-11-01 06:00 — step 16 tutorial «Il naufragio» (inizio Fase 3)
- Sistema delle missioni: racconto di Rocco della Lira e di Eudora a gioco fermo, obiettivi in sequenza con suggerimenti (strada, boscaiolo, segheria, 6 assi, due abitazioni), racconto di chiusura. Si parte col solo magazzino (il relitto). Voce «Campagna dei Greci» nel menu.
- Bug trovato: la segheria si fermava a 12 assi in magazzino (tetto delle scorte) e il tutorial non si poteva finire. Ora assi e monete servono sempre.
- Tutti i 15 test OK (eseguiti in primo piano a gruppi). Versione 0.18.0. Prossimo: step 17 campagna dei Greci.

## 2026-11-01 07:00 — step 17 campagna dei Greci
- Le altre 5 missioni de «Le Colonne dell'Alba» (Pane straniero, L'uliveto del vecchio, Città sorelle, L'ira del fiume con l'alluvione, La voce del mare con il Frammento del Mare). Testi originali. Sblocco progressivo e pannello della campagna nel menu.
- Un giocatore automatico nei test le completa tutte. Trovati e corretti: torri verso la costa non collegate alla rete; olio insufficiente in «Città sorelle» (le case consumano il vino come lusso).
- Tutti i 16 test OK. Versione 0.19.0. Prossimo: step 18 mappa della Calabria stilizzata.

## 2026-11-01 08:30 — step 18 mappa della Calabria (Fase 3 finita) + richieste del proprietario
- Mappa della campagna con la forma reale della Calabria (costa dalle coordinate geografiche), Sicilia nord-orientale, montagne, fiumi, città; missioni come segnaposti sbloccati in ordine; frammenti del Sigillo.
- Richieste del proprietario applicate: monete → **ducati** (chiave interna inclusa, vecchi salvataggi convertiti); nuove decisioni in decisioni.md; piano della mappa di Monteleone e dei suoi monumenti (docs/monteleone.md), step V1–V3 e Fase 6 (Sicilia) in roadmap, seguito della storia in Sicilia in storia.md. Partite senza limite di tempo.
- Tutti i 16 test OK. Versione 0.20.0. Prossimo: step V1 mappa di Monteleone.

## 2026-11-01 09:00 — sistema di memoria del progetto
- Su richiesta del proprietario: CLAUDE.md riordinato (76 righe: regole permanenti, continuità tra sessioni, gestione del contesto, comandi) e quattro documenti nuovi: PROJECT_MEMORY (conoscenze stabili e mappa del codice), DEVELOPMENT_STATUS (stato), DECISIONS (decisioni tecniche con motivi), SESSION_HANDOFF (punto di ripresa). Nessuna informazione persa: le note per step sono confluite in PROJECT_MEMORY.
- Il proprietario vuole «tutto automatico» (commit, merge, push compresi) e un contesto leggero. Nessuna modifica al gioco.

## 2026-11-01 10:00 — step V1 mappa di Monteleone
- Nuovo generatore `genera_monteleone` (96×96): costa del Vibonese dalle coordinate vere (Pizzo → Nicotera), mare a nord-ovest, Monteleone sul colle come villaggio, Vibo Marina, Bivona, Briatico, Tropea sulla rupe con lo scoglio dell'Isola, Capo Vaticano, altopiano del Poro, valle del Mesima, Serre, lago dell'Angitola. Nomi dei luoghi scritti sulla mappa.
- Scelta della mappa nel pannello «Nuova partita» e pulsante «Gioca a Monteleone» sulla mappa della Calabria; il salvataggio ricorda la mappa (i vecchi restano sulla Costa ionica).
- Nuovo test `test_monteleone` (catena di produzione + forma + salvataggio). Tutti i 17 test OK. Versione 0.21.0. Prossimo: V2 monumenti.

## 2026-11-01 11:00 — step V2 monumenti di Monteleone
- `Monumenti` (src/storia/monumenti.gd): 11 monumenti in ordine storico, ognuno sbloccato da un traguardo (fondazione, coloni, pescatore, agorà e ducati, castello, mestieri, ducati coniati, pesci spada, un anno senza perdere forti), posato su 2×2 caselle libere vicino al luogo vero; vantaggi in `Villaggio.vantaggi` (confini, nascite, lavoro, duelli) e doni a ogni stagione.
- 11 modelli 3D nuovi (fatti da un subagente in tools/studio/modelli.gd). Monumenti nel salvataggio e nel pannello del villaggio; tabella aggiornata in monteleone.md.
- Nuovo test `test_monumenti`; tutti i 18 test OK. Versione 0.22.0. Prossimo: V3 partite senza fine.

## 2026-11-01 12:00 — step V3 partite senza fine
- Nuovo test `test_durata` (estende test_catena): su Monteleone costruisce legno, pietra, pozzo e abitazioni e gioca 2 ore a velocità ×16 misurando nodi, oggetti, memoria, merci e registro della produzione: tutto stabile, la produzione continua.
- Trovato nel test: con il guardaboschi lontano dai boscaioli il legno finisce dopo 20 minuti (comportamento voluto, annotato nei limiti noti). Nessuna schermata di fine obbligata: missioni e monumenti finiti lasciano continuare la partita.
- Versione 0.23.0. Codice del gioco invariato rispetto alla v0.22.0 (tutti i 18 test già verdi lì). Prossimo: Fase 4, step 19 Brettii giocabili.

## 2026-11-01 13:00 — step 19 Brettii giocabili (Fase 4)
- Piano in docs/brettii.md. Nuova classe `Popoli`; scelta «Con chi?» nella nuova partita; edifici, soldati, torri nemiche e messaggi secondo il popolo; pecificio e pece (lusso) solo per i Brettii, agorà solo per i Greci; portatori brettii più veloci nei boschi e in montagna; popolo nel salvataggio.
- 16 modelli 3D brettii (subagente): pietra grezza, paglia, scandole, recinti, pelli, pali intagliati, verde bosco.
- Nuovo test `test_brettii`; tutti i 20 test OK. Versione 0.24.0. Prossimo: step 20 Romani.

## 2026-11-02 — step 20 Romani giocabili (Fase 4)
- Piano in docs/romani.md. Romani in `Popoli.DATI` (contro i Brettii, legionari, portatori +15% sulle strade lastricate); `Popoli.sprite()` generale per ogni popolo; fornace dei laterizi (argilla e tronchi → tegole, lusso).
- 19 modelli nuovi (subagente, interrotto una volta dal limite di utilizzo e ripreso): edifici romani, fornace, tegole, legionario.
- Nuovo test `test_romani`; tutti i 21 test OK. Versione 0.25.0. Prossimo: step 21 Saraceni.

## 2026-11-02 — step 21 Saraceni giocabili (Fase 4)
- Piano in docs/saraceni.md. Saraceni in `Popoli.DATI` (contro i Romani, cavalieri leggeri); campi irrigati (×1,5 vicino all'acqua); catena della seta: bachicoltura → bozzoli → filanda → seta (lusso).
- 21 modelli nuovi (subagente): edifici saraceni, bachicoltura, filanda, bozzoli, seta, cavaliere leggero.
- Nuovo test `test_saraceni`; tutti i 22 test OK. Versione 0.26.0. Prossimo: step 22 Normanni.

## 2026-11-02 — step 22 Normanni giocabili (Fase 4)
- Piano in docs/normanni.md. Normanni in `Popoli.DATI` (contro i Saraceni, cavalieri pesanti, confini +2 per torri e castelli); allevamento di cavalli (grano e acqua → cavalli) e mastio (costa cavalli, raggio 13). Le guardie dei forti ora hanno l'aspetto del soldato del proprio popolo.
- 20 modelli nuovi (subagente). Nuovo test `test_normanni`; tutti i 23 test OK. Versione 0.27.0. I cinque popoli sono tutti giocabili. Prossimo: step 23 campagna finale.

## 2026-11-02 — step 23 campagna finale «La Soglia» (Fase 4)
- Piano in docs/soglia.md. Quattro missioni sulla mappa di Monteleone con il popolo scelto all'inizio (pulsante «La Soglia» sulla mappa della Calabria, aperto dopo la campagna dei Greci); la terza missione è la scelta «unire» (12 merci di lusso) o «conquistare» (una torre nemica), che decide il finale dell'ultima.
- Testi originali: il Mercante senza Volto, Rocco della Lira, i due finali. Domande nuove al proprietario: chi è Rocco; il Mac per l'iPhone.
- Nuovo test `test_soglia`; il bot di test_campagna gioca «Il velo sulla Soglia» fino in fondo. Tutti i 24 test OK. Versione 0.28.0.

## 2026-11-02 — step 24 iPhone, prima parte: comandi touch
- `CameraMappa`: un dito trascina la mappa, due dita pizzicano per lo zoom, il tocco lungo (0,6 s fermo) annulla come il tasto destro. `partita.gd`: il clic del dito vale quando si alza e solo se non era un trascinamento o un tocco lungo.
- Nuovo test `test_touch`; tutti i 25 test OK. Versione 0.29.0. L'esportazione iOS aspetta la risposta del proprietario sul Mac; prossimo: Fase 6 (Sicilia).

## 2026-11-02 — step 25 mappa della Sicilia «Zancle e l'Etna» (Fase 6)
- Nuovo generatore `genera_zancle` con le coste vere (Patti, Tindari, Milazzo, Capo Peloro, Messina, Taormina, Acireale, Catania) e la punta della Calabria oltre lo Stretto; Peloritani, Nebrodi, Etna con neve, terra nera e cratere.
- Il villaggio è stato spostato due volte: prima la dorsale dei Peloritani ci passava sopra, poi Zancle era sulla riva con il magazzino in acqua. Ora sta tra i due mari, come la Messina vera.
- Nuovo test `test_zancle`; tutti i 26 test OK. Versione 0.30.0. Prossimo: step 26 Siculi e Sicani.

## 2026-11-02 — step 26 Siculi e Sicani (Fase 6)
- Piano in docs/siculi_sicani.md. Due popoli nuovi giocabili: Siculi (bottega del vasaio → ceramiche, pastori più svelti, guerrieri con lancia) e Sicani (laboratorio dell'ossidiana → lame, cave e miniere più svelte, arcieri), nemici l'uno dell'altro.
- `Popoli.durata(mestiere)` usata dal lavoratore. Modelli dei due popoli fatti da due subagenti uno dopo l'altro.
- Nuovo test `test_sicilia_popoli`; tutti i 27 test OK. Versione 0.31.0. Prossimo: step 27, campagna siciliana.

## 2026-11-02 — step 27 campagna «Il fuoco sotto la montagna» (Fase 6)
- Piano in docs/fuoco.md. Sei missioni a Zancle con il popolo della Soglia: la traversata, Zancle, i vasai di Pantalica, la neve dell'Etna (la cenere brucia i campi), il vento delle Eolie, il cuore del fuoco (finale secondo la scelta della Soglia).
- `Missione.CAMPAGNE`: Greci → Soglia → Sicilia, ognuna si apre finita la precedente. Il bot di test_campagna ora traccia strade e costruisce più edifici uguali: gioca «La traversata» e «Il naufragio» fino in fondo.
- Nuovo test `test_fuoco`; tutti i 28 test OK. Versione 0.32.0. Prossimo: step 28, navi e porti sullo Stretto.

## 2026-11-02 — step 28 lo Stretto: navi e porti (Fase 6)
- Porto per tutti i popoli: riceve anfore, una nave a vela salpa e va fino a un altro porto del giocatore (rotta sul mare casella per casella, attraverso lo Stretto) o al largo, e torna con i ducati.
- Modelli `porto` e `nave` (8 direzioni × 8 fotogrammi) fatti da un subagente. Trovato nel test: un porto fuori dai confini viene perso, come ogni edificio (corretto).
- Nuovo test `test_stretto`; tutti i 29 test OK. Versione 0.33.0. Prossimo: step 29, finale nuovo.

## 2026-11-02 — step 29 epilogo «L'ultimo canto» (Fase 6 finita)
- Una missione dopo la Sicilia, a Monteleone: porto sul golfo, tre viaggi della nave, 150 coloni; il Mercante chiama Rocco «padre» e Rocco si svela: è Italo (scelta provvisoria, domanda aperta al proprietario; registrata in decisioni.md).
- Per poter fare il porto vicino a Monteleone: approdo pianeggiante a Vibo Marina nel generatore (prima la costa era solo rupi e bosco), porto fino a 5 caselle dal mare. Il bot dei test ora riprova a piazzare gli edifici.
- Nuovo test `test_finale`; tutti i 30 test OK. Versione 0.34.0. Prossimo: domande per la Fase 5 e rifinitura G6.

## 2026-11-02 — step G6a: tutti gli edifici dei Brettii
- Domande per la Fase 5 (Coral Island) scritte al proprietario.
- 24 modelli brettii nuovi (subagente): miniere, zecca, fonderia, fabbro, armaiolo, vigneto, cantina, frantoio, porto e gli altri. Nuovo test `test_aspetto`.
- Test toccati (aspetto, brettii, catena, metallo, guerra) OK; il codice del gioco non è cambiato. Versione 0.35.0. Prossimo: G6b Romani.

## 2026-11-02 — step G6b: tutti gli edifici dei Romani
- 24 modelli nuovi `<tipo>_romani` (subagente) per gli edifici che avevano ancora l'aspetto greco; popolo aggiunto a `COMPLETI` in `test_aspetto`.
- Test toccati OK; il codice del gioco non è cambiato. Versione 0.36.0. Prossimo: G6c Saraceni.

## 2026-11-02 — step G6c: tutti gli edifici dei Saraceni
- 24 modelli nuovi `<tipo>_saraceni` (subagente) per gli edifici che avevano ancora l'aspetto greco; popolo aggiunto a `COMPLETI` in `test_aspetto`.
- Test toccati OK; il codice del gioco non è cambiato. Versione 0.37.0. Prossimo: G6d Normanni.

## 2026-11-02 — step G6d: tutti gli edifici dei Normanni
- 24 modelli nuovi `<tipo>_normanni` (subagente) per gli edifici che avevano ancora l'aspetto greco; popolo aggiunto a `COMPLETI` in `test_aspetto`.
- Test toccati OK; il codice del gioco non è cambiato. Versione 0.38.0. Prossimo: G6e Siculi.

## 2026-11-02 — step G6e: tutti gli edifici dei Siculi
- 24 modelli nuovi `<tipo>_siculi` (subagente) per gli edifici che avevano ancora l'aspetto greco; popolo aggiunto a `COMPLETI` in `test_aspetto`.
- Test toccati OK; il codice del gioco non è cambiato. Versione 0.39.0. Prossimo: G6f Sicani.

## 2026-11-02 — step G6f: tutti gli edifici dei Sicani
- 24 modelli nuovi `<tipo>_sicani` (subagente) per gli edifici che avevano ancora l'aspetto greco; popolo aggiunto a `COMPLETI` in `test_aspetto`.
- Test toccati OK; il codice del gioco non è cambiato. Versione 0.40.0. Prossimo: bilanciamento e sfide.

## 2026-11-02 — sfide
- Tre sfide dalle «Modalità libere» di storia.md (nutri 200 abitanti, la seta da un mare all'altro, sopravvivi all'alluvione): senza sconfitta, perché il proprietario vuole partite senza limite di tempo; il cronometro segna il record, visibile nel menu e nel pannello.
- Menu: «Campagne» e «Sfide». Nuovo test `test_sfide`; il bot gioca «Sopravvivi all'alluvione». Tutti i 32 test OK. Versione 0.41.0.

## 2026-11-02 — bilanciamento
- `test_durata` con `POPOLO`: mezz'ora di gioco per ognuno dei sette popoli, tutte stabili; la catena di base rende quasi uguale (55–59 merci ogni 5 minuti). Risultati in docs/bilanciamento.md. Versione 0.42.0.

## 2026-11-02 — le Eolie sulla mappa della campagna
- Promesse allo step 25 e poi dimenticate: le sette isole Eolie disegnate con le coordinate vere, con il fuoco di Stromboli; il pulsante dell'epilogo spostato sul mar Ionio. Test della campagna OK. Versione 0.43.0.

## 2026-11-02 — colori dei Brettii del giocatore
- `brettio(squadra)` e fogli `brettio_giocatore`: i guerrieri brettii del giocatore hanno le fasce del giocatore, i nemici quelle rosse. Test toccati OK. Versione 0.44.0.

## 2026-11-02 — piano dell'update «Le guerre di Annibale» (idee da Imperivm)
- Richiesta del proprietario: unire le idee e la dinamica di Imperivm: le guerre puniche, con grafica nuova, senza rovinare il lavoro fatto. Ricerca sul gioco (villaggi da conquistare, popolazione che produce, eroi con eserciti, cibo che cura, morale, navi, assedi).
- Piano in docs/piano-imperivm.md: Fase 7 (step 30–40), regola «niente si rompe», tema storico coerente (Annibale nel Bruzio con i Brettii). Quattro domande al proprietario; si comincia dai villaggi indigeni.

## 2026-11-02 — risposte del proprietario e step 30 villaggi indigeni (Fase 7)
- Il proprietario ha confermato tutte le scelte consigliate (decisioni.md): Rocco è Italo, iPhone rimandato, FluidSynth per la musica, controllo diretto delle schiere, Cartaginesi con elefanti, prima Fase 7 poi Fase 5 come modalità «Vita del villaggio».
- Step 30: tre villaggi indigeni per mappa nella partita libera, che crescono; con i doni diventano alleati, fuori dalla pace si conquistano con soldati e un forte vicino. Trovato nel test: a Pizzo e sulle Serre non c'era posto per il bosco: ora il villaggio sgombera la natura.
- Nuovo test `test_indigeni`; tutti i 33 test OK. Versione 0.45.0. Prossimo: step 31 condottieri e schiere.

## 2026-11-02 — step 31 condottieri e schiere (Fase 7)
- `Schiere`: il condottiero del popolo esce con fino a 12 soldati di riserva; si comanda con il clic (muovi, attacca torri nemiche e villaggi indigeni); duelli con le regole della guerra; cerchio di selezione e barra della forza. Solo partita libera, non in pace.
- Sette condottieri (Eudora, Tauro, Gaio Settimio, Zahra, Osmund, Duketio, Kokalo) disegnati da un subagente. Trovato nel test: la torre conquistata viene liberata, il bersaglio va controllato con `is_instance_valid`.
- Nuovo test `test_schiere`; tutti i 34 test OK. Versione 0.46.0. Prossimo: step 32.

## 2026-11-02 — step 32 cibo, morale ed esperienza (Fase 7)
- Le schiere prendono 20 razioni dal magazzino e le consumano; senza cibo perdono soldati e morale; vicino al magazzino si riforniscono e si rinforzano. Morale e livello del condottiero (1–5) cambiano i duelli; barre e livello disegnati sopra il condottiero; esperienza nel salvataggio.
- Nuovo test `test_morale`; `test_schiere` ora dà il pane alla schiera. Tutti i 35 test OK. Versione 0.47.0. Prossimo: step 33 tipi di unità.

## 2026-11-02 — step 33 tipi di unità (Fase 7)
- Fanteria, tiratori e cavalleria per popolo con vantaggi incrociati (+/− 0,15) nei duelli della guerra di oggi e delle schiere; i tiratori si fermano a distanza e tirano, con sassi e frecce disegnati in volo; polvere nei corpo a corpo.
- Nuovo test `test_tipi`; tutti i 36 test OK. Versione 0.48.0. Prossimo: step 34 abilità dei condottieri.

## 2026-11-02 — step 34 abilità dei condottieri (Fase 7)
- Due abilità per popolo (ai livelli 2 e 4, ricarica 60 s): falange e canto di Eudora, passo di montagna e imboscata, disciplina e testuggine, carica rapida e grido del deserto, giuramento e carica pesante, grido degli antenati e lance lunghe, rifugio sui monti e pioggia di frecce. Pannello della schiera in basso al centro, tasti 1 e 2.
- Nuovo test `test_abilita`; tutti i 37 test OK. Versione 0.49.0. Prossimo: step 35 navi da guerra e traversate.

## 2026-11-02 — step 35 navi da guerra e traversate (Fase 7)
- `Mare` (rotte sull'acqua), traversata delle schiere tra due nostri porti, `NaviGuerra` (armate al porto, bersagliano le torri nemiche sulla costa finché non hanno difensori). Bireme disegnata da un subagente; mentre lavorava, i test sono girati in una copia della cartella per non usare Godot in due nello stesso progetto.
- Nuovo test `test_navi`; tutti i test OK (il test di durata non è stato rifatto: lo step non tocca le partite in pace). Versione 0.50.0. Lo script dei documenti era fallito dopo il merge del codice: versione e documenti aggiunti con un commit a parte. Prossimo: step 36 assedi.

### 2026-11-02 — Fase 5 rimandata
- Il proprietario: personaggi, feste, cura del mare, collezioni e museo «per ora no», in una versione successiva.
- Nuovo `docs/idee-future.md` (con l'iPhone); roadmap, decisioni, stato, memoria e passaggio di consegne aggiornati.
- Per finire il gioco restano: step 36–40, musica nuova, chiusura con la versione 1.0.

### 2026-11-02 — Step 36a: costruttori al cantiere (v0.51.0)
- Richiesta del proprietario: i cantieri come in Settlers, con chi va a costruirli.
- `Costruttore` (dal magazzino, martella sul fianco del cantiere, torna a lavoro finito o se il cantiere è demolito); modelli col mazzuolo e il berretto arancione.
- Suoni di lavoro udibili solo vicino (1000 px). Mandati al proprietario musiche ed effetti da ascoltare.
- Test nuovo `test_costruttori`; aggiornati `test_popolazione` (testo del pannello) e `test_salvataggio` (conta i costruttori). 39 test OK, compreso `test_durata`.

### 2026-11-02 — Step 36b: voce di re Italo (v0.52.0)
- Il proprietario ha scelto la voce inventata (libera da diritti).
- `tools/suoni/voce.py`: 20 sillabe a formanti (voce bassa, vibrato, tremolio d'anziano); `Audio.parla()` le mette in fila sotto le battute di Rocco della Lira.
- Test nuovo `test_voce`; esempio `esempio_voce_italo.wav` mandato al proprietario.

### 2026-11-02 — Step 36: assedi (v0.53.0)
- Mura sulle torri nemiche (crescono col tempo, barra di pietre sopra la torre); prima delle mura niente duelli.
- Ariete e onagro dall'armaiolo, seguono la schiera; modelli fatti da un subagente.
- Corretto un errore vecchio (schiera sciolta durante l'ultimo duello). Test nuovo `test_assedi`; 41 test OK.

### 2026-11-02 — Step 37: i Cartaginesi (v0.54.0)
- Ottavo popolo: nemici i Romani, mercenari, porto che rende il doppio, tintoria della porpora, stalla degli elefanti, Annibale.
- Elefante da guerra come unità speciale nella schiera (dalla stalla).
- Modelli in tre file separati, fatti da tre subagenti in parallelo in tre worktree (nessun conflitto su `modelli.gd`).

### 2026-11-02 — Step 38: mappa del Bruzio (v0.55.0)
- La Calabria centrale da coordinate vere: i due mari, l'istmo, la Sila, le Serre, l'Aspromonte, Crotone e Locri.
- Villaggio nel Marchesato vicino a Crotone; villaggi indigeni Petelia, Scolacium, Consentia.
- Scritta mentre i subagenti disegnavano i Cartaginesi (worktree separati). Test nuovo `test_bruzio`.

### 2026-11-02 — Step 39: campagna «Annibale nel Bruzio» (v0.56.0)
- Otto missioni nel Bruzio, dai due lati (Cartagine o Roma), con racconti diversi per lato.
- Schiere e villaggi indigeni accesi nelle missioni che lo chiedono; prove nuove.
- Pulsanti sulla mappa della Calabria e scelta del lato. Test nuovo `test_annibale`.

### 2026-11-02 — GitHub e step 40 (v0.57.0)
- Lo spazio di Actions era finito (artifact a 90 giorni): workflow riscritto in un solo job su Windows senza artifact, solo per i push su main; esito nel ramo `ci-esito`. Prima compilazione verde (esecuzione 130, release v0.56.0).
- Step 40: modelli dei 4 villaggi indigeni (12, subagente), macerie delle mura crollate. **Fase 7 finita.**
- Il proprietario cancella a mano le release vecchie (le cancellazioni definitive non posso farle io).

### 2026-11-02 — Musica nuova (v0.58.0)
- Scaricati FluidSynth 2.6.2 e GeneralUser GS (licenza libera anche commerciale) in `C:\Users\User\Tools`.
- `tools/suoni/musica_fluid.py`: quattro brani originali (mattino, lavoro, sera, guerra) scritti come MIDI e resi in Ogg.
- In battaglia parte la musica di guerra, dopo 25 s di calma torna quella del villaggio. Test nuovo `test_musica`.

### 2026-11-02 — Versione 1.0.0
- Crediti completi nel menu, README della 1.0.
- Prova completa delle 28 missioni con il giocatore automatico; corretto quello che è venuto fuori.
- Tutti i test verdi; versione 1.0.0 pubblicata.

### 2026-11-03 — Fase 8 chiesta dal proprietario
- Quattordici richieste (interfaccia, montagna, torri, stagioni, suoni, merci e magazzini, comignoli, pionieri, mappe più grandi, rovine): raccolte negli step 43–51.

### 2026-11-05 — Verifica finale Fase 8 e release v1.1.0
- Eseguite le 48 suite Godot: passate dopo aggiornamenti dei test per mappe 144×144, coloni che restano nelle case, neve montana e magazzino da 200; corretta la radura iniziale di Zancle e la pendenza per le miniere.
- README e preset Windows aggiornati a 1.1.0; inclusi nell'export gli atlas SVG dei coloni.
- Release ancora in preparazione: completare export, push/merge su `main` e verificare Actions, tag `v1.1.0` e Setup.exe.
- GitHub Actions run 135 (`4c0655c`) completata con successo; Release `v1.1.0` pubblicata con `TerreDiCalabria-Setup-1.1.0.exe` caricato (126.743.026 byte).
- Esito `ci-esito`: `success`; export Windows x64 e ARM64 e compilazione Inno Setup riusciti.
- Documenti di handoff e stato sviluppo aggiornati alla release pubblicata.

### 2026-11-06 — Step 54: correzioni da schermate (v1.1.1)
- Ingresso degli edifici cercato lungo tutto il perimetro; bandierine stradali invisibili fuori dallo strumento Collegamento; pannello Costruisci realmente richiudibile.
- Raggio del magazzino iniziale portato a 13 caselle e quello delle torri a 9; costruzione in montagna e prova della miniera di ferro verificate.
- Coloni/lavoratori ridimensionati, abiti differenziati e animazioni di camminata/lavoro ritoccate; guardie ridotte senza toccare navi e macchine.
- Salvataggi preservano ingressi, rete stradale e mappa dei territori; tutte le 49 suite Godot, import e screenshot visuale passano.
- Release Windows ARM64/x64 in preparazione; merge/push e verifica di Actions e asset in attesa del commit finale.

### 2026-11-06 — Pubblicazione della release v1.1.1
- Merge su `main`: `de5cb45b61310e03390d3bd187f16c34e8aa4839`; GitHub Actions run 137 completato con successo per export ARM64/x64 e Setup.
- Tag `v1.1.1` pubblicato con `TerreDiCalabria-Setup-1.1.1.exe` (123.645.878 byte): https://github.com/danylbd/terre-di-calabria/releases/tag/v1.1.1.
- Il ramo `ci-esito` riporta `success` e lo stesso commit; tutte le 49 suite Godot erano verdi prima del merge.

### 2026-11-06 — Step 55: correzioni visive raccolte dopo v1.1.1
- Pannello Costruisci ancorato in alto, riapertura dentro lo schermo e contenuti scorrevoli nelle finestre basse.
- Coloni: ciclo del passo impostato in loop, partenze sfalsate e ritmo legato alla velocità, mantenendo gli atlas 8×8 originali.
- Luoghi: cartigli con fondo scuro nascosti per impostazione predefinita e mostrati soltanto vicino al cursore.
- Test mirati visuale e atlas coloni passano; worktree step 55 resta separato, senza merge o release mentre il proprietario raccoglie altri bug.
- Rete stradale: alberi e ulivi sono attraversabili e vengono sgombrati sul sedime, mentre rocce ed edifici restano ostacoli.
- Gli innesti vicini riusano la bandierina esistente; la ricerca prova uscite alternative quando i primi accessi sono bloccati.
- Nuova suite `test_rete_strade.gd`: passano percorso nel bosco, rimozione dell’albero, split del tratto e giunzione a tre segmenti.
