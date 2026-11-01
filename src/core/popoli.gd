class_name Popoli
## I popoli giocabili (Fase 4): nome, nemici, soldati e aspetto degli edifici. Vedi docs/brettii.md.

const DATI := {
	"greci": {"nome": "Greci", "descrizione": "Città sulla costa: olio, vino e commercio all'agorà.",
		"nemici": "brettii", "soldati": ["guardia", "guardia_lotta"], "torre": "torre"},
	"brettii": {"nome": "Brettii", "descrizione": "Pastori e guerrieri della Sila: pece, frombolieri e passo svelto nei boschi.",
		"nemici": "greci", "soldati": ["brettio", "brettio_lotta"], "torre": "torre_brettia"},
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


## Il tipo di torre che alzano i nemici.
static func torre_nemica() -> String:
	return DATI[nemico()]["torre"]


## Lo sprite di un edificio con l'aspetto del suo popolo (se il modello esiste, altrimenti quello comune).
static func sprite(tipo: String, popolo: String) -> String:
	if popolo == "brettii":
		if tipo == "torre":
			return "torre_brettia"
		if ResourceLoader.exists("res://assets/grafica/%s_brettii.png" % tipo):
			return tipo + "_brettii"
	return tipo


## Un testo che nomina «i Brettii» come nemici, adattato a chi sono i nemici della partita.
static func testo(s: String) -> String:
	return s.replace("Brettii", nome(nemico())) if nemico() != "brettii" else s
