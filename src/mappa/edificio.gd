class_name Edificio
extends Node2D
## Un edificio sulla mappa. Nasce come cantiere e cresce in tre fasi fino a diventare l'edificio vero.
## Il cantiere avanza solo quando i portatori consegnano assi e pietre e il costruttore (step 36a) è al lavoro.

signal completato(e: Edificio)

var id := 0
var tipo := ""
var casella := Vector2i.ZERO        # angolo in alto della sua impronta
var taglia := 1
var bandiera := Vector2i.ZERO       # casella davanti alla porta (per le strade dello step 03)
var progresso := 0.0                 # 0..1
var tempo_totale := 20.0
var finito := false
var collegato := false               # la sua bandierina è collegata a un magazzino
var fabbisogno := {}                 # materiali che servono al cantiere
var richiesti := {}                  # già partiti dal magazzino verso il cantiere
var consegnati := {}                 # già arrivati
var ingresso := {}                   # merci in deposito per la produzione (es. tronchi alla segheria)
var in_arrivo := {}                  # merci per la produzione già in viaggio verso l'edificio
var lavoratore: Node2D               # chi ci lavora (null se nessuno)
var costruttore: Node2D              # il costruttore del cantiere (null finché non parte dal magazzino)
var manca_attrezzo := false          # il lavoratore aspetta che arrivi il suo attrezzo
var manca_colono := false            # non c'erano coloni liberi per mandare il lavoratore
var prodotti := 0                    # merci prodotte finora
var nascita := 0.0                   # abitazioni: secondi al prossimo colono
var acquisto := ""                   # agorà: la merce da comprare con i ducati ("" = niente)
var guadagno := 0                    # agorà: ducati ricavati finora
var presidiata := false              # torri e castelli: la guardia è entrata, i confini si allargano
var soldati := 0                     # soldati dentro il forte (o difensori di una torre nemica)
var soldati_in_arrivo := 0
var proprietario := 1                # 1 il giocatore, 2.. un altro popolo
var mura := -1.0                     # torri nemiche (step 36): punti di mura da abbattere prima dei duelli (-1 nessuna)
var dati_mappa: DatiMappa
var villaggio: Node

var _sprite: Sprite2D
var _fase := -1
var _martello := 0.0


func prepara(p_id: int, p_tipo: String, p_casella: Vector2i, gia_finito := false) -> void:
	id = p_id
	tipo = p_tipo
	casella = p_casella
	var d := CatalogoEdifici.dati(tipo)
	taglia = d["taglia"]
	tempo_totale = d["tempo"]
	fabbisogno = (d["costo"] as Dictionary).duplicate()
	bandiera = Vector2i(casella.x + (taglia - 1) / 2, casella.y + taglia)
	_sprite = Sprite2D.new()
	_sprite.centered = false
	add_child(_sprite)
	if gia_finito:
		progresso = 1.0
		_finisci(false)
	else:
		_aggiorna_aspetto()


func frazione_materiali() -> float:
	var tot := 0
	var ok := 0
	for r in fabbisogno:
		tot += fabbisogno[r]
		ok += consegnati.get(r, 0)
	return 1.0 if tot == 0 else float(ok) / tot


func costruttore_al_lavoro() -> bool:
	return costruttore != null and is_instance_valid(costruttore) and costruttore.al_lavoro


func centro() -> Vector2:
	return Vector2(casella.x + taglia * 0.5, casella.y + taglia * 0.5)


func _process(delta: float) -> void:
	if finito:
		return
	if not collegato:
		queue_redraw()
		return
	# il cantiere avanza solo fin dove arrivano i materiali consegnati, e solo col costruttore accanto
	var limite := frazione_materiali()
	if progresso < limite and costruttore_al_lavoro():
		progresso = minf(limite, progresso + delta / tempo_totale)
		_martello -= delta
		if _martello <= 0.0:
			_martello = randf_range(0.45, 0.9)
			Suono.suona_in("martello", global_position, -6.0)
	queue_redraw()
	_aggiorna_aspetto()
	if progresso >= 1.0:
		_finisci(true)


func _aggiorna_aspetto() -> void:
	var fase := 0 if progresso < 0.25 else (1 if progresso < 0.6 else 2)
	if fase != _fase:
		_fase = fase
		_imposta_sprite("cantiere_%d" % fase)
		_sprite.scale = Vector2.ONE * (1.0 + (taglia - 1) * 0.7)
		_sprite.offset = -Sprites.ancora("cantiere_%d" % fase)


func _finisci(avvisa: bool) -> void:
	finito = true
	var aspetto := Popoli.sprite(tipo, Popoli.di(proprietario))
	_imposta_sprite(aspetto)
	_sprite.scale = Vector2.ONE
	_sprite.offset = -Sprites.ancora(aspetto)
	queue_redraw()
	if avvisa:
		Suono.suona_in("completato", global_position)
		completato.emit(self)


func _imposta_sprite(nome: String) -> void:
	_sprite.texture = Sprites.texture(nome)


func evidenzia(colore: Color) -> void:
	_sprite.modulate = colore


func _draw() -> void:
	if finito:
		if proprietario != 1 and mura >= 0.0:
			_disegna_mura()
		return
	# barra di avanzamento del cantiere
	var w := 64.0
	var y := -40.0 - taglia * 45.0
	draw_rect(Rect2(-w * 0.5 - 2, y - 2, w + 4, 14), Color(Palette.INCHIOSTRO, 0.8))
	draw_rect(Rect2(-w * 0.5, y, w * frazione_materiali(), 3), Palette.PERGAMENA_CHIARA)
	draw_rect(Rect2(-w * 0.5, y + 4, w * progresso, 6), Palette.OCRA if collegato else Color(0.6, 0.6, 0.6))
	if not collegato:
		# segnale: manca la strada
		var c := Vector2(0, y - 22)
		draw_circle(c, 12, Color(Palette.INCHIOSTRO, 0.85))
		draw_circle(c, 10, Color("e05a3a"))
		draw_rect(Rect2(c.x - 1.5, c.y - 6, 3, 8), Palette.PERGAMENA_CHIARA)
		draw_rect(Rect2(c.x - 1.5, c.y + 4, 3, 3), Palette.PERGAMENA_CHIARA)


## Le mura di una torre nemica: una fila di blocchi di pietra sopra la torre, uno per punto.
func _disegna_mura() -> void:
	var n := int(Schiere.MURA_MAX)
	var w := 7.0
	var x0 := -n * (w + 2.0) * 0.5
	var y := -70.0 - taglia * 45.0
	draw_rect(Rect2(x0 - 3, y - 3, n * (w + 2.0) + 4, w + 6), Color(Palette.INCHIOSTRO, 0.7))
	for k in n:
		var pieno := k < ceili(mura)
		draw_rect(Rect2(x0 + k * (w + 2.0), y, w, w), Color("c8bca4") if pieno else Color(0.35, 0.3, 0.26, 0.6))
