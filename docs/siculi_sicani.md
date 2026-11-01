# Siculi e Sicani, i popoli della Sicilia (step 26)

*Piano dello step 26 (Fase 6). Stesso schema dei popoli calabresi: vedi [`brettii.md`](brettii.md). Fonte: «Il seguito in Sicilia» in [`storia.md`](storia.md).*

## Chi sono

- **Siculi** — pastori e vasai dell'interno della Sicilia orientale (le tombe a grotticella di Pantalica, i villaggi sulle alture). Capanne ovali di pietra e argilla con tetti di frasche e canne, recinti di pietra a secco, grandi giare dipinte, forni da vasaio. Colore del popolo: ocra rossa.
- **Sicani** — gente delle montagne della Sicilia occidentale: villaggi arroccati, case di pietra grigia a secco con tetti di lastre di pietra e terra, terrazzamenti, cave e lame di ossidiana portata dalle Eolie. Colore del popolo: blu lapislazzuli.

## Cosa cambia giocando con loro

| Cosa | Siculi | Sicani |
|---|---|---|
| Edificio unico | **Bottega del vasaio** (`vasaio`): argilla e tronchi → **ceramiche** | **Laboratorio dell'ossidiana** (`ossidiana`): pietra → **lame di ossidiana** |
| Merce speciale | **ceramiche**: lusso (le case crescono più in fretta) | **lame di ossidiana**: lusso |
| Unità | guerriero siculo (`guerriero_siculo`) con lancia e scudo rotondo | arciere sicano (`arciere_sicano`) |
| Abilità | **pastori**: ovile, capraio, porcile e caseificio lavorano più in fretta (tempo ×0,8) | **montanari**: cava e miniere lavorano più in fretta (tempo ×0,8) |
| Nemici | i Sicani | i Siculi |
| Aspetto | `<tipo>_siculi` | `<tipo>_sicani` |

## Codice

- `Popoli.DATI["siculi"]`, `Popoli.DATI["sicani"]` con `"svelti": [mestieri]`; `Popoli.durata(mestiere)` moltiplica il tempo di lavoro in `Lavoratore`.
- Catalogo: `vasaio` e `ossidiana` con `"popolo"`; merci `ceramiche` e `lame` in `LUSSO`.

## Modelli 3D (due subagenti, uno dopo l'altro)

Per ognuno dei due popoli: `casa_greca_<p>`, `magazzino_<p>`, `boscaiolo_<p>`, `segheria_<p>`, `cava_<p>`, `guardaboschi_<p>`, `pozzo_<p>`, `fattoria_<p>`, `mulino_<p>`, `forno_<p>`, `ovile_<p>`, `capraio_<p>`, `caserma_<p>`, `castello_<p>`, `torre_<p>`, più l'edificio unico, la merce e il soldato.

## Test

`tools/test/test_sicilia_popoli.gd`: per tutti e due: aspetto, menu con l'edificio unico, catena della merce speciale, mestieri più svelti, nemici l'uno dell'altro, soldati, salvataggio.
