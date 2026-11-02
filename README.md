# Terre di Calabria

Gioco di strategia ed economia in stile «costruisci e trasporta», ambientato nella Calabria antica e medievale.
Originale: meccaniche ispirate ai classici del genere, ma grafica, popoli, storia, musica e nomi sono nostri.

## Che cosa c'è nella versione 1.0

- **Otto popoli giocabili**, ognuno con tutti gli edifici nel suo stile e un suo vantaggio: Greci, Brettii, Romani, Saraceni, Normanni, Siculi, Sicani e Cartaginesi.
- **Quattro mappe**: Costa ionica, Monteleone (il Vibonese), Zancle e l'Etna, il Bruzio di Annibale (la Calabria centrale con la forma vera).
- **Cinque campagne**: i Greci («Le Colonne dell'Alba»), la Soglia, il fuoco sotto la montagna (Sicilia), l'ultimo canto, e «Annibale nel Bruzio», giocabile con Roma o con Cartagine. Più tre **sfide** a tempo.
- **Economia alla Settlers**: portatori sulle strade, costruttori ai cantieri, catene di produzione, stagioni, porti e navi.
- **Guerra alla Imperivm**: condottieri con le loro schiere, cibo e morale, fanteria, tiratori e cavalleria, abilità, assedi con ariete e onagro, elefanti da guerra, navi da guerra, villaggi indigeni da unire o conquistare.
- **Musica e voce originali**: quattro brani (anche di guerra) e la voce inventata di re Italo, il cantastorie.

## Installare

Dalla pagina **Releases** si scarica `TerreDiCalabria-Setup-<versione>.exe` (Windows ARM64 nativo oppure x64) e si segue il wizard.

## Per chi sviluppa

- Motore: Godot 4.7 (GDScript). Grafica generata da modelli 3D scritti in codice (`tools/studio/`), suoni e musica generati in codice (`tools/suoni/`).
- Test automatici in `tools/test/` (uno per ogni parte del gioco).
- Ogni push su `main` compila il gioco e il Setup con GitHub Actions e pubblica la Release; l'esito si legge nel ramo `ci-esito`.
- Documentazione in `docs/` (si comincia da `docs/SESSION_HANDOFF.md` e `docs/roadmap.md`).
- Idee per le versioni future (la modalità «Vita del villaggio», l'iPhone): `docs/idee-future.md`.
