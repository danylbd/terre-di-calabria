class_name Costruttore
extends Colono
## Il costruttore di un cantiere (step 36a, come in Settlers): parte dal magazzino lungo le strade,
## si mette accanto al cantiere e lo tira su col mazzuolo mentre i portatori consegnano assi e pietre.
## Finito l'edificio (o se il cantiere viene demolito) torna al magazzino e ridiventa un colono libero.

var cantiere: Edificio
var villaggio: Node
var rete: ReteStrade
var al_lavoro := false               # è accanto al cantiere: il cantiere può avanzare
var _ritorno := false
var _bandiera := Vector2i.ZERO       # la bandierina del cantiere (resta anche se il cantiere sparisce)
var _foglio_cammino := "portatore_nessuno"
var _foglio_lavoro := ""


func avvia(v: Node, e: Edificio, rs: ReteStrade, partenza: Array[Vector2]) -> void:
	villaggio = v
	cantiere = e
	rete = rs
	_bandiera = e.bandiera
	if ResourceLoader.exists("res://assets/grafica/lavoratore_martello.png"):
		_foglio_cammino = "lavoratore_martello"
		_foglio_lavoro = "lavoratore_martello_lavoro"
	prepara(e.dati_mappa, partenza[0], _foglio_cammino)
	arrivato.connect(_on_arrivato)
	partenza.append(posto(e))
	percorri(partenza)


## Dove sta il costruttore mentre lavora: sul fianco del cantiere, verso la bandierina.
static func posto(e: Edificio) -> Vector2:
	return Vector2(e.casella.x + e.taglia + 0.15, e.casella.y + e.taglia - 0.35)


func _on_arrivato(_c: Colono) -> void:
	if _ritorno:
		villaggio.costruttore_tornato(self)
		queue_free()
		return
	if not is_instance_valid(cantiere) or cantiere.finito:
		torna()
		return
	al_lavoro = true
	if _foglio_lavoro != "":
		imposta_foglio(_foglio_lavoro)
	# guarda il cantiere
	var verso: Vector2 = dati.a_schermo(cantiere.centro().x, cantiere.centro().y) - position
	_anim.animation = Sprites.DIREZIONI[Sprites.direzione(verso)]


func _process(delta: float) -> void:
	super._process(delta)
	if not al_lavoro:
		return
	if not is_instance_valid(cantiere) or cantiere.finito:
		torna()
		return
	# martella solo quando ci sono materiali da mettere in opera
	if cantiere.collegato and cantiere.progresso < cantiere.frazione_materiali():
		if not _anim.is_playing():
			_anim.play()
	elif _anim.is_playing():
		_ferma()


## Torna al magazzino lungo le strade (se non c'è più strada, rientra subito).
func torna() -> void:
	if _ritorno:
		return
	al_lavoro = false
	_ritorno = true
	imposta_foglio(_foglio_cammino)
	var mag: Edificio = villaggio.magazzino()
	var punti: Array[Vector2] = [Vector2(_bandiera) + Vector2(0.5, 0.5)]
	if mag != null:
		var strada := rete.percorso_tra_bandiere(_bandiera, mag.bandiera)
		if not strada.is_empty() or mag.bandiera == _bandiera:
			punti.append_array(strada)
			punti.append(mag.centro())
			percorri(punti)
			return
	villaggio.costruttore_tornato(self)
	queue_free()
