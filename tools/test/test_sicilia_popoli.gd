extends "res://tools/test/test_catena.gd"
## Test automatico dello step 26 (Siculi e Sicani): per ognuno dei due popoli, partita libera sulla mappa
## di Zancle in guerra: aspetto, menu con l'edificio unico, la merce speciale prodotta, i mestieri più
## svelti, i nemici (l'uno dell'altro), i soldati e il salvataggio del popolo.
## Uso: godot --headless --path . --script tools/test/test_sicilia_popoli.gd

const FILE := "user://test_sicilia_popoli.json"
const CASI := {
	"siculi": {"unico": "vasaio", "scorte": {"argilla": 10}, "nemico": "sicani", "soldato": "guerriero_siculo", "svelto": "ovile"},
	"sicani": {"unico": "ossidiana", "scorte": {"pietra": 30}, "nemico": "siculi", "soldato": "arciere_sicano", "svelto": "cava"},
}


func _initialize() -> void:
	Impostazioni.mappa = "zancle"
	Impostazioni.modalita = "guerra"
	Impostazioni.missione = ""
	Impostazioni.popolo = "siculi"
	super._initialize()


func _prova() -> void:
	for popolo in CASI:
		await _prova_popolo(popolo, CASI[popolo])
	Impostazioni.popolo = "greci"
	Impostazioni.mappa = "costa_ionica"
	Popoli.giocatore = "greci"
	_fine()


func _nuova_partita(popolo: String) -> void:
	Impostazioni.popolo = popolo
	if p:
		p.queue_free()
		await process_frame
	p = load("res://src/mappa/partita.tscn").instantiate()
	root.add_child(p)
	await process_frame


func _prova_popolo(popolo: String, caso: Dictionary) -> void:
	if p.popolo != popolo:
		await _nuova_partita(popolo)
	var v: Villaggio = p.villaggio
	var mag: Edificio = v.magazzino()
	_controlla(p.popolo == popolo and Popoli.nemico() == caso["nemico"], "%s contro %s" % [popolo, caso["nemico"]])
	_controlla(mag._sprite.texture.resource_path.ends_with("magazzino_%s.png" % popolo), "il magazzino ha l'aspetto dei %s" % popolo)
	var base := CatalogoEdifici.della_categoria("Base", popolo)
	_controlla(caso["unico"] in base and not "agora" in base and not "pecificio" in base, "nel menu c'è %s e non gli edifici unici degli altri" % caso["unico"])
	_controlla(Popoli.soldati(1)[0] == caso["soldato"] and ResourceLoader.exists("res://assets/grafica/%s.png" % caso["soldato"]), "i soldati sono %s" % caso["soldato"])
	_controlla(is_equal_approx(Popoli.durata(caso["svelto"]), 0.8) and is_equal_approx(Popoli.durata("segheria"), 1.0), "%s lavora più in fretta, la segheria no" % caso["svelto"])
	var torri := v.nemici.values()
	_controlla(torri.size() == 2 and torri.all(func(n): return n._sprite.texture.resource_path.ends_with("torre_%s.png" % caso["nemico"])),
		"le torri nemiche sono dei %s" % caso["nemico"])

	for m in caso["scorte"]:
		v.scorte[m] = caso["scorte"][m]
	var unico := _piazza(caso["unico"], func(f): return -Vector2(f - mag.bandiera).length())
	_controlla(unico != null, "%s piazzato e collegato" % caso["unico"])
	Engine.time_scale = VELOCITA
	for k in 20:
		await create_timer(30.0).timeout
		if unico and unico.prodotti > 0:
			break
	Engine.time_scale = 1.0
	_controlla(unico != null and unico.prodotti > 0, "%s ha prodotto la merce speciale (%d)" % [caso["unico"], unico.prodotti if unico else 0])

	_controlla(Salvataggio.salva(p, FILE), "partita salvata")
	Impostazioni.popolo = "greci"
	Salvataggio.da_caricare = FILE
	await _nuova_partita("greci")
	_controlla(p.popolo == popolo, "ricaricando si torna ai %s" % popolo)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(FILE))
