class_name Avversario
extends Node
## I Brettii, il popolo delle montagne, giocati dal computer. Crescono piano: ogni tanto alzano una
## torre nuova al margine del loro territorio. Dopo una tregua iniziale, quando una loro torre ha
## abbastanza guerrieri, attaccano il nostro forte più debole tra quelli raggiungibili.

const POPOLO := 2
const TREGUA := 900.0                # secondi di pace all'inizio della partita
const OGNI_ESPANSIONE := 300.0
const OGNI_ATTACCO := 240.0
const TORRI_MAX := 6
const ATTACCANTI_MIN := 3            # guerrieri che una torre deve avere per partire all'attacco

var villaggio: Villaggio
var guerra: Guerra
var dati: DatiMappa
var attivo := true                   # false nella partita «solo pace»
var tempo := 0.0                     # secondi dall'inizio della partita (si salva)
var _espansione := OGNI_ESPANSIONE
var _attacco := OGNI_ATTACCO
var _rng := RandomNumberGenerator.new()


func prepara(v: Villaggio, g: Guerra, d: DatiMappa) -> void:
	villaggio = v
	guerra = g
	dati = d
	_rng.seed = 1453


func _process(delta: float) -> void:
	if not attivo or villaggio.nemici.is_empty():
		return
	tempo += delta
	_espansione -= delta
	if _espansione <= 0.0:
		_espansione = OGNI_ESPANSIONE
		espandi()
	if tempo < TREGUA:
		return
	_attacco -= delta
	if _attacco <= 0.0:
		_attacco = OGNI_ATTACCO
		attacca()


## Una torre nuova al margine del territorio dei Brettii, lontana dai nostri confini.
func espandi() -> Edificio:
	if villaggio.nemici.size() >= TORRI_MAX:
		return null
	var torri := villaggio.nemici.values().filter(func(n): return n.proprietario == POPOLO)
	if torri.is_empty():
		return null
	var migliore := Vector2i(-1, -1)
	var punteggio := -INF
	for t in torri:
		var c0 := Vector2i(t.centro())
		for k in 40:
			var a := _rng.randf() * TAU
			var r := _rng.randf_range(5.0, 8.0)
			var c := c0 + Vector2i(roundi(cos(a) * r), roundi(sin(a) * r))
			if not _posto_libero(c):
				continue
			# meglio verso terre libere e lontano dai nostri confini
			var s := _rng.randf() - _vicino_al_giocatore(c) * 2.0
			if s > punteggio:
				punteggio = s
				migliore = c
	if migliore.x < 0:
		return null
	return villaggio.metti_nemico("torre_brettia", migliore, POPOLO, 1)


func _posto_libero(c: Vector2i) -> bool:
	for y in range(c.y, c.y + 3):
		for x in range(c.x, c.x + 2):
			if not dati.dentro(x, y) or dati.occupante(x, y) != 0 or dati.proprietario(x, y) == 1:
				return false
			if dati.tipo(x, y) not in [DatiMappa.Terreno.PRATO, DatiMappa.Terreno.SECCO, DatiMappa.Terreno.TERRA, DatiMappa.Terreno.BOSCO]:
				return false
	return true


func _vicino_al_giocatore(c: Vector2i) -> float:
	var n := 0
	for y in range(c.y - 6, c.y + 7, 2):
		for x in range(c.x - 6, c.x + 7, 2):
			if dati.proprietario(x, y) == 1:
				n += 1
	return n / 49.0


## Sceglie una torre con abbastanza guerrieri e il nostro forte più debole alla sua portata.
func attacca() -> bool:
	var scelta := []
	for t in villaggio.nemici.values():
		if t.proprietario != POPOLO or t.soldati < ATTACCANTI_MIN:
			continue
		for e in villaggio.edifici.values():
			if not CatalogoEdifici.dati(e.tipo).has("soldati_max") or not e.finito:
				continue
			var d := Vector2(e.centro() - t.centro()).length()
			if d > Guerra.RAGGIO_ATTACCO:
				continue
			# attaccano solo se sono più numerosi dei difensori
			var vantaggio: int = (t.soldati - 1) - e.soldati
			if vantaggio > 0:
				scelta.append([vantaggio - d * 0.05, t, e])
	if scelta.is_empty():
		return false
	scelta.sort_custom(func(a, b): return a[0] > b[0])
	return guerra.attacca(scelta[0][1], scelta[0][2]) > 0
