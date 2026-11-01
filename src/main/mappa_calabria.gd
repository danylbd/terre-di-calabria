extends Control
## Mappa della campagna: la Calabria con la sua forma vera tra il Tirreno e lo Ionio (la costa viene
## dalle coordinate geografiche reali), montagne, fiumi, città, i luoghi dei cinque frammenti del Sigillo
## e le missioni dei Greci da scegliere. Disegnata in codice su un foglio di 1920×1080, adattato alla finestra.
## Conversione usata: x = 700 + (longitudine − 15,6) × 360,  y = 30 + (40,15 − latitudine) × 455.

const LARGHEZZA := 1920.0
const ALTEZZA := 1080.0

## costa della Calabria (senso orario dal confine con la Basilicata sul Tirreno): Praia, Scalea, Paola,
## Amantea, golfo di Sant'Eufemia, Pizzo, Vibo Marina, Tropea, Capo Vaticano, Gioia Tauro, Scilla,
## Reggio, Capo Spartivento, Locri, golfo di Squillace, Capo Rizzuto, Capo Colonna, Crotone,
## Punta Alice, piana di Sibari, Rocca Imperiale
const COSTA := [
	Vector2(736, -16), Vector2(754, 107), Vector2(768, 185), Vector2(779, 244), Vector2(794, 271), Vector2(830, 339),
	Vector2(855, 389), Vector2(873, 494), Vector2(891, 535), Vector2(916, 567), Vector2(923, 599), Vector2(916, 644),
	Vector2(902, 676), Vector2(887, 685), Vector2(855, 681), Vector2(826, 694), Vector2(808, 699), Vector2(783, 726),
	Vector2(797, 744), Vector2(822, 758), Vector2(815, 790), Vector2(808, 813), Vector2(790, 844), Vector2(772, 876),
	Vector2(740, 894), Vector2(714, 908), Vector2(718, 958), Vector2(722, 999), Vector2(729, 1031), Vector2(754, 1045),
	Vector2(808, 1049), Vector2(866, 1045), Vector2(880, 1026), Vector2(898, 967), Vector2(938, 899), Vector2(952, 885),
	Vector2(988, 863), Vector2(1017, 835), Vector2(1049, 803), Vector2(1046, 744), Vector2(1042, 694), Vector2(1053, 653),
	Vector2(1067, 635), Vector2(1132, 599), Vector2(1179, 594), Vector2(1215, 594), Vector2(1240, 599), Vector2(1265, 571),
	Vector2(1276, 540), Vector2(1251, 517), Vector2(1254, 462), Vector2(1247, 412), Vector2(1251, 385), Vector2(1262, 371),
	Vector2(1233, 339), Vector2(1186, 326), Vector2(1132, 298), Vector2(1078, 271), Vector2(1042, 258), Vector2(1017, 221),
	Vector2(1024, 180), Vector2(1035, 157), Vector2(1060, 94), Vector2(1067, 48), Vector2(1074, -16),
]
## la punta nord-orientale della Sicilia: Capo d'Orlando, Milazzo, Capo Peloro, Messina, Taormina, Catania
const SICILIA := [
	Vector2(340, 894), Vector2(394, 935), Vector2(484, 926), Vector2(570, 899), Vector2(628, 899), Vector2(682, 881),
	Vector2(718, 885), Vector2(689, 922), Vector2(664, 986), Vector2(628, 1031), Vector2(588, 1076), Vector2(556, 1145),
	Vector2(520, 1236), Vector2(340, 1281),
]
## montagne: [centro, raggi, colore, nome]
const MONTI := [
	[Vector2(916, 120), Vector2(120, 60), "monte", "Pollino"],
	[Vector2(1050, 420), Vector2(120, 105), "bosco", "Sila"],
	[Vector2(975, 755), Vector2(55, 80), "monte", "Serre"],
	[Vector2(820, 930), Vector2(70, 65), "monte", "Aspromonte"],
	[Vector2(840, 728), Vector2(30, 20), "bosco", "Monte Poro"],
]
const FIUMARE := [
	[Vector2(934, 430), Vector2(955, 330), Vector2(990, 260), Vector2(1017, 225)],
	[Vector2(1090, 420), Vector2(1170, 470), Vector2(1250, 505)],
	[Vector2(990, 600), Vector2(955, 600), Vector2(923, 603)],
	[Vector2(940, 770), Vector2(880, 790), Vector2(820, 795)],
	[Vector2(1000, 820), Vector2(1020, 838)],
]
const CITTA := [
	["Sibari", Vector2(1017, 221)], ["Cosenza", Vector2(934, 417)], ["Crotone", Vector2(1251, 517)],
	["Catanzaro", Vector2(1056, 599)], ["Monteleone", Vector2(880, 703)], ["Tropea", Vector2(808, 699)],
	["Locri", Vector2(938, 899)], ["Scilla", Vector2(740, 894)], ["Reggio", Vector2(718, 958)], ["Messina", Vector2(682, 922)],
]
## dove scrivere i nomi delle città vicine tra loro
const SCRITTE_SPOSTATE := {"Tropea": Vector2(-34, -10), "Monteleone": Vector2(48, -12), "Messina": Vector2(-30, 6),
	"Reggio": Vector2(30, 6), "Scilla": Vector2(28, -8)}
const FRAMMENTI := [
	["Frammento del Monte", Vector2(916, 100), ""],
	["Frammento del Bosco", Vector2(1050, 390), ""],
	["Frammento del Ferro", Vector2(975, 725), ""],
	["Frammento della Roccia", Vector2(820, 905), ""],
	["Frammento del Mare", Vector2(705, 865), "voce_del_mare"],
]
## dove si svolge ogni missione dei Greci
const LUOGHI := {
	"naufragio": Vector2(1305, 548), "pane_straniero": Vector2(1180, 455), "uliveto": Vector2(1185, 560),
	"citta_sorelle": Vector2(1080, 195), "ira_del_fiume": Vector2(1085, 700), "voce_del_mare": Vector2(665, 850),
}

var _segnaposti := {}                # id missione -> Button
var _monteleone: Button               # partita libera sulla mappa di Monteleone
const MONTELEONE := Vector2(880, 735)
var _fatte := []
var _carattere: Font


func _ready() -> void:
	theme = TemaGioco.crea(18)
	_carattere = get_theme_default_font()
	_fatte = Missione.completate()
	for k in Missione.CAMPAGNA_GRECI.size():
		var id: String = Missione.CAMPAGNA_GRECI[k]
		var b := Button.new()
		var aperta := Missione.sbloccata(id)
		b.text = "✔" if id in _fatte else str(k + 1)
		b.custom_minimum_size = Vector2(46, 46)
		b.disabled = not aperta
		b.tooltip_text = "%d. %s\n%s" % [k + 1, Missione.MISSIONI[id]["titolo"],
			"Compiuta" if id in _fatte else ("Clicca per giocare" if aperta else "Si apre finendo la missione prima")]
		b.add_theme_font_size_override("font_size", 22)
		b.pressed.connect(_gioca.bind(id))
		add_child(b)
		_segnaposti[id] = b
	_monteleone = Button.new()
	_monteleone.text = "Gioca a Monteleone"
	_monteleone.tooltip_text = "Partita libera nel Vibonese, senza limiti di tempo"
	_monteleone.add_theme_font_size_override("font_size", 16)
	_monteleone.pressed.connect(func():
		Impostazioni.missione = ""
		Impostazioni.mappa = "monteleone"
		get_tree().change_scene_to_file("res://src/mappa/partita.tscn"))
	add_child(_monteleone)
	var indietro := Button.new()
	indietro.text = "Indietro"
	indietro.custom_minimum_size = Vector2(220, 46)
	indietro.pressed.connect(func(): get_tree().change_scene_to_file("res://src/main/title_screen.tscn"))
	add_child(indietro)
	indietro.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT, Control.PRESET_MODE_MINSIZE, 24)
	indietro.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	indietro.grow_vertical = Control.GROW_DIRECTION_BEGIN
	resized.connect(_disponi)
	_disponi()
	Suono.scaletta(["mattino"] as Array[String])


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://src/main/title_screen.tscn")


func _gioca(id: String) -> void:
	Impostazioni.missione = id
	get_tree().change_scene_to_file("res://src/mappa/partita.tscn")


# ------------------------------------------------------------------ foglio → schermo

func _scala() -> float:
	return minf(size.x / LARGHEZZA, size.y / ALTEZZA)


func _origine() -> Vector2:
	return (size - Vector2(LARGHEZZA, ALTEZZA) * _scala()) * 0.5


func _p(v: Vector2) -> Vector2:
	return _origine() + v * _scala()


func _disponi() -> void:
	for id in _segnaposti:
		var b: Button = _segnaposti[id]
		b.position = _p(LUOGHI[id]) - b.custom_minimum_size * 0.5
	_monteleone.position = _p(MONTELEONE) - Vector2(_monteleone.get_combined_minimum_size().x * 0.5, 0)
	queue_redraw()


# ------------------------------------------------------------------ disegno

func _draw() -> void:
	var s := _scala()
	# i due mari: il Tirreno a ovest più scuro, lo Ionio a est più chiaro
	var fasce := 48
	for k in fasce:
		var f := float(k) / (fasce - 1)
		var x0 := size.x * float(k) / fasce
		var col := Palette.MARE_TIRRENO.lerp(Palette.MARE_IONIO, smoothstep(0.3, 0.7, f))
		draw_rect(Rect2(Vector2(x0, 0), Vector2(size.x / fasce + 1.0, size.y)), col)
	for k in 60:
		var y := float(k) * 18.0 + 10.0
		var x := fmod(k * 137.0, LARGHEZZA)
		draw_line(_p(Vector2(x, y)), _p(Vector2(x + 26, y)), Color(Palette.SCHIUMA, 0.25), 2.0 * s)
	# terre: un'ombra, la sabbia della costa, l'entroterra verde
	var costa := PackedVector2Array(COSTA.map(func(v): return _p(v)))
	var ombra := PackedVector2Array(COSTA.map(func(v): return _p(v + Vector2(10, 12))))
	draw_colored_polygon(ombra, Color(0, 0, 0, 0.25))
	draw_colored_polygon(costa, Palette.ARGILLA)
	var interno := PackedVector2Array(COSTA.map(func(v): return _p(v.lerp(Vector2(980, 560), 0.05))))
	draw_colored_polygon(interno, Palette.VERDE_ULIVO)
	draw_colored_polygon(PackedVector2Array(SICILIA.map(func(v): return _p(v))), Palette.ARGILLA.darkened(0.08))
	costa.append(costa[0])
	draw_polyline(costa, Palette.INCHIOSTRO, 3.0 * s, true)
	# montagne: macchie scure con piccole cime, la Sila coperta di boschi
	for m in MONTI:
		var centro: Vector2 = m[0]
		var raggi: Vector2 = m[1]
		var col: Color = Palette.BOSCO_SILA if m[2] == "bosco" else Color("8a6f52")
		_ellisse(centro, raggi, col.lerp(Palette.VERDE_ULIVO, 0.25))
		_ellisse(centro, raggi * 0.7, col)
		var rng := RandomNumberGenerator.new()
		rng.seed = int(centro.x)
		for k in 14:
			var p := centro + Vector2(rng.randf_range(-1, 1) * raggi.x * 0.75, rng.randf_range(-1, 1) * raggi.y * 0.6)
			if m[2] == "bosco":
				draw_circle(_p(p), 9.0 * s, Palette.BOSCO_SILA.darkened(0.3))
				draw_circle(_p(p + Vector2(-2, -3)), 6.0 * s, Palette.BOSCO_SILA.lightened(0.15))
			else:
				var cima := PackedVector2Array([_p(p + Vector2(-16, 10)), _p(p + Vector2(0, -16)), _p(p + Vector2(16, 10))])
				draw_colored_polygon(cima, Color("6a5240"))
				draw_colored_polygon(PackedVector2Array([_p(p + Vector2(-6, -6)), _p(p + Vector2(0, -16)), _p(p + Vector2(6, -6))]), Palette.CALCE)
		if raggi.x > 40.0:
			_scritta(m[3], centro + Vector2(0, raggi.y + 22), 22, Palette.INCHIOSTRO)
	# fiumare
	for f in FIUMARE:
		draw_polyline(PackedVector2Array(f.map(func(v): return _p(v))), Palette.MARE_IONIO.lightened(0.3), 3.0 * s, true)
	# città
	for c in CITTA:
		draw_circle(_p(c[1]), 7.0 * s, Palette.CALCE)
		draw_arc(_p(c[1]), 7.0 * s, 0, TAU, 16, Palette.INCHIOSTRO, 2.0 * s)
		var spostata: Vector2 = SCRITTE_SPOSTATE.get(c[0], Vector2(0, -16))
		_scritta(c[0], c[1] + spostata, 18 if c[0] != "Monteleone" else 20, Palette.TERRACOTTA_SCURA if c[0] == "Monteleone" else Palette.INCHIOSTRO)
	# la Soglia: l'istmo dove i due mari quasi si toccano
	draw_dashed_line(_p(Vector2(923, 603)), _p(Vector2(1067, 635)), Color(Palette.TERRACOTTA, 0.9), 3.0 * s, 10.0 * s)
	_scritta("la Soglia", Vector2(990, 640), 20, Palette.TERRACOTTA_SCURA)
	# i mari
	_scritta("Mar Tirreno", Vector2(480, 520), 40, Color(Palette.CALCE, 0.85))
	_scritta("Mar Ionio", Vector2(1440, 820), 40, Color(Palette.CALCE, 0.85))
	_scritta("Sicilia", Vector2(470, 1010), 26, Palette.INCHIOSTRO)
	_scritta("lo Stretto", Vector2(640, 960), 16, Color(Palette.CALCE, 0.9))
	# il cammino della campagna dei Greci
	var cammino := PackedVector2Array()
	for id in Missione.CAMPAGNA_GRECI:
		cammino.append(_p(LUOGHI[id]))
	for k in cammino.size() - 1:
		var aperta := Missione.sbloccata(Missione.CAMPAGNA_GRECI[k + 1])
		draw_dashed_line(cammino[k], cammino[k + 1], Color(Palette.OCRA if aperta else Palette.PERGAMENA, 0.9), 4.0 * s, 12.0 * s)
	# i cinque frammenti del Sigillo
	for f in FRAMMENTI:
		var trovato: bool = f[2] != "" and f[2] in _fatte
		var p := _p(f[1])
		var rombo := PackedVector2Array([p + Vector2(0, -14) * s, p + Vector2(11, 0) * s, p + Vector2(0, 14) * s, p + Vector2(-11, 0) * s])
		draw_colored_polygon(rombo, Color("4fb3d9") if trovato else Color(Palette.PERGAMENA, 0.5))
		rombo.append(rombo[0])
		draw_polyline(rombo, Palette.INCHIOSTRO, 2.0 * s)
		if trovato:
			draw_circle(p, 22.0 * s, Color(0.6, 0.9, 1.0, 0.25))
	# cartiglio del titolo
	var cart := Rect2(_p(Vector2(1260, 60)), Vector2(600, 190) * s)
	draw_rect(cart, Palette.PERGAMENA)
	draw_rect(cart, Palette.TERRACOTTA_SCURA, false, 3.0 * s)
	_scritta("La terra tra due mari", Vector2(1560, 115), 40, Palette.TERRACOTTA_SCURA)
	_scritta("Le Colonne dell'Alba — la campagna dei Greci", Vector2(1560, 160), 22, Palette.INCHIOSTRO)
	_scritta("Frammenti del Sigillo trovati: %d di 5" % (1 if "voce_del_mare" in _fatte else 0), Vector2(1560, 205), 22,
		Palette.INCHIOSTRO)


func _ellisse(centro: Vector2, raggi: Vector2, col: Color) -> void:
	var punti := PackedVector2Array()
	for k in 32:
		var a := k * TAU / 32
		punti.append(_p(centro + Vector2(cos(a) * raggi.x, sin(a) * raggi.y)))
	draw_colored_polygon(punti, col)


func _scritta(testo: String, centro: Vector2, dimensione: int, col: Color) -> void:
	var d := int(dimensione * _scala())
	var largo := _carattere.get_string_size(testo, HORIZONTAL_ALIGNMENT_LEFT, -1, d).x
	var p := _p(centro) - Vector2(largo * 0.5, -d * 0.35)
	draw_string_outline(_carattere, p, testo, HORIZONTAL_ALIGNMENT_LEFT, -1, d, maxi(2, d / 6), Color(Palette.PERGAMENA_CHIARA, 0.7))
	draw_string(_carattere, p, testo, HORIZONTAL_ALIGNMENT_LEFT, -1, d, col)
