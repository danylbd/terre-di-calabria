extends SceneTree
## Test automatico dello step 31 (condottieri e schiere): dalla caserma esce il condottiero con i soldati di
## riserva; si sceglie con un clic e va dove gli si dice camminando sulla terra; attacca e conquista una torre
## nemica e un villaggio indigeno; il salvataggio rimette i soldati nella riserva; in pace non c'è.
## Uso: godot --headless --path . --script tools/test/test_schiere.gd (FOTO=file.png senza --headless)

const VELOCITA := 8.0
const FILE := "user://test_schiere.json"

var p: Node2D
var errori := 0


func _initialize() -> void:
	Impostazioni.mappa = "monteleone"
	Impostazioni.modalita = "guerra"
	Impostazioni.missione = ""
	Impostazioni.popolo = "greci"
	p = load("res://src/mappa/partita.tscn").instantiate()
	root.add_child(p)
	_prova.call_deferred()


func _prova() -> void:
	await process_frame
	var v: Villaggio = p.villaggio
	var d: DatiMappa = p.dati
	var sch: Schiere = p.schiere
	_controlla(Schiere.attive(), "in guerra le schiere ci sono")
	var caserma: Edificio = null
	for y in range(d.villaggio.y - 8, d.villaggio.y + 9):
		for x in range(d.villaggio.x - 8, d.villaggio.x + 9):
			if caserma == null and v.puo_costruire("caserma", Vector2i(x, y)):
				caserma = v.costruisci("caserma", Vector2i(x, y), true, true)
	_controlla(caserma != null, "caserma costruita")
	_controlla(sch.motivo_no_schiera().begins_with("Servono soldati"), "senza soldati niente schiera")
	v.soldati = 14
	_controlla(sch.forma(caserma) and sch.soldati() == 12 and v.soldati == 2, "il condottiero esce con 12 soldati (2 restano in riserva)")
	_controlla(not sch.forma(caserma), "un condottiero solo per volta")
	var capo: Colono = sch.schiera["condottiero"]
	_controlla(sch.in_casella(Vector2i(capo.pos.floor())), "un clic sul condottiero lo trova")

	# marcia
	var meta := Vector2i(capo.pos.floor()) + Vector2i(6, 3)
	while not sch._camminabile(meta):
		meta += Vector2i(1, 0)
	_controlla(sch.muovi(meta), "ordine: vai in %s" % meta)
	_controlla(not sch.muovi(Vector2i(30, 8)), "nel mare non si cammina")
	Engine.time_scale = VELOCITA
	await create_timer(20.0).timeout
	Engine.time_scale = 1.0
	_controlla(capo.pos.distance_to(Vector2(meta) + Vector2(0.5, 0.5)) < 1.0, "il condottiero è arrivato (%s)" % capo.pos)
	var s0: Colono = sch.schiera["soldati"][0]
	_controlla(s0.pos.distance_to(capo.pos) < 3.0, "i soldati lo seguono in formazione")

	# assalto a una torre nemica
	var torre: Edificio = v.nemici.values()[0]
	torre.soldati = 3
	var casella_torre := torre.casella
	var id_torre := torre.id
	sch._rng.seed = 11
	_controlla(sch.attacca(torre), "ordine: attacca la torre dei Brettii in %s" % casella_torre)
	Engine.time_scale = VELOCITA
	for k in 60:
		await create_timer(2.0).timeout
		if not v.nemici.has(id_torre) or not sch.esiste():
			break
	Engine.time_scale = 1.0
	var nostra := v.edificio_in(casella_torre)
	_controlla(nostra != null and nostra.proprietario == 1, "la torre è conquistata dalla schiera (rimasti %d soldati)" % sch.soldati())

	var foto := OS.get_environment("FOTO")
	if foto != "" and sch.esiste():
		sch.scegli(true)
		p.camera.set_process(false)
		p.camera.zoom = Vector2.ONE * 1.0
		p.camera.position = d.a_schermo(sch.schiera["condottiero"].pos.x, sch.schiera["condottiero"].pos.y)
		for k in 8:
			await process_frame
		root.get_viewport().get_texture().get_image().save_png(foto)
		print("Screenshot salvato in ", foto)

	# assalto a un villaggio indigeno
	if sch.esiste():
		var ind: VillaggiIndigeni = p.indigeni
		var i := 2      # i pastori delle Serre
		ind.elenco[i]["abitanti"] = 15
		_controlla(sch.attacca(i), "ordine: attacca %s" % ind.elenco[i]["nome"])
		Engine.time_scale = VELOCITA
		for k in 80:
			await create_timer(2.0).timeout
			if ind.elenco[i]["stato"] == "nostro" or not sch.esiste():
				break
		Engine.time_scale = 1.0
		_controlla(ind.elenco[i]["stato"] == "nostro", "%s conquistato dalla schiera" % ind.elenco[i]["nome"])

	# salvataggio: la schiera torna nella riserva
	var totale := v.soldati + sch.soldati()
	_controlla(Salvataggio.salva(p, FILE), "partita salvata")
	Salvataggio.da_caricare = FILE
	p.queue_free()
	await process_frame
	p = load("res://src/mappa/partita.tscn").instantiate()
	root.add_child(p)
	await process_frame
	_controlla(p.villaggio.soldati == totale, "ricaricando i soldati della schiera sono nella riserva (%d)" % p.villaggio.soldati)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(FILE))
	Impostazioni.modalita = "pace"
	_controlla(not Schiere.attive(), "in pace le schiere non ci sono")
	Impostazioni.modalita = "pace_poi_guerra"
	Impostazioni.mappa = "costa_ionica"
	print("RISULTATO: %s (%d errori)" % ["OK" if errori == 0 else "FALLITO", errori])
	quit(1 if errori > 0 else 0)


func _controlla(ok: bool, cosa: String) -> void:
	print(("  ok  " if ok else "  NO  ") + cosa)
	if not ok:
		errori += 1
