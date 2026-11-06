extends SceneTree
## Test automatico dello step 13 (soldati e conquista): avamposti dei Brettii, armaiolo, caserma che
## arruola, soldati che raggiungono il castello, attacco con duelli e conquista della torre nemica.
## Uso: godot --headless --path . --script tools/test/test_guerra.gd
## (FOTO=file.png senza --headless: screenshot durante la battaglia)

const VELOCITA := 8.0
const FILE := "user://test_guerra.json"

var p: Node2D
var errori := 0


func _initialize() -> void:
	p = load("res://src/mappa/partita.tscn").instantiate()
	root.add_child(p)
	_prova.call_deferred()


func _conta(chi: int) -> int:
	var d: DatiMappa = p.dati
	var n := 0
	for i in d.territorio.size():
		if d.territorio[i] == chi:
			n += 1
	return n


func _prova() -> void:
	await process_frame
	var v: Villaggio = p.villaggio
	var g: Guerra = p.guerra
	var d: DatiMappa = p.dati
	var mag := v.magazzino()
	_controlla(v.nemici.size() == 2, "due avamposti dei Brettii (%d)" % v.nemici.size())
	_controlla(_conta(2) > 100, "i Brettii hanno il loro territorio (%d caselle)" % _conta(2))
	for n in v.nemici.values():
		print("avamposto in %s, %d difensori, distanza %.1f" % [n.casella, n.soldati, Vector2(n.centro() - mag.centro()).length()])
	v.scorte["assi"] = 80
	v.scorte["pietra"] = 80
	v.scorte["armi"] = 3
	v.scorte["lingotti"] = 4
	var armaiolo := _piazza("armaiolo", func(f): return -Vector2(f - mag.bandiera).length())
	var caserma := _piazza("caserma", func(f): return -Vector2(f - mag.bandiera).length())
	# il castello verso l'avamposto più vicino, già finito e presidiato
	var bersaglio: Edificio = null
	for n in v.nemici.values():
		if bersaglio == null or Vector2(n.centro() - mag.centro()).length() < Vector2(bersaglio.centro() - mag.centro()).length():
			bersaglio = n
	var castello := _piazza("castello", func(f): return -Vector2(Vector2(f) - bersaglio.centro()).length(), true)
	_controlla(armaiolo != null and caserma != null and castello != null, "armaiolo, caserma e castello piazzati")
	if errori > 0:
		_fine()
		return
	print("castello a %.1f caselle dall'avamposto" % Vector2(castello.centro() - bersaglio.centro()).length())
	Engine.time_scale = VELOCITA
	for k in 16:
		await create_timer(15.0).timeout
		print("t=%3ds armi=%d soldati riserva=%d castello=%d(+%d) caserma: %s | coloni %d, popolazione %d" % [(k + 1) * 15,
			v.scorte.get("armi", 0), v.soldati, castello.soldati, castello.soldati_in_arrivo, PannelloEdificio.stato(caserma, v),
			v.coloni_liberi, v.popolazione()])
	_controlla(caserma.prodotti >= 3, "la caserma ha addestrato gli opliti (%d)" % caserma.prodotti)
	_controlla(castello.soldati >= 3, "i soldati hanno raggiunto il castello (%d)" % castello.soldati)
	var popolazione_attesa: int = v.coloni_liberi + v.in_cammino + v.costruttori + v.lavoratori() + p.rete.portatori() + v.soldati + g.in_marcia()
	for e in v.edifici.values():
		popolazione_attesa += e.soldati
	_controlla(v.popolazione() == popolazione_attesa, "la popolazione conta coloni, lavoratori, portatori e soldati una sola volta (%d)" % v.popolazione())

	# all'attacco: più attaccanti che difensori
	castello.soldati = 8
	var difensori: int = bersaglio.soldati
	var loro_prima := _conta(2)
	var partiti := g.attacca(castello, bersaglio)
	_controlla(partiti == 7 and castello.soldati == 1, "partono 7 soldati, uno resta nel castello")
	var visto_duello := false
	var foto := OS.get_environment("FOTO")
	for k in 120:
		await create_timer(1.0).timeout
		if not g._duelli.is_empty():
			visto_duello = true
			if foto != "" and k % 3 == 0:
				Engine.time_scale = 1.0
				var c: Colono = g._duelli.values()[0]["attaccante"]["nodo"]
				p.camera.position = c.global_position
				for f in 10:
					await process_frame
				root.get_viewport().get_texture().get_image().save_png(foto)
				foto = ""
				Engine.time_scale = VELOCITA
		if not is_instance_valid(bersaglio) or bersaglio.is_queued_for_deletion():
			break
	Engine.time_scale = 1.0
	await process_frame
	_controlla(visto_duello, "attaccanti e difensori si sono battuti a duello")
	var conquistata := not is_instance_valid(bersaglio) or bersaglio.is_queued_for_deletion()
	_controlla(conquistata, "la torre dei Brettii (%d difensori) è stata conquistata" % difensori)
	_controlla(v.nemici.size() == 1, "resta un solo avamposto")
	var nuova: Edificio = null
	for e in v.edifici.values():
		if e.tipo == "torre" and e.presidiata and e != castello:
			nuova = e
	_controlla(nuova != null and nuova.soldati > 0, "al posto dell'avamposto c'è una nostra torre con i vincitori (%d)" % (nuova.soldati if nuova else 0))
	_controlla(_conta(2) < loro_prima, "i Brettii hanno perso territorio (%d -> %d)" % [loro_prima, _conta(2)])
	var torri := v.edifici.values().filter(func(e): return e.tipo == "torre" and e.casella == nuova.casella).size() if nuova else 0
	_controlla(torri == 1, "una sola torre conquistata (%d)" % torri)
	Engine.time_scale = VELOCITA
	await create_timer(240.0).timeout
	Engine.time_scale = 1.0
	_controlla(armaiolo.prodotti > 0, "l'armaiolo ha forgiato le armi (%d)" % armaiolo.prodotti)

	# salvataggio
	var nemici_n := v.nemici.size()
	var difesa: int = v.nemici.values()[0].soldati
	Salvataggio.salva(p, FILE)
	p.queue_free()
	await process_frame
	Salvataggio.da_caricare = FILE
	p = load("res://src/mappa/partita.tscn").instantiate()
	root.add_child(p)
	await process_frame
	await process_frame
	_controlla(p.villaggio.nemici.size() == nemici_n and p.villaggio.nemici.values()[0].soldati == difesa, "gli avamposti e i difensori si salvano")
	var c2: Edificio = null
	for e in p.villaggio.edifici.values():
		if e.tipo == "castello":
			c2 = e
	_controlla(c2 != null and c2.soldati >= 1, "i soldati del castello si salvano (%d)" % (c2.soldati if c2 else -1))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(FILE))
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
		f = e.bandiera
		var bandiere: Array = rete.bandiere.keys().filter(func(b): return b != f)
		bandiere.sort_custom(func(a, b): return Vector2(a - f).length() < Vector2(b - f).length())
		for b in bandiere:
			var perc := rete.trova_percorso(b, f)
			if not perc.is_empty() and perc.size() <= 14 and rete.costruisci_strada(perc):
				break
		if rete.collegata(e.bandiera):
			print("%s in %s (bandierina %s, punteggio %.1f)" % [tipo, c, f, candidati[k][0]])
			return e
		v.demolisci(e)
	print("Impossibile piazzare ", tipo)
	return null
