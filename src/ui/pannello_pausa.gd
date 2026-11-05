class_name PannelloPausa
extends ColorRect
## Menu di pausa: la schermata resta attiva mentre il resto della partita è in pausa.

signal azione(nome: String)
var _titolo: Label


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	color = Color(0.05, 0.07, 0.08, 0.72)
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var centro := CenterContainer.new()
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(centro)
	var riquadro := PanelContainer.new()
	riquadro.theme = TemaGioco.crea(18)
	riquadro.custom_minimum_size = Vector2(430, 0)
	riquadro.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	riquadro.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	centro.add_child(riquadro)
	var colonna := VBoxContainer.new()
	colonna.add_theme_constant_override("separation", 12)
	riquadro.add_child(colonna)
	_titolo = Label.new()
	_titolo.text = "Partita in pausa"
	_titolo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_titolo.add_theme_font_size_override("font_size", 26)
	_titolo.add_theme_color_override("font_color", Palette.TERRACOTTA_SCURA)
	colonna.add_child(_titolo)
	_pulsante(colonna, "Continua", "continua")
	_pulsante(colonna, "Salva partita", "salva")
	_pulsante(colonna, "Esci al menu", "esci")
	_riga_volume(colonna, "Musica", "Musica")
	_riga_volume(colonna, "Effetti sonori", "Effetti")
	_riga_volume(colonna, "Suoni ambientali", "Ambiente")
	visible = false


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		azione.emit("continua")
		get_viewport().set_input_as_handled()


func _pulsante(padre: VBoxContainer, testo: String, nome: String) -> void:
	var b := Button.new()
	b.text = testo
	b.custom_minimum_size = Vector2(360, 42)
	b.pressed.connect(func(): azione.emit(nome))
	padre.add_child(b)


func mostra_esito_salvataggio(riuscito: bool) -> void:
	_titolo.text = "Partita salvata" if riuscito else "Salvataggio non riuscito"


func _riga_volume(padre: VBoxContainer, testo: String, bus: String) -> void:
	var riga := HBoxContainer.new()
	var etichetta := Label.new()
	etichetta.text = testo
	etichetta.custom_minimum_size = Vector2(150, 32)
	riga.add_child(etichetta)
	var cursore := HSlider.new()
	cursore.min_value = 0.0
	cursore.max_value = 1.0
	cursore.step = 0.01
	cursore.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var audio := get_node_or_null("/root/Audio")
	if audio:
		cursore.value = audio.volume(bus)
	cursore.value_changed.connect(func(valore: float):
		var sistema := get_node_or_null("/root/Audio")
		if sistema:
			sistema.imposta_volume(bus, valore))
	riga.add_child(cursore)
	padre.add_child(riga)
