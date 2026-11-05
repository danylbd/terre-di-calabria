class_name PannelloEdificio
extends PanelContainer
## Pannello che si apre cliccando un edificio: cosa fa, a che punto è, perché è fermo,
## le merci che riceve e quante ne ha prodotte. Da qui si può tracciare una strada o demolire.

signal strada_da(e: Edificio)
signal demolisci(e: Edificio)
signal attacca(e: Edificio)
signal forma_schiera(e: Edificio)
signal arma_nave(e: Edificio)
signal costruisci_macchina(tipo: String, e: Edificio)
signal manda_pioniere(e: Edificio)

var edificio: Edificio
var villaggio: Villaggio
var _titolo: Label
var _testo: RichTextLabel
var _icona: TextureRect
var _aggiorna := 0.0
var _compra: OptionButton
var _riga_compra: HBoxContainer
var _riga_speciali: HBoxContainer
var _speciale: OptionButton
var _compra_speciale: Button
var _pulsanti: HBoxContainer
var _attacca: Button
var _schiera: Button
var schiere: Schiere
var navi_guerra: NaviGuerra
var _nave: Button
var _macchine := {}                  # "ariete"/"onagro" -> Button (all'armaiolo)
var _produzione: Button
var _pioniere: Button
var _priorita: Button


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

	_riga_compra = HBoxContainer.new()
	_riga_compra.add_theme_constant_override("separation", 8)
	colonna.add_child(_riga_compra)
	var et := Label.new()
	et.text = "Compra con i ducati:"
	et.add_theme_color_override("font_color", Palette.INCHIOSTRO)
	_riga_compra.add_child(et)
	_compra = OptionButton.new()
	_compra.add_item("niente")
	for m in CatalogoEdifici.ACQUISTO:
		_compra.add_item("%s (%d)" % [CatalogoEdifici.NOMI_RISORSE[m], CatalogoEdifici.ACQUISTO[m]])
	_compra.item_selected.connect(func(i: int):
		if edificio:
			edificio.acquisto = "" if i == 0 else CatalogoEdifici.ACQUISTO.keys()[i - 1])
	_riga_compra.add_child(_compra)
	_riga_speciali = HBoxContainer.new()
	_riga_speciali.add_theme_constant_override("separation", 8)
	colonna.add_child(_riga_speciali)
	var titolo_speciali := Label.new()
	titolo_speciali.text = "Edifici speciali:"
	titolo_speciali.add_theme_color_override("font_color", Palette.INCHIOSTRO)
	_riga_speciali.add_child(titolo_speciali)
	_speciale = OptionButton.new()
	for tipo in CatalogoEdifici.EDIFICI_SPECIALI:
		var d := CatalogoEdifici.dati(tipo)
		_speciale.add_item("%s (%d ducati)" % [d["nome"], d["prezzo_ducati"]])
	_riga_speciali.add_child(_speciale)
	_compra_speciale = Button.new()
	_compra_speciale.text = "Compra"
	_compra_speciale.pressed.connect(func():
		if edificio and villaggio.acquista_edificio_speciale(CatalogoEdifici.EDIFICI_SPECIALI[_speciale.selected]):
			_riempi())
	_riga_speciali.add_child(_compra_speciale)

	var pulsanti := HBoxContainer.new()
	pulsanti.add_theme_constant_override("separation", 8)
	colonna.add_child(pulsanti)
	_pulsanti = pulsanti
	_attacca = Button.new()
	_attacca.text = "Attacca"
	_attacca.tooltip_text = "Scegli una torre nemica vicina: partono tutti i soldati tranne uno"
	_attacca.custom_minimum_size = Vector2(100, 36)
	_attacca.pressed.connect(func(): attacca.emit(edificio))
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
	pulsanti.add_child(_attacca)
	_schiera = Button.new()
	_schiera.text = "Schiera"
	_schiera.custom_minimum_size = Vector2(100, 36)
	_schiera.pressed.connect(func(): forma_schiera.emit(edificio))
	pulsanti.add_child(_schiera)
	_nave = Button.new()
	_nave.text = "Nave da guerra"
	_nave.custom_minimum_size = Vector2(140, 36)
	_nave.pressed.connect(func(): arma_nave.emit(edificio))
	pulsanti.add_child(_nave)
	_produzione = Button.new()
	_produzione.custom_minimum_size = Vector2(140, 36)
	_produzione.pressed.connect(func():
		if edificio:
			edificio.produzione_attiva = not edificio.produzione_attiva
			_riempi())
	pulsanti.add_child(_produzione)
	_pioniere = Button.new()
	_pioniere.text = "Invia pioniere"
	_pioniere.custom_minimum_size = Vector2(140, 36)
	_pioniere.tooltip_text = "Manda un colono a fondare un avamposto entro 18 caselle"
	_pioniere.pressed.connect(func():
		if edificio:
			manda_pioniere.emit(edificio))
	pulsanti.add_child(_pioniere)
	_priorita = Button.new()
	_priorita.custom_minimum_size = Vector2(140, 36)
	_priorita.pressed.connect(func():
		if edificio:
			edificio.priorita_materiali = (edificio.priorita_materiali + 1) % 3
			_riempi())
	pulsanti.add_child(_priorita)
	for t in Schiere.MACCHINE:
		var b := Button.new()
		b.text = Schiere.MACCHINE[t]["nome"]
		b.custom_minimum_size = Vector2(100, 36)
		b.pressed.connect(func(): costruisci_macchina.emit(t, edificio))
		pulsanti.add_child(b)
		_macchine[t] = b
	visible = false


func mostra(e: Edificio) -> void:
	edificio = e
	visible = true
	_icona.texture = Sprites.icona(Popoli.sprite(e.tipo, Popoli.di(e.proprietario)))
	_titolo.text = CatalogoEdifici.dati(e.tipo)["nome"]
	_riga_compra.visible = e.tipo == "agora"
	_riga_speciali.visible = e.tipo == "agora"
	_pulsanti.visible = e.proprietario == 1
	if e.tipo == "agora":
		_compra.select(0 if e.acquisto == "" else CatalogoEdifici.ACQUISTO.keys().find(e.acquisto) + 1)
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
	_attacca.visible = info.has("soldati_max") and e.presidiata
	_attacca.disabled = e.soldati < 2
	_nave.visible = e.tipo == "porto" and e.finito and Schiere.attive() and navi_guerra != null
	var prodotti := CatalogoEdifici.prodotti(e.tipo).filter(func(p): return p != "")
	_produzione.visible = e.proprietario == 1 and e.finito and not prodotti.is_empty()
	_produzione.text = "Ferma produzione" if e.produzione_attiva else "Riprendi produzione"
	_produzione.tooltip_text = "La produzione attiva riprenderà quando ci sarà spazio fuori dall'edificio e nel magazzino."
	_pioniere.visible = e.proprietario == 1 and e.tipo == "casa_pionieri" and e.finito
	_pioniere.disabled = villaggio.coloni_liberi <= 0 or villaggio.scorte.get("assi", 0) < 2
	_priorita.visible = not e.finito
	_priorita.text = ["Priorità normale", "Priorità alta", "Priorità urgente"][e.priorita_materiali]
	_priorita.tooltip_text = "Cambia la priorità con cui il magazzino invia i materiali a questo cantiere"
	if _nave.visible:
		var no := navi_guerra.motivo_no_nave(e)
		_nave.disabled = no != ""
		_nave.tooltip_text = no if no != "" else "Assi 6, armi 2: va a colpire la torre nemica più vicina alla costa"
	for t in _macchine:
		var b: Button = _macchine[t]
		b.visible = e.tipo == Schiere.edificio_macchina(t) and Schiere.macchina_del_popolo(t) and e.finito and Schiere.attive() and schiere != null
		if b.visible:
			var no := schiere.motivo_no_macchina(t)
			b.disabled = no != ""
			b.tooltip_text = no if no != "" else Schiere.MACCHINE[t]["descrizione"]
	_schiera.visible = e.tipo in ["caserma", "castello", "mastio"] and e.finito and Schiere.attive()
	if _schiera.visible and schiere:
		var perche := schiere.motivo_no_schiera()
		_schiera.disabled = perche != ""
		_schiera.tooltip_text = perche if perche != "" else "%s esce con i soldati di riserva (fino a %d)" % [Schiere.nome_condottiero(), Schiere.MAX_SOLDATI]
	if e.proprietario != 1:
		righe.append("[b]Difensori: %d[/b]" % e.soldati)
		_testo.text = "\n".join(righe)
		return
	if e.tipo == "agora":
		var speciale: String = CatalogoEdifici.EDIFICI_SPECIALI[_speciale.selected]
		_compra_speciale.disabled = villaggio.scorte.get("ducati", 0) < CatalogoEdifici.dati(speciale)["prezzo_ducati"]
	if info.has("soldati_max") and e.finito:
		righe.append("Soldati: %d / %d%s" % [e.soldati, info["soldati_max"], "  (+%d in arrivo)" % e.soldati_in_arrivo if e.soldati_in_arrivo > 0 else ""])
	righe.append("[b]%s[/b]" % stato(e, villaggio))
	if not e.finito:
		for r in e.fabbisogno:
			righe.append("%s: %d / %d" % [CatalogoEdifici.NOMI_RISORSE[r], e.consegnati.get(r, 0), e.fabbisogno[r]])
	else:
		var ingressi := CatalogoEdifici.merci_in_ingresso(e.tipo)
		if not ingressi.is_empty():
			var parti := []
			for r in ingressi:
				var g := CatalogoEdifici.gruppo(e.tipo)
				if not g.is_empty() and r in g[0] and e.ingresso.get(r, 0) + e.in_arrivo.get(r, 0) == 0:
					continue
				parti.append("%s %d%s" % [CatalogoEdifici.NOMI_RISORSE[r], e.ingresso.get(r, 0),
					" (+%d in arrivo)" % e.in_arrivo[r] if e.in_arrivo.get(r, 0) > 0 else ""])
			if info.has("cibo"):
				parti.append("cibo per i minatori fino a %d" % info["cibo"])
			if info.has("vende"):
				parti.append("merci da vendere fino a %d" % info["vende"])
			righe.append("Riceve: " + ", ".join(parti))
		if e.tipo == "agora":
			righe.append("Ducati in cassa: %d  —  guadagnati qui: %d" % [villaggio.scorte.get("ducati", 0), e.guadagno])
			var listino := []
			for m in CatalogoEdifici.VENDITA:
				listino.append("%s %d" % [CatalogoEdifici.NOMI_RISORSE[m].to_lower(), CatalogoEdifici.VENDITA[m]])
			righe.append("[font_size=14]Vende (ducati): %s[/font_size]" % ", ".join(listino))
		var prodotti_edificio := CatalogoEdifici.prodotti(e.tipo).filter(func(p): return p != "")
		if not prodotti_edificio.is_empty():
			var nomi := prodotti_edificio.map(func(p): return "attrezzi" if p == "attrezzi" else CatalogoEdifici.NOMI_RISORSE[p].to_lower())
			righe.append("Produce: %s  —  finora %d" % [", ".join(nomi), e.prodotti])
	_testo.text = "\n".join(righe)


## Una frase che dice a che punto è l'edificio e, se è fermo, perché.
static func stato(e: Edificio, v: Villaggio) -> String:
	var info := CatalogoEdifici.dati(e.tipo)
	if not e.finito:
		if not e.collegato:
			return "Cantiere senza strada: collegalo con una strada"
		if not e.costruttore_al_lavoro():
			if e.costruttore == null and e.manca_colono:
				return "Nessun colono libero per costruire: costruisci abitazioni"
			return "Il costruttore sta arrivando (%d%%)" % int(e.progresso * 100)
		if e.progresso >= e.frazione_materiali():
			return "Il costruttore aspetta assi e pietre (%d%%)" % int(e.progresso * 100)
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
	if e.tipo == "caserma" and e.lavoratore and e.lavoratore.entrato:
		if e.ingresso.get("armi", 0) <= 0:
			return "Aspetta le armi dall'armaiolo"
		if v.coloni_liberi <= 0:
			return "Non ci sono coloni liberi da addestrare"
		return "Addestra gli opliti (finora %d)" % e.prodotti
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
