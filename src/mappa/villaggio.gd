class_name Villaggio
extends Node
## Regole di costruzione e stato del villaggio del giocatore: scorte, edifici, territorio.

signal scorte_cambiate
signal territorio_cambiato
signal messaggio(testo: String, errore: bool)
signal togli_decori(c: Vector2i)
signal popolazione_cambiata

const T := DatiMappa.Terreno
const RAGGIO_MAGAZZINO := 9.0
const TERRENI_EDIFICABILI := [T.PRATO, T.SECCO, T.TERRA]
const PENDENZA_MAX := {1: 14.0, 2: 12.0, 3: 10.0}
const PENDENZA_MINIERA := 40.0

var dati: DatiMappa
var rete: ReteStrade
var risorse: RisorseNaturali
var logistica: Logistica
var oggetti: Node2D                  # nodo con ordinamento in profondità dove vanno gli edifici
var edifici := {}                    # id -> Edificio
var scorte := {"tronchi": 20, "assi": 24, "pietra": 18,
	"ascia": 3, "piccone": 3, "pala": 2, "falce": 4, "canna": 2, "sega": 2, "martello": 2}
var _prossimo_id := 2
var coloni_liberi := 40              # coloni in magazzino, pronti a fare i portatori o i lavoratori
var in_cammino := 0                  # coloni appena nati che vanno verso il magazzino
var _richiamo := 0.0
var centri_esterni := []             # territori di altri popoli: [casella, raggio, proprietario]
var nemici := {}                     # id -> Edificio di un altro popolo (torri con i loro difensori)
var soldati := 0                     # soldati di riserva, pronti a raggiungere i forti
var guerra: Guerra
var vantaggi := {}                   # dai monumenti: "confini" (+raggio), "nascita" e "lavoro" (×tempo), "duelli" (+probabilità)
var caricamento := false             # si sta ricostruendo una partita salvata: niente costi né messaggi

const TEMPO_NASCITA := 40.0          # secondi tra una nascita e l'altra in ogni abitazione
const TEMPO_NASCITA_LUSSO := 20.0


func _init(d: DatiMappa, nodo_oggetti: Node2D) -> void:
	dati = d
	oggetti = nodo_oggetti


# ------------------------------------------------------------ verifiche

func motivo_impossibile(tipo: String, c: Vector2i, controlla_costo := false) -> String:
	var info := CatalogoEdifici.dati(tipo)
	var s: int = info["taglia"]
	for y in range(c.y, c.y + s):
		for x in range(c.x, c.x + s):
			if not dati.dentro(x, y):
				return "Fuori dalla mappa"
			if not dati.nel_territorio(x, y):
				return "Fuori dai tuoi confini"
			if dati.tipo(x, y) not in TERRENI_EDIFICABILI and not (info.has("miniera") and dati.tipo(x, y) == T.ROCCIA):
				return "Terreno non adatto"
			var o := dati.occupante(x, y)
			if o == DatiMappa.NATURA and not (info.has("miniera") and risorse and risorse.solo_massi(Vector2i(x, y))):
				return "Ci sono alberi o rocce"
			if o >= 2:
				return "Posto occupato"
			if rete and (rete.strada.has(Vector2i(x, y)) or rete.bandiere.has(Vector2i(x, y))):
				return "C'è una strada"
	var b := Vector2i(c.x + (s - 1) / 2, c.y + s)
	var vietati := [T.ACQUA, T.NEVE] if info.has("miniera") else [T.ACQUA, T.ROCCIA, T.NEVE]
	if not dati.nel_territorio(b.x, b.y) or dati.tipo(b.x, b.y) in vietati or dati.occupante(b.x, b.y) != 0:
		return "Serve spazio davanti alla porta per la bandierina"
	if rete and not rete.bandiere.has(b) and rete.motivo_no_bandiera(b) != "":
		return "Serve spazio davanti alla porta per la bandierina"
	var qmin := INF
	var qmax := -INF
	for j in range(c.y, c.y + s + 1):
		for i in range(c.x, c.x + s + 1):
			var q := dati.quota_vertice(i, j)
			qmin = minf(qmin, q)
			qmax = maxf(qmax, q)
	if qmax - qmin > (PENDENZA_MINIERA if info.has("miniera") else PENDENZA_MAX[s]):
		return "Terreno troppo in pendenza"
	if info.has("miniera") and risorse and risorse.minerale_vicino(Vector2i(c.x + s / 2, c.y + s / 2), info["miniera"]) <= 0:
		return "Qui sotto non c'è %s: cerca la roccia della montagna" % CatalogoEdifici.NOMI_RISORSE[info["miniera"]].to_lower()
	if info.has("vicino_mare") and not _mare_entro(b, info["vicino_mare"]):
		return "Va costruita vicino al mare"
	if controlla_costo:
		var costo: Dictionary = info["costo"]
		for r in costo:
			if scorte.get(r, 0) < costo[r]:
				return "Mancano %s" % CatalogoEdifici.NOMI_RISORSE[r].to_lower()
	return ""


func puo_costruire(tipo: String, c: Vector2i) -> bool:
	return motivo_impossibile(tipo, c) == ""


# ------------------------------------------------------------ azioni

func costruisci(tipo: String, c: Vector2i, gia_finito := false, forza := false) -> Edificio:
	if not gia_finito and not forza:
		var perche := motivo_impossibile(tipo, c)
		if perche != "":
			messaggio.emit(perche, true)
			return null
	var e := Edificio.new()
	e.dati_mappa = dati
	e.villaggio = self
	e.prepara(_prossimo_id, tipo, c, gia_finito)
	_prossimo_id += 1
	e.position = dati.a_schermo(e.centro().x, e.centro().y)
	oggetti.add_child(e)
	edifici[e.id] = e
	for y in range(c.y, c.y + e.taglia):
		for x in range(c.x, c.x + e.taglia):
			if CatalogoEdifici.dati(tipo).has("miniera") and risorse and risorse.solo_massi(Vector2i(x, y)):
				risorse.togli_massi(Vector2i(x, y))
			dati.occupa(x, y, e.id)
			togli_decori.emit(Vector2i(x, y))
	e.completato.connect(_on_completato)
	if gia_finito and CatalogoEdifici.dati(tipo).has("presidio") and not caricamento:
		# un forte già finito (inizio partita, prove) ha già la sua guardia dentro
		e.presidiata = true
		metti_lavoratore(e)
	if gia_finito:
		_ricalcola_territorio()
	rete.aggiungi_bandiera(e.bandiera, true)
	rete.segna_ostacoli_vecchi()
	if not gia_finito and not caricamento:
		if rete.collegata(e.bandiera):
			messaggio.emit("Cantiere aperto: %s — i portatori consegneranno %s" % [CatalogoEdifici.dati(tipo)["nome"], CatalogoEdifici.testo_costo(tipo)], false)
		else:
			messaggio.emit("Collega la bandierina del cantiere con una strada", false)
	_aggiorna_collegamenti()
	return e


func demolisci(e: Edificio, recupera := true) -> void:
	if e.tipo == "magazzino" and _conta("magazzino") <= 1:
		messaggio.emit("Non puoi demolire l'ultimo magazzino", true)
		return
	for y in range(e.casella.y, e.casella.y + e.taglia):
		for x in range(e.casella.x, e.casella.x + e.taglia):
			dati.occupa(x, y, 0)
	# materiali recuperati: tutti quelli già arrivati al cantiere, metà del costo se l'edificio era finito
	var recupero: Dictionary = e.consegnati if recupera else {}
	if e.finito and recupera:
		recupero = {}
		var costo: Dictionary = CatalogoEdifici.dati(e.tipo)["costo"]
		for r in costo:
			recupero[r] = int(costo[r] / 2)
	for r in recupero:
		scorte[r] = scorte.get(r, 0) + recupero[r]
	edifici.erase(e.id)
	if e.lavoratore and is_instance_valid(e.lavoratore):
		e.lavoratore.queue_free()
		restituisci_colono()
	if recupera:
		for r in e.ingresso:
			scorte[r] = scorte.get(r, 0) + e.ingresso[r]
	rete.libera_protezione(e.bandiera)
	rete.segna_ostacoli_vecchi()
	e.queue_free()
	rete._ricalcola()
	scorte_cambiate.emit()
	_ricalcola_territorio()
	if recupera:
		messaggio.emit("Demolito: %s" % CatalogoEdifici.dati(e.tipo)["nome"].to_lower(), false)


# ------------------------------------------------------------ popolazione

func prendi_colono() -> bool:
	if caricamento:
		return true
	if coloni_liberi <= 0:
		return false
	coloni_liberi -= 1
	popolazione_cambiata.emit()
	return true


func restituisci_colono() -> void:
	coloni_liberi += 1
	popolazione_cambiata.emit()


func lavoratori() -> int:
	var n := 0
	for e in edifici.values():
		if e.lavoratore and is_instance_valid(e.lavoratore):
			n += 1
	return n


func popolazione() -> int:
	var nei_forti := 0
	for e in edifici.values():
		nei_forti += e.soldati
	return coloni_liberi + in_cammino + lavoratori() + (rete.portatori() if rete else 0) + soldati + nei_forti \
		+ (guerra.in_marcia() if guerra else 0)


func magazzino() -> Edificio:
	for m in edifici.values():
		if m.tipo == "magazzino" and m.finito:
			return m
	return null


func nemico_in(c: Vector2i) -> Edificio:
	return nemici.get(dati.occupante(c.x, c.y))


## Un altro popolo costruisce una torre già finita, con i suoi difensori.
func metti_nemico(tipo: String, c: Vector2i, chi: int, difensori: int) -> Edificio:
	var e := Edificio.new()
	e.dati_mappa = dati
	e.villaggio = self
	e.proprietario = chi
	e.prepara(_prossimo_id, tipo, c, true)
	_prossimo_id += 1
	e.position = dati.a_schermo(e.centro().x, e.centro().y)
	e.soldati = difensori
	oggetti.add_child(e)
	nemici[e.id] = e
	for y in range(c.y, c.y + e.taglia):
		for x in range(c.x, c.x + e.taglia):
			dati.occupa(x, y, e.id)
			togli_decori.emit(Vector2i(x, y))
	_ricalcola_territorio()
	return e


func rimuovi_nemico(e: Edificio) -> void:
	nemici.erase(e.id)
	for y in range(e.casella.y, e.casella.y + e.taglia):
		for x in range(e.casella.x, e.casella.x + e.taglia):
			dati.occupa(x, y, 0)
	e.queue_free()
	_ricalcola_territorio()


## Quanti coloni il villaggio può ospitare: le abitazioni e i magazzini finiti.
func capacita() -> int:
	var n := 0
	for e in edifici.values():
		if e.finito:
			n += CatalogoEdifici.dati(e.tipo).get("abitanti", 0)
	return n


func _process(delta: float) -> void:
	for e in edifici.values():
		if e.finito and e.tipo == "casa_greca":
			_cresci(e, delta)
	# chi aspettava un colono (strade senza portatore, edifici senza lavoratore) riprova ogni tanto
	_richiamo -= delta
	if _richiamo <= 0.0:
		_richiamo = 1.5
		if coloni_liberi > 0 and rete:
			rete.manda_portatori_mancanti()
			for e in edifici.values():
				if e.manca_colono:
					_chiama_lavoratore(e)


func _cresci(casa: Edificio, delta: float) -> void:
	if popolazione() >= capacita() or not casa.collegato:
		casa.nascita = 0.0
		return
	if casa.nascita <= 0.0:
		casa.nascita = TEMPO_NASCITA * vantaggi.get("nascita", 1.0)
		for l in CatalogoEdifici.LUSSO:
			if scorte.get(l, 0) > 0:
				scorte[l] -= 1
				casa.nascita = TEMPO_NASCITA_LUSSO * vantaggi.get("nascita", 1.0)
				scorte_cambiate.emit()
				break
		return
	casa.nascita -= delta
	if casa.nascita <= 0.0:
		_nasce_colono(casa)


## Un nuovo colono esce dalla casa e va a piedi lungo le strade fino al magazzino.
func _nasce_colono(casa: Edificio) -> void:
	var mag: Edificio = null
	for m in edifici.values():
		if m.tipo == "magazzino" and m.finito:
			mag = m
			break
	if mag == null:
		return
	var punti: Array[Vector2] = [casa.centro()]
	punti.append_array(rete.percorso_tra_bandiere(casa.bandiera, mag.bandiera))
	punti.append(mag.centro())
	var c := Colono.new()
	oggetti.add_child(c)
	c.prepara(dati, punti[0])
	c.arrivato.connect(func(_c):
		in_cammino -= 1
		c.queue_free()
		restituisci_colono())
	c.percorri(punti)
	in_cammino += 1
	popolazione_cambiata.emit()


func edificio_in(c: Vector2i) -> Edificio:
	var o := dati.occupante(c.x, c.y)
	return edifici.get(o) if o >= 2 else null


func _on_completato(e: Edificio) -> void:
	if CatalogoEdifici.dati(e.tipo).has("presidio"):
		messaggio.emit("%s completato: arriva una guardia a presidiarlo" % CatalogoEdifici.dati(e.tipo)["nome"], false)
	else:
		messaggio.emit("%s completato" % CatalogoEdifici.dati(e.tipo)["nome"], false)
	_chiama_lavoratore(e)
	if CatalogoEdifici.dati(e.tipo).has("territorio") or e.tipo == "magazzino":
		_ricalcola_territorio()
	if e.tipo == "magazzino":
		rete.aggiungi_bandiera(e.bandiera, true)
		rete._ricalcola()


func _ricalcola_territorio() -> void:
	var centri := []
	for e in edifici.values():
		if not e.finito:
			continue
		if e.tipo == "magazzino":
			centri.append([Vector2i(e.centro()), RAGGIO_MAGAZZINO + vantaggi.get("confini", 0), 1])
		elif CatalogoEdifici.dati(e.tipo).has("territorio") and e.presidiata:
			centri.append([Vector2i(e.centro()), float(CatalogoEdifici.dati(e.tipo)["territorio"]) + vantaggi.get("confini", 0) + Popoli.confini(), 1])
	for n in nemici.values():
		centri.append([Vector2i(n.centro()), float(CatalogoEdifici.dati(n.tipo)["territorio"]), n.proprietario])
	centri.append_array(centri_esterni)
	dati.calcola_territorio(centri)
	if not caricamento:
		_perdi_fuori_confine()
	if rete:
		rete.segna_ostacoli_vecchi()
	territorio_cambiato.emit()


## Il confine si è ritirato: gli edifici rimasti fuori bruciano, strade e bandierine fuori spariscono.
func _perdi_fuori_confine() -> void:
	var persi := []
	for e in edifici.values():
		for y in range(e.casella.y, e.casella.y + e.taglia):
			for x in range(e.casella.x, e.casella.x + e.taglia):
				if not dati.nel_territorio(x, y) and not e in persi:
					persi.append(e)
	for e in persi:
		messaggio.emit("Fuori dai confini, è andato a fuoco: %s" % CatalogoEdifici.dati(e.tipo)["nome"].to_lower(), true)
		demolisci(e, false)
	if rete:
		for c in rete.bandiere.keys():
			if not dati.nel_territorio(c.x, c.y):
				rete.libera_protezione(c)
				rete.rimuovi_bandiera(c)
		for c in rete.strada.keys():
			if rete.strada.has(c) and not dati.nel_territorio(c.x, c.y):
				rete.rimuovi_strada_in(c)


func _aggiorna_collegamenti() -> void:
	for e in edifici.values():
		e.collegato = e.tipo == "magazzino" or rete.collegata(e.bandiera)
		_chiama_lavoratore(e)


## Un edificio di produzione finito e collegato riceve il suo lavoratore, che arriva dal magazzino
## e prende con sé l'attrezzo del mestiere (se manca, aspetta che il fabbro lo forgi).
func _chiama_lavoratore(e: Edificio) -> void:
	if caricamento or not e.finito or not e.collegato or e.lavoratore != null:
		return
	if not CatalogoEdifici.dati(e.tipo).has("lavoratore"):
		return
	var att: String = CatalogoEdifici.dati(e.tipo).get("attrezzo", "")
	if att != "" and scorte.get(att, 0) <= 0:
		if not e.manca_attrezzo:
			e.manca_attrezzo = true
			messaggio.emit("%s: manca %s in magazzino. Il fabbro può forgiarlo." % [CatalogoEdifici.dati(e.tipo)["nome"],
				CatalogoEdifici.ATTREZZO_UNO[att]], true)
		return
	var mag: Edificio = null
	for m in edifici.values():
		if m.tipo == "magazzino" and m.finito:
			mag = m
			break
	if mag == null:
		return
	var punti := rete.percorso_tra_bandiere(mag.bandiera, e.bandiera)
	if punti.is_empty():
		return
	if not prendi_colono():
		e.manca_colono = true
		return
	e.manca_colono = false
	if att != "":
		scorte[att] -= 1
		e.manca_attrezzo = false
		scorte_cambiate.emit()
	var l := Lavoratore.new()
	oggetti.add_child(l)
	l.avvia(e, risorse, logistica, rete, punti)
	e.lavoratore = l


func _mare_entro(c: Vector2i, raggio: int) -> bool:
	for y in range(c.y - raggio, c.y + raggio + 1):
		for x in range(c.x - raggio, c.x + raggio + 1):
			if dati.dentro(x, y) and dati.tipo(x, y) == T.ACQUA and Vector2(Vector2i(x, y) - c).length() <= raggio:
				return true
	return false


## Le scorte sono cambiate (per esempio il fabbro ha forgiato un attrezzo): chi aspettava può partire.
func richiama_lavoratori() -> void:
	for e in edifici.values():
		if e.manca_attrezzo:
			_chiama_lavoratore(e)


## Una guardia è entrata nel forte: i confini si allargano.
func presidia(e: Edificio) -> void:
	if e.presidiata:
		return
	e.presidiata = true
	messaggio.emit("%s presidiato: i confini si allargano" % CatalogoEdifici.dati(e.tipo)["nome"], false)
	_ricalcola_territorio()


## Partita caricata: il lavoratore è già dentro il suo edificio (coloni e attrezzi sono già contati).
func metti_lavoratore(e: Edificio) -> void:
	if e.lavoratore != null:
		return
	var l := Lavoratore.new()
	oggetti.add_child(l)
	var qui: Array[Vector2] = [e.centro()]
	l.avvia(e, risorse, logistica, rete, qui)
	e.lavoratore = l


## La caserma arruola: un colono libero diventa un soldato di riserva.
func arruola() -> void:
	soldati += 1
	popolazione_cambiata.emit()


func _conta(tipo: String) -> int:
	var n := 0
	for e in edifici.values():
		if e.tipo == tipo:
			n += 1
	return n
