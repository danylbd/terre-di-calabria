class_name Portatore
extends Colono
## Il portatore di un tratto di strada: aspetta a metà del tratto; quando una merce lo aspetta
## a un capo, va a prenderla, la porta all'altro capo, la posa e torna a metà.

signal merce_posata(m: Merce, dove: Vector2i)

enum Stato { ARRIVO, ATTESA, VA_A_PRENDERE, PORTA, RIENTRA }

var stato := Stato.ARRIVO
var tratto                     # ReteStrade.Tratto
var _merce: Merce
var _da := Vector2i.ZERO
var _a := Vector2i.ZERO


func _ready() -> void:
	arrivato.connect(_on_arrivato)


func libero() -> bool:
	return stato == Stato.ATTESA


## Incarico: prendere la merce m alla bandierina "da" e portarla alla bandierina "a" (i due capi del tratto).
func trasporta(m: Merce, da: Vector2i, a: Vector2i) -> void:
	_merce = m
	_da = da
	_a = a
	m.prenotata = true
	stato = Stato.VA_A_PRENDERE
	percorri(_punti_verso(da))


## Il tratto è stato tolto: la merce in spalla torna a terra alla bandierina di partenza.
func annulla() -> Merce:
	var m := _merce
	if m:
		m.prenotata = false
		if m.in_spalla:
			m.in_spalla = false
			m.bandiera = _da
	_merce = null
	return m


func _on_arrivato(_c: Colono) -> void:
	match stato:
		Stato.ARRIVO, Stato.RIENTRA:
			stato = Stato.ATTESA
			imposta_foglio("portatore_nessuno")
		Stato.VA_A_PRENDERE:
			_merce.in_spalla = true
			_merce.sprite.visible = false
			imposta_foglio(_merce.foglio_portatore())
			stato = Stato.PORTA
			percorri(_punti_tra(_da, _a))
		Stato.PORTA:
			var m := _merce
			_merce = null
			m.in_spalla = false
			m.prenotata = false
			m.bandiera = _a
			imposta_foglio("portatore_nessuno")
			stato = Stato.RIENTRA
			percorri(_punti_verso_meta(_a))
			merce_posata.emit(m, _a)


# ---------------------------------------------------------- percorsi lungo il proprio tratto

func _indice(bandiera: Vector2i) -> int:
	return 0 if tratto.percorso[0] == bandiera else tratto.percorso.size() - 1


func _centro(c: Vector2i) -> Vector2:
	return Vector2(c) + Vector2(0.5, 0.5)


func punto_meta() -> Vector2:
	var p: Array[Vector2i] = tratto.percorso
	var m := p.size() / 2
	if p.size() % 2 == 0:
		return (_centro(p[m - 1]) + _centro(p[m])) * 0.5
	return _centro(p[m])


func _punti_verso(bandiera: Vector2i) -> Array[Vector2]:
	var p: Array[Vector2i] = tratto.percorso
	var r: Array[Vector2] = []
	var m := p.size() / 2
	if _indice(bandiera) == 0:
		for k in range(m - 1 if p.size() % 2 == 0 else m, -1, -1):
			r.append(_centro(p[k]))
	else:
		for k in range(m, p.size()):
			r.append(_centro(p[k]))
	return r


func _punti_tra(da: Vector2i, a: Vector2i) -> Array[Vector2]:
	var p: Array[Vector2i] = tratto.percorso.duplicate()
	if _indice(da) != 0:
		p.reverse()
	var r: Array[Vector2] = []
	for c in p:
		r.append(_centro(c))
	return r


func _punti_verso_meta(da: Vector2i) -> Array[Vector2]:
	var verso := _punti_verso(da)
	verso.reverse()
	verso.append(punto_meta())
	return verso
