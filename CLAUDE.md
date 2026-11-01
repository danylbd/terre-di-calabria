# Terre di Calabria — istruzioni per Claude

Gioco di strategia/economia originale in stile *The Settlers 3*, ambientato nella Calabria antica e medievale (Godot 4.7, GDScript).
Proprietario: danylbd. Lingua del progetto, del codice e dei commit: **italiano**.

## Come lavorare con il proprietario

- **Tutto automatico.** Fai tutto da solo: codice, grafica, test, commit, merge, push e release, senza chiedere conferma. Chiedi solo per decisioni importantissime (cambiare una decisione fissata, cancellare lavoro del proprietario, spese): scrivile in `docs/domande-per-il-proprietario.md` e intanto vai avanti con il resto.
- **In continuo**: un solo agente, da questa sessione; niente turni orari né sessioni parallele. Finito uno step si passa al successivo senza fermarsi. Non chiudere mai il turno per aspettare un comando in background.
- **Uno step alla volta, finito per bene**: ramo `step-XX-nome` in un **worktree** in `C:\Users\User\Projects\tdc-wt\<ramo>` (percorsi corti); a step verificato (test, screenshot, roadmap, versione) `git merge --no-ff` in `main`, push, rimuovi il worktree.
- Ogni push su `main` fa partire GitHub Actions: compila Windows ARM64 + x64, crea `TerreDiCalabria-Setup-<versione>.exe` (Inno Setup) e lo pubblica come Release `v<versione>`. A ogni step alza `config/version` in `project.godot` e `application/*_version` in `export_presets.cfg`.
- Commit con autore `danylbd <danylbd@users.noreply.github.com>` e la riga `Co-Authored-By: Claude <noreply@anthropic.com>`.
- **Grafica**: qualità, colori e ricchezza di Settlers 3, ma **tutto originale**: mai copiare sprite, personaggi, nomi o musiche di altri giochi.

## Memoria del progetto (leggere all'inizio di ogni sessione)

| File | Contenuto |
|---|---|
| `docs/SESSION_HANDOFF.md` | **dove riprendere**: ultimo obiettivo, file toccati, test, problemi aperti |
| `docs/DEVELOPMENT_STATUS.md` | fatto / in corso / da fare, bug noti, prossima attività |
| `docs/PROJECT_MEMORY.md` | obiettivo, requisiti, strumenti, mappa del codice per sistemi, regole tecniche |
| `docs/DECISIONS.md` | decisioni tecniche con motivi e alternative |
| `docs/decisioni.md` | decisioni di gioco del proprietario (fonte ufficiale) |
| `docs/roadmap.md` | piano completo degli step con lo stato |
| `docs/design.md`, `storia.md`, `grafica.md`, `monteleone.md` | design, storia, grafica, mappa di Monteleone |
| `docs/domande-per-il-proprietario.md` | domande aperte e risposte |
| `docs/diario-automatico.md` | registro cronologico di ogni sessione di lavoro |

### Continuità tra sessioni
1. All'inizio: leggi `SESSION_HANDOFF.md` e `DEVELOPMENT_STATUS.md`, poi solo le parti degli altri documenti che servono.
2. Controlla che i documenti corrispondano al repository (`git status`, `git log --oneline -5`, `git worktree list`, rami aperti): se non coincidono, fidati del repository e correggi i documenti.
3. Riprendi dal punto indicato senza chiedere al proprietario di rispiegare.
4. Aggiorna `SESSION_HANDOFF.md` (sovrascrivendolo) e `DEVELOPMENT_STATUS.md` alla fine di ogni step, quando cambia una decisione, quando il proprietario chiede qualcosa di nuovo, e prima di una compattazione. Aggiungi 3–6 righe in fondo a `diario-automatico.md`. Aggiorna solo le sezioni interessate.
5. Nuove decisioni del proprietario → `decisioni.md`; scelte tecniche → `DECISIONS.md` (segnando le provvisorie).

### Gestione del contesto
- Tieni la conversazione leggera: lo stato vive nei documenti, non nella memoria della chat.
- Letture mirate (Grep, `sed -n`, `offset/limit`) invece di file interi; `modelli.gd` e `partita.gd` sono lunghi: cerca la funzione che serve.
- Output dei test filtrati: solo righe `RISULTATO`, `  NO`, `SCRIPT ERROR`.
- Modifiche con Edit o con piccoli script Python (`newline='\n'`); gli script lunghi vanno nello scratchpad, non incollati nei comandi.
- Lavori lunghi e indipendenti (modelli 3D di un gruppo di edifici, un test nuovo, una revisione) → subagente con contesto separato, che restituisce solo il risultato.
- Non rileggere i file appena scritti; non ristampare codice già visto.

## Struttura

- `src/mappa/` — partita, dati e generatore della mappa, terreno, strade, portatori e lavoratori, edifici, villaggio, natura, stagioni, guerra, avversario
- `src/economia/` — catalogo degli edifici e delle merci, logistica, merci
- `src/storia/` — missioni e campagne; `src/main/` — menu iniziale e mappa della Calabria
- `src/ui/` — menu, barra, pannelli; `src/core/` — salvataggio, impostazioni, sprite, coordinate, palette; `src/audio/` — audio
- `assets/grafica/` (sprite **generati**), `assets/terreno/`, `assets/suoni/`, `assets/musica/`
- `tools/studio/` (modelli 3D in codice e studio di rendering), `tools/terreno/`, `tools/suoni/`, `tools/test/` (test automatici)
- `installer/setup.iss`, `.github/workflows/build.yml`

Dettaglio per sistema e regole tecniche: `docs/PROJECT_MEMORY.md`.

## Comandi

Godot (console): `C:\Users\User\AppData\Local\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64_console.exe` — Python: `C:\Users\User\AppData\Local\Programs\Python\Python313\python.exe` — git: `C:\Program Files\Git\cmd\git.exe`.

```bash
# sprite (tutti o alcuni), poi SEMPRE l'import
godot --path . --rendering-driver opengl3 --script tools/studio/studio.gd -- assets/grafica [nomi...]
godot --headless --path . --import
# un test (FOTO=file.png e senza --headless per lo screenshot; MISSIONE=id per test_campagna)
godot --headless --path . --script tools/test/test_catena.gd
# suoni, musica, texture
python tools/suoni/suoni.py ; python tools/suoni/musica.py ; python tools/terreno/texture.py
# esportazione
godot --headless --path . --export-release "Windows ARM64" build/arm64/TerreDiCalabria.exe
```

**Verifica a fine step**: tutti i test di `tools/test/` in primo piano, a gruppi di 5–6 (ognuno sotto i 10 minuti; `test_durata` da solo, circa 6 minuti); devono stampare `RISULTATO: OK` (o `tutto bene`). Poi screenshot di quello che è cambiato.

## Stato

Vedi `docs/DEVELOPMENT_STATUS.md` e `docs/SESSION_HANDOFF.md`. In breve: Fasi 1–3 e step V1–V3 (Monteleone: mappa, monumenti, partite senza fine) fatti (release v0.23.0); Fase 4: step 19–23 (cinque popoli giocabili, campagna finale «La Soglia», v0.28.0) fatti; step 24 (iPhone): comandi touch fatti (v0.29.0), esportazione in attesa del Mac (domanda aperta); Fase 6 finita (step 25–29, v0.34.0: Sicilia, Siculi e Sicani, campagna siciliana, navi e porti, epilogo «L'ultimo canto»). Domande per la Fase 5 scritte. Rifinitura grafica G6 in corso: Brettii completi, Romani (v0.36.0), poi Romani, Saraceni, Normanni, Siculi, Sicani (un popolo per step, subagente). Fase 5 (idee da Coral Island): **prima di progettarla fai domande al proprietario**.
