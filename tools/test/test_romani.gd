extends "res://tools/test/test_catena.gd"
## Test automatico dello step 20 (Romani giocabili): partita libera con i Romani in guerra. Controlla
## l'aspetto romano degli edifici, il menu (laterizi sì, agorà e pecificio no), la catena argilla → tegole,
## i portatori più veloci, i nemici brettii, i legionari e il salvataggio del popolo.
## Uso: godot --headless --path . --script tools/test/test_romani.gd (FOTO=file.png senza --headless)

const FILE := "user://test_romani.json"


func _initialize() -> void:
	Impostazioni.popolo = "romani"
	Impostazioni.mappa = "costa_ionica"
	Impostazioni.modalita = "guerra"
	Impostazioni.missione = ""
	super._initialize()


func _prova() -> void:
	await process_frame
	var v: Villaggio = p.villaggio
	var mag: Edificio = v.magazzino()
	_controlla(p.popolo == "romani" and Popoli.giocatore == "romani" and Popoli.nemico() == "brettii", "si gioca con i Romani contro i Brettii")
	_controlla(mag._sprite.texture.resource_path.ends_with("magazzino_romani.png"), "il magazzino ha l'aspetto romano")
	var base := CatalogoEdifici.della_categoria("Base", "romani")
	_controlla("laterizi" in base and not "agora" in base and not "pecificio" in base, "nel menu ci sono i laterizi, non l'agorà né il pecificio")
	var torri := v.nemici.values()
	_controlla(torri.size() == 2 and torri.all(func(n): return n.tipo == "torre_brettia"), "i nemici sono brettii: %d torri" % torri.size())
	_controlla(Popoli.soldati(1)[0] == "legionario" and Popoli.soldati(2)[0] == "brettio", "i nostri soldati sono legionari, i loro frombolieri")
	_controlla(ResourceLoader.exists("res://assets/grafica/legionario.png"), "c'è lo sprite del legionario")
	_controlla(Popoli.testo("I Brettii attaccano") == "I Brettii attaccano", "i messaggi nominano i Brettii come nemici")
	var rete: ReteStrade = p.rete
	_controlla(rete.tratti.values().all(func(t): return t.portatore == null or is_equal_approx(t.portatore.velocita, 1.15 * 1.15)),
		"i portatori corrono sulle strade lastricate")

	# le tegole
	v.scorte["argilla"] = 12
	var lat := _piazza("laterizi", func(f): return -Vector2(f - mag.bandiera).length())
	_controlla(lat != null, "fornace dei laterizi piazzata e collegata")
	Engine.time_scale = VELOCITA
	for k in 20:
		await create_timer(30.0).timeout
		if lat and lat.prodotti > 0:
			break
	Engine.time_scale = 1.0
	_controlla(lat != null and lat.prodotti > 0, "la fornace ha cotto le tegole (%d)" % (lat.prodotti if lat else 0))
	_controlla(lat != null and lat._sprite.texture.resource_path.ends_with("laterizi.png"), "la fornace ha il suo aspetto")

	# salvataggio
	_controlla(Salvataggio.salva(p, FILE), "partita salvata")
	_controlla(Salvataggio.popolo_di(FILE) == "romani", "il file ricorda i Romani")
	Impostazioni.popolo = "greci"
	Salvataggio.da_caricare = FILE
	p.queue_free()
	await process_frame
	p = load("res://src/mappa/partita.tscn").instantiate()
	root.add_child(p)
	await process_frame
	_controlla(p.popolo == "romani" and p.villaggio.magazzino()._sprite.texture.resource_path.ends_with("magazzino_romani.png"),
		"ricaricando si torna ai Romani")
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
