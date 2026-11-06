extends SceneTree
## Verifica piazzamento vicino a una bandierina, bandierine nascoste e scala dei coloni.

var errori := 0


func _initialize() -> void:
	var partita: Node = load("res://src/mappa/partita.tscn").instantiate()
	root.add_child(partita)
	_verifica.call_deferred(partita)


func _verifica(partita: Node) -> void:
	await process_frame
	var villaggio: Villaggio = partita.villaggio
	var dati: DatiMappa = partita.dati
	var caselle_nostre := 0
	for proprietario in dati.territorio:
		if proprietario == 1:
			caselle_nostre += 1
	_controlla(caselle_nostre >= 400, "il magazzino iniziale offre un'area ampia per costruire (%d caselle)" % caselle_nostre)
	var menu: MenuCostruzione = partita.menu
	var altezza_menu := menu.size.y
	menu.alterna()
	await process_frame
	_controlla(menu.size.y < altezza_menu * 0.3, "il menu Costruisci si richiude davvero lasciando visibile la maniglia")
	menu.alterna()
	await process_frame
	var posata := false
	var dimensione: int = CatalogoEdifici.dati("casa_greca")["taglia"]
	for y in range(1, dati.altezza - dimensione - 2):
		for x in range(1, dati.larghezza - dimensione - 2):
			var c := Vector2i(x, y)
			var ingresso := Vector2i(c.x + (dimensione - 1) / 2, c.y + dimensione)
			var vicino := ingresso + Vector2i(1, 0)
			if not villaggio.puo_costruire("casa_greca", c):
				continue
			if partita.rete.motivo_no_bandiera(vicino) != "":
				continue
			if not partita.rete.aggiungi_bandiera(vicino):
				continue
			var trovato: Vector2i = villaggio._trova_bandiera_edificio("casa_greca", c)
			if trovato != ingresso and villaggio.puo_costruire("casa_greca", c):
				var casa: Edificio = villaggio.costruisci("casa_greca", c)
				_controlla(casa != null, "la casa si costruisce anche se l'ingresso frontale è vicino a una bandierina")
				if casa:
					_controlla(casa.bandiera == trovato, "la casa usa un ingresso libero sul perimetro")
				posata = true
			partita.rete.rimuovi_bandiera(vicino)
			if posata:
				break
		if posata:
			break
	_controlla(posata, "trovato uno spazio edificabile con una bandierina vicina alla porta frontale")
	for record in partita.rete.bandiere.values():
		_controlla(not (record["sprite"] as CanvasItem).visible, "le bandierine stradali non compaiono sulla mappa")
		break
	var colono := Colono.new()
	colono.prepara(dati, Vector2.ZERO)
	var animazione_colono := colono.get_child(0) as AnimatedSprite2D
	_controlla(is_equal_approx(animazione_colono.scale.x, 0.58), "il colono è ridimensionato per la scala degli edifici")
	_controlla(animazione_colono.sprite_frames.get_frame_count("S") == 8, "il colono mantiene otto fotogrammi di camminata")
	colono.free()
	var soldato := Colono.new()
	soldato.prepara(dati, Vector2.ZERO, "guardia")
	_controlla(is_equal_approx(soldato.get_child(0).scale.x, 0.72), "le guardie mantengono una scala leggibile e proporzionata")
	soldato.free()
	var lavoratore := Colono.new()
	lavoratore.prepara(dati, Vector2.ZERO, "lavoratore_martello_lavoro")
	var animazione_lavoro := lavoratore.get_child(0) as AnimatedSprite2D
	_controlla(animazione_lavoro.sprite_frames.get_frame_count("S") == 8, "l'attività mostra l'animazione del mestiere")
	lavoratore.free()
	var nave := Colono.new()
	nave.prepara(dati, Vector2.ZERO, "nave")
	_controlla(is_equal_approx(nave.get_child(0).scale.x, 1.0), "navi e macchine non vengono rimpicciolite insieme ai personaggi")
	nave.free()
	var foto := OS.get_environment("FOTO")
	if foto != "":
		partita._esci_modalita()
		var magazzino := villaggio.magazzino()
		partita.camera.position = dati.a_schermo(magazzino.centro().x + 4, magazzino.centro().y + 2)
		partita.camera.zoom = Vector2.ONE * 1.25
		var base := magazzino.centro() + Vector2(4, 1)
		for esempio in [["portatore_pesce", base], ["lavoratore_ascia_lavoro", base + Vector2(1, 0)], ["guardia", base + Vector2(2, 0)]]:
			var persona := Colono.new()
			partita.oggetti.add_child(persona)
			persona.prepara(dati, esempio[1], esempio[0])
			persona.percorri([esempio[1] + Vector2(0.8, 0)])
		await create_timer(0.8).timeout
		var immagine := root.get_viewport().get_texture().get_image()
		immagine.save_png(foto)
		print("Screenshot salvato in ", foto)
	partita.queue_free()
	await process_frame
	print("RISULTATO: %s (%d errori)" % ["OK" if errori == 0 else "FALLITO", errori])
	quit(1 if errori > 0 else 0)


func _controlla(ok: bool, testo: String) -> void:
	print(("  ok  " if ok else "  NO  ") + testo)
	if not ok:
		errori += 1
