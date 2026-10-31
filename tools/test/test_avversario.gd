extends SceneTree
## Test automatico dello step 14 (avversario): i Brettii alzano torri nuove, rispettano la tregua,
## attaccano il nostro forte più debole e se vincono lo prendono (perdiamo i confini intorno);
## non attaccano chi è più forte; il loro stato si salva.
## Uso: godot --headless --path . --script tools/test/test_avversario.gd

const VELOCITA := 8.0
const FILE := "user://test_avversario.json"

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
	var av: Avversario = p.avversario
	var g: Guerra = p.guerra
	var mag := v.magazzino()
	v.scorte["assi"] = 80
	v.scorte["pietra"] = 80

	# espansione
	var prima := v.nemici.size()
	var nuova := av.espandi()
	_controlla(nuova != null and v.nemici.size() == prima + 1, "i Brettii alzano una torre nuova (%d -> %d)" % [prima, v.nemici.size()])
	var fuori := true
	for y in range(nuova.casella.y, nuova.casella.y + 2):
		for x in range(nuova.casella.x, nuova.casella.x + 2):
			if p.dati.proprietario(x, y) != 2:
				fuori = false
	_controlla(fuori, "la torre nuova sta nel loro territorio, non nel nostro")

	# un nostro forte verso l'avamposto più vicino, sguarnito (solo la guardia)
	var bersaglio: Edificio = null
	for n in v.nemici.values():
		if bersaglio == null or Vector2(n.centro() - mag.centro()).length() < Vector2(bersaglio.centro() - mag.centro()).length():
			bersaglio = n
	var torre := _piazza("torre", func(f): return -Vector2(Vector2(f) - bersaglio.centro()).length(), true)
	_controlla(torre != null, "nostra torre verso i Brettii")
	var casa := _piazza("casa_greca", func(f): return -Vector2(f - Vector2i(torre.centro())).length() if Vector2(f - Vector2i(mag.centro())).length() > 9.5 else -99.0)
	print("torre a %.1f caselle dall'avamposto; casa in %s" % [Vector2(torre.centro() - bersaglio.centro()).length(), casa.casella if casa else null])

	# tregua: niente attacchi all'inizio
	bersaglio.soldati = 5
	Engine.time_scale = VELOCITA
	await create_timer(Avversario.OGNI_ATTACCO + 20.0).timeout
	Engine.time_scale = 1.0
	_controlla(is_instance_valid(torre) and not torre.is_queued_for_deletion() and g._soldati.filter(func(s): return s["lato"] == 2).is_empty(),
		"durante la tregua i Brettii non attaccano")

	# finita la tregua: attaccano il forte sguarnito e lo prendono
	av.tempo = Avversario.TREGUA + 1.0
	var mio := _conta(1)
	_controlla(av.attacca(), "i Brettii partono all'attacco della torre sguarnita")
	Engine.time_scale = VELOCITA
	for k in 60:
		await create_timer(1.0).timeout
		if not is_instance_valid(torre) or torre.is_queued_for_deletion():
			break
	Engine.time_scale = 1.0
	await process_frame
	_controlla(not is_instance_valid(torre) or torre.is_queued_for_deletion(), "la nostra torre è caduta")
	_controlla(_conta(1) < mio, "abbiamo perso territorio (%d -> %d)" % [mio, _conta(1)])
	_controlla(casa == null or not is_instance_valid(casa) or casa.is_queued_for_deletion(), "la casa rimasta fuori dai confini è bruciata")
	_controlla(v.nemici.values().any(func(n): return Vector2(n.casella - (bersaglio.casella if is_instance_valid(bersaglio) else n.casella)).length() > 0.5), "al posto della torre c'è una torre dei Brettii")

	# chi è più forte non viene attaccato
	for n in v.nemici.values():
		n.soldati = 4
	var castello := _piazza("castello", func(f): return -Vector2(f - mag.bandiera).length(), true)
	castello.soldati = 8
	for e in v.edifici.values():
		if e != castello and CatalogoEdifici.dati(e.tipo).has("soldati_max"):
			e.soldati = 8
	var lontani := v.nemici.values().filter(func(n): return Vector2(n.centro() - castello.centro()).length() <= Guerra.RAGGIO_ATTACCO).size()
	_controlla(not av.attacca(), "contro un castello con 8 soldati i Brettii non attaccano (%d torri vicine)" % lontani)

	# salvataggio dello stato dei Brettii
	av.tempo = 1234.0
	var torri_loro := v.nemici.size()
	Salvataggio.salva(p, FILE)
	p.queue_free()
	await process_frame
	Salvataggio.da_caricare = FILE
	p = load("res://src/mappa/partita.tscn").instantiate()
	root.add_child(p)
	await process_frame
	await process_frame
	_controlla(absf(p.avversario.tempo - 1234.0) < 1.0 and p.villaggio.nemici.size() == torri_loro, "i Brettii e il loro tempo si salvano")
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
