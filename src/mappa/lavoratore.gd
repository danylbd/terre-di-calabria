class_name Lavoratore
extends Colono
## Il lavoratore di un edificio di produzione. Arriva dal magazzino lungo le strade, entra
## nell'edificio e poi lavora: esce a piedi verso alberi o rocce, torna con la merce e la posa
## alla bandierina; oppure (segheria) trasforma le merci che gli arrivano.

enum Stato { ARRIVO, DENTRO, ANDATA, LAVORO, RITORNO, ESCE_CON_MERCE }

const RAGGIO := 7
const PAUSA := 3.5

var edificio: Edificio
var risorse: RisorseNaturali
var logistica: Logistica
var rete: ReteStrade
var stato := Stato.ARRIVO
var mestiere := ""
var _bersaglio := Vector2i(-1, -1)
var _attesa := 0.0
var _foglio_cammino := ""
var _foglio_lavoro := ""
var _avvisato := false


func avvia(e: Edificio, r: RisorseNaturali, l: Logistica, rs: ReteStrade, partenza: Array[Vector2]) -> void:
	edificio = e
	risorse = r
	logistica = l
	rete = rs
	mestiere = e.tipo
	var info := CatalogoEdifici.dati(e.tipo)
	_foglio_cammino = info.get("lavoratore", "portatore_nessuno")
	_foglio_lavoro = _foglio_cammino + "_lavoro" if _foglio_cammino.begins_with("lavoratore") else ""
	prepara(e.dati_mappa, partenza[0], _foglio_cammino)
	arrivato.connect(_on_arrivato)
	partenza.append(e.centro())
	percorri(partenza)


func _porta() -> Vector2:
	return Vector2(edificio.bandiera) + Vector2(0.5, 0.5)


func _process(delta: float) -> void:
	super._process(delta)
	if not is_instance_valid(edificio) or edificio.is_queued_for_deletion():
		queue_free()
		return
	match stato:
		Stato.DENTRO:
			_attesa -= delta
			if _attesa <= 0.0:
				_cerca_lavoro()
		Stato.LAVORO:
			_attesa -= delta
			if _attesa <= 0.0:
				_fine_lavoro()


func _on_arrivato(_c: Colono) -> void:
	match stato:
		Stato.ARRIVO:
			_entra()
		Stato.ANDATA:
			stato = Stato.LAVORO
			_attesa = 4.0 if mestiere != "guardaboschi" else 3.0
			if _foglio_lavoro != "":
				imposta_foglio(_foglio_lavoro)
				_anim.play()
		Stato.RITORNO, Stato.ESCE_CON_MERCE:
			logistica.produci(_merce_prodotta(), edificio)
			imposta_foglio(_foglio_cammino)
			stato = Stato.ARRIVO
			var dentro: Array[Vector2] = [edificio.centro()]
			percorri(dentro)


func _entra() -> void:
	stato = Stato.DENTRO
	visible = false
	_attesa = PAUSA


func _cerca_lavoro() -> void:
	_attesa = PAUSA
	if logistica.merci_in_uscita(edificio) >= 3:
		return
	var da := edificio.bandiera
	match mestiere:
		"boscaiolo":
			_bersaglio = risorse.albero_vicino(da, RAGGIO)
			if _bersaglio.x < 0 or not risorse.prenota_albero(_bersaglio):
				_segnala("Il boscaiolo non trova alberi vicini")
				return
		"cava":
			_bersaglio = risorse.roccia_vicina(da, RAGGIO)
			if _bersaglio.x < 0 or not risorse.prenota_roccia(_bersaglio):
				_segnala("La cava non trova rocce vicine")
				return
		"guardaboschi":
			_bersaglio = risorse.posto_per_albero(da, RAGGIO - 1, rete)
			if _bersaglio.x < 0:
				return
		"segheria":
			if edificio.ingresso.get("tronchi", 0) <= 0:
				return
			edificio.ingresso["tronchi"] -= 1
			stato = Stato.LAVORO
			_attesa = 5.0
			return
		_:
			return
	_avvisato = false
	visible = true
	stato = Stato.ANDATA
	pos = edificio.centro()
	var punti: Array[Vector2] = [_porta(), Vector2(_bersaglio) + Vector2(0.35, 0.75)]
	percorri(punti)


func _fine_lavoro() -> void:
	match mestiere:
		"boscaiolo":
			risorse.abbatti(_bersaglio)
			_torna("portatore_tronco")
		"cava":
			risorse.estrai(_bersaglio)
			_torna("portatore_pietra")
		"guardaboschi":
			if dati.occupante(_bersaglio.x, _bersaglio.y) == 0:
				risorse.pianta(_bersaglio)
			imposta_foglio(_foglio_cammino)
			stato = Stato.ARRIVO
			var punti: Array[Vector2] = [_porta(), edificio.centro()]
			percorri(punti)
		"segheria":
			# esce dalla porta con le assi e le posa alla bandierina
			visible = true
			pos = edificio.centro()
			imposta_foglio("portatore_asse")
			stato = Stato.ESCE_CON_MERCE
			var punti: Array[Vector2] = [_porta()]
			percorri(punti)


func _torna(foglio: String) -> void:
	imposta_foglio(foglio)
	stato = Stato.RITORNO
	var punti: Array[Vector2] = [_porta()]
	percorri(punti)


func _merce_prodotta() -> String:
	return CatalogoEdifici.dati(mestiere).get("produce", "")


func _segnala(testo: String) -> void:
	if not _avvisato:
		_avvisato = true
		edificio.villaggio.messaggio.emit(testo, true)
