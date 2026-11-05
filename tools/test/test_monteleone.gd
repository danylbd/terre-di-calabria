extends "res://tools/test/test_catena.gd"
## Test automatico dello step V1 (mappa di Monteleone): la stessa catena di test_catena (boscaiolo,
## cava, segheria, guardaboschi) giocata sulla mappa del Vibonese; poi controlla la forma della mappa
## (mare a nord-ovest, Tropea sulla costa, l'Isola, il lago, il colle, il Poro, le Serre) e che il
## salvataggio ricordi la mappa.
## Uso: godot --headless --path . --script tools/test/test_monteleone.gd (FOTO=file.png senza --headless)

const FILE := "user://test_monteleone.json"

var _controllata := false


func _initialize() -> void:
	Impostazioni.mappa = "monteleone"
	Impostazioni.modalita = "pace"
	Impostazioni.missione = ""
	super._initialize()


func _fine() -> void:
	if _controllata:
		return
	_controllata = true
	var d: DatiMappa = p.dati
	var T := DatiMappa.Terreno
	_controlla(p.mappa == "monteleone" and d.larghezza == 144 and d.altezza == 144, "si gioca sulla mappa di Monteleone ampliata 144×144")
	_controlla(d.tipo(30, 8) == T.ACQUA and d.tipo(5, 20) == T.ACQUA, "il mare sta a nord-ovest (golfo di Sant'Eufemia)")
	_controlla(d.tipo(90, 90) != T.ACQUA and d.tipo(60, 60) != T.ACQUA, "l'entroterra a sud-est è terra")
	var tropea: Vector2i = d.luoghi["Tropea"]
	_controlla(d.tipo(tropea.x, tropea.y) != T.ACQUA and _mare_vicino(d, tropea, 4), "Tropea è a terra, sul mare")
	var isola: Vector2i = d.luoghi["Isola"]
	_controlla(d.tipo(isola.x, isola.y) == T.ROCCIA and _mare_vicino(d, isola, 2), "lo scoglio dell'Isola davanti a Tropea")
	var lago: Vector2i = d.luoghi["Lago dell'Angitola"]
	_controlla(d.tipo(lago.x, lago.y) == T.ACQUA, "il lago dell'Angitola")
	_controlla(d.villaggio == d.luoghi["Monteleone"] and d.quota(d.villaggio.x, d.villaggio.y) > 60.0,
		"il villaggio è Monteleone, sul colle (quota %.0f)" % d.quota(d.villaggio.x, d.villaggio.y))
	var poro: Vector2i = d.luoghi["Monte Poro"]
	_controlla(d.quota(poro.x, poro.y) > 70.0, "l'altopiano del Poro è alto (quota %.0f)" % d.quota(poro.x, poro.y))
	var serre := 0.0
	for y in range(40, 96):
		for x in range(75, 96):
			serre = maxf(serre, d.quota(x, y))
	_controlla(serre > 150.0, "le Serre sono montagne (quota massima %.0f)" % serre)
	_controlla(p.find_children("*", "Label", true, false).filter(func(l): return l.text == "Tropea").size() == 1,
		"il nome di Tropea è scritto sulla mappa")

	# il salvataggio ricorda la mappa, anche se nel menu si sceglie l'altra
	_controlla(Salvataggio.salva(p, FILE), "partita salvata")
	_controlla(Salvataggio.mappa_di(FILE) == "monteleone", "il file dice che la mappa è Monteleone")
	Impostazioni.mappa = "costa_ionica"
	Salvataggio.da_caricare = FILE
	var p2 = load("res://src/mappa/partita.tscn").instantiate()
	p.queue_free()
	root.add_child(p2)
	await process_frame
	_controlla(p2.mappa == "monteleone" and p2.dati.larghezza == 144, "ricaricando si torna a Monteleone")
	_controlla(p2.villaggio.edifici.size() == p.villaggio.edifici.size() if is_instance_valid(p) else p2.villaggio.edifici.size() >= 5,
		"gli edifici sono stati ricaricati (%d)" % p2.villaggio.edifici.size())
	DirAccess.remove_absolute(ProjectSettings.globalize_path(FILE))
	Impostazioni.mappa = "costa_ionica"
	super._fine()


func _mare_vicino(d: DatiMappa, c: Vector2i, r: int) -> bool:
	for y in range(c.y - r, c.y + r + 1):
		for x in range(c.x - r, c.x + r + 1):
			if d.dentro(x, y) and d.tipo(x, y) == DatiMappa.Terreno.ACQUA:
				return true
	return false
