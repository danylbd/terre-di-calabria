# Memoria del progetto — Terre di Calabria

*Conoscenze stabili del progetto. Si aggiorna quando cambia qualcosa di consolidato (nuovo sistema, nuovo requisito).
Lo stato del lavoro sta in [`DEVELOPMENT_STATUS.md`](DEVELOPMENT_STATUS.md); le decisioni tecniche in [`DECISIONS.md`](DECISIONS.md).*

## Obiettivo

Gioco di strategia ed economia **originale** in stile *The Settlers 3*, ambientato nella Calabria antica e medievale: villaggi pieni di coloni, catene di produzione lunghe, strade con portatori, territorio, guerra a scelta, campagne con una storia (Il Sigillo di Italo). Proprietario: **danylbd**. Lingua di progetto, codice, commenti e commit: **italiano**.

## Requisiti e vincoli del proprietario

- **Lavoro**: tutto automatico (codice, grafica, test, commit, merge, push, release). Chiedere solo per decisioni importantissime. Un solo agente, in continuo, senza turni orari né sessioni parallele.
- **Qualità**: grafica con la ricchezza e i colori di Settlers 3, ma **tutto originale** (mai copiare sprite, personaggi, nomi, musiche).
- **Piattaforma**: Windows 11 ARM64 (Samsung Galaxy Book5/6 Edge, Snapdragon); si compila anche x64. Mouse e tastiera.
- **Decisioni di gioco fissate**: [`decisioni.md`](decisioni.md) (fonte ufficiale; qui non si ripetono). Le più recenti (2026-11-01): monete = **ducati**; partite e campagne **senza limite di tempo**; mappa della Calabria con la **forma reale**; mappa di **Monteleone (Vibo Valentia)** con i suoi monumenti sbloccati man mano ([`monteleone.md`](monteleone.md)); seguito della storia in **Sicilia** (piano in [`storia.md`](storia.md)).
- **Fase 5** (idee ispirate a Coral Island): non iniziarla senza aver fatto domande al proprietario.

## Informazioni tecniche

- **Motore**: Godot 4.7.2, GDScript, renderer «mobile» (D3D12 su Windows). Finestra base 1920×1080, `stretch canvas_items`.
- **Strumenti sul PC** (non sempre nel PATH): Godot console `C:\Users\User\AppData\Local\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64_console.exe`, Python 3.13 `C:\Users\User\AppData\Local\Programs\Python\Python313\python.exe` (solo libreria standard: niente numpy/PIL), git `C:\Program Files\Git\cmd\git.exe`. `gh` non è installato. GitHub con Git Credential Manager (repo privato `danylbd/terre-di-calabria`).
- **Rilascio**: ogni push su `main` → GitHub Actions compila ARM64 + x64, crea `TerreDiCalabria-Setup-<versione>.exe` (Inno Setup, `installer/setup.iss`) e lo pubblica come Release `v<versione>` presa da `project.godot`.
- **Grafica generata**: modelli 3D scritti in codice (`tools/studio/modelli.gd`) fotografati in isometria da `tools/studio/studio.gd` → PNG + JSON in `assets/grafica/`. Terreno: `tools/terreno/texture.py`. Suoni e musica segnaposto: `tools/suoni/suoni.py`, `tools/suoni/musica.py`. Su Linux senza schermo lo studio va lanciato con `xvfb-run`; su Windows con GPU può usare il renderer Forward+ (ombre e occlusione ambientale migliori), consigliato per la grafica definitiva. `tools/studio/anteprima.py` compone una scena di prova con gli sprite (richiede numpy e PIL, non installati).
- **Salvataggi** in `user://` (cartella utente di Godot): `salvataggio.json` (partita), `campagna.json` (missioni compiute). I test usano file `user://test_*.json` propri e li cancellano.

## Il codice, sistema per sistema

- **Mappa** (`src/mappa/`): `partita.gd/tscn` (scena di gioco, interfaccia, avvio partita/missione, Brettii, torri verso la costa), `dati_mappa.gd` (terreno, quote, occupazione, `territorio` = proprietario di ogni casella), `generatore_mappa.gd` (mappe dal seme 1987: «Costa ionica» 72×72 e «Monteleone» 96×96 con costa e luoghi veri; `crea(mappa, seme)`; la mappa scelta è `Impostazioni.mappa`, quella giocata `partita.mappa`, salvata nel file), `terreno.gd` + `terreno.gdshader` (terreno continuo, neve), `camera_mappa.gd`, `segni.gd` (confini colorati per popolo, posti costruibili, cerchio dei confini).
- **Strade e trasporto**: `rete_strade.gd` (bandierine, tratti, A*, instradamento, un portatore per tratto, prende un colono), `portatore.gd`/`colono.gd`, `logistica.gd` (merci in viaggio, richieste dei cantieri e degli edifici, `produci()`, `serve()`, tetti `SCORTA_MINIMA`/`SCORTA_MASSIMA`, `SEMPRE_UTILI` = assi e ducati, storia della produzione), `merce.gd` (`origine` = chi l'ha prodotta).
- **Edifici ed economia**: `src/economia/catalogo_edifici.gd` (tutti gli edifici: taglia, costo, `lavoratore`, `attrezzo`, `produce` anche come elenco, `ingressi`, `coltura`, `durata`, `vicino_mare`, `miniera`, `cibo`/`vende` = gruppo «una qualsiasi», `territorio`, `presidio`, `soldati_max`, `abitanti`; merci, `CIBI`, `LUSSO`, `ATTREZZI`, `VENDITA`/`ACQUISTO` dell'agorà), `edificio.gd`, `villaggio.gd` (regole di costruzione, scorte, coloni, abitazioni, territorio, nemici, perdita degli edifici fuori confine), `lavoratore.gd` (tutti i mestieri: fuori, dentro, colture, pesca, barca, miniera, fabbro, agorà, caserma, guardia).
- **Natura**: `risorse_naturali.gd` (alberi, massi, ulivi e olive, campi per coltura con perenni, pesce e pesce spada che si ripopolano, giacimenti di ferro e argento, ceppi e stoppie).
- **Tempo**: `stagioni.gd` (4 stagioni da 300 s, crescita per coltura, neve, foglie, luce).
- **Guerra**: `guerra.gd` (rinforzi ai forti, attacco, duelli, conquista, valida per entrambi i lati), `avversario.gd` (i Brettii: espansione, tregua, attacchi, modalità).
- **Storia**: `src/storia/missione.gd` (missioni in `Missione.MISSIONI`, obiettivi generici, eventi, progressi della campagna), `src/ui/pannello_missione.gd`, `src/main/mappa_calabria.gd` (mappa della campagna, Calabria reale).
- **Interfaccia** (`src/ui/`): `menu_costruzione.gd`, `barra_risorse.gd`, `pannello_edificio.gd` (stato e motivo se fermo, agorà, attacco), `pannello_villaggio.gd` (tasto I), `tema_gioco.gd`. Menu iniziale `src/main/title_screen.gd`.
- **Sistema**: `src/core/` — `salvataggio.gd`, `impostazioni.gd` (modalità e missione scelte nel menu), `sprites.gd`, `iso.gd` (casella 112×56), `palette.gd`. Audio: autoload `Audio` (`src/audio/audio.gd`) usato negli script tramite la classe statica `Suono`.

## Regole tecniche da ricordare

- Negli script usare `Suono.*`, mai l'identificatore `Audio` (con `--script` l'autoload non è visibile al compilatore).
- **Ogni cosa nuova che cambia durante la partita va aggiunta al salvataggio** e a `tools/test/test_salvataggio.gd`.
- Dopo aver generato sprite con lo studio, eseguire sempre `--import` prima di test e screenshot (altrimenti le texture nuove non si caricano).
- Se lo studio resta «appeso» senza output, c'è quasi sempre un errore di sintassi in `modelli.gd`: `godot --headless --path . --check-only --script tools/studio/modelli.gd`.
- Variabili che possono contenere un edificio già distrutto: senza tipo e con `is_instance_valid` (assegnare un oggetto liberato a una variabile tipizzata dà errore).
- Le modifiche ai file con Python vanno scritte con `newline='\n'` (altrimenti CRLF); i comandi lunghi con barre rovesciate meglio in uno script a parte.
