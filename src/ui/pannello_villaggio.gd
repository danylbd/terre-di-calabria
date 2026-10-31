class_name PannelloVillaggio
extends PanelContainer
## Pannello del villaggio (tasto I): popolazione, produzione degli ultimi minuti e tutte le scorte.

const GRUPPI := [
	["Costruzione", ["tronchi", "assi", "pietra"]],
	["Cibo", ["grano", "farina", "acqua", "pane", "pesce", "pesce_spada", "maiale", "carne", "latte", "formaggio",
		"ortaggi", "cipolle", "olive"]],
	["Lusso", ["vino", "olio", "agrumi", "miele", "lana"]],
	["Metallo", ["ferro", "carbone", "lingotti"]],
	["Attrezzi", ["ascia", "piccone", "pala", "falce", "canna", "sega", "martello"]],
]

var villaggio: Villaggio
var logistica: Logistica
var rete: ReteStrade
var _testo: RichTextLabel
var _aggiorna := 0.0


func _ready() -> void:
	theme = TemaGioco.crea(17)
	var colonna := VBoxContainer.new()
	colonna.add_theme_constant_override("separation", 6)
	add_child(colonna)
	var testa := HBoxContainer.new()
	colonna.add_child(testa)
	var titolo := Label.new()
	titolo.text = "Il villaggio"
	titolo.add_theme_font_size_override("font_size", 24)
	titolo.add_theme_color_override("font_color", Palette.TERRACOTTA_SCURA)
	titolo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	testa.add_child(titolo)
	var chiudi := Button.new()
	chiudi.text = "✕"
	chiudi.custom_minimum_size = Vector2(36, 36)
	chiudi.tooltip_text = "Chiudi (I)"
	chiudi.pressed.connect(func(): visible = false)
	testa.add_child(chiudi)
	_testo = RichTextLabel.new()
	_testo.bbcode_enabled = true
	_testo.fit_content = true
	_testo.scroll_active = false
	_testo.custom_minimum_size = Vector2(520, 0)
	_testo.add_theme_color_override("default_color", Palette.INCHIOSTRO)
	colonna.add_child(_testo)
	visible = false


func alterna() -> void:
	visible = not visible
	if visible:
		_riempi()


func _process(delta: float) -> void:
	if not visible:
		return
	_aggiorna -= delta
	if _aggiorna <= 0.0:
		_aggiorna = 0.5
		_riempi()


func _riempi() -> void:
	var v := villaggio
	var righe := []
	var case := v.edifici.values().filter(func(e): return e.tipo == "casa_greca" and e.finito).size()
	righe.append("[b]Popolazione: %d[/b] su %d posti  (%d abitazioni)" % [v.popolazione(), v.capacita(), case])
	righe.append("Coloni liberi %d  ·  portatori %d  ·  lavoratori %d%s" % [v.coloni_liberi, rete.portatori(), v.lavoratori(),
		"  ·  in arrivo %d" % v.in_cammino if v.in_cammino > 0 else ""])
	var senza := rete.tratti_senza_portatore()
	if senza > 0:
		righe.append("[color=#a8321e]%d strade aspettano un portatore[/color]" % senza)
	righe.append("")
	var prod := logistica.produzione_recente()
	righe.append("[b]Prodotto negli ultimi 5 minuti[/b]")
	if prod.is_empty():
		righe.append("ancora niente")
	else:
		var parti := []
		for r in prod:
			parti.append("%s %d" % [CatalogoEdifici.NOMI_RISORSE.get(r, r), prod[r]])
		righe.append(",  ".join(parti))
	righe.append("")
	righe.append("[b]In magazzino[/b]")
	for g in GRUPPI:
		var parti := []
		for r in g[1]:
			if v.scorte.get(r, 0) > 0 or g[0] == "Costruzione":
				parti.append("%s %d" % [CatalogoEdifici.NOMI_RISORSE[r], v.scorte.get(r, 0)])
		righe.append("%s:  %s" % [g[0], ",  ".join(parti) if not parti.is_empty() else "—"])
	_testo.text = "\n".join(righe)
