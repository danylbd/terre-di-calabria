class_name Schiere
extends Node2D
## Condottieri e schiere (step 31, Fase 7 — idee da Imperivm, docs/piano-imperivm.md): il condottiero del
## popolo esce dalla caserma o dal castello con fino a 12 soldati presi dalla riserva. Si comanda in modo
## diretto: clic sul condottiero per sceglierlo, poi clic sulla terra (va lì), su una torre nemica o su un
## villaggio indigeno (attacca). L'economia resta alla Settlers. Non c'è nella partita in pace.

signal cambiata

const MAX_SOLDATI := 12
const DURATA_DUELLO := 1.5
const DISTANZA_ASSALTO := 3.5        # caselle dal bersaglio entro cui la schiera combatte
## step 32: cibo, morale ed esperienza
const RAZIONI_MAX := 20
const CONSUMO := 20.0                # secondi per ogni razione mangiata dalla schiera
const FAME := 30.0                   # senza razioni, ogni tanto un soldato se ne va
const RAGGIO_MAGAZZINO := 6.0        # vicino a un nostro magazzino la schiera si rifornisce e si rinforza
const ESPERIENZA_LIVELLO := 10       # duelli vinti per ogni livello del condottiero
const LIVELLO_MAX := 5
const NOMI := {"greci": "Eudora", "brettii": "Tauro", "romani": "Gaio Settimio", "saraceni": "Zahra",
	"normanni": "Osmund", "siculi": "Duketio", "sicani": "Kokalo"}

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


static func attive() -> bool:
	return Impostazioni.condottieri and Impostazioni.modalita != "pace" and Impostazioni.missione == ""


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
	schiera = {"condottiero": capo, "soldati": truppa, "bersaglio": null, "razioni": 0, "morale": 70}
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


## Il posto di un soldato nella formazione: file di 4 dietro al condottiero.
func _posto(k: int) -> Vector2:
	return Vector2((k % 4) * 0.45 - 0.7, (k / 4 + 1) * 0.5)


## Il condottiero è in questa casella (o lì vicino)?
func in_casella(c: Vector2i) -> bool:
	return esiste() and Vector2(c) .distance_to(schiera["condottiero"].pos.floor()) <= 1.0


func scegli(si: bool) -> void:
	scelta = si and esiste()
	queue_redraw()


## Ordine di andare in una casella: il percorso più breve a piedi (niente mare, niente edifici).
func muovi(c: Vector2i) -> bool:
	if not esiste():
		return false
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


## Attacca una torre nemica o un villaggio indigeno: la schiera ci va e combatte.
func attacca(bersaglio) -> bool:
	if not esiste():
		return false
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
	var percorso := percorso_a_piedi(Vector2i(capo.pos.floor()), vicino)
	if percorso.is_empty():
		return false
	schiera["bersaglio"] = bersaglio
	_marcia(percorso)
	return true


func _vicino_a_piedi(c: Vector2i) -> Vector2i:
	for r in range(2, 6):
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


## Il livello del condottiero (1–5): sale con i duelli vinti dalla sua schiera.
func livello() -> int:
	return mini(LIVELLO_MAX, 1 + esperienza / ESPERIENZA_LIVELLO)


## Probabilità che un nostro soldato vinca un duello: base, vantaggi dei monumenti, morale e livello.
func probabilita_vittoria() -> float:
	var morale: float = schiera.get("morale", 70) if esiste() else 70.0
	return clampf(0.55 + villaggio.vantaggi.get("duelli", 0.0) + (morale - 50.0) / 500.0 + 0.02 * (livello() - 1), 0.1, 0.9)


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
	if not esiste():
		return
	queue_redraw()
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
	if capo.pos.distance_to(centro) > DISTANZA_ASSALTO:
		return
	_duello -= delta
	if _duello > 0.0:
		return
	_duello = DURATA_DUELLO
	capo.imposta_foglio(_foglio_condottiero(true))
	for s in schiera["soldati"]:
		s.imposta_foglio(Popoli.soldati(1)[1])
	_combatti(b)


## Un duello: vince il nostro (con il vantaggio dei duelli e il condottiero che dà coraggio) o il difensore.
func _combatti(b) -> void:
	if _rng.randf() < probabilita_vittoria():
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
		villaggio.messaggio.emit("%s si ritira ferito: la schiera è sciolta" % nome_condottiero(), true)
		schiera = {}
		scelta = false
		cambiata.emit()
		queue_redraw()
		return
	var s: Colono = truppa.pop_back()
	s.queue_free()
	cambiata.emit()


func _fine_assalto(testo: String) -> void:
	schiera["bersaglio"] = null
	_difensori_villaggio = -1
	var capo: Colono = schiera["condottiero"]
	capo.imposta_foglio(_foglio_condottiero(false))
	for s in schiera["soldati"]:
		s.imposta_foglio(Popoli.soldati(1)[0])
	if testo != "":
		villaggio.messaggio.emit(testo, false)
	cambiata.emit()


## Cerchio sotto il condottiero scelto e barra della forza della schiera.
func _draw() -> void:
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
	schiera["condottiero"].queue_free()
	schiera = {}
	scelta = false
