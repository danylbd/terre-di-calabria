# Campagna «Annibale nel Bruzio» (step 39, Fase 7)

La seconda guerra punica in Calabria (216–203 a.C.), sulla mappa del Bruzio (step 38). Sempre aperta, separata
dalle altre campagne. All'inizio si sceglie il lato: **Cartagine** (Annibale, gli elefanti, gli alleati Brettii) o
**Roma** (le legioni, le rocche, la pazienza del Temporeggiatore). Il narratore è sempre Rocco della Lira, con la
sua voce; parlano anche Annibale o Gaio Settimio, secondo il lato.

In queste missioni ci sono le **schiere** (con il condottiero, le macchine d'assedio e, per Cartagine,
l'elefante) e i **villaggi indigeni** del Bruzio (Petelia, Scolacium, Consentia).

| # | Id | Titolo | Obiettivi |
|---|---|---|---|
| 1 | `annibale_sbarco` | Il porto di Crotone | 50 coloni; il porto |
| 2 | `annibale_brettii` | I popoli della Sila | un villaggio alleato o conquistato; 70 coloni |
| 3 | `annibale_condottiero` | La schiera | una schiera di 10 soldati; una torre conquistata |
| 4 | `annibale_petelia` | L'assedio di Petelia | una macchina d'assedio; due torri conquistate |
| 5 | `annibale_lacinio` | Il tempio sul capo | 14 merci di lusso; 100 coloni |
| 6 | `annibale_marchesato` | La rocca del Marchesato | un castello presidiato; condottiero al livello 3 |
| 7 | `annibale_due_mari` | Tra i due mari | due villaggi; due torri conquistate |
| 8 | `annibale_partenza` | L'ultima estate | nessuna torre nemica rimasta |

Il nemico dipende dal lato: con Cartagine si combatte contro Roma (torri romane), con Roma contro i Brettii
alleati di Annibale. I racconti (`inizio`, `fine`, `dopo`) possono essere un dizionario per lato
(`{"cartaginesi": [...], "romani": [...]}`): `Missione.per_lato()` sceglie quello giusto.

Codice: `Missione.CAMPAGNA_ANNIBALE`, `LATI_ANNIBALE`, `lato_annibale()`, `scegli_lato_annibale()`, prove nuove
`villaggi`, `schiera`, `condottiero_livello`, `macchina`, `nemici_zero`; chiavi di missione `"popolo": "lato"`,
`"schiere": true`, `"indigeni": true`. Sulla mappa della Calabria: pulsanti «Annibale nel Bruzio» e «Gioca nel
Bruzio», con la scelta del lato. Test `tools/test/test_annibale.gd`.

Fatti storici usati (liberamente): Annibale nel Bruzio dopo Canne; i Brettii alleati di Cartagine; l'assedio di
Petelia, rimasta fedele a Roma; il tempio di Hera Lacinia e l'iscrizione bilingue di Annibale; la strategia di
Fabio Massimo il Temporeggiatore; la partenza di Annibale da Crotone nel 203 a.C.
