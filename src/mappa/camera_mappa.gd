class_name CameraMappa
extends Camera2D
## Camera della partita: WASD/frecce, mouse ai bordi, trascinamento con tasto destro o centrale,
## rotella per lo zoom (verso il punto indicato dal mouse).

const VELOCITA := 1100.0
const MARGINE_BORDO := 10.0
const ZOOM_MIN := 0.45
const ZOOM_MAX := 1.6
const PASSO_ZOOM := 1.12

var area := Rect2()
var scorrimento_bordi := true
var _trascino := false
var _zoom_obiettivo := 1.0


func _ready() -> void:
	_zoom_obiettivo = zoom.x


func _process(delta: float) -> void:
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
