class_name Guerra
extends Node
## Soldati e conquista: i soldati della riserva raggiungono i forti presidiati; da un forte si attacca
## una torre dell'altro popolo: gli attaccanti arrivano alla porta e sfidano i difensori uno alla volta.
## Quando nella torre non resta nessuno, chi è sopravvissuto la conquista e i confini cambiano padrone.
## Vale per tutti e due i lati: anche i Brettii (vedi avversario.gd) attaccano i nostri forti così.

signal messaggio(testo: String, errore: bool)
signal forte_perso

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


## Nostri soldati in cammino (verso un forte o all'attacco): contano nella popolazione.
func in_marcia() -> int:
	return _soldati.filter(func(s): return s["lato"] == 1).size()


const FOGLI := {1: ["guardia", "guardia_lotta"], 2: ["brettio", "brettio_lotta"]}


## Il forte o la torre sotto attacco esiste ancora (dalla sua parte)?
func _in_piedi(e) -> bool:
	if not is_instance_valid(e) or e.is_queued_for_deletion():
		return false
	return villaggio.nemici.has(e.id) if e.proprietario != 1 else villaggio.edifici.has(e.id)


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
		var n = s["destinazione"]
		if _in_piedi(n) and not _duelli.has(n.id):
			_combatti(s)
		elif not _in_piedi(n):
			_arrivato(s)
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


func _nuovo_soldato(punti: Array[Vector2], scopo: String, dest: Edificio, lato := 1) -> Dictionary:
	var c := Colono.new()
	oggetti.add_child(c)
	c.prepara(dati, punti[0], FOGLI[lato][0])
	c.velocita = 1.4
	var s := {"nodo": c, "scopo": scopo, "destinazione": dest, "stato": "marcia", "lato": lato}
	c.arrivato.connect(func(_c): _arrivato(s))
	c.percorri(punti)
	_soldati.append(s)
	return s


func _arrivato(s: Dictionary) -> void:
	var dest = s["destinazione"]          # può essere già distrutto: niente tipo
	if s["scopo"] == "rinforzo":
		_togli(s)
		if is_instance_valid(dest) and not dest.is_queued_for_deletion():
			dest.soldati_in_arrivo -= 1
			dest.soldati += 1
		else:
			villaggio.soldati += 1
		return
	# all'attacco: se la torre non c'è più (già conquistata) il soldato entra in quella nuova del suo popolo
	if not _in_piedi(dest):
		_togli(s)
		var c: Vector2i = s["bersaglio"]
		var nuova: Edificio = villaggio.edificio_in(c) if s["lato"] == 1 else villaggio.nemico_in(c)
		if nuova:
			nuova.soldati += 1
		elif s["lato"] == 1:
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
## Funziona per tutti e due i lati: il forte "da" e il "bersaglio" sono di popoli diversi.
func attacca(da: Edificio, bersaglio: Edificio) -> int:
	var n := da.soldati - 1
	if n <= 0:
		if da.proprietario == 1:
			messaggio.emit("Servono almeno 2 soldati nel forte: uno resta a difenderlo", true)
		return 0
	if Vector2(bersaglio.centro() - da.centro()).length() > RAGGIO_ATTACCO:
		if da.proprietario == 1:
			messaggio.emit("Troppo lontano: attacca da un forte più vicino", true)
		return 0
	for k in n:
		da.soldati -= 1
		var arrivo := Vector2(bersaglio.bandiera) + Vector2(0.5, 0.6) + Vector2(_rng.randf_range(-0.6, 0.6), _rng.randf_range(0.0, 0.7))
		var punti: Array[Vector2] = [da.centro(), Vector2(da.bandiera) + Vector2(0.5, 0.5), arrivo]
		var s := _nuovo_soldato(punti, "attacco", bersaglio, da.proprietario)
		s["bersaglio"] = bersaglio.casella
		(s["nodo"] as Colono).velocita = 1.2 + k * 0.03
	if da.proprietario == 1:
		messaggio.emit("%d soldati partono all'attacco" % n, false)
	else:
		messaggio.emit("I Brettii attaccano: %s!" % CatalogoEdifici.dati(bersaglio.tipo)["nome"].to_lower(), true)
		Suono.suona("errore")
	return n


## Un attaccante arrivato alla porta sfida un difensore; se non ne restano, la torre è conquistata.
func _combatti(s: Dictionary) -> void:
	var bersaglio = s["destinazione"]
	if bersaglio.soldati <= 0:
		_conquista(bersaglio, s["lato"])
		return
	var difensore := Colono.new()
	oggetti.add_child(difensore)
	var c: Colono = s["nodo"]
	difensore.prepara(dati, c.pos + Vector2(-0.45, -0.35), FOGLI[bersaglio.proprietario][1])
	c.imposta_foglio(FOGLI[s["lato"]][1])
	c._anim.play()
	difensore._anim.play()
	s["stato"] = "duello"
	_duelli[bersaglio.id] = {"attaccante": s, "difensore": difensore, "tempo": DURATA_DUELLO}
	Suono.suona_in("scontro", c.global_position, -2.0)


func _fine_duello(id: int) -> void:
	var d: Dictionary = _duelli[id]
	_duelli.erase(id)
	var s: Dictionary = d["attaccante"]
	(d["difensore"] as Node).queue_free()
	var bersaglio = s["destinazione"]
	if not s in _soldati:
		return
	# i monumenti (il Valentianum) danno ai nostri soldati più probabilità di vincere
	var vittoria := VITTORIA_ATTACCANTE
	if s["lato"] == 1:
		vittoria += villaggio.vantaggi.get("duelli", 0.0)
	elif is_instance_valid(bersaglio) and bersaglio.proprietario == 1:
		vittoria -= villaggio.vantaggi.get("duelli", 0.0)
	if _rng.randf() < vittoria:
		if is_instance_valid(bersaglio):
			bersaglio.soldati -= 1
			if bersaglio.proprietario == 1:
				messaggio.emit("Un nostro soldato è caduto difendendo il forte", true)
		s["stato"] = "attesa"
		(s["nodo"] as Colono).imposta_foglio(FOGLI[s["lato"]][0])
	else:
		_togli(s)
		if s["lato"] == 1:
			messaggio.emit("Un soldato è caduto in battaglia", true)


func _conquista(bersaglio: Edificio, lato: int) -> void:
	if not _in_piedi(bersaglio):
		return
	var vincitori := _soldati.filter(func(s): return s["scopo"] == "attacco" and s["destinazione"] == bersaglio and s["stato"] == "attesa")
	var casella := bersaglio.casella
	var nome: String = CatalogoEdifici.dati(bersaglio.tipo)["nome"]
	var nuova: Edificio
	if lato == 1:
		villaggio.rimuovi_nemico(bersaglio)
		nuova = villaggio.costruisci("torre", casella, true, true)
	else:
		# i Brettii prendono il nostro forte: lo bruciano e alzano una loro torre
		villaggio.demolisci(bersaglio, false)
		nuova = villaggio.metti_nemico("torre_brettia", casella, lato, 0)
	for s in vincitori:
		_togli(s)
		if nuova:
			nuova.soldati += 1
		elif lato == 1:
			villaggio.soldati += 1
	if lato == 1:
		messaggio.emit("%s conquistata! I confini sono nostri" % nome, false)
		Suono.suona("completato")
	else:
		messaggio.emit("I Brettii hanno preso %s: abbiamo perso i confini intorno" % nome.to_lower(), true)
		forte_perso.emit()
		Suono.suona("errore")
