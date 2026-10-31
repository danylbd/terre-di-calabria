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

Risposta:
