extends "res://tools/test/test_catena.gd"
## Test automatico dello step 36a (costruttori, come in Settlers): il cantiere riceve un costruttore che
## parte dal magazzino; il cantiere avanza solo con il costruttore accanto; finito l'edificio il costruttore
## torna e ridiventa un colono libero; se il cantiere viene demolito torna lo stesso; il salvataggio lo conta.
## Uso: godot --headless --path . --script tools/test/test_costruttori.gd (FOTO=file.png senza --headless)

const FILE := "user://test_costruttori.json"


func _initialize() -> void:
	Impostazioni.popolo = "greci"
	Impostazioni.mappa = "costa_ionica"
	Impostazioni.modalita = "pace"
	Impostazioni.missione = ""
	super._initialize()


func _prova() -> void:
	await process_frame
	var v: Villaggio = p.villaggio
	var mag: Edificio = v.magazzino()
	_controlla(ResourceLoader.exists("res://assets/grafica/lavoratore_martello_lavoro.png"), "c'è lo sprite del costruttore che martella")
	var pop := v.popolazione()

	var seg := _piazza("segheria", func(f): return -Vector2(f - mag.bandiera).length())
	_controlla(seg != null, "segheria piazzata e collegata")
	for k in 5:
		await process_frame
	_controlla(seg != null and seg.costruttore != null and v.costruttori == 1, "dal magazzino parte un costruttore (%d)" % v.costruttori)
	_controlla(v.popolazione() == pop, "il costruttore resta nella popolazione (%d su %d)" % [v.popolazione(), pop])

	# il cantiere non avanza finché il costruttore non è arrivato
	var avanzato_senza := false
	var visto_al_lavoro := false
	var foto := OS.get_environment("FOTO")
	Engine.time_scale = VELOCITA
	var prima := 0.0
	for k in 4000:
		await process_frame
		if seg == null or not is_instance_valid(seg) or seg.finito:
			break
		if seg.costruttore_al_lavoro():
			visto_al_lavoro = true
			if foto != "" and seg.progresso > 0.3:
				break
		elif seg.progresso > prima + 0.0001:
			avanzato_senza = true
		prima = seg.progresso
	_controlla(visto_al_lavoro, "il costruttore è arrivato al cantiere e martella")
	_controlla(not avanzato_senza, "senza costruttore il cantiere non avanza")
	if foto != "":
		Engine.time_scale = 1.0
		p.camera.set_process(false)
		p.camera.zoom = Vector2.ONE * 1.6
		p.camera.position = seg.position + Vector2(20, -20)
		for k in 10:
			await process_frame
		root.get_viewport().get_texture().get_image().save_png(foto)
		print("Screenshot salvato in ", foto)
		_fine()
		return
	for k in 40:
		if seg.finito:
			break
		await create_timer(5.0).timeout
	_controlla(seg.finito, "la segheria è finita")
	for k in 40:
		if v.costruttori == 0:
			break
		await create_timer(2.0).timeout
	Engine.time_scale = 1.0
	_controlla(v.costruttori == 0 and not is_instance_valid(seg.costruttore), "finito l'edificio il costruttore torna al magazzino")
	_controlla(v.popolazione() == pop, "la popolazione torna come prima (%d su %d)" % [v.popolazione(), pop])

	# cantiere demolito: il costruttore torna lo stesso
	var casa := _piazza("casa_greca", func(f): return -Vector2(f - mag.bandiera).length())
	_controlla(casa != null, "abitazione piazzata")
	for k in 5:
		await process_frame
	_controlla(casa != null and casa.costruttore != null and v.costruttori == 1, "anche l'abitazione ha il suo costruttore")
	# salvataggio con il costruttore per strada: torna tra i coloni liberi
	var liberi := v.coloni_liberi
	_controlla(Salvataggio.salva(p, FILE), "partita salvata col costruttore in cammino")
	var d: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(FILE))
	_controlla(int(d["coloni_liberi"]) >= liberi + 1, "nel salvataggio il costruttore conta come colono libero")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(FILE))
	v.demolisci(casa)
	Engine.time_scale = VELOCITA
	for k in 40:
		if v.costruttori == 0:
			break
		await create_timer(2.0).timeout
	Engine.time_scale = 1.0
	_controlla(v.costruttori == 0, "demolito il cantiere, il costruttore torna al magazzino")
	_fine()
