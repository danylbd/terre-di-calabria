class_name Colono
extends Node2D
## Un colono che cammina avanti e indietro lungo un percorso di punti della mappa.
## (Nello step 04 il percorso verrà dalla rete di strade; per ora è fisso.)

var dati: DatiMappa
var percorso: Array[Vector2] = []      # punti in coordinate di mappa
var velocita := 1.1                      # caselle al secondo
var _tappa := 1
var _pos := Vector2.ZERO
var _anim: AnimatedSprite2D
var _avanti := true


func prepara(d: DatiMappa, punti: Array[Vector2], foglio: String, ritardo := 0.0) -> void:
	dati = d
	percorso = punti
	_pos = punti[0].lerp(punti[1], fposmod(ritardo, 1.0))
	_anim = AnimatedSprite2D.new()
	_anim.sprite_frames = Sprites.animazioni(foglio)
	_anim.centered = false
	_anim.offset = -Sprites.ancora(foglio)
	add_child(_anim)
	_anim.play("S")
	_anim.frame = randi() % 8
	position = d.a_schermo(_pos.x, _pos.y)


func _process(delta: float) -> void:
	if percorso.size() < 2:
		return
	var meta := percorso[_tappa]
	var verso := meta - _pos
	var passo := velocita * delta
	if verso.length() <= passo:
		_pos = meta
		_prossima_tappa()
	else:
		_pos += verso.normalized() * passo
	var nuova := dati.a_schermo(_pos.x, _pos.y)
	var mov := nuova - position
	if mov.length_squared() > 0.0001:
		var nome_dir: String = Sprites.DIREZIONI[Sprites.direzione(mov)]
		if _anim.animation != nome_dir:
			var f := _anim.frame
			_anim.play(nome_dir)
			_anim.frame = f
	position = nuova


func _prossima_tappa() -> void:
	if _avanti:
		_tappa += 1
		if _tappa >= percorso.size():
			_avanti = false
			_tappa = percorso.size() - 2
	else:
		_tappa -= 1
		if _tappa < 0:
			_avanti = true
			_tappa = 1
