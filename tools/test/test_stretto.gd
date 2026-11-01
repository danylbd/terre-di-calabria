extends "res://tools/test/test_catena.gd"
## Test automatico dello step 28 (lo Stretto: navi e porti): sulla mappa di Zancle un porto riceve le anfore,
## la nave salpa sul mare, va al largo e torna con i ducati; con un secondo porto sulla costa calabrese la
## nave attraversa lo Stretto fino a lì.
## Uso: godot --headless --path . --script tools/test/test_stretto.gd (FOTO=file.png senza --headless)

var _vista_nave := false
var _vista_in_mare := false


func _initialize() -> void:
	Impostazioni.mappa = "zancle"
	Impostazioni.modalita = "pace"
	Impostazioni.missione = ""
	Impostazioni.popolo = "greci"
	super._initialize()


func _prova() -> void:
	await process_frame
	var v: Villaggio = p.villaggio
	var d: DatiMappa = p.dati
	var mag: Edificio = v.magazzino()
	_controlla(CatalogoEdifici.dati("porto")["ingressi"].has("anfore") and "porto" in CatalogoEdifici.della_categoria("Base", "greci"),
		"il porto è nel menu e vuole anfore")
	v.scorte["anfore"] = 12
	var porto := _piazza("porto", func(f): return -Vector2(f - mag.bandiera).length())
	_controlla(porto != null, "porto piazzato sulla costa e collegato")
	if porto == null:
		_fine()
		return
	Engine.time_scale = VELOCITA
	var foto := OS.get_environment("FOTO")
	for k in 120:
		await create_timer(5.0).timeout
		var l: Lavoratore = porto.lavoratore
		if l and l.stato == Lavoratore.Stato.NAVIGA:
			_vista_nave = true
			if d.tipo(int(l.pos.x), int(l.pos.y)) == DatiMappa.Terreno.ACQUA and l._foglio == "nave":
				_vista_in_mare = true
				if foto != "" and not FileAccess.file_exists(foto):
					Engine.time_scale = 1.0
					p.camera.set_process(false)
					p.camera.zoom = Vector2.ONE * 0.8
					p.camera.position = d.a_schermo(l.pos.x, l.pos.y)
					for f in 8:
						await process_frame
					root.get_viewport().get_texture().get_image().save_png(foto)
					print("Screenshot salvato in ", foto)
					Engine.time_scale = VELOCITA
		if porto.prodotti >= 2:
			break
	Engine.time_scale = 1.0
	_controlla(_vista_nave and _vista_in_mare, "la nave è salpata e ha navigato sul mare")
	_controlla(porto.prodotti >= 1, "la nave è tornata con i ducati (%d viaggi)" % porto.prodotti)
	var l: Lavoratore = porto.lavoratore
	_controlla(l != null and is_equal_approx(l.velocita, 1.15), "a terra il marinaio torna a camminare piano")

	# la traversata: un secondo porto sulla costa calabrese
	var calabria := Vector2i(-1, -1)
	for y in range(14, 34):
		for x in range(66, 80):
			if calabria.x < 0 and d.tipo(x, y) != DatiMappa.Terreno.ACQUA and d.tipo(x + 1, y) != DatiMappa.Terreno.ACQUA \
					and d.tipo(x - 2, y) == DatiMappa.Terreno.ACQUA and d.occupante(x, y) == 0:
				calabria = Vector2i(x, y)
	# i confini sulla sponda calabrese: una torre presidiata
	var torre := v.costruisci("torre", calabria + Vector2i(4, 2), true, true)
	torre.presidiata = true
	v._ricalcola_territorio()
	var altro := v.costruisci("porto", calabria, true, true)
	_controlla(altro != null, "secondo porto sulla costa calabrese in %s" % calabria)
	if l and altro:
		var partenza: Vector2i = l._acqua_vicina(Vector2i(porto.centro()), 4)
		var rotta: Array[Vector2] = l.rotta_nave(partenza)
		var vicino_altro: Vector2i = l._acqua_vicina(Vector2i(altro.centro()), 4)
		_controlla(not rotta.is_empty() and Vector2i(rotta[-1].floor()) == vicino_altro,
			"la nave attraversa lo Stretto fino all'altro porto (%s → %s, %d tappe)" % [partenza, vicino_altro, rotta.size()])
		_controlla(rotta.all(func(t): return d.tipo(int(t.x), int(t.y)) == DatiMappa.Terreno.ACQUA), "la rotta passa solo sul mare")
	_fine()
