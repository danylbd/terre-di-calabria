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

const MISSIONI := {
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
		"scorte": {"tronchi": 20, "assi": 40, "pietra": 40, "olio": 8, "monete": 4},
		"inizio": [
			["Rocco della Lira", "La terra nuova è generosa, ma non ha fretta: il grano seminato oggi si raccoglie domani, e la fame non sa aspettare."],
			["Eudora", "Lassù, tra i pini, vivono pastori che chiamano se stessi Brettii. Hanno grano e formaggio. Noi abbiamo l'olio della nave e qualche moneta."],
			["Eudora", "Alziamo una piazza del mercato: lì si incontrano i popoli, prima che le loro spade."],
		],
		"obiettivi": [
			{"testo": "Costruisci l'agorà", "aiuto": "Nel menu «Base»: è grande (3×3). Collegala al magazzino.", "prova": "edificio", "tipo": "agora"},
			{"testo": "Vendi l'olio e compra 4 grano dai pastori", "aiuto": "Clicca l'agorà e scegli «Grano» in «Compra con le monete». L'olio in magazzino arriva da solo e si vende.", "prova": "prodotti", "tipo": "agora", "n": 4},
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
			{"testo": "Costruisci l'agorà e guadagna 9 monete con l'olio", "aiuto": "L'olio si vende bene: 3 monete ad anfora.", "prova": "guadagno", "n": 9},
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
			{"testo": "Metti da parte 20 monete", "aiuto": "Vendi all'agorà olio, vino, stoffa, anfore... oppure apri una zecca.", "prova": "scorta", "merce": "monete", "n": 20},
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
var _strade_iniziali := 0
var _controllo := 0.0


func prepara(p: Node2D, missione: String) -> void:
	partita = p
	id = missione
	dati = MISSIONI[missione]
	_strade_iniziali = p.rete.tratti.size()


func titolo() -> String:
	return dati["titolo"]


func obiettivi() -> Array:
	return dati["obiettivi"]


func finita() -> bool:
	return indice >= obiettivi().size()


func comincia() -> void:
	dialogo.emit(dati["inizio"])


func _process(delta: float) -> void:
	if finita():
		return
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
			dialogo.emit(ob["dopo"])
		obiettivo_cambiato.emit()
		if finita():
			segna_compiuta(id)
			compiuta.emit()
			dialogo.emit(dati["fine"])


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
	return false


func _evento(nome: String) -> void:
	match nome:
		"alluvione":
			# l'acqua porta via tutti i campi seminati
			var ris: RisorseNaturali = partita.risorse
			for c in ris.campi.keys():
				(ris.campi[c]["sprite"] as Node).queue_free()
				ris.campi.erase(c)
				partita.dati.occupa(c.x, c.y, 0)
			Suono.suona("errore")


# ------------------------------------------------------------------ progressi della campagna

static func completate() -> Array:
	var f := FileAccess.open(progressi, FileAccess.READ)
	if f == null:
		return []
	var d = JSON.parse_string(f.get_as_text())
	return d.get("completate", []) if d is Dictionary else []


static func segna_compiuta(missione: String) -> void:
	var c := completate()
	if missione in c:
		return
	c.append(missione)
	var f := FileAccess.open(progressi, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify({"completate": c}))


## Una missione si può giocare se è la prima o se quella prima è stata compiuta.
static func sbloccata(missione: String) -> bool:
	var i := CAMPAGNA_GRECI.find(missione)
	return i <= 0 or CAMPAGNA_GRECI[i - 1] in completate()
