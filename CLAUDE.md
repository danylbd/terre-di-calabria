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

- `src/core/` — `palette.gd`, `iso.gd` (coordinate isometriche, casella 112×56), `sprites.gd` (carica sprite + JSON di ancoraggio)
- `src/mappa/` — `partita.gd/tscn` (scena di gioco), `dati_mappa.gd`, `generatore_mappa.gd`, `terreno.gd` + `terreno.gdshader` (terreno continuo con rilievi), `rete_strade.gd` (bandierine, tratti, A*, instradamento), `portatore.gd`/`colono.gd`, `edificio.gd`, `villaggio.gd` (regole, territorio, scorte), `segni.gd` (confini e segni), `camera_mappa.gd`
- `src/economia/` — `catalogo_edifici.gd`, `merce.gd`, `logistica.gd`
- `src/ui/` — `tema_gioco.gd`, `menu_costruzione.gd`, `barra_risorse.gd`
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

Vedi `docs/roadmap.md`. Rami: `step-04-trasporto` (merci che viaggiano, in chiusura), `step-g2-grafica` (bozza: materiale "vissuto" `tools/studio/vissuto.gdshader` e luce più contrastata, da completare dopo lo step 04).
