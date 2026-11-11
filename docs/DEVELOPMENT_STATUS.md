# Stato dello sviluppo

*Aggiornato il 2026-11-11. Fonte del piano completo: [`roadmap.md`](roadmap.md); richieste del proprietario: [`decisioni.md`](decisioni.md).*

## Lavoro corrente — step 56, preparazione v1.1.3

Ramo `fix/bug-mercato-strade-aure`, basato sulla `main` aggiornata a `f6f70fa`. Sistemato il pulsante per comprare le merci nell'Agorà; ridotti gli artefatti delle intersezioni stradali; barra risorse posizionata dopo il menu Costruisci; anteprima dell'aura di lavoro per cava, boscaiolo e altre attività produttive; pietra più abbondante e concentrata con nuovi sprite. Import Godot 4.7.2 e `git diff --check` passati. Test automatici non eseguiti localmente; il workflow GitHub li esegue durante il rilascio.

## Storico step 55

Worktree finale `C:\Users\User\Projects\tdc-wt\step-55-completamento`, ramo `step-55-completamento`, basato sui fix step 55. Corretti e verificati menu Costruisci che si richiude e si riapre nel viewport, nomi alleati su hover, strade con innesti e passaggi sugli alberi, costruzione senza vincolo di spazio bandierina e capienza conteggiata solo per magazzini finiti. La grafica scelta dal proprietario è C10: otto popoli civili e otto tipi militari, atlas 4×8 celle da 160 px, animazioni di marcia e combattimento, filtro lineare e scala 0,38. Gli atlas PNG/JSON e i sorgenti di rigenerazione sono inclusi nel ramo; screenshot runtime OpenGL in `docs/immagini/screenshot-coloni-C10-stile-C-in-gioco.png`, `screenshot-soldati-C10-cammino-in-gioco.png` e `screenshot-soldati-C10-combattimento-in-gioco.png`. Import Godot, `git diff --check` e tutte le 52 suite automatiche sono passati; la PR verso `main` avvia la pubblicazione v1.1.2.

Per il riferimento C usare `docs/immagini/riferimento-personaggi-A-B-C.png`; il proprietario ha scelto l'opzione C10. `py -3 tools/grafica/prepara_atlanti_c10.py` ricostruisce gli atlas dai sorgenti e `py tools/grafica/contatto_atlas_c.py` genera i contact sheet. Importazione Godot, screenshot runtime e 52 suite automatiche sono verificati. La PR verso `main` farà partire il workflow di export e pubblicazione v1.1.2.

## Versione pubblicata

**v1.1.1 — correzioni da schermate reali**, step 54: pubblicata. Edifici con accesso alternativo, bandierine stradali invisibili durante il gioco, pannello Costruisci richiudibile, raggio magazzino 13 e torri 9 (con guardia), coloni e soldati proporzionati senza rimpicciolire navi/macchine; atlanti con abiti variati e animazioni di camminata/lavoro. Salvataggi aggiornati per conservare ingressi reali, rete e territorio esplorato.

Versione pubblicata precedente: [v1.1.0](https://github.com/danylbd/terre-di-calabria/releases/tag/v1.1.0), con Setup Windows ARM64/x64.

## Richieste incluse

- Interfaccia a schermo intero; menu costruzione e legenda richiudibili; nome del villaggio modificabile; zoom regolabile; menu Esc con salvataggio e impostazioni audio.
- Strumento «Collegamento» per le strade; bandierine nascoste dopo la connessione; priorità dei materiali, stop produzione e rimborso metà materiali demolendo.
- Merci di produzione mostrate in ordine fuori dagli edifici fino a 50; arresto a scorta piena; magazzini da 200 articoli, uno ogni 50 coloni.
- Abitazioni con comignoli/fumo; coloni animati, gli inattivi assegnati alle case; casa dei pionieri, avamposti, torre da due soldati, confini sbloccati all'arrivo dei soldati.
- Mappe 144×144 con camera ai bordi; costruzioni in montagna limitate a miniere, cava e torri; rovine e dettagli ambientali; neve emessa solo su celle montane.
- Raccoglitore di porcini; stagione di un'ora; suoni dedicati per segheria e cava; tintura sabbia e nomi alleati visibili al passaggio.
- Agorà con vendita/acquisto, ducati e costruzioni speciali; salvataggio compatibile conservato agli aggiornamenti; più spazio costruibile e partita pacifica con rovine esplorabili e ricompense.

## Verifica

Tutte le **49 suite** in `tools/test/` sono state eseguite in Godot 4.7.2 e hanno stampato `RISULTATO: OK`. La suite di durata ha simulato 1,5 ore; ha verificato stabilità di nodi, oggetti e memoria, produzione durante la partita, merci in viaggio e rispetto della capienza del magazzino. La nuova prova visuale controlla collasso del menu, accessi alternativi, bandierine, proporzioni e animazioni; screenshot in `docs/immagini/step54-piazzamento-coloni.png`. `git diff --check` e import Godot sono passati. GitHub Actions run **137** ha completato export x64/ARM64 e pubblicazione; l'asset `TerreDiCalabria-Setup-1.1.1.exe` (123.645.878 byte) è disponibile nella [release v1.1.1](https://github.com/danylbd/terre-di-calabria/releases/tag/v1.1.1). `ci-esito` conferma il commit `de5cb45b61310e03390d3bd187f16c34e8aa4839`.

## Versione pubblicata precedente

**v1.1.0**. Contenuto e storia delle fasi precedenti sono in [`roadmap.md`](roadmap.md) e [`diario-automatico.md`](diario-automatico.md). La modalità «Vita del villaggio» e l'esportazione iPhone restano idee future in [`idee-future.md`](idee-future.md).
