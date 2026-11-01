# Lo Stretto: navi e porti (step 28)

*Step 28 della Fase 6.*

- **Porto** (`porto`, taglia 2, vicino al mare, per tutti i popoli): riceve le **anfore** (dalla fornace) e fa salpare una **nave a vela** (sprite `nave`, 8 direzioni × 8 fotogrammi). La nave va fino a un **altro porto del giocatore** raggiungibile per mare (per esempio dall'altra parte dello Stretto, tra Zancle e la Calabria), altrimenti **al largo**, e torna con i **ducati**.
- La rotta tra due porti si cerca casella per casella sul mare (`Lavoratore._rotta_sul_mare`), così la nave aggira i capi; al largo va dritta.
- Codice: `Lavoratore` (stato `NAVIGA`, `_salpa()`, `rotta_nave()`, `_meta_al_largo()`, foglio `nave` sull'acqua), catalogo `porto`.
- Test: `tools/test/test_stretto.gd`.
- Per il futuro: portare merci vere (non solo commercio) da un porto all'altro, e porti dei nemici.
