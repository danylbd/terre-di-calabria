# Terre di Calabria — istruzioni per Claude

Gioco di strategia/economia originale in stile *The Settlers 3*, ambientato nella Calabria antica e medievale.
Proprietario: danylbd. Lingua del progetto, del codice e dei commit: **italiano**.

## Come lavorare con il proprietario

- **Lavora in automatico.** Fai tutto da solo (codice, grafica, GitHub, release). Chiedi solo per decisioni importantissime che non puoi prendere da solo.
- **Uno step alla volta, finito per bene**: non saltare tra step diversi. Chiudi lo step (test, screenshot, commit, merge, release) prima di iniziare il successivo.
- Ogni step ha il suo ramo `step-XX-nome` in un **worktree** separato. Quando è finito e verificato, uniscilo a `main` (`--no-ff`).
- Ogni push su `main` fa partire GitHub Actions, che compila Windows ARM64 + x64, crea `TerreDiCalabria-Setup-<versione>.exe` con Inno Setup e lo pubblica come **Release** `v<versione>` (versione presa da `project.godot`). Alza `config/version` e `application/*_version` in `export_presets.cfg` a ogni step.
- Firma dei commit: `Co-Authored-By: Claude <noreply@anthropic.com>`.

## Decisioni fissate

Vedi `docs/decisioni.md` (visuale fissa prerenderizzata, qualità grafica pari a Settlers 3, musica orchestra + strumenti calabresi, economia ricca, guerra a scelta, Greci per primi, Calabria stilizzata, stagioni, mouse e tastiera, hardware: Samsung Galaxy Book5/6 Edge Snapdragon, Windows 11 ARM64).
Storia: `docs/storia.md` (Il Sigillo di Italo). Design: `docs/design.md`. Grafica: `docs/grafica.md`. Piano: `docs/roadmap.md`.

**Grafica:** l'obiettivo è la qualità, i colori e la ricchezza di Settlers 3 (colori saturi e caldi, terreno fitto di dettagli, edifici grandi e "vissuti", alberi frondosi, villaggi pieni di omini), ma **tutto originale**: mai copiare sprite, personaggi, nomi o musiche di altri giochi.

## Struttura

- `src/audio/` — `audio.gd` (autoload Audio), `suono.gd` (scorciatoie statiche)
- `src/core/` — `palette.gd`, `iso.gd` (coordinate isometriche, casella 112×56), `sprites.gd` (carica sprite + JSON di ancoraggio)
- `src/mappa/` — `partita.gd/tscn` (scena di gioco), `dati_mappa.gd`, `generatore_mappa.gd`, `terreno.gd` + `terreno.gdshader` (terreno continuo con rilievi), `rete_strade.gd` (bandierine, tratti, A*, instradamento), `portatore.gd`/`colono.gd`, `edificio.gd`, `villaggio.gd` (regole, territorio, scorte), `segni.gd` (confini e segni), `camera_mappa.gd`
- `src/economia/` — `catalogo_edifici.gd`, `merce.gd`, `logistica.gd`
- `src/ui/` — `tema_gioco.gd`, `menu_costruzione.gd`, `barra_risorse.gd`, `pannello_edificio.gd`, `pannello_villaggio.gd`
- `src/main/` — schermata iniziale
- `assets/grafica/` — sprite PNG + JSON (ancora, celle, fotogrammi) **generati**, non disegnati a mano
- `assets/terreno/` — texture del terreno generate
- `tools/studio/` — studio di rendering: `modelli.gd` (modelli 3D costruiti in codice), `studio.gd` (li fotografa in isometria con ombra e sfondo trasparente), `anteprima.py`
- `tools/terreno/texture.py` — dipinge le texture del terreno
- `installer/setup.iss` — wizard Inno Setup; `.github/workflows/build.yml` — compilazione e release

## Comandi utili

```bash
# rigenerare sprite (tutti o solo alcuni)
godot --path . --rendering-driver opengl3 --script tools/studio/studio.gd -- assets/grafica [nomi...]
# rigenerare texture del terreno
python3 tools/terreno/texture.py
# importare ed esportare
godot --headless --path . --import
godot --headless --path . --export-release "Windows ARM64" build/arm64/TerreDiCalabria.exe
```

Su Linux senza schermo serve `xvfb-run`. Su Windows con GPU lo studio può usare il renderer Forward+ (ombre e occlusione ambientale migliori): è il modo consigliato per la grafica definitiva.

## Stato

Vedi `docs/roadmap.md`. Fatti: tutta la Fase 1 (00, G1, 01–11, G2, M1) e gli step 12–14 (in `main`, release v0.16.0).

- Step 05 (prima catena): `risorse_naturali.gd`, `lavoratore.gd` (boscaiolo, cava, guardaboschi, segheria), produzione in `logistica.gd`. Test: `tools/test/test_catena.gd`.
- Step M1 (audio): autoload `Audio` (`src/audio/audio.gd`: canali Musica/Effetti/Ambiente, scaletta, ambiente con dissolvenza); negli script usare la classe statica `Suono` (`src/audio/suono.gd`), non `Audio`, perché con `--script` l'autoload non è visibile al compilatore. Suoni: `tools/suoni/suoni.py` → `assets/suoni`; brani: `tools/suoni/musica.py` → `assets/musica` (**segnaposto**: la domanda su come fare la musica vera è in `docs/domande-per-il-proprietario.md`). Test: `tools/test/test_audio.gd`.

- Step 06 (cibo): campi generici per coltura in `risorse_naturali.gd` (`campi`, grano/vite/orto/agrumi, perenni), olive sugli ulivi, pesce e pesce spada che si ripopolano; nel catalogo i campi `coltura`, `durata`, `vicino_mare`, `produce` anche come elenco (prodotti a turno). `Logistica.serve()` ferma chi produce senza materie prime quando non serve. Barca: foglio `barca_remi` sull'acqua. Test: `tools/test/test_cibo.gd`, `test_allevamenti.gd`, `test_colture.gd`.

- Step 07 (metallo): giacimenti di ferro nella roccia (`RisorseNaturali.minerali`), miniera sulla roccia (anche sopra i massi) che mangia un cibo qualsiasi per turno (`cibo` nel catalogo, `CatalogoEdifici.CIBI`), carbonaia, fonderia, fabbro che forgia l'attrezzo più richiesto (`Logistica.attrezzo_da_fare()`). Gli artigiani arrivano solo con il loro attrezzo (`attrezzo` nel catalogo, scorte iniziali in `villaggio.gd`). Chi trasforma si ferma oltre `SCORTA_MASSIMA` se nessuno chiede il prodotto. Test: `tools/test/test_metallo.gd`.
- **Dopo aver generato sprite con lo studio, esegui sempre `--import`** prima di test e screenshot, altrimenti le texture nuove non si caricano.

- Step 08 (popolazione): `Villaggio.coloni_liberi` (40 all'inizio), ogni portatore e lavoratore prende un colono; posti = `abitanti` nel catalogo (magazzino 24, casa 8); le case fanno nascere coloni (più in fretta col lusso) che camminano al magazzino. Pannello edificio (clic) con `PannelloEdificio.stato()`, pannello villaggio (tasto I) con la produzione degli ultimi 5 minuti (`Logistica.storia`). Test: `tools/test/test_popolazione.gd`.

- Step 09 (salvataggio): `src/core/salvataggio.gd` (JSON in `user://salvataggio.json`): la mappa si rigenera dal seme, si salvano natura, edifici, bandierine, strade, merci, scorte, coloni. Caricando, `Villaggio.caricamento` evita costi e messaggi; i lavoratori tornano dentro (`metti_lavoratore`). F5 salva, F9 carica, Esc e chiusura salvano da soli; "Continua la partita" nel menu. **Ogni cosa nuova che cambia durante la partita va aggiunta al salvataggio** (e a `test_salvataggio.gd`).

- Step 10 (stagioni): `src/mappa/stagioni.gd` (4 stagioni da 300 s, `crescita(coltura)`, aspetto: `neve` nello shader del terreno, fiocchi, foglie di castagni e querce, luce con `CanvasModulate`). D'inverno niente semina né miele. Il calendario è nel salvataggio. Test: `tools/test/test_stagioni.gd`.

- Step 11 (Greci completi, 36 edifici): argillaio e fornace (anfore), saline, tessitura (stoffa, lusso), miniera d'argento e zecca (monete), agorà 3×3 che vende (`CatalogoEdifici.VENDITA`) e compra (`ACQUISTO`, scelta nel pannello, `Edificio.acquisto`). Il gruppo "una qualsiasi tra queste merci" è `CatalogoEdifici.gruppo()` (cibo dei minatori, merci dell'agorà). Test: `tools/test/test_greci.gd`.

- Step 12 (territorio): `DatiMappa.territorio` contiene il proprietario (0 nessuno, 1 giocatore, 2.. altri popoli, `proprietario(x, y)`); le caselle non si rubano finché il vecchio proprietario le copre. Torre (raggio 7) e castello (3×3, raggio 11) allargano solo quando la guardia entra (`Edificio.presidiata`, `Villaggio.presidia`). Altri popoli per ora come `Villaggio.centri_esterni`. Confine che si ritira: gli edifici fuori bruciano. Test: `tools/test/test_territorio.gd`.

- Step 13 (soldati): `src/mappa/guerra.gd` (rinforzi dalla riserva ai forti, attacco da un forte entro 18 caselle, duelli alla porta, conquista che trasforma la torre nemica in una nostra torre). Armaiolo (armi), caserma (colono + armi → soldato di riserva, `Villaggio.soldati`), forti con `soldati_max` (torre 3, castello 8). Altri popoli: `Villaggio.nemici` (Edificio con `proprietario` 2), due avamposti dei Brettii a inizio partita (`partita._metti_brettii`), difensori che si rigenerano. Test: `tools/test/test_guerra.gd`.

- Step 14 (avversario): `src/mappa/avversario.gd` (i Brettii alzano una torre ogni 300 s fino a 6, tregua di 900 s, poi ogni 240 s attaccano il nostro forte più debole se hanno più guerrieri dei difensori). `guerra.gd` vale per entrambi i lati (`lato` del soldato, fogli `guardia`/`brettio`): se vincono i Brettii il nostro forte brucia e diventa una loro torre. `Avversario.attivo` servirà per la partita «solo pace». Test: `tools/test/test_avversario.gd`.

**In corso: step 15 – scelta all'avvio** (ramo `step-15-modalita`): solo pace / solo guerra / pace poi guerra (vedi `docs/decisioni.md`).

Idea futura (Fase 5): logiche ispirate a Coral Island — **prima di progettarla fai domande al proprietario**.

### Note pratiche
- Test automatici: script `extends SceneTree` lanciati con `--script` che caricano `res://src/mappa/partita.tscn`, accelerano con `Engine.time_scale` e stampano lo stato. Esempio completo: `tools/test/test_catena.gd` (`--headless`; con `FOTO=file.png` e senza `--headless` salva anche uno screenshot).
- Se lo studio di rendering resta "appeso" senza output, quasi sempre c'è un errore di sintassi in `modelli.gd`: controlla con `godot --headless --path . --check-only --script tools/studio/modelli.gd`.
