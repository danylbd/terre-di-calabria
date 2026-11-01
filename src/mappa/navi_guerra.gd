class_name NaviGuerra
extends Node2D
## Le navi da guerra (step 35, Fase 7): si armano al porto (assi e armi), vanno per mare fino alla torre
## nemica più vicina alla costa e la bersagliano finché non ha più difensori; poi tornano al porto.
## La torre si prende con la schiera. Solo dove ci sono le schiere (partita libera, non in pace).

const COSTO := {"assi": 6, "armi": 2}
const MAX_NAVI := 2
const RAGGIO_COSTA := 5              # la torre dev'essere a tanto dall'acqua
const RAGGIO_CACCIA := 40.0          # quanto lontano cerca torri da colpire
const TIRO := 3.0                    # secondi tra un tiro e l'altro
const VELOCITA := 2.0

var villaggio: Villaggio
var dati: DatiMappa
var oggetti: Node2D
var navi: Array = []                 # {"nave": Colono, "porto": Edificio, "bersaglio": Edificio, "stato": "va" | "tira" | "torna" | "ferma", "tiro": float}
var _rng := RandomNumberGenerator.new()
var _colpi: Array = []               # [da, a, tempo] in coordinate di mappa


func prepara(v: Villaggio, d: DatiMappa, nodo_oggetti: Node2D) -> void:
	villaggio = v
	dati = d
	oggetti = nodo_oggetti
	z_index = 30
	_rng.randomize()


func motivo_no_nave(porto: Edificio) -> String:
	if not Schiere.attive():
		return "Le navi da guerra non ci sono in questa partita"
	if navi.size() >= MAX_NAVI:
		return "Al massimo %d navi da guerra" % MAX_NAVI
	for m in COSTO:
		if villaggio.scorte.get(m, 0) < COSTO[m]:
			return "Servono %d assi e %d armi" % [COSTO["assi"], COSTO["armi"]]
	if Mare.acqua_vicina(dati, Vector2i(porto.centro()), 7).x < 0:
		return "Il porto non ha il mare vicino"
	return ""


## Arma una nave al porto e la manda contro la torre nemica sulla costa più vicina (se c'è).
func arma(porto: Edificio) -> bool:
	if motivo_no_nave(porto) != "":
		return false
	for m in COSTO:
		villaggio.scorte[m] -= COSTO[m]
	villaggio.scorte_cambiate.emit()
	var w := Mare.acqua_vicina(dati, Vector2i(porto.centro()), 7)
	var c := Colono.new()
	oggetti.add_child(c)
	c.prepara(dati, Vector2(w) + Vector2(0.5, 0.5), "nave_guerra" if ResourceLoader.exists("res://assets/grafica/nave_guerra.png") else "nave")
	c.velocita = VELOCITA
	var n := {"nave": c, "porto": porto, "bersaglio": null, "stato": "ferma", "tiro": TIRO, "base": w}
	navi.append(n)
	c.arrivato.connect(func(_c): _arrivata(n))
	villaggio.messaggio.emit("Una nave da guerra esce dal porto", false)
	caccia(n)
	return true


## Cerca la torre nemica più vicina che si può colpire dal mare e ci va.
func caccia(n: Dictionary) -> bool:
	var nave: Colono = n["nave"]
	var da := Vector2i(nave.pos.floor())
	var migliore: Array[Vector2] = []
	var bersaglio: Edificio = null
	for t in villaggio.nemici.values():
		if t.soldati <= 0 or t.centro().distance_to(nave.pos) > RAGGIO_CACCIA:
			continue
		var w := Mare.acqua_vicina(dati, Vector2i(t.centro()), RAGGIO_COSTA)
		if w.x < 0:
			continue
		var r := Mare.rotta(dati, da, w)
		if (not r.is_empty() or w == da) and (bersaglio == null or r.size() < migliore.size()):
			migliore = r
			bersaglio = t
	if bersaglio == null:
		return false
	n["bersaglio"] = bersaglio
	n["stato"] = "va"
	if migliore.is_empty():
		_arrivata(n)
	else:
		nave.percorri(migliore)
	return true


func _arrivata(n: Dictionary) -> void:
	match n["stato"]:
		"va":
			n["stato"] = "tira"
			n["tiro"] = TIRO
		"torna":
			n["stato"] = "ferma"


func _process(delta: float) -> void:
	for c in _colpi:
		c[2] += delta
	_colpi = _colpi.filter(func(c): return c[2] < 0.5)
	for n in navi:
		if n["stato"] != "tira":
			continue
		var t = n["bersaglio"]
		if not is_instance_valid(t) or not villaggio.nemici.has(t.id) or t.soldati <= 0:
			if is_instance_valid(t) and villaggio.nemici.has(t.id):
				villaggio.messaggio.emit("La torre nemica sulla costa non ha più difensori: mandate la schiera!", false)
			_torna(n)
			continue
		n["tiro"] -= delta
		if n["tiro"] > 0.0:
			continue
		n["tiro"] = TIRO
		_colpi.append([n["nave"].pos, t.centro(), 0.0])
		if _rng.randf() < 0.5:
			t.soldati -= 1
	queue_redraw()


func _torna(n: Dictionary) -> void:
	n["bersaglio"] = null
	var nave: Colono = n["nave"]
	var r := Mare.rotta(dati, Vector2i(nave.pos.floor()), n["base"])
	if r.is_empty():
		n["stato"] = "ferma"
		return
	n["stato"] = "torna"
	nave.percorri(r)


func _draw() -> void:
	for c in _colpi:
		var f: float = c[2] / 0.5
		var a := dati.a_schermo(c[0].x, c[0].y)
		var b := dati.a_schermo(c[1].x, c[1].y)
		draw_circle(a.lerp(b, f) + Vector2(0, -50.0 * sin(f * PI) - 20.0), 3.0, Color("3a3028"))


## Assi e armi delle navi (nel salvataggio tornano nel magazzino: le navi non si salvano).
func materiali() -> Dictionary:
	var m := {}
	for n in navi:
		for k in COSTO:
			m[k] = m.get(k, 0) + COSTO[k]
	return m
