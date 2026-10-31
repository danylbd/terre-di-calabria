class_name Terreno
extends MeshInstance2D
## Costruisce la superficie della mappa: una griglia isometrica con i rilievi,
## ombreggiata dal sole e dipinta dallo shader con le texture del terreno.

const SHADER := preload("res://src/mappa/terreno.gdshader")
const LUCE := Vector3(-0.62, 0.28, 0.73)   # da sinistra-alto, come negli sprite

var dati: DatiMappa


func costruisci(d: DatiMappa) -> void:
	dati = d
	mesh = _crea_mesh()
	var mat := ShaderMaterial.new()
	mat.shader = SHADER
	var pesi := _crea_pesi()
	mat.set_shader_parameter("pesi_a", pesi[0])
	mat.set_shader_parameter("pesi_b", pesi[1])
	mat.set_shader_parameter("dim_pesi", Vector2(d.larghezza + 1, d.altezza + 1))
	for nome in ["prato", "bosco", "sabbia", "roccia", "neve", "acqua", "terra", "secco"]:
		var file: String = "prato_secco" if nome == "secco" else nome
		mat.set_shader_parameter("t_" + nome, load("res://assets/terreno/%s.png" % file))
	mat.set_shader_parameter("rumore", load("res://assets/terreno/rumore_bordi.png"))
	material = mat
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS


func _crea_mesh() -> ArrayMesh:
	var w := dati.larghezza
	var h := dati.altezza
	var vertici := PackedVector2Array()
	var uv := PackedVector2Array()
	var colori := PackedColorArray()
	var indici := PackedInt32Array()
	var scala_orizzontale := Iso.TW * 0.7071   # distanza "reale" tra due vertici vicini
	for j in h + 1:
		for i in w + 1:
			var q := dati.quota_vertice(i, j)
			vertici.append(Iso.a_schermo(i, j, q))
			uv.append(Vector2(i, j))
			var dqx := (dati.quota_vertice(i + 1, j) - dati.quota_vertice(i - 1, j)) * 0.5
			var dqy := (dati.quota_vertice(i, j + 1) - dati.quota_vertice(i, j - 1)) * 0.5
			var n := Vector3(-dqx / scala_orizzontale * 3.2, -dqy / scala_orizzontale * 3.2, 1.0).normalized()
			var l := clampf(0.3 + 0.78 * n.dot(LUCE.normalized()), 0.3, 1.2)
			colori.append(Color(l * 0.8, l * 0.8, l * 0.8, 1.0))
	for j in h:
		for i in w:
			var a := j * (w + 1) + i
			var b := a + 1
			var c := a + (w + 1)
			var e := c + 1
			indici.append_array([a, b, e, a, e, c])
	var arr := []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = vertici
	arr[Mesh.ARRAY_TEX_UV] = uv
	arr[Mesh.ARRAY_COLOR] = colori
	arr[Mesh.ARRAY_INDEX] = indici
	var m := ArrayMesh.new()
	m.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	return m


## Due immagini (8 canali) con il peso di ogni terreno su ogni vertice:
## la media delle quattro caselle che toccano il vertice.
func _crea_pesi() -> Array[ImageTexture]:
	var w := dati.larghezza
	var h := dati.altezza
	var img_a := Image.create(w + 1, h + 1, false, Image.FORMAT_RGBA8)
	var img_b := Image.create(w + 1, h + 1, false, Image.FORMAT_RGBA8)
	for j in h + 1:
		for i in w + 1:
			var p := PackedFloat32Array([0, 0, 0, 0, 0, 0, 0, 0])
			for v in [Vector2i(i - 1, j - 1), Vector2i(i, j - 1), Vector2i(i - 1, j), Vector2i(i, j)]:
				p[dati.tipo(v.x, v.y)] += 0.25
			img_a.set_pixel(i, j, Color(p[0], p[1], p[2], p[3]))
			img_b.set_pixel(i, j, Color(p[4], p[5], p[6], p[7]))
	return [ImageTexture.create_from_image(img_a), ImageTexture.create_from_image(img_b)]


## Rettangolo che contiene tutta la mappa sullo schermo.
func limiti() -> Rect2:
	var w := dati.larghezza
	var h := dati.altezza
	var r := Rect2(Iso.a_schermo(0, 0), Vector2.ZERO)
	for p in [Iso.a_schermo(w, 0), Iso.a_schermo(0, h), Iso.a_schermo(w, h)]:
		r = r.expand(p)
	return r.grow_individual(0, 220, 0, 0)
