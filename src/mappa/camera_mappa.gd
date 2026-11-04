class_name CameraMappa
extends Camera2D
## Camera della partita: WASD/frecce, mouse ai bordi, trascinamento con tasto destro o centrale,
## rotella per lo zoom (verso il punto indicato dal mouse). Sugli schermi touch: un dito trascina la
## mappa, due dita pizzicano per lo zoom, un tocco lungo fermo vale come il tasto destro (annulla).

signal tocco_lungo

const VELOCITA := 1100.0
const MARGINE_BORDO := 10.0
const ZOOM_MIN := 0.45
const ZOOM_MAX := 1.6
const PASSO_ZOOM := 1.12

var area := Rect2()
var scorrimento_bordi := true
var _trascino := false
var _zoom_obiettivo := 1.0

const SOGLIA_TRASCINO := 14.0      # pixel: sotto questa distanza un tocco è un clic
const TEMPO_TOCCO_LUNGO := 0.6
var _tocchi := {}                  # dito -> posizione sullo schermo
var _inizio_tocco := Vector2.ZERO
var _tempo_tocco := 0.0
var tocco_mosso := false           # il dito si è spostato (o ci sono due dita): non è un clic
var tocco_lungo_fatto := false     # il tocco è diventato un tocco lungo: non è un clic


func _ready() -> void:
	_zoom_obiettivo = zoom.x


func regola_zoom(valore: float) -> void:
	_zoom_obiettivo = clampf(valore, ZOOM_MIN, ZOOM_MAX)


func _process(delta: float) -> void:
	if _tocchi.size() == 1 and not tocco_mosso and not tocco_lungo_fatto:
		_tempo_tocco += delta
		if _tempo_tocco >= TEMPO_TOCCO_LUNGO:
			tocco_lungo_fatto = true
			tocco_lungo.emit()
	var dir := Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		dir.x -= 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		dir.x += 1
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		dir.y -= 1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		dir.y += 1
	if scorrimento_bordi and not _trascino and DisplayServer.window_is_focused():
		var m := get_viewport().get_mouse_position()
		var vs := get_viewport().get_visible_rect().size
		if m.x >= 0 and m.y >= 0 and m.x <= vs.x and m.y <= vs.y:
			if m.x < MARGINE_BORDO: dir.x -= 1
			if m.x > vs.x - MARGINE_BORDO: dir.x += 1
			if m.y < MARGINE_BORDO: dir.y -= 1
			if m.y > vs.y - MARGINE_BORDO: dir.y += 1
	if dir != Vector2.ZERO:
		position += dir.normalized() * VELOCITA * delta / zoom.x
	# zoom morbido
	if absf(zoom.x - _zoom_obiettivo) > 0.001:
		var prima := get_global_mouse_position()
		zoom = Vector2.ONE * lerpf(zoom.x, _zoom_obiettivo, minf(1.0, delta * 12.0))
		position += prima - get_global_mouse_position()
	_limita()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		_tocco(event)
		return
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_WHEEL_UP and mb.pressed:
			_zoom_obiettivo = clampf(_zoom_obiettivo * PASSO_ZOOM, ZOOM_MIN, ZOOM_MAX)
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN and mb.pressed:
			_zoom_obiettivo = clampf(_zoom_obiettivo / PASSO_ZOOM, ZOOM_MIN, ZOOM_MAX)
		elif mb.button_index in [MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_MIDDLE]:
			_trascino = mb.pressed
	elif event is InputEventMouseMotion and _trascino:
		position -= (event as InputEventMouseMotion).relative / zoom.x
	elif event is InputEventKey and event.pressed and not event.echo:
		match (event as InputEventKey).keycode:
			KEY_PLUS, KEY_KP_ADD, KEY_EQUAL:
				_zoom_obiettivo = clampf(_zoom_obiettivo * PASSO_ZOOM, ZOOM_MIN, ZOOM_MAX)
			KEY_MINUS, KEY_KP_SUBTRACT:
				_zoom_obiettivo = clampf(_zoom_obiettivo / PASSO_ZOOM, ZOOM_MIN, ZOOM_MAX)


func _limita() -> void:
	if area.size == Vector2.ZERO:
		return
	var meta_vista := get_viewport().get_visible_rect().size * 0.5 / zoom.x
	var minimo := area.position + meta_vista * 0.3
	var massimo := area.end - meta_vista * 0.3
	position = position.clamp(minimo, massimo)


## Le dita sullo schermo: trascinare, pizzicare, tocco lungo.
func _tocco(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var t := event as InputEventScreenTouch
		if t.pressed:
			_tocchi[t.index] = t.position
			if _tocchi.size() == 1:
				_inizio_tocco = t.position
				_tempo_tocco = 0.0
				tocco_mosso = false
				tocco_lungo_fatto = false
			else:
				tocco_mosso = true
		else:
			_tocchi.erase(t.index)
	elif event is InputEventScreenDrag:
		var d := event as InputEventScreenDrag
		if _tocchi.size() >= 2 and _tocchi.has(d.index):
			var altro: Vector2 = _tocchi[_tocchi.keys().filter(func(k): return k != d.index)[0]]
			var prima: float = (_tocchi[d.index] as Vector2).distance_to(altro)
			var dopo := d.position.distance_to(altro)
			if prima > 1.0:
				_zoom_obiettivo = clampf(_zoom_obiettivo * dopo / prima, ZOOM_MIN, ZOOM_MAX)
		elif _tocchi.size() == 1:
			if d.position.distance_to(_inizio_tocco) > SOGLIA_TRASCINO:
				tocco_mosso = true
			if tocco_mosso:
				position -= d.relative / zoom.x
		_tocchi[d.index] = d.position
