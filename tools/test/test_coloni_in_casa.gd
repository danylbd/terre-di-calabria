extends SceneTree
## I coloni liberi aspettano nelle case, nascono nella propria abitazione e partono da lì al lavoro.

var errori := 0


func _initialize() -> void:
	_prova.call_deferred()


func _prova() -> void:
	var partita: Node2D = load("res://src/mappa/partita.tscn").instantiate()
	root.add_child(partita)
	await process_frame
	var villaggio: Villaggio = partita.villaggio
	villaggio._ripartisci_coloni_libere()
	var totale := 0
	for n in villaggio._coloni_disponibili_case.values():
		totale += int(n)
	_controlla(totale == villaggio.coloni_liberi, "la riserva libera è assegnata alle abitazioni")
	var origine_valida := false
	for c in villaggio._coloni_disponibili_case:
		var casa := villaggio.edificio_con_bandiera(c)
		if casa and CatalogoEdifici.dati(casa.tipo).get("abitanti", 0) > 0:
			origine_valida = true
	_controlla(origine_valida, "i coloni inattivi aspettano in edifici abitabili")
	var liberi_prima: int = villaggio.coloni_liberi
	var cammino_prima: int = villaggio.in_cammino
	var casa_nascita: Edificio = null
	for e in villaggio.edifici.values():
		if e.finito and CatalogoEdifici.dati(e.tipo).get("abitanti", 0) > 0:
			casa_nascita = e
			break
	if casa_nascita:
		villaggio._nasce_colono(casa_nascita)
		_controlla(villaggio.coloni_liberi == liberi_prima + 1, "il nuovo colono resta nella casa dove nasce")
		_controlla(villaggio.in_cammino == cammino_prima, "la nascita non manda coloni ad aspettare sulle strade")
		_controlla(villaggio._coloni_disponibili_case.get(casa_nascita.bandiera, 0) > 0, "la casa registra il colono libero")
	else:
		_controlla(false, "esiste un'abitazione iniziale")
	var magazzino := villaggio.magazzino()
	var origini_ok := true
	if magazzino and villaggio.prendi_colono():
		var casa_partenza := villaggio.edificio_con_bandiera(villaggio.ultima_origine_colono)
		var cammino := villaggio.rete.percorso_tra_bandiere(villaggio.ultima_origine_colono, magazzino.bandiera)
		origini_ok = casa_partenza != null and not cammino.is_empty() and cammino[0] == Vector2(casa_partenza.bandiera) + Vector2(0.5, 0.5)
		villaggio.restituisci_colono(villaggio.ultima_origine_colono)
	_controlla(origini_ok, "il colono chiamato parte dalla casa assegnata e segue la strada")
	print("RISULTATO: %s (%d errori)" % ["OK" if errori == 0 else "FALLITO", errori])
	partita.queue_free()
	await process_frame
	quit(1 if errori > 0 else 0)


func _controlla(ok: bool, testo: String) -> void:
	print(("  ok  " if ok else "  NO  ") + testo)
	if not ok:
		errori += 1
