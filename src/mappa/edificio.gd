class_name Edificio
extends Node2D
## Un edificio sulla mappa. Nasce come cantiere e cresce in tre fasi fino a diventare l'edificio vero.
## (Nello step 05 il cantiere avanzerà solo quando i portatori consegnano assi e pietre.)

signal completato(e: Edificio)

var id := 0
var tipo := ""
var casella := Vector2i.ZERO        # angolo in alto della sua impronta
var taglia := 1
var bandiera := Vector2i.ZERO       # casella davanti alla porta (per le strade dello step 03)
var progresso := 0.0                 # 0..1
var tempo_totale := 20.0
var finito := false

var _sprite: Sprite2D
var _fase := -1


func prepara(p_id: int, p_tipo: String, p_casella: Vector2i, gia_finito := false) -> void:
	id = p_id
	tipo = p_tipo
	casella = p_casella
	var d := CatalogoEdifici.dati(tipo)
	taglia = d["taglia"]
	tempo_totale = d["tempo"]
	bandiera = Vector2i(casella.x + taglia - 1, casella.y + taglia)
	_sprite = Sprite2D.new()
	_sprite.centered = false
	add_child(_sprite)
	if gia_finito:
		progresso = 1.0
		_finisci(false)
	else:
		_aggiorna_aspetto()


func centro() -> Vector2:
	return Vector2(casella.x + taglia * 0.5, casella.y + taglia * 0.5)


func _process(delta: float) -> void:
	if finito:
		return
	progresso = minf(1.0, progresso + delta / tempo_totale)
	_aggiorna_aspetto()
	queue_redraw()
	if progresso >= 1.0:
		_finisci(true)


func _aggiorna_aspetto() -> void:
	var fase := 0 if progresso < 0.25 else (1 if progresso < 0.6 else 2)
	if fase != _fase:
		_fase = fase
		_imposta_sprite("cantiere_%d" % fase)
		_sprite.scale = Vector2.ONE * (1.0 if taglia == 1 else 1.75)
		_sprite.offset = -Sprites.ancora("cantiere_%d" % fase)


func _finisci(avvisa: bool) -> void:
	finito = true
	_imposta_sprite(tipo)
	_sprite.scale = Vector2.ONE
	_sprite.offset = -Sprites.ancora(tipo)
	queue_redraw()
	if avvisa:
		completato.emit(self)


func _imposta_sprite(nome: String) -> void:
	_sprite.texture = Sprites.texture(nome)


func evidenzia(colore: Color) -> void:
	_sprite.modulate = colore


func _draw() -> void:
	if finito:
		return
	# barra di avanzamento del cantiere
	var w := 64.0
	var y := -62.0 if taglia == 1 else -110.0
	draw_rect(Rect2(-w * 0.5 - 2, y - 2, w + 4, 10), Color(Palette.INCHIOSTRO, 0.8))
	draw_rect(Rect2(-w * 0.5, y, w * progresso, 6), Palette.OCRA)
