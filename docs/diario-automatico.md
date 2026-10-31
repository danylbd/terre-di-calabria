# Diario dei turni automatici

Memoria tra un turno automatico e l'altro: in fondo l'ultimo turno.

## 2026-10-31 20:00 — step 05 prima catena
- Scritto `tools/test/test_catena.gd`: piazza boscaiolo, cava, segheria, guardaboschi, li collega e accelera il tempo. Risultato OK: alberi abbattuti, pietra estratta, 8 alberelli piantati, assi della segheria e pietra arrivano al magazzino.
- Trovato collo di bottiglia: il portatore rientrava sempre a metà tratto anche con una merce di ritorno già in attesa. Ora la riprende subito (`portatore.gd: puo_prendere`): assi in 6 minuti di gioco da 22 a 31.
- Screenshot in `docs/immagini/step05-catena.png`. Versione 0.6.0, roadmap e CLAUDE.md aggiornati, step unito a `main`.
- Resta / da tenere d'occhio: con una sola strada verso il magazzino si formano code (normale, il giocatore aggiunge strade). I tronchi del boscaiolo vanno al magazzino quando la segheria ha già 4 tronchi in arrivo: corretto ma fa fare giri in più.
- Prossimo: step M1 musica e suoni.

## 2026-10-31 20:30 — step M1 musica e suoni (inizio)
- Creato ramo `step-m1-musica` e worktree. Sul PC mancano numpy, ffmpeg, fluidsynth, soundfont.
- Scritta la domanda in `docs/domande-per-il-proprietario.md` (come produrre la musica; raccomandata opzione 1: FluidSynth + soundfont libero).
- Prossimo turno, senza aspettare la risposta: sistema audio in Godot (bus Musica/Effetti/Ambiente, lettore musica con dissolvenza, suoni posizionali dei lavoratori) e suoni di lavoro/natura sintetizzati con Python standard (`wave`, `math`) in `tools/suoni/`.

## 2026-10-31 20:45 — step M1 completato (sessione principale, lavoro continuo)
- Su richiesta del proprietario: turno orario disattivato (eliminarlo va fatto da una sessione normale), si lavora solo dalla sessione principale.
- Adottato il lavoro della sessione oraria (audio.gd, suoni.py, suoni di lavoro e interfaccia); aggiunta la classe `Suono` perché l'identificatore `Audio` rompeva i test con `--script`.
- Musica segnaposto (3 brani, `tools/suoni/musica.py`), scaletta, tasto M, cicale. test_audio e test_catena OK; il gioco parte senza errori audio.
- Versione 0.7.0, merge in main. Prossimo: step 06 cibo.

## 2026-10-31 21:15 — step 06 cibo, pezzo 1 (pane e pesce)
- Fattoria (contadino semina fino a 8 campi, crescono in 4 fasi, miete → grano), mulino (farina), forno (farina + acqua → pane), pozzo (acqua solo se serve: `Logistica.serve()`), pescatore (pesce dalla riva, si esaurisce e torna). Lavoratore generalizzato: `_lavora_dentro()` vale per segheria, mulino, forno, pozzo.
- Sprite nuovi (studio opengl3): 4 edifici, campo_1..4, stoppie, 5 merci, 4 carichi del portatore, contadino e pescatore. Suoni falce, tuffo, macina.
- Corretto bug in `rete_strade.gd` (_percorso_tra_uscite: array senza tipo).
- test_cibo OK (pane 10, pesce 19 in 10 minuti di gioco), test_catena OK. Screenshot `docs/immagini/step06-cibo*.png`.
- Resta per lo step 06: allevamenti (maiali, pecore, capre, api) con macelleria e caseificio; vite, orto/cipolla, agrumi; barca per il pesce spada; olive per il frantoio.

## 2026-10-31 21:45 — step 06 cibo, pezzo 2 (allevamenti)
- Porcile (grano + acqua → maiali), macelleria (carne), ovile (acqua → latte e lana a turno: `produce` può essere un elenco), capraio (latte), apiario (miele), caseificio (latte → formaggio). Campo `durata` nel catalogo per i tempi di lavoro.
- Modelli con animali (maiali, pecore, capre) nei recinti; merci e carichi nuovi. Barra delle scorte: legno e pietra sempre, le altre merci solo quando ci sono, e si ricentra.
- test_allevamenti OK (carne, lana, formaggio, miele al magazzino). Screenshot `docs/immagini/step06-allevamenti.png`.
- Resta: vite/cantina, orto e cipolla, agrumi, olive per il frantoio, barca per il pesce spada. Animali fermi nel modello (in futuro: animali che si muovono).

## 2026-10-31 22:30 — step 06 completato
- Pezzo 3: colture generiche (vigneto, ortolano, agrumeto con vite e agrumi perenni), cantina, raccoglitore di olive + frantoio, barca del pesce spada (rema sull'acqua). Pescatore e barca solo vicino al mare.
- Tutti i test OK: catena, audio, cibo, allevamenti, colture. Versione 0.8.0, merge in main.
- Note per il futuro: olive e altre materie prime non hanno tetto (solo il pozzo si ferma); animali fermi nei modelli; la costa è lontana dal villaggio iniziale (servono 2 torri).
- Prossimo: step 07 metallo.

## 2026-10-31 23:15 — step 07 metallo completato
- Miniera di ferro (sulla roccia, anche sopra i massi; giacimenti nascosti che si esauriscono; i minatori mangiano pane/pesce/carne/formaggio/ortaggi/cipolle), carbonaia, fonderia, fabbro.
- Attrezzi: ogni artigiano porta il suo dal magazzino (scorte iniziali); il fabbro forgia prima quello che manca. Barra: voce unica "Attrezzi" con il dettaglio nel suggerimento.
- Chi trasforma si ferma oltre 12 in magazzino se nessuno chiede (la carbonaia non brucia più tutti i tronchi).
- Lezione: dopo lo studio serve `--import`, altrimenti gli edifici nuovi sono invisibili (successo nel primo screenshot).
- Tutti i 6 test OK. Versione 0.9.0, merge in main. Prossimo: step 08 popolazione e statistiche.

## 2026-10-31 23:50 — step 08 popolazione e statistiche completato
- Coloni contati: 40 all'inizio, posti dalle abitazioni (8) e dal magazzino (24); portatori e lavoratori prendono un colono, demolendo tornano liberi; strade ed edifici aspettano se i coloni finiscono.
- Le case fanno nascere coloni ogni 40 s (20 s consumando vino, agrumi o miele); il nuovo colono cammina fino al magazzino.
- Pannello edificio (clic: stato, perché è fermo, ingressi, produzione, strada da qui, demolisci) e pannello villaggio (tasto I / pulsante). Barra: "Coloni N / M".
- Tutti i 7 test OK. Versione 0.10.0, merge in main. Prossimo: step 09 salvataggio.

## 2026-11-01 00:30 — step 09 salvataggio completato
- `Salvataggio.salva/carica` (JSON): natura (alberi con posizione e crescita, massi, campi, ceppi, pesce, olive, giacimenti), edifici e cantieri, bandierine, strade (con o senza portatore), merci in viaggio, scorte, coloni, statistiche, camera.
- F5/F9, salvataggio automatico con Esc e alla chiusura, "Continua la partita" nel menu iniziale. Tolta la scritta "step G2" dalla versione nel titolo.
- test_salvataggio: tutto identico dopo il caricamento e la partita continua a produrre. Tutti gli 8 test OK. Versione 0.11.0. Prossimo: step 10 stagioni.

## 2026-11-01 01:15 — step 10 stagioni completato
- Calendario di 4 stagioni (5 minuti l'una), si parte in primavera. Crescita per stagione di grano, orto, vite, agrumi, alberelli, olive; d'inverno niente semina e api a riposo.
- Neve nello shader del terreno, fiocchi che cadono, castagni e querce gialli d'autunno e spogli d'inverno, luce che cambia; cicale solo d'estate, più vento d'inverno. Stagione e anno nella barra e nel pannello.
- Calendario nel salvataggio. Tutti i 9 test OK. Versione 0.12.0. Prossimo: step 11 Greci completi.

## 2026-11-01 02:10 — step 11 Greci completi (Fase 1 finita)
- 7 edifici nuovi (36 in tutto): argillaio, fornace, saline, tessitura, miniera d'argento, zecca, agorà (3×3, edificio unico dei Greci).
- Agorà: vende olio, vino, stoffa, anfore, pesce spada, miele, formaggio, sale, agrumi per monete (prezzi favorevoli); compra la merce scelta nel pannello. Le monete non hanno tetto di scorta.
- Generalizzato il gruppo "una qualsiasi" (`CatalogoEdifici.gruppo`). Versione 0.13.0. Prossimo: step 12 territorio e torri.
