extends SceneTree
## Test automatico dello step 17 (campagna dei Greci): un giocatore automatico gioca una missione,
## costruendo quello che serve all'obiettivo del momento e facendo scorrere i dialoghi.
## Uso: MISSIONE=pane_straniero godot --headless --path . --script tools/test/test_campagna.gd
## (senza MISSIONE controlla solo l'elenco e lo sblocco delle missioni)

const VELOCITA := 8.0
const PROGRESSI := "user://test_campagna.json"

var p: Node2D
var errori := 0
var _fatti := {}


func _initialize() -> void:
	_prova.call_deferred()


func _prova() -> void:
	Missione.progressi = PROGRESSI
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PROGRESSI))
	var id := OS.get_environment("MISSIONE")
	if id == "":
		_controlla(Missione.CAMPAGNA_GRECI.size() == 6, "la campagna dei Greci ha 6 missioni")
		_controlla(Missione.sbloccata("naufragio") and not Missione.sbloccata("pane_straniero"), "all'inizio si gioca solo il naufragio")
		Missione.segna_compiuta("naufragio")
		_controlla(Missione.sbloccata("pane_straniero") and not Missione.sbloccata("uliveto"), "finito il naufragio si sblocca la seconda")
		for m in Missione.CAMPAGNA_GRECI:
			_controlla(Missione.MISSIONI[m]["obiettivi"].size() >= 2 and not Missione.MISSIONI[m]["fine"].is_empty(), "%s ha obiettivi e finale" % m)
		# la mappa della Calabria: sei segnaposti, quelli futuri bloccati
		var mappa = load("res://src/main/mappa_calabria.tscn").instantiate()
		root.add_child(mappa)
		await process_frame
		var s: Dictionary = mappa._segnaposti
		_controlla(s.size() == 6, "sulla mappa ci sono le 6 missioni dei Greci")
		_controlla(s["naufragio"].text == "✔" and not s["pane_straniero"].disabled and s["uliveto"].disabled,
			"compiute con la spunta, la prossima aperta, le altre bloccate")
		var dentro := true
		for m in s:
			var b: Button = s[m]
			if not Rect2(Vector2.ZERO, mappa.size).encloses(Rect2(b.position, b.size)):
				dentro = false
		_controlla(dentro, "i segnaposti stanno dentro lo schermo")
		DirAccess.remove_absolute(ProjectSettings.globalize_path(PROGRESSI))
		_fine()
		return

	Impostazioni.missione = id
	p = load("res://src/mappa/partita.tscn").instantiate()
	root.add_child(p)
	await process_frame
	await process_frame
	var m: Missione = p.missione
	_controlla(m != null and m.id == id, "missione %s partita" % id)
	Engine.time_scale = VELOCITA
	var ultimo := -1
	for k in 600:
		while p.pannello_missione.dialogo_aperto():
			p.pannello_missione.avanti()
		if m.finita():
			break
		if m.indice != ultimo:
			ultimo = m.indice
			print("t=%4ds obiettivo %d: %s" % [k * 2, m.indice + 1, m.obiettivi()[m.indice]["testo"]])
		_gioca(m.obiettivi()[m.indice])
		await create_timer(2.0).timeout
	Engine.time_scale = 1.0
	_controlla(m.finita(), "%s compiuta (obiettivo %d di %d)" % [id, m.indice, m.obiettivi().size()])
	_controlla(id in Missione.completate(), "la missione risulta compiuta nei progressi")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PROGRESSI))
	_fine()


func _bottoni(n: Node, testi: Array) -> void:
	if n is Button:
		testi.append((n as Button).text)
	for k in n.get_children():
		_bottoni(k, testi)


## Il giocatore automatico: costruisce una volta sola quello che serve all'obiettivo.
func _gioca(ob: Dictionary) -> void:
	var v: Villaggio = p.villaggio
	var mag := v.magazzino()
	var vicino := func(f): return -Vector2(f - mag.bandiera).length()
	match ob["prova"]:
		"edificio":
			match ob["tipo"]:
				"forno":
					_una_volta("pozzo", vicino)
					_una_volta("mulino", vicino)
					_una_volta("forno", vicino)
				"uliveto":
					_una_volta("uliveto", func(f): return _conta(p.risorse.ulivi, f, 6) - Vector2(f - mag.bandiera).length() * 0.3)
				"pesca_spada":
					_una_volta("pesca_spada", func(f): return -_distanza_acqua(f))
				_:
					_una_volta(ob["tipo"], vicino)
		"prodotti":
			match ob["tipo"]:
				"agora":
					for e in v.edifici.values():
						if e.tipo == "agora":
							e.acquisto = "grano"
				"forno":
					pass
				"fattoria":
					_una_volta("fattoria", func(f): return _prato_libero(f, 4) - Vector2(f - mag.bandiera).length() * 0.3)
		"guadagno":
			_una_volta("agora", vicino)
		"campi":
			_una_volta("fattoria", func(f): return _prato_libero(f, 4) - Vector2(f - mag.bandiera).length() * 0.3)
		"scorta":
			if ob["merce"] == "pietra":
				_una_volta("cava", func(f): return _conta(p.risorse.rocce, f, 7))
				_una_volta("cava2", func(f): return _conta(p.risorse.rocce, f, 7))
			elif ob["merce"] == "ducati":
				_una_volta("agora", vicino)
		"popolazione":
			# abitazioni finché i posti bastano per la popolazione chiesta (8 posti l'una)
			var mancano := maxi(0, ob.get("n", 1) - p.villaggio.capacita())
			for k in ceili(mancano / 8.0) + 2:
				_una_volta("casa_greca#%d" % k, vicino)
		"presidiata":
			_una_volta("torre", func(f): return Vector2(f - mag.bandiera).length() if Vector2(f - mag.bandiera).length() < 9 else -99.0)


func _una_volta(chiave: String, punteggio: Callable) -> void:
	if _fatti.has(chiave):
		return
	_fatti[chiave] = true
	var tipo := chiave.trim_suffix("2").get_slice("#", 0)
	var e := _piazza(tipo, punteggio)
	if e == null:
		print("  (non riesco a piazzare %s)" % tipo)


func _conta(dove: Dictionary, f: Vector2i, raggio: int) -> float:
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
			if not perc.is_empty() and perc.size() <= 14 and rete.costruisci_strada(perc):
				break
		if rete.collegata(e.bandiera):
			print("%s in %s (bandierina %s, punteggio %.1f)" % [tipo, c, f, candidati[k][0]])
			return e
		v.demolisci(e)
	print("Impossibile piazzare ", tipo)
	return null
