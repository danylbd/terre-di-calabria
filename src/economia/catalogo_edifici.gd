class_name CatalogoEdifici
## Elenco degli edifici costruibili (Greci) con taglia, costo, categoria e descrizione.
## taglia = lato dell'impronta in caselle: 1 (pozzo), 2 (la maggior parte), 3 (magazzino).

const CATEGORIE := ["Base", "Cibo", "Metallo", "Difesa"]

const EDIFICI := {
	"casa_greca": {"nome": "Abitazione", "taglia": 2, "costo": {"assi": 2, "pietra": 2}, "categoria": "Base",
		"tempo": 20.0, "descrizione": "Fa crescere il villaggio con nuovi coloni."},
	"boscaiolo": {"nome": "Boscaiolo", "taglia": 2, "costo": {"assi": 2}, "categoria": "Base",
		"tempo": 16.0, "lavoratore": "lavoratore_ascia", "produce": "tronchi",
		"descrizione": "Abbatte gli alberi vicini e porta i tronchi."},
	"guardaboschi": {"nome": "Guardaboschi", "taglia": 2, "costo": {"assi": 2}, "categoria": "Base",
		"tempo": 16.0, "lavoratore": "lavoratore_pala",
		"descrizione": "Pianta nuovi alberi, così il bosco non finisce."},
	"segheria": {"nome": "Segheria", "taglia": 2, "costo": {"assi": 2, "pietra": 2}, "categoria": "Base",
		"tempo": 24.0, "lavoratore": "portatore_nessuno", "ingressi": {"tronchi": 4}, "produce": "assi",
		"descrizione": "Taglia i tronchi e ne ricava assi."},
	"cava": {"nome": "Cava di pietra", "taglia": 2, "costo": {"assi": 2}, "categoria": "Base",
		"tempo": 16.0, "lavoratore": "lavoratore_piccone", "produce": "pietra",
		"descrizione": "Estrae pietra dalle rocce vicine."},
	"magazzino": {"nome": "Magazzino", "taglia": 3, "costo": {"assi": 6, "pietra": 6}, "categoria": "Base",
		"tempo": 40.0, "descrizione": "Custodisce le merci. I portatori partono da qui."},
	"pozzo": {"nome": "Pozzo", "taglia": 1, "costo": {"pietra": 2}, "categoria": "Cibo",
		"tempo": 12.0, "lavoratore": "portatore_nessuno", "produce": "acqua",
		"descrizione": "Acqua per il forno e per il bestiame."},
	"fattoria": {"nome": "Fattoria", "taglia": 2, "costo": {"assi": 3, "pietra": 1}, "categoria": "Cibo",
		"tempo": 20.0, "lavoratore": "lavoratore_falce", "produce": "grano",
		"descrizione": "Il contadino semina i campi di grano intorno e li miete quando sono dorati."},
	"mulino": {"nome": "Mulino", "taglia": 2, "costo": {"assi": 2, "pietra": 3}, "categoria": "Cibo",
		"tempo": 24.0, "lavoratore": "portatore_nessuno", "ingressi": {"grano": 4}, "produce": "farina",
		"descrizione": "Macina il grano e ne fa farina."},
	"forno": {"nome": "Forno", "taglia": 2, "costo": {"assi": 2, "pietra": 3}, "categoria": "Cibo",
		"tempo": 24.0, "lavoratore": "portatore_nessuno", "ingressi": {"farina": 4, "acqua": 4}, "produce": "pane",
		"descrizione": "Impasta farina e acqua e cuoce il pane."},
	"porcile": {"nome": "Porcile", "taglia": 2, "costo": {"assi": 3, "pietra": 1}, "categoria": "Cibo",
		"tempo": 20.0, "lavoratore": "portatore_nessuno", "ingressi": {"grano": 2, "acqua": 2}, "produce": "maiale",
		"durata": 12.0, "descrizione": "Alleva maiali nutriti con grano e acqua."},
	"macelleria": {"nome": "Macelleria", "taglia": 2, "costo": {"assi": 2, "pietra": 2}, "categoria": "Cibo",
		"tempo": 22.0, "lavoratore": "portatore_nessuno", "ingressi": {"maiale": 2}, "produce": "carne",
		"descrizione": "Ricava carne e salumi dai maiali."},
	"ovile": {"nome": "Ovile", "taglia": 2, "costo": {"assi": 3, "pietra": 1}, "categoria": "Cibo",
		"tempo": 20.0, "lavoratore": "portatore_nessuno", "ingressi": {"acqua": 2}, "produce": ["latte", "lana"],
		"durata": 10.0, "descrizione": "Le pecore danno latte e lana. Bevono molto."},
	"capraio": {"nome": "Capraio", "taglia": 2, "costo": {"assi": 2, "pietra": 1}, "categoria": "Cibo",
		"tempo": 18.0, "lavoratore": "portatore_nessuno", "produce": "latte", "durata": 12.0,
		"descrizione": "Le capre si arrangiano da sole e danno latte."},
	"apiario": {"nome": "Apiario", "taglia": 2, "costo": {"assi": 2}, "categoria": "Cibo",
		"tempo": 16.0, "lavoratore": "portatore_nessuno", "produce": "miele", "durata": 14.0,
		"descrizione": "Le arnie danno miele dai fiori dei prati."},
	"caseificio": {"nome": "Caseificio", "taglia": 2, "costo": {"assi": 2, "pietra": 2}, "categoria": "Cibo",
		"tempo": 22.0, "lavoratore": "portatore_nessuno", "ingressi": {"latte": 4}, "produce": "formaggio",
		"descrizione": "Fa il formaggio con il latte di pecore e capre."},
	"pescatore": {"nome": "Pescatore", "taglia": 2, "costo": {"assi": 2}, "categoria": "Cibo",
		"tempo": 16.0, "lavoratore": "lavoratore_canna", "produce": "pesce",
		"descrizione": "Pesca dalla riva. Il pesce finisce e torna col tempo: costruiscilo vicino al mare."},
	"frantoio": {"nome": "Frantoio", "taglia": 2, "costo": {"assi": 2, "pietra": 2}, "categoria": "Cibo",
		"tempo": 24.0, "descrizione": "Spreme le olive e produce olio."},
	"torre": {"nome": "Torre di guardia", "taglia": 2, "costo": {"assi": 2, "pietra": 4}, "categoria": "Difesa",
		"tempo": 30.0, "territorio": 7, "descrizione": "Allarga i confini del territorio."},
}

const NOMI_RISORSE := {"tronchi": "Tronchi", "assi": "Assi", "pietra": "Pietra", "grano": "Grano",
	"farina": "Farina", "acqua": "Acqua", "pane": "Pane", "pesce": "Pesce", "maiale": "Maiali", "carne": "Carne",
	"latte": "Latte", "lana": "Lana", "formaggio": "Formaggio", "miele": "Miele"}
## merci sempre visibili nella barra delle scorte (le altre compaiono quando ce ne sono)
const RISORSE_BASE := ["tronchi", "assi", "pietra"]


static func dati(tipo: String) -> Dictionary:
	return EDIFICI[tipo]


static func della_categoria(cat: String) -> Array:
	var r := []
	for k in EDIFICI:
		if EDIFICI[k]["categoria"] == cat:
			r.append(k)
	return r


## Le merci che un edificio produce (alcuni ne fanno più d'una, a turno).
static func prodotti(tipo: String) -> Array:
	var p = EDIFICI[tipo].get("produce", [])
	return p if p is Array else [p]


static func testo_costo(tipo: String) -> String:
	var parti := []
	var c: Dictionary = EDIFICI[tipo]["costo"]
	for r in c:
		parti.append("%d %s" % [c[r], NOMI_RISORSE[r].to_lower()])
	return ", ".join(parti)
