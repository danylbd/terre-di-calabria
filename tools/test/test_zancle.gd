extends "res://tools/test/test_catena.gd"
## Test automatico dello step 25 (mappa «Zancle e l'Etna»): la catena di test_catena giocata in Sicilia;
## poi la forma della mappa (lo Stretto stretto tra Capo Peloro e Scilla, il mare a est, l'Etna innevato
## con la terra nera, Taormina sul mare, Milazzo sulla penisola) e il salvataggio della mappa.
## Uso: godot --headless --path . --script tools/test/test_zancle.gd

const FILE := "user://test_zancle.json"

var _controllata := false


func _initialize() -> void:
	Impostazioni.mappa = "zancle"
	Impostazioni.modalita = "pace"
	Impostazioni.missione = ""
	Impostazioni.popolo = "greci"
	super._initialize()


func _fine() -> void:
	if _controllata:
		return
	_controllata = true
	var d: DatiMappa = p.dati
	var T := DatiMappa.Terreno
	_controlla(p.mappa == "zancle" and d.larghezza == 144 and d.altezza == 144, "si gioca sulla mappa di Zancle ampliata 144×144")
	_controlla(d.tipo(60, 60) == T.ACQUA and d.tipo(50, 90) == T.ACQUA, "a est e a sud-est c'è il mar Ionio")
	_controlla(d.tipo(10, 80) != T.ACQUA and d.tipo(85, 20) != T.ACQUA, "a ovest la Sicilia, a est la Calabria")
	var stretto := 0
	for x in range(64, 76):
		if d.tipo(x, 8) == T.ACQUA:
			stretto += 1
	_controlla(stretto >= 2 and stretto <= 8, "lo Stretto è stretto tra Capo Peloro e Scilla (%d caselle di mare)" % stretto)
	var etna: Vector2i = d.luoghi["Etna"]
	_controlla(d.quota(etna.x, etna.y) > 225.0 and d.tipo(etna.x + 5, etna.y) in [T.TERRA, T.NEVE, T.ROCCIA],
		"l'Etna è alto e innevato, con la terra nera sui fianchi (quota %.0f)" % d.quota(etna.x, etna.y))
	var taormina: Vector2i = d.luoghi["Taormina"]
	_controlla(d.tipo(taormina.x, taormina.y) != T.ACQUA and _mare_vicino(d, taormina, 4), "Taormina è sul mare")
	var milazzo: Vector2i = d.luoghi["Milazzo"]
	_controlla(d.tipo(milazzo.x, milazzo.y) != T.ACQUA and _mare_vicino(d, milazzo, 3), "Milazzo sta sulla sua penisola")
	_controlla(d.villaggio == d.luoghi["Zancle"] and d.tipo(d.villaggio.x, d.villaggio.y) != T.ACQUA, "il villaggio nasce a Zancle")
	_controlla(Salvataggio.salva(p, FILE) and Salvataggio.mappa_di(FILE) == "zancle", "il salvataggio ricorda la mappa di Zancle")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(FILE))
	Impostazioni.mappa = "costa_ionica"
	super._fine()


func _mare_vicino(d: DatiMappa, c: Vector2i, r: int) -> bool:
	for y in range(c.y - r, c.y + r + 1):
		for x in range(c.x - r, c.x + r + 1):
			if d.dentro(x, y) and d.tipo(x, y) == DatiMappa.Terreno.ACQUA:
				return true
	return false
