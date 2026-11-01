# Le sfide

*Dalle «Modalità libere» di [`storia.md`](storia.md). Il proprietario vuole partite senza limite di tempo: le sfide non hanno sconfitta, il cronometro segna solo il record.*

| id | Sfida | Mappa e popolo | Obiettivi |
|---|---|---|---|
| `sfida_200` | Nutri 200 abitanti | Costa ionica, popolo scelto in «Nuova partita» | 200 coloni |
| `sfida_seta` | La seta da un mare all'altro | Zancle, Saraceni | 6 matasse di seta, 3 viaggi della nave |
| `sfida_alluvione` | Sopravvivi all'alluvione | Costa ionica, popolo scelto | 8 campi → alluvione → 10 covoni |

- Menu iniziale: voce «Sfide» con il record di ognuna. Il pannello della missione mostra il tempo e il record.
- Codice: `Missione.SFIDE`, `"sfida": true`, `Missione.tempo`, `record()`, `segna_record()`, `testo_tempo()` (record nei progressi, chiave `record`); `"popolo": "libero"` = quello scelto nel menu.
- Test: `tools/test/test_sfide.gd`; il bot di `test_campagna` gioca `sfida_alluvione`.
