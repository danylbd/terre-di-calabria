class_name Popoli
## I popoli giocabili (Fase 4): nome, nemici, soldati, passo dei portatori e aspetto degli edifici.
## Vedi docs/brettii.md, docs/romani.md, docs/saraceni.md, docs/normanni.md e docs/siculi_sicani.md.

const DATI := {
	"greci": {"nome": "Greci", "descrizione": "Città sulla costa: olio, vino e commercio all'agorà.",
		"nemici": "brettii", "soldati": ["guardia", "guardia_lotta"], "torre": "torre"},
	"brettii": {"nome": "Brettii", "descrizione": "Pastori e guerrieri della Sila: pece, frombolieri e passo svelto nei boschi.",
		"nemici": "greci", "soldati": ["brettio", "brettio_lotta"], "torre": "torre_brettia",
		"soldati_giocatore": ["brettio_giocatore", "brettio_giocatore_lotta"]},
	"romani": {"nome": "Romani", "descrizione": "Agrimensori e legionari: laterizi, tegole e strade lastricate dove si corre.",
		"nemici": "brettii", "soldati": ["legionario", "legionario_lotta"], "torre": "torre", "passo": 1.15},
	"saraceni": {"nome": "Saraceni", "descrizione": "Venuti dal mare: giardini irrigati, gelsi e seta, cavalieri leggeri.",
		"nemici": "romani", "soldati": ["cavaliere_leggero", "cavaliere_leggero_lotta"], "torre": "torre", "irriga": true},
	"normanni": {"nome": "Normanni", "descrizione": "Cavalieri del nord: cavalli, castelli e un mastio che domina la valle.",
		"nemici": "saraceni", "soldati": ["cavaliere_pesante", "cavaliere_pesante_lotta"], "torre": "torre", "confini": 2},
	"siculi": {"nome": "Siculi", "descrizione": "Pastori e vasai della Sicilia: ceramiche dipinte e greggi che rendono di più.",
		"nemici": "sicani", "soldati": ["guerriero_siculo", "guerriero_siculo_lotta"], "torre": "torre",
		"svelti": ["ovile", "capraio", "porcile", "caseificio"]},
	"sicani": {"nome": "Sicani", "descrizione": "Montanari della Sicilia: lame di ossidiana, cave e miniere più rapide.",
		"nemici": "siculi", "soldati": ["arciere_sicano", "arciere_sicano_lotta"], "torre": "torre",
		"svelti": ["cava", "miniera_ferro", "miniera_argento"]},
}
const AGILITA := 1.25               # Brettii: portatori più veloci nei boschi e in montagna
const QUOTA_MONTAGNA := 60.0
const IRRIGAZIONE := 1.5            # Saraceni: i campi vicino all'acqua crescono così più in fretta
const RAGGIO_IRRIGAZIONE := 4
const SVELTEZZA := 0.8              # Siculi e Sicani: i loro mestieri tipici lavorano in meno tempo

## popolo del giocatore nella partita in corso (lo fissa la partita all'avvio)
static var giocatore := "greci"


static func nemico() -> String:
	return DATI[giocatore]["nemici"]


## Il popolo di chi possiede un edificio o guida un soldato (1 = il giocatore, gli altri i nemici).
static func di(proprietario: int) -> String:
	return giocatore if proprietario == 1 else nemico()


static func nome(popolo: String) -> String:
	return DATI[popolo]["nome"]


static func soldati(proprietario: int) -> Array:
	var d: Dictionary = DATI[di(proprietario)]
	return d.get("soldati_giocatore", d["soldati"]) if proprietario == 1 else d["soldati"]


## Quanto più svelti camminano i portatori del giocatore ovunque (Romani: strade lastricate).
static func passo() -> float:
	return DATI[giocatore].get("passo", 1.0)


## Caselle in più di confine per torri e castelli del giocatore (Normanni).
static func confini() -> int:
	return DATI[giocatore].get("confini", 0)


## Quanto dura il lavoro di un mestiere per il popolo del giocatore (1 = come tutti).
static func durata(mestiere: String) -> float:
	return SVELTEZZA if mestiere in DATI[giocatore].get("svelti", []) else 1.0


## Il giocatore irriga i campi vicino all'acqua (Saraceni).
static func irriga() -> bool:
	return DATI[giocatore].get("irriga", false)


## Il tipo di torre che alzano i nemici.
static func torre_nemica() -> String:
	return DATI[nemico()]["torre"]


## Lo sprite di un edificio con l'aspetto del suo popolo (se il modello esiste, altrimenti quello comune).
static func sprite(tipo: String, popolo: String) -> String:
	if popolo == "greci":
		return tipo
	if popolo == "brettii" and tipo == "torre":
		return "torre_brettia"
	if ResourceLoader.exists("res://assets/grafica/%s_%s.png" % [tipo, popolo]):
		return "%s_%s" % [tipo, popolo]
	return tipo


## Un testo che nomina «i Brettii» come nemici, adattato a chi sono i nemici della partita.
static func testo(s: String) -> String:
	return s.replace("Brettii", nome(nemico())) if nemico() != "brettii" else s
