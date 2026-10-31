class_name Villaggio
extends Node
## Regole di costruzione e stato del villaggio del giocatore: scorte, edifici, territorio.

signal scorte_cambiate
signal territorio_cambiato
signal messaggio(testo: String, errore: bool)

const T := DatiMappa.Terreno
const RAGGIO_MAGAZZINO := 9.0
const TERRENI_EDIFICABILI := [T.PRATO, T.SECCO, T.TERRA]
const PENDENZA_MAX := {1: 14.0, 2: 10.0}

var dati: DatiMappa
var rete: ReteStrade
var oggetti: Node2D                  # nodo con ordinamento in profondità dove vanno gli edifici
var natura := {}                     # Vector2i -> Array[Node2D] (alberi e rocce su quella casella)
var edifici := {}                    # id -> Edificio
var scorte := {"tronchi": 20, "assi": 24, "pietra": 18}
var _prossimo_id := 2


func _init(d: DatiMappa, nodo_oggetti: Node2D) -> void:
	dati = d
	oggetti = nodo_oggetti


# ------------------------------------------------------------ verifiche

func motivo_impossibile(tipo: String, c: Vector2i, controlla_costo := true) -> String:
	var info := CatalogoEdifici.dati(tipo)
	var s: int = info["taglia"]
	for y in range(c.y, c.y + s):
		for x in range(c.x, c.x + s):
			if not dati.dentro(x, y):
				return "Fuori dalla mappa"
			if not dati.nel_territorio(x, y):
				return "Fuori dai tuoi confini"
			if dati.tipo(x, y) not in TERRENI_EDIFICABILI:
				return "Terreno non adatto"
			var o := dati.occupante(x, y)
			if o == DatiMappa.NATURA:
				return "Ci sono alberi o rocce"
			if o >= 2:
				return "Posto occupato"
			if rete and (rete.strada.has(Vector2i(x, y)) or rete.bandiere.has(Vector2i(x, y))):
				return "C'è una strada"
	var b := Vector2i(c.x + s - 1, c.y + s)
	if not dati.nel_territorio(b.x, b.y) or dati.tipo(b.x, b.y) in [T.ACQUA, T.ROCCIA, T.NEVE] or dati.occupante(b.x, b.y) != 0:
		return "Serve spazio davanti alla porta per la bandierina"
	if rete and not rete.bandiere.has(b) and rete.motivo_no_bandiera(b) != "":
		return "Serve spazio davanti alla porta per la bandierina"
	var qmin := INF
	var qmax := -INF
	for j in range(c.y, c.y + s + 1):
		for i in range(c.x, c.x + s + 1):
			var q := dati.quota_vertice(i, j)
			qmin = minf(qmin, q)
			qmax = maxf(qmax, q)
	if qmax - qmin > PENDENZA_MAX[s]:
		return "Terreno troppo in pendenza"
	if controlla_costo:
		var costo: Dictionary = info["costo"]
		for r in costo:
			if scorte.get(r, 0) < costo[r]:
				return "Mancano %s" % CatalogoEdifici.NOMI_RISORSE[r].to_lower()
	return ""


func puo_costruire(tipo: String, c: Vector2i) -> bool:
	return motivo_impossibile(tipo, c) == ""


# ------------------------------------------------------------ azioni

func costruisci(tipo: String, c: Vector2i, gia_finito := false) -> Edificio:
	if not gia_finito:
		var perche := motivo_impossibile(tipo, c)
		if perche != "":
			messaggio.emit(perche, true)
			return null
		var costo: Dictionary = CatalogoEdifici.dati(tipo)["costo"]
		for r in costo:
			scorte[r] -= costo[r]
		scorte_cambiate.emit()
	var e := Edificio.new()
	e.prepara(_prossimo_id, tipo, c, gia_finito)
	_prossimo_id += 1
	e.position = dati.a_schermo(e.centro().x, e.centro().y)
	oggetti.add_child(e)
	edifici[e.id] = e
	for y in range(c.y, c.y + e.taglia):
		for x in range(c.x, c.x + e.taglia):
			dati.occupa(x, y, e.id)
	e.completato.connect(_on_completato)
	if gia_finito:
		_ricalcola_territorio()
	rete.aggiungi_bandiera(e.bandiera, true)
	rete.segna_ostacoli_vecchi()
	if not gia_finito:
		if rete.collegata(e.bandiera):
			messaggio.emit("Cantiere aperto: %s" % CatalogoEdifici.dati(tipo)["nome"], false)
		else:
			messaggio.emit("Collega la bandierina del cantiere con una strada", false)
	_aggiorna_collegamenti()
	return e


func demolisci(e: Edificio) -> void:
	if e.tipo == "magazzino" and _conta("magazzino") <= 1:
		messaggio.emit("Non puoi demolire l'ultimo magazzino", true)
		return
	for y in range(e.casella.y, e.casella.y + e.taglia):
		for x in range(e.casella.x, e.casella.x + e.taglia):
			dati.occupa(x, y, 0)
	# si recupera metà dei materiali
	var costo: Dictionary = CatalogoEdifici.dati(e.tipo)["costo"]
	for r in costo:
		scorte[r] += int(costo[r] / 2)
	edifici.erase(e.id)
	rete.libera_protezione(e.bandiera)
	rete.segna_ostacoli_vecchi()
	e.queue_free()
	scorte_cambiate.emit()
	_ricalcola_territorio()
	messaggio.emit("%s demolito" % CatalogoEdifici.dati(e.tipo)["nome"], false)


func edificio_in(c: Vector2i) -> Edificio:
	var o := dati.occupante(c.x, c.y)
	return edifici.get(o) if o >= 2 else null


func _on_completato(e: Edificio) -> void:
	messaggio.emit("%s completato" % CatalogoEdifici.dati(e.tipo)["nome"], false)
	if CatalogoEdifici.dati(e.tipo).has("territorio") or e.tipo == "magazzino":
		_ricalcola_territorio()
	if e.tipo == "magazzino":
		rete.aggiungi_bandiera(e.bandiera, true)
		rete._ricalcola()


func _ricalcola_territorio() -> void:
	var centri := []
	for e in edifici.values():
		if not e.finito:
			continue
		if e.tipo == "magazzino":
			centri.append([Vector2i(e.centro()), RAGGIO_MAGAZZINO])
		elif CatalogoEdifici.dati(e.tipo).has("territorio"):
			centri.append([e.casella, float(CatalogoEdifici.dati(e.tipo)["territorio"])])
	dati.calcola_territorio(centri)
	if rete:
		rete.segna_ostacoli_vecchi()
	territorio_cambiato.emit()


func _aggiorna_collegamenti() -> void:
	for e in edifici.values():
		e.collegato = e.tipo == "magazzino" or rete.collegata(e.bandiera)


func _conta(tipo: String) -> int:
	var n := 0
	for e in edifici.values():
		if e.tipo == tipo:
			n += 1
	return n
