extends SceneTree
## Test automatico dello step 30 (villaggi indigeni): sulla mappa di Monteleone nascono Tropea, Pizzo e i
## pastori delle Serre; occupano il loro posto; crescono; con i doni diventano alleati e mandano merci; si
## conquistano solo fuori dalla pace, con soldati e un forte vicino, e allargano i confini; il salvataggio li
## ricorda; nelle missioni non ci sono.
## Uso: godot --headless --path . --script tools/test/test_indigeni.gd (FOTO=file.png senza --headless)

const FILE := "user://test_indigeni.json"

var p: Node2D
var errori := 0


func _initialize() -> void:
	Impostazioni.mappa = "monteleone"
	Impostazioni.modalita = "pace_poi_guerra"
	Impostazioni.missione = ""
	Impostazioni.popolo = "greci"
	p = load("res://src/mappa/partita.tscn").instantiate()
	root.add_child(p)
	_prova.call_deferred()


func _prova() -> void:
	await process_frame
	var ind: VillaggiIndigeni = p.indigeni
	var v: Villaggio = p.villaggio
	var d: DatiMappa = p.dati
	var nomi: Array = ind.elenco.map(func(x): return x["nome"])
	_controlla(nomi == ["Tropea", "Pizzo", "Pastori delle Serre"], "nascono Tropea, Pizzo e i pastori delle Serre %s" % [nomi])
	if ind.elenco.size() < 3:
		_fine()
		return
	var tropea: Dictionary = ind.elenco[0]
	_controlla(Vector2(tropea["casella"] - d.luoghi["Tropea"]).length() < 12.0, "Tropea sta vicino alla Tropea vera (%s)" % tropea["casella"])
	var c: Vector2i = tropea["casella"]
	_controlla(d.occupante(c.x + 1, c.y + 1) != 0 and not v.puo_costruire("casa_greca", c), "il villaggio occupa il suo posto")
	_controlla(ind.villaggio_in(c + Vector2i(2, 2)) == 0 and ind.villaggio_in(d.villaggio) == -1, "un clic sul villaggio lo trova")

	# crescita
	var ab: int = tropea["abitanti"]
	ind._process(VillaggiIndigeni.CRESCITA + 1.0)
	_controlla(tropea["abitanti"] == ab + 1, "il villaggio cresce da solo")

	# i doni
	_controlla(ind.dona(0) == 0 and tropea["stato"] == "neutrale", "senza lusso in magazzino niente doni")
	v.scorte["olio"] = 4
	_controlla(ind.dona(0) == 4 and tropea["stato"] == "neutrale", "i primi doni non bastano (4 su %d)" % ind.doni_necessari(0))
	v.scorte["vino"] = 20
	ind.dona(0)
	_controlla(tropea["stato"] == "alleato", "con abbastanza doni Tropea diventa alleata")
	var olio: int = v.scorte.get("olio", 0)
	ind._process(VillaggiIndigeni.PERIODO + 0.1)
	_controlla(v.scorte.get("olio", 0) > olio, "l'alleato manda olio al magazzino (%d → %d)" % [olio, v.scorte.get("olio", 0)])

	# la conquista
	_controlla(ind.motivo_no_conquista(1).begins_with("Servono soldati"), "senza soldati non si attacca")
	v.soldati = 30
	_controlla(ind.motivo_no_conquista(1).begins_with("Serve un nostro forte"), "senza un forte vicino non si attacca")
	var pizzo: Dictionary = ind.elenco[1]
	var vicino := Vector2i(pizzo["casella"]) + Vector2i(-6, 4)
	var forte := v.costruisci("torre", vicino, true, true)
	forte.presidiata = true
	v._ricalcola_territorio()
	_controlla(ind.motivo_no_conquista(1) == "", "con soldati e un forte vicino si può attaccare")
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	_controlla(ind.conquista(1, rng) and pizzo["stato"] == "nostro", "Pizzo è conquistato (soldati rimasti %d)" % v.soldati)
	var pc: Vector2i = Vector2i(pizzo["casella"]) + Vector2i(2, 2)
	_controlla(d.nel_territorio(pc.x, pc.y) and d.nel_territorio(pc.x + 4, pc.y), "i confini intorno a Pizzo sono nostri")
	Impostazioni.modalita = "pace"
	_controlla(ind.motivo_no_conquista(2) != "", "in pace non si conquista")
	Impostazioni.modalita = "pace_poi_guerra"

	var foto := OS.get_environment("FOTO")
	if foto != "":
		p.camera.set_process(false)
		p.camera.zoom = Vector2.ONE * 0.7
		p.camera.position = d.a_schermo(c.x + 2.5, c.y + 2.5)
		for k in 8:
			await process_frame
		root.get_viewport().get_texture().get_image().save_png(foto)
		print("Screenshot salvato in ", foto)

	# salvataggio
	_controlla(Salvataggio.salva(p, FILE), "partita salvata")
	Salvataggio.da_caricare = FILE
	p.queue_free()
	await process_frame
	p = load("res://src/mappa/partita.tscn").instantiate()
	root.add_child(p)
	await process_frame
	var stati: Array = p.indigeni.elenco.map(func(x): return x["stato"])
	_controlla(stati == ["alleato", "nostro", "neutrale"], "ricaricando i villaggi tornano come erano %s" % [stati])
	_controlla(p.dati.nel_territorio(pc.x, pc.y), "e i confini di Pizzo restano nostri")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(FILE))

	# nelle missioni niente villaggi indigeni
	p.queue_free()
	await process_frame
	Missione.progressi = "user://test_indigeni_progressi.json"
	Impostazioni.missione = "naufragio"
	p = load("res://src/mappa/partita.tscn").instantiate()
	root.add_child(p)
	await process_frame
	_controlla(p.indigeni.elenco.is_empty(), "nelle missioni della campagna non ci sono")
	Impostazioni.missione = ""
	Impostazioni.mappa = "costa_ionica"
	_fine()


func _fine() -> void:
	print("RISULTATO: %s (%d errori)" % ["OK" if errori == 0 else "FALLITO", errori])
	quit(1 if errori > 0 else 0)


func _controlla(ok: bool, cosa: String) -> void:
	print(("  ok  " if ok else "  NO  ") + cosa)
	if not ok:
		errori += 1
