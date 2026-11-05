# Passaggio di consegne tra sessioni

**Aggiornamento 2026-11-05 — Release v1.1.0 in preparazione.** Lavoro nel worktree `work/tdc-step-43`, branch `feature/fase-8-rifiniture`, repository `danylbd/terre-di-calabria`. Le richieste Fase 8, step 43–53, sono implementate; README e preset export sono aggiornati a 1.1.0. Le 48 suite Godot sono state eseguite e risultano verdi dopo aver allineato i test alle regole nuove e corretto lo spazio di costruzione nella radura di Zancle. L'export locale non parte perché mancano i template Windows di Godot; la workflow GitHub li scarica e sarà la verifica di compilazione definitiva. Prossimi passi: commit, push del branch, merge `--no-ff` su `main`, push e verifica di GitHub Actions e asset `TerreDiCalabria-Setup-1.1.0.exe` nella Release `v1.1.0`.

## Correzioni emerse dalla verifica

- Le miniere di ferro erano bloccate dalle pendenze sui pendii: tolleranza aumentata; `test_metallo` conferma piazzamento, collegamento e produzione.
- I test del Bruzio, Monteleone e Zancle si aspettavano ancora le mappe 104×120 / 96×96 invece delle mappe 144×144. Aggiornate le asserzioni.
- Il test della popolazione si aspettava coloni inattivi in viaggio; ora verifica che restino nelle case.
- Il test della neve usava una conversione schermo-casella imprecisa; ora confronta le posizioni di emissione con le celle montane ammesse.
- La prova di durata si aspettava produzione continua anche con magazzino saturo; ora verifica produzione durante la partita e rispetto della capacità di 200 articoli.
- Zancle non lasciava abbastanza spazio pianeggiante e accessibile per la segheria: radura iniziale ampliata a 12 caselle.
- Il test audio si aspettava il vecchio suono generico della cava; ora controlla il suono dedicato `cava`.

**Ultimo passaggio:** verificare `git diff --check`, esportazione locale e documenti; poi commit e rilascio GitHub. Non dichiarare la release pronta finché `ci-esito` non segnala successo e il file Setup non è presente nella release.

Storico in [`diario-automatico.md`](diario-automatico.md).
