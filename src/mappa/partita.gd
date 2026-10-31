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

var menu: MenuCostruzione
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
var decori := {}            # Vector2i -> [Sprite2D] fiori, funghi, cespugli (spariscono sotto gli edifici)


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("16384f"))
	dati = GeneratoreMappa.genera(SEME)

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
	villaggio.risorse = risorse
	villaggio.logistica = logistica
	villaggio.territorio_cambiato.connect(segni.aggiorna)
	villaggio.messaggio.connect(_mostra_avviso)
	villaggio.togli_decori.connect(_togli_decori)

	_metti_natura()
	_metti_villaggio()

	camera = CameraMappa.new()
	camera.area = terreno.limiti()
	camera.position = dati.a_schermo(dati.villaggio.x + 0.5, dati.villaggio.y + 0.5)
	add_child(camera)
	camera.make_current()

	_crea_interfaccia()
	villaggio.scorte_cambiate.connect(func(): barra.aggiorna(villaggio.scorte))
	logistica.scorte_cambiate.connect(func(): barra.aggiorna(villaggio.scorte))
	barra.aggiorna(villaggio.scorte)


# --------------------------------------------------------------- comandi

func _process(_delta: float) -> void:
	var c := dati.casella_da_schermo(get_global_mouse_position())
	if c == _casella_mouse:
		return
	_casella_mouse = c
	_aggiorna_fantasma()
	_aggiorna_evidenziato()
	_aggiorna_anteprima_strada()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if modalita != "":
			_esci_modalita()
		else:
			get_tree().change_scene_to_file("res://src/main/title_screen.tscn")
		get_viewport().set_input_as_handled()
	elif event is InputEventKey and event.pressed and not event.echo:
		match (event as InputEventKey).keycode:
			KEY_R:
				menu.premi_attrezzo("strada")
			KEY_F:
				menu.premi_attrezzo("bandierina")
	elif event is InputEventMouseButton and event.pressed:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			_clic(dati.casella_da_schermo(get_global_mouse_position()))
		elif mb.button_index == MOUSE_BUTTON_RIGHT and modalita != "":
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
			# clic su un edificio o su una bandierina: scorciatoia per iniziare una strada
			var e := villaggio.edificio_in(c)
			if rete.bandiera_in(c) or e:
				menu.premi_attrezzo("strada")
				_clic_strada(e.bandiera if e else c)


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
	_esci_modalita(false)
	modalita = "costruisci"
	tipo_scelto = tipo
	segni.tipo_scelto = tipo
	segni.aggiorna()
	if _fantasma == null:
		_fantasma = Sprite2D.new()
		_fantasma.centered = false
		oggetti.add_child(_fantasma)
	_fantasma.texture = Sprites.texture(tipo)
	_fantasma.offset = -Sprites.ancora(tipo)
	_fantasma.visible = true
	_casella_mouse = Vector2i(-99, -99)


func _strumento(nome: String, attivo: bool) -> void:
	if attivo:
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


func _metti_villaggio() -> void:
	var magazzino: Edificio = null
	for e in INIZIALI:
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


# --------------------------------------------------------------- interfaccia

func _crea_interfaccia() -> void:
	var strato := CanvasLayer.new()
	add_child(strato)

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

	var aiuto := Label.new()
	aiuto.text = "WASD: muovi  ·  Rotella: zoom  ·  Tasto destro: trascina / annulla  ·  R: strada  ·  F: bandierina  ·  Maiusc+clic: più edifici  ·  Esc: menu"
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
	_avviso.text = testo
	_avviso.add_theme_color_override("font_color", Color("ff9a8a") if errore else Palette.PERGAMENA_CHIARA)
	if _tween_avviso:
		_tween_avviso.kill()
	_avviso.modulate.a = 1.0
	_tween_avviso = create_tween()
	_tween_avviso.tween_interval(1.8)
	_tween_avviso.tween_property(_avviso, "modulate:a", 0.0, 0.6)
