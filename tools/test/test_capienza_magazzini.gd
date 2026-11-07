extends SceneTree
## La capacità di stoccaggio è disponibile solo quando il magazzino è completato.
## Uso: godot --headless --path . --script tools/test/test_capienza_magazzini.gd

var errori := 0
var oggetti: Node2D


func _initialize() -> void:
	oggetti = Node2D.new()
	root.add_child(oggetti)
	var villaggio := Villaggio.new(null, oggetti)
	root.add_child(villaggio)
	_verifica.call_deferred(villaggio)


func _verifica(villaggio: Villaggio) -> void:
	await process_frame
	var deposito := Edificio.new()
	deposito.tipo = "magazzino"
	deposito.finito = true
	villaggio.edifici[1] = deposito
	_controlla(villaggio.capienza_magazzini() == 200, "un magazzino completo offre 200 posti")
	var cantiere := Edificio.new()
	cantiere.tipo = "magazzino"
	cantiere.finito = false
	villaggio.edifici[-1] = cantiere
	_controlla(villaggio.capienza_magazzini() == 200, "un cantiere di magazzino non aggiunge ancora capacità")
	cantiere.finito = true
	_controlla(villaggio.capienza_magazzini() == 400, "un secondo magazzino completato aggiunge 200 posti")
	villaggio.edifici.erase(-1)
	_fine()


func _controlla(ok: bool, descrizione: String) -> void:
	print(("  ok  " if ok else "  NO  ") + descrizione)
	if not ok:
		errori += 1


func _fine() -> void:
	print("RISULTATO: %s (%d errori)" % ["OK" if errori == 0 else "FALLITO", errori])
	for nodo in root.get_children():
		nodo.queue_free()
	await process_frame
	await process_frame
	quit(1 if errori > 0 else 0)
