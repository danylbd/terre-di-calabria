extends SceneTree
## Un edificio deve poter essere costruito anche se ogni accesso perimetrale ha già una bandierina.

var errori := 0


func _initialize() -> void:
	var partita: Node = load("res://src/mappa/partita.tscn").instantiate()
	root.add_child(partita)
	_verifica.call_deferred(partita)


func _verifica(partita: Node) -> void:
	await process_frame
	var villaggio: Villaggio = partita.villaggio
	var dati: DatiMappa = partita.dati
	var posto := Vector2i(-1, -1)
	var accessi: Array[Vector2i] = []
	var taglia: int = CatalogoEdifici.dati("casa_greca")["taglia"]
	for y in range(4, dati.altezza - 4):
		for x in range(4, dati.larghezza - 4):
			var candidato := Vector2i(x, y)
			if not villaggio.puo_costruire("casa_greca", candidato):
				continue
			var posizioni: Array[Vector2i] = []
			var valide := true
			var perimetro: Array[Vector2i] = []
			for k in taglia:
				perimetro.append(Vector2i(candidato.x + k, candidato.y + taglia))
				perimetro.append(Vector2i(candidato.x + taglia, candidato.y + k))
				perimetro.append(Vector2i(candidato.x - 1, candidato.y + k))
				perimetro.append(Vector2i(candidato.x + k, candidato.y - 1))
			for p in perimetro:
				if not dati.nel_territorio(p.x, p.y) or dati.occupante(p.x, p.y) != 0 or villaggio.rete.bandiera_in(p):
					valide = false
					break
				posizioni.append(p)
			if valide:
				posto = candidato
				accessi = posizioni
				break
		if posto.x >= 0:
			break
	_controlla(posto.x >= 0, "trovata una casa edificabile con accessi liberi da saturare")
	if posto.x >= 0:
		for p in accessi:
			villaggio.rete.aggiungi_bandiera(p, false, true)
		_controlla(accessi.all(func(p): return villaggio.rete.bandiera_in(p)), "tutti i lati della casa sono occupati da bandierine")
		_controlla(villaggio.puo_costruire("casa_greca", posto), "la casa resta costruibile senza spazio per una nuova bandierina (%s)" % villaggio.motivo_impossibile("casa_greca", posto))
		var casa := villaggio.costruisci("casa_greca", posto)
		_controlla(casa != null, "la casa viene costruita anche con tutti gli accessi occupati")
		if casa:
			_controlla(accessi.has(casa.bandiera), "il cantiere riusa un nodo di rete vicino come accesso logistico")
	partita.queue_free()
	await process_frame
	print("RISULTATO: %s (%d errori)" % ["OK" if errori == 0 else "FALLITO", errori])
	quit(1 if errori > 0 else 0)


func _controlla(ok: bool, testo: String) -> void:
	print(("  ok  " if ok else "  NO  ") + testo)
	if not ok:
		errori += 1
