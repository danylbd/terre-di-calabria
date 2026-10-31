extends Node
## Sistema audio del gioco (autoload "Audio"): tre canali (Musica, Effetti, Ambiente),
## effetti con varianti e posizione sulla mappa, suoni d'ambiente in loop e brani musicali
## che si passano il testimone con una dissolvenza.
## I suoni sono in res://assets/suoni (generati da tools/suoni/suoni.py), la musica in res://assets/musica.

const CARTELLA_SUONI := "res://assets/suoni/"
const CARTELLA_MUSICA := "res://assets/musica/"
const BUS := ["Musica", "Effetti", "Ambiente"]
const VOCI := 16                     # effetti che possono suonare insieme
const DISTANZA_MAX := 1800.0         # oltre questa distanza (pixel) un effetto non si sente
const DISSOLVENZA := 2.5             # secondi per il cambio di brano o d'ambiente

var _varianti := {}                  # nome -> Array[AudioStream]
var _voci: Array[AudioStreamPlayer2D] = []
var _voce_ui: AudioStreamPlayer
var _ambiente := {}                  # nome -> AudioStreamPlayer in loop
var _musica: Array[AudioStreamPlayer] = []
var _brano := ""
var _scaletta: Array[String] = []    # brani che si alternano uno dopo l'altro
var _musica_spenta := false
var _prossima := 0
var suonati := {}                    # nome -> quante volte (per i test)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for nome in BUS:
		if AudioServer.get_bus_index(nome) < 0:
			AudioServer.add_bus()
			var i := AudioServer.bus_count - 1
			AudioServer.set_bus_name(i, nome)
			AudioServer.set_bus_send(i, "Master")
	imposta_volume("Musica", 0.7)
	imposta_volume("Ambiente", 0.6)
	_carica_suoni()
	for i in VOCI:
		var v := AudioStreamPlayer2D.new()
		v.bus = "Effetti"
		v.max_distance = DISTANZA_MAX
		v.attenuation = 1.6
		add_child(v)
		_voci.append(v)
	_voce_ui = AudioStreamPlayer.new()
	_voce_ui.bus = "Effetti"
	add_child(_voce_ui)
	for i in 2:
		var m := AudioStreamPlayer.new()
		m.bus = "Musica"
		m.finished.connect(_on_brano_finito.bind(m))
		add_child(m)
		_musica.append(m)


func _carica_suoni() -> void:
	# ascia_1, ascia_2, ... diventano varianti di "ascia"
	for file in ResourceLoader.list_directory(CARTELLA_SUONI):
		if not file.ends_with(".wav"):
			continue
		var nome := file.get_basename()
		var parti := nome.rsplit("_", true, 1)
		if parti.size() == 2 and parti[1].is_valid_int():
			nome = parti[0]
		if not _varianti.has(nome):
			_varianti[nome] = []
		_varianti[nome].append(load(CARTELLA_SUONI + file))


func ha_suono(nome: String) -> bool:
	return _varianti.has(nome)


## Effetto sulla mappa in `dove` (coordinate globali): si sente più piano lontano dalla camera.
func suona_in(nome: String, dove: Vector2, volume_db := 0.0) -> void:
	var s := _scegli(nome)
	if s == null:
		return
	suonati[nome] = suonati.get(nome, 0) + 1
	var camera := get_viewport().get_camera_2d()
	if camera and camera.global_position.distance_to(dove) > DISTANZA_MAX:
		return
	var voce := _voce_libera()
	voce.stream = s
	voce.global_position = dove
	voce.volume_db = volume_db
	voce.pitch_scale = randf_range(0.93, 1.07)
	voce.play()


## Effetto d'interfaccia (clic, errori): stesso volume ovunque.
func suona(nome: String, volume_db := 0.0) -> void:
	var s := _scegli(nome)
	if s == null:
		return
	suonati[nome] = suonati.get(nome, 0) + 1
	_voce_ui.stream = s
	_voce_ui.volume_db = volume_db
	_voce_ui.play()


func _scegli(nome: String) -> AudioStream:
	var lista: Array = _varianti.get(nome, [])
	return null if lista.is_empty() else lista.pick_random()


func _voce_libera() -> AudioStreamPlayer2D:
	for i in VOCI:
		var v := _voci[(_prossima + i) % VOCI]
		if not v.playing:
			_prossima = (_prossima + i + 1) % VOCI
			return v
	# tutte occupate: si ruba la più vecchia
	var v := _voci[_prossima]
	_prossima = (_prossima + 1) % VOCI
	return v


## Accende (volume_db) o spegne (null) un suono d'ambiente in loop, con dissolvenza.
func ambiente(nome: String, volume_db: Variant = 0.0) -> void:
	var p: AudioStreamPlayer = _ambiente.get(nome)
	if volume_db == null:
		if p:
			_sfuma(p, -60.0, true)
			_ambiente.erase(nome)
		return
	if p == null:
		var s := _scegli(nome)
		if s == null:
			return
		p = AudioStreamPlayer.new()
		p.bus = "Ambiente"
		p.stream = s
		p.volume_db = -60.0
		add_child(p)
		p.play(randf() * s.get_length())
		_ambiente[nome] = p
	_sfuma(p, volume_db)


func spegni_ambiente() -> void:
	for nome in _ambiente.keys():
		ambiente(nome, null)


## Fa partire un brano (file in assets/musica senza estensione); "" ferma la musica.
func musica(nome: String) -> void:
	if nome == _brano:
		return
	_brano = nome
	var vecchio := _musica[0]
	var nuovo := _musica[1]
	_musica.reverse()
	if vecchio.playing:
		_sfuma(vecchio, -60.0, false, true)
	if nome == "":
		return
	var stream: AudioStream = null
	for est: String in ["ogg", "wav", "mp3"]:
		var percorso := CARTELLA_MUSICA + nome + "." + est
		if ResourceLoader.exists(percorso):
			stream = load(percorso)
			break
	if stream == null:
		push_warning("Brano non trovato: " + nome)
		return
	nuovo.stream = stream
	nuovo.volume_db = -60.0
	nuovo.play()
	_sfuma(nuovo, 0.0)


func brano_attuale() -> String:
	return _brano


## Suona i brani uno dopo l'altro, ricominciando dal primo; parte da uno a caso.
func scaletta(nomi: Array[String]) -> void:
	_scaletta = nomi.duplicate()
	if _brano in _scaletta:
		return
	musica(_scaletta.pick_random() if _scaletta.size() > 0 else "")


func _on_brano_finito(p: AudioStreamPlayer) -> void:
	if p != _musica[0] or _scaletta.is_empty():
		return
	var i := _scaletta.find(_brano)
	_brano = ""
	musica(_scaletta[(i + 1) % _scaletta.size()])


## Tasto M: toglie o rimette la musica (gli effetti restano).
func alterna_musica() -> bool:
	_musica_spenta = not _musica_spenta
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Musica"), _musica_spenta)
	return not _musica_spenta


## Volume lineare 0..1 di un canale ("Master", "Musica", "Effetti", "Ambiente").
func imposta_volume(bus: String, lineare: float) -> void:
	var i := AudioServer.get_bus_index(bus)
	if i >= 0:
		AudioServer.set_bus_volume_db(i, linear_to_db(maxf(lineare, 0.0001)))
		AudioServer.set_bus_mute(i, lineare <= 0.001)


func volume(bus: String) -> float:
	var i := AudioServer.get_bus_index(bus)
	return 0.0 if i < 0 else db_to_linear(AudioServer.get_bus_volume_db(i))


func _sfuma(p: AudioStreamPlayer, verso_db: float, libera := false, ferma := false) -> void:
	var prima: Tween = p.get_meta("sfumatura") if p.has_meta("sfumatura") else null
	if prima and prima.is_valid():
		prima.kill()
	var t := create_tween()
	p.set_meta("sfumatura", t)
	t.set_ignore_time_scale(true)
	t.tween_property(p, "volume_db", verso_db, DISSOLVENZA).set_trans(Tween.TRANS_SINE)
	if libera:
		t.tween_callback(p.queue_free)
	elif ferma:
		t.tween_callback(p.stop)
