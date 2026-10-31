class_name PannelloEdificio
extends PanelContainer
## Pannello che si apre cliccando un edificio: cosa fa, a che punto è, perché è fermo,
## le merci che riceve e quante ne ha prodotte. Da qui si può tracciare una strada o demolire.

signal strada_da(e: Edificio)
signal demolisci(e: Edificio)

var edificio: Edificio
var villaggio: Villaggio
var _titolo: Label
var _testo: RichTextLabel
var _icona: TextureRect
var _aggiorna := 0.0


func _ready() -> void:
	theme = TemaGioco.crea(17)
	custom_minimum_size = Vector2(380, 0)
	var colonna := VBoxContainer.new()
	colonna.add_theme_constant_override("separation", 8)
	add_child(colonna)

	var testa := HBoxContainer.new()
	colonna.add_child(testa)
	_icona = TextureRect.new()
	_icona.custom_minimum_size = Vector2(72, 56)
	_icona.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_icona.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	testa.add_child(_icona)
	_titolo = Label.new()
	_titolo.add_theme_font_size_override("font_size", 24)
	_titolo.add_theme_color_override("font_color", Palette.TERRACOTTA_SCURA)
	_titolo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_titolo.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	testa.add_child(_titolo)
	var chiudi := Button.new()
	chiudi.text = "✕"
	chiudi.custom_minimum_size = Vector2(36, 36)
	chiudi.tooltip_text = "Chiudi (Esc)"
	chiudi.pressed.connect(chiudi_pannello)
	testa.add_child(chiudi)

	_testo = RichTextLabel.new()
	_testo.bbcode_enabled = true
	_testo.fit_content = true
	_testo.scroll_active = false
	_testo.custom_minimum_size = Vector2(360, 0)
	_testo.add_theme_color_override("default_color", Palette.INCHIOSTRO)
	colonna.add_child(_testo)

	var pulsanti := HBoxContainer.new()
	pulsanti.add_theme_constant_override("separation", 8)
	colonna.add_child(pulsanti)
	var strada := Button.new()
	strada.text = "Strada da qui"
	strada.custom_minimum_size = Vector2(150, 36)
	strada.pressed.connect(func(): strada_da.emit(edificio))
	pulsanti.add_child(strada)
	var demol := Button.new()
	demol.text = "Demolisci"
	demol.custom_minimum_size = Vector2(120, 36)
	demol.pressed.connect(func(): demolisci.emit(edificio))
	pulsanti.add_child(demol)
	visible = false


func mostra(e: Edificio) -> void:
	edificio = e
	visible = true
	_icona.texture = Sprites.icona(e.tipo)
	_titolo.text = CatalogoEdifici.dati(e.tipo)["nome"]
	_riempi()


func chiudi_pannello() -> void:
	visible = false
	edificio = null


func _process(delta: float) -> void:
	if not visible:
		return
	if not is_instance_valid(edificio) or edificio.is_queued_for_deletion():
		chiudi_pannello()
		return
	_aggiorna -= delta
	if _aggiorna <= 0.0:
		_aggiorna = 0.4
		_riempi()


func _riempi() -> void:
	var e := edificio
	var info := CatalogoEdifici.dati(e.tipo)
	var righe := []
	righe.append("[i]%s[/i]" % info["descrizione"])
	righe.append("[b]%s[/b]" % stato(e, villaggio))
	if not e.finito:
		for r in e.fabbisogno:
			righe.append("%s: %d / %d" % [CatalogoEdifici.NOMI_RISORSE[r], e.consegnati.get(r, 0), e.fabbisogno[r]])
	else:
		var ingressi := CatalogoEdifici.merci_in_ingresso(e.tipo)
		if not ingressi.is_empty():
			var parti := []
			for r in ingressi:
				if r in CatalogoEdifici.CIBI and info.has("cibo") and e.ingresso.get(r, 0) + e.in_arrivo.get(r, 0) == 0:
					continue
				parti.append("%s %d%s" % [CatalogoEdifici.NOMI_RISORSE[r], e.ingresso.get(r, 0),
					" (+%d in arrivo)" % e.in_arrivo[r] if e.in_arrivo.get(r, 0) > 0 else ""])
			if info.has("cibo"):
				parti.append("cibo per i minatori fino a %d" % info["cibo"])
			righe.append("Riceve: " + ", ".join(parti))
		var prodotti := CatalogoEdifici.prodotti(e.tipo)
		if not prodotti.is_empty():
			var nomi := prodotti.map(func(p): return "attrezzi" if p == "attrezzi" else CatalogoEdifici.NOMI_RISORSE[p].to_lower())
			righe.append("Produce: %s  —  finora %d" % [", ".join(nomi), e.prodotti])
	_testo.text = "\n".join(righe)


## Una frase che dice a che punto è l'edificio e, se è fermo, perché.
static func stato(e: Edificio, v: Villaggio) -> String:
	var info := CatalogoEdifici.dati(e.tipo)
	if not e.finito:
		if not e.collegato:
			return "Cantiere senza strada: collegalo con una strada"
		return "In costruzione: %d%%" % int(e.progresso * 100)
	if not e.collegato:
		return "Non è collegato al magazzino con una strada"
	if e.tipo == "magazzino":
		return "Coloni liberi: %d" % v.coloni_liberi
	if info.has("abitanti"):
		if v.popolazione() >= v.capacita():
			return "Il villaggio è pieno: costruisci altre abitazioni"
		return "Il prossimo colono nasce tra %d s" % ceili(maxf(e.nascita, 0.0))
	if not info.has("lavoratore"):
		return "Pronto"
	if e.lavoratore == null:
		if e.manca_attrezzo:
			return "Aspetta un attrezzo: %s" % CatalogoEdifici.ATTREZZO_UNO[info["attrezzo"]]
		if e.manca_colono:
			return "Non ci sono coloni liberi: costruisci abitazioni"
		return "Il lavoratore sta arrivando"
	var l: Lavoratore = e.lavoratore
	if not l.entrato:
		return "Il lavoratore sta arrivando"
	var mancano := []
	for r in info.get("ingressi", {}):
		if e.ingresso.get(r, 0) <= 0:
			mancano.append(CatalogoEdifici.NOMI_RISORSE[r].to_lower())
	if info.has("cibo"):
		var cibo := 0
		for c in CatalogoEdifici.CIBI:
			cibo += e.ingresso.get(c, 0)
		if cibo == 0:
			mancano.append("cibo")
	if l.stato == Lavoratore.Stato.DENTRO and not mancano.is_empty():
		return "Fermo: mancano " + ", ".join(mancano)
	if l.stato in [Lavoratore.Stato.ANDATA, Lavoratore.Stato.LAVORO, Lavoratore.Stato.RITORNO, Lavoratore.Stato.ESCE_CON_MERCE]:
		return "Al lavoro"
	return "In attesa"
