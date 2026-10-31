class_name GeneratoreMappa
extends RefCounted
## Crea una mappa di prova "Costa ionica": monti e boschi a ovest, pianura con ulivi al centro,
## spiaggia e mare a est. Stesso seme = stessa mappa.

const T := DatiMappa.Terreno
const LIVELLO_MARE := 0.0


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

	# --- mare piatto e rive basse
	for y in h:
		for x in w:
			if d.tipo(x, y) == T.ACQUA:
				for v in [Vector2i(x, y), Vector2i(x + 1, y), Vector2i(x, y + 1), Vector2i(x + 1, y + 1)]:
					d.imposta_quota(v.x, v.y, LIVELLO_MARE)

	# --- radura pianeggiante per il villaggio
	d.villaggio = Vector2i(int(w * 0.48), int(h * 0.5))
	var raggio := 8
	var q0 := d.quota(d.villaggio.x, d.villaggio.y)
	for j in range(d.villaggio.y - raggio, d.villaggio.y + raggio + 1):
		for i in range(d.villaggio.x - raggio, d.villaggio.x + raggio + 1):
			if i < 0 or j < 0 or i > w or j > h:
				continue
			var dist := Vector2(i - d.villaggio.x, j - d.villaggio.y).length() / raggio
			if dist < 1.0:
				var peso := smoothstep(1.0, 0.55, dist)
				d.imposta_quota(i, j, lerpf(d.quota_vertice(i, j), q0, peso))
				if dist < 0.8 and d.dentro(i, j) and d.tipo(i, j) in [T.BOSCO, T.SECCO, T.ROCCIA]:
					d.imposta_tipo(i, j, T.PRATO)
	return d


static func _rumore(seme: int, frequenza: float, ottave: int) -> FastNoiseLite:
	var n := FastNoiseLite.new()
	n.seed = seme
	n.frequency = frequenza
	n.fractal_octaves = ottave
	n.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	return n
