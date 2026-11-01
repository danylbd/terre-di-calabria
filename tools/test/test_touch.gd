extends SceneTree
## Test automatico dello step 24 (comandi touch): un dito trascina la mappa senza cliccare, un tocco
## breve vale come clic (si costruisce), due dita pizzicano per lo zoom, un tocco lungo annulla.
## Uso: godot --headless --path . --script tools/test/test_touch.gd

var p: Node2D
var errori := 0


func _initialize() -> void:
	Impostazioni.mappa = "costa_ionica"
	Impostazioni.modalita = "pace"
	Impostazioni.missione = ""
	Impostazioni.popolo = "greci"
	p = load("res://src/mappa/partita.tscn").instantiate()
	root.add_child(p)
	_prova.call_deferred()


func _prova() -> void:
	await process_frame
	var cam: CameraMappa = p.camera
	var v: Villaggio = p.villaggio
	cam.set_process(true)

	# un posto dove si può costruire un'abitazione, e la sua posizione sullo schermo
	var posto := Vector2i(-1, -1)
	for y in range(v.dati.villaggio.y - 6, v.dati.villaggio.y + 7):
		for x in range(v.dati.villaggio.x - 6, v.dati.villaggio.x + 7):
			if posto.x < 0 and v.puo_costruire("casa_greca", Vector2i(x, y)):
				posto = Vector2i(x, y)
	_controlla(posto.x >= 0, "c'è un posto libero per un'abitazione %s" % posto)
	var schermo: Vector2 = p.get_canvas_transform() * p.dati.a_schermo(posto.x + 0.5, posto.y + 0.5)
	var case_prima := _case(v)

	# trascinare con un dito: la mappa si muove e non si costruisce niente
	_scegli(p, "casa_greca")
	var pos0 := cam.position
	_dito(0, schermo, true)
	_mouse(schermo, true)
	for k in 5:
		_trascina(0, schermo + Vector2(30 * (k + 1), 0), Vector2(30, 0))
	_mouse(schermo + Vector2(150, 0), false)
	_dito(0, schermo + Vector2(150, 0), false)
	_controlla(cam.position.x < pos0.x - 100.0, "un dito trascina la mappa (%.0f → %.0f)" % [pos0.x, cam.position.x])
	_controlla(_case(v) == case_prima, "trascinando non si costruisce")

	# un tocco breve: è un clic e si costruisce
	cam.position = pos0
	await process_frame
	schermo = p.get_canvas_transform() * p.dati.a_schermo(posto.x + 0.5, posto.y + 0.5)
	_scegli(p, "casa_greca")
	_dito(0, schermo, true)
	_mouse(schermo, true)
	_mouse(schermo, false)
	_dito(0, schermo, false)
	_controlla(_case(v) == case_prima + 1, "un tocco breve costruisce l'abitazione")

	# due dita: pizzicare allarga lo zoom
	var z0: float = cam._zoom_obiettivo
	_dito(0, Vector2(800, 500), true)
	_dito(1, Vector2(900, 500), true)
	_trascina(1, Vector2(1000, 500), Vector2(100, 0))
	_dito(1, Vector2(1000, 500), false)
	_dito(0, Vector2(800, 500), false)
	_controlla(cam._zoom_obiettivo > z0 * 1.5 or is_equal_approx(cam._zoom_obiettivo, CameraMappa.ZOOM_MAX), "due dita allargano lo zoom (%.2f → %.2f)" % [z0, cam._zoom_obiettivo])

	# tocco lungo: annulla la modalità di costruzione
	_scegli(p, "casa_greca")
	_controlla(p.modalita == "costruisci", "si sta costruendo")
	_dito(0, Vector2(600, 600), true)
	_mouse(Vector2(600, 600), true)
	for k in 50:
		await process_frame
		cam._process(0.02)
	_mouse(Vector2(600, 600), false)
	_dito(0, Vector2(600, 600), false)
	_controlla(p.modalita == "", "un tocco lungo annulla (modalità «%s»)" % p.modalita)
	_controlla(_case(v) == case_prima + 1, "il tocco lungo non costruisce")

	print("RISULTATO: %s (%d errori)" % ["OK" if errori == 0 else "FALLITO", errori])
	quit(1 if errori > 0 else 0)


func _scegli(partita: Node2D, tipo: String) -> void:
	partita.modalita = "costruisci"
	partita.tipo_scelto = tipo


func _case(v: Villaggio) -> int:
	return v.edifici.values().filter(func(e): return e.tipo == "casa_greca").size()


func _dito(indice: int, pos: Vector2, giu: bool) -> void:
	var t := InputEventScreenTouch.new()
	t.index = indice
	t.position = pos
	t.pressed = giu
	p.camera._unhandled_input(t)


func _trascina(indice: int, pos: Vector2, rel: Vector2) -> void:
	var d := InputEventScreenDrag.new()
	d.index = indice
	d.position = pos
	d.relative = rel
	p.camera._unhandled_input(d)


## Il clic che Godot ricava dal dito (dispositivo «emulazione»).
func _mouse(pos: Vector2, giu: bool) -> void:
	var m := InputEventMouseButton.new()
	m.button_index = MOUSE_BUTTON_LEFT
	m.position = pos
	m.pressed = giu
	m.device = InputEvent.DEVICE_ID_EMULATION
	p._unhandled_input(m)


func _controlla(ok: bool, cosa: String) -> void:
	print(("  ok  " if ok else "  NO  ") + cosa)
	if not ok:
		errori += 1
