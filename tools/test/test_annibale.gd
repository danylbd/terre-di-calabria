extends SceneTree
## Test automatico dello step 39 (campagna «Annibale nel Bruzio»): otto missioni sulla mappa del Bruzio,
## sempre aperta, giocabile dai due lati (Cartagine o Roma) con i racconti diversi; nelle sue missioni ci sono
## le schiere e i villaggi indigeni; le prove nuove (villaggi, schiera, livello del condottiero, macchine,
## nessun nemico); la mappa della Calabria con il pulsante della campagna e la scelta del lato.
## Uso: godot --headless --path . --script tools/test/test_annibale.gd

const PROGRESSI := "user://test_annibale.json"

var p: Node2D
var errori := 0


func _initialize() -> void:
	_prova.call_deferred()


func _prova() -> void:
	Missione.progressi = PROGRESSI
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PROGRESSI))
	var c := Missione.CAMPAGNA_ANNIBALE
	_controlla(c.size() == 8, "la campagna di Annibale ha 8 missioni")
	var adatte := c.filter(func(m): return Missione.MISSIONI[m]["mappa"] == "bruzio" and Missione.MISSIONI[m]["popolo"] == "lato" and Missione.MISSIONI[m]["schiere"] and Missione.MISSIONI[m]["indigeni"])
	_controlla(adatte.size() == 8, "tutte nel Bruzio, con il lato scelto, le schiere e i villaggi")
	var complete := c.filter(func(m): return not Missione.MISSIONI[m]["obiettivi"].is_empty() and not Missione.per_lato(Missione.MISSIONI[m]["fine"]).is_empty())
	_controlla(complete.size() == 8, "tutte hanno obiettivi e finale")
	_controlla(Missione.sbloccata(c[0]) and not Missione.sbloccata(c[1]), "è aperta dall'inizio, una missione dopo l'altra")
	Missione.segna_compiuta(c[0])
	_controlla(Missione.sbloccata(c[1]) and not Missione.sbloccata(c[2]), "finita la prima si apre la seconda")
	_controlla(not Missione.lato_scelto() and Missione.lato_annibale() == "cartaginesi", "prima della scelta il lato è Cartagine")
	Missione.scegli_lato_annibale("romani")
	_controlla(Missione.lato_scelto() and Missione.lato_annibale() == "romani", "si sceglie Roma")
	var inizio := Missione.per_lato(Missione.MISSIONI[c[0]]["inizio"])
	_controlla(inizio[-1][0] == "Gaio Settimio", "con Roma parla Gaio Settimio")
	Missione.scegli_lato_annibale("cartaginesi")
	inizio = Missione.per_lato(Missione.MISSIONI[c[0]]["inizio"])
	_controlla(inizio[-1][0] == "Annibale", "con Cartagine parla Annibale")

	# una missione con Roma: i Romani contro i Brettii, sulla mappa del Bruzio
	Missione.scegli_lato_annibale("romani")
	await _partita("annibale_condottiero")
	_controlla(p.popolo == "romani" and p.mappa == "bruzio" and Popoli.nemico() == "brettii", "con Roma si gioca contro i Brettii nel Bruzio")
	_controlla(Schiere.attive() and p.indigeni.attivi and p.indigeni.elenco.size() == 3, "nella missione ci sono le schiere e i villaggi indigeni")
	_controlla(p.villaggio.nemici.size() == 2, "ci sono due torri nemiche")
	var m: Missione = p.missione
	var v: Villaggio = p.villaggio
	var sch: Schiere = p.schiere
	_controlla(not m.raggiunto({"prova": "schiera", "n": 10}), "senza schiera la prova non è raggiunta")
	var caserma: Edificio = null
	var armaiolo: Edificio = null
	var d: DatiMappa = p.dati
	for y in range(d.villaggio.y - 10, d.villaggio.y + 11):
		for x in range(d.villaggio.x - 10, d.villaggio.x + 11):
			if caserma == null and v.puo_costruire("caserma", Vector2i(x, y)):
				caserma = v.costruisci("caserma", Vector2i(x, y), true, true)
			elif armaiolo == null and v.puo_costruire("armaiolo", Vector2i(x, y)):
				armaiolo = v.costruisci("armaiolo", Vector2i(x, y), true, true)
	v.soldati = 12
	_controlla(caserma != null and sch.forma(caserma), "la schiera esce dalla caserma")
	_controlla(m.raggiunto({"prova": "schiera", "n": 10}), "prova: una schiera di almeno 10 soldati")
	v.scorte["assi"] = 10
	v.scorte["armi"] = 2
	_controlla(armaiolo != null and sch.costruisci_macchina("ariete", armaiolo) and m.raggiunto({"prova": "macchina", "n": 1}), "prova: una macchina d'assedio")
	_controlla(not m.raggiunto({"prova": "condottiero_livello", "n": 3}), "il condottiero è ancora al livello 1")
	sch.esperienza = Schiere.ESPERIENZA_LIVELLO * 2
	_controlla(m.raggiunto({"prova": "condottiero_livello", "n": 3}), "prova: il condottiero al livello 3")
	_controlla(not m.raggiunto({"prova": "villaggi", "n": 1}), "nessun villaggio alleato all'inizio")
	p.indigeni.elenco[0]["stato"] = "alleato"
	_controlla(m.raggiunto({"prova": "villaggi", "n": 1}), "prova: un villaggio alleato")
	for n in v.nemici.values():
		v.rimuovi_nemico(n)
	_controlla(m.raggiunto({"prova": "nemici_zero"}), "prova: nessuna torre nemica")

	# la stessa missione con Cartagine
	Missione.scegli_lato_annibale("cartaginesi")
	await _partita("annibale_sbarco")
	_controlla(p.popolo == "cartaginesi" and Popoli.nemico() == "romani" and Schiere.nome_condottiero() == "Annibale", "con Cartagine si gioca con Annibale contro Roma")
	_controlla(p.villaggio.nemici.is_empty(), "nella prima missione non ci sono nemici")
	p.queue_free()
	await process_frame
	Impostazioni.missione = ""
	_controlla(not Schiere.attive() or Impostazioni.modalita != "pace", "fuori dalle missioni tutto come prima")

	# la mappa della Calabria
	var mappa = load("res://src/main/mappa_calabria.tscn").instantiate()
	root.add_child(mappa)
	await process_frame
	_controlla(mappa._annibale != null and not mappa._annibale.disabled and mappa._bruzio != null, "sulla mappa c'è la campagna di Annibale, aperta, e la partita nel Bruzio")
	var dentro := true
	for b in [mappa._annibale, mappa._bruzio]:
		if not Rect2(Vector2.ZERO, mappa.size).encloses(Rect2(b.position, b.size)):
			dentro = false
	_controlla(dentro, "i pulsanti stanno dentro lo schermo")
	Missione.segna_compiuta(c[1])
	mappa._apri_annibale()
	_controlla(not mappa._scelta_lato.visible, "a campagna avviata si continua senza riscegliere il lato")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PROGRESSI))
	Missione.progressi = PROGRESSI
	mappa._apri_annibale()
	_controlla(mappa._scelta_lato.visible and mappa._scelta_lato.get_child(0).get_child_count() == 4, "all'inizio si sceglie tra Cartagine e Roma")
	mappa.queue_free()
	Impostazioni.popolo = "greci"
	Popoli.giocatore = "greci"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PROGRESSI))
	print("RISULTATO: %s (%d errori)" % ["OK" if errori == 0 else "FALLITO", errori])
	quit(1 if errori > 0 else 0)


func _partita(id: String) -> void:
	if p:
		p.queue_free()
		await process_frame
	Impostazioni.missione = id
	p = load("res://src/mappa/partita.tscn").instantiate()
	root.add_child(p)
	await process_frame
	await process_frame
	var pm: PannelloMissione = p.pannello_missione
	while pm.dialogo_aperto():
		pm.avanti()


func _controlla(ok: bool, cosa: String) -> void:
	print(("  ok  " if ok else "  NO  ") + cosa)
	if not ok:
		errori += 1
