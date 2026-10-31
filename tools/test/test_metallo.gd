extends SceneTree
## Test automatico dello step 07 (metallo): miniera di ferro sulla montagna (con il cibo per i minatori),
## carbonaia, fonderia e fabbro. Senza asce in magazzino il boscaiolo aspetta, finché il fabbro non ne forgia una.
## Uso: godot --headless --path . --script tools/test/test_metallo.gd
## (MINUTI=n per la durata in mezzi minuti di gioco, FOTO=file.png senza --headless per lo screenshot)

const VELOCITA := 8.0

var p: Node2D
var errori := 0


func _initialize() -> void:
	p = load("res://src/mappa/partita.tscn").instantiate()
	root.add_child(p)
	_prova.call_deferred()


func _prova() -> void:
	await process_frame
	var v: Villaggio = p.villaggio
	var d: DatiMappa = p.dati
	var ris: RisorseNaturali = p.risorse
	v.scorte["pane"] = 6
	v.scorte["pesce"] = 6
	v.scorte["assi"] = 40
	v.scorte["pietra"] = 30
	v.scorte["ascia"] = 0
	var mag: Edificio = null
	for e in v.edifici.values():
		if e.tipo == "magazzino":
			mag = e
	_controlla(ris.minerali["ferro"].size() > 20, "ferro nascosto nella roccia (%d caselle)" % ris.minerali["ferro"].size())
	# torri già finite verso la montagna finché la miniera non si può costruire
	var miniera: Edificio = null
	for k in 3:
		var torre := _piazza("torre", func(f): return -_distanza_ferro(f), true)
		_controlla(torre != null, "torre verso la montagna")
		miniera = _piazza("miniera_ferro", func(f): return ris.minerale_vicino(f + Vector2i(0, -1), "ferro") * 0.2 - Vector2(f - mag.bandiera).length() * 0.3)
		if miniera:
			break
	var carb := _piazza("carbonaia", func(f): return -Vector2(f - mag.bandiera).length())
	var fond := _piazza("fonderia", func(f): return -Vector2(f - mag.bandiera).length())
	var fabb := _piazza("fabbro", func(f): return -Vector2(f - mag.bandiera).length())
	var bosc := _piazza("boscaiolo", func(f): return _conta_vicini(ris.alberi, f, 7))
	for e in [miniera, carb, fond, fabb, bosc]:
		_controlla(e != null, "edificio piazzato")
	if errori > 0:
		_fine()
		return
	var ferro_0 := ris.minerale_vicino(Vector2i(miniera.centro()), "ferro")
	Engine.time_scale = VELOCITA
	var mezzi_minuti := int(OS.get_environment("MINUTI")) if OS.get_environment("MINUTI") != "" else 24
	var aspettava := false
	for k in mezzi_minuti:
		await create_timer(30.0).timeout
		if bosc.finito and bosc.lavoratore == null and bosc.manca_attrezzo:
			aspettava = true
		var s := []
		for r in ["pane", "pesce", "tronchi", "ferro", "carbone", "lingotti", "ascia", "piccone"]:
			s.append("%s=%d" % [r, v.scorte.get(r, 0)])
		var stato := []
		for e in [miniera, carb, fond, fabb, bosc]:
			stato.append("%s:%s%s%s" % [e.tipo, "ok" if e.finito else "%.0f%%" % (e.progresso * 100),
				"" if e.lavoratore == null else "(L)", "" if e.ingresso.is_empty() else str(e.ingresso)])
		print("t=%3ds %s | %s" % [(k + 1) * 30, " ".join(s), " ".join(stato)])
	_controlla(ris.minerale_vicino(Vector2i(miniera.centro()), "ferro") < ferro_0, "la miniera ha scavato il giacimento")
	_controlla(v.scorte["pane"] + v.scorte["pesce"] < 12, "i minatori hanno mangiato")
	_controlla(aspettava, "il boscaiolo ha aspettato l'ascia")
	_controlla(bosc.lavoratore != null, "il fabbro ha forgiato l'ascia e il boscaiolo lavora")
	var foto := OS.get_environment("FOTO")
	if foto != "":
		var centro := (miniera.centro() + carb.centro() + fond.centro() + fabb.centro()) / 4.0
		p.camera.position = d.a_schermo(centro.x, centro.y)
		Engine.time_scale = 1.0
		for k in 10:
			await process_frame
		root.get_viewport().get_texture().get_image().save_png(foto)
		print("Screenshot salvato in ", foto)
	_fine()


func _distanza_ferro(f: Vector2i) -> float:
	var migliore := 99.0
	for c in p.risorse.minerali["ferro"]:
		migliore = minf(migliore, Vector2(c - f).length())
	return migliore


func _conta_vicini(dove: Dictionary, f: Vector2i, raggio: int) -> float:
	var n := 0
	for c in dove:
		if Vector2(c - f).length() <= raggio:
			n += 1
	return n


func _fine() -> void:
	print("RISULTATO: %s (%d errori)" % ["OK" if errori == 0 else "FALLITO", errori])
	Engine.time_scale = 1.0
	quit(1 if errori > 0 else 0)


func _controlla(ok: bool, cosa: String) -> void:
	print(("  ok  " if ok else "  NO  ") + cosa)
	if not ok:
		errori += 1


## Caselle libere di prato vicino alla bandierina (spazio per i campi).
func _prato_libero(f: Vector2i, raggio: int) -> float:
	var d: DatiMappa = p.dati
	var n := 0
	for y in range(f.y - raggio, f.y + raggio + 1):
		for x in range(f.x - raggio, f.x + raggio + 1):
			if d.dentro(x, y) and d.nel_territorio(x, y) and d.occupante(x, y) == 0 \
					and d.tipo(x, y) in [DatiMappa.Terreno.PRATO, DatiMappa.Terreno.SECCO, DatiMappa.Terreno.TERRA]:
				n += 1
	return n


func _distanza_acqua(f: Vector2i) -> float:
	var d: DatiMappa = p.dati
	var migliore := 99.0
	for y in range(f.y - 20, f.y + 21):
		for x in range(f.x - 20, f.x + 21):
			if d.dentro(x, y) and d.tipo(x, y) == DatiMappa.Terreno.ACQUA:
				migliore = minf(migliore, Vector2(Vector2i(x, y) - f).length())
	return migliore


func _conta_acqua(f: Vector2i, raggio: int) -> float:
	var d: DatiMappa = p.dati
	var n := 0
	for y in range(f.y - raggio, f.y + raggio + 1):
		for x in range(f.x - raggio, f.x + raggio + 1):
			if d.dentro(x, y) and d.tipo(x, y) == DatiMappa.Terreno.ACQUA:
				n += 1
	return mini(n, 12)


## Cerca la casella migliore (secondo "punteggio" della sua bandierina) dove il tipo si può
## costruire e collegare con una strada a una bandierina già esistente; lo costruisce.
func _piazza(tipo: String, punteggio: Callable, gia_finito := false) -> Edificio:
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
		var e := v.costruisci(tipo, c, gia_finito)
		if e == null:
			continue
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
