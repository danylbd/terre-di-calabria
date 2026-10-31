extends SceneTree
## Test automatico dello step 06 (colture e pesca al largo): vigneto e cantina, ortolano, agrumeto,
## raccoglitore di olive e frantoio, barca del pesce spada (con una torre che allarga i confini verso il mare).
## Uso: godot --headless --path . --script tools/test/test_colture.gd
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
	var mag: Edificio = null
	for e in v.edifici.values():
		if e.tipo == "magazzino":
			mag = e
	# torri già finite verso il mare finché la barca non si può costruire sulla costa
	var spada: Edificio = null
	for k in 3:
		var torre := _piazza("torre", func(f): return -_distanza_acqua(f), true)
		_controlla(torre != null, "torre verso il mare")
		spada = _piazza("pesca_spada", func(f): return -_distanza_acqua(f) - Vector2(f - mag.bandiera).length() * 0.05)
		if spada:
			break
	var uliv := _piazza("uliveto", func(f): return _conta_vicini(ris.ulivi, f, 6) - Vector2(f - mag.bandiera).length() * 0.3)
	var edifici := [spada, uliv]
	for tipo in ["frantoio", "cantina", "vigneto", "ortolano", "agrumeto"]:
		var punteggio := func(f): return -Vector2(f - mag.bandiera).length()
		if tipo in ["vigneto", "ortolano", "agrumeto"]:
			punteggio = func(f): return _prato_libero(f, 4) - Vector2(f - mag.bandiera).length() * 0.5
		edifici.append(_piazza(tipo, punteggio))
	for e in edifici:
		_controlla(e != null, "edificio piazzato")
	if errori > 0:
		_fine()
		return
	Engine.time_scale = VELOCITA
	var mezzi_minuti := int(OS.get_environment("MINUTI")) if OS.get_environment("MINUTI") != "" else 24
	var in_barca := false
	for k in mezzi_minuti * 6:
		await create_timer(5.0).timeout
		var l: Lavoratore = spada.lavoratore
		if l and l._foglio == "barca_remi":
			in_barca = true
		if k % 6 != 5:
			continue
		var s := []
		for r in ["olive", "olio", "uva", "vino", "ortaggi", "cipolle", "agrumi", "pesce_spada"]:
			s.append("%s=%d" % [r, v.scorte.get(r, 0)])
		var colture := {}
		for c in ris.campi.values():
			colture[c["coltura"]] = colture.get(c["coltura"], 0) + 1
		print("t=%3ds %s campi=%s" % [(k + 1) * 5, " ".join(s), colture])
	for r in ["olio", "vino", "ortaggi", "cipolle", "agrumi", "pesce_spada"]:
		_controlla(v.scorte.get(r, 0) > 0, "%s al magazzino (%d)" % [r, v.scorte.get(r, 0)])
	_controlla(in_barca, "il pescatore è uscito in barca")
	var viti := ris.campi.values().filter(func(c): return c["coltura"] == "vite").size()
	_controlla(viti > 0, "le viti restano dopo la vendemmia (%d)" % viti)
	var foto := OS.get_environment("FOTO")
	if foto != "":
		var centro := Vector2.ZERO
		for e in edifici.slice(1):
			centro += e.centro()
		centro /= edifici.size() - 1
		p.camera.position = d.a_schermo(centro.x, centro.y)
		Engine.time_scale = 1.0
		for k in 10:
			await process_frame
		root.get_viewport().get_texture().get_image().save_png(foto)
		Engine.time_scale = VELOCITA
		while not (spada.lavoratore._foglio == "barca_remi" and spada.lavoratore.stato == Lavoratore.Stato.LAVORO):
			await process_frame
		Engine.time_scale = 1.0
		p.camera.position = spada.lavoratore.position
		for k in 10:
			await process_frame
		root.get_viewport().get_texture().get_image().save_png(foto.get_basename() + "_barca.png")
		print("Screenshot salvati in ", foto)
	_fine()


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
