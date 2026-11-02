extends "res://tools/studio/modelli.gd"
## Modelli dei Cartaginesi (step 37, docs/cartaginesi.md): parte «a». Lo studio unisce catalogo_extra()
## di ogni file tools/studio/modelli_*.gd al catalogo di modelli.gd.


static func catalogo_extra() -> Dictionary:
	return {
		"casa_greca_cartaginesi": {"crea": casa_greca_cartaginesi.bind(1)},
		"magazzino_cartaginesi": {"crea": magazzino_cartaginesi},
		"boscaiolo_cartaginesi": {"crea": boscaiolo_cartaginesi},
		"guardaboschi_cartaginesi": {"crea": guardaboschi_cartaginesi},
		"segheria_cartaginesi": {"crea": segheria_cartaginesi},
		"cava_cartaginesi": {"crea": cava_cartaginesi},
		"argillaio_cartaginesi": {"crea": argillaio_cartaginesi},
		"fornace_cartaginesi": {"crea": fornace_cartaginesi},
		"porto_cartaginesi": {"crea": porto_cartaginesi},
		"pozzo_cartaginesi": {"crea": pozzo_cartaginesi},
		"fattoria_cartaginesi": {"crea": fattoria_cartaginesi},
		"mulino_cartaginesi": {"crea": mulino_cartaginesi},
		"forno_cartaginesi": {"crea": forno_cartaginesi},
		"porcile_cartaginesi": {"crea": porcile_cartaginesi},
		"macelleria_cartaginesi": {"crea": macelleria_cartaginesi},
		"ovile_cartaginesi": {"crea": ovile_cartaginesi},
		"capraio_cartaginesi": {"crea": capraio_cartaginesi},
		"apiario_cartaginesi": {"crea": apiario_cartaginesi},
		"caseificio_cartaginesi": {"crea": caseificio_cartaginesi},
	}


# =================================================================== CARTAGINESI (step 37)
# Lo stile dei Cartaginesi: case di mattoni crudi intonacate color sabbia con i pilastri di pietra squadrata
# («opus africanum»), fascia di calce bianca e riga porpora sotto la cornice, teste di travi di cedro, tetti piatti
# a terrazza con il parapetto; porte e finestre con la cornice «a gola» (cavetto) dipinta a scanalature porpora e blu
# e il disco solare alato; il segno di Tanit dipinto sulle porte; tende e drappi porpora, anfore puniche a siluro,
# palme da dattero, merli a scalini sulle mura. Ogni modello ha lo stesso ingombro del corrispondente siculo/greco.

## Materiali propri dei Cartaginesi (porpora, cedro, intonaco color sabbia, tenda a strisce porpora), costruiti con gli
## stessi strumenti di modelli.gd e messi nella cache dei materiali, così scatola()/cilindro()/sfera() li trovano per nome.
static func _mat_ca() -> void:
	if _cache_mat.has("porpora_ca"):
		return
	_reg_ca("porpora_ca", _rumore(3701, 0.35, Color("5c1038"), Color("8e2058")), 2.0, [0.0, 0.05, 1.25])
	_reg_ca("porpora_chiara_ca", _rumore(3702, 0.3, Color("8c2a64"), Color("b44a86")), 2.0, [0.0, 0.05, 1.2])
	_reg_ca("cedro_ca", _rumore(3703, 0.15, Color("3c1a0e"), Color("6e3620")), 1.0, [0.15, 0.25, 1.05], Vector3(1, 6, 1))
	_reg_ca("sabbia_ca", _rumore(3704, 0.08, Color("ccaa72"), Color("ecd4a0")), 2.0, [0.4, 0.4, 1.08])
	_reg_ca("tenda_porpora_ca", _strisce_tex(Color("f2ead8"), Color("7c1a50")), 3.0, [0.05, 0.05, 1.15])
	_reg_ca("anfora_ca", _rumore(3705, 0.2, Color("c49a68"), Color("ead2a2")), 2.0, [0.25, 0.3, 1.0])


static func _reg_ca(nome: String, tex: Texture2D, scala: float, reg: Array, uv := Vector3.ZERO) -> void:
	var m := StandardMaterial3D.new()
	m.albedo_texture = tex
	m.roughness = 0.9
	m.uv1_scale = uv if uv != Vector3.ZERO else Vector3.ONE * scala
	var sm := _a_vissuto(m, nome)
	sm.set_shader_parameter("scala", scala)
	sm.set_shader_parameter("sporco", reg[0])
	sm.set_shader_parameter("macchie", reg[1])
	sm.set_shader_parameter("saturazione", reg[2])
	_cache_mat[nome] = sm


## Casa cartaginese: zoccolo di pietra, muri di mattoni crudi intonacati color sabbia con i pilastri di pietra agli
## spigoli, intonaco caduto qua e là, riga porpora e fascia di calce sotto la cornice, teste di travi di cedro,
## doccione, terrazza piatta con il parapetto di calce (con i merli a scalini se merli). Restituisce il nodo del corpo
## (centro a terra) con il metadato "top" = quota del pavimento della terrazza.
static func _casa_ca(r: Node3D, pos: Vector3, lx: float, lz: float, h: float, seme: int, merli := false, zoccolo := true, rot_y := 0.0) -> Node3D:
	_mat_ca()
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot_y
	r.add_child(n)
	var rng := _rng(seme)
	var y0 := 0.0
	if zoccolo:
		n.add_child(scatola(Vector3(lx + 0.04, 0.06, lz + 0.04), Vector3(0, 0.03, 0), "blocchi_greci"))
		y0 = 0.06
	n.add_child(scatola(Vector3(lx, h, lz), Vector3(0, y0 + h * 0.5, 0), "sabbia_ca"))
	var top := y0 + h
	# pilastri di pietra squadrata agli spigoli in vista («opus africanum»)
	for p: Vector3 in [Vector3(-lx * 0.5 + 0.025, 0, lz * 0.5), Vector3(lx * 0.5 - 0.025, 0, lz * 0.5), Vector3(lx * 0.5, 0, -lz * 0.5 + 0.025)]:
		var su_x := absf(p.x - lx * 0.5) < 0.001
		var nb := int((h - 0.08) / 0.05)
		for k in nb:
			var lungo := 0.05 if k % 2 == 0 else 0.034
			var dim := Vector3(0.012, 0.046, lungo) if su_x else Vector3(lungo, 0.046, 0.012)
			n.add_child(scatola(dim, Vector3(p.x, y0 + 0.025 + k * 0.05, p.z) + (Vector3(0.004, 0, 0) if su_x else Vector3(0, 0, 0.004)), "roccia_chiara"))
	# intonaco caduto: si vedono i mattoni crudi
	for k in 3:
		var w := rng.randf_range(0.06, 0.11)
		var hh := rng.randf_range(0.035, 0.06)
		var y := rng.randf_range(y0 + 0.05, top - 0.13)
		if k < 2:
			n.add_child(scatola(Vector3(w, hh, 0.01), Vector3(rng.randf_range(-lx * 0.3, lx * 0.3), y, lz * 0.5 + 0.002), "mattoni_crudi"))
		else:
			n.add_child(scatola(Vector3(0.01, hh, w), Vector3(lx * 0.5 + 0.002, y, rng.randf_range(-lz * 0.3, lz * 0.3)), "mattoni_crudi"))
	# riga porpora, fascia di calce, travi di cedro e cornice
	n.add_child(scatola(Vector3(lx + 0.008, 0.012, lz + 0.008), Vector3(0, top - 0.062, 0), "porpora_ca"))
	n.add_child(scatola(Vector3(lx + 0.006, 0.04, lz + 0.006), Vector3(0, top - 0.035, 0), "calce"))
	var nt := maxi(2, int(lx / 0.1))
	for i in nt:
		n.add_child(cilindro(0.01, 0.01, 0.04, Vector3(-lx * 0.5 + (i + 0.5) * lx / nt, top - 0.032, lz * 0.5 + 0.012), "cedro_ca", Vector3(90, 0, 0), 6))
	var ntz := maxi(2, int(lz / 0.1))
	for i in ntz:
		n.add_child(cilindro(0.01, 0.01, 0.04, Vector3(lx * 0.5 + 0.012, top - 0.032, -lz * 0.5 + (i + 0.5) * lz / ntz), "cedro_ca", Vector3(0, 0, 90), 6))
	n.add_child(scatola(Vector3(lx + 0.04, 0.02, lz + 0.04), Vector3(0, top + 0.01, 0), "calce"))
	# doccione di terracotta con la colatura
	var dz := rng.randf_range(-lz * 0.25, lz * 0.25)
	n.add_child(cilindro(0.011, 0.013, 0.08, Vector3(lx * 0.5 + 0.04, top + 0.012, dz), "terracotta", Vector3(0, 0, 80), 6))
	n.add_child(scatola(Vector3(0.004, top * 0.5, 0.022), Vector3(lx * 0.5 + 0.002, top * 0.55, dz), "intonaco_sporco"))
	# terrazza
	var tt := top + 0.02
	n.add_child(scatola(Vector3(lx - 0.02, 0.004, lz - 0.02), Vector3(0, tt + 0.002, 0), "battuto"))
	_parapetto_s(n, lx + 0.03, lz + 0.03, tt, merli, "calce", 0.04, 0.7)
	n.set_meta("top", tt)
	return n


## Cornice «a gola» (cavetto) sopra una porta o una finestra (guarda verso +Z): toro di calce, tre fasce che sporgono
## sempre di più, scanalature dipinte porpora e blu e il disco solare alato al centro, abaco in cima.
## p = centro della base sulla facciata.
static func _cavetto(n: Node3D, p: Vector3, w: float, s := 1.0) -> void:
	n.add_child(cilindro(0.007 * s, 0.007 * s, w, p + Vector3(0, 0.007 * s, 0.007 * s), "calce", Vector3(0, 0, 90), 8))
	var y := 0.014 * s
	var extra: Array[float] = [0.01, 0.026, 0.046]
	var alto: Array[float] = [0.012, 0.014, 0.012]
	var prof: Array[float] = [0.018, 0.028, 0.04]
	for k in 3:
		var lw := w + extra[k] * s
		var hh := alto[k] * s
		var pp := prof[k] * s
		n.add_child(scatola(Vector3(lw, hh, pp), p + Vector3(0, y + hh * 0.5, pp * 0.5), "calce"))
		if k == 1:
			var nf := maxi(3, int(lw / (0.016 * s)))
			for i in nf:
				var x := -lw * 0.5 + (i + 0.5) * lw / nf
				if absf(x) < 0.022 * s:
					continue
				n.add_child(scatola(Vector3(0.007 * s, hh * 0.9, 0.004), p + Vector3(x, y + hh * 0.5, pp + 0.001), "porpora_ca" if i % 2 == 0 else "lapislazzuli"))
			# disco solare alato
			n.add_child(cilindro(0.008 * s, 0.008 * s, 0.006, p + Vector3(0, y + hh * 0.5, pp + 0.002), "moneta", Vector3(90, 0, 0), 12))
			for lato: int in [-1, 1]:
				n.add_child(scatola(Vector3(0.016 * s, 0.005 * s, 0.004), p + Vector3(lato * 0.016 * s, y + hh * 0.55, pp + 0.002), "lapislazzuli", Vector3(0, 0, lato * 8)))
		y += hh
	n.add_child(scatola(Vector3(w + 0.056 * s, 0.008 * s, 0.046 * s), p + Vector3(0, y + 0.004 * s, 0.023 * s), "calce"))


## Segno di Tanit (guarda verso +Z): triangolo, braccia alzate alle estremità, collo e disco. p = centro del triangolo.
static func _tanit(n: Node3D, p: Vector3, s := 1.0, mat := "calce") -> void:
	var rr := 0.022 * s
	n.add_child(cilindro(rr, rr, 0.004, p, mat, Vector3(-90, 0, 0), 3))
	n.add_child(scatola(Vector3(rr * 2.5, rr * 0.3, 0.004), p + Vector3(0, rr * 1.0, 0), mat))
	for lato: int in [-1, 1]:
		n.add_child(scatola(Vector3(rr * 0.3, rr * 0.6, 0.004), p + Vector3(lato * rr * 1.1, rr * 1.25, 0), mat))
	n.add_child(scatola(Vector3(rr * 0.32, rr * 0.4, 0.004), p + Vector3(0, rr * 1.25, 0), mat))
	n.add_child(cilindro(rr * 0.55, rr * 0.55, 0.004, p + Vector3(0, rr * 1.9, 0), mat, Vector3(90, 0, 0), 14))


## Porta cartaginese (guarda verso +Z locale): vano buio, stipiti di calce, battenti di cedro con le borchie di bronzo
## e il segno di Tanit dipinto, soglia di pietra, cornice a gola sopra. pos = piede della porta sulla facciata.
static func _porta_ca(r: Node3D, pos: Vector3, rot_y := 0.0, w := 0.12, h := 0.17, aperta := false) -> void:
	_mat_ca()
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot_y
	r.add_child(n)
	n.add_child(scatola(Vector3(w, h, 0.014), Vector3(0, h * 0.5, 0.003), "buio"))
	for lato: int in [-1, 1]:
		n.add_child(scatola(Vector3(0.02, h + 0.01, 0.016), Vector3(lato * (w * 0.5 + 0.01), (h + 0.01) * 0.5, 0.006), "calce"))
	if aperta:
		n.add_child(scatola(Vector3(w * 0.48, h - 0.006, 0.01), Vector3(-w * 0.26, h * 0.5, 0.012), "cedro_ca"))
		_tanit(n, Vector3(-w * 0.26, h * 0.52, 0.018), w / 0.16, "calce")
	else:
		for lato: int in [-1, 1]:
			n.add_child(scatola(Vector3(w * 0.48, h - 0.006, 0.01), Vector3(lato * w * 0.25, h * 0.5, 0.011), "cedro_ca"))
			for j in 3:
				n.add_child(sfera(0.005, Vector3(lato * w * 0.42, 0.03 + j * h * 0.36, 0.017), "bronzo"))
		_tanit(n, Vector3(0, h * 0.5, 0.018), w / 0.12, "calce")
	n.add_child(scatola(Vector3(w + 0.06, 0.014, 0.05), Vector3(0, 0.007, 0.028), "roccia_chiara"))
	_cavetto(n, Vector3(0, h + 0.008, 0.004), w + 0.04)
	if pos.y > 0.01:
		n.add_child(scatola(Vector3(w + 0.06, pos.y, 0.07), Vector3(0, -pos.y * 0.5, 0.04), "blocchi_greci"))


## Finestrella cartaginese (guarda verso +Z locale): vano buio con la grata di cedro, tenda porpora scostata,
## davanzale di calce e piccola cornice a gola. pos = centro del vano.
static func _finestra_ca(r: Node3D, pos: Vector3, rot_y: float, w := 0.06, h := 0.075) -> void:
	_mat_ca()
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot_y
	r.add_child(n)
	n.add_child(scatola(Vector3(w, h, 0.012), Vector3(0, 0, 0.003), "buio"))
	for k in 2:
		n.add_child(scatola(Vector3(0.005, h, 0.005), Vector3((k - 0.5) * w * 0.4, 0, 0.009), "cedro_ca"))
	n.add_child(scatola(Vector3(w * 0.45, h * 0.9, 0.004), Vector3(w * 0.22, 0, 0.011), "porpora_ca", Vector3(0, 0, -3)))
	n.add_child(scatola(Vector3(w + 0.026, 0.012, 0.028), Vector3(0, -h * 0.5 - 0.006, 0.01), "calce"))
	_cavetto(n, Vector3(0, h * 0.5 + 0.002, 0.003), w + 0.014, 0.6)


## Anfora punica «a siluro»: corpo lungo e stretto con la punta in basso, spalla tonda, due anse piccole,
## collo corto. pos = punta; rot in gradi (per coricarla o appoggiarla al muro).
static func _anfora_p(pos: Vector3, scala := 1.0, rot := Vector3.ZERO, mat := "anfora_ca") -> Node3D:
	_mat_ca()
	var n := Node3D.new()
	n.position = pos
	n.scale = Vector3(1.18, 1.0, 1.18) * scala
	n.rotation_degrees = rot
	n.add_child(cilindro(0.006, 0.025, 0.07, Vector3(0, 0.035, 0), mat, Vector3.ZERO, 10))
	n.add_child(cilindro(0.025, 0.029, 0.12, Vector3(0, 0.13, 0), mat, Vector3.ZERO, 10))
	n.add_child(sfera(0.029, Vector3(0, 0.19, 0), mat, Vector3(1, 0.55, 1)))
	n.add_child(cilindro(0.0295, 0.0295, 0.012, Vector3(0, 0.16, 0), "terracotta", Vector3.ZERO, 10))
	n.add_child(cilindro(0.0285, 0.0285, 0.006, Vector3(0, 0.1, 0), "terracotta", Vector3.ZERO, 10))
	for lato: int in [-1, 1]:
		n.add_child(_toro(0.004, 0.011, Vector3(lato * 0.029, 0.178, 0), "terracotta", Vector3(90, 0, 0)))
	n.add_child(cilindro(0.011, 0.013, 0.022, Vector3(0, 0.21, 0), mat, Vector3.ZERO, 8))
	n.add_child(cilindro(0.016, 0.016, 0.008, Vector3(0, 0.222, 0), "terracotta", Vector3.ZERO, 8))
	return n


## Fila di n anfore a siluro piantate nella sabbia e appoggiate l'una all'altra, da «da» con il passo dato.
static func _fila_anfore(r: Node3D, da: Vector3, passo: Vector3, n: int, scala := 0.9, inclina := -10.0) -> void:
	for k in n:
		r.add_child(_anfora_p(da + passo * k + Vector3(0, -0.025, 0), scala * (1.0 - (k % 3) * 0.05), Vector3(inclina, (k % 2) * 30, (k % 3 - 1) * 4)))


## Rastrelliera di cedro con le anfore a siluro coricate a piramide (lungo X locale).
static func _rastrelliera_anfore(r: Node3D, pos: Vector3, rot_y := 0.0, file := 3) -> void:
	_mat_ca()
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot_y
	r.add_child(n)
	var larg := file * 0.07 + 0.04
	n.add_child(scatola(Vector3(larg, 0.02, 0.24), Vector3(0, 0.01, 0), "cedro_ca"))
	for lato: int in [-1, 1]:
		n.add_child(scatola(Vector3(0.02, 0.03, 0.24), Vector3(lato * larg * 0.5, 0.025, 0), "cedro_ca"))
	for f in file:
		for k in file - f:
			var x := (k - (file - f - 1) * 0.5) * 0.068
			n.add_child(_anfora_p(Vector3(x, 0.05 + f * 0.058, -0.11), 0.95, Vector3(90, 0, 0)))


## Insegna dei Cartaginesi: asta di cedro con la traversa, drappo porpora con il segno di Tanit e la frangia d'oro,
## in cima il disco sopra la falce di luna, di bronzo dorato.
static func _insegna_ca(r: Node3D, pos: Vector3, h := 0.6) -> void:
	_mat_ca()
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = 30
	r.add_child(n)
	n.add_child(cilindro(0.011, 0.014, h, Vector3(0, h * 0.5, 0), "cedro_ca", Vector3.ZERO, 6))
	n.add_child(cilindro(0.007, 0.007, 0.2, Vector3(0, h - 0.04, 0.01), "cedro_ca", Vector3(0, 0, 90), 5))
	n.add_child(scatola(Vector3(0.17, 0.22, 0.006), Vector3(0, h - 0.155, 0.014), "porpora_ca"))
	n.add_child(scatola(Vector3(0.172, 0.014, 0.008), Vector3(0, h - 0.055, 0.016), "seta_oro"))
	_tanit(n, Vector3(0, h - 0.17, 0.019), 1.5, "seta_oro")
	for k in 6:
		n.add_child(scatola(Vector3(0.022, 0.035, 0.006), Vector3(-0.07 + k * 0.028, h - 0.28, 0.014), "seta_oro" if k % 2 == 0 else "porpora_ca"))
	# disco e falce di luna
	n.add_child(cilindro(0.022, 0.022, 0.01, Vector3(0, h + 0.07, 0.0), "moneta", Vector3(90, 0, 0), 16))
	for k in 7:
		var a := deg_to_rad(200.0 + k * 23.0)
		n.add_child(sfera(0.009, Vector3(cos(a) * 0.04, h + 0.075 + sin(a) * 0.035, 0), "moneta"))


## Tettoia piatta su pali di cedro coperta di stuoie di canne e foglie di palma, con la frangia porpora davanti.
## pos = centro a terra.
static func _tettoia_ca(r: Node3D, pos: Vector3, larg: float, prof: float, h: float, seme := 1) -> void:
	_mat_ca()
	var rng := _rng(seme)
	for x: float in [-larg * 0.5, larg * 0.5]:
		for z: float in [-prof * 0.5, prof * 0.5]:
			r.add_child(cilindro(0.013, 0.015, h, pos + Vector3(x, h * 0.5, z), "cedro_ca", Vector3.ZERO, 6))
	for z: float in [-prof * 0.5, prof * 0.5]:
		r.add_child(scatola(Vector3(larg + 0.08, 0.022, 0.022), pos + Vector3(0, h, z), "cedro_ca"))
	r.add_child(scatola(Vector3(larg + 0.1, 0.016, prof + 0.08), pos + Vector3(0, h + 0.019, 0), "canne"))
	for k in int(larg * prof * 90) + 6:
		var f := sfera(0.05, pos + Vector3(rng.randf_range(-larg * 0.45, larg * 0.45), h + 0.03, rng.randf_range(-prof * 0.35, prof * 0.35)), "foglie" if k % 3 else ("foglie_chiare" if k % 2 else "foglie_scure"), Vector3(0.55, 0.14, 2.4))
		f.rotation_degrees.y = rng.randf_range(-40, 40) + 90 * (k % 2)
		r.add_child(f)
	var nf := maxi(3, int(larg / 0.05))
	for k in nf:
		var x := -larg * 0.5 - 0.04 + (k + 0.5) * (larg + 0.08) / nf
		r.add_child(scatola(Vector3((larg + 0.08) / nf * 0.85, 0.03, 0.005), pos + Vector3(x, h - 0.02, prof * 0.5 + 0.015), "porpora_ca" if k % 2 == 0 else "calce"))


## Muretto di mattoni crudi intonacato color sabbia con lo zoccolo di pietra e la copertina di calce
## (con i merli a scalini se merli).
static func _muretto_ca(r: Node3D, da: Vector3, a: Vector3, h := 0.08, sp := 0.06, merli := false) -> void:
	_mat_ca()
	var d := a - da
	d.y = 0.0
	var lung := d.length()
	var n := Node3D.new()
	n.position = Vector3((da.x + a.x) * 0.5, da.y, (da.z + a.z) * 0.5)
	n.rotation.y = atan2(-d.z, d.x)
	r.add_child(n)
	n.add_child(scatola(Vector3(lung + 0.01, 0.025, sp + 0.012), Vector3(0, 0.0125, 0), "roccia_chiara"))
	n.add_child(scatola(Vector3(lung, h, sp), Vector3(0, h * 0.5, 0), "sabbia_ca"))
	n.add_child(scatola(Vector3(lung + 0.012, 0.016, sp + 0.016), Vector3(0, h + 0.008, 0), "calce"))
	var nk := int(lung / 0.3)
	for k in nk:
		n.add_child(scatola(Vector3(0.06, 0.028, sp + 0.004), Vector3(-lung * 0.5 + (k + 0.5) * lung / nk + 0.03, h * 0.5, 0), "mattoni_crudi"))
	if merli:
		_fila_merli(n, Vector3(-lung * 0.5, h + 0.016, 0), Vector3(lung * 0.5, h + 0.016, 0), "calce", 0.8)


## Cedro: tronco scuro e palchi di rami piatti e larghi, a strati.
static func _cedro(r: Node3D, pos: Vector3, s := 1.0, seme := 1) -> void:
	var rng := _rng(seme)
	var n := Node3D.new()
	n.position = pos
	n.scale = Vector3.ONE * s
	r.add_child(n)
	n.add_child(cilindro(0.025, 0.04, 0.46, Vector3(0, 0.23, 0), "corteccia", Vector3.ZERO, 8))
	for k in 4:
		var y := 0.2 + k * 0.095
		var rg := 0.26 - k * 0.05
		var off := Vector3(rng.randf_range(-0.02, 0.02), 0, rng.randf_range(-0.02, 0.02))
		n.add_child(sfera(rg, Vector3(0, y, 0) + off, "aghi", Vector3(1, 0.13, 1)))
		ramo(n, Vector3(0, y - 0.03, 0), Vector3(rg * 0.7, y - 0.005, rg * 0.3), 0.008)
		n.add_child(sfera(rg * 0.8, Vector3(0, y + 0.015, 0) + off, "foglie_scure", Vector3(1, 0.1, 1)))
		for j in 3:
			var a := j * TAU / 3 + k
			n.add_child(sfera(rg * 0.45, Vector3(cos(a) * rg * 0.65, y + 0.01, sin(a) * rg * 0.65) + off, "aghi", Vector3(1, 0.22, 1)))
	n.add_child(sfera(0.05, Vector3(0, 0.56, 0), "aghi", Vector3(1, 0.5, 1)))


## Tannur: forno di argilla a tronco di cono con la bocca in alto, le braci, la fascia porpora e il fumo.
static func _tannur(r: Node3D, pos: Vector3, s := 1.0, fumo := true) -> void:
	_mat_ca()
	r.add_child(cilindro(0.11 * s, 0.13 * s, 0.03 * s, pos + Vector3(0, 0.015 * s, 0), "roccia_chiara", Vector3.ZERO, 14))
	r.add_child(cilindro(0.065 * s, 0.1 * s, 0.17 * s, pos + Vector3(0, 0.115 * s, 0), "argilla", Vector3.ZERO, 14))
	r.add_child(cilindro(0.094 * s, 0.096 * s, 0.014 * s, pos + Vector3(0, 0.07 * s, 0), "porpora_ca", Vector3.ZERO, 14))
	r.add_child(_toro(0.055 * s, 0.07 * s, pos + Vector3(0, 0.2 * s, 0), "argilla_cruda"))
	r.add_child(cilindro(0.055 * s, 0.055 * s, 0.004, pos + Vector3(0, 0.2 * s, 0), "buio", Vector3.ZERO, 12))
	r.add_child(sfera(0.035 * s, pos + Vector3(0, 0.195 * s, 0), "brace", Vector3(1, 0.3, 1)))
	r.add_child(scatola(Vector3(0.05 * s, 0.04 * s, 0.01 * s), pos + Vector3(0, 0.04 * s, 0.098 * s), "buio", Vector3(-12, 0, 0)))
	r.add_child(sfera(0.012 * s, pos + Vector3(0, 0.035 * s, 0.1 * s), "brace"))
	for k in 3:
		var a := deg_to_rad(-20.0 + k * 50.0)
		var t := sfera(0.03 * s, pos + Vector3(sin(a), 0, cos(a)) * 0.08 * s + Vector3(0, 0.16 * s, 0), "fuliggine", Vector3(1.2, 0.8, 0.3))
		t.rotation.y = a
		r.add_child(t)
	if fumo:
		_fumo(r, pos + Vector3(0, 0.24 * s, 0), 3, s * 0.8)


## Nave mercantile punica («gaulos») ormeggiata: scafo tondo di cedro con la fascia porpora, testa di cavallo
## sul dritto di prua, occhio dipinto, poppa ricurva, vela a strisce porpora serrata sul pennone, anfore a siluro,
## casse e balle di stoffa porpora sul ponte. La prua guarda verso +X locale.
static func _nave_ca(r: Node3D, pos: Vector3, rot_y := 0.0, s := 1.0) -> void:
	_mat_ca()
	var b := Node3D.new()
	b.position = pos
	b.rotation_degrees.y = rot_y
	b.scale = Vector3.ONE * s
	r.add_child(b)
	var mi := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.15
	sm.height = 0.15
	sm.is_hemisphere = true
	sm.radial_segments = 20
	sm.rings = 8
	mi.mesh = sm
	mi.rotation_degrees.x = 180
	mi.position = Vector3(0, 0.07, 0)
	mi.scale = Vector3(2.7, 0.75, 1.0)
	mi.material_override = materiale("cedro_ca")
	b.add_child(mi)
	var fasce := [[0.15, 0.04, 0.09, "cedro_ca"], [0.152, 0.016, 0.1, "porpora_ca"], [0.151, 0.008, 0.075, "pece"]]
	for f: Array in fasce:
		var c := cilindro(f[0], f[0], f[1], Vector3(0, f[2], 0), f[3], Vector3.ZERO, 20)
		c.scale = Vector3(2.7, 1, 1.0)
		b.add_child(c)
	var ponte := cilindro(0.135, 0.135, 0.006, Vector3(0, 0.108, 0), "legno_chiaro", Vector3.ZERO, 20)
	ponte.scale = Vector3(2.7, 1, 1.0)
	b.add_child(ponte)
	# occhio dipinto a prua
	for lato: int in [-1, 1]:
		b.add_child(sfera(0.016, Vector3(0.33, 0.085, lato * 0.075), "intonaco_bianco", Vector3(1.4, 1, 0.4)))
		b.add_child(sfera(0.008, Vector3(0.335, 0.085, lato * 0.081), "buio", Vector3(1, 1, 0.5)))
	# dritto di prua con la testa di cavallo
	ramo(b, Vector3(0.37, 0.06, 0), Vector3(0.43, 0.2, 0), 0.016, "cedro_ca")
	b.add_child(cilindro(0.016, 0.02, 0.07, Vector3(0.445, 0.23, 0), "legno_chiaro", Vector3(0, 0, -25), 8))
	b.add_child(sfera(0.022, Vector3(0.47, 0.27, 0), "legno_chiaro", Vector3(1.7, 0.85, 0.75)))
	for lato: int in [-1, 1]:
		b.add_child(cilindro(0.004, 0.0, 0.02, Vector3(0.455, 0.295, lato * 0.008), "legno_chiaro", Vector3.ZERO, 4))
	for k in 4:
		b.add_child(scatola(Vector3(0.012, 0.016, 0.006), Vector3(0.425 + k * 0.01, 0.24 + k * 0.012, 0), "porpora_ca", Vector3(0, 0, -25)))
	b.add_child(sfera(0.005, Vector3(0.48, 0.28, 0.015), "buio"))
	# poppa ricurva a coda di pesce
	var punti := [Vector3(-0.36, 0.07, 0), Vector3(-0.41, 0.14, 0), Vector3(-0.43, 0.22, 0), Vector3(-0.41, 0.28, 0)]
	for k in punti.size() - 1:
		ramo(b, punti[k], punti[k + 1], 0.018 - k * 0.003, "cedro_ca")
	for lato: int in [-1, 1]:
		b.add_child(scatola(Vector3(0.012, 0.05, 0.03), Vector3(-0.4, 0.3, lato * 0.014), "cedro_ca", Vector3(lato * 20, 0, 10)))
	b.add_child(scatola(Vector3(0.1, 0.02, 0.18), Vector3(-0.28, 0.12, 0), "cedro_ca"))
	# timone laterale
	ramo(b, Vector3(-0.26, 0.17, 0.12), Vector3(-0.4, -0.03, 0.16), 0.008, "legno_chiaro")
	b.add_child(scatola(Vector3(0.05, 0.08, 0.012), Vector3(-0.405, -0.02, 0.163), "legno_chiaro", Vector3(0, 0, 35)))
	# carico: anfore a siluro coricate, casse e balle porpora
	for i in 2:
		for k in 4:
			b.add_child(_anfora_p(Vector3(-0.17 + k * 0.06, 0.135 + i * 0.045, 0.1 - i * 0.03), 0.6, Vector3(90, 0, 0)))
	b.add_child(cassa(Vector3(0.14, 0.11, -0.04), 10, 0.07))
	b.add_child(cassa(Vector3(0.22, 0.11, 0.03), -12, 0.06))
	b.add_child(cilindro(0.03, 0.03, 0.12, Vector3(0.15, 0.2, 0.04), "porpora_ca", Vector3(90, 0, 0), 10))
	b.add_child(cilindro(0.028, 0.028, 0.12, Vector3(0.21, 0.2, 0.05), "porpora_chiara_ca", Vector3(90, 0, 0), 10))
	# albero, pennone con la vela serrata e le sartie
	b.add_child(cilindro(0.012, 0.009, 0.56, Vector3(0.03, 0.39, 0), "cedro_ca", Vector3.ZERO, 8))
	b.add_child(cilindro(0.008, 0.006, 0.5, Vector3(0.03, 0.6, 0), "legno_chiaro", Vector3(90, 0, 0), 6))
	b.add_child(cilindro(0.026, 0.026, 0.42, Vector3(0.03, 0.58, 0.0), "tenda_porpora_ca", Vector3(90, 0, 0), 10))
	for k in 4:
		b.add_child(cilindro(0.028, 0.028, 0.008, Vector3(0.03, 0.58, -0.15 + k * 0.1), "corda", Vector3(90, 0, 0), 10))
	ramo(b, Vector3(0.03, 0.66, 0), Vector3(0.4, 0.17, 0), 0.003, "corda")
	ramo(b, Vector3(0.03, 0.66, 0), Vector3(-0.38, 0.26, 0), 0.003, "corda")
	for lato: int in [-1, 1]:
		ramo(b, Vector3(0.03, 0.6, 0), Vector3(-0.02, 0.1, lato * 0.14), 0.0025, "corda")
	b.add_child(scatola(Vector3(0.06, 0.03, 0.004), Vector3(0.0, 0.69, 0), "porpora_ca"))
	b.add_child(sfera(0.012, Vector3(0.03, 0.675, 0), "moneta"))


## Bilancia del mercante su un banco di cedro con il drappo porpora, i piatti di bronzo, i pesi e le monete.
static func _banco_bilancia(r: Node3D, pos: Vector3, rot_y := 0.0) -> void:
	_mat_ca()
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot_y
	r.add_child(n)
	n.add_child(scatola(Vector3(0.2, 0.012, 0.1), Vector3(0, 0.09, 0), "cedro_ca"))
	for x: float in [-0.08, 0.08]:
		n.add_child(scatola(Vector3(0.016, 0.085, 0.08), Vector3(x, 0.042, 0), "cedro_ca"))
	n.add_child(scatola(Vector3(0.2, 0.05, 0.004), Vector3(0, 0.07, 0.05), "porpora_ca"))
	n.add_child(cilindro(0.004, 0.004, 0.1, Vector3(-0.03, 0.146, 0), "bronzo", Vector3.ZERO, 5))
	n.add_child(cilindro(0.003, 0.003, 0.11, Vector3(-0.03, 0.195, 0), "bronzo", Vector3(0, 0, 90), 5))
	for lato: int in [-1, 1]:
		n.add_child(cilindro(0.001, 0.001, 0.05, Vector3(-0.03 + lato * 0.05, 0.17, 0), "corda", Vector3.ZERO, 3))
		n.add_child(cilindro(0.022, 0.016, 0.008, Vector3(-0.03 + lato * 0.05, 0.145, 0), "bronzo", Vector3.ZERO, 10))
	for k in 5:
		n.add_child(cilindro(0.007, 0.007, 0.003, Vector3(0.05 + (k % 2) * 0.014, 0.098 + k * 0.003, 0.01), "moneta", Vector3.ZERO, 8))
	n.add_child(cilindro(0.008, 0.01, 0.014, Vector3(0.075, 0.103, -0.02), "bronzo", Vector3.ZERO, 6))


## Filo con i panni stesi fra due pali: drappi porpora, lino bianco e porpora chiara.
static func _panni_ca(r: Node3D, da: Vector3, a: Vector3, h := 0.26) -> void:
	_mat_ca()
	r.add_child(cilindro(0.008, 0.009, h, da + Vector3(0, h * 0.5, 0), "cedro_ca", Vector3.ZERO, 5))
	r.add_child(cilindro(0.008, 0.009, h, a + Vector3(0, h * 0.5, 0), "cedro_ca", Vector3.ZERO, 5))
	ramo(r, da + Vector3(0, h - 0.01, 0), a + Vector3(0, h - 0.01, 0), 0.002, "corda")
	var d := a - da
	var ang := rad_to_deg(atan2(-d.z, d.x))
	var mats := ["porpora_ca", "lino_bianco", "porpora_chiara_ca", "porpora_ca"]
	for k in 4:
		var p := da.lerp(a, 0.15 + k * 0.23)
		r.add_child(scatola(Vector3(d.length() * 0.18, 0.1 + (k % 2) * 0.03, 0.004), p + Vector3(0, h - 0.07 - (k % 2) * 0.015, 0), mats[k], Vector3(0, ang, 0)))


## Cisterna a campana: bocca tonda di pietra con il coperchio di cedro e il secchio di bronzo.
static func _cisterna_ca(r: Node3D, pos: Vector3) -> void:
	_mat_ca()
	r.add_child(cilindro(0.065, 0.075, 0.06, pos + Vector3(0, 0.03, 0), "blocchi_greci", Vector3.ZERO, 14))
	r.add_child(cilindro(0.06, 0.06, 0.012, pos + Vector3(0, 0.066, 0), "cedro_ca", Vector3.ZERO, 14))
	r.add_child(_toro(0.006, 0.014, pos + Vector3(0, 0.075, 0), "ferro", Vector3(90, 0, 0)))
	r.add_child(cilindro(0.025, 0.02, 0.04, pos + Vector3(0.1, 0.02, 0.02), "bronzo", Vector3.ZERO, 10))
	r.add_child(cilindro(0.021, 0.021, 0.003, pos + Vector3(0.1, 0.04, 0.02), "acqua_pozzo", Vector3.ZERO, 10))


## Casetta di bottega: corpo cartaginese con la porta, finestre, anfora e cesta sulla terrazza e (se tenda)
## la tenda porpora. Restituisce il corpo (meta "top").
static func _bottega_ca(r: Node3D, pos: Vector3, lx: float, lz: float, h: float, seme: int, tenda := true) -> Node3D:
	var c := _casa_ca(r, pos, lx, lz, h, seme)
	var top: float = c.get_meta("top")
	_porta_ca(c, Vector3(-lx * 0.18, 0.06, lz * 0.5), 0.0, 0.11, minf(0.16, h - 0.1))
	if lx > 0.42:
		_finestra_ca(c, Vector3(lx * 0.24, 0.06 + h * 0.62, lz * 0.5), 0.0)
	# scala esterna di mattoni crudi che sale alla terrazza lungo il fianco destro
	var nst := maxi(4, int((lz - 0.04) / 0.05))
	for k in nst:
		var yk := (top - 0.02) * (k + 1) / nst
		var zk := lz * 0.5 - 0.03 - k * (lz - 0.06) / nst
		c.add_child(scatola(Vector3(0.075, yk, (lz - 0.06) / nst + 0.002), Vector3(lx * 0.5 + 0.04, yk * 0.5, zk), "sabbia_ca"))
		c.add_child(scatola(Vector3(0.078, 0.008, (lz - 0.06) / nst), Vector3(lx * 0.5 + 0.04, yk + 0.004, zk), "calce"))
	# drappo porpora steso sul parapetto
	c.add_child(scatola(Vector3(lx * 0.28, 0.1, 0.006), Vector3(-lx * 0.05 + lx * 0.2, top - 0.01, lz * 0.5 + 0.024), "porpora_ca"))
	c.add_child(scatola(Vector3(lx * 0.28, 0.01, 0.008), Vector3(-lx * 0.05 + lx * 0.2, top - 0.058, lz * 0.5 + 0.026), "seta_oro"))
	if tenda:
		_tenda(c, Vector3(lx * 0.18, top, -lz * 0.08), lx * 0.5, lz * 0.55, 0.16, 0.12, 0.0, "tenda_porpora_ca", true)
	c.add_child(_anfora_p(Vector3(-lx * 0.36, top - 0.01, -lz * 0.3), 0.6, Vector3(-10, 0, 6)))
	c.add_child(_anfora_p(Vector3(-lx * 0.28, top - 0.01, -lz * 0.33), 0.55, Vector3(-10, 0, -6)))
	return c


# ------------------------------------------------------------------ edifici dei Cartaginesi

## Casa cartaginese: casa a terrazza color sabbia con la porta di cedro e il segno di Tanit, stanzetta sul tetto,
## tenda porpora sulla terrazza con i cuscini, drappo porpora steso sul parapetto, cisterna, anfore a siluro
## appoggiate al muro, panni porpora stesi, forno tannur e palma da dattero.
static func casa_greca_cartaginesi(seme := 1) -> Node3D:
	_mat_ca()
	var r := Node3D.new()
	var lx := 0.82
	var lz := 0.62
	var c := _casa_ca(r, Vector3(-0.12, 0, -0.16), lx, lz, 0.4, seme + 3700)
	var top: float = c.get_meta("top")
	_porta_ca(c, Vector3(-0.18, 0.06, lz * 0.5), 0.0, 0.12, 0.18)
	_finestra_ca(c, Vector3(0.2, 0.32, lz * 0.5), 0.0)
	_finestra_ca(c, Vector3(lx * 0.5, 0.32, 0.12), 90.0)
	_finestra_ca(c, Vector3(lx * 0.5, 0.32, -0.16), 90.0)
	# stanzetta sul tetto
	var st := _casa_ca(c, Vector3(-0.2, top, -0.12), 0.34, 0.3, 0.17, seme + 3701, false, false)
	_finestra_ca(st, Vector3(0.0, 0.1, 0.15), 0.0, 0.05, 0.05)
	_finestra_ca(st, Vector3(0.17, 0.1, 0.0), 90.0, 0.05, 0.05)
	# tenda porpora sulla terrazza con i cuscini
	_tenda(c, Vector3(0.2, top, 0.08), 0.34, 0.3, 0.22, 0.17, 0.0, "tenda_porpora_ca", true)
	c.add_child(scatola(Vector3(0.22, 0.012, 0.13), Vector3(0.2, top + 0.008, 0.08), "porpora_ca"))
	for k in 2:
		c.add_child(sfera(0.026, Vector3(0.13 + k * 0.14, top + 0.03, 0.03), "seta_oro" if k == 0 else "lino_bianco", Vector3(1.3, 0.6, 1)))
	c.add_child(_anfora_p(Vector3(0.33, top, -0.2), 0.7, Vector3(-12, 0, 0)))
	# drappo porpora steso sul parapetto
	c.add_child(scatola(Vector3(0.16, 0.13, 0.006), Vector3(0.2, top - 0.02, lz * 0.5 + 0.024), "porpora_ca"))
	c.add_child(scatola(Vector3(0.16, 0.012, 0.008), Vector3(0.2, top - 0.08, lz * 0.5 + 0.026), "seta_oro"))
	# panca di pietra col cuscino, anfore a siluro appoggiate al muro
	c.add_child(scatola(Vector3(0.16, 0.05, 0.07), Vector3(0.05, 0.025, lz * 0.5 + 0.06), "blocchi_greci"))
	c.add_child(scatola(Vector3(0.14, 0.012, 0.06), Vector3(0.05, 0.056, lz * 0.5 + 0.06), "porpora_chiara_ca"))
	c.add_child(_anfora_p(Vector3(-0.37, -0.02, lz * 0.5 + 0.06), 0.9, Vector3(-12, 0, 4)))
	c.add_child(_anfora_p(Vector3(-0.31, -0.02, lz * 0.5 + 0.07), 0.85, Vector3(-14, 0, -6)))
	# cortile: cisterna, panni stesi, palma, tannur
	_cisterna_ca(r, Vector3(0.42, 0, 0.36))
	_panni_ca(r, Vector3(0.36, 0, 0.62), Vector3(0.72, 0, 0.22), 0.27)
	_palma(r, Vector3(-0.66, 0, 0.28), 0.95, seme + 5)
	_tannur(r, Vector3(-0.44, 0, 0.5), 0.75)
	r.add_child(cesta(Vector3(-0.28, 0, 0.56), "pane", 0.8))
	r.add_child(_anfora_p(Vector3(0.12, -0.02, 0.56), 0.9, Vector3(0, 0, 8)))
	return r


## Magazzino cartaginese: grande emporio a terrazza con i merli a scalini, torre d'angolo, cortile chiuso dal muro
## merlato con il portale a gola e il segno di Tanit, rastrelliere di anfore a siluro, balle di stoffa porpora, sacchi
## e casse sotto la tenda, banco con la bilancia, asino carico, palma e insegna.
static func magazzino_cartaginesi() -> Node3D:
	_mat_ca()
	var r := Node3D.new()
	r.position = Vector3(0, 0, -0.1)
	r.add_child(scatola(Vector3(2.0, 0.02, 1.6), Vector3(0, 0.01, 0.05), "sabbia"))
	var lx := 1.3
	var lz := 0.58
	var c := _casa_ca(r, Vector3(-0.28, 0, -0.38), lx, lz, 0.56, 3711, true)
	var top: float = c.get_meta("top")
	_porta_ca(c, Vector3(-0.12, 0.06, lz * 0.5), 0.0, 0.18, 0.24, true)
	for x: float in [-0.48, 0.22, 0.48]:
		_finestra_ca(c, Vector3(x, 0.44, lz * 0.5), 0.0)
	_finestra_ca(c, Vector3(lx * 0.5, 0.44, 0.0), 90.0)
	_tenda(c, Vector3(-0.3, top, 0.0), 0.5, 0.36, 0.2, 0.15, 0.0, "tenda_porpora_ca", true)
	for k in 3:
		c.add_child(_anfora_p(Vector3(0.2 + k * 0.08, top, -0.1), 0.7, Vector3(-10, 0, (k - 1) * 5)))
	# torre d'angolo a destra
	var t := _casa_ca(r, Vector3(0.66, 0, -0.42), 0.36, 0.36, 0.8, 3712, true)
	_finestra_ca(t, Vector3(0.0, 0.62, 0.18), 0.0)
	_finestra_ca(t, Vector3(0.18, 0.62, 0.0), 90.0)
	_porta_ca(t, Vector3(0.0, 0.06, 0.18), 0.0, 0.1, 0.15)
	# muro del cortile con i merli a scalini e il portale
	_muretto_ca(r, Vector3(-0.98, 0, -0.62), Vector3(-0.98, 0, 0.82), 0.14, 0.08, true)
	_muretto_ca(r, Vector3(-0.98, 0, 0.82), Vector3(-0.22, 0, 0.82), 0.14, 0.08, true)
	_muretto_ca(r, Vector3(0.22, 0, 0.82), Vector3(0.98, 0, 0.82), 0.14, 0.08, true)
	_muretto_ca(r, Vector3(0.98, 0, 0.82), Vector3(0.98, 0, -0.2), 0.14, 0.08, true)
	for x: float in [-0.2, 0.2]:
		r.add_child(scatola(Vector3(0.09, 0.3, 0.12), Vector3(x, 0.15, 0.82), "blocchi_greci"))
	r.add_child(scatola(Vector3(0.5, 0.05, 0.12), Vector3(0, 0.325, 0.82), "calce"))
	_cavetto(r, Vector3(0, 0.35, 0.82 + 0.06), 0.42, 1.2)
	_tanit(r, Vector3(0, 0.31, 0.882), 1.1, "porpora_ca")
	# rastrelliere di anfore a siluro nel cortile
	_rastrelliera_anfore(r, Vector3(-0.72, 0, 0.3), 0.0, 3)
	_rastrelliera_anfore(r, Vector3(-0.42, 0, 0.3), 0.0, 3)
	_fila_anfore(r, Vector3(-0.85, 0, 0.62), Vector3(0.075, 0, 0), 6, 0.95)
	# tenda porpora sopra le merci a destra
	_tenda(r, Vector3(0.6, 0, 0.2), 0.62, 0.4, 0.38, 0.3, 0.0, "tenda_porpora_ca", true)
	for i in 3:
		r.add_child(sacco(Vector3(0.4 + i * 0.13, 0, 0.12), i * 0.6))
	for i in 3:
		r.add_child(cilindro(0.035, 0.035, 0.16, Vector3(0.45 + i * 0.1, 0.035, 0.3), "porpora_ca" if i % 2 == 0 else "porpora_chiara_ca", Vector3(0, 10, 90), 10))
		r.add_child(cilindro(0.036, 0.036, 0.01, Vector3(0.45 + i * 0.1, 0.035, 0.3), "seta_oro", Vector3(0, 10, 90), 10))
	r.add_child(cassa(Vector3(0.82, 0, 0.12), 10))
	r.add_child(cassa(Vector3(0.82, 0.088, 0.13), 30, 0.09))
	r.add_child(cesta(Vector3(0.76, 0, 0.3), "agrumi"))
	_banco_bilancia(r, Vector3(0.45, 0, 0.56), 0.0)
	# asino carico, palma, insegna
	r.add_child(asino(Vector3(0.05, 0, 0.55), 70))
	r.add_child(_anfora_p(Vector3(-0.05, 0.12, 0.55), 0.55, Vector3(0, 0, -80)))
	_palma(r, Vector3(-0.8, 0, -0.05), 1.0, 3713)
	_insegna_ca(r, Vector3(0.88, 0, 0.66), 0.8)
	return r


## Boscaiolo cartaginese: bottega a terrazza, tettoia di cedro e foglie di palma sopra la legna spaccata, catasta
## di tronchi, ceppo con l'ascia, trucioli, anfore a siluro e un cedro.
static func boscaiolo_cartaginesi() -> Node3D:
	_mat_ca()
	var r := Node3D.new()
	_bottega_ca(r, Vector3(-0.2, 0, -0.22), 0.5, 0.42, 0.32, 3721, false)
	_tettoia_ca(r, Vector3(0.45, 0, -0.2), 0.34, 0.44, 0.3, 3722)
	legnaia(r, Vector3(0.45, 0, -0.32), 0.28, 5)
	legnaia(r, Vector3(0.45, 0, -0.1), 0.28, 4)
	catasta_tronchi(r, Vector3(0.55, 0, 0.5), 4, 0.5)
	r.add_child(cilindro(0.07, 0.075, 0.09, Vector3(-0.15, 0.045, 0.45), "corteccia", Vector3.ZERO, 12))
	r.add_child(cilindro(0.066, 0.066, 0.006, Vector3(-0.15, 0.092, 0.45), "legno_chiaro", Vector3.ZERO, 12))
	r.add_child(cilindro(0.008, 0.008, 0.22, Vector3(-0.15, 0.18, 0.45), "legno", Vector3(0, 0, 22), 6))
	r.add_child(scatola(Vector3(0.055, 0.04, 0.012), Vector3(-0.195, 0.27, 0.45), "ferro", Vector3(0, 0, 22)))
	for i in 6:
		r.add_child(cilindro(0.02, 0.02, 0.06, Vector3(-0.35 + i * 0.06, 0.02, 0.6 + (i % 2) * 0.05), "legno_chiaro", Vector3(0, i * 37, 90), 6))
	_fila_anfore(r, Vector3(-0.62, 0, 0.12), Vector3(0, 0, 0.07), 3, 0.85)
	_cedro(r, Vector3(-0.62, 0, 0.6), 0.7, 3723)
	return r


## Guardaboschi cartaginese: bottega a terrazza, vivaio di cedri e palme giovani in file dentro il muretto
## intonacato, canaletta d'acqua, anfora, zappa e sacchi di semi, cedro adulto.
static func guardaboschi_cartaginesi() -> Node3D:
	_mat_ca()
	var r := Node3D.new()
	_bottega_ca(r, Vector3(-0.32, 0, -0.32), 0.44, 0.38, 0.3, 3731, false)
	for i in 4:
		for j in 3:
			var p := Vector3(-0.1 + i * 0.16, 0, 0.28 + j * 0.15)
			r.add_child(cilindro(0.05, 0.05, 0.012, p + Vector3(0, 0.006, 0), "terra", Vector3.ZERO, 10))
			r.add_child(cilindro(0.006, 0.006, 0.06 + j * 0.02, p + Vector3(0, 0.03, 0), "corteccia", Vector3.ZERO, 5))
			if (i + j) % 2 == 0:
				for k in 2:
					r.add_child(sfera(0.045 + j * 0.006 - k * 0.015, p + Vector3(0, 0.06 + j * 0.02 + k * 0.03, 0), "aghi", Vector3(1, 0.35, 1)))
			else:
				for k in 5:
					var f := sfera(0.03, p + Vector3(0, 0.08 + j * 0.02, 0), "foglie", Vector3(0.35, 0.1, 1.6))
					f.rotation_degrees = Vector3(20, k * 72, 0)
					r.add_child(f)
	_muretto_ca(r, Vector3(-0.2, 0, 0.74), Vector3(0.52, 0, 0.74), 0.08, 0.06)
	_muretto_ca(r, Vector3(0.52, 0, 0.18), Vector3(0.52, 0, 0.74), 0.08, 0.06)
	_canaletta(r, Vector3(-0.18, 0, 0.19), Vector3(0.48, 0, 0.19), 0.03)
	r.add_child(_anfora_p(Vector3(0.3, -0.02, -0.15), 1.0, Vector3(-8, 0, 0)))
	r.add_child(cilindro(0.007, 0.007, 0.22, Vector3(0.15, 0.11, -0.3), "legno", Vector3(12, 0, -15), 5))
	r.add_child(scatola(Vector3(0.05, 0.012, 0.04), Vector3(0.18, 0.01, -0.28), "ferro", Vector3(0, 0, -15)))
	r.add_child(sacco(Vector3(-0.6, 0, 0.3), 0.4))
	r.add_child(sacco(Vector3(-0.62, 0, 0.42), -0.2))
	_cedro(r, Vector3(0.55, 0, -0.5), 0.9, 3732)
	return r


## Segheria cartaginese: bottega a terrazza, tettoia di cedro sopra il tronco sui cavalletti con la sega a telaio,
## pile di assi, cunei e mazzuolo, catasta di tronchi.
static func segheria_cartaginesi() -> Node3D:
	_mat_ca()
	var r := Node3D.new()
	_bottega_ca(r, Vector3(-0.22, 0, -0.27), 0.52, 0.42, 0.34, 3741)
	var t := Vector3(0.05, 0, 0.48)
	_tettoia_ca(r, t, 0.86, 0.36, 0.36, 3742)
	for px: float in [-0.25, 0.0, 0.25]:
		r.add_child(scatola(Vector3(0.03, 0.12, 0.12), t + Vector3(px, 0.06, 0.0), "cedro_ca"))
	r.add_child(cilindro(0.055, 0.055, 0.8, t + Vector3(0, 0.17, 0.0), "corteccia", Vector3(0, 0, 90), 9))
	r.add_child(cilindro(0.047, 0.047, 0.805, t + Vector3(0, 0.17, 0.0), "legno_chiaro", Vector3(0, 0, 90), 9))
	for z: float in [-0.08, 0.08]:
		r.add_child(scatola(Vector3(0.014, 0.3, 0.014), t + Vector3(0.1, 0.24, z), "cedro_ca"))
	r.add_child(scatola(Vector3(0.014, 0.014, 0.18), t + Vector3(0.1, 0.38, 0.0), "cedro_ca"))
	r.add_child(scatola(Vector3(0.006, 0.006, 0.17), t + Vector3(0.1, 0.2, 0.0), "ferro"))
	r.add_child(cilindro(0.2, 0.2, 0.004, t + Vector3(0.1, 0.002, 0.0), "legno_chiaro", Vector3.ZERO, 16))
	for k in 3:
		r.add_child(scatola(Vector3(0.03, 0.02, 0.05), t + Vector3(-0.35 + k * 0.05, 0.01, 0.17), "legno_scuro", Vector3(0, k * 30, 0)))
	r.add_child(cilindro(0.025, 0.025, 0.07, t + Vector3(-0.2, 0.025, 0.18), "legno", Vector3(0, 30, 90), 8))
	pila_assi(r, Vector3(0.62, 0, -0.25), 8, 90)
	pila_assi(r, Vector3(0.62, 0, 0.1), 5, 90)
	catasta_tronchi(r, Vector3(-0.65, 0, 0.5), 3, 0.42)
	r.add_child(_anfora_p(Vector3(0.42, -0.02, 0.8), 0.85, Vector3(-8, 0, 0)))
	return r


## Cava cartaginese: bottega a terrazza, parete d'arenaria tagliata a gradoni, blocchi squadrati in fila,
## leva, ceste di pietrame, piccone, slitta di tronchi con un blocco.
static func cava_cartaginesi() -> Node3D:
	_mat_ca()
	var r := Node3D.new()
	_bottega_ca(r, Vector3(-0.4, 0, -0.32), 0.4, 0.36, 0.3, 3751, false)
	# parete tagliata a gradoni (si vedono i segni dei blocchi cavati)
	var pc := Vector3(0.32, 0, -0.38)
	for k in 4:
		var hh := 0.42 - k * 0.1
		r.add_child(scatola(Vector3(0.56 - k * 0.04, hh, 0.12), pc + Vector3(0, hh * 0.5, -0.06 + k * 0.1), "tufo", Vector3(0, -6, 0)))
		for j in 3:
			r.add_child(scatola(Vector3(0.004, hh * 0.8, 0.004), pc + Vector3(-0.18 + j * 0.16 - k * 0.01, hh * 0.45, k * 0.1), "pietra_scura", Vector3(0, -6, 0)))
	var rng := _rng(3752)
	for k in 6:
		var p := Vector3(0.62 + rng.randf_range(-0.1, 0.1), 0.0, -0.45 + rng.randf_range(-0.12, 0.25))
		var d := rng.randf_range(0.12, 0.22)
		r.add_child(scatola(Vector3(d, d * rng.randf_range(0.7, 1.2), d * 0.8), p + Vector3(0, d * 0.4, 0), "tufo" if k % 3 != 0 else "roccia_massi", Vector3(0, rng.randf() * 60, 0)))
	# blocchi squadrati pronti
	for i in 4:
		for j in 2 - (i / 3):
			r.add_child(scatola(Vector3(0.13, 0.09, 0.09), Vector3(-0.1 + i * 0.15, 0.045 + j * 0.09, 0.45), "tufo", Vector3(0, i * 5 - 6, 0)))
	r.add_child(scatola(Vector3(0.14, 0.1, 0.1), Vector3(0.55, 0.05, 0.12), "tufo", Vector3(0, 20, 6)))
	ramo(r, Vector3(0.5, 0.02, 0.2), Vector3(0.78, 0.2, 0.34), 0.01, "cedro_ca")
	for k in 2:
		var cp := Vector3(-0.55 + k * 0.13, 0, 0.3 + k * 0.08)
		r.add_child(cilindro(0.065, 0.055, 0.06, cp + Vector3(0, 0.03, 0), "canne", Vector3.ZERO, 12))
		r.add_child(mucchio(cp + Vector3(0, 0.03, 0), "tufo", 5, 7 + k, 0.025))
	for lato: int in [-1, 1]:
		r.add_child(cilindro(0.018, 0.018, 0.34, Vector3(-0.42, 0.018, 0.62 + lato * 0.06), "corteccia", Vector3(0, 0, 90), 6))
	r.add_child(scatola(Vector3(0.26, 0.02, 0.16), Vector3(-0.42, 0.045, 0.62), "cedro_ca"))
	r.add_child(scatola(Vector3(0.12, 0.08, 0.09), Vector3(-0.42, 0.095, 0.62), "tufo"))
	ramo(r, Vector3(-0.27, 0.02, 0.62), Vector3(-0.1, 0.06, 0.66), 0.004, "corda")
	var a := attrezzo("piccone")
	a.position = Vector3(0.2, 0.02, 0.2)
	a.rotation_degrees = Vector3(0, -30, 8)
	r.add_child(a)
	r.add_child(_anfora_p(Vector3(-0.15, -0.02, 0.18), 0.85, Vector3(-6, 0, 4)))
	return r


## Argillaio cartaginese: bottega piccola, mattoni crudi che seccano in file, fossa d'argilla bordata di pietre,
## stampo di cedro, pala, vasca d'acqua intonacata e anfora.
static func argillaio_cartaginesi() -> Node3D:
	_mat_ca()
	var r := Node3D.new()
	_bottega_ca(r, Vector3(-0.32, 0, -0.32), 0.36, 0.3, 0.26, 3761, false)
	r.add_child(scatola(Vector3(0.44, 0.008, 0.18), Vector3(-0.41, 0.004, 0.45), "sabbia"))
	r.add_child(sfera(0.3, Vector3(0.3, -0.02, 0.25), "terra", Vector3(1.3, 0.12, 1.0)))
	r.add_child(sfera(0.22, Vector3(0.3, 0.0, 0.25), "argilla_cruda", Vector3(1.3, 0.08, 1.0)))
	for k in 6:
		var a := deg_to_rad(-20.0 + k * 40.0)
		r.add_child(sfera(0.03, Vector3(0.3 + cos(a) * 0.37, 0.01, 0.25 + sin(a) * 0.29), "roccia_chiara", Vector3(1.2, 0.6, 1.0)))
	for k in 12:
		r.add_child(scatola(Vector3(0.07, 0.03, 0.04), Vector3(-0.55 + (k % 4) * 0.09, 0.024 + (k / 4) * 0.032, 0.45), "mattoni_crudi" if k % 3 else "argilla_cruda", Vector3(0, (k % 2) * 5, 0)))
	r.add_child(scatola(Vector3(0.1, 0.02, 0.06), Vector3(-0.12, 0.01, 0.6), "cedro_ca"))
	r.add_child(scatola(Vector3(0.07, 0.006, 0.04), Vector3(-0.12, 0.023, 0.6), "buio"))
	var a2 := attrezzo("pala")
	a2.position = Vector3(0.62, 0.02, 0.05)
	a2.rotation_degrees = Vector3(0, 40, 10)
	r.add_child(a2)
	r.add_child(scatola(Vector3(0.16, 0.06, 0.12), Vector3(0.04, 0.03, 0.62), "calce"))
	r.add_child(scatola(Vector3(0.13, 0.004, 0.09), Vector3(0.04, 0.061, 0.62), "acqua_pozzo"))
	r.add_child(_anfora_p(Vector3(-0.02, -0.02, 0.02), 0.85, Vector3(-8, 0, 0)))
	return r


## Fornace cartaginese: bottega, fornace a cilindro di mattoni crudi con la cupola d'argilla, la bocca accesa con la
## cornice a gola e il fumo, file di anfore a siluro appena cotte, anfore crude ad asciugare sul graticcio,
## mucchio d'argilla e legna.
static func fornace_cartaginesi() -> Node3D:
	_mat_ca()
	var r := Node3D.new()
	_bottega_ca(r, Vector3(-0.28, 0, -0.32), 0.42, 0.36, 0.3, 3771, false)
	var f := Vector3(0.42, 0, 0.26)
	r.add_child(cilindro(0.24, 0.26, 0.05, f + Vector3(0, 0.025, 0), "roccia_chiara", Vector3.ZERO, 20))
	r.add_child(cilindro(0.2, 0.22, 0.24, f + Vector3(0, 0.17, 0), "mattoni_crudi", Vector3.ZERO, 20))
	r.add_child(cilindro(0.221, 0.221, 0.02, f + Vector3(0, 0.22, 0), "porpora_ca", Vector3.ZERO, 20))
	r.add_child(sfera(0.2, f + Vector3(0, 0.29, 0), "argilla_cruda", Vector3(1, 0.6, 1)))
	for k in 4:
		var a := deg_to_rad(-30.0 + k * 40.0)
		var t := sfera(0.05, f + Vector3(sin(a), 0, cos(a)) * 0.17 + Vector3(0, 0.33, 0), "fuliggine", Vector3(1.3, 0.7, 0.3))
		t.rotation.y = a
		r.add_child(t)
	r.add_child(cilindro(0.04, 0.045, 0.06, f + Vector3(0, 0.42, 0), "mattoni_crudi", Vector3.ZERO, 10))
	_fumo(r, f + Vector3(0.02, 0.48, 0), 4, 1.0)
	var b := f + Vector3(0, 0, 0.22)
	r.add_child(scatola(Vector3(0.14, 0.12, 0.08), b + Vector3(0, 0.06, 0), "blocchi_greci"))
	r.add_child(scatola(Vector3(0.09, 0.08, 0.02), b + Vector3(0, 0.05, 0.035), "buio"))
	r.add_child(sfera(0.034, b + Vector3(0, 0.03, 0.04), "brace", Vector3(1.2, 0.6, 0.8)))
	_cavetto(r, b + Vector3(0, 0.12, 0.04), 0.12, 0.8)
	_fila_anfore(r, Vector3(-0.66, 0, 0.42), Vector3(0.08, 0, 0), 5, 0.9)
	_fila_anfore(r, Vector3(-0.62, 0, 0.62), Vector3(0.08, 0, 0), 4, 0.85, -14.0)
	r.add_child(scatola(Vector3(0.3, 0.012, 0.14), Vector3(-0.12, 0.13, 0.12), "canne"))
	for x: float in [-0.25, 0.01]:
		r.add_child(cilindro(0.008, 0.008, 0.13, Vector3(x, 0.065, 0.12), "cedro_ca", Vector3.ZERO, 5))
	for k in 3:
		r.add_child(_anfora_p(Vector3(-0.22 + k * 0.08, 0.165, 0.12), 0.65, Vector3(0, 0, -90), "argilla_cruda"))
	r.add_child(mucchio(Vector3(0.7, 0, -0.2), "argilla_cruda", 8, 9))
	legnaia(r, Vector3(0.72, 0, 0.12), 0.2, 3)
	return r


## Porto cartaginese: banchina di pietra squadrata con le bitte, molo di pietra che entra in mare con la nave
## mercantile punica ormeggiata (testa di cavallo a prua, anfore e stoffe porpora), gru di cedro con la rete
## di anfore, emporio a terrazza merlato con le tende porpora, rastrelliera di anfore a siluro, balle porpora,
## banco del cambiavalute con la bilancia, palma e insegna.
static func porto_cartaginesi() -> Node3D:
	_mat_ca()
	var r := Node3D.new()
	# banchina
	r.add_child(scatola(Vector3(0.44, 0.12, 1.12), Vector3(0.36, 0.04, 0.02), "blocchi_greci"))
	r.add_child(scatola(Vector3(0.48, 0.022, 1.16), Vector3(0.36, 0.111, 0.02), "blocchi_greci"))
	for k in 6:
		r.add_child(scatola(Vector3(0.01, 0.004, 1.14), Vector3(0.17 + k * 0.08, 0.123, 0.02), "pietra_scura"))
	# molo di pietra verso il mare
	var pz := 0.2
	r.add_child(scatola(Vector3(0.56, 0.26, 0.26), Vector3(0.86, -0.02, pz), "blocchi_greci"))
	r.add_child(scatola(Vector3(0.58, 0.022, 0.28), Vector3(0.86, 0.111, pz), "blocchi_greci"))
	r.add_child(scatola(Vector3(0.58, 0.03, 0.29), Vector3(0.86, -0.0, pz), "foglie_scure"))
	for x: float in [0.68, 0.98]:
		for s: int in [-1, 1]:
			r.add_child(cilindro(0.016, 0.02, 0.06, Vector3(x, 0.152, pz + s * 0.11), "pietra_scura", Vector3.ZERO, 8))
	for z: float in [-0.42, -0.08]:
		r.add_child(cilindro(0.02, 0.024, 0.06, Vector3(0.54, 0.152, z), "pietra_scura", Vector3.ZERO, 8))
	# nave ormeggiata lungo il molo, con le cime e la passerella
	_nave_ca(r, Vector3(0.88, 0.0, pz + 0.3), 0.0, 1.0)
	for x: float in [0.68, 0.98]:
		ramo(r, Vector3(x, 0.17, pz + 0.11), Vector3(x + (0.08 if x > 0.8 else -0.06), 0.1, pz + 0.24), 0.004, "corda")
	r.add_child(scatola(Vector3(0.05, 0.008, 0.16), Vector3(0.82, 0.13, pz + 0.18), "legno_chiaro", Vector3(-20, 0, 0)))
	_fila_anfore(r, Vector3(0.72, 0.122, pz - 0.06), Vector3(0.07, 0, 0), 4, 0.75)
	r.add_child(cilindro(0.03, 0.03, 0.12, Vector3(1.04, 0.152, pz + 0.02), "porpora_ca", Vector3(0, 0, 90), 10))
	# gru di cedro sulla banchina con la rete di anfore
	var g := Node3D.new()
	g.position = Vector3(0.4, 0.122, -0.3)
	r.add_child(g)
	var cima := Vector3(0.36, 0.62, 0.0)
	for s: int in [-1, 1]:
		ramo(g, Vector3(-0.04, 0, s * 0.12), cima, 0.016, "cedro_ca")
	ramo(g, Vector3(-0.22, 0, 0), cima + Vector3(-0.02, -0.02, 0), 0.012, "cedro_ca")
	g.add_child(cilindro(0.03, 0.03, 0.2, Vector3(0.0, 0.1, 0), "cedro_ca", Vector3(90, 0, 0), 10))
	g.add_child(cilindro(0.032, 0.032, 0.06, Vector3(0.0, 0.1, 0), "corda", Vector3(90, 0, 0), 10))
	g.add_child(cilindro(0.025, 0.025, 0.04, cima, "legno_chiaro", Vector3(90, 0, 0), 10))
	ramo(g, Vector3(0.0, 0.12, 0), cima, 0.004, "corda")
	ramo(g, cima, cima + Vector3(0, -0.3, 0), 0.004, "corda")
	for k in 3:
		g.add_child(_anfora_p(cima + Vector3(-0.03 + k * 0.03, -0.5, (k - 1) * 0.02), 0.6, Vector3(0, k * 40, (k - 1) * 10)))
	g.add_child(sfera(0.06, cima + Vector3(0, -0.4, 0), "rete", Vector3(1, 1.4, 1)))
	g.add_child(scatola(Vector3(0.05, 0.03, 0.004), cima + Vector3(0, 0.03, 0), "porpora_ca"))
	# emporio del porto
	var lx := 0.6
	var lz := 0.42
	var c := _casa_ca(r, Vector3(-0.3, 0, -0.3), lx, lz, 0.38, 3781, true)
	var top: float = c.get_meta("top")
	_porta_ca(c, Vector3(-0.1, 0.06, lz * 0.5), 0.0, 0.13, 0.18, true)
	_finestra_ca(c, Vector3(0.17, 0.32, lz * 0.5), 0.0)
	_finestra_ca(c, Vector3(lx * 0.5, 0.32, 0.0), 90.0)
	_tenda(c, Vector3(-0.08, top, -0.02), 0.36, 0.28, 0.18, 0.14, 0.0, "tenda_porpora_ca", true)
	c.add_child(_anfora_p(Vector3(0.18, top, -0.1), 0.7, Vector3(-10, 0, 0)))
	c.add_child(_anfora_p(Vector3(0.24, top, -0.06), 0.65, Vector3(-10, 0, 8)))
	var pd := 0.22
	c.add_child(scatola(Vector3(lx + 0.06, 0.04, pd + 0.02), Vector3(0, 0.02, lz * 0.5 + pd * 0.5), "blocchi_greci"))
	_tenda(c, Vector3(0, 0.04, lz * 0.5 + pd * 0.5), lx + 0.04, pd, 0.32, 0.27, 0.0, "tenda_porpora_ca", false)
	r.add_child(scatola(Vector3(0.6, 0.012, 0.5), Vector3(-0.15, 0.006, 0.34), "sabbia"))
	_rastrelliera_anfore(r, Vector3(-0.46, 0, 0.42), 0.0, 3)
	_fila_anfore(r, Vector3(-0.62, 0, 0.66), Vector3(0.075, 0, 0), 4, 0.9)
	for i in 2:
		r.add_child(cilindro(0.035, 0.035, 0.16, Vector3(-0.1 + i * 0.09, 0.035, 0.42), "porpora_ca" if i == 0 else "porpora_chiara_ca", Vector3(0, 20, 90), 10))
	r.add_child(cassa(Vector3(0.07, 0, 0.45), 10))
	_banco_bilancia(r, Vector3(-0.08, 0, 0.64), 0.0)
	_palma(r, Vector3(-0.72, 0, 0.2), 0.95, 3782)
	_insegna_ca(r, Vector3(0.5, 0.122, 0.48), 0.55)
	return r


## Pozzo cartaginese: vera quadrata intonacata di calce con la riga porpora e il segno di Tanit, due pilastri di
## pietra e la trave di cedro con la carrucola, secchio di bronzo, abbeveratoio, anfore a siluro, palma piccola.
static func pozzo_cartaginesi() -> Node3D:
	_mat_ca()
	var r := Node3D.new()
	r.add_child(scatola(Vector3(0.4, 0.03, 0.4), Vector3(0, 0.015, 0), "roccia_chiara"))
	r.add_child(scatola(Vector3(0.3, 0.16, 0.3), Vector3(0, 0.11, 0), "calce"))
	r.add_child(scatola(Vector3(0.305, 0.014, 0.305), Vector3(0, 0.17, 0), "porpora_ca"))
	r.add_child(scatola(Vector3(0.33, 0.02, 0.33), Vector3(0, 0.2, 0), "blocchi_greci"))
	r.add_child(scatola(Vector3(0.2, 0.005, 0.2), Vector3(0, 0.211, 0), "acqua_pozzo"))
	_tanit(r, Vector3(0, 0.09, 0.152), 1.1, "porpora_ca")
	for lato: int in [-1, 1]:
		r.add_child(scatola(Vector3(0.05, 0.42, 0.05), Vector3(lato * 0.14, 0.42, -0.02), "blocchi_greci"))
		r.add_child(scatola(Vector3(0.07, 0.025, 0.07), Vector3(lato * 0.14, 0.64, -0.02), "calce"))
	r.add_child(scatola(Vector3(0.38, 0.03, 0.04), Vector3(0, 0.67, -0.02), "cedro_ca"))
	r.add_child(cilindro(0.03, 0.03, 0.02, Vector3(0, 0.63, -0.02), "legno_chiaro", Vector3(90, 0, 0), 12))
	r.add_child(cilindro(0.003, 0.003, 0.3, Vector3(0.0, 0.47, 0.01), "corda", Vector3.ZERO, 3))
	r.add_child(cilindro(0.028, 0.022, 0.045, Vector3(0.0, 0.31, 0.01), "bronzo", Vector3.ZERO, 10))
	r.add_child(_toro(0.025, 0.029, Vector3(0, 0.34, 0.01), "bronzo", Vector3(90, 0, 0)))
	r.add_child(scatola(Vector3(0.24, 0.06, 0.1), Vector3(0.28, 0.03, 0.2), "calce", Vector3(0, -40, 0)))
	r.add_child(scatola(Vector3(0.2, 0.005, 0.07), Vector3(0.28, 0.061, 0.2), "acqua_pozzo", Vector3(0, -40, 0)))
	_fila_anfore(r, Vector3(-0.3, 0, 0.12), Vector3(0.06, 0, 0.08), 3, 0.75)
	_palma(r, Vector3(-0.32, 0, -0.22), 0.7, 3791)
	r.scale = Vector3.ONE * 1.2
	return r


## Fattoria cartaginese: bottega a terrazza, granaio intonacato con le cupolette di mattoni crudi, aia lastricata con
## i covoni, campo di grano dentro il muretto intonacato, palma da dattero, asino, galline e anfora.
static func fattoria_cartaginesi() -> Node3D:
	_mat_ca()
	var r := Node3D.new()
	_bottega_ca(r, Vector3(-0.22, 0, -0.26), 0.5, 0.4, 0.32, 3801)
	var g := Vector3(0.72, 0, -0.28)
	r.add_child(scatola(Vector3(0.3, 0.2, 0.3), g + Vector3(0, 0.1, 0), "sabbia_ca"))
	r.add_child(scatola(Vector3(0.31, 0.02, 0.31), g + Vector3(0, 0.2, 0), "calce"))
	for i in 2:
		for j in 2:
			var p := g + Vector3(-0.07 + i * 0.14, 0.21, -0.07 + j * 0.14)
			r.add_child(sfera(0.07, p, "mattoni_crudi", Vector3(1, 1.0, 1)))
			r.add_child(cilindro(0.016, 0.02, 0.03, p + Vector3(0, 0.075, 0), "calce", Vector3.ZERO, 8))
	r.add_child(scatola(Vector3(0.08, 0.1, 0.02), g + Vector3(0, 0.07, 0.155), "cedro_ca"))
	r.add_child(scatola(Vector3(0.012, 0.012, 0.25), g + Vector3(-0.1, 0.12, 0.2), "cedro_ca", Vector3(-55, 0, 0)))
	var a := Vector3(-0.35, 0, 0.5)
	r.add_child(cilindro(0.26, 0.27, 0.02, a + Vector3(0, 0.01, 0), "roccia_chiara", Vector3.ZERO, 20))
	r.add_child(cilindro(0.22, 0.22, 0.005, a + Vector3(0, 0.022, 0), "paglia", Vector3.ZERO, 20))
	for i in 4:
		var cv := covone(1.15)
		cv.position = a + Vector3(-0.15 + i * 0.1, 0.02, -0.05 + (i % 2) * 0.1)
		cv.rotation_degrees.z = 8 * (i % 2 * 2 - 1)
		r.add_child(cv)
	var c := Vector3(0.45, 0, 0.45)
	r.add_child(scatola(Vector3(0.42, 0.012, 0.36), c + Vector3(0, 0.006, 0), "terra"))
	for i in 7:
		for j in 5:
			r.add_child(cilindro(0.012, 0.016, 0.1, c + Vector3(-0.18 + i * 0.06, 0.05, -0.14 + j * 0.07), "grano", Vector3.ZERO, 5))
	_muretto_ca(r, c + Vector3(-0.23, 0, 0.21), c + Vector3(0.25, 0, 0.21), 0.07, 0.05)
	_muretto_ca(r, c + Vector3(0.25, 0, -0.2), c + Vector3(0.25, 0, 0.21), 0.07, 0.05)
	r.add_child(asino(Vector3(0.18, 0, 0.0), 120))
	for i in 3:
		r.add_child(sfera(0.025, Vector3(0.05 + i * 0.07, 0.03, 0.22 - i * 0.03), "intonaco", Vector3(1.3, 1, 1)))
		r.add_child(sfera(0.008, Vector3(0.08 + i * 0.07, 0.05, 0.22 - i * 0.03), "geranio"))
	_palma(r, Vector3(-0.72, 0, 0.05), 0.9, 3802)
	r.add_child(sacco(Vector3(0.48, 0, 0.0), 0.3))
	r.add_child(_anfora_p(Vector3(0.56, -0.02, 0.04), 0.8, Vector3(-8, 0, 0)))
	return r


## Mulino cartaginese: bottega, macina «a clessidra» di pietra scura girata dall'asino sulla base tonda,
## tettoia di cedro e palma, sacchi di farina, covone, anfora e cesta di pane.
static func mulino_cartaginesi() -> Node3D:
	_mat_ca()
	var r := Node3D.new()
	_bottega_ca(r, Vector3(-0.22, 0, -0.27), 0.5, 0.4, 0.36, 3811)
	var m := Vector3(-0.28, 0, 0.48)
	r.add_child(cilindro(0.22, 0.24, 0.05, m + Vector3(0, 0.025, 0), "blocchi_greci", Vector3.ZERO, 20))
	r.add_child(cilindro(0.19, 0.19, 0.005, m + Vector3(0, 0.051, 0), "lino", Vector3.ZERO, 20))
	r.add_child(cilindro(0.09, 0.03, 0.14, m + Vector3(0, 0.12, 0), "pietra_scura", Vector3.ZERO, 14))
	r.add_child(cilindro(0.04, 0.085, 0.09, m + Vector3(0, 0.14, 0), "pietra_scura", Vector3.ZERO, 14))
	r.add_child(cilindro(0.085, 0.04, 0.09, m + Vector3(0, 0.23, 0), "pietra_scura", Vector3.ZERO, 14))
	r.add_child(cilindro(0.04, 0.04, 0.004, m + Vector3(0, 0.276, 0), "grano", Vector3.ZERO, 12))
	for lato: int in [-1, 1]:
		r.add_child(scatola(Vector3(0.03, 0.04, 0.03), m + Vector3(lato * 0.075, 0.18, 0), "cedro_ca"))
	r.add_child(scatola(Vector3(0.5, 0.025, 0.025), m + Vector3(0.12, 0.19, 0), "cedro_ca"))
	r.add_child(asino(m + Vector3(0.38, 0, 0.0), 90))
	_tettoia_ca(r, m + Vector3(0.02, 0, -0.04), 0.5, 0.3, 0.42, 3812)
	for i in 5:
		r.add_child(sacco(Vector3(0.45 + (i % 3) * 0.12, 0.0, -0.1 + (i / 3) * 0.13), i * 0.7))
	var cv := covone(1.1)
	cv.position = Vector3(0.6, 0, 0.42)
	r.add_child(cv)
	r.add_child(_anfora_p(Vector3(0.3, -0.02, 0.3), 0.9, Vector3(-8, 0, 0)))
	r.add_child(cesta(Vector3(0.12, 0, 0.66), "pane", 0.9))
	return r


## Forno cartaginese: bottega, due forni tannur d'argilla con le braci e il fumo sotto la tettoia, banco
## intonacato con le focacce tonde, ceste di pane, legna, sacco di farina e anfore.
static func forno_cartaginesi() -> Node3D:
	_mat_ca()
	var r := Node3D.new()
	_bottega_ca(r, Vector3(-0.22, 0, -0.27), 0.5, 0.4, 0.34, 3821)
	_tannur(r, Vector3(0.42, 0, 0.32), 1.35)
	_tannur(r, Vector3(0.66, 0, 0.0), 1.1, false)
	_tettoia_ca(r, Vector3(0.52, 0, 0.18), 0.4, 0.46, 0.44, 3822)
	legnaia(r, Vector3(0.72, 0, 0.5), 0.2, 3)
	r.add_child(scatola(Vector3(0.32, 0.03, 0.15), Vector3(-0.3, 0.1, 0.55), "calce"))
	r.add_child(scatola(Vector3(0.3, 0.085, 0.13), Vector3(-0.3, 0.042, 0.55), "sabbia_ca"))
	for i in 5:
		r.add_child(cilindro(0.03, 0.028, 0.012, Vector3(-0.42 + i * 0.06, 0.122, 0.55 + (i % 2) * 0.03), "pane", Vector3.ZERO, 12))
	r.add_child(cesta(Vector3(-0.62, 0, 0.42), "pane"))
	r.add_child(cesta(Vector3(0.05, 0, 0.66), "pane"))
	r.add_child(sacco(Vector3(-0.68, 0, 0.15), 0.4))
	_fila_anfore(r, Vector3(0.1, 0, 0.32), Vector3(0.05, 0, 0.07), 2, 0.85)
	return r


## Porcile cartaginese: casetta, recinto di muretti intonacati con il cancello di cedro, truogolo di pietra,
## maiali nel fango, palma, sacco e anfora.
static func porcile_cartaginesi() -> Node3D:
	_mat_ca()
	var r := Node3D.new()
	_bottega_ca(r, Vector3(-0.3, 0, -0.3), 0.4, 0.34, 0.28, 3831, false)
	var a := Vector3(0.05, 0, 0.0)
	r.add_child(scatola(Vector3(0.8, 0.012, 0.75), a + Vector3(0.12, 0.006, 0.12), "terra"))
	_muretto_ca(r, a + Vector3(-0.28, 0, 0.5), a + Vector3(0.28, 0, 0.5), 0.08, 0.06)
	for k in 5:
		r.add_child(scatola(Vector3(0.012, 0.09, 0.012), a + Vector3(0.31 + k * 0.045, 0.045, 0.5), "cedro_ca"))
	for y: float in [0.03, 0.07]:
		r.add_child(scatola(Vector3(0.2, 0.014, 0.012), a + Vector3(0.4, y, 0.5), "cedro_ca"))
	_muretto_ca(r, a + Vector3(0.52, 0, -0.26), a + Vector3(0.52, 0, 0.53), 0.08, 0.06)
	_muretto_ca(r, a + Vector3(0.15, 0, -0.26), a + Vector3(0.55, 0, -0.26), 0.08, 0.06)
	r.add_child(sfera(0.14, a + Vector3(0.28, 0.0, 0.05), "fuliggine", Vector3(1.4, 0.1, 1.0)))
	r.add_child(scatola(Vector3(0.24, 0.05, 0.08), a + Vector3(0.0, 0.025, 0.4), "roccia_chiara"))
	r.add_child(scatola(Vector3(0.2, 0.008, 0.05), a + Vector3(0.0, 0.051, 0.4), "grano"))
	for p: Array in [[Vector3(0.25, 0, 0.3), 20], [Vector3(0.38, 0, -0.05), 130], [Vector3(0.05, 0, 0.18), -60], [Vector3(0.4, 0, 0.32), 200]]:
		r.add_child(maiale(a + (p[0] as Vector3), p[1]))
	r.add_child(sacco(Vector3(-0.62, 0, 0.3), 0.3))
	r.add_child(_anfora_p(Vector3(-0.48, -0.02, 0.42), 0.8, Vector3(-8, 0, 0)))
	_palma(r, Vector3(-0.7, 0, -0.1), 0.65, 3832)
	return r


## Macelleria cartaginese: bottega, tettoia di cedro con la carne appesa, banco intonacato con il drappo porpora,
## ceppo con la mannaia, anfore, maiale e insegna.
static func macelleria_cartaginesi() -> Node3D:
	_mat_ca()
	var r := Node3D.new()
	_bottega_ca(r, Vector3(-0.2, 0, -0.25), 0.5, 0.42, 0.36, 3841)
	_tettoia_ca(r, Vector3(0.45, 0, 0.42), 0.56, 0.24, 0.38, 3842)
	r.add_child(cilindro(0.01, 0.01, 0.56, Vector3(0.45, 0.3, 0.5), "cedro_ca", Vector3(0, 0, 90), 5))
	for k in 5:
		var x := 0.25 + k * 0.1
		r.add_child(cilindro(0.003, 0.003, 0.05, Vector3(x, 0.275, 0.5), "corda", Vector3.ZERO, 3))
		if k % 2 == 0:
			r.add_child(sfera(0.035, Vector3(x, 0.215, 0.5), "carne", Vector3(0.9, 1.4, 0.8)))
		else:
			r.add_child(cilindro(0.016, 0.016, 0.1, Vector3(x, 0.205, 0.5), "carne", Vector3.ZERO, 8))
	var b := Vector3(-0.35, 0, 0.55)
	r.add_child(scatola(Vector3(0.32, 0.09, 0.14), b + Vector3(0, 0.045, 0), "sabbia_ca"))
	r.add_child(scatola(Vector3(0.34, 0.02, 0.16), b + Vector3(0, 0.1, 0), "calce"))
	r.add_child(scatola(Vector3(0.3, 0.05, 0.004), b + Vector3(0, 0.06, 0.072), "porpora_ca"))
	r.add_child(sfera(0.04, b + Vector3(-0.05, 0.125, 0), "carne", Vector3(1.2, 0.5, 0.9)))
	r.add_child(scatola(Vector3(0.07, 0.004, 0.02), b + Vector3(0.08, 0.112, 0.02), "ferro", Vector3(0, 30, 0)))
	r.add_child(cilindro(0.07, 0.075, 0.1, Vector3(-0.65, 0.05, 0.38), "corteccia", Vector3.ZERO, 12))
	r.add_child(scatola(Vector3(0.06, 0.04, 0.01), Vector3(-0.64, 0.12, 0.38), "ferro", Vector3(0, 0, 15)))
	_fila_anfore(r, Vector3(0.66, 0, -0.05), Vector3(0, 0, 0.08), 2, 0.85)
	r.add_child(maiale(Vector3(-0.6, 0, 0.0), 60))
	_insegna_ca(r, Vector3(0.12, 0, 0.12), 0.55)
	return r


## Ovile cartaginese: casetta, stazzo tondo di muretti intonacati con le pecore, abbeveratoio di calce, bastone
## del pastore, lana tosata e anfora.
static func ovile_cartaginesi() -> Node3D:
	_mat_ca()
	var r := Node3D.new()
	_bottega_ca(r, Vector3(-0.38, 0, -0.38), 0.4, 0.34, 0.28, 3851, false)
	var a := Vector3(0.18, 0, 0.18)
	for k in 10:
		if k == 6:
			continue
		var a0 := deg_to_rad(-150.0 + k * 30.0)
		var a1 := deg_to_rad(-150.0 + (k + 1) * 30.0)
		_muretto_ca(r, a + Vector3(cos(a0), 0, sin(a0)) * 0.42, a + Vector3(cos(a1), 0, sin(a1)) * 0.42, 0.08, 0.05)
	for p: Array in [[Vector3(0.0, 0, 0.1), 30], [Vector3(0.15, 0, -0.1), 160], [Vector3(0.2, 0, 0.18), -40],
			[Vector3(-0.15, 0, 0.18), 90], [Vector3(0.05, 0, -0.22), 210]]:
		r.add_child(pecora(a + p[0], p[1]))
	r.add_child(scatola(Vector3(0.22, 0.05, 0.07), a + Vector3(-0.15, 0.025, -0.1), "calce", Vector3(0, 30, 0)))
	r.add_child(scatola(Vector3(0.18, 0.005, 0.04), a + Vector3(-0.15, 0.051, -0.1), "acqua_pozzo", Vector3(0, 30, 0)))
	r.add_child(cilindro(0.007, 0.006, 0.36, Vector3(-0.07, 0.17, -0.04), "cedro_ca", Vector3(0, 0, -10), 5))
	r.add_child(_toro(0.012, 0.02, Vector3(-0.1, 0.35, -0.04), "cedro_ca", Vector3(90, 0, 0)))
	r.add_child(sfera(0.06, Vector3(-0.6, 0.04, 0.3), "lana", Vector3(1.2, 0.6, 1.0)))
	r.add_child(sfera(0.05, Vector3(-0.52, 0.035, 0.4), "lana", Vector3(1.2, 0.6, 1.0)))
	r.add_child(_anfora_p(Vector3(-0.7, -0.02, 0.1), 0.85, Vector3(-8, 0, 0)))
	return r


## Capraio cartaginese: casetta, rocce d'arenaria con le capre, muretto intonacato, graticcio di cedro e canne
## con i formaggi a stagionare, anfora del latte e palma.
static func capraio_cartaginesi() -> Node3D:
	_mat_ca()
	var r := Node3D.new()
	_bottega_ca(r, Vector3(-0.34, 0, -0.34), 0.36, 0.3, 0.26, 3861, false)
	var a := Vector3(0.15, 0, 0.15)
	r.add_child(sfera(0.16, a + Vector3(0.2, 0.0, -0.1), "tufo", Vector3(1.2, 0.85, 1.0)))
	r.add_child(sfera(0.1, a + Vector3(-0.05, 0.0, 0.3), "roccia_chiara", Vector3(1.3, 0.7, 1.0)))
	r.add_child(sfera(0.07, a + Vector3(0.38, 0.0, 0.1), "roccia_massi", Vector3(1.3, 0.8, 1.0)))
	r.add_child(capra(a + Vector3(0.2, 0.12, -0.1), 40))
	r.add_child(capra(a + Vector3(0.0, 0, 0.1), 200))
	r.add_child(capra(a + Vector3(0.35, 0, 0.3), -30))
	r.add_child(capra(a + Vector3(-0.1, 0.06, 0.3), 110))
	_muretto_ca(r, a + Vector3(-0.4, 0, 0.52), a + Vector3(0.5, 0, 0.52), 0.08, 0.05)
	var f := Vector3(-0.62, 0, 0.3)
	for x: float in [-0.08, 0.08]:
		for z: float in [-0.06, 0.06]:
			r.add_child(cilindro(0.008, 0.008, 0.16, f + Vector3(x, 0.08, z), "cedro_ca", Vector3.ZERO, 5))
	r.add_child(scatola(Vector3(0.2, 0.012, 0.16), f + Vector3(0, 0.16, 0), "canne"))
	for k in 4:
		r.add_child(cilindro(0.025, 0.025, 0.024, f + Vector3(-0.055 + (k % 2) * 0.1, 0.178, -0.035 + (k / 2) * 0.07), "formaggio", Vector3.ZERO, 10))
	r.add_child(_anfora_p(Vector3(-0.42, -0.02, 0.5), 0.8, Vector3(-8, 0, 0)))
	_palma(r, Vector3(0.55, 0, -0.45), 0.6, 3862)
	return r


## Apiario cartaginese: casetta, banchi di mattoni crudi intonacati con le arnie a tubo di terracotta coricate a file
## (fascia porpora, tappo e foro di volo), fiori tutto intorno, palma, vasetti di miele e anfora.
static func apiario_cartaginesi() -> Node3D:
	_mat_ca()
	var r := Node3D.new()
	_bottega_ca(r, Vector3(-0.38, 0, -0.38), 0.32, 0.28, 0.26, 3871, false)
	for f in 2:
		var z := 0.12 + f * 0.27
		r.add_child(scatola(Vector3(0.78, 0.07, 0.15), Vector3(0.15, 0.035, z), "sabbia_ca"))
		r.add_child(scatola(Vector3(0.8, 0.012, 0.17), Vector3(0.15, 0.076, z), "calce"))
		for liv in 2:
			for k in 5 - liv:
				var x := -0.15 + k * 0.15 + liv * 0.075
				var p := Vector3(x, 0.118 + liv * 0.072, z)
				r.add_child(cilindro(0.036, 0.036, 0.16, p, "terracotta", Vector3(90, 0, 0), 12))
				r.add_child(cilindro(0.037, 0.037, 0.01, p + Vector3(0, 0, 0.03), "porpora_ca", Vector3(90, 0, 0), 12))
				r.add_child(cilindro(0.033, 0.033, 0.01, p + Vector3(0, 0, 0.078), "argilla_cruda", Vector3(90, 0, 0), 12))
				r.add_child(sfera(0.007, p + Vector3(0, -0.01, 0.085), "buio"))
	var rng := _rng(3872)
	for k in 30:
		var p := Vector3(rng.randf_range(-0.7, 0.7), 0.0, rng.randf_range(0.6, 0.75))
		if k % 2 == 0:
			p = Vector3(rng.randf_range(0.6, 0.75), 0.0, rng.randf_range(-0.3, 0.6))
		r.add_child(sfera(0.018, p + Vector3(0, 0.02, 0), "orto"))
		r.add_child(sfera(0.012, p + Vector3(0, 0.04, 0), ["fiore", "geranio", "miele"][k % 3]))
	_palma(r, Vector3(0.5, 0, -0.42), 0.7, 3873)
	for k in 3:
		r.add_child(cilindro(0.022, 0.018, 0.04, Vector3(-0.6 + k * 0.06, 0.02, 0.22 + (k % 2) * 0.05), "terracotta", Vector3.ZERO, 10))
		r.add_child(cilindro(0.017, 0.017, 0.004, Vector3(-0.6 + k * 0.06, 0.041, 0.22 + (k % 2) * 0.05), "miele", Vector3.ZERO, 10))
	r.add_child(_anfora_p(Vector3(-0.66, -0.02, 0.4), 0.8, Vector3(-8, 0, 0)))
	return r


## Caseificio cartaginese: bottega, paiolo di bronzo col latte sul fuoco fra tre pali di cedro, scaffali di cedro
## e canne con le forme di formaggio sotto la tettoia, anfore del latte.
static func caseificio_cartaginesi() -> Node3D:
	_mat_ca()
	var r := Node3D.new()
	_bottega_ca(r, Vector3(-0.2, 0, -0.25), 0.5, 0.42, 0.36, 3881)
	var f := Vector3(0.45, 0, 0.45)
	_fuoco(r, f, 1.0)
	r.add_child(cilindro(0.08, 0.06, 0.08, f + Vector3(0, 0.14, 0), "bronzo", Vector3.ZERO, 14))
	r.add_child(cilindro(0.072, 0.072, 0.004, f + Vector3(0, 0.18, 0), "latte", Vector3.ZERO, 14))
	for k in 3:
		var a := k * TAU / 3 + 0.5
		ramo(r, f + Vector3(cos(a) * 0.15, 0, sin(a) * 0.15), f + Vector3(0, 0.34, 0), 0.008, "cedro_ca")
	r.add_child(cilindro(0.004, 0.004, 0.14, f + Vector3(0, 0.26, 0), "corda", Vector3.ZERO, 3))
	_fumo(r, f + Vector3(0, 0.24, 0), 2, 0.6)
	_tettoia_ca(r, Vector3(-0.3, 0, 0.5), 0.4, 0.2, 0.34, 3882)
	for p: Vector3 in [Vector3(-0.3, 0, 0.5), Vector3(0.7, 0, -0.05)]:
		var lungo_x := p.x < 0
		for liv in 3:
			r.add_child(scatola(Vector3(0.28 if lungo_x else 0.08, 0.012, 0.08 if lungo_x else 0.28), p + Vector3(0, 0.05 + liv * 0.08, 0), "canne"))
			for k in 3:
				var o := Vector3((k - 1) * 0.085, 0, 0) if lungo_x else Vector3(0, 0, (k - 1) * 0.085)
				r.add_child(cilindro(0.033, 0.033, 0.035, p + o + Vector3(0, 0.074 + liv * 0.08, 0), "formaggio", Vector3.ZERO, 12))
		if not lungo_x:
			for s: int in [-1, 1]:
				r.add_child(cilindro(0.008, 0.009, 0.24, p + Vector3(0, 0.12, s * 0.15), "cedro_ca", Vector3.ZERO, 5))
	_fila_anfore(r, Vector3(0.05, 0, 0.62), Vector3(0.09, 0, 0), 2, 0.85)
	return r
