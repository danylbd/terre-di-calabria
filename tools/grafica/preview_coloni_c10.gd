extends SceneTree

const USCITA := "res://docs/immagini/screenshot-coloni-C10-stile-C-in-gioco.png"
const POPOLI := ["greci", "romani", "brettii", "saraceni", "normanni", "siculi", "sicani", "cartaginesi"]

func _initialize() -> void:
	call_deferred("_crea")

func _crea() -> void:
	var partita: Node = load("res://src/mappa/partita.tscn").instantiate()
	root.add_child(partita)
	await process_frame
	partita._esci_modalita()
	partita.menu.hide()
	var dati: DatiMappa = partita.dati
	var base: Vector2 = partita.villaggio.magazzino().centro() + Vector2(1, 2)
	partita.camera.position = dati.a_schermo(base.x + 4.0, base.y + 2.3)
	partita.camera.zoom = Vector2.ONE * CameraMappa.ZOOM_MAX
	var canvas := CanvasLayer.new()
	root.add_child(canvas)
	var vp_size := root.get_viewport().get_visible_rect().size
	for indice in POPOLI.size():
		var pos := base + Vector2((indice % 4) * 2.2, (indice / 4) * 2.6)
		var popolo: String = POPOLI[indice]
		var persona := Colono.new()
		partita.oggetti.add_child(persona)
		persona.prepara(dati, pos, "portatore_nessuno", popolo)
		persona.percorri([pos + Vector2(1.0, 0.1)])
		var schermo: Vector2 = (dati.a_schermo(pos.x, pos.y) - partita.camera.position) * partita.camera.zoom + vp_size * 0.5
		var nome := Label.new()
		nome.text = popolo.to_upper()
		nome.position = schermo + Vector2(-32, 16)
		nome.add_theme_font_size_override("font_size", 13)
		nome.add_theme_color_override("font_color", Color(0.2, 0.08, 0.04))
		canvas.add_child(nome)
	await create_timer(1.0).timeout
	root.get_viewport().get_texture().get_image().save_png(USCITA)
	print("Screenshot C10 salvato in ", USCITA)
	quit()
