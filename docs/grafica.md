# Terre di Calabria — Piano della grafica

*Versione 0.2. Stile: modelli 3D pre-renderizzati in isometria.*

## 1. Come nasce la grafica

Il riferimento di qualità sono i classici del genere di fine anni '90: modelli 3D dettagliati, illuminati con cura e **fotografati dall'alto** per diventare sprite 2D ("pre-renderizzati"). Seguiamo lo stesso metodo, con modelli e disegni tutti nostri.

```
tools/studio/modelli.gd  ──▶  modello 3D (pietra, intonaco, coppi veri, legno…)
                         ──▶  luce del sole + ombre + camera isometrica (Godot)
                         ──▶  sprite PNG con ombra e sfondo trasparente  ──▶  assets/grafica/
```

**Lezioni dai classici che applichiamo:**
- **Edifici "vissuti":** texture dipinte e poi sporcate, niente superfici perfette.
- **Persone piccole ma leggibili:** teste e attrezzi leggermente esagerati, così si capisce cosa fanno anche a 40 pixel.
- **Animazioni per ogni azione:** camminare, portare, tagliare, segare, ognuna con i suoi fotogrammi.
- **Terreno continuo e dipinto**, non a quadretti.

**Perché in codice:** coerenza di luce e proporzioni, modifiche rapide ("tetti più scuri" = una riga), rigenerazione di tutto con un comando, tutto originale.

**Comando:** `godot --path . --rendering-driver opengl3 --script tools/studio/studio.gd -- assets/grafica [modelli...]`

## 2. Regole fisse

| Regola | Valore |
|---|---|
| Casella isometrica | 112 × 56 pixel (rapporto 2:1) |
| Zoom nel gioco | 50%, 100%, 200% |
| Luce | dall'alto a sinistra; ombre verso destra-basso |
| Facce degli oggetti | sinistra illuminata, destra in ombra (−22%) |
| Punto di ancoraggio | centro della casella a terra (scritto in `sprite.json`) |
| Altezza persone | circa 0,8 caselle (45 px) |
| Edifici piccoli | 1 × 1 casella; grandi 2 × 1 o 2 × 2 |
| Tavolozza | `src/core/palette.gd` e `tools/arte/arte.py` (stessi valori) |
| Colore del giocatore | bandiere, fasce sulle tuniche, vele: si ricolora per ogni giocatore |

## 3. Cosa migliorare rispetto ai primi esempi

1. **Passaggi tra terreni:** bordi morbidi prato/sabbia/mare, schiuma sulla riva, invece dei rombi netti.
2. **Varietà:** 4–6 varianti per ogni casella di terreno e per ogni albero, scelte a caso.
3. **Dettagli del terreno:** ciuffi d'erba, sassi, fiori, solchi nei campi.
4. **Montagne vere:** rilievi su più caselle, pendii, rocce e neve solo in cima.
5. **Acqua viva:** onde animate, riflessi, fiumi e fiumare con letto sassoso.
6. **Animazioni:** portatori che camminano (4 direzioni), bandiere al vento, fumo dai comignoli, ruota della segheria, alberi che ondeggiano, vele.
7. **Mestieri riconoscibili:** ogni lavoratore con il suo attrezzo e la sua animazione (ascia, sega, falce, rete, martello).
8. **Identità dei popoli:** ogni popolo ha forme, materiali e colori propri (vedi §5).
9. **Cantieri in fasi:** fondamenta → muri → tetto, visibili mentre si costruisce.
10. **Luce del giorno e stagioni:** alba, giorno, tramonto; inverno con neve in montagna.

## 4. Fasi di lavoro

| Fase | Contenuto | Stato |
|---|---|---|
| **G1** | Studio di rendering 3D; casa, magazzino, boscaiolo, segheria, frantoio; pino, ulivo; portatore animato (8 direzioni × 8 passi, 4 carichi) | fatto, da rifinire |
| G2 | Edifici "vissuti" e più grandi, alberi frondosi (castagno, quercia, pino laricio, ulivo), decorazioni, terreno saturo e granuloso, materiale con sporco e finta occlusione | fatto |
| G3 | Tutti gli edifici greci (≈ 20) con cantiere in 3 fasi | |
| G4 | Mestieri: 12 lavoratori animati; soldati greci | |
| G5 | Interfaccia: icone di tutte le merci, pulsanti, pannelli, cursori | |
| G6 | Brettii, Romani, Saraceni, Normanni, Siculi, Sicani (edifici + persone) | in corso: Brettii completi (v0.35.0, step G6a); gli altri popoli hanno 15–16 edifici propri e 24 ancora con l'aspetto greco |
| G7 | Effetti: fumo, polvere, fuoco, onde, uccelli; luce del giorno e stagioni | |
| G8 | Ritratti dei personaggi e illustrazioni della storia | |

## 5. Identità visiva dei popoli

| Popolo | Muri | Tetti | Dettagli | Colore giocatore suggerito |
|---|---|---|---|---|
| Greci | intonaco bianco a calce | tegole in terracotta, poco inclinati | colonne, frontoni, anfore | azzurro Ionio |
| Brettii | pietra grezza e legno | paglia e scandole di legno | recinti, pelli, totem di legno | verde bosco |
| Romani | mattoni e intonaco ocra | tegole e coppi | archi, strade lastricate, cippi | rosso pompeiano |
| Saraceni | intonaco chiaro e terra cruda | terrazze piatte, cupole | archi a ferro di cavallo, giardini, norie | verde smeraldo |
| Normanni | pietra squadrata grigia | ardesia scura | torri merlate, palizzate, stendardi | giallo oro |

## 6. Elenco degli sprite di G1

- **Terreno:** prato (4 varianti), bosco, sabbia, grano, roccia, mare (4 fotogrammi animati), mare profondo
- **Natura:** pino della Sila (3 varianti), ulivo (3 varianti), cespuglio, rocce
- **Monti:** collina, monte, vetta innevata
- **Edifici greci:** magazzino, casa, boscaiolo, segheria, frantoio, cantiere
- **Persone:** portatore che cammina (4 fotogrammi × 2 direzioni base, specchiabili) con 6 carichi diversi
- **Varie:** bandierina (4 fotogrammi), nave

## 7. Da rifinire dopo G1

- Tetti: tono della terracotta meno acceso, coppi più irregolari.
- Ulivi: chioma più sfrangiata e argentata, tronco contorto più visibile.
- Terreno: macchie meno marcate, più dettaglio fine (ciuffi, sassi, fiori).
- Persone: visi, capelli vari, tuniche di colori diversi; pose di lavoro.
- Edifici: più "sporcizia" (muschio alla base, macchie di pioggia), più oggetti attorno.
- Ombre a terra un po' più morbide.

Anteprima: `python3 tools/studio/anteprima.py assets/grafica docs/immagini/g1-villaggio.png`
