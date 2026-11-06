# Passaggio di consegne tra sessioni

**Aggiornamento 2026-11-06 — step 54, test completati, release v1.1.1 da pubblicare.** Repository `danylbd/terre-di-calabria`. Le foto hanno guidato le correzioni al piazzamento, alle bandierine visibili, al menu Costruisci e all'area edificabile. Gli ingressi liberi si cercano lungo il perimetro; le bandierine restano invisibili fuori dallo strumento Collegamento; il menu si richiude; il raggio del magazzino iniziale è 13 e quello delle torri 9, con confini sbloccati solo dalla guardia. Portatori/lavoratori sono alla scala 0.58, guardie 0.72; atlanti con vestiario differenziato, animazione utensili e salvataggi che preservano ingressi, rete e territorio. Tutte le 49 suite, import Godot e screenshot visuale sono verificati. Restano commit, merge, push e controllo GitHub Actions/release. La v1.1.0 è la release stabile precedente.

## Correzioni emerse dalla verifica

- Le miniere di ferro erano bloccate dalle pendenze sui pendii: tolleranza aumentata; `test_metallo` conferma piazzamento, collegamento e produzione.
- I test del Bruzio, Monteleone e Zancle si aspettavano ancora le mappe 104×120 / 96×96 invece delle mappe 144×144. Aggiornate le asserzioni.
- Il test della popolazione si aspettava coloni inattivi in viaggio; ora verifica che restino nelle case.
- Il test della neve usava una conversione schermo-casella imprecisa; ora confronta le posizioni di emissione con le celle montane ammesse.
- La prova di durata si aspettava produzione continua anche con magazzino saturo; ora verifica produzione durante la partita e rispetto della capacità di 200 articoli.
- Zancle non lasciava abbastanza spazio pianeggiante e accessibile per la segheria: radura iniziale ampliata a 12 caselle.
- Il test audio si aspettava il vecchio suono generico della cava; ora controlla il suono dedicato `cava`.

**Ultimo passaggio:** suites verdi e correzione della serializzazione della rete/territorio; in corso la preparazione della release v1.1.1.

Storico in [`diario-automatico.md`](diario-automatico.md).
