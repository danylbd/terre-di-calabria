class_name Colono
extends Node2D
## Un colono che cammina sulla mappa seguendo una serie di punti (coordinate di mappa)
## e poi si ferma ad aspettare.

signal arrivato(c: Colono)

var dati: DatiMappa
var velocita := 1.15                     # caselle al secondo
var agile := false                       # Brettii: più veloce nei boschi e in montagna
var pos := Vector2.ZERO                  # posizione attuale in coordinate di mappa
var _punti: Array[Vector2] = []
var _foglio := ""
var popolo := "greci"
var _anim: AnimatedSprite2D
var _dettaglio: Sprite2D
var _velocita_animazione_base := 1.15
var _fase_passo_inizializzata := false

const ICONE_CARICO := {
	"portatore_tronco": "merce_tronchi", "portatore_asse": "merce_assi", "portatore_pietra": "merce_pietra",
	"portatore_covone": "merce_grano", "portatore_sacco": "merce_farina", "portatore_anfora": "merce_anfore",
	"portatore_cesta": "merce_ceramiche", "portatore_pesce": "merce_pesce", "portatore_maiale": "merce_maiale",
	"portatore_carne": "merce_carne", "portatore_lana": "merce_lana", "portatore_formaggio": "merce_formaggio",
	"portatore_olive": "merce_olive", "portatore_uva": "merce_uva", "portatore_ortaggi": "merce_ortaggi",
	"portatore_cipolle": "merce_cipolle", "portatore_agrumi": "merce_agrumi", "portatore_spada": "merce_pesce_spada",
	"portatore_carbone": "merce_carbone", "portatore_lingotti": "merce_lingotti", "portatore_attrezzi": "merce_ascia",
	"portatore_armi": "merce_armi", "portatore_cavalli": "merce_cavalli", "portatore_elefanti": "merce_elefanti",
}
const ICONE_ATTREZZI := {
	"lavoratore_ascia": "merce_ascia", "lavoratore_pala": "merce_pala", "lavoratore_piccone": "merce_piccone",
	"lavoratore_falce": "merce_falce", "lavoratore_canna": "merce_canna", "lavoratore_martello": "merce_martello",
}


func prepara(d: DatiMappa, inizio: Vector2, foglio := "portatore_nessuno", appartenenza := "") -> void:
	dati = d
	pos = inizio
	popolo = appartenenza if appartenenza != "" else Popoli.giocatore
	_anim = AnimatedSprite2D.new()
	_anim.centered = false
	# Questi atlanti sono illustrazioni ad alta definizione, non pixel art:
	# il filtro lineare evita contorni a blocchi quando la figura è ridotta.
	_anim.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	add_child(_anim)
	imposta_foglio(foglio)
	_anim.play("S")
	_ferma()
	position = d.a_schermo(pos.x, pos.y)


func imposta_foglio(foglio: String) -> void:
	if foglio == _foglio:
		return
	var riprendi_movimento := not _punti.is_empty()
	_foglio = foglio
	var atlante := Sprites.atlante_colono(foglio, popolo)
	var anim: StringName = _anim.animation
	if anim == &"" or anim == &"default":
		anim = &"S"
	_anim.sprite_frames = Sprites.animazioni(atlante)
	_anim.animation = anim
	_anim.offset = -Sprites.ancora(atlante)
	# Le persone erano alla stessa scala delle strutture e dei mezzi: regola la sola figura,
	# lasciando invariati navi, animali e macchine da guerra.
	# La variante culturale può avere celle diverse dall'atlas generico:
	# dimensionare usando il file realmente caricato evita lavoratori giganti.
	_anim.scale = Vector2.ONE * _scala_personaggio(atlante)
	_aggiorna_dettaglio(foglio)
	if atlante.ends_with("_lotta") or riprendi_movimento:
		_anim.play(anim)
	else:
		_anim.pause()
		_anim.frame = 0


func _aggiorna_dettaglio(foglio: String) -> void:
	var icona := ""
	var attrezzo := false
	if ICONE_CARICO.has(foglio):
		icona = ICONE_CARICO[foglio]
	elif foglio.begins_with("lavoratore_"):
		for nome in ICONE_ATTREZZI:
			if foglio.begins_with(nome):
				icona = ICONE_ATTREZZI[nome]
				attrezzo = true
				break
	if _dettaglio == null:
		_dettaglio = Sprite2D.new()
		_dettaglio.centered = true
		add_child(_dettaglio)
	_dettaglio.visible = icona != "" and ResourceLoader.exists("res://assets/grafica/%s.png" % icona)
	if not _dettaglio.visible:
		return
	_dettaglio.texture = Sprites.icona(icona)
	# Le icone sono già ritagliate alla loro misura d'uso (circa 18 px): non vanno
	# ridotte di nuovo, altrimenti scompaiono alla scala effettiva dei coloni.
	_dettaglio.scale = Vector2.ONE if attrezzo else Vector2.ONE * 0.8
	_dettaglio.z_index = 1
	_dettaglio.position = Vector2(7, -18) if attrezzo else Vector2(-12, -30)


func _scala_personaggio(foglio: String) -> float:
	if foglio.begins_with("portatore_") or foglio.begins_with("lavoratore_") or foglio.begins_with("c10_portatore_"):
		var cella: Array = Sprites.info(foglio).get("cella", [96, 96])
		# I fogli ad alta definizione conservano dettaglio nelle celle grandi:
		# questa scala li mantiene leggibili senza farli prevalere sugli edifici.
		if cella.size() == 2 and int(cella[0]) >= 128:
			return 0.38
		return 0.58
	if foglio.begins_with("c10_soldato_") or foglio.begins_with("guardia") or foglio.begins_with("brettio") or foglio.begins_with("legionario") \
		or foglio.begins_with("cavaliere_") or foglio.begins_with("guerriero_") \
		or foglio.begins_with("arciere_") or foglio.begins_with("mercenario_") \
		or foglio.begins_with("condottiero_"):
		var cella_soldato: Array = Sprites.info(foglio).get("cella", [96, 96])
		if cella_soldato.size() == 2 and int(cella_soldato[0]) >= 128:
			return 0.38
		return 0.58
	return 1.0


func percorri(punti: Array[Vector2]) -> void:
	_punti = punti.duplicate()
	if _punti.size() > 0:
		_anim.play()
		# Evita che tutti i portatori inizino il passo nello stesso istante.
		# Il seme resta riproducibile per la stessa partita.
		if not _fase_passo_inizializzata:
			_anim.frame = randi_range(0, _anim.sprite_frames.get_frame_count(_anim.animation) - 1)
			_fase_passo_inizializzata = true


func in_cammino() -> bool:
	return _punti.size() > 0


func _process(delta: float) -> void:
	if _punti.is_empty():
		return
	var passo := velocita * delta
	if agile and _in_montagna():
		passo *= Popoli.AGILITA
	# Il ritmo dei passi segue la velocità effettiva (anche bonus e rallentamenti).
	_anim.speed_scale = maxf(0.1, velocita * (Popoli.AGILITA if agile and _in_montagna() else 1.0) / _velocita_animazione_base)
	while passo > 0.0 and _punti.size() > 0:
		var meta: Vector2 = _punti[0]
		var verso := meta - pos
		var dist := verso.length()
		if dist <= passo:
			pos = meta
			passo -= dist
			_punti.pop_front()
		else:
			pos += verso / dist * passo
			passo = 0.0
	var nuova := dati.a_schermo(pos.x, pos.y)
	var mov := nuova - position
	if mov.length_squared() > 0.0001:
		var nome_dir: String = Sprites.DIREZIONI[Sprites.direzione(mov)]
		if _anim.animation != nome_dir:
			var f := _anim.frame
			_anim.play(nome_dir)
			_anim.frame = f
	position = nuova
	if _punti.is_empty():
		_ferma()
		arrivato.emit(self)


func _ferma() -> void:
	_anim.pause()
	_anim.frame = 0


func _in_montagna() -> bool:
	var c := Vector2i(floori(pos.x), floori(pos.y))
	return dati.dentro(c.x, c.y) and (dati.tipo(c.x, c.y) == DatiMappa.Terreno.BOSCO or dati.quota(pos.x, pos.y) > Popoli.QUOTA_MONTAGNA)
