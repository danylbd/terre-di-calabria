extends SceneTree
## Test automatico dello step V2 (monumenti di Monteleone): il primo monumento arriva da solo con la
## fondazione, gli altri seguono in ordine con i loro vantaggi, si posano sulla terra senza sovrapporsi,
## portano doni ogni stagione e sopravvivono al salvataggio. Sulla Costa ionica non ci sono.
## Uso: godot --headless --path . --script tools/test/test_monumenti.gd (FOTO=file.png senza --headless)

const FILE := "user://test_monumenti.json"

var p: Node2D
var errori := 0


func _initialize() -> void:
	Impostazioni.mappa = "monteleone"
	Impostazioni.modalita = "pace"
	Impostazioni.missione = ""
	p = load("res://src/mappa/partita.tscn").instantiate()
	root.add_child(p)
	_prova.call_deferred()


func _prova() -> void:
	await process_frame
	var mon: Monumenti = p.monumenti
	var v: Villaggio = p.villaggio
	var d: DatiMappa = p.dati
	_controlla(mon.attivi, "sulla mappa di Monteleone i monumenti sono attivi")
	var territorio_prima := _caselle_nostre(d)
	Engine.time_scale = 4.0
	await create_timer(4.0).timeout
	Engine.time_scale = 1.0
	_controlla(mon.ottenuti.size() == 1 and mon.ottenuti[0] == "mura_greche", "con la fondazione arrivano le mura greche (%s)" % [mon.ottenuti])
	_controlla(_caselle_nostre(d) > territorio_prima, "le mura allargano i confini (%d -> %d caselle)" % [territorio_prima, _caselle_nostre(d)])
	_controlla(not mon.traguardo_raggiunto("tempio_proserpina"), "il tempio aspetta i 50 coloni")

	# gli altri, uno dopo l'altro
	var soldati_prima := v.soldati
	for m in Monumenti.CATALOGO.slice(1):
		mon.sblocca(m["id"])
	_controlla(mon.ottenuti.size() == 11 and mon.prossimo_monumento().is_empty(), "tutti gli 11 monumenti ottenuti")
	_controlla(v.soldati == soldati_prima + 3, "il castello porta 3 soldati")
	_controlla(is_equal_approx(v.vantaggi["nascita"], 0.64) and is_equal_approx(v.vantaggi["lavoro"], 0.85)
		and is_equal_approx(v.vantaggi["duelli"], 0.12) and v.vantaggi["confini"] == 3, "vantaggi sommati: %s" % [v.vantaggi])
	var sovrapposti := false
	var in_mare := false
	var occupate := {}
	for id in mon.posti:
		var c: Vector2i = mon.posti[id]
		for y in range(c.y, c.y + 2):
			for x in range(c.x, c.x + 2):
				if occupate.has(Vector2i(x, y)):
					sovrapposti = true
				occupate[Vector2i(x, y)] = id
		if id != "santa_maria_isola" and d.tipo(c.x, c.y) == DatiMappa.Terreno.ACQUA:
			in_mare = true
		_controlla(mon._sprite[id].texture != null, "%s ha il suo sprite (in %s)" % [id, c])
	_controlla(not sovrapposti and not in_mare, "i monumenti stanno sulla terra senza sovrapporsi")
	_controlla(Vector2(mon.posti["castello_pizzo"] - d.luoghi["Pizzo"]).length() < 6.0
		and Vector2(mon.posti["porto_santa_venere"] - d.luoghi["Vibo Marina"]).length() < 6.0,
		"Pizzo e il porto stanno al loro posto")
	var ducati: int = v.scorte.get("ducati", 0)
	var pesce: int = v.scorte.get("pesce", 0)
	mon._doni()
	_controlla(v.scorte["ducati"] == ducati + 15 and v.scorte["pesce"] == pesce + 10, "i doni di una stagione: 15 ducati e 10 pesci")

	# salvataggio
	_controlla(Salvataggio.salva(p, FILE), "partita salvata")
	var posti: Dictionary = mon.posti.duplicate()
	var vantaggi: Dictionary = v.vantaggi.duplicate()
	var soldati := v.soldati
	Salvataggio.da_caricare = FILE
	p.queue_free()
	await process_frame
	p = load("res://src/mappa/partita.tscn").instantiate()
	root.add_child(p)
	await process_frame
	await process_frame
	_controlla(p.monumenti.ottenuti.size() == 11 and p.monumenti.posti == posti, "ricaricati tutti i monumenti, al loro posto")
	_controlla(p.villaggio.vantaggi == vantaggi, "ricaricati i vantaggi")
	_controlla(p.villaggio.soldati == soldati, "i soldati regalati non si raddoppiano (%d)" % p.villaggio.soldati)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(FILE))

	var foto := OS.get_environment("FOTO")
	if foto != "":
		var cam: Camera2D = p.camera
		cam.set_process(false)
		cam.limit_left = -100000
		cam.limit_top = -100000
		cam.limit_right = 100000
		cam.limit_bottom = 100000
		cam.zoom = Vector2.ONE * 0.45
		cam.position = p.dati.a_schermo(60, 30)
		for k in 10:
			await process_frame
		root.get_viewport().get_texture().get_image().save_png(foto)
		print("Screenshot salvato in ", foto)

	# sulla Costa ionica niente monumenti
	Impostazioni.mappa = "costa_ionica"
	p.queue_free()
	await process_frame
	p = load("res://src/mappa/partita.tscn").instantiate()
	root.add_child(p)
	await process_frame
	_controlla(not p.monumenti.attivi, "sulla Costa ionica i monumenti non ci sono")
	_fine()


func _caselle_nostre(d: DatiMappa) -> int:
	var n := 0
	for k in d.territorio.size():
		if d.territorio[k] == 1:
			n += 1
	return n


func _fine() -> void:
	print("RISULTATO: %s (%d errori)" % ["OK" if errori == 0 else "FALLITO", errori])
	Engine.time_scale = 1.0
	quit(1 if errori > 0 else 0)


func _controlla(ok: bool, cosa: String) -> void:
	print(("  ok  " if ok else "  NO  ") + cosa)
	if not ok:
		errori += 1
