class_name Logistica
extends Node
## Fa viaggiare le merci: i cantieri chiedono materiali, il magazzino li fa uscire alla sua
## bandierina, e ogni merce passa di bandierina in bandierina, portata dal portatore di ogni tratto.

signal scorte_cambiate
signal prodotta(tipo: String)

const INTERVALLO_USCITA := 0.7      # secondi tra un'uscita e l'altra da un magazzino
const MAX_PER_BANDIERA := 8
const SCORTA_MINIMA := 6            # chi produce senza materie prime (il pozzo) si ferma oltre questa scorta
const SCORTA_MASSIMA := 12          # chi trasforma (carbonaia, mulino...) si ferma oltre questa, se nessuno ne chiede
## merci che servono sempre: i ducati (all'agorà si compra con quelli) e le assi (per costruire)
const SEMPRE_UTILI := ["ducati", "assi"]

var dati: DatiMappa
var villaggio: Villaggio
var rete: ReteStrade
var oggetti: Node2D
var merci: Array[Merce] = []
var _attesa_uscita := {}            # id magazzino -> secondi alla prossima uscita
var tempo := 0.0                    # secondi di gioco trascorsi
var storia: Array = []              # [tempo, merce] di ogni merce prodotta negli ultimi minuti
const DURATA_STORIA := 300.0


func prepara(d: DatiMappa, v: Villaggio, r: ReteStrade, nodo_oggetti: Node2D) -> void:
	dati = d
	villaggio = v
	rete = r
	oggetti = nodo_oggetti
	rete.portatore_nuovo.connect(func(p: Portatore): p.merce_posata.connect(_on_posata))
	rete.merce_rilasciata.connect(func(m: Merce): _rimetti_a_terra(m))
	rete.cambiata.connect(_controlla_destinazioni)


func _process(delta: float) -> void:
	tempo += delta
	while storia.size() > 0 and storia[0][0] < tempo - DURATA_STORIA:
		storia.pop_front()
	_fai_uscire(delta)
	_assegna_trasporti()


# ------------------------------------------------------------ uscita dal magazzino

func _fai_uscire(delta: float) -> void:
	for mag in _magazzini():
		var t: float = _attesa_uscita.get(mag.id, 0.0) - delta
		_attesa_uscita[mag.id] = t
		if t > 0.0 or _merci_in(mag.bandiera) >= MAX_PER_BANDIERA:
			continue
		var richiesta := _prossima_richiesta(mag)
		if richiesta.is_empty():
			continue
		var e: Edificio = richiesta[0]
		var tipo: String = richiesta[1]
		villaggio.scorte[tipo] -= 1
		if e.finito:
			e.in_arrivo[tipo] = e.in_arrivo.get(tipo, 0) + 1
		else:
			e.richiesti[tipo] = e.richiesti.get(tipo, 0) + 1
		_nuova_merce(tipo, e, mag.bandiera)
		_attesa_uscita[mag.id] = INTERVALLO_USCITA
		scorte_cambiate.emit()


## Il cantiere collegato più vecchio che aspetta ancora un materiale disponibile in magazzino.
func _prossima_richiesta(mag: Edificio) -> Array:
	var cantieri := villaggio.edifici.values().filter(func(e): return not e.finito and e.collegato)
	cantieri.sort_custom(func(a, b):
		if a.priorita_materiali != b.priorita_materiali:
			return a.priorita_materiali > b.priorita_materiali
		return a.id < b.id)
	for e in cantieri:
		for tipo in e.fabbisogno:
			var mancano: int = e.fabbisogno[tipo] - e.richiesti.get(tipo, 0)
			if mancano > 0 and villaggio.scorte.get(tipo, 0) > 0:
				if rete.prossimo_salto(mag.bandiera, e.bandiera) != Vector2i(-1, -1) or mag.bandiera == e.bandiera:
					return [e, tipo]
	for e in villaggio.edifici.values():
		if not e.finito or not e.collegato:
			continue
		var tipi := CatalogoEdifici.merci_in_ingresso(e.tipo)
		if e.tipo == "agora":
			# L'agorà riceve a rotazione le merci meno presenti: una produzione continua di legna
			# non deve impedire al mercato di vendere anche olio, vino, stoffa o altri prodotti.
			tipi.sort_custom(func(a, b):
				var qa: int = e.ingresso.get(a, 0) + e.in_arrivo.get(a, 0)
				var qb: int = e.ingresso.get(b, 0) + e.in_arrivo.get(b, 0)
				if qa != qb:
					return qa < qb
				return str(a) < str(b))
		for tipo in tipi:
			if _spazio_ingresso(e, tipo) > 0 and villaggio.scorte.get(tipo, 0) > 0:
				if rete.prossimo_salto(mag.bandiera, e.bandiera) != Vector2i(-1, -1):
					return [e, tipo]
	return []


func _spazio_ingresso(e: Edificio, tipo: String) -> int:
	var cap := CatalogoEdifici.capacita(e.tipo, tipo)
	var g := CatalogoEdifici.gruppo(e.tipo)
	if cap > 0 and not g.is_empty() and tipo in g[0]:
		# il gruppo "una qualsiasi" (cibo dei minatori, merci dell'agorà): posto per quello che manca in tutto
		var tot := 0
		for c in g[0]:
			tot += e.ingresso.get(c, 0) + e.in_arrivo.get(c, 0)
		return mini(cap - e.ingresso.get(tipo, 0) - e.in_arrivo.get(tipo, 0), g[1] - tot)
	return cap - e.ingresso.get(tipo, 0) - e.in_arrivo.get(tipo, 0)


# ------------------------------------------------------------ produzione

## Un lavoratore ha prodotto una merce: la posa alla bandierina del suo edificio e le trova
## una destinazione (prima chi la usa per lavorare, altrimenti il magazzino).
func produci(tipo: String, da: Edificio) -> void:
	if tipo == "":
		return
	if merci_in_uscita(da) >= 50:
		return
	da.prodotti += 1
	storia.append([tempo, tipo])
	prodotta.emit(tipo)
	var dest := _destinazione_per(tipo, da.bandiera)
	if dest != null and dest.tipo != "magazzino":
		dest.in_arrivo[tipo] = dest.in_arrivo.get(tipo, 0) + 1
	var m := _nuova_merce(tipo, dest if dest else da, da.bandiera)
	m.origine = da.id
	m.locale = dest == null
	_disponi(da.bandiera)


func puo_produrre(da: Edificio) -> bool:
	if not da.produzione_attiva:
		return false
	var prodotti := CatalogoEdifici.prodotti(da.tipo)
	if prodotti.is_empty():
		return true
	var tipo: String = prodotti[da.prodotti % prodotti.size()]
	return merci_in_uscita(da) < 50 or _destinazione_per(tipo, da.bandiera) != null


## Quante merci di ogni tipo sono state prodotte negli ultimi minuti.
func produzione_recente() -> Dictionary:
	var r := {}
	for voce in storia:
		r[voce[1]] = r.get(voce[1], 0) + 1
	return r


## Quale attrezzo deve forgiare il fabbro: prima quello che manca a un edificio in attesa,
## poi quello con meno scorte se ce ne sono meno di 2; "" se non serve niente.
func attrezzo_da_fare() -> String:
	for e in villaggio.edifici.values():
		var att: String = CatalogoEdifici.dati(e.tipo).get("attrezzo", "")
		if att != "" and e.finito and e.lavoratore == null and villaggio.scorte.get(att, 0) <= 0:
			return att
	var scelto := ""
	for att in CatalogoEdifici.ATTREZZI:
		if villaggio.scorte.get(att, 0) < 2 and (scelto == "" or villaggio.scorte.get(att, 0) < villaggio.scorte.get(scelto, 0)):
			scelto = att
	return scelto


## Serve ancora questa merce? Sì se un edificio ha posto per riceverla o se in magazzino ce n'è meno della soglia.
func serve(tipo: String, soglia := SCORTA_MINIMA) -> bool:
	if tipo in SEMPRE_UTILI:
		return true
	if villaggio.scorte.get(tipo, 0) < soglia:
		return true
	for e in villaggio.edifici.values():
		if e.finito and e.collegato and _spazio_ingresso(e, tipo) > villaggio.scorte.get(tipo, 0):
			return true
	return false


func _destinazione_per(tipo: String, da: Vector2i) -> Edificio:
	var migliore: Edificio = null
	for e in villaggio.edifici.values():
		if e.finito and e.collegato and _spazio_ingresso(e, tipo) > 0 and (rete.prossimo_salto(da, e.bandiera).x >= 0):
			if migliore == null or Vector2(e.bandiera - da).length() < Vector2(migliore.bandiera - da).length():
				migliore = e
	if migliore:
		return migliore
	for e in _magazzini():
		if spazio_magazzino() > 0 and (rete.prossimo_salto(da, e.bandiera).x >= 0 or e.bandiera == da):
			if migliore == null or Vector2(e.bandiera - da).length() < Vector2(migliore.bandiera - da).length():
				migliore = e
	return migliore


func spazio_magazzino(escludi: Merce = null) -> int:
	var limite: int = villaggio.capienza_magazzini()
	if limite <= 0:
		return 0
	var occupati := villaggio.merci_in_scorta()
	for m in merci:
		if m != escludi and not m.locale and is_instance_valid(m.destinazione) and m.destinazione.tipo == "magazzino":
			occupati += 1
	return maxi(0, limite - occupati)


## Merci prodotte da questo edificio che aspettano ancora alla sua bandierina (non quelle di passaggio).
func merci_in_uscita(e: Edificio) -> int:
	var n := 0
	for m in merci:
		if m.origine == e.id and m.bandiera == e.bandiera and not m.in_spalla:
			n += 1
	return n


# ------------------------------------------------------------ viaggio

var _da_consegnare: Array[Merce] = []


func _assegna_trasporti() -> void:
	_da_consegnare.clear()
	for m in merci:
		if m.prenotata or m.in_spalla:
			continue
		if m.locale:
			var destinazione := _destinazione_per(m.tipo, m.bandiera)
			if destinazione == null:
				continue
			m.destinazione = destinazione
			m.locale = false
			if destinazione.tipo != "magazzino":
				destinazione.in_arrivo[m.tipo] = destinazione.in_arrivo.get(m.tipo, 0) + 1
		var dest := m.destinazione.bandiera
		if m.bandiera == dest:
			_da_consegnare.append(m)
			continue
		var prossima := rete.prossimo_salto(m.bandiera, dest)
		if prossima.x < 0:
			continue
		if _merci_in(prossima) >= MAX_PER_BANDIERA and prossima != dest:
			continue
		var t = rete.tratto_tra(m.bandiera, prossima)
		if t and t.portatore and t.portatore.puo_prendere(m.bandiera):
			t.portatore.trasporta(m, m.bandiera, prossima)
	for m in _da_consegnare:
		_consegna(m)


func _on_posata(m: Merce, dove: Vector2i) -> void:
	if not is_instance_valid(m.destinazione) or dove != m.destinazione.bandiera:
		_disponi(dove)
		_disponi_tutte_partenze()
		return
	_consegna(m)


func _consegna(m: Merce) -> void:
	var e := m.destinazione
	merci.erase(m)
	m.sprite.queue_free()
	if e.tipo == "magazzino" and e.finito:
		if spazio_magazzino(m) > 0:
			villaggio.scorte[m.tipo] = villaggio.scorte.get(m.tipo, 0) + 1
			scorte_cambiate.emit()
	elif e.finito:
		e.in_arrivo[m.tipo] = maxi(0, e.in_arrivo.get(m.tipo, 0) - 1)
		e.ingresso[m.tipo] = e.ingresso.get(m.tipo, 0) + 1
		if e.tipo == "agora":
			e.vendite_in_coda.append(m.tipo)
	else:
		e.consegnati[m.tipo] = e.consegnati.get(m.tipo, 0) + 1
	_disponi(m.bandiera)


func _nuova_merce(tipo: String, dest: Edificio, dove: Vector2i) -> Merce:
	var m := Merce.new(tipo, dest, dove)
	oggetti.add_child(m.sprite)
	merci.append(m)
	_disponi(dove)
	return m


func _rimetti_a_terra(m: Merce) -> void:
	m.sprite.visible = true
	_disponi(m.bandiera)


## Edifici demoliti o strade tolte: le merci senza più una destinazione valida tornano al magazzino.
func _controlla_destinazioni() -> void:
	var mags := _magazzini()
	for m in merci:
		if not is_instance_valid(m.destinazione) or m.destinazione.is_queued_for_deletion():
			if mags.size() > 0:
				m.destinazione = mags[0]


# ------------------------------------------------------------ merci posate vicino alle bandierine

func _disponi(f: Vector2i) -> void:
	var k := 0
	for m in merci:
		if m.bandiera == f and not m.in_spalla:
			# Griglia compatta 10×5: fino a 50 merci in attesa senza sovrapporsi.
			var o := Vector2(-0.38 + float(k % 10) * 0.085, -0.25 + float(k / 10) * 0.11)
			m.sprite.position = dati.a_schermo(f.x + 0.5 + o.x, f.y + 0.5 + o.y)
			m.sprite.visible = true
			k += 1


func _disponi_tutte_partenze() -> void:
	var viste := {}
	for m in merci:
		if not viste.has(m.bandiera):
			viste[m.bandiera] = true
			_disponi(m.bandiera)


func _merci_in(f: Vector2i) -> int:
	var n := 0
	for m in merci:
		if m.bandiera == f and not m.in_spalla:
			n += 1
	return n


func _magazzini() -> Array:
	return villaggio.edifici.values().filter(func(e): return e.tipo == "magazzino" and e.finito)
