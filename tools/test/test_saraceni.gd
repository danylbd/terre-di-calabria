extends "res://tools/test/test_catena.gd"
## Test automatico dello step 21 (Saraceni giocabili): partita libera con i Saraceni in guerra. Controlla
## l'aspetto saraceno, il menu (bachicoltura e filanda sì, edifici unici degli altri no), la catena
## bozzoli → seta, i campi irrigati, i nemici romani, i cavalieri e il salvataggio del popolo.
## Uso: godot --headless --path . --script tools/test/test_saraceni.gd (FOTO=file.png senza --headless)

const FILE := "user://test_saraceni.json"


func _initialize() -> void:
	Impostazioni.popolo = "saraceni"
	Impostazioni.mappa = "costa_ionica"
	Impostazioni.modalita = "guerra"
	Impostazioni.missione = ""
	super._initialize()


func _prova() -> void:
	await process_frame
	var v: Villaggio = p.villaggio
	var d: DatiMappa = p.dati
	var mag: Edificio = v.magazzino()
	_controlla(p.popolo == "saraceni" and Popoli.nemico() == "romani", "si gioca con i Saraceni contro i Romani")
	_controlla(mag._sprite.texture.resource_path.ends_with("magazzino_saraceni.png"), "il magazzino ha l'aspetto saraceno")
	var base := CatalogoEdifici.della_categoria("Base", "saraceni")
	_controlla("bachicoltura" in base and "filanda" in base and not "agora" in base and not "pecificio" in base and not "laterizi" in base,
		"nel menu bachicoltura e filanda, non gli edifici unici degli altri")
	var torri := v.nemici.values()
	_controlla(torri.size() == 2 and torri.all(func(n): return n.tipo == "torre" and n._sprite.texture.resource_path.ends_with("torre_romani.png")),
		"i nemici sono romani: %d torri romane" % torri.size())
	_controlla(Popoli.soldati(1)[0] == "cavaliere_leggero" and Popoli.soldati(2)[0] == "legionario", "cavalieri leggeri contro legionari")
	_controlla(ResourceLoader.exists("res://assets/grafica/cavaliere_leggero.png"), "c'è lo sprite del cavaliere leggero")
	_controlla(Popoli.testo("I Brettii attaccano") == "I Romani attaccano", "i messaggi nominano i Romani come nemici")

	# campi irrigati
	var vicino := Vector2i(-1, -1)
	var lontano := Vector2i(-1, -1)
	for y in d.altezza:
		for x in d.larghezza:
			if d.tipo(x, y) != DatiMappa.Terreno.PRATO or d.occupante(x, y) != 0:
				continue
			var acqua: bool = p.risorse._acqua_entro(Vector2i(x, y), 3)
			if acqua and vicino.x < 0:
				vicino = Vector2i(x, y)
			elif not p.risorse._acqua_entro(Vector2i(x, y), 10) and lontano.x < 0:
				lontano = Vector2i(x, y)
	p.risorse.semina(vicino)
	p.risorse.semina(lontano)
	var cv: Dictionary = p.risorse.campi[vicino]
	var cl: Dictionary = p.risorse.campi[lontano]
	_controlla(cv["irrigato"] and not cl["irrigato"], "il campo vicino all'acqua è irrigato, quello lontano no")
	for k in 10:
		p.risorse._process(1.0)
	_controlla(cv["crescita"] > cl["crescita"] * 1.4, "il campo irrigato cresce più in fretta (%.3f contro %.3f)" % [cv["crescita"], cl["crescita"]])

	# la seta
	var bac := _piazza("bachicoltura", func(f): return -Vector2(f - mag.bandiera).length())
	var fil := _piazza("filanda", func(f): return -Vector2(f - mag.bandiera).length())
	_controlla(bac != null and fil != null, "bachicoltura e filanda piazzate e collegate")
	Engine.time_scale = VELOCITA
	for k in 20:
		await create_timer(30.0).timeout
		if fil and fil.prodotti > 0:
			break
	Engine.time_scale = 1.0
	_controlla(bac != null and bac.prodotti > 0, "i bachi hanno fatto i bozzoli (%d)" % (bac.prodotti if bac else 0))
	_controlla(fil != null and fil.prodotti > 0, "la filanda ha filato la seta (%d)" % (fil.prodotti if fil else 0))

	# salvataggio
	_controlla(Salvataggio.salva(p, FILE), "partita salvata")
	Impostazioni.popolo = "greci"
	Salvataggio.da_caricare = FILE
	p.queue_free()
	await process_frame
	p = load("res://src/mappa/partita.tscn").instantiate()
	root.add_child(p)
	await process_frame
	_controlla(p.popolo == "saraceni" and p.villaggio.magazzino()._sprite.texture.resource_path.ends_with("magazzino_saraceni.png"),
		"ricaricando si torna ai Saraceni")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(FILE))

	var foto := OS.get_environment("FOTO")
	if foto != "":
		p.camera.set_process(false)
		p.camera.zoom = Vector2.ONE * 0.8
		p.camera.position = p.dati.a_schermo(p.dati.villaggio.x + 0.5, p.dati.villaggio.y + 2.5)
		for k in 10:
			await process_frame
		root.get_viewport().get_texture().get_image().save_png(foto)
		print("Screenshot salvato in ", foto)
	Impostazioni.popolo = "greci"
	Popoli.giocatore = "greci"
	_fine()
