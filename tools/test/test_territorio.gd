extends SceneTree
## Test automatico dello step 12 (territorio e torri): la torre allarga i confini solo quando la guardia
## la presidia; i confini di un altro popolo non si rubano; demolendo la torre gli edifici rimasti
## fuori bruciano; il castello allarga di più; tutto sopravvive al salvataggio.
## Uso: godot --headless --path . --script tools/test/test_territorio.gd
## (FOTO=file.png senza --headless per lo screenshot)

const VELOCITA := 8.0
const FILE := "user://test_territorio.json"

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
	var d: DatiMappa = p.dati
	var mag: Edificio = null
	for e in v.edifici.values():
		if e.tipo == "magazzino":
			mag = e
	v.scorte["assi"] = 60
	v.scorte["pietra"] = 60
	var mio_0 := _conta(1)
	print("territorio iniziale: %d caselle" % mio_0)

	# un altro popolo a est, confinante
	var est := Vector2i(int(mag.centro().x) + 15, int(mag.centro().y))
	v.centri_esterni = [[est, 8.0, 2]]
	v._ricalcola_territorio()
	var loro := _conta(2)
	_controlla(loro > 50, "c'è il territorio di un altro popolo (%d caselle)" % loro)
	var casella_loro := Vector2i(-1, -1)
	for y in d.altezza:
		for x in d.larghezza:
			if casella_loro.x < 0 and d.proprietario(x, y) == 2 and d.tipo(x, y) == DatiMappa.Terreno.PRATO and d.occupante(x, y) == 0:
				casella_loro = Vector2i(x, y)
	_controlla(v.motivo_impossibile("casa_greca", casella_loro) == "Fuori dai tuoi confini", "non si costruisce nel territorio altrui")

	# torre al limite raggiungibile: allarga solo dopo il presidio, e non ruba le caselle altrui
	var torre := _piazza("torre", func(f): return Vector2(f - mag.bandiera).length())
	_controlla(torre != null, "torre piazzata al limite dei confini")
	_controlla(CatalogoEdifici.dati("torre").get("soldati_max", 0) == 2, "una torre ospita due soldati")
	var prima := _conta(1)
	Engine.time_scale = VELOCITA
	var visto_senza := false
	for k in 40:
		await create_timer(5.0).timeout
		if torre.finito and not torre.presidiata:
			visto_senza = true
			_controlla(_conta(1) == prima, "torre finita ma senza guardia: confini fermi")
		if torre.presidiata:
			break
	Engine.time_scale = 1.0
	_controlla(visto_senza, "la torre ha aspettato la guardia")
	_controlla(torre.presidiata, "la guardia presidia la torre")
	_controlla(_conta(1) > prima, "con la guardia i confini si allargano (%d -> %d)" % [prima, _conta(1)])
	_controlla(_conta(2) == loro, "le caselle dell'altro popolo restano sue (%d)" % _conta(2))
	_controlla(torre.lavoratore != null and v.lavoratori() >= 1, "la guardia conta come lavoratore")

	# una casa nella zona nuova; demolendo la torre la casa resta fuori e brucia
	var casa := _piazza("casa_greca", func(f): return Vector2(f - mag.bandiera).length() if not _vicino_magazzino(f, mag) else -99.0)
	_controlla(casa != null and not _vicino_magazzino(casa.bandiera, mag), "casa costruita nella zona della torre")
	var tratti_prima: int = p.rete.tratti.size()
	v.demolisci(torre)
	await process_frame
	_controlla(not is_instance_valid(casa) or casa.is_queued_for_deletion(), "la casa fuori dai confini è bruciata")
	_controlla(_conta(1) == mio_0, "i confini tornano come prima (%d)" % _conta(1))
	_controlla(p.rete.tratti.size() < tratti_prima, "le strade fuori dai confini sono sparite")

	# il castello allarga di più della torre
	var cast := _piazza("castello", func(f): return Vector2(f - mag.bandiera).length(), true)
	_controlla(cast != null and cast.presidiata, "castello piazzato e presidiato")
	_controlla(_conta(1) > mio_0 + 100, "il castello allarga molto i confini (%d)" % _conta(1))

	# Il centro nemico sopra è un dato temporaneo del test, non viene salvato dal gioco.
	v.centri_esterni.clear()
	v._ricalcola_territorio()
	# salvataggio
	var mio := _conta(1)
	Salvataggio.salva(p, FILE)
	var foto := OS.get_environment("FOTO")
	if foto != "":
		p._scegli_edificio("torre")
		p._casella_mouse = Vector2i(int(mag.centro().x) - 6, int(mag.centro().y) + 6)
		p._aggiorna_fantasma()
		p.camera.position = d.a_schermo(mag.centro().x + 4, mag.centro().y)
		p.camera.zoom = Vector2.ONE * 0.6
		for k in 10:
			await process_frame
		root.get_viewport().get_texture().get_image().save_png(foto)
		print("Screenshot salvato in ", foto)
	p.queue_free()
	await process_frame
	Salvataggio.da_caricare = FILE
	p = load("res://src/mappa/partita.tscn").instantiate()
	root.add_child(p)
	await process_frame
	await process_frame
	_controlla(_conta(1) == mio, "dopo il caricamento i confini sono gli stessi (%d)" % _conta(1))
	var c2: Edificio = null
	for e in p.villaggio.edifici.values():
		if e.tipo == "castello":
			c2 = e
	_controlla(c2 != null and c2.presidiata and c2.lavoratore != null, "il castello è ancora presidiato")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(FILE))
	_fine()


func _vicino_magazzino(f: Vector2i, mag: Edificio) -> bool:
	return Vector2(f - Vector2i(mag.centro())).length() < 8.5


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
