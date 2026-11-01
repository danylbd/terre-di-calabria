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
	schiera = {"condottiero": capo, "soldati": truppa, "bersaglio": null}
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


func _process(delta: float) -> void:
	if not esiste():
		return
	queue_redraw()
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
	var vittoria: float = 0.55 + villaggio.vantaggi.get("duelli", 0.0)
	if _rng.randf() < vittoria:
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
	var barra := Rect2(p + Vector2(-24, -96), Vector2(48, 6))
	draw_rect(barra, Color(0, 0, 0, 0.55))
	draw_rect(Rect2(barra.position, Vector2(48 * forza, 6)), Color("6fbf4a") if forza > 0.4 else Color("d0a030"))


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
