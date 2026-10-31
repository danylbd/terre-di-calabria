extends SceneTree
## Test automatico dello step 06 (filiera del pane e pesca): costruisce fattoria, mulino, forno,
## pozzo e pescatore, li collega, accelera il tempo e controlla che arrivino pane e pesce.
## Uso: godot --headless --path . --script tools/test/test_cibo.gd
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
	var ris: RisorseNaturali = p.risorse
	var d: DatiMappa = p.dati
	var mag: Edificio = null
	for e in v.edifici.values():
		if e.tipo == "magazzino":
			mag = e
	var fatt := _piazza("fattoria", func(f): return _prato_libero(f, 4) - Vector2(f - mag.bandiera).length() * 0.3)
	# la costa è fuori dai confini iniziali: una torre già finita li allarga verso il mare, come farebbe il giocatore
	var torre := _piazza("torre", func(f): return -_distanza_acqua(f), true)
	_controlla(torre != null, "torre verso il mare")
	var pesc := _piazza("pescatore", func(f): return _conta_acqua(f, 6) - Vector2(f - mag.bandiera).length() * 0.2)
	var mul := _piazza("mulino", func(f): return -Vector2(f - mag.bandiera).length())
	var forno := _piazza("forno", func(f): return -Vector2(f - mag.bandiera).length())
	var pozzo := _piazza("pozzo", func(f): return -Vector2(f - forno.bandiera).length() if forno else 0.0)
	for e in [fatt, pesc, mul, forno, pozzo]:
		_controlla(e != null, "edificio piazzato")
	if errori > 0:
		_fine()
		return

	Engine.time_scale = VELOCITA
	var mezzi_minuti := int(OS.get_environment("MINUTI")) if OS.get_environment("MINUTI") != "" else 20
	var campi_max := 0
	for k in mezzi_minuti:
		await create_timer(30.0).timeout
		campi_max = maxi(campi_max, ris.campi.size())
		var stato := []
		for e in [fatt, pesc, mul, forno, pozzo]:
			var l: Lavoratore = e.lavoratore
			stato.append("%s:%s%s%s" % [e.tipo, "ok" if e.finito else "%.0f%%" % (e.progresso * 100),
				"" if l == null else "(" + Lavoratore.Stato.keys()[l.stato] + ")", "" if e.ingresso.is_empty() else str(e.ingresso)])
		var maturi := ris.campi.values().filter(func(c): return c["crescita"] >= 3.0).size()
		print("t=%3ds grano=%d farina=%d acqua=%d pane=%d pesce=%d campi=%d (maturi %d) | %s" % [(k + 1) * 30,
			v.scorte.get("grano", 0), v.scorte.get("farina", 0), v.scorte.get("acqua", 0), v.scorte.get("pane", 0),
			v.scorte.get("pesce", 0), ris.campi.size(), maturi, " ".join(stato)])

	for m in p.logistica.merci:
		print("  merce %s in %s -> %s %s spalla=%s" % [m.tipo, m.bandiera, m.destinazione.tipo, m.destinazione.bandiera, m.in_spalla])
	for e in [mul, forno]:
		print("  %s in_arrivo=%s ingresso=%s" % [e.tipo, e.in_arrivo, e.ingresso])
	var w := 99.0
	for y in d.altezza:
		for x in d.larghezza:
			if d.tipo(x, y) == DatiMappa.Terreno.ACQUA:
				w = minf(w, Vector2(Vector2i(x, y) - pesc.bandiera).length())
	print("  acqua più vicina al pescatore: %.1f caselle; posto di pesca: %s" % [w, ris.posto_di_pesca(pesc.bandiera, 7)])
	_controlla(campi_max >= 3, "il contadino ha seminato i campi (max %d)" % campi_max)
	_controlla(ris._ceppi.size() > 0 or v.scorte.get("grano", 0) > 0 or mul.ingresso.get("grano", 0) > 0 or v.scorte.get("farina", 0) > 0,
		"il contadino ha mietuto")
	_controlla(v.scorte.get("pane", 0) > 0, "pane arrivato al magazzino (%d)" % v.scorte.get("pane", 0))
	_controlla(v.scorte.get("pesce", 0) > 0, "pesce arrivato al magazzino (%d)" % v.scorte.get("pesce", 0))
	_controlla(not ris.pesci.is_empty(), "il mare si è impoverito dove si pesca")
	var foto := OS.get_environment("FOTO")
	if foto != "":
		var centro := (fatt.centro() + mul.centro() + forno.centro() + mag.centro()) / 4.0
		p.camera.position = d.a_schermo(centro.x, centro.y)
		Engine.time_scale = 1.0
		for k in 10:
			await process_frame
		root.get_viewport().get_texture().get_image().save_png(foto)
		print("Screenshot salvato in ", foto)
		p.camera.position = d.a_schermo(pesc.centro().x, pesc.centro().y)
		for k in 10:
			await process_frame
		root.get_viewport().get_texture().get_image().save_png(foto.get_basename() + "_pesca.png")
	_fine()


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
