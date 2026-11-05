extends SceneTree
## Verifica l'importazione di tutti gli atlas vettoriali dei coloni e la loro dimensione.

var errori := 0


func _initialize() -> void:
	var nomi := []
	for p in DirAccess.get_files_at("res://assets/grafica/coloni"):
		if p.ends_with(".svg"):
			nomi.append(p.trim_suffix(".svg"))
	nomi.sort()
	_controlla(nomi.size() == 35, "35 atlas dei coloni presenti (%d)" % nomi.size())
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
