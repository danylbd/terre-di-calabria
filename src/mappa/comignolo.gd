extends Node2D
## Piccolo comignolo animato per le abitazioni.

var _tempo := 0.0


func _process(delta: float) -> void:
	_tempo = fmod(_tempo + delta, 2.2)
	queue_redraw()


func _draw() -> void:
	# Il comignolo resta sul colmo della falda e ha mattoni leggibili anche allo zoom minimo.
	draw_rect(Rect2(12, -69, 9, 18), Color("392c24"))
	draw_rect(Rect2(10, -72, 13, 5), Color("6d4936"))
	draw_rect(Rect2(12, -69, 3, 15), Color("936045"))
	var fase := _tempo / 2.2
	for k in 3:
		var comparsa := fposmod(fase * 2.0 + float(k) / 3.0, 1.0)
		var raggio := 2.8 + comparsa * 5.0
		var centro := Vector2(16, -75) + Vector2(-5.0 * comparsa, -15.0 * comparsa)
		var fumo := Color("b9b7b0")
		fumo.a = (1.0 - comparsa) * 0.34
		draw_circle(centro, raggio, fumo)
		draw_circle(centro + Vector2(-2, -2), raggio * 0.45, Color(0.88, 0.87, 0.84, fumo.a * 0.65))
