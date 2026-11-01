# La campagna finale «La Soglia» (step 23)

*Piano dello step 23 (Fase 4). Storia in [`storia.md`](storia.md) («La campagna finale», «La rivelazione», «I due finali»).*

## Come si gioca

- Si apre dalla mappa della Calabria con il pulsante **«La Soglia»** (sull'istmo), dopo aver finito la campagna dei Greci («La voce del mare»).
- Alla prima missione si **sceglie il popolo** protagonista tra i cinque; la scelta vale per tutta la campagna (salvata con i progressi).
- Si gioca sulla **mappa di Monteleone**, che guarda la Soglia (il golfo di Sant'Eufemia, l'Angitola, le Serre).
- Quattro missioni, senza limite di tempo:

| # | id | Titolo | Obiettivi |
|---|---|---|---|
| 1 | `soglia_velo` | Il velo sulla Soglia | arrivano i coloni; 60 coloni; una torre presidiata. Compare il Mercante senza Volto |
| 2 | `soglia_frammenti` | Cinque frammenti, cinque popoli | vicini ostili; un castello (o il mastio) finito; 100 coloni |
| 3 | `soglia_scelta` | Unire o conquistare | **la scelta**: *unire* (mettere da parte 12 merci di lusso da donare) **oppure** *conquistare* (prendere una torre nemica): vale il primo dei due raggiunto |
| 4 | `soglia_sigillo` | Il Sigillo ricomposto | 120 coloni; 2 forti presidiati. Finale secondo la scelta: **Unione** (il Mercante libero, Rocco svela chi è) o **Conquista** (il velo passa su un nuovo volto) |

## Codice

- `Missione.CAMPAGNA_SOGLIA`, missioni nuove in `Missione.MISSIONI` con `"popolo": "scelto"` e `"mappa": "monteleone"`.
- Progressi (`user://campagna.json`): oltre a `completate`, `popolo_soglia` e `finale` (`unione` / `conquista`).
- Prove nuove: `lusso` (somma delle merci di lusso in magazzino), `conquiste` (torri nemiche in meno rispetto all'inizio), `una_tra` (la prima di più prove; ognuna può avere `"scelta"` che fissa il finale), `forti` (forti presidiati).
- Il racconto di chiusura dell'ultima missione è `fine_unione` o `fine_conquista`.
- `partita._popolo_da_usare()`: con una missione `"popolo": "scelto"` usa `Missione.popolo_soglia()`.
- `mappa_calabria.gd`: pulsante «La Soglia» e pannello di scelta del popolo.

## Test

`tools/test/test_soglia.gd`: sblocco dopo la campagna dei Greci, scelta del popolo che vale per tutta la campagna, mappa di Monteleone, la scelta «unire» e «conquistare» che fissa il finale giusto, il racconto di chiusura corrispondente.
