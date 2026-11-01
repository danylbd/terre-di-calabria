# I Normanni giocabili (step 22)

*Piano dello step 22 (Fase 4). Stesso schema di [`brettii.md`](brettii.md), [`romani.md`](romani.md) e [`saraceni.md`](saraceni.md). Fonti: [`design.md`](design.md) §3, [`grafica.md`](grafica.md), campagna «Cento Castelli» in [`storia.md`](storia.md).*

## Chi sono

Cavalieri venuti dal nord: castelli, cavalli e stendardi. Pietra squadrata grigia, tetti di ardesia scura, torri merlate, palizzate. Colore del popolo: giallo oro.

## Cosa cambia giocando con i Normanni

| Cosa | Normanni |
|---|---|
| Scelta | partita libera («Con chi?») |
| Catena speciale | **allevamento dei cavalli**: grano e acqua → **cavalli** |
| Edificio unico | **Mastio** (difesa, taglia 3): costa anche 2 cavalli, allarga molto i confini (raggio 13) e ospita 10 soldati |
| Unità | **cavaliere pesante** (sprite `cavaliere_pesante`, `cavaliere_pesante_lotta`) |
| Abilità | **torri e castelli allargano i confini più lontano** (+2 caselle) |
| Nemici | i **Saraceni** (torri e cavalieri saraceni) |
| Aspetto | modelli `<tipo>_normanni` per gli edifici principali, gli altri con l'aspetto greco |

Anche le guardie che presidiano torri e castelli hanno ora l'aspetto del soldato del proprio popolo (prima erano sempre opliti greci).

## Codice

- `Popoli.DATI["normanni"]` con `"confini": 2`, `"nemici": "saraceni"`; `Popoli.confini()` usato in `Villaggio._ricalcola_territorio()` per gli edifici con territorio (non il magazzino).
- Catalogo: `allevamento_cavalli` (grano 2, acqua 1 → cavalli) e `mastio` (`"popolo": "normanni"`); merce `cavalli`.
- `Lavoratore`: il foglio `guardia` diventa il soldato del popolo del giocatore.

## Modelli 3D nuovi (subagente)

`casa_greca_normanni`, `magazzino_normanni`, `boscaiolo_normanni`, `segheria_normanni`, `cava_normanni`, `guardaboschi_normanni`, `pozzo_normanni`, `fattoria_normanni`, `mulino_normanni`, `forno_normanni`, `ovile_normanni`, `capraio_normanni`, `caserma_normanni`, `castello_normanni`, `torre_normanni`, `allevamento_cavalli`, `mastio`, `merce_cavalli`, soldato `cavaliere_pesante` (camminata e lotta).

## Test

`tools/test/test_normanni.gd`: aspetto normanno, menu, catena dei cavalli, mastio che costa cavalli, confini più larghi delle torri, nemici saraceni, cavalieri, salvataggio del popolo.
