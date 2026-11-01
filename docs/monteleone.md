# Monteleone — la mappa di Vibo Valentia

*Piano del 2026-11-01, su richiesta del proprietario. Da rifinire insieme.*

Una mappa di gioco ambientata a **Monteleone** (l'antica *Hipponion* dei Greci, la *Vibo Valentia* dei Romani) e in tutto il suo circondario. Non è fedele al metro, ma la costa, i rilievi e i paesi devono essere riconoscibili.

## Geografia (da nord a sud, dal mare ai monti)

| Luogo | Dove sulla mappa | Che cosa c'è nel gioco |
|---|---|---|
| **Golfo di Sant'Eufemia** | a nord, mare aperto | pesca, pesce spada, tonni |
| **Pizzo** | costa nord-est, su una rupe sul mare | paese di pescatori, tonnara |
| **Vibo Marina** (Porto Santa Venere) | costa nord, pianura bassa | il porto, le saline, i pescatori |
| **Bivona** | costa tra Vibo Marina e Pizzo | la tonnara e la torre |
| **Monteleone / Vibo Valentia** | su un colle a ~500 m, 4–5 km dal mare | il centro del giocatore: il colle con il castello |
| **Monte Poro** | altopiano a sud-ovest di Vibo, ~700 m | pascoli, campi, cipolla e 'nduja |
| **Briatico, Zambrone, Parghelia** | costa ovest | calette, scogli, uliveti |
| **Tropea** | promontorio sul mare a ovest, rupe a picco | il paese sulla rupe e lo scoglio dell'Isola |
| **Capo Vaticano** | punta sud-ovest | scogliere e fari, mare aperto verso le Eolie |
| **Valle del Mesima** | a sud-est, pianura con fiume | grano, agrumi, vigne |
| **Serre** | a est, montagne boscose | boschi, miniere di ferro |
| **Lago dell'Angitola** | nord-est, verso Pizzo | acqua dolce, canneti |

**Costa:** il mare sta a nord e a ovest. Da Pizzo la costa scende verso ovest (Vibo Marina, Bivona, Briatico), poi gira a sud con il promontorio di Tropea e la punta di Capo Vaticano. Il colle di Monteleone guarda il golfo dall'alto. Le isole Eolie (Stromboli) si vedono all'orizzonte, oltre il bordo della mappa.

**Come si fa:** un nuovo generatore di mappa (`GeneratoreMappa` con la variante «monteleone») che parte da una maschera disegnata a mano della costa e dei rilievi, poi aggiunge il rumore per i dettagli. Il villaggio del giocatore parte sul colle di Monteleone, con il mare visibile sotto.

## I monumenti di Monteleone, uno dopo l'altro

Ogni volta che il villaggio fa un passo avanti (traguardi di crescita), si sblocca un monumento tipico del luogo. Compare sulla mappa **al suo posto** (posti riservati sulla mappa di Monteleone), con un breve canto di Rocco della Lira, e dà un piccolo vantaggio. L'ordine segue la storia della città, dai Greci in poi.

| # | Traguardo | Monumento | Dove | Vantaggio (come è nel gioco) |
|---|---|---|---|---|
| 1 | Fondazione: magazzino e 2 strade | **Mura greche di Hipponion** | sul bordo del colle | confini +2 caselle |
| 2 | 50 coloni | **Tempio di Proserpina** (area del Cofino) | sul colle, fuori le mura | nascite più rapide (×0,8 sul tempo) |
| 3 | Un pescatore o una barca del pesce spada | **Porto di Santa Venere** | Vibo Marina | 4 pesci ogni stagione |
| 4 | Un'agorà e 30 ducati | **Foro di Valentia** (i resti romani) | in città | 5 ducati ogni stagione |
| 5 | Un castello | **Castello normanno-svevo** | in cima al colle | 3 soldati di rinforzo |
| 6 | 100 coloni | **Duomo di Santa Maria Maggiore e San Leoluca** | in città | nascite ancora più rapide (×0,8) |
| 7 | 10 mestieri diversi al lavoro | **Chiesa del Rosario** | in città | lavoro più rapido (×0,85 sul tempo) |
| 8 | 200 ducati coniati in tutta la partita | **Valentianum** (il convento dei Domenicani) | in città | +12% di duelli vinti dai nostri soldati |
| 9 | 30 pesci spada pescati | **Tonnara e castello di Bivona** | costa, Bivona | 6 pesci ogni stagione |
| 10 | 150 coloni | **Castello di Pizzo** e **Chiesetta di Piedigrotta** | Pizzo | confini +1 casella |
| 11 | Un anno (4 stagioni) senza perdere un forte | **Santa Maria dell'Isola** | Tropea, sullo scoglio | 10 ducati ogni stagione |

Si ottengono in quest'ordine, uno alla volta: il traguardo di un monumento conta solo dopo che è arrivato il precedente. Codice: `src/storia/monumenti.gd` (catalogo, traguardi, posa), vantaggi in `Villaggio.vantaggi`; si vedono nel pannello del villaggio (tasto I).

I monumenti sono originali nell'aspetto (modelli 3D del gioco ispirati alla forma dei luoghi veri), mai copiati da altri giochi.

## Durata

Nessun limite di tempo: la mappa di Monteleone si gioca anche per ore; i monumenti sono il filo che fa venire voglia di andare avanti.
