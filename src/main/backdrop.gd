extends Control
## Paesaggio della schermata iniziale, disegnato interamente in codice:
## cielo all'alba, sole, nuvole, montagne su due piani, mare luccicante,
## una costa con ulivi a sinistra e un capo con due colonne a destra.

const NUM_NUVOLE := 7
const NUM_ULIVI := 9
const NUM_RIFLESSI := 70
const POS_SOLE := 0.84  # posizione orizzontale del sole (0..1)

var _tempo := 0.0
var _nuvole: Array[Vector3] = []   # x (0..1), y (0..1), scala
var _riflessi: Array[Vector3] = [] # x (0..1), y (0..1 nel mare), fase
var _ulivi: Array[Vector2] = []    # x (0..1 sulla costa), scala


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var rng := RandomNumberGenerator.new()
	rng.seed = 1987
	for i in NUM_NUVOLE:
		_nuvole.append(Vector3(rng.randf(), rng.randf_range(0.06, 0.32), rng.randf_range(0.6, 1.4)))
	for i in NUM_RIFLESSI:
		_riflessi.append(Vector3(rng.randf(), rng.randf(), rng.randf() * TAU))
	for i in NUM_ULIVI:
		_ulivi.append(Vector2(rng.randf_range(0.02, 0.9), rng.randf_range(0.7, 1.2)))


func _process(delta: float) -> void:
	_tempo += delta
	queue_redraw()


func _draw() -> void:
	var s := size
	var orizzonte := s.y * 0.6
	_disegna_cielo(s, orizzonte)
	_disegna_sole(s, orizzonte)
	_disegna_nuvole(s)
	_disegna_catena(s, orizzonte, s.y * 0.24, Palette.MONTI_LONTANI, 3.0, 0.0)
	_disegna_catena(s, orizzonte, s.y * 0.15, Palette.BOSCO_SILA, 7.0, 1.9)
	_disegna_mare(s, orizzonte)
	_disegna_costa_sinistra(s, orizzonte)
	_disegna_capo_destro(s, orizzonte)


func _disegna_cielo(s: Vector2, orizzonte: float) -> void:
	var meta := orizzonte * 0.55
	draw_polygon(
		PackedVector2Array([Vector2.ZERO, Vector2(s.x, 0), Vector2(s.x, meta), Vector2(0, meta)]),
		PackedColorArray([Palette.CIELO_ALTO, Palette.CIELO_ALTO, Palette.CIELO_ALBA, Palette.CIELO_ALBA]))
	draw_polygon(
		PackedVector2Array([Vector2(0, meta), Vector2(s.x, meta), Vector2(s.x, orizzonte), Vector2(0, orizzonte)]),
		PackedColorArray([Palette.CIELO_ALBA, Palette.CIELO_ALBA, Palette.CIELO_ORIZZONTE, Palette.CIELO_ORIZZONTE]))


func _disegna_sole(s: Vector2, orizzonte: float) -> void:
	var centro := Vector2(s.x * POS_SOLE, orizzonte - s.y * 0.29)
	var raggio := s.y * 0.055
	var respiro := 1.0 + sin(_tempo * 0.8) * 0.03
	for i in range(7, 0, -1):
		draw_circle(centro, (raggio + i * s.y * 0.02) * respiro, Color(Palette.SOLE, 0.05))
	draw_circle(centro, raggio, Palette.SOLE)


func _disegna_nuvole(s: Vector2) -> void:
	for n in _nuvole:
		var x := fposmod(n.x + _tempo * 0.004 * n.z, 1.2) - 0.1
		var c := Vector2(x * s.x, n.y * s.y * 0.6)
		var r := s.y * 0.025 * n.z
		var colore := Color(Palette.PERGAMENA_CHIARA, 0.55)
		draw_circle(c, r, colore)
		draw_circle(c + Vector2(r * 1.1, r * 0.2), r * 0.8, colore)
		draw_circle(c + Vector2(-r * 1.0, r * 0.25), r * 0.7, colore)
		draw_circle(c + Vector2(r * 0.3, -r * 0.5), r * 0.75, colore)


## Profilo di montagne generato da una somma di onde: stesso disegno a ogni avvio.
func _disegna_catena(s: Vector2, base: float, altezza: float, colore: Color, seme: float, spostamento: float) -> void:
	var punti := PackedVector2Array()
	var passi := 64
	for i in passi + 1:
		var t := float(i) / passi
		var h := 0.55 + 0.25 * sin(t * 5.0 + seme) + 0.15 * sin(t * 13.0 + seme * 2.0 + spostamento) + 0.08 * sin(t * 29.0 + seme)
		punti.append(Vector2(t * s.x, base - h * altezza))
	punti.append(Vector2(s.x, base + 2.0))
	punti.append(Vector2(0, base + 2.0))
	draw_colored_polygon(punti, colore)


func _disegna_mare(s: Vector2, orizzonte: float) -> void:
	var fondo := s.y
	draw_polygon(
		PackedVector2Array([Vector2(0, orizzonte), Vector2(s.x, orizzonte), Vector2(s.x, fondo), Vector2(0, fondo)]),
		PackedColorArray([Palette.MARE_TIRRENO, Palette.MARE_TIRRENO, Palette.MARE_IONIO, Palette.MARE_IONIO]))
	# Scia di luce del sole sull'acqua
	var colonna_sole := s.x * POS_SOLE
	for r in _riflessi:
		var y := orizzonte + pow(r.y, 1.6) * (fondo - orizzonte)
		var vicinanza := 1.0 - clampf(absf(r.x - 0.5) * 2.0, 0.0, 1.0)
		var larghezza := (8.0 + 60.0 * r.y) * (0.4 + vicinanza)
		var x := colonna_sole + (r.x - 0.5) * (80.0 + 500.0 * r.y)
		var alfa := (0.25 + 0.35 * sin(_tempo * 1.6 + r.z)) * (0.3 + vicinanza)
		draw_line(Vector2(x - larghezza * 0.5, y), Vector2(x + larghezza * 0.5, y), Color(Palette.SCHIUMA, clampf(alfa, 0.0, 1.0)), 3.0)


func _disegna_costa_sinistra(s: Vector2, orizzonte: float) -> void:
	var punti := PackedVector2Array([
		Vector2(0, orizzonte + s.y * 0.06),
		Vector2(s.x * 0.10, orizzonte + s.y * 0.10),
		Vector2(s.x * 0.20, orizzonte + s.y * 0.17),
		Vector2(s.x * 0.27, orizzonte + s.y * 0.28),
		Vector2(s.x * 0.30, s.y),
		Vector2(0, s.y),
	])
	draw_colored_polygon(punti, Palette.ARGILLA)
	var erba := PackedVector2Array([
		Vector2(0, orizzonte + s.y * 0.05),
		Vector2(s.x * 0.10, orizzonte + s.y * 0.09),
		Vector2(s.x * 0.19, orizzonte + s.y * 0.16),
		Vector2(s.x * 0.235, orizzonte + s.y * 0.24),
		Vector2(s.x * 0.20, s.y),
		Vector2(0, s.y),
	])
	draw_colored_polygon(erba, Palette.VERDE_ULIVO)
	# Ulivi: tronco scuro e chioma argentata che ondeggia appena
	for u in _ulivi:
		var x := u.x * s.x * 0.2
		var y := orizzonte + s.y * (0.07 + u.x * 0.2) + s.y * 0.03
		var r := s.y * 0.018 * u.y
		var vento := sin(_tempo * 1.2 + u.x * 10.0) * r * 0.08
		draw_line(Vector2(x, y), Vector2(x + vento, y - r * 1.6), Palette.INCHIOSTRO, maxf(2.0, r * 0.25))
		draw_circle(Vector2(x + vento, y - r * 2.0), r, Palette.BOSCO_SILA)
		draw_circle(Vector2(x + vento + r * 0.6, y - r * 1.7), r * 0.75, Color("7d9a5c"))


func _disegna_capo_destro(s: Vector2, orizzonte: float) -> void:
	var punti := PackedVector2Array([
		Vector2(s.x, orizzonte + s.y * 0.08),
		Vector2(s.x * 0.86, orizzonte + s.y * 0.10),
		Vector2(s.x * 0.80, orizzonte + s.y * 0.14),
		Vector2(s.x * 0.84, orizzonte + s.y * 0.18),
		Vector2(s.x, orizzonte + s.y * 0.20),
	])
	draw_colored_polygon(punti, Palette.ARGILLA)
	# Due colonne antiche sul capo
	var base_y := orizzonte + s.y * 0.105
	for i in 2:
		var x := s.x * (0.885 + i * 0.03)
		var alt := s.y * (0.11 if i == 0 else 0.08)
		var larg := s.y * 0.012
		draw_rect(Rect2(x - larg * 0.5, base_y - alt, larg, alt), Palette.CALCE)
		draw_rect(Rect2(x - larg * 0.8, base_y - alt - larg * 0.5, larg * 1.6, larg * 0.5), Palette.CALCE)
		draw_rect(Rect2(x + larg * 0.15, base_y - alt, larg * 0.2, alt), Color(Palette.ARGILLA, 0.6))
