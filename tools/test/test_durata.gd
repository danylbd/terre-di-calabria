extends "res://tools/test/test_catena.gd"
## Test automatico dello step V3 (partite senza fine): sulla mappa di Monteleone costruisce la catena
## del legno e della pietra più alcune abitazioni, poi fa correre il tempo molto in fretta (ore di gioco
## in pochi minuti) e controlla che niente cresca senza limite: nodi, oggetti, merci in viaggio,
## registro della produzione, memoria. Alla fine la partita deve ancora produrre.
## Uso: godot --headless --path . --script tools/test/test_durata.gd  (ORE=n per la durata in ore di gioco, 1,5 di serie: circa 6 minuti)

const VELOCITA_DURATA := 16.0
const CAMPIONE := 60.0              # secondi di gioco tra una misura e l'altra

var _misure := []


func _initialize() -> void:
	Impostazioni.mappa = "monteleone"
	Impostazioni.modalita = "pace"
	Impostazioni.missione = ""
	super._initialize()


func _prova() -> void:
	await process_frame
	var v: Villaggio = p.villaggio
	var ris: RisorseNaturali = p.risorse
	var mag: Edificio = v.magazzino()
	var bosc := _piazza("boscaiolo", func(f): return _conta_vicini(ris.alberi, f, 7))
	var bosc2 := _piazza("boscaiolo", func(f): return _conta_vicini(ris.alberi, f, 7))
	var cava := _piazza("cava", func(f): return _conta_vicini(ris.rocce, f, 7))
	var seg := _piazza("segheria", func(f): return -Vector2(f - mag.bandiera).length())
	var guard := _piazza("guardaboschi", func(f): return -Vector2(f - bosc.bandiera).length())
	_piazza("guardaboschi", func(f): return -Vector2(f - bosc2.bandiera).length())
	var pozzo := _piazza("pozzo", func(f): return -Vector2(f - mag.bandiera).length())
	for k in 3:
		_piazza("casa_greca", func(f): return -Vector2(f - mag.bandiera).length())
	for e in [bosc, bosc2, cava, seg, guard, pozzo]:
		_controlla(e != null, "edificio piazzato")
	var ore := float(OS.get_environment("ORE")) if OS.get_environment("ORE") != "" else 1.5
	var campioni := int(ore * 3600.0 / CAMPIONE)
	Engine.time_scale = VELOCITA_DURATA
	var t0 := Time.get_ticks_msec()
	for k in campioni:
		await create_timer(CAMPIONE).timeout
		_misura(k)
	Engine.time_scale = 1.0
	var reale := (Time.get_ticks_msec() - t0) / 1000.0
	print("Tempo reale: %.0f s per %.1f ore di gioco" % [reale, ore])
	_controlla_crescita()
	_fine_durata()


func _misura(k: int) -> void:
	var m := {
		"nodi": Performance.get_monitor(Performance.OBJECT_NODE_COUNT),
		"oggetti": Performance.get_monitor(Performance.OBJECT_COUNT),
		"memoria": Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0,
		"merci": p.logistica.merci.size(),
		"storia": p.logistica.storia.size(),
		"popolazione": p.villaggio.popolazione(),
		"assi": p.villaggio.scorte.get("assi", 0),
	}
	_misure.append(m)
	if k % 10 == 0:
		print("min %3d  %s" % [k + 1, m])


## Dalla metà alla fine della partita nodi, oggetti e memoria non devono crescere più di poco.
func _controlla_crescita() -> void:
	var meta: Dictionary = _misure[_misure.size() / 2]
	var fine: Dictionary = _misure[-1]
	for chiave in ["nodi", "oggetti", "memoria"]:
		_controlla(fine[chiave] <= meta[chiave] * 1.25 + 50, "%s stabili (%.0f a metà, %.0f alla fine)" % [chiave, meta[chiave], fine[chiave]])
	_controlla(fine["merci"] < 200, "le merci in viaggio non si accumulano (%d)" % fine["merci"])
	_controlla(fine["storia"] < 2000, "il registro della produzione resta corto (%d)" % fine["storia"])


func _fine_durata() -> void:
	for e in p.villaggio.edifici.values():
		var l = e.lavoratore
		print("  %s %s lavoratore=%s prodotti=%d ingresso=%s" % [e.tipo, e.casella, "nessuno" if l == null else Lavoratore.Stato.keys()[l.stato], e.prodotti, e.ingresso])
	print("  alberi %d (alberelli %d), riserva rocce %d, scorte %s" % [p.risorse.alberi.size(), _alberelli(), _riserva_rocce(), p.villaggio.scorte])
	var prod: int = p.logistica.storia.size()
	_controlla(prod > 0, "dopo ore di gioco si produce ancora (%d merci negli ultimi 5 minuti)" % prod)
	super._fine()
