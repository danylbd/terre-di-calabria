extends "res://tools/test/test_catena.gd"
## Test automatico dello step 37 (i Cartaginesi): partita libera in guerra con l'ottavo popolo. Aspetto,
## menu con la tintoria della porpora e la stalla degli elefanti, la porpora prodotta, i nemici romani,
## i mercenari, il porto dei mercanti, Annibale con le sue abilità, l'elefante da guerra che segue la
## schiera (solo per i Cartaginesi) e il salvataggio del popolo.
## Uso: godot --headless --path . --script tools/test/test_cartaginesi.gd (FOTO=file.png senza --headless)

const FILE := "user://test_cartaginesi.json"


func _initialize() -> void:
	Impostazioni.mappa = "costa_ionica"
	Impostazioni.modalita = "guerra"
	Impostazioni.missione = ""
	Impostazioni.popolo = "cartaginesi"
	super._initialize()


func _prova() -> void:
	await process_frame
	var v: Villaggio = p.villaggio
	var mag: Edificio = v.magazzino()
	_controlla(Popoli.DATI.size() == 8 and p.popolo == "cartaginesi" and Popoli.nemico() == "romani", "l'ottavo popolo: i Cartaginesi contro i Romani")
	_controlla(mag._sprite.texture.resource_path.ends_with("magazzino_cartaginesi.png"), "il magazzino ha l'aspetto cartaginese")
	var base := CatalogoEdifici.della_categoria("Base", "cartaginesi")
	var difesa := CatalogoEdifici.della_categoria("Difesa", "cartaginesi")
	_controlla("tintoria_porpora" in base and "stalla_elefanti" in difesa and not "vasaio" in base and not "agora" in base,
		"nel menu ci sono la tintoria della porpora e la stalla degli elefanti")
	_controlla(not "tintoria_porpora" in CatalogoEdifici.della_categoria("Base", "romani"), "gli altri popoli non hanno la tintoria")
	_controlla(Popoli.soldati(1)[0] == "mercenario_cartaginese" and ResourceLoader.exists("res://assets/grafica/mercenario_cartaginese.png"),
		"i soldati sono i mercenari")
	_controlla(Popoli.tipo_soldato("cartaginesi") == "fanteria", "i mercenari sono fanteria")
	var torri := v.nemici.values()
	_controlla(torri.size() == 2 and torri.all(func(n): return n._sprite.texture.resource_path.ends_with("torre_romani.png")), "le torri nemiche sono romane")
	_controlla(Popoli.mercanti(), "i Cartaginesi sono mercanti: il porto rende il doppio")
	_controlla("porpora" in CatalogoEdifici.LUSSO, "la porpora è un lusso")
	for nome in ["tintoria_porpora_cartaginesi", "stalla_elefanti_cartaginesi", "condottiero_cartaginesi", "condottiero_cartaginesi_lotta",
			"elefante_guerra", "elefante_guerra_lotta", "merce_porpora", "merce_elefanti"]:
		_controlla(ResourceLoader.exists("res://assets/grafica/%s.png" % nome), "c'è lo sprite %s" % nome)

	# la porpora
	v.scorte["pesce"] = 12
	v.scorte["acqua"] = 8
	var tin := _piazza("tintoria_porpora", func(f): return -Vector2(f - mag.bandiera).length())
	_controlla(tin != null and tin._sprite.texture != null, "tintoria piazzata e collegata")
	Engine.time_scale = VELOCITA
	for k in 20:
		await create_timer(30.0).timeout
		if tin and tin.prodotti > 0:
			break
	Engine.time_scale = 1.0
	_controlla(tin != null and tin.prodotti > 0, "la tintoria ha prodotto la porpora (%d)" % (tin.prodotti if tin else 0))

	# Annibale e l'elefante da guerra
	var sch: Schiere = p.schiere
	_controlla(Schiere.nome_condottiero() == "Annibale" and Schiere.abilita().size() == 2, "il condottiero è Annibale, con due abilità")
	var d: DatiMappa = p.dati
	var caserma: Edificio = null
	var stalla: Edificio = null
	for y in range(d.villaggio.y - 10, d.villaggio.y + 11):
		for x in range(d.villaggio.x - 10, d.villaggio.x + 11):
			if caserma == null and v.puo_costruire("caserma", Vector2i(x, y)):
				caserma = v.costruisci("caserma", Vector2i(x, y), true, true)
			elif stalla == null and v.puo_costruire("stalla_elefanti", Vector2i(x, y)):
				stalla = v.costruisci("stalla_elefanti", Vector2i(x, y), true, true)
	_controlla(caserma != null and stalla != null, "caserma e stalla degli elefanti costruite")
	v.soldati = 8
	v.scorte["pane"] = 30
	_controlla(sch.forma(caserma), "Annibale esce con la schiera")
	var prima := sch.probabilita_vittoria()
	_controlla(sch.motivo_no_macchina("elefante").begins_with("Servono"), "senza elefanti nella stalla niente elefante da guerra")
	v.scorte["elefanti"] = 1
	v.scorte["armi"] = 1
	_controlla(Schiere.edificio_macchina("elefante") == "stalla_elefanti", "l'elefante esce dalla stalla")
	_controlla(sch.costruisci_macchina("elefante", stalla), "un elefante da guerra si unisce alla schiera")
	_controlla(sch.probabilita_vittoria() > prima, "con l'elefante i duelli sono più facili (%.2f > %.2f)" % [sch.probabilita_vittoria(), prima])
	_controlla(sch.macchine()["elefante"]._foglio == "elefante_guerra", "l'elefante ha il suo sprite")
	var foto := OS.get_environment("FOTO")
	if foto != "":
		Engine.time_scale = VELOCITA
		await create_timer(5.0).timeout
		Engine.time_scale = 1.0
		sch.scegli(true)
		p.camera.set_process(false)
		p.camera.zoom = Vector2.ONE * 1.4
		var capo: Colono = sch.schiera["condottiero"]
		p.camera.position = d.a_schermo(capo.pos.x, capo.pos.y)
		for k in 10:
			await process_frame
		root.get_viewport().get_texture().get_image().save_png(foto)
		print("Screenshot salvato in ", foto)
	# salvataggio
	_controlla(Salvataggio.salva(p, FILE), "partita salvata")
	_controlla(Salvataggio.popolo_di(FILE) == "cartaginesi", "il file ricorda i Cartaginesi")
	Impostazioni.popolo = "greci"
	Salvataggio.da_caricare = FILE
	p.queue_free()
	await process_frame
	p = load("res://src/mappa/partita.tscn").instantiate()
	root.add_child(p)
	await process_frame
	_controlla(p.popolo == "cartaginesi", "ricaricando si torna ai Cartaginesi")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(FILE))
	Impostazioni.popolo = "greci"
	Popoli.giocatore = "greci"
	_controlla(not Schiere.macchina_del_popolo("elefante") and not Popoli.mercanti(), "con i Greci niente elefanti e niente porto doppio")
	_fine()
