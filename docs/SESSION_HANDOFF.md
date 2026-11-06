# Passaggio di consegne tra sessioni

**Aggiornamento 2026-11-06 — step 54 pubblicato come v1.1.1; step 55 in corso.** Repository `danylbd/terre-di-calabria`. La release v1.1.1 è verificata e scaricabile: [release v1.1.1](https://github.com/danylbd/terre-di-calabria/releases/tag/v1.1.1).

**Step 55 — worktree `C:\Users\User\Projects\tdc-wt\step-55-menu-costruzione`, ramo `step-55-menu-costruzione` basato su main `e3cfaeb`.** Corretti riapertura fuori schermo del menu Costruisci, ciclo del passo non continuo/coloni sincronizzati e nomi dei luoghi sempre visibili. Niente merge su main né release finché il proprietario raccoglie altri bug. Test mirati `test_piazzamento_visuale.gd` e `test_coloni_dettagliati.gd` passati.

## Correzioni emerse dalla verifica

- Le miniere di ferro erano bloccate dalle pendenze sui pendii: tolleranza aumentata; `test_metallo` conferma piazzamento, collegamento e produzione.
- I test del Bruzio, Monteleone e Zancle si aspettavano ancora le mappe 104×120 / 96×96 invece delle mappe 144×144. Aggiornate le asserzioni.
- Il test della popolazione si aspettava coloni inattivi in viaggio; ora verifica che restino nelle case.
- Il test della neve usava una conversione schermo-casella imprecisa; ora confronta le posizioni di emissione con le celle montane ammesse.
- La prova di durata si aspettava produzione continua anche con magazzino saturo; ora verifica produzione durante la partita e rispetto della capacità di 200 articoli.
- Zancle non lasciava abbastanza spazio pianeggiante e accessibile per la segheria: radura iniziale ampliata a 12 caselle.
- Il test audio si aspettava il vecchio suono generico della cava; ora controlla il suono dedicato `cava`.

**Ultimo passaggio:** step 55 in lavorazione; correggere i bug raccolti, poi attendere che il proprietario completi la lista prima della prossima release.

Storico in [`diario-automatico.md`](diario-automatico.md).
