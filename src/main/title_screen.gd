extends Control
## Schermata iniziale: paesaggio, titolo, menu, leggenda e crediti.

const Sfondo := preload("res://src/main/backdrop.gd")

const LEGGENDA := """«Prima dei Greci, prima delle navi,
c'era un re che camminava tra due mari.
Si chiamava Italo, e diede il suo nome alla terra.

Quando morì, nessuno dei suoi figli era degno di regnare.
Allora spezzò il suo Sigillo in cinque parti
e le affidò alla terra stessa:
al monte, al bosco, al ferro, alla roccia e al mare.

Chi le riunirà sulla Soglia,
dove i due mari quasi si toccano,
custodirà la terra tra due mari.»"""

var _menu: VBoxContainer
var _strato_leggenda: CenterContainer
var _strato_crediti: CenterContainer
var _avviso: Label
var _tween_avviso: Tween


func _ready() -> void:
	theme = _crea_tema()
	add_child(Sfondo.new())
	_crea_titolo_e_menu()
	_strato_leggenda = _crea_strato(_crea_pannello_leggenda())
	_strato_crediti = _crea_strato(_crea_pannello_crediti())
	_crea_versione()
	_crea_avviso()
	_menu.get_child(0).grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and (_strato_leggenda.visible or _strato_crediti.visible):
		_torna_al_menu()
		get_viewport().set_input_as_handled()


# --- Costruzione dell'interfaccia -------------------------------------------

func _crea_titolo_e_menu() -> void:
	var centro := CenterContainer.new()
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(centro)

	var colonna := VBoxContainer.new()
	colonna.alignment = BoxContainer.ALIGNMENT_CENTER
	colonna.add_theme_constant_override("separation", 6)
	centro.add_child(colonna)

	var titolo := Label.new()
	titolo.text = "Terre di Calabria"
	titolo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titolo.add_theme_font_size_override("font_size", 112)
	titolo.add_theme_color_override("font_color", Palette.PERGAMENA_CHIARA)
	titolo.add_theme_color_override("font_outline_color", Palette.TERRACOTTA_SCURA)
	titolo.add_theme_constant_override("outline_size", 18)
	titolo.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.35))
	titolo.add_theme_constant_override("shadow_offset_y", 6)
	colonna.add_child(titolo)

	var sottotitolo := Label.new()
	sottotitolo.text = "Il Sigillo di Italo"
	sottotitolo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sottotitolo.add_theme_font_size_override("font_size", 40)
	sottotitolo.add_theme_color_override("font_color", Palette.PERGAMENA_CHIARA)
	sottotitolo.add_theme_color_override("font_shadow_color", Color(Palette.TERRACOTTA_SCURA, 0.9))
	sottotitolo.add_theme_constant_override("shadow_offset_x", 0)
	sottotitolo.add_theme_constant_override("shadow_offset_y", 3)
	sottotitolo.add_theme_constant_override("shadow_outline_size", 8)
	colonna.add_child(sottotitolo)

	var spazio := Control.new()
	spazio.custom_minimum_size = Vector2(0, 56)
	colonna.add_child(spazio)

	_menu = VBoxContainer.new()
	_menu.add_theme_constant_override("separation", 14)
	colonna.add_child(_menu)
	_aggiungi_voce("Nuova partita", _on_nuova_partita)
	_aggiungi_voce("La leggenda", func(): _mostra(_strato_leggenda))
	_aggiungi_voce("Crediti", func(): _mostra(_strato_crediti))
	_aggiungi_voce("Esci", func(): get_tree().quit())


func _aggiungi_voce(testo: String, azione: Callable) -> void:
	var b := Button.new()
	b.text = testo
	b.custom_minimum_size = Vector2(460, 0)
	b.pressed.connect(azione)
	_menu.add_child(b)


func _crea_strato(pannello: Control) -> CenterContainer:
	var strato := CenterContainer.new()
	strato.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	strato.visible = false
	var velo := ColorRect.new()
	velo.color = Color(Palette.INCHIOSTRO, 0.45)
	velo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	velo.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(velo)
	velo.visible = false
	strato.set_meta("velo", velo)
	strato.add_child(pannello)
	add_child(strato)
	return strato


func _crea_pannello_leggenda() -> PanelContainer:
	var pannello := PanelContainer.new()
	pannello.custom_minimum_size = Vector2(980, 0)
	var colonna := VBoxContainer.new()
	colonna.add_theme_constant_override("separation", 22)
	pannello.add_child(colonna)

	var titolo := _etichetta("Il Sigillo di Italo", 52, Palette.TERRACOTTA_SCURA)
	colonna.add_child(titolo)

	var testo := _etichetta(LEGGENDA, 30, Palette.INCHIOSTRO)
	testo.add_theme_constant_override("line_spacing", 6)
	colonna.add_child(testo)

	var firma := _etichetta("— canto di Rocco della Lira", 26, Palette.TERRACOTTA)
	firma.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	colonna.add_child(firma)

	colonna.add_child(_bottone_indietro())
	return pannello


func _crea_pannello_crediti() -> PanelContainer:
	var pannello := PanelContainer.new()
	pannello.custom_minimum_size = Vector2(980, 760)
	var colonna := VBoxContainer.new()
	colonna.add_theme_constant_override("separation", 18)
	pannello.add_child(colonna)

	colonna.add_child(_etichetta("Crediti", 52, Palette.TERRACOTTA_SCURA))
	colonna.add_child(_etichetta("Ideato da danylbd\nSviluppato insieme a Claude", 30, Palette.INCHIOSTRO))

	var nota := _etichetta("Realizzato con il motore Godot Engine (licenza MIT):", 24, Palette.TERRACOTTA)
	colonna.add_child(nota)

	var scorrimento := ScrollContainer.new()
	scorrimento.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scorrimento.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var licenza := Label.new()
	licenza.text = Engine.get_license_text()
	licenza.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	licenza.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	licenza.add_theme_font_size_override("font_size", 18)
	licenza.add_theme_color_override("font_color", Color(Palette.INCHIOSTRO, 0.8))
	scorrimento.add_child(licenza)
	colonna.add_child(scorrimento)

	colonna.add_child(_bottone_indietro())
	return pannello


func _crea_versione() -> void:
	var etichetta := Label.new()
	etichetta.text = "v%s · step 00" % ProjectSettings.get_setting("application/config/version", "0.0.0")
	etichetta.add_theme_font_size_override("font_size", 20)
	etichetta.add_theme_color_override("font_color", Color(Palette.PERGAMENA_CHIARA, 0.8))
	etichetta.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT, Control.PRESET_MODE_MINSIZE, 20)
	etichetta.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	etichetta.grow_vertical = Control.GROW_DIRECTION_BEGIN
	add_child(etichetta)


func _crea_avviso() -> void:
	_avviso = Label.new()
	_avviso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_avviso.add_theme_font_size_override("font_size", 30)
	_avviso.add_theme_color_override("font_color", Palette.PERGAMENA_CHIARA)
	_avviso.add_theme_color_override("font_outline_color", Palette.INCHIOSTRO)
	_avviso.add_theme_constant_override("outline_size", 10)
	_avviso.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM, Control.PRESET_MODE_MINSIZE, 70)
	_avviso.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_avviso.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_avviso.modulate.a = 0.0
	add_child(_avviso)


func _etichetta(testo: String, dimensione: int, colore: Color) -> Label:
	var l := Label.new()
	l.text = testo
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_font_size_override("font_size", dimensione)
	l.add_theme_color_override("font_color", colore)
	return l


func _bottone_indietro() -> Button:
	var b := Button.new()
	b.text = "Indietro"
	b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	b.custom_minimum_size = Vector2(300, 0)
	b.pressed.connect(_torna_al_menu)
	return b


# --- Azioni -------------------------------------------------------------------

func _on_nuova_partita() -> void:
	_mostra_avviso("La mappa della Calabria arriva con lo step 01.")


func _mostra(strato: CenterContainer) -> void:
	var velo: ColorRect = strato.get_meta("velo")
	velo.visible = true
	strato.visible = true
	strato.modulate.a = 0.0
	velo.modulate.a = 0.0
	var t := create_tween().set_parallel()
	t.tween_property(strato, "modulate:a", 1.0, 0.35)
	t.tween_property(velo, "modulate:a", 1.0, 0.35)
	var bottone := _trova_bottone(strato)
	if bottone:
		bottone.grab_focus()


func _torna_al_menu() -> void:
	for strato in [_strato_leggenda, _strato_crediti]:
		strato.visible = false
		(strato.get_meta("velo") as ColorRect).visible = false
	_menu.get_child(0).grab_focus()


func _mostra_avviso(testo: String) -> void:
	_avviso.text = testo
	if _tween_avviso:
		_tween_avviso.kill()
	_avviso.modulate.a = 1.0
	_tween_avviso = create_tween()
	_tween_avviso.tween_interval(2.2)
	_tween_avviso.tween_property(_avviso, "modulate:a", 0.0, 0.8)


func _trova_bottone(nodo: Node) -> Button:
	for figlio in nodo.get_children():
		if figlio is Button:
			return figlio
		var trovato := _trova_bottone(figlio)
		if trovato:
			return trovato
	return null


# --- Tema grafico ---------------------------------------------------------------

func _crea_tema() -> Theme:
	var t := Theme.new()
	t.default_font_size = 32

	var normale := StyleBoxFlat.new()
	normale.bg_color = Palette.PERGAMENA
	normale.border_color = Palette.TERRACOTTA_SCURA
	normale.set_border_width_all(3)
	normale.set_corner_radius_all(8)
	normale.content_margin_left = 36
	normale.content_margin_right = 36
	normale.content_margin_top = 14
	normale.content_margin_bottom = 14
	normale.shadow_color = Color(0, 0, 0, 0.25)
	normale.shadow_size = 6
	normale.shadow_offset = Vector2(0, 4)

	var sopra := normale.duplicate() as StyleBoxFlat
	sopra.bg_color = Palette.PERGAMENA_CHIARA
	sopra.border_color = Palette.TERRACOTTA

	var premuto := normale.duplicate() as StyleBoxFlat
	premuto.bg_color = Palette.OCRA
	premuto.shadow_size = 2

	var fuoco := sopra.duplicate() as StyleBoxFlat
	fuoco.draw_center = false
	fuoco.border_color = Palette.OCRA
	fuoco.set_border_width_all(5)
	fuoco.shadow_size = 0

	t.set_stylebox("normal", "Button", normale)
	t.set_stylebox("hover", "Button", sopra)
	t.set_stylebox("pressed", "Button", premuto)
	t.set_stylebox("focus", "Button", fuoco)
	t.set_stylebox("disabled", "Button", normale)
	t.set_color("font_color", "Button", Palette.INCHIOSTRO)
	t.set_color("font_hover_color", "Button", Palette.TERRACOTTA_SCURA)
	t.set_color("font_pressed_color", "Button", Palette.INCHIOSTRO)
	t.set_color("font_focus_color", "Button", Palette.INCHIOSTRO)
	t.set_color("font_hover_pressed_color", "Button", Palette.INCHIOSTRO)
	t.set_color("font_disabled_color", "Button", Color(Palette.INCHIOSTRO, 0.45))

	var pannello := StyleBoxFlat.new()
	pannello.bg_color = Palette.PERGAMENA
	pannello.border_color = Palette.TERRACOTTA
	pannello.set_border_width_all(4)
	pannello.set_corner_radius_all(12)
	pannello.content_margin_left = 56
	pannello.content_margin_right = 56
	pannello.content_margin_top = 44
	pannello.content_margin_bottom = 44
	pannello.shadow_color = Color(0, 0, 0, 0.35)
	pannello.shadow_size = 16
	t.set_stylebox("panel", "PanelContainer", pannello)

	t.set_color("font_color", "Label", Palette.INCHIOSTRO)
	return t
