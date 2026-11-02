extends "res://tools/studio/modelli.gd"
## Modelli dei Cartaginesi (step 37, docs/cartaginesi.md): parte «b». Lo studio unisce catalogo_extra()
## di ogni file tools/studio/modelli_*.gd al catalogo di modelli.gd.
##
## Stile punico: mattoni crudi intonacati color sabbia e calce bianca, terrazze piatte col parapetto,
## cornici «a gola» (cavetto) sopra porte e finestre, fascia e drappi di porpora, legno di cedro scuro,
## palme da dattero, anfore puniche a siluro, merli a scalini, il segno di Tanit dipinto sulle porte.
## Ogni modello ha lo stesso ingombro del corrispondente dei Saraceni/Siculi (stesso nome senza il suffisso).


static func catalogo_extra() -> Dictionary:
	return {
		"saline_cartaginesi": {"crea": saline_cartaginesi},
		"tessitura_cartaginesi": {"crea": tessitura_cartaginesi},
		"pescatore_cartaginesi": {"crea": capanna_pescatore_cartaginesi},
		"frantoio_cartaginesi": {"crea": frantoio_cartaginesi},
		"uliveto_cartaginesi": {"crea": uliveto_cartaginesi},
		"vigneto_cartaginesi": {"crea": vigneto_cartaginesi},
		"cantina_cartaginesi": {"crea": cantina_cartaginesi},
		"ortolano_cartaginesi": {"crea": ortolano_cartaginesi},
		"agrumeto_cartaginesi": {"crea": agrumeto_cartaginesi},
		"pesca_spada_cartaginesi": {"crea": pesca_spada_cartaginesi},
		"miniera_ferro_cartaginesi": {"crea": miniera_ferro_cartaginesi},
		"miniera_argento_cartaginesi": {"crea": miniera_ferro_cartaginesi.bind("argento_grezzo")},
		"zecca_cartaginesi": {"crea": zecca_cartaginesi},
		"armaiolo_cartaginesi": {"crea": armaiolo_cartaginesi},
		"carbonaia_cartaginesi": {"crea": carbonaia_cartaginesi},
		"fonderia_cartaginesi": {"crea": fonderia_cartaginesi},
		"fabbro_cartaginesi": {"crea": fabbro_cartaginesi},
		"torre_cartaginesi": {"crea": torre_cartaginesi},
		"castello_cartaginesi": {"crea": castello_cartaginesi},
		"caserma_cartaginesi": {"crea": caserma_cartaginesi},
	}


# ------------------------------------------------------------------ materiali propri (nella cache di modelli.gd)

## Aggiunge alla cache dei materiali di modelli.gd quelli punici (porpora, cedro, intonaco color sabbia).
## Le regolazioni dello shader «vissuto» si prendono in prestito da un materiale simile.
static func _mat_cb() -> void:
	if _cache_mat.has("porpora_cb"):
		return
	_nuovo_mat("porpora_cb", _rumore(3701, 0.3, Color("4a0c3c"), Color("721a5c")), 1.0, "stoffa_rossa")
	_nuovo_mat("tenda_porpora_cb", _strisce_tex(Color("efe6d2"), Color("561048")), 3.0, "tenda_rossa")
	_nuovo_mat("cedro_cb", _rumore(3702, 0.15, Color("3a2116"), Color("62402a")), 2.0, "persiana")
	_nuovo_mat("anfora_cb", _rumore(3704, 0.3, Color("a8704a"), Color("d8ae84")), 2.0, "ceramica")
	_nuovo_mat("muro_cb", _rumore(3703, 0.08, Color("cfac74"), Color("ecd4a2")), 2.0, "intonaco_giallo")


static func _nuovo_mat(nome: String, tex: Texture2D, scala: float, regola_come: String) -> void:
	var m := StandardMaterial3D.new()
	m.roughness = 0.9
	m.uv1_triplanar = true
	m.albedo_texture = tex
	m.uv1_scale = Vector3.ONE * scala
	_cache_mat[nome] = _a_vissuto(m, regola_come)


# ------------------------------------------------------------------ kit punico

## Muri punici: zoccolo di mattoni crudi, intonaco color sabbia (o calce) con qualche toppa caduta, fascia di porpora,
## cornice a gola di calce, teste di travi di cedro, doccione, terrazza piatta col parapetto (merli a scalini facoltativi).
## Restituisce la quota del pavimento della terrazza.
static func _muri_cb(r: Node3D, lx: float, lz: float, h: float, seme: int, mat := "muro_cb", merli := false, fascia := true) -> float:
	_mat_cb()
	var rng := _rng(seme)
	r.add_child(scatola(Vector3(lx + 0.05, 0.07, lz + 0.05), Vector3(0, 0.035, 0), "mattoni_crudi"))
	r.add_child(scatola(Vector3(lx, h, lz), Vector3(0, 0.07 + h * 0.5, 0), mat))
	var top := 0.07 + h
	if mat != "mattoni_crudi":
		for k in 3:
			var w := rng.randf_range(0.06, 0.11)
			var hh := rng.randf_range(0.035, 0.06)
			var y := rng.randf_range(0.11, top - 0.15)
			if k < 2:
				r.add_child(scatola(Vector3(w, hh, 0.01), Vector3(rng.randf_range(-lx * 0.4, lx * 0.4), y, lz * 0.5 + 0.002), "mattoni_crudi"))
			else:
				r.add_child(scatola(Vector3(0.01, hh, w), Vector3(lx * 0.5 + 0.002, y, rng.randf_range(-lz * 0.4, lz * 0.4)), "mattoni_crudi"))
	if fascia:
		r.add_child(scatola(Vector3(lx + 0.006, 0.03, lz + 0.006), Vector3(0, top - 0.078, 0), "porpora_cb"))
	# cornice a gola: tre gradini di calce che si allargano verso l'alto
	for k in 3:
		var s := 0.008 + k * 0.016
		r.add_child(scatola(Vector3(lx + s, 0.014, lz + s), Vector3(0, top - 0.035 + k * 0.014, 0), "calce"))
	# teste di travi di cedro
	var nt := int(lx / 0.11)
	for i in nt:
		r.add_child(cilindro(0.01, 0.01, 0.04, Vector3(-lx * 0.5 + (i + 0.5) * lx / nt, top - 0.05, lz * 0.5 + 0.01), "cedro_cb", Vector3(90, 0, 0), 6))
	var ntz := int(lz / 0.11)
	for i in ntz:
		r.add_child(cilindro(0.01, 0.01, 0.04, Vector3(lx * 0.5 + 0.01, top - 0.05, -lz * 0.5 + (i + 0.5) * lz / ntz), "cedro_cb", Vector3(0, 0, 90), 6))
	var dz := rng.randf_range(-lz * 0.3, lz * 0.3)
	r.add_child(cilindro(0.012, 0.014, 0.09, Vector3(lx * 0.5 + 0.045, top + 0.012, dz), "terracotta", Vector3(0, 0, 80), 6))
	r.add_child(scatola(Vector3(0.004, top * 0.55, 0.022), Vector3(lx * 0.5 + 0.002, top * 0.62, dz), "intonaco_sporco"))
	r.add_child(scatola(Vector3(lx - 0.04, 0.006, lz - 0.04), Vector3(0, top + 0.01, 0), "battuto"))
	_parapetto_s(r, lx + 0.04, lz + 0.04, top + 0.007, merli, "calce", 0.04)
	return top + 0.007


## Cornice a gola (cavetto) sopra un vano, nel nodo locale che guarda verso +Z: tre listelli che sporgono
## sempre di più, col disco alato d'oro al centro. pos è il centro della base.
static func _gola(n: Node3D, pos: Vector3, w: float) -> void:
	for k in 3:
		n.add_child(scatola(Vector3(w + k * 0.016, 0.011, 0.014 + k * 0.009), pos + Vector3(0, 0.0055 + k * 0.011, 0.007 + k * 0.0045), "calce"))
	n.add_child(sfera(0.009, pos + Vector3(0, 0.017, 0.024), "moneta", Vector3(1, 1, 0.4)))
	for lato: int in [-1, 1]:
		n.add_child(scatola(Vector3(0.012, 0.005, 0.004), pos + Vector3(lato * 0.016, 0.017, 0.022), "moneta"))


## Segno di Tanit (triangolo, braccia, disco) dipinto; nel nodo locale guarda verso +Z. pos è il centro del triangolo.
static func _tanit(n: Node3D, pos: Vector3, s: float, mat := "calce") -> void:
	n.add_child(cilindro(s, s, 0.004, pos, mat, Vector3(-90, 0, 0), 3))
	n.add_child(scatola(Vector3(s * 2.0, s * 0.28, 0.004), pos + Vector3(0, s * 0.9, 0), mat))
	n.add_child(cilindro(s * 0.45, s * 0.45, 0.004, pos + Vector3(0, s * 1.55, 0), mat, Vector3(90, 0, 0), 12))


## Porta punica (nel nodo locale guarda verso +Z): stipiti e architrave di calce, cornice a gola, battenti di cedro
## col segno di Tanit dipinto di bianco e le borchie di bronzo (o vano aperto), soglia. pos è il piede della porta.
static func _porta_cb(r: Node3D, pos: Vector3, rot_y := 0.0, w := 0.13, h := 0.17, aperta := false) -> void:
	_mat_cb()
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot_y
	r.add_child(n)
	n.add_child(scatola(Vector3(w, h, 0.014), Vector3(0, h * 0.5, 0.004), "buio"))
	for lato: int in [-1, 1]:
		n.add_child(scatola(Vector3(0.022, h + 0.02, 0.016), Vector3(lato * (w * 0.5 + 0.011), (h + 0.02) * 0.5, 0.007), "calce"))
	n.add_child(scatola(Vector3(w + 0.07, 0.022, 0.018), Vector3(0, h + 0.011, 0.008), "calce"))
	_gola(n, Vector3(0, h + 0.022, 0.0), w + 0.07)
	if not aperta:
		n.add_child(scatola(Vector3(w * 0.94, h * 0.97, 0.012), Vector3(0, h * 0.485, 0.009), "cedro_cb"))
		n.add_child(scatola(Vector3(0.005, h * 0.95, 0.006), Vector3(0, h * 0.48, 0.016), "legno_scuro"))
		for i: int in [-1, 1]:
			for j in 2:
				n.add_child(sfera(0.006, Vector3(i * w * 0.36, 0.03 + j * h * 0.7, 0.016), "bronzo"))
		_tanit(n, Vector3(0, h * 0.42, 0.017), w * 0.17)
	else:
		_tanit(n, Vector3(0, h + 0.075, 0.03), 0.018, "porpora_cb")
	n.add_child(scatola(Vector3(w + 0.07, 0.014, 0.05), Vector3(0, 0.007, 0.03), "blocco"))
	if pos.y > 0.01:
		n.add_child(scatola(Vector3(w + 0.08, pos.y, 0.07), Vector3(0, -pos.y * 0.5, 0.035), "blocco"))


## Finestrella punica (nel nodo locale guarda verso +Z): vano scuro con la grata di cedro, tendina di porpora,
## davanzale e cornice a gola. pos è il centro del vano; rot_y = 0 per la facciata +Z, 90 per la +X.
static func _finestra_cb(r: Node3D, pos: Vector3, rot_y: float, w := 0.06, h := 0.075) -> void:
	_mat_cb()
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot_y
	r.add_child(n)
	n.add_child(scatola(Vector3(w, h, 0.012), Vector3(0, 0, 0.003), "buio"))
	n.add_child(scatola(Vector3(w * 0.45, h * 0.85, 0.004), Vector3(-w * 0.26, h * 0.06, 0.008), "porpora_cb"))
	for k in 2:
		n.add_child(scatola(Vector3(0.005, h, 0.005), Vector3((k - 0.5) * w * 0.4, 0, 0.012), "cedro_cb"))
	n.add_child(scatola(Vector3(w, 0.005, 0.005), Vector3(0, 0, 0.012), "cedro_cb"))
	for lato: int in [-1, 1]:
		n.add_child(scatola(Vector3(0.012, h + 0.012, 0.012), Vector3(lato * (w * 0.5 + 0.006), 0, 0.006), "calce"))
	n.add_child(scatola(Vector3(w + 0.03, 0.012, 0.028), Vector3(0, -h * 0.5 - 0.006, 0.012), "calce"))
	_gola(n, Vector3(0, h * 0.5, 0.0), w + 0.03)


## Drappo di porpora appeso a un'asta di cedro (nel nodo locale verso +Z), con la fascia d'oro e la frangia.
## pos è il centro dell'asta.
static func _drappo(r: Node3D, pos: Vector3, rot_y: float, w: float, h: float) -> void:
	_mat_cb()
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot_y
	r.add_child(n)
	n.add_child(cilindro(0.006, 0.006, w + 0.04, Vector3(0, 0, 0.006), "cedro_cb", Vector3(0, 0, 90), 5))
	n.add_child(scatola(Vector3(w, h, 0.005), Vector3(0, -h * 0.5, 0.008), "porpora_cb"))
	n.add_child(scatola(Vector3(w, 0.012, 0.004), Vector3(0, -h + 0.02, 0.012), "seta_oro"))
	n.add_child(scatola(Vector3(w * 0.12, h * 0.7, 0.004), Vector3(0, -h * 0.45, 0.012), "seta_oro"))
	var nf := maxi(3, int(w / 0.03))
	for k in nf:
		n.add_child(sfera(0.006, Vector3(-w * 0.5 + (k + 0.5) * w / nf, -h - 0.004, 0.008), "moneta"))


## Anfora punica a siluro: corpo lungo e stretto, puntale, spalla carenata, orlo basso e due anse ad anello.
## L'origine è sulla punta del puntale; alta circa 0.25 × scala.
static func _anfora_p(pos: Vector3, scala := 1.0, rot := Vector3.ZERO) -> Node3D:
	_mat_cb()
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees = rot
	n.scale = Vector3.ONE * scala
	n.add_child(cilindro(0.006, 0.032, 0.06, Vector3(0, 0.03, 0), "anfora_cb", Vector3.ZERO, 10))
	n.add_child(cilindro(0.032, 0.038, 0.14, Vector3(0, 0.13, 0), "anfora_cb", Vector3.ZERO, 12))
	n.add_child(sfera(0.039, Vector3(0, 0.2, 0), "anfora_cb", Vector3(1, 0.42, 1)))
	n.add_child(cilindro(0.015, 0.017, 0.022, Vector3(0, 0.22, 0), "anfora_cb", Vector3.ZERO, 8))
	n.add_child(cilindro(0.019, 0.019, 0.009, Vector3(0, 0.234, 0), "argilla", Vector3.ZERO, 8))
	for lato: int in [-1, 1]:
		n.add_child(_toro(0.004, 0.012, Vector3(lato * 0.036, 0.19, 0), "anfora_cb", Vector3(90, 0, 0)))
	n.add_child(cilindro(0.0385, 0.0385, 0.008, Vector3(0, 0.165, 0), "argilla", Vector3.ZERO, 12))
	n.add_child(cilindro(0.0365, 0.0365, 0.006, Vector3(0, 0.1, 0), "argilla", Vector3.ZERO, 12))
	return n


## Anfora a siluro coricata a terra (yaw = direzione in gradi).
static func _anfora_giu(pos: Vector3, yaw := 0.0, scala := 1.0) -> Node3D:
	return _anfora_p(pos + Vector3(0, 0.037 * scala, 0), scala, Vector3(0, yaw, 90))


## Rastrelliera di cedro con una fila di anfore a siluro infilate in piedi (fila lungo X locale).
static func _rastrelliera_anfore(r: Node3D, pos: Vector3, n_anf: int, rot_y := 0.0, scala := 1.0) -> void:
	_mat_cb()
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot_y
	r.add_child(n)
	var lung := n_anf * 0.075 * scala
	for lato: int in [-1, 1]:
		n.add_child(scatola(Vector3(0.02, 0.14 * scala, 0.07 * scala), Vector3(lato * (lung * 0.5 + 0.01), 0.07 * scala, 0), "cedro_cb"))
	n.add_child(scatola(Vector3(lung + 0.04, 0.014, 0.08 * scala), Vector3(0, 0.12 * scala, 0), "cedro_cb"))
	for k in n_anf:
		n.add_child(_anfora_p(Vector3(-lung * 0.5 + (k + 0.5) * lung / n_anf, 0.0, 0), scala))


## Insegna punica: asta di cedro col simbolo di bronzo (disco sopra la falce di luna) e drappo di porpora
## con il segno di Tanit bianco e la frangia d'oro (verso +Z).
static func _stendardo_cb(r: Node3D, pos: Vector3, h := 0.6) -> void:
	_mat_cb()
	r.add_child(cilindro(0.009, 0.011, h, pos + Vector3(0, h * 0.5, 0), "cedro_cb", Vector3.ZERO, 6))
	r.add_child(_toro(0.012, 0.02, pos + Vector3(0, h + 0.02, 0), "moneta", Vector3(90, 90, 0)))
	r.add_child(sfera(0.014, pos + Vector3(0, h + 0.05, 0), "moneta"))
	r.add_child(cilindro(0.005, 0.005, 0.2, pos + Vector3(0, h - 0.02, 0.09), "cedro_cb", Vector3(90, 0, 0), 5))
	r.add_child(scatola(Vector3(0.006, 0.17, 0.16), pos + Vector3(0, h - 0.11, 0.095), "porpora_cb"))
	r.add_child(scatola(Vector3(0.008, 0.016, 0.16), pos + Vector3(0, h - 0.19, 0.095), "seta_oro"))
	for k in 5:
		r.add_child(sfera(0.006, pos + Vector3(0, h - 0.205, 0.025 + k * 0.035), "moneta"))
	var t := Node3D.new()
	t.position = pos + Vector3(0.005, h - 0.12, 0.095)
	t.rotation_degrees.y = 90
	r.add_child(t)
	_tanit(t, Vector3.ZERO, 0.022)


## Mercenario libico: tunica bianca con la cintura di porpora, elmo di bronzo col cimiero, scudo ovale di porpora
## con l'orlo e l'umbone di bronzo, lancia.
static func _mercenario_cb(pos: Vector3, s := 0.9, rot := 0.0) -> Node3D:
	_mat_cb()
	var g := portatore("", "porpora_cb", "lino_bianco")
	g.position = pos
	g.scale = Vector3.ONE * s
	g.rotation_degrees.y = rot
	g.add_child(sfera(0.08, Vector3(0, 0.475, -0.005), "bronzo", Vector3(1.0, 0.8, 1.05)))
	g.add_child(scatola(Vector3(0.016, 0.05, 0.13), Vector3(0, 0.55, -0.01), "porpora_cb"))
	g.add_child(sfera(0.1, Vector3(-0.1, 0.3, 0.04), "porpora_cb", Vector3(0.14, 1.3, 0.85)))
	g.add_child(sfera(0.104, Vector3(-0.097, 0.3, 0.04), "bronzo", Vector3(0.1, 1.32, 0.88)))
	g.add_child(sfera(0.022, Vector3(-0.116, 0.3, 0.04), "bronzo"))
	g.add_child(cilindro(0.006, 0.006, 0.56, Vector3(0.09, 0.28, 0.0), "cedro_cb", Vector3.ZERO, 5))
	g.add_child(cilindro(0.012, 0.0, 0.06, Vector3(0.09, 0.59, 0.0), "ferro", Vector3.ZERO, 5))
	return g


## Scudo ovale punico appoggiato o appeso (la faccia guarda verso +Z locale, ruotata con rot).
static func _scudo_ovale(r: Node3D, pos: Vector3, rot: Vector3, s := 1.0) -> void:
	_mat_cb()
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees = rot
	n.scale = Vector3.ONE * s
	r.add_child(n)
	n.add_child(sfera(0.075, Vector3.ZERO, "bronzo", Vector3(0.8, 1.25, 0.12)))
	n.add_child(sfera(0.07, Vector3(0, 0, 0.003), "porpora_cb", Vector3(0.8, 1.25, 0.14)))
	n.add_child(sfera(0.016, Vector3(0, 0, 0.01), "bronzo"))


## Barca punica (prua verso +X locale): scafo di cedro con la fascia di porpora, occhio dipinto e polena a testa di cavallo.
static func _barca_cb(pos: Vector3, rot := 0.0, s := 1.0) -> Node3D:
	_mat_cb()
	var b := Node3D.new()
	b.position = pos
	b.rotation_degrees.y = rot
	b.scale = Vector3.ONE * s
	b.add_child(sfera(0.13, Vector3(0, 0.07, 0), "cedro_cb", Vector3(2.7, 0.7, 1.0)))
	b.add_child(sfera(0.132, Vector3(0, 0.085, 0), "porpora_cb", Vector3(2.72, 0.22, 1.02)))
	b.add_child(sfera(0.115, Vector3(0, 0.1, 0), "legno", Vector3(2.6, 0.35, 0.9)))
	for lato: int in [-1, 1]:
		b.add_child(sfera(0.016, Vector3(0.27, 0.1, lato * 0.085), "calce", Vector3(1.3, 1, 0.4)))
		b.add_child(sfera(0.008, Vector3(0.275, 0.1, lato * 0.093), "buio"))
	# polena a testa di cavallo e poppa ricurva
	b.add_child(cilindro(0.016, 0.02, 0.14, Vector3(0.35, 0.16, 0), "cedro_cb", Vector3(0, 0, -30), 6))
	b.add_child(sfera(0.03, Vector3(0.39, 0.235, 0), "cedro_cb", Vector3(1.6, 0.9, 0.7)))
	b.add_child(scatola(Vector3(0.03, 0.012, 0.012), Vector3(0.37, 0.27, 0), "porpora_cb"))
	b.add_child(cilindro(0.012, 0.006, 0.18, Vector3(-0.34, 0.18, 0), "cedro_cb", Vector3(0, 0, 40), 6))
	for z: float in [-0.05, 0.06]:
		b.add_child(scatola(Vector3(0.5, 0.01, 0.025), Vector3(0.0, 0.15, z), "legno_chiaro", Vector3(0, 8, 4)))
	return b


## Conchiglia di murice (da cui si ricava la porpora): guscio a punta con la bocca viola.
static func _murice(pos: Vector3, s := 1.0, rot := 0.0) -> Node3D:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees = Vector3(0, rot, 70)
	n.scale = Vector3.ONE * s
	n.add_child(sfera(0.02, Vector3.ZERO, "osso", Vector3(1, 1.5, 1)))
	n.add_child(cilindro(0.0, 0.012, 0.035, Vector3(0, 0.035, 0), "argilla", Vector3.ZERO, 6))
	n.add_child(sfera(0.012, Vector3(0, -0.006, 0.012), "porpora_cb", Vector3(1, 1.4, 0.5)))
	return n


## Casa punica in pos: crea il nodo, i muri e la terrazza; restituisce [nodo, quota della terrazza].
static func _casa_cb(r: Node3D, pos: Vector3, lx: float, lz: float, h: float, seme: int, mat := "muro_cb", merli := false, fascia := true) -> Array:
	var c := Node3D.new()
	c.position = pos
	r.add_child(c)
	var top := _muri_cb(c, lx, lz, h, seme, mat, merli, fascia)
	return [c, top]


## Vasca quadrata di mattoni crudi con l'orlo di calce e la fascia di porpora, piena d'acqua.
static func _vasca_cb(r: Node3D, pos: Vector3, rg := 0.08) -> void:
	_mat_cb()
	r.add_child(scatola(Vector3(rg * 2, 0.07, rg * 2), pos + Vector3(0, 0.035, 0), "mattoni_crudi"))
	r.add_child(scatola(Vector3(rg * 2 + 0.006, 0.014, rg * 2 + 0.006), pos + Vector3(0, 0.05, 0), "porpora_cb"))
	r.add_child(scatola(Vector3(rg * 2 + 0.02, 0.014, rg * 2 + 0.02), pos + Vector3(0, 0.077, 0), "calce"))
	r.add_child(scatola(Vector3(rg * 2 - 0.02, 0.004, rg * 2 - 0.02), pos + Vector3(0, 0.084, 0), "acqua_chiara"))


## Stanzetta sulla terrazza: cubo color sabbia con la sua cornice a gola.
static func _stanzetta(c: Node3D, pos: Vector3, lx: float, lz: float, h: float) -> void:
	c.add_child(scatola(Vector3(lx, h, lz), pos + Vector3(0, h * 0.5, 0), "muro_cb"))
	for k in 3:
		c.add_child(scatola(Vector3(lx + 0.01 + k * 0.012, 0.01, lz + 0.01 + k * 0.012), pos + Vector3(0, h + 0.005 + k * 0.01, 0), "calce"))


# ------------------------------------------------------------------ edifici dei Cartaginesi

## Saline dei Cartaginesi: vasche bordate di mattoni crudi, mucchi di sale bianco, casotto color sabbia con la tenda
## di porpora sulla terrazza, pala, sacchi, anfore a siluro e palma.
static func saline_cartaginesi() -> Node3D:
	_mat_cb()
	var r := Node3D.new()
	for i in 3:
		for j in 2:
			var p := Vector3(-0.45 + i * 0.42, 0, -0.22 + j * 0.48)
			r.add_child(scatola(Vector3(0.4, 0.04, 0.44), p + Vector3(0, 0.02, 0), "mattoni_crudi"))
			var mat := "acqua_chiara" if (i + j) % 3 != 0 else "sale"
			r.add_child(scatola(Vector3(0.34, 0.005, 0.38), p + Vector3(0, 0.042, 0), mat))
			if mat == "sale":
				for k in 3:
					r.add_child(sfera(0.035, p + Vector3(-0.1 + k * 0.1, 0.045, 0.05 * (k - 1)), "sale", Vector3(1, 0.6, 1)))
	_canaletta(r, Vector3(-0.68, 0, -0.5), Vector3(0.3, 0, -0.5), 0.03)
	for p: Vector3 in [Vector3(0.6, 0, 0.52), Vector3(0.4, 0, 0.64), Vector3(-0.6, 0, 0.6)]:
		r.add_child(sfera(0.1, p, "sale", Vector3(1, 0.9, 1)))
	var cs := _casa_cb(r, Vector3(0.58, 0, -0.52), 0.3, 0.26, 0.15, 3711, "muro_cb", false, true)
	var c: Node3D = cs[0]
	var top: float = cs[1]
	_porta_cb(c, Vector3(-0.04, 0.07, 0.13), 0.0, 0.08, 0.09)
	_tenda(c, Vector3(0.0, top, 0.0), 0.26, 0.22, 0.14, 0.11, 0.0, "tenda_porpora_cb", true)
	var a := attrezzo("pala")
	a.position = Vector3(0.22, 0.02, 0.45)
	a.rotation_degrees = Vector3(0, -30, 5)
	r.add_child(a)
	r.add_child(sacco(Vector3(0.0, 0, 0.64), 0.3))
	r.add_child(sacco(Vector3(0.12, 0, 0.7), 1.2))
	r.add_child(_anfora_giu(Vector3(0.78, 0, -0.18), 5.0, 1.0))
	r.add_child(_anfora_giu(Vector3(0.8, 0, -0.08), -5.0, 1.0))
	_palma(r, Vector3(0.25, 0, -0.74), 0.6, 3712)
	return r


## Tessitura dei Cartaginesi: bottega color sabbia, telaio di cedro con la tela di porpora, bianca e d'oro,
## drappi di porpora stesi ad asciugare su una pertica, matasse colorate, palma.
static func tessitura_cartaginesi() -> Node3D:
	_mat_cb()
	var r := Node3D.new()
	var lx := 0.72
	var lz := 0.52
	var cs := _casa_cb(r, Vector3(-0.2, 0, -0.28), lx, lz, 0.36, 3721)
	var c: Node3D = cs[0]
	var top: float = cs[1]
	_porta_cb(c, Vector3(-0.16, 0.07, lz * 0.5), 0.0, 0.13, 0.16)
	_finestra_cb(c, Vector3(0.18, 0.28, lz * 0.5), 0.0)
	_finestra_cb(c, Vector3(lx * 0.5, 0.28, 0.0), 90.0)
	_tenda(c, Vector3(0.12, top, -0.04), 0.34, 0.28, 0.17, 0.13, 0.0, "tenda_porpora_cb", true)
	var t := Vector3(0.0, 0, 0.5)
	for x: float in [-0.18, 0.18]:
		r.add_child(cilindro(0.012, 0.012, 0.4, t + Vector3(x, 0.2, 0), "cedro_cb", Vector3.ZERO, 6))
	r.add_child(cilindro(0.012, 0.012, 0.42, t + Vector3(0, 0.39, 0), "cedro_cb", Vector3(0, 0, 90), 6))
	var fili := ["porpora_cb", "seta_oro", "lino_bianco", "porpora_cb", "seta_oro", "porpora_cb"]
	for k in 6:
		r.add_child(scatola(Vector3(0.34, 0.04, 0.006), t + Vector3(0, 0.34 - k * 0.04, 0), fili[k]))
	for k in 5:
		r.add_child(sfera(0.014, t + Vector3(-0.14 + k * 0.07, 0.08, 0), "argilla"))
	var colori := ["lana", "porpora_cb", "seta_zafferano"]
	for i in 3:
		var p := Vector3(0.55 + (i % 2) * 0.06, 0, 0.0 + i * 0.1)
		r.add_child(sfera(0.045, p + Vector3(0, 0.035, 0), colori[i], Vector3(1.2, 0.8, 1)))
	for x: float in [0.36, 0.86]:
		r.add_child(cilindro(0.009, 0.009, 0.38, Vector3(x, 0.19, -0.35), "cedro_cb", Vector3.ZERO, 5))
	r.add_child(cilindro(0.008, 0.008, 0.56, Vector3(0.61, 0.375, -0.35), "cedro_cb", Vector3(0, 0, 90), 5))
	_drappo(r, Vector3(0.49, 0.375, -0.35), 0.0, 0.2, 0.26)
	_drappo(r, Vector3(0.73, 0.375, -0.35), 0.0, 0.2, 0.22)
	_palma(r, Vector3(-0.66, 0, 0.3), 0.6, 3722)
	return r


## Capanna del pescatore dei Cartaginesi: casetta color sabbia con la tenda di porpora, reti stese, barca con
## l'occhio dipinto e la polena a cavallo, ceste di pesce e di murici (per la porpora), anfora, palma.
static func capanna_pescatore_cartaginesi() -> Node3D:
	_mat_cb()
	var r := Node3D.new()
	var lx := 0.66
	var lz := 0.5
	var cs := _casa_cb(r, Vector3(-0.22, 0, -0.25), lx, lz, 0.3, 3731)
	var c: Node3D = cs[0]
	var top: float = cs[1]
	_porta_cb(c, Vector3(0.12, 0.07, lz * 0.5), 0.0, 0.12, 0.15)
	_finestra_cb(c, Vector3(-0.16, 0.25, lz * 0.5), 0.0)
	_finestra_cb(c, Vector3(lx * 0.5, 0.25, 0.0), 90.0)
	_tenda(c, Vector3(-0.12, top, 0.0), 0.32, 0.26, 0.18, 0.14, 0.0, "tenda_porpora_cb", true)
	c.add_child(scatola(Vector3(0.18, 0.04, 0.12), Vector3(0.2, top + 0.02, -0.08), "rete"))
	for x: float in [0.35, 0.75]:
		r.add_child(cilindro(0.012, 0.012, 0.36, Vector3(x, 0.18, -0.35), "cedro_cb", Vector3.ZERO, 6))
	r.add_child(scatola(Vector3(0.4, 0.26, 0.006), Vector3(0.55, 0.2, -0.35), "rete"))
	for k in 6:
		r.add_child(scatola(Vector3(0.004, 0.26, 0.008), Vector3(0.37 + k * 0.07, 0.2, -0.345), "corda"))
	for k in 4:
		r.add_child(scatola(Vector3(0.4, 0.004, 0.008), Vector3(0.55, 0.1 + k * 0.065, -0.345), "corda"))
	r.add_child(_barca_cb(Vector3(0.36, 0, 0.42), -25))
	r.add_child(cesta(Vector3(-0.45, 0, 0.45), "pesce"))
	r.add_child(cesta(Vector3(-0.3, 0, 0.6), "pesce"))
	# cesta e mucchietto di murici
	r.add_child(cilindro(0.06, 0.05, 0.06, Vector3(-0.6, 0.03, 0.55), "canne", Vector3.ZERO, 12))
	for k in 7:
		var a := k * 2.3
		r.add_child(_murice(Vector3(-0.6 + cos(a) * 0.03, 0.065 + (k % 2) * 0.01, 0.55 + sin(a) * 0.03), 0.9, k * 50.0))
	for k in 5:
		r.add_child(_murice(Vector3(-0.1 + k * 0.035, 0.012, 0.66 + (k % 2) * 0.03), 0.8, k * 70.0))
	r.add_child(_anfora_giu(Vector3(-0.66, 0, 0.18), 140.0, 1.0))
	_palma(r, Vector3(-0.68, 0, -0.05), 0.7, 3732)
	return r


## Frantoio dei Cartaginesi: grande bottega color sabbia col camino e la stanzetta sulla terrazza, trapeto
## (vasca di pietra con due mole), anfore d'olio nella rastrelliera di cedro, fiscoli, giara grande, ulivo.
static func frantoio_cartaginesi() -> Node3D:
	_mat_cb()
	var r := Node3D.new()
	var lx := 0.82
	var lz := 0.62
	var cs := _casa_cb(r, Vector3(-0.2, 0, -0.22), lx, lz, 0.4, 3741)
	var c: Node3D = cs[0]
	var top: float = cs[1]
	_porta_cb(c, Vector3(0.18, 0.07, lz * 0.5), 0.0, 0.15, 0.18)
	_finestra_cb(c, Vector3(-0.18, 0.31, lz * 0.5), 0.0)
	_finestra_cb(c, Vector3(lx * 0.5, 0.31, 0.12), 90.0)
	_finestra_cb(c, Vector3(lx * 0.5, 0.31, -0.14), 90.0)
	_camino_s(c, Vector3(-0.26, top, -0.16))
	_stanzetta(c, Vector3(0.14, top, -0.1), 0.3, 0.26, 0.14)
	_tenda(c, Vector3(0.14, top, 0.12), 0.3, 0.16, 0.13, 0.1, 0.0, "tenda_porpora_cb", false)
	var m := Vector3(-0.35, 0, 0.55)
	r.add_child(cilindro(0.26, 0.28, 0.1, m + Vector3(0, 0.05, 0), "blocco", Vector3.ZERO, 24))
	r.add_child(cilindro(0.27, 0.27, 0.012, m + Vector3(0, 0.104, 0), "calce", Vector3.ZERO, 24))
	r.add_child(cilindro(0.21, 0.21, 0.01, m + Vector3(0, 0.106, 0), "oliva", Vector3.ZERO, 24))
	r.add_child(cilindro(0.035, 0.035, 0.22, m + Vector3(0, 0.2, 0), "cedro_cb", Vector3.ZERO, 8))
	for lato: int in [-1, 1]:
		r.add_child(sfera(0.1, m + Vector3(lato * 0.12, 0.17, 0), "blocco", Vector3(0.55, 1, 1)))
	r.add_child(cilindro(0.012, 0.012, 0.62, m + Vector3(0, 0.27, 0), "cedro_cb", Vector3(0, 0, 90), 6))
	_rastrelliera_anfore(r, Vector3(0.38, 0, 0.5), 4, 0.0, 1.0)
	for i in 3:
		r.add_child(cilindro(0.06, 0.05, 0.06, Vector3(0.66, 0.03, -0.3 + i * 0.15), "canne", Vector3.ZERO, 12))
		r.add_child(sfera(0.05, Vector3(0.66, 0.06, -0.3 + i * 0.15), "oliva", Vector3(1, 0.4, 1)))
	r.add_child(anfora(Vector3(0.68, 0.0, 0.2), 1.6))
	var u := ulivo(3742)
	u.position = Vector3(-0.7, 0, -0.45)
	u.scale = Vector3.ONE * 0.8
	r.add_child(u)
	return r


## Uliveto dei Cartaginesi: casetta color sabbia con la tenda di porpora, ulivo con il telo steso sotto,
## olive raccolte, ceste, scala a pioli di cedro, anfore a siluro, palma.
static func uliveto_cartaginesi() -> Node3D:
	_mat_cb()
	var r := Node3D.new()
	var lx := 0.58
	var lz := 0.46
	var cs := _casa_cb(r, Vector3(-0.3, 0, -0.3), lx, lz, 0.28, 3751)
	var c: Node3D = cs[0]
	var top: float = cs[1]
	_porta_cb(c, Vector3(-0.08, 0.07, lz * 0.5), 0.0, 0.12, 0.15)
	_finestra_cb(c, Vector3(lx * 0.5, 0.24, 0.0), 90.0, 0.055, 0.06)
	_tenda(c, Vector3(0.0, top, -0.02), 0.28, 0.24, 0.16, 0.12, 0.0, "tenda_porpora_cb", true)
	var u := ulivo(3752)
	u.position = Vector3(0.35, 0, 0.3)
	u.scale = Vector3.ONE * 0.85
	r.add_child(u)
	r.add_child(scatola(Vector3(0.5, 0.004, 0.45), Vector3(0.35, 0.004, 0.3), "lino", Vector3(0, 12, 0)))
	for k in 12:
		r.add_child(sfera(0.012, Vector3(0.2 + (k % 4) * 0.08, 0.012, 0.18 + (k / 4) * 0.1), "oliva"))
	for p: Vector3 in [Vector3(-0.45, 0, 0.45), Vector3(-0.25, 0, 0.58), Vector3(0.62, 0, -0.2)]:
		r.add_child(cesta(p, "olive"))
	r.add_child(scatola(Vector3(0.03, 0.45, 0.012), Vector3(0.12, 0.22, 0.12), "cedro_cb", Vector3(0, 0, -18)))
	r.add_child(scatola(Vector3(0.03, 0.45, 0.012), Vector3(0.12, 0.22, 0.2), "cedro_cb", Vector3(0, 0, -18)))
	r.add_child(_anfora_giu(Vector3(-0.62, 0, 0.12), 170.0, 1.0))
	r.add_child(_anfora_giu(Vector3(-0.64, 0, 0.24), 175.0, 1.0))
	_palma(r, Vector3(0.6, 0, -0.55), 0.55, 3753)
	return r


## Vigneto dei Cartaginesi: casetta color sabbia, pergolato d'uva su pilastrini di calce con le travi di cedro,
## vasca per pigiare bordata di porpora, ceste di grappoli, anfora.
static func vigneto_cartaginesi() -> Node3D:
	_mat_cb()
	var r := Node3D.new()
	var lx := 0.66
	var lz := 0.5
	var cs := _casa_cb(r, Vector3(-0.25, 0, -0.3), lx, lz, 0.32, 3761)
	var c: Node3D = cs[0]
	var top: float = cs[1]
	_porta_cb(c, Vector3(0.1, 0.07, lz * 0.5), 0.0, 0.13, 0.16)
	_finestra_cb(c, Vector3(-0.18, 0.26, lz * 0.5), 0.0)
	_finestra_cb(c, Vector3(lx * 0.5, 0.26, 0.0), 90.0)
	_tenda(c, Vector3(0.12, top, -0.02), 0.34, 0.26, 0.18, 0.14, 0.0, "tenda_porpora_cb", true)
	for p: Vector3 in [Vector3(-0.35, 0, 0.15), Vector3(0.25, 0, 0.15), Vector3(-0.35, 0, 0.55), Vector3(0.25, 0, 0.55)]:
		r.add_child(scatola(Vector3(0.035, 0.36, 0.035), p + Vector3(0, 0.18, 0), "calce"))
		r.add_child(scatola(Vector3(0.05, 0.03, 0.05), p + Vector3(0, 0.015, 0), "mattoni_crudi"))
		r.add_child(scatola(Vector3(0.05, 0.015, 0.05), p + Vector3(0, 0.36, 0), "calce"))
	for z: float in [0.15, 0.55]:
		r.add_child(scatola(Vector3(0.66, 0.018, 0.018), Vector3(-0.05, 0.37, z), "cedro_cb"))
	var rng := _rng(3762)
	for k in 26:
		r.add_child(sfera(0.045, Vector3(rng.randf_range(-0.38, 0.28), 0.385, rng.randf_range(0.12, 0.58)), "foglie" if k % 3 else "foglie_chiare", Vector3(1, 0.5, 1)))
	for k in 6:
		r.add_child(sfera(0.022, Vector3(-0.3 + k * 0.1, 0.33, 0.35 + (k % 2) * 0.1), "uva", Vector3(1, 1.5, 1)))
	var v := Vector3(0.56, 0, 0.38)
	r.add_child(scatola(Vector3(0.24, 0.1, 0.24), v + Vector3(0, 0.05, 0), "mattoni_crudi"))
	r.add_child(scatola(Vector3(0.252, 0.014, 0.252), v + Vector3(0, 0.08, 0), "porpora_cb"))
	r.add_child(scatola(Vector3(0.25, 0.018, 0.25), v + Vector3(0, 0.1, 0), "calce"))
	r.add_child(scatola(Vector3(0.2, 0.005, 0.2), v + Vector3(0, 0.108, 0), "uva"))
	r.add_child(cesta(Vector3(0.62, 0, 0.0), "uva"))
	r.add_child(cesta(Vector3(0.45, 0, -0.2), "uva"))
	r.add_child(_anfora_giu(Vector3(0.72, 0, 0.14), 110.0, 1.0))
	return r


## Cantina dei Cartaginesi: magazzino di mattoni crudi con la cornice a gola e la stanzetta merlata, file di anfore
## a siluro nelle rastrelliere di cedro e coricate a piramide, vasca del mosto, cesta d'uva, palma.
static func cantina_cartaginesi() -> Node3D:
	_mat_cb()
	var r := Node3D.new()
	var lx := 0.76
	var lz := 0.56
	var cs := _casa_cb(r, Vector3(-0.2, 0, -0.25), lx, lz, 0.36, 3771, "mattoni_crudi", false, true)
	var c: Node3D = cs[0]
	var top: float = cs[1]
	_porta_cb(c, Vector3(0.15, 0.07, lz * 0.5), 0.0, 0.16, 0.17)
	_finestra_cb(c, Vector3(-0.2, 0.28, lz * 0.5), 0.0)
	_finestra_cb(c, Vector3(lx * 0.5, 0.28, 0.0), 90.0)
	_stanzetta(c, Vector3(-0.14, top, -0.08), 0.28, 0.28, 0.12)
	_parapetto_s(c, 0.32, 0.32, top + 0.155, true, "calce", 0.03)
	_rastrelliera_anfore(r, Vector3(0.6, 0, -0.2), 4, 90.0, 1.05)
	_rastrelliera_anfore(r, Vector3(-0.42, 0, 0.42), 4, 0.0, 1.0)
	# anfore coricate a piramide
	for f in 2:
		for k in 3 - f:
			r.add_child(_anfora_p(Vector3(0.36, 0.038 + f * 0.066, 0.3 + (k - (2 - f) * 0.5) * 0.08), 0.95, Vector3(0, 0, 90)))
	r.add_child(scatola(Vector3(0.3, 0.1, 0.24), Vector3(0.05, 0.05, 0.58), "mattoni_crudi"))
	r.add_child(scatola(Vector3(0.32, 0.016, 0.26), Vector3(0.05, 0.1, 0.58), "calce"))
	r.add_child(scatola(Vector3(0.26, 0.01, 0.2), Vector3(0.05, 0.105, 0.58), "vino"))
	r.add_child(cesta(Vector3(-0.18, 0, 0.66), "uva"))
	_palma(r, Vector3(-0.7, 0, -0.1), 0.6, 3772)
	return r


## Ortolano dei Cartaginesi: casetta color sabbia con la tenda di porpora, orto attraversato dalla canaletta,
## trecce di cipolle appese a una pertica di cedro, ceste di verdura, palma.
static func ortolano_cartaginesi() -> Node3D:
	_mat_cb()
	var r := Node3D.new()
	var lx := 0.58
	var lz := 0.46
	var cs := _casa_cb(r, Vector3(-0.3, 0, -0.3), lx, lz, 0.28, 3781)
	var c: Node3D = cs[0]
	var top: float = cs[1]
	_porta_cb(c, Vector3(0.08, 0.07, lz * 0.5), 0.0, 0.12, 0.15)
	_finestra_cb(c, Vector3(-0.16, 0.24, lz * 0.5), 0.0, 0.055, 0.06)
	_tenda(c, Vector3(0.0, top, -0.02), 0.3, 0.24, 0.17, 0.13, 0.0, "tenda_porpora_cb", true)
	orto(r, Vector3(0.45, 0, 0.0), 0.36, 0.6, 3782)
	_canaletta(r, Vector3(0.45, 0, -0.32), Vector3(0.45, 0, 0.32), 0.025)
	for x: float in [-0.56, -0.2]:
		r.add_child(cilindro(0.01, 0.01, 0.34, Vector3(x, 0.17, 0.05), "cedro_cb", Vector3.ZERO, 5))
	r.add_child(cilindro(0.008, 0.008, 0.38, Vector3(-0.38, 0.33, 0.05), "cedro_cb", Vector3(0, 0, 90), 5))
	for k in 4:
		for i in 4:
			r.add_child(sfera(0.02, Vector3(-0.5 + k * 0.08, 0.3 - i * 0.04, 0.05), "cipolla"))
	for p: Vector3 in [Vector3(-0.42, 0, 0.45), Vector3(-0.22, 0, 0.56)]:
		r.add_child(cesta(p, "ortaggi"))
	r.add_child(cesta(Vector3(0.05, 0, 0.6), "cipolle"))
	_palma(r, Vector3(0.7, 0, -0.6), 0.5, 3783)
	return r


## Agrumeto dei Cartaginesi: casetta color sabbia con la stanzetta sulla terrazza, albero di agrumi in un'aiuola
## bordata di mattoni crudi bagnata dalla canaletta che scende da una vasca, ceste di frutti, palma.
static func agrumeto_cartaginesi() -> Node3D:
	_mat_cb()
	var r := Node3D.new()
	var lx := 0.6
	var lz := 0.46
	var cs := _casa_cb(r, Vector3(-0.3, 0, -0.3), lx, lz, 0.3, 3791)
	var c: Node3D = cs[0]
	var top: float = cs[1]
	_porta_cb(c, Vector3(-0.1, 0.07, lz * 0.5), 0.0, 0.12, 0.15)
	_finestra_cb(c, Vector3(0.15, 0.25, lz * 0.5), 0.0, 0.06, 0.065)
	_stanzetta(c, Vector3(0.1, top, -0.08), 0.22, 0.2, 0.11)
	_tenda(c, Vector3(-0.12, top, 0.0), 0.2, 0.2, 0.13, 0.1, 0.0, "tenda_porpora_cb", true)
	var a := agrumi(3)
	var terra := a.get_child(0)
	a.remove_child(terra)
	terra.free()
	a.position = Vector3(0.3, 0, 0.25)
	a.scale = Vector3.ONE * 1.1
	r.add_child(a)
	r.add_child(cilindro(0.2, 0.2, 0.03, Vector3(0.3, 0.015, 0.25), "mattoni_crudi", Vector3.ZERO, 16))
	r.add_child(cilindro(0.18, 0.18, 0.004, Vector3(0.3, 0.031, 0.25), "terra", Vector3.ZERO, 16))
	_vasca_cb(r, Vector3(-0.02, 0, 0.6), 0.07)
	_canaletta(r, Vector3(0.05, 0, 0.6), Vector3(0.22, 0, 0.42), 0.025)
	for p: Vector3 in [Vector3(-0.45, 0, 0.45), Vector3(-0.28, 0, 0.62), Vector3(0.7, 0, -0.25)]:
		r.add_child(cesta(p, "agrumi"))
	r.add_child(cassa(Vector3(0.66, 0, 0.05), 20))
	_palma(r, Vector3(0.62, 0, -0.62), 0.5, 3792)
	return r


## Pesca del pesce spada dei Cartaginesi: casetta color sabbia, barca punica con l'albero di vedetta e il
## pennoncello di porpora, passerella dell'arpioniere, arpione e pesce spada, anfore.
static func pesca_spada_cartaginesi() -> Node3D:
	_mat_cb()
	var r := Node3D.new()
	var lx := 0.6
	var lz := 0.46
	var cs := _casa_cb(r, Vector3(-0.3, 0, -0.3), lx, lz, 0.3, 3801)
	var c: Node3D = cs[0]
	var top: float = cs[1]
	_porta_cb(c, Vector3(0.1, 0.07, lz * 0.5), 0.0, 0.12, 0.15)
	_finestra_cb(c, Vector3(lx * 0.5, 0.25, 0.0), 90.0)
	_finestra_cb(c, Vector3(-0.15, 0.25, lz * 0.5), 0.0, 0.055, 0.06)
	c.add_child(scatola(Vector3(0.2, 0.04, 0.12), Vector3(-0.1, top + 0.02, -0.06), "rete"))
	var b := _barca_cb(Vector3(0.3, 0, 0.35), -30, 1.12)
	r.add_child(b)
	b.add_child(cilindro(0.01, 0.008, 0.6, Vector3(0.0, 0.42, 0), "cedro_cb", Vector3.ZERO, 6))
	for k in 5:
		b.add_child(scatola(Vector3(0.08, 0.006, 0.01), Vector3(0.0, 0.2 + k * 0.08, 0.0), "cedro_cb"))
	b.add_child(scatola(Vector3(0.006, 0.04, 0.07), Vector3(0.0, 0.69, 0.035), "porpora_cb"))
	b.add_child(sfera(0.012, Vector3(0.0, 0.73, 0), "moneta"))
	b.add_child(scatola(Vector3(0.4, 0.012, 0.02), Vector3(0.52, 0.13, 0), "legno_chiaro"))
	r.add_child(cilindro(0.008, 0.008, 0.5, Vector3(-0.62, 0.012, 0.3), "cedro_cb", Vector3(90, 0, 0), 5))
	r.add_child(cilindro(0.014, 0.0, 0.06, Vector3(-0.62, 0.012, 0.58), "ferro", Vector3(90, 0, 0), 5))
	var sp := pesce_spada_modello()
	sp.position = Vector3(-0.35, 0.02, 0.55)
	r.add_child(sp)
	r.add_child(_anfora_giu(Vector3(0.68, 0, -0.2), 5.0, 1.0))
	r.add_child(_anfora_giu(Vector3(0.7, 0, -0.08), -5.0, 1.0))
	return r


## Miniera dei Cartaginesi: fianco della montagna con l'imbocco murato color sabbia, stipiti di calce, cornice
## a gola e segno di Tanit, merli a scalini, binari, carrello di cedro, mucchio di minerale, lucerna, puntelli, insegna.
static func miniera_ferro_cartaginesi(minerale := "minerale") -> Node3D:
	_mat_cb()
	var r := Node3D.new()
	r.add_child(sfera(0.6, Vector3(-0.25, 0.0, -0.3), "roccia_massi", Vector3(1.2, 0.75, 1.0)))
	r.add_child(sfera(0.35, Vector3(0.35, 0.0, -0.45), "roccia_massi", Vector3(1.1, 0.8, 1.0)))
	r.add_child(sfera(0.3, Vector3(-0.65, 0.0, 0.15), "roccia_massi", Vector3(1.0, 0.7, 1.0)))
	var imb := Vector3(-0.05, 0, 0.18)
	r.add_child(scatola(Vector3(0.42, 0.38, 0.14), imb + Vector3(0, 0.19, -0.02), "muro_cb"))
	r.add_child(scatola(Vector3(0.43, 0.02, 0.15), imb + Vector3(0, 0.32, -0.02), "porpora_cb"))
	for k in 3:
		r.add_child(scatola(Vector3(0.43 + k * 0.016, 0.014, 0.15 + k * 0.016), imb + Vector3(0, 0.36 + k * 0.014, -0.02), "calce"))
	_fila_merli(r, imb + Vector3(-0.2, 0.4, 0.03), imb + Vector3(0.2, 0.4, 0.03), "calce", 0.8)
	_porta_cb(r, imb + Vector3(0, 0, 0.05), 0.0, 0.17, 0.2, true)
	for k in 6:
		r.add_child(scatola(Vector3(0.14, 0.008, 0.02), imb + Vector3(0, 0.004, 0.12 + k * 0.08), "legno_scuro"))
	for lato: int in [-1, 1]:
		r.add_child(scatola(Vector3(0.012, 0.01, 0.5), imb + Vector3(lato * 0.05, 0.012, 0.33), "ferro"))
	var carr := Vector3(-0.05, 0, 0.5)
	r.add_child(scatola(Vector3(0.14, 0.08, 0.18), carr + Vector3(0, 0.07, 0), "cedro_cb"))
	r.add_child(scatola(Vector3(0.145, 0.014, 0.185), carr + Vector3(0, 0.09, 0), "porpora_cb"))
	r.add_child(mucchio(carr + Vector3(0, 0.1, 0), minerale, 6, 3, 0.03))
	for x: float in [-0.075, 0.075]:
		for z: float in [-0.06, 0.06]:
			r.add_child(cilindro(0.022, 0.022, 0.012, carr + Vector3(x, 0.025, z), "ferro", Vector3(0, 0, 90), 8))
	r.add_child(mucchio(Vector3(0.45, 0, 0.35), minerale, 14, 4))
	# lucerna punica su un palo
	r.add_child(cilindro(0.01, 0.01, 0.3, Vector3(0.22, 0.15, 0.3), "cedro_cb", Vector3.ZERO, 5))
	r.add_child(sfera(0.022, Vector3(0.22, 0.31, 0.3), "terracotta", Vector3(1.3, 0.5, 1)))
	r.add_child(sfera(0.012, Vector3(0.245, 0.33, 0.3), "brace"))
	for k in 4:
		r.add_child(cilindro(0.018, 0.018, 0.4, Vector3(-0.55 + k * 0.045, 0.02 + (k % 2) * 0.03, 0.55), "cedro_cb", Vector3(0, 70, 90), 6))
	var a := attrezzo("piccone")
	a.position = Vector3(0.25, 0.02, 0.6)
	a.rotation_degrees.y = 30
	r.add_child(a)
	r.add_child(_anfora_giu(Vector3(0.62, 0, 0.5), -30.0, 1.0))
	_stendardo_cb(r, Vector3(0.62, 0, 0.08), 0.45)
	return r


## Zecca dei Cartaginesi: palazzetto color sabbia merlato con il portico di pilastri dai capitelli a volute sotto
## la cornice a gola, grande moneta d'oro col cavallo e la palma, casse di monete, incudine, argento grezzo,
## mercenario di guardia, insegna.
static func zecca_cartaginesi() -> Node3D:
	_mat_cb()
	var r := Node3D.new()
	var lx := 0.74
	var lz := 0.56
	var cs := _casa_cb(r, Vector3(-0.2, 0, -0.25), lx, lz, 0.44, 3811, "muro_cb", true, true)
	var c: Node3D = cs[0]
	var top: float = cs[1]
	_porta_cb(c, Vector3(0.0, 0.07, lz * 0.5), 0.0, 0.15, 0.18)
	_finestra_cb(c, Vector3(lx * 0.5, 0.32, 0.17), 90.0)
	_finestra_cb(c, Vector3(lx * 0.5, 0.32, -0.19), 90.0)
	# portico: pilastri di calce con i capitelli a volute d'oro, architrave con la gola
	var zp := lz * 0.5 + 0.08
	for x: float in [-0.3, -0.14, 0.14, 0.3]:
		c.add_child(scatola(Vector3(0.06, 0.03, 0.06), Vector3(x, 0.085, zp), "blocco"))
		c.add_child(scatola(Vector3(0.04, top - 0.2, 0.04), Vector3(x, 0.1 + (top - 0.2) * 0.5, zp), "calce"))
		for lato: int in [-1, 1]:
			c.add_child(cilindro(0.014, 0.014, 0.044, Vector3(x + lato * 0.022, top - 0.095, zp), "moneta", Vector3(90, 0, 0), 10))
		c.add_child(scatola(Vector3(0.07, 0.014, 0.046), Vector3(x, top - 0.075, zp), "calce"))
	c.add_child(scatola(Vector3(lx - 0.02, 0.05, 0.13), Vector3(0, top - 0.045, lz * 0.5 + 0.06), "muro_cb"))
	c.add_child(scatola(Vector3(lx - 0.02, 0.016, 0.004), Vector3(0, top - 0.045, lz * 0.5 + 0.127), "porpora_cb"))
	for k in 3:
		c.add_child(scatola(Vector3(lx + k * 0.016, 0.012, 0.13 + k * 0.012), Vector3(0, top - 0.014 + k * 0.012, lz * 0.5 + 0.06 + k * 0.004), "calce"))
	_fila_merli(c, Vector3(-lx * 0.5 + 0.03, top + 0.022, lz * 0.5 + 0.1), Vector3(lx * 0.5 - 0.03, top + 0.022, lz * 0.5 + 0.1), "calce", 0.72)
	# grande moneta d'oro col cavallo e la palma, sul lato destro
	var mo := Vector3(lx * 0.5 + 0.012, 0.3, 0.0)
	c.add_child(cilindro(0.075, 0.075, 0.014, mo, "moneta", Vector3(0, 0, 90), 24))
	c.add_child(cilindro(0.062, 0.062, 0.016, mo, "seta_oro", Vector3(0, 0, 90), 24))
	c.add_child(sfera(0.022, mo + Vector3(0.01, -0.01, 0.0), "bronzo", Vector3(0.4, 0.8, 1.6)))
	c.add_child(sfera(0.012, mo + Vector3(0.01, 0.012, 0.03), "bronzo", Vector3(0.4, 1, 1)))
	c.add_child(cilindro(0.004, 0.004, 0.06, mo + Vector3(0.01, 0.0, -0.035), "bronzo", Vector3.ZERO, 4))
	for k in 4:
		c.add_child(scatola(Vector3(0.004, 0.004, 0.025), mo + Vector3(0.01, 0.03, -0.035), "bronzo", Vector3(k * 45.0, 0, 0)))
	_stanzetta(c, Vector3(-0.12, top, -0.1), 0.3, 0.26, 0.13)
	_finestra_cb(c, Vector3(-0.12, top + 0.065, 0.03), 0.0, 0.05, 0.05)
	for k in 3:
		r.add_child(cassa(Vector3(0.45 + k * 0.12, 0, 0.42), k * 15, 0.1))
		r.add_child(cilindro(0.035, 0.035, 0.01, Vector3(0.45 + k * 0.12, 0.085, 0.42), "moneta", Vector3.ZERO, 10))
	r.add_child(mucchio(Vector3(0.62, 0.0, 0.2), "moneta", 7, 11, 0.02))
	r.add_child(cilindro(0.04, 0.05, 0.08, Vector3(-0.35, 0.04, 0.52), "corteccia", Vector3.ZERO, 10))
	r.add_child(scatola(Vector3(0.1, 0.035, 0.05), Vector3(-0.35, 0.095, 0.52), "ferro"))
	r.add_child(mucchio(Vector3(-0.62, 0, 0.25), "argento_grezzo", 8, 10))
	r.add_child(_mercenario_cb(Vector3(0.18, 0, 0.52), 0.85, 20))
	_stendardo_cb(r, Vector3(0.68, 0, -0.1), 0.55)
	return r


## Fabbro dei Cartaginesi: bottega color sabbia col camino, fucina all'aperto sotto la tenda di porpora,
## focolare di mattoni crudi, incudine, attrezzi appesi alla trave di cedro, vasca dell'acqua, lingotti, carbone.
static func fabbro_cartaginesi() -> Node3D:
	_mat_cb()
	var r := Node3D.new()
	var lx := 0.72
	var lz := 0.5
	var cs := _casa_cb(r, Vector3(-0.2, 0, -0.28), lx, lz, 0.36, 3821)
	var c: Node3D = cs[0]
	var top: float = cs[1]
	_porta_cb(c, Vector3(0.16, 0.07, lz * 0.5), 0.0, 0.13, 0.17)
	_finestra_cb(c, Vector3(-0.18, 0.28, lz * 0.5), 0.0)
	_finestra_cb(c, Vector3(lx * 0.5, 0.28, 0.0), 90.0)
	_camino_s(c, Vector3(-0.22, top, -0.05), 0.2)
	_tenda(r, Vector3(-0.22, 0, 0.42), 0.6, 0.3, 0.36, 0.3, 0.0, "tenda_porpora_cb", true)
	r.add_child(scatola(Vector3(0.2, 0.12, 0.16), Vector3(-0.38, 0.06, 0.42), "mattoni_crudi"))
	r.add_child(scatola(Vector3(0.22, 0.016, 0.18), Vector3(-0.38, 0.128, 0.42), "calce"))
	r.add_child(scatola(Vector3(0.14, 0.01, 0.1), Vector3(-0.38, 0.14, 0.42), "brace"))
	r.add_child(scatola(Vector3(0.06, 0.05, 0.012), Vector3(-0.38, 0.05, 0.505), "brace"))
	r.add_child(cilindro(0.04, 0.05, 0.08, Vector3(-0.05, 0.04, 0.45), "corteccia", Vector3.ZERO, 10))
	r.add_child(scatola(Vector3(0.12, 0.04, 0.05), Vector3(-0.05, 0.1, 0.45), "ferro"))
	r.add_child(scatola(Vector3(0.04, 0.025, 0.035), Vector3(0.03, 0.1, 0.45), "ferro"))
	r.add_child(scatola(Vector3(0.6, 0.018, 0.018), Vector3(-0.22, 0.27, 0.3), "cedro_cb"))
	for k in 4:
		var a := attrezzo(ATTREZZI_FABBRO[k])
		a.position = Vector3(-0.44 + k * 0.1, 0.19, 0.31)
		a.rotation_degrees = Vector3(90, 0, 90)
		r.add_child(a)
	_vasca_cb(r, Vector3(0.62, 0, 0.1), 0.075)
	for k in 3:
		r.add_child(scatola(Vector3(0.09, 0.025, 0.035), Vector3(0.45, 0.013 + k * 0.026, 0.5), "lingotto"))
	r.add_child(mucchio(Vector3(0.68, 0, -0.2), "carbone", 7, 12))
	return r


## Armaiolo dei Cartaginesi: la bottega del fabbro con la rastrelliera di lance dai pennoncelli di porpora,
## scudi ovali di porpora con l'umbone di bronzo, elmi di bronzo sul bancone e una spada sul ceppo.
static func armaiolo_cartaginesi() -> Node3D:
	var r := fabbro_cartaginesi()
	r.add_child(scatola(Vector3(0.28, 0.03, 0.05), Vector3(0.48, 0.015, 0.36), "cedro_cb"))
	r.add_child(scatola(Vector3(0.28, 0.02, 0.03), Vector3(0.48, 0.34, 0.35), "cedro_cb"))
	for k in 5:
		var x := 0.38 + k * 0.05
		r.add_child(cilindro(0.006, 0.006, 0.44, Vector3(x, 0.22, 0.36), "legno", Vector3.ZERO, 5))
		r.add_child(cilindro(0.009, 0.0, 0.04, Vector3(x, 0.46, 0.36), "ferro", Vector3.ZERO, 5))
		r.add_child(scatola(Vector3(0.004, 0.03, 0.04), Vector3(x, 0.41, 0.38), "porpora_cb"))
	for k in 2:
		_scudo_ovale(r, Vector3(0.72 + k * 0.03, 0.1, 0.22 + k * 0.17), Vector3(-12, 90, 0), 1.0)
	r.add_child(scatola(Vector3(0.12, 0.08, 0.26), Vector3(0.72, 0.04, -0.2), "cedro_cb"))
	for k in 2:
		r.add_child(sfera(0.04, Vector3(0.72, 0.1, -0.28 + k * 0.14), "bronzo", Vector3(1, 0.85, 1.05)))
		r.add_child(scatola(Vector3(0.01, 0.03, 0.06), Vector3(0.72, 0.145, -0.28 + k * 0.14), "porpora_cb"))
	var sp := Node3D.new()
	sp.position = Vector3(0.3, 0.12, 0.62)
	sp.rotation_degrees.y = 20
	r.add_child(sp)
	sp.add_child(scatola(Vector3(0.16, 0.006, 0.024), Vector3(0.04, 0, 0), "ferro"))
	sp.add_child(scatola(Vector3(0.008, 0.01, 0.06), Vector3(-0.045, 0, 0), "bronzo"))
	sp.add_child(cilindro(0.008, 0.008, 0.05, Vector3(-0.07, 0, 0), "cuoio", Vector3(0, 0, 90), 6))
	r.add_child(cilindro(0.06, 0.065, 0.11, Vector3(0.3, 0.055, 0.62), "corteccia", Vector3.ZERO, 12))
	return r


## Carbonaia dei Cartaginesi: casotto di mattoni crudi con le fascine sulla terrazza, cumulo di legna coperto
## di terra che fuma, legnaia, carbone pronto, sacco, anfora.
static func carbonaia_cartaginesi() -> Node3D:
	_mat_cb()
	var r := Node3D.new()
	var cs := _casa_cb(r, Vector3(-0.38, 0, -0.35), 0.4, 0.32, 0.2, 3831, "mattoni_crudi", false, true)
	var c: Node3D = cs[0]
	var top: float = cs[1]
	_porta_cb(c, Vector3(0.05, 0.07, 0.16), 0.0, 0.1, 0.11, true)
	for k in 3:
		c.add_child(cilindro(0.025, 0.025, 0.24, Vector3(-0.1 + k * 0.07, top + 0.025, -0.02), "paglia_scura", Vector3(90, 0, 0), 8))
	var m := Vector3(0.22, 0, 0.2)
	r.add_child(sfera(0.36, m, "terra", Vector3(1, 0.7, 1)))
	r.add_child(sfera(0.3, m + Vector3(0, 0.03, 0), "fuliggine", Vector3(1, 0.7, 1)))
	r.add_child(sfera(0.37, m + Vector3(0, -0.01, 0), "terra", Vector3(1, 0.68, 1)))
	for k in 5:
		r.add_child(sfera(0.05 + k * 0.012, m + Vector3(0.02 * k, 0.28 + k * 0.07, -0.01 * k), "fumo", Vector3(1, 0.8, 1)))
	r.add_child(scatola(Vector3(0.06, 0.04, 0.04), m + Vector3(0.0, 0.12, 0.33), "brace"))
	legnaia(r, Vector3(-0.55, 0, 0.35), 0.35, 4)
	r.add_child(mucchio(Vector3(0.62, 0, -0.25), "carbone", 12, 5))
	r.add_child(sacco(Vector3(0.6, 0, 0.55), 0.4))
	r.add_child(_anfora_giu(Vector3(-0.12, 0, 0.0), 140.0, 1.0))
	return r


## Fonderia dei Cartaginesi: bottega di mattoni crudi con la tenda di porpora, forno a torre di mattoni crudi
## cerchiato di calce e porpora con la bocca accesa, mantice di pelle, lingotti, carbone e minerale.
static func fonderia_cartaginesi() -> Node3D:
	_mat_cb()
	var r := Node3D.new()
	var lx := 0.66
	var lz := 0.52
	var cs := _casa_cb(r, Vector3(-0.25, 0, -0.25), lx, lz, 0.34, 3841, "mattoni_crudi", false, true)
	var c: Node3D = cs[0]
	var top: float = cs[1]
	_porta_cb(c, Vector3(-0.12, 0.07, lz * 0.5), 0.0, 0.14, 0.17, true)
	_finestra_cb(c, Vector3(0.16, 0.27, lz * 0.5), 0.0)
	_finestra_cb(c, Vector3(lx * 0.5, 0.27, 0.0), 90.0)
	_tenda(c, Vector3(0.08, top, -0.02), 0.3, 0.24, 0.16, 0.12, 0.0, "tenda_porpora_cb", true)
	var f := Vector3(0.42, 0, 0.38)
	r.add_child(cilindro(0.17, 0.2, 0.5, f + Vector3(0, 0.25, 0), "mattoni_crudi", Vector3.ZERO, 16))
	r.add_child(cilindro(0.19, 0.19, 0.025, f + Vector3(0, 0.14, 0), "calce", Vector3.ZERO, 16))
	r.add_child(cilindro(0.18, 0.18, 0.025, f + Vector3(0, 0.34, 0), "porpora_cb", Vector3.ZERO, 16))
	for k in 3:
		r.add_child(cilindro(0.17 + k * 0.012, 0.17 + k * 0.012, 0.014, f + Vector3(0, 0.47 + k * 0.014, 0), "calce", Vector3.ZERO, 16))
	r.add_child(cilindro(0.13, 0.15, 0.06, f + Vector3(0, 0.53, 0), "fuliggine", Vector3.ZERO, 16))
	r.add_child(scatola(Vector3(0.1, 0.1, 0.05), f + Vector3(-0.05, 0.12, 0.17), "brace", Vector3(0, 25, 0)))
	for k in 4:
		r.add_child(sfera(0.05 + k * 0.012, f + Vector3(0.0, 0.64 + k * 0.08, -0.01 * k), "fumo"))
	r.add_child(sfera(0.07, f + Vector3(-0.28, 0.1, 0.05), "pelle_scura", Vector3(1.4, 0.5, 1.0)))
	r.add_child(cilindro(0.01, 0.01, 0.12, f + Vector3(-0.18, 0.1, 0.05), "cedro_cb", Vector3(0, 0, 90), 5))
	for k in 6:
		r.add_child(scatola(Vector3(0.09, 0.025, 0.035), Vector3(-0.45 + (k % 3) * 0.1, 0.013 + (k / 3) * 0.026, 0.55), "lingotto"))
	r.add_child(mucchio(Vector3(-0.62, 0, 0.25), "carbone", 9, 6))
	r.add_child(mucchio(Vector3(0.7, 0, -0.1), "minerale", 9, 7))
	return r


## Torre di guardia dei Cartaginesi: fusto quadrato di mattoni crudi con la parte alta color sabbia, fascia di porpora
## e cornice a gola, finestre con la gola, porta rialzata con la scala di cedro, terrazza merlata a scalini con la tenda
## di porpora, il braciere, gli scudi ovali appesi e l'insegna; anfore e palma alla base.
static func torre_cartaginesi() -> Node3D:
	_mat_cb()
	var r := Node3D.new()
	var lato := 0.52
	var h := 1.2
	r.add_child(scatola(Vector3(lato + 0.16, 0.08, lato + 0.16), Vector3(0, 0.04, 0), "blocco"))
	r.add_child(scatola(Vector3(lato + 0.06, 0.16, lato + 0.06), Vector3(0, 0.16, 0), "mattoni_crudi"))
	r.add_child(scatola(Vector3(lato, h, lato), Vector3(0, 0.08 + h * 0.5, 0), "mattoni_crudi"))
	r.add_child(scatola(Vector3(lato + 0.006, 0.5, lato + 0.006), Vector3(0, 0.08 + h - 0.25, 0), "muro_cb"))
	r.add_child(scatola(Vector3(lato + 0.012, 0.03, lato + 0.012), Vector3(0, 0.08 + h - 0.5, 0), "calce"))
	r.add_child(scatola(Vector3(lato + 0.012, 0.03, lato + 0.012), Vector3(0, 0.08 + h - 0.1, 0), "porpora_cb"))
	var top := 0.08 + h
	for k in 3:
		var s := 0.014 + k * 0.02
		r.add_child(scatola(Vector3(lato + s, 0.016, lato + s), Vector3(0, top - 0.04 + k * 0.016, 0), "calce"))
	top += 0.008
	_finestra_cb(r, Vector3(0.1, 0.62, lato * 0.5), 0.0, 0.04, 0.08)
	_finestra_cb(r, Vector3(lato * 0.5, 0.62, 0.0), 90.0, 0.04, 0.08)
	for k: int in [-1, 1]:
		_finestra_cb(r, Vector3(k * 0.12, 0.96, lato * 0.5 + 0.003), 0.0, 0.06, 0.09)
		_finestra_cb(r, Vector3(lato * 0.5 + 0.003, 0.96, k * 0.12), 90.0, 0.06, 0.09)
	# porta rialzata con la scala di cedro
	_porta_cb(r, Vector3(-0.1, 0.3, lato * 0.5), 0.0, 0.12, 0.16)
	for lato_s: int in [-1, 1]:
		r.add_child(scatola(Vector3(0.016, 0.42, 0.016), Vector3(-0.1 + lato_s * 0.06, 0.17, lato * 0.5 + 0.13), "cedro_cb", Vector3(-28, 0, 0)))
	for k in 4:
		r.add_child(scatola(Vector3(0.12, 0.01, 0.014), Vector3(-0.1, 0.06 + k * 0.08, lato * 0.5 + 0.2 - k * 0.042), "cedro_cb"))
	# terrazza: pavimento, parapetto con i merli a scalini
	r.add_child(scatola(Vector3(lato + 0.04, 0.03, lato + 0.04), Vector3(0, top + 0.015, 0), "battuto"))
	_parapetto_s(r, lato + 0.08, lato + 0.08, top + 0.02, true, "calce", 0.05, 0.9)
	for k: int in [-1, 0, 1]:
		_scudo_ovale(r, Vector3(k * 0.16, top + 0.02, lato * 0.5 + 0.06), Vector3(-8, 0, 0), 0.75)
		_scudo_ovale(r, Vector3(lato * 0.5 + 0.06, top + 0.02, k * 0.16), Vector3(-8, 90, 0), 0.75)
	_tenda(r, Vector3(-0.06, top + 0.03, -0.06), 0.34, 0.3, 0.26, 0.2, 0.0, "tenda_porpora_cb", true)
	r.add_child(cilindro(0.04, 0.03, 0.08, Vector3(0.14, top + 0.07, 0.14), "bronzo", Vector3.ZERO, 8))
	r.add_child(sfera(0.035, Vector3(0.14, top + 0.12, 0.14), "brace", Vector3(1, 0.6, 1)))
	_fumo(r, Vector3(0.14, top + 0.18, 0.14), 3, 0.7)
	_stendardo_cb(r, Vector3(lato * 0.5, top + 0.02, -lato * 0.5 + 0.06), 0.5)
	r.add_child(_anfora_giu(Vector3(lato * 0.5 + 0.15, 0.0, 0.2), 180.0, 1.0))
	r.add_child(_anfora_giu(Vector3(lato * 0.5 + 0.16, 0.0, 0.09), 175.0, 1.0))
	r.add_child(cassa(Vector3(lato * 0.5 + 0.17, 0.0, -0.08), 10))
	_palma(r, Vector3(-lato * 0.5 - 0.12, 0, lato * 0.5 + 0.1), 0.6, 3851)
	return r


## Caserma dei Cartaginesi: edificio color sabbia merlato con due torrette ai lati della porta, campo d'addestramento
## di sabbia con il bersaglio, due mercenari libici che si esercitano, rastrelliera di lance con i pennoncelli di
## porpora, scudi ovali, insegne.
static func caserma_cartaginesi() -> Node3D:
	_mat_cb()
	var r := Node3D.new()
	var lx := 0.62
	var lz := 0.5
	var cs := _casa_cb(r, Vector3(-0.3, 0, -0.3), lx, lz, 0.36, 3861, "muro_cb", true, true)
	var c: Node3D = cs[0]
	var top: float = cs[1]
	_porta_cb(c, Vector3(0.0, 0.07, lz * 0.5), 0.0, 0.15, 0.18, false)
	_finestra_cb(c, Vector3(lx * 0.5, 0.29, 0.0), 90.0)
	for x: int in [-1, 1]:
		var p := Vector3(x * (lx * 0.5 - 0.02), 0, lz * 0.5 - 0.02)
		c.add_child(scatola(Vector3(0.13, top + 0.14, 0.13), p + Vector3(0, (top + 0.14) * 0.5, 0), "mattoni_crudi"))
		c.add_child(scatola(Vector3(0.134, 0.1, 0.134), p + Vector3(0, top + 0.06, 0), "muro_cb"))
		c.add_child(scatola(Vector3(0.138, 0.018, 0.138), p + Vector3(0, top + 0.02, 0), "porpora_cb"))
		for k in 3:
			c.add_child(scatola(Vector3(0.14 + k * 0.012, 0.01, 0.14 + k * 0.012), p + Vector3(0, top + 0.115 + k * 0.01, 0), "calce"))
		_parapetto_s(c, 0.17, 0.17, top + 0.14, true)
	_stendardo_cb(c, Vector3(lx * 0.5 - 0.02, top + 0.14, lz * 0.5 - 0.02), 0.42)
	_stendardo_cb(c, Vector3(-lx * 0.5 + 0.02, top + 0.14, lz * 0.5 - 0.02), 0.36)
	_tenda(c, Vector3(0.0, top, -0.08), 0.3, 0.22, 0.16, 0.12, 0.0, "tenda_porpora_cb", true)
	# campo d'addestramento
	r.add_child(scatola(Vector3(0.75, 0.01, 0.55), Vector3(0.25, 0.005, 0.4), "sabbia"))
	r.add_child(cilindro(0.025, 0.025, 0.36, Vector3(0.55, 0.18, 0.3), "cedro_cb", Vector3.ZERO, 8))
	r.add_child(cilindro(0.08, 0.08, 0.014, Vector3(0.55, 0.28, 0.34), "paglia", Vector3(90, 0, 0), 14))
	r.add_child(cilindro(0.045, 0.045, 0.016, Vector3(0.55, 0.28, 0.35), "porpora_cb", Vector3(90, 0, 0), 12))
	r.add_child(cilindro(0.018, 0.018, 0.018, Vector3(0.55, 0.28, 0.355), "calce", Vector3(90, 0, 0), 10))
	r.add_child(_mercenario_cb(Vector3(0.1, 0, 0.5), 0.9, 70))
	r.add_child(_mercenario_cb(Vector3(0.34, 0, 0.58), 0.9, -110))
	var rs := Vector3(-0.62, 0, 0.42)
	r.add_child(scatola(Vector3(0.03, 0.03, 0.3), rs + Vector3(0, 0.2, 0), "cedro_cb"))
	for lato: int in [-1, 1]:
		r.add_child(scatola(Vector3(0.03, 0.22, 0.03), rs + Vector3(0, 0.11, lato * 0.14), "cedro_cb"))
	for k in 4:
		var z := -0.11 + k * 0.073
		r.add_child(cilindro(0.005, 0.005, 0.48, rs + Vector3(-0.02, 0.24, z), "legno", Vector3(0, 0, -8), 5))
		r.add_child(cilindro(0.01, 0.0, 0.04, rs + Vector3(-0.054, 0.5, z), "ferro", Vector3(0, 0, -8), 5))
		r.add_child(scatola(Vector3(0.004, 0.03, 0.05), rs + Vector3(-0.05, 0.44, z + 0.025), "porpora_cb"))
	for k in 2:
		_scudo_ovale(r, Vector3(-0.46 + k * 0.12, 0.1, 0.64 - k * 0.03), Vector3(-15, 10, 0), 1.0)
	return r


## Fortezza punica (castello 3x3): mura di mattoni crudi con la fascia color sabbia e porpora, cornice a gola e merli
## a scalini, torri quadrate con le terrazze merlate, le tende di porpora e le insegne, porta fra due torri col segno
## di Tanit, palazzo a terrazze su due piani, torre di vedetta, tempietto con i pilastri e la gola, cisterna,
## palme da dattero, anfore a siluro.
static func castello_cartaginesi() -> Node3D:
	_mat_cb()
	var r := Node3D.new()
	var lato := 2.3
	var h := 0.5
	r.add_child(scatola(Vector3(lato + 0.3, 0.06, lato + 0.3), Vector3(0, 0.03, 0), "blocco"))
	r.add_child(scatola(Vector3(lato - 0.1, 0.008, lato - 0.1), Vector3(0, 0.064, 0), "sabbia"))
	var y0 := 0.06
	for i in 4:
		var m := Node3D.new()
		m.rotation_degrees.y = i * 90
		r.add_child(m)
		m.add_child(scatola(Vector3(lato, h, 0.16), Vector3(0, y0 + h * 0.5, lato * 0.5), "mattoni_crudi"))
		m.add_child(scatola(Vector3(lato + 0.004, 0.12, 0.164), Vector3(0, y0 + h - 0.08, lato * 0.5), "muro_cb"))
		m.add_child(scatola(Vector3(lato + 0.008, 0.024, 0.168), Vector3(0, y0 + h - 0.13, lato * 0.5), "porpora_cb"))
		for k in 3:
			m.add_child(scatola(Vector3(lato + 0.01, 0.014, 0.17 + k * 0.016), Vector3(0, y0 + h - 0.014 + k * 0.014, lato * 0.5), "calce"))
		_fila_merli(m, Vector3(-lato * 0.5, y0 + h + 0.028, lato * 0.5 + 0.06), Vector3(lato * 0.5, y0 + h + 0.028, lato * 0.5 + 0.06), "calce", 1.4)
		for k in 5:
			var x := -0.9 + k * 0.45
			if i == 0 and absf(x - 0.25) < 0.35:
				continue
			m.add_child(scatola(Vector3(0.05, h - 0.14, 0.012), Vector3(x, y0 + (h - 0.14) * 0.5, lato * 0.5 + 0.085), "muro_cb"))
	for x: int in [-1, 1]:
		for z: int in [-1, 1]:
			var p := Vector3(x * lato * 0.5, 0, z * lato * 0.5)
			var ht := h + 0.34
			r.add_child(scatola(Vector3(0.42, ht, 0.42), p + Vector3(0, y0 + ht * 0.5, 0), "mattoni_crudi"))
			r.add_child(scatola(Vector3(0.424, 0.2, 0.424), p + Vector3(0, y0 + ht - 0.12, 0), "muro_cb"))
			r.add_child(scatola(Vector3(0.43, 0.026, 0.43), p + Vector3(0, y0 + ht - 0.2, 0), "porpora_cb"))
			for k in 3:
				r.add_child(scatola(Vector3(0.43 + k * 0.016, 0.014, 0.43 + k * 0.016), p + Vector3(0, y0 + ht - 0.035 + k * 0.014, 0), "calce"))
			_finestra_cb(r, p + Vector3(0, y0 + ht - 0.3, 0.21), 0.0, 0.05, 0.08)
			_finestra_cb(r, p + Vector3(0.21, y0 + ht - 0.3, 0), 90.0, 0.05, 0.08)
			_parapetto_s(r, 0.47, 0.47, y0 + ht + 0.007, true, "calce", 0.04, 0.9)
			if x + z >= 0:
				_tenda(r, p + Vector3(-0.02, y0 + ht + 0.007, -0.02), 0.26, 0.24, 0.2, 0.15, 0.0, "tenda_porpora_cb", true)
			else:
				_stendardo_cb(r, p + Vector3(0.0, y0 + ht, 0.0), 0.45)
	# porta fra due torri sul lato in vista (+Z)
	var gx := 0.25
	var gz := lato * 0.5
	for k: int in [-1, 1]:
		var p := Vector3(gx + k * 0.3, 0, gz + 0.02)
		var hh := h + 0.24
		r.add_child(scatola(Vector3(0.24, hh, 0.28), p + Vector3(0, y0 + hh * 0.5, 0), "mattoni_crudi"))
		r.add_child(scatola(Vector3(0.244, 0.14, 0.284), p + Vector3(0, y0 + hh - 0.09, 0), "muro_cb"))
		r.add_child(scatola(Vector3(0.248, 0.022, 0.288), p + Vector3(0, y0 + hh - 0.16, 0), "porpora_cb"))
		for j in 3:
			r.add_child(scatola(Vector3(0.25 + j * 0.016, 0.014, 0.29 + j * 0.016), p + Vector3(0, y0 + hh - 0.03 + j * 0.014, 0), "calce"))
		_parapetto_s(r, 0.29, 0.33, y0 + hh + 0.012, true, "calce", 0.035)
		_stendardo_cb(r, p + Vector3(0, y0 + hh + 0.01, 0), 0.45)
		_scudo_ovale(r, p + Vector3(0, y0 + 0.36, 0.15), Vector3(-5, 0, 0), 0.9)
	r.add_child(scatola(Vector3(0.38, 0.16, 0.22), Vector3(gx, y0 + h - 0.02, gz + 0.03), "muro_cb"))
	var porta := Node3D.new()
	porta.position = Vector3(gx, y0, gz + 0.14)
	r.add_child(porta)
	_porta_cb(porta, Vector3.ZERO, 0.0, 0.22, 0.28, false)
	_tanit(porta, Vector3(0, 0.4, 0.004), 0.04, "porpora_cb")
	# palazzo a terrazze su due piani (dietro a sinistra)
	var pc := Node3D.new()
	pc.position = Vector3(-0.38, y0 - 0.07, -0.4)
	r.add_child(pc)
	var tp := _muri_cb(pc, 0.95, 0.8, 0.46, 3871, "muro_cb", false, true)
	_porta_cb(pc, Vector3(0.0, 0.07, 0.4), 0.0, 0.16, 0.19)
	for xx: float in [-0.3, 0.3]:
		_finestra_cb(pc, Vector3(xx, 0.32, 0.4), 0.0, 0.07, 0.08)
	_finestra_cb(pc, Vector3(0.475, 0.32, -0.18), 90.0, 0.07, 0.08)
	_finestra_cb(pc, Vector3(0.475, 0.32, 0.15), 90.0, 0.07, 0.08)
	var p2 := Node3D.new()
	p2.position = Vector3(-0.1, tp - 0.07, -0.1)
	pc.add_child(p2)
	var tp2 := _muri_cb(p2, 0.6, 0.5, 0.26, 3872, "calce", true, true)
	_finestra_cb(p2, Vector3(-0.12, 0.2, 0.25), 0.0, 0.06, 0.07)
	_finestra_cb(p2, Vector3(0.12, 0.2, 0.25), 0.0, 0.06, 0.07)
	_finestra_cb(p2, Vector3(0.3, 0.2, 0.0), 90.0, 0.06, 0.07)
	_tenda(p2, Vector3(0.0, tp2, -0.02), 0.36, 0.3, 0.2, 0.15, 0.0, "tenda_porpora_cb", true)
	_drappo(pc, Vector3(0.3, tp - 0.05, 0.42), 0.0, 0.14, 0.2)
	_drappo(pc, Vector3(-0.3, tp - 0.05, 0.42), 0.0, 0.14, 0.2)
	_tenda(pc, Vector3(0.32, tp, 0.2), 0.26, 0.28, 0.16, 0.12, 0.0, "tenda_porpora_cb", true)
	# torre di vedetta accanto al palazzo
	var tt := Vector3(0.55, y0, -0.7)
	r.add_child(scatola(Vector3(0.26, 1.0, 0.26), tt + Vector3(0, 0.5, 0), "mattoni_crudi"))
	r.add_child(scatola(Vector3(0.264, 0.32, 0.264), tt + Vector3(0, 0.84, 0), "muro_cb"))
	r.add_child(scatola(Vector3(0.27, 0.024, 0.27), tt + Vector3(0, 0.7, 0), "porpora_cb"))
	for k in 3:
		r.add_child(scatola(Vector3(0.27 + k * 0.016, 0.014, 0.27 + k * 0.016), tt + Vector3(0, 0.965 + k * 0.014, 0), "calce"))
	_finestra_cb(r, tt + Vector3(0, 0.84, 0.13), 0.0, 0.05, 0.07)
	_finestra_cb(r, tt + Vector3(0.13, 0.84, 0), 90.0, 0.05, 0.07)
	_parapetto_s(r, 0.31, 0.31, tt.y + 1.007, true, "calce", 0.035)
	_stendardo_cb(r, tt + Vector3(0.0, 1.0, 0.0), 0.5)
	# tempietto: podio, quattro pilastri di calce coi capitelli d'oro, gola col disco alato, betilo e altare
	var tm := Vector3(0.5, y0, 0.05)
	r.add_child(scatola(Vector3(0.5, 0.08, 0.4), tm + Vector3(0, 0.04, 0), "blocco"))
	r.add_child(scatola(Vector3(0.3, 0.04, 0.12), tm + Vector3(0, 0.02, 0.26), "blocco"))
	r.add_child(scatola(Vector3(0.4, 0.3, 0.2), tm + Vector3(0, 0.23, -0.08), "calce"))
	for xx: float in [-0.19, -0.07, 0.07, 0.19]:
		r.add_child(scatola(Vector3(0.04, 0.3, 0.04), tm + Vector3(xx, 0.23, 0.15), "calce"))
		r.add_child(cilindro(0.012, 0.012, 0.05, tm + Vector3(xx, 0.38, 0.16), "moneta", Vector3(0, 0, 90), 8))
	r.add_child(scatola(Vector3(0.48, 0.05, 0.4), tm + Vector3(0, 0.405, 0.0), "muro_cb"))
	r.add_child(scatola(Vector3(0.484, 0.016, 0.404), tm + Vector3(0, 0.41, 0.0), "porpora_cb"))
	for k in 3:
		r.add_child(scatola(Vector3(0.5 + k * 0.02, 0.016, 0.42 + k * 0.02), tm + Vector3(0, 0.438 + k * 0.016, 0), "calce"))
	r.add_child(sfera(0.03, tm + Vector3(0, 0.46, 0.22), "moneta", Vector3(1.2, 1, 0.4)))
	for lato_a: int in [-1, 1]:
		r.add_child(scatola(Vector3(0.06, 0.02, 0.006), tm + Vector3(lato_a * 0.06, 0.46, 0.215), "moneta"))
	r.add_child(scatola(Vector3(0.12, 0.2, 0.004), tm + Vector3(0, 0.2, 0.025), "buio"))
	var tn := Node3D.new()
	tn.position = tm + Vector3(0, 0.16, 0.03)
	r.add_child(tn)
	_tanit(tn, Vector3.ZERO, 0.03, "porpora_cb")
	r.add_child(scatola(Vector3(0.08, 0.07, 0.08), tm + Vector3(0.0, 0.035, 0.42), "blocco"))
	r.add_child(sfera(0.025, tm + Vector3(0.0, 0.085, 0.42), "brace", Vector3(1, 0.5, 1)))
	_fumo(r, tm + Vector3(0.0, 0.13, 0.42), 3, 0.6)
	# cortile: cisterna, palme, anfore, casse
	_vasca_cb(r, Vector3(-0.2, y0, 0.55), 0.12)
	_palma(r, Vector3(-0.75, y0, 0.6), 1.0, 3881)
	_palma(r, Vector3(-0.55, y0, 0.82), 0.85, 3882)
	_palma(r, Vector3(0.9, y0, 0.7), 0.95, 3883)
	_palma(r, Vector3(0.85, y0, -0.4), 0.8, 3884)
	_rastrelliera_anfore(r, Vector3(-0.85, y0, 0.15), 4, 90.0, 1.0)
	for k in 3:
		r.add_child(cassa(Vector3(0.15 + k * 0.13, y0, 0.75), k * 20))
	r.add_child(_anfora_giu(Vector3(0.6, y0, 0.78), 110.0, 1.1))
	return r
