class_name Impostazioni
## Scelte fatte nel menu iniziale per la prossima partita.

const MODALITA := {
	"pace": ["Solo pace", "Costruisci e fai crescere il villaggio: nessun nemico."],
	"pace_poi_guerra": ["Pace, poi guerra", "Prima l'economia; quando il villaggio è cresciuto i vicini dichiarano guerra."],
	"guerra": ["Solo guerra", "I vicini sono ostili fin dall'inizio: dopo pochi minuti attaccano."],
}

static var modalita := "pace_poi_guerra"
## missione della campagna da giocare ("" = partita libera)
static var missione := ""
## mappa della partita libera (una chiave di GeneratoreMappa.MAPPE)
static var mappa := "costa_ionica"
## popolo del giocatore nella partita libera (una chiave di Popoli.DATI); la campagna è dei Greci
static var popolo := "greci"
## villaggi indigeni da unire o conquistare nella partita libera (Fase 7, step 30)
static var villaggi_indigeni := true
