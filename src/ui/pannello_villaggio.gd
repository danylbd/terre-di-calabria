class_name PannelloVillaggio
extends PanelContainer
## Pannello del villaggio (tasto I): popolazione, produzione degli ultimi minuti e tutte le scorte.

const GRUPPI := [
	["Costruzione", ["tronchi", "assi", "pietra"]],
	["Cibo", ["grano", "farina", "acqua", "pane", "pesce", "pesce_spada", "maiale", "carne", "latte", "formaggio",
		"ortaggi", "cipolle", "olive"]],
	["Lusso", ["vino", "olio", "agrumi", "miele", "lana", "stoffa", "anfore", "pece"]],
	["Metallo", ["ferro", "carbone", "lingotti", "argento", "ducati", "armi"]],
	["Altro", ["argilla", "sale"]],
	["Attrezzi", ["ascia", "piccone", "pala", "falce", "canna", "sega", "martello"]],
]

var villaggio: Villaggio
var logistica: Logistica
var rete: ReteStrade
var stagioni: Stagioni
var avversario: Avversario
var monumenti: Monumenti
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
	if stagioni:
		righe.append("[b]%s[/b]%s" % [stagioni.nome(), "  —  d'inverno i campi non crescono e non si semina" if stagioni.inverno() else ""])
	if avversario:
		var stato := "nessun nemico" if not avversario.attivo else (
			Popoli.testo("i Brettii sono in pace") if not avversario.guerra_dichiarata else (
			"guerra fra %d s" % ceili(avversario.tregua - avversario.tempo) if avversario.tempo < avversario.tregua else Popoli.testo("in guerra con i Brettii")))
		righe.append("Partita: %s  —  %s" % [Impostazioni.MODALITA[avversario.modalita][0], stato])
	var case := v.edifici.values().filter(func(e): return e.tipo == "casa_greca" and e.finito).size()
	righe.append("[b]Popolazione: %d[/b] su %d posti  (%d abitazioni)" % [v.popolazione(), v.capacita(), case])
	righe.append("Coloni liberi %d  ·  portatori %d  ·  lavoratori %d%s" % [v.coloni_liberi, rete.portatori(), v.lavoratori(),
		"  ·  in arrivo %d" % v.in_cammino if v.in_cammino > 0 else ""])
	var nei_forti := 0
	for e in v.edifici.values():
		nei_forti += e.soldati
	righe.append("Soldati: %d nei forti, %d di riserva" % [nei_forti, v.soldati])
	var senza := rete.tratti_senza_portatore()
	if senza > 0:
		righe.append("[color=#a8321e]%d strade aspettano un portatore[/color]" % senza)
	if monumenti and monumenti.attivi:
		righe.append("")
		righe.append("[b]Monumenti di Monteleone: %d di %d[/b]" % [monumenti.ottenuti.size(), Monumenti.CATALOGO.size()])
		for id in monumenti.ottenuti:
			var m := Monumenti.voce(id)
			righe.append("[color=#3d6b2a]✔[/color] %s  —  %s" % [m["nome"], m["vantaggio"].to_lower()])
		var prossimo := monumenti.prossimo_monumento()
		if prossimo.is_empty():
			righe.append("Monteleone ha tutti i suoi monumenti!")
		else:
			righe.append("Prossimo: [b]%s[/b]  —  traguardo: %s" % [prossimo["nome"], prossimo["traguardo"].to_lower()])
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
