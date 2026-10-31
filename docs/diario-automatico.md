# Diario dei turni automatici

Memoria tra un turno automatico e l'altro: in fondo l'ultimo turno.

## 2026-10-31 20:00 — step 05 prima catena
- Scritto `tools/test/test_catena.gd`: piazza boscaiolo, cava, segheria, guardaboschi, li collega e accelera il tempo. Risultato OK: alberi abbattuti, pietra estratta, 8 alberelli piantati, assi della segheria e pietra arrivano al magazzino.
- Trovato collo di bottiglia: il portatore rientrava sempre a metà tratto anche con una merce di ritorno già in attesa. Ora la riprende subito (`portatore.gd: puo_prendere`): assi in 6 minuti di gioco da 22 a 31.
- Screenshot in `docs/immagini/step05-catena.png`. Versione 0.6.0, roadmap e CLAUDE.md aggiornati, step unito a `main`.
- Resta / da tenere d'occhio: con una sola strada verso il magazzino si formano code (normale, il giocatore aggiunge strade). I tronchi del boscaiolo vanno al magazzino quando la segheria ha già 4 tronchi in arrivo: corretto ma fa fare giri in più.
- Prossimo: step M1 musica e suoni.
