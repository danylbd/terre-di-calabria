extends SceneTree
## Test automatico dello step 16 (tutorial «Il naufragio»): si parte col solo magazzino, il racconto
## ferma il gioco, gli obiettivi si compiono uno dopo l'altro come farebbe un giocatore, alla fine
## arriva il racconto di chiusura; la missione si salva.
## Uso: godot --headless --path . --script tools/test/test_missione.gd
## (FOTO=file.png senza --headless: screenshot del dialogo e degli obiettivi)

const VELOCITA := 8.0
const FILE := "user://test_missione.json"

var p: Node2D
var errori := 0


func _initialize() -> void:
	Missione.progressi = "user://test_campagna.json"
	Impostazioni.missione = "naufragio"
	p = load("res://src/mappa/partita.tscn").instantiate()
	root.add_child(p)
	_prova.call_deferred()


func _prova() -> void:
	await process_frame
	await process_frame
	var v: Villaggio = p.villaggio
	var m: Missione = p.missione
	var pm: PannelloMissione = p.pannello_missione
	var foto := OS.get_environment("FOTO")
	_controlla(m != null and m.titolo() == "Il naufragio", "la missione è partita")
	_controlla(v.edifici.size() == 1 and v.magazzino() != null, "si parte col solo magazzino (il relitto)")
	_controlla(v.nemici.is_empty(), "nessun Brettio nel tutorial")
	_controlla(pm.dialogo_aperto() and paused, "il racconto d'apertura ferma il gioco")
	if foto != "":
		await _foto(foto.get_basename() + "_dialogo.png")
	var battute := 0
	while pm.dialogo_aperto():
		pm.avanti()
		battute += 1
	_controlla(battute == 3 and not paused, "tre battute, poi si gioca (%d)" % battute)
	_controlla(m.indice == 0, "primo obiettivo: la strada")

	var mag := v.magazzino()
	var bosc := _piazza("boscaiolo", func(f): return _conta_vicini(p.risorse.alberi, f, 7))
	Engine.time_scale = VELOCITA
	await create_timer(2.0).timeout
	_controlla(m.indice >= 1, "strada tracciata: obiettivo compiuto")
	var seg := _piazza("segheria", func(f): return -Vector2(f - mag.bandiera).length())
	var casa1 := _piazza("casa_greca", func(f): return -Vector2(f - mag.bandiera).length())
	var casa2 := _piazza("casa_greca", func(f): return -Vector2(f - mag.bandiera).length())
	_controlla(bosc != null and seg != null and casa1 != null and casa2 != null, "edifici del tutorial piazzati")
	var visti := {}
	for k in 120:
		await create_timer(5.0).timeout
		visti[m.indice] = true
		if m.finita():
			break
		if foto != "" and m.indice == 3 and not visti.has("foto"):
			visti["foto"] = true
			Engine.time_scale = 1.0
			await _foto(foto.get_basename() + "_obiettivi.png")
			Engine.time_scale = VELOCITA
	Engine.time_scale = 1.0
	_controlla(m.finita(), "tutti gli obiettivi compiuti (indice %d)" % m.indice)
	_controlla(visti.has(1) and visti.has(2) or visti.has(3), "gli obiettivi si compiono in ordine")
	await process_frame
	_controlla(pm.dialogo_aperto(), "arriva il racconto di chiusura")
	while pm.dialogo_aperto():
		pm.avanti()
	_controlla(pm._obiettivi.text.contains("Missione compiuta"), "il riquadro dice «Missione compiuta»")

	Salvataggio.salva(p, FILE)
	p.queue_free()
	await process_frame
	Impostazioni.missione = ""
	Salvataggio.da_caricare = FILE
	p = load("res://src/mappa/partita.tscn").instantiate()
	root.add_child(p)
	await process_frame
	await process_frame
	_controlla(p.missione != null and p.missione.finita(), "la missione si salva")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(FILE))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Missione.progressi))
	_fine()


func _foto(file: String) -> void:
	for k in 10:
		await process_frame
	root.get_viewport().get_texture().get_image().save_png(file)
	print("Screenshot salvato in ", file)


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
