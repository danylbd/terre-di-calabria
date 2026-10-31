class_name Sprites
## Carica gli sprite prodotti dallo studio di rendering (PNG + JSON con l'ancoraggio).

static var _info := {}
static var _texture := {}
static var _animazioni := {}

const DIREZIONI := ["S", "SE", "E", "NE", "N", "NO", "O", "SO"]


static func info(nome: String) -> Dictionary:
	if not _info.has(nome):
		var f := FileAccess.open("res://assets/grafica/%s.json" % nome, FileAccess.READ)
		_info[nome] = JSON.parse_string(f.get_as_text()) if f else {}
	return _info[nome]


static func texture(nome: String) -> Texture2D:
	if not _texture.has(nome):
		_texture[nome] = load("res://assets/grafica/%s.png" % nome)
	return _texture[nome]


## Sprite fermo, con il punto di ancoraggio (centro della casella a terra) nell'origine.
static func crea(nome: String) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = texture(nome)
	s.centered = false
	var a: Array = info(nome).get("ancora", [0, 0])
	s.offset = Vector2(-a[0], -a[1])
	return s


## Animazione da un foglio "direzioni × fotogrammi": un'animazione per ogni direzione.
static func animazioni(nome: String, velocita := 10.0) -> SpriteFrames:
	if _animazioni.has(nome):
		return _animazioni[nome]
	var i := info(nome)
	var cella: Array = i["cella"]
	var n: int = i["fotogrammi"]
	var tex := texture(nome)
	var sf := SpriteFrames.new()
	sf.remove_animation("default")
	for d in DIREZIONI.size():
		var anim: String = DIREZIONI[d]
		sf.add_animation(anim)
		sf.set_animation_speed(anim, velocita)
		for f in n:
			var at := AtlasTexture.new()
			at.atlas = tex
			at.region = Rect2(f * cella[0], d * cella[1], cella[0], cella[1])
			sf.add_frame(anim, at)
	_animazioni[nome] = sf
	return sf


static func ancora(nome: String) -> Vector2:
	var a: Array = info(nome).get("ancora", [0, 0])
	return Vector2(a[0], a[1])


## Indice della direzione (0 = S, poi SE, E, NE, N, NO, O, SO) da un movimento sullo schermo.
static func direzione(movimento: Vector2) -> int:
	var gradi := rad_to_deg(movimento.angle())
	return posmod(roundi((90.0 - gradi) / 45.0), 8)
