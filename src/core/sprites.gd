class_name Sprites
## Carica gli sprite prodotti dallo studio di rendering (PNG + JSON con l'ancoraggio).

static var _info := {}
static var _texture := {}
static var _animazioni := {}
static var _icone := {}

const DIREZIONI := ["S", "SE", "E", "NE", "N", "NO", "O", "SO"]


static func info(nome: String) -> Dictionary:
	if not _info.has(nome):
		var f := FileAccess.open("res://assets/grafica/%s.json" % nome, FileAccess.READ)
		_info[nome] = JSON.parse_string(f.get_as_text()) if f else {}
	return _info[nome]


static func texture(nome: String) -> Texture2D:
	if not _texture.has(nome):
		# Gli atlas animati di personaggi usano sempre i render 3D PNG dello studio.
		# Le SVG storiche restano disponibili solo come ripiego per asset senza PNG.
		var png := "res://assets/grafica/%s.png" % nome
		var colono := "res://assets/grafica/coloni/%s.svg" % nome
		_texture[nome] = load(png) if ResourceLoader.exists(png) else load(colono)
	return _texture[nome]


## Restituisce la variante culturale di un portatore o lavoratore, se presente.
static func atlante_colono(nome: String, popolo: String) -> String:
	# I soldati hanno un atlas C10 distinto per marcia e combattimento.
	# Il Brettio giocatore usa lo stesso modello culturale della variante alleata.
	var tipo_soldato := nome
	var e_lotta := tipo_soldato.ends_with("_lotta")
	if e_lotta:
		tipo_soldato = tipo_soldato.trim_suffix("_lotta")
	tipo_soldato = tipo_soldato.trim_suffix("_giocatore")
	var tipi_soldato := ["guardia", "legionario", "brettio", "cavaliere_leggero", "cavaliere_pesante",
		"guerriero_siculo", "arciere_sicano", "mercenario_cartaginese"]
	if tipo_soldato in tipi_soldato:
		var atlas_soldato := "c10_soldato_%s%s" % [tipo_soldato, "_lotta" if e_lotta else ""]
		if ResourceLoader.exists("res://assets/grafica/%s.png" % atlas_soldato):
			return atlas_soldato
	if not (nome.begins_with("portatore_") or nome.begins_with("lavoratore_")):
		return nome
	# Tutti i ruoli civili usano lo stesso modello C del proprio popolo. Merce e attrezzi
	# vengono disegnati come dettagli separati sopra il personaggio, evitando di mischiare
	# atlanti di stili e dimensioni differenti durante il cambio di stato.
	var base := "c10_portatore_%s" % popolo
	if ResourceLoader.exists("res://assets/grafica/%s.png" % base):
		return base
	base = "portatore_nessuno_%s" % popolo
	if ResourceLoader.exists("res://assets/grafica/%s.png" % base):
		return base
	var variante := "%s_%s" % [nome, popolo]
	return variante if ResourceLoader.exists("res://assets/grafica/%s.png" % variante) else nome


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
	var fps := float(i.get("fps", velocita))
	var tex := texture(nome)
	var sf := SpriteFrames.new()   # tiene anche "default" (un fotogramma) per evitare errori al primo assegnamento
	for d in DIREZIONI.size():
		var anim: String = DIREZIONI[d]
		sf.add_animation(anim)
		sf.set_animation_loop(anim, true)
		sf.set_animation_speed(anim, fps)
		for f in n:
			var at := AtlasTexture.new()
			at.atlas = tex
			at.region = Rect2(f * cella[0], d * cella[1], cella[0], cella[1])
			sf.add_frame(anim, at)
			if d == 0 and f == 0:
				sf.add_frame("default", at)
	_animazioni[nome] = sf
	return sf


static func ancora(nome: String) -> Vector2:
	var a: Array = info(nome).get("ancora", [0, 0])
	return Vector2(a[0], a[1])


## Indice della direzione (0 = S, poi SE, E, NE, N, NO, O, SO) da un movimento sullo schermo.
static func direzione(movimento: Vector2) -> int:
	var gradi := rad_to_deg(movimento.angle())
	return posmod(roundi((90.0 - gradi) / 45.0), 8)


## Icona per i menu: lo sprite ritagliato sulla parte visibile (senza i margini trasparenti).
static func icona(nome: String) -> Texture2D:
	if not _icone.has(nome):
		var tex := texture(nome)
		var img := tex.get_image()
		var at := AtlasTexture.new()
		at.atlas = tex
		at.region = Rect2(img.get_used_rect())
		_icone[nome] = at
	return _icone[nome]
