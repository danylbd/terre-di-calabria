# Decisioni di progetto

*Fissate il 31 ottobre 2026. Si cambiano solo di comune accordo; ogni modifica va annotata qui sotto con la data.*

| Tema | Decisione |
|---|---|
| Nome | **Terre di Calabria** — sottotitolo *Il Sigillo di Italo* |
| Visuale | Fissa, isometrica, sprite 3D prerenderizzati (come Settlers 3) |
| Qualità grafica | Obiettivo: pari a Settlers 3 (edifici dettagliati e "vissuti", terreno dipinto continuo, omini piccoli e animati per ogni azione) |
| Scala | Omini piccoli e tanti: villaggi brulicanti con centinaia di coloni |
| Musica | Orchestra + strumenti calabresi (zampogna, lira, tamburello, chitarra battente), brani in loop di sottofondo |
| Suoni | Lavoro (asce, seghe, martelli, macine) e natura (mare, vento, uccelli, cicale). Niente voci per ora |
| Economia | Ricca come Settlers 3: circa 30 edifici, catene lunghe, molti mestieri |
| Guerra | Si sceglie all'inizio della partita/campagna: **solo pace**, **solo guerra**, oppure **pace e poi guerra** dopo l'economia |
| Avversari | Computer (IA). Niente multigiocatore per ora |
| Primo popolo | **Greci**, completi in tutto prima di passare agli altri |
| Mappa campagna | Calabria con la **forma reale** della regione (costa dalle coordinate vere), con Pollino, Sila, Serre, Aspromonte, Stretto *(deciso dal proprietario il 2026-11-01)* |
| Tempo | Stagioni sì (neve, raccolti); luce sempre di giorno |
| Durata | Missioni lunghe (1–3 ore) con salvataggi |
| Comandi | Mouse e tastiera |
| Lingua | Italiano; Rocco della Lira con qualche frase in dialetto calabrese |
| Hardware di riferimento | Samsung Galaxy Book5/Book6 Edge (Snapdragon X), Windows 11 ARM64 nativo |
| Consegna | `Setup.exe` compilato da GitHub a ogni step |
| Repository | GitHub privato `danylbd/terre-di-calabria`; un ramo per step, `main` = versioni approvate |

## Decisioni del 2026-11-01 (dal proprietario)

| Tema | Scelta |
|---|---|
| Moneta | Le monete del gioco si chiamano **ducati** |
| Durata | Campagne e missioni **senza limite di tempo**: finita una missione si continua a giocare liberamente, anche per ore |
| Mappa di Monteleone | Una mappa di gioco ambientata a **Monteleone (Vibo Valentia)** con il circondario: Vibo Marina, Pizzo, Tropea, Capo Vaticano, il Monte Poro, le Serre; la costa rifatta simile a quella vera |
| Monumenti | Man mano che il giocatore avanza ottiene i **monumenti tipici di Monteleone**, che compaiono sulla mappa al loro posto, uno dopo l'altro |
| Sicilia | Pianificare un **prolungamento della storia in Sicilia** |

## Decisioni provvisorie (prese in automatico, in attesa del proprietario)

| Argomento | Scelta provvisoria |
|---|---|
| Chi è Rocco della Lira | **È re Italo**, che ha aspettato secoli di vedere i popoli scegliere (l'idea scritta in `storia.md`). Si svela nell'epilogo «L'ultimo canto» (step 29). Domanda aperta in `domande-per-il-proprietario.md`: se il proprietario sceglie altro, si cambiano solo i testi di `ultimo_canto` e di `soglia_sigillo` in `src/storia/missione.gd`. |

## Decisioni del 2026-11-02 (dal proprietario)

| Argomento | Decisione |
|---|---|
| Update «Imperivm» | Unire al gioco le idee e la dinamica di *Imperivm: le guerre puniche* (villaggi da conquistare, condottieri con schiere, cibo dell'esercito, morale, navi, assedi) e una grafica di guerra più ricca, **senza annullare o rovinare il lavoro fatto**: piano in `piano-imperivm.md` (Fase 7) |
