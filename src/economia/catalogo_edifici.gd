class_name CatalogoEdifici
## Elenco degli edifici costruibili (Greci) con taglia, costo, categoria e descrizione.
## taglia = lato dell'impronta in caselle: 1 (pozzo), 2 (la maggior parte), 3 (magazzino).

const CATEGORIE := ["Base", "Cibo", "Metallo", "Difesa"]

const EDIFICI := {
	"casa_greca": {"nome": "Abitazione", "taglia": 2, "costo": {"assi": 2, "pietra": 2}, "categoria": "Base",
		"tempo": 20.0, "descrizione": "Fa crescere il villaggio con nuovi coloni."},
	"boscaiolo": {"nome": "Boscaiolo", "taglia": 2, "costo": {"assi": 2}, "categoria": "Base",
		"tempo": 16.0, "descrizione": "Abbatte gli alberi vicini e porta i tronchi."},
	"guardaboschi": {"nome": "Guardaboschi", "taglia": 2, "costo": {"assi": 2}, "categoria": "Base",
		"tempo": 16.0, "descrizione": "Pianta nuovi alberi, così il bosco non finisce."},
	"segheria": {"nome": "Segheria", "taglia": 2, "costo": {"assi": 2, "pietra": 2}, "categoria": "Base",
		"tempo": 24.0, "descrizione": "Taglia i tronchi e ne ricava assi."},
	"cava": {"nome": "Cava di pietra", "taglia": 2, "costo": {"assi": 2}, "categoria": "Base",
		"tempo": 16.0, "descrizione": "Estrae pietra dalle rocce vicine."},
	"magazzino": {"nome": "Magazzino", "taglia": 3, "costo": {"assi": 6, "pietra": 6}, "categoria": "Base",
		"tempo": 40.0, "descrizione": "Custodisce le merci. I portatori partono da qui."},
	"pozzo": {"nome": "Pozzo", "taglia": 1, "costo": {"pietra": 2}, "categoria": "Cibo",
		"tempo": 12.0, "descrizione": "Acqua per il forno e per il bestiame."},
	"frantoio": {"nome": "Frantoio", "taglia": 2, "costo": {"assi": 2, "pietra": 2}, "categoria": "Cibo",
		"tempo": 24.0, "descrizione": "Spreme le olive e produce olio."},
	"torre": {"nome": "Torre di guardia", "taglia": 2, "costo": {"assi": 2, "pietra": 4}, "categoria": "Difesa",
		"tempo": 30.0, "territorio": 7, "descrizione": "Allarga i confini del territorio."},
}

const NOMI_RISORSE := {"tronchi": "Tronchi", "assi": "Assi", "pietra": "Pietra"}


static func dati(tipo: String) -> Dictionary:
	return EDIFICI[tipo]


static func della_categoria(cat: String) -> Array:
	var r := []
	for k in EDIFICI:
		if EDIFICI[k]["categoria"] == cat:
			r.append(k)
	return r


static func testo_costo(tipo: String) -> String:
	var parti := []
	var c: Dictionary = EDIFICI[tipo]["costo"]
	for r in c:
		parti.append("%d %s" % [c[r], NOMI_RISORSE[r].to_lower()])
	return ", ".join(parti)
