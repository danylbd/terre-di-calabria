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
const DISTANZA_TIRO := 6.0           # i tiratori combattono da più lontano
const VOLO := 0.45                   # secondi di volo di un proiettile
## step 32: cibo, morale ed esperienza
const RAZIONI_MAX := 20
const CONSUMO := 20.0                # secondi per ogni razione mangiata dalla schiera
const FAME := 30.0                   # senza razioni, ogni tanto un soldato se ne va
const RAGGIO_MAGAZZINO := 6.0        # vicino a un nostro magazzino la schiera si rifornisce e si rinforza
const ESPERIENZA_LIVELLO := 10       # duelli vinti per ogni livello del condottiero
const LIVELLO_MAX := 5
## step 34: due abilità per condottiero, la prima dal livello 2, la seconda dal livello 4.
## effetto: "duelli" (+probabilità per "durata" secondi), "morale" (subito), "passo" (velocità × per "durata")
const ABILITA := {
	"greci": [{"nome": "Falange", "descrizione": "Scudi stretti: duelli più facili per 20 s", "effetto": "duelli", "valore": 0.12, "durata": 20.0},
		{"nome": "Canto di Eudora", "descrizione": "Il canto delle stelle: morale +25", "effetto": "morale", "valore": 25}],
	"brettii": [{"nome": "Passo di montagna", "descrizione": "Tauro guida per i sentieri: schiera più veloce per 20 s", "effetto": "passo", "valore": 1.5, "durata": 20.0},
		{"nome": "Imboscata", "descrizione": "Dal folto del bosco: duelli molto più facili per 12 s", "effetto": "duelli", "valore": 0.2, "durata": 12.0}],
	"romani": [{"nome": "Disciplina", "descrizione": "Ordine nelle file: morale +20", "effetto": "morale", "valore": 20},
		{"nome": "Testuggine", "descrizione": "Scudi sopra e davanti: duelli più facili per 20 s", "effetto": "duelli", "valore": 0.14, "durata": 20.0}],
	"saraceni": [{"nome": "Carica rapida", "descrizione": "I cavalli leggeri volano: schiera più veloce per 15 s", "effetto": "passo", "valore": 1.6, "durata": 15.0},
		{"nome": "Grido del deserto", "descrizione": "Duelli più facili per 15 s", "effetto": "duelli", "valore": 0.15, "durata": 15.0}],
	"normanni": [{"nome": "Giuramento", "descrizione": "Osmund giura per tutti: morale +25", "effetto": "morale", "valore": 25},
		{"nome": "Carica pesante", "descrizione": "Lance in resta: duelli molto più facili per 10 s", "effetto": "duelli", "valore": 0.22, "durata": 10.0}],
	"siculi": [{"nome": "Grido degli antenati", "descrizione": "Le voci di Pantalica: morale +20", "effetto": "morale", "valore": 20},
		{"nome": "Lance lunghe", "descrizione": "Duelli più facili per 20 s", "effetto": "duelli", "valore": 0.12, "durata": 20.0}],
	"sicani": [{"nome": "Rifugio sui monti", "descrizione": "Kokalo conosce ogni passo: schiera più veloce per 20 s", "effetto": "passo", "valore": 1.5, "durata": 20.0},
		{"nome": "Pioggia di frecce", "descrizione": "Punte d'ossidiana: duelli molto più facili per 10 s", "effetto": "duelli", "valore": 0.2, "durata": 10.0}],
}
const LIVELLI_ABILITA := [2, 4]
const RICARICA := 60.0
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
var _proiettili: Array = []          # [da, a, tempo] in coordinate di mappa: sassi e frecce in volo
var _polvere: Array = []             # [dove, tempo]: la polvere dei duelli corpo a corpo
var _ricarica := [0.0, 0.0]          # secondi prima che ogni abilità si possa riusare
var _bonus_duelli := 0.0
var _bonus_fino := 0.0
var _passo := 1.0
var _passo_fino := 0.0
var _orologio := 0.0
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
	return esiste() and not in_viaggio() and Vector2(c) .distance_to(schiera["condottiero"].pos.floor()) <= 1.0


func scegli(si: bool) -> void:
	scelta = si and esiste()
	queue_redraw()


## Ordine di andare in una casella: il percorso più breve a piedi (niente mare, niente edifici).
func muovi(c: Vector2i) -> bool:
	if not esiste() or in_viaggio():
		return false
	schiera.erase("imbarco")
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


## La traversata (step 35): la schiera va al porto, sale sulla nave e sbarca a un altro nostro porto
## raggiungibile per mare (per esempio dall'altra parte dello Stretto).
func imbarca(porto: Edificio) -> bool:
	if not esiste() or porto.tipo != "porto" or not porto.finito:
		return false
	var da := Mare.acqua_vicina(dati, Vector2i(porto.centro()), 7)
	if da.x < 0:
		return false
	var meta: Edificio = null
	var rotta: Array[Vector2] = []
	for e in villaggio.edifici.values():
		if e == porto or e.tipo != "porto" or not e.finito:
			continue
		var w := Mare.acqua_vicina(dati, Vector2i(e.centro()), 7)
		if w.x < 0:
			continue
		var r := Mare.rotta(dati, da, w)
		if not r.is_empty() and (meta == null or r.size() < rotta.size()):
			meta = e
			rotta = r
	if meta == null:
		villaggio.messaggio.emit("Serve un altro nostro porto raggiungibile per mare", true)
		return false
	var capo: Colono = schiera["condottiero"]
	var percorso := percorso_a_piedi(Vector2i(capo.pos.floor()), porto.bandiera)
	if percorso.is_empty() and Vector2(porto.bandiera).distance_to(capo.pos) > 1.5:
		return false
	schiera["bersaglio"] = null
	schiera["imbarco"] = {"porto": porto, "acqua": da, "meta": meta, "rotta": rotta}
	if not percorso.is_empty():
		_marcia(percorso)
	return true


func in_viaggio() -> bool:
	return esiste() and schiera.has("nave")


## Al porto: tutti a bordo, la nave attraversa il mare.
func _salpa() -> void:
	var imb: Dictionary = schiera["imbarco"]
	for m in [schiera["condottiero"]] + schiera["soldati"]:
		m.visible = false
		m.percorri([m.pos] as Array[Vector2])
	var nave := _nuovo(Vector2(imb["acqua"]) + Vector2(0.5, 0.5), "nave")
	nave.velocita = 2.2
	nave.arrivato.connect(func(_c): _sbarca())
	nave.percorri(imb["rotta"].duplicate())
	schiera["nave"] = nave
	villaggio.messaggio.emit("La schiera di %s salpa verso l'altro porto" % nome_condottiero(), false)


func _sbarca() -> void:
	if not esiste() or not schiera.has("nave"):
		return
	var meta: Edificio = schiera["imbarco"]["meta"]
	var terra := Vector2(meta.bandiera) + Vector2(0.5, 0.6)
	schiera["condottiero"].pos = terra
	schiera["condottiero"].visible = true
	for k in schiera["soldati"].size():
		var s: Colono = schiera["soldati"][k]
		s.pos = terra + _posto(k)
		s.visible = true
	schiera["nave"].queue_free()
	schiera.erase("nave")
	schiera.erase("imbarco")
	villaggio.messaggio.emit("La schiera di %s è sbarcata" % nome_condottiero(), false)
	cambiata.emit()


## Attacca una torre nemica o un villaggio indigeno: la schiera ci va e combatte.
func attacca(bersaglio) -> bool:
	if not esiste() or in_viaggio():
		return false
	schiera.erase("imbarco")
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
	if tipo() == "tiratori":
		# i tiratori si fermano a distanza di tiro, dalla parte da cui arrivano
		var punto := centro + (capo.pos - centro).normalized() * (DISTANZA_TIRO - 1.0)
		vicino = _vicino_a_piedi(Vector2i(punto.floor()), 0)
	var percorso := percorso_a_piedi(Vector2i(capo.pos.floor()), vicino)
	if percorso.is_empty():
		return false
	schiera["bersaglio"] = bersaglio
	_marcia(percorso)
	return true


func _vicino_a_piedi(c: Vector2i, da_raggio := 2) -> Vector2i:
	for r in range(da_raggio, 6):
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


static func tipo() -> String:
	return Popoli.tipo_soldato(Popoli.giocatore)


## Da quanto lontano combatte la schiera: i tiratori da lontano, gli altri corpo a corpo.
static func distanza_assalto() -> float:
	return DISTANZA_TIRO if tipo() == "tiratori" else DISTANZA_ASSALTO


## Il livello del condottiero (1–5): sale con i duelli vinti dalla sua schiera.
func livello() -> int:
	return mini(LIVELLO_MAX, 1 + esperienza / ESPERIENZA_LIVELLO)


static func abilita() -> Array:
	return ABILITA.get(Popoli.giocatore, [])


## Perché un'abilità non si può usare adesso («» se si può).
func motivo_no_abilita(k: int) -> String:
	if not esiste():
		return "Nessuna schiera"
	if livello() < LIVELLI_ABILITA[k]:
		return "Si impara al livello %d" % LIVELLI_ABILITA[k]
	if _ricarica[k] > 0.0:
		return "Pronta tra %d s" % ceili(_ricarica[k])
	return ""


func usa_abilita(k: int) -> bool:
	if k >= abilita().size() or motivo_no_abilita(k) != "":
		return false
	var a: Dictionary = abilita()[k]
	match a["effetto"]:
		"duelli":
			_bonus_duelli = a["valore"]
			_bonus_fino = _orologio + a["durata"]
		"morale":
			_cambia_morale(a["valore"])
		"passo":
			_passo = a["valore"]
			_passo_fino = _orologio + a["durata"]
			_imposta_velocita()
	_ricarica[k] = RICARICA
	villaggio.messaggio.emit("%s: %s!" % [nome_condottiero(), a["nome"]], false)
	Suono.suona("completato")
	cambiata.emit()
	return true


func bonus_attivo() -> float:
	return _bonus_duelli if _orologio < _bonus_fino else 0.0


func _imposta_velocita() -> void:
	var v := _passo if _orologio < _passo_fino else 1.0
	schiera["condottiero"].velocita = v
	for s in schiera["soldati"]:
		s.velocita = v


## Probabilità che un nostro soldato vinca un duello: base, vantaggi dei monumenti, morale, livello e il
## tipo dei soldati contro quello dei difensori (di serie fanteria, come i villaggi indigeni).
func probabilita_vittoria(tipo_difensore := "fanteria") -> float:
	var morale: float = schiera.get("morale", 70) if esiste() else 70.0
	return clampf(0.55 + villaggio.vantaggi.get("duelli", 0.0) + (morale - 50.0) / 500.0 + 0.02 * (livello() - 1)
		+ Popoli.vantaggio_tipo(tipo(), tipo_difensore) + bonus_attivo(), 0.1, 0.95)


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
	_orologio += delta
	for k in 2:
		_ricarica[k] = maxf(0.0, _ricarica[k] - delta)
	if not esiste():
		return
	if _passo != 1.0 and _orologio >= _passo_fino:
		_passo = 1.0
		_imposta_velocita()
	if schiera.has("imbarco") and not schiera.has("nave"):
		var porto: Edificio = schiera["imbarco"]["porto"]
		if not is_instance_valid(porto):
			schiera.erase("imbarco")
		elif schiera["condottiero"].pos.distance_to(Vector2(porto.bandiera) + Vector2(0.5, 0.5)) < 1.6:
			_salpa()
	if in_viaggio():
		queue_redraw()
		return
	queue_redraw()
	_avanza_effetti(delta)
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
	if capo.pos.distance_to(centro) > distanza_assalto() + 0.5:
		return
	_duello -= delta
	if _duello > 0.0:
		return
	_duello = DURATA_DUELLO
	capo.imposta_foglio(_foglio_condottiero(true))
	for s in schiera["soldati"]:
		s.imposta_foglio(Popoli.soldati(1)[1])
	_combatti(b)
	_effetti(centro)


## Sassi e frecce che volano dai tiratori al bersaglio, polvere nei duelli corpo a corpo.
func _effetti(centro: Vector2) -> void:
	var truppa: Array = schiera["soldati"]
	if tipo() == "tiratori":
		for k in mini(3, truppa.size()):
			var s: Colono = truppa[_rng.randi_range(0, truppa.size() - 1)]
			_proiettili.append([s.pos, centro + Vector2(_rng.randf_range(-0.6, 0.6), _rng.randf_range(-0.6, 0.6)), 0.0])
	else:
		_polvere.append([centro + Vector2(_rng.randf_range(-1.0, 1.0), _rng.randf_range(-1.0, 1.0)), 0.0])


func _avanza_effetti(delta: float) -> void:
	for pr in _proiettili:
		pr[2] += delta
	_proiettili = _proiettili.filter(func(pr): return pr[2] < VOLO)
	for po in _polvere:
		po[1] += delta
	_polvere = _polvere.filter(func(po): return po[1] < 0.8)


## Un duello: vince il nostro (con il vantaggio dei duelli e il condottiero che dà coraggio) o il difensore.
func _combatti(b) -> void:
	var tipo_dif := "fanteria"
	if b is Edificio:
		tipo_dif = Popoli.tipo_soldato(Popoli.di(b.proprietario))
	if _rng.randf() < probabilita_vittoria(tipo_dif):
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
	for pr in _proiettili:
		var f: float = pr[2] / VOLO
		var a := dati.a_schermo(pr[0].x, pr[0].y)
		var b := dati.a_schermo(pr[1].x, pr[1].y)
		var q := a.lerp(b, f) + Vector2(0, -40.0 * sin(f * PI) - 20.0)
		draw_circle(q, 2.5, Color("3a3028"))
	for po in _polvere:
		var t: float = po[1] / 0.8
		draw_circle(dati.a_schermo(po[0].x, po[0].y) + Vector2(0, -10), 8.0 + 14.0 * t, Color(0.82, 0.74, 0.58, 0.45 * (1.0 - t)))
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
