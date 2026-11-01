class_name Popoli
## I popoli giocabili (Fase 4): nome, nemici, soldati, passo dei portatori e aspetto degli edifici.
## Vedi docs/brettii.md e docs/romani.md.

const DATI := {
	"greci": {"nome": "Greci", "descrizione": "Città sulla costa: olio, vino e commercio all'agorà.",
		"nemici": "brettii", "soldati": ["guardia", "guardia_lotta"], "torre": "torre"},
	"brettii": {"nome": "Brettii", "descrizione": "Pastori e guerrieri della Sila: pece, frombolieri e passo svelto nei boschi.",
		"nemici": "greci", "soldati": ["brettio", "brettio_lotta"], "torre": "torre_brettia"},
	"romani": {"nome": "Romani", "descrizione": "Agrimensori e legionari: laterizi, tegole e strade lastricate dove si corre.",
		"nemici": "brettii", "soldati": ["legionario", "legionario_lotta"], "torre": "torre", "passo": 1.15},
}
const AGILITA := 1.25               # Brettii: portatori più veloci nei boschi e in montagna
const QUOTA_MONTAGNA := 60.0

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
	return DATI[di(proprietario)]["soldati"]


## Quanto più svelti camminano i portatori del giocatore ovunque (Romani: strade lastricate).
static func passo() -> float:
	return DATI[giocatore].get("passo", 1.0)


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
