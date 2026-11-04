class_name RovinaAntica
extends Node2D
## Piccolo rudere procedurale: mura spezzate, colonne cadute e pietre fra l'erba.

var seme := 1


func _draw() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seme
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.8, 0.6))
	draw_circle(Vector2(0, 8), 20.0, Color(0.1, 0.12, 0.1, 0.2))
	draw_set_transform(Vector2.ZERO)
	# basamenti e muri crollati, in prospettiva isometrica
	for blocco in [[-24, -5, 28, 9], [-12, -17, 9, 19], [2, -13, 21, 8], [23, -7, 10, 8]]:
		var x: float = blocco[0]
		var y: float = blocco[1]
		var w: float = blocco[2]
		var h: float = blocco[3]
		draw_colored_polygon(PackedVector2Array([Vector2(x, y), Vector2(x + w, y - 4), Vector2(x + w + 5, y + h - 4), Vector2(x + 5, y + h)]), Color("716b5a"))
		draw_colored_polygon(PackedVector2Array([Vector2(x + 5, y + h), Vector2(x + w + 5, y + h - 4), Vector2(x + w + 5, y + h + 2), Vector2(x + 5, y + h + 6)]), Color("49483e"))
		for k in 3:
			var bx := x + 4 + k * maxf(4.0, (w - 5) / 3.0)
			draw_line(Vector2(bx, y + 2), Vector2(bx + 5, y + 1), Color("a79a7a", 0.7), 1.0)
	# colonna spezzata e massi sparsi
	draw_rect(Rect2(-7, -27, 7, 17), Color("958a70"))
	draw_rect(Rect2(-10, -29, 13, 3), Color("b2a585"))
	draw_rect(Rect2(-8, -11, 9, 3), Color("696454"))
	for k in 7:
		var p := Vector2(rng.randf_range(-32, 32), rng.randf_range(-1, 13))
		var r := rng.randf_range(2.0, 4.5)
		draw_circle(p + Vector2(1, 1.5), r, Color(0.1, 0.1, 0.08, 0.25))
		draw_circle(p, r, Color("8d846f").darkened(rng.randf_range(0.0, 0.25)))
