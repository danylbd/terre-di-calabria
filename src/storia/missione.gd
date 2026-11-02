class_name Missione
extends Node
## Una missione della campagna: racconto d'apertura, obiettivi da raggiungere uno dopo l'altro
## (ognuno con un suggerimento, a volte con un evento e qualche battuta quando si compie),
## racconto di chiusura. I testi sono originali del gioco.

signal dialogo(battute: Array)       # [[chi, testo], ...]: il pannello le mostra una alla volta
signal obiettivo_cambiato
signal compiuta

## file dei progressi della campagna (i test ne usano un altro)
static var progressi := "user://campagna.json"
const CAMPAGNA_GRECI := ["naufragio", "pane_straniero", "uliveto", "citta_sorelle", "ira_del_fiume", "voce_del_mare"]
## la campagna finale (docs/soglia.md): si apre finita quella dei Greci, con il popolo scelto all'inizio
const CAMPAGNA_SOGLIA := ["soglia_velo", "soglia_frammenti", "soglia_scelta", "soglia_sigillo"]
## il seguito in Sicilia (docs/fuoco.md): si apre finita la Soglia, con lo stesso popolo
const CAMPAGNA_FUOCO := ["fuoco_traversata", "fuoco_zancle", "fuoco_vasai", "fuoco_etna", "fuoco_eolie", "fuoco_cuore"]
## l'epilogo (docs/ultimo_canto.md): il Sigillo intero torna sulla Soglia, e Rocco si svela
const CAMPAGNA_FINALE := ["ultimo_canto"]
const CAMPAGNE := [CAMPAGNA_GRECI, CAMPAGNA_SOGLIA, CAMPAGNA_FUOCO, CAMPAGNA_FINALE]
## la campagna di Annibale (step 39, docs/annibale.md): sempre aperta, sulla mappa del Bruzio, giocabile dai
## due lati (Roma o Cartagine con i Brettii); le schiere e i villaggi indigeni ci sono
const CAMPAGNA_ANNIBALE := ["annibale_sbarco", "annibale_brettii", "annibale_condottiero", "annibale_petelia",
	"annibale_lacinio", "annibale_marchesato", "annibale_due_mari", "annibale_partenza"]
const LATI_ANNIBALE := ["cartaginesi", "romani"]
## le sfide (docs/sfide.md): sempre aperte, senza sconfitta; il cronometro segna il record
const SFIDE := ["sfida_200", "sfida_seta", "sfida_alluvione"]

const MISSIONI := {
	# ---------------------------------------------------- la campagna di Annibale (step 39, docs/annibale.md)
	"annibale_sbarco": {
		"titolo": "Il porto di Crotone",
		"popolo": "lato", "mappa": "bruzio", "villaggio": "pieno", "coloni": 40, "schiere": true, "indigeni": true,
		"scorte": {"tronchi": 24, "assi": 40, "pietra": 40, "grano": 8, "pesce": 8},
		"inizio": {
			"cartaginesi": [
				["Rocco della Lira", "Ascoltate, ascoltate... Questa è una storia vera, o quasi. Dopo Canne, Annibale scese a sud, nella terra dei Brettii, e ci restò tanti anni quanti ne ha un ragazzo che diventa uomo."],
				["Annibale", "Crotone ha un buon porto e campi d'argilla che danno grano. Da qui arriveranno le navi di Cartagine. Costruite, e in fretta."],
			],
			"romani": [
				["Rocco della Lira", "Ascoltate, ascoltate... Dopo Canne, Roma tremava. E Annibale scese a sud, nella terra dei Brettii. Ma qualcuno, a Crotone, teneva ancora alta l'aquila."],
				["Gaio Settimio", "Crotone è la chiave dello Ionio. Se Annibale prende il porto, da Cartagine gli arriveranno uomini ed elefanti. Fortifichiamola."],
			],
		},
		"obiettivi": [
			{"testo": "Fai crescere il villaggio fino a 50 coloni", "aiuto": "Abitazioni, cibo e il lusso del tuo popolo: le case crescono più in fretta.", "prova": "popolazione", "n": 50},
			{"testo": "Costruisci il porto", "aiuto": "Nel menu «Base», sulla riva vicino a Crotone. Le navi portano anfore e tornano con i ducati.", "prova": "edificio", "tipo": "porto"},
		],
		"fine": {
			"cartaginesi": [["Annibale", "Le vele entrano nel golfo. Da oggi il Bruzio non è più una trappola: è una casa."]],
			"romani": [["Gaio Settimio", "Il porto è nostro. Che Annibale guardi pure il mare: non ne arriverà niente."]],
		},
	},
	"annibale_brettii": {
		"titolo": "I popoli della Sila",
		"popolo": "lato", "mappa": "bruzio", "villaggio": "pieno", "coloni": 50, "schiere": true, "indigeni": true,
		"scorte": {"tronchi": 24, "assi": 40, "pietra": 40, "grano": 8, "pesce": 8, "vino": 4, "olio": 4},
		"inizio": {
			"cartaginesi": [
				["Rocco della Lira", "I Brettii scendevano dalla Sila con le loro pecore e le loro fionde. Roma li aveva umiliati, e non l'avevano dimenticato."],
				["Annibale", "Un esercito lontano da casa vive dei suoi amici. Portate doni ai villaggi: Petelia, Consentia, Scolacium. Chi mangia il nostro pane combatte con noi."],
			],
			"romani": [
				["Rocco della Lira", "I Brettii scendevano dalla Sila con le loro pecore e le loro fionde. Annibale prometteva loro la libertà; Roma, la pace."],
				["Gaio Settimio", "Le città del Bruzio guardano chi vince. Facciamo loro vedere che Roma sa anche donare, non solo comandare."],
			],
		},
		"obiettivi": [
			{"testo": "Fai alleato (o conquista) un villaggio del Bruzio", "aiuto": "Clic su un villaggio indigeno: con i doni di lusso diventa alleato, con i soldati si conquista.", "prova": "villaggi", "n": 1},
			{"testo": "Fai crescere il villaggio fino a 70 coloni", "aiuto": "Gli alleati mandano parte del loro raccolto al tuo magazzino.", "prova": "popolazione", "n": 70},
		],
		"fine": [["Rocco della Lira", "Il villaggio mandò grano e formaggio. E con il formaggio, come sempre, arrivarono le notizie: l'altro esercito si stava muovendo."]],
	},
	"annibale_condottiero": {
		"titolo": "La schiera",
		"popolo": "lato", "mappa": "bruzio", "villaggio": "pieno", "coloni": 60, "schiere": true, "indigeni": true, "brettii": true,
		"scorte": {"tronchi": 24, "assi": 50, "pietra": 50, "grano": 10, "pesce": 10, "pane": 20, "armi": 10},
		"inizio": {
			"cartaginesi": [
				["Annibale", "I Romani hanno alzato torri sulle colline, a ovest. Non le prenderemo con i portatori. Mi serve una schiera vera, che marci con me."],
			],
			"romani": [
				["Gaio Settimio", "I Brettii di Annibale hanno torri sulle colline, a ovest. Una legione non si improvvisa: caserma, armi, e poi in marcia."],
			],
		},
		"obiettivi": [
			{"testo": "Forma una schiera di almeno 10 soldati", "aiuto": "Caserma (o castello) e armi dall'armaiolo: i soldati di riserva escono con il condottiero (pulsante «Schiera»).", "prova": "schiera", "n": 10},
			{"testo": "Conquista una torre nemica con la schiera", "aiuto": "Clic sul condottiero, poi sulla torre. Prima vanno giù le mura, poi si combatte.", "prova": "conquiste", "n": 1},
		],
		"fine": [["Rocco della Lira", "Quella sera il condottiero contò i suoi uomini, uno per uno. Ne mancavano. Ma la torre era presa, e dalla torre si vedeva il mare dall'altra parte."]],
	},
	"annibale_petelia": {
		"titolo": "L'assedio di Petelia",
		"popolo": "lato", "mappa": "bruzio", "villaggio": "pieno", "coloni": 60, "schiere": true, "indigeni": true, "brettii": true,
		"scorte": {"tronchi": 30, "assi": 60, "pietra": 50, "grano": 10, "pesce": 10, "pane": 30, "armi": 14},
		"inizio": {
			"cartaginesi": [
				["Rocco della Lira", "Petelia, sulla sua rupe, restò fedele a Roma. Mangiarono le erbe, poi il cuoio degli scudi. Le storie dicono undici mesi."],
				["Annibale", "Le mura nemiche si fanno più alte ogni giorno che aspettiamo. Ariete e onagro, dall'armaiolo. Non lasceremo il tempo di finirle."],
			],
			"romani": [
				["Rocco della Lira", "Petelia, sulla sua rupe, restò fedele a Roma, e Annibale la strinse d'assedio. Ma questa volta la storia la scrivete voi."],
				["Gaio Settimio", "I nemici si sono chiusi dietro le mura. Gli ingegneri dicono: un ariete per le porte, un onagro per i merli. All'armaiolo."],
			],
		},
		"obiettivi": [
			{"testo": "Fai costruire una macchina d'assedio", "aiuto": "All'armaiolo, con una schiera in campo: l'ariete sfonda da vicino, l'onagro tira da lontano.", "prova": "macchina", "n": 1},
			{"testo": "Conquista due torri nemiche", "aiuto": "Mura giù con le macchine, poi i duelli. Tieni la schiera vicino al magazzino per le razioni.", "prova": "conquiste", "n": 2},
		],
		"fine": [["Rocco della Lira", "Quando le mura caddero, uscirono uomini magri come rami d'inverno. Chi vinse non fece festa: ci sono vittorie che si guardano in silenzio."]],
	},
	"annibale_lacinio": {
		"titolo": "Il tempio sul capo",
		"popolo": "lato", "mappa": "bruzio", "villaggio": "pieno", "coloni": 70, "schiere": true, "indigeni": true,
		"scorte": {"tronchi": 30, "assi": 50, "pietra": 50, "grano": 12, "pesce": 12},
		"inizio": {
			"cartaginesi": [
				["Rocco della Lira", "Sul capo Lacinio c'era il tempio di Hera, con una sola colonna che oggi guarda ancora il mare. Annibale vi lasciò un'iscrizione in due lingue: le sue imprese, raccontate da lui."],
				["Annibale", "Un condottiero muore. Le parole restano. Portiamo al tempio doni degni: porpora, vino, olio."],
			],
			"romani": [
				["Rocco della Lira", "Sul capo Lacinio c'era il tempio di Hera, ricco di doni di tutto il mondo greco. Chi lo onorava, onorava Crotone."],
				["Gaio Settimio", "La gente di Crotone ci guarderà diversamente, se vedrà Roma salire al tempio con le mani piene."],
			],
		},
		"obiettivi": [
			{"testo": "Metti da parte 14 merci di lusso per il tempio", "aiuto": "Il lusso del tuo popolo (porpora, tegole, vino, olio...) resta in magazzino come dono.", "prova": "lusso", "n": 14},
			{"testo": "Fai crescere il villaggio fino a 100 coloni", "aiuto": "Più abitazioni, più cibo, più lusso.", "prova": "popolazione", "n": 100},
		],
		"fine": [["Rocco della Lira", "Il vento del capo portava via le parole, ma non quelle scolpite. Le iscrizioni del Lacinio, dicono, le lesse anche uno storico greco, cinquant'anni dopo."]],
	},
	"annibale_marchesato": {
		"titolo": "La rocca del Marchesato",
		"popolo": "lato", "mappa": "bruzio", "villaggio": "pieno", "coloni": 70, "schiere": true, "indigeni": true, "brettii": true,
		"scorte": {"tronchi": 30, "assi": 70, "pietra": 80, "grano": 12, "pesce": 12, "pane": 30, "armi": 12},
		"inizio": {
			"cartaginesi": [["Annibale", "Roma non ci attacca: ci aspetta. Ogni anno ci toglie una città. Allora costruiamo una rocca che non si toglie."]],
			"romani": [["Gaio Settimio", "Annibale non perde battaglie. Allora non gliene daremo: rocche, granai, pazienza. Lo chiamano il metodo di Fabio, il Temporeggiatore."]],
		},
		"obiettivi": [
			{"testo": "Costruisci un castello e presidialo", "aiuto": "Nel menu «Difesa». Servono molte assi e pietre; una guardia lo presidia.", "prova": "forti", "n": 1},
			{"testo": "Fai salire il condottiero al livello 3", "aiuto": "Il condottiero cresce con i duelli vinti dalla sua schiera.", "prova": "condottiero_livello", "n": 3},
		],
		"fine": [["Rocco della Lira", "Dalla rocca si vedeva tutto il Marchesato, giallo d'estate e verde d'inverno. E si vedeva, lontano, il fumo dell'altro campo."]],
	},
	"annibale_due_mari": {
		"titolo": "Tra i due mari",
		"popolo": "lato", "mappa": "bruzio", "villaggio": "pieno", "coloni": 80, "schiere": true, "indigeni": true, "brettii": true,
		"scorte": {"tronchi": 30, "assi": 70, "pietra": 70, "grano": 14, "pesce": 14, "pane": 40, "armi": 16},
		"inizio": [
			["Rocco della Lira", "Tra Scolacium e Terina la Calabria si stringe come una vita sottile: trenta chilometri, e dall'alto si vedono tutti e due i mari. Chi tiene l'istmo, tiene il Bruzio."],
		],
		"obiettivi": [
			{"testo": "Fai tuoi (alleati o conquistati) due villaggi del Bruzio", "aiuto": "Doni di lusso o soldati: Petelia, Scolacium, Consentia.", "prova": "villaggi", "n": 2},
			{"testo": "Conquista due torri nemiche", "aiuto": "Schiera, macchine d'assedio e razioni.", "prova": "conquiste", "n": 2},
		],
		"fine": [["Rocco della Lira", "Sull'istmo si piantarono le insegne. Da una parte il Tirreno, dall'altra lo Ionio: e in mezzo, per una stagione, la pace di chi ha vinto."]],
	},
	"annibale_partenza": {
		"titolo": "L'ultima estate",
		"popolo": "lato", "mappa": "bruzio", "villaggio": "pieno", "coloni": 90, "schiere": true, "indigeni": true, "brettii": true,
		"scorte": {"tronchi": 30, "assi": 80, "pietra": 80, "grano": 16, "pesce": 16, "pane": 40, "armi": 20},
		"inizio": {
			"cartaginesi": [
				["Rocco della Lira", "Era il 203 avanti Cristo. Da Cartagine arrivò l'ordine: tornare a casa, perché Roma era sbarcata in Africa."],
				["Annibale", "Sedici anni in Italia, e nessuno mi ha battuto in campo. Ma la guerra non si vince solo in campo. Prima di partire, che i Romani ricordino il Bruzio."],
			],
			"romani": [
				["Rocco della Lira", "Era il 203 avanti Cristo. Scipione era sbarcato in Africa, e Cartagine richiamava il suo generale."],
				["Gaio Settimio", "Annibale se ne va da Crotone, ma i suoi alleati restano sulle colline. Il Bruzio deve tornare tutto sotto l'aquila."],
			],
		},
		"obiettivi": [
			{"testo": "Conquista tutte le torri nemiche", "aiuto": "Schiera, macchine e razioni: le torri rimaste sono a ovest e a sud-ovest.", "prova": "nemici_zero"},
		],
		"fine": {
			"cartaginesi": [
				["Rocco della Lira", "Annibale salpò da Crotone in una mattina d'estate. Dicono che dal ponte guardasse la costa finché diventò una riga, e poi niente."],
				["Annibale", "Ho fatto tremare Roma. Che basti, a chi racconterà."],
				["Rocco della Lira", "E qualcuno, ve lo assicuro, lo racconta ancora. Fine."],
			],
			"romani": [
				["Rocco della Lira", "Annibale salpò da Crotone senza voltarsi. Sulle colline del Bruzio tornò l'aquila, e con l'aquila le strade lastricate."],
				["Gaio Settimio", "Sedici anni. Tanto è durato. Che nessuno dimentichi quanto costa una vittoria."],
				["Rocco della Lira", "E i Brettii? I Brettii tornarono alle loro pecore, sulla Sila. Le montagne, ragazzi, sopravvivono a tutti gli imperi. Fine."],
			],
		},
	},
	"sfida_200": {
		"titolo": "Nutri 200 abitanti",
		"sfida": true, "popolo": "libero", "mappa": "costa_ionica", "villaggio": "pieno", "coloni": 40,
		"scorte": {"tronchi": 30, "assi": 60, "pietra": 60, "grano": 10, "pesce": 10},
		"inizio": [["Rocco della Lira", "Una sfida, ragazzi: quanto ci mettete a far vivere duecento persone in questo villaggio? Il tempo corre, ma nessuno vi caccia: si può giocare con calma, il record aspetta."]],
		"obiettivi": [
			{"testo": "Fai crescere il villaggio fino a 200 coloni", "aiuto": "Abitazioni, tanto cibo e il lusso del tuo popolo: le case con il lusso fanno nascere i coloni più in fretta.", "prova": "popolazione", "n": 200},
		],
		"fine": [["Rocco della Lira", "Duecento! Ho contato i comignoli due volte. Il tempo è scritto nel libro dei record."]],
	},
	"sfida_seta": {
		"titolo": "La seta da un mare all'altro",
		"sfida": true, "popolo": "saraceni", "mappa": "zancle", "villaggio": "pieno", "coloni": 40,
		"scorte": {"tronchi": 30, "assi": 50, "pietra": 50, "grano": 8, "pesce": 8, "anfore": 6},
		"inizio": [["Rocco della Lira", "Una sfida per i Saraceni di Zancle: filare la seta e mandare le navi sui due mari. Quanto ci mettete?"]],
		"obiettivi": [
			{"testo": "Fila 6 matasse di seta", "aiuto": "Bachicoltura per i bozzoli, filanda per la seta.", "prova": "prodotti", "tipo": "filanda", "n": 6},
			{"testo": "Fai fare 3 viaggi alla nave di un porto", "aiuto": "Il porto vuole anfore: costruiscilo vicino al mare.", "prova": "prodotti", "tipo": "porto", "n": 3},
		],
		"fine": [["Rocco della Lira", "Le vele sono tornate, la seta è stesa al sole. Il record è vostro... finché qualcuno non fa meglio."]],
	},
	"sfida_alluvione": {
		"titolo": "Sopravvivi all'alluvione",
		"sfida": true, "popolo": "libero", "mappa": "costa_ionica", "villaggio": "pieno", "coloni": 40,
		"scorte": {"tronchi": 24, "assi": 40, "pietra": 40, "grano": 6, "pesce": 10},
		"inizio": [["Rocco della Lira", "Le fiumare sono gonfie: semina, e preparati a ricominciare. Quanto ci metti a rimettere in piedi i campi?"]],
		"obiettivi": [
			{"testo": "Semina 8 campi di grano", "aiuto": "Costruisci una o più fattorie.", "prova": "campi", "coltura": "grano", "n": 8, "evento": "alluvione",
				"dopo": [["Rocco della Lira", "Ed ecco l'acqua! Dei campi non resta niente. Coraggio: si risemina."]]},
			{"testo": "Raccogli 10 covoni dopo l'alluvione", "aiuto": "Il contadino risemina da solo.", "prova": "prodotti", "tipo": "fattoria", "n": 10},
		],
		"fine": [["Rocco della Lira", "Il grano è di nuovo alto. L'acqua passa, la gente resta."]],
	},
	"ultimo_canto": {
		"titolo": "L'ultimo canto",
		"popolo": "scelto", "mappa": "monteleone", "villaggio": "pieno", "costa": true, "coloni": 60,
		"scorte": {"tronchi": 30, "assi": 60, "pietra": 60, "grano": 10, "pesce": 10, "anfore": 8},
		"inizio": [
			["Rocco della Lira", "Ascoltate, ascoltate... per l'ultima volta. Il Sigillo è intero, e batte come un cuore. Ma non è il suo posto, la Sicilia: deve tornare sulla Soglia, dove i due mari quasi si toccano."],
			["Rocco della Lira", "Una nave lo porterà dallo Stretto fino al golfo. E il nostro popolo, sul colle di Monteleone, gli preparerà una casa degna."],
		],
		"obiettivi": [
			{"testo": "Costruisci un porto sul golfo", "aiuto": "Nel menu «Base», vicino al mare. La nave del Sigillo ha bisogno di un approdo.", "prova": "edificio", "tipo": "porto"},
			{"testo": "Fai fare tre viaggi alla nave del porto", "aiuto": "Il porto vuole anfore (fornace e argillaio): ogni viaggio porta a casa un pezzo di storia.", "prova": "prodotti", "tipo": "porto", "n": 3},
			{"testo": "Fai crescere Monteleone fino a 150 coloni", "aiuto": "Tutti i popoli vogliono esserci, il giorno del ritorno.", "prova": "popolazione", "n": 150},
		],
		"fine_unione": [
			["Rocco della Lira", "La nave entrò nel golfo all'alba. Sulla spiaggia c'erano Greci e Brettii, Romani e Saraceni, Normanni, Siculi e Sicani: nessuno aveva un'arma in mano."],
			["Il Mercante senza Volto", "Padre."],
			["Rocco della Lira", "Sì, figlio mio. Io sono Italo. Ho spezzato il Sigillo tremila anni fa, e da allora canto per i popoli che passano, aspettando che imparassero da soli quello che io non sono riuscito a insegnarti."],
			["Rocco della Lira", "Il Sigillo non serve a regnare. Serve a ricordare che questa terra è di chi la lavora insieme. Adesso lo sapete. E io posso posare la lira."],
			["Rocco della Lira", "...ma la lira, ragazzi, lasciatela a qualcuno che sappia suonarla. Le storie non finiscono: cambiano solo chi le canta. Fine."],
		],
		"fine_conquista": [
			["Rocco della Lira", "La nave entrò nel golfo all'alba, scortata da navi da guerra. Sulla spiaggia c'era un solo popolo, e tutti gli altri guardavano da lontano."],
			["Il Mercante senza Volto", "Padre. Hai visto? È andata come con me."],
			["Rocco della Lira", "Sì, figlio mio. Io sono Italo, e ho visto. Il Sigillo è intero, ma pesa come una corona di pietra. Chi lo tiene da solo non riposa mai: tu lo sai meglio di tutti."],
			["Rocco della Lira", "Allora canterò ancora. Canterò finché qualcuno, un giorno, salirà sulla Soglia con gli altri invece che contro. Ascoltate, ascoltate..."],
		],
	},
	"fuoco_traversata": {
		"titolo": "La traversata",
		"popolo": "scelto", "mappa": "zancle", "villaggio": "relitto", "coloni": 30,
		"scorte": {"tronchi": 20, "assi": 30, "pietra": 24, "pesce": 6},
		"inizio": [
			["Rocco della Lira", "Ascoltate, ascoltate... Sulla Soglia il Sigillo si era ricomposto, ma al centro restava un buco, piccolo come un occhio. E io mi ricordai l'ultimo verso del canto, quello che nessuno ascoltava più: «e il cuore del Sigillo lo tenne il fuoco, oltre lo Stretto»."],
			["Rocco della Lira", "Così il nostro popolo caricò le barche e passò tra Scilla e Cariddi, dove l'acqua gira come in una pentola. Arrivarono in pochi, sulla falce di sabbia di Zancle."],
		],
		"obiettivi": [
			{"testo": "Traccia una strada dal magazzino", "aiuto": "Premi «Strada» e collega la bandierina davanti al magazzino.", "prova": "strada"},
			{"testo": "Costruisci un pescatore sullo Stretto", "aiuto": "Nel menu «Cibo». Il mare è a due passi, da tutte e due le parti.", "prova": "edificio", "tipo": "pescatore"},
			{"testo": "Pesca 6 pesci", "aiuto": "I pescatori dello Stretto conoscono le correnti: lascia lavorare.", "prova": "prodotti", "tipo": "pescatore", "n": 6},
			{"testo": "Costruisci due abitazioni", "aiuto": "Assi e pietra: i superstiti della traversata hanno freddo.", "prova": "edificio", "tipo": "casa_greca", "n": 2},
		],
		"fine": [
			["Rocco della Lira", "La prima notte in Sicilia, dalla spiaggia, si vedeva la Calabria: i fuochi di Scilla, così vicini che sembrava di poterli toccare. E a ovest, lontano, una montagna che fumava."],
		],
	},
	"fuoco_zancle": {
		"titolo": "Zancle",
		"popolo": "scelto", "mappa": "zancle", "villaggio": "pieno", "coloni": 40,
		"scorte": {"tronchi": 24, "assi": 40, "pietra": 40, "grano": 6, "pesce": 6},
		"inizio": [
			["Rocco della Lira", "Zancle, la chiamavano: la falce. Il porto è curvo come una lama, e protegge le barche dalle correnti."],
			["Rocco della Lira", "Ma una falce sola non fa una città. Servono case, magazzini, gente."],
		],
		"obiettivi": [
			{"testo": "Fai crescere il villaggio fino a 60 coloni", "aiuto": "Abitazioni collegate e cibo.", "prova": "popolazione", "n": 60},
			{"testo": "Costruisci un secondo magazzino", "aiuto": "Un magazzino più lontano accorcia le strade dei portatori.", "prova": "edificio", "tipo": "magazzino", "n": 2},
		],
		"fine": [
			["Rocco della Lira", "Zancle crebbe sulla sua falce. E un giorno, dalle colline, scesero due uomini con vasi dipinti sulle spalle: i Siculi volevano conoscere i nuovi vicini."],
		],
	},
	"fuoco_vasai": {
		"titolo": "I vasai di Pantalica",
		"popolo": "scelto", "mappa": "zancle", "villaggio": "pieno", "coloni": 50,
		"scorte": {"tronchi": 24, "assi": 40, "pietra": 40, "grano": 8, "pesce": 8},
		"inizio": [
			["Un vasaio siculo", "Noi scaviamo le case dei morti nella roccia di Pantalica, e quelle dei vivi le facciamo d'argilla. Voi che cosa sapete fare?"],
			["Rocco della Lira", "I Siculi non vendono le loro giare a chiunque: vogliono vedere che cosa sa fare un popolo prima di fidarsi."],
		],
		"obiettivi": [
			{"testo": "Metti da parte 8 merci di lusso da scambiare con i Siculi", "aiuto": "Il lusso del tuo popolo (olio, vino, pece, tegole, seta, cavalli, ceramiche...) resta in magazzino.", "prova": "lusso", "n": 8},
			{"testo": "Fai crescere il villaggio fino a 80 coloni", "aiuto": "I Siculi rispettano chi ha un villaggio grande.", "prova": "popolazione", "n": 80},
		],
		"fine": [
			["Un vasaio siculo", "Bene. Allora vi diciamo una cosa che sanno solo i vecchi: sotto la neve dell'Etna c'è un fuoco che non si spegne mai. E nel fuoco, qualcosa che brilla."],
		],
	},
	"fuoco_etna": {
		"titolo": "La neve dell'Etna",
		"popolo": "scelto", "mappa": "zancle", "villaggio": "pieno", "brettii": true, "coloni": 50,
		"scorte": {"tronchi": 24, "assi": 40, "pietra": 40, "grano": 8, "pesce": 8, "armi": 4},
		"inizio": [
			["Rocco della Lira", "Sui fianchi del vulcano la terra è nera e ricchissima. Il grano cresce alto, la vite dà un vino che sa di fumo. Ma la montagna brontola."],
		],
		"obiettivi": [
			{"testo": "Semina 8 campi di grano", "aiuto": "Costruisci una o più fattorie: il contadino semina da solo intorno.", "prova": "campi", "coltura": "grano", "n": 8, "evento": "lava",
				"dopo": [["Rocco della Lira", "Poi l'Etna tossì. Una nuvola di cenere coprì il cielo, e quando la pioggia nera finì, dei campi non restava niente."],
					["Rocco della Lira", "Ma la cenere, l'anno dopo, fa la terra ancora più grassa. Si semina di nuovo."]]},
			{"testo": "Raccogli 6 covoni di grano dopo la cenere", "aiuto": "Il contadino risemina da solo.", "prova": "prodotti", "tipo": "fattoria", "n": 6},
		],
		"fine": [
			["Rocco della Lira", "Il vulcano si calmò. E nella notte, dalla cima, si vide una luce che non era quella della lava: una luce ferma, come una stella caduta."],
		],
	},
	"fuoco_eolie": {
		"titolo": "Il vento delle Eolie",
		"popolo": "scelto", "mappa": "zancle", "villaggio": "pieno", "brettii": true, "coloni": 60,
		"scorte": {"tronchi": 24, "assi": 50, "pietra": 60, "grano": 8, "pesce": 8, "armi": 6},
		"inizio": [
			["Rocco della Lira", "A nord, nel mare, ci sono le isole dei venti: pomice, ossidiana, sale. E dietro una di quelle isole il Mercante senza Volto nascondeva una flotta."],
			["Il Mercante senza Volto", "Siete venuti fin qui? Testardi. I vostri vicini, però, lavorano per me adesso: e le loro torri vi chiudono la strada per il vulcano."],
		],
		"obiettivi": [
			{"testo": "Presidia due forti", "aiuto": "Nel menu «Difesa»: torri, castelli o il mastio.", "prova": "forti", "n": 2},
			{"testo": "Conquista una torre nemica", "aiuto": "Addestra soldati alla caserma e attacca una torre: la strada per l'Etna si apre.", "prova": "conquiste", "n": 1},
		],
		"fine": [
			["Rocco della Lira", "La torre cadde, e dalla sua cima si vedeva il sentiero che sale al vulcano. Il Mercante non c'era già più: era andato avanti, verso il fuoco."],
		],
	},
	"fuoco_cuore": {
		"titolo": "Il cuore del fuoco",
		"popolo": "scelto", "mappa": "zancle", "villaggio": "pieno", "brettii": true, "coloni": 60,
		"scorte": {"tronchi": 30, "assi": 60, "pietra": 70, "grano": 10, "pesce": 10, "armi": 6},
		"inizio": [
			["Rocco della Lira", "Il cuore del Sigillo è lassù, nella bocca dell'Etna. Per arrivarci serve un popolo grande, e forti che proteggano la strada."],
			["Il Mercante senza Volto", "Io lo so che cosa c'è nel cratere. Lo so da tremila anni. Ma da solo non posso prenderlo: il fuoco brucia solo chi è solo."],
		],
		"obiettivi": [
			{"testo": "Fai crescere il villaggio fino a 120 coloni", "aiuto": "Il cuore del Sigillo chiede un popolo grande.", "prova": "popolazione", "n": 120},
			{"testo": "Presidia tre forti lungo la strada del vulcano", "aiuto": "Nel menu «Difesa».", "prova": "forti", "n": 3},
		],
		"fine_unione": [
			["Rocco della Lira", "Salirono in tanti, di tutti i popoli, fino all'orlo del cratere. Il cuore del Sigillo brillava nel fuoco come un seme."],
			["Il Mercante senza Volto", "Sono tornato dal mare per vederlo. Non per prenderlo: solo per vederlo. Mettetelo al suo posto."],
			["Rocco della Lira", "Il Sigillo fu intero, finalmente. Non disse niente: cominciò a battere, piano, come un cuore. E la montagna, per la prima volta da secoli, smise di brontolare. Fine del canto."],
		],
		"fine_conquista": [
			["Rocco della Lira", "Il nostro popolo salì da solo fino al cratere, con le spade ancora sporche. Il cuore del Sigillo brillava nel fuoco."],
			["Il Mercante senza Volto", "Prendetelo, prendetelo. Ma sappiate che il fuoco ricorda chi lo tocca."],
			["Rocco della Lira", "Il Sigillo fu intero, e battè forte, come un tamburo di guerra. La montagna rispose con un boato. Chi regna sulla terra tra due mari, adesso, regna anche sul fuoco... e il fuoco non è un suddito tranquillo. Ricomincio il canto."],
		],
	},
	"soglia_velo": {
		"titolo": "Il velo sulla Soglia",
		"popolo": "scelto", "mappa": "monteleone", "villaggio": "pieno", "coloni": 40,
		"scorte": {"tronchi": 24, "assi": 40, "pietra": 40, "grano": 6, "pesce": 6},
		"inizio": [
			["Rocco della Lira", "Ascoltate, ascoltate... Cinque popoli, cinque frammenti, una sola terra. E in mezzo, dove i due mari quasi si toccano, una striscia di colline che tutti chiamano la Soglia."],
			["Rocco della Lira", "Il nostro popolo è arrivato fin qui, sul colle che guarda il golfo. Di là il Tirreno, di là, oltre le Serre, lo Ionio. Chi tiene questo colle, tiene la porta della Calabria."],
			["Il Mercante senza Volto", "Benvenuti, viaggiatori. Io vendo di tutto: ferro, sale, notizie. E compro una cosa sola... ma di questo parleremo quando sarete più grandi."],
		],
		"obiettivi": [
			{"testo": "Fai crescere il villaggio fino a 60 coloni", "aiuto": "Abitazioni collegate e cibo: le case fanno nascere i coloni, il lusso del tuo popolo le fa crescere più in fretta.", "prova": "popolazione", "n": 60},
			{"testo": "Presidia una torre", "aiuto": "Nel menu «Difesa». Una guardia la presidia e allarga i confini.", "prova": "presidiata",
				"dopo": [["Il Mercante senza Volto", "Una torre! Bene, bene. Chi alza torri ha qualcosa da difendere. E chi ha qualcosa da difendere, prima o poi, ha bisogno di me."]]},
		],
		"fine": [
			["Rocco della Lira", "Il Mercante se ne andò per la strada di Pizzo, senza voltarsi. Ma il suo velo restò negli occhi di tutti, come una nuvola sul sole."],
		],
	},
	"soglia_frammenti": {
		"titolo": "Cinque frammenti, cinque popoli",
		"popolo": "scelto", "mappa": "monteleone", "villaggio": "pieno", "brettii": true, "coloni": 40,
		"scorte": {"tronchi": 24, "assi": 50, "pietra": 60, "grano": 8, "pesce": 8, "armi": 4},
		"inizio": [
			["Rocco della Lira", "I frammenti del Sigillo sono ormai nelle mani di cinque popoli diversi. Ognuno crede di essere l'unico degno di riunirli."],
			["Il Mercante senza Volto", "I vostri vicini hanno alzato torri sul Poro. Io gli ho venduto le pietre, naturalmente. A voi posso vendere le notizie: vi stanno guardando."],
		],
		"obiettivi": [
			{"testo": "Costruisci un castello (o il mastio) e presidialo", "aiuto": "Nel menu «Difesa». Servono molte assi e pietre; una guardia lo presidia.", "prova": "forti", "n": 1},
			{"testo": "Fai crescere il villaggio fino a 100 coloni", "aiuto": "Più abitazioni, più cibo, più lusso.", "prova": "popolazione", "n": 100},
		],
		"fine": [
			["Rocco della Lira", "Dall'alto del castello si vedevano entrambi i mari. E si vedeva anche il fumo dei fuochi nemici sul Poro. La pace, quella notte, sembrò più sottile di un velo."],
		],
	},
	"soglia_scelta": {
		"titolo": "Unire o conquistare",
		"popolo": "scelto", "mappa": "monteleone", "villaggio": "pieno", "brettii": true, "coloni": 50,
		"scorte": {"tronchi": 24, "assi": 50, "pietra": 50, "grano": 8, "pesce": 8, "armi": 6},
		"inizio": [
			["Rocco della Lira", "Viene un giorno, nella vita di ogni popolo, in cui bisogna scegliere che cosa si vuole essere."],
			["Il Mercante senza Volto", "Il frammento dei vostri vicini si può avere in due modi. Con i doni: tanti, preziosi, e pazienza. Oppure con le spade: in fretta, e senza pazienza. Io, per me, vendo a tutti e due."],
		],
		"obiettivi": [
			{"testo": "Scegli: metti da parte 12 merci di lusso da donare ai vicini, oppure conquista una loro torre",
				"aiuto": "Unire: il lusso del tuo popolo (olio, vino, pece, tegole, seta, cavalli...) resta in magazzino come dono. Conquistare: addestra soldati e attacca una torre nemica.",
				"prova": "una_tra", "prove": [
					{"prova": "lusso", "n": 12, "scelta": "unione"},
					{"prova": "conquiste", "n": 1, "scelta": "conquista"},
				]},
		],
		"fine": [
			["Rocco della Lira", "E la scelta fu fatta. Da quel giorno, sulla Soglia, non si parlò d'altro."],
		],
	},
	"soglia_sigillo": {
		"titolo": "Il Sigillo ricomposto",
		"popolo": "scelto", "mappa": "monteleone", "villaggio": "pieno", "brettii": true, "coloni": 60,
		"scorte": {"tronchi": 30, "assi": 60, "pietra": 70, "grano": 10, "pesce": 10, "armi": 6},
		"inizio": [
			["Rocco della Lira", "I cinque frammenti, finalmente, sono sulla Soglia. Manca solo un luogo degno, e un popolo abbastanza grande da custodirli."],
			["Il Mercante senza Volto", "Lo sapete chi sono? No. Nessuno lo sa. Ma quando il Sigillo sarà intero, forse, potrò finalmente riposare."],
		],
		"obiettivi": [
			{"testo": "Fai crescere il villaggio fino a 120 coloni", "aiuto": "Il Sigillo chiede un popolo grande e sazio.", "prova": "popolazione", "n": 120},
			{"testo": "Presidia due forti (torri, castelli o il mastio) per custodire il Sigillo", "aiuto": "Nel menu «Difesa».", "prova": "forti", "n": 2},
		],
		"fine_unione": [
			["Rocco della Lira", "I cinque popoli salirono insieme sulla Soglia, ognuno con il suo frammento. Nessuno parlava. Le mani tremavano un poco."],
			["Rocco della Lira", "Il Sigillo si ricompose, e disse una cosa sola: la terra non appartiene a chi la conquista, ma a chi la lavora."],
			["Il Mercante senza Volto", "Finalmente... Mio padre aveva ragione, sapete? Io non ero degno. Ma voi sì."],
			["Rocco della Lira", "Il Mercante si tolse il velo: aveva il viso di un ragazzo stanco. Camminò verso il mare, e il mare lo prese con dolcezza. Quanto a me... io ho aspettato tanto, tanto tempo di vedere questo giorno. Un re, a volte, deve solo aspettare che i suoi figli imparino. Fine."],
		],
		"fine_conquista": [
			["Rocco della Lira", "Un solo popolo salì sulla Soglia, con cinque frammenti presi uno a uno. Il Sigillo si ricompose, e pesava come una montagna."],
			["Il Mercante senza Volto", "Ecco fatto. Avete vinto. Tenete pure il Sigillo: è vostro, e voi siete suoi."],
			["Rocco della Lira", "Il Mercante se ne andò, ma il suo velo restò per terra. Qualcuno lo raccolse, e se lo mise sul viso. E io... io ricomincio il canto dall'inizio. Ascoltate, ascoltate..."],
		],
	},
	"naufragio": {
		"titolo": "Il naufragio",
		"villaggio": "relitto", "scorte": {"tronchi": 12, "assi": 18, "pietra": 14}, "coloni": 20,
		"inizio": [
			["Rocco della Lira", "Ascoltate, ascoltate... Il mare d'autunno è un padrone geloso. Si prese la nave del capitano, e lasciò sulla sabbia soltanto i suoi figli, le sue casse e una fiamma di coraggio."],
			["Eudora", "Mio padre è rimasto laggiù, tra le onde. Ma noi siamo vivi, e questa terra ha alberi, pietre e acqua dolce. Abbiamo tirato a riva quel che restava della nave: sarà il nostro magazzino."],
			["Eudora", "Prima di tutto servono strade, legname e un tetto per chi ha freddo. Coraggio: cominciamo."],
		],
		"obiettivi": [
			{"testo": "Traccia una strada dal magazzino", "aiuto": "Premi «Strada» (o R), clicca la bandierina davanti al magazzino e poi un punto libero vicino.", "prova": "strada"},
			{"testo": "Costruisci un boscaiolo vicino al bosco", "aiuto": "Nel menu «Base» scegli il boscaiolo, mettilo vicino agli alberi e collega la sua bandierina con una strada.", "prova": "edificio", "tipo": "boscaiolo"},
			{"testo": "Costruisci una segheria", "aiuto": "La segheria trasforma i tronchi in assi. Mettila vicino al magazzino e collegala.", "prova": "edificio", "tipo": "segheria"},
			{"testo": "Fai preparare 6 assi", "aiuto": "Basta aspettare: il boscaiolo taglia, i portatori portano i tronchi alla segheria.", "prova": "prodotti", "tipo": "segheria", "n": 6},
			{"testo": "Costruisci due abitazioni per i superstiti", "aiuto": "Le abitazioni danno riparo e fanno crescere il villaggio. Servono assi e pietra.", "prova": "edificio", "tipo": "casa_greca", "n": 2},
		],
		"fine": [
			["Eudora", "Il fumo dei focolari sale dritto: niente vento, stanotte. Per la prima volta da quando abbiamo toccato terra, dormiremo sotto un tetto."],
			["Rocco della Lira", "E così, sulla riva delle colonne di roccia, nacque una città. Piccola, sì. Ma anche le querce, un tempo, erano ghiande... La storia continua."],
		],
	},
	"pane_straniero": {
		"titolo": "Pane straniero",
		"villaggio": "pieno", "brettii": true, "coloni": 40,
		"scorte": {"tronchi": 20, "assi": 40, "pietra": 40, "olio": 8, "ducati": 4},
		"inizio": [
			["Rocco della Lira", "La terra nuova è generosa, ma non ha fretta: il grano seminato oggi si raccoglie domani, e la fame non sa aspettare."],
			["Eudora", "Lassù, tra i pini, vivono pastori che chiamano se stessi Brettii. Hanno grano e formaggio. Noi abbiamo l'olio della nave e qualche ducato."],
			["Eudora", "Alziamo una piazza del mercato: lì si incontrano i popoli, prima che le loro spade."],
		],
		"obiettivi": [
			{"testo": "Costruisci l'agorà", "aiuto": "Nel menu «Base»: è grande (3×3). Collegala al magazzino.", "prova": "edificio", "tipo": "agora"},
			{"testo": "Vendi l'olio e compra 4 grano dai pastori", "aiuto": "Clicca l'agorà e scegli «Grano» in «Compra con i ducati». L'olio in magazzino arriva da solo e si vende.", "prova": "prodotti", "tipo": "agora", "n": 4},
			{"testo": "Costruisci un mulino e un forno", "aiuto": "Il mulino macina il grano; il forno impasta farina e acqua (serve anche un pozzo).", "prova": "edificio", "tipo": "forno",
				"dopo": [["Eudora", "Il mugnaio dice che la farina dei Brettii è più scura della nostra. Sarà buona lo stesso."]]},
			{"testo": "Cuoci 6 pani", "aiuto": "Mulino, pozzo e forno collegati: il pane arriva in magazzino.", "prova": "prodotti", "tipo": "forno", "n": 6},
		],
		"fine": [
			["Rocco della Lira", "Il primo pane della città sapeva di montagna e di mare insieme. Nessuno lo disse ad alta voce, ma fu allora che i due popoli si conobbero."],
		],
	},
	"uliveto": {
		"titolo": "L'uliveto del vecchio",
		"villaggio": "pieno", "coloni": 40,
		"scorte": {"tronchi": 20, "assi": 40, "pietra": 40, "pane": 6},
		"inizio": [
			["Rocco della Lira", "C'era, sulla collina, un ulivo così vecchio che nessuno ricordava chi l'avesse piantato. Torto come un nodo di corda, carico come una promessa."],
			["Eudora", "Nella nostra terra l'olio era luce, medicina e ricchezza. Qui gli ulivi crescono da soli: raccogliamo le olive e facciamo l'olio."],
		],
		"obiettivi": [
			{"testo": "Costruisci un raccoglitore di olive vicino agli ulivi", "aiuto": "Nel menu «Cibo». Gli ulivi stanno nella pianura secca, a qualche passo dal villaggio.", "prova": "edificio", "tipo": "uliveto"},
			{"testo": "Costruisci un frantoio", "aiuto": "Il frantoio spreme le olive che i portatori gli consegnano.", "prova": "edificio", "tipo": "frantoio"},
			{"testo": "Spremi 8 anfore d'olio", "aiuto": "Le olive maturano soprattutto d'autunno e d'inverno.", "prova": "prodotti", "tipo": "frantoio", "n": 8},
			{"testo": "Costruisci l'agorà e guadagna 9 ducati con l'olio", "aiuto": "L'olio si vende bene: 3 ducati ad anfora.", "prova": "guadagno", "n": 9},
		],
		"fine": [
			["Eudora", "Le navi che passano al largo ora si fermano: l'odore dell'olio nuovo arriva fino al mare."],
			["Rocco della Lira", "Il vecchio ulivo non disse niente. Gli ulivi non parlano. Ma quell'autunno fece più olive di tutti gli altri."],
		],
	},
	"citta_sorelle": {
		"titolo": "Città sorelle",
		"villaggio": "pieno", "coloni": 40,
		"scorte": {"tronchi": 30, "assi": 60, "pietra": 60, "olio": 10, "vino": 6, "pane": 10},
		"inizio": [
			["Rocco della Lira", "Più a nord, sulla stessa costa, altri Greci fondarono un'altra città. Sorelle, si dicevano. Ma anche le sorelle litigano per lo stesso specchio."],
			["Eudora", "Vogliono i nostri porti e i nostri campi. Non li avranno: diventiamo più grandi, più ricchi e più forti di loro."],
		],
		"obiettivi": [
			{"testo": "Fai crescere il villaggio fino a 52 coloni", "aiuto": "Costruisci abitazioni: ogni casa ospita 8 coloni. Vino, agrumi e miele li fanno nascere prima.", "prova": "popolazione", "n": 52},
			{"testo": "Metti da parte 20 ducati", "aiuto": "Vendi all'agorà olio, vino, stoffa, anfore... oppure apri una zecca.", "prova": "scorta", "merce": "ducati", "n": 20},
			{"testo": "Presidia una torre di guardia", "aiuto": "Nel menu «Difesa»: quando la guardia entra, i confini si allargano.", "prova": "presidiata"},
		],
		"fine": [
			["Eudora", "Hanno mandato un'ambasceria con doni e parole dolci. Hanno visto le nostre torri e il nostro mercato. Per ora, saremo sorelle davvero."],
			["Rocco della Lira", "Per ora. Ricordatevelo, voi che ascoltate: per ora."],
		],
	},
	"ira_del_fiume": {
		"titolo": "L'ira del fiume",
		"villaggio": "pieno", "coloni": 40,
		"scorte": {"tronchi": 20, "assi": 40, "pietra": 10, "pane": 6},
		"inizio": [
			["Rocco della Lira", "Le fiumare di Calabria dormono tutta l'estate come cani al sole. Poi una notte d'autunno si svegliano, e si ricordano di essere fiumi."],
			["Eudora", "Seminiamo il grano finché il tempo è buono. I vecchi Brettii dicono che quest'anno la pioggia sarà cattiva."],
		],
		"obiettivi": [
			{"testo": "Costruisci una fattoria e semina 4 campi", "aiuto": "Nel menu «Cibo»: il contadino semina da solo intorno alla fattoria.", "prova": "campi", "coltura": "grano", "n": 4,
				"evento": "alluvione",
				"dopo": [["Eudora", "La fiumara ha rotto gli argini di terra! L'acqua ha portato via tutti i campi."], ["Eudora", "Servono pietre per argini veri. Poi riseminiamo."]]},
			{"testo": "Accumula 25 pietre per gli argini", "aiuto": "Costruisci una cava vicino alle rocce: i portatori portano la pietra in magazzino.", "prova": "scorta", "merce": "pietra", "n": 25},
			{"testo": "Raccogli 6 covoni di grano", "aiuto": "Il contadino risemina da solo: aspetta che i campi diventino dorati.", "prova": "prodotti", "tipo": "fattoria", "n": 6},
		],
		"fine": [
			["Rocco della Lira", "Gli argini di pietra sono ancora là, coperti di muschio. Chi ci passa accanto non sa chi li ha fatti. Ma il fiume lo sa."],
		],
	},
	"voce_del_mare": {
		"titolo": "La voce del mare",
		"villaggio": "pieno", "coloni": 40, "costa": true,
		"scorte": {"tronchi": 30, "assi": 60, "pietra": 60, "pane": 10},
		"inizio": [
			["Rocco della Lira", "Ascoltate bene, adesso, perché questa è la parte che nessuno crede. I pescatori dicevano che il mare dello Stretto, nelle notti calme, cantava."],
			["Eudora", "Io l'ho sentito. Una voce sotto l'acqua, lontano dalla riva. Se c'è qualcosa laggiù, lo troveranno le barche del pesce spada."],
		],
		"obiettivi": [
			{"testo": "Costruisci la barca del pesce spada sulla costa", "aiuto": "Nel menu «Cibo». Le torri già alzate verso il mare ti danno la costa.", "prova": "edificio", "tipo": "pesca_spada"},
			{"testo": "Pesca 5 pesci spada al largo", "aiuto": "Il pescatore esce in barca da solo, fino al mare aperto.", "prova": "prodotti", "tipo": "pesca_spada", "n": 5,
				"dopo": [["Eudora", "L'ultima barca è tornata con qualcosa nella rete: un pezzo di pietra azzurra, liscia come un sasso di fiume, incisa con un segno che nessuno sa leggere."]]},
		],
		"fine": [
			["Rocco della Lira", "Il Frammento del Mare. Uno dei cinque pezzi del Sigillo di Italo, il re che camminava tra due mari."],
			["Rocco della Lira", "Eudora lo tenne in mano a lungo, guardando le montagne. Perché ora sapeva che gli altri quattro aspettavano lassù... e che non sarebbe stata la sola a cercarli."],
			["Rocco della Lira", "Qui finisce il canto dei Greci. Ma la terra tra due mari ha ancora molte voci."],
		],
	},
}

var id := ""
var dati: Dictionary
var indice := 0                      # obiettivo corrente (== numero obiettivi: missione compiuta)
var partita: Node2D
var _nemici_iniziali := 0
var tempo := 0.0                     # secondi di gioco dall'inizio della missione (il cronometro delle sfide)
var _secondo := 0.0
var _strade_iniziali := 0
var _controllo := 0.0


func prepara(p: Node2D, missione: String) -> void:
	partita = p
	id = missione
	dati = MISSIONI[missione]
	_strade_iniziali = p.rete.tratti.size()
	_nemici_iniziali = p.villaggio.nemici.size()


func titolo() -> String:
	return dati["titolo"]


func obiettivi() -> Array:
	return dati["obiettivi"]


func finita() -> bool:
	return indice >= obiettivi().size()


func comincia() -> void:
	dialogo.emit(per_lato(dati["inizio"]))


## Nella campagna di Annibale i racconti possono cambiare con il lato scelto: {"romani": [...], "cartaginesi": [...]}.
static func per_lato(battute) -> Array:
	if battute is Dictionary:
		return battute.get(lato_annibale(), battute.values()[0])
	return battute


func _process(delta: float) -> void:
	if finita():
		return
	tempo += delta
	if dati.get("sfida", false):
		_secondo += delta
		if _secondo >= 1.0:
			_secondo = 0.0
			obiettivo_cambiato.emit()          # il pannello aggiorna il cronometro
	_controllo -= delta
	if _controllo > 0.0:
		return
	_controllo = 0.5
	var ob: Dictionary = obiettivi()[indice]
	if raggiunto(ob):
		indice += 1
		Suono.suona("completato")
		if ob.has("evento"):
			_evento(ob["evento"])
		if ob.has("dopo"):
			dialogo.emit(per_lato(ob["dopo"]))
		obiettivo_cambiato.emit()
		if finita():
			segna_compiuta(id)
			if dati.get("sfida", false):
				segna_record(id, tempo)
			compiuta.emit()
			dialogo.emit(racconto_finale())


## Il racconto di chiusura; nell'ultima missione della Soglia dipende dal finale scelto.
func racconto_finale() -> Array:
	return per_lato(dati.get("fine_" + finale(), dati.get("fine", [])))


## Verifica un obiettivo sullo stato della partita.
func raggiunto(ob: Dictionary) -> bool:
	var v: Villaggio = partita.villaggio
	var n: int = ob.get("n", 1)
	match ob["prova"]:
		"strada":
			return partita.rete.tratti.size() > _strade_iniziali
		"edificio":
			return v.edifici.values().filter(func(e): return e.tipo == ob["tipo"] and e.finito and e.collegato).size() >= n
		"prodotti":
			return v.edifici.values().filter(func(e): return e.tipo == ob["tipo"]).reduce(func(t, e): return t + e.prodotti, 0) >= n
		"scorta":
			return v.scorte.get(ob["merce"], 0) >= n
		"popolazione":
			return v.popolazione() >= n
		"campi":
			return partita.risorse.campi.values().filter(func(c): return c["coltura"] == ob["coltura"]).size() >= n
		"presidiata":
			return v.edifici.values().any(func(e): return e.tipo in ["torre", "castello"] and e.presidiata and e.collegato)
		"guadagno":
			return v.edifici.values().filter(func(e): return e.tipo == "agora").reduce(func(t, e): return t + e.guadagno, 0) >= n
		"lusso":
			return (CatalogoEdifici.LUSSO + ["olio", "cavalli"]).reduce(func(t, m): return t + v.scorte.get(m, 0), 0) >= n
		"conquiste":
			return _nemici_iniziali - v.nemici.size() >= n
		"forti":
			return v.edifici.values().filter(func(e): return CatalogoEdifici.dati(e.tipo).has("presidio") and e.presidiata and e.collegato).size() >= n
		"villaggi":
			return partita.indigeni.elenco.filter(func(i): return i["stato"] in ["alleato", "nostro"]).size() >= n
		"schiera":
			return partita.schiere.soldati() >= n
		"condottiero_livello":
			return partita.schiere.livello() >= n
		"macchina":
			return partita.schiere.macchine().size() >= n
		"nemici_zero":
			return v.nemici.is_empty()
		"una_tra":
			for altra in ob["prove"]:
				if raggiunto(altra):
					if altra.has("scelta"):
						scegli_finale(altra["scelta"])
					return true
			return false
	return false


func _evento(nome: String) -> void:
	match nome:
		"lava":
			# la cenere dell'Etna brucia i campi seminati
			_evento("alluvione")
		"alluvione":
			# l'acqua porta via tutti i campi seminati
			var ris: RisorseNaturali = partita.risorse
			for c in ris.campi.keys():
				(ris.campi[c]["sprite"] as Node).queue_free()
				ris.campi.erase(c)
				partita.dati.occupa(c.x, c.y, 0)
			Suono.suona("errore")


# ------------------------------------------------------------------ progressi della campagna

## Il file dei progressi: {"completate": [...], "popolo_soglia": "...", "finale": "unione" | "conquista"}.
static func _leggi() -> Dictionary:
	var f := FileAccess.open(progressi, FileAccess.READ)
	if f == null:
		return {}
	var d = JSON.parse_string(f.get_as_text())
	return d if d is Dictionary else {}


static func _scrivi(d: Dictionary) -> void:
	var f := FileAccess.open(progressi, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(d))


static func completate() -> Array:
	return _leggi().get("completate", [])


static func segna_compiuta(missione: String) -> void:
	var d := _leggi()
	var c: Array = d.get("completate", [])
	if missione in c:
		return
	c.append(missione)
	d["completate"] = c
	_scrivi(d)


## Il miglior tempo di una sfida in secondi (-1 se non è mai stata compiuta).
static func record(sfida: String) -> float:
	return float(_leggi().get("record", {}).get(sfida, -1.0))


static func segna_record(sfida: String, secondi: float) -> void:
	var d := _leggi()
	var rec: Dictionary = d.get("record", {})
	if not rec.has(sfida) or secondi < float(rec[sfida]):
		rec[sfida] = secondi
		d["record"] = rec
		_scrivi(d)


static func testo_tempo(secondi: float) -> String:
	return "%d:%02d" % [int(secondi) / 60, int(secondi) % 60]


## Il popolo scelto per la campagna finale («» finché non si sceglie).
static func popolo_soglia() -> String:
	return _leggi().get("popolo_soglia", "")


static func scegli_popolo_soglia(popolo: String) -> void:
	var d := _leggi()
	d["popolo_soglia"] = popolo
	_scrivi(d)


## Il lato scelto per la campagna di Annibale: «cartaginesi» (di serie) o «romani».
static func lato_annibale() -> String:
	var l: String = _leggi().get("lato_annibale", "")
	return l if l in LATI_ANNIBALE else "cartaginesi"


static func lato_scelto() -> bool:
	return _leggi().get("lato_annibale", "") in LATI_ANNIBALE


static func scegli_lato_annibale(lato: String) -> void:
	var d := _leggi()
	d["lato_annibale"] = lato
	_scrivi(d)


## Il finale della campagna della Soglia: «unione» (di serie) o «conquista».
static func finale() -> String:
	return _leggi().get("finale", "unione")


static func scegli_finale(quale: String) -> void:
	var d := _leggi()
	d["finale"] = quale
	_scrivi(d)


## La prossima missione da giocare della campagna finale ("" se è tutta compiuta).
static func prossima_soglia() -> String:
	return prossima(CAMPAGNA_SOGLIA)


## La prossima missione da giocare di una campagna ("" se è tutta compiuta).
static func prossima(campagna: Array) -> String:
	for m in campagna:
		if not m in completate():
			return m
	return ""


## Una missione si può giocare se quella prima nella sua campagna è stata compiuta; la prima missione di
## una campagna si apre finita l'ultima della campagna precedente (Greci → Soglia → Sicilia).
static func sbloccata(missione: String) -> bool:
	if missione in SFIDE:
		return true
	var a := CAMPAGNA_ANNIBALE.find(missione)
	if a >= 0:
		return a == 0 or CAMPAGNA_ANNIBALE[a - 1] in completate()
	for k in CAMPAGNE.size():
		var campagna: Array = CAMPAGNE[k]
		var i := campagna.find(missione)
		if i < 0:
			continue
		if i > 0:
			return campagna[i - 1] in completate()
		return k == 0 or CAMPAGNE[k - 1][-1] in completate()
	return false
