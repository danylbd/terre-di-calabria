class_name GeneratoreMappa
extends RefCounted
## Crea le mappe di gioco. "Costa ionica": monti e boschi a ovest, pianura con ulivi al centro,
## spiaggia e mare a est. "Monteleone": il Vibonese con la costa vera, da Pizzo a Nicotera.
## "Zancle": la Sicilia nord-orientale con la costa vera (Milazzo, Messina, lo Stretto, Taormina, l'Etna, Catania).
## Stesso seme = stessa mappa.

const T := DatiMappa.Terreno
const LIVELLO_MARE := 0.0

## Mappe tra cui scegliere nella partita libera: id -> [nome, descrizione]
const MAPPE := {
	"costa_ionica": ["Costa ionica", "Monti a ovest, pianura di ulivi e il mare a est."],
	"monteleone": ["Monteleone", "Il Vibonese: Monteleone sul colle, il golfo, Tropea, il Poro e le Serre."],
	"zancle": ["Zancle e l'Etna", "Oltre lo Stretto: Messina, i Peloritani, Taormina e il vulcano fumante."],
	"bruzio": ["Il Bruzio di Annibale", "La Calabria di Annibale tra i due mari: Crotone e il Lacinio, la Sila, Consentia, Scolacium e Locri."],
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
	match mappa:
		"monteleone":
			return genera_monteleone(seme)
		"zancle":
			return genera_zancle(seme)
		"bruzio":
			return genera_bruzio(seme)
	return genera(seme)


static func genera(seme: int, w := 144, h := 144) -> DatiMappa:
	var d := DatiMappa.new(w, h)
	var continente := _rumore(seme, 0.035, 3)
	var monti := _rumore(seme + 1, 0.05, 4)
	var creste := _rumore(seme + 2, 0.09, 2)
	var umido := _rumore(seme + 3, 0.06, 3)
	var secco := _rumore(seme + 4, 0.05, 2)
	var dettaglio := _rumore(seme + 5, 0.25, 2)
	# Il riquadro storico di 72×72 resta identico al suo centro; la nuova area si aggiunge
	# tutt'intorno e continua il terreno senza rimpicciolire montagne, costa o risorse.
	var margine_x := maxi(0, int((w - 72) / 2))
	var margine_y := maxi(0, int((h - 72) / 2))

	# --- quote dei vertici
	var costa_v := PackedFloat32Array()
	costa_v.resize((w + 1) * (h + 1))
	for j in h + 1:
		for i in w + 1:
			var mx := i - margine_x
			var my := j - margine_y
			var fx := float(mx) / 72.0
			var fy := float(my) / 72.0
			var costa := fx * 0.85 + fy * 0.22 + continente.get_noise_2d(mx, my) * 0.16
			costa_v[j * (w + 1) + i] = costa
			var entro := 0.76 - costa
			var q := 0.0
			if entro > 0.0:
				var forza_monte := clampf((0.5 - fx) * 2.4 + monti.get_noise_2d(mx, my) * 0.6, 0.0, 1.0)
				var cresta := 1.0 - absf(creste.get_noise_2d(mx, my))
				q = 4.0 + minf(entro, 0.12) * 60.0 + pow(forza_monte, 1.5) * 260.0 * (0.45 + 0.55 * cresta)
				q += dettaglio.get_noise_2d(mx, my) * 3.0
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
			elif umido.get_noise_2d(x - margine_x, y - margine_y) > 0.08 and q > 18.0:
				t = T.BOSCO
			elif secco.get_noise_2d(x - margine_x, y - margine_y) > 0.22:
				t = T.SECCO
			d.imposta_tipo(x, y, t)

	_mare_piatto(d)
	_radura(d, Vector2i(margine_x + 34, margine_y + 36))
	return d


## Il Vibonese: Monteleone sul colle sopra il golfo, Vibo Marina, Pizzo e il lago dell'Angitola a nord-est,
## Tropea sulla rupe e Capo Vaticano a ovest, l'altopiano del Poro, la valle del Mesima e le Serre a sud-est.
static func genera_monteleone(seme: int, w := 144, h := 144) -> DatiMappa:
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
			var s := _distanza_costa(p, [COSTA_MONTELEONE], [terra]) + frastaglio.get_noise_2d(i, j) * 1.3
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
	_spiana(d, LUOGHI_MONTELEONE["Vibo Marina"] + Vector2i(-1, -2), 5, true)      # l'approdo di Vibo Marina, dove fare il porto
	return d


## Coste della Sicilia nord-orientale in caselle (da coordinate vere: x = (lon − 14,85)·83, y = (38,32 − lat)·104,7,
## una casella ≈ 1 km): costa tirrenica da Patti a Capo Peloro (con la penisola di Milazzo), poi lo Stretto e la
## costa ionica fino a Catania. A est, oltre lo Stretto, la punta della Calabria (Scilla, Villa, Reggio).
const COSTA_SICILIA := [
	Vector2(-1, 19.5), Vector2(10, 18.8), Vector2(16.6, 18.8), Vector2(22.4, 16.8), Vector2(29.5, 13.5),
	Vector2(31.0, 8.0), Vector2(32.4, 5.2), Vector2(33.8, 8.0), Vector2(34.5, 12.5), Vector2(38.0, 12.0),
	Vector2(44.0, 9.4), Vector2(55.0, 7.5), Vector2(63.0, 6.0), Vector2(66.4, 5.8), Vector2(64.0, 9.5),
	Vector2(60.5, 12.0), Vector2(58.9, 13.6), Vector2(56.0, 19.0), Vector2(50.6, 28.3), Vector2(41.5, 41.9),
	Vector2(37.4, 49.2), Vector2(35.3, 52.4), Vector2(29.9, 61.8), Vector2(26.6, 74.3), Vector2(24.9, 80.6),
	Vector2(19.9, 85.9), Vector2(19.0, 97.0),
]
const COSTA_CALABRIA := [
	Vector2(73.0, -1), Vector2(71.4, 7.3), Vector2(65.6, 11.5), Vector2(66.0, 22.0), Vector2(66.4, 34.5),
	Vector2(68.9, 38.7), Vector2(77.0, 42.0), Vector2(97.0, 44.0),
]
const LUOGHI_ZANCLE := {
	"Zancle": Vector2i(50, 16), "Capo Peloro": Vector2i(64, 7), "Milazzo": Vector2i(32, 9), "Tindari": Vector2i(17, 20),
	"Peloritani": Vector2i(44, 24), "Taormina": Vector2i(36, 48), "Naxos": Vector2i(33, 53), "Etna": Vector2i(12, 60),
	"Acireale": Vector2i(24, 74), "Catania": Vector2i(17, 87), "Scilla": Vector2i(74, 7), "Reggio": Vector2i(70, 22),
}
const ETNA := Vector2(11.6, 59.7)


## La Sicilia nord-orientale: Zancle (Messina) sulla falce del porto davanti allo Stretto, i monti Peloritani alle
## spalle, la penisola di Milazzo, Taormina sulla rupe, l'Etna innevato e la sua terra nera, Catania; oltre lo
## Stretto la punta della Calabria. Il villaggio nasce a Zancle.
static func genera_zancle(seme: int, w := 144, h := 144) -> DatiMappa:
	var d := DatiMappa.new(w, h)
	var frastaglio := _rumore(seme + 20, 0.12, 2)
	var creste := _rumore(seme + 21, 0.08, 3)
	var umido := _rumore(seme + 22, 0.06, 3)
	var dettaglio := _rumore(seme + 23, 0.25, 2)
	var sicilia := PackedVector2Array(COSTA_SICILIA)
	sicilia.append_array([Vector2(19.0, 98), Vector2(-2, 98), Vector2(-2, 19.5)])
	var calabria := PackedVector2Array(COSTA_CALABRIA)
	calabria.append_array([Vector2(98, 44), Vector2(98, -2), Vector2(73.0, -2)])
	var coste := [COSTA_SICILIA, COSTA_CALABRIA]
	var terre := [sicilia, calabria]

	# --- quote dei vertici
	var dist_v := PackedFloat32Array()
	dist_v.resize((w + 1) * (h + 1))
	for j in h + 1:
		for i in w + 1:
			var p := Vector2(i, j)
			var s := _distanza_costa(p, coste, terre) + frastaglio.get_noise_2d(i, j) * 1.1
			dist_v[j * (w + 1) + i] = s
			var q := 0.0
			if s > 0.0:
				q = 5.0 + minf(s, 6.0) * 2.5
				var cresta := 1.0 - absf(creste.get_noise_2d(i, j))
				# i Peloritani: una dorsale da Capo Peloro verso sud-ovest, tra i due mari
				var dorsale := _distanza_segmento(p, Vector2(47, 5), Vector2(18, 33))
				q += 125.0 * exp(-dorsale * dorsale / (2.0 * 5.0 * 5.0)) * (0.6 + 0.4 * cresta)
				# i Nebrodi a ovest
				q += smoothstep(26.0, 6.0, i) * smoothstep(18.0, 30.0, j) * smoothstep(58.0, 44.0, j) * 120.0 * (0.6 + 0.4 * cresta)
				# l'Etna: base larga, cono alto con la neve, cratere in cima
				var de := p.distance_to(ETNA)
				q += 95.0 * exp(-de * de / (2.0 * 17.0 * 17.0)) + 200.0 * exp(-de * de / (2.0 * 7.0 * 7.0))
				if de < 1.6:
					q -= 30.0 * (1.0 - de / 1.6)
				# la punta della Calabria: l'Aspromonte che sale verso est
				if i > 64:
					q += smoothstep(68.0, 95.0, i) * 130.0 * (0.6 + 0.4 * cresta)
				q += dettaglio.get_noise_2d(i, j) * 3.0
				q = maxf(q, 3.0)
			d.imposta_quota(i, j, q)

	# --- tipo di terreno per casella
	for y in h:
		for x in w:
			var centro := Vector2(x + 0.5, y + 0.5)
			var s := (dist_v[y * (w + 1) + x] + dist_v[y * (w + 1) + x + 1] + dist_v[(y + 1) * (w + 1) + x] + dist_v[(y + 1) * (w + 1) + x + 1]) * 0.25
			var q := d.quota(centro.x, centro.y)
			var de := centro.distance_to(ETNA)
			var t := T.PRATO
			if s <= 0.0:
				t = T.ACQUA
			elif s < 1.4 and q < 18.0:
				t = T.SABBIA
			elif q > 225.0:
				t = T.NEVE
			elif de < 15.0 and q > 60.0:
				t = T.TERRA if de > 3.0 else T.ROCCIA     # la terra nera del vulcano, la lava vicino al cratere
			elif q > 140.0:
				t = T.ROCCIA
			elif s < 2.0 and q > 30.0:
				t = T.ROCCIA                  # le rupi sul mare (Taormina, Capo Sant'Alessio)
			elif umido.get_noise_2d(x, y) > 0.05 and q > 25.0:
				t = T.BOSCO
			elif de < 22.0 and umido.get_noise_2d(x, y) < -0.3:
				t = T.SECCO
			d.imposta_tipo(x, y, t)

	_mare_piatto(d)
	for nome in LUOGHI_ZANCLE:
		d.luoghi[nome] = LUOGHI_ZANCLE[nome]
	_radura(d, LUOGHI_ZANCLE["Zancle"], 12)
	return d


## Il Bruzio di Annibale (step 38): la Calabria centrale tra il Tirreno e lo Ionio, da coordinate vere
## (x = (lon − 15,95)·80, y = (39,45 − lat)·100, una casella ≈ 1,1 km). A ovest la costa tirrenica con il
## golfo di Sant'Eufemia, a est la costa ionica dal capo Alice a Locri, con Crotone e il capo Lacinio.
const COSTA_TIRRENO := [
	Vector2(2.4, -5), Vector2(6.4, 9), Vector2(9.6, 32), Vector2(12.0, 40), Vector2(20.0, 47), Vector2(21.6, 55),
	Vector2(16.8, 72), Vector2(14.4, 73), Vector2(6.4, 73), Vector2(-4, 75),
]
const COSTA_IONIO := [
	Vector2(88, -2), Vector2(96.8, 5), Vector2(94.4, 8), Vector2(94.4, 15), Vector2(94.4, 20), Vector2(96, 25),
	Vector2(94.4, 37), Vector2(100, 42), Vector2(91.2, 56), Vector2(86.4, 54), Vector2(72.8, 52), Vector2(53.6, 63),
	Vector2(48, 76), Vector2(49.6, 88), Vector2(49.6, 100), Vector2(36.8, 113), Vector2(28, 118), Vector2(24.8, 121),
	Vector2(18.4, 130),
]
const LUOGHI_BRUZIO := {
	"Crotone": Vector2i(89, 36), "Capo Lacinio": Vector2i(95, 41), "Petelia": Vector2i(87, 18), "Consentia": Vector2i(24, 15),
	"Sila": Vector2i(48, 20), "Valle del Crati": Vector2i(26, 4), "Terina": Vector2i(25, 50), "Scolacium": Vector2i(49, 65),
	"Hipponion": Vector2i(13, 79), "Serre": Vector2i(33, 92), "Kaulon": Vector2i(46, 100), "Locri": Vector2i(23, 119),
	"Aspromonte": Vector2i(9, 114), "Marchesato": Vector2i(76, 34),
}
## colline a campana: centro, altezza, raggio, tetto (0 = nessuno)
const COLLI_BRUZIO := [
	[Vector2(48, 20), 150.0, 19.0, 108.0],   # l'altopiano della Sila, coperto di pini
	[Vector2(13, 18), 120.0, 6.0, 0.0],      # la Catena Costiera sopra Paola
	[Vector2(14, 30), 110.0, 5.0, 0.0],
	[Vector2(26, 6), -20.0, 7.0, 0.0],       # la valle del Crati
	[Vector2(35, 58), -10.0, 8.0, 0.0],      # l'istmo tra i due mari, il punto più stretto d'Italia
	[Vector2(36, 84), 135.0, 9.0, 0.0],      # le Serre
	[Vector2(31, 98), 140.0, 9.0, 0.0],
	[Vector2(9, 116), 230.0, 13.0, 0.0],     # l'Aspromonte
	[Vector2(76, 34), 30.0, 12.0, 0.0],      # le colline d'argilla del Marchesato
	[Vector2(78, 30), 185.0, 2.6, 0.0],      # uno sperone di roccia nel Marchesato, la cava di Crotone
]


static func genera_bruzio(seme: int, w := 144, h := 144) -> DatiMappa:
	var d := DatiMappa.new(w, h)
	var frastaglio := _rumore(seme + 20, 0.12, 2)
	var umido := _rumore(seme + 21, 0.06, 3)
	var secco := _rumore(seme + 22, 0.07, 2)
	var dettaglio := _rumore(seme + 23, 0.25, 2)
	var coste := [COSTA_TIRRENO, COSTA_IONIO]
	var terra := PackedVector2Array(COSTA_TIRRENO)
	terra.append_array([Vector2(-6, h + 6)])
	var ionio_rovescio := COSTA_IONIO.duplicate()
	ionio_rovescio.reverse()
	terra.append_array(PackedVector2Array(ionio_rovescio))
	terra.append_array([Vector2(88, -6), Vector2(2.4, -6)])

	# --- quote dei vertici (s: distanza con segno dalla costa, positiva verso terra)
	var dist_v := PackedFloat32Array()
	dist_v.resize((w + 1) * (h + 1))
	for j in h + 1:
		for i in w + 1:
			var p := Vector2(i, j)
			var s := _distanza_costa(p, coste, [terra]) + frastaglio.get_noise_2d(i, j) * 1.3
			dist_v[j * (w + 1) + i] = s
			var q := 0.0
			if s > 0.0:
				q = 5.0 + minf(s, 8.0) * 3.0
				for c in COLLI_BRUZIO:
					var r: float = c[2]
					var alta: float = c[1] * exp(-p.distance_squared_to(c[0]) / (2.0 * r * r))
					q += minf(alta, c[3]) if c[3] > 0.0 else alta
				q += dettaglio.get_noise_2d(i, j) * 3.0
				q = maxf(q, 3.0)
			d.imposta_quota(i, j, q)

	# --- tipo di terreno per casella
	for y in h:
		for x in w:
			var centro := Vector2(x + 0.5, y + 0.5)
			var s := (dist_v[y * (w + 1) + x] + dist_v[y * (w + 1) + x + 1] + dist_v[(y + 1) * (w + 1) + x] + dist_v[(y + 1) * (w + 1) + x + 1]) * 0.25
			var q := d.quota(centro.x, centro.y)
			var t := T.PRATO
			if s <= 0.0:
				t = T.ACQUA
			elif s < 1.6 and q < 20.0:
				t = T.SABBIA
			elif q > 225.0:
				t = T.NEVE
			elif q > 150.0:
				t = T.ROCCIA
			elif centro.distance_to(COLLI_BRUZIO[0][0]) < 22.0 and q > 60.0:
				t = T.BOSCO                   # i pini della Sila
			elif (q > 95.0 and umido.get_noise_2d(x, y) > -0.3) or (umido.get_noise_2d(x, y) > 0.15 and q > 20.0):
				t = T.BOSCO
			elif centro.distance_to(COLLI_BRUZIO[8][0]) < 16.0 and secco.get_noise_2d(x, y) > -0.2:
				t = T.SECCO                   # le argille assolate del Marchesato
			d.imposta_tipo(x, y, t)

	_mare_piatto(d)
	for nome in LUOGHI_BRUZIO:
		d.luoghi[nome] = LUOGHI_BRUZIO[nome]
	_radura(d, LUOGHI_BRUZIO["Crotone"] + Vector2i(-5, -1), 10)
	_spiana(d, LUOGHI_BRUZIO["Crotone"] + Vector2i(2, 1), 4, true)     # il porto di Crotone, dentro i primi confini
	return d


static func _distanza_segmento(p: Vector2, a: Vector2, b: Vector2) -> float:
	return p.distance_to(Geometry2D.get_closest_point_to_segment(p, a, b))


## Distanza con segno dalla costa più vicina (positiva a terra): coste sono linee, terre i poligoni.
static func _distanza_costa(p: Vector2, coste: Array, terre: Array) -> float:
	var m := INF
	for costa in coste:
		for k in costa.size() - 1:
			m = minf(m, p.distance_to(Geometry2D.get_closest_point_to_segment(p, costa[k], costa[k + 1])))
	for terra in terre:
		if Geometry2D.is_point_in_polygon(p, terra):
			return m
	return -m


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
	_spiana(d, centro, raggio)


## Spiana un tratto di terra intorno a una casella e lo libera da boschi e rocce. Con «riva» il mare e la
## sua riga di bordo restano come sono, e anche la sabbia diventa prato (un approdo dove costruire).
static func _spiana(d: DatiMappa, centro: Vector2i, raggio: int, riva := false) -> void:
	var q0 := 7.0 if riva else d.quota(centro.x, centro.y)      # l'approdo sta appena sopra il mare
	for j in range(centro.y - raggio, centro.y + raggio + 1):
		for i in range(centro.x - raggio, centro.x + raggio + 1):
			if i < 0 or j < 0 or i > d.larghezza or j > d.altezza:
				continue
			var dist := Vector2(i - centro.x, j - centro.y).length() / raggio
			if dist < 1.0:
				var peso := smoothstep(1.0, 0.55, dist)
				if not (riva and _vertice_sul_mare(d, i, j)):
					d.imposta_quota(i, j, lerpf(d.quota_vertice(i, j), q0, peso))
				var adatti := [T.BOSCO, T.SECCO, T.ROCCIA, T.SABBIA] if riva else [T.BOSCO, T.SECCO, T.ROCCIA]
				if dist < 0.8 and d.dentro(i, j) and d.tipo(i, j) in adatti:
					d.imposta_tipo(i, j, T.PRATO)


## Il vertice tocca una casella di mare.
static func _vertice_sul_mare(d: DatiMappa, i: int, j: int) -> bool:
	for c in [Vector2i(i - 1, j - 1), Vector2i(i, j - 1), Vector2i(i - 1, j), Vector2i(i, j)]:
		if d.dentro(c.x, c.y) and d.tipo(c.x, c.y) == T.ACQUA:
			return true
	return false


static func _rumore(seme: int, frequenza: float, ottave: int) -> FastNoiseLite:
	var n := FastNoiseLite.new()
	n.seed = seme
	n.frequency = frequenza
	n.fractal_octaves = ottave
	n.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	return n
