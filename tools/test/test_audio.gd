extends SceneTree
## Test automatico dello step M1: canali audio, suoni caricati, loop d'ambiente, e suoni di lavoro
## che partono davvero quando boscaiolo, cava, segheria e cantieri lavorano.
## Uso: godot --headless --path . --script tools/test/test_audio.gd

const VELOCITA := 8.0

var p: Node2D
var errori := 0
var audio: Node


func _initialize() -> void:
	_prova.call_deferred()


func _prova() -> void:
	audio = root.get_node_or_null("Audio")
	_controlla(audio != null, "autoload Audio presente")
	if audio == null:
		_fine()
		return
	for bus in ["Musica", "Effetti", "Ambiente"]:
		_controlla(AudioServer.get_bus_index(bus) >= 0, "canale " + bus)
	for nome in ["ascia", "piccone", "sega", "vanga", "martello", "albero_cade", "clic", "posa",
			"completato", "errore", "vento", "mare", "uccelli", "cicale"]:
		_controlla(audio.ha_suono(nome), "suono " + nome)
	for nome in ["vento", "mare", "uccelli", "cicale"]:
		var s: AudioStreamWAV = load("res://assets/suoni/%s.wav" % nome)
		_controlla(s.loop_mode != AudioStreamWAV.LOOP_DISABLED, "%s in loop (%.1fs)" % [nome, s.get_length()])
	audio.imposta_volume("Effetti", 0.5)
	_controlla(absf(audio.volume("Effetti") - 0.5) < 0.01, "volume del canale Effetti")
	audio.imposta_volume("Effetti", 1.0)

	p = load("res://src/mappa/partita.tscn").instantiate()
	root.add_child(p)
	await process_frame
	await process_frame
	var v: Villaggio = p.villaggio
	var ris: RisorseNaturali = p.risorse
	var mag: Edificio = null
	for e in v.edifici.values():
		if e.tipo == "magazzino":
			mag = e
	var bosc := _piazza("boscaiolo", func(f): return _conta_vicini(ris.alberi, f, 7))
	var cava := _piazza("cava", func(f): return _conta_vicini(ris.rocce, f, 7))
	var seg := _piazza("segheria", func(f): return -Vector2(f - mag.bandiera).length())
	for e in [bosc, cava, seg]:
		_controlla(e != null, "edificio piazzato")
	if errori > 0:
		_fine()
		return
	Engine.time_scale = VELOCITA
	for i in 10:
		await create_timer(30.0).timeout
		print("t=%3ds suonati=%s ambiente=%s" % [(i + 1) * 30, audio.suonati, audio._ambiente.keys()])
	Engine.time_scale = 1.0
	for nome in ["martello", "ascia", "cava", "albero_cade", "completato"]:
		_controlla(audio.suonati.get(nome, 0) > 0, "si è sentito " + nome)
	_controlla(audio._ambiente.has("uccelli") and audio._ambiente["uccelli"].playing, "uccelli in sottofondo")
	# musica: un brano della scaletta suona, alla fine passa al successivo, M la toglie e la rimette
	for nome in ["mattino", "lavoro", "sera"]:
		_controlla(ResourceLoader.exists("res://assets/musica/%s.ogg" % nome), "brano " + nome)
	var brano: String = audio.brano_attuale()
	_controlla(brano in ["mattino", "lavoro", "sera"] and audio._musica[0].playing, "musica in corso: " + brano)
	audio._on_brano_finito(audio._musica[0])
	_controlla(audio.brano_attuale() != brano and audio.brano_attuale() != "", "passa al brano successivo: " + audio.brano_attuale())
	_controlla(audio.alterna_musica() == false and AudioServer.is_bus_mute(AudioServer.get_bus_index("Musica")), "tasto M toglie la musica")
	_controlla(audio.alterna_musica() == true and not AudioServer.is_bus_mute(AudioServer.get_bus_index("Musica")), "tasto M rimette la musica")
	_fine()


## Cerca la casella migliore (secondo "punteggio" della sua bandierina) dove il tipo si può
## costruire e collegare con una strada a una bandierina già esistente; lo costruisce.
func _piazza(tipo: String, punteggio: Callable) -> Edificio:
	var v: Villaggio = p.villaggio
	var rete: ReteStrade = p.rete
	var d: DatiMappa = p.dati
	var candidati := []
	for y in d.altezza:
		for x in d.larghezza:
			var c := Vector2i(x, y)
			if not d.nel_territorio(x, y) or not v.puo_costruire(tipo, c):
				continue
			var s: int = CatalogoEdifici.dati(tipo)["taglia"]
			var f := Vector2i(c.x + (s - 1) / 2, c.y + s)
			candidati.append([punteggio.call(f), c, f])
	candidati.sort_custom(func(a, b): return a[0] > b[0])
	for k in mini(candidati.size(), 60):
		var c: Vector2i = candidati[k][1]
		var f: Vector2i = candidati[k][2]
		if not v.puo_costruire(tipo, c):
			continue
		var e := v.costruisci(tipo, c)
		if e == null:
			continue
		f = e.bandiera
		# strada dalla bandierina esistente più vicina che dà un percorso valido
		var bandiere: Array = rete.bandiere.keys().filter(func(b): return b != f)
		bandiere.sort_custom(func(a, b): return Vector2(a - f).length() < Vector2(b - f).length())
		for b in bandiere:
			var perc := rete.trova_percorso(b, f)
			if not perc.is_empty() and rete.costruisci_strada(perc):
				break
		if rete.collegata(e.bandiera):
			print("%s in %s (bandierina %s, punteggio %.1f)" % [tipo, c, f, candidati[k][0]])
			return e
		v.demolisci(e)
	print("Impossibile piazzare ", tipo)
	return null


func _conta_vicini(dove: Dictionary, f: Vector2i, raggio: int) -> float:
	var n := 0
	for c in dove:
		if Vector2(c - f).length() <= raggio:
			n += 1
	return n


func _controlla(ok: bool, cosa: String) -> void:
	print(("OK    " if ok else "ERRORE ") + cosa)
	if not ok:
		errori += 1


func _fine() -> void:
	print("RISULTATO: ", "tutto bene" if errori == 0 else "%d errori" % errori)
	quit(1 if errori > 0 else 0)
