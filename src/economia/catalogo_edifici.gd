class_name CatalogoEdifici
## Elenco degli edifici costruibili (Greci) con taglia, costo, categoria e descrizione.
## taglia = lato dell'impronta in caselle: 1 (pozzo), 2 (la maggior parte), 3 (magazzino).

const CATEGORIE := ["Base", "Cibo", "Metallo", "Difesa"]

const EDIFICI := {
	"casa_greca": {"nome": "Abitazione", "taglia": 2, "costo": {"assi": 2, "pietra": 2}, "categoria": "Base",
		"tempo": 20.0, "descrizione": "Fa crescere il villaggio con nuovi coloni."},
	"boscaiolo": {"nome": "Boscaiolo", "taglia": 2, "costo": {"assi": 2}, "categoria": "Base",
		"tempo": 16.0, "attrezzo": "ascia", "lavoratore": "lavoratore_ascia", "produce": "tronchi",
		"descrizione": "Abbatte gli alberi vicini e porta i tronchi."},
	"guardaboschi": {"nome": "Guardaboschi", "taglia": 2, "costo": {"assi": 2}, "categoria": "Base",
		"tempo": 16.0, "attrezzo": "pala", "lavoratore": "lavoratore_pala",
		"descrizione": "Pianta nuovi alberi, così il bosco non finisce."},
	"segheria": {"nome": "Segheria", "taglia": 2, "costo": {"assi": 2, "pietra": 2}, "categoria": "Base",
		"tempo": 24.0, "attrezzo": "sega", "lavoratore": "portatore_nessuno", "ingressi": {"tronchi": 4}, "produce": "assi",
		"descrizione": "Taglia i tronchi e ne ricava assi."},
	"cava": {"nome": "Cava di pietra", "taglia": 2, "costo": {"assi": 2}, "categoria": "Base",
		"tempo": 16.0, "attrezzo": "piccone", "lavoratore": "lavoratore_piccone", "produce": "pietra",
		"descrizione": "Estrae pietra dalle rocce vicine."},
	"magazzino": {"nome": "Magazzino", "taglia": 3, "costo": {"assi": 6, "pietra": 6}, "categoria": "Base",
		"tempo": 40.0, "descrizione": "Custodisce le merci. I portatori partono da qui."},
	"pozzo": {"nome": "Pozzo", "taglia": 1, "costo": {"pietra": 2}, "categoria": "Cibo",
		"tempo": 12.0, "lavoratore": "portatore_nessuno", "produce": "acqua",
		"descrizione": "Acqua per il forno e per il bestiame."},
	"fattoria": {"nome": "Fattoria", "taglia": 2, "costo": {"assi": 3, "pietra": 1}, "categoria": "Cibo",
		"tempo": 20.0, "attrezzo": "falce", "lavoratore": "lavoratore_falce", "produce": "grano", "coltura": "grano",
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
		"tempo": 16.0, "attrezzo": "canna", "lavoratore": "lavoratore_canna", "produce": "pesce", "vicino_mare": 5,
		"descrizione": "Pesca dalla riva. Il pesce finisce e torna col tempo: costruiscilo vicino al mare."},
	"frantoio": {"nome": "Frantoio", "taglia": 2, "costo": {"assi": 2, "pietra": 2}, "categoria": "Cibo",
		"tempo": 24.0, "lavoratore": "portatore_nessuno", "ingressi": {"olive": 4}, "produce": "olio",
		"descrizione": "Spreme le olive e produce olio."},
	"uliveto": {"nome": "Raccoglitore di olive", "taglia": 2, "costo": {"assi": 2}, "categoria": "Cibo",
		"tempo": 16.0, "attrezzo": "falce", "lavoratore": "lavoratore_falce", "produce": "olive",
		"descrizione": "Raccoglie le olive dagli ulivi vicini. Gli ulivi rimettono frutto col tempo."},
	"vigneto": {"nome": "Vigneto", "taglia": 2, "costo": {"assi": 3, "pietra": 1}, "categoria": "Cibo",
		"tempo": 20.0, "attrezzo": "falce", "lavoratore": "lavoratore_falce", "produce": "uva", "coltura": "vite",
		"descrizione": "Pianta le viti, che danno uva ogni anno."},
	"cantina": {"nome": "Cantina", "taglia": 2, "costo": {"assi": 2, "pietra": 3}, "categoria": "Cibo",
		"tempo": 24.0, "lavoratore": "portatore_nessuno", "ingressi": {"uva": 4}, "produce": "vino",
		"descrizione": "Pigia l'uva e fa il vino, merce di lusso."},
	"ortolano": {"nome": "Ortolano", "taglia": 2, "costo": {"assi": 2, "pietra": 1}, "categoria": "Cibo",
		"tempo": 18.0, "attrezzo": "falce", "lavoratore": "lavoratore_falce", "produce": ["ortaggi", "cipolle"], "coltura": "orto",
		"descrizione": "Coltiva ortaggi e cipolle rosse: cibo per i minatori."},
	"agrumeto": {"nome": "Agrumeto", "taglia": 2, "costo": {"assi": 3, "pietra": 1}, "categoria": "Cibo",
		"tempo": 20.0, "attrezzo": "falce", "lavoratore": "lavoratore_falce", "produce": "agrumi", "coltura": "agrumi",
		"descrizione": "Pianta aranci e bergamotti, che danno frutta ogni anno."},
	"pesca_spada": {"nome": "Barca del pesce spada", "taglia": 2, "costo": {"assi": 4}, "categoria": "Cibo",
		"tempo": 20.0, "attrezzo": "canna", "lavoratore": "lavoratore_canna", "produce": "pesce_spada", "vicino_mare": 5,
		"descrizione": "Esce in barca al largo per il pesce spada. Va costruita sulla costa."},
	"miniera_ferro": {"nome": "Miniera di ferro", "taglia": 2, "costo": {"assi": 4, "pietra": 1}, "categoria": "Metallo",
		"tempo": 24.0, "attrezzo": "piccone", "lavoratore": "lavoratore_piccone", "produce": "ferro", "durata": 8.0,
		"miniera": "ferro", "cibo": 4,
		"descrizione": "Scava il ferro nei monti. Va costruita sulla roccia, ai piedi della montagna. I minatori lavorano solo se mangiano (pane, pesce, carne, formaggio, ortaggi o cipolle)."},
	"carbonaia": {"nome": "Carbonaia", "taglia": 2, "costo": {"assi": 2, "pietra": 1}, "categoria": "Metallo",
		"tempo": 18.0, "lavoratore": "portatore_nessuno", "ingressi": {"tronchi": 4}, "produce": "carbone", "durata": 9.0,
		"descrizione": "Cuoce lentamente i tronchi sotto la terra e ne ricava carbone."},
	"fonderia": {"nome": "Fonderia", "taglia": 2, "costo": {"assi": 2, "pietra": 4}, "categoria": "Metallo",
		"tempo": 28.0, "lavoratore": "portatore_nessuno", "ingressi": {"ferro": 4, "carbone": 4}, "produce": "lingotti",
		"durata": 7.0, "descrizione": "Fonde il ferro con il carbone e cola i lingotti."},
	"fabbro": {"nome": "Fabbro", "taglia": 2, "costo": {"assi": 2, "pietra": 3}, "categoria": "Metallo",
		"tempo": 26.0, "attrezzo": "martello", "lavoratore": "portatore_nessuno", "ingressi": {"lingotti": 4, "assi": 2},
		"produce": "attrezzi", "durata": 8.0,
		"descrizione": "Forgia gli attrezzi dei mestieri. Fa per primi quelli che mancano."},
	"torre": {"nome": "Torre di guardia", "taglia": 2, "costo": {"assi": 2, "pietra": 4}, "categoria": "Difesa",
		"tempo": 30.0, "territorio": 7, "descrizione": "Allarga i confini del territorio."},
}

const NOMI_RISORSE := {"tronchi": "Tronchi", "assi": "Assi", "pietra": "Pietra", "grano": "Grano",
	"farina": "Farina", "acqua": "Acqua", "pane": "Pane", "pesce": "Pesce", "maiale": "Maiali", "carne": "Carne",
	"latte": "Latte", "lana": "Lana", "formaggio": "Formaggio", "miele": "Miele", "olive": "Olive", "olio": "Olio",
	"uva": "Uva", "vino": "Vino", "ortaggi": "Ortaggi", "cipolle": "Cipolle", "agrumi": "Agrumi",
	"pesce_spada": "Pesce spada", "ferro": "Ferro", "carbone": "Carbone", "lingotti": "Lingotti",
	"ascia": "Asce", "piccone": "Picconi", "pala": "Pale", "falce": "Falci", "canna": "Canne da pesca", "sega": "Seghe",
	"martello": "Martelli"}
## attrezzi dei mestieri: senza l'attrezzo in magazzino l'artigiano non arriva
const ATTREZZI := ["ascia", "piccone", "pala", "falce", "canna", "sega", "martello"]
const ATTREZZO_UNO := {"ascia": "un'ascia", "piccone": "un piccone", "pala": "una pala", "falce": "una falce",
	"canna": "una canna da pesca", "sega": "una sega", "martello": "un martello"}
## cibo che i minatori accettano (uno qualsiasi per ogni turno di lavoro)
const CIBI := ["pane", "pesce", "carne", "formaggio", "ortaggi", "cipolle"]
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


## Quante merci di un tipo può tenere un edificio per lavorare (ingressi, più il cibo per i minatori).
static func capacita(tipo: String, merce: String) -> int:
	var d: Dictionary = EDIFICI[tipo]
	var n: int = d.get("ingressi", {}).get(merce, 0)
	if d.has("cibo") and merce in CIBI:
		n += d["cibo"]
	return n


## Tutte le merci che un edificio riceve per lavorare.
static func merci_in_ingresso(tipo: String) -> Array:
	var d: Dictionary = EDIFICI[tipo]
	var r: Array = d.get("ingressi", {}).keys()
	if d.has("cibo"):
		r.append_array(CIBI)
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
