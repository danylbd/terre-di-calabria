# Stato dello sviluppo

*Aggiornato il 2026-11-05. Fonte del piano completo: [`roadmap.md`](roadmap.md); richieste del proprietario: [`decisioni.md`](decisioni.md).*

## Versione in preparazione

**v1.1.0 — Fase 8 «Rifiniture alla Settlers»**, step 43–53: implementata sul branch `feature/fase-8-rifiniture`. La versione 1.0.0 resta in `main` fino alla pubblicazione della nuova release. La release 1.1.0 non è pronta finché GitHub Actions non termina con successo e il Setup non è visibile nella pagina Release.

## Richieste incluse

- Interfaccia a schermo intero; menu costruzione e legenda richiudibili; nome del villaggio modificabile; zoom regolabile; menu Esc con salvataggio e impostazioni audio.
- Strumento «Collegamento» per le strade; bandierine nascoste dopo la connessione; priorità dei materiali, stop produzione e rimborso metà materiali demolendo.
- Merci di produzione mostrate in ordine fuori dagli edifici fino a 50; arresto a scorta piena; magazzini da 200 articoli, uno ogni 50 coloni.
- Abitazioni con comignoli/fumo; coloni animati, gli inattivi assegnati alle case; casa dei pionieri, avamposti, torre da due soldati, confini sbloccati all'arrivo dei soldati.
- Mappe 144×144 con camera ai bordi; costruzioni in montagna limitate a miniere, cava e torri; rovine e dettagli ambientali; neve emessa solo su celle montane.
- Raccoglitore di porcini; stagione di un'ora; suoni dedicati per segheria e cava; tintura sabbia e nomi alleati visibili al passaggio.
- Agorà con vendita/acquisto, ducati e costruzioni speciali; salvataggio compatibile conservato agli aggiornamenti; più spazio costruibile e partita pacifica con rovine esplorabili e ricompense.

## Verifica

Tutte le **48 suite** in `tools/test/` sono state eseguite in Godot 4.7.2 e hanno stampato `RISULTATO: OK`. La suite di durata ha simulato 1,5 ore; ha verificato stabilità di nodi, oggetti e memoria, produzione durante la partita, merci in viaggio e rispetto della capienza del magazzino. `git diff --check` e import Godot sono passati. L'export locale non è disponibile perché mancano i template Windows; GitHub Actions scarica i template e compilerà entrambi i pacchetti al push su `main`. Prossimo: commit, merge `--no-ff`, push e verifica della Release v1.1.0.

## Versione pubblicata precedente

**v1.0.0**. Contenuto e storia delle fasi precedenti sono in [`roadmap.md`](roadmap.md) e [`diario-automatico.md`](diario-automatico.md). La modalità «Vita del villaggio» e l'esportazione iPhone restano idee future in [`idee-future.md`](idee-future.md).
