extends SceneTree
## Test automatico dello step 15 (modalità all'avvio): solo pace (niente Brettii), solo guerra (Brettii
## più forti e tregua breve), pace poi guerra (la guerra arriva quando il villaggio è cresciuto);
## la modalità si salva; il menu iniziale propone la scelta.
## Uso: godot --headless --path . --script tools/test/test_modalita.gd
## (FOTO=file.png senza --headless: screenshot del menu di scelta)

const FILE := "user://test_modalita.json"

var p: Node2D
var errori := 0


func _initialize() -> void:
	_prova.call_deferred()


func _nuova(modalita: String) -> void:
	if p:
		p.queue_free()
		await process_frame
	Impostazioni.modalita = modalita
	p = load("res://src/mappa/partita.tscn").instantiate()
	root.add_child(p)
	await process_frame
	await process_frame


func _prova() -> void:
	await _nuova("pace")
	_controlla(p.villaggio.nemici.is_empty() and not p.avversario.attivo, "solo pace: nessun Brettio")

	await _nuova("guerra")
	var av: Avversario = p.avversario
	_controlla(p.villaggio.nemici.size() == 2, "solo guerra: due avamposti")
	_controlla(p.villaggio.nemici.values().all(func(n): return n.soldati == 4), "solo guerra: avamposti con 4 difensori")
	_controlla(av.guerra_dichiarata and av.tregua == Avversario.TREGUA_GUERRA, "solo guerra: tregua breve (%d s)" % av.tregua)

	await _nuova("pace_poi_guerra")
	av = p.avversario
	_controlla(p.villaggio.nemici.size() == 2 and not av.guerra_dichiarata, "pace poi guerra: i Brettii ci sono ma sono in pace")
	Engine.time_scale = 8.0
	await create_timer(30.0).timeout
	_controlla(not av.guerra_dichiarata, "con un villaggio piccolo resta la pace")
	p.villaggio.coloni_liberi += 25
	await create_timer(5.0).timeout
	Engine.time_scale = 1.0
	_controlla(av.guerra_dichiarata, "il villaggio è cresciuto (%d coloni): i Brettii dichiarano guerra" % p.villaggio.popolazione())
	_controlla(av.tregua > av.tempo and av.tregua - av.tempo <= Avversario.PREAVVISO, "c'è un preavviso prima degli attacchi (%d s)" % (av.tregua - av.tempo))
	_controlla(p.pannello_villaggio != null, "pannello del villaggio presente")
	p.pannello_villaggio.alterna()
	await process_frame
	_controlla(p.pannello_villaggio._testo.text.contains("Pace, poi guerra"), "il pannello del villaggio dice la modalità")

	Salvataggio.salva(p, FILE)
	Impostazioni.modalita = "pace"
	p.queue_free()
	await process_frame
	Salvataggio.da_caricare = FILE
	p = load("res://src/mappa/partita.tscn").instantiate()
	root.add_child(p)
	await process_frame
	await process_frame
	_controlla(p.avversario.modalita == "pace_poi_guerra" and p.avversario.guerra_dichiarata and p.villaggio.nemici.size() == 2,
		"modalità e dichiarazione di guerra si salvano")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(FILE))
	p.queue_free()
	await process_frame

	# il menu iniziale propone la scelta
	var t = load("res://src/main/title_screen.tscn").instantiate()
	root.add_child(t)
	for k in 5:
		await process_frame
	t._mostra(t._strato_modalita)
	for k in 30:
		await process_frame
	var testi := []
	_raccogli_bottoni(t._strato_modalita, testi)
	_controlla("Solo pace" in testi and "Pace, poi guerra" in testi and "Solo guerra" in testi, "il menu propone le tre modalità %s" % [testi])
	var foto := OS.get_environment("FOTO")
	if foto != "":
		root.get_viewport().get_texture().get_image().save_png(foto)
		print("Screenshot salvato in ", foto)
	_fine()


func _raccogli_bottoni(n: Node, testi: Array) -> void:
	if n is Button:
		testi.append((n as Button).text)
	for k in n.get_children():
		_raccogli_bottoni(k, testi)


func _fine() -> void:
	print("RISULTATO: %s (%d errori)" % ["OK" if errori == 0 else "FALLITO", errori])
	Engine.time_scale = 1.0
	quit(1 if errori > 0 else 0)


func _controlla(ok: bool, cosa: String) -> void:
	print(("  ok  " if ok else "  NO  ") + cosa)
	if not ok:
		errori += 1
