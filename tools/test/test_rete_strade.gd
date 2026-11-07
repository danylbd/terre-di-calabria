extends SceneTree
## Verifica che le strade attraversino il bosco e si innestino sulla rete esistente.

var errori := 0


func _initialize() -> void:
	var partita: Node = load("res://src/mappa/partita.tscn").instantiate()
	root.add_child(partita)
	_verifica.call_deferred(partita)


func _verifica(partita: Node) -> void:
	await process_frame
	var rete: ReteStrade = partita.rete
	var dati: DatiMappa = partita.dati
	var risorse: RisorseNaturali = partita.risorse
	var percorso_albero: Array[Vector2i] = []
	var albero_scelto := Vector2i(-1, -1)
	var bandiera_partenza := Vector2i(-1, -1)
	var innesto := Vector2i(-1, -1)
	for albero in risorse.alberi.keys():
		if not dati.nel_territorio(albero.x, albero.y):
			continue
		if rete.motivo_spaziatura(albero) != "":
			continue
		var partenze: Array = rete.bandiere.keys()
		partenze.sort_custom(func(a, b): return Vector2(a - albero).length_squared() < Vector2(b - albero).length_squared())
		for partenza in partenze:
			var candidato: Array[Vector2i] = rete.trova_percorso(partenza, albero)
			if candidato.size() >= 4 and candidato.size() <= 32:
				percorso_albero = candidato
				albero_scelto = albero
				bandiera_partenza = partenza
				break
		if not percorso_albero.is_empty():
			break
	_controlla(not percorso_albero.is_empty(), "il percorso stradale trova un collegamento attraverso un albero nel bosco")
	if not percorso_albero.is_empty():
		_controlla(percorso_albero.has(albero_scelto), "il tracciato attraversa la casella occupata dall'albero")
		var costruita := rete.costruisci_strada(percorso_albero)
		_controlla(costruita, "si costruisce il collegamento che attraversa il bosco")
		_controlla(not risorse.alberi.has(albero_scelto) and dati.occupante(albero_scelto.x, albero_scelto.y) == 0,
			"l'albero sul sedime viene sgombrato senza bloccare la strada")
		_controlla(rete.bandiera_in(albero_scelto), "il collegamento nel bosco termina con un nodo stradale valido")
		var innesto_vicino_ok := false
		var tratto_vicino := percorso_albero[1]
		for altra in rete.bandiere.keys():
			if altra == bandiera_partenza or altra == albero_scelto:
				continue
			var p_vicino: Array[Vector2i] = rete.trova_percorso(altra, tratto_vicino)
			if not p_vicino.is_empty() and p_vicino[-1] == bandiera_partenza:
				innesto_vicino_ok = true
				break
		_controlla(innesto_vicino_ok, "un clic sul tratto vicino a un nodo usa il collegamento già esistente")
		var percorso_innesto: Array[Vector2i] = []
		for k in range(2, percorso_albero.size() - 2):
			var candidato_innesto: Vector2i = percorso_albero[k]
			if not rete.strada.has(candidato_innesto) or rete.motivo_spaziatura(candidato_innesto) != "":
				continue
			for altra in rete.bandiere.keys():
				if altra == albero_scelto or altra == bandiera_partenza:
					continue
				var p: Array[Vector2i] = rete.trova_percorso(altra, candidato_innesto)
				if not p.is_empty():
					innesto = candidato_innesto
					percorso_innesto = p
					break
			if not percorso_innesto.is_empty():
				break
		_controlla(not percorso_innesto.is_empty(), "la rete consente di unire una strada a un tratto già esistente")
		if not percorso_innesto.is_empty():
			var costruito_innesto := rete.costruisci_strada(percorso_innesto)
			_controlla(costruito_innesto, "si completa la fusione sul tratto esistente")
			_controlla(rete.bandiera_in(innesto) and rete._adiacenti.get(innesto, []).size() >= 3,
				"il punto di fusione collega i due segmenti originali e la nuova strada")
	partita.queue_free()
	await process_frame
	print("RISULTATO: %s (%d errori)" % ["OK" if errori == 0 else "FALLITO", errori])
	quit(1 if errori > 0 else 0)


func _controlla(ok: bool, testo: String) -> void:
	print(("  ok  " if ok else "  NO  ") + testo)
	if not ok:
		errori += 1
