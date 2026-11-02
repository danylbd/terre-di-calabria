class_name PannelloMissione
extends Control
## Interfaccia di una missione: in alto a sinistra gli obiettivi (fatti, attuale con il suggerimento,
## ancora da fare); al centro i dialoghi del racconto, una battuta alla volta, a gioco fermo.

signal finito_dialogo

const VOCI := {"Rocco della Lira": "voce_italo"}   # chi ha una voce (sillabe in assets/suoni)

var missione: Missione
var _obiettivi: RichTextLabel
var _riquadro: PanelContainer
var _dialogo: PanelContainer
var _chi: Label
var _battuta: Label
var _avanti: Button
var _coda: Array = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	theme = TemaGioco.crea(18)

	_riquadro = PanelContainer.new()
	_riquadro.custom_minimum_size = Vector2(420, 0)
	add_child(_riquadro)
	_riquadro.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT, Control.PRESET_MODE_MINSIZE, 14)
	_obiettivi = RichTextLabel.new()
	_obiettivi.bbcode_enabled = true
	_obiettivi.fit_content = true
	_obiettivi.scroll_active = false
	_obiettivi.custom_minimum_size = Vector2(400, 0)
	_obiettivi.add_theme_color_override("default_color", Palette.INCHIOSTRO)
	_riquadro.add_child(_obiettivi)

	_dialogo = PanelContainer.new()
	_dialogo.custom_minimum_size = Vector2(820, 0)
	add_child(_dialogo)
	_dialogo.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM, Control.PRESET_MODE_MINSIZE, 140)
	_dialogo.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_dialogo.grow_vertical = Control.GROW_DIRECTION_BEGIN
	var colonna := VBoxContainer.new()
	colonna.add_theme_constant_override("separation", 10)
	_dialogo.add_child(colonna)
	_chi = Label.new()
	_chi.add_theme_font_size_override("font_size", 26)
	_chi.add_theme_color_override("font_color", Palette.TERRACOTTA_SCURA)
	colonna.add_child(_chi)
	_battuta = Label.new()
	_battuta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_battuta.custom_minimum_size = Vector2(780, 0)
	_battuta.add_theme_font_size_override("font_size", 22)
	_battuta.add_theme_color_override("font_color", Palette.INCHIOSTRO)
	colonna.add_child(_battuta)
	_avanti = Button.new()
	_avanti.text = "Avanti"
	_avanti.custom_minimum_size = Vector2(180, 40)
	_avanti.size_flags_horizontal = Control.SIZE_SHRINK_END
	_avanti.pressed.connect(avanti)
	colonna.add_child(_avanti)
	_dialogo.visible = false


func prepara(m: Missione) -> void:
	missione = m
	m.dialogo.connect(mostra_dialogo)
	m.obiettivo_cambiato.connect(aggiorna)
	aggiorna()


func aggiorna() -> void:
	var righe := ["[font_size=22][color=#7f3420]%s[/color][/font_size]" % missione.titolo()]
	var ob := missione.obiettivi()
	for k in ob.size():
		if k < missione.indice:
			righe.append("[color=#4f7a2a]✔ %s[/color]" % ob[k]["testo"])
		elif k == missione.indice:
			righe.append("[b]➤ %s[/b]" % ob[k]["testo"])
			righe.append("[i][font_size=15]%s[/font_size][/i]" % ob[k]["aiuto"])
		else:
			righe.append("[color=#8a7a66]• %s[/color]" % ob[k]["testo"])
	if missione.dati.get("sfida", false):
		var rec := Missione.record(missione.id)
		righe.append("[color=#7f3420]Tempo %s[/color]%s" % [Missione.testo_tempo(missione.tempo),
			"   ·   record %s" % Missione.testo_tempo(rec) if rec >= 0.0 else ""])
	if missione.finita():
		righe.append("[b][color=#4f7a2a]Missione compiuta![/color][/b]")
	_obiettivi.text = "\n".join(righe)


func dialogo_aperto() -> bool:
	return _dialogo.visible


## Mostra le battute una alla volta; il gioco resta fermo finché il dialogo non finisce.
func mostra_dialogo(battute: Array) -> void:
	_coda.append_array(battute)
	if not _dialogo.visible:
		get_tree().paused = true
		_dialogo.visible = true
		avanti()


func avanti() -> void:
	if _coda.is_empty():
		Suono.taci()
		_dialogo.visible = false
		get_tree().paused = false
		finito_dialogo.emit()
		return
	var b: Array = _coda.pop_front()
	_chi.text = b[0]
	_battuta.text = b[1]
	# re Italo (Rocco della Lira) ha la sua voce; gli altri per ora parlano solo per iscritto
	if VOCI.has(b[0]):
		Suono.parla(VOCI[b[0]], b[1])
	else:
		Suono.taci()
	_avanti.text = "Avanti" if not _coda.is_empty() else ("Al lavoro!" if not missione.finita() else "Fine")
	_avanti.grab_focus()
