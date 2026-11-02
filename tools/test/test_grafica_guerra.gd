extends SceneTree
## Test automatico dello step 40 (rifinitura grafica di guerra): ogni tipo di villaggio indigeno ha i suoi tre
## modelli e li usa; ci sono tutti gli sprite della guerra (macchine d'assedio, elefanti, condottieri).
## Uso: godot --headless --path . --script tools/test/test_grafica_guerra.gd

var errori := 0


func _initialize() -> void:
	for tipo in VillaggiIndigeni.TIPI:
		var propri := true
		for k in 3:
			var nome := VillaggiIndigeni.sprite_di(tipo, k)
			if nome != "indigeni_%s_%d" % [tipo, k]:
				propri = false
		_controlla(propri, "il villaggio dei %s ha i suoi tre modelli" % VillaggiIndigeni.TIPI[tipo]["nome"])
	var guerra := ["ariete", "ariete_colpo", "onagro", "onagro_tiro", "nave_guerra"]
	for popolo in Popoli.DATI:
		guerra.append("condottiero_" + popolo)
		guerra.append("condottiero_%s_lotta" % popolo)
	var mancano := guerra.filter(func(n): return not ResourceLoader.exists("res://assets/grafica/%s.png" % n))
	_controlla(mancano.is_empty(), "ci sono tutti gli sprite della guerra %s" % [mancano])
	print("RISULTATO: %s (%d errori)" % ["OK" if errori == 0 else "FALLITO", errori])
	quit(1 if errori > 0 else 0)


func _controlla(ok: bool, cosa: String) -> void:
	print(("  ok  " if ok else "  NO  ") + cosa)
	if not ok:
		errori += 1
