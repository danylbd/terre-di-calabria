extends SceneTree
## Test automatico dello step 09 (salvataggio): si gioca qualche minuto, si salva, si ricarica in una
## scena nuova e si confronta tutto; poi il villaggio ricaricato deve continuare a lavorare.
## Uso: godot --headless --path . --script tools/test/test_salvataggio.gd

const VELOCITA := 8.0
const FILE := "user://test_salvataggio.json"

var p: Node2D
var errori := 0


func _initialize() -> void:
	p = load("res://src/mappa/partita.tscn").instantiate()
	root.add_child(p)
	_prova.call_deferred()


func _prova() -> void:
	await process_frame
	var v: Villaggio = p.villaggio
	var mag: Edificio = null
	for e in v.edifici.values():
		if e.tipo == "magazzino":
			mag = e
	_piazza("boscaiolo", func(f): return _conta_vicini(p.risorse.alberi, f, 7))
	_piazza("segheria", func(f): return -Vector2(f - mag.bandiera).length())
	_piazza("fattoria", func(f): return _prato_libero(f, 4) - Vector2(f - mag.bandiera).length() * 0.3)
	_piazza("guardaboschi", func(f): return _conta_vicini(p.risorse.alberi, f, 7) * 0.5)
	Engine.time_scale = VELOCITA
	await create_timer(200.0).timeout
	# un cantiere lasciato a metà (senza strada) e una merce in viaggio
	var cantiere := _piazza("casa_greca", func(f): return -Vector2(f - mag.bandiera).length())
	await create_timer(4.0).timeout
	Engine.time_scale = 1.0
	await process_frame
	var prima := _riassunto(p)
	print("PRIMA:  ", prima)
	_controlla(Salvataggio.salva(p, FILE), "partita salvata")
	var prodotti_prima: int = p.logistica.storia.size()
	p.queue_free()
	await process_frame
	await process_frame

	Salvataggio.da_caricare = FILE
	p = load("res://src/mappa/partita.tscn").instantiate()
	root.add_child(p)
	await process_frame
	await process_frame
	var dopo := _riassunto(p)
	print("DOPO:   ", dopo)
	for k in prima:
		_controlla(JSON.stringify(prima[k], "", true) == JSON.stringify(dopo[k], "", true), "%s uguale (%s)" % [k, str(dopo[k])])
	# la partita ricaricata continua: i lavoratori lavorano e le merci viaggiano
	Engine.time_scale = VELOCITA
	await create_timer(120.0).timeout
	Engine.time_scale = 1.0
	_controlla(p.logistica.storia.size() > prodotti_prima, "dopo il caricamento si continua a produrre (%d -> %d)" % [prodotti_prima, p.logistica.storia.size()])
	_controlla(p.villaggio.popolazione() <= p.villaggio.capacita(), "coloni dentro i posti")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(FILE))
	_fine()


## Tutto quello che deve sopravvivere al salvataggio, in forma confrontabile.
func _riassunto(q: Node2D) -> Dictionary:
	var v: Villaggio = q.villaggio
	var ris: RisorseNaturali = q.risorse
	var edifici := []
	for e in v.edifici.values():
		edifici.append("%s@%s:%s:%d" % [e.tipo, e.casella, "ok" if e.finito else str(e.consegnati), e.prodotti])
	edifici.sort()
	var alberi := 0
	for c in ris.alberi:
		alberi += ris.alberi[c].size()
	var riserva := 0
	for c in ris.rocce:
		riserva += ris.rocce[c]["riserva"]
	var merci := []
	for m in q.logistica.merci:
		merci.append("%s->%s" % [m.tipo, m.destinazione.tipo])
	merci.sort()
	var con_lavoratore := v.edifici.values().filter(func(e): return e.lavoratore != null).size()
	var bandiere: Array = q.rete.bandiere.keys().map(func(c): return str(c))
	bandiere.sort()
	return {"edifici": edifici, "bandiere": q.rete.bandiere.size(), "tratti": q.rete.tratti.size(),
		"posizioni_bandiere": bandiere,
		"portatori": q.rete.portatori(), "lavoratori": con_lavoratore, "coloni": v.coloni_liberi + v.in_cammino + v.costruttori,
		"popolazione": v.popolazione(), "scorte": v.scorte, "alberi": alberi, "campi": ris.campi.size(),
		"riserva_rocce": riserva, "merci": merci, "ceppi": ris._ceppi.size()}


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
			if not perc.is_empty() and rete.costruisci_strada(perc):
				break
		if rete.collegata(e.bandiera):
			print("%s in %s (bandierina %s, punteggio %.1f)" % [tipo, c, f, candidati[k][0]])
			return e
		v.demolisci(e)
	print("Impossibile piazzare ", tipo)
	return null
