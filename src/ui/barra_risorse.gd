class_name BarraRisorse
extends PanelContainer
## Barra in alto con le scorte del magazzino: legno e pietra sempre, le altre merci quando ce ne sono.

const COLORI := {"tronchi": Color("8a5a32"), "assi": Color("d8b07a"), "pietra": Color("b9ab90"),
	"grano": Color("e0b84a"), "farina": Color("f2ead8"), "acqua": Color("4f8fc0"), "pane": Color("c07a3a"),
	"pesce": Color("8fb3c4"), "maiale": Color("e0a0a0"), "carne": Color("a83a2e"), "latte": Color("f4f4ee"),
	"lana": Color("e8e2cf"), "formaggio": Color("f0d27a"), "miele": Color("d89a28"), "olive": Color("5c6a2a"),
	"olio": Color("b8a830"), "uva": Color("5a2a5c"), "vino": Color("7a1a2a"), "ortaggi": Color("4f8a2a"),
	"cipolle": Color("a8304a"), "agrumi": Color("f0a020"), "pesce_spada": Color("5a7a9a"), "ferro": Color("8a4a3a"),
	"carbone": Color("2a2624"), "lingotti": Color("7a8088"), "attrezzi": Color("a0a8b0"), "argilla": Color("b0603a"),
	"anfore": Color("c8703a"), "sale": Color("f0f0f0"), "argento": Color("c8ccd4"), "ducati": Color("e8c040"),
	"stoffa": Color("8a3a8a"), "armi": Color("b0802a"), "pece": Color("1e1a16"), "tegole": Color("b8482e"), "bozzoli": Color("f4f0e0"), "seta": Color("2a9a6a"), "cavalli": Color("7a5030"), "ceramiche": Color("c06a3a"), "lame": Color("201c2a")}

var _etichette := {}
var _scatole := {}
var _coloni: Label
var _stagione: Label


func _ready() -> void:
	theme = TemaGioco.crea(20)
	var riga := HBoxContainer.new()
	riga.add_theme_constant_override("separation", 18)
	add_child(riga)
	var voci: Array = CatalogoEdifici.NOMI_RISORSE.keys().filter(func(r): return r not in CatalogoEdifici.ATTREZZI)
	voci.append("attrezzi")
	for r in voci:
		var box := HBoxContainer.new()
		box.add_theme_constant_override("separation", 8)
		var chip := ColorRect.new()
		chip.color = COLORI[r]
		chip.custom_minimum_size = Vector2(18, 18)
		chip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		box.add_child(chip)
		var nome := Label.new()
		nome.text = "Attrezzi" if r == "attrezzi" else CatalogoEdifici.NOMI_RISORSE[r]
		nome.add_theme_color_override("font_color", Palette.TERRACOTTA_SCURA)
		nome.add_theme_font_size_override("font_size", 16)
		box.add_child(nome)
		var n := Label.new()
		n.add_theme_font_size_override("font_size", 22)
		box.add_child(n)
		_etichette[r] = n
		_scatole[r] = box
		riga.add_child(box)
	_coloni = Label.new()
	_coloni.add_theme_font_size_override("font_size", 20)
	_coloni.add_theme_color_override("font_color", Palette.TERRACOTTA_SCURA)
	_coloni.tooltip_text = "Coloni nel villaggio / posti nelle abitazioni"
	_coloni.mouse_filter = Control.MOUSE_FILTER_STOP
	riga.add_child(VSeparator.new())
	riga.add_child(_coloni)
	_stagione = Label.new()
	_stagione.add_theme_font_size_override("font_size", 20)
	_stagione.add_theme_color_override("font_color", Palette.INCHIOSTRO)
	riga.add_child(VSeparator.new())
	riga.add_child(_stagione)


func aggiorna(scorte: Dictionary) -> void:
	var cambiata := false
	# gli attrezzi stanno in una voce sola; il dettaglio è nel suggerimento
	var attrezzi := 0
	var dettaglio := []
	for a in CatalogoEdifici.ATTREZZI:
		attrezzi += scorte.get(a, 0)
		dettaglio.append("%s: %d" % [CatalogoEdifici.NOMI_RISORSE[a], scorte.get(a, 0)])
	(_scatole["attrezzi"] as Control).tooltip_text = "\n".join(dettaglio)
	for r in _etichette:
		var n: int = attrezzi if r == "attrezzi" else scorte.get(r, 0)
		(_etichette[r] as Label).text = str(n)
		var visibile: bool = r in CatalogoEdifici.RISORSE_BASE or n > 0
		if (_scatole[r] as Control).visible != visibile:
			(_scatole[r] as Control).visible = visibile
			cambiata = true
	if cambiata:
		_ricentra.call_deferred()


func aggiorna_stagione(testo: String) -> void:
	_stagione.text = testo
	_ricentra.call_deferred()


func aggiorna_coloni(popolazione: int, capacita: int) -> void:
	_coloni.text = "Coloni %d / %d" % [popolazione, capacita]
	_ricentra.call_deferred()


## Le merci mostrate sono cambiate: la barra si stringe o si allarga restando al centro in alto.
func _ricentra() -> void:
	reset_size()
	set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP, Control.PRESET_MODE_MINSIZE, 12)
