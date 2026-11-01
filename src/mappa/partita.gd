extends Node2D
## Scena della partita: mappa, natura, villaggio, costruzione di edifici dentro i confini.

const T := DatiMappa.Terreno
const SEME := 1987

var dati: DatiMappa
var terreno: Terreno
var segni: SegniMappa
var rete: ReteStrade
var oggetti: Node2D
var camera: CameraMappa
var villaggio: Villaggio
var logistica: Logistica
var risorse: RisorseNaturali
var stagioni: Stagioni
var guerra: Guerra
var avversario: Avversario
var missione: Missione
var pannello_missione: PannelloMissione
var _attaccante: Edificio

var menu: MenuCostruzione
var pannello: PannelloEdificio
var pannello_villaggio: PannelloVillaggio
var barra: BarraRisorse
var _avviso: Label
var _tween_avviso: Tween

var modalita := ""          # "", "costruisci", "strada", "bandierina", "demolisci"
var _inizio_strada := Vector2i(-1, -1)
var _percorso: Array[Vector2i] = []
var tipo_scelto := ""
var _fantasma: Sprite2D
var _casella_mouse := Vector2i(-1, -1)
var _evidenziato: Edificio
var _ascolto_mare := 0.0
var monumenti: Monumenti
var indigeni: VillaggiIndigeni
var schiere: Schiere
var pannello_indigeno: PannelloIndigeno
var pannello_schiera: PannelloSchiera
var mappa := "costa_ionica"
var popolo := "greci"         # il popolo del giocatore (Popoli.DATI)   # quale mappa si gioca (GeneratoreMappa.MAPPE)
var decori := {}            # Vector2i -> [Sprite2D] fiori, funghi, cespugli (spariscono sotto gli edifici)


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("16384f"))
	mappa = _mappa_da_usare()
	popolo = _popolo_da_usare()
	Popoli.giocatore = popolo
	dati = GeneratoreMappa.crea(mappa, SEME)

	terreno = Terreno.new()
	add_child(terreno)
	terreno.costruisci(dati)

	rete = ReteStrade.new()
	add_child(rete)

	segni = SegniMappa.new()
	add_child(segni)

	oggetti = Node2D.new()
	oggetti.y_sort_enabled = true
	add_child(oggetti)

	_metti_nomi_luoghi()

	villaggio = Villaggio.new(dati, oggetti)
	add_child(villaggio)
	villaggio.rete = rete
	rete.prepara(dati, villaggio, oggetti)
	rete.cambiata.connect(villaggio._aggiorna_collegamenti)
	rete.cambiata.connect(segni.queue_redraw)
	segni.prepara(dati, villaggio)
	logistica = Logistica.new()
	add_child(logistica)
	logistica.prepara(dati, villaggio, rete, oggetti)
	risorse = RisorseNaturali.new()
	add_child(risorse)
	risorse.prepara(dati, oggetti)
	stagioni = Stagioni.new()
	add_child(stagioni)
	risorse.stagioni = stagioni
	villaggio.risorse = risorse
	guerra = Guerra.new()
	add_child(guerra)
	guerra.prepara(villaggio, rete, dati, oggetti)
	villaggio.guerra = guerra
	guerra.messaggio.connect(_mostra_avviso)
	avversario = Avversario.new()
	add_child(avversario)
	avversario.prepara(villaggio, guerra, dati)
	avversario.messaggio.connect(_mostra_avviso)
	monumenti = Monumenti.new()
	add_child(monumenti)
	indigeni = VillaggiIndigeni.new()
	add_child(indigeni)
	indigeni.prepara(villaggio, dati, oggetti, risorse)
	schiere = Schiere.new()
	add_child(schiere)
	schiere.prepara(villaggio, guerra, indigeni, dati, oggetti)
	avversario.imposta_modalita("pace" if Impostazioni.missione != "" else Impostazioni.modalita)
	villaggio.logistica = logistica
	villaggio.territorio_cambiato.connect(segni.aggiorna)
	villaggio.messaggio.connect(_mostra_avviso)
	villaggio.togli_decori.connect(_togli_decori)

	_metti_natura()
	var da_caricare := Salvataggio.da_caricare
	Salvataggio.da_caricare = ""
	if da_caricare == "" and Impostazioni.missione != "":
		var d: Dictionary = Missione.MISSIONI[Impostazioni.missione]
		_metti_villaggio(d["villaggio"] == "relitto")
		if d.get("brettii", false):
			_metti_brettii()
		if d.get("costa", false):
			_torri_verso_costa()
		for r in d["scorte"]:
			villaggio.scorte[r] = d["scorte"][r]
		villaggio.coloni_liberi = d["coloni"] - rete.portatori() - villaggio.lavoratori()
	elif da_caricare == "":
		_metti_villaggio()
		if Impostazioni.modalita != "pace":
			_metti_brettii()

	if da_caricare == "":
		indigeni.genera(mappa)

	camera = CameraMappa.new()
	camera.area = terreno.limiti()
	camera.position = dati.a_schermo(dati.villaggio.x + 0.5, dati.villaggio.y + 0.5)
	add_child(camera)
	camera.make_current()
	camera.tocco_lungo.connect(_annulla)

	_crea_interfaccia()
	stagioni.prepara(terreno, risorse, _crea_luce(), _crea_fiocchi())
	monumenti.prepara(villaggio, dati, oggetti, logistica, guerra, stagioni, mappa)
	stagioni.cambiata.connect(func(s: int):
		barra.aggiorna_stagione(stagioni.nome())
		_mostra_avviso("Arriva %s" % ["la primavera", "l'estate", "l'autunno", "l'inverno"][s], false))
	villaggio.scorte_cambiate.connect(func(): barra.aggiorna(villaggio.scorte))
	villaggio.popolazione_cambiata.connect(func(): barra.aggiorna_coloni(villaggio.popolazione(), villaggio.capacita()))
	villaggio.territorio_cambiato.connect(func(): barra.aggiorna_coloni(villaggio.popolazione(), villaggio.capacita()))
	logistica.scorte_cambiate.connect(func(): barra.aggiorna(villaggio.scorte))
	logistica.scorte_cambiate.connect(villaggio.richiama_lavoratori)
	if da_caricare == "" and Impostazioni.missione != "":
		avvia_missione(Impostazioni.missione, 0)
		missione.comincia.call_deferred()
	if da_caricare != "":
		if Salvataggio.carica(self, da_caricare):
			segni.aggiorna()
			_mostra_avviso("Partita caricata", false)
		else:
			_metti_villaggio()
			_metti_brettii()
			_mostra_avviso("Il salvataggio non si può leggere: nuova partita", true)
	barra.aggiorna(villaggio.scorte)
	barra.aggiorna_coloni(villaggio.popolazione(), villaggio.capacita())
	barra.aggiorna_stagione(stagioni.nome())
	Suono.scaletta(["lavoro", "mattino", "sera"] as Array[String])
	Suono.ambiente("uccelli", -6.0)
	Suono.ambiente("vento", -12.0)
	Suono.ambiente("mare", -40.0)


func _notification(what: int) -> void:
	# chiudendo la finestra la partita si salva da sola
	if what == NOTIFICATION_WM_CLOSE_REQUEST and villaggio:
		Salvataggio.salva(self)


func _exit_tree() -> void:
	Suono.spegni_ambiente()


# --------------------------------------------------------------- comandi

func _process(delta: float) -> void:
	_ascolto_mare -= delta
	if _ascolto_mare <= 0.0:
		_ascolto_mare = 0.5
		_aggiorna_ambiente()
	var c := dati.casella_da_schermo(get_global_mouse_position())
	if c == _casella_mouse:
		return
	_casella_mouse = c
	_aggiorna_fantasma()
	_aggiorna_evidenziato()
	_aggiorna_anteprima_strada()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if schiere.scelta:
			schiere.scegli(false)
		elif pannello.visible or pannello_villaggio.visible:
			pannello.chiudi_pannello()
			pannello_villaggio.visible = false
		elif modalita != "":
			_esci_modalita()
		else:
			Salvataggio.salva(self)
			get_tree().change_scene_to_file("res://src/main/title_screen.tscn")
		get_viewport().set_input_as_handled()
	elif event is InputEventKey and event.pressed and not event.echo:
		match (event as InputEventKey).keycode:
			KEY_R:
				menu.premi_attrezzo("strada")
			KEY_F:
				menu.premi_attrezzo("bandierina")
			KEY_F5:
				_mostra_avviso("Partita salvata" if Salvataggio.salva(self) else "Non sono riuscito a salvare", false)
			KEY_F9:
				if Salvataggio.esiste():
					Salvataggio.da_caricare = Salvataggio.PERCORSO
					get_tree().reload_current_scene()
			KEY_I:
				pannello_villaggio.alterna()
			KEY_1, KEY_2:
				if schiere.scelta:
					schiere.usa_abilita((event as InputEventKey).keycode - KEY_1)
			KEY_M:
				_mostra_avviso("Musica accesa" if Suono.alterna_musica() else "Musica spenta", false)
	elif event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		var casella := dati.casella_da_schermo(get_canvas_transform().affine_inverse() * mb.position)
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.device == InputEvent.DEVICE_ID_EMULATION:
			# da un dito: il clic vale quando si alza, se non era un trascinamento né un tocco lungo
			if not mb.pressed and not camera.tocco_mosso and not camera.tocco_lungo_fatto:
				_clic(casella)
		elif not mb.pressed:
			return
		elif mb.button_index == MOUSE_BUTTON_LEFT:
			_clic(casella)
		elif mb.button_index == MOUSE_BUTTON_RIGHT:
			_annulla()


## Tasto destro o tocco lungo: annulla la strada iniziata o esce dalla modalità (o lascia la schiera).
func _annulla() -> void:
	if schiere.scelta:
		schiere.scegli(false)
		return
	if modalita == "":
		return
	if modalita == "strada" and _inizio_strada.x >= 0:
		_inizio_strada = Vector2i(-1, -1)
		rete.nascondi_anteprima()
		segni.inizio_strada = _inizio_strada
		segni.queue_redraw()
	else:
		_esci_modalita()


func _clic(c: Vector2i) -> void:
	match modalita:
		"costruisci":
			if villaggio.costruisci(tipo_scelto, c) != null:
				Suono.suona("posa")
				segni.aggiorna()
				_aggiorna_fantasma()
				if not Input.is_key_pressed(KEY_SHIFT):
					_esci_modalita()
		"strada":
			_clic_strada(c)
		"bandierina":
			var perche := rete.motivo_no_bandiera(c)
			if perche != "":
				_mostra_avviso(perche, true)
			elif rete.aggiungi_bandiera(c):
				_mostra_avviso("Bandierina piantata", false)
		"attacca":
			var n := villaggio.nemico_in(c)
			if n == null:
				_mostra_avviso("Clicca una torre nemica", true)
			elif is_instance_valid(_attaccante) and guerra.attacca(_attaccante, n) > 0:
				_esci_modalita()
		"demolisci":
			var e := villaggio.edificio_in(c)
			if e:
				_evidenziato = null
				villaggio.demolisci(e)
				segni.aggiorna()
			elif rete.bandiera_in(c):
				var esito := rete.rimuovi_bandiera(c)
				_mostra_avviso(esito, esito.begins_with("È"))
			elif rete.rimuovi_strada_in(c):
				_mostra_avviso("Strada rimossa", false)
		"":
			# la schiera: clic sul condottiero per sceglierlo, poi ordini (muovi, attacca)
			if schiere.in_casella(c):
				Suono.suona("clic")
				schiere.scegli(true)
				return
			if schiere.scelta:
				_ordine_schiera(c)
				return
			# clic su un edificio: il suo pannello; su una bandierina: scorciatoia per iniziare una strada
			var e := villaggio.edificio_in(c)
			if e == null:
				e = villaggio.nemico_in(c)
			var ind := indigeni.villaggio_in(c)
			if e == null and ind >= 0:
				Suono.suona("clic")
				pannello.chiudi_pannello()
				pannello_indigeno.mostra(ind)
			elif e:
				Suono.suona("clic")
				pannello_indigeno.visible = false
				pannello.mostra(e)
			elif rete.bandiera_in(c):
				pannello.chiudi_pannello()
				menu.premi_attrezzo("strada")
				_clic_strada(c)
			else:
				pannello.chiudi_pannello()


## Ordine alla schiera scelta: una torre nemica o un villaggio indigeno da attaccare, altrimenti dove andare.
func _ordine_schiera(c: Vector2i) -> void:
	var n := villaggio.nemico_in(c)
	var ind := indigeni.villaggio_in(c)
	var ok := false
	if n:
		ok = schiere.attacca(n)
	elif ind >= 0 and indigeni.elenco[ind]["stato"] != "nostro":
		ok = schiere.attacca(ind)
	else:
		ok = schiere.muovi(c)
	if ok:
		Suono.suona("clic")
	else:
		_mostra_avviso("La schiera non può arrivare lì", true)


func _clic_strada(c: Vector2i) -> void:
	if _inizio_strada.x < 0:
		var e := villaggio.edificio_in(c)
		if e:
			c = e.bandiera
		if not rete.bandiera_in(c):
			_mostra_avviso("Una strada parte sempre da una bandierina", true)
			return
		_inizio_strada = c
		segni.inizio_strada = c
		segni.queue_redraw()
		_casella_mouse = Vector2i(-99, -99)
		return
	var e2 := villaggio.edificio_in(c)
	if e2:
		c = e2.bandiera
	var p := rete.trova_percorso(_inizio_strada, c)
	if p.is_empty():
		_mostra_avviso("Qui la strada non può arrivare", true)
		return
	if rete.costruisci_strada(p):
		for c2 in p:
			_togli_decori(c2)
		# si continua dalla bandierina d'arrivo, come una penna che non si stacca dal foglio
		_inizio_strada = p[-1]
		segni.inizio_strada = _inizio_strada
		rete.nascondi_anteprima()
		segni.queue_redraw()
		if rete.collegata(p[-1]):
			_mostra_avviso("Strada costruita: arriva un portatore", false)
		else:
			_mostra_avviso("Strada costruita, ma non è collegata al magazzino", true)


func _aggiorna_anteprima_strada() -> void:
	if modalita != "strada" or _inizio_strada.x < 0:
		return
	var c := _casella_mouse
	var e := villaggio.edificio_in(c)
	if e:
		c = e.bandiera
	_percorso = rete.trova_percorso(_inizio_strada, c)
	rete.mostra_anteprima(_percorso, not _percorso.is_empty())


func _scegli_edificio(tipo: String) -> void:
	Suono.suona("clic")
	_esci_modalita(false)
	modalita = "costruisci"
	tipo_scelto = tipo
	segni.tipo_scelto = tipo
	segni.aggiorna()
	if _fantasma == null:
		_fantasma = Sprite2D.new()
		_fantasma.centered = false
		oggetti.add_child(_fantasma)
	_fantasma.texture = Sprites.texture(Popoli.sprite(tipo, Popoli.giocatore))
	_fantasma.offset = -Sprites.ancora(tipo)
	_fantasma.visible = true
	_casella_mouse = Vector2i(-99, -99)


func _strumento(nome: String, attivo: bool) -> void:
	if attivo:
		Suono.suona("clic")
		_esci_modalita(false)
		modalita = nome
		segni.mostra_bandiere = nome in ["strada", "bandierina", "demolisci"]
		segni.queue_redraw()
		Input.set_default_cursor_shape(Input.CURSOR_CROSS if nome == "demolisci" else Input.CURSOR_POINTING_HAND)
	elif modalita == nome:
		_esci_modalita()


func _esci_modalita(deseleziona := true) -> void:
	modalita = ""
	tipo_scelto = ""
	segni.tipo_scelto = ""
	segni.mostra_bandiere = false
	_inizio_strada = Vector2i(-1, -1)
	segni.inizio_strada = _inizio_strada
	segni.aggiorna()
	rete.nascondi_anteprima()
	if _fantasma:
		_fantasma.visible = false
	segni.anteprima_confine = []
	if _evidenziato:
		_evidenziato.evidenzia(Color.WHITE)
		_evidenziato = null
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	if deseleziona and menu:
		menu.deseleziona()


func _aggiorna_fantasma() -> void:
	if modalita != "costruisci" or _fantasma == null:
		return
	var taglia: int = CatalogoEdifici.dati(tipo_scelto)["taglia"]
	var c := _casella_mouse
	_fantasma.position = dati.a_schermo(c.x + taglia * 0.5, c.y + taglia * 0.5)
	var ok := villaggio.puo_costruire(tipo_scelto, c)
	_fantasma.modulate = Color(0.75, 1.0, 0.75, 0.8) if ok else Color(1.0, 0.45, 0.4, 0.6)
	var info := CatalogoEdifici.dati(tipo_scelto)
	segni.anteprima_confine = [Vector2(c.x + taglia * 0.5, c.y + taglia * 0.5), float(info["territorio"])] if info.has("territorio") else []
	segni.queue_redraw()


func _aggiorna_evidenziato() -> void:
	if modalita != "demolisci":
		return
	var e := villaggio.edificio_in(_casella_mouse)
	if e == _evidenziato:
		return
	if _evidenziato and is_instance_valid(_evidenziato):
		_evidenziato.evidenzia(Color.WHITE)
	_evidenziato = e
	if e:
		e.evidenzia(Color(1.0, 0.5, 0.45))


# --------------------------------------------------------------- villaggio iniziale

const INIZIALI := [
	["magazzino", Vector2i(0, 0)],
	["casa_greca", Vector2i(4, -3)],
	["casa_greca", Vector2i(-3, 4)],
]


func _cella(rel: Vector2i) -> Vector2i:
	return dati.villaggio + rel


## Il villaggio iniziale: magazzino e due case collegate (nelle missioni, solo il magazzino).
func _metti_villaggio(solo_magazzino := false) -> void:
	var magazzino: Edificio = null
	for e in INIZIALI:
		if solo_magazzino and e[0] != "magazzino":
			continue
		var ed := villaggio.costruisci(e[0], _cella(e[1]), true)
		if e[0] == "magazzino":
			magazzino = ed
	for ed in villaggio.edifici.values():
		if ed != magazzino:
			var percorso := rete.trova_percorso(magazzino.bandiera, ed.bandiera)
			rete.costruisci_strada(percorso)
			for c2 in percorso:
				_togli_decori(c2)


# --------------------------------------------------------------- natura

func _metti_natura() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = SEME
	var oliveti := FastNoiseLite.new()
	oliveti.seed = SEME + 9
	oliveti.frequency = 0.08
	var latifoglie := FastNoiseLite.new()
	latifoglie.seed = SEME + 13
	latifoglie.frequency = 0.06
	for y in dati.altezza:
		for x in dati.larghezza:
			if Vector2(x - dati.villaggio.x - 1, y - dati.villaggio.y - 1).length() < 7.0:
				continue
			var t := dati.tipo(x, y)
			match t:
				T.BOSCO:
					# la Sila: pini laricio in alto, castagni e querce più in basso
					var quota := dati.quota(x + 0.5, y + 0.5)
					var albero := "pino_%d" % rng.randi_range(1, 4)
					if quota < 70.0 and latifoglie.get_noise_2d(x, y) > -0.1:
						albero = ("castagno_%d" if rng.randf() < 0.6 else "quercia_%d") % rng.randi_range(1, 4)
					_metti(albero, x, y, rng)
					if rng.randf() < 0.45:
						_metti("pino_%d" % rng.randi_range(1, 4) if quota >= 70.0 else "castagno_%d" % rng.randi_range(1, 4), x, y, rng)
					if rng.randf() < 0.18:
						_metti_decoro("funghi" if rng.randf() < 0.5 else "cespuglio_1", x, y, rng)
				T.PRATO:
					var o := oliveti.get_noise_2d(x, y)
					if o > 0.25 and rng.randf() < 0.5:
						_metti("ulivo_%d" % rng.randi_range(1, 3), x, y, rng)
					elif rng.randf() < 0.03:
						_metti(("quercia_%d" if rng.randf() < 0.5 else "castagno_%d") % rng.randi_range(1, 4), x, y, rng)
					elif rng.randf() < 0.07:
						_metti_decoro("cespuglio_%d" % rng.randi_range(1, 2), x, y, rng)
					elif rng.randf() < 0.07:
						_metti_decoro("fiori_%d" % rng.randi_range(1, 2), x, y, rng)
				T.SECCO:
					if rng.randf() < 0.08:
						_metti_decoro("cespuglio_%d" % rng.randi_range(1, 2), x, y, rng)
					elif rng.randf() < 0.03:
						_metti("rocce_%d" % rng.randi_range(1, 3), x, y, rng)
					elif rng.randf() < 0.07:
						_metti("ulivo_%d" % rng.randi_range(1, 3), x, y, rng)
				T.ROCCIA:
					if rng.randf() < 0.25:
						_metti("rocce_%d" % rng.randi_range(1, 3), x, y, rng)
					elif rng.randf() < 0.08:
						_metti("pino_%d" % rng.randi_range(1, 4), x, y, rng)
				T.SABBIA:
					if rng.randf() < 0.015:
						_metti("rocce_%d" % rng.randi_range(1, 3), x, y, rng)


func _togli_decori(c: Vector2i) -> void:
	for d in decori.get(c, []):
		d.queue_free()
	decori.erase(c)


## Decorazioni che non occupano la casella (si può costruire sopra: spariscono).
func _metti_decoro(nome: String, x: int, y: int, rng: RandomNumberGenerator) -> void:
	var s := Sprites.crea(nome)
	s.position = dati.a_schermo(x + rng.randf_range(0.2, 0.8), y + rng.randf_range(0.2, 0.8))
	oggetti.add_child(s)
	decori.get_or_add(Vector2i(x, y), []).append(s)


func _metti(nome: String, x: int, y: int, rng: RandomNumberGenerator) -> void:
	var px := x + rng.randf_range(0.2, 0.8)
	var py := y + rng.randf_range(0.2, 0.8)
	var s := Sprites.crea(nome)
	s.position = dati.a_schermo(px, py)
	oggetti.add_child(s)
	risorse.registra(nome, Vector2i(x, y), s)


## Il mare si sente di più quando la camera guarda la costa; il vento in alto, fra le rocce.
func _aggiorna_ambiente() -> void:
	var centro := dati.casella_da_schermo(camera.global_position)
	var acqua := 0
	var roccia := 0
	var prato := 0
	var tot := 0
	for dy in range(-10, 11, 2):
		for dx in range(-10, 11, 2):
			var t := dati.tipo(centro.x + dx, centro.y + dy)
			tot += 1
			if t == T.ACQUA:
				acqua += 1
			elif t == T.ROCCIA or t == T.NEVE:
				roccia += 1
			elif t == T.SECCO or t == T.PRATO:
				prato += 1
	var f_mare := minf(1.0, acqua / float(tot) * 3.0)
	var f_roccia := minf(1.0, roccia / float(tot) * 2.5)
	Suono.ambiente("mare", lerpf(-40.0, -4.0, sqrt(f_mare)))
	Suono.ambiente("vento", lerpf(-14.0, -5.0, f_roccia))
	Suono.ambiente("uccelli", lerpf(-5.0, -16.0, maxf(f_mare, f_roccia)))
	# le cicale cantano d'estate nei prati assolati, non sulla spiaggia né in montagna; d'inverno tira più vento
	var estate := 1.0 if stagioni.stagione() == Stagioni.ESTATE else (0.3 if stagioni.stagione() == Stagioni.PRIMAVERA else 0.0)
	Suono.ambiente("cicale", lerpf(-40.0, -9.0, clampf(prato / float(tot) * 1.5 - f_mare - f_roccia, 0.0, 1.0) * estate))
	if stagioni.inverno():
		Suono.ambiente("vento", lerpf(-8.0, -3.0, f_roccia))
		Suono.ambiente("uccelli", -22.0)


# --------------------------------------------------------------- missioni

## Missione sul mare: due torri già presidiate allargano i confini fino alla costa.
func _torri_verso_costa() -> void:
	for k in 2:
		var migliore := Vector2i(-1, -1)
		var dist := INF
		for y in dati.altezza:
			for x in dati.larghezza:
				var c := Vector2i(x, y)
				if not dati.nel_territorio(x, y) or not villaggio.puo_costruire("torre", c):
					continue
				var d := _distanza_mare(c)
				if d < dist:
					dist = d
					migliore = c
		if migliore.x >= 0:
			var torre := villaggio.costruisci("torre", migliore, true)
			if torre:
				_collega(torre.bandiera)


## Traccia una strada da una bandierina alla rete già collegata al magazzino (la più vicina possibile).
func _collega(f: Vector2i) -> void:
	var altre: Array = rete.bandiere.keys().filter(func(b): return b != f and rete.collegata(b))
	altre.sort_custom(func(a, b): return Vector2(a - f).length() < Vector2(b - f).length())
	for b in altre:
		var perc := rete.trova_percorso(b, f)
		if not perc.is_empty() and rete.costruisci_strada(perc):
			for c in perc:
				_togli_decori(c)
			return


func _distanza_mare(c: Vector2i) -> float:
	var migliore := 99.0
	for y in range(c.y - 16, c.y + 17, 2):
		for x in range(c.x - 16, c.x + 17, 2):
			if dati.dentro(x, y) and dati.tipo(x, y) == T.ACQUA:
				migliore = minf(migliore, Vector2(x - c.x, y - c.y).length())
	return migliore


func avvia_missione(id: String, indice: int) -> void:
	missione = Missione.new()
	add_child(missione)
	missione.prepara(self, id)
	missione.indice = indice
	pannello_missione = PannelloMissione.new()
	_strato_ui.add_child(pannello_missione)
	pannello_missione.prepara(missione)
	missione.compiuta.connect(func(): _mostra_avviso("Missione compiuta: %s" % missione.titolo(), false))


## I nomi dei luoghi scritti leggeri sulla mappa (Tropea, Pizzo, il Poro...): non quello del villaggio.
func _metti_nomi_luoghi() -> void:
	var nomi := Node2D.new()
	nomi.z_index = 40
	add_child(nomi)
	for nome in dati.luoghi:
		var c: Vector2i = dati.luoghi[nome]
		if c == dati.villaggio:
			continue
		var l := Label.new()
		l.text = nome
		l.add_theme_font_size_override("font_size", 30)
		l.add_theme_color_override("font_color", Color(Palette.PERGAMENA_CHIARA, 0.85))
		l.add_theme_color_override("font_outline_color", Color(Palette.INCHIOSTRO, 0.6))
		l.add_theme_constant_override("outline_size", 8)
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		nomi.add_child(l)
		l.position = dati.a_schermo(c.x + 0.5, c.y + 0.5) - l.get_combined_minimum_size() * 0.5 - Vector2(0, 40)


## Il popolo del salvataggio da caricare; la campagna è dei Greci; altrimenti quello scelto nel menu.
func _popolo_da_usare() -> String:
	if Salvataggio.da_caricare != "":
		return Salvataggio.popolo_di(Salvataggio.da_caricare)
	if Impostazioni.missione != "":
		var pm: String = Missione.MISSIONI[Impostazioni.missione].get("popolo", "greci")
		match pm:
			"scelto":
				pm = Missione.popolo_soglia()
			"libero":
				pm = Impostazioni.popolo
		return pm if Popoli.DATI.has(pm) else "greci"
	return Impostazioni.popolo if Popoli.DATI.has(Impostazioni.popolo) else "greci"


## La mappa del salvataggio da caricare, quella della missione o quella scelta nel menu.
func _mappa_da_usare() -> String:
	if Salvataggio.da_caricare != "":
		return Salvataggio.mappa_di(Salvataggio.da_caricare)
	if Impostazioni.missione != "":
		return Missione.MISSIONI[Impostazioni.missione].get("mappa", "costa_ionica")
	return Impostazioni.mappa if GeneratoreMappa.MAPPE.has(Impostazioni.mappa) else "costa_ionica"


# --------------------------------------------------------------- i Brettii

## Due avamposti dei Brettii, il popolo delle montagne, a una ventina di caselle dal villaggio.
func _metti_brettii() -> void:
	var centro := dati.villaggio
	var presi: Array[Vector2i] = []
	var versi := [Vector2(-1, -0.4), Vector2(-0.3, 1)]
	match mappa:
		"monteleone":
			versi = [Vector2(-0.4, 1), Vector2(1, 0.6)]
		"zancle":
			versi = [Vector2(-1, 0.3), Vector2(-0.5, 1)]
	for verso in versi:
		var migliore := Vector2i(-1, -1)
		var punteggio := -INF
		for y in dati.altezza:
			for x in dati.larghezza:
				var c := Vector2i(x, y)
				var d := Vector2(c - centro)
				if d.length() < 18.0 or d.length() > 24.0 or not _posto_libero(c, 2):
					continue
				var s: float = d.normalized().dot((verso as Vector2).normalized())
				for altro in presi:
					if Vector2(c - altro).length() < 12.0:
						s -= 10.0
				if s > punteggio:
					punteggio = s
					migliore = c
		if migliore.x >= 0:
			presi.append(migliore)
			villaggio.metti_nemico(Popoli.torre_nemica(), migliore, 2, 4 if Impostazioni.modalita == "guerra" else 3)


func _posto_libero(c: Vector2i, taglia: int) -> bool:
	for y in range(c.y, c.y + taglia + 1):
		for x in range(c.x, c.x + taglia):
			if not dati.dentro(x, y) or dati.occupante(x, y) != 0 or dati.proprietario(x, y) != 0:
				return false
			if dati.tipo(x, y) not in [T.PRATO, T.SECCO, T.TERRA, T.BOSCO]:
				return false
	return true


# --------------------------------------------------------------- stagioni

## Luce generale della mappa (le stagioni la scaldano o la raffreddano); non tocca l'interfaccia.
func _crea_luce() -> CanvasModulate:
	var l := CanvasModulate.new()
	add_child(l)
	return l


## Fiocchi di neve sullo schermo, accesi d'inverno.
func _crea_fiocchi() -> CPUParticles2D:
	var strato := CanvasLayer.new()
	strato.layer = 0
	add_child(strato)
	var f := CPUParticles2D.new()
	f.emitting = false
	f.amount = 500
	f.lifetime = 9.0
	f.preprocess = 9.0
	f.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	f.emission_rect_extents = Vector2(1100, 10)
	f.position = Vector2(960, -20)
	f.direction = Vector2(0.15, 1)
	f.spread = 12.0
	f.gravity = Vector2(0, 30)
	f.initial_velocity_min = 60.0
	f.initial_velocity_max = 120.0
	f.scale_amount_min = 2.0
	f.scale_amount_max = 4.5
	f.color = Color(1, 1, 1, 0.85)
	strato.add_child(f)
	return f


# --------------------------------------------------------------- interfaccia

var _strato_ui: CanvasLayer


func _crea_interfaccia() -> void:
	var strato := CanvasLayer.new()
	add_child(strato)
	_strato_ui = strato

	barra = BarraRisorse.new()
	strato.add_child(barra)
	barra.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP, Control.PRESET_MODE_MINSIZE, 12)
	barra.grow_horizontal = Control.GROW_DIRECTION_BOTH

	menu = MenuCostruzione.new()
	strato.add_child(menu)
	menu.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT, Control.PRESET_MODE_MINSIZE, 14)
	menu.grow_vertical = Control.GROW_DIRECTION_BEGIN
	menu.edificio_scelto.connect(_scegli_edificio)
	menu.strumento.connect(_strumento)

	pannello = PannelloEdificio.new()
	pannello.villaggio = villaggio
	strato.add_child(pannello)
	pannello.schiere = schiere
	pannello.forma_schiera.connect(func(e: Edificio):
		if schiere.forma(e):
			pannello.chiudi_pannello()
			schiere.scegli(true))
	pannello_schiera = PannelloSchiera.new()
	pannello_schiera.schiere = schiere
	strato.add_child(pannello_schiera)
	pannello_schiera.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM, Control.PRESET_MODE_MINSIZE, 50)
	pannello_schiera.grow_horizontal = Control.GROW_DIRECTION_BOTH
	pannello_schiera.grow_vertical = Control.GROW_DIRECTION_BEGIN
	pannello_indigeno = PannelloIndigeno.new()
	pannello_indigeno.indigeni = indigeni
	strato.add_child(pannello_indigeno)
	pannello_indigeno.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT, Control.PRESET_MODE_MINSIZE, 14)
	pannello_indigeno.offset_bottom = -46
	pannello_indigeno.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	pannello_indigeno.grow_vertical = Control.GROW_DIRECTION_BEGIN
	# in basso a destra, sopra la riga d'aiuto (il pannello del villaggio sta in alto a destra)
	pannello.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT, Control.PRESET_MODE_MINSIZE, 14)
	pannello.offset_bottom = -46
	pannello.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	pannello.grow_vertical = Control.GROW_DIRECTION_BEGIN
	pannello.strada_da.connect(func(e: Edificio):
		pannello.chiudi_pannello()
		menu.premi_attrezzo("strada")
		_clic_strada(e.bandiera))
	pannello.attacca.connect(func(e: Edificio):
		pannello.chiudi_pannello()
		_esci_modalita()
		modalita = "attacca"
		_attaccante = e
		Input.set_default_cursor_shape(Input.CURSOR_CROSS)
		_mostra_avviso("Clicca la torre nemica da attaccare (Esc per annullare)", false))
	pannello.demolisci.connect(func(e: Edificio):
		pannello.chiudi_pannello()
		villaggio.demolisci(e)
		segni.aggiorna())

	pannello_villaggio = PannelloVillaggio.new()
	pannello_villaggio.villaggio = villaggio
	pannello_villaggio.logistica = logistica
	pannello_villaggio.rete = rete
	pannello_villaggio.stagioni = stagioni
	pannello_villaggio.avversario = avversario
	pannello_villaggio.monumenti = monumenti
	pannello_villaggio.schiere = schiere
	strato.add_child(pannello_villaggio)
	pannello_villaggio.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT, Control.PRESET_MODE_MINSIZE, 70)
	pannello_villaggio.grow_horizontal = Control.GROW_DIRECTION_BEGIN

	var pulsante := Button.new()
	pulsante.text = "Villaggio (I)"
	pulsante.theme = TemaGioco.crea(17)
	pulsante.custom_minimum_size = Vector2(140, 40)
	pulsante.tooltip_text = "Popolazione, produzione e scorte"
	pulsante.pressed.connect(pannello_villaggio.alterna)
	strato.add_child(pulsante)
	pulsante.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT, Control.PRESET_MODE_MINSIZE, 14)
	pulsante.grow_horizontal = Control.GROW_DIRECTION_BEGIN

	var aiuto := Label.new()
	aiuto.text = "WASD: muovi  ·  Rotella: zoom  ·  Clic: info edificio  ·  Tasto destro: trascina / annulla  ·  R: strada  ·  F: bandierina  ·  I: villaggio  ·  M: musica  ·  F5 salva  ·  F9 carica  ·  Esc: menu (salva)"
	aiuto.add_theme_font_size_override("font_size", 16)
	aiuto.add_theme_color_override("font_color", Palette.PERGAMENA_CHIARA)
	aiuto.add_theme_color_override("font_outline_color", Palette.INCHIOSTRO)
	aiuto.add_theme_constant_override("outline_size", 6)
	strato.add_child(aiuto)
	aiuto.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT, Control.PRESET_MODE_MINSIZE, 12)
	aiuto.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	aiuto.grow_vertical = Control.GROW_DIRECTION_BEGIN

	_avviso = Label.new()
	_avviso.add_theme_font_size_override("font_size", 24)
	_avviso.add_theme_color_override("font_outline_color", Palette.INCHIOSTRO)
	_avviso.add_theme_constant_override("outline_size", 8)
	_avviso.modulate.a = 0.0
	strato.add_child(_avviso)
	_avviso.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP, Control.PRESET_MODE_MINSIZE, 92)
	_avviso.grow_horizontal = Control.GROW_DIRECTION_BOTH


func _mostra_avviso(testo: String, errore: bool) -> void:
	if errore:
		Suono.suona("errore", -4.0)
	_avviso.text = testo
	_avviso.add_theme_color_override("font_color", Color("ff9a8a") if errore else Palette.PERGAMENA_CHIARA)
	if _tween_avviso:
		_tween_avviso.kill()
	_avviso.modulate.a = 1.0
	_tween_avviso = create_tween()
	_tween_avviso.tween_interval(1.8)
	_tween_avviso.tween_property(_avviso, "modulate:a", 0.0, 0.6)
