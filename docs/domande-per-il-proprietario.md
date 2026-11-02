# Domande per il proprietario

Scrivi la risposta sotto la domanda (riga "Risposta: ..."): il turno automatico successivo la applica.

## 2026-10-31 — Step M1 (musica e suoni): come produrre la musica?

La decisione fissata è «orchestra + strumenti calabresi (zampogna, lira, tamburello, chitarra battente)». Sul PC non c'è nessuno strumento musicale (niente sintetizzatori, campioni o librerie audio): la musica andrebbe "generata" in codice, e un'orchestra sintetizzata da zero suona da videogioco anni '90, non da Settlers 3.

Opzioni:
1. **Installare FluidSynth + un soundfont orchestrale libero** (es. FluidR3 / GeneralUser GS, licenze libere): scrivo le partiture in codice (MIDI) e le registro in OGG. Qualità discreta, tutto originale, gratis. Serve installare software.
2. **Sintesi pura in Python** (senza installare nulla): qualità bassa, va bene come segnaposto.
3. **Musica fatta da un musicista o con un servizio a pagamento**: qualità migliore, ma è una spesa.

Raccomandazione: **1** per i primi 3 brani (poi si può sostituire con l'opzione 3 più avanti). Nel frattempo preparo il sistema audio del gioco (canali musica/effetti/ambiente, volumi, brani in loop con dissolvenza) e i **suoni di lavoro e natura** sintetizzati in codice, che non dipendono da questa scelta.

Nel frattempo (stesso giorno): ci sono 3 brani segnaposto sintetizzati in Python (`tools/suoni/musica.py`: mattino, lavoro, sera) con zampogna, lira, chitarra battente, tamburello e archi imitati. Funzionano nel gioco, ma la qualità è da segnaposto. La domanda resta aperta.

Risposta: confermate le scelte consigliate (2026-11-02), vedi `decisioni.md`.

## 2026-11-02 — Step 23 (campagna finale): chi è Rocco della Lira?

In `storia.md` c'è scritto «Chi è Rocco? Lo decidiamo insieme. Un'idea: è Italo stesso». Nel finale dell'Unione della campagna «La Soglia» Rocco ora lo lascia solo intuire («Un re, a volte, deve solo aspettare che i suoi figli imparino»), senza dirlo. Va bene così, o preferisci un'altra identità (o nessuna rivelazione)? Il testo si cambia in un attimo (`src/storia/missione.gd`, missione `soglia_sigillo`).

Risposta: confermate le scelte consigliate (2026-11-02), vedi `decisioni.md`.

## 2026-11-02 — Step 24 (versione iPhone): serve un Mac

Per esportare il gioco per iPhone, Godot ha bisogno di un **Mac con Xcode** e di un **account Apple Developer** (99 $ l'anno) per installarlo sul telefono o pubblicarlo. Da questo PC Windows non si può fare. Opzioni:
1. Hai (o puoi usare) un Mac: preparo qui tutto quello che serve (comandi touch, interfaccia per schermi piccoli, preset di esportazione iOS) e tu fai l'ultimo passo sul Mac.
2. Un servizio di compilazione in cloud con Mac (a pagamento).
3. Rimandare l'iPhone e fare prima la Fase 6 (Sicilia).

Nel frattempo, senza aspettare la risposta, comincio dalla parte che non dipende dal Mac: comandi touch e interfaccia adatta agli schermi piccoli.

Risposta: confermate le scelte consigliate (2026-11-02), vedi `decisioni.md`.

## 2026-11-02 — Fase 5 (idee da Coral Island): che cosa vuoi prendere?

Le fasi 1–4 e 6 sono fatte. Prima di progettare la Fase 5 ho bisogno di capire che cosa ti piace di Coral Island. Rispondi anche solo con i numeri e un sì/no:

1. **Personaggi del villaggio** con nome, carattere e amicizia (regali, dialoghi, piccole richieste): sì o no? Se sì, quanti (pochi personaggi importanti, per esempio 8–10, o uno per mestiere)?
2. **Feste stagionali** (la festa del grano d'estate, la vendemmia d'autunno, il presepe d'inverno, la festa del mare): solo da guardare, o con piccoli giochi e premi?
3. **Cura del mare e della costa** (pulire le spiagge, proteggere i pesci, il mare che torna più ricco): ti piace come obiettivo del gioco?
4. **Collezioni** (conchiglie, monete antiche, frammenti di vasi, piante rare da trovare e mettere in un museo): sì o no?
5. **Un personaggio del giocatore** che cammina sulla mappa (come in Coral Island) oppure resta tutto «dall'alto» come in Settlers? (Consiglio: restare dall'alto, con i personaggi del villaggio da visitare cliccando.)
6. Queste cose devono stare **in tutte le partite** o in una **modalità a parte** («vita del villaggio», più tranquilla)?
7. C'è qualcos'altro di Coral Island che ti è piaciuto e che qui non ho scritto?

Nel frattempo, senza aspettare, lavoro alla rifinitura grafica (edifici dei popoli che hanno ancora l'aspetto greco) e al bilanciamento.

Risposta: confermate le scelte consigliate (2026-11-02), vedi `decisioni.md`.

## 2026-11-02 — Update «Le guerre di Annibale» (idee da Imperivm)

Il piano è in `docs/piano-imperivm.md`. Quattro domande:
1. Per le schiere va bene il **controllo diretto** (clic sul condottiero, poi dove andare o chi attaccare), mentre l'economia resta alla Settlers? (Consiglio: sì.)
2. I **Cartaginesi** come ottavo popolo giocabile: sì? E gli **elefanti**?
3. La campagna di Annibale **prima o dopo** la Fase 5 (Coral Island)?
4. C'è qualcosa di Imperivm che ti piaceva in modo particolare e che nel piano manca?

Intanto comincio dallo step 30 (villaggi indigeni), che non dipende da queste risposte.

Risposta: confermate le scelte consigliate (2026-11-02), vedi `decisioni.md`.

*Tutte le domande fin qui hanno risposta (2026-11-02): le scelte sono in `decisioni.md`.*

## 2026-11-02 — Voce di re Italo (libera da diritti)

Il proprietario vuole sentire la voce di re Italo, solo con suoni e voci liberi da diritti. Oggi nel gioco non c'è nessuna voce: i dialoghi sono scritti. Possibilità:

1. ★ **Voce inventata, generata in codice** («grammelot»: sillabe e tono di un vecchio re, senza parole vere, con il testo scritto sotto, come nei giochi di strategia classici). È tutta nostra: nessun dubbio sui diritti.
2. **Voce sintetica italiana con Piper** (motore MIT; voci italiane «riccardo», «paola», «serena»). Le voci sono addestrate su raccolte di registrazioni le cui licenze vanno controllate una per una prima di usarle in un gioco distribuito: «riccardo» viene dal dataset M-AILABS (in gran parte audiolibri LibriVox di pubblico dominio), ma il testo della licenza va letto prima. Serve installare Piper solo sul computer di sviluppo.
3. **Voce registrata da una persona** (il proprietario o un amico che firma il permesso): voce vera e diritti chiari.

Risposta (2026-11-02): **1, voce inventata**. Fatta nello step 36b.

## 2026-11-02 — Musica nuova: serve scaricare FluidSynth e un soundfont

La decisione è: musica con **FluidSynth** e un **soundfont orchestrale libero**, brani originali scritti in codice. Per farlo devo **scaricare e installare** due cose sul computer di sviluppo (non nel gioco):
1. FluidSynth (programma libero, licenza LGPL), circa 5–10 MB;
2. un soundfont libero, per esempio «GeneralUser GS» (licenza libera, si può usare nei giochi) o «FluidR3_GM» (MIT), circa 30–150 MB.

Le regole di lavoro mi chiedono il tuo permesso per scaricare file. Posso scaricarli?
★ Sì, scarica FluidSynth e GeneralUser GS · Sì, ma un altro soundfont · No, usa il sintetizzatore che c'è già (tools/suoni/musica.py)

Intanto vado avanti con il resto (step 40 e la chiusura).

Risposta: (in attesa)
