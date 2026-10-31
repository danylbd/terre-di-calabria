class_name MenuCostruzione
extends PanelContainer
## Pannello in basso a sinistra: schede per categoria, pulsanti degli edifici con anteprima,
## pulsante per demolire.

signal edificio_scelto(tipo: String)
signal strumento(nome: String, attivo: bool)   # "strada", "bandierina", "demolisci"

var _griglia: GridContainer
var _schede: Array[Button] = []
var _pulsanti := {}          # tipo -> Button
var _attrezzi := {}
var _nota: Label
var _categoria := "Base"
var _gruppo := ButtonGroup.new()


func _ready() -> void:
	theme = TemaGioco.crea(16)
	var colonna := VBoxContainer.new()
	colonna.add_theme_constant_override("separation", 8)
	add_child(colonna)

	var titolo := Label.new()
	titolo.text = "Costruisci"
	titolo.add_theme_font_size_override("font_size", 22)
	titolo.add_theme_color_override("font_color", Palette.TERRACOTTA_SCURA)
	colonna.add_child(titolo)

	var riga := HBoxContainer.new()
	riga.add_theme_constant_override("separation", 4)
	colonna.add_child(riga)
	var gruppo_schede := ButtonGroup.new()
	for cat in CatalogoEdifici.CATEGORIE:
		var b := Button.new()
		b.text = cat
		b.toggle_mode = true
		b.button_group = gruppo_schede
		b.custom_minimum_size = Vector2(92, 34)
		b.button_pressed = cat == _categoria
		b.pressed.connect(func(): Suono.suona("clic"); _mostra_categoria(cat))
		riga.add_child(b)
		_schede.append(b)

	_griglia = GridContainer.new()
	_griglia.columns = 4
	_griglia.add_theme_constant_override("h_separation", 6)
	_griglia.add_theme_constant_override("v_separation", 6)
	colonna.add_child(_griglia)

	_nota = Label.new()
	_nota.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_nota.custom_minimum_size = Vector2(390, 0)
	_nota.add_theme_color_override("font_color", Color(Palette.INCHIOSTRO, 0.7))
	colonna.add_child(_nota)

	var attrezzi := HBoxContainer.new()
	attrezzi.add_theme_constant_override("separation", 6)
	colonna.add_child(attrezzi)
	for a in [["strada", "Strada", "Clicca una bandierina, poi il punto d'arrivo: la strada trova da sola il percorso. (Tasto R)"],
			["bandierina", "Bandierina", "Pianta una bandierina su una strada per dividerla: ogni tratto ha il suo portatore. (Tasto F)"],
			["demolisci", "Demolisci", "Clicca un edificio, una strada o una bandierina per toglierli."]]:
		var b := Button.new()
		b.text = a[1]
		b.toggle_mode = true
		b.button_group = _gruppo
		b.custom_minimum_size = Vector2(128, 36)
		b.tooltip_text = a[2]
		var nome: String = a[0]
		b.toggled.connect(func(on: bool): strumento.emit(nome, on))
		attrezzi.add_child(b)
		_attrezzi[nome] = b

	_mostra_categoria(_categoria)


func _mostra_categoria(cat: String) -> void:
	_categoria = cat
	for c in _griglia.get_children():
		c.queue_free()
	_pulsanti.clear()
	var tipi := CatalogoEdifici.della_categoria(cat)
	_nota.text = "" if tipi.size() > 0 else "Miniere, fonderia e fabbro arriveranno con lo step 07."
	_nota.visible = tipi.is_empty()
	for tipo in tipi:
		var d := CatalogoEdifici.dati(tipo)
		var b := Button.new()
		b.toggle_mode = true
		b.button_group = _gruppo
		b.custom_minimum_size = Vector2(96, 104)
		b.text = d["nome"]
		b.icon = Sprites.icona(tipo)
		b.expand_icon = true
		b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		b.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		b.add_theme_font_size_override("font_size", 12 if d["nome"].length() > 11 else 13)
		b.add_theme_constant_override("icon_max_width", 84)
		b.tooltip_text = "%s\n%s\nCosto: %s" % [d["nome"], d["descrizione"], CatalogoEdifici.testo_costo(tipo)]
		b.toggled.connect(func(on: bool):
			if on:
				edificio_scelto.emit(tipo)
		)
		_griglia.add_child(b)
		_pulsanti[tipo] = b


## Toglie la selezione (dopo aver piazzato, o con Esc / tasto destro).
func deseleziona() -> void:
	var premuto := _gruppo.get_pressed_button()
	if premuto:
		premuto.set_pressed_no_signal(false)


func premi_attrezzo(nome: String) -> void:
	if _attrezzi.has(nome):
		_attrezzi[nome].button_pressed = true
