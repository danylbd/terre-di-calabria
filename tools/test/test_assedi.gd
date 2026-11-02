extends SceneTree
## Test automatico dello step 36 (assedi): le torri nemiche hanno le mura, che crescono col tempo; l'armaiolo
## costruisce l'ariete e l'onagro (costano assi, pietre e armi) che seguono la schiera; l'onagro abbatte le mura
## da lontano, l'ariete da vicino; a mura giù si conquista la torre; il salvataggio ricorda le mura e rende i
## materiali delle macchine.
## Uso: godot --headless --path . --script tools/test/test_assedi.gd (FOTO=file.png senza --headless)

const VELOCITA := 8.0
const FILE := "user://test_assedi.json"

var p: Node2D
var errori := 0


func _initialize() -> void:
	Impostazioni.mappa = "monteleone"
	Impostazioni.modalita = "guerra"
	Impostazioni.missione = ""
	Impostazioni.popolo = "greci"
	p = load("res://src/mappa/partita.tscn").instantiate()
	root.add_child(p)
	_prova.call_deferred()


func _prova() -> void:
	await process_frame
	await process_frame
	var v: Villaggio = p.villaggio
	var d: DatiMappa = p.dati
	var sch: Schiere = p.schiere
	var torri: Array = v.nemici.values()
	_controlla(not torri.is_empty() and torri.all(func(n): return n.mura >= Schiere.MURA_INIZIO and n.mura < Schiere.MURA_INIZIO + 0.1), "le torri nemiche hanno le mura (%s)" % [torri.map(func(n): return n.mura)])
	# le mura crescono col tempo
	var t0: Edificio = torri[0]
	var prima := t0.mura
	sch._rinforza_mura(Schiere.RIFORZO_MURA * 2.0)
	_controlla(absf(t0.mura - prima - 2.0) < 0.01, "col tempo il nemico rialza le mura (%.1f)" % t0.mura)
	sch._rinforza_mura(Schiere.RIFORZO_MURA * 50.0)
	_controlla(t0.mura == Schiere.MURA_MAX, "fino a un massimo di %d" % Schiere.MURA_MAX)

	# caserma, armaiolo e schiera
	var caserma: Edificio = null
	var armaiolo: Edificio = null
	for y in range(d.villaggio.y - 9, d.villaggio.y + 10):
		for x in range(d.villaggio.x - 9, d.villaggio.x + 10):
			if caserma == null and v.puo_costruire("caserma", Vector2i(x, y)):
				caserma = v.costruisci("caserma", Vector2i(x, y), true, true)
			elif armaiolo == null and v.puo_costruire("armaiolo", Vector2i(x, y)):
				armaiolo = v.costruisci("armaiolo", Vector2i(x, y), true, true)
	_controlla(caserma != null and armaiolo != null, "caserma e armaiolo costruiti")
	_controlla(sch.motivo_no_macchina("ariete").begins_with("Serve una schiera"), "senza schiera niente macchine")
	v.soldati = 12
	v.scorte["pane"] = 40
	_controlla(sch.forma(caserma), "il condottiero esce con la schiera")
	v.scorte["assi"] = 9
	v.scorte["pietra"] = 3
	v.scorte["armi"] = 1
	_controlla(sch.motivo_no_macchina("ariete") == "", "con assi e armi l'ariete si può costruire")
	_controlla(sch.costruisci_macchina("ariete", armaiolo), "l'armaiolo costruisce l'ariete")
	_controlla(v.scorte["assi"] == 4 and v.scorte["armi"] == 0, "l'ariete costa 5 assi e 1 arma")
	_controlla(sch.motivo_no_macchina("ariete").contains("già"), "un ariete solo per schiera")
	_controlla(sch.motivo_no_macchina("onagro").begins_with("Servono"), "senza armi niente onagro")
	v.scorte["armi"] = 1
	_controlla(sch.costruisci_macchina("onagro", armaiolo), "l'armaiolo costruisce l'onagro")
	_controlla(sch.macchine().size() == 2, "la schiera ha ariete e onagro")
	_controlla(ResourceLoader.exists("res://assets/grafica/ariete.png") and ResourceLoader.exists("res://assets/grafica/onagro_tiro.png"),
		"ci sono gli sprite dell'ariete e dell'onagro")

	# salvataggio: le mura restano, le macchine tornano assi, pietre e armi
	var torre: Edificio = t0
	torre.mura = 6.0
	_controlla(Salvataggio.salva(p, FILE), "partita salvata con le macchine")
	var dati_file: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(FILE))
	_controlla(int(dati_file["scorte"]["assi"]) == v.scorte["assi"] + 9 and int(dati_file["scorte"]["armi"]) == v.scorte["armi"] + 2,
		"nel salvataggio le macchine tornano materiali")
	_controlla(dati_file["nemici"].any(func(n): return n.size() > 5 and float(n[5]) == 6.0), "nel salvataggio ci sono le mura")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(FILE))

	# l'assedio: la torre più vicina, con le mura alte
	var capo: Colono = sch.schiera["condottiero"]
	torri.sort_custom(func(a, b): return a.centro().distance_to(capo.pos) < b.centro().distance_to(capo.pos))
	torre = torri[0]
	torre.mura = 6.0
	torre.soldati = 2
	var id_torre := torre.id
	var casella_torre := torre.casella
	sch._rng.seed = 5
	sch.schiera["razioni"] = Schiere.RAZIONI_MAX
	Engine.time_scale = VELOCITA
	await create_timer(6.0).timeout       # le macchine raggiungono la schiera
	_controlla(sch.attacca(torre), "ordine: assedia la torre in %s" % casella_torre)
	var mura_giu := false
	var tiro_visto := false
	var colpo_visto := false
	var foto := OS.get_environment("FOTO")
	for k in 400:
		await create_timer(0.5).timeout
		if not sch.esiste() or not v.nemici.has(id_torre):
			break
		if not sch._massi.is_empty():
			tiro_visto = true
		var ar: Colono = sch.macchine().get("ariete")
		if ar and ar._foglio == "ariete_colpo":
			colpo_visto = true
		if torre.mura <= 0.0:
			mura_giu = true
		if foto != "" and tiro_visto and colpo_visto:
			break
	Engine.time_scale = 1.0
	if foto != "":
		p.camera.set_process(false)
		p.camera.zoom = Vector2.ONE * 2.0
		var on: Colono = sch.macchine().get("onagro")
		p.camera.position = torre.position.lerp(on.position if on else torre.position, 0.5)
		for k in 10:
			await process_frame
		root.get_viewport().get_texture().get_image().save_png(foto)
		print("Screenshot salvato in ", foto)
		quit(0)
		return
	_controlla(tiro_visto, "l'onagro ha tirato i suoi sassi")
	_controlla(colpo_visto, "l'ariete ha battuto sulle mura")
	_controlla(mura_giu or not v.nemici.has(id_torre), "le mura sono crollate")
	var nostra := v.edificio_in(casella_torre)
	_controlla(nostra != null and nostra.proprietario == 1, "la torre è conquistata (rimasti %d soldati)" % sch.soldati())

	# senza macchine si assedia lo stesso, ma è più lento e si rischia
	if sch.esiste():
		sch._perdi_macchine()
		_controlla(sch.macchine().is_empty(), "macchine perse")
	Impostazioni.modalita = "pace"
	_controlla(not Schiere.attive() and sch.motivo_no_macchina("ariete") != "", "in pace niente macchine d'assedio")
	Impostazioni.modalita = "pace_poi_guerra"
	Impostazioni.mappa = "costa_ionica"
	print("RISULTATO: %s (%d errori)" % ["OK" if errori == 0 else "FALLITO", errori])
	quit(1 if errori > 0 else 0)


func _controlla(ok: bool, cosa: String) -> void:
	print(("  ok  " if ok else "  NO  ") + cosa)
	if not ok:
		errori += 1
