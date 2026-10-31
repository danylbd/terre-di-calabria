class_name Logistica
extends Node
## Fa viaggiare le merci: i cantieri chiedono materiali, il magazzino li fa uscire alla sua
## bandierina, e ogni merce passa di bandierina in bandierina, portata dal portatore di ogni tratto.

signal scorte_cambiate

const INTERVALLO_USCITA := 0.7      # secondi tra un'uscita e l'altra da un magazzino
const MAX_PER_BANDIERA := 8

var dati: DatiMappa
var villaggio: Villaggio
var rete: ReteStrade
var oggetti: Node2D
var merci: Array[Merce] = []
var _attesa_uscita := {}            # id magazzino -> secondi alla prossima uscita


func prepara(d: DatiMappa, v: Villaggio, r: ReteStrade, nodo_oggetti: Node2D) -> void:
	dati = d
	villaggio = v
	rete = r
	oggetti = nodo_oggetti
	rete.portatore_nuovo.connect(func(p: Portatore): p.merce_posata.connect(_on_posata))
	rete.merce_rilasciata.connect(func(m: Merce): _rimetti_a_terra(m))
	rete.cambiata.connect(_controlla_destinazioni)


func _process(delta: float) -> void:
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
	cantieri.sort_custom(func(a, b): return a.id < b.id)
	for e in cantieri:
		for tipo in e.fabbisogno:
			var mancano: int = e.fabbisogno[tipo] - e.richiesti.get(tipo, 0)
			if mancano > 0 and villaggio.scorte.get(tipo, 0) > 0:
				if rete.prossimo_salto(mag.bandiera, e.bandiera) != Vector2i(-1, -1) or mag.bandiera == e.bandiera:
					return [e, tipo]
	for e in villaggio.edifici.values():
		if not e.finito or not e.collegato:
			continue
		for tipo in CatalogoEdifici.dati(e.tipo).get("ingressi", {}):
			if _spazio_ingresso(e, tipo) > 0 and villaggio.scorte.get(tipo, 0) > 0:
				if rete.prossimo_salto(mag.bandiera, e.bandiera) != Vector2i(-1, -1):
					return [e, tipo]
	return []


func _spazio_ingresso(e: Edificio, tipo: String) -> int:
	var cap: int = CatalogoEdifici.dati(e.tipo).get("ingressi", {}).get(tipo, 0)
	return cap - e.ingresso.get(tipo, 0) - e.in_arrivo.get(tipo, 0)


# ------------------------------------------------------------ produzione

## Un lavoratore ha prodotto una merce: la posa alla bandierina del suo edificio e le trova
## una destinazione (prima chi la usa per lavorare, altrimenti il magazzino).
func produci(tipo: String, da: Edificio) -> void:
	if tipo == "":
		return
	var dest := _destinazione_per(tipo, da.bandiera)
	if dest == null:
		return
	if dest.tipo != "magazzino":
		dest.in_arrivo[tipo] = dest.in_arrivo.get(tipo, 0) + 1
	_nuova_merce(tipo, dest, da.bandiera)


func _destinazione_per(tipo: String, da: Vector2i) -> Edificio:
	var migliore: Edificio = null
	for e in villaggio.edifici.values():
		if e.finito and e.collegato and _spazio_ingresso(e, tipo) > 0 and (rete.prossimo_salto(da, e.bandiera).x >= 0):
			if migliore == null or Vector2(e.bandiera - da).length() < Vector2(migliore.bandiera - da).length():
				migliore = e
	if migliore:
		return migliore
	for e in _magazzini():
		if rete.prossimo_salto(da, e.bandiera).x >= 0 or e.bandiera == da:
			if migliore == null or Vector2(e.bandiera - da).length() < Vector2(migliore.bandiera - da).length():
				migliore = e
	return migliore if migliore else (_magazzini()[0] if _magazzini().size() > 0 else null)


func merci_in_uscita(e: Edificio) -> int:
	return _merci_in(e.bandiera)


# ------------------------------------------------------------ viaggio

var _da_consegnare: Array[Merce] = []


func _assegna_trasporti() -> void:
	_da_consegnare.clear()
	for m in merci:
		if m.prenotata or m.in_spalla:
			continue
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
		villaggio.scorte[m.tipo] = villaggio.scorte.get(m.tipo, 0) + 1
		scorte_cambiate.emit()
	elif e.finito:
		e.in_arrivo[m.tipo] = maxi(0, e.in_arrivo.get(m.tipo, 0) - 1)
		e.ingresso[m.tipo] = e.ingresso.get(m.tipo, 0) + 1
	else:
		e.consegnati[m.tipo] = e.consegnati.get(m.tipo, 0) + 1
	_disponi(m.bandiera)


func _nuova_merce(tipo: String, dest: Edificio, dove: Vector2i) -> void:
	var m := Merce.new(tipo, dest, dove)
	oggetti.add_child(m.sprite)
	merci.append(m)
	_disponi(dove)


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

const POSTI := [Vector2(-0.22, 0.12), Vector2(0.12, 0.22), Vector2(-0.3, -0.12), Vector2(0.24, -0.06),
	Vector2(-0.05, 0.3), Vector2(0.3, 0.2), Vector2(-0.34, 0.26), Vector2(0.06, -0.26)]


func _disponi(f: Vector2i) -> void:
	var k := 0
	for m in merci:
		if m.bandiera == f and not m.in_spalla:
			var o: Vector2 = POSTI[k % POSTI.size()]
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
