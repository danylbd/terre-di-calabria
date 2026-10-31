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
	"aghi": [0.0, 0.0, 1.3], "foglie_ulivo": [0.0, 0.0, 1.2], "foglie": [0.0, 0.0, 1.15], "foglie_scure": [0.0, 0.0, 1.1],
	"macchia": [0.0, 0.0, 1.3], "fiore": [0.0, 0.0, 1.2], "tegola": [0.15, 0.5, 1.0], "tegola_scura": [0.15, 0.5, 1.0],
	"marmo": [0.35, 0.3, 1.0], "intonaco": [0.55, 0.45, 1.1], "tunica": [0.0, 0.0, 1.1], "pelle": [0.0, 0.0, 1.1],
	"capelli": [0.0, 0.0, 1.0], "giocatore": [0.0, 0.0, 1.3], "sandali": [0.0, 0.0, 1.0], "corda": [0.0, 0.0, 1.0],
	"persiana": [0.2, 0.3, 1.2], "lino": [0.2, 0.2, 1.1], "terracotta": [0.25, 0.3, 1.25],
	"tegola_b": [0.15, 0.5, 1.0], "tegola_c": [0.15, 0.5, 1.0], "orto": [0.0, 0.0, 1.3], "geranio": [0.0, 0.0, 1.3],
	"foglie_chiare": [0.0, 0.0, 1.15], "paglia": [0.2, 0.2, 1.15], "terra": [0.0, 0.3, 1.1], "pietra_vista": [0.5, 0.4, 1.1],
	"bandiera_rossa": [0.0, 0.0, 1.2], "grano": [0.0, 0.1, 1.25], "grano_verde": [0.0, 0.0, 1.25], "pane": [0.1, 0.2, 1.2],
	"pesce": [0.0, 0.0, 1.0], "rete": [0.1, 0.1, 1.0], "asino": [0.0, 0.1, 1.0], "maiale": [0.0, 0.2, 1.1],
	"lana": [0.1, 0.2, 1.0], "pelle_scura": [0.0, 0.0, 1.0], "capra": [0.0, 0.1, 1.0], "carne": [0.0, 0.1, 1.15],
	"formaggio": [0.1, 0.2, 1.1], "miele": [0.0, 0.0, 1.2], "latte": [0.0, 0.0, 1.0], "uva": [0.0, 0.0, 1.2],
	"cipolla": [0.0, 0.1, 1.2], "arancia": [0.0, 0.0, 1.25], "bergamotto": [0.0, 0.0, 1.2], "oliva": [0.0, 0.0, 1.1],
	"vino": [0.0, 0.0, 1.1], "spada": [0.0, 0.0, 1.0], "minerale": [0.3, 0.3, 1.15], "carbone": [0.0, 0.0, 1.0],
	"lingotto": [0.1, 0.1, 1.0], "brace": [0.0, 0.0, 1.3], "fumo": [0.0, 0.0, 1.0], "argilla": [0.2, 0.2, 1.15],
	"argilla_cruda": [0.3, 0.3, 1.05], "sale": [0.1, 0.1, 1.0], "moneta": [0.0, 0.0, 1.1], "argento_grezzo": [0.2, 0.2, 1.0],
	"stoffa_rossa": [0.0, 0.0, 1.15], "bronzo": [0.1, 0.1, 1.1],
}


static func catalogo() -> Dictionary:
	var c := {
		"casa_greca": {"crea": casa_greca.bind(1)},
		"magazzino": {"crea": magazzino},
		"boscaiolo": {"crea": boscaiolo},
		"segheria": {"crea": segheria},
		"frantoio": {"crea": frantoio},
		"cava": {"crea": cava},
		"guardaboschi": {"crea": guardaboschi},
		"torre": {"crea": torre},
		"pozzo": {"crea": pozzo},
		"fattoria": {"crea": fattoria},
		"mulino": {"crea": mulino},
		"forno": {"crea": forno},
		"pescatore": {"crea": capanna_pescatore},
		"porcile": {"crea": porcile},
		"macelleria": {"crea": macelleria},
		"ovile": {"crea": ovile},
		"capraio": {"crea": capraio},
		"apiario": {"crea": apiario},
		"caseificio": {"crea": caseificio},
		"uliveto": {"crea": uliveto},
		"vigneto": {"crea": vigneto},
		"cantina": {"crea": cantina},
		"ortolano": {"crea": ortolano},
		"agrumeto": {"crea": agrumeto},
		"pesca_spada": {"crea": pesca_spada},
		"miniera_ferro": {"crea": miniera_ferro},
		"carbonaia": {"crea": carbonaia},
		"fonderia": {"crea": fonderia},
		"fabbro": {"crea": fabbro},
		"miniera_argento": {"crea": miniera_ferro.bind("argento_grezzo")},
		"zecca": {"crea": zecca},
		"argillaio": {"crea": argillaio},
		"fornace": {"crea": fornace},
		"saline": {"crea": saline},
		"tessitura": {"crea": tessitura},
		"agora": {"crea": agora},
		"castello": {"crea": castello},
		"cantiere_0": {"crea": cantiere.bind(0)},
		"cantiere_1": {"crea": cantiere.bind(1)},
		"cantiere_2": {"crea": cantiere.bind(2)},
		"bandierina": {"crea": bandierina},
		"merce_assi": {"crea": merce.bind("assi")},
		"merce_tronchi": {"crea": merce.bind("tronchi")},
		"merce_pietra": {"crea": merce.bind("pietra")},
		"merce_grano": {"crea": merce.bind("grano")},
		"merce_farina": {"crea": merce.bind("farina")},
		"merce_pane": {"crea": merce.bind("pane")},
		"merce_acqua": {"crea": merce.bind("acqua")},
		"merce_pesce": {"crea": merce.bind("pesce")},
		"merce_maiale": {"crea": merce.bind("maiale")},
		"merce_carne": {"crea": merce.bind("carne")},
		"merce_latte": {"crea": merce.bind("latte")},
		"merce_lana": {"crea": merce.bind("lana")},
		"merce_formaggio": {"crea": merce.bind("formaggio")},
		"merce_miele": {"crea": merce.bind("miele")},
		"merce_olive": {"crea": merce.bind("olive")},
		"merce_olio": {"crea": merce.bind("olio")},
		"merce_uva": {"crea": merce.bind("uva")},
		"merce_vino": {"crea": merce.bind("vino")},
		"merce_ortaggi": {"crea": merce.bind("ortaggi")},
		"merce_cipolle": {"crea": merce.bind("cipolle")},
		"merce_agrumi": {"crea": merce.bind("agrumi")},
		"merce_pesce_spada": {"crea": merce.bind("pesce_spada")},
		"merce_ferro": {"crea": merce.bind("ferro")},
		"merce_carbone": {"crea": merce.bind("carbone")},
		"merce_lingotti": {"crea": merce.bind("lingotti")},
		"merce_argilla": {"crea": merce.bind("argilla")},
		"merce_anfore": {"crea": merce.bind("anfore")},
		"merce_sale": {"crea": merce.bind("sale")},
		"merce_argento": {"crea": merce.bind("argento")},
		"merce_monete": {"crea": merce.bind("monete")},
		"merce_stoffa": {"crea": merce.bind("stoffa")},
		"stoppie": {"crea": stoppie},
		"cespuglio_1": {"crea": cespuglio.bind(1)},
		"cespuglio_2": {"crea": cespuglio.bind(2)},
		"fiori_1": {"crea": fiori.bind(1)},
		"fiori_2": {"crea": fiori.bind(2)},
		"funghi": {"crea": funghi.bind(3)},
		"rocce_1": {"crea": rocce.bind(1)},
		"rocce_2": {"crea": rocce.bind(2)},
		"rocce_3": {"crea": rocce.bind(3)},
	}
	# alberi: più varianti per specie
	for k in 4:
		c["pino_%d" % (k + 1)] = {"crea": pino_laricio.bind(k + 1)}
		c["castagno_%d" % (k + 1)] = {"crea": castagno.bind(k + 11)}
		c["quercia_%d" % (k + 1)] = {"crea": quercia.bind(k + 21)}
	for k in 3:
		c["ulivo_%d" % (k + 1)] = {"crea": ulivo.bind(k + 3)}
	# risorse naturali che cambiano: ceppo, alberelli che crescono, rocce consumate
	c["ceppo"] = {"crea": ceppo}
	for k in 3:
		c["alberello_%d" % (k + 1)] = {"crea": alberello.bind(k)}
	for k in 4:
		c["campo_%d" % (k + 1)] = {"crea": campo.bind(k)}
		c["vite_%d" % (k + 1)] = {"crea": vite.bind(k)}
		c["orto_%d" % (k + 1)] = {"crea": orto_campo.bind(k)}
		c["agrumi_%d" % (k + 1)] = {"crea": agrumi.bind(k)}
	for att in ["ascia", "piccone", "pala", "falce", "canna", "sega", "martello"]:
		c["merce_" + att] = {"crea": merce.bind(att)}
	c["guardia"] = {"crea": guardia, "posa": posa_cammino,
		"fotogrammi": 8, "direzioni": 8, "dimensione": Vector2i(96, 96), "ancora": Vector2(42, 80)}
	c["barca_remi"] = {"crea": barca_remi, "posa": posa_remata,
		"fotogrammi": 8, "direzioni": 8, "dimensione": Vector2i(112, 96), "ancora": Vector2(56, 64)}
	# mestieri: camminata con l'attrezzo e gesto di lavoro (8 direzioni × 8 fotogrammi)
	for att in ["ascia", "piccone", "pala", "falce", "canna"]:
		c["lavoratore_%s" % att] = {"crea": lavoratore.bind(att), "posa": posa_cammino,
			"fotogrammi": 8, "direzioni": 8, "dimensione": Vector2i(96, 96), "ancora": Vector2(42, 80)}
		c["lavoratore_%s_lavoro" % att] = {"crea": lavoratore.bind(att), "posa": posa_pesca if att == "canna" else posa_lavoro,
			"fotogrammi": 8, "direzioni": 8, "dimensione": Vector2i(96, 96), "ancora": Vector2(42, 80)}
	# persone: fogli di animazione 8 direzioni × 8 passi
	for carico in ["nessuno", "tronco", "asse", "anfora", "pietra", "covone", "sacco", "cesta", "pesce", "maiale", "carne", "lana", "formaggio", "olive", "uva", "ortaggi", "cipolle", "agrumi", "spada", "carbone", "lingotti", "attrezzi"]:
		c["portatore_" + carico] = {"crea": portatore.bind("" if carico == "nessuno" else carico), "posa": posa_cammino,
			"fotogrammi": 8, "direzioni": 8, "dimensione": Vector2i(80, 80), "ancora": Vector2(34, 68)}
	return c


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


## Texture di muro a pietre: blocchi irregolari con malta scura tra uno e l'altro.
static func _pietre_murate(seme: int, dim := 128) -> ImageTexture:
	var rng := RandomNumberGenerator.new()
	rng.seed = seme
	var img := Image.create(dim, dim, false, Image.FORMAT_RGBA8)
	img.fill(Color("5a5046"))
	var n := FastNoiseLite.new()
	n.seed = seme
	n.frequency = 0.15
	var y := 0
	while y < dim:
		var h := rng.randi_range(9, 16)
		var x := -rng.randi_range(0, 12)
		while x < dim:
			var w := rng.randi_range(12, 26)
			var base := Color("9a8a74").lerp(Color("c8b89a"), rng.randf())
			for yy in range(y + 1, mini(y + h - 1, dim)):
				for xx in range(maxi(x + 1, 0), mini(x + w - 1, dim)):
					var v := n.get_noise_2d(xx, yy) * 0.12
					var bordo := 1.0 - 0.18 * float(yy == y + 1 or xx == x + 1)
					img.set_pixel(xx, yy, Color(base.r + v, base.g + v, base.b + v) * bordo)
			x += w
		y += h
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
			m.albedo_texture = _rumore(4, 0.11, Color("5e2618"), Color("9a462a"))
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
		"pietra_vista":
			m.albedo_texture = _pietre_murate(19)
			m.uv1_scale = Vector3(1.6, 1.6, 1.6)
		"tegola_b":
			m.albedo_texture = _rumore(20, 0.12, Color("6a2c1b"), Color("9e4f2e"))
			m.uv1_scale = Vector3(4, 4, 4)
		"tegola_c":
			m.albedo_texture = _rumore(21, 0.12, Color("7a3a24"), Color("aa6440"))
			m.uv1_scale = Vector3(4, 4, 4)
		"legno_vecchio":
			m.albedo_texture = _rumore(22, 0.25, Color("4e3f31"), Color("8a7559"))
			m.uv1_scale = Vector3(1, 6, 1)
		"terra":
			m.albedo_texture = _rumore(23, 0.2, Color("5d4127"), Color("8a6a44"))
		"orto":
			m.albedo_texture = _rumore(24, 0.5, Color("2e5a1c"), Color("74a63a"))
		"geranio":
			m.albedo_texture = _rumore(25, 0.6, Color("a8161c"), Color("e8473a"))
		"fuliggine":
			m.albedo_color = Color("2a2420")
		"paglia":
			m.albedo_texture = _rumore(26, 0.3, Color("a8873e"), Color("e0c271"))
			m.uv1_scale = Vector3(2, 6, 2)
		"foglie":
			m.albedo_texture = _rumore(27, 0.45, Color("1e4212"), Color("5a8c28"))
			m.uv1_scale = Vector3(4, 4, 4)
		"foglie_scure":
			m.albedo_texture = _rumore(28, 0.45, Color("10290b"), Color("355e1c"))
			m.uv1_scale = Vector3(4, 4, 4)
		"foglie_chiare":
			m.albedo_texture = _rumore(29, 0.45, Color("41701c"), Color("86ad3c"))
			m.uv1_scale = Vector3(4, 4, 4)
		"fusto_chiaro":
			m.albedo_texture = _rumore(30, 0.25, Color("5a4632"), Color("8e7656"))
			m.uv1_scale = Vector3(2, 8, 2)
		"bandiera_rossa":
			m.albedo_color = Color("b0322a")
		"persiana":
			m.albedo_color = Color("3f6f96")
		"buio":
			m.albedo_color = Color("1e140d")
		"grano":
			m.albedo_texture = _rumore(31, 0.5, Color("c08a22"), Color("f2cf5e"))
			m.uv1_scale = Vector3(3, 6, 3)
		"grano_verde":
			m.albedo_texture = _rumore(32, 0.5, Color("4f7d1f"), Color("9cc04a"))
			m.uv1_scale = Vector3(3, 6, 3)
		"pane":
			m.albedo_texture = _rumore(33, 0.4, Color("8a4a1c"), Color("d08a44"))
		"pesce":
			m.albedo_texture = _rumore(34, 0.5, Color("6f8c9c"), Color("d6e2e8"))
			m.metallic = 0.3
			m.roughness = 0.45
		"rete":
			m.albedo_color = Color("8a7550")
			m.cull_mode = BaseMaterial3D.CULL_DISABLED
		"asino":
			m.albedo_texture = _rumore(35, 0.3, Color("5e5650"), Color("8f857a"))
		"maiale":
			m.albedo_texture = _rumore(36, 0.3, Color("c98a80"), Color("f0b8a8"))
		"lana":
			m.albedo_texture = _rumore(37, 0.8, Color("cfc6ae"), Color("f6f1e2"))
		"pelle_scura":
			m.albedo_color = Color("3a2c24")
		"capra":
			m.albedo_texture = _rumore(38, 0.4, Color("2e2420"), Color("7a5a40"))
		"carne":
			m.albedo_texture = _rumore(39, 0.5, Color("7a2a20"), Color("b85a40"))
		"formaggio":
			m.albedo_texture = _rumore(40, 0.4, Color("d8b860"), Color("f6e6a6"))
		"miele":
			m.albedo_color = Color("e0a020")
		"latte":
			m.albedo_color = Color("f4f2ea")
		"uva":
			m.albedo_texture = _rumore(41, 0.9, Color("2e1438"), Color("6a3a72"))
		"cipolla":
			m.albedo_texture = _rumore(42, 0.6, Color("7a1838"), Color("c0486a"))
		"arancia":
			m.albedo_color = Color("f08a1a")
		"bergamotto":
			m.albedo_color = Color("d8d040")
		"oliva":
			m.albedo_texture = _rumore(43, 0.9, Color("1e2410"), Color("4a5a20"))
		"vino":
			m.albedo_color = Color("4a0c1a")
			m.roughness = 0.2
		"minerale":
			m.albedo_texture = _rumore(45, 0.7, Color("4a2a20"), Color("9a5a3a"))
		"carbone":
			m.albedo_texture = _rumore(46, 0.8, Color("141210"), Color("3a3634"))
			m.roughness = 0.6
		"lingotto":
			m.albedo_texture = _rumore(47, 0.4, Color("5a5e66"), Color("9aa0a8"))
			m.metallic = 0.5
			m.roughness = 0.4
		"brace":
			m.albedo_color = Color("ff6a1a")
			m.emission_enabled = true
			m.emission = Color("ff5a10")
			m.emission_energy_multiplier = 1.5
		"argilla":
			m.albedo_texture = _rumore(48, 0.4, Color("8a3a1c"), Color("c86a3a"))
		"argilla_cruda":
			m.albedo_texture = _rumore(49, 0.3, Color("8a6040"), Color("b89068"))
		"sale":
			m.albedo_texture = _rumore(50, 0.9, Color("d8dce0"), Color("ffffff"))
		"moneta":
			m.albedo_color = Color("d8c070")
			m.metallic = 0.7
			m.roughness = 0.35
		"argento_grezzo":
			m.albedo_texture = _rumore(51, 0.7, Color("4a4c54"), Color("c8ccd8"))
			m.metallic = 0.4
		"bronzo":
			m.albedo_texture = _rumore(52, 0.5, Color("8a5a20"), Color("d8a048"))
			m.metallic = 0.6
			m.roughness = 0.4
		"stoffa_rossa":
			m.albedo_color = Color("a8302a")
			m.cull_mode = BaseMaterial3D.CULL_DISABLED
		"fumo":
			m.albedo_color = Color(0.75, 0.73, 0.7, 0.55)
			m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		"spada":
			m.albedo_texture = _rumore(44, 0.4, Color("3a4e66"), Color("a8bcc8"))
			m.metallic = 0.3
			m.roughness = 0.4
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
		"covone":
			var cv := covone(1.0)
			cv.position = spalla + Vector3(0.08, 0.0, 0)
			cv.rotation_degrees = Vector3(70, 0, 0)
			corpo.add_child(cv)
		"sacco":
			corpo.add_child(sfera(0.075, spalla + Vector3(0.06, 0.04, -0.01), "lino", Vector3(0.8, 0.9, 1.25)))
		"cesta", "pesce", "formaggio", "olive", "uva", "ortaggi", "cipolle", "agrumi":
			corpo.add_child(cesta(Vector3(0, anca + 0.31, 0), "pane" if carico == "cesta" else carico, 1.15))
		"maiale":
			var mm := maiale(Vector3(0.0, anca + 0.02, 0.09), 90)
			mm.scale = Vector3.ONE * 0.7
			corpo.add_child(mm)
		"carne":
			corpo.add_child(sfera(0.05, spalla + Vector3(0.07, 0.03, 0), "carne", Vector3(0.9, 1.4, 0.8)))
		"lana":
			corpo.add_child(sfera(0.08, spalla + Vector3(0.05, 0.05, -0.01), "lana", Vector3(1.0, 0.8, 1.2)))
		"carbone":
			corpo.add_child(cesta(Vector3(0, anca + 0.31, 0), "carbone", 1.15))
		"lingotti":
			for k in 3:
				corpo.add_child(scatola(Vector3(0.09, 0.025, 0.035), Vector3(-0.01 * k, anca + 0.33 + k * 0.026, 0), "lingotto", Vector3(0, 10 * k, 0)))
		"attrezzi":
			for k in 3:
				var a := attrezzo(["ascia", "piccone", "pala"][k])
				a.position = spalla + Vector3(0.07, 0.01 + k * 0.012, -0.03 + k * 0.03)
				a.rotation_degrees = Vector3(0, 90, 0)
				corpo.add_child(a)
		"spada":
			var sp := pesce_spada_modello()
			sp.position = spalla + Vector3(0.07, 0.0, -0.05)
			sp.rotation_degrees = Vector3(0, 90, 0)
			sp.scale = Vector3.ONE * 0.8
			corpo.add_child(sp)
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
	corpo.rotation.x = 0.0
	if carico == "attrezzo":
		# attrezzo in spalla
		bs.rotation = Vector3(-oscill * 0.45, 0, 0)
		bd.rotation = Vector3(-2.6, 0, 0.2)
	elif carico == "":
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



# ------------------------------------------------------------------ altri edifici greci (step 02)





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
		"grano":
			var cv := covone(1.1)
			cv.rotation_degrees = Vector3(0, 0, 80)
			cv.position = Vector3(0.0, 0.05, 0)
			r.add_child(cv)
		"farina":
			r.add_child(sfera(0.07, Vector3(0, 0.06, 0), "lino", Vector3(1, 0.85, 0.8)))
			r.add_child(cilindro(0.025, 0.02, 0.03, Vector3(0, 0.125, 0), "lino", Vector3.ZERO, 8))
		"pane":
			r.add_child(cesta(Vector3.ZERO, "pane"))
		"acqua":
			r.add_child(anfora(Vector3.ZERO, 1.3))
		"pesce":
			r.add_child(cesta(Vector3.ZERO, "pesce"))
		"maiale":
			r.add_child(maiale(Vector3.ZERO, 30))
		"carne":
			r.add_child(sfera(0.05, Vector3(0, 0.04, 0), "carne", Vector3(1.5, 0.8, 1.0)))
			r.add_child(cilindro(0.016, 0.016, 0.1, Vector3(0.05, 0.016, 0.05), "carne", Vector3(0, 30, 90), 8))
		"latte":
			r.add_child(anfora(Vector3.ZERO, 1.2))
			r.add_child(cilindro(0.02, 0.02, 0.004, Vector3(0, 0.235, 0), "latte", Vector3.ZERO, 8))
		"lana":
			r.add_child(sfera(0.07, Vector3(0, 0.05, 0), "lana", Vector3(1.3, 0.7, 1.0)))
		"formaggio":
			r.add_child(cesta(Vector3.ZERO, "formaggio"))
		"olive", "uva", "ortaggi", "cipolle", "agrumi":
			r.add_child(cesta(Vector3.ZERO, tipo))
		"olio", "vino":
			r.add_child(anfora(Vector3.ZERO, 1.3))
			r.add_child(cilindro(0.02, 0.02, 0.004, Vector3(0, 0.235, 0), "miele" if tipo == "olio" else "vino", Vector3.ZERO, 8))
		"pesce_spada":
			r.add_child(pesce_spada_modello())
		"ferro":
			r.add_child(mucchio(Vector3.ZERO, "minerale", 5, 8, 0.04))
		"carbone":
			r.add_child(cesta(Vector3.ZERO, "carbone"))
		"lingotti":
			for k in 3:
				r.add_child(scatola(Vector3(0.1, 0.028, 0.04), Vector3((k % 2) * 0.02, 0.014 + k * 0.028, 0), "lingotto", Vector3(0, 20 + k * 30, 0)))
		"argilla":
			r.add_child(mucchio(Vector3.ZERO, "argilla", 5, 11, 0.04))
		"anfore":
			r.add_child(anfora(Vector3(-0.03, 0, 0), 1.2))
			r.add_child(anfora(Vector3(0.05, 0, 0.03), 1.1))
		"sale":
			r.add_child(sfera(0.065, Vector3(0, 0.05, 0), "lino", Vector3(1, 0.8, 0.8)))
			r.add_child(sfera(0.03, Vector3(0, 0.1, 0), "sale"))
		"argento":
			r.add_child(mucchio(Vector3.ZERO, "argento_grezzo", 5, 12, 0.04))
		"monete":
			r.add_child(sfera(0.05, Vector3(0, 0.04, 0), "pelle_scura", Vector3(1, 0.9, 1)))
			for k in 4:
				r.add_child(cilindro(0.016, 0.016, 0.005, Vector3(0.05 + k * 0.004, 0.003 + k * 0.006, 0.03), "moneta", Vector3.ZERO, 8))
		"stoffa":
			r.add_child(cilindro(0.035, 0.035, 0.16, Vector3(0, 0.035, 0), "stoffa_rossa", Vector3(90, 30, 0), 10))
			r.add_child(cilindro(0.03, 0.03, 0.14, Vector3(0.03, 0.09, 0.0), "stoffa", Vector3(90, 50, 0), 10))
		"ascia", "piccone", "pala", "falce", "canna", "sega", "martello":
			var a := attrezzo(tipo)
			a.rotation_degrees.y = 30
			a.scale = Vector3.ONE * 1.3
			r.add_child(a)
		"miele":
			r.add_child(cilindro(0.04, 0.035, 0.08, Vector3(0, 0.04, 0), "terracotta", Vector3.ZERO, 10))
			r.add_child(cilindro(0.032, 0.032, 0.005, Vector3(0, 0.082, 0), "miele", Vector3.ZERO, 10))
	r.scale = Vector3.ONE * 1.25
	return r


# =================================================================== KIT G2: parti ricche
# Coordinate: +Z = faccia sinistra (illuminata, con la porta), +X = faccia destra (in ombra).

static func _rng(seme: int) -> RandomNumberGenerator:
	var r := RandomNumberGenerator.new()
	r.seed = seme
	return r


## Muri intonacati "vissuti": zoccolo di pietra, cantonali squadrati, chiazze di intonaco caduto.
static func casa_muri(r: Node3D, lx: float, lz: float, h: float, seme: int, mat := "intonaco") -> void:
	var rng := _rng(seme)
	r.add_child(scatola(Vector3(lx + 0.06, 0.07, lz + 0.06), Vector3(0, 0.035, 0), "pietra"))
	r.add_child(scatola(Vector3(lx, h, lz), Vector3(0, 0.07 + h * 0.5, 0), mat))
	# chiazze dove l'intonaco è caduto e si vede la pietra
	for k in 3:
		var w := rng.randf_range(0.1, 0.22)
		var hh := rng.randf_range(0.06, 0.14)
		var y := rng.randf_range(0.12, h - 0.05)
		if k < 2:
			r.add_child(scatola(Vector3(w, hh, 0.01), Vector3(rng.randf_range(-lx * 0.4, lx * 0.4), y, lz * 0.5 + 0.002), "pietra_vista"))
		else:
			r.add_child(scatola(Vector3(0.01, hh, w), Vector3(lx * 0.5 + 0.002, y, rng.randf_range(-lz * 0.4, lz * 0.4)), "pietra_vista"))
	# cantonali sugli spigoli in vista
	var y := 0.1
	var k := 0
	while y < h:
		var lungo := 0.09 if k % 2 == 0 else 0.055
		r.add_child(scatola(Vector3(0.035, 0.05, lungo), Vector3(lx * 0.5 + 0.004, y, lz * 0.5 - lungo * 0.5 + 0.006), "blocco"))
		r.add_child(scatola(Vector3(lungo, 0.05, 0.035), Vector3(lx * 0.5 - lungo * 0.5 + 0.006, y, lz * 0.5 + 0.004), "blocco"))
		r.add_child(scatola(Vector3(lungo, 0.05, 0.035), Vector3(-lx * 0.5 + lungo * 0.5 - 0.006, y, lz * 0.5 + 0.004), "blocco"))
		y += 0.055
		k += 1


static func finestra_z(r: Node3D, x: float, y: float, zf: float, w := 0.1, h := 0.12, fiori := false) -> void:
	r.add_child(scatola(Vector3(w, h, 0.02), Vector3(x, y, zf + 0.002), "buio"))
	r.add_child(scatola(Vector3(w + 0.03, 0.02, 0.03), Vector3(x, y + h * 0.5 + 0.012, zf + 0.012), "legno_vecchio"))
	r.add_child(scatola(Vector3(w + 0.04, 0.018, 0.05), Vector3(x, y - h * 0.5 - 0.01, zf + 0.02), "blocco"))
	for lato in [-1, 1]:
		var p := scatola(Vector3(w * 0.5, h, 0.012), Vector3(x + lato * (w * 0.75 + 0.01), y, zf + 0.02), "persiana", Vector3(0, lato * 25, 0))
		r.add_child(p)
	if fiori:
		r.add_child(scatola(Vector3(w + 0.02, 0.03, 0.035), Vector3(x, y - h * 0.5 + 0.005, zf + 0.04), "terracotta"))
		for i in 4:
			r.add_child(sfera(0.018, Vector3(x - w * 0.4 + i * w * 0.27, y - h * 0.5 + 0.035, zf + 0.045), "geranio" if i % 2 == 0 else "orto"))


static func finestra_x(r: Node3D, z: float, y: float, xf: float, w := 0.1, h := 0.12) -> void:
	r.add_child(scatola(Vector3(0.02, h, w), Vector3(xf + 0.002, y, z), "buio"))
	r.add_child(scatola(Vector3(0.03, 0.02, w + 0.03), Vector3(xf + 0.012, y + h * 0.5 + 0.012, z), "legno_vecchio"))
	r.add_child(scatola(Vector3(0.05, 0.018, w + 0.04), Vector3(xf + 0.02, y - h * 0.5 - 0.01, z), "blocco"))
	for lato in [-1, 1]:
		r.add_child(scatola(Vector3(0.012, h, w * 0.5), Vector3(xf + 0.02, y, z + lato * (w * 0.75 + 0.01)), "persiana", Vector3(0, lato * -25, 0)))


static func porta_z(r: Node3D, x: float, zf: float, w := 0.12, h := 0.22) -> void:
	r.add_child(scatola(Vector3(w, h, 0.02), Vector3(x, 0.07 + h * 0.5, zf + 0.003), "legno_scuro"))
	for k in 3:
		r.add_child(scatola(Vector3(0.006, h - 0.02, 0.008), Vector3(x - w * 0.3 + k * w * 0.3, 0.07 + h * 0.5, zf + 0.014), "legno_vecchio"))
	r.add_child(scatola(Vector3(w + 0.05, 0.035, 0.04), Vector3(x, 0.07 + h + 0.017, zf + 0.012), "legno_vecchio"))
	for lato in [-1, 1]:
		r.add_child(scatola(Vector3(0.025, h, 0.03), Vector3(x + lato * (w * 0.5 + 0.012), 0.07 + h * 0.5, zf + 0.01), "blocco"))
	r.add_child(scatola(Vector3(w + 0.08, 0.035, 0.08), Vector3(x, 0.017, zf + 0.04), "pietra"))


## Tetto a coppi irregolari (due tinte, piccole rotazioni), travetti sporgenti sotto la gronda.
static func tetto(r: Node3D, larg: float, prof: float, base_y: float, pendenza: float, seme: int) -> void:
	var rng := _rng(seme)
	var meta := prof * 0.5 + 0.07
	var ang := deg_to_rad(pendenza)
	var lung := meta / cos(ang)
	var alt := meta * tan(ang)
	for lato in [-1, 1]:
		var falda := Node3D.new()
		falda.position = Vector3(0, base_y + alt * 0.5, lato * meta * 0.5)
		falda.rotation.x = lato * ang
		r.add_child(falda)
		falda.add_child(scatola(Vector3(larg + 0.14, 0.03, lung), Vector3.ZERO, "tegola_scura"))
		var n := int((larg + 0.12) / 0.07)
		for k in n:
			var x := -larg * 0.5 - 0.04 + (k + 0.5) * (larg + 0.08) / n
			var mat: String = ["tegola", "tegola_b", "tegola_c"][rng.randi_range(0, 2)]
			var coppo := cilindro(0.03, 0.027, lung, Vector3(x, 0.02 + rng.randf_range(0, 0.004), 0), mat, Vector3(90, rng.randf_range(-1.5, 1.5), 0), 8)
			coppo.scale = Vector3(1, 1, 0.55)
			falda.add_child(coppo)
	r.add_child(cilindro(0.045, 0.045, larg + 0.18, Vector3(0, base_y + alt + 0.025, 0), "tegola_b", Vector3(0, 0, 90), 10))
	# travetti sotto la gronda sul lato in vista
	var nt := int(larg / 0.12)
	for k in nt + 1:
		var x := -larg * 0.5 + k * larg / nt
		r.add_child(scatola(Vector3(0.025, 0.025, 0.09), Vector3(x, base_y - 0.005, prof * 0.5 + 0.03), "legno_vecchio"))


static func comignolo(r: Node3D, pos: Vector3, h := 0.16) -> void:
	r.add_child(scatola(Vector3(0.08, h, 0.08), pos + Vector3(0, h * 0.5, 0), "intonaco"))
	r.add_child(scatola(Vector3(0.085, 0.035, 0.085), pos + Vector3(0, h - 0.015, 0), "fuliggine"))
	r.add_child(scatola(Vector3(0.11, 0.02, 0.11), pos + Vector3(0, h + 0.01, 0), "tegola_scura"))


static func barile(pos: Vector3, scala := 1.0) -> Node3D:
	var n := Node3D.new()
	n.position = pos
	n.scale = Vector3.ONE * scala
	n.add_child(cilindro(0.045, 0.045, 0.1, Vector3(0, 0.05, 0), "legno", Vector3.ZERO, 12))
	for y in [0.02, 0.08]:
		n.add_child(cilindro(0.048, 0.048, 0.008, Vector3(0, y, 0), "ferro", Vector3.ZERO, 12))
	return n


static func vaso_fiori(pos: Vector3) -> Node3D:
	var n := Node3D.new()
	n.position = pos
	n.add_child(cilindro(0.025, 0.02, 0.04, Vector3(0, 0.02, 0), "terracotta", Vector3.ZERO, 8))
	n.add_child(sfera(0.028, Vector3(0, 0.05, 0), "orto"))
	n.add_child(sfera(0.014, Vector3(0.012, 0.07, 0.01), "geranio"))
	n.add_child(sfera(0.012, Vector3(-0.012, 0.065, -0.005), "geranio"))
	return n


static func panca(pos: Vector3, rot := 0.0) -> Node3D:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot
	n.add_child(scatola(Vector3(0.2, 0.02, 0.05), Vector3(0, 0.05, 0), "legno"))
	for lato in [-1, 1]:
		n.add_child(scatola(Vector3(0.02, 0.05, 0.04), Vector3(lato * 0.08, 0.025, 0), "legno_vecchio"))
	return n


static func recinto(r: Node3D, da: Vector3, a: Vector3, h := 0.07) -> void:
	var lung := da.distance_to(a)
	var n := int(lung / 0.08) + 1
	for k in n + 1:
		var p := da.lerp(a, float(k) / n)
		r.add_child(cilindro(0.008, 0.007, h, p + Vector3(0, h * 0.5, 0), "legno_vecchio", Vector3.ZERO, 5))
	var dir := (a - da).normalized()
	var rot := rad_to_deg(atan2(dir.x, dir.z))
	for y in [h * 0.45, h * 0.85]:
		var t := scatola(Vector3(0.008, 0.01, lung), (da + a) * 0.5 + Vector3(0, y, 0), "legno_vecchio", Vector3(0, rot, 0))
		r.add_child(t)


static func orto(r: Node3D, pos: Vector3, lx: float, lz: float, seme: int) -> void:
	var rng := _rng(seme)
	r.add_child(scatola(Vector3(lx, 0.012, lz), pos + Vector3(0, 0.006, 0), "terra"))
	var file := int(lz / 0.07)
	for f in file:
		var z := pos.z - lz * 0.5 + (f + 0.5) * lz / file
		var piante := int(lx / 0.06)
		for k in piante:
			var x := pos.x - lx * 0.5 + (k + 0.5) * lx / piante
			r.add_child(sfera(rng.randf_range(0.018, 0.026), Vector3(x, 0.025, z), "orto" if f % 3 != 2 else "foglie_chiare", Vector3(1, 0.8, 1)))
	recinto(r, pos + Vector3(-lx * 0.5 - 0.02, 0, lz * 0.5 + 0.02), pos + Vector3(lx * 0.5 + 0.02, 0, lz * 0.5 + 0.02))
	recinto(r, pos + Vector3(lx * 0.5 + 0.02, 0, -lz * 0.5 - 0.02), pos + Vector3(lx * 0.5 + 0.02, 0, lz * 0.5 + 0.02))


static func legnaia(r: Node3D, pos: Vector3, lung := 0.3, file := 4) -> void:
	for f in file:
		for k in int(lung / 0.045):
			var x := pos.x - lung * 0.5 + (k + 0.5) * 0.045
			r.add_child(cilindro(0.02, 0.02, 0.1, Vector3(x, pos.y + 0.02 + f * 0.038, pos.z), "legno_chiaro" if (k + f) % 3 == 0 else "corteccia", Vector3(90, 0, 0), 6))


static func carretto(r: Node3D, pos: Vector3, rot := 0.0, carico := "") -> void:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot
	r.add_child(n)
	n.add_child(scatola(Vector3(0.3, 0.025, 0.18), Vector3(0, 0.1, 0), "legno"))
	for lato in [-1, 1]:
		n.add_child(scatola(Vector3(0.3, 0.05, 0.012), Vector3(0, 0.13, lato * 0.09), "legno_vecchio"))
		n.add_child(cilindro(0.065, 0.065, 0.02, Vector3(-0.02, 0.065, lato * 0.11), "legno_vecchio", Vector3(90, 0, 0), 14))
		n.add_child(cilindro(0.015, 0.015, 0.03, Vector3(-0.02, 0.065, lato * 0.115), "ferro", Vector3(90, 0, 0), 6))
	n.add_child(scatola(Vector3(0.24, 0.015, 0.015), Vector3(0.26, 0.07, 0.05), "legno", Vector3(0, 0, -12)))
	n.add_child(scatola(Vector3(0.24, 0.015, 0.015), Vector3(0.26, 0.07, -0.05), "legno", Vector3(0, 0, -12)))
	match carico:
		"sacchi":
			for i in 3:
				n.add_child(sfera(0.05, Vector3(-0.08 + i * 0.08, 0.15, 0.0), "lino", Vector3(1, 0.75, 0.8)))
		"tronchi":
			for i in 3:
				n.add_child(cilindro(0.03, 0.03, 0.34, Vector3(0, 0.14 + (i / 2) * 0.05, -0.035 + (i % 2) * 0.07), "corteccia", Vector3(0, 0, 90), 7))


# =================================================================== ALBERI G2

## Chioma fatta di tanti ciuffi: sotto più scuri, sopra più chiari (come le foglie al sole).
static func chioma(r: Node3D, centro: Vector3, raggio: Vector3, ciuffi: int, seme: int, mat_scuro := "foglie_scure", mat := "foglie", mat_chiaro := "foglie_chiare", dim := Vector2(0.045, 0.08)) -> void:
	var rng := _rng(seme)
	for k in ciuffi:
		var d := Vector3(rng.randf_range(-1, 1), rng.randf_range(-1, 1), rng.randf_range(-1, 1))
		if d.length() > 1.0:
			d = d.normalized() * rng.randf_range(0.6, 1.0)
		var p := centro + d * raggio
		var m := mat_scuro if d.y < -0.1 or rng.randf() < 0.18 else (mat_chiaro if d.y > 0.45 and rng.randf() < 0.45 else mat)
		r.add_child(sfera(rng.randf_range(dim.x, dim.y), p, m, Vector3(1, 0.85, 1)))


static func ramo(r: Node3D, da: Vector3, a: Vector3, spessore: float, mat := "corteccia") -> void:
	var dir := a - da
	var c := cilindro(spessore, spessore * 0.7, dir.length(), Vector3.ZERO, mat, Vector3.ZERO, 7)
	c.basis = Basis(Quaternion(Vector3.UP, dir.normalized()))
	c.position = (da + a) * 0.5
	r.add_child(c)


static func castagno(seme: int) -> Node3D:
	var rng := _rng(seme)
	var r := Node3D.new()
	var cima := Vector3(rng.randf_range(-0.05, 0.05), 0.42, rng.randf_range(-0.05, 0.05))
	ramo(r, Vector3.ZERO, cima, 0.065)
	for k in 3:
		var a := k * TAU / 3 + rng.randf()
		ramo(r, cima * 0.85, cima + Vector3(cos(a) * 0.22, 0.2, sin(a) * 0.22), 0.03)
	chioma(r, cima + Vector3(0, 0.3, 0), Vector3(0.42, 0.3, 0.42), 170, seme)
	r.add_child(sfera(0.08, Vector3(0.05, 0.02, 0.06), "foglie_scure", Vector3(1.6, 0.4, 1.2)))
	r.scale = Vector3.ONE * rng.randf_range(1.05, 1.25)
	return r


static func quercia(seme: int) -> Node3D:
	var rng := _rng(seme)
	var r := Node3D.new()
	var cima := Vector3(0, 0.34, 0)
	ramo(r, Vector3.ZERO, cima, 0.075)
	var centri := []
	for k in 4:
		var a := k * TAU / 4 + rng.randf_range(-0.4, 0.4)
		var c := cima + Vector3(cos(a) * 0.28, rng.randf_range(0.18, 0.32), sin(a) * 0.28)
		ramo(r, cima * 0.9, c, 0.035)
		centri.append(c)
	for k in centri.size():
		chioma(r, centri[k], Vector3(0.24, 0.18, 0.24), 60, seme * 10 + k)
	chioma(r, cima + Vector3(0, 0.42, 0), Vector3(0.26, 0.18, 0.26), 55, seme * 10 + 9)
	r.scale = Vector3.ONE * rng.randf_range(1.0, 1.2)
	return r


## Pino laricio della Sila: tronco alto e dritto rossiccio, chioma a palchi in cima.
static func pino_laricio(seme: int) -> Node3D:
	var rng := _rng(seme)
	var r := Node3D.new()
	var h := rng.randf_range(1.15, 1.45)
	ramo(r, Vector3.ZERO, Vector3(0, h, 0), 0.05, "fusto_chiaro")
	var palchi := 6
	for k in palchi:
		var t := float(k) / palchi
		var y := lerpf(h * 0.4, h * 0.98, t)
		var rag := lerpf(0.32, 0.1, t) * rng.randf_range(0.85, 1.15)
		for j in 4:
			var a := j * TAU / 4 + rng.randf() * 1.2 + k * 0.9
			var p := Vector3(cos(a) * rag * 0.65, y + rng.randf_range(-0.03, 0.03), sin(a) * rag * 0.65)
			ramo(r, Vector3(0, y - 0.04, 0), p, 0.012, "fusto_chiaro")
			chioma(r, p + Vector3(0, 0.025, 0), Vector3(rag * 0.55, 0.045, rag * 0.55), 9, seme * 100 + k * 10 + j, "foglie_scure", "aghi", "foglie", Vector2(0.035, 0.06))
	chioma(r, Vector3(0, h + 0.04, 0), Vector3(0.07, 0.06, 0.07), 6, seme * 100 + 99, "aghi", "aghi", "foglie", Vector2(0.03, 0.05))
	return r


static func ulivo(seme: int) -> Node3D:
	var rng := _rng(seme)
	var r := Node3D.new()
	# tronco contorto e grigio
	var p := Vector3.ZERO
	for k in 3:
		var q := p + Vector3(rng.randf_range(-0.07, 0.07), 0.1, rng.randf_range(-0.07, 0.07))
		ramo(r, p, q, 0.06 - k * 0.012, "legno_vecchio")
		p = q
	for k in 3:
		var a := k * TAU / 3 + rng.randf()
		var c := p + Vector3(cos(a) * 0.2, 0.12, sin(a) * 0.2)
		ramo(r, p, c, 0.022, "legno_vecchio")
		chioma(r, c + Vector3(0, 0.06, 0), Vector3(0.17, 0.1, 0.17), 22, seme * 7 + k, "foglie_ulivo", "foglie_ulivo", "foglie_chiare", Vector2(0.04, 0.07))
	chioma(r, p + Vector3(0, 0.22, 0), Vector3(0.18, 0.08, 0.18), 18, seme * 7 + 5, "foglie_ulivo", "foglie_ulivo", "foglie_chiare", Vector2(0.04, 0.07))
	r.scale = Vector3.ONE * rng.randf_range(1.1, 1.3)
	return r


static func cespuglio(seme: int) -> Node3D:
	var r := Node3D.new()
	chioma(r, Vector3(0, 0.09, 0), Vector3(0.16, 0.08, 0.14), 22, seme, "foglie_scure", "macchia", "foglie", Vector2(0.035, 0.06))
	if seme % 2 == 0:
		var rng := _rng(seme)
		for k in 7:
			r.add_child(sfera(0.012, Vector3(rng.randf_range(-0.14, 0.14), rng.randf_range(0.1, 0.17), rng.randf_range(-0.06, 0.14)), "geranio" if k % 2 else "fiore"))
	return r


static func fiori(seme: int) -> Node3D:
	var rng := _rng(seme)
	var r := Node3D.new()
	for k in 14:
		var p := Vector3(rng.randf_range(-0.2, 0.2), 0.0, rng.randf_range(-0.2, 0.2))
		r.add_child(cilindro(0.003, 0.003, 0.05, p + Vector3(0, 0.025, 0), "orto", Vector3.ZERO, 4))
		r.add_child(sfera(0.014, p + Vector3(0, 0.055, 0), ["fiore", "geranio", "tunica"][k % 3]))
	return r


static func funghi(seme: int) -> Node3D:
	var rng := _rng(seme)
	var r := Node3D.new()
	for k in 4:
		var p := Vector3(rng.randf_range(-0.1, 0.1), 0, rng.randf_range(-0.1, 0.1))
		r.add_child(cilindro(0.008, 0.01, 0.03, p + Vector3(0, 0.015, 0), "tunica", Vector3.ZERO, 6))
		r.add_child(sfera(0.022, p + Vector3(0, 0.032, 0), "bandiera_rossa" if k % 2 == 0 else "legno", Vector3(1, 0.55, 1)))
	return r


# =================================================================== EDIFICI G2 (impronta 2×2, magazzino 3×3)

static func casa_greca(seme := 1) -> Node3D:
	var r := Node3D.new()
	var corpo := Node3D.new()
	corpo.position = Vector3(-0.12, 0, -0.15)
	r.add_child(corpo)
	var lx := 0.92
	var lz := 0.7
	var h := 0.46
	casa_muri(corpo, lx, lz, h, seme)
	porta_z(corpo, -0.18, lz * 0.5)
	finestra_z(corpo, 0.18, 0.36, lz * 0.5, 0.11, 0.12, true)
	finestra_x(corpo, 0.0, 0.36, lx * 0.5)
	sottotetto(corpo, lx, lz, 0.07 + h, 24.0)
	tetto(corpo, lx + 0.06, lz, 0.07 + h, 24.0, seme)
	comignolo(corpo, Vector3(-0.25, 0.07 + h + 0.06, -0.12))
	# pergolato con vite sul lato
	for px in [-0.36, -0.06]:
		corpo.add_child(cilindro(0.012, 0.012, 0.36, Vector3(px, 0.18, lz * 0.5 + 0.28), "legno_vecchio", Vector3.ZERO, 6))
	corpo.add_child(scatola(Vector3(0.38, 0.02, 0.32), Vector3(-0.21, 0.37, lz * 0.5 + 0.15), "legno_vecchio"))
	chioma(corpo, Vector3(-0.21, 0.4, lz * 0.5 + 0.15), Vector3(0.2, 0.03, 0.16), 26, seme + 50, "foglie_scure", "foglie", "foglie_chiare", Vector2(0.025, 0.045))
	corpo.add_child(panca(Vector3(-0.21, 0, lz * 0.5 + 0.26), 0))
	corpo.add_child(anfora(Vector3(0.08, 0.0, lz * 0.5 + 0.12), 1.15))
	corpo.add_child(anfora(Vector3(0.16, 0.0, lz * 0.5 + 0.16), 1.0))
	corpo.add_child(vaso_fiori(Vector3(-0.02, 0.0, lz * 0.5 + 0.08)))
	# orto recintato e legnaia
	orto(r, Vector3(0.56, 0, 0.42), 0.36, 0.42, seme + 3)
	legnaia(corpo, Vector3(lx * 0.5 + 0.06, 0.0, -0.2), 0.24, 3)
	r.add_child(barile(Vector3(-0.62, 0.0, 0.62)))
	return r


static func magazzino() -> Node3D:
	var r := Node3D.new()
	var lx := 1.75
	var lz := 1.3
	var h := 0.6
	var portico := 0.32
	r.position = Vector3(0, 0, -0.1)
	for k in 3:
		r.add_child(scatola(Vector3(lx + 0.3 - k * 0.1, 0.045, lz + 0.3 - k * 0.1), Vector3(0, 0.022 + k * 0.045, 0), "marmo" if k == 2 else "pietra"))
	var base := 0.135
	var cz := lz - portico
	var cella := Node3D.new()
	cella.position = Vector3(0, base - 0.07, -portico * 0.5)
	r.add_child(cella)
	casa_muri(cella, lx - 0.1, cz, h, 7)
	porta_z(cella, 0.0, cz * 0.5, 0.26, 0.36)
	for fx in [-0.55, 0.55]:
		finestra_z(cella, fx, 0.45, cz * 0.5, 0.12, 0.14)
	finestra_x(cella, 0.0, 0.45, (lx - 0.1) * 0.5)
	# colonnato
	var n := 8
	for k in n:
		var x := -lx * 0.5 + 0.08 + k * (lx - 0.16) / (n - 1)
		var zc := lz * 0.5 - 0.07
		r.add_child(cilindro(0.05, 0.042, h, Vector3(x, base + h * 0.5, zc), "marmo", Vector3.ZERO, 14))
		r.add_child(scatola(Vector3(0.11, 0.03, 0.11), Vector3(x, base + h + 0.01, zc), "marmo"))
		r.add_child(scatola(Vector3(0.1, 0.02, 0.1), Vector3(x, base + 0.01, zc), "marmo"))
	for z in [lz * 0.5 - 0.25]:
		r.add_child(cilindro(0.05, 0.042, h, Vector3(lx * 0.5 - 0.08, base + h * 0.5, z), "marmo", Vector3.ZERO, 14))
	# trabeazione, fregio a triglifi, frontone
	var ty := base + h + 0.025
	r.add_child(scatola(Vector3(lx + 0.04, 0.07, lz + 0.04), Vector3(0, ty + 0.035, 0), "marmo"))
	for k in 20:
		var x := -lx * 0.5 + 0.04 + k * (lx - 0.08) / 19
		r.add_child(scatola(Vector3(0.035, 0.05, 0.012), Vector3(x, ty + 0.035, lz * 0.5 + 0.026), "intonaco_sporco" if k % 2 == 0 else "persiana"))
	r.add_child(scatola(Vector3(lx + 0.08, 0.025, lz + 0.08), Vector3(0, ty + 0.08, 0), "marmo"))
	sottotetto(r, lx + 0.04, lz + 0.04, ty + 0.09, 16.0, "marmo")
	tetto(r, lx + 0.1, lz + 0.04, ty + 0.09, 16.0, 7)
	# merci e vita davanti al magazzino
	for i in 4:
		r.add_child(anfora(Vector3(-0.78 + (i % 2) * 0.09, base - 0.07, lz * 0.5 + 0.2 + (i / 2) * 0.1), 1.2))
	for i in 3:
		r.add_child(cassa(Vector3(0.45 + i * 0.13, base - 0.07, lz * 0.5 + 0.24), i * 12))
	r.add_child(cassa(Vector3(0.52, base - 0.07 + 0.088, lz * 0.5 + 0.24), 25, 0.09))
	for i in 3:
		r.add_child(sacco(Vector3(-0.42 + i * 0.1, base - 0.07, lz * 0.5 + 0.22), i * 0.5))
	r.add_child(barile(Vector3(0.92, 0.0, 0.3), 1.2))
	r.add_child(barile(Vector3(0.95, 0.0, 0.42), 1.2))
	carretto(r, Vector3(-0.2, 0.0, lz * 0.5 + 0.55), 20, "sacchi")
	# stendardo del giocatore
	r.add_child(cilindro(0.012, 0.012, 0.7, Vector3(lx * 0.5 + 0.12, 0.35, lz * 0.5 + 0.12), "legno", Vector3.ZERO, 6))
	r.add_child(scatola(Vector3(0.006, 0.2, 0.14), Vector3(lx * 0.5 + 0.12, 0.6, lz * 0.5 + 0.2), "stoffa"))
	return r


static func boscaiolo() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.15, 0, -0.18)
	r.add_child(c)
	var lx := 0.8
	var lz := 0.62
	var h := 0.36
	c.add_child(scatola(Vector3(lx + 0.06, 0.06, lz + 0.06), Vector3(0, 0.03, 0), "pietra"))
	c.add_child(scatola(Vector3(lx, h, lz), Vector3(0, 0.06 + h * 0.5, 0), "legno"))
	var file := 8
	for k in file:
		var y := 0.08 + k * (h / file)
		c.add_child(cilindro(0.024, 0.024, lx + 0.1, Vector3(0, y, lz * 0.5), "corteccia", Vector3(0, 0, 90), 7))
		c.add_child(cilindro(0.024, 0.024, lz + 0.1, Vector3(lx * 0.5, y + 0.022, 0), "corteccia", Vector3(90, 0, 0), 7))
		for lato in [-1, 1]:
			c.add_child(cilindro(0.021, 0.021, 0.006, Vector3(lato * (lx * 0.5 + 0.05), y, lz * 0.5), "legno_chiaro", Vector3(0, 0, 90), 7))
	porta_z(c, -0.15, lz * 0.5 + 0.02, 0.12, 0.22)
	finestra_z(c, 0.18, 0.3, lz * 0.5 + 0.02, 0.1, 0.09)
	sottotetto(c, lx, lz, 0.06 + h, 32.0, "legno")
	tetto_scandole(c, lx + 0.06, lz, 0.06 + h, 32.0)
	comignolo(c, Vector3(0.2, 0.06 + h + 0.1, -0.1), 0.14)
	# tettoia con legna spaccata
	for pz in [-0.25, 0.25]:
		c.add_child(cilindro(0.012, 0.012, 0.3, Vector3(lx * 0.5 + 0.3, 0.15, pz), "legno_vecchio", Vector3.ZERO, 6))
	c.add_child(scatola(Vector3(0.3, 0.02, 0.6), Vector3(lx * 0.5 + 0.17, 0.31, 0), "legno_scuro", Vector3(0, 0, -15)))
	legnaia(c, Vector3(lx * 0.5 + 0.17, 0.0, 0.0), 0.5, 5)
	# grande catasta di tronchi, ceppo con ascia, cavalletto, ceppaie
	catasta_tronchi(r, Vector3(0.55, 0, 0.55), 4, 0.5)
	r.add_child(cilindro(0.07, 0.075, 0.09, Vector3(-0.2, 0.045, 0.5), "corteccia", Vector3.ZERO, 12))
	r.add_child(cilindro(0.066, 0.066, 0.006, Vector3(-0.2, 0.092, 0.5), "legno_chiaro", Vector3.ZERO, 12))
	r.add_child(cilindro(0.008, 0.008, 0.22, Vector3(-0.2, 0.18, 0.5), "legno", Vector3(0, 0, 22), 6))
	r.add_child(scatola(Vector3(0.055, 0.04, 0.012), Vector3(-0.245, 0.27, 0.5), "ferro", Vector3(0, 0, 22)))
	for i in 6:
		r.add_child(cilindro(0.02, 0.02, 0.06, Vector3(-0.38 + i * 0.06, 0.02, 0.62 + (i % 2) * 0.05), "legno_chiaro", Vector3(0, i * 37, 90), 6))
	for pos in [Vector3(-0.72, 0, 0.3), Vector3(-0.6, 0, 0.75)]:
		r.add_child(cilindro(0.06, 0.07, 0.05, pos + Vector3(0, 0.025, 0), "corteccia", Vector3.ZERO, 10))
		r.add_child(cilindro(0.056, 0.056, 0.005, pos + Vector3(0, 0.052, 0), "legno_chiaro", Vector3.ZERO, 10))
	return r


static func segheria() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.25)
	r.add_child(c)
	var lx := 0.85
	var lz := 0.62
	var h := 0.44
	casa_muri(c, lx, lz, h, 11, "pietra_vista")
	porta_z(c, -0.22, lz * 0.5, 0.15, 0.26)
	finestra_z(c, 0.15, 0.38, lz * 0.5, 0.1, 0.11)
	finestra_x(c, 0.05, 0.38, lx * 0.5)
	sottotetto(c, lx, lz, 0.07 + h, 22.0, "pietra_vista")
	tetto(c, lx + 0.06, lz, 0.07 + h, 22.0, 11)
	# grande tettoia aperta con la sega a telaio
	var t := Node3D.new()
	t.position = Vector3(0.05, 0, 0.5)
	r.add_child(t)
	for p in [Vector3(-0.42, 0, -0.18), Vector3(0.42, 0, -0.18), Vector3(-0.42, 0, 0.22), Vector3(0.42, 0, 0.22)]:
		t.add_child(cilindro(0.018, 0.018, 0.4, p + Vector3(0, 0.2, 0), "legno_vecchio", Vector3.ZERO, 6))
	t.add_child(scatola(Vector3(0.95, 0.025, 0.5), Vector3(0, 0.41, 0.02), "legno_scuro", Vector3(-10, 0, 0)))
	for k in 6:
		t.add_child(scatola(Vector3(0.95, 0.012, 0.05), Vector3(0, 0.425, -0.2 + k * 0.08), "tegola_b", Vector3(-10, 0, 0)))
	for px in [-0.25, 0.0, 0.25]:
		t.add_child(scatola(Vector3(0.03, 0.12, 0.12), Vector3(px, 0.06, 0.0), "legno"))
	t.add_child(cilindro(0.055, 0.055, 0.8, Vector3(0, 0.17, 0.0), "corteccia", Vector3(0, 0, 90), 9))
	t.add_child(cilindro(0.047, 0.047, 0.805, Vector3(0, 0.17, 0.0), "legno_chiaro", Vector3(0, 0, 90), 9))
	for z in [-0.08, 0.08]:
		t.add_child(scatola(Vector3(0.014, 0.3, 0.014), Vector3(0.1, 0.24, z), "legno"))
	t.add_child(scatola(Vector3(0.014, 0.014, 0.18), Vector3(0.1, 0.38, 0.0), "legno"))
	t.add_child(scatola(Vector3(0.006, 0.006, 0.17), Vector3(0.1, 0.2, 0.0), "ferro"))
	t.add_child(cilindro(0.2, 0.2, 0.004, Vector3(0.1, 0.002, 0.0), "legno_chiaro", Vector3.ZERO, 16))
	# pile di assi e tronchi in attesa
	pila_assi(r, Vector3(0.62, 0, -0.25), 8, 90)
	pila_assi(r, Vector3(0.62, 0, 0.12), 5, 90)
	catasta_tronchi(r, Vector3(-0.65, 0, 0.55), 3, 0.42)
	carretto(r, Vector3(0.35, 0, 0.85), -30, "tronchi")
	return r


static func frantoio() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.22)
	r.add_child(c)
	var lx := 0.82
	var lz := 0.62
	var h := 0.42
	casa_muri(c, lx, lz, h, 13)
	porta_z(c, 0.18, lz * 0.5, 0.15, 0.25)
	finestra_z(c, -0.18, 0.36, lz * 0.5, 0.1, 0.11, true)
	finestra_x(c, 0.0, 0.36, lx * 0.5)
	sottotetto(c, lx, lz, 0.07 + h, 20.0)
	tetto(c, lx + 0.06, lz, 0.07 + h, 20.0, 13)
	comignolo(c, Vector3(-0.22, 0.07 + h + 0.05, -0.1))
	# macina all'aperto: vasca, ruota di pietra, stanga
	var m := Vector3(-0.35, 0, 0.55)
	r.add_child(cilindro(0.26, 0.28, 0.1, m + Vector3(0, 0.05, 0), "pietra", Vector3.ZERO, 24))
	r.add_child(cilindro(0.21, 0.21, 0.01, m + Vector3(0, 0.101, 0), "foglie_ulivo", Vector3.ZERO, 24))
	r.add_child(cilindro(0.03, 0.03, 0.22, m + Vector3(0, 0.2, 0), "legno", Vector3.ZERO, 8))
	r.add_child(cilindro(0.12, 0.12, 0.08, m + Vector3(0.1, 0.22, 0), "blocco", Vector3(0, 0, 90), 18))
	r.add_child(scatola(Vector3(0.6, 0.03, 0.03), m + Vector3(0.2, 0.26, 0), "legno_vecchio"))
	# giare d'olio, ceste di olive, botti
	for i in 6:
		r.add_child(anfora(Vector3(0.25 + (i % 3) * 0.1, 0.0, 0.42 + (i / 3) * 0.11), 1.15))
	for i in 3:
		r.add_child(cilindro(0.06, 0.05, 0.06, Vector3(0.62, 0.03, -0.3 + i * 0.16), "paglia", Vector3.ZERO, 12))
		r.add_child(sfera(0.05, Vector3(0.62, 0.06, -0.3 + i * 0.16), "foglie_ulivo", Vector3(1, 0.4, 1)))
	r.add_child(barile(Vector3(0.62, 0.0, 0.25), 1.2))
	r.add_child(ulivo(31))
	r.get_child(r.get_child_count() - 1).position = Vector3(-0.7, 0, -0.45)
	r.get_child(r.get_child_count() - 1).scale = Vector3.ONE * 0.8
	return r


static func cava() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.35, 0, -0.3)
	r.add_child(c)
	casa_muri(c, 0.55, 0.48, 0.3, 17, "pietra_vista")
	porta_z(c, -0.08, 0.24, 0.11, 0.2)
	sottotetto(c, 0.55, 0.48, 0.37, 24.0, "pietra_vista")
	tetto(c, 0.6, 0.48, 0.37, 24.0, 17)
	# parete di roccia gradonata da cui si estraggono i blocchi
	var rng := _rng(17)
	for k in 9:
		var p := Vector3(0.35 + rng.randf_range(-0.2, 0.2), 0.0, -0.4 + rng.randf_range(-0.15, 0.2))
		var d := rng.randf_range(0.16, 0.3)
		r.add_child(scatola(Vector3(d, d * rng.randf_range(0.6, 1.4), d * 0.8), p + Vector3(0, d * 0.4, 0), "roccia_massi", Vector3(0, rng.randf() * 60, 0)))
	# blocchi squadrati pronti, impalcatura di travi, attrezzi
	for i in 4:
		for j in 2 - (i / 3):
			r.add_child(scatola(Vector3(0.13, 0.09, 0.09), Vector3(-0.1 + i * 0.15, 0.045 + j * 0.09, 0.45), "blocco", Vector3(0, i * 5 - 6, 0)))
	r.add_child(scatola(Vector3(0.012, 0.4, 0.012), Vector3(0.12, 0.2, -0.05), "legno"))
	r.add_child(scatola(Vector3(0.012, 0.4, 0.012), Vector3(0.12, 0.2, 0.15), "legno"))
	r.add_child(scatola(Vector3(0.012, 0.012, 0.25), Vector3(0.12, 0.4, 0.05), "legno"))
	r.add_child(cilindro(0.004, 0.004, 0.2, Vector3(0.12, 0.3, 0.05), "corda", Vector3.ZERO, 4))
	r.add_child(cilindro(0.008, 0.008, 0.22, Vector3(0.55, 0.11, 0.35), "legno", Vector3(0, 0, -25), 6))
	r.add_child(scatola(Vector3(0.11, 0.014, 0.014), Vector3(0.6, 0.21, 0.35), "ferro", Vector3(0, 0, -25)))
	carretto(r, Vector3(-0.45, 0, 0.6), 15)
	r.add_child(scatola(Vector3(0.1, 0.07, 0.07), Vector3(-0.45, 0.16, 0.6), "blocco"))
	return r


static func guardaboschi() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.3, 0, -0.3)
	r.add_child(c)
	c.add_child(scatola(Vector3(0.62, 0.05, 0.52), Vector3(0, 0.025, 0), "pietra"))
	c.add_child(scatola(Vector3(0.58, 0.32, 0.48), Vector3(0, 0.05 + 0.16, 0), "legno"))
	for k in 7:
		c.add_child(cilindro(0.022, 0.022, 0.66, Vector3(0, 0.07 + k * 0.045, 0.24), "corteccia", Vector3(0, 0, 90), 7))
	porta_z(c, 0.12, 0.26, 0.11, 0.2)
	finestra_z(c, -0.14, 0.28, 0.26, 0.09, 0.09)
	sottotetto(c, 0.58, 0.48, 0.37, 34.0, "legno")
	tetto_scandole(c, 0.64, 0.48, 0.37, 34.0)
	# vivaio di alberelli in file, recintato
	for i in 4:
		for j in 3:
			var p := Vector3(-0.1 + i * 0.16, 0, 0.3 + j * 0.15)
			r.add_child(scatola(Vector3(0.1, 0.012, 0.1), p + Vector3(0, 0.006, 0), "terra"))
			r.add_child(cilindro(0.006, 0.006, 0.06 + j * 0.02, p + Vector3(0, 0.03, 0), "corteccia", Vector3.ZERO, 5))
			r.add_child(cilindro(0.035 + j * 0.008, 0.0, 0.09 + j * 0.03, p + Vector3(0, 0.09 + j * 0.03, 0), "aghi", Vector3.ZERO, 7))
	recinto(r, Vector3(-0.2, 0, 0.75), Vector3(0.52, 0, 0.75))
	recinto(r, Vector3(0.52, 0, 0.2), Vector3(0.52, 0, 0.75))
	# annaffiatoio, pala, sacchi di semi
	r.add_child(cilindro(0.03, 0.03, 0.05, Vector3(0.35, 0.025, -0.2), "ferro", Vector3.ZERO, 8))
	r.add_child(cilindro(0.007, 0.007, 0.22, Vector3(0.2, 0.11, -0.3), "legno", Vector3(12, 0, -15), 5))
	r.add_child(sacco(Vector3(-0.55, 0, 0.3), 0.4))
	r.add_child(sacco(Vector3(-0.6, 0, 0.42), -0.2))
	r.add_child(pino_laricio(41))
	r.get_child(r.get_child_count() - 1).position = Vector3(0.55, 0, -0.55)
	r.get_child(r.get_child_count() - 1).scale = Vector3.ONE * 0.7
	return r


static func torre() -> Node3D:
	var r := Node3D.new()
	var lato := 0.55
	var h := 1.25
	r.add_child(scatola(Vector3(lato + 0.16, 0.08, lato + 0.16), Vector3(0, 0.04, 0), "pietra"))
	r.add_child(scatola(Vector3(lato + 0.06, 0.18, lato + 0.06), Vector3(0, 0.17, 0), "pietra_vista"))
	r.add_child(scatola(Vector3(lato, h, lato), Vector3(0, 0.08 + h * 0.5, 0), "pietra_vista"))
	for y in [0.45, 0.85]:
		r.add_child(scatola(Vector3(lato + 0.03, 0.03, lato + 0.03), Vector3(0, y, 0), "blocco"))
	for y in [0.62, 1.02]:
		r.add_child(scatola(Vector3(0.035, 0.11, 0.02), Vector3(0, y, lato * 0.5 + 0.005), "buio"))
		r.add_child(scatola(Vector3(0.02, 0.11, 0.035), Vector3(lato * 0.5 + 0.005, y, 0), "buio"))
	porta_z(r, -0.08, lato * 0.5 + 0.01, 0.14, 0.24)
	r.get_child(r.get_child_count() - 1).position.y += 0.06
	# ballatoio sporgente su mensole e merli
	var top := 0.08 + h
	for k in 5:
		var off := -lato * 0.5 + k * lato / 4
		r.add_child(scatola(Vector3(0.04, 0.06, 0.05), Vector3(off, top - 0.03, lato * 0.5 + 0.03), "blocco"))
		r.add_child(scatola(Vector3(0.05, 0.06, 0.04), Vector3(lato * 0.5 + 0.03, top - 0.03, off), "blocco"))
	r.add_child(scatola(Vector3(lato + 0.14, 0.05, lato + 0.14), Vector3(0, top + 0.025, 0), "blocco"))
	for k in 5:
		for lm in [-1, 1]:
			var off := -lato * 0.5 - 0.02 + k * (lato + 0.04) / 4
			r.add_child(scatola(Vector3(0.07, 0.09, 0.05), Vector3(off, top + 0.095, lm * (lato * 0.5 + 0.045)), "pietra_vista"))
			r.add_child(scatola(Vector3(0.05, 0.09, 0.07), Vector3(lm * (lato * 0.5 + 0.045), top + 0.095, off), "pietra_vista"))
	r.add_child(cilindro(0.012, 0.012, 0.5, Vector3(0, top + 0.3, 0), "legno", Vector3.ZERO, 6))
	r.add_child(scatola(Vector3(0.006, 0.16, 0.26), Vector3(0, top + 0.46, 0.13), "stoffa"))
	# scudi, lance e barili alla base
	r.add_child(barile(Vector3(lato * 0.5 + 0.15, 0.0, 0.2), 1.1))
	r.add_child(cassa(Vector3(lato * 0.5 + 0.17, 0.0, 0.0), 10))
	for k in 3:
		r.add_child(cilindro(0.005, 0.005, 0.32, Vector3(-0.22 + k * 0.04, 0.16, lato * 0.5 + 0.08), "legno", Vector3(-12, 0, 0), 5))
	return r


static func pozzo() -> Node3D:
	var r := Node3D.new()
	r.add_child(cilindro(0.2, 0.21, 0.18, Vector3(0, 0.09, 0), "pietra_vista", Vector3.ZERO, 18))
	r.add_child(cilindro(0.15, 0.15, 0.005, Vector3(0, 0.17, 0), "acqua_pozzo", Vector3.ZERO, 18))
	r.add_child(cilindro(0.215, 0.215, 0.03, Vector3(0, 0.19, 0), "blocco", Vector3.ZERO, 18))
	for lato in [-1, 1]:
		r.add_child(scatola(Vector3(0.035, 0.34, 0.035), Vector3(lato * 0.19, 0.34, 0), "legno_vecchio"))
	r.add_child(cilindro(0.025, 0.025, 0.42, Vector3(0, 0.43, 0), "legno", Vector3(0, 0, 90), 8))
	r.add_child(cilindro(0.004, 0.004, 0.18, Vector3(0.02, 0.33, 0), "corda", Vector3.ZERO, 4))
	r.add_child(cilindro(0.04, 0.034, 0.06, Vector3(0.02, 0.22, 0), "legno_scuro", Vector3.ZERO, 8))
	var t := Node3D.new()
	r.add_child(t)
	tetto(t, 0.46, 0.26, 0.5, 30.0, 23)
	r.add_child(anfora(Vector3(0.26, 0.0, 0.18), 1.1))
	r.add_child(scatola(Vector3(0.16, 0.05, 0.06), Vector3(-0.2, 0.025, 0.24), "legno_vecchio", Vector3(0, 30, 0)))
	r.scale = Vector3.ONE * 1.2
	return r



# =================================================================== MESTIERI (step 05)

## Lavoratore con l'attrezzo in mano destra: ascia (boscaiolo), piccone (cavapietre), pala (guardaboschi),
## falce (contadino), canna (pescatore).
static func lavoratore(attrezzo: String) -> Node3D:
	var r := portatore("")
	var corpo: Node3D = r.get_node("corpo")
	var bd: Node3D = corpo.get_node("braccio_d")
	var att := Node3D.new()
	att.name = "attrezzo"
	att.position = Vector3(0, -0.14, 0.0)
	bd.add_child(att)
	match attrezzo:
		"ascia":
			att.add_child(cilindro(0.009, 0.009, 0.24, Vector3(0, 0.0, 0.08), "legno", Vector3(90, 0, 0), 6))
			att.add_child(scatola(Vector3(0.012, 0.07, 0.05), Vector3(0, -0.02, 0.19), "ferro"))
		"piccone":
			att.add_child(cilindro(0.009, 0.009, 0.24, Vector3(0, 0.0, 0.08), "legno", Vector3(90, 0, 0), 6))
			att.add_child(scatola(Vector3(0.014, 0.16, 0.022), Vector3(0, 0.0, 0.2), "ferro"))
		"pala":
			att.add_child(cilindro(0.008, 0.008, 0.26, Vector3(0, 0.0, 0.09), "legno", Vector3(90, 0, 0), 6))
			att.add_child(scatola(Vector3(0.06, 0.008, 0.07), Vector3(0, 0.0, 0.24), "ferro"))
		"falce":
			# falcetto: manico corto e lama a mezzaluna
			att.add_child(cilindro(0.009, 0.009, 0.1, Vector3(0, 0.0, 0.03), "legno", Vector3(90, 0, 0), 6))
			for k in 5:
				var a := k * 0.35
				att.add_child(scatola(Vector3(0.008, 0.02, 0.04), Vector3(0, 0.05 * sin(a), 0.09 + 0.05 * (1.0 - cos(a)) + k * 0.012), "ferro", Vector3(rad_to_deg(a), 0, 0)))
		"canna":
			att.add_child(cilindro(0.006, 0.003, 0.5, Vector3(0, 0.08, 0.2), "legno_chiaro", Vector3(70, 0, 0), 5))
			att.add_child(cilindro(0.002, 0.002, 0.2, Vector3(0, 0.22, 0.45), "corda", Vector3.ZERO, 3))
	# berretto di lana per riconoscere i mestieri
	corpo.add_child(sfera(0.07, Vector3(0, 0.2 + 0.31, -0.005), {"ascia": "giocatore", "piccone": "terra", "pala": "orto", "falce": "paglia", "canna": "persiana"}[attrezzo], Vector3(1, 0.55, 1)))
	r.set_meta("carico", "attrezzo")
	return r


## Gesto di lavoro: braccio che si alza e cala (ascia e piccone colpiscono in avanti, la pala scava).
static func posa_lavoro(modello: Node3D, fotogramma: int, totale: int) -> void:
	var t := float(fotogramma) / totale
	var corpo: Node3D = modello.get_node("corpo")
	var bd: Node3D = corpo.get_node("braccio_d")
	var bs: Node3D = corpo.get_node("braccio_s")
	# su fino a metà, poi giù veloce
	var alzata := sin(t * PI) if t < 0.65 else sin(0.65 * PI) * (1.0 - (t - 0.65) / 0.35)
	bd.rotation = Vector3(-0.3 - alzata * 2.4, 0, 0.15)
	bs.rotation = Vector3(-0.5 - alzata * 1.6, 0, -0.2)
	corpo.rotation.x = 0.15 - alzata * 0.25
	corpo.position.y = 0.0
	(corpo.get_node("gamba_s") as Node3D).rotation.x = 0.2
	(corpo.get_node("gamba_d") as Node3D).rotation.x = -0.2


static func ceppo() -> Node3D:
	var r := Node3D.new()
	r.add_child(cilindro(0.06, 0.075, 0.06, Vector3(0, 0.03, 0), "corteccia", Vector3.ZERO, 10))
	r.add_child(cilindro(0.056, 0.056, 0.005, Vector3(0, 0.062, 0), "legno_chiaro", Vector3.ZERO, 10))
	for k in 5:
		r.add_child(cilindro(0.01, 0.01, 0.03, Vector3(0.09 * cos(k * 1.3), 0.01, 0.09 * sin(k * 1.3)), "legno_chiaro", Vector3(0, k * 50, 90), 4))
	return r


static func alberello(fase: int) -> Node3D:
	var r := Node3D.new()
	var s: float = [0.28, 0.48, 0.72][fase]
	var albero := pino_laricio(60 + fase)
	albero.scale = Vector3.ONE * s
	r.add_child(albero)
	if fase == 0:
		r.add_child(cilindro(0.004, 0.004, 0.14, Vector3(0.05, 0.07, 0.0), "legno", Vector3.ZERO, 4))
	return r


# =================================================================== CIBO (step 06)

## Covone di grano legato in mezzo (in piedi lungo Y).
static func covone(scala := 1.0) -> Node3D:
	var n := Node3D.new()
	n.scale = Vector3.ONE * scala
	n.add_child(cilindro(0.035, 0.05, 0.2, Vector3(0, 0.1, 0), "grano", Vector3.ZERO, 10))
	n.add_child(cilindro(0.05, 0.03, 0.06, Vector3(0, 0.23, 0), "grano", Vector3.ZERO, 10))
	n.add_child(cilindro(0.038, 0.038, 0.015, Vector3(0, 0.13, 0), "corda", Vector3.ZERO, 10))
	return n


## Cesta di vimini con pani, pesci, formaggi, olive, uva, ortaggi, cipolle o agrumi.
static func cesta(pos: Vector3, contenuto: String, scala := 1.0) -> Node3D:
	var n := Node3D.new()
	n.position = pos
	n.scale = Vector3.ONE * scala
	n.add_child(cilindro(0.08, 0.065, 0.06, Vector3(0, 0.03, 0), "paglia", Vector3.ZERO, 14))
	n.add_child(cilindro(0.083, 0.083, 0.012, Vector3(0, 0.062, 0), "legno_vecchio", Vector3.ZERO, 14))
	if contenuto == "pane":
		for k in 4:
			var a := k * TAU / 4 + 0.4
			n.add_child(sfera(0.035, Vector3(cos(a) * 0.035, 0.07, sin(a) * 0.035), "pane", Vector3(1, 0.6, 1)))
		n.add_child(sfera(0.033, Vector3(0, 0.09, 0), "pane", Vector3(1, 0.6, 1)))
	elif contenuto in ["olive", "uva", "ortaggi", "cipolle", "agrumi", "carbone"]:
		var mat: String = {"olive": "oliva", "uva": "uva", "ortaggi": "orto", "cipolle": "cipolla", "agrumi": "arancia", "carbone": "carbone"}[contenuto]
		var g: float = {"olive": 0.016, "uva": 0.02, "ortaggi": 0.03, "cipolle": 0.025, "agrumi": 0.026, "carbone": 0.025}[contenuto]
		for k in 9:
			var a := k * 2.4
			var rr := 0.02 + (k % 3) * 0.018
			var m2 := mat
			if contenuto == "agrumi" and k % 3 == 0:
				m2 = "bergamotto"
			if contenuto == "ortaggi" and k % 3 == 1:
				m2 = "geranio"
			n.add_child(sfera(g, Vector3(cos(a) * rr, 0.07 + (k % 2) * 0.012, sin(a) * rr), m2))
	elif contenuto == "formaggio":
		for k in 3:
			n.add_child(cilindro(0.033, 0.033, 0.03, Vector3((k - 1) * 0.03, 0.07 + (k % 2) * 0.02, 0), "formaggio", Vector3(0, 0, 10 * (k - 1)), 12))
	else:
		for k in 5:
			var pesce := sfera(0.022, Vector3(-0.04 + k * 0.02, 0.07 + (k % 2) * 0.01, (k % 3 - 1) * 0.025), "pesce", Vector3(3.0, 0.6, 0.8))
			pesce.rotation_degrees.y = k * 37
			n.add_child(pesce)
	return n


## Campo di grano su una casella: 0 seminato, 1 verde basso, 2 verde alto, 3 maturo e dorato.
static func campo(fase: int) -> Node3D:
	var r := Node3D.new()
	var rng := _rng(70 + fase)
	r.add_child(scatola(Vector3(0.92, 0.02, 0.92), Vector3(0, 0.01, 0), "terra"))
	for f in 7:
		r.add_child(scatola(Vector3(0.88, 0.018, 0.04), Vector3(0, 0.022, -0.39 + f * 0.13), "terra"))
	var alt: float = [0.025, 0.07, 0.16, 0.2][fase]
	var mat: String = "grano" if fase == 3 else "grano_verde"
	for f in 7:
		for k in 8:
			var p := Vector3(-0.39 + k * 0.11 + rng.randf_range(-0.02, 0.02), 0, -0.39 + f * 0.13 + rng.randf_range(-0.015, 0.015))
			var h := alt * rng.randf_range(0.8, 1.15)
			if fase == 0:
				r.add_child(sfera(0.012, p + Vector3(0, 0.03, 0), "orto", Vector3(1, 1.5, 1)))
			else:
				r.add_child(sfera(0.05, p + Vector3(0, h * 0.5 + 0.02, 0), mat, Vector3(1, h / 0.1, 1)))
				if fase == 3:
					r.add_child(sfera(0.02, p + Vector3(rng.randf_range(-0.01, 0.01), h + 0.03, 0), "grano", Vector3(0.8, 1.6, 0.8)))
	return r


static func stoppie() -> Node3D:
	var r := Node3D.new()
	var rng := _rng(80)
	r.add_child(scatola(Vector3(0.92, 0.02, 0.92), Vector3(0, 0.01, 0), "terra"))
	for k in 40:
		var p := Vector3(rng.randf_range(-0.42, 0.42), 0.03, rng.randf_range(-0.42, 0.42))
		r.add_child(cilindro(0.01, 0.008, 0.035, p, "paglia", Vector3.ZERO, 4))
	for p in [Vector3(-0.15, 0, 0.1), Vector3(0.18, 0, -0.12)]:
		var cv := covone(1.0)
		cv.position = p
		r.add_child(cv)
	return r


## Asino stilizzato (per la mola del mulino).
static func asino(pos: Vector3, rot := 0.0) -> Node3D:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot
	n.add_child(sfera(0.07, Vector3(0, 0.15, 0), "asino", Vector3(1.6, 0.9, 0.9)))
	for x in [-0.07, 0.07]:
		for z in [-0.035, 0.035]:
			n.add_child(cilindro(0.013, 0.011, 0.11, Vector3(x, 0.055, z), "asino", Vector3.ZERO, 6))
	n.add_child(cilindro(0.025, 0.03, 0.09, Vector3(0.12, 0.2, 0), "asino", Vector3(0, 0, -50), 8))
	n.add_child(sfera(0.035, Vector3(0.17, 0.22, 0), "asino", Vector3(1.4, 0.9, 0.9)))
	for z in [-0.015, 0.015]:
		n.add_child(cilindro(0.008, 0.004, 0.07, Vector3(0.15, 0.28, z), "asino", Vector3(z * 600, 0, 15), 5))
	n.add_child(cilindro(0.006, 0.003, 0.08, Vector3(-0.12, 0.12, 0), "capelli", Vector3(0, 0, 30), 4))
	return n


static func fattoria() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.18, 0, -0.22)
	r.add_child(c)
	var lx := 0.78
	var lz := 0.58
	var h := 0.38
	casa_muri(c, lx, lz, h, 41)
	porta_z(c, -0.12, lz * 0.5, 0.13, 0.23)
	finestra_z(c, 0.2, 0.34, lz * 0.5, 0.1, 0.1, true)
	finestra_x(c, 0.0, 0.34, lx * 0.5)
	sottotetto(c, lx, lz, 0.07 + h, 24.0)
	tetto(c, lx + 0.06, lz, 0.07 + h, 24.0, 41)
	comignolo(c, Vector3(0.22, 0.07 + h + 0.06, -0.08))
	# fienile aperto con tetto di paglia sul lato destro
	for p in [Vector3(0.62, 0, -0.45), Vector3(0.62, 0, 0.05), Vector3(0.95, 0, -0.45), Vector3(0.95, 0, 0.05)]:
		r.add_child(cilindro(0.016, 0.016, 0.34, p + Vector3(0, 0.17, 0), "legno_vecchio", Vector3.ZERO, 6))
	r.add_child(scatola(Vector3(0.42, 0.05, 0.6), Vector3(0.785, 0.36, -0.2), "paglia", Vector3(0, 0, -10)))
	for i in 5:
		var cv := covone(1.1)
		cv.position = Vector3(0.68 + (i % 3) * 0.1, 0.0, -0.35 + (i / 3) * 0.14)
		r.add_child(cv)
	# aia con covoni, carretto di sacchi, orto e galline
	for i in 4:
		var cv := covone(1.2)
		cv.position = Vector3(-0.55 + i * 0.13, 0.0, 0.55 + (i % 2) * 0.08)
		cv.rotation_degrees.z = 8 * (i % 2 * 2 - 1)
		r.add_child(cv)
	carretto(r, Vector3(0.4, 0, 0.55), -20, "sacchi")
	orto(r, Vector3(-0.72, 0, -0.05), 0.24, 0.5, 42)
	for i in 3:
		r.add_child(sfera(0.025, Vector3(0.05 + i * 0.07, 0.03, 0.42 - i * 0.03), "intonaco", Vector3(1.3, 1, 1)))
		r.add_child(sfera(0.008, Vector3(0.08 + i * 0.07, 0.05, 0.42 - i * 0.03), "geranio"))
	return r


static func mulino() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.25)
	r.add_child(c)
	var lx := 0.74
	var lz := 0.56
	var h := 0.46
	casa_muri(c, lx, lz, h, 51, "intonaco_sporco")
	porta_z(c, 0.15, lz * 0.5, 0.14, 0.25)
	finestra_z(c, -0.17, 0.4, lz * 0.5, 0.09, 0.1)
	finestra_x(c, 0.0, 0.4, lx * 0.5)
	sottotetto(c, lx, lz, 0.07 + h, 22.0)
	tetto(c, lx + 0.06, lz, 0.07 + h, 22.0, 51)
	# mola a clessidra sotto una tettoia, girata dall'asino
	var m := Vector3(-0.3, 0, 0.5)
	r.add_child(cilindro(0.2, 0.22, 0.06, m + Vector3(0, 0.03, 0), "pietra", Vector3.ZERO, 20))
	r.add_child(cilindro(0.06, 0.14, 0.16, m + Vector3(0, 0.14, 0), "blocco", Vector3.ZERO, 16))
	r.add_child(cilindro(0.14, 0.06, 0.16, m + Vector3(0, 0.3, 0), "blocco", Vector3.ZERO, 16))
	r.add_child(scatola(Vector3(0.5, 0.025, 0.025), m + Vector3(0.16, 0.25, 0), "legno_vecchio"))
	r.add_child(sfera(0.12, m + Vector3(0, 0.07, 0), "lino", Vector3(1.6, 0.2, 1.6)))
	r.add_child(asino(m + Vector3(0.38, 0, 0.0), 90))
	for p in [m + Vector3(-0.25, 0, -0.22), m + Vector3(-0.25, 0, 0.25), m + Vector3(0.25, 0, 0.25)]:
		r.add_child(cilindro(0.015, 0.015, 0.42, p + Vector3(0, 0.21, 0), "legno_vecchio", Vector3.ZERO, 6))
	r.add_child(scatola(Vector3(0.56, 0.03, 0.52), m + Vector3(0, 0.43, 0), "tegola_scura", Vector3(0, 0, 8)))
	# sacchi di farina e di grano
	for i in 5:
		r.add_child(sacco(Vector3(0.45 + (i % 3) * 0.12, 0.0, -0.1 + (i / 3) * 0.13), i * 0.7))
	var cv := covone(1.1)
	cv.position = Vector3(0.55, 0, 0.45)
	r.add_child(cv)
	r.add_child(cassa(Vector3(0.3, 0, 0.6), 15))
	return r


static func forno() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.25)
	r.add_child(c)
	var lx := 0.74
	var lz := 0.56
	var h := 0.4
	casa_muri(c, lx, lz, h, 61)
	porta_z(c, -0.15, lz * 0.5, 0.13, 0.24)
	finestra_z(c, 0.18, 0.36, lz * 0.5, 0.11, 0.1, true)
	finestra_x(c, 0.0, 0.36, lx * 0.5)
	sottotetto(c, lx, lz, 0.07 + h, 22.0)
	tetto(c, lx + 0.06, lz, 0.07 + h, 22.0, 61)
	comignolo(c, Vector3(-0.2, 0.07 + h + 0.05, -0.08))
	# grande forno a cupola davanti, con bocca annerita e canna fumaria
	var f := Vector3(0.45, 0, 0.42)
	r.add_child(cilindro(0.26, 0.27, 0.12, f + Vector3(0, 0.06, 0), "pietra", Vector3.ZERO, 22))
	r.add_child(sfera(0.24, f + Vector3(0, 0.12, 0), "intonaco_sporco", Vector3(1, 0.85, 1)))
	r.add_child(scatola(Vector3(0.1, 0.09, 0.06), f + Vector3(-0.06, 0.18, 0.21), "fuliggine", Vector3(0, 30, 0)))
	r.add_child(scatola(Vector3(0.11, 0.1, 0.03), f + Vector3(-0.065, 0.18, 0.235), "buio", Vector3(0, 30, 0)))
	r.add_child(cilindro(0.035, 0.035, 0.14, f + Vector3(0.08, 0.36, -0.08), "terracotta", Vector3.ZERO, 8))
	legnaia(r, Vector3(0.62, 0, -0.1), 0.25, 3)
	# tavolo con pani, ceste, sacchi di farina, anfore d'acqua
	r.add_child(scatola(Vector3(0.3, 0.02, 0.14), Vector3(-0.3, 0.12, 0.55), "legno"))
	for lato in [-1, 1]:
		r.add_child(scatola(Vector3(0.02, 0.11, 0.1), Vector3(-0.3 + lato * 0.12, 0.055, 0.55), "legno_vecchio"))
	for i in 5:
		r.add_child(sfera(0.03, Vector3(-0.42 + i * 0.06, 0.145, 0.55 + (i % 2) * 0.03), "pane", Vector3(1, 0.6, 1)))
	r.add_child(cesta(Vector3(-0.62, 0, 0.45), "pane"))
	r.add_child(cesta(Vector3(0.05, 0, 0.62), "pane"))
	r.add_child(sacco(Vector3(-0.68, 0, 0.15), 0.4))
	r.add_child(anfora(Vector3(0.18, 0, 0.42), 1.1))
	r.add_child(anfora(Vector3(0.25, 0, 0.5), 1.0))
	return r


static func capanna_pescatore() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.22, 0, -0.25)
	r.add_child(c)
	var lx := 0.66
	var lz := 0.5
	var h := 0.32
	c.add_child(scatola(Vector3(lx + 0.06, 0.06, lz + 0.06), Vector3(0, 0.03, 0), "pietra"))
	c.add_child(scatola(Vector3(lx, h, lz), Vector3(0, 0.06 + h * 0.5, 0), "legno_vecchio"))
	for k in 7:
		c.add_child(scatola(Vector3(lx + 0.01, 0.008, 0.01), Vector3(0, 0.1 + k * 0.04, lz * 0.5 + 0.004), "legno_scuro"))
	porta_z(c, 0.12, lz * 0.5 + 0.01, 0.12, 0.21)
	finestra_z(c, -0.16, 0.28, lz * 0.5 + 0.01, 0.08, 0.08)
	sottotetto(c, lx, lz, 0.06 + h, 30.0, "legno")
	tetto_scandole(c, lx + 0.08, lz, 0.06 + h, 30.0)
	# reti stese ad asciugare su pali
	for x in [0.35, 0.75]:
		r.add_child(cilindro(0.012, 0.012, 0.36, Vector3(x, 0.18, -0.35), "legno_vecchio", Vector3.ZERO, 6))
	r.add_child(scatola(Vector3(0.4, 0.26, 0.006), Vector3(0.55, 0.2, -0.35), "rete"))
	for k in 6:
		r.add_child(scatola(Vector3(0.004, 0.26, 0.008), Vector3(0.37 + k * 0.07, 0.2, -0.345), "corda"))
	for k in 4:
		r.add_child(scatola(Vector3(0.4, 0.004, 0.008), Vector3(0.55, 0.1 + k * 0.065, -0.345), "corda"))
	# barca tirata a secco, remi, ceste di pesce, galleggianti
	var b := Node3D.new()
	b.position = Vector3(0.35, 0, 0.45)
	b.rotation_degrees.y = -25
	r.add_child(b)
	b.add_child(sfera(0.13, Vector3(0, 0.07, 0), "legno", Vector3(2.6, 0.7, 1.0)))
	b.add_child(sfera(0.115, Vector3(0, 0.1, 0), "legno_scuro", Vector3(2.5, 0.35, 0.9)))
	b.add_child(scatola(Vector3(0.66, 0.02, 0.03), Vector3(0, 0.13, 0.12), "persiana"))
	b.add_child(scatola(Vector3(0.66, 0.02, 0.03), Vector3(0, 0.13, -0.12), "persiana"))
	for z in [-0.05, 0.06]:
		b.add_child(scatola(Vector3(0.5, 0.01, 0.025), Vector3(0.05, 0.16, z), "legno_chiaro", Vector3(0, 8, 4)))
	r.add_child(cesta(Vector3(-0.45, 0, 0.45), "pesce"))
	r.add_child(cesta(Vector3(-0.3, 0, 0.58), "pesce"))
	r.add_child(barile(Vector3(-0.62, 0, 0.25)))
	for i in 3:
		r.add_child(sfera(0.02, Vector3(0.62 + i * 0.05, 0.02, 0.1 + i * 0.03), "bandiera_rossa"))
	return r


## Gesto del pescatore: canna tesa in avanti che oscilla piano.
static func posa_pesca(modello: Node3D, fotogramma: int, totale: int) -> void:
	var t := float(fotogramma) / totale * TAU
	var corpo: Node3D = modello.get_node("corpo")
	var bd: Node3D = corpo.get_node("braccio_d")
	var bs: Node3D = corpo.get_node("braccio_s")
	bd.rotation = Vector3(-1.1 - 0.12 * sin(t), 0, 0.1)
	bs.rotation = Vector3(-0.9 - 0.08 * sin(t), 0, -0.3)
	corpo.rotation.x = 0.05
	corpo.position.y = 0.0
	(corpo.get_node("gamba_s") as Node3D).rotation.x = 0.15
	(corpo.get_node("gamba_d") as Node3D).rotation.x = -0.15


# =================================================================== ALLEVAMENTI (step 06)

## Quadrupede generico: corpo, zampe, collo e testa. Serve per maiali, pecore e capre.
static func quadrupede(pos: Vector3, rot: float, mat: String, scala: float, mat_testa := "", corna := false) -> Node3D:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot
	n.scale = Vector3.ONE * scala
	var testa := mat if mat_testa == "" else mat_testa
	n.add_child(sfera(0.07, Vector3(0, 0.12, 0), mat, Vector3(1.5, 0.95, 0.95)))
	for x in [-0.065, 0.065]:
		for z in [-0.033, 0.033]:
			n.add_child(cilindro(0.012, 0.01, 0.08, Vector3(x, 0.04, z), testa, Vector3.ZERO, 6))
	n.add_child(sfera(0.038, Vector3(0.12, 0.15, 0), testa, Vector3(1.3, 0.95, 0.9)))
	if corna:
		for z in [-0.015, 0.015]:
			n.add_child(cilindro(0.006, 0.002, 0.05, Vector3(0.11, 0.2, z), "legno_scuro", Vector3(0, 0, 35), 4))
	return n


static func maiale(pos: Vector3, rot := 0.0) -> Node3D:
	var n := quadrupede(pos, rot, "maiale", 0.9)
	n.add_child(cilindro(0.018, 0.02, 0.02, Vector3(0.17, 0.145, 0), "maiale", Vector3(0, 0, 90), 8))
	for z in [-0.02, 0.02]:
		n.add_child(sfera(0.014, Vector3(0.12, 0.185, z), "maiale", Vector3(1, 0.6, 1)))
	return n


static func pecora(pos: Vector3, rot := 0.0) -> Node3D:
	var n := quadrupede(pos, rot, "lana", 0.95, "pelle_scura")
	for k in 4:
		n.add_child(sfera(0.04, Vector3(-0.05 + k * 0.035, 0.17, (k % 2) * 0.02 - 0.01), "lana"))
	return n


static func capra(pos: Vector3, rot := 0.0) -> Node3D:
	var n := quadrupede(pos, rot, "capra", 0.85, "", true)
	n.add_child(cilindro(0.006, 0.003, 0.03, Vector3(0.14, 0.11, 0), "capra", Vector3.ZERO, 4))
	return n


static func porcile() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.3, 0, -0.3)
	r.add_child(c)
	var lx := 0.6
	var lz := 0.46
	var h := 0.3
	casa_muri(c, lx, lz, h, 71, "intonaco_sporco")
	porta_z(c, -0.1, lz * 0.5, 0.12, 0.2)
	finestra_x(c, 0.0, 0.28, lx * 0.5, 0.08, 0.08)
	sottotetto(c, lx, lz, 0.07 + h, 22.0)
	tetto(c, lx + 0.06, lz, 0.07 + h, 22.0, 71)
	# recinto con fango, mangiatoia e maiali
	var a := Vector3(0.05, 0, 0.0)
	r.add_child(scatola(Vector3(0.8, 0.012, 0.75), a + Vector3(0.12, 0.006, 0.12), "terra"))
	recinto(r, a + Vector3(-0.28, 0, 0.5), a + Vector3(0.52, 0, 0.5))
	recinto(r, a + Vector3(0.52, 0, -0.26), a + Vector3(0.52, 0, 0.5))
	recinto(r, a + Vector3(0.15, 0, -0.26), a + Vector3(0.52, 0, -0.26))
	r.add_child(sfera(0.14, a + Vector3(0.28, 0.0, 0.05), "fuliggine", Vector3(1.4, 0.1, 1.0)))
	r.add_child(scatola(Vector3(0.24, 0.05, 0.07), a + Vector3(0.0, 0.025, 0.4), "legno_vecchio"))
	r.add_child(scatola(Vector3(0.2, 0.012, 0.05), a + Vector3(0.0, 0.05, 0.4), "grano"))
	for p in [[Vector3(0.25, 0, 0.3), 20], [Vector3(0.38, 0, -0.05), 130], [Vector3(0.05, 0, 0.18), -60], [Vector3(0.4, 0, 0.32), 200]]:
		r.add_child(maiale(a + p[0], p[1]))
	r.add_child(sacco(Vector3(-0.62, 0, 0.2), 0.3))
	r.add_child(anfora(Vector3(-0.5, 0, 0.3), 1.0))
	return r


static func ovile() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.32, 0, -0.32)
	r.add_child(c)
	var lx := 0.62
	var lz := 0.48
	var h := 0.3
	casa_muri(c, lx, lz, h, 81, "pietra_vista")
	porta_z(c, 0.1, lz * 0.5, 0.14, 0.2)
	sottotetto(c, lx, lz, 0.07 + h, 28.0, "legno")
	tetto_scandole(c, lx + 0.06, lz, 0.07 + h, 28.0)
	# stazzo in pietra a secco con le pecore
	var a := Vector3(0.1, 0, 0.1)
	for k in 9:
		r.add_child(scatola(Vector3(0.1, 0.07, 0.06), a + Vector3(-0.32 + k * 0.095, 0.035, 0.45), "pietra", Vector3(0, (k % 3) * 7, 0)))
	for k in 7:
		r.add_child(scatola(Vector3(0.06, 0.07, 0.1), a + Vector3(0.48, 0.035, -0.2 + k * 0.095), "pietra", Vector3(0, (k % 3) * 7, 0)))
	for p in [[Vector3(0.0, 0, 0.25), 30], [Vector3(0.2, 0, 0.05), 160], [Vector3(0.3, 0, 0.3), -40],
			[Vector3(-0.15, 0, 0.32), 90], [Vector3(0.32, 0, -0.12), 210]]:
		r.add_child(pecora(a + p[0], p[1]))
	r.add_child(scatola(Vector3(0.22, 0.04, 0.06), a + Vector3(-0.2, 0.02, 0.05), "legno_vecchio"))
	r.add_child(cilindro(0.09, 0.08, 0.06, Vector3(-0.68, 0.03, 0.3), "legno", Vector3.ZERO, 14))
	r.add_child(cilindro(0.08, 0.08, 0.005, Vector3(-0.68, 0.06, 0.3), "acqua_pozzo", Vector3.ZERO, 14))
	r.add_child(sfera(0.06, Vector3(-0.55, 0.04, 0.55), "lana", Vector3(1.2, 0.6, 1.0)))
	return r


static func capraio() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.3, 0, -0.3)
	r.add_child(c)
	var lx := 0.56
	var lz := 0.44
	var h := 0.28
	c.add_child(scatola(Vector3(lx + 0.06, 0.06, lz + 0.06), Vector3(0, 0.03, 0), "pietra"))
	c.add_child(scatola(Vector3(lx, h, lz), Vector3(0, 0.06 + h * 0.5, 0), "pietra_vista"))
	porta_z(c, -0.08, lz * 0.5, 0.12, 0.19)
	sottotetto(c, lx, lz, 0.06 + h, 30.0, "legno")
	tetto_scandole(c, lx + 0.06, lz, 0.06 + h, 30.0)
	# rocce su cui le capre si arrampicano
	var a := Vector3(0.15, 0, 0.15)
	r.add_child(sfera(0.16, a + Vector3(0.2, 0.0, -0.1), "roccia_massi", Vector3(1.2, 0.8, 1.0)))
	r.add_child(sfera(0.1, a + Vector3(-0.05, 0.0, 0.3), "roccia_massi", Vector3(1.3, 0.7, 1.0)))
	r.add_child(capra(a + Vector3(0.2, 0.1, -0.1), 40))
	r.add_child(capra(a + Vector3(0.0, 0, 0.1), 200))
	r.add_child(capra(a + Vector3(0.35, 0, 0.25), -30))
	r.add_child(capra(a + Vector3(-0.1, 0.05, 0.3), 110))
	recinto(r, a + Vector3(-0.4, 0, 0.5), a + Vector3(0.5, 0, 0.5))
	r.add_child(anfora(Vector3(-0.6, 0, 0.25), 1.1))
	r.add_child(cesta(Vector3(-0.55, 0, 0.45), "formaggio"))
	return r


static func apiario() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.35, 0, -0.35)
	r.add_child(c)
	var lx := 0.5
	var lz := 0.4
	var h := 0.26
	casa_muri(c, lx, lz, h, 91)
	porta_z(c, 0.06, lz * 0.5, 0.11, 0.18)
	sottotetto(c, lx, lz, 0.07 + h, 25.0)
	tetto(c, lx + 0.06, lz, 0.07 + h, 25.0, 91)
	# file di arnie di paglia (bugni) su un'asse, fiori tutto intorno
	for f in 2:
		r.add_child(scatola(Vector3(0.75, 0.02, 0.1), Vector3(0.15, 0.06, 0.15 + f * 0.25), "legno_vecchio"))
		for k in 5:
			var p := Vector3(-0.15 + k * 0.15, 0.07, 0.15 + f * 0.25)
			r.add_child(cilindro(0.045, 0.05, 0.05, p + Vector3(0, 0.025, 0), "paglia", Vector3.ZERO, 12))
			r.add_child(sfera(0.045, p + Vector3(0, 0.05, 0), "paglia", Vector3(1, 0.9, 1)))
			r.add_child(scatola(Vector3(0.015, 0.012, 0.01), p + Vector3(0, 0.02, 0.048), "buio"))
	var rng := _rng(92)
	for k in 30:
		var p := Vector3(rng.randf_range(-0.7, 0.7), 0.0, rng.randf_range(0.55, 0.75))
		if k % 2 == 0:
			p = Vector3(rng.randf_range(0.5, 0.75), 0.0, rng.randf_range(-0.6, 0.6))
		r.add_child(sfera(0.018, p + Vector3(0, 0.02, 0), "orto"))
		r.add_child(sfera(0.012, p + Vector3(0, 0.04, 0), ["geranio", "fiore", "miele"][k % 3]))
	r.add_child(anfora(Vector3(-0.62, 0, 0.2), 0.9))
	r.add_child(anfora(Vector3(-0.55, 0, 0.3), 0.8))
	return r


static func macelleria() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.25)
	r.add_child(c)
	var lx := 0.74
	var lz := 0.56
	var h := 0.4
	casa_muri(c, lx, lz, h, 101)
	porta_z(c, 0.16, lz * 0.5, 0.13, 0.24)
	finestra_z(c, -0.17, 0.35, lz * 0.5, 0.1, 0.1)
	finestra_x(c, 0.0, 0.35, lx * 0.5)
	sottotetto(c, lx, lz, 0.07 + h, 22.0)
	tetto(c, lx + 0.06, lz, 0.07 + h, 22.0, 101)
	comignolo(c, Vector3(0.2, 0.07 + h + 0.05, -0.1))
	# tettoia con prosciutti e salami appesi, banco, ceppo
	for x in [0.2, 0.7]:
		r.add_child(cilindro(0.014, 0.014, 0.36, Vector3(x, 0.18, 0.5), "legno_vecchio", Vector3.ZERO, 6))
	r.add_child(scatola(Vector3(0.6, 0.02, 0.02), Vector3(0.45, 0.34, 0.5), "legno"))
	r.add_child(scatola(Vector3(0.62, 0.025, 0.3), Vector3(0.45, 0.38, 0.42), "tegola_scura", Vector3(-12, 0, 0)))
	for k in 5:
		var x := 0.25 + k * 0.1
		r.add_child(cilindro(0.003, 0.003, 0.05, Vector3(x, 0.31, 0.5), "corda", Vector3.ZERO, 3))
		if k % 2 == 0:
			r.add_child(sfera(0.035, Vector3(x, 0.25, 0.5), "carne", Vector3(0.9, 1.4, 0.8)))
		else:
			r.add_child(cilindro(0.016, 0.016, 0.1, Vector3(x, 0.24, 0.5), "carne", Vector3.ZERO, 8))
	r.add_child(scatola(Vector3(0.3, 0.02, 0.14), Vector3(-0.35, 0.12, 0.55), "legno"))
	for lato in [-1, 1]:
		r.add_child(scatola(Vector3(0.02, 0.11, 0.1), Vector3(-0.35 + lato * 0.12, 0.055, 0.55), "legno_vecchio"))
	r.add_child(sfera(0.04, Vector3(-0.4, 0.15, 0.55), "carne", Vector3(1.2, 0.5, 0.9)))
	r.add_child(cilindro(0.07, 0.075, 0.1, Vector3(-0.65, 0.05, 0.4), "corteccia", Vector3.ZERO, 12))
	r.add_child(barile(Vector3(0.65, 0, 0.0), 1.1))
	r.add_child(maiale(Vector3(-0.6, 0, 0.0), 60))
	return r


static func caseificio() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.25)
	r.add_child(c)
	var lx := 0.74
	var lz := 0.56
	var h := 0.4
	casa_muri(c, lx, lz, h, 111)
	porta_z(c, -0.15, lz * 0.5, 0.13, 0.24)
	finestra_z(c, 0.18, 0.35, lz * 0.5, 0.1, 0.1, true)
	finestra_x(c, 0.0, 0.35, lx * 0.5)
	sottotetto(c, lx, lz, 0.07 + h, 22.0)
	tetto(c, lx + 0.06, lz, 0.07 + h, 22.0, 111)
	comignolo(c, Vector3(-0.2, 0.07 + h + 0.05, -0.1))
	# paiolo sul fuoco, scaffale di forme di formaggio, secchi di latte
	var f := Vector3(0.45, 0, 0.45)
	for k in 6:
		r.add_child(scatola(Vector3(0.07, 0.05, 0.05), f + Vector3(0.12 * cos(k), 0.025, 0.12 * sin(k)), "pietra", Vector3(0, k * 50, 0)))
	r.add_child(sfera(0.1, f + Vector3(0, 0.12, 0), "ferro", Vector3(1, 0.8, 1)))
	r.add_child(cilindro(0.085, 0.085, 0.01, f + Vector3(0, 0.17, 0), "latte", Vector3.ZERO, 14))
	for lato in [-1, 1]:
		r.add_child(cilindro(0.01, 0.01, 0.3, f + Vector3(lato * 0.15, 0.15, 0), "legno_vecchio", Vector3.ZERO, 5))
	r.add_child(cilindro(0.008, 0.008, 0.32, f + Vector3(0, 0.3, 0), "legno_vecchio", Vector3(0, 0, 90), 5))
	for p in [Vector3(-0.3, 0, 0.5), Vector3(0.7, 0, -0.05)]:
		for liv in 3:
			r.add_child(scatola(Vector3(0.28 if p.x < 0 else 0.08, 0.012, 0.08 if p.x < 0 else 0.28), p + Vector3(0, 0.05 + liv * 0.08, 0), "legno"))
			for k in 3:
				var o := Vector3((k - 1) * 0.085, 0, 0) if p.x < 0 else Vector3(0, 0, (k - 1) * 0.085)
				r.add_child(cilindro(0.035, 0.035, 0.04, p + o + Vector3(0, 0.078 + liv * 0.08, 0), "formaggio", Vector3.ZERO, 12))
	r.add_child(anfora(Vector3(0.1, 0, 0.62), 1.0))
	r.add_child(anfora(Vector3(0.2, 0, 0.6), 1.1))
	return r


# =================================================================== COLTURE E PESCA AL LARGO (step 06)

## Filare di viti su una casella: 0 piantine, 1 tralci, 2 foglie fitte, 3 grappoli maturi.
static func vite(fase: int) -> Node3D:
	var r := Node3D.new()
	var rng := _rng(120 + fase)
	r.add_child(scatola(Vector3(0.92, 0.02, 0.92), Vector3(0, 0.01, 0), "terra"))
	for f in 3:
		var z := -0.3 + f * 0.3
		if fase > 0:
			for x in [-0.4, 0.0, 0.4]:
				r.add_child(cilindro(0.008, 0.008, 0.2, Vector3(x, 0.1, z), "legno_vecchio", Vector3.ZERO, 5))
			r.add_child(cilindro(0.002, 0.002, 0.8, Vector3(0, 0.17, z), "corda", Vector3(0, 0, 90), 3))
		for k in 5:
			var p := Vector3(-0.36 + k * 0.18, 0, z)
			r.add_child(cilindro(0.01, 0.014, 0.06 + fase * 0.03, p + Vector3(0, 0.03 + fase * 0.015, 0), "corteccia", Vector3.ZERO, 5))
			if fase == 0:
				r.add_child(sfera(0.02, p + Vector3(0, 0.07, 0), "orto"))
				continue
			var n := 2 + fase * 2
			for i in n:
				var o := Vector3(rng.randf_range(-0.08, 0.08), 0.1 + rng.randf_range(0, 0.08), rng.randf_range(-0.04, 0.04))
				r.add_child(sfera(0.03, p + o, "foglie_chiare" if i % 2 == 0 else "foglie", Vector3(1, 0.7, 1)))
			if fase == 3:
				for i in 2:
					r.add_child(sfera(0.022, p + Vector3(-0.03 + i * 0.06, 0.1, 0.03), "uva", Vector3(1, 1.4, 1)))
	return r


## Orto su una casella: 0 seminato, 1 piantine, 2 cespi, 3 maturo (cavoli, cipolle rosse, peperoni).
static func orto_campo(fase: int) -> Node3D:
	var r := Node3D.new()
	var rng := _rng(130 + fase)
	r.add_child(scatola(Vector3(0.92, 0.02, 0.92), Vector3(0, 0.01, 0), "terra"))
	for f in 5:
		r.add_child(scatola(Vector3(0.84, 0.03, 0.1), Vector3(0, 0.025, -0.34 + f * 0.17), "terra"))
	for f in 5:
		for k in 6:
			var p := Vector3(-0.35 + k * 0.14 + rng.randf_range(-0.01, 0.01), 0.04, -0.34 + f * 0.17)
			match fase:
				0:
					r.add_child(sfera(0.008, p, "orto"))
				1:
					r.add_child(sfera(0.02, p + Vector3(0, 0.01, 0), "orto", Vector3(1, 0.8, 1)))
				_:
					var g := 0.035 if fase == 2 else 0.045
					if f % 2 == 0:
						r.add_child(sfera(g, p + Vector3(0, g * 0.6, 0), "orto" if f == 0 else "foglie_chiare", Vector3(1, 0.8, 1)))
					else:
						if fase == 3:
							r.add_child(sfera(0.026, p + Vector3(0, 0.02, 0), "cipolla", Vector3(1, 0.9, 1)))
						for i in 3:
							r.add_child(cilindro(0.004, 0.002, 0.08, p + Vector3((i - 1) * 0.01, 0.06, 0), "orto", Vector3(0, 0, (i - 1) * 15), 3))
					if fase == 3 and f == 4 and k % 2 == 0:
						r.add_child(sfera(0.018, p + Vector3(0.02, 0.05, 0.02), "geranio", Vector3(0.8, 1.4, 0.8)))
	return r


## Alberello di agrumi: 0 piantina, 1 giovane, 2 chioma, 3 carico di frutti.
static func agrumi(fase: int) -> Node3D:
	var r := Node3D.new()
	var rng := _rng(140)
	r.add_child(scatola(Vector3(0.92, 0.02, 0.92), Vector3(0, 0.01, 0), "terra"))
	var s: float = [0.3, 0.55, 0.85, 0.85][fase]
	for p in [Vector3(-0.2, 0, -0.2), Vector3(0.22, 0, 0.18)]:
		var a := Node3D.new()
		a.position = p
		a.scale = Vector3.ONE * s
		r.add_child(a)
		a.add_child(cilindro(0.02, 0.028, 0.22, Vector3(0, 0.11, 0), "corteccia", Vector3.ZERO, 6))
		chioma(a, Vector3(0, 0.3, 0), Vector3(0.16, 0.13, 0.16), 26, 141 + int(p.x * 10), "foglie_scure", "foglie", "foglie_chiare")
		if fase == 3:
			for k in 14:
				var d := Vector3(rng.randf_range(-1, 1), rng.randf_range(-0.6, 0.8), rng.randf_range(-1, 1)).normalized()
				a.add_child(sfera(0.025, Vector3(0, 0.3, 0) + d * Vector3(0.16, 0.13, 0.16), "arancia" if k % 4 else "bergamotto"))
	return r


static func uliveto() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.3, 0, -0.3)
	r.add_child(c)
	var lx := 0.58
	var lz := 0.46
	var h := 0.3
	casa_muri(c, lx, lz, h, 151)
	porta_z(c, -0.08, lz * 0.5, 0.12, 0.21)
	finestra_x(c, 0.0, 0.3, lx * 0.5, 0.08, 0.08)
	sottotetto(c, lx, lz, 0.07 + h, 24.0)
	tetto(c, lx + 0.06, lz, 0.07 + h, 24.0, 151)
	# teli stesi sotto un ulivo, ceste di olive, scala a pioli
	var u := ulivo(152)
	u.position = Vector3(0.35, 0, 0.3)
	u.scale = Vector3.ONE * 0.8
	r.add_child(u)
	r.add_child(scatola(Vector3(0.5, 0.004, 0.45), Vector3(0.35, 0.004, 0.3), "lino", Vector3(0, 12, 0)))
	for k in 12:
		r.add_child(sfera(0.012, Vector3(0.2 + (k % 4) * 0.08, 0.012, 0.18 + (k / 4) * 0.1), "oliva"))
	for p in [Vector3(-0.45, 0, 0.45), Vector3(-0.25, 0, 0.55), Vector3(0.7, 0, -0.2)]:
		r.add_child(cesta(p, "olive"))
	r.add_child(scatola(Vector3(0.03, 0.45, 0.012), Vector3(0.12, 0.22, 0.12), "legno_vecchio", Vector3(0, 0, -18)))
	r.add_child(scatola(Vector3(0.03, 0.45, 0.012), Vector3(0.12, 0.22, 0.2), "legno_vecchio", Vector3(0, 0, -18)))
	return r


static func vigneto() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.25, 0, -0.3)
	r.add_child(c)
	var lx := 0.66
	var lz := 0.5
	var h := 0.34
	casa_muri(c, lx, lz, h, 161)
	porta_z(c, 0.1, lz * 0.5, 0.13, 0.22)
	finestra_z(c, -0.18, 0.32, lz * 0.5, 0.09, 0.09, true)
	sottotetto(c, lx, lz, 0.07 + h, 24.0)
	tetto(c, lx + 0.06, lz, 0.07 + h, 24.0, 161)
	# pergolato d'uva davanti alla porta, tino, ceste di grappoli
	for p in [Vector3(-0.35, 0, 0.15), Vector3(0.25, 0, 0.15), Vector3(-0.35, 0, 0.55), Vector3(0.25, 0, 0.55)]:
		r.add_child(cilindro(0.012, 0.012, 0.36, p + Vector3(0, 0.18, 0), "legno_vecchio", Vector3.ZERO, 6))
	var rng := _rng(162)
	for k in 26:
		r.add_child(sfera(0.045, Vector3(rng.randf_range(-0.38, 0.28), 0.37, rng.randf_range(0.12, 0.58)), "foglie" if k % 3 else "foglie_chiare", Vector3(1, 0.5, 1)))
	for k in 6:
		r.add_child(sfera(0.022, Vector3(-0.3 + k * 0.1, 0.32, 0.35 + (k % 2) * 0.1), "uva", Vector3(1, 1.5, 1)))
	r.add_child(cilindro(0.1, 0.09, 0.12, Vector3(0.55, 0.06, 0.4), "legno", Vector3.ZERO, 14))
	r.add_child(cilindro(0.09, 0.09, 0.005, Vector3(0.55, 0.12, 0.4), "uva", Vector3.ZERO, 14))
	r.add_child(cesta(Vector3(0.6, 0, 0.0), "uva"))
	r.add_child(cesta(Vector3(0.45, 0, -0.2), "uva"))
	return r


static func cantina() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.25)
	r.add_child(c)
	var lx := 0.76
	var lz := 0.56
	var h := 0.38
	casa_muri(c, lx, lz, h, 171, "pietra_vista")
	porta_z(c, 0.15, lz * 0.5, 0.16, 0.24)
	finestra_z(c, -0.2, 0.34, lz * 0.5, 0.08, 0.08)
	sottotetto(c, lx, lz, 0.07 + h, 20.0)
	tetto(c, lx + 0.06, lz, 0.07 + h, 20.0, 171)
	# botti in fila, anfore di vino, palmento (vasca per pigiare)
	for k in 3:
		var b := barile(Vector3(0.62, 0, -0.3 + k * 0.2), 1.5)
		b.rotation_degrees.x = 90
		b.position.y = 0.07
		r.add_child(b)
	for k in 5:
		r.add_child(anfora(Vector3(-0.6 + (k % 3) * 0.1, 0, 0.42 + (k / 3) * 0.12), 1.15))
	r.add_child(scatola(Vector3(0.36, 0.1, 0.28), Vector3(0.2, 0.05, 0.55), "pietra"))
	r.add_child(scatola(Vector3(0.3, 0.01, 0.22), Vector3(0.2, 0.1, 0.55), "vino"))
	r.add_child(cesta(Vector3(-0.15, 0, 0.6), "uva"))
	return r


static func ortolano() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.3, 0, -0.3)
	r.add_child(c)
	var lx := 0.58
	var lz := 0.46
	var h := 0.3
	casa_muri(c, lx, lz, h, 181)
	porta_z(c, 0.08, lz * 0.5, 0.12, 0.21)
	finestra_z(c, -0.16, 0.3, lz * 0.5, 0.08, 0.08, true)
	sottotetto(c, lx, lz, 0.07 + h, 24.0)
	tetto(c, lx + 0.06, lz, 0.07 + h, 24.0, 181)
	# trecce di cipolle rosse appese, cassette di verdura, orticello
	orto(r, Vector3(0.45, 0, 0.0), 0.36, 0.6, 182)
	for k in 4:
		for i in 4:
			r.add_child(sfera(0.02, Vector3(-0.5 + k * 0.08, 0.3 - i * 0.04, 0.0), "cipolla"))
	for p in [Vector3(-0.4, 0, 0.45), Vector3(-0.2, 0, 0.55)]:
		r.add_child(cesta(p, "ortaggi"))
	r.add_child(cesta(Vector3(0.05, 0, 0.6), "cipolle"))
	return r


static func agrumeto() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.3, 0, -0.3)
	r.add_child(c)
	var lx := 0.6
	var lz := 0.46
	var h := 0.32
	casa_muri(c, lx, lz, h, 191)
	porta_z(c, -0.1, lz * 0.5, 0.12, 0.22)
	finestra_z(c, 0.15, 0.3, lz * 0.5, 0.08, 0.08, true)
	sottotetto(c, lx, lz, 0.07 + h, 24.0)
	tetto(c, lx + 0.06, lz, 0.07 + h, 24.0, 191)
	var a := agrumi(3)
	var terra := a.get_child(0)
	a.remove_child(terra)
	terra.free()
	a.position = Vector3(0.3, 0, 0.25)
	a.scale = Vector3.ONE * 1.1
	r.add_child(a)
	for p in [Vector3(-0.45, 0, 0.45), Vector3(-0.25, 0, 0.58), Vector3(0.7, 0, -0.25)]:
		r.add_child(cesta(p, "agrumi"))
	r.add_child(cassa(Vector3(0.65, 0, 0.1), 20))
	return r


static func pesca_spada() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.3, 0, -0.3)
	r.add_child(c)
	var lx := 0.6
	var lz := 0.46
	var h := 0.32
	casa_muri(c, lx, lz, h, 201)
	porta_z(c, 0.1, lz * 0.5, 0.12, 0.22)
	finestra_x(c, 0.0, 0.3, lx * 0.5, 0.08, 0.08)
	sottotetto(c, lx, lz, 0.07 + h, 24.0)
	tetto(c, lx + 0.06, lz, 0.07 + h, 24.0, 201)
	# la feluca: barca con l'albero di vedetta e la passerella dell'arpioniere
	var b := Node3D.new()
	b.position = Vector3(0.3, 0, 0.35)
	b.rotation_degrees.y = -30
	r.add_child(b)
	b.add_child(sfera(0.15, Vector3(0, 0.07, 0), "legno", Vector3(2.8, 0.7, 1.0)))
	b.add_child(sfera(0.13, Vector3(0, 0.1, 0), "legno_scuro", Vector3(2.7, 0.35, 0.9)))
	b.add_child(scatola(Vector3(0.8, 0.02, 0.03), Vector3(0, 0.14, 0.13), "persiana"))
	b.add_child(scatola(Vector3(0.8, 0.02, 0.03), Vector3(0, 0.14, -0.13), "persiana"))
	b.add_child(cilindro(0.01, 0.008, 0.6, Vector3(0.0, 0.42, 0), "legno_vecchio", Vector3.ZERO, 6))
	for k in 5:
		b.add_child(scatola(Vector3(0.08, 0.006, 0.01), Vector3(0.0, 0.2 + k * 0.08, 0.0), "legno_vecchio"))
	b.add_child(scatola(Vector3(0.45, 0.012, 0.02), Vector3(0.55, 0.13, 0), "legno_chiaro"))
	r.add_child(scatola(Vector3(0.02, 0.012, 0.5), Vector3(-0.6, 0.15, 0.4), "ferro", Vector3(0, 0, 4)))
	var sp := pesce_spada_modello()
	sp.position = Vector3(-0.35, 0.02, 0.55)
	r.add_child(sp)
	return r


static func pesce_spada_modello() -> Node3D:
	var n := Node3D.new()
	n.add_child(sfera(0.05, Vector3(0, 0.04, 0), "spada", Vector3(3.2, 0.8, 0.7)))
	n.add_child(cilindro(0.008, 0.002, 0.2, Vector3(0.25, 0.045, 0), "spada", Vector3(0, 0, 90), 5))
	n.add_child(scatola(Vector3(0.05, 0.06, 0.01), Vector3(0.0, 0.09, 0), "spada", Vector3(0, 0, 30)))
	for lato in [-1, 1]:
		n.add_child(scatola(Vector3(0.05, 0.01, 0.05), Vector3(-0.17, 0.04 + lato * 0.03, 0), "spada", Vector3(0, 0, lato * 40)))
	return n


## Barca a remi con il pescatore (vista in 8 direzioni): la prua è verso +Z come il viso dei portatori.
static func barca_remi() -> Node3D:
	var r := Node3D.new()
	var b := Node3D.new()
	b.name = "scafo"
	r.add_child(b)
	b.add_child(sfera(0.13, Vector3(0, 0.02, 0), "legno", Vector3(0.9, 0.55, 2.4)))
	b.add_child(sfera(0.115, Vector3(0, 0.05, 0), "legno_scuro", Vector3(0.85, 0.3, 2.3)))
	b.add_child(scatola(Vector3(0.03, 0.02, 0.6), Vector3(0.11, 0.07, 0), "persiana"))
	b.add_child(scatola(Vector3(0.03, 0.02, 0.6), Vector3(-0.11, 0.07, 0), "persiana"))
	var uomo := portatore("")
	uomo.scale = Vector3.ONE * 0.8
	uomo.position = Vector3(0, -0.13, -0.04)
	b.add_child(uomo)
	for lato in [-1, 1]:
		var remo := Node3D.new()
		remo.name = "remo_s" if lato < 0 else "remo_d"
		remo.position = Vector3(lato * 0.1, 0.1, 0.0)
		b.add_child(remo)
		remo.add_child(cilindro(0.006, 0.006, 0.32, Vector3(lato * 0.15, -0.03, 0), "legno_chiaro", Vector3(0, 0, lato * 75), 4))
		remo.add_child(scatola(Vector3(0.08, 0.005, 0.035), Vector3(lato * 0.3, -0.07, 0), "legno_chiaro", Vector3(0, 0, lato * 15)))
	r.set_meta("carico", "barca")
	return r


## Remata: i remi girano avanti e indietro, la barca beccheggia appena.
static func posa_remata(modello: Node3D, fotogramma: int, totale: int) -> void:
	var t := float(fotogramma) / totale * TAU
	var b: Node3D = modello.get_node("scafo")
	b.rotation.x = 0.04 * sin(t)
	for nome in ["remo_s", "remo_d"]:
		var remo: Node3D = b.get_node(nome)
		remo.rotation.y = (0.5 * sin(t)) * (1 if nome == "remo_d" else -1)
		remo.rotation.z = 0.15 * cos(t) * (1 if nome == "remo_d" else -1)


# =================================================================== METALLO (step 07)

## Attrezzo da solo (per le merci a terra e il fascio del portatore).
static func attrezzo(tipo: String) -> Node3D:
	var n := Node3D.new()
	n.add_child(cilindro(0.008, 0.008, 0.22, Vector3(0, 0.01, 0), "legno", Vector3(0, 0, 90), 6))
	match tipo:
		"ascia":
			n.add_child(scatola(Vector3(0.05, 0.012, 0.06), Vector3(0.11, 0.012, 0.02), "ferro"))
		"piccone":
			n.add_child(scatola(Vector3(0.02, 0.014, 0.16), Vector3(0.11, 0.012, 0), "ferro"))
		"pala":
			n.add_child(scatola(Vector3(0.07, 0.008, 0.06), Vector3(0.14, 0.008, 0), "ferro"))
		"falce":
			for k in 4:
				n.add_child(scatola(Vector3(0.03, 0.008, 0.012), Vector3(0.11 + 0.012 * k, 0.01, 0.015 + 0.02 * k - 0.003 * k * k), "ferro", Vector3(0, -k * 25, 0)))
		"canna":
			n.add_child(cilindro(0.004, 0.002, 0.2, Vector3(0.2, 0.01, 0), "legno_chiaro", Vector3(0, 0, 90), 4))
		"sega":
			n.add_child(scatola(Vector3(0.18, 0.004, 0.04), Vector3(0.06, 0.012, 0.025), "ferro"))
		"martello":
			n.add_child(scatola(Vector3(0.03, 0.03, 0.06), Vector3(0.11, 0.015, 0), "ferro"))
	return n


static func mucchio(pos: Vector3, mat: String, pezzi: int, seme: int, dim := 0.035) -> Node3D:
	var n := Node3D.new()
	n.position = pos
	var rng := _rng(seme)
	for k in pezzi:
		var a := k * 2.4
		var rr := 0.012 * k
		n.add_child(sfera(dim * rng.randf_range(0.7, 1.2), Vector3(cos(a) * rr, dim * 0.6 + (pezzi - k) * 0.004, sin(a) * rr), mat,
			Vector3(1, rng.randf_range(0.6, 0.9), 1)))
	return n


static func miniera_ferro(minerale := "minerale") -> Node3D:
	var r := Node3D.new()
	# fianco della montagna con l'imbocco puntellato
	r.add_child(sfera(0.6, Vector3(-0.25, 0.0, -0.3), "roccia_massi", Vector3(1.2, 0.75, 1.0)))
	r.add_child(sfera(0.35, Vector3(0.35, 0.0, -0.45), "roccia_massi", Vector3(1.1, 0.8, 1.0)))
	r.add_child(sfera(0.3, Vector3(-0.65, 0.0, 0.15), "roccia_massi", Vector3(1.0, 0.7, 1.0)))
	var imb := Vector3(-0.05, 0, 0.18)
	r.add_child(scatola(Vector3(0.22, 0.26, 0.1), imb + Vector3(0, 0.13, 0), "buio"))
	for lato in [-1, 1]:
		r.add_child(scatola(Vector3(0.04, 0.3, 0.04), imb + Vector3(lato * 0.13, 0.15, 0.05), "legno_vecchio"))
	r.add_child(scatola(Vector3(0.34, 0.045, 0.05), imb + Vector3(0, 0.31, 0.05), "legno_vecchio"))
	r.add_child(scatola(Vector3(0.12, 0.03, 0.01), imb + Vector3(0, 0.36, 0.08), "legno_chiaro"))
	# binari e carrello di minerale
	for lato in [-1, 1]:
		r.add_child(scatola(Vector3(0.012, 0.01, 0.55), imb + Vector3(lato * 0.05, 0.005, 0.3), "ferro"))
	for k in 6:
		r.add_child(scatola(Vector3(0.14, 0.008, 0.02), imb + Vector3(0, 0.004, 0.08 + k * 0.09), "legno_scuro"))
	var carr := Vector3(-0.05, 0, 0.5)
	r.add_child(scatola(Vector3(0.14, 0.08, 0.18), carr + Vector3(0, 0.07, 0), "legno"))
	r.add_child(mucchio(carr + Vector3(0, 0.1, 0), minerale, 6, 3, 0.03))
	for x in [-0.075, 0.075]:
		for z in [-0.06, 0.06]:
			r.add_child(cilindro(0.022, 0.022, 0.012, carr + Vector3(x, 0.025, z), "ferro", Vector3(0, 0, 90), 8))
	# mucchio di minerale, lanterna, puntelli di scorta
	r.add_child(mucchio(Vector3(0.45, 0, 0.35), minerale, 14, 4))
	r.add_child(cilindro(0.01, 0.01, 0.3, Vector3(0.22, 0.15, 0.3), "legno_vecchio", Vector3.ZERO, 5))
	r.add_child(sfera(0.025, Vector3(0.22, 0.31, 0.3), "miele"))
	for k in 4:
		r.add_child(cilindro(0.018, 0.018, 0.4, Vector3(-0.55 + k * 0.045, 0.02 + (k % 2) * 0.03, 0.55), "legno_vecchio", Vector3(0, 70, 90), 6))
	return r


static func carbonaia() -> Node3D:
	var r := Node3D.new()
	# capanno del carbonaio
	var c := Node3D.new()
	c.position = Vector3(-0.38, 0, -0.35)
	r.add_child(c)
	c.add_child(scatola(Vector3(0.44, 0.05, 0.36), Vector3(0, 0.025, 0), "pietra"))
	c.add_child(scatola(Vector3(0.4, 0.24, 0.32), Vector3(0, 0.17, 0), "legno_vecchio"))
	porta_z(c, 0.05, 0.16, 0.1, 0.17)
	sottotetto(c, 0.4, 0.32, 0.29, 32.0, "legno")
	tetto_scandole(c, 0.46, 0.32, 0.29, 32.0)
	# la carbonaia: cupola di legna coperta di terra, che fuma
	var m := Vector3(0.22, 0, 0.2)
	r.add_child(sfera(0.36, m, "terra", Vector3(1, 0.7, 1)))
	r.add_child(sfera(0.3, m + Vector3(0, 0.03, 0), "fuliggine", Vector3(1, 0.7, 1)))
	r.add_child(sfera(0.37, m + Vector3(0, -0.01, 0), "terra", Vector3(1, 0.68, 1)))
	for k in 5:
		r.add_child(sfera(0.05 + k * 0.012, m + Vector3(0.02 * k, 0.28 + k * 0.07, -0.01 * k), "fumo", Vector3(1, 0.8, 1)))
	r.add_child(scatola(Vector3(0.06, 0.04, 0.04), m + Vector3(0.0, 0.12, 0.33), "buio"))
	# legna da cuocere e carbone pronto
	legnaia(r, Vector3(-0.55, 0, 0.35), 0.35, 4)
	r.add_child(mucchio(Vector3(0.62, 0, -0.25), "carbone", 12, 5))
	r.add_child(sacco(Vector3(0.6, 0, 0.55), 0.4))
	return r


static func fonderia() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.25, 0, -0.25)
	r.add_child(c)
	var lx := 0.66
	var lz := 0.52
	var h := 0.36
	casa_muri(c, lx, lz, h, 211, "pietra_vista")
	porta_z(c, -0.12, lz * 0.5, 0.14, 0.24)
	sottotetto(c, lx, lz, 0.07 + h, 20.0)
	tetto(c, lx + 0.06, lz, 0.07 + h, 20.0, 211)
	# forno a torre in pietra con la bocca accesa e mantici
	var f := Vector3(0.42, 0, 0.38)
	r.add_child(cilindro(0.17, 0.2, 0.5, f + Vector3(0, 0.25, 0), "pietra", Vector3.ZERO, 16))
	r.add_child(cilindro(0.13, 0.15, 0.08, f + Vector3(0, 0.54, 0), "fuliggine", Vector3.ZERO, 16))
	r.add_child(scatola(Vector3(0.1, 0.1, 0.05), f + Vector3(-0.05, 0.12, 0.17), "brace", Vector3(0, 25, 0)))
	for k in 4:
		r.add_child(sfera(0.05 + k * 0.012, f + Vector3(0.0, 0.66 + k * 0.08, -0.01 * k), "fumo"))
	r.add_child(sfera(0.07, f + Vector3(-0.28, 0.1, 0.05), "pelle_scura", Vector3(1.4, 0.5, 1.0)))
	# lingotti, carbone e minerale in attesa
	for k in 6:
		r.add_child(scatola(Vector3(0.09, 0.025, 0.035), Vector3(-0.45 + (k % 3) * 0.1, 0.013 + (k / 3) * 0.026, 0.55), "lingotto"))
	r.add_child(mucchio(Vector3(-0.62, 0, 0.25), "carbone", 9, 6))
	r.add_child(mucchio(Vector3(0.68, 0, -0.1), "minerale", 9, 7))
	return r


static func fabbro() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.28)
	r.add_child(c)
	var lx := 0.72
	var lz := 0.5
	var h := 0.38
	casa_muri(c, lx, lz, h, 221)
	porta_z(c, 0.16, lz * 0.5, 0.13, 0.24)
	finestra_z(c, -0.18, 0.34, lz * 0.5, 0.1, 0.1)
	sottotetto(c, lx, lz, 0.07 + h, 22.0)
	tetto(c, lx + 0.06, lz, 0.07 + h, 22.0, 221)
	comignolo(c, Vector3(-0.22, 0.07 + h + 0.05, -0.05), 0.2)
	# fucina all'aperto sotto una tettoia: focolare, incudine, attrezzi appesi
	for p in [Vector3(-0.5, 0, 0.6), Vector3(0.1, 0, 0.6)]:
		r.add_child(cilindro(0.014, 0.014, 0.34, p + Vector3(0, 0.17, 0), "legno_vecchio", Vector3.ZERO, 6))
	r.add_child(scatola(Vector3(0.68, 0.025, 0.36), Vector3(-0.2, 0.35, 0.46), "tegola_scura", Vector3(-14, 0, 0)))
	r.add_child(scatola(Vector3(0.2, 0.12, 0.16), Vector3(-0.38, 0.06, 0.42), "pietra"))
	r.add_child(scatola(Vector3(0.14, 0.01, 0.1), Vector3(-0.38, 0.125, 0.42), "brace"))
	r.add_child(cilindro(0.04, 0.05, 0.08, Vector3(-0.05, 0.04, 0.45), "corteccia", Vector3.ZERO, 10))
	r.add_child(scatola(Vector3(0.12, 0.04, 0.05), Vector3(-0.05, 0.1, 0.45), "ferro"))
	r.add_child(scatola(Vector3(0.04, 0.025, 0.035), Vector3(0.03, 0.1, 0.45), "ferro"))
	for k in 4:
		var a := attrezzo(ATTREZZI_FABBRO[k])
		a.position = Vector3(-0.42 + k * 0.1, 0.25, 0.235)
		a.rotation_degrees = Vector3(90, 0, 90)
		r.add_child(a)
	r.add_child(barile(Vector3(0.62, 0, 0.1), 1.0))
	r.add_child(cilindro(0.04, 0.04, 0.005, Vector3(0.62, 0.1, 0.1), "acqua_pozzo", Vector3.ZERO, 10))
	for k in 3:
		r.add_child(scatola(Vector3(0.09, 0.025, 0.035), Vector3(0.45, 0.013 + k * 0.026, 0.45), "lingotto"))
	return r


const ATTREZZI_FABBRO := ["ascia", "piccone", "falce", "martello"]


# =================================================================== GRECI COMPLETI (step 11)

static func argillaio() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.32, 0, -0.32)
	r.add_child(c)
	c.add_child(scatola(Vector3(0.5, 0.05, 0.4), Vector3(0, 0.025, 0), "pietra"))
	c.add_child(scatola(Vector3(0.46, 0.26, 0.36), Vector3(0, 0.18, 0), "argilla_cruda"))
	porta_z(c, 0.06, 0.18, 0.11, 0.18)
	sottotetto(c, 0.46, 0.36, 0.31, 28.0, "legno")
	tetto_scandole(c, 0.52, 0.36, 0.31, 28.0)
	# fossa d'argilla, mattoni crudi che seccano, pala, acqua
	r.add_child(sfera(0.3, Vector3(0.3, -0.02, 0.25), "argilla", Vector3(1.3, 0.12, 1.0)))
	r.add_child(sfera(0.22, Vector3(0.3, 0.0, 0.25), "argilla_cruda", Vector3(1.3, 0.08, 1.0)))
	for k in 12:
		r.add_child(scatola(Vector3(0.07, 0.03, 0.04), Vector3(-0.55 + (k % 4) * 0.09, 0.015 + (k / 4) * 0.032, 0.45), "argilla", Vector3(0, (k % 2) * 5, 0)))
	var a := attrezzo("pala")
	a.position = Vector3(0.62, 0.02, 0.05)
	a.rotation_degrees = Vector3(0, 40, 10)
	r.add_child(a)
	r.add_child(barile(Vector3(-0.1, 0, 0.6), 1.0))
	r.add_child(cilindro(0.04, 0.04, 0.005, Vector3(-0.1, 0.1, 0.6), "acqua_pozzo", Vector3.ZERO, 10))
	return r


static func fornace() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.25, 0, -0.3)
	r.add_child(c)
	var lx := 0.6
	var lz := 0.46
	var h := 0.32
	casa_muri(c, lx, lz, h, 231)
	porta_z(c, 0.12, lz * 0.5, 0.12, 0.22)
	sottotetto(c, lx, lz, 0.07 + h, 22.0)
	tetto(c, lx + 0.06, lz, 0.07 + h, 22.0, 231)
	# fornace a cupola con la bocca accesa, anfore dipinte in fila ad asciugare
	var f := Vector3(0.42, 0, 0.35)
	r.add_child(cilindro(0.2, 0.22, 0.14, f + Vector3(0, 0.07, 0), "argilla", Vector3.ZERO, 18))
	r.add_child(sfera(0.2, f + Vector3(0, 0.14, 0), "argilla", Vector3(1, 1.0, 1)))
	r.add_child(scatola(Vector3(0.08, 0.07, 0.05), f + Vector3(-0.05, 0.1, 0.19), "brace", Vector3(0, 25, 0)))
	for k in 3:
		r.add_child(sfera(0.04 + k * 0.012, f + Vector3(0.0, 0.4 + k * 0.08, 0.0), "fumo"))
	for k in 7:
		var an := anfora(Vector3(-0.6 + (k % 4) * 0.1, 0, 0.42 + (k / 4) * 0.12), 1.2)
		r.add_child(an)
		r.add_child(cilindro(0.047, 0.047, 0.015, Vector3(-0.6 + (k % 4) * 0.1, 0.075 * 1.2, 0.42 + (k / 4) * 0.12), "fuliggine", Vector3.ZERO, 10))
	r.add_child(mucchio(Vector3(0.68, 0, -0.15), "argilla", 8, 9))
	legnaia(r, Vector3(0.65, 0, 0.12), 0.2, 3)
	return r


static func saline() -> Node3D:
	var r := Node3D.new()
	# vasche basse di evaporazione, cumuli di sale, capanno del salinaro
	for i in 3:
		for j in 2:
			var p := Vector3(-0.45 + i * 0.42, 0, -0.25 + j * 0.5)
			r.add_child(scatola(Vector3(0.4, 0.04, 0.46), p + Vector3(0, 0.02, 0), "argilla_cruda"))
			var mat := "acqua_pozzo" if (i + j) % 3 != 0 else "sale"
			r.add_child(scatola(Vector3(0.34, 0.005, 0.4), p + Vector3(0, 0.042, 0), mat))
	for p in [Vector3(0.62, 0, 0.55), Vector3(0.42, 0, 0.62), Vector3(-0.6, 0, 0.6)]:
		r.add_child(sfera(0.1, p, "sale", Vector3(1, 0.9, 1)))
	var c := Node3D.new()
	c.position = Vector3(0.6, 0, -0.55)
	r.add_child(c)
	c.add_child(scatola(Vector3(0.28, 0.2, 0.24), Vector3(0, 0.1, 0), "legno_vecchio"))
	tetto_scandole(c, 0.32, 0.24, 0.2, 30.0)
	var a := attrezzo("pala")
	a.position = Vector3(0.25, 0.02, 0.45)
	a.rotation_degrees = Vector3(0, -30, 5)
	r.add_child(a)
	r.add_child(sacco(Vector3(0.0, 0, 0.62), 0.3))
	return r


static func zecca() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.25)
	r.add_child(c)
	var lx := 0.74
	var lz := 0.56
	var h := 0.42
	casa_muri(c, lx, lz, h, 241, "marmo")
	porta_z(c, 0.0, lz * 0.5, 0.15, 0.26)
	for x in [-0.25, 0.25]:
		c.add_child(cilindro(0.03, 0.026, h, Vector3(x, 0.07 + h * 0.5, lz * 0.5 + 0.06), "marmo", Vector3.ZERO, 12))
	c.add_child(scatola(Vector3(lx, 0.04, 0.14), Vector3(0, 0.07 + h + 0.02, lz * 0.5 + 0.03), "marmo"))
	sottotetto(c, lx, lz, 0.07 + h, 18.0, "marmo")
	tetto(c, lx + 0.06, lz, 0.07 + h, 18.0, 241)
	comignolo(c, Vector3(0.24, 0.07 + h + 0.04, -0.12), 0.16)
	# casse di monete, incudine per coniare, guardia
	for k in 3:
		r.add_child(cassa(Vector3(0.45 + k * 0.12, 0, 0.4), k * 15, 0.1))
		r.add_child(cilindro(0.035, 0.035, 0.01, Vector3(0.45 + k * 0.12, 0.085, 0.4), "moneta", Vector3.ZERO, 10))
	r.add_child(cilindro(0.04, 0.05, 0.08, Vector3(-0.35, 0.04, 0.5), "corteccia", Vector3.ZERO, 10))
	r.add_child(scatola(Vector3(0.1, 0.035, 0.05), Vector3(-0.35, 0.095, 0.5), "ferro"))
	r.add_child(mucchio(Vector3(-0.62, 0, 0.25), "argento_grezzo", 8, 10))
	var g := portatore("")
	g.position = Vector3(0.15, 0, 0.5)
	g.scale = Vector3.ONE * 0.9
	r.add_child(g)
	g.add_child(cilindro(0.006, 0.006, 0.5, Vector3(0.09, 0.25, 0.0), "legno", Vector3.ZERO, 5))
	g.add_child(scatola(Vector3(0.012, 0.06, 0.03), Vector3(0.09, 0.51, 0.0), "ferro"))
	return r


static func tessitura() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.28)
	r.add_child(c)
	var lx := 0.72
	var lz := 0.52
	var h := 0.36
	casa_muri(c, lx, lz, h, 251)
	porta_z(c, -0.16, lz * 0.5, 0.13, 0.23)
	finestra_z(c, 0.18, 0.32, lz * 0.5, 0.11, 0.1, true)
	sottotetto(c, lx, lz, 0.07 + h, 22.0)
	tetto(c, lx + 0.06, lz, 0.07 + h, 22.0, 251)
	# telaio verticale con la tela a righe, matasse, stoffe stese
	var t := Vector3(0.0, 0, 0.5)
	for x in [-0.18, 0.18]:
		r.add_child(cilindro(0.012, 0.012, 0.4, t + Vector3(x, 0.2, 0), "legno_vecchio", Vector3.ZERO, 6))
	r.add_child(cilindro(0.012, 0.012, 0.4, t + Vector3(0, 0.39, 0), "legno", Vector3(0, 0, 90), 6))
	for k in 6:
		r.add_child(scatola(Vector3(0.34, 0.04, 0.006), t + Vector3(0, 0.34 - k * 0.04, 0), "stoffa_rossa" if k % 2 == 0 else "lana"))
	for k in 5:
		r.add_child(sfera(0.014, t + Vector3(-0.14 + k * 0.07, 0.08, 0), "argilla"))
	for p in [Vector3(0.55, 0, 0.0), Vector3(0.6, 0, 0.2)]:
		r.add_child(sfera(0.05, p + Vector3(0, 0.04, 0), "lana", Vector3(1.2, 0.8, 1)))
	r.add_child(cilindro(0.008, 0.008, 0.5, Vector3(0.55, 0.3, -0.35), "legno_vecchio", Vector3(0, 0, 90), 5))
	r.add_child(scatola(Vector3(0.22, 0.2, 0.004), Vector3(0.48, 0.2, -0.35), "stoffa"))
	r.add_child(scatola(Vector3(0.2, 0.18, 0.004), Vector3(0.7, 0.21, -0.35), "stoffa_rossa"))
	return r


## Agorà (3x3): piazza lastricata con un portico a colonne su due lati, bancarelle, statua e anfore.
static func agora() -> Node3D:
	var r := Node3D.new()
	r.add_child(scatola(Vector3(2.7, 0.04, 2.7), Vector3(0, 0.02, 0), "pietra"))
	var rng := _rng(260)
	for k in 40:
		r.add_child(scatola(Vector3(rng.randf_range(0.2, 0.4), 0.006, rng.randf_range(0.2, 0.4)),
			Vector3(rng.randf_range(-1.2, 1.2), 0.043, rng.randf_range(-1.2, 1.2)), "blocco", Vector3(0, rng.randf_range(-5, 5), 0)))
	# portico (stoa) lungo il fondo (-Z) e il lato sinistro (-X)
	var h := 0.48
	for lato in 2:
		var stoa := Node3D.new()
		stoa.position = Vector3(0, 0.04, -1.05) if lato == 0 else Vector3(-1.05, 0.04, 0.15)
		stoa.rotation_degrees.y = 0 if lato == 0 else 90
		r.add_child(stoa)
		var lung := 2.5 if lato == 0 else 2.2
		stoa.add_child(scatola(Vector3(lung, 0.04, 0.5), Vector3(0, 0.02, 0), "marmo"))
		stoa.add_child(scatola(Vector3(lung, h, 0.06), Vector3(0, 0.04 + h * 0.5, -0.22), "intonaco"))
		var n := 9 if lato == 0 else 8
		for k in n:
			var x := -lung * 0.5 + 0.1 + k * (lung - 0.2) / (n - 1)
			stoa.add_child(cilindro(0.04, 0.034, h, Vector3(x, 0.04 + h * 0.5, 0.2), "marmo", Vector3.ZERO, 12))
			stoa.add_child(scatola(Vector3(0.09, 0.025, 0.09), Vector3(x, 0.04 + h + 0.012, 0.2), "marmo"))
		stoa.add_child(scatola(Vector3(lung + 0.04, 0.05, 0.52), Vector3(0, 0.04 + h + 0.05, 0), "marmo"))
		for k in int(lung / 0.1):
			stoa.add_child(scatola(Vector3(0.03, 0.035, 0.01), Vector3(-lung * 0.5 + 0.05 + k * 0.1, 0.04 + h + 0.05, 0.265), "persiana" if k % 2 else "intonaco_sporco"))
		var t := Node3D.new()
		t.position = Vector3(0, 0.04 + h + 0.075, 0)
		stoa.add_child(t)
		tetto(t, lung, 0.5, 0.0, 18.0, 261 + lato)
		# merci sotto il portico
		for k in 4:
			stoa.add_child(anfora(Vector3(-lung * 0.4 + k * 0.5, 0.04, -0.08), 1.2))
	# bancarelle con le tende colorate
	var tende := ["stoffa_rossa", "stoffa", "geranio", "persiana"]
	for i in 4:
		var b := Node3D.new()
		b.position = Vector3(-0.25 + (i % 2) * 0.75, 0.04, -0.15 + (i / 2) * 0.72)
		r.add_child(b)
		b.add_child(scatola(Vector3(0.36, 0.1, 0.2), Vector3(0, 0.05, 0), "legno"))
		for x in [-0.17, 0.17]:
			b.add_child(cilindro(0.008, 0.008, 0.3, Vector3(x, 0.15, -0.09), "legno_vecchio", Vector3.ZERO, 5))
		b.add_child(scatola(Vector3(0.42, 0.012, 0.3), Vector3(0, 0.29, 0.0), tende[i], Vector3(-14, 0, 0)))
		var merce: String = ["olive", "pane", "agrumi", "formaggio"][i]
		b.add_child(cesta(Vector3(-0.08, 0.1, 0), merce, 0.8))
		b.add_child(cesta(Vector3(0.09, 0.1, 0.02), ["uva", "pesce", "cipolle", "olive"][i], 0.8))
	# statua su piedistallo al centro della piazza
	var s := Vector3(0.75, 0.04, 0.95)
	r.add_child(scatola(Vector3(0.2, 0.18, 0.2), s + Vector3(0, 0.09, 0), "marmo"))
	var statua := portatore("")
	statua.position = s + Vector3(0, 0.18, 0)
	statua.scale = Vector3.ONE * 0.95
	r.add_child(statua)
	_tutto_marmo(statua)
	# fontana in un angolo
	r.add_child(cilindro(0.18, 0.2, 0.08, Vector3(-0.7, 0.08, 0.95), "marmo", Vector3.ZERO, 18))
	r.add_child(cilindro(0.15, 0.15, 0.005, Vector3(-0.7, 0.125, 0.95), "acqua_pozzo", Vector3.ZERO, 18))
	return r


static func _tutto_marmo(n: Node) -> void:
	if n is MeshInstance3D:
		(n as MeshInstance3D).material_override = materiale("marmo")
	for k in n.get_children():
		_tutto_marmo(k)


# =================================================================== DIFESA (step 12)

## Guardia greca: elmo di bronzo con cresta, scudo rotondo al braccio sinistro, lancia nella destra.
static func guardia() -> Node3D:
	var r := portatore("")
	var corpo: Node3D = r.get_node("corpo")
	var anca := 0.2
	corpo.add_child(sfera(0.08, Vector3(0, anca + 0.27, -0.005), "bronzo", Vector3(1, 0.75, 1.05)))
	corpo.add_child(scatola(Vector3(0.016, 0.06, 0.13), Vector3(0, anca + 0.34, -0.01), "bandiera_rossa"))
	corpo.add_child(cilindro(0.088, 0.088, 0.03, Vector3(0, anca + 0.12, 0), "bronzo", Vector3.ZERO, 10))
	var bs: Node3D = corpo.get_node("braccio_s")
	var scudo := cilindro(0.085, 0.085, 0.014, Vector3(-0.02, -0.07, 0.04), "bronzo", Vector3(0, 0, 90), 16)
	bs.add_child(scudo)
	bs.add_child(cilindro(0.03, 0.03, 0.016, Vector3(-0.03, -0.07, 0.04), "bandiera_rossa", Vector3(0, 0, 90), 10))
	var bd: Node3D = corpo.get_node("braccio_d")
	bd.add_child(cilindro(0.007, 0.007, 0.5, Vector3(0, 0.06, 0.02), "legno", Vector3.ZERO, 5))
	bd.add_child(cilindro(0.016, 0.0, 0.06, Vector3(0, 0.34, 0.02), "ferro", Vector3.ZERO, 6))
	r.set_meta("carico", "lancia")
	return r


## Castello (3x3): mura di pietra con quattro torri agli angoli, mastio al centro, porta e stendardi.
static func castello() -> Node3D:
	var r := Node3D.new()
	var lato := 2.3
	var h := 0.5
	r.add_child(scatola(Vector3(lato + 0.3, 0.06, lato + 0.3), Vector3(0, 0.03, 0), "pietra"))
	# mura con merli
	for i in 4:
		var m := Node3D.new()
		m.rotation_degrees.y = i * 90
		r.add_child(m)
		m.add_child(scatola(Vector3(lato, h, 0.16), Vector3(0, 0.06 + h * 0.5, lato * 0.5), "pietra_vista"))
		for k in 11:
			m.add_child(scatola(Vector3(0.1, 0.08, 0.17), Vector3(-lato * 0.5 + 0.1 + k * (lato - 0.2) / 10, 0.06 + h + 0.04, lato * 0.5), "blocco"))
	# torri d'angolo
	for x in [-1, 1]:
		for z in [-1, 1]:
			var p := Vector3(x * lato * 0.5, 0, z * lato * 0.5)
			r.add_child(cilindro(0.24, 0.27, h + 0.3, p + Vector3(0, 0.06 + (h + 0.3) * 0.5, 0), "pietra_vista", Vector3.ZERO, 16))
			for k in 8:
				var a := k * TAU / 8
				r.add_child(scatola(Vector3(0.09, 0.08, 0.09), p + Vector3(cos(a) * 0.22, 0.06 + h + 0.34, sin(a) * 0.22), "blocco", Vector3(0, -rad_to_deg(a), 0)))
			r.add_child(cilindro(0.29, 0.0, 0.32, p + Vector3(0, 0.06 + h + 0.54, 0), "tegola", Vector3.ZERO, 16))
	# mastio al centro
	var c := Node3D.new()
	c.position = Vector3(-0.15, 0.06, -0.15)
	r.add_child(c)
	c.add_child(scatola(Vector3(0.8, 0.95, 0.8), Vector3(0, 0.475, 0), "pietra_vista"))
	for i in 4:
		for k in 5:
			var a := i * PI * 0.5
			var o := Vector3(-0.32 + k * 0.16, 0.99, 0.4).rotated(Vector3.UP, a)
			c.add_child(scatola(Vector3(0.1, 0.08, 0.1), o, "blocco", Vector3(0, rad_to_deg(a), 0)))
	finestra_z(c, 0.0, 0.7, 0.4, 0.07, 0.12)
	finestra_x(c, 0.0, 0.7, 0.4, 0.07, 0.12)
	c.add_child(cilindro(0.012, 0.012, 0.5, Vector3(0.2, 1.25, 0.2), "legno", Vector3.ZERO, 6))
	c.add_child(scatola(Vector3(0.006, 0.18, 0.26), Vector3(0.2, 1.4, 0.34), "stoffa"))
	# porta ad arco sul lato in vista e cortile
	r.add_child(scatola(Vector3(0.4, 0.38, 0.06), Vector3(0.45, 0.25, lato * 0.5 + 0.06), "legno_scuro"))
	r.add_child(scatola(Vector3(0.52, 0.06, 0.08), Vector3(0.45, 0.47, lato * 0.5 + 0.07), "blocco"))
	for k in 3:
		r.add_child(cassa(Vector3(0.55 + k * 0.12, 0.06, 0.55), k * 20))
	r.add_child(barile(Vector3(-0.7, 0.06, 0.6), 1.1))
	return r
