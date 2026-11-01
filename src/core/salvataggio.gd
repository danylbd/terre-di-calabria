class_name Salvataggio
## Salva e carica la partita in un file JSON. La mappa si rigenera identica dal seme, quindi si salva
## solo quello che cambia: natura (alberi, massi, campi, pesce, giacimenti), edifici, bandierine,
## strade, merci in viaggio, scorte, coloni e statistiche. Portatori e lavoratori vengono ricreati.

const PERCORSO := "user://salvataggio.json"
const VERSIONE := 1

## Partita da caricare all'avvio della scena di gioco ("" = nuova partita).
static var da_caricare := ""


static func esiste(percorso := PERCORSO) -> bool:
	return FileAccess.file_exists(percorso)


static func _v(c: Vector2i) -> Array:
	return [c.x, c.y]


static func _c(a: Array) -> Vector2i:
	return Vector2i(int(a[0]), int(a[1]))


static func _nome(s: Sprite2D) -> String:
	return s.texture.resource_path.get_file().get_basename() if s.texture else ""


static func _chiavi(d: Dictionary) -> Array:
	var r := []
	for c in d:
		r.append([c.x, c.y, d[c]])
	return r


static func _da_chiavi(a: Array) -> Dictionary:
	var r := {}
	for voce in a:
		r[Vector2i(int(voce[0]), int(voce[1]))] = voce[2]
	return r


# ------------------------------------------------------------------ salvare

## La mappa su cui è stata salvata la partita (i salvataggi vecchi sono tutti sulla Costa ionica).
static func mappa_di(percorso := PERCORSO) -> String:
	var f := FileAccess.open(percorso, FileAccess.READ)
	if f == null:
		return "costa_ionica"
	var d = JSON.parse_string(f.get_as_text())
	f.close()
	if d is Dictionary and GeneratoreMappa.MAPPE.has(str(d.get("mappa", ""))):
		return d["mappa"]
	return "costa_ionica"


## Il popolo del giocatore nel salvataggio (i salvataggi vecchi sono tutti dei Greci).
static func popolo_di(percorso := PERCORSO) -> String:
	var f := FileAccess.open(percorso, FileAccess.READ)
	if f == null:
		return "greci"
	var d = JSON.parse_string(f.get_as_text())
	f.close()
	if d is Dictionary and Popoli.DATI.has(str(d.get("popolo", ""))):
		return d["popolo"]
	return "greci"


static func salva(p: Node2D, percorso := PERCORSO) -> bool:
	var v: Villaggio = p.villaggio
	var rete: ReteStrade = p.rete
	var ris: RisorseNaturali = p.risorse
	var log: Logistica = p.logistica
	var d := {"versione": VERSIONE, "seme": p.SEME, "mappa": p.mappa, "popolo": p.popolo, "tempo": log.tempo, "storia": log.storia, "calendario": p.stagioni.tempo,
		"scorte": v.scorte, "coloni_liberi": v.coloni_liberi + v.in_cammino,
		"camera": [p.camera.position.x, p.camera.position.y, p.camera.zoom.x]}
	# natura
	var alberi := []
	for c in ris.alberi:
		for a in ris.alberi[c]:
			var s: Sprite2D = a["sprite"]
			alberi.append([c.x, c.y, a["specie"], a["crescita"], _nome(s), s.position.x, s.position.y])
	d["alberi"] = alberi
	var rocce := []
	for c in ris.rocce:
		var s: Sprite2D = ris.rocce[c]["sprite"]
		rocce.append([c.x, c.y, ris.rocce[c]["riserva"], _nome(s), s.position.x, s.position.y])
	d["rocce"] = rocce
	var campi := []
	for c in ris.campi:
		campi.append([c.x, c.y, ris.campi[c]["coltura"], ris.campi[c]["crescita"]])
	d["campi"] = campi
	var ceppi := []
	for k in ris._ceppi:
		var s: Sprite2D = k[0]
		ceppi.append([_nome(s), s.position.x, s.position.y, k[1]])
	d["ceppi"] = ceppi
	d["pesci"] = _chiavi(ris.pesci)
	d["ripopola"] = _chiavi(ris._ripopola)
	d["spada"] = _chiavi(ris.spada)
	d["ripopola_spada"] = _chiavi(ris._ripopola_spada)
	d["olive_attesa"] = _chiavi(ris._olive_attesa)
	var minerali := {}
	for tipo in ris.minerali:
		minerali[tipo] = _chiavi(ris.minerali[tipo])
	d["minerali"] = minerali
	# villaggio
	var edifici := []
	for e in v.edifici.values():
		edifici.append({"id": e.id, "tipo": e.tipo, "casella": _v(e.casella), "finito": e.finito, "progresso": e.progresso,
			"consegnati": e.consegnati, "richiesti": e.richiesti, "ingresso": e.ingresso, "in_arrivo": e.in_arrivo,
			"prodotti": e.prodotti, "nascita": e.nascita, "acquisto": e.acquisto, "guadagno": e.guadagno, "presidiata": e.presidiata, "soldati": e.soldati + e.soldati_in_arrivo, "manca_attrezzo": e.manca_attrezzo, "manca_colono": e.manca_colono,
			"lavoratore": e.lavoratore != null and is_instance_valid(e.lavoratore)})
	d["edifici"] = edifici
	var nemici := []
	for n in v.nemici.values():
		nemici.append([n.tipo, n.casella.x, n.casella.y, n.proprietario, n.soldati])
	d["nemici"] = nemici
	if p.missione:
		d["missione"] = [p.missione.id, p.missione.indice]
	d["avversario"] = [p.avversario.tempo, p.avversario._espansione, p.avversario._attacco, p.avversario.attivo,
		p.avversario.modalita, p.avversario.tregua, p.avversario.guerra_dichiarata]
	# i soldati in marcia tornano nella riserva (quelli all'attacco ricominceranno da capo)
	d["soldati"] = v.soldati + p.guerra.in_marcia()
	d["indigeni"] = p.indigeni.dati_salvataggio()
	var mon: Monumenti = p.monumenti
	d["monumenti"] = {"ottenuti": mon.ottenuti.map(func(id): return [id, mon.posti[id].x, mon.posti[id].y]),
		"prodotti": mon.prodotti, "senza_perdite": mon.tempo_senza_perdite}
	var bandiere := []
	for c in rete.bandiere:
		bandiere.append([c.x, c.y, rete.bandiere[c]["protetta"]])
	d["bandiere"] = bandiere
	var tratti := []
	for t in rete.tratti.values():
		tratti.append({"percorso": t.percorso.map(func(c): return _v(c)), "portatore": t.portatore != null})
	d["tratti"] = tratti
	var merci := []
	for m in log.merci:
		if is_instance_valid(m.destinazione):
			merci.append([m.tipo, m.bandiera.x, m.bandiera.y, m.destinazione.id])
	d["merci"] = merci
	var f := FileAccess.open(percorso, FileAccess.WRITE)
	if f == null:
		push_warning("Impossibile salvare in " + percorso)
		return false
	f.store_string(JSON.stringify(d))
	f.close()
	return true


# ------------------------------------------------------------------ caricare

## Ricostruisce la partita salvata dentro una scena di gioco appena creata (con la natura già messa
## dal generatore, ma senza il villaggio iniziale). Restituisce false se il file non va bene.
static func carica(p: Node2D, percorso := PERCORSO) -> bool:
	var f := FileAccess.open(percorso, FileAccess.READ)
	if f == null:
		return false
	var d = JSON.parse_string(f.get_as_text())
	f.close()
	if not d is Dictionary or int(d.get("versione", 0)) != VERSIONE:
		return false
	var v: Villaggio = p.villaggio
	var rete: ReteStrade = p.rete
	var ris: RisorseNaturali = p.risorse
	var log: Logistica = p.logistica
	var dati: DatiMappa = p.dati
	_carica_natura(d, ris, dati)

	v.caricamento = true
	for n in d.get("nemici", []):
		v.metti_nemico(n[0], Vector2i(int(n[1]), int(n[2])), int(n[3]), int(n[4]))
	v.soldati = int(d.get("soldati", 0))
	if d.has("avversario"):
		p.avversario.tempo = float(d["avversario"][0])
		p.avversario._espansione = float(d["avversario"][1])
		p.avversario._attacco = float(d["avversario"][2])
		p.avversario.attivo = d["avversario"][3]
		if d["avversario"].size() > 4:
			p.avversario.modalita = d["avversario"][4]
			p.avversario.tregua = float(d["avversario"][5])
			p.avversario.guerra_dichiarata = d["avversario"][6]
	# prima gli edifici finiti (allargano i confini), poi i cantieri
	var vecchi := {}                 # id salvato -> Edificio nuovo
	var ordinati: Array = d["edifici"].duplicate()
	ordinati.sort_custom(func(a, b): return a["finito"] and not b["finito"])
	for s in ordinati:
		var e := v.costruisci(s["tipo"], _c(s["casella"]), s["finito"], true)
		if e == null:
			continue
		vecchi[int(s["id"])] = e
		if not s["finito"]:
			e.progresso = s["progresso"]
			e.consegnati = _interi(s["consegnati"])
			e.richiesti = _interi(s["richiesti"])
		e.ingresso = _interi(s["ingresso"])
		e.in_arrivo = _interi(s["in_arrivo"])
		e.prodotti = int(s["prodotti"])
		e.nascita = s["nascita"]
		e.acquisto = s.get("acquisto", "")
		e.guadagno = int(s.get("guadagno", 0))
		e.presidiata = s.get("presidiata", false)
		e.soldati = int(s.get("soldati", 0))
		e.manca_attrezzo = s["manca_attrezzo"]
		e.manca_colono = s["manca_colono"]
	for b in d["bandiere"]:
		var c := _c(b)
		if not rete.bandiere.has(c):
			rete.aggiungi_bandiera(c, b[2])
	for t in d["tratti"]:
		var perc: Array[Vector2i] = []
		for c in t["percorso"]:
			perc.append(_c(c))
		rete.costruisci_strada(perc)
	# chi non aveva il portatore (mancavano i coloni) torna ad aspettarlo
	for t in d["tratti"]:
		if t["portatore"]:
			continue
		var a := _c(t["percorso"][0])
		var b := _c(t["percorso"][-1])
		var tr = rete.tratto_tra(a, b)
		if tr and tr.portatore:
			tr.portatore.queue_free()
			tr.portatore = null

	v.scorte = _interi(d["scorte"])
	if v.scorte.has("monete"):
		# salvataggi vecchi: le monete ora si chiamano ducati
		v.scorte["ducati"] = v.scorte.get("ducati", 0) + v.scorte["monete"]
		v.scorte.erase("monete")
	v.coloni_liberi = int(d["coloni_liberi"])
	log.tempo = d["tempo"]
	p.stagioni.tempo = float(d.get("calendario", 0.0))
	p.stagioni.prepara(p.terreno, ris, p.stagioni.luce, p.stagioni.fiocchi)
	log.storia = d["storia"]
	for m in d["merci"]:
		var dest: Edificio = vecchi.get(int(m[3]))
		if dest:
			log._nuova_merce(m[0], dest, Vector2i(int(m[1]), int(m[2])))
	for s in d["edifici"]:
		var e: Edificio = vecchi.get(int(s["id"]))
		if e and s["lavoratore"]:
			v.metti_lavoratore(e)
	if d.has("missione") and p.missione == null:
		p.avvia_missione(d["missione"][0], int(d["missione"][1]))
	p.indigeni.carica(d.get("indigeni", []))
	var mon: Dictionary = d.get("monumenti", {})
	for o in mon.get("ottenuti", []):
		p.monumenti.sblocca(o[0], true, Vector2i(int(o[1]), int(o[2])))
	p.monumenti.prodotti = _interi(mon.get("prodotti", {}))
	p.monumenti.tempo_senza_perdite = float(mon.get("senza_perdite", 0.0))
	v.caricamento = false
	v._ricalcola_territorio()
	p.camera.position = Vector2(d["camera"][0], d["camera"][1])
	p.camera.zoom = Vector2.ONE * float(d["camera"][2])
	v.scorte_cambiate.emit()
	v.popolazione_cambiata.emit()
	return true


static func _interi(d: Dictionary) -> Dictionary:
	var r := {}
	for k in d:
		r[k] = int(d[k])
	return r


static func _carica_natura(d: Dictionary, ris: RisorseNaturali, dati: DatiMappa) -> void:
	# via gli alberi e i massi messi dal generatore: tornano quelli salvati, dove erano
	for c in ris.alberi:
		for a in ris.alberi[c]:
			(a["sprite"] as Node).free()
		if not ris.ulivi.has(c):
			dati.occupa(c.x, c.y, 0)
	ris.alberi.clear()
	for c in ris.rocce:
		(ris.rocce[c]["sprite"] as Node).free()
		if not ris.ulivi.has(c):
			dati.occupa(c.x, c.y, 0)
	ris.rocce.clear()
	for a in d["alberi"]:
		var c := Vector2i(int(a[0]), int(a[1]))
		var s := Sprites.crea(a[4])
		s.position = Vector2(a[5], a[6])
		ris.oggetti.add_child(s)
		ris.alberi.get_or_add(c, []).append({"sprite": s, "specie": a[2], "crescita": float(a[3]), "prenotato": false})
		dati.occupa(c.x, c.y, DatiMappa.NATURA)
	for r in d["rocce"]:
		var c := Vector2i(int(r[0]), int(r[1]))
		var s := Sprites.crea(r[3])
		s.position = Vector2(r[4], r[5])
		s.scale = Vector2.ONE * lerpf(0.45, 1.0, float(r[2]) / RisorseNaturali.RISERVA_ROCCIA)
		ris.oggetti.add_child(s)
		ris.rocce[c] = {"sprite": s, "riserva": int(r[2]), "prenotata": false}
		dati.occupa(c.x, c.y, DatiMappa.NATURA)
	for k in d["campi"]:
		var c := Vector2i(int(k[0]), int(k[1]))
		ris.semina(c, k[2])
		ris.campi[c]["crescita"] = float(k[3])
		ris._imposta_fase(ris.campi[c])
	for k in d["ceppi"]:
		ris._metti_ceppo(Vector2(k[1], k[2]), k[0], float(k[3]))
	ris.pesci = _interi(_da_chiavi(d["pesci"]))
	ris._ripopola = _da_chiavi(d["ripopola"])
	ris.spada = _interi(_da_chiavi(d["spada"]))
	ris._ripopola_spada = _da_chiavi(d["ripopola_spada"])
	ris._olive_attesa = _da_chiavi(d["olive_attesa"])
	for tipo in d["minerali"]:
		ris.minerali[tipo] = _interi(_da_chiavi(d["minerali"][tipo]))
