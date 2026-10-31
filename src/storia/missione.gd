class_name Missione
extends Node
## Una missione della campagna: racconto d'apertura, obiettivi da raggiungere uno dopo l'altro
## (ognuno con un suggerimento), racconto di chiusura. I testi sono originali del gioco.

signal dialogo(battute: Array)       # [[chi, testo], ...]: il pannello le mostra una alla volta
signal obiettivo_cambiato
signal compiuta

const MISSIONI := {
	"naufragio": {
		"campagna": "Le Colonne dell'Alba",
		"titolo": "Il naufragio",
		"inizio": [
			["Rocco della Lira", "Ascoltate, ascoltate... Il mare d'autunno è un padrone geloso. Si prese la nave del capitano, e lasciò sulla sabbia soltanto i suoi figli, le sue casse e una fiamma di coraggio."],
			["Eudora", "Mio padre è rimasto laggiù, tra le onde. Ma noi siamo vivi, e questa terra ha alberi, pietre e acqua dolce. Abbiamo tirato a riva quel che restava della nave: sarà il nostro magazzino."],
			["Eudora", "Prima di tutto servono strade, legname e un tetto per chi ha freddo. Coraggio: cominciamo."],
		],
		"obiettivi": [
			{"testo": "Traccia una strada dal magazzino", "aiuto": "Premi «Strada» (o R), clicca la bandierina davanti al magazzino e poi un punto libero vicino.", "prova": "strada"},
			{"testo": "Costruisci un boscaiolo vicino al bosco", "aiuto": "Nel menu «Base» scegli il boscaiolo, mettilo vicino agli alberi e collega la sua bandierina con una strada.", "prova": "boscaiolo"},
			{"testo": "Costruisci una segheria", "aiuto": "La segheria trasforma i tronchi in assi. Mettila vicino al magazzino e collegala.", "prova": "segheria"},
			{"testo": "Fai preparare 6 assi", "aiuto": "Basta aspettare: il boscaiolo taglia, i portatori portano i tronchi alla segheria.", "prova": "assi"},
			{"testo": "Costruisci due abitazioni per i superstiti", "aiuto": "Le abitazioni danno riparo e fanno crescere il villaggio. Servono assi e pietra.", "prova": "case"},
		],
		"fine": [
			["Eudora", "Il fumo dei focolari sale dritto: niente vento, stanotte. Per la prima volta da quando abbiamo toccato terra, dormiremo sotto un tetto."],
			["Rocco della Lira", "E così, sulla riva delle colonne di roccia, nacque una città. Piccola, sì. Ma anche le querce, un tempo, erano ghiande... La storia continua."],
		],
		"scorte": {"tronchi": 12, "assi": 18, "pietra": 14},
		"coloni": 20,
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
	if raggiunto(obiettivi()[indice]["prova"]):
		indice += 1
		Suono.suona("completato")
		obiettivo_cambiato.emit()
		if finita():
			compiuta.emit()
			dialogo.emit(dati["fine"])


## Verifica un obiettivo sullo stato della partita.
func raggiunto(prova: String) -> bool:
	var v: Villaggio = partita.villaggio
	match prova:
		"strada":
			return partita.rete.tratti.size() > _strade_iniziali
		"boscaiolo", "segheria":
			return v.edifici.values().any(func(e): return e.tipo == prova and e.finito and e.collegato)
		"assi":
			return v.edifici.values().filter(func(e): return e.tipo == "segheria").reduce(func(n, e): return n + e.prodotti, 0) >= 6
		"case":
			return v.edifici.values().filter(func(e): return e.tipo == "casa_greca" and e.finito).size() >= 2
	return false
