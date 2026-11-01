extends SceneTree
## Test automatico dello step 34 (abilità dei condottieri): ogni popolo ha due abilità; si imparano ai livelli
## 2 e 4; hanno effetto (duelli, morale, passo) e una ricarica; il pannello della schiera le mostra e i
## tasti 1 e 2 le usano.
## Uso: godot --headless --path . --script tools/test/test_abilita.gd (FOTO=file.png senza --headless)

var p: Node2D
var errori := 0


func _initialize() -> void:
	Impostazioni.mappa = "costa_ionica"
	Impostazioni.modalita = "guerra"
	Impostazioni.missione = ""
	Impostazioni.popolo = "saraceni"
	p = load("res://src/mappa/partita.tscn").instantiate()
	root.add_child(p)
	_prova.call_deferred()


func _prova() -> void:
	await process_frame
	_controlla(Popoli.DATI.keys().all(func(k): return Schiere.ABILITA.has(k) and Schiere.ABILITA[k].size() == 2), "ogni popolo ha due abilità")
	var v: Villaggio = p.villaggio
	var d: DatiMappa = p.dati
	var sch: Schiere = p.schiere
	var caserma: Edificio = null
	for y in range(d.villaggio.y - 6, d.villaggio.y + 7):
		for x in range(d.villaggio.x - 6, d.villaggio.x + 7):
			if caserma == null and v.puo_costruire("caserma", Vector2i(x, y)):
				caserma = v.costruisci("caserma", Vector2i(x, y), true, true)
	v.soldati = 12
	v.scorte["pane"] = 30
	sch.forma(caserma)
	sch.scegli(true)
	_controlla(sch.motivo_no_abilita(0).contains("livello 2") and not sch.usa_abilita(0), "al livello 1 le abilità non ci sono ancora")
	sch.esperienza = Schiere.ESPERIENZA_LIVELLO
	_controlla(sch.livello() == 2 and sch.motivo_no_abilita(0) == "" and sch.motivo_no_abilita(1).contains("livello 4"), "al livello 2 si impara la prima")

	# Zahra: carica rapida (passo) e grido del deserto (duelli)
	_controlla(sch.usa_abilita(0) and is_equal_approx(sch.schiera["condottiero"].velocita, 1.6), "carica rapida: la schiera corre (velocità 1,6)")
	_controlla(not sch.usa_abilita(0) and sch.motivo_no_abilita(0).begins_with("Pronta tra"), "poi c'è la ricarica")
	sch._process(16.0)
	_controlla(is_equal_approx(sch.schiera["condottiero"].velocita, 1.0), "finito l'effetto si torna al passo normale")
	sch.esperienza = Schiere.ESPERIENZA_LIVELLO * 3
	var prima := sch.probabilita_vittoria()
	_controlla(sch.usa_abilita(1) and sch.probabilita_vittoria() > prima + 0.1, "grido del deserto: duelli più facili (%.2f → %.2f)" % [prima, sch.probabilita_vittoria()])
	sch._process(Schiere.RICARICA + 1.0)
	_controlla(sch.motivo_no_abilita(0) == "" and is_equal_approx(sch.bonus_attivo(), 0.0), "dopo un minuto si possono riusare e l'effetto è finito")

	# il pannello della schiera e il tasto 1
	var pan: PannelloSchiera = p.pannello_schiera
	pan._aggiorna = 0.0
	pan._process(0.1)
	_controlla(pan.visible and pan._testo.text.begins_with("Zahra") and pan._pulsanti[0].text.contains("Carica rapida"), "il pannello mostra Zahra e le sue abilità")
	var tasto := InputEventKey.new()
	tasto.keycode = KEY_1
	tasto.pressed = true
	p._unhandled_input(tasto)
	_controlla(sch.motivo_no_abilita(0).begins_with("Pronta tra"), "il tasto 1 usa la prima abilità")

	# un'abilità di morale (Normanni)
	Impostazioni.popolo = "normanni"
	Popoli.giocatore = "normanni"
	sch.schiera["morale"] = 40
	sch._ricarica = [0.0, 0.0]
	_controlla(sch.usa_abilita(0) and sch.schiera["morale"] == 65, "giuramento di Osmund: morale +25")

	var foto := OS.get_environment("FOTO")
	if foto != "":
		p.camera.set_process(false)
		p.camera.zoom = Vector2.ONE
		p.camera.position = d.a_schermo(sch.schiera["condottiero"].pos.x, sch.schiera["condottiero"].pos.y)
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
