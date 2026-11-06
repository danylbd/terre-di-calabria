# Stato dello sviluppo

*Aggiornato il 2026-11-06. Fonte del piano completo: [`roadmap.md`](roadmap.md); richieste del proprietario: [`decisioni.md`](decisioni.md).*

## Versione in preparazione

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
