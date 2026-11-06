extends SceneTree
## Test automatico dello step 06 (allevamenti): porcile, macelleria, ovile, capraio, apiario e
## caseificio, con un pozzo. Il magazzino parte con grano e acqua, per provare gli allevamenti da soli.
## Uso: godot --headless --path . --script tools/test/test_allevamenti.gd
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
	v.scorte["grano"] = 12
	v.scorte["acqua"] = 16
	var mag: Edificio = null
	for e in v.edifici.values():
		if e.tipo == "magazzino":
			mag = e
	var edifici := []
	for tipo in ["porcile", "macelleria", "pozzo", "ovile", "caseificio", "capraio", "apiario"]:
		var e := _piazza(tipo, func(f): return -Vector2(f - mag.bandiera).length())
		_controlla(e != null, tipo + " piazzato")
		if e:
			edifici.append(e)
	if errori > 0:
		_fine()
		return
	Engine.time_scale = VELOCITA
	var mezzi_minuti := int(OS.get_environment("MINUTI")) if OS.get_environment("MINUTI") != "" else 20
	for k in mezzi_minuti:
		await create_timer(30.0).timeout
		var stato := []
		for e in edifici:
			stato.append("%s:%s%s" % [e.tipo, "ok" if e.finito else "%.0f%%" % (e.progresso * 100), "" if e.ingresso.is_empty() else str(e.ingresso)])
		var s := []
		for r in ["grano", "acqua", "maiale", "carne", "latte", "lana", "formaggio", "miele"]:
			s.append("%s=%d" % [r, v.scorte.get(r, 0)])
		print("t=%3ds %s | %s" % [(k + 1) * 30, " ".join(s), " ".join(stato)])
	for r in ["carne", "lana", "formaggio", "miele"]:
		_controlla(v.scorte.get(r, 0) > 0, "%s arrivata al magazzino (%d)" % [r, v.scorte.get(r, 0)])
	_controlla(v.scorte["grano"] < 12 and v.scorte["acqua"] < 16, "porcile e ovile hanno consumato grano e acqua")
	var foto := OS.get_environment("FOTO")
	if foto != "":
		var centro := Vector2.ZERO
		for e in edifici:
			centro += e.centro()
		centro /= edifici.size()
		p.camera.position = d.a_schermo(centro.x, centro.y)
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
			if not perc.is_empty() and rete.costruisci_strada(perc):
				break
		if rete.collegata(e.bandiera):
			print("%s in %s (bandierina %s, punteggio %.1f)" % [tipo, c, f, candidati[k][0]])
			return e
		v.demolisci(e)
	print("Impossibile piazzare ", tipo)
	return null
