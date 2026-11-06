class_name MenuCostruzione
extends PanelContainer
## Pannello a sinistra: schede per categoria, pulsanti degli edifici con anteprima,
## pulsante per demolire.

signal edificio_scelto(tipo: String)
signal strumento(nome: String, attivo: bool)   # "strada", "demolisci"

var _griglia: GridContainer
var _corpo: VBoxContainer
var _pulsante_chiudi: Button
var _intestazione: HBoxContainer
var _schede: Array[Button] = []
var _pulsanti := {}          # tipo -> Button
var _attrezzi := {}
var _nota: Label
var villaggio: Villaggio
var _categoria := "Base"
var _gruppo := ButtonGroup.new()
var _altezza_aperta := 0.0


func _ready() -> void:
	theme = TemaGioco.crea(16)
	var colonna := VBoxContainer.new()
	colonna.add_theme_constant_override("separation", 8)
	add_child(colonna)
	_intestazione = HBoxContainer.new()
	colonna.add_child(_intestazione)

	var titolo := Label.new()
	titolo.text = "Costruisci"
	titolo.add_theme_font_size_override("font_size", 22)
	titolo.add_theme_color_override("font_color", Palette.TERRACOTTA_SCURA)
	titolo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_intestazione.add_child(titolo)
	_pulsante_chiudi = Button.new()
	_pulsante_chiudi.text = "−"
	_pulsante_chiudi.custom_minimum_size = Vector2(38, 34)
	_pulsante_chiudi.tooltip_text = "Riduci il menu di costruzione"
	_pulsante_chiudi.pressed.connect(alterna)
	_intestazione.add_child(_pulsante_chiudi)

	_corpo = VBoxContainer.new()
	_corpo.add_theme_constant_override("separation", 8)
	colonna.add_child(_corpo)

	var riga := HBoxContainer.new()
	riga.add_theme_constant_override("separation", 4)
	_corpo.add_child(riga)
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
	_corpo.add_child(_griglia)

	_nota = Label.new()
	_nota.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_nota.custom_minimum_size = Vector2(390, 0)
	_nota.add_theme_color_override("font_color", Color(Palette.INCHIOSTRO, 0.7))
	_corpo.add_child(_nota)

	var attrezzi := HBoxContainer.new()
	attrezzi.add_theme_constant_override("separation", 6)
	_corpo.add_child(attrezzi)
	for a in [["strada", "Collegamento", "Collega due punti della rete: la strada trova da sola il percorso. (Tasto R)"],
			["demolisci", "Demolisci", "Clicca un edificio, una strada o un collegamento per toglierli."]]:
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
	call_deferred("_memorizza_altezza_aperta")


func alterna() -> void:
	_corpo.visible = not _corpo.visible
	_pulsante_chiudi.text = "−" if _corpo.visible else "+"
	_pulsante_chiudi.tooltip_text = "Riduci il menu di costruzione" if _corpo.visible else "Espandi il menu di costruzione"
	await get_tree().process_frame
	var nuova_altezza := _altezza_aperta if _corpo.visible else _intestazione.get_combined_minimum_size().y + 22.0
	size.y = nuova_altezza
	# Il pannello è ancorato al centro verticale: mantiene la maniglia sempre nella stessa zona.
	position.y = -nuova_altezza * 0.5
	update_minimum_size()


func _memorizza_altezza_aperta() -> void:
	_altezza_aperta = maxf(size.y, get_combined_minimum_size().y)


func _mostra_categoria(cat: String) -> void:
	_categoria = cat
	for c in _griglia.get_children():
		c.queue_free()
	_pulsanti.clear()
	var tipi := CatalogoEdifici.della_categoria(cat, Popoli.giocatore)
	_nota.text = "" if tipi.size() > 0 else "Torri e soldati arriveranno con la guerra."
	_nota.visible = tipi.is_empty()
	for tipo in tipi:
		var d := CatalogoEdifici.dati(tipo)
		var b := Button.new()
		b.toggle_mode = true
		b.button_group = _gruppo
		b.custom_minimum_size = Vector2(96, 104)
		b.text = d["nome"]
		b.icon = Sprites.icona(Popoli.sprite(tipo, Popoli.giocatore))
		b.expand_icon = true
		b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		b.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		b.add_theme_font_size_override("font_size", 12 if d["nome"].length() > 11 else 13)
		b.add_theme_constant_override("icon_max_width", 84)
		b.tooltip_text = "%s\n%s\nCosto: %s" % [d["nome"], d["descrizione"], CatalogoEdifici.testo_costo(tipo)]
		if d.has("prezzo_ducati"):
			var disponibili: int = 0 if villaggio == null else villaggio.edifici_speciali_acquistati.get(tipo, 0)
			b.disabled = disponibili <= 0
			b.tooltip_text += "\nPrezzo: %d ducati%s" % [d["prezzo_ducati"], " — acquista all'agorà" if disponibili <= 0 else " — disponibili: %d" % disponibili]
		if d.has("attrezzo"):
			b.tooltip_text += "\nAttrezzo: %s (dal magazzino)" % CatalogoEdifici.ATTREZZO_UNO[d["attrezzo"]]
		b.toggled.connect(func(on: bool):
			if on:
				edificio_scelto.emit(tipo)
		)
		_griglia.add_child(b)
		_pulsanti[tipo] = b


func aggiorna() -> void:
	_mostra_categoria(_categoria)


## Toglie la selezione (dopo aver piazzato, o con Esc / tasto destro).
func deseleziona() -> void:
	var premuto := _gruppo.get_pressed_button()
	if premuto:
		premuto.set_pressed_no_signal(false)


func premi_attrezzo(nome: String) -> void:
	if _attrezzi.has(nome):
		_attrezzi[nome].button_pressed = true
