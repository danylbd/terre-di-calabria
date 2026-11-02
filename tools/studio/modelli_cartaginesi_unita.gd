extends "res://tools/studio/modelli.gd"
## Modelli dei Cartaginesi (step 37, docs/cartaginesi.md): parte «unita». Lo studio unisce catalogo_extra()
## di ogni file tools/studio/modelli_*.gd al catalogo di modelli.gd.
## Qui: mercenario libico, Annibale sull'elefante (condottiero), elefante da guerra, icone della porpora e
## degli elefanti, tintoria della porpora e stalla degli elefanti.

const CELLA_ELEFANTE := Vector2i(168, 136)
const ANCORA_ELEFANTE := Vector2(64, 106)


static func catalogo_extra() -> Dictionary:
	var c := {}
	c["mercenario_cartaginese"] = {"crea": mercenario_cartaginese, "posa": posa_cammino,
		"fotogrammi": 8, "direzioni": 8, "dimensione": Vector2i(96, 96), "ancora": Vector2(42, 80)}
	c["mercenario_cartaginese_lotta"] = {"crea": mercenario_cartaginese, "posa": posa_lotta,
		"fotogrammi": 8, "direzioni": 8, "dimensione": Vector2i(96, 96), "ancora": Vector2(42, 80)}
	c["condottiero_cartaginesi"] = {"crea": annibale_elefante, "posa": posa_elefante_passo,
		"fotogrammi": 8, "direzioni": 8, "dimensione": CELLA_ELEFANTE, "ancora": ANCORA_ELEFANTE}
	c["condottiero_cartaginesi_lotta"] = {"crea": annibale_elefante, "posa": posa_elefante_carica,
		"fotogrammi": 8, "direzioni": 8, "dimensione": CELLA_ELEFANTE, "ancora": ANCORA_ELEFANTE}
	c["elefante_guerra"] = {"crea": elefante_guerra, "posa": posa_elefante_passo,
		"fotogrammi": 8, "direzioni": 8, "dimensione": CELLA_ELEFANTE, "ancora": ANCORA_ELEFANTE}
	c["elefante_guerra_lotta"] = {"crea": elefante_guerra, "posa": posa_elefante_carica,
		"fotogrammi": 8, "direzioni": 8, "dimensione": CELLA_ELEFANTE, "ancora": ANCORA_ELEFANTE}
	c["merce_porpora"] = {"crea": merce_cartaginese.bind("porpora")}
	c["merce_elefanti"] = {"crea": merce_cartaginese.bind("elefanti")}
	c["tintoria_porpora_cartaginesi"] = {"crea": tintoria_porpora_cartaginesi}
	c["stalla_elefanti_cartaginesi"] = {"crea": stalla_elefanti_cartaginesi}
	return c


# ------------------------------------------------------------------ materiali propri (porpora, elefante, cedro)

## Registra nella cache dei materiali di modelli.gd i materiali dei Cartaginesi (prefisso «ctu_»), così le
## funzioni scatola/cilindro/sfera li trovano per nome. Stesso trattamento «vissuto» degli altri materiali.
static func _materiali_ct() -> void:
	if _cache_mat.has("ctu_porpora"):
		return
	_registra("ctu_porpora", _rumore(371, 0.35, Color("4e0b37"), Color("8c1f5e")), 1.0, [0.0, 0.0, 1.2])
	_registra("ctu_porpora_scura", _rumore(372, 0.3, Color("2e0620"), Color("561040")), 1.0, [0.0, 0.0, 1.15])
	_registra("ctu_porpora_chiara", _rumore(373, 0.3, Color("8a2468"), Color("b84a8e")), 1.0, [0.0, 0.0, 1.2])
	_registra("ctu_elefante", _rumore(374, 0.22, Color("5e5a58"), Color("8e8882")), 2.0, [0.05, 0.25, 1.0])
	_registra("ctu_elefante_scuro", _rumore(375, 0.25, Color("3e3b3a"), Color("605b58")), 2.0, [0.05, 0.2, 1.0])
	_registra("ctu_avorio", _rumore(376, 0.2, Color("e2d6b8"), Color("fff9e8")), 1.0, [0.0, 0.05, 1.0])
	_registra("ctu_cedro", _rumore(377, 0.14, Color("3c200f"), Color("6e3c1c")), 1.0, [0.15, 0.25, 1.1], Vector3(1, 5, 1))
	_registra("ctu_sabbia", _rumore(378, 0.08, Color("c0965c"), Color("e2c08a")), 2.0, [0.4, 0.35, 1.05])
	_registra("ctu_murice", _rumore(379, 0.45, Color("9a7656"), Color("e2c8a4")), 1.0, [0.05, 0.1, 1.0])
	_registra("ctu_tinta", null, 1.0, [], Vector3.ONE, Color("6e0f4c"))


static func _registra(nome: String, tex: Texture2D, scala: float, reg: Array, uv := Vector3.ONE, colore := Color.WHITE) -> void:
	var m := StandardMaterial3D.new()
	m.uv1_triplanar = true
	m.roughness = 0.9
	if tex == null:
		# liquido della tintura: lucido, semplice
		m.albedo_color = colore
		m.roughness = 0.12
		m.metallic = 0.25
		_cache_mat[nome] = m
		return
	m.albedo_texture = tex
	m.uv1_scale = uv * scala
	var sm := _a_vissuto(m, nome)
	sm.set_shader_parameter("sporco", reg[0])
	sm.set_shader_parameter("macchie", reg[1])
	sm.set_shader_parameter("saturazione", reg[2])
	_cache_mat[nome] = sm


# ------------------------------------------------------------------ piccoli pezzi cartaginesi

## Segno di Tanit dipinto: triangolo, braccia orizzontali alzate alle punte, disco sopra. pos = centro del
## segno; il segno sta nel piano XY locale e guarda verso +Z locale (rot_y lo gira).
static func _tanit(r: Node3D, pos: Vector3, rot_y := 0.0, s := 1.0, mat := "calce") -> void:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot_y
	n.scale = Vector3.ONE * s
	r.add_child(n)
	var tri := cilindro(0.03, 0.0, 0.05, Vector3(0, -0.012, 0), mat, Vector3.ZERO, 4)
	tri.scale = Vector3(1.0, 1.0, 0.12)
	n.add_child(tri)
	n.add_child(scatola(Vector3(0.06, 0.008, 0.004), Vector3(0, 0.016, 0), mat))
	for lato: int in [-1, 1]:
		n.add_child(scatola(Vector3(0.008, 0.014, 0.004), Vector3(lato * 0.03, 0.022, 0), mat))
	n.add_child(scatola(Vector3(0.008, 0.012, 0.004), Vector3(0, 0.024, 0), mat))
	n.add_child(cilindro(0.013, 0.013, 0.005, Vector3(0, 0.041, 0), mat, Vector3(90, 0, 0), 12))


## Anfora punica «a siluro»: lunga, stretta, con il puntale e due piccole anse. pos = base; rot = inclinazione.
static func _anfora_punica(pos: Vector3, rot := Vector3.ZERO, s := 1.0) -> Node3D:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees = rot
	n.scale = Vector3.ONE * s
	n.add_child(cilindro(0.004, 0.022, 0.05, Vector3(0, 0.025, 0), "terracotta", Vector3.ZERO, 8))
	n.add_child(cilindro(0.026, 0.028, 0.14, Vector3(0, 0.12, 0), "terracotta", Vector3.ZERO, 10))
	n.add_child(sfera(0.028, Vector3(0, 0.19, 0), "terracotta", Vector3(1, 0.55, 1)))
	n.add_child(cilindro(0.012, 0.014, 0.025, Vector3(0, 0.215, 0), "terracotta", Vector3.ZERO, 8))
	n.add_child(_toro(0.009, 0.015, Vector3(0, 0.228, 0), "terracotta"))
	for lato: int in [-1, 1]:
		n.add_child(_toro(0.006, 0.011, Vector3(lato * 0.026, 0.175, 0), "terracotta", Vector3(90, 0, 0), Vector3(1, 1, 1.3)))
	n.add_child(cilindro(0.0285, 0.0285, 0.01, Vector3(0, 0.15, 0), "vernice_rossa", Vector3.ZERO, 10))
	return n


## Cornice «a gola» (cavetto egizio) sopra una porta o una finestra della faccia +Z: listello e gola sporgente.
static func _gola_z(r: Node3D, x: float, y: float, zf: float, w: float, mat := "calce") -> void:
	r.add_child(scatola(Vector3(w + 0.03, 0.014, 0.02), Vector3(x, y + 0.007, zf + 0.008), mat))
	r.add_child(scatola(Vector3(w + 0.05, 0.022, 0.016), Vector3(x, y + 0.025, zf + 0.018), mat, Vector3(-38, 0, 0)))
	r.add_child(scatola(Vector3(w + 0.06, 0.008, 0.03), Vector3(x, y + 0.039, zf + 0.022), mat))


## La stessa cornice a gola sulla faccia +X.
static func _gola_x(r: Node3D, z: float, y: float, xf: float, w: float, mat := "calce") -> void:
	r.add_child(scatola(Vector3(0.02, 0.014, w + 0.03), Vector3(xf + 0.008, y + 0.007, z), mat))
	r.add_child(scatola(Vector3(0.016, 0.022, w + 0.05), Vector3(xf + 0.018, y + 0.025, z), mat, Vector3(0, 0, 38)))
	r.add_child(scatola(Vector3(0.03, 0.008, w + 0.06), Vector3(xf + 0.022, y + 0.039, z), mat))


## Casa punica: mattoni crudi intonacati color sabbia, zoccolo e fascia di calce, tetto piatto a terrazza con
## parapetto (e a richiesta i merli a scalini), travi di cedro sporgenti, porta di cedro con il segno di Tanit e
## la cornice a gola, finestrelle, tenda porpora a righe sulla porta. pos = centro a terra; porta sulla faccia +Z.
static func _casa_punica(r: Node3D, pos: Vector3, lx: float, lz: float, h: float, seme := 1, merli := false, tenda := true) -> Node3D:
	var n := Node3D.new()
	n.position = pos
	r.add_child(n)
	n.add_child(scatola(Vector3(lx + 0.03, 0.05, lz + 0.03), Vector3(0, 0.025, 0), "calce"))
	n.add_child(scatola(Vector3(lx, h, lz), Vector3(0, h * 0.5, 0), "ctu_sabbia"))
	n.add_child(scatola(Vector3(lx + 0.02, 0.03, lz + 0.02), Vector3(0, h - 0.015, 0), "calce"))
	n.add_child(scatola(Vector3(lx + 0.04, 0.02, lz + 0.04), Vector3(0, h + 0.01, 0), "calce"))
	var nt := int(lx / 0.08)
	for k in nt:
		n.add_child(scatola(Vector3(0.018, 0.018, 0.03), Vector3(-lx * 0.5 + (k + 0.5) * lx / nt, h - 0.045, lz * 0.5 + 0.012), "ctu_cedro"))
	var hp := 0.045
	for lato: int in [-1, 1]:
		n.add_child(scatola(Vector3(lx + 0.04, hp, 0.025), Vector3(0, h + 0.02 + hp * 0.5, lato * (lz * 0.5 + 0.0075)), "calce"))
		n.add_child(scatola(Vector3(0.025, hp, lz + 0.04), Vector3(lato * (lx * 0.5 + 0.0075), h + 0.02 + hp * 0.5, 0), "calce"))
	if merli:
		var y := h + 0.02 + hp
		_fila_merli(n, Vector3(-lx * 0.5, y, lz * 0.5 + 0.0075), Vector3(lx * 0.5, y, lz * 0.5 + 0.0075), "calce", 0.6)
		_fila_merli(n, Vector3(lx * 0.5 + 0.0075, y, lz * 0.5), Vector3(lx * 0.5 + 0.0075, y, -lz * 0.5), "calce", 0.6)
	# porta di cedro con Tanit e la gola sopra
	var zf := lz * 0.5
	var px := -lx * 0.18
	n.add_child(scatola(Vector3(0.13, 0.22, 0.012), Vector3(px, 0.14, zf + 0.002), "calce"))
	n.add_child(scatola(Vector3(0.1, 0.2, 0.014), Vector3(px, 0.13, zf + 0.004), "ctu_cedro"))
	for k in 3:
		n.add_child(scatola(Vector3(0.1, 0.008, 0.016), Vector3(px, 0.07 + k * 0.06, zf + 0.005), "legno_scuro"))
	_tanit(n, Vector3(px, 0.15, zf + 0.013), 0.0, 0.9, "calce")
	_gola_z(n, px, 0.25, zf, 0.13)
	# finestrelle con la gola
	var fx := lx * 0.25
	n.add_child(scatola(Vector3(0.06, 0.07, 0.012), Vector3(fx, h * 0.62, zf + 0.002), "buio"))
	n.add_child(scatola(Vector3(0.07, 0.012, 0.02), Vector3(fx, h * 0.62 - 0.04, zf + 0.008), "calce"))
	_gola_z(n, fx, h * 0.62 + 0.035, zf, 0.06)
	for k in 2:
		var z := -lz * 0.25 + k * lz * 0.5
		n.add_child(scatola(Vector3(0.012, 0.07, 0.06), Vector3(lx * 0.5 + 0.002, h * 0.62, z), "buio"))
		_gola_x(n, z, h * 0.62 + 0.035, lx * 0.5, 0.06)
	if tenda:
		# tenda porpora a righe bianche sopra la porta, su due pali di cedro
		for lato: int in [-1, 1]:
			n.add_child(cilindro(0.007, 0.007, 0.25, Vector3(px + lato * 0.09, 0.125, zf + 0.12), "ctu_cedro", Vector3.ZERO, 5))
		for k in 5:
			var m := "ctu_porpora" if k % 2 == 0 else "calce"
			n.add_child(scatola(Vector3(0.04, 0.006, 0.15), Vector3(px - 0.08 + k * 0.04, 0.28, zf + 0.06), m, Vector3(-16, 0, 0)))
			n.add_child(scatola(Vector3(0.04, 0.03, 0.005), Vector3(px - 0.08 + k * 0.04, 0.25, zf + 0.135), m))
	# qualche crepa nell'intonaco
	var rng := _rng(seme)
	for k in 3:
		n.add_child(scatola(Vector3(0.05, 0.03, 0.004), Vector3(rng.randf_range(lx * 0.0, lx * 0.4), rng.randf_range(0.08, h - 0.08), zf + 0.001), "mattoni_crudi"))
	return n


## Conchiglia di murice: corpo a fuso con le spine, bocca porpora. pos = centro; rot_y = direzione della punta.
static func _murice(pos: Vector3, rot_y := 0.0, s := 1.0) -> Node3D:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot_y
	n.scale = Vector3.ONE * s
	n.add_child(sfera(0.022, Vector3.ZERO, "ctu_murice", Vector3(1.0, 0.9, 1.3)))
	n.add_child(cilindro(0.016, 0.0, 0.045, Vector3(0, 0.003, 0.04), "ctu_murice", Vector3(80, 0, 0), 7))
	n.add_child(cilindro(0.006, 0.0, 0.04, Vector3(0, -0.002, -0.042), "ctu_murice", Vector3(-95, 0, 0), 6))
	for k in 6:
		var a := k * TAU / 6
		n.add_child(cilindro(0.004, 0.0, 0.016, Vector3(cos(a) * 0.022, sin(a) * 0.018 + 0.004, 0.0), "ctu_murice", Vector3(0, 0, rad_to_deg(a) - 90), 4))
	n.add_child(sfera(0.012, Vector3(0.012, 0.004, -0.005), "ctu_porpora_chiara", Vector3(0.6, 0.9, 1.6)))
	return n


# ------------------------------------------------------------------ mercenario libico

## Scudo ovale grande dei mercenari: campo porpora, orlo di calce, Tanit dorato e umbone di bronzo.
static func _scudo_ovale(pos: Vector3, rot_y := 0.0, s := 1.0) -> Node3D:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot_y
	n.scale = Vector3.ONE * s
	var campo := Node3D.new()
	campo.scale = Vector3(0.72, 1.18, 1.0)
	n.add_child(campo)
	campo.add_child(cilindro(0.1, 0.1, 0.012, Vector3.ZERO, "ctu_porpora", Vector3(90, 0, 0), 20))
	campo.add_child(_toro(0.094, 0.104, Vector3.ZERO, "calce", Vector3(90, 0, 0)))
	campo.add_child(_toro(0.07, 0.076, Vector3(0, 0, 0.007), "stoffa_oro", Vector3(90, 0, 0)))
	_tanit(n, Vector3(0, 0.0, 0.012), 0.0, 0.85, "oro_n")
	n.add_child(sfera(0.016, Vector3(0, -0.055, 0.01), "bronzo", Vector3(1, 1, 0.6)))
	return n


## Mercenario libico: tunica bianca con l'orlo porpora, cinturone, mantellina porpora, elmo semplice di bronzo
## con i paraguance, grande scudo ovale dipinto e lancia.
static func mercenario_cartaginese() -> Node3D:
	_materiali_ct()
	var r := portatore("", "ctu_porpora", "lino_bianco")
	var corpo: Node3D = r.get_node("corpo")
	var anca := 0.2
	corpo.add_child(cilindro(0.082, 0.082, 0.018, Vector3(0, anca + 0.055, 0), "cuoio", Vector3.ZERO, 12))
	corpo.add_child(sfera(0.01, Vector3(0, anca + 0.055, 0.083), "bronzo"))
	corpo.add_child(scatola(Vector3(0.02, 0.2, 0.006), Vector3(0.0, anca + 0.12, 0.072), "cuoio", Vector3(0, 0, -36)))
	corpo.add_child(sfera(0.07, Vector3(0, anca + 0.165, -0.02), "ctu_porpora", Vector3(1.25, 0.38, 1.0)))
	corpo.add_child(scatola(Vector3(0.12, 0.12, 0.01), Vector3(0, anca + 0.1, -0.085), "ctu_porpora", Vector3(10, 0, 0)))
	corpo.add_child(sfera(0.044, Vector3(0, anca + 0.215, 0.045), "capelli", Vector3(1.0, 0.8, 0.6)))
	corpo.add_child(sfera(0.081, Vector3(0, anca + 0.28, -0.006), "bronzo", Vector3(1, 0.78, 1.05)))
	corpo.add_child(cilindro(0.084, 0.085, 0.012, Vector3(0, anca + 0.262, -0.006), "bronzo", Vector3.ZERO, 14))
	corpo.add_child(cilindro(0.012, 0.016, 0.03, Vector3(0, anca + 0.35, -0.006), "bronzo", Vector3.ZERO, 8))
	corpo.add_child(sfera(0.012, Vector3(0, anca + 0.37, -0.006), "ctu_porpora"))
	for lato: int in [-1, 1]:
		corpo.add_child(scatola(Vector3(0.01, 0.05, 0.035), Vector3(lato * 0.077, anca + 0.235, 0.025), "bronzo"))
	var bs: Node3D = corpo.get_node("braccio_s")
	bs.add_child(_scudo_ovale(Vector3(-0.035, -0.07, 0.04), -90.0, 1.15))
	var bd: Node3D = corpo.get_node("braccio_d")
	bd.add_child(cilindro(0.007, 0.007, 0.54, Vector3(0, 0.07, 0.02), "legno", Vector3.ZERO, 5))
	bd.add_child(cilindro(0.016, 0.0, 0.065, Vector3(0, 0.37, 0.02), "ferro", Vector3.ZERO, 6))
	bd.add_child(cilindro(0.009, 0.009, 0.02, Vector3(0, 0.33, 0.02), "ctu_porpora", Vector3.ZERO, 6))
	bd.add_child(cilindro(0.008, 0.0, 0.03, Vector3(0, -0.215, 0.02), "bronzo", Vector3(180, 0, 0), 5))
	r.set_meta("carico", "lancia")
	return r


# ------------------------------------------------------------------ elefante

## Elefante da guerra (avanti verso +Z): corpo grigio, zampe a colonna con le unghie d'avorio, testa con le
## grandi orecchie, zanne, proboscide in sei pezzi (nodi «pr_0»… che si piegano), gualdrappa con l'orlo e le
## frange d'oro. Nodi animati: corpo, zampe (con «stinco»), testa, orecchie, proboscide.
static func _elefante(gualdrappa := "ctu_porpora", orlo := "stoffa_oro", segno := true) -> Node3D:
	_materiali_ct()
	var r := Node3D.new()
	var corpo := Node3D.new()
	corpo.name = "corpo"
	r.add_child(corpo)
	var hy := 0.34
	for nome in ["zampa_as", "zampa_ad", "zampa_ps", "zampa_pd"]:
		var davanti: bool = nome.begins_with("zampa_a")
		var lato := -1.0 if nome.ends_with("s") else 1.0
		var z := Node3D.new()
		z.name = nome
		z.position = Vector3(lato * 0.095, hy, 0.15 if davanti else -0.15)
		corpo.add_child(z)
		z.add_child(cilindro(0.06, 0.05, 0.2, Vector3(0, -0.08, 0), "ctu_elefante", Vector3.ZERO, 10))
		var st := Node3D.new()
		st.name = "stinco"
		st.position = Vector3(0, -0.17, 0)
		z.add_child(st)
		st.add_child(cilindro(0.047, 0.052, 0.14, Vector3(0, -0.07, 0), "ctu_elefante", Vector3.ZERO, 10))
		st.add_child(cilindro(0.057, 0.059, 0.03, Vector3(0, -0.155, 0.004), "ctu_elefante_scuro", Vector3.ZERO, 12))
		for k in 3:
			st.add_child(sfera(0.012, Vector3((k - 1) * 0.026, -0.158, 0.052), "ctu_avorio", Vector3(1, 0.8, 0.6)))
		st.add_child(_toro(0.044, 0.054, Vector3(0, -0.005, 0), "ctu_elefante_scuro", Vector3.ZERO, Vector3(1, 0.6, 1)))
	# corpo, pancia, garrese e groppa
	corpo.add_child(sfera(0.2, Vector3(0, 0.46, -0.01), "ctu_elefante", Vector3(0.86, 0.8, 1.3)))
	corpo.add_child(sfera(0.16, Vector3(0, 0.4, 0.0), "ctu_elefante", Vector3(0.95, 0.75, 1.25)))
	corpo.add_child(sfera(0.13, Vector3(0, 0.52, 0.13), "ctu_elefante", Vector3(1.05, 0.9, 1.0)))
	corpo.add_child(sfera(0.14, Vector3(0, 0.5, -0.15), "ctu_elefante", Vector3(1.05, 0.95, 1.0)))
	# coda con il ciuffo
	corpo.add_child(cilindro(0.012, 0.007, 0.2, Vector3(0, 0.42, -0.285), "ctu_elefante", Vector3(-12, 0, 0), 6))
	corpo.add_child(sfera(0.015, Vector3(0, 0.32, -0.3), "crine", Vector3(1, 1.6, 1)))
	# testa (nodo che si alza)
	var testa := Node3D.new()
	testa.name = "testa"
	testa.position = Vector3(0, 0.52, 0.22)
	corpo.add_child(testa)
	testa.add_child(sfera(0.13, Vector3(0, 0.0, 0.1), "ctu_elefante", Vector3(0.9, 1.0, 0.95)))
	testa.add_child(sfera(0.07, Vector3(0, 0.07, 0.12), "ctu_elefante", Vector3(1.2, 0.8, 1.0)))
	testa.add_child(sfera(0.07, Vector3(0, -0.06, 0.17), "ctu_elefante", Vector3(0.9, 1.0, 0.9)))
	for lato: int in [-1, 1]:
		testa.add_child(sfera(0.013, Vector3(lato * 0.078, 0.025, 0.17), "vernice_nera"))
		testa.add_child(sfera(0.006, Vector3(lato * 0.082, 0.03, 0.178), "calce"))
		var o := Node3D.new()
		o.name = "orecchio_s" if lato < 0 else "orecchio_d"
		o.position = Vector3(lato * 0.09, 0.03, 0.07)
		o.rotation_degrees.y = lato * 18.0
		testa.add_child(o)
		o.add_child(sfera(0.12, Vector3(lato * 0.012, -0.035, -0.06), "ctu_elefante", Vector3(0.16, 1.0, 0.85)))
		o.add_child(sfera(0.1, Vector3(lato * 0.02, -0.035, -0.055), "ctu_elefante_scuro", Vector3(0.1, 0.9, 0.75)))
		# zanne d'avorio, puntate in avanti e poi in su, con l'anello d'oro
		var base := Vector3(lato * 0.05, -0.08, 0.2)
		var d1 := Vector3(0, -sin(deg_to_rad(20.0)), cos(deg_to_rad(20.0)))
		testa.add_child(cilindro(0.015, 0.011, 0.09, base + d1 * 0.045, "ctu_avorio", Vector3(110, 0, 0), 8))
		var b2 := base + d1 * 0.088
		var d2 := Vector3(0, sin(deg_to_rad(35.0)), cos(deg_to_rad(35.0)))
		testa.add_child(cilindro(0.011, 0.002, 0.08, b2 + d2 * 0.04, "ctu_avorio", Vector3(55, 0, 0), 8))
		testa.add_child(_toro(0.013, 0.02, base, "oro_n", Vector3(110, 0, 0)))
	# proboscide a pezzi
	var padre: Node3D = testa
	var raggi := [0.042, 0.036, 0.031, 0.026, 0.021, 0.017, 0.013]
	for k in 6:
		var seg := Node3D.new()
		seg.name = "pr_%d" % k
		seg.position = Vector3(0, -0.07, 0.24) if k == 0 else Vector3(0, -0.058, 0)
		padre.add_child(seg)
		seg.add_child(cilindro(raggi[k + 1], raggi[k], 0.062, Vector3(0, -0.029, 0), "ctu_elefante", Vector3.ZERO, 10))
		if k % 2 == 1:
			seg.add_child(_toro(raggi[k] * 0.85, raggi[k] * 1.08, Vector3(0, -0.01, 0), "ctu_elefante_scuro", Vector3.ZERO, Vector3(1, 0.5, 1)))
		padre = seg
	padre.add_child(sfera(0.016, Vector3(0, -0.06, 0.004), "ctu_elefante_scuro", Vector3(1, 0.7, 1)))
	# frontale porpora con il disco d'oro
	testa.add_child(scatola(Vector3(0.09, 0.1, 0.012), Vector3(0, 0.05, 0.205), gualdrappa, Vector3(-18, 0, 0)))
	testa.add_child(cilindro(0.022, 0.022, 0.006, Vector3(0, 0.055, 0.214), orlo, Vector3(72, 0, 0), 12))
	testa.add_child(scatola(Vector3(0.094, 0.012, 0.016), Vector3(0, 0.0, 0.22), orlo, Vector3(-18, 0, 0)))
	# gualdrappa: telo che avvolge il dorso, pannelli che scendono sui fianchi, orli e frange d'oro
	var telo := cilindro(0.182, 0.182, 0.26, Vector3(0, 0.47, -0.02), gualdrappa, Vector3(90, 0, 0), 22)
	telo.scale = Vector3(1, 1, 0.9)
	corpo.add_child(telo)
	for zz: float in [-0.15, 0.11]:
		corpo.add_child(_toro(0.172, 0.19, Vector3(0, 0.47, zz), orlo, Vector3(90, 0, 0), Vector3(1, 0.5, 0.9)))
	for lato: int in [-1, 1]:
		var x := lato * 0.186
		corpo.add_child(scatola(Vector3(0.012, 0.12, 0.26), Vector3(x, 0.41, -0.02), gualdrappa))
		corpo.add_child(scatola(Vector3(0.014, 0.016, 0.262), Vector3(x, 0.352, -0.02), orlo))
		corpo.add_child(scatola(Vector3(0.014, 0.01, 0.262), Vector3(x, 0.462, -0.02), orlo))
		for k in 9:
			corpo.add_child(cilindro(0.006, 0.003, 0.028, Vector3(x, 0.33, -0.136 + k * 0.029), "oro_n", Vector3.ZERO, 4))
		if segno:
			_tanit(corpo, Vector3(x + lato * 0.008, 0.405, -0.02), lato * 90.0, 1.1, "stoffa_oro")
	r.set_meta("carico", "elefante")
	return r


## Annibale in groppa all'elefante: mantello porpora, corazza di bronzo, elmo col cimiero, benda sull'occhio,
## spada; sulla schiena lo stendardo col colore del giocatore e il segno di Tanit.
static func annibale_elefante() -> Node3D:
	var r := _elefante("ctu_porpora", "stoffa_oro")
	var corpo: Node3D = r.get_node("corpo")
	# sella-cuscino
	corpo.add_child(scatola(Vector3(0.2, 0.04, 0.2), Vector3(0, 0.66, -0.02), "ctu_porpora_scura"))
	corpo.add_child(scatola(Vector3(0.206, 0.012, 0.206), Vector3(0, 0.682, -0.02), "stoffa_oro"))
	var cav := portatore("", "giocatore", "lino_bianco")
	cav.name = "cavaliere"
	cav.scale = Vector3.ONE * 1.05
	cav.position = Vector3(0, 0.69 - 0.2 * 1.05, 0.0)
	corpo.add_child(cav)
	var cc: Node3D = cav.get_node("corpo")
	var anca := 0.2
	(cc.get_node("gamba_s") as Node3D).rotation = Vector3(-1.1, 0, -1.0)
	(cc.get_node("gamba_d") as Node3D).rotation = Vector3(-1.1, 0, 1.0)
	# corazza di bronzo anatomica e frange porpora
	cc.add_child(cilindro(0.088, 0.072, 0.13, Vector3(0, anca + 0.1, 0), "bronzo", Vector3.ZERO, 12))
	for lato: int in [-1, 1]:
		cc.add_child(sfera(0.03, Vector3(lato * 0.03, anca + 0.135, 0.06), "bronzo", Vector3(1.1, 0.8, 0.6)))
	for k in 7:
		var a := deg_to_rad(-75.0 + k * 25.0)
		cc.add_child(scatola(Vector3(0.022, 0.05, 0.006), Vector3(sin(a) * 0.088, anca + 0.015, cos(a) * 0.088), "ctu_porpora", Vector3(0, rad_to_deg(a), 0)))
	# barba nera, elmo di bronzo col cimiero porpora, benda sull'occhio
	cc.add_child(sfera(0.046, Vector3(0, anca + 0.212, 0.045), "capelli", Vector3(1.0, 0.95, 0.65)))
	cc.add_child(sfera(0.081, Vector3(0, anca + 0.285, -0.008), "bronzo", Vector3(1, 0.78, 1.05)))
	cc.add_child(cilindro(0.084, 0.085, 0.012, Vector3(0, anca + 0.265, -0.008), "oro_n", Vector3.ZERO, 14))
	for lato: int in [-1, 1]:
		cc.add_child(scatola(Vector3(0.01, 0.05, 0.04), Vector3(lato * 0.077, anca + 0.235, 0.02), "bronzo"))
	cc.add_child(scatola(Vector3(0.016, 0.03, 0.15), Vector3(0, anca + 0.36, -0.01), "oro_n"))
	for k in 7:
		var z := -0.075 + k * 0.025
		cc.add_child(sfera(0.022, Vector3(0, anca + 0.39 - absf(z) * 0.4, z), "ctu_porpora", Vector3(0.55, 1.25, 0.9)))
	cc.add_child(sfera(0.02, Vector3(0, anca + 0.33, -0.095), "ctu_porpora", Vector3(0.55, 2.0, 0.8)))
	cc.add_child(_toro(0.073, 0.079, Vector3(0, anca + 0.255, 0.0), "vernice_nera", Vector3(-14, 0, 0), Vector3(1, 1.4, 1)))
	cc.add_child(sfera(0.02, Vector3(0.03, anca + 0.255, 0.07), "vernice_nera", Vector3(1.1, 0.9, 0.5)))
	_mantello(cc, "ctu_porpora", "oro_n", "stoffa_oro")
	_stendardo(cc, "", "oro_n", "lancia")
	var st: Node3D = cc.get_node("stendardo")
	_tanit(st, Vector3(0, 0.86 - 0.14, 0.009), 0.0, 1.05, "stoffa_oro")
	_tanit(st, Vector3(0, 0.86 - 0.14, -0.006), 180.0, 1.05, "stoffa_oro")
	# spada nella destra (nodo inclinato in avanti e in basso), redini nella sinistra
	var bd: Node3D = cc.get_node("braccio_d")
	var sp := Node3D.new()
	sp.name = "spada"
	sp.position = Vector3(0, -0.14, 0.0)
	sp.rotation_degrees.x = 45
	bd.add_child(sp)
	sp.add_child(scatola(Vector3(0.012, 0.022, 0.2), Vector3(0, 0, 0.12), "spada"))
	sp.add_child(cilindro(0.011, 0.0, 0.03, Vector3(0, 0, 0.235), "spada", Vector3(90, 0, 0), 4))
	sp.add_child(scatola(Vector3(0.06, 0.014, 0.014), Vector3(0, 0, 0.016), "oro_n"))
	sp.add_child(scatola(Vector3(0.013, 0.015, 0.035), Vector3(0, 0, -0.008), "pelle_scura"))
	sp.add_child(sfera(0.012, Vector3(0, 0, -0.03), "oro_n"))
	r.set_meta("carico", "spada")
	return r


## Elefante da guerra: il conducente seduto sul collo con il pungolo, sulla schiena una torretta di cedro con
## gli scudi appesi e un arciere dentro.
static func elefante_guerra() -> Node3D:
	var r := _elefante("ctu_porpora_scura", "stoffa_oro", false)
	var corpo: Node3D = r.get_node("corpo")
	var anca := 0.2
	# conducente sul collo, turbante bianco e porpora, pungolo
	var con := portatore("", "ctu_porpora", "lino_bianco")
	con.name = "conducente"
	con.scale = Vector3.ONE * 0.8
	con.position = Vector3(0, 0.67 - 0.2 * 0.8, 0.19)
	corpo.add_child(con)
	var cc: Node3D = con.get_node("corpo")
	(cc.get_node("gamba_s") as Node3D).rotation = Vector3(-1.0, 0, -0.9)
	(cc.get_node("gamba_d") as Node3D).rotation = Vector3(-1.0, 0, 0.9)
	cc.add_child(sfera(0.08, Vector3(0, anca + 0.29, -0.005), "lino_bianco", Vector3(1.05, 0.7, 1.05)))
	cc.add_child(_toro(0.065, 0.082, Vector3(0, anca + 0.275, -0.005), "ctu_porpora", Vector3(-6, 0, 0), Vector3(1, 1.3, 1)))
	var bd: Node3D = cc.get_node("braccio_d")
	bd.add_child(cilindro(0.005, 0.005, 0.26, Vector3(0, -0.14, 0.09), "legno", Vector3(70, 0, 0), 4))
	bd.add_child(cilindro(0.008, 0.0, 0.03, Vector3(0, -0.098, 0.215), "ferro", Vector3(70, 0, 0), 5))
	# torretta: pianale, sponde di cedro, angoli col pomo d'oro, scudi ovali appesi, cinghie
	var tor := Node3D.new()
	tor.name = "torretta"
	tor.position = Vector3(0, 0.63, -0.08)
	corpo.add_child(tor)
	tor.add_child(scatola(Vector3(0.27, 0.025, 0.25), Vector3(0, 0.0125, 0), "ctu_cedro"))
	var ht := 0.11
	for lato: int in [-1, 1]:
		tor.add_child(scatola(Vector3(0.27, ht, 0.016), Vector3(0, 0.025 + ht * 0.5, lato * 0.117), "ctu_cedro"))
		tor.add_child(scatola(Vector3(0.016, ht, 0.25), Vector3(lato * 0.127, 0.025 + ht * 0.5, 0), "ctu_cedro"))
		tor.add_child(scatola(Vector3(0.28, 0.014, 0.022), Vector3(0, 0.025 + ht, lato * 0.117), "legno_chiaro"))
		tor.add_child(scatola(Vector3(0.022, 0.014, 0.26), Vector3(lato * 0.127, 0.025 + ht, 0), "legno_chiaro"))
		for lz: int in [-1, 1]:
			tor.add_child(cilindro(0.012, 0.012, ht + 0.06, Vector3(lato * 0.127, 0.025 + (ht + 0.06) * 0.5, lz * 0.117), "legno_scuro", Vector3.ZERO, 6))
			tor.add_child(sfera(0.014, Vector3(lato * 0.127, 0.025 + ht + 0.065, lz * 0.117), "oro_n"))
		for k in 2:
			tor.add_child(_scudo_ovale(Vector3(lato * 0.138, 0.08, -0.055 + k * 0.11), lato * 90.0, 0.55))
		corpo.add_child(scatola(Vector3(0.008, 0.2, 0.025), Vector3(lato * 0.19, 0.53, -0.08), "cuoio"))
	tor.add_child(_scudo_ovale(Vector3(0, 0.08, 0.128), 0.0, 0.55))
	tor.add_child(_scudo_ovale(Vector3(0, 0.08, -0.128), 180.0, 0.55))
	# arciere nella torretta
	var arc := portatore("", "ctu_porpora", "lino_bianco")
	arc.name = "arciere"
	arc.scale = Vector3.ONE * 0.82
	arc.position = Vector3(0, 0.025, -0.01)
	tor.add_child(arc)
	var ac: Node3D = arc.get_node("corpo")
	ac.add_child(sfera(0.081, Vector3(0, anca + 0.282, -0.006), "bronzo", Vector3(1, 0.75, 1.05)))
	ac.add_child(cilindro(0.012, 0.015, 0.025, Vector3(0, anca + 0.345, -0.006), "bronzo", Vector3.ZERO, 6))
	ac.add_child(sfera(0.012, Vector3(0, anca + 0.365, -0.006), "ctu_porpora"))
	ac.add_child(sfera(0.044, Vector3(0, anca + 0.215, 0.045), "capelli", Vector3(1.0, 0.8, 0.6)))
	var a_bs: Node3D = ac.get_node("braccio_s")
	var arco := Node3D.new()
	arco.name = "arco"
	arco.position = Vector3(0, -0.14, 0.0)
	a_bs.add_child(arco)
	for k in 6:
		var a0 := deg_to_rad(-60.0 + k * 20.0)
		var a1 := deg_to_rad(-60.0 + (k + 1) * 20.0)
		var p0 := Vector3(sin(a0) * 0.12, 0, cos(a0) * 0.04)
		var p1 := Vector3(sin(a1) * 0.12, 0, cos(a1) * 0.04)
		ramo(arco, p0, p1, 0.007, "legno_scuro")
	arco.add_child(cilindro(0.0015, 0.0015, 0.21, Vector3(0, 0, 0.02), "corda", Vector3(0, 0, 90), 3))
	ac.add_child(cilindro(0.022, 0.02, 0.13, Vector3(0.05, anca + 0.17, -0.08), "cuoio", Vector3(0, 0, -20), 8))
	for k in 3:
		ac.add_child(cilindro(0.003, 0.003, 0.05, Vector3(0.07 + k * 0.006, anca + 0.25, -0.08 + (k - 1) * 0.008), "ctu_porpora" if k == 1 else "calce", Vector3(0, 0, -20), 3))
	r.set_meta("carico", "elefante")
	return r


## Passo pesante dell'elefante: le zampe si muovono una alla volta (prima quella di dietro, poi quella davanti
## dello stesso lato), il corpo ondeggia di lato, la proboscide dondola, le orecchie sventolano; chi sta sopra
## segue il dondolio.
static func posa_elefante_passo(modello: Node3D, fotogramma: int, totale: int) -> void:
	var t := float(fotogramma) / totale * TAU
	var corpo: Node3D = modello.get_node("corpo")
	corpo.position = Vector3(0, absf(sin(t)) * 0.008, 0)
	corpo.rotation = Vector3(0, 0, sin(t) * 0.025)
	var fasi := {"zampa_ps": 0.0, "zampa_as": PI * 0.5, "zampa_pd": PI, "zampa_ad": PI * 1.5}
	for nome: String in fasi:
		var z: Node3D = corpo.get_node(nome)
		var f: float = t + fasi[nome]
		var davanti := nome.begins_with("zampa_a")
		z.rotation.x = -sin(f) * 0.3
		(z.get_node("stinco") as Node3D).rotation.x = maxf(0.0, cos(f)) * (0.55 if davanti else -0.35)
	var testa: Node3D = corpo.get_node("testa")
	testa.rotation.x = sin(t * 2.0) * 0.03
	(testa.get_node("orecchio_s") as Node3D).rotation.y = deg_to_rad(-18.0) - sin(t) * 0.18
	(testa.get_node("orecchio_d") as Node3D).rotation.y = deg_to_rad(18.0) - sin(t) * 0.18
	var seg: Node3D = testa.get_node("pr_0")
	for k in 6:
		seg.rotation = Vector3((-0.32 if k == 0 else 0.07) - (0.06 if k == 5 else 0.0), 0, sin(t + k * 0.6) * 0.09)
		if k < 5:
			seg = seg.get_node("pr_%d" % (k + 1))
	_posa_cavalieri(corpo, t, 0.0)


## Carica dell'elefante: si solleva sulle zampe di dietro alzando quelle davanti, la testa in su, le orecchie
## aperte e la proboscide arrotolata verso l'alto; Annibale alza la spada (o il conducente il pungolo e
## l'arciere tende l'arco).
static func posa_elefante_carica(modello: Node3D, fotogramma: int, totale: int) -> void:
	var t := float(fotogramma) / totale * TAU
	var alza := 0.5 - 0.5 * cos(t)
	var corpo: Node3D = modello.get_node("corpo")
	var beccheggio := -0.16 * alza
	corpo.rotation = Vector3(beccheggio, 0, 0)
	# ruota attorno ai piedi di dietro, che restano a terra
	corpo.position = Vector3(0, 0.15 * sin(-beccheggio), 0)
	for nome in ["zampa_as", "zampa_ad"]:
		var z: Node3D = corpo.get_node(nome)
		var k := 0.0 if nome == "zampa_as" else 0.35
		var a := clampf(alza + (k - 0.17) * sin(t), 0.0, 1.0)
		z.rotation.x = -0.75 * a
		(z.get_node("stinco") as Node3D).rotation.x = 0.95 * a
	for nome in ["zampa_ps", "zampa_pd"]:
		var z: Node3D = corpo.get_node(nome)
		z.rotation.x = -beccheggio + 0.05
		(z.get_node("stinco") as Node3D).rotation.x = 0.0
	var testa: Node3D = corpo.get_node("testa")
	testa.rotation.x = -0.25 * alza
	(testa.get_node("orecchio_s") as Node3D).rotation.y = deg_to_rad(-18.0) - 0.5 * alza
	(testa.get_node("orecchio_d") as Node3D).rotation.y = deg_to_rad(18.0) + 0.5 * alza
	var seg: Node3D = testa.get_node("pr_0")
	for k in 6:
		var base := -0.32 if k == 0 else 0.07
		var su := -0.42 - (0.12 if k >= 4 else 0.0)
		seg.rotation = Vector3(lerpf(base, su, alza), 0, sin(t + k) * 0.04)
		if k < 5:
			seg = seg.get_node("pr_%d" % (k + 1))
	_posa_cavalieri(corpo, t, alza)


## Pose di chi sta sull'elefante: Annibale (spada), il conducente (pungolo) e l'arciere (arco).
static func _posa_cavalieri(corpo: Node3D, t: float, colpo: float) -> void:
	if corpo.has_node("cavaliere"):
		var cc: Node3D = corpo.get_node("cavaliere/corpo")
		cc.rotation = Vector3(0.04 + colpo * 0.1, 0, -sin(t) * 0.03)
		var bd: Node3D = cc.get_node("braccio_d")
		bd.rotation = Vector3(lerpf(-0.45 + sin(t) * 0.05, -2.75 + sin(t * 2.0) * 0.2, colpo), 0, 0.15)
		(cc.get_node("braccio_s") as Node3D).rotation = Vector3(-0.7, 0, -0.2)
	if corpo.has_node("conducente"):
		var cc: Node3D = corpo.get_node("conducente/corpo")
		cc.rotation = Vector3(0.1 + colpo * 0.1, 0, -sin(t) * 0.03)
		(cc.get_node("braccio_d") as Node3D).rotation = Vector3(-0.6 - colpo * 1.4 + sin(t) * 0.05, 0, 0.15)
		(cc.get_node("braccio_s") as Node3D).rotation = Vector3(-0.8, 0, -0.15)
	if corpo.has_node("torretta/arciere"):
		var ac: Node3D = corpo.get_node("torretta/arciere/corpo")
		ac.rotation = Vector3(0, 0, -sin(t) * 0.03)
		var bs: Node3D = ac.get_node("braccio_s")
		var bd: Node3D = ac.get_node("braccio_d")
		bs.rotation = Vector3(lerpf(-0.5, -1.5, colpo), 0, -0.15)
		bd.rotation = Vector3(lerpf(-0.4, -1.35, colpo), 0, lerpf(0.15, 0.55, colpo))
		bd.position.z = -0.035 * colpo


# ------------------------------------------------------------------ icone delle merci

## Icone delle merci cartaginesi, nello stesso stile di merce(): porpora (stoffe e un murice) ed elefanti.
static func merce_cartaginese(tipo: String) -> Node3D:
	_materiali_ct()
	var r := Node3D.new()
	match tipo:
		"porpora":
			r.add_child(scatola(Vector3(0.15, 0.022, 0.1), Vector3(-0.01, 0.011, -0.01), "ctu_porpora_scura", Vector3(0, 20, 0)))
			r.add_child(scatola(Vector3(0.14, 0.022, 0.095), Vector3(-0.012, 0.033, -0.008), "ctu_porpora", Vector3(0, 24, 0)))
			r.add_child(scatola(Vector3(0.142, 0.006, 0.097), Vector3(-0.012, 0.045, -0.008), "stoffa_oro", Vector3(0, 24, 0)))
			r.add_child(cilindro(0.032, 0.032, 0.17, Vector3(0.0, 0.08, 0.005), "ctu_porpora_chiara", Vector3(90, 60, 0), 14))
			r.add_child(cilindro(0.033, 0.033, 0.012, Vector3(0.0, 0.08, 0.005), "stoffa_oro", Vector3(90, 60, 0), 14))
			r.add_child(_murice(Vector3(0.07, 0.022, 0.07), 140.0, 1.5))
		"elefanti":
			var e := _elefante("ctu_porpora", "stoffa_oro", false)
			e.scale = Vector3.ONE * 0.33
			e.rotation_degrees.y = -50
			var seg: Node3D = e.get_node("corpo/testa/pr_0")
			for k in 6:
				seg.rotation.x = -0.3 if k == 0 else 0.08
				if k < 5:
					seg = seg.get_node("pr_%d" % (k + 1))
			r.add_child(e)
	r.scale = Vector3.ONE * 1.25
	return r


# ------------------------------------------------------------------ edifici propri

## Tintoria della porpora: casa punica con la terrazza, tre vasche di pietra con la tintura porpora, caldaia
## sul fuoco, mucchio di conchiglie di murice, stoffe porpora stese ad asciugare, anfore puniche e una palma.
static func tintoria_porpora_cartaginesi() -> Node3D:
	_materiali_ct()
	var r := Node3D.new()
	var casa := _casa_punica(r, Vector3(-0.3, 0, -0.3), 0.56, 0.42, 0.36, 381, true)
	# sulla terrazza: telaio con le stoffe ad asciugare
	for lato: int in [-1, 1]:
		casa.add_child(cilindro(0.007, 0.007, 0.16, Vector3(lato * 0.2, 0.36 + 0.1, -0.08), "ctu_cedro", Vector3.ZERO, 5))
	casa.add_child(cilindro(0.005, 0.005, 0.42, Vector3(0, 0.36 + 0.18, -0.08), "ctu_cedro", Vector3(0, 0, 90), 5))
	casa.add_child(scatola(Vector3(0.16, 0.12, 0.008), Vector3(-0.09, 0.36 + 0.115, -0.08), "ctu_porpora"))
	casa.add_child(scatola(Vector3(0.14, 0.1, 0.008), Vector3(0.09, 0.36 + 0.125, -0.08), "ctu_porpora_chiara"))
	# tre vasche di pietra con la tintura, bordo di calce
	for k in 3:
		var p := Vector3(-0.5 + k * 0.27, 0, 0.3)
		r.add_child(scatola(Vector3(0.22, 0.09, 0.18), p + Vector3(0, 0.045, 0), "blocchi_greci"))
		r.add_child(scatola(Vector3(0.235, 0.014, 0.195), p + Vector3(0, 0.095, 0), "calce"))
		r.add_child(scatola(Vector3(0.18, 0.006, 0.14), p + Vector3(0, 0.1, 0), "ctu_tinta" if k != 1 else "ctu_porpora_chiara"))
		if k == 0:
			r.add_child(cilindro(0.005, 0.005, 0.24, p + Vector3(0.04, 0.17, 0.02), "legno_chiaro", Vector3(30, 0, -20), 4))
			r.add_child(scatola(Vector3(0.03, 0.05, 0.006), p + Vector3(0.0, 0.1, -0.02), "legno_chiaro", Vector3(30, 0, -20)))
		if k == 2:
			r.add_child(scatola(Vector3(0.08, 0.008, 0.07), p + Vector3(0.06, 0.106, 0.07), "ctu_porpora", Vector3(0, 10, 0)))
			r.add_child(scatola(Vector3(0.08, 0.07, 0.006), p + Vector3(0.06, 0.07, 0.1), "ctu_porpora", Vector3(0, 10, 0)))
	# caldaia di bronzo sul fuoco dove la tintura cuoce
	var cp := Vector3(0.3, 0, -0.32)
	_fuoco(r, cp, 1.1)
	r.add_child(cilindro(0.09, 0.075, 0.1, cp + Vector3(0, 0.1, 0), "bronzo", Vector3.ZERO, 16))
	r.add_child(_toro(0.085, 0.097, cp + Vector3(0, 0.15, 0), "bronzo"))
	r.add_child(cilindro(0.082, 0.082, 0.006, cp + Vector3(0, 0.148, 0), "ctu_tinta", Vector3.ZERO, 16))
	for k in 3:
		var a := k * TAU / 3 + 0.4
		r.add_child(cilindro(0.012, 0.012, 0.1, cp + Vector3(cos(a) * 0.08, 0.045, sin(a) * 0.08), "pietra", Vector3.ZERO, 6))
	_fumo(r, cp + Vector3(0, 0.22, 0), 3, 0.9)
	# mucchio di conchiglie di murice e ceste piene
	var rng := _rng(382)
	var mc := Vector3(0.6, 0, -0.05)
	r.add_child(sfera(0.12, mc, "sabbia", Vector3(1.1, 0.4, 1.1)))
	for k in 16:
		var a := rng.randf() * TAU
		var d := sqrt(rng.randf()) * 0.12
		var y := 0.025 + (0.12 - d) * 0.3 + rng.randf() * 0.01
		r.add_child(_murice(mc + Vector3(cos(a) * d, y, sin(a) * d), rng.randf() * 360.0, 1.35))
	for k in 2:
		var cpos := Vector3(0.48 + k * 0.2, 0, 0.22 + k * 0.05)
		r.add_child(cilindro(0.055, 0.045, 0.06, cpos + Vector3(0, 0.03, 0), "canne", Vector3.ZERO, 12))
		for j in 5:
			var a := j * TAU / 5
			r.add_child(_murice(cpos + Vector3(cos(a) * 0.025, 0.065, sin(a) * 0.025), j * 70.0, 0.85))
	# stenditoio con le stoffe porpora ad asciugare
	var sx := Vector3(0.25, 0, 0.06)
	for lato: int in [-1, 1]:
		r.add_child(cilindro(0.01, 0.012, 0.36, sx + Vector3(lato * 0.2, 0.18, 0), "ctu_cedro", Vector3.ZERO, 6))
	r.add_child(cilindro(0.007, 0.007, 0.46, sx + Vector3(0, 0.34, 0), "ctu_cedro", Vector3(0, 0, 90), 6))
	var teli := ["ctu_porpora", "ctu_porpora_chiara", "ctu_porpora_scura", "ctu_porpora"]
	for k in 4:
		var x := -0.15 + k * 0.1
		var hh := 0.16 + (k % 2) * 0.04
		r.add_child(scatola(Vector3(0.085, hh, 0.006), sx + Vector3(x, 0.34 - hh * 0.5, 0.004 * (k % 2)), teli[k]))
		r.add_child(scatola(Vector3(0.085, 0.01, 0.008), sx + Vector3(x, 0.34 - hh + 0.02, 0.004 * (k % 2)), "stoffa_oro"))
	# anfore puniche piantate nella sabbia
	r.add_child(_anfora_punica(Vector3(-0.66, 0, 0.0), Vector3(0, 0, 8), 1.2))
	r.add_child(_anfora_punica(Vector3(-0.6, 0, 0.08), Vector3(-6, 0, -4), 1.1))
	r.add_child(_anfora_punica(Vector3(-0.7, 0, 0.1), Vector3(0, 0, 12), 1.05))
	_palma(r, Vector3(0.66, 0, -0.38), 0.85, 383)
	# insegna: pezza porpora appesa a un palo con Tanit
	r.add_child(cilindro(0.01, 0.012, 0.42, Vector3(0.78, 0.21, 0.42), "ctu_cedro", Vector3.ZERO, 6))
	r.add_child(cilindro(0.006, 0.006, 0.14, Vector3(0.78, 0.4, 0.47), "ctu_cedro", Vector3(90, 0, 0), 5))
	r.add_child(scatola(Vector3(0.006, 0.13, 0.09), Vector3(0.78, 0.33, 0.5), "ctu_porpora"))
	_tanit(r, Vector3(0.785, 0.33, 0.5), 90.0, 1.1, "stoffa_oro")
	return r


## Stalla degli elefanti: grande recinto di cedro, tettoia di cedro a terrazza con il drappo porpora, un
## elefante dentro, fieno e mangiatoia, abbeveratoio di pietra, casetta del guardiano e una palma.
static func stalla_elefanti_cartaginesi() -> Node3D:
	_materiali_ct()
	var r := Node3D.new()
	r.add_child(scatola(Vector3(1.5, 0.008, 1.06), Vector3(0.0, 0.004, 0.08), "battuto"))
	# recinto: pali e tre correnti (davanti con il varco del cancello)
	var x0 := -0.75
	var x1 := 0.75
	var z0 := -0.45
	var z1 := 0.6
	var lati := [[Vector3(x0, 0, z1), Vector3(x1, 0, z1)], [Vector3(x1, 0, z0), Vector3(x1, 0, z1)], [Vector3(x0, 0, -0.12), Vector3(x0, 0, z1)]]
	for i in lati.size():
		var da: Vector3 = lati[i][0]
		var a: Vector3 = lati[i][1]
		var lung := da.distance_to(a)
		var np := int(lung / 0.15)
		for k in np + 1:
			var p := da.lerp(a, float(k) / np)
			if i == 0 and absf(p.x - 0.2) < 0.12:
				continue
			r.add_child(cilindro(0.016, 0.018, 0.22, p + Vector3(0, 0.11, 0), "ctu_cedro", Vector3.ZERO, 6))
			r.add_child(sfera(0.016, p + Vector3(0, 0.225, 0), "ctu_cedro"))
		for j in 3:
			var y := 0.06 + j * 0.065
			if i == 0:
				for tratto: Array in [[x0, 0.08], [0.32, x1]]:
					var sa := Vector3(tratto[0], y, z1)
					var sb := Vector3(tratto[1], y, z1)
					r.add_child(scatola(Vector3(absf(sb.x - sa.x), 0.018, 0.014), (sa + sb) * 0.5, "legno"))
			else:
				r.add_child(scatola(Vector3(0.014, 0.018, lung), (da + a) * 0.5 + Vector3(0, y, 0), "legno"))
	# cancello aperto con il segno di Tanit
	r.add_child(scatola(Vector3(0.012, 0.17, 0.22), Vector3(0.32, 0.1, z1 + 0.11), "ctu_cedro"))
	_tanit(r, Vector3(0.328, 0.12, z1 + 0.11), 90.0, 1.0, "calce")
	# tettoia di cedro sul fondo: pali, terrazza di calce con i merli a scalini, travi sporgenti
	var tx := 0.12
	var tz := -0.2
	var lx := 0.95
	var lz := 0.44
	var h := 0.56
	for xx: float in [-lx * 0.5, 0.0, lx * 0.5]:
		for zz: float in [tz - lz * 0.5, tz + lz * 0.5]:
			r.add_child(cilindro(0.022, 0.026, h, Vector3(tx + xx, h * 0.5, zz), "ctu_cedro", Vector3.ZERO, 8))
			r.add_child(scatola(Vector3(0.06, 0.03, 0.06), Vector3(tx + xx, h - 0.01, zz), "calce"))
	r.add_child(scatola(Vector3(lx + 0.12, 0.03, lz + 0.1), Vector3(tx, h + 0.015, tz), "ctu_cedro"))
	r.add_child(scatola(Vector3(lx + 0.14, 0.02, lz + 0.12), Vector3(tx, h + 0.04, tz), "terra_cruda"))
	for lato: int in [-1, 1]:
		r.add_child(scatola(Vector3(lx + 0.14, 0.022, 0.025), Vector3(tx, h + 0.04, tz + lato * (lz * 0.5 + 0.05)), "calce"))
		r.add_child(scatola(Vector3(0.025, 0.022, lz + 0.12), Vector3(tx + lato * (lx * 0.5 + 0.06), h + 0.04, tz), "calce"))
	var nt := 11
	for k in nt:
		r.add_child(scatola(Vector3(0.02, 0.02, lz + 0.16), Vector3(tx - lx * 0.5 + k * lx / (nt - 1), h - 0.005, tz), "legno_scuro"))
	var yt := h + 0.05
	_fila_merli(r, Vector3(tx - lx * 0.5 - 0.06, yt, tz + lz * 0.5 + 0.05), Vector3(tx + lx * 0.5 + 0.06, yt, tz + lz * 0.5 + 0.05), "calce", 0.75)
	_fila_merli(r, Vector3(tx + lx * 0.5 + 0.06, yt, tz + lz * 0.5 + 0.05), Vector3(tx + lx * 0.5 + 0.06, yt, tz - lz * 0.5 - 0.05), "calce", 0.75)
	# drappo porpora a teli alterni con l'orlo d'oro, sul davanti e sul fianco
	var fz := tz + lz * 0.5 + 0.06
	for k in 6:
		var x := tx - lx * 0.5 + (k + 0.5) * lx / 6
		r.add_child(scatola(Vector3(lx / 6 - 0.01, 0.07, 0.008), Vector3(x, h - 0.045, fz), "ctu_porpora" if k % 2 == 0 else "ctu_porpora_chiara"))
		r.add_child(scatola(Vector3(lx / 6 - 0.01, 0.012, 0.01), Vector3(x, h - 0.085, fz), "stoffa_oro"))
	for k in 3:
		var z := tz - lz * 0.5 + (k + 0.5) * lz / 3
		r.add_child(scatola(Vector3(0.008, 0.07, lz / 3 - 0.01), Vector3(tx + lx * 0.5 + 0.07, h - 0.045, z), "ctu_porpora" if k % 2 == 0 else "ctu_porpora_chiara"))
		r.add_child(scatola(Vector3(0.01, 0.012, lz / 3 - 0.01), Vector3(tx + lx * 0.5 + 0.07, h - 0.085, z), "stoffa_oro"))
	# muro di fondo intonacato sotto la tettoia
	r.add_child(scatola(Vector3(lx, 0.3, 0.05), Vector3(tx, 0.15, tz - lz * 0.5), "ctu_sabbia"))
	r.add_child(scatola(Vector3(lx + 0.02, 0.02, 0.06), Vector3(tx, 0.31, tz - lz * 0.5), "calce"))
	# fieno sotto la tettoia e mangiatoia di cedro
	var rng := _rng(391)
	for k in 5:
		var p := Vector3(tx - 0.38 + k * 0.08 + rng.randf_range(-0.02, 0.02), 0.04, tz - 0.1 + rng.randf_range(-0.04, 0.04))
		r.add_child(sfera(0.075, p, "paglia", Vector3(1.2, 0.65, 1.0)))
	r.add_child(scatola(Vector3(0.36, 0.09, 0.1), Vector3(tx + 0.18, 0.08, tz - 0.13), "ctu_cedro"))
	r.add_child(scatola(Vector3(0.32, 0.03, 0.07), Vector3(tx + 0.18, 0.12, tz - 0.13), "paglia"))
	# l'elefante, di profilo, beve all'abbeveratoio
	var e := _elefante("ctu_porpora", "stoffa_oro", true)
	e.scale = Vector3.ONE * 0.82
	e.position = Vector3(0.18, 0, 0.14)
	e.rotation_degrees.y = -45
	var seg: Node3D = e.get_node("corpo/testa/pr_0")
	for k in 6:
		seg.rotation.x = -0.35 if k == 0 else (0.12 if k < 4 else -0.15)
		if k < 5:
			seg = seg.get_node("pr_%d" % (k + 1))
	r.add_child(e)
	# abbeveratoio di pietra con l'acqua
	var ab := Vector3(-0.28, 0, 0.45)
	r.add_child(scatola(Vector3(0.36, 0.08, 0.13), ab + Vector3(0, 0.04, 0), "blocchi_greci"))
	r.add_child(scatola(Vector3(0.37, 0.012, 0.14), ab + Vector3(0, 0.085, 0), "calce"))
	r.add_child(scatola(Vector3(0.32, 0.004, 0.09), ab + Vector3(0, 0.088, 0), "acqua_pozzo"))
	r.add_child(_anfora_punica(ab + Vector3(-0.24, 0, -0.04), Vector3(0, 0, -10), 1.15))
	# casetta del guardiano accanto al recinto e palma
	_casa_punica(r, Vector3(-0.58, 0, -0.3), 0.3, 0.28, 0.3, 392, false, false)
	_palma(r, Vector3(0.68, 0, -0.5), 0.8, 393)
	r.add_child(sfera(0.08, Vector3(-0.66, 0.03, 0.02), "paglia", Vector3(1.1, 0.7, 1.0)))
	return r
