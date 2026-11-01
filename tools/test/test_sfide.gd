extends SceneTree
## Test automatico delle sfide: sempre aperte, popolo e mappa giusti, il cronometro corre e si vede nel
## pannello, il record tiene il tempo migliore, il menu iniziale le elenca.
## Uso: godot --headless --path . --script tools/test/test_sfide.gd

const PROGRESSI := "user://test_sfide_progressi.json"

var errori := 0


func _initialize() -> void:
	_prova.call_deferred()


func _prova() -> void:
	Missione.progressi = PROGRESSI
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PROGRESSI))
	_controlla(Missione.SFIDE.all(func(s): return Missione.sbloccata(s)), "tutte le sfide sono aperte da subito")
	_controlla(Missione.record("sfida_200") < 0.0, "all'inizio nessun record")
	Missione.segna_record("sfida_200", 900.0)
	Missione.segna_record("sfida_200", 1200.0)
	Missione.segna_record("sfida_200", 600.0)
	_controlla(is_equal_approx(Missione.record("sfida_200"), 600.0) and Missione.testo_tempo(600.0) == "10:00", "il record tiene il tempo migliore (10:00)")

	# il popolo: libero = quello scelto nel menu, oppure fissato dalla sfida
	Impostazioni.popolo = "normanni"
	Impostazioni.missione = "sfida_200"
	var p = load("res://src/mappa/partita.tscn").instantiate()
	root.add_child(p)
	await process_frame
	await process_frame
	_controlla(p.popolo == "normanni" and p.mappa == "costa_ionica", "«Nutri 200 abitanti» con il popolo scelto (%s)" % p.popolo)
	while p.pannello_missione.dialogo_aperto():
		p.pannello_missione.avanti()          # durante il racconto il gioco è in pausa
	var t0: float = p.missione.tempo
	for k in 30:
		await process_frame
	_controlla(p.missione.tempo > t0, "il cronometro corre (%.2f s)" % p.missione.tempo)
	p.pannello_missione.aggiorna()
	_controlla(p.pannello_missione._obiettivi.text.contains("Tempo") and p.pannello_missione._obiettivi.text.contains("record 10:00"), "il pannello mostra tempo e record")
	p.queue_free()
	await process_frame

	Impostazioni.missione = "sfida_seta"
	p = load("res://src/mappa/partita.tscn").instantiate()
	root.add_child(p)
	await process_frame
	await process_frame
	_controlla(p.popolo == "saraceni" and p.mappa == "zancle", "«La seta da un mare all'altro» con i Saraceni a Zancle")
	p.queue_free()
	await process_frame

	var titolo = load("res://src/main/title_screen.tscn").instantiate()
	root.add_child(titolo)
	await process_frame
	var testi := []
	_bottoni(titolo._strato_sfide, testi)
	_controlla(testi.filter(func(t): return t.begins_with("Nutri") or t.begins_with("La seta") or t.begins_with("Sopravvivi")).size() == 3,
		"il menu elenca le tre sfide %s" % [testi])
	_controlla(testi.any(func(t): return t.contains("record 10:00")), "e mostra il record")
	titolo.queue_free()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PROGRESSI))
	Impostazioni.missione = ""
	Impostazioni.popolo = "greci"
	Popoli.giocatore = "greci"
	print("RISULTATO: %s (%d errori)" % ["OK" if errori == 0 else "FALLITO", errori])
	quit(1 if errori > 0 else 0)


func _bottoni(n: Node, testi: Array) -> void:
	if n is Button:
		testi.append((n as Button).text)
	for k in n.get_children():
		_bottoni(k, testi)


func _controlla(ok: bool, cosa: String) -> void:
	print(("  ok  " if ok else "  NO  ") + cosa)
	if not ok:
		errori += 1
