extends SceneTree
## Test automatico dello step 27 (campagna «Il fuoco sotto la montagna»): si apre dopo la Soglia, si gioca
## con il popolo della Soglia sulla mappa di Zancle, la cenere dell'Etna brucia i campi, il finale segue
## la scelta della Soglia.
## Uso: godot --headless --path . --script tools/test/test_fuoco.gd

const PROGRESSI := "user://test_fuoco_progressi.json"

var errori := 0


func _initialize() -> void:
	_prova.call_deferred()


func _prova() -> void:
	Missione.progressi = PROGRESSI
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PROGRESSI))
	for m in Missione.CAMPAGNA_GRECI:
		Missione.segna_compiuta(m)
	_controlla(not Missione.sbloccata("fuoco_traversata"), "la Sicilia è chiusa finché non finisce la Soglia")
	for m in Missione.CAMPAGNA_SOGLIA:
		Missione.segna_compiuta(m)
	_controlla(Missione.sbloccata("fuoco_traversata") and not Missione.sbloccata("fuoco_zancle"), "finita la Soglia si apre «La traversata»")
	_controlla(Missione.sbloccata("naufragio") and Missione.sbloccata("soglia_velo"), "le campagne di prima restano aperte")
	_controlla(Missione.prossima(Missione.CAMPAGNA_FUOCO) == "fuoco_traversata", "la prossima è «La traversata»")

	var mappa = load("res://src/main/mappa_calabria.tscn").instantiate()
	root.add_child(mappa)
	await process_frame
	_controlla(not mappa._fuoco.disabled, "il pulsante della campagna siciliana è aperto")
	var dentro := Rect2(Vector2.ZERO, mappa.size).encloses(Rect2(mappa._fuoco.position, mappa._fuoco.size))
	_controlla(dentro, "il pulsante sta dentro lo schermo")
	mappa.queue_free()

	Missione.scegli_popolo_soglia("saraceni")
	Missione.segna_compiuta("fuoco_traversata")
	Missione.segna_compiuta("fuoco_zancle")
	Missione.segna_compiuta("fuoco_vasai")
	Impostazioni.missione = "fuoco_etna"
	var p = load("res://src/mappa/partita.tscn").instantiate()
	root.add_child(p)
	await process_frame
	await process_frame
	_controlla(p.popolo == "saraceni" and p.mappa == "zancle", "si gioca con il popolo della Soglia a Zancle (%s, %s)" % [p.popolo, p.mappa])
	var vicino: Vector2i = p.dati.villaggio + Vector2i(3, 6)
	for k in 12:
		var c := vicino + Vector2i(k % 4, k / 4)
		if p.dati.occupante(c.x, c.y) == 0 and p.dati.tipo(c.x, c.y) != DatiMappa.Terreno.ACQUA:
			p.risorse.semina(c)
	var campi: int = p.risorse.campi.size()
	p.missione._evento("lava")
	_controlla(campi > 0 and p.risorse.campi.is_empty(), "la cenere dell'Etna brucia i campi (%d → %d)" % [campi, p.risorse.campi.size()])
	p.queue_free()
	await process_frame

	var ultima := Missione.new()
	ultima.dati = Missione.MISSIONI["fuoco_cuore"]
	Missione.scegli_finale("conquista")
	_controlla(ultima.racconto_finale() == Missione.MISSIONI["fuoco_cuore"]["fine_conquista"], "dopo la conquista, il finale del fuoco è quello della Conquista")
	Missione.scegli_finale("unione")
	_controlla(ultima.racconto_finale() == Missione.MISSIONI["fuoco_cuore"]["fine_unione"], "dopo l'unione, il finale dell'Unione")
	ultima.free()
	for m in Missione.CAMPAGNA_FUOCO:
		_controlla(Missione.MISSIONI[m]["mappa"] == "zancle" and Missione.MISSIONI[m]["popolo"] == "scelto", "%s: a Zancle con il popolo scelto" % m)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PROGRESSI))
	Impostazioni.missione = ""
	Popoli.giocatore = "greci"
	print("RISULTATO: %s (%d errori)" % ["OK" if errori == 0 else "FALLITO", errori])
	quit(1 if errori > 0 else 0)


func _controlla(ok: bool, cosa: String) -> void:
	print(("  ok  " if ok else "  NO  ") + cosa)
	if not ok:
		errori += 1
