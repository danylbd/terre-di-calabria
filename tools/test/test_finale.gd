extends SceneTree
## Test automatico dello step 29 (epilogo «L'ultimo canto»): si apre dopo «Il cuore del fuoco», si gioca a
## Monteleone con il popolo della Soglia, ha il porto tra gli obiettivi, e il finale (con la rivelazione di
## Rocco) segue la scelta della Soglia.
## Uso: godot --headless --path . --script tools/test/test_finale.gd

const PROGRESSI := "user://test_finale_progressi.json"

var errori := 0


func _initialize() -> void:
	_prova.call_deferred()


func _prova() -> void:
	Missione.progressi = PROGRESSI
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PROGRESSI))
	for m in Missione.CAMPAGNA_GRECI + Missione.CAMPAGNA_SOGLIA:
		Missione.segna_compiuta(m)
	_controlla(not Missione.sbloccata("ultimo_canto"), "l'epilogo è chiuso finché non finisce la Sicilia")
	for m in Missione.CAMPAGNA_FUOCO:
		Missione.segna_compiuta(m)
	_controlla(Missione.sbloccata("ultimo_canto"), "finita la Sicilia si apre «L'ultimo canto»")

	var mappa = load("res://src/main/mappa_calabria.tscn").instantiate()
	root.add_child(mappa)
	await process_frame
	_controlla(not mappa._canto.disabled and Rect2(Vector2.ZERO, mappa.size).encloses(Rect2(mappa._canto.position, mappa._canto.size)),
		"il pulsante dell'epilogo è aperto e dentro lo schermo")
	_controlla(not mappa._canto.get_rect().intersects(mappa._soglia.get_rect()), "non copre il pulsante della Soglia")
	mappa.queue_free()

	Missione.scegli_popolo_soglia("normanni")
	Impostazioni.missione = "ultimo_canto"
	var p = load("res://src/mappa/partita.tscn").instantiate()
	root.add_child(p)
	await process_frame
	await process_frame
	_controlla(p.popolo == "normanni" and p.mappa == "monteleone", "si gioca con il popolo della Soglia a Monteleone")
	_controlla(p.missione.obiettivi().any(func(o): return o.get("tipo", "") == "porto"), "tra gli obiettivi c'è il porto")
	_controlla(p.villaggio.scorte.get("anfore", 0) >= 6, "ci sono le anfore per i primi viaggi")
	p.queue_free()
	await process_frame

	var m := Missione.new()
	m.dati = Missione.MISSIONI["ultimo_canto"]
	Missione.scegli_finale("unione")
	var unione: Array = m.racconto_finale()
	Missione.scegli_finale("conquista")
	var conquista: Array = m.racconto_finale()
	m.free()
	_controlla(unione != conquista and unione.size() >= 3, "due finali diversi")
	var svela := func(r: Array): return r.any(func(b): return b[0] == "Rocco della Lira" and b[1].contains("Io sono Italo"))
	_controlla(svela.call(unione) and svela.call(conquista), "in tutti e due Rocco si svela: è Italo")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PROGRESSI))
	Impostazioni.missione = ""
	Popoli.giocatore = "greci"
	print("RISULTATO: %s (%d errori)" % ["OK" if errori == 0 else "FALLITO", errori])
	quit(1 if errori > 0 else 0)


func _controlla(ok: bool, cosa: String) -> void:
	print(("  ok  " if ok else "  NO  ") + cosa)
	if not ok:
		errori += 1
