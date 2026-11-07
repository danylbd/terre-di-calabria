extends SceneTree

const USCITA_CAMMINO := "res://docs/immagini/screenshot-soldati-C10-cammino-in-gioco.png"
const USCITA_LOTTA := "res://docs/immagini/screenshot-soldati-C10-combattimento-in-gioco.png"
const TIPI := ["guardia", "legionario", "brettio", "cavaliere_leggero", "cavaliere_pesante",
	"guerriero_siculo", "arciere_sicano", "mercenario_cartaginese"]

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
	var nodi: Array[Colono] = []
	for indice in TIPI.size():
		var pos := base + Vector2((indice % 4) * 2.2, (indice / 4) * 2.6)
		var tipo: String = TIPI[indice]
		var persona := Colono.new()
		partita.oggetti.add_child(persona)
		persona.prepara(dati, pos, tipo, "greci")
		persona.percorri([pos + Vector2(1.0, 0.1)])
		nodi.append(persona)
		var schermo: Vector2 = (dati.a_schermo(pos.x, pos.y) - partita.camera.position) * partita.camera.zoom + vp_size * 0.5
		var nome := Label.new()
		nome.text = tipo.replace("_", " ").to_upper()
		nome.position = schermo + Vector2(-45, 14)
		nome.add_theme_font_size_override("font_size", 12)
		nome.add_theme_color_override("font_color", Color(0.2, 0.08, 0.04))
		canvas.add_child(nome)
	await create_timer(1.0).timeout
	root.get_viewport().get_texture().get_image().save_png(USCITA_CAMMINO)
	for indice in TIPI.size():
		nodi[indice].imposta_foglio("%s_lotta" % TIPI[indice])
	await create_timer(0.7).timeout
	root.get_viewport().get_texture().get_image().save_png(USCITA_LOTTA)
	print("Screenshot C10 soldati salvati: cammino e combattimento")
	quit()
