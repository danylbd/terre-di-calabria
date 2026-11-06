# Passaggio di consegne tra sessioni

**Aggiornamento 2026-11-06 — step 54 completato e pubblicato come v1.1.1.** Repository `danylbd/terre-di-calabria`. Le foto hanno guidato le correzioni al piazzamento, alle bandierine visibili, al menu Costruisci e all'area edificabile. Ingressi liberi cercati lungo il perimetro; bandierine nascoste fuori dallo strumento Collegamento; menu richiudibile; raggio magazzino 13 e torri 9 con presidio; portatori/lavoratori alla scala 0.58, guardie 0.72; atlanti con vestiario differenziato e animazioni utensili. Salvataggi preservano ingressi, rete e territorio. Tutte le 49 suite, import Godot e screenshot visuale sono verificati. GitHub Actions run 137 e `ci-esito` confermano il commit `de5cb45b61310e03390d3bd187f16c34e8aa4839`; installer Setup ARM64/x64: [release v1.1.1](https://github.com/danylbd/terre-di-calabria/releases/tag/v1.1.1). La v1.1.0 è la release precedente.

## Correzioni emerse dalla verifica

- Le miniere di ferro erano bloccate dalle pendenze sui pendii: tolleranza aumentata; `test_metallo` conferma piazzamento, collegamento e produzione.
- I test del Bruzio, Monteleone e Zancle si aspettavano ancora le mappe 104×120 / 96×96 invece delle mappe 144×144. Aggiornate le asserzioni.
- Il test della popolazione si aspettava coloni inattivi in viaggio; ora verifica che restino nelle case.
- Il test della neve usava una conversione schermo-casella imprecisa; ora confronta le posizioni di emissione con le celle montane ammesse.
- La prova di durata si aspettava produzione continua anche con magazzino saturo; ora verifica produzione durante la partita e rispetto della capacità di 200 articoli.
- Zancle non lasciava abbastanza spazio pianeggiante e accessibile per la segheria: radura iniziale ampliata a 12 caselle.
- Il test audio si aspettava il vecchio suono generico della cava; ora controlla il suono dedicato `cava`.

**Ultimo passaggio:** release v1.1.1 pubblicata e verificata; asset Setup Windows ARM64/x64 disponibile su GitHub.

Storico in [`diario-automatico.md`](diario-automatico.md).
