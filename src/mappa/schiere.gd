class_name Schiere
extends Node2D
## Condottieri e schiere (step 31, Fase 7 — idee da Imperivm, docs/piano-imperivm.md): il condottiero del
## popolo esce dalla caserma o dal castello con fino a 12 soldati presi dalla riserva. Si comanda in modo
## diretto: clic sul condottiero per sceglierlo, poi clic sulla terra (va lì), su una torre nemica o su un
## villaggio indigeno (attacca). L'economia resta alla Settlers. Non c'è nella partita in pace.
## Step 36 (assedi): le torri nemiche hanno le mura, punti da abbattere prima dei duelli, che il nemico rialza
## col tempo; l'armaiolo costruisce l'ariete (sfonda da vicino) e l'onagro (tira da lontano), che seguono la schiera.

signal cambiata

const MAX_SOLDATI := 12
const DURATA_DUELLO := 1.5
const DISTANZA_ASSALTO := 3.5        # caselle dal bersaglio entro cui la schiera combatte
const DISTANZA_TIRO := 6.0           # i tiratori combattono da più lontano
const VOLO := 0.45                   # secondi di volo di un proiettile
## step 32: cibo, morale ed esperienza
const RAZIONI_MAX := 20
const CONSUMO := 20.0                # secondi per ogni razione mangiata dalla schiera
const FAME := 30.0                   # senza razioni, ogni tanto un soldato se ne va
const RAGGIO_MAGAZZINO := 6.0        # vicino a un nostro magazzino la schiera si rifornisce e si rinforza
const ESPERIENZA_LIVELLO := 10       # duelli vinti per ogni livello del condottiero
const LIVELLO_MAX := 5
## step 34: due abilità per condottiero, la prima dal livello 2, la seconda dal livello 4.
## effetto: "duelli" (+probabilità per "durata" secondi), "morale" (subito), "passo" (velocità × per "durata")
const ABILITA := {
	"greci": [{"nome": "Falange", "descrizione": "Scudi stretti: duelli più facili per 20 s", "effetto": "duelli", "valore": 0.12, "durata": 20.0},
		{"nome": "Canto di Eudora", "descrizione": "Il canto delle stelle: morale +25", "effetto": "morale", "valore": 25}],
	"brettii": [{"nome": "Passo di montagna", "descrizione": "Tauro guida per i sentieri: schiera più veloce per 20 s", "effetto": "passo", "valore": 1.5, "durata": 20.0},
		{"nome": "Imboscata", "descrizione": "Dal folto del bosco: duelli molto più facili per 12 s", "effetto": "duelli", "valore": 0.2, "durata": 12.0}],
	"romani": [{"nome": "Disciplina", "descrizione": "Ordine nelle file: morale +20", "effetto": "morale", "valore": 20},
		{"nome": "Testuggine", "descrizione": "Scudi sopra e davanti: duelli più facili per 20 s", "effetto": "duelli", "valore": 0.14, "durata": 20.0}],
	"saraceni": [{"nome": "Carica rapida", "descrizione": "I cavalli leggeri volano: schiera più veloce per 15 s", "effetto": "passo", "valore": 1.6, "durata": 15.0},
		{"nome": "Grido del deserto", "descrizione": "Duelli più facili per 15 s", "effetto": "duelli", "valore": 0.15, "durata": 15.0}],
	"normanni": [{"nome": "Giuramento", "descrizione": "Osmund giura per tutti: morale +25", "effetto": "morale", "valore": 25},
		{"nome": "Carica pesante", "descrizione": "Lance in resta: duelli molto più facili per 10 s", "effetto": "duelli", "valore": 0.22, "durata": 10.0}],
	"siculi": [{"nome": "Grido degli antenati", "descrizione": "Le voci di Pantalica: morale +20", "effetto": "morale", "valore": 20},
		{"nome": "Lance lunghe", "descrizione": "Duelli più facili per 20 s", "effetto": "duelli", "valore": 0.12, "durata": 20.0}],
	"cartaginesi": [{"nome": "Astuzia di Canne", "descrizione": "Annibale accerchia il nemico: duelli molto più facili per 12 s", "effetto": "duelli", "valore": 0.2, "durata": 12.0},
		{"nome": "Giuramento di Annibale", "descrizione": "L'odio giurato a Roma: morale +25", "effetto": "morale", "valore": 25}],
	"sicani": [{"nome": "Rifugio sui monti", "descrizione": "Kokalo conosce ogni passo: schiera più veloce per 20 s", "effetto": "passo", "valore": 1.5, "durata": 20.0},
		{"nome": "Pioggia di frecce", "descrizione": "Punte d'ossidiana: duelli molto più facili per 10 s", "effetto": "duelli", "valore": 0.2, "durata": 10.0}],
}
const LIVELLI_ABILITA := [2, 4]
const MURA_INIZIO := 2.0             # punti di mura di una torre nemica appena vista
const MURA_MAX := 8.0
const RIFORZO_MURA := 45.0           # secondi perché il nemico aggiunga un punto di mura (non mentre lo assediamo)
const RISCHIO_MURA := 0.2            # senza ariete, sotto le mura un soldato può cadere a ogni colpo
const MACCHINE := {
	"ariete": {"nome": "Ariete", "costo": {"assi": 5, "armi": 1}, "danno": 3.0,
		"descrizione": "Sfonda le mura da vicino (3 punti a colpo) e ripara i soldati"},
	"onagro": {"nome": "Onagro", "costo": {"assi": 4, "pietra": 3, "armi": 1}, "danno": 2.0,
		"descrizione": "Tira grossi sassi sulle mura da lontano (2 punti ogni 3 secondi)"},
	# step 37: l'unità speciale dei Cartaginesi, dalla stalla degli elefanti
	"elefante": {"nome": "Elefante da guerra", "costo": {"elefanti": 1, "armi": 1}, "danno": 2.0, "popolo": "cartaginesi",
		"edificio": "stalla_elefanti", "descrizione": "Abbatte le mura da vicino (2 punti a colpo) e dà coraggio ai duelli"},
}
const CORAGGIO_ELEFANTE := 0.1
const DISTANZA_ONAGRO := 9.0
const RICARICA_ONAGRO := 3.0
const VOLO_MASSO := 0.9
const RICARICA := 60.0
const NOMI := {"greci": "Eudora", "brettii": "Tauro", "romani": "Gaio Settimio", "saraceni": "Zahra",
	"normanni": "Osmund", "siculi": "Duketio", "sicani": "Kokalo", "cartaginesi": "Annibale"}

var villaggio: Villaggio
var guerra: Guerra
var indigeni: VillaggiIndigeni
var dati: DatiMappa
var oggetti: Node2D
var schiera := {}                    # vuota se non c'è: {"condottiero": Colono, "soldati": [Colono], "bersaglio": ...}
var scelta := false                  # il giocatore ha selezionato la schiera
var _rng := RandomNumberGenerator.new()
var _duello := 0.0
var _difensori_villaggio := -1       # difensori rimasti del villaggio indigeno sotto attacco
var esperienza := 0                  # duelli vinti dal condottiero (resta anche quando la schiera si scioglie)
var _proiettili: Array = []          # [da, a, tempo] in coordinate di mappa: sassi e frecce in volo
var _polvere: Array = []             # [dove, tempo]: la polvere dei duelli corpo a corpo
var _ricarica := [0.0, 0.0]          # secondi prima che ogni abilità si possa riusare
var _bonus_duelli := 0.0
var _bonus_fino := 0.0
var _passo := 1.0
var _passo_fino := 0.0
var _orologio := 0.0
var _tiro_onagro := 0.0
var _massi: Array = []               # [da, a, tempo]: i sassi dell'onagro in volo
var _pasto := CONSUMO
var _fame := FAME


func prepara(v: Villaggio, g: Guerra, ind: VillaggiIndigeni, d: DatiMappa, nodo_oggetti: Node2D) -> void:
	villaggio = v
	guerra = g
	indigeni = ind
	dati = d
	oggetti = nodo_oggetti
	z_index = 30
	_rng.randomize()


## Le schiere ci sono nella partita libera (non in pace) e nelle missioni che le vogliono (la campagna di Annibale).
static func attive() -> bool:
	if not Impostazioni.condottieri:
		return false
	if Impostazioni.missione != "":
		return Missione.MISSIONI.get(Impostazioni.missione, {}).get("schiere", false)
	return Impostazioni.modalita != "pace"


static func nome_condottiero() -> String:
	return NOMI.get(Popoli.giocatore, "Il condottiero")


func esiste() -> bool:
	return not schiera.is_empty()


func soldati() -> int:
	return schiera["soldati"].size() if esiste() else 0


func motivo_no_schiera() -> String:
	if not attive():
		return "Le schiere non ci sono in questa partita"
	if esiste():
		return "%s guida già la sua schiera" % nome_condottiero()
	if villaggio.soldati <= 0:
		return "Servono soldati di riserva (dalla caserma)"
	return ""


## Il condottiero esce da un edificio con i soldati di riserva (fino a 12).
func forma(da: Edificio) -> bool:
	if motivo_no_schiera() != "":
		return false
	var n := mini(MAX_SOLDATI, villaggio.soldati)
	villaggio.soldati -= n
	var inizio := Vector2(da.bandiera) + Vector2(0.5, 0.6)
	var capo := _nuovo(inizio, _foglio_condottiero(false))
	capo.velocita = 1.0
	var truppa: Array = []
	for k in n:
		var s := _nuovo(inizio + _posto(k), Popoli.soldati(1)[0])
		s.velocita = 1.0
		truppa.append(s)
	schiera = {"condottiero": capo, "soldati": truppa, "bersaglio": null, "razioni": 0, "morale": 70, "macchine": {}}
	_rifornisci()
	villaggio.messaggio.emit("%s guida una schiera di %d soldati: cliccalo per dargli ordini" % [nome_condottiero(), n], false)
	cambiata.emit()
	return true


func _foglio_condottiero(lotta: bool) -> String:
	var nome := "condottiero_%s%s" % [Popoli.giocatore, "_lotta" if lotta else ""]
	if ResourceLoader.exists("res://assets/grafica/%s.png" % nome):
		return nome
	return Popoli.soldati(1)[1 if lotta else 0]


func _nuovo(p: Vector2, foglio: String) -> Colono:
	var c := Colono.new()
	oggetti.add_child(c)
	c.prepara(dati, p, foglio)
	return c


## Il posto di una macchina dietro la schiera: l'ariete a sinistra, l'onagro a destra, l'elefante davanti in mezzo.
func _posto_macchina(t: String, righe: int) -> Vector2:
	match t:
		"onagro":
			return Vector2(0.6, (righe + 1) * 0.5 + 0.4)
		"elefante":
			return Vector2(0.9, -0.6)
	return Vector2(-0.6, (righe + 1) * 0.5 + 0.4)


## Il posto di un soldato nella formazione: file di 4 dietro al condottiero.
func _posto(k: int) -> Vector2:
	return Vector2((k % 4) * 0.45 - 0.7, (k / 4 + 1) * 0.5)


## Il condottiero è in questa casella (o lì vicino)?
func in_casella(c: Vector2i) -> bool:
	return esiste() and not in_viaggio() and Vector2(c) .distance_to(schiera["condottiero"].pos.floor()) <= 1.0


func scegli(si: bool) -> void:
	scelta = si and esiste()
	queue_redraw()


## Ordine di andare in una casella: il percorso più breve a piedi (niente mare, niente edifici).
func muovi(c: Vector2i) -> bool:
	if not esiste() or in_viaggio():
		return false
	schiera.erase("imbarco")
	var capo: Colono = schiera["condottiero"]
	var percorso := percorso_a_piedi(Vector2i(capo.pos.floor()), c)
	if percorso.is_empty():
		return false
	schiera["bersaglio"] = null
	_difensori_villaggio = -1
	_marcia(percorso)
	return true


func _marcia(percorso: Array[Vector2]) -> void:
	var capo: Colono = schiera["condottiero"]
	capo.imposta_foglio(_foglio_condottiero(false))
	capo.percorri(percorso.duplicate())
	var arrivo: Vector2 = percorso[-1]
	for k in schiera["soldati"].size():
		var s: Colono = schiera["soldati"][k]
		s.imposta_foglio(Popoli.soldati(1)[0])
		var p: Array[Vector2] = percorso.duplicate()
		p[-1] = arrivo + _posto(k)
		s.percorri(p)
	var righe: int = (schiera["soldati"].size() + 3) / 4
	for t in macchine():
		var m: Colono = macchine()[t]
		m.imposta_foglio(_foglio_macchina(t, false))
		var p: Array[Vector2] = percorso.duplicate()
		p[-1] = arrivo + _posto_macchina(t, righe)
		var b = schiera.get("bersaglio")
		if t == "onagro" and typeof(b) == TYPE_OBJECT and is_instance_valid(b):
			# l'onagro si ferma appena il bersaglio è a tiro
			for i in p.size():
				if p[i].distance_to(b.centro()) <= DISTANZA_ONAGRO - 1.5:
					p = p.slice(0, i + 1)
					break
		m.percorri(p)


## La traversata (step 35): la schiera va al porto, sale sulla nave e sbarca a un altro nostro porto
## raggiungibile per mare (per esempio dall'altra parte dello Stretto).
func imbarca(porto: Edificio) -> bool:
	if not esiste() or porto.tipo != "porto" or not porto.finito:
		return false
	var da := Mare.acqua_vicina(dati, Vector2i(porto.centro()), 7)
	if da.x < 0:
		return false
	var meta: Edificio = null
	var rotta: Array[Vector2] = []
	for e in villaggio.edifici.values():
		if e == porto or e.tipo != "porto" or not e.finito:
			continue
		var w := Mare.acqua_vicina(dati, Vector2i(e.centro()), 7)
		if w.x < 0:
			continue
		var r := Mare.rotta(dati, da, w)
		if not r.is_empty() and (meta == null or r.size() < rotta.size()):
			meta = e
			rotta = r
	if meta == null:
		villaggio.messaggio.emit("Serve un altro nostro porto raggiungibile per mare", true)
		return false
	var capo: Colono = schiera["condottiero"]
	var percorso := percorso_a_piedi(Vector2i(capo.pos.floor()), porto.bandiera)
	if percorso.is_empty() and Vector2(porto.bandiera).distance_to(capo.pos) > 1.5:
		return false
	schiera["bersaglio"] = null
	schiera["imbarco"] = {"porto": porto, "acqua": da, "meta": meta, "rotta": rotta}
	if not percorso.is_empty():
		_marcia(percorso)
	return true


func in_viaggio() -> bool:
	return esiste() and schiera.has("nave")


## Al porto: tutti a bordo, la nave attraversa il mare.
func _salpa() -> void:
	var imb: Dictionary = schiera["imbarco"]
	for m in [schiera["condottiero"]] + schiera["soldati"] + macchine().values():
		m.visible = false
		m.percorri([m.pos] as Array[Vector2])
	var nave := _nuovo(Vector2(imb["acqua"]) + Vector2(0.5, 0.5), "nave")
	nave.velocita = 2.2
	nave.arrivato.connect(func(_c): _sbarca())
	nave.percorri(imb["rotta"].duplicate())
	schiera["nave"] = nave
	villaggio.messaggio.emit("La schiera di %s salpa verso l'altro porto" % nome_condottiero(), false)


func _sbarca() -> void:
	if not esiste() or not schiera.has("nave"):
		return
	var meta: Edificio = schiera["imbarco"]["meta"]
	var terra := Vector2(meta.bandiera) + Vector2(0.5, 0.6)
	schiera["condottiero"].pos = terra
	schiera["condottiero"].visible = true
	for k in schiera["soldati"].size():
		var s: Colono = schiera["soldati"][k]
		s.pos = terra + _posto(k)
		s.visible = true
	for t in macchine():
		macchine()[t].pos = terra + _posto_macchina(t, 3)
		macchine()[t].visible = true
	schiera["nave"].queue_free()
	schiera.erase("nave")
	schiera.erase("imbarco")
	villaggio.messaggio.emit("La schiera di %s è sbarcata" % nome_condottiero(), false)
	cambiata.emit()


## Attacca una torre nemica o un villaggio indigeno: la schiera ci va e combatte.
func attacca(bersaglio) -> bool:
	if not esiste() or in_viaggio():
		return false
	schiera.erase("imbarco")
	var centro: Vector2
	if bersaglio is Edificio:
		centro = (bersaglio as Edificio).centro()
	elif bersaglio is int:
		if indigeni.elenco[bersaglio]["stato"] == "nostro":
			return false
		centro = Vector2(indigeni.elenco[bersaglio]["casella"]) + Vector2(2.5, 2.5)
		_difensori_villaggio = indigeni.difensori(bersaglio)
	else:
		return false
	var capo: Colono = schiera["condottiero"]
	var vicino := _vicino_a_piedi(Vector2i(centro.floor()))
	if tipo() == "tiratori":
		# i tiratori si fermano a distanza di tiro, dalla parte da cui arrivano
		var punto := centro + (capo.pos - centro).normalized() * (DISTANZA_TIRO - 1.0)
		vicino = _vicino_a_piedi(Vector2i(punto.floor()), 0)
	var percorso := percorso_a_piedi(Vector2i(capo.pos.floor()), vicino)
	if percorso.is_empty():
		return false
	schiera["bersaglio"] = bersaglio
	_marcia(percorso)
	return true


func _vicino_a_piedi(c: Vector2i, da_raggio := 2) -> Vector2i:
	for r in range(da_raggio, 6):
		for y in range(c.y - r, c.y + r + 1):
			for x in range(c.x - r, c.x + r + 1):
				if _camminabile(Vector2i(x, y)):
					return Vector2i(x, y)
	return c


func _camminabile(c: Vector2i) -> bool:
	return dati.dentro(c.x, c.y) and dati.tipo(c.x, c.y) != DatiMappa.Terreno.ACQUA and dati.occupante(c.x, c.y) < 2


## Percorso a piedi casella per casella (8 direzioni), tappe al centro delle caselle.
func percorso_a_piedi(da: Vector2i, a: Vector2i) -> Array[Vector2]:
	var rotta: Array[Vector2] = []
	if not _camminabile(a):
		return rotta
	var da_dove := {da: da}
	var coda: Array[Vector2i] = [da]
	var i := 0
	while i < coda.size() and i < 20000:
		var c: Vector2i = coda[i]
		i += 1
		if c == a:
			break
		for dy in range(-1, 2):
			for dx in range(-1, 2):
				var n := c + Vector2i(dx, dy)
				if not da_dove.has(n) and _camminabile(n):
					da_dove[n] = c
					coda.append(n)
	if not da_dove.has(a):
		return rotta
	var c := a
	while c != da:
		rotta.push_front(Vector2(c) + Vector2(0.5, 0.5))
		c = da_dove[c]
	if rotta.is_empty():
		rotta.append(Vector2(a) + Vector2(0.5, 0.5))
	return rotta


static func tipo() -> String:
	return Popoli.tipo_soldato(Popoli.giocatore)


## Da quanto lontano combatte la schiera: i tiratori da lontano, gli altri corpo a corpo.
static func distanza_assalto() -> float:
	return DISTANZA_TIRO if tipo() == "tiratori" else DISTANZA_ASSALTO


## Il livello del condottiero (1–5): sale con i duelli vinti dalla sua schiera.
func livello() -> int:
	return mini(LIVELLO_MAX, 1 + esperienza / ESPERIENZA_LIVELLO)


static func abilita() -> Array:
	return ABILITA.get(Popoli.giocatore, [])


## Perché un'abilità non si può usare adesso («» se si può).
func motivo_no_abilita(k: int) -> String:
	if not esiste():
		return "Nessuna schiera"
	if livello() < LIVELLI_ABILITA[k]:
		return "Si impara al livello %d" % LIVELLI_ABILITA[k]
	if _ricarica[k] > 0.0:
		return "Pronta tra %d s" % ceili(_ricarica[k])
	return ""


func usa_abilita(k: int) -> bool:
	if k >= abilita().size() or motivo_no_abilita(k) != "":
		return false
	var a: Dictionary = abilita()[k]
	match a["effetto"]:
		"duelli":
			_bonus_duelli = a["valore"]
			_bonus_fino = _orologio + a["durata"]
		"morale":
			_cambia_morale(a["valore"])
		"passo":
			_passo = a["valore"]
			_passo_fino = _orologio + a["durata"]
			_imposta_velocita()
	_ricarica[k] = RICARICA
	villaggio.messaggio.emit("%s: %s!" % [nome_condottiero(), a["nome"]], false)
	Suono.suona("completato")
	cambiata.emit()
	return true


func bonus_attivo() -> float:
	return _bonus_duelli if _orologio < _bonus_fino else 0.0


func _imposta_velocita() -> void:
	var v := _passo if _orologio < _passo_fino else 1.0
	schiera["condottiero"].velocita = v
	for s in schiera["soldati"]:
		s.velocita = v


## Probabilità che un nostro soldato vinca un duello: base, vantaggi dei monumenti, morale, livello e il
## tipo dei soldati contro quello dei difensori (di serie fanteria, come i villaggi indigeni).
func probabilita_vittoria(tipo_difensore := "fanteria") -> float:
	var morale: float = schiera.get("morale", 70) if esiste() else 70.0
	return clampf(0.55 + villaggio.vantaggi.get("duelli", 0.0) + (morale - 50.0) / 500.0 + 0.02 * (livello() - 1)
		+ Popoli.vantaggio_tipo(tipo(), tipo_difensore) + bonus_attivo()
		+ (CORAGGIO_ELEFANTE if macchine().has("elefante") else 0.0), 0.1, 0.95)


func _cambia_morale(d: int) -> void:
	schiera["morale"] = clampi(schiera["morale"] + d, 0, 100)


## Vicino a un nostro magazzino: razioni piene dal magazzino e soldati di riserva che tornano nella schiera.
func _rifornisci() -> void:
	var capo: Colono = schiera["condottiero"]
	var vicino := false
	for e in villaggio.edifici.values():
		if e.tipo == "magazzino" and e.finito and e.centro().distance_to(capo.pos) <= RAGGIO_MAGAZZINO:
			vicino = true
	if not vicino:
		return
	var preso := false
	for c in CatalogoEdifici.CIBI:
		while schiera["razioni"] < RAZIONI_MAX and villaggio.scorte.get(c, 0) > 0:
			villaggio.scorte[c] -= 1
			schiera["razioni"] += 1
			preso = true
	if preso:
		villaggio.scorte_cambiate.emit()
	while schiera["soldati"].size() < MAX_SOLDATI and villaggio.soldati > 0:
		villaggio.soldati -= 1
		var k: int = schiera["soldati"].size()
		var s := _nuovo(capo.pos + _posto(k), Popoli.soldati(1)[0])
		s.velocita = 1.0
		schiera["soldati"].append(s)


## La schiera mangia: senza razioni la fame fa andare via i soldati e cala il morale.
func _mangia(delta: float) -> void:
	_pasto -= delta
	if _pasto <= 0.0:
		_pasto = CONSUMO
		if schiera["razioni"] > 0:
			schiera["razioni"] -= 1
			_cambia_morale(1)
	if schiera["razioni"] > 0:
		_fame = FAME
		return
	_fame -= delta
	if _fame <= 0.0:
		_fame = FAME
		_cambia_morale(-15)
		villaggio.messaggio.emit("La schiera di %s ha fame: un soldato torna a casa" % nome_condottiero(), true)
		_perdi_soldato()


func _process(delta: float) -> void:
	_orologio += delta
	for k in 2:
		_ricarica[k] = maxf(0.0, _ricarica[k] - delta)
	if attive() and villaggio:
		_rinforza_mura(delta)
	if not esiste():
		_avanza_massi(delta)
		return
	if _passo != 1.0 and _orologio >= _passo_fino:
		_passo = 1.0
		_imposta_velocita()
	if schiera.has("imbarco") and not schiera.has("nave"):
		var porto: Edificio = schiera["imbarco"]["porto"]
		if not is_instance_valid(porto):
			schiera.erase("imbarco")
		elif schiera["condottiero"].pos.distance_to(Vector2(porto.bandiera) + Vector2(0.5, 0.5)) < 1.6:
			_salpa()
	if in_viaggio():
		queue_redraw()
		return
	queue_redraw()
	_avanza_effetti(delta)
	_avanza_massi(delta)
	_rifornisci()
	_mangia(delta)
	if not esiste():
		return
	var b = schiera["bersaglio"]
	if b == null:
		return
	var capo: Colono = schiera["condottiero"]
	var centro: Vector2
	if typeof(b) == TYPE_OBJECT:
		if not is_instance_valid(b) or not villaggio.nemici.has(b.id):
			_fine_assalto("")
			return
		centro = b.centro()
	else:
		centro = Vector2(indigeni.elenco[b]["casella"]) + Vector2(2.5, 2.5)
	if typeof(b) == TYPE_OBJECT:
		_onagro(b, delta)
	if capo.pos.distance_to(centro) > distanza_assalto() + 0.5:
		return
	_duello -= delta
	if _duello > 0.0:
		return
	_duello = DURATA_DUELLO
	capo.imposta_foglio(_foglio_condottiero(true))
	for s in schiera["soldati"]:
		s.imposta_foglio(Popoli.soldati(1)[1])
	_combatti(b)
	if not esiste():
		return
	_effetti(centro)


## Sassi e frecce che volano dai tiratori al bersaglio, polvere nei duelli corpo a corpo.
func _effetti(centro: Vector2) -> void:
	var truppa: Array = schiera["soldati"]
	if tipo() == "tiratori":
		for k in mini(3, truppa.size()):
			var s: Colono = truppa[_rng.randi_range(0, truppa.size() - 1)]
			_proiettili.append([s.pos, centro + Vector2(_rng.randf_range(-0.6, 0.6), _rng.randf_range(-0.6, 0.6)), 0.0])
	else:
		_polvere.append([centro + Vector2(_rng.randf_range(-1.0, 1.0), _rng.randf_range(-1.0, 1.0)), 0.0])


func _avanza_effetti(delta: float) -> void:
	for pr in _proiettili:
		pr[2] += delta
	_proiettili = _proiettili.filter(func(pr): return pr[2] < VOLO)
	for po in _polvere:
		po[1] += delta
	_polvere = _polvere.filter(func(po): return po[1] < 0.8)


## Un duello: vince il nostro (con il vantaggio dei duelli e il condottiero che dà coraggio) o il difensore.
func _combatti(b) -> void:
	if b is Edificio and b.mura > 0.0:
		_colpisci_mura(b)
		return
	var tipo_dif := "fanteria"
	if b is Edificio:
		tipo_dif = Popoli.tipo_soldato(Popoli.di(b.proprietario))
	if _rng.randf() < probabilita_vittoria(tipo_dif):
		esperienza += 1
		_cambia_morale(3)
		if b is Edificio:
			b.soldati -= 1
			if b.soldati <= 0:
				guerra._conquista(b, 1)
				_fine_assalto("%s ha preso la torre!" % nome_condottiero())
		else:
			_difensori_villaggio -= 1
			if _difensori_villaggio <= 0:
				indigeni.prendi(b)
				_fine_assalto("")
	else:
		_cambia_morale(-4)
		_perdi_soldato()


func _perdi_soldato() -> void:
	var truppa: Array = schiera["soldati"]
	if truppa.is_empty():
		var capo: Colono = schiera["condottiero"]
		capo.queue_free()
		_perdi_macchine()
		villaggio.messaggio.emit("%s si ritira ferito: la schiera è sciolta" % nome_condottiero(), true)
		schiera = {}
		scelta = false
		cambiata.emit()
		queue_redraw()
		return
	var s: Colono = truppa.pop_back()
	s.queue_free()
	cambiata.emit()


# ------------------------------------------------------------ assedi (step 36)

func macchine() -> Dictionary:
	return schiera.get("macchine", {}) if esiste() else {}


## Quale edificio costruisce la macchina (l'armaiolo, o la stalla per l'elefante).
static func edificio_macchina(t: String) -> String:
	return MACCHINE[t].get("edificio", "armaiolo")


## La macchina c'è per il popolo del giocatore? (l'elefante solo per i Cartaginesi)
static func macchina_del_popolo(t: String) -> bool:
	return MACCHINE[t].get("popolo", Popoli.giocatore) == Popoli.giocatore


func _foglio_macchina(t: String, lavoro: bool) -> String:
	if t == "elefante":
		t = "elefante_guerra"
	var nome: String = t + {"ariete": "_colpo", "onagro": "_tiro"}.get(t, "_lotta") if lavoro else t
	if ResourceLoader.exists("res://assets/grafica/%s.png" % nome):
		return nome
	return "portatore_nessuno"


## Perché l'armaiolo non può costruire questa macchina adesso («» se può).
func motivo_no_macchina(t: String) -> String:
	if not attive():
		return "Le macchine d'assedio non ci sono in questa partita"
	if not macchina_del_popolo(t):
		return "Solo i %s hanno questa unità" % Popoli.nome(MACCHINE[t]["popolo"])
	if not esiste():
		return "Serve una schiera da seguire"
	if in_viaggio():
		return "La schiera è in mare"
	if macchine().has(t):
		return "%s ha già il suo %s" % [nome_condottiero(), MACCHINE[t]["nome"].to_lower()]
	var costo: Dictionary = MACCHINE[t]["costo"]
	for m in costo:
		if villaggio.scorte.get(m, 0) < costo[m]:
			return "Servono " + ", ".join(costo.keys().map(func(k): return "%d %s" % [costo[k], CatalogoEdifici.NOMI_RISORSE.get(k, k).to_lower()]))
	return ""


## L'armaiolo costruisce la macchina, che esce dalla bottega e raggiunge la schiera.
func costruisci_macchina(t: String, armaiolo: Edificio) -> bool:
	if motivo_no_macchina(t) != "":
		return false
	var costo: Dictionary = MACCHINE[t]["costo"]
	for m in costo:
		villaggio.scorte[m] -= costo[m]
	villaggio.scorte_cambiate.emit()
	var inizio := Vector2(armaiolo.bandiera) + Vector2(0.5, 0.6)
	var c := _nuovo(inizio, _foglio_macchina(t, false))
	c.velocita = 0.8
	schiera["macchine"][t] = c
	var capo: Colono = schiera["condottiero"]
	var percorso := percorso_a_piedi(Vector2i(inizio.floor()), Vector2i(capo.pos.floor()))
	if not percorso.is_empty():
		percorso[-1] = capo.pos + _posto_macchina(t, 3)
		c.percorri(percorso)
	if t == "elefante":
		villaggio.messaggio.emit("Un elefante da guerra esce dalla stalla e segue %s" % nome_condottiero(), false)
	else:
		villaggio.messaggio.emit("L'armaiolo ha costruito l'%s: segue la schiera di %s" % [MACCHINE[t]["nome"].to_lower(), nome_condottiero()], false)
	Suono.suona("completato")
	cambiata.emit()
	return true


## Assi, pietre e armi delle macchine (nel salvataggio tornano nel magazzino: le macchine non si salvano).
func materiali() -> Dictionary:
	var m := {}
	for t in macchine():
		var costo: Dictionary = MACCHINE[t]["costo"]
		for k in costo:
			m[k] = m.get(k, 0) + costo[k]
	return m


## Le torri nemiche si fanno le mura e le rialzano col tempo (non quella che stiamo assediando).
func _rinforza_mura(delta: float) -> void:
	var assediata = schiera.get("bersaglio") if esiste() else null
	if typeof(assediata) != TYPE_OBJECT:
		assediata = null
	for n in villaggio.nemici.values():
		if n.mura < 0.0:
			n.mura = MURA_INIZIO
			n.queue_redraw()
		elif n.mura < MURA_MAX and n != assediata:
			var prima := ceili(n.mura)
			n.mura = minf(MURA_MAX, n.mura + delta / RIFORZO_MURA)
			if ceili(n.mura) != prima:
				n.queue_redraw()


## Un colpo sotto le mura: i soldati (e l'ariete, se è lì) le abbattono un po'; senza ariete
## dagli spalti piovono sassi e un soldato può cadere.
func _colpisci_mura(b: Edificio) -> void:
	var danno := 1.0
	var ariete: Colono = macchine().get("ariete")
	if ariete and ariete.pos.distance_to(b.centro()) > distanza_assalto() + 2.0:
		return          # i soldati aspettano al riparo che arrivi l'ariete
	if ariete:
		danno += MACCHINE["ariete"]["danno"]
		ariete.imposta_foglio(_foglio_macchina("ariete", true))
		ariete._anim.play()
		Suono.suona_in("martello", b.position, 2.0)
	var elefante: Colono = macchine().get("elefante")
	if elefante and elefante.pos.distance_to(b.centro()) <= distanza_assalto() + 2.0:
		danno += MACCHINE["elefante"]["danno"]
		elefante.imposta_foglio(_foglio_macchina("elefante", true))
		elefante._anim.play()
	b.mura = maxf(0.0, b.mura - danno)
	b.queue_redraw()
	if b.mura <= 0.0:
		villaggio.messaggio.emit("Le mura sono crollate: all'assalto!", false)
		return
	if ariete == null and elefante == null and _rng.randf() < RISCHIO_MURA:
		_cambia_morale(-2)
		_perdi_soldato()


## L'onagro tira da lontano: prima sulle mura, poi (a mura giù) sui difensori.
func _onagro(b: Edificio, delta: float) -> void:
	var onagro: Colono = macchine().get("onagro")
	if onagro == null or onagro.in_cammino():
		return
	if onagro.pos.distance_to(b.centro()) > DISTANZA_ONAGRO:
		return
	_tiro_onagro -= delta
	if _tiro_onagro > 0.0:
		return
	_tiro_onagro = RICARICA_ONAGRO
	onagro.imposta_foglio(_foglio_macchina("onagro", true))
	onagro._anim.play()
	_massi.append([onagro.pos, b.centro() + Vector2(_rng.randf_range(-0.4, 0.4), _rng.randf_range(-0.4, 0.4)), 0.0, b])


func _avanza_massi(delta: float) -> void:
	for m in _massi:
		m[2] += delta
		if m[2] >= VOLO_MASSO and m.size() > 3:
			var b = m[3]
			m.resize(3)
			if not is_instance_valid(b) or not villaggio.nemici.has(b.id):
				continue
			Suono.suona_in("piccone", b.position, 3.0)
			if b.mura > 0.0:
				b.mura = maxf(0.0, b.mura - MACCHINE["onagro"]["danno"])
				b.queue_redraw()
				if b.mura <= 0.0:
					villaggio.messaggio.emit("L'onagro ha aperto una breccia nelle mura!", false)
			elif b.soldati > 1 and _rng.randf() < 0.4:
				b.soldati -= 1
			_polvere.append([b.centro(), 0.0])
	_massi = _massi.filter(func(m): return m[2] < VOLO_MASSO + 0.05)


func _perdi_macchine() -> void:
	for t in macchine():
		macchine()[t].queue_free()
	if esiste():
		schiera["macchine"] = {}


func _fine_assalto(testo: String) -> void:
	schiera["bersaglio"] = null
	_difensori_villaggio = -1
	var capo: Colono = schiera["condottiero"]
	capo.imposta_foglio(_foglio_condottiero(false))
	for s in schiera["soldati"]:
		s.imposta_foglio(Popoli.soldati(1)[0])
	for t in macchine():
		macchine()[t].imposta_foglio(_foglio_macchina(t, false))
		macchine()[t]._ferma()
	if testo != "":
		villaggio.messaggio.emit(testo, false)
	cambiata.emit()


## Cerchio sotto il condottiero scelto e barra della forza della schiera.
func _draw() -> void:
	for pr in _proiettili:
		var f: float = pr[2] / VOLO
		var a := dati.a_schermo(pr[0].x, pr[0].y)
		var b := dati.a_schermo(pr[1].x, pr[1].y)
		var q := a.lerp(b, f) + Vector2(0, -40.0 * sin(f * PI) - 20.0)
		draw_circle(q, 2.5, Color("3a3028"))
	for m in _massi:
		var f: float = minf(1.0, m[2] / VOLO_MASSO)
		var a := dati.a_schermo(m[0].x, m[0].y)
		var b := dati.a_schermo(m[1].x, m[1].y)
		var q := a.lerp(b, f) + Vector2(0, -110.0 * sin(f * PI) - 30.0)
		draw_circle(q, 6.0, Color("5a5048"))
		draw_circle(q + Vector2(-1.5, -1.5), 3.0, Color("8a8070"))
	for po in _polvere:
		var t: float = po[1] / 0.8
		draw_circle(dati.a_schermo(po[0].x, po[0].y) + Vector2(0, -10), 8.0 + 14.0 * t, Color(0.82, 0.74, 0.58, 0.45 * (1.0 - t)))
	if not esiste():
		return
	var capo: Colono = schiera["condottiero"]
	var p := dati.a_schermo(capo.pos.x, capo.pos.y)
	if scelta:
		draw_arc(p, 26.0, 0.0, TAU, 32, Color(Palette.PERGAMENA_CHIARA, 0.9), 3.0)
	var forza := float(soldati()) / MAX_SOLDATI
	var barra := Rect2(p + Vector2(-24, -104), Vector2(48, 6))
	draw_rect(barra, Color(0, 0, 0, 0.55))
	draw_rect(Rect2(barra.position, Vector2(48 * forza, 6)), Color("6fbf4a") if forza > 0.4 else Color("d0a030"))
	# morale (azzurro) e razioni (ocra) sotto la forza, livello del condottiero accanto
	var morale := Rect2(barra.position + Vector2(0, 8), Vector2(48, 4))
	draw_rect(morale, Color(0, 0, 0, 0.55))
	draw_rect(Rect2(morale.position, Vector2(48 * schiera["morale"] / 100.0, 4)), Color("6fb0e0"))
	var cibo := Rect2(morale.position + Vector2(0, 6), Vector2(48, 4))
	draw_rect(cibo, Color(0, 0, 0, 0.55))
	draw_rect(Rect2(cibo.position, Vector2(48.0 * schiera["razioni"] / RAZIONI_MAX, 4)), Color("d8a040"))
	draw_string(ThemeDB.fallback_font, barra.position + Vector2(52, 8), "liv %d" % livello(), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Palette.PERGAMENA_CHIARA)


## Rimanda i soldati nella riserva (per il salvataggio: la schiera si riforma dopo il caricamento).
func scioglie() -> void:
	if not esiste():
		return
	villaggio.soldati += soldati()
	for s in schiera["soldati"]:
		s.queue_free()
	_perdi_macchine()
	schiera["condottiero"].queue_free()
	schiera = {}
	scelta = false
