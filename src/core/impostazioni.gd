class_name Impostazioni
## Scelte fatte nel menu iniziale per la prossima partita.

const MODALITA := {
	"pace": ["Solo pace", "Costruisci e fai crescere il villaggio: nessun nemico."],
	"pace_poi_guerra": ["Pace, poi guerra", "Prima l'economia; quando il villaggio è cresciuto i Brettii dichiarano guerra."],
	"guerra": ["Solo guerra", "I Brettii sono ostili fin dall'inizio: dopo pochi minuti attaccano."],
}

static var modalita := "pace_poi_guerra"
## missione della campagna da giocare ("" = partita libera)
static var missione := ""
