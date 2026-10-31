extends RefCounted
## Modelli 3D costruiti in codice per lo studio di rendering.
## Unità: 1 = una casella. Asse Y verso l'alto. La camera guarda dal lato +X/+Z,
## quindi le facce "in vista" sono +Z (sinistra, illuminata) e +X (destra, in ombra).

static var _cache_mat := {}
static var _rumore_rgb: ImageTexture
const SHADER_VISSUTO := preload("res://tools/studio/vissuto.gdshader")

# materiali che restano "semplici" (metallo, stoffa sottile, acqua)
const MATERIALI_SEMPLICI := ["ferro", "stoffa", "acqua_pozzo", "buio"]
# regolazioni per materiale: [sporco, macchie, saturazione]
const REGOLAZIONI := {
	"aghi": [0.0, 0.0, 1.3], "foglie_ulivo": [0.0, 0.0, 1.2], "foglie": [0.0, 0.0, 1.35], "foglie_scure": [0.0, 0.0, 1.3],
	"macchia": [0.0, 0.0, 1.3], "fiore": [0.0, 0.0, 1.2], "tegola": [0.15, 0.5, 1.2], "tegola_scura": [0.15, 0.5, 1.2],
	"marmo": [0.35, 0.3, 1.0], "intonaco": [0.55, 0.45, 1.1], "tunica": [0.0, 0.0, 1.1], "pelle": [0.0, 0.0, 1.1],
	"capelli": [0.0, 0.0, 1.0], "giocatore": [0.0, 0.0, 1.3], "sandali": [0.0, 0.0, 1.0], "corda": [0.0, 0.0, 1.0],
	"persiana": [0.2, 0.3, 1.2], "lino": [0.2, 0.2, 1.1], "terracotta": [0.25, 0.3, 1.25],
}


static func catalogo() -> Dictionary:
	return {
		"casa_greca": {"crea": casa_greca, "dimensione": Vector2i(256, 256), "ancora": Vector2(128, 196)},
		"pino_1": {"crea": pino.bind(1), "dimensione": Vector2i(160, 240), "ancora": Vector2(80, 214)},
		"pino_2": {"crea": pino.bind(2), "dimensione": Vector2i(160, 240), "ancora": Vector2(80, 214)},
		"pino_3": {"crea": pino.bind(3), "dimensione": Vector2i(160, 240), "ancora": Vector2(80, 214)},
		"pino_4": {"crea": pino.bind(4), "dimensione": Vector2i(160, 240), "ancora": Vector2(80, 214)},
		"ulivo_1": {"crea": ulivo.bind(3), "dimensione": Vector2i(176, 176), "ancora": Vector2(88, 150)},
		"ulivo_2": {"crea": ulivo.bind(7), "dimensione": Vector2i(176, 176), "ancora": Vector2(88, 150)},
		"ulivo_3": {"crea": ulivo.bind(11), "dimensione": Vector2i(176, 176), "ancora": Vector2(88, 150)},
		"rocce_1": {"crea": rocce.bind(1), "dimensione": Vector2i(128, 112), "ancora": Vector2(64, 80)},
		"rocce_2": {"crea": rocce.bind(2), "dimensione": Vector2i(128, 112), "ancora": Vector2(64, 80)},
		"rocce_3": {"crea": rocce.bind(3), "dimensione": Vector2i(128, 112), "ancora": Vector2(64, 80)},
		"cespuglio_1": {"crea": cespuglio.bind(1), "dimensione": Vector2i(96, 80), "ancora": Vector2(48, 60)},
		"cespuglio_2": {"crea": cespuglio.bind(2), "dimensione": Vector2i(96, 80), "ancora": Vector2(48, 60)},
		"cava": {"crea": cava, "dimensione": Vector2i(256, 240), "ancora": Vector2(128, 186)},
		"guardaboschi": {"crea": guardaboschi, "dimensione": Vector2i(256, 240), "ancora": Vector2(128, 186)},
		"torre": {"crea": torre, "dimensione": Vector2i(224, 320), "ancora": Vector2(112, 270)},
		"pozzo": {"crea": pozzo, "dimensione": Vector2i(192, 192), "ancora": Vector2(96, 140)},
		"cantiere_0": {"crea": cantiere.bind(0), "dimensione": Vector2i(224, 208), "ancora": Vector2(112, 160)},
		"cantiere_1": {"crea": cantiere.bind(1), "dimensione": Vector2i(224, 208), "ancora": Vector2(112, 160)},
		"cantiere_2": {"crea": cantiere.bind(2), "dimensione": Vector2i(224, 208), "ancora": Vector2(112, 160)},
		"bandierina": {"crea": bandierina, "dimensione": Vector2i(64, 96), "ancora": Vector2(24, 82)},
		"magazzino": {"crea": magazzino, "dimensione": Vector2i(384, 320), "ancora": Vector2(192, 230)},
		"boscaiolo": {"crea": boscaiolo, "dimensione": Vector2i(256, 256), "ancora": Vector2(128, 196)},
		"segheria": {"crea": segheria, "dimensione": Vector2i(288, 272), "ancora": Vector2(144, 206)},
		"frantoio": {"crea": frantoio, "dimensione": Vector2i(288, 272), "ancora": Vector2(144, 206)},
		"portatore_nessuno": {"crea": portatore.bind(""), "posa": posa_cammino, "fotogrammi": 8, "direzioni": 8,
			"dimensione": Vector2i(80, 80), "ancora": Vector2(34, 68)},
		"portatore_tronco": {"crea": portatore.bind("tronco"), "posa": posa_cammino, "fotogrammi": 8, "direzioni": 8,
			"dimensione": Vector2i(80, 80), "ancora": Vector2(34, 68)},
		"portatore_asse": {"crea": portatore.bind("asse"), "posa": posa_cammino, "fotogrammi": 8, "direzioni": 8,
			"dimensione": Vector2i(80, 80), "ancora": Vector2(34, 68)},
		"portatore_anfora": {"crea": portatore.bind("anfora"), "posa": posa_cammino, "fotogrammi": 8, "direzioni": 8,
			"dimensione": Vector2i(80, 80), "ancora": Vector2(34, 68)},
		"portatore_pietra": {"crea": portatore.bind("pietra"), "posa": posa_cammino, "fotogrammi": 8, "direzioni": 8,
			"dimensione": Vector2i(80, 80), "ancora": Vector2(34, 68)},
		"merce_assi": {"crea": merce.bind("assi"), "dimensione": Vector2i(48, 40), "ancora": Vector2(24, 30)},
		"merce_tronchi": {"crea": merce.bind("tronchi"), "dimensione": Vector2i(48, 40), "ancora": Vector2(24, 30)},
		"merce_pietra": {"crea": merce.bind("pietra"), "dimensione": Vector2i(48, 40), "ancora": Vector2(24, 30)},
	}


# ------------------------------------------------------------------ materiali

static func _rumore(seme: int, frequenza: float, c1: Color, c2: Color, dim := 128) -> ImageTexture:
	var n := FastNoiseLite.new()
	n.seed = seme
	n.frequency = frequenza
	n.fractal_octaves = 4
	var img := n.get_seamless_image(dim, dim)
	img.convert(Image.FORMAT_RGBA8)
	for y in dim:
		for x in dim:
			var v := img.get_pixel(x, y).r
			img.set_pixel(x, y, c1.lerp(c2, v))
	img.generate_mipmaps()
	return ImageTexture.create_from_image(img)


static func materiale(nome: String) -> Material:
	if _cache_mat.has(nome):
		return _cache_mat[nome]
	var m := StandardMaterial3D.new()
	m.roughness = 0.9
	m.uv1_triplanar = true
	match nome:
		"intonaco":
			m.albedo_texture = _rumore(1, 0.09, Color("d6c9ae"), Color("f7f1e4"))
			m.uv1_scale = Vector3(2, 2, 2)
		"intonaco_sporco":
			m.albedo_texture = _rumore(2, 0.03, Color("b9ab8f"), Color("ddd2bb"))
			m.uv1_scale = Vector3(2, 2, 2)
		"pietra":
			m.albedo_texture = _rumore(3, 0.09, Color("8f8270"), Color("c4b69c"))
			m.uv1_scale = Vector3(3, 3, 3)
		"tegola":
			m.albedo_texture = _rumore(4, 0.11, Color("6e2f1d"), Color("a14c2e"))
			m.uv1_scale = Vector3(4, 4, 4)
		"tegola_scura":
			m.albedo_texture = _rumore(5, 0.08, Color("5c2616"), Color("853b22"))
		"legno":
			m.albedo_texture = _rumore(6, 0.15, Color("5a3a22"), Color("8a5a32"))
			m.uv1_scale = Vector3(1, 6, 1)
		"legno_scuro":
			m.albedo_texture = _rumore(7, 0.12, Color("2e1d12"), Color("4a2e1c"))
		"corteccia":
			m.albedo_texture = _rumore(8, 0.2, Color("3d2818"), Color("6b4a30"))
			m.uv1_scale = Vector3(2, 8, 2)
		"aghi":
			m.albedo_texture = _rumore(9, 0.25, Color("15301a"), Color("35592f"))
			m.uv1_scale = Vector3(4, 4, 4)
		"foglie_ulivo":
			m.albedo_texture = _rumore(10, 0.3, Color("3f5a33"), Color("8c9d74"))
			m.uv1_scale = Vector3(5, 5, 5)
		"terracotta":
			m.albedo_texture = _rumore(11, 0.1, Color("a8582f"), Color("c97a4a"))
			m.roughness = 0.75
		"legno_chiaro":
			m.albedo_texture = _rumore(12, 0.2, Color("b88a55"), Color("e0bd88"))
			m.uv1_scale = Vector3(1, 5, 1)
		"lino":
			m.albedo_texture = _rumore(13, 0.3, Color("c9b48a"), Color("e8d9b4"))
		"marmo":
			m.albedo_texture = _rumore(14, 0.05, Color("e2dccf"), Color("fbfaf6"))
		"ferro":
			m.albedo_color = Color("7d8287")
			m.metallic = 0.6
			m.roughness = 0.45
		"pelle":
			m.albedo_color = Color("d39a72")
		"capelli":
			m.albedo_color = Color("3a2416")
		"tunica":
			m.albedo_texture = _rumore(15, 0.4, Color("c8b48e"), Color("e4d6b6"))
		"giocatore":
			m.albedo_color = Color("2f78a8")
		"sandali":
			m.albedo_color = Color("5a3a22")
		"roccia_massi":
			m.albedo_texture = _rumore(16, 0.12, Color("4a443c"), Color("857a68"))
		"macchia":
			m.albedo_texture = _rumore(17, 0.35, Color("2f4a24"), Color("5f7a3c"))
		"fiore":
			m.albedo_color = Color("e8c94a")
		"blocco":
			m.albedo_texture = _rumore(18, 0.15, Color("b9ab90"), Color("ddd0b6"))
		"acqua_pozzo":
			m.albedo_color = Color("1d4a66")
			m.roughness = 0.2
		"corda":
			m.albedo_color = Color("b89a64")
		"stoffa":
			m.albedo_color = Color("2f78a8")
			m.cull_mode = BaseMaterial3D.CULL_DISABLED
		"persiana":
			m.albedo_color = Color("3f6f96")
		"buio":
			m.albedo_color = Color("1e140d")
	var finale: Material = m if nome in MATERIALI_SEMPLICI else _a_vissuto(m, nome)
	_cache_mat[nome] = finale
	return finale


static func _a_vissuto(m: StandardMaterial3D, nome: String) -> ShaderMaterial:
	var sm := ShaderMaterial.new()
	sm.shader = SHADER_VISSUTO
	var tex: Texture2D = m.albedo_texture
	if tex == null:
		var img := Image.create(4, 4, false, Image.FORMAT_RGBA8)
		img.fill(m.albedo_color)
		tex = ImageTexture.create_from_image(img)
	sm.set_shader_parameter("tex", tex)
	sm.set_shader_parameter("rumore", _rumore_studio())
	sm.set_shader_parameter("scala", m.uv1_scale.x * 1.0)
	sm.set_shader_parameter("ruvidezza", m.roughness)
	var reg: Array = REGOLAZIONI.get(nome, [0.45, 0.35, 1.2])
	sm.set_shader_parameter("sporco", reg[0])
	sm.set_shader_parameter("macchie", reg[1])
	sm.set_shader_parameter("saturazione", reg[2])
	return sm


static func _rumore_studio() -> ImageTexture:
	if _rumore_rgb:
		return _rumore_rgb
	var dim := 128
	var img := Image.create(dim, dim, false, Image.FORMAT_RGBA8)
	var canali := []
	for k in 3:
		var n := FastNoiseLite.new()
		n.seed = 300 + k
		n.frequency = 0.06 + k * 0.05
		n.fractal_octaves = 3
		canali.append(n.get_seamless_image(dim, dim))
	for y in dim:
		for x in dim:
			img.set_pixel(x, y, Color(canali[0].get_pixel(x, y).r, canali[1].get_pixel(x, y).r, canali[2].get_pixel(x, y).r))
	img.generate_mipmaps()
	_rumore_rgb = ImageTexture.create_from_image(img)
	return _rumore_rgb


# ------------------------------------------------------------------ primitive

static func scatola(dim: Vector3, pos: Vector3, mat: String, rot := Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = dim
	mi.mesh = bm
	mi.position = pos
	mi.rotation_degrees = rot
	mi.material_override = materiale(mat)
	return mi


static func cilindro(r_basso: float, r_alto: float, h: float, pos: Vector3, mat: String, rot := Vector3.ZERO, segmenti := 12) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.bottom_radius = r_basso
	cm.top_radius = r_alto
	cm.height = h
	cm.radial_segments = segmenti
	cm.rings = 1
	mi.mesh = cm
	mi.position = pos
	mi.rotation_degrees = rot
	mi.material_override = materiale(mat)
	return mi


static func sfera(r: float, pos: Vector3, mat: String, scala := Vector3.ONE) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = r
	sm.height = r * 2
	sm.radial_segments = 16
	sm.rings = 8
	mi.mesh = sm
	mi.position = pos
	mi.scale = scala
	mi.material_override = materiale(mat)
	return mi


## Tetto a due falde coperto di coppi veri (mezzi cilindri), colmo lungo l'asse X.
static func tetto_coppi(radice: Node3D, larg: float, prof: float, base_y: float, pendenza_gradi: float, mat := "tegola") -> void:
	var meta := prof * 0.5 + 0.06
	var ang := deg_to_rad(pendenza_gradi)
	var lung_falda := meta / cos(ang)
	var alt := meta * tan(ang)
	for lato in [-1, 1]:
		var falda := Node3D.new()
		falda.position = Vector3(0, base_y + alt * 0.5, lato * meta * 0.5)
		falda.rotation.x = lato * ang
		radice.add_child(falda)
		falda.add_child(scatola(Vector3(larg + 0.12, 0.03, lung_falda), Vector3.ZERO, "tegola_scura"))
		var n := int((larg + 0.1) / 0.075)
		for k in n:
			var x := -larg * 0.5 - 0.03 + (k + 0.5) * (larg + 0.06) / n
			var coppo := cilindro(0.032, 0.03, lung_falda, Vector3(x, 0.022, 0), mat, Vector3(90, 0, 0), 8)
			coppo.scale = Vector3(1, 1, 0.55)
			falda.add_child(coppo)
	var colmo := cilindro(0.045, 0.045, larg + 0.16, Vector3(0, base_y + alt + 0.025, 0), mat, Vector3(0, 0, 90), 10)
	radice.add_child(colmo)


# ------------------------------------------------------------------ modelli

static func casa_greca() -> Node3D:
	var r := Node3D.new()
	var lx := 0.62
	var lz := 0.52
	var h := 0.36
	r.add_child(scatola(Vector3(lx + 0.06, 0.06, lz + 0.06), Vector3(0, 0.03, 0), "pietra"))
	r.add_child(scatola(Vector3(lx, h, lz), Vector3(0, h * 0.5 + 0.04, 0), "intonaco"))
	# fascia sporca alla base, come una casa vissuta
	r.add_child(scatola(Vector3(lx + 0.004, 0.07, lz + 0.004), Vector3(0, 0.095, 0), "intonaco_sporco"))
	tetto_coppi(r, lx + 0.04, lz, h + 0.04, 24.0)
	# porta e finestre (faccia +Z visibile)
	r.add_child(scatola(Vector3(0.12, 0.2, 0.02), Vector3(-0.08, 0.14, lz * 0.5 + 0.005), "legno_scuro"))
	r.add_child(scatola(Vector3(0.16, 0.025, 0.05), Vector3(-0.08, 0.255, lz * 0.5 + 0.02), "pietra"))
	for fx in [0.17]:
		r.add_child(scatola(Vector3(0.08, 0.09, 0.02), Vector3(fx, 0.25, lz * 0.5 + 0.005), "buio"))
		r.add_child(scatola(Vector3(0.035, 0.1, 0.015), Vector3(fx - 0.065, 0.25, lz * 0.5 + 0.015), "persiana"))
		r.add_child(scatola(Vector3(0.035, 0.1, 0.015), Vector3(fx + 0.065, 0.25, lz * 0.5 + 0.015), "persiana"))
	# finestra sulla faccia +X
	r.add_child(scatola(Vector3(0.02, 0.09, 0.08), Vector3(lx * 0.5 + 0.005, 0.25, 0.0), "buio"))
	# comignolo
	r.add_child(scatola(Vector3(0.07, 0.16, 0.07), Vector3(-0.18, h + 0.17, -0.1), "intonaco"))
	r.add_child(scatola(Vector3(0.09, 0.025, 0.09), Vector3(-0.18, h + 0.26, -0.1), "tegola_scura"))
	# anfore e panca davanti alla porta
	for i in 2:
		var ax := 0.12 + i * 0.09
		r.add_child(sfera(0.045, Vector3(ax, 0.075, lz * 0.5 + 0.1), "terracotta", Vector3(1, 1.35, 1)))
		r.add_child(cilindro(0.018, 0.022, 0.04, Vector3(ax, 0.145, lz * 0.5 + 0.1), "terracotta", Vector3.ZERO, 8))
	r.add_child(scatola(Vector3(0.22, 0.03, 0.06), Vector3(-0.32, 0.07, lz * 0.5 + 0.09), "legno", Vector3(0, 90, 0)))
	r.add_child(scatola(Vector3(0.03, 0.05, 0.05), Vector3(-0.32, 0.025, lz * 0.5 + 0.0), "legno"))
	r.add_child(scatola(Vector3(0.03, 0.05, 0.05), Vector3(-0.32, 0.025, lz * 0.5 + 0.18), "legno"))
	r.scale = Vector3.ONE * 1.55
	return r


static func pino(seme: int) -> Node3D:
	var rng := RandomNumberGenerator.new()
	rng.seed = seme
	var r := Node3D.new()
	var h := rng.randf_range(1.15, 1.35)
	r.add_child(cilindro(0.05, 0.03, h * 0.55, Vector3(0, h * 0.27, 0), "corteccia", Vector3.ZERO, 8))
	var piani := 5
	for k in piani:
		var t := float(k) / piani
		var raggio := lerpf(0.36, 0.08, t) * rng.randf_range(0.9, 1.1)
		var alt := lerpf(0.42, 0.24, t)
		var y := 0.28 + t * (h - 0.4)
		var cono := cilindro(raggio, 0.0, alt, Vector3(rng.randf_range(-0.02, 0.02), y + alt * 0.5, rng.randf_range(-0.02, 0.02)), "aghi", Vector3(rng.randf_range(-4, 4), rng.randf() * 360, rng.randf_range(-4, 4)), 9)
		r.add_child(cono)
	return r


static func ulivo(seme: int) -> Node3D:
	var rng := RandomNumberGenerator.new()
	rng.seed = seme
	var r := Node3D.new()
	# tronco nodoso: segmenti inclinati
	var base := Vector3.ZERO
	for k in 2:
		var dir := Vector3(rng.randf_range(-0.35, 0.35), 1, rng.randf_range(-0.35, 0.35)).normalized()
		var lung := 0.12
		var seg := cilindro(0.055 - k * 0.01, 0.045 - k * 0.01, lung, base + dir * lung * 0.5, "corteccia", Vector3.ZERO, 7)
		seg.basis = Basis(Quaternion(Vector3.UP, dir))
		seg.position = base + dir * lung * 0.5
		r.add_child(seg)
		base += dir * lung
	# rami
	for k in 3:
		var ang := k * TAU / 3 + rng.randf() * 0.6
		var dir := Vector3(cos(ang) * 0.6, 0.8, sin(ang) * 0.6).normalized()
		var seg := cilindro(0.025, 0.015, 0.2, Vector3.ZERO, "corteccia", Vector3.ZERO, 6)
		seg.basis = Basis(Quaternion(Vector3.UP, dir))
		seg.position = base + dir * 0.1
		r.add_child(seg)
	r.scale = Vector3.ONE * 1.25
	# chioma argentata a ciuffi
	for k in 16:
		var ang := rng.randf() * TAU
		var dist := rng.randf_range(0.04, 0.3)
		var p := base + Vector3(cos(ang) * dist, rng.randf_range(0.02, 0.2) - dist * 0.25, sin(ang) * dist)
		var rr := rng.randf_range(0.09, 0.14)
		r.add_child(sfera(rr, p, "foglie_ulivo", Vector3(1, 0.62, 1)))
	return r


## Riempie il sottotetto (i due timpani triangolari) sotto un tetto a due falde con colmo lungo X.
static func sottotetto(radice: Node3D, lx: float, lz: float, base_y: float, pendenza_gradi: float, mat := "intonaco") -> void:
	var alt := (lz * 0.5) * tan(deg_to_rad(pendenza_gradi))
	var mi := MeshInstance3D.new()
	var pm := PrismMesh.new()
	pm.size = Vector3(lz, alt, lx)
	mi.mesh = pm
	mi.rotation_degrees = Vector3(0, 90, 0)
	mi.position = Vector3(0, base_y + alt * 0.5, 0)
	mi.material_override = materiale(mat)
	radice.add_child(mi)


## Tetto a scandole di legno (file di tavolette sovrapposte).
static func tetto_scandole(radice: Node3D, larg: float, prof: float, base_y: float, pendenza_gradi: float) -> void:
	var meta := prof * 0.5 + 0.06
	var ang := deg_to_rad(pendenza_gradi)
	var lung := meta / cos(ang)
	var alt := meta * tan(ang)
	for lato in [-1, 1]:
		var falda := Node3D.new()
		falda.position = Vector3(0, base_y + alt * 0.5, lato * meta * 0.5)
		falda.rotation.x = lato * ang
		radice.add_child(falda)
		falda.add_child(scatola(Vector3(larg + 0.12, 0.025, lung), Vector3.ZERO, "legno_scuro"))
		var file := int(lung / 0.07)
		for k in file:
			var z := -lung * 0.5 + (k + 0.5) * lung / file
			var fila := scatola(Vector3(larg + 0.12, 0.018, lung / file * 1.3), Vector3(0, 0.02, z * lato * -1.0), "legno" if k % 2 == 0 else "legno_scuro")
			fila.rotation_degrees.x = 6 * lato
			falda.add_child(fila)
	radice.add_child(cilindro(0.035, 0.035, larg + 0.16, Vector3(0, base_y + alt + 0.02, 0), "legno_scuro", Vector3(0, 0, 90), 8))


static func anfora(pos: Vector3, scala := 1.0) -> Node3D:
	var n := Node3D.new()
	n.position = pos
	n.scale = Vector3.ONE * scala
	n.add_child(sfera(0.045, Vector3(0, 0.05, 0), "terracotta", Vector3(1, 1.35, 1)))
	n.add_child(cilindro(0.018, 0.022, 0.04, Vector3(0, 0.12, 0), "terracotta", Vector3.ZERO, 8))
	n.add_child(cilindro(0.026, 0.026, 0.01, Vector3(0, 0.14, 0), "terracotta", Vector3.ZERO, 8))
	return n


static func sacco(pos: Vector3, rot := 0.0) -> MeshInstance3D:
	var s := sfera(0.06, pos + Vector3(0, 0.045, 0), "lino", Vector3(1, 0.8, 0.8))
	s.rotation.y = rot
	return s


static func cassa(pos: Vector3, rot := 0.0, lato := 0.11) -> MeshInstance3D:
	return scatola(Vector3(lato, lato * 0.8, lato), pos + Vector3(0, lato * 0.4, 0), "legno", Vector3(0, rot, 0))


static func catasta_tronchi(radice: Node3D, pos: Vector3, file := 3, lung := 0.36) -> void:
	for f in file:
		for k in file - f:
			var x := (k - (file - f - 1) * 0.5) * 0.075
			radice.add_child(cilindro(0.035, 0.035, lung, pos + Vector3(x, 0.035 + f * 0.062, 0), "corteccia", Vector3(90, 0, 0), 8))
			radice.add_child(cilindro(0.028, 0.028, lung + 0.004, pos + Vector3(x, 0.035 + f * 0.062, 0), "legno_chiaro", Vector3(90, 0, 0), 8))


static func pila_assi(radice: Node3D, pos: Vector3, strati := 5, rot := 0.0) -> void:
	for k in strati:
		var a := scatola(Vector3(0.34, 0.018, 0.14), pos + Vector3(0, 0.012 + k * 0.021, 0), "legno_chiaro", Vector3(0, rot + (k % 2) * 3, 0))
		radice.add_child(a)


# ------------------------------------------------------------------ edifici greci

static func magazzino() -> Node3D:
	var r := Node3D.new()
	var lx := 1.6
	var lz := 1.2
	var h := 0.52
	var portico := 0.28
	# basamento a gradini
	r.add_child(scatola(Vector3(lx + 0.16, 0.05, lz + 0.16), Vector3(0, 0.025, 0), "pietra"))
	r.add_child(scatola(Vector3(lx + 0.08, 0.05, lz + 0.08), Vector3(0, 0.075, 0), "marmo"))
	# cella (muri arretrati dietro il portico)
	var cz := lz - portico
	r.add_child(scatola(Vector3(lx - 0.08, h, cz), Vector3(0, 0.1 + h * 0.5, -portico * 0.5), "intonaco"))
	r.add_child(scatola(Vector3(lx - 0.075, 0.08, cz + 0.005), Vector3(0, 0.14, -portico * 0.5), "intonaco_sporco"))
	# porta grande e due finestrelle
	var fz := -portico * 0.5 + cz * 0.5 + 0.006
	r.add_child(scatola(Vector3(0.24, 0.32, 0.02), Vector3(0.0, 0.26, fz), "legno_scuro"))
	r.add_child(scatola(Vector3(0.012, 0.32, 0.025), Vector3(0.0, 0.26, fz + 0.004), "ferro"))
	for fx in [-0.5, 0.5]:
		r.add_child(scatola(Vector3(0.1, 0.12, 0.02), Vector3(fx, 0.38, fz), "buio"))
	# colonne doriche
	var n := 7
	for k in n:
		var x := -lx * 0.5 + 0.1 + k * (lx - 0.2) / (n - 1)
		var zc := lz * 0.5 - 0.06
		r.add_child(cilindro(0.045, 0.036, h - 0.04, Vector3(x, 0.1 + (h - 0.04) * 0.5, zc), "marmo", Vector3.ZERO, 12))
		r.add_child(scatola(Vector3(0.1, 0.025, 0.1), Vector3(x, 0.1 + h - 0.03, zc), "marmo"))
	# colonne sul lato destro (+X) del portico
	r.add_child(cilindro(0.045, 0.036, h - 0.04, Vector3(lx * 0.5 - 0.1, 0.1 + (h - 0.04) * 0.5, lz * 0.5 - 0.2), "marmo"))
	# trabeazione con fregio
	var ty := 0.1 + h
	r.add_child(scatola(Vector3(lx + 0.02, 0.06, lz + 0.02), Vector3(0, ty + 0.01, 0), "marmo"))
	for k in 16:
		var x := -lx * 0.5 + 0.05 + k * (lx - 0.1) / 15
		r.add_child(scatola(Vector3(0.03, 0.04, 0.012), Vector3(x, ty + 0.012, lz * 0.5 + 0.012), "intonaco_sporco"))
	r.add_child(scatola(Vector3(lx + 0.06, 0.02, lz + 0.06), Vector3(0, ty + 0.05, 0), "marmo"))
	# tetto e frontone
	sottotetto(r, lx + 0.02, lz + 0.02, ty + 0.06, 17.0, "marmo")
	tetto_coppi(r, lx + 0.06, lz + 0.02, ty + 0.06, 17.0)
	# merci davanti
	for i in 3:
		r.add_child(anfora(Vector3(-0.62 + i * 0.09, 0.1, lz * 0.5 + 0.17), 1.1))
	r.add_child(anfora(Vector3(-0.58, 0.1, lz * 0.5 + 0.27), 1.1))
	r.add_child(cassa(Vector3(0.45, 0.0, lz * 0.5 + 0.22), 15))
	r.add_child(cassa(Vector3(0.58, 0.0, lz * 0.5 + 0.2), -10))
	r.add_child(cassa(Vector3(0.5, 0.088, lz * 0.5 + 0.21), 30, 0.09))
	r.add_child(sacco(Vector3(0.7, 0.0, lz * 0.5 + 0.08), 0.3))
	r.add_child(sacco(Vector3(0.72, 0.0, lz * 0.5 - 0.06), -0.4))
	return r


static func boscaiolo() -> Node3D:
	var r := Node3D.new()
	var lx := 0.6
	var lz := 0.5
	var h := 0.3
	r.add_child(scatola(Vector3(lx + 0.05, 0.04, lz + 0.05), Vector3(0, 0.02, 0), "pietra"))
	r.add_child(scatola(Vector3(lx, h, lz), Vector3(0, 0.04 + h * 0.5, 0), "legno"))
	# tronchi orizzontali sulle due facce visibili (capanna di tronchi)
	var file := 6
	for k in file:
		var y := 0.06 + k * (h / file)
		r.add_child(cilindro(0.026, 0.026, lx + 0.08, Vector3(0, y, lz * 0.5), "corteccia", Vector3(0, 0, 90), 7))
		r.add_child(cilindro(0.026, 0.026, lz + 0.08, Vector3(lx * 0.5, y + 0.025, 0), "corteccia", Vector3(90, 0, 0), 7))
	r.add_child(scatola(Vector3(0.12, 0.2, 0.03), Vector3(-0.1, 0.14, lz * 0.5 + 0.02), "legno_scuro"))
	sottotetto(r, lx, lz, 0.04 + h, 32.0, "legno")
	tetto_scandole(r, lx + 0.04, lz, 0.04 + h, 32.0)
	# catasta di tronchi sul lato
	catasta_tronchi(r, Vector3(lx * 0.5 + 0.17, 0, -0.02), 3)
	# ceppo con ascia
	r.add_child(cilindro(0.06, 0.065, 0.08, Vector3(0.12, 0.04, lz * 0.5 + 0.2), "corteccia", Vector3.ZERO, 10))
	r.add_child(cilindro(0.058, 0.058, 0.005, Vector3(0.12, 0.081, lz * 0.5 + 0.2), "legno_chiaro", Vector3.ZERO, 10))
	var manico := cilindro(0.008, 0.008, 0.2, Vector3(0.12, 0.16, lz * 0.5 + 0.2), "legno", Vector3(0, 0, 25), 6)
	r.add_child(manico)
	r.add_child(scatola(Vector3(0.05, 0.035, 0.012), Vector3(0.08, 0.245, lz * 0.5 + 0.2), "ferro", Vector3(0, 0, 25)))
	# trucioli e ciocchi a terra
	for i in 4:
		r.add_child(cilindro(0.022, 0.022, 0.06, Vector3(0.0 + i * 0.05, 0.022, lz * 0.5 + 0.32 - (i % 2) * 0.05), "legno_chiaro", Vector3(0, i * 40, 90), 6))
	r.scale = Vector3.ONE * 1.5
	return r


static func segheria() -> Node3D:
	var r := Node3D.new()
	var lx := 0.7
	var lz := 0.55
	var h := 0.38
	r.position = Vector3(-0.08, 0, -0.08)
	r.add_child(scatola(Vector3(lx + 0.05, 0.05, lz + 0.05), Vector3(0, 0.025, 0), "pietra"))
	r.add_child(scatola(Vector3(lx, h, lz), Vector3(0, 0.05 + h * 0.5, 0), "pietra"))
	r.add_child(scatola(Vector3(lx + 0.005, 0.1, lz + 0.005), Vector3(0, 0.1, 0), "intonaco_sporco"))
	r.add_child(scatola(Vector3(0.16, 0.24, 0.03), Vector3(-0.15, 0.17, lz * 0.5 + 0.01), "legno_scuro"))
	r.add_child(scatola(Vector3(0.02, 0.1, 0.09), Vector3(lx * 0.5 + 0.005, 0.3, 0.05), "buio"))
	sottotetto(r, lx, lz, 0.05 + h, 22.0, "pietra")
	tetto_coppi(r, lx + 0.04, lz, 0.05 + h, 22.0)
	# tettoia aperta sul davanti, su pali
	var tz := lz * 0.5 + 0.22
	for px in [-0.3, 0.3]:
		r.add_child(cilindro(0.02, 0.02, 0.32, Vector3(px, 0.16, tz + 0.1), "legno", Vector3.ZERO, 6))
	var tettoia := scatola(Vector3(0.72, 0.025, 0.36), Vector3(0, 0.34, tz - 0.02), "legno_scuro", Vector3(-14, 0, 0))
	r.add_child(tettoia)
	# cavalletti con tronco e sega a telaio
	for px in [-0.18, 0.18]:
		r.add_child(scatola(Vector3(0.025, 0.12, 0.1), Vector3(px, 0.06, tz), "legno"))
	r.add_child(cilindro(0.045, 0.045, 0.56, Vector3(0, 0.15, tz), "corteccia", Vector3(0, 0, 90), 8))
	r.add_child(scatola(Vector3(0.012, 0.22, 0.012), Vector3(0.05, 0.2, tz), "legno"))
	r.add_child(scatola(Vector3(0.012, 0.22, 0.012), Vector3(0.05, 0.2, tz + 0.12), "legno"))
	r.add_child(scatola(Vector3(0.006, 0.006, 0.12), Vector3(0.05, 0.13, tz + 0.06), "ferro"))
	r.add_child(scatola(Vector3(0.01, 0.01, 0.13), Vector3(0.05, 0.3, tz + 0.06), "legno"))
	# pile di assi
	pila_assi(r, Vector3(lx * 0.5 + 0.2, 0, 0.15), 6, 90)
	pila_assi(r, Vector3(lx * 0.5 + 0.2, 0, -0.2), 3, 90)
	catasta_tronchi(r, Vector3(-lx * 0.5 - 0.02, 0, lz * 0.5 + 0.35), 2, 0.3)
	r.scale = Vector3.ONE * 1.45
	return r


static func frantoio() -> Node3D:
	var r := Node3D.new()
	var lx := 0.66
	var lz := 0.5
	var h := 0.36
	r.position = Vector3(-0.08, 0, -0.1)
	r.add_child(scatola(Vector3(lx + 0.05, 0.05, lz + 0.05), Vector3(0, 0.025, 0), "pietra"))
	r.add_child(scatola(Vector3(lx, h, lz), Vector3(0, 0.05 + h * 0.5, 0), "intonaco"))
	r.add_child(scatola(Vector3(lx + 0.005, 0.08, lz + 0.005), Vector3(0, 0.09, 0), "intonaco_sporco"))
	r.add_child(scatola(Vector3(0.14, 0.22, 0.02), Vector3(0.12, 0.16, lz * 0.5 + 0.005), "legno_scuro"))
	r.add_child(scatola(Vector3(0.08, 0.08, 0.02), Vector3(-0.15, 0.28, lz * 0.5 + 0.005), "buio"))
	sottotetto(r, lx, lz, 0.05 + h, 20.0, "intonaco")
	tetto_coppi(r, lx + 0.04, lz, 0.05 + h, 20.0)
	# macina: vasca di pietra con ruota verticale e palo
	var mz := lz * 0.5 + 0.3
	var mx := -0.18
	r.add_child(cilindro(0.2, 0.21, 0.08, Vector3(mx, 0.04, mz), "pietra", Vector3.ZERO, 20))
	r.add_child(cilindro(0.16, 0.16, 0.01, Vector3(mx, 0.081, mz), "intonaco_sporco", Vector3.ZERO, 20))
	r.add_child(cilindro(0.025, 0.025, 0.16, Vector3(mx, 0.14, mz), "legno", Vector3.ZERO, 6))
	r.add_child(cilindro(0.1, 0.1, 0.06, Vector3(mx + 0.08, 0.18, mz), "pietra", Vector3(0, 0, 90), 16))
	r.add_child(scatola(Vector3(0.42, 0.025, 0.025), Vector3(mx + 0.12, 0.2, mz), "legno"))
	# anfore d'olio e ceste di olive
	for i in 4:
		r.add_child(anfora(Vector3(0.22 + (i % 2) * 0.09, 0.0, mz - 0.05 + (i / 2) * 0.1), 1.0))
	for i in 2:
		r.add_child(cilindro(0.05, 0.04, 0.05, Vector3(lx * 0.5 + 0.12, 0.025, 0.1 - i * 0.14), "legno_chiaro", Vector3.ZERO, 10))
		r.add_child(sfera(0.042, Vector3(lx * 0.5 + 0.12, 0.05, 0.1 - i * 0.14), "foglie_ulivo", Vector3(1, 0.4, 1)))
	r.scale = Vector3.ONE * 1.45
	return r


# ------------------------------------------------------------------ persone

## Portatore: proporzioni esagerate (testa grande, carico ben visibile) per restare leggibile a 45 pixel.
static func portatore(carico: String) -> Node3D:
	var r := Node3D.new()
	var corpo := Node3D.new()
	corpo.name = "corpo"
	r.add_child(corpo)
	var anca := 0.2
	for lato in [-1, 1]:
		var gamba := Node3D.new()
		gamba.name = "gamba_s" if lato < 0 else "gamba_d"
		gamba.position = Vector3(lato * 0.035, anca, 0)
		corpo.add_child(gamba)
		gamba.add_child(cilindro(0.022, 0.018, 0.18, Vector3(0, -0.09, 0), "pelle", Vector3.ZERO, 6))
		gamba.add_child(scatola(Vector3(0.04, 0.02, 0.07), Vector3(0, -0.185, 0.015), "sandali"))
	corpo.add_child(cilindro(0.085, 0.06, 0.2, Vector3(0, anca + 0.07, 0), "tunica", Vector3.ZERO, 10))
	corpo.add_child(cilindro(0.075, 0.075, 0.022, Vector3(0, anca + 0.1, 0), "giocatore", Vector3.ZERO, 10))
	corpo.add_child(cilindro(0.087, 0.087, 0.018, Vector3(0, anca - 0.022, 0), "giocatore", Vector3.ZERO, 10))
	corpo.add_child(sfera(0.075, Vector3(0, anca + 0.25, 0), "pelle"))
	var capelli := sfera(0.078, Vector3(0, anca + 0.27, -0.01), "capelli", Vector3(1, 0.85, 1))
	corpo.add_child(capelli)
	corpo.add_child(sfera(0.012, Vector3(0, anca + 0.24, 0.075), "pelle"))  # naso
	for lato in [-1, 1]:
		var braccio := Node3D.new()
		braccio.name = "braccio_s" if lato < 0 else "braccio_d"
		braccio.position = Vector3(lato * 0.07, anca + 0.155, 0)
		corpo.add_child(braccio)
		braccio.add_child(cilindro(0.017, 0.015, 0.14, Vector3(0, -0.07, 0), "pelle", Vector3.ZERO, 6))
	var spalla := Vector3(0, anca + 0.2, 0)
	match carico:
		"tronco":
			corpo.add_child(cilindro(0.038, 0.038, 0.3, spalla + Vector3(0.085, 0.01, 0), "corteccia", Vector3(90, 0, 0), 8))
			corpo.add_child(cilindro(0.03, 0.03, 0.302, spalla + Vector3(0.085, 0.01, 0), "legno_chiaro", Vector3(90, 0, 0), 8))
		"asse":
			corpo.add_child(scatola(Vector3(0.05, 0.016, 0.36), spalla + Vector3(0.08, 0.02, 0), "legno_chiaro"))
			corpo.add_child(scatola(Vector3(0.05, 0.016, 0.34), spalla + Vector3(0.08, 0.038, 0.01), "legno_chiaro"))
		"anfora":
			corpo.add_child(anfora(Vector3(0, anca + 0.31, 0), 1.25))
		"pietra":
			corpo.add_child(scatola(Vector3(0.1, 0.075, 0.09), Vector3(0, anca + 0.36, 0), "blocco", Vector3(0, 15, 0)))
	r.set_meta("carico", carico)
	return r


static func posa_cammino(modello: Node3D, fotogramma: int, totale: int) -> void:
	var t := float(fotogramma) / totale * TAU
	var oscill := sin(t)
	var corpo: Node3D = modello.get_node("corpo")
	corpo.position.y = absf(cos(t)) * 0.012
	(corpo.get_node("gamba_s") as Node3D).rotation.x = oscill * 0.5
	(corpo.get_node("gamba_d") as Node3D).rotation.x = -oscill * 0.5
	var carico: String = modello.get_meta("carico", "")
	var bs: Node3D = corpo.get_node("braccio_s")
	var bd: Node3D = corpo.get_node("braccio_d")
	if carico == "":
		bs.rotation.x = -oscill * 0.45
		bd.rotation.x = oscill * 0.45
	elif carico == "anfora" or carico == "pietra":
		bs.rotation = Vector3(0, 0, -2.6)
		bd.rotation = Vector3(0, 0, 2.6)
	else:
		bs.rotation = Vector3(-0.3 - oscill * 0.2, 0, 0)
		bd.rotation = Vector3(-0.4, 0, 2.2)


static func rocce(seme: int) -> Node3D:
	var rng := RandomNumberGenerator.new()
	rng.seed = seme * 31
	var r := Node3D.new()
	for k in 3 + seme % 2:
		var mi := MeshInstance3D.new()
		var sm := SphereMesh.new()
		sm.radius = 0.5
		sm.height = 1.0
		sm.radial_segments = 7
		sm.rings = 4
		mi.mesh = sm
		var dim := rng.randf_range(0.12, 0.26)
		mi.scale = Vector3(dim * rng.randf_range(1.0, 1.6), dim * rng.randf_range(0.6, 1.0), dim * rng.randf_range(0.9, 1.4))
		mi.position = Vector3(rng.randf_range(-0.18, 0.18), dim * 0.3, rng.randf_range(-0.15, 0.15))
		mi.rotation = Vector3(rng.randf_range(-0.3, 0.3), rng.randf() * TAU, rng.randf_range(-0.3, 0.3))
		mi.material_override = materiale("roccia_massi")
		r.add_child(mi)
	r.add_child(sfera(0.05, Vector3(0.2, 0.02, 0.18), "aghi", Vector3(1.4, 0.5, 1.0)))
	return r


static func cespuglio(seme: int) -> Node3D:
	var rng := RandomNumberGenerator.new()
	rng.seed = seme * 17
	var r := Node3D.new()
	for k in 7:
		var p := Vector3(rng.randf_range(-0.12, 0.12), rng.randf_range(0.05, 0.14), rng.randf_range(-0.12, 0.12))
		r.add_child(sfera(rng.randf_range(0.06, 0.1), p, "macchia", Vector3(1, 0.8, 1)))
	if seme % 2 == 0:
		for k in 5:
			r.add_child(sfera(0.012, Vector3(rng.randf_range(-0.12, 0.12), rng.randf_range(0.12, 0.2), rng.randf_range(-0.05, 0.14)), "fiore"))
	return r



# ------------------------------------------------------------------ altri edifici greci (step 02)

static func cava() -> Node3D:
	var r := Node3D.new()
	r.position = Vector3(-0.1, 0, -0.1)
	# capanno di pietra a secco
	r.add_child(scatola(Vector3(0.5, 0.26, 0.42), Vector3(-0.12, 0.13, -0.08), "pietra"))
	sottotetto(r, 0.5, 0.42, 0.26, 24.0, "pietra")
	var t := Node3D.new()
	t.position = Vector3(-0.12, 0, -0.08)
	r.add_child(t)
	tetto_coppi(t, 0.54, 0.42, 0.26, 24.0)
	r.add_child(scatola(Vector3(0.1, 0.17, 0.02), Vector3(-0.2, 0.09, 0.14), "legno_scuro"))
	# parete di roccia tagliata e blocchi squadrati
	for k in 4:
		r.add_child(scatola(Vector3(0.18, 0.12, 0.14), Vector3(0.28 + (k % 2) * 0.06, 0.06 + (k / 2) * 0.12, -0.25 + k * 0.03), "roccia_massi", Vector3(0, k * 9, 0)))
	for i in 3:
		for j in 2 - (i / 2):
			r.add_child(scatola(Vector3(0.11, 0.08, 0.08), Vector3(0.14 + i * 0.12, 0.04 + j * 0.08, 0.26), "blocco", Vector3(0, i * 4 - 4, 0)))
	# piccone appoggiato e carriola
	r.add_child(cilindro(0.008, 0.008, 0.2, Vector3(0.36, 0.1, 0.1), "legno", Vector3(0, 0, -20), 6))
	r.add_child(scatola(Vector3(0.1, 0.012, 0.012), Vector3(0.39, 0.19, 0.1), "ferro", Vector3(0, 0, -20)))
	r.add_child(scatola(Vector3(0.16, 0.05, 0.1), Vector3(-0.32, 0.07, 0.3), "legno"))
	r.add_child(cilindro(0.035, 0.035, 0.015, Vector3(-0.24, 0.035, 0.3), "legno_scuro", Vector3(90, 0, 0), 10))
	r.scale = Vector3.ONE * 1.4
	return r


static func guardaboschi() -> Node3D:
	var r := Node3D.new()
	r.position = Vector3(-0.08, 0, -0.08)
	r.add_child(scatola(Vector3(0.44, 0.26, 0.38), Vector3(0, 0.13, 0), "legno"))
	for k in 5:
		r.add_child(cilindro(0.022, 0.022, 0.5, Vector3(0, 0.03 + k * 0.05, 0.19), "corteccia", Vector3(0, 0, 90), 7))
	sottotetto(r, 0.44, 0.38, 0.26, 34.0, "legno")
	tetto_scandole(r, 0.48, 0.38, 0.26, 34.0)
	r.add_child(scatola(Vector3(0.1, 0.17, 0.02), Vector3(0.1, 0.09, 0.2), "legno_scuro"))
	# vivaio di alberelli con recinto
	for i in 3:
		for j in 2:
			var p := Vector3(-0.16 + i * 0.13, 0, 0.36 + j * 0.12)
			r.add_child(cilindro(0.008, 0.008, 0.06, p + Vector3(0, 0.03, 0), "corteccia", Vector3.ZERO, 5))
			r.add_child(cilindro(0.04, 0.0, 0.09, p + Vector3(0, 0.1, 0), "aghi", Vector3.ZERO, 7))
	for k in 5:
		r.add_child(cilindro(0.01, 0.01, 0.08, Vector3(-0.24 + k * 0.12, 0.04, 0.52), "legno", Vector3.ZERO, 5))
	r.add_child(scatola(Vector3(0.5, 0.012, 0.012), Vector3(0.0, 0.06, 0.52), "legno"))
	# annaffiatoio e pala
	r.add_child(cilindro(0.03, 0.03, 0.05, Vector3(0.28, 0.025, 0.12), "ferro", Vector3.ZERO, 8))
	r.add_child(cilindro(0.007, 0.007, 0.2, Vector3(0.26, 0.11, -0.05), "legno", Vector3(10, 0, -15), 5))
	r.scale = Vector3.ONE * 1.45
	return r


static func torre() -> Node3D:
	var r := Node3D.new()
	var lato := 0.42
	var h := 0.95
	r.add_child(scatola(Vector3(lato + 0.1, 0.06, lato + 0.1), Vector3(0, 0.03, 0), "pietra"))
	r.add_child(scatola(Vector3(lato, h, lato), Vector3(0, 0.06 + h * 0.5, 0), "pietra"))
	r.add_child(scatola(Vector3(lato + 0.005, 0.1, lato + 0.005), Vector3(0, 0.11, 0), "intonaco_sporco"))
	# fasce, feritoie e porta
	for y in [0.4, 0.75]:
		r.add_child(scatola(Vector3(lato + 0.02, 0.025, lato + 0.02), Vector3(0, y, 0), "blocco"))
	for y in [0.55, 0.88]:
		r.add_child(scatola(Vector3(0.03, 0.09, 0.02), Vector3(0, y, lato * 0.5 + 0.005), "buio"))
		r.add_child(scatola(Vector3(0.02, 0.09, 0.03), Vector3(lato * 0.5 + 0.005, y, 0), "buio"))
	r.add_child(scatola(Vector3(0.13, 0.22, 0.02), Vector3(-0.06, 0.17, lato * 0.5 + 0.005), "legno_scuro"))
	# ballatoio e merli
	var top := 0.06 + h
	r.add_child(scatola(Vector3(lato + 0.1, 0.04, lato + 0.1), Vector3(0, top + 0.02, 0), "blocco"))
	for k in 4:
		for lato_m in [-1, 1]:
			var off := -lato * 0.5 + 0.03 + k * (lato - 0.06) / 3
			r.add_child(scatola(Vector3(0.06, 0.07, 0.04), Vector3(off, top + 0.075, lato_m * (lato * 0.5 + 0.03)), "pietra"))
			r.add_child(scatola(Vector3(0.04, 0.07, 0.06), Vector3(lato_m * (lato * 0.5 + 0.03), top + 0.075, off), "pietra"))
	# asta con stendardo del giocatore
	r.add_child(cilindro(0.01, 0.01, 0.42, Vector3(0, top + 0.25, 0), "legno", Vector3.ZERO, 6))
	var s := scatola(Vector3(0.2, 0.12, 0.006), Vector3(0.1, top + 0.38, 0), "stoffa", Vector3(0, -30, 0))
	r.add_child(s)
	r.scale = Vector3.ONE * 1.35
	return r


static func pozzo() -> Node3D:
	var r := Node3D.new()
	r.add_child(cilindro(0.17, 0.18, 0.16, Vector3(0, 0.08, 0), "pietra", Vector3.ZERO, 16))
	r.add_child(cilindro(0.13, 0.13, 0.005, Vector3(0, 0.15, 0), "acqua_pozzo", Vector3.ZERO, 16))
	r.add_child(cilindro(0.185, 0.185, 0.025, Vector3(0, 0.17, 0), "blocco", Vector3.ZERO, 16))
	for lato in [-1, 1]:
		r.add_child(scatola(Vector3(0.03, 0.3, 0.03), Vector3(lato * 0.16, 0.3, 0), "legno"))
	r.add_child(cilindro(0.022, 0.022, 0.36, Vector3(0, 0.38, 0), "legno", Vector3(0, 0, 90), 8))
	r.add_child(cilindro(0.004, 0.004, 0.16, Vector3(0.02, 0.3, 0), "corda", Vector3.ZERO, 4))
	r.add_child(cilindro(0.035, 0.03, 0.05, Vector3(0.02, 0.2, 0), "legno_scuro", Vector3.ZERO, 8))
	# tettuccio
	var t := Node3D.new()
	r.add_child(t)
	tetto_coppi(t, 0.4, 0.22, 0.45, 30.0)
	r.add_child(anfora(Vector3(0.22, 0.0, 0.16), 1.0))
	r.scale = Vector3.ONE * 1.4
	return r


static func cantiere(fase: int) -> Node3D:
	var r := Node3D.new()
	var l := 0.62
	# picchetti e corda che segnano l'area
	for p in [Vector3(-l, 0, -l), Vector3(l, 0, -l), Vector3(l, 0, l), Vector3(-l, 0, l)]:
		r.add_child(cilindro(0.01, 0.006, 0.09, p * 0.5 + Vector3(0, 0.045, 0), "legno", Vector3.ZERO, 5))
	for k in 4:
		var a := k * PI / 2
		var lungo := scatola(Vector3(l, 0.004, 0.004), Vector3(cos(a) * l * 0.5, 0.07, sin(a) * l * 0.5), "corda", Vector3(0, rad_to_deg(a) + 90, 0))
		r.add_child(lungo)
	if fase >= 1:
		r.add_child(scatola(Vector3(l * 0.86, 0.05, l * 0.86), Vector3(0, 0.025, 0), "pietra"))
		for i in 3:
			r.add_child(scatola(Vector3(0.1, 0.07, 0.07), Vector3(-0.38 + i * 0.11, 0.035, 0.42), "blocco", Vector3(0, i * 7, 0)))
		pila_assi(r, Vector3(0.42, 0, 0.1), 4, 90)
	if fase >= 2:
		var h := 0.18
		r.add_child(scatola(Vector3(l * 0.8, h, 0.04), Vector3(0, 0.05 + h * 0.5, l * 0.4 - 0.02), "intonaco"))
		r.add_child(scatola(Vector3(0.04, h * 0.7, l * 0.5), Vector3(l * 0.4 - 0.02, 0.05 + h * 0.35, 0.1), "intonaco"))
		for p in [Vector3(-l * 0.45, 0, l * 0.45), Vector3(l * 0.45, 0, l * 0.45), Vector3(l * 0.45, 0, -l * 0.45), Vector3(-l * 0.45, 0, -l * 0.45)]:
			r.add_child(cilindro(0.012, 0.012, 0.36, p + Vector3(0, 0.18, 0), "legno", Vector3.ZERO, 5))
		for y in [0.17, 0.31]:
			r.add_child(scatola(Vector3(l * 0.92, 0.012, 0.012), Vector3(0, y, l * 0.45), "legno"))
			r.add_child(scatola(Vector3(0.012, 0.012, l * 0.92), Vector3(l * 0.45, y, 0), "legno"))
		r.add_child(scatola(Vector3(l * 0.9, 0.015, 0.08), Vector3(0, 0.17, l * 0.5), "legno_chiaro"))
	r.scale = Vector3.ONE * 1.3
	return r


static func bandierina() -> Node3D:
	var r := Node3D.new()
	r.add_child(cilindro(0.04, 0.05, 0.03, Vector3(0, 0.015, 0), "pietra", Vector3.ZERO, 8))
	r.add_child(cilindro(0.008, 0.008, 0.4, Vector3(0, 0.2, 0), "legno", Vector3.ZERO, 6))
	r.add_child(scatola(Vector3(0.16, 0.1, 0.006), Vector3(0.08, 0.34, 0), "stoffa", Vector3(0, -40, 0)))
	r.scale = Vector3.ONE * 1.3
	return r



# ------------------------------------------------------------------ merci (posate a terra vicino alle bandierine)

static func merce(tipo: String) -> Node3D:
	var r := Node3D.new()
	match tipo:
		"assi":
			for k in 3:
				r.add_child(scatola(Vector3(0.26, 0.022, 0.07), Vector3(0, 0.012 + k * 0.024, (k % 2) * 0.01), "legno_chiaro", Vector3(0, 30 + k * 4, 0)))
		"tronchi":
			r.add_child(cilindro(0.04, 0.04, 0.24, Vector3(0, 0.04, 0), "corteccia", Vector3(90, 30, 0), 8))
			r.add_child(cilindro(0.033, 0.033, 0.242, Vector3(0, 0.04, 0), "legno_chiaro", Vector3(90, 30, 0), 8))
		"pietra":
			r.add_child(scatola(Vector3(0.12, 0.08, 0.1), Vector3(0, 0.04, 0), "blocco", Vector3(0, 20, 0)))
			r.add_child(scatola(Vector3(0.07, 0.05, 0.06), Vector3(0.07, 0.025, 0.05), "blocco", Vector3(0, -10, 0)))
	r.scale = Vector3.ONE * 1.25
	return r
