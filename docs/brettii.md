# I Brettii giocabili (step 19)

*Piano dello step 19, prima parte della Fase 4. Fonte delle scelte di base: [`design.md`](design.md) §3.*

## Chi sono

Pastori e guerrieri delle montagne della Sila. Vivono in villaggi di pietra grezza e legno, con tetti di paglia e scandole, recinti, pelli stese e pali intagliati. Colore del popolo: verde bosco.

## Cosa cambia giocando con i Brettii

| Cosa | Greci | Brettii |
|---|---|---|
| Scelta | campagna e partita libera | partita libera (pannello «Nuova partita»: «Con chi?») |
| Edificio unico | Agorà (mercato) | **Pecificio**: cuoce i tronchi di pino e ne ricava **pece** |
| Merce speciale | olio | **pece**: un lusso dei Brettii (le case crescono più in fretta, come con vino e miele) |
| Unità | oplita (sprite `guardia`) | **fromboliere** (sprite `brettio`, già esistente) |
| Abilità | — | i portatori camminano **più veloci nei boschi e in montagna** (+25% su bosco o sopra quota 60) |
| Nemici | i Brettii (torri `torre_brettia`) | i **Greci** (torri `torre` con l'aspetto greco) |
| Aspetto degli edifici | modelli greci | modelli brettii per gli edifici principali (`<tipo>_brettii`); gli altri per ora restano con l'aspetto greco |

L'economia di base resta la stessa (stesso catalogo, stesse catene): cambiano aspetto, edificio unico, merce speciale, unità e abilità. Gli edifici con `"popolo"` nel catalogo si costruiscono solo con quel popolo (`agora`: greci, `pecificio`: brettii).

## Codice

- `src/core/popoli.gd` (`Popoli`): dati dei popoli (nome, nemici, soldati, torre nemica), `sprite(tipo, popolo)` (variante del popolo se esiste), `del_giocatore()` / `nemico()`, `testo()` per i messaggi che nominano i nemici.
- `Impostazioni.popolo` ("greci" | "brettii"); la missione della campagna forza i Greci. `partita.popolo`, salvato nel file.
- `Edificio`: sprite secondo il popolo del proprietario. `Guerra.FOGLI` secondo il popolo. `Avversario`, `Guerra`, `partita._metti_brettii`: torre nemica e nomi secondo il popolo nemico.
- `Colono`/portatori: velocità ×1,25 su bosco o quota > 60 se il giocatore è brettio.
- Catalogo: `pecificio` (ingressi tronchi 2 → pece, categoria Base), merce `pece` (portata in anfora), `pece` in `LUSSO`.
- Menu di costruzione: nasconde gli edifici di un altro popolo.

## Modelli 3D nuovi (subagente)

`casa_greca_brettii`, `magazzino_brettii`, `boscaiolo_brettii`, `segheria_brettii`, `cava_brettii`, `guardaboschi_brettii`, `pozzo_brettii`, `fattoria_brettii`, `mulino_brettii`, `forno_brettii`, `ovile_brettii`, `capraio_brettii`, `caserma_brettii`, `castello_brettii`, `pecificio`, `merce_pece`. La torre dei Brettii (`torre_brettia`) esiste già.

## Test

`tools/test/test_brettii.gd`: partita libera con i Brettii: sprite brettii sugli edifici, niente agorà nel menu ma il pecificio sì, catena tronchi → pece → case più veloci, portatori più rapidi nel bosco, nemici greci con torri greche e soldati giusti, salvataggio che ricorda il popolo.
