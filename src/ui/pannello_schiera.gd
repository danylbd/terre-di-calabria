class_name PannelloSchiera
extends PanelContainer
## Il pannello della schiera scelta (step 34): condottiero, livello, forza, morale, razioni e i due pulsanti
## delle abilità (anche con i tasti 1 e 2).

var schiere: Schiere
var _testo: Label
var _pulsanti: Array[Button] = []
var _aggiorna := 0.0


func _ready() -> void:
	theme = TemaGioco.crea(18)
	visible = false
	var colonna := VBoxContainer.new()
	colonna.add_theme_constant_override("separation", 6)
	add_child(colonna)
	_testo = Label.new()
	_testo.add_theme_color_override("font_color", Palette.INCHIOSTRO)
	colonna.add_child(_testo)
	var riga := HBoxContainer.new()
	riga.add_theme_constant_override("separation", 8)
	colonna.add_child(riga)
	for k in 2:
		var b := Button.new()
		b.custom_minimum_size = Vector2(230, 40)
		b.pressed.connect(func(): schiere.usa_abilita(k))
		riga.add_child(b)
		_pulsanti.append(b)


func _process(delta: float) -> void:
	visible = schiere != null and schiere.scelta and schiere.esiste()
	if not visible:
		return
	_aggiorna -= delta
	if _aggiorna > 0.0:
		return
	_aggiorna = 0.25
	var sc: Dictionary = schiere.schiera
	_testo.text = "%s · livello %d · %s · %d soldati · morale %d · razioni %d" % [Schiere.nome_condottiero(), schiere.livello(),
		Schiere.tipo(), schiere.soldati(), sc["morale"], sc["razioni"]]
	var mac: Array = schiere.macchine().keys().map(func(t): return Schiere.MACCHINE[t]["nome"].to_lower())
	if not mac.is_empty():
		_testo.text += " · " + " e ".join(mac)
	var ab := Schiere.abilita()
	for k in 2:
		var b := _pulsanti[k]
		b.visible = k < ab.size()
		if not b.visible:
			continue
		var perche := schiere.motivo_no_abilita(k)
		b.disabled = perche != ""
		b.text = "%d · %s%s" % [k + 1, ab[k]["nome"], "" if perche == "" else " (%s)" % perche.to_lower()]
		b.tooltip_text = ab[k]["descrizione"]
