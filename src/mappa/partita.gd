extends Node2D
## Scena della partita (step 01): mappa, natura, villaggio iniziale e coloni che camminano.

const T := DatiMappa.Terreno
const SEME := 1987

var dati: DatiMappa
var terreno: Terreno
var oggetti: Node2D
var camera: CameraMappa


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("16384f"))
	dati = GeneratoreMappa.genera(SEME)
	_traccia_sentieri()

	terreno = Terreno.new()
	add_child(terreno)
	terreno.costruisci(dati)

	oggetti = Node2D.new()
	oggetti.y_sort_enabled = true
	add_child(oggetti)
	_metti_natura()
	_metti_villaggio()

	camera = CameraMappa.new()
	camera.area = terreno.limiti()
	camera.position = dati.a_schermo(dati.villaggio.x + 0.5, dati.villaggio.y + 0.5)
	add_child(camera)
	camera.make_current()

	_crea_interfaccia()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://src/main/title_screen.tscn")


# --------------------------------------------------------------- villaggio

const EDIFICI := [
	["magazzino", Vector2i(0, 0)],
	["casa_greca", Vector2i(4, -3)],
	["casa_greca", Vector2i(-3, 4)],
	["casa_greca", Vector2i(3, 4)],
	["boscaiolo", Vector2i(-6, -1)],
	["segheria", Vector2i(-3, -5)],
	["frantoio", Vector2i(6, 1)],
]


func _cella(rel: Vector2i) -> Vector2i:
	return dati.villaggio + rel


func _traccia_sentieri() -> void:
	# sentieri di terra battuta dal magazzino a ogni edificio (le strade vere arriveranno nello step 03)
	for e in EDIFICI.slice(1):
		var a := _cella(Vector2i(1, 1))
		var b := _cella(e[1]) + Vector2i(1, 1)
		var p := a
		while p != b:
			if p.x != b.x:
				p.x += signi(b.x - p.x)
			else:
				p.y += signi(b.y - p.y)
			if dati.dentro(p.x, p.y) and dati.tipo(p.x, p.y) != T.ACQUA:
				dati.imposta_tipo(p.x, p.y, T.TERRA)


func _metti_villaggio() -> void:
	for e in EDIFICI:
		var c := _cella(e[1])
		var centro := Vector2(c.x + 0.5, c.y + 0.5)
		if e[0] == "magazzino":
			centro = Vector2(c.x + 1.0, c.y + 1.0)
		var s := Sprites.crea(e[0])
		s.position = dati.a_schermo(centro.x, centro.y)
		oggetti.add_child(s)

	var giri := [
		["portatore_tronco", Vector2i(-6, -1)], ["portatore_asse", Vector2i(-3, -5)],
		["portatore_anfora", Vector2i(6, 1)], ["portatore_nessuno", Vector2i(4, -3)],
		["portatore_tronco", Vector2i(-6, -1)], ["portatore_asse", Vector2i(-3, -5)],
		["portatore_nessuno", Vector2i(3, 4)], ["portatore_anfora", Vector2i(-3, 4)],
	]
	var k := 0
	for g in giri:
		var a := Vector2(dati.villaggio.x + 1.5, dati.villaggio.y + 1.5)
		var meta := _cella(g[1]) + Vector2i(1, 1)
		var punti: Array[Vector2] = [a]
		if meta.x != dati.villaggio.x + 1:
			punti.append(Vector2(meta.x + 0.5, a.y))
		punti.append(Vector2(meta.x + 0.5, meta.y + 0.5))
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
			if Vector2(x - dati.villaggio.x, y - dati.villaggio.y).length() < 7.5:
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


# --------------------------------------------------------------- interfaccia

func _crea_interfaccia() -> void:
	var strato := CanvasLayer.new()
	add_child(strato)
	var aiuto := Label.new()
	aiuto.text = "WASD / frecce / mouse ai bordi: muovi   ·   Rotella o +/-: zoom   ·   Tasto destro: trascina   ·   Esc: menu"
	aiuto.add_theme_font_size_override("font_size", 18)
	aiuto.add_theme_color_override("font_color", Palette.PERGAMENA_CHIARA)
	aiuto.add_theme_color_override("font_outline_color", Palette.INCHIOSTRO)
	aiuto.add_theme_constant_override("outline_size", 6)
	aiuto.position = Vector2(16, 12)
	strato.add_child(aiuto)
