extends SceneTree
## Test automatico della musica nuova (FluidSynth + GeneralUser GS): i quattro brani ci sono, sono Ogg lunghi
## più di un minuto; in battaglia (la schiera all'assalto) parte la musica di guerra, e dopo un po' di calma
## torna quella del villaggio.
## Uso: godot --headless --path . --script tools/test/test_musica.gd

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
	for nome in ["mattino", "lavoro", "sera", "guerra"]:
		var s = load("res://assets/musica/%s.ogg" % nome)
		_controlla(s is AudioStreamOggVorbis and s.get_length() > 60.0, "brano %s (%.0f s)" % [nome, s.get_length() if s else 0.0])
	var audio := root.get_node("Audio")
	_controlla(audio.brano_attuale() in ["mattino", "lavoro", "sera"], "nel villaggio suona un brano del villaggio (%s)" % audio.brano_attuale())
	# la schiera all'assalto
	var v: Villaggio = p.villaggio
	var sch: Schiere = p.schiere
	var d: DatiMappa = p.dati
	var caserma: Edificio = null
	for y in range(d.villaggio.y - 8, d.villaggio.y + 9):
		for x in range(d.villaggio.x - 8, d.villaggio.x + 9):
			if caserma == null and v.puo_costruire("caserma", Vector2i(x, y)):
				caserma = v.costruisci("caserma", Vector2i(x, y), true, true)
	v.soldati = 6
	_controlla(caserma != null and sch.forma(caserma), "la schiera esce")
	_controlla(sch.attacca(v.nemici.values()[0]), "la schiera va all'assalto")
	p._aggiorna_musica(0.5)
	_controlla(audio.brano_attuale() == "guerra", "in battaglia suona la musica di guerra")
	sch.schiera["bersaglio"] = null
	p._aggiorna_musica(5.0)
	_controlla(audio.brano_attuale() == "guerra", "subito dopo la battaglia la musica di guerra continua")
	p._aggiorna_musica(p.CALMA)
	_controlla(audio.brano_attuale() in ["mattino", "lavoro", "sera"], "dopo la calma torna la musica del villaggio (%s)" % audio.brano_attuale())
	Impostazioni.modalita = "pace_poi_guerra"
	Impostazioni.mappa = "costa_ionica"
	print("RISULTATO: %s (%d errori)" % ["OK" if errori == 0 else "FALLITO", errori])
	quit(1 if errori > 0 else 0)


func _controlla(ok: bool, cosa: String) -> void:
	print(("  ok  " if ok else "  NO  ") + cosa)
	if not ok:
		errori += 1
