extends RefCounted
## Modelli 3D costruiti in codice per lo studio di rendering.
## Unità: 1 = una casella. Asse Y verso l'alto. La camera guarda dal lato +X/+Z,
## quindi le facce "in vista" sono +Z (sinistra, illuminata) e +X (destra, in ombra).

static var _cache_mat := {}


static func catalogo() -> Dictionary:
	return {
		"casa_greca": {"crea": casa_greca, "dimensione": Vector2i(256, 256), "ancora": Vector2(128, 196)},
		"pino": {"crea": pino.bind(1), "dimensione": Vector2i(160, 240), "ancora": Vector2(80, 214)},
		"ulivo": {"crea": ulivo.bind(3), "dimensione": Vector2i(176, 176), "ancora": Vector2(88, 150)},
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


static func materiale(nome: String) -> StandardMaterial3D:
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
			m.albedo_texture = _rumore(4, 0.08, Color("8a3a22"), Color("b85a36"))
			m.uv1_scale = Vector3(4, 4, 4)
		"tegola_scura":
			m.albedo_texture = _rumore(5, 0.08, Color("7a3019"), Color("a24a2a"))
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
		"persiana":
			m.albedo_color = Color("3f6f96")
		"buio":
			m.albedo_color = Color("1e140d")
	_cache_mat[nome] = m
	return m


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
