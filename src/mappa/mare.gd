class_name Mare
## Strumenti per andare per mare (step 35): l'acqua più vicina a una casella e la rotta più breve sul mare.


static func acqua_vicina(dati: DatiMappa, c: Vector2i, raggio: int) -> Vector2i:
	var migliore := Vector2i(-1, -1)
	var meglio := INF
	for y in range(c.y - raggio, c.y + raggio + 1):
		for x in range(c.x - raggio, c.x + raggio + 1):
			var d := Vector2(x - c.x, y - c.y).length()
			if d < meglio and dati.dentro(x, y) and dati.tipo(x, y) == DatiMappa.Terreno.ACQUA:
				meglio = d
				migliore = Vector2i(x, y)
	return migliore


## La rotta più breve sul mare (8 direzioni), tappe al centro delle caselle, senza la partenza.
static func rotta(dati: DatiMappa, da: Vector2i, a: Vector2i) -> Array[Vector2]:
	var tappe: Array[Vector2] = []
	var da_dove := {da: da}
	var coda: Array[Vector2i] = [da]
	var i := 0
	while i < coda.size():
		var c: Vector2i = coda[i]
		i += 1
		if c == a:
			break
		for dy in range(-1, 2):
			for dx in range(-1, 2):
				var n := c + Vector2i(dx, dy)
				if not da_dove.has(n) and dati.dentro(n.x, n.y) and dati.tipo(n.x, n.y) == DatiMappa.Terreno.ACQUA:
					da_dove[n] = c
					coda.append(n)
	if not da_dove.has(a):
		return tappe
	var c := a
	while c != da:
		tappe.push_front(Vector2(c) + Vector2(0.5, 0.5))
		c = da_dove[c]
	return tappe
