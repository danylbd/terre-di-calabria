extends "res://tools/test/test_catena.gd"
## Test automatico dello step 22 (Normanni giocabili): partita libera con i Normanni in guerra. Controlla
## l'aspetto normanno, il menu (allevamento e mastio sì, edifici unici degli altri no), la catena dei
## cavalli, il mastio che costa cavalli, i confini più larghi delle torri, le guardie del proprio popolo,
## i nemici saraceni e il salvataggio del popolo.
## Uso: godot --headless --path . --script tools/test/test_normanni.gd (FOTO=file.png senza --headless)

const FILE := "user://test_normanni.json"


func _initialize() -> void:
	Impostazioni.popolo = "normanni"
	Impostazioni.mappa = "costa_ionica"
	Impostazioni.modalita = "guerra"
	Impostazioni.missione = ""
	super._initialize()


func _prova() -> void:
	await process_frame
	var v: Villaggio = p.villaggio
	var d: DatiMappa = p.dati
	var mag: Edificio = v.magazzino()
	_controlla(p.popolo == "normanni" and Popoli.nemico() == "saraceni", "si gioca con i Normanni contro i Saraceni")
	_controlla(mag._sprite.texture.resource_path.ends_with("magazzino_normanni.png"), "il magazzino ha l'aspetto normanno")
	var cibo := CatalogoEdifici.della_categoria("Cibo", "normanni")
	var difesa := CatalogoEdifici.della_categoria("Difesa", "normanni")
	_controlla("allevamento_cavalli" in cibo and "mastio" in difesa and not "agora" in CatalogoEdifici.della_categoria("Base", "normanni"),
		"nel menu l'allevamento e il mastio, non gli edifici unici degli altri")
	_controlla(not "mastio" in CatalogoEdifici.della_categoria("Difesa", "greci"), "i Greci non hanno il mastio")
	_controlla(CatalogoEdifici.dati("mastio")["costo"].get("cavalli", 0) == 2, "il mastio costa 2 cavalli")
	var torri := v.nemici.values()
	_controlla(torri.size() == 2 and torri.all(func(n): return n._sprite.texture.resource_path.ends_with("torre_saraceni.png")),
		"i nemici sono saraceni: %d torri saracene" % torri.size())
	_controlla(Popoli.soldati(1)[0] == "cavaliere_pesante" and Popoli.soldati(2)[0] == "cavaliere_leggero", "cavalieri pesanti contro cavalieri leggeri")
	_controlla(ResourceLoader.exists("res://assets/grafica/cavaliere_pesante.png"), "c'è lo sprite del cavaliere pesante")

	# confini più larghi: una torre presidiata copre 7 + 2 caselle
	var verso := Vector2(1, 0.4).normalized()
	var c := d.villaggio + Vector2i(verso * 12.0)
	var torre := v.costruisci("torre", c, true, true)
	torre.presidiata = true
	v._ricalcola_territorio()
	var lontana := Vector2i((torre.centro() + verso * 8.5).floor())
	_controlla(d.nel_territorio(lontana.x, lontana.y), "la torre normanna copre fino a 9 caselle (casella %s)" % lontana)
	_controlla(torre.lavoratore == null or torre.lavoratore._foglio_cammino == "cavaliere_pesante", "la guardia della torre è un cavaliere normanno")

	# i cavalli
	v.scorte["grano"] = 8
	v.scorte["acqua"] = 8
	var all := _piazza("allevamento_cavalli", func(f): return -Vector2(f - mag.bandiera).length())
	_controlla(all != null, "allevamento piazzato e collegato")
	Engine.time_scale = VELOCITA
	for k in 20:
		await create_timer(30.0).timeout
		if all and all.prodotti > 0:
			break
	Engine.time_scale = 1.0
	_controlla(all != null and all.prodotti > 0, "sono nati i cavalli (%d)" % (all.prodotti if all else 0))

	# salvataggio
	_controlla(Salvataggio.salva(p, FILE), "partita salvata")
	Impostazioni.popolo = "greci"
	Salvataggio.da_caricare = FILE
	p.queue_free()
	await process_frame
	p = load("res://src/mappa/partita.tscn").instantiate()
	root.add_child(p)
	await process_frame
	_controlla(p.popolo == "normanni" and p.villaggio.magazzino()._sprite.texture.resource_path.ends_with("magazzino_normanni.png"),
		"ricaricando si torna ai Normanni")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(FILE))

	var foto := OS.get_environment("FOTO")
	if foto != "":
		p.camera.set_process(false)
		p.camera.zoom = Vector2.ONE * 0.7
		p.camera.position = p.dati.a_schermo(p.dati.villaggio.x + 3.5, p.dati.villaggio.y + 2.5)
		for k in 10:
			await process_frame
		root.get_viewport().get_texture().get_image().save_png(foto)
		print("Screenshot salvato in ", foto)
	Impostazioni.popolo = "greci"
	Popoli.giocatore = "greci"
	_fine()
