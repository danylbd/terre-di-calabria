# Passaggio di consegne tra sessioni

*Si aggiorna a ogni passaggio importante. Lo storico è in [`diario-automatico.md`](diario-automatico.md).*

**Aggiornato:** 2026-11-01, step V1 appena iniziato (in `main`: release v0.20.0 e memoria del progetto).

## Ultimo obiettivo affrontato

**Step V1 — mappa di Monteleone** (ramo `step-v1-monteleone`, worktree `C:\Users\User\Projects\tdc-wt\step-v1-monteleone`). Finora solo questo piano, nessun codice. Le modifiche lunghe ai file vanno scritte in uno script Python nello scratchpad (un heredoc nella shell è fallito per gli apostrofi).

## Piano dettagliato dello step V1

1. **`src/mappa/generatore_mappa.gd`**: estrarre la radura del villaggio in `static func _radura(d, centro, raggio := 8)` (oggi è in fondo a `genera()`), poi aggiungere `static func genera_monteleone(seme, w := 96, h := 96) -> DatiMappa`:
   - costa in caselle (dalle coordinate vere: x = (lon − 15,80)/0,50·96, y = (38,80 − lat)/0,36·96), da Pizzo a nord-est fino a Nicotera; il mare sta a nord-ovest:
     `(78.7,-1) (74.9,10.7) (71.0,17.3) (66.2,21.3) (61.4,23.5) (53.8,22.7) (44.2,21.3) (34.6,25.3) (25.0,29.3) (18.2,32.8) (11.5,37.3) (5.8,45.3) (7.7,50.7) (15.4,58.7) (26.9,66.7) (25.0,80.0) (19.2,97)`; la terra è il poligono costa + `(w+2,h+2) (w+2,-2) (78.7,-2)` (`Geometry2D.is_point_in_polygon`), con la costa frastagliata dal rumore.
   - luoghi (caselle): Monteleone (57,33) = villaggio sul colle, Vibo Marina (61,26), Bivona (66,23), Pizzo (71,19), Briatico (44,23), Tropea (20,33), Isola (16,31) = scoglio di roccia in mare, Capo Vaticano (8,46), Monte Poro (35,49), lago dell'Angitola (82,12) = ellisse d'acqua 4×2,6, Serre (88,59), valle del Mesima (54,72).
   - quote: 5 + distanza dalla costa (max 6)·2,5; colline a campana `alta·exp(−d²/2r²)`: Monteleone +70 (r 7), Poro +105 limitato a 88 (r 13, altopiano), Tropea +32 (r 4, rupe), Mesima −14 (r 11); dorsale delle Serre `smoothstep(66,95,x)·smoothstep(−4,30,y)·250·(0.65+0.35·rumore)`; rumore di dettaglio. Mare e lago a quota 0.
   - tipi: mare; sabbia se distanza < 1,6 e quota < 20; neve > 225; roccia > 135; rupe (roccia) se distanza < 2,2 e quota > 28; bosco sulle Serre (x > 66) e dove è umido; secco sul Poro; prato il resto.
   - `DatiMappa.luoghi` (nuova variabile: nome → casella) per i nomi sulla mappa e per i monumenti dello step V2.
2. **`src/core/impostazioni.gd`**: `static var mappa := "costa_ionica"` (oppure `"monteleone"`).
3. **`src/mappa/partita.gd`** (riga ~43 `dati = GeneratoreMappa.genera(SEME)`): con la mappa Monteleone usare `genera_monteleone(SEME)`; scrivere i nomi dei luoghi sulla mappa (etichette leggere).
4. **Salvataggio** (`src/core/salvataggio.gd`): salvare `"mappa"`; quando si carica, leggere la mappa dal file prima di generarla (`Salvataggio.mappa_di(percorso)`).
5. **Menu iniziale**, pannello «Nuova partita» (`src/main/title_screen.gd`, `_crea_pannello_modalita`): scelta della mappa (Costa ionica / Monteleone). Sulla mappa della Calabria (`src/main/mappa_calabria.gd`) un segnaposto «Monteleone» a (880, 703) del foglio per la partita libera.
6. **Test** `tools/test/test_monteleone.gd`: forma (mare a nord-ovest, Tropea sulla costa, villaggio a terra sul colle), si costruisce e si produce (catena breve), salvataggio con la mappa giusta; screenshot. Poi tutti i test a gruppi, versione 0.21.0, roadmap, CLAUDE.md, merge.

## Problemi irrisolti

- Musica ancora segnaposto (domanda aperta al proprietario).
- Esito delle GitHub Actions non verificabile da qui (`gh` assente).

## Da dove riprendere

Dal punto 1 del piano, nel worktree dello step V1.
