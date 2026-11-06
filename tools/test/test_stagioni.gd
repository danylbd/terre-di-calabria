extends SceneTree
## Test automatico dello step 10 (stagioni): calendario, campi fermi d'inverno e niente semina,
## neve e fiocchi, foglie d'autunno, il calendario nel salvataggio.
## Uso: godot --headless --path . --script tools/test/test_stagioni.gd
## (FOTO=file.png senza --headless: screenshot d'inverno e d'autunno)

const VELOCITA := 8.0
const FILE := "user://test_stagioni.json"

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
	var st: Stagioni = p.stagioni
	var d: DatiMappa = p.dati
	var mag: Edificio = null
	for e in v.edifici.values():
		if e.tipo == "magazzino":
			mag = e
	_controlla(st.stagione() == Stagioni.PRIMAVERA and st.anno() == 1, "si parte in primavera, anno 1 (%s)" % st.nome())
	_controlla(Stagioni.DURATA == 3600.0, "ogni stagione dura un'ora di gioco")
	_controlla(p.barra._stagione.text == st.nome(), "la barra mostra la stagione")

	# inverno: la fattoria non semina, i campi non crescono, nevica
	st.tempo = Stagioni.DURATA * 3 + Stagioni.PASSAGGIO + 1.0
	await create_timer(1.0).timeout
	_controlla(st.inverno(), "salto all'inverno (%s)" % st.nome())
	var neve: float = (p.terreno.material as ShaderMaterial).get_shader_parameter("neve")
	_controlla(neve > 0.9, "la neve copre il terreno (%.2f)" % neve)
	_controlla(st.fiocchi.emitting, "cadono i fiocchi")
	var punti_montagna := {}
	for y in d.altezza:
		for x in d.larghezza:
			if d.tipo(x, y) in [DatiMappa.Terreno.ROCCIA, DatiMappa.Terreno.NEVE] and d.quota(x + 0.5, y + 0.5) >= 80.0:
				var punto := d.a_schermo(x + 0.5, y + 0.5)
				punti_montagna[Vector2i(roundi(punto.x * 100.0), roundi(punto.y * 100.0))] = true
	var fiocchi_alti := not st.fiocchi.emission_points.is_empty() and st.fiocchi.emission_points.size() == punti_montagna.size()
	for punto in st.fiocchi.emission_points:
		if not punti_montagna.has(Vector2i(roundi(punto.x * 100.0), roundi(punto.y * 100.0))):
			fiocchi_alti = false
			break
	_controlla(fiocchi_alti, "la neve cade solo in montagna")
	var c_prova := Vector2i(-1, -1)
	for y in range(mag.casella.y + 5, mag.casella.y + 9):
		for x in range(mag.casella.x - 4, mag.casella.x + 4):
			if c_prova.x < 0 and d.occupante(x, y) == 0 and d.tipo(x, y) == DatiMappa.Terreno.PRATO and not p.rete.strada.has(Vector2i(x, y)):
				c_prova = Vector2i(x, y)
	ris.semina(c_prova, "grano")
	var fatt := _piazza("fattoria", func(f): return _prato_libero(f, 4) - Vector2(f - mag.bandiera).length() * 0.3)
	Engine.time_scale = VELOCITA
	await create_timer(150.0).timeout
	Engine.time_scale = 1.0
	_controlla(st.inverno(), "ancora inverno")
	_controlla(ris.campi[c_prova]["crescita"] == 0.0, "d'inverno il grano non cresce")
	_controlla(fatt.finito and fatt.lavoratore != null, "la fattoria è finita e ha il contadino")
	_controlla(ris.campi_vicini(fatt.bandiera, 5, "grano") <= 1, "d'inverno il contadino non semina")
	var foto := OS.get_environment("FOTO")
	if foto != "":
		p.camera.position = d.a_schermo(mag.centro().x, mag.centro().y)
		for k in 20:
			await process_frame
		root.get_viewport().get_texture().get_image().save_png(foto.get_basename() + "_inverno.png")

	# primavera: si semina e si cresce, la neve se ne va (salto calendario per non attendere un'ora reale).
	Engine.time_scale = VELOCITA
	st.tempo = Stagioni.DURATA * 4 + Stagioni.PASSAGGIO + 1.0
	await process_frame
	_controlla(st.stagione() == Stagioni.PRIMAVERA and st.anno() == 2, "torna la primavera, anno 2 (%s)" % st.nome())
	await create_timer(60.0).timeout
	Engine.time_scale = 1.0
	_controlla(ris.campi[c_prova]["crescita"] > 0.5, "in primavera il grano cresce (%.2f)" % ris.campi[c_prova]["crescita"])
	_controlla(ris.campi_vicini(fatt.bandiera, 5, "grano") > 1, "in primavera il contadino semina")
	neve = (p.terreno.material as ShaderMaterial).get_shader_parameter("neve")
	_controlla(neve < 0.1 and not st.fiocchi.emitting, "la neve si è sciolta")

	# autunno: castagni e querce cambiano colore
	st.tempo = Stagioni.DURATA * 10 + Stagioni.PASSAGGIO + 1.0
	await create_timer(1.0).timeout
	var arancio := false
	for c in ris.alberi:
		for a in ris.alberi[c]:
			if a["specie"] == "castagno" and a["crescita"] >= 3.0 and (a["sprite"] as CanvasItem).self_modulate.b < 0.7:
				arancio = true
	_controlla(arancio, "d'autunno i castagni ingialliscono")
	if foto != "":
		for k in 20:
			await process_frame
		root.get_viewport().get_texture().get_image().save_png(foto.get_basename() + "_autunno.png")
		print("Screenshot salvati")

	# il calendario si salva
	var t := st.tempo
	Salvataggio.salva(p, FILE)
	p.queue_free()
	await process_frame
	Salvataggio.da_caricare = FILE
	p = load("res://src/mappa/partita.tscn").instantiate()
	root.add_child(p)
	await process_frame
	await process_frame
	_controlla(absf(p.stagioni.tempo - t) < 1.0 and p.stagioni.stagione() == Stagioni.AUTUNNO, "il calendario sopravvive al salvataggio (%s)" % p.stagioni.nome())
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
			if not perc.is_empty() and rete.costruisci_strada(perc):
				break
		if rete.collegata(e.bandiera):
			print("%s in %s (bandierina %s, punteggio %.1f)" % [tipo, c, f, candidati[k][0]])
			return e
		v.demolisci(e)
	print("Impossibile piazzare ", tipo)
	return null
