# I Romani giocabili (step 20)

*Piano dello step 20 (Fase 4). Stesso schema dei Brettii: vedi [`brettii.md`](brettii.md). Fonti: [`design.md`](design.md) §3, [`grafica.md`](grafica.md), campagna «La Strada fino al Mare» in [`storia.md`](storia.md).*

## Chi sono

Agrimensori, ingegneri e legionari arrivati da nord lungo la grande strada. Case di mattoni e intonaco ocra, tetti di tegole e coppi, archi, strade lastricate, cippi miliari. Colore del popolo: rosso pompeiano.

## Cosa cambia giocando con i Romani

| Cosa | Romani |
|---|---|
| Scelta | partita libera («Con chi?»: Greci, Brettii, Romani) |
| Edificio unico | **Fornace dei laterizi** (`laterizi`): argilla e tronchi → **tegole** |
| Merce speciale | **tegole**: lusso dei Romani (le case crescono più in fretta) |
| Unità | **legionario** (sprite `legionario`, `legionario_lotta`, nuovi) |
| Abilità | **strade lastricate**: i portatori camminano sempre più veloci (+15%) |
| Nemici | i **Brettii** (torri `torre_brettia`, frombolieri) |
| Aspetto | modelli `<tipo>_romani` per gli edifici principali, gli altri con l'aspetto greco |

Scelta provvisoria (vedi `DECISIONS.md`): in `design.md` l'edificio unico dei Romani era il «Cantiere stradale» e la catena speciale i laterizi; per ora l'edificio unico è la fornace dei laterizi e le strade lastricate sono un'abilità sempre attiva. Il cantiere stradale potrà arrivare con la campagna dei Romani (lastricare le strade a mano).

## Codice

- `Popoli.DATI["romani"]` con `"passo": 1.15` (moltiplica la velocità dei portatori) e `"nemici": "brettii"`.
- Catalogo: `laterizi` (`"popolo": "romani"`), merce `tegole` in `LUSSO`, colore nella barra, gruppo Lusso nel pannello del villaggio, portata come le assi.
- `ReteStrade._manda_portatore`: velocità × `Popoli.passo()`.

## Modelli 3D nuovi (subagente)

`casa_greca_romani`, `magazzino_romani`, `boscaiolo_romani`, `segheria_romani`, `cava_romani`, `guardaboschi_romani`, `pozzo_romani`, `fattoria_romani`, `mulino_romani`, `forno_romani`, `ovile_romani`, `capraio_romani`, `caserma_romani`, `castello_romani`, `torre_romani`, `laterizi`, `merce_tegole`, soldato `legionario` (camminata e lotta).

## Test

`tools/test/test_romani.gd`: aspetto romano, menu (laterizi sì, agorà e pecificio no), catena argilla → tegole, portatori più veloci, nemici brettii, legionari, salvataggio del popolo.
