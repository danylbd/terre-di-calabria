class_name BarraRisorse
extends PanelContainer
## Riepilogo compatto in alto; l'elenco completo delle merci si apre a richiesta.

const COLORI := {"tronchi": Color("8a5a32"), "assi": Color("d8b07a"), "pietra": Color("b9ab90"),
	"grano": Color("e0b84a"), "farina": Color("f2ead8"), "acqua": Color("4f8fc0"), "pane": Color("c07a3a"),
	"pesce": Color("8fb3c4"), "maiale": Color("e0a0a0"), "carne": Color("a83a2e"), "latte": Color("f4f4ee"),
	"lana": Color("e8e2cf"), "formaggio": Color("f0d27a"), "miele": Color("d89a28"), "olive": Color("5c6a2a"),
	"olio": Color("b8a830"), "uva": Color("5a2a5c"), "vino": Color("7a1a2a"), "ortaggi": Color("4f8a2a"),
	"cipolle": Color("a8304a"), "agrumi": Color("f0a020"), "pesce_spada": Color("5a7a9a"), "ferro": Color("8a4a3a"),
	"carbone": Color("2a2624"), "lingotti": Color("7a8088"), "attrezzi": Color("a0a8b0"), "argilla": Color("b0603a"),
	"anfore": Color("c8703a"), "sale": Color("f0f0f0"), "argento": Color("c8ccd4"), "ducati": Color("e8c040"),
	"stoffa": Color("8a3a8a"), "armi": Color("b0802a"), "pece": Color("1e1a16"), "tegole": Color("b8482e"),
	"bozzoli": Color("f4f0e0"), "seta": Color("2a9a6a"), "cavalli": Color("7a5030"), "porpora": Color("7a1f4a"),
	"elefanti": Color("8a8a90"), "ceramiche": Color("c06a3a"), "lame": Color("201c2a")}

var _etichette := {}
var _scatole := {}
var _coloni: Label
var _stagione: Label
var _rapide: Label
var _capienza: Label
var _elenco: ScrollContainer
var _pulsante_elenco: Button
var _dettaglio := false


func _ready() -> void:
	theme = TemaGioco.crea(19)
	var colonna := VBoxContainer.new()
	colonna.add_theme_constant_override("separation", 5)
	add_child(colonna)
	var intestazione := HBoxContainer.new()
	intestazione.add_theme_constant_override("separation", 12)
	colonna.add_child(intestazione)
	_rapide = Label.new()
	_rapide.add_theme_color_override("font_color", Palette.TERRACOTTA_SCURA)
	_rapide.add_theme_font_size_override("font_size", 17)
	intestazione.add_child(_rapide)
	_capienza = Label.new()
	_capienza.add_theme_font_size_override("font_size", 16)
	intestazione.add_child(_capienza)
	_coloni = Label.new()
	_coloni.add_theme_font_size_override("font_size", 18)
	_coloni.add_theme_color_override("font_color", Palette.TERRACOTTA_SCURA)
	_coloni.tooltip_text = "Coloni nel villaggio / posti nelle abitazioni"
	intestazione.add_child(_coloni)
	_stagione = Label.new()
	_stagione.add_theme_font_size_override("font_size", 18)
	_stagione.add_theme_color_override("font_color", Palette.INCHIOSTRO)
	intestazione.add_child(_stagione)
	_pulsante_elenco = Button.new()
	_pulsante_elenco.text = "Scorte ▾"
	_pulsante_elenco.tooltip_text = "Apri l'elenco completo delle merci"
	_pulsante_elenco.pressed.connect(_alterna_elenco)
	intestazione.add_child(_pulsante_elenco)
	_elenco = ScrollContainer.new()
	_elenco.custom_minimum_size = Vector2(0, 250)
	_elenco.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_elenco.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	colonna.add_child(_elenco)
	var griglia := GridContainer.new()
	griglia.columns = 6
	griglia.add_theme_constant_override("h_separation", 12)
	griglia.add_theme_constant_override("v_separation", 6)
	_elenco.add_child(griglia)
	var voci: Array = CatalogoEdifici.NOMI_RISORSE.keys().filter(func(r): return r not in CatalogoEdifici.ATTREZZI)
	voci.append("attrezzi")
	for r in voci:
		var box := HBoxContainer.new()
		box.add_theme_constant_override("separation", 6)
		var chip := ColorRect.new()
		chip.color = COLORI.get(r, Color("a0a8b0"))
		chip.custom_minimum_size = Vector2(14, 14)
		chip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		box.add_child(chip)
		var nome := Label.new()
		nome.text = "Attrezzi" if r == "attrezzi" else CatalogoEdifici.NOMI_RISORSE[r]
		nome.add_theme_color_override("font_color", Palette.TERRACOTTA_SCURA)
		nome.add_theme_font_size_override("font_size", 15)
		box.add_child(nome)
		var n := Label.new()
		n.add_theme_font_size_override("font_size", 17)
		box.add_child(n)
		_etichette[r] = n
		_scatole[r] = box
		griglia.add_child(box)
	_elenco.visible = false


func _alterna_elenco() -> void:
	_dettaglio = not _dettaglio
	_elenco.visible = _dettaglio
	_pulsante_elenco.text = "Scorte ▴" if _dettaglio else "Scorte ▾"
	_pulsante_elenco.tooltip_text = "Chiudi l'elenco merci" if _dettaglio else "Apri l'elenco completo delle merci"
	_ricentra.call_deferred()


func aggiorna(scorte: Dictionary) -> void:
	var attrezzi := 0
	var dettaglio := []
	for a in CatalogoEdifici.ATTREZZI:
		attrezzi += scorte.get(a, 0)
		dettaglio.append("%s: %d" % [CatalogoEdifici.NOMI_RISORSE[a], scorte.get(a, 0)])
	(_scatole["attrezzi"] as Control).tooltip_text = "\n".join(dettaglio)
	for r in _etichette:
		var n: int = attrezzi if r == "attrezzi" else scorte.get(r, 0)
		(_etichette[r] as Label).text = str(n)
		(_scatole[r] as Control).visible = _dettaglio or r in CatalogoEdifici.RISORSE_BASE or n > 0
	_rapide.text = "Legna %d  ·  Assi %d  ·  Pietra %d  ·  Ducati %d" % [scorte.get("tronchi", 0), scorte.get("assi", 0), scorte.get("pietra", 0), scorte.get("ducati", 0)]
	_ricentra.call_deferred()


func aggiorna_capienza(occupati: int, limite: int) -> void:
	_capienza.text = "Magazzini %d / %d" % [occupati, limite]
	_capienza.add_theme_color_override("font_color", Color("a8321e") if limite > 0 and occupati >= limite else Palette.TERRACOTTA_SCURA)


func aggiorna_stagione(testo: String) -> void:
	_stagione.text = testo
	_ricentra.call_deferred()


func aggiorna_coloni(popolazione: int, capacita: int) -> void:
	_coloni.text = "Coloni %d / %d" % [popolazione, capacita]
	_ricentra.call_deferred()


func _ricentra() -> void:
	reset_size()
	set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP, Control.PRESET_MODE_MINSIZE, 12)
