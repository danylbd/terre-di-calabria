# La campagna «Il fuoco sotto la montagna» (step 27)

*Piano dello step 27 (Fase 6). Storia in [`storia.md`](storia.md), «Il seguito in Sicilia».*

- Si apre dalla mappa della Calabria con il pulsante **«Il fuoco sotto la montagna»** (in Sicilia), finita la campagna della Soglia.
- Si gioca con il **popolo scelto per la Soglia**, sulla mappa **«Zancle e l'Etna»**.
- Sei missioni, senza limite di tempo:

| # | id | Titolo | Obiettivi |
|---|---|---|---|
| 1 | `fuoco_traversata` | La traversata | pochi coloni e un relitto: strada, pescatore sullo Stretto, 6 pesci, 2 abitazioni |
| 2 | `fuoco_zancle` | Zancle | 60 coloni, un secondo magazzino |
| 3 | `fuoco_vasai` | I vasai di Pantalica | 8 merci di lusso da scambiare con i Siculi, 80 coloni |
| 4 | `fuoco_etna` | La neve dell'Etna | 8 campi di grano → **la cenere dell'Etna** brucia i campi (evento `lava`) → 6 covoni dopo la cenere |
| 5 | `fuoco_eolie` | Il vento delle Eolie | 2 forti presidiati, una torre nemica conquistata |
| 6 | `fuoco_cuore` | Il cuore del fuoco | 120 coloni, 3 forti; il finale dipende dalla scelta fatta sulla Soglia (unione / conquista) |

## Codice

- `Missione.CAMPAGNA_FUOCO`, `Missione.CAMPAGNE` (Greci → Soglia → Sicilia: la prima missione di una campagna si apre finita la precedente), `Missione.prossima(campagna)`.
- Evento `lava` in `Missione._evento()`.
- `mappa_calabria.gd`: pulsante della campagna.

## Test

`tools/test/test_fuoco.gd`: sblocco dopo la Soglia, popolo e mappa giusti, la cenere che brucia i campi, il finale secondo la scelta della Soglia; il bot di `test_campagna` gioca «La traversata».
