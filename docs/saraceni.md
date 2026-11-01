# I Saraceni giocabili (step 21)

*Piano dello step 21 (Fase 4). Stesso schema di [`brettii.md`](brettii.md) e [`romani.md`](romani.md). Fonti: [`design.md`](design.md) §3, [`grafica.md`](grafica.md), campagna «I Giardini dell'Acqua» in [`storia.md`](storia.md).*

## Chi sono

Arrivati dal mare, dal sud: ingegneri dell'acqua, giardinieri, mercanti di seta. Case di intonaco chiaro e terra cruda, terrazze piatte, cupole, archi a ferro di cavallo, giardini e canali. Colore del popolo: verde smeraldo.

## Cosa cambia giocando con i Saraceni

| Cosa | Saraceni |
|---|---|
| Scelta | partita libera («Con chi?») |
| Catena speciale | **seta**: la **bachicoltura** (gelsi e bachi) dà i **bozzoli**, la **filanda** li fila in **seta** |
| Merce speciale | **seta**: lusso dei Saraceni (le case crescono più in fretta) |
| Unità | **cavaliere leggero** (sprite `cavaliere_leggero`, `cavaliere_leggero_lotta`) |
| Abilità | **campi irrigati**: i campi a 4 caselle o meno dall'acqua crescono una volta e mezzo più in fretta |
| Nemici | i **Romani** (torri e legionari romani) |
| Aspetto | modelli `<tipo>_saraceni` per gli edifici principali, gli altri con l'aspetto greco |

Scelta provvisoria (in `DECISIONS.md`): la **noria**, edificio unico in `design.md`, per ora non c'è; l'irrigazione è un'abilità sempre attiva e la noria potrà arrivare con la campagna dei Saraceni.

## Codice

- `Popoli.DATI["saraceni"]` con `"irriga": true`, `"nemici": "romani"`; `Popoli.IRRIGAZIONE`.
- Catalogo: `bachicoltura` (produce bozzoli, senza materie prime) e `filanda` (bozzoli → seta), tutte e due `"popolo": "saraceni"`; merci `bozzoli` e `seta` (`seta` in `LUSSO`).
- `RisorseNaturali`: un campo seminato vicino all'acqua da un giocatore saraceno è `"irrigato"` e cresce più in fretta.

## Modelli 3D nuovi (subagente)

`casa_greca_saraceni`, `magazzino_saraceni`, `boscaiolo_saraceni`, `segheria_saraceni`, `cava_saraceni`, `guardaboschi_saraceni`, `pozzo_saraceni`, `fattoria_saraceni`, `mulino_saraceni`, `forno_saraceni`, `ovile_saraceni`, `capraio_saraceni`, `caserma_saraceni`, `castello_saraceni`, `torre_saraceni`, `bachicoltura`, `filanda`, `merce_bozzoli`, `merce_seta`, soldato `cavaliere_leggero` (camminata e lotta).

## Test

`tools/test/test_saraceni.gd`: aspetto saraceno, menu (bachicoltura e filanda sì, gli edifici unici degli altri no), catena bozzoli → seta, campo irrigato più veloce, nemici romani, cavalieri, salvataggio del popolo.
