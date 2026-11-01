extends SceneTree
## Test automatico dello step 33 (tipi di unità): ogni popolo ha il suo tipo di soldato; la cavalleria batte i
## tiratori, i tiratori la fanteria, la fanteria la cavalleria; i tiratori brettii attaccano da lontano e i loro
## sassi volano; i duelli della guerra di oggi tengono conto dei tipi.
## Uso: godot --headless --path . --script tools/test/test_tipi.gd (FOTO=file.png senza --headless)

const VELOCITA := 8.0

var p: Node2D
var errori := 0


func _initialize() -> void:
	Impostazioni.mappa = "costa_ionica"
	Impostazioni.modalita = "guerra"
	Impostazioni.missione = ""
	Impostazioni.popolo = "brettii"
	p = load("res://src/mappa/partita.tscn").instantiate()
	root.add_child(p)
	_prova.call_deferred()


func _prova() -> void:
	await process_frame
	_controlla(Popoli.tipo_soldato("greci") == "fanteria" and Popoli.tipo_soldato("brettii") == "tiratori"
		and Popoli.tipo_soldato("normanni") == "cavalleria", "ogni popolo ha il suo tipo (opliti, frombolieri, cavalieri)")
	_controlla(Popoli.TIPI_SOLDATO.size() == Popoli.DATI.size(), "tutti i popoli hanno un tipo")
	_controlla(Popoli.vantaggio_tipo("cavalleria", "tiratori") > 0 and Popoli.vantaggio_tipo("tiratori", "fanteria") > 0
		and Popoli.vantaggio_tipo("fanteria", "cavalleria") > 0, "la cavalleria batte i tiratori, i tiratori la fanteria, la fanteria la cavalleria")
	_controlla(Popoli.vantaggio_tipo("tiratori", "cavalleria") < 0 and is_equal_approx(Popoli.vantaggio_tipo("fanteria", "fanteria"), 0.0),
		"chi è battuto ha lo svantaggio, tra uguali nessuno")

	var v: Villaggio = p.villaggio
	var d: DatiMappa = p.dati
	var sch: Schiere = p.schiere
	_controlla(Schiere.tipo() == "tiratori" and Schiere.distanza_assalto() > Schiere.DISTANZA_ASSALTO, "la schiera dei Brettii è di tiratori e tira da lontano")
	var caserma: Edificio = null
	for y in range(d.villaggio.y - 6, d.villaggio.y + 7):
		for x in range(d.villaggio.x - 6, d.villaggio.x + 7):
			if caserma == null and v.puo_costruire("caserma", Vector2i(x, y)):
				caserma = v.costruisci("caserma", Vector2i(x, y), true, true)
	v.soldati = 12
	v.scorte["pane"] = 30
	sch.forma(caserma)
	# contro i Greci (fanteria) i frombolieri hanno il vantaggio
	var torre: Edificio = v.nemici.values()[0]
	_controlla(sch.probabilita_vittoria(Popoli.tipo_soldato(Popoli.di(torre.proprietario))) > sch.probabilita_vittoria("tiratori"),
		"contro gli opliti greci i frombolieri vincono più spesso")
	torre.soldati = 40
	_controlla(sch.attacca(torre), "ordine: attacca la torre greca")
	var vista_tiro := false
	var distanza_tiro := 0.0
	Engine.time_scale = VELOCITA
	for k in 60:
		await create_timer(1.0).timeout
		if not sch._proiettili.is_empty():
			vista_tiro = true
			distanza_tiro = sch.schiera["condottiero"].pos.distance_to(torre.centro())
			break
	Engine.time_scale = 1.0
	_controlla(vista_tiro, "i sassi dei frombolieri volano verso la torre")
	_controlla(distanza_tiro > Schiere.DISTANZA_ASSALTO, "e tirano da lontano (%.1f caselle)" % distanza_tiro)

	var foto := OS.get_environment("FOTO")
	if foto != "":
		p.camera.set_process(false)
		p.camera.zoom = Vector2.ONE * 0.9
		var c: Vector2 = (sch.schiera["condottiero"].pos + torre.centro()) * 0.5
		p.camera.position = d.a_schermo(c.x, c.y)
		for k in 6:
			await process_frame
		root.get_viewport().get_texture().get_image().save_png(foto)
		print("Screenshot salvato in ", foto)

	Impostazioni.popolo = "greci"
	Popoli.giocatore = "greci"
	Impostazioni.modalita = "pace_poi_guerra"
	print("RISULTATO: %s (%d errori)" % ["OK" if errori == 0 else "FALLITO", errori])
	quit(1 if errori > 0 else 0)


func _controlla(ok: bool, cosa: String) -> void:
	print(("  ok  " if ok else "  NO  ") + cosa)
	if not ok:
		errori += 1
