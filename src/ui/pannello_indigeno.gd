class_name PannelloIndigeno
extends PanelContainer
## Il pannello di un villaggio indigeno: chi sono, quanti abitanti, che cosa producono; i doni per farselo
## amico e, fuori dalla pace, l'attacco con i soldati di riserva.

var indigeni: VillaggiIndigeni
var _indice := -1
var _testo: RichTextLabel
var _dona: Button
var _conquista: Button


func _ready() -> void:
	theme = TemaGioco.crea(18)
	custom_minimum_size = Vector2(420, 0)
	visible = false
	var colonna := VBoxContainer.new()
	colonna.add_theme_constant_override("separation", 8)
	add_child(colonna)
	_testo = RichTextLabel.new()
	_testo.bbcode_enabled = true
	_testo.fit_content = true
	_testo.add_theme_color_override("default_color", Palette.INCHIOSTRO)
	colonna.add_child(_testo)
	_dona = Button.new()
	_dona.pressed.connect(func():
		indigeni.dona(_indice)
		aggiorna())
	colonna.add_child(_dona)
	_conquista = Button.new()
	_conquista.pressed.connect(func():
		indigeni.conquista(_indice)
		aggiorna())
	colonna.add_child(_conquista)
	var chiudi := Button.new()
	chiudi.text = "Chiudi"
	chiudi.pressed.connect(func(): visible = false)
	colonna.add_child(chiudi)


func mostra(i: int) -> void:
	_indice = i
	visible = true
	aggiorna()


func aggiorna() -> void:
	if _indice < 0 or _indice >= indigeni.elenco.size():
		visible = false
		return
	var v: Dictionary = indigeni.elenco[_indice]
	var tipo: Dictionary = VillaggiIndigeni.TIPI[v["tipo"]]
	var merci: Array = tipo["merci"].map(func(m): return CatalogoEdifici.NOMI_RISORSE.get(m, m).to_lower())
	var righe := ["[font_size=24][color=#7f3420]%s[/color][/font_size]" % v["nome"],
		"Villaggio di %s · %d abitanti · %s" % [tipo["nome"], v["abitanti"], VillaggiIndigeni.STATI[v["stato"]]],
		"Producono: %s" % ", ".join(merci)]
	match v["stato"]:
		"neutrale":
			righe.append("Doni ricevuti: %d su %d (merci di lusso)" % [v["doni"], indigeni.doni_necessari(_indice)])
			righe.append("Difensori: %d" % indigeni.difensori(_indice))
		"alleato":
			righe.append("Alleato: ogni minuto manda metà del raccolto al magazzino.")
		"nostro":
			righe.append("Nostro: ogni minuto manda tutto il raccolto, e i suoi confini sono nostri.")
	_testo.text = "\n".join(righe)
	_dona.visible = v["stato"] == "neutrale"
	_dona.text = "Porta i doni (merci di lusso dal magazzino)"
	var perche := indigeni.motivo_no_conquista(_indice)
	_conquista.visible = v["stato"] != "nostro" and Impostazioni.modalita != "pace"
	_conquista.disabled = perche != ""
	_conquista.text = "Conquista con %d soldati di riserva" % indigeni.villaggio.soldati if perche == "" else perche
