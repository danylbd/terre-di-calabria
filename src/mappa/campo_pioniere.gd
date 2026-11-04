extends Node2D
## Accampamento che rende visibile il nuovo insediamento dei pionieri.


func _draw() -> void:
	# Ombra, tenda di tela e palo con bandiera ocra.
	draw_colored_polygon(PackedVector2Array([Vector2(-24, 2), Vector2(0, 12), Vector2(23, 2), Vector2(0, -4)]), Color(0, 0, 0, 0.22))
	draw_colored_polygon(PackedVector2Array([Vector2(-19, 0), Vector2(0, -17), Vector2(19, 0), Vector2(0, 8)]), Color("b49766"))
	draw_colored_polygon(PackedVector2Array([Vector2(-19, 0), Vector2(0, -17), Vector2(0, 8)]), Color("e1c996"))
	draw_line(Vector2(0, -16), Vector2(0, -40), Color("59402e"), 3.0)
	draw_colored_polygon(PackedVector2Array([Vector2(1, -39), Vector2(17, -34), Vector2(1, -29)]), Palette.OCRA)
	draw_line(Vector2(-23, 4), Vector2(0, 13), Color("6f5940"), 2.0)
	draw_line(Vector2(0, 13), Vector2(23, 4), Color("6f5940"), 2.0)
