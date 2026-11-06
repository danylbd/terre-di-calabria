class_name ReteStrade
extends Node2D
## Rete stradale: bandierine (nodi) collegate da tratti di strada.
## Ogni tratto collegato al magazzino riceve un portatore che aspetta a metà strada.
## (Nello step 04 i portatori inizieranno a passarsi le merci di bandierina in bandierina.)

signal cambiata
signal portatore_nuovo(p: Portatore)
signal merce_rilasciata(m: Merce)

const T := DatiMappa.Terreno
const TEXTURE_STRADA := preload("res://assets/terreno/strada.png")


class Tratto:
	var id := 0
	var a := Vector2i.ZERO
	var b := Vector2i.ZERO
	var percorso: Array[Vector2i] = []
	var linea: Line2D
	var portatore: Portatore


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
var _adiacenti := {}          # bandierina -> [Tratto]
var _instradamento := {}      # destinazione -> {bandierina: prossima bandierina}


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


func aggiungi_bandiera(c: Vector2i, protetta := false, forza := false) -> bool:
	if bandiere.has(c):
		if protetta:
			bandiere[c]["protetta"] = true
		return true
	if not forza and motivo_no_bandiera(c) != "":
		return false
	var s := Sprites.crea("bandierina")
	# La rete resta logica: i simboli si mostrano come anelli temporanei nello strumento Collegamento.
	s.visible = false
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
		for e in villaggio.edifici.values():
			if e.bandiera == c:
				return
		bandiere[c]["protetta"] = false


# ------------------------------------------------------------ strade

## Percorso migliore da una bandierina a una casella (vuoto se impossibile).
func trova_percorso(da: Vector2i, a: Vector2i) -> Array[Vector2i]:
	var vuoto: Array[Vector2i] = []
	# Un clic impreciso su una strada o accanto a un nodo esistente deve comunque
	# raggiungere quel nodo, senza richiedere una nuova casella per la bandierina.
	if not bandiere.has(a) and (strada.has(a) or _albero_attraversabile(a) or motivo_spaziatura(a) != ""):
		var nodo_vicino := bandiera_vicina(a)
		if nodo_vicino.x >= 0:
			a = nodo_vicino
	if not bandiere.has(da) or da == a or not dati.dentro(a.x, a.y):
		return vuoto
	if not bandiere.has(a):
		if motivo_spaziatura(a) != "":
			return vuoto
		if motivo_no_bandiera(a) != "" and not _albero_attraversabile(a):
			return vuoto
	_aggiorna_ostacoli()
	var p := _percorso_tra_uscite(da, a)
	if p.size() < 2:
		return vuoto
	for c in p:
		if not dati.nel_territorio(c.x, c.y):
			return vuoto
	return p


## Una bandierina può avere strade in tutte le 8 direzioni: si cerca il percorso tra le sue
## caselle d'uscita libere (anche in diagonale tra due strade che partono dalla stessa bandierina).
func _percorso_tra_uscite(da: Vector2i, a: Vector2i) -> Array[Vector2i]:
	var migliore: Array[Vector2i] = []
	if (da - a).abs().x <= 1 and (da - a).abs().y <= 1:
		migliore.assign([da, a])
		return migliore
	var uscite_da := _uscite(da, a)
	var uscite_a := _uscite(a, da)
	var era_solido := _astar.is_point_solid(a)
	if not bandiere.has(a):
		uscite_a = [a] as Array[Vector2i]
		_astar.set_point_solid(a, false)
	var limite_da := mini(4, uscite_da.size())
	var limite_a := mini(4, uscite_a.size())
	var minimo_teorico := maxi(absi(da.x - a.x), absi(da.y - a.y)) + 1
	for espansione in 2:
		for i in limite_da:
			for j in limite_a:
				var u: Vector2i = uscite_da[i]
				var v: Vector2i = uscite_a[j]
				var tratto: Array[Vector2i] = [u]
				if u != v:
					tratto = _astar.get_id_path(u, v)
				if tratto.is_empty():
					continue
				var tot: Array[Vector2i] = [da]
				tot.append_array(tratto)
				if tot[-1] != a:
					tot.append(a)
				if migliore.is_empty() or tot.size() < migliore.size():
					migliore = tot
		# In terreno libero bastano gli accessi migliori. Se la via trovata fa
		# una deviazione, prova anche gli altri lati prima di scegliere il tracciato.
		if not migliore.is_empty() and migliore.size() <= minimo_teorico:
			break
		limite_da = uscite_da.size()
		limite_a = uscite_a.size()
	_astar.set_point_solid(a, era_solido)
	return migliore


func _uscite(f: Vector2i, verso: Vector2i) -> Array[Vector2i]:
	var r: Array[Vector2i] = []
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			var n := f + Vector2i(dx, dy)
			if (dx != 0 or dy != 0) and _astar.is_in_boundsv(n) and not _astar.is_point_solid(n):
				r.append(n)
	r.sort_custom(func(p1, p2): return (p1 - verso).length_squared() < (p2 - verso).length_squared())
	return r


func motivo_spaziatura(c: Vector2i) -> String:
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			if (dx != 0 or dy != 0) and bandiere.has(c + Vector2i(dx, dy)):
				return "Troppo vicina a un'altra bandierina"
	return ""


func bandiera_vicina(c: Vector2i) -> Vector2i:
	var migliore := Vector2i(-1, -1)
	var distanza := INF
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			var candidato := c + Vector2i(dx, dy)
			if bandiere.has(candidato):
				var d := Vector2(candidato - c).length_squared()
				if d < distanza:
					distanza = d
					migliore = candidato
	return migliore


func _albero_attraversabile(c: Vector2i) -> bool:
	if villaggio == null or villaggio.risorse == null:
		return false
	return (villaggio.risorse.alberi.has(c) or villaggio.risorse.ulivi.has(c)) and not villaggio.risorse.rocce.has(c)


## Costruisce la strada; se l'arrivo non è una bandierina ne pianta una. Restituisce la bandierina d'arrivo.
func costruisci_strada(percorso: Array[Vector2i]) -> bool:
	if percorso.size() < 2:
		return false
	var arrivo: Vector2i = percorso[-1]
	# Sposta gli alberi lungo il tracciato prima di creare il nodo di arrivo:
	# una foresta non deve spezzare una strada né rendere irraggiungibile il collegamento.
	for c in percorso:
		if _albero_attraversabile(c):
			villaggio.risorse.sgombra_per_strada(c)
			_ostacoli_vecchi = true
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
		var m := t.portatore.annulla()
		if m:
			merce_rilasciata.emit(m)
		t.portatore.queue_free()
		villaggio.restituisci_colono(t.portatore.casa_origine)
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
			var occupante := dati.occupante(x, y)
			var albero := occupante == DatiMappa.NATURA and _albero_attraversabile(c)
			var solido := t == T.ACQUA or t == T.NEVE or (occupante != 0 and not albero) or strada.has(c) or bandiere.has(c) or not dati.nel_territorio(x, y)
			_astar.set_point_solid(c, solido)


func segna_ostacoli_vecchi() -> void:
	_ostacoli_vecchi = true


## Quali bandierine sono collegate a un magazzino, e manda i portatori ai tratti nuovi.
func _ricalcola() -> void:
	var adiacenti := {}
	for t in tratti.values():
		adiacenti.get_or_add(t.a, []).append(t)
		adiacenti.get_or_add(t.b, []).append(t)
	_adiacenti = adiacenti
	_instradamento.clear()
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
	manda_portatori_mancanti()
	cambiata.emit()


## Ogni tratto collegato senza portatore ne riceve uno, se nel villaggio ci sono coloni liberi.
func manda_portatori_mancanti() -> void:
	for t in tratti.values():
		if t.portatore == null and _collegate.has(t.a) and villaggio.prendi_colono():
			_manda_portatore(t, _adiacenti, villaggio.ultima_origine_colono)


func tratti_senza_portatore() -> int:
	var n := 0
	for t in tratti.values():
		if t.portatore == null and _collegate.has(t.a):
			n += 1
	return n


func portatori() -> int:
	var n := 0
	for t in tratti.values():
		if t.portatore:
			n += 1
	return n


func _manda_portatore(t: Tratto, adiacenti: Dictionary, origine := Vector2i(-1, -1)) -> void:
	# Il portatore parte dalla casa in cui aspettava e raggiunge il proprio tratto.
	var mag := villaggio.magazzino()
	if origine == Vector2i(-1, -1) and mag:
		origine = mag.bandiera
	var punti: Array[Vector2] = []
	var casa := villaggio.edificio_con_bandiera(origine)
	if casa:
		punti.append(casa.centro())
	var strada := percorso_tra_bandiere(origine, t.a)
	if strada.is_empty() and origine != t.a:
		origine = mag.bandiera if mag else t.a
		punti.clear()
		if mag:
			punti.append(mag.centro())
		strada = percorso_tra_bandiere(origine, t.a)
	punti.append_array(strada)
	var percorso_tratto := t.percorso.duplicate()
	if percorso_tratto[0] != t.a:
		percorso_tratto.reverse()
	for c in percorso_tratto:
		punti.append(Vector2(c) + Vector2(0.5, 0.5))
	var nuovo := Portatore.new()
	nuovo.agile = Popoli.giocatore == "brettii"
	nuovo.velocita *= Popoli.passo()
	nuovo.tratto = t
	nuovo.casa_origine = origine
	oggetti.add_child(nuovo)
	var meta_punti := t.percorso.size() / 2
	for k in meta_punti + 1:
		punti.append(Vector2(t.percorso[k]) + Vector2(0.5, 0.5))
	punti[-1] = nuovo.punto_meta()
	nuovo.prepara(dati, punti[0])
	nuovo.percorri(punti)
	t.portatore = nuovo
	portatore_nuovo.emit(nuovo)



# ------------------------------------------------------------ instradamento delle merci

func tratto_tra(f1: Vector2i, f2: Vector2i) -> Tratto:
	for t in _adiacenti.get(f1, []):
		if (t.a == f1 and t.b == f2) or (t.b == f1 and t.a == f2):
			return t
	return null


## Prossima bandierina sulla strada più corta da "da" verso "a" (Vector2i(-1, -1) se non c'è strada).
func prossimo_salto(da: Vector2i, a: Vector2i) -> Vector2i:
	if not _instradamento.has(a):
		_instradamento[a] = _calcola_verso(a)
	return _instradamento[a].get(da, Vector2i(-1, -1))


func _calcola_verso(a: Vector2i) -> Dictionary:
	# Dijkstra all'indietro dalla destinazione: per ogni bandierina, il primo passo verso "a"
	var dist := {a: 0.0}
	var prossimo := {}
	var aperti: Array[Vector2i] = [a]
	while aperti.size() > 0:
		var migliore := 0
		for k in aperti.size():
			if dist[aperti[k]] < dist[aperti[migliore]]:
				migliore = k
		var f: Vector2i = aperti[migliore]
		aperti.remove_at(migliore)
		for t in _adiacenti.get(f, []):
			var altra: Vector2i = t.b if t.a == f else t.a
			var d: float = dist[f] + t.percorso.size()
			if d < dist.get(altra, INF):
				dist[altra] = d
				prossimo[altra] = f
				if not aperti.has(altra):
					aperti.append(altra)
	return prossimo



## Punti (coordinate di mappa) per camminare sulle strade da una bandierina a un'altra.
func percorso_tra_bandiere(da: Vector2i, a: Vector2i) -> Array[Vector2]:
	var punti: Array[Vector2] = [Vector2(da) + Vector2(0.5, 0.5)]
	var f := da
	var giri := 0
	while f != a and giri < 200:
		giri += 1
		var prossima := prossimo_salto(f, a)
		if prossima.x < 0:
			return [] as Array[Vector2]
		var t := tratto_tra(f, prossima)
		var p: Array[Vector2i] = t.percorso.duplicate()
		if p[0] != f:
			p.reverse()
		for k in range(1, p.size()):
			punti.append(Vector2(p[k]) + Vector2(0.5, 0.5))
		f = prossima
	return punti
