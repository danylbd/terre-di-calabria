class_name Iso
## Conversioni tra coordinate della mappa (caselle) e coordinate dello schermo isometrico.
## La casella (x, y) ha il vertice in alto in a_schermo(x, y); il centro è in a_schermo(x + 0.5, y + 0.5).

const TW := 112.0   # larghezza di una casella in pixel
const TH := 56.0    # altezza di una casella in pixel


static func a_schermo(x: float, y: float, quota := 0.0) -> Vector2:
	return Vector2((x - y) * TW * 0.5, (x + y) * TH * 0.5 - quota)


## Inverso di a_schermo per quota 0 (il terreno con rilievi va corretto a parte).
static func da_schermo(p: Vector2) -> Vector2:
	return Vector2(p.x / TW + p.y / TH, p.y / TH - p.x / TW)
