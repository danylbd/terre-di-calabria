class_name BarraRisorse
extends PanelContainer
## Barra in alto con le scorte del magazzino: legno e pietra sempre, le altre merci quando ce ne sono.

const COLORI := {"tronchi": Color("8a5a32"), "assi": Color("d8b07a"), "pietra": Color("b9ab90"),
	"grano": Color("e0b84a"), "farina": Color("f2ead8"), "acqua": Color("4f8fc0"), "pane": Color("c07a3a"),
	"pesce": Color("8fb3c4"), "maiale": Color("e0a0a0"), "carne": Color("a83a2e"), "latte": Color("f4f4ee"),
	"lana": Color("e8e2cf"), "formaggio": Color("f0d27a"), "miele": Color("d89a28")}

var _etichette := {}
var _scatole := {}


func _ready() -> void:
	theme = TemaGioco.crea(20)
	var riga := HBoxContainer.new()
	riga.add_theme_constant_override("separation", 18)
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
		_scatole[r] = box
		riga.add_child(box)


func aggiorna(scorte: Dictionary) -> void:
	var cambiata := false
	for r in _etichette:
		(_etichette[r] as Label).text = str(scorte.get(r, 0))
		var visibile: bool = r in CatalogoEdifici.RISORSE_BASE or scorte.get(r, 0) > 0
		if (_scatole[r] as Control).visible != visibile:
			(_scatole[r] as Control).visible = visibile
			cambiata = true
	if cambiata:
		_ricentra.call_deferred()


## Le merci mostrate sono cambiate: la barra si stringe o si allarga restando al centro in alto.
func _ricentra() -> void:
	reset_size()
	set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP, Control.PRESET_MODE_MINSIZE, 12)
