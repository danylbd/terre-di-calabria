# Terre di Calabria — Documento di design

*Versione 0.1 — step 00. Documento vivo: lo aggiorniamo man mano.*

## 1. L'idea in una frase

Guidi un popolo che approda in Calabria e costruisci un'economia in cui **ogni merce viene portata a mano** da piccoli abitanti, lungo strade che disegni tu, finché il tuo villaggio diventa abbastanza forte da difendere e allargare i propri confini.

## 2. Principi

1. **Si guarda vivere il villaggio.** Il piacere principale è osservare portatori, artigiani e contadini che lavorano. Niente risorse astratte che "appaiono" in un magazzino: tutto si muove.
2. **Catene lunghe ma leggibili.** Dal tronco all'asse, dal grano al pane, dal minerale alla spada. Ogni anello è un edificio e una persona.
3. **La Calabria è protagonista.** Montagne (Pollino, Sila, Serre, Aspromonte), due mari (Tirreno e Ionio), lo Stretto. Le risorse speciali vengono dalla storia della regione.
4. **Ritmo calmo.** La guerra c'è, ma arriva dopo l'economia. Si può giocare anche in modalità pacifica.
5. **Tutto originale.** Prendiamo l'ispirazione dai classici del genere, ma disegni, popoli, nomi e storia sono nostri.

> **Licenza poetica.** Mettiamo insieme popoli arrivati in epoche diverse (dall'VIII sec. a.C. all'XI sec. d.C.). È un gioco, non un libro di storia: i popoli convivono in un'unica "Calabria del mito".

## 3. I popoli

Cinque popoli giocabili. Condividono le catene base (legno, pietra, cibo, metallo) e ognuno ha **una catena speciale**, **un edificio unico** e **un'unità militare particolare**.

| Popolo | Da dove arriva | Carattere | Catena speciale | Edificio unico | Unità speciale |
|---|---|---|---|---|---|
| **Brettii** | Popolo nativo delle montagne | Pastori e guerrieri della Sila | Pece della Sila (resina → pece) | Pecificio | Fromboliere |
| **Greci** (Italioti) | Città sulla costa ionica | Commercio, olio e vino | Olio d'oliva | Agorà (mercato) | Oplita |
| **Romani** | Da nord, lungo la grande strada | Strade e ingegneria | Laterizi (argilla → mattoni → tegole) | Cantiere stradale | Legionario |
| **Saraceni** | Dal mare, dal sud | Agrumi, seta, irrigazione | Seta (gelso → bachi → filanda) | Noria (ruota idraulica) | Cavaliere leggero |
| **Normanni** | Dal nord, a cavallo | Castelli e cavalleria | Allevamento cavalli | Mastio | Cavaliere pesante |

### Abilità passive (prima proposta)

- **Brettii** — i portatori camminano più veloci in montagna e nei boschi.
- **Greci** — il mercato scambia merci con un rapporto più favorevole.
- **Romani** — le strade lastricate rendono i portatori più rapidi.
- **Saraceni** — i campi irrigati producono di più vicino ai fiumi.
- **Normanni** — le torri e i castelli espandono il territorio più lontano.

### Popoli per il futuro

Bizantini (monasteri e mosaici), Svevi (falconeria e castelli), Arbëreshë (comunità di villaggio e tessitura).

## 4. Le risorse

### Materie prime (comuni a tutti)

| Risorsa | Da dove | Chi la produce |
|---|---|---|
| Tronchi | Boschi (Sila, Aspromonte) | Boscaiolo |
| Pietra | Rocce e colline | Cavapietre |
| Argilla | Rive dei fiumi | Argillaio |
| Grano | Campi in pianura | Contadino |
| Acqua | Pozzi | Pozzaiolo |
| Pesce | Mare e fiumi | Pescatore |
| Maiali e pecore | Pascoli | Allevatore |
| Ferro | Miniere nelle Serre | Minatore |
| Carbone | Carbonaia nel bosco | Carbonaio |

### Risorse speciali della Calabria

| Risorsa | Luogo d'ispirazione | Uso nel gioco |
|---|---|---|
| **Sale di roccia** | Saline di Lungro | Conservare il cibo: il pesce e la carne salati durano di più |
| **Argento** | Miniere di Longobucco | Monete per pagare i soldati e commerciare |
| **Pece** | Foreste della Sila | Navi, difese, commercio (Brettii) |
| **Ulivi e olio** | Tutta la regione | Cibo pregiato e merce di scambio (Greci) |
| **Seta** | Gelsi di Catanzaro | Merce di lusso, aumenta la felicità (Saraceni) |
| **Agrumi e bergamotto** | Costa di Reggio | Cibo pregiato e profumi (Saraceni) |
| **Pesce spada** | Scilla e Bagnara | Cibo pregiato, pesca speciale nello Stretto |
| **Liquirizia** | Piana di Sibari | Medicina: cura i soldati feriti |
| **Cipolla rossa** | Tropea | Cibo per i minatori |

## 5. Le catene di produzione

```
LEGNO     Boscaiolo ──tronchi──▶ Segheria ──assi──▶ (costruzioni, navi, attrezzi)
          Guardaboschi ripianta gli alberi

PIETRA    Cavapietre ──pietra──▶ (costruzioni)

CIBO      Contadino ──grano──▶ Mulino ──farina──▶ Forno (+ acqua) ──pane──▶ minatori
          Pescatore ──pesce──▶ minatori
          Allevatore ──maiali──▶ Macelleria (+ sale) ──carne──▶ minatori, soldati

METALLO   Minatore ferro + Carbonaio ──▶ Fonderia ──lingotti──▶ Fabbro ──attrezzi──▶ nuovi artigiani
                                                              └──▶ Armaiolo ──armi──▶ caserma

MONETE    Minatore argento ──▶ Zecca ──monete──▶ paga soldati, commercio
```

**Regola base:** i minatori lavorano solo se ricevono cibo (pane, pesce o carne). Gli artigiani nascono da un portatore libero più l'attrezzo giusto: se mancano attrezzi, non si possono aprire nuovi edifici di quel tipo.

## 6. Come si gioca

### Il territorio
- Parti con un **Centro del villaggio** (magazzino + abitazione), un territorio iniziale e alcuni portatori.
- Si costruisce solo dentro i propri confini.
- I confini si allargano con **torri di guardia** e **castelli** presidiati da soldati.

### Strade e trasporto
- Le strade collegano gli edifici attraverso **bandierine** (nodi).
- Ogni tratto tra due bandierine ha **un portatore** che fa la spola.
- Le merci viaggiano di bandierina in bandierina; se un tratto è congestionato, conviene costruire una strada alternativa o aggiungere un asino da soma.
- Strade in salita = più lente; strade lastricate (Romani) = più veloci.

### Costruire
1. Scegli l'edificio e lo piazzi su un terreno libero.
2. Un **muratore** livella il terreno.
3. I portatori consegnano assi e pietre.
4. Finita la costruzione, arriva l'artigiano (se c'è l'attrezzo).

### Popolazione
- Le **abitazioni** producono nuovi portatori nel tempo.
- Le merci di lusso (vino, seta, agrumi) aumentano la crescita.

### Guerra (arriva dopo)
- Soldati su 3 livelli di esperienza, addestrati con armi e monete.
- Si conquistano torri nemiche: chi conquista una torre ne prende il territorio.
- Modalità **pacifica** senza nemici, per chi vuole solo costruire.

### Navi
- Porti sulle coste: commercio con altre città e trasporto tra Tirreno e Ionio.
- Pesca del pesce spada nello Stretto.

## 7. La mappa

Una Calabria **stilizzata**, non fedele al metro:

- **Nord:** il Pollino e la Piana di Sibari (pianura fertile, città greca).
- **Centro:** l'altopiano della Sila (boschi, pece, laghi) e l'istmo di Catanzaro (il punto più stretto, tra i due mari).
- **Sud:** le Serre (ferro), l'Aspromonte (montagne ripide), Reggio e lo Stretto.
- **Coste:** Tirreno (Tropea, Scilla) e Ionio (Crotone, Locri).

Oltre alla campagna ci saranno mappe libere più piccole (un'insenatura, una valle, un altopiano).

## 8. Campagna e storia

La storia completa è in [`storia.md`](storia.md): **Il Sigillo di Italo**, spezzato in cinque frammenti nascosti nel Pollino, nella Sila, nelle Serre, in Aspromonte e nello Stretto. Cinque campagne (una per popolo, 6 missioni ciascuna) più una campagna finale sulla Soglia, con due finali possibili. Narratore: il cantastorie Rocco della Lira. Antagonista: il Mercante senza Volto.

## 9. Stile grafico e suono

- **Visuale:** isometrica 2D, dall'alto, con zoom.
- **Stile:** pixel-art "dipinta" ad alta risoluzione, colori caldi e mediterranei.
- **Tavolozza:** ocra, terracotta, verde ulivo, verde bosco della Sila, blu ionio, bianco calce.
- **Interfaccia:** pannelli color pergamena e terracotta, icone chiare.
- **Ogni popolo ha i suoi edifici:** tetti in tegola (Romani), colonne e marmo chiaro (Greci), legno e pietra grezza (Brettii), cupole e archi (Saraceni), torri squadrate (Normanni).
- **Musica:** strumenti tradizionali del Sud (lira calabrese, zampogna, tamburello, chitarra battente), tutta originale.

## 10. Tecnica

- **Motore:** Godot 4.7, linguaggio GDScript.
- **Piattaforme:** Windows ARM64 (nativo, per il notebook Samsung), Windows x64; iPhone più avanti.
- **Installer:** wizard creato con Inno Setup (icona sul desktop, menu Start, disinstallazione).
- **Compilazione automatica:** GitHub Actions crea il `Setup.exe` a ogni versione.
- **Codice:** `src/` organizzato per sistemi (mappa, strade, trasporto, economia, popoli, interfaccia).
