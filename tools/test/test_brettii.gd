extends "res://tools/test/test_catena.gd"
## Test automatico dello step 19 (Brettii giocabili): partita libera con i Brettii in guerra. Controlla
## l'aspetto brettio degli edifici, il menu (pecificio sì, agorà no), la catena tronchi → pece, il passo
## svelto dei portatori nei boschi, i nemici greci con torri e soldati greci e il salvataggio del popolo.
## Uso: godot --headless --path . --script tools/test/test_brettii.gd (FOTO=file.png senza --headless)

const FILE := "user://test_brettii.json"


func _initialize() -> void:
	Impostazioni.popolo = "brettii"
	Impostazioni.mappa = "costa_ionica"
	Impostazioni.modalita = "guerra"
	Impostazioni.missione = ""
	super._initialize()


func _prova() -> void:
	await process_frame
	var v: Villaggio = p.villaggio
	var mag: Edificio = v.magazzino()
	_controlla(p.popolo == "brettii" and Popoli.giocatore == "brettii" and Popoli.nemico() == "greci", "si gioca con i Brettii contro i Greci")
	_controlla(mag._sprite.texture.resource_path.ends_with("magazzino_brettii.png"), "il magazzino ha l'aspetto brettio")
	var base := CatalogoEdifici.della_categoria("Base", "brettii")
	_controlla("pecificio" in base and not "agora" in base, "nel menu c'è il pecificio e non l'agorà")
	_controlla("agora" in CatalogoEdifici.della_categoria("Base", "greci") and not "pecificio" in CatalogoEdifici.della_categoria("Base", "greci"),
		"i Greci hanno l'agorà e non il pecificio")
	var torri := v.nemici.values()
	_controlla(torri.size() == 2 and torri.all(func(n): return n.tipo == "torre" and n._sprite.texture.resource_path.ends_with("/torre.png")),
		"i nemici sono greci: %d torri greche" % torri.size())
	_controlla(Popoli.soldati(1)[0] == "brettio" and Popoli.soldati(2)[0] == "guardia", "i nostri soldati sono frombolieri, i loro opliti")
	_controlla(Popoli.testo("I Brettii attaccano") == "I Greci attaccano", "i messaggi nominano i Greci come nemici")

	# passo svelto nel bosco
	var bosco := Vector2i(-1, -1)
	for y in p.dati.altezza:
		for x in p.dati.larghezza:
			if bosco.x < 0 and p.dati.tipo(x, y) == DatiMappa.Terreno.BOSCO and p.dati.tipo(x + 3, y) == DatiMappa.Terreno.BOSCO:
				bosco = Vector2i(x, y)
	var lento := Colono.new()
	var svelto := Colono.new()
	svelto.agile = true
	var percorsi := []
	for c in [lento, svelto]:
		p.oggetti.add_child(c)
		c.prepara(p.dati, Vector2(bosco) + Vector2(0.5, 0.5))
		c.set_process(false)
		c.percorri([Vector2(bosco) + Vector2(3.5, 0.5)] as Array[Vector2])
		c._process(1.0)
		percorsi.append(c.pos.x - bosco.x - 0.5)
		c.queue_free()
	_controlla(bosco.x >= 0 and percorsi[1] > percorsi[0] * 1.2, "nel bosco il portatore brettio è più svelto (%.2f contro %.2f caselle)" % [percorsi[1], percorsi[0]])
	var rete: ReteStrade = p.rete
	_controlla(rete.tratti.values().all(func(t): return t.portatore == null or t.portatore.agile), "i portatori del villaggio sono agili")

	# la pece
	var pec := _piazza("pecificio", func(f): return -Vector2(f - mag.bandiera).length())
	_controlla(pec != null, "pecificio piazzato e collegato")
	Engine.time_scale = VELOCITA
	for k in 20:
		await create_timer(30.0).timeout
		if pec and pec.prodotti > 0:
			break
	Engine.time_scale = 1.0
	if pec:
		print("  pecificio finito=%s lavoratore=%s ingresso=%s manca_colono=%s scorte=%s" % [pec.finito, "nessuno" if pec.lavoratore == null else Lavoratore.Stato.keys()[pec.lavoratore.stato], pec.ingresso, pec.manca_colono, v.scorte])
	_controlla(pec != null and pec.prodotti > 0, "il pecificio ha cotto la pece (%d)" % (pec.prodotti if pec else 0))
	_controlla(pec != null and pec._sprite.texture.resource_path.ends_with("pecificio.png"), "il pecificio ha il suo aspetto")

	# salvataggio
	_controlla(Salvataggio.salva(p, FILE), "partita salvata")
	_controlla(Salvataggio.popolo_di(FILE) == "brettii", "il file ricorda i Brettii")
	Impostazioni.popolo = "greci"
	Salvataggio.da_caricare = FILE
	p.queue_free()
	await process_frame
	p = load("res://src/mappa/partita.tscn").instantiate()
	root.add_child(p)
	await process_frame
	_controlla(p.popolo == "brettii" and p.villaggio.magazzino()._sprite.texture.resource_path.ends_with("magazzino_brettii.png"),
		"ricaricando si torna ai Brettii")
	_controlla(p.villaggio.nemici.values().all(func(n): return n.tipo == "torre"), "e le torri nemiche restano greche")
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
