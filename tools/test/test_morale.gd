extends SceneTree
## Test automatico dello step 32 (cibo, morale ed esperienza delle schiere): la schiera prende le razioni dal
## magazzino e le consuma; senza cibo perde morale e soldati; vicino al magazzino si rifornisce e si rinforza
## con la riserva; i duelli vinti danno esperienza e livelli; il morale e il livello cambiano i duelli; il
## livello resta nel salvataggio.
## Uso: godot --headless --path . --script tools/test/test_morale.gd

const FILE := "user://test_morale.json"

var p: Node2D
var errori := 0


func _initialize() -> void:
	Impostazioni.mappa = "costa_ionica"
	Impostazioni.modalita = "guerra"
	Impostazioni.missione = ""
	Impostazioni.popolo = "romani"
	p = load("res://src/mappa/partita.tscn").instantiate()
	root.add_child(p)
	_prova.call_deferred()


func _prova() -> void:
	await process_frame
	var v: Villaggio = p.villaggio
	var d: DatiMappa = p.dati
	var sch: Schiere = p.schiere
	var mag: Edificio = v.magazzino()
	var caserma: Edificio = null
	for y in range(d.villaggio.y - 6, d.villaggio.y + 7):
		for x in range(d.villaggio.x - 6, d.villaggio.x + 7):
			if caserma == null and v.puo_costruire("caserma", Vector2i(x, y)):
				caserma = v.costruisci("caserma", Vector2i(x, y), true, true)
	v.soldati = 16
	v.scorte["pane"] = 8
	v.scorte["pesce"] = 50
	_controlla(sch.forma(caserma), "la schiera di Gaio Settimio esce dalla caserma")
	_controlla(sch.schiera["razioni"] == Schiere.RAZIONI_MAX and v.scorte["pane"] == 0, "prende 20 razioni dal magazzino (pane %d, pesce %d)" % [v.scorte["pane"], v.scorte["pesce"]])
	_controlla(sch.schiera["morale"] == 70 and sch.livello() == 1, "morale 70, livello 1")

	# lontano dal magazzino: mangia, poi la fame
	var capo: Colono = sch.schiera["condottiero"]
	capo.pos = mag.centro() + Vector2(20, 0)
	sch._mangia(Schiere.CONSUMO + 0.1)
	_controlla(sch.schiera["razioni"] == Schiere.RAZIONI_MAX - 1, "dopo un po' ha mangiato una razione")
	sch.schiera["razioni"] = 0
	var prima := sch.soldati()
	var morale: int = sch.schiera["morale"]
	sch._mangia(Schiere.FAME + 0.1)
	_controlla(sch.soldati() == prima - 1 and sch.schiera["morale"] < morale, "senza razioni la fame porta via un soldato e il morale cala")

	# vicino al magazzino: rifornimento e rinforzi
	capo.pos = mag.centro() + Vector2(1, 1)
	sch._rifornisci()
	_controlla(sch.schiera["razioni"] == Schiere.RAZIONI_MAX and sch.soldati() == Schiere.MAX_SOLDATI, "al magazzino razioni piene e soldati di riserva di nuovo nella schiera")

	# morale ed esperienza nei duelli
	sch.schiera["morale"] = 100
	var alto := sch.probabilita_vittoria()
	sch.schiera["morale"] = 10
	var basso := sch.probabilita_vittoria()
	_controlla(alto > basso + 0.1, "il morale cambia i duelli (%.2f contro %.2f)" % [alto, basso])
	sch.schiera["morale"] = 70
	var liv1 := sch.probabilita_vittoria()
	sch.esperienza = Schiere.ESPERIENZA_LIVELLO * 3
	_controlla(sch.livello() == 4 and sch.probabilita_vittoria() > liv1, "dopo 30 duelli vinti il condottiero è al livello 4 e combatte meglio")
	var torre: Edificio = v.nemici.values()[0]
	torre.soldati = 50
	sch._rng.seed = 3
	var esp := sch.esperienza
	for k in 10:
		sch._combatti(torre)
	_controlla(sch.esperienza > esp, "i duelli vinti danno esperienza (%d → %d)" % [esp, sch.esperienza])

	# il livello resta nel salvataggio
	var esp_salvata := sch.esperienza
	_controlla(Salvataggio.salva(p, FILE), "partita salvata")
	Salvataggio.da_caricare = FILE
	p.queue_free()
	await process_frame
	p = load("res://src/mappa/partita.tscn").instantiate()
	root.add_child(p)
	await process_frame
	_controlla(p.schiere.esperienza == esp_salvata, "ricaricando il condottiero ha la sua esperienza (%d)" % p.schiere.esperienza)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(FILE))
	Impostazioni.popolo = "greci"
	Popoli.giocatore = "greci"
	Impostazioni.modalita = "pace_poi_guerra"
	print("RISULTATO: %s (%d errori)" % ["OK" if errori == 0 else "FALLITO", errori])
	quit(1 if errori > 0 else 0)


func _controlla(ok: bool, cosa: String) -> void:
	print(("  ok  " if ok else "  NO  ") + cosa)
	if not ok:
		errori += 1
