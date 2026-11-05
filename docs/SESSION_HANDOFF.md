# Passaggio di consegne tra sessioni

**Aggiornamento 2026-11-05 — Release v1.1.0 pubblicata.** Repository `danylbd/terre-di-calabria`, branch principale aggiornato al commit `4c0655cc5002f6b69ed0632ea54984ea4df60cfc`. Le richieste Fase 8, step 43–53, sono implementate; tutte le 48 suite Godot sono verdi. GitHub Actions run 135 è riuscita: import, export Windows x64/ARM64, Setup Inno e pubblicazione completati. Release: [v1.1.0](https://github.com/danylbd/terre-di-calabria/releases/tag/v1.1.0), asset `TerreDiCalabria-Setup-1.1.0.exe` (126.743.026 byte). L'export locale non era disponibile perché mancavano i template Windows; l'export GitHub è riuscito.

## Correzioni emerse dalla verifica

- Le miniere di ferro erano bloccate dalle pendenze sui pendii: tolleranza aumentata; `test_metallo` conferma piazzamento, collegamento e produzione.
- I test del Bruzio, Monteleone e Zancle si aspettavano ancora le mappe 104×120 / 96×96 invece delle mappe 144×144. Aggiornate le asserzioni.
- Il test della popolazione si aspettava coloni inattivi in viaggio; ora verifica che restino nelle case.
- Il test della neve usava una conversione schermo-casella imprecisa; ora confronta le posizioni di emissione con le celle montane ammesse.
- La prova di durata si aspettava produzione continua anche con magazzino saturo; ora verifica produzione durante la partita e rispetto della capacità di 200 articoli.
- Zancle non lasciava abbastanza spazio pianeggiante e accessibile per la segheria: radura iniziale ampliata a 12 caselle.
- Il test audio si aspettava il vecchio suono generico della cava; ora controlla il suono dedicato `cava`.

**Ultimo passaggio:** release e documenti verificati; non restano attività richieste per la versione 1.1.0.

Storico in [`diario-automatico.md`](diario-automatico.md).
