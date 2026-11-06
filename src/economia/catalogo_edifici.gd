class_name CatalogoEdifici
## Elenco degli edifici costruibili (Greci) con taglia, costo, categoria e descrizione.
## taglia = lato dell'impronta in caselle: 1 (pozzo), 2 (la maggior parte), 3 (magazzino).

const CATEGORIE := ["Base", "Cibo", "Metallo", "Difesa", "Speciali"]
const EDIFICI_SPECIALI := ["tempio_proserpina", "foro_valentia", "duomo"]

const EDIFICI := {
	"casa_greca": {"nome": "Abitazione", "taglia": 2, "costo": {"assi": 2, "pietra": 2}, "categoria": "Base",
		"tempo": 20.0, "abitanti": 8,
		"descrizione": "Ospita 8 coloni e ne fa nascere di nuovi. Vino, agrumi e miele in magazzino li fanno crescere più in fretta."},
	"boscaiolo": {"nome": "Boscaiolo", "taglia": 2, "costo": {"assi": 2}, "categoria": "Base",
		"tempo": 16.0, "attrezzo": "ascia", "lavoratore": "lavoratore_ascia", "produce": "tronchi",
		"descrizione": "Abbatte gli alberi vicini e porta i tronchi."},
	"guardaboschi": {"nome": "Guardaboschi", "taglia": 2, "costo": {"assi": 2}, "categoria": "Base",
		"tempo": 16.0, "attrezzo": "pala", "lavoratore": "lavoratore_pala",
		"descrizione": "Pianta nuovi alberi, così il bosco non finisce."},
	"segheria": {"nome": "Segheria", "taglia": 2, "costo": {"assi": 2, "pietra": 2}, "categoria": "Base",
		"tempo": 24.0, "attrezzo": "sega", "lavoratore": "portatore_nessuno", "ingressi": {"tronchi": 4}, "produce": "assi",
		"descrizione": "Taglia i tronchi e ne ricava assi."},
	"cava": {"nome": "Cava di pietra", "taglia": 2, "costo": {"assi": 2}, "categoria": "Base",
		"tempo": 16.0, "attrezzo": "piccone", "lavoratore": "lavoratore_piccone", "produce": "pietra",
		"descrizione": "Estrae pietra dalle rocce vicine."},
	"magazzino": {"nome": "Magazzino", "taglia": 3, "costo": {"assi": 6, "pietra": 6}, "categoria": "Base",
		"tempo": 40.0, "abitanti": 24, "descrizione": "Custodisce le merci. I portatori partono da qui."},
	"pozzo": {"nome": "Pozzo", "taglia": 1, "costo": {"pietra": 2}, "categoria": "Cibo",
		"tempo": 12.0, "lavoratore": "portatore_nessuno", "produce": "acqua",
		"descrizione": "Acqua per il forno e per il bestiame."},
	"fattoria": {"nome": "Fattoria", "taglia": 2, "costo": {"assi": 3, "pietra": 1}, "categoria": "Cibo",
		"tempo": 20.0, "attrezzo": "falce", "lavoratore": "lavoratore_falce", "produce": "grano", "coltura": "grano",
		"descrizione": "Il contadino semina i campi di grano intorno e li miete quando sono dorati."},
	"mulino": {"nome": "Mulino", "taglia": 2, "costo": {"assi": 2, "pietra": 3}, "categoria": "Cibo",
		"tempo": 24.0, "lavoratore": "portatore_nessuno", "ingressi": {"grano": 4}, "produce": "farina",
		"descrizione": "Macina il grano e ne fa farina."},
	"forno": {"nome": "Forno", "taglia": 2, "costo": {"assi": 2, "pietra": 3}, "categoria": "Cibo",
		"tempo": 24.0, "lavoratore": "portatore_nessuno", "ingressi": {"farina": 4, "acqua": 4}, "produce": "pane",
		"descrizione": "Impasta farina e acqua e cuoce il pane."},
	"porcile": {"nome": "Porcile", "taglia": 2, "costo": {"assi": 3, "pietra": 1}, "categoria": "Cibo",
		"tempo": 20.0, "lavoratore": "portatore_nessuno", "ingressi": {"grano": 2, "acqua": 2}, "produce": "maiale",
		"durata": 12.0, "descrizione": "Alleva maiali nutriti con grano e acqua."},
	"macelleria": {"nome": "Macelleria", "taglia": 2, "costo": {"assi": 2, "pietra": 2}, "categoria": "Cibo",
		"tempo": 22.0, "lavoratore": "portatore_nessuno", "ingressi": {"maiale": 2}, "produce": "carne",
		"descrizione": "Ricava carne e salumi dai maiali."},
	"ovile": {"nome": "Ovile", "taglia": 2, "costo": {"assi": 3, "pietra": 1}, "categoria": "Cibo",
		"tempo": 20.0, "lavoratore": "portatore_nessuno", "ingressi": {"acqua": 2}, "produce": ["latte", "lana"],
		"durata": 10.0, "descrizione": "Le pecore danno latte e lana. Bevono molto."},
	"capraio": {"nome": "Capraio", "taglia": 2, "costo": {"assi": 2, "pietra": 1}, "categoria": "Cibo",
		"tempo": 18.0, "lavoratore": "portatore_nessuno", "produce": "latte", "durata": 12.0,
		"descrizione": "Le capre si arrangiano da sole e danno latte."},
	"apiario": {"nome": "Apiario", "taglia": 2, "costo": {"assi": 2}, "categoria": "Cibo",
		"tempo": 16.0, "lavoratore": "portatore_nessuno", "produce": "miele", "durata": 14.0,
		"descrizione": "Le arnie danno miele dai fiori dei prati."},
	"raccoglitore_funghi": {"nome": "Raccoglitore di porcini", "taglia": 2, "costo": {"assi": 2}, "categoria": "Cibo",
		"tempo": 18.0, "attrezzo": "pala", "lavoratore": "lavoratore_pala", "produce": "porcini",
		"descrizione": "Raccoglie porcini nei boschi vicini. I funghi ricrescono col tempo."},
	"caseificio": {"nome": "Caseificio", "taglia": 2, "costo": {"assi": 2, "pietra": 2}, "categoria": "Cibo",
		"tempo": 22.0, "lavoratore": "portatore_nessuno", "ingressi": {"latte": 4}, "produce": "formaggio",
		"descrizione": "Fa il formaggio con il latte di pecore e capre."},
	"argillaio": {"nome": "Argillaio", "taglia": 2, "costo": {"assi": 2}, "categoria": "Base",
		"tempo": 16.0, "attrezzo": "pala", "lavoratore": "portatore_nessuno", "produce": "argilla", "durata": 7.0,
		"vicino_mare": 4, "descrizione": "Cava l'argilla dalla riva. Va costruito vicino al mare."},
	"fornace": {"nome": "Fornace", "taglia": 2, "costo": {"assi": 2, "pietra": 3}, "categoria": "Base",
		"tempo": 24.0, "lavoratore": "portatore_nessuno", "ingressi": {"argilla": 4, "tronchi": 2}, "produce": "anfore",
		"durata": 8.0, "descrizione": "Cuoce l'argilla e fa le anfore dipinte, ricercate al mercato."},
	"saline": {"nome": "Saline", "taglia": 2, "costo": {"assi": 2, "pietra": 1}, "categoria": "Cibo",
		"tempo": 18.0, "lavoratore": "portatore_nessuno", "produce": "sale", "durata": 9.0, "vicino_mare": 3,
		"descrizione": "Vasche dove il mare evapora e lascia il sale. Vanno costruite sulla costa."},
	"tessitura": {"nome": "Tessitura", "taglia": 2, "costo": {"assi": 3, "pietra": 1}, "categoria": "Cibo",
		"tempo": 20.0, "lavoratore": "portatore_nessuno", "ingressi": {"lana": 4}, "produce": "stoffa", "durata": 8.0,
		"descrizione": "Fila e tesse la lana: la stoffa è un lusso che fa crescere il villaggio."},
	"agora": {"nome": "Agorà", "popolo": "greci", "taglia": 3, "costo": {"assi": 6, "pietra": 8}, "categoria": "Base",
		"tempo": 45.0, "lavoratore": "portatore_nessuno", "vende": 8, "produce": "", "durata": 6.0,
		"descrizione": "La piazza del mercato dei Greci: vende olio, vino, anfore, stoffa e altro in cambio di ducati, e con i ducati compra quello che scegli."},
	"tempio_proserpina": {"nome": "Tempio di Proserpina", "taglia": 3, "costo": {}, "prezzo_ducati": 90, "categoria": "Speciali",
		"tempo": 52.0, "descrizione": "Un tempio dedicato a Proserpina, acquistabile al mercato."},
	"foro_valentia": {"nome": "Foro di Valentia", "taglia": 3, "costo": {}, "prezzo_ducati": 180, "categoria": "Speciali",
		"tempo": 64.0, "descrizione": "Un grande foro civico, acquistabile al mercato."},
	"duomo": {"nome": "Duomo di Santa Maria Maggiore", "taglia": 3, "costo": {}, "prezzo_ducati": 300, "categoria": "Speciali",
		"tempo": 74.0, "descrizione": "Il duomo di Valentia, acquistabile al mercato."},
	"pescatore": {"nome": "Pescatore", "taglia": 2, "costo": {"assi": 2}, "categoria": "Cibo",
		"tempo": 16.0, "attrezzo": "canna", "lavoratore": "lavoratore_canna", "produce": "pesce", "vicino_mare": 5,
		"descrizione": "Pesca dalla riva. Il pesce finisce e torna col tempo: costruiscilo vicino al mare."},
	"frantoio": {"nome": "Frantoio", "taglia": 2, "costo": {"assi": 2, "pietra": 2}, "categoria": "Cibo",
		"tempo": 24.0, "lavoratore": "portatore_nessuno", "ingressi": {"olive": 4}, "produce": "olio",
		"descrizione": "Spreme le olive e produce olio."},
	"uliveto": {"nome": "Raccoglitore di olive", "taglia": 2, "costo": {"assi": 2}, "categoria": "Cibo",
		"tempo": 16.0, "attrezzo": "falce", "lavoratore": "lavoratore_falce", "produce": "olive",
		"descrizione": "Raccoglie le olive dagli ulivi vicini. Gli ulivi rimettono frutto col tempo."},
	"vigneto": {"nome": "Vigneto", "taglia": 2, "costo": {"assi": 3, "pietra": 1}, "categoria": "Cibo",
		"tempo": 20.0, "attrezzo": "falce", "lavoratore": "lavoratore_falce", "produce": "uva", "coltura": "vite",
		"descrizione": "Pianta le viti, che danno uva ogni anno."},
	"cantina": {"nome": "Cantina", "taglia": 2, "costo": {"assi": 2, "pietra": 3}, "categoria": "Cibo",
		"tempo": 24.0, "lavoratore": "portatore_nessuno", "ingressi": {"uva": 4}, "produce": "vino",
		"descrizione": "Pigia l'uva e fa il vino, merce di lusso."},
	"ortolano": {"nome": "Ortolano", "taglia": 2, "costo": {"assi": 2, "pietra": 1}, "categoria": "Cibo",
		"tempo": 18.0, "attrezzo": "falce", "lavoratore": "lavoratore_falce", "produce": ["ortaggi", "cipolle"], "coltura": "orto",
		"descrizione": "Coltiva ortaggi e cipolle rosse: cibo per i minatori."},
	"agrumeto": {"nome": "Agrumeto", "taglia": 2, "costo": {"assi": 3, "pietra": 1}, "categoria": "Cibo",
		"tempo": 20.0, "attrezzo": "falce", "lavoratore": "lavoratore_falce", "produce": "agrumi", "coltura": "agrumi",
		"descrizione": "Pianta aranci e bergamotti, che danno frutta ogni anno."},
	"pesca_spada": {"nome": "Barca del pesce spada", "taglia": 2, "costo": {"assi": 4}, "categoria": "Cibo",
		"tempo": 20.0, "attrezzo": "canna", "lavoratore": "lavoratore_canna", "produce": "pesce_spada", "vicino_mare": 5,
		"descrizione": "Esce in barca al largo per il pesce spada. Va costruita sulla costa."},
	"miniera_ferro": {"nome": "Miniera di ferro", "taglia": 2, "costo": {"assi": 4, "pietra": 1}, "categoria": "Metallo",
		"tempo": 24.0, "attrezzo": "piccone", "lavoratore": "lavoratore_piccone", "produce": "ferro", "durata": 8.0,
		"miniera": "ferro", "cibo": 4,
		"descrizione": "Scava il ferro nei monti. Va costruita sulla roccia, ai piedi della montagna. I minatori lavorano solo se mangiano (pane, pesce, carne, formaggio, ortaggi o cipolle)."},
	"miniera_argento": {"nome": "Miniera d'argento", "taglia": 2, "costo": {"assi": 4, "pietra": 1}, "categoria": "Metallo",
		"tempo": 24.0, "attrezzo": "piccone", "lavoratore": "lavoratore_piccone", "produce": "argento", "durata": 10.0,
		"miniera": "argento", "cibo": 4,
		"descrizione": "Scava l'argento, più raro del ferro, nella roccia dei monti. I minatori lavorano solo se mangiano."},
	"zecca": {"nome": "Zecca", "taglia": 2, "costo": {"assi": 2, "pietra": 4}, "categoria": "Metallo",
		"tempo": 28.0, "lavoratore": "portatore_nessuno", "ingressi": {"argento": 4, "carbone": 4}, "produce": "ducati",
		"durata": 7.0, "descrizione": "Fonde l'argento e conia i ducati per il commercio."},
	"armaiolo": {"nome": "Armaiolo", "taglia": 2, "costo": {"assi": 2, "pietra": 3}, "categoria": "Metallo",
		"tempo": 26.0, "attrezzo": "martello", "lavoratore": "portatore_nessuno", "ingressi": {"lingotti": 4, "assi": 2},
		"produce": "armi", "durata": 9.0, "descrizione": "Forgia lance, scudi ed elmi per gli opliti."},
	"pecificio": {"nome": "Pecificio", "popolo": "brettii", "taglia": 2, "costo": {"assi": 2, "pietra": 2}, "categoria": "Base",
		"tempo": 18.0, "lavoratore": "portatore_nessuno", "ingressi": {"tronchi": 2}, "produce": "pece", "durata": 8.0,
		"descrizione": "Cuoce la resina dei pini della Sila e ne ricava la pece: un lusso dei Brettii che fa crescere le case."},
	"laterizi": {"nome": "Fornace dei laterizi", "popolo": "romani", "taglia": 2, "costo": {"assi": 2, "pietra": 3}, "categoria": "Base",
		"tempo": 20.0, "lavoratore": "portatore_nessuno", "ingressi": {"argilla": 2, "tronchi": 1}, "produce": "tegole", "durata": 8.0,
		"descrizione": "Cuoce l'argilla in mattoni e tegole: con un tetto di tegole le case dei Romani crescono più in fretta."},
	"bachicoltura": {"nome": "Bachicoltura", "popolo": "saraceni", "taglia": 2, "costo": {"assi": 2, "pietra": 1}, "categoria": "Base",
		"tempo": 18.0, "lavoratore": "portatore_nessuno", "produce": "bozzoli", "durata": 9.0,
		"descrizione": "Tra i gelsi si allevano i bachi, che filano i bozzoli di seta."},
	"filanda": {"nome": "Filanda", "popolo": "saraceni", "taglia": 2, "costo": {"assi": 3, "pietra": 2}, "categoria": "Base",
		"tempo": 20.0, "lavoratore": "portatore_nessuno", "ingressi": {"bozzoli": 2}, "produce": "seta", "durata": 8.0,
		"descrizione": "Dipana i bozzoli nell'acqua calda e fila la seta: un lusso che fa crescere le case dei Saraceni."},
	"allevamento_cavalli": {"nome": "Allevamento di cavalli", "popolo": "normanni", "taglia": 2, "costo": {"assi": 3, "pietra": 2}, "categoria": "Cibo",
		"tempo": 20.0, "lavoratore": "portatore_nessuno", "ingressi": {"grano": 2, "acqua": 1}, "produce": "cavalli", "durata": 10.0,
		"descrizione": "Cresce i cavalli dei cavalieri con grano e acqua: servono per alzare il mastio."},
	"vasaio": {"nome": "Bottega del vasaio", "popolo": "siculi", "taglia": 2, "costo": {"assi": 2, "pietra": 2}, "categoria": "Base",
		"tempo": 18.0, "lavoratore": "portatore_nessuno", "ingressi": {"argilla": 2, "tronchi": 1}, "produce": "ceramiche", "durata": 8.0,
		"descrizione": "Al tornio e al forno nascono vasi e giare dipinte: un lusso che fa crescere le case dei Siculi."},
	"ossidiana": {"nome": "Laboratorio dell'ossidiana", "popolo": "sicani", "taglia": 2, "costo": {"assi": 2, "pietra": 3}, "categoria": "Base",
		"tempo": 18.0, "lavoratore": "portatore_nessuno", "ingressi": {"pietra": 2}, "produce": "lame", "durata": 8.0,
		"descrizione": "Scheggia il vetro nero dei vulcani in lame taglienti e specchi: il lusso dei Sicani."},
	"tintoria_porpora": {"nome": "Tintoria della porpora", "popolo": "cartaginesi", "taglia": 2, "costo": {"assi": 2, "pietra": 3}, "categoria": "Base",
		"tempo": 20.0, "lavoratore": "portatore_nessuno", "ingressi": {"pesce": 2, "acqua": 1}, "produce": "porpora", "durata": 9.0,
		"descrizione": "Dalle conchiglie del murice si ricava la porpora che tinge le stoffe: il lusso dei Cartaginesi."},
	"stalla_elefanti": {"nome": "Stalla degli elefanti", "popolo": "cartaginesi", "taglia": 2, "costo": {"assi": 4, "pietra": 3}, "categoria": "Difesa",
		"tempo": 24.0, "lavoratore": "portatore_nessuno", "ingressi": {"grano": 3, "acqua": 2}, "produce": "elefanti", "durata": 16.0,
		"descrizione": "Nutre gli elefanti di Annibale con grano e acqua: da qui escono gli elefanti da guerra che seguono la schiera."},
	"porto": {"nome": "Porto", "taglia": 2, "costo": {"assi": 4, "pietra": 4}, "categoria": "Base",
		"tempo": 24.0, "lavoratore": "portatore_nessuno", "ingressi": {"anfore": 2}, "produce": "ducati", "durata": 4.0,
		"vicino_mare": 5, "descrizione": "Una nave carica le anfore e va a venderle oltre il mare (o fino a un altro tuo porto, attraverso lo Stretto) e torna con i ducati."},
	"carbonaia": {"nome": "Carbonaia", "taglia": 2, "costo": {"assi": 2, "pietra": 1}, "categoria": "Metallo",
		"tempo": 18.0, "lavoratore": "portatore_nessuno", "ingressi": {"tronchi": 4}, "produce": "carbone", "durata": 9.0,
		"descrizione": "Cuoce lentamente i tronchi sotto la terra e ne ricava carbone."},
	"fonderia": {"nome": "Fonderia", "taglia": 2, "costo": {"assi": 2, "pietra": 4}, "categoria": "Metallo",
		"tempo": 28.0, "lavoratore": "portatore_nessuno", "ingressi": {"ferro": 4, "carbone": 4}, "produce": "lingotti",
		"durata": 7.0, "descrizione": "Fonde il ferro con il carbone e cola i lingotti."},
	"fabbro": {"nome": "Fabbro", "taglia": 2, "costo": {"assi": 2, "pietra": 3}, "categoria": "Metallo",
		"tempo": 26.0, "attrezzo": "martello", "lavoratore": "portatore_nessuno", "ingressi": {"lingotti": 4, "assi": 2},
		"produce": "attrezzi", "durata": 8.0,
		"descrizione": "Forgia gli attrezzi dei mestieri. Fa per primi quelli che mancano."},
	"torre": {"nome": "Torre di guardia", "taglia": 2, "costo": {"assi": 2, "pietra": 4}, "categoria": "Difesa",
		"tempo": 30.0, "territorio": 9, "presidio": 1, "lavoratore": "guardia", "soldati_max": 2,
		"descrizione": "Allarga i confini solo quando la guardia entra. Può ospitare 2 soldati."},
	"casa_pionieri": {"nome": "Casa dei pionieri", "taglia": 2, "costo": {"assi": 4, "pietra": 3}, "categoria": "Difesa",
		"tempo": 32.0, "lavoratore": "portatore_nessuno", "descrizione": "Da qui partono i pionieri per fondare avamposti e allargare il territorio."},
	"castello": {"nome": "Castello", "taglia": 3, "costo": {"assi": 6, "pietra": 12}, "categoria": "Difesa",
		"tempo": 60.0, "territorio": 11, "presidio": 1, "lavoratore": "guardia", "soldati_max": 8,
		"descrizione": "Fortezza di pietra: allarga molto i confini quando è presidiata. Ospita 8 soldati."},
	"mastio": {"nome": "Mastio", "popolo": "normanni", "taglia": 3, "costo": {"assi": 6, "pietra": 14, "cavalli": 2}, "categoria": "Difesa",
		"tempo": 70.0, "territorio": 13, "presidio": 1, "lavoratore": "guardia", "soldati_max": 10,
		"descrizione": "La grande torre dei Normanni: allarga moltissimo i confini quando è presidiata. Ospita 10 soldati."},
	"caserma": {"nome": "Caserma", "taglia": 2, "costo": {"assi": 3, "pietra": 4}, "categoria": "Difesa",
		"tempo": 30.0, "lavoratore": "portatore_nessuno", "ingressi": {"armi": 4}, "produce": "", "durata": 10.0,
		"descrizione": "Addestra gli opliti: un colono libero e un'armatura diventano un soldato, che va a presidiare i forti."},
	"torre_brettia": {"nome": "Torre dei Brettii", "taglia": 2, "costo": {}, "categoria": "Nemici",
		"tempo": 1.0, "territorio": 7,
		"descrizione": "Avamposto dei Brettii, il popolo delle montagne. I suoi guerrieri difendono la porta."},
}

const NOMI_RISORSE := {"tronchi": "Tronchi", "assi": "Assi", "pietra": "Pietra", "grano": "Grano",
	"farina": "Farina", "acqua": "Acqua", "pane": "Pane", "pesce": "Pesce", "maiale": "Maiali", "carne": "Carne",
	"latte": "Latte", "lana": "Lana", "formaggio": "Formaggio", "miele": "Miele", "olive": "Olive", "olio": "Olio",
	"uva": "Uva", "vino": "Vino", "ortaggi": "Ortaggi", "cipolle": "Cipolle", "agrumi": "Agrumi",
	"pesce_spada": "Pesce spada", "ferro": "Ferro", "carbone": "Carbone", "pece": "Pece", "tegole": "Tegole", "bozzoli": "Bozzoli", "seta": "Seta", "cavalli": "Cavalli", "porpora": "Porpora", "elefanti": "Elefanti", "ceramiche": "Ceramiche", "lame": "Lame di ossidiana", "lingotti": "Lingotti",
	"ascia": "Asce", "piccone": "Picconi", "pala": "Pale", "falce": "Falci", "canna": "Canne da pesca", "sega": "Seghe",
	"martello": "Martelli", "argilla": "Argilla", "anfore": "Anfore", "sale": "Sale", "argento": "Argento",
	"ducati": "Ducati", "stoffa": "Stoffa", "armi": "Armi", "porcini": "Porcini"}
## all'agorà: ducati ricavati vendendo una merce (i Greci sono buoni mercanti: prezzi favorevoli)
const VENDITA := {"tronchi": 1, "assi": 2, "pietra": 1, "grano": 1, "farina": 1, "acqua": 1, "pane": 2, "pesce": 2,
	"maiale": 2, "carne": 3, "latte": 1, "lana": 2, "formaggio": 3, "miele": 3, "olive": 1, "olio": 4, "uva": 1,
	"vino": 4, "ortaggi": 1, "cipolle": 1, "agrumi": 2, "pesce_spada": 3, "ferro": 2, "carbone": 1, "lingotti": 4,
	"argilla": 2, "anfore": 4, "sale": 2, "argento": 5, "stoffa": 4, "armi": 5, "pece": 4, "tegole": 3, "bozzoli": 1,
	"seta": 5, "cavalli": 5, "porpora": 6, "ceramiche": 4, "lame": 4, "porcini": 5}
## all'agorà: ducati per comprare una merce
const ACQUISTO := {"grano": 1, "pesce": 1, "tronchi": 1, "pietra": 1, "assi": 1, "argilla": 1, "ferro": 2, "carbone": 1,
	"lingotti": 3, "lana": 1, "farina": 1, "acqua": 1, "pane": 2, "carne": 3, "formaggio": 3, "olio": 4, "vino": 4,
	"anfore": 3, "sale": 2}
## attrezzi dei mestieri: senza l'attrezzo in magazzino l'artigiano non arriva
const ATTREZZI := ["ascia", "piccone", "pala", "falce", "canna", "sega", "martello"]
const ATTREZZO_UNO := {"ascia": "un'ascia", "piccone": "un piccone", "pala": "una pala", "falce": "una falce",
	"canna": "una canna da pesca", "sega": "una sega", "martello": "un martello"}
## cibo che i minatori accettano (uno qualsiasi per ogni turno di lavoro)
const CIBI := ["pane", "pesce", "carne", "formaggio", "ortaggi", "cipolle"]
## merci di lusso: fanno nascere i coloni più in fretta
const LUSSO := ["vino", "agrumi", "miele", "stoffa", "pece", "tegole", "seta", "ceramiche", "lame", "porpora"]
## merci sempre visibili nella barra delle scorte (le altre compaiono quando ce ne sono)
const RISORSE_BASE := ["tronchi", "assi", "pietra"]


static func dati(tipo: String) -> Dictionary:
	return EDIFICI[tipo]


## Gli edifici di una categoria; con un popolo, senza gli edifici unici degli altri popoli.
static func della_categoria(cat: String, popolo := "") -> Array:
	var r := []
	for k in EDIFICI:
		if popolo != "" and EDIFICI[k].get("popolo", popolo) != popolo:
			continue
		if EDIFICI[k]["categoria"] == cat:
			r.append(k)
	return r


## Merci "una qualsiasi tra queste" che un edificio accetta: [elenco, quante in tutto], o [] se nessuna.
## Il cibo dei minatori e le merci da vendere all'agorà.
static func gruppo(tipo: String) -> Array:
	var d: Dictionary = EDIFICI[tipo]
	if d.has("cibo"):
		return [CIBI, d["cibo"]]
	if d.has("vende"):
		return [VENDITA.keys(), d["vende"]]
	return []


## Quante merci di un tipo può tenere un edificio per lavorare (ingressi, più il gruppo "una qualsiasi").
static func capacita(tipo: String, merce: String) -> int:
	var d: Dictionary = EDIFICI[tipo]
	var n: int = d.get("ingressi", {}).get(merce, 0)
	var g := gruppo(tipo)
	if not g.is_empty() and merce in g[0]:
		n += g[1]
	return n


## Tutte le merci che un edificio riceve per lavorare.
static func merci_in_ingresso(tipo: String) -> Array:
	var d: Dictionary = EDIFICI[tipo]
	var r: Array = d.get("ingressi", {}).keys()
	var g := gruppo(tipo)
	if not g.is_empty():
		r.append_array(g[0])
	return r


## Le merci che un edificio produce (alcuni ne fanno più d'una, a turno).
static func prodotti(tipo: String) -> Array:
	var p = EDIFICI[tipo].get("produce", [])
	return p if p is Array else [p]


static func testo_costo(tipo: String) -> String:
	var parti := []
	var c: Dictionary = EDIFICI[tipo]["costo"]
	for r in c:
		parti.append("%d %s" % [c[r], NOMI_RISORSE[r].to_lower()])
	return ", ".join(parti)
