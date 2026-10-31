class_name RisorseNaturali
extends Node
## Alberi, rocce e ulivi della mappa: si consumano (abbattuti, estratti) e ricrescono (piantati).
## Anche i campi di grano seminati dai contadini e il pesce nei tratti di mare vicino alla riva.

const SPECIE_ABBATTIBILI := ["pino", "castagno", "quercia"]
const RISERVA_ROCCIA := 6
const TEMPO_CRESCITA := 45.0        # secondi per ogni fase dell'alberello (3 fasi)
const DURATA_CEPPO := 90.0
const TEMPO_CAMPO := 35.0           # secondi per ogni fase del grano (seminato, verde, alto, maturo)
const DURATA_STOPPIE := 40.0
const PESCE_MAX := 4                # pesci in ogni casella di mare vicino alla riva
const TEMPO_PESCE := 50.0           # secondi perché torni un pesce

var dati: DatiMappa
var oggetti: Node2D
var alberi := {}      # Vector2i -> Array[Dictionary] {sprite, specie, crescita (0..3, 3 = adulto), prenotato}
var rocce := {}       # Vector2i -> {sprite, riserva, prenotata}
var ulivi := {}       # Vector2i -> Array[Sprite2D]
var campi := {}       # Vector2i -> {sprite, crescita (0..3, 3 = maturo), prenotato}
var pesci := {}       # Vector2i (casella d'acqua) -> pesci rimasti (assente = pieno)
var _ripopola := {}   # Vector2i -> secondi al prossimo pesce
var _ceppi: Array = []  # [sprite, secondi rimasti]
var _rng := RandomNumberGenerator.new()


func prepara(d: DatiMappa, nodo_oggetti: Node2D) -> void:
	dati = d
	oggetti = nodo_oggetti
	_rng.seed = 77


## Registra uno sprite di natura messo dal generatore.
func registra(nome: String, c: Vector2i, s: Sprite2D) -> void:
	var specie := nome.get_slice("_", 0)
	if specie in SPECIE_ABBATTIBILI:
		alberi.get_or_add(c, []).append({"sprite": s, "specie": specie, "crescita": 3.0, "prenotato": false})
	elif specie == "rocce":
		rocce[c] = {"sprite": s, "riserva": RISERVA_ROCCIA, "prenotata": false}
	elif specie == "ulivo":
		ulivi.get_or_add(c, []).append(s)
	dati.occupa(c.x, c.y, DatiMappa.NATURA)


# ------------------------------------------------------------ ricerca

## Casella con un albero adulto libero più vicina a "da" entro "raggio" (Vector2i(-1,-1) se nessuna).
func albero_vicino(da: Vector2i, raggio: int) -> Vector2i:
	return _piu_vicino(da, raggio, func(c: Vector2i):
		for a in alberi.get(c, []):
			if a["crescita"] >= 3.0 and not a["prenotato"]:
				return true
		return false)


func roccia_vicina(da: Vector2i, raggio: int) -> Vector2i:
	return _piu_vicino(da, raggio, func(c: Vector2i): return rocce.has(c) and not rocce[c]["prenotata"])


## Casella libera adatta a un nuovo albero.
func posto_per_albero(da: Vector2i, raggio: int, rete: ReteStrade) -> Vector2i:
	var candidati: Array[Vector2i] = []
	for y in range(da.y - raggio, da.y + raggio + 1):
		for x in range(da.x - raggio, da.x + raggio + 1):
			var c := Vector2i(x, y)
			if not dati.dentro(x, y) or Vector2(c - da).length() > raggio or Vector2(c - da).length() < 2.0:
				continue
			if dati.occupante(x, y) != 0 or rete.strada.has(c) or rete.bandiere.has(c) or _vicino_a_bandiera(c, rete):
				continue
			if dati.tipo(x, y) in [DatiMappa.Terreno.PRATO, DatiMappa.Terreno.BOSCO, DatiMappa.Terreno.SECCO]:
				candidati.append(c)
	if candidati.is_empty():
		return Vector2i(-1, -1)
	return candidati[_rng.randi_range(0, candidati.size() - 1)]


func _vicino_a_bandiera(c: Vector2i, rete: ReteStrade) -> bool:
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			if rete.bandiere.has(c + Vector2i(dx, dy)):
				return true
	return false


func _piu_vicino(da: Vector2i, raggio: int, filtro: Callable) -> Vector2i:
	var migliore := Vector2i(-1, -1)
	var dist := INF
	for y in range(da.y - raggio, da.y + raggio + 1):
		for x in range(da.x - raggio, da.x + raggio + 1):
			var c := Vector2i(x, y)
			var d := Vector2(c - da).length()
			if d <= raggio and d < dist and filtro.call(c) and _raggiungibile(da, c):
				dist = d
				migliore = c
	return migliore


## Il lavoratore va a piedi in linea retta: niente acqua o neve lungo il cammino.
func _raggiungibile(da: Vector2i, a: Vector2i) -> bool:
	var passi := int(Vector2(a - da).length() * 2) + 1
	for k in passi + 1:
		var p := Vector2(da).lerp(Vector2(a), float(k) / passi) + Vector2(0.5, 0.5)
		var t := dati.tipo(int(p.x), int(p.y))
		if t == DatiMappa.Terreno.ACQUA or t == DatiMappa.Terreno.NEVE:
			return false
	return true


## Campo di grano maturo e libero più vicino.
func campo_maturo(da: Vector2i, raggio: int) -> Vector2i:
	return _piu_vicino(da, raggio, func(c: Vector2i): return campi.has(c) and campi[c]["crescita"] >= 3.0 and not campi[c]["prenotato"])


func campi_vicini(da: Vector2i, raggio: int) -> int:
	var n := 0
	for c in campi:
		if Vector2(c - da).length() <= raggio:
			n += 1
	return n


## Casella libera per un nuovo campo: dentro i confini, vicino alla fattoria, lontano da strade e bandierine.
func posto_per_campo(da: Vector2i, raggio: int, rete: ReteStrade) -> Vector2i:
	var migliore := Vector2i(-1, -1)
	var dist := INF
	for y in range(da.y - raggio, da.y + raggio + 1):
		for x in range(da.x - raggio, da.x + raggio + 1):
			var c := Vector2i(x, y)
			var d := Vector2(c - da).length() + _rng.randf() * 0.8
			if d > raggio or d < 1.5 or d >= dist or not dati.dentro(x, y) or not dati.nel_territorio(x, y):
				continue
			if dati.occupante(x, y) != 0 or rete.strada.has(c) or rete.bandiere.has(c) or _vicino_a_bandiera(c, rete):
				continue
			if dati.tipo(x, y) in [DatiMappa.Terreno.PRATO, DatiMappa.Terreno.SECCO, DatiMappa.Terreno.TERRA] and _raggiungibile(da, c):
				dist = d
				migliore = c
	return migliore


## Punto della riva dove pescare: [casella di terra dove stare, casella d'acqua con pesce], o [] se nessuno.
func posto_di_pesca(da: Vector2i, raggio: int) -> Array:
	var migliore := []
	var dist := INF
	for y in range(da.y - raggio, da.y + raggio + 1):
		for x in range(da.x - raggio, da.x + raggio + 1):
			var c := Vector2i(x, y)
			var d := Vector2(c - da).length()
			if d > raggio or d >= dist or not dati.dentro(x, y) or dati.tipo(x, y) == DatiMappa.Terreno.ACQUA:
				continue
			for v in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				var w: Vector2i = c + v
				if dati.dentro(w.x, w.y) and dati.tipo(w.x, w.y) == DatiMappa.Terreno.ACQUA and pesci.get(w, PESCE_MAX) > 0 						and _raggiungibile(da, c):
					dist = d
					migliore = [c, w]
					break
	return migliore


# ------------------------------------------------------------ azioni

func prenota_albero(c: Vector2i) -> bool:
	for a in alberi.get(c, []):
		if a["crescita"] >= 3.0 and not a["prenotato"]:
			a["prenotato"] = true
			return true
	return false


## Abbatte un albero prenotato sulla casella; lascia un ceppo. Restituisce true se ce n'era uno.
func abbatti(c: Vector2i) -> bool:
	var lista: Array = alberi.get(c, [])
	for i in lista.size():
		if lista[i]["prenotato"]:
			var s: Sprite2D = lista[i]["sprite"]
			_metti_ceppo(s.position)
			s.queue_free()
			lista.remove_at(i)
			if lista.is_empty():
				alberi.erase(c)
				if not ulivi.has(c) and not rocce.has(c):
					dati.occupa(c.x, c.y, 0)
			return true
	return false


func prenota_roccia(c: Vector2i) -> bool:
	if rocce.has(c) and not rocce[c]["prenotata"]:
		rocce[c]["prenotata"] = true
		return true
	return false


## Estrae una pietra: la roccia si rimpicciolisce e alla fine sparisce.
func estrai(c: Vector2i) -> bool:
	if not rocce.has(c):
		return false
	var r: Dictionary = rocce[c]
	r["riserva"] -= 1
	r["prenotata"] = false
	var s: Sprite2D = r["sprite"]
	s.scale = Vector2.ONE * lerpf(0.45, 1.0, float(r["riserva"]) / RISERVA_ROCCIA)
	if r["riserva"] <= 0:
		s.queue_free()
		rocce.erase(c)
		if not alberi.has(c) and not ulivi.has(c):
			dati.occupa(c.x, c.y, 0)
	return true


func pianta(c: Vector2i) -> void:
	var s := Sprites.crea("alberello_1")
	s.position = dati.a_schermo(c.x + 0.5, c.y + 0.5)
	oggetti.add_child(s)
	var specie: String = SPECIE_ABBATTIBILI[_rng.randi_range(0, 2)]
	alberi.get_or_add(c, []).append({"sprite": s, "specie": specie, "crescita": 0.0, "prenotato": false})
	dati.occupa(c.x, c.y, DatiMappa.NATURA)


func semina(c: Vector2i) -> void:
	var s := Sprites.crea("campo_1")
	s.position = dati.a_schermo(c.x + 0.5, c.y + 0.5)
	oggetti.add_child(s)
	campi[c] = {"sprite": s, "crescita": 0.0, "prenotato": false}
	dati.occupa(c.x, c.y, DatiMappa.NATURA)


func prenota_campo(c: Vector2i) -> bool:
	if campi.has(c) and campi[c]["crescita"] >= 3.0 and not campi[c]["prenotato"]:
		campi[c]["prenotato"] = true
		return true
	return false


## Mietitura: il campo diventa stoppie e la casella torna libera.
func mieti(c: Vector2i) -> bool:
	if not campi.has(c):
		return false
	var s: Sprite2D = campi[c]["sprite"]
	_metti_ceppo(s.position, "stoppie", DURATA_STOPPIE)
	s.queue_free()
	campi.erase(c)
	dati.occupa(c.x, c.y, 0)
	return true


func pesca(w: Vector2i) -> bool:
	var n: int = pesci.get(w, PESCE_MAX)
	if n <= 0:
		return false
	pesci[w] = n - 1
	if not _ripopola.has(w):
		_ripopola[w] = TEMPO_PESCE
	return true


func _metti_ceppo(pos: Vector2, nome := "ceppo", durata := DURATA_CEPPO) -> void:
	var s := Sprites.crea(nome)
	s.position = pos
	oggetti.add_child(s)
	_ceppi.append([s, durata])


# ------------------------------------------------------------ tempo che passa

func _process(delta: float) -> void:
	for c in alberi:
		for a in alberi[c]:
			if a["crescita"] < 3.0:
				var prima := int(a["crescita"])
				a["crescita"] = minf(3.0, a["crescita"] + delta / TEMPO_CRESCITA)
				var dopo := int(a["crescita"])
				if dopo != prima:
					var s: Sprite2D = a["sprite"]
					var nome: String = "alberello_%d" % (dopo + 1) if dopo < 3 else "%s_%d" % [a["specie"], _rng.randi_range(1, 4)]
					s.texture = Sprites.texture(nome)
					s.offset = -Sprites.ancora(nome)
	for c in campi:
		var campo: Dictionary = campi[c]
		if campo["crescita"] < 3.0:
			var prima := int(campo["crescita"])
			campo["crescita"] = minf(3.0, campo["crescita"] + delta / TEMPO_CAMPO)
			var dopo := int(campo["crescita"])
			if dopo != prima:
				var nome := "campo_%d" % (dopo + 1)
				var s: Sprite2D = campo["sprite"]
				s.texture = Sprites.texture(nome)
				s.offset = -Sprites.ancora(nome)
	for w in _ripopola.keys():
		_ripopola[w] -= delta
		if _ripopola[w] <= 0.0:
			pesci[w] = pesci.get(w, PESCE_MAX) + 1
			if pesci[w] >= PESCE_MAX:
				pesci.erase(w)
				_ripopola.erase(w)
			else:
				_ripopola[w] = TEMPO_PESCE
	for i in range(_ceppi.size() - 1, -1, -1):
		_ceppi[i][1] -= delta
		if _ceppi[i][1] <= 0.0:
			_ceppi[i][0].queue_free()
			_ceppi.remove_at(i)
