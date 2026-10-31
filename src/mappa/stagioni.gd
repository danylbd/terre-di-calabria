class_name Stagioni
extends Node
## Il calendario: quattro stagioni che si susseguono. Decidono quanto crescono campi e frutti,
## quando si semina, e cambiano l'aspetto della mappa (neve, foglie d'autunno, luce) con dolcezza.

signal cambiata(stagione: int)

enum { PRIMAVERA, ESTATE, AUTUNNO, INVERNO }
const NOMI := ["Primavera", "Estate", "Autunno", "Inverno"]
const DURATA := 300.0                # secondi di gioco per ogni stagione
const PASSAGGIO := 25.0              # secondi in cui i colori sfumano da una stagione all'altra

## quanto crescono le colture in ogni stagione (primavera, estate, autunno, inverno)
const CRESCITA := {
	"grano": [1.3, 1.0, 0.6, 0.0], "orto": [1.3, 1.0, 0.6, 0.0],
	"vite": [0.8, 1.2, 1.0, 0.0], "agrumi": [0.8, 1.2, 1.0, 0.0],
	"alberi": [1.2, 1.0, 0.7, 0.3], "olive": [0.5, 0.5, 2.0, 1.0],
}
## aspetto: neve sul terreno, foglie di castagni e querce, luce generale
const NEVE := [0.0, 0.0, 0.0, 1.0]
const FOGLIE := [Color(1, 1, 1), Color(1.05, 1.02, 0.92), Color(1.25, 0.82, 0.5), Color(0.72, 0.62, 0.55)]
const LUCE := [Color(1, 1, 1), Color(1.05, 1.0, 0.92), Color(1.04, 0.96, 0.88), Color(0.9, 0.94, 1.04)]
const SPECIE_DECIDUE := ["castagno", "quercia"]

var tempo := 0.0                     # secondi dall'inizio della partita
var terreno: Terreno
var risorse: RisorseNaturali
var luce: CanvasModulate
var fiocchi: CPUParticles2D
var _stagione := PRIMAVERA
var _ritocco := 0.0


func prepara(t: Terreno, r: RisorseNaturali, l: CanvasModulate, f: CPUParticles2D) -> void:
	terreno = t
	risorse = r
	luce = l
	fiocchi = f
	_stagione = stagione()
	_applica_aspetto(true)


func stagione() -> int:
	return int(tempo / DURATA) % 4


func anno() -> int:
	return int(tempo / (DURATA * 4)) + 1


func nome() -> String:
	return "%s · anno %d" % [NOMI[stagione()], anno()]


func inverno() -> bool:
	return stagione() == INVERNO


## Moltiplicatore della crescita di una coltura (grano, orto, vite, agrumi, alberi, olive).
func crescita(coltura: String) -> float:
	return CRESCITA.get(coltura, [1.0, 1.0, 1.0, 1.0])[stagione()]


func _process(delta: float) -> void:
	tempo += delta
	var s := stagione()
	if s != _stagione:
		_stagione = s
		cambiata.emit(s)
	_ritocco -= delta
	if _ritocco <= 0.0:
		_ritocco = 0.5
		_applica_aspetto(false)


## Mescola l'aspetto della stagione precedente con quella attuale durante il passaggio.
func _applica_aspetto(subito: bool) -> void:
	var s := stagione()
	var prima := (s + 3) % 4
	var f := 1.0 if subito else clampf(fmod(tempo, DURATA) / PASSAGGIO, 0.0, 1.0)
	if tempo < DURATA:
		f = 1.0
	var neve := lerpf(NEVE[prima], NEVE[s], f)
	if terreno and terreno.material:
		(terreno.material as ShaderMaterial).set_shader_parameter("neve", neve)
	if luce:
		luce.color = (LUCE[prima] as Color).lerp(LUCE[s], f)
	if fiocchi:
		fiocchi.emitting = neve > 0.3
	if risorse:
		var colore: Color = (FOGLIE[prima] as Color).lerp(FOGLIE[s], f)
		for c in risorse.alberi:
			for a in risorse.alberi[c]:
				if a["specie"] in SPECIE_DECIDUE and a["crescita"] >= 3.0:
					(a["sprite"] as CanvasItem).self_modulate = colore
