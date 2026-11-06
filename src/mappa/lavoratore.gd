class_name Lavoratore
extends Colono
## Il lavoratore di un edificio di produzione. Arriva dalla propria casa lungo le strade, entra
## nell'edificio e poi lavora: esce a piedi verso alberi, rocce, campi o riva, torna con la merce
## e la posa alla bandierina; oppure (segheria, mulino, forno, pozzo) la fa dentro l'edificio,
## consumando le merci che gli arrivano, ed esce a posare il prodotto.

enum Stato { ARRIVO, DENTRO, ANDATA, LAVORO, RITORNO, ESCE_CON_MERCE, NAVIGA }

const RAGGIO := 7
const PAUSA := 3.5
## suono di lavoro di ogni mestiere e secondi tra un colpo e l'altro
const SUONI := {"boscaiolo": ["ascia", 0.85], "guardaboschi": ["vanga", 1.3],
	"segheria": ["segheria", 1.2], "cava": ["cava", 1.3], "fattoria": ["falce", 1.1], "vigneto": ["falce", 1.4], "ortolano": ["vanga", 1.3],
	"agrumeto": ["falce", 1.6], "uliveto": ["falce", 1.5], "mulino": ["macina", 1.7], "pozzo": ["tuffo", 2.4],
	"miniera_ferro": ["piccone", 0.9], "miniera_argento": ["piccone", 0.9], "fabbro": ["martello", 0.7],
	"fonderia": ["macina", 2.0], "zecca": ["martello", 1.2], "armaiolo": ["martello", 0.8], "caserma": ["scontro", 2.5], "argillaio": ["vanga", 1.3], "fornace": ["macina", 2.2]}
## secondi di lavoro sul posto (o dentro l'edificio)
const DURATA := {"boscaiolo": 4.0, "cava": 4.0, "guardaboschi": 3.0, "fattoria": 3.5, "pescatore": 6.0,
	"uliveto": 4.0, "pesca_spada": 9.0}
const DURATA_DENTRO := 5.0
const MESTIERI_FUORI := ["boscaiolo", "cava", "guardaboschi", "pescatore", "uliveto", "pesca_spada", "raccoglitore_funghi"]
const RAGGIO_LARGO := 12
const RAGGIO_CAMPI := 4
const MAX_CAMPI := 8

var edificio: Edificio
var risorse: RisorseNaturali
var logistica: Logistica
var rete: ReteStrade
var stato := Stato.ARRIVO
var mestiere := ""
var _bersaglio := Vector2i(-1, -1)
var _acqua := Vector2i(-1, -1)       # casella di mare dove pesca il pescatore
var _semina := false                 # il contadino sta seminando (non mietendo)
var _turno := 0                      # per chi produce più merci a turno (ovile: latte e lana)
var _coltura := ""                   # per i contadini: grano, vite, orto, agrumi
var _foglio_terra := ""              # foglio da usare a terra (la barca lo cambia sull'acqua)
var _partenza_nave := Vector2.ZERO   # il porto: casella di mare da cui la nave parte e a cui torna
var _rotta_nave: Array[Vector2] = []  # il porto: le tappe sul mare dell'andata
const VELOCITA_NAVE := 2.2
var _velocita_terra := 1.15
const RAGGIO_ROTTA := 26
var _attrezzo_scelto := ""           # quello che il fabbro sta forgiando
var entrato := false                 # è già arrivato all'edificio almeno una volta
var _attesa := 0.0
var _foglio_cammino := ""
var _foglio_lavoro := ""
var _avvisato := false
var _colpo := 0.0


func avvia(e: Edificio, r: RisorseNaturali, l: Logistica, rs: ReteStrade, partenza: Array[Vector2]) -> void:
	edificio = e
	risorse = r
	logistica = l
	rete = rs
	mestiere = e.tipo
	var info := CatalogoEdifici.dati(e.tipo)
	_foglio_cammino = info.get("lavoratore", "portatore_nessuno")
	if _foglio_cammino == "guardia":
		_foglio_cammino = Popoli.soldati(e.proprietario)[0]     # la guardia ha l'aspetto del suo popolo
	_foglio_lavoro = _foglio_cammino + "_lavoro" if _foglio_cammino.begins_with("lavoratore") else ""
	_coltura = info.get("coltura", "")
	prepara(e.dati_mappa, partenza[0], _foglio_cammino, Popoli.di(e.proprietario))
	arrivato.connect(_on_arrivato)
	partenza.append(e.centro())
	percorri(partenza)


func _porta() -> Vector2:
	return Vector2(edificio.bandiera) + Vector2(0.5, 0.5)


## La barca del pesce spada e la nave del porto: sull'acqua navigano, a terra si cammina.
func imposta_foglio(foglio: String) -> void:
	_foglio_terra = foglio
	if mestiere in ["pesca_spada", "porto"] and dati and dati.tipo(int(pos.x), int(pos.y)) == DatiMappa.Terreno.ACQUA:
		foglio = "nave" if mestiere == "porto" and ResourceLoader.exists("res://assets/grafica/nave.png") else "barca_remi"
	super.imposta_foglio(foglio)


func _process(delta: float) -> void:
	super._process(delta)
	if not is_instance_valid(edificio) or edificio.is_queued_for_deletion():
		queue_free()
		return
	if mestiere in ["pesca_spada", "porto"] and visible:
		imposta_foglio(_foglio_terra)
	match stato:
		Stato.DENTRO:
			_attesa -= delta
			if _attesa <= 0.0:
				_cerca_lavoro()
		Stato.LAVORO:
			_attesa -= delta
			_suona_lavoro(delta)
			if _attesa <= 0.0:
				_fine_lavoro()


func _on_arrivato(_c: Colono) -> void:
	match stato:
		Stato.ARRIVO:
			_entra()
		Stato.ANDATA:
			stato = Stato.LAVORO
			_colpo = 0.3
			_attesa = DURATA.get(mestiere, 4.0)
			if _coltura != "":
				_attesa = 3.5
			if _foglio_lavoro != "":
				imposta_foglio(_foglio_lavoro)
				_anim.play()
		Stato.NAVIGA:
			# il porto: arrivata alla meta, la nave torna indietro con il guadagno
			stato = Stato.ESCE_CON_MERCE
			var ritorno: Array[Vector2] = _rotta_nave.duplicate()
			ritorno.reverse()
			ritorno.append_array([_partenza_nave, _porta()] as Array[Vector2])
			percorri(ritorno)
		Stato.RITORNO, Stato.ESCE_CON_MERCE:
			if mestiere == "porto":
				velocita = _velocita_terra
			logistica.produci(_merce_prodotta(), edificio)
			if mestiere == "porto" and edificio.proprietario == 1 and Popoli.mercanti():
				logistica.produci(_merce_prodotta(), edificio)      # i Cartaginesi: il porto rende il doppio
			_turno += 1
			imposta_foglio(_foglio_cammino)
			stato = Stato.ARRIVO
			var dentro: Array[Vector2] = [edificio.centro()]
			percorri(dentro)


func _entra() -> void:
	entrato = true
	stato = Stato.DENTRO
	if CatalogoEdifici.dati(mestiere).has("presidio"):
		edificio.villaggio.presidia(edificio)
	visible = false
	_attesa = PAUSA


func _cerca_lavoro() -> void:
	_attesa = PAUSA
	if not logistica.puo_produrre(edificio):
		return
	var da := edificio.bandiera
	if _coltura != "":
		if not _cerca_campo(da):
			return
		_esci_verso_bersaglio()
		return
	match mestiere:
		"boscaiolo":
			_bersaglio = risorse.albero_vicino(da, RAGGIO)
			if _bersaglio.x < 0 or not risorse.prenota_albero(_bersaglio):
				_segnala("Il boscaiolo non trova alberi vicini")
				return
		"cava":
			_bersaglio = risorse.roccia_vicina(da, RAGGIO)
			if _bersaglio.x < 0 or not risorse.prenota_roccia(_bersaglio):
				_segnala("La cava non trova rocce vicine")
				return
		"guardaboschi":
			_bersaglio = risorse.posto_per_albero(da, RAGGIO - 1, rete)
			if _bersaglio.x < 0:
				return
		"uliveto":
			_bersaglio = risorse.ulivo_con_olive(da, RAGGIO)
			if _bersaglio.x < 0 or not risorse.prenota_ulivo(_bersaglio):
				return
		"raccoglitore_funghi":
			_bersaglio = risorse.fungo_vicino(da, RAGGIO_LARGO)
			if _bersaglio.x < 0 or not risorse.prenota_fungo(_bersaglio):
				_segnala("Il raccoglitore non trova porcini nei boschi vicini")
				return
		"pesca_spada":
			_acqua = risorse.posto_al_largo(da, RAGGIO_LARGO)
			if _acqua.x < 0:
				_segnala("La barca non trova mare aperto vicino")
				return
			_bersaglio = _acqua
		"pescatore":
			var posto := risorse.posto_di_pesca(da, RAGGIO)
			if posto.is_empty():
				_segnala("Il pescatore non trova pesce vicino alla riva")
				return
			_bersaglio = posto[0]
			_acqua = posto[1]
		_:
			if mestiere in MESTIERI_FUORI:
				return
			_lavora_dentro()
			return
	_esci_verso_bersaglio()


func _esci_verso_bersaglio() -> void:
	_avvisato = false
	visible = true
	stato = Stato.ANDATA
	pos = edificio.centro()
	var punti: Array[Vector2] = [_porta(), Vector2(_bersaglio) + Vector2(0.35, 0.75)]
	percorri(punti)


## Contadino: raccoglie un campo maturo della sua coltura, altrimenti ne semina uno nuovo.
func _cerca_campo(da: Vector2i) -> bool:
	_semina = false
	_bersaglio = risorse.campo_maturo(da, RAGGIO_CAMPI + 1, _coltura)
	if _bersaglio.x >= 0 and risorse.prenota_campo(_bersaglio):
		return true
	_semina = true
	if risorse.stagioni and risorse.stagioni.inverno():
		return false
	if risorse.campi_vicini(da, RAGGIO_CAMPI + 1, _coltura) >= MAX_CAMPI:
		return false
	_bersaglio = risorse.posto_per_campo(da, RAGGIO_CAMPI, rete)
	if _bersaglio.x < 0:
		_segnala("%s: non c'è spazio per i campi" % CatalogoEdifici.dati(mestiere)["nome"])
		return false
	return true


func _fine_lavoro() -> void:
	if mestiere == "agora" and _attrezzo_scelto != "":
		_torna(Merce.FOGLI.get(_attrezzo_scelto, "portatore_nessuno"))
		return
	if mestiere == "caserma":
		edificio.villaggio.arruola()
		edificio.prodotti += 1
		stato = Stato.DENTRO
		_attesa = PAUSA
		return
	if _coltura != "":
		if _semina:
			if dati.occupante(_bersaglio.x, _bersaglio.y) == 0:
				risorse.semina(_bersaglio, _coltura)
			_rientra_vuoto()
		else:
			risorse.mieti(_bersaglio)
			_torna(Merce.FOGLI[_merce_prodotta()])
		return
	match mestiere:
		"boscaiolo":
			risorse.abbatti(_bersaglio)
			Suono.suona_in("albero_cade", global_position)
			_torna(Merce.FOGLI["tronchi"])
		"cava":
			risorse.estrai(_bersaglio)
			_torna(Merce.FOGLI["pietra"])
		"guardaboschi":
			if dati.occupante(_bersaglio.x, _bersaglio.y) == 0:
				risorse.pianta(_bersaglio)
			_rientra_vuoto()
		"uliveto":
			risorse.raccogli_olive(_bersaglio)
			_torna(Merce.FOGLI["olive"])
		"raccoglitore_funghi":
			if risorse.raccogli_fungo(_bersaglio):
				_torna(Merce.FOGLI["porcini"])
			else:
				_rientra_vuoto()
		"pesca_spada":
			if risorse.pesca_spada(_acqua):
				Suono.suona_in("tuffo", global_position, -2.0)
				_torna(Merce.FOGLI["pesce_spada"])
			else:
				_rientra_vuoto()
		"porto":
			_salpa()
		"pescatore":
			if risorse.pesca(_acqua):
				Suono.suona_in("tuffo", global_position, -4.0)
				_torna(Merce.FOGLI["pesce"])
			else:
				_rientra_vuoto()
		_:
			# esce dalla porta con il prodotto e lo posa alla bandierina
			visible = true
			pos = edificio.centro()
			imposta_foglio(Merce.FOGLI.get(_merce_prodotta(), "portatore_nessuno"))
			stato = Stato.ESCE_CON_MERCE
			var punti: Array[Vector2] = [_porta()]
			percorri(punti)


## Dentro l'edificio: se ci sono tutte le merci in ingresso (e il cibo, per i minatori),
## ne consuma una per tipo e lavora. La miniera scava il giacimento; il fabbro sceglie l'attrezzo.
func _lavora_dentro() -> void:
	var info := CatalogoEdifici.dati(mestiere)
	var ingressi: Dictionary = info.get("ingressi", {})
	if mestiere == "apiario" and risorse.stagioni and risorse.stagioni.inverno():
		return
	if mestiere == "agora":
		_lavora_agora()
		return
	if mestiere == "casa_pionieri":
		return
	if info.has("presidio"):
		return                 # la guardia sta di vedetta: niente da produrre
	if mestiere == "caserma":
		# un'armatura e un colono libero diventano un oplita
		if edificio.ingresso.get("armi", 0) <= 0 or not edificio.villaggio.prendi_colono():
			return
		edificio.ingresso["armi"] -= 1
		stato = Stato.LAVORO
		_attesa = info.get("durata", DURATA_DENTRO) * edificio.villaggio.vantaggi.get("lavoro", 1.0) * Popoli.durata(mestiere)
		return
	if mestiere == "fabbro":
		_attrezzo_scelto = logistica.attrezzo_da_fare()
		if _attrezzo_scelto == "":
			return
	elif ingressi.is_empty() and not info.has("cibo") and not logistica.serve(_merce_prodotta()):
		return
	elif not ingressi.is_empty() and not logistica.serve(_merce_prodotta(), Logistica.SCORTA_MASSIMA):
		return
	for tipo in ingressi:
		if edificio.ingresso.get(tipo, 0) <= 0:
			return
	var cibo := ""
	if info.has("cibo"):
		for c in CatalogoEdifici.CIBI:
			if edificio.ingresso.get(c, 0) > 0 and (cibo == "" or edificio.ingresso[c] > edificio.ingresso[cibo]):
				cibo = c
		if cibo == "":
			_segnala("%s: i minatori hanno fame" % info["nome"])
			return
	if info.has("miniera") and not risorse.scava(Vector2i(edificio.centro()), info["miniera"]):
		_segnala("%s: il giacimento è esaurito" % info["nome"])
		return
	_avvisato = false
	if cibo != "":
		edificio.ingresso[cibo] -= 1
	for tipo in ingressi:
		edificio.ingresso[tipo] -= 1
	stato = Stato.LAVORO
	_attesa = CatalogoEdifici.dati(mestiere).get("durata", DURATA_DENTRO) * edificio.villaggio.vantaggi.get("lavoro", 1.0) * Popoli.durata(mestiere)


## Agorà: vende una merce arrivata (i ducati vanno subito in cassa), altrimenti compra quella scelta
## con i ducati del magazzino e il mercante la porta fuori.
func _lavora_agora() -> void:
	var v: Villaggio = edificio.villaggio
	_attrezzo_scelto = ""
	var coda := edificio.vendite_in_coda.duplicate()
	if coda.is_empty():
		for m in CatalogoEdifici.VENDITA:
			if edificio.ingresso.get(m, 0) > 0:
				coda.append(m)
	for m in coda:
		if edificio.ingresso.get(m, 0) > 0:
			edificio.ingresso[m] -= 1
			var posto := edificio.vendite_in_coda.find(m)
			if posto >= 0:
				edificio.vendite_in_coda.remove_at(posto)
			var ricavo: int = CatalogoEdifici.VENDITA[m]
			v.scorte["ducati"] = v.scorte.get("ducati", 0) + ricavo
			edificio.guadagno += ricavo
			v.scorte_cambiate.emit()
			Suono.suona_in("completato", edificio.global_position, -10.0)
			_attesa = 2.0          # il mercante resta al banco: la prossima vendita tra poco
			return
	var a := edificio.acquisto
	if a != "" and v.scorte.get("ducati", 0) >= CatalogoEdifici.ACQUISTO[a] and logistica.serve(a, Logistica.SCORTA_MASSIMA):
		v.scorte["ducati"] -= CatalogoEdifici.ACQUISTO[a]
		v.scorte_cambiate.emit()
		_attrezzo_scelto = a
		stato = Stato.LAVORO
		_attesa = CatalogoEdifici.dati(mestiere).get("durata", DURATA_DENTRO) * edificio.villaggio.vantaggi.get("lavoro", 1.0) * Popoli.durata(mestiere)


func _rientra_vuoto() -> void:
	imposta_foglio(_foglio_cammino)
	stato = Stato.ARRIVO
	var punti: Array[Vector2] = [_porta(), edificio.centro()]
	percorri(punti)


func _suona_lavoro(delta: float) -> void:
	if not SUONI.has(mestiere):
		return
	_colpo -= delta
	if _colpo <= 0.0:
		_colpo = SUONI[mestiere][1]
		var dove := global_position if visible else edificio.global_position
		Suono.suona_in(SUONI[mestiere][0], dove, -3.0)


func _torna(foglio: String) -> void:
	imposta_foglio(foglio)
	stato = Stato.RITORNO
	var punti: Array[Vector2] = [_porta()]
	percorri(punti)


func _merce_prodotta() -> String:
	if mestiere == "fabbro" or mestiere == "agora":
		return _attrezzo_scelto
	var p := CatalogoEdifici.prodotti(mestiere)
	return "" if p.is_empty() else p[_turno % p.size()]


func _segnala(testo: String) -> void:
	if not _avvisato:
		_avvisato = true
		edificio.villaggio.messaggio.emit(testo, true)


## Il porto: la nave parte con le anfore, attraversa il mare fino a un altro porto (lo Stretto) o al largo,
## e torna con il guadagno. Senza mare libero si commercia sulla riva.
func _salpa() -> void:
	var partenza := _acqua_vicina(Vector2i(edificio.centro()), 7)
	_rotta_nave = rotta_nave(partenza) if partenza.x >= 0 else ([] as Array[Vector2])
	if _rotta_nave.is_empty():
		_torna(Merce.FOGLI.get(_merce_prodotta(), "portatore_nessuno"))
		return
	visible = true
	_partenza_nave = Vector2(partenza) + Vector2(0.5, 0.5)
	pos = _partenza_nave
	stato = Stato.NAVIGA
	_velocita_terra = velocita
	velocita = VELOCITA_NAVE
	imposta_foglio(_foglio_cammino)
	percorri(_rotta_nave.duplicate())


## Le tappe della nave: fino al porto più vicino raggiungibile per mare (la traversata dello Stretto),
## altrimenti dritta al largo, il più lontano possibile. Vuota se non c'è mare libero.
func rotta_nave(da: Vector2i) -> Array[Vector2]:
	var migliore: Array[Vector2] = []
	for e in edificio.villaggio.edifici.values():
		if e == edificio or e.tipo != "porto" or not e.finito:
			continue
		var w := _acqua_vicina(Vector2i(e.centro()), 7)
		if w.x < 0:
			continue
		var r := _rotta_sul_mare(da, w)
		if not r.is_empty() and (migliore.is_empty() or r.size() < migliore.size()):
			migliore = r
	if not migliore.is_empty():
		return migliore
	var meta := _meta_al_largo(da)
	if meta.x >= 0:
		migliore.append(Vector2(meta) + Vector2(0.5, 0.5))
	return migliore


## Il percorso più breve sul mare da una casella d'acqua all'altra (le tappe, senza la partenza).
func _rotta_sul_mare(da: Vector2i, a: Vector2i) -> Array[Vector2]:
	var da_dove := {da: da}
	var coda: Array[Vector2i] = [da]
	var i := 0
	while i < coda.size():
		var c: Vector2i = coda[i]
		i += 1
		if c == a:
			break
		for dy in range(-1, 2):
			for dx in range(-1, 2):
				var n := c + Vector2i(dx, dy)
				if not da_dove.has(n) and dati.dentro(n.x, n.y) and dati.tipo(n.x, n.y) == DatiMappa.Terreno.ACQUA:
					da_dove[n] = c
					coda.append(n)
	var rotta: Array[Vector2] = []
	if not da_dove.has(a):
		return rotta
	var c := a
	while c != da:
		rotta.push_front(Vector2(c) + Vector2(0.5, 0.5))
		c = da_dove[c]
	return rotta


## Al largo, dritto e il più lontano possibile.
func _meta_al_largo(da: Vector2i) -> Vector2i:
	var migliore := Vector2i(-1, -1)
	var lontano := 0.0
	for y in range(da.y - RAGGIO_ROTTA, da.y + RAGGIO_ROTTA + 1, 2):
		for x in range(da.x - RAGGIO_ROTTA, da.x + RAGGIO_ROTTA + 1, 2):
			var c := Vector2i(x, y)
			var d := Vector2(c - da).length()
			if d > RAGGIO_ROTTA or d <= lontano or not risorse._al_largo(c) or not _rotta_libera(da, c):
				continue
			lontano = d
			migliore = c
	return migliore


func _acqua_vicina(c: Vector2i, raggio: int) -> Vector2i:
	var migliore := Vector2i(-1, -1)
	var meglio := INF
	for y in range(c.y - raggio, c.y + raggio + 1):
		for x in range(c.x - raggio, c.x + raggio + 1):
			var d := Vector2(x - c.x, y - c.y).length()
			if d < meglio and dati.dentro(x, y) and dati.tipo(x, y) == DatiMappa.Terreno.ACQUA:
				meglio = d
				migliore = Vector2i(x, y)
	return migliore


## Una rotta dritta che passa solo sul mare.
func _rotta_libera(a: Vector2i, b: Vector2i) -> bool:
	var passi := int(Vector2(b - a).length() * 3.0) + 1
	for k in passi + 1:
		var p := (Vector2(a) + Vector2(0.5, 0.5)).lerp(Vector2(b) + Vector2(0.5, 0.5), float(k) / passi)
		if not dati.dentro(int(p.x), int(p.y)) or dati.tipo(int(p.x), int(p.y)) != DatiMappa.Terreno.ACQUA:
			return false
	return true
