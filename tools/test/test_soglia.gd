extends SceneTree
## Test automatico dello step 23 (campagna finale «La Soglia»): si apre dopo la campagna dei Greci,
## il popolo scelto vale per tutta la campagna, si gioca a Monteleone, la scelta «unire» o «conquistare»
## fissa il finale e il racconto di chiusura corrisponde.
## Uso: godot --headless --path . --script tools/test/test_soglia.gd (FOTO=file.png senza --headless)

const PROGRESSI := "user://test_soglia_progressi.json"

var errori := 0


func _initialize() -> void:
	_prova.call_deferred()


func _prova() -> void:
	Missione.progressi = PROGRESSI
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PROGRESSI))
	_controlla(not Missione.sbloccata("soglia_velo"), "la Soglia è chiusa finché non finisce la campagna dei Greci")
	for m in Missione.CAMPAGNA_GRECI:
		Missione.segna_compiuta(m)
	_controlla(Missione.sbloccata("soglia_velo") and not Missione.sbloccata("soglia_frammenti"), "finiti i Greci si apre la prima missione della Soglia")
	_controlla(Missione.prossima_soglia() == "soglia_velo", "la prossima è «Il velo sulla Soglia»")

	# la mappa della Calabria: pulsante e scelta del popolo
	var mappa = load("res://src/main/mappa_calabria.tscn").instantiate()
	root.add_child(mappa)
	await process_frame
	_controlla(not mappa._soglia.disabled, "il pulsante «La Soglia» è aperto")
	mappa._apri_soglia()
	_controlla(mappa._scelta_popolo.visible, "alla prima missione si sceglie il popolo")
	var foto := OS.get_environment("FOTO")
	if foto != "":
		for k in 5:
			await process_frame
		root.get_viewport().get_texture().get_image().save_png(foto)
		print("Screenshot salvato in ", foto)
	mappa.queue_free()
	Missione.scegli_popolo_soglia("romani")
	Missione.segna_compiuta("soglia_velo")
	Missione.segna_compiuta("soglia_frammenti")

	# la missione della scelta, con i Romani a Monteleone
	Impostazioni.missione = "soglia_scelta"
	Impostazioni.popolo = "greci"
	var p = load("res://src/mappa/partita.tscn").instantiate()
	root.add_child(p)
	await process_frame
	await process_frame
	_controlla(p.popolo == "romani" and p.mappa == "monteleone", "si gioca con il popolo scelto sulla mappa di Monteleone (%s, %s)" % [p.popolo, p.mappa])
	_controlla(p.villaggio.nemici.size() >= 2, "ci sono i vicini ostili (%d torri)" % p.villaggio.nemici.size())
	var mis: Missione = p.missione
	var scelta: Dictionary = mis.obiettivi()[0]
	_controlla(not mis.raggiunto(scelta), "all'inizio la scelta non è fatta")
	p.villaggio.scorte["tegole"] = 8
	p.villaggio.scorte["olio"] = 4
	_controlla(mis.raggiunto(scelta) and Missione.finale() == "unione", "12 merci di lusso da donare: si sceglie di unire")
	p.villaggio.scorte["tegole"] = 0
	p.villaggio.scorte["olio"] = 0
	Missione.scegli_finale("unione")
	p.villaggio.rimuovi_nemico(p.villaggio.nemici.values()[0])
	_controlla(mis.raggiunto(scelta) and Missione.finale() == "conquista", "una torre nemica conquistata: si sceglie di conquistare")
	p.queue_free()
	await process_frame

	# il finale
	var ultima := Missione.new()
	ultima.dati = Missione.MISSIONI["soglia_sigillo"]
	_controlla(ultima.racconto_finale() == Missione.MISSIONI["soglia_sigillo"]["fine_conquista"], "con la conquista il finale è quello della Conquista")
	Missione.scegli_finale("unione")
	_controlla(ultima.racconto_finale() == Missione.MISSIONI["soglia_sigillo"]["fine_unione"], "con l'unione il finale è quello dell'Unione")
	ultima.free()
	for m in Missione.CAMPAGNA_SOGLIA:
		Missione.segna_compiuta(m)
	_controlla(Missione.prossima_soglia() == "" and Missione.popolo_soglia() == "romani", "campagna compiuta, il popolo resta ricordato")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PROGRESSI))
	Impostazioni.missione = ""
	Popoli.giocatore = "greci"
	print("RISULTATO: %s (%d errori)" % ["OK" if errori == 0 else "FALLITO", errori])
	quit(1 if errori > 0 else 0)


func _controlla(ok: bool, cosa: String) -> void:
	print(("  ok  " if ok else "  NO  ") + cosa)
	if not ok:
		errori += 1
