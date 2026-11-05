extends SceneTree
## Test automatico dello step 08 (popolazione): i coloni sono contati, portatori e lavoratori ne prendono
## uno ciascuno; una nuova abitazione fa nascere coloni (più in fretta col vino); i pannelli dicono il vero.
## Uso: godot --headless --path . --script tools/test/test_popolazione.gd
## (FOTO=file.png senza --headless per lo screenshot con i pannelli aperti)

const VELOCITA := 8.0

var p: Node2D
var errori := 0


func _initialize() -> void:
	p = load("res://src/mappa/partita.tscn").instantiate()
	root.add_child(p)
	_prova.call_deferred()


func _prova() -> void:
	await process_frame
	await process_frame
	var v: Villaggio = p.villaggio
	var rete: ReteStrade = p.rete
	var d: DatiMappa = p.dati
	var mag: Edificio = null
	for e in v.edifici.values():
		if e.tipo == "magazzino":
			mag = e
	print("popolazione %d, capacità %d, liberi %d, portatori %d" % [v.popolazione(), v.capacita(), v.coloni_liberi, rete.portatori()])
	_controlla(v.popolazione() == 40 and v.capacita() == 40, "si parte con 40 coloni e 40 posti")
	_controlla(v.coloni_liberi == 40 - rete.portatori(), "ogni portatore ha preso un colono")
	_controlla(PannelloEdificio.stato(mag, v).begins_with("Coloni liberi"), "il pannello del magazzino conta i coloni liberi")

	# senza coloni liberi le strade nuove aspettano
	var liberi := v.coloni_liberi
	v.coloni_liberi = 0
	var bosc := _piazza("boscaiolo", func(f): return _conta_vicini(p.risorse.alberi, f, 7))
	_controlla(rete.tratti_senza_portatore() > 0, "senza coloni la strada nuova aspetta il portatore")
	_controlla(PannelloEdificio.stato(bosc, v).begins_with("Nessun colono libero per costruire"), "pannello: il cantiere aspetta un colono per costruire")
	v.coloni_liberi = liberi
	await create_timer(2.0).timeout
	_controlla(rete.tratti_senza_portatore() == 0, "tornati i coloni, arriva il portatore")

	# una casa nuova: posti in più e nascite, accelerate dal vino
	var casa := _piazza("casa_greca", func(f): return -Vector2(f - mag.bandiera).length())
	_controlla(casa != null, "abitazione piazzata")
	v.scorte["vino"] = 3
	Engine.time_scale = VELOCITA
	var pop_0 := v.popolazione()
	var liberi_in_casa_0 := _coloni_nelle_case(v)
	var nati_in_casa := false
	for k in 24:
		await create_timer(15.0).timeout
		nati_in_casa = nati_in_casa or _coloni_nelle_case(v) > liberi_in_casa_0
		print("t=%3ds popolazione %d / %d  liberi %d  portatori %d  lavoratori %d  in cammino %d  vino %d | casa: %s | boscaiolo: %s" % [
			(k + 1) * 15, v.popolazione(), v.capacita(), v.coloni_liberi, rete.portatori(), v.lavoratori(), v.in_cammino,
			v.scorte.get("vino", 0), PannelloEdificio.stato(casa, v), PannelloEdificio.stato(bosc, v)])
	_controlla(v.capacita() == 48, "la casa aggiunge 8 posti")
	_controlla(v.popolazione() > pop_0, "sono nati coloni (%d -> %d)" % [pop_0, v.popolazione()])
	_controlla(nati_in_casa, "i nuovi coloni restano nelle abitazioni")
	_controlla(v.scorte.get("vino", 0) < 3, "il vino ha fatto crescere più in fretta")
	_controlla(v.popolazione() <= v.capacita(), "mai più coloni dei posti")
	_controlla(p.logistica.produzione_recente().get("tronchi", 0) > 0, "la produzione recente conta i tronchi")
	_controlla(bosc.prodotti > 0, "il boscaiolo conta quello che ha prodotto (%d)" % bosc.prodotti)

	# pannelli aperti
	p.pannello.mostra(bosc)
	p.pannello_villaggio.alterna()
	Engine.time_scale = 1.0
	await create_timer(0.5).timeout
	_controlla(p.pannello.visible and p.pannello._testo.text.contains("Produce"), "pannello del boscaiolo aperto")
	_controlla(p.pannello_villaggio._testo.text.contains("Popolazione"), "pannello del villaggio aperto")
	var foto := OS.get_environment("FOTO")
	if foto != "":
		p.camera.position = d.a_schermo(mag.centro().x, mag.centro().y)
		for k in 10:
			await process_frame
		root.get_viewport().get_texture().get_image().save_png(foto)
		print("Screenshot salvato in ", foto)
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


func _coloni_nelle_case(v: Villaggio) -> int:
	var totale := 0
	for disponibili in v._coloni_disponibili_case.values():
		totale += int(disponibili)
	return totale


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
