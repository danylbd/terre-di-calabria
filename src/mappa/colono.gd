class_name Colono
extends Node2D
## Un colono che cammina sulla mappa seguendo una serie di punti (coordinate di mappa)
## e poi si ferma ad aspettare.

signal arrivato(c: Colono)

var dati: DatiMappa
var velocita := 1.15                     # caselle al secondo
var agile := false                       # Brettii: più veloce nei boschi e in montagna
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
	# Le persone erano alla stessa scala delle strutture e dei mezzi: regola la sola figura,
	# lasciando invariati navi, animali e macchine da guerra.
	_anim.scale = Vector2.ONE * _scala_personaggio(foglio)


func _scala_personaggio(foglio: String) -> float:
	if foglio.begins_with("portatore_") or foglio.begins_with("lavoratore_"):
		return 0.58
	if foglio == "guardia" or foglio.begins_with("brettio") or foglio.begins_with("legionario") \
		or foglio.begins_with("cavaliere_") or foglio.begins_with("guerriero_") \
		or foglio.begins_with("arciere_") or foglio.begins_with("mercenario_") \
		or foglio.begins_with("condottiero_"):
		return 0.72
	return 1.0


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
	if agile and _in_montagna():
		passo *= Popoli.AGILITA
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


func _in_montagna() -> bool:
	var c := Vector2i(floori(pos.x), floori(pos.y))
	return dati.dentro(c.x, c.y) and (dati.tipo(c.x, c.y) == DatiMappa.Terreno.BOSCO or dati.quota(pos.x, pos.y) > Popoli.QUOTA_MONTAGNA)
