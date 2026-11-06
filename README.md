# Terre di Calabria

Gioco di strategia ed economia in stile «costruisci e trasporta», ambientato nella Calabria antica e medievale.
Originale: meccaniche ispirate ai classici del genere, ma grafica, popoli, storia, musica e nomi sono nostri.

## Versione attuale: 1.1.1

Corregge il piazzamento degli edifici vicino agli ingressi occupati, nasconde le bandierine stradali durante il gioco, richiude davvero il menu Costruisci e amplia l'area edificabile: magazzino iniziale di raggio 13 e torri di raggio 9, sempre attive solo con una guardia presente. Coloni e guardie sono ridimensionati; le animazioni e i vestiti dei lavoratori sono stati rifiniti. Il salvataggio conserva ingressi, rete stradale e territorio già esplorato.

Scarica [TerreDiCalabria-Setup-1.1.1.exe](https://github.com/danylbd/terre-di-calabria/releases/download/v1.1.1/TerreDiCalabria-Setup-1.1.1.exe) dalla [release 1.1.1](https://github.com/danylbd/terre-di-calabria/releases/tag/v1.1.1) (Windows ARM64 o x64).

## Che cosa c'è nella versione 1.1.0

- **Otto popoli giocabili**, ognuno con tutti gli edifici nel suo stile e un suo vantaggio: Greci, Brettii, Romani, Saraceni, Normanni, Siculi, Sicani e Cartaginesi.
- **Quattro mappe**: Costa ionica, Monteleone (il Vibonese), Zancle e l'Etna, il Bruzio di Annibale (la Calabria centrale con la forma vera).
- **Cinque campagne**: i Greci («Le Colonne dell'Alba»), la Soglia, il fuoco sotto la montagna (Sicilia), l'ultimo canto, e «Annibale nel Bruzio», giocabile con Roma o con Cartagine. Più tre **sfide** a tempo.
- **Economia alla Settlers**: portatori sulle strade, costruttori ai cantieri, catene di produzione, stagioni, porti e navi.
- **Guerra alla Imperivm**: condottieri con le loro schiere, cibo e morale, fanteria, tiratori e cavalleria, abilità, assedi con ariete e onagro, elefanti da guerra, navi da guerra, villaggi indigeni da unire o conquistare.
- **Musica e voce originali**: quattro brani (anche di guerra) e la voce inventata di re Italo, il cantastorie.

## Aggiornamento 1.1.0

- Interfaccia a schermo intero con menu di costruzione richiudibile, zoom, nome del villaggio modificabile e menu di pausa con controlli audio.
- Produzione più leggibile: merci visibili fuori dalle attività, limite di 50 pezzi, magazzini da 200 unità e uno ogni 50 coloni; priorità e arresto della produzione.
- Agorà con vendita e acquisto di merci, ducati e nuovi edifici speciali acquistabili.
- Pionieri, raccoglitore di porcini, rovine da esplorare e mappe più ampie.
- Torri presidiate da due soldati, stagioni di un'ora, neve limitata alle montagne e nuovi dettagli visivi e sonori.
- Nuovi coloni animati e salvataggi mantenuti quando si aggiorna il gioco.

## Installare

Dalla pagina **Releases** si scarica `TerreDiCalabria-Setup-<versione>.exe` (Windows ARM64 nativo oppure x64) e si segue il wizard.

## Per chi sviluppa

- Motore: Godot 4.7 (GDScript). Grafica generata da modelli 3D scritti in codice (`tools/studio/`), suoni e musica generati in codice (`tools/suoni/`).
- Test automatici in `tools/test/` (uno per ogni parte del gioco).
- Ogni push su `main` compila il gioco e il Setup con GitHub Actions e pubblica la Release; l'esito si legge nel ramo `ci-esito`.
- Documentazione in `docs/` (si comincia da `docs/SESSION_HANDOFF.md` e `docs/roadmap.md`).
- Idee per le versioni future (la modalità «Vita del villaggio», l'iPhone): `docs/idee-future.md`.
