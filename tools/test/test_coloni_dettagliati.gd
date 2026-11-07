extends SceneTree
## Verifica l'importazione di tutti gli atlas vettoriali dei coloni e la loro dimensione.

var errori := 0


func _initialize() -> void:
	var nomi := []
	for p in DirAccess.get_files_at("res://assets/grafica/coloni"):
		if p.ends_with(".svg"):
			nomi.append(p.trim_suffix(".svg"))
	nomi.sort()
	var popoli := ["greci", "brettii", "romani", "saraceni", "normanni", "siculi", "sicani", "cartaginesi"]
	var civili := []
	var varianti_civili := 0
	for nome in nomi:
		if not (nome.begins_with("portatore_") or nome.begins_with("lavoratore_")):
			continue
		var e_variante := false
		for popolo in popoli:
			if nome.ends_with("_" + popolo):
				e_variante = true
				break
		if e_variante:
			varianti_civili += 1
		else:
			civili.append(nome)
	_controlla(civili.size() == 35, "35 atlas civili di base presenti (%d)" % civili.size())
	_controlla(varianti_civili == 280, "280 varianti civili per popolo presenti (%d)" % varianti_civili)
	var soldati := ["guardia", "brettio", "brettio_giocatore", "legionario", "cavaliere_leggero",
		"cavaliere_pesante", "guerriero_siculo", "arciere_sicano", "mercenario_cartaginese"]
	var varianti_soldati := 0
	for soldato in soldati:
		for suffisso in ["", "_lotta"]:
			if nomi.has(soldato + suffisso):
				varianti_soldati += 1
	_controlla(varianti_soldati == 18, "18 atlas animati dei tipi di soldato presenti (%d)" % varianti_soldati)
	_controlla(Sprites.atlante_colono("portatore_nessuno", "saraceni") == "c10_portatore_saraceni",
		"il portatore seleziona l'atlante del proprio popolo")
	_controlla(Sprites.atlante_colono("lavoratore_ascia_lavoro", "normanni") == "c10_portatore_normanni",
		"il lavoratore usa l'atlante C10 del proprio popolo")
	for nome in nomi:
		var meta := Sprites.info(nome)
		var texture: Texture2D = Sprites.texture(nome)
		var misura: Array = meta.get("cella", [0, 0])
		var fotogrammi: int = meta.get("fotogrammi", 0)
		var corretto: bool = texture != null and texture.get_width() == misura[0] * fotogrammi and texture.get_height() == misura[1] * 8
		_controlla(corretto, "%s: atlas animato importato" % nome)
	print("RISULTATO: %s (%d errori)" % ["OK" if errori == 0 else "FALLITO", errori])
	quit(1 if errori > 0 else 0)


func _controlla(ok: bool, testo: String) -> void:
	print(("  ok  " if ok else "  NO  ") + testo)
	if not ok:
		errori += 1
