class_name Colono
extends Node2D
## Un colono che cammina sulla mappa seguendo una serie di punti (coordinate di mappa)
## e poi si ferma ad aspettare.

signal arrivato(c: Colono)

var dati: DatiMappa
var velocita := 1.15                     # caselle al secondo
var pos := Vector2.ZERO                  # posizione attuale in coordinate di mappa
var _punti: Array[Vector2] = []
var _foglio := ""
var _anim: AnimatedSprite2D


func prepara(d: DatiMappa, inizio: Vector2, foglio := "portatore_nessuno") -> void:
	dati = d
	pos = inizio
	_anim = AnimatedSprite2D.new()
	_anim.centered = false
	add_child(_anim)
	imposta_foglio(foglio)
	_anim.play("S")
	_ferma()
	position = d.a_schermo(pos.x, pos.y)


func imposta_foglio(foglio: String) -> void:
	if foglio == _foglio:
		return
	_foglio = foglio
	var anim: StringName = _anim.animation
	if anim == &"" or anim == &"default":
		anim = &"S"
	_anim.sprite_frames = Sprites.animazioni(foglio)
	_anim.animation = anim
	_anim.offset = -Sprites.ancora(foglio)


func percorri(punti: Array[Vector2]) -> void:
	_punti = punti.duplicate()
	if _punti.size() > 0:
		_anim.play()


func in_cammino() -> bool:
	return _punti.size() > 0


func _process(delta: float) -> void:
	if _punti.is_empty():
		return
	var passo := velocita * delta
	while passo > 0.0 and _punti.size() > 0:
		var meta: Vector2 = _punti[0]
		var verso := meta - pos
		var dist := verso.length()
		if dist <= passo:
			pos = meta
			passo -= dist
			_punti.pop_front()
		else:
			pos += verso / dist * passo
			passo = 0.0
	var nuova := dati.a_schermo(pos.x, pos.y)
	var mov := nuova - position
	if mov.length_squared() > 0.0001:
		var nome_dir: String = Sprites.DIREZIONI[Sprites.direzione(mov)]
		if _anim.animation != nome_dir:
			var f := _anim.frame
			_anim.play(nome_dir)
			_anim.frame = f
	position = nuova
	if _punti.is_empty():
		_ferma()
		arrivato.emit(self)


func _ferma() -> void:
	_anim.pause()
	_anim.frame = 0
