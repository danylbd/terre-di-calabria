extends "res://tools/test/test_catena.gd"
## Test automatico dello step 36b (voce di re Italo): le sillabe ci sono, Rocco della Lira parla sotto le
## sue battute (una sillaba o più per parola, poi tace), «Avanti» passa alla battuta dopo e alla fine
## del dialogo la voce si ferma.
## Uso: godot --headless --path . --script tools/test/test_voce.gd

var audio: Node


func _initialize() -> void:
	Impostazioni.popolo = "greci"
	Impostazioni.mappa = "costa_ionica"
	Impostazioni.modalita = "pace"
	Impostazioni.missione = "sfida_200"
	super._initialize()


func _prova() -> void:
	await process_frame
	audio = root.get_node_or_null("Audio")
	_controlla(audio != null and audio.ha_suono("voce_italo"), "ci sono le sillabe della voce di Italo")
	_controlla(audio._varianti.get("voce_italo", []).size() >= 12, "almeno 12 sillabe diverse")
	var pm: PannelloMissione = p.pannello_missione
	for k in 3:
		await process_frame
	_controlla(pm.dialogo_aperto(), "all'inizio della sfida parla Rocco della Lira")
	_controlla(audio.sta_parlando(), "e si sente la sua voce")
	# lascia finire la battuta
	for k in 60:
		await create_timer(0.25).timeout
		if not audio.sta_parlando():
			break
	var dette: int = audio.suonati.get("voce_italo", 0)
	_controlla(dette >= 8, "ha detto le sue sillabe (%d)" % dette)
	_controlla(not audio.sta_parlando(), "finita la battuta tace")

	# una battuta nuova: le sillabe seguono le parole, con un tetto per le parole lunghe
	audio.parla("voce_italo", "Sì, figlio mio. Io sono Italo.")
	_controlla(audio._discorso.size() == 8, "una sillaba per ogni parola corta, due per le medie (%d)" % audio._discorso.size())
	audio.parla("voce_italo", "Ascoltate")
	_controlla(audio._discorso.size() == 3, "tre sillabe per una parola lunga (%d)" % audio._discorso.size())
	audio.parla("voce_italo", "Chi va là?")
	_controlla(audio._discorso[-1][1] > audio._discorso[0][1], "sulle domande la voce sale")
	while pm.dialogo_aperto():
		pm.avanti()
	pm.mostra_dialogo([["Rocco della Lira", "Ascoltate, ascoltate."], ["Un pastore", "Eccomi."]])
	_controlla(audio.sta_parlando(), "Rocco parla nel dialogo")
	pm.avanti()
	_controlla(not audio.sta_parlando(), "chi non ha una voce parla solo per iscritto")
	pm.avanti()
	_controlla(not pm.dialogo_aperto() and not audio.sta_parlando(), "chiuso il dialogo la voce si ferma")
	_fine()
