extends SceneTree
## Test automatico dello step 05: costruisce boscaiolo, segheria, cava e guardaboschi vicino
## al magazzino, li collega con le strade, accelera il tempo e controlla che la catena funzioni.
## Uso: godot --headless --path . --script tools/test/test_catena.gd
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
	if p.mappa == "bruzio":
		# La suite del Bruzio verifica geografia e salvataggio della mappa; la catena produttiva
		# completa è verificata qui sulla mappa base e nelle suite dedicate ai mestieri.
		_fine()
		return
	var v: Villaggio = p.villaggio
	var rete: ReteStrade = p.rete
	var ris: RisorseNaturali = p.risorse
	var mag: Edificio = null
	for e in v.edifici.values():
		if e.tipo == "magazzino":
			mag = e
	print("Alberi: %d caselle, rocce: %d caselle" % [ris.alberi.size(), ris.rocce.size()])
	print("Scorte iniziali: ", v.scorte)

	var bosc := _piazza("boscaiolo", func(f): return _conta_vicini(ris.alberi, f, 7))
	var cava := _piazza("cava", func(f): return _conta_vicini(ris.rocce, f, 7))
	var seg := _piazza("segheria", func(f): return -Vector2(f - mag.bandiera).length())
	var guard := _piazza("guardaboschi", func(f): return _conta_vicini(ris.alberi, f, 7) * 0.5 - Vector2(f - bosc.bandiera).length() if bosc else 0.0)
	for e in [bosc, cava, seg, guard]:
		_controlla(e != null, "edificio piazzato")
	if errori > 0:
		_fine()
		return

	var tronchi_0: int = ris.alberi.size()
	var riserva_0 := _riserva_rocce()
	Engine.time_scale = VELOCITA
	var assi_prodotte := 0
	var pietre := 0
	var piantati := 0
	for minuto in (int(OS.get_environment("MINUTI")) if OS.get_environment("MINUTI") != "" else 12):
		await create_timer(30.0).timeout
		var stato := []
		for e in [bosc, cava, seg, guard]:
			var l: Lavoratore = e.lavoratore
			stato.append("%s:%s%s" % [e.tipo, "finito" if e.finito else "cantiere %.0f%%" % (e.progresso * 100),
				"" if l == null else " (" + Lavoratore.Stato.keys()[l.stato] + ")"])
		print("t=%3ds scorte=%s merci=%d seg.ingresso=%s | %s" % [(minuto + 1) * 30, v.scorte, p.logistica.merci.size(),
			seg.ingresso, ", ".join(stato)])
	for m in p.logistica.merci:
		print("  merce %s in %s -> %s (%s) spalla=%s prenotata=%s salto=%s" % [m.tipo, m.bandiera, m.destinazione.tipo, m.destinazione.bandiera, m.in_spalla, m.prenotata, rete.prossimo_salto(m.bandiera, m.destinazione.bandiera)])
	for t in rete.tratti.values():
		print("  tratto %s-%s portatore=%s" % [t.a, t.b, t.portatore != null and t.portatore.libero()])
	piantati = _alberelli()
	print("Alberelli piantati e in crescita: %d" % piantati)
	print("Rocce: riserva da %d a %d" % [riserva_0, _riserva_rocce()])

	_controlla(bosc.finito and cava.finito and seg.finito and guard.finito, "tutti gli edifici finiti")
	_controlla(bosc.lavoratore != null and cava.lavoratore != null and seg.lavoratore != null and guard.lavoratore != null,
		"ogni edificio ha il suo lavoratore")
	_controlla(_riserva_rocce() < riserva_0, "la cava ha estratto pietra")
	_controlla(piantati > 0, "il guardaboschi ha piantato alberelli")
	_controlla(_ceppi() > 0 or _alberi_abbattuti(tronchi_0), "il boscaiolo ha abbattuto alberi")
	# la segheria deve aver ricevuto tronchi e consegnato assi al magazzino
	_controlla(v.scorte["assi"] > 24 - 2 * 4 - 2, "assi prodotte dalla segheria arrivate al magazzino (assi=%d)" % v.scorte["assi"])
	_controlla(v.scorte["pietra"] > 18 - 2, "pietra arrivata al magazzino (pietra=%d)" % v.scorte["pietra"])
	var foto := OS.get_environment("FOTO")
	if foto != "":
		# FOTO=percorso.png: inquadra la catena e salva uno screenshot (serve lanciarlo senza --headless)
		var centro := (bosc.centro() + cava.centro() + seg.centro() + mag.centro()) / 4.0
		p.camera.position = p.dati.a_schermo(centro.x, centro.y)
		Engine.time_scale = 1.0
		for k in 10:
			await process_frame
		root.get_viewport().get_texture().get_image().save_png(foto)
		print("Screenshot salvato in ", foto)
	_fine()


func _fine() -> void:
	print("RISULTATO: %s (%d errori)" % ["OK" if errori == 0 else "FALLITO", errori])
	Engine.time_scale = 1.0
	quit(1 if errori > 0 else 0)


func _controlla(ok: bool, cosa: String) -> void:
	print(("  ok  " if ok else "  NO  ") + cosa)
	if not ok:
		errori += 1


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
	for k in mini(candidati.size(), 300):
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


func _riserva_rocce() -> int:
	var n := 0
	for r in p.risorse.rocce.values():
		n += r["riserva"]
	return n


func _alberelli() -> int:
	var n := 0
	for lista in p.risorse.alberi.values():
		for a in lista:
			if a["crescita"] < 3.0:
				n += 1
	return n


func _ceppi() -> int:
	return p.risorse._ceppi.size()


func _alberi_abbattuti(caselle_prima: int) -> bool:
	return p.risorse.alberi.size() < caselle_prima
