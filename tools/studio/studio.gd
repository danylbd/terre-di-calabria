extends SceneTree
## Studio di rendering: costruisce modelli 3D in codice, li illumina e li fotografa
## dall'alto in isometria (come facevano i giochi di strategia di fine anni '90),
## producendo sprite PNG con ombra e sfondo trasparente.
##
## Uso:  godot --path . --rendering-driver opengl3 --script tools/studio/studio.gd -- <cartella_uscita> [nome_modello...]

const Modelli := preload("res://tools/studio/modelli.gd")

const PIXEL_PER_UNITA := 79.2      # casella 1x1 = 112 px di larghezza
const ELEVAZIONE := 30.0           # gradi: rapporto 2:1
const AZIMUT := 45.0
const SUPERCAMPIONE := 2       # si disegna al doppio e si riduce: bordi più puliti

var _uscita := "res://assets/grafica"
var _richiesti: PackedStringArray = []


func _initialize() -> void:
	var argomenti := OS.get_cmdline_user_args()
	if argomenti.size() > 0:
		_uscita = argomenti[0]
		_richiesti = argomenti.slice(1)
	_esegui.call_deferred()


func _esegui() -> void:
	DirAccess.make_dir_recursive_absolute(_uscita)
	var catalogo: Dictionary = Modelli.catalogo()
	var nomi: Array = _richiesti if _richiesti.size() > 0 else catalogo.keys()
	for nome in nomi:
		if not catalogo.has(nome):
			push_error("Modello sconosciuto: %s" % nome)
			continue
		var voce: Dictionary = catalogo[nome]
		await _fotografa(nome, voce)
	quit()


func _fotografa(nome: String, voce: Dictionary) -> void:
	var dim: Vector2i = voce.get("dimensione", Vector2i(256, 256))
	var ancora: Vector2 = voce.get("ancora", Vector2(dim.x * 0.5, dim.y - 48))

	var vp := SubViewport.new()
	vp.size = dim * SUPERCAMPIONE
	vp.transparent_bg = true
	vp.msaa_3d = Viewport.MSAA_4X
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	vp.own_world_3d = true
	root.add_child(vp)

	var mondo := Node3D.new()
	vp.add_child(mondo)
	_luci(mondo)
	var camera := _camera(dim * SUPERCAMPIONE, ancora * SUPERCAMPIONE)
	mondo.add_child(camera)

	var modello: Node3D = voce["crea"].call()
	mondo.add_child(modello)

	# Passo 1: solo l'oggetto (sfondo trasparente)
	var oggetto := await _scatta(vp)

	# Passo 2: solo l'ombra, su un piano chiaro, con l'oggetto invisibile ma che proietta ombra
	_imposta_solo_ombra(modello, true)
	var piano := _piano_ombra()
	mondo.add_child(piano)
	var con_ombra := await _scatta(vp)
	piano.queue_free()
	_imposta_solo_ombra(modello, false)
	await process_frame
	var senza_ombra := await _scatta_piano_libero(vp, mondo, modello)

	var finale := _componi(oggetto, con_ombra, senza_ombra)
	finale.resize(dim.x, dim.y, Image.INTERPOLATE_LANCZOS)
	finale.save_png(_uscita.path_join(nome + ".png"))
	print("  ✓ %s (%dx%d)" % [nome, dim.x, dim.y])
	vp.queue_free()
	await process_frame


func _scatta(vp: SubViewport) -> Image:
	for i in 4:
		await process_frame
	return vp.get_texture().get_image()


func _scatta_piano_libero(vp: SubViewport, mondo: Node3D, modello: Node3D) -> Image:
	# Piano illuminato senza ombre: serve da riferimento per misurare quanto è scura l'ombra.
	modello.visible = false
	var piano := _piano_ombra()
	mondo.add_child(piano)
	var img := await _scatta(vp)
	piano.queue_free()
	modello.visible = true
	return img


func _componi(oggetto: Image, con_ombra: Image, senza_ombra: Image) -> Image:
	var w := oggetto.get_width()
	var h := oggetto.get_height()
	var finale := Image.create(w, h, false, Image.FORMAT_RGBA8)
	for y in h:
		for x in w:
			var luce := senza_ombra.get_pixel(x, y).get_luminance()
			var ombra := con_ombra.get_pixel(x, y).get_luminance()
			var a_ombra := 0.0
			if luce > 0.01:
				a_ombra = clampf((luce - ombra) / luce, 0.0, 1.0) * 0.55
			var sotto := Color(0.08, 0.05, 0.02, a_ombra)
			var sopra := oggetto.get_pixel(x, y)
			# "sopra" su "sotto"
			var a := sopra.a + sotto.a * (1.0 - sopra.a)
			var c := Color(0, 0, 0, 0)
			if a > 0.0:
				c = Color(
					(sopra.r * sopra.a + sotto.r * sotto.a * (1.0 - sopra.a)) / a,
					(sopra.g * sopra.a + sotto.g * sotto.a * (1.0 - sopra.a)) / a,
					(sopra.b * sopra.a + sotto.b * sotto.a * (1.0 - sopra.a)) / a, a)
			finale.set_pixel(x, y, c)
	return finale


func _imposta_solo_ombra(nodo: Node, attivo: bool) -> void:
	if nodo is GeometryInstance3D:
		(nodo as GeometryInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY if attivo else GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	for figlio in nodo.get_children():
		_imposta_solo_ombra(figlio, attivo)


func _piano_ombra() -> MeshInstance3D:
	var m := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(12, 12)
	m.mesh = pm
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.85, 0.85, 0.85)
	mat.roughness = 1.0
	m.material_override = mat
	m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return m


func _luci(mondo: Node3D) -> void:
	var sole := DirectionalLight3D.new()
	sole.light_color = Color(1.0, 0.94, 0.82)
	sole.light_energy = 1.0
	sole.shadow_enabled = true
	sole.shadow_blur = 1.5
	sole.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
	sole.directional_shadow_max_distance = 30.0
	sole.rotation_degrees = Vector3(-48, -20, 0)
	mondo.add_child(sole)

	var riempimento := DirectionalLight3D.new()
	riempimento.light_color = Color(0.75, 0.82, 1.0)
	riempimento.light_energy = 0.25
	riempimento.rotation_degrees = Vector3(-25, 150, 0)
	mondo.add_child(riempimento)

	var amb := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_CLEAR_COLOR
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.62, 0.62, 0.68)
	env.ambient_light_energy = 0.5
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.tonemap_exposure = 0.95
	amb.environment = env
	mondo.add_child(amb)


func _camera(dim: Vector2i, ancora: Vector2) -> Camera3D:
	var cam := Camera3D.new()
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.size = dim.y / (PIXEL_PER_UNITA * SUPERCAMPIONE)
	cam.keep_aspect = Camera3D.KEEP_HEIGHT
	cam.rotation_degrees = Vector3(-ELEVAZIONE, AZIMUT, 0)
	cam.position = cam.basis.z * 40.0
	cam.near = 1.0
	cam.far = 100.0
	# sposta l'inquadratura in modo che l'origine (centro della casella) cada sul punto di ancoraggio
	cam.h_offset = (dim.x * 0.5 - ancora.x) / (PIXEL_PER_UNITA * SUPERCAMPIONE)
	cam.v_offset = (ancora.y - dim.y * 0.5) / (PIXEL_PER_UNITA * SUPERCAMPIONE)
	return cam
