class_name ReteStrade
extends Node2D
## Rete stradale: bandierine (nodi) collegate da tratti di strada.
## Ogni tratto collegato al magazzino riceve un portatore che aspetta a metà strada.
## (Nello step 04 i portatori inizieranno a passarsi le merci di bandierina in bandierina.)

signal cambiata

const T := DatiMappa.Terreno
const LUNGHEZZA_MAX := 32
const TEXTURE_STRADA := preload("res://assets/terreno/strada.png")


class Tratto:
	var id := 0
	var a := Vector2i.ZERO
	var b := Vector2i.ZERO
	var percorso: Array[Vector2i] = []
	var linea: Line2D
	var portatore: Colono


var dati: DatiMappa
var villaggio: Villaggio
var oggetti: Node2D
var bandiere := {}            # Vector2i -> {"sprite": Sprite2D, "protetta": bool}
var tratti := {}              # id -> Tratto
var strada := {}              # Vector2i (caselle interne dei tratti) -> id del tratto
var _astar := AStarGrid2D.new()
var _ostacoli_vecchi := true
var _prossimo_id := 1
var _anteprima: Line2D
var _collegate := {}          # bandierine raggiungibili da un magazzino


func prepara(d: DatiMappa, v: Villaggio, nodo_oggetti: Node2D) -> void:
	dati = d
	villaggio = v
	oggetti = nodo_oggetti
	_astar.region = Rect2i(0, 0, d.larghezza, d.altezza)
	_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	_astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	_astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	_astar.update()
	for y in d.altezza:
		for x in d.larghezza:
			var pendenza := absf(d.quota_vertice(x, y) - d.quota_vertice(x + 1, y + 1)) + absf(d.quota_vertice(x + 1, y) - d.quota_vertice(x, y + 1))
			_astar.set_point_weight_scale(Vector2i(x, y), 1.0 + pendenza / 18.0)
	_anteprima = _nuova_linea()
	_anteprima.visible = false
	add_child(_anteprima)


# ------------------------------------------------------------ bandierine

func bandiera_in(c: Vector2i) -> bool:
	return bandiere.has(c)


func motivo_no_bandiera(c: Vector2i) -> String:
	if not dati.dentro(c.x, c.y) or not dati.nel_territorio(c.x, c.y):
		return "Fuori dai tuoi confini"
	if bandiere.has(c):
		return "C'è già una bandierina"
	if dati.tipo(c.x, c.y) in [T.ACQUA, T.NEVE]:
		return "Terreno non adatto"
	if dati.occupante(c.x, c.y) != 0:
		return "Posto occupato"
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			if (dx != 0 or dy != 0) and bandiere.has(c + Vector2i(dx, dy)):
				return "Troppo vicina a un'altra bandierina"
	return ""


func aggiungi_bandiera(c: Vector2i, protetta := false) -> bool:
	if bandiere.has(c):
		if protetta:
			bandiere[c]["protetta"] = true
		return true
	if motivo_no_bandiera(c) != "":
		return false
	var s := Sprites.crea("bandierina")
	s.scale = Vector2.ONE * 1.5
	s.position = dati.a_schermo(c.x + 0.5, c.y + 0.5)
	oggetti.add_child(s)
	bandiere[c] = {"sprite": s, "protetta": protetta}
	_ostacoli_vecchi = true
	# una bandierina piantata su una strada la divide in due tratti
	if strada.has(c):
		_dividi(tratti[strada[c]], c)
	_ricalcola()
	return true


func rimuovi_bandiera(c: Vector2i) -> String:
	if not bandiere.has(c):
		return ""
	if bandiere[c]["protetta"]:
		return "È la bandierina di un edificio"
	for t in tratti.values().duplicate():
		if t.a == c or t.b == c:
			_rimuovi_tratto(t)
	(bandiere[c]["sprite"] as Node).queue_free()
	bandiere.erase(c)
	_ostacoli_vecchi = true
	_ricalcola()
	return "Bandierina rimossa"


func libera_protezione(c: Vector2i) -> void:
	if bandiere.has(c):
		bandiere[c]["protetta"] = false


# ------------------------------------------------------------ strade

## Percorso migliore da una bandierina a una casella (vuoto se impossibile).
func trova_percorso(da: Vector2i, a: Vector2i) -> Array[Vector2i]:
	var vuoto: Array[Vector2i] = []
	if not bandiere.has(da) or da == a or not dati.dentro(a.x, a.y):
		return vuoto
	if not bandiere.has(a) and motivo_no_bandiera(a) != "" and not strada.has(a):
		return vuoto
	if strada.has(a) and motivo_spaziatura(a) != "":
		return vuoto
	_aggiorna_ostacoli()
	_astar.set_point_solid(da, false)
	_astar.set_point_solid(a, false)
	var p := _astar.get_id_path(da, a)
	_astar.set_point_solid(da, true)
	_astar.set_point_solid(a, true)
	if p.size() < 2 or p.size() > LUNGHEZZA_MAX:
		return vuoto
	for c in p:
		if not dati.nel_territorio(c.x, c.y):
			return vuoto
	var r: Array[Vector2i] = []
	r.assign(p)
	return r


func motivo_spaziatura(c: Vector2i) -> String:
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			if (dx != 0 or dy != 0) and bandiere.has(c + Vector2i(dx, dy)):
				return "Troppo vicina a un'altra bandierina"
	return ""


## Costruisce la strada; se l'arrivo non è una bandierina ne pianta una. Restituisce la bandierina d'arrivo.
func costruisci_strada(percorso: Array[Vector2i]) -> bool:
	if percorso.size() < 2:
		return false
	var arrivo: Vector2i = percorso[-1]
	if not bandiere.has(arrivo):
		if not aggiungi_bandiera(arrivo):
			return false
	var t := Tratto.new()
	t.id = _prossimo_id
	_prossimo_id += 1
	t.a = percorso[0]
	t.b = arrivo
	t.percorso = percorso
	_disegna(t)
	tratti[t.id] = t
	for k in range(1, percorso.size() - 1):
		strada[percorso[k]] = t.id
	_ostacoli_vecchi = true
	_ricalcola()
	return true


func tratto_in(c: Vector2i) -> Tratto:
	return tratti.get(strada.get(c, -1))


func rimuovi_strada_in(c: Vector2i) -> bool:
	var t := tratto_in(c)
	if t == null:
		return false
	_rimuovi_tratto(t)
	_ostacoli_vecchi = true
	_ricalcola()
	return true


func mostra_anteprima(percorso: Array[Vector2i], valido: bool) -> void:
	if percorso.size() < 2:
		_anteprima.visible = false
		return
	_anteprima.points = _punti_schermo(percorso)
	_anteprima.modulate = Color(0.85, 1.0, 0.8, 0.75) if valido else Color(1.0, 0.5, 0.45, 0.6)
	_anteprima.visible = true


func nascondi_anteprima() -> void:
	_anteprima.visible = false


func collegata(c: Vector2i) -> bool:
	return _collegate.has(c)


# ------------------------------------------------------------ interni

func _rimuovi_tratto(t: Tratto) -> void:
	for k in range(1, t.percorso.size() - 1):
		strada.erase(t.percorso[k])
	if t.linea:
		t.linea.queue_free()
	if t.portatore:
		t.portatore.queue_free()
	tratti.erase(t.id)


func _dividi(t: Tratto, c: Vector2i) -> void:
	var i := t.percorso.find(c)
	var primo: Array[Vector2i] = []
	primo.assign(t.percorso.slice(0, i + 1))
	var secondo: Array[Vector2i] = []
	secondo.assign(t.percorso.slice(i))
	_rimuovi_tratto(t)
	for parte in [primo, secondo]:
		var n := Tratto.new()
		n.id = _prossimo_id
		_prossimo_id += 1
		n.a = parte[0]
		n.b = parte[-1]
		n.percorso = parte
		_disegna(n)
		tratti[n.id] = n
		for k in range(1, parte.size() - 1):
			strada[parte[k]] = n.id


func _nuova_linea() -> Line2D:
	var l := Line2D.new()
	l.width = 40.0
	l.texture = TEXTURE_STRADA
	l.texture_mode = Line2D.LINE_TEXTURE_TILE
	l.joint_mode = Line2D.LINE_JOINT_ROUND
	l.begin_cap_mode = Line2D.LINE_CAP_ROUND
	l.end_cap_mode = Line2D.LINE_CAP_ROUND
	l.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	l.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	return l


func _disegna(t: Tratto) -> void:
	t.linea = _nuova_linea()
	t.linea.points = _punti_schermo(t.percorso)
	add_child(t.linea)
	move_child(_anteprima, -1)


func _punti_schermo(percorso: Array[Vector2i]) -> PackedVector2Array:
	var r := PackedVector2Array()
	for k in percorso.size():
		var c: Vector2i = percorso[k]
		r.append(dati.a_schermo(c.x + 0.5, c.y + 0.5))
		if k < percorso.size() - 1:
			var m := (Vector2(c) + Vector2(percorso[k + 1])) * 0.5 + Vector2(0.5, 0.5)
			r.append(dati.a_schermo(m.x, m.y))
	return r


func _aggiorna_ostacoli() -> void:
	if not _ostacoli_vecchi:
		return
	_ostacoli_vecchi = false
	for y in dati.altezza:
		for x in dati.larghezza:
			var c := Vector2i(x, y)
			var t := dati.tipo(x, y)
			var solido := t == T.ACQUA or t == T.NEVE or dati.occupante(x, y) != 0 or strada.has(c) or bandiere.has(c) or not dati.nel_territorio(x, y)
			_astar.set_point_solid(c, solido)


func segna_ostacoli_vecchi() -> void:
	_ostacoli_vecchi = true


## Quali bandierine sono collegate a un magazzino, e manda i portatori ai tratti nuovi.
func _ricalcola() -> void:
	var adiacenti := {}
	for t in tratti.values():
		adiacenti.get_or_add(t.a, []).append(t)
		adiacenti.get_or_add(t.b, []).append(t)
	_collegate.clear()
	var coda: Array[Vector2i] = []
	for e in villaggio.edifici.values():
		if e.tipo == "magazzino" and e.finito and bandiere.has(e.bandiera):
			_collegate[e.bandiera] = e.bandiera
			coda.append(e.bandiera)
	# visita in ampiezza: per ogni bandierina ricordo da dove si arriva (per i percorsi dei portatori)
	while coda.size() > 0:
		var f: Vector2i = coda.pop_front()
		for t in adiacenti.get(f, []):
			var altra: Vector2i = t.b if t.a == f else t.a
			if not _collegate.has(altra):
				_collegate[altra] = f
				coda.append(altra)
	for t in tratti.values():
		if t.portatore == null and _collegate.has(t.a):
			_manda_portatore(t, adiacenti)
	cambiata.emit()


func _manda_portatore(t: Tratto, adiacenti: Dictionary) -> void:
	# il portatore parte dal magazzino e segue la rete fino a metà del suo tratto
	var catena: Array[Vector2i] = [t.a]
	while _collegate[catena[0]] != catena[0]:
		catena.push_front(_collegate[catena[0]])
	var punti: Array[Vector2] = []
	for k in catena.size() - 1:
		var da: Vector2i = catena[k]
		var a: Vector2i = catena[k + 1]
		for tr in adiacenti.get(da, []):
			if (tr.a == da and tr.b == a) or (tr.b == da and tr.a == a):
				var p: Array[Vector2i] = tr.percorso.duplicate()
				if tr.b == da:
					p.reverse()
				for c in p:
					punti.append(Vector2(c) + Vector2(0.5, 0.5))
				break
	var meta := t.percorso.size() / 2
	for k in meta + 1:
		punti.append(Vector2(t.percorso[k]) + Vector2(0.5, 0.5))
	if t.percorso.size() % 2 == 0:
		# tratto con numero pari di caselle: aspetta tra le due centrali
		punti[-1] = (Vector2(t.percorso[meta - 1]) + Vector2(t.percorso[meta])) * 0.5 + Vector2(0.5, 0.5)
	var c := Colono.new()
	oggetti.add_child(c)
	c.prepara(dati, punti[0] if punti.size() > 0 else Vector2(t.a) + Vector2(0.5, 0.5))
	c.percorri(punti)
	t.portatore = c
