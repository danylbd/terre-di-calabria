extends SceneTree
## Test automatico della rifinitura grafica G6: per ogni popolo, ogni edificio che può costruire ha uno
## sprite che esiste; per i popoli già completati, ogni edificio ha l'aspetto del popolo (non quello greco).
## Uso: godot --headless --path . --script tools/test/test_aspetto.gd

## popoli con tutti gli edifici rifatti nel loro stile (si allunga a ogni step G6)
const COMPLETI := ["brettii", "romani", "saraceni"]

var errori := 0


func _initialize() -> void:
	for popolo in Popoli.DATI:
		var mancano := []
		var greci := []
		for cat in CatalogoEdifici.CATEGORIE:
			for tipo in CatalogoEdifici.della_categoria(cat, popolo):
				var nome := Popoli.sprite(tipo, popolo)
				if not ResourceLoader.exists("res://assets/grafica/%s.png" % nome):
					mancano.append(nome)
				elif popolo != "greci" and nome == tipo and not CatalogoEdifici.dati(tipo).has("popolo"):
					greci.append(tipo)
		_controlla(mancano.is_empty(), "%s: tutti gli sprite esistono %s" % [popolo, mancano])
		if popolo in COMPLETI:
			_controlla(greci.is_empty(), "%s: tutti gli edifici hanno il loro aspetto %s" % [popolo, greci])
		else:
			print("  ..  %s: %d edifici ancora con l'aspetto greco" % [popolo, greci.size()])
	print("RISULTATO: %s (%d errori)" % ["OK" if errori == 0 else "FALLITO", errori])
	quit(1 if errori > 0 else 0)


func _controlla(ok: bool, cosa: String) -> void:
	print(("  ok  " if ok else "  NO  ") + cosa)
	if not ok:
		errori += 1
