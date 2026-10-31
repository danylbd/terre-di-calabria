extends Node2D
## Scena della partita: mappa, natura, villaggio, costruzione di edifici dentro i confini.

const T := DatiMappa.Terreno
const SEME := 1987

var dati: DatiMappa
var terreno: Terreno
var segni: SegniMappa
var oggetti: Node2D
var camera: CameraMappa
var villaggio: Villaggio

var menu: MenuCostruzione
var barra: BarraRisorse
var _avviso: Label
var _tween_avviso: Tween

var modalita := ""          # "", "costruisci", "demolisci"
var tipo_scelto := ""
var _fantasma: Sprite2D
var _casella_mouse := Vector2i(-1, -1)
var _evidenziato: Edificio


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("16384f"))
	dati = GeneratoreMappa.genera(SEME)
	_traccia_sentieri()

	terreno = Terreno.new()
	add_child(terreno)
	terreno.costruisci(dati)

	segni = SegniMappa.new()
	add_child(segni)

	oggetti = Node2D.new()
	oggetti.y_sort_enabled = true
	add_child(oggetti)

	villaggio = Villaggio.new(dati, oggetti)
	add_child(villaggio)
	segni.prepara(dati, villaggio)
	villaggio.territorio_cambiato.connect(segni.aggiorna)
	villaggio.messaggio.connect(_mostra_avviso)

	_metti_natura()
	_metti_villaggio()

	camera = CameraMappa.new()
	camera.area = terreno.limiti()
	camera.position = dati.a_schermo(dati.villaggio.x + 0.5, dati.villaggio.y + 0.5)
	add_child(camera)
	camera.make_current()

	_crea_interfaccia()
	villaggio.scorte_cambiate.connect(func(): barra.aggiorna(villaggio.scorte))
	barra.aggiorna(villaggio.scorte)


# --------------------------------------------------------------- comandi

func _process(_delta: float) -> void:
	var c := dati.casella_da_schermo(get_global_mouse_position())
	if c == _casella_mouse:
		return
	_casella_mouse = c
	_aggiorna_fantasma()
	_aggiorna_evidenziato()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if modalita != "":
			_esci_modalita()
		else:
			get_tree().change_scene_to_file("res://src/main/title_screen.tscn")
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.pressed:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			_clic(dati.casella_da_schermo(get_global_mouse_position()))
		elif mb.button_index == MOUSE_BUTTON_RIGHT and modalita != "":
			_esci_modalita()


func _clic(c: Vector2i) -> void:
	match modalita:
		"costruisci":
			if villaggio.costruisci(tipo_scelto, c) != null:
				segni.aggiorna()
				_aggiorna_fantasma()
				if not Input.is_key_pressed(KEY_SHIFT):
					_esci_modalita()
		"demolisci":
			var e := villaggio.edificio_in(c)
			if e:
				_evidenziato = null
				villaggio.demolisci(e)
				segni.aggiorna()


func _scegli_edificio(tipo: String) -> void:
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


func _modalita_demolizione(attiva: bool) -> void:
	if attiva:
		_esci_modalita(false)
		modalita = "demolisci"
		Input.set_default_cursor_shape(Input.CURSOR_CROSS)
	elif modalita == "demolisci":
		_esci_modalita()


func _esci_modalita(deseleziona := true) -> void:
	modalita = ""
	tipo_scelto = ""
	segni.tipo_scelto = ""
	segni.aggiorna()
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


func _traccia_sentieri() -> void:
	# sentieri di terra battuta dal magazzino alle prime case (le strade vere arriveranno nello step 03)
	for e in INIZIALI.slice(1):
		var a := _cella(Vector2i(1, 2))
		var b := _cella(e[1]) + Vector2i(0, 1)
		var p := a
		while p != b:
			if p.x != b.x:
				p.x += signi(b.x - p.x)
			else:
				p.y += signi(b.y - p.y)
			if dati.dentro(p.x, p.y) and dati.tipo(p.x, p.y) != T.ACQUA:
				dati.imposta_tipo(p.x, p.y, T.TERRA)


func _metti_villaggio() -> void:
	for e in INIZIALI:
		villaggio.costruisci(e[0], _cella(e[1]), true)
	var giri := [
		["portatore_nessuno", Vector2i(4, -3)], ["portatore_anfora", Vector2i(-3, 4)],
		["portatore_asse", Vector2i(4, -3)],
	]
	var k := 0
	for g in giri:
		var a := Vector2(dati.villaggio.x + 1.5, dati.villaggio.y + 2.5)
		var meta: Vector2i = _cella(g[1]) + Vector2i(0, 1)
		var punti: Array[Vector2] = [a, Vector2(meta.x + 0.5, a.y), Vector2(meta.x + 0.5, meta.y + 0.5)]
		var c := Colono.new()
		oggetti.add_child(c)
		c.prepara(dati, punti, g[0], k * 0.37)
		c.velocita = 0.9 + (k % 3) * 0.15
		k += 1


# --------------------------------------------------------------- natura

func _metti_natura() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = SEME
	var oliveti := FastNoiseLite.new()
	oliveti.seed = SEME + 9
	oliveti.frequency = 0.08
	for y in dati.altezza:
		for x in dati.larghezza:
			if Vector2(x - dati.villaggio.x - 1, y - dati.villaggio.y - 1).length() < 6.5:
				continue
			var t := dati.tipo(x, y)
			match t:
				T.BOSCO:
					for k in (2 if rng.randf() < 0.55 else 1):
						_metti("pino_%d" % rng.randi_range(1, 4), x, y, rng)
					if rng.randf() < 0.08:
						_metti("cespuglio_1", x, y, rng)
				T.PRATO:
					var o := oliveti.get_noise_2d(x, y)
					if o > 0.25 and rng.randf() < 0.45:
						_metti("ulivo_%d" % rng.randi_range(1, 3), x, y, rng)
					elif rng.randf() < 0.035:
						_metti("cespuglio_%d" % rng.randi_range(1, 2), x, y, rng)
					elif rng.randf() < 0.012:
						_metti("pino_%d" % rng.randi_range(1, 4), x, y, rng)
				T.SECCO:
					if rng.randf() < 0.06:
						_metti("cespuglio_%d" % rng.randi_range(1, 2), x, y, rng)
					elif rng.randf() < 0.025:
						_metti("rocce_%d" % rng.randi_range(1, 3), x, y, rng)
					elif rng.randf() < 0.05:
						_metti("ulivo_%d" % rng.randi_range(1, 3), x, y, rng)
				T.ROCCIA:
					if rng.randf() < 0.22:
						_metti("rocce_%d" % rng.randi_range(1, 3), x, y, rng)
					elif rng.randf() < 0.07:
						_metti("pino_%d" % rng.randi_range(1, 4), x, y, rng)
				T.SABBIA:
					if rng.randf() < 0.015:
						_metti("rocce_%d" % rng.randi_range(1, 3), x, y, rng)


func _metti(nome: String, x: int, y: int, rng: RandomNumberGenerator) -> void:
	var px := x + rng.randf_range(0.2, 0.8)
	var py := y + rng.randf_range(0.2, 0.8)
	var s := Sprites.crea(nome)
	s.position = dati.a_schermo(px, py)
	oggetti.add_child(s)
	if not nome.begins_with("cespuglio"):
		dati.occupa(x, y, DatiMappa.NATURA)
		var c := Vector2i(x, y)
		if not villaggio.natura.has(c):
			villaggio.natura[c] = []
		villaggio.natura[c].append(s)


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
	menu.demolizione.connect(_modalita_demolizione)

	var aiuto := Label.new()
	aiuto.text = "WASD / frecce: muovi  ·  Rotella: zoom  ·  Tasto destro: trascina / annulla  ·  Maiusc+clic: costruisci più volte  ·  Esc: menu"
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
