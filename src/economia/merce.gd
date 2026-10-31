class_name Merce
extends RefCounted
## Una singola merce (un tronco, un fascio di assi, una pietra, un sacco di farina...) che viaggia sulla rete stradale.

const FOGLI := {"tronchi": "portatore_tronco", "assi": "portatore_asse", "pietra": "portatore_pietra",
	"grano": "portatore_covone", "farina": "portatore_sacco", "acqua": "portatore_anfora", "pane": "portatore_cesta",
	"pesce": "portatore_pesce", "maiale": "portatore_maiale", "carne": "portatore_carne", "latte": "portatore_anfora",
	"lana": "portatore_lana", "formaggio": "portatore_formaggio", "miele": "portatore_anfora",
	"olive": "portatore_olive", "olio": "portatore_anfora", "uva": "portatore_uva", "vino": "portatore_anfora",
	"ortaggi": "portatore_ortaggi", "cipolle": "portatore_cipolle", "agrumi": "portatore_agrumi",
	"pesce_spada": "portatore_spada", "ferro": "portatore_pietra", "carbone": "portatore_carbone",
	"lingotti": "portatore_lingotti", "ascia": "portatore_attrezzi", "piccone": "portatore_attrezzi",
	"pala": "portatore_attrezzi", "falce": "portatore_attrezzi", "canna": "portatore_attrezzi",
	"sega": "portatore_attrezzi", "martello": "portatore_attrezzi", "argilla": "portatore_sacco",
	"anfore": "portatore_anfora", "sale": "portatore_sacco", "argento": "portatore_pietra", "monete": "portatore_sacco",
	"stoffa": "portatore_lana", "armi": "portatore_armi"}

var tipo := ""
var destinazione: Edificio          # dove deve arrivare
var bandiera := Vector2i.ZERO        # bandierina dove si trova ora (se non è in spalla a qualcuno)
var prenotata := false               # un portatore sta venendo a prenderla
var in_spalla := false
var sprite: Sprite2D
var origine := 0                     # id dell'edificio che l'ha prodotta (0 = uscita dal magazzino)


func _init(p_tipo: String, dest: Edificio, dove: Vector2i) -> void:
	tipo = p_tipo
	destinazione = dest
	bandiera = dove
	sprite = Sprites.crea("merce_" + p_tipo)


func foglio_portatore() -> String:
	return FOGLI.get(tipo, "portatore_nessuno")
