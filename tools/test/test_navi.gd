extends "res://tools/test/test_catena.gd"
## Test automatico dello step 35 (navi da guerra e traversate): a Zancle la schiera sale sulla nave al porto
## siciliano e sbarca al porto calabrese; una nave da guerra armata al porto va a bersagliare una torre nemica
## sulla costa finché non ha più difensori; nel salvataggio i materiali delle navi tornano nel magazzino.
## Uso: godot --headless --path . --script tools/test/test_navi.gd (FOTO=file.png senza --headless)

const FILE := "user://test_navi.json"


func _initialize() -> void:
	Impostazioni.mappa = "zancle"
	Impostazioni.modalita = "guerra"
	Impostazioni.missione = ""
	Impostazioni.popolo = "greci"
	super._initialize()


func _prova() -> void:
	await process_frame
	var v: Villaggio = p.villaggio
	var d: DatiMappa = p.dati
	var mag: Edificio = v.magazzino()
	var sch: Schiere = p.schiere
	var flotta: NaviGuerra = p.navi_guerra
	var porto := _piazza("porto", func(f): return -Vector2(f - mag.bandiera).length())
	_controlla(porto != null, "porto sulla sponda siciliana")
	porto.finito = true
	# la sponda calabrese: una torre nostra per i confini e un porto
	var calabria := Vector2i(-1, -1)
	for y in range(14, 34):
		for x in range(66, 80):
			if calabria.x < 0 and d.tipo(x, y) != DatiMappa.Terreno.ACQUA and d.tipo(x + 1, y) != DatiMappa.Terreno.ACQUA \
					and d.tipo(x - 2, y) == DatiMappa.Terreno.ACQUA and d.occupante(x, y) == 0:
				calabria = Vector2i(x, y)
	var torre := v.costruisci("torre", calabria + Vector2i(4, 2), true, true)
	torre.presidiata = true
	v._ricalcola_territorio()
	var altro := v.costruisci("porto", calabria, true, true)
	_controlla(altro != null, "porto sulla sponda calabrese")

	# la traversata
	var caserma: Edificio = null
	for y in range(d.villaggio.y - 6, d.villaggio.y + 7):
		for x in range(d.villaggio.x - 6, d.villaggio.x + 7):
			if caserma == null and v.puo_costruire("caserma", Vector2i(x, y)):
				caserma = v.costruisci("caserma", Vector2i(x, y), true, true)
	v.soldati = 8
	v.scorte["pane"] = 30
	sch.forma(caserma)
	_controlla(sch.imbarca(porto), "ordine: la schiera va al porto e si imbarca")
	var salpata := false
	Engine.time_scale = VELOCITA
	for k in 60:
		await create_timer(1.0).timeout
		if sch.in_viaggio():
			salpata = true
		if salpata and not sch.in_viaggio():
			break
	Engine.time_scale = 1.0
	_controlla(salpata, "la schiera è salita sulla nave")
	var capo: Colono = sch.schiera["condottiero"]
	_controlla(not sch.in_viaggio() and capo.visible and capo.pos.distance_to(Vector2(altro.bandiera)) < 3.0,
		"ed è sbarcata in Calabria (%s)" % capo.pos)

	# la nave da guerra
	var costa := Vector2i(-1, -1)
	for y in range(26, 40):
		for x in range(66, 84):
			if costa.x < 0 and d.tipo(x, y) != DatiMappa.Terreno.ACQUA and d.tipo(x + 1, y + 2) != DatiMappa.Terreno.ACQUA \
					and Mare.acqua_vicina(d, Vector2i(x, y), 3).x >= 0 and d.occupante(x, y) == 0 and d.occupante(x + 1, y + 2) == 0 \
					and Vector2(Vector2i(x, y) - calabria).length() > 8:
				costa = Vector2i(x, y)
	var nemica := v.metti_nemico(Popoli.torre_nemica(), costa, 2, 3)
	_controlla(nemica != null, "una torre nemica sulla costa in %s" % costa)
	_controlla(flotta.motivo_no_nave(porto).begins_with("Servono"), "senza assi e armi niente nave")
	v.scorte["assi"] = 20
	v.scorte["armi"] = 4
	_controlla(flotta.arma(porto) and flotta.navi.size() == 1, "una nave da guerra esce dal porto")
	var nave: Dictionary = flotta.navi[0]
	var colpita = nave["bersaglio"]
	_controlla(colpita != null and v.nemici.has(colpita.id), "e punta la torre nemica più vicina per mare")
	var materiali_file := 0
	Engine.time_scale = VELOCITA
	for k in 90:
		await create_timer(1.0).timeout
		if nave["stato"] == "tira" and OS.get_environment("FOTO") != "" and not FileAccess.file_exists(OS.get_environment("FOTO")):
			Engine.time_scale = 1.0
			p.camera.set_process(false)
			p.camera.zoom = Vector2.ONE * 0.8
			p.camera.position = d.a_schermo(nave["nave"].pos.x, nave["nave"].pos.y)
			for f in 6:
				await process_frame
			root.get_viewport().get_texture().get_image().save_png(OS.get_environment("FOTO"))
			print("Screenshot salvato in ", OS.get_environment("FOTO"))
			Engine.time_scale = VELOCITA
		if colpita == null or (is_instance_valid(colpita) and colpita.soldati <= 0):
			break
	Engine.time_scale = 1.0
	_controlla(colpita != null and is_instance_valid(colpita) and colpita.soldati <= 0, "la nave ha tolto tutti i difensori alla torre")

	# salvataggio: i materiali delle navi tornano nel magazzino
	var assi: int = v.scorte["assi"]
	_controlla(Salvataggio.salva(p, FILE), "partita salvata")
	var f := FileAccess.open(FILE, FileAccess.READ)
	var dati_file = JSON.parse_string(f.get_as_text())
	f.close()
	_controlla(int(dati_file["scorte"]["assi"]) == assi + NaviGuerra.COSTO["assi"], "nel file la nave è tornata assi e armi")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(FILE))
	Impostazioni.mappa = "costa_ionica"
	Impostazioni.modalita = "pace_poi_guerra"
	_fine()
