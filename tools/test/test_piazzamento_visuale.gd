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
	var pannello_nome_prova := PanelContainer.new()
	pannello_nome_prova.visible = false
	partita.add_child(pannello_nome_prova)
	partita._etichette_luoghi.append({"casella": dati.villaggio + Vector2i(8, 0), "pannello": pannello_nome_prova})
	_controlla(partita._etichette_luoghi.size() > 0, "i nomi dei luoghi sulla mappa hanno etichette interattive")
	var nomi_visibili := 0
	for record_nome in partita._etichette_luoghi:
		nomi_visibili += int((record_nome["pannello"] as Control).visible)
	_controlla(nomi_visibili == 0, "i nomi dei luoghi restano nascosti senza passaggio del cursore")
	partita._aggiorna_nomi_luoghi(partita._etichette_luoghi[0]["casella"])
	nomi_visibili = 0
	for record_nome in partita._etichette_luoghi:
		nomi_visibili += int((record_nome["pannello"] as Control).visible)
	_controlla(nomi_visibili == 1, "passando sul luogo appare soltanto il suo nome con sfondo")
	partita._aggiorna_nomi_luoghi(Vector2i(-1000, -1000))
	pannello_nome_prova.free()
	partita._etichette_luoghi.clear()
	var caselle_nostre := 0
	for proprietario in dati.territorio:
		if proprietario == 1:
			caselle_nostre += 1
	_controlla(caselle_nostre >= 400, "il magazzino iniziale offre un'area ampia per costruire (%d caselle)" % caselle_nostre)
	var menu: MenuCostruzione = partita.menu
	var altezza_menu := menu.size.y
	var altezza_finestra := menu.get_viewport_rect().size.y
	menu.alterna()
	await process_frame
	_controlla(menu.size.y < altezza_menu * 0.3, "il menu Costruisci si richiude davvero lasciando visibile la maniglia")
	menu.alterna()
	await process_frame
	var rettangolo_riaperto := menu.get_global_rect()
	_controlla(rettangolo_riaperto.position.y >= 0.0 and rettangolo_riaperto.end.y <= altezza_finestra,
		"il menu si riapre interamente dentro lo schermo (y %.0f..%.0f su %.0f)" % [rettangolo_riaperto.position.y, rettangolo_riaperto.end.y, altezza_finestra])
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
	_controlla(is_equal_approx(animazione_colono.scale.x, 0.38), "il colono C10 è ridimensionato per la scala degli edifici")
	_controlla(animazione_colono.sprite_frames.get_frame_count("S") == 4, "il colono C10 usa i quattro fotogrammi di camminata")
	_controlla(animazione_colono.sprite_frames.get_animation_loop("S"), "il ciclo del passo continua finché il colono cammina")
	colono.velocita = 2.3
	colono.percorri([Vector2(1, 0)])
	colono._process(0.0)
	_controlla(is_equal_approx(animazione_colono.speed_scale, 2.0), "il ritmo dei passi segue la velocità del colono")
	colono.free()
	var soldato := Colono.new()
	soldato.prepara(dati, Vector2.ZERO, "guardia")
	_controlla(is_equal_approx(soldato.get_child(0).scale.x, 0.38), "le guardie C10 mantengono una scala leggibile e proporzionata")
	soldato.free()
	var lavoratore := Colono.new()
	lavoratore.prepara(dati, Vector2.ZERO, "lavoratore_martello_lavoro")
	var animazione_lavoro := lavoratore.get_child(0) as AnimatedSprite2D
	_controlla(animazione_lavoro.sprite_frames.get_frame_count("S") == 4, "l'attività mostra l'animazione del mestiere")
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
	for record_nome in partita._etichette_luoghi:
		(record_nome["pannello"] as Control).free()
	partita._etichette_luoghi.clear()
	partita.queue_free()
	await process_frame
	print("RISULTATO: %s (%d errori)" % ["OK" if errori == 0 else "FALLITO", errori])
	quit(1 if errori > 0 else 0)


func _controlla(ok: bool, testo: String) -> void:
	print(("  ok  " if ok else "  NO  ") + testo)
	if not ok:
		errori += 1
