class_name GeneratoreMappa
extends RefCounted
## Crea le mappe di gioco. "Costa ionica": monti e boschi a ovest, pianura con ulivi al centro,
## spiaggia e mare a est. "Monteleone": il Vibonese con la costa vera, da Pizzo a Nicotera.
## Stesso seme = stessa mappa.

const T := DatiMappa.Terreno
const LIVELLO_MARE := 0.0

## Mappe tra cui scegliere nella partita libera: id -> [nome, descrizione]
const MAPPE := {
	"costa_ionica": ["Costa ionica", "Monti a ovest, pianura di ulivi e il mare a est."],
	"monteleone": ["Monteleone", "Il Vibonese: Monteleone sul colle, il golfo, Tropea, il Poro e le Serre."],
}

## Costa del Vibonese in caselle (da coordinate vere: x = (lon − 15,80)/0,50·96, y = (38,80 − lat)/0,36·96),
## da Pizzo (nord-est) a Nicotera (sud-ovest): il mare sta a nord-ovest della linea.
const COSTA_MONTELEONE := [
	Vector2(78.7, -1), Vector2(74.9, 10.7), Vector2(71.0, 17.3), Vector2(66.2, 21.3), Vector2(61.4, 23.5),
	Vector2(53.8, 22.7), Vector2(44.2, 21.3), Vector2(34.6, 25.3), Vector2(25.0, 29.3), Vector2(18.2, 32.8),
	Vector2(11.5, 37.3), Vector2(5.8, 45.3), Vector2(7.7, 50.7), Vector2(15.4, 58.7), Vector2(26.9, 66.7),
	Vector2(25.0, 80.0), Vector2(19.2, 97),
]
const LUOGHI_MONTELEONE := {
	"Monteleone": Vector2i(57, 33), "Vibo Marina": Vector2i(61, 26), "Bivona": Vector2i(66, 23),
	"Pizzo": Vector2i(71, 19), "Briatico": Vector2i(44, 23), "Tropea": Vector2i(20, 33),
	"Isola": Vector2i(16, 31), "Capo Vaticano": Vector2i(8, 46), "Monte Poro": Vector2i(35, 49),
	"Lago dell'Angitola": Vector2i(82, 12), "Serre": Vector2i(88, 59), "Valle del Mesima": Vector2i(54, 72),
}
## colline a campana: centro, altezza, raggio, tetto (0 = nessuno)
const COLLI_MONTELEONE := [
	[Vector2(57, 33), 70.0, 10.0, 0.0],     # il colle di Monteleone
	[Vector2(35, 49), 105.0, 13.0, 88.0],   # l'altopiano del Poro
	[Vector2(20, 33), 32.0, 4.0, 0.0],      # la rupe di Tropea
	[Vector2(54, 72), -14.0, 11.0, 0.0],    # la valle del Mesima
]
const LAGO := Vector2(82, 12)
const LAGO_RAGGI := Vector2(4.0, 2.6)


static func crea(mappa: String, seme: int) -> DatiMappa:
	return genera_monteleone(seme) if mappa == "monteleone" else genera(seme)


static func genera(seme: int, w := 72, h := 72) -> DatiMappa:
	var d := DatiMappa.new(w, h)
	var continente := _rumore(seme, 0.035, 3)
	var monti := _rumore(seme + 1, 0.05, 4)
	var creste := _rumore(seme + 2, 0.09, 2)
	var umido := _rumore(seme + 3, 0.06, 3)
	var secco := _rumore(seme + 4, 0.05, 2)
	var dettaglio := _rumore(seme + 5, 0.25, 2)

	# --- quote dei vertici
	var costa_v := PackedFloat32Array()
	costa_v.resize((w + 1) * (h + 1))
	for j in h + 1:
		for i in w + 1:
			var fx := float(i) / w
			var fy := float(j) / h
			var costa := fx * 0.85 + fy * 0.22 + continente.get_noise_2d(i, j) * 0.16
			costa_v[j * (w + 1) + i] = costa
			var entro := 0.76 - costa
			var q := 0.0
			if entro > 0.0:
				var forza_monte := clampf((0.5 - fx) * 2.4 + monti.get_noise_2d(i, j) * 0.6, 0.0, 1.0)
				var cresta := 1.0 - absf(creste.get_noise_2d(i, j))
				q = 4.0 + minf(entro, 0.12) * 60.0 + pow(forza_monte, 1.5) * 260.0 * (0.45 + 0.55 * cresta)
				q += dettaglio.get_noise_2d(i, j) * 3.0
			d.imposta_quota(i, j, q)

	# --- tipo di terreno per casella
	for y in h:
		for x in w:
			var c := (costa_v[y * (w + 1) + x] + costa_v[y * (w + 1) + x + 1] + costa_v[(y + 1) * (w + 1) + x] + costa_v[(y + 1) * (w + 1) + x + 1]) * 0.25
			var q := d.quota(x + 0.5, y + 0.5)
			var t := T.PRATO
			if c > 0.765:
				t = T.ACQUA
			elif c > 0.725:
				t = T.SABBIA
			elif q > 225.0:
				t = T.NEVE
			elif q > 120.0:
				t = T.ROCCIA
			elif umido.get_noise_2d(x, y) > 0.08 and q > 18.0:
				t = T.BOSCO
			elif secco.get_noise_2d(x, y) > 0.22:
				t = T.SECCO
			d.imposta_tipo(x, y, t)

	_mare_piatto(d)
	_radura(d, Vector2i(int(w * 0.48), int(h * 0.5)))
	return d


## Il Vibonese: Monteleone sul colle sopra il golfo, Vibo Marina, Pizzo e il lago dell'Angitola a nord-est,
## Tropea sulla rupe e Capo Vaticano a ovest, l'altopiano del Poro, la valle del Mesima e le Serre a sud-est.
static func genera_monteleone(seme: int, w := 96, h := 96) -> DatiMappa:
	var d := DatiMappa.new(w, h)
	var frastaglio := _rumore(seme + 10, 0.12, 2)
	var serre_r := _rumore(seme + 11, 0.07, 3)
	var umido := _rumore(seme + 12, 0.06, 3)
	var secco := _rumore(seme + 13, 0.07, 2)
	var dettaglio := _rumore(seme + 14, 0.25, 2)
	var terra := PackedVector2Array(COSTA_MONTELEONE)
	terra.append_array([Vector2(w + 2, h + 2), Vector2(w + 2, -2), Vector2(78.7, -2)])

	# --- quote dei vertici (dist_v: distanza con segno dalla costa, positiva verso terra)
	var dist_v := PackedFloat32Array()
	dist_v.resize((w + 1) * (h + 1))
	for j in h + 1:
		for i in w + 1:
			var p := Vector2(i, j)
			var s := _distanza_costa(p, terra) + frastaglio.get_noise_2d(i, j) * 1.3
			dist_v[j * (w + 1) + i] = s
			var q := 0.0
			if s > 0.0:
				q = 5.0 + minf(s, 6.0) * 2.5
				for c in COLLI_MONTELEONE:
					var r: float = c[2]
					var alta: float = c[1] * exp(-p.distance_squared_to(c[0]) / (2.0 * r * r))
					q += minf(alta, c[3]) if c[3] > 0.0 else alta
				var lago := _nel_lago(p)
				var serre := smoothstep(66.0, 95.0, i) * smoothstep(-4.0, 30.0, j) * 250.0 * (0.65 + 0.35 * serre_r.get_noise_2d(i, j))
				q += serre * smoothstep(1.0, 3.0, lago)
				q += dettaglio.get_noise_2d(i, j) * 3.0
				q = maxf(q, 3.0)
				if lago < 1.0:
					q = 0.0
			d.imposta_quota(i, j, q)

	# --- tipo di terreno per casella
	for y in h:
		for x in w:
			var centro := Vector2(x + 0.5, y + 0.5)
			var s := (dist_v[y * (w + 1) + x] + dist_v[y * (w + 1) + x + 1] + dist_v[(y + 1) * (w + 1) + x] + dist_v[(y + 1) * (w + 1) + x + 1]) * 0.25
			var q := d.quota(centro.x, centro.y)
			var t := T.PRATO
			if s <= 0.0 or _nel_lago(centro) < 1.0:
				t = T.ACQUA
			elif s < 1.6 and q < 20.0:
				t = T.SABBIA
			elif q > 225.0:
				t = T.NEVE
			elif q > 135.0:
				t = T.ROCCIA
			elif s < 2.2 and q > 28.0:
				t = T.ROCCIA                  # le rupi sul mare (Tropea, Capo Vaticano)
			elif (x > 66 and q > 45.0) or (umido.get_noise_2d(x, y) > 0.1 and q > 18.0):
				t = T.BOSCO
			elif centro.distance_to(COLLI_MONTELEONE[1][0]) < 15.0 and secco.get_noise_2d(x, y) > -0.1:
				t = T.SECCO                   # l'altopiano del Poro, sassoso e assolato
			d.imposta_tipo(x, y, t)

	_mare_piatto(d)
	# lo scoglio di Santa Maria dell'Isola davanti a Tropea
	var isola := Vector2(LUOGHI_MONTELEONE["Isola"]) + Vector2(0.5, 0.5)
	for j in range(int(isola.y) - 2, int(isola.y) + 3):
		for i in range(int(isola.x) - 2, int(isola.x) + 3):
			var dv := Vector2(i, j).distance_to(isola)
			if dv < 1.6:
				d.imposta_quota(i, j, 22.0 if dv < 1.0 else 8.0)
			if d.dentro(i, j) and Vector2(i + 0.5, j + 0.5).distance_to(isola) < 1.2:
				d.imposta_tipo(i, j, T.ROCCIA)
	for nome in LUOGHI_MONTELEONE:
		d.luoghi[nome] = LUOGHI_MONTELEONE[nome]
	_radura(d, LUOGHI_MONTELEONE["Monteleone"], 11)
	return d


static func _distanza_costa(p: Vector2, terra: PackedVector2Array) -> float:
	var m := INF
	for k in COSTA_MONTELEONE.size() - 1:
		m = minf(m, p.distance_to(Geometry2D.get_closest_point_to_segment(p, COSTA_MONTELEONE[k], COSTA_MONTELEONE[k + 1])))
	return m if Geometry2D.is_point_in_polygon(p, terra) else -m


## 0 al centro del lago dell'Angitola, 1 sulla riva.
static func _nel_lago(p: Vector2) -> float:
	return Vector2((p.x - LAGO.x) / LAGO_RAGGI.x, (p.y - LAGO.y) / LAGO_RAGGI.y).length()


## Mare piatto e rive basse.
static func _mare_piatto(d: DatiMappa) -> void:
	for y in d.altezza:
		for x in d.larghezza:
			if d.tipo(x, y) == T.ACQUA:
				for v in [Vector2i(x, y), Vector2i(x + 1, y), Vector2i(x, y + 1), Vector2i(x + 1, y + 1)]:
					d.imposta_quota(v.x, v.y, LIVELLO_MARE)


## Radura pianeggiante per il villaggio.
static func _radura(d: DatiMappa, centro: Vector2i, raggio := 8) -> void:
	d.villaggio = centro
	var q0 := d.quota(centro.x, centro.y)
	for j in range(centro.y - raggio, centro.y + raggio + 1):
		for i in range(centro.x - raggio, centro.x + raggio + 1):
			if i < 0 or j < 0 or i > d.larghezza or j > d.altezza:
				continue
			var dist := Vector2(i - centro.x, j - centro.y).length() / raggio
			if dist < 1.0:
				var peso := smoothstep(1.0, 0.55, dist)
				d.imposta_quota(i, j, lerpf(d.quota_vertice(i, j), q0, peso))
				if dist < 0.8 and d.dentro(i, j) and d.tipo(i, j) in [T.BOSCO, T.SECCO, T.ROCCIA]:
					d.imposta_tipo(i, j, T.PRATO)


static func _rumore(seme: int, frequenza: float, ottave: int) -> FastNoiseLite:
	var n := FastNoiseLite.new()
	n.seed = seme
	n.frequency = frequenza
	n.fractal_octaves = ottave
	n.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	return n
