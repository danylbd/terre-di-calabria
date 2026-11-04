class_name Villaggio
extends Node
## Regole di costruzione e stato del villaggio del giocatore: scorte, edifici, territorio.

signal scorte_cambiate
signal territorio_cambiato
signal messaggio(testo: String, errore: bool)
signal togli_decori(c: Vector2i)
signal popolazione_cambiata
signal edifici_speciali_cambiati

const T := DatiMappa.Terreno
const RAGGIO_MAGAZZINO := 9.0
const TERRENI_EDIFICABILI := [T.PRATO, T.SECCO, T.TERRA]
const PENDENZA_MAX := {1: 14.0, 2: 12.0, 3: 10.0}
const PENDENZA_MINIERA := 40.0

var dati: DatiMappa
var nome := "Villaggio"
var rete: ReteStrade
var risorse: RisorseNaturali
var logistica: Logistica
var oggetti: Node2D                  # nodo con ordinamento in profondità dove vanno gli edifici
var edifici := {}                    # id -> Edificio
var scorte := {"tronchi": 20, "assi": 24, "pietra": 18,
	"ascia": 3, "piccone": 3, "pala": 2, "falce": 4, "canna": 2, "sega": 2, "martello": 2}
var edifici_speciali_acquistati := {}
var _prossimo_id := 2
var coloni_liberi := 40              # coloni a casa, pronti a essere chiamati al lavoro
var _coloni_disponibili_case := {}   # bandierina dell'abitazione -> coloni liberi che vi aspettano
var ultima_origine_colono := Vector2i(-1, -1)
var in_cammino := 0                  # compatibilità con coloni già in viaggio nei salvataggi
var costruttori := 0                 # coloni usciti a costruire i cantieri (step 36a)
var _richiamo := 0.0
var centri_esterni := []             # territori di altri popoli: [casella, raggio, proprietario]
var nemici := {}                     # id -> Edificio di un altro popolo (torri con i loro difensori)
var soldati := 0                     # soldati di riserva, pronti a raggiungere i forti
var guerra: Guerra
var centri_propri := []             # altri centri del nostro territorio: [casella, raggio, 1] (villaggi indigeni conquistati)
var pionieri: Array[Vector2i] = []  # avamposti fondati dalle case dei pionieri
var vantaggi := {}                   # dai monumenti: "confini" (+raggio), "nascita" e "lavoro" (×tempo), "duelli" (+probabilità)
var caricamento := false             # si sta ricostruendo una partita salvata: niente costi né messaggi

const TEMPO_NASCITA := 40.0          # secondi tra una nascita e l'altra in ogni abitazione
const TEMPO_NASCITA_LUSSO := 20.0


func _init(d: DatiMappa, nodo_oggetti: Node2D) -> void:
	dati = d
	oggetti = nodo_oggetti


func rinomina(nuovo_nome: String) -> void:
	var pulito := nuovo_nome.strip_edges()
	if pulito.is_empty():
		return
	nome = pulito.substr(0, 32)


func puo_fondare_pioniere(c: Vector2i) -> String:
	if not dati.dentro(c.x, c.y):
		return "Fuori dalla mappa"
	if dati.proprietario(c.x, c.y) != 0 or dati.occupante(c.x, c.y) != 0:
		return "Scegli un terreno libero fuori dai confini"
	if dati.tipo(c.x, c.y) in [T.ACQUA, T.NEVE, T.ROCCIA]:
		return "Il pioniere può fondare solo su terreno abitabile"
	var distanza := INF
	for y in dati.altezza:
		for x in dati.larghezza:
			if dati.proprietario(x, y) == 1:
				distanza = minf(distanza, Vector2(c - Vector2i(x, y)).length())
	if distanza > 18.0:
		return "Troppo lontano: resta entro 18 caselle dal villaggio"
	return ""


func fonda_avamposto(c: Vector2i, origine: Edificio) -> bool:
	var perche := puo_fondare_pioniere(c)
	if perche != "":
		messaggio.emit(perche, true)
		return false
	if scorte.get("assi", 0) < 2:
		messaggio.emit("Servono 2 assi per l'accampamento", true)
		return false
	if not prendi_colono():
		messaggio.emit("Manca un colono libero per il pioniere", true)
		return false
	scorte["assi"] -= 2
	costruttori += 1
	pionieri.append(c)
	centri_propri.append([c, 7.0, 1])
	dati.occupa(c.x, c.y, DatiMappa.NATURA)
	var viandante := Colono.new()
	oggetti.add_child(viandante)
	var casa_origine := ultima_origine_colono
	var partenza := edificio_con_bandiera(casa_origine)
	var cammino: Array[Vector2] = []
	if partenza:
		cammino.append(partenza.centro())
		cammino.append_array(rete.percorso_tra_bandiere(casa_origine, origine.bandiera))
	cammino.append(origine.centro())
	cammino.append(Vector2(c) + Vector2(0.5, 0.5))
	viandante.prepara(dati, cammino[0], "portatore_attrezzi")
	viandante.arrivato.connect(func(_c):
		costruttori = maxi(0, costruttori - 1)
		viandante.queue_free()
		restituisci_colono(casa_origine))
	viandante.percorri(cammino)
	_mostra_campo_pioniere(c)
	_ricalcola_territorio()
	scorte_cambiate.emit()
	messaggio.emit("Il pioniere ha fondato un avamposto: i confini si allargano", false)
	return true


func _mostra_campo_pioniere(c: Vector2i) -> void:
	var campo := Node2D.new()
	campo.set_script(load("res://src/mappa/campo_pioniere.gd"))
	campo.position = dati.a_schermo(c.x + 0.5, c.y + 0.5)
	oggetti.add_child(campo)


# ------------------------------------------------------------ verifiche

func motivo_impossibile(tipo: String, c: Vector2i, controlla_costo := false) -> String:
	var info := CatalogoEdifici.dati(tipo)
	if tipo in CatalogoEdifici.EDIFICI_SPECIALI and edifici_speciali_acquistati.get(tipo, 0) <= 0:
		return "Acquista questo edificio all'agorà prima di costruirlo"
	if tipo == "magazzino" and _conta("magazzino") >= magazzini_massimi():
		return "Serve un magazzino ogni 50 coloni"
	var s: int = info["taglia"]
	var montano := _edificio_montano(tipo)
	for y in range(c.y, c.y + s):
		for x in range(c.x, c.x + s):
			if not dati.dentro(x, y):
				return "Fuori dalla mappa"
			if not dati.nel_territorio(x, y):
				return "Fuori dai tuoi confini"
			var terreno := dati.tipo(x, y)
			if terreno in [T.ROCCIA, T.NEVE] and not montano:
				return "Sui monti si costruiscono solo miniere, cave e torri"
			if terreno not in TERRENI_EDIFICABILI and not (montano and terreno in [T.ROCCIA, T.NEVE]):
				return "Terreno non adatto"
			var o := dati.occupante(x, y)
			if o == DatiMappa.NATURA and not (info.has("miniera") and risorse and risorse.solo_massi(Vector2i(x, y))):
				return "Ci sono alberi o rocce"
			if o >= 2:
				return "Posto occupato"
			if rete and (rete.strada.has(Vector2i(x, y)) or rete.bandiere.has(Vector2i(x, y))):
				return "C'è una strada"
	var b := Vector2i(c.x + (s - 1) / 2, c.y + s)
	var vietati := [T.ACQUA, T.NEVE] if info.has("miniera") else ([T.ACQUA] if montano else [T.ACQUA, T.ROCCIA, T.NEVE])
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


func _edificio_montano(tipo: String) -> bool:
	var info := CatalogoEdifici.dati(tipo)
	return tipo == "cava" or info.has("miniera") or info.get("presidio", 0) > 0


func puo_costruire(tipo: String, c: Vector2i) -> bool:
	return motivo_impossibile(tipo, c) == ""


func acquista_edificio_speciale(tipo: String) -> bool:
	if tipo not in CatalogoEdifici.EDIFICI_SPECIALI:
		return false
	var prezzo: int = CatalogoEdifici.dati(tipo)["prezzo_ducati"]
	if scorte.get("ducati", 0) < prezzo:
		messaggio.emit("Servono %d ducati per acquistare %s" % [prezzo, CatalogoEdifici.dati(tipo)["nome"]], true)
		return false
	scorte["ducati"] -= prezzo
	edifici_speciali_acquistati[tipo] = edifici_speciali_acquistati.get(tipo, 0) + 1
	scorte_cambiate.emit()
	edifici_speciali_cambiati.emit()
	messaggio.emit("Acquistato: %s. Ora è disponibile nel menu Speciali" % CatalogoEdifici.dati(tipo)["nome"], false)
	return true


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
	if not gia_finito and not forza and tipo in CatalogoEdifici.EDIFICI_SPECIALI:
		edifici_speciali_acquistati[tipo] -= 1
		edifici_speciali_cambiati.emit()
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
	# La demolizione restituisce metà del costo iniziale, sia per i cantieri sia per gli edifici finiti.
	var recupero := {}
	if recupera:
		var costo: Dictionary = CatalogoEdifici.dati(e.tipo)["costo"]
		for r in costo:
			recupero[r] = int(costo[r] / 2)
	for r in recupero:
		scorte[r] = scorte.get(r, 0) + recupero[r]
	edifici.erase(e.id)
	if e.lavoratore and is_instance_valid(e.lavoratore):
		e.lavoratore.queue_free()
		restituisci_colono()
	if e.costruttore and is_instance_valid(e.costruttore):
		e.costruttore.torna()
	if recupera:
		for r in e.ingresso:
			scorte[r] = scorte.get(r, 0) + e.ingresso[r]
	if e.tipo in CatalogoEdifici.EDIFICI_SPECIALI:
		edifici_speciali_acquistati[e.tipo] = edifici_speciali_acquistati.get(e.tipo, 0) + 1
		edifici_speciali_cambiati.emit()
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
	_ripartisci_coloni_libere()
	ultima_origine_colono = _scegli_casa_libera()
	if ultima_origine_colono != Vector2i(-1, -1):
		_coloni_disponibili_case[ultima_origine_colono] = maxi(0, _coloni_disponibili_case.get(ultima_origine_colono, 0) - 1)
	coloni_liberi -= 1
	popolazione_cambiata.emit()
	return true


func restituisci_colono(origine := Vector2i(-1, -1)) -> void:
	var casa_origine := edificio_con_bandiera(origine)
	if casa_origine == null or CatalogoEdifici.dati(casa_origine.tipo).get("abitanti", 0) <= 0:
		_ripartisci_coloni_libere()
		origine = _scegli_casa_libera()
	coloni_liberi += 1
	if origine == Vector2i(-1, -1):
		var mag := magazzino()
		if mag:
			origine = mag.bandiera
	if origine != Vector2i(-1, -1):
		_coloni_disponibili_case[origine] = _coloni_disponibili_case.get(origine, 0) + 1
	popolazione_cambiata.emit()


func _ripartisci_coloni_libere() -> void:
	for pos in _coloni_disponibili_case.keys():
		var casa: Edificio = edificio_con_bandiera(pos)
		if casa == null or not casa.finito or CatalogoEdifici.dati(casa.tipo).get("abitanti", 0) <= 0:
			_coloni_disponibili_case.erase(pos)
	var presenti := 0
	for n in _coloni_disponibili_case.values():
		presenti += int(n)
	var case := edifici.values().filter(func(e):
		return e.finito and CatalogoEdifici.dati(e.tipo).get("abitanti", 0) > 0)
	case.sort_custom(func(a, b): return a.id < b.id)
	while presenti < coloni_liberi and not case.is_empty():
		var scelta: Edificio = null
		for c in case:
			if _coloni_disponibili_case.get(c.bandiera, 0) < CatalogoEdifici.dati(c.tipo).get("abitanti", 0):
				scelta = c
				break
		if scelta == null:
			break
		_coloni_disponibili_case[scelta.bandiera] = _coloni_disponibili_case.get(scelta.bandiera, 0) + 1
		presenti += 1
	if presenti < coloni_liberi:
		var mag := magazzino()
		if mag:
			_coloni_disponibili_case[mag.bandiera] = _coloni_disponibili_case.get(mag.bandiera, 0) + coloni_liberi - presenti


func _scegli_casa_libera() -> Vector2i:
	var scelta := Vector2i(-1, -1)
	var quanti := 2147483647
	for posizione in _coloni_disponibili_case:
		var liberi: int = _coloni_disponibili_case[posizione]
		if liberi > 0 and liberi < quanti:
			var casa := edificio_con_bandiera(posizione)
			if casa and CatalogoEdifici.dati(casa.tipo).get("abitanti", 0) > 0:
				scelta = posizione
				quanti = liberi
	return scelta


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
	return coloni_liberi + in_cammino + costruttori + lavoratori() + (rete.portatori() if rete else 0) + soldati + nei_forti \
		+ (guerra.in_marcia() if guerra else 0)


func magazzini_massimi() -> int:
	return maxi(1, ceili(float(popolazione()) / 50.0))


func capienza_magazzini() -> int:
	return _conta("magazzino") * 200


func merci_in_scorta() -> int:
	var totale := 0
	for tipo in scorte:
		if tipo != "ducati":
			totale += maxi(0, int(scorte[tipo]))
	return totale


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


## Un nuovo colono resta nella sua abitazione e si aggiunge alla riserva libera del villaggio.
func _nasce_colono(casa: Edificio) -> void:
	coloni_liberi += 1
	_coloni_disponibili_case[casa.bandiera] = _coloni_disponibili_case.get(casa.bandiera, 0) + 1
	popolazione_cambiata.emit()


func edificio_in(c: Vector2i) -> Edificio:
	var o := dati.occupante(c.x, c.y)
	return edifici.get(o) if o >= 2 else null


func edificio_con_bandiera(c: Vector2i) -> Edificio:
	for e in edifici.values():
		if e.bandiera == c:
			return e
	return null


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
	centri.append_array(centri_propri)
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
		_manda_costruttore(e)


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
	if not prendi_colono():
		e.manca_colono = true
		return
	var partenza: Vector2i = ultima_origine_colono if ultima_origine_colono != Vector2i(-1, -1) else mag.bandiera
	var punti := rete.percorso_tra_bandiere(partenza, e.bandiera)
	if punti.is_empty():
		restituisci_colono(partenza)
		return
	var casa := edificio_con_bandiera(partenza)
	if casa:
		punti.push_front(casa.centro())
	e.manca_colono = false
	if att != "":
		scorte[att] -= 1
		e.manca_attrezzo = false
		scorte_cambiate.emit()
	var l := Lavoratore.new()
	oggetti.add_child(l)
	l.avvia(e, risorse, logistica, rete, punti)
	e.lavoratore = l


## Un cantiere collegato riceve il suo costruttore, che parte da casa lungo le strade (step 36a).
func _manda_costruttore(e: Edificio) -> void:
	if caricamento or e.finito or not e.collegato or e.costruttore != null:
		return
	var mag := magazzino()
	if mag == null or mag == e:
		return
	if coloni_liberi <= 0:
		e.manca_colono = true
		return
	if not prendi_colono():
		return
	var partenza: Vector2i = ultima_origine_colono if ultima_origine_colono != Vector2i(-1, -1) else mag.bandiera
	var punti := rete.percorso_tra_bandiere(partenza, e.bandiera)
	if punti.is_empty():
		restituisci_colono(partenza)
		return
	var casa := edificio_con_bandiera(partenza)
	if casa:
		punti.push_front(casa.centro())
	e.manca_colono = false
	costruttori += 1
	var c := Costruttore.new()
	oggetti.add_child(c)
	c.avvia(self, e, rete, punti, partenza)
	e.costruttore = c


func costruttore_tornato(c: Costruttore) -> void:
	costruttori -= 1
	restituisci_colono(c.casa_origine)


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
