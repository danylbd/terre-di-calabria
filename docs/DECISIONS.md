# Decisioni tecniche e di lavoro

*Le decisioni di **gioco** del proprietario (visuale, stile, popoli, guerra, ducati, Monteleone, Sicilia...) sono in [`decisioni.md`](decisioni.md) e non si ripetono qui. Questo file raccoglie le scelte tecniche e di metodo, con il motivo e le alternative scartate. «Provvisoria» = da confermare.*

| Data | Decisione | Motivo | Alternative scartate |
|---|---|---|---|
| 2026-10 | Godot 4 + GDScript | motore libero, export Windows ARM64, 2D isometrico comodo | Unity (licenza), motore scritto da zero (troppo lavoro) |
| 2026-10 | Grafica **generata** da modelli 3D scritti in codice e fotografati in isometria (`tools/studio`) | qualità costante, tutto originale, rigenerabile; nessun artista disponibile | sprite disegnati a mano (lenti, incoerenti), asset di altri giochi (vietato) |
| 2026-10 | Uno step per ramo `step-XX-nome` in un worktree, merge `--no-ff` in `main`, release automatica | storia leggibile, `main` sempre funzionante | lavoro diretto su `main` |
| 2026-10-31 | Test automatici come script `extends SceneTree` (`tools/test/`), accelerati con `Engine.time_scale`, con screenshot opzionale | verificano davvero il gioco senza intervento umano | test solo manuali |
| 2026-10-31 | Classe statica `Suono` al posto dell'autoload `Audio` negli script | con `--script` l'autoload non è visibile al compilatore e i test non partono | rinunciare ai test con l'audio |
| 2026-10-31 | Suoni e musica sintetizzati in Python (solo libreria standard) — **provvisoria per la musica** | nessuno strumento audio sul PC | FluidSynth + soundfont (serve installarlo: domanda al proprietario), musicista (spesa) |
| 2026-10-31 | Il portatore riprende subito la merce di ritorno al capo dove l'ha appena posata | dimezza i viaggi a vuoto | rientrare sempre a metà tratto |
| 2026-10-31 | Chi produce senza materie prime si ferma oltre 6 in magazzino; chi trasforma oltre 12 se nessuno chiede; assi e ducati mai | evita strade intasate e materie prime bruciate (carbonaia) | nessun tetto (ingorghi), tetto anche alle assi (bloccava il tutorial) |
| 2026-10-31 | Un produttore si ferma solo per le **sue** merci in attesa alla bandierina (`Merce.origine`) | gli incroci trafficati bloccavano i produttori | contare tutte le merci alla bandierina |
| 2026-11-01 | Coloni contati: ogni portatore, lavoratore e soldato prende un colono; le case danno posti e nascite | economia di popolazione come nei classici del genere | portatori infiniti |
| 2026-11-01 | Salvataggio: la mappa si rigenera dal seme, si salvano solo le cose che cambiano (JSON) | file piccoli, semplice | salvare tutta la mappa |
| 2026-11-01 | Territorio con proprietario per casella; una casella non si ruba finché il vecchio proprietario la copre | i confini cambiano solo con la conquista | «vince il più vicino» (rubava terre senza combattere) |
| 2026-11-01 | `guerra.gd` unico per i due lati (giocatore e Brettii) | stesso combattimento, meno codice | due sistemi separati |
| 2026-11-01 | Missioni descritte come dati (`Missione.MISSIONI`) con obiettivi generici; test con un giocatore automatico | aggiungere missioni senza nuovo codice; ogni missione è verificata | una scena per missione |
| 2026-11-01 | Mappa della Calabria disegnata in codice dalle coordinate geografiche reali (x = 700 + (lon − 15,6)·360, y = 30 + (40,15 − lat)·455) | forma reale chiesta dal proprietario, senza immagini esterne | immagine disegnata a mano, forma stilizzata (prima versione) |
| 2026-11-01 | Monete rinominate **ducati** anche nel codice (`ducati`), con conversione dei salvataggi vecchi | coerenza tra codice e testi | cambiare solo i testi |
| 2026-11-01 | Un solo agente in continuo; turno orario disattivato | un turno orario aveva avviato una seconda sessione sullo stesso worktree | turni orari automatici |
| 2026-11-01 | Test lunghi in primo piano, a gruppi sotto i 10 minuti | i comandi in background lasciavano il lavoro fermo | test in background |
| 2026-11-01 | Memoria del progetto in documenti (`PROJECT_MEMORY`, `DEVELOPMENT_STATUS`, `DECISIONS`, `SESSION_HANDOFF`) + CLAUDE.md corto | riprendere dopo chiusure e compattazioni senza rispiegare | tutto in CLAUDE.md (diventava lungo) |
| 2026-11-01 | Romani: edificio unico = fornace dei laterizi (non il cantiere stradale); strade lastricate = abilità sempre attiva (+15% ai portatori) | più semplice e leggibile; il cantiere stradale potrà arrivare con la campagna dei Romani (provvisoria) | cantiere stradale che lastrica le strade a mano (rimandato) |
