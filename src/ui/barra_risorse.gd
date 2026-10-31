class_name BarraRisorse
extends PanelContainer
## Barra in alto con le scorte del magazzino.

const COLORI := {"tronchi": Color("8a5a32"), "assi": Color("d8b07a"), "pietra": Color("b9ab90")}

var _etichette := {}


func _ready() -> void:
	theme = TemaGioco.crea(20)
	var riga := HBoxContainer.new()
	riga.add_theme_constant_override("separation", 22)
	add_child(riga)
	for r in CatalogoEdifici.NOMI_RISORSE:
		var box := HBoxContainer.new()
		box.add_theme_constant_override("separation", 8)
		var chip := ColorRect.new()
		chip.color = COLORI[r]
		chip.custom_minimum_size = Vector2(18, 18)
		chip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		box.add_child(chip)
		var nome := Label.new()
		nome.text = CatalogoEdifici.NOMI_RISORSE[r]
		nome.add_theme_color_override("font_color", Palette.TERRACOTTA_SCURA)
		nome.add_theme_font_size_override("font_size", 16)
		box.add_child(nome)
		var n := Label.new()
		n.add_theme_font_size_override("font_size", 22)
		box.add_child(n)
		_etichette[r] = n
		riga.add_child(box)


func aggiorna(scorte: Dictionary) -> void:
	for r in _etichette:
		(_etichette[r] as Label).text = str(scorte.get(r, 0))
