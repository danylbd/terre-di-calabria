class_name Monumenti
extends Node
## I monumenti di Monteleone (step V2): uno dopo l'altro, nell'ordine della storia della città, ogni
## traguardo del villaggio sblocca un monumento che compare al suo posto sulla mappa e dà un vantaggio.
## Attivi solo sulla mappa di Monteleone. Tabella completa in docs/monteleone.md.

signal sbloccato(id: String)

const INTERVALLO := 2.0             # secondi tra un controllo dei traguardi e l'altro
const UN_ANNO := 1200.0             # quattro stagioni

## id (= nome dello sprite), nome, casella di riferimento, traguardo, vantaggio (testo e dati)
const CATALOGO := [
	{"id": "mura_greche", "nome": "Mura greche di Hipponion", "dove": Vector2i(50, 31),
		"traguardo": "Fondare la città: magazzino e due strade", "vantaggio": "I confini si allargano",
		"effetto": {"confini": 2}},
	{"id": "tempio_proserpina", "nome": "Tempio di Proserpina", "dove": Vector2i(51, 38),
		"traguardo": "50 coloni", "vantaggio": "I coloni nascono più in fretta",
		"effetto": {"nascita": 0.8}},
	{"id": "porto_santa_venere", "nome": "Porto di Santa Venere", "dove": Vector2i(61, 26),
		"traguardo": "Un pescatore o una barca del pesce spada", "vantaggio": "Il porto porta 4 pesci ogni stagione",
		"effetto": {"dono": {"pesce": 4}}},
	{"id": "foro_valentia", "nome": "Foro di Valentia", "dove": Vector2i(61, 37),
		"traguardo": "Un'agorà e 30 ducati", "vantaggio": "Mercanti al foro: 5 ducati ogni stagione",
		"effetto": {"dono": {"ducati": 5}}},
	{"id": "castello_normanno", "nome": "Castello normanno-svevo", "dove": Vector2i(55, 28),
		"traguardo": "Un castello", "vantaggio": "Arrivano 3 soldati di rinforzo",
		"effetto": {"soldati": 3}},
	{"id": "duomo", "nome": "Duomo di Santa Maria Maggiore e San Leoluca", "dove": Vector2i(62, 33),
		"traguardo": "100 coloni", "vantaggio": "Feste in città: i coloni nascono ancora più in fretta",
		"effetto": {"nascita": 0.8}},
	{"id": "chiesa_rosario", "nome": "Chiesa del Rosario", "dove": Vector2i(58, 41),
		"traguardo": "10 mestieri diversi", "vantaggio": "I lavoratori lavorano più in fretta",
		"effetto": {"lavoro": 0.85}},
	{"id": "valentianum", "nome": "Valentianum", "dove": Vector2i(64, 38),
		"traguardo": "200 ducati guadagnati", "vantaggio": "Il sapere dei frati: i soldati vincono più duelli",
		"effetto": {"duelli": 0.12}},
	{"id": "tonnara_bivona", "nome": "Tonnara e castello di Bivona", "dove": Vector2i(66, 23),
		"traguardo": "30 pesci spada pescati", "vantaggio": "La tonnara porta 6 pesci ogni stagione",
		"effetto": {"dono": {"pesce": 6}}},
	{"id": "castello_pizzo", "nome": "Castello di Pizzo e Piedigrotta", "dove": Vector2i(71, 19),
		"traguardo": "150 coloni", "vantaggio": "I confini si allargano ancora",
		"effetto": {"confini": 1}},
	{"id": "santa_maria_isola", "nome": "Santa Maria dell'Isola", "dove": Vector2i(15, 30),
		"traguardo": "Un anno senza perdere un forte", "vantaggio": "La fama della città: 10 ducati ogni stagione",
		"effetto": {"dono": {"ducati": 10}}},
]

var villaggio: Villaggio
var dati: DatiMappa
var oggetti: Node2D
var attivi := false
var ottenuti: Array[String] = []
var prodotti := {}                  # merce -> quante prodotte in tutta la partita (ducati, pesce spada)
var tempo_senza_perdite := 0.0      # secondi dall'ultimo forte perduto
var _attesa := INTERVALLO
var posti := {}                     # id -> casella dove è stato posato
var _sprite := {}                   # id -> Sprite2D sulla mappa


func prepara(v: Villaggio, d: DatiMappa, nodo_oggetti: Node2D, log: Logistica, guerra: Guerra, stagioni: Stagioni, mappa: String) -> void:
	villaggio = v
	dati = d
	oggetti = nodo_oggetti
	attivi = mappa == "monteleone"
	log.prodotta.connect(func(tipo: String): prodotti[tipo] = prodotti.get(tipo, 0) + 1)
	guerra.forte_perso.connect(func(): tempo_senza_perdite = 0.0)
	stagioni.cambiata.connect(func(_s): _doni())


func _process(delta: float) -> void:
	if not attivi:
		return
	tempo_senza_perdite += delta
	_attesa -= delta
	if _attesa > 0.0:
		return
	_attesa = INTERVALLO
	var prossimo := prossimo_monumento()
	if not prossimo.is_empty() and traguardo_raggiunto(prossimo["id"]):
		sblocca(prossimo["id"])


static func voce(id: String) -> Dictionary:
	for m in CATALOGO:
		if m["id"] == id:
			return m
	return {}


func prossimo_monumento() -> Dictionary:
	return CATALOGO[ottenuti.size()] if ottenuti.size() < CATALOGO.size() else {}


func traguardo_raggiunto(id: String) -> bool:
	var v := villaggio
	match id:
		"mura_greche":
			return v.magazzino() != null and v.rete.tratti.size() >= 2
		"tempio_proserpina":
			return v.popolazione() >= 50
		"porto_santa_venere":
			return _finiti("pescatore") + _finiti("pesca_spada") > 0
		"foro_valentia":
			return _finiti("agora") > 0 and v.scorte.get("ducati", 0) >= 30
		"castello_normanno":
			return _finiti("castello") > 0
		"duomo":
			return v.popolazione() >= 100
		"chiesa_rosario":
			return mestieri() >= 10
		"valentianum":
			return prodotti.get("ducati", 0) >= 200
		"tonnara_bivona":
			return prodotti.get("pesce_spada", 0) >= 30
		"castello_pizzo":
			return v.popolazione() >= 150
		"santa_maria_isola":
			return tempo_senza_perdite >= UN_ANNO
	return false


## Quanti mestieri diversi lavorano nel villaggio (edifici finiti con il loro lavoratore).
func mestieri() -> int:
	var tipi := {}
	for e in villaggio.edifici.values():
		if e.finito and e.lavoratore != null:
			tipi[e.tipo] = true
	return tipi.size()


func _finiti(tipo: String) -> int:
	return villaggio.edifici.values().filter(func(e): return e.finito and e.tipo == tipo).size()


## Il monumento compare sulla mappa e il suo vantaggio vale da subito.
## in_silenzio: si ricarica una partita (niente avviso né soldati regalati di nuovo), posto: dov'era.
func sblocca(id: String, in_silenzio := false, posto := Vector2i(-1, -1)) -> void:
	if id in ottenuti:
		return
	ottenuti.append(id)
	var m := voce(id)
	_posa(m, posto)
	var eff: Dictionary = m["effetto"]
	var vant := villaggio.vantaggi
	if eff.has("confini"):
		vant["confini"] = vant.get("confini", 0) + eff["confini"]
		villaggio._ricalcola_territorio()
	for chiave in ["nascita", "lavoro"]:
		if eff.has(chiave):
			vant[chiave] = vant.get(chiave, 1.0) * eff[chiave]
	if eff.has("duelli"):
		vant["duelli"] = vant.get("duelli", 0.0) + eff["duelli"]
	if eff.has("soldati") and not in_silenzio:
		villaggio.soldati += eff["soldati"]
	if not in_silenzio:
		villaggio.messaggio.emit("Nuovo monumento: %s! %s" % [m["nome"], m["vantaggio"]], false)
		Suono.suona("completato")
		sbloccato.emit(id)


## Ogni stagione i monumenti con un dono (porto, foro, tonnara, Isola) lo portano al magazzino.
func _doni() -> void:
	var cambiato := false
	for id in ottenuti:
		var dono: Dictionary = voce(id)["effetto"].get("dono", {})
		for merce in dono:
			villaggio.scorte[merce] = villaggio.scorte.get(merce, 0) + dono[merce]
			cambiato = true
	if cambiato:
		villaggio.scorte_cambiate.emit()


## Cerca vicino al posto del monumento due caselle per due libere sulla terra e ci mette lo sprite.
func _posa(m: Dictionary, posto: Vector2i) -> void:
	var dove: Vector2i = m["dove"]
	var c := posto
	if c.x < 0:
		c = dove if m["id"] == "santa_maria_isola" else _posto_libero(dove)
	posti[m["id"]] = c
	for y in range(c.y, c.y + 2):
		for x in range(c.x, c.x + 2):
			if dati.dentro(x, y) and dati.occupante(x, y) == 0:
				dati.occupa(x, y, DatiMappa.NATURA)
				villaggio.togli_decori.emit(Vector2i(x, y))
	var s := Sprites.crea(m["id"])
	s.position = dati.a_schermo(c.x + 1.0, c.y + 1.0)
	oggetti.add_child(s)
	_sprite[m["id"]] = s


func _posto_libero(dove: Vector2i) -> Vector2i:
	for r in 12:
		var migliore := Vector2i(-1, -1)
		var meglio := INF
		for y in range(dove.y - r, dove.y + r + 1):
			for x in range(dove.x - r, dove.x + r + 1):
				var c := Vector2i(x, y)
				var dist := Vector2(c - dove).length()
				if dist <= r and dist < meglio and _libero(c):
					meglio = dist
					migliore = c
		if migliore.x >= 0:
			return migliore
	return dove


func _libero(c: Vector2i) -> bool:
	for y in range(c.y, c.y + 2):
		for x in range(c.x, c.x + 2):
			if not dati.dentro(x, y) or dati.occupante(x, y) != 0 or dati.tipo(x, y) == DatiMappa.Terreno.ACQUA:
				return false
			if Vector2i(x, y) in villaggio.rete.bandiere or villaggio.rete.tratto_in(Vector2i(x, y)) != null:
				return false
	return true
