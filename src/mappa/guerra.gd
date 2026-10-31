class_name Guerra
extends Node
## Soldati e conquista: i soldati della riserva raggiungono i forti presidiati; da un forte si attacca
## una torre nemica: gli attaccanti arrivano alla porta e sfidano i difensori uno alla volta.
## Quando nella torre non resta nessuno, chi è sopravvissuto la conquista e i confini passano a noi.

signal messaggio(testo: String, errore: bool)

const RAGGIO_ATTACCO := 18.0         # quanto lontano può attaccare un forte (caselle)
const DURATA_DUELLO := 2.6
const VITTORIA_ATTACCANTE := 0.5     # probabilità che l'attaccante vinca un duello
const RINFORZO_NEMICO := 120.0       # secondi perché un avamposto nemico richiami un difensore
const DIFENSORI_MAX := 4

var villaggio: Villaggio
var rete: ReteStrade
var dati: DatiMappa
var oggetti: Node2D
var _invio := 0.0
var _soldati: Array = []             # {nodo: Colono, scopo: "rinforzo"/"attacco", destinazione: Edificio, stato, attesa}
var _duelli := {}                    # id torre nemica -> {attaccante, difensore: Colono, tempo}
var _rng := RandomNumberGenerator.new()


func prepara(v: Villaggio, r: ReteStrade, d: DatiMappa, nodo_oggetti: Node2D) -> void:
	villaggio = v
	rete = r
	dati = d
	oggetti = nodo_oggetti
	_rng.seed = 2600


## Soldati in cammino (verso un forte o all'attacco): contano nella popolazione.
func in_marcia() -> int:
	return _soldati.size()


func _process(delta: float) -> void:
	_invio -= delta
	if _invio <= 0.0:
		_invio = 2.0
		_manda_rinforzi()
	for n in villaggio.nemici.values():
		if n.soldati < DIFENSORI_MAX:
			n.nascita += delta
			if n.nascita >= RINFORZO_NEMICO:
				n.nascita = 0.0
				n.soldati += 1
	for s in _soldati.duplicate():
		if not s in _soldati or s["stato"] != "attesa":
			continue
		var n: Edificio = s["destinazione"]
		if is_instance_valid(n) and villaggio.nemici.has(n.id) and not _duelli.has(n.id):
			_combatti(s)
	for id in _duelli.keys():
		var d: Dictionary = _duelli[id]
		d["tempo"] -= delta
		if d["tempo"] <= 0.0:
			_fine_duello(id)


# ------------------------------------------------------------ rinforzi dalla riserva ai forti

func _manda_rinforzi() -> void:
	if villaggio.soldati <= 0:
		return
	var mag := villaggio.magazzino()
	if mag == null:
		return
	for e in villaggio.edifici.values():
		var massimo: int = CatalogoEdifici.dati(e.tipo).get("soldati_max", 0)
		if massimo == 0 or not e.presidiata or not e.collegato:
			continue
		while villaggio.soldati > 0 and e.soldati + e.soldati_in_arrivo < massimo:
			var punti: Array[Vector2] = [mag.centro()]
			punti.append_array(rete.percorso_tra_bandiere(mag.bandiera, e.bandiera))
			punti.append(e.centro())
			villaggio.soldati -= 1
			e.soldati_in_arrivo += 1
			_nuovo_soldato(punti, "rinforzo", e)


func _nuovo_soldato(punti: Array[Vector2], scopo: String, dest: Edificio) -> Dictionary:
	var c := Colono.new()
	oggetti.add_child(c)
	c.prepara(dati, punti[0], "guardia")
	c.velocita = 1.4
	var s := {"nodo": c, "scopo": scopo, "destinazione": dest, "stato": "marcia", "origine": null}
	c.arrivato.connect(func(_c): _arrivato(s))
	c.percorri(punti)
	_soldati.append(s)
	return s


func _arrivato(s: Dictionary) -> void:
	var dest: Edificio = s["destinazione"]
	if s["scopo"] == "rinforzo":
		_togli(s)
		if is_instance_valid(dest) and not dest.is_queued_for_deletion():
			dest.soldati_in_arrivo -= 1
			dest.soldati += 1
		else:
			villaggio.soldati += 1
		return
	# all'attacco: se la torre non c'è più (già conquistata) il soldato entra nella torre nuova
	if not is_instance_valid(dest) or dest.is_queued_for_deletion():
		_togli(s)
		var mia := villaggio.edificio_in(s["bersaglio"])
		if mia:
			mia.soldati += 1
		else:
			villaggio.soldati += 1
		return
	s["stato"] = "attesa"


func _togli(s: Dictionary) -> void:
	_soldati.erase(s)
	(s["nodo"] as Node).queue_free()
	villaggio.popolazione_cambiata.emit()


# ------------------------------------------------------------ attacco

## Torri nemiche che un forte può attaccare.
func bersagli(da: Edificio) -> Array:
	return villaggio.nemici.values().filter(func(n): return Vector2(n.centro() - da.centro()).length() <= RAGGIO_ATTACCO)


## Manda all'attacco tutti i soldati del forte tranne uno, che resta a difenderlo. Restituisce quanti partono.
func attacca(da: Edificio, nemico: Edificio) -> int:
	var n := da.soldati - 1
	if n <= 0:
		messaggio.emit("Servono almeno 2 soldati nel forte: uno resta a difenderlo", true)
		return 0
	if Vector2(nemico.centro() - da.centro()).length() > RAGGIO_ATTACCO:
		messaggio.emit("Troppo lontano: attacca da un forte più vicino", true)
		return 0
	for k in n:
		da.soldati -= 1
		var arrivo := Vector2(nemico.bandiera) + Vector2(0.5, 0.6) + Vector2(_rng.randf_range(-0.6, 0.6), _rng.randf_range(0.0, 0.7))
		var punti: Array[Vector2] = [da.centro(), Vector2(da.bandiera) + Vector2(0.5, 0.5), arrivo]
		var s := _nuovo_soldato(punti, "attacco", nemico)
		s["bersaglio"] = nemico.casella
		(s["nodo"] as Colono).velocita = 1.2 + k * 0.03
	messaggio.emit("%d soldati partono all'attacco" % n, false)
	return n


## Un attaccante arrivato alla porta sfida un difensore; se non ne restano, la torre è conquistata.
func _combatti(s: Dictionary) -> void:
	var nemico: Edificio = s["destinazione"]
	if nemico.soldati <= 0:
		_conquista(nemico)
		return
	var difensore := Colono.new()
	oggetti.add_child(difensore)
	var c: Colono = s["nodo"]
	difensore.prepara(dati, c.pos + Vector2(-0.45, -0.35), "brettio_lotta")
	c.imposta_foglio("guardia_lotta")
	c._anim.play()
	difensore._anim.play()
	s["stato"] = "duello"
	_duelli[nemico.id] = {"attaccante": s, "difensore": difensore, "tempo": DURATA_DUELLO}
	Suono.suona_in("scontro", c.global_position, -2.0)


func _fine_duello(id: int) -> void:
	var d: Dictionary = _duelli[id]
	_duelli.erase(id)
	var s: Dictionary = d["attaccante"]
	(d["difensore"] as Node).queue_free()
	var nemico: Edificio = s["destinazione"]
	if _rng.randf() < VITTORIA_ATTACCANTE:
		if is_instance_valid(nemico):
			nemico.soldati -= 1
		s["stato"] = "attesa"
		var c: Colono = s["nodo"]
		c.imposta_foglio("guardia")
	else:
		_togli(s)
		messaggio.emit("Un soldato è caduto in battaglia", true)


func _conquista(nemico: Edificio) -> void:
	if not villaggio.nemici.has(nemico.id):
		return
	var vincitori := _soldati.filter(func(s): return s["scopo"] == "attacco" and s["destinazione"] == nemico and s["stato"] == "attesa")
	var casella := nemico.casella
	var nome: String = CatalogoEdifici.dati(nemico.tipo)["nome"]
	villaggio.rimuovi_nemico(nemico)
	var torre := villaggio.costruisci("torre", casella, true, true)
	for s in vincitori:
		_togli(s)
		if torre:
			torre.soldati += 1
		else:
			villaggio.soldati += 1
	messaggio.emit("%s conquistata! I confini sono nostri" % nome, false)
	Suono.suona("completato")
