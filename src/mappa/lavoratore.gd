class_name Lavoratore
extends Colono
## Il lavoratore di un edificio di produzione. Arriva dal magazzino lungo le strade, entra
## nell'edificio e poi lavora: esce a piedi verso alberi, rocce, campi o riva, torna con la merce
## e la posa alla bandierina; oppure (segheria, mulino, forno, pozzo) la fa dentro l'edificio,
## consumando le merci che gli arrivano, ed esce a posare il prodotto.

enum Stato { ARRIVO, DENTRO, ANDATA, LAVORO, RITORNO, ESCE_CON_MERCE }

const RAGGIO := 7
const PAUSA := 3.5
## suono di lavoro di ogni mestiere e secondi tra un colpo e l'altro
const SUONI := {"boscaiolo": ["ascia", 0.85], "cava": ["piccone", 1.0], "guardaboschi": ["vanga", 1.3],
	"segheria": ["sega", 1.45], "fattoria": ["falce", 1.1], "vigneto": ["falce", 1.4], "ortolano": ["vanga", 1.3],
	"agrumeto": ["falce", 1.6], "uliveto": ["falce", 1.5], "mulino": ["macina", 1.7], "pozzo": ["tuffo", 2.4]}
## secondi di lavoro sul posto (o dentro l'edificio)
const DURATA := {"boscaiolo": 4.0, "cava": 4.0, "guardaboschi": 3.0, "fattoria": 3.5, "pescatore": 6.0,
	"uliveto": 4.0, "pesca_spada": 9.0}
const DURATA_DENTRO := 5.0
const MESTIERI_FUORI := ["boscaiolo", "cava", "guardaboschi", "pescatore", "uliveto", "pesca_spada"]
const RAGGIO_LARGO := 12
const RAGGIO_CAMPI := 4
const MAX_CAMPI := 8

var edificio: Edificio
var risorse: RisorseNaturali
var logistica: Logistica
var rete: ReteStrade
var stato := Stato.ARRIVO
var mestiere := ""
var _bersaglio := Vector2i(-1, -1)
var _acqua := Vector2i(-1, -1)       # casella di mare dove pesca il pescatore
var _semina := false                 # il contadino sta seminando (non mietendo)
var _turno := 0                      # per chi produce più merci a turno (ovile: latte e lana)
var _coltura := ""                   # per i contadini: grano, vite, orto, agrumi
var _foglio_terra := ""              # foglio da usare a terra (la barca lo cambia sull'acqua)
var _attesa := 0.0
var _foglio_cammino := ""
var _foglio_lavoro := ""
var _avvisato := false
var _colpo := 0.0


func avvia(e: Edificio, r: RisorseNaturali, l: Logistica, rs: ReteStrade, partenza: Array[Vector2]) -> void:
	edificio = e
	risorse = r
	logistica = l
	rete = rs
	mestiere = e.tipo
	var info := CatalogoEdifici.dati(e.tipo)
	_foglio_cammino = info.get("lavoratore", "portatore_nessuno")
	_foglio_lavoro = _foglio_cammino + "_lavoro" if _foglio_cammino.begins_with("lavoratore") else ""
	_coltura = info.get("coltura", "")
	prepara(e.dati_mappa, partenza[0], _foglio_cammino)
	arrivato.connect(_on_arrivato)
	partenza.append(e.centro())
	percorri(partenza)


func _porta() -> Vector2:
	return Vector2(edificio.bandiera) + Vector2(0.5, 0.5)


## La barca del pesce spada: sull'acqua il pescatore rema, a terra cammina.
func imposta_foglio(foglio: String) -> void:
	_foglio_terra = foglio
	if mestiere == "pesca_spada" and dati and dati.tipo(int(pos.x), int(pos.y)) == DatiMappa.Terreno.ACQUA:
		foglio = "barca_remi"
	super.imposta_foglio(foglio)


func _process(delta: float) -> void:
	super._process(delta)
	if not is_instance_valid(edificio) or edificio.is_queued_for_deletion():
		queue_free()
		return
	if mestiere == "pesca_spada" and visible:
		imposta_foglio(_foglio_terra)
	match stato:
		Stato.DENTRO:
			_attesa -= delta
			if _attesa <= 0.0:
				_cerca_lavoro()
		Stato.LAVORO:
			_attesa -= delta
			_suona_lavoro(delta)
			if _attesa <= 0.0:
				_fine_lavoro()


func _on_arrivato(_c: Colono) -> void:
	match stato:
		Stato.ARRIVO:
			_entra()
		Stato.ANDATA:
			stato = Stato.LAVORO
			_colpo = 0.3
			_attesa = DURATA.get(mestiere, 4.0)
			if _coltura != "":
				_attesa = 3.5
			if _foglio_lavoro != "":
				imposta_foglio(_foglio_lavoro)
				_anim.play()
		Stato.RITORNO, Stato.ESCE_CON_MERCE:
			logistica.produci(_merce_prodotta(), edificio)
			_turno += 1
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
	if _coltura != "":
		if not _cerca_campo(da):
			return
		_esci_verso_bersaglio()
		return
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
		"uliveto":
			_bersaglio = risorse.ulivo_con_olive(da, RAGGIO)
			if _bersaglio.x < 0 or not risorse.prenota_ulivo(_bersaglio):
				return
		"pesca_spada":
			_acqua = risorse.posto_al_largo(da, RAGGIO_LARGO)
			if _acqua.x < 0:
				_segnala("La barca non trova mare aperto vicino")
				return
			_bersaglio = _acqua
		"pescatore":
			var posto := risorse.posto_di_pesca(da, RAGGIO)
			if posto.is_empty():
				_segnala("Il pescatore non trova pesce vicino alla riva")
				return
			_bersaglio = posto[0]
			_acqua = posto[1]
		_:
			if mestiere in MESTIERI_FUORI:
				return
			_lavora_dentro()
			return
	_esci_verso_bersaglio()


func _esci_verso_bersaglio() -> void:
	_avvisato = false
	visible = true
	stato = Stato.ANDATA
	pos = edificio.centro()
	var punti: Array[Vector2] = [_porta(), Vector2(_bersaglio) + Vector2(0.35, 0.75)]
	percorri(punti)


## Contadino: raccoglie un campo maturo della sua coltura, altrimenti ne semina uno nuovo.
func _cerca_campo(da: Vector2i) -> bool:
	_semina = false
	_bersaglio = risorse.campo_maturo(da, RAGGIO_CAMPI + 1, _coltura)
	if _bersaglio.x >= 0 and risorse.prenota_campo(_bersaglio):
		return true
	_semina = true
	if risorse.campi_vicini(da, RAGGIO_CAMPI + 1, _coltura) >= MAX_CAMPI:
		return false
	_bersaglio = risorse.posto_per_campo(da, RAGGIO_CAMPI, rete)
	if _bersaglio.x < 0:
		_segnala("%s: non c'è spazio per i campi" % CatalogoEdifici.dati(mestiere)["nome"])
		return false
	return true


func _fine_lavoro() -> void:
	if _coltura != "":
		if _semina:
			if dati.occupante(_bersaglio.x, _bersaglio.y) == 0:
				risorse.semina(_bersaglio, _coltura)
			_rientra_vuoto()
		else:
			risorse.mieti(_bersaglio)
			_torna(Merce.FOGLI[_merce_prodotta()])
		return
	match mestiere:
		"boscaiolo":
			risorse.abbatti(_bersaglio)
			Suono.suona_in("albero_cade", global_position)
			_torna(Merce.FOGLI["tronchi"])
		"cava":
			risorse.estrai(_bersaglio)
			_torna(Merce.FOGLI["pietra"])
		"guardaboschi":
			if dati.occupante(_bersaglio.x, _bersaglio.y) == 0:
				risorse.pianta(_bersaglio)
			_rientra_vuoto()
		"uliveto":
			risorse.raccogli_olive(_bersaglio)
			_torna(Merce.FOGLI["olive"])
		"pesca_spada":
			if risorse.pesca_spada(_acqua):
				Suono.suona_in("tuffo", global_position, -2.0)
				_torna(Merce.FOGLI["pesce_spada"])
			else:
				_rientra_vuoto()
		"pescatore":
			if risorse.pesca(_acqua):
				Suono.suona_in("tuffo", global_position, -4.0)
				_torna(Merce.FOGLI["pesce"])
			else:
				_rientra_vuoto()
		_:
			# esce dalla porta con il prodotto e lo posa alla bandierina
			visible = true
			pos = edificio.centro()
			imposta_foglio(Merce.FOGLI.get(_merce_prodotta(), "portatore_nessuno"))
			stato = Stato.ESCE_CON_MERCE
			var punti: Array[Vector2] = [_porta()]
			percorri(punti)


## Dentro l'edificio: se ci sono tutte le merci in ingresso, ne consuma una per tipo e lavora.
func _lavora_dentro() -> void:
	var ingressi: Dictionary = CatalogoEdifici.dati(mestiere).get("ingressi", {})
	if ingressi.is_empty() and not logistica.serve(_merce_prodotta()):
		return
	for tipo in ingressi:
		if edificio.ingresso.get(tipo, 0) <= 0:
			return
	for tipo in ingressi:
		edificio.ingresso[tipo] -= 1
	stato = Stato.LAVORO
	_attesa = CatalogoEdifici.dati(mestiere).get("durata", DURATA_DENTRO)


func _rientra_vuoto() -> void:
	imposta_foglio(_foglio_cammino)
	stato = Stato.ARRIVO
	var punti: Array[Vector2] = [_porta(), edificio.centro()]
	percorri(punti)


func _suona_lavoro(delta: float) -> void:
	if not SUONI.has(mestiere):
		return
	_colpo -= delta
	if _colpo <= 0.0:
		_colpo = SUONI[mestiere][1]
		var dove := global_position if visible else edificio.global_position
		Suono.suona_in(SUONI[mestiere][0], dove, -3.0)


func _torna(foglio: String) -> void:
	imposta_foglio(foglio)
	stato = Stato.RITORNO
	var punti: Array[Vector2] = [_porta()]
	percorri(punti)


func _merce_prodotta() -> String:
	var p := CatalogoEdifici.prodotti(mestiere)
	return "" if p.is_empty() else p[_turno % p.size()]


func _segnala(testo: String) -> void:
	if not _avvisato:
		_avvisato = true
		edificio.villaggio.messaggio.emit(testo, true)
