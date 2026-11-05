extends "res://tools/test/test_catena.gd"
## Test automatico dello step 38 (mappa «Il Bruzio di Annibale»): la catena di test_catena giocata nella
## Calabria di Annibale; poi la forma della mappa (i due mari, l'istmo stretto tra Sant'Eufemia e Squillace,
## la Sila alta e boscosa, Crotone e il capo Lacinio sullo Ionio, Consentia nell'interno, Locri a sud),
## i villaggi indigeni del Bruzio e il salvataggio della mappa.
## Uso: godot --headless --path . --script tools/test/test_bruzio.gd (FOTO=file.png senza --headless)

const FILE := "user://test_bruzio.json"

var _controllata := false


func _initialize() -> void:
	Impostazioni.mappa = "bruzio"
	Impostazioni.modalita = "pace"
	Impostazioni.missione = ""
	Impostazioni.popolo = "greci"
	super._initialize()


func _fine() -> void:
	if _controllata:
		return
	_controllata = true
	var d: DatiMappa = p.dati
	var T := DatiMappa.Terreno
	_controlla(p.mappa == "bruzio" and d.larghezza == 144 and d.altezza == 144, "si gioca sulla mappa del Bruzio ampliata 144×144")
	_controlla(d.tipo(2, 30) == T.ACQUA and d.tipo(100, 70) == T.ACQUA, "a ovest il Tirreno, a est lo Ionio")
	# l'istmo: sulla riga di Lamezia e Catanzaro la terra è stretta
	var terra := 0
	for x in d.larghezza:
		if d.tipo(x, 62) != T.ACQUA:
			terra += 1
	_controlla(terra >= 25 and terra <= 40, "l'istmo tra i due mari è stretto (%d caselle di terra)" % terra)
	var sila: Vector2i = d.luoghi["Sila"]
	var boschi := 0
	for y in range(sila.y - 6, sila.y + 7):
		for x in range(sila.x - 6, sila.x + 7):
			if d.tipo(x, y) == T.BOSCO:
				boschi += 1
	_controlla(d.quota(sila.x, sila.y) > 100.0 and boschi > 60, "la Sila è alta e coperta di pini (quota %.0f, %d caselle di bosco)" % [d.quota(sila.x, sila.y), boschi])
	for nome in ["Crotone", "Capo Lacinio", "Locri", "Scolacium"]:
		var c: Vector2i = d.luoghi[nome]
		_controlla(d.tipo(c.x, c.y) != T.ACQUA and _mare_vicino(d, c, 5), "%s è sul mare" % nome)
	var cos: Vector2i = d.luoghi["Consentia"]
	_controlla(d.tipo(cos.x, cos.y) != T.ACQUA and not _mare_vicino(d, cos, 8), "Consentia è nell'interno")
	_controlla(Vector2(d.villaggio).distance_to(Vector2(d.luoghi["Crotone"])) < 10.0 and d.tipo(d.villaggio.x, d.villaggio.y) != T.ACQUA,
		"il villaggio nasce vicino a Crotone")
	var ind: VillaggiIndigeni = p.indigeni
	_controlla(ind.elenco.size() == 3 and ind.elenco.map(func(i): return i["nome"]).has("Petelia"), "ci sono i villaggi del Bruzio (%s)" % [ind.elenco.map(func(i): return i["nome"])])
	_controlla(Salvataggio.salva(p, FILE) and Salvataggio.mappa_di(FILE) == "bruzio", "il salvataggio ricorda la mappa del Bruzio")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(FILE))
	var foto := OS.get_environment("FOTO")
	if foto != "":
		p.camera.set_process(false)
		p.camera.zoom = Vector2.ONE * 0.18
		p.camera.position = d.a_schermo(52, 60)
		for k in 10:
			await process_frame
		root.get_viewport().get_texture().get_image().save_png(foto)
		print("Screenshot salvato in ", foto)
	Impostazioni.mappa = "costa_ionica"
	super._fine()


func _mare_vicino(d: DatiMappa, c: Vector2i, r: int) -> bool:
	for y in range(c.y - r, c.y + r + 1):
		for x in range(c.x - r, c.x + r + 1):
			if d.dentro(x, y) and d.tipo(x, y) == DatiMappa.Terreno.ACQUA:
				return true
	return false
