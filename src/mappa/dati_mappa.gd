class_name DatiMappa
extends RefCounted
## Tutti i dati di una mappa: tipo di terreno per casella e quota per vertice.

enum Terreno { PRATO, BOSCO, SABBIA, ROCCIA, NEVE, ACQUA, TERRA, SECCO }

var larghezza: int
var altezza: int
var tipi := PackedByteArray()        # larghezza * altezza
var quote := PackedFloat32Array()    # (larghezza + 1) * (altezza + 1), in pixel verso l'alto
var villaggio := Vector2i.ZERO       # casella del centro del villaggio iniziale
var occupazione := PackedInt32Array() # 0 libero, 1 natura (alberi, rocce), >=2 id di un edificio
var territorio := PackedByteArray()   # 1 = casella del giocatore

const NATURA := 1


func _init(w: int, h: int) -> void:
	larghezza = w
	altezza = h
	tipi.resize(w * h)
	quote.resize((w + 1) * (h + 1))
	occupazione.resize(w * h)
	territorio.resize(w * h)


func occupante(x: int, y: int) -> int:
	if not dentro(x, y):
		return -1
	return occupazione[y * larghezza + x]


func occupa(x: int, y: int, id: int) -> void:
	if dentro(x, y):
		occupazione[y * larghezza + x] = id


func nel_territorio(x: int, y: int) -> bool:
	return dentro(x, y) and territorio[y * larghezza + x] == 1


## Ricalcola il territorio da un elenco di centri [casella, raggio].
func calcola_territorio(centri: Array) -> void:
	territorio.fill(0)
	for c in centri:
		var p: Vector2i = c[0]
		var r: float = c[1]
		for y in range(p.y - int(r) - 1, p.y + int(r) + 2):
			for x in range(p.x - int(r) - 1, p.x + int(r) + 2):
				if dentro(x, y) and Vector2(x - p.x, y - p.y).length() <= r:
					territorio[y * larghezza + x] = 1


## Casella sotto un punto dello schermo, tenendo conto del rilievo.
func casella_da_schermo(p: Vector2) -> Vector2i:
	var v := Iso.da_schermo(p)
	for k in 5:
		var q := quota(clampf(v.x, 0, larghezza), clampf(v.y, 0, altezza))
		v = Iso.da_schermo(p + Vector2(0, q))
	return Vector2i(floori(v.x), floori(v.y))


func tipo(x: int, y: int) -> int:
	return tipi[clampi(y, 0, altezza - 1) * larghezza + clampi(x, 0, larghezza - 1)]


func imposta_tipo(x: int, y: int, t: int) -> void:
	tipi[y * larghezza + x] = t


func quota_vertice(i: int, j: int) -> float:
	return quote[clampi(j, 0, altezza) * (larghezza + 1) + clampi(i, 0, larghezza)]


func imposta_quota(i: int, j: int, q: float) -> void:
	quote[j * (larghezza + 1) + i] = q


## Quota in un punto qualsiasi della mappa (interpolata tra i quattro vertici).
func quota(x: float, y: float) -> float:
	var i := int(floor(x))
	var j := int(floor(y))
	var fx := x - i
	var fy := y - j
	var a := lerpf(quota_vertice(i, j), quota_vertice(i + 1, j), fx)
	var b := lerpf(quota_vertice(i, j + 1), quota_vertice(i + 1, j + 1), fx)
	return lerpf(a, b, fy)


func dentro(x: int, y: int) -> bool:
	return x >= 0 and y >= 0 and x < larghezza and y < altezza


## Posizione sullo schermo di un punto della mappa, tenendo conto del rilievo.
func a_schermo(x: float, y: float) -> Vector2:
	return Iso.a_schermo(x, y, quota(x, y))
