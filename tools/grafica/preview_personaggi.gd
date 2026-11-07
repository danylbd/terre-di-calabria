extends SceneTree

const POPOLI := ["greci", "brettii", "romani", "saraceni", "normanni", "siculi", "sicani", "cartaginesi"]
const SOLDATI := ["guardia", "brettio", "legionario", "cavaliere_leggero", "cavaliere_pesante", "guerriero_siculo", "arciere_sicano", "mercenario_cartaginese"]


func _initialize() -> void:
	call_deferred("_crea")


func _crea() -> void:
	var civili := Image.create(528, 1408, false, Image.FORMAT_RGBA8)
	civili.fill(Color("#e7dec9"))
	for y in POPOLI.size():
		var popolo: String = POPOLI[y]
		var nomi := ["portatore_nessuno", "portatore_pietra", "lavoratore_ascia_lavoro"]
		for x in nomi.size():
			var tex := load("res://assets/grafica/coloni/%s_%s.svg" % [nomi[x], popolo]) as Texture2D
			var frame := tex.get_image().get_region(Rect2i(0, 0, 80, 80))
			frame.resize(144, 144, Image.INTERPOLATE_LANCZOS)
			civili.blend_rect(frame, Rect2i(Vector2i.ZERO, frame.get_size()), Vector2i(16 + x * 176, 16 + y * 176))
	civili.save_png("res://docs/immagini/preview-coloni-popoli.png")
	var soldati := Image.create(416, SOLDATI.size() * 208, false, Image.FORMAT_RGBA8)
	soldati.fill(Color("#e7dec9"))
	for y in SOLDATI.size():
		var nome: String = SOLDATI[y]
		for x in 2:
			var suffisso := "_lotta" if x == 1 else ""
			var tex := load("res://assets/grafica/coloni/%s%s.svg" % [nome, suffisso]) as Texture2D
			var frame_x := 0 if x == 0 else 3 * 96
			var frame := tex.get_image().get_region(Rect2i(frame_x, 0, 96, 96))
			frame.resize(192, 192, Image.INTERPOLATE_LANCZOS)
			soldati.blend_rect(frame, Rect2i(Vector2i.ZERO, frame.get_size()), Vector2i(8 + x * 208, 8 + y * 208))
	soldati.save_png("res://docs/immagini/preview-soldati-popoli.png")
	quit()
