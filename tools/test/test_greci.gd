extends SceneTree
## Test automatico dello step 11 (Greci completi): argillaio e fornace (anfore), saline, tessitura,
## miniera d'argento e zecca (monete), agorà che vende e compra. Il magazzino riceve qualche merce
## di partenza per provare le nuove catene senza aspettare quelle vecchie.
## Uso: godot --headless --path . --script tools/test/test_greci.gd
## (FOTO=file.png senza --headless per lo screenshot)

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
	var regali := {"olio": 6, "vino": 6, "lana": 6, "pane": 10, "carbone": 10, "tronchi": 30, "assi": 70, "pietra": 70}
	for m in regali:
		v.scorte[m] = regali[m]
	var mag: Edificio = null
	for e in v.edifici.values():
		if e.tipo == "magazzino":
			mag = e
	_controlla(CatalogoEdifici.EDIFICI.size() >= 30, "i Greci hanno %d edifici" % CatalogoEdifici.EDIFICI.size())
	_controlla(ris.minerali["argento"].size() > 5, "vene d'argento nella roccia (%d)" % ris.minerali["argento"].size())
	var agora := _piazza("agora", func(f): return -Vector2(f - mag.bandiera).length())
	var tess := _piazza("tessitura", func(f): return -Vector2(f - mag.bandiera).length())
	var zecca := _piazza("zecca", func(f): return -Vector2(f - mag.bandiera).length())
	var fornace := _piazza("fornace", func(f): return -Vector2(f - mag.bandiera).length())
	# miniera d'argento: torri verso le vene
	var miniera: Edificio = null
	for k in 4:
		miniera = _piazza("miniera_argento", func(f): return ris.minerale_vicino(f + Vector2i(0, -1), "argento") * 0.3 - Vector2(f - mag.bandiera).length() * 0.2)
		if miniera:
			break
		_piazza("torre", func(f): return -_distanza(ris.minerali["argento"], f), true)
	# argillaio e saline: torri verso il mare
	var argillaio: Edificio = null
	var saline: Edificio = null
	for k in 4:
		argillaio = argillaio if argillaio else _piazza("argillaio", func(f): return -Vector2(f - mag.bandiera).length())
		saline = saline if saline else _piazza("saline", func(f): return -Vector2(f - mag.bandiera).length())
		if argillaio and saline:
			break
		_piazza("torre", func(f): return -_distanza_acqua(f), true)
	for e in [agora, tess, zecca, fornace, miniera, argillaio, saline]:
		_controlla(e != null, "edificio piazzato")
	if errori > 0:
		_fine()
		return
	agora.acquisto = "ferro"
	Engine.time_scale = VELOCITA
	for k in 24:
		await create_timer(30.0).timeout
		var s := []
		for r in ["olio", "vino", "monete", "ferro", "anfore", "argilla", "sale", "stoffa", "lana", "argento"]:
			s.append("%s=%d" % [r, v.scorte.get(r, 0)])
		print("t=%3ds %s | agorà %s guadagno %d | coloni %d/%d" % [(k + 1) * 30, " ".join(s), agora.ingresso, agora.guadagno,
			v.popolazione(), v.capacita()])
	_controlla(v.scorte.get("anfore", 0) + agora.ingresso.get("anfore", 0) > 0 or fornace.prodotti > 0, "la fornace fa le anfore (%d)" % fornace.prodotti)
	_controlla(saline.prodotti > 0, "le saline danno il sale (%d)" % saline.prodotti)
	_controlla(tess.prodotti > 0, "la tessitura fa la stoffa (%d)" % tess.prodotti)
	_controlla(miniera.prodotti > 0, "la miniera dà l'argento (%d)" % miniera.prodotti)
	_controlla(zecca.prodotti > 0, "la zecca conia le monete (%d)" % zecca.prodotti)
	_controlla(agora.guadagno > 0, "l'agorà vende e guadagna (%d monete)" % agora.guadagno)
	_controlla(agora.prodotti > 0 and v.scorte.get("ferro", 0) > 0, "l'agorà compra il ferro (%d)" % agora.prodotti)
	_controlla(v.scorte.get("olio", 0) < 6, "l'olio è stato venduto")
	p.pannello.mostra(agora)
	Engine.time_scale = 1.0
	await create_timer(0.5).timeout
	_controlla(p.pannello._riga_compra.visible and p.pannello._compra.selected > 0, "il pannello dell'agorà mostra l'acquisto scelto")
	var foto := OS.get_environment("FOTO")
	if foto != "":
		p.camera.position = d.a_schermo(agora.centro().x, agora.centro().y)
		for k in 10:
			await process_frame
		root.get_viewport().get_texture().get_image().save_png(foto)
		print("Screenshot salvato in ", foto)
	_fine()


func _distanza(dove: Dictionary, f: Vector2i) -> float:
	var migliore := 99.0
	for c in dove:
		migliore = minf(migliore, Vector2(c - f).length())
	return migliore


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
