class_name SegniMappa
extends Node2D
## Disegna sul terreno i pali di confine del territorio e, in modalità costruzione,
## i segni dei posti dove l'edificio scelto si può costruire.

var dati: DatiMappa
var villaggio: Villaggio
var tipo_scelto := ""
var mostra_bandiere := false
var inizio_strada := Vector2i(-1, -1)
var anteprima_confine := []          # [centro (caselle), raggio] del forte che si sta piazzando
const COLORI_POPOLI := [Color(0, 0, 0, 0), Color("2f78a8"), Color("b0322a"), Color("d9a441"), Color("4f8a2a")]
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
	if anteprima_confine.size() == 2:
		var centro: Vector2 = anteprima_confine[0]
		var r: float = anteprima_confine[1]
		var punti := PackedVector2Array()
		for k in 65:
			var a := k * TAU / 64
			punti.append(dati.a_schermo(centro.x + cos(a) * r, centro.y + sin(a) * r))
		draw_polyline(punti, Color(Palette.INCHIOSTRO, 0.5), 5.0)
		draw_polyline(punti, Color(COLORI_POPOLI[1], 0.9), 2.5)
	if mostra_bandiere and villaggio.rete:
		for c in villaggio.rete.bandiere:
			var p := dati.a_schermo(c.x + 0.5, c.y + 0.5)
			var scelta: bool = c == inizio_strada
			var col := Palette.OCRA if scelta else Color(Palette.PERGAMENA_CHIARA, 0.9)
			draw_set_transform(p, 0.0, Vector2(1.0, 0.5))
			draw_arc(Vector2.ZERO, 26.0 if scelta else 18.0, 0, TAU, 32, Color(Palette.INCHIOSTRO, 0.6), 6.0)
			draw_arc(Vector2.ZERO, 26.0 if scelta else 18.0, 0, TAU, 32, col, 3.0)
			draw_set_transform(Vector2.ZERO)
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


## Pali di confine sul bordo di ogni territorio, col colore del popolo che lo possiede.
func _disegna_confini() -> void:
	for y in dati.altezza:
		for x in dati.larghezza:
			var chi := dati.proprietario(x, y)
			if chi == 0:
				continue
			var col: Color = COLORI_POPOLI[chi % COLORI_POPOLI.size()]
			for v in [[Vector2i(1, 0), Vector2(1, 0.5)], [Vector2i(-1, 0), Vector2(0, 0.5)], [Vector2i(0, 1), Vector2(0.5, 1)], [Vector2i(0, -1), Vector2(0.5, 0)]]:
				var n: Vector2i = Vector2i(x, y) + v[0]
				if dati.proprietario(n.x, n.y) == chi:
					continue
				var m: Vector2 = Vector2(x, y) + v[1]
				var p := dati.a_schermo(m.x, m.y)
				draw_circle(p + Vector2(3, 1), 4.0, Color(0, 0, 0, 0.25))
				draw_line(p, p + Vector2(0, -16), Color(Palette.INCHIOSTRO, 0.9), 3.0)
				draw_line(p, p + Vector2(0, -16), Palette.PERGAMENA, 1.5)
				draw_circle(p + Vector2(0, -17), 3.5, col)
				draw_circle(p + Vector2(-1, -18), 1.2, Palette.PERGAMENA_CHIARA)
