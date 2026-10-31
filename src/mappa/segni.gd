class_name SegniMappa
extends Node2D
## Disegna sul terreno i pali di confine del territorio e, in modalità costruzione,
## i segni dei posti dove l'edificio scelto si può costruire.

var dati: DatiMappa
var villaggio: Villaggio
var tipo_scelto := ""
var _posti: Array[Vector2i] = []


func prepara(d: DatiMappa, v: Villaggio) -> void:
	dati = d
	villaggio = v


func aggiorna() -> void:
	_posti.clear()
	if tipo_scelto != "":
		var taglia: int = CatalogoEdifici.dati(tipo_scelto)["taglia"]
		for y in dati.altezza:
			for x in dati.larghezza:
				if dati.nel_territorio(x, y) and villaggio.motivo_impossibile(tipo_scelto, Vector2i(x, y), false) == "":
					_posti.append(Vector2i(x, y))
	queue_redraw()


func _draw() -> void:
	_disegna_confini()
	if tipo_scelto == "":
		return
	var taglia: int = CatalogoEdifici.dati(tipo_scelto)["taglia"]
	var r := 9.0 if taglia == 1 else 15.0
	for c in _posti:
		var p := dati.a_schermo(c.x + taglia * 0.5, c.y + taglia * 0.5)
		var rombo := PackedVector2Array([p + Vector2(0, -r * 0.5), p + Vector2(r, 0), p + Vector2(0, r * 0.5), p + Vector2(-r, 0)])
		draw_colored_polygon(rombo, Color(Palette.OCRA, 0.75))
		rombo.append(rombo[0])
		draw_polyline(rombo, Color(Palette.INCHIOSTRO, 0.7), 1.5)


func _disegna_confini() -> void:
	var col := Color("2f78a8")
	for y in dati.altezza:
		for x in dati.larghezza:
			if not dati.nel_territorio(x, y):
				continue
			for v in [[Vector2i(1, 0), Vector2(1, 0.5)], [Vector2i(-1, 0), Vector2(0, 0.5)], [Vector2i(0, 1), Vector2(0.5, 1)], [Vector2i(0, -1), Vector2(0.5, 0)]]:
				var n: Vector2i = Vector2i(x, y) + v[0]
				if dati.nel_territorio(n.x, n.y):
					continue
				var m: Vector2 = Vector2(x, y) + v[1]
				var p := dati.a_schermo(m.x, m.y)
				draw_circle(p + Vector2(3, 1), 4.0, Color(0, 0, 0, 0.25))
				draw_line(p, p + Vector2(0, -16), Color(Palette.INCHIOSTRO, 0.9), 3.0)
				draw_line(p, p + Vector2(0, -16), Palette.PERGAMENA, 1.5)
				draw_circle(p + Vector2(0, -17), 3.5, col)
				draw_circle(p + Vector2(-1, -18), 1.2, Palette.PERGAMENA_CHIARA)
