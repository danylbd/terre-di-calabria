# Passaggio di consegne tra sessioni

**Aggiornamento 2026-11-07 — step 54 pubblicato come v1.1.1; step 55 verificato per v1.1.2.** Repository `danylbd/terre-di-calabria`. La release v1.1.1 è verificata e scaricabile: [release v1.1.1](https://github.com/danylbd/terre-di-calabria/releases/tag/v1.1.1).

**Step 55 — worktree `C:\Users\User\Projects\tdc-wt\step-55-completamento`, ramo `step-55-completamento`.** Correzioni confermate per menu Costruisci, nomi dei luoghi al passaggio del mouse, costruzione senza spazio per bandierina, fusioni stradali e passaggi nel bosco. L'audit economia ha corretto la capienza: solo magazzini completati aggiungono 200 posti. Il proprietario ha scelto l'opzione 1 per i personaggi C10: otto popoli civili, otto tipi militari, atlanti 4×8 celle a 160 px, marcia e combattimento. Importazione Godot, screenshot runtime e tutte le 52 suite passano. Il merge su `main` avvia il workflow che esporta e pubblica il Setup v1.1.2; prima di chiudere verificare run, asset e tag.

Il reference originale è in `docs/immagini/riferimento-personaggi-A-B-C.png`; il pannello destro è il C scelto dal proprietario. Gli atlas finali sono `assets/grafica/c10_portatore_*.png` e `assets/grafica/c10_soldato_*.png`; marcia e combattimento dei soldati usano i rispettivi fogli `_lotta`. Per rigenerarli eseguire `py -3 tools/grafica/prepara_atlanti_c10.py`.

## Correzioni emerse dalla verifica

- Le miniere di ferro erano bloccate dalle pendenze sui pendii: tolleranza aumentata; `test_metallo` conferma piazzamento, collegamento e produzione.
- I test del Bruzio, Monteleone e Zancle si aspettavano ancora le mappe 104×120 / 96×96 invece delle mappe 144×144. Aggiornate le asserzioni.
- Il test della popolazione si aspettava coloni inattivi in viaggio; ora verifica che restino nelle case.
- Il test della neve usava una conversione schermo-casella imprecisa; ora confronta le posizioni di emissione con le celle montane ammesse.
- La prova di durata si aspettava produzione continua anche con magazzino saturo; ora verifica produzione durante la partita e rispetto della capacità di 200 articoli.
- Zancle non lasciava abbastanza spazio pianeggiante e accessibile per la segheria: radura iniziale ampliata a 12 caselle.
- Il test audio si aspettava il vecchio suono generico della cava; ora controlla il suono dedicato `cava`.

**Ultimo passaggio:** rimpiazzato il rendering procedurale con i sorgenti illustrati C e aggiornato il generatore affinché non li sovrascriva. Import Godot, preview alla scala di gioco, controllo degli atlas e screenshot OpenGL in scena completati; restano le varianti di beni/utensili e l'audit finale. Nessuna release pubblicata per lo step 55.

Storico in [`diario-automatico.md`](diario-automatico.md).
