extends RefCounted
## Modelli 3D costruiti in codice per lo studio di rendering.
## Unità: 1 = una casella. Asse Y verso l'alto. La camera guarda dal lato +X/+Z,
## quindi le facce "in vista" sono +Z (sinistra, illuminata) e +X (destra, in ombra).

static var _cache_mat := {}
static var _rumore_rgb: ImageTexture
const SHADER_VISSUTO := preload("res://tools/studio/vissuto.gdshader")

# materiali che restano "semplici" (metallo, stoffa sottile, acqua)
const MATERIALI_SEMPLICI := ["ferro", "stoffa", "acqua_pozzo", "buio", "mare", "pece", "acqua_chiara", "vapore", "maglia", "ossidiana", "riflesso_oss"]
# regolazioni per materiale: [sporco, macchie, saturazione]
const REGOLAZIONI := {
	"aghi": [0.0, 0.0, 1.3], "foglie_ulivo": [0.0, 0.0, 1.2], "foglie": [0.0, 0.0, 1.15], "foglie_scure": [0.0, 0.0, 1.1],
	"macchia": [0.0, 0.0, 1.3], "fiore": [0.0, 0.0, 1.2], "tegola": [0.15, 0.5, 1.0], "tegola_scura": [0.15, 0.5, 1.0],
	"marmo": [0.35, 0.3, 1.0], "intonaco": [0.55, 0.45, 1.1], "tunica": [0.0, 0.0, 1.1], "pelle": [0.0, 0.0, 1.1],
	"capelli": [0.0, 0.0, 1.0], "giocatore": [0.0, 0.0, 1.3], "sandali": [0.0, 0.0, 1.0], "corda": [0.0, 0.0, 1.0],
	"persiana": [0.2, 0.3, 1.2], "lino": [0.2, 0.2, 1.1], "terracotta": [0.25, 0.3, 1.25],
	"tegola_b": [0.15, 0.5, 1.0], "tegola_c": [0.15, 0.5, 1.0], "orto": [0.0, 0.0, 1.3], "geranio": [0.0, 0.0, 1.3],
	"foglie_chiare": [0.0, 0.0, 1.15], "paglia": [0.2, 0.2, 1.15], "terra": [0.0, 0.3, 1.1], "pietra_vista": [0.5, 0.4, 1.1],
	"bandiera_rossa": [0.0, 0.0, 1.2], "grano": [0.0, 0.1, 1.25], "grano_verde": [0.0, 0.0, 1.25], "pane": [0.1, 0.2, 1.2],
	"pesce": [0.0, 0.0, 1.0], "rete": [0.1, 0.1, 1.0], "asino": [0.0, 0.1, 1.0], "maiale": [0.0, 0.2, 1.1],
	"lana": [0.1, 0.2, 1.0], "pelle_scura": [0.0, 0.0, 1.0], "capra": [0.0, 0.1, 1.0], "carne": [0.0, 0.1, 1.15],
	"formaggio": [0.1, 0.2, 1.1], "miele": [0.0, 0.0, 1.2], "latte": [0.0, 0.0, 1.0], "uva": [0.0, 0.0, 1.2],
	"cipolla": [0.0, 0.1, 1.2], "arancia": [0.0, 0.0, 1.25], "bergamotto": [0.0, 0.0, 1.2], "oliva": [0.0, 0.0, 1.1],
	"vino": [0.0, 0.0, 1.1], "spada": [0.0, 0.0, 1.0], "minerale": [0.3, 0.3, 1.15], "carbone": [0.0, 0.0, 1.0],
	"lingotto": [0.1, 0.1, 1.0], "brace": [0.0, 0.0, 1.3], "fumo": [0.0, 0.0, 1.0], "argilla": [0.2, 0.2, 1.15],
	"argilla_cruda": [0.3, 0.3, 1.05], "sale": [0.1, 0.1, 1.0], "moneta": [0.0, 0.0, 1.1], "argento_grezzo": [0.2, 0.2, 1.0],
	"stoffa_rossa": [0.0, 0.0, 1.15], "bronzo": [0.1, 0.1, 1.1], "pelliccia": [0.1, 0.2, 1.0],
	"intonaco_bianco": [0.3, 0.35, 1.0], "intonaco_giallo": [0.4, 0.4, 1.1], "blocchi_greci": [0.35, 0.3, 1.05],
	"roccia_chiara": [0.3, 0.4, 1.0], "sabbia": [0.1, 0.2, 1.05], "maiolica": [0.0, 0.1, 1.2], "piombo": [0.2, 0.2, 1.0],
	"pietra_grezza": [0.5, 0.4, 1.05], "paglia_scura": [0.2, 0.3, 1.05], "paglia_tetto": [0.2, 0.35, 1.05], "stoffa_verde": [0.0, 0.0, 1.15], "osso": [0.1, 0.15, 1.0],
	"mattoni": [0.3, 0.3, 1.1], "intonaco_ocra": [0.45, 0.4, 1.15], "laterizio": [0.2, 0.45, 1.05], "laterizio_scuro": [0.15, 0.4, 1.05],
	"rosso_pompeiano": [0.25, 0.3, 1.15], "stoffa_pompeiana": [0.0, 0.0, 1.15], "basoli": [0.3, 0.3, 1.0],
	"calce": [0.3, 0.3, 1.0], "terra_cruda": [0.3, 0.35, 1.1], "mattoni_crudi": [0.3, 0.35, 1.1], "maiolica_verde": [0.0, 0.05, 1.15],
	"zellige": [0.0, 0.05, 1.1], "stoffa_smeraldo": [0.0, 0.0, 1.2], "smeraldo": [0.0, 0.0, 1.2], "tenda_verde": [0.05, 0.05, 1.1],
	"tenda_rossa": [0.05, 0.05, 1.1], "canne": [0.15, 0.25, 1.05], "seta_verde": [0.0, 0.0, 1.25], "seta_cremisi": [0.0, 0.0, 1.25],
	"seta_oro": [0.0, 0.0, 1.25], "seta_azzurra": [0.0, 0.0, 1.25], "seta_zafferano": [0.0, 0.0, 1.25], "bozzolo": [0.0, 0.05, 1.0],
	"cavallo": [0.0, 0.05, 1.0], "cavallo_muso": [0.0, 0.0, 1.0], "crine": [0.0, 0.0, 1.0], "lino_bianco": [0.0, 0.05, 1.0],
	"legno_verde": [0.15, 0.25, 1.15], "schiuma": [0.0, 0.0, 1.0], "battuto": [0.2, 0.3, 1.0], "cammello": [0.0, 0.1, 1.05],
	"pietra_normanna": [0.4, 0.35, 1.0], "pietra_n_scura": [0.35, 0.3, 1.0], "pietra_n_chiara": [0.3, 0.3, 1.0],
	"ardesia": [0.1, 0.3, 1.0], "ardesia_b": [0.1, 0.3, 1.0], "graticcio_n": [0.4, 0.4, 1.05], "stoffa_oro": [0.0, 0.0, 1.2],
	"oro_n": [0.0, 0.0, 1.15], "cavallo_baio": [0.0, 0.05, 1.05], "prato": [0.1, 0.2, 1.0],
	"argilla_sic": [0.35, 0.35, 1.1], "pietra_secca": [0.35, 0.35, 1.0], "canne_sic": [0.25, 0.3, 1.0], "frasche": [0.1, 0.2, 1.1],
	"ocra_rossa": [0.0, 0.0, 1.15], "ceramica": [0.15, 0.2, 1.05], "vernice_rossa": [0.05, 0.1, 1.15], "vernice_nera": [0.0, 0.0, 1.0],
	"cuoio": [0.05, 0.1, 1.05], "tunica_ocra": [0.0, 0.0, 1.1],
	"pietra_sicana": [0.4, 0.35, 1.0], "sasso_sic": [0.3, 0.3, 1.0], "lastra_sic": [0.3, 0.35, 1.0], "erba_tetto": [0.05, 0.15, 1.15],
	"lapislazzuli": [0.0, 0.0, 1.2], "tunica_lapis": [0.0, 0.0, 1.1],
}


static func catalogo() -> Dictionary:
	var c := {
		"casa_greca": {"crea": casa_greca.bind(1)},
		"magazzino": {"crea": magazzino},
		"boscaiolo": {"crea": boscaiolo},
		"segheria": {"crea": segheria},
		"frantoio": {"crea": frantoio},
		"cava": {"crea": cava},
		"guardaboschi": {"crea": guardaboschi},
		"torre": {"crea": torre},
		"pozzo": {"crea": pozzo},
		"fattoria": {"crea": fattoria},
		"mulino": {"crea": mulino},
		"forno": {"crea": forno},
		"pescatore": {"crea": capanna_pescatore},
		"porto": {"crea": porto},
		"porcile": {"crea": porcile},
		"macelleria": {"crea": macelleria},
		"ovile": {"crea": ovile},
		"capraio": {"crea": capraio},
		"apiario": {"crea": apiario},
		"caseificio": {"crea": caseificio},
		"uliveto": {"crea": uliveto},
		"vigneto": {"crea": vigneto},
		"cantina": {"crea": cantina},
		"ortolano": {"crea": ortolano},
		"agrumeto": {"crea": agrumeto},
		"pesca_spada": {"crea": pesca_spada},
		"miniera_ferro": {"crea": miniera_ferro},
		"carbonaia": {"crea": carbonaia},
		"fonderia": {"crea": fonderia},
		"fabbro": {"crea": fabbro},
		"miniera_argento": {"crea": miniera_ferro.bind("argento_grezzo")},
		"zecca": {"crea": zecca},
		"argillaio": {"crea": argillaio},
		"fornace": {"crea": fornace},
		"saline": {"crea": saline},
		"tessitura": {"crea": tessitura},
		"agora": {"crea": agora},
		"castello": {"crea": castello},
		"armaiolo": {"crea": armaiolo},
		"caserma": {"crea": caserma},
		"torre_brettia": {"crea": torre_brettia},
		"mura_greche": {"crea": mura_greche},
		"tempio_proserpina": {"crea": tempio_proserpina},
		"porto_santa_venere": {"crea": porto_santa_venere},
		"foro_valentia": {"crea": foro_valentia},
		"castello_normanno": {"crea": castello_normanno},
		"duomo": {"crea": duomo},
		"chiesa_rosario": {"crea": chiesa_rosario},
		"valentianum": {"crea": valentianum},
		"tonnara_bivona": {"crea": tonnara_bivona},
		"castello_pizzo": {"crea": castello_pizzo},
		"santa_maria_isola": {"crea": santa_maria_isola},
		"casa_greca_brettii": {"crea": casa_greca_brettii.bind(1)},
		"magazzino_brettii": {"crea": magazzino_brettii},
		"boscaiolo_brettii": {"crea": boscaiolo_brettii},
		"segheria_brettii": {"crea": segheria_brettii},
		"cava_brettii": {"crea": cava_brettii},
		"guardaboschi_brettii": {"crea": guardaboschi_brettii},
		"pozzo_brettii": {"crea": pozzo_brettii},
		"fattoria_brettii": {"crea": fattoria_brettii},
		"mulino_brettii": {"crea": mulino_brettii},
		"forno_brettii": {"crea": forno_brettii},
		"ovile_brettii": {"crea": ovile_brettii},
		"capraio_brettii": {"crea": capraio_brettii},
		"caserma_brettii": {"crea": caserma_brettii},
		"castello_brettii": {"crea": castello_brettii},
		"pecificio": {"crea": pecificio},
		"merce_pece": {"crea": merce.bind("pece")},
		"porcile_brettii": {"crea": porcile_brettii},
		"macelleria_brettii": {"crea": macelleria_brettii},
		"apiario_brettii": {"crea": apiario_brettii},
		"caseificio_brettii": {"crea": caseificio_brettii},
		"argillaio_brettii": {"crea": argillaio_brettii},
		"fornace_brettii": {"crea": fornace_brettii},
		"saline_brettii": {"crea": saline_brettii},
		"tessitura_brettii": {"crea": tessitura_brettii},
		"pescatore_brettii": {"crea": capanna_pescatore_brettii},
		"frantoio_brettii": {"crea": frantoio_brettii},
		"uliveto_brettii": {"crea": uliveto_brettii},
		"vigneto_brettii": {"crea": vigneto_brettii},
		"cantina_brettii": {"crea": cantina_brettii},
		"ortolano_brettii": {"crea": ortolano_brettii},
		"agrumeto_brettii": {"crea": agrumeto_brettii},
		"pesca_spada_brettii": {"crea": pesca_spada_brettii},
		"miniera_ferro_brettii": {"crea": miniera_ferro_brettii},
		"miniera_argento_brettii": {"crea": miniera_ferro_brettii.bind("argento_grezzo")},
		"zecca_brettii": {"crea": zecca_brettii},
		"armaiolo_brettii": {"crea": armaiolo_brettii},
		"porto_brettii": {"crea": porto_brettii},
		"carbonaia_brettii": {"crea": carbonaia_brettii},
		"fonderia_brettii": {"crea": fonderia_brettii},
		"fabbro_brettii": {"crea": fabbro_brettii},
		"casa_greca_romani": {"crea": casa_greca_romani.bind(1)},
		"magazzino_romani": {"crea": magazzino_romani},
		"boscaiolo_romani": {"crea": boscaiolo_romani},
		"segheria_romani": {"crea": segheria_romani},
		"cava_romani": {"crea": cava_romani},
		"guardaboschi_romani": {"crea": guardaboschi_romani},
		"pozzo_romani": {"crea": pozzo_romani},
		"fattoria_romani": {"crea": fattoria_romani},
		"mulino_romani": {"crea": mulino_romani},
		"forno_romani": {"crea": forno_romani},
		"ovile_romani": {"crea": ovile_romani},
		"capraio_romani": {"crea": capraio_romani},
		"caserma_romani": {"crea": caserma_romani},
		"castello_romani": {"crea": castello_romani},
		"torre_romani": {"crea": torre_romani},
		"laterizi": {"crea": laterizi},
		"merce_tegole": {"crea": merce.bind("tegole")},
		"porcile_romani": {"crea": porcile_romani},
		"macelleria_romani": {"crea": macelleria_romani},
		"apiario_romani": {"crea": apiario_romani},
		"caseificio_romani": {"crea": caseificio_romani},
		"argillaio_romani": {"crea": argillaio_romani},
		"fornace_romani": {"crea": fornace_romani},
		"saline_romani": {"crea": saline_romani},
		"tessitura_romani": {"crea": tessitura_romani},
		"pescatore_romani": {"crea": capanna_pescatore_romani},
		"frantoio_romani": {"crea": frantoio_romani},
		"uliveto_romani": {"crea": uliveto_romani},
		"vigneto_romani": {"crea": vigneto_romani},
		"cantina_romani": {"crea": cantina_romani},
		"ortolano_romani": {"crea": ortolano_romani},
		"agrumeto_romani": {"crea": agrumeto_romani},
		"pesca_spada_romani": {"crea": pesca_spada_romani},
		"miniera_ferro_romani": {"crea": miniera_ferro_romani},
		"miniera_argento_romani": {"crea": miniera_ferro_romani.bind("argento_grezzo")},
		"zecca_romani": {"crea": zecca_romani},
		"armaiolo_romani": {"crea": armaiolo_romani},
		"porto_romani": {"crea": porto_romani},
		"carbonaia_romani": {"crea": carbonaia_romani},
		"fonderia_romani": {"crea": fonderia_romani},
		"fabbro_romani": {"crea": fabbro_romani},
		"casa_greca_saraceni": {"crea": casa_greca_saraceni.bind(1)},
		"magazzino_saraceni": {"crea": magazzino_saraceni},
		"boscaiolo_saraceni": {"crea": boscaiolo_saraceni},
		"segheria_saraceni": {"crea": segheria_saraceni},
		"cava_saraceni": {"crea": cava_saraceni},
		"guardaboschi_saraceni": {"crea": guardaboschi_saraceni},
		"pozzo_saraceni": {"crea": pozzo_saraceni},
		"fattoria_saraceni": {"crea": fattoria_saraceni},
		"mulino_saraceni": {"crea": mulino_saraceni},
		"forno_saraceni": {"crea": forno_saraceni},
		"ovile_saraceni": {"crea": ovile_saraceni},
		"capraio_saraceni": {"crea": capraio_saraceni},
		"caserma_saraceni": {"crea": caserma_saraceni},
		"castello_saraceni": {"crea": castello_saraceni},
		"torre_saraceni": {"crea": torre_saraceni},
		"bachicoltura": {"crea": bachicoltura},
		"filanda": {"crea": filanda},
		"merce_bozzoli": {"crea": merce.bind("bozzoli")},
		"merce_seta": {"crea": merce.bind("seta")},
		"porcile_saraceni": {"crea": porcile_saraceni},
		"macelleria_saraceni": {"crea": macelleria_saraceni},
		"apiario_saraceni": {"crea": apiario_saraceni},
		"caseificio_saraceni": {"crea": caseificio_saraceni},
		"argillaio_saraceni": {"crea": argillaio_saraceni},
		"fornace_saraceni": {"crea": fornace_saraceni},
		"saline_saraceni": {"crea": saline_saraceni},
		"tessitura_saraceni": {"crea": tessitura_saraceni},
		"pescatore_saraceni": {"crea": capanna_pescatore_saraceni},
		"frantoio_saraceni": {"crea": frantoio_saraceni},
		"uliveto_saraceni": {"crea": uliveto_saraceni},
		"vigneto_saraceni": {"crea": vigneto_saraceni},
		"cantina_saraceni": {"crea": cantina_saraceni},
		"ortolano_saraceni": {"crea": ortolano_saraceni},
		"agrumeto_saraceni": {"crea": agrumeto_saraceni},
		"pesca_spada_saraceni": {"crea": pesca_spada_saraceni},
		"miniera_ferro_saraceni": {"crea": miniera_ferro_saraceni},
		"miniera_argento_saraceni": {"crea": miniera_ferro_saraceni.bind("argento_grezzo")},
		"zecca_saraceni": {"crea": zecca_saraceni},
		"armaiolo_saraceni": {"crea": armaiolo_saraceni},
		"porto_saraceni": {"crea": porto_saraceni},
		"carbonaia_saraceni": {"crea": carbonaia_saraceni},
		"fonderia_saraceni": {"crea": fonderia_saraceni},
		"fabbro_saraceni": {"crea": fabbro_saraceni},
		"casa_greca_normanni": {"crea": casa_greca_normanni.bind(1)},
		"magazzino_normanni": {"crea": magazzino_normanni},
		"boscaiolo_normanni": {"crea": boscaiolo_normanni},
		"segheria_normanni": {"crea": segheria_normanni},
		"cava_normanni": {"crea": cava_normanni},
		"guardaboschi_normanni": {"crea": guardaboschi_normanni},
		"pozzo_normanni": {"crea": pozzo_normanni},
		"fattoria_normanni": {"crea": fattoria_normanni},
		"mulino_normanni": {"crea": mulino_normanni},
		"forno_normanni": {"crea": forno_normanni},
		"ovile_normanni": {"crea": ovile_normanni},
		"capraio_normanni": {"crea": capraio_normanni},
		"caserma_normanni": {"crea": caserma_normanni},
		"castello_normanni": {"crea": castello_normanni},
		"torre_normanni": {"crea": torre_normanni},
		"allevamento_cavalli": {"crea": allevamento_cavalli},
		"mastio": {"crea": mastio},
		"porcile_normanni": {"crea": porcile_normanni},
		"macelleria_normanni": {"crea": macelleria_normanni},
		"apiario_normanni": {"crea": apiario_normanni},
		"caseificio_normanni": {"crea": caseificio_normanni},
		"argillaio_normanni": {"crea": argillaio_normanni},
		"fornace_normanni": {"crea": fornace_normanni},
		"saline_normanni": {"crea": saline_normanni},
		"tessitura_normanni": {"crea": tessitura_normanni},
		"pescatore_normanni": {"crea": capanna_pescatore_normanni},
		"frantoio_normanni": {"crea": frantoio_normanni},
		"uliveto_normanni": {"crea": uliveto_normanni},
		"vigneto_normanni": {"crea": vigneto_normanni},
		"cantina_normanni": {"crea": cantina_normanni},
		"ortolano_normanni": {"crea": ortolano_normanni},
		"agrumeto_normanni": {"crea": agrumeto_normanni},
		"pesca_spada_normanni": {"crea": pesca_spada_normanni},
		"miniera_ferro_normanni": {"crea": miniera_ferro_normanni},
		"miniera_argento_normanni": {"crea": miniera_ferro_normanni.bind("argento_grezzo")},
		"zecca_normanni": {"crea": zecca_normanni},
		"armaiolo_normanni": {"crea": armaiolo_normanni},
		"porto_normanni": {"crea": porto_normanni},
		"carbonaia_normanni": {"crea": carbonaia_normanni},
		"fonderia_normanni": {"crea": fonderia_normanni},
		"fabbro_normanni": {"crea": fabbro_normanni},
		"casa_greca_siculi": {"crea": casa_greca_siculi.bind(1)},
		"magazzino_siculi": {"crea": magazzino_siculi},
		"boscaiolo_siculi": {"crea": boscaiolo_siculi},
		"segheria_siculi": {"crea": segheria_siculi},
		"cava_siculi": {"crea": cava_siculi},
		"guardaboschi_siculi": {"crea": guardaboschi_siculi},
		"pozzo_siculi": {"crea": pozzo_siculi},
		"fattoria_siculi": {"crea": fattoria_siculi},
		"mulino_siculi": {"crea": mulino_siculi},
		"forno_siculi": {"crea": forno_siculi},
		"ovile_siculi": {"crea": ovile_siculi},
		"capraio_siculi": {"crea": capraio_siculi},
		"caserma_siculi": {"crea": caserma_siculi},
		"castello_siculi": {"crea": castello_siculi},
		"torre_siculi": {"crea": torre_siculi},
		"vasaio": {"crea": vasaio},
		"porcile_siculi": {"crea": porcile_siculi},
		"macelleria_siculi": {"crea": macelleria_siculi},
		"apiario_siculi": {"crea": apiario_siculi},
		"caseificio_siculi": {"crea": caseificio_siculi},
		"argillaio_siculi": {"crea": argillaio_siculi},
		"fornace_siculi": {"crea": fornace_siculi},
		"saline_siculi": {"crea": saline_siculi},
		"tessitura_siculi": {"crea": tessitura_siculi},
		"pescatore_siculi": {"crea": capanna_pescatore_siculi},
		"frantoio_siculi": {"crea": frantoio_siculi},
		"uliveto_siculi": {"crea": uliveto_siculi},
		"vigneto_siculi": {"crea": vigneto_siculi},
		"cantina_siculi": {"crea": cantina_siculi},
		"ortolano_siculi": {"crea": ortolano_siculi},
		"agrumeto_siculi": {"crea": agrumeto_siculi},
		"pesca_spada_siculi": {"crea": pesca_spada_siculi},
		"miniera_ferro_siculi": {"crea": miniera_ferro_siculi},
		"miniera_argento_siculi": {"crea": miniera_ferro_siculi.bind("argento_grezzo")},
		"zecca_siculi": {"crea": zecca_siculi},
		"armaiolo_siculi": {"crea": armaiolo_siculi},
		"porto_siculi": {"crea": porto_siculi},
		"carbonaia_siculi": {"crea": carbonaia_siculi},
		"fonderia_siculi": {"crea": fonderia_siculi},
		"fabbro_siculi": {"crea": fabbro_siculi},
		"casa_greca_sicani": {"crea": casa_greca_sicani.bind(1)},
		"magazzino_sicani": {"crea": magazzino_sicani},
		"boscaiolo_sicani": {"crea": boscaiolo_sicani},
		"segheria_sicani": {"crea": segheria_sicani},
		"cava_sicani": {"crea": cava_sicani},
		"guardaboschi_sicani": {"crea": guardaboschi_sicani},
		"pozzo_sicani": {"crea": pozzo_sicani},
		"fattoria_sicani": {"crea": fattoria_sicani},
		"mulino_sicani": {"crea": mulino_sicani},
		"forno_sicani": {"crea": forno_sicani},
		"ovile_sicani": {"crea": ovile_sicani},
		"capraio_sicani": {"crea": capraio_sicani},
		"caserma_sicani": {"crea": caserma_sicani},
		"castello_sicani": {"crea": castello_sicani},
		"torre_sicani": {"crea": torre_sicani},
		"porcile_sicani": {"crea": porcile_sicani},
		"macelleria_sicani": {"crea": macelleria_sicani},
		"apiario_sicani": {"crea": apiario_sicani},
		"caseificio_sicani": {"crea": caseificio_sicani},
		"argillaio_sicani": {"crea": argillaio_sicani},
		"fornace_sicani": {"crea": fornace_sicani},
		"saline_sicani": {"crea": saline_sicani},
		"tessitura_sicani": {"crea": tessitura_sicani},
		"pescatore_sicani": {"crea": capanna_pescatore_sicani},
		"frantoio_sicani": {"crea": frantoio_sicani},
		"uliveto_sicani": {"crea": uliveto_sicani},
		"vigneto_sicani": {"crea": vigneto_sicani},
		"cantina_sicani": {"crea": cantina_sicani},
		"ortolano_sicani": {"crea": ortolano_sicani},
		"agrumeto_sicani": {"crea": agrumeto_sicani},
		"pesca_spada_sicani": {"crea": pesca_spada_sicani},
		"miniera_ferro_sicani": {"crea": miniera_ferro_sicani},
		"miniera_argento_sicani": {"crea": miniera_ferro_sicani.bind("argento_grezzo")},
		"zecca_sicani": {"crea": zecca_sicani},
		"armaiolo_sicani": {"crea": armaiolo_sicani},
		"porto_sicani": {"crea": porto_sicani},
		"carbonaia_sicani": {"crea": carbonaia_sicani},
		"fonderia_sicani": {"crea": fonderia_sicani},
		"fabbro_sicani": {"crea": fabbro_sicani},
		"ossidiana": {"crea": ossidiana},
		"merce_lame": {"crea": merce.bind("lame")},
		"merce_cavalli": {"crea": merce.bind("cavalli")},
		"merce_ceramiche": {"crea": merce.bind("ceramiche")},
		"merce_armi": {"crea": merce.bind("armi")},
		"cantiere_0": {"crea": cantiere.bind(0)},
		"cantiere_1": {"crea": cantiere.bind(1)},
		"cantiere_2": {"crea": cantiere.bind(2)},
		"bandierina": {"crea": bandierina},
		"merce_assi": {"crea": merce.bind("assi")},
		"merce_tronchi": {"crea": merce.bind("tronchi")},
		"merce_pietra": {"crea": merce.bind("pietra")},
		"merce_grano": {"crea": merce.bind("grano")},
		"merce_farina": {"crea": merce.bind("farina")},
		"merce_pane": {"crea": merce.bind("pane")},
		"merce_acqua": {"crea": merce.bind("acqua")},
		"merce_pesce": {"crea": merce.bind("pesce")},
		"merce_maiale": {"crea": merce.bind("maiale")},
		"merce_carne": {"crea": merce.bind("carne")},
		"merce_latte": {"crea": merce.bind("latte")},
		"merce_lana": {"crea": merce.bind("lana")},
		"merce_formaggio": {"crea": merce.bind("formaggio")},
		"merce_miele": {"crea": merce.bind("miele")},
		"merce_olive": {"crea": merce.bind("olive")},
		"merce_olio": {"crea": merce.bind("olio")},
		"merce_uva": {"crea": merce.bind("uva")},
		"merce_vino": {"crea": merce.bind("vino")},
		"merce_ortaggi": {"crea": merce.bind("ortaggi")},
		"merce_cipolle": {"crea": merce.bind("cipolle")},
		"merce_agrumi": {"crea": merce.bind("agrumi")},
		"merce_pesce_spada": {"crea": merce.bind("pesce_spada")},
		"merce_ferro": {"crea": merce.bind("ferro")},
		"merce_carbone": {"crea": merce.bind("carbone")},
		"merce_lingotti": {"crea": merce.bind("lingotti")},
		"merce_argilla": {"crea": merce.bind("argilla")},
		"merce_anfore": {"crea": merce.bind("anfore")},
		"merce_sale": {"crea": merce.bind("sale")},
		"merce_argento": {"crea": merce.bind("argento")},
		"merce_ducati": {"crea": merce.bind("ducati")},
		"merce_stoffa": {"crea": merce.bind("stoffa")},
		"stoppie": {"crea": stoppie},
		"cespuglio_1": {"crea": cespuglio.bind(1)},
		"cespuglio_2": {"crea": cespuglio.bind(2)},
		"fiori_1": {"crea": fiori.bind(1)},
		"fiori_2": {"crea": fiori.bind(2)},
		"funghi": {"crea": funghi.bind(3)},
		"rocce_1": {"crea": rocce.bind(1)},
		"rocce_2": {"crea": rocce.bind(2)},
		"rocce_3": {"crea": rocce.bind(3)},
	}
	# alberi: più varianti per specie
	for k in 4:
		c["pino_%d" % (k + 1)] = {"crea": pino_laricio.bind(k + 1)}
		c["castagno_%d" % (k + 1)] = {"crea": castagno.bind(k + 11)}
		c["quercia_%d" % (k + 1)] = {"crea": quercia.bind(k + 21)}
	for k in 3:
		c["ulivo_%d" % (k + 1)] = {"crea": ulivo.bind(k + 3)}
	# risorse naturali che cambiano: ceppo, alberelli che crescono, rocce consumate
	c["ceppo"] = {"crea": ceppo}
	for k in 3:
		c["alberello_%d" % (k + 1)] = {"crea": alberello.bind(k)}
	for k in 4:
		c["campo_%d" % (k + 1)] = {"crea": campo.bind(k)}
		c["vite_%d" % (k + 1)] = {"crea": vite.bind(k)}
		c["orto_%d" % (k + 1)] = {"crea": orto_campo.bind(k)}
		c["agrumi_%d" % (k + 1)] = {"crea": agrumi.bind(k)}
	for att in ["ascia", "piccone", "pala", "falce", "canna", "sega", "martello"]:
		c["merce_" + att] = {"crea": merce.bind(att)}
	c["guardia"] = {"crea": guardia, "posa": posa_cammino,
		"fotogrammi": 8, "direzioni": 8, "dimensione": Vector2i(96, 96), "ancora": Vector2(42, 80)}
	c["guardia_lotta"] = {"crea": guardia, "posa": posa_lotta,
		"fotogrammi": 8, "direzioni": 8, "dimensione": Vector2i(96, 96), "ancora": Vector2(42, 80)}
	# condottieri (step 31): cella più alta per lo stendardo, stessa ancora rispetto al fondo della cella
	for popolo in ["greci", "brettii", "romani", "saraceni", "normanni", "siculi", "sicani"]:
		c["condottiero_" + popolo] = {"crea": condottiero.bind(popolo), "posa": posa_cammino,
			"fotogrammi": 8, "direzioni": 8, "dimensione": Vector2i(128, 112), "ancora": Vector2(42, 96)}
		c["condottiero_%s_lotta" % popolo] = {"crea": condottiero.bind(popolo), "posa": posa_lotta,
			"fotogrammi": 8, "direzioni": 8, "dimensione": Vector2i(128, 112), "ancora": Vector2(42, 96)}
	# i Brettii del giocatore, con il colore del giocatore (quelli nemici restano con la bandiera rossa)
	c["brettio_giocatore"] = {"crea": brettio.bind("giocatore"), "posa": posa_cammino,
		"fotogrammi": 8, "direzioni": 8, "dimensione": Vector2i(96, 96), "ancora": Vector2(42, 80)}
	c["brettio_giocatore_lotta"] = {"crea": brettio.bind("giocatore"), "posa": posa_lotta,
		"fotogrammi": 8, "direzioni": 8, "dimensione": Vector2i(96, 96), "ancora": Vector2(42, 80)}
	c["brettio"] = {"crea": brettio, "posa": posa_cammino,
		"fotogrammi": 8, "direzioni": 8, "dimensione": Vector2i(96, 96), "ancora": Vector2(42, 80)}
	c["brettio_lotta"] = {"crea": brettio, "posa": posa_lotta,
		"fotogrammi": 8, "direzioni": 8, "dimensione": Vector2i(96, 96), "ancora": Vector2(42, 80)}
	c["legionario"] = {"crea": legionario, "posa": posa_cammino,
		"fotogrammi": 8, "direzioni": 8, "dimensione": Vector2i(96, 96), "ancora": Vector2(42, 80)}
	c["legionario_lotta"] = {"crea": legionario, "posa": posa_lotta,
		"fotogrammi": 8, "direzioni": 8, "dimensione": Vector2i(96, 96), "ancora": Vector2(42, 80)}
	c["guerriero_siculo"] = {"crea": guerriero_siculo, "posa": posa_cammino,
		"fotogrammi": 8, "direzioni": 8, "dimensione": Vector2i(96, 96), "ancora": Vector2(42, 80)}
	c["guerriero_siculo_lotta"] = {"crea": guerriero_siculo, "posa": posa_lotta,
		"fotogrammi": 8, "direzioni": 8, "dimensione": Vector2i(96, 96), "ancora": Vector2(42, 80)}
	c["arciere_sicano"] = {"crea": arciere_sicano, "posa": posa_cammino,
		"fotogrammi": 8, "direzioni": 8, "dimensione": Vector2i(96, 96), "ancora": Vector2(42, 80)}
	c["arciere_sicano_lotta"] = {"crea": arciere_sicano, "posa": posa_lotta,
		"fotogrammi": 8, "direzioni": 8, "dimensione": Vector2i(96, 96), "ancora": Vector2(42, 80)}
	c["cavaliere_leggero"] = {"crea": cavaliere_leggero, "posa": posa_galoppo,
		"fotogrammi": 8, "direzioni": 8, "dimensione": Vector2i(96, 96), "ancora": Vector2(42, 80)}
	c["cavaliere_leggero_lotta"] = {"crea": cavaliere_leggero, "posa": posa_carica,
		"fotogrammi": 8, "direzioni": 8, "dimensione": Vector2i(96, 96), "ancora": Vector2(42, 80)}
	c["cavaliere_pesante"] = {"crea": cavaliere_pesante, "posa": posa_galoppo,
		"fotogrammi": 8, "direzioni": 8, "dimensione": Vector2i(96, 96), "ancora": Vector2(42, 80)}
	c["cavaliere_pesante_lotta"] = {"crea": cavaliere_pesante, "posa": posa_carica,
		"fotogrammi": 8, "direzioni": 8, "dimensione": Vector2i(96, 96), "ancora": Vector2(42, 80)}
	c["barca_remi"] = {"crea": barca_remi, "posa": posa_remata,
		"fotogrammi": 8, "direzioni": 8, "dimensione": Vector2i(112, 96), "ancora": Vector2(56, 64)}
	c["nave"] = {"crea": nave, "posa": posa_vela,
		"fotogrammi": 8, "direzioni": 8, "dimensione": Vector2i(128, 112), "ancora": Vector2(64, 74)}
	c["nave_guerra"] = {"crea": nave_guerra, "posa": posa_voga,
		"fotogrammi": 8, "direzioni": 8, "dimensione": Vector2i(144, 112), "ancora": Vector2(72, 72)}
	# mestieri: camminata con l'attrezzo e gesto di lavoro (8 direzioni × 8 fotogrammi)
	for att in ["ascia", "piccone", "pala", "falce", "canna"]:
		c["lavoratore_%s" % att] = {"crea": lavoratore.bind(att), "posa": posa_cammino,
			"fotogrammi": 8, "direzioni": 8, "dimensione": Vector2i(96, 96), "ancora": Vector2(42, 80)}
		c["lavoratore_%s_lavoro" % att] = {"crea": lavoratore.bind(att), "posa": posa_pesca if att == "canna" else posa_lavoro,
			"fotogrammi": 8, "direzioni": 8, "dimensione": Vector2i(96, 96), "ancora": Vector2(42, 80)}
	# persone: fogli di animazione 8 direzioni × 8 passi
	for carico in ["nessuno", "tronco", "asse", "anfora", "pietra", "covone", "sacco", "cesta", "pesce", "maiale", "carne", "lana", "formaggio", "olive", "uva", "ortaggi", "cipolle", "agrumi", "spada", "carbone", "lingotti", "attrezzi", "armi"]:
		c["portatore_" + carico] = {"crea": portatore.bind("" if carico == "nessuno" else carico), "posa": posa_cammino,
			"fotogrammi": 8, "direzioni": 8, "dimensione": Vector2i(80, 80), "ancora": Vector2(34, 68)}
	return c


# ------------------------------------------------------------------ materiali

static func _rumore(seme: int, frequenza: float, c1: Color, c2: Color, dim := 128) -> ImageTexture:
	var n := FastNoiseLite.new()
	n.seed = seme
	n.frequency = frequenza
	n.fractal_octaves = 4
	var img := n.get_seamless_image(dim, dim)
	img.convert(Image.FORMAT_RGBA8)
	for y in dim:
		for x in dim:
			var v := img.get_pixel(x, y).r
			img.set_pixel(x, y, c1.lerp(c2, v))
	img.generate_mipmaps()
	return ImageTexture.create_from_image(img)


## Texture di muro a pietre: blocchi irregolari con malta scura tra uno e l'altro.
static func _pietre_murate(seme: int, dim := 128, scuro := Color("9a8a74"), chiaro := Color("c8b89a"), malta := Color("5a5046")) -> ImageTexture:
	var rng := RandomNumberGenerator.new()
	rng.seed = seme
	var img := Image.create(dim, dim, false, Image.FORMAT_RGBA8)
	img.fill(malta)
	var n := FastNoiseLite.new()
	n.seed = seme
	n.frequency = 0.15
	var y := 0
	while y < dim:
		var h := rng.randi_range(9, 16)
		var x := -rng.randi_range(0, 12)
		while x < dim:
			var w := rng.randi_range(12, 26)
			var base := scuro.lerp(chiaro, rng.randf())
			for yy in range(y + 1, mini(y + h - 1, dim)):
				for xx in range(maxi(x + 1, 0), mini(x + w - 1, dim)):
					var v := n.get_noise_2d(xx, yy) * 0.12
					var bordo := 1.0 - 0.18 * float(yy == y + 1 or xx == x + 1)
					img.set_pixel(xx, yy, Color(base.r + v, base.g + v, base.b + v) * bordo)
			x += w
		y += h
	img.generate_mipmaps()
	return ImageTexture.create_from_image(img)


## Texture di paglia: fili verticali (lungo V) di tinte diverse, con fasce più chiare e più scure. Si ripete senza giunte.
static func _paglia_fili(seme: int, scuro: Color, chiaro: Color, dim := 128) -> ImageTexture:
	var rng := RandomNumberGenerator.new()
	rng.seed = seme
	var img := Image.create(dim, dim, false, Image.FORMAT_RGBA8)
	var tono := PackedFloat32Array()
	var fase := PackedFloat32Array()
	for x in dim:
		tono.append(rng.randf())
		fase.append(rng.randf() * TAU)
	for y in dim:
		for x in dim:
			var t := (tono[x] * 2.0 + tono[(x + 1) % dim] + tono[(x + dim - 1) % dim]) * 0.25
			t = t * 0.75 + 0.25 * (0.5 + 0.5 * sin(fase[x] + y * TAU * 2.0 / dim))
			img.set_pixel(x, y, scuro.lerp(chiaro, t))
	img.generate_mipmaps()
	return ImageTexture.create_from_image(img)


static func materiale(nome: String) -> Material:
	if _cache_mat.has(nome):
		return _cache_mat[nome]
	var m := StandardMaterial3D.new()
	m.roughness = 0.9
	m.uv1_triplanar = true
	match nome:
		"intonaco":
			m.albedo_texture = _rumore(1, 0.09, Color("d6c9ae"), Color("f7f1e4"))
			m.uv1_scale = Vector3(2, 2, 2)
		"intonaco_sporco":
			m.albedo_texture = _rumore(2, 0.03, Color("b9ab8f"), Color("ddd2bb"))
			m.uv1_scale = Vector3(2, 2, 2)
		"pietra":
			m.albedo_texture = _rumore(3, 0.09, Color("8f8270"), Color("c4b69c"))
			m.uv1_scale = Vector3(3, 3, 3)
		"tegola":
			m.albedo_texture = _rumore(4, 0.11, Color("5e2618"), Color("9a462a"))
			m.uv1_scale = Vector3(4, 4, 4)
		"tegola_scura":
			m.albedo_texture = _rumore(5, 0.08, Color("5c2616"), Color("853b22"))
		"legno":
			m.albedo_texture = _rumore(6, 0.15, Color("5a3a22"), Color("8a5a32"))
			m.uv1_scale = Vector3(1, 6, 1)
		"legno_scuro":
			m.albedo_texture = _rumore(7, 0.12, Color("2e1d12"), Color("4a2e1c"))
		"corteccia":
			m.albedo_texture = _rumore(8, 0.2, Color("3d2818"), Color("6b4a30"))
			m.uv1_scale = Vector3(2, 8, 2)
		"aghi":
			m.albedo_texture = _rumore(9, 0.25, Color("15301a"), Color("35592f"))
			m.uv1_scale = Vector3(4, 4, 4)
		"foglie_ulivo":
			m.albedo_texture = _rumore(10, 0.3, Color("3f5a33"), Color("8c9d74"))
			m.uv1_scale = Vector3(5, 5, 5)
		"terracotta":
			m.albedo_texture = _rumore(11, 0.1, Color("a8582f"), Color("c97a4a"))
			m.roughness = 0.75
		"legno_chiaro":
			m.albedo_texture = _rumore(12, 0.2, Color("b88a55"), Color("e0bd88"))
			m.uv1_scale = Vector3(1, 5, 1)
		"lino":
			m.albedo_texture = _rumore(13, 0.3, Color("c9b48a"), Color("e8d9b4"))
		"marmo":
			m.albedo_texture = _rumore(14, 0.05, Color("e2dccf"), Color("fbfaf6"))
		"ferro":
			m.albedo_color = Color("7d8287")
			m.metallic = 0.6
			m.roughness = 0.45
		"pelle":
			m.albedo_color = Color("d39a72")
		"capelli":
			m.albedo_color = Color("3a2416")
		"tunica":
			m.albedo_texture = _rumore(15, 0.4, Color("c8b48e"), Color("e4d6b6"))
		"giocatore":
			m.albedo_color = Color("2f78a8")
		"sandali":
			m.albedo_color = Color("5a3a22")
		"roccia_massi":
			m.albedo_texture = _rumore(16, 0.12, Color("4a443c"), Color("857a68"))
		"macchia":
			m.albedo_texture = _rumore(17, 0.35, Color("2f4a24"), Color("5f7a3c"))
		"fiore":
			m.albedo_color = Color("e8c94a")
		"blocco":
			m.albedo_texture = _rumore(18, 0.15, Color("b9ab90"), Color("ddd0b6"))
		"acqua_pozzo":
			m.albedo_color = Color("1d4a66")
			m.roughness = 0.2
		"corda":
			m.albedo_color = Color("b89a64")
		"stoffa":
			m.albedo_color = Color("2f78a8")
			m.cull_mode = BaseMaterial3D.CULL_DISABLED
		"pietra_vista":
			m.albedo_texture = _pietre_murate(19)
			m.uv1_scale = Vector3(1.6, 1.6, 1.6)
		"tegola_b":
			m.albedo_texture = _rumore(20, 0.12, Color("6a2c1b"), Color("9e4f2e"))
			m.uv1_scale = Vector3(4, 4, 4)
		"tegola_c":
			m.albedo_texture = _rumore(21, 0.12, Color("7a3a24"), Color("aa6440"))
			m.uv1_scale = Vector3(4, 4, 4)
		"legno_vecchio":
			m.albedo_texture = _rumore(22, 0.25, Color("4e3f31"), Color("8a7559"))
			m.uv1_scale = Vector3(1, 6, 1)
		"terra":
			m.albedo_texture = _rumore(23, 0.2, Color("5d4127"), Color("8a6a44"))
		"orto":
			m.albedo_texture = _rumore(24, 0.5, Color("2e5a1c"), Color("74a63a"))
		"geranio":
			m.albedo_texture = _rumore(25, 0.6, Color("a8161c"), Color("e8473a"))
		"fuliggine":
			m.albedo_color = Color("2a2420")
		"paglia":
			m.albedo_texture = _rumore(26, 0.3, Color("a8873e"), Color("e0c271"))
			m.uv1_scale = Vector3(2, 6, 2)
		"foglie":
			m.albedo_texture = _rumore(27, 0.45, Color("1e4212"), Color("5a8c28"))
			m.uv1_scale = Vector3(4, 4, 4)
		"foglie_scure":
			m.albedo_texture = _rumore(28, 0.45, Color("10290b"), Color("355e1c"))
			m.uv1_scale = Vector3(4, 4, 4)
		"foglie_chiare":
			m.albedo_texture = _rumore(29, 0.45, Color("41701c"), Color("86ad3c"))
			m.uv1_scale = Vector3(4, 4, 4)
		"fusto_chiaro":
			m.albedo_texture = _rumore(30, 0.25, Color("5a4632"), Color("8e7656"))
			m.uv1_scale = Vector3(2, 8, 2)
		"bandiera_rossa":
			m.albedo_color = Color("b0322a")
		"persiana":
			m.albedo_color = Color("3f6f96")
		"buio":
			m.albedo_color = Color("1e140d")
		"grano":
			m.albedo_texture = _rumore(31, 0.5, Color("c08a22"), Color("f2cf5e"))
			m.uv1_scale = Vector3(3, 6, 3)
		"grano_verde":
			m.albedo_texture = _rumore(32, 0.5, Color("4f7d1f"), Color("9cc04a"))
			m.uv1_scale = Vector3(3, 6, 3)
		"pane":
			m.albedo_texture = _rumore(33, 0.4, Color("8a4a1c"), Color("d08a44"))
		"pesce":
			m.albedo_texture = _rumore(34, 0.5, Color("6f8c9c"), Color("d6e2e8"))
			m.metallic = 0.3
			m.roughness = 0.45
		"rete":
			m.albedo_color = Color("8a7550")
			m.cull_mode = BaseMaterial3D.CULL_DISABLED
		"asino":
			m.albedo_texture = _rumore(35, 0.3, Color("5e5650"), Color("8f857a"))
		"maiale":
			m.albedo_texture = _rumore(36, 0.3, Color("c98a80"), Color("f0b8a8"))
		"lana":
			m.albedo_texture = _rumore(37, 0.8, Color("cfc6ae"), Color("f6f1e2"))
		"pelle_scura":
			m.albedo_color = Color("3a2c24")
		"capra":
			m.albedo_texture = _rumore(38, 0.4, Color("2e2420"), Color("7a5a40"))
		"carne":
			m.albedo_texture = _rumore(39, 0.5, Color("7a2a20"), Color("b85a40"))
		"formaggio":
			m.albedo_texture = _rumore(40, 0.4, Color("d8b860"), Color("f6e6a6"))
		"miele":
			m.albedo_color = Color("e0a020")
		"latte":
			m.albedo_color = Color("f4f2ea")
		"uva":
			m.albedo_texture = _rumore(41, 0.9, Color("2e1438"), Color("6a3a72"))
		"cipolla":
			m.albedo_texture = _rumore(42, 0.6, Color("7a1838"), Color("c0486a"))
		"arancia":
			m.albedo_color = Color("f08a1a")
		"bergamotto":
			m.albedo_color = Color("d8d040")
		"oliva":
			m.albedo_texture = _rumore(43, 0.9, Color("1e2410"), Color("4a5a20"))
		"vino":
			m.albedo_color = Color("4a0c1a")
			m.roughness = 0.2
		"minerale":
			m.albedo_texture = _rumore(45, 0.7, Color("4a2a20"), Color("9a5a3a"))
		"carbone":
			m.albedo_texture = _rumore(46, 0.8, Color("141210"), Color("3a3634"))
			m.roughness = 0.6
		"lingotto":
			m.albedo_texture = _rumore(47, 0.4, Color("5a5e66"), Color("9aa0a8"))
			m.metallic = 0.5
			m.roughness = 0.4
		"brace":
			m.albedo_color = Color("ff6a1a")
			m.emission_enabled = true
			m.emission = Color("ff5a10")
			m.emission_energy_multiplier = 1.5
		"argilla":
			m.albedo_texture = _rumore(48, 0.4, Color("8a3a1c"), Color("c86a3a"))
		"argilla_cruda":
			m.albedo_texture = _rumore(49, 0.3, Color("8a6040"), Color("b89068"))
		"sale":
			m.albedo_texture = _rumore(50, 0.9, Color("d8dce0"), Color("ffffff"))
		"moneta":
			m.albedo_color = Color("d8c070")
			m.metallic = 0.7
			m.roughness = 0.35
		"argento_grezzo":
			m.albedo_texture = _rumore(51, 0.7, Color("4a4c54"), Color("c8ccd8"))
			m.metallic = 0.4
		"pelliccia":
			m.albedo_texture = _rumore(53, 0.9, Color("3e2a1a"), Color("7a5a3a"))
		"bronzo":
			m.albedo_texture = _rumore(52, 0.5, Color("8a5a20"), Color("d8a048"))
			m.metallic = 0.6
			m.roughness = 0.4
		"stoffa_rossa":
			m.albedo_color = Color("a8302a")
			m.cull_mode = BaseMaterial3D.CULL_DISABLED
		"fumo":
			m.albedo_color = Color(0.75, 0.73, 0.7, 0.55)
			m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		"spada":
			m.albedo_texture = _rumore(44, 0.4, Color("3a4e66"), Color("a8bcc8"))
			m.metallic = 0.3
			m.roughness = 0.4
		"pietra_scura":
			m.albedo_texture = _pietre_murate(60, 128, Color("4e4840"), Color("7a7064"), Color("2c2722"))
			m.uv1_scale = Vector3(1.6, 1.6, 1.6)
		"blocchi_greci":
			m.albedo_texture = _pietre_murate(61, 128, Color("c4b38e"), Color("e8dcc0"), Color("8a7a5e"))
			m.uv1_scale = Vector3(0.9, 0.9, 0.9)
		"roccia_chiara":
			m.albedo_texture = _rumore(62, 0.14, Color("9c8e78"), Color("e2d8c4"))
			m.uv1_scale = Vector3(2, 2, 2)
		"mare":
			m.albedo_color = Color("2f7c9a")
			m.roughness = 0.15
			m.metallic = 0.1
		"sabbia":
			m.albedo_texture = _rumore(63, 0.35, Color("c9ae7c"), Color("ead8a8"))
			m.uv1_scale = Vector3(3, 3, 3)
		"intonaco_bianco":
			m.albedo_texture = _rumore(64, 0.08, Color("e6e0d2"), Color("fffdf6"))
			m.uv1_scale = Vector3(2, 2, 2)
		"intonaco_giallo":
			m.albedo_texture = _rumore(65, 0.08, Color("d8b46e"), Color("f0d79c"))
			m.uv1_scale = Vector3(2, 2, 2)
		"piombo":
			m.albedo_texture = _rumore(66, 0.2, Color("5e6a72"), Color("8f9ca4"))
			m.roughness = 0.6
		"maiolica":
			m.albedo_texture = _rumore(67, 0.7, Color("1d6a64"), Color("e2c050"))
			m.uv1_scale = Vector3(4, 4, 4)
			m.roughness = 0.4
		"tufo":
			m.albedo_texture = _rumore(68, 0.16, Color("a8834f"), Color("dcc08a"))
			m.uv1_scale = Vector3(2, 2, 2)
		# materiali dei Brettii
		"pietra_grezza":
			m.albedo_texture = _pietre_murate(70, 128, Color("5e574c"), Color("a09482"), Color("2e2a25"))
			m.uv1_scale = Vector3(2.4, 2.4, 2.4)
		"paglia_scura":
			m.albedo_texture = _paglia_fili(71, Color("5e4824"), Color("a08349"))
			m.uv1_scale = Vector3(1.2, 1.2, 1.2)
		"paglia_tetto":
			m.albedo_texture = _paglia_fili(72, Color("74592a"), Color("c9a65a"))
			m.uv1_scale = Vector3(1.0, 1.0, 1.0)
		"stoffa_verde":
			m.albedo_color = Color("2f6b33")
			m.cull_mode = BaseMaterial3D.CULL_DISABLED
		"osso":
			m.albedo_color = Color("ebe0c6")
		# materiali dei Romani
		"mattoni":
			m.albedo_texture = _mattoni_tex(81)
			m.uv1_scale = Vector3(2.2, 2.2, 2.2)
		"intonaco_ocra":
			m.albedo_texture = _rumore(84, 0.08, Color("c4863a"), Color("e8b866"))
			m.uv1_scale = Vector3(2, 2, 2)
		"laterizio":
			m.albedo_texture = _rumore(82, 0.12, Color("9c4426"), Color("c86c3e"))
		"laterizio_scuro":
			m.albedo_texture = _rumore(83, 0.1, Color("6e3018"), Color("94482a"))
		"rosso_pompeiano":
			m.albedo_texture = _rumore(85, 0.2, Color("8a2018"), Color("ac362a"))
		"stoffa_pompeiana":
			m.albedo_color = Color("a02a22")
			m.cull_mode = BaseMaterial3D.CULL_DISABLED
		"basoli":
			m.albedo_texture = _pietre_murate(86, 128, Color("4c4e50"), Color("858680"), Color("2a2826"))
			m.uv1_scale = Vector3(1.6, 1.6, 1.6)
		# materiali dei Saraceni
		"calce":
			m.albedo_texture = _rumore(90, 0.08, Color("e6dccb"), Color("fffaf0"))
			m.uv1_scale = Vector3(2, 2, 2)
		"terra_cruda":
			m.albedo_texture = _rumore(91, 0.12, Color("a8754a"), Color("d6a874"))
			m.uv1_scale = Vector3(2, 2, 2)
		"mattoni_crudi":
			m.albedo_texture = _pietre_murate(92, 128, Color("b07c50"), Color("d4a672"), Color("8e6440"))
			m.uv1_scale = Vector3(1.4, 1.4, 1.4)
		"maiolica_verde":
			m.albedo_texture = _rumore(93, 0.45, Color("0a6a46"), Color("34b07a"))
			m.uv1_scale = Vector3(3, 3, 3)
			m.roughness = 0.35
		"zellige":
			m.albedo_texture = _zellige_tex()
			m.uv1_scale = Vector3(3, 3, 3)
			m.roughness = 0.4
		"stoffa_smeraldo":
			m.albedo_color = Color("0f8a58")
			m.cull_mode = BaseMaterial3D.CULL_DISABLED
		"smeraldo":
			m.albedo_color = Color("12925e")
		"tenda_verde":
			m.albedo_texture = _strisce_tex(Color("f2ecdc"), Color("118656"))
			m.uv1_scale = Vector3(3, 3, 3)
			m.cull_mode = BaseMaterial3D.CULL_DISABLED
		"tenda_rossa":
			m.albedo_texture = _strisce_tex(Color("f2ecdc"), Color("b4302a"))
			m.uv1_scale = Vector3(3, 3, 3)
			m.cull_mode = BaseMaterial3D.CULL_DISABLED
		"canne":
			m.albedo_texture = _paglia_fili(94, Color("5e4e2c"), Color("a89262"))
			m.uv1_scale = Vector3(1.5, 1.5, 1.5)
		"seta_verde":
			m.albedo_color = Color("16a06a")
			m.roughness = 0.35
		"seta_cremisi":
			m.albedo_color = Color("b81e3c")
			m.roughness = 0.35
		"seta_oro":
			m.albedo_color = Color("e6b232")
			m.roughness = 0.35
		"seta_azzurra":
			m.albedo_color = Color("3a7cd0")
			m.roughness = 0.35
		"seta_zafferano":
			m.albedo_color = Color("ec7e1e")
			m.roughness = 0.35
		"bozzolo":
			m.albedo_texture = _rumore(95, 0.6, Color("e8dfc4"), Color("fffbef"))
		"cavallo":
			m.albedo_texture = _rumore(96, 0.35, Color("9c968c"), Color("ece8e0"))
		"cavallo_muso":
			m.albedo_color = Color("6a6460")
		"crine":
			m.albedo_color = Color("3c3836")
		"lino_bianco":
			m.albedo_texture = _rumore(97, 0.4, Color("ddd6c4"), Color("fbf8ef"))
		"legno_verde":
			m.albedo_texture = _rumore(98, 0.2, Color("1c5440"), Color("2e7a5a"))
			m.uv1_scale = Vector3(1, 6, 1)
		"acqua_chiara":
			m.albedo_color = Color("2f8cae")
			m.roughness = 0.12
			m.metallic = 0.15
		"schiuma":
			m.albedo_color = Color("eef6f8")
		"vapore":
			m.albedo_color = Color(0.95, 0.95, 0.97, 0.45)
			m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		"battuto":
			m.albedo_texture = _rumore(100, 0.15, Color("c49a70"), Color("e4c69c"))
			m.uv1_scale = Vector3(2, 2, 2)
		"cammello":
			m.albedo_texture = _rumore(99, 0.3, Color("a07848"), Color("d0a874"))
		"pece":
			m.albedo_color = Color("16110d")
			m.roughness = 0.18
			m.metallic = 0.15
		# materiali dei Normanni
		"pietra_normanna":
			m.albedo_texture = _conci_tex(110)
			m.uv1_scale = Vector3(1.5, 1.5, 1.5)
		"pietra_n_scura":
			m.albedo_texture = _conci_tex(111, 128, Color("444648"), Color("686a6a"), Color("2a2a2a"))
			m.uv1_scale = Vector3(1.5, 1.5, 1.5)
		"pietra_n_chiara":
			m.albedo_texture = _rumore(112, 0.12, Color("787874"), Color("9c9a94"))
		"ardesia":
			m.albedo_texture = _ardesia_tex(113)
			m.uv1_scale = Vector3(2.5, 2.5, 2.5)
		"ardesia_b":
			m.albedo_texture = _rumore(114, 0.3, Color("262a33"), Color("3e4552"))
			m.uv1_scale = Vector3(3, 3, 3)
		"graticcio_n":
			m.albedo_texture = _rumore(115, 0.1, Color("c2b48e"), Color("e0d4b4"))
			m.uv1_scale = Vector3(2, 2, 2)
		"stoffa_oro":
			m.albedo_color = Color("e2a619")
			m.cull_mode = BaseMaterial3D.CULL_DISABLED
		"oro_n":
			m.albedo_color = Color("e8b022")
		"maglia":
			m.albedo_texture = _rumore(116, 0.9, Color("4e5258"), Color("a4aab0"))
			m.metallic = 0.55
			m.roughness = 0.45
			m.uv1_scale = Vector3(6, 6, 6)
		"cavallo_baio":
			m.albedo_texture = _rumore(117, 0.35, Color("4a2814"), Color("7e4a26"))
		"prato":
			m.albedo_texture = _rumore(118, 0.3, Color("2c4018"), Color("4a6228"))
			m.uv1_scale = Vector3(3, 3, 3)
		# materiali dei Siculi
		"argilla_sic":
			m.albedo_texture = _rumore(130, 0.14, Color("a86a3e"), Color("d6a26c"))
			m.uv1_scale = Vector3(2, 2, 2)
		"pietra_secca":
			m.albedo_texture = _pietre_murate(131, 128, Color("8e8270"), Color("d2c6aa"), Color("2c261f"))
			m.uv1_scale = Vector3(2.2, 2.2, 2.2)
		"canne_sic":
			m.albedo_texture = _paglia_fili(132, Color("4c4a2a"), Color("958c56"))
			m.uv1_scale = Vector3(1.2, 1.2, 1.2)
		"frasche":
			m.albedo_texture = _rumore(133, 0.45, Color("2c2a14"), Color("5c5226"))
			m.uv1_scale = Vector3(2, 2, 2)
		"ocra_rossa":
			m.albedo_color = Color("b4441c")
			m.cull_mode = BaseMaterial3D.CULL_DISABLED
		"ceramica":
			m.albedo_texture = _rumore(134, 0.2, Color("d4ae7a"), Color("eed4a4"))
			m.roughness = 0.7
		"vernice_rossa":
			m.albedo_color = Color("a8321a")
		"vernice_nera":
			m.albedo_color = Color("221a14")
		"cuoio":
			m.albedo_texture = _rumore(135, 0.3, Color("5e3a1e"), Color("8c5a2e"))
		"tunica_ocra":
			m.albedo_texture = _rumore(136, 0.4, Color("bc7a34"), Color("dc9e52"))
		# materiali dei Sicani
		"pietra_sicana":
			m.albedo_texture = _pietre_murate(140, 128, Color("5e605e"), Color("a6a49c"), Color("1a1a1a"))
			m.uv1_scale = Vector3(2.4, 2.4, 2.4)
		"sasso_sic":
			m.albedo_texture = _rumore(141, 0.18, Color("5c5d5a"), Color("9c9a92"))
		"lastra_sic":
			m.albedo_texture = _rumore(142, 0.22, Color("55524c"), Color("8c877c"))
			m.uv1_scale = Vector3(3, 3, 3)
		"erba_tetto":
			m.albedo_texture = _rumore(143, 0.4, Color("3a561c"), Color("7c9c38"))
			m.uv1_scale = Vector3(3, 3, 3)
		"lapislazzuli":
			m.albedo_texture = _rumore(144, 0.5, Color("173c94"), Color("2f5fc4"))
			m.cull_mode = BaseMaterial3D.CULL_DISABLED
		"tunica_lapis":
			m.albedo_texture = _rumore(145, 0.4, Color("1c3a80"), Color("3560b0"))
		"mantello_blu":
			m.albedo_texture = _rumore(146, 0.35, Color("18234a"), Color("2a3c72"))
		"ossidiana":
			m.albedo_color = Color("0e0c12")
			m.metallic = 0.35
			m.roughness = 0.1
		"riflesso_oss":
			m.albedo_color = Color("6a7488")
			m.roughness = 0.2
	var finale: Material = m if nome in MATERIALI_SEMPLICI else _a_vissuto(m, nome)
	_cache_mat[nome] = finale
	return finale


static func _a_vissuto(m: StandardMaterial3D, nome: String) -> ShaderMaterial:
	var sm := ShaderMaterial.new()
	sm.shader = SHADER_VISSUTO
	var tex: Texture2D = m.albedo_texture
	if tex == null:
		var img := Image.create(4, 4, false, Image.FORMAT_RGBA8)
		img.fill(m.albedo_color)
		tex = ImageTexture.create_from_image(img)
	sm.set_shader_parameter("tex", tex)
	sm.set_shader_parameter("rumore", _rumore_studio())
	sm.set_shader_parameter("scala", m.uv1_scale.x * 1.0)
	sm.set_shader_parameter("ruvidezza", m.roughness)
	var reg: Array = REGOLAZIONI.get(nome, [0.45, 0.35, 1.2])
	sm.set_shader_parameter("sporco", reg[0])
	sm.set_shader_parameter("macchie", reg[1])
	sm.set_shader_parameter("saturazione", reg[2])
	return sm


static func _rumore_studio() -> ImageTexture:
	if _rumore_rgb:
		return _rumore_rgb
	var dim := 128
	var img := Image.create(dim, dim, false, Image.FORMAT_RGBA8)
	var canali := []
	for k in 3:
		var n := FastNoiseLite.new()
		n.seed = 300 + k
		n.frequency = 0.06 + k * 0.05
		n.fractal_octaves = 3
		canali.append(n.get_seamless_image(dim, dim))
	for y in dim:
		for x in dim:
			img.set_pixel(x, y, Color(canali[0].get_pixel(x, y).r, canali[1].get_pixel(x, y).r, canali[2].get_pixel(x, y).r))
	img.generate_mipmaps()
	_rumore_rgb = ImageTexture.create_from_image(img)
	return _rumore_rgb


# ------------------------------------------------------------------ primitive

static func scatola(dim: Vector3, pos: Vector3, mat: String, rot := Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = dim
	mi.mesh = bm
	mi.position = pos
	mi.rotation_degrees = rot
	mi.material_override = materiale(mat)
	return mi


static func cilindro(r_basso: float, r_alto: float, h: float, pos: Vector3, mat: String, rot := Vector3.ZERO, segmenti := 12) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.bottom_radius = r_basso
	cm.top_radius = r_alto
	cm.height = h
	cm.radial_segments = segmenti
	cm.rings = 1
	mi.mesh = cm
	mi.position = pos
	mi.rotation_degrees = rot
	mi.material_override = materiale(mat)
	return mi


static func sfera(r: float, pos: Vector3, mat: String, scala := Vector3.ONE) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = r
	sm.height = r * 2
	sm.radial_segments = 16
	sm.rings = 8
	mi.mesh = sm
	mi.position = pos
	mi.scale = scala
	mi.material_override = materiale(mat)
	return mi


## Tetto a due falde coperto di coppi veri (mezzi cilindri), colmo lungo l'asse X.
static func tetto_coppi(radice: Node3D, larg: float, prof: float, base_y: float, pendenza_gradi: float, mat := "tegola") -> void:
	var meta := prof * 0.5 + 0.06
	var ang := deg_to_rad(pendenza_gradi)
	var lung_falda := meta / cos(ang)
	var alt := meta * tan(ang)
	for lato in [-1, 1]:
		var falda := Node3D.new()
		falda.position = Vector3(0, base_y + alt * 0.5, lato * meta * 0.5)
		falda.rotation.x = lato * ang
		radice.add_child(falda)
		falda.add_child(scatola(Vector3(larg + 0.12, 0.03, lung_falda), Vector3.ZERO, "tegola_scura"))
		var n := int((larg + 0.1) / 0.075)
		for k in n:
			var x := -larg * 0.5 - 0.03 + (k + 0.5) * (larg + 0.06) / n
			var coppo := cilindro(0.032, 0.03, lung_falda, Vector3(x, 0.022, 0), mat, Vector3(90, 0, 0), 8)
			coppo.scale = Vector3(1, 1, 0.55)
			falda.add_child(coppo)
	var colmo := cilindro(0.045, 0.045, larg + 0.16, Vector3(0, base_y + alt + 0.025, 0), mat, Vector3(0, 0, 90), 10)
	radice.add_child(colmo)


# ------------------------------------------------------------------ modelli




static func sottotetto(radice: Node3D, lx: float, lz: float, base_y: float, pendenza_gradi: float, mat := "intonaco") -> void:
	var alt := (lz * 0.5) * tan(deg_to_rad(pendenza_gradi))
	var mi := MeshInstance3D.new()
	var pm := PrismMesh.new()
	pm.size = Vector3(lz, alt, lx)
	mi.mesh = pm
	mi.rotation_degrees = Vector3(0, 90, 0)
	mi.position = Vector3(0, base_y + alt * 0.5, 0)
	mi.material_override = materiale(mat)
	radice.add_child(mi)


## Tetto a scandole di legno (file di tavolette sovrapposte).
static func tetto_scandole(radice: Node3D, larg: float, prof: float, base_y: float, pendenza_gradi: float) -> void:
	var meta := prof * 0.5 + 0.06
	var ang := deg_to_rad(pendenza_gradi)
	var lung := meta / cos(ang)
	var alt := meta * tan(ang)
	for lato in [-1, 1]:
		var falda := Node3D.new()
		falda.position = Vector3(0, base_y + alt * 0.5, lato * meta * 0.5)
		falda.rotation.x = lato * ang
		radice.add_child(falda)
		falda.add_child(scatola(Vector3(larg + 0.12, 0.025, lung), Vector3.ZERO, "legno_scuro"))
		var file := int(lung / 0.07)
		for k in file:
			var z := -lung * 0.5 + (k + 0.5) * lung / file
			var fila := scatola(Vector3(larg + 0.12, 0.018, lung / file * 1.3), Vector3(0, 0.02, z * lato * -1.0), "legno" if k % 2 == 0 else "legno_scuro")
			fila.rotation_degrees.x = 6 * lato
			falda.add_child(fila)
	radice.add_child(cilindro(0.035, 0.035, larg + 0.16, Vector3(0, base_y + alt + 0.02, 0), "legno_scuro", Vector3(0, 0, 90), 8))


static func anfora(pos: Vector3, scala := 1.0) -> Node3D:
	var n := Node3D.new()
	n.position = pos
	n.scale = Vector3.ONE * scala
	n.add_child(sfera(0.045, Vector3(0, 0.05, 0), "terracotta", Vector3(1, 1.35, 1)))
	n.add_child(cilindro(0.018, 0.022, 0.04, Vector3(0, 0.12, 0), "terracotta", Vector3.ZERO, 8))
	n.add_child(cilindro(0.026, 0.026, 0.01, Vector3(0, 0.14, 0), "terracotta", Vector3.ZERO, 8))
	return n


static func sacco(pos: Vector3, rot := 0.0) -> MeshInstance3D:
	var s := sfera(0.06, pos + Vector3(0, 0.045, 0), "lino", Vector3(1, 0.8, 0.8))
	s.rotation.y = rot
	return s


static func cassa(pos: Vector3, rot := 0.0, lato := 0.11) -> MeshInstance3D:
	return scatola(Vector3(lato, lato * 0.8, lato), pos + Vector3(0, lato * 0.4, 0), "legno", Vector3(0, rot, 0))


static func catasta_tronchi(radice: Node3D, pos: Vector3, file := 3, lung := 0.36) -> void:
	for f in file:
		for k in file - f:
			var x := (k - (file - f - 1) * 0.5) * 0.075
			radice.add_child(cilindro(0.035, 0.035, lung, pos + Vector3(x, 0.035 + f * 0.062, 0), "corteccia", Vector3(90, 0, 0), 8))
			radice.add_child(cilindro(0.028, 0.028, lung + 0.004, pos + Vector3(x, 0.035 + f * 0.062, 0), "legno_chiaro", Vector3(90, 0, 0), 8))


static func pila_assi(radice: Node3D, pos: Vector3, strati := 5, rot := 0.0) -> void:
	for k in strati:
		var a := scatola(Vector3(0.34, 0.018, 0.14), pos + Vector3(0, 0.012 + k * 0.021, 0), "legno_chiaro", Vector3(0, rot + (k % 2) * 3, 0))
		radice.add_child(a)


# ------------------------------------------------------------------ edifici greci





# ------------------------------------------------------------------ persone

## Portatore: proporzioni esagerate (testa grande, carico ben visibile) per restare leggibile a 45 pixel.
static func portatore(carico: String, squadra := "giocatore", veste := "tunica") -> Node3D:
	var r := Node3D.new()
	var corpo := Node3D.new()
	corpo.name = "corpo"
	r.add_child(corpo)
	var anca := 0.2
	for lato in [-1, 1]:
		var gamba := Node3D.new()
		gamba.name = "gamba_s" if lato < 0 else "gamba_d"
		gamba.position = Vector3(lato * 0.035, anca, 0)
		corpo.add_child(gamba)
		gamba.add_child(cilindro(0.022, 0.018, 0.18, Vector3(0, -0.09, 0), "pelle", Vector3.ZERO, 6))
		gamba.add_child(scatola(Vector3(0.04, 0.02, 0.07), Vector3(0, -0.185, 0.015), "sandali"))
	corpo.add_child(cilindro(0.085, 0.06, 0.2, Vector3(0, anca + 0.07, 0), veste, Vector3.ZERO, 10))
	corpo.add_child(cilindro(0.075, 0.075, 0.022, Vector3(0, anca + 0.1, 0), squadra, Vector3.ZERO, 10))
	corpo.add_child(cilindro(0.087, 0.087, 0.018, Vector3(0, anca - 0.022, 0), squadra, Vector3.ZERO, 10))
	corpo.add_child(sfera(0.075, Vector3(0, anca + 0.25, 0), "pelle"))
	var capelli := sfera(0.078, Vector3(0, anca + 0.27, -0.01), "capelli", Vector3(1, 0.85, 1))
	corpo.add_child(capelli)
	corpo.add_child(sfera(0.012, Vector3(0, anca + 0.24, 0.075), "pelle"))  # naso
	for lato in [-1, 1]:
		var braccio := Node3D.new()
		braccio.name = "braccio_s" if lato < 0 else "braccio_d"
		braccio.position = Vector3(lato * 0.07, anca + 0.155, 0)
		corpo.add_child(braccio)
		braccio.add_child(cilindro(0.017, 0.015, 0.14, Vector3(0, -0.07, 0), "pelle", Vector3.ZERO, 6))
	var spalla := Vector3(0, anca + 0.2, 0)
	match carico:
		"tronco":
			corpo.add_child(cilindro(0.038, 0.038, 0.3, spalla + Vector3(0.085, 0.01, 0), "corteccia", Vector3(90, 0, 0), 8))
			corpo.add_child(cilindro(0.03, 0.03, 0.302, spalla + Vector3(0.085, 0.01, 0), "legno_chiaro", Vector3(90, 0, 0), 8))
		"asse":
			corpo.add_child(scatola(Vector3(0.05, 0.016, 0.36), spalla + Vector3(0.08, 0.02, 0), "legno_chiaro"))
			corpo.add_child(scatola(Vector3(0.05, 0.016, 0.34), spalla + Vector3(0.08, 0.038, 0.01), "legno_chiaro"))
		"anfora":
			corpo.add_child(anfora(Vector3(0, anca + 0.31, 0), 1.25))
		"pietra":
			corpo.add_child(scatola(Vector3(0.1, 0.075, 0.09), Vector3(0, anca + 0.36, 0), "blocco", Vector3(0, 15, 0)))
		"covone":
			var cv := covone(1.0)
			cv.position = spalla + Vector3(0.08, 0.0, 0)
			cv.rotation_degrees = Vector3(70, 0, 0)
			corpo.add_child(cv)
		"sacco":
			corpo.add_child(sfera(0.075, spalla + Vector3(0.06, 0.04, -0.01), "lino", Vector3(0.8, 0.9, 1.25)))
		"cesta", "pesce", "formaggio", "olive", "uva", "ortaggi", "cipolle", "agrumi":
			corpo.add_child(cesta(Vector3(0, anca + 0.31, 0), "pane" if carico == "cesta" else carico, 1.15))
		"maiale":
			var mm := maiale(Vector3(0.0, anca + 0.02, 0.09), 90)
			mm.scale = Vector3.ONE * 0.7
			corpo.add_child(mm)
		"carne":
			corpo.add_child(sfera(0.05, spalla + Vector3(0.07, 0.03, 0), "carne", Vector3(0.9, 1.4, 0.8)))
		"lana":
			corpo.add_child(sfera(0.08, spalla + Vector3(0.05, 0.05, -0.01), "lana", Vector3(1.0, 0.8, 1.2)))
		"carbone":
			corpo.add_child(cesta(Vector3(0, anca + 0.31, 0), "carbone", 1.15))
		"lingotti":
			for k in 3:
				corpo.add_child(scatola(Vector3(0.09, 0.025, 0.035), Vector3(-0.01 * k, anca + 0.33 + k * 0.026, 0), "lingotto", Vector3(0, 10 * k, 0)))
		"armi":
			var fa := fascio_armi()
			fa.position = spalla + Vector3(0.06, 0.0, -0.05)
			fa.rotation_degrees = Vector3(0, 90, 20)
			corpo.add_child(fa)
		"attrezzi":
			for k in 3:
				var a := attrezzo(["ascia", "piccone", "pala"][k])
				a.position = spalla + Vector3(0.07, 0.01 + k * 0.012, -0.03 + k * 0.03)
				a.rotation_degrees = Vector3(0, 90, 0)
				corpo.add_child(a)
		"spada":
			var sp := pesce_spada_modello()
			sp.position = spalla + Vector3(0.07, 0.0, -0.05)
			sp.rotation_degrees = Vector3(0, 90, 0)
			sp.scale = Vector3.ONE * 0.8
			corpo.add_child(sp)
	r.set_meta("carico", carico)
	return r


static func posa_cammino(modello: Node3D, fotogramma: int, totale: int) -> void:
	var t := float(fotogramma) / totale * TAU
	var oscill := sin(t)
	var corpo: Node3D = modello.get_node("corpo")
	corpo.position.y = absf(cos(t)) * 0.012
	(corpo.get_node("gamba_s") as Node3D).rotation.x = oscill * 0.5
	(corpo.get_node("gamba_d") as Node3D).rotation.x = -oscill * 0.5
	var carico: String = modello.get_meta("carico", "")
	var bs: Node3D = corpo.get_node("braccio_s")
	var bd: Node3D = corpo.get_node("braccio_d")
	corpo.rotation.x = 0.0
	if carico == "attrezzo":
		# attrezzo in spalla
		bs.rotation = Vector3(-oscill * 0.45, 0, 0)
		bd.rotation = Vector3(-2.6, 0, 0.2)
	elif carico == "":
		bs.rotation.x = -oscill * 0.45
		bd.rotation.x = oscill * 0.45
	elif carico == "anfora" or carico == "pietra":
		bs.rotation = Vector3(0, 0, -2.6)
		bd.rotation = Vector3(0, 0, 2.6)
	else:
		bs.rotation = Vector3(-0.3 - oscill * 0.2, 0, 0)
		bd.rotation = Vector3(-0.4, 0, 2.2)


static func rocce(seme: int) -> Node3D:
	var rng := RandomNumberGenerator.new()
	rng.seed = seme * 31
	var r := Node3D.new()
	for k in 3 + seme % 2:
		var mi := MeshInstance3D.new()
		var sm := SphereMesh.new()
		sm.radius = 0.5
		sm.height = 1.0
		sm.radial_segments = 7
		sm.rings = 4
		mi.mesh = sm
		var dim := rng.randf_range(0.12, 0.26)
		mi.scale = Vector3(dim * rng.randf_range(1.0, 1.6), dim * rng.randf_range(0.6, 1.0), dim * rng.randf_range(0.9, 1.4))
		mi.position = Vector3(rng.randf_range(-0.18, 0.18), dim * 0.3, rng.randf_range(-0.15, 0.15))
		mi.rotation = Vector3(rng.randf_range(-0.3, 0.3), rng.randf() * TAU, rng.randf_range(-0.3, 0.3))
		mi.material_override = materiale("roccia_massi")
		r.add_child(mi)
	r.add_child(sfera(0.05, Vector3(0.2, 0.02, 0.18), "aghi", Vector3(1.4, 0.5, 1.0)))
	return r



# ------------------------------------------------------------------ altri edifici greci (step 02)





static func cantiere(fase: int) -> Node3D:
	var r := Node3D.new()
	var l := 0.62
	# picchetti e corda che segnano l'area
	for p in [Vector3(-l, 0, -l), Vector3(l, 0, -l), Vector3(l, 0, l), Vector3(-l, 0, l)]:
		r.add_child(cilindro(0.01, 0.006, 0.09, p * 0.5 + Vector3(0, 0.045, 0), "legno", Vector3.ZERO, 5))
	for k in 4:
		var a := k * PI / 2
		var lungo := scatola(Vector3(l, 0.004, 0.004), Vector3(cos(a) * l * 0.5, 0.07, sin(a) * l * 0.5), "corda", Vector3(0, rad_to_deg(a) + 90, 0))
		r.add_child(lungo)
	if fase >= 1:
		r.add_child(scatola(Vector3(l * 0.86, 0.05, l * 0.86), Vector3(0, 0.025, 0), "pietra"))
		for i in 3:
			r.add_child(scatola(Vector3(0.1, 0.07, 0.07), Vector3(-0.38 + i * 0.11, 0.035, 0.42), "blocco", Vector3(0, i * 7, 0)))
		pila_assi(r, Vector3(0.42, 0, 0.1), 4, 90)
	if fase >= 2:
		var h := 0.18
		r.add_child(scatola(Vector3(l * 0.8, h, 0.04), Vector3(0, 0.05 + h * 0.5, l * 0.4 - 0.02), "intonaco"))
		r.add_child(scatola(Vector3(0.04, h * 0.7, l * 0.5), Vector3(l * 0.4 - 0.02, 0.05 + h * 0.35, 0.1), "intonaco"))
		for p in [Vector3(-l * 0.45, 0, l * 0.45), Vector3(l * 0.45, 0, l * 0.45), Vector3(l * 0.45, 0, -l * 0.45), Vector3(-l * 0.45, 0, -l * 0.45)]:
			r.add_child(cilindro(0.012, 0.012, 0.36, p + Vector3(0, 0.18, 0), "legno", Vector3.ZERO, 5))
		for y in [0.17, 0.31]:
			r.add_child(scatola(Vector3(l * 0.92, 0.012, 0.012), Vector3(0, y, l * 0.45), "legno"))
			r.add_child(scatola(Vector3(0.012, 0.012, l * 0.92), Vector3(l * 0.45, y, 0), "legno"))
		r.add_child(scatola(Vector3(l * 0.9, 0.015, 0.08), Vector3(0, 0.17, l * 0.5), "legno_chiaro"))
	r.scale = Vector3.ONE * 1.3
	return r


static func bandierina() -> Node3D:
	var r := Node3D.new()
	r.add_child(cilindro(0.04, 0.05, 0.03, Vector3(0, 0.015, 0), "pietra", Vector3.ZERO, 8))
	r.add_child(cilindro(0.008, 0.008, 0.4, Vector3(0, 0.2, 0), "legno", Vector3.ZERO, 6))
	r.add_child(scatola(Vector3(0.16, 0.1, 0.006), Vector3(0.08, 0.34, 0), "stoffa", Vector3(0, -40, 0)))
	r.scale = Vector3.ONE * 1.3
	return r



# ------------------------------------------------------------------ merci (posate a terra vicino alle bandierine)

static func merce(tipo: String) -> Node3D:
	var r := Node3D.new()
	match tipo:
		"assi":
			for k in 3:
				r.add_child(scatola(Vector3(0.26, 0.022, 0.07), Vector3(0, 0.012 + k * 0.024, (k % 2) * 0.01), "legno_chiaro", Vector3(0, 30 + k * 4, 0)))
		"tronchi":
			r.add_child(cilindro(0.04, 0.04, 0.24, Vector3(0, 0.04, 0), "corteccia", Vector3(90, 30, 0), 8))
			r.add_child(cilindro(0.033, 0.033, 0.242, Vector3(0, 0.04, 0), "legno_chiaro", Vector3(90, 30, 0), 8))
		"pietra":
			r.add_child(scatola(Vector3(0.12, 0.08, 0.1), Vector3(0, 0.04, 0), "blocco", Vector3(0, 20, 0)))
			r.add_child(scatola(Vector3(0.07, 0.05, 0.06), Vector3(0.07, 0.025, 0.05), "blocco", Vector3(0, -10, 0)))
		"grano":
			var cv := covone(1.1)
			cv.rotation_degrees = Vector3(0, 0, 80)
			cv.position = Vector3(0.0, 0.05, 0)
			r.add_child(cv)
		"farina":
			r.add_child(sfera(0.07, Vector3(0, 0.06, 0), "lino", Vector3(1, 0.85, 0.8)))
			r.add_child(cilindro(0.025, 0.02, 0.03, Vector3(0, 0.125, 0), "lino", Vector3.ZERO, 8))
		"pane":
			r.add_child(cesta(Vector3.ZERO, "pane"))
		"acqua":
			r.add_child(anfora(Vector3.ZERO, 1.3))
		"pesce":
			r.add_child(cesta(Vector3.ZERO, "pesce"))
		"maiale":
			r.add_child(maiale(Vector3.ZERO, 30))
		"carne":
			r.add_child(sfera(0.05, Vector3(0, 0.04, 0), "carne", Vector3(1.5, 0.8, 1.0)))
			r.add_child(cilindro(0.016, 0.016, 0.1, Vector3(0.05, 0.016, 0.05), "carne", Vector3(0, 30, 90), 8))
		"latte":
			r.add_child(anfora(Vector3.ZERO, 1.2))
			r.add_child(cilindro(0.02, 0.02, 0.004, Vector3(0, 0.235, 0), "latte", Vector3.ZERO, 8))
		"lana":
			r.add_child(sfera(0.07, Vector3(0, 0.05, 0), "lana", Vector3(1.3, 0.7, 1.0)))
		"formaggio":
			r.add_child(cesta(Vector3.ZERO, "formaggio"))
		"olive", "uva", "ortaggi", "cipolle", "agrumi":
			r.add_child(cesta(Vector3.ZERO, tipo))
		"olio", "vino":
			r.add_child(anfora(Vector3.ZERO, 1.3))
			r.add_child(cilindro(0.02, 0.02, 0.004, Vector3(0, 0.235, 0), "miele" if tipo == "olio" else "vino", Vector3.ZERO, 8))
		"pesce_spada":
			r.add_child(pesce_spada_modello())
		"armi":
			r.add_child(fascio_armi())
		"ferro":
			r.add_child(mucchio(Vector3.ZERO, "minerale", 5, 8, 0.04))
		"carbone":
			r.add_child(cesta(Vector3.ZERO, "carbone"))
		"lingotti":
			for k in 3:
				r.add_child(scatola(Vector3(0.1, 0.028, 0.04), Vector3((k % 2) * 0.02, 0.014 + k * 0.028, 0), "lingotto", Vector3(0, 20 + k * 30, 0)))
		"argilla":
			r.add_child(mucchio(Vector3.ZERO, "argilla", 5, 11, 0.04))
		"anfore":
			r.add_child(anfora(Vector3(-0.03, 0, 0), 1.2))
			r.add_child(anfora(Vector3(0.05, 0, 0.03), 1.1))
		"sale":
			r.add_child(sfera(0.065, Vector3(0, 0.05, 0), "lino", Vector3(1, 0.8, 0.8)))
			r.add_child(sfera(0.03, Vector3(0, 0.1, 0), "sale"))
		"argento":
			r.add_child(mucchio(Vector3.ZERO, "argento_grezzo", 5, 12, 0.04))
		"ducati":
			r.add_child(sfera(0.05, Vector3(0, 0.04, 0), "pelle_scura", Vector3(1, 0.9, 1)))
			for k in 4:
				r.add_child(cilindro(0.016, 0.016, 0.005, Vector3(0.05 + k * 0.004, 0.003 + k * 0.006, 0.03), "moneta", Vector3.ZERO, 8))
		"stoffa":
			r.add_child(cilindro(0.035, 0.035, 0.16, Vector3(0, 0.035, 0), "stoffa_rossa", Vector3(90, 30, 0), 10))
			r.add_child(cilindro(0.03, 0.03, 0.14, Vector3(0.03, 0.09, 0.0), "stoffa", Vector3(90, 50, 0), 10))
		"ascia", "piccone", "pala", "falce", "canna", "sega", "martello":
			var a := attrezzo(tipo)
			a.rotation_degrees.y = 30
			a.scale = Vector3.ONE * 1.3
			r.add_child(a)
		"miele":
			r.add_child(cilindro(0.04, 0.035, 0.08, Vector3(0, 0.04, 0), "terracotta", Vector3.ZERO, 10))
			r.add_child(cilindro(0.032, 0.032, 0.005, Vector3(0, 0.082, 0), "miele", Vector3.ZERO, 10))
		"tegole":
			_pila_tegole(r, Vector3.ZERO, 4, 25)
			for k in 2:
				var cp := cilindro(0.022, 0.018, 0.13, Vector3(-0.022 + k * 0.044, 0.085, 0.0), "laterizio", Vector3(90, 25, 0), 8)
				cp.scale = Vector3(1, 1, 0.6)
				r.add_child(cp)
		"pece":
			r.add_child(_vaso_pece(Vector3(-0.03, 0, 0), 1.15))
			r.add_child(_vaso_pece(Vector3(0.055, 0, 0.035), 0.95))
		"bozzoli":
			r.add_child(cilindro(0.075, 0.06, 0.055, Vector3(0, 0.0275, 0), "canne", Vector3.ZERO, 14))
			r.add_child(_toro(0.07, 0.08, Vector3(0, 0.056, 0), "legno_vecchio"))
			var rb := _rng(77)
			for k in 18:
				var a := k * 2.4
				var rr := 0.012 + (k % 4) * 0.016
				var b := sfera(0.017, Vector3(cos(a) * rr, 0.062 + (3 - k % 4) * 0.008 + rb.randf() * 0.006, sin(a) * rr), "bozzolo", Vector3(1.55, 1.0, 1.0))
				b.rotation_degrees.y = rb.randf() * 180
				r.add_child(b)
		"seta":
			var tinte := ["seta_cremisi", "seta_verde", "seta_oro"]
			for k in 3:
				r.add_child(_toro(0.016, 0.04, Vector3((k - 1) * 0.012, 0.018 + k * 0.026, (k % 2) * 0.012), tinte[k], Vector3(0, 25 + k * 35, 0), Vector3(1.9, 2.0, 0.9)))
			var appesa := _toro(0.014, 0.036, Vector3(0.05, 0.05, 0.02), "seta_azzurra", Vector3(0, 0, 80), Vector3(1.8, 1.6, 0.8))
			r.add_child(appesa)
		"cavalli":
			var cv := _cavallo_n("cavallo_baio", 1.0)
			cv.scale = Vector3.ONE * 0.42
			cv.rotation_degrees.y = 60
			var cc: Node3D = cv.get_node("corpo")
			cc.add_child(scatola(Vector3(0.17, 0.014, 0.16), Vector3(0, 0.395, -0.01), "stoffa_oro"))
			for lato: int in [-1, 1]:
				cc.add_child(scatola(Vector3(0.008, 0.09, 0.16), Vector3(lato * 0.084, 0.35, -0.01), "stoffa_oro"))
				cc.add_child(scatola(Vector3(0.01, 0.016, 0.162), Vector3(lato * 0.085, 0.305, -0.01), "bandiera_rossa"))
			cc.add_child(scatola(Vector3(0.095, 0.03, 0.11), Vector3(0, 0.415, -0.015), "pelle_scura"))
			cc.add_child(scatola(Vector3(0.08, 0.05, 0.018), Vector3(0, 0.44, 0.04), "pelle_scura"))
			r.add_child(cv)
		"ceramiche":
			r.add_child(_vaso_sic(Vector3(-0.04, 0, -0.02), 1.15, 1))
			r.add_child(_vaso_sic(Vector3(0.045, 0, 0.0), 1.05, 0))
			r.add_child(_vaso_sic(Vector3(0.0, 0, 0.055), 0.9, 2))
		"lame":
			r.add_child(scatola(Vector3(0.14, 0.008, 0.11), Vector3(0, 0.004, 0), "lapislazzuli", Vector3(0, 15, 0)))
			r.add_child(scatola(Vector3(0.1, 0.009, 0.075), Vector3(0, 0.005, 0), "lino", Vector3(0, 15, 0)))
			for k in 4:
				r.add_child(_lama_oss(Vector3(-0.004 + k * 0.003, 0.016 + (k % 2) * 0.008, -0.03 + k * 0.02), Vector3(0, 15 + (k - 2) * 6, (k % 2) * 5), 0.13, k == 1))
			r.add_child(_toro(0.022, 0.028, Vector3(-0.01, 0.02, 0.0), "corda", Vector3(0, 15, 90), Vector3(1, 0.7, 2.2)))
	r.scale = Vector3.ONE * 1.25
	return r


# =================================================================== KIT G2: parti ricche
# Coordinate: +Z = faccia sinistra (illuminata, con la porta), +X = faccia destra (in ombra).

static func _rng(seme: int) -> RandomNumberGenerator:
	var r := RandomNumberGenerator.new()
	r.seed = seme
	return r


## Muri intonacati "vissuti": zoccolo di pietra, cantonali squadrati, chiazze di intonaco caduto.
static func casa_muri(r: Node3D, lx: float, lz: float, h: float, seme: int, mat := "intonaco") -> void:
	var rng := _rng(seme)
	r.add_child(scatola(Vector3(lx + 0.06, 0.07, lz + 0.06), Vector3(0, 0.035, 0), "pietra"))
	r.add_child(scatola(Vector3(lx, h, lz), Vector3(0, 0.07 + h * 0.5, 0), mat))
	# chiazze dove l'intonaco è caduto e si vede la pietra
	for k in 3:
		var w := rng.randf_range(0.1, 0.22)
		var hh := rng.randf_range(0.06, 0.14)
		var y := rng.randf_range(0.12, h - 0.05)
		if k < 2:
			r.add_child(scatola(Vector3(w, hh, 0.01), Vector3(rng.randf_range(-lx * 0.4, lx * 0.4), y, lz * 0.5 + 0.002), "pietra_vista"))
		else:
			r.add_child(scatola(Vector3(0.01, hh, w), Vector3(lx * 0.5 + 0.002, y, rng.randf_range(-lz * 0.4, lz * 0.4)), "pietra_vista"))
	# cantonali sugli spigoli in vista
	var y := 0.1
	var k := 0
	while y < h:
		var lungo := 0.09 if k % 2 == 0 else 0.055
		r.add_child(scatola(Vector3(0.035, 0.05, lungo), Vector3(lx * 0.5 + 0.004, y, lz * 0.5 - lungo * 0.5 + 0.006), "blocco"))
		r.add_child(scatola(Vector3(lungo, 0.05, 0.035), Vector3(lx * 0.5 - lungo * 0.5 + 0.006, y, lz * 0.5 + 0.004), "blocco"))
		r.add_child(scatola(Vector3(lungo, 0.05, 0.035), Vector3(-lx * 0.5 + lungo * 0.5 - 0.006, y, lz * 0.5 + 0.004), "blocco"))
		y += 0.055
		k += 1


static func finestra_z(r: Node3D, x: float, y: float, zf: float, w := 0.1, h := 0.12, fiori := false) -> void:
	r.add_child(scatola(Vector3(w, h, 0.02), Vector3(x, y, zf + 0.002), "buio"))
	r.add_child(scatola(Vector3(w + 0.03, 0.02, 0.03), Vector3(x, y + h * 0.5 + 0.012, zf + 0.012), "legno_vecchio"))
	r.add_child(scatola(Vector3(w + 0.04, 0.018, 0.05), Vector3(x, y - h * 0.5 - 0.01, zf + 0.02), "blocco"))
	for lato in [-1, 1]:
		var p := scatola(Vector3(w * 0.5, h, 0.012), Vector3(x + lato * (w * 0.75 + 0.01), y, zf + 0.02), "persiana", Vector3(0, lato * 25, 0))
		r.add_child(p)
	if fiori:
		r.add_child(scatola(Vector3(w + 0.02, 0.03, 0.035), Vector3(x, y - h * 0.5 + 0.005, zf + 0.04), "terracotta"))
		for i in 4:
			r.add_child(sfera(0.018, Vector3(x - w * 0.4 + i * w * 0.27, y - h * 0.5 + 0.035, zf + 0.045), "geranio" if i % 2 == 0 else "orto"))


static func finestra_x(r: Node3D, z: float, y: float, xf: float, w := 0.1, h := 0.12) -> void:
	r.add_child(scatola(Vector3(0.02, h, w), Vector3(xf + 0.002, y, z), "buio"))
	r.add_child(scatola(Vector3(0.03, 0.02, w + 0.03), Vector3(xf + 0.012, y + h * 0.5 + 0.012, z), "legno_vecchio"))
	r.add_child(scatola(Vector3(0.05, 0.018, w + 0.04), Vector3(xf + 0.02, y - h * 0.5 - 0.01, z), "blocco"))
	for lato in [-1, 1]:
		r.add_child(scatola(Vector3(0.012, h, w * 0.5), Vector3(xf + 0.02, y, z + lato * (w * 0.75 + 0.01)), "persiana", Vector3(0, lato * -25, 0)))


static func porta_z(r: Node3D, x: float, zf: float, w := 0.12, h := 0.22) -> void:
	r.add_child(scatola(Vector3(w, h, 0.02), Vector3(x, 0.07 + h * 0.5, zf + 0.003), "legno_scuro"))
	for k in 3:
		r.add_child(scatola(Vector3(0.006, h - 0.02, 0.008), Vector3(x - w * 0.3 + k * w * 0.3, 0.07 + h * 0.5, zf + 0.014), "legno_vecchio"))
	r.add_child(scatola(Vector3(w + 0.05, 0.035, 0.04), Vector3(x, 0.07 + h + 0.017, zf + 0.012), "legno_vecchio"))
	for lato in [-1, 1]:
		r.add_child(scatola(Vector3(0.025, h, 0.03), Vector3(x + lato * (w * 0.5 + 0.012), 0.07 + h * 0.5, zf + 0.01), "blocco"))
	r.add_child(scatola(Vector3(w + 0.08, 0.035, 0.08), Vector3(x, 0.017, zf + 0.04), "pietra"))


## Tetto a coppi irregolari (due tinte, piccole rotazioni), travetti sporgenti sotto la gronda.
static func tetto(r: Node3D, larg: float, prof: float, base_y: float, pendenza: float, seme: int) -> void:
	var rng := _rng(seme)
	var meta := prof * 0.5 + 0.07
	var ang := deg_to_rad(pendenza)
	var lung := meta / cos(ang)
	var alt := meta * tan(ang)
	for lato in [-1, 1]:
		var falda := Node3D.new()
		falda.position = Vector3(0, base_y + alt * 0.5, lato * meta * 0.5)
		falda.rotation.x = lato * ang
		r.add_child(falda)
		falda.add_child(scatola(Vector3(larg + 0.14, 0.03, lung), Vector3.ZERO, "tegola_scura"))
		var n := int((larg + 0.12) / 0.07)
		for k in n:
			var x := -larg * 0.5 - 0.04 + (k + 0.5) * (larg + 0.08) / n
			var mat: String = ["tegola", "tegola_b", "tegola_c"][rng.randi_range(0, 2)]
			var coppo := cilindro(0.03, 0.027, lung, Vector3(x, 0.02 + rng.randf_range(0, 0.004), 0), mat, Vector3(90, rng.randf_range(-1.5, 1.5), 0), 8)
			coppo.scale = Vector3(1, 1, 0.55)
			falda.add_child(coppo)
	r.add_child(cilindro(0.045, 0.045, larg + 0.18, Vector3(0, base_y + alt + 0.025, 0), "tegola_b", Vector3(0, 0, 90), 10))
	# travetti sotto la gronda sul lato in vista
	var nt := int(larg / 0.12)
	for k in nt + 1:
		var x := -larg * 0.5 + k * larg / nt
		r.add_child(scatola(Vector3(0.025, 0.025, 0.09), Vector3(x, base_y - 0.005, prof * 0.5 + 0.03), "legno_vecchio"))


static func comignolo(r: Node3D, pos: Vector3, h := 0.16) -> void:
	r.add_child(scatola(Vector3(0.08, h, 0.08), pos + Vector3(0, h * 0.5, 0), "intonaco"))
	r.add_child(scatola(Vector3(0.085, 0.035, 0.085), pos + Vector3(0, h - 0.015, 0), "fuliggine"))
	r.add_child(scatola(Vector3(0.11, 0.02, 0.11), pos + Vector3(0, h + 0.01, 0), "tegola_scura"))


static func barile(pos: Vector3, scala := 1.0) -> Node3D:
	var n := Node3D.new()
	n.position = pos
	n.scale = Vector3.ONE * scala
	n.add_child(cilindro(0.045, 0.045, 0.1, Vector3(0, 0.05, 0), "legno", Vector3.ZERO, 12))
	for y in [0.02, 0.08]:
		n.add_child(cilindro(0.048, 0.048, 0.008, Vector3(0, y, 0), "ferro", Vector3.ZERO, 12))
	return n


static func vaso_fiori(pos: Vector3) -> Node3D:
	var n := Node3D.new()
	n.position = pos
	n.add_child(cilindro(0.025, 0.02, 0.04, Vector3(0, 0.02, 0), "terracotta", Vector3.ZERO, 8))
	n.add_child(sfera(0.028, Vector3(0, 0.05, 0), "orto"))
	n.add_child(sfera(0.014, Vector3(0.012, 0.07, 0.01), "geranio"))
	n.add_child(sfera(0.012, Vector3(-0.012, 0.065, -0.005), "geranio"))
	return n


static func panca(pos: Vector3, rot := 0.0) -> Node3D:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot
	n.add_child(scatola(Vector3(0.2, 0.02, 0.05), Vector3(0, 0.05, 0), "legno"))
	for lato in [-1, 1]:
		n.add_child(scatola(Vector3(0.02, 0.05, 0.04), Vector3(lato * 0.08, 0.025, 0), "legno_vecchio"))
	return n


static func recinto(r: Node3D, da: Vector3, a: Vector3, h := 0.07) -> void:
	var lung := da.distance_to(a)
	var n := int(lung / 0.08) + 1
	for k in n + 1:
		var p := da.lerp(a, float(k) / n)
		r.add_child(cilindro(0.008, 0.007, h, p + Vector3(0, h * 0.5, 0), "legno_vecchio", Vector3.ZERO, 5))
	var dir := (a - da).normalized()
	var rot := rad_to_deg(atan2(dir.x, dir.z))
	for y in [h * 0.45, h * 0.85]:
		var t := scatola(Vector3(0.008, 0.01, lung), (da + a) * 0.5 + Vector3(0, y, 0), "legno_vecchio", Vector3(0, rot, 0))
		r.add_child(t)


static func orto(r: Node3D, pos: Vector3, lx: float, lz: float, seme: int) -> void:
	var rng := _rng(seme)
	r.add_child(scatola(Vector3(lx, 0.012, lz), pos + Vector3(0, 0.006, 0), "terra"))
	var file := int(lz / 0.07)
	for f in file:
		var z := pos.z - lz * 0.5 + (f + 0.5) * lz / file
		var piante := int(lx / 0.06)
		for k in piante:
			var x := pos.x - lx * 0.5 + (k + 0.5) * lx / piante
			r.add_child(sfera(rng.randf_range(0.018, 0.026), Vector3(x, 0.025, z), "orto" if f % 3 != 2 else "foglie_chiare", Vector3(1, 0.8, 1)))
	recinto(r, pos + Vector3(-lx * 0.5 - 0.02, 0, lz * 0.5 + 0.02), pos + Vector3(lx * 0.5 + 0.02, 0, lz * 0.5 + 0.02))
	recinto(r, pos + Vector3(lx * 0.5 + 0.02, 0, -lz * 0.5 - 0.02), pos + Vector3(lx * 0.5 + 0.02, 0, lz * 0.5 + 0.02))


static func legnaia(r: Node3D, pos: Vector3, lung := 0.3, file := 4) -> void:
	for f in file:
		for k in int(lung / 0.045):
			var x := pos.x - lung * 0.5 + (k + 0.5) * 0.045
			r.add_child(cilindro(0.02, 0.02, 0.1, Vector3(x, pos.y + 0.02 + f * 0.038, pos.z), "legno_chiaro" if (k + f) % 3 == 0 else "corteccia", Vector3(90, 0, 0), 6))


static func carretto(r: Node3D, pos: Vector3, rot := 0.0, carico := "") -> void:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot
	r.add_child(n)
	n.add_child(scatola(Vector3(0.3, 0.025, 0.18), Vector3(0, 0.1, 0), "legno"))
	for lato in [-1, 1]:
		n.add_child(scatola(Vector3(0.3, 0.05, 0.012), Vector3(0, 0.13, lato * 0.09), "legno_vecchio"))
		n.add_child(cilindro(0.065, 0.065, 0.02, Vector3(-0.02, 0.065, lato * 0.11), "legno_vecchio", Vector3(90, 0, 0), 14))
		n.add_child(cilindro(0.015, 0.015, 0.03, Vector3(-0.02, 0.065, lato * 0.115), "ferro", Vector3(90, 0, 0), 6))
	n.add_child(scatola(Vector3(0.24, 0.015, 0.015), Vector3(0.26, 0.07, 0.05), "legno", Vector3(0, 0, -12)))
	n.add_child(scatola(Vector3(0.24, 0.015, 0.015), Vector3(0.26, 0.07, -0.05), "legno", Vector3(0, 0, -12)))
	match carico:
		"sacchi":
			for i in 3:
				n.add_child(sfera(0.05, Vector3(-0.08 + i * 0.08, 0.15, 0.0), "lino", Vector3(1, 0.75, 0.8)))
		"tronchi":
			for i in 3:
				n.add_child(cilindro(0.03, 0.03, 0.34, Vector3(0, 0.14 + (i / 2) * 0.05, -0.035 + (i % 2) * 0.07), "corteccia", Vector3(0, 0, 90), 7))


# =================================================================== ALBERI G2

## Chioma fatta di tanti ciuffi: sotto più scuri, sopra più chiari (come le foglie al sole).
static func chioma(r: Node3D, centro: Vector3, raggio: Vector3, ciuffi: int, seme: int, mat_scuro := "foglie_scure", mat := "foglie", mat_chiaro := "foglie_chiare", dim := Vector2(0.045, 0.08)) -> void:
	var rng := _rng(seme)
	for k in ciuffi:
		var d := Vector3(rng.randf_range(-1, 1), rng.randf_range(-1, 1), rng.randf_range(-1, 1))
		if d.length() > 1.0:
			d = d.normalized() * rng.randf_range(0.6, 1.0)
		var p := centro + d * raggio
		var m := mat_scuro if d.y < -0.1 or rng.randf() < 0.18 else (mat_chiaro if d.y > 0.45 and rng.randf() < 0.45 else mat)
		r.add_child(sfera(rng.randf_range(dim.x, dim.y), p, m, Vector3(1, 0.85, 1)))


static func ramo(r: Node3D, da: Vector3, a: Vector3, spessore: float, mat := "corteccia") -> void:
	var dir := a - da
	var c := cilindro(spessore, spessore * 0.7, dir.length(), Vector3.ZERO, mat, Vector3.ZERO, 7)
	c.basis = Basis(Quaternion(Vector3.UP, dir.normalized()))
	c.position = (da + a) * 0.5
	r.add_child(c)


static func castagno(seme: int) -> Node3D:
	var rng := _rng(seme)
	var r := Node3D.new()
	var cima := Vector3(rng.randf_range(-0.05, 0.05), 0.42, rng.randf_range(-0.05, 0.05))
	ramo(r, Vector3.ZERO, cima, 0.065)
	for k in 3:
		var a := k * TAU / 3 + rng.randf()
		ramo(r, cima * 0.85, cima + Vector3(cos(a) * 0.22, 0.2, sin(a) * 0.22), 0.03)
	chioma(r, cima + Vector3(0, 0.3, 0), Vector3(0.42, 0.3, 0.42), 170, seme)
	r.add_child(sfera(0.08, Vector3(0.05, 0.02, 0.06), "foglie_scure", Vector3(1.6, 0.4, 1.2)))
	r.scale = Vector3.ONE * rng.randf_range(1.05, 1.25)
	return r


static func quercia(seme: int) -> Node3D:
	var rng := _rng(seme)
	var r := Node3D.new()
	var cima := Vector3(0, 0.34, 0)
	ramo(r, Vector3.ZERO, cima, 0.075)
	var centri := []
	for k in 4:
		var a := k * TAU / 4 + rng.randf_range(-0.4, 0.4)
		var c := cima + Vector3(cos(a) * 0.28, rng.randf_range(0.18, 0.32), sin(a) * 0.28)
		ramo(r, cima * 0.9, c, 0.035)
		centri.append(c)
	for k in centri.size():
		chioma(r, centri[k], Vector3(0.24, 0.18, 0.24), 60, seme * 10 + k)
	chioma(r, cima + Vector3(0, 0.42, 0), Vector3(0.26, 0.18, 0.26), 55, seme * 10 + 9)
	r.scale = Vector3.ONE * rng.randf_range(1.0, 1.2)
	return r


## Pino laricio della Sila: tronco alto e dritto rossiccio, chioma a palchi in cima.
static func pino_laricio(seme: int) -> Node3D:
	var rng := _rng(seme)
	var r := Node3D.new()
	var h := rng.randf_range(1.15, 1.45)
	ramo(r, Vector3.ZERO, Vector3(0, h, 0), 0.05, "fusto_chiaro")
	var palchi := 6
	for k in palchi:
		var t := float(k) / palchi
		var y := lerpf(h * 0.4, h * 0.98, t)
		var rag := lerpf(0.32, 0.1, t) * rng.randf_range(0.85, 1.15)
		for j in 4:
			var a := j * TAU / 4 + rng.randf() * 1.2 + k * 0.9
			var p := Vector3(cos(a) * rag * 0.65, y + rng.randf_range(-0.03, 0.03), sin(a) * rag * 0.65)
			ramo(r, Vector3(0, y - 0.04, 0), p, 0.012, "fusto_chiaro")
			chioma(r, p + Vector3(0, 0.025, 0), Vector3(rag * 0.55, 0.045, rag * 0.55), 9, seme * 100 + k * 10 + j, "foglie_scure", "aghi", "foglie", Vector2(0.035, 0.06))
	chioma(r, Vector3(0, h + 0.04, 0), Vector3(0.07, 0.06, 0.07), 6, seme * 100 + 99, "aghi", "aghi", "foglie", Vector2(0.03, 0.05))
	return r


static func ulivo(seme: int) -> Node3D:
	var rng := _rng(seme)
	var r := Node3D.new()
	# tronco contorto e grigio
	var p := Vector3.ZERO
	for k in 3:
		var q := p + Vector3(rng.randf_range(-0.07, 0.07), 0.1, rng.randf_range(-0.07, 0.07))
		ramo(r, p, q, 0.06 - k * 0.012, "legno_vecchio")
		p = q
	for k in 3:
		var a := k * TAU / 3 + rng.randf()
		var c := p + Vector3(cos(a) * 0.2, 0.12, sin(a) * 0.2)
		ramo(r, p, c, 0.022, "legno_vecchio")
		chioma(r, c + Vector3(0, 0.06, 0), Vector3(0.17, 0.1, 0.17), 22, seme * 7 + k, "foglie_ulivo", "foglie_ulivo", "foglie_chiare", Vector2(0.04, 0.07))
	chioma(r, p + Vector3(0, 0.22, 0), Vector3(0.18, 0.08, 0.18), 18, seme * 7 + 5, "foglie_ulivo", "foglie_ulivo", "foglie_chiare", Vector2(0.04, 0.07))
	r.scale = Vector3.ONE * rng.randf_range(1.1, 1.3)
	return r


static func cespuglio(seme: int) -> Node3D:
	var r := Node3D.new()
	chioma(r, Vector3(0, 0.09, 0), Vector3(0.16, 0.08, 0.14), 22, seme, "foglie_scure", "macchia", "foglie", Vector2(0.035, 0.06))
	if seme % 2 == 0:
		var rng := _rng(seme)
		for k in 7:
			r.add_child(sfera(0.012, Vector3(rng.randf_range(-0.14, 0.14), rng.randf_range(0.1, 0.17), rng.randf_range(-0.06, 0.14)), "geranio" if k % 2 else "fiore"))
	return r


static func fiori(seme: int) -> Node3D:
	var rng := _rng(seme)
	var r := Node3D.new()
	for k in 14:
		var p := Vector3(rng.randf_range(-0.2, 0.2), 0.0, rng.randf_range(-0.2, 0.2))
		r.add_child(cilindro(0.003, 0.003, 0.05, p + Vector3(0, 0.025, 0), "orto", Vector3.ZERO, 4))
		r.add_child(sfera(0.014, p + Vector3(0, 0.055, 0), ["fiore", "geranio", "tunica"][k % 3]))
	return r


static func funghi(seme: int) -> Node3D:
	var rng := _rng(seme)
	var r := Node3D.new()
	for k in 4:
		var p := Vector3(rng.randf_range(-0.1, 0.1), 0, rng.randf_range(-0.1, 0.1))
		r.add_child(cilindro(0.008, 0.01, 0.03, p + Vector3(0, 0.015, 0), "tunica", Vector3.ZERO, 6))
		r.add_child(sfera(0.022, p + Vector3(0, 0.032, 0), "bandiera_rossa" if k % 2 == 0 else "legno", Vector3(1, 0.55, 1)))
	return r


# =================================================================== EDIFICI G2 (impronta 2×2, magazzino 3×3)

static func casa_greca(seme := 1) -> Node3D:
	var r := Node3D.new()
	var corpo := Node3D.new()
	corpo.position = Vector3(-0.12, 0, -0.15)
	r.add_child(corpo)
	var lx := 0.92
	var lz := 0.7
	var h := 0.46
	casa_muri(corpo, lx, lz, h, seme)
	porta_z(corpo, -0.18, lz * 0.5)
	finestra_z(corpo, 0.18, 0.36, lz * 0.5, 0.11, 0.12, true)
	finestra_x(corpo, 0.0, 0.36, lx * 0.5)
	sottotetto(corpo, lx, lz, 0.07 + h, 24.0)
	tetto(corpo, lx + 0.06, lz, 0.07 + h, 24.0, seme)
	comignolo(corpo, Vector3(-0.25, 0.07 + h + 0.06, -0.12))
	# pergolato con vite sul lato
	for px in [-0.36, -0.06]:
		corpo.add_child(cilindro(0.012, 0.012, 0.36, Vector3(px, 0.18, lz * 0.5 + 0.28), "legno_vecchio", Vector3.ZERO, 6))
	corpo.add_child(scatola(Vector3(0.38, 0.02, 0.32), Vector3(-0.21, 0.37, lz * 0.5 + 0.15), "legno_vecchio"))
	chioma(corpo, Vector3(-0.21, 0.4, lz * 0.5 + 0.15), Vector3(0.2, 0.03, 0.16), 26, seme + 50, "foglie_scure", "foglie", "foglie_chiare", Vector2(0.025, 0.045))
	corpo.add_child(panca(Vector3(-0.21, 0, lz * 0.5 + 0.26), 0))
	corpo.add_child(anfora(Vector3(0.08, 0.0, lz * 0.5 + 0.12), 1.15))
	corpo.add_child(anfora(Vector3(0.16, 0.0, lz * 0.5 + 0.16), 1.0))
	corpo.add_child(vaso_fiori(Vector3(-0.02, 0.0, lz * 0.5 + 0.08)))
	# orto recintato e legnaia
	orto(r, Vector3(0.56, 0, 0.42), 0.36, 0.42, seme + 3)
	legnaia(corpo, Vector3(lx * 0.5 + 0.06, 0.0, -0.2), 0.24, 3)
	r.add_child(barile(Vector3(-0.62, 0.0, 0.62)))
	return r


static func magazzino() -> Node3D:
	var r := Node3D.new()
	var lx := 1.75
	var lz := 1.3
	var h := 0.6
	var portico := 0.32
	r.position = Vector3(0, 0, -0.1)
	for k in 3:
		r.add_child(scatola(Vector3(lx + 0.3 - k * 0.1, 0.045, lz + 0.3 - k * 0.1), Vector3(0, 0.022 + k * 0.045, 0), "marmo" if k == 2 else "pietra"))
	var base := 0.135
	var cz := lz - portico
	var cella := Node3D.new()
	cella.position = Vector3(0, base - 0.07, -portico * 0.5)
	r.add_child(cella)
	casa_muri(cella, lx - 0.1, cz, h, 7)
	porta_z(cella, 0.0, cz * 0.5, 0.26, 0.36)
	for fx in [-0.55, 0.55]:
		finestra_z(cella, fx, 0.45, cz * 0.5, 0.12, 0.14)
	finestra_x(cella, 0.0, 0.45, (lx - 0.1) * 0.5)
	# colonnato
	var n := 8
	for k in n:
		var x := -lx * 0.5 + 0.08 + k * (lx - 0.16) / (n - 1)
		var zc := lz * 0.5 - 0.07
		r.add_child(cilindro(0.05, 0.042, h, Vector3(x, base + h * 0.5, zc), "marmo", Vector3.ZERO, 14))
		r.add_child(scatola(Vector3(0.11, 0.03, 0.11), Vector3(x, base + h + 0.01, zc), "marmo"))
		r.add_child(scatola(Vector3(0.1, 0.02, 0.1), Vector3(x, base + 0.01, zc), "marmo"))
	for z in [lz * 0.5 - 0.25]:
		r.add_child(cilindro(0.05, 0.042, h, Vector3(lx * 0.5 - 0.08, base + h * 0.5, z), "marmo", Vector3.ZERO, 14))
	# trabeazione, fregio a triglifi, frontone
	var ty := base + h + 0.025
	r.add_child(scatola(Vector3(lx + 0.04, 0.07, lz + 0.04), Vector3(0, ty + 0.035, 0), "marmo"))
	for k in 20:
		var x := -lx * 0.5 + 0.04 + k * (lx - 0.08) / 19
		r.add_child(scatola(Vector3(0.035, 0.05, 0.012), Vector3(x, ty + 0.035, lz * 0.5 + 0.026), "intonaco_sporco" if k % 2 == 0 else "persiana"))
	r.add_child(scatola(Vector3(lx + 0.08, 0.025, lz + 0.08), Vector3(0, ty + 0.08, 0), "marmo"))
	sottotetto(r, lx + 0.04, lz + 0.04, ty + 0.09, 16.0, "marmo")
	tetto(r, lx + 0.1, lz + 0.04, ty + 0.09, 16.0, 7)
	# merci e vita davanti al magazzino
	for i in 4:
		r.add_child(anfora(Vector3(-0.78 + (i % 2) * 0.09, base - 0.07, lz * 0.5 + 0.2 + (i / 2) * 0.1), 1.2))
	for i in 3:
		r.add_child(cassa(Vector3(0.45 + i * 0.13, base - 0.07, lz * 0.5 + 0.24), i * 12))
	r.add_child(cassa(Vector3(0.52, base - 0.07 + 0.088, lz * 0.5 + 0.24), 25, 0.09))
	for i in 3:
		r.add_child(sacco(Vector3(-0.42 + i * 0.1, base - 0.07, lz * 0.5 + 0.22), i * 0.5))
	r.add_child(barile(Vector3(0.92, 0.0, 0.3), 1.2))
	r.add_child(barile(Vector3(0.95, 0.0, 0.42), 1.2))
	carretto(r, Vector3(-0.2, 0.0, lz * 0.5 + 0.55), 20, "sacchi")
	# stendardo del giocatore
	r.add_child(cilindro(0.012, 0.012, 0.7, Vector3(lx * 0.5 + 0.12, 0.35, lz * 0.5 + 0.12), "legno", Vector3.ZERO, 6))
	r.add_child(scatola(Vector3(0.006, 0.2, 0.14), Vector3(lx * 0.5 + 0.12, 0.6, lz * 0.5 + 0.2), "stoffa"))
	return r


static func boscaiolo() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.15, 0, -0.18)
	r.add_child(c)
	var lx := 0.8
	var lz := 0.62
	var h := 0.36
	c.add_child(scatola(Vector3(lx + 0.06, 0.06, lz + 0.06), Vector3(0, 0.03, 0), "pietra"))
	c.add_child(scatola(Vector3(lx, h, lz), Vector3(0, 0.06 + h * 0.5, 0), "legno"))
	var file := 8
	for k in file:
		var y := 0.08 + k * (h / file)
		c.add_child(cilindro(0.024, 0.024, lx + 0.1, Vector3(0, y, lz * 0.5), "corteccia", Vector3(0, 0, 90), 7))
		c.add_child(cilindro(0.024, 0.024, lz + 0.1, Vector3(lx * 0.5, y + 0.022, 0), "corteccia", Vector3(90, 0, 0), 7))
		for lato in [-1, 1]:
			c.add_child(cilindro(0.021, 0.021, 0.006, Vector3(lato * (lx * 0.5 + 0.05), y, lz * 0.5), "legno_chiaro", Vector3(0, 0, 90), 7))
	porta_z(c, -0.15, lz * 0.5 + 0.02, 0.12, 0.22)
	finestra_z(c, 0.18, 0.3, lz * 0.5 + 0.02, 0.1, 0.09)
	sottotetto(c, lx, lz, 0.06 + h, 32.0, "legno")
	tetto_scandole(c, lx + 0.06, lz, 0.06 + h, 32.0)
	comignolo(c, Vector3(0.2, 0.06 + h + 0.1, -0.1), 0.14)
	# tettoia con legna spaccata
	for pz in [-0.25, 0.25]:
		c.add_child(cilindro(0.012, 0.012, 0.3, Vector3(lx * 0.5 + 0.3, 0.15, pz), "legno_vecchio", Vector3.ZERO, 6))
	c.add_child(scatola(Vector3(0.3, 0.02, 0.6), Vector3(lx * 0.5 + 0.17, 0.31, 0), "legno_scuro", Vector3(0, 0, -15)))
	legnaia(c, Vector3(lx * 0.5 + 0.17, 0.0, 0.0), 0.5, 5)
	# grande catasta di tronchi, ceppo con ascia, cavalletto, ceppaie
	catasta_tronchi(r, Vector3(0.55, 0, 0.55), 4, 0.5)
	r.add_child(cilindro(0.07, 0.075, 0.09, Vector3(-0.2, 0.045, 0.5), "corteccia", Vector3.ZERO, 12))
	r.add_child(cilindro(0.066, 0.066, 0.006, Vector3(-0.2, 0.092, 0.5), "legno_chiaro", Vector3.ZERO, 12))
	r.add_child(cilindro(0.008, 0.008, 0.22, Vector3(-0.2, 0.18, 0.5), "legno", Vector3(0, 0, 22), 6))
	r.add_child(scatola(Vector3(0.055, 0.04, 0.012), Vector3(-0.245, 0.27, 0.5), "ferro", Vector3(0, 0, 22)))
	for i in 6:
		r.add_child(cilindro(0.02, 0.02, 0.06, Vector3(-0.38 + i * 0.06, 0.02, 0.62 + (i % 2) * 0.05), "legno_chiaro", Vector3(0, i * 37, 90), 6))
	for pos in [Vector3(-0.72, 0, 0.3), Vector3(-0.6, 0, 0.75)]:
		r.add_child(cilindro(0.06, 0.07, 0.05, pos + Vector3(0, 0.025, 0), "corteccia", Vector3.ZERO, 10))
		r.add_child(cilindro(0.056, 0.056, 0.005, pos + Vector3(0, 0.052, 0), "legno_chiaro", Vector3.ZERO, 10))
	return r


static func segheria() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.25)
	r.add_child(c)
	var lx := 0.85
	var lz := 0.62
	var h := 0.44
	casa_muri(c, lx, lz, h, 11, "pietra_vista")
	porta_z(c, -0.22, lz * 0.5, 0.15, 0.26)
	finestra_z(c, 0.15, 0.38, lz * 0.5, 0.1, 0.11)
	finestra_x(c, 0.05, 0.38, lx * 0.5)
	sottotetto(c, lx, lz, 0.07 + h, 22.0, "pietra_vista")
	tetto(c, lx + 0.06, lz, 0.07 + h, 22.0, 11)
	# grande tettoia aperta con la sega a telaio
	var t := Node3D.new()
	t.position = Vector3(0.05, 0, 0.5)
	r.add_child(t)
	for p in [Vector3(-0.42, 0, -0.18), Vector3(0.42, 0, -0.18), Vector3(-0.42, 0, 0.22), Vector3(0.42, 0, 0.22)]:
		t.add_child(cilindro(0.018, 0.018, 0.4, p + Vector3(0, 0.2, 0), "legno_vecchio", Vector3.ZERO, 6))
	t.add_child(scatola(Vector3(0.95, 0.025, 0.5), Vector3(0, 0.41, 0.02), "legno_scuro", Vector3(-10, 0, 0)))
	for k in 6:
		t.add_child(scatola(Vector3(0.95, 0.012, 0.05), Vector3(0, 0.425, -0.2 + k * 0.08), "tegola_b", Vector3(-10, 0, 0)))
	for px in [-0.25, 0.0, 0.25]:
		t.add_child(scatola(Vector3(0.03, 0.12, 0.12), Vector3(px, 0.06, 0.0), "legno"))
	t.add_child(cilindro(0.055, 0.055, 0.8, Vector3(0, 0.17, 0.0), "corteccia", Vector3(0, 0, 90), 9))
	t.add_child(cilindro(0.047, 0.047, 0.805, Vector3(0, 0.17, 0.0), "legno_chiaro", Vector3(0, 0, 90), 9))
	for z in [-0.08, 0.08]:
		t.add_child(scatola(Vector3(0.014, 0.3, 0.014), Vector3(0.1, 0.24, z), "legno"))
	t.add_child(scatola(Vector3(0.014, 0.014, 0.18), Vector3(0.1, 0.38, 0.0), "legno"))
	t.add_child(scatola(Vector3(0.006, 0.006, 0.17), Vector3(0.1, 0.2, 0.0), "ferro"))
	t.add_child(cilindro(0.2, 0.2, 0.004, Vector3(0.1, 0.002, 0.0), "legno_chiaro", Vector3.ZERO, 16))
	# pile di assi e tronchi in attesa
	pila_assi(r, Vector3(0.62, 0, -0.25), 8, 90)
	pila_assi(r, Vector3(0.62, 0, 0.12), 5, 90)
	catasta_tronchi(r, Vector3(-0.65, 0, 0.55), 3, 0.42)
	carretto(r, Vector3(0.35, 0, 0.85), -30, "tronchi")
	return r


static func frantoio() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.22)
	r.add_child(c)
	var lx := 0.82
	var lz := 0.62
	var h := 0.42
	casa_muri(c, lx, lz, h, 13)
	porta_z(c, 0.18, lz * 0.5, 0.15, 0.25)
	finestra_z(c, -0.18, 0.36, lz * 0.5, 0.1, 0.11, true)
	finestra_x(c, 0.0, 0.36, lx * 0.5)
	sottotetto(c, lx, lz, 0.07 + h, 20.0)
	tetto(c, lx + 0.06, lz, 0.07 + h, 20.0, 13)
	comignolo(c, Vector3(-0.22, 0.07 + h + 0.05, -0.1))
	# macina all'aperto: vasca, ruota di pietra, stanga
	var m := Vector3(-0.35, 0, 0.55)
	r.add_child(cilindro(0.26, 0.28, 0.1, m + Vector3(0, 0.05, 0), "pietra", Vector3.ZERO, 24))
	r.add_child(cilindro(0.21, 0.21, 0.01, m + Vector3(0, 0.101, 0), "foglie_ulivo", Vector3.ZERO, 24))
	r.add_child(cilindro(0.03, 0.03, 0.22, m + Vector3(0, 0.2, 0), "legno", Vector3.ZERO, 8))
	r.add_child(cilindro(0.12, 0.12, 0.08, m + Vector3(0.1, 0.22, 0), "blocco", Vector3(0, 0, 90), 18))
	r.add_child(scatola(Vector3(0.6, 0.03, 0.03), m + Vector3(0.2, 0.26, 0), "legno_vecchio"))
	# giare d'olio, ceste di olive, botti
	for i in 6:
		r.add_child(anfora(Vector3(0.25 + (i % 3) * 0.1, 0.0, 0.42 + (i / 3) * 0.11), 1.15))
	for i in 3:
		r.add_child(cilindro(0.06, 0.05, 0.06, Vector3(0.62, 0.03, -0.3 + i * 0.16), "paglia", Vector3.ZERO, 12))
		r.add_child(sfera(0.05, Vector3(0.62, 0.06, -0.3 + i * 0.16), "foglie_ulivo", Vector3(1, 0.4, 1)))
	r.add_child(barile(Vector3(0.62, 0.0, 0.25), 1.2))
	r.add_child(ulivo(31))
	r.get_child(r.get_child_count() - 1).position = Vector3(-0.7, 0, -0.45)
	r.get_child(r.get_child_count() - 1).scale = Vector3.ONE * 0.8
	return r


static func cava() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.35, 0, -0.3)
	r.add_child(c)
	casa_muri(c, 0.55, 0.48, 0.3, 17, "pietra_vista")
	porta_z(c, -0.08, 0.24, 0.11, 0.2)
	sottotetto(c, 0.55, 0.48, 0.37, 24.0, "pietra_vista")
	tetto(c, 0.6, 0.48, 0.37, 24.0, 17)
	# parete di roccia gradonata da cui si estraggono i blocchi
	var rng := _rng(17)
	for k in 9:
		var p := Vector3(0.35 + rng.randf_range(-0.2, 0.2), 0.0, -0.4 + rng.randf_range(-0.15, 0.2))
		var d := rng.randf_range(0.16, 0.3)
		r.add_child(scatola(Vector3(d, d * rng.randf_range(0.6, 1.4), d * 0.8), p + Vector3(0, d * 0.4, 0), "roccia_massi", Vector3(0, rng.randf() * 60, 0)))
	# blocchi squadrati pronti, impalcatura di travi, attrezzi
	for i in 4:
		for j in 2 - (i / 3):
			r.add_child(scatola(Vector3(0.13, 0.09, 0.09), Vector3(-0.1 + i * 0.15, 0.045 + j * 0.09, 0.45), "blocco", Vector3(0, i * 5 - 6, 0)))
	r.add_child(scatola(Vector3(0.012, 0.4, 0.012), Vector3(0.12, 0.2, -0.05), "legno"))
	r.add_child(scatola(Vector3(0.012, 0.4, 0.012), Vector3(0.12, 0.2, 0.15), "legno"))
	r.add_child(scatola(Vector3(0.012, 0.012, 0.25), Vector3(0.12, 0.4, 0.05), "legno"))
	r.add_child(cilindro(0.004, 0.004, 0.2, Vector3(0.12, 0.3, 0.05), "corda", Vector3.ZERO, 4))
	r.add_child(cilindro(0.008, 0.008, 0.22, Vector3(0.55, 0.11, 0.35), "legno", Vector3(0, 0, -25), 6))
	r.add_child(scatola(Vector3(0.11, 0.014, 0.014), Vector3(0.6, 0.21, 0.35), "ferro", Vector3(0, 0, -25)))
	carretto(r, Vector3(-0.45, 0, 0.6), 15)
	r.add_child(scatola(Vector3(0.1, 0.07, 0.07), Vector3(-0.45, 0.16, 0.6), "blocco"))
	return r


static func guardaboschi() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.3, 0, -0.3)
	r.add_child(c)
	c.add_child(scatola(Vector3(0.62, 0.05, 0.52), Vector3(0, 0.025, 0), "pietra"))
	c.add_child(scatola(Vector3(0.58, 0.32, 0.48), Vector3(0, 0.05 + 0.16, 0), "legno"))
	for k in 7:
		c.add_child(cilindro(0.022, 0.022, 0.66, Vector3(0, 0.07 + k * 0.045, 0.24), "corteccia", Vector3(0, 0, 90), 7))
	porta_z(c, 0.12, 0.26, 0.11, 0.2)
	finestra_z(c, -0.14, 0.28, 0.26, 0.09, 0.09)
	sottotetto(c, 0.58, 0.48, 0.37, 34.0, "legno")
	tetto_scandole(c, 0.64, 0.48, 0.37, 34.0)
	# vivaio di alberelli in file, recintato
	for i in 4:
		for j in 3:
			var p := Vector3(-0.1 + i * 0.16, 0, 0.3 + j * 0.15)
			r.add_child(scatola(Vector3(0.1, 0.012, 0.1), p + Vector3(0, 0.006, 0), "terra"))
			r.add_child(cilindro(0.006, 0.006, 0.06 + j * 0.02, p + Vector3(0, 0.03, 0), "corteccia", Vector3.ZERO, 5))
			r.add_child(cilindro(0.035 + j * 0.008, 0.0, 0.09 + j * 0.03, p + Vector3(0, 0.09 + j * 0.03, 0), "aghi", Vector3.ZERO, 7))
	recinto(r, Vector3(-0.2, 0, 0.75), Vector3(0.52, 0, 0.75))
	recinto(r, Vector3(0.52, 0, 0.2), Vector3(0.52, 0, 0.75))
	# annaffiatoio, pala, sacchi di semi
	r.add_child(cilindro(0.03, 0.03, 0.05, Vector3(0.35, 0.025, -0.2), "ferro", Vector3.ZERO, 8))
	r.add_child(cilindro(0.007, 0.007, 0.22, Vector3(0.2, 0.11, -0.3), "legno", Vector3(12, 0, -15), 5))
	r.add_child(sacco(Vector3(-0.55, 0, 0.3), 0.4))
	r.add_child(sacco(Vector3(-0.6, 0, 0.42), -0.2))
	r.add_child(pino_laricio(41))
	r.get_child(r.get_child_count() - 1).position = Vector3(0.55, 0, -0.55)
	r.get_child(r.get_child_count() - 1).scale = Vector3.ONE * 0.7
	return r


static func torre() -> Node3D:
	var r := Node3D.new()
	var lato := 0.55
	var h := 1.25
	r.add_child(scatola(Vector3(lato + 0.16, 0.08, lato + 0.16), Vector3(0, 0.04, 0), "pietra"))
	r.add_child(scatola(Vector3(lato + 0.06, 0.18, lato + 0.06), Vector3(0, 0.17, 0), "pietra_vista"))
	r.add_child(scatola(Vector3(lato, h, lato), Vector3(0, 0.08 + h * 0.5, 0), "pietra_vista"))
	for y in [0.45, 0.85]:
		r.add_child(scatola(Vector3(lato + 0.03, 0.03, lato + 0.03), Vector3(0, y, 0), "blocco"))
	for y in [0.62, 1.02]:
		r.add_child(scatola(Vector3(0.035, 0.11, 0.02), Vector3(0, y, lato * 0.5 + 0.005), "buio"))
		r.add_child(scatola(Vector3(0.02, 0.11, 0.035), Vector3(lato * 0.5 + 0.005, y, 0), "buio"))
	porta_z(r, -0.08, lato * 0.5 + 0.01, 0.14, 0.24)
	r.get_child(r.get_child_count() - 1).position.y += 0.06
	# ballatoio sporgente su mensole e merli
	var top := 0.08 + h
	for k in 5:
		var off := -lato * 0.5 + k * lato / 4
		r.add_child(scatola(Vector3(0.04, 0.06, 0.05), Vector3(off, top - 0.03, lato * 0.5 + 0.03), "blocco"))
		r.add_child(scatola(Vector3(0.05, 0.06, 0.04), Vector3(lato * 0.5 + 0.03, top - 0.03, off), "blocco"))
	r.add_child(scatola(Vector3(lato + 0.14, 0.05, lato + 0.14), Vector3(0, top + 0.025, 0), "blocco"))
	for k in 5:
		for lm in [-1, 1]:
			var off := -lato * 0.5 - 0.02 + k * (lato + 0.04) / 4
			r.add_child(scatola(Vector3(0.07, 0.09, 0.05), Vector3(off, top + 0.095, lm * (lato * 0.5 + 0.045)), "pietra_vista"))
			r.add_child(scatola(Vector3(0.05, 0.09, 0.07), Vector3(lm * (lato * 0.5 + 0.045), top + 0.095, off), "pietra_vista"))
	r.add_child(cilindro(0.012, 0.012, 0.5, Vector3(0, top + 0.3, 0), "legno", Vector3.ZERO, 6))
	r.add_child(scatola(Vector3(0.006, 0.16, 0.26), Vector3(0, top + 0.46, 0.13), "stoffa"))
	# scudi, lance e barili alla base
	r.add_child(barile(Vector3(lato * 0.5 + 0.15, 0.0, 0.2), 1.1))
	r.add_child(cassa(Vector3(lato * 0.5 + 0.17, 0.0, 0.0), 10))
	for k in 3:
		r.add_child(cilindro(0.005, 0.005, 0.32, Vector3(-0.22 + k * 0.04, 0.16, lato * 0.5 + 0.08), "legno", Vector3(-12, 0, 0), 5))
	return r


static func pozzo() -> Node3D:
	var r := Node3D.new()
	r.add_child(cilindro(0.2, 0.21, 0.18, Vector3(0, 0.09, 0), "pietra_vista", Vector3.ZERO, 18))
	r.add_child(cilindro(0.15, 0.15, 0.005, Vector3(0, 0.17, 0), "acqua_pozzo", Vector3.ZERO, 18))
	r.add_child(cilindro(0.215, 0.215, 0.03, Vector3(0, 0.19, 0), "blocco", Vector3.ZERO, 18))
	for lato in [-1, 1]:
		r.add_child(scatola(Vector3(0.035, 0.34, 0.035), Vector3(lato * 0.19, 0.34, 0), "legno_vecchio"))
	r.add_child(cilindro(0.025, 0.025, 0.42, Vector3(0, 0.43, 0), "legno", Vector3(0, 0, 90), 8))
	r.add_child(cilindro(0.004, 0.004, 0.18, Vector3(0.02, 0.33, 0), "corda", Vector3.ZERO, 4))
	r.add_child(cilindro(0.04, 0.034, 0.06, Vector3(0.02, 0.22, 0), "legno_scuro", Vector3.ZERO, 8))
	var t := Node3D.new()
	r.add_child(t)
	tetto(t, 0.46, 0.26, 0.5, 30.0, 23)
	r.add_child(anfora(Vector3(0.26, 0.0, 0.18), 1.1))
	r.add_child(scatola(Vector3(0.16, 0.05, 0.06), Vector3(-0.2, 0.025, 0.24), "legno_vecchio", Vector3(0, 30, 0)))
	r.scale = Vector3.ONE * 1.2
	return r



# =================================================================== MESTIERI (step 05)

## Lavoratore con l'attrezzo in mano destra: ascia (boscaiolo), piccone (cavapietre), pala (guardaboschi),
## falce (contadino), canna (pescatore).
static func lavoratore(attrezzo: String) -> Node3D:
	var r := portatore("")
	var corpo: Node3D = r.get_node("corpo")
	var bd: Node3D = corpo.get_node("braccio_d")
	var att := Node3D.new()
	att.name = "attrezzo"
	att.position = Vector3(0, -0.14, 0.0)
	bd.add_child(att)
	match attrezzo:
		"ascia":
			att.add_child(cilindro(0.009, 0.009, 0.24, Vector3(0, 0.0, 0.08), "legno", Vector3(90, 0, 0), 6))
			att.add_child(scatola(Vector3(0.012, 0.07, 0.05), Vector3(0, -0.02, 0.19), "ferro"))
		"piccone":
			att.add_child(cilindro(0.009, 0.009, 0.24, Vector3(0, 0.0, 0.08), "legno", Vector3(90, 0, 0), 6))
			att.add_child(scatola(Vector3(0.014, 0.16, 0.022), Vector3(0, 0.0, 0.2), "ferro"))
		"pala":
			att.add_child(cilindro(0.008, 0.008, 0.26, Vector3(0, 0.0, 0.09), "legno", Vector3(90, 0, 0), 6))
			att.add_child(scatola(Vector3(0.06, 0.008, 0.07), Vector3(0, 0.0, 0.24), "ferro"))
		"falce":
			# falcetto: manico corto e lama a mezzaluna
			att.add_child(cilindro(0.009, 0.009, 0.1, Vector3(0, 0.0, 0.03), "legno", Vector3(90, 0, 0), 6))
			for k in 5:
				var a := k * 0.35
				att.add_child(scatola(Vector3(0.008, 0.02, 0.04), Vector3(0, 0.05 * sin(a), 0.09 + 0.05 * (1.0 - cos(a)) + k * 0.012), "ferro", Vector3(rad_to_deg(a), 0, 0)))
		"canna":
			att.add_child(cilindro(0.006, 0.003, 0.5, Vector3(0, 0.08, 0.2), "legno_chiaro", Vector3(70, 0, 0), 5))
			att.add_child(cilindro(0.002, 0.002, 0.2, Vector3(0, 0.22, 0.45), "corda", Vector3.ZERO, 3))
	# berretto di lana per riconoscere i mestieri
	corpo.add_child(sfera(0.07, Vector3(0, 0.2 + 0.31, -0.005), {"ascia": "giocatore", "piccone": "terra", "pala": "orto", "falce": "paglia", "canna": "persiana"}[attrezzo], Vector3(1, 0.55, 1)))
	r.set_meta("carico", "attrezzo")
	return r


## Gesto di lavoro: braccio che si alza e cala (ascia e piccone colpiscono in avanti, la pala scava).
static func posa_lavoro(modello: Node3D, fotogramma: int, totale: int) -> void:
	var t := float(fotogramma) / totale
	var corpo: Node3D = modello.get_node("corpo")
	var bd: Node3D = corpo.get_node("braccio_d")
	var bs: Node3D = corpo.get_node("braccio_s")
	# su fino a metà, poi giù veloce
	var alzata := sin(t * PI) if t < 0.65 else sin(0.65 * PI) * (1.0 - (t - 0.65) / 0.35)
	bd.rotation = Vector3(-0.3 - alzata * 2.4, 0, 0.15)
	bs.rotation = Vector3(-0.5 - alzata * 1.6, 0, -0.2)
	corpo.rotation.x = 0.15 - alzata * 0.25
	corpo.position.y = 0.0
	(corpo.get_node("gamba_s") as Node3D).rotation.x = 0.2
	(corpo.get_node("gamba_d") as Node3D).rotation.x = -0.2


static func ceppo() -> Node3D:
	var r := Node3D.new()
	r.add_child(cilindro(0.06, 0.075, 0.06, Vector3(0, 0.03, 0), "corteccia", Vector3.ZERO, 10))
	r.add_child(cilindro(0.056, 0.056, 0.005, Vector3(0, 0.062, 0), "legno_chiaro", Vector3.ZERO, 10))
	for k in 5:
		r.add_child(cilindro(0.01, 0.01, 0.03, Vector3(0.09 * cos(k * 1.3), 0.01, 0.09 * sin(k * 1.3)), "legno_chiaro", Vector3(0, k * 50, 90), 4))
	return r


static func alberello(fase: int) -> Node3D:
	var r := Node3D.new()
	var s: float = [0.28, 0.48, 0.72][fase]
	var albero := pino_laricio(60 + fase)
	albero.scale = Vector3.ONE * s
	r.add_child(albero)
	if fase == 0:
		r.add_child(cilindro(0.004, 0.004, 0.14, Vector3(0.05, 0.07, 0.0), "legno", Vector3.ZERO, 4))
	return r


# =================================================================== CIBO (step 06)

## Covone di grano legato in mezzo (in piedi lungo Y).
static func covone(scala := 1.0) -> Node3D:
	var n := Node3D.new()
	n.scale = Vector3.ONE * scala
	n.add_child(cilindro(0.035, 0.05, 0.2, Vector3(0, 0.1, 0), "grano", Vector3.ZERO, 10))
	n.add_child(cilindro(0.05, 0.03, 0.06, Vector3(0, 0.23, 0), "grano", Vector3.ZERO, 10))
	n.add_child(cilindro(0.038, 0.038, 0.015, Vector3(0, 0.13, 0), "corda", Vector3.ZERO, 10))
	return n


## Cesta di vimini con pani, pesci, formaggi, olive, uva, ortaggi, cipolle o agrumi.
static func cesta(pos: Vector3, contenuto: String, scala := 1.0) -> Node3D:
	var n := Node3D.new()
	n.position = pos
	n.scale = Vector3.ONE * scala
	n.add_child(cilindro(0.08, 0.065, 0.06, Vector3(0, 0.03, 0), "paglia", Vector3.ZERO, 14))
	n.add_child(cilindro(0.083, 0.083, 0.012, Vector3(0, 0.062, 0), "legno_vecchio", Vector3.ZERO, 14))
	if contenuto == "pane":
		for k in 4:
			var a := k * TAU / 4 + 0.4
			n.add_child(sfera(0.035, Vector3(cos(a) * 0.035, 0.07, sin(a) * 0.035), "pane", Vector3(1, 0.6, 1)))
		n.add_child(sfera(0.033, Vector3(0, 0.09, 0), "pane", Vector3(1, 0.6, 1)))
	elif contenuto in ["olive", "uva", "ortaggi", "cipolle", "agrumi", "carbone"]:
		var mat: String = {"olive": "oliva", "uva": "uva", "ortaggi": "orto", "cipolle": "cipolla", "agrumi": "arancia", "carbone": "carbone"}[contenuto]
		var g: float = {"olive": 0.016, "uva": 0.02, "ortaggi": 0.03, "cipolle": 0.025, "agrumi": 0.026, "carbone": 0.025}[contenuto]
		for k in 9:
			var a := k * 2.4
			var rr := 0.02 + (k % 3) * 0.018
			var m2 := mat
			if contenuto == "agrumi" and k % 3 == 0:
				m2 = "bergamotto"
			if contenuto == "ortaggi" and k % 3 == 1:
				m2 = "geranio"
			n.add_child(sfera(g, Vector3(cos(a) * rr, 0.07 + (k % 2) * 0.012, sin(a) * rr), m2))
	elif contenuto == "formaggio":
		for k in 3:
			n.add_child(cilindro(0.033, 0.033, 0.03, Vector3((k - 1) * 0.03, 0.07 + (k % 2) * 0.02, 0), "formaggio", Vector3(0, 0, 10 * (k - 1)), 12))
	else:
		for k in 5:
			var pesce := sfera(0.022, Vector3(-0.04 + k * 0.02, 0.07 + (k % 2) * 0.01, (k % 3 - 1) * 0.025), "pesce", Vector3(3.0, 0.6, 0.8))
			pesce.rotation_degrees.y = k * 37
			n.add_child(pesce)
	return n


## Campo di grano su una casella: 0 seminato, 1 verde basso, 2 verde alto, 3 maturo e dorato.
static func campo(fase: int) -> Node3D:
	var r := Node3D.new()
	var rng := _rng(70 + fase)
	r.add_child(scatola(Vector3(0.92, 0.02, 0.92), Vector3(0, 0.01, 0), "terra"))
	for f in 7:
		r.add_child(scatola(Vector3(0.88, 0.018, 0.04), Vector3(0, 0.022, -0.39 + f * 0.13), "terra"))
	var alt: float = [0.025, 0.07, 0.16, 0.2][fase]
	var mat: String = "grano" if fase == 3 else "grano_verde"
	for f in 7:
		for k in 8:
			var p := Vector3(-0.39 + k * 0.11 + rng.randf_range(-0.02, 0.02), 0, -0.39 + f * 0.13 + rng.randf_range(-0.015, 0.015))
			var h := alt * rng.randf_range(0.8, 1.15)
			if fase == 0:
				r.add_child(sfera(0.012, p + Vector3(0, 0.03, 0), "orto", Vector3(1, 1.5, 1)))
			else:
				r.add_child(sfera(0.05, p + Vector3(0, h * 0.5 + 0.02, 0), mat, Vector3(1, h / 0.1, 1)))
				if fase == 3:
					r.add_child(sfera(0.02, p + Vector3(rng.randf_range(-0.01, 0.01), h + 0.03, 0), "grano", Vector3(0.8, 1.6, 0.8)))
	return r


static func stoppie() -> Node3D:
	var r := Node3D.new()
	var rng := _rng(80)
	r.add_child(scatola(Vector3(0.92, 0.02, 0.92), Vector3(0, 0.01, 0), "terra"))
	for k in 40:
		var p := Vector3(rng.randf_range(-0.42, 0.42), 0.03, rng.randf_range(-0.42, 0.42))
		r.add_child(cilindro(0.01, 0.008, 0.035, p, "paglia", Vector3.ZERO, 4))
	for p in [Vector3(-0.15, 0, 0.1), Vector3(0.18, 0, -0.12)]:
		var cv := covone(1.0)
		cv.position = p
		r.add_child(cv)
	return r


## Asino stilizzato (per la mola del mulino).
static func asino(pos: Vector3, rot := 0.0) -> Node3D:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot
	n.add_child(sfera(0.07, Vector3(0, 0.15, 0), "asino", Vector3(1.6, 0.9, 0.9)))
	for x in [-0.07, 0.07]:
		for z in [-0.035, 0.035]:
			n.add_child(cilindro(0.013, 0.011, 0.11, Vector3(x, 0.055, z), "asino", Vector3.ZERO, 6))
	n.add_child(cilindro(0.025, 0.03, 0.09, Vector3(0.12, 0.2, 0), "asino", Vector3(0, 0, -50), 8))
	n.add_child(sfera(0.035, Vector3(0.17, 0.22, 0), "asino", Vector3(1.4, 0.9, 0.9)))
	for z in [-0.015, 0.015]:
		n.add_child(cilindro(0.008, 0.004, 0.07, Vector3(0.15, 0.28, z), "asino", Vector3(z * 600, 0, 15), 5))
	n.add_child(cilindro(0.006, 0.003, 0.08, Vector3(-0.12, 0.12, 0), "capelli", Vector3(0, 0, 30), 4))
	return n


static func fattoria() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.18, 0, -0.22)
	r.add_child(c)
	var lx := 0.78
	var lz := 0.58
	var h := 0.38
	casa_muri(c, lx, lz, h, 41)
	porta_z(c, -0.12, lz * 0.5, 0.13, 0.23)
	finestra_z(c, 0.2, 0.34, lz * 0.5, 0.1, 0.1, true)
	finestra_x(c, 0.0, 0.34, lx * 0.5)
	sottotetto(c, lx, lz, 0.07 + h, 24.0)
	tetto(c, lx + 0.06, lz, 0.07 + h, 24.0, 41)
	comignolo(c, Vector3(0.22, 0.07 + h + 0.06, -0.08))
	# fienile aperto con tetto di paglia sul lato destro
	for p in [Vector3(0.62, 0, -0.45), Vector3(0.62, 0, 0.05), Vector3(0.95, 0, -0.45), Vector3(0.95, 0, 0.05)]:
		r.add_child(cilindro(0.016, 0.016, 0.34, p + Vector3(0, 0.17, 0), "legno_vecchio", Vector3.ZERO, 6))
	r.add_child(scatola(Vector3(0.42, 0.05, 0.6), Vector3(0.785, 0.36, -0.2), "paglia", Vector3(0, 0, -10)))
	for i in 5:
		var cv := covone(1.1)
		cv.position = Vector3(0.68 + (i % 3) * 0.1, 0.0, -0.35 + (i / 3) * 0.14)
		r.add_child(cv)
	# aia con covoni, carretto di sacchi, orto e galline
	for i in 4:
		var cv := covone(1.2)
		cv.position = Vector3(-0.55 + i * 0.13, 0.0, 0.55 + (i % 2) * 0.08)
		cv.rotation_degrees.z = 8 * (i % 2 * 2 - 1)
		r.add_child(cv)
	carretto(r, Vector3(0.4, 0, 0.55), -20, "sacchi")
	orto(r, Vector3(-0.72, 0, -0.05), 0.24, 0.5, 42)
	for i in 3:
		r.add_child(sfera(0.025, Vector3(0.05 + i * 0.07, 0.03, 0.42 - i * 0.03), "intonaco", Vector3(1.3, 1, 1)))
		r.add_child(sfera(0.008, Vector3(0.08 + i * 0.07, 0.05, 0.42 - i * 0.03), "geranio"))
	return r


static func mulino() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.25)
	r.add_child(c)
	var lx := 0.74
	var lz := 0.56
	var h := 0.46
	casa_muri(c, lx, lz, h, 51, "intonaco_sporco")
	porta_z(c, 0.15, lz * 0.5, 0.14, 0.25)
	finestra_z(c, -0.17, 0.4, lz * 0.5, 0.09, 0.1)
	finestra_x(c, 0.0, 0.4, lx * 0.5)
	sottotetto(c, lx, lz, 0.07 + h, 22.0)
	tetto(c, lx + 0.06, lz, 0.07 + h, 22.0, 51)
	# mola a clessidra sotto una tettoia, girata dall'asino
	var m := Vector3(-0.3, 0, 0.5)
	r.add_child(cilindro(0.2, 0.22, 0.06, m + Vector3(0, 0.03, 0), "pietra", Vector3.ZERO, 20))
	r.add_child(cilindro(0.06, 0.14, 0.16, m + Vector3(0, 0.14, 0), "blocco", Vector3.ZERO, 16))
	r.add_child(cilindro(0.14, 0.06, 0.16, m + Vector3(0, 0.3, 0), "blocco", Vector3.ZERO, 16))
	r.add_child(scatola(Vector3(0.5, 0.025, 0.025), m + Vector3(0.16, 0.25, 0), "legno_vecchio"))
	r.add_child(sfera(0.12, m + Vector3(0, 0.07, 0), "lino", Vector3(1.6, 0.2, 1.6)))
	r.add_child(asino(m + Vector3(0.38, 0, 0.0), 90))
	for p in [m + Vector3(-0.25, 0, -0.22), m + Vector3(-0.25, 0, 0.25), m + Vector3(0.25, 0, 0.25)]:
		r.add_child(cilindro(0.015, 0.015, 0.42, p + Vector3(0, 0.21, 0), "legno_vecchio", Vector3.ZERO, 6))
	r.add_child(scatola(Vector3(0.56, 0.03, 0.52), m + Vector3(0, 0.43, 0), "tegola_scura", Vector3(0, 0, 8)))
	# sacchi di farina e di grano
	for i in 5:
		r.add_child(sacco(Vector3(0.45 + (i % 3) * 0.12, 0.0, -0.1 + (i / 3) * 0.13), i * 0.7))
	var cv := covone(1.1)
	cv.position = Vector3(0.55, 0, 0.45)
	r.add_child(cv)
	r.add_child(cassa(Vector3(0.3, 0, 0.6), 15))
	return r


static func forno() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.25)
	r.add_child(c)
	var lx := 0.74
	var lz := 0.56
	var h := 0.4
	casa_muri(c, lx, lz, h, 61)
	porta_z(c, -0.15, lz * 0.5, 0.13, 0.24)
	finestra_z(c, 0.18, 0.36, lz * 0.5, 0.11, 0.1, true)
	finestra_x(c, 0.0, 0.36, lx * 0.5)
	sottotetto(c, lx, lz, 0.07 + h, 22.0)
	tetto(c, lx + 0.06, lz, 0.07 + h, 22.0, 61)
	comignolo(c, Vector3(-0.2, 0.07 + h + 0.05, -0.08))
	# grande forno a cupola davanti, con bocca annerita e canna fumaria
	var f := Vector3(0.45, 0, 0.42)
	r.add_child(cilindro(0.26, 0.27, 0.12, f + Vector3(0, 0.06, 0), "pietra", Vector3.ZERO, 22))
	r.add_child(sfera(0.24, f + Vector3(0, 0.12, 0), "intonaco_sporco", Vector3(1, 0.85, 1)))
	r.add_child(scatola(Vector3(0.1, 0.09, 0.06), f + Vector3(-0.06, 0.18, 0.21), "fuliggine", Vector3(0, 30, 0)))
	r.add_child(scatola(Vector3(0.11, 0.1, 0.03), f + Vector3(-0.065, 0.18, 0.235), "buio", Vector3(0, 30, 0)))
	r.add_child(cilindro(0.035, 0.035, 0.14, f + Vector3(0.08, 0.36, -0.08), "terracotta", Vector3.ZERO, 8))
	legnaia(r, Vector3(0.62, 0, -0.1), 0.25, 3)
	# tavolo con pani, ceste, sacchi di farina, anfore d'acqua
	r.add_child(scatola(Vector3(0.3, 0.02, 0.14), Vector3(-0.3, 0.12, 0.55), "legno"))
	for lato in [-1, 1]:
		r.add_child(scatola(Vector3(0.02, 0.11, 0.1), Vector3(-0.3 + lato * 0.12, 0.055, 0.55), "legno_vecchio"))
	for i in 5:
		r.add_child(sfera(0.03, Vector3(-0.42 + i * 0.06, 0.145, 0.55 + (i % 2) * 0.03), "pane", Vector3(1, 0.6, 1)))
	r.add_child(cesta(Vector3(-0.62, 0, 0.45), "pane"))
	r.add_child(cesta(Vector3(0.05, 0, 0.62), "pane"))
	r.add_child(sacco(Vector3(-0.68, 0, 0.15), 0.4))
	r.add_child(anfora(Vector3(0.18, 0, 0.42), 1.1))
	r.add_child(anfora(Vector3(0.25, 0, 0.5), 1.0))
	return r


static func capanna_pescatore() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.22, 0, -0.25)
	r.add_child(c)
	var lx := 0.66
	var lz := 0.5
	var h := 0.32
	c.add_child(scatola(Vector3(lx + 0.06, 0.06, lz + 0.06), Vector3(0, 0.03, 0), "pietra"))
	c.add_child(scatola(Vector3(lx, h, lz), Vector3(0, 0.06 + h * 0.5, 0), "legno_vecchio"))
	for k in 7:
		c.add_child(scatola(Vector3(lx + 0.01, 0.008, 0.01), Vector3(0, 0.1 + k * 0.04, lz * 0.5 + 0.004), "legno_scuro"))
	porta_z(c, 0.12, lz * 0.5 + 0.01, 0.12, 0.21)
	finestra_z(c, -0.16, 0.28, lz * 0.5 + 0.01, 0.08, 0.08)
	sottotetto(c, lx, lz, 0.06 + h, 30.0, "legno")
	tetto_scandole(c, lx + 0.08, lz, 0.06 + h, 30.0)
	# reti stese ad asciugare su pali
	for x in [0.35, 0.75]:
		r.add_child(cilindro(0.012, 0.012, 0.36, Vector3(x, 0.18, -0.35), "legno_vecchio", Vector3.ZERO, 6))
	r.add_child(scatola(Vector3(0.4, 0.26, 0.006), Vector3(0.55, 0.2, -0.35), "rete"))
	for k in 6:
		r.add_child(scatola(Vector3(0.004, 0.26, 0.008), Vector3(0.37 + k * 0.07, 0.2, -0.345), "corda"))
	for k in 4:
		r.add_child(scatola(Vector3(0.4, 0.004, 0.008), Vector3(0.55, 0.1 + k * 0.065, -0.345), "corda"))
	# barca tirata a secco, remi, ceste di pesce, galleggianti
	var b := Node3D.new()
	b.position = Vector3(0.35, 0, 0.45)
	b.rotation_degrees.y = -25
	r.add_child(b)
	b.add_child(sfera(0.13, Vector3(0, 0.07, 0), "legno", Vector3(2.6, 0.7, 1.0)))
	b.add_child(sfera(0.115, Vector3(0, 0.1, 0), "legno_scuro", Vector3(2.5, 0.35, 0.9)))
	b.add_child(scatola(Vector3(0.66, 0.02, 0.03), Vector3(0, 0.13, 0.12), "persiana"))
	b.add_child(scatola(Vector3(0.66, 0.02, 0.03), Vector3(0, 0.13, -0.12), "persiana"))
	for z in [-0.05, 0.06]:
		b.add_child(scatola(Vector3(0.5, 0.01, 0.025), Vector3(0.05, 0.16, z), "legno_chiaro", Vector3(0, 8, 4)))
	r.add_child(cesta(Vector3(-0.45, 0, 0.45), "pesce"))
	r.add_child(cesta(Vector3(-0.3, 0, 0.58), "pesce"))
	r.add_child(barile(Vector3(-0.62, 0, 0.25)))
	for i in 3:
		r.add_child(sfera(0.02, Vector3(0.62 + i * 0.05, 0.02, 0.1 + i * 0.03), "bandiera_rossa"))
	return r


## Gesto del pescatore: canna tesa in avanti che oscilla piano.
static func posa_pesca(modello: Node3D, fotogramma: int, totale: int) -> void:
	var t := float(fotogramma) / totale * TAU
	var corpo: Node3D = modello.get_node("corpo")
	var bd: Node3D = corpo.get_node("braccio_d")
	var bs: Node3D = corpo.get_node("braccio_s")
	bd.rotation = Vector3(-1.1 - 0.12 * sin(t), 0, 0.1)
	bs.rotation = Vector3(-0.9 - 0.08 * sin(t), 0, -0.3)
	corpo.rotation.x = 0.05
	corpo.position.y = 0.0
	(corpo.get_node("gamba_s") as Node3D).rotation.x = 0.15
	(corpo.get_node("gamba_d") as Node3D).rotation.x = -0.15


# =================================================================== ALLEVAMENTI (step 06)

## Quadrupede generico: corpo, zampe, collo e testa. Serve per maiali, pecore e capre.
static func quadrupede(pos: Vector3, rot: float, mat: String, scala: float, mat_testa := "", corna := false) -> Node3D:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot
	n.scale = Vector3.ONE * scala
	var testa := mat if mat_testa == "" else mat_testa
	n.add_child(sfera(0.07, Vector3(0, 0.12, 0), mat, Vector3(1.5, 0.95, 0.95)))
	for x in [-0.065, 0.065]:
		for z in [-0.033, 0.033]:
			n.add_child(cilindro(0.012, 0.01, 0.08, Vector3(x, 0.04, z), testa, Vector3.ZERO, 6))
	n.add_child(sfera(0.038, Vector3(0.12, 0.15, 0), testa, Vector3(1.3, 0.95, 0.9)))
	if corna:
		for z in [-0.015, 0.015]:
			n.add_child(cilindro(0.006, 0.002, 0.05, Vector3(0.11, 0.2, z), "legno_scuro", Vector3(0, 0, 35), 4))
	return n


static func maiale(pos: Vector3, rot := 0.0) -> Node3D:
	var n := quadrupede(pos, rot, "maiale", 0.9)
	n.add_child(cilindro(0.018, 0.02, 0.02, Vector3(0.17, 0.145, 0), "maiale", Vector3(0, 0, 90), 8))
	for z in [-0.02, 0.02]:
		n.add_child(sfera(0.014, Vector3(0.12, 0.185, z), "maiale", Vector3(1, 0.6, 1)))
	return n


static func pecora(pos: Vector3, rot := 0.0) -> Node3D:
	var n := quadrupede(pos, rot, "lana", 0.95, "pelle_scura")
	for k in 4:
		n.add_child(sfera(0.04, Vector3(-0.05 + k * 0.035, 0.17, (k % 2) * 0.02 - 0.01), "lana"))
	return n


static func capra(pos: Vector3, rot := 0.0) -> Node3D:
	var n := quadrupede(pos, rot, "capra", 0.85, "", true)
	n.add_child(cilindro(0.006, 0.003, 0.03, Vector3(0.14, 0.11, 0), "capra", Vector3.ZERO, 4))
	return n


static func porcile() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.3, 0, -0.3)
	r.add_child(c)
	var lx := 0.6
	var lz := 0.46
	var h := 0.3
	casa_muri(c, lx, lz, h, 71, "intonaco_sporco")
	porta_z(c, -0.1, lz * 0.5, 0.12, 0.2)
	finestra_x(c, 0.0, 0.28, lx * 0.5, 0.08, 0.08)
	sottotetto(c, lx, lz, 0.07 + h, 22.0)
	tetto(c, lx + 0.06, lz, 0.07 + h, 22.0, 71)
	# recinto con fango, mangiatoia e maiali
	var a := Vector3(0.05, 0, 0.0)
	r.add_child(scatola(Vector3(0.8, 0.012, 0.75), a + Vector3(0.12, 0.006, 0.12), "terra"))
	recinto(r, a + Vector3(-0.28, 0, 0.5), a + Vector3(0.52, 0, 0.5))
	recinto(r, a + Vector3(0.52, 0, -0.26), a + Vector3(0.52, 0, 0.5))
	recinto(r, a + Vector3(0.15, 0, -0.26), a + Vector3(0.52, 0, -0.26))
	r.add_child(sfera(0.14, a + Vector3(0.28, 0.0, 0.05), "fuliggine", Vector3(1.4, 0.1, 1.0)))
	r.add_child(scatola(Vector3(0.24, 0.05, 0.07), a + Vector3(0.0, 0.025, 0.4), "legno_vecchio"))
	r.add_child(scatola(Vector3(0.2, 0.012, 0.05), a + Vector3(0.0, 0.05, 0.4), "grano"))
	for p in [[Vector3(0.25, 0, 0.3), 20], [Vector3(0.38, 0, -0.05), 130], [Vector3(0.05, 0, 0.18), -60], [Vector3(0.4, 0, 0.32), 200]]:
		r.add_child(maiale(a + p[0], p[1]))
	r.add_child(sacco(Vector3(-0.62, 0, 0.2), 0.3))
	r.add_child(anfora(Vector3(-0.5, 0, 0.3), 1.0))
	return r


static func ovile() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.32, 0, -0.32)
	r.add_child(c)
	var lx := 0.62
	var lz := 0.48
	var h := 0.3
	casa_muri(c, lx, lz, h, 81, "pietra_vista")
	porta_z(c, 0.1, lz * 0.5, 0.14, 0.2)
	sottotetto(c, lx, lz, 0.07 + h, 28.0, "legno")
	tetto_scandole(c, lx + 0.06, lz, 0.07 + h, 28.0)
	# stazzo in pietra a secco con le pecore
	var a := Vector3(0.1, 0, 0.1)
	for k in 9:
		r.add_child(scatola(Vector3(0.1, 0.07, 0.06), a + Vector3(-0.32 + k * 0.095, 0.035, 0.45), "pietra", Vector3(0, (k % 3) * 7, 0)))
	for k in 7:
		r.add_child(scatola(Vector3(0.06, 0.07, 0.1), a + Vector3(0.48, 0.035, -0.2 + k * 0.095), "pietra", Vector3(0, (k % 3) * 7, 0)))
	for p in [[Vector3(0.0, 0, 0.25), 30], [Vector3(0.2, 0, 0.05), 160], [Vector3(0.3, 0, 0.3), -40],
			[Vector3(-0.15, 0, 0.32), 90], [Vector3(0.32, 0, -0.12), 210]]:
		r.add_child(pecora(a + p[0], p[1]))
	r.add_child(scatola(Vector3(0.22, 0.04, 0.06), a + Vector3(-0.2, 0.02, 0.05), "legno_vecchio"))
	r.add_child(cilindro(0.09, 0.08, 0.06, Vector3(-0.68, 0.03, 0.3), "legno", Vector3.ZERO, 14))
	r.add_child(cilindro(0.08, 0.08, 0.005, Vector3(-0.68, 0.06, 0.3), "acqua_pozzo", Vector3.ZERO, 14))
	r.add_child(sfera(0.06, Vector3(-0.55, 0.04, 0.55), "lana", Vector3(1.2, 0.6, 1.0)))
	return r


static func capraio() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.3, 0, -0.3)
	r.add_child(c)
	var lx := 0.56
	var lz := 0.44
	var h := 0.28
	c.add_child(scatola(Vector3(lx + 0.06, 0.06, lz + 0.06), Vector3(0, 0.03, 0), "pietra"))
	c.add_child(scatola(Vector3(lx, h, lz), Vector3(0, 0.06 + h * 0.5, 0), "pietra_vista"))
	porta_z(c, -0.08, lz * 0.5, 0.12, 0.19)
	sottotetto(c, lx, lz, 0.06 + h, 30.0, "legno")
	tetto_scandole(c, lx + 0.06, lz, 0.06 + h, 30.0)
	# rocce su cui le capre si arrampicano
	var a := Vector3(0.15, 0, 0.15)
	r.add_child(sfera(0.16, a + Vector3(0.2, 0.0, -0.1), "roccia_massi", Vector3(1.2, 0.8, 1.0)))
	r.add_child(sfera(0.1, a + Vector3(-0.05, 0.0, 0.3), "roccia_massi", Vector3(1.3, 0.7, 1.0)))
	r.add_child(capra(a + Vector3(0.2, 0.1, -0.1), 40))
	r.add_child(capra(a + Vector3(0.0, 0, 0.1), 200))
	r.add_child(capra(a + Vector3(0.35, 0, 0.25), -30))
	r.add_child(capra(a + Vector3(-0.1, 0.05, 0.3), 110))
	recinto(r, a + Vector3(-0.4, 0, 0.5), a + Vector3(0.5, 0, 0.5))
	r.add_child(anfora(Vector3(-0.6, 0, 0.25), 1.1))
	r.add_child(cesta(Vector3(-0.55, 0, 0.45), "formaggio"))
	return r


static func apiario() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.35, 0, -0.35)
	r.add_child(c)
	var lx := 0.5
	var lz := 0.4
	var h := 0.26
	casa_muri(c, lx, lz, h, 91)
	porta_z(c, 0.06, lz * 0.5, 0.11, 0.18)
	sottotetto(c, lx, lz, 0.07 + h, 25.0)
	tetto(c, lx + 0.06, lz, 0.07 + h, 25.0, 91)
	# file di arnie di paglia (bugni) su un'asse, fiori tutto intorno
	for f in 2:
		r.add_child(scatola(Vector3(0.75, 0.02, 0.1), Vector3(0.15, 0.06, 0.15 + f * 0.25), "legno_vecchio"))
		for k in 5:
			var p := Vector3(-0.15 + k * 0.15, 0.07, 0.15 + f * 0.25)
			r.add_child(cilindro(0.045, 0.05, 0.05, p + Vector3(0, 0.025, 0), "paglia", Vector3.ZERO, 12))
			r.add_child(sfera(0.045, p + Vector3(0, 0.05, 0), "paglia", Vector3(1, 0.9, 1)))
			r.add_child(scatola(Vector3(0.015, 0.012, 0.01), p + Vector3(0, 0.02, 0.048), "buio"))
	var rng := _rng(92)
	for k in 30:
		var p := Vector3(rng.randf_range(-0.7, 0.7), 0.0, rng.randf_range(0.55, 0.75))
		if k % 2 == 0:
			p = Vector3(rng.randf_range(0.5, 0.75), 0.0, rng.randf_range(-0.6, 0.6))
		r.add_child(sfera(0.018, p + Vector3(0, 0.02, 0), "orto"))
		r.add_child(sfera(0.012, p + Vector3(0, 0.04, 0), ["geranio", "fiore", "miele"][k % 3]))
	r.add_child(anfora(Vector3(-0.62, 0, 0.2), 0.9))
	r.add_child(anfora(Vector3(-0.55, 0, 0.3), 0.8))
	return r


static func macelleria() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.25)
	r.add_child(c)
	var lx := 0.74
	var lz := 0.56
	var h := 0.4
	casa_muri(c, lx, lz, h, 101)
	porta_z(c, 0.16, lz * 0.5, 0.13, 0.24)
	finestra_z(c, -0.17, 0.35, lz * 0.5, 0.1, 0.1)
	finestra_x(c, 0.0, 0.35, lx * 0.5)
	sottotetto(c, lx, lz, 0.07 + h, 22.0)
	tetto(c, lx + 0.06, lz, 0.07 + h, 22.0, 101)
	comignolo(c, Vector3(0.2, 0.07 + h + 0.05, -0.1))
	# tettoia con prosciutti e salami appesi, banco, ceppo
	for x in [0.2, 0.7]:
		r.add_child(cilindro(0.014, 0.014, 0.36, Vector3(x, 0.18, 0.5), "legno_vecchio", Vector3.ZERO, 6))
	r.add_child(scatola(Vector3(0.6, 0.02, 0.02), Vector3(0.45, 0.34, 0.5), "legno"))
	r.add_child(scatola(Vector3(0.62, 0.025, 0.3), Vector3(0.45, 0.38, 0.42), "tegola_scura", Vector3(-12, 0, 0)))
	for k in 5:
		var x := 0.25 + k * 0.1
		r.add_child(cilindro(0.003, 0.003, 0.05, Vector3(x, 0.31, 0.5), "corda", Vector3.ZERO, 3))
		if k % 2 == 0:
			r.add_child(sfera(0.035, Vector3(x, 0.25, 0.5), "carne", Vector3(0.9, 1.4, 0.8)))
		else:
			r.add_child(cilindro(0.016, 0.016, 0.1, Vector3(x, 0.24, 0.5), "carne", Vector3.ZERO, 8))
	r.add_child(scatola(Vector3(0.3, 0.02, 0.14), Vector3(-0.35, 0.12, 0.55), "legno"))
	for lato in [-1, 1]:
		r.add_child(scatola(Vector3(0.02, 0.11, 0.1), Vector3(-0.35 + lato * 0.12, 0.055, 0.55), "legno_vecchio"))
	r.add_child(sfera(0.04, Vector3(-0.4, 0.15, 0.55), "carne", Vector3(1.2, 0.5, 0.9)))
	r.add_child(cilindro(0.07, 0.075, 0.1, Vector3(-0.65, 0.05, 0.4), "corteccia", Vector3.ZERO, 12))
	r.add_child(barile(Vector3(0.65, 0, 0.0), 1.1))
	r.add_child(maiale(Vector3(-0.6, 0, 0.0), 60))
	return r


static func caseificio() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.25)
	r.add_child(c)
	var lx := 0.74
	var lz := 0.56
	var h := 0.4
	casa_muri(c, lx, lz, h, 111)
	porta_z(c, -0.15, lz * 0.5, 0.13, 0.24)
	finestra_z(c, 0.18, 0.35, lz * 0.5, 0.1, 0.1, true)
	finestra_x(c, 0.0, 0.35, lx * 0.5)
	sottotetto(c, lx, lz, 0.07 + h, 22.0)
	tetto(c, lx + 0.06, lz, 0.07 + h, 22.0, 111)
	comignolo(c, Vector3(-0.2, 0.07 + h + 0.05, -0.1))
	# paiolo sul fuoco, scaffale di forme di formaggio, secchi di latte
	var f := Vector3(0.45, 0, 0.45)
	for k in 6:
		r.add_child(scatola(Vector3(0.07, 0.05, 0.05), f + Vector3(0.12 * cos(k), 0.025, 0.12 * sin(k)), "pietra", Vector3(0, k * 50, 0)))
	r.add_child(sfera(0.1, f + Vector3(0, 0.12, 0), "ferro", Vector3(1, 0.8, 1)))
	r.add_child(cilindro(0.085, 0.085, 0.01, f + Vector3(0, 0.17, 0), "latte", Vector3.ZERO, 14))
	for lato in [-1, 1]:
		r.add_child(cilindro(0.01, 0.01, 0.3, f + Vector3(lato * 0.15, 0.15, 0), "legno_vecchio", Vector3.ZERO, 5))
	r.add_child(cilindro(0.008, 0.008, 0.32, f + Vector3(0, 0.3, 0), "legno_vecchio", Vector3(0, 0, 90), 5))
	for p in [Vector3(-0.3, 0, 0.5), Vector3(0.7, 0, -0.05)]:
		for liv in 3:
			r.add_child(scatola(Vector3(0.28 if p.x < 0 else 0.08, 0.012, 0.08 if p.x < 0 else 0.28), p + Vector3(0, 0.05 + liv * 0.08, 0), "legno"))
			for k in 3:
				var o := Vector3((k - 1) * 0.085, 0, 0) if p.x < 0 else Vector3(0, 0, (k - 1) * 0.085)
				r.add_child(cilindro(0.035, 0.035, 0.04, p + o + Vector3(0, 0.078 + liv * 0.08, 0), "formaggio", Vector3.ZERO, 12))
	r.add_child(anfora(Vector3(0.1, 0, 0.62), 1.0))
	r.add_child(anfora(Vector3(0.2, 0, 0.6), 1.1))
	return r


# =================================================================== COLTURE E PESCA AL LARGO (step 06)

## Filare di viti su una casella: 0 piantine, 1 tralci, 2 foglie fitte, 3 grappoli maturi.
static func vite(fase: int) -> Node3D:
	var r := Node3D.new()
	var rng := _rng(120 + fase)
	r.add_child(scatola(Vector3(0.92, 0.02, 0.92), Vector3(0, 0.01, 0), "terra"))
	for f in 3:
		var z := -0.3 + f * 0.3
		if fase > 0:
			for x in [-0.4, 0.0, 0.4]:
				r.add_child(cilindro(0.008, 0.008, 0.2, Vector3(x, 0.1, z), "legno_vecchio", Vector3.ZERO, 5))
			r.add_child(cilindro(0.002, 0.002, 0.8, Vector3(0, 0.17, z), "corda", Vector3(0, 0, 90), 3))
		for k in 5:
			var p := Vector3(-0.36 + k * 0.18, 0, z)
			r.add_child(cilindro(0.01, 0.014, 0.06 + fase * 0.03, p + Vector3(0, 0.03 + fase * 0.015, 0), "corteccia", Vector3.ZERO, 5))
			if fase == 0:
				r.add_child(sfera(0.02, p + Vector3(0, 0.07, 0), "orto"))
				continue
			var n := 2 + fase * 2
			for i in n:
				var o := Vector3(rng.randf_range(-0.08, 0.08), 0.1 + rng.randf_range(0, 0.08), rng.randf_range(-0.04, 0.04))
				r.add_child(sfera(0.03, p + o, "foglie_chiare" if i % 2 == 0 else "foglie", Vector3(1, 0.7, 1)))
			if fase == 3:
				for i in 2:
					r.add_child(sfera(0.022, p + Vector3(-0.03 + i * 0.06, 0.1, 0.03), "uva", Vector3(1, 1.4, 1)))
	return r


## Orto su una casella: 0 seminato, 1 piantine, 2 cespi, 3 maturo (cavoli, cipolle rosse, peperoni).
static func orto_campo(fase: int) -> Node3D:
	var r := Node3D.new()
	var rng := _rng(130 + fase)
	r.add_child(scatola(Vector3(0.92, 0.02, 0.92), Vector3(0, 0.01, 0), "terra"))
	for f in 5:
		r.add_child(scatola(Vector3(0.84, 0.03, 0.1), Vector3(0, 0.025, -0.34 + f * 0.17), "terra"))
	for f in 5:
		for k in 6:
			var p := Vector3(-0.35 + k * 0.14 + rng.randf_range(-0.01, 0.01), 0.04, -0.34 + f * 0.17)
			match fase:
				0:
					r.add_child(sfera(0.008, p, "orto"))
				1:
					r.add_child(sfera(0.02, p + Vector3(0, 0.01, 0), "orto", Vector3(1, 0.8, 1)))
				_:
					var g := 0.035 if fase == 2 else 0.045
					if f % 2 == 0:
						r.add_child(sfera(g, p + Vector3(0, g * 0.6, 0), "orto" if f == 0 else "foglie_chiare", Vector3(1, 0.8, 1)))
					else:
						if fase == 3:
							r.add_child(sfera(0.026, p + Vector3(0, 0.02, 0), "cipolla", Vector3(1, 0.9, 1)))
						for i in 3:
							r.add_child(cilindro(0.004, 0.002, 0.08, p + Vector3((i - 1) * 0.01, 0.06, 0), "orto", Vector3(0, 0, (i - 1) * 15), 3))
					if fase == 3 and f == 4 and k % 2 == 0:
						r.add_child(sfera(0.018, p + Vector3(0.02, 0.05, 0.02), "geranio", Vector3(0.8, 1.4, 0.8)))
	return r


## Alberello di agrumi: 0 piantina, 1 giovane, 2 chioma, 3 carico di frutti.
static func agrumi(fase: int) -> Node3D:
	var r := Node3D.new()
	var rng := _rng(140)
	r.add_child(scatola(Vector3(0.92, 0.02, 0.92), Vector3(0, 0.01, 0), "terra"))
	var s: float = [0.3, 0.55, 0.85, 0.85][fase]
	for p in [Vector3(-0.2, 0, -0.2), Vector3(0.22, 0, 0.18)]:
		var a := Node3D.new()
		a.position = p
		a.scale = Vector3.ONE * s
		r.add_child(a)
		a.add_child(cilindro(0.02, 0.028, 0.22, Vector3(0, 0.11, 0), "corteccia", Vector3.ZERO, 6))
		chioma(a, Vector3(0, 0.3, 0), Vector3(0.16, 0.13, 0.16), 26, 141 + int(p.x * 10), "foglie_scure", "foglie", "foglie_chiare")
		if fase == 3:
			for k in 14:
				var d := Vector3(rng.randf_range(-1, 1), rng.randf_range(-0.6, 0.8), rng.randf_range(-1, 1)).normalized()
				a.add_child(sfera(0.025, Vector3(0, 0.3, 0) + d * Vector3(0.16, 0.13, 0.16), "arancia" if k % 4 else "bergamotto"))
	return r


static func uliveto() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.3, 0, -0.3)
	r.add_child(c)
	var lx := 0.58
	var lz := 0.46
	var h := 0.3
	casa_muri(c, lx, lz, h, 151)
	porta_z(c, -0.08, lz * 0.5, 0.12, 0.21)
	finestra_x(c, 0.0, 0.3, lx * 0.5, 0.08, 0.08)
	sottotetto(c, lx, lz, 0.07 + h, 24.0)
	tetto(c, lx + 0.06, lz, 0.07 + h, 24.0, 151)
	# teli stesi sotto un ulivo, ceste di olive, scala a pioli
	var u := ulivo(152)
	u.position = Vector3(0.35, 0, 0.3)
	u.scale = Vector3.ONE * 0.8
	r.add_child(u)
	r.add_child(scatola(Vector3(0.5, 0.004, 0.45), Vector3(0.35, 0.004, 0.3), "lino", Vector3(0, 12, 0)))
	for k in 12:
		r.add_child(sfera(0.012, Vector3(0.2 + (k % 4) * 0.08, 0.012, 0.18 + (k / 4) * 0.1), "oliva"))
	for p in [Vector3(-0.45, 0, 0.45), Vector3(-0.25, 0, 0.55), Vector3(0.7, 0, -0.2)]:
		r.add_child(cesta(p, "olive"))
	r.add_child(scatola(Vector3(0.03, 0.45, 0.012), Vector3(0.12, 0.22, 0.12), "legno_vecchio", Vector3(0, 0, -18)))
	r.add_child(scatola(Vector3(0.03, 0.45, 0.012), Vector3(0.12, 0.22, 0.2), "legno_vecchio", Vector3(0, 0, -18)))
	return r


static func vigneto() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.25, 0, -0.3)
	r.add_child(c)
	var lx := 0.66
	var lz := 0.5
	var h := 0.34
	casa_muri(c, lx, lz, h, 161)
	porta_z(c, 0.1, lz * 0.5, 0.13, 0.22)
	finestra_z(c, -0.18, 0.32, lz * 0.5, 0.09, 0.09, true)
	sottotetto(c, lx, lz, 0.07 + h, 24.0)
	tetto(c, lx + 0.06, lz, 0.07 + h, 24.0, 161)
	# pergolato d'uva davanti alla porta, tino, ceste di grappoli
	for p in [Vector3(-0.35, 0, 0.15), Vector3(0.25, 0, 0.15), Vector3(-0.35, 0, 0.55), Vector3(0.25, 0, 0.55)]:
		r.add_child(cilindro(0.012, 0.012, 0.36, p + Vector3(0, 0.18, 0), "legno_vecchio", Vector3.ZERO, 6))
	var rng := _rng(162)
	for k in 26:
		r.add_child(sfera(0.045, Vector3(rng.randf_range(-0.38, 0.28), 0.37, rng.randf_range(0.12, 0.58)), "foglie" if k % 3 else "foglie_chiare", Vector3(1, 0.5, 1)))
	for k in 6:
		r.add_child(sfera(0.022, Vector3(-0.3 + k * 0.1, 0.32, 0.35 + (k % 2) * 0.1), "uva", Vector3(1, 1.5, 1)))
	r.add_child(cilindro(0.1, 0.09, 0.12, Vector3(0.55, 0.06, 0.4), "legno", Vector3.ZERO, 14))
	r.add_child(cilindro(0.09, 0.09, 0.005, Vector3(0.55, 0.12, 0.4), "uva", Vector3.ZERO, 14))
	r.add_child(cesta(Vector3(0.6, 0, 0.0), "uva"))
	r.add_child(cesta(Vector3(0.45, 0, -0.2), "uva"))
	return r


static func cantina() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.25)
	r.add_child(c)
	var lx := 0.76
	var lz := 0.56
	var h := 0.38
	casa_muri(c, lx, lz, h, 171, "pietra_vista")
	porta_z(c, 0.15, lz * 0.5, 0.16, 0.24)
	finestra_z(c, -0.2, 0.34, lz * 0.5, 0.08, 0.08)
	sottotetto(c, lx, lz, 0.07 + h, 20.0)
	tetto(c, lx + 0.06, lz, 0.07 + h, 20.0, 171)
	# botti in fila, anfore di vino, palmento (vasca per pigiare)
	for k in 3:
		var b := barile(Vector3(0.62, 0, -0.3 + k * 0.2), 1.5)
		b.rotation_degrees.x = 90
		b.position.y = 0.07
		r.add_child(b)
	for k in 5:
		r.add_child(anfora(Vector3(-0.6 + (k % 3) * 0.1, 0, 0.42 + (k / 3) * 0.12), 1.15))
	r.add_child(scatola(Vector3(0.36, 0.1, 0.28), Vector3(0.2, 0.05, 0.55), "pietra"))
	r.add_child(scatola(Vector3(0.3, 0.01, 0.22), Vector3(0.2, 0.1, 0.55), "vino"))
	r.add_child(cesta(Vector3(-0.15, 0, 0.6), "uva"))
	return r


static func ortolano() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.3, 0, -0.3)
	r.add_child(c)
	var lx := 0.58
	var lz := 0.46
	var h := 0.3
	casa_muri(c, lx, lz, h, 181)
	porta_z(c, 0.08, lz * 0.5, 0.12, 0.21)
	finestra_z(c, -0.16, 0.3, lz * 0.5, 0.08, 0.08, true)
	sottotetto(c, lx, lz, 0.07 + h, 24.0)
	tetto(c, lx + 0.06, lz, 0.07 + h, 24.0, 181)
	# trecce di cipolle rosse appese, cassette di verdura, orticello
	orto(r, Vector3(0.45, 0, 0.0), 0.36, 0.6, 182)
	for k in 4:
		for i in 4:
			r.add_child(sfera(0.02, Vector3(-0.5 + k * 0.08, 0.3 - i * 0.04, 0.0), "cipolla"))
	for p in [Vector3(-0.4, 0, 0.45), Vector3(-0.2, 0, 0.55)]:
		r.add_child(cesta(p, "ortaggi"))
	r.add_child(cesta(Vector3(0.05, 0, 0.6), "cipolle"))
	return r


static func agrumeto() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.3, 0, -0.3)
	r.add_child(c)
	var lx := 0.6
	var lz := 0.46
	var h := 0.32
	casa_muri(c, lx, lz, h, 191)
	porta_z(c, -0.1, lz * 0.5, 0.12, 0.22)
	finestra_z(c, 0.15, 0.3, lz * 0.5, 0.08, 0.08, true)
	sottotetto(c, lx, lz, 0.07 + h, 24.0)
	tetto(c, lx + 0.06, lz, 0.07 + h, 24.0, 191)
	var a := agrumi(3)
	var terra := a.get_child(0)
	a.remove_child(terra)
	terra.free()
	a.position = Vector3(0.3, 0, 0.25)
	a.scale = Vector3.ONE * 1.1
	r.add_child(a)
	for p in [Vector3(-0.45, 0, 0.45), Vector3(-0.25, 0, 0.58), Vector3(0.7, 0, -0.25)]:
		r.add_child(cesta(p, "agrumi"))
	r.add_child(cassa(Vector3(0.65, 0, 0.1), 20))
	return r


static func pesca_spada() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.3, 0, -0.3)
	r.add_child(c)
	var lx := 0.6
	var lz := 0.46
	var h := 0.32
	casa_muri(c, lx, lz, h, 201)
	porta_z(c, 0.1, lz * 0.5, 0.12, 0.22)
	finestra_x(c, 0.0, 0.3, lx * 0.5, 0.08, 0.08)
	sottotetto(c, lx, lz, 0.07 + h, 24.0)
	tetto(c, lx + 0.06, lz, 0.07 + h, 24.0, 201)
	# la feluca: barca con l'albero di vedetta e la passerella dell'arpioniere
	var b := Node3D.new()
	b.position = Vector3(0.3, 0, 0.35)
	b.rotation_degrees.y = -30
	r.add_child(b)
	b.add_child(sfera(0.15, Vector3(0, 0.07, 0), "legno", Vector3(2.8, 0.7, 1.0)))
	b.add_child(sfera(0.13, Vector3(0, 0.1, 0), "legno_scuro", Vector3(2.7, 0.35, 0.9)))
	b.add_child(scatola(Vector3(0.8, 0.02, 0.03), Vector3(0, 0.14, 0.13), "persiana"))
	b.add_child(scatola(Vector3(0.8, 0.02, 0.03), Vector3(0, 0.14, -0.13), "persiana"))
	b.add_child(cilindro(0.01, 0.008, 0.6, Vector3(0.0, 0.42, 0), "legno_vecchio", Vector3.ZERO, 6))
	for k in 5:
		b.add_child(scatola(Vector3(0.08, 0.006, 0.01), Vector3(0.0, 0.2 + k * 0.08, 0.0), "legno_vecchio"))
	b.add_child(scatola(Vector3(0.45, 0.012, 0.02), Vector3(0.55, 0.13, 0), "legno_chiaro"))
	r.add_child(scatola(Vector3(0.02, 0.012, 0.5), Vector3(-0.6, 0.15, 0.4), "ferro", Vector3(0, 0, 4)))
	var sp := pesce_spada_modello()
	sp.position = Vector3(-0.35, 0.02, 0.55)
	r.add_child(sp)
	return r


static func pesce_spada_modello() -> Node3D:
	var n := Node3D.new()
	n.add_child(sfera(0.05, Vector3(0, 0.04, 0), "spada", Vector3(3.2, 0.8, 0.7)))
	n.add_child(cilindro(0.008, 0.002, 0.2, Vector3(0.25, 0.045, 0), "spada", Vector3(0, 0, 90), 5))
	n.add_child(scatola(Vector3(0.05, 0.06, 0.01), Vector3(0.0, 0.09, 0), "spada", Vector3(0, 0, 30)))
	for lato in [-1, 1]:
		n.add_child(scatola(Vector3(0.05, 0.01, 0.05), Vector3(-0.17, 0.04 + lato * 0.03, 0), "spada", Vector3(0, 0, lato * 40)))
	return n


## Barca a remi con il pescatore (vista in 8 direzioni): la prua è verso +Z come il viso dei portatori.
static func barca_remi() -> Node3D:
	var r := Node3D.new()
	var b := Node3D.new()
	b.name = "scafo"
	r.add_child(b)
	b.add_child(sfera(0.13, Vector3(0, 0.02, 0), "legno", Vector3(0.9, 0.55, 2.4)))
	b.add_child(sfera(0.115, Vector3(0, 0.05, 0), "legno_scuro", Vector3(0.85, 0.3, 2.3)))
	b.add_child(scatola(Vector3(0.03, 0.02, 0.6), Vector3(0.11, 0.07, 0), "persiana"))
	b.add_child(scatola(Vector3(0.03, 0.02, 0.6), Vector3(-0.11, 0.07, 0), "persiana"))
	var uomo := portatore("")
	uomo.scale = Vector3.ONE * 0.8
	uomo.position = Vector3(0, -0.13, -0.04)
	b.add_child(uomo)
	for lato in [-1, 1]:
		var remo := Node3D.new()
		remo.name = "remo_s" if lato < 0 else "remo_d"
		remo.position = Vector3(lato * 0.1, 0.1, 0.0)
		b.add_child(remo)
		remo.add_child(cilindro(0.006, 0.006, 0.32, Vector3(lato * 0.15, -0.03, 0), "legno_chiaro", Vector3(0, 0, lato * 75), 4))
		remo.add_child(scatola(Vector3(0.08, 0.005, 0.035), Vector3(lato * 0.3, -0.07, 0), "legno_chiaro", Vector3(0, 0, lato * 15)))
	r.set_meta("carico", "barca")
	return r


## Remata: i remi girano avanti e indietro, la barca beccheggia appena.
static func posa_remata(modello: Node3D, fotogramma: int, totale: int) -> void:
	var t := float(fotogramma) / totale * TAU
	var b: Node3D = modello.get_node("scafo")
	b.rotation.x = 0.04 * sin(t)
	for nome in ["remo_s", "remo_d"]:
		var remo: Node3D = b.get_node(nome)
		remo.rotation.y = (0.5 * sin(t)) * (1 if nome == "remo_d" else -1)
		remo.rotation.z = 0.15 * cos(t) * (1 if nome == "remo_d" else -1)


# =================================================================== PORTO E NAVE (step 28)

## Porto commerciale greco: magazzino con portico, banchina di pietra, pontile di legno sul mare,
## bitte, anfore, casse, gru a capra e una vela arrotolata.
static func porto() -> Node3D:
	var r := Node3D.new()
	var rng := _rng(2801)
	# banchina di pietra lungo il lato del mare (+x)
	r.add_child(scatola(Vector3(0.42, 0.1, 1.08), Vector3(0.36, 0.05, 0.02), "blocchi_greci"))
	r.add_child(scatola(Vector3(0.46, 0.025, 1.12), Vector3(0.36, 0.112, 0.02), "pietra"))
	for k in 6:
		r.add_child(scatola(Vector3(0.012, 0.004, 1.1), Vector3(0.18 + k * 0.07, 0.126, 0.02), "pietra_grezza"))
	# pontile di legno su pali che entra nel mare
	var pz := 0.26
	for k in 4:
		var x := 0.66 + k * 0.13
		for s in [-1, 1]:
			r.add_child(cilindro(0.017, 0.019, 0.26, Vector3(x, -0.01, pz + s * 0.12), "legno_vecchio", Vector3.ZERO, 7))
			r.add_child(cilindro(0.02, 0.02, 0.012, Vector3(x, 0.01, pz + s * 0.12), "foglie_scure", Vector3.ZERO, 7))
	for s in [-1, 1]:
		r.add_child(scatola(Vector3(0.5, 0.025, 0.02), Vector3(0.82, 0.095, pz + s * 0.12), "legno_scuro"))
	for k in 13:
		var x := 0.59 + k * 0.038
		r.add_child(scatola(Vector3(0.034, 0.014, 0.28), Vector3(x, 0.112 + rng.randf_range(-0.003, 0.003), pz), "legno" if k % 3 else "legno_chiaro", Vector3(0, rng.randf_range(-2, 2), 0)))
	# bitte di pietra e di legno con le cime
	for z in [-0.42, -0.08, 0.5]:
		r.add_child(cilindro(0.022, 0.026, 0.07, Vector3(0.54, 0.16, z), "blocco", Vector3.ZERO, 10))
		r.add_child(cilindro(0.03, 0.03, 0.014, Vector3(0.54, 0.198, z), "blocco", Vector3.ZERO, 10))
	for x in [0.72, 1.02]:
		for s in [-1, 1]:
			r.add_child(cilindro(0.014, 0.016, 0.07, Vector3(x, 0.155, pz + s * 0.125), "legno_scuro", Vector3.ZERO, 7))
	r.add_child(cilindro(0.03, 0.03, 0.014, Vector3(0.54, 0.177, -0.08), "corda", Vector3.ZERO, 10))
	ramo(r, Vector3(0.54, 0.175, -0.08), Vector3(0.66, 0.02, -0.02), 0.005, "corda")
	ramo(r, Vector3(1.02, 0.17, pz + 0.125), Vector3(1.1, 0.03, pz + 0.2), 0.005, "corda")
	# magazzino del porto con portico di colonne sul davanti
	var c := Node3D.new()
	c.position = Vector3(-0.28, 0, -0.26)
	r.add_child(c)
	var lx := 0.62
	var lz := 0.4
	var h := 0.32
	casa_muri(c, lx, lz, h, 2801, "intonaco")
	porta_z(c, -0.1, lz * 0.5 + 0.01, 0.14, 0.22)
	finestra_z(c, 0.16, 0.3, lz * 0.5 + 0.01, 0.07, 0.07)
	finestra_x(c, 0.0, 0.28, lx * 0.5 + 0.01, 0.07, 0.08)
	# fascia rossa sotto la gronda, alla greca
	c.add_child(scatola(Vector3(lx + 0.01, 0.025, lz + 0.01), Vector3(0, 0.07 + h - 0.02, 0), "rosso_pompeiano"))
	# portico: gradino, quattro colonne, architrave
	var pd := 0.2
	c.add_child(scatola(Vector3(lx + 0.06, 0.06, pd + 0.02), Vector3(0, 0.03, lz * 0.5 + pd * 0.5), "blocchi_greci"))
	c.add_child(scatola(Vector3(lx + 0.08, 0.02, pd + 0.04), Vector3(0, 0.07, lz * 0.5 + pd * 0.5), "marmo"))
	for k in 4:
		_colonna(c, Vector3(-lx * 0.5 + 0.04 + k * (lx - 0.08) / 3.0, 0.08, lz * 0.5 + pd - 0.03), h - 0.03, 0.022)
	c.add_child(scatola(Vector3(lx + 0.04, 0.04, 0.05), Vector3(0, 0.08 + h - 0.03 + 0.04, lz * 0.5 + pd - 0.03), "marmo"))
	var tt := Node3D.new()
	tt.position = Vector3(0, 0, pd * 0.5)
	c.add_child(tt)
	sottotetto(tt, lx, lz + pd, 0.07 + h + 0.03, 22.0)
	tetto(tt, lx + 0.06, lz + pd, 0.07 + h + 0.03, 22.0, 2801)
	# acroterio e antefisse sul colmo
	var alt := ((lz + pd) * 0.5 + 0.07) * tan(deg_to_rad(22.0))
	for s in [-1, 1]:
		tt.add_child(sfera(0.025, Vector3(s * (lx * 0.5 + 0.1), 0.07 + h + 0.03 + alt + 0.05, 0), "terracotta", Vector3(1, 1.4, 0.5)))
	# sotto il portico: anfore e sacchi
	for i in 4:
		c.add_child(anfora(Vector3(0.06 + i * 0.06, 0.08, lz * 0.5 + 0.07), 0.85))
	c.add_child(sacco(Vector3(-0.22, 0.08, lz * 0.5 + 0.08), 0.3))
	# insegna: un'anfora dipinta sopra la porta
	c.add_child(scatola(Vector3(0.1, 0.06, 0.01), Vector3(-0.1, 0.07 + 0.27, lz * 0.5 + 0.006), "intonaco_bianco"))
	c.add_child(sfera(0.014, Vector3(-0.1, 0.07 + 0.27, lz * 0.5 + 0.012), "terracotta", Vector3(1, 1.4, 0.3)))
	# piazzale lastricato davanti al magazzino
	r.add_child(scatola(Vector3(0.62, 0.012, 0.5), Vector3(-0.12, 0.006, 0.32), "pietra"))
	# anfore impilate su una rastrelliera (sdraiate, a piramide)
	var ra := Node3D.new()
	ra.position = Vector3(-0.42, 0, 0.34)
	r.add_child(ra)
	ra.add_child(scatola(Vector3(0.3, 0.02, 0.2), Vector3(0, 0.02, 0), "legno_scuro"))
	for f in 3:
		for k in 3 - f:
			var a := anfora(Vector3((k - (2 - f) * 0.5) * 0.085, 0.07 + f * 0.072, -0.07), 0.8)
			a.rotation_degrees.x = 90
			ra.add_child(a)
	for k in 3:
		ra.add_child(anfora(Vector3(-0.1 + k * 0.1, 0.03, 0.12), 0.9))
	# casse impilate e un barile
	r.add_child(cassa(Vector3(0.06, 0.012, 0.42), 10))
	r.add_child(cassa(Vector3(0.18, 0.012, 0.44), -15))
	r.add_child(cassa(Vector3(0.11, 0.1, 0.43), 30, 0.1))
	r.add_child(scatola(Vector3(0.1, 0.004, 0.1), Vector3(0.11, 0.182, 0.43), "corda", Vector3(0, 30, 0)))
	r.add_child(barile(Vector3(-0.06, 0.012, 0.52), 0.9))
	r.add_child(cesta(Vector3(0.28, 0.125, 0.4), "pesce", 0.8))
	# gru a capra di legno sulla banchina, sporta verso il mare con un carico di anfore appeso
	var g := Node3D.new()
	g.position = Vector3(0.42, 0.125, -0.28)
	r.add_child(g)
	var cima := Vector3(0.36, 0.62, 0.0)
	for s in [-1, 1]:
		ramo(g, Vector3(-0.04, 0, s * 0.12), cima, 0.016, "legno")
	ramo(g, Vector3(-0.22, 0, 0), cima + Vector3(-0.02, -0.02, 0), 0.012, "legno_vecchio")
	g.add_child(scatola(Vector3(0.02, 0.02, 0.26), Vector3(0.06, 0.18, 0), "legno_scuro"))
	g.add_child(cilindro(0.03, 0.03, 0.2, Vector3(0.0, 0.1, 0), "legno_scuro", Vector3(90, 0, 0), 10))
	g.add_child(cilindro(0.032, 0.032, 0.06, Vector3(0.0, 0.1, 0), "corda", Vector3(90, 0, 0), 10))
	g.add_child(cilindro(0.025, 0.025, 0.04, cima, "legno_chiaro", Vector3(90, 0, 0), 10))
	ramo(g, Vector3(0.0, 0.12, 0), cima, 0.004, "corda")
	ramo(g, cima, cima + Vector3(0, -0.34, 0), 0.004, "corda")
	var rete := Node3D.new()
	rete.position = cima + Vector3(0, -0.42, 0)
	g.add_child(rete)
	rete.add_child(scatola(Vector3(0.09, 0.006, 0.09), Vector3.ZERO, "legno_chiaro"))
	for k in 2:
		rete.add_child(anfora(Vector3(-0.022 + k * 0.044, 0.003, 0), 0.6))
	for s in [-1, 1]:
		ramo(rete, Vector3(s * 0.045, 0, 0), Vector3(0, 0.08, 0), 0.003, "corda")
	# vela arrotolata a strisce su un pennone, sulla banchina
	var v := Node3D.new()
	v.position = Vector3(0.3, 0.125, 0.1)
	v.rotation_degrees.y = 8
	r.add_child(v)
	v.add_child(cilindro(0.008, 0.008, 0.5, Vector3(0, 0.02, 0), "legno_chiaro", Vector3(90, 0, 0), 6))
	for k in 7:
		v.add_child(cilindro(0.032, 0.032, 0.06, Vector3(0, 0.034, -0.18 + k * 0.06), "lino" if k % 2 == 0 else "bandiera_rossa", Vector3(90, 0, 0), 10))
	for k in 4:
		v.add_child(cilindro(0.035, 0.035, 0.008, Vector3(0, 0.034, -0.15 + k * 0.1), "corda", Vector3(90, 0, 0), 10))
	# matassa di cima e un'ancora di ferro
	r.add_child(cilindro(0.04, 0.04, 0.02, Vector3(0.2, 0.135, -0.48), "corda", Vector3.ZERO, 12))
	r.add_child(cilindro(0.02, 0.02, 0.022, Vector3(0.2, 0.136, -0.48), "legno_scuro", Vector3.ZERO, 8))
	var an := _ancora_nave(Vector3(0.88, 0.12, pz), 90)
	an.scale = Vector3.ONE * 0.6
	r.add_child(an)
	# stendardo con il colore del giocatore
	r.add_child(cilindro(0.01, 0.008, 0.46, Vector3(0.52, 0.355, 0.5), "legno_scuro", Vector3.ZERO, 6))
	r.add_child(scatola(Vector3(0.006, 0.08, 0.12), Vector3(0.52, 0.53, 0.44), "giocatore"))
	r.add_child(sfera(0.013, Vector3(0.52, 0.59, 0.5), "moneta"))
	return r


## Nave mercantile antica: scafo panciuto, vela quadra a strisce, due remi-timone a poppa,
## anfore sul ponte e un marinaio al timone. La prua guarda verso +z.
static func nave() -> Node3D:
	var r := Node3D.new()
	var b := Node3D.new()
	b.name = "scafo"
	r.add_child(b)
	# scafo: una ciotola allungata, la murata scura e il ponte chiaro
	var mi := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.15
	sm.height = 0.15
	sm.is_hemisphere = true
	sm.radial_segments = 20
	sm.rings = 8
	mi.mesh = sm
	mi.rotation_degrees.x = 180
	mi.position = Vector3(0, 0.06, 0)
	mi.scale = Vector3(0.95, 0.75, 2.6)
	mi.material_override = materiale("legno")
	b.add_child(mi)
	var murata := cilindro(0.15, 0.15, 0.04, Vector3(0, 0.075, 0), "legno_scuro", Vector3.ZERO, 20)
	murata.scale = Vector3(0.95, 1, 2.6)
	b.add_child(murata)
	var fascia := cilindro(0.152, 0.152, 0.012, Vector3(0, 0.062, 0), "pece", Vector3.ZERO, 20)
	fascia.scale = Vector3(0.95, 1, 2.6)
	b.add_child(fascia)
	var ponte := cilindro(0.135, 0.135, 0.006, Vector3(0, 0.096, 0), "legno_chiaro", Vector3.ZERO, 20)
	ponte.scale = Vector3(0.95, 1, 2.6)
	b.add_child(ponte)
	for k in 5:
		b.add_child(scatola(Vector3(0.006, 0.002, 0.62), Vector3(-0.08 + k * 0.04, 0.1, 0), "legno_vecchio"))
	# dritto di prua con lo sperone e gli occhi dipinti
	ramo(b, Vector3(0, 0.05, 0.37), Vector3(0, 0.17, 0.41), 0.014, "legno_scuro")
	b.add_child(sfera(0.012, Vector3(0, 0.18, 0.412), "giocatore"))
	b.add_child(scatola(Vector3(0.02, 0.025, 0.08), Vector3(0, 0.02, 0.4), "legno_scuro", Vector3(-15, 0, 0)))
	for s in [-1, 1]:
		b.add_child(sfera(0.016, Vector3(s * 0.06, 0.075, 0.33), "intonaco_bianco", Vector3(0.4, 1, 1.4)))
		b.add_child(sfera(0.008, Vector3(s * 0.067, 0.075, 0.335), "buio", Vector3(0.5, 1, 1)))
	# poppa alta e ricurva a collo di cigno
	var punti := [Vector3(0, 0.07, -0.36), Vector3(0, 0.14, -0.41), Vector3(0, 0.22, -0.42), Vector3(0, 0.27, -0.39), Vector3(0, 0.28, -0.35)]
	for k in punti.size() - 1:
		ramo(b, punti[k], punti[k + 1], 0.018 - k * 0.003, "legno_scuro")
	b.add_child(sfera(0.014, Vector3(0, 0.275, -0.345), "moneta"))
	# piccola tolda di poppa
	b.add_child(scatola(Vector3(0.18, 0.02, 0.1), Vector3(0, 0.11, -0.28), "legno"))
	# due remi-timone ai lati della poppa
	for s in [-1, 1]:
		ramo(b, Vector3(s * 0.12, 0.17, -0.25), Vector3(s * 0.16, -0.04, -0.4), 0.008, "legno_chiaro")
		b.add_child(scatola(Vector3(0.012, 0.09, 0.05), Vector3(s * 0.163, -0.03, -0.405), "legno_chiaro", Vector3(-35, 0, 0)))
		b.add_child(scatola(Vector3(0.03, 0.03, 0.03), Vector3(s * 0.13, 0.11, -0.27), "legno_scuro"))
	# carico sul ponte: anfore in file e casse a prua
	for i in 6:
		b.add_child(anfora(Vector3(-0.05 + (i % 3) * 0.05, 0.096, -0.14 + (i / 3) * 0.06), 0.62))
	b.add_child(cassa(Vector3(-0.04, 0.096, 0.2), 10, 0.07))
	b.add_child(cassa(Vector3(0.05, 0.096, 0.22), -12, 0.07))
	b.add_child(sacco(Vector3(0.0, 0.08, 0.28), 0.4))
	# albero, pennone e stralli
	b.add_child(cilindro(0.013, 0.01, 0.56, Vector3(0, 0.37, 0.05), "legno_scuro", Vector3.ZERO, 8))
	b.add_child(cilindro(0.008, 0.006, 0.52, Vector3(0, 0.6, 0.06), "legno_chiaro", Vector3(0, 0, 90), 6))
	ramo(b, Vector3(0, 0.64, 0.05), Vector3(0, 0.17, 0.4), 0.003, "corda")
	ramo(b, Vector3(0, 0.64, 0.05), Vector3(0, 0.27, -0.37), 0.003, "corda")
	for s in [-1, 1]:
		ramo(b, Vector3(0, 0.6, 0.05), Vector3(s * 0.13, 0.1, 0.0), 0.0025, "corda")
	var pennello := Node3D.new()
	pennello.name = "pennello"
	pennello.position = Vector3(0, 0.64, 0.05)
	b.add_child(pennello)
	pennello.add_child(scatola(Vector3(0.004, 0.025, 0.07), Vector3(0, 0, -0.035), "giocatore"))
	# vela quadra a strisce verticali bianche e rosse, gonfiata in avanti
	var vela := Node3D.new()
	vela.name = "vela"
	vela.position = Vector3(0, 0.595, 0.075)
	b.add_child(vela)
	var colonne := 7
	var righe := 6
	var larg := 0.48
	var alt := 0.36
	for j in colonne:
		var xn := (j + 0.5) / colonne * 2.0 - 1.0
		for k in righe:
			var yn := (k + 0.5) / righe
			var gonfio := 0.06 * (1.0 - xn * xn * 0.7) * sin(PI * (0.25 + yn * 0.75))
			var pezzo := scatola(Vector3(larg / colonne + 0.003, alt / righe + 0.003, 0.006), Vector3(xn * larg * 0.5, -yn * alt, gonfio), "lino" if j % 2 == 0 else "bandiera_rossa", Vector3(0, -xn * 25, 0))
			vela.add_child(pezzo)
	# scotte dagli angoli bassi della vela ai fianchi
	for s in [-1, 1]:
		ramo(b, Vector3(s * 0.24, 0.24, 0.09), Vector3(s * 0.13, 0.1, -0.12), 0.0025, "corda")
	# il marinaio al timone
	var uomo := portatore("")
	uomo.scale = Vector3.ONE * 0.66
	uomo.position = Vector3(0, 0.12, -0.27)
	b.add_child(uomo)
	r.set_meta("carico", "nave")
	return r


## Navigazione a vela: la nave rolla e beccheggia piano, la vela si gonfia, il pennello sventola.
static func posa_vela(modello: Node3D, fotogramma: int, totale: int) -> void:
	var t := float(fotogramma) / totale * TAU
	var b: Node3D = modello.get_node("scafo")
	b.rotation.z = 0.05 * sin(t)
	b.rotation.x = 0.025 * cos(t)
	b.position.y = 0.008 * sin(t * 2.0)
	var vela: Node3D = b.get_node("vela")
	vela.scale.z = 1.0 + 0.35 * (0.5 + 0.5 * sin(t))
	var pennello: Node3D = b.get_node("pennello")
	pennello.rotation.y = 0.35 * sin(t * 2.0)
	var corpo: Node3D = (b.get_child(b.get_child_count() - 1) as Node3D).get_node("corpo")
	corpo.get_node("braccio_d").rotation = Vector3(-0.6 + 0.15 * sin(t), 0, 0.3)
	corpo.get_node("braccio_s").rotation = Vector3(-0.6 + 0.15 * sin(t), 0, -0.3)


## Nave da guerra antica (bireme): scafo lungo, basso e scuro, sperone di bronzo a prua sul pelo dell'acqua,
## occhi dipinti, due file di remi per lato, vela quadra ammainata a metà, scudi col colore del giocatore
## lungo le murate, castello di prua con due arcieri e bandiera a poppa. La prua guarda verso +z.
static func nave_guerra() -> Node3D:
	var r := Node3D.new()
	var b := Node3D.new()
	b.name = "scafo"
	r.add_child(b)
	var lz := 3.7  # allungamento dello scafo
	var lx := 0.72  # strettezza dello scafo
	# opera viva: una ciotola lunga e stretta, nera di pece
	var mi := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.15
	sm.height = 0.15
	sm.is_hemisphere = true
	sm.radial_segments = 24
	sm.rings = 8
	mi.mesh = sm
	mi.rotation_degrees.x = 180
	mi.position = Vector3(0, 0.05, 0)
	mi.scale = Vector3(lx, 0.5, lz)
	mi.material_override = materiale("pece")
	b.add_child(mi)
	# murate scure, fascia rossa sotto gli scalmi, bordo chiaro e ponte
	var murata := cilindro(0.15, 0.15, 0.05, Vector3(0, 0.075, 0), "legno_scuro", Vector3.ZERO, 24)
	murata.scale = Vector3(lx, 1, lz)
	b.add_child(murata)
	var fascia := cilindro(0.152, 0.152, 0.01, Vector3(0, 0.058, 0), "bandiera_rossa", Vector3.ZERO, 24)
	fascia.scale = Vector3(lx, 1, lz)
	b.add_child(fascia)
	b.add_child(_toro(0.142, 0.154, Vector3(0, 0.102, 0), "legno_chiaro", Vector3.ZERO, Vector3(lx, 0.5, lz)))
	var ponte := cilindro(0.138, 0.138, 0.006, Vector3(0, 0.098, 0), "legno_vecchio", Vector3.ZERO, 24)
	ponte.scale = Vector3(lx, 1, lz)
	b.add_child(ponte)
	# passerella centrale tra le file dei rematori
	b.add_child(scatola(Vector3(0.04, 0.006, 0.7), Vector3(0, 0.104, -0.02), "legno"))
	for k in 9:
		b.add_child(scatola(Vector3(0.16, 0.004, 0.012), Vector3(0, 0.103, -0.36 + k * 0.08), "legno_scuro"))
	# sperone di bronzo a tre lame sul pelo dell'acqua, con la trave che lo regge
	b.add_child(scatola(Vector3(0.03, 0.03, 0.14), Vector3(0, 0.015, 0.52), "legno_scuro", Vector3(-8, 0, 0)))
	b.add_child(cilindro(0.032, 0.0, 0.13, Vector3(0, 0.01, 0.62), "bronzo", Vector3(90, 0, 0), 4))
	for y: float in [0.0, 0.022]:
		b.add_child(scatola(Vector3(0.07, 0.006, 0.05), Vector3(0, y, 0.585), "bronzo"))
	b.add_child(scatola(Vector3(0.006, 0.05, 0.05), Vector3(0, 0.012, 0.585), "bronzo"))
	# dritto di prua che sale e si ripiega all'indietro
	var prua := [Vector3(0, 0.04, 0.54), Vector3(0, 0.12, 0.575), Vector3(0, 0.19, 0.57), Vector3(0, 0.22, 0.54)]
	for k in prua.size() - 1:
		ramo(b, prua[k], prua[k + 1], 0.016 - k * 0.003, "legno_scuro")
	b.add_child(sfera(0.012, Vector3(0, 0.222, 0.535), "bronzo"))
	# occhi dipinti sulle guance di prua
	for s: int in [-1, 1]:
		b.add_child(sfera(0.02, Vector3(s * 0.05, 0.068, 0.49), "intonaco_bianco", Vector3(0.35, 0.8, 1.5)))
		b.add_child(sfera(0.01, Vector3(s * 0.056, 0.068, 0.497), "buio", Vector3(0.5, 1, 1)))
		b.add_child(sfera(0.02, Vector3(s * 0.048, 0.079, 0.49), "bandiera_rossa", Vector3(0.3, 0.25, 1.6)))
	# castello di prua: piattaforma su travi con parapetto e due arcieri
	b.add_child(scatola(Vector3(0.15, 0.012, 0.12), Vector3(0, 0.17, 0.4), "legno"))
	for s: int in [-1, 1]:
		for zz: float in [0.35, 0.45]:
			b.add_child(cilindro(0.007, 0.007, 0.07, Vector3(s * 0.06, 0.135, zz), "legno_scuro", Vector3.ZERO, 6))
		b.add_child(scatola(Vector3(0.008, 0.03, 0.12), Vector3(s * 0.072, 0.19, 0.4), "legno_scuro"))
	b.add_child(scatola(Vector3(0.15, 0.03, 0.008), Vector3(0, 0.19, 0.458), "legno_scuro"))
	for k in 2:
		var arc := portatore("", "giocatore")
		arc.name = "arciere_%d" % k
		arc.scale = Vector3.ONE * 0.5
		arc.position = Vector3(-0.035 + k * 0.07, 0.176, 0.4 + k * 0.01)
		arc.rotation_degrees.y = -20 + k * 40
		var corpo: Node3D = arc.get_node("corpo")
		corpo.add_child(sfera(0.08, Vector3(0, 0.2 + 0.28, -0.008), "bronzo", Vector3(1, 0.75, 1.05)))
		_arco_sic(corpo.get_node("braccio_s"), Vector3(-0.005, -0.14, 0.02), 0.24, 0.05)
		corpo.add_child(_faretra(Vector3(0.035, 0.36, -0.09), Vector3(-12, 0, -22), 1.0))
		b.add_child(arc)
	# poppa: coda ricurva verso l'alto e in avanti, a ventaglio (aplustre)
	var poppa := [Vector3(0, 0.07, -0.53), Vector3(0, 0.15, -0.58), Vector3(0, 0.23, -0.57), Vector3(0, 0.28, -0.53)]
	for k in poppa.size() - 1:
		ramo(b, poppa[k], poppa[k + 1], 0.018 - k * 0.004, "legno_scuro")
	for s: int in [-1, 1]:
		ramo(b, Vector3(0, 0.23, -0.57), Vector3(s * 0.03, 0.3, -0.555), 0.005, "legno_scuro")
	b.add_child(sfera(0.012, Vector3(0, 0.285, -0.525), "bronzo"))
	# tolda di poppa e remi-timone
	b.add_child(scatola(Vector3(0.14, 0.016, 0.1), Vector3(0, 0.11, -0.44), "legno"))
	for s: int in [-1, 1]:
		ramo(b, Vector3(s * 0.08, 0.16, -0.42), Vector3(s * 0.12, -0.03, -0.55), 0.007, "legno_chiaro")
		b.add_child(scatola(Vector3(0.01, 0.07, 0.04), Vector3(s * 0.122, -0.025, -0.555), "legno_chiaro", Vector3(-35, 0, 0)))
	# timoniere
	var uomo := portatore("", "giocatore")
	uomo.scale = Vector3.ONE * 0.5
	uomo.position = Vector3(0, 0.118, -0.43)
	b.add_child(uomo)
	# bandiera del giocatore su un'asta a poppa
	b.add_child(cilindro(0.005, 0.004, 0.2, Vector3(0, 0.21, -0.47), "legno_scuro", Vector3.ZERO, 6))
	var bandiera := Node3D.new()
	bandiera.name = "bandiera"
	bandiera.position = Vector3(0, 0.29, -0.47)
	b.add_child(bandiera)
	for k in 3:
		var pz := scatola(Vector3(0.004, 0.05, 0.03), Vector3(0, -0.02, -0.015 - k * 0.03), "giocatore")
		pz.name = "lembo_%d" % k
		bandiera.add_child(pz)
	# albero basso, pennone e vela quadra ammainata a metà (raccolta in pieghe sotto il pennone)
	b.add_child(cilindro(0.011, 0.008, 0.36, Vector3(0, 0.28, 0.06), "legno_scuro", Vector3.ZERO, 8))
	b.add_child(cilindro(0.007, 0.006, 0.48, Vector3(0, 0.42, 0.07), "legno_chiaro", Vector3(0, 0, 90), 6))
	ramo(b, Vector3(0, 0.45, 0.06), Vector3(0, 0.2, 0.55), 0.0025, "corda")
	ramo(b, Vector3(0, 0.45, 0.06), Vector3(0, 0.26, -0.53), 0.0025, "corda")
	for s: int in [-1, 1]:
		ramo(b, Vector3(0, 0.42, 0.06), Vector3(s * 0.1, 0.1, 0.0), 0.002, "corda")
	var vela := Node3D.new()
	vela.name = "vela"
	vela.position = Vector3(0, 0.415, 0.08)
	b.add_child(vela)
	var colonne := 8
	var larg := 0.44
	for j in colonne:
		var xn := (j + 0.5) / colonne * 2.0 - 1.0
		var tinta := "lino" if j % 2 == 0 else "bandiera_rossa"
		# telo che pende per metà altezza, un po' sbuffato
		vela.add_child(scatola(Vector3(larg / colonne + 0.003, 0.12, 0.005), Vector3(xn * larg * 0.5, -0.07, 0.012 * (1.0 - xn * xn)), tinta))
		# rotolo raccolto sotto il pennone
		vela.add_child(cilindro(0.016, 0.016, larg / colonne + 0.002, Vector3(xn * larg * 0.5, -0.012, 0.005), tinta, Vector3(0, 0, 90), 8))
	# imbrogli: cime che reggono le pieghe
	for k in 4:
		var x := -0.15 + k * 0.1
		vela.add_child(scatola(Vector3(0.003, 0.14, 0.003), Vector3(x, -0.07, 0.02), "corda"))
	# file di remi (due per lato): ogni remo ruota sul suo scalmo
	var remi := Node3D.new()
	remi.name = "remi"
	b.add_child(remi)
	for s: int in [-1, 1]:
		for fila in 2:
			var n := 8 if fila == 0 else 7
			for k in n:
				var z := -0.32 + k * (0.62 / (n - 1))
				var mezza := sqrt(maxf(0.0, 1.0 - pow(z / (0.15 * lz), 2.0)))
				var perno := Node3D.new()
				perno.set_meta("lato", s)
				perno.set_meta("fila", fila)
				perno.position = Vector3(s * (0.15 * lx * mezza + 0.002), 0.088 if fila == 0 else 0.062, z + (0.0 if fila == 0 else 0.04))
				remi.add_child(perno)
				var lungo := 0.25 if fila == 0 else 0.2
				var cima := Vector3(s * lungo, -0.1 if fila == 0 else -0.075, 0)
				ramo(perno, Vector3.ZERO, cima, 0.0045, "legno")
				perno.add_child(scatola(Vector3(0.055, 0.004, 0.022), cima + Vector3(s * 0.02, -0.008, 0), "legno_chiaro", Vector3(0, 0, s * 20)))
				# scalmo scuro sulla murata
				b.add_child(sfera(0.008, perno.position, "buio", Vector3(1, 1, 1.2)))
	# scudi rotondi appesi lungo le murate, col colore del giocatore e l'umbone di bronzo
	for s: int in [-1, 1]:
		for k in 8:
			var z := -0.3 + k * 0.085
			var mezza := sqrt(maxf(0.0, 1.0 - pow(z / (0.15 * lz), 2.0)))
			var x := s * (0.15 * lx * mezza + 0.008)
			b.add_child(cilindro(0.03, 0.03, 0.006, Vector3(x, 0.112, z), "giocatore", Vector3(0, 0, 90), 12))
			b.add_child(_toro(0.026, 0.031, Vector3(x + s * 0.001, 0.112, z), "bronzo", Vector3(0, 0, 90)))
			b.add_child(sfera(0.008, Vector3(x + s * 0.004, 0.112, z), "bronzo", Vector3(0.6, 1, 1)))
	r.set_meta("carico", "nave")
	return r


## Voga: le due file di remi passano avanti e indietro insieme, entrando e uscendo dall'acqua;
## lo scafo beccheggia appena e la bandiera sventola.
static func posa_voga(modello: Node3D, fotogramma: int, totale: int) -> void:
	var t := float(fotogramma) / totale * TAU
	var b: Node3D = modello.get_node("scafo")
	b.rotation.x = 0.03 * sin(t)
	b.rotation.z = 0.012 * sin(t * 2.0)
	b.position.y = 0.006 * cos(t)
	for perno: Node3D in b.get_node("remi").get_children():
		var s: int = perno.get_meta("lato")
		var fase := t + (0.3 if int(perno.get_meta("fila")) == 1 else 0.0)
		# avanti-indietro attorno all'asse verticale, e su (ritorno) / giù (in acqua)
		perno.rotation.y = 0.45 * sin(fase) * -s
		perno.rotation.z = 0.18 * cos(fase) * s
	var bandiera: Node3D = b.get_node("bandiera")
	for k in 3:
		var pz: Node3D = bandiera.get_node("lembo_%d" % k)
		pz.rotation.y = 0.3 * sin(t * 2.0 - k * 0.9) * (k + 1) * 0.5
	for k in 2:
		var corpo: Node3D = b.get_node("arciere_%d" % k).get_node("corpo")
		corpo.get_node("braccio_s").rotation = Vector3(-1.3, 0, -0.15)
		corpo.get_node("braccio_d").rotation = Vector3(-1.2 + 0.25 * sin(t + k * PI), 0, 0.3)

# =================================================================== METALLO (step 07)

## Attrezzo da solo (per le merci a terra e il fascio del portatore).
static func attrezzo(tipo: String) -> Node3D:
	var n := Node3D.new()
	n.add_child(cilindro(0.008, 0.008, 0.22, Vector3(0, 0.01, 0), "legno", Vector3(0, 0, 90), 6))
	match tipo:
		"ascia":
			n.add_child(scatola(Vector3(0.05, 0.012, 0.06), Vector3(0.11, 0.012, 0.02), "ferro"))
		"piccone":
			n.add_child(scatola(Vector3(0.02, 0.014, 0.16), Vector3(0.11, 0.012, 0), "ferro"))
		"pala":
			n.add_child(scatola(Vector3(0.07, 0.008, 0.06), Vector3(0.14, 0.008, 0), "ferro"))
		"falce":
			for k in 4:
				n.add_child(scatola(Vector3(0.03, 0.008, 0.012), Vector3(0.11 + 0.012 * k, 0.01, 0.015 + 0.02 * k - 0.003 * k * k), "ferro", Vector3(0, -k * 25, 0)))
		"canna":
			n.add_child(cilindro(0.004, 0.002, 0.2, Vector3(0.2, 0.01, 0), "legno_chiaro", Vector3(0, 0, 90), 4))
		"sega":
			n.add_child(scatola(Vector3(0.18, 0.004, 0.04), Vector3(0.06, 0.012, 0.025), "ferro"))
		"martello":
			n.add_child(scatola(Vector3(0.03, 0.03, 0.06), Vector3(0.11, 0.015, 0), "ferro"))
	return n


static func mucchio(pos: Vector3, mat: String, pezzi: int, seme: int, dim := 0.035) -> Node3D:
	var n := Node3D.new()
	n.position = pos
	var rng := _rng(seme)
	for k in pezzi:
		var a := k * 2.4
		var rr := 0.012 * k
		n.add_child(sfera(dim * rng.randf_range(0.7, 1.2), Vector3(cos(a) * rr, dim * 0.6 + (pezzi - k) * 0.004, sin(a) * rr), mat,
			Vector3(1, rng.randf_range(0.6, 0.9), 1)))
	return n


static func miniera_ferro(minerale := "minerale") -> Node3D:
	var r := Node3D.new()
	# fianco della montagna con l'imbocco puntellato
	r.add_child(sfera(0.6, Vector3(-0.25, 0.0, -0.3), "roccia_massi", Vector3(1.2, 0.75, 1.0)))
	r.add_child(sfera(0.35, Vector3(0.35, 0.0, -0.45), "roccia_massi", Vector3(1.1, 0.8, 1.0)))
	r.add_child(sfera(0.3, Vector3(-0.65, 0.0, 0.15), "roccia_massi", Vector3(1.0, 0.7, 1.0)))
	var imb := Vector3(-0.05, 0, 0.18)
	r.add_child(scatola(Vector3(0.22, 0.26, 0.1), imb + Vector3(0, 0.13, 0), "buio"))
	for lato in [-1, 1]:
		r.add_child(scatola(Vector3(0.04, 0.3, 0.04), imb + Vector3(lato * 0.13, 0.15, 0.05), "legno_vecchio"))
	r.add_child(scatola(Vector3(0.34, 0.045, 0.05), imb + Vector3(0, 0.31, 0.05), "legno_vecchio"))
	r.add_child(scatola(Vector3(0.12, 0.03, 0.01), imb + Vector3(0, 0.36, 0.08), "legno_chiaro"))
	# binari e carrello di minerale
	for lato in [-1, 1]:
		r.add_child(scatola(Vector3(0.012, 0.01, 0.55), imb + Vector3(lato * 0.05, 0.005, 0.3), "ferro"))
	for k in 6:
		r.add_child(scatola(Vector3(0.14, 0.008, 0.02), imb + Vector3(0, 0.004, 0.08 + k * 0.09), "legno_scuro"))
	var carr := Vector3(-0.05, 0, 0.5)
	r.add_child(scatola(Vector3(0.14, 0.08, 0.18), carr + Vector3(0, 0.07, 0), "legno"))
	r.add_child(mucchio(carr + Vector3(0, 0.1, 0), minerale, 6, 3, 0.03))
	for x in [-0.075, 0.075]:
		for z in [-0.06, 0.06]:
			r.add_child(cilindro(0.022, 0.022, 0.012, carr + Vector3(x, 0.025, z), "ferro", Vector3(0, 0, 90), 8))
	# mucchio di minerale, lanterna, puntelli di scorta
	r.add_child(mucchio(Vector3(0.45, 0, 0.35), minerale, 14, 4))
	r.add_child(cilindro(0.01, 0.01, 0.3, Vector3(0.22, 0.15, 0.3), "legno_vecchio", Vector3.ZERO, 5))
	r.add_child(sfera(0.025, Vector3(0.22, 0.31, 0.3), "miele"))
	for k in 4:
		r.add_child(cilindro(0.018, 0.018, 0.4, Vector3(-0.55 + k * 0.045, 0.02 + (k % 2) * 0.03, 0.55), "legno_vecchio", Vector3(0, 70, 90), 6))
	return r


static func carbonaia() -> Node3D:
	var r := Node3D.new()
	# capanno del carbonaio
	var c := Node3D.new()
	c.position = Vector3(-0.38, 0, -0.35)
	r.add_child(c)
	c.add_child(scatola(Vector3(0.44, 0.05, 0.36), Vector3(0, 0.025, 0), "pietra"))
	c.add_child(scatola(Vector3(0.4, 0.24, 0.32), Vector3(0, 0.17, 0), "legno_vecchio"))
	porta_z(c, 0.05, 0.16, 0.1, 0.17)
	sottotetto(c, 0.4, 0.32, 0.29, 32.0, "legno")
	tetto_scandole(c, 0.46, 0.32, 0.29, 32.0)
	# la carbonaia: cupola di legna coperta di terra, che fuma
	var m := Vector3(0.22, 0, 0.2)
	r.add_child(sfera(0.36, m, "terra", Vector3(1, 0.7, 1)))
	r.add_child(sfera(0.3, m + Vector3(0, 0.03, 0), "fuliggine", Vector3(1, 0.7, 1)))
	r.add_child(sfera(0.37, m + Vector3(0, -0.01, 0), "terra", Vector3(1, 0.68, 1)))
	for k in 5:
		r.add_child(sfera(0.05 + k * 0.012, m + Vector3(0.02 * k, 0.28 + k * 0.07, -0.01 * k), "fumo", Vector3(1, 0.8, 1)))
	r.add_child(scatola(Vector3(0.06, 0.04, 0.04), m + Vector3(0.0, 0.12, 0.33), "buio"))
	# legna da cuocere e carbone pronto
	legnaia(r, Vector3(-0.55, 0, 0.35), 0.35, 4)
	r.add_child(mucchio(Vector3(0.62, 0, -0.25), "carbone", 12, 5))
	r.add_child(sacco(Vector3(0.6, 0, 0.55), 0.4))
	return r


static func fonderia() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.25, 0, -0.25)
	r.add_child(c)
	var lx := 0.66
	var lz := 0.52
	var h := 0.36
	casa_muri(c, lx, lz, h, 211, "pietra_vista")
	porta_z(c, -0.12, lz * 0.5, 0.14, 0.24)
	sottotetto(c, lx, lz, 0.07 + h, 20.0)
	tetto(c, lx + 0.06, lz, 0.07 + h, 20.0, 211)
	# forno a torre in pietra con la bocca accesa e mantici
	var f := Vector3(0.42, 0, 0.38)
	r.add_child(cilindro(0.17, 0.2, 0.5, f + Vector3(0, 0.25, 0), "pietra", Vector3.ZERO, 16))
	r.add_child(cilindro(0.13, 0.15, 0.08, f + Vector3(0, 0.54, 0), "fuliggine", Vector3.ZERO, 16))
	r.add_child(scatola(Vector3(0.1, 0.1, 0.05), f + Vector3(-0.05, 0.12, 0.17), "brace", Vector3(0, 25, 0)))
	for k in 4:
		r.add_child(sfera(0.05 + k * 0.012, f + Vector3(0.0, 0.66 + k * 0.08, -0.01 * k), "fumo"))
	r.add_child(sfera(0.07, f + Vector3(-0.28, 0.1, 0.05), "pelle_scura", Vector3(1.4, 0.5, 1.0)))
	# lingotti, carbone e minerale in attesa
	for k in 6:
		r.add_child(scatola(Vector3(0.09, 0.025, 0.035), Vector3(-0.45 + (k % 3) * 0.1, 0.013 + (k / 3) * 0.026, 0.55), "lingotto"))
	r.add_child(mucchio(Vector3(-0.62, 0, 0.25), "carbone", 9, 6))
	r.add_child(mucchio(Vector3(0.68, 0, -0.1), "minerale", 9, 7))
	return r


static func fabbro() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.28)
	r.add_child(c)
	var lx := 0.72
	var lz := 0.5
	var h := 0.38
	casa_muri(c, lx, lz, h, 221)
	porta_z(c, 0.16, lz * 0.5, 0.13, 0.24)
	finestra_z(c, -0.18, 0.34, lz * 0.5, 0.1, 0.1)
	sottotetto(c, lx, lz, 0.07 + h, 22.0)
	tetto(c, lx + 0.06, lz, 0.07 + h, 22.0, 221)
	comignolo(c, Vector3(-0.22, 0.07 + h + 0.05, -0.05), 0.2)
	# fucina all'aperto sotto una tettoia: focolare, incudine, attrezzi appesi
	for p in [Vector3(-0.5, 0, 0.6), Vector3(0.1, 0, 0.6)]:
		r.add_child(cilindro(0.014, 0.014, 0.34, p + Vector3(0, 0.17, 0), "legno_vecchio", Vector3.ZERO, 6))
	r.add_child(scatola(Vector3(0.68, 0.025, 0.36), Vector3(-0.2, 0.35, 0.46), "tegola_scura", Vector3(-14, 0, 0)))
	r.add_child(scatola(Vector3(0.2, 0.12, 0.16), Vector3(-0.38, 0.06, 0.42), "pietra"))
	r.add_child(scatola(Vector3(0.14, 0.01, 0.1), Vector3(-0.38, 0.125, 0.42), "brace"))
	r.add_child(cilindro(0.04, 0.05, 0.08, Vector3(-0.05, 0.04, 0.45), "corteccia", Vector3.ZERO, 10))
	r.add_child(scatola(Vector3(0.12, 0.04, 0.05), Vector3(-0.05, 0.1, 0.45), "ferro"))
	r.add_child(scatola(Vector3(0.04, 0.025, 0.035), Vector3(0.03, 0.1, 0.45), "ferro"))
	for k in 4:
		var a := attrezzo(ATTREZZI_FABBRO[k])
		a.position = Vector3(-0.42 + k * 0.1, 0.25, 0.235)
		a.rotation_degrees = Vector3(90, 0, 90)
		r.add_child(a)
	r.add_child(barile(Vector3(0.62, 0, 0.1), 1.0))
	r.add_child(cilindro(0.04, 0.04, 0.005, Vector3(0.62, 0.1, 0.1), "acqua_pozzo", Vector3.ZERO, 10))
	for k in 3:
		r.add_child(scatola(Vector3(0.09, 0.025, 0.035), Vector3(0.45, 0.013 + k * 0.026, 0.45), "lingotto"))
	return r


const ATTREZZI_FABBRO := ["ascia", "piccone", "falce", "martello"]


# =================================================================== GRECI COMPLETI (step 11)

static func argillaio() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.32, 0, -0.32)
	r.add_child(c)
	c.add_child(scatola(Vector3(0.5, 0.05, 0.4), Vector3(0, 0.025, 0), "pietra"))
	c.add_child(scatola(Vector3(0.46, 0.26, 0.36), Vector3(0, 0.18, 0), "argilla_cruda"))
	porta_z(c, 0.06, 0.18, 0.11, 0.18)
	sottotetto(c, 0.46, 0.36, 0.31, 28.0, "legno")
	tetto_scandole(c, 0.52, 0.36, 0.31, 28.0)
	# fossa d'argilla, mattoni crudi che seccano, pala, acqua
	r.add_child(sfera(0.3, Vector3(0.3, -0.02, 0.25), "argilla", Vector3(1.3, 0.12, 1.0)))
	r.add_child(sfera(0.22, Vector3(0.3, 0.0, 0.25), "argilla_cruda", Vector3(1.3, 0.08, 1.0)))
	for k in 12:
		r.add_child(scatola(Vector3(0.07, 0.03, 0.04), Vector3(-0.55 + (k % 4) * 0.09, 0.015 + (k / 4) * 0.032, 0.45), "argilla", Vector3(0, (k % 2) * 5, 0)))
	var a := attrezzo("pala")
	a.position = Vector3(0.62, 0.02, 0.05)
	a.rotation_degrees = Vector3(0, 40, 10)
	r.add_child(a)
	r.add_child(barile(Vector3(-0.1, 0, 0.6), 1.0))
	r.add_child(cilindro(0.04, 0.04, 0.005, Vector3(-0.1, 0.1, 0.6), "acqua_pozzo", Vector3.ZERO, 10))
	return r


static func fornace() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.25, 0, -0.3)
	r.add_child(c)
	var lx := 0.6
	var lz := 0.46
	var h := 0.32
	casa_muri(c, lx, lz, h, 231)
	porta_z(c, 0.12, lz * 0.5, 0.12, 0.22)
	sottotetto(c, lx, lz, 0.07 + h, 22.0)
	tetto(c, lx + 0.06, lz, 0.07 + h, 22.0, 231)
	# fornace a cupola con la bocca accesa, anfore dipinte in fila ad asciugare
	var f := Vector3(0.42, 0, 0.35)
	r.add_child(cilindro(0.2, 0.22, 0.14, f + Vector3(0, 0.07, 0), "argilla", Vector3.ZERO, 18))
	r.add_child(sfera(0.2, f + Vector3(0, 0.14, 0), "argilla", Vector3(1, 1.0, 1)))
	r.add_child(scatola(Vector3(0.08, 0.07, 0.05), f + Vector3(-0.05, 0.1, 0.19), "brace", Vector3(0, 25, 0)))
	for k in 3:
		r.add_child(sfera(0.04 + k * 0.012, f + Vector3(0.0, 0.4 + k * 0.08, 0.0), "fumo"))
	for k in 7:
		var an := anfora(Vector3(-0.6 + (k % 4) * 0.1, 0, 0.42 + (k / 4) * 0.12), 1.2)
		r.add_child(an)
		r.add_child(cilindro(0.047, 0.047, 0.015, Vector3(-0.6 + (k % 4) * 0.1, 0.075 * 1.2, 0.42 + (k / 4) * 0.12), "fuliggine", Vector3.ZERO, 10))
	r.add_child(mucchio(Vector3(0.68, 0, -0.15), "argilla", 8, 9))
	legnaia(r, Vector3(0.65, 0, 0.12), 0.2, 3)
	return r


static func saline() -> Node3D:
	var r := Node3D.new()
	# vasche basse di evaporazione, cumuli di sale, capanno del salinaro
	for i in 3:
		for j in 2:
			var p := Vector3(-0.45 + i * 0.42, 0, -0.25 + j * 0.5)
			r.add_child(scatola(Vector3(0.4, 0.04, 0.46), p + Vector3(0, 0.02, 0), "argilla_cruda"))
			var mat := "acqua_pozzo" if (i + j) % 3 != 0 else "sale"
			r.add_child(scatola(Vector3(0.34, 0.005, 0.4), p + Vector3(0, 0.042, 0), mat))
	for p in [Vector3(0.62, 0, 0.55), Vector3(0.42, 0, 0.62), Vector3(-0.6, 0, 0.6)]:
		r.add_child(sfera(0.1, p, "sale", Vector3(1, 0.9, 1)))
	var c := Node3D.new()
	c.position = Vector3(0.6, 0, -0.55)
	r.add_child(c)
	c.add_child(scatola(Vector3(0.28, 0.2, 0.24), Vector3(0, 0.1, 0), "legno_vecchio"))
	tetto_scandole(c, 0.32, 0.24, 0.2, 30.0)
	var a := attrezzo("pala")
	a.position = Vector3(0.25, 0.02, 0.45)
	a.rotation_degrees = Vector3(0, -30, 5)
	r.add_child(a)
	r.add_child(sacco(Vector3(0.0, 0, 0.62), 0.3))
	return r


static func zecca() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.25)
	r.add_child(c)
	var lx := 0.74
	var lz := 0.56
	var h := 0.42
	casa_muri(c, lx, lz, h, 241, "marmo")
	porta_z(c, 0.0, lz * 0.5, 0.15, 0.26)
	for x in [-0.25, 0.25]:
		c.add_child(cilindro(0.03, 0.026, h, Vector3(x, 0.07 + h * 0.5, lz * 0.5 + 0.06), "marmo", Vector3.ZERO, 12))
	c.add_child(scatola(Vector3(lx, 0.04, 0.14), Vector3(0, 0.07 + h + 0.02, lz * 0.5 + 0.03), "marmo"))
	sottotetto(c, lx, lz, 0.07 + h, 18.0, "marmo")
	tetto(c, lx + 0.06, lz, 0.07 + h, 18.0, 241)
	comignolo(c, Vector3(0.24, 0.07 + h + 0.04, -0.12), 0.16)
	# casse di ducati, incudine per coniare, guardia
	for k in 3:
		r.add_child(cassa(Vector3(0.45 + k * 0.12, 0, 0.4), k * 15, 0.1))
		r.add_child(cilindro(0.035, 0.035, 0.01, Vector3(0.45 + k * 0.12, 0.085, 0.4), "moneta", Vector3.ZERO, 10))
	r.add_child(cilindro(0.04, 0.05, 0.08, Vector3(-0.35, 0.04, 0.5), "corteccia", Vector3.ZERO, 10))
	r.add_child(scatola(Vector3(0.1, 0.035, 0.05), Vector3(-0.35, 0.095, 0.5), "ferro"))
	r.add_child(mucchio(Vector3(-0.62, 0, 0.25), "argento_grezzo", 8, 10))
	var g := portatore("")
	g.position = Vector3(0.15, 0, 0.5)
	g.scale = Vector3.ONE * 0.9
	r.add_child(g)
	g.add_child(cilindro(0.006, 0.006, 0.5, Vector3(0.09, 0.25, 0.0), "legno", Vector3.ZERO, 5))
	g.add_child(scatola(Vector3(0.012, 0.06, 0.03), Vector3(0.09, 0.51, 0.0), "ferro"))
	return r


static func tessitura() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.28)
	r.add_child(c)
	var lx := 0.72
	var lz := 0.52
	var h := 0.36
	casa_muri(c, lx, lz, h, 251)
	porta_z(c, -0.16, lz * 0.5, 0.13, 0.23)
	finestra_z(c, 0.18, 0.32, lz * 0.5, 0.11, 0.1, true)
	sottotetto(c, lx, lz, 0.07 + h, 22.0)
	tetto(c, lx + 0.06, lz, 0.07 + h, 22.0, 251)
	# telaio verticale con la tela a righe, matasse, stoffe stese
	var t := Vector3(0.0, 0, 0.5)
	for x in [-0.18, 0.18]:
		r.add_child(cilindro(0.012, 0.012, 0.4, t + Vector3(x, 0.2, 0), "legno_vecchio", Vector3.ZERO, 6))
	r.add_child(cilindro(0.012, 0.012, 0.4, t + Vector3(0, 0.39, 0), "legno", Vector3(0, 0, 90), 6))
	for k in 6:
		r.add_child(scatola(Vector3(0.34, 0.04, 0.006), t + Vector3(0, 0.34 - k * 0.04, 0), "stoffa_rossa" if k % 2 == 0 else "lana"))
	for k in 5:
		r.add_child(sfera(0.014, t + Vector3(-0.14 + k * 0.07, 0.08, 0), "argilla"))
	for p in [Vector3(0.55, 0, 0.0), Vector3(0.6, 0, 0.2)]:
		r.add_child(sfera(0.05, p + Vector3(0, 0.04, 0), "lana", Vector3(1.2, 0.8, 1)))
	r.add_child(cilindro(0.008, 0.008, 0.5, Vector3(0.55, 0.3, -0.35), "legno_vecchio", Vector3(0, 0, 90), 5))
	r.add_child(scatola(Vector3(0.22, 0.2, 0.004), Vector3(0.48, 0.2, -0.35), "stoffa"))
	r.add_child(scatola(Vector3(0.2, 0.18, 0.004), Vector3(0.7, 0.21, -0.35), "stoffa_rossa"))
	return r


## Agorà (3x3): piazza lastricata con un portico a colonne su due lati, bancarelle, statua e anfore.
static func agora() -> Node3D:
	var r := Node3D.new()
	r.add_child(scatola(Vector3(2.7, 0.04, 2.7), Vector3(0, 0.02, 0), "pietra"))
	var rng := _rng(260)
	for k in 40:
		r.add_child(scatola(Vector3(rng.randf_range(0.2, 0.4), 0.006, rng.randf_range(0.2, 0.4)),
			Vector3(rng.randf_range(-1.2, 1.2), 0.043, rng.randf_range(-1.2, 1.2)), "blocco", Vector3(0, rng.randf_range(-5, 5), 0)))
	# portico (stoa) lungo il fondo (-Z) e il lato sinistro (-X)
	var h := 0.48
	for lato in 2:
		var stoa := Node3D.new()
		stoa.position = Vector3(0, 0.04, -1.05) if lato == 0 else Vector3(-1.05, 0.04, 0.15)
		stoa.rotation_degrees.y = 0 if lato == 0 else 90
		r.add_child(stoa)
		var lung := 2.5 if lato == 0 else 2.2
		stoa.add_child(scatola(Vector3(lung, 0.04, 0.5), Vector3(0, 0.02, 0), "marmo"))
		stoa.add_child(scatola(Vector3(lung, h, 0.06), Vector3(0, 0.04 + h * 0.5, -0.22), "intonaco"))
		var n := 9 if lato == 0 else 8
		for k in n:
			var x := -lung * 0.5 + 0.1 + k * (lung - 0.2) / (n - 1)
			stoa.add_child(cilindro(0.04, 0.034, h, Vector3(x, 0.04 + h * 0.5, 0.2), "marmo", Vector3.ZERO, 12))
			stoa.add_child(scatola(Vector3(0.09, 0.025, 0.09), Vector3(x, 0.04 + h + 0.012, 0.2), "marmo"))
		stoa.add_child(scatola(Vector3(lung + 0.04, 0.05, 0.52), Vector3(0, 0.04 + h + 0.05, 0), "marmo"))
		for k in int(lung / 0.1):
			stoa.add_child(scatola(Vector3(0.03, 0.035, 0.01), Vector3(-lung * 0.5 + 0.05 + k * 0.1, 0.04 + h + 0.05, 0.265), "persiana" if k % 2 else "intonaco_sporco"))
		var t := Node3D.new()
		t.position = Vector3(0, 0.04 + h + 0.075, 0)
		stoa.add_child(t)
		tetto(t, lung, 0.5, 0.0, 18.0, 261 + lato)
		# merci sotto il portico
		for k in 4:
			stoa.add_child(anfora(Vector3(-lung * 0.4 + k * 0.5, 0.04, -0.08), 1.2))
	# bancarelle con le tende colorate
	var tende := ["stoffa_rossa", "stoffa", "geranio", "persiana"]
	for i in 4:
		var b := Node3D.new()
		b.position = Vector3(-0.25 + (i % 2) * 0.75, 0.04, -0.15 + (i / 2) * 0.72)
		r.add_child(b)
		b.add_child(scatola(Vector3(0.36, 0.1, 0.2), Vector3(0, 0.05, 0), "legno"))
		for x in [-0.17, 0.17]:
			b.add_child(cilindro(0.008, 0.008, 0.3, Vector3(x, 0.15, -0.09), "legno_vecchio", Vector3.ZERO, 5))
		b.add_child(scatola(Vector3(0.42, 0.012, 0.3), Vector3(0, 0.29, 0.0), tende[i], Vector3(-14, 0, 0)))
		var merce: String = ["olive", "pane", "agrumi", "formaggio"][i]
		b.add_child(cesta(Vector3(-0.08, 0.1, 0), merce, 0.8))
		b.add_child(cesta(Vector3(0.09, 0.1, 0.02), ["uva", "pesce", "cipolle", "olive"][i], 0.8))
	# statua su piedistallo al centro della piazza
	var s := Vector3(0.75, 0.04, 0.95)
	r.add_child(scatola(Vector3(0.2, 0.18, 0.2), s + Vector3(0, 0.09, 0), "marmo"))
	var statua := portatore("")
	statua.position = s + Vector3(0, 0.18, 0)
	statua.scale = Vector3.ONE * 0.95
	r.add_child(statua)
	_tutto_marmo(statua)
	# fontana in un angolo
	r.add_child(cilindro(0.18, 0.2, 0.08, Vector3(-0.7, 0.08, 0.95), "marmo", Vector3.ZERO, 18))
	r.add_child(cilindro(0.15, 0.15, 0.005, Vector3(-0.7, 0.125, 0.95), "acqua_pozzo", Vector3.ZERO, 18))
	return r


static func _tutto_marmo(n: Node) -> void:
	if n is MeshInstance3D:
		(n as MeshInstance3D).material_override = materiale("marmo")
	for k in n.get_children():
		_tutto_marmo(k)


# =================================================================== DIFESA (step 12)

## Guardia greca: elmo di bronzo con cresta, scudo rotondo al braccio sinistro, lancia nella destra.
static func guardia() -> Node3D:
	var r := portatore("")
	var corpo: Node3D = r.get_node("corpo")
	var anca := 0.2
	corpo.add_child(sfera(0.08, Vector3(0, anca + 0.27, -0.005), "bronzo", Vector3(1, 0.75, 1.05)))
	corpo.add_child(scatola(Vector3(0.016, 0.06, 0.13), Vector3(0, anca + 0.34, -0.01), "bandiera_rossa"))
	corpo.add_child(cilindro(0.088, 0.088, 0.03, Vector3(0, anca + 0.12, 0), "bronzo", Vector3.ZERO, 10))
	var bs: Node3D = corpo.get_node("braccio_s")
	var scudo := cilindro(0.085, 0.085, 0.014, Vector3(-0.02, -0.07, 0.04), "bronzo", Vector3(0, 0, 90), 16)
	bs.add_child(scudo)
	bs.add_child(cilindro(0.03, 0.03, 0.016, Vector3(-0.03, -0.07, 0.04), "bandiera_rossa", Vector3(0, 0, 90), 10))
	var bd: Node3D = corpo.get_node("braccio_d")
	bd.add_child(cilindro(0.007, 0.007, 0.5, Vector3(0, 0.06, 0.02), "legno", Vector3.ZERO, 5))
	bd.add_child(cilindro(0.016, 0.0, 0.06, Vector3(0, 0.34, 0.02), "ferro", Vector3.ZERO, 6))
	r.set_meta("carico", "lancia")
	return r


## Castello (3x3): mura di pietra con quattro torri agli angoli, mastio al centro, porta e stendardi.
static func castello() -> Node3D:
	var r := Node3D.new()
	var lato := 2.3
	var h := 0.5
	r.add_child(scatola(Vector3(lato + 0.3, 0.06, lato + 0.3), Vector3(0, 0.03, 0), "pietra"))
	# mura con merli
	for i in 4:
		var m := Node3D.new()
		m.rotation_degrees.y = i * 90
		r.add_child(m)
		m.add_child(scatola(Vector3(lato, h, 0.16), Vector3(0, 0.06 + h * 0.5, lato * 0.5), "pietra_vista"))
		for k in 11:
			m.add_child(scatola(Vector3(0.1, 0.08, 0.17), Vector3(-lato * 0.5 + 0.1 + k * (lato - 0.2) / 10, 0.06 + h + 0.04, lato * 0.5), "blocco"))
	# torri d'angolo
	for x in [-1, 1]:
		for z in [-1, 1]:
			var p := Vector3(x * lato * 0.5, 0, z * lato * 0.5)
			r.add_child(cilindro(0.24, 0.27, h + 0.3, p + Vector3(0, 0.06 + (h + 0.3) * 0.5, 0), "pietra_vista", Vector3.ZERO, 16))
			for k in 8:
				var a := k * TAU / 8
				r.add_child(scatola(Vector3(0.09, 0.08, 0.09), p + Vector3(cos(a) * 0.22, 0.06 + h + 0.34, sin(a) * 0.22), "blocco", Vector3(0, -rad_to_deg(a), 0)))
			r.add_child(cilindro(0.29, 0.0, 0.32, p + Vector3(0, 0.06 + h + 0.54, 0), "tegola", Vector3.ZERO, 16))
	# mastio al centro
	var c := Node3D.new()
	c.position = Vector3(-0.15, 0.06, -0.15)
	r.add_child(c)
	c.add_child(scatola(Vector3(0.8, 0.95, 0.8), Vector3(0, 0.475, 0), "pietra_vista"))
	for i in 4:
		for k in 5:
			var a := i * PI * 0.5
			var o := Vector3(-0.32 + k * 0.16, 0.99, 0.4).rotated(Vector3.UP, a)
			c.add_child(scatola(Vector3(0.1, 0.08, 0.1), o, "blocco", Vector3(0, rad_to_deg(a), 0)))
	finestra_z(c, 0.0, 0.7, 0.4, 0.07, 0.12)
	finestra_x(c, 0.0, 0.7, 0.4, 0.07, 0.12)
	c.add_child(cilindro(0.012, 0.012, 0.5, Vector3(0.2, 1.25, 0.2), "legno", Vector3.ZERO, 6))
	c.add_child(scatola(Vector3(0.006, 0.18, 0.26), Vector3(0.2, 1.4, 0.34), "stoffa"))
	# porta ad arco sul lato in vista e cortile
	r.add_child(scatola(Vector3(0.4, 0.38, 0.06), Vector3(0.45, 0.25, lato * 0.5 + 0.06), "legno_scuro"))
	r.add_child(scatola(Vector3(0.52, 0.06, 0.08), Vector3(0.45, 0.47, lato * 0.5 + 0.07), "blocco"))
	for k in 3:
		r.add_child(cassa(Vector3(0.55 + k * 0.12, 0.06, 0.55), k * 20))
	r.add_child(barile(Vector3(-0.7, 0.06, 0.6), 1.1))
	return r


# =================================================================== SOLDATI (step 13)

## Guerriero brettio: pelliccia, berretto di pelo, scudo di legno ovale e spada corta.
static func brettio(squadra := "bandiera_rossa") -> Node3D:
	var r := portatore("", squadra, "pelliccia")
	var corpo: Node3D = r.get_node("corpo")
	var anca := 0.2
	corpo.add_child(sfera(0.082, Vector3(0, anca + 0.29, -0.01), "pelliccia", Vector3(1, 0.6, 1)))
	var bs: Node3D = corpo.get_node("braccio_s")
	bs.add_child(sfera(0.09, Vector3(-0.025, -0.07, 0.03), "legno", Vector3(0.2, 1.2, 0.85)))
	bs.add_child(sfera(0.025, Vector3(-0.04, -0.07, 0.03), "ferro"))
	var bd: Node3D = corpo.get_node("braccio_d")
	bd.add_child(scatola(Vector3(0.012, 0.02, 0.2), Vector3(0, -0.14, 0.1), "ferro"))
	bd.add_child(scatola(Vector3(0.04, 0.015, 0.02), Vector3(0, -0.14, 0.0), "legno_scuro"))
	r.set_meta("carico", "spada")
	return r


## Colpo in combattimento: il braccio armato affonda in avanti, lo scudo si alza.
static func posa_lotta(modello: Node3D, fotogramma: int, totale: int) -> void:
	var t := float(fotogramma) / totale * TAU
	var corpo: Node3D = modello.get_node("corpo")
	var bd: Node3D = corpo.get_node("braccio_d")
	var bs: Node3D = corpo.get_node("braccio_s")
	var affondo := maxf(0.0, sin(t))
	bd.rotation = Vector3(-1.0 - affondo * 0.9, 0, 0.2)
	bs.rotation = Vector3(-0.9 + 0.2 * sin(t * 2.0), 0, -0.35)
	corpo.rotation.x = 0.12 + affondo * 0.15
	corpo.position.y = 0.0
	(corpo.get_node("gamba_s") as Node3D).rotation.x = 0.35
	(corpo.get_node("gamba_d") as Node3D).rotation.x = -0.25


## Fascio di armi: lance, uno scudo rotondo e un elmo.
static func fascio_armi() -> Node3D:
	var n := Node3D.new()
	for k in 3:
		n.add_child(cilindro(0.006, 0.006, 0.34, Vector3(0, 0.015 + k * 0.012, -0.02 + k * 0.02), "legno", Vector3(0, 20, 90), 5))
		n.add_child(cilindro(0.012, 0.0, 0.04, Vector3(0.18, 0.015 + k * 0.012, 0.045 - k * 0.02), "ferro", Vector3(0, 20, -90), 5))
	n.add_child(cilindro(0.07, 0.07, 0.012, Vector3(-0.04, 0.05, 0.04), "bronzo", Vector3(70, 0, 0), 14))
	n.add_child(sfera(0.04, Vector3(0.06, 0.03, -0.05), "bronzo", Vector3(1, 0.8, 1.1)))
	return n


static func armaiolo() -> Node3D:
	var r := fabbro()
	# rastrelliera di lance e scudi appesi al muro davanti
	for k in 5:
		r.add_child(cilindro(0.006, 0.006, 0.5, Vector3(0.38 + k * 0.05, 0.25, 0.42), "legno", Vector3(0, 0, -8), 5))
		r.add_child(cilindro(0.012, 0.0, 0.05, Vector3(0.38 + k * 0.05 - 0.035, 0.52, 0.42), "ferro", Vector3(0, 0, -8), 5))
	for k in 2:
		r.add_child(cilindro(0.08, 0.08, 0.014, Vector3(0.62 + k * 0.05, 0.12, 0.2 + k * 0.18), "bronzo", Vector3(0, 0, 80), 16))
	return r


static func caserma() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.3, 0, -0.3)
	r.add_child(c)
	var lx := 0.62
	var lz := 0.5
	var h := 0.38
	casa_muri(c, lx, lz, h, 271, "pietra_vista")
	porta_z(c, 0.08, lz * 0.5, 0.15, 0.25)
	sottotetto(c, lx, lz, 0.07 + h, 22.0)
	tetto(c, lx + 0.06, lz, 0.07 + h, 22.0, 271)
	c.add_child(cilindro(0.01, 0.01, 0.5, Vector3(lx * 0.5 - 0.05, 0.07 + h + 0.25, lz * 0.5 - 0.05), "legno", Vector3.ZERO, 6))
	c.add_child(scatola(Vector3(0.006, 0.16, 0.22), Vector3(lx * 0.5 - 0.05, 0.07 + h + 0.42, lz * 0.5 + 0.06), "stoffa"))
	# campo d'addestramento: palo con lo scudo bersaglio, rastrelliera, opliti che si esercitano
	r.add_child(scatola(Vector3(0.75, 0.01, 0.55), Vector3(0.25, 0.005, 0.4), "terra"))
	r.add_child(cilindro(0.025, 0.025, 0.36, Vector3(0.5, 0.18, 0.35), "legno_vecchio", Vector3.ZERO, 8))
	r.add_child(cilindro(0.08, 0.08, 0.014, Vector3(0.5, 0.28, 0.39), "paglia", Vector3(90, 0, 0), 14))
	r.add_child(cilindro(0.03, 0.03, 0.016, Vector3(0.5, 0.28, 0.4), "bandiera_rossa", Vector3(90, 0, 0), 10))
	for k in 2:
		var o := guardia()
		o.position = Vector3(0.05 + k * 0.28, 0, 0.55 - k * 0.15)
		o.rotation_degrees.y = 150 - k * 60
		o.scale = Vector3.ONE * 0.95
		r.add_child(o)
	r.add_child(fascio_armi())
	r.get_child(r.get_child_count() - 1).position = Vector3(-0.6, 0, 0.45)
	return r


## Torre dei Brettii: legno su base di pietra grezza, palizzata e pelli stese.
static func torre_brettia() -> Node3D:
	var r := Node3D.new()
	r.add_child(cilindro(0.42, 0.46, 0.18, Vector3(0, 0.09, 0), "roccia_massi", Vector3.ZERO, 10))
	for k in 10:
		var a := k * TAU / 10
		r.add_child(cilindro(0.04, 0.045, 0.75, Vector3(cos(a) * 0.3, 0.55, sin(a) * 0.3), "corteccia", Vector3.ZERO, 7))
	r.add_child(cilindro(0.38, 0.38, 0.05, Vector3(0, 0.95, 0), "legno_vecchio", Vector3.ZERO, 10))
	for k in 12:
		var a := k * TAU / 12
		r.add_child(cilindro(0.025, 0.02, 0.18, Vector3(cos(a) * 0.36, 1.05, sin(a) * 0.36), "corteccia", Vector3.ZERO, 5))
	r.add_child(cilindro(0.46, 0.0, 0.4, Vector3(0, 1.32, 0), "paglia", Vector3.ZERO, 12))
	r.add_child(scatola(Vector3(0.16, 0.26, 0.04), Vector3(0.0, 0.31, 0.3), "buio"))
	# palizzata di pali appuntiti davanti, pelli stese, fuoco
	for k in 9:
		var x := -0.75 + k * 0.08
		r.add_child(cilindro(0.025, 0.0, 0.32, Vector3(x, 0.16, 0.6), "corteccia", Vector3.ZERO, 6))
	r.add_child(scatola(Vector3(0.2, 0.004, 0.16), Vector3(0.55, 0.2, -0.2), "pelliccia", Vector3(0, 0, 70)))
	r.add_child(cilindro(0.01, 0.01, 0.3, Vector3(0.55, 0.15, -0.3), "legno_vecchio", Vector3.ZERO, 5))
	for k in 5:
		r.add_child(cilindro(0.012, 0.012, 0.12, Vector3(0.5 + 0.03 * cos(k), 0.02, 0.45 + 0.03 * sin(k)), "corteccia", Vector3(0, k * 36, 90), 5))
	r.add_child(sfera(0.03, Vector3(0.5, 0.04, 0.45), "brace"))
	r.add_child(cilindro(0.012, 0.012, 0.7, Vector3(-0.3, 1.4, -0.1), "legno", Vector3.ZERO, 6))
	r.add_child(scatola(Vector3(0.006, 0.16, 0.22), Vector3(-0.3, 1.62, 0.02), "bandiera_rossa"))
	return r


# =================================================================== MONUMENTI DI MONTELEONE (step V2)

## Masso: mezza sfera schiacciata appoggiata a terra (niente sotto il piano).
static func _masso(pos: Vector3, raggio: float, scala: Vector3, mat := "roccia_chiara", rot_y := 0.0) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = raggio
	sm.height = raggio
	sm.is_hemisphere = true
	sm.radial_segments = 9
	sm.rings = 4
	mi.mesh = sm
	mi.position = pos
	mi.scale = scala
	mi.rotation_degrees.y = rot_y
	mi.material_override = materiale(mat)
	return mi


## Muro da un punto a un altro (alla quota di `da`), con cornice e merli.
static func _muro(r: Node3D, da: Vector3, a: Vector3, h: float, sp: float, mat: String, merli := true, mat_merli := "blocco") -> void:
	var d := a - da
	d.y = 0.0
	var lung := d.length()
	var n := Node3D.new()
	n.position = Vector3((da.x + a.x) * 0.5, da.y, (da.z + a.z) * 0.5)
	n.rotation.y = atan2(-d.z, d.x)
	r.add_child(n)
	n.add_child(scatola(Vector3(lung, h, sp), Vector3(0, h * 0.5, 0), mat))
	n.add_child(scatola(Vector3(lung + 0.02, 0.03, sp + 0.04), Vector3(0, h - 0.015, 0), mat_merli))
	if merli:
		var nm := maxi(2, int(lung / 0.13))
		for k in nm:
			var x := -lung * 0.5 + (k + 0.5) * lung / nm
			n.add_child(scatola(Vector3(lung / nm * 0.55, 0.08, sp * 0.5), Vector3(x, h + 0.04, 0.0), mat_merli))


## Torre cilindrica: scarpa e cordone (facoltativi), beccatelli, merli o tetto a cono, feritoie.
static func _torre_tonda(r: Node3D, pos: Vector3, rg: float, h: float, mat: String, mat_merli := "blocco", beccatelli := true, cono := "", scarpa := 0.0) -> void:
	if scarpa > 0.0:
		r.add_child(cilindro(rg + scarpa, rg, h * 0.35, pos + Vector3(0, h * 0.175, 0), mat, Vector3.ZERO, 22))
		r.add_child(cilindro(rg + 0.025, rg + 0.025, 0.035, pos + Vector3(0, h * 0.35, 0), mat_merli, Vector3.ZERO, 22))
	r.add_child(cilindro(rg, rg, h, pos + Vector3(0, h * 0.5, 0), mat, Vector3.ZERO, 22))
	var cima := h
	var rm := rg
	if beccatelli:
		var nb := maxi(10, int(rg * 34))
		for k in nb:
			var a := k * TAU / nb
			r.add_child(scatola(Vector3(0.03, 0.06, 0.06), pos + Vector3(cos(a) * (rg + 0.015), h - 0.03, sin(a) * (rg + 0.015)), mat_merli, Vector3(0, -rad_to_deg(a) - 90, 0)))
		r.add_child(cilindro(rg + 0.05, rg + 0.05, 0.1, pos + Vector3(0, h + 0.05, 0), mat, Vector3.ZERO, 22))
		cima = h + 0.1
		rm = rg + 0.035
	else:
		r.add_child(cilindro(rg + 0.02, rg + 0.02, 0.03, pos + Vector3(0, h + 0.015, 0), mat_merli, Vector3.ZERO, 22))
		cima = h + 0.03
	if cono == "":
		var nm := maxi(6, int(rg * 20))
		for k in nm:
			var a := (k + 0.5) * TAU / nm
			r.add_child(scatola(Vector3(TAU * rm / nm * 0.55, 0.08, 0.06), pos + Vector3(cos(a) * rm, cima + 0.04, sin(a) * rm), mat_merli, Vector3(0, -rad_to_deg(a) - 90, 0)))
	else:
		r.add_child(cilindro(rm + 0.05, 0.0, rm * 1.3, pos + Vector3(0, cima + rm * 0.65, 0), cono, Vector3.ZERO, 22))
	# feritoie verso chi guarda
	for k in 3:
		var a := deg_to_rad(15.0 + k * 30.0)
		r.add_child(scatola(Vector3(0.025, 0.11, 0.02), pos + Vector3(cos(a) * rg, h * (0.5 + 0.15 * (k % 2)), sin(a) * rg), "buio", Vector3(0, -rad_to_deg(a) - 90, 0)))


## Arco a tutto sesto: due piedritti e cunei (luce lungo X locale, spessore lungo Z locale).
static func _arco(r: Node3D, pos: Vector3, larg: float, h: float, sp: float, mat: String, rot_y := 0.0, mat_cunei := "blocco") -> Node3D:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot_y
	r.add_child(n)
	var pw := larg * 0.28
	for lato in [-1, 1]:
		n.add_child(scatola(Vector3(pw, h, sp), Vector3(lato * (larg + pw) * 0.5, h * 0.5, 0), mat))
		n.add_child(scatola(Vector3(pw + 0.02, 0.025, sp + 0.02), Vector3(lato * (larg + pw) * 0.5, h, 0), mat_cunei))
	var raggio := (larg + pw) * 0.5
	var nc := 9
	for k in nc:
		var a := (k + 0.5) * PI / nc
		n.add_child(scatola(Vector3(pw, PI * raggio / nc * 1.05, sp), Vector3(cos(a) * raggio, h + sin(a) * raggio, 0), mat_cunei if k % 2 == 0 else mat, Vector3(0, 0, rad_to_deg(a))))
	return n


## Colonna con fusto rastremato e capitello dorico (echino + abaco).
static func _colonna(r: Node3D, pos: Vector3, h: float, rg: float, mat := "marmo", capitello := true) -> void:
	r.add_child(cilindro(rg, rg * 0.82, h, pos + Vector3(0, h * 0.5, 0), mat, Vector3.ZERO, 14))
	if capitello:
		r.add_child(cilindro(rg * 0.85, rg * 1.35, rg * 0.6, pos + Vector3(0, h + rg * 0.3, 0), mat, Vector3.ZERO, 14))
		r.add_child(scatola(Vector3(rg * 2.9, rg * 0.45, rg * 2.9), pos + Vector3(0, h + rg * 0.82, 0), mat))


static func _croce(r: Node3D, pos: Vector3, s := 1.0, mat := "ferro") -> void:
	r.add_child(scatola(Vector3(0.016, 0.14, 0.016) * s, pos + Vector3(0, 0.07 * s, 0), mat))
	r.add_child(scatola(Vector3(0.08, 0.016, 0.016) * s, pos + Vector3(0, 0.095 * s, 0), mat))


## Tetto a una falda: alto dietro (-Z locale), basso davanti (+Z locale); base_y è la gronda.
static func _falda(r: Node3D, larg: float, prof: float, base_y: float, pendenza: float, pos := Vector3.ZERO, rot_y := 0.0, seme := 1) -> void:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot_y
	r.add_child(n)
	var rng := _rng(seme)
	var ang := deg_to_rad(pendenza)
	var lung := (prof + 0.08) / cos(ang)
	var alt := (prof + 0.08) * tan(ang)
	var f := Node3D.new()
	f.position = Vector3(0, base_y + alt * 0.5, 0.04)
	f.rotation.x = ang
	n.add_child(f)
	f.add_child(scatola(Vector3(larg + 0.08, 0.03, lung), Vector3.ZERO, "tegola_scura"))
	var nc := int((larg + 0.06) / 0.07)
	for k in nc:
		var x := -larg * 0.5 - 0.02 + (k + 0.5) * (larg + 0.04) / nc
		var mat: String = ["tegola", "tegola_b", "tegola_c"][rng.randi_range(0, 2)]
		var coppo := cilindro(0.03, 0.027, lung, Vector3(x, 0.02, 0), mat, Vector3(90, 0, 0), 8)
		coppo.scale = Vector3(1, 1, 0.55)
		f.add_child(coppo)


## Rete stesa ad asciugare fra due pali (piano della rete perpendicolare a Z locale).
static func _rete(r: Node3D, pos: Vector3, larg := 0.4, rot_y := 0.0) -> void:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot_y
	r.add_child(n)
	for x in [-larg * 0.5 - 0.02, larg * 0.5 + 0.02]:
		n.add_child(cilindro(0.012, 0.012, 0.36, Vector3(x, 0.18, 0), "legno_vecchio", Vector3.ZERO, 6))
	n.add_child(scatola(Vector3(larg, 0.26, 0.006), Vector3(0, 0.2, 0), "rete"))
	for k in 6:
		n.add_child(scatola(Vector3(0.004, 0.26, 0.008), Vector3(-larg * 0.5 + 0.02 + k * (larg - 0.04) / 5, 0.2, 0.004), "corda"))
	for k in 4:
		n.add_child(scatola(Vector3(larg, 0.004, 0.008), Vector3(0, 0.1 + k * 0.065, 0.004), "corda"))
	# galleggianti di sughero sul bordo
	for k in 5:
		n.add_child(sfera(0.014, Vector3(-larg * 0.4 + k * larg * 0.2, 0.33, 0.01), "bandiera_rossa"))


## Barca da pesca (prua verso +X locale).
static func _barca(pos: Vector3, rot := 0.0, col := "persiana", scala := 1.0) -> Node3D:
	var b := Node3D.new()
	b.position = pos
	b.rotation_degrees.y = rot
	b.scale = Vector3.ONE * scala
	b.add_child(sfera(0.13, Vector3(0, 0.06, 0), "legno", Vector3(2.6, 0.62, 1.0)))
	b.add_child(sfera(0.115, Vector3(0, 0.085, 0), "legno_scuro", Vector3(2.5, 0.32, 0.9)))
	for z in [-0.12, 0.12]:
		b.add_child(scatola(Vector3(0.6, 0.022, 0.03), Vector3(0, 0.11, z), col))
	for x in [0.06, -0.12]:
		b.add_child(scatola(Vector3(0.03, 0.012, 0.22), Vector3(x, 0.115, 0), "legno_chiaro"))
	b.add_child(cilindro(0.012, 0.004, 0.1, Vector3(0.33, 0.15, 0), "legno", Vector3(0, 0, -25), 5))
	return b


static func _cipresso(r: Node3D, pos: Vector3, h := 0.7) -> void:
	r.add_child(cilindro(0.018, 0.015, 0.1, pos + Vector3(0, 0.05, 0), "corteccia", Vector3.ZERO, 6))
	r.add_child(sfera(0.075, pos + Vector3(0, 0.06 + h * 0.5, 0), "foglie_scure", Vector3(1, h / 0.15, 1)))
	r.add_child(sfera(0.06, pos + Vector3(0.02, 0.06 + h * 0.45, 0.025), "foglie", Vector3(1, h / 0.15, 1)))


static func _ciuffo(r: Node3D, pos: Vector3, s := 1.0) -> void:
	r.add_child(sfera(0.035 * s, pos + Vector3(0, 0.01, 0), "macchia", Vector3(1.3, 0.6, 1.1)))
	r.add_child(sfera(0.022 * s, pos + Vector3(0.02 * s, 0.02, 0.01 * s), "foglie_chiare", Vector3(1.2, 0.7, 1.0)))


## Specchio di mare: dischi piatti (x, z, raggio) con un filo di schiuma sul bordo.
static func _mare(r: Node3D, dischi: Array) -> void:
	for d in dischi:
		var v: Vector3 = d
		r.add_child(cilindro(v.z + 0.035, v.z + 0.035, 0.008, Vector3(v.x, 0.004, v.y), "intonaco_bianco", Vector3.ZERO, 16))
	for d in dischi:
		var v: Vector3 = d
		r.add_child(cilindro(v.z, v.z, 0.014, Vector3(v.x, 0.007, v.y), "mare", Vector3.ZERO, 16))


## Riva di sabbia (o altro): dischi (x, z, raggio) appena più alti del mare.
static func _riva(r: Node3D, dischi: Array, mat := "sabbia") -> void:
	for d in dischi:
		var v: Vector3 = d
		r.add_child(cilindro(v.z, v.z + 0.03, 0.02, Vector3(v.x, 0.01, v.y), mat, Vector3.ZERO, 14))


## Apertura ad arco scura su una facciata rivolta verso +Z.
static func _vano_arco_z(r: Node3D, x: float, y: float, zf: float, w: float, h: float, cornice := "marmo") -> void:
	r.add_child(scatola(Vector3(w + 0.03, h, 0.012), Vector3(x, y + h * 0.5, zf + 0.003), cornice))
	r.add_child(cilindro(w * 0.5 + 0.015, w * 0.5 + 0.015, 0.012, Vector3(x, y + h, zf + 0.003), cornice, Vector3(90, 0, 0), 14))
	r.add_child(scatola(Vector3(w, h, 0.014), Vector3(x, y + h * 0.5, zf + 0.006), "buio"))
	r.add_child(cilindro(w * 0.5, w * 0.5, 0.014, Vector3(x, y + h, zf + 0.006), "buio", Vector3(90, 0, 0), 14))


## Apertura ad arco scura su una facciata rivolta verso +X.
static func _vano_arco_x(r: Node3D, z: float, y: float, xf: float, w: float, h: float, cornice := "marmo") -> void:
	r.add_child(scatola(Vector3(0.012, h, w + 0.03), Vector3(xf + 0.003, y + h * 0.5, z), cornice))
	r.add_child(cilindro(w * 0.5 + 0.015, w * 0.5 + 0.015, 0.012, Vector3(xf + 0.003, y + h, z), cornice, Vector3(0, 0, 90), 14))
	r.add_child(scatola(Vector3(0.014, h, w), Vector3(xf + 0.006, y + h * 0.5, z), "buio"))
	r.add_child(cilindro(w * 0.5, w * 0.5, 0.014, Vector3(xf + 0.006, y + h, z), "buio", Vector3(0, 0, 90), 14))


## Rosone: disco di marmo con vetri colorati e raggi.
static func _rosone(r: Node3D, pos: Vector3, rg: float) -> void:
	r.add_child(cilindro(rg, rg, 0.02, pos, "marmo", Vector3(90, 0, 0), 18))
	r.add_child(cilindro(rg * 0.78, rg * 0.78, 0.024, pos, "persiana", Vector3(90, 0, 0), 18))
	for k in 6:
		r.add_child(scatola(Vector3(0.008, rg * 1.6, 0.03), pos, "marmo", Vector3(0, 0, k * 30)))
	r.add_child(cilindro(rg * 0.22, rg * 0.22, 0.032, pos, "geranio", Vector3(90, 0, 0), 10))


## Portico ad archi lungo X locale (aperto verso +Z locale), falda appoggiata al muro dietro.
static func _portico_archi(r: Node3D, pos: Vector3, lung: float, n: int, h: float, rot_y: float, seme: int, prof := 0.28) -> void:
	var p := Node3D.new()
	p.position = pos
	p.rotation_degrees.y = rot_y
	r.add_child(p)
	var s := lung / n
	p.add_child(scatola(Vector3(lung + 0.06, 0.04, prof + 0.04), Vector3(0, 0.02, -prof * 0.5), "marmo"))
	for k in n + 1:
		_colonna(p, Vector3(-lung * 0.5 + k * s, 0.04, 0), h, 0.028, "marmo")
	var ya := 0.04 + h + 0.03
	var ra := s * 0.5
	for k in n:
		var xc := -lung * 0.5 + (k + 0.5) * s
		for j in 7:
			var a := (j + 0.5) * PI / 7
			p.add_child(scatola(Vector3(0.035, PI * ra / 7 * 1.1, 0.06), Vector3(xc + cos(a) * ra, ya + sin(a) * ra, 0), "intonaco_bianco", Vector3(0, 0, rad_to_deg(a))))
	# pennacchi fra un arco e l'altro, a fette
	for k in n + 1:
		var x := -lung * 0.5 + k * s
		for j in 6:
			var yy := (j + 0.5) * ra / 6
			var w := 2.0 * (ra - sqrt(ra * ra - yy * yy)) + 0.03
			p.add_child(scatola(Vector3(w, ra / 6 + 0.003, 0.05), Vector3(x, ya + yy, 0), "intonaco_bianco"))
	p.add_child(scatola(Vector3(lung + 0.04, 0.06, 0.07), Vector3(0, ya + ra + 0.03, 0), "intonaco_bianco"))
	p.add_child(scatola(Vector3(lung + 0.06, 0.02, 0.09), Vector3(0, ya + ra + 0.07, 0), "marmo"))
	_falda(p, lung + 0.04, prof, ya + ra + 0.08, 22.0, Vector3(0, 0, -prof * 0.5), 0.0, seme)


static func _tonno(pos: Vector3, rot := 0.0) -> Node3D:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot
	n.add_child(sfera(0.05, Vector3(0, 0.045, 0), "spada", Vector3(3.0, 0.9, 0.9)))
	n.add_child(sfera(0.045, Vector3(0.01, 0.035, 0), "pesce", Vector3(2.7, 0.6, 0.85)))
	n.add_child(scatola(Vector3(0.012, 0.1, 0.05), Vector3(-0.17, 0.05, 0), "spada"))
	n.add_child(scatola(Vector3(0.05, 0.035, 0.008), Vector3(0.0, 0.09, 0), "spada", Vector3(0, 0, 30)))
	return n


static func _ancora_nave(pos: Vector3, rot := 0.0) -> Node3D:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot
	n.add_child(scatola(Vector3(0.24, 0.02, 0.02), Vector3(0, 0.012, 0), "ferro"))
	n.add_child(scatola(Vector3(0.02, 0.02, 0.14), Vector3(0.1, 0.012, 0), "ferro"))
	for s in [-1, 1]:
		n.add_child(scatola(Vector3(0.08, 0.02, 0.02), Vector3(-0.1, 0.012, s * 0.035), "ferro", Vector3(0, s * 40, 0)))
	n.add_child(cilindro(0.02, 0.02, 0.008, Vector3(0.13, 0.012, 0), "ferro", Vector3(0, 0, 90), 8))
	return n


## Statua di marmo (una figura in posa).
static func _statua(pos: Vector3, scala := 1.0, rot := 0.0) -> Node3D:
	var s := portatore("")
	s.position = pos
	s.scale = Vector3.ONE * scala
	s.rotation_degrees.y = rot
	_tutto_marmo(s)
	return s


## Mura greche di Hipponion: grandi blocchi squadrati, torre semicircolare, porta con architrave.
static func mura_greche() -> Node3D:
	var r := Node3D.new()
	var h := 0.7
	var sp := 0.3
	var z0 := -0.2
	var mat := "blocchi_greci"
	var rng := _rng(301)
	# strada battuta che passa per la porta
	r.add_child(scatola(Vector3(0.36, 0.012, 1.4), Vector3(-0.55, 0.006, 0.4), "terra"))
	for k in 7:
		r.add_child(scatola(Vector3(0.13, 0.01, 0.1), Vector3(-0.61 + (k % 2) * 0.12, 0.014, 0.12 + k * 0.13), "blocco", Vector3(0, k * 7, 0)))
	# zoccolo, cortine ai lati della porta e tratto che torna indietro
	r.add_child(scatola(Vector3(2.4, 0.08, sp + 0.1), Vector3(-0.05, 0.04, z0), "pietra"))
	_muro(r, Vector3(-1.25, 0.08, z0), Vector3(-0.77, 0.08, z0), h, sp, mat)
	_muro(r, Vector3(-0.33, 0.08, z0), Vector3(1.0, 0.08, z0), h, sp, mat)
	_muro(r, Vector3(-1.25, 0.0, -1.25), Vector3(-1.25, 0.0, z0 - sp * 0.5), h + 0.08, sp, mat)
	# tratto in rovina a destra: blocchi che scendono a gradini e blocchi caduti
	for k in 4:
		var hh := h * (0.78 - k * 0.19)
		r.add_child(scatola(Vector3(0.1, hh, sp), Vector3(1.05 + k * 0.1, 0.08 + hh * 0.5, z0), mat))
	for k in 6:
		r.add_child(scatola(Vector3(0.16, 0.09, 0.11), Vector3(0.95 + rng.randf_range(0, 0.35), 0.045, z0 + 0.3 + rng.randf_range(0, 0.45)), mat, Vector3(rng.randf_range(-8, 8), rng.randf_range(0, 60), 0)))
	# porta: stipiti, architrave monolitico, muro e merli sopra, battenti aperti
	var gx := -0.55
	r.add_child(scatola(Vector3(0.44, 0.44, 0.02), Vector3(gx, 0.08 + 0.22, z0 - sp * 0.5 + 0.02), "buio"))
	r.add_child(scatola(Vector3(0.44, 0.012, sp), Vector3(gx, 0.006, z0), "terra"))
	for s in [-1, 1]:
		r.add_child(scatola(Vector3(0.07, 0.46, sp + 0.04), Vector3(gx + s * 0.235, 0.08 + 0.23, z0), "blocco"))
	r.add_child(scatola(Vector3(0.6, 0.11, sp + 0.05), Vector3(gx, 0.08 + 0.46 + 0.055, z0), "blocco"))
	_muro(r, Vector3(-0.77, 0.65, z0), Vector3(-0.33, 0.65, z0), h - 0.57, sp, mat)
	for s in [-1, 1]:
		var cardine := Node3D.new()
		cardine.position = Vector3(gx + s * 0.2, 0.08, z0 + sp * 0.5)
		cardine.rotation_degrees.y = s * 70
		r.add_child(cardine)
		cardine.add_child(scatola(Vector3(0.2, 0.42, 0.025), Vector3(-s * 0.1, 0.21, 0), "legno_scuro"))
		for k in 3:
			cardine.add_child(scatola(Vector3(0.2, 0.015, 0.03), Vector3(-s * 0.1, 0.06 + k * 0.15, 0), "ferro"))
	# torre semicircolare che sporge dalle mura, con una sentinella
	_torre_tonda(r, Vector3(0.4, 0.08, z0 + 0.05), 0.4, 0.95, mat, "blocco", false)
	r.add_child(scatola(Vector3(0.12, 0.2, 0.02), Vector3(0.4, 0.62, z0 + 0.45), "buio"))
	r.add_child(scatola(Vector3(0.16, 0.03, 0.04), Vector3(0.4, 0.735, z0 + 0.45), "blocco"))
	var g := guardia()
	g.position = Vector3(0.45, 0.08 + 0.98, z0 + 0.12)
	g.rotation_degrees.y = 30
	r.add_child(g)
	var g2 := guardia()
	g2.position = Vector3(-1.02, 0.08 + h, z0 - 0.05)
	g2.rotation_degrees.y = 10
	g2.scale = Vector3.ONE * 0.95
	r.add_child(g2)
	# ulivo, cespugli e ciuffi d'erba ai piedi delle mura
	var u := ulivo(4)
	u.position = Vector3(0.95, 0, 0.75)
	u.scale = Vector3.ONE * 0.75
	r.add_child(u)
	for k in 10:
		_ciuffo(r, Vector3(rng.randf_range(-1.2, 1.2), 0.0, z0 + sp * 0.5 + rng.randf_range(0.05, 0.25)), rng.randf_range(0.8, 1.5))
	r.add_child(anfora(Vector3(-0.2, 0.0, 0.25), 1.2))
	r.add_child(anfora(Vector3(-0.12, 0.0, 0.3), 1.1))
	return r


## Tempio di Proserpina: tempio dorico su crepidoma a tre gradini, frontone dipinto, tetto a coppi.
static func tempio_proserpina() -> Node3D:
	var r := Node3D.new()
	var t := Node3D.new()
	t.position = Vector3(-0.05, 0, -0.2)
	t.rotation_degrees.y = -90   # la facciata (+X locale) guarda verso +Z
	r.add_child(t)
	var lx := 1.8
	var lz := 1.15
	for k in 3:
		t.add_child(scatola(Vector3(lx + 0.34 - k * 0.12, 0.05, lz + 0.34 - k * 0.12), Vector3(0, 0.025 + k * 0.05, 0), "marmo" if k == 2 else "blocco"))
	var base := 0.15
	var h := 0.56
	# cella con la porta di bronzo verso la facciata
	var cl := lx - 0.6
	var cw := lz - 0.46
	t.add_child(scatola(Vector3(cl, h, cw), Vector3(-0.04, base + h * 0.5, 0), "intonaco_giallo"))
	var xp := -0.04 + cl * 0.5
	t.add_child(scatola(Vector3(0.02, 0.34, 0.2), Vector3(xp + 0.005, base + 0.17, 0), "bronzo"))
	t.add_child(scatola(Vector3(0.03, 0.035, 0.28), Vector3(xp + 0.012, base + 0.36, 0), "marmo"))
	for s in [-1, 1]:
		t.add_child(scatola(Vector3(0.03, 0.34, 0.035), Vector3(xp + 0.012, base + 0.17, s * 0.12), "marmo"))
	# peristasi: 4 colonne doriche sulla fronte, 7 sui fianchi
	var rg := 0.05
	var nx := 7
	var nz := 4
	for i in nx:
		for j in nz:
			if i == 0 or i == nx - 1 or j == 0 or j == nz - 1:
				_colonna(t, Vector3(-lx * 0.5 + 0.07 + i * (lx - 0.14) / (nx - 1), base, -lz * 0.5 + 0.07 + j * (lz - 0.14) / (nz - 1)), h, rg, "marmo")
	# trabeazione: architrave, fregio a triglifi blu, listello rosso, cornice
	var ye := base + h + rg * 1.05
	t.add_child(scatola(Vector3(lx - 0.02, 0.06, lz - 0.02), Vector3(0, ye + 0.03, 0), "marmo"))
	t.add_child(scatola(Vector3(lx, 0.065, lz), Vector3(0, ye + 0.0925, 0), "marmo"))
	var nf := 9
	for k in nf:
		t.add_child(scatola(Vector3(0.012, 0.055, 0.035), Vector3(lx * 0.5 + 0.004, ye + 0.0925, -lz * 0.5 + 0.03 + k * (lz - 0.06) / (nf - 1)), "persiana"))
	var nl := 15
	for k in nl:
		t.add_child(scatola(Vector3(0.035, 0.055, 0.012), Vector3(-lx * 0.5 + 0.03 + k * (lx - 0.06) / (nl - 1), ye + 0.0925, -lz * 0.5 - 0.004), "persiana"))
	t.add_child(scatola(Vector3(lx + 0.02, 0.014, lz + 0.02), Vector3(0, ye + 0.13, 0), "bandiera_rossa"))
	t.add_child(scatola(Vector3(lx + 0.08, 0.03, lz + 0.08), Vector3(0, ye + 0.152, 0), "marmo"))
	var yr := ye + 0.167
	sottotetto(t, lx + 0.06, lz + 0.06, yr, 16.0, "marmo")
	tetto_coppi(t, lx + 0.04, lz + 0.06, yr, 16.0)
	# timpano dipinto con un gruppo di statue
	var alt := (lz + 0.06) * 0.5 * tan(deg_to_rad(16.0))
	var tim := MeshInstance3D.new()
	var pm := PrismMesh.new()
	pm.size = Vector3(lz - 0.12, alt * 0.75, 0.01)
	tim.mesh = pm
	tim.rotation_degrees.y = 90
	tim.position = Vector3((lx + 0.06) * 0.5 + 0.006, yr + alt * 0.375 + 0.012, 0)
	tim.material_override = materiale("persiana")
	t.add_child(tim)
	for k in 3:
		var fz := -0.16 + k * 0.16
		var fh := 0.1 if k == 1 else 0.065
		t.add_child(sfera(0.025, Vector3((lx + 0.06) * 0.5 + 0.02, yr + 0.02 + fh * 0.5, fz), "marmo", Vector3(1, fh / 0.05, 1)))
	# acroteri dorati
	for s in [-1, 1]:
		t.add_child(sfera(0.035, Vector3(s * ((lx + 0.06) * 0.5 + 0.02), yr + alt + 0.06, 0), "moneta", Vector3(1, 1.4, 1)))
		for q in [-1, 1]:
			t.add_child(sfera(0.025, Vector3(s * ((lx + 0.06) * 0.5 + 0.02), yr + 0.03, q * ((lz + 0.06) * 0.5)), "moneta"))
	# altare davanti al tempio, con il fuoco acceso
	var al := Vector3(-0.05, 0, 1.22)
	r.add_child(scatola(Vector3(0.36, 0.05, 0.22), al + Vector3(0, 0.025, 0), "blocco"))
	r.add_child(scatola(Vector3(0.3, 0.14, 0.16), al + Vector3(0, 0.12, 0), "marmo"))
	r.add_child(scatola(Vector3(0.31, 0.025, 0.17), al + Vector3(0, 0.15, 0), "bandiera_rossa"))
	r.add_child(scatola(Vector3(0.34, 0.02, 0.2), al + Vector3(0, 0.2, 0), "marmo"))
	r.add_child(sfera(0.045, al + Vector3(0, 0.23, 0), "brace", Vector3(1.2, 0.8, 1)))
	r.add_child(sfera(0.05, al + Vector3(0.02, 0.33, -0.02), "fumo", Vector3(1, 1.4, 1)))
	for k in 3:
		r.add_child(anfora(al + Vector3(0.25 + k * 0.08, 0, 0.05 - k * 0.03), 1.0))
	# melograno sacro a Proserpina, cipressi dietro, devoti con le offerte
	var mp := Vector3(0.82, 0, 0.62)
	ramo(r, mp, mp + Vector3(-0.02, 0.28, 0), 0.025)
	chioma(r, mp + Vector3(-0.02, 0.38, 0), Vector3(0.2, 0.15, 0.2), 14, 311)
	var rng := _rng(312)
	for k in 9:
		var a := rng.randf() * TAU
		r.add_child(sfera(0.022, mp + Vector3(cos(a) * 0.19, 0.33 + rng.randf_range(0, 0.12), sin(a) * 0.19), "geranio"))
	_cipresso(r, Vector3(-0.95, 0, -1.05), 0.9)
	_cipresso(r, Vector3(-0.72, 0, -1.2), 0.75)
	var p1 := portatore("cesta")
	p1.position = Vector3(0.32, 0, 1.38)
	p1.rotation_degrees.y = 200
	r.add_child(p1)
	var p2 := portatore("anfora")
	p2.position = Vector3(-0.5, 0, 1.3)
	p2.rotation_degrees.y = 160
	r.add_child(p2)
	return r


## Porto di Santa Venere: molo di blocchi con bitte, lanterna, barche ormeggiate, reti e anfore.
static func porto_santa_venere() -> Node3D:
	var r := Node3D.new()
	_mare(r, [Vector3(0.45, 0.45, 0.85), Vector3(-0.3, 0.9, 0.55), Vector3(1.05, -0.15, 0.55), Vector3(0.95, 0.95, 0.45)])
	_riva(r, [Vector3(-0.6, -0.5, 0.75), Vector3(0.1, -0.85, 0.55), Vector3(-1.0, 0.25, 0.45), Vector3(0.65, -0.95, 0.35)])
	var rng := _rng(331)
	for k in 7:
		var a := deg_to_rad(110 + k * 22)
		r.add_child(_masso(Vector3(-0.45 + cos(a) * 0.95, 0.0, -0.45 + sin(a) * 0.95), rng.randf_range(0.1, 0.18), Vector3(1.3, 1.0, 1.0), "roccia_chiara", rng.randf() * 180))
	# molo
	var mx := 0.25
	var mz0 := -0.6
	var mz1 := 0.95
	var ml := mz1 - mz0
	var mc := (mz0 + mz1) * 0.5
	r.add_child(scatola(Vector3(0.46, 0.16, ml), Vector3(mx, 0.08, mc), "blocchi_greci"))
	r.add_child(scatola(Vector3(0.5, 0.03, ml + 0.02), Vector3(mx, 0.175, mc), "pietra"))
	r.add_child(scatola(Vector3(0.72, 0.16, 0.5), Vector3(mx, 0.08, mz1 + 0.15), "blocchi_greci"))
	r.add_child(scatola(Vector3(0.76, 0.03, 0.54), Vector3(mx, 0.175, mz1 + 0.15), "pietra"))
	for k in 4:
		var z := mz0 + 0.3 + k * 0.36
		for s in [-1, 1]:
			r.add_child(cilindro(0.025, 0.03, 0.07, Vector3(mx + s * 0.19, 0.225, z), "legno_scuro", Vector3.ZERO, 8))
			r.add_child(cilindro(0.035, 0.035, 0.015, Vector3(mx + s * 0.19, 0.262, z), "legno_scuro", Vector3.ZERO, 8))
	# lanterna in testa al molo
	var lp := Vector3(mx + 0.08, 0.19, mz1 + 0.18)
	r.add_child(scatola(Vector3(0.28, 0.12, 0.28), lp + Vector3(0, 0.06, 0), "blocco"))
	r.add_child(cilindro(0.1, 0.085, 0.5, lp + Vector3(0, 0.37, 0), "intonaco_bianco", Vector3.ZERO, 14))
	for k in 2:
		r.add_child(cilindro(0.098 - k * 0.008, 0.096 - k * 0.008, 0.05, lp + Vector3(0, 0.24 + k * 0.2, 0), "bandiera_rossa", Vector3.ZERO, 14))
	r.add_child(scatola(Vector3(0.06, 0.1, 0.02), lp + Vector3(0, 0.17, 0.095), "legno_scuro"))
	r.add_child(scatola(Vector3(0.03, 0.05, 0.02), lp + Vector3(0, 0.36, 0.088), "buio"))
	r.add_child(cilindro(0.135, 0.135, 0.025, lp + Vector3(0, 0.632, 0), "pietra", Vector3.ZERO, 14))
	for k in 12:
		var a := k * TAU / 12
		r.add_child(cilindro(0.004, 0.004, 0.05, lp + Vector3(cos(a) * 0.125, 0.67, sin(a) * 0.125), "ferro", Vector3.ZERO, 4))
	r.add_child(cilindro(0.13, 0.13, 0.006, lp + Vector3(0, 0.695, 0), "ferro", Vector3.ZERO, 14))
	r.add_child(cilindro(0.06, 0.06, 0.1, lp + Vector3(0, 0.7, 0), "brace", Vector3.ZERO, 8))
	r.add_child(cilindro(0.085, 0.0, 0.1, lp + Vector3(0, 0.8, 0), "piombo", Vector3.ZERO, 8))
	r.add_child(sfera(0.015, lp + Vector3(0, 0.86, 0), "moneta"))
	# barche ormeggiate
	r.add_child(_barca(Vector3(mx + 0.42, 0.0, 0.25), 90, "persiana", 1.1))
	ramo(r, Vector3(mx + 0.19, 0.24, 0.06), Vector3(mx + 0.4, 0.11, 0.0), 0.005, "corda")
	r.add_child(_barca(Vector3(-0.3, 0.0, 0.85), 30, "bandiera_rossa", 1.0))
	r.add_child(_barca(Vector3(-0.85, 0.02, -0.05), -60, "giocatore", 0.95))
	# magazzino del porto sulla riva
	var c := Node3D.new()
	c.position = Vector3(-0.62, 0.02, -0.62)
	r.add_child(c)
	casa_muri(c, 0.62, 0.45, 0.32, 331)
	porta_z(c, 0.12, 0.225, 0.13, 0.22)
	finestra_z(c, -0.15, 0.27, 0.225, 0.08, 0.08)
	finestra_x(c, 0.0, 0.27, 0.31, 0.08, 0.08)
	sottotetto(c, 0.62, 0.45, 0.39, 24.0)
	tetto(c, 0.68, 0.45, 0.39, 24.0, 331)
	# anfore, ceste, reti, gente al lavoro
	for i in 6:
		r.add_child(anfora(Vector3(-0.15 + (i % 3) * 0.08, 0.02, -0.2 + (i / 3) * 0.09), 1.15))
	r.add_child(cesta(Vector3(0.05, 0.02, -0.38), "pesce"))
	r.add_child(cesta(Vector3(mx - 0.1, 0.19, mz1 - 0.1), "pesce"))
	r.add_child(barile(Vector3(mx + 0.1, 0.19, mz1 - 0.05)))
	r.add_child(cassa(Vector3(-0.25, 0.02, -0.38), 15))
	_rete(r, Vector3(-1.0, 0.02, 0.35), 0.38, 25)
	var p1 := portatore("anfora")
	p1.position = Vector3(mx - 0.05, 0.19, 0.25)
	p1.rotation_degrees.y = 180
	r.add_child(p1)
	var p2 := portatore("pesce")
	p2.position = Vector3(-0.45, 0.02, 0.1)
	p2.rotation_degrees.y = 60
	r.add_child(p2)
	return r


## Foro di Vibo Valentia: lastricato, colonne in piedi e spezzate, arco onorario, esedra.
static func foro_valentia() -> Node3D:
	var r := Node3D.new()
	r.add_child(scatola(Vector3(2.5, 0.04, 2.4), Vector3(0, 0.02, 0), "pietra"))
	var rng := _rng(341)
	for k in 46:
		r.add_child(scatola(Vector3(rng.randf_range(0.18, 0.34), 0.006, rng.randf_range(0.18, 0.34)),
			Vector3(rng.randf_range(-1.1, 1.1), 0.043, rng.randf_range(-1.05, 1.05)), "marmo" if k % 3 == 0 else "blocco", Vector3(0, rng.randf_range(-6, 6), 0)))
	for k in 16:
		_ciuffo(r, Vector3(rng.randf_range(-1.15, 1.15), 0.04, rng.randf_range(-1.1, 1.1)), rng.randf_range(0.7, 1.4))
	# portico in fondo: tre colonne con l'architrave ancora in piedi, le altre spezzate
	var zc := -0.92
	var hs := 0.85
	var alte := [hs, hs, hs, 0.45, 0.22, 0.6]
	for k in 6:
		var p := Vector3(-1.0 + k * 0.32, 0.04, zc)
		r.add_child(scatola(Vector3(0.16, 0.06, 0.16), p + Vector3(0, 0.03, 0), "marmo"))
		var hh: float = alte[k]
		_colonna(r, p + Vector3(0, 0.06, 0), hh, 0.058, "marmo", k < 3)
		if k >= 3:
			r.add_child(cilindro(0.052, 0.04, 0.05, p + Vector3(0.01, 0.06 + hh + 0.02, 0), "marmo", Vector3(18, 0, 12), 10))
	var ya := 0.1 + hs + 0.058 * 1.05
	r.add_child(scatola(Vector3(0.82, 0.08, 0.16), Vector3(-0.68, ya + 0.04, zc), "marmo"))
	r.add_child(scatola(Vector3(0.8, 0.06, 0.14), Vector3(-0.68, ya + 0.11, zc), "intonaco_giallo"))
	r.add_child(scatola(Vector3(0.5, 0.035, 0.01), Vector3(-0.68, ya + 0.11, zc + 0.072), "bandiera_rossa"))
	r.add_child(scatola(Vector3(0.88, 0.03, 0.2), Vector3(-0.68, ya + 0.155, zc), "marmo"))
	# rocchi caduti e un capitello a terra
	r.add_child(cilindro(0.058, 0.058, 0.26, Vector3(0.2, 0.04 + 0.058, -0.6), "marmo", Vector3(90, 35, 0), 12))
	r.add_child(cilindro(0.058, 0.058, 0.2, Vector3(0.45, 0.04 + 0.058, -0.52), "marmo", Vector3(90, -50, 0), 12))
	r.add_child(scatola(Vector3(0.17, 0.05, 0.17), Vector3(0.0, 0.065, -0.45), "marmo", Vector3(0, 20, 8)))
	# arco onorario sul lato sinistro, con attico e iscrizione
	var ar := _arco(r, Vector3(-0.98, 0.04, 0.2), 0.42, 0.5, 0.26, "pietra_vista", 90, "marmo")
	var pw := 0.42 * 0.28
	for s in [-1, 1]:
		ar.add_child(scatola(Vector3(pw, 0.34, 0.26), Vector3(s * (0.42 + pw) * 0.5, 0.67, 0), "pietra_vista"))
		ar.add_child(scatola(Vector3(0.05, 0.5, 0.03), Vector3(s * (0.42 + pw) * 0.5, 0.25, 0.14), "marmo"))
	ar.add_child(scatola(Vector3(0.7, 0.03, 0.32), Vector3(0, 0.85, 0), "marmo"))
	ar.add_child(scatola(Vector3(0.66, 0.2, 0.28), Vector3(0, 0.965, 0), "pietra_vista"))
	ar.add_child(scatola(Vector3(0.4, 0.11, 0.012), Vector3(0, 0.965, 0.142), "marmo"))
	for k in 3:
		ar.add_child(scatola(Vector3(0.3 - k * 0.06, 0.008, 0.004), Vector3(0, 0.99 - k * 0.025, 0.15), "buio"))
	ar.add_child(scatola(Vector3(0.72, 0.03, 0.32), Vector3(0, 1.08, 0), "marmo"))
	# esedra con il sedile curvo e una statua al centro
	var ec := Vector3(0.62, 0.04, -0.15)
	for k in 9:
		var a := PI + (k + 0.5) * PI / 9
		var ruota := Vector3(0, -rad_to_deg(a) - 90, 0)
		var hm := 0.32 - (0.14 if k == 2 or k == 7 else 0.0)
		var pp := ec + Vector3(cos(a) * 0.46, 0, sin(a) * 0.46)
		r.add_child(scatola(Vector3(0.17, hm, 0.08), pp + Vector3(0, hm * 0.5, 0), "pietra_vista", ruota))
		r.add_child(scatola(Vector3(0.18, 0.025, 0.1), pp + Vector3(0, hm + 0.012, 0), "marmo", ruota))
		var pb := ec + Vector3(cos(a) * 0.37, 0, sin(a) * 0.37)
		r.add_child(scatola(Vector3(0.14, 0.08, 0.1), pb + Vector3(0, 0.04, 0), "marmo", ruota))
	r.add_child(scatola(Vector3(0.16, 0.18, 0.16), ec + Vector3(0, 0.09, -0.12), "marmo"))
	r.add_child(_statua(ec + Vector3(0, 0.18, -0.12), 0.95, 10))
	# basi di colonne superstiti lungo il lato destro
	for k in 5:
		var pb := Vector3(1.02, 0.04, -0.45 + k * 0.32)
		var hb: float = [0.28, 0.12, 0.4, 0.08, 0.2][k]
		r.add_child(scatola(Vector3(0.15, 0.05, 0.15), pb + Vector3(0, 0.025, 0), "marmo"))
		r.add_child(cilindro(0.055, 0.05, hb, pb + Vector3(0, 0.05 + hb * 0.5, 0), "marmo", Vector3.ZERO, 12))
	r.add_child(cilindro(0.055, 0.05, 0.55, Vector3(0.7, 0.04 + 0.055, 0.75), "marmo", Vector3(90, 70, 0), 12))
	# cipresso e fico cresciuti fra le rovine
	_cipresso(r, Vector3(1.05, 0.04, -1.0), 0.85)
	ramo(r, Vector3(0.95, 0.04, 0.85), Vector3(0.9, 0.3, 0.8), 0.022)
	chioma(r, Vector3(0.9, 0.38, 0.8), Vector3(0.18, 0.12, 0.18), 12, 342)
	var p1 := portatore("")
	p1.position = Vector3(0.1, 0.04, 0.45)
	p1.rotation_degrees.y = 200
	r.add_child(p1)
	return r


## Castello normanno-svevo: mastio quadrato, mura merlate e torri cilindriche di pietra scura.
static func castello_normanno() -> Node3D:
	var r := Node3D.new()
	var rng := _rng(351)
	# sperone di roccia su cui sorge
	r.add_child(cilindro(1.42, 1.52, 0.14, Vector3(0, 0.07, 0), "roccia_massi", Vector3(0, 12, 0), 9))
	for k in 12:
		var a := k * TAU / 12 + 0.2
		r.add_child(_masso(Vector3(cos(a) * 1.42, 0.0, sin(a) * 1.42), rng.randf_range(0.16, 0.26), Vector3(1.3, rng.randf_range(0.8, 1.2), 1.0), "roccia_massi", rng.randf() * 180))
	var y0 := 0.14
	var lato := 2.0
	var h := 0.5
	var mat := "pietra_scura"
	var c := lato * 0.5
	r.add_child(scatola(Vector3(lato, 0.01, lato), Vector3(0, y0 + 0.005, 0), "terra"))
	var angoli := [Vector3(-c, y0, -c), Vector3(c, y0, -c), Vector3(c, y0, c), Vector3(-c, y0, c)]
	for i in 4:
		_muro(r, angoli[i], angoli[(i + 1) % 4], h, 0.15, mat, true, "pietra")
	for p in angoli:
		_torre_tonda(r, p, 0.24, h + 0.32, mat, "pietra", true)
	# mastio
	var mp := Vector3(-0.3, y0, -0.3)
	var ml := 0.82
	var mh := 1.3
	r.add_child(cilindro(ml * 0.8, ml * 0.71, 0.24, mp + Vector3(0, 0.12, 0), mat, Vector3(0, 45, 0), 4))
	r.add_child(scatola(Vector3(ml, mh, ml), mp + Vector3(0, mh * 0.5, 0), mat))
	for s in [-1, 1]:
		r.add_child(scatola(Vector3(0.09, mh - 0.2, 0.03), mp + Vector3(s * (ml * 0.5 - 0.045), 0.2 + (mh - 0.2) * 0.5, ml * 0.5 + 0.012), mat))
		r.add_child(scatola(Vector3(0.03, mh - 0.2, 0.09), mp + Vector3(ml * 0.5 + 0.012, 0.2 + (mh - 0.2) * 0.5, s * (ml * 0.5 - 0.045)), mat))
	# archetti pensili sotto il coronamento
	for k in 8:
		var o := -ml * 0.5 + 0.06 + k * (ml - 0.12) / 7
		r.add_child(cilindro(0.035, 0.035, 0.02, mp + Vector3(o, mh - 0.1, ml * 0.5 + 0.004), "pietra", Vector3(90, 0, 0), 10))
		r.add_child(cilindro(0.035, 0.035, 0.02, mp + Vector3(ml * 0.5 + 0.004, mh - 0.1, o), "pietra", Vector3(0, 0, 90), 10))
	r.add_child(scatola(Vector3(ml + 0.06, 0.1, ml + 0.06), mp + Vector3(0, mh + 0.05, 0), mat))
	for i in 4:
		for k in 5:
			var a := i * PI * 0.5
			var o := Vector3(-0.33 + k * 0.165, mh + 0.14, ml * 0.5 + 0.0).rotated(Vector3.UP, a)
			r.add_child(scatola(Vector3(0.1, 0.08, 0.1), mp + o, "pietra", Vector3(0, rad_to_deg(a), 0)))
	# bifore sui due lati in vista
	for s in [-1, 1]:
		r.add_child(scatola(Vector3(0.05, 0.13, 0.02), mp + Vector3(s * 0.04, mh * 0.66, ml * 0.5 + 0.004), "buio"))
		r.add_child(cilindro(0.025, 0.025, 0.02, mp + Vector3(s * 0.04, mh * 0.66 + 0.065, ml * 0.5 + 0.004), "buio", Vector3(90, 0, 0), 10))
		r.add_child(scatola(Vector3(0.02, 0.13, 0.05), mp + Vector3(ml * 0.5 + 0.004, mh * 0.66, s * 0.04), "buio"))
		r.add_child(cilindro(0.025, 0.025, 0.02, mp + Vector3(ml * 0.5 + 0.004, mh * 0.66 + 0.065, s * 0.04), "buio", Vector3(0, 0, 90), 10))
	r.add_child(cilindro(0.008, 0.008, 0.15, mp + Vector3(0, mh * 0.66, ml * 0.5 + 0.01), "marmo", Vector3.ZERO, 6))
	r.add_child(cilindro(0.008, 0.008, 0.15, mp + Vector3(ml * 0.5 + 0.01, mh * 0.66, 0), "marmo", Vector3.ZERO, 6))
	r.add_child(scatola(Vector3(0.025, 0.09, 0.02), mp + Vector3(0.25, mh * 0.35, ml * 0.5 + 0.004), "buio"))
	r.add_child(scatola(Vector3(0.02, 0.09, 0.025), mp + Vector3(ml * 0.5 + 0.004, mh * 0.35, -0.2), "buio"))
	# stendardo
	r.add_child(cilindro(0.012, 0.012, 0.55, mp + Vector3(0.2, mh + 0.37, 0.2), "legno", Vector3.ZERO, 6))
	r.add_child(scatola(Vector3(0.006, 0.18, 0.13), mp + Vector3(0.2, mh + 0.55, 0.27), "bandiera_rossa"))
	r.add_child(scatola(Vector3(0.007, 0.18, 0.13), mp + Vector3(0.2, mh + 0.55, 0.4), "moneta"))
	# porta ad arco con la saracinesca e la rampa
	var gx := 0.35
	var zf := c + 0.08
	r.add_child(scatola(Vector3(0.24, 0.24, 0.02), Vector3(gx, y0 + 0.12, zf), "buio"))
	r.add_child(cilindro(0.12, 0.12, 0.02, Vector3(gx, y0 + 0.24, zf), "buio", Vector3(90, 0, 0), 14))
	_arco(r, Vector3(gx, y0, zf + 0.01), 0.24, 0.22, 0.05, mat, 0, "pietra")
	for k in 5:
		r.add_child(scatola(Vector3(0.008, 0.26, 0.008), Vector3(gx - 0.09 + k * 0.045, y0 + 0.17, zf + 0.015), "ferro"))
	for k in 3:
		r.add_child(scatola(Vector3(0.22, 0.008, 0.008), Vector3(gx, y0 + 0.12 + k * 0.08, zf + 0.015), "ferro"))
	r.add_child(scatola(Vector3(0.32, 0.03, 0.55), Vector3(gx, 0.07, c + 0.36), "terra", Vector3(14, 0, 0)))
	# cortile: pozzo, tettoia, botti, sentinelle sulle mura
	r.add_child(cilindro(0.09, 0.1, 0.1, Vector3(0.45, y0 + 0.05, -0.35), "pietra", Vector3.ZERO, 12))
	r.add_child(cilindro(0.07, 0.07, 0.005, Vector3(0.45, y0 + 0.102, -0.35), "acqua_pozzo", Vector3.ZERO, 12))
	r.add_child(barile(Vector3(0.6, y0, 0.3), 1.1))
	r.add_child(barile(Vector3(0.72, y0, 0.25), 1.1))
	r.add_child(cassa(Vector3(0.55, y0, 0.45), 20))
	var g := guardia()
	g.position = Vector3(c - 0.03, y0 + h, 0.1)
	g.rotation_degrees.y = 90
	r.add_child(g)
	var g2 := guardia()
	g2.position = Vector3(-0.5, y0 + h, c - 0.03)
	g2.rotation_degrees.y = 10
	r.add_child(g2)
	return r


## Duomo di Santa Maria Maggiore e San Leoluca: facciata barocca a due ordini, cupola, campanile.
static func duomo() -> Node3D:
	var r := Node3D.new()
	var xc := -0.22
	var zf := 0.5
	var lung := 1.5
	var zm := zf - lung * 0.5
	var ln := 0.68
	var hn := 0.88
	var la := 0.3
	var ha := 0.5
	# sagrato a gradini
	for k in 3:
		var e := (2 - k) * 0.07
		r.add_child(scatola(Vector3(1.9 + e * 2, 0.035, lung + 0.62 + e * 2), Vector3(xc + 0.12, 0.0175 + k * 0.035, zm + 0.24), "blocco" if k < 2 else "marmo"))
	var b := 0.105
	# navata centrale e navatelle
	r.add_child(scatola(Vector3(ln, hn, lung), Vector3(xc, b + hn * 0.5, zm), "intonaco_giallo"))
	for s in [-1, 1]:
		r.add_child(scatola(Vector3(la, ha, lung - 0.05), Vector3(xc + s * (ln + la) * 0.5, b + ha * 0.5, zm - 0.025), "intonaco_giallo"))
		_falda(r, lung - 0.05, la, b + ha, 22.0, Vector3(xc + s * (ln + la) * 0.5, 0, zm - 0.025), 90.0 * s, 360 + s)
	var nt := Node3D.new()
	nt.position = Vector3(xc, 0, zm)
	nt.rotation_degrees.y = 90
	r.add_child(nt)
	sottotetto(nt, lung, ln, b + hn, 24.0, "intonaco_giallo")
	tetto(nt, lung, ln, b + hn, 24.0, 361)
	# finestre sul fianco in vista
	for k in 4:
		var z := zf - 0.25 - k * 0.3
		_vano_arco_x(r, z, b + hn - 0.2, xc + ln * 0.5, 0.07, 0.1, "intonaco_bianco")
		_vano_arco_x(r, z, b + 0.22, xc + ln * 0.5 + la, 0.07, 0.12, "intonaco_bianco")
	# abside
	r.add_child(cilindro(0.3, 0.3, hn * 0.8, Vector3(xc, b + hn * 0.4, zm - lung * 0.5), "intonaco_giallo", Vector3.ZERO, 16))
	r.add_child(cilindro(0.34, 0.0, 0.2, Vector3(xc, b + hn * 0.8 + 0.1, zm - lung * 0.5), "tegola", Vector3.ZERO, 16))
	# tiburio, tamburo ottagonale e cupola con lanterna
	var zd := zm - lung * 0.5 + 0.38
	r.add_child(scatola(Vector3(ln + 0.06, 0.25, 0.62), Vector3(xc, b + hn + 0.125, zd), "intonaco_giallo"))
	r.add_child(scatola(Vector3(ln + 0.1, 0.03, 0.66), Vector3(xc, b + hn + 0.26, zd), "marmo"))
	var yt := b + hn + 0.275
	r.add_child(cilindro(0.3, 0.3, 0.24, Vector3(xc, yt + 0.12, zd), "intonaco_bianco", Vector3(0, 22.5, 0), 8))
	for k in 8:
		var a := k * TAU / 8
		r.add_child(scatola(Vector3(0.04, 0.24, 0.03), Vector3(xc + cos(a) * 0.29, yt + 0.12, zd + sin(a) * 0.29), "marmo", Vector3(0, -rad_to_deg(a) - 90, 0)))
		var a2 := a + TAU / 16
		r.add_child(scatola(Vector3(0.05, 0.11, 0.02), Vector3(xc + cos(a2) * 0.28, yt + 0.12, zd + sin(a2) * 0.28), "buio", Vector3(0, -rad_to_deg(a2) - 90, 0)))
	r.add_child(cilindro(0.33, 0.33, 0.04, Vector3(xc, yt + 0.25, zd), "marmo", Vector3.ZERO, 16))
	r.add_child(sfera(0.31, Vector3(xc, yt + 0.25, zd), "piombo", Vector3(1, 0.95, 1)))
	for k in 8:
		var a := k * TAU / 8
		var costa := Node3D.new()
		costa.position = Vector3(xc, yt + 0.25, zd)
		costa.rotation.y = -a
		r.add_child(costa)
		for j in 4:
			var t := (j + 0.5) * PI * 0.5 / 4
			costa.add_child(scatola(Vector3(0.03, 0.08, 0.02), Vector3(cos(t) * 0.305, sin(t) * 0.295, 0), "marmo", Vector3(0, 0, rad_to_deg(t))))
	r.add_child(cilindro(0.06, 0.06, 0.12, Vector3(xc, yt + 0.6, zd), "marmo", Vector3.ZERO, 8))
	r.add_child(cilindro(0.075, 0.0, 0.09, Vector3(xc, yt + 0.705, zd), "piombo", Vector3.ZERO, 8))
	_croce(r, Vector3(xc, yt + 0.75, zd), 1.0, "moneta")
	# facciata: ordine inferiore
	var fw := ln + 2 * la + 0.04
	r.add_child(scatola(Vector3(fw, 0.62, 0.08), Vector3(xc, b + 0.31, zf + 0.04), "intonaco_bianco"))
	for x in [-0.62, -0.36, 0.36, 0.62]:
		r.add_child(scatola(Vector3(0.07, 0.6, 0.03), Vector3(xc + x, b + 0.3, zf + 0.095), "marmo"))
		r.add_child(scatola(Vector3(0.09, 0.03, 0.045), Vector3(xc + x, b + 0.6, zf + 0.1), "marmo"))
	r.add_child(scatola(Vector3(fw + 0.06, 0.07, 0.13), Vector3(xc, b + 0.655, zf + 0.06), "marmo"))
	r.add_child(scatola(Vector3(fw + 0.02, 0.025, 0.12), Vector3(xc, b + 0.61, zf + 0.06), "intonaco_giallo"))
	_vano_arco_z(r, xc, b, zf + 0.08, 0.2, 0.28, "marmo")
	r.add_child(scatola(Vector3(0.18, 0.27, 0.02), Vector3(xc, b + 0.135, zf + 0.09), "legno_scuro"))
	var tp := MeshInstance3D.new()
	var pmt := PrismMesh.new()
	pmt.size = Vector3(0.34, 0.08, 0.05)
	tp.mesh = pmt
	tp.position = Vector3(xc, b + 0.46, zf + 0.1)
	tp.material_override = materiale("marmo")
	r.add_child(tp)
	for s in [-1, 1]:
		r.add_child(scatola(Vector3(0.11, 0.19, 0.02), Vector3(xc + s * 0.49, b + 0.095, zf + 0.09), "legno_scuro"))
		r.add_child(scatola(Vector3(0.15, 0.03, 0.04), Vector3(xc + s * 0.49, b + 0.2, zf + 0.095), "marmo"))
		r.add_child(cilindro(0.045, 0.045, 0.02, Vector3(xc + s * 0.49, b + 0.38, zf + 0.085), "buio", Vector3(90, 0, 0), 12))
		r.add_child(cilindro(0.058, 0.058, 0.014, Vector3(xc + s * 0.49, b + 0.38, zf + 0.082), "marmo", Vector3(90, 0, 0), 12))
		# vasi di fiamma sulla cornice
		r.add_child(cilindro(0.025, 0.035, 0.05, Vector3(xc + s * 0.62, b + 0.715, zf + 0.09), "marmo", Vector3.ZERO, 8))
		r.add_child(sfera(0.028, Vector3(xc + s * 0.62, b + 0.76, zf + 0.09), "marmo", Vector3(1, 1.3, 1)))
	# ordine superiore con volute e frontone
	var ys := b + 0.69
	r.add_child(scatola(Vector3(ln + 0.04, 0.4, 0.08), Vector3(xc, ys + 0.2, zf + 0.04), "intonaco_bianco"))
	for s in [-1, 1]:
		r.add_child(scatola(Vector3(0.06, 0.4, 0.03), Vector3(xc + s * 0.3, ys + 0.2, zf + 0.095), "marmo"))
		r.add_child(cilindro(0.17, 0.17, 0.07, Vector3(xc + s * (ln * 0.5 + 0.02), ys, zf + 0.04), "intonaco_bianco", Vector3(90, 0, 0), 18))
		r.add_child(cilindro(0.04, 0.04, 0.09, Vector3(xc + s * (ln * 0.5 + 0.16), ys + 0.04, zf + 0.05), "marmo", Vector3(90, 0, 0), 10))
	_vano_arco_z(r, xc, ys + 0.1, zf + 0.08, 0.13, 0.16, "marmo")
	r.add_child(scatola(Vector3(ln + 0.14, 0.035, 0.12), Vector3(xc, ys + 0.415, zf + 0.05), "marmo"))
	var fr := MeshInstance3D.new()
	var pmf := PrismMesh.new()
	pmf.size = Vector3(ln + 0.12, 0.17, 0.1)
	fr.mesh = pmf
	fr.position = Vector3(xc, ys + 0.433 + 0.085, zf + 0.04)
	fr.material_override = materiale("marmo")
	r.add_child(fr)
	var ti := MeshInstance3D.new()
	var pmi := PrismMesh.new()
	pmi.size = Vector3(ln - 0.06, 0.11, 0.104)
	ti.mesh = pmi
	ti.position = Vector3(xc, ys + 0.433 + 0.06, zf + 0.04)
	ti.material_override = materiale("intonaco_giallo")
	r.add_child(ti)
	r.add_child(cilindro(0.03, 0.03, 0.02, Vector3(xc, ys + 0.5, zf + 0.096), "moneta", Vector3(90, 0, 0), 10))
	_croce(r, Vector3(xc, ys + 0.6, zf + 0.04), 1.1, "moneta")
	# campanile a destra, con orologio, cella campanaria e cuspide di maiolica
	var cp := Vector3(xc + ln * 0.5 + la + 0.19, b, -0.3)
	var cl := 0.34
	r.add_child(scatola(Vector3(cl, 0.62, cl), cp + Vector3(0, 0.31, 0), "pietra_vista"))
	r.add_child(scatola(Vector3(cl + 0.04, 0.04, cl + 0.04), cp + Vector3(0, 0.64, 0), "marmo"))
	r.add_child(scatola(Vector3(cl - 0.02, 0.44, cl - 0.02), cp + Vector3(0, 0.88, 0), "intonaco_bianco"))
	for k in 2:
		var ruota := Vector3(90, 0, 0) if k == 0 else Vector3(0, 0, 90)
		var faccia := Vector3(0, 0.9, (cl - 0.02) * 0.5 + 0.006) if k == 0 else Vector3((cl - 0.02) * 0.5 + 0.006, 0.9, 0)
		r.add_child(cilindro(0.085, 0.085, 0.012, cp + faccia, "marmo", ruota, 18))
		r.add_child(cilindro(0.07, 0.07, 0.016, cp + faccia, "intonaco", ruota, 18))
		var lan := Vector3(0, 0, 0.012) if k == 0 else Vector3(0.012, 0, 0)
		r.add_child(scatola(Vector3(0.01, 0.055, 0.01), cp + faccia + lan + Vector3(0, 0.025, 0), "ferro"))
		r.add_child(scatola(Vector3(0.01, 0.04, 0.01), cp + faccia + lan + Vector3(0, 0, 0) + Vector3(0.015, -0.012, 0.015 if k == 1 else 0.0), "ferro", Vector3(0, 0, 50) if k == 0 else Vector3(-50, 0, 0)))
		if k == 0:
			_vano_arco_z(r, cp.x, cp.y + 0.38, cp.z + cl * 0.5, 0.05, 0.12, "intonaco_bianco")
		else:
			_vano_arco_x(r, cp.z, cp.y + 0.38, cp.x + cl * 0.5, 0.05, 0.12, "intonaco_bianco")
	r.add_child(scatola(Vector3(cl + 0.04, 0.04, cl + 0.04), cp + Vector3(0, 1.12, 0), "marmo"))
	var yb := 1.14
	r.add_child(scatola(Vector3(0.14, 0.28, 0.14), cp + Vector3(0, yb + 0.14, 0), "buio"))
	for sx in [-1, 1]:
		for sz in [-1, 1]:
			r.add_child(scatola(Vector3(0.075, 0.3, 0.075), cp + Vector3(sx * (cl * 0.5 - 0.05), yb + 0.15, sz * (cl * 0.5 - 0.05)), "intonaco_bianco"))
	r.add_child(sfera(0.05, cp + Vector3(0, yb + 0.13, cl * 0.5 - 0.09), "bronzo", Vector3(1, 1.15, 1)))
	r.add_child(sfera(0.045, cp + Vector3(cl * 0.5 - 0.09, yb + 0.14, 0), "bronzo", Vector3(1, 1.15, 1)))
	r.add_child(scatola(Vector3(cl + 0.04, 0.05, cl + 0.04), cp + Vector3(0, yb + 0.325, 0), "marmo"))
	r.add_child(cilindro(0.2, 0.0, 0.34, cp + Vector3(0, yb + 0.52, 0), "maiolica", Vector3(0, 45, 0), 8))
	r.add_child(sfera(0.025, cp + Vector3(0, yb + 0.7, 0), "moneta"))
	_croce(r, cp + Vector3(0, yb + 0.71, 0), 0.9, "moneta")
	# fedeli sul sagrato
	var p1 := portatore("")
	p1.position = Vector3(xc + 0.72, b, zf + 0.42)
	p1.rotation_degrees.y = 160
	r.add_child(p1)
	var p2 := portatore("cesta")
	p2.position = Vector3(xc - 0.62, b, zf + 0.45)
	p2.rotation_degrees.y = 200
	r.add_child(p2)
	return r


## Chiesa del Rosario: navata semplice, facciata con portale e rosone, campanile a vela, canonica.
static func chiesa_rosario() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.3, 0, -0.15)
	r.add_child(c)
	var lx := 0.62
	var lz := 1.1
	var h := 0.55
	casa_muri(c, lx, lz, h, 371, "intonaco_bianco")
	var n := Node3D.new()
	n.rotation_degrees.y = 90
	c.add_child(n)
	sottotetto(n, lz, lx, 0.07 + h, 26.0, "intonaco_bianco")
	tetto(n, lz, lx, 0.07 + h, 26.0, 371)
	for k in 3:
		_vano_arco_x(c, -0.3 + k * 0.3, 0.36, lx * 0.5, 0.06, 0.13, "intonaco_giallo")
	# facciata a capanna
	var zf := lz * 0.5
	var hf := h + 0.1
	c.add_child(scatola(Vector3(lx + 0.08, hf, 0.07), Vector3(0, 0.07 + hf * 0.5, zf + 0.035), "intonaco_giallo"))
	for s in [-1, 1]:
		c.add_child(scatola(Vector3(0.05, hf, 0.03), Vector3(s * (lx * 0.5 + 0.015), 0.07 + hf * 0.5, zf + 0.08), "marmo"))
	c.add_child(scatola(Vector3(lx + 0.16, 0.035, 0.1), Vector3(0, 0.07 + hf + 0.017, zf + 0.04), "marmo"))
	var fr := MeshInstance3D.new()
	var pm := PrismMesh.new()
	pm.size = Vector3(lx + 0.12, 0.22, 0.07)
	fr.mesh = pm
	fr.position = Vector3(0, 0.07 + hf + 0.035 + 0.11, zf + 0.035)
	fr.material_override = materiale("intonaco_giallo")
	c.add_child(fr)
	# portale con lunetta dipinta
	var zp := zf + 0.07
	c.add_child(scatola(Vector3(0.16, 0.26, 0.02), Vector3(0, 0.07 + 0.13, zp + 0.003), "legno_scuro"))
	for k in 3:
		c.add_child(scatola(Vector3(0.006, 0.24, 0.008), Vector3(-0.05 + k * 0.05, 0.2, zp + 0.014), "legno_vecchio"))
	for s in [-1, 1]:
		c.add_child(scatola(Vector3(0.03, 0.3, 0.04), Vector3(s * 0.095, 0.07 + 0.15, zp + 0.01), "marmo"))
	c.add_child(scatola(Vector3(0.24, 0.03, 0.045), Vector3(0, 0.07 + 0.3, zp + 0.012), "marmo"))
	c.add_child(cilindro(0.1, 0.1, 0.02, Vector3(0, 0.385, zp + 0.003), "marmo", Vector3(90, 0, 0), 16))
	c.add_child(cilindro(0.08, 0.08, 0.024, Vector3(0, 0.385, zp + 0.004), "persiana", Vector3(90, 0, 0), 16))
	c.add_child(sfera(0.02, Vector3(0, 0.42, zp + 0.02), "intonaco_bianco"))
	_rosone(c, Vector3(0, 0.6, zp + 0.005), 0.09)
	for k in 2:
		c.add_child(scatola(Vector3(0.36 - k * 0.08, 0.035, 0.1), Vector3(0, 0.0175 + k * 0.035, zp + 0.1 - k * 0.03), "blocco"))
	# campanile a vela sopra il frontone
	var yv := 0.07 + hf + 0.17
	c.add_child(scatola(Vector3(0.28, 0.26, 0.06), Vector3(0, yv + 0.13, zf + 0.035), "intonaco_giallo"))
	for s in [-1, 1]:
		c.add_child(scatola(Vector3(0.065, 0.09, 0.064), Vector3(s * 0.065, yv + 0.12, zf + 0.035), "buio"))
		c.add_child(cilindro(0.0325, 0.0325, 0.064, Vector3(s * 0.065, yv + 0.165, zf + 0.035), "buio", Vector3(90, 0, 0), 10))
		c.add_child(sfera(0.026, Vector3(s * 0.065, yv + 0.13, zf + 0.05), "bronzo", Vector3(1, 1.2, 1)))
	var cv := MeshInstance3D.new()
	var pv := PrismMesh.new()
	pv.size = Vector3(0.32, 0.08, 0.07)
	cv.mesh = pv
	cv.position = Vector3(0, yv + 0.3, zf + 0.035)
	cv.material_override = materiale("marmo")
	c.add_child(cv)
	_croce(c, Vector3(0, yv + 0.34, zf + 0.035), 0.9)
	# sagrato lastricato
	r.add_child(scatola(Vector3(0.9, 0.012, 0.5), Vector3(-0.3, 0.006, 0.75), "blocco"))
	# canonica
	var d := Node3D.new()
	d.position = Vector3(0.55, 0, -0.42)
	r.add_child(d)
	casa_muri(d, 0.5, 0.55, 0.38, 372)
	porta_z(d, 0.1, 0.275, 0.12, 0.22)
	finestra_z(d, -0.12, 0.32, 0.275, 0.08, 0.1, true)
	finestra_x(d, 0.0, 0.3, 0.25, 0.08, 0.1)
	sottotetto(d, 0.5, 0.55, 0.45, 24.0)
	tetto(d, 0.56, 0.55, 0.45, 24.0, 372)
	comignolo(d, Vector3(0.15, 0.5, -0.12))
	# orto con muretto, cipressi, panca e vasi
	recinto(r, Vector3(0.25, 0, 0.0), Vector3(0.85, 0, 0.0))
	recinto(r, Vector3(0.85, 0, 0.0), Vector3(0.85, 0, 0.5))
	orto(r, Vector3(0.55, 0, 0.25), 0.5, 0.4, 373)
	_cipresso(r, Vector3(0.2, 0, 0.62), 0.6)
	_cipresso(r, Vector3(-0.85, 0, 0.55), 0.55)
	r.add_child(panca(Vector3(-0.72, 0, 0.75), 0.0))
	r.add_child(vaso_fiori(Vector3(0.0, 0, 0.5)))
	r.add_child(vaso_fiori(Vector3(-0.6, 0, 0.5)))
	return r


## Valentianum: convento dei Domenicani con chiostro ad archi, pozzo, aranci e la chiesa a un lato.
static func valentianum() -> Node3D:
	var r := Node3D.new()
	# ala di fondo a due piani
	var c1 := Node3D.new()
	c1.position = Vector3(0.18, 0, -0.85)
	r.add_child(c1)
	casa_muri(c1, 1.55, 0.42, 0.62, 381)
	for k in 5:
		finestra_z(c1, -0.6 + k * 0.3, 0.56, 0.21, 0.07, 0.1)
	finestra_x(c1, 0.0, 0.5, 0.775, 0.07, 0.1)
	sottotetto(c1, 1.55, 0.42, 0.69, 24.0)
	tetto(c1, 1.61, 0.42, 0.69, 24.0, 381)
	comignolo(c1, Vector3(0.45, 0.75, -0.08))
	# chiesa sul lato sinistro
	var c2 := Node3D.new()
	c2.position = Vector3(-0.82, 0, 0.0)
	r.add_child(c2)
	casa_muri(c2, 0.5, 2.1, 0.82, 382, "intonaco_giallo")
	var n := Node3D.new()
	n.rotation_degrees.y = 90
	c2.add_child(n)
	sottotetto(n, 2.1, 0.5, 0.89, 26.0, "intonaco_giallo")
	tetto(n, 2.1, 0.5, 0.89, 26.0, 382)
	for k in 5:
		_vano_arco_x(c2, -0.7 + k * 0.35, 0.66, 0.25, 0.06, 0.13, "intonaco_bianco")
	var zf := 1.05
	c2.add_child(scatola(Vector3(0.58, 0.95, 0.06), Vector3(0, 0.475 + 0.07, zf + 0.03), "intonaco_bianco"))
	var fr := MeshInstance3D.new()
	var pm := PrismMesh.new()
	pm.size = Vector3(0.62, 0.17, 0.07)
	fr.mesh = pm
	fr.position = Vector3(0, 1.02 + 0.085, zf + 0.03)
	fr.material_override = materiale("intonaco_bianco")
	c2.add_child(fr)
	c2.add_child(scatola(Vector3(0.64, 0.03, 0.09), Vector3(0, 1.025, zf + 0.035), "marmo"))
	_vano_arco_z(c2, 0.0, 0.07, zf + 0.06, 0.15, 0.22, "marmo")
	c2.add_child(scatola(Vector3(0.14, 0.21, 0.02), Vector3(0, 0.07 + 0.105, zf + 0.072), "legno_scuro"))
	_rosone(c2, Vector3(0, 0.7, zf + 0.065), 0.09)
	_croce(c2, Vector3(0, 1.19, zf + 0.03), 1.0)
	# campanile della chiesa
	var cp := Vector3(-0.82, 0, -0.78)
	r.add_child(scatola(Vector3(0.3, 1.25, 0.3), cp + Vector3(0, 0.625, 0), "intonaco_giallo"))
	r.add_child(scatola(Vector3(0.34, 0.03, 0.34), cp + Vector3(0, 1.0, 0), "marmo"))
	_vano_arco_z(r, cp.x, cp.y + 1.04, cp.z + 0.15, 0.08, 0.1, "intonaco_bianco")
	_vano_arco_x(r, cp.z, cp.y + 1.04, cp.x + 0.15, 0.08, 0.1, "intonaco_bianco")
	r.add_child(sfera(0.035, cp + Vector3(0, 1.1, 0.12), "bronzo", Vector3(1, 1.2, 1)))
	r.add_child(scatola(Vector3(0.34, 0.03, 0.34), cp + Vector3(0, 1.265, 0), "marmo"))
	r.add_child(cilindro(0.22, 0.0, 0.22, cp + Vector3(0, 1.39, 0), "tegola", Vector3(0, 45, 0), 4))
	_croce(r, cp + Vector3(0, 1.5, 0), 0.8)
	# chiostro: portici ad archi sui lati di fondo e di sinistra
	_portico_archi(r, Vector3(0.22, 0, -0.36), 1.4, 6, 0.3, 0.0, 383)
	_portico_archi(r, Vector3(-0.29, 0, 0.18), 1.5, 6, 0.3, 90.0, 384)
	# ali basse sul davanti e a destra
	r.add_child(scatola(Vector3(1.55, 0.36, 0.14), Vector3(0.27, 0.18, 0.98), "intonaco"))
	_falda(r, 1.55, 0.1, 0.36, 25.0, Vector3(0.27, 0, 0.95), 0.0, 385)
	r.add_child(scatola(Vector3(0.14, 0.36, 1.6), Vector3(0.98, 0.18, 0.2), "intonaco"))
	_falda(r, 1.62, 0.1, 0.36, 25.0, Vector3(0.95, 0, 0.2), 90.0, 386)
	_vano_arco_z(r, 0.3, 0.0, 1.05, 0.14, 0.2, "pietra")
	r.add_child(scatola(Vector3(0.13, 0.2, 0.02), Vector3(0.3, 0.1, 1.06), "legno_scuro"))
	for x in [-0.25, 0.75]:
		r.add_child(scatola(Vector3(0.06, 0.08, 0.02), Vector3(x, 0.22, 1.055), "buio"))
	for z in [-0.35, 0.2, 0.7]:
		r.add_child(scatola(Vector3(0.02, 0.08, 0.06), Vector3(1.055, 0.22, z), "buio"))
	# cortile: aiuole, vialetti in croce, pozzo e aranci
	var cc := Vector3(0.24, 0, 0.18)
	r.add_child(scatola(Vector3(0.95, 0.015, 0.95), cc + Vector3(0, 0.0075, 0), "orto"))
	r.add_child(scatola(Vector3(0.95, 0.02, 0.12), cc + Vector3(0, 0.01, 0), "blocco"))
	r.add_child(scatola(Vector3(0.12, 0.02, 0.95), cc + Vector3(0, 0.01, 0), "blocco"))
	r.add_child(cilindro(0.11, 0.11, 0.12, cc + Vector3(0, 0.06, 0), "marmo", Vector3(0, 22.5, 0), 8))
	r.add_child(cilindro(0.085, 0.085, 0.005, cc + Vector3(0, 0.122, 0), "acqua_pozzo", Vector3.ZERO, 8))
	for s in [-1, 1]:
		r.add_child(cilindro(0.01, 0.01, 0.2, cc + Vector3(s * 0.09, 0.2, 0), "ferro", Vector3.ZERO, 5))
	r.add_child(scatola(Vector3(0.2, 0.012, 0.012), cc + Vector3(0, 0.3, 0), "ferro"))
	r.add_child(scatola(Vector3(0.03, 0.04, 0.03), cc + Vector3(0, 0.2, 0), "legno"))
	var rng := _rng(387)
	for sx in [-1, 1]:
		for sz in [-1, 1]:
			var p := cc + Vector3(sx * 0.27, 0, sz * 0.27)
			ramo(r, p, p + Vector3(0, 0.15, 0), 0.014)
			chioma(r, p + Vector3(0, 0.2, 0), Vector3(0.09, 0.08, 0.09), 8, 388 + sx + sz * 3)
			for k in 4:
				var a := rng.randf() * TAU
				r.add_child(sfera(0.014, p + Vector3(cos(a) * 0.08, 0.17 + rng.randf_range(0, 0.07), sin(a) * 0.08), "arancia"))
	# due frati domenicani
	for k in 2:
		var f := portatore("", "buio", "intonaco_bianco")
		f.position = Vector3(0.05 + k * 0.42, 0.0, 0.5 - k * 0.12)
		f.rotation_degrees.y = 210 - k * 80
		f.scale = Vector3.ONE * 0.9
		r.add_child(f)
	return r


## Tonnara di Bivona: torre costiera quadrata con scarpa, magazzini bassi, barche, reti e tonni.
static func tonnara_bivona() -> Node3D:
	var r := Node3D.new()
	_mare(r, [Vector3(0.6, 0.85, 0.7), Vector3(1.15, 0.35, 0.5), Vector3(-0.2, 1.15, 0.45)])
	_riva(r, [Vector3(-0.5, -0.4, 0.95), Vector3(0.5, -0.6, 0.7), Vector3(-0.85, 0.5, 0.5), Vector3(0.1, 0.3, 0.5)])
	# torre
	var tp := Vector3(-0.52, 0.02, -0.45)
	var mat := "pietra_vista"
	r.add_child(cilindro(0.68, 0.55, 0.36, tp + Vector3(0, 0.18, 0), mat, Vector3(0, 45, 0), 4))
	r.add_child(scatola(Vector3(0.82, 0.04, 0.82), tp + Vector3(0, 0.38, 0), "blocco"))
	r.add_child(scatola(Vector3(0.76, 0.8, 0.76), tp + Vector3(0, 0.8, 0), mat))
	for k in 8:
		var o := -0.33 + k * 0.66 / 7
		r.add_child(scatola(Vector3(0.035, 0.07, 0.07), tp + Vector3(o, 1.17, 0.4), "blocco"))
		r.add_child(scatola(Vector3(0.07, 0.07, 0.035), tp + Vector3(0.4, 1.17, o), "blocco"))
	r.add_child(scatola(Vector3(0.86, 0.12, 0.86), tp + Vector3(0, 1.26, 0), mat))
	for i in 4:
		for k in 5:
			var a := i * PI * 0.5
			var o := Vector3(-0.34 + k * 0.17, 1.36, 0.4).rotated(Vector3.UP, a)
			r.add_child(scatola(Vector3(0.09, 0.08, 0.06), tp + o, "blocco", Vector3(0, rad_to_deg(a), 0)))
	# garitta sull'angolo verso il mare
	var ga := tp + Vector3(0.42, 1.12, 0.42)
	r.add_child(cilindro(0.04, 0.085, 0.12, ga, mat, Vector3.ZERO, 12))
	r.add_child(cilindro(0.085, 0.085, 0.2, ga + Vector3(0, 0.16, 0), mat, Vector3.ZERO, 12))
	r.add_child(scatola(Vector3(0.02, 0.07, 0.02), ga + Vector3(0.06, 0.17, 0.06), "buio", Vector3(0, 45, 0)))
	r.add_child(cilindro(0.1, 0.0, 0.12, ga + Vector3(0, 0.32, 0), "pietra", Vector3.ZERO, 12))
	# finestre, porta rialzata con la scala di legno
	finestra_z(r, tp.x - 0.15, 0.98, tp.z + 0.38, 0.07, 0.1)
	finestra_x(r, tp.z + 0.1, 0.98, tp.x + 0.38, 0.07, 0.1)
	r.add_child(scatola(Vector3(0.025, 0.08, 0.02), tp + Vector3(0.2, 0.7, 0.385), "buio"))
	r.add_child(scatola(Vector3(0.14, 0.22, 0.02), tp + Vector3(0.12, 0.53, 0.39), "legno_scuro"))
	r.add_child(scatola(Vector3(0.18, 0.03, 0.05), tp + Vector3(0.12, 0.655, 0.4), "blocco"))
	for k in 6:
		r.add_child(scatola(Vector3(0.14, 0.02, 0.06), tp + Vector3(0.12, 0.41 - k * 0.07, 0.45 + k * 0.06), "legno"))
	for s in [-1, 1]:
		r.add_child(scatola(Vector3(0.015, 0.02, 0.46), tp + Vector3(0.12 + s * 0.075, 0.24, 0.6), "legno_vecchio", Vector3(-41, 0, 0)))
	# stendardo
	r.add_child(cilindro(0.01, 0.01, 0.45, tp + Vector3(-0.2, 1.55, -0.2), "legno", Vector3.ZERO, 6))
	r.add_child(scatola(Vector3(0.006, 0.14, 0.2), tp + Vector3(-0.2, 1.69, -0.09), "stoffa"))
	# magazzini della tonnara (il "malfaraggio")
	var c := Node3D.new()
	c.position = Vector3(0.38, 0.02, -0.55)
	r.add_child(c)
	casa_muri(c, 0.88, 0.5, 0.34, 391, "intonaco_sporco")
	for k in 3:
		_vano_arco_z(c, -0.28 + k * 0.28, 0.07, 0.25, 0.14, 0.16, "blocco")
	finestra_x(c, 0.0, 0.3, 0.44, 0.07, 0.08)
	sottotetto(c, 0.88, 0.5, 0.41, 22.0)
	tetto(c, 0.94, 0.5, 0.41, 22.0, 391)
	comignolo(c, Vector3(-0.25, 0.48, -0.1))
	# tettoia con le botti del tonno sotto sale
	for x in [0.88, 1.22]:
		for z in [-0.75, -0.45]:
			r.add_child(cilindro(0.015, 0.015, 0.3, Vector3(x, 0.17, z), "legno_vecchio", Vector3.ZERO, 6))
	_falda(r, 0.42, 0.34, 0.32, 15.0, Vector3(1.05, 0, -0.6), 90.0, 392)
	for k in 3:
		r.add_child(barile(Vector3(0.95 + k * 0.11, 0.02, -0.5), 1.1))
	r.add_child(barile(Vector3(1.0, 0.02, -0.68), 1.1))
	# spiaggia: barche tirate a secco, reti, ancore e tonni
	r.add_child(_barca(Vector3(-0.42, 0.02, 0.42), 20, "bandiera_rossa", 1.3))
	r.add_child(_barca(Vector3(0.12, 0.02, 0.15), -10, "persiana", 1.2))
	r.add_child(_barca(Vector3(0.8, 0.0, 0.85), -40, "giocatore", 1.1))
	_rete(r, Vector3(-1.05, 0.02, 0.2), 0.42, 75)
	for p in [Vector3(-0.75, 0.02, 0.75), Vector3(0.45, 0.02, -0.05)]:
		r.add_child(sfera(0.1, p, "rete", Vector3(1.4, 0.45, 1.0)))
		r.add_child(sfera(0.06, p + Vector3(0.05, 0.03, 0.02), "corda", Vector3(1.2, 0.5, 1.0)))
	r.add_child(_ancora_nave(Vector3(-0.15, 0.025, 0.72), 30))
	for k in 3:
		r.add_child(_tonno(Vector3(-0.05 + k * 0.12, 0.02, -0.05 + k * 0.05), 70 + k * 15))
	var p1 := portatore("pesce")
	p1.position = Vector3(0.25, 0.02, -0.1)
	p1.rotation_degrees.y = -100
	r.add_child(p1)
	var p2 := portatore("")
	p2.position = Vector3(-0.2, 0.02, 0.15)
	p2.rotation_degrees.y = 40
	r.add_child(p2)
	return r


## Castello di Pizzo: grosse torri cilindriche aragonesi e mura su una rupe, con la grotta-chiesa di Piedigrotta.
static func castello_pizzo() -> Node3D:
	var r := Node3D.new()
	_riva(r, [Vector3(0.75, 0.7, 0.62), Vector3(0.2, 0.9, 0.4), Vector3(1.1, 0.15, 0.4)])
	_mare(r, [Vector3(1.3, 1.15, 0.38), Vector3(0.7, 1.4, 0.3)])
	var cc := Vector3(-0.45, 0, -0.45)
	r.add_child(cilindro(0.95, 1.05, 0.2, cc + Vector3(0, 0.1, 0), "tufo", Vector3(0, 10, 0), 10))
	var rng := _rng(401)
	for k in 9:
		var a := deg_to_rad(-30 + k * 18)
		r.add_child(_masso(cc + Vector3(cos(a) * 1.0, 0, sin(a) * 1.0), rng.randf_range(0.12, 0.2), Vector3(1.3, 1.1, 1.0), "tufo", rng.randf() * 180))
	var y0 := 0.2
	var mat := "pietra"
	var mz := "blocco"
	var a1 := cc + Vector3(0.5, y0, 0.5)
	var a2 := cc + Vector3(0.5, y0, -0.5)
	var a3 := cc + Vector3(-0.5, y0, -0.5)
	var a4 := cc + Vector3(-0.5, y0, 0.5)
	r.add_child(scatola(Vector3(1.0, 0.01, 1.0), cc + Vector3(0, y0 + 0.005, 0), "terra"))
	_muro(r, a1, a2, 0.5, 0.16, mat, true, mz)
	_muro(r, a2, a3, 0.5, 0.16, mat, true, mz)
	_muro(r, a3, a4, 0.5, 0.16, mat, true, mz)
	_muro(r, a4, a1, 0.5, 0.16, mat, true, mz)
	# palazzo del castellano nel cortile
	var pz := Node3D.new()
	pz.position = cc + Vector3(-0.15, y0, -0.15)
	r.add_child(pz)
	casa_muri(pz, 0.5, 0.45, 0.55, 402, "pietra_vista")
	finestra_z(pz, 0.0, 0.5, 0.225, 0.07, 0.1)
	sottotetto(pz, 0.5, 0.45, 0.62, 24.0, "pietra_vista")
	tetto(pz, 0.56, 0.45, 0.62, 24.0, 402)
	# torri: il grosso mastio cilindrico sull'angolo in vista, un'altra torre grossa e due minori
	_torre_tonda(r, a1, 0.34, 0.95, mat, mz, true, "", 0.08)
	_torre_tonda(r, a2, 0.3, 0.8, mat, mz, true, "", 0.07)
	_torre_tonda(r, a4, 0.22, 0.7, mat, mz, true, "", 0.05)
	_torre_tonda(r, a3, 0.2, 0.65, mat, mz, true)
	# porta sul lato in vista
	var gx := cc.x - 0.15
	var zf := cc.z + 0.5 + 0.085
	r.add_child(scatola(Vector3(0.18, 0.2, 0.02), Vector3(gx, y0 + 0.1, zf), "buio"))
	r.add_child(cilindro(0.09, 0.09, 0.02, Vector3(gx, y0 + 0.2, zf), "buio", Vector3(90, 0, 0), 12))
	_arco(r, Vector3(gx, y0, zf + 0.01), 0.18, 0.2, 0.04, "blocco", 0, "blocco")
	r.add_child(scatola(Vector3(0.12, 0.08, 0.01), Vector3(gx, y0 + 0.4, zf + 0.0), "moneta"))
	for k in 3:
		r.add_child(scatola(Vector3(0.014, 0.08, 0.012), Vector3(gx - 0.035 + k * 0.035, y0 + 0.4, zf + 0.006), "bandiera_rossa"))
	for k in 4:
		r.add_child(scatola(Vector3(0.22, 0.05, 0.1), Vector3(gx, 0.025 + k * 0.05, zf + 0.42 - k * 0.1), "blocco"))
	# stendardo aragonese sul mastio
	var tb := a1 + Vector3(0, 1.05, 0)
	r.add_child(cilindro(0.012, 0.012, 0.5, tb + Vector3(0, 0.25, 0), "legno", Vector3.ZERO, 6))
	r.add_child(scatola(Vector3(0.006, 0.16, 0.24), tb + Vector3(0, 0.42, 0.12), "moneta"))
	for k in 3:
		r.add_child(scatola(Vector3(0.008, 0.16, 0.03), tb + Vector3(0, 0.42, 0.04 + k * 0.07), "bandiera_rossa"))
	# Piedigrotta: chiesetta scavata nello scoglio di tufo, sulla spiaggia
	var g := Vector3(0.72, 0.0, 0.62)
	r.add_child(_masso(g + Vector3(-0.32, 0, -0.25), 0.42, Vector3(1.1, 1.3, 1.0), "tufo", 70))
	r.add_child(_masso(g + Vector3(0.3, 0, -0.25), 0.36, Vector3(1.0, 1.2, 1.0), "tufo", 10))
	r.add_child(_masso(g + Vector3(0, 0, -0.1), 0.45, Vector3(1.1, 1.25, 0.8), "tufo", 20))
	var zg := g.z + 0.2
	r.add_child(scatola(Vector3(0.38, 0.36, 0.08), Vector3(g.x, 0.18, zg), "intonaco_bianco"))
	r.add_child(scatola(Vector3(0.42, 0.03, 0.1), Vector3(g.x, 0.37, zg), "tufo"))
	_vano_arco_z(r, g.x, 0.0, zg + 0.04, 0.13, 0.16, "tufo")
	for s in [-1, 1]:
		_vano_arco_z(r, g.x + s * 0.13, 0.2, zg + 0.04, 0.04, 0.06, "tufo")
	r.add_child(scatola(Vector3(0.12, 0.08, 0.06), Vector3(g.x, 0.425, zg), "intonaco_bianco"))
	r.add_child(scatola(Vector3(0.05, 0.05, 0.065), Vector3(g.x, 0.425, zg), "buio"))
	r.add_child(sfera(0.018, Vector3(g.x, 0.42, zg + 0.02), "bronzo", Vector3(1, 1.2, 1)))
	_croce(r, Vector3(g.x, 0.465, zg), 0.6)
	for s in [-1, 1]:
		r.add_child(scatola(Vector3(0.06, 0.08, 0.06), Vector3(g.x + s * 0.27, 0.04, zg + 0.12), "tufo"))
		r.add_child(_statua(Vector3(g.x + s * 0.27, 0.08, zg + 0.12), 0.5, 180 + s * 20))
	for p in [Vector3(0.52, 0.14, -0.02), Vector3(-0.58, 0.16, -0.05), Vector3(0.3, 0.35, -0.02)]:
		r.add_child(sfera(0.055, g + p, "buio", Vector3(1, 0.8, 0.6)))
	for k in 6:
		_ciuffo(r, g + Vector3(rng.randf_range(-0.45, 0.4), rng.randf_range(0.4, 0.5), rng.randf_range(-0.4, -0.15)), 1.2)
	r.add_child(_barca(Vector3(0.15, 0.02, 1.0), -20, "persiana", 1.0))
	return r


## Santa Maria dell'Isola: scoglio alto di roccia chiara con la chiesetta bianca in cima e la scala scavata.
static func santa_maria_isola() -> Node3D:
	var r := Node3D.new()
	_mare(r, [Vector3(0.0, 0.1, 1.2), Vector3(0.75, 0.65, 0.55), Vector3(-0.65, 0.7, 0.5)])
	_riva(r, [Vector3(0.45, 0.95, 0.32)])
	r.add_child(cilindro(0.95, 0.95, 0.02, Vector3(0, 0.01, 0), "intonaco_bianco", Vector3.ZERO, 9))
	# lo scoglio, a balze
	r.add_child(cilindro(0.75, 0.88, 0.36, Vector3(0, 0.18, 0), "tufo", Vector3(0, 5, 0), 9))
	r.add_child(cilindro(0.6, 0.72, 0.4, Vector3(0.0, 0.56, -0.05), "tufo", Vector3(0, 25, 0), 8))
	r.add_child(cilindro(0.5, 0.58, 0.25, Vector3(-0.05, 0.885, -0.1), "tufo", Vector3(0, 45, 0), 9))
	var rng := _rng(411)
	for k in 9:
		var a := k * TAU / 9 + 0.3
		r.add_child(_masso(Vector3(cos(a) * 0.85, 0.0, sin(a) * 0.85), rng.randf_range(0.14, 0.24), Vector3(1.2, 1.3, 1.0), "tufo", rng.randf() * 180))
	for k in 12:
		var a := rng.randf_range(-0.6, 2.4)
		var y: float = [0.36, 0.76][k % 2]
		var rr: float = [0.73, 0.58][k % 2]
		r.add_child(sfera(0.045, Vector3(cos(a) * rr, y + 0.01, sin(a) * rr - 0.05 * (k % 2)), "macchia", Vector3(1.4, 0.6, 1.1)))
	for q in [Vector3(20, 0.36, 0.66), Vector3(48, 0.36, 0.66), Vector3(85, 0.76, 0.52), Vector3(110, 0.76, 0.52), Vector3(-25, 0.76, 0.52), Vector3(60, 1.0, 0.0)]:
		if q.z > 0.0:
			var aq := deg_to_rad(q.x)
			r.add_child(_masso(Vector3(cos(aq) * q.z, q.y, sin(aq) * q.z - 0.05), rng.randf_range(0.12, 0.17), Vector3(1.3, 1.1, 1.0), "tufo", rng.randf() * 180))
	# scala scavata che sale girando attorno allo scoglio
	var n := 26
	for k in n:
		var t := float(k) / (n - 1)
		var a := deg_to_rad(115.0 - t * 140.0)
		var y := 0.04 + t * 0.96
		var rr := 0.0
		var cz := 0.0
		var cx := 0.0
		if y < 0.36:
			rr = 0.88 - 0.13 * (y / 0.36)
		elif y < 0.76:
			rr = 0.72 - 0.12 * ((y - 0.36) / 0.4)
			cz = -0.05
		else:
			rr = 0.58 - 0.08 * ((y - 0.76) / 0.24)
			cz = -0.1
			cx = -0.05
		var p := Vector3(cx + cos(a) * (rr + 0.03), 0, cz + sin(a) * (rr + 0.03))
		var ruota := Vector3(0, -rad_to_deg(a) - 90, 0)
		r.add_child(scatola(Vector3(0.12, y, 0.13), p + Vector3(0, y * 0.5, 0), "tufo", ruota))
		r.add_child(scatola(Vector3(0.12, 0.015, 0.14), p + Vector3(0, y + 0.007, 0), "blocco", ruota))
	# chiesetta in cima
	var top := 1.01
	r.add_child(cilindro(0.5, 0.5, 0.02, Vector3(-0.05, top - 0.005, -0.1), "blocco", Vector3(0, 45, 0), 9))
	var ch := Node3D.new()
	ch.position = Vector3(-0.08, top, -0.18)
	r.add_child(ch)
	casa_muri(ch, 0.36, 0.56, 0.3, 412, "intonaco_bianco")
	var nt := Node3D.new()
	nt.rotation_degrees.y = 90
	ch.add_child(nt)
	sottotetto(nt, 0.56, 0.36, 0.37, 26.0, "intonaco_bianco")
	tetto(nt, 0.56, 0.36, 0.37, 26.0, 412)
	ch.add_child(scatola(Vector3(0.42, 0.38, 0.05), Vector3(0, 0.07 + 0.19, 0.305), "intonaco_bianco"))
	var fr := MeshInstance3D.new()
	var pm := PrismMesh.new()
	pm.size = Vector3(0.44, 0.13, 0.05)
	fr.mesh = pm
	fr.position = Vector3(0, 0.45 + 0.065, 0.305)
	fr.material_override = materiale("intonaco_bianco")
	ch.add_child(fr)
	ch.add_child(scatola(Vector3(0.46, 0.02, 0.07), Vector3(0, 0.455, 0.31), "pietra"))
	_vano_arco_z(ch, 0.0, 0.07, 0.33, 0.1, 0.15, "pietra")
	ch.add_child(scatola(Vector3(0.09, 0.15, 0.02), Vector3(0, 0.07 + 0.075, 0.342), "legno_scuro"))
	_rosone(ch, Vector3(0, 0.38, 0.335), 0.045)
	_vano_arco_x(ch, 0.0, 0.2, 0.18, 0.05, 0.1, "pietra")
	# campaniletto a vela sul fianco
	ch.add_child(scatola(Vector3(0.05, 0.22, 0.18), Vector3(0.12, 0.5, -0.15), "intonaco_bianco"))
	ch.add_child(scatola(Vector3(0.054, 0.08, 0.07), Vector3(0.12, 0.53, -0.15), "buio"))
	ch.add_child(sfera(0.022, Vector3(0.15, 0.53, -0.15), "bronzo", Vector3(1, 1.2, 1)))
	ch.add_child(scatola(Vector3(0.07, 0.02, 0.2), Vector3(0.12, 0.62, -0.15), "pietra"))
	_croce(ch, Vector3(0.12, 0.63, -0.15), 0.6)
	_croce(ch, Vector3(0, 0.58, 0.305), 0.7)
	_cipresso(r, Vector3(-0.38, top, 0.12), 0.45)
	r.add_child(vaso_fiori(Vector3(0.2, top, 0.15)))
	# barca ormeggiata ai piedi della scala
	r.add_child(_barca(Vector3(-0.55, 0.0, 0.95), 15, "persiana", 1.0))
	return r


# =================================================================== BRETTII (step 19)
# Lo stile dei Brettii: pietra grezza a secco, tronchi spaccati messi in piedi, tetti spessi di paglia o di scandole
# tenute da sassi, corna di legno incrociate sui colmi, pali intagliati e dipinti, pelli stese, stoffe verde bosco.
# Ogni modello ha lo stesso ingombro del corrispondente greco (stesso nome senza "_brettii").

## Muri di pietra grezza a secco: sassi sporgenti, pali d'angolo e travi di gronda in vista. Base a quota 0.
static func _muri_pietra_b(r: Node3D, lx: float, lz: float, h: float, seme: int) -> void:
	var rng := _rng(seme)
	r.add_child(scatola(Vector3(lx + 0.08, 0.05, lz + 0.08), Vector3(0, 0.025, 0), "roccia_massi"))
	r.add_child(scatola(Vector3(lx, h, lz), Vector3(0, h * 0.5, 0), "pietra_grezza"))
	for k in int(lx * 16):
		var p := Vector3(rng.randf_range(-lx * 0.46, lx * 0.46), rng.randf_range(0.05, h - 0.04), lz * 0.5)
		r.add_child(sfera(rng.randf_range(0.022, 0.038), p, "roccia_massi" if k % 3 != 0 else "pietra", Vector3(1.4, 0.75, 0.35)))
	for k in int(lz * 16):
		var p := Vector3(lx * 0.5, rng.randf_range(0.05, h - 0.04), rng.randf_range(-lz * 0.46, lz * 0.46))
		r.add_child(sfera(rng.randf_range(0.022, 0.038), p, "roccia_massi" if k % 3 != 0 else "pietra", Vector3(0.35, 0.75, 1.4)))
	for c: Vector3 in [Vector3(lx * 0.5, 0, lz * 0.5), Vector3(-lx * 0.5, 0, lz * 0.5), Vector3(lx * 0.5, 0, -lz * 0.5)]:
		r.add_child(cilindro(0.03, 0.034, h + 0.02, c + Vector3(0, h * 0.5 + 0.01, 0), "corteccia", Vector3.ZERO, 7))
	r.add_child(cilindro(0.026, 0.026, lx + 0.12, Vector3(0, h, lz * 0.5 + 0.012), "legno_vecchio", Vector3(0, 0, 90), 7))
	r.add_child(cilindro(0.026, 0.026, lz + 0.12, Vector3(lx * 0.5 + 0.012, h, 0), "legno_vecchio", Vector3(90, 0, 0), 7))


## Muri di tronchi spaccati messi in piedi, su uno zoccolo alto di pietra grezza, legati da due traverse.
static func _muri_tavole_b(r: Node3D, lx: float, lz: float, h: float, seme: int) -> void:
	var rng := _rng(seme)
	var hp := h * 0.34
	r.add_child(scatola(Vector3(lx + 0.06, hp, lz + 0.06), Vector3(0, hp * 0.5, 0), "pietra_grezza"))
	for k in int(lx * 9):
		r.add_child(sfera(rng.randf_range(0.02, 0.032), Vector3(rng.randf_range(-lx * 0.46, lx * 0.46), rng.randf_range(0.03, hp - 0.02), lz * 0.5 + 0.03), "roccia_massi", Vector3(1.4, 0.75, 0.35)))
	for k in int(lz * 9):
		r.add_child(sfera(rng.randf_range(0.02, 0.032), Vector3(lx * 0.5 + 0.03, rng.randf_range(0.03, hp - 0.02), rng.randf_range(-lz * 0.46, lz * 0.46)), "roccia_massi", Vector3(0.35, 0.75, 1.4)))
	var hl := h - hp
	r.add_child(scatola(Vector3(lx - 0.02, hl, lz - 0.02), Vector3(0, hp + hl * 0.5, 0), "legno_scuro"))
	var nx := int(lx / 0.048)
	for k in nx:
		var hh := hl + rng.randf_range(-0.012, 0.012)
		r.add_child(cilindro(0.025, 0.025, hh, Vector3(-lx * 0.5 + (k + 0.5) * lx / nx, hp + hh * 0.5, lz * 0.5 - 0.01), "legno" if k % 4 != 1 else "legno_vecchio", Vector3.ZERO, 7))
	var nz := int(lz / 0.048)
	for k in nz:
		var hh := hl + rng.randf_range(-0.012, 0.012)
		r.add_child(cilindro(0.025, 0.025, hh, Vector3(lx * 0.5 - 0.01, hp + hh * 0.5, -lz * 0.5 + (k + 0.5) * lz / nz), "legno" if k % 4 != 2 else "legno_vecchio", Vector3.ZERO, 7))
	for y: float in [hp + hl * 0.3, hp + hl * 0.85]:
		r.add_child(scatola(Vector3(lx + 0.06, 0.03, 0.025), Vector3(0, y, lz * 0.5 + 0.02), "legno_vecchio"))
		r.add_child(scatola(Vector3(0.025, 0.03, lz + 0.06), Vector3(lx * 0.5 + 0.02, y, 0), "legno_vecchio"))


## Tetto spesso di paglia a due falde (colmo lungo X) che scende basso sulle gronde: strati sfalsati,
## gronda arrotondata, colmo legato, bastoni incrociati sul colmo e corna di legno dipinte sui timpani.
## base_y è la cima dei muri, lz la loro profondità (il timpano si chiude con sottotetto(..., base_y, pendenza)).
static func _tetto_paglia(r: Node3D, larg: float, lz: float, base_y: float, pendenza: float, seme: int, corna := true) -> void:
	var rng := _rng(seme)
	var sporto := 0.1
	var meta := lz * 0.5 + sporto
	var ang := deg_to_rad(pendenza)
	var lung := meta / cos(ang)
	var alt := meta * tan(ang)
	var y0 := base_y - sporto * tan(ang)
	for lato: int in [-1, 1]:
		var f := Node3D.new()
		f.position = Vector3(0, y0 + alt * 0.5, lato * meta * 0.5)
		f.rotation.x = lato * ang
		r.add_child(f)
		f.add_child(scatola(Vector3(larg + 0.18, 0.06, lung), Vector3.ZERO, "paglia_scura"))
		var file := maxi(3, int(lung / 0.075))
		for k in file:
			var z := lato * (lung * 0.5 - (k + 0.6) * lung / file)
			var mat := "paglia_tetto" if rng.randf() < 0.75 else "paglia_scura"
			f.add_child(scatola(Vector3(larg + 0.19 + rng.randf_range(-0.01, 0.02), 0.03, lung / file * 1.25), Vector3(rng.randf_range(-0.01, 0.01), 0.035, z), mat, Vector3(-9 * lato, 0, 0)))
		# gronda sfrangiata: ciuffi di paglia
		var nc := int((larg + 0.2) / 0.055)
		for k in nc:
			var x := -larg * 0.5 - 0.1 + (k + 0.5) * (larg + 0.2) / nc
			f.add_child(sfera(rng.randf_range(0.036, 0.046), Vector3(x, 0.0, lato * (lung * 0.5 - 0.01)), "paglia_scura" if k % 3 == 0 else "paglia_tetto", Vector3(0.9, 0.55, 1.1)))
		# bastoni incrociati che tengono la paglia del colmo
		var nb := maxi(2, int(larg / 0.26))
		for k in nb:
			var x := -larg * 0.5 + (k + 0.5) * larg / nb
			f.add_child(cilindro(0.008, 0.008, 0.2, Vector3(x, 0.06, -lato * (lung * 0.5 - 0.06)), "legno_scuro", Vector3(90, 0, 0), 5))
		if corna:
			for lc: int in [-1, 1]:
				f.add_child(cilindro(0.014, 0.01, 0.36, Vector3(lc * (larg * 0.5 + 0.09), 0.05, -lato * (lung * 0.5 - 0.1)), "legno_vecchio", Vector3(90, 0, 0), 6))
				f.add_child(sfera(0.017, Vector3(lc * (larg * 0.5 + 0.09), 0.05, -lato * (lung * 0.5 + 0.08)), "stoffa_verde"))
	var yc := y0 + alt + 0.03
	r.add_child(cilindro(0.058, 0.058, larg + 0.22, Vector3(0, yc, 0), "paglia_scura", Vector3(0, 0, 90), 10))
	var nl := maxi(1, int(larg / 0.16))
	for k in nl + 1:
		r.add_child(cilindro(0.061, 0.061, 0.012, Vector3(-larg * 0.5 + k * larg / nl, yc, 0), "corda", Vector3(0, 0, 90), 10))


## Tetto di scandole tenuto fermo da pertiche e grossi sassi (come nelle baite di montagna).
static func _tetto_scandole_sassi(r: Node3D, larg: float, prof: float, base_y: float, pendenza: float, seme: int) -> void:
	tetto_scandole(r, larg, prof, base_y, pendenza)
	var rng := _rng(seme)
	var meta := prof * 0.5 + 0.06
	var ang := deg_to_rad(pendenza)
	var lung := meta / cos(ang)
	var alt := meta * tan(ang)
	for lato: int in [-1, 1]:
		var f := Node3D.new()
		f.position = Vector3(0, base_y + alt * 0.5, lato * meta * 0.5)
		f.rotation.x = lato * ang
		r.add_child(f)
		for t in 2:
			var z := lato * (lung * 0.5 - 0.07 - t * lung * 0.42)
			f.add_child(cilindro(0.016, 0.016, larg + 0.12, Vector3(0, 0.04, z), "corteccia", Vector3(0, 0, 90), 6))
			for k in int(larg / 0.17):
				var x := -larg * 0.5 + 0.09 + k * 0.17 + rng.randf_range(-0.025, 0.025)
				f.add_child(sfera(rng.randf_range(0.03, 0.04), Vector3(x, 0.05, z - lato * 0.035), "roccia_massi", Vector3(1.2, 0.65, 1.0)))


## Tettoia a una falda di paglia su pali: alta dietro (-Z), bassa davanti (+Z). pos = centro a terra.
static func _tettoia_paglia(r: Node3D, pos: Vector3, larg: float, prof: float, h_alta: float, h_bassa: float, pali_dietro := true) -> void:
	var dh := h_alta - h_bassa
	var ang := atan2(dh, prof)
	var lung := sqrt(prof * prof + dh * dh) + 0.12
	var xs := [-larg * 0.5, larg * 0.5]
	if larg > 0.7:
		xs.append(0.0)
	for x: float in xs:
		r.add_child(cilindro(0.016, 0.019, h_bassa, pos + Vector3(x, h_bassa * 0.5, prof * 0.5), "corteccia", Vector3.ZERO, 6))
		if pali_dietro:
			r.add_child(cilindro(0.016, 0.019, h_alta, pos + Vector3(x, h_alta * 0.5, -prof * 0.5), "corteccia", Vector3.ZERO, 6))
	r.add_child(scatola(Vector3(larg + 0.14, 0.05, lung), pos + Vector3(0, (h_alta + h_bassa) * 0.5 + 0.03, 0.0), "paglia_tetto", Vector3(rad_to_deg(ang), 0, 0)))
	r.add_child(scatola(Vector3(larg + 0.15, 0.024, lung * 0.5), pos + Vector3(0, (h_alta + h_bassa) * 0.5 + 0.06 - dh * 0.25, prof * 0.25), "paglia_scura", Vector3(rad_to_deg(ang) - 3, 0, 0)))
	r.add_child(cilindro(0.03, 0.03, larg + 0.16, pos + Vector3(0, h_bassa + 0.0, prof * 0.5 + 0.06), "paglia_scura", Vector3(0, 0, 90), 8))
	r.add_child(cilindro(0.014, 0.014, larg + 0.08, pos + Vector3(0, h_bassa - 0.01, prof * 0.5), "legno_vecchio", Vector3(0, 0, 90), 6))


## Capanna tonda dei pastori: muro basso di pietra grezza e alto cono di paglia a strati legati.
## porta_ang: direzione della porta in gradi (0 = verso +Z, 90 = verso +X).
static func _capanna_tonda(r: Node3D, pos: Vector3, rg: float, h: float, seme: int, porta_ang := 25.0) -> void:
	var rng := _rng(seme)
	r.add_child(cilindro(rg + 0.04, rg + 0.05, 0.04, pos + Vector3(0, 0.02, 0), "roccia_massi", Vector3.ZERO, 16))
	r.add_child(cilindro(rg, rg + 0.01, h, pos + Vector3(0, h * 0.5, 0), "pietra_grezza", Vector3.ZERO, 20))
	for k in int(rg * 44):
		var a := deg_to_rad(rng.randf_range(-30.0, 120.0))
		var d := Vector3(cos(a), 0, sin(a))
		var s := sfera(rng.randf_range(0.022, 0.034), pos + d * (rg + 0.002) + Vector3(0, rng.randf_range(0.05, h - 0.03), 0), "roccia_massi" if k % 3 != 0 else "pietra", Vector3(1.3, 0.75, 0.4))
		s.rotation.y = PI * 0.5 - a
		r.add_child(s)
	# cono di paglia a tre strati legati
	var hc := rg * 1.75
	var y1 := h - 0.02
	r.add_child(cilindro(rg + 0.07, rg * 0.5, hc * 0.5, pos + Vector3(0, y1 + hc * 0.25, 0), "paglia_tetto", Vector3.ZERO, 20))
	var nc := int(rg * 50)
	for k in nc:
		var a := k * TAU / nc
		var ciuffo := sfera(0.035, pos + Vector3(cos(a) * (rg + 0.065), y1 + 0.01, sin(a) * (rg + 0.065)), "paglia_scura" if k % 3 == 0 else "paglia_tetto", Vector3(1.1, 0.55, 0.8))
		ciuffo.rotation.y = PI * 0.5 - a
		r.add_child(ciuffo)
	var y2 := y1 + hc * 0.5 - 0.045
	r.add_child(cilindro(rg * 0.6, rg * 0.2, hc * 0.32, pos + Vector3(0, y2 + hc * 0.16, 0), "paglia_scura", Vector3.ZERO, 18))
	r.add_child(cilindro(rg * 0.56, rg * 0.56, 0.02, pos + Vector3(0, y2 + 0.02, 0), "legno_scuro", Vector3.ZERO, 18))
	var y3 := y2 + hc * 0.32 - 0.035
	r.add_child(cilindro(rg * 0.25, 0.015, hc * 0.24, pos + Vector3(0, y3 + hc * 0.12, 0), "paglia_tetto", Vector3.ZERO, 14))
	r.add_child(cilindro(rg * 0.23, rg * 0.23, 0.016, pos + Vector3(0, y3 + 0.015, 0), "legno_scuro", Vector3.ZERO, 14))
	r.add_child(cilindro(0.011, 0.011, 0.2, pos + Vector3(0, y3 + hc * 0.24 + 0.04, 0), "legno_vecchio", Vector3.ZERO, 5))
	_teschio(r, pos + Vector3(0, y3 + hc * 0.24 + 0.14, 0), 45.0, 1.1)
	var t := deg_to_rad(porta_ang)
	_porta_b(r, pos + Vector3(sin(t), 0, cos(t)) * (rg - 0.008), porta_ang, 0.12, 0.2)


## Teschio di montone con le corna (sopra le porte e in cima ai pali).
static func _teschio(r: Node3D, pos: Vector3, rot_y := 45.0, s := 1.0) -> void:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot_y
	n.scale = Vector3.ONE * s
	r.add_child(n)
	n.add_child(sfera(0.024, Vector3.ZERO, "osso", Vector3(1.0, 0.9, 0.8)))
	n.add_child(sfera(0.014, Vector3(0, -0.022, 0.012), "osso", Vector3(0.9, 1.3, 0.8)))
	for lato: int in [-1, 1]:
		n.add_child(sfera(0.006, Vector3(lato * 0.01, 0.002, 0.018), "fuliggine"))
		n.add_child(cilindro(0.009, 0.006, 0.05, Vector3(lato * 0.035, 0.012, 0), "osso", Vector3(0, 0, -70 * lato), 5))
		n.add_child(cilindro(0.006, 0.002, 0.04, Vector3(lato * 0.068, 0.003, 0.006), "osso", Vector3(0, 0, -150 * lato), 5))


## Porta dei Brettii (nel nodo locale guarda verso +Z): tavole scure o tenda verde, stipiti di tronco,
## architrave, teschio sopra e soglia di pietra piatta. pos è il piede della porta sulla facciata.
static func _porta_b(r: Node3D, pos: Vector3, rot_y: float, w := 0.13, h := 0.23, tenda := false) -> void:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot_y
	r.add_child(n)
	n.add_child(scatola(Vector3(w, h, 0.03), Vector3(0, h * 0.5, 0), "buio" if tenda else "legno_scuro"))
	if tenda:
		n.add_child(scatola(Vector3(w * 0.62, h - 0.01, 0.008), Vector3(-w * 0.2, h * 0.5, 0.02), "stoffa_verde", Vector3(0, 0, 3)))
		n.add_child(scatola(Vector3(w * 0.25, h - 0.03, 0.008), Vector3(w * 0.36, h * 0.5 + 0.01, 0.02), "stoffa_verde", Vector3(0, 0, -4)))
		n.add_child(scatola(Vector3(w * 0.9, 0.014, 0.01), Vector3(0, h * 0.62, 0.026), "tufo"))
	else:
		for k in 3:
			n.add_child(scatola(Vector3(w * 0.28, h - 0.015, 0.008), Vector3(-w * 0.32 + k * w * 0.32, h * 0.5, 0.017), "legno_vecchio"))
		for y: float in [h * 0.25, h * 0.7]:
			n.add_child(scatola(Vector3(w * 0.9, 0.018, 0.012), Vector3(0, y, 0.024), "legno"))
	for lato: int in [-1, 1]:
		n.add_child(cilindro(0.018, 0.02, h + 0.04, Vector3(lato * (w * 0.5 + 0.016), h * 0.5 + 0.02, 0.018), "corteccia", Vector3.ZERO, 6))
	n.add_child(cilindro(0.022, 0.022, w + 0.14, Vector3(0, h + 0.035, 0.022), "legno_vecchio", Vector3(0, 0, 90), 7))
	_teschio(n, Vector3(0, h + 0.085, 0.035), 0.0, 1.0)
	n.add_child(sfera(0.075, Vector3(0, 0.0, 0.07), "roccia_massi", Vector3(1.3, 0.22, 0.8)))


## Finestrella quadrata con telaio di legno e una pelle arrotolata sopra (nel nodo locale guarda verso +Z).
static func _finestrella_b(r: Node3D, pos: Vector3, rot_y: float, w := 0.08, h := 0.08) -> void:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot_y
	r.add_child(n)
	n.add_child(scatola(Vector3(w, h, 0.02), Vector3.ZERO, "buio"))
	for lato: int in [-1, 1]:
		n.add_child(scatola(Vector3(0.016, h + 0.03, 0.02), Vector3(lato * (w * 0.5 + 0.008), 0, 0.01), "legno_scuro"))
		n.add_child(scatola(Vector3(w + 0.04, 0.016, 0.02), Vector3(0, lato * (h * 0.5 + 0.008), 0.01), "legno_scuro"))
	n.add_child(cilindro(0.017, 0.017, w + 0.03, Vector3(0, h * 0.5 + 0.03, 0.022), "pelliccia", Vector3(0, 0, 90), 7))


## Palo intagliato: rocchi con occhi incisi, rombi e fasce dipinte (verde, rosso, ocra), testa di montone in cima.
static func _totem(r: Node3D, pos: Vector3, h := 0.5, seme := 1) -> void:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = 45
	r.add_child(n)
	for k in 4:
		var a := k * TAU / 4 + 0.4
		n.add_child(sfera(0.035, Vector3(cos(a) * 0.055, 0.0, sin(a) * 0.055), "roccia_massi", Vector3(1.2, 0.8, 1.0)))
	var seg := 4
	var hs := h * 0.82 / seg
	var colori := ["stoffa_verde", "bandiera_rossa", "tufo", "stoffa_verde"]
	for k in seg:
		var rr := 0.036 if k % 2 == 0 else 0.044
		n.add_child(cilindro(rr, rr * 0.9, hs, Vector3(0, hs * (k + 0.5), 0), "legno" if k % 2 == 0 else "legno_vecchio", Vector3.ZERO, 9))
		n.add_child(cilindro(rr * 0.92 + 0.004, rr * 0.92 + 0.004, 0.016, Vector3(0, hs * (k + 1) - 0.01, 0), colori[(k + seme) % 4], Vector3.ZERO, 9))
		if k % 2 == 1:
			for lato: int in [-1, 1]:
				n.add_child(sfera(0.009, Vector3(lato * 0.017, hs * (k + 0.6), rr * 0.93), "fuliggine"))
			n.add_child(scatola(Vector3(0.032, 0.008, 0.01), Vector3(0, hs * (k + 0.28), rr * 0.95), "fuliggine"))
		else:
			n.add_child(scatola(Vector3(0.024, 0.024, 0.01), Vector3(0, hs * (k + 0.45), rr * 0.97), colori[(k + seme + 1) % 4], Vector3(0, 0, 45)))
	var top := h * 0.82
	n.add_child(sfera(0.045, Vector3(0, top + 0.035, 0), "legno", Vector3(1.0, 1.0, 1.15)))
	n.add_child(sfera(0.026, Vector3(0, top + 0.015, 0.045), "legno", Vector3(0.9, 1.0, 1.2)))
	for lato: int in [-1, 1]:
		n.add_child(sfera(0.009, Vector3(lato * 0.022, top + 0.05, 0.036), "fuliggine"))
		n.add_child(cilindro(0.016, 0.008, 0.1, Vector3(lato * 0.06, top + 0.075, 0), "osso", Vector3(0, 0, -60 * lato), 6))
		n.add_child(cilindro(0.009, 0.003, 0.07, Vector3(lato * 0.128, top + 0.075, 0.01), "osso", Vector3(0, 0, -135 * lato), 6))


## Insegna dei Brettii: asta con traversa, drappo verde bosco con disco ocra e code, teschio in cima.
static func _stendardo_b(r: Node3D, pos: Vector3, h := 0.6) -> void:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = 45
	r.add_child(n)
	n.add_child(cilindro(0.012, 0.015, h, Vector3(0, h * 0.5, 0), "corteccia", Vector3.ZERO, 6))
	n.add_child(cilindro(0.008, 0.008, 0.2, Vector3(0, h - 0.05, 0.01), "legno_vecchio", Vector3(0, 0, 90), 5))
	n.add_child(scatola(Vector3(0.17, 0.2, 0.006), Vector3(0, h - 0.155, 0.014), "stoffa_verde"))
	for k in 5:
		n.add_child(scatola(Vector3(0.026, 0.045, 0.006), Vector3(-0.068 + k * 0.034, h - 0.275, 0.014), "stoffa_verde" if k % 2 == 0 else "tufo"))
	n.add_child(cilindro(0.04, 0.04, 0.004, Vector3(0, h - 0.15, 0.019), "tufo", Vector3(90, 0, 0), 14))
	n.add_child(cilindro(0.02, 0.02, 0.005, Vector3(0, h - 0.15, 0.021), "bandiera_rossa", Vector3(90, 0, 0), 10))
	_teschio(n, Vector3(0, h + 0.02, 0.0), 0.0, 1.1)


## Rastrelliera con pelli messe ad asciugare a cavallo di una stanga.
static func _pelli_stese(r: Node3D, pos: Vector3, rot_y := 0.0) -> void:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot_y
	r.add_child(n)
	for lato: int in [-1, 1]:
		n.add_child(cilindro(0.011, 0.013, 0.3, Vector3(lato * 0.14, 0.15, 0), "corteccia", Vector3.ZERO, 5))
	n.add_child(cilindro(0.01, 0.01, 0.34, Vector3(0, 0.29, 0), "legno_vecchio", Vector3(0, 0, 90), 5))
	for p: Array in [["pelliccia", -0.065, 0.16], ["capra", 0.07, 0.13]]:
		for lato: int in [-1, 1]:
			n.add_child(scatola(Vector3(0.11, p[2], 0.006), Vector3(p[1], 0.29 - p[2] * 0.48, lato * 0.014), p[0], Vector3(-8 * lato, 0, 0)))
		n.add_child(scatola(Vector3(0.018, 0.03, 0.006), Vector3(p[1] - 0.045, 0.29 - p[2] - 0.005, 0.02), p[0], Vector3(-8, 0, 15)))
		n.add_child(scatola(Vector3(0.018, 0.03, 0.006), Vector3(p[1] + 0.045, 0.29 - p[2] - 0.005, 0.02), p[0], Vector3(-8, 0, -15)))


## Pelle conciata tesa su un telaio di rami appoggiato a terra.
static func _telaio_pelle(r: Node3D, pos: Vector3, rot_y := 0.0) -> void:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees = Vector3(-14, rot_y, 0)
	r.add_child(n)
	var l := 0.24
	for lato: int in [-1, 1]:
		n.add_child(cilindro(0.009, 0.009, l + 0.06, Vector3(lato * l * 0.5, l * 0.5 + 0.01, 0), "corteccia", Vector3.ZERO, 5))
		n.add_child(cilindro(0.009, 0.009, l + 0.06, Vector3(0, l * 0.5 + 0.01 + lato * l * 0.5, 0), "corteccia", Vector3(0, 0, 90), 5))
	n.add_child(sfera(0.1, Vector3(0, l * 0.5 + 0.01, 0.004), "capra", Vector3(0.85, 1.05, 0.04)))
	for sx: int in [-1, 1]:
		for sy: int in [-1, 1]:
			ramo(n, Vector3(sx * 0.07, l * 0.5 + 0.01 + sy * 0.075, 0.005), Vector3(sx * l * 0.5, l * 0.5 + 0.01 + sy * l * 0.5, 0.0), 0.003, "corda")


## Palizzata di pali appuntiti con una traversa.
static func _palizzata(r: Node3D, da: Vector3, a: Vector3, h := 0.3) -> void:
	var lung := da.distance_to(a)
	var n := maxi(1, int(lung / 0.046))
	for k in n + 1:
		var p := da.lerp(a, float(k) / n)
		var hh := h * (0.9 + 0.05 * float((k * 7) % 3))
		r.add_child(cilindro(0.023, 0.025, hh, p + Vector3(0, hh * 0.5, 0), "corteccia", Vector3.ZERO, 6))
		r.add_child(cilindro(0.023, 0.0, 0.06, p + Vector3(0, hh + 0.03, 0), "legno_chiaro", Vector3.ZERO, 6))
	var dir := (a - da).normalized()
	var rot := rad_to_deg(atan2(dir.x, dir.z))
	r.add_child(scatola(Vector3(0.065, 0.025, lung), (da + a) * 0.5 + Vector3(0, h * 0.62, 0), "legno_vecchio", Vector3(0, rot, 0)))


## Recinto di graticcio: paletti e rami intrecciati.
static func _graticcio(r: Node3D, da: Vector3, a: Vector3, h := 0.1) -> void:
	var lung := da.distance_to(a)
	var n := int(lung / 0.1) + 1
	for k in n + 1:
		var p := da.lerp(a, float(k) / n)
		r.add_child(cilindro(0.009, 0.008, h + 0.025, p + Vector3(0, (h + 0.025) * 0.5, 0), "legno_vecchio", Vector3.ZERO, 5))
	var dir := (a - da).normalized()
	var rot := rad_to_deg(atan2(dir.x, dir.z))
	for i in 4:
		r.add_child(scatola(Vector3(0.017, 0.02, lung), (da + a) * 0.5 + Vector3(0, 0.02 + i * h * 0.26, 0), "paglia_scura" if i % 2 == 0 else "legno_vecchio", Vector3(0, rot, 0)))


## Fuoco all'aperto: cerchio di sassi, ceppi incrociati, braci e fiamme.
static func _fuoco(r: Node3D, pos: Vector3, s := 1.0) -> void:
	for k in 8:
		var a := k * TAU / 8
		r.add_child(sfera(0.026 * s, pos + Vector3(cos(a), 0, sin(a)) * 0.075 * s + Vector3(0, 0.008, 0), "roccia_massi", Vector3(1.1, 0.7, 1.0)))
	for k in 4:
		r.add_child(cilindro(0.012 * s, 0.012 * s, 0.12 * s, pos + Vector3(0, 0.025 * s, 0), "corteccia", Vector3(0, k * 45, 78), 5))
	r.add_child(sfera(0.04 * s, pos + Vector3(0, 0.02 * s, 0), "brace", Vector3(1, 0.5, 1)))
	r.add_child(cilindro(0.032 * s, 0.0, 0.08 * s, pos + Vector3(0, 0.07 * s, 0), "brace", Vector3.ZERO, 7))
	r.add_child(cilindro(0.018 * s, 0.0, 0.06 * s, pos + Vector3(0.025 * s, 0.06 * s, 0.01), "brace", Vector3(0, 0, -12), 6))


## Colonna di fumo che sale e si allarga piegando verso destra.
static func _fumo(r: Node3D, pos: Vector3, n := 4, s := 1.0) -> void:
	for k in n:
		var g := (0.024 + k * 0.011) * s
		r.add_child(sfera(g, pos + Vector3(k * 0.035 * s, k * 0.075 * s, -k * 0.02 * s), "fumo", Vector3(1.1, 0.9, 1.0)))


## Vaso di terracotta sigillato con la pece: tappo nero lucido, colature sui fianchi e legatura di corda.
static func _vaso_pece(pos: Vector3, scala := 1.0) -> Node3D:
	var n := Node3D.new()
	n.position = pos
	n.scale = Vector3.ONE * scala
	n.add_child(sfera(0.05, Vector3(0, 0.052, 0), "terracotta", Vector3(1, 1.1, 1)))
	n.add_child(cilindro(0.026, 0.032, 0.035, Vector3(0, 0.11, 0), "terracotta", Vector3.ZERO, 10))
	n.add_child(sfera(0.047, Vector3(0, 0.088, 0), "pece", Vector3(1, 0.5, 1)))
	n.add_child(cilindro(0.036, 0.036, 0.016, Vector3(0, 0.125, 0), "pece", Vector3.ZERO, 10))
	n.add_child(sfera(0.037, Vector3(0, 0.133, 0), "pece", Vector3(1, 0.5, 1)))
	for k in 6:
		var a := k * TAU / 6 + 0.5
		var lungo := 1.0 if k % 2 == 0 else 0.6
		n.add_child(sfera(0.011, Vector3(cos(a) * 0.048, 0.068 - lungo * 0.012, sin(a) * 0.048), "pece", Vector3(1, 1.8 * lungo + 0.6, 1)))
	n.add_child(cilindro(0.03, 0.03, 0.008, Vector3(0, 0.105, 0), "corda", Vector3.ZERO, 10))
	return n


## Calderone nero sul fuoco, appeso a un treppiede di pali, pieno di pece che bolle.
static func _calderone(r: Node3D, pos: Vector3, s := 1.0) -> void:
	_fuoco(r, pos, 1.6 * s)
	var cima := pos + Vector3(0, 0.5 * s, 0)
	for k in 3:
		var a := k * TAU / 3 + 0.5
		ramo(r, pos + Vector3(cos(a), 0, sin(a)) * 0.22 * s, cima + Vector3(cos(a), 0, sin(a)) * 0.015, 0.016 * s, "corteccia")
	r.add_child(cilindro(0.004, 0.004, 0.2 * s, pos + Vector3(0, 0.39 * s, 0), "ferro", Vector3.ZERO, 4))
	r.add_child(sfera(0.12 * s, pos + Vector3(0, 0.19 * s, 0), "fuliggine", Vector3(1, 0.85, 1)))
	r.add_child(cilindro(0.1 * s, 0.1 * s, 0.03 * s, pos + Vector3(0, 0.27 * s, 0), "fuliggine", Vector3.ZERO, 16))
	r.add_child(cilindro(0.105 * s, 0.105 * s, 0.014 * s, pos + Vector3(0, 0.285 * s, 0), "ferro", Vector3.ZERO, 16))
	r.add_child(cilindro(0.094 * s, 0.094 * s, 0.006 * s, pos + Vector3(0, 0.288 * s, 0), "pece", Vector3.ZERO, 16))
	for k in 4:
		var a := k * 1.7
		r.add_child(sfera(0.014 * s, pos + Vector3(cos(a) * 0.05 * s, 0.29 * s, sin(a) * 0.05 * s), "pece", Vector3(1, 0.6, 1)))
	for lato: int in [-1, 1]:
		r.add_child(cilindro(0.012 * s, 0.012 * s, 0.006 * s, pos + Vector3(lato * 0.11 * s, 0.27 * s, 0), "ferro", Vector3(90, 0, 0), 8))
	# mestolo di legno appoggiato al bordo
	ramo(r, pos + Vector3(-0.04 * s, 0.27 * s, 0.03 * s), pos + Vector3(-0.2 * s, 0.45 * s, 0.12 * s), 0.008 * s, "legno")
	_fumo(r, pos + Vector3(0.03 * s, 0.42 * s, -0.03 * s), 4, 1.0 * s)


## Granaio su pali con le pietre a fungo contro i topi, scaletta e tetto di paglia.
static func _granaio(r: Node3D, pos: Vector3, lx := 0.36, lz := 0.34, seme := 1) -> void:
	for x: float in [-lx * 0.4, lx * 0.4]:
		for z: float in [-lz * 0.4, lz * 0.4]:
			r.add_child(cilindro(0.022, 0.026, 0.14, pos + Vector3(x, 0.07, z), "corteccia", Vector3.ZERO, 6))
			r.add_child(cilindro(0.048, 0.04, 0.026, pos + Vector3(x, 0.152, z), "roccia_massi", Vector3.ZERO, 9))
	r.add_child(scatola(Vector3(lx + 0.06, 0.025, lz + 0.06), pos + Vector3(0, 0.177, 0), "legno_vecchio"))
	var c := Node3D.new()
	c.position = pos + Vector3(0, 0.19, 0)
	r.add_child(c)
	var h := 0.2
	c.add_child(scatola(Vector3(lx, h, lz), Vector3(0, h * 0.5, 0), "legno_scuro"))
	var nx := int(lx / 0.045)
	for k in nx:
		c.add_child(cilindro(0.022, 0.022, h, Vector3(-lx * 0.5 + (k + 0.5) * lx / nx, h * 0.5, lz * 0.5 - 0.01), "legno" if k % 3 != 1 else "legno_vecchio", Vector3.ZERO, 6))
	var nz := int(lz / 0.045)
	for k in nz:
		c.add_child(cilindro(0.022, 0.022, h, Vector3(lx * 0.5 - 0.01, h * 0.5, -lz * 0.5 + (k + 0.5) * lz / nz), "legno" if k % 3 != 2 else "legno_vecchio", Vector3.ZERO, 6))
	c.add_child(scatola(Vector3(0.08, 0.1, 0.02), Vector3(0.0, 0.1, lz * 0.5 + 0.012), "buio"))
	c.add_child(scatola(Vector3(0.1, 0.016, 0.03), Vector3(0.0, 0.158, lz * 0.5 + 0.018), "legno_vecchio"))
	sottotetto(c, lx, lz, h, 42.0, "legno_vecchio")
	_tetto_paglia(c, lx, lz, h, 42.0, seme, false)
	# scaletta a pioli
	for lato: int in [-1, 1]:
		ramo(r, pos + Vector3(lato * 0.035, 0, lz * 0.5 + 0.17), pos + Vector3(lato * 0.035, 0.2, lz * 0.5 + 0.03), 0.008, "legno_vecchio")
	for k in 3:
		var t := (k + 1) / 4.0
		r.add_child(scatola(Vector3(0.08, 0.008, 0.008), pos + Vector3(0, 0.2 * t, lz * 0.5 + 0.17 - 0.14 * t), "legno"))


## Ruota idraulica a pale (piano YZ, asse lungo X) con schiuma in basso.
static func _ruota_mulino(r: Node3D, pos: Vector3, rg := 0.2) -> void:
	var n := Node3D.new()
	n.position = pos
	r.add_child(n)
	n.add_child(cilindro(0.028, 0.028, 0.16, Vector3.ZERO, "legno_scuro", Vector3(0, 0, 90), 8))
	var np := 12
	var corda := 2.0 * rg * 0.88 * sin(PI / np)
	for k in np:
		var a := k * TAU / np
		n.add_child(scatola(Vector3(0.016, rg, 0.016), Vector3(0, cos(a) * rg * 0.5, sin(a) * rg * 0.5), "legno", Vector3(rad_to_deg(a), 0, 0)))
		n.add_child(scatola(Vector3(0.11, 0.07, 0.014), Vector3(0, cos(a) * rg, sin(a) * rg), "legno_chiaro" if k % 2 == 0 else "legno", Vector3(rad_to_deg(a), 0, 0)))
		var b := a + PI / np
		for x: float in [-0.045, 0.045]:
			n.add_child(scatola(Vector3(0.014, 0.016, corda + 0.01), Vector3(x, cos(b) * rg * 0.88, sin(b) * rg * 0.88), "legno_scuro", Vector3(rad_to_deg(b), 0, 0)))


# ------------------------------------------------------------------ edifici dei Brettii

## Casa dei Brettii: pietra grezza a secco, tetto alto di paglia con corna incrociate, orto di graticcio, palo intagliato.
static func casa_greca_brettii(seme := 1) -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.12, 0, -0.15)
	r.add_child(c)
	var lx := 0.9
	var lz := 0.66
	var h := 0.36
	_muri_pietra_b(c, lx, lz, h, seme)
	_porta_b(c, Vector3(-0.16, 0, lz * 0.5), 0.0, 0.13, 0.23, true)
	_finestrella_b(c, Vector3(0.2, 0.24, lz * 0.5 + 0.004), 0.0)
	_finestrella_b(c, Vector3(lx * 0.5 + 0.004, 0.24, -0.02), 90.0)
	sottotetto(c, lx, lz, h, 40.0, "legno_vecchio")
	_tetto_paglia(c, lx, lz, h, 40.0, seme)
	# foro del fumo nella paglia
	c.add_child(scatola(Vector3(0.09, 0.04, 0.07), Vector3(0.22, h + 0.2, -0.04), "fuliggine", Vector3(40, 0, 0)))
	_fumo(c, Vector3(0.24, h + 0.3, -0.05), 3, 0.9)
	# davanti: panca, pelle tesa, palo intagliato, vasi e legna
	c.add_child(panca(Vector3(0.18, 0, lz * 0.5 + 0.12), 0))
	_telaio_pelle(r, Vector3(-0.42, 0, 0.42), 25.0)
	_totem(r, Vector3(-0.72, 0, 0.5), 0.5, seme)
	r.add_child(_vaso_pece(Vector3(0.1, 0, 0.42), 1.0))
	r.add_child(anfora(Vector3(0.2, 0, 0.47), 1.05))
	legnaia(c, Vector3(lx * 0.5 + 0.07, 0.0, -0.2), 0.24, 3)
	# orto chiuso dal graticcio, con cavoli e fave
	var o := Vector3(0.56, 0, 0.45)
	r.add_child(scatola(Vector3(0.34, 0.012, 0.38), o + Vector3(0, 0.006, 0), "terra"))
	var rng := _rng(seme + 9)
	for f in 4:
		for k in 5:
			r.add_child(sfera(rng.randf_range(0.02, 0.028), o + Vector3(-0.14 + k * 0.07, 0.025, -0.14 + f * 0.093), "orto" if f % 2 == 0 else "foglie_chiare", Vector3(1, 0.8, 1)))
	_graticcio(r, o + Vector3(-0.19, 0, 0.21), o + Vector3(0.19, 0, 0.21))
	_graticcio(r, o + Vector3(0.19, 0, -0.21), o + Vector3(0.19, 0, 0.21))
	return r


## Magazzino dei Brettii: lunga casa di tronchi su zoccolo di pietra, tettoia di paglia, granaio su pali, insegna verde.
static func magazzino_brettii() -> Node3D:
	var r := Node3D.new()
	r.position = Vector3(0, 0, -0.1)
	r.add_child(scatola(Vector3(2.0, 0.03, 1.5), Vector3(0, 0.015, 0.05), "terra"))
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0.03, -0.3)
	r.add_child(c)
	var lx := 1.42
	var lz := 0.8
	var h := 0.5
	_muri_tavole_b(c, lx, lz, h, 7)
	_porta_b(c, Vector3(0.22, 0, lz * 0.5 + 0.02), 0.0, 0.24, 0.32)
	_finestrella_b(c, Vector3(-0.45, 0.36, lz * 0.5 + 0.02), 0.0, 0.1, 0.08)
	_finestrella_b(c, Vector3(lx * 0.5 + 0.02, 0.36, 0.0), 90.0, 0.1, 0.08)
	sottotetto(c, lx, lz, h, 42.0, "legno_vecchio")
	_tetto_paglia(c, lx, lz, h, 42.0, 7)
	_teschio(c, Vector3(lx * 0.5 + 0.03, h + 0.18, 0), 90.0, 1.6)
	# tettoia davanti al lato sinistro con le merci all'ombra
	_tettoia_paglia(r, Vector3(-0.62, 0.03, 0.32), 0.62, 0.4, 0.5, 0.36, false)
	for i in 3:
		r.add_child(sacco(Vector3(-0.82 + i * 0.1, 0.03, 0.3), i * 0.6))
	r.add_child(sacco(Vector3(-0.77, 0.1, 0.3), 1.2))
	for i in 3:
		r.add_child(_vaso_pece(Vector3(-0.5 + (i % 2) * 0.09, 0.03, 0.26 + (i / 2) * 0.1), 1.05))
	r.add_child(cesta(Vector3(-0.38, 0.03, 0.42), "cipolle"))
	# granaio su pali a destra
	_granaio(r, Vector3(0.8, 0.03, -0.3), 0.38, 0.36, 8)
	# merci e vita davanti: botti, casse, tronchi, carretto, insegna e palo intagliato
	r.add_child(barile(Vector3(0.45, 0.03, 0.32), 1.2))
	r.add_child(barile(Vector3(0.56, 0.03, 0.4), 1.2))
	for i in 2:
		r.add_child(cassa(Vector3(0.3 + i * 0.13, 0.03, 0.48), i * 15))
	r.add_child(cesta(Vector3(0.2, 0.03, 0.42), "formaggio"))
	catasta_tronchi(r, Vector3(0.85, 0.03, 0.2), 3, 0.36)
	carretto(r, Vector3(-0.05, 0.03, 0.75), 20, "sacchi")
	_stendardo_b(r, Vector3(0.62, 0.03, 0.72), 0.75)
	_totem(r, Vector3(-0.9, 0.03, 0.62), 0.55, 3)
	_pelli_stese(r, Vector3(-0.92, 0.03, -0.05), 90.0)
	return r


## Boscaiolo dei Brettii: capanna di tronchi spaccati con tetto di paglia, tettoia con la legna, grande catasta di pini.
static func boscaiolo_brettii() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.17, 0, -0.2)
	r.add_child(c)
	var lx := 0.74
	var lz := 0.58
	var h := 0.36
	_muri_tavole_b(c, lx, lz, h, 21)
	_porta_b(c, Vector3(-0.14, 0, lz * 0.5 + 0.01), 0.0)
	_finestrella_b(c, Vector3(0.18, 0.26, lz * 0.5 + 0.012), 0.0)
	sottotetto(c, lx, lz, h, 42.0, "legno_vecchio")
	_tetto_paglia(c, lx, lz, h, 42.0, 21)
	# tettoia sul fianco con legna spaccata
	_tettoia_paglia(c, Vector3(lx * 0.5 + 0.17, 0, 0.0), 0.5, 0.26, 0.34, 0.28, false)
	legnaia(c, Vector3(lx * 0.5 + 0.17, 0.0, -0.02), 0.44, 5)
	# grande catasta di pini, ceppo con l'ascia, ceppaie, pelli e palo intagliato
	catasta_tronchi(r, Vector3(0.55, 0, 0.55), 4, 0.5)
	r.add_child(cilindro(0.07, 0.075, 0.09, Vector3(-0.2, 0.045, 0.52), "corteccia", Vector3.ZERO, 12))
	r.add_child(cilindro(0.066, 0.066, 0.006, Vector3(-0.2, 0.092, 0.52), "legno_chiaro", Vector3.ZERO, 12))
	r.add_child(cilindro(0.008, 0.008, 0.22, Vector3(-0.2, 0.18, 0.52), "legno", Vector3(0, 0, 22), 6))
	r.add_child(scatola(Vector3(0.055, 0.04, 0.012), Vector3(-0.245, 0.27, 0.52), "ferro", Vector3(0, 0, 22)))
	for i in 6:
		r.add_child(cilindro(0.02, 0.02, 0.06, Vector3(-0.36 + i * 0.06, 0.02, 0.66 + (i % 2) * 0.05), "legno_chiaro", Vector3(0, i * 37, 90), 6))
	for pos: Vector3 in [Vector3(-0.72, 0, 0.62), Vector3(0.05, 0, 0.78)]:
		r.add_child(cilindro(0.06, 0.07, 0.05, pos + Vector3(0, 0.025, 0), "corteccia", Vector3.ZERO, 10))
		r.add_child(cilindro(0.056, 0.056, 0.005, pos + Vector3(0, 0.052, 0), "legno_chiaro", Vector3.ZERO, 10))
	_pelli_stese(r, Vector3(-0.68, 0, 0.18), 80.0)
	_totem(r, Vector3(-0.45, 0, 0.5), 0.46, 2)
	var p := pino_laricio(44)
	p.position = Vector3(0.52, 0, -0.62)
	p.scale = Vector3.ONE * 0.7
	r.add_child(p)
	return r


## Segheria dei Brettii: baita di tronchi con scandole e sassi, cavalletto alto con il tronco e la sega a telaio.
static func segheria_brettii() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.22, 0, -0.28)
	r.add_child(c)
	var lx := 0.82
	var lz := 0.6
	var h := 0.42
	_muri_tavole_b(c, lx, lz, h, 31)
	_porta_b(c, Vector3(-0.2, 0, lz * 0.5 + 0.01), 0.0, 0.15, 0.25)
	_finestrella_b(c, Vector3(0.16, 0.32, lz * 0.5 + 0.012), 0.0)
	_finestrella_b(c, Vector3(lx * 0.5 + 0.012, 0.32, 0.0), 90.0)
	sottotetto(c, lx, lz, h, 26.0, "legno_vecchio")
	_tetto_scandole_sassi(c, lx + 0.06, lz, h, 26.0, 31)
	# cavalletti a X con il tronco alzato e la grande sega a telaio
	var t := Node3D.new()
	t.position = Vector3(0.08, 0, 0.48)
	r.add_child(t)
	t.add_child(cilindro(0.2, 0.2, 0.006, Vector3(0.05, 0.003, 0.0), "legno_chiaro", Vector3.ZERO, 16))
	for x: float in [-0.28, 0.28]:
		ramo(t, Vector3(x, 0, -0.13), Vector3(x, 0.38, 0.1), 0.018, "corteccia")
		ramo(t, Vector3(x, 0, 0.13), Vector3(x, 0.38, -0.1), 0.018, "corteccia")
	t.add_child(cilindro(0.055, 0.055, 0.86, Vector3(0, 0.33, 0.0), "corteccia", Vector3(0, 0, 90), 9))
	t.add_child(cilindro(0.047, 0.047, 0.865, Vector3(0, 0.33, 0.0), "legno_chiaro", Vector3(0, 0, 90), 9))
	t.add_child(scatola(Vector3(0.3, 0.012, 0.1), Vector3(-0.27, 0.392, 0.0), "legno_chiaro"))
	for z: float in [-0.08, 0.08]:
		t.add_child(scatola(Vector3(0.014, 0.5, 0.014), Vector3(0.08, 0.3, z), "legno"))
	for y: float in [0.06, 0.55]:
		t.add_child(scatola(Vector3(0.014, 0.014, 0.2), Vector3(0.08, y, 0.0), "legno"))
	t.add_child(scatola(Vector3(0.004, 0.5, 0.012), Vector3(0.08, 0.3, 0.0), "ferro"))
	t.add_child(cilindro(0.004, 0.004, 0.18, Vector3(0.08, 0.6, 0.0), "corda", Vector3(90, 0, 0), 4))
	# assi, tronchi in attesa, tettoia con le tavole e slitta da trascino
	_tettoia_paglia(r, Vector3(0.66, 0, -0.18), 0.32, 0.5, 0.4, 0.32, true)
	pila_assi(r, Vector3(0.66, 0, -0.3), 7, 90)
	pila_assi(r, Vector3(0.66, 0, 0.02), 4, 90)
	catasta_tronchi(r, Vector3(-0.66, 0, 0.5), 3, 0.42)
	var s := Node3D.new()
	s.position = Vector3(0.45, 0, 0.88)
	s.rotation_degrees.y = -30
	r.add_child(s)
	for lato: int in [-1, 1]:
		s.add_child(scatola(Vector3(0.36, 0.025, 0.025), Vector3(0, 0.0125, lato * 0.08), "legno_vecchio"))
		s.add_child(scatola(Vector3(0.05, 0.025, 0.025), Vector3(0.19, 0.03, lato * 0.08), "legno_vecchio", Vector3(0, 0, 35)))
	for i in 3:
		s.add_child(cilindro(0.032, 0.032, 0.34, Vector3(0, 0.055 + (i / 2) * 0.05, -0.035 + (i % 2) * 0.07), "corteccia", Vector3(0, 0, 90), 7))
	_stendardo_b(r, Vector3(-0.72, 0, 0.0), 0.55)
	return r


## Cava dei Brettii: capanna tonda di pietra, rupe scura, capra di legno per alzare i massi, cumuli di pietre grezze.
static func cava_brettii() -> Node3D:
	var r := Node3D.new()
	_capanna_tonda(r, Vector3(-0.42, 0, -0.32), 0.24, 0.3, 17, 20.0)
	# rupe gradonata di roccia scura
	var rng := _rng(17)
	for k in 9:
		var p := Vector3(0.35 + rng.randf_range(-0.22, 0.22), 0.0, -0.4 + rng.randf_range(-0.15, 0.18))
		var d := rng.randf_range(0.16, 0.3)
		r.add_child(_masso(p, d, Vector3(1.0, rng.randf_range(1.4, 2.2), 0.9), "roccia_massi", rng.randf() * 90))
	for k in 4:
		r.add_child(sfera(rng.randf_range(0.03, 0.05), Vector3(0.1 + k * 0.1, 0.2 + rng.randf() * 0.15, -0.3 + rng.randf() * 0.1), "macchia"))
	# capra di legno (treppiede) con carrucola e masso appeso
	var cc := Vector3(0.1, 0, 0.05)
	for k in 3:
		var a := k * TAU / 3 + 0.3
		ramo(r, cc + Vector3(cos(a), 0, sin(a)) * 0.2, cc + Vector3(0, 0.5, 0), 0.014, "corteccia")
	r.add_child(cilindro(0.003, 0.003, 0.26, cc + Vector3(0, 0.37, 0), "corda", Vector3.ZERO, 4))
	r.add_child(cilindro(0.02, 0.02, 0.012, cc + Vector3(0, 0.49, 0.0), "legno_scuro", Vector3(90, 0, 0), 8))
	r.add_child(sfera(0.06, cc + Vector3(0, 0.22, 0), "pietra", Vector3(1.2, 0.8, 1.0)))
	for k in 4:
		ramo(r, cc + Vector3(0, 0.24, 0), cc + Vector3(cos(k * 1.57) * 0.05, 0.19, sin(k * 1.57) * 0.05), 0.003, "corda")
	# cumuli di pietre grezze e cesta piena, piccone e slitta
	for k in 12:
		r.add_child(sfera(rng.randf_range(0.035, 0.055), Vector3(0.05 + rng.randf_range(-0.16, 0.16), 0.03 + (k / 6) * 0.04, 0.5 + rng.randf_range(-0.1, 0.1)), "pietra" if k % 2 == 0 else "blocco", Vector3(1.2, 0.8, 1.0)))
	for k in 6:
		r.add_child(sfera(rng.randf_range(0.03, 0.045), Vector3(0.5 + rng.randf_range(-0.08, 0.08), 0.03, 0.4 + rng.randf_range(-0.08, 0.08)), "pietra", Vector3(1.2, 0.8, 1.0)))
	r.add_child(cilindro(0.008, 0.008, 0.22, Vector3(0.38, 0.11, 0.62), "legno", Vector3(0, 0, -25), 6))
	r.add_child(scatola(Vector3(0.11, 0.014, 0.014), Vector3(0.43, 0.21, 0.62), "ferro", Vector3(0, 0, -25)))
	var s := Node3D.new()
	s.position = Vector3(-0.45, 0, 0.55)
	s.rotation_degrees.y = 15
	r.add_child(s)
	for lato: int in [-1, 1]:
		s.add_child(scatola(Vector3(0.32, 0.025, 0.025), Vector3(0, 0.0125, lato * 0.07), "legno_vecchio"))
		s.add_child(scatola(Vector3(0.05, 0.025, 0.025), Vector3(0.17, 0.03, lato * 0.07), "legno_vecchio", Vector3(0, 0, 35)))
	s.add_child(scatola(Vector3(0.28, 0.015, 0.16), Vector3(0, 0.032, 0), "legno"))
	s.add_child(sfera(0.07, Vector3(0, 0.08, 0), "pietra", Vector3(1.3, 0.8, 1.0)))
	_totem(r, Vector3(-0.1, 0, -0.62), 0.42, 1)
	return r


## Guardaboschi dei Brettii: capanna tonda di pietra e paglia, vivaio di pini chiuso dal graticcio, palo intagliato.
static func guardaboschi_brettii() -> Node3D:
	var r := Node3D.new()
	_capanna_tonda(r, Vector3(-0.32, 0, -0.32), 0.26, 0.3, 41, 20.0)
	# vivaio di pini in file, chiuso dal graticcio
	for i in 4:
		for j in 3:
			var p := Vector3(-0.1 + i * 0.16, 0, 0.3 + j * 0.15)
			r.add_child(scatola(Vector3(0.1, 0.012, 0.1), p + Vector3(0, 0.006, 0), "terra"))
			r.add_child(cilindro(0.006, 0.006, 0.06 + j * 0.02, p + Vector3(0, 0.03, 0), "corteccia", Vector3.ZERO, 5))
			r.add_child(cilindro(0.035 + j * 0.008, 0.0, 0.09 + j * 0.03, p + Vector3(0, 0.09 + j * 0.03, 0), "aghi", Vector3.ZERO, 7))
	_graticcio(r, Vector3(-0.2, 0, 0.75), Vector3(0.52, 0, 0.75))
	_graticcio(r, Vector3(0.52, 0, 0.2), Vector3(0.52, 0, 0.75))
	# cesta di pigne, pala, sacchi di semi, palo intagliato e pino
	r.add_child(cilindro(0.07, 0.055, 0.06, Vector3(0.3, 0.03, -0.12), "paglia", Vector3.ZERO, 12))
	for k in 6:
		r.add_child(sfera(0.02, Vector3(0.3 + cos(k * 1.1) * 0.035, 0.065 + (k % 2) * 0.012, -0.12 + sin(k * 1.1) * 0.035), "corteccia", Vector3(1, 1.3, 1)))
	r.add_child(cilindro(0.007, 0.007, 0.22, Vector3(0.12, 0.11, -0.05), "legno", Vector3(12, 0, -15), 5))
	r.add_child(sacco(Vector3(-0.58, 0, 0.3), 0.4))
	r.add_child(sacco(Vector3(-0.62, 0, 0.42), -0.2))
	_totem(r, Vector3(-0.32, 0, 0.42), 0.48, 4)
	var p := pino_laricio(41)
	p.position = Vector3(0.55, 0, -0.55)
	p.scale = Vector3.ONE * 0.7
	r.add_child(p)
	return r


## Pozzo dei Brettii: vera di pietre grezze e mazzacavallo (lunga pertica con il contrappeso di pietra).
static func pozzo_brettii() -> Node3D:
	var r := Node3D.new()
	r.add_child(cilindro(0.19, 0.21, 0.18, Vector3(0, 0.09, 0), "pietra_grezza", Vector3.ZERO, 16))
	r.add_child(cilindro(0.125, 0.125, 0.005, Vector3(0, 0.184, 0), "buio", Vector3.ZERO, 16))
	r.add_child(cilindro(0.09, 0.09, 0.005, Vector3(0, 0.186, 0), "acqua_pozzo", Vector3.ZERO, 16))
	var rng := _rng(23)
	for k in 11:
		var a := k * TAU / 11
		r.add_child(sfera(rng.randf_range(0.045, 0.055), Vector3(cos(a) * 0.17, 0.185, sin(a) * 0.17), "roccia_massi", Vector3(1.2, 0.6, 1.0)))
	for k in 9:
		var a := k * TAU / 9 + 0.3
		r.add_child(sfera(rng.randf_range(0.04, 0.05), Vector3(cos(a) * 0.21, 0.05 + (k % 2) * 0.06, sin(a) * 0.21), "roccia_massi" if k % 3 != 0 else "pietra_grezza", Vector3(1.0, 0.8, 0.7)))
	# forcella, pertica, secchio e contrappeso
	var cima := Vector3(0.0, 0.62, 0.05)
	var fondo := Vector3(0.42, 0.22, -0.22)
	var perno := cima.lerp(fondo, 0.5)
	r.add_child(cilindro(0.022, 0.026, perno.y, Vector3(perno.x, perno.y * 0.5, perno.z), "corteccia", Vector3.ZERO, 7))
	for lato: int in [-1, 1]:
		ramo(r, Vector3(perno.x, perno.y - 0.03, perno.z), Vector3(perno.x + lato * 0.03, perno.y + 0.05, perno.z + lato * 0.03), 0.01, "corteccia")
	ramo(r, fondo, cima, 0.016, "legno_vecchio")
	r.add_child(cilindro(0.003, 0.003, 0.26, Vector3(0, 0.49, 0.05), "corda", Vector3.ZERO, 4))
	r.add_child(cilindro(0.035, 0.03, 0.05, Vector3(0, 0.34, 0.05), "legno_scuro", Vector3.ZERO, 8))
	r.add_child(cilindro(0.036, 0.036, 0.006, Vector3(0, 0.35, 0.05), "ferro", Vector3.ZERO, 8))
	r.add_child(sfera(0.065, fondo + Vector3(0, -0.04, 0), "roccia_massi", Vector3(1.1, 0.9, 1.0)))
	r.add_child(cilindro(0.068, 0.068, 0.01, fondo + Vector3(0, -0.04, 0), "corda", Vector3.ZERO, 10))
	r.add_child(scatola(Vector3(0.05, 0.035, 0.006), Vector3(perno.x + 0.02, perno.y - 0.06, perno.z + 0.03), "stoffa_verde", Vector3(0, 45, 0)))
	# abbeveratoio di tronco scavato, vaso e lastra
	var ab := Node3D.new()
	ab.position = Vector3(-0.22, 0, 0.22)
	ab.rotation_degrees.y = 40
	r.add_child(ab)
	ab.add_child(scatola(Vector3(0.26, 0.06, 0.08), Vector3(0, 0.03, 0), "corteccia"))
	ab.add_child(scatola(Vector3(0.22, 0.006, 0.05), Vector3(0, 0.061, 0), "acqua_pozzo"))
	r.add_child(anfora(Vector3(0.25, 0.0, 0.18), 1.0))
	r.add_child(_masso(Vector3(0.1, 0, 0.26), 0.07, Vector3(1.4, 0.4, 1.0), "roccia_massi", 20))
	r.scale = Vector3.ONE * 1.15
	return r


## Fattoria dei Brettii: casa di pietra e paglia, granaio su pali, pagliaio a cono, covoni, orto di graticcio e galline.
static func fattoria_brettii() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.24)
	r.add_child(c)
	var lx := 0.76
	var lz := 0.56
	var h := 0.34
	_muri_pietra_b(c, lx, lz, h, 41)
	_porta_b(c, Vector3(-0.12, 0, lz * 0.5), 0.0, 0.13, 0.22, true)
	_finestrella_b(c, Vector3(0.2, 0.23, lz * 0.5 + 0.004), 0.0)
	_finestrella_b(c, Vector3(lx * 0.5 + 0.004, 0.23, 0.0), 90.0)
	sottotetto(c, lx, lz, h, 40.0, "legno_vecchio")
	_tetto_paglia(c, lx, lz, h, 40.0, 41)
	# granaio su pali e pagliaio a cono intorno al palo
	_granaio(r, Vector3(0.74, 0, -0.32), 0.34, 0.32, 42)
	r.add_child(cilindro(0.15, 0.03, 0.34, Vector3(0.78, 0.17, 0.2), "paglia_tetto", Vector3.ZERO, 14))
	r.add_child(cilindro(0.155, 0.15, 0.06, Vector3(0.78, 0.03, 0.2), "paglia_scura", Vector3.ZERO, 14))
	r.add_child(cilindro(0.008, 0.008, 0.48, Vector3(0.78, 0.24, 0.2), "legno_vecchio", Vector3.ZERO, 5))
	# aia con covoni, aratro di legno, orto e galline
	for i in 4:
		var cv := covone(1.2)
		cv.position = Vector3(-0.55 + i * 0.13, 0.0, 0.55 + (i % 2) * 0.08)
		cv.rotation_degrees.z = 8 * (i % 2 * 2 - 1)
		r.add_child(cv)
	ramo(r, Vector3(0.22, 0.0, 0.48), Vector3(0.52, 0.12, 0.66), 0.012, "legno_vecchio")
	ramo(r, Vector3(0.24, 0.0, 0.48), Vector3(0.2, 0.18, 0.44), 0.01, "legno_vecchio")
	r.add_child(scatola(Vector3(0.08, 0.012, 0.03), Vector3(0.2, 0.01, 0.5), "ferro", Vector3(0, 30, -20)))
	var o := Vector3(-0.72, 0, -0.05)
	r.add_child(scatola(Vector3(0.24, 0.012, 0.5), o + Vector3(0, 0.006, 0), "terra"))
	for f in 6:
		for k in 3:
			r.add_child(sfera(0.022, o + Vector3(-0.08 + k * 0.08, 0.025, -0.2 + f * 0.08), "orto" if f % 2 == 0 else "foglie_chiare", Vector3(1, 0.8, 1)))
	_graticcio(r, o + Vector3(-0.14, 0, 0.27), o + Vector3(0.14, 0, 0.27))
	for i in 3:
		r.add_child(sfera(0.025, Vector3(0.05 + i * 0.07, 0.03, 0.4 - i * 0.03), "intonaco", Vector3(1.3, 1, 1)))
		r.add_child(sfera(0.008, Vector3(0.08 + i * 0.07, 0.05, 0.4 - i * 0.03), "geranio"))
	_stendardo_b(r, Vector3(-0.68, 0, 0.42), 0.5)
	return r


## Mulino dei Brettii: casa di pietra grezza con la ruota a pale mossa dal ruscello, canale di legno, macine e sacchi.
static func mulino_brettii() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.36, 0, -0.26)
	r.add_child(c)
	var lx := 0.66
	var lz := 0.54
	var h := 0.42
	_muri_pietra_b(c, lx, lz, h, 51)
	_porta_b(c, Vector3(-0.12, 0, lz * 0.5), 0.0, 0.14, 0.25)
	_finestrella_b(c, Vector3(0.17, 0.3, lz * 0.5 + 0.004), 0.0)
	sottotetto(c, lx, lz, h, 40.0, "legno_vecchio")
	_tetto_paglia(c, lx, lz, h, 40.0, 51)
	# ruscello con le sponde di sassi che passa accanto alla casa
	var xr := 0.24
	r.add_child(scatola(Vector3(0.2, 0.012, 1.5), Vector3(xr, 0.006, 0.0), "mare"))
	var rng := _rng(52)
	for k in 26:
		var lato := -1 if k % 2 == 0 else 1
		r.add_child(sfera(rng.randf_range(0.022, 0.036), Vector3(xr + lato * 0.11, 0.008, -0.72 + (k / 2) * 0.115 + rng.randf_range(-0.02, 0.02)), "roccia_massi" if k % 3 != 0 else "pietra", Vector3(1.2, 0.6, 1.0)))
	# ruota a pale e canale di legno sui pali che porta l'acqua dall'alto
	_ruota_mulino(r, Vector3(xr, 0.23, -0.02), 0.22)
	r.add_child(cilindro(0.014, 0.014, 0.16, Vector3(xr - 0.12, 0.23, -0.02), "legno_scuro", Vector3(0, 0, 90), 6))
	for k in 5:
		r.add_child(sfera(rng.randf_range(0.02, 0.03), Vector3(xr + rng.randf_range(-0.06, 0.06), 0.02, -0.08 + rng.randf_range(-0.2, 0.2)), "latte", Vector3(1.3, 0.5, 1.0)))
	var cz := -0.7
	r.add_child(scatola(Vector3(0.09, 0.05, 0.52), Vector3(xr, 0.44, (cz - 0.12) * 0.5 - 0.02), "legno_vecchio"))
	r.add_child(scatola(Vector3(0.06, 0.006, 0.52), Vector3(xr, 0.468, (cz - 0.12) * 0.5 - 0.02), "mare"))
	for z: float in [cz + 0.05, -0.3]:
		r.add_child(cilindro(0.014, 0.016, 0.42, Vector3(xr, 0.21, z), "corteccia", Vector3.ZERO, 6))
	r.add_child(sfera(0.03, Vector3(xr, 0.43, -0.12), "latte", Vector3(1.2, 0.6, 1.0)))
	# macine appoggiate, sacchi di farina e di grano, covone, insegna
	r.add_child(cilindro(0.13, 0.13, 0.05, Vector3(-0.5, 0.025, 0.3), "blocco", Vector3.ZERO, 16))
	r.add_child(cilindro(0.11, 0.11, 0.045, Vector3(-0.5, 0.07, 0.3), "pietra", Vector3.ZERO, 16))
	r.add_child(cilindro(0.025, 0.025, 0.052, Vector3(-0.5, 0.07, 0.3), "buio", Vector3.ZERO, 8))
	r.add_child(cilindro(0.1, 0.1, 0.04, Vector3(-0.56, 0.1, -0.05), "pietra", Vector3(0, 0, 75), 16))
	r.add_child(cilindro(0.022, 0.022, 0.042, Vector3(-0.56, 0.1, -0.05), "buio", Vector3(0, 0, 75), 8))
	for i in 5:
		r.add_child(sacco(Vector3(0.48 + (i % 3) * 0.12, 0.0, 0.0 + (i / 3) * 0.13), i * 0.7))
	var cv := covone(1.1)
	cv.position = Vector3(0.55, 0, 0.45)
	r.add_child(cv)
	r.add_child(cassa(Vector3(-0.25, 0, 0.55), 15))
	_stendardo_b(r, Vector3(-0.72, 0, 0.0), 0.5)
	return r


## Forno dei Brettii: casa di tronchi su pietra, grande forno di argilla e sassi con la bocca annerita, pani sulla tavola.
static func forno_brettii() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.25)
	r.add_child(c)
	var lx := 0.72
	var lz := 0.54
	var h := 0.38
	_muri_tavole_b(c, lx, lz, h, 61)
	_porta_b(c, Vector3(-0.15, 0, lz * 0.5 + 0.01), 0.0, 0.13, 0.24, true)
	_finestrella_b(c, Vector3(0.18, 0.28, lz * 0.5 + 0.012), 0.0)
	_finestrella_b(c, Vector3(lx * 0.5 + 0.012, 0.28, 0.0), 90.0)
	sottotetto(c, lx, lz, h, 40.0, "legno_vecchio")
	_tetto_paglia(c, lx, lz, h, 40.0, 61)
	# grande forno a cupola di argilla con sassi murati, bocca annerita e fumo
	var f := Vector3(0.45, 0, 0.4)
	r.add_child(cilindro(0.26, 0.28, 0.12, f + Vector3(0, 0.06, 0), "pietra_grezza", Vector3.ZERO, 18))
	r.add_child(sfera(0.24, f + Vector3(0, 0.12, 0), "argilla_cruda", Vector3(1, 0.85, 1)))
	var rng := _rng(62)
	for k in 14:
		var a := rng.randf_range(-0.6, 2.2)
		var e := rng.randf_range(0.15, 1.2)
		r.add_child(sfera(rng.randf_range(0.02, 0.03), f + Vector3(cos(a) * cos(e) * 0.235, 0.12 + sin(e) * 0.2, sin(a) * cos(e) * 0.235), "roccia_massi", Vector3(1.2, 0.7, 1.0)))
	r.add_child(scatola(Vector3(0.12, 0.1, 0.06), f + Vector3(-0.06, 0.18, 0.21), "fuliggine", Vector3(0, 30, 0)))
	r.add_child(scatola(Vector3(0.1, 0.09, 0.03), f + Vector3(-0.065, 0.175, 0.235), "buio", Vector3(0, 30, 0)))
	r.add_child(sfera(0.025, f + Vector3(-0.07, 0.15, 0.22), "brace", Vector3(1.4, 0.5, 1.0)))
	r.add_child(cilindro(0.008, 0.008, 0.5, f + Vector3(-0.2, 0.06, 0.32), "legno", Vector3(-80, 30, 0), 5))
	_fumo(r, f + Vector3(0.02, 0.38, -0.02), 4, 1.0)
	legnaia(r, Vector3(0.66, 0, -0.1), 0.25, 3)
	# tavola con pani, ceste, sacchi di farina e macina a mano
	r.add_child(scatola(Vector3(0.3, 0.02, 0.14), Vector3(-0.3, 0.12, 0.55), "legno"))
	for x: float in [-0.42, -0.18]:
		r.add_child(cilindro(0.016, 0.016, 0.11, Vector3(x, 0.055, 0.55), "corteccia", Vector3.ZERO, 6))
	for i in 5:
		r.add_child(sfera(0.03, Vector3(-0.42 + i * 0.06, 0.145, 0.55 + (i % 2) * 0.03), "pane", Vector3(1, 0.6, 1)))
	r.add_child(cesta(Vector3(-0.62, 0, 0.45), "pane"))
	r.add_child(cesta(Vector3(0.05, 0, 0.66), "pane"))
	r.add_child(sacco(Vector3(-0.68, 0, 0.15), 0.4))
	r.add_child(cilindro(0.07, 0.07, 0.04, Vector3(0.15, 0.02, 0.5), "pietra", Vector3.ZERO, 12))
	r.add_child(cilindro(0.06, 0.06, 0.03, Vector3(0.15, 0.055, 0.5), "blocco", Vector3.ZERO, 12))
	r.add_child(cilindro(0.006, 0.006, 0.06, Vector3(0.19, 0.09, 0.5), "legno", Vector3.ZERO, 5))
	_totem(r, Vector3(-0.75, 0, -0.05), 0.42, 5)
	return r


## Ovile dei Brettii: capanna tonda dei pastori, stazzo di graticcio con le pecore, pelli, bastone e palo intagliato.
static func ovile_brettii() -> Node3D:
	var r := Node3D.new()
	_capanna_tonda(r, Vector3(-0.36, 0, -0.36), 0.26, 0.3, 81, 30.0)
	# stazzo di graticcio con le pecore
	var a := Vector3(0.1, 0, 0.1)
	_graticcio(r, a + Vector3(-0.36, 0, 0.47), a + Vector3(0.5, 0, 0.47))
	_graticcio(r, a + Vector3(0.5, 0, -0.26), a + Vector3(0.5, 0, 0.47))
	_graticcio(r, a + Vector3(-0.08, 0, -0.26), a + Vector3(0.5, 0, -0.26))
	_graticcio(r, a + Vector3(-0.36, 0, 0.1), a + Vector3(-0.36, 0, 0.47))
	for p: Array in [[Vector3(0.0, 0, 0.25), 30], [Vector3(0.2, 0, 0.05), 160], [Vector3(0.3, 0, 0.3), -40],
			[Vector3(-0.15, 0, 0.32), 90], [Vector3(0.32, 0, -0.12), 210]]:
		r.add_child(pecora(a + p[0], p[1]))
	r.add_child(scatola(Vector3(0.22, 0.04, 0.06), a + Vector3(-0.2, 0.02, 0.05), "corteccia"))
	# bastone del pastore appoggiato al recinto
	ramo(r, a + Vector3(0.53, 0, 0.3), a + Vector3(0.58, 0.32, 0.2), 0.008, "legno_vecchio")
	ramo(r, a + Vector3(0.58, 0.32, 0.2), a + Vector3(0.62, 0.34, 0.18), 0.007, "legno_vecchio")
	ramo(r, a + Vector3(0.62, 0.34, 0.18), a + Vector3(0.63, 0.31, 0.17), 0.006, "legno_vecchio")
	# vasca, lana, pelli e palo intagliato
	r.add_child(cilindro(0.09, 0.08, 0.06, Vector3(-0.68, 0.03, 0.3), "legno", Vector3.ZERO, 14))
	r.add_child(cilindro(0.08, 0.08, 0.005, Vector3(-0.68, 0.06, 0.3), "acqua_pozzo", Vector3.ZERO, 14))
	r.add_child(sfera(0.06, Vector3(-0.55, 0.04, 0.6), "lana", Vector3(1.2, 0.6, 1.0)))
	r.add_child(sfera(0.05, Vector3(-0.45, 0.035, 0.66), "lana", Vector3(1.2, 0.6, 1.0)))
	_pelli_stese(r, Vector3(0.32, 0, -0.55), 0.0)
	_totem(r, Vector3(-0.72, 0, -0.02), 0.46, 6)
	return r


## Capraio dei Brettii: baita di pietra con scandole e sassi, rupi con le capre, graticcio e rastrelliera dei formaggi.
static func capraio_brettii() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.3, 0, -0.3)
	r.add_child(c)
	var lx := 0.54
	var lz := 0.42
	var h := 0.27
	_muri_pietra_b(c, lx, lz, h, 91)
	_porta_b(c, Vector3(-0.08, 0, lz * 0.5), 0.0, 0.12, 0.19, true)
	sottotetto(c, lx, lz, h, 30.0, "legno_vecchio")
	_tetto_scandole_sassi(c, lx + 0.06, lz, h, 30.0, 91)
	# rupi su cui le capre si arrampicano
	var a := Vector3(0.15, 0, 0.15)
	r.add_child(_masso(a + Vector3(0.22, 0.0, -0.12), 0.2, Vector3(1.1, 1.3, 1.0), "roccia_massi", 15))
	r.add_child(_masso(a + Vector3(-0.05, 0.0, 0.3), 0.12, Vector3(1.3, 1.1, 1.0), "roccia_massi", 50))
	r.add_child(_masso(a + Vector3(0.42, 0.0, 0.12), 0.1, Vector3(1.2, 1.0, 1.0), "roccia_massi", 80))
	r.add_child(sfera(0.04, a + Vector3(0.3, 0.05, -0.25), "macchia"))
	r.add_child(capra(a + Vector3(0.2, 0.23, -0.12), 40))
	r.add_child(capra(a + Vector3(0.0, 0, 0.1), 200))
	r.add_child(capra(a + Vector3(0.35, 0, 0.3), -30))
	r.add_child(capra(a + Vector3(-0.06, 0.12, 0.3), 110))
	_graticcio(r, a + Vector3(-0.4, 0, 0.5), a + Vector3(0.5, 0, 0.5))
	# rastrelliera con i formaggi, vaso, teschio sul palo
	var rs := Vector3(-0.62, 0, 0.3)
	for x: float in [-0.1, 0.1]:
		r.add_child(cilindro(0.01, 0.011, 0.24, rs + Vector3(x, 0.12, 0), "corteccia", Vector3.ZERO, 5))
	for y: float in [0.1, 0.2]:
		r.add_child(scatola(Vector3(0.24, 0.012, 0.08), rs + Vector3(0, y, 0), "legno_vecchio"))
		for k in 3:
			r.add_child(cilindro(0.028, 0.028, 0.025, rs + Vector3(-0.065 + k * 0.065, y + 0.019, 0), "formaggio", Vector3.ZERO, 10))
	r.add_child(_vaso_pece(Vector3(-0.42, 0, 0.5), 0.9))
	r.add_child(cilindro(0.01, 0.012, 0.36, Vector3(0.02, 0.18, -0.04), "corteccia", Vector3.ZERO, 5))
	_teschio(r, Vector3(0.02, 0.38, -0.04), 45.0, 1.4)
	r.add_child(scatola(Vector3(0.05, 0.08, 0.005), Vector3(0.035, 0.28, -0.03), "stoffa_verde", Vector3(0, 45, 0)))
	return r


## Caserma dei Brettii: casa lunga di tronchi con paglia, tratto di palizzata, campo dei frombolieri con i vasi bersaglio.
static func caserma_brettii() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.3, 0, -0.3)
	r.add_child(c)
	var lx := 0.62
	var lz := 0.5
	var h := 0.36
	_muri_tavole_b(c, lx, lz, h, 271)
	_porta_b(c, Vector3(0.08, 0, lz * 0.5 + 0.01), 0.0, 0.15, 0.25, true)
	_finestrella_b(c, Vector3(lx * 0.5 + 0.012, 0.27, 0.0), 90.0)
	sottotetto(c, lx, lz, h, 42.0, "legno_vecchio")
	_tetto_paglia(c, lx, lz, h, 42.0, 271)
	_stendardo_b(c, Vector3(lx * 0.5 + 0.06, 0, lz * 0.5 + 0.06), 0.8)
	_palizzata(r, Vector3(-0.78, 0, -0.62), Vector3(-0.78, 0, 0.2), 0.3)
	# campo d'addestramento: pali con i vasi bersaglio, fantoccio di paglia, mucchio di sassi da fionda
	r.add_child(scatola(Vector3(0.75, 0.01, 0.55), Vector3(0.25, 0.005, 0.4), "terra"))
	for k in 3:
		var p := Vector3(0.5 + k * 0.09, 0, 0.12 + k * 0.1)
		r.add_child(cilindro(0.014, 0.016, 0.26 - k * 0.03, p + Vector3(0, 0.13 - k * 0.015, 0), "corteccia", Vector3.ZERO, 6))
		r.add_child(anfora(p + Vector3(0, 0.26 - k * 0.03, 0), 0.75))
	r.add_child(cilindro(0.016, 0.016, 0.34, Vector3(0.22, 0.17, 0.2), "legno_vecchio", Vector3.ZERO, 6))
	r.add_child(cilindro(0.01, 0.01, 0.2, Vector3(0.22, 0.27, 0.2), "legno_vecchio", Vector3(0, 45, 90), 5))
	r.add_child(sfera(0.06, Vector3(0.22, 0.22, 0.2), "paglia", Vector3(1, 1.4, 1)))
	r.add_child(sfera(0.035, Vector3(0.22, 0.34, 0.2), "paglia"))
	for k in 9:
		r.add_child(sfera(0.016, Vector3(0.0 + (k % 3) * 0.025, 0.012 + (k / 3) * 0.012, 0.75 + (k % 2) * 0.02), "pietra"))
	for k in 2:
		var o := brettio()
		o.position = Vector3(0.05 + k * 0.26, 0, 0.6 - k * 0.15)
		o.rotation_degrees.y = 150 - k * 60
		o.scale = Vector3.ONE * 0.95
		r.add_child(o)
	# rastrelliera con lance e scudi ovali dipinti
	var rs := Vector3(-0.55, 0, 0.5)
	r.add_child(scatola(Vector3(0.3, 0.02, 0.02), rs + Vector3(0, 0.22, 0), "legno_vecchio"))
	for x: float in [-0.14, 0.14]:
		r.add_child(cilindro(0.01, 0.01, 0.24, rs + Vector3(x, 0.12, 0), "corteccia", Vector3.ZERO, 5))
	for k in 4:
		r.add_child(cilindro(0.005, 0.005, 0.4, rs + Vector3(-0.1 + k * 0.06, 0.2, -0.02), "legno", Vector3(-10, 0, 0), 5))
		r.add_child(cilindro(0.008, 0.0, 0.04, rs + Vector3(-0.1 + k * 0.06, 0.41, -0.055), "ferro", Vector3(-10, 0, 0), 5))
	for k in 2:
		var sc := rs + Vector3(-0.07 + k * 0.13, 0.11, 0.04)
		r.add_child(sfera(0.08, sc, "legno", Vector3(0.8, 1.2, 0.18)))
		r.add_child(sfera(0.05, sc + Vector3(0, 0, 0.008), "stoffa_verde", Vector3(0.8, 1.2, 0.18)))
		r.add_child(sfera(0.018, sc + Vector3(0, 0, 0.016), "ferro"))
	return r


## Castello dei Brettii: rocca su un'altura con terrapieno di pietra a secco e palizzata, torri di legno con tetti
## a piramide di paglia, porta con torretta e la grande casa del capo con corna, palo intagliato e insegne verdi.
static func castello_brettii() -> Node3D:
	var r := Node3D.new()
	var lato := 2.3
	var hm := 0.26
	r.add_child(scatola(Vector3(lato + 0.34, 0.06, lato + 0.34), Vector3(0, 0.03, 0), "roccia_massi"))
	r.add_child(scatola(Vector3(lato - 0.1, 0.012, lato - 0.1), Vector3(0, 0.066, 0), "terra"))
	# terrapieno di pietra grezza con la palizzata sopra
	var rng := _rng(301)
	for i in 4:
		var m := Node3D.new()
		m.rotation_degrees.y = i * 90
		r.add_child(m)
		m.add_child(scatola(Vector3(lato, hm, 0.2), Vector3(0, 0.06 + hm * 0.5, lato * 0.5), "pietra_grezza"))
		for k in 22:
			m.add_child(sfera(rng.randf_range(0.03, 0.045), Vector3(rng.randf_range(-lato * 0.45, lato * 0.45), 0.06 + rng.randf_range(0.04, hm - 0.03), lato * 0.5 + 0.1), "roccia_massi" if k % 3 != 0 else "pietra", Vector3(1.4, 0.75, 0.35)))
		if i == 0:
			_palizzata(m, Vector3(-lato * 0.5 + 0.2, 0.06 + hm, lato * 0.5), Vector3(0.18, 0.06 + hm, lato * 0.5), 0.24)
			_palizzata(m, Vector3(0.72, 0.06 + hm, lato * 0.5), Vector3(lato * 0.5 - 0.2, 0.06 + hm, lato * 0.5), 0.24)
		else:
			_palizzata(m, Vector3(-lato * 0.5 + 0.2, 0.06 + hm, lato * 0.5), Vector3(lato * 0.5 - 0.2, 0.06 + hm, lato * 0.5), 0.24)
	# torri di legno agli angoli
	for x: int in [-1, 1]:
		for z: int in [-1, 1]:
			var p := Vector3(x * lato * 0.5, 0.06, z * lato * 0.5)
			var t := Node3D.new()
			t.position = p
			r.add_child(t)
			t.add_child(scatola(Vector3(0.46, 0.34, 0.46), Vector3(0, 0.17, 0), "pietra_grezza"))
			var su := Node3D.new()
			su.position.y = 0.3
			t.add_child(su)
			_muri_tavole_b(su, 0.4, 0.4, 0.44, 320 + x * 3 + z)
			su.add_child(scatola(Vector3(0.52, 0.03, 0.52), Vector3(0, 0.46, 0), "legno_vecchio"))
			for k in 4:
				su.add_child(cilindro(0.015, 0.015, 0.14, Vector3(-0.24 + k * 0.16, 0.53, 0.25), "corteccia", Vector3.ZERO, 5))
				su.add_child(cilindro(0.015, 0.015, 0.14, Vector3(0.25, 0.53, -0.24 + k * 0.16), "corteccia", Vector3.ZERO, 5))
			su.add_child(scatola(Vector3(0.025, 0.11, 0.02), Vector3(0, 0.25, 0.212), "buio"))
			su.add_child(scatola(Vector3(0.02, 0.11, 0.025), Vector3(0.212, 0.25, 0), "buio"))
			var tetto_t := cilindro(0.46, 0.0, 0.4, Vector3(0, 0.79, 0), "paglia_tetto", Vector3(0, 45, 0), 4)
			su.add_child(tetto_t)
			su.add_child(cilindro(0.47, 0.47, 0.03, Vector3(0, 0.6, 0), "paglia_scura", Vector3(0, 45, 0), 4))
			su.add_child(cilindro(0.01, 0.01, 0.16, Vector3(0, 1.02, 0), "legno_vecchio", Vector3.ZERO, 5))
			_teschio(su, Vector3(0, 1.08, 0), 45.0, 1.2)
	# porta sul lato in vista con la torretta sopra
	var g := Vector3(0.45, 0.06, lato * 0.5)
	r.add_child(scatola(Vector3(0.36, 0.34, 0.06), g + Vector3(0, 0.17, 0.08), "legno_scuro"))
	for k in 6:
		r.add_child(scatola(Vector3(0.05, 0.32, 0.01), g + Vector3(-0.15 + k * 0.06, 0.17, 0.115), "legno_vecchio"))
	for lx: int in [-1, 1]:
		r.add_child(cilindro(0.045, 0.05, 0.7, g + Vector3(lx * 0.24, 0.35, 0.1), "corteccia", Vector3.ZERO, 8))
		_teschio(r, g + Vector3(lx * 0.24, 0.74, 0.14), 0.0, 1.4)
	r.add_child(scatola(Vector3(0.6, 0.04, 0.3), g + Vector3(0, 0.6, 0.06), "legno_vecchio"))
	_palizzata(r, g + Vector3(-0.27, 0.62, 0.2), g + Vector3(0.27, 0.62, 0.2), 0.14)
	_stendardo_b(r, g + Vector3(0.0, 0.62, 0.0), 0.45)
	# grande casa del capo sull'altura
	var c := Node3D.new()
	r.add_child(c)
	r.add_child(_masso(Vector3(-0.25, 0.06, -0.28), 0.7, Vector3(1.1, 0.18, 1.0), "roccia_massi", 0))
	c.position = Vector3(-0.25, 0.11, -0.28)
	_muri_tavole_b(c, 0.92, 0.62, 0.48, 330)
	_porta_b(c, Vector3(0.12, 0, 0.32), 0.0, 0.17, 0.28, true)
	_finestrella_b(c, Vector3(-0.25, 0.34, 0.322), 0.0, 0.09, 0.08)
	_finestrella_b(c, Vector3(0.472, 0.34, 0.0), 90.0, 0.09, 0.08)
	sottotetto(c, 0.92, 0.62, 0.48, 45.0, "legno_vecchio")
	_tetto_paglia(c, 0.92, 0.62, 0.48, 45.0, 331)
	_stendardo_b(c, Vector3(0.38, 0.0, 0.48), 1.0)
	# cortile: palo intagliato, fuoco, granaio, capanna
	_totem(r, Vector3(0.3, 0.07, 0.45), 0.6, 7)
	_fuoco(r, Vector3(-0.3, 0.07, 0.55), 1.2)
	_granaio(r, Vector3(0.62, 0.07, -0.5), 0.3, 0.3, 333)
	_capanna_tonda(r, Vector3(-0.68, 0.07, 0.45), 0.18, 0.22, 334, 40.0)
	for k in 3:
		r.add_child(cassa(Vector3(0.6 + k * 0.12, 0.07, 0.35), k * 20))
	r.add_child(barile(Vector3(0.75, 0.07, 0.55), 1.1))
	return r


## Pecificio (edificio unico dei Brettii): capanna di tronchi e pietra dove si cuoce la resina dei pini in un grande
## calderone nero fumante; tronchi di pino accatastati e vasi sigillati di pece pronti da portare via.
static func pecificio() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.28, 0, -0.32)
	r.add_child(c)
	var lx := 0.7
	var lz := 0.52
	var h := 0.38
	_muri_tavole_b(c, lx, lz, h, 401)
	_porta_b(c, Vector3(-0.12, 0, lz * 0.5 + 0.01), 0.0, 0.14, 0.24)
	_finestrella_b(c, Vector3(0.18, 0.28, lz * 0.5 + 0.012), 0.0)
	_finestrella_b(c, Vector3(lx * 0.5 + 0.012, 0.28, 0.0), 90.0)
	# fuliggine sopra le aperture
	c.add_child(scatola(Vector3(0.14, 0.06, 0.006), Vector3(0.18, 0.36, lz * 0.5 + 0.03), "fuliggine"))
	c.add_child(scatola(Vector3(0.006, 0.06, 0.14), Vector3(lx * 0.5 + 0.03, 0.36, 0.0), "fuliggine"))
	sottotetto(c, lx, lz, h, 28.0, "legno_vecchio")
	_tetto_scandole_sassi(c, lx + 0.06, lz, h, 28.0, 401)
	# calderone della pece sul fuoco
	_calderone(r, Vector3(0.2, 0, 0.32), 1.25)
	# vasca di legno dove la pece si raffredda
	var v := Vector3(0.62, 0, 0.5)
	r.add_child(scatola(Vector3(0.3, 0.07, 0.16), v + Vector3(0, 0.035, 0), "legno_vecchio", Vector3(0, -20, 0)))
	r.add_child(scatola(Vector3(0.26, 0.006, 0.12), v + Vector3(0, 0.071, 0), "pece", Vector3(0, -20, 0)))
	# tronchi di pino accatastati e legna per il fuoco
	catasta_tronchi(r, Vector3(0.62, 0, -0.3), 3, 0.44)
	legnaia(r, Vector3(-0.68, 0, 0.1), 0.24, 4)
	# vasi sigillati di pece in file, pronti per i portatori
	for i in 6:
		r.add_child(_vaso_pece(Vector3(-0.5 + (i % 3) * 0.12, 0, 0.42 + (i / 3) * 0.13), 1.15))
	r.add_child(_vaso_pece(Vector3(-0.15, 0, 0.62), 1.0))
	# pino con le incisioni da cui cola la resina
	var p := pino_laricio(43)
	p.position = Vector3(-0.72, 0, -0.62)
	p.scale = Vector3.ONE * 0.62
	r.add_child(p)
	for k in 3:
		r.add_child(scatola(Vector3(0.022, 0.035, 0.01), Vector3(-0.72 + 0.02 * k, 0.1 + k * 0.05, -0.62 + 0.032), "legno_chiaro", Vector3(0, 45, 0)))
	r.add_child(cilindro(0.02, 0.016, 0.03, Vector3(-0.7, 0.07, -0.58), "terracotta", Vector3.ZERO, 8))
	_stendardo_b(r, Vector3(0.42, 0, -0.06), 0.6)
	_totem(r, Vector3(0.78, 0, 0.12), 0.45, 8)
	return r


# ------------------------------------------------------------------ altri edifici dei Brettii (step G6a)

## Vasetto rotondo di terracotta grezza, senza anse, con una fascia annerita dal fuoco.
static func _pentola_b(pos: Vector3, scala := 1.0, mat := "terracotta") -> Node3D:
	var n := Node3D.new()
	n.position = pos
	n.scale = Vector3.ONE * scala
	n.add_child(sfera(0.045, Vector3(0, 0.045, 0), mat, Vector3(1, 0.95, 1)))
	n.add_child(cilindro(0.026, 0.03, 0.025, Vector3(0, 0.092, 0), mat, Vector3.ZERO, 10))
	n.add_child(cilindro(0.031, 0.031, 0.008, Vector3(0, 0.104, 0), mat, Vector3.ZERO, 10))
	n.add_child(cilindro(0.046, 0.046, 0.012, Vector3(0, 0.05, 0), "fuliggine", Vector3.ZERO, 12))
	return n


## Otre di pelle di capra gonfio di vino, con il collo legato.
static func _otre(pos: Vector3, rot_y := 0.0, scala := 1.0) -> Node3D:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot_y
	n.scale = Vector3.ONE * scala
	n.add_child(sfera(0.055, Vector3(0, 0.042, 0), "pelle_scura", Vector3(1.4, 0.75, 1.0)))
	n.add_child(sfera(0.03, Vector3(0.07, 0.05, 0), "pelle_scura", Vector3(1.0, 0.8, 0.9)))
	n.add_child(cilindro(0.012, 0.009, 0.04, Vector3(0.1, 0.07, 0), "pelle_scura", Vector3(0, 0, -50), 6))
	n.add_child(cilindro(0.013, 0.013, 0.008, Vector3(0.112, 0.08, 0), "corda", Vector3(0, 0, -50), 6))
	for lato: int in [-1, 1]:
		n.add_child(cilindro(0.01, 0.007, 0.035, Vector3(-0.05, 0.02, lato * 0.035), "pelle_scura", Vector3(lato * 30, 0, 20), 5))
	return n


## Arnia di tronco cavo messa in piedi, coperta da una lastra di pietra e un sasso.
static func _arnia_tronco(r: Node3D, pos: Vector3, h := 0.13) -> void:
	r.add_child(cilindro(0.045, 0.05, h, pos + Vector3(0, h * 0.5, 0), "corteccia", Vector3.ZERO, 10))
	r.add_child(cilindro(0.043, 0.043, 0.004, pos + Vector3(0, h + 0.001, 0), "legno_chiaro", Vector3.ZERO, 10))
	r.add_child(sfera(0.062, pos + Vector3(0, h + 0.008, 0), "pietra_grezza", Vector3(1.1, 0.18, 1.0)))
	r.add_child(sfera(0.022, pos + Vector3(0.01, h + 0.03, 0), "roccia_massi", Vector3(1.2, 0.7, 1.0)))
	r.add_child(scatola(Vector3(0.022, 0.012, 0.01), pos + Vector3(0, 0.04, 0.047), "buio"))
	r.add_child(sfera(0.01, pos + Vector3(0.01, 0.06, 0.05), "miele", Vector3(1, 1.6, 0.6)))


## Barca monossile dei Brettii: un tronco di pino scavato, con la corteccia sui fianchi. Prua verso +X locale.
static func _monossile(r: Node3D, pos: Vector3, rot_y: float, lung := 1.0) -> Node3D:
	var b := Node3D.new()
	b.position = pos
	b.rotation_degrees.y = rot_y
	r.add_child(b)
	b.add_child(sfera(0.13, Vector3(0, 0.07, 0), "corteccia", Vector3(2.6 * lung, 0.62, 0.9)))
	b.add_child(sfera(0.112, Vector3(0, 0.1, 0), "legno_scuro", Vector3(2.5 * lung, 0.32, 0.78)))
	b.add_child(scatola(Vector3(0.6 * lung, 0.016, 0.022), Vector3(0, 0.122, 0.105), "legno_vecchio"))
	b.add_child(scatola(Vector3(0.6 * lung, 0.016, 0.022), Vector3(0, 0.122, -0.105), "legno_vecchio"))
	b.add_child(cilindro(0.02, 0.012, 0.06, Vector3(0.34 * lung, 0.13, 0), "legno_vecchio", Vector3(0, 0, -60), 6))
	b.add_child(sfera(0.012, Vector3(0.36 * lung, 0.15, 0), "stoffa_verde"))
	return b


## Porcile dei Brettii: stalla di tronchi con la paglia, stabbio fangoso chiuso dal graticcio, trogolo di tronco e querce.
static func porcile_brettii() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.3, 0, -0.3)
	r.add_child(c)
	var lx := 0.6
	var lz := 0.46
	var h := 0.32
	_muri_tavole_b(c, lx, lz, h, 71)
	_porta_b(c, Vector3(-0.1, 0, lz * 0.5 + 0.01), 0.0, 0.12, 0.2)
	_finestrella_b(c, Vector3(lx * 0.5 + 0.012, 0.24, 0.0), 90.0, 0.07, 0.07)
	sottotetto(c, lx, lz, h, 40.0, "legno_vecchio")
	_tetto_paglia(c, lx, lz, h, 40.0, 71)
	# stabbio fangoso chiuso dal graticcio, trogolo di tronco e maiali
	var a := Vector3(0.05, 0, 0.0)
	r.add_child(scatola(Vector3(0.8, 0.012, 0.75), a + Vector3(0.12, 0.006, 0.12), "terra"))
	_graticcio(r, a + Vector3(-0.28, 0, 0.5), a + Vector3(0.52, 0, 0.5), 0.09)
	_graticcio(r, a + Vector3(0.52, 0, -0.26), a + Vector3(0.52, 0, 0.5), 0.09)
	_graticcio(r, a + Vector3(0.15, 0, -0.26), a + Vector3(0.52, 0, -0.26), 0.09)
	r.add_child(sfera(0.14, a + Vector3(0.28, 0.0, 0.05), "fuliggine", Vector3(1.4, 0.1, 1.0)))
	r.add_child(sfera(0.08, a + Vector3(0.1, 0.0, 0.3), "terra_cruda", Vector3(1.5, 0.1, 1.0)))
	r.add_child(cilindro(0.04, 0.04, 0.26, a + Vector3(0.0, 0.03, 0.4), "corteccia", Vector3(0, 0, 90), 10))
	r.add_child(scatola(Vector3(0.22, 0.012, 0.05), a + Vector3(0.0, 0.058, 0.4), "grano"))
	for p: Array in [[Vector3(0.25, 0, 0.3), 20], [Vector3(0.38, 0, -0.05), 130], [Vector3(0.05, 0, 0.18), -60], [Vector3(0.4, 0, 0.32), 200]]:
		r.add_child(maiale(a + p[0], p[1]))
	# ghiande nella cesta, sacco, vaso, palo intagliato
	r.add_child(sacco(Vector3(-0.62, 0, 0.2), 0.3))
	r.add_child(_vaso_pece(Vector3(-0.5, 0, 0.32), 1.0))
	r.add_child(cesta(Vector3(-0.38, 0, 0.42), "olive", 0.9))
	_totem(r, Vector3(-0.7, 0, -0.05), 0.42, 4)
	_teschio(c, Vector3(lx * 0.5 + 0.03, h + 0.16, 0), 90.0, 1.3)
	return r


## Macelleria dei Brettii: casa di pietra grezza, tettoia di paglia con prosciutti e salsicce affumicate, ceppo e pelli.
static func macelleria_brettii() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.25)
	r.add_child(c)
	var lx := 0.74
	var lz := 0.56
	var h := 0.38
	_muri_pietra_b(c, lx, lz, h, 101)
	_porta_b(c, Vector3(0.16, 0, lz * 0.5), 0.0, 0.13, 0.24)
	_finestrella_b(c, Vector3(-0.17, 0.27, lz * 0.5 + 0.004), 0.0)
	_finestrella_b(c, Vector3(lx * 0.5 + 0.004, 0.27, 0.0), 90.0)
	sottotetto(c, lx, lz, h, 40.0, "legno_vecchio")
	_tetto_paglia(c, lx, lz, h, 40.0, 101)
	c.add_child(scatola(Vector3(0.09, 0.04, 0.07), Vector3(0.2, h + 0.2, -0.05), "fuliggine", Vector3(40, 0, 0)))
	_fumo(c, Vector3(0.22, h + 0.3, -0.06), 3, 0.9)
	# tettoia di paglia con la carne appesa alla trave
	_tettoia_paglia(r, Vector3(0.45, 0, 0.42), 0.52, 0.22, 0.44, 0.36)
	for k in 5:
		var x := 0.25 + k * 0.1
		r.add_child(cilindro(0.003, 0.003, 0.05, Vector3(x, 0.32, 0.53), "corda", Vector3.ZERO, 3))
		if k % 2 == 0:
			r.add_child(sfera(0.035, Vector3(x, 0.26, 0.53), "carne", Vector3(0.9, 1.4, 0.8)))
		else:
			r.add_child(cilindro(0.016, 0.016, 0.1, Vector3(x, 0.25, 0.53), "carne", Vector3.ZERO, 8))
	# banco di tronco spaccato, ceppo con la mannaia, pelli stese, maiale
	r.add_child(scatola(Vector3(0.3, 0.025, 0.12), Vector3(-0.35, 0.12, 0.55), "legno_vecchio"))
	for x: float in [-0.46, -0.24]:
		r.add_child(cilindro(0.018, 0.02, 0.11, Vector3(x, 0.055, 0.55), "corteccia", Vector3.ZERO, 6))
	r.add_child(sfera(0.04, Vector3(-0.4, 0.15, 0.55), "carne", Vector3(1.2, 0.5, 0.9)))
	r.add_child(sfera(0.03, Vector3(-0.29, 0.145, 0.56), "carne", Vector3(1.3, 0.5, 0.9)))
	r.add_child(cilindro(0.07, 0.075, 0.1, Vector3(-0.65, 0.05, 0.4), "corteccia", Vector3.ZERO, 12))
	r.add_child(cilindro(0.066, 0.066, 0.006, Vector3(-0.65, 0.102, 0.4), "legno_chiaro", Vector3.ZERO, 12))
	r.add_child(scatola(Vector3(0.06, 0.04, 0.01), Vector3(-0.63, 0.13, 0.4), "ferro", Vector3(0, 30, 15)))
	_pelli_stese(r, Vector3(0.66, 0, 0.0), 90.0)
	r.add_child(maiale(Vector3(-0.6, 0, 0.05), 60))
	return r


## Apiario dei Brettii: capanna tonda di pietra e paglia, file di arnie di tronco con la lastra sopra, fiori e vasi di miele.
static func apiario_brettii() -> Node3D:
	var r := Node3D.new()
	_capanna_tonda(r, Vector3(-0.36, 0, -0.36), 0.24, 0.27, 91, 30.0)
	# due file di arnie di tronco su lastre di pietra
	for f in 2:
		r.add_child(scatola(Vector3(0.76, 0.03, 0.1), Vector3(0.15, 0.015, 0.15 + f * 0.25), "pietra_grezza"))
		for k in 5:
			_arnia_tronco(r, Vector3(-0.15 + k * 0.15, 0.03, 0.15 + f * 0.25), 0.11 + ((k + f) % 3) * 0.015)
	var rng := _rng(92)
	for k in 30:
		var p := Vector3(rng.randf_range(-0.7, 0.7), 0.0, rng.randf_range(0.55, 0.75))
		if k % 2 == 0:
			p = Vector3(rng.randf_range(0.5, 0.75), 0.0, rng.randf_range(-0.6, 0.6))
		r.add_child(sfera(0.018, p + Vector3(0, 0.02, 0), "orto"))
		r.add_child(sfera(0.012, p + Vector3(0, 0.04, 0), ["geranio", "fiore", "miele"][k % 3]))
	r.add_child(_pentola_b(Vector3(-0.62, 0, 0.2), 1.0))
	r.add_child(_pentola_b(Vector3(-0.54, 0, 0.3), 0.85))
	r.add_child(sfera(0.03, Vector3(-0.54, 0.09, 0.3), "miele", Vector3(1, 0.4, 1)))
	_totem(r, Vector3(-0.72, 0, 0.45), 0.42, 7)
	return r


## Caseificio dei Brettii: casa di pietra grezza, paiolo del latte su un treppiede di pali, rastrelliere di formaggi, secchi di legno.
static func caseificio_brettii() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.25)
	r.add_child(c)
	var lx := 0.74
	var lz := 0.56
	var h := 0.38
	_muri_pietra_b(c, lx, lz, h, 111)
	_porta_b(c, Vector3(-0.15, 0, lz * 0.5), 0.0, 0.13, 0.24, true)
	_finestrella_b(c, Vector3(0.18, 0.27, lz * 0.5 + 0.004), 0.0)
	_finestrella_b(c, Vector3(lx * 0.5 + 0.004, 0.27, 0.0), 90.0)
	sottotetto(c, lx, lz, h, 40.0, "legno_vecchio")
	_tetto_paglia(c, lx, lz, h, 40.0, 111)
	c.add_child(scatola(Vector3(0.09, 0.04, 0.07), Vector3(-0.2, h + 0.2, -0.05), "fuliggine", Vector3(40, 0, 0)))
	_fumo(c, Vector3(-0.18, h + 0.3, -0.06), 3, 0.9)
	# paiolo del latte appeso a un treppiede di pali sopra il fuoco
	var f := Vector3(0.45, 0, 0.45)
	_fuoco(r, f, 1.5)
	var cima := f + Vector3(0, 0.42, 0)
	for k in 3:
		var a := k * TAU / 3 + 0.5
		ramo(r, f + Vector3(cos(a), 0, sin(a)) * 0.19, cima + Vector3(cos(a), 0, sin(a)) * 0.015, 0.014, "corteccia")
	r.add_child(cilindro(0.004, 0.004, 0.14, f + Vector3(0, 0.34, 0), "ferro", Vector3.ZERO, 4))
	r.add_child(sfera(0.1, f + Vector3(0, 0.17, 0), "fuliggine", Vector3(1, 0.8, 1)))
	r.add_child(cilindro(0.088, 0.088, 0.02, f + Vector3(0, 0.235, 0), "ferro", Vector3.ZERO, 14))
	r.add_child(cilindro(0.08, 0.08, 0.006, f + Vector3(0, 0.245, 0), "latte", Vector3.ZERO, 14))
	# rastrelliere di rami con le forme di formaggio
	for p: Vector3 in [Vector3(-0.3, 0, 0.5), Vector3(0.7, 0, -0.05)]:
		var lungo_x := p.x < 0
		for s: int in [-1, 1]:
			var o := Vector3(s * 0.15, 0, 0) if lungo_x else Vector3(0, 0, s * 0.15)
			r.add_child(cilindro(0.011, 0.012, 0.28, p + o + Vector3(0, 0.14, 0), "corteccia", Vector3.ZERO, 5))
		for liv in 3:
			r.add_child(scatola(Vector3(0.3 if lungo_x else 0.08, 0.014, 0.08 if lungo_x else 0.3), p + Vector3(0, 0.05 + liv * 0.08, 0), "legno_vecchio"))
			for k in 3:
				var o2 := Vector3((k - 1) * 0.085, 0, 0) if lungo_x else Vector3(0, 0, (k - 1) * 0.085)
				r.add_child(cilindro(0.035, 0.035, 0.04, p + o2 + Vector3(0, 0.078 + liv * 0.08, 0), "formaggio", Vector3.ZERO, 12))
	# secchi di legno pieni di latte e un vaso
	for p: Vector3 in [Vector3(0.08, 0, 0.62), Vector3(0.19, 0, 0.6)]:
		r.add_child(cilindro(0.04, 0.034, 0.08, p + Vector3(0, 0.04, 0), "legno", Vector3.ZERO, 10))
		r.add_child(cilindro(0.042, 0.042, 0.012, p + Vector3(0, 0.07, 0), "legno_scuro", Vector3.ZERO, 10))
		r.add_child(cilindro(0.036, 0.036, 0.004, p + Vector3(0, 0.079, 0), "latte", Vector3.ZERO, 10))
	r.add_child(_vaso_pece(Vector3(-0.62, 0, 0.3), 0.95))
	return r


## Argillaio dei Brettii: capanno di tronchi con la paglia, fossa d'argilla chiusa dal graticcio, mattoni crudi al sole.
static func argillaio_brettii() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.32, 0, -0.32)
	r.add_child(c)
	var lx := 0.46
	var lz := 0.36
	var h := 0.3
	_muri_tavole_b(c, lx, lz, h, 121)
	_porta_b(c, Vector3(0.06, 0, lz * 0.5 + 0.01), 0.0, 0.11, 0.18, true)
	sottotetto(c, lx, lz, h, 40.0, "legno_vecchio")
	_tetto_paglia(c, lx, lz, h, 40.0, 121, false)
	# fossa d'argilla con il bordo di sassi e il graticcio
	var fo := Vector3(0.3, 0, 0.25)
	r.add_child(sfera(0.3, fo + Vector3(0, -0.02, 0), "argilla", Vector3(1.3, 0.12, 1.0)))
	r.add_child(sfera(0.22, fo, "argilla_cruda", Vector3(1.3, 0.08, 1.0)))
	var rng := _rng(122)
	for k in 12:
		var a := k * TAU / 12 + 0.2
		r.add_child(sfera(rng.randf_range(0.025, 0.035), fo + Vector3(cos(a) * 0.38, 0.01, sin(a) * 0.29), "roccia_massi", Vector3(1.2, 0.7, 1.0)))
	_graticcio(r, fo + Vector3(0.42, 0, -0.25), fo + Vector3(0.42, 0, 0.3))
	# mattoni crudi a seccare, pala, tinozza di tronco con l'acqua
	for k in 12:
		r.add_child(scatola(Vector3(0.07, 0.03, 0.04), Vector3(-0.55 + (k % 4) * 0.09, 0.015 + (k / 4) * 0.032, 0.45), "argilla", Vector3(0, (k % 2) * 5, 0)))
	var pa := attrezzo("pala")
	pa.position = Vector3(0.62, 0.02, 0.05)
	pa.rotation_degrees = Vector3(0, 40, 10)
	r.add_child(pa)
	r.add_child(cilindro(0.07, 0.065, 0.08, Vector3(-0.1, 0.04, 0.6), "corteccia", Vector3.ZERO, 12))
	r.add_child(cilindro(0.058, 0.058, 0.005, Vector3(-0.1, 0.079, 0.6), "acqua_pozzo", Vector3.ZERO, 12))
	_totem(r, Vector3(-0.68, 0, 0.12), 0.4, 9)
	return r


## Fornace dei Brettii: casa di pietra grezza, forno a cupola d'argilla con i sassi murati, vasi rotondi in fila.
static func fornace_brettii() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.25, 0, -0.3)
	r.add_child(c)
	var lx := 0.6
	var lz := 0.46
	var h := 0.32
	_muri_pietra_b(c, lx, lz, h, 231)
	_porta_b(c, Vector3(0.12, 0, lz * 0.5), 0.0, 0.12, 0.22, true)
	_finestrella_b(c, Vector3(lx * 0.5 + 0.004, 0.22, 0.0), 90.0)
	sottotetto(c, lx, lz, h, 40.0, "legno_vecchio")
	_tetto_paglia(c, lx, lz, h, 40.0, 231)
	# forno a cupola d'argilla con sassi murati, bocca accesa e fumo
	var f := Vector3(0.42, 0, 0.35)
	r.add_child(cilindro(0.21, 0.23, 0.12, f + Vector3(0, 0.06, 0), "pietra_grezza", Vector3.ZERO, 18))
	r.add_child(sfera(0.2, f + Vector3(0, 0.12, 0), "argilla_cruda", Vector3(1, 1.0, 1)))
	var rng := _rng(232)
	for k in 12:
		var a := rng.randf_range(-0.6, 2.2)
		var e := rng.randf_range(0.15, 1.2)
		r.add_child(sfera(rng.randf_range(0.018, 0.026), f + Vector3(cos(a) * cos(e) * 0.195, 0.12 + sin(e) * 0.19, sin(a) * cos(e) * 0.195), "roccia_massi", Vector3(1.2, 0.7, 1.0)))
	r.add_child(scatola(Vector3(0.1, 0.09, 0.05), f + Vector3(-0.05, 0.1, 0.19), "fuliggine", Vector3(0, 25, 0)))
	r.add_child(scatola(Vector3(0.08, 0.07, 0.05), f + Vector3(-0.052, 0.095, 0.2), "brace", Vector3(0, 25, 0)))
	_fumo(r, f + Vector3(0.0, 0.34, 0.0), 4, 1.0)
	# vasi rotondi di terracotta in file ad asciugare
	for k in 7:
		r.add_child(_pentola_b(Vector3(-0.6 + (k % 4) * 0.1, 0, 0.42 + (k / 4) * 0.12), 1.15))
	r.add_child(mucchio(Vector3(0.68, 0, -0.15), "argilla", 8, 9))
	legnaia(r, Vector3(0.65, 0, 0.12), 0.2, 3)
	_totem(r, Vector3(-0.7, 0, 0.12), 0.4, 10)
	return r


## Saline dei Brettii: vasche di evaporazione con il bordo di sassi, cumuli di sale, capanno di tronchi con la paglia.
static func saline_brettii() -> Node3D:
	var r := Node3D.new()
	var rng := _rng(131)
	for i in 3:
		for j in 2:
			var p := Vector3(-0.45 + i * 0.42, 0, -0.25 + j * 0.5)
			r.add_child(scatola(Vector3(0.4, 0.04, 0.46), p + Vector3(0, 0.02, 0), "pietra_grezza"))
			var mat := "acqua_pozzo" if (i + j) % 3 != 0 else "sale"
			r.add_child(scatola(Vector3(0.34, 0.005, 0.4), p + Vector3(0, 0.042, 0), mat))
			for k in 5:
				r.add_child(sfera(rng.randf_range(0.018, 0.026), p + Vector3(-0.17 + k * 0.085, 0.04, 0.215), "roccia_massi", Vector3(1.3, 0.7, 0.9)))
				r.add_child(sfera(rng.randf_range(0.018, 0.026), p + Vector3(0.19, 0.04, -0.2 + k * 0.1), "roccia_massi", Vector3(0.9, 0.7, 1.3)))
	for p: Vector3 in [Vector3(0.62, 0, 0.55), Vector3(0.42, 0, 0.62), Vector3(-0.6, 0, 0.6)]:
		r.add_child(sfera(0.1, p, "sale", Vector3(1, 0.9, 1)))
	var c := Node3D.new()
	c.position = Vector3(0.6, 0, -0.55)
	r.add_child(c)
	_muri_tavole_b(c, 0.28, 0.24, 0.22, 132)
	_porta_b(c, Vector3(-0.04, 0, 0.13), 0.0, 0.08, 0.14, true)
	sottotetto(c, 0.28, 0.24, 0.22, 40.0, "legno_vecchio")
	_tetto_paglia(c, 0.28, 0.24, 0.22, 40.0, 132, false)
	var a := attrezzo("pala")
	a.position = Vector3(0.25, 0.02, 0.45)
	a.rotation_degrees = Vector3(0, -30, 5)
	r.add_child(a)
	r.add_child(sacco(Vector3(0.0, 0, 0.62), 0.3))
	_totem(r, Vector3(-0.72, 0, 0.3), 0.38, 11)
	return r


## Tessitura dei Brettii: casa di tronchi con la paglia, telaio verticale coi pesi di pietra e la tela verde, lana e pelli.
static func tessitura_brettii() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.28)
	r.add_child(c)
	var lx := 0.72
	var lz := 0.52
	var h := 0.36
	_muri_tavole_b(c, lx, lz, h, 251)
	_porta_b(c, Vector3(-0.16, 0, lz * 0.5 + 0.01), 0.0, 0.13, 0.23, true)
	_finestrella_b(c, Vector3(0.18, 0.26, lz * 0.5 + 0.012), 0.0, 0.1, 0.08)
	sottotetto(c, lx, lz, h, 40.0, "legno_vecchio")
	_tetto_paglia(c, lx, lz, h, 40.0, 251)
	# telaio a pesi: due pali, subbio in alto, tela a righe verde bosco, pesi di pietra in basso
	var t := Vector3(0.0, 0, 0.5)
	for x: float in [-0.19, 0.19]:
		r.add_child(cilindro(0.014, 0.016, 0.44, t + Vector3(x, 0.22, 0), "corteccia", Vector3.ZERO, 6))
		r.add_child(sfera(0.016, t + Vector3(x, 0.44, 0), "legno_vecchio"))
	r.add_child(cilindro(0.013, 0.013, 0.42, t + Vector3(0, 0.4, 0), "legno", Vector3(0, 0, 90), 6))
	var colori := ["stoffa_verde", "pelliccia", "tufo", "stoffa_verde", "pelliccia", "lana"]
	for k in 6:
		r.add_child(scatola(Vector3(0.34, 0.04, 0.006), t + Vector3(0, 0.36 - k * 0.04, 0), colori[k]))
	for k in 9:
		r.add_child(cilindro(0.002, 0.002, 0.07, t + Vector3(-0.15 + k * 0.0375, 0.1, 0), "lana", Vector3.ZERO, 3))
		r.add_child(sfera(0.016, t + Vector3(-0.15 + k * 0.0375, 0.06, 0), "pietra_grezza", Vector3(1, 1.2, 0.7)))
	# lana grezza, fusi, panca e pelli stese
	for p: Vector3 in [Vector3(0.55, 0, 0.0), Vector3(0.6, 0, 0.2)]:
		r.add_child(sfera(0.05, p + Vector3(0, 0.04, 0), "lana", Vector3(1.2, 0.8, 1)))
	r.add_child(sfera(0.035, Vector3(-0.34, 0.03, 0.5), "lana", Vector3(1.2, 0.8, 1)))
	r.add_child(cilindro(0.004, 0.004, 0.12, Vector3(-0.3, 0.04, 0.5), "legno", Vector3(0, 0, 70), 4))
	r.add_child(cilindro(0.008, 0.008, 0.5, Vector3(0.55, 0.3, -0.35), "corteccia", Vector3(0, 0, 90), 5))
	for x: float in [0.3, 0.8]:
		r.add_child(cilindro(0.01, 0.012, 0.31, Vector3(x, 0.155, -0.35), "corteccia", Vector3.ZERO, 5))
	r.add_child(scatola(Vector3(0.2, 0.2, 0.004), Vector3(0.44, 0.2, -0.35), "stoffa_verde"))
	r.add_child(scatola(Vector3(0.2, 0.18, 0.004), Vector3(0.66, 0.21, -0.35), "pelliccia"))
	_totem(r, Vector3(-0.68, 0, 0.05), 0.44, 12)
	return r


## Capanna del pescatore brettio: tronchi e paglia, reti su pali di corteccia, barca monossile, pesce affumicato sul fuoco.
static func capanna_pescatore_brettii() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.22, 0, -0.25)
	r.add_child(c)
	var lx := 0.66
	var lz := 0.5
	var h := 0.36
	_muri_tavole_b(c, lx, lz, h, 141)
	_porta_b(c, Vector3(0.12, 0, lz * 0.5 + 0.01), 0.0, 0.12, 0.21)
	_finestrella_b(c, Vector3(-0.16, 0.26, lz * 0.5 + 0.012), 0.0)
	sottotetto(c, lx, lz, h, 40.0, "legno_vecchio")
	_tetto_paglia(c, lx, lz, h, 40.0, 141)
	# reti stese ad asciugare su pali di corteccia
	for x: float in [0.35, 0.75]:
		r.add_child(cilindro(0.013, 0.015, 0.38, Vector3(x, 0.19, -0.35), "corteccia", Vector3.ZERO, 6))
	r.add_child(cilindro(0.009, 0.009, 0.46, Vector3(0.55, 0.36, -0.35), "legno_vecchio", Vector3(0, 0, 90), 5))
	r.add_child(scatola(Vector3(0.4, 0.26, 0.006), Vector3(0.55, 0.21, -0.35), "rete"))
	for k in 6:
		r.add_child(scatola(Vector3(0.004, 0.26, 0.008), Vector3(0.37 + k * 0.07, 0.21, -0.345), "corda"))
	for k in 4:
		r.add_child(scatola(Vector3(0.4, 0.004, 0.008), Vector3(0.55, 0.11 + k * 0.065, -0.345), "corda"))
	for k in 5:
		r.add_child(sfera(0.012, Vector3(0.39 + k * 0.08, 0.34, -0.34), "tufo"))
	# barca monossile tirata a secco, con la pagaia
	var b := _monossile(r, Vector3(0.35, 0, 0.45), -25.0)
	b.add_child(cilindro(0.006, 0.006, 0.34, Vector3(0.0, 0.14, 0.02), "legno_chiaro", Vector3(0, 10, 86), 4))
	b.add_child(scatola(Vector3(0.07, 0.006, 0.035), Vector3(-0.18, 0.15, 0.02), "legno_chiaro", Vector3(0, 10, -4)))
	# fuoco con i pesci infilzati sui rami, ceste di pesce, vaso
	_fuoco(r, Vector3(-0.58, 0, 0.3), 1.1)
	for k in 3:
		var a := -0.5 + k * 0.5
		var base := Vector3(-0.58 + cos(a) * 0.13, 0, 0.3 + sin(a) * 0.13)
		ramo(r, base, Vector3(-0.58 + cos(a) * 0.03, 0.2, 0.3 + sin(a) * 0.03), 0.004, "legno_vecchio")
		r.add_child(sfera(0.02, Vector3(-0.58 + cos(a) * 0.06, 0.15, 0.3 + sin(a) * 0.06), "pesce", Vector3(0.8, 2.6, 0.6)))
	r.add_child(cesta(Vector3(-0.42, 0, 0.5), "pesce"))
	r.add_child(cesta(Vector3(-0.27, 0, 0.6), "pesce"))
	r.add_child(_vaso_pece(Vector3(-0.66, 0, 0.05), 0.95))
	_totem(r, Vector3(0.78, 0, 0.05), 0.42, 13)
	return r


## Frantoio dei Brettii: grande casa di pietra grezza e paglia, macina di pietra in una vasca di sassi, giare e vasi.
static func frantoio_brettii() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.22)
	r.add_child(c)
	var lx := 0.82
	var lz := 0.62
	var h := 0.42
	_muri_pietra_b(c, lx, lz, h, 13)
	_porta_b(c, Vector3(0.18, 0, lz * 0.5), 0.0, 0.15, 0.25)
	_finestrella_b(c, Vector3(-0.18, 0.3, lz * 0.5 + 0.004), 0.0, 0.1, 0.09)
	_finestrella_b(c, Vector3(lx * 0.5 + 0.004, 0.3, 0.0), 90.0)
	sottotetto(c, lx, lz, h, 40.0, "legno_vecchio")
	_tetto_paglia(c, lx, lz, h, 40.0, 13)
	c.add_child(scatola(Vector3(0.09, 0.04, 0.07), Vector3(-0.22, h + 0.22, -0.06), "fuliggine", Vector3(40, 0, 0)))
	_fumo(c, Vector3(-0.2, h + 0.32, -0.07), 3, 0.9)
	# macina: vasca di pietra grezza, ruota di pietra, stanga di tronco
	var m := Vector3(-0.35, 0, 0.55)
	r.add_child(cilindro(0.26, 0.28, 0.1, m + Vector3(0, 0.05, 0), "pietra_grezza", Vector3.ZERO, 22))
	var rng := _rng(14)
	for k in 14:
		var a := rng.randf_range(-0.5, 2.0)
		r.add_child(sfera(rng.randf_range(0.022, 0.03), m + Vector3(cos(a) * 0.275, rng.randf_range(0.03, 0.08), sin(a) * 0.275), "roccia_massi", Vector3(1.2, 0.75, 1.0)))
	r.add_child(cilindro(0.21, 0.21, 0.01, m + Vector3(0, 0.101, 0), "foglie_ulivo", Vector3.ZERO, 24))
	r.add_child(cilindro(0.032, 0.035, 0.24, m + Vector3(0, 0.2, 0), "corteccia", Vector3.ZERO, 8))
	r.add_child(cilindro(0.12, 0.12, 0.08, m + Vector3(0.1, 0.22, 0), "pietra_grezza", Vector3(0, 0, 90), 16))
	r.add_child(cilindro(0.018, 0.02, 0.62, m + Vector3(0.2, 0.26, 0), "corteccia", Vector3(0, 0, 90), 6))
	# giare d'olio e vasi sigillati, ceste di olive, tinozza di tronco
	for i in 6:
		if i % 2 == 0:
			r.add_child(anfora(Vector3(0.25 + (i % 3) * 0.1, 0.0, 0.42 + (i / 3) * 0.11), 1.15))
		else:
			r.add_child(_pentola_b(Vector3(0.25 + (i % 3) * 0.1, 0.0, 0.42 + (i / 3) * 0.11), 1.15))
	for i in 3:
		r.add_child(cesta(Vector3(0.64, 0, -0.3 + i * 0.16), "olive"))
	r.add_child(cilindro(0.07, 0.065, 0.1, Vector3(0.62, 0.05, 0.25), "corteccia", Vector3.ZERO, 12))
	r.add_child(cilindro(0.058, 0.058, 0.005, Vector3(0.62, 0.099, 0.25), "oliva", Vector3.ZERO, 12))
	var u := ulivo(31)
	u.position = Vector3(-0.7, 0, -0.45)
	u.scale = Vector3.ONE * 0.8
	r.add_child(u)
	_totem(r, Vector3(0.05, 0, 0.66), 0.42, 14)
	return r


## Uliveto dei Brettii: baita di pietra con scandole e sassi, ulivo col telo steso, ceste e scala di rami.
static func uliveto_brettii() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.3, 0, -0.3)
	r.add_child(c)
	var lx := 0.58
	var lz := 0.46
	var h := 0.32
	_muri_pietra_b(c, lx, lz, h, 151)
	_porta_b(c, Vector3(-0.08, 0, lz * 0.5), 0.0, 0.12, 0.21, true)
	_finestrella_b(c, Vector3(lx * 0.5 + 0.004, 0.22, 0.0), 90.0, 0.07, 0.07)
	sottotetto(c, lx, lz, h, 30.0, "legno_vecchio")
	_tetto_scandole_sassi(c, lx + 0.06, lz, h, 30.0, 151)
	# telo steso sotto l'ulivo con le olive cadute, ceste, scala di rami
	var u := ulivo(152)
	u.position = Vector3(0.35, 0, 0.3)
	u.scale = Vector3.ONE * 0.8
	r.add_child(u)
	r.add_child(scatola(Vector3(0.5, 0.004, 0.45), Vector3(0.35, 0.004, 0.3), "lana", Vector3(0, 12, 0)))
	for k in 12:
		r.add_child(sfera(0.012, Vector3(0.2 + (k % 4) * 0.08, 0.012, 0.18 + (k / 4) * 0.1), "oliva"))
	for p: Vector3 in [Vector3(-0.45, 0, 0.45), Vector3(-0.25, 0, 0.55), Vector3(0.7, 0, -0.2)]:
		r.add_child(cesta(p, "olive"))
	for lato: int in [-1, 1]:
		ramo(r, Vector3(0.05, 0, 0.16 + lato * 0.04), Vector3(0.2, 0.44, 0.16 + lato * 0.04), 0.008, "corteccia")
	for k in 5:
		var t := (k + 1) / 6.0
		r.add_child(cilindro(0.005, 0.005, 0.09, Vector3(0.05 + 0.15 * t, 0.44 * t, 0.16), "legno_vecchio", Vector3(90, 0, 0), 4))
	r.add_child(_vaso_pece(Vector3(-0.6, 0, 0.3), 0.95))
	_totem(r, Vector3(-0.66, 0, 0.0), 0.4, 15)
	return r


## Vigneto dei Brettii: casa di tronchi con la paglia, pergola di pali scortecciati, tino di tronco cavo, ceste d'uva.
static func vigneto_brettii() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.25, 0, -0.3)
	r.add_child(c)
	var lx := 0.66
	var lz := 0.5
	var h := 0.34
	_muri_tavole_b(c, lx, lz, h, 161)
	_porta_b(c, Vector3(0.1, 0, lz * 0.5 + 0.01), 0.0, 0.13, 0.22, true)
	_finestrella_b(c, Vector3(-0.18, 0.25, lz * 0.5 + 0.012), 0.0)
	sottotetto(c, lx, lz, h, 40.0, "legno_vecchio")
	_tetto_paglia(c, lx, lz, h, 40.0, 161)
	# pergola di pali di corteccia con le traverse legate, foglie e grappoli
	for p: Vector3 in [Vector3(-0.35, 0, 0.15), Vector3(0.25, 0, 0.15), Vector3(-0.35, 0, 0.55), Vector3(0.25, 0, 0.55)]:
		r.add_child(cilindro(0.014, 0.017, 0.37, p + Vector3(0, 0.185, 0), "corteccia", Vector3.ZERO, 6))
	for z: float in [0.15, 0.55]:
		r.add_child(cilindro(0.01, 0.01, 0.66, Vector3(-0.05, 0.36, z), "legno_vecchio", Vector3(0, 0, 90), 5))
	for x: float in [-0.35, -0.05, 0.25]:
		r.add_child(cilindro(0.008, 0.008, 0.46, Vector3(x, 0.365, 0.35), "legno_vecchio", Vector3(90, 0, 0), 5))
	var rng := _rng(162)
	for k in 26:
		r.add_child(sfera(0.045, Vector3(rng.randf_range(-0.38, 0.28), 0.38, rng.randf_range(0.12, 0.58)), "foglie" if k % 3 else "foglie_chiare", Vector3(1, 0.5, 1)))
	for k in 6:
		r.add_child(sfera(0.022, Vector3(-0.3 + k * 0.1, 0.33, 0.35 + (k % 2) * 0.1), "uva", Vector3(1, 1.5, 1)))
	ramo(r, Vector3(-0.35, 0, 0.55), Vector3(-0.3, 0.36, 0.5), 0.01, "corteccia")
	# tino di tronco cavo pieno d'uva, ceste, otre
	r.add_child(cilindro(0.1, 0.095, 0.13, Vector3(0.55, 0.065, 0.4), "corteccia", Vector3.ZERO, 14))
	r.add_child(cilindro(0.088, 0.088, 0.005, Vector3(0.55, 0.128, 0.4), "uva", Vector3.ZERO, 14))
	for y: float in [0.03, 0.1]:
		r.add_child(cilindro(0.102, 0.102, 0.01, Vector3(0.55, y, 0.4), "corda", Vector3.ZERO, 14))
	r.add_child(cesta(Vector3(0.6, 0, 0.0), "uva"))
	r.add_child(cesta(Vector3(0.45, 0, -0.2), "uva"))
	r.add_child(_otre(Vector3(0.38, 0, 0.64), 20.0, 1.0))
	_teschio(c, Vector3(lx * 0.5 + 0.03, h + 0.14, 0), 90.0, 1.3)
	return r


## Cantina dei Brettii: casa di pietra con scandole e sassi, botti coricate, otri di pelle, palmento scavato nella roccia.
static func cantina_brettii() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.25)
	r.add_child(c)
	var lx := 0.76
	var lz := 0.56
	var h := 0.38
	_muri_pietra_b(c, lx, lz, h, 171)
	_porta_b(c, Vector3(0.15, 0, lz * 0.5), 0.0, 0.16, 0.24)
	_finestrella_b(c, Vector3(-0.2, 0.27, lz * 0.5 + 0.004), 0.0)
	sottotetto(c, lx, lz, h, 30.0, "legno_vecchio")
	_tetto_scandole_sassi(c, lx + 0.06, lz, h, 30.0, 171)
	# botti coricate su travi di tronco
	for x: float in [0.5, 0.74]:
		r.add_child(cilindro(0.018, 0.018, 0.6, Vector3(x, 0.018, -0.1), "corteccia", Vector3(90, 0, 0), 6))
	for k in 3:
		var b := barile(Vector3(0.62, 0, -0.3 + k * 0.2), 1.5)
		b.rotation_degrees.x = 90
		b.position.y = 0.09
		r.add_child(b)
	# otri di pelle e vasi di vino
	for k in 3:
		r.add_child(_otre(Vector3(-0.6 + k * 0.12, 0, 0.42 + (k % 2) * 0.05), k * 40.0, 1.0))
	r.add_child(_pentola_b(Vector3(-0.55, 0, 0.56), 1.1))
	r.add_child(_pentola_b(Vector3(-0.44, 0, 0.6), 1.0))
	# palmento: vasca scavata in un masso, col vino che cola nel catino
	r.add_child(_masso(Vector3(0.2, 0.0, 0.55), 0.17, Vector3(1.3, 0.55, 1.05), "roccia_massi", 20))
	r.add_child(scatola(Vector3(0.28, 0.012, 0.2), Vector3(0.2, 0.09, 0.55), "vino"))
	r.add_child(cilindro(0.05, 0.045, 0.04, Vector3(0.34, 0.02, 0.7), "pietra_grezza", Vector3.ZERO, 12))
	r.add_child(cilindro(0.04, 0.04, 0.004, Vector3(0.34, 0.041, 0.7), "vino", Vector3.ZERO, 12))
	r.add_child(cesta(Vector3(-0.15, 0, 0.6), "uva"))
	_teschio(c, Vector3(lx * 0.5 + 0.03, h + 0.12, 0), 90.0, 1.4)
	return r


## Ortolano dei Brettii: casa di pietra grezza e paglia, orto chiuso dal graticcio, trecce di cipolle sulla rastrelliera.
static func ortolano_brettii() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.3, 0, -0.3)
	r.add_child(c)
	var lx := 0.58
	var lz := 0.46
	var h := 0.32
	_muri_pietra_b(c, lx, lz, h, 181)
	_porta_b(c, Vector3(0.08, 0, lz * 0.5), 0.0, 0.12, 0.21, true)
	_finestrella_b(c, Vector3(-0.16, 0.22, lz * 0.5 + 0.004), 0.0)
	sottotetto(c, lx, lz, h, 40.0, "legno_vecchio")
	_tetto_paglia(c, lx, lz, h, 40.0, 181)
	# orto con le file di cavoli e fave, chiuso dal graticcio
	var o := Vector3(0.45, 0, 0.0)
	r.add_child(scatola(Vector3(0.36, 0.012, 0.6), o + Vector3(0, 0.006, 0), "terra"))
	var rng := _rng(182)
	for f in 8:
		for k in 5:
			r.add_child(sfera(rng.randf_range(0.018, 0.026), o + Vector3(-0.15 + k * 0.075, 0.025, -0.26 + f * 0.075), "orto" if f % 3 != 2 else "foglie_chiare", Vector3(1, 0.8, 1)))
	_graticcio(r, o + Vector3(-0.2, 0, 0.32), o + Vector3(0.2, 0, 0.32))
	_graticcio(r, o + Vector3(0.2, 0, -0.32), o + Vector3(0.2, 0, 0.32))
	_graticcio(r, o + Vector3(-0.2, 0, -0.32), o + Vector3(0.2, 0, -0.32))
	# rastrelliera di pali con le trecce di cipolle appese
	for x: float in [-0.56, -0.2]:
		r.add_child(cilindro(0.011, 0.013, 0.36, Vector3(x, 0.18, 0.04), "corteccia", Vector3.ZERO, 5))
	r.add_child(cilindro(0.009, 0.009, 0.42, Vector3(-0.38, 0.35, 0.04), "legno_vecchio", Vector3(0, 0, 90), 5))
	for k in 4:
		for i in 4:
			r.add_child(sfera(0.02, Vector3(-0.5 + k * 0.08, 0.3 - i * 0.04, 0.04), "cipolla"))
	for p: Vector3 in [Vector3(-0.4, 0, 0.45), Vector3(-0.2, 0, 0.55)]:
		r.add_child(cesta(p, "ortaggi"))
	r.add_child(cesta(Vector3(0.05, 0, 0.6), "cipolle"))
	_totem(r, Vector3(-0.7, 0, 0.2), 0.4, 17)
	return r


## Agrumeto dei Brettii: casa di tronchi con la paglia, l'albero di agrumi chiuso dal graticcio, ceste e vasi.
static func agrumeto_brettii() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.3, 0, -0.3)
	r.add_child(c)
	var lx := 0.6
	var lz := 0.46
	var h := 0.34
	_muri_tavole_b(c, lx, lz, h, 191)
	_porta_b(c, Vector3(-0.1, 0, lz * 0.5 + 0.01), 0.0, 0.12, 0.22, true)
	_finestrella_b(c, Vector3(0.15, 0.25, lz * 0.5 + 0.012), 0.0)
	sottotetto(c, lx, lz, h, 40.0, "legno_vecchio")
	_tetto_paglia(c, lx, lz, h, 40.0, 191)
	var a := agrumi(3)
	var terra := a.get_child(0)
	a.remove_child(terra)
	terra.free()
	a.position = Vector3(0.3, 0, 0.25)
	a.scale = Vector3.ONE * 1.1
	r.add_child(a)
	_graticcio(r, Vector3(-0.05, 0, 0.66), Vector3(0.66, 0, 0.66))
	_graticcio(r, Vector3(0.66, 0, 0.0), Vector3(0.66, 0, 0.66))
	for p: Vector3 in [Vector3(-0.45, 0, 0.45), Vector3(-0.25, 0, 0.58), Vector3(0.72, 0, -0.25)]:
		r.add_child(cesta(p, "agrumi"))
	r.add_child(cassa(Vector3(0.62, 0, -0.08), 20))
	r.add_child(_vaso_pece(Vector3(-0.6, 0, 0.3), 0.95))
	_totem(r, Vector3(-0.66, 0, 0.0), 0.4, 18)
	return r


## Pesca del pesce spada dei Brettii: baita di pietra con scandole e sassi, feluca di legno grezzo con l'albero
## di vedetta e la passerella, l'arpione e il pesce spada sul graticcio.
static func pesca_spada_brettii() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.3, 0, -0.3)
	r.add_child(c)
	var lx := 0.6
	var lz := 0.46
	var h := 0.32
	_muri_pietra_b(c, lx, lz, h, 201)
	_porta_b(c, Vector3(0.1, 0, lz * 0.5), 0.0, 0.12, 0.22)
	_finestrella_b(c, Vector3(lx * 0.5 + 0.004, 0.22, 0.0), 90.0, 0.07, 0.07)
	sottotetto(c, lx, lz, h, 30.0, "legno_vecchio")
	_tetto_scandole_sassi(c, lx + 0.06, lz, h, 30.0, 201)
	# la feluca: scafo di legno grezzo, albero di vedetta coi pioli, drappo verde in cima, passerella
	var b := Node3D.new()
	b.position = Vector3(0.3, 0, 0.35)
	b.rotation_degrees.y = -30
	r.add_child(b)
	b.add_child(sfera(0.15, Vector3(0, 0.07, 0), "legno_vecchio", Vector3(2.8, 0.7, 1.0)))
	b.add_child(sfera(0.13, Vector3(0, 0.1, 0), "legno_scuro", Vector3(2.7, 0.35, 0.9)))
	b.add_child(scatola(Vector3(0.8, 0.022, 0.03), Vector3(0, 0.14, 0.13), "corteccia"))
	b.add_child(scatola(Vector3(0.8, 0.022, 0.03), Vector3(0, 0.14, -0.13), "corteccia"))
	b.add_child(scatola(Vector3(0.6, 0.012, 0.01), Vector3(0, 0.1, 0.152), "stoffa_verde"))
	b.add_child(cilindro(0.012, 0.009, 0.62, Vector3(0.0, 0.43, 0), "corteccia", Vector3.ZERO, 6))
	for k in 5:
		b.add_child(cilindro(0.005, 0.005, 0.08, Vector3(0.0, 0.2 + k * 0.08, 0.0), "legno_vecchio", Vector3(90, 0, 0), 4))
	b.add_child(scatola(Vector3(0.006, 0.07, 0.1), Vector3(0.0, 0.7, 0.055), "stoffa_verde"))
	b.add_child(scatola(Vector3(0.45, 0.014, 0.022), Vector3(0.55, 0.13, 0), "legno"))
	_teschio(b, Vector3(0.38, 0.16, 0), 90.0, 0.9)
	# arpione appoggiato al cavalletto e il pesce spada sul graticcio di rami
	r.add_child(scatola(Vector3(0.02, 0.012, 0.5), Vector3(-0.6, 0.15, 0.4), "legno", Vector3(0, 0, 4)))
	r.add_child(cilindro(0.01, 0.0, 0.05, Vector3(-0.6, 0.152, 0.67), "ferro", Vector3(90, 0, 0), 5))
	for z: float in [0.2, 0.6]:
		ramo(r, Vector3(-0.66, 0, z), Vector3(-0.6, 0.15, z), 0.008, "corteccia")
		ramo(r, Vector3(-0.54, 0, z), Vector3(-0.6, 0.15, z), 0.008, "corteccia")
	r.add_child(scatola(Vector3(0.3, 0.012, 0.18), Vector3(-0.32, 0.03, 0.55), "legno_vecchio"))
	for x: float in [-0.44, -0.2]:
		r.add_child(cilindro(0.012, 0.012, 0.03, Vector3(x, 0.015, 0.55), "corteccia", Vector3.ZERO, 5))
	var sp := pesce_spada_modello()
	sp.position = Vector3(-0.35, 0.03, 0.55)
	r.add_child(sp)
	r.add_child(_vaso_pece(Vector3(0.66, 0, -0.2), 0.95))
	return r


## Miniera dei Brettii: imbocco nella montagna armato di tronchi con la corteccia, teschio sopra, scalini di tronchi,
## slitta di legno col minerale, torcia su un palo e ceste.
static func miniera_ferro_brettii(minerale := "minerale") -> Node3D:
	var r := Node3D.new()
	r.add_child(sfera(0.6, Vector3(-0.25, 0.0, -0.3), "roccia_massi", Vector3(1.2, 0.75, 1.0)))
	r.add_child(sfera(0.35, Vector3(0.35, 0.0, -0.45), "roccia_massi", Vector3(1.1, 0.8, 1.0)))
	r.add_child(sfera(0.3, Vector3(-0.65, 0.0, 0.15), "roccia_massi", Vector3(1.0, 0.7, 1.0)))
	r.add_child(sfera(0.06, Vector3(-0.45, 0.38, -0.2), "macchia"))
	r.add_child(sfera(0.05, Vector3(0.3, 0.26, -0.35), "macchia"))
	var imb := Vector3(-0.05, 0, 0.18)
	r.add_child(scatola(Vector3(0.22, 0.26, 0.1), imb + Vector3(0, 0.13, 0), "buio"))
	for lato: int in [-1, 1]:
		r.add_child(cilindro(0.024, 0.028, 0.31, imb + Vector3(lato * 0.135, 0.155, 0.05), "corteccia", Vector3.ZERO, 7))
	r.add_child(cilindro(0.026, 0.026, 0.38, imb + Vector3(0, 0.32, 0.05), "corteccia", Vector3(0, 0, 90), 7))
	r.add_child(cilindro(0.02, 0.02, 0.3, imb + Vector3(0, 0.36, 0.04), "legno_vecchio", Vector3(0, 0, 90), 7))
	_teschio(r, imb + Vector3(0, 0.41, 0.08), 0.0, 1.3)
	for lato: int in [-1, 1]:
		r.add_child(cilindro(0.008, 0.008, 0.05, imb + Vector3(lato * 0.17, 0.32, 0.08), "legno_vecchio", Vector3(0, 0, 90), 5))
		r.add_child(sfera(0.012, imb + Vector3(lato * 0.2, 0.32, 0.08), "stoffa_verde"))
	# scalini di tronchi che scendono dall'imbocco
	for k in 5:
		r.add_child(cilindro(0.016, 0.016, 0.16, imb + Vector3(0, 0.012, 0.12 + k * 0.1), "corteccia", Vector3(0, 0, 90), 6))
	# slitta di legno carica di minerale
	var sl := Vector3(-0.05, 0, 0.55)
	for lato: int in [-1, 1]:
		r.add_child(scatola(Vector3(0.016, 0.02, 0.24), sl + Vector3(lato * 0.065, 0.01, 0), "legno_vecchio"))
		r.add_child(cilindro(0.01, 0.01, 0.04, sl + Vector3(lato * 0.065, 0.03, 0.12), "legno_vecchio", Vector3(60, 0, 0), 5))
	r.add_child(scatola(Vector3(0.15, 0.05, 0.18), sl + Vector3(0, 0.045, 0), "legno"))
	r.add_child(scatola(Vector3(0.155, 0.012, 0.185), sl + Vector3(0, 0.07, 0), "legno_scuro"))
	r.add_child(mucchio(sl + Vector3(0, 0.07, 0), minerale, 6, 3, 0.03))
	ramo(r, sl + Vector3(0, 0.03, 0.09), sl + Vector3(0.05, 0.12, 0.25), 0.004, "corda")
	# mucchio di minerale, torcia su un palo, ceste e tronchi di scorta
	r.add_child(mucchio(Vector3(0.45, 0, 0.35), minerale, 14, 4))
	r.add_child(cesta(Vector3(0.62, 0, 0.55), "carbone", 0.9))
	r.add_child(cilindro(0.011, 0.013, 0.3, Vector3(0.22, 0.15, 0.3), "corteccia", Vector3.ZERO, 5))
	r.add_child(cilindro(0.018, 0.014, 0.04, Vector3(0.22, 0.31, 0.3), "fuliggine", Vector3.ZERO, 6))
	r.add_child(cilindro(0.016, 0.0, 0.05, Vector3(0.22, 0.355, 0.3), "brace", Vector3.ZERO, 6))
	for k in 4:
		r.add_child(cilindro(0.02, 0.02, 0.4, Vector3(-0.55 + k * 0.045, 0.02 + (k % 2) * 0.032, 0.55), "corteccia", Vector3(0, 70, 90), 6))
	_totem(r, Vector3(0.66, 0, 0.12), 0.42, 21)
	return r


## Carbonaia dei Brettii: capanna conica di pali e frasche del carbonaio, cupola di legna sotto la terra che fuma,
## legna, carbone e il rastrello.
static func carbonaia_brettii() -> Node3D:
	var r := Node3D.new()
	# capanna conica di pali coperti di frasche e zolle
	var cp := Vector3(-0.4, 0, -0.38)
	r.add_child(cilindro(0.25, 0.26, 0.04, cp + Vector3(0, 0.02, 0), "roccia_massi", Vector3.ZERO, 14))
	r.add_child(cilindro(0.24, 0.02, 0.5, cp + Vector3(0, 0.27, 0), "paglia_scura", Vector3.ZERO, 16))
	r.add_child(cilindro(0.2, 0.06, 0.24, cp + Vector3(0, 0.16, 0), "terra", Vector3.ZERO, 16))
	var rng := _rng(301)
	for k in 9:
		var a := k * TAU / 9 + 0.3
		ramo(r, cp + Vector3(cos(a) * 0.25, 0.02, sin(a) * 0.25), cp + Vector3(cos(a) * 0.01, 0.58, sin(a) * 0.01), 0.011, "corteccia")
	for k in 16:
		var a := rng.randf_range(-0.6, 2.2)
		var y := rng.randf_range(0.06, 0.24)
		var rr := 0.24 - y * 0.75
		r.add_child(sfera(rng.randf_range(0.025, 0.035), cp + Vector3(cos(a) * rr, y, sin(a) * rr), "terra" if k % 2 else "foglie_scure", Vector3(1.2, 0.7, 1.0)))
	var t := deg_to_rad(40.0)
	r.add_child(scatola(Vector3(0.09, 0.15, 0.04), cp + Vector3(sin(t) * 0.215, 0.09, cos(t) * 0.215), "buio", Vector3(0, 40, 0)))
	_teschio(r, cp + Vector3(0, 0.62, 0), 45.0, 1.0)
	# la carbonaia: cupola di legna coperta di terra, che fuma
	var m := Vector3(0.22, 0, 0.2)
	r.add_child(sfera(0.36, m, "terra", Vector3(1, 0.7, 1)))
	r.add_child(sfera(0.3, m + Vector3(0, 0.03, 0), "fuliggine", Vector3(1, 0.7, 1)))
	r.add_child(sfera(0.37, m + Vector3(0, -0.01, 0), "terra", Vector3(1, 0.68, 1)))
	for k in 10:
		var a := k * 0.63
		r.add_child(sfera(0.04, m + Vector3(cos(a) * 0.3, 0.1, sin(a) * 0.3), "foglie_scure", Vector3(1.3, 0.5, 1.0)))
	for k in 5:
		r.add_child(sfera(0.05 + k * 0.012, m + Vector3(0.02 * k, 0.28 + k * 0.07, -0.01 * k), "fumo", Vector3(1, 0.8, 1)))
	r.add_child(scatola(Vector3(0.06, 0.04, 0.04), m + Vector3(0.0, 0.12, 0.33), "buio"))
	r.add_child(sfera(0.018, m + Vector3(0.0, 0.12, 0.345), "brace"))
	# legna da cuocere, carbone pronto, sacchi e rastrello di rami
	legnaia(r, Vector3(-0.55, 0, 0.35), 0.35, 4)
	r.add_child(mucchio(Vector3(0.62, 0, -0.25), "carbone", 12, 5))
	r.add_child(cesta(Vector3(0.66, 0, 0.0), "carbone"))
	r.add_child(sacco(Vector3(0.6, 0, 0.55), 0.4))
	ramo(r, Vector3(-0.2, 0.01, 0.6), Vector3(0.1, 0.02, 0.5), 0.007, "legno_vecchio")
	for k in 4:
		r.add_child(cilindro(0.004, 0.004, 0.05, Vector3(0.1, 0.02, 0.47 + k * 0.022), "legno_vecchio", Vector3(0, 0, 90), 4))
	return r


## Fonderia dei Brettii: casa di pietra con scandole e sassi, basso forno di pietra grezza e argilla, mantici di pelle.
static func fonderia_brettii() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.25, 0, -0.25)
	r.add_child(c)
	var lx := 0.66
	var lz := 0.52
	var h := 0.36
	_muri_pietra_b(c, lx, lz, h, 211)
	_porta_b(c, Vector3(-0.12, 0, lz * 0.5), 0.0, 0.14, 0.24)
	_finestrella_b(c, Vector3(lx * 0.5 + 0.004, 0.25, 0.0), 90.0)
	sottotetto(c, lx, lz, h, 30.0, "legno_vecchio")
	_tetto_scandole_sassi(c, lx + 0.06, lz, h, 30.0, 211)
	# basso forno: tronco di cono di pietra grezza intonacato d'argilla, bocca accesa, fumo
	var f := Vector3(0.42, 0, 0.38)
	r.add_child(cilindro(0.15, 0.21, 0.46, f + Vector3(0, 0.23, 0), "argilla_cruda", Vector3.ZERO, 16))
	var rng := _rng(212)
	for k in 18:
		var a := rng.randf_range(-0.7, 2.3)
		var y := rng.randf_range(0.04, 0.42)
		var rr := 0.21 - y * 0.13 + 0.004
		r.add_child(sfera(rng.randf_range(0.02, 0.03), f + Vector3(cos(a) * rr, y, sin(a) * rr), "roccia_massi", Vector3(1.2, 0.75, 1.0)))
	r.add_child(cilindro(0.13, 0.15, 0.06, f + Vector3(0, 0.49, 0), "fuliggine", Vector3.ZERO, 16))
	r.add_child(cilindro(0.1, 0.1, 0.01, f + Vector3(0, 0.52, 0), "brace", Vector3.ZERO, 14))
	r.add_child(scatola(Vector3(0.1, 0.1, 0.05), f + Vector3(-0.05, 0.1, 0.18), "fuliggine", Vector3(0, 25, 0)))
	r.add_child(scatola(Vector3(0.08, 0.08, 0.05), f + Vector3(-0.052, 0.095, 0.19), "brace", Vector3(0, 25, 0)))
	_fumo(r, f + Vector3(0.0, 0.6, 0.0), 4, 1.2)
	# due mantici di pelle con il manico di legno
	for k in 2:
		var mp := f + Vector3(-0.27, 0.05, -0.04 + k * 0.13)
		r.add_child(sfera(0.06, mp, "pelle_scura", Vector3(1.4, 0.5, 1.0)))
		r.add_child(cilindro(0.008, 0.008, 0.12, mp + Vector3(-0.06, 0.06, 0), "legno", Vector3(0, 0, 60), 5))
		r.add_child(cilindro(0.008, 0.004, 0.1, mp + Vector3(0.09, 0.0, 0), "legno_scuro", Vector3(0, 0, 90), 5))
	# lingotti, carbone e minerale in attesa
	for k in 6:
		r.add_child(scatola(Vector3(0.09, 0.025, 0.035), Vector3(-0.45 + (k % 3) * 0.1, 0.013 + (k / 3) * 0.026, 0.55), "lingotto"))
	r.add_child(mucchio(Vector3(-0.62, 0, 0.25), "carbone", 9, 6))
	r.add_child(mucchio(Vector3(0.68, 0, -0.1), "minerale", 9, 7))
	_totem(r, Vector3(-0.62, 0, 0.05), 0.4, 19)
	return r


## Fabbro dei Brettii: casa di tronchi con la paglia, fucina all'aperto sotto la tettoia, incudine sul ceppo, attrezzi appesi.
static func fabbro_brettii() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.28)
	r.add_child(c)
	var lx := 0.72
	var lz := 0.5
	var h := 0.38
	_muri_tavole_b(c, lx, lz, h, 221)
	_porta_b(c, Vector3(0.16, 0, lz * 0.5 + 0.01), 0.0, 0.13, 0.24)
	_finestrella_b(c, Vector3(-0.18, 0.27, lz * 0.5 + 0.012), 0.0)
	sottotetto(c, lx, lz, h, 40.0, "legno_vecchio")
	_tetto_paglia(c, lx, lz, h, 40.0, 221)
	c.add_child(scatola(Vector3(0.09, 0.04, 0.07), Vector3(-0.22, h + 0.2, -0.04), "fuliggine", Vector3(40, 0, 0)))
	_fumo(c, Vector3(-0.2, h + 0.3, -0.05), 3, 0.9)
	# tettoia di paglia sopra la fucina
	_tettoia_paglia(r, Vector3(-0.28, 0, 0.42), 0.44, 0.2, 0.46, 0.4)
	# focolare di pietra grezza con le braci, incudine sul ceppo, mantice
	r.add_child(scatola(Vector3(0.2, 0.12, 0.16), Vector3(-0.38, 0.06, 0.44), "pietra_grezza"))
	var rng := _rng(222)
	for k in 6:
		r.add_child(sfera(rng.randf_range(0.02, 0.028), Vector3(-0.46 + k * 0.032, rng.randf_range(0.03, 0.1), 0.52), "roccia_massi", Vector3(1.3, 0.75, 0.4)))
	r.add_child(scatola(Vector3(0.14, 0.01, 0.1), Vector3(-0.38, 0.125, 0.44), "brace"))
	r.add_child(sfera(0.045, Vector3(-0.54, 0.06, 0.42), "pelle_scura", Vector3(1.4, 0.5, 1.0)))
	r.add_child(cilindro(0.04, 0.05, 0.08, Vector3(0.08, 0.04, 0.6), "corteccia", Vector3.ZERO, 10))
	r.add_child(scatola(Vector3(0.12, 0.04, 0.05), Vector3(0.08, 0.1, 0.6), "ferro"))
	r.add_child(scatola(Vector3(0.04, 0.025, 0.035), Vector3(0.16, 0.1, 0.6), "ferro"))
	r.add_child(sfera(0.012, Vector3(0.06, 0.13, 0.6), "brace", Vector3(1.6, 0.5, 1)))
	# attrezzi appesi alla trave di dietro della tettoia
	r.add_child(cilindro(0.01, 0.01, 0.5, Vector3(-0.28, 0.36, 0.32), "legno_vecchio", Vector3(0, 0, 90), 5))
	for k in 4:
		var a := attrezzo(ATTREZZI_FABBRO[k])
		a.position = Vector3(-0.43 + k * 0.1, 0.26, 0.33)
		a.rotation_degrees = Vector3(90, 0, 90)
		r.add_child(a)
	# tinozza di tronco con l'acqua, lingotti, palo intagliato
	r.add_child(cilindro(0.07, 0.065, 0.1, Vector3(0.62, 0.05, 0.1), "corteccia", Vector3.ZERO, 12))
	r.add_child(cilindro(0.058, 0.058, 0.005, Vector3(0.62, 0.099, 0.1), "acqua_pozzo", Vector3.ZERO, 12))
	for k in 3:
		r.add_child(scatola(Vector3(0.09, 0.025, 0.035), Vector3(0.45, 0.013 + k * 0.026, 0.45), "lingotto"))
	_totem(r, Vector3(-0.62, 0, 0.5), 0.4, 20)
	return r


## Armaiolo dei Brettii: la fucina del fabbro con la rastrelliera di giavellotti, scudi ovali dipinti e fionde.
static func armaiolo_brettii() -> Node3D:
	var r := fabbro_brettii()
	# rastrelliera di giavellotti appoggiata a una traversa
	r.add_child(cilindro(0.008, 0.008, 0.3, Vector3(0.48, 0.34, 0.42), "corteccia", Vector3(0, 0, 90), 5))
	for x: float in [0.34, 0.62]:
		r.add_child(cilindro(0.01, 0.012, 0.36, Vector3(x, 0.18, 0.42), "corteccia", Vector3.ZERO, 5))
	for k in 5:
		r.add_child(cilindro(0.006, 0.006, 0.5, Vector3(0.38 + k * 0.05, 0.25, 0.4), "legno", Vector3(0, 0, -8), 5))
		r.add_child(cilindro(0.012, 0.0, 0.05, Vector3(0.38 + k * 0.05 - 0.035, 0.52, 0.4), "ferro", Vector3(0, 0, -8), 5))
	# scudi ovali di legno con l'umbone e la fascia verde
	for k in 2:
		var s := Node3D.new()
		s.position = Vector3(0.7, 0.12, 0.18 + k * 0.17)
		s.rotation_degrees = Vector3(0, 0, 80)
		r.add_child(s)
		s.add_child(sfera(0.085, Vector3.ZERO, "legno", Vector3(1.0, 0.12, 0.7)))
		s.add_child(scatola(Vector3(0.15, 0.022, 0.02), Vector3(0, 0.002, 0), "stoffa_verde"))
		s.add_child(sfera(0.022, Vector3(0, 0.01, 0), "ferro", Vector3(1, 0.6, 1)))
	# fionde e sassi tondi da lancio
	r.add_child(cilindro(0.004, 0.004, 0.16, Vector3(0.28, 0.2, 0.42), "cuoio", Vector3(0, 0, 0), 4))
	r.add_child(sfera(0.012, Vector3(0.28, 0.12, 0.425), "cuoio", Vector3(1.4, 0.8, 0.6)))
	r.add_child(cesta(Vector3(0.3, 0, 0.62), "carbone", 0.8))
	for k in 5:
		r.add_child(sfera(0.012, Vector3(0.28 + (k % 3) * 0.018, 0.068 + (k / 3) * 0.008, 0.62 + (k % 2) * 0.015), "pietra"))
	return r


## Zecca dei Brettii: casa di pietra grezza con il portico di pali intagliati, tetto di scandole e sassi,
## casse di monete, incudine per coniare e un fromboliere di guardia.
static func zecca_brettii() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.25)
	r.add_child(c)
	var lx := 0.74
	var lz := 0.56
	var h := 0.44
	_muri_pietra_b(c, lx, lz, h, 241)
	_porta_b(c, Vector3(0.0, 0, lz * 0.5), 0.0, 0.15, 0.26)
	_finestrella_b(c, Vector3(lx * 0.5 + 0.004, 0.3, 0.0), 90.0)
	# portico: due pali intagliati davanti alla porta con l'architrave e lo stendardo
	for x: float in [-0.25, 0.25]:
		_totem(c, Vector3(x, 0, lz * 0.5 + 0.1), h + 0.02, 1 + int(x > 0))
	c.add_child(cilindro(0.028, 0.028, lx + 0.06, Vector3(0, h + 0.04, lz * 0.5 + 0.1), "legno_vecchio", Vector3(0, 0, 90), 7))
	_tettoia_paglia(c, Vector3(0, 0, lz * 0.5 + 0.06), 0.6, 0.12, h + 0.04, h - 0.02, false)
	sottotetto(c, lx, lz, h, 30.0, "legno_vecchio")
	_tetto_scandole_sassi(c, lx + 0.06, lz, h, 30.0, 241)
	c.add_child(cilindro(0.04, 0.05, 0.16, Vector3(0.24, h + 0.18, -0.12), "pietra_grezza", Vector3.ZERO, 8))
	# casse di monete, incudine per coniare, argento grezzo
	for k in 3:
		r.add_child(cassa(Vector3(0.45 + k * 0.12, 0, 0.4), k * 15, 0.1))
		r.add_child(cilindro(0.035, 0.035, 0.01, Vector3(0.45 + k * 0.12, 0.085, 0.4), "moneta", Vector3.ZERO, 10))
	r.add_child(cilindro(0.04, 0.05, 0.08, Vector3(-0.35, 0.04, 0.5), "corteccia", Vector3.ZERO, 10))
	r.add_child(scatola(Vector3(0.1, 0.035, 0.05), Vector3(-0.35, 0.095, 0.5), "ferro"))
	r.add_child(mucchio(Vector3(-0.62, 0, 0.25), "argento_grezzo", 8, 10))
	r.add_child(_vaso_pece(Vector3(-0.6, 0, 0.5), 0.9))
	var g := brettio()
	g.position = Vector3(0.15, 0, 0.55)
	g.scale = Vector3.ONE * 0.9
	r.add_child(g)
	_stendardo_b(r, Vector3(-0.66, 0, -0.02), 0.6)
	return r


## Porto dei Brettii: banchina di grossi sassi, pontile di tronchi su pali, magazzino di tronchi con la paglia e la tettoia,
## vasi di pece e tronchi di pino pronti per le navi, gru a capra di pali e un'ancora di pietra.
static func porto_brettii() -> Node3D:
	var r := Node3D.new()
	var rng := _rng(2901)
	# banchina di pietra grezza lungo il mare (+x)
	r.add_child(scatola(Vector3(0.42, 0.1, 1.08), Vector3(0.36, 0.05, 0.02), "pietra_grezza"))
	r.add_child(scatola(Vector3(0.46, 0.025, 1.12), Vector3(0.36, 0.112, 0.02), "roccia_massi"))
	for k in 22:
		r.add_child(sfera(rng.randf_range(0.03, 0.045), Vector3(0.575, rng.randf_range(0.02, 0.09), -0.5 + k * 0.05), "roccia_massi", Vector3(0.45, 0.8, 1.3)))
	for k in 8:
		r.add_child(sfera(rng.randf_range(0.04, 0.06), Vector3(rng.randf_range(0.18, 0.54), 0.122, rng.randf_range(-0.5, 0.54)), "pietra_grezza", Vector3(1.3, 0.15, 1.1)))
	# pontile di tronchi su pali che entra nel mare
	var pz := 0.26
	for k in 4:
		var x := 0.66 + k * 0.13
		for s: int in [-1, 1]:
			r.add_child(cilindro(0.019, 0.022, 0.26, Vector3(x, -0.01, pz + s * 0.12), "corteccia", Vector3.ZERO, 7))
			r.add_child(cilindro(0.023, 0.023, 0.012, Vector3(x, 0.01, pz + s * 0.12), "foglie_scure", Vector3.ZERO, 7))
	for s: int in [-1, 1]:
		r.add_child(cilindro(0.016, 0.016, 0.5, Vector3(0.82, 0.095, pz + s * 0.12), "legno_scuro", Vector3(0, 0, 90), 6))
	for k in 13:
		var x := 0.59 + k * 0.038
		r.add_child(cilindro(0.018, 0.018, 0.29, Vector3(x, 0.115 + rng.randf_range(-0.003, 0.003), pz), "corteccia" if k % 3 else "legno_vecchio", Vector3(90, rng.randf_range(-2, 2), 0), 6))
	# bitte: ceppi di tronco con le cime
	for z: float in [-0.42, -0.08, 0.5]:
		r.add_child(cilindro(0.026, 0.03, 0.08, Vector3(0.54, 0.165, z), "corteccia", Vector3.ZERO, 8))
		r.add_child(cilindro(0.024, 0.024, 0.004, Vector3(0.54, 0.206, z), "legno_chiaro", Vector3.ZERO, 8))
	for x: float in [0.72, 1.02]:
		for s: int in [-1, 1]:
			r.add_child(cilindro(0.014, 0.016, 0.07, Vector3(x, 0.16, pz + s * 0.13), "corteccia", Vector3.ZERO, 7))
	r.add_child(cilindro(0.032, 0.032, 0.014, Vector3(0.54, 0.18, -0.08), "corda", Vector3.ZERO, 10))
	ramo(r, Vector3(0.54, 0.178, -0.08), Vector3(0.66, 0.02, -0.02), 0.005, "corda")
	ramo(r, Vector3(1.02, 0.17, pz + 0.13), Vector3(1.1, 0.03, pz + 0.2), 0.005, "corda")
	# magazzino del porto: tronchi su zoccolo di pietra, paglia e tettoia sul davanti
	var c := Node3D.new()
	c.position = Vector3(-0.28, 0, -0.26)
	r.add_child(c)
	var lx := 0.62
	var lz := 0.4
	var h := 0.34
	_muri_tavole_b(c, lx, lz, h, 2901)
	_porta_b(c, Vector3(-0.1, 0, lz * 0.5 + 0.01), 0.0, 0.14, 0.22)
	_finestrella_b(c, Vector3(lx * 0.5 + 0.012, 0.25, 0.0), 90.0, 0.07, 0.07)
	sottotetto(c, lx, lz, h, 40.0, "legno_vecchio")
	_tetto_paglia(c, lx, lz, h, 40.0, 2901)
	_tettoia_paglia(c, Vector3(0.0, 0, lz * 0.5 + 0.13), lx, 0.22, 0.28, 0.24, false)
	_teschio(c, Vector3(lx * 0.5 + 0.03, h + 0.14, 0), 90.0, 1.4)
	# piazzale di terra battuta
	r.add_child(scatola(Vector3(0.62, 0.012, 0.5), Vector3(-0.12, 0.006, 0.32), "battuto"))
	# sotto la tettoia: vasi di pece e sacchi
	for i in 4:
		c.add_child(_vaso_pece(Vector3(0.08 + i * 0.065, 0, lz * 0.5 + 0.08), 0.85))
	c.add_child(sacco(Vector3(-0.22, 0, lz * 0.5 + 0.08), 0.3))
	# tronchi di pino della Sila accatastati, pelli e un mucchio di vasi
	catasta_tronchi(r, Vector3(-0.42, 0, 0.36), 3, 0.32)
	_pelli_stese(r, Vector3(-0.62, 0, 0.1), 90.0)
	for i in 3:
		r.add_child(_vaso_pece(Vector3(-0.06 + i * 0.1, 0.012, 0.52), 1.0))
	r.add_child(cassa(Vector3(0.06, 0.012, 0.42), 10))
	r.add_child(cassa(Vector3(0.18, 0.012, 0.44), -15))
	r.add_child(cassa(Vector3(0.11, 0.1, 0.43), 30, 0.1))
	r.add_child(cesta(Vector3(0.28, 0.125, 0.4), "pesce", 0.8))
	# gru a capra di pali con un carico di vasi di pece appeso
	var g := Node3D.new()
	g.position = Vector3(0.42, 0.125, -0.28)
	r.add_child(g)
	var cima := Vector3(0.36, 0.62, 0.0)
	for s: int in [-1, 1]:
		ramo(g, Vector3(-0.04, 0, s * 0.12), cima, 0.018, "corteccia")
	ramo(g, Vector3(-0.22, 0, 0), cima + Vector3(-0.02, -0.02, 0), 0.014, "corteccia")
	g.add_child(cilindro(0.012, 0.012, 0.26, Vector3(0.06, 0.18, 0), "legno_vecchio", Vector3(90, 0, 0), 6))
	g.add_child(cilindro(0.03, 0.03, 0.2, Vector3(0.0, 0.1, 0), "corteccia", Vector3(90, 0, 0), 10))
	g.add_child(cilindro(0.032, 0.032, 0.06, Vector3(0.0, 0.1, 0), "corda", Vector3(90, 0, 0), 10))
	g.add_child(cilindro(0.025, 0.025, 0.04, cima, "legno_vecchio", Vector3(90, 0, 0), 10))
	ramo(g, Vector3(0.0, 0.12, 0), cima, 0.004, "corda")
	ramo(g, cima, cima + Vector3(0, -0.34, 0), 0.004, "corda")
	var rete := Node3D.new()
	rete.position = cima + Vector3(0, -0.42, 0)
	g.add_child(rete)
	rete.add_child(scatola(Vector3(0.09, 0.006, 0.09), Vector3.ZERO, "legno_vecchio"))
	for k in 2:
		rete.add_child(_vaso_pece(Vector3(-0.022 + k * 0.044, 0.003, 0), 0.6))
	for s: int in [-1, 1]:
		ramo(rete, Vector3(s * 0.045, 0, 0), Vector3(0, 0.08, 0), 0.003, "corda")
	g.add_child(scatola(Vector3(0.006, 0.06, 0.09), cima + Vector3(0, 0.07, 0.05), "giocatore"))
	# vela arrotolata a strisce verdi su un pennone
	var v := Node3D.new()
	v.position = Vector3(0.3, 0.125, 0.1)
	v.rotation_degrees.y = 8
	r.add_child(v)
	v.add_child(cilindro(0.009, 0.009, 0.5, Vector3(0, 0.02, 0), "corteccia", Vector3(90, 0, 0), 6))
	for k in 7:
		v.add_child(cilindro(0.032, 0.032, 0.06, Vector3(0, 0.034, -0.18 + k * 0.06), "lana" if k % 2 == 0 else "stoffa_verde", Vector3(90, 0, 0), 10))
	for k in 4:
		v.add_child(cilindro(0.035, 0.035, 0.008, Vector3(0, 0.034, -0.15 + k * 0.1), "corda", Vector3(90, 0, 0), 10))
	# matassa di cima e ancora di pietra forata
	r.add_child(cilindro(0.04, 0.04, 0.02, Vector3(0.2, 0.135, -0.48), "corda", Vector3.ZERO, 12))
	r.add_child(cilindro(0.02, 0.02, 0.022, Vector3(0.2, 0.136, -0.48), "legno_scuro", Vector3.ZERO, 8))
	var an := Node3D.new()
	an.position = Vector3(0.88, 0.13, pz)
	an.rotation_degrees.y = 20
	r.add_child(an)
	an.add_child(sfera(0.06, Vector3(0, 0.02, 0), "pietra_grezza", Vector3(1.0, 0.45, 1.2)))
	an.add_child(cilindro(0.016, 0.016, 0.03, Vector3(0, 0.03, 0), "buio", Vector3.ZERO, 8))
	ramo(an, Vector3(0, 0.04, 0), Vector3(0.03, 0.0, 0.12), 0.004, "corda")
	_stendardo_b(r, Vector3(0.52, 0.125, 0.5), 0.5)
	return r

# =================================================================== ROMANI (step 20)
# Mattoni e intonaco ocra, tetti bassi di tegole piane e coppi con antefisse, archi in mattoni,
# basoli davanti agli ingressi, cippi miliari; colore del popolo: rosso pompeiano.

## Texture di mattoni romani: corsi regolari di mattoni sottili e lunghi, giunti di malta chiara, tinte un po' diverse.
static func _mattoni_tex(seme: int, dim := 128, scuro := Color("9a4426"), chiaro := Color("c8693c"), malta := Color("d2c09c")) -> ImageTexture:
	var rng := RandomNumberGenerator.new()
	rng.seed = seme
	var img := Image.create(dim, dim, false, Image.FORMAT_RGBA8)
	img.fill(malta)
	var n := FastNoiseLite.new()
	n.seed = seme
	n.frequency = 0.2
	var fila := 0
	for y in range(0, dim, 8):
		var x := -(fila % 2) * 14
		while x < dim:
			var w := 28
			var base := scuro.lerp(chiaro, rng.randf())
			for yy in range(y + 1, mini(y + 7, dim)):
				for xx in range(maxi(x + 1, 0), mini(x + w - 1, dim)):
					var v := n.get_noise_2d(xx, yy) * 0.08
					var bordo := 1.0 - 0.15 * float(yy == y + 1)
					img.set_pixel(xx, yy, Color(base.r + v, base.g + v, base.b + v) * bordo)
			x += w
		fila += 1
	img.generate_mipmaps()
	return ImageTexture.create_from_image(img)


## Muri romani: zoccolo e cantonali di mattoni, intonaco ocra con la fascia dipinta di rosso pompeiano in basso,
## chiazze dove l'intonaco è caduto e si vedono i mattoni, cornice di mattoni con dentelli sotto la gronda.
## Con mat = "mattoni" il muro resta a mattoni vivi (botteghe e magazzini).
static func _muri_r(r: Node3D, lx: float, lz: float, h: float, seme: int, mat := "intonaco_ocra", dipinto := true) -> void:
	var rng := _rng(seme)
	r.add_child(scatola(Vector3(lx + 0.06, 0.07, lz + 0.06), Vector3(0, 0.035, 0), "mattoni"))
	r.add_child(scatola(Vector3(lx + 0.07, 0.014, lz + 0.07), Vector3(0, 0.074, 0), "blocco"))
	r.add_child(scatola(Vector3(lx, h, lz), Vector3(0, 0.07 + h * 0.5, 0), mat))
	var intonacato := mat != "mattoni"
	var hd := minf(0.11, h * 0.28)
	if intonacato and dipinto:
		r.add_child(scatola(Vector3(lx + 0.008, hd, lz + 0.008), Vector3(0, 0.081 + hd * 0.5, 0), "rosso_pompeiano"))
		r.add_child(scatola(Vector3(lx + 0.012, 0.012, lz + 0.012), Vector3(0, 0.081 + hd, 0), "fuliggine"))
	if intonacato:
		# intonaco caduto: si vedono i mattoni
		for k in 3:
			var w := rng.randf_range(0.08, 0.15)
			var hh := rng.randf_range(0.05, 0.09)
			var y := rng.randf_range(0.07 + hd + 0.06, 0.07 + h - 0.06)
			if k < 2:
				r.add_child(scatola(Vector3(w, hh, 0.01), Vector3(rng.randf_range(-lx * 0.38, lx * 0.38), y, lz * 0.5 + 0.002), "mattoni"))
			else:
				r.add_child(scatola(Vector3(0.01, hh, w), Vector3(lx * 0.5 + 0.002, y, rng.randf_range(-lz * 0.38, lz * 0.38)), "mattoni"))
		# cantonali a dente di mattoni sugli spigoli in vista
		var y := 0.1
		var k := 0
		while y < 0.07 + h - 0.02:
			var lungo := 0.08 if k % 2 == 0 else 0.05
			r.add_child(scatola(Vector3(0.03, 0.03, lungo), Vector3(lx * 0.5 + 0.004, y, lz * 0.5 - lungo * 0.5 + 0.006), "mattoni"))
			r.add_child(scatola(Vector3(lungo, 0.03, 0.03), Vector3(lx * 0.5 - lungo * 0.5 + 0.006, y, lz * 0.5 + 0.004), "mattoni"))
			r.add_child(scatola(Vector3(lungo, 0.03, 0.03), Vector3(-lx * 0.5 + lungo * 0.5 - 0.006, y, lz * 0.5 + 0.004), "mattoni"))
			r.add_child(scatola(Vector3(0.03, 0.03, lungo), Vector3(lx * 0.5 + 0.004, y, -lz * 0.5 + lungo * 0.5 - 0.006), "mattoni"))
			y += 0.034
			k += 1
	else:
		# ricorsi di travertino nel muro di mattoni
		for y in [0.07 + h * 0.4, 0.07 + h * 0.75]:
			r.add_child(scatola(Vector3(lx + 0.01, 0.018, lz + 0.01), Vector3(0, y, 0), "blocco"))
	# cornice di mattoni con dentelli sotto la gronda
	r.add_child(scatola(Vector3(lx + 0.04, 0.028, lz + 0.04), Vector3(0, 0.07 + h - 0.014, 0), "mattoni"))
	var nd := int(lx / 0.055)
	for i in nd:
		r.add_child(scatola(Vector3(0.022, 0.018, 0.02), Vector3(-lx * 0.5 + (i + 0.5) * lx / nd, 0.07 + h - 0.037, lz * 0.5 + 0.008), "laterizio"))
	var ndz := int(lz / 0.055)
	for i in ndz:
		r.add_child(scatola(Vector3(0.02, 0.018, 0.022), Vector3(lx * 0.5 + 0.008, 0.07 + h - 0.037, -lz * 0.5 + (i + 0.5) * lz / ndz), "laterizio"))


## Tetto romano a due falde basse (colmo lungo X): tegole piane a gradini, coppi sulle giunture,
## colmo di coppi e antefisse in fila sulla gronda in vista.
static func _tetto_r(r: Node3D, larg: float, prof: float, base_y: float, pendenza: float, seme: int) -> void:
	var rng := _rng(seme)
	var meta := prof * 0.5 + 0.07
	var ang := deg_to_rad(pendenza)
	var lung := meta / cos(ang)
	var alt := meta * tan(ang)
	var nc := maxi(2, int((larg + 0.12) / 0.095))
	var passo := (larg + 0.12) / nc
	var nr := maxi(2, int(lung / 0.09))
	for lato: int in [-1, 1]:
		var falda := Node3D.new()
		falda.position = Vector3(0, base_y + alt * 0.5, lato * meta * 0.5)
		falda.rotation.x = lato * ang
		r.add_child(falda)
		falda.add_child(scatola(Vector3(larg + 0.14, 0.024, lung), Vector3.ZERO, "laterizio_scuro"))
		for k in nc:
			var x := -larg * 0.5 - 0.06 + (k + 0.5) * passo
			for j in nr:
				var z := lato * (-lung * 0.5 + (j + 0.5) * lung / nr)
				var t := scatola(Vector3(passo * 0.86, 0.012, lung / nr * 1.02), Vector3(x, 0.016, z), "laterizio" if rng.randf() < 0.7 else "tegola_c")
				t.rotation_degrees.x = -lato * 4.0
				falda.add_child(t)
		for k in nc + 1:
			var x := -larg * 0.5 - 0.06 + k * passo
			var coppo := cilindro(0.02, 0.018, lung, Vector3(x, 0.026, 0), "laterizio" if k % 2 == 0 else "tegola_b", Vector3(90, 0, 0), 8)
			coppo.scale = Vector3(1, 1, 0.6)
			falda.add_child(coppo)
	r.add_child(cilindro(0.038, 0.038, larg + 0.18, Vector3(0, base_y + alt + 0.02, 0), "laterizio", Vector3(0, 0, 90), 10))
	# antefisse sulla gronda in vista
	for k in nc + 1:
		var x := -larg * 0.5 - 0.06 + k * passo
		r.add_child(scatola(Vector3(0.03, 0.035, 0.008), Vector3(x, base_y + 0.03, meta + 0.004), "terracotta"))
		r.add_child(sfera(0.012, Vector3(x, base_y + 0.05, meta + 0.004), "terracotta", Vector3(1.2, 1, 0.5)))


static func _comignolo_r(r: Node3D, pos: Vector3, h := 0.16) -> void:
	r.add_child(scatola(Vector3(0.075, h, 0.075), pos + Vector3(0, h * 0.5, 0), "mattoni"))
	r.add_child(scatola(Vector3(0.08, 0.03, 0.08), pos + Vector3(0, h - 0.012, 0), "fuliggine"))
	r.add_child(scatola(Vector3(0.1, 0.018, 0.1), pos + Vector3(0, h + 0.01, 0), "laterizio"))


## Porta ad arco su una facciata +Z: stipiti e ghiera di mattoni, battente di legno borchiato, lunetta con grata, soglia.
static func _porta_r(r: Node3D, x: float, zf: float, w := 0.13, h := 0.2) -> void:
	var y0 := 0.07
	r.add_child(cilindro(w * 0.5, w * 0.5, 0.012, Vector3(x, y0 + h, zf + 0.002), "buio", Vector3(90, 0, 0), 14))
	for k in 3:
		r.add_child(scatola(Vector3(0.005, w * 0.45, 0.006), Vector3(x - w * 0.25 + k * w * 0.25, y0 + h + w * 0.2, zf + 0.009), "ferro"))
	r.add_child(scatola(Vector3(w, h, 0.02), Vector3(x, y0 + h * 0.5, zf + 0.006), "legno_scuro"))
	r.add_child(scatola(Vector3(0.006, h, 0.008), Vector3(x, y0 + h * 0.5, zf + 0.017), "legno_vecchio"))
	for i in 2:
		for j in 3:
			r.add_child(sfera(0.007, Vector3(x + (i - 0.5) * w * 0.5, y0 + 0.05 + j * h * 0.32, zf + 0.018), "ferro"))
	for lato: int in [-1, 1]:
		r.add_child(scatola(Vector3(0.03, h, 0.03), Vector3(x + lato * (w * 0.5 + 0.015), y0 + h * 0.5, zf + 0.01), "mattoni"))
	var rg := w * 0.5 + 0.015
	for k in 7:
		var a := (k + 0.5) * PI / 7
		r.add_child(scatola(Vector3(0.03, PI * rg / 7 * 1.1, 0.032), Vector3(x + cos(a) * rg, y0 + h + sin(a) * rg, zf + 0.01), "mattoni" if k % 2 == 0 else "laterizio", Vector3(0, 0, rad_to_deg(a))))
	r.add_child(scatola(Vector3(w + 0.09, 0.03, 0.08), Vector3(x, 0.015, zf + 0.04), "blocco"))


## Finestrella ad arco con ghiera di mattoni, grata e davanzale di travertino; pos è il centro sulla facciata,
## rot_y = 0 per la facciata +Z, 90 per la facciata +X.
static func _finestra_r(r: Node3D, pos: Vector3, rot_y: float, w := 0.07, h := 0.08) -> void:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot_y
	r.add_child(n)
	n.add_child(scatola(Vector3(w, h, 0.014), Vector3(0, 0, 0.003), "buio"))
	n.add_child(cilindro(w * 0.5, w * 0.5, 0.014, Vector3(0, h * 0.5, 0.003), "buio", Vector3(90, 0, 0), 12))
	var rg := w * 0.5 + 0.011
	for k in 5:
		var a := (k + 0.5) * PI / 5
		n.add_child(scatola(Vector3(0.022, PI * rg / 5 * 1.1, 0.022), Vector3(cos(a) * rg, h * 0.5 + sin(a) * rg, 0.006), "mattoni" if k % 2 == 0 else "laterizio", Vector3(0, 0, rad_to_deg(a))))
	n.add_child(scatola(Vector3(w + 0.04, 0.016, 0.04), Vector3(0, -h * 0.5 - 0.008, 0.014), "blocco"))
	for k in 2:
		n.add_child(scatola(Vector3(0.005, h + w * 0.4, 0.005), Vector3((k - 0.5) * w * 0.4, w * 0.2, 0.012), "ferro"))
	n.add_child(scatola(Vector3(w, 0.005, 0.005), Vector3(0, 0.0, 0.012), "ferro"))


## Selciato di basoli: lastre poligonali grigie, con i cordoli di travertino sui lati lunghi (lungo Z) se richiesto.
static func _basolato(r: Node3D, pos: Vector3, lx: float, lz: float, seme: int, cordoli := false) -> void:
	r.add_child(scatola(Vector3(lx, 0.012, lz), pos + Vector3(0, 0.006, 0), "basoli"))
	var rng := _rng(seme)
	var n := mini(140, int(lx * lz / 0.0055))
	for k in n:
		var p := pos + Vector3(rng.randf_range(-lx * 0.44, lx * 0.44), 0.013, rng.randf_range(-lz * 0.44, lz * 0.44))
		var c := cilindro(0.032, 0.036, 0.01, p, "basoli", Vector3(0, rng.randf() * 60, 0), rng.randi_range(5, 7))
		c.scale = Vector3(rng.randf_range(0.8, 1.25), 1, rng.randf_range(0.8, 1.2))
		r.add_child(c)
	if cordoli:
		for lato: int in [-1, 1]:
			r.add_child(scatola(Vector3(0.035, 0.03, lz), pos + Vector3(lato * (lx * 0.5 + 0.017), 0.015, 0), "blocco"))


## Cippo miliario: colonnina di pietra su un dado, con le righe dell'iscrizione dipinte di rosso.
static func _cippo(r: Node3D, pos: Vector3, s := 1.0) -> void:
	r.add_child(scatola(Vector3(0.075, 0.035, 0.075) * s, pos + Vector3(0, 0.0175 * s, 0), "blocco"))
	r.add_child(cilindro(0.027 * s, 0.031 * s, 0.17 * s, pos + Vector3(0, 0.12 * s, 0), "marmo", Vector3.ZERO, 12))
	r.add_child(cilindro(0.033 * s, 0.03 * s, 0.018 * s, pos + Vector3(0, 0.214 * s, 0), "blocco", Vector3.ZERO, 12))
	for k in 4:
		var w := (0.034 - (k % 2) * 0.01) * s
		r.add_child(scatola(Vector3(w, 0.006 * s, 0.006 * s), pos + Vector3(0.021, (0.18 - k * 0.022) * s, 0.021) * Vector3(s, 1, s), "rosso_pompeiano", Vector3(0, 45, 0)))


## Vessillo romano: asta con traversa, drappo rosso pompeiano frangiato d'oro e aquila in cima (drappo verso +Z).
static func _vessillo(r: Node3D, pos: Vector3, h := 0.6) -> void:
	r.add_child(cilindro(0.009, 0.009, h, pos + Vector3(0, h * 0.5, 0), "legno_scuro", Vector3.ZERO, 6))
	r.add_child(scatola(Vector3(0.19, 0.012, 0.012), pos + Vector3(0, h - 0.07, 0.012), "legno_scuro"))
	r.add_child(scatola(Vector3(0.15, 0.17, 0.006), pos + Vector3(0, h - 0.165, 0.016), "stoffa_pompeiana"))
	r.add_child(scatola(Vector3(0.152, 0.016, 0.008), pos + Vector3(0, h - 0.25, 0.016), "moneta"))
	r.add_child(cilindro(0.028, 0.028, 0.008, pos + Vector3(0, h - 0.16, 0.02), "moneta", Vector3(90, 0, 0), 12))
	r.add_child(cilindro(0.019, 0.019, 0.01, pos + Vector3(0, h - 0.16, 0.021), "stoffa_pompeiana", Vector3(90, 0, 0), 10))
	for lato: int in [-1, 1]:
		r.add_child(sfera(0.012, pos + Vector3(lato * 0.095, h - 0.085, 0.012), "moneta"))
	# aquila d'oro
	r.add_child(sfera(0.018, pos + Vector3(0, h + 0.01, 0), "moneta"))
	r.add_child(sfera(0.02, pos + Vector3(0, h + 0.04, 0), "moneta", Vector3(0.8, 1.2, 0.8)))
	for lato: int in [-1, 1]:
		r.add_child(scatola(Vector3(0.05, 0.03, 0.008), pos + Vector3(lato * 0.03, h + 0.055, 0), "moneta", Vector3(0, 0, lato * 30)))


## Scudo romano (scutum) curvo appoggiato: rosso pompeiano con umbone e bordi di bronzo.
static func _scuto(pos: Vector3, rot_y := 0.0, s := 1.0) -> Node3D:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot_y
	n.scale = Vector3.ONE * s
	n.add_child(scatola(Vector3(0.012, 0.21, 0.06), Vector3(0, 0.105, 0), "rosso_pompeiano"))
	for lato: int in [-1, 1]:
		n.add_child(scatola(Vector3(0.012, 0.21, 0.05), Vector3(0.007, 0.105, lato * 0.052), "rosso_pompeiano", Vector3(0, lato * 28, 0)))
		n.add_child(scatola(Vector3(0.006, 0.05, 0.008), Vector3(-0.004, 0.17, lato * 0.045), "moneta", Vector3(lato * 35, lato * 28, 0)))
		n.add_child(scatola(Vector3(0.006, 0.05, 0.008), Vector3(-0.004, 0.04, lato * 0.045), "moneta", Vector3(-lato * 35, lato * 28, 0)))
	for y in [0.004, 0.206]:
		n.add_child(scatola(Vector3(0.016, 0.01, 0.15), Vector3(0.003, y, 0), "bronzo"))
	n.add_child(sfera(0.024, Vector3(-0.007, 0.105, 0), "bronzo", Vector3(0.6, 1, 1)))
	return n


## Dolio: grande giara di terracotta interrata a metà, con il coperchio.
static func _dolio(r: Node3D, pos: Vector3, s := 1.0) -> void:
	r.add_child(sfera(0.075 * s, pos + Vector3(0, 0.03 * s, 0), "terracotta", Vector3(1, 0.9, 1)))
	r.add_child(cilindro(0.04 * s, 0.045 * s, 0.025 * s, pos + Vector3(0, 0.1 * s, 0), "terracotta", Vector3.ZERO, 12))
	r.add_child(cilindro(0.048 * s, 0.048 * s, 0.012 * s, pos + Vector3(0, 0.116 * s, 0), "laterizio_scuro", Vector3.ZERO, 12))


## Orto romano: aiuole in file chiuse da un muretto di mattoni sui lati in vista.
static func _orto_r(r: Node3D, pos: Vector3, lx: float, lz: float, seme: int) -> void:
	var rng := _rng(seme)
	r.add_child(scatola(Vector3(lx, 0.012, lz), pos + Vector3(0, 0.006, 0), "terra"))
	var file := int(lz / 0.07)
	for f in file:
		var z := pos.z - lz * 0.5 + (f + 0.5) * lz / file
		var piante := int(lx / 0.06)
		for k in piante:
			var x := pos.x - lx * 0.5 + (k + 0.5) * lx / piante
			r.add_child(sfera(rng.randf_range(0.018, 0.026), Vector3(x, 0.025, z), "orto" if f % 3 != 2 else "foglie_chiare", Vector3(1, 0.8, 1)))
	r.add_child(scatola(Vector3(lx + 0.06, 0.06, 0.03), pos + Vector3(0, 0.03, lz * 0.5 + 0.015), "mattoni"))
	r.add_child(scatola(Vector3(lx + 0.07, 0.014, 0.04), pos + Vector3(0, 0.067, lz * 0.5 + 0.015), "laterizio"))
	r.add_child(scatola(Vector3(0.03, 0.06, lz), pos + Vector3(lx * 0.5 + 0.015, 0.03, 0), "mattoni"))
	r.add_child(scatola(Vector3(0.04, 0.014, lz + 0.01), pos + Vector3(lx * 0.5 + 0.015, 0.067, 0), "laterizio"))


## Pila di tegole piane con i bordi rialzati (pos = base della pila).
static func _pila_tegole(r: Node3D, pos: Vector3, strati := 5, rot := 0.0, mat := "laterizio") -> void:
	for k in strati:
		var t := Node3D.new()
		t.position = pos + Vector3(0, 0.007 + k * 0.016, 0)
		t.rotation_degrees.y = rot + (k % 2) * 4
		r.add_child(t)
		t.add_child(scatola(Vector3(0.11, 0.01, 0.14), Vector3.ZERO, mat))
		for lato: int in [-1, 1]:
			t.add_child(scatola(Vector3(0.012, 0.014, 0.14), Vector3(lato * 0.05, 0.007, 0), mat if mat != "laterizio" else "laterizio_scuro"))


# ------------------------------------------------------------------ edifici dei Romani

## Domus piccola: intonaco ocra con la fascia rossa, porta ad arco, tetto basso di tegole, orto murato e basoli.
static func casa_greca_romani(seme := 1) -> Node3D:
	var r := Node3D.new()
	var corpo := Node3D.new()
	corpo.position = Vector3(-0.12, 0, -0.15)
	r.add_child(corpo)
	var lx := 0.92
	var lz := 0.7
	var h := 0.46
	_muri_r(corpo, lx, lz, h, seme + 600)
	_porta_r(corpo, -0.18, lz * 0.5, 0.13, 0.22)
	_finestra_r(corpo, Vector3(0.2, 0.4, lz * 0.5), 0.0)
	_finestra_r(corpo, Vector3(lx * 0.5, 0.4, 0.14), 90.0)
	_finestra_r(corpo, Vector3(lx * 0.5, 0.4, -0.16), 90.0)
	sottotetto(corpo, lx, lz, 0.07 + h, 18.0, "intonaco_ocra")
	_tetto_r(corpo, lx + 0.06, lz, 0.07 + h, 18.0, seme + 600)
	_comignolo_r(corpo, Vector3(-0.25, 0.07 + h + 0.04, -0.12))
	# basoli davanti alla porta, panca di pietra, giare e alloro in vaso
	_basolato(corpo, Vector3(-0.18, 0, lz * 0.5 + 0.2), 0.36, 0.3, seme + 601)
	corpo.add_child(scatola(Vector3(0.2, 0.025, 0.06), Vector3(0.12, 0.06, lz * 0.5 + 0.06), "blocco"))
	for lato: int in [-1, 1]:
		corpo.add_child(scatola(Vector3(0.03, 0.05, 0.05), Vector3(0.12 + lato * 0.08, 0.025, lz * 0.5 + 0.06), "mattoni"))
	corpo.add_child(anfora(Vector3(0.3, 0.0, lz * 0.5 + 0.1), 1.1))
	corpo.add_child(anfora(Vector3(0.36, 0.0, lz * 0.5 + 0.16), 1.0))
	corpo.add_child(vaso_fiori(Vector3(-0.38, 0.0, lz * 0.5 + 0.08)))
	_cipresso(r, Vector3(-0.66, 0, 0.28), 0.5)
	_cippo(r, Vector3(-0.58, 0, 0.6), 1.0)
	# orto murato e legnaia
	_orto_r(r, Vector3(0.56, 0, 0.42), 0.36, 0.42, seme + 3)
	legnaia(corpo, Vector3(lx * 0.5 + 0.06, 0.0, -0.2), 0.24, 3)
	_dolio(r, Vector3(-0.2, 0.0, 0.66))
	return r


## Horreum: grande magazzino di mattoni vivi con lesene, portale ad arco di travertino, finestrelle alte,
## banchina di basoli con merci, carro e vessillo.
static func magazzino_romani() -> Node3D:
	var r := Node3D.new()
	var lx := 1.75
	var lz := 1.3
	var h := 0.68
	r.position = Vector3(0, 0, -0.1)
	var c := Node3D.new()
	c.position = Vector3(0, 0, -0.12)
	r.add_child(c)
	var cz := lz - 0.16
	_muri_r(c, lx - 0.1, cz, h, 707, "mattoni")
	# lesene di mattoni con capitelli di travertino
	for k in 7:
		var x := -(lx - 0.1) * 0.5 + 0.04 + k * (lx - 0.18) / 6
		c.add_child(scatola(Vector3(0.06, h - 0.03, 0.03), Vector3(x, 0.07 + (h - 0.03) * 0.5, cz * 0.5 + 0.012), "laterizio"))
		c.add_child(scatola(Vector3(0.075, 0.025, 0.04), Vector3(x, 0.07 + h - 0.045, cz * 0.5 + 0.016), "blocco"))
	for k in 5:
		var z := -cz * 0.5 + 0.04 + k * (cz - 0.08) / 4
		c.add_child(scatola(Vector3(0.03, h - 0.03, 0.06), Vector3((lx - 0.1) * 0.5 + 0.012, 0.07 + (h - 0.03) * 0.5, z), "laterizio"))
	# portale ad arco di travertino con frontoncino
	var pz := cz * 0.5 + 0.02
	_arco(c, Vector3(0, 0.07, pz), 0.28, 0.3, 0.06, "blocco", 0.0, "intonaco_bianco")
	c.add_child(scatola(Vector3(0.28, 0.3, 0.02), Vector3(0, 0.07 + 0.15, pz - 0.02), "legno_scuro"))
	c.add_child(cilindro(0.14, 0.14, 0.02, Vector3(0, 0.37, pz - 0.02), "buio", Vector3(90, 0, 0), 16))
	c.add_child(scatola(Vector3(0.006, 0.3, 0.01), Vector3(0, 0.22, pz - 0.008), "legno_vecchio"))
	for i in 4:
		for j in 4:
			c.add_child(sfera(0.008, Vector3(-0.1 + i * 0.065, 0.1 + j * 0.07, pz - 0.006), "ferro"))
	c.add_child(scatola(Vector3(0.36, 0.07, 0.012), Vector3(0, 0.62, cz * 0.5 + 0.03), "marmo"))
	for k in 2:
		c.add_child(scatola(Vector3(0.26 - k * 0.08, 0.01, 0.006), Vector3(0, 0.635 - k * 0.025, cz * 0.5 + 0.038), "rosso_pompeiano"))
	# finestrelle alte
	for fx in [-0.62, -0.38, 0.38, 0.62]:
		_finestra_r(c, Vector3(fx, 0.5, cz * 0.5 + 0.004), 0.0, 0.06, 0.08)
	for fz in [-0.3, 0.0, 0.3]:
		_finestra_r(c, Vector3((lx - 0.1) * 0.5 + 0.004, 0.5, fz), 90.0, 0.06, 0.08)
	sottotetto(c, lx - 0.1, cz, 0.07 + h, 15.0, "mattoni")
	_tetto_r(c, lx - 0.04, cz, 0.07 + h, 15.0, 707)
	# banchina di basoli e merci
	_basolato(r, Vector3(0, 0, lz * 0.5 + 0.3), lx + 0.1, 0.42, 708, true)
	for i in 4:
		r.add_child(anfora(Vector3(-0.78 + (i % 2) * 0.09, 0.012, lz * 0.5 + 0.2 + (i / 2) * 0.1), 1.2))
	for i in 3:
		r.add_child(cassa(Vector3(0.45 + i * 0.13, 0.012, lz * 0.5 + 0.24), i * 12))
	r.add_child(cassa(Vector3(0.52, 0.012 + 0.088, lz * 0.5 + 0.24), 25, 0.09))
	for i in 3:
		r.add_child(sacco(Vector3(-0.42 + i * 0.1, 0.012, lz * 0.5 + 0.22), i * 0.5))
	_dolio(r, Vector3(0.92, 0.0, 0.3), 1.1)
	_dolio(r, Vector3(0.95, 0.0, 0.46), 1.0)
	carretto(r, Vector3(-0.2, 0.012, lz * 0.5 + 0.55), 20, "sacchi")
	_vessillo(r, Vector3(lx * 0.5 + 0.12, 0, lz * 0.5 + 0.12), 0.75)
	_cippo(r, Vector3(-lx * 0.5 - 0.02, 0, lz * 0.5 + 0.62))
	return r


## Boscaiolo romano: casetta ocra con tetto di tegole, tettoia a una falda su pilastri di mattoni con la legna spaccata.
static func boscaiolo_romani() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.15, 0, -0.18)
	r.add_child(c)
	var lx := 0.8
	var lz := 0.62
	var h := 0.36
	_muri_r(c, lx, lz, h, 611)
	_porta_r(c, -0.15, lz * 0.5, 0.12, 0.2)
	_finestra_r(c, Vector3(0.18, 0.32, lz * 0.5), 0.0)
	sottotetto(c, lx, lz, 0.07 + h, 20.0, "intonaco_ocra")
	_tetto_r(c, lx + 0.06, lz, 0.07 + h, 20.0, 611)
	_comignolo_r(c, Vector3(0.2, 0.07 + h + 0.04, -0.1), 0.14)
	# tettoia con legna spaccata
	for pz in [-0.25, 0.25]:
		c.add_child(scatola(Vector3(0.04, 0.27, 0.04), Vector3(lx * 0.5 + 0.3, 0.135, pz), "mattoni"))
		c.add_child(scatola(Vector3(0.05, 0.02, 0.05), Vector3(lx * 0.5 + 0.3, 0.275, pz), "blocco"))
	_falda(c, 0.62, 0.28, 0.27, 22.0, Vector3(lx * 0.5 + 0.17, 0, 0), 90.0, 612)
	legnaia(c, Vector3(lx * 0.5 + 0.17, 0.0, 0.0), 0.5, 5)
	# catasta di tronchi, ceppo con l'ascia, ceppaie, basoli davanti alla porta
	_basolato(c, Vector3(-0.15, 0, lz * 0.5 + 0.14), 0.26, 0.2, 613)
	catasta_tronchi(r, Vector3(0.55, 0, 0.55), 4, 0.5)
	r.add_child(cilindro(0.07, 0.075, 0.09, Vector3(-0.2, 0.045, 0.5), "corteccia", Vector3.ZERO, 12))
	r.add_child(cilindro(0.066, 0.066, 0.006, Vector3(-0.2, 0.092, 0.5), "legno_chiaro", Vector3.ZERO, 12))
	r.add_child(cilindro(0.008, 0.008, 0.22, Vector3(-0.2, 0.18, 0.5), "legno", Vector3(0, 0, 22), 6))
	r.add_child(scatola(Vector3(0.055, 0.04, 0.012), Vector3(-0.245, 0.27, 0.5), "ferro", Vector3(0, 0, 22)))
	for i in 6:
		r.add_child(cilindro(0.02, 0.02, 0.06, Vector3(-0.38 + i * 0.06, 0.02, 0.62 + (i % 2) * 0.05), "legno_chiaro", Vector3(0, i * 37, 90), 6))
	for pos in [Vector3(-0.72, 0, 0.3), Vector3(-0.6, 0, 0.75)]:
		r.add_child(cilindro(0.06, 0.07, 0.05, pos + Vector3(0, 0.025, 0), "corteccia", Vector3.ZERO, 10))
		r.add_child(cilindro(0.056, 0.056, 0.005, pos + Vector3(0, 0.052, 0), "legno_chiaro", Vector3.ZERO, 10))
	_vessillo(r, Vector3(-0.68, 0, -0.1), 0.5)
	return r


## Segheria romana: bottega di mattoni vivi, tettoia a due falde di tegole su pilastri con la grande sega a telaio.
static func segheria_romani() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.25)
	r.add_child(c)
	var lx := 0.85
	var lz := 0.62
	var h := 0.44
	_muri_r(c, lx, lz, h, 621, "mattoni")
	_porta_r(c, -0.22, lz * 0.5, 0.15, 0.24)
	_finestra_r(c, Vector3(0.15, 0.4, lz * 0.5), 0.0)
	_finestra_r(c, Vector3(lx * 0.5, 0.4, 0.05), 90.0)
	sottotetto(c, lx, lz, 0.07 + h, 18.0, "mattoni")
	_tetto_r(c, lx + 0.06, lz, 0.07 + h, 18.0, 621)
	# tettoia aperta con la sega a telaio
	var t := Node3D.new()
	t.position = Vector3(0.05, 0, 0.5)
	r.add_child(t)
	for p in [Vector3(-0.42, 0, -0.18), Vector3(0.42, 0, -0.18), Vector3(-0.42, 0, 0.2), Vector3(0.42, 0, 0.2)]:
		t.add_child(scatola(Vector3(0.045, 0.36, 0.045), p + Vector3(0, 0.18, 0), "mattoni"))
		t.add_child(scatola(Vector3(0.055, 0.02, 0.055), p + Vector3(0, 0.36, 0), "blocco"))
	for z in [-0.18, 0.2]:
		t.add_child(scatola(Vector3(0.9, 0.03, 0.035), Vector3(0, 0.385, z), "legno_vecchio"))
	_tetto_r(t, 0.86, 0.36, 0.4, 15.0, 622)
	for px in [-0.25, 0.0, 0.25]:
		t.add_child(scatola(Vector3(0.03, 0.12, 0.12), Vector3(px, 0.06, 0.0), "legno"))
	t.add_child(cilindro(0.055, 0.055, 0.8, Vector3(0, 0.17, 0.0), "corteccia", Vector3(0, 0, 90), 9))
	t.add_child(cilindro(0.047, 0.047, 0.805, Vector3(0, 0.17, 0.0), "legno_chiaro", Vector3(0, 0, 90), 9))
	for z in [-0.08, 0.08]:
		t.add_child(scatola(Vector3(0.014, 0.3, 0.014), Vector3(0.1, 0.24, z), "legno"))
	t.add_child(scatola(Vector3(0.014, 0.014, 0.18), Vector3(0.1, 0.38, 0.0), "legno"))
	t.add_child(scatola(Vector3(0.006, 0.006, 0.17), Vector3(0.1, 0.2, 0.0), "ferro"))
	t.add_child(cilindro(0.2, 0.2, 0.004, Vector3(0.1, 0.002, 0.0), "legno_chiaro", Vector3.ZERO, 16))
	# pile di assi, tronchi, carro
	pila_assi(r, Vector3(0.62, 0, -0.25), 8, 90)
	pila_assi(r, Vector3(0.62, 0, 0.12), 5, 90)
	catasta_tronchi(r, Vector3(-0.65, 0, 0.55), 3, 0.42)
	carretto(r, Vector3(0.35, 0, 0.85), -30, "tronchi")
	_vessillo(r, Vector3(-0.72, 0, 0.1), 0.5)
	return r


## Cava romana: casotto di mattoni, parete di roccia, blocchi squadrati e la gru a capra con la ruota e il paranco.
static func cava_romani() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.35, 0, -0.3)
	r.add_child(c)
	_muri_r(c, 0.55, 0.48, 0.3, 631, "mattoni")
	_porta_r(c, -0.08, 0.24, 0.11, 0.18)
	sottotetto(c, 0.55, 0.48, 0.37, 20.0, "mattoni")
	_tetto_r(c, 0.6, 0.48, 0.37, 20.0, 631)
	var rng := _rng(17)
	for k in 9:
		var p := Vector3(0.35 + rng.randf_range(-0.2, 0.2), 0.0, -0.4 + rng.randf_range(-0.15, 0.2))
		var d := rng.randf_range(0.16, 0.3)
		r.add_child(scatola(Vector3(d, d * rng.randf_range(0.6, 1.4), d * 0.8), p + Vector3(0, d * 0.4, 0), "roccia_massi", Vector3(0, rng.randf() * 60, 0)))
	# blocchi squadrati pronti
	for i in 4:
		for j in 2 - (i / 3):
			r.add_child(scatola(Vector3(0.13, 0.09, 0.09), Vector3(-0.1 + i * 0.15, 0.045 + j * 0.09, 0.45), "blocco", Vector3(0, i * 5 - 6, 0)))
	# gru a capra: due travi a V rovesciata, puntone, carrucola e ruota del verricello
	var g := Vector3(0.18, 0, 0.08)
	for lato: int in [-1, 1]:
		r.add_child(scatola(Vector3(0.022, 0.62, 0.022), g + Vector3(-0.06, 0.3, lato * 0.11), "legno", Vector3(lato * 10, 0, 12)))
	r.add_child(scatola(Vector3(0.018, 0.55, 0.018), g + Vector3(0.12, 0.26, 0), "legno_vecchio", Vector3(0, 0, -22)))
	r.add_child(cilindro(0.025, 0.025, 0.03, g + Vector3(-0.12, 0.6, 0), "legno_scuro", Vector3(90, 0, 0), 10))
	r.add_child(cilindro(0.004, 0.004, 0.42, g + Vector3(-0.14, 0.38, 0), "corda", Vector3.ZERO, 4))
	r.add_child(scatola(Vector3(0.12, 0.08, 0.08), g + Vector3(-0.14, 0.16, 0), "blocco"))
	r.add_child(cilindro(0.11, 0.11, 0.025, g + Vector3(0.05, 0.12, 0.17), "legno", Vector3(90, 0, 0), 14))
	r.add_child(cilindro(0.09, 0.09, 0.027, g + Vector3(0.05, 0.12, 0.17), "legno_scuro", Vector3(90, 0, 0), 14))
	r.add_child(cilindro(0.015, 0.015, 0.2, g + Vector3(0.05, 0.12, 0.1), "legno_vecchio", Vector3(90, 0, 0), 6))
	r.add_child(cilindro(0.008, 0.008, 0.22, Vector3(0.55, 0.11, 0.35), "legno", Vector3(0, 0, -25), 6))
	r.add_child(scatola(Vector3(0.11, 0.014, 0.014), Vector3(0.6, 0.21, 0.35), "ferro", Vector3(0, 0, -25)))
	_basolato(r, Vector3(-0.45, 0, 0.6), 0.36, 0.26, 632)
	carretto(r, Vector3(-0.45, 0.012, 0.6), 15)
	r.add_child(scatola(Vector3(0.1, 0.07, 0.07), Vector3(-0.45, 0.172, 0.6), "blocco"))
	_cippo(r, Vector3(-0.72, 0, 0.3))
	return r


## Guardaboschi romano: casetta ocra, vivaio di alberelli in vasi di terracotta allineati, muretto di mattoni.
static func guardaboschi_romani() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.3, 0, -0.3)
	r.add_child(c)
	_muri_r(c, 0.58, 0.48, 0.3, 641)
	_porta_r(c, 0.12, 0.24, 0.11, 0.19)
	_finestra_r(c, Vector3(-0.14, 0.3, 0.24), 0.0)
	sottotetto(c, 0.58, 0.48, 0.37, 22.0, "intonaco_ocra")
	_tetto_r(c, 0.64, 0.48, 0.37, 22.0, 641)
	for i in 4:
		for j in 3:
			var p := Vector3(-0.1 + i * 0.16, 0, 0.3 + j * 0.15)
			r.add_child(cilindro(0.04, 0.03, 0.05, p + Vector3(0, 0.025, 0), "terracotta", Vector3.ZERO, 10))
			r.add_child(cilindro(0.036, 0.036, 0.005, p + Vector3(0, 0.05, 0), "terra", Vector3.ZERO, 10))
			r.add_child(cilindro(0.006, 0.006, 0.06 + j * 0.02, p + Vector3(0, 0.07, 0), "corteccia", Vector3.ZERO, 5))
			r.add_child(cilindro(0.035 + j * 0.008, 0.0, 0.09 + j * 0.03, p + Vector3(0, 0.13 + j * 0.03, 0), "aghi", Vector3.ZERO, 7))
	r.add_child(scatola(Vector3(0.74, 0.06, 0.03), Vector3(0.16, 0.03, 0.76), "mattoni"))
	r.add_child(scatola(Vector3(0.75, 0.014, 0.04), Vector3(0.16, 0.067, 0.76), "laterizio"))
	r.add_child(scatola(Vector3(0.03, 0.06, 0.56), Vector3(0.53, 0.03, 0.48), "mattoni"))
	r.add_child(scatola(Vector3(0.04, 0.014, 0.57), Vector3(0.53, 0.067, 0.48), "laterizio"))
	r.add_child(cilindro(0.03, 0.03, 0.05, Vector3(0.35, 0.025, -0.2), "bronzo", Vector3.ZERO, 8))
	r.add_child(cilindro(0.007, 0.007, 0.22, Vector3(0.2, 0.11, -0.3), "legno", Vector3(12, 0, -15), 5))
	r.add_child(sacco(Vector3(-0.55, 0, 0.3), 0.4))
	r.add_child(sacco(Vector3(-0.6, 0, 0.42), -0.2))
	r.add_child(pino_laricio(41))
	r.get_child(r.get_child_count() - 1).position = Vector3(0.55, 0, -0.55)
	r.get_child(r.get_child_count() - 1).scale = Vector3.ONE * 0.7
	return r


## Pozzo romano: puteale di travertino, arco di mattoni con la carrucola, vasca per abbeverare e basoli intorno.
static func pozzo_romani() -> Node3D:
	var r := Node3D.new()
	_basolato(r, Vector3(0, 0, 0.04), 0.6, 0.5, 651)
	r.add_child(cilindro(0.17, 0.18, 0.16, Vector3(0, 0.09, 0), "blocco", Vector3.ZERO, 18))
	r.add_child(cilindro(0.185, 0.185, 0.025, Vector3(0, 0.025, 0), "blocco", Vector3.ZERO, 18))
	r.add_child(cilindro(0.185, 0.185, 0.025, Vector3(0, 0.17, 0), "marmo", Vector3.ZERO, 18))
	r.add_child(cilindro(0.13, 0.13, 0.005, Vector3(0, 0.181, 0), "acqua_pozzo", Vector3.ZERO, 18))
	r.add_child(cilindro(0.18, 0.18, 0.02, Vector3(0, 0.12, 0), "rosso_pompeiano", Vector3.ZERO, 18))
	_arco(r, Vector3(0, 0.012, -0.02), 0.34, 0.36, 0.07, "mattoni", 0.0, "laterizio")
	r.add_child(scatola(Vector3(0.62, 0.035, 0.09), Vector3(0, 0.62, -0.02), "blocco"))
	_tetto_r(r, 0.56, 0.06, 0.64, 22.0, 652)
	r.add_child(cilindro(0.008, 0.008, 0.06, Vector3(0, 0.52, -0.02), "ferro", Vector3.ZERO, 4))
	r.add_child(cilindro(0.03, 0.03, 0.015, Vector3(0, 0.48, -0.02), "legno_scuro", Vector3(90, 0, 0), 12))
	r.add_child(cilindro(0.004, 0.004, 0.24, Vector3(0.03, 0.35, -0.02), "corda", Vector3.ZERO, 4))
	r.add_child(cilindro(0.035, 0.03, 0.055, Vector3(0.03, 0.22, -0.02), "bronzo", Vector3.ZERO, 10))
	# vasca per abbeverare
	r.add_child(scatola(Vector3(0.12, 0.08, 0.26), Vector3(0.3, 0.04, 0.12), "blocco"))
	r.add_child(scatola(Vector3(0.09, 0.005, 0.22), Vector3(0.3, 0.081, 0.12), "acqua_pozzo"))
	r.add_child(anfora(Vector3(-0.27, 0.0, 0.2), 1.1))
	_cippo(r, Vector3(-0.28, 0, -0.12), 0.9)
	r.scale = Vector3.ONE * 1.2
	return r


## Villa rustica: casa padronale ocra con portichetto, fienile di tegole su pilastri, aia lastricata, dolii interrati.
static func fattoria_romani() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.18, 0, -0.22)
	r.add_child(c)
	var lx := 0.78
	var lz := 0.58
	var h := 0.38
	_muri_r(c, lx, lz, h, 661)
	_porta_r(c, -0.12, lz * 0.5, 0.13, 0.21)
	_finestra_r(c, Vector3(0.2, 0.33, lz * 0.5), 0.0)
	_finestra_r(c, Vector3(lx * 0.5, 0.33, 0.0), 90.0)
	sottotetto(c, lx, lz, 0.07 + h, 18.0, "intonaco_ocra")
	_tetto_r(c, lx + 0.06, lz, 0.07 + h, 18.0, 661)
	_comignolo_r(c, Vector3(0.22, 0.07 + h + 0.04, -0.08))
	# portichetto davanti alla porta: pilastri intonacati e falda di tegole
	for px in [-0.32, 0.08]:
		c.add_child(scatola(Vector3(0.04, 0.27, 0.04), Vector3(px, 0.135, lz * 0.5 + 0.17), "intonaco_ocra"))
		c.add_child(scatola(Vector3(0.042, 0.06, 0.042), Vector3(px, 0.03, lz * 0.5 + 0.17), "rosso_pompeiano"))
	_falda(c, 0.5, 0.16, 0.27, 20.0, Vector3(-0.12, 0, lz * 0.5 + 0.08), 0.0, 662)
	# fienile aperto con tetto di tegole su pilastri di mattoni
	for p in [Vector3(0.62, 0, -0.45), Vector3(0.62, 0, 0.05), Vector3(0.95, 0, -0.45), Vector3(0.95, 0, 0.05)]:
		r.add_child(scatola(Vector3(0.04, 0.34, 0.04), p + Vector3(0, 0.17, 0), "mattoni"))
	var f := Node3D.new()
	f.position = Vector3(0.785, 0, -0.2)
	f.rotation_degrees.y = 90
	r.add_child(f)
	_tetto_r(f, 0.5, 0.3, 0.34, 18.0, 663)
	for i in 5:
		var cv := covone(1.1)
		cv.position = Vector3(0.68 + (i % 3) * 0.1, 0.0, -0.35 + (i / 3) * 0.14)
		r.add_child(cv)
	# aia lastricata con covoni, carro, orto murato, dolii, galline
	_basolato(r, Vector3(-0.35, 0, 0.6), 0.6, 0.26, 664)
	for i in 4:
		var cv := covone(1.2)
		cv.position = Vector3(-0.55 + i * 0.13, 0.012, 0.55 + (i % 2) * 0.08)
		cv.rotation_degrees.z = 8 * (i % 2 * 2 - 1)
		r.add_child(cv)
	carretto(r, Vector3(0.4, 0, 0.55), -20, "sacchi")
	_orto_r(r, Vector3(-0.72, 0, -0.05), 0.24, 0.5, 665)
	for i in 3:
		_dolio(r, Vector3(0.66 + i * 0.13, 0, 0.28), 0.9)
	for i in 3:
		r.add_child(sfera(0.025, Vector3(0.05 + i * 0.07, 0.03, 0.42 - i * 0.03), "intonaco", Vector3(1.3, 1, 1)))
		r.add_child(sfera(0.008, Vector3(0.08 + i * 0.07, 0.05, 0.42 - i * 0.03), "geranio"))
	return r


## Mulino romano ad acqua: bottega di mattoni, piccolo acquedotto ad archi che porta l'acqua sulla grande ruota.
static func mulino_romani() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.25)
	r.add_child(c)
	var lx := 0.74
	var lz := 0.56
	var h := 0.46
	_muri_r(c, lx, lz, h, 671, "mattoni")
	_porta_r(c, 0.15, lz * 0.5, 0.14, 0.23)
	_finestra_r(c, Vector3(-0.17, 0.4, lz * 0.5), 0.0)
	_finestra_r(c, Vector3(lx * 0.5, 0.42, 0.12), 90.0)
	sottotetto(c, lx, lz, 0.07 + h, 18.0, "mattoni")
	_tetto_r(c, lx + 0.06, lz, 0.07 + h, 18.0, 671)
	# acquedotto ad archi lungo il fianco destro, con la ruota a cassette in fondo
	var ax := 0.42
	for k in 3:
		_arco(r, Vector3(ax, 0, -0.62 + k * 0.24), 0.16, 0.22, 0.08, "mattoni", 90.0, "laterizio")
	r.add_child(scatola(Vector3(0.1, 0.05, 0.78), Vector3(ax, 0.345, -0.38), "mattoni"))
	r.add_child(scatola(Vector3(0.06, 0.01, 0.78), Vector3(ax, 0.371, -0.38), "acqua_pozzo"))
	r.add_child(scatola(Vector3(0.05, 0.012, 0.16), Vector3(ax, 0.36, 0.08), "legno", Vector3(-8, 0, 0)))
	var ruota := Node3D.new()
	r.add_child(ruota)
	_ruota_mulino(ruota, Vector3(ax, 0.2, 0.27), 0.19)
	for k in 3:
		r.add_child(sfera(0.03 + k * 0.006, Vector3(ax, 0.34 - k * 0.06, 0.16 + k * 0.02), "acqua_pozzo", Vector3(0.8, 1.3, 0.8)))
	r.add_child(scatola(Vector3(0.2, 0.02, 0.36), Vector3(ax, 0.01, 0.3), "acqua_pozzo"))
	r.add_child(scatola(Vector3(0.24, 0.035, 0.03), Vector3(ax, 0.017, 0.49), "blocco"))
	# sacchi, covone, macina di riserva, basoli
	_basolato(r, Vector3(-0.05, 0, 0.3), 0.36, 0.26, 672)
	for i in 5:
		r.add_child(sacco(Vector3(-0.62 + (i % 3) * 0.12, 0.0, 0.42 + (i / 3) * 0.13), i * 0.7))
	var cv := covone(1.1)
	cv.position = Vector3(-0.3, 0, 0.62)
	r.add_child(cv)
	r.add_child(cilindro(0.09, 0.09, 0.04, Vector3(0.1, 0.034, 0.6), "blocco", Vector3(0, 0, 0), 14))
	r.add_child(cassa(Vector3(0.7, 0, -0.2), 15))
	_vessillo(r, Vector3(0.68, 0, 0.0), 0.5)
	return r


## Forno romano (pistrinum): bottega di mattoni, forno a cupola di laterizi con la bocca ad arco,
## bancone di mattoni col piano di marmo sotto la tenda rossa, pani tondi a spicchi.
static func forno_romani() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.25)
	r.add_child(c)
	var lx := 0.74
	var lz := 0.56
	var h := 0.4
	_muri_r(c, lx, lz, h, 681)
	_porta_r(c, -0.15, lz * 0.5, 0.13, 0.22)
	_finestra_r(c, Vector3(0.18, 0.35, lz * 0.5), 0.0)
	_finestra_r(c, Vector3(lx * 0.5, 0.35, 0.0), 90.0)
	sottotetto(c, lx, lz, 0.07 + h, 18.0, "intonaco_ocra")
	_tetto_r(c, lx + 0.06, lz, 0.07 + h, 18.0, 681)
	_comignolo_r(c, Vector3(-0.2, 0.07 + h + 0.04, -0.08))
	# forno: dado di mattoni con la cupola, bocca ad arco annerita, camino
	var f := Vector3(0.45, 0, 0.4)
	r.add_child(scatola(Vector3(0.44, 0.16, 0.42), f + Vector3(0, 0.08, 0), "mattoni"))
	r.add_child(scatola(Vector3(0.46, 0.02, 0.44), f + Vector3(0, 0.165, 0), "blocco"))
	r.add_child(sfera(0.2, f + Vector3(0, 0.17, 0), "laterizio", Vector3(1, 0.7, 1)))
	for k in 4:
		r.add_child(cilindro(0.2 - k * 0.04, 0.2 - k * 0.04, 0.01, f + Vector3(0, 0.18 + k * 0.035, 0), "mattoni", Vector3.ZERO, 18))
	_arco(r, f + Vector3(-0.02, 0.02, 0.215), 0.1, 0.07, 0.03, "mattoni", 0.0, "laterizio")
	r.add_child(scatola(Vector3(0.1, 0.12, 0.012), f + Vector3(-0.02, 0.08, 0.225), "brace"))
	r.add_child(scatola(Vector3(0.15, 0.05, 0.008), f + Vector3(-0.02, 0.2, 0.236), "fuliggine"))
	r.add_child(scatola(Vector3(0.06, 0.16, 0.06), f + Vector3(0.1, 0.36, -0.1), "mattoni"))
	_fumo(r, f + Vector3(0.1, 0.48, -0.1), 3, 0.9)
	legnaia(r, Vector3(0.62, 0, -0.1), 0.25, 3)
	# bancone sotto la tenda
	var b := Vector3(-0.3, 0, 0.55)
	r.add_child(scatola(Vector3(0.32, 0.12, 0.12), b + Vector3(0, 0.06, 0), "mattoni"))
	r.add_child(scatola(Vector3(0.34, 0.02, 0.14), b + Vector3(0, 0.13, 0), "marmo"))
	r.add_child(scatola(Vector3(0.3, 0.05, 0.004), b + Vector3(0, 0.07, 0.062), "rosso_pompeiano"))
	for lato: int in [-1, 1]:
		r.add_child(cilindro(0.008, 0.008, 0.32, b + Vector3(lato * 0.17, 0.16, 0.1), "legno", Vector3.ZERO, 5))
	r.add_child(scatola(Vector3(0.38, 0.006, 0.2), b + Vector3(0, 0.31, 0.02), "stoffa_pompeiana", Vector3(-14, 0, 0)))
	for k in 5:
		r.add_child(scatola(Vector3(0.03, 0.007, 0.2), b + Vector3(-0.16 + k * 0.08, 0.312, 0.02), "lino", Vector3(-14, 0, 0)))
	for i in 5:
		var pp := b + Vector3(-0.12 + i * 0.06, 0.155, (i % 2) * 0.03 - 0.015)
		r.add_child(sfera(0.028, pp, "pane", Vector3(1, 0.55, 1)))
		r.add_child(scatola(Vector3(0.05, 0.004, 0.004), pp + Vector3(0, 0.014, 0), "fuliggine"))
		r.add_child(scatola(Vector3(0.004, 0.004, 0.05), pp + Vector3(0, 0.014, 0), "fuliggine"))
	r.add_child(cesta(Vector3(-0.62, 0, 0.45), "pane"))
	r.add_child(cesta(Vector3(0.05, 0, 0.66), "pane"))
	r.add_child(sacco(Vector3(-0.68, 0, 0.15), 0.4))
	_dolio(r, Vector3(0.12, 0, 0.42), 0.8)
	return r


## Ovile romano: stalla di mattoni con tetto di tegole, recinto murato di mattoni con cancello, pecore, vasca di pietra.
static func ovile_romani() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.32, 0, -0.32)
	r.add_child(c)
	var lx := 0.62
	var lz := 0.48
	var h := 0.3
	_muri_r(c, lx, lz, h, 691, "mattoni")
	_porta_r(c, 0.1, lz * 0.5, 0.14, 0.19)
	sottotetto(c, lx, lz, 0.07 + h, 22.0, "mattoni")
	_tetto_r(c, lx + 0.06, lz, 0.07 + h, 22.0, 691)
	var a := Vector3(0.1, 0, 0.1)
	r.add_child(scatola(Vector3(0.62, 0.08, 0.035), a + Vector3(-0.04, 0.04, 0.45), "mattoni"))
	r.add_child(scatola(Vector3(0.63, 0.014, 0.045), a + Vector3(-0.04, 0.087, 0.45), "laterizio"))
	r.add_child(scatola(Vector3(0.035, 0.08, 0.68), a + Vector3(0.48, 0.04, 0.09), "mattoni"))
	r.add_child(scatola(Vector3(0.045, 0.014, 0.69), a + Vector3(0.48, 0.087, 0.09), "laterizio"))
	recinto(r, a + Vector3(0.28, 0, 0.45), a + Vector3(0.46, 0, 0.45), 0.08)
	for p in [[Vector3(0.0, 0, 0.25), 30], [Vector3(0.2, 0, 0.05), 160], [Vector3(0.3, 0, 0.3), -40],
			[Vector3(-0.15, 0, 0.32), 90], [Vector3(0.32, 0, -0.12), 210]]:
		r.add_child(pecora(a + p[0], p[1]))
	r.add_child(scatola(Vector3(0.22, 0.04, 0.06), a + Vector3(-0.2, 0.02, 0.05), "blocco"))
	r.add_child(scatola(Vector3(0.18, 0.005, 0.04), a + Vector3(-0.2, 0.041, 0.05), "acqua_pozzo"))
	_dolio(r, Vector3(-0.68, 0, 0.3), 0.9)
	r.add_child(sfera(0.06, Vector3(-0.55, 0.04, 0.55), "lana", Vector3(1.2, 0.6, 1.0)))
	_vessillo(r, Vector3(-0.7, 0, -0.05), 0.45)
	return r


## Capraio romano: casetta ocra, rocce con le capre, muretto di mattoni, anfora e formaggi.
static func capraio_romani() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.3, 0, -0.3)
	r.add_child(c)
	var lx := 0.56
	var lz := 0.44
	var h := 0.28
	_muri_r(c, lx, lz, h, 701)
	_porta_r(c, -0.08, lz * 0.5, 0.12, 0.18)
	_finestra_r(c, Vector3(lx * 0.5, 0.28, 0.0), 90.0)
	sottotetto(c, lx, lz, 0.07 + h, 22.0, "intonaco_ocra")
	_tetto_r(c, lx + 0.06, lz, 0.07 + h, 22.0, 701)
	var a := Vector3(0.15, 0, 0.15)
	r.add_child(sfera(0.16, a + Vector3(0.2, 0.0, -0.1), "roccia_massi", Vector3(1.2, 0.8, 1.0)))
	r.add_child(sfera(0.1, a + Vector3(-0.05, 0.0, 0.3), "roccia_massi", Vector3(1.3, 0.7, 1.0)))
	r.add_child(capra(a + Vector3(0.2, 0.1, -0.1), 40))
	r.add_child(capra(a + Vector3(0.0, 0, 0.1), 200))
	r.add_child(capra(a + Vector3(0.35, 0, 0.25), -30))
	r.add_child(capra(a + Vector3(-0.1, 0.05, 0.3), 110))
	r.add_child(scatola(Vector3(0.9, 0.07, 0.035), a + Vector3(0.05, 0.035, 0.5), "mattoni"))
	r.add_child(scatola(Vector3(0.91, 0.014, 0.045), a + Vector3(0.05, 0.077, 0.5), "laterizio"))
	r.add_child(anfora(Vector3(-0.6, 0, 0.25), 1.1))
	r.add_child(cesta(Vector3(-0.55, 0, 0.45), "formaggio"))
	_cippo(r, Vector3(-0.68, 0, 0.6), 0.9)
	return r


## Caserma romana: alloggio di mattoni con portico, campo d'addestramento col palo, legionari, rastrelliera di pili e scudi.
static func caserma_romani() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.3, 0, -0.3)
	r.add_child(c)
	var lx := 0.62
	var lz := 0.5
	var h := 0.38
	_muri_r(c, lx, lz, h, 711, "mattoni")
	_porta_r(c, 0.08, lz * 0.5, 0.15, 0.24)
	_finestra_r(c, Vector3(-0.17, 0.36, lz * 0.5), 0.0)
	_finestra_r(c, Vector3(lx * 0.5, 0.36, 0.0), 90.0)
	sottotetto(c, lx, lz, 0.07 + h, 18.0, "mattoni")
	_tetto_r(c, lx + 0.06, lz, 0.07 + h, 18.0, 711)
	_vessillo(c, Vector3(lx * 0.5 - 0.05, 0.07 + h + 0.02, lz * 0.5 - 0.06), 0.5)
	# campo d'addestramento in terra battuta
	r.add_child(scatola(Vector3(0.75, 0.01, 0.55), Vector3(0.25, 0.005, 0.4), "terra"))
	r.add_child(cilindro(0.025, 0.028, 0.36, Vector3(0.5, 0.18, 0.35), "legno_vecchio", Vector3.ZERO, 8))
	for k in 3:
		r.add_child(scatola(Vector3(0.006, 0.02, 0.054), Vector3(0.526, 0.1 + k * 0.08, 0.35), "fuliggine"))
	for k in 2:
		var o := legionario()
		o.position = Vector3(0.05 + k * 0.28, 0, 0.55 - k * 0.15)
		o.rotation_degrees.y = 150 - k * 60
		o.scale = Vector3.ONE * 0.95
		r.add_child(o)
	# rastrelliera di pili e scudi appoggiati
	r.add_child(scatola(Vector3(0.24, 0.02, 0.03), Vector3(-0.58, 0.28, 0.42), "legno"))
	for lato: int in [-1, 1]:
		r.add_child(scatola(Vector3(0.02, 0.3, 0.03), Vector3(-0.58 + lato * 0.11, 0.15, 0.42), "legno_vecchio"))
	for k in 5:
		r.add_child(cilindro(0.005, 0.005, 0.44, Vector3(-0.66 + k * 0.04, 0.22, 0.4), "legno", Vector3(-8, 0, 0), 5))
	r.add_child(_scuto(Vector3(-0.6, 0, 0.55), -70, 0.95))
	r.add_child(_scuto(Vector3(-0.45, 0, 0.6), -55, 0.95))
	_cippo(r, Vector3(0.68, 0, -0.1))
	return r


## Castrum: mura di mattoni con ricorsi di travertino, torri quadrate con il tetto di tegole, porta a due fornici
## fra due torri, via di basoli fino ai principia con le insegne, baracche in fila.
static func castello_romani() -> Node3D:
	var r := Node3D.new()
	var lato := 2.3
	var h := 0.48
	r.add_child(scatola(Vector3(lato + 0.3, 0.06, lato + 0.3), Vector3(0, 0.03, 0), "blocco"))
	r.add_child(scatola(Vector3(lato - 0.1, 0.012, lato - 0.1), Vector3(0, 0.066, 0), "terra"))
	for i in 4:
		var m := Node3D.new()
		m.rotation_degrees.y = i * 90
		r.add_child(m)
		if i == 0:
			for seg in [[-lato * 0.5, 0.05], [0.85, lato * 0.5]]:
				var l: float = seg[1] - seg[0]
				var cx: float = (seg[0] + seg[1]) * 0.5
				m.add_child(scatola(Vector3(l, h, 0.16), Vector3(cx, 0.06 + h * 0.5, lato * 0.5), "mattoni"))
				for y in [0.06 + h * 0.35, 0.06 + h * 0.7]:
					m.add_child(scatola(Vector3(l, 0.02, 0.17), Vector3(cx, y, lato * 0.5), "blocco"))
				m.add_child(scatola(Vector3(l, 0.025, 0.19), Vector3(cx, 0.06 + h, lato * 0.5), "blocco"))
				var nm := int(l / 0.2)
				for k in nm:
					m.add_child(scatola(Vector3(0.1, 0.08, 0.06), Vector3(seg[0] + (k + 0.5) * l / nm, 0.06 + h + 0.05, lato * 0.5 + 0.06), "mattoni"))
		else:
			m.add_child(scatola(Vector3(lato, h, 0.16), Vector3(0, 0.06 + h * 0.5, lato * 0.5), "mattoni"))
			for y in [0.06 + h * 0.35, 0.06 + h * 0.7]:
				m.add_child(scatola(Vector3(lato, 0.02, 0.17), Vector3(0, y, lato * 0.5), "blocco"))
			m.add_child(scatola(Vector3(lato, 0.025, 0.19), Vector3(0, 0.06 + h, lato * 0.5), "blocco"))
			for k in 11:
				m.add_child(scatola(Vector3(0.1, 0.08, 0.06), Vector3(-lato * 0.5 + 0.1 + k * (lato - 0.2) / 10, 0.06 + h + 0.05, lato * 0.5 + 0.06), "mattoni"))
	# torri quadrate agli angoli e ai lati della porta
	var torri := [Vector3(-1, 0, -1) * lato * 0.5, Vector3(1, 0, -1) * lato * 0.5, Vector3(1, 0, 1) * lato * 0.5, Vector3(-1, 0, 1) * lato * 0.5,
		Vector3(-0.05, 0, lato * 0.5), Vector3(0.95, 0, lato * 0.5)]
	for k in torri.size():
		var p: Vector3 = torri[k]
		var lt := 0.42 if k < 4 else 0.3
		var ht := h + 0.32
		var t := Node3D.new()
		t.position = p + Vector3(0, 0.06, 0)
		r.add_child(t)
		t.add_child(scatola(Vector3(lt, ht, lt), Vector3(0, ht * 0.5, 0), "mattoni"))
		for y in [ht * 0.3, ht * 0.62]:
			t.add_child(scatola(Vector3(lt + 0.01, 0.022, lt + 0.01), Vector3(0, y, 0), "blocco"))
		t.add_child(scatola(Vector3(lt + 0.04, 0.03, lt + 0.04), Vector3(0, ht, 0), "blocco"))
		_finestra_r(t, Vector3(0, ht - 0.12, lt * 0.5), 0.0, 0.05, 0.06)
		_finestra_r(t, Vector3(lt * 0.5, ht - 0.12, 0), 90.0, 0.05, 0.06)
		for lv: int in [-1, 1]:
			t.add_child(scatola(Vector3(0.04, 0.12, 0.04), Vector3(lv * (lt * 0.5 - 0.02), ht + 0.07, lt * 0.5 - 0.02), "mattoni"))
			t.add_child(scatola(Vector3(0.04, 0.12, 0.04), Vector3(lv * (lt * 0.5 - 0.02), ht + 0.07, -lt * 0.5 + 0.02), "mattoni"))
		t.add_child(cilindro((lt + 0.12) * 0.707, 0.0, 0.2, Vector3(0, ht + 0.23, 0), "laterizio", Vector3(0, 45, 0), 4))
		t.add_child(cilindro((lt + 0.13) * 0.707, (lt + 0.13) * 0.707, 0.02, Vector3(0, ht + 0.135, 0), "laterizio_scuro", Vector3(0, 45, 0), 4))
	# porta a due fornici fra le torri
	var g := Vector3(0.45, 0.06, lato * 0.5)
	r.add_child(scatola(Vector3(0.66, 0.5, 0.2), g + Vector3(0, 0.25, 0), "mattoni"))
	for gx in [-0.13, 0.13]:
		r.add_child(scatola(Vector3(0.16, 0.24, 0.012), g + Vector3(gx, 0.12, 0.104), "buio"))
		r.add_child(cilindro(0.08, 0.08, 0.012, g + Vector3(gx, 0.24, 0.104), "buio", Vector3(90, 0, 0), 14))
		for k in 7:
			var a := (k + 0.5) * PI / 7
			r.add_child(scatola(Vector3(0.03, 0.04, 0.02), g + Vector3(gx + cos(a) * 0.095, 0.24 + sin(a) * 0.095, 0.11), "blocco" if k % 2 == 0 else "intonaco_bianco", Vector3(0, 0, rad_to_deg(a))))
	r.add_child(scatola(Vector3(0.5, 0.07, 0.012), g + Vector3(0, 0.42, 0.105), "marmo"))
	for k in 2:
		r.add_child(scatola(Vector3(0.36 - k * 0.1, 0.012, 0.006), g + Vector3(0, 0.44 - k * 0.025, 0.112), "rosso_pompeiano"))
	r.add_child(scatola(Vector3(0.7, 0.025, 0.22), g + Vector3(0, 0.51, 0), "blocco"))
	for k in 6:
		r.add_child(scatola(Vector3(0.07, 0.07, 0.05), g + Vector3(-0.3 + k * 0.12, 0.56, 0.08), "mattoni"))
	_basolato(r, Vector3(0.45, 0, lato * 0.5 + 0.28), 0.36, 0.3, 721)
	_cippo(r, Vector3(0.82, 0, lato * 0.5 + 0.3), 1.2)
	# via di basoli fino ai principia
	_basolato(r, Vector3(0.45, 0.06, 0.45), 0.3, 1.1, 722, true)
	var c := Node3D.new()
	c.position = Vector3(-0.15, 0.06, -0.42)
	r.add_child(c)
	_muri_r(c, 0.9, 0.62, 0.5, 723)
	_porta_r(c, 0.18, 0.31, 0.16, 0.26)
	_finestra_r(c, Vector3(-0.2, 0.42, 0.31), 0.0)
	_finestra_r(c, Vector3(0.45, 0.42, 0.0), 90.0)
	sottotetto(c, 0.9, 0.62, 0.57, 18.0, "intonaco_ocra")
	_tetto_r(c, 0.96, 0.62, 0.57, 18.0, 723)
	for k in 3:
		_vessillo(r, Vector3(0.2 + k * 0.12, 0.06, -0.02 + k * 0.03), 0.62 + (k % 2) * 0.08)
	# baracche in fila sul lato sinistro
	for k in 2:
		var b := Node3D.new()
		b.position = Vector3(-0.72, 0.06, 0.15 + k * 0.42)
		r.add_child(b)
		_muri_r(b, 0.5, 0.26, 0.22, 730 + k, "mattoni")
		for d in 3:
			b.add_child(scatola(Vector3(0.06, 0.12, 0.01), Vector3(-0.16 + d * 0.16, 0.13, 0.135), "legno_scuro"))
		sottotetto(b, 0.5, 0.26, 0.29, 18.0, "mattoni")
		_tetto_r(b, 0.54, 0.26, 0.29, 18.0, 730 + k)
	r.add_child(_scuto(Vector3(0.75, 0.06, 0.45), -60, 1.0))
	r.add_child(_scuto(Vector3(0.82, 0.06, 0.55), -50, 1.0))
	for k in 3:
		r.add_child(cassa(Vector3(0.75 + k * 0.12, 0.06, 0.2), k * 20))
	r.add_child(barile(Vector3(0.78, 0.06, -0.1), 1.1))
	return r


## Torre di guardia romana: fusto di mattoni con ricorsi di travertino, piano alto di legno con ballatoio,
## tetto a padiglione di tegole, fiaccola, vessillo, legna per il segnale.
static func torre_romani() -> Node3D:
	var r := Node3D.new()
	var lato := 0.55
	var h := 0.85
	r.add_child(scatola(Vector3(lato + 0.16, 0.08, lato + 0.16), Vector3(0, 0.04, 0), "blocco"))
	r.add_child(scatola(Vector3(lato, h, lato), Vector3(0, 0.08 + h * 0.5, 0), "mattoni"))
	for y in [0.35, 0.65, 0.08 + h - 0.02]:
		r.add_child(scatola(Vector3(lato + 0.02, 0.025, lato + 0.02), Vector3(0, y, 0), "blocco"))
	for y in [0.5, 0.8]:
		_finestra_r(r, Vector3(0.1, y, lato * 0.5), 0.0, 0.04, 0.07)
		_finestra_r(r, Vector3(lato * 0.5, y, -0.05), 90.0, 0.04, 0.07)
	_porta_r(r, -0.1, lato * 0.5, 0.13, 0.22)
	# piano di legno con il ballatoio
	var top := 0.08 + h
	r.add_child(scatola(Vector3(lato + 0.2, 0.03, lato + 0.2), Vector3(0, top + 0.015, 0), "legno_vecchio"))
	for k in 5:
		var off := -lato * 0.5 + k * lato / 4
		r.add_child(scatola(Vector3(0.025, 0.07, 0.1), Vector3(off, top - 0.03, lato * 0.5 + 0.05), "legno_scuro", Vector3(-30, 0, 0)))
		r.add_child(scatola(Vector3(0.1, 0.07, 0.025), Vector3(lato * 0.5 + 0.05, top - 0.03, off), "legno_scuro", Vector3(0, 0, 30)))
	var ls := lato - 0.08
	r.add_child(scatola(Vector3(ls, 0.3, ls), Vector3(0, top + 0.18, 0), "legno"))
	for k in 6:
		r.add_child(scatola(Vector3(ls + 0.006, 0.006, ls + 0.006), Vector3(0, top + 0.05 + k * 0.042, 0), "legno_scuro"))
	r.add_child(scatola(Vector3(0.1, 0.08, 0.01), Vector3(0, top + 0.18, ls * 0.5 + 0.002), "buio"))
	r.add_child(scatola(Vector3(0.01, 0.08, 0.1), Vector3(ls * 0.5 + 0.002, top + 0.18, 0), "buio"))
	# parapetto del ballatoio
	var pb := lato * 0.5 + 0.08
	for k in 7:
		var off := -pb + k * pb * 2 / 6
		r.add_child(scatola(Vector3(0.014, 0.1, 0.014), Vector3(off, top + 0.08, pb), "legno_vecchio"))
		r.add_child(scatola(Vector3(0.014, 0.1, 0.014), Vector3(pb, top + 0.08, off), "legno_vecchio"))
	r.add_child(scatola(Vector3(pb * 2, 0.016, 0.016), Vector3(0, top + 0.13, pb), "legno"))
	r.add_child(scatola(Vector3(0.016, 0.016, pb * 2), Vector3(pb, top + 0.13, 0), "legno"))
	# pali angolari e tetto a padiglione di tegole
	var rt := ls * 0.5 + 0.07
	r.add_child(cilindro(rt * 1.414, rt * 1.414, 0.025, Vector3(0, top + 0.34, 0), "laterizio_scuro", Vector3(0, 45, 0), 4))
	r.add_child(cilindro((rt - 0.01) * 1.414, 0.0, 0.24, Vector3(0, top + 0.47, 0), "laterizio", Vector3(0, 45, 0), 4))
	for k in 4:
		var a := k * PI * 0.5
		r.add_child(scatola(Vector3(0.02, 0.02, rt * 1.5), Vector3(cos(a + PI * 0.25) * rt * 0.5, top + 0.47, sin(a + PI * 0.25) * rt * 0.5), "tegola_b", Vector3(0, -rad_to_deg(a + PI * 0.25) + 90, 0)))
	r.add_child(sfera(0.03, Vector3(0, top + 0.6, 0), "terracotta"))
	_vessillo(r, Vector3(-0.12, top + 0.38, -0.12), 0.5)
	# fiaccola accesa sull'angolo e cataste per i segnali di fuoco alla base
	r.add_child(cilindro(0.006, 0.006, 0.12, Vector3(pb, top + 0.2, pb), "legno", Vector3.ZERO, 5))
	r.add_child(sfera(0.02, Vector3(pb, top + 0.28, pb), "brace", Vector3(1, 1.4, 1)))
	legnaia(r, Vector3(0.0, 0.0, lato * 0.5 + 0.2), 0.3, 3)
	r.add_child(_scuto(Vector3(lato * 0.5 + 0.12, 0.0, 0.2), -80, 1.0))
	r.add_child(cassa(Vector3(lato * 0.5 + 0.17, 0.0, -0.05), 10))
	_basolato(r, Vector3(-0.1, 0, lato * 0.5 + 0.12), 0.24, 0.16, 741)
	_cippo(r, Vector3(-0.42, 0, 0.42), 1.0)
	return r


## Fornace dei laterizi (edificio unico dei Romani): fornace a volta di mattoni con la bocca di fuoco,
## tettoia dove seccano le tegole crude, file di tegole e mattoni al sole, cataste di argilla e di legna.
static func laterizi() -> Node3D:
	var r := Node3D.new()
	var f := Node3D.new()
	f.position = Vector3(-0.22, 0, -0.28)
	r.add_child(f)
	var lx := 0.66
	var lz := 0.5
	var h := 0.24
	f.add_child(scatola(Vector3(lx + 0.06, 0.05, lz + 0.06), Vector3(0, 0.025, 0), "blocco"))
	f.add_child(scatola(Vector3(lx, h, lz), Vector3(0, 0.05 + h * 0.5, 0), "mattoni"))
	f.add_child(scatola(Vector3(lx + 0.02, 0.02, lz + 0.02), Vector3(0, 0.05 + h, 0), "blocco"))
	# volta a botte di mattoni con le ghiere
	var rg := lz * 0.5 - 0.01
	f.add_child(cilindro(rg, rg, lx - 0.02, Vector3(0, 0.05 + h, 0), "mattoni", Vector3(0, 0, 90), 22))
	for k in 5:
		f.add_child(cilindro(rg + 0.012, rg + 0.012, 0.035, Vector3(-lx * 0.5 + 0.03 + k * (lx - 0.06) / 4, 0.05 + h, 0), "laterizio", Vector3(0, 0, 90), 22))
	# sfiatatoi fumanti
	for x in [-0.15, 0.15]:
		f.add_child(cilindro(0.03, 0.035, 0.08, Vector3(x, 0.05 + h + rg + 0.02, 0), "mattoni", Vector3.ZERO, 8))
		f.add_child(cilindro(0.022, 0.022, 0.005, Vector3(x, 0.05 + h + rg + 0.062, 0), "fuliggine", Vector3.ZERO, 8))
		_fumo(f, Vector3(x, 0.05 + h + rg + 0.1, 0), 3, 0.9)
	# bocca del prefurnio ad arco, accesa, con fuliggine sopra e il fosso del fochista
	_arco(f, Vector3(-0.05, 0.05, lz * 0.5 + 0.03), 0.13, 0.08, 0.06, "mattoni", 0.0, "laterizio")
	f.add_child(scatola(Vector3(0.13, 0.1, 0.01), Vector3(-0.05, 0.1, lz * 0.5 + 0.004), "buio"))
	f.add_child(cilindro(0.065, 0.065, 0.01, Vector3(-0.05, 0.13, lz * 0.5 + 0.004), "buio", Vector3(90, 0, 0), 12))
	f.add_child(sfera(0.05, Vector3(-0.05, 0.08, lz * 0.5 + 0.02), "brace", Vector3(1.2, 0.8, 0.6)))
	f.add_child(cilindro(0.025, 0.0, 0.07, Vector3(-0.05, 0.12, lz * 0.5 + 0.02), "brace", Vector3.ZERO, 6))
	f.add_child(scatola(Vector3(0.2, 0.08, 0.006), Vector3(-0.05, 0.24, lz * 0.5 + 0.032), "fuliggine"))
	f.add_child(scatola(Vector3(0.24, 0.006, 0.16), Vector3(-0.05, 0.004, lz * 0.5 + 0.12), "fuliggine"))
	legnaia(f, Vector3(0.2, 0.0, lz * 0.5 + 0.1), 0.2, 3)
	# tettoia di essiccazione sul lato destro con tegole crude sulle rastrelliere
	var t := Node3D.new()
	t.position = Vector3(0.52, 0, -0.18)
	r.add_child(t)
	for p in [Vector3(-0.14, 0, -0.32), Vector3(0.14, 0, -0.32), Vector3(-0.14, 0, 0.32), Vector3(0.14, 0, 0.32)]:
		t.add_child(scatola(Vector3(0.035, 0.32, 0.035), p + Vector3(0, 0.16, 0), "mattoni"))
	var ft := Node3D.new()
	ft.rotation_degrees.y = 90
	t.add_child(ft)
	_tetto_r(ft, 0.74, 0.28, 0.32, 16.0, 751)
	for k in 3:
		t.add_child(scatola(Vector3(0.24, 0.012, 0.62), Vector3(0, 0.06 + k * 0.08, 0), "legno_vecchio"))
		for j in 5:
			t.add_child(scatola(Vector3(0.09, 0.008, 0.11), Vector3(-0.055 + (j % 2) * 0.11, 0.07 + k * 0.08, -0.24 + j * 0.12), "argilla_cruda", Vector3(0, 0, 0)))
	# file di tegole e mattoni crudi a seccare al sole
	for i in 4:
		for j in 3:
			var p := Vector3(-0.66 + i * 0.13, 0, 0.3 + j * 0.13)
			r.add_child(scatola(Vector3(0.1, 0.01, 0.12), p + Vector3(0, 0.005, 0), "argilla_cruda", Vector3(0, 4, 0)))
			for lato: int in [-1, 1]:
				r.add_child(scatola(Vector3(0.01, 0.014, 0.12), p + Vector3(lato * 0.045, 0.012, 0), "argilla_cruda", Vector3(0, 4, 0)))
	for k in 10:
		r.add_child(scatola(Vector3(0.07, 0.025, 0.035), Vector3(-0.1 + (k % 5) * 0.08, 0.0125 + (k / 5) * 0.026, 0.7), "argilla_cruda", Vector3(0, (k % 2) * 6, 0)))
	# tegole e coppi cotti pronti, argilla, acqua
	_pila_tegole(r, Vector3(0.36, 0, 0.42), 6, 20)
	_pila_tegole(r, Vector3(0.5, 0, 0.56), 4, 10)
	for k in 4:
		var cp := cilindro(0.022, 0.018, 0.13, Vector3(0.66, 0.014 + (k / 2) * 0.028, 0.36 + (k % 2) * 0.05), "laterizio", Vector3(90, 0, 0), 8)
		cp.scale = Vector3(1, 1, 0.6)
		r.add_child(cp)
	r.add_child(mucchio(Vector3(-0.68, 0, -0.05), "argilla", 9, 13, 0.05))
	r.add_child(mucchio(Vector3(-0.62, 0, 0.12), "argilla_cruda", 6, 14, 0.04))
	r.add_child(barile(Vector3(0.2, 0, 0.7), 1.0))
	r.add_child(cilindro(0.04, 0.04, 0.005, Vector3(0.2, 0.1, 0.7), "acqua_pozzo", Vector3.ZERO, 10))
	_vessillo(r, Vector3(-0.68, 0, -0.45), 0.55)
	return r


## Legionario: elmo di ferro con paranuca e pennacchio rosso, lorica a lamine, tunica rosso pompeiano,
## scudo rettangolare curvo rosso con umbone di bronzo, gladio.
static func legionario() -> Node3D:
	var r := portatore("", "giocatore", "stoffa_pompeiana")
	var corpo: Node3D = r.get_node("corpo")
	var anca := 0.2
	# lorica a lamine e spallacci
	for k in 3:
		var y := anca + 0.115 + k * 0.022
		var rr := 0.085 - (y - (anca - 0.03)) / 0.2 * 0.025 + 0.007
		corpo.add_child(cilindro(rr, rr - 0.002, 0.019, Vector3(0, y, 0), "ferro" if k % 2 == 0 else "lingotto", Vector3.ZERO, 12))
	for lato: int in [-1, 1]:
		corpo.add_child(sfera(0.034, Vector3(lato * 0.058, anca + 0.17, 0), "ferro", Vector3(1.15, 0.55, 1.1)))
	# cinturone con le strisce borchiate davanti
	corpo.add_child(cilindro(0.083, 0.083, 0.018, Vector3(0, anca + 0.075, 0), "pelle_scura", Vector3.ZERO, 12))
	corpo.add_child(sfera(0.01, Vector3(0, anca + 0.075, 0.083), "moneta"))
	for k in 4:
		corpo.add_child(scatola(Vector3(0.012, 0.06, 0.006), Vector3(-0.027 + k * 0.018, anca + 0.04, 0.084), "pelle_scura"))
		corpo.add_child(sfera(0.005, Vector3(-0.027 + k * 0.018, anca + 0.012, 0.087), "moneta"))
	# elmo di ferro: calotta, fascia di bronzo, paranuca, paraguance, pennacchio rosso
	corpo.add_child(sfera(0.08, Vector3(0, anca + 0.282, -0.005), "ferro", Vector3(1, 0.72, 1.05)))
	corpo.add_child(cilindro(0.081, 0.083, 0.014, Vector3(0, anca + 0.262, -0.005), "bronzo", Vector3.ZERO, 14))
	corpo.add_child(scatola(Vector3(0.13, 0.012, 0.06), Vector3(0, anca + 0.245, -0.08), "ferro", Vector3(-22, 0, 0)))
	for lato: int in [-1, 1]:
		corpo.add_child(scatola(Vector3(0.01, 0.055, 0.04), Vector3(lato * 0.077, anca + 0.235, 0.025), "bronzo"))
	corpo.add_child(cilindro(0.008, 0.008, 0.03, Vector3(0, anca + 0.345, 0), "bronzo", Vector3.ZERO, 6))
	for k in 5:
		var z := -0.05 + k * 0.025
		corpo.add_child(sfera(0.024, Vector3(0, anca + 0.37 - absf(z) * 0.4, z), "stoffa_pompeiana", Vector3(0.55, 1.15, 0.9)))
	# scudo al braccio sinistro
	var bs: Node3D = corpo.get_node("braccio_s")
	var sc := _scuto(Vector3(-0.035, -0.18, 0.035), 0.0, 1.0)
	bs.add_child(sc)
	# gladio nella destra
	var bd: Node3D = corpo.get_node("braccio_d")
	bd.add_child(scatola(Vector3(0.01, 0.018, 0.15), Vector3(0, -0.14, 0.09), "spada"))
	bd.add_child(cilindro(0.009, 0.0, 0.025, Vector3(0, -0.14, 0.177), "spada", Vector3(90, 0, 0), 4))
	bd.add_child(scatola(Vector3(0.036, 0.016, 0.014), Vector3(0, -0.14, 0.012), "bronzo"))
	bd.add_child(scatola(Vector3(0.012, 0.014, 0.03), Vector3(0, -0.14, -0.01), "legno_scuro"))
	bd.add_child(sfera(0.011, Vector3(0, -0.14, -0.028), "moneta"))
	r.set_meta("carico", "spada")
	return r


# ------------------------------------------------------------------ altri edifici dei Romani (step G6b)
# Stesso ingombro e stessa disposizione del corrispondente greco (stesso nome senza "_romani").

## Bottega romana: muri ocra (o mattoni vivi), sottotetto e tetto di tegole; porta e finestre si aggiungono a parte.
static func _bottega_r(c: Node3D, lx: float, lz: float, h: float, seme: int, pend := 20.0, mat := "intonaco_ocra") -> void:
	_muri_r(c, lx, lz, h, seme, mat)
	sottotetto(c, lx, lz, 0.07 + h, pend, mat)
	_tetto_r(c, lx + 0.06, lz, 0.07 + h, pend, seme)


## Muretto di mattoni con la copertina di laterizio fra due punti a terra.
static func _muretto_r(r: Node3D, da: Vector3, a: Vector3, h := 0.08) -> void:
	var d := a - da
	var l := Vector2(d.x, d.z).length()
	var rot := rad_to_deg(atan2(-d.z, d.x))
	var m := (da + a) * 0.5
	r.add_child(scatola(Vector3(l + 0.035, h, 0.035), m + Vector3(0, h * 0.5, 0), "mattoni", Vector3(0, rot, 0)))
	r.add_child(scatola(Vector3(l + 0.045, 0.014, 0.045), m + Vector3(0, h + 0.007, 0), "laterizio", Vector3(0, rot, 0)))


## Tettoia di tegole a una falda su quattro pilastrini di mattoni con il capitello di travertino (gronda verso +Z locale).
static func _tettoia_r(r: Node3D, pos: Vector3, larg: float, prof: float, h: float, seme: int, rot_y := 0.0) -> void:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot_y
	r.add_child(n)
	var pend := 16.0
	var dh := prof * tan(deg_to_rad(pend))
	for lato: int in [-1, 1]:
		for dietro: int in [0, 1]:
			var hp := h + dietro * dh
			var z := prof * 0.5 - dietro * prof
			n.add_child(scatola(Vector3(0.04, hp, 0.04), Vector3(lato * (larg * 0.5 - 0.03), hp * 0.5, z), "mattoni"))
			n.add_child(scatola(Vector3(0.052, 0.018, 0.052), Vector3(lato * (larg * 0.5 - 0.03), hp - 0.009, z), "blocco"))
	_falda(n, larg, prof, h, pend, Vector3.ZERO, 0.0, seme)


## Porcile romano: stalla di mattoni con tetto di tegole, recinto di muretti di mattoni con il cancelletto,
## truogolo di pietra, maiali nel fango, dolio e cippo.
static func porcile_romani() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.3, 0, -0.3)
	r.add_child(c)
	var lx := 0.6
	var lz := 0.46
	var h := 0.3
	_bottega_r(c, lx, lz, h, 711, 20.0, "mattoni")
	_porta_r(c, -0.1, lz * 0.5, 0.12, 0.17)
	_finestra_r(c, Vector3(lx * 0.5, 0.28, 0.0), 90.0)
	var a := Vector3(0.05, 0, 0.0)
	r.add_child(scatola(Vector3(0.8, 0.012, 0.75), a + Vector3(0.12, 0.006, 0.12), "terra"))
	_muretto_r(r, a + Vector3(-0.28, 0, 0.5), a + Vector3(0.28, 0, 0.5))
	recinto(r, a + Vector3(0.3, 0, 0.5), a + Vector3(0.5, 0, 0.5), 0.08)
	_muretto_r(r, a + Vector3(0.52, 0, -0.26), a + Vector3(0.52, 0, 0.5))
	_muretto_r(r, a + Vector3(0.15, 0, -0.26), a + Vector3(0.52, 0, -0.26))
	r.add_child(sfera(0.14, a + Vector3(0.28, 0.0, 0.05), "fuliggine", Vector3(1.4, 0.1, 1.0)))
	r.add_child(scatola(Vector3(0.24, 0.05, 0.07), a + Vector3(0.0, 0.025, 0.4), "blocco"))
	r.add_child(scatola(Vector3(0.2, 0.012, 0.05), a + Vector3(0.0, 0.05, 0.4), "grano"))
	for p in [[Vector3(0.25, 0, 0.3), 20], [Vector3(0.38, 0, -0.05), 130], [Vector3(0.05, 0, 0.18), -60], [Vector3(0.4, 0, 0.32), 200]]:
		r.add_child(maiale(a + p[0], p[1]))
	r.add_child(sacco(Vector3(-0.62, 0, 0.2), 0.3))
	_dolio(r, Vector3(-0.5, 0, 0.32), 0.85)
	return r


## Macelleria romana: bottega ocra con la fascia rossa, tettoia di tegole su pilastri di mattoni con prosciutti
## e salami appesi, banco di mattoni col piano di marmo, ceppo, dolio.
static func macelleria_romani() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.25)
	r.add_child(c)
	var lx := 0.74
	var lz := 0.56
	var h := 0.4
	_bottega_r(c, lx, lz, h, 721, 18.0)
	_porta_r(c, 0.16, lz * 0.5, 0.13, 0.22)
	_finestra_r(c, Vector3(-0.17, 0.35, lz * 0.5), 0.0)
	_finestra_r(c, Vector3(lx * 0.5, 0.35, 0.0), 90.0)
	_comignolo_r(c, Vector3(0.2, 0.07 + h + 0.04, -0.1))
	_tettoia_r(r, Vector3(0.45, 0, 0.34), 0.56, 0.22, 0.36, 722)
	for x: float in [0.2, 0.7]:
		r.add_child(scatola(Vector3(0.02, 0.02, 0.16), Vector3(x, 0.33, 0.53), "legno_scuro"))
	r.add_child(scatola(Vector3(0.54, 0.02, 0.02), Vector3(0.45, 0.33, 0.6), "legno"))
	for k in 5:
		var x := 0.27 + k * 0.09
		r.add_child(cilindro(0.003, 0.003, 0.05, Vector3(x, 0.305, 0.6), "corda", Vector3.ZERO, 3))
		if k % 2 == 0:
			r.add_child(sfera(0.035, Vector3(x, 0.24, 0.6), "carne", Vector3(0.9, 1.4, 0.8)))
		else:
			r.add_child(cilindro(0.016, 0.016, 0.1, Vector3(x, 0.23, 0.6), "carne", Vector3.ZERO, 8))
	var b := Vector3(-0.35, 0, 0.55)
	r.add_child(scatola(Vector3(0.3, 0.1, 0.13), b + Vector3(0, 0.05, 0), "mattoni"))
	r.add_child(scatola(Vector3(0.32, 0.02, 0.15), b + Vector3(0, 0.11, 0), "marmo"))
	r.add_child(scatola(Vector3(0.26, 0.05, 0.004), b + Vector3(0, 0.055, 0.067), "rosso_pompeiano"))
	r.add_child(sfera(0.04, b + Vector3(-0.05, 0.135, 0), "carne", Vector3(1.2, 0.5, 0.9)))
	r.add_child(scatola(Vector3(0.07, 0.004, 0.02), b + Vector3(0.08, 0.123, 0.02), "ferro", Vector3(0, 30, 0)))
	r.add_child(cilindro(0.07, 0.075, 0.1, Vector3(-0.65, 0.05, 0.4), "corteccia", Vector3.ZERO, 12))
	_dolio(r, Vector3(0.65, 0, 0.0), 0.9)
	r.add_child(maiale(Vector3(-0.6, 0, 0.0), 60))
	return r


## Apiario romano: casetta ocra, arnie di terracotta a tubo coricate in due file su banchi di mattoni, fiori.
static func apiario_romani() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.35, 0, -0.35)
	r.add_child(c)
	var lx := 0.5
	var lz := 0.4
	var h := 0.26
	_bottega_r(c, lx, lz, h, 731, 20.0)
	_porta_r(c, 0.06, lz * 0.5, 0.11, 0.15)
	_finestra_r(c, Vector3(lx * 0.5, 0.25, 0.0), 90.0, 0.06, 0.07)
	for f in 2:
		var z := 0.15 + f * 0.25
		r.add_child(scatola(Vector3(0.78, 0.06, 0.12), Vector3(0.15, 0.03, z), "mattoni"))
		r.add_child(scatola(Vector3(0.8, 0.014, 0.14), Vector3(0.15, 0.067, z), "laterizio"))
		for liv in 2:
			for k in 5 - liv:
				var p := Vector3(-0.15 + k * 0.15 + liv * 0.075, 0.115 + liv * 0.075, z)
				r.add_child(cilindro(0.04, 0.04, 0.12, p, "terracotta", Vector3(90, 0, 0), 12))
				r.add_child(cilindro(0.042, 0.042, 0.012, p + Vector3(0, 0, 0.03), "laterizio_scuro", Vector3(90, 0, 0), 12))
				r.add_child(cilindro(0.032, 0.032, 0.006, p + Vector3(0, 0, 0.061), "laterizio_scuro", Vector3(90, 0, 0), 12))
				r.add_child(cilindro(0.014, 0.014, 0.006, p + Vector3(0, 0, 0.064), "buio", Vector3(90, 0, 0), 8))
	var rng := _rng(92)
	for k in 30:
		var p := Vector3(rng.randf_range(-0.7, 0.7), 0.0, rng.randf_range(0.55, 0.75))
		if k % 2 == 0:
			p = Vector3(rng.randf_range(0.5, 0.75), 0.0, rng.randf_range(-0.6, 0.6))
		r.add_child(sfera(0.018, p + Vector3(0, 0.02, 0), "orto"))
		r.add_child(sfera(0.012, p + Vector3(0, 0.04, 0), ["geranio", "fiore", "miele"][k % 3]))
	r.add_child(anfora(Vector3(-0.62, 0, 0.2), 0.9))
	_dolio(r, Vector3(-0.55, 0, 0.34), 0.7)
	return r


## Caseificio romano: bottega ocra, focolare tondo di mattoni col paiolo di bronzo, scaffali di formaggi
## su zoccoli di mattoni, dolio e anfora.
static func caseificio_romani() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.25)
	r.add_child(c)
	var lx := 0.74
	var lz := 0.56
	var h := 0.4
	_bottega_r(c, lx, lz, h, 741, 18.0)
	_porta_r(c, -0.15, lz * 0.5, 0.13, 0.22)
	_finestra_r(c, Vector3(0.18, 0.35, lz * 0.5), 0.0)
	_finestra_r(c, Vector3(lx * 0.5, 0.35, 0.0), 90.0)
	_comignolo_r(c, Vector3(-0.2, 0.07 + h + 0.04, -0.1))
	var f := Vector3(0.45, 0, 0.45)
	r.add_child(cilindro(0.14, 0.15, 0.08, f + Vector3(0, 0.04, 0), "mattoni", Vector3.ZERO, 16))
	r.add_child(cilindro(0.15, 0.15, 0.014, f + Vector3(0, 0.086, 0), "laterizio", Vector3.ZERO, 16))
	r.add_child(scatola(Vector3(0.07, 0.045, 0.02), f + Vector3(0, 0.035, 0.14), "brace"))
	r.add_child(sfera(0.1, f + Vector3(0, 0.16, 0), "bronzo", Vector3(1, 0.8, 1)))
	r.add_child(cilindro(0.085, 0.085, 0.01, f + Vector3(0, 0.21, 0), "latte", Vector3.ZERO, 14))
	for lato: int in [-1, 1]:
		r.add_child(scatola(Vector3(0.035, 0.32, 0.035), f + Vector3(lato * 0.17, 0.16, 0), "mattoni"))
	r.add_child(scatola(Vector3(0.4, 0.02, 0.02), f + Vector3(0, 0.33, 0), "legno_scuro"))
	r.add_child(scatola(Vector3(0.006, 0.07, 0.006), f + Vector3(0, 0.29, 0), "ferro"))
	for p: Vector3 in [Vector3(-0.3, 0, 0.5), Vector3(0.7, 0, -0.05)]:
		var lungo_x := p.x < 0
		r.add_child(scatola(Vector3(0.3 if lungo_x else 0.1, 0.04, 0.1 if lungo_x else 0.3), p + Vector3(0, 0.02, 0), "mattoni"))
		for liv in 3:
			r.add_child(scatola(Vector3(0.28 if lungo_x else 0.08, 0.012, 0.08 if lungo_x else 0.28), p + Vector3(0, 0.05 + liv * 0.08, 0), "legno"))
			for k in 3:
				var o := Vector3((k - 1) * 0.085, 0, 0) if lungo_x else Vector3(0, 0, (k - 1) * 0.085)
				r.add_child(cilindro(0.035, 0.035, 0.04, p + o + Vector3(0, 0.078 + liv * 0.08, 0), "formaggio", Vector3.ZERO, 12))
	_dolio(r, Vector3(0.08, 0, 0.62), 0.8)
	r.add_child(anfora(Vector3(0.2, 0, 0.6), 1.1))
	return r


## Argillaio romano: casetta di mattoni con tetto di tegole, fossa d'argilla, mattoni crudi e tegole crude
## che seccano, vasca di pietra con l'acqua, pala, cippo.
static func argillaio_romani() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.32, 0, -0.32)
	r.add_child(c)
	_bottega_r(c, 0.46, 0.36, 0.24, 751, 22.0, "mattoni")
	_porta_r(c, 0.06, 0.18, 0.11, 0.13)
	r.add_child(sfera(0.3, Vector3(0.3, -0.02, 0.25), "argilla", Vector3(1.3, 0.12, 1.0)))
	r.add_child(sfera(0.22, Vector3(0.3, 0.0, 0.25), "argilla_cruda", Vector3(1.3, 0.08, 1.0)))
	for k in 12:
		r.add_child(scatola(Vector3(0.07, 0.03, 0.04), Vector3(-0.55 + (k % 4) * 0.09, 0.015 + (k / 4) * 0.032, 0.45), "argilla", Vector3(0, (k % 2) * 5, 0)))
	_pila_tegole(r, Vector3(-0.42, 0, 0.62), 4, 8.0, "argilla_cruda")
	# stampo di legno per i mattoni
	for lato: int in [-1, 1]:
		r.add_child(scatola(Vector3(0.12, 0.02, 0.012), Vector3(-0.2, 0.01, 0.6 + lato * 0.04), "legno"))
		r.add_child(scatola(Vector3(0.012, 0.02, 0.08), Vector3(-0.2 + lato * 0.054, 0.01, 0.6), "legno"))
	var a := attrezzo("pala")
	a.position = Vector3(0.62, 0.02, 0.05)
	a.rotation_degrees = Vector3(0, 40, 10)
	r.add_child(a)
	r.add_child(scatola(Vector3(0.18, 0.07, 0.12), Vector3(0.0, 0.035, 0.62), "blocco"))
	r.add_child(scatola(Vector3(0.15, 0.005, 0.09), Vector3(0.0, 0.071, 0.62), "acqua_pozzo"))
	_cippo(r, Vector3(-0.65, 0, 0.1), 0.9)
	return r


## Fornace romana: bottega ocra, camera di cottura quadrata di mattoni con la volta a botte e la bocca ad arco
## accesa, anfore e tegole che asciugano, argilla e legna.
static func fornace_romani() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.25, 0, -0.3)
	r.add_child(c)
	var lx := 0.6
	var lz := 0.46
	var h := 0.32
	_bottega_r(c, lx, lz, h, 761, 20.0)
	_porta_r(c, 0.12, lz * 0.5, 0.12, 0.19)
	_finestra_r(c, Vector3(-0.15, 0.3, lz * 0.5), 0.0)
	_finestra_r(c, Vector3(lx * 0.5, 0.3, 0.0), 90.0)
	var f := Vector3(0.42, 0, 0.35)
	r.add_child(scatola(Vector3(0.36, 0.2, 0.36), f + Vector3(0, 0.1, 0), "mattoni"))
	r.add_child(scatola(Vector3(0.38, 0.02, 0.38), f + Vector3(0, 0.2, 0), "blocco"))
	r.add_child(cilindro(0.17, 0.17, 0.36, f + Vector3(0, 0.21, 0), "laterizio", Vector3(0, 0, 90), 16))
	for k in 3:
		r.add_child(cilindro(0.172, 0.172, 0.02, f + Vector3(-0.12 + k * 0.12, 0.21, 0), "mattoni", Vector3(0, 0, 90), 16))
	for k in 2:
		r.add_child(scatola(Vector3(0.03, 0.012, 0.03), f + Vector3(-0.06 + k * 0.12, 0.382, 0), "buio"))
	_arco(r, f + Vector3(-0.02, 0.0, 0.185), 0.08, 0.06, 0.03, "mattoni", 0.0, "laterizio")
	r.add_child(scatola(Vector3(0.08, 0.1, 0.01), f + Vector3(-0.02, 0.05, 0.181), "brace"))
	r.add_child(scatola(Vector3(0.14, 0.05, 0.006), f + Vector3(-0.02, 0.15, 0.182), "fuliggine"))
	_fumo(r, f + Vector3(0.0, 0.42, 0.0), 3, 0.9)
	for k in 6:
		var p := Vector3(-0.6 + (k % 3) * 0.1, 0, 0.42 + (k / 3) * 0.12)
		r.add_child(anfora(p, 1.2))
		r.add_child(cilindro(0.047, 0.047, 0.015, p + Vector3(0, 0.09, 0), "fuliggine", Vector3.ZERO, 10))
	_pila_tegole(r, Vector3(-0.22, 0, 0.56), 4, 6.0)
	r.add_child(mucchio(Vector3(0.68, 0, -0.15), "argilla", 8, 9))
	legnaia(r, Vector3(0.66, 0, 0.12), 0.2, 3)
	return r


## Saline romane: vasche di evaporazione con le sponde di mattoni, cumuli di sale, casotto di mattoni con tegole, cippo.
static func saline_romani() -> Node3D:
	var r := Node3D.new()
	for i in 3:
		for j in 2:
			var p := Vector3(-0.45 + i * 0.42, 0, -0.25 + j * 0.5)
			r.add_child(scatola(Vector3(0.4, 0.04, 0.46), p + Vector3(0, 0.02, 0), "mattoni"))
			r.add_child(scatola(Vector3(0.41, 0.01, 0.47), p + Vector3(0, 0.04, 0), "laterizio"))
			var mat := "acqua_pozzo" if (i + j) % 3 != 0 else "sale"
			r.add_child(scatola(Vector3(0.34, 0.006, 0.4), p + Vector3(0, 0.045, 0), mat))
	for p: Vector3 in [Vector3(0.62, 0, 0.55), Vector3(0.42, 0, 0.62), Vector3(-0.6, 0, 0.6)]:
		r.add_child(sfera(0.1, p, "sale", Vector3(1, 0.9, 1)))
	var c := Node3D.new()
	c.position = Vector3(0.6, 0, -0.55)
	r.add_child(c)
	_muri_r(c, 0.26, 0.22, 0.14, 771, "mattoni")
	_porta_r(c, 0.0, 0.11, 0.07, 0.055)
	sottotetto(c, 0.26, 0.22, 0.21, 20.0, "mattoni")
	_tetto_r(c, 0.3, 0.22, 0.21, 20.0, 771)
	var a := attrezzo("pala")
	a.position = Vector3(0.25, 0.02, 0.45)
	a.rotation_degrees = Vector3(0, -30, 5)
	r.add_child(a)
	r.add_child(sacco(Vector3(0.0, 0, 0.62), 0.3))
	r.add_child(sacco(Vector3(-0.12, 0, 0.64), 1.2))
	_cippo(r, Vector3(0.66, 0, 0.12), 0.9)
	return r


## Tessitura romana: bottega ocra, telaio verticale con la tela a righe rosso pompeiano e i pesi di terracotta,
## matasse di lana, stoffe stese.
static func tessitura_romani() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.28)
	r.add_child(c)
	var lx := 0.72
	var lz := 0.52
	var h := 0.36
	_bottega_r(c, lx, lz, h, 781, 18.0)
	_porta_r(c, -0.16, lz * 0.5, 0.13, 0.2)
	_finestra_r(c, Vector3(0.18, 0.32, lz * 0.5), 0.0, 0.08, 0.08)
	_finestra_r(c, Vector3(lx * 0.5, 0.32, 0.0), 90.0)
	var t := Vector3(0.0, 0, 0.5)
	for x: float in [-0.18, 0.18]:
		r.add_child(cilindro(0.013, 0.013, 0.42, t + Vector3(x, 0.21, 0), "legno_scuro", Vector3.ZERO, 6))
	r.add_child(cilindro(0.012, 0.012, 0.42, t + Vector3(0, 0.4, 0), "legno", Vector3(0, 0, 90), 6))
	for k in 6:
		r.add_child(scatola(Vector3(0.34, 0.04, 0.006), t + Vector3(0, 0.355 - k * 0.04, 0), "stoffa_pompeiana" if k % 2 == 0 else "lino"))
	r.add_child(scatola(Vector3(0.34, 0.012, 0.008), t + Vector3(0, 0.375, 0.002), "moneta"))
	for k in 6:
		r.add_child(cilindro(0.007, 0.014, 0.028, t + Vector3(-0.15 + k * 0.06, 0.08, 0), "terracotta", Vector3.ZERO, 4))
	for p: Vector3 in [Vector3(0.55, 0, 0.0), Vector3(0.6, 0, 0.2)]:
		r.add_child(sfera(0.05, p + Vector3(0, 0.04, 0), "lana", Vector3(1.2, 0.8, 1)))
	r.add_child(cesta(Vector3(0.42, 0, 0.3), "lana", 0.8))
	r.add_child(cilindro(0.008, 0.008, 0.5, Vector3(0.55, 0.3, -0.35), "legno_vecchio", Vector3(0, 0, 90), 5))
	for x: float in [0.32, 0.78]:
		r.add_child(scatola(Vector3(0.03, 0.3, 0.03), Vector3(x, 0.15, -0.35), "mattoni"))
	r.add_child(scatola(Vector3(0.22, 0.2, 0.004), Vector3(0.48, 0.2, -0.35), "stoffa_pompeiana"))
	r.add_child(scatola(Vector3(0.2, 0.18, 0.004), Vector3(0.7, 0.21, -0.35), "lino"))
	return r


## Pescatore romano: casetta ocra con il tetto di tegole, reti stese, barca tirata a secco, ceste di pesce, dolio.
static func capanna_pescatore_romani() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.22, 0, -0.25)
	r.add_child(c)
	var lx := 0.66
	var lz := 0.5
	var h := 0.32
	_bottega_r(c, lx, lz, h, 791, 20.0)
	_porta_r(c, 0.12, lz * 0.5, 0.12, 0.19)
	_finestra_r(c, Vector3(-0.16, 0.3, lz * 0.5), 0.0)
	_finestra_r(c, Vector3(lx * 0.5, 0.3, 0.0), 90.0)
	_basolato(r, Vector3(-0.1, 0, 0.12), 0.26, 0.2, 792)
	_rete(r, Vector3(0.55, 0, -0.35), 0.4)
	var b := _barca(Vector3(0.35, 0, 0.45), -25, "rosso_pompeiano")
	r.add_child(b)
	for z: float in [-0.05, 0.06]:
		b.add_child(scatola(Vector3(0.5, 0.01, 0.025), Vector3(0.05, 0.14, z), "legno_chiaro", Vector3(0, 8, 4)))
	r.add_child(cesta(Vector3(-0.45, 0, 0.45), "pesce"))
	r.add_child(cesta(Vector3(-0.3, 0, 0.58), "pesce"))
	_dolio(r, Vector3(-0.62, 0, 0.25), 0.85)
	r.add_child(anfora(Vector3(-0.6, 0, 0.42), 0.9))
	for i in 3:
		r.add_child(sfera(0.02, Vector3(0.62 + i * 0.05, 0.02, 0.1 + i * 0.03), "bandiera_rossa"))
	return r


## Frantoio romano: bottega ocra, trapeto all'aperto (mortaio di pietra su podio di mattoni, pilastrino e due macine
## a mezza sfera sulla stanga), dolii per l'olio, ceste di olive, ulivo.
static func frantoio_romani() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.22)
	r.add_child(c)
	var lx := 0.82
	var lz := 0.62
	var h := 0.42
	_bottega_r(c, lx, lz, h, 801, 18.0)
	_porta_r(c, 0.18, lz * 0.5, 0.15, 0.22)
	_finestra_r(c, Vector3(-0.18, 0.36, lz * 0.5), 0.0, 0.08, 0.09)
	_finestra_r(c, Vector3(lx * 0.5, 0.36, 0.0), 90.0)
	_comignolo_r(c, Vector3(-0.22, 0.07 + h + 0.04, -0.1))
	var m := Vector3(-0.35, 0, 0.55)
	r.add_child(cilindro(0.27, 0.29, 0.06, m + Vector3(0, 0.03, 0), "mattoni", Vector3.ZERO, 24))
	r.add_child(cilindro(0.24, 0.21, 0.08, m + Vector3(0, 0.1, 0), "blocco", Vector3.ZERO, 24))
	r.add_child(cilindro(0.2, 0.2, 0.01, m + Vector3(0, 0.141, 0), "foglie_ulivo", Vector3.ZERO, 24))
	r.add_child(cilindro(0.04, 0.045, 0.12, m + Vector3(0, 0.18, 0), "blocco", Vector3.ZERO, 10))
	r.add_child(cilindro(0.012, 0.012, 0.04, m + Vector3(0, 0.25, 0), "ferro", Vector3.ZERO, 6))
	for lato: int in [-1, 1]:
		r.add_child(sfera(0.09, m + Vector3(lato * 0.1, 0.2, 0), "blocco", Vector3(0.55, 1, 1)))
	r.add_child(scatola(Vector3(0.62, 0.025, 0.025), m + Vector3(0.05, 0.25, 0), "legno_vecchio"))
	for p: Vector3 in [Vector3(0.27, 0, 0.42), Vector3(0.43, 0, 0.42), Vector3(0.35, 0, 0.56)]:
		_dolio(r, p, 0.95)
	r.add_child(anfora(Vector3(0.55, 0, 0.6), 1.1))
	for i in 3:
		r.add_child(cesta(Vector3(0.62, 0, -0.3 + i * 0.16), "olive", 0.85))
	r.add_child(anfora(Vector3(0.62, 0, 0.22), 1.15))
	r.add_child(anfora(Vector3(0.67, 0, 0.3), 1.0))
	var u := ulivo(31)
	u.position = Vector3(-0.7, 0, -0.45)
	u.scale = Vector3.ONE * 0.8
	r.add_child(u)
	return r


## Uliveto romano: casetta ocra con il tetto di tegole, ulivo con i teli stesi, ceste di olive, scala, dolio e cippo.
static func uliveto_romani() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.3, 0, -0.3)
	r.add_child(c)
	var lx := 0.58
	var lz := 0.46
	var h := 0.3
	_bottega_r(c, lx, lz, h, 811, 20.0)
	_porta_r(c, -0.08, lz * 0.5, 0.12, 0.18)
	_finestra_r(c, Vector3(lx * 0.5, 0.28, 0.0), 90.0)
	var u := ulivo(152)
	u.position = Vector3(0.35, 0, 0.3)
	u.scale = Vector3.ONE * 0.8
	r.add_child(u)
	r.add_child(scatola(Vector3(0.5, 0.004, 0.45), Vector3(0.35, 0.004, 0.3), "lino", Vector3(0, 12, 0)))
	for k in 12:
		r.add_child(sfera(0.012, Vector3(0.2 + (k % 4) * 0.08, 0.012, 0.18 + (k / 4) * 0.1), "oliva"))
	for p: Vector3 in [Vector3(-0.45, 0, 0.45), Vector3(-0.25, 0, 0.55), Vector3(0.7, 0, -0.2)]:
		r.add_child(cesta(p, "olive"))
	r.add_child(scatola(Vector3(0.03, 0.45, 0.012), Vector3(0.12, 0.22, 0.12), "legno_vecchio", Vector3(0, 0, -18)))
	r.add_child(scatola(Vector3(0.03, 0.45, 0.012), Vector3(0.12, 0.22, 0.2), "legno_vecchio", Vector3(0, 0, -18)))
	_dolio(r, Vector3(-0.62, 0, 0.25), 0.85)
	_cippo(r, Vector3(0.0, 0, 0.62), 0.9)
	return r


## Vigneto romano: casetta ocra, pergolato d'uva su pilastrini di mattoni, vasca di mattoni per pigiare, ceste di grappoli.
static func vigneto_romani() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.25, 0, -0.3)
	r.add_child(c)
	var lx := 0.66
	var lz := 0.5
	var h := 0.34
	_bottega_r(c, lx, lz, h, 821, 20.0)
	_porta_r(c, 0.1, lz * 0.5, 0.13, 0.2)
	_finestra_r(c, Vector3(-0.18, 0.32, lz * 0.5), 0.0)
	_finestra_r(c, Vector3(lx * 0.5, 0.32, 0.0), 90.0)
	for p: Vector3 in [Vector3(-0.35, 0, 0.15), Vector3(0.25, 0, 0.15), Vector3(-0.35, 0, 0.55), Vector3(0.25, 0, 0.55)]:
		r.add_child(scatola(Vector3(0.035, 0.35, 0.035), p + Vector3(0, 0.175, 0), "mattoni"))
		r.add_child(scatola(Vector3(0.048, 0.016, 0.048), p + Vector3(0, 0.355, 0), "blocco"))
	for z: float in [0.15, 0.55]:
		r.add_child(scatola(Vector3(0.66, 0.02, 0.02), Vector3(-0.05, 0.372, z), "legno"))
	for k in 4:
		r.add_child(scatola(Vector3(0.012, 0.012, 0.44), Vector3(-0.32 + k * 0.18, 0.386, 0.35), "legno_vecchio"))
	var rng := _rng(162)
	for k in 26:
		r.add_child(sfera(0.045, Vector3(rng.randf_range(-0.38, 0.28), 0.39, rng.randf_range(0.12, 0.58)), "foglie" if k % 3 else "foglie_chiare", Vector3(1, 0.5, 1)))
	for k in 6:
		r.add_child(sfera(0.022, Vector3(-0.3 + k * 0.1, 0.34, 0.35 + (k % 2) * 0.1), "uva", Vector3(1, 1.5, 1)))
	r.add_child(scatola(Vector3(0.22, 0.1, 0.22), Vector3(0.55, 0.05, 0.4), "mattoni"))
	r.add_child(scatola(Vector3(0.23, 0.014, 0.23), Vector3(0.55, 0.1, 0.4), "laterizio"))
	r.add_child(scatola(Vector3(0.18, 0.005, 0.18), Vector3(0.55, 0.105, 0.4), "uva"))
	r.add_child(cesta(Vector3(0.6, 0, 0.0), "uva"))
	r.add_child(cesta(Vector3(0.45, 0, -0.2), "uva"))
	r.add_child(anfora(Vector3(0.66, 0, 0.62), 1.0))
	return r


## Cantina romana: cella vinaria di mattoni vivi, dolii in fila, anfore, vasca di pigiatura col beccuccio, ceste d'uva.
static func cantina_romani() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.25)
	r.add_child(c)
	var lx := 0.76
	var lz := 0.56
	var h := 0.38
	_bottega_r(c, lx, lz, h, 831, 18.0, "mattoni")
	_porta_r(c, 0.15, lz * 0.5, 0.15, 0.2)
	_finestra_r(c, Vector3(-0.2, 0.34, lz * 0.5), 0.0)
	_finestra_r(c, Vector3(lx * 0.5, 0.34, 0.0), 90.0)
	r.add_child(scatola(Vector3(0.22, 0.012, 0.68), Vector3(0.6, 0.006, -0.06), "terra"))
	for k in 4:
		_dolio(r, Vector3(0.6, 0, -0.32 + k * 0.17), 1.05)
	for k in 5:
		r.add_child(anfora(Vector3(-0.6 + (k % 3) * 0.1, 0, 0.42 + (k / 3) * 0.12), 1.15))
	r.add_child(scatola(Vector3(0.36, 0.1, 0.28), Vector3(0.2, 0.05, 0.52), "mattoni"))
	r.add_child(scatola(Vector3(0.38, 0.014, 0.3), Vector3(0.2, 0.1, 0.52), "laterizio"))
	r.add_child(scatola(Vector3(0.3, 0.01, 0.22), Vector3(0.2, 0.104, 0.52), "vino"))
	r.add_child(cilindro(0.012, 0.012, 0.06, Vector3(0.2, 0.06, 0.68), "terracotta", Vector3(90, 0, 0), 8))
	_dolio(r, Vector3(0.2, -0.04, 0.74), 0.55)
	r.add_child(cesta(Vector3(-0.15, 0, 0.6), "uva"))
	return r


## Ortolano romano: casetta ocra, orto murato, trecce di cipolle appese a una trave su pilastrini di mattoni, ceste.
static func ortolano_romani() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.3, 0, -0.3)
	r.add_child(c)
	var lx := 0.58
	var lz := 0.46
	var h := 0.3
	_bottega_r(c, lx, lz, h, 841, 20.0)
	_porta_r(c, 0.08, lz * 0.5, 0.12, 0.18)
	_finestra_r(c, Vector3(-0.16, 0.28, lz * 0.5), 0.0)
	_orto_r(r, Vector3(0.45, 0, 0.0), 0.36, 0.6, 842)
	for x: float in [-0.56, -0.22]:
		r.add_child(scatola(Vector3(0.03, 0.34, 0.03), Vector3(x, 0.17, 0.05), "mattoni"))
	r.add_child(scatola(Vector3(0.38, 0.018, 0.018), Vector3(-0.39, 0.335, 0.05), "legno"))
	for k in 4:
		r.add_child(cilindro(0.003, 0.003, 0.03, Vector3(-0.5 + k * 0.08, 0.315, 0.05), "corda", Vector3.ZERO, 3))
		for i in 4:
			r.add_child(sfera(0.02, Vector3(-0.5 + k * 0.08, 0.28 - i * 0.04, 0.05), "cipolla"))
	for p: Vector3 in [Vector3(-0.4, 0, 0.45), Vector3(-0.2, 0, 0.55)]:
		r.add_child(cesta(p, "ortaggi"))
	r.add_child(cesta(Vector3(0.05, 0, 0.6), "cipolle"))
	return r


## Agrumeto romano: casetta ocra, agrumi in aiuole tonde di mattoni, ceste di frutti, cassa, cippo.
static func agrumeto_romani() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.3, 0, -0.3)
	r.add_child(c)
	var lx := 0.6
	var lz := 0.46
	var h := 0.32
	_bottega_r(c, lx, lz, h, 851, 20.0)
	_porta_r(c, -0.1, lz * 0.5, 0.12, 0.19)
	_finestra_r(c, Vector3(0.15, 0.3, lz * 0.5), 0.0)
	_finestra_r(c, Vector3(lx * 0.5, 0.3, 0.0), 90.0)
	var a := agrumi(3)
	var terra := a.get_child(0)
	a.remove_child(terra)
	terra.free()
	a.position = Vector3(0.3, 0, 0.25)
	a.scale = Vector3.ONE * 1.1
	for p: Vector3 in [Vector3(0.08, 0, 0.03), Vector3(0.542, 0, 0.448)]:
		r.add_child(cilindro(0.1, 0.1, 0.05, p + Vector3(0, 0.025, 0), "mattoni", Vector3.ZERO, 14))
		r.add_child(cilindro(0.105, 0.105, 0.012, p + Vector3(0, 0.054, 0), "laterizio", Vector3.ZERO, 14))
		r.add_child(cilindro(0.085, 0.085, 0.01, p + Vector3(0, 0.058, 0), "terra", Vector3.ZERO, 14))
	r.add_child(a)
	for p: Vector3 in [Vector3(-0.45, 0, 0.45), Vector3(-0.25, 0, 0.58), Vector3(0.7, 0, -0.25)]:
		r.add_child(cesta(p, "agrumi"))
	r.add_child(cassa(Vector3(0.65, 0, 0.1), 20))
	_cippo(r, Vector3(-0.64, 0, 0.2), 0.9)
	return r


## Pesca del pesce spada alla romana: casetta ocra, feluca con l'albero di vedetta e il bordo rosso pompeiano,
## arpione, pesce spada, anfore di garum.
static func pesca_spada_romani() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.3, 0, -0.3)
	r.add_child(c)
	var lx := 0.6
	var lz := 0.46
	var h := 0.32
	_bottega_r(c, lx, lz, h, 861, 20.0)
	_porta_r(c, 0.1, lz * 0.5, 0.12, 0.19)
	_finestra_r(c, Vector3(-0.15, 0.3, lz * 0.5), 0.0)
	_finestra_r(c, Vector3(lx * 0.5, 0.3, 0.0), 90.0)
	var b := Node3D.new()
	b.position = Vector3(0.3, 0, 0.35)
	b.rotation_degrees.y = -30
	r.add_child(b)
	b.add_child(sfera(0.15, Vector3(0, 0.07, 0), "legno", Vector3(2.8, 0.7, 1.0)))
	b.add_child(sfera(0.13, Vector3(0, 0.1, 0), "legno_scuro", Vector3(2.7, 0.35, 0.9)))
	b.add_child(scatola(Vector3(0.8, 0.02, 0.03), Vector3(0, 0.14, 0.13), "rosso_pompeiano"))
	b.add_child(scatola(Vector3(0.8, 0.02, 0.03), Vector3(0, 0.14, -0.13), "rosso_pompeiano"))
	for lato: int in [-1, 1]:
		b.add_child(sfera(0.018, Vector3(0.33, 0.11, lato * 0.105), "marmo", Vector3(1, 0.8, 0.4)))
		b.add_child(sfera(0.009, Vector3(0.335, 0.11, lato * 0.11), "buio", Vector3(1, 1, 0.4)))
	b.add_child(cilindro(0.01, 0.008, 0.6, Vector3(0.0, 0.42, 0), "legno_vecchio", Vector3.ZERO, 6))
	for k in 5:
		b.add_child(scatola(Vector3(0.08, 0.006, 0.01), Vector3(0.0, 0.2 + k * 0.08, 0.0), "legno_vecchio"))
	b.add_child(scatola(Vector3(0.45, 0.012, 0.02), Vector3(0.55, 0.13, 0), "legno_chiaro"))
	r.add_child(scatola(Vector3(0.02, 0.012, 0.5), Vector3(-0.6, 0.15, 0.4), "ferro", Vector3(0, 0, 4)))
	for z: float in [0.2, 0.6]:
		r.add_child(scatola(Vector3(0.03, 0.14, 0.03), Vector3(-0.6, 0.07, z), "mattoni"))
	var sp := pesce_spada_modello()
	sp.position = Vector3(-0.35, 0.02, 0.55)
	r.add_child(sp)
	r.add_child(anfora(Vector3(-0.66, 0, 0.0), 1.0))
	r.add_child(anfora(Vector3(-0.58, 0, -0.06), 0.9))
	return r


## Miniera romana: fianco di roccia con l'imbocco ad arco di mattoni e la lapide, selciato di basoli
## con il carrello del minerale, mucchio di minerale, lucerna su palo, puntelli di scorta, cippo.
static func miniera_ferro_romani(minerale := "minerale") -> Node3D:
	var r := Node3D.new()
	r.add_child(sfera(0.6, Vector3(-0.25, 0.0, -0.3), "roccia_massi", Vector3(1.2, 0.75, 1.0)))
	r.add_child(sfera(0.35, Vector3(0.35, 0.0, -0.45), "roccia_massi", Vector3(1.1, 0.8, 1.0)))
	r.add_child(sfera(0.3, Vector3(-0.65, 0.0, 0.15), "roccia_massi", Vector3(1.0, 0.7, 1.0)))
	var imb := Vector3(-0.05, 0, 0.18)
	r.add_child(scatola(Vector3(0.22, 0.24, 0.1), imb + Vector3(0, 0.12, 0), "buio"))
	r.add_child(cilindro(0.11, 0.11, 0.1, imb + Vector3(0, 0.22, 0), "buio", Vector3(90, 0, 0), 14))
	_arco(r, imb + Vector3(0, 0, 0.055), 0.2, 0.22, 0.05, "mattoni", 0.0, "laterizio")
	r.add_child(scatola(Vector3(0.42, 0.03, 0.07), imb + Vector3(0, 0.015, 0.055), "blocco"))
	r.add_child(scatola(Vector3(0.15, 0.05, 0.012), imb + Vector3(0, 0.4, 0.085), "marmo"))
	for k in 2:
		r.add_child(scatola(Vector3(0.11 - k * 0.04, 0.008, 0.006), imb + Vector3(0, 0.41 - k * 0.02, 0.092), "rosso_pompeiano"))
	_basolato(r, imb + Vector3(0, 0, 0.36), 0.22, 0.46, 3121)
	var carr := Vector3(-0.05, 0, 0.5)
	r.add_child(scatola(Vector3(0.14, 0.08, 0.18), carr + Vector3(0, 0.08, 0), "legno"))
	r.add_child(mucchio(carr + Vector3(0, 0.11, 0), minerale, 6, 3, 0.03))
	for x: float in [-0.075, 0.075]:
		for z: float in [-0.06, 0.06]:
			r.add_child(cilindro(0.025, 0.025, 0.012, carr + Vector3(x, 0.038, z), "legno_scuro", Vector3(0, 0, 90), 8))
	r.add_child(mucchio(Vector3(0.45, 0, 0.35), minerale, 14, 4))
	r.add_child(cilindro(0.01, 0.01, 0.3, Vector3(0.22, 0.15, 0.3), "legno_vecchio", Vector3.ZERO, 5))
	r.add_child(sfera(0.022, Vector3(0.22, 0.31, 0.3), "bronzo", Vector3(1.4, 0.6, 1)))
	r.add_child(sfera(0.012, Vector3(0.24, 0.33, 0.3), "miele"))
	for k in 4:
		r.add_child(cilindro(0.018, 0.018, 0.4, Vector3(-0.55 + k * 0.045, 0.02 + (k % 2) * 0.03, 0.55), "legno_vecchio", Vector3(0, 70, 90), 6))
	_cippo(r, Vector3(0.62, 0, 0.08), 0.9)
	return r


## Carbonaia romana: casotto di mattoni con il tetto di tegole, cupola di legna coperta di terra che fuma,
## legna, carbone pronto, sacco e cippo.
static func carbonaia_romani() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.38, 0, -0.35)
	r.add_child(c)
	_muri_r(c, 0.4, 0.32, 0.22, 871, "mattoni")
	_porta_r(c, 0.05, 0.16, 0.1, 0.11)
	sottotetto(c, 0.4, 0.32, 0.29, 22.0, "mattoni")
	_tetto_r(c, 0.44, 0.32, 0.29, 22.0, 871)
	var m := Vector3(0.22, 0, 0.2)
	r.add_child(sfera(0.36, m, "terra", Vector3(1, 0.7, 1)))
	r.add_child(sfera(0.3, m + Vector3(0, 0.03, 0), "fuliggine", Vector3(1, 0.7, 1)))
	r.add_child(sfera(0.37, m + Vector3(0, -0.01, 0), "terra", Vector3(1, 0.68, 1)))
	for k in 5:
		r.add_child(sfera(0.05 + k * 0.012, m + Vector3(0.02 * k, 0.28 + k * 0.07, -0.01 * k), "fumo", Vector3(1, 0.8, 1)))
	r.add_child(scatola(Vector3(0.06, 0.04, 0.04), m + Vector3(0.0, 0.12, 0.33), "buio"))
	legnaia(r, Vector3(-0.55, 0, 0.35), 0.35, 4)
	r.add_child(mucchio(Vector3(0.62, 0, -0.25), "carbone", 12, 5))
	r.add_child(sacco(Vector3(0.6, 0, 0.55), 0.4))
	_cippo(r, Vector3(-0.2, 0, 0.62), 0.9)
	return r


## Fonderia romana: officina di mattoni vivi, forno a torre di mattoni con i ricorsi di laterizio e la bocca ad arco
## accesa, mantice, lingotti, carbone e minerale.
static func fonderia_romani() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.25, 0, -0.25)
	r.add_child(c)
	var lx := 0.66
	var lz := 0.52
	var h := 0.36
	_bottega_r(c, lx, lz, h, 881, 18.0, "mattoni")
	_porta_r(c, -0.12, lz * 0.5, 0.14, 0.2)
	_finestra_r(c, Vector3(lx * 0.5, 0.32, 0.0), 90.0)
	var f := Vector3(0.42, 0, 0.38)
	r.add_child(cilindro(0.17, 0.2, 0.5, f + Vector3(0, 0.25, 0), "mattoni", Vector3.ZERO, 16))
	for y: float in [0.16, 0.32]:
		var rr := 0.2 - y / 0.5 * 0.03 + 0.006
		r.add_child(cilindro(rr, rr, 0.016, f + Vector3(0, y, 0), "laterizio", Vector3.ZERO, 16))
	r.add_child(cilindro(0.185, 0.185, 0.025, f + Vector3(0, 0.5, 0), "blocco", Vector3.ZERO, 16))
	r.add_child(cilindro(0.13, 0.15, 0.08, f + Vector3(0, 0.54, 0), "fuliggine", Vector3.ZERO, 16))
	_arco(r, f + Vector3(0.085, 0.0, 0.18), 0.08, 0.07, 0.04, "mattoni", 25.0, "laterizio")
	r.add_child(scatola(Vector3(0.08, 0.11, 0.02), f + Vector3(0.08, 0.055, 0.172), "brace", Vector3(0, 25, 0)))
	_fumo(r, f + Vector3(0.0, 0.62, 0.0), 4, 1.1)
	r.add_child(sfera(0.07, f + Vector3(-0.28, 0.1, 0.05), "pelle_scura", Vector3(1.4, 0.5, 1.0)))
	r.add_child(scatola(Vector3(0.1, 0.012, 0.02), f + Vector3(-0.19, 0.1, 0.05), "legno_scuro"))
	for k in 6:
		r.add_child(scatola(Vector3(0.09, 0.025, 0.035), Vector3(-0.45 + (k % 3) * 0.1, 0.013 + (k / 3) * 0.026, 0.55), "lingotto"))
	r.add_child(mucchio(Vector3(-0.62, 0, 0.25), "carbone", 9, 6))
	r.add_child(mucchio(Vector3(0.68, 0, -0.1), "minerale", 9, 7))
	return r


## Fabbro romano: bottega ocra con il comignolo, fucina di mattoni sotto una tettoia di tegole su pilastri,
## incudine sul ceppo, attrezzi appesi, vasca di pietra con l'acqua, lingotti.
static func fabbro_romani() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.28)
	r.add_child(c)
	var lx := 0.72
	var lz := 0.5
	var h := 0.38
	_bottega_r(c, lx, lz, h, 891, 18.0)
	_porta_r(c, 0.16, lz * 0.5, 0.13, 0.2)
	_finestra_r(c, Vector3(-0.18, 0.34, lz * 0.5), 0.0)
	_finestra_r(c, Vector3(lx * 0.5, 0.34, 0.0), 90.0)
	_comignolo_r(c, Vector3(-0.22, 0.07 + h + 0.04, -0.05), 0.2)
	_tettoia_r(r, Vector3(-0.2, 0, 0.45), 0.66, 0.3, 0.32, 892)
	r.add_child(scatola(Vector3(0.2, 0.12, 0.16), Vector3(-0.38, 0.06, 0.42), "mattoni"))
	r.add_child(scatola(Vector3(0.22, 0.016, 0.18), Vector3(-0.38, 0.128, 0.42), "blocco"))
	r.add_child(scatola(Vector3(0.14, 0.01, 0.1), Vector3(-0.38, 0.14, 0.42), "brace"))
	r.add_child(scatola(Vector3(0.06, 0.05, 0.012), Vector3(-0.38, 0.05, 0.505), "brace"))
	r.add_child(cilindro(0.04, 0.05, 0.08, Vector3(-0.05, 0.04, 0.45), "corteccia", Vector3.ZERO, 10))
	r.add_child(scatola(Vector3(0.12, 0.04, 0.05), Vector3(-0.05, 0.1, 0.45), "ferro"))
	r.add_child(scatola(Vector3(0.04, 0.025, 0.035), Vector3(0.03, 0.1, 0.45), "ferro"))
	r.add_child(scatola(Vector3(0.6, 0.018, 0.018), Vector3(-0.2, 0.3, 0.3), "legno"))
	for k in 4:
		var a := attrezzo(ATTREZZI_FABBRO[k])
		a.position = Vector3(-0.42 + k * 0.1, 0.22, 0.31)
		a.rotation_degrees = Vector3(90, 0, 90)
		r.add_child(a)
	r.add_child(scatola(Vector3(0.15, 0.08, 0.15), Vector3(0.62, 0.04, 0.1), "blocco"))
	r.add_child(scatola(Vector3(0.12, 0.005, 0.12), Vector3(0.62, 0.081, 0.1), "acqua_pozzo"))
	for k in 3:
		r.add_child(scatola(Vector3(0.09, 0.025, 0.035), Vector3(0.45, 0.013 + k * 0.026, 0.45), "lingotto"))
	return r


## Armaiolo romano: la bottega del fabbro con la rastrelliera di pili, gli scudi rossi appoggiati e un elmo crestato.
static func armaiolo_romani() -> Node3D:
	var r := fabbro_romani()
	r.add_child(scatola(Vector3(0.28, 0.03, 0.05), Vector3(0.48, 0.015, 0.32), "legno_scuro"))
	r.add_child(scatola(Vector3(0.28, 0.02, 0.03), Vector3(0.48, 0.34, 0.31), "legno_scuro"))
	for k in 5:
		var x := 0.38 + k * 0.05
		r.add_child(cilindro(0.006, 0.006, 0.4, Vector3(x, 0.2, 0.32), "legno", Vector3.ZERO, 5))
		r.add_child(cilindro(0.003, 0.003, 0.12, Vector3(x, 0.46, 0.32), "ferro", Vector3.ZERO, 4))
		r.add_child(cilindro(0.008, 0.0, 0.03, Vector3(x, 0.535, 0.32), "ferro", Vector3.ZERO, 4))
	r.add_child(_scuto(Vector3(0.66, 0, 0.3), 135.0))
	r.add_child(_scuto(Vector3(0.6, 0, 0.42), 150.0, 0.95))
	r.add_child(cilindro(0.006, 0.006, 0.28, Vector3(0.3, 0.14, 0.6), "legno", Vector3.ZERO, 5))
	r.add_child(sfera(0.035, Vector3(0.3, 0.3, 0.6), "bronzo", Vector3(1, 0.85, 1.1)))
	r.add_child(scatola(Vector3(0.012, 0.04, 0.07), Vector3(0.3, 0.345, 0.6), "stoffa_pompeiana"))
	return r


## Zecca romana: edificio ocra con il portichetto di due colonne di marmo e l'architrave iscritto, basoli,
## casse di monete, incudine per coniare, argento grezzo, legionario di guardia, vessillo.
static func zecca_romani() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.25)
	r.add_child(c)
	var lx := 0.74
	var lz := 0.56
	var h := 0.42
	_muri_r(c, lx, lz, h, 901)
	_porta_r(c, 0.0, lz * 0.5, 0.15, 0.22)
	_finestra_r(c, Vector3(lx * 0.5, 0.38, 0.12), 90.0)
	_finestra_r(c, Vector3(lx * 0.5, 0.38, -0.14), 90.0)
	for x: float in [-0.25, 0.25]:
		c.add_child(scatola(Vector3(0.07, 0.03, 0.07), Vector3(x, 0.085, lz * 0.5 + 0.07), "blocco"))
		_colonna(c, Vector3(x, 0.1, lz * 0.5 + 0.07), h - 0.08, 0.026)
	c.add_child(scatola(Vector3(lx - 0.04, 0.05, 0.12), Vector3(0, 0.07 + h - 0.015, lz * 0.5 + 0.05), "marmo"))
	for k in 2:
		c.add_child(scatola(Vector3(0.36 - k * 0.12, 0.01, 0.006), Vector3(0, 0.07 + h - 0.005 - k * 0.02, lz * 0.5 + 0.112), "rosso_pompeiano"))
	sottotetto(c, lx, lz, 0.07 + h, 18.0, "intonaco_ocra")
	_tetto_r(c, lx + 0.06, lz, 0.07 + h, 18.0, 901)
	_comignolo_r(c, Vector3(0.24, 0.07 + h + 0.04, -0.12), 0.16)
	_basolato(r, Vector3(-0.2, 0, 0.3), 0.5, 0.3, 902)
	for k in 3:
		r.add_child(cassa(Vector3(0.45 + k * 0.12, 0, 0.4), k * 15, 0.1))
		r.add_child(cilindro(0.035, 0.035, 0.01, Vector3(0.45 + k * 0.12, 0.085, 0.4), "moneta", Vector3.ZERO, 10))
	r.add_child(cilindro(0.04, 0.05, 0.08, Vector3(-0.35, 0.04, 0.5), "corteccia", Vector3.ZERO, 10))
	r.add_child(scatola(Vector3(0.1, 0.035, 0.05), Vector3(-0.35, 0.095, 0.5), "ferro"))
	r.add_child(mucchio(Vector3(-0.62, 0, 0.25), "argento_grezzo", 8, 10))
	var g := legionario()
	g.position = Vector3(0.15, 0, 0.5)
	g.scale = Vector3.ONE * 0.9
	r.add_child(g)
	_vessillo(r, Vector3(0.66, 0, 0.12), 0.55)
	return r


## Porto romano: banchina di mattoni e travertino lastricata di basoli, pontile di legno sul mare, bitte,
## magazzino ocra con il portico su pilastri di mattoni, anfore, dolio, casse, gru di legno, vela a strisce rosse, vessillo.
static func porto_romani() -> Node3D:
	var r := Node3D.new()
	var rng := _rng(2911)
	r.add_child(scatola(Vector3(0.42, 0.1, 1.08), Vector3(0.36, 0.05, 0.02), "mattoni"))
	r.add_child(scatola(Vector3(0.44, 0.018, 1.1), Vector3(0.36, 0.06, 0.02), "blocco"))
	r.add_child(scatola(Vector3(0.46, 0.022, 1.12), Vector3(0.36, 0.111, 0.02), "blocco"))
	_basolato(r, Vector3(0.36, 0.116, 0.02), 0.4, 1.06, 2912)
	var pz := 0.26
	for k in 4:
		var x := 0.66 + k * 0.13
		for s: int in [-1, 1]:
			r.add_child(cilindro(0.017, 0.019, 0.26, Vector3(x, -0.01, pz + s * 0.12), "legno_vecchio", Vector3.ZERO, 7))
			r.add_child(cilindro(0.02, 0.02, 0.012, Vector3(x, 0.01, pz + s * 0.12), "foglie_scure", Vector3.ZERO, 7))
	for s: int in [-1, 1]:
		r.add_child(scatola(Vector3(0.5, 0.025, 0.02), Vector3(0.82, 0.095, pz + s * 0.12), "legno_scuro"))
	for k in 13:
		var x := 0.59 + k * 0.038
		r.add_child(scatola(Vector3(0.034, 0.014, 0.28), Vector3(x, 0.112 + rng.randf_range(-0.003, 0.003), pz), "legno" if k % 3 else "legno_chiaro", Vector3(0, rng.randf_range(-2, 2), 0)))
	for z: float in [-0.42, -0.08, 0.5]:
		r.add_child(cilindro(0.022, 0.026, 0.07, Vector3(0.54, 0.165, z), "blocco", Vector3.ZERO, 10))
		r.add_child(cilindro(0.03, 0.03, 0.014, Vector3(0.54, 0.203, z), "blocco", Vector3.ZERO, 10))
	for x: float in [0.72, 1.02]:
		for s: int in [-1, 1]:
			r.add_child(cilindro(0.014, 0.016, 0.07, Vector3(x, 0.155, pz + s * 0.125), "legno_scuro", Vector3.ZERO, 7))
	r.add_child(cilindro(0.03, 0.03, 0.014, Vector3(0.54, 0.182, -0.08), "corda", Vector3.ZERO, 10))
	ramo(r, Vector3(0.54, 0.18, -0.08), Vector3(0.66, 0.02, -0.02), 0.005, "corda")
	ramo(r, Vector3(1.02, 0.17, pz + 0.125), Vector3(1.1, 0.03, pz + 0.2), 0.005, "corda")
	# magazzino del porto con il portico su pilastri di mattoni
	var c := Node3D.new()
	c.position = Vector3(-0.28, 0, -0.26)
	r.add_child(c)
	var lx := 0.62
	var lz := 0.4
	var h := 0.32
	_muri_r(c, lx, lz, h, 2913)
	_porta_r(c, -0.1, lz * 0.5, 0.14, 0.18)
	_finestra_r(c, Vector3(lx * 0.5, 0.3, 0.0), 90.0)
	var pd := 0.2
	c.add_child(scatola(Vector3(lx + 0.06, 0.06, pd + 0.02), Vector3(0, 0.03, lz * 0.5 + pd * 0.5), "mattoni"))
	c.add_child(scatola(Vector3(lx + 0.08, 0.02, pd + 0.04), Vector3(0, 0.07, lz * 0.5 + pd * 0.5), "blocco"))
	for k in 4:
		var x := -lx * 0.5 + 0.04 + k * (lx - 0.08) / 3.0
		c.add_child(scatola(Vector3(0.045, h - 0.02, 0.045), Vector3(x, 0.08 + (h - 0.02) * 0.5, lz * 0.5 + pd - 0.03), "mattoni"))
		c.add_child(scatola(Vector3(0.058, 0.02, 0.058), Vector3(x, 0.08 + h - 0.03, lz * 0.5 + pd - 0.03), "blocco"))
	c.add_child(scatola(Vector3(lx + 0.04, 0.04, 0.05), Vector3(0, 0.08 + h - 0.0, lz * 0.5 + pd - 0.03), "mattoni"))
	c.add_child(scatola(Vector3(lx + 0.05, 0.012, 0.055), Vector3(0, 0.08 + h - 0.02, lz * 0.5 + pd - 0.03), "laterizio"))
	var tt := Node3D.new()
	tt.position = Vector3(0, 0, pd * 0.5)
	c.add_child(tt)
	sottotetto(tt, lx, lz + pd, 0.07 + h + 0.03, 18.0, "intonaco_ocra")
	_tetto_r(tt, lx + 0.06, lz + pd, 0.07 + h + 0.03, 18.0, 2913)
	for i in 4:
		c.add_child(anfora(Vector3(0.06 + i * 0.06, 0.08, lz * 0.5 + 0.07), 0.85))
	c.add_child(sacco(Vector3(-0.22, 0.08, lz * 0.5 + 0.08), 0.3))
	_basolato(r, Vector3(-0.12, 0, 0.32), 0.62, 0.5, 2914)
	var ra := Node3D.new()
	ra.position = Vector3(-0.42, 0, 0.34)
	r.add_child(ra)
	ra.add_child(scatola(Vector3(0.3, 0.02, 0.2), Vector3(0, 0.02, 0), "legno_scuro"))
	for f in 3:
		for k in 3 - f:
			var a := anfora(Vector3((k - (2 - f) * 0.5) * 0.085, 0.07 + f * 0.072, -0.07), 0.8)
			a.rotation_degrees.x = 90
			ra.add_child(a)
	for k in 3:
		ra.add_child(anfora(Vector3(-0.1 + k * 0.1, 0.03, 0.12), 0.9))
	r.add_child(cassa(Vector3(0.06, 0.012, 0.42), 10))
	r.add_child(cassa(Vector3(0.18, 0.012, 0.44), -15))
	r.add_child(cassa(Vector3(0.11, 0.1, 0.43), 30, 0.1))
	r.add_child(scatola(Vector3(0.1, 0.004, 0.1), Vector3(0.11, 0.182, 0.43), "corda", Vector3(0, 30, 0)))
	_dolio(r, Vector3(-0.06, 0.012, 0.54), 0.75)
	r.add_child(cesta(Vector3(0.28, 0.14, 0.4), "pesce", 0.8))
	# gru di legno sulla banchina con un carico di anfore appeso
	var g := Node3D.new()
	g.position = Vector3(0.42, 0.14, -0.28)
	r.add_child(g)
	var cima := Vector3(0.36, 0.62, 0.0)
	for s: int in [-1, 1]:
		ramo(g, Vector3(-0.04, 0, s * 0.12), cima, 0.016, "legno")
	ramo(g, Vector3(-0.22, 0, 0), cima + Vector3(-0.02, -0.02, 0), 0.012, "legno_vecchio")
	g.add_child(scatola(Vector3(0.02, 0.02, 0.26), Vector3(0.06, 0.18, 0), "legno_scuro"))
	g.add_child(cilindro(0.03, 0.03, 0.2, Vector3(0.0, 0.1, 0), "legno_scuro", Vector3(90, 0, 0), 10))
	g.add_child(cilindro(0.032, 0.032, 0.06, Vector3(0.0, 0.1, 0), "corda", Vector3(90, 0, 0), 10))
	g.add_child(cilindro(0.025, 0.025, 0.04, cima, "legno_chiaro", Vector3(90, 0, 0), 10))
	ramo(g, Vector3(0.0, 0.12, 0), cima, 0.004, "corda")
	ramo(g, cima, cima + Vector3(0, -0.34, 0), 0.004, "corda")
	var rete := Node3D.new()
	rete.position = cima + Vector3(0, -0.42, 0)
	g.add_child(rete)
	rete.add_child(scatola(Vector3(0.09, 0.006, 0.09), Vector3.ZERO, "legno_chiaro"))
	for k in 2:
		rete.add_child(anfora(Vector3(-0.022 + k * 0.044, 0.003, 0), 0.6))
	for s: int in [-1, 1]:
		ramo(rete, Vector3(s * 0.045, 0, 0), Vector3(0, 0.08, 0), 0.003, "corda")
	# vela arrotolata a strisce rosse su un pennone
	var v := Node3D.new()
	v.position = Vector3(0.3, 0.14, 0.1)
	v.rotation_degrees.y = 8
	r.add_child(v)
	v.add_child(cilindro(0.008, 0.008, 0.5, Vector3(0, 0.02, 0), "legno_chiaro", Vector3(90, 0, 0), 6))
	for k in 7:
		v.add_child(cilindro(0.032, 0.032, 0.06, Vector3(0, 0.034, -0.18 + k * 0.06), "lino" if k % 2 == 0 else "stoffa_pompeiana", Vector3(90, 0, 0), 10))
	for k in 4:
		v.add_child(cilindro(0.035, 0.035, 0.008, Vector3(0, 0.034, -0.15 + k * 0.1), "corda", Vector3(90, 0, 0), 10))
	r.add_child(cilindro(0.04, 0.04, 0.02, Vector3(0.2, 0.15, -0.48), "corda", Vector3.ZERO, 12))
	r.add_child(cilindro(0.02, 0.02, 0.022, Vector3(0.2, 0.151, -0.48), "legno_scuro", Vector3.ZERO, 8))
	var an := _ancora_nave(Vector3(0.88, 0.12, pz), 90)
	an.scale = Vector3.ONE * 0.6
	r.add_child(an)
	_vessillo(r, Vector3(0.52, 0.14, 0.42), 0.48)
	return r


# =================================================================== SARACENI (step 21)
# Intonaco di calce chiaro e terra cruda, terrazze piatte con i merli a gradini, cupole di maiolica verde,
# archi a ferro di cavallo con i conci bianchi e rossi, giardini con agrumi, palme e canalette d'acqua,
# maioliche e tende a strisce; colore del popolo: verde smeraldo.

## Texture a strisce verticali (lungo U) per le tende, con un filo più scuro sul bordo di ogni striscia.
static func _strisce_tex(c1: Color, c2: Color, n := 8, dim := 64) -> ImageTexture:
	var img := Image.create(dim, dim, false, Image.FORMAT_RGBA8)
	var larg := dim / n
	for y in dim:
		for x in dim:
			var c := c1 if (x / larg) % 2 == 0 else c2
			if x % larg == 0:
				c = c.darkened(0.18)
			img.set_pixel(x, y, c.darkened(0.05 * float((x * 7 + y * 13) % 5) / 5.0))
	img.generate_mipmaps()
	return ImageTexture.create_from_image(img)


## Texture di maiolica a mosaico: piastrelle bianche con stelle a rombo verdi, blu e ocra, fughe grigie.
static func _zellige_tex(dim := 128) -> ImageTexture:
	var img := Image.create(dim, dim, false, Image.FORMAT_RGBA8)
	var colori := [Color("0f8a5c"), Color("1f4f9a"), Color("0f8a5c"), Color("d09a2a")]
	var lato := 16
	for y in dim:
		for x in dim:
			var cx := x / lato
			var cy := y / lato
			var lx := x % lato
			var ly := y % lato
			var c := Color("f2ecdc")
			var d := absi(lx - lato / 2) + absi(ly - lato / 2)
			if d < 6:
				c = colori[(cx + cy * 2) % 4]
			elif d < 7:
				c = Color("7a6a50")
			elif (lx < 3 and ly < 3) or (lx > lato - 3 and ly > lato - 3) or (lx < 3 and ly > lato - 3) or (lx > lato - 3 and ly < 3):
				c = Color("b8322a")
			if lx == 0 or ly == 0:
				c = Color("8a8274")
			img.set_pixel(x, y, c)
	img.generate_mipmaps()
	return ImageTexture.create_from_image(img)


## Anello (toro) per matasse, ciambelle di corda e cerchi.
static func _toro(r_in: float, r_out: float, pos: Vector3, mat: String, rot := Vector3.ZERO, scala := Vector3.ONE) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var tm := TorusMesh.new()
	tm.inner_radius = r_in
	tm.outer_radius = r_out
	tm.rings = 16
	tm.ring_segments = 8
	mi.mesh = tm
	mi.position = pos
	mi.rotation_degrees = rot
	mi.scale = scala
	mi.material_override = materiale(mat)
	return mi


## Fila di merli a gradini (tre scalini, come nelle mura saracene) da un punto a un altro, alla quota di `da`.
static func _fila_merli(r: Node3D, da: Vector3, a: Vector3, mat := "calce", s := 1.0) -> void:
	var d := a - da
	d.y = 0.0
	var lung := d.length()
	var n := Node3D.new()
	n.position = Vector3((da.x + a.x) * 0.5, da.y, (da.z + a.z) * 0.5)
	n.rotation.y = atan2(-d.z, d.x)
	r.add_child(n)
	var nm := maxi(2, int(lung / (0.075 * s)))
	for k in nm:
		var x := -lung * 0.5 + (k + 0.5) * lung / nm
		n.add_child(scatola(Vector3(0.044 * s, 0.026 * s, 0.03 * s), Vector3(x, 0.013 * s, 0), mat))
		n.add_child(scatola(Vector3(0.029 * s, 0.02 * s, 0.03 * s), Vector3(x, 0.036 * s, 0), mat))
		n.add_child(scatola(Vector3(0.014 * s, 0.016 * s, 0.03 * s), Vector3(x, 0.054 * s, 0), mat))


## Parapetto della terrazza piatta (base alla quota y), con o senza i merli a gradini.
static func _parapetto_s(r: Node3D, lx: float, lz: float, y: float, merli := true, mat := "calce", hp := 0.045, s := 0.72) -> void:
	var sp := 0.03
	for lato: int in [-1, 1]:
		r.add_child(scatola(Vector3(lx, hp, sp), Vector3(0, y + hp * 0.5, lato * (lz * 0.5 - sp * 0.5)), mat))
		r.add_child(scatola(Vector3(sp, hp, lz), Vector3(lato * (lx * 0.5 - sp * 0.5), y + hp * 0.5, 0), mat))
	if merli:
		var yy := y + hp
		var ex := lx * 0.5 - sp * 0.5
		var ez := lz * 0.5 - sp * 0.5
		_fila_merli(r, Vector3(-ex, yy, ez), Vector3(ex, yy, ez), mat, s)
		_fila_merli(r, Vector3(ex, yy, -ez), Vector3(ex, yy, ez), mat, s)
		_fila_merli(r, Vector3(-ex, yy, -ez), Vector3(ex, yy, -ez), mat, s)
		_fila_merli(r, Vector3(-ex, yy, -ez), Vector3(-ex, yy, ez), mat, s)


## Muri saraceni: zoccolo di terra cruda, muri lisci di calce (o di terra cruda), intonaco caduto qua e là,
## fascia di maiolica sotto la cornice, teste di travi sporgenti, doccione con la colatura e terrazza piatta
## con il pavimento di cotto e il parapetto. Restituisce la quota del pavimento della terrazza.
static func _muri_s(r: Node3D, lx: float, lz: float, h: float, seme: int, mat := "calce", merli := true, fascia := true) -> float:
	var rng := _rng(seme)
	r.add_child(scatola(Vector3(lx + 0.05, 0.07, lz + 0.05), Vector3(0, 0.035, 0), "terra_cruda"))
	r.add_child(scatola(Vector3(lx, h, lz), Vector3(0, 0.07 + h * 0.5, 0), mat))
	var top := 0.07 + h
	if mat == "calce":
		# intonaco caduto: si vedono i mattoni crudi
		for k in 3:
			var w := rng.randf_range(0.07, 0.13)
			var hh := rng.randf_range(0.04, 0.07)
			var y := rng.randf_range(0.11, top - 0.14)
			if k < 2:
				r.add_child(scatola(Vector3(w, hh, 0.01), Vector3(rng.randf_range(-lx * 0.4, lx * 0.4), y, lz * 0.5 + 0.002), "mattoni_crudi"))
			else:
				r.add_child(scatola(Vector3(0.01, hh, w), Vector3(lx * 0.5 + 0.002, y, rng.randf_range(-lz * 0.4, lz * 0.4)), "mattoni_crudi"))
	if fascia:
		r.add_child(scatola(Vector3(lx + 0.008, 0.032, lz + 0.008), Vector3(0, top - 0.042, 0), "zellige"))
	r.add_child(scatola(Vector3(lx + 0.03, 0.022, lz + 0.03), Vector3(0, top - 0.011, 0), "terra_cruda" if mat == "calce" else "calce"))
	# teste di travi sui lati in vista
	var nt := int(lx / 0.11)
	for i in nt:
		r.add_child(cilindro(0.011, 0.011, 0.05, Vector3(-lx * 0.5 + (i + 0.5) * lx / nt, top - 0.078, lz * 0.5 + 0.012), "legno_vecchio", Vector3(90, 0, 0), 6))
	var ntz := int(lz / 0.11)
	for i in ntz:
		r.add_child(cilindro(0.011, 0.011, 0.05, Vector3(lx * 0.5 + 0.012, top - 0.078, -lz * 0.5 + (i + 0.5) * lz / ntz), "legno_vecchio", Vector3(0, 0, 90), 6))
	# doccione di terracotta con la colatura scura
	var dz := rng.randf_range(-lz * 0.3, lz * 0.3)
	r.add_child(cilindro(0.012, 0.014, 0.09, Vector3(lx * 0.5 + 0.04, top + 0.01, dz), "terracotta", Vector3(0, 0, 80), 6))
	r.add_child(scatola(Vector3(0.004, top * 0.6, 0.025), Vector3(lx * 0.5 + 0.002, top * 0.6, dz), "intonaco_sporco"))
	# pavimento di cotto e parapetto
	r.add_child(scatola(Vector3(lx - 0.05, 0.006, lz - 0.05), Vector3(0, top + 0.003, 0), "battuto"))
	_parapetto_s(r, lx + 0.02, lz + 0.02, top, merli, "calce" if mat == "calce" else "terra_cruda")
	return top


## Porta ad arco a ferro di cavallo (nel nodo locale guarda verso +Z): conci bianchi e rossi alternati,
## alfiz di maiolica intorno, battente di legno verde borchiato (o vano aperto), gradino fino a terra.
## pos è il piede della porta sulla facciata (y = quota della soglia).
static func _porta_s(r: Node3D, pos: Vector3, rot_y := 0.0, w := 0.13, h := 0.15, aperta := false) -> void:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot_y
	r.add_child(n)
	var rg := w * 0.58
	var cy := h + rg * 0.51
	var ax := rg + 0.036
	var atop := cy + rg + 0.034
	n.add_child(scatola(Vector3(ax * 2 + 0.018, 0.018, 0.012), Vector3(0, atop, 0.006), "zellige"))
	for lato: int in [-1, 1]:
		n.add_child(scatola(Vector3(0.018, atop - h * 0.55, 0.012), Vector3(lato * ax, h * 0.55 + (atop - h * 0.55) * 0.5, 0.006), "zellige"))
	n.add_child(scatola(Vector3(w, h, 0.014), Vector3(0, h * 0.5, 0.004), "buio"))
	n.add_child(cilindro(rg, rg, 0.014, Vector3(0, cy, 0.004), "buio", Vector3(90, 0, 0), 20))
	if not aperta:
		n.add_child(scatola(Vector3(w * 0.9, h, 0.012), Vector3(0, h * 0.5, 0.008), "legno_verde"))
		n.add_child(cilindro(rg * 0.84, rg * 0.84, 0.012, Vector3(0, cy, 0.008), "legno_verde", Vector3(90, 0, 0), 20))
		n.add_child(scatola(Vector3(0.006, h + rg * 0.8, 0.008), Vector3(0, (h + rg * 0.8) * 0.5, 0.016), "legno_scuro"))
		for i in 2:
			for j in 3:
				n.add_child(sfera(0.0065, Vector3((i - 0.5) * w * 0.5, 0.035 + j * h * 0.32, 0.016), "moneta"))
		n.add_child(_toro(0.008, 0.013, Vector3(w * 0.18, h * 0.55, 0.018), "ferro", Vector3(90, 0, 0)))
	var nc := 13
	var rr := rg + 0.014
	for k in nc:
		var a := deg_to_rad(-34.0 + (k + 0.5) * 248.0 / nc)
		n.add_child(scatola(Vector3(0.026, TAU * rr * (248.0 / 360.0) / nc * 1.1, 0.02), Vector3(cos(a) * rr, cy + sin(a) * rr, 0.01), "terracotta" if k % 2 == 0 else "blocco", Vector3(0, 0, rad_to_deg(a))))
	if pos.y > 0.01:
		n.add_child(scatola(Vector3(w + 0.08, pos.y, 0.07), Vector3(0, -pos.y * 0.5, 0.035), "blocco"))


## Finestrella a ferro di cavallo con la grata di legno a graticcio (nel nodo locale guarda verso +Z);
## pos è il centro della parte rettangolare, rot_y = 0 per la facciata +Z, 90 per la facciata +X.
static func _finestra_s(r: Node3D, pos: Vector3, rot_y: float, w := 0.065, h := 0.07) -> void:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot_y
	r.add_child(n)
	var rg := w * 0.58
	var cy := h * 0.5 + rg * 0.51
	n.add_child(scatola(Vector3(w, h, 0.012), Vector3(0, 0, 0.003), "buio"))
	n.add_child(cilindro(rg, rg, 0.012, Vector3(0, cy, 0.003), "buio", Vector3(90, 0, 0), 16))
	var basso := -h * 0.5
	var alto := cy + rg * 0.7
	for k in 3:
		n.add_child(scatola(Vector3(0.005, alto - basso, 0.005), Vector3((k - 1) * w * 0.3, (alto + basso) * 0.5, 0.011), "legno"))
	for k in 4:
		var y := basso + (k + 1) * (alto - basso) / 5.0
		var larg := w if y < h * 0.5 else w * 0.75
		n.add_child(scatola(Vector3(larg, 0.005, 0.005), Vector3(0, y, 0.011), "legno"))
	var rr := rg + 0.01
	for k in 9:
		var a := deg_to_rad(-30.0 + (k + 0.5) * 240.0 / 9)
		n.add_child(scatola(Vector3(0.018, TAU * rr * (240.0 / 360.0) / 9 * 1.1, 0.016), Vector3(cos(a) * rr, cy + sin(a) * rr, 0.006), "terracotta" if k % 2 == 0 else "blocco", Vector3(0, 0, rad_to_deg(a))))
	n.add_child(scatola(Vector3(w + 0.03, 0.014, 0.03), Vector3(0, basso - 0.007, 0.01), "blocco"))


## Cupola di maiolica verde su un tamburo di calce con le finestrelle, costoloni bianchi e pinnacolo con le sfere d'oro.
## pos è il centro della base del tamburo.
static func _cupola(r: Node3D, pos: Vector3, rg: float, mat := "maiolica_verde", tamburo := true) -> void:
	var off := 0.0
	if tamburo:
		var ht := rg * 0.45
		r.add_child(cilindro(rg * 1.03, rg * 1.03, ht, pos + Vector3(0, ht * 0.5, 0), "calce", Vector3.ZERO, 20))
		for k in 3:
			var a := deg_to_rad(20.0 + k * 25.0)
			r.add_child(scatola(Vector3(rg * 0.16, ht * 0.55, 0.012), pos + Vector3(cos(a) * rg * 1.03, ht * 0.48, sin(a) * rg * 1.03), "buio", Vector3(0, -rad_to_deg(a) + 90, 0)))
		r.add_child(cilindro(rg * 1.09, rg * 1.09, 0.018, pos + Vector3(0, ht, 0), "zellige", Vector3.ZERO, 20))
		off = ht + 0.009
	var c := pos + Vector3(0, off, 0)
	r.add_child(sfera(rg, c, mat, Vector3(1, 1.12, 1)))
	for k in 4:
		var costola := sfera(rg * 1.012, c, "calce", Vector3(0.045, 1.12, 1))
		costola.rotation_degrees.y = k * 45.0
		r.add_child(costola)
	var cima := c + Vector3(0, rg * 1.12, 0)
	r.add_child(cilindro(0.006, 0.006, rg * 0.55 + 0.03, cima + Vector3(0, rg * 0.27, 0), "moneta", Vector3.ZERO, 6))
	r.add_child(sfera(0.02 + rg * 0.06, cima + Vector3(0, 0.02, 0), "moneta"))
	r.add_child(sfera(0.012 + rg * 0.04, cima + Vector3(0, 0.06 + rg * 0.15, 0), "moneta"))


## Palma da datteri: fusto ad anelli un po' storto, ciuffo di foglie lunghe che ricadono, grappoli di datteri.
static func _palma(r: Node3D, pos: Vector3, s := 1.0, seme := 1) -> void:
	var rng := _rng(seme)
	var n := Node3D.new()
	n.position = pos
	n.scale = Vector3.ONE * s
	r.add_child(n)
	var p := Vector3.ZERO
	var piega := Vector3(rng.randf_range(-0.012, 0.012), 0, rng.randf_range(0.0, 0.014))
	for k in 8:
		var hs := 0.085
		var q := p + Vector3(0, hs, 0) + piega
		n.add_child(cilindro(0.026 - k * 0.0012, 0.03 - k * 0.0012, hs * 1.05, (p + q) * 0.5, "fusto_chiaro" if k % 2 == 0 else "corteccia", Vector3.ZERO, 8))
		n.add_child(cilindro(0.032 - k * 0.0012, 0.032 - k * 0.0012, 0.012, q, "corteccia", Vector3.ZERO, 8))
		p = q
	n.add_child(sfera(0.04, p + Vector3(0, 0.01, 0), "corteccia"))
	for k in 12:
		var f := Node3D.new()
		f.position = p + Vector3(0, 0.02, 0)
		var su := k < 3
		f.rotation_degrees = Vector3(-35.0 + k * 12.0 if su else rng.randf_range(8, 40), k * 360.0 / 12.0 + rng.randf_range(-12, 12), 0)
		n.add_child(f)
		f.add_child(sfera(0.05, Vector3(0, 0, 0.12), "foglie_chiare" if k % 3 == 0 else "foglie", Vector3(0.5, 0.1, 2.5)))
		f.add_child(sfera(0.035, Vector3(0, -0.035, 0.26), "foglie" if k % 2 == 0 else "foglie_scure", Vector3(0.55, 0.12, 2.0)))
	for k in 3:
		var a := k * TAU / 3 + 0.5
		for j in 5:
			n.add_child(sfera(0.012, p + Vector3(cos(a) * 0.04, -0.03 - j * 0.012, sin(a) * 0.04) + Vector3(rng.randf_range(-0.01, 0.01), 0, rng.randf_range(-0.01, 0.01)), "miele"))


## Alberello di agrumi (arance e limoni) in un'aiuola tonda bordata di terra cruda.
static func _arancio(r: Node3D, pos: Vector3, s := 1.0, seme := 1, aiuola := true) -> void:
	var rng := _rng(seme)
	var n := Node3D.new()
	n.position = pos
	n.scale = Vector3.ONE * s
	r.add_child(n)
	if aiuola:
		n.add_child(cilindro(0.12, 0.12, 0.03, Vector3(0, 0.015, 0), "terra_cruda", Vector3.ZERO, 14))
		n.add_child(cilindro(0.1, 0.1, 0.004, Vector3(0, 0.031, 0), "terra", Vector3.ZERO, 14))
	n.add_child(cilindro(0.016, 0.022, 0.2, Vector3(0, 0.1, 0), "corteccia", Vector3.ZERO, 6))
	chioma(n, Vector3(0, 0.27, 0), Vector3(0.14, 0.12, 0.14), 24, seme, "foglie_scure", "foglie", "foglie_chiare", Vector2(0.04, 0.065))
	for k in 12:
		var d := Vector3(rng.randf_range(-1, 1), rng.randf_range(-0.5, 0.9), rng.randf_range(-1, 1)).normalized()
		n.add_child(sfera(0.022, Vector3(0, 0.27, 0) + d * Vector3(0.15, 0.13, 0.15), "arancia" if k % 4 != 0 else "bergamotto"))


## Gelso: tronco nodoso, chioma larga di foglie verde chiaro e more scure e rosse (le foglie sfamano i bachi).
static func _gelso(r: Node3D, pos: Vector3, s := 1.0, seme := 1) -> void:
	var rng := _rng(seme)
	var n := Node3D.new()
	n.position = pos
	n.scale = Vector3.ONE * s
	r.add_child(n)
	n.add_child(cilindro(0.03, 0.042, 0.24, Vector3(0, 0.12, 0), "corteccia", Vector3.ZERO, 8))
	ramo(n, Vector3(0, 0.22, 0), Vector3(-0.1, 0.33, 0.04), 0.018)
	ramo(n, Vector3(0, 0.22, 0), Vector3(0.09, 0.34, -0.03), 0.018)
	ramo(n, Vector3(0, 0.22, 0), Vector3(0.02, 0.36, 0.1), 0.016)
	chioma(n, Vector3(0, 0.38, 0), Vector3(0.22, 0.12, 0.2), 40, seme, "foglie", "foglie_chiare", "grano_verde", Vector2(0.045, 0.075))
	for k in 16:
		var d := Vector3(rng.randf_range(-1, 1), rng.randf_range(-0.7, 0.6), rng.randf_range(-1, 1)).normalized()
		n.add_child(sfera(0.011, Vector3(0, 0.38, 0) + d * Vector3(0.23, 0.13, 0.21), "uva" if k % 3 != 0 else "cipolla", Vector3(1, 1.3, 1)))


## Canaletta d'acqua di pietra da un punto a un altro (a terra).
static func _canaletta(r: Node3D, da: Vector3, a: Vector3, larg := 0.045) -> void:
	var d := a - da
	d.y = 0.0
	var lung := d.length()
	var n := Node3D.new()
	n.position = Vector3((da.x + a.x) * 0.5, da.y, (da.z + a.z) * 0.5)
	n.rotation.y = atan2(-d.z, d.x)
	r.add_child(n)
	n.add_child(scatola(Vector3(lung, 0.02, larg + 0.03), Vector3(0, 0.01, 0), "blocco"))
	for lato: int in [-1, 1]:
		n.add_child(scatola(Vector3(lung, 0.012, 0.016), Vector3(0, 0.026, lato * (larg * 0.5 + 0.008)), "blocco"))
	n.add_child(scatola(Vector3(lung + 0.002, 0.004, larg), Vector3(0, 0.024, 0), "acqua_chiara"))


## Vasca ottagonale rivestita di maiolica con lo zampillo al centro.
static func _vasca(r: Node3D, pos: Vector3, rg := 0.12) -> void:
	r.add_child(cilindro(rg + 0.025, rg + 0.025, 0.022, pos + Vector3(0, 0.011, 0), "blocco", Vector3.ZERO, 8))
	r.add_child(cilindro(rg, rg, 0.06, pos + Vector3(0, 0.05, 0), "zellige", Vector3.ZERO, 8))
	r.add_child(cilindro(rg + 0.012, rg + 0.012, 0.014, pos + Vector3(0, 0.083, 0), "calce", Vector3.ZERO, 8))
	r.add_child(cilindro(rg - 0.012, rg - 0.012, 0.004, pos + Vector3(0, 0.088, 0), "acqua_chiara", Vector3.ZERO, 8))
	r.add_child(cilindro(0.012, 0.018, 0.05, pos + Vector3(0, 0.11, 0), "calce", Vector3.ZERO, 8))
	r.add_child(sfera(0.018, pos + Vector3(0, 0.15, 0), "schiuma", Vector3(1, 1.5, 1)))
	for k in 4:
		var a := k * TAU / 4 + 0.4
		r.add_child(sfera(0.009, pos + Vector3(cos(a) * 0.035, 0.12, sin(a) * 0.035), "schiuma"))


## Tenda a una falda con le strisce: alta dietro (-Z locale), bassa davanti su due pali, con la frangia a festoni.
## pos è il centro a terra (o sulla terrazza).
static func _tenda(r: Node3D, pos: Vector3, larg: float, prof: float, h_dietro: float, h_davanti: float, rot_y := 0.0, mat := "tenda_verde", pali_dietro := false) -> void:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot_y
	r.add_child(n)
	for lato: int in [-1, 1]:
		n.add_child(cilindro(0.008, 0.008, h_davanti, Vector3(lato * larg * 0.46, h_davanti * 0.5, prof * 0.5), "legno", Vector3.ZERO, 5))
		if pali_dietro:
			n.add_child(cilindro(0.008, 0.008, h_dietro, Vector3(lato * larg * 0.46, h_dietro * 0.5, -prof * 0.5), "legno", Vector3.ZERO, 5))
	var dh := h_dietro - h_davanti
	var lung := sqrt(prof * prof + dh * dh)
	n.add_child(scatola(Vector3(larg, 0.007, lung), Vector3(0, (h_dietro + h_davanti) * 0.5, 0), mat, Vector3(rad_to_deg(atan2(dh, prof)), 0, 0)))
	var nf := maxi(3, int(larg / 0.045))
	for k in nf:
		var x := -larg * 0.5 + (k + 0.5) * larg / nf
		n.add_child(scatola(Vector3(larg / nf * 0.9, 0.028, 0.005), Vector3(x, h_davanti - 0.014, prof * 0.5 + 0.004), mat))
		n.add_child(sfera(0.007, Vector3(x, h_davanti - 0.03, prof * 0.5 + 0.004), "moneta"))


## Insegna dei Saraceni: asta scura con la sfera d'oro, drappo verde smeraldo a due code con la fascia d'oro (verso +Z).
static func _stendardo_s(r: Node3D, pos: Vector3, h := 0.6) -> void:
	r.add_child(cilindro(0.009, 0.011, h, pos + Vector3(0, h * 0.5, 0), "legno_scuro", Vector3.ZERO, 6))
	r.add_child(sfera(0.02, pos + Vector3(0, h + 0.016, 0), "moneta"))
	r.add_child(scatola(Vector3(0.006, 0.13, 0.15), pos + Vector3(0, h - 0.08, 0.085), "stoffa_smeraldo"))
	for k: int in [-1, 1]:
		r.add_child(scatola(Vector3(0.006, 0.05, 0.08), pos + Vector3(0, h - 0.08 + k * 0.038, 0.195), "stoffa_smeraldo", Vector3(-k * 6.0, 0, 0)))
	r.add_child(scatola(Vector3(0.008, 0.13, 0.016), pos + Vector3(0, h - 0.08, 0.03), "moneta"))
	r.add_child(scatola(Vector3(0.008, 0.016, 0.15), pos + Vector3(0, h - 0.01, 0.085), "moneta"))


## Tappeto steso (nel nodo locale guarda verso +Z): rosso con la cornice d'oro e il medaglione verde, frange chiare.
## pos è il centro del bordo alto.
static func _tappeto(r: Node3D, pos: Vector3, rot_y := 0.0, w := 0.14, h := 0.17) -> void:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot_y
	r.add_child(n)
	n.add_child(scatola(Vector3(w, h, 0.006), Vector3(0, -h * 0.5, 0.003), "stoffa_rossa"))
	n.add_child(scatola(Vector3(w * 0.82, h * 0.86, 0.006), Vector3(0, -h * 0.5, 0.005), "seta_oro"))
	n.add_child(scatola(Vector3(w * 0.68, h * 0.74, 0.006), Vector3(0, -h * 0.5, 0.007), "stoffa_rossa"))
	n.add_child(scatola(Vector3(w * 0.3, w * 0.3, 0.006), Vector3(0, -h * 0.5, 0.009), "stoffa_smeraldo", Vector3(0, 0, 45)))
	n.add_child(scatola(Vector3(w * 0.12, w * 0.12, 0.006), Vector3(0, -h * 0.5, 0.011), "seta_oro", Vector3(0, 0, 45)))
	n.add_child(scatola(Vector3(w, 0.014, 0.004), Vector3(0, -h - 0.007, 0.003), "lino"))


## Dromedario delle carovane (muso verso +X), con la gualdrappa a strisce e due bisacce.
static func _dromedario(pos: Vector3, rot := 0.0) -> Node3D:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot
	n.add_child(sfera(0.08, Vector3(0, 0.27, 0), "cammello", Vector3(1.5, 0.75, 0.75)))
	n.add_child(sfera(0.06, Vector3(-0.01, 0.33, 0), "cammello", Vector3(1.15, 0.95, 0.85)))
	for x in [-0.085, 0.085]:
		for z in [-0.035, 0.035]:
			n.add_child(cilindro(0.014, 0.01, 0.23, Vector3(x, 0.115, z), "cammello", Vector3.ZERO, 6))
			n.add_child(cilindro(0.016, 0.016, 0.012, Vector3(x, 0.006, z), "pelle_scura", Vector3.ZERO, 6))
	n.add_child(cilindro(0.022, 0.03, 0.17, Vector3(0.15, 0.3, 0), "cammello", Vector3(0, 0, -38), 8))
	n.add_child(sfera(0.032, Vector3(0.21, 0.37, 0), "cammello", Vector3(1.6, 0.85, 0.8)))
	for z in [-0.012, 0.012]:
		n.add_child(sfera(0.008, Vector3(0.19, 0.4, z), "cammello"))
	n.add_child(cilindro(0.006, 0.003, 0.09, Vector3(-0.125, 0.22, 0), "crine", Vector3(0, 0, 25), 4))
	n.add_child(scatola(Vector3(0.12, 0.012, 0.16), Vector3(-0.01, 0.38, 0), "tenda_rossa"))
	for lato: int in [-1, 1]:
		n.add_child(sfera(0.04, Vector3(-0.01, 0.31, lato * 0.075), "lino", Vector3(1.1, 1.2, 0.6)))
		n.add_child(scatola(Vector3(0.1, 0.012, 0.006), Vector3(-0.01, 0.35, lato * 0.07), "stoffa_smeraldo"))
	n.add_child(scatola(Vector3(0.05, 0.012, 0.012), Vector3(0.24, 0.36, 0), "stoffa_rossa"))
	return n


## Giardinetto murato con i canali in croce: muretto di terra cruda sui lati in vista, aranci, fiori e vasca al centro.
static func _giardino_s(r: Node3D, pos: Vector3, lx: float, lz: float, seme: int) -> void:
	r.add_child(scatola(Vector3(lx, 0.01, lz), pos + Vector3(0, 0.005, 0), "orto"))
	for lato: int in [-1, 1]:
		r.add_child(scatola(Vector3(lx * 0.5 - 0.06, 0.012, lz * 0.5 - 0.06), pos + Vector3(lato * lx * 0.25 + lato * 0.005, 0.01, -lato * lz * 0.25 - lato * 0.005), "terra"))
	_canaletta(r, pos + Vector3(-lx * 0.5, 0, 0), pos + Vector3(lx * 0.5, 0, 0), 0.03)
	_canaletta(r, pos + Vector3(0, 0, -lz * 0.5), pos + Vector3(0, 0, lz * 0.5), 0.03)
	_vasca(r, pos, 0.06)
	_arancio(r, pos + Vector3(-lx * 0.25, 0, -lz * 0.25), 0.62, seme, false)
	_arancio(r, pos + Vector3(lx * 0.25, 0, lz * 0.25), 0.55, seme + 1, false)
	var rng := _rng(seme)
	for k in 10:
		var lato := 1 if k % 2 == 0 else -1
		var p := pos + Vector3(lato * rng.randf_range(0.04, lx * 0.45), 0.02, lato * rng.randf_range(-lz * 0.45, -0.04))
		r.add_child(sfera(0.018, p, "orto"))
		r.add_child(sfera(0.009, p + Vector3(0, 0.014, 0), "geranio" if k % 3 != 0 else "fiore"))
	# muretto di terra cruda con la copertina di calce sui due lati in vista
	for seg in [[Vector3(-lx * 0.5 - 0.02, 0, lz * 0.5 + 0.02), Vector3(-0.06, 0, lz * 0.5 + 0.02)],
			[Vector3(0.06, 0, lz * 0.5 + 0.02), Vector3(lx * 0.5 + 0.02, 0, lz * 0.5 + 0.02)],
			[Vector3(lx * 0.5 + 0.02, 0, -lz * 0.5 - 0.02), Vector3(lx * 0.5 + 0.02, 0, lz * 0.5 + 0.02)]]:
		var da: Vector3 = pos + (seg[0] as Vector3)
		var a: Vector3 = pos + (seg[1] as Vector3)
		_muro(r, da, a, 0.07, 0.035, "terra_cruda", false, "calce")
		r.add_child(cilindro(0.025, 0.025, 0.09, da + Vector3(0, 0.045, 0), "terra_cruda", Vector3.ZERO, 8))
		r.add_child(sfera(0.026, da + Vector3(0, 0.092, 0), "calce", Vector3(1, 0.7, 1)))


## Casa dei Saraceni: cubo di calce con la terrazza e i merli a gradini, stanzetta con la cupola verde,
## porta a ferro di cavallo, tenda a strisce e tappeto sulla terrazza, giardinetto murato con aranci e vasca, palma.
static func casa_greca_saraceni(seme := 1) -> Node3D:
	var r := Node3D.new()
	var corpo := Node3D.new()
	corpo.position = Vector3(-0.12, 0, -0.15)
	r.add_child(corpo)
	var lx := 0.92
	var lz := 0.7
	var top := _muri_s(corpo, lx, lz, 0.4, seme + 700)
	_porta_s(corpo, Vector3(-0.2, 0.07, lz * 0.5), 0.0, 0.13, 0.15)
	_finestra_s(corpo, Vector3(0.2, 0.27, lz * 0.5), 0.0)
	_finestra_s(corpo, Vector3(lx * 0.5, 0.27, 0.14), 90.0)
	_finestra_s(corpo, Vector3(lx * 0.5, 0.27, -0.16), 90.0)
	# stanzetta sulla terrazza con la cupola
	var st := Node3D.new()
	st.position = Vector3(-0.2, top, -0.14)
	corpo.add_child(st)
	st.add_child(scatola(Vector3(0.34, 0.2, 0.32), Vector3(0, 0.1, 0), "calce"))
	st.add_child(scatola(Vector3(0.36, 0.02, 0.34), Vector3(0, 0.2, 0), "terra_cruda"))
	_finestra_s(st, Vector3(0.0, 0.09, 0.16), 0.0, 0.05, 0.05)
	_finestra_s(st, Vector3(0.17, 0.09, 0.0), 90.0, 0.05, 0.05)
	_cupola(st, Vector3(0, 0.21, 0), 0.13)
	# tenda a strisce sulla terrazza con i cuscini, tappeto steso sul parapetto
	_tenda(corpo, Vector3(0.22, top, 0.14), 0.36, 0.3, 0.2, 0.15, 0.0, "tenda_verde", true)
	corpo.add_child(scatola(Vector3(0.22, 0.012, 0.13), Vector3(0.22, top + 0.01, 0.12), "stoffa_rossa"))
	for k in 2:
		corpo.add_child(sfera(0.028, Vector3(0.15 + k * 0.14, top + 0.03, 0.08), "stoffa_smeraldo", Vector3(1.3, 0.6, 1)))
	_tappeto(corpo, Vector3(0.24, top + 0.05, lz * 0.5 + 0.03), 0.0, 0.13, 0.15)
	# panca di terra cruda col cuscino, giare e vasi accanto alla porta
	corpo.add_child(scatola(Vector3(0.2, 0.05, 0.07), Vector3(0.06, 0.025, lz * 0.5 + 0.065), "terra_cruda"))
	corpo.add_child(scatola(Vector3(0.18, 0.014, 0.06), Vector3(0.06, 0.057, lz * 0.5 + 0.065), "stoffa_smeraldo"))
	corpo.add_child(anfora(Vector3(-0.4, 0, lz * 0.5 + 0.1), 1.1))
	corpo.add_child(anfora(Vector3(-0.34, 0, lz * 0.5 + 0.17), 0.95))
	corpo.add_child(vaso_fiori(Vector3(0.24, 0.0, lz * 0.5 + 0.08)))
	# giardinetto murato e palma
	_giardino_s(r, Vector3(0.56, 0, 0.42), 0.38, 0.42, seme + 3)
	_palma(r, Vector3(-0.64, 0, 0.32), 0.85, seme + 5)
	r.add_child(anfora(Vector3(-0.2, 0.0, 0.66), 1.2))
	return r


## Fondaco: grande casa dei mercanti a due piani, portico di archi a ferro di cavallo, cupola verde al centro,
## terrazza merlata, tende a strisce sulle merci (stoffe, tappeti, giare, sacchi), dromedario e insegna verde.
static func magazzino_saraceni() -> Node3D:
	var r := Node3D.new()
	var lx := 1.75
	var lz := 1.3
	r.position = Vector3(0, 0, -0.1)
	r.add_child(scatola(Vector3(lx + 0.24, 0.05, lz + 0.24), Vector3(0, 0.025, 0), "terra_cruda"))
	r.add_child(scatola(Vector3(lx + 0.16, 0.04, lz + 0.16), Vector3(0, 0.07, 0), "blocco"))
	var base := 0.09
	var corpo := Node3D.new()
	corpo.position = Vector3(0, base - 0.07, 0)
	r.add_child(corpo)
	var top := _muri_s(corpo, lx - 0.1, lz - 0.1, 0.62, 77)
	var fz := (lz - 0.1) * 0.5
	var fx := (lx - 0.1) * 0.5
	# portico: cinque archi aperti in basso, finestre a graticcio al piano di sopra
	for k in 5:
		var x := -0.64 + k * 0.32
		_porta_s(corpo, Vector3(x, 0.07, fz), 0.0, 0.2, 0.2, k != 2)
		_finestra_s(corpo, Vector3(x, 0.52, fz), 0.0, 0.07, 0.07)
	for k in 3:
		_finestra_s(corpo, Vector3(fx, 0.52, -0.4 + k * 0.4), 90.0, 0.07, 0.07)
	_porta_s(corpo, Vector3(fx, 0.07, 0.15), 90.0, 0.18, 0.2, true)
	# cornice di maiolica a mezza altezza
	corpo.add_child(scatola(Vector3(lx - 0.09, 0.026, lz - 0.09), Vector3(0, 0.43, 0), "zellige"))
	# cupola grande al centro su un dado di calce, due cupolette agli angoli dietro
	corpo.add_child(scatola(Vector3(0.62, 0.12, 0.62), Vector3(0, top + 0.06, -0.12), "calce"))
	corpo.add_child(scatola(Vector3(0.66, 0.02, 0.66), Vector3(0, top + 0.12, -0.12), "terra_cruda"))
	_cupola(corpo, Vector3(0, top + 0.13, -0.12), 0.26)
	for x in [-0.62, 0.62]:
		corpo.add_child(scatola(Vector3(0.22, 0.12, 0.22), Vector3(x, top + 0.06, -0.38), "calce"))
		_cupola(corpo, Vector3(x, top + 0.12, -0.38), 0.1, "maiolica_verde", false)
	_tappeto(corpo, Vector3(-0.5, top + 0.05, fz + 0.03), 0.0, 0.14, 0.17)
	_tenda(corpo, Vector3(0.45, top, 0.25), 0.4, 0.3, 0.2, 0.15, 0.0, "tenda_verde", true)
	for i in 3:
		corpo.add_child(cilindro(0.03, 0.03, 0.28, Vector3(0.36 + i * 0.07, top + 0.03, 0.25), ["stoffa_rossa", "seta_azzurra", "seta_zafferano"][i], Vector3(90, 0, 0), 10))
	for i in 2:
		corpo.add_child(scatola(Vector3(0.24, 0.006, 0.16), Vector3(-0.42 + i * 0.3, top + 0.01, 0.2), "stoffa_rossa" if i == 0 else "stoffa_smeraldo"))
		corpo.add_child(scatola(Vector3(0.18, 0.007, 0.1), Vector3(-0.42 + i * 0.3, top + 0.012, 0.2), "seta_oro"))
	corpo.add_child(cesta(Vector3(-0.15, top, 0.32), "agrumi"))
	corpo.add_child(sacco(Vector3(0.12, top, 0.32), 0.3))
	_tappeto(corpo, Vector3(0.48, top + 0.05, fz + 0.03), 0.0, 0.14, 0.17)
	_tappeto(corpo, Vector3(fx + 0.03, top + 0.05, 0.2), 90.0, 0.14, 0.17)
	# banchi sotto le tende a strisce: stoffe arrotolate, sacchi, giare, casse
	var fronte := lz * 0.5
	_tenda(r, Vector3(-0.55, base, fronte + 0.12), 0.5, 0.26, 0.32, 0.24, 0.0, "tenda_verde")
	_tenda(r, Vector3(0.55, base, fronte + 0.12), 0.5, 0.26, 0.32, 0.24, 0.0, "tenda_rossa")
	for i in 4:
		r.add_child(cilindro(0.028, 0.028, 0.2, Vector3(-0.7 + i * 0.09, base + 0.03 + (i % 2) * 0.03, fronte + 0.16), ["seta_cremisi", "seta_verde", "seta_oro", "seta_azzurra"][i], Vector3(90, 0, 0), 10))
	for i in 3:
		r.add_child(anfora(Vector3(-0.42 + (i % 2) * 0.08, base, fronte + 0.1 + (i / 2) * 0.1), 1.2))
	for i in 3:
		r.add_child(sacco(Vector3(0.38 + i * 0.1, base, fronte + 0.12), i * 0.5))
	r.add_child(cassa(Vector3(0.7, base, fronte + 0.14), 12))
	r.add_child(cassa(Vector3(0.7, base + 0.088, fronte + 0.14), 30, 0.09))
	var dr := _dromedario(Vector3(0.12, 0, fronte + 0.36), -25)
	dr.scale = Vector3.ONE * 1.25
	r.add_child(dr)
	r.add_child(anfora(Vector3(0.95, 0.0, -0.1), 1.3))
	r.add_child(anfora(Vector3(0.98, 0.0, 0.05), 1.2))
	_stendardo_s(r, Vector3(lx * 0.5 + 0.12, 0, lz * 0.5 + 0.12), 0.75)
	_palma(r, Vector3(-0.98, 0, -0.5), 1.0, 71)
	return r


## Boscaiolo dei Saraceni: casetta di terra cruda con la terrazza dove seccano le frasche, pergola di pali coperta
## di stuoie di canne sopra la legna, ceppo con l'ascia, grande catasta di tronchi.
static func boscaiolo_saraceni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.15, 0, -0.18)
	r.add_child(c)
	var lx := 0.8
	var lz := 0.62
	var top := _muri_s(c, lx, lz, 0.32, 801, "mattoni_crudi", false, false)
	_porta_s(c, Vector3(-0.15, 0.07, lz * 0.5), 0.0, 0.12, 0.14)
	_finestra_s(c, Vector3(0.18, 0.24, lz * 0.5), 0.0)
	_finestra_s(c, Vector3(lx * 0.5, 0.24, 0.0), 90.0)
	# frasche e fascine sulla terrazza
	for k in 4:
		c.add_child(cilindro(0.03, 0.03, 0.26, Vector3(-0.2 + k * 0.08, top + 0.03, -0.1), "paglia_scura", Vector3(90, 0, 0), 8))
	c.add_child(scatola(Vector3(0.05, 0.12, 0.05), Vector3(0.28, top + 0.06, -0.18), "terra_cruda"))
	# pergola con le stuoie di canne sopra la legna
	for pz in [-0.26, 0.24]:
		c.add_child(cilindro(0.013, 0.013, 0.32, Vector3(lx * 0.5 + 0.3, 0.16, pz), "legno_vecchio", Vector3.ZERO, 6))
	c.add_child(scatola(Vector3(0.34, 0.016, 0.6), Vector3(lx * 0.5 + 0.16, 0.33, -0.01), "canne", Vector3(0, 0, -6)))
	for k in 4:
		c.add_child(cilindro(0.008, 0.008, 0.36, Vector3(lx * 0.5 + 0.02 + k * 0.1, 0.345 - k * 0.01, -0.01), "legno", Vector3(0, 0, 90 - 6), 5))
	legnaia(c, Vector3(lx * 0.5 + 0.17, 0.0, 0.0), 0.5, 5)
	# catasta di tronchi, ceppo con l'ascia, ceppaie, giara d'acqua
	catasta_tronchi(r, Vector3(0.55, 0, 0.55), 4, 0.5)
	r.add_child(cilindro(0.07, 0.075, 0.09, Vector3(-0.2, 0.045, 0.5), "corteccia", Vector3.ZERO, 12))
	r.add_child(cilindro(0.066, 0.066, 0.006, Vector3(-0.2, 0.092, 0.5), "legno_chiaro", Vector3.ZERO, 12))
	r.add_child(cilindro(0.008, 0.008, 0.22, Vector3(-0.2, 0.18, 0.5), "legno", Vector3(0, 0, 22), 6))
	r.add_child(scatola(Vector3(0.06, 0.045, 0.012), Vector3(-0.245, 0.27, 0.5), "ferro", Vector3(0, 0, 22)))
	for i in 6:
		r.add_child(cilindro(0.02, 0.02, 0.06, Vector3(-0.38 + i * 0.06, 0.02, 0.62 + (i % 2) * 0.05), "legno_chiaro", Vector3(0, i * 37, 90), 6))
	for pos in [Vector3(-0.72, 0, 0.3), Vector3(-0.6, 0, 0.75)]:
		r.add_child(cilindro(0.06, 0.07, 0.05, pos + Vector3(0, 0.025, 0), "corteccia", Vector3.ZERO, 10))
		r.add_child(cilindro(0.056, 0.056, 0.005, pos + Vector3(0, 0.052, 0), "legno_chiaro", Vector3.ZERO, 10))
	r.add_child(anfora(Vector3(-0.05, 0, 0.2), 1.1))
	_stendardo_s(c, Vector3(-lx * 0.5 + 0.06, top, lz * 0.5 - 0.06), 0.36)
	return r


## Segheria dei Saraceni: bottega di calce con la cupoletta, tettoia piatta di canne su pali con la sega a telaio,
## tenda a strisce sul davanti, pile di assi e tronchi.
static func segheria_saraceni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.25)
	r.add_child(c)
	var lx := 0.85
	var lz := 0.62
	var top := _muri_s(c, lx, lz, 0.4, 811)
	_porta_s(c, Vector3(-0.22, 0.07, lz * 0.5), 0.0, 0.15, 0.17, true)
	_finestra_s(c, Vector3(0.15, 0.27, lz * 0.5), 0.0)
	_finestra_s(c, Vector3(lx * 0.5, 0.27, 0.05), 90.0)
	c.add_child(scatola(Vector3(0.3, 0.1, 0.3), Vector3(-0.18, top + 0.05, -0.12), "calce"))
	_cupola(c, Vector3(-0.18, top + 0.1, -0.12), 0.12, "maiolica_verde", false)
	# tettoia piatta di canne su pali, con la tenda a strisce davanti
	var t := Node3D.new()
	t.position = Vector3(0.05, 0, 0.5)
	r.add_child(t)
	for p in [Vector3(-0.42, 0, -0.18), Vector3(0.42, 0, -0.18), Vector3(-0.42, 0, 0.22), Vector3(0.42, 0, 0.22)]:
		t.add_child(cilindro(0.018, 0.018, 0.4, p + Vector3(0, 0.2, 0), "legno_vecchio", Vector3.ZERO, 6))
	for z in [-0.18, 0.22]:
		t.add_child(scatola(Vector3(0.92, 0.03, 0.03), Vector3(0, 0.405, z), "legno"))
	t.add_child(scatola(Vector3(0.95, 0.018, 0.5), Vector3(0, 0.43, 0.02), "canne"))
	var nf := 14
	for k in nf:
		t.add_child(scatola(Vector3(0.95 / nf * 0.9, 0.03, 0.005), Vector3(-0.475 + (k + 0.5) * 0.95 / nf, 0.41, 0.272), "tenda_verde"))
	for px in [-0.25, 0.0, 0.25]:
		t.add_child(scatola(Vector3(0.03, 0.12, 0.12), Vector3(px, 0.06, 0.0), "legno"))
	t.add_child(cilindro(0.055, 0.055, 0.8, Vector3(0, 0.17, 0.0), "corteccia", Vector3(0, 0, 90), 9))
	t.add_child(cilindro(0.047, 0.047, 0.805, Vector3(0, 0.17, 0.0), "legno_chiaro", Vector3(0, 0, 90), 9))
	for z in [-0.08, 0.08]:
		t.add_child(scatola(Vector3(0.014, 0.3, 0.014), Vector3(0.1, 0.24, z), "legno"))
	t.add_child(scatola(Vector3(0.014, 0.014, 0.18), Vector3(0.1, 0.38, 0.0), "legno"))
	t.add_child(scatola(Vector3(0.006, 0.006, 0.17), Vector3(0.1, 0.2, 0.0), "ferro"))
	t.add_child(cilindro(0.2, 0.2, 0.004, Vector3(0.1, 0.002, 0.0), "legno_chiaro", Vector3.ZERO, 16))
	pila_assi(r, Vector3(0.62, 0, -0.25), 8, 90)
	pila_assi(r, Vector3(0.62, 0, 0.12), 5, 90)
	catasta_tronchi(r, Vector3(-0.65, 0, 0.55), 3, 0.42)
	carretto(r, Vector3(0.35, 0, 0.85), -30, "tronchi")
	return r


## Cava dei Saraceni: casetta cubica di terra cruda con la cupola di terra, rupe chiara di arenaria,
## blocchi squadrati, capra di legno con la carrucola, carretto.
static func cava_saraceni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.35, 0, -0.3)
	r.add_child(c)
	var top := _muri_s(c, 0.5, 0.46, 0.28, 821, "mattoni_crudi", false, false)
	_porta_s(c, Vector3(-0.06, 0.07, 0.23), 0.0, 0.11, 0.13)
	_cupola(c, Vector3(0, top, 0), 0.19, "terra_cruda", false)
	_finestra_s(c, Vector3(0.25, 0.22, 0.05), 90.0, 0.05, 0.05)
	# rupe di arenaria chiara a gradoni
	var rng := _rng(821)
	for k in 9:
		var p := Vector3(0.35 + rng.randf_range(-0.2, 0.2), 0.0, -0.4 + rng.randf_range(-0.15, 0.2))
		var d := rng.randf_range(0.16, 0.3)
		r.add_child(scatola(Vector3(d, d * rng.randf_range(0.6, 1.4), d * 0.8), p + Vector3(0, d * 0.4, 0), "roccia_chiara" if k % 3 != 0 else "tufo", Vector3(0, rng.randf() * 60, 0)))
	for i in 4:
		for j in 2 - (i / 3):
			r.add_child(scatola(Vector3(0.13, 0.09, 0.09), Vector3(-0.1 + i * 0.15, 0.045 + j * 0.09, 0.45), "tufo" if (i + j) % 2 == 0 else "blocco", Vector3(0, i * 5 - 6, 0)))
	# capra di tre pali con la carrucola e la corda
	var g := Vector3(0.14, 0, 0.05)
	for k in 3:
		var a := k * TAU / 3 + 0.3
		ramo(r, g + Vector3(cos(a) * 0.14, 0, sin(a) * 0.14), g + Vector3(0, 0.46, 0), 0.01, "legno")
	r.add_child(cilindro(0.025, 0.025, 0.012, g + Vector3(0, 0.43, 0.012), "legno_scuro", Vector3(90, 0, 0), 10))
	r.add_child(cilindro(0.004, 0.004, 0.3, g + Vector3(0, 0.27, 0.02), "corda", Vector3.ZERO, 4))
	r.add_child(scatola(Vector3(0.1, 0.07, 0.08), g + Vector3(0, 0.1, 0.02), "tufo"))
	r.add_child(cilindro(0.008, 0.008, 0.22, Vector3(0.55, 0.11, 0.35), "legno", Vector3(0, 0, -25), 6))
	r.add_child(scatola(Vector3(0.11, 0.014, 0.014), Vector3(0.6, 0.21, 0.35), "ferro", Vector3(0, 0, -25)))
	carretto(r, Vector3(-0.45, 0, 0.6), 15)
	r.add_child(scatola(Vector3(0.1, 0.07, 0.07), Vector3(-0.45, 0.16, 0.6), "blocco"))
	r.add_child(anfora(Vector3(-0.68, 0, 0.15), 1.1))
	_tenda(r, Vector3(-0.35, 0, 0.1), 0.3, 0.2, 0.25, 0.2, 0.0, "tenda_rossa")
	return r


## Guardaboschi dei Saraceni: casetta di calce con la terrazza, vivaio di alberelli (pini e aranci) in vasi di terracotta
## allineati fra le canalette d'acqua che partono da una piccola cisterna.
static func guardaboschi_saraceni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.3, 0, -0.3)
	r.add_child(c)
	var top := _muri_s(c, 0.58, 0.48, 0.28, 831)
	_porta_s(c, Vector3(0.12, 0.07, 0.24), 0.0, 0.11, 0.13)
	_finestra_s(c, Vector3(-0.14, 0.23, 0.24), 0.0, 0.055, 0.06)
	_tenda(c, Vector3(-0.1, top, 0.05), 0.26, 0.24, 0.17, 0.13, 0.0, "tenda_verde", true)
	# cisterna e canalette fra le file dei vasi
	var cs := Vector3(-0.2, 0, 0.3)
	r.add_child(cilindro(0.09, 0.09, 0.08, cs + Vector3(0, 0.04, 0), "terra_cruda", Vector3.ZERO, 12))
	r.add_child(cilindro(0.075, 0.075, 0.004, cs + Vector3(0, 0.081, 0), "acqua_chiara", Vector3.ZERO, 12))
	for j in 3:
		_canaletta(r, cs + Vector3(0.08, 0, 0.0 + j * 0.15), Vector3(0.6, 0, 0.3 + j * 0.15), 0.025)
	for i in 4:
		for j in 3:
			var p := Vector3(-0.02 + i * 0.16, 0, 0.36 + j * 0.15)
			r.add_child(cilindro(0.03, 0.022, 0.045, p + Vector3(0, 0.0225, 0), "terracotta", Vector3.ZERO, 10))
			r.add_child(cilindro(0.026, 0.026, 0.004, p + Vector3(0, 0.046, 0), "terra", Vector3.ZERO, 10))
			r.add_child(cilindro(0.005, 0.005, 0.05 + j * 0.02, p + Vector3(0, 0.07 + j * 0.01, 0), "corteccia", Vector3.ZERO, 5))
			if (i + j) % 2 == 0:
				r.add_child(cilindro(0.03 + j * 0.008, 0.0, 0.08 + j * 0.03, p + Vector3(0, 0.12 + j * 0.03, 0), "aghi", Vector3.ZERO, 7))
			else:
				r.add_child(sfera(0.034 + j * 0.008, p + Vector3(0, 0.11 + j * 0.03, 0), "foglie", Vector3(1, 0.9, 1)))
				r.add_child(sfera(0.009, p + Vector3(0.02, 0.12 + j * 0.03, 0.02), "arancia"))
	# zappa, annaffiatoio di rame, sacchi di semi, palma giovane
	r.add_child(cilindro(0.03, 0.025, 0.06, Vector3(0.35, 0.03, -0.2), "bronzo", Vector3.ZERO, 8))
	r.add_child(cilindro(0.007, 0.007, 0.22, Vector3(0.2, 0.11, -0.3), "legno", Vector3(12, 0, -15), 5))
	r.add_child(sacco(Vector3(-0.58, 0, 0.3), 0.4))
	r.add_child(sacco(Vector3(-0.62, 0, 0.44), -0.2))
	_palma(r, Vector3(0.55, 0, -0.5), 0.7, 832)
	return r


## Pozzo dei Saraceni: vera ottagonale di maiolica sotto un baldacchino di quattro colonnine con gli archi
## a ferro di cavallo e la cupoletta verde; carrucola, secchio di rame, vasca e canaletta verso un arancio.
static func pozzo_saraceni() -> Node3D:
	var r := Node3D.new()
	r.add_child(cilindro(0.27, 0.27, 0.03, Vector3(0, 0.015, 0), "blocco", Vector3.ZERO, 8))
	r.add_child(cilindro(0.17, 0.18, 0.17, Vector3(0, 0.115, 0), "zellige", Vector3.ZERO, 8))
	r.add_child(cilindro(0.185, 0.185, 0.025, Vector3(0, 0.21, 0), "calce", Vector3.ZERO, 8))
	r.add_child(cilindro(0.14, 0.14, 0.005, Vector3(0, 0.2, 0), "acqua_pozzo", Vector3.ZERO, 8))
	var hc := 0.34
	var d := 0.2
	for x in [-d, d]:
		for z in [-d, d]:
			r.add_child(cilindro(0.017, 0.017, hc, Vector3(x, 0.03 + hc * 0.5, z), "calce", Vector3.ZERO, 8))
			r.add_child(scatola(Vector3(0.045, 0.025, 0.045), Vector3(x, 0.03 + hc, z), "zellige"))
	# archi a ferro di cavallo fra le colonnine: conci alternati bianchi e rossi, pennacchi pieni agli angoli
	var y0 := 0.03 + hc + 0.0125
	for i in 4:
		var n := Node3D.new()
		n.rotation_degrees.y = i * 90.0
		r.add_child(n)
		n.add_child(scatola(Vector3(2 * d + 0.04, 0.04, 0.03), Vector3(0, y0 + 0.09, d), "calce"))
		var rg := d - 0.035
		var cy := y0 - 0.02
		for k in 11:
			var a := deg_to_rad(-25.0 + (k + 0.5) * 230.0 / 11)
			n.add_child(scatola(Vector3(0.026, TAU * rg * (230.0 / 360.0) / 11 * 1.12, 0.03), Vector3(cos(a) * rg, cy + sin(a) * rg, d), "terracotta" if k % 2 == 0 else "calce", Vector3(0, 0, rad_to_deg(a))))
		for lato: int in [-1, 1]:
			n.add_child(scatola(Vector3(0.05, 0.08, 0.028), Vector3(lato * (d - 0.012), y0 + 0.04, d), "calce"))
	r.add_child(scatola(Vector3(2 * d + 0.06, 0.02, 2 * d + 0.06), Vector3(0, y0 + 0.1, 0), "zellige"))
	r.add_child(scatola(Vector3(2 * d + 0.09, 0.025, 2 * d + 0.09), Vector3(0, y0 + 0.122, 0), "terra_cruda"))
	_fila_merli(r, Vector3(-d - 0.03, y0 + 0.134, d + 0.03), Vector3(d + 0.03, y0 + 0.134, d + 0.03), "calce", 0.8)
	_fila_merli(r, Vector3(d + 0.03, y0 + 0.134, -d - 0.03), Vector3(d + 0.03, y0 + 0.134, d + 0.03), "calce", 0.8)
	_cupola(r, Vector3(0, y0 + 0.134, 0), 0.17, "maiolica_verde", true)
	# carrucola, corda e secchio di rame
	r.add_child(scatola(Vector3(2 * d, 0.02, 0.02), Vector3(0, y0 - 0.03, 0), "legno"))
	r.add_child(cilindro(0.03, 0.03, 0.014, Vector3(0, y0 - 0.06, 0), "legno_scuro", Vector3(90, 0, 0), 12))
	r.add_child(cilindro(0.003, 0.003, 0.18, Vector3(0.02, 0.26, 0), "corda", Vector3.ZERO, 4))
	r.add_child(cilindro(0.032, 0.026, 0.05, Vector3(0.02, 0.24, 0.0), "bronzo", Vector3.ZERO, 10))
	# vasca per abbeverare e canaletta
	r.add_child(scatola(Vector3(0.24, 0.06, 0.1), Vector3(0.08, 0.03, 0.33), "terra_cruda"))
	r.add_child(scatola(Vector3(0.21, 0.004, 0.07), Vector3(0.08, 0.061, 0.33), "acqua_chiara"))
	_canaletta(r, Vector3(0.2, 0, 0.33), Vector3(0.36, 0, 0.33), 0.025)
	r.add_child(anfora(Vector3(-0.26, 0.0, 0.18), 1.1))
	r.add_child(anfora(Vector3(-0.2, 0.0, 0.26), 0.95))
	r.scale = Vector3.ONE * 1.2
	return r


## Fattoria dei Saraceni: casa di calce con la terrazza dove seccano i fichi, fienile con le stuoie di canne,
## campi irrigati divisi dalle canalette con la cisterna, covoni, carretto, galline e palma.
static func fattoria_saraceni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.18, 0, -0.22)
	r.add_child(c)
	var lx := 0.78
	var lz := 0.58
	var top := _muri_s(c, lx, lz, 0.34, 841)
	_porta_s(c, Vector3(-0.12, 0.07, lz * 0.5), 0.0, 0.13, 0.15)
	_finestra_s(c, Vector3(0.2, 0.25, lz * 0.5), 0.0)
	_finestra_s(c, Vector3(lx * 0.5, 0.25, 0.0), 90.0)
	# graticci con i fichi e il grano steso sulla terrazza
	for k in 2:
		c.add_child(scatola(Vector3(0.24, 0.01, 0.16), Vector3(-0.16 + k * 0.3, top + 0.02, -0.08), "canne"))
		for j in 8:
			c.add_child(sfera(0.014, Vector3(-0.25 + k * 0.3 + (j % 4) * 0.06, top + 0.03, -0.12 + (j / 4) * 0.08), "uva" if k == 0 else "miele", Vector3(1, 0.6, 1)))
	c.add_child(sfera(0.1, Vector3(0.15, top + 0.01, 0.12), "grano", Vector3(1.2, 0.35, 0.9)))
	# fienile coperto di canne sul lato destro
	for p in [Vector3(0.62, 0, -0.45), Vector3(0.62, 0, 0.05), Vector3(0.95, 0, -0.45), Vector3(0.95, 0, 0.05)]:
		r.add_child(cilindro(0.016, 0.016, 0.34, p + Vector3(0, 0.17, 0), "legno_vecchio", Vector3.ZERO, 6))
	r.add_child(scatola(Vector3(0.42, 0.02, 0.6), Vector3(0.785, 0.35, -0.2), "canne"))
	r.add_child(scatola(Vector3(0.44, 0.03, 0.62), Vector3(0.785, 0.335, -0.2), "legno"))
	for i in 5:
		var cv := covone(1.1)
		cv.position = Vector3(0.68 + (i % 3) * 0.1, 0.0, -0.35 + (i / 3) * 0.14)
		r.add_child(cv)
	# campi irrigati: aiuole verdi fra le canalette, cisterna tonda
	var cs := Vector3(-0.72, 0, 0.1)
	r.add_child(cilindro(0.08, 0.08, 0.08, cs + Vector3(0, 0.04, 0), "terra_cruda", Vector3.ZERO, 12))
	r.add_child(cilindro(0.066, 0.066, 0.004, cs + Vector3(0, 0.081, 0), "acqua_chiara", Vector3.ZERO, 12))
	_canaletta(r, cs + Vector3(0, 0, 0.08), Vector3(-0.72, 0, 0.78), 0.025)
	for j in 3:
		_canaletta(r, Vector3(-0.7, 0, 0.42 + j * 0.16), Vector3(-0.1, 0, 0.42 + j * 0.16), 0.022)
	for j in 2:
		for i in 4:
			var p := Vector3(-0.6 + i * 0.14, 0, 0.5 + j * 0.16)
			r.add_child(scatola(Vector3(0.12, 0.012, 0.12), p + Vector3(0, 0.006, 0), "terra"))
			for q in 4:
				r.add_child(sfera(0.02, p + Vector3(-0.03 + (q % 2) * 0.06, 0.022, -0.03 + (q / 2) * 0.06), "orto" if j == 0 else "grano_verde", Vector3(1, 0.9, 1)))
	carretto(r, Vector3(0.4, 0, 0.55), -20, "sacchi")
	for i in 3:
		var cv := covone(1.15)
		cv.position = Vector3(0.12 + i * 0.12, 0.0, 0.32 + (i % 2) * 0.06)
		r.add_child(cv)
	for i in 3:
		r.add_child(sfera(0.025, Vector3(0.05 + i * 0.07, 0.03, 0.5 - i * 0.03), "calce", Vector3(1.3, 1, 1)))
		r.add_child(sfera(0.008, Vector3(0.08 + i * 0.07, 0.05, 0.5 - i * 0.03), "geranio"))
	_palma(r, Vector3(-0.72, 0, -0.32), 0.85, 842)
	return r


## Mulino dei Saraceni ad acqua: la canaletta arriva su due archi di terra cruda fino alla torretta di carico,
## l'acqua cade sulla ruota orizzontale nascosta ed esce schiumando da un arco in basso; sacchi, asino, covoni.
static func mulino_saraceni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.28, 0, -0.25)
	r.add_child(c)
	var lx := 0.7
	var lz := 0.56
	var top := _muri_s(c, lx, lz, 0.42, 851)
	_porta_s(c, Vector3(-0.12, 0.07, lz * 0.5), 0.0, 0.14, 0.16)
	_finestra_s(c, Vector3(0.17, 0.3, lz * 0.5), 0.0)
	c.add_child(scatola(Vector3(0.26, 0.1, 0.26), Vector3(-0.16, top + 0.05, -0.1), "calce"))
	_cupola(c, Vector3(-0.16, top + 0.1, -0.1), 0.11, "maiolica_verde", false)
	# torretta di carico sul lato destro: l'acqua arriva in cima e cade sulla ruota orizzontale nascosta
	var tc := Vector3(lx * 0.5 + 0.11, 0, 0.12)
	c.add_child(scatola(Vector3(0.22, 0.52, 0.24), tc + Vector3(0, 0.26, 0), "mattoni_crudi"))
	c.add_child(scatola(Vector3(0.224, 0.08, 0.244), tc + Vector3(0, 0.48, 0), "calce"))
	c.add_child(scatola(Vector3(0.23, 0.022, 0.25), tc + Vector3(0, 0.45, 0), "zellige"))
	c.add_child(scatola(Vector3(0.24, 0.02, 0.26), tc + Vector3(0, 0.53, 0), "terra_cruda"))
	c.add_child(scatola(Vector3(0.16, 0.008, 0.18), tc + Vector3(0, 0.542, 0), "acqua_chiara"))
	# acquedotto su due archi lungo il fianco destro, con la canaletta in cima
	for k in 2:
		var z := tc.z - 0.27 - k * 0.24
		_arco(c, Vector3(tc.x, 0, z), 0.13, 0.28, 0.08, "mattoni_crudi", 90.0, "calce")
	c.add_child(scatola(Vector3(0.1, 0.07, 0.62), Vector3(tc.x, 0.47, tc.z - 0.4), "mattoni_crudi"))
	c.add_child(scatola(Vector3(0.106, 0.02, 0.62), Vector3(tc.x, 0.515, tc.z - 0.4), "calce"))
	c.add_child(scatola(Vector3(0.05, 0.008, 0.62), Vector3(tc.x, 0.528, tc.z - 0.4), "acqua_chiara"))
	# uscita dell'acqua da un arco in basso, con la schiuma, e canale verso il davanti
	_porta_s(c, Vector3(tc.x, 0.0, tc.z + 0.12), 0.0, 0.11, 0.08, true)
	c.add_child(scatola(Vector3(0.12, 0.008, 0.5), Vector3(tc.x, 0.008, tc.z + 0.37), "acqua_chiara"))
	for lato: int in [-1, 1]:
		c.add_child(scatola(Vector3(0.025, 0.03, 0.5), Vector3(tc.x + lato * 0.07, 0.015, tc.z + 0.37), "blocco"))
	for k in 5:
		c.add_child(sfera(0.022, Vector3(tc.x + (k % 2 - 0.5) * 0.04, 0.02, tc.z + 0.16 + k * 0.03), "schiuma", Vector3(1, 0.5, 1)))
	# macine di scorta, sacchi, asino, covone
	r.add_child(cilindro(0.11, 0.11, 0.04, Vector3(-0.62, 0.11, 0.3), "blocco", Vector3(90, 30, 0), 18))
	r.add_child(cilindro(0.11, 0.11, 0.04, Vector3(-0.55, 0.11, 0.38), "pietra", Vector3(90, 30, 0), 18))
	for i in 5:
		r.add_child(sacco(Vector3(-0.42 + (i % 3) * 0.12, 0.0, 0.5 + (i / 3) * 0.13), i * 0.7))
	r.add_child(asino(Vector3(0.0, 0, 0.55), 160))
	var cv := covone(1.1)
	cv.position = Vector3(-0.68, 0, 0.6)
	r.add_child(cv)
	r.add_child(cassa(Vector3(0.48, 0, 0.62), 15))
	r.add_child(anfora(Vector3(0.62, 0, 0.5), 1.1))
	return r


## Forno dei Saraceni: bottega di calce con la cupoletta, due tannur di argilla (forni a pozzo) con le braci e il fumo,
## bancone sotto la tenda rossa a strisce con le focacce tonde, ceste, sacchi di farina e giare d'acqua.
static func forno_saraceni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.25)
	r.add_child(c)
	var lx := 0.74
	var lz := 0.56
	var top := _muri_s(c, lx, lz, 0.36, 861)
	_porta_s(c, Vector3(-0.15, 0.07, lz * 0.5), 0.0, 0.13, 0.15, true)
	_finestra_s(c, Vector3(0.18, 0.25, lz * 0.5), 0.0)
	_finestra_s(c, Vector3(lx * 0.5, 0.25, 0.0), 90.0)
	c.add_child(scatola(Vector3(0.06, 0.16, 0.06), Vector3(0.24, top + 0.08, -0.15), "terra_cruda"))
	c.add_child(scatola(Vector3(0.07, 0.03, 0.07), Vector3(0.24, top + 0.15, -0.15), "fuliggine"))
	_fumo(c, Vector3(0.24, top + 0.2, -0.15), 3, 0.8)
	c.add_child(scatola(Vector3(0.26, 0.1, 0.26), Vector3(-0.18, top + 0.05, -0.1), "calce"))
	_cupola(c, Vector3(-0.18, top + 0.1, -0.1), 0.11, "maiolica_verde", false)
	# due tannur: forni di argilla a tronco di cono con la bocca in alto annerita, le fiamme e la bocchetta del fuoco
	for k in 2:
		var f := Vector3(0.36 + k * 0.22, 0, 0.3 + k * 0.16)
		r.add_child(cilindro(0.14, 0.15, 0.04, f + Vector3(0, 0.02, 0), "blocco", Vector3.ZERO, 16))
		r.add_child(cilindro(0.07, 0.13, 0.2, f + Vector3(0, 0.14, 0), "terra_cruda", Vector3.ZERO, 16))
		r.add_child(_toro(0.045, 0.075, f + Vector3(0, 0.24, 0), "fuliggine", Vector3.ZERO, Vector3(1, 0.6, 1)))
		r.add_child(cilindro(0.05, 0.05, 0.005, f + Vector3(0, 0.236, 0), "brace", Vector3.ZERO, 12))
		r.add_child(cilindro(0.035, 0.0, 0.07, f + Vector3(0, 0.27, 0), "brace", Vector3.ZERO, 7))
		var bocca := Vector3(sin(0.6), 0, cos(0.6))
		r.add_child(scatola(Vector3(0.05, 0.045, 0.03), f + Vector3(0, 0.07, 0) + bocca * 0.13, "brace", Vector3(0, rad_to_deg(0.6), 0)))
		r.add_child(scatola(Vector3(0.07, 0.065, 0.026), f + Vector3(0, 0.075, 0) + bocca * 0.125, "fuliggine", Vector3(0, rad_to_deg(0.6), 0)))
		for j in 3:
			r.add_child(cilindro(0.035, 0.033, 0.008, f + Vector3(0.09 - j * 0.03, 0.17 - j * 0.04, -0.06), "pane", Vector3(70, 40, 0), 10))
		_fumo(r, f + Vector3(0, 0.3, 0), 3, 0.7)
	legnaia(r, Vector3(0.66, 0, -0.15), 0.25, 3)
	# bancone di terra cruda sotto la tenda con le focacce
	_tenda(r, Vector3(-0.32, 0, 0.5), 0.42, 0.24, 0.34, 0.26, 0.0, "tenda_rossa", true)
	r.add_child(scatola(Vector3(0.34, 0.1, 0.12), Vector3(-0.32, 0.05, 0.55), "terra_cruda"))
	r.add_child(scatola(Vector3(0.36, 0.014, 0.14), Vector3(-0.32, 0.107, 0.55), "zellige"))
	for i in 6:
		r.add_child(cilindro(0.032, 0.03, 0.012, Vector3(-0.45 + i * 0.052, 0.12 + (i % 2) * 0.006, 0.55 + (i % 2) * 0.02), "pane", Vector3(0, 0, (i % 3) * 6.0), 12))
	r.add_child(cesta(Vector3(-0.62, 0, 0.45), "pane"))
	r.add_child(cesta(Vector3(0.05, 0, 0.66), "pane"))
	r.add_child(sacco(Vector3(-0.68, 0, 0.15), 0.4))
	r.add_child(sacco(Vector3(-0.6, 0, 0.05), 1.4))
	r.add_child(anfora(Vector3(0.12, 0, 0.42), 1.1))
	r.add_child(anfora(Vector3(0.18, 0, 0.52), 1.0))
	return r


## Ovile dei Saraceni: stalla di terra cruda con il tetto piatto coperto di fieno, recinto di muretti arrotondati,
## pecore, abbeveratoio riempito dalla canaletta, lana e palma.
static func ovile_saraceni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.32, 0, -0.32)
	r.add_child(c)
	var lx := 0.62
	var lz := 0.48
	var top := _muri_s(c, lx, lz, 0.28, 871, "mattoni_crudi", false, false)
	_porta_s(c, Vector3(0.1, 0.07, lz * 0.5), 0.0, 0.14, 0.13, true)
	_finestra_s(c, Vector3(-0.15, 0.24, lz * 0.5), 0.0, 0.05, 0.05)
	for k in 3:
		c.add_child(sfera(0.1, Vector3(-0.16 + k * 0.13, top + 0.02, -0.06 + (k % 2) * 0.06), "paglia_tetto", Vector3(1.0, 0.55, 0.9)))
	for k in 2:
		c.add_child(scatola(Vector3(0.12, 0.06, 0.08), Vector3(0.18, top + 0.03 + k * 0.06, 0.1), "paglia", Vector3(0, k * 20.0, 0)))
	# recinto di muretti di terra cruda con la cima tonda
	var a := Vector3(0.1, 0, 0.1)
	for seg in [[Vector3(-0.34, 0, 0.45), Vector3(0.22, 0, 0.45)], [Vector3(0.48, 0, -0.22), Vector3(0.48, 0, 0.45)]]:
		var da: Vector3 = a + (seg[0] as Vector3)
		var b: Vector3 = a + (seg[1] as Vector3)
		_muro(r, da, b, 0.08, 0.04, "terra_cruda", false, "terra_cruda")
		var lung := da.distance_to(b)
		var nn := int(lung / 0.1)
		for k in nn + 1:
			r.add_child(cilindro(0.022, 0.022, 0.012, da.lerp(b, float(k) / nn) + Vector3(0, 0.085, 0), "calce", Vector3.ZERO, 8))
	# cancello di legno verde
	for k in 3:
		r.add_child(scatola(Vector3(0.012, 0.08, 0.012), a + Vector3(0.28 + k * 0.08, 0.04, 0.45), "legno_verde"))
	r.add_child(scatola(Vector3(0.22, 0.014, 0.012), a + Vector3(0.36, 0.06, 0.45), "legno_verde"))
	for p in [[Vector3(0.0, 0, 0.25), 30], [Vector3(0.2, 0, 0.05), 160], [Vector3(0.3, 0, 0.3), -40],
			[Vector3(-0.15, 0, 0.32), 90], [Vector3(0.32, 0, -0.12), 210]]:
		r.add_child(pecora(a + (p[0] as Vector3), p[1]))
	# abbeveratoio con la canaletta
	r.add_child(scatola(Vector3(0.24, 0.05, 0.08), a + Vector3(-0.2, 0.025, 0.05), "terra_cruda"))
	r.add_child(scatola(Vector3(0.21, 0.004, 0.055), a + Vector3(-0.2, 0.051, 0.05), "acqua_chiara"))
	_canaletta(r, Vector3(-0.72, 0, 0.15), a + Vector3(-0.32, 0, 0.05), 0.025)
	r.add_child(sfera(0.06, Vector3(-0.55, 0.04, 0.55), "lana", Vector3(1.2, 0.6, 1.0)))
	r.add_child(sfera(0.05, Vector3(-0.45, 0.035, 0.62), "lana", Vector3(1.2, 0.6, 1.0)))
	_palma(r, Vector3(-0.7, 0, 0.45), 0.75, 872)
	return r


## Capraio dei Saraceni: casetta con la cupola bianca, rocce chiare con le capre, muretto a secco,
## cesta di formaggi, giara e tenda a strisce.
static func capraio_saraceni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.3, 0, -0.3)
	r.add_child(c)
	var top := _muri_s(c, 0.5, 0.42, 0.26, 881, "calce", false, false)
	_porta_s(c, Vector3(-0.08, 0.07, 0.21), 0.0, 0.11, 0.13)
	_cupola(c, Vector3(0, top, 0), 0.18, "calce", false)
	_finestra_s(c, Vector3(0.25, 0.22, 0.0), 90.0, 0.05, 0.05)
	var a := Vector3(0.15, 0, 0.15)
	r.add_child(sfera(0.16, a + Vector3(0.2, 0.0, -0.1), "roccia_chiara", Vector3(1.2, 0.8, 1.0)))
	r.add_child(sfera(0.1, a + Vector3(-0.05, 0.0, 0.3), "roccia_chiara", Vector3(1.3, 0.7, 1.0)))
	r.add_child(capra(a + Vector3(0.2, 0.1, -0.1), 40))
	r.add_child(capra(a + Vector3(0.0, 0, 0.1), 200))
	r.add_child(capra(a + Vector3(0.35, 0, 0.25), -30))
	r.add_child(capra(a + Vector3(-0.1, 0.05, 0.3), 110))
	var rng := _rng(882)
	for k in 10:
		r.add_child(scatola(Vector3(0.09, 0.06, 0.06), a + Vector3(-0.4 + k * 0.095, 0.03, 0.5), "roccia_chiara" if k % 2 else "tufo", Vector3(0, rng.randf_range(-15, 15), 0)))
	_tenda(r, Vector3(-0.58, 0, 0.32), 0.26, 0.2, 0.26, 0.2, 0.0, "tenda_verde", true)
	r.add_child(anfora(Vector3(-0.62, 0, 0.22), 1.1))
	r.add_child(cesta(Vector3(-0.54, 0, 0.36), "formaggio"))
	return r


## Caserma dei Saraceni: casa forte di calce con i merli a gradini e due torrette, portone a ferro di cavallo,
## insegne verdi; campo di sabbia con il palo bersaglio, rastrelliera di lance con i pennoncelli e scudi tondi verdi.
static func caserma_saraceni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.3, 0, -0.3)
	r.add_child(c)
	var lx := 0.62
	var lz := 0.5
	var top := _muri_s(c, lx, lz, 0.36, 891)
	_porta_s(c, Vector3(0.06, 0.07, lz * 0.5), 0.0, 0.16, 0.17, true)
	_finestra_s(c, Vector3(lx * 0.5, 0.28, 0.0), 90.0)
	for x in [-1, 1]:
		var p := Vector3(x * (lx * 0.5 - 0.02), 0, lz * 0.5 - 0.02)
		c.add_child(scatola(Vector3(0.13, top + 0.14, 0.13), p + Vector3(0, (top + 0.14) * 0.5, 0), "calce"))
		c.add_child(scatola(Vector3(0.14, 0.022, 0.14), p + Vector3(0, top + 0.1, 0), "zellige"))
		_parapetto_s(c, 0.15, 0.15, top + 0.14, true)
	_stendardo_s(c, Vector3(lx * 0.5 - 0.02, top + 0.14, lz * 0.5 - 0.02), 0.42)
	_stendardo_s(c, Vector3(-lx * 0.5 + 0.02, top + 0.14, lz * 0.5 - 0.02), 0.36)
	# campo d'addestramento
	r.add_child(scatola(Vector3(0.75, 0.01, 0.55), Vector3(0.25, 0.005, 0.4), "sabbia"))
	r.add_child(cilindro(0.025, 0.025, 0.36, Vector3(0.5, 0.18, 0.35), "legno_vecchio", Vector3.ZERO, 8))
	r.add_child(cilindro(0.08, 0.08, 0.014, Vector3(0.5, 0.28, 0.39), "paglia", Vector3(90, 0, 0), 14))
	r.add_child(cilindro(0.045, 0.045, 0.016, Vector3(0.5, 0.28, 0.4), "stoffa_rossa", Vector3(90, 0, 0), 12))
	r.add_child(cilindro(0.018, 0.018, 0.018, Vector3(0.5, 0.28, 0.4), "calce", Vector3(90, 0, 0), 10))
	var cav := cavaliere_leggero()
	cav.position = Vector3(0.12, 0, 0.5)
	cav.rotation_degrees.y = 120
	cav.scale = Vector3.ONE * 0.9
	posa_galoppo(cav, 2, 8)
	r.add_child(cav)
	# rastrelliera di lance con i pennoncelli verdi e scudi tondi
	var rs := Vector3(-0.62, 0, 0.42)
	r.add_child(scatola(Vector3(0.03, 0.03, 0.3), rs + Vector3(0, 0.2, 0), "legno"))
	for lato: int in [-1, 1]:
		r.add_child(scatola(Vector3(0.03, 0.22, 0.03), rs + Vector3(0, 0.11, lato * 0.14), "legno_vecchio"))
	for k in 4:
		var z := -0.11 + k * 0.073
		r.add_child(cilindro(0.005, 0.005, 0.48, rs + Vector3(-0.02, 0.24, z), "legno", Vector3(0, 0, -8), 5))
		r.add_child(cilindro(0.01, 0.0, 0.04, rs + Vector3(-0.054, 0.5, z), "ferro", Vector3(0, 0, -8), 5))
		r.add_child(scatola(Vector3(0.004, 0.03, 0.05), rs + Vector3(-0.05, 0.44, z + 0.025), "stoffa_smeraldo"))
	for k in 2:
		var sc := Vector3(-0.5 + k * 0.1, 0.08, 0.62 - k * 0.03)
		r.add_child(cilindro(0.075, 0.075, 0.012, sc, "smeraldo", Vector3(70, 20, 0), 16))
		r.add_child(sfera(0.02, sc + Vector3(0, 0.004, 0.012), "moneta"))
	return r


## Qasr dei Saraceni (castello 3x3): mura di terra cruda con la fascia di calce e i merli a gradini, torri quadrate
## con le cupolette verdi, porta a ferro di cavallo fra due torri, palazzo con la grande cupola,
## giardino con i canali in croce, la fontana, gli aranci e le palme, insegne verdi.
static func castello_saraceni() -> Node3D:
	var r := Node3D.new()
	var lato := 2.3
	var h := 0.5
	r.add_child(scatola(Vector3(lato + 0.3, 0.06, lato + 0.3), Vector3(0, 0.03, 0), "terra_cruda"))
	r.add_child(scatola(Vector3(lato - 0.1, 0.008, lato - 0.1), Vector3(0, 0.064, 0), "sabbia"))
	var y0 := 0.06
	# mura: terra cruda, fascia alta di calce con la maiolica, merli a gradini
	for i in 4:
		var m := Node3D.new()
		m.rotation_degrees.y = i * 90
		r.add_child(m)
		m.add_child(scatola(Vector3(lato, h, 0.16), Vector3(0, y0 + h * 0.5, lato * 0.5), "mattoni_crudi"))
		m.add_child(scatola(Vector3(lato + 0.004, 0.1, 0.164), Vector3(0, y0 + h - 0.05, lato * 0.5), "calce"))
		m.add_child(scatola(Vector3(lato + 0.008, 0.026, 0.168), Vector3(0, y0 + h - 0.06, lato * 0.5), "zellige"))
		_fila_merli(m, Vector3(-lato * 0.5, y0 + h, lato * 0.5 + 0.05), Vector3(lato * 0.5, y0 + h, lato * 0.5 + 0.05), "calce", 1.4)
		# finte arcate sulle mura
		for k in 4:
			var x := -0.75 + k * 0.5
			if i == 0 and absf(x - 0.25) < 0.3:
				continue
			m.add_child(cilindro(0.06, 0.06, 0.01, Vector3(x, y0 + 0.28, lato * 0.5 + 0.08), "intonaco_sporco", Vector3(90, 0, 0), 14))
			m.add_child(scatola(Vector3(0.12, 0.14, 0.01), Vector3(x, y0 + 0.2, lato * 0.5 + 0.08), "intonaco_sporco"))
			m.add_child(scatola(Vector3(0.025, 0.08, 0.02), Vector3(x, y0 + 0.22, lato * 0.5 + 0.087), "buio"))
	# torri quadrate agli angoli con la cupoletta
	for x in [-1, 1]:
		for z in [-1, 1]:
			var p := Vector3(x * lato * 0.5, 0, z * lato * 0.5)
			var ht := h + 0.32
			r.add_child(scatola(Vector3(0.42, ht, 0.42), p + Vector3(0, y0 + ht * 0.5, 0), "mattoni_crudi"))
			r.add_child(scatola(Vector3(0.424, 0.14, 0.424), p + Vector3(0, y0 + ht - 0.07, 0), "calce"))
			r.add_child(scatola(Vector3(0.43, 0.03, 0.43), p + Vector3(0, y0 + ht - 0.09, 0), "zellige"))
			_finestra_s(r, p + Vector3(0, y0 + ht - 0.26, 0.21), 0.0, 0.06, 0.07)
			_finestra_s(r, p + Vector3(0.21, y0 + ht - 0.26, 0), 90.0, 0.06, 0.07)
			_parapetto_s(r, 0.46, 0.46, y0 + ht, true, "calce", 0.04)
			r.add_child(scatola(Vector3(0.2, 0.08, 0.2), p + Vector3(0, y0 + ht + 0.04, 0), "calce"))
			_cupola(r, p + Vector3(0, y0 + ht + 0.08, 0), 0.11, "maiolica_verde", false)
	# porta fra due torri sul lato in vista
	var gx := 0.25
	var gz := lato * 0.5
	for k: int in [-1, 1]:
		var p := Vector3(gx + k * 0.3, 0, gz + 0.02)
		r.add_child(scatola(Vector3(0.24, h + 0.2, 0.28), p + Vector3(0, y0 + (h + 0.2) * 0.5, 0), "mattoni_crudi"))
		r.add_child(scatola(Vector3(0.244, 0.1, 0.284), p + Vector3(0, y0 + h + 0.15, 0), "calce"))
		_parapetto_s(r, 0.26, 0.3, y0 + h + 0.2, true, "calce", 0.035)
	r.add_child(scatola(Vector3(0.38, 0.2, 0.2), Vector3(gx, y0 + h - 0.1 + 0.15, gz + 0.02), "calce"))
	_porta_s(r, Vector3(gx, y0, gz + 0.12), 0.0, 0.24, 0.24, false)
	_stendardo_s(r, Vector3(gx - 0.3, y0 + h + 0.2, gz + 0.02), 0.5)
	_stendardo_s(r, Vector3(gx + 0.3, y0 + h + 0.2, gz + 0.02), 0.5)
	# palazzo con la grande cupola (dietro a sinistra)
	var pc := Node3D.new()
	pc.position = Vector3(-0.38, y0 - 0.07, -0.4)
	r.add_child(pc)
	var tp := _muri_s(pc, 0.95, 0.8, 0.5, 901)
	_porta_s(pc, Vector3(0.0, 0.07, 0.4), 0.0, 0.16, 0.18)
	for x in [-0.3, 0.3]:
		_finestra_s(pc, Vector3(x, 0.3, 0.4), 0.0, 0.07, 0.08)
	_finestra_s(pc, Vector3(0.475, 0.3, -0.15), 90.0, 0.07, 0.08)
	_finestra_s(pc, Vector3(0.475, 0.3, 0.15), 90.0, 0.07, 0.08)
	pc.add_child(scatola(Vector3(0.6, 0.14, 0.6), Vector3(0, tp + 0.07, -0.05), "calce"))
	pc.add_child(scatola(Vector3(0.64, 0.022, 0.64), Vector3(0, tp + 0.14, -0.05), "zellige"))
	_cupola(pc, Vector3(0, tp + 0.15, -0.05), 0.27)
	_tappeto(pc, Vector3(0.28, tp + 0.05, 0.43), 0.0, 0.13, 0.15)
	# torretta alta accanto al palazzo
	var tt := Vector3(0.55, y0, -0.7)
	r.add_child(scatola(Vector3(0.24, 1.0, 0.24), tt + Vector3(0, 0.5, 0), "calce"))
	r.add_child(scatola(Vector3(0.25, 0.03, 0.25), tt + Vector3(0, 0.75, 0), "zellige"))
	_finestra_s(r, tt + Vector3(0, 0.84, 0.12), 0.0, 0.06, 0.07)
	_finestra_s(r, tt + Vector3(0.12, 0.84, 0), 90.0, 0.06, 0.07)
	_parapetto_s(r, 0.28, 0.28, tt.y + 1.0, true, "calce", 0.035)
	_cupola(r, tt + Vector3(0, 1.0, 0), 0.09, "maiolica_verde", false)
	_stendardo_s(r, tt + Vector3(0.1, 1.08, 0.1), 0.4)
	# giardino con i canali in croce, fontana, aranci e palme
	var gd := Vector3(0.45, y0, 0.4)
	r.add_child(scatola(Vector3(0.95, 0.008, 0.85), gd + Vector3(0, 0.004, 0), "orto"))
	_canaletta(r, gd + Vector3(-0.47, 0, 0), gd + Vector3(0.47, 0, 0), 0.04)
	_canaletta(r, gd + Vector3(0, 0, -0.42), gd + Vector3(0, 0, 0.42), 0.04)
	_vasca(r, gd, 0.12)
	for q in 4:
		var sx := 1 if q % 2 == 0 else -1
		var sz := 1 if q < 2 else -1
		_arancio(r, gd + Vector3(sx * 0.24, 0, sz * 0.21), 0.75, 910 + q)
	_palma(r, gd + Vector3(0.42, 0, -0.38), 1.0, 921)
	_palma(r, Vector3(-0.85, y0, 0.55), 1.05, 922)
	_palma(r, Vector3(-0.6, y0, 0.75), 0.85, 923)
	_tenda(r, Vector3(-0.75, y0, 0.2), 0.36, 0.26, 0.3, 0.24, 90.0, "tenda_verde", true)
	for k in 3:
		r.add_child(cassa(Vector3(-0.7, y0, -0.05 - k * 0.12), k * 20))
	r.add_child(anfora(Vector3(-0.85, y0, 0.0), 1.2))
	return r


## Torre di guardia dei Saraceni: fusto quadrato di terra cruda con la parte alta di calce, fasce di maiolica,
## finestre a ferro di cavallo, ballatoio merlato su mensole e chiosco con la cupoletta verde e l'insegna.
static func torre_saraceni() -> Node3D:
	var r := Node3D.new()
	var lato := 0.52
	var h := 1.2
	r.add_child(scatola(Vector3(lato + 0.16, 0.08, lato + 0.16), Vector3(0, 0.04, 0), "terra_cruda"))
	r.add_child(scatola(Vector3(lato + 0.06, 0.16, lato + 0.06), Vector3(0, 0.16, 0), "mattoni_crudi"))
	r.add_child(scatola(Vector3(lato, h, lato), Vector3(0, 0.08 + h * 0.5, 0), "mattoni_crudi"))
	r.add_child(scatola(Vector3(lato + 0.006, 0.45, lato + 0.006), Vector3(0, 0.08 + h - 0.225, 0), "calce"))
	for y in [0.08 + h - 0.45, 0.08 + h - 0.06]:
		r.add_child(scatola(Vector3(lato + 0.012, 0.03, lato + 0.012), Vector3(0, y, 0), "zellige"))
	# arcate cieche e finestre a ferro di cavallo
	_finestra_s(r, Vector3(0.0, 0.62, lato * 0.5), 0.0, 0.05, 0.08)
	_finestra_s(r, Vector3(lato * 0.5, 0.62, 0.0), 90.0, 0.05, 0.08)
	for k: int in [-1, 1]:
		_finestra_s(r, Vector3(k * 0.12, 1.02, lato * 0.5 + 0.003), 0.0, 0.07, 0.1)
		_finestra_s(r, Vector3(lato * 0.5 + 0.003, 1.02, k * 0.12), 90.0, 0.07, 0.1)
	_porta_s(r, Vector3(-0.06, 0.24, lato * 0.5), 0.0, 0.13, 0.17)
	# ballatoio sporgente su mensole, merli a gradini
	var top := 0.08 + h
	for k in 5:
		var off := -lato * 0.5 + k * lato / 4
		r.add_child(scatola(Vector3(0.04, 0.06, 0.05), Vector3(off, top - 0.03, lato * 0.5 + 0.03), "legno_vecchio"))
		r.add_child(scatola(Vector3(0.05, 0.06, 0.04), Vector3(lato * 0.5 + 0.03, top - 0.03, off), "legno_vecchio"))
	r.add_child(scatola(Vector3(lato + 0.14, 0.04, lato + 0.14), Vector3(0, top + 0.02, 0), "terra_cruda"))
	_parapetto_s(r, lato + 0.14, lato + 0.14, top + 0.04, true, "calce", 0.05)
	# chiosco con quattro pilastrini e la cupoletta
	for x in [-0.13, 0.13]:
		for z in [-0.13, 0.13]:
			r.add_child(scatola(Vector3(0.04, 0.2, 0.04), Vector3(x, top + 0.14, z), "calce"))
	r.add_child(scatola(Vector3(0.34, 0.04, 0.34), Vector3(0, top + 0.26, 0), "calce"))
	r.add_child(scatola(Vector3(0.35, 0.018, 0.35), Vector3(0, top + 0.25, 0), "zellige"))
	_cupola(r, Vector3(0, top + 0.28, 0), 0.15, "maiolica_verde", false)
	r.add_child(cilindro(0.04, 0.04, 0.06, Vector3(0, top + 0.07, 0), "brace", Vector3.ZERO, 8))
	_stendardo_s(r, Vector3(lato * 0.5 + 0.03, top + 0.04, lato * 0.5 + 0.03), 0.5)
	# giare, scudi tondi e lance alla base
	r.add_child(anfora(Vector3(lato * 0.5 + 0.15, 0.0, 0.2), 1.2))
	r.add_child(cassa(Vector3(lato * 0.5 + 0.17, 0.0, 0.0), 10))
	r.add_child(cilindro(0.07, 0.07, 0.012, Vector3(lato * 0.5 + 0.1, 0.08, -0.18), "smeraldo", Vector3(0, 0, 70), 16))
	for k in 3:
		r.add_child(cilindro(0.005, 0.005, 0.36, Vector3(-0.22 + k * 0.04, 0.18, lato * 0.5 + 0.08), "legno", Vector3(-12, 0, 0), 5))
	return r


## Bachicoltura (edificio unico dei Saraceni): casa bassa con la terrazza dove, sotto la stuoia, stanno i graticci
## di canne con le foglie di gelso e i bachi bianchi; graticci anche sotto la tenda davanti, gelsi tutto intorno,
## scala appoggiata, ceste di foglie e di bozzoli.
static func bachicoltura() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.15, 0, -0.2)
	r.add_child(c)
	var lx := 0.86
	var lz := 0.6
	var top := _muri_s(c, lx, lz, 0.28, 931)
	_porta_s(c, Vector3(-0.22, 0.07, lz * 0.5), 0.0, 0.12, 0.14)
	_finestra_s(c, Vector3(0.12, 0.23, lz * 0.5), 0.0, 0.06, 0.06)
	_finestra_s(c, Vector3(lx * 0.5, 0.23, 0.0), 90.0, 0.06, 0.06)
	# sulla terrazza: castello di pali con tre piani di graticci e la stuoia di canne sopra
	var g := Node3D.new()
	g.position = Vector3(0.0, top, -0.02)
	c.add_child(g)
	for x in [-0.32, 0.32]:
		for z in [-0.18, 0.18]:
			g.add_child(cilindro(0.01, 0.01, 0.3, Vector3(x, 0.15, z), "legno", Vector3.ZERO, 5))
	g.add_child(scatola(Vector3(0.74, 0.012, 0.44), Vector3(0, 0.305, 0), "canne", Vector3(4, 0, 0)))
	for k in 3:
		_graticcio_bachi(g, Vector3(0, 0.05 + k * 0.08, 0), 0.6, 0.32, 930 + k)
	# graticci all'aperto sotto la tenda davanti
	for k in 2:
		var p := Vector3(0.38, 0.0, 0.42)
		for x in [-0.18, 0.18]:
			for z in [-0.12, 0.12]:
				r.add_child(cilindro(0.006, 0.006, 0.18, p + Vector3(x, 0.09, z), "legno_vecchio", Vector3.ZERO, 4))
		_graticcio_bachi(r, p + Vector3(0, 0.06 + k * 0.1, 0), 0.4, 0.28, 940 + k)
	# gelsi tutto intorno, scala, ceste
	_gelso(r, Vector3(-0.7, 0, 0.35), 1.0, 951)
	_gelso(r, Vector3(0.72, 0, -0.5), 0.95, 952)
	_gelso(r, Vector3(-0.35, 0, 0.75), 0.8, 953)
	ramo(r, Vector3(-0.55, 0, 0.25), Vector3(-0.66, 0.36, 0.32), 0.008, "legno")
	ramo(r, Vector3(-0.5, 0, 0.32), Vector3(-0.61, 0.36, 0.39), 0.008, "legno")
	for k in 4:
		r.add_child(scatola(Vector3(0.006, 0.006, 0.08), Vector3(-0.565 - k * 0.022, 0.07 + k * 0.08, 0.3 + k * 0.016), "legno", Vector3(0, 0, 0)))
	r.add_child(cesta(Vector3(-0.15, 0, 0.5), "ortaggi", 1.1))
	var cb := merce("bozzoli")
	cb.position = Vector3(0.0, 0, 0.62)
	cb.scale = Vector3.ONE
	r.add_child(cb)
	return r


## Graticcio di canne con le foglie di gelso e i bachi bianchi sopra (pos = centro del piano).
static func _graticcio_bachi(r: Node3D, pos: Vector3, lx: float, lz: float, seme: int) -> void:
	var rng := _rng(seme)
	r.add_child(scatola(Vector3(lx, 0.01, lz), pos, "canne"))
	r.add_child(scatola(Vector3(lx + 0.02, 0.014, 0.012), pos + Vector3(0, 0.004, lz * 0.5), "legno"))
	r.add_child(scatola(Vector3(0.012, 0.014, lz + 0.02), pos + Vector3(lx * 0.5, 0.004, 0), "legno"))
	var n := int(lx * lz / 0.004)
	for k in n:
		var p := pos + Vector3(rng.randf_range(-lx * 0.45, lx * 0.45), 0.008, rng.randf_range(-lz * 0.45, lz * 0.45))
		var f := sfera(0.018, p, "foglie_chiare" if k % 3 else "foglie", Vector3(1.2, 0.15, 1.0))
		f.rotation_degrees.y = rng.randf() * 180
		r.add_child(f)
	for k in n / 2:
		var p := pos + Vector3(rng.randf_range(-lx * 0.45, lx * 0.45), 0.013, rng.randf_range(-lz * 0.45, lz * 0.45))
		var b := sfera(0.006, p, "bozzolo", Vector3(2.4, 0.9, 0.9))
		b.rotation_degrees.y = rng.randf() * 180
		r.add_child(b)


## Filanda (edificio unico dei Saraceni): laboratorio di calce con il portico di tre archi a ferro di cavallo; davanti
## le bacinelle di rame sull'acqua calda (fornelli con le braci e il vapore), gli aspi che avvolgono il filo,
## le matasse di seta colorata stese sulle pertiche, ceste di bozzoli.
static func filanda() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.15, 0, -0.25)
	r.add_child(c)
	var lx := 0.95
	var lz := 0.58
	var top := _muri_s(c, lx, lz, 0.4, 961)
	for k in 3:
		_porta_s(c, Vector3(-0.3 + k * 0.3, 0.07, lz * 0.5), 0.0, 0.17, 0.17, k != 1)
	_finestra_s(c, Vector3(lx * 0.5, 0.27, -0.1), 90.0)
	_finestra_s(c, Vector3(lx * 0.5, 0.27, 0.14), 90.0)
	c.add_child(scatola(Vector3(0.28, 0.1, 0.28), Vector3(0.22, top + 0.05, -0.1), "calce"))
	_cupola(c, Vector3(0.22, top + 0.1, -0.1), 0.12, "maiolica_verde", false)
	c.add_child(scatola(Vector3(0.06, 0.16, 0.06), Vector3(-0.3, top + 0.08, -0.15), "terra_cruda"))
	_fumo(c, Vector3(-0.3, top + 0.2, -0.15), 3, 0.8)
	_stendardo_s(c, Vector3(-lx * 0.5 + 0.05, top, lz * 0.5 - 0.05), 0.4)
	# fornelli con le bacinelle di rame piene d'acqua calda e i bozzoli che galleggiano
	for k in 2:
		var b := Vector3(-0.42 + k * 0.28, 0, 0.32)
		r.add_child(scatola(Vector3(0.16, 0.12, 0.14), b + Vector3(0, 0.06, 0), "terra_cruda"))
		r.add_child(scatola(Vector3(0.06, 0.04, 0.01), b + Vector3(0, 0.035, 0.071), "brace"))
		r.add_child(cilindro(0.07, 0.055, 0.05, b + Vector3(0, 0.145, 0), "bronzo", Vector3.ZERO, 14))
		r.add_child(cilindro(0.063, 0.063, 0.004, b + Vector3(0, 0.168, 0), "acqua_chiara", Vector3.ZERO, 14))
		for j in 5:
			r.add_child(sfera(0.009, b + Vector3(cos(j * 1.3) * 0.035, 0.172, sin(j * 1.3) * 0.035), "bozzolo", Vector3(1.4, 1, 1)))
		_vapore(r, b + Vector3(0, 0.2, 0))
		# aspo che avvolge il filo, dietro la bacinella
		_aspo(r, b + Vector3(0, 0, 0.17), "seta_oro" if k == 0 else "bozzolo")
	# pertiche con le matasse di seta colorate stese ad asciugare
	var tinte := ["seta_cremisi", "seta_verde", "seta_oro", "seta_azzurra", "seta_zafferano", "seta_verde", "seta_cremisi"]
	for f in 2:
		var pz := -0.1 + f * 0.3
		var px := 0.62
		for lato: int in [-1, 1]:
			r.add_child(cilindro(0.01, 0.012, 0.36, Vector3(px, 0.18, pz + lato * 0.13), "legno_vecchio", Vector3.ZERO, 5))
		r.add_child(cilindro(0.007, 0.007, 0.3, Vector3(px, 0.35, pz), "legno", Vector3(90, 0, 0), 5))
		for k in 5:
			r.add_child(_toro(0.016, 0.03, Vector3(px, 0.27, pz - 0.1 + k * 0.05), tinte[(k + f * 2) % tinte.size()], Vector3(0, 0, 90), Vector3(2.6, 1.1, 0.8)))
	# ceste di bozzoli e matasse pronte
	var cb := merce("bozzoli")
	cb.position = Vector3(-0.66, 0, 0.5)
	cb.scale = Vector3.ONE
	r.add_child(cb)
	var cs := merce("seta")
	cs.position = Vector3(0.1, 0, 0.62)
	cs.scale = Vector3.ONE
	r.add_child(cs)
	r.add_child(anfora(Vector3(-0.68, 0, 0.25), 1.1))
	return r


## Aspo da seta: due ritti, asse con sei razze e traverse avvolte di filo, manovella (pos = centro a terra, asse lungo X).
static func _aspo(r: Node3D, pos: Vector3, mat_filo := "seta_oro") -> void:
	for lato: int in [-1, 1]:
		r.add_child(scatola(Vector3(0.016, 0.2, 0.03), pos + Vector3(lato * 0.1, 0.1, 0), "legno"))
		r.add_child(scatola(Vector3(0.02, 0.012, 0.1), pos + Vector3(lato * 0.1, 0.006, 0), "legno_vecchio"))
	r.add_child(cilindro(0.008, 0.008, 0.24, pos + Vector3(0, 0.18, 0), "legno_scuro", Vector3(0, 0, 90), 6))
	for k in 6:
		var a := k * TAU / 6
		for lato: int in [-1, 1]:
			r.add_child(scatola(Vector3(0.006, 0.07, 0.006), pos + Vector3(lato * 0.07, 0.18 + sin(a) * 0.035, cos(a) * 0.035), "legno", Vector3(-rad_to_deg(a), 0, 0)))
		r.add_child(cilindro(0.006, 0.006, 0.16, pos + Vector3(0, 0.18 + sin(a) * 0.07, cos(a) * 0.07), "legno_chiaro", Vector3(0, 0, 90), 4))
	r.add_child(cilindro(0.068, 0.068, 0.12, pos + Vector3(0, 0.18, 0), mat_filo, Vector3(0, 0, 90), 6))
	r.add_child(scatola(Vector3(0.01, 0.05, 0.01), pos + Vector3(0.13, 0.16, 0), "legno"))


## Vapore che sale dalle bacinelle calde: sbuffi chiari e radi.
static func _vapore(r: Node3D, pos: Vector3) -> void:
	for k in 3:
		r.add_child(sfera(0.02 + k * 0.01, pos + Vector3(k * 0.012, k * 0.05, -k * 0.01), "vapore", Vector3(1.1, 0.8, 1.0)))


## Cavaliere leggero dei Saraceni: cavallo grigio snello con la gualdrappa verde smeraldo frangiata d'oro,
## cavaliere col turbante bianco, mantello verde, scudo tondo verde con l'umbone d'oro e lancia leggera col pennoncello.
## Il muso del cavallo guarda verso +Z come il viso dei portatori. Nodi animati: corpo, collo, zampe, cavaliere.
static func cavaliere_leggero() -> Node3D:
	var r := Node3D.new()
	var corpo := Node3D.new()
	corpo.name = "corpo"
	r.add_child(corpo)
	# zampe: spalla, stinco (nodo del ginocchio), zoccolo
	for nome in ["zampa_as", "zampa_ad", "zampa_ps", "zampa_pd"]:
		var davanti: bool = nome.begins_with("zampa_a")
		var lato := -1.0 if nome.ends_with("s") else 1.0
		var z := Node3D.new()
		z.name = nome
		z.position = Vector3(lato * 0.042, 0.27, 0.12 if davanti else -0.12)
		corpo.add_child(z)
		z.add_child(cilindro(0.022 if davanti else 0.028, 0.015, 0.13, Vector3(0, -0.065, 0), "cavallo", Vector3.ZERO, 7))
		var st := Node3D.new()
		st.name = "stinco"
		st.position = Vector3(0, -0.13, 0)
		z.add_child(st)
		st.add_child(cilindro(0.013, 0.011, 0.12, Vector3(0, -0.06, 0), "cavallo", Vector3.ZERO, 6))
		st.add_child(cilindro(0.015, 0.017, 0.022, Vector3(0, -0.123, 0.004), "crine", Vector3.ZERO, 7))
	# corpo snello, petto e groppa
	corpo.add_child(sfera(0.1, Vector3(0, 0.31, 0), "cavallo", Vector3(0.7, 0.78, 1.85)))
	corpo.add_child(sfera(0.078, Vector3(0, 0.315, 0.12), "cavallo", Vector3(0.92, 1.05, 1.0)))
	corpo.add_child(sfera(0.08, Vector3(0, 0.325, -0.12), "cavallo", Vector3(0.95, 1.0, 1.05)))
	# collo e testa (nodo che annuisce)
	var collo := Node3D.new()
	collo.name = "collo"
	collo.position = Vector3(0, 0.34, 0.15)
	corpo.add_child(collo)
	var cn := Node3D.new()
	cn.rotation_degrees.x = 32
	collo.add_child(cn)
	cn.add_child(cilindro(0.032, 0.05, 0.2, Vector3(0, 0.08, 0), "cavallo", Vector3.ZERO, 8))
	cn.add_child(scatola(Vector3(0.016, 0.19, 0.03), Vector3(0, 0.085, -0.035), "crine"))
	for k in 4:
		cn.add_child(scatola(Vector3(0.022, 0.035, 0.03), Vector3(0.008 * (k % 2 * 2 - 1), 0.02 + k * 0.045, -0.042), "crine", Vector3(0, 0, 12 * (k % 2 * 2 - 1))))
	var testa := sfera(0.042, Vector3(0, 0.165, 0.135), "cavallo", Vector3(0.75, 0.8, 1.55))
	testa.rotation_degrees.x = 38
	collo.add_child(testa)
	collo.add_child(sfera(0.03, Vector3(0, 0.12, 0.19), "cavallo_muso", Vector3(0.85, 0.85, 1.1)))
	for lato: int in [-1, 1]:
		collo.add_child(cilindro(0.008, 0.002, 0.04, Vector3(lato * 0.017, 0.215, 0.1), "cavallo", Vector3(-15, 0, lato * 12.0), 5))
		collo.add_child(sfera(0.007, Vector3(lato * 0.03, 0.17, 0.15), "crine"))
	# finimenti rossi e d'oro: capezza, pettorale con le nappe
	collo.add_child(_toro(0.028, 0.034, Vector3(0, 0.13, 0.175), "stoffa_rossa", Vector3(60, 0, 0), Vector3(1, 1, 1.1)))
	collo.add_child(_toro(0.04, 0.047, Vector3(0, 0.16, 0.115), "stoffa_rossa", Vector3(-30, 0, 0)))
	corpo.add_child(_toro(0.07, 0.078, Vector3(0, 0.3, 0.16), "stoffa_rossa", Vector3(70, 0, 0), Vector3(0.9, 1, 1)))
	for k in 5:
		var a := deg_to_rad(-60.0 + k * 30.0)
		corpo.add_child(sfera(0.009, Vector3(sin(a) * 0.068, 0.27 - cos(a) * 0.02, 0.19 + cos(a) * 0.01), "moneta"))
	# coda lunga scura
	corpo.add_child(cilindro(0.024, 0.012, 0.22, Vector3(0, 0.25, -0.25), "crine", Vector3(25, 0, 0), 7))
	corpo.add_child(sfera(0.025, Vector3(0, 0.36, -0.205), "crine"))
	# gualdrappa verde smeraldo con l'orlo d'oro, sella
	corpo.add_child(scatola(Vector3(0.17, 0.012, 0.17), Vector3(0, 0.39, -0.01), "stoffa_smeraldo"))
	for lato: int in [-1, 1]:
		corpo.add_child(scatola(Vector3(0.008, 0.09, 0.17), Vector3(lato * 0.081, 0.345, -0.01), "stoffa_smeraldo"))
		corpo.add_child(scatola(Vector3(0.01, 0.014, 0.172), Vector3(lato * 0.082, 0.3, -0.01), "moneta"))
		corpo.add_child(scatola(Vector3(0.01, 0.03, 0.03), Vector3(lato * 0.083, 0.35, -0.01), "seta_cremisi"))
	corpo.add_child(scatola(Vector3(0.09, 0.03, 0.11), Vector3(0, 0.405, -0.015), "pelle_scura"))
	corpo.add_child(scatola(Vector3(0.07, 0.04, 0.016), Vector3(0, 0.425, 0.04), "pelle_scura"))
	# cavaliere seduto: turbante, barba, veste bianca, mantello verde, scudo tondo, lancia leggera
	var cav := portatore("", "smeraldo", "lino_bianco")
	cav.name = "cavaliere"
	cav.scale = Vector3.ONE * 0.85
	cav.position = Vector3(0, 0.425 - 0.2 * 0.85, -0.02)
	corpo.add_child(cav)
	var cc: Node3D = cav.get_node("corpo")
	var anca := 0.2
	(cc.get_node("gamba_s") as Node3D).rotation = Vector3(-0.75, 0, -0.5)
	(cc.get_node("gamba_d") as Node3D).rotation = Vector3(-0.75, 0, 0.5)
	cc.add_child(sfera(0.084, Vector3(0, anca + 0.29, -0.006), "lino_bianco", Vector3(1.05, 0.72, 1.08)))
	cc.add_child(_toro(0.06, 0.084, Vector3(0, anca + 0.275, -0.004), "lino_bianco", Vector3(-8, 0, 0), Vector3(1, 1.4, 1.03)))
	cc.add_child(sfera(0.014, Vector3(0, anca + 0.29, 0.08), "smeraldo"))
	cc.add_child(scatola(Vector3(0.035, 0.09, 0.012), Vector3(0.02, anca + 0.22, -0.078), "lino_bianco", Vector3(10, 0, 0)))
	cc.add_child(sfera(0.042, Vector3(0, anca + 0.205, 0.04), "capelli", Vector3(1, 0.85, 0.75)))
	cc.add_child(scatola(Vector3(0.14, 0.17, 0.014), Vector3(0, anca + 0.09, -0.07), "stoffa_smeraldo", Vector3(14, 0, 0)))
	cc.add_child(cilindro(0.086, 0.086, 0.018, Vector3(0, anca + 0.07, 0), "seta_cremisi", Vector3.ZERO, 12))
	var bs: Node3D = cc.get_node("braccio_s")
	bs.add_child(cilindro(0.08, 0.08, 0.008, Vector3(-0.022, -0.085, 0.03), "moneta", Vector3(0, 0, 90), 18))
	bs.add_child(cilindro(0.074, 0.074, 0.01, Vector3(-0.028, -0.085, 0.03), "smeraldo", Vector3(0, 0, 90), 18))
	bs.add_child(sfera(0.022, Vector3(-0.034, -0.085, 0.03), "moneta", Vector3(0.6, 1, 1)))
	for k in 8:
		var a := k * TAU / 8
		bs.add_child(sfera(0.007, Vector3(-0.034, -0.085 + sin(a) * 0.05, 0.03 + cos(a) * 0.05), "calce"))
	var bd: Node3D = cc.get_node("braccio_d")
	bd.add_child(cilindro(0.006, 0.006, 0.54, Vector3(0, -0.14, 0.14), "legno", Vector3(90, 0, 0), 5))
	bd.add_child(cilindro(0.014, 0.0, 0.055, Vector3(0, -0.14, 0.437), "ferro", Vector3(90, 0, 0), 6))
	bd.add_child(scatola(Vector3(0.004, 0.035, 0.07), Vector3(0, -0.12, 0.36), "stoffa_smeraldo"))
	r.set_meta("carico", "lancia")
	return r


## Andatura del cavallo (piccolo galoppo): zampe a coppie sfasate con il ginocchio che si piega, corpo che ondeggia,
## testa che annuisce; il cavaliere tiene la lancia alta e lo scudo al fianco.
static func posa_galoppo(modello: Node3D, fotogramma: int, totale: int) -> void:
	var t := float(fotogramma) / totale * TAU
	var corpo: Node3D = modello.get_node("corpo")
	corpo.position.y = 0.012 + sin(t * 2.0) * 0.012
	corpo.rotation.x = sin(t) * 0.05
	var fasi := {"zampa_as": 0.0, "zampa_ad": 0.6, "zampa_ps": PI, "zampa_pd": PI + 0.6}
	for nome: String in fasi:
		var z: Node3D = corpo.get_node(nome)
		var f: float = t + fasi[nome]
		var davanti := nome.begins_with("zampa_a")
		z.rotation.x = sin(f) * (0.55 if davanti else 0.45)
		(z.get_node("stinco") as Node3D).rotation.x = maxf(0.0, cos(f)) * (0.9 if davanti else -0.5)
	(corpo.get_node("collo") as Node3D).rotation.x = cos(t) * 0.1
	var cc: Node3D = corpo.get_node("cavaliere/corpo")
	cc.rotation.x = 0.06 + sin(t) * 0.03
	var bd: Node3D = cc.get_node("braccio_d")
	bd.position = Vector3(0.07, 0.355, 0)
	bd.rotation = Vector3(-1.15 + sin(t) * 0.05, 0, 0.12)
	(cc.get_node("braccio_s") as Node3D).rotation = Vector3(-0.45, 0, -0.3)


## Carica del cavaliere: il cavallo si impenna appena scalciando con le zampe davanti, il cavaliere si sporge
## e affonda la lancia in avanti, lo scudo alzato.
static func posa_carica(modello: Node3D, fotogramma: int, totale: int) -> void:
	var t := float(fotogramma) / totale * TAU
	var affondo := maxf(0.0, sin(t))
	var corpo: Node3D = modello.get_node("corpo")
	corpo.position.y = 0.01 + affondo * 0.02
	corpo.rotation.x = -0.08 * affondo
	for nome in ["zampa_as", "zampa_ad"]:
		var z: Node3D = corpo.get_node(nome)
		var k := 0.0 if nome == "zampa_as" else 0.8
		z.rotation.x = -0.5 * maxf(0.0, sin(t + k)) - 0.05
		(z.get_node("stinco") as Node3D).rotation.x = 0.9 * maxf(0.0, sin(t + k))
	for nome in ["zampa_ps", "zampa_pd"]:
		var z: Node3D = corpo.get_node(nome)
		z.rotation.x = 0.2
		(z.get_node("stinco") as Node3D).rotation.x = -0.25
	(corpo.get_node("collo") as Node3D).rotation.x = -0.15 * affondo
	var cc: Node3D = corpo.get_node("cavaliere/corpo")
	cc.rotation.x = 0.1 + affondo * 0.2
	var bd: Node3D = cc.get_node("braccio_d")
	bd.position = Vector3(0.07, 0.355, affondo * 0.05)
	bd.rotation = Vector3(-0.85 + affondo * 0.75, 0, 0.12)
	(cc.get_node("braccio_s") as Node3D).rotation = Vector3(-0.95 + 0.15 * sin(t * 2.0), 0, -0.35)


# ------------------------------------------------------------------ altri edifici dei Saraceni (step G6c)
# Stesso ingombro e stessa disposizione del corrispondente greco (stesso nome senza "_saraceni").

## Comignolo di terra cruda con la bocca annerita e il fumo, sulla terrazza (pos = piede sulla terrazza).
static func _camino_s(c: Node3D, pos: Vector3, h := 0.14) -> void:
	c.add_child(scatola(Vector3(0.06, h, 0.06), pos + Vector3(0, h * 0.5, 0), "terra_cruda"))
	c.add_child(scatola(Vector3(0.075, 0.025, 0.075), pos + Vector3(0, h, 0), "calce"))
	c.add_child(scatola(Vector3(0.04, 0.006, 0.04), pos + Vector3(0, h + 0.014, 0), "fuliggine"))
	_fumo(c, pos + Vector3(0, h + 0.05, 0), 3, 0.8)


## Muretto di terra cruda con la cima tonda di calce fra due punti a terra (come i recinti dei Saraceni).
static func _muretto_s(r: Node3D, da: Vector3, a: Vector3, h := 0.08) -> void:
	_muro(r, da, a, h, 0.04, "terra_cruda", false, "terra_cruda")
	var nn := maxi(1, int(da.distance_to(a) / 0.1))
	for k in nn + 1:
		r.add_child(cilindro(0.022, 0.022, 0.012, da.lerp(a, float(k) / nn) + Vector3(0, h + 0.005, 0), "calce", Vector3.ZERO, 8))


## Cancelletto di legno verde fra due punti a terra.
static func _cancello_s(r: Node3D, da: Vector3, a: Vector3, h := 0.08) -> void:
	var n := 3
	for k in n:
		r.add_child(scatola(Vector3(0.012, h, 0.012), da.lerp(a, (k + 0.5) / n) + Vector3(0, h * 0.5, 0), "legno_verde"))
	var d := a - da
	r.add_child(scatola(Vector3(Vector2(d.x, d.z).length(), 0.014, 0.012), (da + a) * 0.5 + Vector3(0, h * 0.75, 0), "legno_verde", Vector3(0, rad_to_deg(atan2(-d.z, d.x)), 0)))


## Pergola di pali coperta da una stuoia di canne (gronda verso +Z locale), con i correnti in vista.
static func _pergola_s(r: Node3D, pos: Vector3, larg: float, prof: float, h: float, rot_y := 0.0) -> void:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot_y
	r.add_child(n)
	for lato: int in [-1, 1]:
		for z: float in [-prof * 0.5, prof * 0.5]:
			var hp := h + (0.03 if z < 0 else 0.0)
			n.add_child(cilindro(0.013, 0.013, hp, Vector3(lato * (larg * 0.5 - 0.02), hp * 0.5, z), "legno_vecchio", Vector3.ZERO, 6))
	n.add_child(scatola(Vector3(larg + 0.04, 0.014, prof + 0.06), Vector3(0, h + 0.022, 0), "canne", Vector3(-5, 0, 0)))
	var nc := maxi(2, int(larg / 0.12))
	for k in nc + 1:
		n.add_child(cilindro(0.007, 0.007, prof + 0.08, Vector3(-larg * 0.5 + k * larg / nc, h + 0.032, 0), "legno", Vector3(90 - 5, 0, 0), 5))


## Guardia dei Saraceni: veste bianca, turbante bianco con il giro verde, lancia con il pennoncello.
static func _guardia_s(pos: Vector3, s := 0.9) -> Node3D:
	var g := portatore("", "giocatore", "lino_bianco")
	g.position = pos
	g.scale = Vector3.ONE * s
	g.add_child(sfera(0.088, Vector3(0, 0.5, -0.005), "lino_bianco", Vector3(1.05, 0.72, 1.05)))
	g.add_child(_toro(0.07, 0.092, Vector3(0, 0.485, -0.005), "stoffa_smeraldo", Vector3.ZERO, Vector3(1, 0.8, 1)))
	g.add_child(sfera(0.014, Vector3(0, 0.49, 0.085), "moneta"))
	g.add_child(cilindro(0.006, 0.006, 0.5, Vector3(0.09, 0.25, 0.0), "legno", Vector3.ZERO, 5))
	g.add_child(scatola(Vector3(0.012, 0.06, 0.03), Vector3(0.09, 0.51, 0.0), "ferro"))
	g.add_child(scatola(Vector3(0.004, 0.03, 0.05), Vector3(0.09, 0.45, 0.025), "stoffa_smeraldo"))
	return g


## Porcile dei Saraceni: stalla di terra cruda col fieno sul tetto piatto, recinto di muretti tondi
## con il cancelletto verde, truogolo riempito dalla canaletta, maiali nel fango, giara e palma.
static func porcile_saraceni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.3, 0, -0.3)
	r.add_child(c)
	var lx := 0.6
	var lz := 0.46
	var top := _muri_s(c, lx, lz, 0.28, 1101, "mattoni_crudi", false, false)
	_porta_s(c, Vector3(-0.1, 0.07, lz * 0.5), 0.0, 0.12, 0.13, true)
	_finestra_s(c, Vector3(lx * 0.5, 0.24, 0.0), 90.0, 0.05, 0.05)
	for k in 2:
		c.add_child(sfera(0.1, Vector3(-0.12 + k * 0.16, top + 0.02, -0.04 + k * 0.05), "paglia_tetto", Vector3(1.0, 0.55, 0.9)))
	c.add_child(scatola(Vector3(0.12, 0.06, 0.08), Vector3(0.18, top + 0.03, 0.12), "paglia"))
	var a := Vector3(0.05, 0, 0.0)
	r.add_child(scatola(Vector3(0.8, 0.012, 0.75), a + Vector3(0.12, 0.006, 0.12), "terra"))
	_muretto_s(r, a + Vector3(-0.28, 0, 0.5), a + Vector3(0.28, 0, 0.5))
	_cancello_s(r, a + Vector3(0.3, 0, 0.5), a + Vector3(0.5, 0, 0.5))
	_muretto_s(r, a + Vector3(0.52, 0, -0.26), a + Vector3(0.52, 0, 0.5))
	_muretto_s(r, a + Vector3(0.15, 0, -0.26), a + Vector3(0.52, 0, -0.26))
	r.add_child(sfera(0.14, a + Vector3(0.28, 0.0, 0.05), "fuliggine", Vector3(1.4, 0.1, 1.0)))
	r.add_child(scatola(Vector3(0.24, 0.05, 0.07), a + Vector3(0.0, 0.025, 0.4), "terra_cruda"))
	r.add_child(scatola(Vector3(0.2, 0.012, 0.05), a + Vector3(0.0, 0.05, 0.4), "grano"))
	for p in [[Vector3(0.25, 0, 0.3), 20], [Vector3(0.38, 0, -0.05), 130], [Vector3(0.05, 0, 0.18), -60], [Vector3(0.4, 0, 0.32), 200]]:
		r.add_child(maiale(a + (p[0] as Vector3), p[1]))
	r.add_child(scatola(Vector3(0.16, 0.04, 0.06), a + Vector3(-0.15, 0.02, 0.1), "terra_cruda"))
	r.add_child(scatola(Vector3(0.13, 0.004, 0.04), a + Vector3(-0.15, 0.041, 0.1), "acqua_chiara"))
	_canaletta(r, Vector3(-0.62, 0, 0.1), a + Vector3(-0.23, 0, 0.1), 0.025)
	r.add_child(sacco(Vector3(-0.62, 0, 0.3), 0.3))
	r.add_child(anfora(Vector3(-0.5, 0, 0.38), 1.1))
	_palma(r, Vector3(-0.7, 0, -0.18), 0.65, 1102)
	return r


## Macelleria dei Saraceni: bottega di calce con la fascia di maiolica, tenda rossa a strisce con la carne appesa,
## bancone di terra cruda col piano di maiolica, ceppo, giara.
static func macelleria_saraceni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.25)
	r.add_child(c)
	var lx := 0.74
	var lz := 0.56
	var top := _muri_s(c, lx, lz, 0.38, 1111)
	_porta_s(c, Vector3(0.16, 0.07, lz * 0.5), 0.0, 0.13, 0.16)
	_finestra_s(c, Vector3(-0.17, 0.28, lz * 0.5), 0.0)
	_finestra_s(c, Vector3(lx * 0.5, 0.28, 0.0), 90.0)
	_camino_s(c, Vector3(0.2, top, -0.1))
	c.add_child(scatola(Vector3(0.24, 0.1, 0.24), Vector3(-0.18, top + 0.05, -0.1), "calce"))
	_cupola(c, Vector3(-0.18, top + 0.1, -0.1), 0.1, "maiolica_verde", false)
	_tenda(r, Vector3(0.45, 0, 0.42), 0.6, 0.26, 0.4, 0.34, 0.0, "tenda_rossa", true)
	r.add_child(scatola(Vector3(0.56, 0.018, 0.018), Vector3(0.45, 0.3, 0.52), "legno"))
	for k in 5:
		var x := 0.25 + k * 0.1
		r.add_child(cilindro(0.003, 0.003, 0.05, Vector3(x, 0.275, 0.52), "corda", Vector3.ZERO, 3))
		if k % 2 == 0:
			r.add_child(sfera(0.035, Vector3(x, 0.215, 0.52), "carne", Vector3(0.9, 1.4, 0.8)))
		else:
			r.add_child(cilindro(0.016, 0.016, 0.1, Vector3(x, 0.205, 0.52), "carne", Vector3.ZERO, 8))
	var b := Vector3(-0.35, 0, 0.55)
	r.add_child(scatola(Vector3(0.3, 0.1, 0.13), b + Vector3(0, 0.05, 0), "terra_cruda"))
	r.add_child(scatola(Vector3(0.32, 0.018, 0.15), b + Vector3(0, 0.109, 0), "zellige"))
	r.add_child(sfera(0.04, b + Vector3(-0.05, 0.135, 0), "carne", Vector3(1.2, 0.5, 0.9)))
	r.add_child(scatola(Vector3(0.07, 0.004, 0.02), b + Vector3(0.08, 0.122, 0.02), "ferro", Vector3(0, 30, 0)))
	r.add_child(cilindro(0.07, 0.075, 0.1, Vector3(-0.65, 0.05, 0.4), "corteccia", Vector3.ZERO, 12))
	r.add_child(anfora(Vector3(0.65, 0, 0.0), 1.4))
	r.add_child(anfora(Vector3(0.68, 0, 0.14), 1.1))
	r.add_child(maiale(Vector3(-0.6, 0, 0.0), 60))
	return r


## Apiario dei Saraceni: casetta di calce con la cupoletta bianca, arnie a tubo di canne intonacate di terra
## coricate su due muretti, aranci in fiore e fiori tutto intorno, giare di miele.
static func apiario_saraceni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.35, 0, -0.35)
	r.add_child(c)
	var lx := 0.5
	var lz := 0.4
	var top := _muri_s(c, lx, lz, 0.26, 1121, "calce", false, false)
	_porta_s(c, Vector3(0.06, 0.07, lz * 0.5), 0.0, 0.11, 0.13)
	_finestra_s(c, Vector3(lx * 0.5, 0.22, 0.0), 90.0, 0.05, 0.05)
	_cupola(c, Vector3(-0.08, top, -0.04), 0.13, "calce", false)
	for f in 2:
		var z := 0.15 + f * 0.25
		r.add_child(scatola(Vector3(0.75, 0.06, 0.1), Vector3(0.15, 0.03, z), "terra_cruda"))
		r.add_child(scatola(Vector3(0.77, 0.012, 0.11), Vector3(0.15, 0.066, z), "calce"))
		for k in 5:
			var p := Vector3(-0.15 + k * 0.15, 0.072, z)
			r.add_child(cilindro(0.04, 0.04, 0.1, p + Vector3(0, 0.04, 0), "canne" if k % 2 == 0 else "terra_cruda", Vector3(90, 0, 0), 12))
			r.add_child(cilindro(0.036, 0.036, 0.004, p + Vector3(0, 0.04, 0.051), "terra_cruda", Vector3(90, 0, 0), 12))
			r.add_child(cilindro(0.008, 0.008, 0.004, p + Vector3(0, 0.03, 0.054), "buio", Vector3(90, 0, 0), 6))
	var rng := _rng(1122)
	for k in 30:
		var p := Vector3(rng.randf_range(-0.7, 0.7), 0.0, rng.randf_range(0.55, 0.75))
		if k % 2 == 0:
			p = Vector3(rng.randf_range(0.5, 0.75), 0.0, rng.randf_range(-0.3, 0.6))
		r.add_child(sfera(0.018, p + Vector3(0, 0.02, 0), "orto"))
		r.add_child(sfera(0.012, p + Vector3(0, 0.04, 0), ["geranio", "fiore", "miele"][k % 3]))
	_arancio(r, Vector3(0.55, 0, -0.42), 0.75, 1123)
	r.add_child(anfora(Vector3(-0.62, 0, 0.2), 0.9))
	r.add_child(anfora(Vector3(-0.55, 0, 0.3), 0.8))
	return r


## Caseificio dei Saraceni: bottega di calce con la cupola, paiolo di rame sul fuoco, scaffali di formaggi
## sotto la tenda a strisce, giare di latte.
static func caseificio_saraceni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.25)
	r.add_child(c)
	var lx := 0.74
	var lz := 0.56
	var top := _muri_s(c, lx, lz, 0.38, 1131)
	_porta_s(c, Vector3(-0.15, 0.07, lz * 0.5), 0.0, 0.13, 0.16)
	_finestra_s(c, Vector3(0.18, 0.28, lz * 0.5), 0.0)
	_finestra_s(c, Vector3(lx * 0.5, 0.28, 0.0), 90.0)
	_camino_s(c, Vector3(-0.2, top, -0.1))
	c.add_child(scatola(Vector3(0.26, 0.1, 0.26), Vector3(0.14, top + 0.05, -0.08), "calce"))
	_cupola(c, Vector3(0.14, top + 0.1, -0.08), 0.11, "maiolica_verde", false)
	var f := Vector3(0.45, 0, 0.45)
	for k in 6:
		r.add_child(scatola(Vector3(0.07, 0.05, 0.05), f + Vector3(0.12 * cos(k), 0.025, 0.12 * sin(k)), "terra_cruda", Vector3(0, k * 50, 0)))
	r.add_child(sfera(0.1, f + Vector3(0, 0.12, 0), "bronzo", Vector3(1, 0.8, 1)))
	r.add_child(cilindro(0.085, 0.085, 0.01, f + Vector3(0, 0.17, 0), "latte", Vector3.ZERO, 14))
	for lato: int in [-1, 1]:
		r.add_child(cilindro(0.01, 0.01, 0.3, f + Vector3(lato * 0.15, 0.15, 0), "legno_vecchio", Vector3.ZERO, 5))
	r.add_child(cilindro(0.008, 0.008, 0.32, f + Vector3(0, 0.3, 0), "legno_vecchio", Vector3(0, 0, 90), 5))
	_fumo(r, f + Vector3(0, 0.24, 0), 2, 0.6)
	for p: Vector3 in [Vector3(-0.3, 0, 0.5), Vector3(0.7, 0, -0.05)]:
		for liv in 3:
			r.add_child(scatola(Vector3(0.28 if p.x < 0 else 0.08, 0.012, 0.08 if p.x < 0 else 0.28), p + Vector3(0, 0.05 + liv * 0.08, 0), "legno_verde"))
			for k in 3:
				var o := Vector3((k - 1) * 0.085, 0, 0) if p.x < 0 else Vector3(0, 0, (k - 1) * 0.085)
				r.add_child(cilindro(0.035, 0.035, 0.04, p + o + Vector3(0, 0.078 + liv * 0.08, 0), "formaggio", Vector3.ZERO, 12))
	_tenda(r, Vector3(-0.3, 0, 0.47), 0.38, 0.2, 0.36, 0.31, 0.0, "tenda_verde", true)
	r.add_child(anfora(Vector3(0.1, 0, 0.62), 1.0))
	r.add_child(anfora(Vector3(0.2, 0, 0.6), 1.1))
	return r


## Argillaio dei Saraceni: casotto di mattoni crudi con la pergola di canne, fossa d'argilla, mattoni crudi
## che seccano, stampo di legno, pala, giara d'acqua.
static func argillaio_saraceni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.32, 0, -0.32)
	r.add_child(c)
	var top := _muri_s(c, 0.46, 0.36, 0.24, 1141, "mattoni_crudi", false, false)
	_porta_s(c, Vector3(0.06, 0.07, 0.18), 0.0, 0.11, 0.12, true)
	for k in 3:
		c.add_child(scatola(Vector3(0.07, 0.03, 0.04), Vector3(-0.12 + k * 0.09, top + 0.015, -0.06), "argilla"))
	_pergola_s(r, Vector3(-0.32, 0, 0.42), 0.42, 0.22, 0.26)
	r.add_child(sfera(0.3, Vector3(0.3, -0.02, 0.25), "argilla", Vector3(1.3, 0.12, 1.0)))
	r.add_child(sfera(0.22, Vector3(0.3, 0.0, 0.25), "argilla_cruda", Vector3(1.3, 0.08, 1.0)))
	for k in 12:
		r.add_child(scatola(Vector3(0.07, 0.03, 0.04), Vector3(-0.55 + (k % 4) * 0.09, 0.015 + (k / 4) * 0.032, 0.45), "argilla" if k % 3 else "terra_cruda", Vector3(0, (k % 2) * 5, 0)))
	r.add_child(scatola(Vector3(0.1, 0.02, 0.06), Vector3(-0.12, 0.01, 0.6), "legno"))
	r.add_child(scatola(Vector3(0.07, 0.006, 0.04), Vector3(-0.12, 0.023, 0.6), "buio"))
	var a := attrezzo("pala")
	a.position = Vector3(0.62, 0.02, 0.05)
	a.rotation_degrees = Vector3(0, 40, 10)
	r.add_child(a)
	r.add_child(anfora(Vector3(0.02, 0, 0.62), 1.3))
	return r


## Fornace dei Saraceni: bottega di calce, fornace a cupola di terra cruda imbiancata con la bocca accesa,
## vasi e ciotole smaltate di verde e bianco in fila, argilla e legna.
static func fornace_saraceni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.25, 0, -0.3)
	r.add_child(c)
	var lx := 0.6
	var lz := 0.46
	var top := _muri_s(c, lx, lz, 0.3, 1151)
	_porta_s(c, Vector3(0.12, 0.07, lz * 0.5), 0.0, 0.12, 0.14)
	_finestra_s(c, Vector3(-0.14, 0.23, lz * 0.5), 0.0, 0.055, 0.055)
	_finestra_s(c, Vector3(lx * 0.5, 0.23, 0.0), 90.0, 0.055, 0.055)
	for k in 4:
		c.add_child(sfera(0.03, Vector3(-0.18 + k * 0.08, top + 0.02, -0.08), "maiolica_verde" if k % 2 == 0 else "calce", Vector3(1, 0.7, 1)))
	var f := Vector3(0.42, 0, 0.35)
	r.add_child(cilindro(0.2, 0.22, 0.14, f + Vector3(0, 0.07, 0), "terra_cruda", Vector3.ZERO, 18))
	r.add_child(sfera(0.2, f + Vector3(0, 0.14, 0), "terra_cruda", Vector3(1, 1.0, 1)))
	r.add_child(cilindro(0.205, 0.205, 0.02, f + Vector3(0, 0.15, 0), "calce", Vector3.ZERO, 18))
	r.add_child(cilindro(0.04, 0.05, 0.06, f + Vector3(0, 0.35, 0), "terra_cruda", Vector3.ZERO, 10))
	r.add_child(scatola(Vector3(0.08, 0.07, 0.05), f + Vector3(-0.05, 0.1, 0.19), "brace", Vector3(0, 25, 0)))
	_fumo(r, f + Vector3(0, 0.4, 0), 3, 1.0)
	for k in 7:
		var p := Vector3(-0.6 + (k % 4) * 0.1, 0, 0.42 + (k / 4) * 0.12)
		if k % 3 == 1:
			r.add_child(cilindro(0.03, 0.045, 0.04, p + Vector3(0, 0.02, 0), "maiolica_verde", Vector3.ZERO, 12))
			r.add_child(cilindro(0.036, 0.036, 0.004, p + Vector3(0, 0.041, 0), "calce", Vector3.ZERO, 12))
		else:
			r.add_child(anfora(p, 1.2))
			r.add_child(cilindro(0.047, 0.047, 0.015, p + Vector3(0, 0.075 * 1.2, 0), "maiolica_verde" if k % 2 == 0 else "calce", Vector3.ZERO, 10))
	r.add_child(mucchio(Vector3(0.68, 0, -0.15), "argilla", 8, 9))
	legnaia(r, Vector3(0.65, 0, 0.12), 0.2, 3)
	return r


## Saline dei Saraceni: vasche di evaporazione bordate di terra cruda e riempite dalla canaletta, cumuli di sale,
## casotto bianco con la cupoletta, pala, sacco e palma.
static func saline_saraceni() -> Node3D:
	var r := Node3D.new()
	for i in 3:
		for j in 2:
			var p := Vector3(-0.45 + i * 0.42, 0, -0.25 + j * 0.5)
			r.add_child(scatola(Vector3(0.4, 0.04, 0.46), p + Vector3(0, 0.02, 0), "terra_cruda"))
			var mat := "acqua_chiara" if (i + j) % 3 != 0 else "sale"
			r.add_child(scatola(Vector3(0.34, 0.005, 0.4), p + Vector3(0, 0.042, 0), mat))
			r.add_child(scatola(Vector3(0.05, 0.008, 0.04), p + Vector3(0, 0.04, -0.21), "acqua_chiara"))
	_canaletta(r, Vector3(-0.68, 0, -0.53), Vector3(0.42, 0, -0.53), 0.03)
	for p: Vector3 in [Vector3(0.62, 0, 0.55), Vector3(0.42, 0, 0.62), Vector3(-0.6, 0, 0.6)]:
		r.add_child(sfera(0.1, p, "sale", Vector3(1, 0.9, 1)))
	var c := Node3D.new()
	c.position = Vector3(0.6, 0, -0.55)
	r.add_child(c)
	var top := _muri_s(c, 0.28, 0.24, 0.13, 1161, "calce", false, false)
	_porta_s(c, Vector3(-0.04, 0.07, 0.12), 0.0, 0.08, 0.06)
	_cupola(c, Vector3(0, top, 0), 0.1, "calce", false)
	var a := attrezzo("pala")
	a.position = Vector3(0.25, 0.02, 0.45)
	a.rotation_degrees = Vector3(0, -30, 5)
	r.add_child(a)
	r.add_child(sacco(Vector3(0.0, 0, 0.62), 0.3))
	_palma(r, Vector3(0.3, 0, -0.74), 0.6, 1162)
	return r


## Tessitura dei Saraceni: bottega di calce con la cupola, telaio con la tela a strisce verdi, rosse e d'oro,
## matasse di lana colorata, tappeti stesi su una pertica.
static func tessitura_saraceni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.28)
	r.add_child(c)
	var lx := 0.72
	var lz := 0.52
	var top := _muri_s(c, lx, lz, 0.36, 1171)
	_porta_s(c, Vector3(-0.16, 0.07, lz * 0.5), 0.0, 0.13, 0.15)
	_finestra_s(c, Vector3(0.18, 0.27, lz * 0.5), 0.0)
	_finestra_s(c, Vector3(lx * 0.5, 0.27, 0.0), 90.0)
	c.add_child(scatola(Vector3(0.26, 0.1, 0.26), Vector3(-0.16, top + 0.05, -0.08), "calce"))
	_cupola(c, Vector3(-0.16, top + 0.1, -0.08), 0.11, "maiolica_verde", false)
	_tappeto(c, Vector3(0.2, top + 0.05, lz * 0.5 + 0.03), 0.0, 0.13, 0.15)
	var t := Vector3(0.0, 0, 0.5)
	for x: float in [-0.18, 0.18]:
		r.add_child(cilindro(0.012, 0.012, 0.4, t + Vector3(x, 0.2, 0), "legno_verde", Vector3.ZERO, 6))
	r.add_child(cilindro(0.012, 0.012, 0.4, t + Vector3(0, 0.39, 0), "legno_verde", Vector3(0, 0, 90), 6))
	var fili := ["stoffa_smeraldo", "seta_oro", "stoffa_rossa", "lino_bianco", "stoffa_smeraldo", "stoffa_rossa"]
	for k in 6:
		r.add_child(scatola(Vector3(0.34, 0.04, 0.006), t + Vector3(0, 0.34 - k * 0.04, 0), fili[k]))
	for k in 5:
		r.add_child(sfera(0.014, t + Vector3(-0.14 + k * 0.07, 0.08, 0), "argilla"))
	var colori := ["lana", "seta_zafferano", "stoffa_smeraldo"]
	for i in 3:
		var p := Vector3(0.55 + (i % 2) * 0.06, 0, 0.0 + i * 0.1)
		r.add_child(sfera(0.045, p + Vector3(0, 0.035, 0), colori[i], Vector3(1.2, 0.8, 1)))
	for x: float in [0.36, 0.86]:
		r.add_child(cilindro(0.009, 0.009, 0.36, Vector3(x, 0.18, -0.35), "legno_vecchio", Vector3.ZERO, 5))
	r.add_child(cilindro(0.008, 0.008, 0.54, Vector3(0.61, 0.36, -0.35), "legno_vecchio", Vector3(0, 0, 90), 5))
	_tappeto(r, Vector3(0.49, 0.36, -0.345), 0.0, 0.2, 0.24)
	_tappeto(r, Vector3(0.73, 0.36, -0.345), 0.0, 0.2, 0.22)
	return r


## Pescatore dei Saraceni: casetta di calce bassa con la terrazza, reti stese su pali, barca dipinta di verde
## tirata a secco, ceste di pesce, giara e palma.
static func capanna_pescatore_saraceni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.22, 0, -0.25)
	r.add_child(c)
	var lx := 0.66
	var lz := 0.5
	var top := _muri_s(c, lx, lz, 0.3, 1181, "calce", false, true)
	_porta_s(c, Vector3(0.12, 0.07, lz * 0.5), 0.0, 0.12, 0.14)
	_finestra_s(c, Vector3(-0.16, 0.24, lz * 0.5), 0.0)
	_finestra_s(c, Vector3(lx * 0.5, 0.24, 0.0), 90.0)
	_tenda(c, Vector3(-0.12, top, 0.0), 0.32, 0.26, 0.18, 0.14, 0.0, "tenda_verde", true)
	c.add_child(scatola(Vector3(0.18, 0.04, 0.12), Vector3(0.2, top + 0.02, -0.08), "rete"))
	for x: float in [0.35, 0.75]:
		r.add_child(cilindro(0.012, 0.012, 0.36, Vector3(x, 0.18, -0.35), "legno_vecchio", Vector3.ZERO, 6))
	r.add_child(scatola(Vector3(0.4, 0.26, 0.006), Vector3(0.55, 0.2, -0.35), "rete"))
	for k in 6:
		r.add_child(scatola(Vector3(0.004, 0.26, 0.008), Vector3(0.37 + k * 0.07, 0.2, -0.345), "corda"))
	for k in 4:
		r.add_child(scatola(Vector3(0.4, 0.004, 0.008), Vector3(0.55, 0.1 + k * 0.065, -0.345), "corda"))
	var b := Node3D.new()
	b.position = Vector3(0.35, 0, 0.45)
	b.rotation_degrees.y = -25
	r.add_child(b)
	b.add_child(sfera(0.13, Vector3(0, 0.07, 0), "legno_verde", Vector3(2.6, 0.7, 1.0)))
	b.add_child(sfera(0.115, Vector3(0, 0.1, 0), "legno_scuro", Vector3(2.5, 0.35, 0.9)))
	b.add_child(scatola(Vector3(0.66, 0.02, 0.03), Vector3(0, 0.13, 0.12), "calce"))
	b.add_child(scatola(Vector3(0.66, 0.02, 0.03), Vector3(0, 0.13, -0.12), "calce"))
	for s: int in [-1, 1]:
		b.add_child(sfera(0.012, Vector3(0.3, 0.11, s * 0.1), "seta_oro"))
	for z: float in [-0.05, 0.06]:
		b.add_child(scatola(Vector3(0.5, 0.01, 0.025), Vector3(0.05, 0.16, z), "legno_chiaro", Vector3(0, 8, 4)))
	r.add_child(cesta(Vector3(-0.45, 0, 0.45), "pesce"))
	r.add_child(cesta(Vector3(-0.3, 0, 0.58), "pesce"))
	r.add_child(anfora(Vector3(-0.62, 0, 0.25), 1.2))
	for i in 3:
		r.add_child(sfera(0.02, Vector3(0.62 + i * 0.05, 0.02, 0.1 + i * 0.03), "stoffa_smeraldo"))
	_palma(r, Vector3(-0.66, 0, 0.0), 0.7, 1182)
	return r


## Frantoio dei Saraceni: grande bottega di calce con la cupola, macina di pietra all'aperto con la vasca bordata
## di terra cruda, giare d'olio, fiscoli, ulivo.
static func frantoio_saraceni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.22)
	r.add_child(c)
	var lx := 0.82
	var lz := 0.62
	var top := _muri_s(c, lx, lz, 0.4, 1191)
	_porta_s(c, Vector3(0.18, 0.07, lz * 0.5), 0.0, 0.15, 0.17)
	_finestra_s(c, Vector3(-0.18, 0.3, lz * 0.5), 0.0)
	_finestra_s(c, Vector3(lx * 0.5, 0.3, 0.12), 90.0)
	_finestra_s(c, Vector3(lx * 0.5, 0.3, -0.14), 90.0)
	_camino_s(c, Vector3(-0.24, top, -0.14))
	c.add_child(scatola(Vector3(0.32, 0.12, 0.32), Vector3(0.12, top + 0.06, -0.06), "calce"))
	c.add_child(scatola(Vector3(0.34, 0.02, 0.34), Vector3(0.12, top + 0.12, -0.06), "terra_cruda"))
	_cupola(c, Vector3(0.12, top + 0.13, -0.06), 0.13)
	var m := Vector3(-0.35, 0, 0.55)
	r.add_child(cilindro(0.26, 0.28, 0.1, m + Vector3(0, 0.05, 0), "terra_cruda", Vector3.ZERO, 24))
	r.add_child(cilindro(0.27, 0.27, 0.012, m + Vector3(0, 0.104, 0), "calce", Vector3.ZERO, 24))
	r.add_child(cilindro(0.21, 0.21, 0.01, m + Vector3(0, 0.106, 0), "foglie_ulivo", Vector3.ZERO, 24))
	r.add_child(cilindro(0.03, 0.03, 0.22, m + Vector3(0, 0.2, 0), "legno", Vector3.ZERO, 8))
	r.add_child(cilindro(0.12, 0.12, 0.08, m + Vector3(0.1, 0.22, 0), "blocco", Vector3(0, 0, 90), 18))
	r.add_child(scatola(Vector3(0.6, 0.03, 0.03), m + Vector3(0.2, 0.26, 0), "legno_verde"))
	for i in 6:
		r.add_child(anfora(Vector3(0.25 + (i % 3) * 0.1, 0.0, 0.42 + (i / 3) * 0.11), 1.15))
	for i in 3:
		r.add_child(cilindro(0.06, 0.05, 0.06, Vector3(0.62, 0.03, -0.3 + i * 0.16), "canne", Vector3.ZERO, 12))
		r.add_child(sfera(0.05, Vector3(0.62, 0.06, -0.3 + i * 0.16), "foglie_ulivo", Vector3(1, 0.4, 1)))
	r.add_child(anfora(Vector3(0.62, 0.0, 0.25), 1.6))
	var u := ulivo(1192)
	u.position = Vector3(-0.7, 0, -0.45)
	u.scale = Vector3.ONE * 0.8
	r.add_child(u)
	return r


## Uliveto dei Saraceni: casetta di calce con la cupoletta, teli stesi sotto l'ulivo bagnato dalla canaletta,
## ceste di olive, scala a pioli.
static func uliveto_saraceni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.3, 0, -0.3)
	r.add_child(c)
	var lx := 0.58
	var lz := 0.46
	var top := _muri_s(c, lx, lz, 0.28, 1201, "calce", true, false)
	_porta_s(c, Vector3(-0.08, 0.07, lz * 0.5), 0.0, 0.12, 0.14)
	_finestra_s(c, Vector3(lx * 0.5, 0.23, 0.0), 90.0, 0.055, 0.055)
	_cupola(c, Vector3(0.08, top, -0.05), 0.12, "calce", false)
	var u := ulivo(1202)
	u.position = Vector3(0.35, 0, 0.3)
	u.scale = Vector3.ONE * 0.8
	r.add_child(u)
	r.add_child(scatola(Vector3(0.5, 0.004, 0.45), Vector3(0.35, 0.004, 0.3), "lino", Vector3(0, 12, 0)))
	for k in 12:
		r.add_child(sfera(0.012, Vector3(0.2 + (k % 4) * 0.08, 0.012, 0.18 + (k / 4) * 0.1), "oliva"))
	_canaletta(r, Vector3(0.62, 0, 0.12), Vector3(0.48, 0, 0.26), 0.025)
	_vasca(r, Vector3(0.66, 0, 0.06), 0.06)
	for p: Vector3 in [Vector3(-0.45, 0, 0.45), Vector3(-0.25, 0, 0.55), Vector3(0.58, 0, -0.2)]:
		r.add_child(cesta(p, "olive"))
	r.add_child(scatola(Vector3(0.03, 0.45, 0.012), Vector3(0.12, 0.22, 0.12), "legno_vecchio", Vector3(0, 0, -18)))
	r.add_child(scatola(Vector3(0.03, 0.45, 0.012), Vector3(0.12, 0.22, 0.2), "legno_vecchio", Vector3(0, 0, -18)))
	return r


## Vigneto dei Saraceni: casetta di calce, pergolato d'uva su pilastrini intonacati, vasca di terra cruda
## bordata di maiolica per pigiare, ceste di grappoli.
static func vigneto_saraceni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.25, 0, -0.3)
	r.add_child(c)
	var lx := 0.66
	var lz := 0.5
	var top := _muri_s(c, lx, lz, 0.32, 1211)
	_porta_s(c, Vector3(0.1, 0.07, lz * 0.5), 0.0, 0.13, 0.15)
	_finestra_s(c, Vector3(-0.18, 0.25, lz * 0.5), 0.0)
	_finestra_s(c, Vector3(lx * 0.5, 0.25, 0.0), 90.0)
	_tenda(c, Vector3(0.12, top, -0.02), 0.34, 0.26, 0.18, 0.14, 0.0, "tenda_rossa", true)
	for p: Vector3 in [Vector3(-0.35, 0, 0.15), Vector3(0.25, 0, 0.15), Vector3(-0.35, 0, 0.55), Vector3(0.25, 0, 0.55)]:
		r.add_child(scatola(Vector3(0.035, 0.36, 0.035), p + Vector3(0, 0.18, 0), "calce"))
		r.add_child(scatola(Vector3(0.05, 0.03, 0.05), p + Vector3(0, 0.015, 0), "terra_cruda"))
	for z: float in [0.15, 0.55]:
		r.add_child(scatola(Vector3(0.66, 0.018, 0.018), Vector3(-0.05, 0.355, z), "legno"))
	var rng := _rng(1212)
	for k in 26:
		r.add_child(sfera(0.045, Vector3(rng.randf_range(-0.38, 0.28), 0.37, rng.randf_range(0.12, 0.58)), "foglie" if k % 3 else "foglie_chiare", Vector3(1, 0.5, 1)))
	for k in 6:
		r.add_child(sfera(0.022, Vector3(-0.3 + k * 0.1, 0.32, 0.35 + (k % 2) * 0.1), "uva", Vector3(1, 1.5, 1)))
	var v := Vector3(0.55, 0, 0.4)
	r.add_child(cilindro(0.11, 0.11, 0.1, v + Vector3(0, 0.05, 0), "terra_cruda", Vector3.ZERO, 8))
	r.add_child(cilindro(0.115, 0.115, 0.016, v + Vector3(0, 0.1, 0), "zellige", Vector3.ZERO, 8))
	r.add_child(cilindro(0.095, 0.095, 0.005, v + Vector3(0, 0.106, 0), "uva", Vector3.ZERO, 8))
	r.add_child(cesta(Vector3(0.6, 0, 0.0), "uva"))
	r.add_child(cesta(Vector3(0.45, 0, -0.2), "uva"))
	return r


## Cantina dei Saraceni: bottega di calce con la cupola verde, grandi giare interrate per il vino, anfore in fila,
## palmento di terra cruda con la maiolica, cesta d'uva.
static func cantina_saraceni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.25)
	r.add_child(c)
	var lx := 0.76
	var lz := 0.56
	var top := _muri_s(c, lx, lz, 0.36, 1221, "mattoni_crudi", true, true)
	_porta_s(c, Vector3(0.15, 0.07, lz * 0.5), 0.0, 0.16, 0.16)
	_finestra_s(c, Vector3(-0.2, 0.27, lz * 0.5), 0.0)
	_finestra_s(c, Vector3(lx * 0.5, 0.27, 0.0), 90.0)
	c.add_child(scatola(Vector3(0.28, 0.1, 0.28), Vector3(-0.14, top + 0.05, -0.08), "calce"))
	_cupola(c, Vector3(-0.14, top + 0.1, -0.08), 0.12, "maiolica_verde", false)
	for k in 3:
		var p := Vector3(0.62, 0, -0.3 + k * 0.2)
		r.add_child(cilindro(0.09, 0.09, 0.05, p + Vector3(0, 0.025, 0), "terra_cruda", Vector3.ZERO, 14))
		var g := anfora(p + Vector3(0, -0.02, 0), 1.9)
		r.add_child(g)
		r.add_child(cilindro(0.045, 0.045, 0.012, p + Vector3(0, 0.15, 0), "calce", Vector3.ZERO, 10))
	for k in 5:
		r.add_child(anfora(Vector3(-0.6 + (k % 3) * 0.1, 0, 0.42 + (k / 3) * 0.12), 1.15))
	r.add_child(scatola(Vector3(0.36, 0.1, 0.28), Vector3(0.2, 0.05, 0.55), "terra_cruda"))
	r.add_child(scatola(Vector3(0.38, 0.016, 0.3), Vector3(0.2, 0.1, 0.55), "zellige"))
	r.add_child(scatola(Vector3(0.3, 0.01, 0.22), Vector3(0.2, 0.105, 0.55), "vino"))
	r.add_child(cesta(Vector3(-0.15, 0, 0.6), "uva"))
	return r


## Ortolano dei Saraceni: casetta di calce, orto a quadri attraversato dalla canaletta, trecce di cipolle
## appese a una pertica, ceste di verdura.
static func ortolano_saraceni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.3, 0, -0.3)
	r.add_child(c)
	var lx := 0.58
	var lz := 0.46
	var top := _muri_s(c, lx, lz, 0.28, 1231, "calce", true, false)
	_porta_s(c, Vector3(0.08, 0.07, lz * 0.5), 0.0, 0.12, 0.14)
	_finestra_s(c, Vector3(-0.16, 0.23, lz * 0.5), 0.0, 0.055, 0.055)
	_tenda(c, Vector3(0.0, top, -0.02), 0.3, 0.24, 0.17, 0.13, 0.0, "tenda_verde", true)
	orto(r, Vector3(0.45, 0, 0.0), 0.36, 0.6, 1232)
	_canaletta(r, Vector3(0.45, 0, -0.32), Vector3(0.45, 0, 0.32), 0.025)
	for x: float in [-0.56, -0.2]:
		r.add_child(cilindro(0.01, 0.01, 0.34, Vector3(x, 0.17, 0.0), "legno_vecchio", Vector3.ZERO, 5))
	r.add_child(cilindro(0.008, 0.008, 0.38, Vector3(-0.38, 0.33, 0.0), "legno_vecchio", Vector3(0, 0, 90), 5))
	for k in 4:
		for i in 4:
			r.add_child(sfera(0.02, Vector3(-0.5 + k * 0.08, 0.3 - i * 0.04, 0.0), "cipolla"))
	for p: Vector3 in [Vector3(-0.4, 0, 0.45), Vector3(-0.2, 0, 0.55)]:
		r.add_child(cesta(p, "ortaggi"))
	r.add_child(cesta(Vector3(0.05, 0, 0.6), "cipolle"))
	return r


## Agrumeto dei Saraceni: casetta di calce con la cupoletta verde, grande albero di agrumi in un'aiuola tonda
## bagnata dalla canaletta che scende da una vasca, ceste di arance e limoni.
static func agrumeto_saraceni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.3, 0, -0.3)
	r.add_child(c)
	var lx := 0.6
	var lz := 0.46
	var top := _muri_s(c, lx, lz, 0.3, 1241)
	_porta_s(c, Vector3(-0.1, 0.07, lz * 0.5), 0.0, 0.12, 0.14)
	_finestra_s(c, Vector3(0.15, 0.24, lz * 0.5), 0.0, 0.06, 0.06)
	c.add_child(scatola(Vector3(0.22, 0.09, 0.22), Vector3(0.1, top + 0.045, -0.06), "calce"))
	_cupola(c, Vector3(0.1, top + 0.09, -0.06), 0.09, "maiolica_verde", false)
	var a := agrumi(3)
	var terra := a.get_child(0)
	a.remove_child(terra)
	terra.free()
	a.position = Vector3(0.3, 0, 0.25)
	a.scale = Vector3.ONE * 1.1
	r.add_child(a)
	r.add_child(cilindro(0.2, 0.2, 0.03, Vector3(0.3, 0.015, 0.25), "terra_cruda", Vector3.ZERO, 16))
	r.add_child(cilindro(0.18, 0.18, 0.004, Vector3(0.3, 0.031, 0.25), "terra", Vector3.ZERO, 16))
	_vasca(r, Vector3(-0.02, 0, 0.6), 0.07)
	_canaletta(r, Vector3(0.05, 0, 0.6), Vector3(0.22, 0, 0.42), 0.025)
	for p: Vector3 in [Vector3(-0.45, 0, 0.45), Vector3(-0.28, 0, 0.6), Vector3(0.7, 0, -0.25)]:
		r.add_child(cesta(p, "agrumi"))
	r.add_child(cassa(Vector3(0.65, 0, 0.1), 20))
	return r


## Pesca del pesce spada dei Saraceni: casetta di calce, feluca dipinta di verde con l'albero di vedetta
## e il pennoncello, passerella dell'arpioniere, arpione e pesce spada.
static func pesca_spada_saraceni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.3, 0, -0.3)
	r.add_child(c)
	var lx := 0.6
	var lz := 0.46
	var top := _muri_s(c, lx, lz, 0.3, 1251, "calce", true, true)
	_porta_s(c, Vector3(0.1, 0.07, lz * 0.5), 0.0, 0.12, 0.14)
	_finestra_s(c, Vector3(lx * 0.5, 0.24, 0.0), 90.0)
	_finestra_s(c, Vector3(-0.15, 0.24, lz * 0.5), 0.0, 0.055, 0.055)
	c.add_child(scatola(Vector3(0.2, 0.04, 0.12), Vector3(-0.1, top + 0.02, -0.06), "rete"))
	var b := Node3D.new()
	b.position = Vector3(0.3, 0, 0.35)
	b.rotation_degrees.y = -30
	r.add_child(b)
	b.add_child(sfera(0.15, Vector3(0, 0.07, 0), "legno_verde", Vector3(2.8, 0.7, 1.0)))
	b.add_child(sfera(0.13, Vector3(0, 0.1, 0), "legno_scuro", Vector3(2.7, 0.35, 0.9)))
	b.add_child(scatola(Vector3(0.8, 0.02, 0.03), Vector3(0, 0.14, 0.13), "calce"))
	b.add_child(scatola(Vector3(0.8, 0.02, 0.03), Vector3(0, 0.14, -0.13), "calce"))
	for s: int in [-1, 1]:
		b.add_child(sfera(0.013, Vector3(0.36, 0.12, s * 0.11), "seta_oro"))
	b.add_child(cilindro(0.01, 0.008, 0.6, Vector3(0.0, 0.42, 0), "legno_vecchio", Vector3.ZERO, 6))
	for k in 5:
		b.add_child(scatola(Vector3(0.08, 0.006, 0.01), Vector3(0.0, 0.2 + k * 0.08, 0.0), "legno_vecchio"))
	b.add_child(scatola(Vector3(0.006, 0.04, 0.07), Vector3(0.0, 0.69, 0.035), "stoffa_smeraldo"))
	b.add_child(sfera(0.012, Vector3(0.0, 0.73, 0), "moneta"))
	b.add_child(scatola(Vector3(0.45, 0.012, 0.02), Vector3(0.55, 0.13, 0), "legno_chiaro"))
	r.add_child(scatola(Vector3(0.02, 0.012, 0.5), Vector3(-0.6, 0.15, 0.4), "ferro", Vector3(0, 0, 4)))
	var sp := pesce_spada_modello()
	sp.position = Vector3(-0.35, 0.02, 0.55)
	r.add_child(sp)
	return r


## Miniera dei Saraceni: fianco della montagna con l'imbocco ad arco a ferro di cavallo in una facciata di terra cruda,
## binari, carrello, mucchio di minerale, lanterna di rame traforata, puntelli e insegna verde.
static func miniera_ferro_saraceni(minerale := "minerale") -> Node3D:
	var r := Node3D.new()
	r.add_child(sfera(0.6, Vector3(-0.25, 0.0, -0.3), "roccia_massi", Vector3(1.2, 0.75, 1.0)))
	r.add_child(sfera(0.35, Vector3(0.35, 0.0, -0.45), "roccia_massi", Vector3(1.1, 0.8, 1.0)))
	r.add_child(sfera(0.3, Vector3(-0.65, 0.0, 0.15), "roccia_massi", Vector3(1.0, 0.7, 1.0)))
	var imb := Vector3(-0.05, 0, 0.18)
	r.add_child(scatola(Vector3(0.4, 0.4, 0.14), imb + Vector3(0, 0.2, -0.02), "terra_cruda"))
	r.add_child(scatola(Vector3(0.42, 0.02, 0.16), imb + Vector3(0, 0.41, -0.02), "calce"))
	_fila_merli(r, imb + Vector3(-0.19, 0.42, 0.03), imb + Vector3(0.19, 0.42, 0.03), "calce", 0.8)
	_porta_s(r, imb + Vector3(0, 0, 0.05), 0.0, 0.18, 0.15, true)
	for k in 6:
		r.add_child(scatola(Vector3(0.14, 0.008, 0.02), imb + Vector3(0, 0.004, 0.12 + k * 0.08), "legno_scuro"))
	for lato: int in [-1, 1]:
		r.add_child(scatola(Vector3(0.012, 0.01, 0.5), imb + Vector3(lato * 0.05, 0.012, 0.33), "ferro"))
	var carr := Vector3(-0.05, 0, 0.5)
	r.add_child(scatola(Vector3(0.14, 0.08, 0.18), carr + Vector3(0, 0.07, 0), "legno_verde"))
	r.add_child(mucchio(carr + Vector3(0, 0.1, 0), minerale, 6, 3, 0.03))
	for x: float in [-0.075, 0.075]:
		for z: float in [-0.06, 0.06]:
			r.add_child(cilindro(0.022, 0.022, 0.012, carr + Vector3(x, 0.025, z), "ferro", Vector3(0, 0, 90), 8))
	r.add_child(mucchio(Vector3(0.45, 0, 0.35), minerale, 14, 4))
	r.add_child(cilindro(0.01, 0.01, 0.3, Vector3(0.22, 0.15, 0.3), "legno_vecchio", Vector3.ZERO, 5))
	r.add_child(cilindro(0.018, 0.022, 0.04, Vector3(0.22, 0.28, 0.3), "bronzo", Vector3.ZERO, 8))
	r.add_child(sfera(0.016, Vector3(0.22, 0.28, 0.3), "miele"))
	r.add_child(cilindro(0.0, 0.024, 0.03, Vector3(0.22, 0.315, 0.3), "bronzo", Vector3.ZERO, 8))
	for k in 4:
		r.add_child(cilindro(0.018, 0.018, 0.4, Vector3(-0.55 + k * 0.045, 0.02 + (k % 2) * 0.03, 0.55), "legno_vecchio", Vector3(0, 70, 90), 6))
	r.add_child(anfora(Vector3(0.3, 0, 0.55), 1.1))
	_stendardo_s(r, Vector3(0.62, 0, 0.08), 0.42)
	return r


## Carbonaia dei Saraceni: casotto di mattoni crudi con le fascine sulla terrazza, cupola di legna coperta
## di terra che fuma, legna, carbone pronto, sacchi sotto la tenda.
static func carbonaia_saraceni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.38, 0, -0.35)
	r.add_child(c)
	var top := _muri_s(c, 0.4, 0.32, 0.2, 1261, "mattoni_crudi", false, false)
	_porta_s(c, Vector3(0.05, 0.07, 0.16), 0.0, 0.1, 0.1, true)
	for k in 3:
		c.add_child(cilindro(0.025, 0.025, 0.24, Vector3(-0.1 + k * 0.07, top + 0.025, -0.02), "paglia_scura", Vector3(90, 0, 0), 8))
	var m := Vector3(0.22, 0, 0.2)
	r.add_child(sfera(0.36, m, "terra", Vector3(1, 0.7, 1)))
	r.add_child(sfera(0.3, m + Vector3(0, 0.03, 0), "fuliggine", Vector3(1, 0.7, 1)))
	r.add_child(sfera(0.37, m + Vector3(0, -0.01, 0), "terra", Vector3(1, 0.68, 1)))
	for k in 5:
		r.add_child(sfera(0.05 + k * 0.012, m + Vector3(0.02 * k, 0.28 + k * 0.07, -0.01 * k), "fumo", Vector3(1, 0.8, 1)))
	r.add_child(scatola(Vector3(0.06, 0.04, 0.04), m + Vector3(0.0, 0.12, 0.33), "buio"))
	legnaia(r, Vector3(-0.55, 0, 0.35), 0.35, 4)
	r.add_child(mucchio(Vector3(0.62, 0, -0.25), "carbone", 12, 5))
	r.add_child(sacco(Vector3(0.6, 0, 0.55), 0.4))
	r.add_child(anfora(Vector3(-0.1, 0, 0.0), 1.1))
	return r


## Fonderia dei Saraceni: bottega di calce con la cupoletta, forno a torre di terra cruda cerchiato di calce
## con la bocca accesa, mantice di pelle, lingotti, carbone e minerale.
static func fonderia_saraceni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.25, 0, -0.25)
	r.add_child(c)
	var lx := 0.66
	var lz := 0.52
	var top := _muri_s(c, lx, lz, 0.34, 1271, "mattoni_crudi", true, true)
	_porta_s(c, Vector3(-0.12, 0.07, lz * 0.5), 0.0, 0.14, 0.16, true)
	_finestra_s(c, Vector3(0.16, 0.26, lz * 0.5), 0.0)
	_finestra_s(c, Vector3(lx * 0.5, 0.26, 0.0), 90.0)
	c.add_child(scatola(Vector3(0.24, 0.1, 0.24), Vector3(-0.12, top + 0.05, -0.08), "calce"))
	_cupola(c, Vector3(-0.12, top + 0.1, -0.08), 0.1, "maiolica_verde", false)
	var f := Vector3(0.42, 0, 0.38)
	r.add_child(cilindro(0.17, 0.2, 0.5, f + Vector3(0, 0.25, 0), "terra_cruda", Vector3.ZERO, 16))
	for k in 2:
		r.add_child(cilindro(0.19 - k * 0.02, 0.19 - k * 0.02, 0.025, f + Vector3(0, 0.14 + k * 0.2, 0), "calce", Vector3.ZERO, 16))
	r.add_child(cilindro(0.13, 0.15, 0.08, f + Vector3(0, 0.54, 0), "fuliggine", Vector3.ZERO, 16))
	r.add_child(scatola(Vector3(0.1, 0.1, 0.05), f + Vector3(-0.05, 0.12, 0.17), "brace", Vector3(0, 25, 0)))
	for k in 4:
		r.add_child(sfera(0.05 + k * 0.012, f + Vector3(0.0, 0.66 + k * 0.08, -0.01 * k), "fumo"))
	r.add_child(sfera(0.07, f + Vector3(-0.28, 0.1, 0.05), "pelle_scura", Vector3(1.4, 0.5, 1.0)))
	for k in 6:
		r.add_child(scatola(Vector3(0.09, 0.025, 0.035), Vector3(-0.45 + (k % 3) * 0.1, 0.013 + (k / 3) * 0.026, 0.55), "lingotto"))
	r.add_child(mucchio(Vector3(-0.62, 0, 0.25), "carbone", 9, 6))
	r.add_child(mucchio(Vector3(0.68, 0, -0.1), "minerale", 9, 7))
	return r


## Fabbro dei Saraceni: bottega di calce col comignolo di terra cruda, fucina all'aperto sotto la pergola di canne,
## focolare di terra cruda, incudine, attrezzi appesi, vasca dell'acqua di maiolica, lingotti.
static func fabbro_saraceni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.28)
	r.add_child(c)
	var lx := 0.72
	var lz := 0.5
	var top := _muri_s(c, lx, lz, 0.36, 1281)
	_porta_s(c, Vector3(0.16, 0.07, lz * 0.5), 0.0, 0.13, 0.16)
	_finestra_s(c, Vector3(-0.18, 0.27, lz * 0.5), 0.0)
	_finestra_s(c, Vector3(lx * 0.5, 0.27, 0.0), 90.0)
	_camino_s(c, Vector3(-0.22, top, -0.05), 0.2)
	_pergola_s(r, Vector3(-0.2, 0, 0.43), 0.66, 0.32, 0.32)
	r.add_child(scatola(Vector3(0.2, 0.12, 0.16), Vector3(-0.38, 0.06, 0.42), "terra_cruda"))
	r.add_child(scatola(Vector3(0.22, 0.016, 0.18), Vector3(-0.38, 0.128, 0.42), "calce"))
	r.add_child(scatola(Vector3(0.14, 0.01, 0.1), Vector3(-0.38, 0.14, 0.42), "brace"))
	r.add_child(scatola(Vector3(0.06, 0.05, 0.012), Vector3(-0.38, 0.05, 0.505), "brace"))
	r.add_child(cilindro(0.04, 0.05, 0.08, Vector3(-0.05, 0.04, 0.45), "corteccia", Vector3.ZERO, 10))
	r.add_child(scatola(Vector3(0.12, 0.04, 0.05), Vector3(-0.05, 0.1, 0.45), "ferro"))
	r.add_child(scatola(Vector3(0.04, 0.025, 0.035), Vector3(0.03, 0.1, 0.45), "ferro"))
	r.add_child(scatola(Vector3(0.6, 0.018, 0.018), Vector3(-0.2, 0.3, 0.3), "legno"))
	for k in 4:
		var a := attrezzo(ATTREZZI_FABBRO[k])
		a.position = Vector3(-0.42 + k * 0.1, 0.22, 0.31)
		a.rotation_degrees = Vector3(90, 0, 90)
		r.add_child(a)
	r.add_child(scatola(Vector3(0.15, 0.08, 0.15), Vector3(0.62, 0.04, 0.1), "terra_cruda"))
	r.add_child(scatola(Vector3(0.16, 0.014, 0.16), Vector3(0.62, 0.083, 0.1), "zellige"))
	r.add_child(scatola(Vector3(0.12, 0.005, 0.12), Vector3(0.62, 0.088, 0.1), "acqua_chiara"))
	for k in 3:
		r.add_child(scatola(Vector3(0.09, 0.025, 0.035), Vector3(0.45, 0.013 + k * 0.026, 0.45), "lingotto"))
	return r


## Armaiolo dei Saraceni: la bottega del fabbro con la rastrelliera di lance dai pennoncelli verdi,
## scudi tondi verdi con l'umbone d'oro e una scimitarra sul ceppo.
static func armaiolo_saraceni() -> Node3D:
	var r := fabbro_saraceni()
	r.add_child(scatola(Vector3(0.28, 0.03, 0.05), Vector3(0.48, 0.015, 0.36), "legno_verde"))
	r.add_child(scatola(Vector3(0.28, 0.02, 0.03), Vector3(0.48, 0.34, 0.35), "legno_verde"))
	for k in 5:
		var x := 0.38 + k * 0.05
		r.add_child(cilindro(0.006, 0.006, 0.44, Vector3(x, 0.22, 0.36), "legno", Vector3.ZERO, 5))
		r.add_child(cilindro(0.009, 0.0, 0.04, Vector3(x, 0.46, 0.36), "ferro", Vector3.ZERO, 5))
		r.add_child(scatola(Vector3(0.004, 0.03, 0.04), Vector3(x, 0.41, 0.38), "stoffa_smeraldo"))
	for k in 2:
		var sc := Vector3(0.66 + k * 0.04, 0.09, 0.24 + k * 0.17)
		r.add_child(cilindro(0.08, 0.08, 0.014, sc, "smeraldo", Vector3(0, 0, 80), 16))
		r.add_child(cilindro(0.083, 0.083, 0.008, sc + Vector3(-0.002, 0, 0), "moneta", Vector3(0, 0, 80), 16))
		r.add_child(cilindro(0.074, 0.074, 0.016, sc + Vector3(0.001, 0, 0), "smeraldo", Vector3(0, 0, 80), 16))
		r.add_child(sfera(0.02, sc + Vector3(0.01, 0, 0), "moneta"))
	var sci := Node3D.new()
	sci.position = Vector3(0.3, 0.12, 0.6)
	sci.rotation_degrees.y = 20
	r.add_child(sci)
	sci.add_child(scatola(Vector3(0.16, 0.005, 0.022), Vector3(0.04, 0, 0), "ferro", Vector3(0, 12, 0)))
	sci.add_child(scatola(Vector3(0.008, 0.008, 0.06), Vector3(-0.045, 0, 0), "moneta"))
	sci.add_child(cilindro(0.008, 0.008, 0.05, Vector3(-0.07, 0, 0), "cuoio", Vector3(0, 0, 90), 6))
	r.add_child(cilindro(0.06, 0.065, 0.11, Vector3(0.3, 0.055, 0.6), "corteccia", Vector3.ZERO, 12))
	return r


## Zecca dei Saraceni: palazzetto di calce con la grande cupola verde, portico di due colonne sotto la fascia
## di maiolica, casse di monete d'oro, incudine per coniare, argento grezzo, guardia col turbante, insegna verde.
static func zecca_saraceni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.25)
	r.add_child(c)
	var lx := 0.74
	var lz := 0.56
	var top := _muri_s(c, lx, lz, 0.42, 1291)
	_porta_s(c, Vector3(0.0, 0.07, lz * 0.5), 0.0, 0.15, 0.17)
	_finestra_s(c, Vector3(lx * 0.5, 0.31, 0.12), 90.0)
	_finestra_s(c, Vector3(lx * 0.5, 0.31, -0.14), 90.0)
	for x: float in [-0.25, 0.25]:
		c.add_child(scatola(Vector3(0.07, 0.03, 0.07), Vector3(x, 0.085, lz * 0.5 + 0.07), "blocco"))
		c.add_child(cilindro(0.024, 0.024, top - 0.17, Vector3(x, 0.1 + (top - 0.17) * 0.5, lz * 0.5 + 0.07), "marmo", Vector3.ZERO, 12))
		c.add_child(scatola(Vector3(0.06, 0.03, 0.06), Vector3(x, top - 0.055, lz * 0.5 + 0.07), "calce"))
	c.add_child(scatola(Vector3(lx - 0.04, 0.05, 0.12), Vector3(0, top - 0.015, lz * 0.5 + 0.05), "calce"))
	c.add_child(scatola(Vector3(lx - 0.06, 0.024, 0.006), Vector3(0, top - 0.015, lz * 0.5 + 0.112), "zellige"))
	_fila_merli(c, Vector3(-lx * 0.5 + 0.03, top + 0.01, lz * 0.5 + 0.08), Vector3(lx * 0.5 - 0.03, top + 0.01, lz * 0.5 + 0.08), "calce", 0.72)
	c.add_child(scatola(Vector3(0.4, 0.12, 0.4), Vector3(0, top + 0.06, -0.06), "calce"))
	c.add_child(scatola(Vector3(0.42, 0.02, 0.42), Vector3(0, top + 0.12, -0.06), "terra_cruda"))
	_cupola(c, Vector3(0, top + 0.13, -0.06), 0.17)
	for k in 3:
		r.add_child(cassa(Vector3(0.45 + k * 0.12, 0, 0.4), k * 15, 0.1))
		r.add_child(cilindro(0.035, 0.035, 0.01, Vector3(0.45 + k * 0.12, 0.085, 0.4), "moneta", Vector3.ZERO, 10))
	r.add_child(cilindro(0.04, 0.05, 0.08, Vector3(-0.35, 0.04, 0.5), "corteccia", Vector3.ZERO, 10))
	r.add_child(scatola(Vector3(0.1, 0.035, 0.05), Vector3(-0.35, 0.095, 0.5), "ferro"))
	r.add_child(mucchio(Vector3(-0.62, 0, 0.25), "argento_grezzo", 8, 10))
	r.add_child(_guardia_s(Vector3(0.15, 0, 0.5)))
	_stendardo_s(r, Vector3(0.66, 0, 0.12), 0.55)
	return r


## Porto dei Saraceni: banchina di pietra chiara con il bordo di terra cruda, pontile di legno sul mare, bitte,
## fondaco di calce con la cupola e la tenda a strisce sul davanti, giare, casse, gru di legno, vela verde arrotolata,
## insegna verde.
static func porto_saraceni() -> Node3D:
	var r := Node3D.new()
	var rng := _rng(2921)
	r.add_child(scatola(Vector3(0.42, 0.1, 1.08), Vector3(0.36, 0.05, 0.02), "blocco"))
	r.add_child(scatola(Vector3(0.44, 0.02, 1.1), Vector3(0.36, 0.06, 0.02), "terra_cruda"))
	r.add_child(scatola(Vector3(0.46, 0.025, 1.12), Vector3(0.36, 0.112, 0.02), "battuto"))
	for k in 6:
		r.add_child(scatola(Vector3(0.012, 0.004, 1.1), Vector3(0.18 + k * 0.07, 0.126, 0.02), "blocco"))
	var pz := 0.26
	for k in 4:
		var x := 0.66 + k * 0.13
		for s: int in [-1, 1]:
			r.add_child(cilindro(0.017, 0.019, 0.26, Vector3(x, -0.01, pz + s * 0.12), "legno_vecchio", Vector3.ZERO, 7))
			r.add_child(cilindro(0.02, 0.02, 0.012, Vector3(x, 0.01, pz + s * 0.12), "foglie_scure", Vector3.ZERO, 7))
	for s: int in [-1, 1]:
		r.add_child(scatola(Vector3(0.5, 0.025, 0.02), Vector3(0.82, 0.095, pz + s * 0.12), "legno_scuro"))
	for k in 13:
		var x := 0.59 + k * 0.038
		r.add_child(scatola(Vector3(0.034, 0.014, 0.28), Vector3(x, 0.112 + rng.randf_range(-0.003, 0.003), pz), "legno" if k % 3 else "legno_chiaro", Vector3(0, rng.randf_range(-2, 2), 0)))
	for z: float in [-0.42, -0.08, 0.5]:
		r.add_child(cilindro(0.022, 0.026, 0.07, Vector3(0.54, 0.16, z), "calce", Vector3.ZERO, 10))
		r.add_child(cilindro(0.03, 0.03, 0.014, Vector3(0.54, 0.198, z), "terra_cruda", Vector3.ZERO, 10))
	for x: float in [0.72, 1.02]:
		for s: int in [-1, 1]:
			r.add_child(cilindro(0.014, 0.016, 0.07, Vector3(x, 0.155, pz + s * 0.125), "legno_scuro", Vector3.ZERO, 7))
	r.add_child(cilindro(0.03, 0.03, 0.014, Vector3(0.54, 0.177, -0.08), "corda", Vector3.ZERO, 10))
	ramo(r, Vector3(0.54, 0.175, -0.08), Vector3(0.66, 0.02, -0.02), 0.005, "corda")
	ramo(r, Vector3(1.02, 0.17, pz + 0.125), Vector3(1.1, 0.03, pz + 0.2), 0.005, "corda")
	# fondaco del porto con la cupola, e la tenda a strisce sul davanti
	var c := Node3D.new()
	c.position = Vector3(-0.28, 0, -0.26)
	r.add_child(c)
	var lx := 0.62
	var lz := 0.4
	var top := _muri_s(c, lx, lz, 0.34, 2922)
	_porta_s(c, Vector3(-0.1, 0.07, lz * 0.5), 0.0, 0.14, 0.15, true)
	_finestra_s(c, Vector3(0.16, 0.27, lz * 0.5), 0.0)
	_finestra_s(c, Vector3(lx * 0.5, 0.27, 0.0), 90.0)
	c.add_child(scatola(Vector3(0.26, 0.1, 0.26), Vector3(-0.12, top + 0.05, -0.04), "calce"))
	_cupola(c, Vector3(-0.12, top + 0.1, -0.04), 0.11)
	_tappeto(c, Vector3(0.16, top + 0.05, lz * 0.5 + 0.03), 0.0, 0.12, 0.14)
	var pd := 0.2
	c.add_child(scatola(Vector3(lx + 0.06, 0.06, pd + 0.02), Vector3(0, 0.03, lz * 0.5 + pd * 0.5), "terra_cruda"))
	c.add_child(scatola(Vector3(lx + 0.08, 0.016, pd + 0.04), Vector3(0, 0.068, lz * 0.5 + pd * 0.5), "zellige"))
	_tenda(c, Vector3(0, 0.076, lz * 0.5 + pd * 0.5), lx + 0.04, pd, 0.3, 0.26, 0.0, "tenda_verde", false)
	for i in 4:
		c.add_child(anfora(Vector3(0.06 + i * 0.06, 0.076, lz * 0.5 + 0.07), 0.85))
	c.add_child(sacco(Vector3(-0.22, 0.076, lz * 0.5 + 0.08), 0.3))
	r.add_child(scatola(Vector3(0.62, 0.012, 0.5), Vector3(-0.12, 0.006, 0.32), "battuto"))
	var ra := Node3D.new()
	ra.position = Vector3(-0.42, 0, 0.34)
	r.add_child(ra)
	ra.add_child(scatola(Vector3(0.3, 0.02, 0.2), Vector3(0, 0.02, 0), "legno_verde"))
	for f in 3:
		for k in 3 - f:
			var a := anfora(Vector3((k - (2 - f) * 0.5) * 0.085, 0.07 + f * 0.072, -0.07), 0.8)
			a.rotation_degrees.x = 90
			ra.add_child(a)
	for k in 3:
		ra.add_child(anfora(Vector3(-0.1 + k * 0.1, 0.03, 0.12), 0.9))
	r.add_child(cassa(Vector3(0.06, 0.012, 0.42), 10))
	r.add_child(cassa(Vector3(0.18, 0.012, 0.44), -15))
	r.add_child(cassa(Vector3(0.11, 0.1, 0.43), 30, 0.1))
	r.add_child(scatola(Vector3(0.1, 0.004, 0.1), Vector3(0.11, 0.182, 0.43), "corda", Vector3(0, 30, 0)))
	r.add_child(cilindro(0.028, 0.028, 0.16, Vector3(-0.06, 0.04, 0.54), "seta_cremisi", Vector3(0, 70, 90), 10))
	r.add_child(cilindro(0.028, 0.028, 0.16, Vector3(-0.04, 0.09, 0.55), "seta_azzurra", Vector3(0, 80, 90), 10))
	r.add_child(cesta(Vector3(0.28, 0.125, 0.4), "agrumi", 0.8))
	var g := Node3D.new()
	g.position = Vector3(0.42, 0.125, -0.28)
	r.add_child(g)
	var cima := Vector3(0.36, 0.62, 0.0)
	for s: int in [-1, 1]:
		ramo(g, Vector3(-0.04, 0, s * 0.12), cima, 0.016, "legno")
	ramo(g, Vector3(-0.22, 0, 0), cima + Vector3(-0.02, -0.02, 0), 0.012, "legno_vecchio")
	g.add_child(scatola(Vector3(0.02, 0.02, 0.26), Vector3(0.06, 0.18, 0), "legno_scuro"))
	g.add_child(cilindro(0.03, 0.03, 0.2, Vector3(0.0, 0.1, 0), "legno_scuro", Vector3(90, 0, 0), 10))
	g.add_child(cilindro(0.032, 0.032, 0.06, Vector3(0.0, 0.1, 0), "corda", Vector3(90, 0, 0), 10))
	g.add_child(cilindro(0.025, 0.025, 0.04, cima, "legno_chiaro", Vector3(90, 0, 0), 10))
	ramo(g, Vector3(0.0, 0.12, 0), cima, 0.004, "corda")
	ramo(g, cima, cima + Vector3(0, -0.34, 0), 0.004, "corda")
	var rete := Node3D.new()
	rete.position = cima + Vector3(0, -0.42, 0)
	g.add_child(rete)
	rete.add_child(scatola(Vector3(0.09, 0.006, 0.09), Vector3.ZERO, "legno_chiaro"))
	for k in 2:
		rete.add_child(anfora(Vector3(-0.022 + k * 0.044, 0.003, 0), 0.6))
	for s: int in [-1, 1]:
		ramo(rete, Vector3(s * 0.045, 0, 0), Vector3(0, 0.08, 0), 0.003, "corda")
	var v := Node3D.new()
	v.position = Vector3(0.3, 0.125, 0.1)
	v.rotation_degrees.y = 8
	r.add_child(v)
	v.add_child(cilindro(0.008, 0.008, 0.5, Vector3(0, 0.02, 0), "legno_chiaro", Vector3(90, 0, 0), 6))
	for k in 7:
		v.add_child(cilindro(0.032, 0.032, 0.06, Vector3(0, 0.034, -0.18 + k * 0.06), "lino" if k % 2 == 0 else "stoffa_smeraldo", Vector3(90, 0, 0), 10))
	for k in 4:
		v.add_child(cilindro(0.035, 0.035, 0.008, Vector3(0, 0.034, -0.15 + k * 0.1), "corda", Vector3(90, 0, 0), 10))
	r.add_child(cilindro(0.04, 0.04, 0.02, Vector3(0.2, 0.135, -0.48), "corda", Vector3.ZERO, 12))
	r.add_child(cilindro(0.02, 0.02, 0.022, Vector3(0.2, 0.136, -0.48), "legno_scuro", Vector3.ZERO, 8))
	var an := _ancora_nave(Vector3(0.88, 0.12, pz), 90)
	an.scale = Vector3.ONE * 0.6
	r.add_child(an)
	_stendardo_s(r, Vector3(0.52, 0.125, 0.42), 0.46)
	return r


# =================================================================== NORMANNI (step 22)
# Pietra squadrata grigia a conci regolari, tetti di ardesia scura molto inclinati, piani alti a graticcio di legno scuro,
# torri quadrate merlate con le lesene, palizzate di pali appuntiti, stendardi e scudi a mandorla; colore del popolo: giallo oro.

## Texture di conci squadrati: file regolari di blocchi rettangolari sfalsati, giunti sottili di malta grigia.
static func _conci_tex(seme: int, dim := 128, scuro := Color("66686a"), chiaro := Color("a2a29c"), malta := Color("3c3c3a")) -> ImageTexture:
	var rng := RandomNumberGenerator.new()
	rng.seed = seme
	var img := Image.create(dim, dim, false, Image.FORMAT_RGBA8)
	img.fill(malta)
	var n := FastNoiseLite.new()
	n.seed = seme
	n.frequency = 0.18
	var fila := 0
	for y in range(0, dim, 16):
		var x := -(fila % 2) * 16
		while x < dim:
			var w := 32
			var base := scuro.lerp(chiaro, rng.randf())
			for yy in range(y + 1, mini(y + 15, dim)):
				for xx in range(maxi(x + 1, 0), mini(x + w - 1, dim)):
					var v := n.get_noise_2d(xx, yy) * 0.07
					var bordo := 1.0 - 0.14 * float(yy == y + 1 or xx == x + 1)
					var c := Color(base.r + v, base.g + v, base.b + v) * bordo
					c.a = 1.0
					img.set_pixel(xx, yy, c)
			x += w
		fila += 1
	img.generate_mipmaps()
	return ImageTexture.create_from_image(img)


## Texture di ardesia: file di lastre scure sfalsate, ogni lastra più scura verso il basso dove copre quella sotto.
static func _ardesia_tex(seme: int, dim := 128) -> ImageTexture:
	var rng := RandomNumberGenerator.new()
	rng.seed = seme
	var img := Image.create(dim, dim, false, Image.FORMAT_RGBA8)
	img.fill(Color("181b21"))
	var scuro := Color("2c313b")
	var chiaro := Color("525b69")
	for y in range(0, dim, 8):
		var x := -rng.randi_range(0, 10)
		while x < dim:
			var w := rng.randi_range(10, 16)
			var base := scuro.lerp(chiaro, rng.randf())
			for yy in range(y, mini(y + 7, dim)):
				var t := float(yy - y) / 7.0
				for xx in range(maxi(x + 1, 0), mini(x + w, dim)):
					img.set_pixel(xx, yy, base.darkened(t * 0.35))
			x += w
	img.generate_mipmaps()
	return ImageTexture.create_from_image(img)


## Muri normanni: zoccolo di conci scuri, muro di conci grigi con i cantonali chiari e la cornice in cima.
## Con graticcio > 0 solo quella frazione in basso è di pietra: sopra c'è il piano a graticcio di legno scuro,
## appena sporgente, con montanti, traversi e croci. Restituisce la quota della gronda.
static func _muri_n(r: Node3D, lx: float, lz: float, h: float, seme: int, graticcio := 0.0) -> float:
	r.add_child(scatola(Vector3(lx + 0.06, 0.07, lz + 0.06), Vector3(0, 0.035, 0), "pietra_n_scura"))
	var hs := h if graticcio <= 0.0 else h * graticcio
	r.add_child(scatola(Vector3(lx, hs, lz), Vector3(0, 0.07 + hs * 0.5, 0), "pietra_normanna"))
	# cantonali chiari sugli spigoli in vista
	var y := 0.1
	var k := 0
	while y < 0.07 + hs - 0.02:
		var lungo := 0.1 if k % 2 == 0 else 0.06
		r.add_child(scatola(Vector3(0.03, 0.05, lungo), Vector3(lx * 0.5 + 0.004, y, lz * 0.5 - lungo * 0.5 + 0.006), "pietra_n_chiara"))
		r.add_child(scatola(Vector3(lungo, 0.05, 0.03), Vector3(lx * 0.5 - lungo * 0.5 + 0.006, y, lz * 0.5 + 0.004), "pietra_n_chiara"))
		r.add_child(scatola(Vector3(lungo, 0.05, 0.03), Vector3(-lx * 0.5 + lungo * 0.5 - 0.006, y, lz * 0.5 + 0.004), "pietra_n_chiara"))
		r.add_child(scatola(Vector3(0.03, 0.05, lungo), Vector3(lx * 0.5 + 0.004, y, -lz * 0.5 + lungo * 0.5 - 0.006), "pietra_n_chiara"))
		y += 0.056
		k += 1
	if graticcio <= 0.0:
		r.add_child(scatola(Vector3(lx + 0.03, 0.03, lz + 0.03), Vector3(0, 0.07 + h - 0.015, 0), "pietra_n_scura"))
		return 0.07 + h
	# piano a graticcio sporgente sulla trave
	var hg := h - hs
	var y0 := 0.07 + hs
	r.add_child(scatola(Vector3(lx + 0.07, 0.03, lz + 0.07), Vector3(0, y0 + 0.015, 0), "legno_scuro"))
	r.add_child(scatola(Vector3(lx + 0.04, hg, lz + 0.04), Vector3(0, y0 + hg * 0.5, 0), "graticcio_n"))
	_telaio_n(r, Vector3(0, y0, lz * 0.5 + 0.026), lx + 0.04, hg, 0.0, seme)
	_telaio_n(r, Vector3(lx * 0.5 + 0.026, y0, 0), lz + 0.04, hg, 90.0, seme + 1)
	_telaio_n(r, Vector3(-lx * 0.5 - 0.026, y0, 0), lz + 0.04, hg, -90.0, seme + 2)
	return 0.07 + h


## Telaio di legno scuro su una parete (piano locale z = 0, faccia verso +Z locale): montanti, traversi, saette e croci.
static func _telaio_n(r: Node3D, pos: Vector3, larg: float, alt: float, rot_y: float, seme: int) -> void:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot_y
	r.add_child(n)
	var np := maxi(2, int(round(larg / 0.17)))
	var passo := larg / np
	for k in np + 1:
		n.add_child(scatola(Vector3(0.024, alt, 0.014), Vector3(-larg * 0.5 + k * passo, alt * 0.5, 0), "legno_scuro"))
	for yy: float in [0.012, alt * 0.5, alt - 0.012]:
		n.add_child(scatola(Vector3(larg + 0.02, 0.022, 0.014), Vector3(0, yy, 0.001), "legno_scuro"))
	var rng := _rng(seme)
	for k in np:
		var cx := -larg * 0.5 + (k + 0.5) * passo
		var tipo := rng.randi_range(0, 2)
		var d := sqrt(passo * passo + alt * alt * 0.25)
		var a := rad_to_deg(atan2(alt * 0.5, passo))
		if tipo == 0:
			n.add_child(scatola(Vector3(d, 0.02, 0.012), Vector3(cx, alt * 0.25, 0.003), "legno_scuro", Vector3(0, 0, a if k % 2 == 0 else -a)))
		elif tipo == 1:
			for s: float in [-1.0, 1.0]:
				n.add_child(scatola(Vector3(d, 0.02, 0.012), Vector3(cx, alt * 0.75, 0.003 + (s + 1.0) * 0.001), "legno_scuro", Vector3(0, 0, a * s)))
		else:
			n.add_child(scatola(Vector3(d, 0.02, 0.012), Vector3(cx, alt * 0.75, 0.003), "legno_scuro", Vector3(0, 0, -a if k % 2 == 0 else a)))


## Tetto di ardesia molto inclinato (colmo lungo X): file di lastre sovrapposte, colmo di piombo, timpani pieni.
## Restituisce la quota del colmo.
static func _tetto_n(r: Node3D, larg: float, prof: float, base_y: float, pendenza: float, seme: int, timpano := "pietra_normanna") -> float:
	var rng := _rng(seme)
	var meta := prof * 0.5 + 0.06
	var ang := deg_to_rad(pendenza)
	var lung := meta / cos(ang)
	var alt := meta * tan(ang)
	if timpano != "":
		sottotetto(r, larg - 0.06, prof, base_y, pendenza, timpano)
	var nr := maxi(3, int(lung / 0.05))
	for lato: int in [-1, 1]:
		var falda := Node3D.new()
		falda.position = Vector3(0, base_y + alt * 0.5, lato * meta * 0.5)
		falda.rotation.x = lato * ang
		r.add_child(falda)
		falda.add_child(scatola(Vector3(larg + 0.1, 0.022, lung), Vector3.ZERO, "ardesia_b"))
		for j in nr:
			var z := lato * (-lung * 0.5 + (j + 0.5) * lung / nr)
			var fila := scatola(Vector3(larg + 0.1, 0.012, lung / nr * 1.25), Vector3(0, 0.016, z), "ardesia" if rng.randf() < 0.75 else "ardesia_b")
			fila.rotation_degrees.x = -lato * 5.0
			falda.add_child(fila)
		for k in 4:
			var x := rng.randf_range(-larg * 0.45, larg * 0.45)
			var z := lato * rng.randf_range(-lung * 0.4, lung * 0.4)
			falda.add_child(scatola(Vector3(0.05, 0.014, 0.05), Vector3(x, 0.024, z), "pietra_n_scura"))
	r.add_child(scatola(Vector3(larg + 0.12, 0.035, 0.05), Vector3(0, base_y + alt + 0.01, 0), "piombo"))
	return base_y + alt


## Tettoia di ardesia a una falda su pali di legno scuro: alta dietro (-Z locale), bassa davanti (+Z locale).
static func _tettoia_n(r: Node3D, pos: Vector3, larg: float, prof: float, h_dietro: float, h_davanti: float, rot_y := 0.0, pali_dietro := true) -> void:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot_y
	r.add_child(n)
	for x: float in [-larg * 0.5 + 0.02, larg * 0.5 - 0.02]:
		n.add_child(scatola(Vector3(0.03, h_davanti, 0.03), Vector3(x, h_davanti * 0.5, prof * 0.5 - 0.02), "legno_scuro"))
		if pali_dietro:
			n.add_child(scatola(Vector3(0.03, h_dietro, 0.03), Vector3(x, h_dietro * 0.5, -prof * 0.5 + 0.02), "legno_scuro"))
		var dl := sqrt(0.01 + 0.01)
		n.add_child(scatola(Vector3(0.016, dl, 0.016), Vector3(x, h_davanti - 0.06, prof * 0.5 - 0.08), "legno_scuro", Vector3(45, 0, 0)))
	n.add_child(scatola(Vector3(larg, 0.03, 0.03), Vector3(0, h_davanti - 0.015, prof * 0.5 - 0.02), "legno_scuro"))
	var dh := h_dietro - h_davanti
	var lung := sqrt(prof * prof + dh * dh) + 0.08
	var f := Node3D.new()
	f.position = Vector3(0, (h_dietro + h_davanti) * 0.5 + 0.02, 0)
	f.rotation.x = atan2(dh, prof)
	n.add_child(f)
	f.add_child(scatola(Vector3(larg + 0.08, 0.02, lung), Vector3.ZERO, "ardesia_b"))
	var nr := maxi(3, int(lung / 0.05))
	for j in nr:
		var fila := scatola(Vector3(larg + 0.08, 0.012, lung / nr * 1.25), Vector3(0, 0.014, -lung * 0.5 + (j + 0.5) * lung / nr), "ardesia" if j % 3 != 1 else "ardesia_b")
		fila.rotation_degrees.x = 5.0
		f.add_child(fila)


## Porta ad arco a tutto sesto su una facciata (piede in pos, faccia verso +Z locale): stipiti e conci chiari,
## battente di legno scuro con le bandelle di ferro (o vano buio se aperta), gradino.
static func _porta_n(r: Node3D, pos: Vector3, rot_y := 0.0, w := 0.13, h := 0.17, aperta := false) -> void:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot_y
	r.add_child(n)
	var mat := "buio" if aperta else "legno_scuro"
	n.add_child(scatola(Vector3(w, h, 0.02), Vector3(0, h * 0.5, 0.004), mat))
	n.add_child(cilindro(w * 0.5, w * 0.5, 0.02, Vector3(0, h, 0.004), mat, Vector3(90, 0, 0), 14))
	if not aperta:
		for yy: float in [h * 0.3, h * 0.75]:
			n.add_child(scatola(Vector3(w * 0.85, 0.012, 0.008), Vector3(0, yy, 0.016), "ferro"))
		n.add_child(sfera(0.008, Vector3(w * 0.25, h * 0.5, 0.018), "ferro"))
	for s: float in [-1.0, 1.0]:
		n.add_child(scatola(Vector3(0.03, h, 0.03), Vector3(s * (w * 0.5 + 0.015), h * 0.5, 0.01), "pietra_n_chiara"))
	var nc := 7
	var rg := w * 0.5 + 0.015
	for k in nc:
		var a := (k + 0.5) * PI / nc
		n.add_child(scatola(Vector3(0.03, PI * rg / nc * 1.05, 0.034), Vector3(cos(a) * rg, h + sin(a) * rg, 0.01), "pietra_n_chiara" if k % 2 == 0 else "pietra_n_scura", Vector3(0, 0, rad_to_deg(a))))
	n.add_child(scatola(Vector3(w + 0.08, 0.03, 0.06), Vector3(0, -0.015, 0.03), "pietra_n_scura"))


## Monofora a tutto sesto (centro in pos, faccia verso +Z locale): vano buio stretto, conci chiari, davanzale.
static func _finestra_n(r: Node3D, pos: Vector3, rot_y := 0.0, w := 0.05, h := 0.08) -> void:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot_y
	r.add_child(n)
	n.add_child(scatola(Vector3(w, h, 0.02), Vector3(0, 0, 0.004), "buio"))
	n.add_child(cilindro(w * 0.5, w * 0.5, 0.02, Vector3(0, h * 0.5, 0.004), "buio", Vector3(90, 0, 0), 12))
	var rg := w * 0.5 + 0.012
	for k in 5:
		var a := (k + 0.5) * PI / 5
		n.add_child(scatola(Vector3(0.022, PI * rg / 5 * 1.1, 0.026), Vector3(cos(a) * rg, h * 0.5 + sin(a) * rg, 0.008), "pietra_n_chiara", Vector3(0, 0, rad_to_deg(a))))
	n.add_child(scatola(Vector3(w + 0.04, 0.018, 0.035), Vector3(0, -h * 0.5 - 0.009, 0.014), "pietra_n_chiara"))


## Finestrella quadrata del piano a graticcio con l'imposta di legno aperta (faccia verso +Z locale).
static func _finestrella_n(r: Node3D, pos: Vector3, rot_y := 0.0, w := 0.07, h := 0.07) -> void:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot_y
	r.add_child(n)
	n.add_child(scatola(Vector3(w, h, 0.02), Vector3(0, 0, 0.006), "buio"))
	n.add_child(scatola(Vector3(w + 0.03, 0.018, 0.024), Vector3(0, h * 0.5 + 0.009, 0.01), "legno_scuro"))
	n.add_child(scatola(Vector3(w + 0.03, 0.018, 0.03), Vector3(0, -h * 0.5 - 0.009, 0.012), "legno_scuro"))
	n.add_child(scatola(Vector3(0.008, h, 0.01), Vector3(0, 0, 0.016), "legno_scuro"))
	n.add_child(scatola(Vector3(w * 0.5, h, 0.01), Vector3(w * 0.5 + w * 0.22, 0, 0.03), "legno", Vector3(0, -50, 0)))


## Merli quadrati lungo il bordo di un rettangolo (centro in c alla quota della cima), con il camminamento.
static func _merli_n(r: Node3D, c: Vector3, lx: float, lz: float, mat := "pietra_normanna", passo := 0.12, alt := 0.08) -> void:
	r.add_child(scatola(Vector3(lx + 0.03, 0.03, lz + 0.03), c + Vector3(0, -0.015, 0), "pietra_n_scura"))
	var sp := 0.05
	for i in 4:
		var lungo := lx if i % 2 == 0 else lz
		var off := (lz if i % 2 == 0 else lx) * 0.5 - sp * 0.5
		var m := Node3D.new()
		m.position = c
		m.rotation_degrees.y = i * 90.0
		r.add_child(m)
		var nm := maxi(2, int(round(lungo / passo)))
		for k in nm:
			m.add_child(scatola(Vector3(lungo / nm * 0.55, alt, sp), Vector3(-lungo * 0.5 + (k + 0.5) * lungo / nm, alt * 0.5, off), mat))


## Torre quadrata normanna: zoccolo a scarpa, conci grigi, lesene sugli spigoli, cornici, feritoie, merli.
## Con tetto = true sopra i merli sale una cuspide di ardesia a piramide. Restituisce la quota dei merli.
static func _torre_n(r: Node3D, pos: Vector3, lato: float, h: float, tetto := false, finestre := true) -> float:
	r.add_child(cilindro(lato * 0.78, lato * 0.71, 0.14, pos + Vector3(0, 0.07, 0), "pietra_n_scura", Vector3(0, 45, 0), 4))
	r.add_child(scatola(Vector3(lato, h, lato), pos + Vector3(0, h * 0.5, 0), "pietra_normanna"))
	for s: float in [-1.0, 1.0]:
		r.add_child(scatola(Vector3(0.05, h - 0.12, 0.022), pos + Vector3(s * (lato * 0.5 - 0.025), 0.12 + (h - 0.12) * 0.5, lato * 0.5 + 0.01), "pietra_n_chiara"))
		r.add_child(scatola(Vector3(0.022, h - 0.12, 0.05), pos + Vector3(lato * 0.5 + 0.01, 0.12 + (h - 0.12) * 0.5, s * (lato * 0.5 - 0.025)), "pietra_n_chiara"))
	for yy: float in [h * 0.45, h - 0.03]:
		r.add_child(scatola(Vector3(lato + 0.03, 0.03, lato + 0.03), pos + Vector3(0, yy, 0), "pietra_n_scura"))
	if finestre:
		r.add_child(scatola(Vector3(0.022, 0.09, 0.02), pos + Vector3(0, h * 0.3, lato * 0.5 + 0.004), "buio"))
		r.add_child(scatola(Vector3(0.02, 0.09, 0.022), pos + Vector3(lato * 0.5 + 0.004, h * 0.3, 0), "buio"))
		_finestra_n(r, pos + Vector3(0, h * 0.7, lato * 0.5), 0.0, 0.045, 0.07)
		_finestra_n(r, pos + Vector3(lato * 0.5, h * 0.7, 0), 90.0, 0.045, 0.07)
	_merli_n(r, pos + Vector3(0, h, 0), lato + 0.03, lato + 0.03, "pietra_normanna", 0.11)
	if tetto:
		var rg := lato * 0.62
		r.add_child(cilindro(rg, 0.0, lato * 1.25, pos + Vector3(0, h + lato * 0.625, 0), "ardesia", Vector3(0, 45, 0), 4))
		r.add_child(cilindro(0.012, 0.005, 0.1, pos + Vector3(0, h + lato * 1.25 + 0.04, 0), "piombo", Vector3.ZERO, 6))
	return h


## Stendardo normanno: asta scura con il puntale, gonfalone giallo oro a due code con la banda rossa.
static func _stendardo_n(r: Node3D, pos: Vector3, h := 0.6, s := 1.0) -> void:
	r.add_child(cilindro(0.011 * s, 0.011 * s, h, pos + Vector3(0, h * 0.5, 0), "legno_scuro", Vector3.ZERO, 6))
	r.add_child(cilindro(0.016 * s, 0.0, 0.05 * s, pos + Vector3(0, h + 0.025 * s, 0), "ferro", Vector3.ZERO, 6))
	var b := Node3D.new()
	b.position = pos + Vector3(0, h - 0.02 * s, 0)
	b.scale = Vector3.ONE * s
	r.add_child(b)
	b.add_child(scatola(Vector3(0.012, 0.012, 0.17), Vector3(0, 0, 0.085), "legno_scuro"))
	b.add_child(scatola(Vector3(0.007, 0.16, 0.16), Vector3(0, -0.085, 0.09), "stoffa_oro"))
	for z: float in [0.045, 0.135]:
		b.add_child(scatola(Vector3(0.007, 0.06, 0.06), Vector3(0, -0.19, z), "stoffa_oro", Vector3(0, 0, 0)))
	b.add_child(scatola(Vector3(0.009, 0.032, 0.162), Vector3(0, -0.085, 0.09), "bandiera_rossa"))
	b.add_child(scatola(Vector3(0.009, 0.162, 0.032), Vector3(0, -0.085, 0.09), "bandiera_rossa"))


## Scudo a mandorla giallo oro (faccia verso +Z locale): parte alta tonda, punta in basso, orlo scuro, croce rossa e umbone.
static func _scudo_n(pos: Vector3, rot_y := 0.0, s := 1.0) -> Node3D:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot_y
	n.scale = Vector3(s, s, s * 0.22)
	n.add_child(sfera(0.056, Vector3(0, 0.03, -0.025), "legno_scuro", Vector3(1, 0.9, 1)))
	n.add_child(cilindro(0.0, 0.056, 0.135, Vector3(0, -0.04, -0.025), "legno_scuro", Vector3(0, 45, 0), 4))
	n.add_child(sfera(0.05, Vector3(0, 0.03, 0), "oro_n", Vector3(1, 0.9, 1)))
	n.add_child(cilindro(0.0, 0.05, 0.12, Vector3(0, -0.035, 0), "oro_n", Vector3(0, 45, 0), 4))
	n.add_child(scatola(Vector3(0.016, 0.17, 0.05), Vector3(0, -0.01, 0.03), "bandiera_rossa"))
	n.add_child(scatola(Vector3(0.08, 0.016, 0.05), Vector3(0, 0.035, 0.03), "bandiera_rossa"))
	n.add_child(sfera(0.014, Vector3(0, 0.035, 0.06), "ferro"))
	return n


## Cavallo normanno (destriero robusto), con le stesse parti mobili del cavallo saraceno per le pose di galoppo e carica.
static func _cavallo_n(mat := "cavallo_baio", robusto := 1.12) -> Node3D:
	var r := Node3D.new()
	var corpo := Node3D.new()
	corpo.name = "corpo"
	r.add_child(corpo)
	for nome in ["zampa_as", "zampa_ad", "zampa_ps", "zampa_pd"]:
		var davanti: bool = nome.begins_with("zampa_a")
		var lato := -1.0 if nome.ends_with("s") else 1.0
		var z := Node3D.new()
		z.name = nome
		z.position = Vector3(lato * 0.046 * robusto, 0.27, 0.12 if davanti else -0.12)
		corpo.add_child(z)
		z.add_child(cilindro(0.025 * robusto if davanti else 0.031 * robusto, 0.017, 0.13, Vector3(0, -0.065, 0), mat, Vector3.ZERO, 7))
		var st := Node3D.new()
		st.name = "stinco"
		st.position = Vector3(0, -0.13, 0)
		z.add_child(st)
		st.add_child(cilindro(0.015, 0.013, 0.12, Vector3(0, -0.06, 0), mat, Vector3.ZERO, 6))
		# barbette chiare sopra lo zoccolo, come i cavalli da guerra pesanti
		st.add_child(cilindro(0.017, 0.022, 0.03, Vector3(0, -0.105, 0.002), "lino_bianco", Vector3.ZERO, 7))
		st.add_child(cilindro(0.018, 0.02, 0.02, Vector3(0, -0.127, 0.004), "crine", Vector3.ZERO, 7))
	corpo.add_child(sfera(0.1, Vector3(0, 0.31, 0), mat, Vector3(0.78 * robusto, 0.82, 1.85)))
	corpo.add_child(sfera(0.08, Vector3(0, 0.315, 0.12), mat, Vector3(1.0 * robusto, 1.08, 1.0)))
	corpo.add_child(sfera(0.084, Vector3(0, 0.325, -0.12), mat, Vector3(1.0 * robusto, 1.0, 1.05)))
	var collo := Node3D.new()
	collo.name = "collo"
	collo.position = Vector3(0, 0.34, 0.15)
	corpo.add_child(collo)
	var cn := Node3D.new()
	cn.rotation_degrees.x = 30
	collo.add_child(cn)
	cn.add_child(cilindro(0.036, 0.056, 0.2, Vector3(0, 0.08, 0), mat, Vector3.ZERO, 8))
	cn.add_child(scatola(Vector3(0.018, 0.19, 0.03), Vector3(0, 0.085, -0.04), "crine"))
	var testa := sfera(0.045, Vector3(0, 0.165, 0.135), mat, Vector3(0.78, 0.8, 1.55))
	testa.rotation_degrees.x = 38
	collo.add_child(testa)
	collo.add_child(sfera(0.032, Vector3(0, 0.12, 0.19), "crine", Vector3(0.85, 0.85, 1.1)))
	collo.add_child(scatola(Vector3(0.012, 0.05, 0.03), Vector3(0, 0.19, 0.15), "lino_bianco", Vector3(38, 0, 0)))
	for lato: int in [-1, 1]:
		collo.add_child(cilindro(0.008, 0.002, 0.04, Vector3(lato * 0.017, 0.215, 0.1), mat, Vector3(-15, 0, lato * 12.0), 5))
		collo.add_child(sfera(0.007, Vector3(lato * 0.031, 0.17, 0.15), "buio"))
	collo.add_child(_toro(0.03, 0.036, Vector3(0, 0.13, 0.175), "pelle_scura", Vector3(60, 0, 0), Vector3(1, 1, 1.1)))
	collo.add_child(_toro(0.042, 0.049, Vector3(0, 0.16, 0.115), "pelle_scura", Vector3(-30, 0, 0)))
	corpo.add_child(cilindro(0.026, 0.014, 0.22, Vector3(0, 0.25, -0.25), "crine", Vector3(25, 0, 0), 7))
	corpo.add_child(sfera(0.027, Vector3(0, 0.36, -0.205), "crine"))
	return r


## Gualdrappa giallo oro con l'orlo rosso sul cavallo, pettorale di cuoio con le borchie, sella alta.
static func _gualdrappa_n(corpo: Node3D, robusto := 1.12) -> void:
	corpo.add_child(sfera(0.106, Vector3(0, 0.318, -0.03), "stoffa_oro", Vector3(0.8 * robusto, 0.82, 1.95)))
	for lato: int in [-1, 1]:
		var x := lato * 0.082 * robusto
		corpo.add_child(scatola(Vector3(0.008, 0.14, 0.38), Vector3(x, 0.3, -0.03), "stoffa_oro"))
		corpo.add_child(scatola(Vector3(0.01, 0.022, 0.382), Vector3(x + lato * 0.001, 0.235, -0.03), "bandiera_rossa"))
		corpo.add_child(scatola(Vector3(0.011, 0.07, 0.016), Vector3(x + lato * 0.002, 0.31, -0.03), "bandiera_rossa"))
		corpo.add_child(scatola(Vector3(0.011, 0.016, 0.07), Vector3(x + lato * 0.002, 0.32, -0.03), "bandiera_rossa"))
	corpo.add_child(_toro(0.074, 0.084, Vector3(0, 0.3, 0.16), "pelle_scura", Vector3(70, 0, 0), Vector3(0.95 * robusto, 1, 1)))
	for k in 5:
		var a := deg_to_rad(-60.0 + k * 30.0)
		corpo.add_child(sfera(0.009, Vector3(sin(a) * 0.074 * robusto, 0.27 - cos(a) * 0.02, 0.195 + cos(a) * 0.01), "oro_n"))
	corpo.add_child(scatola(Vector3(0.095, 0.03, 0.11), Vector3(0, 0.412, -0.015), "pelle_scura"))
	corpo.add_child(scatola(Vector3(0.08, 0.055, 0.018), Vector3(0, 0.44, 0.04), "pelle_scura"))
	corpo.add_child(scatola(Vector3(0.08, 0.04, 0.016), Vector3(0, 0.43, -0.07), "pelle_scura"))


# ------------------------------------------------------------------ edifici dei Normanni

## Casa dei Normanni: pianterreno di conci grigi, piano alto a graticcio di legno scuro, tetto ripido di ardesia,
## comignolo di pietra, scudo giallo oro sopra la porta, orto e legnaia.
static func casa_greca_normanni(seme := 1) -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.12, 0, -0.15)
	r.add_child(c)
	var lx := 0.9
	var lz := 0.66
	var top := _muri_n(c, lx, lz, 0.4, seme + 1100, 0.5)
	_porta_n(c, Vector3(-0.2, 0.07, lz * 0.5), 0.0, 0.11, 0.13)
	_finestra_n(c, Vector3(0.17, 0.17, lz * 0.5), 0.0)
	_finestra_n(c, Vector3(lx * 0.5, 0.17, 0.0), 90.0)
	_finestrella_n(c, Vector3(-0.16, 0.37, lz * 0.5 + 0.03), 0.0)
	_finestrella_n(c, Vector3(0.2, 0.37, lz * 0.5 + 0.03), 0.0)
	_finestrella_n(c, Vector3(lx * 0.5 + 0.03, 0.37, 0.0), 90.0)
	var cima := _tetto_n(c, lx + 0.06, lz + 0.04, top, 46.0, seme + 1100, "graticcio_n")
	c.add_child(scatola(Vector3(0.09, cima - top + 0.12, 0.09), Vector3(-0.28, top + (cima - top + 0.12) * 0.5, -0.1), "pietra_normanna"))
	c.add_child(scatola(Vector3(0.1, 0.03, 0.1), Vector3(-0.28, cima + 0.12, -0.1), "pietra_n_scura"))
	_fumo(c, Vector3(-0.28, cima + 0.16, -0.1), 3, 0.7)
	c.add_child(_scudo_n(Vector3(-0.02, 0.17, lz * 0.5 + 0.012), 0.0, 0.8))
	# panca, botte, legnaia sotto la falda
	c.add_child(panca(Vector3(0.12, 0, lz * 0.5 + 0.1), 0))
	c.add_child(barile(Vector3(-0.38, 0.0, lz * 0.5 + 0.1)))
	legnaia(c, Vector3(lx * 0.5 + 0.07, 0.0, -0.18), 0.26, 3)
	# orto chiuso dal graticcio
	orto(r, Vector3(0.56, 0, 0.42), 0.36, 0.42, seme + 3)
	r.add_child(barile(Vector3(-0.62, 0.0, 0.62)))
	r.add_child(sacco(Vector3(-0.52, 0.0, 0.58), 0.4))
	return r


## Magazzino dei Normanni: grande sala di conci grigi con tre arconi, tetto ripido di ardesia,
## porta del fienile con il paranco nel timpano, torre quadrata merlata con lo stendardo, merci davanti.
static func magazzino_normanni() -> Node3D:
	var r := Node3D.new()
	var lx := 1.7
	var lz := 1.15
	r.position = Vector3(0, 0, -0.1)
	r.add_child(scatola(Vector3(lx + 0.32, 0.05, lz + 0.36), Vector3(0, 0.025, 0.02), "pietra_n_scura"))
	var c := Node3D.new()
	c.position = Vector3(0, 0.03, -0.04)
	r.add_child(c)
	var top := _muri_n(c, lx, lz, 0.56, 1201)
	var fz := lz * 0.5
	var fx := lx * 0.5
	for k in 3:
		var x := -0.55 + k * 0.55
		_porta_n(c, Vector3(x, 0.07, fz), 0.0, 0.24, 0.2, k != 1)
		_finestra_n(c, Vector3(x, 0.5, fz), 0.0, 0.06, 0.09)
	for k in 2:
		_finestra_n(c, Vector3(fx, 0.5, -0.25 + k * 0.5), 90.0, 0.06, 0.09)
	_porta_n(c, Vector3(fx, 0.07, 0.2), 90.0, 0.16, 0.18)
	# lesene sulla facciata
	for x: float in [-0.83, -0.28, 0.28, 0.83]:
		c.add_child(scatola(Vector3(0.05, top - 0.1, 0.02), Vector3(x, 0.07 + (top - 0.07) * 0.5, fz + 0.01), "pietra_n_chiara"))
	var cima := _tetto_n(c, lx + 0.08, lz, top, 40.0, 1201)
	# porta del fienile nel timpano con la trave del paranco, la corda e un sacco appeso
	var gy := top + (cima - top) * 0.3
	c.add_child(scatola(Vector3(0.02, 0.13, 0.11), Vector3(fx + 0.04, gy, 0.0), "legno_scuro"))
	c.add_child(scatola(Vector3(0.022, 0.15, 0.13), Vector3(fx + 0.035, gy, 0.0), "pietra_n_chiara"))
	c.add_child(scatola(Vector3(0.24, 0.03, 0.03), Vector3(fx + 0.12, gy + 0.13, 0.0), "legno_scuro"))
	c.add_child(cilindro(0.003, 0.003, 0.3, Vector3(fx + 0.22, gy - 0.02, 0.0), "corda", Vector3.ZERO, 4))
	c.add_child(sfera(0.045, Vector3(fx + 0.22, gy - 0.18, 0.0), "lino", Vector3(0.9, 1.2, 0.9)))
	# torre quadrata merlata dietro a destra
	var tp := Vector3(fx - 0.18, 0, -lz * 0.5 + 0.18)
	var ht := _torre_n(c, tp, 0.38, cima + 0.12, false, true)
	_stendardo_n(c, tp + Vector3(0.1, ht, 0.1), 0.5)
	_stendardo_n(c, Vector3(-fx + 0.05, cima - 0.04, 0.0), 0.36, 0.8)
	# merci e vita davanti al magazzino
	var fr := lz * 0.5 + 0.03
	for i in 4:
		r.add_child(barile(Vector3(-0.85 + (i % 2) * 0.12, 0.05, fr + 0.14 + (i / 2) * 0.12), 1.15))
	for i in 3:
		r.add_child(cassa(Vector3(0.42 + i * 0.13, 0.05, fr + 0.16), i * 12))
	r.add_child(cassa(Vector3(0.49, 0.05 + 0.088, fr + 0.16), 25, 0.09))
	for i in 3:
		r.add_child(sacco(Vector3(-0.32 + i * 0.1, 0.05, fr + 0.14), i * 0.5))
	r.add_child(barile(Vector3(0.98, 0.0, 0.25), 1.2))
	r.add_child(barile(Vector3(1.0, 0.0, 0.38), 1.2))
	pila_assi(r, Vector3(0.98, 0.0, -0.2), 5, 90)
	carretto(r, Vector3(-0.15, 0.0, fr + 0.5), 20, "sacchi")
	_stendardo_n(r, Vector3(fx + 0.14, 0, lz * 0.5 + 0.16), 0.75)
	return r


## Boscaiolo dei Normanni: casetta a graticcio sullo zoccolo di pietra, tettoia di ardesia sopra la legna,
## ceppo con l'ascia, catasta di tronchi e un tratto di palizzata.
static func boscaiolo_normanni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.15, 0, -0.18)
	r.add_child(c)
	var lx := 0.74
	var lz := 0.56
	var top := _muri_n(c, lx, lz, 0.32, 1301, 0.35)
	_porta_n(c, Vector3(-0.14, 0.07, lz * 0.5), 0.0, 0.11, 0.12)
	_finestrella_n(c, Vector3(0.17, 0.27, lz * 0.5 + 0.03), 0.0)
	_finestrella_n(c, Vector3(lx * 0.5 + 0.03, 0.27, 0.0), 90.0)
	var cima := _tetto_n(c, lx + 0.06, lz + 0.04, top, 48.0, 1301, "graticcio_n")
	c.add_child(scatola(Vector3(0.08, 0.14, 0.08), Vector3(-0.22, cima - 0.04, -0.08), "pietra_normanna"))
	_tettoia_n(c, Vector3(lx * 0.5 + 0.15, 0, 0.0), 0.56, 0.3, 0.36, 0.26, 90.0, false)
	legnaia(c, Vector3(lx * 0.5 + 0.15, 0.0, 0.0), 0.46, 5)
	catasta_tronchi(r, Vector3(0.55, 0, 0.55), 4, 0.5)
	r.add_child(cilindro(0.07, 0.075, 0.09, Vector3(-0.2, 0.045, 0.5), "corteccia", Vector3.ZERO, 12))
	r.add_child(cilindro(0.066, 0.066, 0.006, Vector3(-0.2, 0.092, 0.5), "legno_chiaro", Vector3.ZERO, 12))
	r.add_child(cilindro(0.008, 0.008, 0.22, Vector3(-0.2, 0.18, 0.5), "legno", Vector3(0, 0, 22), 6))
	r.add_child(scatola(Vector3(0.06, 0.045, 0.012), Vector3(-0.245, 0.27, 0.5), "ferro", Vector3(0, 0, 22)))
	for i in 6:
		r.add_child(cilindro(0.02, 0.02, 0.06, Vector3(-0.38 + i * 0.06, 0.02, 0.62 + (i % 2) * 0.05), "legno_chiaro", Vector3(0, i * 37, 90), 6))
	for pos in [Vector3(-0.72, 0, 0.3), Vector3(-0.6, 0, 0.75)]:
		r.add_child(cilindro(0.06, 0.07, 0.05, pos + Vector3(0, 0.025, 0), "corteccia", Vector3.ZERO, 10))
		r.add_child(cilindro(0.056, 0.056, 0.005, pos + Vector3(0, 0.052, 0), "legno_chiaro", Vector3.ZERO, 10))
	_palizzata(r, Vector3(-0.75, 0, -0.1), Vector3(-0.75, 0, -0.55), 0.26)
	r.add_child(barile(Vector3(-0.02, 0, 0.2), 1.0))
	return r


## Segheria dei Normanni: bottega di pietra col piano a graticcio, tettoia di ardesia su pali sopra il cavalletto
## con la sega a telaio, pile di assi e tronchi.
static func segheria_normanni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.25)
	r.add_child(c)
	var lx := 0.82
	var lz := 0.58
	var top := _muri_n(c, lx, lz, 0.4, 1401, 0.5)
	_porta_n(c, Vector3(-0.22, 0.07, lz * 0.5), 0.0, 0.14, 0.14, true)
	_finestra_n(c, Vector3(0.16, 0.17, lz * 0.5), 0.0)
	_finestrella_n(c, Vector3(0.0, 0.37, lz * 0.5 + 0.03), 0.0)
	_finestrella_n(c, Vector3(lx * 0.5 + 0.03, 0.37, 0.0), 90.0)
	_tetto_n(c, lx + 0.06, lz + 0.04, top, 46.0, 1401, "graticcio_n")
	# tettoia di ardesia sopra il cavalletto
	var t := Node3D.new()
	t.position = Vector3(0.05, 0, 0.52)
	r.add_child(t)
	_tettoia_n(t, Vector3(0, 0, 0.02), 0.95, 0.46, 0.5, 0.38)
	for px: float in [-0.25, 0.0, 0.25]:
		t.add_child(scatola(Vector3(0.03, 0.12, 0.12), Vector3(px, 0.06, 0.0), "legno_scuro"))
	t.add_child(cilindro(0.055, 0.055, 0.8, Vector3(0, 0.17, 0.0), "corteccia", Vector3(0, 0, 90), 9))
	t.add_child(cilindro(0.047, 0.047, 0.805, Vector3(0, 0.17, 0.0), "legno_chiaro", Vector3(0, 0, 90), 9))
	for z: float in [-0.08, 0.08]:
		t.add_child(scatola(Vector3(0.014, 0.3, 0.014), Vector3(0.1, 0.24, z), "legno"))
	t.add_child(scatola(Vector3(0.014, 0.014, 0.18), Vector3(0.1, 0.38, 0.0), "legno"))
	t.add_child(scatola(Vector3(0.006, 0.006, 0.17), Vector3(0.1, 0.2, 0.0), "ferro"))
	t.add_child(cilindro(0.2, 0.2, 0.004, Vector3(0.1, 0.002, 0.0), "legno_chiaro", Vector3.ZERO, 16))
	pila_assi(r, Vector3(0.62, 0, -0.25), 8, 90)
	pila_assi(r, Vector3(0.62, 0, 0.12), 5, 90)
	catasta_tronchi(r, Vector3(-0.65, 0, 0.55), 3, 0.42)
	carretto(r, Vector3(0.35, 0, 0.88), -30, "tronchi")
	return r


## Cava dei Normanni: casupola di conci col tetto d'ardesia, parete di roccia grigia, blocchi squadrati in pila,
## gru a ruota (il cavatore cammina dentro la ruota) che solleva un concio, carretto.
static func cava_normanni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.38, 0, -0.32)
	r.add_child(c)
	var top := _muri_n(c, 0.46, 0.4, 0.24, 1501)
	_porta_n(c, Vector3(-0.06, 0.07, 0.2), 0.0, 0.1, 0.1)
	_tetto_n(c, 0.5, 0.42, top, 50.0, 1501)
	# rupe grigia a gradoni
	var rng := _rng(1502)
	for k in 10:
		var p := Vector3(0.32 + rng.randf_range(-0.22, 0.22), 0.0, -0.42 + rng.randf_range(-0.14, 0.18))
		var d := rng.randf_range(0.16, 0.3)
		r.add_child(scatola(Vector3(d, d * rng.randf_range(0.7, 1.5), d * 0.8), p + Vector3(0, d * 0.45, 0), "roccia_massi" if k % 3 != 0 else "pietra_n_chiara", Vector3(0, rng.randf() * 60, 0)))
	for i in 4:
		for j in 2 - (i / 3):
			r.add_child(scatola(Vector3(0.13, 0.08, 0.09), Vector3(-0.15 + i * 0.15, 0.04 + j * 0.08, 0.48), "pietra_n_chiara" if (i + j) % 2 == 0 else "pietra_normanna", Vector3(0, i * 5 - 6, 0)))
	# gru a ruota: telaio, ruota grande, albero e braccio con la carrucola
	var g := Vector3(0.12, 0, 0.08)
	var ruota := Vector3(g.x - 0.12, 0.2, g.z)
	r.add_child(_toro(0.15, 0.175, ruota, "legno_scuro", Vector3(0, 0, 90)))
	for k in 6:
		r.add_child(scatola(Vector3(0.012, 0.33, 0.012), ruota, "legno", Vector3(k * 30.0, 0, 0)))
	r.add_child(cilindro(0.016, 0.016, 0.16, ruota, "legno_scuro", Vector3(0, 0, 90), 8))
	for s: float in [-1.0, 1.0]:
		r.add_child(scatola(Vector3(0.025, 0.2, 0.025), Vector3(ruota.x + s * 0.04, 0.1, ruota.z), "legno_scuro"))
	r.add_child(scatola(Vector3(0.03, 0.5, 0.03), g + Vector3(0.0, 0.25, 0), "legno_scuro"))
	var braccio := scatola(Vector3(0.36, 0.025, 0.025), g + Vector3(0.14, 0.47, 0), "legno_scuro", Vector3(0, 0, 18))
	r.add_child(braccio)
	var punta := g + Vector3(0.31, 0.53, 0)
	r.add_child(cilindro(0.022, 0.022, 0.012, punta, "legno", Vector3(90, 0, 0), 10))
	r.add_child(cilindro(0.003, 0.003, 0.3, punta + Vector3(0, -0.15, 0), "corda", Vector3.ZERO, 4))
	r.add_child(scatola(Vector3(0.1, 0.07, 0.08), punta + Vector3(0, -0.34, 0), "pietra_n_chiara"))
	r.add_child(cilindro(0.008, 0.008, 0.22, Vector3(0.6, 0.11, 0.35), "legno", Vector3(0, 0, -25), 6))
	r.add_child(scatola(Vector3(0.11, 0.014, 0.014), Vector3(0.65, 0.21, 0.35), "ferro", Vector3(0, 0, -25)))
	carretto(r, Vector3(-0.45, 0, 0.62), 15)
	r.add_child(scatola(Vector3(0.1, 0.07, 0.07), Vector3(-0.45, 0.16, 0.62), "pietra_n_chiara"))
	r.add_child(barile(Vector3(-0.7, 0, 0.18), 1.0))
	return r


## Guardaboschi dei Normanni: casetta a graticcio col tetto di ardesia, vivaio di abeti e querce giovani
## in file dentro il recinto di graticcio, pala, secchio e sacchi di semi.
static func guardaboschi_normanni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.3, 0, -0.3)
	r.add_child(c)
	var top := _muri_n(c, 0.56, 0.46, 0.28, 1601, 0.4)
	_porta_n(c, Vector3(0.1, 0.07, 0.23), 0.0, 0.1, 0.1)
	_finestrella_n(c, Vector3(-0.13, 0.25, 0.23 + 0.03), 0.0, 0.06, 0.06)
	_finestrella_n(c, Vector3(0.28 + 0.03, 0.25, 0.0), 90.0, 0.06, 0.06)
	_tetto_n(c, 0.62, 0.5, top, 50.0, 1601, "graticcio_n")
	# vivaio nel recinto di graticcio
	var o := Vector3(0.0, 0, 0.3)
	_graticcio(r, o + Vector3(-0.08, 0, 0.0), o + Vector3(0.66, 0, 0.0))
	_graticcio(r, o + Vector3(0.66, 0, 0.0), o + Vector3(0.66, 0, 0.5))
	_graticcio(r, o + Vector3(-0.08, 0, 0.5), o + Vector3(0.66, 0, 0.5))
	r.add_child(scatola(Vector3(0.72, 0.008, 0.48), o + Vector3(0.29, 0.004, 0.25), "terra"))
	for i in 4:
		for j in 3:
			var p := o + Vector3(0.04 + i * 0.16, 0, 0.1 + j * 0.15)
			r.add_child(cilindro(0.005, 0.005, 0.05 + j * 0.02, p + Vector3(0, 0.025 + j * 0.01, 0), "corteccia", Vector3.ZERO, 5))
			if (i + j) % 2 == 0:
				r.add_child(cilindro(0.034 + j * 0.008, 0.0, 0.1 + j * 0.03, p + Vector3(0, 0.08 + j * 0.03, 0), "aghi", Vector3.ZERO, 7))
			else:
				r.add_child(sfera(0.036 + j * 0.008, p + Vector3(0, 0.09 + j * 0.03, 0), "foglie_scure", Vector3(1, 0.9, 1)))
	r.add_child(barile(Vector3(-0.2, 0, 0.42), 0.8))
	r.add_child(cilindro(0.007, 0.007, 0.24, Vector3(-0.32, 0.12, 0.5), "legno", Vector3(12, 0, -15), 5))
	r.add_child(scatola(Vector3(0.05, 0.06, 0.01), Vector3(-0.295, 0.02, 0.48), "ferro", Vector3(12, 0, -15)))
	r.add_child(sacco(Vector3(-0.58, 0, 0.3), 0.4))
	r.add_child(sacco(Vector3(-0.62, 0, 0.44), -0.2))
	r.add_child(pino_laricio(3))
	r.get_child(r.get_child_count() - 1).position = Vector3(0.55, 0, -0.5)
	r.get_child(r.get_child_count() - 1).scale = Vector3.ONE * 0.55
	return r


## Pozzo dei Normanni: vera tonda di conci grigi con l'orlo chiaro, tettuccio ripido di ardesia su due pali,
## argano con la manovella, secchio di legno cerchiato, abbeveratoio di pietra.
static func pozzo_normanni() -> Node3D:
	var r := Node3D.new()
	r.add_child(cilindro(0.26, 0.26, 0.03, Vector3(0, 0.015, 0), "pietra_n_scura", Vector3.ZERO, 14))
	r.add_child(cilindro(0.17, 0.18, 0.18, Vector3(0, 0.12, 0), "pietra_normanna", Vector3.ZERO, 14))
	r.add_child(cilindro(0.19, 0.19, 0.03, Vector3(0, 0.215, 0), "pietra_n_chiara", Vector3.ZERO, 14))
	r.add_child(cilindro(0.14, 0.14, 0.005, Vector3(0, 0.205, 0), "acqua_pozzo", Vector3.ZERO, 14))
	for x: float in [-0.2, 0.2]:
		r.add_child(scatola(Vector3(0.035, 0.46, 0.035), Vector3(x, 0.23 + 0.03, 0), "legno_scuro"))
		r.add_child(scatola(Vector3(0.012, 0.1, 0.012), Vector3(x * 0.8, 0.42, 0), "legno_scuro", Vector3(0, 0, -45.0 * signf(x))))
	r.add_child(cilindro(0.025, 0.025, 0.4, Vector3(0, 0.36, 0), "legno", Vector3(0, 0, 90), 8))
	r.add_child(scatola(Vector3(0.012, 0.07, 0.012), Vector3(0.225, 0.33, 0.0), "ferro"))
	r.add_child(scatola(Vector3(0.012, 0.012, 0.05), Vector3(0.235, 0.3, 0.02), "ferro"))
	r.add_child(cilindro(0.028, 0.028, 0.06, Vector3(0, 0.36, 0), "corda", Vector3(0, 0, 90), 8))
	r.add_child(cilindro(0.003, 0.003, 0.1, Vector3(0, 0.3, 0.02), "corda", Vector3.ZERO, 4))
	r.add_child(cilindro(0.03, 0.026, 0.05, Vector3(0, 0.24, 0.02), "legno", Vector3.ZERO, 10))
	r.add_child(cilindro(0.031, 0.031, 0.008, Vector3(0, 0.255, 0.02), "ferro", Vector3.ZERO, 10))
	_tetto_n(r, 0.46, 0.26, 0.5, 52.0, 1701, "")
	# abbeveratoio di pietra e secchio
	r.add_child(scatola(Vector3(0.26, 0.07, 0.11), Vector3(0.06, 0.035, 0.33), "pietra_normanna"))
	r.add_child(scatola(Vector3(0.22, 0.004, 0.08), Vector3(0.06, 0.071, 0.33), "acqua_chiara"))
	r.add_child(barile(Vector3(-0.26, 0.0, 0.2), 0.8))
	r.scale = Vector3.ONE * 1.15
	return r


## Fattoria dei Normanni: casa di pietra col piano a graticcio, fienile aperto di pali col tetto ripido d'ardesia
## pieno di fieno, campi di grano chiusi dal graticcio, covoni, carretto e galline.
static func fattoria_normanni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.24)
	r.add_child(c)
	var lx := 0.74
	var lz := 0.54
	var top := _muri_n(c, lx, lz, 0.34, 1801, 0.5)
	_porta_n(c, Vector3(-0.12, 0.07, lz * 0.5), 0.0, 0.11, 0.12)
	_finestra_n(c, Vector3(0.18, 0.16, lz * 0.5), 0.0)
	_finestrella_n(c, Vector3(0.0, 0.32, lz * 0.5 + 0.03), 0.0, 0.06, 0.06)
	_finestrella_n(c, Vector3(lx * 0.5 + 0.03, 0.32, 0.0), 90.0, 0.06, 0.06)
	var cima := _tetto_n(c, lx + 0.06, lz + 0.04, top, 46.0, 1801, "graticcio_n")
	c.add_child(scatola(Vector3(0.08, 0.14, 0.08), Vector3(-0.22, cima - 0.05, -0.06), "pietra_normanna"))
	# fienile aperto sul lato destro
	var f := Node3D.new()
	f.position = Vector3(0.74, 0, -0.22)
	r.add_child(f)
	for p in [Vector3(-0.16, 0, -0.26), Vector3(0.16, 0, -0.26), Vector3(-0.16, 0, 0.26), Vector3(0.16, 0, 0.26)]:
		f.add_child(scatola(Vector3(0.03, 0.3, 0.03), p + Vector3(0, 0.15, 0), "legno_scuro"))
	for z: float in [-0.26, 0.26]:
		f.add_child(scatola(Vector3(0.36, 0.03, 0.03), Vector3(0, 0.3, z), "legno_scuro"))
	var fr := Node3D.new()
	fr.rotation_degrees.y = 90
	f.add_child(fr)
	_tetto_n(fr, 0.56, 0.32, 0.31, 50.0, 1802, "")
	for i in 6:
		f.add_child(sfera(0.075, Vector3(-0.08 + (i % 2) * 0.15, 0.06 + (i / 2) * 0.07, -0.18 + (i % 3) * 0.18), "paglia", Vector3(1.1, 0.7, 1.2)))
	# campi di grano nel graticcio
	_graticcio(r, Vector3(-0.8, 0, 0.3), Vector3(-0.08, 0, 0.3), 0.08)
	_graticcio(r, Vector3(-0.8, 0, 0.3), Vector3(-0.8, 0, 0.82), 0.08)
	for j in 3:
		r.add_child(scatola(Vector3(0.66, 0.012, 0.13), Vector3(-0.45, 0.006, 0.4 + j * 0.15), "terra"))
		for i in 7:
			r.add_child(cilindro(0.028, 0.02, 0.07, Vector3(-0.73 + i * 0.095, 0.04, 0.4 + j * 0.15), "grano" if j != 1 else "grano_verde", Vector3.ZERO, 6))
	carretto(r, Vector3(0.42, 0, 0.58), -20, "sacchi")
	for i in 3:
		var cv := covone(1.15)
		cv.position = Vector3(0.1 + i * 0.12, 0.0, 0.32 + (i % 2) * 0.06)
		r.add_child(cv)
	for i in 3:
		r.add_child(sfera(0.025, Vector3(0.05 + i * 0.07, 0.03, 0.55 - i * 0.03), "lino_bianco", Vector3(1.3, 1, 1)))
		r.add_child(sfera(0.008, Vector3(0.08 + i * 0.07, 0.05, 0.55 - i * 0.03), "geranio"))
	return r


## Mulino dei Normanni ad acqua: casa di macina di conci e graticcio col tetto d'ardesia, grande ruota verticale
## sul fianco destro mossa dall'acqua che arriva nella gora di legno, macine di scorta, sacchi, asino.
static func mulino_normanni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.26, 0, -0.25)
	r.add_child(c)
	var lx := 0.7
	var lz := 0.56
	var top := _muri_n(c, lx, lz, 0.44, 1901, 0.55)
	_porta_n(c, Vector3(-0.12, 0.07, lz * 0.5), 0.0, 0.12, 0.14)
	_finestra_n(c, Vector3(0.16, 0.2, lz * 0.5), 0.0)
	_finestrella_n(c, Vector3(0.05, 0.42, lz * 0.5 + 0.03), 0.0)
	_finestrella_n(c, Vector3(lx * 0.5 + 0.03, 0.42, -0.15), 90.0)
	_tetto_n(c, lx + 0.06, lz + 0.04, top, 47.0, 1901, "graticcio_n")
	# ruota verticale sul fianco destro, gora di legno che porta l'acqua in cima, canale sotto
	var rp := Vector3(lx * 0.5 + 0.11, 0.24, 0.05)
	_ruota_mulino(c, rp, 0.22)
	c.add_child(scatola(Vector3(0.12, 0.05, 0.5), Vector3(rp.x, 0.5, rp.z - 0.4), "legno_scuro"))
	c.add_child(scatola(Vector3(0.08, 0.008, 0.5), Vector3(rp.x, 0.526, rp.z - 0.4), "acqua_chiara"))
	for z: float in [-0.25, -0.55]:
		c.add_child(scatola(Vector3(0.03, 0.5, 0.03), Vector3(rp.x, 0.25, rp.z + z), "legno_scuro"))
	for k in 4:
		c.add_child(sfera(0.02, Vector3(rp.x + (k % 2 - 0.5) * 0.04, 0.47 - k * 0.04, rp.z - 0.17), "schiuma", Vector3(1, 0.6, 1)))
	c.add_child(scatola(Vector3(0.16, 0.01, 0.9), Vector3(rp.x, 0.005, rp.z + 0.2), "acqua_chiara"))
	for s: int in [-1, 1]:
		c.add_child(scatola(Vector3(0.03, 0.04, 0.9), Vector3(rp.x + s * 0.095, 0.02, rp.z + 0.2), "pietra_n_scura"))
	for k in 4:
		c.add_child(sfera(0.022, Vector3(rp.x + (k % 2 - 0.5) * 0.05, 0.02, rp.z + 0.08 + k * 0.05), "schiuma", Vector3(1, 0.5, 1)))
	# macine di scorta, sacchi, asino, covone
	r.add_child(cilindro(0.11, 0.11, 0.04, Vector3(-0.62, 0.11, 0.3), "pietra_n_chiara", Vector3(90, 30, 0), 18))
	r.add_child(cilindro(0.11, 0.11, 0.04, Vector3(-0.55, 0.11, 0.38), "pietra_normanna", Vector3(90, 30, 0), 18))
	for i in 5:
		r.add_child(sacco(Vector3(-0.42 + (i % 3) * 0.12, 0.0, 0.5 + (i / 3) * 0.13), i * 0.7))
	r.add_child(asino(Vector3(-0.02, 0, 0.58), 160))
	var cv := covone(1.1)
	cv.position = Vector3(-0.68, 0, 0.6)
	r.add_child(cv)
	r.add_child(cassa(Vector3(0.62, 0, 0.66), 15))
	return r


## Forno dei Normanni: bottega di conci col tetto d'ardesia, forno a cupola di pietra addossato al fianco
## con la bocca rossa e il fumo, tettoia sopra il banco dei pani, legnaia, sacchi di farina e ceste.
static func forno_normanni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.22, 0, -0.26)
	r.add_child(c)
	var lx := 0.72
	var lz := 0.54
	var top := _muri_n(c, lx, lz, 0.36, 2001)
	_porta_n(c, Vector3(-0.15, 0.07, lz * 0.5), 0.0, 0.12, 0.14, true)
	_finestra_n(c, Vector3(0.17, 0.25, lz * 0.5), 0.0)
	_tetto_n(c, lx + 0.06, lz, top, 46.0, 2001)
	# forno a cupola sul fianco destro
	var fp := Vector3(lx * 0.5 + 0.17, 0, 0.02)
	c.add_child(cilindro(0.21, 0.22, 0.12, fp + Vector3(0, 0.06, 0), "pietra_normanna", Vector3.ZERO, 16))
	c.add_child(sfera(0.2, fp + Vector3(0, 0.12, 0), "pietra_normanna", Vector3(1, 0.85, 1)))
	c.add_child(scatola(Vector3(0.12, 0.1, 0.06), fp + Vector3(0, 0.17, 0.18), "pietra_n_chiara"))
	c.add_child(cilindro(0.04, 0.04, 0.02, fp + Vector3(0, 0.18, 0.21), "brace", Vector3(90, 0, 0), 10))
	c.add_child(scatola(Vector3(0.08, 0.05, 0.02), fp + Vector3(0, 0.155, 0.212), "brace"))
	c.add_child(scatola(Vector3(0.07, 0.2, 0.07), fp + Vector3(-0.06, 0.35, -0.08), "pietra_normanna"))
	c.add_child(scatola(Vector3(0.08, 0.03, 0.08), fp + Vector3(-0.06, 0.46, -0.08), "fuliggine"))
	_fumo(c, fp + Vector3(-0.06, 0.5, -0.08), 4, 0.8)
	c.add_child(cilindro(0.008, 0.008, 0.3, fp + Vector3(0.14, 0.12, 0.2), "legno", Vector3(0, 0, -30), 5))
	c.add_child(scatola(Vector3(0.06, 0.006, 0.05), fp + Vector3(0.21, 0.24, 0.2), "legno_chiaro", Vector3(0, 0, -30)))
	legnaia(c, Vector3(fp.x + 0.02, 0, -0.33), 0.26, 3)
	# banco dei pani sotto la tettoia
	_tettoia_n(r, Vector3(-0.34, 0, 0.5), 0.46, 0.26, 0.36, 0.28)
	r.add_child(scatola(Vector3(0.36, 0.1, 0.12), Vector3(-0.34, 0.05, 0.53), "legno_scuro"))
	r.add_child(scatola(Vector3(0.38, 0.016, 0.14), Vector3(-0.34, 0.108, 0.53), "legno_chiaro"))
	for i in 5:
		r.add_child(sfera(0.032, Vector3(-0.46 + i * 0.06, 0.13, 0.53 + (i % 2) * 0.02), "pane", Vector3(1.3, 0.7, 0.9)))
	r.add_child(cesta(Vector3(-0.64, 0, 0.45), "pane"))
	r.add_child(cesta(Vector3(0.05, 0, 0.66), "pane"))
	r.add_child(sacco(Vector3(-0.7, 0, 0.15), 0.4))
	r.add_child(sacco(Vector3(-0.62, 0, 0.05), 1.4))
	r.add_child(barile(Vector3(0.18, 0, 0.45), 0.95))
	return r


## Ovile dei Normanni: stalla bassa di conci col tetto ripido d'ardesia, recinto di graticci con le pecore,
## rastrelliera del fieno, trogolo di legno, lana tosata.
static func ovile_normanni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.32, 0, -0.32)
	r.add_child(c)
	var lx := 0.6
	var lz := 0.46
	var top := _muri_n(c, lx, lz, 0.24, 2101)
	_porta_n(c, Vector3(0.1, 0.07, lz * 0.5), 0.0, 0.13, 0.1, true)
	_finestra_n(c, Vector3(-0.15, 0.18, lz * 0.5), 0.0, 0.04, 0.06)
	_tetto_n(c, lx + 0.06, lz, top, 50.0, 2101)
	var a := Vector3(0.1, 0, 0.1)
	_graticcio(r, a + Vector3(-0.34, 0, 0.45), a + Vector3(0.48, 0, 0.45))
	_graticcio(r, a + Vector3(0.48, 0, -0.22), a + Vector3(0.48, 0, 0.45))
	for p in [[Vector3(0.0, 0, 0.25), 30], [Vector3(0.2, 0, 0.05), 160], [Vector3(0.3, 0, 0.3), -40],
			[Vector3(-0.15, 0, 0.32), 90], [Vector3(0.32, 0, -0.12), 210]]:
		r.add_child(pecora(a + (p[0] as Vector3), p[1]))
	# rastrelliera del fieno e trogolo
	var rf := a + Vector3(-0.22, 0, 0.05)
	for s: int in [-1, 1]:
		r.add_child(scatola(Vector3(0.02, 0.16, 0.02), rf + Vector3(s * 0.12, 0.08, 0), "legno_scuro"))
	r.add_child(scatola(Vector3(0.26, 0.012, 0.012), rf + Vector3(0, 0.15, 0.03), "legno_scuro"))
	r.add_child(sfera(0.08, rf + Vector3(0, 0.13, 0), "paglia", Vector3(1.4, 0.6, 0.6)))
	r.add_child(scatola(Vector3(0.24, 0.05, 0.08), a + Vector3(-0.2, 0.025, 0.25), "legno_scuro"))
	r.add_child(scatola(Vector3(0.21, 0.004, 0.055), a + Vector3(-0.2, 0.051, 0.25), "acqua_chiara"))
	r.add_child(sfera(0.06, Vector3(-0.55, 0.04, 0.55), "lana", Vector3(1.2, 0.6, 1.0)))
	r.add_child(sfera(0.05, Vector3(-0.45, 0.035, 0.62), "lana", Vector3(1.2, 0.6, 1.0)))
	r.add_child(barile(Vector3(-0.7, 0, 0.3), 0.9))
	return r


## Capraio dei Normanni: casupola di conci col tetto d'ardesia, rocce grigie con le capre, muretto di pietre,
## cesta di formaggi e botte.
static func capraio_normanni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.3, 0, -0.3)
	r.add_child(c)
	var top := _muri_n(c, 0.48, 0.4, 0.24, 2201)
	_porta_n(c, Vector3(-0.08, 0.07, 0.2), 0.0, 0.1, 0.1)
	_finestra_n(c, Vector3(0.24, 0.17, 0.0), 90.0, 0.04, 0.06)
	_tetto_n(c, 0.52, 0.42, top, 50.0, 2201)
	var a := Vector3(0.15, 0, 0.15)
	r.add_child(sfera(0.16, a + Vector3(0.2, 0.0, -0.1), "roccia_massi", Vector3(1.2, 0.8, 1.0)))
	r.add_child(sfera(0.1, a + Vector3(-0.05, 0.0, 0.3), "roccia_massi", Vector3(1.3, 0.7, 1.0)))
	r.add_child(capra(a + Vector3(0.2, 0.1, -0.1), 40))
	r.add_child(capra(a + Vector3(0.0, 0, 0.1), 200))
	r.add_child(capra(a + Vector3(0.35, 0, 0.25), -30))
	r.add_child(capra(a + Vector3(-0.1, 0.05, 0.3), 110))
	var rng := _rng(2202)
	for k in 10:
		r.add_child(scatola(Vector3(0.09, 0.06, 0.06), a + Vector3(-0.4 + k * 0.095, 0.03, 0.5), "pietra_n_chiara" if k % 2 else "pietra_normanna", Vector3(0, rng.randf_range(-15, 15), 0)))
	r.add_child(barile(Vector3(-0.62, 0, 0.22), 1.0))
	r.add_child(cesta(Vector3(-0.52, 0, 0.36), "formaggio"))
	return r


## Caserma dei Normanni: sala di conci col tetto d'ardesia e la torre quadrata merlata con gli stendardi gialli,
## campo d'addestramento con la quintana (il fantoccio girevole con lo scudo), cavaliere che carica,
## rastrelliera di lance coi pennoncelli d'oro e scudi a mandorla.
static func caserma_normanni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.3, 0, -0.3)
	r.add_child(c)
	var lx := 0.62
	var lz := 0.48
	var top := _muri_n(c, lx, lz, 0.36, 2301)
	_porta_n(c, Vector3(0.08, 0.07, lz * 0.5), 0.0, 0.13, 0.15)
	_finestra_n(c, Vector3(lx * 0.5, 0.28, 0.05), 90.0)
	_finestra_n(c, Vector3(-0.15, 0.3, lz * 0.5), 0.0)
	var cima := _tetto_n(c, lx + 0.06, lz, top, 45.0, 2301)
	var tp := Vector3(-lx * 0.5 + 0.06, 0, -lz * 0.5 + 0.06)
	var ht := _torre_n(c, tp, 0.3, cima + 0.16)
	_stendardo_n(c, tp + Vector3(0.08, ht, 0.08), 0.42)
	c.add_child(_scudo_n(Vector3(0.08, 0.36, lz * 0.5 + 0.012), 0.0, 0.85))
	# campo d'addestramento con la quintana
	r.add_child(scatola(Vector3(0.78, 0.01, 0.58), Vector3(0.25, 0.005, 0.4), "terra"))
	var q := Vector3(0.52, 0, 0.3)
	r.add_child(cilindro(0.022, 0.026, 0.34, q + Vector3(0, 0.17, 0), "legno_scuro", Vector3.ZERO, 8))
	var braccio := Node3D.new()
	braccio.position = q + Vector3(0, 0.32, 0)
	braccio.rotation_degrees.y = 30
	r.add_child(braccio)
	braccio.add_child(scatola(Vector3(0.34, 0.022, 0.022), Vector3.ZERO, "legno_scuro"))
	braccio.add_child(_scudo_n(Vector3(-0.16, -0.06, 0.02), 0.0, 0.8))
	braccio.add_child(cilindro(0.003, 0.003, 0.08, Vector3(0.16, -0.04, 0), "corda", Vector3.ZERO, 4))
	braccio.add_child(sfera(0.035, Vector3(0.16, -0.1, 0), "lino", Vector3(0.9, 1.2, 0.9)))
	var cav := cavaliere_pesante()
	cav.position = Vector3(0.12, 0, 0.55)
	cav.rotation_degrees.y = 120
	cav.scale = Vector3.ONE * 0.9
	posa_carica(cav, 2, 8)
	r.add_child(cav)
	# rastrelliera di lance coi pennoncelli d'oro e scudi a mandorla
	var rs := Vector3(-0.62, 0, 0.42)
	r.add_child(scatola(Vector3(0.03, 0.03, 0.3), rs + Vector3(0, 0.2, 0), "legno_scuro"))
	for lato: int in [-1, 1]:
		r.add_child(scatola(Vector3(0.03, 0.22, 0.03), rs + Vector3(0, 0.11, lato * 0.14), "legno_scuro"))
	for k in 4:
		var z := -0.11 + k * 0.073
		r.add_child(cilindro(0.005, 0.005, 0.5, rs + Vector3(-0.02, 0.25, z), "legno", Vector3(0, 0, -8), 5))
		r.add_child(cilindro(0.01, 0.0, 0.04, rs + Vector3(-0.055, 0.52, z), "ferro", Vector3(0, 0, -8), 5))
		r.add_child(scatola(Vector3(0.004, 0.03, 0.05), rs + Vector3(-0.05, 0.45, z + 0.025), "stoffa_oro"))
	for k in 2:
		r.add_child(_scudo_n(Vector3(-0.48 + k * 0.12, 0.09, 0.64 - k * 0.03), 15.0 - k * 20.0, 1.0))
	return r


## Torre di guardia dei Normanni: torre quadrata di conci con lo zoccolo a scarpa, lesene, monofore,
## merli sulla cima e torretta d'angolo, scala di legno fino alla porta alta, stendardo giallo, palizzata alla base.
static func torre_normanni() -> Node3D:
	var r := Node3D.new()
	var lato := 0.55
	var h := 1.25
	r.add_child(scatola(Vector3(lato + 0.18, 0.06, lato + 0.18), Vector3(0, 0.03, 0), "pietra_n_scura"))
	var ht := _torre_n(r, Vector3(0, 0.06, 0), lato, h)
	var cima := 0.06 + ht
	# torretta d'angolo dietro a sinistra, più alta, con la cuspide d'ardesia
	var tt := Vector3(-lato * 0.5 + 0.09, cima, -lato * 0.5 + 0.09)
	r.add_child(scatola(Vector3(0.18, 0.22, 0.18), tt + Vector3(0, 0.11, 0), "pietra_normanna"))
	_finestra_n(r, tt + Vector3(0, 0.13, 0.09), 0.0, 0.03, 0.05)
	r.add_child(cilindro(0.13, 0.0, 0.26, tt + Vector3(0, 0.22 + 0.13, 0), "ardesia", Vector3(0, 45, 0), 4))
	_stendardo_n(r, Vector3(lato * 0.5 - 0.06, cima, lato * 0.5 - 0.06), 0.5)
	# porta alta e scala di legno addossata alla faccia in vista
	_porta_n(r, Vector3(-0.1, 0.42, lato * 0.5), 0.0, 0.11, 0.14)
	r.add_child(scatola(Vector3(0.18, 0.025, 0.1), Vector3(-0.1, 0.405, lato * 0.5 + 0.05), "legno_scuro"))
	var ns := 7
	for k in ns:
		var t := float(k) / ns
		r.add_child(scatola(Vector3(0.08, 0.02, 0.1), Vector3(0.18 - t * 0.24, 0.05 + t * 0.36, lato * 0.5 + 0.05), "legno"))
	var dl := sqrt(0.24 * 0.24 + 0.38 * 0.38)
	r.add_child(scatola(Vector3(dl, 0.03, 0.02), Vector3(0.06, 0.24, lato * 0.5 + 0.1), "legno_scuro", Vector3(0, 0, -rad_to_deg(atan2(0.38, 0.24)))))
	r.add_child(scatola(Vector3(0.025, 0.4, 0.025), Vector3(-0.02, 0.2, lato * 0.5 + 0.09), "legno_scuro"))
	# palizzata, botti, lance e scudo alla base
	_palizzata(r, Vector3(lato * 0.5 + 0.2, 0, -0.32), Vector3(lato * 0.5 + 0.2, 0, 0.05), 0.24)
	r.add_child(barile(Vector3(lato * 0.5 + 0.12, 0.0, 0.25), 1.1))
	r.add_child(cassa(Vector3(-lato * 0.5 - 0.02, 0.0, lato * 0.5 + 0.12), 10))
	for k in 3:
		r.add_child(cilindro(0.005, 0.005, 0.36, Vector3(0.3 + k * 0.035, 0.18, lato * 0.5 + 0.14), "legno", Vector3(-12, 0, 0), 5))
	r.add_child(_scudo_n(Vector3(lato * 0.5 + 0.05, 0.1, lato * 0.5 + 0.18), 30.0, 1.1))
	return r


## Castello dei Normanni (3x3): cinta di conci grigi merlata, torri quadrate agli angoli con le cuspidi d'ardesia,
## porta fra due torri con la saracinesca e il ponte di legno, sala grande col tetto ripido, mastio quadrato merlato,
## stendardi gialli, cortile con il pozzo, la stalla e le botti.
static func castello_normanni() -> Node3D:
	var r := Node3D.new()
	var lato := 2.3
	var h := 0.5
	r.add_child(scatola(Vector3(lato + 0.32, 0.06, lato + 0.32), Vector3(0, 0.03, 0), "pietra_n_scura"))
	r.add_child(scatola(Vector3(lato - 0.1, 0.008, lato - 0.1), Vector3(0, 0.064, 0), "terra"))
	var y0 := 0.06
	# cinta merlata con il camminamento e le feritoie
	for i in 4:
		var m := Node3D.new()
		m.rotation_degrees.y = i * 90
		r.add_child(m)
		m.add_child(scatola(Vector3(lato, h, 0.16), Vector3(0, y0 + h * 0.5, lato * 0.5), "pietra_normanna"))
		m.add_child(scatola(Vector3(lato + 0.01, 0.03, 0.2), Vector3(0, y0 + h - 0.015, lato * 0.5), "pietra_n_scura"))
		m.add_child(scatola(Vector3(lato + 0.01, 0.05, 0.19), Vector3(0, y0 + 0.025, lato * 0.5), "pietra_n_scura"))
		for k in 13:
			m.add_child(scatola(Vector3(0.09, 0.09, 0.06), Vector3(-lato * 0.5 + 0.12 + k * (lato - 0.24) / 12, y0 + h + 0.045, lato * 0.5 + 0.05), "pietra_normanna"))
		for k in 4:
			var x := -0.75 + k * 0.5
			if i == 0 and absf(x - 0.25) < 0.3:
				continue
			m.add_child(scatola(Vector3(0.022, 0.09, 0.02), Vector3(x, y0 + 0.3, lato * 0.5 + 0.082), "buio"))
	# torri quadrate agli angoli, le due dietro con la cuspide d'ardesia
	for x: float in [-1.0, 1.0]:
		for z: float in [-1.0, 1.0]:
			var p := Vector3(x * lato * 0.5, y0, z * lato * 0.5)
			var hh := _torre_n(r, p, 0.46, h + 0.38, z < 0.0)
			if z > 0.0:
				_stendardo_n(r, p + Vector3(0.12, hh, 0.12), 0.45)
	# porta fra due torri sul lato in vista
	var gx := 0.25
	var gz := lato * 0.5
	for k: int in [-1, 1]:
		var p := Vector3(gx + k * 0.3, y0, gz + 0.03)
		r.add_child(scatola(Vector3(0.26, h + 0.24, 0.3), p + Vector3(0, (h + 0.24) * 0.5, 0), "pietra_normanna"))
		r.add_child(scatola(Vector3(0.05, h + 0.12, 0.02), p + Vector3(k * 0.105, (h + 0.12) * 0.5 + 0.06, 0.15), "pietra_n_chiara"))
		_merli_n(r, p + Vector3(0, h + 0.24, 0), 0.27, 0.31, "pietra_normanna", 0.1)
		_finestra_n(r, p + Vector3(0, h * 0.75, 0.15), 0.0, 0.04, 0.07)
	r.add_child(scatola(Vector3(0.36, 0.2, 0.22), Vector3(gx, y0 + h + 0.04 - 0.1, gz + 0.03), "pietra_normanna"))
	_merli_n(r, Vector3(gx, y0 + h + 0.04, gz + 0.03), 0.34, 0.22, "pietra_normanna", 0.1)
	_porta_n(r, Vector3(gx, y0, gz + 0.15), 0.0, 0.22, 0.2, true)
	for k in 5:
		r.add_child(scatola(Vector3(0.008, 0.24, 0.008), Vector3(gx - 0.09 + k * 0.045, y0 + 0.2, gz + 0.165), "ferro"))
	for k in 3:
		r.add_child(scatola(Vector3(0.22, 0.008, 0.008), Vector3(gx, y0 + 0.14 + k * 0.08, gz + 0.165), "ferro"))
	r.add_child(scatola(Vector3(0.24, 0.025, 0.36), Vector3(gx, 0.04, gz + 0.36), "legno", Vector3(-6, 0, 0)))
	for k in 6:
		r.add_child(scatola(Vector3(0.24, 0.004, 0.012), Vector3(gx, 0.056 - k * 0.006, gz + 0.22 + k * 0.055), "legno_scuro", Vector3(-6, 0, 0)))
	_stendardo_n(r, Vector3(gx - 0.3, y0 + h + 0.24, gz + 0.03), 0.5)
	_stendardo_n(r, Vector3(gx + 0.3, y0 + h + 0.24, gz + 0.03), 0.5)
	# sala grande col tetto ripido d'ardesia (dietro a sinistra)
	var sl := Node3D.new()
	sl.position = Vector3(-0.42, y0 - 0.07, -0.25)
	r.add_child(sl)
	var ts := _muri_n(sl, 1.0, 0.6, 0.52, 2401)
	_porta_n(sl, Vector3(0.1, 0.07, 0.3), 0.0, 0.13, 0.15)
	for x: float in [-0.3, 0.3]:
		_finestra_n(sl, Vector3(x, 0.38, 0.3), 0.0, 0.06, 0.1)
	_finestra_n(sl, Vector3(0.5, 0.38, 0.0), 90.0, 0.06, 0.1)
	_tetto_n(sl, 1.06, 0.6, ts, 48.0, 2401)
	# mastio quadrato dietro a destra
	var mp := Vector3(0.45, y0, -0.55)
	var hm := _torre_n(r, mp, 0.62, 1.35)
	for k: int in [-1, 1]:
		_finestra_n(r, mp + Vector3(k * 0.12, 1.05, 0.31), 0.0, 0.05, 0.09)
		_finestra_n(r, mp + Vector3(0.31, 1.05, k * 0.12), 90.0, 0.05, 0.09)
	_stendardo_n(r, mp + Vector3(0.0, hm, 0.0), 0.6, 1.2)
	# cortile: pozzo, stalla con un cavallo, botti e casse
	r.add_child(cilindro(0.09, 0.1, 0.1, Vector3(0.6, y0 + 0.05, 0.05), "pietra_normanna", Vector3.ZERO, 12))
	r.add_child(cilindro(0.07, 0.07, 0.005, Vector3(0.6, y0 + 0.102, 0.05), "acqua_pozzo", Vector3.ZERO, 12))
	_tettoia_n(r, Vector3(-0.85, y0, 0.45), 0.5, 0.34, 0.36, 0.28, 90.0)
	var cv := _cavallo_n("cavallo_baio", 1.0)
	cv.position = Vector3(-0.72, y0, 0.45)
	cv.rotation_degrees.y = 180
	cv.scale = Vector3.ONE * 0.85
	r.add_child(cv)
	r.add_child(barile(Vector3(0.75, y0, 0.45), 1.1))
	r.add_child(barile(Vector3(0.86, y0, 0.38), 1.1))
	r.add_child(cassa(Vector3(0.7, y0, 0.6), 20))
	r.add_child(cassa(Vector3(-0.2, y0, 0.55), 5))
	return r


## Mastio dei Normanni (3x3, edificio unico): grande torre quadrata di conci (donjon) su una motta erbosa,
## lesene, cornici, bifore, merli, torrette d'angolo e cuspide d'ardesia, stendardi gialli; ingresso alto con la scala
## di legno coperta, cinta di palizzata con la porta di legno, scala giù per la motta, stalla e botti nel cortile.
static func mastio() -> Node3D:
	var r := Node3D.new()
	var rng := _rng(2501)
	var lato := 2.3
	var c := lato * 0.5
	var sm := 0.38
	r.add_child(scatola(Vector3(lato + 0.3, 0.05, lato + 0.3), Vector3(0, 0.025, 0), "terra"))
	r.add_child(scatola(Vector3(lato + 0.1, 0.008, lato + 0.1), Vector3(0, 0.054, 0), "prato"))
	# palizzata a ottagono (quadrato con gli angoli smussati), con la porta davanti
	var v := [Vector3(-c + sm, 0.05, c), Vector3(c - sm, 0.05, c), Vector3(c, 0.05, c - sm), Vector3(c, 0.05, -c + sm),
		Vector3(c - sm, 0.05, -c), Vector3(-c + sm, 0.05, -c), Vector3(-c, 0.05, -c + sm), Vector3(-c, 0.05, c - sm)]
	var gx := 0.3
	for i in 8:
		var da: Vector3 = v[i]
		var a: Vector3 = v[(i + 1) % 8]
		if i == 0:
			_palizzata(r, da, Vector3(gx - 0.3, 0.05, c), 0.32)
			_palizzata(r, Vector3(gx + 0.3, 0.05, c), a, 0.32)
		else:
			_palizzata(r, da, a, 0.32)
	for k in 4:
		var p: Vector3 = v[k * 2]
		r.add_child(scatola(Vector3(0.08, 0.5, 0.08), p + Vector3(0, 0.25, 0), "legno_scuro"))
	# porta di legno con il tettuccio d'ardesia e lo stendardo
	var gp := Node3D.new()
	gp.position = Vector3(gx, 0.05, c)
	r.add_child(gp)
	for s: float in [-1.0, 1.0]:
		gp.add_child(scatola(Vector3(0.07, 0.52, 0.07), Vector3(s * 0.29, 0.26, 0), "legno_scuro"))
	gp.add_child(scatola(Vector3(0.66, 0.05, 0.09), Vector3(0, 0.47, 0), "legno_scuro"))
	_tetto_n(gp, 0.68, 0.16, 0.5, 50.0, 2502, "")
	gp.add_child(scatola(Vector3(0.26, 0.36, 0.025), Vector3(-0.2, 0.18, 0.1), "legno", Vector3(0, 60, 0)))
	gp.add_child(scatola(Vector3(0.26, 0.36, 0.025), Vector3(0.2, 0.18, 0.1), "legno", Vector3(0, -60, 0)))
	_stendardo_n(gp, Vector3(0.29, 0.52, 0.04), 0.36, 0.9)
	_stendardo_n(gp, Vector3(-0.29, 0.52, 0.04), 0.36, 0.9)
	# motta erbosa con i sassi
	var hm := 0.45
	var mc := Vector3(-0.22, 0.05, -0.22)
	r.add_child(cilindro(0.72, 0.98, hm, mc + Vector3(0, hm * 0.5, 0), "prato", Vector3.ZERO, 20))
	r.add_child(cilindro(0.73, 0.73, 0.012, mc + Vector3(0, hm + 0.006, 0), "terra", Vector3.ZERO, 20))
	r.add_child(cilindro(0.99, 1.0, 0.03, mc + Vector3(0, 0.015, 0), "terra", Vector3.ZERO, 20))
	for k in 11:
		var a := k * TAU / 11 + 0.3
		var rr := rng.randf_range(0.78, 0.92)
		r.add_child(_masso(mc + Vector3(cos(a) * rr, hm * (0.98 - rr) / 0.26 * 0.9, sin(a) * rr), rng.randf_range(0.05, 0.09), Vector3(1.3, 1.0, 1.0), "roccia_massi", rng.randf() * 180))
	var top := mc + Vector3(0, hm, 0)
	_palizzata(r, top + Vector3(-0.62, 0, 0.3), top + Vector3(-0.55, 0, -0.42), 0.2)
	_palizzata(r, top + Vector3(-0.55, 0, -0.42), top + Vector3(0.3, 0, -0.64), 0.2)
	# donjon
	var ml := 0.9
	var mh := 1.6
	var d := top + Vector3(0.0, 0, -0.08)
	r.add_child(cilindro(ml * 0.8, ml * 0.73, 0.22, d + Vector3(0, 0.11, 0), "pietra_n_scura", Vector3(0, 45, 0), 4))
	r.add_child(scatola(Vector3(ml, mh, ml), d + Vector3(0, mh * 0.5, 0), "pietra_normanna"))
	for o: float in [-ml * 0.5 + 0.035, -ml / 6.0, ml / 6.0, ml * 0.5 - 0.035]:
		r.add_child(scatola(Vector3(0.07, mh - 0.22, 0.025), d + Vector3(o, 0.22 + (mh - 0.22) * 0.5, ml * 0.5 + 0.012), "pietra_n_chiara"))
		r.add_child(scatola(Vector3(0.025, mh - 0.22, 0.07), d + Vector3(ml * 0.5 + 0.012, 0.22 + (mh - 0.22) * 0.5, o), "pietra_n_chiara"))
	for yy: float in [0.6, 1.1, mh - 0.04]:
		r.add_child(scatola(Vector3(ml + 0.04, 0.035, ml + 0.04), d + Vector3(0, yy, 0), "pietra_n_scura"))
	# archetti pensili sotto il coronamento
	for k in 9:
		var o := -ml * 0.5 + 0.06 + k * (ml - 0.12) / 8
		r.add_child(cilindro(0.032, 0.032, 0.02, d + Vector3(o, mh - 0.1, ml * 0.5 + 0.008), "pietra_n_chiara", Vector3(90, 0, 0), 10))
		r.add_child(cilindro(0.032, 0.032, 0.02, d + Vector3(ml * 0.5 + 0.008, mh - 0.1, o), "pietra_n_chiara", Vector3(0, 0, 90), 10))
	# feritoie in basso, monofore al primo piano, bifore in alto
	for s: float in [-0.3, 0.3]:
		r.add_child(scatola(Vector3(0.022, 0.1, 0.02), d + Vector3(s, 0.36, ml * 0.5 + 0.004), "buio"))
		r.add_child(scatola(Vector3(0.02, 0.1, 0.022), d + Vector3(ml * 0.5 + 0.004, 0.36, s), "buio"))
		_finestra_n(r, d + Vector3(ml * 0.5, 0.84, s), 90.0, 0.05, 0.09)
	_finestra_n(r, d + Vector3(-0.3, 0.84, ml * 0.5), 0.0, 0.05, 0.09)
	for s: float in [-0.3, 0.3]:
		for b: float in [-0.035, 0.035]:
			_finestra_n(r, d + Vector3(s + b, 1.3, ml * 0.5), 0.0, 0.04, 0.1)
			_finestra_n(r, d + Vector3(ml * 0.5, 1.3, s + b), 90.0, 0.04, 0.1)
	# grandi drappi giallo oro con la croce rossa appesi al coronamento
	for f in 2:
		var dr := Node3D.new()
		dr.position = d + (Vector3(0, mh - 0.13, ml * 0.5 + 0.03) if f == 0 else Vector3(ml * 0.5 + 0.03, mh - 0.13, 0))
		dr.rotation_degrees.y = 0.0 if f == 0 else 90.0
		r.add_child(dr)
		dr.add_child(scatola(Vector3(0.18, 0.4, 0.008), Vector3(0, -0.2, 0), "stoffa_oro"))
		for z: float in [-0.045, 0.045]:
			dr.add_child(scatola(Vector3(0.08, 0.07, 0.008), Vector3(z, -0.43, 0), "stoffa_oro"))
		dr.add_child(scatola(Vector3(0.035, 0.3, 0.012), Vector3(0, -0.2, 0), "bandiera_rossa"))
		dr.add_child(scatola(Vector3(0.15, 0.035, 0.012), Vector3(0, -0.14, 0), "bandiera_rossa"))
		dr.add_child(scatola(Vector3(0.22, 0.02, 0.02), Vector3(0, 0.0, 0), "legno_scuro"))
	# coronamento merlato, torrette d'angolo, cuspide centrale
	var tc := d + Vector3(0, mh, 0)
	_merli_n(r, tc, ml + 0.04, ml + 0.04, "pietra_normanna", 0.11, 0.09)
	for x: float in [-1.0, 1.0]:
		for z: float in [-1.0, 1.0]:
			var p := tc + Vector3(x * (ml * 0.5 - 0.07), 0, z * (ml * 0.5 - 0.07))
			r.add_child(scatola(Vector3(0.19, 0.28, 0.19), p + Vector3(0, 0.14, 0), "pietra_normanna"))
			r.add_child(scatola(Vector3(0.02, 0.07, 0.02), p + Vector3(0, 0.15, 0.096), "buio"))
			_merli_n(r, p + Vector3(0, 0.28, 0), 0.2, 0.2, "pietra_normanna", 0.07, 0.06)
	r.add_child(scatola(Vector3(0.46, 0.18, 0.46), tc + Vector3(0, 0.09, 0), "pietra_normanna"))
	r.add_child(cilindro(0.34, 0.0, 0.5, tc + Vector3(0, 0.18 + 0.25, 0), "ardesia", Vector3(0, 45, 0), 4))
	_stendardo_n(r, tc + Vector3(0, 0.6, 0), 0.45, 1.5)
	_stendardo_n(r, tc + Vector3(ml * 0.5 - 0.07, 0.28, ml * 0.5 - 0.07), 0.36, 1.0)
	_stendardo_n(r, tc + Vector3(-ml * 0.5 + 0.07, 0.28, ml * 0.5 - 0.07), 0.36, 1.0)
	# ingresso al primo piano: pianerottolo di legno e scala ripida
	var ip := d + Vector3(0.2, 0, ml * 0.5)
	_porta_n(r, ip + Vector3(0, 0.6, 0), 0.0, 0.12, 0.15)
	r.add_child(scatola(Vector3(0.22, 0.03, 0.16), ip + Vector3(0, 0.58, 0.08), "legno_scuro"))
	for s: float in [-1.0, 1.0]:
		r.add_child(scatola(Vector3(0.025, 0.58, 0.025), ip + Vector3(s * 0.1, 0.29, 0.15), "legno_scuro"))
	var ns := 9
	for k in ns:
		var t := float(k) / ns
		r.add_child(scatola(Vector3(0.12, 0.022, 0.07), ip + Vector3(0.0, 0.03 + t * 0.55, 0.44 - t * 0.3), "legno"))
	var dl := sqrt(0.3 * 0.3 + 0.55 * 0.55)
	for s: float in [-1.0, 1.0]:
		r.add_child(scatola(Vector3(0.02, 0.03, dl), ip + Vector3(s * 0.065, 0.3, 0.29), "legno_scuro", Vector3(rad_to_deg(atan2(0.55, 0.3)), 0, 0)))
	# scala di tronchi giù per la motta, verso la porta
	for k in 7:
		var t := float(k) / 7
		r.add_child(cilindro(0.016, 0.016, 0.16, mc + Vector3(0.52 + t * 0.2, hm - t * hm * 0.95, 0.52 + t * 0.2), "corteccia", Vector3(0, 45, 90), 6))
	# cortile: stalla col tetto d'ardesia e un cavallo, botti, casse, fieno, cavaliere che rientra
	_tettoia_n(r, Vector3(0.85, 0.05, 0.42), 0.52, 0.32, 0.4, 0.3, 90.0)
	var cv := _cavallo_n("cavallo_baio", 1.0)
	cv.position = Vector3(0.82, 0.05, 0.42)
	cv.scale = Vector3.ONE * 0.8
	r.add_child(cv)
	r.add_child(sfera(0.12, Vector3(-0.75, 0.08, 0.7), "paglia", Vector3(1.2, 0.8, 1.0)))
	for i in 3:
		r.add_child(barile(Vector3(0.42 + i * 0.11, 0.05, 0.8 - i * 0.06), 1.1))
	r.add_child(cassa(Vector3(-0.3, 0.05, 0.88), 20))
	r.add_child(cassa(Vector3(-1.0, 0.05, 0.5), 5))
	var k1 := cavaliere_pesante()
	k1.position = Vector3(0.15, 0.05, 0.85)
	k1.rotation_degrees.y = 160
	k1.scale = Vector3.ONE * 0.9
	posa_galoppo(k1, 0, 8)
	r.add_child(k1)
	return r


## Allevamento di cavalli (edificio unico dei Normanni): scuderia lunga di conci e graticcio col tetto d'ardesia,
## mezze porte con i cavalli che si affacciano, recinto di staccionata con tre cavalli, abbeveratoio, fieno e sella.
static func allevamento_cavalli() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.28, 0, -0.38)
	r.add_child(c)
	var lx := 1.0
	var lz := 0.46
	var top := _muri_n(c, lx, lz, 0.34, 2601, 0.5)
	for k in 3:
		var x := -0.32 + k * 0.3
		c.add_child(scatola(Vector3(0.14, 0.17, 0.02), Vector3(x, 0.155, lz * 0.5 + 0.004), "buio"))
		c.add_child(scatola(Vector3(0.14, 0.08, 0.025), Vector3(x, 0.11, lz * 0.5 + 0.012), "legno_scuro"))
		c.add_child(scatola(Vector3(0.16, 0.02, 0.03), Vector3(x, 0.25, lz * 0.5 + 0.014), "legno_scuro"))
		var ts := Node3D.new()
		ts.position = Vector3(x, 0.17, lz * 0.5 + 0.04)
		c.add_child(ts)
		ts.add_child(sfera(0.04, Vector3(0, 0.02, 0.0), ["cavallo_baio", "cavallo", "crine"][k], Vector3(0.75, 0.85, 1.6)))
		ts.add_child(sfera(0.028, Vector3(0, -0.005, 0.05), "crine", Vector3(0.85, 0.85, 1.0)))
		for s: int in [-1, 1]:
			ts.add_child(cilindro(0.008, 0.002, 0.035, Vector3(s * 0.015, 0.06, -0.02), ["cavallo_baio", "cavallo", "crine"][k], Vector3(-15, 0, s * 12.0), 5))
	_finestrella_n(c, Vector3(lx * 0.5 + 0.03, 0.33, 0.0), 90.0)
	var cima := _tetto_n(c, lx + 0.06, lz + 0.04, top, 46.0, 2601, "graticcio_n")
	_stendardo_n(c, Vector3(lx * 0.5 - 0.02, cima - 0.06, 0.0), 0.36, 0.8)
	c.add_child(_scudo_n(Vector3(-0.47, 0.32, lz * 0.5 + 0.03), 0.0, 0.7))
	# tettoia del fieno sul fianco destro
	_tettoia_n(c, Vector3(lx * 0.5 + 0.14, 0, 0.0), 0.44, 0.28, 0.34, 0.26, 90.0, false)
	for i in 4:
		c.add_child(scatola(Vector3(0.12, 0.08, 0.16), Vector3(lx * 0.5 + 0.14, 0.04 + (i / 2) * 0.08, -0.1 + (i % 2) * 0.18), "paglia", Vector3(0, i * 7.0, 0)))
	# recinto di staccionata davanti con tre cavalli
	var a := Vector3(-0.78, 0, 0.12)
	var b := Vector3(0.78, 0, 0.88)
	for seg in [[Vector3(a.x, 0, a.z), Vector3(b.x, 0, a.z)], [Vector3(b.x, 0, a.z), Vector3(b.x, 0, b.z)],
			[Vector3(a.x, 0, b.z), Vector3(b.x, 0, b.z)], [Vector3(a.x, 0, a.z), Vector3(a.x, 0, b.z)]]:
		var da: Vector3 = seg[0]
		var fa: Vector3 = seg[1]
		var lung := da.distance_to(fa)
		var n := int(lung / 0.2) + 1
		for k in n + 1:
			r.add_child(scatola(Vector3(0.025, 0.14, 0.025), da.lerp(fa, float(k) / n) + Vector3(0, 0.07, 0), "legno_scuro"))
		var dir := (fa - da).normalized()
		var rot := rad_to_deg(atan2(dir.x, dir.z))
		for y: float in [0.06, 0.12]:
			r.add_child(scatola(Vector3(0.014, 0.018, lung), (da + fa) * 0.5 + Vector3(0, y, 0), "legno", Vector3(0, rot, 0)))
	for p in [[Vector3(-0.35, 0, 0.5), 70.0, "cavallo_baio"], [Vector3(0.15, 0, 0.62), -120.0, "cavallo"], [Vector3(0.45, 0, 0.35), 160.0, "crine"]]:
		var cv := _cavallo_n(p[2], 1.0)
		cv.position = p[0]
		cv.rotation_degrees.y = p[1]
		cv.scale = Vector3.ONE * 0.8
		r.add_child(cv)
	var pul := _cavallo_n("cavallo_baio", 0.9)
	pul.position = Vector3(-0.15, 0, 0.75)
	pul.rotation_degrees.y = 100
	pul.scale = Vector3.ONE * 0.5
	r.add_child(pul)
	# abbeveratoio di legno, mucchio di fieno, sella sulla staccionata, secchio
	r.add_child(scatola(Vector3(0.3, 0.06, 0.09), Vector3(-0.55, 0.03, 0.22), "legno_scuro"))
	r.add_child(scatola(Vector3(0.27, 0.004, 0.065), Vector3(-0.55, 0.061, 0.22), "acqua_chiara"))
	r.add_child(sfera(0.13, Vector3(0.6, 0.06, 0.2), "paglia", Vector3(1.0, 0.75, 1.0)))
	r.add_child(scatola(Vector3(0.08, 0.04, 0.1), Vector3(b.x, 0.15, 0.55), "pelle_scura"))
	r.add_child(scatola(Vector3(0.012, 0.08, 0.1), Vector3(b.x + 0.04, 0.11, 0.55), "stoffa_oro"))
	r.add_child(barile(Vector3(0.95, 0, 0.3), 0.8))
	return r


## Cavaliere pesante dei Normanni: destriero baio con la gualdrappa giallo oro, cavaliere in cotta di maglia con l'elmo
## a nasale, scudo a mandorla giallo con la croce rossa, lancia lunga col pennoncello d'oro.
static func cavaliere_pesante() -> Node3D:
	var r := _cavallo_n("cavallo_baio", 1.12)
	var corpo: Node3D = r.get_node("corpo")
	_gualdrappa_n(corpo, 1.12)
	var cav := portatore("", "oro_n", "maglia")
	cav.name = "cavaliere"
	cav.scale = Vector3.ONE * 0.85
	cav.position = Vector3(0, 0.44 - 0.2 * 0.85, -0.02)
	corpo.add_child(cav)
	var cc: Node3D = cav.get_node("corpo")
	var anca := 0.2
	var gs: Node3D = cc.get_node("gamba_s")
	var gd: Node3D = cc.get_node("gamba_d")
	gs.rotation = Vector3(-0.75, 0, -0.5)
	gd.rotation = Vector3(-0.75, 0, 0.5)
	for g: Node3D in [gs, gd]:
		g.add_child(cilindro(0.026, 0.022, 0.17, Vector3(0, -0.09, 0), "maglia", Vector3.ZERO, 7))
		g.add_child(scatola(Vector3(0.045, 0.025, 0.075), Vector3(0, -0.185, 0.015), "pelle_scura"))
	# usbergo lungo fino alle cosce, cintura d'oro, cappuccio di maglia ed elmo conico a nasale
	cc.add_child(cilindro(0.1, 0.11, 0.07, Vector3(0, anca - 0.02, 0), "maglia", Vector3.ZERO, 12))
	cc.add_child(sfera(0.082, Vector3(0, anca + 0.245, -0.004), "maglia", Vector3(1.0, 1.05, 1.0)))
	cc.add_child(sfera(0.05, Vector3(0, anca + 0.24, 0.04), "pelle", Vector3(1.1, 1.0, 0.9)))
	cc.add_child(cilindro(0.084, 0.0, 0.12, Vector3(0, anca + 0.34, -0.004), "ferro", Vector3.ZERO, 12))
	cc.add_child(cilindro(0.086, 0.086, 0.018, Vector3(0, anca + 0.285, -0.004), "oro_n", Vector3.ZERO, 12))
	cc.add_child(scatola(Vector3(0.014, 0.07, 0.01), Vector3(0, anca + 0.25, 0.088), "ferro"))
	for lato: String in ["braccio_s", "braccio_d"]:
		(cc.get_node(lato) as Node3D).add_child(cilindro(0.021, 0.018, 0.14, Vector3(0, -0.07, 0), "maglia", Vector3.ZERO, 7))
	# scudo a mandorla al braccio sinistro, rivolto verso l'esterno
	var bs: Node3D = cc.get_node("braccio_s")
	bs.add_child(_scudo_n(Vector3(-0.03, -0.1, 0.03), -90.0, 1.45))
	# lancia lunga col pennoncello d'oro a due code
	var bd: Node3D = cc.get_node("braccio_d")
	bd.add_child(cilindro(0.007, 0.007, 0.52, Vector3(0, -0.14, 0.13), "legno", Vector3(90, 0, 0), 5))
	bd.add_child(cilindro(0.014, 0.0, 0.05, Vector3(0, -0.14, 0.414), "ferro", Vector3(90, 0, 0), 6))
	bd.add_child(scatola(Vector3(0.004, 0.04, 0.06), Vector3(0, -0.118, 0.36), "stoffa_oro"))
	bd.add_child(scatola(Vector3(0.004, 0.016, 0.04), Vector3(0, -0.106, 0.31), "stoffa_oro"))
	bd.add_child(scatola(Vector3(0.004, 0.016, 0.04), Vector3(0, -0.13, 0.31), "bandiera_rossa"))
	r.set_meta("carico", "lancia")
	return r


# ------------------------------------------------------------------ altri edifici dei Normanni (step G6d)
# Stesso ingombro e stessa disposizione del corrispondente greco (stesso nome senza "_normanni").

## Comignolo di conci con la cappa scura e il fumo (pos = piede sul colmo o sulla falda).
static func _camino_n(c: Node3D, pos: Vector3, h := 0.16) -> void:
	c.add_child(scatola(Vector3(0.08, h, 0.08), pos + Vector3(0, h * 0.5, 0), "pietra_normanna"))
	c.add_child(scatola(Vector3(0.095, 0.025, 0.095), pos + Vector3(0, h, 0), "pietra_n_scura"))
	c.add_child(scatola(Vector3(0.05, 0.006, 0.05), pos + Vector3(0, h + 0.014, 0), "fuliggine"))
	_fumo(c, pos + Vector3(0, h + 0.05, 0), 3, 0.8)


## Muretto di pietre squadrate a secco fra due punti a terra (come i recinti dei Normanni).
static func _muretto_n(r: Node3D, da: Vector3, a: Vector3, h := 0.07) -> void:
	var nn := maxi(1, int(da.distance_to(a) / 0.09))
	var d := a - da
	var rot := rad_to_deg(atan2(-d.z, d.x))
	for k in nn:
		var p := da.lerp(a, (k + 0.5) / nn)
		r.add_child(scatola(Vector3(da.distance_to(a) / nn * 0.96, h, 0.05), p + Vector3(0, h * 0.5, 0), "pietra_normanna" if k % 2 == 0 else "pietra_n_chiara", Vector3(0, rot + (k % 3 - 1) * 2.0, 0)))
	r.add_child(scatola(Vector3(da.distance_to(a) + 0.02, 0.016, 0.06), (da + a) * 0.5 + Vector3(0, h + 0.008, 0), "pietra_n_scura", Vector3(0, rot, 0)))


## Cancello di assi scure con le bandelle di ferro fra due punti a terra.
static func _cancello_n(r: Node3D, da: Vector3, a: Vector3, h := 0.09) -> void:
	var d := a - da
	var rot := rad_to_deg(atan2(-d.z, d.x))
	var lung := Vector2(d.x, d.z).length()
	for s: float in [0.0, 1.0]:
		r.add_child(scatola(Vector3(0.025, h + 0.04, 0.025), da.lerp(a, s) + Vector3(0, (h + 0.04) * 0.5, 0), "legno_scuro"))
	r.add_child(scatola(Vector3(lung - 0.03, h, 0.012), (da + a) * 0.5 + Vector3(0, h * 0.5 + 0.01, 0), "legno_scuro", Vector3(0, rot, 0)))
	for yy: float in [h * 0.3, h * 0.8]:
		r.add_child(scatola(Vector3(lung - 0.04, 0.01, 0.016), (da + a) * 0.5 + Vector3(0, yy, 0), "ferro", Vector3(0, rot, 0)))


## Quercia piccola (per i Normanni al posto della palma dei Saraceni).
static func _quercia_n(r: Node3D, pos: Vector3, s := 0.5, seme := 1) -> void:
	var q := quercia(seme)
	q.position = pos
	q.scale = Vector3.ONE * s
	r.add_child(q)


## Guardia dei Normanni: cotta di maglia, elmo conico col nasale, scudo a mandorla e lancia col pennoncello d'oro.
static func _guardia_n(pos: Vector3, s := 0.9) -> Node3D:
	var g := portatore("", "giocatore", "ferro")
	g.position = pos
	g.scale = Vector3.ONE * s
	g.add_child(cilindro(0.08, 0.08, 0.04, Vector3(0, 0.48, -0.005), "ferro", Vector3.ZERO, 10))
	g.add_child(cilindro(0.08, 0.0, 0.09, Vector3(0, 0.545, -0.005), "ferro", Vector3.ZERO, 10))
	g.add_child(scatola(Vector3(0.014, 0.05, 0.01), Vector3(0, 0.45, 0.078), "ferro"))
	g.add_child(cilindro(0.088, 0.088, 0.012, Vector3(0, 0.3, 0), "stoffa_oro", Vector3.ZERO, 10))
	g.add_child(cilindro(0.006, 0.006, 0.55, Vector3(0.09, 0.27, 0.0), "legno_scuro", Vector3.ZERO, 5))
	g.add_child(cilindro(0.01, 0.0, 0.05, Vector3(0.09, 0.57, 0.0), "ferro", Vector3.ZERO, 5))
	g.add_child(scatola(Vector3(0.004, 0.03, 0.05), Vector3(0.09, 0.5, 0.025), "stoffa_oro"))
	g.add_child(_scudo_n(Vector3(-0.085, 0.28, 0.04), -20.0, 1.05))
	return g


## Porcile dei Normanni: stalla bassa di conci col tetto ripido d'ardesia, recinto di muretti di pietra
## col cancello di assi, truogolo di legno, maiali nel fango sotto la quercia delle ghiande.
static func porcile_normanni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.3, 0, -0.3)
	r.add_child(c)
	var lx := 0.6
	var lz := 0.46
	var top := _muri_n(c, lx, lz, 0.22, 3101)
	_porta_n(c, Vector3(-0.1, 0.07, lz * 0.5), 0.0, 0.12, 0.1, true)
	_finestra_n(c, Vector3(lx * 0.5, 0.2, 0.0), 90.0, 0.04, 0.06)
	_tetto_n(c, lx + 0.06, lz, top, 50.0, 3101)
	var a := Vector3(0.05, 0, 0.0)
	r.add_child(scatola(Vector3(0.8, 0.012, 0.75), a + Vector3(0.12, 0.006, 0.12), "terra"))
	_muretto_n(r, a + Vector3(-0.28, 0, 0.5), a + Vector3(0.28, 0, 0.5))
	_cancello_n(r, a + Vector3(0.3, 0, 0.5), a + Vector3(0.5, 0, 0.5))
	_muretto_n(r, a + Vector3(0.52, 0, -0.26), a + Vector3(0.52, 0, 0.5))
	_muretto_n(r, a + Vector3(0.15, 0, -0.26), a + Vector3(0.52, 0, -0.26))
	r.add_child(sfera(0.14, a + Vector3(0.28, 0.0, 0.05), "fuliggine", Vector3(1.4, 0.1, 1.0)))
	r.add_child(scatola(Vector3(0.24, 0.05, 0.07), a + Vector3(0.0, 0.025, 0.4), "legno_scuro"))
	r.add_child(scatola(Vector3(0.2, 0.012, 0.05), a + Vector3(0.0, 0.05, 0.4), "grano"))
	for p in [[Vector3(0.25, 0, 0.3), 20], [Vector3(0.38, 0, -0.05), 130], [Vector3(0.05, 0, 0.18), -60], [Vector3(0.4, 0, 0.32), 200]]:
		r.add_child(maiale(a + (p[0] as Vector3), p[1]))
	r.add_child(scatola(Vector3(0.16, 0.04, 0.06), a + Vector3(-0.15, 0.02, 0.1), "legno_scuro"))
	r.add_child(scatola(Vector3(0.13, 0.004, 0.04), a + Vector3(-0.15, 0.041, 0.1), "acqua_chiara"))
	r.add_child(sacco(Vector3(-0.62, 0, 0.3), 0.3))
	r.add_child(barile(Vector3(-0.5, 0, 0.4), 0.9))
	_quercia_n(r, Vector3(-0.7, 0, -0.1), 0.45, 3102)
	for k in 6:
		r.add_child(sfera(0.012, Vector3(-0.6 + k * 0.04, 0.008, 0.05 + (k % 2) * 0.05), "corteccia"))
	return r


## Macelleria dei Normanni: bottega di conci col piano a graticcio e il tetto d'ardesia, tettoia sul davanti
## con la carne appesa, bancone di legno scuro, ceppo, botte e scudo giallo sopra la porta.
static func macelleria_normanni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.25)
	r.add_child(c)
	var lx := 0.74
	var lz := 0.56
	var top := _muri_n(c, lx, lz, 0.38, 3111, 0.5)
	_porta_n(c, Vector3(0.16, 0.07, lz * 0.5), 0.0, 0.12, 0.13)
	_finestra_n(c, Vector3(-0.17, 0.17, lz * 0.5), 0.0)
	_finestra_n(c, Vector3(lx * 0.5, 0.17, 0.0), 90.0)
	_finestrella_n(c, Vector3(-0.15, 0.35, lz * 0.5 + 0.03), 0.0)
	_finestrella_n(c, Vector3(0.18, 0.35, lz * 0.5 + 0.03), 0.0)
	_finestrella_n(c, Vector3(lx * 0.5 + 0.03, 0.35, 0.0), 90.0)
	var cima := _tetto_n(c, lx + 0.06, lz + 0.04, top, 46.0, 3111, "graticcio_n")
	_camino_n(c, Vector3(0.24, cima - 0.12, -0.08))
	c.add_child(_scudo_n(Vector3(0.0, 0.2, lz * 0.5 + 0.012), 0.0, 0.7))
	_tettoia_n(r, Vector3(0.45, 0, 0.42), 0.6, 0.26, 0.42, 0.34)
	r.add_child(scatola(Vector3(0.56, 0.018, 0.018), Vector3(0.45, 0.3, 0.52), "legno_scuro"))
	for k in 5:
		var x := 0.25 + k * 0.1
		r.add_child(cilindro(0.003, 0.003, 0.05, Vector3(x, 0.275, 0.52), "corda", Vector3.ZERO, 3))
		if k % 2 == 0:
			r.add_child(sfera(0.035, Vector3(x, 0.215, 0.52), "carne", Vector3(0.9, 1.4, 0.8)))
		else:
			r.add_child(cilindro(0.016, 0.016, 0.1, Vector3(x, 0.205, 0.52), "carne", Vector3.ZERO, 8))
	var b := Vector3(-0.35, 0, 0.55)
	r.add_child(scatola(Vector3(0.3, 0.1, 0.13), b + Vector3(0, 0.05, 0), "legno_scuro"))
	r.add_child(scatola(Vector3(0.32, 0.018, 0.15), b + Vector3(0, 0.109, 0), "legno_chiaro"))
	r.add_child(sfera(0.04, b + Vector3(-0.05, 0.135, 0), "carne", Vector3(1.2, 0.5, 0.9)))
	r.add_child(scatola(Vector3(0.07, 0.004, 0.02), b + Vector3(0.08, 0.122, 0.02), "ferro", Vector3(0, 30, 0)))
	r.add_child(cilindro(0.07, 0.075, 0.1, Vector3(-0.65, 0.05, 0.4), "corteccia", Vector3.ZERO, 12))
	r.add_child(barile(Vector3(0.65, 0, 0.0), 1.1))
	r.add_child(barile(Vector3(0.68, 0, 0.16), 0.9))
	r.add_child(maiale(Vector3(-0.6, 0, 0.0), 60))
	return r


## Bugno di paglia intrecciata a campana (arnia dei paesi del nord), sul piede in pos.
static func _bugno_n(r: Node3D, pos: Vector3, s := 1.0) -> void:
	r.add_child(sfera(0.05 * s, pos + Vector3(0, 0.035 * s, 0), "paglia", Vector3(1, 1.25, 1)))
	for k in 3:
		r.add_child(_toro(0.042 * s - k * 0.01 * s, 0.05 * s - k * 0.01 * s, pos + Vector3(0, (0.02 + k * 0.025) * s, 0), "paglia_scura", Vector3.ZERO, Vector3(1, 0.5, 1)))
	r.add_child(scatola(Vector3(0.02, 0.012, 0.01) * s, pos + Vector3(0, 0.008 * s, 0.048 * s), "buio"))


## Apiario dei Normanni: casetta di conci col tetto d'ardesia, bugni di paglia in fila su due panche
## di legno scuro, fiori tutto intorno, quercia, botticelle di miele.
static func apiario_normanni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.35, 0, -0.35)
	r.add_child(c)
	var lx := 0.5
	var lz := 0.4
	var top := _muri_n(c, lx, lz, 0.22, 3121)
	_porta_n(c, Vector3(0.06, 0.07, lz * 0.5), 0.0, 0.1, 0.1)
	_finestra_n(c, Vector3(lx * 0.5, 0.2, 0.0), 90.0, 0.04, 0.06)
	_tetto_n(c, lx + 0.06, lz, top, 50.0, 3121)
	for f in 2:
		var z := 0.15 + f * 0.25
		r.add_child(scatola(Vector3(0.75, 0.018, 0.1), Vector3(0.15, 0.06, z), "legno_scuro"))
		for x: float in [-0.18, 0.15, 0.48]:
			r.add_child(scatola(Vector3(0.025, 0.06, 0.06), Vector3(x, 0.03, z), "legno_scuro"))
		for k in 5:
			_bugno_n(r, Vector3(-0.15 + k * 0.15, 0.069, z))
	var rng := _rng(3122)
	for k in 30:
		var p := Vector3(rng.randf_range(-0.7, 0.7), 0.0, rng.randf_range(0.55, 0.75))
		if k % 2 == 0:
			p = Vector3(rng.randf_range(0.5, 0.75), 0.0, rng.randf_range(-0.3, 0.6))
		r.add_child(sfera(0.018, p + Vector3(0, 0.02, 0), "orto"))
		r.add_child(sfera(0.012, p + Vector3(0, 0.04, 0), ["fiore", "geranio", "miele"][k % 3]))
	_quercia_n(r, Vector3(0.55, 0, -0.42), 0.45, 3123)
	r.add_child(barile(Vector3(-0.62, 0, 0.2), 0.8))
	r.add_child(barile(Vector3(-0.55, 0, 0.32), 0.7))
	return r


## Caseificio dei Normanni: bottega di conci col piano a graticcio e il comignolo, paiolo sul fuoco,
## scaffali di formaggi sotto la tettoia d'ardesia, botti di latte.
static func caseificio_normanni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.25)
	r.add_child(c)
	var lx := 0.74
	var lz := 0.56
	var top := _muri_n(c, lx, lz, 0.38, 3131, 0.5)
	_porta_n(c, Vector3(-0.15, 0.07, lz * 0.5), 0.0, 0.12, 0.13)
	_finestra_n(c, Vector3(0.18, 0.17, lz * 0.5), 0.0)
	_finestra_n(c, Vector3(lx * 0.5, 0.17, 0.0), 90.0)
	_finestrella_n(c, Vector3(-0.15, 0.35, lz * 0.5 + 0.03), 0.0)
	_finestrella_n(c, Vector3(0.18, 0.35, lz * 0.5 + 0.03), 0.0)
	var cima := _tetto_n(c, lx + 0.06, lz + 0.04, top, 46.0, 3131, "graticcio_n")
	_camino_n(c, Vector3(-0.22, cima - 0.12, -0.08))
	var f := Vector3(0.45, 0, 0.45)
	for k in 6:
		r.add_child(scatola(Vector3(0.07, 0.05, 0.05), f + Vector3(0.12 * cos(k), 0.025, 0.12 * sin(k)), "pietra_n_scura", Vector3(0, k * 50, 0)))
	r.add_child(sfera(0.1, f + Vector3(0, 0.12, 0), "bronzo", Vector3(1, 0.8, 1)))
	r.add_child(cilindro(0.085, 0.085, 0.01, f + Vector3(0, 0.17, 0), "latte", Vector3.ZERO, 14))
	for lato: int in [-1, 1]:
		r.add_child(cilindro(0.01, 0.01, 0.3, f + Vector3(lato * 0.15, 0.15, 0), "legno_scuro", Vector3.ZERO, 5))
	r.add_child(cilindro(0.008, 0.008, 0.32, f + Vector3(0, 0.3, 0), "legno_scuro", Vector3(0, 0, 90), 5))
	_fumo(r, f + Vector3(0, 0.24, 0), 2, 0.6)
	_tettoia_n(r, Vector3(-0.3, 0, 0.5), 0.4, 0.2, 0.38, 0.32)
	for p: Vector3 in [Vector3(-0.3, 0, 0.5), Vector3(0.7, 0, -0.05)]:
		for liv in 3:
			r.add_child(scatola(Vector3(0.28 if p.x < 0 else 0.08, 0.012, 0.08 if p.x < 0 else 0.28), p + Vector3(0, 0.05 + liv * 0.08, 0), "legno_scuro"))
			for k in 3:
				var o := Vector3((k - 1) * 0.085, 0, 0) if p.x < 0 else Vector3(0, 0, (k - 1) * 0.085)
				r.add_child(cilindro(0.035, 0.035, 0.04, p + o + Vector3(0, 0.078 + liv * 0.08, 0), "formaggio", Vector3.ZERO, 12))
	r.add_child(barile(Vector3(0.1, 0, 0.62), 0.9))
	r.add_child(barile(Vector3(0.22, 0, 0.6), 1.0))
	return r


## Argillaio dei Normanni: casotto di conci col tetto d'ardesia, mattoni che seccano sui travetti,
## fossa d'argilla, stampo di legno, pala, botte d'acqua.
static func argillaio_normanni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.32, 0, -0.32)
	r.add_child(c)
	var top := _muri_n(c, 0.46, 0.36, 0.2, 3141)
	_porta_n(c, Vector3(0.06, 0.07, 0.18), 0.0, 0.1, 0.09, true)
	_tetto_n(c, 0.5, 0.38, top, 50.0, 3141)
	for x: float in [-0.6, -0.23]:
		r.add_child(scatola(Vector3(0.025, 0.03, 0.14), Vector3(x, 0.015, 0.45), "legno_scuro"))
	r.add_child(sfera(0.3, Vector3(0.3, -0.02, 0.25), "argilla", Vector3(1.3, 0.12, 1.0)))
	r.add_child(sfera(0.22, Vector3(0.3, 0.0, 0.25), "argilla_cruda", Vector3(1.3, 0.08, 1.0)))
	for k in 12:
		r.add_child(scatola(Vector3(0.07, 0.03, 0.04), Vector3(-0.55 + (k % 4) * 0.09, 0.045 + (k / 4) * 0.032, 0.45), "argilla" if k % 3 else "argilla_cruda", Vector3(0, (k % 2) * 5, 0)))
	r.add_child(scatola(Vector3(0.1, 0.02, 0.06), Vector3(-0.12, 0.01, 0.6), "legno_scuro"))
	r.add_child(scatola(Vector3(0.07, 0.006, 0.04), Vector3(-0.12, 0.023, 0.6), "buio"))
	var a := attrezzo("pala")
	a.position = Vector3(0.62, 0.02, 0.05)
	a.rotation_degrees = Vector3(0, 40, 10)
	r.add_child(a)
	r.add_child(barile(Vector3(0.02, 0, 0.62), 1.0))
	return r


## Fornace dei Normanni: bottega di conci col tetto d'ardesia, fornace a cupola di pietra con la bocca accesa
## e il camino, vasi e ciotole in fila, argilla e legna.
static func fornace_normanni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.25, 0, -0.3)
	r.add_child(c)
	var lx := 0.6
	var lz := 0.46
	var top := _muri_n(c, lx, lz, 0.28, 3151)
	_porta_n(c, Vector3(0.12, 0.07, lz * 0.5), 0.0, 0.11, 0.12)
	_finestra_n(c, Vector3(-0.14, 0.24, lz * 0.5), 0.0)
	_finestra_n(c, Vector3(lx * 0.5, 0.24, 0.0), 90.0)
	_tetto_n(c, lx + 0.06, lz, top, 48.0, 3151)
	var f := Vector3(0.42, 0, 0.35)
	r.add_child(cilindro(0.2, 0.22, 0.14, f + Vector3(0, 0.07, 0), "pietra_normanna", Vector3.ZERO, 18))
	r.add_child(sfera(0.2, f + Vector3(0, 0.14, 0), "pietra_normanna", Vector3(1, 1.0, 1)))
	r.add_child(cilindro(0.205, 0.205, 0.02, f + Vector3(0, 0.15, 0), "pietra_n_scura", Vector3.ZERO, 18))
	r.add_child(cilindro(0.04, 0.05, 0.06, f + Vector3(0, 0.35, 0), "pietra_n_scura", Vector3.ZERO, 10))
	r.add_child(scatola(Vector3(0.1, 0.09, 0.06), f + Vector3(-0.05, 0.1, 0.18), "pietra_n_chiara", Vector3(0, 25, 0)))
	r.add_child(scatola(Vector3(0.07, 0.06, 0.05), f + Vector3(-0.055, 0.1, 0.195), "brace", Vector3(0, 25, 0)))
	_fumo(r, f + Vector3(0, 0.4, 0), 3, 1.0)
	for k in 7:
		var p := Vector3(-0.6 + (k % 4) * 0.1, 0, 0.42 + (k / 4) * 0.12)
		if k % 3 == 1:
			r.add_child(cilindro(0.03, 0.045, 0.04, p + Vector3(0, 0.02, 0), "argilla", Vector3.ZERO, 12))
			r.add_child(cilindro(0.036, 0.036, 0.004, p + Vector3(0, 0.041, 0), "argilla_cruda", Vector3.ZERO, 12))
		else:
			r.add_child(anfora(p, 1.2))
	r.add_child(mucchio(Vector3(0.68, 0, -0.15), "argilla", 8, 9))
	legnaia(r, Vector3(0.65, 0, 0.12), 0.2, 3)
	return r


## Saline dei Normanni: vasche di evaporazione bordate di pietra squadrata, canaletta, cumuli di sale,
## casotto di conci col tetto d'ardesia, pala, sacco e botte.
static func saline_normanni() -> Node3D:
	var r := Node3D.new()
	for i in 3:
		for j in 2:
			var p := Vector3(-0.45 + i * 0.42, 0, -0.25 + j * 0.5)
			r.add_child(scatola(Vector3(0.4, 0.04, 0.46), p + Vector3(0, 0.02, 0), "pietra_n_scura"))
			var mat := "acqua_chiara" if (i + j) % 3 != 0 else "sale"
			r.add_child(scatola(Vector3(0.34, 0.005, 0.4), p + Vector3(0, 0.042, 0), mat))
			r.add_child(scatola(Vector3(0.05, 0.008, 0.04), p + Vector3(0, 0.04, -0.21), "acqua_chiara"))
	_canaletta(r, Vector3(-0.68, 0, -0.53), Vector3(0.42, 0, -0.53), 0.03)
	for p: Vector3 in [Vector3(0.62, 0, 0.55), Vector3(0.42, 0, 0.62), Vector3(-0.6, 0, 0.6)]:
		r.add_child(sfera(0.1, p, "sale", Vector3(1, 0.9, 1)))
	var c := Node3D.new()
	c.position = Vector3(0.6, 0, -0.55)
	r.add_child(c)
	var top := _muri_n(c, 0.28, 0.24, 0.12, 3161)
	_porta_n(c, Vector3(-0.04, 0.07, 0.12), 0.0, 0.07, 0.05)
	_tetto_n(c, 0.32, 0.26, top, 52.0, 3161)
	var a := attrezzo("pala")
	a.position = Vector3(0.25, 0.02, 0.45)
	a.rotation_degrees = Vector3(0, -30, 5)
	r.add_child(a)
	r.add_child(sacco(Vector3(0.0, 0, 0.62), 0.3))
	r.add_child(barile(Vector3(0.3, 0, -0.72), 0.8))
	return r


## Tessitura dei Normanni: bottega di conci col piano a graticcio, telaio con la tela a bande d'oro, rosse e bianche,
## matasse di lana, drappi gialli con la croce rossa stesi su una pertica.
static func tessitura_normanni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.28)
	r.add_child(c)
	var lx := 0.72
	var lz := 0.52
	var top := _muri_n(c, lx, lz, 0.36, 3171, 0.5)
	_porta_n(c, Vector3(-0.16, 0.07, lz * 0.5), 0.0, 0.12, 0.12)
	_finestra_n(c, Vector3(0.18, 0.17, lz * 0.5), 0.0)
	_finestra_n(c, Vector3(lx * 0.5, 0.17, 0.0), 90.0)
	_finestrella_n(c, Vector3(-0.14, 0.33, lz * 0.5 + 0.03), 0.0)
	_finestrella_n(c, Vector3(0.18, 0.33, lz * 0.5 + 0.03), 0.0)
	_finestrella_n(c, Vector3(lx * 0.5 + 0.03, 0.33, 0.0), 90.0)
	_tetto_n(c, lx + 0.06, lz + 0.04, top, 46.0, 3171, "graticcio_n")
	var t := Vector3(0.0, 0, 0.5)
	for x: float in [-0.18, 0.18]:
		r.add_child(cilindro(0.012, 0.012, 0.4, t + Vector3(x, 0.2, 0), "legno_scuro", Vector3.ZERO, 6))
	r.add_child(cilindro(0.012, 0.012, 0.4, t + Vector3(0, 0.39, 0), "legno_scuro", Vector3(0, 0, 90), 6))
	var fili := ["stoffa_oro", "bandiera_rossa", "lino_bianco", "stoffa_oro", "bandiera_rossa", "lino"]
	for k in 6:
		r.add_child(scatola(Vector3(0.34, 0.04, 0.006), t + Vector3(0, 0.34 - k * 0.04, 0), fili[k]))
	for k in 5:
		r.add_child(sfera(0.014, t + Vector3(-0.14 + k * 0.07, 0.08, 0), "argilla"))
	var colori := ["lana", "stoffa_oro", "bandiera_rossa"]
	for i in 3:
		var p := Vector3(0.55 + (i % 2) * 0.06, 0, 0.0 + i * 0.1)
		r.add_child(sfera(0.045, p + Vector3(0, 0.035, 0), colori[i], Vector3(1.2, 0.8, 1)))
	for x: float in [0.36, 0.86]:
		r.add_child(cilindro(0.009, 0.009, 0.36, Vector3(x, 0.18, -0.35), "legno_scuro", Vector3.ZERO, 5))
	r.add_child(cilindro(0.008, 0.008, 0.54, Vector3(0.61, 0.36, -0.35), "legno_scuro", Vector3(0, 0, 90), 5))
	for k in 2:
		var x := 0.49 + k * 0.24
		r.add_child(scatola(Vector3(0.2, 0.24, 0.006), Vector3(x, 0.24, -0.345), "stoffa_oro" if k == 0 else "lino_bianco"))
		r.add_child(scatola(Vector3(0.035, 0.242, 0.008), Vector3(x, 0.24, -0.345), "bandiera_rossa"))
		r.add_child(scatola(Vector3(0.202, 0.035, 0.008), Vector3(x, 0.28, -0.345), "bandiera_rossa"))
	return r


## Pescatore dei Normanni: casetta di conci col piano a graticcio e il tetto d'ardesia, reti stese su pali,
## barca di legno scuro con la fascia d'oro tirata a secco, ceste di pesce, botte e quercia.
static func capanna_pescatore_normanni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.22, 0, -0.25)
	r.add_child(c)
	var lx := 0.66
	var lz := 0.5
	var top := _muri_n(c, lx, lz, 0.32, 3181, 0.5)
	_porta_n(c, Vector3(0.12, 0.07, lz * 0.5), 0.0, 0.11, 0.11)
	_finestra_n(c, Vector3(-0.16, 0.16, lz * 0.5), 0.0, 0.045, 0.07)
	_finestrella_n(c, Vector3(-0.12, 0.31, lz * 0.5 + 0.03), 0.0)
	_finestrella_n(c, Vector3(lx * 0.5 + 0.03, 0.31, 0.0), 90.0)
	_tetto_n(c, lx + 0.06, lz + 0.04, top, 46.0, 3181, "graticcio_n")
	for x: float in [0.35, 0.75]:
		r.add_child(cilindro(0.012, 0.012, 0.36, Vector3(x, 0.18, -0.35), "legno_scuro", Vector3.ZERO, 6))
	r.add_child(scatola(Vector3(0.4, 0.26, 0.006), Vector3(0.55, 0.2, -0.35), "rete"))
	for k in 6:
		r.add_child(scatola(Vector3(0.004, 0.26, 0.008), Vector3(0.37 + k * 0.07, 0.2, -0.345), "corda"))
	for k in 4:
		r.add_child(scatola(Vector3(0.4, 0.004, 0.008), Vector3(0.55, 0.1 + k * 0.065, -0.345), "corda"))
	var b := Node3D.new()
	b.position = Vector3(0.35, 0, 0.45)
	b.rotation_degrees.y = -25
	r.add_child(b)
	b.add_child(sfera(0.13, Vector3(0, 0.07, 0), "legno_scuro", Vector3(2.6, 0.7, 1.0)))
	b.add_child(sfera(0.115, Vector3(0, 0.1, 0), "legno_vecchio", Vector3(2.5, 0.35, 0.9)))
	b.add_child(scatola(Vector3(0.66, 0.02, 0.03), Vector3(0, 0.13, 0.12), "stoffa_oro"))
	b.add_child(scatola(Vector3(0.66, 0.02, 0.03), Vector3(0, 0.13, -0.12), "stoffa_oro"))
	for z: float in [-0.05, 0.06]:
		b.add_child(scatola(Vector3(0.5, 0.01, 0.025), Vector3(0.05, 0.16, z), "legno_chiaro", Vector3(0, 8, 4)))
	r.add_child(cesta(Vector3(-0.45, 0, 0.45), "pesce"))
	r.add_child(cesta(Vector3(-0.3, 0, 0.58), "pesce"))
	r.add_child(barile(Vector3(-0.62, 0, 0.25), 1.0))
	_quercia_n(r, Vector3(-0.66, 0, -0.05), 0.42, 3182)
	return r


## Frantoio dei Normanni: grande bottega di conci col tetto d'ardesia e il comignolo, macina di pietra all'aperto
## nella vasca di conci, giare e botti d'olio, fiscoli, ulivo e scudo giallo sulla porta.
static func frantoio_normanni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.22)
	r.add_child(c)
	var lx := 0.82
	var lz := 0.62
	var top := _muri_n(c, lx, lz, 0.38, 3191)
	_porta_n(c, Vector3(0.18, 0.07, lz * 0.5), 0.0, 0.15, 0.16, true)
	_finestra_n(c, Vector3(-0.18, 0.3, lz * 0.5), 0.0)
	_finestra_n(c, Vector3(lx * 0.5, 0.3, 0.12), 90.0)
	_finestra_n(c, Vector3(lx * 0.5, 0.3, -0.14), 90.0)
	var cima := _tetto_n(c, lx + 0.06, lz, top, 44.0, 3191)
	_camino_n(c, Vector3(-0.26, cima - 0.14, -0.1))
	c.add_child(_scudo_n(Vector3(0.18, 0.4, lz * 0.5 + 0.012), 0.0, 0.7))
	var m := Vector3(-0.35, 0, 0.55)
	r.add_child(cilindro(0.26, 0.28, 0.1, m + Vector3(0, 0.05, 0), "pietra_normanna", Vector3.ZERO, 24))
	r.add_child(cilindro(0.27, 0.27, 0.012, m + Vector3(0, 0.104, 0), "pietra_n_scura", Vector3.ZERO, 24))
	r.add_child(cilindro(0.21, 0.21, 0.01, m + Vector3(0, 0.106, 0), "foglie_ulivo", Vector3.ZERO, 24))
	r.add_child(cilindro(0.03, 0.03, 0.22, m + Vector3(0, 0.2, 0), "legno_scuro", Vector3.ZERO, 8))
	r.add_child(cilindro(0.12, 0.12, 0.08, m + Vector3(0.1, 0.22, 0), "blocco", Vector3(0, 0, 90), 18))
	r.add_child(scatola(Vector3(0.6, 0.03, 0.03), m + Vector3(0.2, 0.26, 0), "legno_scuro"))
	for i in 6:
		var p := Vector3(0.25 + (i % 3) * 0.1, 0.0, 0.42 + (i / 3) * 0.11)
		if i % 2 == 0:
			r.add_child(barile(p, 0.85))
		else:
			r.add_child(anfora(p, 1.15))
	for i in 3:
		r.add_child(cilindro(0.06, 0.05, 0.06, Vector3(0.62, 0.03, -0.3 + i * 0.16), "paglia", Vector3.ZERO, 12))
		r.add_child(sfera(0.05, Vector3(0.62, 0.06, -0.3 + i * 0.16), "foglie_ulivo", Vector3(1, 0.4, 1)))
	r.add_child(barile(Vector3(0.62, 0.0, 0.25), 1.3))
	var u := ulivo(3192)
	u.position = Vector3(-0.7, 0, -0.45)
	u.scale = Vector3.ONE * 0.8
	r.add_child(u)
	return r


## Uliveto dei Normanni: casetta di conci col tetto d'ardesia, teli stesi sotto l'ulivo, ceste di olive,
## scala a pioli, botte e muretto di pietra.
static func uliveto_normanni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.3, 0, -0.3)
	r.add_child(c)
	var lx := 0.58
	var lz := 0.46
	var top := _muri_n(c, lx, lz, 0.24, 3201)
	_porta_n(c, Vector3(-0.08, 0.07, lz * 0.5), 0.0, 0.11, 0.11)
	_finestra_n(c, Vector3(lx * 0.5, 0.22, 0.0), 90.0, 0.045, 0.065)
	_tetto_n(c, lx + 0.06, lz, top, 50.0, 3201)
	var u := ulivo(3202)
	u.position = Vector3(0.35, 0, 0.3)
	u.scale = Vector3.ONE * 0.8
	r.add_child(u)
	r.add_child(scatola(Vector3(0.5, 0.004, 0.45), Vector3(0.35, 0.004, 0.3), "lino", Vector3(0, 12, 0)))
	for k in 12:
		r.add_child(sfera(0.012, Vector3(0.2 + (k % 4) * 0.08, 0.012, 0.18 + (k / 4) * 0.1), "oliva"))
	_muretto_n(r, Vector3(0.72, 0, -0.3), Vector3(0.72, 0, 0.5), 0.06)
	for p: Vector3 in [Vector3(-0.45, 0, 0.45), Vector3(-0.25, 0, 0.55), Vector3(0.58, 0, -0.2)]:
		r.add_child(cesta(p, "olive"))
	r.add_child(scatola(Vector3(0.03, 0.45, 0.012), Vector3(0.12, 0.22, 0.12), "legno_scuro", Vector3(0, 0, -18)))
	r.add_child(scatola(Vector3(0.03, 0.45, 0.012), Vector3(0.12, 0.22, 0.2), "legno_scuro", Vector3(0, 0, -18)))
	for k in 5:
		r.add_child(scatola(Vector3(0.012, 0.012, 0.08), Vector3(0.05 + k * 0.03, 0.03 + k * 0.08, 0.16), "legno_scuro"))
	r.add_child(barile(Vector3(-0.62, 0, 0.2), 0.9))
	return r


## Vigneto dei Normanni: casetta di conci col piano a graticcio, pergolato d'uva su pali di legno scuro
## con i plinti di pietra, tino di legno cerchiato per pigiare, ceste di grappoli.
static func vigneto_normanni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.25, 0, -0.3)
	r.add_child(c)
	var lx := 0.66
	var lz := 0.5
	var top := _muri_n(c, lx, lz, 0.32, 3211, 0.5)
	_porta_n(c, Vector3(0.1, 0.07, lz * 0.5), 0.0, 0.11, 0.11)
	_finestra_n(c, Vector3(-0.18, 0.16, lz * 0.5), 0.0, 0.045, 0.07)
	_finestrella_n(c, Vector3(-0.15, 0.31, lz * 0.5 + 0.03), 0.0)
	_finestrella_n(c, Vector3(lx * 0.5 + 0.03, 0.31, 0.0), 90.0)
	_tetto_n(c, lx + 0.06, lz + 0.04, top, 46.0, 3211, "graticcio_n")
	for p: Vector3 in [Vector3(-0.35, 0, 0.15), Vector3(0.25, 0, 0.15), Vector3(-0.35, 0, 0.55), Vector3(0.25, 0, 0.55)]:
		r.add_child(scatola(Vector3(0.03, 0.36, 0.03), p + Vector3(0, 0.18, 0), "legno_scuro"))
		r.add_child(scatola(Vector3(0.06, 0.04, 0.06), p + Vector3(0, 0.02, 0), "pietra_n_chiara"))
	for z: float in [0.15, 0.55]:
		r.add_child(scatola(Vector3(0.66, 0.018, 0.018), Vector3(-0.05, 0.355, z), "legno_scuro"))
	var rng := _rng(3212)
	for k in 26:
		r.add_child(sfera(0.045, Vector3(rng.randf_range(-0.38, 0.28), 0.37, rng.randf_range(0.12, 0.58)), "foglie" if k % 3 else "foglie_chiare", Vector3(1, 0.5, 1)))
	for k in 6:
		r.add_child(sfera(0.022, Vector3(-0.3 + k * 0.1, 0.32, 0.35 + (k % 2) * 0.1), "uva", Vector3(1, 1.5, 1)))
	var v := Vector3(0.55, 0, 0.4)
	r.add_child(cilindro(0.11, 0.1, 0.12, v + Vector3(0, 0.06, 0), "legno_scuro", Vector3.ZERO, 14))
	for yy: float in [0.025, 0.095]:
		r.add_child(cilindro(0.112, 0.112, 0.012, v + Vector3(0, yy, 0), "ferro", Vector3.ZERO, 14))
	r.add_child(cilindro(0.095, 0.095, 0.005, v + Vector3(0, 0.12, 0), "uva", Vector3.ZERO, 14))
	r.add_child(cesta(Vector3(0.6, 0, 0.0), "uva"))
	r.add_child(cesta(Vector3(0.45, 0, -0.2), "uva"))
	return r


## Cantina dei Normanni: cellaio di conci col tetto d'ardesia e il grande portale ad arco, botti coricate
## sui cavalletti, torchio a vite di legno scuro, cesta d'uva e scudo giallo.
static func cantina_normanni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.25)
	r.add_child(c)
	var lx := 0.76
	var lz := 0.56
	var top := _muri_n(c, lx, lz, 0.34, 3221)
	_porta_n(c, Vector3(0.15, 0.07, lz * 0.5), 0.0, 0.17, 0.12, true)
	_finestra_n(c, Vector3(-0.2, 0.27, lz * 0.5), 0.0)
	_finestra_n(c, Vector3(lx * 0.5, 0.27, 0.0), 90.0)
	_tetto_n(c, lx + 0.06, lz, top, 46.0, 3221)
	c.add_child(_scudo_n(Vector3(-0.2, 0.15, lz * 0.5 + 0.012), 0.0, 0.7))
	for k in 3:
		var p := Vector3(0.62, 0, -0.3 + k * 0.2)
		for s: int in [-1, 1]:
			r.add_child(scatola(Vector3(0.14, 0.03, 0.03), p + Vector3(0, 0.015, s * 0.04), "legno_scuro"))
		var b := barile(p + Vector3(0, 0.086, -0.0625), 1.25)
		b.rotation_degrees.x = 90
		r.add_child(b)
	for k in 5:
		r.add_child(barile(Vector3(-0.6 + (k % 3) * 0.1, 0, 0.42 + (k / 3) * 0.12), 0.8))
	var t := Vector3(0.2, 0, 0.55)
	r.add_child(scatola(Vector3(0.36, 0.06, 0.28), t + Vector3(0, 0.03, 0), "pietra_n_scura"))
	r.add_child(scatola(Vector3(0.3, 0.01, 0.22), t + Vector3(0, 0.065, 0), "vino"))
	for s: int in [-1, 1]:
		r.add_child(scatola(Vector3(0.035, 0.34, 0.035), t + Vector3(s * 0.15, 0.17, 0), "legno_scuro"))
	r.add_child(scatola(Vector3(0.36, 0.04, 0.05), t + Vector3(0, 0.33, 0), "legno_scuro"))
	r.add_child(cilindro(0.018, 0.018, 0.24, t + Vector3(0, 0.22, 0), "legno", Vector3.ZERO, 8))
	r.add_child(scatola(Vector3(0.22, 0.03, 0.16), t + Vector3(0, 0.1, 0), "legno_scuro"))
	r.add_child(cilindro(0.008, 0.008, 0.2, t + Vector3(0, 0.3, 0), "legno", Vector3(0, 0, 90), 5))
	r.add_child(cesta(Vector3(-0.15, 0, 0.6), "uva"))
	return r


## Ortolano dei Normanni: casetta di conci col piano a graticcio, orto chiuso dal graticcio e bagnato
## dalla canaletta, trecce di cipolle appese a una pertica, ceste di verdura.
static func ortolano_normanni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.3, 0, -0.3)
	r.add_child(c)
	var lx := 0.58
	var lz := 0.46
	var top := _muri_n(c, lx, lz, 0.3, 3231, 0.5)
	_porta_n(c, Vector3(0.08, 0.07, lz * 0.5), 0.0, 0.1, 0.1)
	_finestra_n(c, Vector3(-0.16, 0.16, lz * 0.5), 0.0, 0.045, 0.06)
	_finestrella_n(c, Vector3(-0.1, 0.3, lz * 0.5 + 0.03), 0.0)
	_finestrella_n(c, Vector3(lx * 0.5 + 0.03, 0.3, 0.0), 90.0)
	_tetto_n(c, lx + 0.06, lz + 0.04, top, 48.0, 3231, "graticcio_n")
	orto(r, Vector3(0.45, 0, 0.0), 0.36, 0.6, 3232)
	_canaletta(r, Vector3(0.45, 0, -0.32), Vector3(0.45, 0, 0.32), 0.025)
	_graticcio(r, Vector3(0.68, 0, -0.34), Vector3(0.68, 0, 0.34), 0.08)
	for x: float in [-0.56, -0.2]:
		r.add_child(cilindro(0.01, 0.01, 0.34, Vector3(x, 0.17, 0.12), "legno_scuro", Vector3.ZERO, 5))
	r.add_child(cilindro(0.008, 0.008, 0.38, Vector3(-0.38, 0.33, 0.12), "legno_scuro", Vector3(0, 0, 90), 5))
	for k in 4:
		for i in 4:
			r.add_child(sfera(0.02, Vector3(-0.5 + k * 0.08, 0.3 - i * 0.04, 0.12), "cipolla"))
	for p: Vector3 in [Vector3(-0.4, 0, 0.45), Vector3(-0.2, 0, 0.55)]:
		r.add_child(cesta(p, "ortaggi"))
	r.add_child(cesta(Vector3(0.05, 0, 0.6), "cipolle"))
	return r


## Agrumeto dei Normanni: casetta di conci col tetto d'ardesia, grande albero di agrumi nell'aiuola bordata di conci,
## cisterna di pietra con la canaletta, ceste di arance e limoni.
static func agrumeto_normanni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.3, 0, -0.3)
	r.add_child(c)
	var lx := 0.6
	var lz := 0.46
	var top := _muri_n(c, lx, lz, 0.26, 3241)
	_porta_n(c, Vector3(-0.1, 0.07, lz * 0.5), 0.0, 0.11, 0.12)
	_finestra_n(c, Vector3(0.15, 0.23, lz * 0.5), 0.0)
	_tetto_n(c, lx + 0.06, lz, top, 50.0, 3241)
	var a := agrumi(3)
	var terra := a.get_child(0)
	a.remove_child(terra)
	terra.free()
	a.position = Vector3(0.3, 0, 0.25)
	a.scale = Vector3.ONE * 1.1
	r.add_child(a)
	r.add_child(cilindro(0.2, 0.2, 0.03, Vector3(0.3, 0.015, 0.25), "pietra_normanna", Vector3.ZERO, 8))
	r.add_child(cilindro(0.18, 0.18, 0.004, Vector3(0.3, 0.031, 0.25), "terra", Vector3.ZERO, 8))
	var v := Vector3(-0.02, 0, 0.6)
	r.add_child(scatola(Vector3(0.16, 0.08, 0.16), v + Vector3(0, 0.04, 0), "pietra_normanna"))
	r.add_child(scatola(Vector3(0.18, 0.016, 0.18), v + Vector3(0, 0.088, 0), "pietra_n_chiara"))
	r.add_child(scatola(Vector3(0.12, 0.005, 0.12), v + Vector3(0, 0.094, 0), "acqua_chiara"))
	_canaletta(r, Vector3(0.07, 0, 0.6), Vector3(0.22, 0, 0.42), 0.025)
	for p: Vector3 in [Vector3(-0.45, 0, 0.45), Vector3(-0.28, 0, 0.6), Vector3(0.7, 0, -0.25)]:
		r.add_child(cesta(p, "agrumi"))
	r.add_child(cassa(Vector3(0.65, 0, 0.1), 20))
	return r


## Pesca del pesce spada dei Normanni: casetta di conci col tetto d'ardesia, barca di legno scuro con le fasce d'oro,
## l'albero di vedetta e il pennoncello giallo, passerella dell'arpioniere, arpione e pesce spada.
static func pesca_spada_normanni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.3, 0, -0.3)
	r.add_child(c)
	var lx := 0.6
	var lz := 0.46
	var top := _muri_n(c, lx, lz, 0.26, 3251)
	_porta_n(c, Vector3(0.1, 0.07, lz * 0.5), 0.0, 0.11, 0.12)
	_finestra_n(c, Vector3(lx * 0.5, 0.23, 0.0), 90.0)
	_finestra_n(c, Vector3(-0.15, 0.23, lz * 0.5), 0.0)
	_tetto_n(c, lx + 0.06, lz, top, 50.0, 3251)
	var b := Node3D.new()
	b.position = Vector3(0.3, 0, 0.35)
	b.rotation_degrees.y = -30
	r.add_child(b)
	b.add_child(sfera(0.15, Vector3(0, 0.07, 0), "legno_scuro", Vector3(2.8, 0.7, 1.0)))
	b.add_child(sfera(0.13, Vector3(0, 0.1, 0), "legno_vecchio", Vector3(2.7, 0.35, 0.9)))
	b.add_child(scatola(Vector3(0.8, 0.02, 0.03), Vector3(0, 0.14, 0.13), "stoffa_oro"))
	b.add_child(scatola(Vector3(0.8, 0.02, 0.03), Vector3(0, 0.14, -0.13), "stoffa_oro"))
	b.add_child(cilindro(0.01, 0.008, 0.6, Vector3(0.0, 0.42, 0), "legno_scuro", Vector3.ZERO, 6))
	for k in 5:
		b.add_child(scatola(Vector3(0.08, 0.006, 0.01), Vector3(0.0, 0.2 + k * 0.08, 0.0), "legno_scuro"))
	b.add_child(scatola(Vector3(0.006, 0.05, 0.08), Vector3(0.0, 0.68, 0.04), "stoffa_oro"))
	b.add_child(scatola(Vector3(0.008, 0.012, 0.08), Vector3(0.0, 0.68, 0.04), "bandiera_rossa"))
	b.add_child(scatola(Vector3(0.45, 0.012, 0.02), Vector3(0.55, 0.13, 0), "legno_chiaro"))
	r.add_child(scatola(Vector3(0.02, 0.012, 0.5), Vector3(-0.6, 0.15, 0.4), "ferro", Vector3(0, 0, 4)))
	var sp := pesce_spada_modello()
	sp.position = Vector3(-0.35, 0.02, 0.55)
	r.add_child(sp)
	r.add_child(barile(Vector3(-0.66, 0, 0.1), 0.9))
	return r


## Miniera dei Normanni: fianco della montagna con il portale di conci ad arco tondo e la tettoia d'ardesia,
## binari, carrello di legno scuro, mucchio di minerale, lanterna di ferro, puntelli e stendardo giallo.
static func miniera_ferro_normanni(minerale := "minerale") -> Node3D:
	var r := Node3D.new()
	r.add_child(sfera(0.6, Vector3(-0.25, 0.0, -0.3), "roccia_massi", Vector3(1.2, 0.75, 1.0)))
	r.add_child(sfera(0.35, Vector3(0.35, 0.0, -0.45), "roccia_massi", Vector3(1.1, 0.8, 1.0)))
	r.add_child(sfera(0.3, Vector3(-0.65, 0.0, 0.15), "roccia_massi", Vector3(1.0, 0.7, 1.0)))
	var imb := Vector3(-0.05, 0, 0.18)
	r.add_child(scatola(Vector3(0.4, 0.36, 0.14), imb + Vector3(0, 0.18, -0.02), "pietra_normanna"))
	for s: float in [-1.0, 1.0]:
		r.add_child(scatola(Vector3(0.05, 0.36, 0.15), imb + Vector3(s * 0.19, 0.18, -0.015), "pietra_n_chiara"))
	r.add_child(scatola(Vector3(0.42, 0.03, 0.16), imb + Vector3(0, 0.37, -0.02), "pietra_n_scura"))
	_tettoia_n(r, imb + Vector3(0, 0.38, 0.02), 0.44, 0.18, 0.1, 0.02, 0.0, false)
	_porta_n(r, imb + Vector3(0, 0, 0.05), 0.0, 0.17, 0.13, true)
	for k in 6:
		r.add_child(scatola(Vector3(0.14, 0.008, 0.02), imb + Vector3(0, 0.004, 0.12 + k * 0.08), "legno_scuro"))
	for lato: int in [-1, 1]:
		r.add_child(scatola(Vector3(0.012, 0.01, 0.5), imb + Vector3(lato * 0.05, 0.012, 0.33), "ferro"))
	var carr := Vector3(-0.05, 0, 0.5)
	r.add_child(scatola(Vector3(0.14, 0.08, 0.18), carr + Vector3(0, 0.07, 0), "legno_scuro"))
	for yy: float in [0.045, 0.095]:
		r.add_child(scatola(Vector3(0.145, 0.01, 0.185), carr + Vector3(0, yy, 0), "ferro"))
	r.add_child(mucchio(carr + Vector3(0, 0.1, 0), minerale, 6, 3, 0.03))
	for x: float in [-0.075, 0.075]:
		for z: float in [-0.06, 0.06]:
			r.add_child(cilindro(0.022, 0.022, 0.012, carr + Vector3(x, 0.025, z), "ferro", Vector3(0, 0, 90), 8))
	r.add_child(mucchio(Vector3(0.45, 0, 0.35), minerale, 14, 4))
	r.add_child(cilindro(0.01, 0.01, 0.3, Vector3(0.22, 0.15, 0.3), "legno_scuro", Vector3.ZERO, 5))
	r.add_child(scatola(Vector3(0.04, 0.05, 0.04), Vector3(0.22, 0.28, 0.3), "ferro"))
	r.add_child(sfera(0.014, Vector3(0.22, 0.28, 0.3), "brace"))
	r.add_child(cilindro(0.0, 0.03, 0.03, Vector3(0.22, 0.315, 0.3), "ferro", Vector3(0, 45, 0), 4))
	for k in 4:
		r.add_child(cilindro(0.018, 0.018, 0.4, Vector3(-0.55 + k * 0.045, 0.02 + (k % 2) * 0.03, 0.55), "legno_vecchio", Vector3(0, 70, 90), 6))
	r.add_child(barile(Vector3(0.3, 0, 0.55), 0.9))
	_stendardo_n(r, Vector3(0.62, 0, 0.08), 0.45)
	return r


## Zecca dei Normanni: casa forte di conci col tetto d'ardesia e la torretta merlata con lo stendardo,
## scudo giallo sul portale, casse di monete, incudine per coniare, argento grezzo, guardia con l'elmo a nasale.
static func zecca_normanni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.25)
	r.add_child(c)
	var lx := 0.74
	var lz := 0.56
	var top := _muri_n(c, lx, lz, 0.4, 3291)
	_porta_n(c, Vector3(0.0, 0.07, lz * 0.5), 0.0, 0.14, 0.16)
	_finestra_n(c, Vector3(-0.22, 0.32, lz * 0.5), 0.0)
	_finestra_n(c, Vector3(0.22, 0.32, lz * 0.5), 0.0)
	_finestra_n(c, Vector3(lx * 0.5, 0.32, 0.12), 90.0)
	_finestra_n(c, Vector3(lx * 0.5, 0.32, -0.14), 90.0)
	for x: float in [-0.36, 0.36]:
		c.add_child(scatola(Vector3(0.05, top - 0.1, 0.022), Vector3(x, 0.07 + (top - 0.07) * 0.5, lz * 0.5 + 0.01), "pietra_n_chiara"))
	c.add_child(_scudo_n(Vector3(0.0, 0.42, lz * 0.5 + 0.012), 0.0, 0.9))
	var cima := _tetto_n(c, lx + 0.06, lz, top, 44.0, 3291)
	var tp := Vector3(-lx * 0.5 + 0.08, 0, -lz * 0.5 + 0.08)
	var ht := _torre_n(c, tp, 0.26, cima - 0.06, false, false)
	_stendardo_n(c, tp + Vector3(0.07, ht, 0.07), 0.3, 0.85)
	for k in 3:
		r.add_child(cassa(Vector3(0.45 + k * 0.12, 0, 0.4), k * 15, 0.1))
		r.add_child(cilindro(0.035, 0.035, 0.01, Vector3(0.45 + k * 0.12, 0.085, 0.4), "moneta", Vector3.ZERO, 10))
	r.add_child(cilindro(0.04, 0.05, 0.08, Vector3(-0.35, 0.04, 0.5), "corteccia", Vector3.ZERO, 10))
	r.add_child(scatola(Vector3(0.1, 0.035, 0.05), Vector3(-0.35, 0.095, 0.5), "ferro"))
	r.add_child(mucchio(Vector3(-0.62, 0, 0.25), "argento_grezzo", 8, 10))
	r.add_child(_guardia_n(Vector3(0.18, 0, 0.5)))
	return r


## Porto dei Normanni: banchina di pietra squadrata, pontile di legno sul mare, bitte, fondaco di conci col tetto
## d'ardesia e la tettoia sul davanti, botti, casse, gru di legno, vela gialla arrotolata, stendardo.
static func porto_normanni() -> Node3D:
	var r := Node3D.new()
	var rng := _rng(3921)
	r.add_child(scatola(Vector3(0.42, 0.1, 1.08), Vector3(0.36, 0.05, 0.02), "pietra_normanna"))
	r.add_child(scatola(Vector3(0.44, 0.02, 1.1), Vector3(0.36, 0.06, 0.02), "pietra_n_scura"))
	r.add_child(scatola(Vector3(0.46, 0.025, 1.12), Vector3(0.36, 0.112, 0.02), "pietra_n_chiara"))
	for k in 6:
		r.add_child(scatola(Vector3(0.012, 0.004, 1.1), Vector3(0.18 + k * 0.07, 0.126, 0.02), "pietra_n_scura"))
	var pz := 0.26
	for k in 4:
		var x := 0.66 + k * 0.13
		for s: int in [-1, 1]:
			r.add_child(cilindro(0.017, 0.019, 0.26, Vector3(x, -0.01, pz + s * 0.12), "legno_vecchio", Vector3.ZERO, 7))
			r.add_child(cilindro(0.02, 0.02, 0.012, Vector3(x, 0.01, pz + s * 0.12), "foglie_scure", Vector3.ZERO, 7))
	for s: int in [-1, 1]:
		r.add_child(scatola(Vector3(0.5, 0.025, 0.02), Vector3(0.82, 0.095, pz + s * 0.12), "legno_scuro"))
	for k in 13:
		var x := 0.59 + k * 0.038
		r.add_child(scatola(Vector3(0.034, 0.014, 0.28), Vector3(x, 0.112 + rng.randf_range(-0.003, 0.003), pz), "legno" if k % 3 else "legno_chiaro", Vector3(0, rng.randf_range(-2, 2), 0)))
	for z: float in [-0.42, -0.08, 0.5]:
		r.add_child(cilindro(0.022, 0.026, 0.07, Vector3(0.54, 0.16, z), "pietra_n_scura", Vector3.ZERO, 10))
		r.add_child(cilindro(0.03, 0.03, 0.014, Vector3(0.54, 0.198, z), "pietra_n_chiara", Vector3.ZERO, 10))
	for x: float in [0.72, 1.02]:
		for s: int in [-1, 1]:
			r.add_child(cilindro(0.014, 0.016, 0.07, Vector3(x, 0.155, pz + s * 0.125), "legno_scuro", Vector3.ZERO, 7))
	r.add_child(cilindro(0.03, 0.03, 0.014, Vector3(0.54, 0.177, -0.08), "corda", Vector3.ZERO, 10))
	ramo(r, Vector3(0.54, 0.175, -0.08), Vector3(0.66, 0.02, -0.02), 0.005, "corda")
	ramo(r, Vector3(1.02, 0.17, pz + 0.125), Vector3(1.1, 0.03, pz + 0.2), 0.005, "corda")
	# fondaco del porto con il tetto d'ardesia e la tettoia sul davanti
	var c := Node3D.new()
	c.position = Vector3(-0.28, 0, -0.26)
	r.add_child(c)
	var lx := 0.62
	var lz := 0.4
	var top := _muri_n(c, lx, lz, 0.34, 3922, 0.5)
	_porta_n(c, Vector3(-0.1, 0.07, lz * 0.5), 0.0, 0.13, 0.12, true)
	_finestra_n(c, Vector3(0.16, 0.16, lz * 0.5), 0.0)
	_finestrella_n(c, Vector3(0.16, 0.32, lz * 0.5 + 0.03), 0.0)
	_finestrella_n(c, Vector3(lx * 0.5 + 0.03, 0.32, 0.0), 90.0)
	var cima := _tetto_n(c, lx + 0.06, lz + 0.04, top, 46.0, 3922, "graticcio_n")
	_stendardo_n(c, Vector3(lx * 0.5 - 0.02, cima - 0.03, 0.0), 0.36, 0.8)
	var pd := 0.2
	c.add_child(scatola(Vector3(lx + 0.06, 0.06, pd + 0.02), Vector3(0, 0.03, lz * 0.5 + pd * 0.5), "pietra_n_scura"))
	_tettoia_n(c, Vector3(0, 0.06, lz * 0.5 + pd * 0.5 + 0.02), lx + 0.04, pd, 0.24, 0.2, 0.0, false)
	for i in 3:
		c.add_child(barile(Vector3(0.06 + i * 0.08, 0.06, lz * 0.5 + 0.08), 0.75))
	c.add_child(sacco(Vector3(-0.22, 0.06, lz * 0.5 + 0.08), 0.3))
	r.add_child(scatola(Vector3(0.62, 0.012, 0.5), Vector3(-0.12, 0.006, 0.32), "battuto"))
	var ra := Node3D.new()
	ra.position = Vector3(-0.42, 0, 0.34)
	r.add_child(ra)
	ra.add_child(scatola(Vector3(0.3, 0.02, 0.2), Vector3(0, 0.02, 0), "legno_scuro"))
	for f in 2:
		for k in 3 - f:
			var b := barile(Vector3((k - (2 - f) * 0.5) * 0.095, 0.064 + f * 0.064, -0.08), 0.75)
			b.rotation_degrees.x = 90
			ra.add_child(b)
	for k in 3:
		ra.add_child(barile(Vector3(-0.1 + k * 0.1, 0.03, 0.12), 0.7))
	r.add_child(cassa(Vector3(0.06, 0.012, 0.42), 10))
	r.add_child(cassa(Vector3(0.18, 0.012, 0.44), -15))
	r.add_child(cassa(Vector3(0.11, 0.1, 0.43), 30, 0.1))
	r.add_child(scatola(Vector3(0.1, 0.004, 0.1), Vector3(0.11, 0.182, 0.43), "corda", Vector3(0, 30, 0)))
	r.add_child(cilindro(0.028, 0.028, 0.16, Vector3(-0.06, 0.04, 0.54), "stoffa_oro", Vector3(0, 70, 90), 10))
	r.add_child(cilindro(0.028, 0.028, 0.16, Vector3(-0.04, 0.09, 0.55), "lana", Vector3(0, 80, 90), 10))
	r.add_child(cesta(Vector3(0.28, 0.125, 0.4), "pesce", 0.8))
	var g := Node3D.new()
	g.position = Vector3(0.42, 0.125, -0.28)
	r.add_child(g)
	var gc := Vector3(0.36, 0.62, 0.0)
	for s: int in [-1, 1]:
		ramo(g, Vector3(-0.04, 0, s * 0.12), gc, 0.016, "legno_scuro")
	ramo(g, Vector3(-0.22, 0, 0), gc + Vector3(-0.02, -0.02, 0), 0.012, "legno_vecchio")
	g.add_child(scatola(Vector3(0.02, 0.02, 0.26), Vector3(0.06, 0.18, 0), "legno_scuro"))
	g.add_child(cilindro(0.03, 0.03, 0.2, Vector3(0.0, 0.1, 0), "legno_scuro", Vector3(90, 0, 0), 10))
	g.add_child(cilindro(0.032, 0.032, 0.06, Vector3(0.0, 0.1, 0), "corda", Vector3(90, 0, 0), 10))
	g.add_child(cilindro(0.025, 0.025, 0.04, gc, "legno_chiaro", Vector3(90, 0, 0), 10))
	ramo(g, Vector3(0.0, 0.12, 0), gc, 0.004, "corda")
	ramo(g, gc, gc + Vector3(0, -0.34, 0), 0.004, "corda")
	var rete := Node3D.new()
	rete.position = gc + Vector3(0, -0.42, 0)
	g.add_child(rete)
	rete.add_child(scatola(Vector3(0.09, 0.006, 0.09), Vector3.ZERO, "legno_chiaro"))
	rete.add_child(barile(Vector3(0, 0.003, 0), 0.6))
	for s: int in [-1, 1]:
		ramo(rete, Vector3(s * 0.045, 0, 0), Vector3(0, 0.08, 0), 0.003, "corda")
	var v := Node3D.new()
	v.position = Vector3(0.3, 0.125, 0.1)
	v.rotation_degrees.y = 8
	r.add_child(v)
	v.add_child(cilindro(0.008, 0.008, 0.5, Vector3(0, 0.02, 0), "legno_chiaro", Vector3(90, 0, 0), 6))
	for k in 7:
		v.add_child(cilindro(0.032, 0.032, 0.06, Vector3(0, 0.034, -0.18 + k * 0.06), "stoffa_oro" if k % 2 == 0 else "bandiera_rossa", Vector3(90, 0, 0), 10))
	for k in 4:
		v.add_child(cilindro(0.035, 0.035, 0.008, Vector3(0, 0.034, -0.15 + k * 0.1), "corda", Vector3(90, 0, 0), 10))
	r.add_child(cilindro(0.04, 0.04, 0.02, Vector3(0.2, 0.135, -0.48), "corda", Vector3.ZERO, 12))
	r.add_child(cilindro(0.02, 0.02, 0.022, Vector3(0.2, 0.136, -0.48), "legno_scuro", Vector3.ZERO, 8))
	var an := _ancora_nave(Vector3(0.88, 0.12, pz), 90)
	an.scale = Vector3.ONE * 0.6
	r.add_child(an)
	_stendardo_n(r, Vector3(0.52, 0.125, 0.42), 0.5)
	return r


## Carbonaia dei Normanni: casotto di conci col tetto d'ardesia, cupola di legna coperta di terra che fuma,
## legna, carbone pronto, sacchi e botte.
static func carbonaia_normanni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.38, 0, -0.35)
	r.add_child(c)
	var top := _muri_n(c, 0.4, 0.32, 0.17, 3261)
	_porta_n(c, Vector3(0.05, 0.07, 0.16), 0.0, 0.09, 0.07, true)
	_tetto_n(c, 0.44, 0.34, top, 52.0, 3261)
	var m := Vector3(0.22, 0, 0.2)
	r.add_child(sfera(0.36, m, "terra", Vector3(1, 0.7, 1)))
	r.add_child(sfera(0.3, m + Vector3(0, 0.03, 0), "fuliggine", Vector3(1, 0.7, 1)))
	r.add_child(sfera(0.37, m + Vector3(0, -0.01, 0), "terra", Vector3(1, 0.68, 1)))
	for k in 5:
		r.add_child(sfera(0.05 + k * 0.012, m + Vector3(0.02 * k, 0.28 + k * 0.07, -0.01 * k), "fumo", Vector3(1, 0.8, 1)))
	r.add_child(scatola(Vector3(0.06, 0.04, 0.04), m + Vector3(0.0, 0.12, 0.33), "buio"))
	legnaia(r, Vector3(-0.55, 0, 0.35), 0.35, 4)
	r.add_child(mucchio(Vector3(0.62, 0, -0.25), "carbone", 12, 5))
	r.add_child(sacco(Vector3(0.6, 0, 0.55), 0.4))
	r.add_child(barile(Vector3(-0.1, 0, 0.0), 0.9))
	return r


## Fonderia dei Normanni: bottega di conci col tetto d'ardesia, forno a torre quadrata di pietra cerchiato di ferro
## con la bocca accesa, mantice di pelle, lingotti, carbone e minerale.
static func fonderia_normanni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.25, 0, -0.25)
	r.add_child(c)
	var lx := 0.66
	var lz := 0.52
	var top := _muri_n(c, lx, lz, 0.32, 3271)
	_porta_n(c, Vector3(-0.12, 0.07, lz * 0.5), 0.0, 0.13, 0.13, true)
	_finestra_n(c, Vector3(0.16, 0.26, lz * 0.5), 0.0)
	_finestra_n(c, Vector3(lx * 0.5, 0.26, 0.0), 90.0)
	_tetto_n(c, lx + 0.06, lz, top, 46.0, 3271)
	var f := Vector3(0.42, 0, 0.38)
	r.add_child(cilindro(0.2, 0.24, 0.5, f + Vector3(0, 0.25, 0), "pietra_normanna", Vector3(0, 45, 0), 4))
	for k in 2:
		r.add_child(cilindro(0.215 - k * 0.025, 0.215 - k * 0.025, 0.025, f + Vector3(0, 0.14 + k * 0.2, 0), "ferro", Vector3(0, 45, 0), 4))
	r.add_child(cilindro(0.15, 0.17, 0.08, f + Vector3(0, 0.54, 0), "fuliggine", Vector3(0, 45, 0), 4))
	r.add_child(scatola(Vector3(0.1, 0.1, 0.05), f + Vector3(-0.05, 0.12, 0.15), "brace", Vector3(0, 25, 0)))
	for k in 4:
		r.add_child(sfera(0.05 + k * 0.012, f + Vector3(0.0, 0.66 + k * 0.08, -0.01 * k), "fumo"))
	r.add_child(sfera(0.07, f + Vector3(-0.3, 0.1, 0.05), "pelle_scura", Vector3(1.4, 0.5, 1.0)))
	for k in 6:
		r.add_child(scatola(Vector3(0.09, 0.025, 0.035), Vector3(-0.45 + (k % 3) * 0.1, 0.013 + (k / 3) * 0.026, 0.55), "lingotto"))
	r.add_child(mucchio(Vector3(-0.62, 0, 0.25), "carbone", 9, 6))
	r.add_child(mucchio(Vector3(0.68, 0, -0.1), "minerale", 9, 7))
	return r


## Fabbro dei Normanni: bottega di conci col piano a graticcio e il comignolo, fucina all'aperto sotto la tettoia
## d'ardesia, focolare di pietra, incudine, attrezzi appesi, tinozza dell'acqua, lingotti.
static func fabbro_normanni() -> Node3D:
	var r := Node3D.new()
	var c := Node3D.new()
	c.position = Vector3(-0.2, 0, -0.28)
	r.add_child(c)
	var lx := 0.72
	var lz := 0.5
	var top := _muri_n(c, lx, lz, 0.36, 3281, 0.5)
	_porta_n(c, Vector3(0.16, 0.07, lz * 0.5), 0.0, 0.12, 0.12)
	_finestra_n(c, Vector3(-0.18, 0.17, lz * 0.5), 0.0)
	_finestra_n(c, Vector3(lx * 0.5, 0.17, 0.0), 90.0)
	_finestrella_n(c, Vector3(0.18, 0.34, lz * 0.5 + 0.03), 0.0)
	_finestrella_n(c, Vector3(lx * 0.5 + 0.03, 0.34, 0.0), 90.0)
	var cima := _tetto_n(c, lx + 0.06, lz + 0.04, top, 46.0, 3281, "graticcio_n")
	_camino_n(c, Vector3(-0.24, cima - 0.12, -0.04), 0.2)
	_tettoia_n(r, Vector3(-0.2, 0, 0.43), 0.66, 0.32, 0.4, 0.32)
	r.add_child(scatola(Vector3(0.2, 0.12, 0.16), Vector3(-0.38, 0.06, 0.42), "pietra_normanna"))
	r.add_child(scatola(Vector3(0.22, 0.016, 0.18), Vector3(-0.38, 0.128, 0.42), "pietra_n_scura"))
	r.add_child(scatola(Vector3(0.14, 0.01, 0.1), Vector3(-0.38, 0.14, 0.42), "brace"))
	r.add_child(scatola(Vector3(0.06, 0.05, 0.012), Vector3(-0.38, 0.05, 0.505), "brace"))
	r.add_child(cilindro(0.04, 0.05, 0.08, Vector3(-0.05, 0.04, 0.45), "corteccia", Vector3.ZERO, 10))
	r.add_child(scatola(Vector3(0.12, 0.04, 0.05), Vector3(-0.05, 0.1, 0.45), "ferro"))
	r.add_child(scatola(Vector3(0.04, 0.025, 0.035), Vector3(0.03, 0.1, 0.45), "ferro"))
	r.add_child(scatola(Vector3(0.6, 0.018, 0.018), Vector3(-0.2, 0.3, 0.3), "legno_scuro"))
	for k in 4:
		var a := attrezzo(ATTREZZI_FABBRO[k])
		a.position = Vector3(-0.42 + k * 0.1, 0.22, 0.31)
		a.rotation_degrees = Vector3(90, 0, 90)
		r.add_child(a)
	r.add_child(cilindro(0.075, 0.07, 0.08, Vector3(0.62, 0.04, 0.1), "legno_scuro", Vector3.ZERO, 14))
	r.add_child(cilindro(0.077, 0.077, 0.01, Vector3(0.62, 0.06, 0.1), "ferro", Vector3.ZERO, 14))
	r.add_child(cilindro(0.065, 0.065, 0.004, Vector3(0.62, 0.079, 0.1), "acqua_chiara", Vector3.ZERO, 14))
	for k in 3:
		r.add_child(scatola(Vector3(0.09, 0.025, 0.035), Vector3(0.45, 0.013 + k * 0.026, 0.45), "lingotto"))
	return r


## Armaiolo dei Normanni: la bottega del fabbro con la rastrelliera di lance dai pennoncelli d'oro,
## scudi a mandorla gialli con la croce rossa, spada e elmo conico sul ceppo.
static func armaiolo_normanni() -> Node3D:
	var r := fabbro_normanni()
	r.add_child(scatola(Vector3(0.28, 0.03, 0.05), Vector3(0.48, 0.015, 0.36), "legno_scuro"))
	r.add_child(scatola(Vector3(0.28, 0.02, 0.03), Vector3(0.48, 0.34, 0.35), "legno_scuro"))
	for k in 5:
		var x := 0.38 + k * 0.05
		r.add_child(cilindro(0.006, 0.006, 0.44, Vector3(x, 0.22, 0.36), "legno", Vector3.ZERO, 5))
		r.add_child(cilindro(0.009, 0.0, 0.04, Vector3(x, 0.46, 0.36), "ferro", Vector3.ZERO, 5))
		r.add_child(scatola(Vector3(0.004, 0.03, 0.04), Vector3(x, 0.41, 0.38), "stoffa_oro"))
	for k in 2:
		r.add_child(_scudo_n(Vector3(0.7 + k * 0.03, 0.1, 0.22 + k * 0.17), 80.0 - k * 10.0, 1.1))
	var sp := Node3D.new()
	sp.position = Vector3(0.3, 0.12, 0.6)
	sp.rotation_degrees.y = 20
	r.add_child(sp)
	sp.add_child(scatola(Vector3(0.16, 0.005, 0.02), Vector3(0.04, 0, 0), "ferro"))
	sp.add_child(scatola(Vector3(0.008, 0.008, 0.07), Vector3(-0.045, 0, 0), "oro_n"))
	sp.add_child(cilindro(0.008, 0.008, 0.04, Vector3(-0.07, 0, 0), "cuoio", Vector3(0, 0, 90), 6))
	sp.add_child(sfera(0.01, Vector3(-0.092, 0, 0), "oro_n"))
	r.add_child(cilindro(0.06, 0.065, 0.11, Vector3(0.3, 0.055, 0.6), "corteccia", Vector3.ZERO, 12))
	r.add_child(cilindro(0.04, 0.04, 0.025, Vector3(0.5, 0.0125, 0.64), "ferro", Vector3.ZERO, 10))
	r.add_child(cilindro(0.04, 0.0, 0.055, Vector3(0.5, 0.052, 0.64), "ferro", Vector3.ZERO, 10))
	r.add_child(scatola(Vector3(0.012, 0.04, 0.008), Vector3(0.5, 0.02, 0.68), "ferro"))
	return r


# =================================================================== SICULI (step 26)
# Lo stile dei Siculi, pastori e vasai dell'interno della Sicilia orientale: capanne ovali con lo zoccolo di pietra
# a secco e il muro di argilla color ocra dipinto a fasce, tetti a cupola di canne legate coperti di frasche, con un vaso
# capovolto sulla cima; recinti di pietra a secco chiara, grandi giare dipinte a fasce rosse e nere, forni da vasaio
# a cupola. Il colore del popolo è l'ocra rossa (stoffe, insegne, scudi).
# Ogni modello ha lo stesso ingombro del corrispondente greco (stesso nome senza "_siculi").

## Capanna ovale dei Siculi: zoccolo di pietra a secco, muro di argilla con la fascia dipinta (ocra rossa fra due righe
## nere, rombi neri), tetto a cupola di canne con le legature di corda, frasche e rami sopra, vaso capovolto in cima.
## pos = centro a terra; rx, rz = semiassi; la porta guarda verso +Z locale (ruotata di rot_y). Restituisce la quota della cima.
static func _capanna_sic(r: Node3D, pos: Vector3, rx: float, rz: float, h: float, seme: int, rot_y := 0.0, porta := true, tetto_k := 1.25) -> float:
	var rng := _rng(seme)
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot_y
	r.add_child(n)
	# nodo schiacciato: i cerchi di raggio rz diventano ovali rx × rz
	var s := Node3D.new()
	s.scale = Vector3(rx / rz, 1, 1)
	n.add_child(s)
	var hz := h * 0.34
	s.add_child(cilindro(rz + 0.035, rz + 0.05, hz, Vector3(0, hz * 0.5, 0), "pietra_secca", Vector3.ZERO, 24))
	for k in int(rz * 46):
		var a := deg_to_rad(rng.randf_range(-60.0, 150.0))
		var d := Vector3(sin(a), 0, cos(a))
		var p := sfera(rng.randf_range(0.02, 0.03), d * (rz + 0.045) + Vector3(0, rng.randf_range(0.025, hz - 0.012), 0), "roccia_chiara" if k % 3 == 0 else "pietra_secca", Vector3(1.4, 0.7, 0.45))
		p.rotation.y = a
		s.add_child(p)
	var hm := h - hz
	s.add_child(cilindro(rz, rz * 0.96, hm, Vector3(0, hz + hm * 0.5, 0), "argilla_sic", Vector3.ZERO, 24))
	# toppe di argilla più fresca sul muro
	for k in 5:
		var a := deg_to_rad(rng.randf_range(-40.0, 130.0))
		var t := sfera(rng.randf_range(0.03, 0.05), Vector3(sin(a), 0, cos(a)) * (rz * 0.975) + Vector3(0, rng.randf_range(hz + 0.03, h - 0.12), 0), "argilla_cruda", Vector3(1.4, 0.8, 0.2))
		t.rotation.y = a
		s.add_child(t)
	# fascia dipinta sotto la gronda
	var rb := rz * 0.965 + 0.004
	var yb := hz + (h - hz) * 0.5
	s.add_child(cilindro(rb, rb, 0.034, Vector3(0, yb, 0), "vernice_rossa", Vector3.ZERO, 24))
	for y: float in [yb - 0.022, yb + 0.022]:
		s.add_child(cilindro(rb + 0.001, rb + 0.001, 0.008, Vector3(0, y, 0), "vernice_nera", Vector3.ZERO, 24))
	for k in 15:
		var a := deg_to_rad(-70.0 + k * 15.0)
		s.add_child(scatola(Vector3(0.017, 0.017, 0.006), Vector3(sin(a), 0, cos(a)) * (rb + 0.003) + Vector3(0, yb, 0), "vernice_nera", Vector3(0, rad_to_deg(a), 45)))
	# tetto a cupola di canne
	var hc := rz * tetto_k
	var y0 := h - 0.04
	var rg := rz + 0.075
	var hcono := hc * 0.55
	s.add_child(cilindro(rg, rz * 0.62, hcono, Vector3(0, y0 + hcono * 0.5, 0), "canne_sic", Vector3.ZERO, 24))
	s.add_child(sfera(rz * 0.66, Vector3(0, y0 + hcono, 0), "canne_sic", Vector3(1, 0.72, 1)))
	# legature di corda
	for f: float in [0.18, 0.5, 0.85]:
		var rr := lerpf(rg, rz * 0.62, f) + 0.004
		s.add_child(_toro(rr - 0.006, rr + 0.006, Vector3(0, y0 + hcono * f, 0), "corda"))
	# gronda sfrangiata di canne
	var nc := int(rg * 52)
	for k in nc:
		var a := k * TAU / nc
		var ci := sfera(0.03, Vector3(sin(a), 0, cos(a)) * (rg - 0.012) + Vector3(0, y0 + 0.004, 0), "frasche" if k % 4 == 0 else "canne_sic", Vector3(1.1, 0.5, 0.8))
		ci.rotation.y = a
		s.add_child(ci)
	# frasche e rami gettati sopra le canne
	for k in int(rz * 70):
		var f := rng.randf_range(0.05, 0.95)
		var a := deg_to_rad(rng.randf_range(-80.0, 170.0))
		var rr := lerpf(rg, rz * 0.62, f)
		var fr := sfera(rng.randf_range(0.03, 0.045), Vector3(sin(a), 0, cos(a)) * rr + Vector3(0, y0 + hcono * f + 0.01, 0), "foglie_scure" if k % 4 == 0 else "frasche", Vector3(1.3, 0.45, 1.0))
		fr.rotation.y = a
		s.add_child(fr)
	for k in 5:
		var a := deg_to_rad(-50.0 + k * 45.0 + rng.randf_range(-10.0, 10.0))
		var d := Vector3(sin(a), 0, cos(a))
		ramo(s, d * (rz * 0.6) + Vector3(0, y0 + hcono + 0.03, 0), d * (rg + 0.015) + Vector3(0, y0 + 0.02, 0), 0.008, "legno_vecchio")
	# cima: ciuffo di canne legato e vaso dipinto capovolto (nel nodo non schiacciato)
	var ytop := y0 + hcono + rz * 0.66 * 0.72
	n.add_child(cilindro(0.05, 0.03, 0.06, Vector3(0, ytop + 0.005, 0), "canne_sic", Vector3.ZERO, 10))
	var v := Node3D.new()
	v.position = Vector3(0, ytop + 0.03, 0)
	n.add_child(v)
	v.add_child(cilindro(0.046, 0.026, 0.065, Vector3(0, 0.032, 0), "ceramica", Vector3.ZERO, 12))
	v.add_child(cilindro(0.045, 0.04, 0.016, Vector3(0, 0.03, 0), "vernice_rossa", Vector3.ZERO, 12))
	v.add_child(cilindro(0.033, 0.03, 0.008, Vector3(0, 0.052, 0), "vernice_nera", Vector3.ZERO, 12))
	v.add_child(cilindro(0.028, 0.028, 0.012, Vector3(0, 0.07, 0), "ceramica", Vector3.ZERO, 10))
	if porta:
		_porta_sic(n, Vector3(0, 0, rz + 0.05), 0.0, 0.12, minf(0.21, h - 0.1))
	return ytop + 0.08


## Porta dei Siculi (guarda verso +Z locale): vano buio fra due lastroni di pietra chiara, architrave di pietra
## con la riga d'ocra, tenda d'ocra rossa con l'orlo nero scostata da un lato, soglia di pietra piatta.
static func _porta_sic(r: Node3D, pos: Vector3, rot_y := 0.0, w := 0.12, h := 0.2, tenda := true) -> void:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot_y
	r.add_child(n)
	n.add_child(scatola(Vector3(w, h, 0.12), Vector3(0, h * 0.5, -0.05), "buio"))
	for lato: int in [-1, 1]:
		n.add_child(scatola(Vector3(0.04, h + 0.02, 0.05), Vector3(lato * (w * 0.5 + 0.02), (h + 0.02) * 0.5, 0.0), "roccia_chiara", Vector3(0, 0, lato * 2)))
	n.add_child(scatola(Vector3(w + 0.13, 0.045, 0.06), Vector3(0, h + 0.035, 0.0), "roccia_chiara"))
	n.add_child(scatola(Vector3(w + 0.08, 0.012, 0.004), Vector3(0, h + 0.035, 0.031), "vernice_rossa"))
	if tenda:
		n.add_child(scatola(Vector3(w * 0.6, h - 0.02, 0.008), Vector3(-w * 0.2, h * 0.5 + 0.005, 0.012), "ocra_rossa", Vector3(0, 0, 2)))
		n.add_child(scatola(Vector3(w * 0.6, 0.016, 0.01), Vector3(-w * 0.21, 0.035, 0.014), "vernice_nera", Vector3(0, 0, 2)))
	n.add_child(sfera(0.07, Vector3(0, 0.0, 0.07), "roccia_chiara", Vector3(1.3, 0.2, 0.7)))


## Muretto di pietra a secco da un punto a un altro: corpo di pietre chiare senza malta, sassi sporgenti, copertine in cima.
static func _muretto_secco(r: Node3D, da: Vector3, a: Vector3, h := 0.1, sp := 0.08) -> void:
	var d := a - da
	d.y = 0.0
	var lung := d.length()
	var n := Node3D.new()
	n.position = Vector3((da.x + a.x) * 0.5, da.y, (da.z + a.z) * 0.5)
	n.rotation.y = atan2(-d.z, d.x)
	r.add_child(n)
	n.add_child(scatola(Vector3(lung, h, sp), Vector3(0, h * 0.5, 0), "pietra_secca"))
	var rng := _rng(int(absf(da.x * 977.0 + da.z * 131.0 + a.x * 53.0)) + 3)
	var nk := maxi(2, int(lung / 0.06))
	for k in nk:
		var x := -lung * 0.5 + (k + 0.5) * lung / nk
		n.add_child(sfera(rng.randf_range(0.026, 0.034), Vector3(x, h, rng.randf_range(-0.01, 0.01)), "roccia_chiara" if k % 3 == 0 else "pietra_secca", Vector3(1.2, 0.6, sp / 0.06)))
		for lato: int in [-1, 1]:
			if rng.randf() < 0.6:
				n.add_child(sfera(rng.randf_range(0.018, 0.026), Vector3(x + rng.randf_range(-0.02, 0.02), rng.randf_range(0.02, maxf(0.025, h - 0.02)), lato * sp * 0.5), "pietra_secca" if k % 2 == 0 else "roccia_chiara", Vector3(1.3, 0.75, 0.4)))


## Grande giara (pithos) di ceramica chiara dipinta: fasce rosse e nere, riga di rombi, due anse, orlo rosso.
static func _giara(pos: Vector3, scala := 1.0, seme := 0) -> Node3D:
	var n := Node3D.new()
	n.position = pos
	n.scale = Vector3.ONE * scala
	var c1 := "vernice_rossa" if seme % 2 == 0 else "vernice_nera"
	var c2 := "vernice_nera" if seme % 2 == 0 else "vernice_rossa"
	n.add_child(cilindro(0.03, 0.036, 0.02, Vector3(0, 0.01, 0), "ceramica", Vector3.ZERO, 12))
	n.add_child(sfera(0.06, Vector3(0, 0.077, 0), "ceramica", Vector3(1, 1.22, 1)))
	n.add_child(cilindro(0.0605, 0.0605, 0.02, Vector3(0, 0.077, 0), c1, Vector3.ZERO, 16))
	n.add_child(cilindro(0.057, 0.0575, 0.007, Vector3(0, 0.052, 0), c2, Vector3.ZERO, 16))
	n.add_child(cilindro(0.0555, 0.052, 0.008, Vector3(0, 0.106, 0), c2, Vector3.ZERO, 16))
	for k in 8:
		var a := k * TAU / 8 + 0.2
		n.add_child(scatola(Vector3(0.012, 0.012, 0.004), Vector3(sin(a) * 0.055, 0.094, cos(a) * 0.055), c2, Vector3(0, rad_to_deg(a), 45)))
	n.add_child(cilindro(0.027, 0.03, 0.035, Vector3(0, 0.155, 0), "ceramica", Vector3.ZERO, 12))
	n.add_child(cilindro(0.036, 0.034, 0.012, Vector3(0, 0.174, 0), "vernice_rossa", Vector3.ZERO, 12))
	n.add_child(cilindro(0.026, 0.026, 0.003, Vector3(0, 0.1805, 0), "buio", Vector3.ZERO, 10))
	for lato: int in [-1, 1]:
		n.add_child(_toro(0.006, 0.014, Vector3(lato * 0.048, 0.125, 0), "ceramica", Vector3(90, 0, 0)))
	return n


## Vaso piccolo dei Siculi: 0 coppa su alto piede, 1 brocca con il becco e l'ansa, 2 olla panciuta. Dipinti a fasce.
static func _vaso_sic(pos: Vector3, scala := 1.0, tipo := 0) -> Node3D:
	var n := Node3D.new()
	n.position = pos
	n.scale = Vector3.ONE * scala
	match tipo:
		0:
			n.add_child(cilindro(0.03, 0.03, 0.008, Vector3(0, 0.004, 0), "ceramica", Vector3.ZERO, 12))
			n.add_child(cilindro(0.012, 0.016, 0.05, Vector3(0, 0.03, 0), "ceramica", Vector3.ZERO, 10))
			n.add_child(cilindro(0.0165, 0.0165, 0.008, Vector3(0, 0.03, 0), "vernice_nera", Vector3.ZERO, 10))
			n.add_child(cilindro(0.052, 0.024, 0.035, Vector3(0, 0.07, 0), "ceramica", Vector3.ZERO, 14))
			n.add_child(cilindro(0.053, 0.05, 0.01, Vector3(0, 0.083, 0), "vernice_rossa", Vector3.ZERO, 14))
			n.add_child(cilindro(0.044, 0.044, 0.003, Vector3(0, 0.088, 0), "buio", Vector3.ZERO, 12))
		1:
			n.add_child(sfera(0.036, Vector3(0, 0.04, 0), "ceramica", Vector3(1, 1.1, 1)))
			n.add_child(cilindro(0.037, 0.037, 0.012, Vector3(0, 0.042, 0), "vernice_rossa", Vector3.ZERO, 12))
			n.add_child(cilindro(0.033, 0.032, 0.005, Vector3(0, 0.06, 0), "vernice_nera", Vector3.ZERO, 12))
			n.add_child(cilindro(0.016, 0.02, 0.04, Vector3(0.004, 0.09, 0), "ceramica", Vector3(0, 0, -12), 10))
			n.add_child(cilindro(0.008, 0.016, 0.025, Vector3(0.022, 0.108, 0), "ceramica", Vector3(0, 0, -55), 8))
			n.add_child(_toro(0.004, 0.011, Vector3(-0.03, 0.07, 0), "ceramica", Vector3(90, 0, 0), Vector3(1, 1.6, 1)))
		_:
			n.add_child(sfera(0.042, Vector3(0, 0.04, 0), "ceramica", Vector3(1, 0.85, 1)))
			n.add_child(cilindro(0.0425, 0.0425, 0.014, Vector3(0, 0.04, 0), "vernice_nera", Vector3.ZERO, 14))
			n.add_child(cilindro(0.04, 0.038, 0.006, Vector3(0, 0.058, 0), "vernice_rossa", Vector3.ZERO, 14))
			n.add_child(cilindro(0.026, 0.03, 0.016, Vector3(0, 0.075, 0), "ceramica", Vector3.ZERO, 12))
			n.add_child(cilindro(0.031, 0.031, 0.006, Vector3(0, 0.084, 0), "vernice_rossa", Vector3.ZERO, 12))
	return n


## Forno a cupola d'argilla (da vasaio o da pane): base di pietra a secco, cupola annerita, bocca con le braci verso +Z,
## sfiatatoi in cima e fumo.
static func _forno_sic(r: Node3D, pos: Vector3, s := 1.0, fumo := true) -> void:
	r.add_child(cilindro(0.21 * s, 0.23 * s, 0.1 * s, pos + Vector3(0, 0.05 * s, 0), "pietra_secca", Vector3.ZERO, 20))
	r.add_child(sfera(0.2 * s, pos + Vector3(0, 0.1 * s, 0), "argilla_sic", Vector3(1, 1.05, 1)))
	r.add_child(cilindro(0.2 * s, 0.2 * s, 0.025 * s, pos + Vector3(0, 0.13 * s, 0), "vernice_rossa", Vector3.ZERO, 20))
	for k in 4:
		var a := deg_to_rad(-30.0 + k * 40.0)
		var t := sfera(0.05 * s, pos + Vector3(sin(a), 0, cos(a)) * 0.165 * s + Vector3(0, 0.23 * s, 0), "fuliggine" if k % 2 == 0 else "argilla_cruda", Vector3(1.3, 0.8, 0.3))
		t.rotation.y = a
		r.add_child(t)
	var b := pos + Vector3(0, 0, 0.2 * s)
	r.add_child(scatola(Vector3(0.14 * s, 0.11 * s, 0.08 * s), b + Vector3(0, 0.07 * s, 0), "pietra_secca"))
	r.add_child(scatola(Vector3(0.09 * s, 0.075 * s, 0.02 * s), b + Vector3(0, 0.06 * s, 0.035 * s), "buio"))
	r.add_child(sfera(0.032 * s, b + Vector3(0, 0.035 * s, 0.04 * s), "brace", Vector3(1.2, 0.6, 0.8)))
	r.add_child(scatola(Vector3(0.12 * s, 0.07 * s, 0.012 * s), b + Vector3(0, 0.15 * s, -0.01 * s), "fuliggine", Vector3(-25, 0, 0)))
	for k in 3:
		var a := k * TAU / 3 + 0.4
		r.add_child(cilindro(0.016 * s, 0.018 * s, 0.03 * s, pos + Vector3(cos(a) * 0.07 * s, 0.3 * s, sin(a) * 0.07 * s), "fuliggine", Vector3.ZERO, 8))
	if fumo:
		_fumo(r, pos + Vector3(0.02 * s, 0.36 * s, 0), 4, s)


## Tornio da vasaio: base di pietra, perno, ruota di legno con un vaso d'argilla fresca, sgabello e ciotola d'acqua.
static func _tornio_sic(r: Node3D, pos: Vector3, rot_y := 0.0) -> void:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot_y
	r.add_child(n)
	n.add_child(cilindro(0.06, 0.07, 0.03, Vector3(0, 0.015, 0), "pietra_secca", Vector3.ZERO, 12))
	n.add_child(cilindro(0.012, 0.012, 0.07, Vector3(0, 0.065, 0), "legno_scuro", Vector3.ZERO, 6))
	n.add_child(cilindro(0.08, 0.08, 0.018, Vector3(0, 0.1, 0), "legno", Vector3.ZERO, 16))
	n.add_child(cilindro(0.081, 0.081, 0.006, Vector3(0, 0.1, 0), "legno_scuro", Vector3.ZERO, 16))
	n.add_child(cilindro(0.03, 0.038, 0.055, Vector3(0, 0.137, 0), "argilla_cruda", Vector3.ZERO, 12))
	n.add_child(cilindro(0.032, 0.03, 0.01, Vector3(0, 0.168, 0), "argilla_cruda", Vector3.ZERO, 12))
	n.add_child(cilindro(0.024, 0.024, 0.003, Vector3(0, 0.174, 0), "buio", Vector3.ZERO, 10))
	n.add_child(scatola(Vector3(0.09, 0.06, 0.08), Vector3(0, 0.03, -0.14), "legno_vecchio"))
	n.add_child(cilindro(0.035, 0.028, 0.03, Vector3(0.11, 0.015, -0.04), "terracotta", Vector3.ZERO, 10))
	n.add_child(cilindro(0.03, 0.03, 0.003, Vector3(0.11, 0.029, -0.04), "acqua_pozzo", Vector3.ZERO, 10))


## Insegna dei Siculi: asta di legno con la traversa, drappo d'ocra rossa con le fasce nere e il rombo chiaro,
## frange, disco di ceramica dipinto in cima.
static func _insegna_sic(r: Node3D, pos: Vector3, h := 0.6) -> void:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = 45
	r.add_child(n)
	n.add_child(cilindro(0.012, 0.015, h, Vector3(0, h * 0.5, 0), "corteccia", Vector3.ZERO, 6))
	n.add_child(cilindro(0.008, 0.008, 0.2, Vector3(0, h - 0.05, 0.01), "legno_vecchio", Vector3(0, 0, 90), 5))
	n.add_child(scatola(Vector3(0.17, 0.21, 0.006), Vector3(0, h - 0.16, 0.014), "ocra_rossa"))
	for y: float in [h - 0.075, h - 0.245]:
		n.add_child(scatola(Vector3(0.172, 0.016, 0.008), Vector3(0, y, 0.016), "vernice_nera"))
	n.add_child(scatola(Vector3(0.06, 0.06, 0.008), Vector3(0, h - 0.16, 0.017), "ceramica", Vector3(0, 0, 45)))
	n.add_child(scatola(Vector3(0.025, 0.025, 0.01), Vector3(0, h - 0.16, 0.019), "vernice_nera", Vector3(0, 0, 45)))
	for k in 5:
		n.add_child(scatola(Vector3(0.022, 0.04, 0.006), Vector3(-0.068 + k * 0.034, h - 0.285, 0.014), "ocra_rossa" if k % 2 == 0 else "vernice_nera"))
	n.add_child(cilindro(0.045, 0.045, 0.012, Vector3(0, h + 0.04, 0.0), "ceramica", Vector3(90, 0, 0), 16))
	n.add_child(cilindro(0.034, 0.034, 0.014, Vector3(0, h + 0.04, 0.0), "vernice_rossa", Vector3(90, 0, 0), 16))
	n.add_child(cilindro(0.018, 0.018, 0.016, Vector3(0, h + 0.04, 0.0), "vernice_nera", Vector3(90, 0, 0), 12))


## Scudo rotondo dei Siculi (faccia verso +Z locale): cuoio dipinto d'ocra rossa con l'anello nero, rombi chiari, orlo
## di cuoio e umbone di bronzo.
static func _scudo_sic(pos: Vector3, rot_y := 0.0, s := 1.0) -> Node3D:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot_y
	n.scale = Vector3.ONE * s
	n.add_child(cilindro(0.085, 0.085, 0.012, Vector3.ZERO, "ocra_rossa", Vector3(90, 0, 0), 18))
	n.add_child(_toro(0.08, 0.091, Vector3.ZERO, "cuoio", Vector3(90, 0, 0)))
	n.add_child(cilindro(0.064, 0.064, 0.004, Vector3(0, 0, 0.007), "vernice_nera", Vector3(90, 0, 0), 18))
	n.add_child(cilindro(0.052, 0.052, 0.004, Vector3(0, 0, 0.009), "ocra_rossa", Vector3(90, 0, 0), 18))
	for k in 4:
		var a := k * TAU / 4 + PI * 0.25
		n.add_child(scatola(Vector3(0.018, 0.018, 0.004), Vector3(cos(a) * 0.035, sin(a) * 0.035, 0.012), "ceramica", Vector3(0, 0, 45)))
	n.add_child(sfera(0.02, Vector3(0, 0, 0.011), "bronzo", Vector3(1, 1, 0.6)))
	return n


## Tettoia di canne e frasche su pali: alta dietro (-Z), bassa davanti (+Z). pos = centro a terra.
static func _tettoia_sic(r: Node3D, pos: Vector3, larg: float, prof: float, h_alta: float, h_bassa: float, seme := 1) -> void:
	var rng := _rng(seme)
	var dh := h_alta - h_bassa
	var ang := atan2(dh, prof)
	var lung := sqrt(prof * prof + dh * dh) + 0.12
	var xs := [-larg * 0.5, larg * 0.5]
	if larg > 0.7:
		xs.append(0.0)
	for x: float in xs:
		r.add_child(cilindro(0.015, 0.018, h_bassa, pos + Vector3(x, h_bassa * 0.5, prof * 0.5), "corteccia", Vector3.ZERO, 6))
		r.add_child(cilindro(0.015, 0.018, h_alta, pos + Vector3(x, h_alta * 0.5, -prof * 0.5), "corteccia", Vector3.ZERO, 6))
		r.add_child(cilindro(0.01, 0.01, 0.05, pos + Vector3(x, h_bassa + 0.01, prof * 0.5), "corteccia", Vector3(0, 0, 35), 5))
	var ym := (h_alta + h_bassa) * 0.5 + 0.025
	r.add_child(scatola(Vector3(larg + 0.14, 0.035, lung), pos + Vector3(0, ym, 0.0), "canne_sic", Vector3(rad_to_deg(ang), 0, 0)))
	for k in int((larg + 0.14) / 0.09):
		var x := -larg * 0.5 - 0.07 + (k + 0.5) * 0.09
		r.add_child(cilindro(0.006, 0.006, lung, pos + Vector3(x, ym + 0.02, 0.0), "corda" if k % 2 == 0 else "legno_vecchio", Vector3(90 + rad_to_deg(ang), 0, 0), 4))
	for k in int(larg * 14):
		var t := rng.randf_range(-0.4, 0.45)
		var p := pos + Vector3(rng.randf_range(-larg * 0.5, larg * 0.5), ym + 0.03 - t * dh, t * prof)
		r.add_child(sfera(rng.randf_range(0.03, 0.045), p, "foglie_scure" if k % 3 == 0 else "frasche", Vector3(1.3, 0.45, 1.0)))
	r.add_child(cilindro(0.016, 0.016, larg + 0.1, pos + Vector3(0, h_bassa - 0.005, prof * 0.5), "legno_vecchio", Vector3(0, 0, 90), 6))


## Macina a sella: lastra di pietra incavata, pietra per macinare e un po' di farina.
static func _macina_sella(r: Node3D, pos: Vector3, rot_y := 0.0) -> void:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot_y
	r.add_child(n)
	n.add_child(sfera(0.08, Vector3(0, 0.0, 0), "roccia_chiara", Vector3(1.4, 0.4, 0.8)))
	n.add_child(sfera(0.032, Vector3(0.01, 0.035, 0), "roccia_massi", Vector3(0.7, 0.6, 1.6)))
	n.add_child(sfera(0.03, Vector3(-0.08, 0.025, 0.02), "lino", Vector3(1.4, 0.3, 1.0)))


## Fascio di frasche legato, da bruciare nel forno.
static func _fascina(r: Node3D, pos: Vector3, rot_y := 0.0) -> void:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot_y
	r.add_child(n)
	for k in 6:
		n.add_child(cilindro(0.006, 0.004, 0.24, Vector3(-0.01 + (k % 3) * 0.01, 0.025 + (k / 3) * 0.012, 0), "corteccia", Vector3(90, 0, -4 + k * 2), 4))
	n.add_child(sfera(0.04, Vector3(0, 0.03, 0.1), "frasche", Vector3(1, 0.8, 1.3)))
	n.add_child(cilindro(0.025, 0.025, 0.01, Vector3(0, 0.03, -0.03), "corda", Vector3(90, 0, 0), 8))


## Rastrelliera di lance con i nastri d'ocra e scudi rotondi appoggiati.
static func _rastrelliera_sic(r: Node3D, pos: Vector3, rot_y := 0.0) -> void:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot_y
	r.add_child(n)
	for lato: int in [-1, 1]:
		n.add_child(cilindro(0.012, 0.014, 0.3, Vector3(lato * 0.13, 0.15, 0), "corteccia", Vector3.ZERO, 6))
	n.add_child(cilindro(0.009, 0.009, 0.3, Vector3(0, 0.27, 0), "legno_vecchio", Vector3(0, 0, 90), 5))
	for k in 5:
		var x := -0.1 + k * 0.05
		n.add_child(cilindro(0.005, 0.005, 0.42, Vector3(x, 0.21, -0.02), "legno", Vector3(-8, 0, 0), 5))
		n.add_child(cilindro(0.012, 0.0, 0.045, Vector3(x, 0.44, -0.05), "bronzo", Vector3(-8, 0, 0), 5))
		n.add_child(scatola(Vector3(0.012, 0.03, 0.004), Vector3(x + 0.006, 0.38, -0.04), "ocra_rossa"))
	for sc: Node3D in [_scudo_sic(Vector3(-0.08, 0.085, 0.06), 0.0, 1.0), _scudo_sic(Vector3(0.09, 0.08, 0.07), 10.0, 0.95)]:
		sc.rotation_degrees.x = -12
		n.add_child(sc)


# ------------------------------------------------------------------ edifici dei Siculi

## Casa dei Siculi: capanna ovale con lo zoccolo a secco e la cupola di canne, dispensa tonda accanto, focolare
## all'aperto con la pentola, macina a sella, giare dipinte, orto chiuso da muretti a secco.
static func casa_greca_siculi(seme := 1) -> Node3D:
	var r := Node3D.new()
	_capanna_sic(r, Vector3(-0.12, 0, -0.16), 0.5, 0.37, 0.46, seme)
	_capanna_sic(r, Vector3(-0.64, 0, 0.32), 0.16, 0.15, 0.24, seme + 7, 60.0, false, 1.4)
	# focolare con la pentola, macina, giare
	_fuoco(r, Vector3(0.22, 0, 0.36), 0.8)
	r.add_child(cilindro(0.04, 0.032, 0.05, Vector3(0.22, 0.07, 0.36), "terracotta", Vector3.ZERO, 10))
	r.add_child(cilindro(0.041, 0.041, 0.008, Vector3(0.22, 0.09, 0.36), "vernice_nera", Vector3.ZERO, 10))
	_fumo(r, Vector3(0.24, 0.16, 0.34), 3, 0.8)
	_macina_sella(r, Vector3(-0.3, 0, 0.42), 20.0)
	r.add_child(_giara(Vector3(0.05, 0, 0.36), 1.35, 0))
	r.add_child(_giara(Vector3(-0.02, 0, 0.46), 1.0, 1))
	r.add_child(_vaso_sic(Vector3(0.12, 0, 0.47), 1.0, 0))
	_fascina(r, Vector3(0.36, 0, -0.12), 80.0)
	legnaia(r, Vector3(0.38, 0, -0.32), 0.18, 3)
	# orto chiuso da muretti a secco, con fave e cavoli
	var o := Vector3(0.56, 0, 0.45)
	r.add_child(scatola(Vector3(0.34, 0.012, 0.38), o + Vector3(0, 0.006, 0), "terra"))
	var rng := _rng(seme + 19)
	for f in 4:
		for k in 5:
			r.add_child(sfera(rng.randf_range(0.02, 0.028), o + Vector3(-0.14 + k * 0.07, 0.025, -0.14 + f * 0.093), "orto" if f % 2 == 0 else "foglie_chiare", Vector3(1, 0.8, 1)))
	_muretto_secco(r, o + Vector3(-0.2, 0, 0.23), o + Vector3(0.21, 0, 0.23), 0.08, 0.07)
	_muretto_secco(r, o + Vector3(0.21, 0, -0.21), o + Vector3(0.21, 0, 0.23), 0.08, 0.07)
	return r


## Magazzino dei Siculi: grande capanna lunga ovale e un granaio tondo, cortile chiuso dal muro a secco con le file
## di grandi giare dipinte sotto la tettoia di canne, sacchi, ceste, asino col basto e l'insegna d'ocra.
static func magazzino_siculi() -> Node3D:
	var r := Node3D.new()
	r.position = Vector3(0, 0, -0.1)
	r.add_child(scatola(Vector3(2.0, 0.02, 1.6), Vector3(0, 0.01, 0.05), "terra"))
	_capanna_sic(r, Vector3(-0.18, 0, -0.36), 0.8, 0.44, 0.58, 31, 0.0, true, 1.3)
	_capanna_sic(r, Vector3(0.7, 0, -0.42), 0.28, 0.25, 0.46, 32, -30.0, true, 1.45)
	# muro a secco attorno al cortile, con l'ingresso davanti fra due lastroni
	_muretto_secco(r, Vector3(-0.98, 0, -0.62), Vector3(-0.98, 0, 0.82), 0.13, 0.1)
	_muretto_secco(r, Vector3(-0.98, 0, 0.82), Vector3(-0.2, 0, 0.82), 0.13, 0.1)
	_muretto_secco(r, Vector3(0.2, 0, 0.82), Vector3(0.98, 0, 0.82), 0.13, 0.1)
	_muretto_secco(r, Vector3(0.98, 0, 0.82), Vector3(0.98, 0, -0.2), 0.13, 0.1)
	for x: float in [-0.2, 0.2]:
		r.add_child(scatola(Vector3(0.1, 0.24, 0.12), Vector3(x, 0.12, 0.82), "roccia_chiara", Vector3(0, 0, 3 * signf(x))))
	# file di grandi giare dipinte nel cortile
	var gi := 0
	for j in 2:
		for i in 4:
			r.add_child(_giara(Vector3(-0.82 + i * 0.19 + j * 0.09, 0, 0.22 + j * 0.22), 1.85, gi))
			gi += 1
	# tettoia di canne sopra sacchi e ceste a destra
	_tettoia_sic(r, Vector3(0.66, 0, 0.22), 0.5, 0.34, 0.4, 0.32, 33)
	for i in 3:
		r.add_child(sacco(Vector3(0.5 + i * 0.12, 0, 0.16), i * 0.6))
	r.add_child(cesta(Vector3(0.82, 0, 0.32), "olive"))
	r.add_child(cesta(Vector3(0.7, 0, 0.32), "formaggio"))
	for i in 3:
		r.add_child(_giara(Vector3(0.48 + i * 0.15, 0, 0.55), 1.25, i + 1))
	r.add_child(_vaso_sic(Vector3(0.3, 0, 0.66), 1.25, 1))
	r.add_child(_vaso_sic(Vector3(0.38, 0, 0.72), 1.15, 2))
	# asino col basto e le ceste
	r.add_child(asino(Vector3(0.08, 0, 0.62), 70))
	r.add_child(cesta(Vector3(0.06, 0.11, 0.56), "olive", 0.7))
	r.add_child(cesta(Vector3(0.1, 0.11, 0.68), "olive", 0.7))
	_insegna_sic(r, Vector3(0.9, 0, 0.7), 0.78)
	return r


## Boscaiolo dei Siculi: capanna ovale, tettoia di canne sopra la legna spaccata, catasta di tronchi,
## ceppo con l'ascia, fascine di frasche e una giara.
static func boscaiolo_siculi() -> Node3D:
	var r := Node3D.new()
	_capanna_sic(r, Vector3(-0.15, 0, -0.18), 0.4, 0.31, 0.34, 41)
	_tettoia_sic(r, Vector3(0.42, 0, -0.18), 0.32, 0.5, 0.34, 0.26, 42)
	legnaia(r, Vector3(0.42, 0, -0.32), 0.28, 5)
	legnaia(r, Vector3(0.42, 0, -0.1), 0.28, 4)
	catasta_tronchi(r, Vector3(0.55, 0, 0.55), 4, 0.5)
	r.add_child(cilindro(0.07, 0.075, 0.09, Vector3(-0.2, 0.045, 0.5), "corteccia", Vector3.ZERO, 12))
	r.add_child(cilindro(0.066, 0.066, 0.006, Vector3(-0.2, 0.092, 0.5), "legno_chiaro", Vector3.ZERO, 12))
	r.add_child(cilindro(0.008, 0.008, 0.22, Vector3(-0.2, 0.18, 0.5), "legno", Vector3(0, 0, 22), 6))
	r.add_child(scatola(Vector3(0.055, 0.04, 0.012), Vector3(-0.245, 0.27, 0.5), "bronzo", Vector3(0, 0, 22)))
	for i in 6:
		r.add_child(cilindro(0.02, 0.02, 0.06, Vector3(-0.38 + i * 0.06, 0.02, 0.62 + (i % 2) * 0.05), "legno_chiaro", Vector3(0, i * 37, 90), 6))
	_fascina(r, Vector3(-0.62, 0, 0.35), 20.0)
	_fascina(r, Vector3(-0.55, 0, 0.45), 35.0)
	r.add_child(_giara(Vector3(0.1, 0, 0.32), 1.2, 0))
	for pos: Vector3 in [Vector3(-0.72, 0, 0.0), Vector3(-0.6, 0, 0.75)]:
		r.add_child(cilindro(0.06, 0.07, 0.05, pos + Vector3(0, 0.025, 0), "corteccia", Vector3.ZERO, 10))
		r.add_child(cilindro(0.056, 0.056, 0.005, pos + Vector3(0, 0.052, 0), "legno_chiaro", Vector3.ZERO, 10))
	return r


## Segheria dei Siculi: capanna ovale, tettoia di canne e frasche sopra il tronco sui cavalletti con la sega a telaio,
## pile di assi, cunei e mazzuolo, catasta di tronchi.
static func segheria_siculi() -> Node3D:
	var r := Node3D.new()
	_capanna_sic(r, Vector3(-0.2, 0, -0.27), 0.42, 0.31, 0.38, 51)
	var t := Vector3(0.05, 0, 0.5)
	_tettoia_sic(r, t, 0.9, 0.44, 0.42, 0.34, 52)
	for px: float in [-0.25, 0.0, 0.25]:
		r.add_child(scatola(Vector3(0.03, 0.12, 0.12), t + Vector3(px, 0.06, 0.0), "legno"))
	r.add_child(cilindro(0.055, 0.055, 0.8, t + Vector3(0, 0.17, 0.0), "corteccia", Vector3(0, 0, 90), 9))
	r.add_child(cilindro(0.047, 0.047, 0.805, t + Vector3(0, 0.17, 0.0), "legno_chiaro", Vector3(0, 0, 90), 9))
	for z: float in [-0.08, 0.08]:
		r.add_child(scatola(Vector3(0.014, 0.3, 0.014), t + Vector3(0.1, 0.24, z), "legno"))
	r.add_child(scatola(Vector3(0.014, 0.014, 0.18), t + Vector3(0.1, 0.38, 0.0), "legno"))
	r.add_child(scatola(Vector3(0.006, 0.006, 0.17), t + Vector3(0.1, 0.2, 0.0), "bronzo"))
	r.add_child(cilindro(0.2, 0.2, 0.004, t + Vector3(0.1, 0.002, 0.0), "legno_chiaro", Vector3.ZERO, 16))
	# cunei e mazzuolo accanto al tronco
	for k in 3:
		r.add_child(scatola(Vector3(0.03, 0.02, 0.05), t + Vector3(-0.35 + k * 0.05, 0.01, 0.17), "legno_scuro", Vector3(0, k * 30, 0)))
	r.add_child(cilindro(0.025, 0.025, 0.07, t + Vector3(-0.2, 0.025, 0.18), "legno", Vector3(0, 30, 90), 8))
	pila_assi(r, Vector3(0.62, 0, -0.25), 8, 90)
	pila_assi(r, Vector3(0.62, 0, 0.12), 5, 90)
	catasta_tronchi(r, Vector3(-0.65, 0, 0.55), 3, 0.42)
	r.add_child(_giara(Vector3(0.4, 0, 0.85), 1.1, 1))
	_fascina(r, Vector3(0.2, 0, 0.85), 70.0)
	return r


## Cava dei Siculi: capanna piccola, parete di calcare chiaro con le tombe a grotticella scavate, blocchi grezzi
## squadrati, leva di legno, ceste di pietrame e slitta di tronchi.
static func cava_siculi() -> Node3D:
	var r := Node3D.new()
	_capanna_sic(r, Vector3(-0.38, 0, -0.32), 0.32, 0.27, 0.32, 61)
	var rng := _rng(61)
	for k in 9:
		var p := Vector3(0.35 + rng.randf_range(-0.2, 0.2), 0.0, -0.4 + rng.randf_range(-0.15, 0.2))
		var d := rng.randf_range(0.16, 0.3)
		r.add_child(scatola(Vector3(d, d * rng.randf_range(0.7, 1.4), d * 0.8), p + Vector3(0, d * 0.4, 0), "tufo" if k % 3 != 0 else "roccia_massi", Vector3(0, rng.randf() * 60, 0)))
	# parete principale con le grotticelle (porte quadrate scure scavate nel calcare)
	r.add_child(scatola(Vector3(0.5, 0.36, 0.24), Vector3(0.3, 0.18, -0.36), "tufo", Vector3(0, -8, 0)))
	for g: Vector3 in [Vector3(0.18, 0.2, -0.235), Vector3(0.36, 0.12, -0.21), Vector3(0.45, 0.27, -0.225)]:
		r.add_child(scatola(Vector3(0.065, 0.06, 0.02), g, "buio", Vector3(0, -8, 0)))
		r.add_child(scatola(Vector3(0.085, 0.012, 0.024), g + Vector3(0, -0.036, 0.002), "pietra_secca", Vector3(0, -8, 0)))
	# blocchi grezzi pronti
	for i in 4:
		for j in 2 - (i / 3):
			r.add_child(scatola(Vector3(0.13, 0.09, 0.09), Vector3(-0.1 + i * 0.15, 0.045 + j * 0.09, 0.45), "tufo", Vector3(0, i * 5 - 6, 0)))
	# leva di legno sotto un blocco, ceste di pietrame
	r.add_child(scatola(Vector3(0.14, 0.1, 0.1), Vector3(0.55, 0.05, 0.1), "tufo", Vector3(0, 20, 6)))
	ramo(r, Vector3(0.5, 0.02, 0.18), Vector3(0.78, 0.2, 0.32), 0.01, "legno")
	r.add_child(sfera(0.025, Vector3(0.52, 0.02, 0.22), "roccia_massi", Vector3(1.2, 0.8, 1)))
	for k in 2:
		var cp := Vector3(-0.55 + k * 0.13, 0, 0.3 + k * 0.08)
		r.add_child(cilindro(0.065, 0.055, 0.06, cp + Vector3(0, 0.03, 0), "canne_sic", Vector3.ZERO, 12))
		r.add_child(mucchio(cp + Vector3(0, 0.03, 0), "tufo", 5, 7 + k, 0.025))
	# slitta di tronchi con un blocco
	for lato: int in [-1, 1]:
		r.add_child(cilindro(0.018, 0.018, 0.34, Vector3(-0.42, 0.018, 0.62 + lato * 0.06), "corteccia", Vector3(0, 0, 90), 6))
	r.add_child(scatola(Vector3(0.26, 0.02, 0.16), Vector3(-0.42, 0.045, 0.62), "legno_vecchio"))
	r.add_child(scatola(Vector3(0.12, 0.08, 0.09), Vector3(-0.42, 0.095, 0.62), "tufo"))
	ramo(r, Vector3(-0.27, 0.02, 0.62), Vector3(-0.1, 0.06, 0.66), 0.004, "corda")
	r.add_child(_giara(Vector3(-0.15, 0, 0.2), 1.0, 0))
	return r


## Guardaboschi dei Siculi: capanna ovale, vivaio di querce e olivastri giovani in file dentro il muretto a secco,
## giara d'acqua, zappa e sacchi di ghiande.
static func guardaboschi_siculi() -> Node3D:
	var r := Node3D.new()
	_capanna_sic(r, Vector3(-0.32, 0, -0.32), 0.33, 0.26, 0.3, 71)
	for i in 4:
		for j in 3:
			var p := Vector3(-0.1 + i * 0.16, 0, 0.3 + j * 0.15)
			r.add_child(cilindro(0.05, 0.05, 0.012, p + Vector3(0, 0.006, 0), "terra", Vector3.ZERO, 10))
			r.add_child(cilindro(0.006, 0.006, 0.06 + j * 0.02, p + Vector3(0, 0.03, 0), "corteccia", Vector3.ZERO, 5))
			r.add_child(sfera(0.035 + j * 0.008, p + Vector3(0, 0.08 + j * 0.03, 0), "foglie_ulivo" if (i + j) % 2 == 0 else "foglie", Vector3(1, 0.85, 1)))
	_muretto_secco(r, Vector3(-0.2, 0, 0.75), Vector3(0.52, 0, 0.75), 0.08, 0.07)
	_muretto_secco(r, Vector3(0.52, 0, 0.2), Vector3(0.52, 0, 0.75), 0.08, 0.07)
	r.add_child(_giara(Vector3(0.3, 0, -0.18), 1.2, 1))
	r.add_child(_vaso_sic(Vector3(0.42, 0, -0.1), 1.0, 1))
	r.add_child(cilindro(0.007, 0.007, 0.22, Vector3(0.2, 0.11, -0.3), "legno", Vector3(12, 0, -15), 5))
	r.add_child(scatola(Vector3(0.05, 0.012, 0.04), Vector3(0.23, 0.01, -0.28), "bronzo", Vector3(0, 0, -15)))
	r.add_child(sacco(Vector3(-0.58, 0, 0.3), 0.4))
	r.add_child(sacco(Vector3(-0.62, 0, 0.42), -0.2))
	r.add_child(quercia(43))
	r.get_child(r.get_child_count() - 1).position = Vector3(0.55, 0, -0.55)
	r.get_child(r.get_child_count() - 1).scale = Vector3.ONE * 0.6
	return r


## Pozzo dei Siculi: vera tonda di pietra a secco, pertica a bilanciere (con il contrappeso di pietra legato) su un palo
## a forcella, giara appesa alla corda, abbeveratoio di pietra e giara dipinta.
static func pozzo_siculi() -> Node3D:
	var r := Node3D.new()
	r.add_child(cilindro(0.2, 0.22, 0.17, Vector3(0, 0.085, 0), "pietra_secca", Vector3.ZERO, 18))
	r.add_child(cilindro(0.15, 0.15, 0.005, Vector3(0, 0.168, 0), "acqua_pozzo", Vector3.ZERO, 18))
	for k in 12:
		var a := k * TAU / 12
		r.add_child(sfera(0.045, Vector3(cos(a) * 0.18, 0.175, sin(a) * 0.18), "roccia_chiara" if k % 3 == 0 else "pietra_secca", Vector3(1.2, 0.5, 1.0)))
	# palo a forcella piantato fra i sassi e pertica a bilanciere (in vista di traverso)
	var pz := Vector3(-0.24, 0, 0.22)
	r.add_child(cilindro(0.024, 0.028, 0.44, pz + Vector3(0, 0.22, 0), "corteccia", Vector3.ZERO, 7))
	ramo(r, pz + Vector3(0, 0.42, 0), pz + Vector3(0.03, 0.5, 0.03), 0.013)
	ramo(r, pz + Vector3(0, 0.42, 0), pz + Vector3(-0.03, 0.5, -0.03), 0.013)
	r.add_child(cilindro(0.006, 0.006, 0.1, pz + Vector3(0, 0.46, 0), "ferro", Vector3(90, 45, 0), 4))
	for k in 4:
		r.add_child(sfera(0.042, pz + Vector3(cos(k * 1.6) * 0.055, 0.02, sin(k * 1.6) * 0.055), "roccia_chiara" if k % 2 == 0 else "pietra_secca", Vector3(1.2, 0.6, 1)))
	var testa := Vector3(0.04, 0.62, -0.06)
	var coda := Vector3(-0.47, 0.3, 0.45)
	ramo(r, coda, testa, 0.014, "legno")
	# contrappeso: grosso sasso legato con la corda
	r.add_child(sfera(0.055, coda + Vector3(0.0, -0.045, 0.0), "roccia_massi", Vector3(1.1, 0.9, 1)))
	r.add_child(_toro(0.035, 0.046, coda + Vector3(0, -0.03, 0), "corda", Vector3(0, 0, 20)))
	# corda e giara appesa sopra l'acqua
	r.add_child(cilindro(0.003, 0.003, 0.3, testa + Vector3(0, -0.15, 0), "corda", Vector3.ZERO, 4))
	r.add_child(_vaso_sic(testa + Vector3(0, -0.39, 0), 1.1, 2))
	# abbeveratoio di pietra, giare, sedile
	r.add_child(scatola(Vector3(0.24, 0.06, 0.1), Vector3(0.26, 0.03, 0.2), "roccia_chiara", Vector3(0, -40, 0)))
	r.add_child(scatola(Vector3(0.2, 0.005, 0.07), Vector3(0.26, 0.061, 0.2), "acqua_pozzo", Vector3(0, -40, 0)))
	r.add_child(_giara(Vector3(0.24, 0, -0.18), 1.2, 0))
	r.add_child(_giara(Vector3(0.05, 0, 0.3), 1.0, 1))
	r.add_child(_vaso_sic(Vector3(0.14, 0, 0.36), 0.9, 1))
	r.add_child(sfera(0.06, Vector3(-0.3, 0.02, -0.12), "roccia_chiara", Vector3(1.3, 0.6, 1)))
	r.scale = Vector3.ONE * 1.2
	return r


## Fattoria dei Siculi: capanna ovale, granaio tondo d'argilla su un basamento di pietre, aia lastricata con i covoni,
## campicello di grano, muretti a secco, asino, galline e giare.
static func fattoria_siculi() -> Node3D:
	var r := Node3D.new()
	_capanna_sic(r, Vector3(-0.2, 0, -0.24), 0.4, 0.3, 0.34, 81)
	# granaio: silo d'argilla su un basamento di pietra con il tappo di canne
	var g := Vector3(0.75, 0, -0.25)
	r.add_child(cilindro(0.2, 0.22, 0.08, g + Vector3(0, 0.04, 0), "pietra_secca", Vector3.ZERO, 16))
	r.add_child(cilindro(0.15, 0.17, 0.26, g + Vector3(0, 0.21, 0), "argilla_sic", Vector3.ZERO, 16))
	r.add_child(cilindro(0.172, 0.172, 0.03, g + Vector3(0, 0.27, 0), "vernice_rossa", Vector3.ZERO, 16))
	r.add_child(cilindro(0.2, 0.03, 0.18, g + Vector3(0, 0.43, 0), "canne_sic", Vector3.ZERO, 16))
	r.add_child(_toro(0.15, 0.165, g + Vector3(0, 0.375, 0), "corda"))
	r.add_child(scatola(Vector3(0.07, 0.08, 0.02), g + Vector3(0.0, 0.2, 0.16), "legno_scuro"))
	# aia tonda lastricata con i covoni
	var a := Vector3(-0.35, 0, 0.5)
	r.add_child(cilindro(0.26, 0.27, 0.02, a + Vector3(0, 0.01, 0), "roccia_chiara", Vector3.ZERO, 20))
	r.add_child(cilindro(0.22, 0.22, 0.005, a + Vector3(0, 0.022, 0), "paglia", Vector3.ZERO, 20))
	for i in 4:
		var cv := covone(1.15)
		cv.position = a + Vector3(-0.15 + i * 0.1, 0.02, -0.05 + (i % 2) * 0.1)
		cv.rotation_degrees.z = 8 * (i % 2 * 2 - 1)
		r.add_child(cv)
	# campicello di grano maturo chiuso dal muretto
	var c := Vector3(0.45, 0, 0.45)
	r.add_child(scatola(Vector3(0.42, 0.012, 0.36), c + Vector3(0, 0.006, 0), "terra"))
	for i in 7:
		for j in 5:
			r.add_child(cilindro(0.012, 0.016, 0.1, c + Vector3(-0.18 + i * 0.06, 0.05, -0.14 + j * 0.07), "grano", Vector3.ZERO, 5))
	_muretto_secco(r, c + Vector3(-0.23, 0, 0.21), c + Vector3(0.25, 0, 0.21), 0.07, 0.06)
	_muretto_secco(r, c + Vector3(0.25, 0, -0.2), c + Vector3(0.25, 0, 0.21), 0.07, 0.06)
	r.add_child(asino(Vector3(0.18, 0, 0.0), 120))
	for i in 3:
		r.add_child(sfera(0.025, Vector3(0.05 + i * 0.07, 0.03, 0.22 - i * 0.03), "intonaco", Vector3(1.3, 1, 1)))
		r.add_child(sfera(0.008, Vector3(0.08 + i * 0.07, 0.05, 0.22 - i * 0.03), "geranio"))
	r.add_child(_giara(Vector3(-0.7, 0, 0.1), 1.2, 1))
	r.add_child(sacco(Vector3(0.48, 0, 0.0), 0.3))
	r.add_child(sacco(Vector3(0.56, 0, 0.06), -0.4))
	return r


## Mulino dei Siculi: capanna ovale; sotto la tettoia di canne la macina tonda di pietra girata dall'asino,
## accanto le macine a sella delle donne, sacchi di farina e giare.
static func mulino_siculi() -> Node3D:
	var r := Node3D.new()
	_capanna_sic(r, Vector3(-0.22, 0, -0.27), 0.38, 0.29, 0.38, 91)
	var m := Vector3(-0.3, 0, 0.5)
	r.add_child(cilindro(0.2, 0.22, 0.06, m + Vector3(0, 0.03, 0), "pietra_secca", Vector3.ZERO, 20))
	r.add_child(cilindro(0.17, 0.17, 0.005, m + Vector3(0, 0.061, 0), "lino", Vector3.ZERO, 20))
	r.add_child(cilindro(0.025, 0.025, 0.24, m + Vector3(0, 0.15, 0), "legno", Vector3.ZERO, 8))
	r.add_child(cilindro(0.11, 0.11, 0.07, m + Vector3(0.07, 0.16, 0), "roccia_chiara", Vector3(0, 0, 90), 18))
	r.add_child(scatola(Vector3(0.5, 0.025, 0.025), m + Vector3(0.16, 0.25, 0), "legno_vecchio"))
	r.add_child(asino(m + Vector3(0.38, 0, 0.0), 90))
	_tettoia_sic(r, m + Vector3(0, 0, -0.2), 0.56, 0.3, 0.46, 0.4, 92)
	_macina_sella(r, Vector3(0.12, 0, 0.66), 30.0)
	_macina_sella(r, Vector3(0.3, 0, 0.58), 10.0)
	for i in 5:
		r.add_child(sacco(Vector3(0.45 + (i % 3) * 0.12, 0.0, -0.1 + (i / 3) * 0.13), i * 0.7))
	var cv := covone(1.1)
	cv.position = Vector3(0.6, 0, 0.42)
	r.add_child(cv)
	r.add_child(_giara(Vector3(0.36, 0, 0.3), 1.2, 0))
	return r


## Forno dei Siculi: capanna ovale, grande forno a cupola d'argilla con la fascia rossa, la bocca accesa e il fumo,
## lastra di pietra con le focacce, fascine, ceste di pane, sacchi e giare d'acqua.
static func forno_siculi() -> Node3D:
	var r := Node3D.new()
	_capanna_sic(r, Vector3(-0.22, 0, -0.27), 0.38, 0.29, 0.36, 101)
	_forno_sic(r, Vector3(0.45, 0, 0.4), 1.25)
	_fascina(r, Vector3(0.75, 0, 0.15), 10.0)
	_fascina(r, Vector3(0.68, 0, 0.05), 25.0)
	# lastra di pietra su due sassi con le focacce
	r.add_child(scatola(Vector3(0.32, 0.03, 0.15), Vector3(-0.3, 0.1, 0.55), "roccia_chiara"))
	for lato: int in [-1, 1]:
		r.add_child(sfera(0.05, Vector3(-0.3 + lato * 0.11, 0.04, 0.55), "pietra_secca", Vector3(1, 1.1, 1.2)))
	for i in 5:
		r.add_child(sfera(0.03, Vector3(-0.42 + i * 0.06, 0.125, 0.55 + (i % 2) * 0.03), "pane", Vector3(1, 0.45, 1)))
	r.add_child(cesta(Vector3(-0.62, 0, 0.42), "pane"))
	r.add_child(cesta(Vector3(0.05, 0, 0.66), "pane"))
	r.add_child(sacco(Vector3(-0.68, 0, 0.15), 0.4))
	r.add_child(_giara(Vector3(0.12, 0, 0.36), 1.2, 1))
	r.add_child(_vaso_sic(Vector3(0.2, 0, 0.47), 1.0, 1))
	return r


## Ovile dei Siculi: capanna ovale bassa, stazzo tondo di pietra a secco con le pecore, abbeveratoio di pietra,
## bastone del pastore, lana tosata e giara del latte.
static func ovile_siculi() -> Node3D:
	var r := Node3D.new()
	_capanna_sic(r, Vector3(-0.36, 0, -0.36), 0.36, 0.28, 0.32, 111)
	var a := Vector3(0.18, 0, 0.18)
	var np := 10
	for k in np:
		var a0 := deg_to_rad(-150.0 + k * 30.0)
		var a1 := deg_to_rad(-150.0 + (k + 1) * 30.0)
		if k == 6:
			continue
		_muretto_secco(r, a + Vector3(cos(a0), 0, sin(a0)) * 0.42, a + Vector3(cos(a1), 0, sin(a1)) * 0.42, 0.09, 0.07)
	for p: Array in [[Vector3(0.0, 0, 0.1), 30], [Vector3(0.15, 0, -0.1), 160], [Vector3(0.2, 0, 0.18), -40],
			[Vector3(-0.15, 0, 0.18), 90], [Vector3(0.05, 0, -0.22), 210]]:
		r.add_child(pecora(a + p[0], p[1]))
	r.add_child(scatola(Vector3(0.22, 0.05, 0.07), a + Vector3(-0.15, 0.025, -0.1), "roccia_chiara", Vector3(0, 30, 0)))
	r.add_child(scatola(Vector3(0.18, 0.005, 0.04), a + Vector3(-0.15, 0.051, -0.1), "acqua_pozzo", Vector3(0, 30, 0)))
	r.add_child(cilindro(0.007, 0.006, 0.36, Vector3(-0.05, 0.17, -0.02), "legno", Vector3(0, 0, -10), 5))
	r.add_child(_toro(0.012, 0.02, Vector3(-0.08, 0.35, -0.02), "legno", Vector3(90, 0, 0)))
	r.add_child(sfera(0.06, Vector3(-0.6, 0.04, 0.3), "lana", Vector3(1.2, 0.6, 1.0)))
	r.add_child(sfera(0.05, Vector3(-0.52, 0.035, 0.4), "lana", Vector3(1.2, 0.6, 1.0)))
	r.add_child(_giara(Vector3(-0.7, 0, 0.1), 1.1, 0))
	return r


## Capraio dei Siculi: capanna ovale, rocce calcaree con le capre, muretto a secco, graticcio di canne con i formaggi
## a stagionare, giara del latte.
static func capraio_siculi() -> Node3D:
	var r := Node3D.new()
	_capanna_sic(r, Vector3(-0.32, 0, -0.32), 0.3, 0.24, 0.26, 121)
	var a := Vector3(0.15, 0, 0.15)
	r.add_child(sfera(0.16, a + Vector3(0.2, 0.0, -0.1), "roccia_chiara", Vector3(1.2, 0.85, 1.0)))
	r.add_child(sfera(0.1, a + Vector3(-0.05, 0.0, 0.3), "roccia_chiara", Vector3(1.3, 0.7, 1.0)))
	r.add_child(sfera(0.07, a + Vector3(0.38, 0.0, 0.1), "roccia_massi", Vector3(1.3, 0.8, 1.0)))
	r.add_child(capra(a + Vector3(0.2, 0.12, -0.1), 40))
	r.add_child(capra(a + Vector3(0.0, 0, 0.1), 200))
	r.add_child(capra(a + Vector3(0.35, 0, 0.3), -30))
	r.add_child(capra(a + Vector3(-0.1, 0.06, 0.3), 110))
	_muretto_secco(r, a + Vector3(-0.4, 0, 0.52), a + Vector3(0.5, 0, 0.52), 0.08, 0.07)
	# graticcio dei formaggi su quattro pali
	var f := Vector3(-0.62, 0, 0.3)
	for x: float in [-0.08, 0.08]:
		for z: float in [-0.06, 0.06]:
			r.add_child(cilindro(0.008, 0.008, 0.16, f + Vector3(x, 0.08, z), "corteccia", Vector3.ZERO, 5))
	r.add_child(scatola(Vector3(0.2, 0.012, 0.16), f + Vector3(0, 0.16, 0), "canne_sic"))
	for k in 4:
		r.add_child(cilindro(0.025, 0.025, 0.024, f + Vector3(-0.055 + (k % 2) * 0.1, 0.178, -0.035 + (k / 2) * 0.07), "formaggio", Vector3.ZERO, 10))
	r.add_child(_giara(Vector3(-0.42, 0, 0.5), 1.1, 1))
	return r


## Caserma dei Siculi: capanna ovale grande con l'insegna d'ocra, campo d'addestramento con il fantoccio di paglia
## e lo scudo dipinto, rastrelliera di lance e due guerrieri che si esercitano.
static func caserma_siculi() -> Node3D:
	var r := Node3D.new()
	_capanna_sic(r, Vector3(-0.3, 0, -0.3), 0.35, 0.28, 0.36, 131)
	_insegna_sic(r, Vector3(0.1, 0, -0.12), 0.7)
	r.add_child(scatola(Vector3(0.75, 0.01, 0.55), Vector3(0.25, 0.005, 0.4), "terra"))
	# fantoccio di paglia con lo scudo
	var fp := Vector3(0.5, 0, 0.32)
	r.add_child(cilindro(0.02, 0.022, 0.36, fp + Vector3(0, 0.18, 0), "legno_vecchio", Vector3.ZERO, 7))
	r.add_child(cilindro(0.008, 0.008, 0.2, fp + Vector3(0, 0.27, 0), "legno_vecchio", Vector3(0, 0, 90), 5))
	r.add_child(cilindro(0.045, 0.04, 0.14, fp + Vector3(0, 0.25, 0), "paglia", Vector3.ZERO, 10))
	r.add_child(sfera(0.035, fp + Vector3(0, 0.355, 0), "paglia"))
	r.add_child(_scudo_sic(fp + Vector3(0.0, 0.24, 0.06), 0.0, 0.9))
	for k in 2:
		var o := guerriero_siculo()
		o.position = Vector3(0.05 + k * 0.28, 0, 0.55 - k * 0.15)
		o.rotation_degrees.y = 150 - k * 60
		o.scale = Vector3.ONE * 0.95
		r.add_child(o)
	_rastrelliera_sic(r, Vector3(-0.6, 0, 0.4), 30.0)
	r.add_child(_giara(Vector3(-0.68, 0, 0.12), 1.0, 0))
	return r


## Torre di guardia dei Siculi: fusto tondo di pietra a secco che si restringe, fasce di legno, porta alta con la scala
## a pioli, piattaforma di tavole con il parapetto di canne e il tettuccio a cono di canne, insegna d'ocra,
## giare, scudi e lance alla base.
static func torre_siculi() -> Node3D:
	var r := Node3D.new()
	var h := 1.0
	r.add_child(cilindro(0.38, 0.4, 0.06, Vector3(0, 0.03, 0), "roccia_chiara", Vector3.ZERO, 20))
	r.add_child(cilindro(0.29, 0.34, h, Vector3(0, 0.06 + h * 0.5, 0), "pietra_secca", Vector3.ZERO, 22))
	var rng := _rng(141)
	for k in 46:
		var a := deg_to_rad(rng.randf_range(-60.0, 150.0))
		var y := rng.randf_range(0.1, h)
		var rr := lerpf(0.34, 0.29, (y - 0.06) / h) + 0.004
		var p := sfera(rng.randf_range(0.024, 0.034), Vector3(sin(a), 0, cos(a)) * rr + Vector3(0, y, 0), "roccia_chiara" if k % 3 == 0 else "pietra_secca", Vector3(1.4, 0.7, 0.45))
		p.rotation.y = a
		r.add_child(p)
	for y: float in [0.42, 0.78]:
		var rr := lerpf(0.34, 0.29, (y - 0.06) / h) + 0.006
		r.add_child(cilindro(rr, rr, 0.03, Vector3(0, y, 0), "legno_vecchio", Vector3.ZERO, 22))
	for y: float in [0.6, 0.95]:
		r.add_child(scatola(Vector3(0.03, 0.08, 0.04), Vector3(0, y, 0.31), "buio"))
		r.add_child(scatola(Vector3(0.04, 0.08, 0.03), Vector3(0.31, y, 0), "buio"))
	# porta alta e scala a pioli
	_porta_sic(r, Vector3(-0.134, 0.3, 0.323), -22.5, 0.11, 0.18)
	for lato: int in [-1, 1]:
		ramo(r, Vector3(-0.12 + lato * 0.04, 0, 0.62), Vector3(-0.15 + lato * 0.04, 0.32, 0.36), 0.009, "legno_vecchio")
	for k in 5:
		var t := (k + 1) / 6.0
		r.add_child(scatola(Vector3(0.09, 0.008, 0.008), Vector3(-0.12 - 0.03 * t, 0.32 * t, 0.62 - 0.26 * t), "legno"))
	# piattaforma, parapetto di canne, tettuccio
	var top := 0.06 + h
	r.add_child(cilindro(0.37, 0.37, 0.04, Vector3(0, top + 0.02, 0), "legno", Vector3.ZERO, 22))
	for k in 12:
		var a := k * TAU / 12
		r.add_child(scatola(Vector3(0.035, 0.03, 0.1), Vector3(sin(a), 0, cos(a)) * 0.31 + Vector3(0, top - 0.012, 0), "legno_scuro", Vector3(0, rad_to_deg(a), 0)))
	r.add_child(cilindro(0.355, 0.355, 0.12, Vector3(0, top + 0.1, 0), "canne_sic", Vector3.ZERO, 22))
	r.add_child(_toro(0.35, 0.365, Vector3(0, top + 0.1, 0), "corda"))
	r.add_child(_toro(0.35, 0.368, Vector3(0, top + 0.155, 0), "vernice_rossa", Vector3.ZERO, Vector3(1, 0.8, 1)))
	for x: float in [-0.2, 0.2]:
		for z: float in [-0.2, 0.2]:
			r.add_child(cilindro(0.012, 0.012, 0.3, Vector3(x, top + 0.19, z), "corteccia", Vector3.ZERO, 5))
	r.add_child(cilindro(0.34, 0.06, 0.26, Vector3(0, top + 0.47, 0), "canne_sic", Vector3.ZERO, 20))
	for k in 14:
		var a := k * TAU / 14
		var ci := sfera(0.03, Vector3(sin(a), 0, cos(a)) * 0.33 + Vector3(0, top + 0.345, 0), "frasche" if k % 3 == 0 else "canne_sic", Vector3(1.1, 0.5, 0.8))
		ci.rotation.y = a
		r.add_child(ci)
	r.add_child(_toro(0.16, 0.175, Vector3(0, top + 0.5, 0), "corda"))
	r.add_child(cilindro(0.04, 0.03, 0.05, Vector3(0, top + 0.62, 0), "ceramica", Vector3.ZERO, 10))
	r.add_child(cilindro(0.041, 0.041, 0.014, Vector3(0, top + 0.62, 0), "vernice_rossa", Vector3.ZERO, 10))
	_insegna_sic(r, Vector3(0.18, top + 0.04, 0.18), 0.66)
	# alla base: giare, scudi e lance
	r.add_child(_giara(Vector3(0.42, 0, 0.18), 1.2, 0))
	r.add_child(_giara(Vector3(0.44, 0, 0.0), 1.0, 1))
	var sc := _scudo_sic(Vector3(0.2, 0.085, 0.38), 20.0, 0.95)
	sc.rotation_degrees.x = -14
	r.add_child(sc)
	for k in 3:
		r.add_child(cilindro(0.005, 0.005, 0.36, Vector3(0.1 + k * 0.04, 0.18, 0.4), "legno", Vector3(-12, 0, 0), 5))
		r.add_child(cilindro(0.011, 0.0, 0.04, Vector3(0.1 + k * 0.04, 0.37, 0.36), "bronzo", Vector3(-12, 0, 0), 5))
	return r


## Villaggio fortificato dei Siculi (castello 3x3): altura di calcare con le tombe a grotticella sui fianchi, cinta ovale
## di pietra a secco con i bastioni tondi e la porta fra due torri, rampa d'accesso; dentro la casa del principe
## (anaktoron) di grandi blocchi squadrati, capanne ovali, giare, recinto con le pecore e insegne d'ocra rossa.
static func castello_siculi() -> Node3D:
	var r := Node3D.new()
	var rng := _rng(151)
	var hc := 0.28
	# altura rocciosa con il prato in cima
	r.add_child(cilindro(1.6, 1.42, hc, Vector3(0, hc * 0.5, 0), "roccia_massi", Vector3.ZERO, 32))
	r.add_child(cilindro(1.43, 1.43, 0.012, Vector3(0, hc + 0.004, 0), "prato", Vector3.ZERO, 32))
	for k in 40:
		var a := deg_to_rad(rng.randf_range(-80.0, 170.0))
		var rr := rng.randf_range(1.48, 1.6)
		r.add_child(_masso(Vector3(sin(a) * rr, 0.0, cos(a) * rr), rng.randf_range(0.08, 0.14), Vector3(1.3, rng.randf_range(1.0, 2.2), 1.0), "roccia_chiara" if k % 3 != 0 else "pietra_secca", rng.randf() * 90))
	for k in 14:
		var a := deg_to_rad(rng.randf_range(-80.0, 170.0))
		r.add_child(sfera(rng.randf_range(0.05, 0.08), Vector3(sin(a), 0, cos(a)) * 1.44 + Vector3(0, hc, 0), "macchia", Vector3(1.3, 0.6, 1.0)))
	# tombe a grotticella scavate nei fianchi
	for k in 9:
		var a := deg_to_rad(-70.0 + k * 20.0)
		if k == 5:
			continue
		var d := Vector3(sin(a), 0, cos(a))
		var y := 0.11 + (k % 2) * 0.06
		var rr := 1.6 - y / hc * 0.18
		r.add_child(scatola(Vector3(0.08, 0.07, 0.04), d * rr + Vector3(0, y, 0), "buio", Vector3(0, rad_to_deg(a), 0)))
		r.add_child(scatola(Vector3(0.1, 0.014, 0.03), d * (rr + 0.012) + Vector3(0, y - 0.042, 0), "roccia_chiara", Vector3(0, rad_to_deg(a), 0)))
	# cinta tonda di pietra a secco, interrotta dalla porta
	var cx := 1.2
	var nseg := 24
	var hm := 0.3
	for k in nseg:
		if k == 1:
			continue
		var a0 := k * TAU / nseg
		var a1 := (k + 1) * TAU / nseg
		_muretto_secco(r, Vector3(sin(a0) * cx, hc, cos(a0) * cx), Vector3(sin(a1) * cx, hc, cos(a1) * cx), hm, 0.14)
	var porta_a := 1.5 * TAU / nseg
	var dir := Vector3(sin(porta_a), 0, cos(porta_a))
	var pp := dir * cx + Vector3(0, hc, 0)
	# bastioni tondi; quello dietro è un'alta torre di guardia col tettuccio di canne
	for b in 4:
		var aa := porta_a + (b + 1) * TAU / 5.0
		var bp := Vector3(sin(aa) * cx, hc, cos(aa) * cx)
		var hb := 0.85 if b == 1 else 0.42
		r.add_child(cilindro(0.18, 0.22, hb, bp + Vector3(0, hb * 0.5, 0), "pietra_secca", Vector3.ZERO, 18))
		r.add_child(cilindro(0.19, 0.19, 0.03, bp + Vector3(0, hb + 0.01, 0), "legno_vecchio", Vector3.ZERO, 18))
		for j in 9:
			var aj := j * TAU / 9
			r.add_child(sfera(0.045, bp + Vector3(cos(aj) * 0.16, hb + 0.03, sin(aj) * 0.16), "roccia_chiara" if j % 2 == 0 else "pietra_secca", Vector3(1.1, 0.7, 1.0)))
		if b == 1:
			for x: float in [-0.1, 0.1]:
				for z: float in [-0.1, 0.1]:
					r.add_child(cilindro(0.01, 0.01, 0.22, bp + Vector3(x, hb + 0.13, z), "corteccia", Vector3.ZERO, 5))
			r.add_child(cilindro(0.22, 0.04, 0.24, bp + Vector3(0, hb + 0.34, 0), "canne_sic", Vector3.ZERO, 16))
			r.add_child(_toro(0.12, 0.135, bp + Vector3(0, hb + 0.36, 0), "corda"))
			r.add_child(scatola(Vector3(0.04, 0.09, 0.03), bp + Vector3(0, hb * 0.6, 0.2), "buio"))
			_insegna_sic(r, bp + Vector3(0.12, hb + 0.04, 0.12), 0.6)
	# porta fra due torri con il tettuccio di canne, trave e battenti aperti
	var tang := Vector3(cos(porta_a), 0, -sin(porta_a))
	for lato: int in [-1, 1]:
		var tp := pp + tang * lato * 0.24
		r.add_child(cilindro(0.15, 0.18, 0.52, tp + Vector3(0, 0.26, 0), "pietra_secca", Vector3.ZERO, 16))
		r.add_child(cilindro(0.16, 0.16, 0.035, tp + Vector3(0, 0.53, 0), "vernice_rossa", Vector3.ZERO, 16))
		r.add_child(cilindro(0.19, 0.035, 0.22, tp + Vector3(0, 0.66, 0), "canne_sic", Vector3.ZERO, 14))
		r.add_child(_toro(0.14, 0.155, tp + Vector3(0, 0.6, 0), "corda"))
	var rotp := rad_to_deg(porta_a)
	var nb := Node3D.new()
	nb.position = pp
	nb.rotation_degrees.y = rotp
	r.add_child(nb)
	nb.add_child(scatola(Vector3(0.36, 0.06, 0.12), Vector3(0, 0.34, 0), "legno_scuro"))
	nb.add_child(scatola(Vector3(0.2, 0.31, 0.04), Vector3(0, 0.155, -0.07), "buio"))
	for lato: int in [-1, 1]:
		nb.add_child(scatola(Vector3(0.1, 0.29, 0.02), Vector3(lato * 0.11, 0.145, 0.08), "legno", Vector3(0, lato * 55, 0)))
	_insegna_sic(r, pp + tang * 0.24 + Vector3(0, 0.74, 0), 0.5)
	# rampa d'accesso giù per l'altura
	var rp := pp + dir * 0.42
	r.add_child(scatola(Vector3(0.3, 0.03, 0.56), Vector3(rp.x, hc * 0.5 - 0.005, rp.z), "terra", Vector3(rad_to_deg(atan2(hc, 0.52)), rotp, 0)))
	# casa del principe (anaktoron): grandi blocchi squadrati, tetto di canne a due falde
	var ana := Node3D.new()
	ana.position = Vector3(-0.3, hc, -0.36)
	r.add_child(ana)
	var lx := 0.95
	var lz := 0.6
	var ha := 0.46
	ana.add_child(scatola(Vector3(lx, ha, lz), Vector3(0, ha * 0.5, 0), "pietra_secca"))
	for f in 3:
		var y := (f + 0.5) * ha / 3.0
		for k in 5:
			var x := -lx * 0.5 + (k + 0.5) * lx / 5.0
			ana.add_child(scatola(Vector3(lx / 5.0 - 0.014, ha / 3.0 - 0.014, 0.014), Vector3(x, y, lz * 0.5 + 0.004), "roccia_chiara" if (k + f) % 2 == 0 else "pietra_secca"))
		for k in 3:
			var z := -lz * 0.5 + (k + 0.5) * lz / 3.0
			ana.add_child(scatola(Vector3(0.014, ha / 3.0 - 0.014, lz / 3.0 - 0.014), Vector3(lx * 0.5 + 0.004, y, z), "pietra_secca" if (k + f) % 2 == 0 else "roccia_chiara"))
	_porta_sic(ana, Vector3(-0.12, 0, lz * 0.5 + 0.03), 0.0, 0.15, 0.26)
	var pend := 34.0
	var hr := ha + lz * 0.5 * tan(deg_to_rad(pend))
	sottotetto(ana, lx, lz, ha, pend, "argilla_sic")
	_tettoia_sic(ana, Vector3(0, 0, lz * 0.25), lx + 0.04, lz * 0.5, hr, ha, 152)
	var ret := Node3D.new()
	ret.rotation_degrees.y = 180
	ana.add_child(ret)
	_tettoia_sic(ret, Vector3(0, 0, lz * 0.25), lx + 0.04, lz * 0.5, hr, ha, 153)
	ana.add_child(cilindro(0.04, 0.04, lx + 0.16, Vector3(0, hr + 0.05, 0), "canne_sic", Vector3(0, 0, 90), 8))
	for k in 5:
		ana.add_child(_toro(0.035, 0.048, Vector3(-lx * 0.44 + k * lx * 0.22, hr + 0.05, 0), "corda", Vector3(0, 0, 90)))
	_insegna_sic(ana, Vector3(lx * 0.5 + 0.07, 0, lz * 0.5 + 0.07), 0.95)
	for i in 3:
		ana.add_child(_giara(Vector3(0.14 + i * 0.13, 0, lz * 0.5 + 0.11), 1.45, i))
	# capanne del villaggio
	_capanna_sic(r, Vector3(0.6, hc, -0.48), 0.32, 0.25, 0.36, 154, -20.0)
	_capanna_sic(r, Vector3(-0.7, hc, 0.42), 0.3, 0.24, 0.34, 155, 30.0)
	_capanna_sic(r, Vector3(0.0, hc, 0.8), 0.26, 0.2, 0.3, 156, 10.0)
	# recinto con le pecore, forno, fuoco e giare
	var o := Vector3(0.66, hc, 0.32)
	for k in 8:
		if k == 1:
			continue
		var a0 := deg_to_rad(k * 45.0)
		var a1 := deg_to_rad((k + 1) * 45.0)
		_muretto_secco(r, o + Vector3(cos(a0), 0, sin(a0)) * 0.27, o + Vector3(cos(a1), 0, sin(a1)) * 0.27, 0.08, 0.06)
	r.add_child(pecora(o + Vector3(-0.06, 0, 0.0), 30))
	r.add_child(pecora(o + Vector3(0.1, 0, -0.1), 200))
	r.add_child(pecora(o + Vector3(0.05, 0, 0.12), 120))
	_forno_sic(r, Vector3(-0.2, hc, 0.3), 0.8)
	_fuoco(r, Vector3(0.26, hc, 0.12), 0.9)
	r.add_child(_giara(Vector3(0.32, hc, 0.6), 1.3, 1))
	r.add_child(_giara(Vector3(0.22, hc, 0.7), 1.1, 0))
	return r


## Bottega del vasaio (edificio unico dei Siculi): capanna ovale, grande forno a cupola per la ceramica con il fumo,
## tornio sotto la tettoia di canne, assi con le file di vasi e giare dipinti ad asciugare, mucchio d'argilla
## con la vasca d'acqua, cocci, fascine e legna.
static func vasaio() -> Node3D:
	var r := Node3D.new()
	_capanna_sic(r, Vector3(-0.25, 0, -0.3), 0.38, 0.29, 0.34, 161)
	_forno_sic(r, Vector3(0.48, 0, -0.22), 1.3)
	legnaia(r, Vector3(0.62, 0, 0.18), 0.24, 3)
	_fascina(r, Vector3(0.78, 0, -0.05), 5.0)
	# tettoia con il tornio
	_tettoia_sic(r, Vector3(-0.44, 0, 0.18), 0.42, 0.24, 0.4, 0.34, 162)
	_tornio_sic(r, Vector3(-0.42, 0, 0.44), -20.0)
	# assi su sassi con i vasi ad asciugare
	for f in 2:
		var z := 0.36 + f * 0.17
		var x0 := 0.0
		r.add_child(scatola(Vector3(0.48, 0.016, 0.09), Vector3(x0 + 0.22, 0.07, z), "legno_chiaro"))
		for lato: int in [-1, 1]:
			r.add_child(sfera(0.04, Vector3(x0 + 0.22 + lato * 0.2, 0.03, z), "pietra_secca", Vector3(1, 0.9, 1.1)))
		for k in 5:
			r.add_child(_vaso_sic(Vector3(x0 + 0.04 + k * 0.09, 0.078, z), 0.95, (k + f) % 3))
	# giare grandi già dipinte
	r.add_child(_giara(Vector3(0.62, 0, 0.42), 1.5, 0))
	r.add_child(_giara(Vector3(0.6, 0, 0.6), 1.25, 1))
	# mucchio d'argilla e vasca d'acqua
	r.add_child(mucchio(Vector3(-0.68, 0, 0.0), "argilla_cruda", 9, 163, 0.06))
	r.add_child(cilindro(0.11, 0.1, 0.05, Vector3(-0.66, 0.025, 0.22), "pietra_secca", Vector3.ZERO, 14))
	r.add_child(cilindro(0.095, 0.095, 0.004, Vector3(-0.66, 0.048, 0.22), "acqua_pozzo", Vector3.ZERO, 14))
	# cocci
	var rng := _rng(164)
	for k in 6:
		r.add_child(scatola(Vector3(0.025, 0.006, 0.02), Vector3(0.3 + rng.randf_range(-0.1, 0.1), 0.003, 0.0 + rng.randf_range(-0.06, 0.06)), "ceramica" if k % 2 == 0 else "vernice_rossa", Vector3(0, rng.randf() * 180, 0)))
	_insegna_sic(r, Vector3(0.86, 0, 0.3), 0.6)
	return r


## Guerriero siculo: tunica ocra con le fasce d'ocra rossa, cinturone e bandoliera di cuoio, elmo semplice di cuoio
## con il paranuca e il ciuffo d'ocra, scudo rotondo dipinto e lancia con la punta di bronzo.
static func guerriero_siculo() -> Node3D:
	var r := portatore("", "ocra_rossa", "tunica_ocra")
	var corpo: Node3D = r.get_node("corpo")
	var anca := 0.2
	corpo.add_child(cilindro(0.083, 0.083, 0.018, Vector3(0, anca + 0.06, 0), "cuoio", Vector3.ZERO, 12))
	corpo.add_child(sfera(0.011, Vector3(0, anca + 0.06, 0.083), "bronzo"))
	corpo.add_child(scatola(Vector3(0.022, 0.2, 0.006), Vector3(0.0, anca + 0.12, 0.072), "cuoio", Vector3(0, 0, 38)))
	corpo.add_child(cilindro(0.088, 0.088, 0.008, Vector3(0, anca - 0.034, 0), "vernice_nera", Vector3.ZERO, 10))
	# elmo di cuoio
	corpo.add_child(sfera(0.081, Vector3(0, anca + 0.282, -0.006), "cuoio", Vector3(1, 0.72, 1.05)))
	corpo.add_child(cilindro(0.083, 0.084, 0.014, Vector3(0, anca + 0.262, -0.006), "pelle_scura", Vector3.ZERO, 14))
	corpo.add_child(scatola(Vector3(0.12, 0.012, 0.05), Vector3(0, anca + 0.248, -0.078), "cuoio", Vector3(-25, 0, 0)))
	for lato: int in [-1, 1]:
		corpo.add_child(scatola(Vector3(0.01, 0.045, 0.035), Vector3(lato * 0.078, anca + 0.24, 0.02), "cuoio"))
	corpo.add_child(cilindro(0.012, 0.014, 0.02, Vector3(0, anca + 0.345, -0.005), "bronzo", Vector3.ZERO, 6))
	for k in 3:
		corpo.add_child(sfera(0.018, Vector3(0, anca + 0.365 - k * 0.012, -0.02 - k * 0.02), "ocra_rossa", Vector3(0.6, 1.0, 1.1)))
	# scudo al braccio sinistro, lancia nella destra
	var bs: Node3D = corpo.get_node("braccio_s")
	bs.add_child(_scudo_sic(Vector3(-0.03, -0.075, 0.04), -90.0, 1.0))
	var bd: Node3D = corpo.get_node("braccio_d")
	bd.add_child(cilindro(0.007, 0.007, 0.5, Vector3(0, 0.06, 0.02), "legno", Vector3.ZERO, 5))
	bd.add_child(cilindro(0.016, 0.0, 0.06, Vector3(0, 0.34, 0.02), "bronzo", Vector3.ZERO, 6))
	bd.add_child(cilindro(0.009, 0.009, 0.018, Vector3(0, 0.3, 0.02), "ocra_rossa", Vector3.ZERO, 6))
	r.set_meta("carico", "lancia")
	return r


# ------------------------------------------------------------------ altri edifici dei Siculi (step G6e)
# Stesso ingombro e stessa disposizione del corrispondente greco (stesso nome senza "_siculi"): la casa diventa
# la capanna ovale con la cupola di canne, botti e anfore diventano giare dipinte, i recinti muretti a secco.

## Barca scavata in un tronco (monossile) dei Siculi: scafo di legno vecchio con la fascia d'ocra rossa,
## l'occhio dipinto a prua, panche e remo. pos = centro a terra, la prua verso +X locale.
static func _barca_sic(r: Node3D, pos: Vector3, rot_y := 0.0, lung := 1.0) -> Node3D:
	var b := Node3D.new()
	b.position = pos
	b.rotation_degrees.y = rot_y
	b.scale = Vector3(lung, 1, 1)
	r.add_child(b)
	b.add_child(sfera(0.13, Vector3(0, 0.07, 0), "legno_vecchio", Vector3(2.6, 0.7, 0.95)))
	b.add_child(sfera(0.115, Vector3(0, 0.1, 0), "corteccia", Vector3(2.45, 0.35, 0.82)))
	for lato: int in [-1, 1]:
		b.add_child(scatola(Vector3(0.56, 0.022, 0.012), Vector3(0, 0.115, lato * 0.112), "ocra_rossa", Vector3(0, 0, 0)))
		b.add_child(scatola(Vector3(0.56, 0.006, 0.013), Vector3(0, 0.1, lato * 0.112), "vernice_nera"))
		# occhio dipinto a prua
		b.add_child(cilindro(0.022, 0.022, 0.006, Vector3(0.24, 0.098, lato * 0.098), "ceramica", Vector3(90, 0, 0), 10))
		b.add_child(cilindro(0.01, 0.01, 0.008, Vector3(0.245, 0.098, lato * 0.1), "vernice_nera", Vector3(90, 0, 0), 8))
	for x: float in [-0.12, 0.1]:
		b.add_child(scatola(Vector3(0.03, 0.012, 0.2), Vector3(x, 0.115, 0), "legno"))
	b.add_child(scatola(Vector3(0.48, 0.008, 0.022), Vector3(0.02, 0.135, 0.05), "legno_chiaro", Vector3(0, 10, 6)))
	b.add_child(scatola(Vector3(0.07, 0.006, 0.035), Vector3(-0.22, 0.13, 0.09), "legno_chiaro", Vector3(0, 10, 6)))
	return b


## Lastra di pietra chiara appoggiata su due sassi (bancone o mensola dei Siculi).
static func _lastra_sic(r: Node3D, pos: Vector3, larg := 0.3, prof := 0.14, h := 0.1, rot_y := 0.0) -> void:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot_y
	r.add_child(n)
	n.add_child(scatola(Vector3(larg, 0.03, prof), Vector3(0, h, 0), "roccia_chiara"))
	for lato: int in [-1, 1]:
		n.add_child(sfera(0.05, Vector3(lato * (larg * 0.5 - 0.05), (h - 0.015) * 0.5, 0), "pietra_secca", Vector3(1, h / 0.09, prof / 0.11)))


## Graticcio di canne su quattro pali (per seccare formaggi, mattoni o pesci). pos = centro a terra.
static func _graticcio_sic(r: Node3D, pos: Vector3, lx: float, lz: float, h: float) -> void:
	for x: float in [-lx * 0.4, lx * 0.4]:
		for z: float in [-lz * 0.4, lz * 0.4]:
			r.add_child(cilindro(0.008, 0.009, h, pos + Vector3(x, h * 0.5, z), "corteccia", Vector3.ZERO, 5))
	r.add_child(scatola(Vector3(lx, 0.012, lz), pos + Vector3(0, h, 0), "canne_sic"))
	for z: float in [-lz * 0.45, lz * 0.45]:
		r.add_child(cilindro(0.006, 0.006, lx + 0.02, pos + Vector3(0, h + 0.008, z), "corda", Vector3(0, 0, 90), 4))


## Vasca tonda di pietra a secco con l'acqua (abbeveratoio o cisterna).
static func _vasca_sic(r: Node3D, pos: Vector3, rg := 0.1, h := 0.06, mat := "acqua_pozzo") -> void:
	r.add_child(cilindro(rg + 0.025, rg + 0.03, h, pos + Vector3(0, h * 0.5, 0), "pietra_secca", Vector3.ZERO, 14))
	r.add_child(cilindro(rg, rg, 0.004, pos + Vector3(0, h + 0.001, 0), mat, Vector3.ZERO, 14))
	for k in 6:
		var a := k * TAU / 6 + 0.3
		r.add_child(sfera(0.022, pos + Vector3(cos(a), 0, sin(a)) * (rg + 0.02) + Vector3(0, h, 0), "roccia_chiara" if k % 2 == 0 else "pietra_secca", Vector3(1.2, 0.6, 1.0)))


## Mantice di pelle con l'ugello di canna (per fucine e fonderie). pos = a terra, l'ugello verso +X locale.
static func _mantice_sic(r: Node3D, pos: Vector3, rot_y := 0.0) -> void:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot_y
	r.add_child(n)
	for z: float in [-0.045, 0.045]:
		n.add_child(sfera(0.05, Vector3(0, 0.04, z), "pelle_scura", Vector3(1.3, 0.6, 0.9)))
		n.add_child(cilindro(0.004, 0.004, 0.07, Vector3(-0.03, 0.08, z), "legno_vecchio", Vector3(0, 0, 30), 4))
	n.add_child(cilindro(0.008, 0.01, 0.16, Vector3(0.12, 0.035, 0), "terracotta", Vector3(0, 0, 90), 6))


## Porcile dei Siculi: capanna ovale, recinto di muretti a secco con il cancello di canne, truogolo di pietra,
## maiali nel fango sotto la quercia delle ghiande, sacco e giara.
static func porcile_siculi() -> Node3D:
	var r := Node3D.new()
	_capanna_sic(r, Vector3(-0.3, 0, -0.3), 0.3, 0.23, 0.28, 201)
	var a := Vector3(0.05, 0, 0.0)
	r.add_child(scatola(Vector3(0.8, 0.012, 0.75), a + Vector3(0.12, 0.006, 0.12), "terra"))
	_muretto_secco(r, a + Vector3(-0.28, 0, 0.5), a + Vector3(0.28, 0, 0.5), 0.08, 0.07)
	_graticcio(r, a + Vector3(0.3, 0, 0.5), a + Vector3(0.5, 0, 0.5), 0.08)
	_muretto_secco(r, a + Vector3(0.52, 0, -0.26), a + Vector3(0.52, 0, 0.53), 0.08, 0.07)
	_muretto_secco(r, a + Vector3(0.15, 0, -0.26), a + Vector3(0.55, 0, -0.26), 0.08, 0.07)
	r.add_child(sfera(0.14, a + Vector3(0.28, 0.0, 0.05), "fuliggine", Vector3(1.4, 0.1, 1.0)))
	# truogolo di pietra con il grano
	r.add_child(scatola(Vector3(0.24, 0.05, 0.08), a + Vector3(0.0, 0.025, 0.4), "roccia_chiara"))
	r.add_child(scatola(Vector3(0.2, 0.008, 0.05), a + Vector3(0.0, 0.051, 0.4), "grano"))
	for p: Array in [[Vector3(0.25, 0, 0.3), 20], [Vector3(0.38, 0, -0.05), 130], [Vector3(0.05, 0, 0.18), -60], [Vector3(0.4, 0, 0.32), 200]]:
		r.add_child(maiale(a + (p[0] as Vector3), p[1]))
	r.add_child(scatola(Vector3(0.16, 0.04, 0.06), a + Vector3(-0.15, 0.02, 0.1), "pietra_secca"))
	r.add_child(scatola(Vector3(0.13, 0.004, 0.04), a + Vector3(-0.15, 0.041, 0.1), "acqua_pozzo"))
	r.add_child(sacco(Vector3(-0.62, 0, 0.3), 0.3))
	r.add_child(_giara(Vector3(-0.48, 0, 0.42), 0.9, 0))
	_quercia_n(r, Vector3(-0.7, 0, -0.1), 0.45, 202)
	for k in 6:
		r.add_child(sfera(0.012, Vector3(-0.6 + k * 0.04, 0.008, 0.05 + (k % 2) * 0.05), "corteccia"))
	return r


## Macelleria dei Siculi: capanna ovale grande, tettoia di canne e frasche con la carne appesa, bancone di pietra
## su due sassi, ceppo, giare e insegna d'ocra.
static func macelleria_siculi() -> Node3D:
	var r := Node3D.new()
	_capanna_sic(r, Vector3(-0.2, 0, -0.25), 0.37, 0.28, 0.4, 211)
	_tettoia_sic(r, Vector3(0.45, 0, 0.42), 0.6, 0.26, 0.42, 0.34, 212)
	r.add_child(cilindro(0.01, 0.01, 0.56, Vector3(0.45, 0.3, 0.52), "corteccia", Vector3(0, 0, 90), 5))
	for k in 5:
		var x := 0.25 + k * 0.1
		r.add_child(cilindro(0.003, 0.003, 0.05, Vector3(x, 0.275, 0.52), "corda", Vector3.ZERO, 3))
		if k % 2 == 0:
			r.add_child(sfera(0.035, Vector3(x, 0.215, 0.52), "carne", Vector3(0.9, 1.4, 0.8)))
		else:
			r.add_child(cilindro(0.016, 0.016, 0.1, Vector3(x, 0.205, 0.52), "carne", Vector3.ZERO, 8))
	var b := Vector3(-0.35, 0, 0.55)
	_lastra_sic(r, b, 0.32, 0.15, 0.1)
	r.add_child(sfera(0.04, b + Vector3(-0.05, 0.135, 0), "carne", Vector3(1.2, 0.5, 0.9)))
	r.add_child(scatola(Vector3(0.07, 0.004, 0.02), b + Vector3(0.08, 0.12, 0.02), "bronzo", Vector3(0, 30, 0)))
	r.add_child(cilindro(0.07, 0.075, 0.1, Vector3(-0.65, 0.05, 0.4), "corteccia", Vector3.ZERO, 12))
	r.add_child(_giara(Vector3(0.65, 0, 0.0), 1.1, 0))
	r.add_child(_giara(Vector3(0.68, 0, 0.16), 0.9, 1))
	r.add_child(maiale(Vector3(-0.6, 0, 0.0), 60))
	_insegna_sic(r, Vector3(0.12, 0, 0.12), 0.55)
	return r


## Apiario dei Siculi: capanna ovale, arnie a tubo di canne e ferula intonacate d'argilla, coricate a file
## su muretti a secco, fiori tutto intorno, quercia, vasetti di miele.
static func apiario_siculi() -> Node3D:
	var r := Node3D.new()
	_capanna_sic(r, Vector3(-0.35, 0, -0.35), 0.25, 0.2, 0.26, 221)
	for f in 2:
		var z := 0.15 + f * 0.25
		_muretto_secco(r, Vector3(-0.22, 0, z), Vector3(0.52, 0, z), 0.06, 0.12)
		for liv in 2:
			for k in 5 - liv:
				var x := -0.15 + k * 0.15 + liv * 0.075
				var p := Vector3(x, 0.105 + liv * 0.07, z)
				r.add_child(cilindro(0.035, 0.035, 0.16, p, "canne_sic", Vector3(90, 0, 0), 10))
				for dz: float in [-0.05, 0.05]:
					r.add_child(_toro(0.033, 0.039, p + Vector3(0, 0, dz), "corda", Vector3(90, 0, 0)))
				r.add_child(cilindro(0.032, 0.032, 0.01, p + Vector3(0, 0, 0.078), "argilla_sic", Vector3(90, 0, 0), 10))
				r.add_child(scatola(Vector3(0.016, 0.01, 0.006), p + Vector3(0, -0.012, 0.084), "buio"))
	var rng := _rng(222)
	for k in 30:
		var p := Vector3(rng.randf_range(-0.7, 0.7), 0.0, rng.randf_range(0.6, 0.75))
		if k % 2 == 0:
			p = Vector3(rng.randf_range(0.58, 0.75), 0.0, rng.randf_range(-0.3, 0.6))
		r.add_child(sfera(0.018, p + Vector3(0, 0.02, 0), "orto"))
		r.add_child(sfera(0.012, p + Vector3(0, 0.04, 0), ["fiore", "geranio", "miele"][k % 3]))
	_quercia_n(r, Vector3(0.55, 0, -0.42), 0.45, 223)
	r.add_child(_vaso_sic(Vector3(-0.62, 0, 0.2), 1.1, 2))
	r.add_child(_vaso_sic(Vector3(-0.52, 0, 0.3), 1.0, 1))
	r.add_child(_giara(Vector3(-0.66, 0, 0.36), 0.8, 1))
	return r


## Caseificio dei Siculi: capanna ovale grande, olla di ceramica col latte sul fuoco fra tre pali, graticci di canne
## con le forme di formaggio sotto la tettoia e accanto alla capanna, giare del latte.
static func caseificio_siculi() -> Node3D:
	var r := Node3D.new()
	_capanna_sic(r, Vector3(-0.2, 0, -0.25), 0.37, 0.28, 0.4, 231)
	var f := Vector3(0.45, 0, 0.45)
	_fuoco(r, f, 1.0)
	r.add_child(sfera(0.085, f + Vector3(0, 0.14, 0), "ceramica", Vector3(1, 0.85, 1)))
	r.add_child(cilindro(0.086, 0.086, 0.02, f + Vector3(0, 0.14, 0), "vernice_rossa", Vector3.ZERO, 14))
	r.add_child(cilindro(0.06, 0.06, 0.01, f + Vector3(0, 0.205, 0), "latte", Vector3.ZERO, 14))
	r.add_child(cilindro(0.062, 0.062, 0.012, f + Vector3(0, 0.2, 0), "vernice_nera", Vector3.ZERO, 14))
	for k in 3:
		var a := k * TAU / 3 + 0.5
		ramo(r, f + Vector3(cos(a) * 0.15, 0, sin(a) * 0.15), f + Vector3(0, 0.34, 0), 0.008, "corteccia")
	r.add_child(cilindro(0.004, 0.004, 0.12, f + Vector3(0, 0.27, 0), "corda", Vector3.ZERO, 3))
	_fumo(r, f + Vector3(0, 0.26, 0), 2, 0.6)
	_tettoia_sic(r, Vector3(-0.3, 0, 0.5), 0.4, 0.2, 0.38, 0.32, 232)
	for p: Vector3 in [Vector3(-0.3, 0, 0.5), Vector3(0.7, 0, -0.05)]:
		var lungo_x := p.x < 0
		for liv in 3:
			r.add_child(scatola(Vector3(0.28 if lungo_x else 0.08, 0.012, 0.08 if lungo_x else 0.28), p + Vector3(0, 0.05 + liv * 0.08, 0), "canne_sic"))
			for k in 3:
				var o := Vector3((k - 1) * 0.085, 0, 0) if lungo_x else Vector3(0, 0, (k - 1) * 0.085)
				r.add_child(cilindro(0.033, 0.033, 0.035, p + o + Vector3(0, 0.074 + liv * 0.08, 0), "formaggio", Vector3.ZERO, 12))
		for s: int in [-1, 1]:
			var o2 := Vector3(s * 0.15, 0, 0) if lungo_x else Vector3(0, 0, s * 0.15)
			r.add_child(cilindro(0.008, 0.009, 0.24, p + o2 + Vector3(0, 0.12, 0), "corteccia", Vector3.ZERO, 5))
	r.add_child(_giara(Vector3(0.1, 0, 0.62), 0.85, 0))
	r.add_child(_giara(Vector3(0.24, 0, 0.6), 1.0, 1))
	return r


## Argillaio dei Siculi: capanna ovale piccola, mattoni crudi che seccano sulla stuoia di canne, fossa d'argilla,
## stampo di legno, pala e vasca d'acqua di pietra a secco.
static func argillaio_siculi() -> Node3D:
	var r := Node3D.new()
	_capanna_sic(r, Vector3(-0.32, 0, -0.32), 0.24, 0.18, 0.24, 241)
	r.add_child(scatola(Vector3(0.44, 0.008, 0.18), Vector3(-0.41, 0.004, 0.45), "canne_sic"))
	r.add_child(sfera(0.3, Vector3(0.3, -0.02, 0.25), "argilla", Vector3(1.3, 0.12, 1.0)))
	r.add_child(sfera(0.22, Vector3(0.3, 0.0, 0.25), "argilla_cruda", Vector3(1.3, 0.08, 1.0)))
	for k in 6:
		var a := deg_to_rad(-20.0 + k * 40.0)
		r.add_child(sfera(0.03, Vector3(0.3 + cos(a) * 0.37, 0.01, 0.25 + sin(a) * 0.29), "pietra_secca", Vector3(1.2, 0.6, 1.0)))
	for k in 12:
		r.add_child(scatola(Vector3(0.07, 0.03, 0.04), Vector3(-0.55 + (k % 4) * 0.09, 0.024 + (k / 4) * 0.032, 0.45), "argilla" if k % 3 else "argilla_cruda", Vector3(0, (k % 2) * 5, 0)))
	r.add_child(scatola(Vector3(0.1, 0.02, 0.06), Vector3(-0.12, 0.01, 0.6), "legno_vecchio"))
	r.add_child(scatola(Vector3(0.07, 0.006, 0.04), Vector3(-0.12, 0.023, 0.6), "buio"))
	var a := attrezzo("pala")
	a.position = Vector3(0.62, 0.02, 0.05)
	a.rotation_degrees = Vector3(0, 40, 10)
	r.add_child(a)
	_vasca_sic(r, Vector3(0.04, 0, 0.62), 0.07, 0.05)
	r.add_child(_giara(Vector3(-0.02, 0, 0.0), 0.9, 1))
	return r


## Fornace dei Siculi: capanna ovale, forno a cupola d'argilla con la fascia rossa, la bocca accesa e il fumo,
## file di vasi dipinti ad asciugare, mucchio d'argilla, legna e fascine.
static func fornace_siculi() -> Node3D:
	var r := Node3D.new()
	_capanna_sic(r, Vector3(-0.25, 0, -0.3), 0.3, 0.23, 0.32, 251)
	_forno_sic(r, Vector3(0.42, 0, 0.3), 1.05)
	for k in 7:
		var p := Vector3(-0.6 + (k % 4) * 0.1, 0, 0.42 + (k / 4) * 0.12)
		if k % 3 == 1:
			r.add_child(_giara(p, 0.65, k))
		else:
			r.add_child(_vaso_sic(p, 1.0, k % 3))
	r.add_child(mucchio(Vector3(0.68, 0, -0.18), "argilla_cruda", 8, 9))
	legnaia(r, Vector3(0.68, 0, 0.12), 0.2, 3)
	_fascina(r, Vector3(0.1, 0, 0.62), 80.0)
	return r


## Saline dei Siculi: vasche di evaporazione bordate di pietra a secco, canaletta, cumuli di sale,
## capannuccia ovale, pala, sacco e giara.
static func saline_siculi() -> Node3D:
	var r := Node3D.new()
	for i in 3:
		for j in 2:
			var p := Vector3(-0.45 + i * 0.42, 0, -0.25 + j * 0.5)
			r.add_child(scatola(Vector3(0.4, 0.04, 0.46), p + Vector3(0, 0.02, 0), "pietra_secca"))
			var mat := "acqua_chiara" if (i + j) % 3 != 0 else "sale"
			r.add_child(scatola(Vector3(0.34, 0.005, 0.4), p + Vector3(0, 0.042, 0), mat))
			r.add_child(scatola(Vector3(0.05, 0.008, 0.04), p + Vector3(0, 0.04, -0.21), "acqua_chiara"))
			for k in 4:
				var q := p + Vector3(-0.17 + (k % 2) * 0.34, 0.04, -0.2 + (k / 2) * 0.4)
				r.add_child(sfera(0.024, q, "roccia_chiara", Vector3(1.2, 0.6, 1.0)))
	var cz := -0.53
	r.add_child(scatola(Vector3(1.1, 0.024, 0.07), Vector3(-0.13, 0.012, cz), "pietra_secca"))
	r.add_child(scatola(Vector3(1.1, 0.004, 0.035), Vector3(-0.13, 0.026, cz), "acqua_chiara"))
	for p: Vector3 in [Vector3(0.62, 0, 0.55), Vector3(0.42, 0, 0.62), Vector3(-0.6, 0, 0.6)]:
		r.add_child(sfera(0.1, p, "sale", Vector3(1, 0.9, 1)))
	_capanna_sic(r, Vector3(0.68, 0, -0.66), 0.16, 0.13, 0.2, 261, 0.0, true, 1.35)
	var a := attrezzo("pala")
	a.position = Vector3(0.25, 0.02, 0.45)
	a.rotation_degrees = Vector3(0, -30, 5)
	r.add_child(a)
	r.add_child(sacco(Vector3(0.0, 0, 0.62), 0.3))
	r.add_child(_giara(Vector3(0.32, 0, -0.74), 0.8, 0))
	return r


## Tessitura dei Siculi: capanna ovale grande, telaio verticale a pesi d'argilla con la tela a fasce d'ocra rossa,
## nere e chiare, matasse di lana, drappi dipinti stesi su una pertica, cesta di lana.
static func tessitura_siculi() -> Node3D:
	var r := Node3D.new()
	_capanna_sic(r, Vector3(-0.2, 0, -0.28), 0.36, 0.26, 0.4, 271)
	var t := Vector3(0.0, 0, 0.5)
	for x: float in [-0.18, 0.18]:
		r.add_child(cilindro(0.012, 0.014, 0.44, t + Vector3(x, 0.21, -0.02), "corteccia", Vector3(-6, 0, 0), 6))
	r.add_child(cilindro(0.012, 0.012, 0.42, t + Vector3(0, 0.4, -0.04), "legno_vecchio", Vector3(0, 0, 90), 6))
	var fili := ["ocra_rossa", "vernice_nera", "lino", "ocra_rossa", "lino", "vernice_nera"]
	for k in 6:
		r.add_child(scatola(Vector3(0.34, 0.03, 0.006), t + Vector3(0, 0.37 - k * 0.03, -0.035 + k * 0.003), fili[k]))
	for k in 12:
		r.add_child(scatola(Vector3(0.004, 0.13, 0.004), t + Vector3(-0.155 + k * 0.028, 0.15, -0.012), "lino"))
	# pesi da telaio d'argilla appesi ai fili
	for k in 8:
		r.add_child(cilindro(0.012, 0.022, 0.04, t + Vector3(-0.14 + k * 0.04, 0.07, -0.01 + (k % 2) * 0.012), "argilla_sic", Vector3.ZERO, 4))
	r.add_child(cilindro(0.006, 0.006, 0.36, t + Vector3(0, 0.1, -0.01), "legno_vecchio", Vector3(0, 0, 90), 5))
	var colori := ["lana", "ocra_rossa", "vernice_nera"]
	for i in 3:
		var p := Vector3(0.52 + (i % 2) * 0.06, 0, 0.05 + i * 0.1)
		r.add_child(sfera(0.045, p + Vector3(0, 0.035, 0), colori[i], Vector3(1.2, 0.8, 1)))
	r.add_child(cesta(Vector3(0.66, 0, 0.42), "lana"))
	for x: float in [0.36, 0.86]:
		r.add_child(cilindro(0.009, 0.01, 0.36, Vector3(x, 0.18, -0.35), "corteccia", Vector3.ZERO, 5))
	r.add_child(cilindro(0.008, 0.008, 0.54, Vector3(0.61, 0.36, -0.35), "legno_vecchio", Vector3(0, 0, 90), 5))
	for k in 2:
		var x := 0.49 + k * 0.24
		r.add_child(scatola(Vector3(0.2, 0.24, 0.006), Vector3(x, 0.24, -0.345), "ocra_rossa" if k == 0 else "lino"))
		for y: float in [0.3, 0.2]:
			r.add_child(scatola(Vector3(0.202, 0.02, 0.008), Vector3(x, y, -0.345), "vernice_nera" if k == 0 else "vernice_rossa"))
		r.add_child(scatola(Vector3(0.05, 0.05, 0.009), Vector3(x, 0.25, -0.345), "ceramica" if k == 0 else "vernice_nera", Vector3(0, 0, 45)))
	return r


## Pescatore dei Siculi: capanna ovale, reti stese su pali di corteccia, barca scavata nel tronco con l'occhio dipinto
## tirata a secco, ceste di pesce, giara e quercia.
static func capanna_pescatore_siculi() -> Node3D:
	var r := Node3D.new()
	_capanna_sic(r, Vector3(-0.22, 0, -0.25), 0.33, 0.25, 0.36, 281)
	for x: float in [0.35, 0.75]:
		r.add_child(cilindro(0.012, 0.014, 0.36, Vector3(x, 0.18, -0.35), "corteccia", Vector3.ZERO, 6))
	r.add_child(scatola(Vector3(0.4, 0.26, 0.006), Vector3(0.55, 0.2, -0.35), "rete"))
	for k in 6:
		r.add_child(scatola(Vector3(0.004, 0.26, 0.008), Vector3(0.37 + k * 0.07, 0.2, -0.345), "corda"))
	for k in 4:
		r.add_child(scatola(Vector3(0.4, 0.004, 0.008), Vector3(0.55, 0.1 + k * 0.065, -0.345), "corda"))
	for k in 4:
		r.add_child(cilindro(0.012, 0.012, 0.02, Vector3(0.4 + k * 0.1, 0.07, -0.34), "argilla_sic", Vector3(90, 0, 0), 6))
	_barca_sic(r, Vector3(0.35, 0, 0.45), -25.0)
	r.add_child(cesta(Vector3(-0.45, 0, 0.45), "pesce"))
	r.add_child(cesta(Vector3(-0.3, 0, 0.58), "pesce"))
	r.add_child(_giara(Vector3(-0.62, 0, 0.25), 1.0, 0))
	_quercia_n(r, Vector3(-0.66, 0, -0.05), 0.42, 282)
	return r


## Frantoio dei Siculi: capanna ovale grande, macina di pietra chiara nella vasca di pietra a secco girata a mano,
## giare dell'olio, fiscoli di paglia con la pasta d'olive, grande giara, ulivo e insegna d'ocra.
static func frantoio_siculi() -> Node3D:
	var r := Node3D.new()
	_capanna_sic(r, Vector3(-0.2, 0, -0.22), 0.41, 0.31, 0.42, 291)
	var m := Vector3(-0.35, 0, 0.55)
	r.add_child(cilindro(0.26, 0.28, 0.1, m + Vector3(0, 0.05, 0), "pietra_secca", Vector3.ZERO, 24))
	r.add_child(cilindro(0.27, 0.27, 0.012, m + Vector3(0, 0.104, 0), "roccia_chiara", Vector3.ZERO, 24))
	r.add_child(cilindro(0.21, 0.21, 0.01, m + Vector3(0, 0.106, 0), "foglie_ulivo", Vector3.ZERO, 24))
	r.add_child(cilindro(0.03, 0.03, 0.22, m + Vector3(0, 0.2, 0), "legno_vecchio", Vector3.ZERO, 8))
	r.add_child(cilindro(0.12, 0.12, 0.08, m + Vector3(0.1, 0.22, 0), "roccia_chiara", Vector3(0, 0, 90), 18))
	r.add_child(scatola(Vector3(0.6, 0.03, 0.03), m + Vector3(0.2, 0.26, 0), "legno_vecchio"))
	for i in 6:
		var p := Vector3(0.25 + (i % 3) * 0.1, 0.0, 0.42 + (i / 3) * 0.11)
		if i % 2 == 0:
			r.add_child(_giara(p, 0.7, i))
		else:
			r.add_child(_vaso_sic(p, 1.15, 2))
	for i in 3:
		r.add_child(cilindro(0.06, 0.05, 0.06, Vector3(0.62, 0.03, -0.3 + i * 0.16), "paglia", Vector3.ZERO, 12))
		r.add_child(sfera(0.05, Vector3(0.62, 0.06, -0.3 + i * 0.16), "foglie_ulivo", Vector3(1, 0.4, 1)))
	r.add_child(_giara(Vector3(0.62, 0.0, 0.25), 1.45, 1))
	var u := ulivo(292)
	u.position = Vector3(-0.72, 0, -0.45)
	u.scale = Vector3.ONE * 0.8
	r.add_child(u)
	_insegna_sic(r, Vector3(0.3, 0, 0.18), 0.55)
	return r


## Uliveto dei Siculi: capanna ovale, teli stesi sotto l'ulivo, ceste di olive, scala a pioli,
## giara e muretto a secco.
static func uliveto_siculi() -> Node3D:
	var r := Node3D.new()
	_capanna_sic(r, Vector3(-0.3, 0, -0.3), 0.29, 0.23, 0.3, 301)
	var u := ulivo(302)
	u.position = Vector3(0.35, 0, 0.3)
	u.scale = Vector3.ONE * 0.8
	r.add_child(u)
	r.add_child(scatola(Vector3(0.5, 0.004, 0.45), Vector3(0.35, 0.004, 0.3), "lino", Vector3(0, 12, 0)))
	for k in 12:
		r.add_child(sfera(0.012, Vector3(0.2 + (k % 4) * 0.08, 0.012, 0.18 + (k / 4) * 0.1), "oliva"))
	_muretto_secco(r, Vector3(0.72, 0, -0.3), Vector3(0.72, 0, 0.5), 0.07, 0.07)
	for p: Vector3 in [Vector3(-0.45, 0, 0.45), Vector3(-0.25, 0, 0.55), Vector3(0.58, 0, -0.2)]:
		r.add_child(cesta(p, "olive"))
	for z: float in [0.12, 0.2]:
		r.add_child(cilindro(0.012, 0.012, 0.45, Vector3(0.12, 0.22, z), "corteccia", Vector3(0, 0, -18), 5))
	for k in 5:
		r.add_child(scatola(Vector3(0.012, 0.012, 0.08), Vector3(0.05 + k * 0.03, 0.03 + k * 0.08, 0.16), "legno_vecchio"))
	r.add_child(_giara(Vector3(-0.62, 0, 0.2), 1.0, 0))
	return r


## Vigneto dei Siculi: capanna ovale, pergolato d'uva su pali forcuti di corteccia con le traverse di canna,
## palmento scavato nella roccia per pigiare con la vaschetta del mosto, ceste di grappoli.
static func vigneto_siculi() -> Node3D:
	var r := Node3D.new()
	_capanna_sic(r, Vector3(-0.25, 0, -0.32), 0.33, 0.24, 0.34, 311)
	for p: Vector3 in [Vector3(-0.35, 0, 0.15), Vector3(0.25, 0, 0.15), Vector3(-0.35, 0, 0.55), Vector3(0.25, 0, 0.55)]:
		r.add_child(cilindro(0.016, 0.02, 0.36, p + Vector3(0, 0.18, 0), "corteccia", Vector3.ZERO, 6))
		r.add_child(sfera(0.035, p + Vector3(0, 0.015, 0), "pietra_secca", Vector3(1.2, 0.6, 1.0)))
	for z: float in [0.15, 0.55]:
		r.add_child(cilindro(0.011, 0.011, 0.68, Vector3(-0.05, 0.355, z), "legno_vecchio", Vector3(0, 0, 90), 5))
	for k in 6:
		r.add_child(cilindro(0.006, 0.006, 0.44, Vector3(-0.35 + k * 0.12, 0.368, 0.35), "canne_sic", Vector3(90, 0, 0), 4))
	var rng := _rng(312)
	for k in 26:
		r.add_child(sfera(0.045, Vector3(rng.randf_range(-0.38, 0.28), 0.38, rng.randf_range(0.12, 0.58)), "foglie" if k % 3 else "foglie_chiare", Vector3(1, 0.5, 1)))
	for k in 6:
		r.add_child(sfera(0.022, Vector3(-0.3 + k * 0.1, 0.33, 0.35 + (k % 2) * 0.1), "uva", Vector3(1, 1.5, 1)))
	# palmento: vasca scavata in un masso piatto, beccuccio e vaschetta del mosto
	var v := Vector3(0.55, 0, 0.38)
	r.add_child(sfera(0.16, v + Vector3(0, 0.0, 0), "roccia_chiara", Vector3(1.0, 0.5, 0.9)))
	r.add_child(cilindro(0.11, 0.1, 0.01, v + Vector3(0, 0.075, 0), "vino", Vector3.ZERO, 14))
	r.add_child(sfera(0.022, v + Vector3(0.0, 0.085, 0.0), "uva", Vector3(1.6, 0.5, 1.4)))
	r.add_child(scatola(Vector3(0.03, 0.012, 0.06), v + Vector3(0, 0.05, 0.15), "roccia_chiara", Vector3(-20, 0, 0)))
	r.add_child(cilindro(0.05, 0.045, 0.04, v + Vector3(0, 0.02, 0.22), "pietra_secca", Vector3.ZERO, 10))
	r.add_child(cilindro(0.038, 0.038, 0.004, v + Vector3(0, 0.041, 0.22), "vino", Vector3.ZERO, 10))
	r.add_child(cesta(Vector3(0.62, 0, 0.0), "uva"))
	r.add_child(cesta(Vector3(0.45, 0, -0.2), "uva"))
	return r


## Cantina dei Siculi: capanna ovale grande, grandi giare del vino interrate a metà in un letto di sassi,
## giare minori in fila, palmento di pietra con il torchio a leva appesantito da un masso, cesta d'uva, insegna.
static func cantina_siculi() -> Node3D:
	var r := Node3D.new()
	_capanna_sic(r, Vector3(-0.2, 0, -0.25), 0.38, 0.28, 0.38, 321)
	r.add_child(scatola(Vector3(0.22, 0.04, 0.66), Vector3(0.62, 0.02, -0.1), "pietra_secca"))
	for k in 3:
		var p := Vector3(0.62, 0.0, -0.32 + k * 0.21)
		r.add_child(_giara(p + Vector3(0, -0.03, 0), 1.35, k))
		r.add_child(cilindro(0.09, 0.095, 0.03, p + Vector3(0, 0.035, 0), "pietra_secca", Vector3.ZERO, 12))
	for k in 5:
		r.add_child(_giara(Vector3(-0.6 + (k % 3) * 0.1, 0, 0.42 + (k / 3) * 0.12), 0.75, k))
	var t := Vector3(0.2, 0, 0.55)
	r.add_child(scatola(Vector3(0.36, 0.06, 0.28), t + Vector3(0, 0.03, 0), "pietra_secca"))
	r.add_child(scatola(Vector3(0.3, 0.01, 0.22), t + Vector3(0, 0.065, 0), "vino"))
	r.add_child(scatola(Vector3(0.22, 0.03, 0.16), t + Vector3(0, 0.085, 0), "canne_sic"))
	# torchio a leva: palo forcuto, trave lunga, masso appeso
	r.add_child(cilindro(0.02, 0.024, 0.3, t + Vector3(-0.2, 0.15, 0), "corteccia", Vector3.ZERO, 6))
	r.add_child(cilindro(0.016, 0.016, 0.5, t + Vector3(0.02, 0.17, 0), "legno_vecchio", Vector3(0, 0, 80), 6))
	r.add_child(cilindro(0.004, 0.004, 0.08, t + Vector3(0.24, 0.12, 0), "corda", Vector3.ZERO, 3))
	r.add_child(sfera(0.05, t + Vector3(0.25, 0.06, 0), "roccia_massi", Vector3(1.1, 0.9, 1.0)))
	r.add_child(cesta(Vector3(-0.15, 0, 0.62), "uva"))
	_insegna_sic(r, Vector3(0.28, 0, 0.12), 0.5)
	return r


## Ortolano dei Siculi: capanna ovale, orto chiuso dal muretto a secco e bagnato dalla canaletta di pietra,
## trecce di cipolle appese a una pertica, ceste di verdura e giara dell'acqua.
static func ortolano_siculi() -> Node3D:
	var r := Node3D.new()
	_capanna_sic(r, Vector3(-0.3, 0, -0.32), 0.29, 0.22, 0.32, 331)
	orto(r, Vector3(0.45, 0, 0.0), 0.36, 0.6, 332)
	r.add_child(scatola(Vector3(0.05, 0.02, 0.64), Vector3(0.45, 0.01, 0.0), "pietra_secca"))
	r.add_child(scatola(Vector3(0.025, 0.004, 0.64), Vector3(0.45, 0.021, 0.0), "acqua_chiara"))
	_muretto_secco(r, Vector3(0.68, 0, -0.34), Vector3(0.68, 0, 0.34), 0.08, 0.07)
	for x: float in [-0.56, -0.2]:
		r.add_child(cilindro(0.01, 0.012, 0.34, Vector3(x, 0.17, 0.14), "corteccia", Vector3.ZERO, 5))
	r.add_child(cilindro(0.008, 0.008, 0.38, Vector3(-0.38, 0.33, 0.14), "legno_vecchio", Vector3(0, 0, 90), 5))
	for k in 4:
		for i in 4:
			r.add_child(sfera(0.02, Vector3(-0.5 + k * 0.08, 0.3 - i * 0.04, 0.14), "cipolla"))
	for p: Vector3 in [Vector3(-0.4, 0, 0.45), Vector3(-0.2, 0, 0.55)]:
		r.add_child(cesta(p, "ortaggi"))
	r.add_child(cesta(Vector3(0.05, 0, 0.6), "cipolle"))
	r.add_child(_giara(Vector3(0.12, 0, 0.42), 0.85, 1))
	return r


## Agrumeto dei Siculi: capanna ovale, grande albero di agrumi nell'aiuola bordata di sassi, vasca di pietra a secco
## con la canaletta, ceste di arance e limoni, giara.
static func agrumeto_siculi() -> Node3D:
	var r := Node3D.new()
	_capanna_sic(r, Vector3(-0.3, 0, -0.3), 0.3, 0.23, 0.3, 341)
	var a := agrumi(3)
	var terra := a.get_child(0)
	a.remove_child(terra)
	terra.free()
	a.position = Vector3(0.3, 0, 0.25)
	a.scale = Vector3.ONE * 1.1
	r.add_child(a)
	r.add_child(cilindro(0.18, 0.18, 0.006, Vector3(0.3, 0.003, 0.25), "terra", Vector3.ZERO, 16))
	for k in 12:
		var an := k * TAU / 12
		r.add_child(sfera(0.03, Vector3(0.3 + cos(an) * 0.2, 0.012, 0.25 + sin(an) * 0.2), "pietra_secca" if k % 2 else "roccia_chiara", Vector3(1.2, 0.65, 1.0)))
	_vasca_sic(r, Vector3(-0.02, 0, 0.6), 0.07, 0.08)
	r.add_child(scatola(Vector3(0.2, 0.02, 0.045), Vector3(0.145, 0.01, 0.51), "pietra_secca", Vector3(0, 50, 0)))
	r.add_child(scatola(Vector3(0.2, 0.004, 0.022), Vector3(0.145, 0.021, 0.51), "acqua_chiara", Vector3(0, 50, 0)))
	for p: Vector3 in [Vector3(-0.45, 0, 0.45), Vector3(-0.28, 0, 0.6), Vector3(0.7, 0, -0.25)]:
		r.add_child(cesta(p, "agrumi"))
	r.add_child(_giara(Vector3(0.65, 0, 0.08), 0.9, 0))
	return r


## Pesca del pesce spada dei Siculi: capanna ovale, grande barca scavata con l'albero di vedetta e il drappo d'ocra,
## la passerella dell'arpioniere, l'arpione con la punta di bronzo, il pesce spada e la giara.
static func pesca_spada_siculi() -> Node3D:
	var r := Node3D.new()
	_capanna_sic(r, Vector3(-0.3, 0, -0.3), 0.3, 0.23, 0.3, 351)
	var b := _barca_sic(r, Vector3(0.3, 0, 0.35), -30.0, 1.15)
	b.add_child(cilindro(0.01, 0.008, 0.6, Vector3(0.0, 0.42, 0), "corteccia", Vector3.ZERO, 6))
	for k in 5:
		b.add_child(scatola(Vector3(0.07, 0.006, 0.01), Vector3(0.0, 0.2 + k * 0.08, 0.0), "legno_vecchio"))
	b.add_child(scatola(Vector3(0.006, 0.06, 0.09), Vector3(0.0, 0.67, 0.045), "ocra_rossa"))
	b.add_child(scatola(Vector3(0.008, 0.012, 0.09), Vector3(0.0, 0.67, 0.045), "vernice_nera"))
	b.add_child(scatola(Vector3(0.4, 0.012, 0.02), Vector3(0.5, 0.13, 0), "legno_chiaro"))
	r.add_child(cilindro(0.006, 0.006, 0.5, Vector3(-0.6, 0.15, 0.4), "legno", Vector3(90, 0, 4), 5))
	r.add_child(cilindro(0.014, 0.0, 0.05, Vector3(-0.6, 0.15, 0.67), "bronzo", Vector3(90, 0, 0), 6))
	var sp := pesce_spada_modello()
	sp.position = Vector3(-0.35, 0.02, 0.55)
	r.add_child(sp)
	r.add_child(_giara(Vector3(-0.66, 0, 0.1), 0.95, 1))
	return r


## Miniera dei Siculi: fianco della montagna con l'imbocco fra due lastroni di pietra chiara sotto la tettoia di canne,
## gerla e slitta di legno con il minerale, mucchio, puntelli, lucerna di ceramica, insegna d'ocra e giara.
static func miniera_ferro_siculi(minerale := "minerale") -> Node3D:
	var r := Node3D.new()
	r.add_child(sfera(0.6, Vector3(-0.25, 0.0, -0.3), "roccia_massi", Vector3(1.2, 0.75, 1.0)))
	r.add_child(sfera(0.35, Vector3(0.35, 0.0, -0.45), "roccia_massi", Vector3(1.1, 0.8, 1.0)))
	r.add_child(sfera(0.3, Vector3(-0.65, 0.0, 0.15), "roccia_massi", Vector3(1.0, 0.7, 1.0)))
	var imb := Vector3(-0.05, 0, 0.18)
	r.add_child(scatola(Vector3(0.42, 0.3, 0.12), imb + Vector3(0, 0.15, -0.04), "pietra_secca"))
	r.add_child(scatola(Vector3(0.2, 0.25, 0.1), imb + Vector3(0, 0.125, 0.06), "buio"))
	_porta_sic(r, imb + Vector3(0, 0, 0.12), 0.0, 0.18, 0.24, false)
	for lato: int in [-1, 1]:
		r.add_child(cilindro(0.014, 0.016, 0.24, imb + Vector3(lato * 0.15, 0.12, 0.16), "corteccia", Vector3.ZERO, 6))
	r.add_child(cilindro(0.014, 0.014, 0.36, imb + Vector3(0, 0.25, 0.16), "legno_vecchio", Vector3(0, 0, 90), 6))
	# slitta di legno con il minerale e gerla
	var carr := Vector3(-0.05, 0, 0.5)
	for lato: int in [-1, 1]:
		r.add_child(scatola(Vector3(0.016, 0.02, 0.24), carr + Vector3(lato * 0.065, 0.01, 0), "legno_vecchio"))
	r.add_child(scatola(Vector3(0.15, 0.06, 0.18), carr + Vector3(0, 0.05, 0), "canne_sic"))
	r.add_child(mucchio(carr + Vector3(0, 0.08, 0), minerale, 6, 3, 0.03))
	r.add_child(cilindro(0.004, 0.004, 0.2, carr + Vector3(0, 0.03, 0.2), "corda", Vector3(90, 0, 0), 3))
	r.add_child(cilindro(0.05, 0.035, 0.11, Vector3(-0.3, 0.055, 0.42), "paglia", Vector3(0, 0, 8), 10))
	r.add_child(mucchio(Vector3(-0.3, 0.1, 0.42), minerale, 4, 4, 0.025))
	r.add_child(mucchio(Vector3(0.45, 0, 0.35), minerale, 14, 4))
	# lucerna di ceramica su un palo
	r.add_child(cilindro(0.01, 0.012, 0.3, Vector3(0.22, 0.15, 0.3), "corteccia", Vector3.ZERO, 5))
	r.add_child(_vaso_sic(Vector3(0.22, 0.29, 0.3), 0.6, 0))
	r.add_child(sfera(0.014, Vector3(0.22, 0.35, 0.3), "brace"))
	for k in 4:
		r.add_child(cilindro(0.018, 0.018, 0.4, Vector3(-0.55 + k * 0.045, 0.02 + (k % 2) * 0.03, 0.55), "corteccia", Vector3(0, 70, 90), 6))
	r.add_child(_giara(Vector3(0.3, 0, 0.55), 0.85, 0))
	_insegna_sic(r, Vector3(0.62, 0, 0.08), 0.5)
	return r


## Zecca dei Siculi: capanna ovale grande con lo scudo dipinto sulla porta, torretta tonda di pietra a secco del tesoro
## col tettuccio di canne e l'insegna, coppe colme di monete, incudine di pietra per coniare, argento grezzo
## e il guerriero siculo di guardia.
static func zecca_siculi() -> Node3D:
	var r := Node3D.new()
	_capanna_sic(r, Vector3(-0.12, 0, -0.2), 0.37, 0.28, 0.42, 371)
	r.add_child(_scudo_sic(Vector3(-0.12, 0.3, 0.135), 0.0, 0.85))
	# torretta del tesoro
	var tp := Vector3(-0.55, 0, -0.5)
	var ht := 0.44
	r.add_child(cilindro(0.15, 0.18, ht, tp + Vector3(0, ht * 0.5, 0), "pietra_secca", Vector3.ZERO, 16))
	r.add_child(cilindro(0.155, 0.155, 0.03, tp + Vector3(0, ht - 0.08, 0), "vernice_rossa", Vector3.ZERO, 16))
	r.add_child(cilindro(0.2, 0.03, 0.22, tp + Vector3(0, ht + 0.1, 0), "canne_sic", Vector3.ZERO, 16))
	r.add_child(_toro(0.13, 0.145, tp + Vector3(0, ht + 0.08, 0), "corda"))
	r.add_child(scatola(Vector3(0.04, 0.08, 0.03), tp + Vector3(0.1, ht * 0.6, 0.12), "buio", Vector3(0, 40, 0)))
	_insegna_sic(r, Vector3(0.32, 0, 0.12), 0.6)
	# coppe di monete sulla lastra
	_lastra_sic(r, Vector3(0.55, 0, 0.4), 0.38, 0.14, 0.08)
	for k in 3:
		var p := Vector3(0.43 + k * 0.12, 0.095, 0.4)
		r.add_child(_vaso_sic(p, 0.9, 0))
		r.add_child(cilindro(0.04, 0.04, 0.012, p + Vector3(0, 0.08, 0), "moneta", Vector3.ZERO, 10))
	r.add_child(_giara(Vector3(0.66, 0, 0.12), 1.0, 1))
	r.add_child(cilindro(0.04, 0.05, 0.08, Vector3(-0.35, 0.04, 0.5), "corteccia", Vector3.ZERO, 10))
	r.add_child(sfera(0.05, Vector3(-0.35, 0.1, 0.5), "roccia_chiara", Vector3(1.2, 0.6, 1.0)))
	r.add_child(cilindro(0.012, 0.012, 0.06, Vector3(-0.32, 0.15, 0.5), "bronzo", Vector3.ZERO, 6))
	r.add_child(mucchio(Vector3(-0.62, 0, 0.25), "argento_grezzo", 8, 10))
	var g := guerriero_siculo()
	g.position = Vector3(0.18, 0, 0.5)
	g.scale = Vector3.ONE * 0.9
	r.add_child(g)
	return r


## Porto dei Siculi: banchina di pietra a secco, pontile di legno sul mare, bitte di pietra chiara, capanna ovale
## con la tettoia di canne sul davanti, giare dipinte, ceste e sacchi, gru di tronchi con la giara nella rete,
## vela d'ocra rossa arrotolata, ancora di pietra forata e insegna.
static func porto_siculi() -> Node3D:
	var r := Node3D.new()
	var rng := _rng(381)
	r.add_child(scatola(Vector3(0.42, 0.1, 1.08), Vector3(0.36, 0.05, 0.02), "pietra_secca"))
	r.add_child(scatola(Vector3(0.46, 0.025, 1.12), Vector3(0.36, 0.112, 0.02), "pietra_secca"))
	for k in 18:
		r.add_child(sfera(rng.randf_range(0.026, 0.034), Vector3(0.58, 0.11, -0.5 + k * 0.06), "pietra_secca" if k % 3 else "roccia_chiara", Vector3(0.7, 0.6, 1.2)))
	var pz := 0.26
	for k in 4:
		var x := 0.66 + k * 0.13
		for s: int in [-1, 1]:
			r.add_child(cilindro(0.017, 0.019, 0.26, Vector3(x, -0.01, pz + s * 0.12), "corteccia", Vector3.ZERO, 7))
			r.add_child(cilindro(0.02, 0.02, 0.012, Vector3(x, 0.01, pz + s * 0.12), "foglie_scure", Vector3.ZERO, 7))
	for s: int in [-1, 1]:
		r.add_child(scatola(Vector3(0.5, 0.025, 0.02), Vector3(0.82, 0.095, pz + s * 0.12), "legno_vecchio"))
	for k in 13:
		var x := 0.59 + k * 0.038
		r.add_child(scatola(Vector3(0.034, 0.014, 0.28), Vector3(x, 0.112 + rng.randf_range(-0.003, 0.003), pz), "legno_vecchio" if k % 3 else "legno", Vector3(0, rng.randf_range(-2, 2), 0)))
	for z: float in [-0.42, -0.08, 0.5]:
		r.add_child(sfera(0.034, Vector3(0.5, 0.15, z), "roccia_chiara", Vector3(1, 1.4, 1)))
	for x: float in [0.72, 1.02]:
		for s: int in [-1, 1]:
			r.add_child(cilindro(0.014, 0.016, 0.07, Vector3(x, 0.155, pz + s * 0.125), "corteccia", Vector3.ZERO, 7))
	r.add_child(cilindro(0.036, 0.036, 0.014, Vector3(0.5, 0.17, -0.08), "corda", Vector3.ZERO, 10))
	ramo(r, Vector3(0.5, 0.17, -0.08), Vector3(0.66, 0.02, -0.02), 0.005, "corda")
	ramo(r, Vector3(1.02, 0.17, pz + 0.125), Vector3(1.1, 0.03, pz + 0.2), 0.005, "corda")
	# capanna del porto con la tettoia sul davanti
	_capanna_sic(r, Vector3(-0.28, 0, -0.32), 0.33, 0.24, 0.38, 382)
	_tettoia_sic(r, Vector3(-0.28, 0, 0.08), 0.62, 0.22, 0.36, 0.3, 383)
	for i in 3:
		r.add_child(_giara(Vector3(-0.2 + i * 0.1, 0, 0.06), 0.7, i))
	r.add_child(sacco(Vector3(-0.5, 0, 0.06), 0.3))
	r.add_child(scatola(Vector3(0.62, 0.012, 0.5), Vector3(-0.12, 0.006, 0.36), "terra"))
	# fila di giare grandi sulle pietre
	var ra := Vector3(-0.42, 0, 0.4)
	r.add_child(scatola(Vector3(0.32, 0.03, 0.12), ra + Vector3(0, 0.015, -0.06), "pietra_secca"))
	for k in 3:
		r.add_child(_giara(ra + Vector3(-0.1 + k * 0.1, 0.03, -0.06), 0.85, k))
	for k in 2:
		r.add_child(_vaso_sic(ra + Vector3(-0.06 + k * 0.12, 0, 0.1), 1.0, k + 1))
	r.add_child(cesta(Vector3(0.06, 0, 0.42), "pesce"))
	r.add_child(sacco(Vector3(0.18, 0, 0.44), -0.4))
	r.add_child(cesta(Vector3(0.28, 0.125, 0.4), "pesce", 0.8))
	# vela d'ocra arrotolata
	r.add_child(cilindro(0.028, 0.028, 0.18, Vector3(-0.05, 0.03, 0.58), "ocra_rossa", Vector3(0, 70, 90), 10))
	for k in 3:
		r.add_child(cilindro(0.03, 0.03, 0.012, Vector3(-0.05 + (k - 1) * 0.06 * cos(deg_to_rad(70.0)), 0.03, 0.58 - (k - 1) * 0.06 * sin(deg_to_rad(70.0))), "vernice_nera", Vector3(0, 70, 90), 10))
	# gru di tronchi con la giara nella rete
	var g := Node3D.new()
	g.position = Vector3(0.42, 0.125, -0.28)
	r.add_child(g)
	var gc := Vector3(0.36, 0.62, 0.0)
	for s: int in [-1, 1]:
		ramo(g, Vector3(-0.04, 0, s * 0.12), gc, 0.016, "corteccia")
	ramo(g, Vector3(-0.22, 0, 0), gc + Vector3(-0.02, -0.02, 0), 0.012, "legno_vecchio")
	g.add_child(cilindro(0.03, 0.03, 0.2, Vector3(0.0, 0.1, 0), "legno_vecchio", Vector3(90, 0, 0), 10))
	g.add_child(cilindro(0.032, 0.032, 0.06, Vector3(0.0, 0.1, 0), "corda", Vector3(90, 0, 0), 10))
	g.add_child(_toro(0.02, 0.035, gc, "corda", Vector3(90, 0, 0)))
	ramo(g, Vector3(0.0, 0.12, 0), gc, 0.004, "corda")
	ramo(g, gc, gc + Vector3(0, -0.3, 0), 0.004, "corda")
	var gr := _giara(gc + Vector3(0, -0.5, 0), 0.9, 0)
	g.add_child(gr)
	g.add_child(sfera(0.062, gc + Vector3(0, -0.42, 0), "rete", Vector3(1, 1.3, 1)))
	# ancora di pietra forata
	r.add_child(scatola(Vector3(0.1, 0.03, 0.12), Vector3(0.22, 0.14, -0.5), "roccia_chiara", Vector3(0, 20, 0)))
	r.add_child(cilindro(0.016, 0.016, 0.032, Vector3(0.22, 0.14, -0.49), "buio", Vector3.ZERO, 8))
	ramo(r, Vector3(0.22, 0.156, -0.49), Vector3(0.36, 0.13, -0.42), 0.004, "corda")
	_insegna_sic(r, Vector3(0.48, 0.125, 0.42), 0.5)
	return r


## Carbonaia dei Siculi: capannuccia ovale, cupola di legna coperta di terra che fuma, legna, carbone pronto,
## sacchi e giara.
static func carbonaia_siculi() -> Node3D:
	var r := Node3D.new()
	_capanna_sic(r, Vector3(-0.38, 0, -0.38), 0.21, 0.16, 0.22, 391, 0.0, true, 1.35)
	var m := Vector3(0.22, 0, 0.2)
	r.add_child(sfera(0.36, m, "terra", Vector3(1, 0.7, 1)))
	r.add_child(sfera(0.3, m + Vector3(0, 0.03, 0), "fuliggine", Vector3(1, 0.7, 1)))
	r.add_child(sfera(0.37, m + Vector3(0, -0.01, 0), "terra", Vector3(1, 0.68, 1)))
	for k in 9:
		var a := k * TAU / 9
		r.add_child(sfera(0.04, m + Vector3(cos(a) * 0.3, 0.12, sin(a) * 0.3), "frasche", Vector3(1.2, 0.5, 1.0)))
	for k in 5:
		r.add_child(sfera(0.05 + k * 0.012, m + Vector3(0.02 * k, 0.28 + k * 0.07, -0.01 * k), "fumo", Vector3(1, 0.8, 1)))
	r.add_child(scatola(Vector3(0.06, 0.04, 0.04), m + Vector3(0.0, 0.12, 0.33), "buio"))
	legnaia(r, Vector3(-0.55, 0, 0.35), 0.35, 4)
	r.add_child(mucchio(Vector3(0.62, 0, -0.25), "carbone", 12, 5))
	r.add_child(sacco(Vector3(0.6, 0, 0.55), 0.4))
	r.add_child(_giara(Vector3(-0.1, 0, 0.0), 0.8, 1))
	_fascina(r, Vector3(-0.1, 0, 0.62), 70.0)
	return r


## Fonderia dei Siculi: capanna ovale, forno a tino d'argilla sulla base di pietra a secco con la fascia rossa,
## la bocca accesa e il fumo, due mantici di pelle, lingotti, carbone e minerale.
static func fonderia_siculi() -> Node3D:
	var r := Node3D.new()
	_capanna_sic(r, Vector3(-0.25, 0, -0.27), 0.33, 0.25, 0.36, 401)
	var f := Vector3(0.42, 0, 0.36)
	r.add_child(cilindro(0.22, 0.24, 0.1, f + Vector3(0, 0.05, 0), "pietra_secca", Vector3.ZERO, 18))
	r.add_child(cilindro(0.13, 0.2, 0.42, f + Vector3(0, 0.31, 0), "argilla_sic", Vector3.ZERO, 18))
	r.add_child(cilindro(0.17, 0.175, 0.03, f + Vector3(0, 0.25, 0), "vernice_rossa", Vector3.ZERO, 18))
	r.add_child(cilindro(0.16, 0.165, 0.008, f + Vector3(0, 0.275, 0), "vernice_nera", Vector3.ZERO, 18))
	r.add_child(cilindro(0.135, 0.14, 0.06, f + Vector3(0, 0.5, 0), "fuliggine", Vector3.ZERO, 18))
	r.add_child(cilindro(0.1, 0.1, 0.004, f + Vector3(0, 0.531, 0), "brace", Vector3.ZERO, 14))
	r.add_child(scatola(Vector3(0.1, 0.09, 0.05), f + Vector3(-0.05, 0.15, 0.2), "brace", Vector3(0, 25, 0)))
	r.add_child(scatola(Vector3(0.13, 0.03, 0.05), f + Vector3(-0.05, 0.21, 0.2), "roccia_chiara", Vector3(0, 25, 0)))
	_fumo(r, f + Vector3(0, 0.6, 0), 4, 1.1)
	_mantice_sic(r, f + Vector3(-0.38, 0, 0.0), 0.0)
	_mantice_sic(r, f + Vector3(0.0, 0, -0.36), 90.0)
	for k in 6:
		r.add_child(scatola(Vector3(0.09, 0.025, 0.035), Vector3(-0.45 + (k % 3) * 0.1, 0.013 + (k / 3) * 0.026, 0.55), "lingotto"))
	r.add_child(mucchio(Vector3(-0.64, 0, 0.25), "carbone", 9, 6))
	r.add_child(mucchio(Vector3(0.7, 0, -0.12), "minerale", 9, 7))
	r.add_child(_giara(Vector3(0.08, 0, 0.62), 0.8, 0))
	return r


## Fabbro dei Siculi: capanna ovale grande, fucina di pietra a secco sotto la tettoia di canne e frasche, mantice di pelle,
## incudine sul ceppo, attrezzi appesi alla trave, vasca dell'acqua di pietra, lingotti.
static func fabbro_siculi() -> Node3D:
	var r := Node3D.new()
	_capanna_sic(r, Vector3(-0.2, 0, -0.32), 0.36, 0.25, 0.38, 411)
	_tettoia_sic(r, Vector3(-0.2, 0, 0.43), 0.66, 0.32, 0.4, 0.32, 412)
	r.add_child(cilindro(0.11, 0.12, 0.12, Vector3(-0.38, 0.06, 0.42), "pietra_secca", Vector3.ZERO, 14))
	r.add_child(cilindro(0.1, 0.1, 0.012, Vector3(-0.38, 0.126, 0.42), "roccia_chiara", Vector3.ZERO, 14))
	r.add_child(cilindro(0.07, 0.07, 0.01, Vector3(-0.38, 0.134, 0.42), "brace", Vector3.ZERO, 12))
	r.add_child(sfera(0.025, Vector3(-0.38, 0.145, 0.42), "brace", Vector3(1.2, 0.6, 1)))
	_mantice_sic(r, Vector3(-0.6, 0, 0.42), 0.0)
	r.add_child(cilindro(0.04, 0.05, 0.08, Vector3(-0.05, 0.04, 0.45), "corteccia", Vector3.ZERO, 10))
	r.add_child(scatola(Vector3(0.12, 0.04, 0.05), Vector3(-0.05, 0.1, 0.45), "ferro"))
	r.add_child(scatola(Vector3(0.04, 0.025, 0.035), Vector3(0.03, 0.1, 0.45), "ferro"))
	r.add_child(cilindro(0.008, 0.008, 0.6, Vector3(-0.2, 0.3, 0.3), "legno_vecchio", Vector3(0, 0, 90), 5))
	for k in 4:
		var a := attrezzo(ATTREZZI_FABBRO[k])
		a.position = Vector3(-0.42 + k * 0.1, 0.22, 0.31)
		a.rotation_degrees = Vector3(90, 0, 90)
		r.add_child(a)
	_vasca_sic(r, Vector3(0.62, 0, 0.1), 0.07, 0.07)
	for k in 3:
		r.add_child(scatola(Vector3(0.09, 0.025, 0.035), Vector3(0.45, 0.013 + k * 0.026, 0.45), "lingotto"))
	legnaia(r, Vector3(0.62, 0, -0.18), 0.2, 3)
	_fumo(r, Vector3(-0.36, 0.46, 0.44), 3, 0.8)
	return r


## Armaiolo dei Siculi: la bottega del fabbro con la rastrelliera di lance dai nastri d'ocra, scudi rotondi dipinti
## appoggiati, punte di lancia di bronzo sul ceppo e l'elmo di cuoio.
static func armaiolo_siculi() -> Node3D:
	var r := fabbro_siculi()
	_rastrelliera_sic(r, Vector3(0.45, 0, 0.32), 0.0)
	for k in 2:
		var sc := _scudo_sic(Vector3(0.72 + k * 0.02, 0.085, 0.24 + k * 0.17), 80.0 - k * 10.0, 1.05)
		sc.rotation_degrees.x = -12
		r.add_child(sc)
	r.add_child(cilindro(0.06, 0.065, 0.11, Vector3(0.3, 0.055, 0.6), "corteccia", Vector3.ZERO, 12))
	for k in 3:
		r.add_child(cilindro(0.012, 0.0, 0.06, Vector3(0.27 + k * 0.03, 0.118, 0.6), "bronzo", Vector3(0, 0, 90), 6))
	r.add_child(sfera(0.04, Vector3(0.5, 0.03, 0.64), "cuoio", Vector3(1, 0.75, 1.05)))
	r.add_child(cilindro(0.041, 0.042, 0.01, Vector3(0.5, 0.012, 0.64), "pelle_scura", Vector3.ZERO, 12))
	return r


# =================================================================== SICANI (step 26)
# Lo stile dei Sicani, montanari della Sicilia occidentale: villaggi arroccati sugli speroni di roccia, case basse e
# massicce di pietra grigia irregolare messa a secco (senza malta), con grossi blocchi agli angoli e i tetti piatti di
# lastre di pietra coperti di terra e d'erba; terrazzamenti a gradoni sostenuti da muri a secco, cataste di pietre, lame
# e schegge di ossidiana nera lucida portata dalle Eolie. Il colore del popolo è il blu lapislazzuli (stoffe, insegne,
# scudi), con le pagliuzze d'oro della pietra. Ogni modello ha lo stesso ingombro del corrispondente greco (stesso nome
# senza "_sicani").

## Sasso grigio irregolare (scatola un po' storta), il mattone dei muri a secco dei Sicani; il seme sceglie la tinta.
static func _sasso_sic(pos: Vector3, dim: Vector3, rot_y := 0.0, seme := 0) -> MeshInstance3D:
	var mats := ["sasso_sic", "pietra_n_chiara", "roccia_massi", "sasso_sic", "lastra_sic"]
	return scatola(dim, pos, mats[absi(seme) % 5], Vector3((absi(seme) % 5) * 3.0 - 6.0, rot_y, (absi(seme) % 7) * 2.5 - 7.5))


## Casa dei Sicani: bassa e massiccia, muri di pietra grigia irregolare a secco con lo zoccolo a scarpa, grossi blocchi
## agli angoli, travi che sporgono sotto il tetto piatto di lastre di pietra coperto di terra e d'erba (con sassi, ciuffi
## e fiori), porta con l'architrave monolitico e la tenda blu, feritoia sul fianco. pos = centro a terra; la porta guarda
## verso +Z locale (ruotata di rot_y), spostata di porta_x. Restituisce la quota della cima del tetto.
static func _casa_sicana(r: Node3D, pos: Vector3, lx: float, lz: float, h: float, seme: int, rot_y := 0.0, porta := true, porta_x := 0.0, fumo := false) -> float:
	var rng := _rng(seme)
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot_y
	r.add_child(n)
	# zoccolo a scarpa e muro
	var hz := h * 0.4
	n.add_child(scatola(Vector3(lx + 0.05, hz, lz + 0.05), Vector3(0, hz * 0.5, 0), "pietra_sicana"))
	n.add_child(scatola(Vector3(lx, h, lz), Vector3(0, h * 0.5, 0), "pietra_sicana"))
	# sassi sporgenti sulle quattro facce (0: +Z, 1: +X, 2: -Z, 3: -X)
	for f in 4:
		var lung := lx if f % 2 == 0 else lz
		var meta := (lz if f % 2 == 0 else lx) * 0.5
		var a := f * 90.0
		var nk := int(lung * h * (120.0 if f < 2 else 40.0)) + 2
		for k in nk:
			var u := rng.randf_range(-lung * 0.5 + 0.035, lung * 0.5 - 0.035)
			var y := rng.randf_range(0.025, h - 0.03)
			var sp := meta + (0.025 if y < hz else 0.0) + 0.006
			var p := Vector3(u, y, sp).rotated(Vector3.UP, deg_to_rad(a))
			n.add_child(_sasso_sic(p, Vector3(rng.randf_range(0.045, 0.085), rng.randf_range(0.026, 0.046), 0.022), a + rng.randf_range(-3.0, 3.0), k * 3 + f))
	# grossi blocchi d'angolo, alternati lunghi e corti
	for cx: int in [-1, 1]:
		for cz: int in [-1, 1]:
			var y := 0.0
			var j := 0
			while y < h - 0.035:
				var bh := minf(rng.randf_range(0.07, 0.1), h - y)
				var fuori := 0.026 if y < hz else 0.012
				var lungo := (j + cx + cz) % 2 == 0
				var d := Vector3(0.15 if lungo else 0.085, bh - 0.008, 0.085 if lungo else 0.15)
				n.add_child(scatola(d, Vector3(cx * (lx * 0.5 - d.x * 0.5 + fuori), y + bh * 0.5, cz * (lz * 0.5 - d.z * 0.5 + fuori)), "sasso_sic" if j % 2 == 0 else "pietra_n_chiara", Vector3(0, rng.randf_range(-4.0, 4.0), rng.randf_range(-2.0, 2.0))))
				y += bh
				j += 1
	# travi che sporgono sotto il tetto, davanti e dietro
	var nt := maxi(2, int(lx / 0.12))
	for k in nt:
		var x := -lx * 0.5 + (k + 0.5) * lx / nt
		n.add_child(cilindro(0.017, 0.019, lz + 0.13, Vector3(x, h - 0.022, 0), "legno_vecchio", Vector3(90, 0, 0), 6))
	# tetto piatto: lastre che sporgono, terra, cuscino d'erba
	n.add_child(scatola(Vector3(lx + 0.1, 0.03, lz + 0.1), Vector3(0, h + 0.015, 0), "lastra_sic"))
	for f in 4:
		var lung := (lx if f % 2 == 0 else lz) + 0.1
		var meta := (lz if f % 2 == 0 else lx) * 0.5 + 0.05
		var a := f * 90.0
		var nl := int(lung / 0.09) + 1
		for k in nl:
			var u := -lung * 0.5 + (k + 0.5) * lung / nl
			var p := Vector3(u, h + 0.014 + rng.randf_range(-0.006, 0.006), meta + rng.randf_range(-0.01, 0.018)).rotated(Vector3.UP, deg_to_rad(a))
			n.add_child(scatola(Vector3(lung / nl + 0.02, 0.022, rng.randf_range(0.07, 0.1)), p, "lastra_sic" if k % 3 != 0 else "sasso_sic", Vector3(rng.randf_range(-5.0, 5.0), a + rng.randf_range(-7.0, 7.0), 0)))
	n.add_child(scatola(Vector3(lx + 0.02, 0.03, lz + 0.02), Vector3(0, h + 0.045, 0), "terra"))
	n.add_child(sfera(0.5, Vector3(0, h + 0.058, 0), "erba_tetto", Vector3(lx + 0.03, 0.075, lz + 0.03)))
	# ciuffi d'erba, sassi che tengono il tetto, fiori
	for k in int(lx * lz * 70.0) + 5:
		var px := rng.randf_range(-lx * 0.46, lx * 0.46)
		var pz := rng.randf_range(-lz * 0.46, lz * 0.46)
		var q := (px / (lx * 0.5)) * (px / (lx * 0.5)) + (pz / (lz * 0.5)) * (pz / (lz * 0.5))
		var py := h + 0.058 + 0.0375 * sqrt(maxf(0.0, 1.0 - q)) if q < 1.0 else h + 0.06
		var p := Vector3(px, py, pz)
		if k % 6 == 0:
			n.add_child(_sasso_sic(p, Vector3(0.05, 0.03, 0.04), rng.randf() * 90.0, k))
		elif k % 9 == 4:
			n.add_child(sfera(0.012, p + Vector3(0, 0.012, 0), "fiore"))
		else:
			n.add_child(sfera(rng.randf_range(0.022, 0.036), p, "prato" if k % 3 == 0 else ("foglie_chiare" if k % 3 == 1 else "erba_tetto"), Vector3(1.2, 0.6, 1.2)))
	if fumo:
		var fp := Vector3(lx * 0.28, h + 0.08, -lz * 0.22)
		for k in 6:
			var ak := k * TAU / 6
			n.add_child(sfera(0.022, fp + Vector3(cos(ak), 0, sin(ak)) * 0.04, "sasso_sic", Vector3(1.2, 0.8, 1)))
		n.add_child(cilindro(0.028, 0.028, 0.01, fp + Vector3(0, 0.008, 0), "buio", Vector3.ZERO, 8))
		_fumo(n, fp + Vector3(0, 0.05, 0), 3, 0.8)
	if porta:
		var hp := minf(0.21, h - 0.12)
		_porta_sicana(n, Vector3(porta_x, 0, lz * 0.5 + 0.026), 0.0, minf(0.13, lx * 0.3), hp, h - hp > 0.17)
	# feritoia sul fianco destro
	if lz > 0.3:
		n.add_child(scatola(Vector3(0.012, 0.07, 0.035), Vector3(lx * 0.5 + 0.004, h * 0.6, -lz * 0.12), "buio"))
		n.add_child(scatola(Vector3(0.03, 0.026, 0.1), Vector3(lx * 0.5 + 0.012, h * 0.6 + 0.048, -lz * 0.12), "lastra_sic"))
	return h + 0.1


## Porta dei Sicani (guarda verso +Z locale): vano buio fra due stipiti monolitici grigi, grande architrave di pietra
## grezza, tenda blu lapislazzuli con i rombi bianchi, soglia di lastra e corna di montone appese sopra.
static func _porta_sicana(r: Node3D, pos: Vector3, rot_y := 0.0, w := 0.13, h := 0.2, corna := true) -> void:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot_y
	r.add_child(n)
	n.add_child(scatola(Vector3(w, h, 0.12), Vector3(0, h * 0.5, -0.05), "buio"))
	for lato: int in [-1, 1]:
		n.add_child(scatola(Vector3(0.05, h + 0.01, 0.06), Vector3(lato * (w * 0.5 + 0.025), (h + 0.01) * 0.5, 0.0), "sasso_sic", Vector3(0, 0, lato * 1.5)))
	n.add_child(scatola(Vector3(w + 0.17, 0.06, 0.075), Vector3(0, h + 0.04, 0.005), "pietra_n_chiara", Vector3(0, 0, -2)))
	n.add_child(scatola(Vector3(w * 0.66, h - 0.015, 0.008), Vector3(w * 0.17, h * 0.5 + 0.005, 0.012), "lapislazzuli", Vector3(0, 0, -2)))
	for k in 3:
		n.add_child(scatola(Vector3(0.015, 0.015, 0.01), Vector3(w * 0.17 - w * 0.2 + k * w * 0.2, h * 0.28, 0.016), "lino_bianco", Vector3(0, 0, 45)))
	n.add_child(scatola(Vector3(w * 0.66, 0.012, 0.01), Vector3(w * 0.17, 0.018, 0.016), "lino_bianco"))
	n.add_child(scatola(Vector3(w + 0.07, 0.016, 0.09), Vector3(0, 0.008, 0.045), "lastra_sic"))
	if corna:
		var c := Vector3(0, h + 0.1, 0.035)
		n.add_child(sfera(0.019, c, "osso", Vector3(0.85, 1.1, 0.7)))
		for lato: int in [-1, 1]:
			n.add_child(_toro(0.007, 0.02, c + Vector3(lato * 0.028, 0.006, -0.004), "osso", Vector3(90, 0, 0)))


## Muro di pietra grigia a secco da un punto a un altro: corpo di sassi irregolari, sassi sporgenti, lastre piatte in cima.
static func _muro_sic(r: Node3D, da: Vector3, a: Vector3, h := 0.1, sp := 0.08) -> void:
	var d := a - da
	d.y = 0.0
	var lung := d.length()
	var n := Node3D.new()
	n.position = Vector3((da.x + a.x) * 0.5, da.y, (da.z + a.z) * 0.5)
	n.rotation.y = atan2(-d.z, d.x)
	r.add_child(n)
	n.add_child(scatola(Vector3(lung, h, sp), Vector3(0, h * 0.5, 0), "pietra_sicana"))
	var rng := _rng(int(absf(da.x * 977.0 + da.z * 131.0 + a.x * 53.0 + a.z * 7.0)) + 11)
	var nk := maxi(2, int(lung / 0.075))
	for k in nk:
		var x := -lung * 0.5 + (k + 0.5) * lung / nk
		n.add_child(scatola(Vector3(lung / nk + 0.012, 0.018, sp + 0.026), Vector3(x, h + 0.007, rng.randf_range(-0.006, 0.006)), "lastra_sic" if k % 3 != 0 else "sasso_sic", Vector3(rng.randf_range(-4.0, 4.0), rng.randf_range(-9.0, 9.0), rng.randf_range(-3.0, 3.0))))
		for lato: int in [-1, 1]:
			if rng.randf() < 0.75:
				n.add_child(_sasso_sic(Vector3(x + rng.randf_range(-0.02, 0.02), rng.randf_range(0.02, maxf(0.025, h - 0.025)), lato * sp * 0.5), Vector3(rng.randf_range(0.035, 0.06), rng.randf_range(0.022, 0.036), 0.018), 0.0, k + lato + 2))


## Terrazzamenti a gradoni: n ripiani che salgono verso -Z, ognuno sostenuto sul davanti da un muro di pietra a secco
## con le lastre di copertina; sopra ogni ripiano uno strato di `sopra`. pos = centro dell'ingombro, a terra.
## Il centro del ripiano k (0 = il più basso, davanti) è pos + (0, (k+1)·hs, prof/2 − (k+0.5)·prof/n).
static func _gradoni(r: Node3D, pos: Vector3, larg: float, prof: float, n: int, hs: float, sopra := "terra", seme := 0) -> void:
	var rng := _rng(seme + 5)
	var ps := prof / n
	for k in n:
		var dz := prof - k * ps
		var yk := (k + 1) * hs
		r.add_child(scatola(Vector3(larg, yk, dz), pos + Vector3(0, yk * 0.5, -prof * 0.5 + dz * 0.5), "pietra_sicana"))
		r.add_child(scatola(Vector3(larg - 0.012, 0.014, ps - 0.03), pos + Vector3(0, yk + 0.004, prof * 0.5 - (k + 0.5) * ps - 0.012), sopra))
		var zf := prof * 0.5 - k * ps
		var nk := maxi(2, int(larg / 0.07))
		for j in nk:
			var x := -larg * 0.5 + (j + 0.5) * larg / nk
			for f in maxi(1, int(hs / 0.05)):
				r.add_child(_sasso_sic(pos + Vector3(x + rng.randf_range(-0.015, 0.015), k * hs + (f + 0.5) * hs / maxi(1, int(hs / 0.05)), zf + 0.006), Vector3(rng.randf_range(0.045, 0.07), minf(0.04, hs * 0.7), 0.018), 0.0, j + k * 3 + f))
			r.add_child(scatola(Vector3(larg / nk + 0.014, 0.014, 0.05), pos + Vector3(x, yk + 0.006, zf - 0.016), "lastra_sic" if j % 3 != 1 else "sasso_sic", Vector3(0, rng.randf_range(-6.0, 6.0), rng.randf_range(-3.0, 3.0))))
		# sassi sul fianco destro (+X) del ripiano
		for j in maxi(1, int(ps / 0.07)):
			var z := zf - (j + 0.5) * ps / maxi(1, int(ps / 0.07))
			r.add_child(_sasso_sic(pos + Vector3(larg * 0.5 + 0.006, rng.randf_range(0.02, yk - 0.015), z), Vector3(rng.randf_range(0.045, 0.065), minf(0.035, yk * 0.6), 0.018), 90.0, j + k + 1))


## Catasta di pietre grigie raccolte nei campi (tre strati che si restringono).
static func _catasta_pietre(r: Node3D, pos: Vector3, s := 1.0, seme := 0) -> void:
	var rng := _rng(seme + 21)
	for f in 3:
		var nf := 4 - f
		for k in nf:
			for j in 2:
				var p := pos + Vector3((k - (nf - 1) * 0.5) * 0.068 + rng.randf_range(-0.008, 0.008), 0.021 + f * 0.038, (j - 0.5) * (0.062 - f * 0.012)) * s
				r.add_child(_sasso_sic(p, Vector3(0.064, 0.04, 0.056) * s * rng.randf_range(0.85, 1.1), rng.randf_range(-25.0, 25.0), k + j * 2 + f * 3))


## Blocco di ossidiana: vetro vulcanico nero lucido a facce taglienti, con un po' di crosta grigia e riflessi chiari.
static func _blocco_oss(pos: Vector3, s := 1.0, seme := 0) -> Node3D:
	var n := Node3D.new()
	n.position = pos
	n.scale = Vector3.ONE * s
	n.rotation_degrees.y = seme * 47.0
	var rng := _rng(seme + 400)
	n.add_child(sfera(0.03, Vector3(-0.02, 0.018, -0.018), "sasso_sic", Vector3(1.1, 0.5, 0.9)))
	for k in 4:
		n.add_child(scatola(Vector3(rng.randf_range(0.04, 0.065), rng.randf_range(0.035, 0.055), rng.randf_range(0.04, 0.06)), Vector3(rng.randf_range(-0.015, 0.02), 0.03 + k * 0.007, rng.randf_range(-0.01, 0.02)), "ossidiana", Vector3(rng.randf_range(-35.0, 35.0), rng.randf_range(0.0, 90.0), rng.randf_range(-35.0, 35.0))))
	n.add_child(scatola(Vector3(0.034, 0.004, 0.006), Vector3(0.006, 0.07, 0.022), "riflesso_oss", Vector3(15, 25, 10)))
	n.add_child(scatola(Vector3(0.006, 0.026, 0.004), Vector3(0.03, 0.045, 0.032), "riflesso_oss", Vector3(-10, 40, 15)))
	return n


## Lama di ossidiana: scheggia lunga, sottile e appuntita, nera e lucida, con il filo chiaro; distesa lungo +X locale.
## Con il manico ha l'impugnatura di legno legata col cuoio.
static func _lama_oss(pos: Vector3, rot := Vector3.ZERO, lung := 0.09, manico := false) -> Node3D:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees = rot
	var l := cilindro(0.017, 0.0, lung, Vector3(lung * 0.1, 0, 0), "ossidiana", Vector3(0, 0, -90), 6)
	l.scale = Vector3(0.4, 1, 1)
	n.add_child(l)
	n.add_child(scatola(Vector3(lung * 0.6, 0.002, 0.0025), Vector3(lung * 0.05, 0.0045, 0.004), "riflesso_oss"))
	if manico:
		n.add_child(cilindro(0.008, 0.009, lung * 0.5, Vector3(-lung * 0.6, 0, 0), "legno", Vector3(0, 0, 90), 6))
		n.add_child(cilindro(0.0095, 0.0095, lung * 0.18, Vector3(-lung * 0.42, 0, 0), "cuoio", Vector3(0, 0, 90), 6))
	return n


## Specchio d'ossidiana: disco nero lucidato, cornice di cuoio, riflesso chiaro, su un piedino di legno (faccia +Z locale).
static func _specchio_oss(pos: Vector3, rot_y := 0.0, s := 1.0) -> Node3D:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot_y
	n.scale = Vector3.ONE * s
	n.add_child(scatola(Vector3(0.05, 0.02, 0.04), Vector3(0, 0.01, 0), "legno_vecchio"))
	n.add_child(cilindro(0.04, 0.04, 0.01, Vector3(0, 0.062, 0), "ossidiana", Vector3(80, 0, 0), 16))
	n.add_child(_toro(0.038, 0.046, Vector3(0, 0.062, 0), "cuoio", Vector3(80, 0, 0)))
	n.add_child(scatola(Vector3(0.006, 0.04, 0.003), Vector3(-0.012, 0.07, 0.007), "riflesso_oss", Vector3(-10, 0, 30)))
	return n


## Arco di legno (vista di traverso, nel piano YZ locale): impugnatura legata di blu all'origine, flettenti che
## piegano verso -Z, puntali d'osso e corda tesa fra le punte.
static func _arco_sic(r: Node3D, presa: Vector3, h := 0.21, curva := 0.055, rot := Vector3.ZERO) -> void:
	var n := Node3D.new()
	n.position = presa
	n.rotation_degrees = rot
	r.add_child(n)
	var pts: Array[Vector3] = []
	for i in 7:
		var t := -1.0 + i / 3.0
		pts.append(Vector3(0, t * h * 0.5, -curva * t * t))
	for i in 6:
		ramo(n, pts[i], pts[i + 1], 0.009, "legno_scuro")
	n.add_child(cilindro(0.009, 0.009, 0.035, Vector3.ZERO, "lapislazzuli", Vector3.ZERO, 6))
	for i: int in [0, 6]:
		n.add_child(sfera(0.007, pts[i], "osso"))
	n.add_child(cilindro(0.0015, 0.0015, h, Vector3(0, 0, -curva), "lino_bianco", Vector3.ZERO, 3))


## Faretra di cuoio con le fasce blu e le frecce impennate di bianco e di blu (asse lungo +Y locale).
static func _faretra(pos: Vector3, rot := Vector3.ZERO, s := 1.0) -> Node3D:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees = rot
	n.scale = Vector3.ONE * s
	n.add_child(cilindro(0.026, 0.021, 0.2, Vector3.ZERO, "cuoio", Vector3.ZERO, 8))
	n.add_child(cilindro(0.0275, 0.0275, 0.016, Vector3(0, 0.075, 0), "lapislazzuli", Vector3.ZERO, 8))
	n.add_child(cilindro(0.023, 0.023, 0.012, Vector3(0, -0.06, 0), "lapislazzuli", Vector3.ZERO, 8))
	for k in 4:
		var p := Vector3((k % 2) * 0.016 - 0.008, 0.12, (k / 2) * 0.016 - 0.008)
		n.add_child(cilindro(0.003, 0.003, 0.08, p + Vector3(0, -0.015, 0), "legno", Vector3.ZERO, 4))
		n.add_child(scatola(Vector3(0.004, 0.035, 0.016), p + Vector3(0, 0.018, 0), "lino_bianco" if k % 2 == 0 else "lapislazzuli", Vector3(0, k * 45, 0)))
	return n


## Insegna dei Sicani: asta di legno con la traversa, drappo blu lapislazzuli con il monte bianco a gradoni e le
## pagliuzze d'oro, frange bianche e blu; in cima corna di montone e una punta d'ossidiana.
static func _insegna_sicana(r: Node3D, pos: Vector3, h := 0.6) -> void:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = 45
	r.add_child(n)
	n.add_child(cilindro(0.012, 0.015, h, Vector3(0, h * 0.5, 0), "corteccia", Vector3.ZERO, 6))
	n.add_child(cilindro(0.008, 0.008, 0.2, Vector3(0, h - 0.05, 0.01), "legno_vecchio", Vector3(0, 0, 90), 5))
	n.add_child(scatola(Vector3(0.17, 0.22, 0.006), Vector3(0, h - 0.165, 0.014), "lapislazzuli"))
	for k in 3:
		n.add_child(scatola(Vector3(0.13 - k * 0.042, 0.024, 0.008), Vector3(0, h - 0.232 + k * 0.024, 0.016), "lino_bianco"))
	for p: Vector2 in [Vector2(-0.055, -0.085), Vector2(0.05, -0.095), Vector2(0.02, -0.125), Vector2(-0.035, -0.14), Vector2(0.065, -0.15)]:
		n.add_child(sfera(0.008, Vector3(p.x, h + p.y, 0.017), "oro_n"))
	for k in 5:
		n.add_child(scatola(Vector3(0.022, 0.04, 0.006), Vector3(-0.068 + k * 0.034, h - 0.29, 0.014), "lapislazzuli" if k % 2 == 0 else "lino_bianco"))
	n.add_child(sfera(0.022, Vector3(0, h + 0.012, 0), "osso", Vector3(0.9, 1.0, 1.1)))
	for lato: int in [-1, 1]:
		n.add_child(_toro(0.008, 0.026, Vector3(lato * 0.032, h + 0.028, 0.0), "osso", Vector3(90, 0, 0)))
	n.add_child(cilindro(0.017, 0.0, 0.075, Vector3(0, h + 0.07, 0), "ossidiana", Vector3.ZERO, 5))


## Scudo dei Sicani (faccia verso +Z locale): ovale alto di cuoio dipinto di blu lapislazzuli, orlo di cuoio, fascia
## di rombi bianchi e umbone d'ossidiana.
static func _scudo_sicano(pos: Vector3, rot_y := 0.0, s := 1.0) -> Node3D:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot_y
	n.scale = Vector3.ONE * s
	var o := Node3D.new()
	o.scale = Vector3(0.72, 1.15, 1)
	n.add_child(o)
	o.add_child(cilindro(0.085, 0.085, 0.012, Vector3.ZERO, "lapislazzuli", Vector3(90, 0, 0), 18))
	o.add_child(_toro(0.08, 0.091, Vector3.ZERO, "cuoio", Vector3(90, 0, 0)))
	for k in 5:
		n.add_child(scatola(Vector3(0.017, 0.017, 0.004), Vector3(0.0, -0.068 + k * 0.034, 0.009), "lino_bianco", Vector3(0, 0, 45)))
	n.add_child(sfera(0.018, Vector3(0, 0, 0.011), "ossidiana", Vector3(1, 1, 0.6)))
	return n


## Tettoia dei Sicani su pali con la base di sasso: piano di tavole coperto di lastre di pietra (tenute da sassi, con
## qualche ciuffo d'erba), alta dietro (-Z) e bassa davanti (+Z). pos = centro a terra.
static func _tettoia_sicana(r: Node3D, pos: Vector3, larg: float, prof: float, h_alta: float, h_bassa: float, seme := 1) -> void:
	var rng := _rng(seme)
	var dh := h_alta - h_bassa
	var ang := atan2(dh, prof)
	var lung := sqrt(prof * prof + dh * dh) + 0.1
	var xs := [-larg * 0.5, larg * 0.5]
	if larg > 0.7:
		xs.append(0.0)
	for x: float in xs:
		for z: float in [prof * 0.5, -prof * 0.5]:
			var hp := h_bassa if z > 0.0 else h_alta
			r.add_child(cilindro(0.016, 0.019, hp, pos + Vector3(x, hp * 0.5, z), "corteccia", Vector3.ZERO, 6))
			r.add_child(_sasso_sic(pos + Vector3(x, 0.02, z), Vector3(0.06, 0.04, 0.06), 20.0, int(x * 10.0 + z * 10.0) + 3))
	r.add_child(cilindro(0.017, 0.017, larg + 0.1, pos + Vector3(0, h_bassa - 0.005, prof * 0.5), "legno_vecchio", Vector3(0, 0, 90), 6))
	r.add_child(cilindro(0.017, 0.017, larg + 0.1, pos + Vector3(0, h_alta - 0.005, -prof * 0.5), "legno_vecchio", Vector3(0, 0, 90), 6))
	var ym := (h_alta + h_bassa) * 0.5 + 0.018
	var c := pos + Vector3(0, ym, 0)
	var asse_t := Vector3(0, -sin(ang), cos(ang))
	var norm := Vector3(0, cos(ang), sin(ang))
	r.add_child(scatola(Vector3(larg + 0.12, 0.022, lung), c, "legno_vecchio", Vector3(rad_to_deg(ang), 0, 0)))
	var nl := maxi(2, int((larg + 0.12) / 0.1))
	var nf := maxi(2, int(lung / 0.1))
	for i in nl:
		for j in nf:
			var x := -(larg + 0.12) * 0.5 + (i + 0.5) * (larg + 0.12) / nl
			var t := -lung * 0.5 + (j + 0.5) * lung / nf
			var p := c + Vector3(x, 0, 0) + asse_t * t + norm * (0.018 + rng.randf_range(-0.003, 0.004))
			r.add_child(scatola(Vector3((larg + 0.12) / nl + 0.016, 0.016, lung / nf + 0.016), p, "lastra_sic" if (i + j) % 4 != 0 else "sasso_sic", Vector3(rad_to_deg(ang) + rng.randf_range(-4.0, 4.0), rng.randf_range(-6.0, 6.0), rng.randf_range(-3.0, 3.0))))
	for k in int(larg * 6.0) + 1:
		var t := rng.randf_range(-0.35, 0.35) * lung
		var p := c + Vector3(rng.randf_range(-larg * 0.45, larg * 0.45), 0, 0) + asse_t * t + norm * 0.04
		if k % 2 == 0:
			r.add_child(_sasso_sic(p, Vector3(0.05, 0.032, 0.045), rng.randf() * 90.0, k))
		else:
			r.add_child(sfera(0.026, p, "erba_tetto", Vector3(1.2, 0.5, 1.2)))


## Forno dei Sicani a falsa cupola: base quadrata di pietra a secco, cupola di pietre grigie coperta di terra e d'erba,
## bocca con l'architrave di lastra e le braci verso +Z, sfiatatoio e fumo.
static func _forno_sicano(r: Node3D, pos: Vector3, s := 1.0, fumo := true) -> void:
	r.add_child(scatola(Vector3(0.44, 0.12, 0.44) * s, pos + Vector3(0, 0.06 * s, 0), "pietra_sicana"))
	for k in 10:
		var a := deg_to_rad(-40.0 + k * 16.0)
		r.add_child(_sasso_sic(pos + Vector3(sin(a), 0, cos(a)) * 0.205 * s + Vector3(0, 0.135 * s, 0), Vector3(0.06, 0.035, 0.03) * s, rad_to_deg(a), k))
	r.add_child(sfera(0.2 * s, pos + Vector3(0, 0.12 * s, 0), "pietra_sicana", Vector3(1, 0.95, 1)))
	r.add_child(sfera(0.165 * s, pos + Vector3(0, 0.205 * s, -0.015 * s), "erba_tetto", Vector3(1, 0.62, 1)))
	for k in 5:
		var a := k * TAU / 5 + 0.3
		r.add_child(sfera(0.024 * s, pos + Vector3(cos(a) * 0.1, 0.29, sin(a) * 0.1) * s, "prato" if k % 2 == 0 else "foglie_chiare", Vector3(1.2, 0.6, 1.2)))
	var b := pos + Vector3(0, 0, 0.2 * s)
	r.add_child(scatola(Vector3(0.16, 0.14, 0.1) * s, b + Vector3(0, 0.07 * s, 0), "sasso_sic"))
	r.add_child(scatola(Vector3(0.09, 0.08, 0.02) * s, b + Vector3(0, 0.055 * s, 0.045 * s), "buio"))
	r.add_child(sfera(0.032 * s, b + Vector3(0, 0.03 * s, 0.05 * s), "brace", Vector3(1.2, 0.6, 0.8)))
	r.add_child(scatola(Vector3(0.2, 0.035, 0.11) * s, b + Vector3(0, 0.15 * s, 0.005 * s), "lastra_sic", Vector3(0, 0, -3)))
	r.add_child(scatola(Vector3(0.1, 0.05, 0.012) * s, b + Vector3(0, 0.2 * s, -0.02 * s), "fuliggine", Vector3(-20, 0, 0)))
	r.add_child(cilindro(0.03 * s, 0.035 * s, 0.05 * s, pos + Vector3(0.02, 0.33, -0.03) * s, "sasso_sic", Vector3.ZERO, 6))
	if fumo:
		_fumo(r, pos + Vector3(0.02 * s, 0.38 * s, -0.03 * s), 4, s)


## Rastrelliera degli arcieri: due pali con la traversa, archi appesi, faretre appoggiate e uno scudo blu.
static func _rastrelliera_archi(r: Node3D, pos: Vector3, rot_y := 0.0) -> void:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot_y
	r.add_child(n)
	for lato: int in [-1, 1]:
		n.add_child(cilindro(0.012, 0.014, 0.32, Vector3(lato * 0.14, 0.16, 0), "corteccia", Vector3.ZERO, 6))
	n.add_child(cilindro(0.009, 0.009, 0.32, Vector3(0, 0.29, 0), "legno_vecchio", Vector3(0, 0, 90), 5))
	for k in 3:
		_arco_sic(n, Vector3(-0.09 + k * 0.09, 0.18, 0.012), 0.22, 0.045, Vector3(0, 90, 0))
	for k in 2:
		n.add_child(_faretra(Vector3(-0.06 + k * 0.1, 0.1, 0.06), Vector3(-15, 0, -8 + k * 16), 1.0))
	n.add_child(_scudo_sicano(Vector3(0.21, 0.1, 0.05), 20.0, 1.0))


## Ripiano di un gradone coltivato: file di piante su una striscia larga `larg` e profonda `prof` (centro pos).
static func _coltura_sic(r: Node3D, pos: Vector3, larg: float, prof: float, tipo := "grano", seme := 0) -> void:
	var rng := _rng(seme + 31)
	var nx := int(larg / 0.06)
	var nz := maxi(1, int(prof / 0.07))
	for i in nx:
		for j in nz:
			var p := pos + Vector3(-larg * 0.5 + (i + 0.5) * larg / nx, 0, -prof * 0.5 + (j + 0.5) * prof / nz)
			match tipo:
				"grano":
					r.add_child(cilindro(0.012, 0.017, 0.1, p + Vector3(0, 0.05, 0), "grano", Vector3.ZERO, 5))
				"orto":
					r.add_child(sfera(rng.randf_range(0.02, 0.028), p + Vector3(0, 0.02, 0), "orto" if (i + j) % 2 == 0 else "foglie_chiare", Vector3(1, 0.8, 1)))
				_:
					r.add_child(cilindro(0.005, 0.005, 0.05, p + Vector3(0, 0.025, 0), "corteccia", Vector3.ZERO, 4))
					r.add_child(sfera(0.03 + rng.randf() * 0.012, p + Vector3(0, 0.07, 0), "foglie_ulivo" if (i + j) % 2 == 0 else "foglie", Vector3(1, 0.85, 1)))


# ------------------------------------------------------------------ edifici dei Sicani

## Casa dei Sicani: casa bassa di pietra a secco col tetto d'erba sopra un basso terrazzamento, dispensa accanto,
## focolare all'aperto con la pentola, panca di lastra, orto a due gradoni, catasta di pietre e una capra.
static func casa_greca_sicani(seme := 1) -> Node3D:
	var r := Node3D.new()
	_gradoni(r, Vector3(-0.12, 0, -0.2), 0.98, 0.74, 1, 0.06, "terra", seme)
	_casa_sicana(r, Vector3(-0.13, 0.06, -0.24), 0.8, 0.54, 0.34, seme, 0.0, true, -0.14, true)
	_casa_sicana(r, Vector3(-0.66, 0, 0.32), 0.28, 0.26, 0.22, seme + 7, 90.0, true)
	# focolare con la pentola, panca di lastra, ceste
	_fuoco(r, Vector3(0.24, 0, 0.36), 0.8)
	r.add_child(cilindro(0.04, 0.032, 0.05, Vector3(0.24, 0.07, 0.36), "terracotta", Vector3.ZERO, 10))
	_fumo(r, Vector3(0.26, 0.16, 0.34), 3, 0.8)
	r.add_child(scatola(Vector3(0.24, 0.03, 0.08), Vector3(-0.22, 0.075, 0.36), "lastra_sic", Vector3(0, 8, 0)))
	for lato: int in [-1, 1]:
		r.add_child(_sasso_sic(Vector3(-0.22 + lato * 0.08, 0.03, 0.36), Vector3(0.05, 0.06, 0.06), 8.0, lato + 2))
	r.add_child(cesta(Vector3(0.04, 0, 0.42), "olive"))
	r.add_child(anfora(Vector3(-0.04, 0, 0.5), 1.1))
	r.add_child(sacco(Vector3(0.36, 0, -0.06), 0.4))
	_catasta_pietre(r, Vector3(0.36, 0, -0.34), 0.9, seme)
	# orto su due gradoni
	var o := Vector3(0.56, 0, 0.44)
	_gradoni(r, o, 0.36, 0.4, 2, 0.05, "terra", seme + 3)
	for k in 2:
		_coltura_sic(r, o + Vector3(0, (k + 1) * 0.05 + 0.01, 0.2 - (k + 0.5) * 0.2 - 0.01), 0.3, 0.12, "orto", seme + k)
	r.add_child(capra(Vector3(-0.36, 0, 0.56), 60))
	return r


## Magazzino dei Sicani: casa lunga di pietra e una casa-torre bassa col tetto d'erba, cortile lastricato chiuso dal muro
## a secco con la porta a trilite, sacchi e casse sotto la tettoia di lastre, file di grandi orci, cataste di pietre e di
## tronchi, asino con le ceste e l'insegna blu.
static func magazzino_sicani() -> Node3D:
	var r := Node3D.new()
	r.position = Vector3(0, 0, -0.1)
	r.add_child(scatola(Vector3(2.0, 0.02, 1.6), Vector3(0, 0.01, 0.05), "terra"))
	var rng := _rng(30)
	for i in 12:
		for j in 5:
			var p := Vector3(-0.86 + i * 0.155 + rng.randf_range(-0.02, 0.02), 0.022, 0.06 + j * 0.15 + rng.randf_range(-0.02, 0.02))
			r.add_child(scatola(Vector3(rng.randf_range(0.11, 0.14), 0.012, rng.randf_range(0.1, 0.13)), p, "lastra_sic" if (i + j) % 3 != 0 else "pietra_n_chiara", Vector3(0, rng.randf_range(-12.0, 12.0), 0)))
	_casa_sicana(r, Vector3(-0.22, 0, -0.38), 1.3, 0.6, 0.44, 31, 0.0, true, -0.3, true)
	_casa_sicana(r, Vector3(0.7, 0, -0.42), 0.46, 0.48, 0.56, 32, 0.0, true)
	# muro a secco attorno al cortile, con la porta a trilite davanti
	_muro_sic(r, Vector3(-0.98, 0, -0.62), Vector3(-0.98, 0, 0.82), 0.14, 0.1)
	_muro_sic(r, Vector3(-0.98, 0, 0.82), Vector3(-0.22, 0, 0.82), 0.14, 0.1)
	_muro_sic(r, Vector3(0.22, 0, 0.82), Vector3(0.98, 0, 0.82), 0.14, 0.1)
	_muro_sic(r, Vector3(0.98, 0, 0.82), Vector3(0.98, 0, -0.2), 0.14, 0.1)
	for x: float in [-0.2, 0.2]:
		r.add_child(scatola(Vector3(0.1, 0.3, 0.12), Vector3(x, 0.15, 0.82), "sasso_sic", Vector3(0, 0, 2 * signf(x))))
	r.add_child(scatola(Vector3(0.6, 0.07, 0.15), Vector3(0, 0.335, 0.82), "pietra_n_chiara", Vector3(0, 0, -1.5)))
	r.add_child(sfera(0.022, Vector3(0, 0.39, 0.86), "osso", Vector3(0.85, 1.1, 0.7)))
	for lato: int in [-1, 1]:
		r.add_child(_toro(0.008, 0.024, Vector3(lato * 0.032, 0.395, 0.86), "osso", Vector3(90, 0, 0)))
	# file di grandi orci e casse a sinistra
	for j in 2:
		for i in 4:
			r.add_child(anfora(Vector3(-0.82 + i * 0.17 + j * 0.08, 0, 0.22 + j * 0.2), 1.6))
	for i in 3:
		r.add_child(cassa(Vector3(-0.8 + i * 0.14, 0, 0.64), i * 10.0, 0.12))
	r.add_child(cassa(Vector3(-0.73, 0.1, 0.64), 25.0, 0.1))
	# tettoia di lastre sopra sacchi e ceste a destra
	_tettoia_sicana(r, Vector3(0.66, 0, 0.24), 0.5, 0.34, 0.42, 0.33, 33)
	for i in 3:
		r.add_child(sacco(Vector3(0.5 + i * 0.12, 0, 0.16), i * 0.6))
	r.add_child(sacco(Vector3(0.56, 0.08, 0.17), 1.0))
	r.add_child(cesta(Vector3(0.82, 0, 0.32), "olive"))
	r.add_child(cesta(Vector3(0.7, 0, 0.32), "formaggio"))
	_catasta_pietre(r, Vector3(0.62, 0, 0.6), 1.0, 34)
	catasta_tronchi(r, Vector3(0.36, 0, 0.62), 3, 0.32)
	# asino con le ceste
	r.add_child(asino(Vector3(0.06, 0, 0.6), 70))
	r.add_child(cesta(Vector3(0.04, 0.11, 0.54), "olive", 0.7))
	r.add_child(cesta(Vector3(0.08, 0.11, 0.66), "olive", 0.7))
	_insegna_sicana(r, Vector3(0.9, 0, 0.7), 0.8)
	return r


## Boscaiolo dei Sicani: casa di pietra col tetto d'erba, tettoia di lastre sopra la legna spaccata, catasta di
## tronchi, ceppo con l'ascia dalla lama di pietra nera, fascine e una catasta di pietre.
static func boscaiolo_sicani() -> Node3D:
	var r := Node3D.new()
	_casa_sicana(r, Vector3(-0.15, 0, -0.2), 0.66, 0.48, 0.3, 41, 0.0, true, -0.08, true)
	_tettoia_sicana(r, Vector3(0.43, 0, -0.18), 0.32, 0.5, 0.36, 0.28, 42)
	legnaia(r, Vector3(0.43, 0, -0.32), 0.28, 5)
	legnaia(r, Vector3(0.43, 0, -0.1), 0.28, 4)
	catasta_tronchi(r, Vector3(0.55, 0, 0.55), 4, 0.5)
	r.add_child(cilindro(0.07, 0.075, 0.09, Vector3(-0.2, 0.045, 0.5), "corteccia", Vector3.ZERO, 12))
	r.add_child(cilindro(0.066, 0.066, 0.006, Vector3(-0.2, 0.092, 0.5), "legno_chiaro", Vector3.ZERO, 12))
	r.add_child(cilindro(0.008, 0.008, 0.22, Vector3(-0.2, 0.18, 0.5), "legno", Vector3(0, 0, 22), 6))
	r.add_child(scatola(Vector3(0.06, 0.04, 0.016), Vector3(-0.245, 0.27, 0.5), "ossidiana", Vector3(0, 0, 22)))
	r.add_child(scatola(Vector3(0.012, 0.035, 0.018), Vector3(-0.27, 0.262, 0.5), "riflesso_oss", Vector3(0, 0, 22)))
	for i in 6:
		r.add_child(cilindro(0.02, 0.02, 0.06, Vector3(-0.38 + i * 0.06, 0.02, 0.62 + (i % 2) * 0.05), "legno_chiaro", Vector3(0, i * 37, 90), 6))
	_fascina(r, Vector3(-0.62, 0, 0.35), 20.0)
	_fascina(r, Vector3(-0.55, 0, 0.45), 35.0)
	_catasta_pietre(r, Vector3(0.12, 0, 0.3), 0.8, 43)
	for pos: Vector3 in [Vector3(-0.72, 0, 0.0), Vector3(-0.6, 0, 0.75)]:
		r.add_child(cilindro(0.06, 0.07, 0.05, pos + Vector3(0, 0.025, 0), "corteccia", Vector3.ZERO, 10))
		r.add_child(cilindro(0.056, 0.056, 0.005, pos + Vector3(0, 0.052, 0), "legno_chiaro", Vector3.ZERO, 10))
	return r


## Segheria dei Sicani: casa di pietra col tetto d'erba, tettoia di lastre sopra il tronco sui cavalletti con la sega a
## telaio, pile di assi, cunei e mazzuolo, catasta di tronchi, catasta di pietre.
static func segheria_sicani() -> Node3D:
	var r := Node3D.new()
	_casa_sicana(r, Vector3(-0.2, 0, -0.3), 0.7, 0.5, 0.32, 51, 0.0, true, -0.1)
	var t := Vector3(0.05, 0, 0.5)
	_tettoia_sicana(r, t, 0.9, 0.44, 0.44, 0.35, 52)
	for px: float in [-0.25, 0.0, 0.25]:
		r.add_child(scatola(Vector3(0.03, 0.12, 0.12), t + Vector3(px, 0.06, 0.0), "legno"))
	r.add_child(cilindro(0.055, 0.055, 0.8, t + Vector3(0, 0.17, 0.0), "corteccia", Vector3(0, 0, 90), 9))
	r.add_child(cilindro(0.047, 0.047, 0.805, t + Vector3(0, 0.17, 0.0), "legno_chiaro", Vector3(0, 0, 90), 9))
	for z: float in [-0.08, 0.08]:
		r.add_child(scatola(Vector3(0.014, 0.3, 0.014), t + Vector3(0.1, 0.24, z), "legno"))
	r.add_child(scatola(Vector3(0.014, 0.014, 0.18), t + Vector3(0.1, 0.38, 0.0), "legno"))
	r.add_child(scatola(Vector3(0.006, 0.006, 0.17), t + Vector3(0.1, 0.2, 0.0), "bronzo"))
	r.add_child(cilindro(0.2, 0.2, 0.004, t + Vector3(0.1, 0.002, 0.0), "legno_chiaro", Vector3.ZERO, 16))
	for k in 3:
		r.add_child(scatola(Vector3(0.03, 0.02, 0.05), t + Vector3(-0.35 + k * 0.05, 0.01, 0.17), "legno_scuro", Vector3(0, k * 30, 0)))
	r.add_child(cilindro(0.025, 0.025, 0.07, t + Vector3(-0.2, 0.025, 0.18), "legno", Vector3(0, 30, 90), 8))
	pila_assi(r, Vector3(0.62, 0, -0.25), 8, 90)
	pila_assi(r, Vector3(0.62, 0, 0.12), 5, 90)
	catasta_tronchi(r, Vector3(-0.65, 0, 0.55), 3, 0.42)
	_catasta_pietre(r, Vector3(0.45, 0, 0.86), 0.8, 53)
	_fascina(r, Vector3(0.2, 0, 0.86), 70.0)
	return r


## Cava dei Sicani: piccola casa di pietra, fronte di roccia grigia tagliata a gradoni con le tacche dei cunei, blocchi
## squadrati pronti, leva di legno, ceste di pietrame, slitta di tronchi con un blocco e una catasta di pietre.
static func cava_sicani() -> Node3D:
	var r := Node3D.new()
	_casa_sicana(r, Vector3(-0.4, 0, -0.34), 0.48, 0.42, 0.28, 61, 0.0, true)
	var rng := _rng(61)
	# fronte di cava a tre gradoni di roccia viva
	var c := Vector3(0.32, 0, -0.38)
	for k in 3:
		var dz := 0.42 - k * 0.12
		var yk := 0.13 + k * 0.11
		r.add_child(scatola(Vector3(0.58 - k * 0.06, yk, dz), c + Vector3(-k * 0.02, yk * 0.5, -0.21 + dz * 0.5), "sasso_sic" if k % 2 == 0 else "pietra_n_chiara"))
		for j in 5:
			r.add_child(scatola(Vector3(0.012, 0.03, 0.012), c + Vector3(-0.22 + j * 0.1 - k * 0.02, yk - 0.02, -0.21 + dz + 0.002), "buio"))
		for j in 3:
			r.add_child(_masso(c + Vector3(-0.25 + j * 0.22 + rng.randf_range(-0.04, 0.04), yk, -0.21 + dz * rng.randf_range(0.2, 0.6)), rng.randf_range(0.05, 0.08), Vector3(1.3, 0.8, 1.0), "pietra_n_chiara" if j % 2 == 0 else "sasso_sic", rng.randf() * 90.0))
	for k in 6:
		r.add_child(_masso(c + Vector3(rng.randf_range(-0.3, 0.3), 0.0, -0.25 + rng.randf_range(-0.04, 0.02)), rng.randf_range(0.08, 0.13), Vector3(1.2, rng.randf_range(1.5, 2.8), 1.0), "sasso_sic" if k % 2 == 0 else "pietra_n_scura", rng.randf() * 90.0))
	# blocchi squadrati pronti
	for i in 4:
		for j in 2 - (i / 3):
			r.add_child(scatola(Vector3(0.13, 0.09, 0.09), Vector3(-0.1 + i * 0.15, 0.045 + j * 0.09, 0.45), "sasso_sic" if (i + j) % 2 == 0 else "pietra_n_chiara", Vector3(0, i * 5 - 6, 0)))
	# leva di legno sotto un blocco, ceste di pietrame
	r.add_child(scatola(Vector3(0.14, 0.1, 0.1), Vector3(0.55, 0.05, 0.12), "sasso_sic", Vector3(0, 20, 6)))
	ramo(r, Vector3(0.5, 0.02, 0.2), Vector3(0.78, 0.2, 0.34), 0.01, "legno")
	r.add_child(sfera(0.025, Vector3(0.52, 0.02, 0.24), "roccia_massi", Vector3(1.2, 0.8, 1)))
	for k in 2:
		var cp := Vector3(-0.55 + k * 0.13, 0, 0.3 + k * 0.08)
		r.add_child(cilindro(0.065, 0.055, 0.06, cp + Vector3(0, 0.03, 0), "paglia_scura", Vector3.ZERO, 12))
		r.add_child(mucchio(cp + Vector3(0, 0.03, 0), "sasso_sic", 5, 7 + k, 0.025))
	# slitta di tronchi con un blocco
	for lato: int in [-1, 1]:
		r.add_child(cilindro(0.018, 0.018, 0.34, Vector3(-0.42, 0.018, 0.62 + lato * 0.06), "corteccia", Vector3(0, 0, 90), 6))
	r.add_child(scatola(Vector3(0.26, 0.02, 0.16), Vector3(-0.42, 0.045, 0.62), "legno_vecchio"))
	r.add_child(scatola(Vector3(0.12, 0.08, 0.09), Vector3(-0.42, 0.095, 0.62), "sasso_sic"))
	ramo(r, Vector3(-0.27, 0.02, 0.62), Vector3(-0.1, 0.06, 0.66), 0.004, "corda")
	_catasta_pietre(r, Vector3(-0.08, 0, 0.12), 0.8, 62)
	return r


## Guardaboschi dei Sicani: casa di pietra col tetto d'erba, vivaio di querce e olivastri giovani su tre gradoni, orcio
## d'acqua, zappa, sacchi di ghiande e una quercia.
static func guardaboschi_sicani() -> Node3D:
	var r := Node3D.new()
	_casa_sicana(r, Vector3(-0.32, 0, -0.34), 0.54, 0.44, 0.28, 71, 0.0, true)
	var g := Vector3(0.16, 0, 0.45)
	_gradoni(r, g, 0.66, 0.54, 3, 0.05, "terra", 72)
	for k in 3:
		_coltura_sic(r, g + Vector3(0, (k + 1) * 0.05 + 0.01, 0.27 - (k + 0.5) * 0.18 - 0.012), 0.6, 0.1, "vivaio", 70 + k)
	r.add_child(anfora(Vector3(0.3, 0, -0.18), 1.3))
	r.add_child(anfora(Vector3(0.4, 0, -0.1), 1.0))
	r.add_child(cilindro(0.007, 0.007, 0.22, Vector3(0.2, 0.11, -0.3), "legno", Vector3(12, 0, -15), 5))
	r.add_child(scatola(Vector3(0.05, 0.012, 0.04), Vector3(0.23, 0.01, -0.28), "bronzo", Vector3(0, 0, -15)))
	r.add_child(sacco(Vector3(-0.58, 0, 0.3), 0.4))
	r.add_child(sacco(Vector3(-0.62, 0, 0.42), -0.2))
	_catasta_pietre(r, Vector3(-0.4, 0, 0.2), 0.7, 73)
	var q := quercia(43)
	q.position = Vector3(0.55, 0, -0.55)
	q.scale = Vector3.ONE * 0.6
	r.add_child(q)
	return r


## Pozzo dei Sicani: vera quadrata di pietra a secco con le lastre di copertina, trilite di due pietre ritte e un
## architrave che regge il rullo di legno con la manovella, secchio di cuoio appeso, abbeveratoio di pietra e orci.
static func pozzo_sicani() -> Node3D:
	var r := Node3D.new()
	var lv := 0.36
	var sp := 0.08
	for f in 4:
		var a := f * 90.0
		var p := Vector3(0, 0.08, lv * 0.5 - sp * 0.5).rotated(Vector3.UP, deg_to_rad(a))
		r.add_child(scatola(Vector3(lv, 0.16, sp), p, "pietra_sicana", Vector3(0, a, 0)))
		for k in 4:
			var q := Vector3(-lv * 0.5 + (k + 0.5) * lv / 4.0, 0.168, lv * 0.5 - sp * 0.5).rotated(Vector3.UP, deg_to_rad(a))
			r.add_child(scatola(Vector3(lv / 4.0 + 0.012, 0.018, sp + 0.03), q, "lastra_sic" if (k + f) % 3 != 0 else "sasso_sic", Vector3(0, a + (k - 1.5) * 4.0, 0)))
		for k in 3:
			var q := Vector3(-0.1 + k * 0.1, 0.05 + (k % 2) * 0.05, lv * 0.5 + 0.004).rotated(Vector3.UP, deg_to_rad(a))
			r.add_child(_sasso_sic(q, Vector3(0.06, 0.035, 0.018), a, k + f))
	r.add_child(scatola(Vector3(lv - 2 * sp, 0.1, lv - 2 * sp), Vector3(0, 0.09, 0), "buio"))
	r.add_child(scatola(Vector3(lv - 2 * sp, 0.004, lv - 2 * sp), Vector3(0, 0.142, 0), "acqua_pozzo"))
	# trilite con il rullo
	for lato: int in [-1, 1]:
		r.add_child(scatola(Vector3(0.07, 0.48, 0.08), Vector3(lato * 0.24, 0.24, 0), "sasso_sic", Vector3(0, 0, lato * 1.5)))
	r.add_child(scatola(Vector3(0.62, 0.07, 0.11), Vector3(0, 0.515, 0), "pietra_n_chiara", Vector3(0, 0, 2)))
	for k in 3:
		r.add_child(sfera(0.02, Vector3(-0.16 + k * 0.13, 0.56, 0.01 - k * 0.01), "prato" if k % 2 == 0 else "foglie_chiare", Vector3(1.3, 0.6, 1.1)))
	r.add_child(cilindro(0.028, 0.028, 0.42, Vector3(0, 0.4, 0), "legno", Vector3(0, 0, 90), 10))
	r.add_child(cilindro(0.031, 0.031, 0.06, Vector3(-0.03, 0.4, 0), "corda", Vector3(0, 0, 90), 10))
	r.add_child(scatola(Vector3(0.015, 0.1, 0.015), Vector3(0.29, 0.37, 0.0), "legno_scuro"))
	r.add_child(cilindro(0.008, 0.008, 0.06, Vector3(0.29, 0.32, 0.03), "legno_scuro", Vector3(90, 0, 0), 5))
	r.add_child(cilindro(0.003, 0.003, 0.15, Vector3(-0.03, 0.31, 0.0), "corda", Vector3.ZERO, 4))
	r.add_child(cilindro(0.036, 0.03, 0.06, Vector3(-0.03, 0.21, 0.0), "cuoio", Vector3.ZERO, 10))
	r.add_child(_toro(0.03, 0.036, Vector3(-0.03, 0.24, 0.0), "legno_scuro"))
	# abbeveratoio di pietra, orci, catasta di pietre
	r.add_child(scatola(Vector3(0.26, 0.06, 0.1), Vector3(0.3, 0.03, 0.26), "sasso_sic", Vector3(0, -40, 0)))
	r.add_child(scatola(Vector3(0.21, 0.005, 0.065), Vector3(0.3, 0.061, 0.26), "acqua_pozzo", Vector3(0, -40, 0)))
	r.add_child(anfora(Vector3(0.3, 0, -0.2), 1.3))
	r.add_child(anfora(Vector3(0.05, 0, 0.32), 1.1))
	r.add_child(anfora(Vector3(-0.06, 0, 0.36), 0.9))
	_catasta_pietre(r, Vector3(-0.3, 0, 0.26), 0.7, 81)
	r.scale = Vector3.ONE * 1.15
	return r


## Fattoria dei Sicani: casa di pietra col tetto d'erba, granaio quadrato di pietra, campi di grano a terrazze che salgono
## sostenuti dai muri a secco, aia tonda lastricata con i covoni, asino, galline e sacchi.
static func fattoria_sicani() -> Node3D:
	var r := Node3D.new()
	_casa_sicana(r, Vector3(-0.26, 0, -0.32), 0.62, 0.46, 0.3, 81, 0.0, true, -0.1, true)
	_casa_sicana(r, Vector3(0.72, 0, -0.3), 0.32, 0.3, 0.3, 82, 0.0, false)
	r.add_child(scatola(Vector3(0.07, 0.09, 0.02), Vector3(0.72, 0.16, -0.14), "legno_scuro"))
	r.add_child(scatola(Vector3(0.12, 0.025, 0.04), Vector3(0.72, 0.22, -0.13), "lastra_sic"))
	# campi a terrazze
	var g := Vector3(0.36, 0, 0.34)
	_gradoni(r, g, 0.74, 0.66, 3, 0.055, "terra", 83)
	for k in 3:
		_coltura_sic(r, g + Vector3(0, (k + 1) * 0.055 + 0.01, 0.33 - (k + 0.5) * 0.22 - 0.012), 0.68, 0.15, "grano", 83 + k)
	# aia tonda lastricata con i covoni
	var a := Vector3(-0.42, 0, 0.46)
	r.add_child(cilindro(0.26, 0.27, 0.02, a + Vector3(0, 0.01, 0), "lastra_sic", Vector3.ZERO, 20))
	for k in 16:
		var ak := k * TAU / 16
		r.add_child(_sasso_sic(a + Vector3(cos(ak), 0, sin(ak)) * 0.27 + Vector3(0, 0.02, 0), Vector3(0.05, 0.03, 0.04), -rad_to_deg(ak) + 90.0, k))
	r.add_child(cilindro(0.22, 0.22, 0.005, a + Vector3(0, 0.022, 0), "paglia", Vector3.ZERO, 20))
	for i in 4:
		var cv := covone(1.15)
		cv.position = a + Vector3(-0.15 + i * 0.1, 0.02, -0.05 + (i % 2) * 0.1)
		cv.rotation_degrees.z = 8 * (i % 2 * 2 - 1)
		r.add_child(cv)
	r.add_child(asino(Vector3(-0.1, 0, 0.1), 160))
	for i in 3:
		r.add_child(sfera(0.025, Vector3(0.1 + i * 0.07, 0.03, 0.76 - i * 0.03), "intonaco", Vector3(1.3, 1, 1)))
		r.add_child(sfera(0.008, Vector3(0.13 + i * 0.07, 0.05, 0.76 - i * 0.03), "geranio"))
	r.add_child(sacco(Vector3(0.5, 0, -0.06), 0.3))
	r.add_child(sacco(Vector3(0.58, 0, 0.0), -0.4))
	r.add_child(anfora(Vector3(-0.72, 0, 0.12), 1.2))
	return r


## Mulino dei Sicani: casa di pietra col tetto d'erba; sotto la tettoia di lastre la macina tonda di pietra grigia girata
## dall'asino, macine a sella, sacchi di farina, un covone e gli orci.
static func mulino_sicani() -> Node3D:
	var r := Node3D.new()
	_casa_sicana(r, Vector3(-0.22, 0, -0.3), 0.62, 0.46, 0.32, 91, 0.0, true, -0.1)
	var m := Vector3(-0.3, 0, 0.5)
	r.add_child(cilindro(0.2, 0.22, 0.06, m + Vector3(0, 0.03, 0), "pietra_sicana", Vector3.ZERO, 20))
	r.add_child(cilindro(0.17, 0.17, 0.005, m + Vector3(0, 0.061, 0), "lino", Vector3.ZERO, 20))
	r.add_child(cilindro(0.025, 0.025, 0.24, m + Vector3(0, 0.15, 0), "legno", Vector3.ZERO, 8))
	r.add_child(cilindro(0.11, 0.11, 0.07, m + Vector3(0.07, 0.16, 0), "sasso_sic", Vector3(0, 0, 90), 18))
	r.add_child(scatola(Vector3(0.5, 0.025, 0.025), m + Vector3(0.16, 0.25, 0), "legno_vecchio"))
	r.add_child(asino(m + Vector3(0.38, 0, 0.0), 90))
	_tettoia_sicana(r, m + Vector3(0, 0, -0.2), 0.56, 0.3, 0.46, 0.4, 92)
	_macina_sella(r, Vector3(0.12, 0, 0.66), 30.0)
	_macina_sella(r, Vector3(0.3, 0, 0.58), 10.0)
	for i in 5:
		r.add_child(sacco(Vector3(0.45 + (i % 3) * 0.12, 0.0, -0.1 + (i / 3) * 0.13), i * 0.7))
	var cv := covone(1.1)
	cv.position = Vector3(0.6, 0, 0.42)
	r.add_child(cv)
	r.add_child(anfora(Vector3(0.36, 0, 0.3), 1.3))
	return r


## Forno dei Sicani: casa di pietra col tetto d'erba, grande forno a falsa cupola di pietra coperto d'erba con la bocca
## accesa e il fumo, lastra con le focacce, fascine, ceste di pane, sacchi e orci.
static func forno_sicani() -> Node3D:
	var r := Node3D.new()
	_casa_sicana(r, Vector3(-0.22, 0, -0.3), 0.62, 0.46, 0.3, 101, 0.0, true, -0.1)
	_forno_sicano(r, Vector3(0.45, 0, 0.36), 1.2)
	_fascina(r, Vector3(0.75, 0, 0.1), 10.0)
	_fascina(r, Vector3(0.68, 0, 0.0), 25.0)
	r.add_child(scatola(Vector3(0.32, 0.03, 0.15), Vector3(-0.3, 0.1, 0.55), "lastra_sic"))
	for lato: int in [-1, 1]:
		r.add_child(_sasso_sic(Vector3(-0.3 + lato * 0.11, 0.043, 0.55), Vector3(0.06, 0.085, 0.1), 0.0, lato + 3))
	for i in 5:
		r.add_child(sfera(0.03, Vector3(-0.42 + i * 0.06, 0.125, 0.55 + (i % 2) * 0.03), "pane", Vector3(1, 0.45, 1)))
	r.add_child(cesta(Vector3(-0.62, 0, 0.42), "pane"))
	r.add_child(cesta(Vector3(0.05, 0, 0.66), "pane"))
	r.add_child(sacco(Vector3(-0.68, 0, 0.15), 0.4))
	r.add_child(anfora(Vector3(0.12, 0, 0.34), 1.2))
	return r


## Ovile dei Sicani: casa di pietra bassa, stazzo tondo di muro a secco grigio con le pecore, abbeveratoio di pietra,
## bastone del pastore, lana tosata e orcio del latte.
static func ovile_sicani() -> Node3D:
	var r := Node3D.new()
	_casa_sicana(r, Vector3(-0.36, 0, -0.4), 0.52, 0.42, 0.28, 111, 0.0, true)
	var a := Vector3(0.18, 0, 0.18)
	for k in 10:
		var a0 := deg_to_rad(-150.0 + k * 30.0)
		var a1 := deg_to_rad(-150.0 + (k + 1) * 30.0)
		if k == 6:
			continue
		_muro_sic(r, a + Vector3(cos(a0), 0, sin(a0)) * 0.42, a + Vector3(cos(a1), 0, sin(a1)) * 0.42, 0.1, 0.075)
	for p: Array in [[Vector3(0.0, 0, 0.1), 30], [Vector3(0.15, 0, -0.1), 160], [Vector3(0.2, 0, 0.18), -40],
			[Vector3(-0.15, 0, 0.18), 90], [Vector3(0.05, 0, -0.22), 210]]:
		r.add_child(pecora(a + p[0], p[1]))
	r.add_child(scatola(Vector3(0.22, 0.05, 0.07), a + Vector3(-0.15, 0.025, -0.1), "sasso_sic", Vector3(0, 30, 0)))
	r.add_child(scatola(Vector3(0.18, 0.005, 0.04), a + Vector3(-0.15, 0.051, -0.1), "acqua_pozzo", Vector3(0, 30, 0)))
	r.add_child(cilindro(0.007, 0.006, 0.36, Vector3(-0.05, 0.17, -0.02), "legno", Vector3(0, 0, -10), 5))
	r.add_child(_toro(0.012, 0.02, Vector3(-0.08, 0.35, -0.02), "legno", Vector3(90, 0, 0)))
	r.add_child(sfera(0.06, Vector3(-0.6, 0.04, 0.3), "lana", Vector3(1.2, 0.6, 1.0)))
	r.add_child(sfera(0.05, Vector3(-0.52, 0.035, 0.4), "lana", Vector3(1.2, 0.6, 1.0)))
	r.add_child(anfora(Vector3(-0.7, 0, 0.1), 1.1))
	return r


## Capraio dei Sicani: casa di pietra bassa, spuntoni di roccia grigia con le capre, muro a secco, rastrelliera di
## formaggi con il ripiano di lastre e l'orcio del latte.
static func capraio_sicani() -> Node3D:
	var r := Node3D.new()
	_casa_sicana(r, Vector3(-0.32, 0, -0.34), 0.46, 0.38, 0.26, 121, 0.0, true)
	var a := Vector3(0.15, 0, 0.15)
	r.add_child(_masso(a + Vector3(0.2, 0.0, -0.1), 0.17, Vector3(1.2, 1.6, 1.0), "pietra_n_chiara", 20.0))
	r.add_child(_masso(a + Vector3(-0.05, 0.0, 0.3), 0.11, Vector3(1.3, 1.4, 1.0), "sasso_sic", 50.0))
	r.add_child(_masso(a + Vector3(0.38, 0.0, 0.1), 0.08, Vector3(1.3, 1.6, 1.0), "pietra_n_scura", 10.0))
	r.add_child(sfera(0.03, a + Vector3(0.12, 0.05, 0.0), "prato", Vector3(1.3, 0.6, 1.2)))
	r.add_child(capra(a + Vector3(0.2, 0.12, -0.1), 40))
	r.add_child(capra(a + Vector3(0.0, 0, 0.1), 200))
	r.add_child(capra(a + Vector3(0.35, 0, 0.3), -30))
	r.add_child(capra(a + Vector3(-0.1, 0.07, 0.3), 110))
	_muro_sic(r, a + Vector3(-0.4, 0, 0.52), a + Vector3(0.5, 0, 0.52), 0.09, 0.07)
	var f := Vector3(-0.62, 0, 0.3)
	for x: float in [-0.08, 0.08]:
		for z: float in [-0.06, 0.06]:
			r.add_child(cilindro(0.008, 0.008, 0.16, f + Vector3(x, 0.08, z), "corteccia", Vector3.ZERO, 5))
	r.add_child(scatola(Vector3(0.21, 0.014, 0.17), f + Vector3(0, 0.16, 0), "lastra_sic"))
	for k in 4:
		r.add_child(cilindro(0.025, 0.025, 0.024, f + Vector3(-0.055 + (k % 2) * 0.1, 0.179, -0.035 + (k / 2) * 0.07), "formaggio", Vector3.ZERO, 10))
	r.add_child(anfora(Vector3(-0.42, 0, 0.5), 1.1))
	return r


## Caserma dei Sicani: casa di pietra col tetto d'erba e l'insegna blu, campo di tiro con il bersaglio di paglia a cerchi
## blu e bianchi, rastrelliera di archi e faretre, due arcieri che si esercitano e una catasta di pietre.
static func caserma_sicani() -> Node3D:
	var r := Node3D.new()
	_casa_sicana(r, Vector3(-0.3, 0, -0.32), 0.58, 0.48, 0.34, 131, 0.0, true, -0.08, true)
	_insegna_sicana(r, Vector3(0.1, 0, -0.1), 0.72)
	r.add_child(scatola(Vector3(0.75, 0.01, 0.55), Vector3(0.25, 0.005, 0.4), "terra"))
	# bersaglio di paglia su un cavalletto
	var b := Vector3(0.52, 0, 0.26)
	for lato: int in [-1, 1]:
		ramo(r, b + Vector3(lato * 0.08, 0, -0.03), b + Vector3(0, 0.3, 0.0), 0.009, "corteccia")
	ramo(r, b + Vector3(0, 0, -0.12), b + Vector3(0, 0.3, 0.0), 0.009, "corteccia")
	var bn := Node3D.new()
	bn.position = b + Vector3(0, 0.22, 0.03)
	bn.rotation_degrees = Vector3(-8, 40, 0)
	r.add_child(bn)
	bn.add_child(cilindro(0.1, 0.1, 0.04, Vector3.ZERO, "paglia", Vector3(90, 0, 0), 18))
	bn.add_child(cilindro(0.08, 0.08, 0.042, Vector3.ZERO, "lapislazzuli", Vector3(90, 0, 0), 18))
	bn.add_child(cilindro(0.055, 0.055, 0.044, Vector3.ZERO, "lino_bianco", Vector3(90, 0, 0), 16))
	bn.add_child(cilindro(0.03, 0.03, 0.046, Vector3.ZERO, "lapislazzuli", Vector3(90, 0, 0), 14))
	for k in 3:
		var fp := Vector3(-0.03 + k * 0.03, 0.02 - k * 0.02, 0.03)
		bn.add_child(cilindro(0.003, 0.003, 0.09, fp + Vector3(0, 0, 0.045), "legno", Vector3(90, 0, 0), 4))
		bn.add_child(scatola(Vector3(0.004, 0.016, 0.03), fp + Vector3(0, 0, 0.085), "lino_bianco"))
	for k in 2:
		var o := arciere_sicano()
		o.position = Vector3(0.0 + k * 0.24, 0, 0.6 - k * 0.12)
		o.rotation_degrees.y = 120 - k * 30
		o.scale = Vector3.ONE * 0.95
		r.add_child(o)
	_rastrelliera_archi(r, Vector3(-0.6, 0, 0.4), 30.0)
	_catasta_pietre(r, Vector3(-0.66, 0, 0.1), 0.7, 132)
	return r


## Torre di guardia dei Sicani: torre quadrata di pietra a secco che si restringe, su un basamento di sassi, grossi blocchi
## agli angoli, cornice di lastre, feritoie, porta alta con la scala a pioli, terrazza piatta d'erba col parapetto di
## lastre ritte, braciere e insegna blu; alla base scudi, archi e una catasta di pietre.
static func torre_sicani() -> Node3D:
	var r := Node3D.new()
	var h := 0.96
	var b0 := 0.08
	var rng := _rng(141)
	r.add_child(scatola(Vector3(0.82, b0, 0.82), Vector3(0, b0 * 0.5, 0), "sasso_sic"))
	for k in 10:
		var a := deg_to_rad(rng.randf_range(-70.0, 160.0))
		r.add_child(_masso(Vector3(sin(a), 0, cos(a)) * 0.46, rng.randf_range(0.05, 0.08), Vector3(1.3, 1.2, 1.0), "roccia_massi" if k % 2 == 0 else "sasso_sic", rng.randf() * 90.0))
	var s0 := 0.35
	var s1 := 0.29
	r.add_child(cilindro(s0 / cos(PI / 4), s1 / cos(PI / 4), h, Vector3(0, b0 + h * 0.5, 0), "pietra_sicana", Vector3(0, 45, 0), 4))
	# sassi sporgenti sulle due facce in vista
	for f in 2:
		var a := f * 90.0
		for k in 70:
			var y := rng.randf_range(0.03, h - 0.03)
			var sh := lerpf(s0, s1, y / h)
			var p := Vector3(rng.randf_range(-sh + 0.04, sh - 0.04), b0 + y, sh + 0.004).rotated(Vector3.UP, deg_to_rad(a))
			r.add_child(_sasso_sic(p, Vector3(rng.randf_range(0.05, 0.09), rng.randf_range(0.028, 0.048), 0.02), a, k + f))
	# blocchi d'angolo
	for cx: int in [-1, 1]:
		for cz: int in [-1, 1]:
			var y := 0.0
			var j := 0
			while y < h - 0.04:
				var bh := minf(rng.randf_range(0.08, 0.11), h - y)
				var sh := lerpf(s0, s1, (y + bh * 0.5) / h)
				var lungo := (j + cx + cz) % 2 == 0
				var d := Vector3(0.16 if lungo else 0.09, bh - 0.008, 0.09 if lungo else 0.16)
				r.add_child(scatola(d, Vector3(cx * (sh - d.x * 0.5 + 0.012), b0 + y + bh * 0.5, cz * (sh - d.z * 0.5 + 0.012)), "sasso_sic" if j % 2 == 0 else "pietra_n_chiara", Vector3(0, rng.randf_range(-3.0, 3.0), 0)))
				y += bh
				j += 1
	# cornice di lastre a metà
	var ym := b0 + h * 0.55
	var sm := lerpf(s0, s1, 0.55) + 0.03
	for f in 4:
		r.add_child(scatola(Vector3(sm * 2 + 0.04, 0.025, 0.07), Vector3(0, ym, sm - 0.02).rotated(Vector3.UP, deg_to_rad(f * 90.0)), "lastra_sic", Vector3(0, f * 90.0, 0)))
	# feritoie
	for y: float in [0.62, 0.86]:
		var sh := lerpf(s0, s1, y / h) + 0.005
		r.add_child(scatola(Vector3(0.03, 0.08, 0.02), Vector3(0.08, b0 + y, sh), "buio"))
		r.add_child(scatola(Vector3(0.02, 0.08, 0.03), Vector3(sh, b0 + y, -0.06), "buio"))
	# porta alta e scala a pioli
	var yp := b0 + 0.28
	_porta_sicana(r, Vector3(-0.12, yp, lerpf(s0, s1, 0.3) + 0.03), 0.0, 0.11, 0.18, false)
	for lato: int in [-1, 1]:
		ramo(r, Vector3(-0.12 + lato * 0.045, 0, 0.66), Vector3(-0.12 + lato * 0.045, yp + 0.02, 0.37), 0.009, "legno_vecchio")
	for k in 5:
		var t := (k + 1) / 6.0
		r.add_child(scatola(Vector3(0.1, 0.008, 0.008), Vector3(-0.12, (yp + 0.02) * t, 0.66 - 0.29 * t), "legno"))
	# terrazza: travi, lastre sporgenti, erba e parapetto di lastre ritte
	var top := b0 + h
	for k in 5:
		r.add_child(cilindro(0.016, 0.018, s1 * 2 + 0.1, Vector3(-s1 + 0.06 + k * (s1 * 2 - 0.12) / 4.0, top - 0.025, 0), "legno_vecchio", Vector3(90, 0, 0), 6))
	r.add_child(scatola(Vector3(s1 * 2 + 0.12, 0.035, s1 * 2 + 0.12), Vector3(0, top + 0.017, 0), "lastra_sic"))
	r.add_child(scatola(Vector3(s1 * 2 - 0.02, 0.02, s1 * 2 - 0.02), Vector3(0, top + 0.044, 0), "erba_tetto"))
	for f in 4:
		var a := f * 90.0
		var np := 6
		for k in np:
			var u := -s1 + 0.03 + (k + 0.5) * (s1 * 2 - 0.06) / np
			var hp := rng.randf_range(0.09, 0.15)
			r.add_child(scatola(Vector3((s1 * 2 - 0.06) / np - 0.012, hp, 0.04), Vector3(u, top + 0.035 + hp * 0.5, s1 + 0.02).rotated(Vector3.UP, deg_to_rad(a)), "sasso_sic" if (k + f) % 3 != 0 else "pietra_n_chiara", Vector3(rng.randf_range(-4.0, 4.0), a + rng.randf_range(-5.0, 5.0), rng.randf_range(-4.0, 4.0))))
	# braciere e piccolo riparo di lastre sul retro
	var br := Vector3(0.06, top + 0.05, 0.08)
	r.add_child(cilindro(0.05, 0.035, 0.05, br + Vector3(0, 0.025, 0), "sasso_sic", Vector3.ZERO, 8))
	_fuoco(r, br + Vector3(0, 0.05, 0), 0.6)
	for x: float in [-0.22, 0.0]:
		r.add_child(cilindro(0.01, 0.01, 0.2, Vector3(x, top + 0.14, -0.08), "corteccia", Vector3.ZERO, 5))
	r.add_child(scatola(Vector3(0.3, 0.025, 0.24), Vector3(-0.11, top + 0.25, -0.16), "lastra_sic", Vector3(10, 0, 0)))
	r.add_child(sfera(0.06, Vector3(-0.11, top + 0.27, -0.16), "erba_tetto", Vector3(2.2, 0.4, 1.6)))
	_insegna_sicana(r, Vector3(0.2, top + 0.04, 0.2), 0.62)
	# alla base: scudo, archi, catasta di pietre, orcio
	var sc := _scudo_sicano(Vector3(0.22, 0.1, 0.46), 20.0, 1.0)
	sc.rotation_degrees.x = -14
	r.add_child(sc)
	_arco_sic(r, Vector3(0.42, 0.13, 0.3), 0.22, 0.045, Vector3(0, 0, 18))
	_catasta_pietre(r, Vector3(0.5, 0, -0.05), 0.8, 142)
	r.add_child(anfora(Vector3(0.46, 0, 0.16), 1.1))
	return r


## Rocca dei Sicani (castello 3x3): sperone di roccia grigia a tre ripiani, con i terrazzamenti e i muri a secco; in
## basso la cinta con la porta a trilite fra due torri quadrate e la rampa, case col tetto d'erba sui ripiani, campi a
## gradoni, recinto delle capre; in cima la casa del capo e la torre con le insegne blu.
static func castello_sicani() -> Node3D:
	var r := Node3D.new()
	var rng := _rng(151)
	var h1 := 0.26
	var h2 := 0.5
	var h3 := 0.7
	# sperone di roccia a tre ripiani, ognuno con il prato in cima
	r.add_child(cilindro(1.62, 1.46, h1, Vector3(0, h1 * 0.5, 0), "roccia_massi", Vector3.ZERO, 15))
	r.add_child(cilindro(1.47, 1.47, 0.012, Vector3(0, h1 + 0.004, 0), "prato", Vector3.ZERO, 15))
	var c2 := Vector3(-0.28, 0, -0.32)
	r.add_child(cilindro(1.02, 0.9, h2 - h1, c2 + Vector3(0, h1 + (h2 - h1) * 0.5, 0), "roccia_massi", Vector3(0, 20, 0), 9))
	r.add_child(cilindro(0.91, 0.91, 0.012, c2 + Vector3(0, h2 + 0.004, 0), "prato", Vector3(0, 20, 0), 9))
	var c3 := Vector3(-0.5, 0, -0.55)
	r.add_child(cilindro(0.64, 0.56, h3 - h2, c3 + Vector3(0, h2 + (h3 - h2) * 0.5, 0), "roccia_massi", Vector3(0, 10, 0), 8))
	r.add_child(cilindro(0.57, 0.57, 0.012, c3 + Vector3(0, h3 + 0.004, 0), "prato", Vector3(0, 10, 0), 8))
	# massi e spuntoni sui fianchi
	for k in 44:
		var a := deg_to_rad(rng.randf_range(-80.0, 170.0))
		var rr := rng.randf_range(1.5, 1.68)
		r.add_child(_masso(Vector3(sin(a) * rr, 0.0, cos(a) * rr), rng.randf_range(0.08, 0.15), Vector3(1.3, rng.randf_range(1.2, 2.6), 1.0), "roccia_massi" if k % 3 != 0 else "sasso_sic", rng.randf() * 90))
	for k in 22:
		var a := deg_to_rad(rng.randf_range(-60.0, 160.0))
		var rr := rng.randf_range(0.88, 1.0)
		r.add_child(_masso(c2 + Vector3(sin(a) * rr, h1, cos(a) * rr), rng.randf_range(0.06, 0.11), Vector3(1.3, rng.randf_range(1.4, 2.6), 1.0), "roccia_massi" if k % 2 != 0 else "sasso_sic", rng.randf() * 90))
	for k in 14:
		var a := deg_to_rad(rng.randf_range(-60.0, 160.0))
		var rr := rng.randf_range(0.55, 0.63)
		r.add_child(_masso(c3 + Vector3(sin(a) * rr, h2, cos(a) * rr), rng.randf_range(0.05, 0.09), Vector3(1.3, rng.randf_range(1.4, 2.4), 1.0), "roccia_massi" if k % 2 != 0 else "sasso_sic", rng.randf() * 90))
	for k in 18:
		var a := deg_to_rad(rng.randf_range(-80.0, 170.0))
		r.add_child(sfera(rng.randf_range(0.05, 0.08), Vector3(sin(a), 0, cos(a)) * 1.42 + Vector3(0, h1, 0), "macchia", Vector3(1.3, 0.6, 1.0)))
	# cinta di pietra a secco sul primo ripiano, interrotta dalla porta
	var cx := 1.3
	var nseg := 22
	var porta_k := 2
	for k in nseg:
		if k == porta_k:
			continue
		var a0 := k * TAU / nseg
		var a1 := (k + 1) * TAU / nseg
		_muro_sic(r, Vector3(sin(a0) * cx, h1, cos(a0) * cx), Vector3(sin(a1) * cx, h1, cos(a1) * cx), 0.22, 0.13)
	var porta_a := (porta_k + 0.5) * TAU / nseg
	var dir := Vector3(sin(porta_a), 0, cos(porta_a))
	var tang := Vector3(cos(porta_a), 0, -sin(porta_a))
	var pp := dir * cx + Vector3(0, h1, 0)
	var rotp := rad_to_deg(porta_a)
	# due torri quadrate con il tetto d'erba ai lati della porta
	for lato: int in [-1, 1]:
		var tp := pp + tang * lato * 0.27
		var tn := Node3D.new()
		tn.position = tp
		tn.rotation_degrees.y = rotp
		r.add_child(tn)
		_casa_sicana(tn, Vector3.ZERO, 0.24, 0.24, 0.46, 156 + lato, 0.0, false)
		tn.add_child(scatola(Vector3(0.03, 0.07, 0.02), Vector3(0, 0.3, 0.13), "buio"))
	var nb := Node3D.new()
	nb.position = pp
	nb.rotation_degrees.y = rotp
	r.add_child(nb)
	for lato: int in [-1, 1]:
		nb.add_child(scatola(Vector3(0.08, 0.34, 0.12), Vector3(lato * 0.125, 0.17, 0.0), "sasso_sic", Vector3(0, 0, lato * 1.5)))
	nb.add_child(scatola(Vector3(0.4, 0.08, 0.15), Vector3(0, 0.38, 0.0), "pietra_n_chiara", Vector3(0, 0, -1.5)))
	nb.add_child(scatola(Vector3(0.17, 0.33, 0.04), Vector3(0, 0.165, -0.05), "buio"))
	for lato: int in [-1, 1]:
		nb.add_child(scatola(Vector3(0.08, 0.3, 0.02), Vector3(lato * 0.085, 0.15, 0.06), "legno", Vector3(0, lato * 55, 0)))
	nb.add_child(sfera(0.024, Vector3(0, 0.45, 0.06), "osso", Vector3(0.85, 1.1, 0.7)))
	for lato: int in [-1, 1]:
		nb.add_child(_toro(0.009, 0.026, Vector3(lato * 0.034, 0.456, 0.06), "osso", Vector3(90, 0, 0)))
	_insegna_sicana(r, pp + tang * 0.27 + Vector3(0, 0.56, 0), 0.5)
	# rampa a gradini giù per lo sperone
	for k in 4:
		var rp := pp + dir * (0.1 + k * 0.1)
		var sg := scatola(Vector3(0.32, h1 - k * h1 / 4.0, 0.1), Vector3(rp.x, (h1 - k * h1 / 4.0) * 0.5, rp.z), "sasso_sic" if k % 2 == 0 else "pietra_n_chiara", Vector3(0, rotp, 0))
		r.add_child(sg)
		r.add_child(scatola(Vector3(0.33, 0.014, 0.11), Vector3(rp.x, h1 - k * h1 / 4.0 + 0.004, rp.z), "lastra_sic", Vector3(0, rotp + 3, 0)))
	# primo ripiano: case, campi a gradoni, recinto delle capre, catasta di pietre
	_casa_sicana(r, Vector3(0.72, h1, 0.2), 0.36, 0.3, 0.26, 152, 0.0, true, 0.0, true)
	_casa_sicana(r, Vector3(-0.92, h1, 0.5), 0.28, 0.26, 0.24, 153, 90.0, true)
	_casa_sicana(r, Vector3(0.82, h1, -0.42), 0.3, 0.28, 0.24, 154, 0.0, true)
	var g := Vector3(-0.3, h1, 0.86)
	_gradoni(r, g, 0.56, 0.3, 2, 0.04, "terra", 155)
	for k in 2:
		_coltura_sic(r, g + Vector3(0, (k + 1) * 0.04 + 0.01, 0.15 - (k + 0.5) * 0.15 - 0.012), 0.5, 0.08, "grano", 155 + k)
	var o := Vector3(0.3, h1, 0.62)
	for k in 8:
		if k == 2:
			continue
		var a0 := deg_to_rad(k * 45.0)
		var a1 := deg_to_rad((k + 1) * 45.0)
		_muro_sic(r, o + Vector3(cos(a0), 0, sin(a0)) * 0.22, o + Vector3(cos(a1), 0, sin(a1)) * 0.22, 0.08, 0.06)
	r.add_child(capra(o + Vector3(-0.05, 0, 0.0), 30))
	r.add_child(capra(o + Vector3(0.08, 0, -0.08), 200))
	_catasta_pietre(r, Vector3(0.5, h1, 0.0), 0.9, 157)
	r.add_child(anfora(Vector3(0.58, h1, 0.5), 1.3))
	# secondo ripiano: muro di sostegno davanti, case e forno
	for k in 7:
		var a0 := deg_to_rad(-40.0 + k * 22.0)
		var a1 := deg_to_rad(-40.0 + (k + 1) * 22.0)
		_muro_sic(r, c2 + Vector3(sin(a0), 0, cos(a0)) * 0.86 + Vector3(0, h2, 0), c2 + Vector3(sin(a1), 0, cos(a1)) * 0.86 + Vector3(0, h2, 0), 0.08, 0.07)
	_casa_sicana(r, c2 + Vector3(0.52, h2, 0.22), 0.36, 0.3, 0.26, 158, 0.0, true)
	_casa_sicana(r, c2 + Vector3(-0.2, h2, 0.56), 0.34, 0.26, 0.24, 159, 0.0, true, 0.0, true)
	_forno_sicano(r, c2 + Vector3(0.22, h2, 0.62), 0.6, true)
	# in cima: casa del capo e torre quadrata con le insegne
	_casa_sicana(r, c3 + Vector3(0.14, h3, 0.22), 0.48, 0.3, 0.3, 160, 0.0, true, -0.08, true)
	var tt := c3 + Vector3(-0.16, h3, -0.16)
	var ht := 0.62
	r.add_child(cilindro(0.22 / cos(PI / 4), 0.19 / cos(PI / 4), ht, tt + Vector3(0, ht * 0.5, 0), "pietra_sicana", Vector3(0, 45, 0), 4))
	for f in 2:
		var a := f * 90.0
		for k in 30:
			var y := rng.randf_range(0.03, ht - 0.03)
			var sh := lerpf(0.22, 0.19, y / ht)
			r.add_child(_sasso_sic(tt + Vector3(rng.randf_range(-sh + 0.03, sh - 0.03), y, sh + 0.004).rotated(Vector3.UP, deg_to_rad(a)), Vector3(rng.randf_range(0.045, 0.08), rng.randf_range(0.026, 0.044), 0.02), a, k + f))
	r.add_child(scatola(Vector3(0.46, 0.03, 0.46), tt + Vector3(0, ht + 0.015, 0), "lastra_sic"))
	r.add_child(scatola(Vector3(0.36, 0.02, 0.36), tt + Vector3(0, ht + 0.04, 0), "erba_tetto"))
	for f in 4:
		var a := f * 90.0
		for k in 4:
			var u := -0.16 + (k + 0.5) * 0.08
			var hp := rng.randf_range(0.07, 0.11)
			r.add_child(scatola(Vector3(0.068, hp, 0.035), tt + Vector3(u, ht + 0.03 + hp * 0.5, 0.195).rotated(Vector3.UP, deg_to_rad(a)), "sasso_sic", Vector3(0, a + rng.randf_range(-5.0, 5.0), rng.randf_range(-4.0, 4.0))))
	for y: float in [0.3, 0.48]:
		r.add_child(scatola(Vector3(0.03, 0.07, 0.02), tt + Vector3(0.0, y, lerpf(0.22, 0.19, y / ht) + 0.005), "buio"))
	_insegna_sicana(r, tt + Vector3(0.1, ht + 0.03, 0.1), 0.62)
	_insegna_sicana(r, c3 + Vector3(0.36, h3, 0.34), 0.55)
	return r


## Laboratorio dell'ossidiana (edificio unico dei Sicani): casa bassa di pietra col tetto d'erba, banco di lastra sotto la
## tettoia con i blocchi di vetro vulcanico nero, il percussore di corno e le lame appena staccate; tavola esposta col
## panno blu, lame e specchi neri lucidi, mucchi di schegge, ceste di grezzi, catasta di pietre e insegna blu.
static func ossidiana() -> Node3D:
	var r := Node3D.new()
	_casa_sicana(r, Vector3(-0.28, 0, -0.32), 0.62, 0.46, 0.28, 171, 0.0, true, -0.1, true)
	_tettoia_sicana(r, Vector3(0.42, 0, -0.36), 0.46, 0.26, 0.4, 0.34, 172)
	r.add_child(mucchio(Vector3(0.36, 0, -0.38), "ossidiana", 10, 177, 0.026))
	r.add_child(_blocco_oss(Vector3(0.52, 0, -0.36), 1.6, 5))
	# banco di lavoro all'aperto: grossa lastra su due sassi
	var b := Vector3(0.42, 0, 0.08)
	r.add_child(scatola(Vector3(0.44, 0.04, 0.18), b + Vector3(0, 0.13, 0), "lastra_sic", Vector3(0, -3, 0)))
	for lato: int in [-1, 1]:
		r.add_child(_sasso_sic(b + Vector3(lato * 0.15, 0.055, 0), Vector3(0.08, 0.11, 0.14), 0.0, lato + 2))
	r.add_child(_blocco_oss(b + Vector3(-0.12, 0.15, -0.01), 1.4, 1))
	r.add_child(_blocco_oss(b + Vector3(0.03, 0.15, -0.03), 1.0, 2))
	ramo(r, b + Vector3(0.08, 0.16, 0.04), b + Vector3(0.18, 0.17, 0.0), 0.01, "osso")
	ramo(r, b + Vector3(0.14, 0.168, 0.015), b + Vector3(0.16, 0.2, 0.03), 0.006, "osso")
	for k in 4:
		r.add_child(_lama_oss(b + Vector3(0.08 + k * 0.035, 0.155, 0.05), Vector3(0, 70 + k * 8, 0), 0.09))
	# tavola esposta inclinata col panno blu, lame in fila
	var e := Vector3(0.02, 0, 0.46)
	for x: float in [-0.22, 0.22]:
		r.add_child(cilindro(0.012, 0.014, 0.18, e + Vector3(x, 0.09, -0.05), "corteccia", Vector3.ZERO, 5))
		r.add_child(cilindro(0.012, 0.014, 0.1, e + Vector3(x, 0.05, 0.06), "corteccia", Vector3.ZERO, 5))
	var tv := Node3D.new()
	tv.position = e + Vector3(0, 0.14, 0.0)
	tv.rotation_degrees.x = 30
	r.add_child(tv)
	tv.add_child(scatola(Vector3(0.5, 0.014, 0.16), Vector3.ZERO, "legno_vecchio"))
	tv.add_child(scatola(Vector3(0.46, 0.004, 0.14), Vector3(0, 0.009, 0), "lino"))
	for z: float in [-0.064, 0.064]:
		tv.add_child(scatola(Vector3(0.46, 0.005, 0.014), Vector3(0, 0.01, z), "lapislazzuli"))
	for i in 7:
		for j in 2:
			tv.add_child(_lama_oss(Vector3(-0.19 + i * 0.063, 0.016, -0.03 + j * 0.06), Vector3(0, 90 + (i % 2) * 6 - 3, 0), 0.07 if j == 0 else 0.085, j == 1 and i % 2 == 0))
	# specchi neri
	r.add_child(_specchio_oss(Vector3(0.44, 0, 0.5), -20.0, 1.7))
	r.add_child(_specchio_oss(Vector3(0.62, 0, 0.4), -40.0, 1.4))
	# mucchi di schegge nere e cocci sparsi
	r.add_child(mucchio(Vector3(0.74, 0, 0.12), "ossidiana", 9, 173, 0.022))
	r.add_child(mucchio(Vector3(0.18, 0, 0.12), "ossidiana", 6, 174, 0.018))
	var rng := _rng(175)
	for k in 10:
		r.add_child(scatola(Vector3(0.018, 0.005, 0.012), Vector3(0.45 + rng.randf_range(-0.2, 0.2), 0.003, 0.26 + rng.randf_range(-0.06, 0.06)), "ossidiana" if k % 3 != 0 else "riflesso_oss", Vector3(0, rng.randf() * 180, 0)))
	# ceste di grezzi d'ossidiana
	for k in 2:
		var cp := Vector3(-0.62 + k * 0.15, 0, 0.26 + k * 0.1)
		r.add_child(cilindro(0.07, 0.058, 0.065, cp + Vector3(0, 0.032, 0), "paglia_scura", Vector3.ZERO, 12))
		r.add_child(_toro(0.066, 0.074, cp + Vector3(0, 0.064, 0), "legno_vecchio"))
		r.add_child(_blocco_oss(cp + Vector3(0, 0.03, 0), 0.75, 3 + k))
	_catasta_pietre(r, Vector3(-0.3, 0, 0.5), 0.75, 176)
	_insegna_sicana(r, Vector3(0.84, 0, 0.3), 0.6)
	return r


## Arciere sicano: tunica blu lapislazzuli, cintura di cuoio col pugnale d'ossidiana, mantellina di pelle, berretto di
## pelle con il risvolto di pelliccia e i paraorecchie, faretra sulla schiena con le frecce dalla punta d'ossidiana,
## arco nella sinistra (col bracciale di cuoio) e una freccia nella destra.
static func arciere_sicano() -> Node3D:
	var r := portatore("", "lapislazzuli", "tunica_lapis")
	var corpo: Node3D = r.get_node("corpo")
	var anca := 0.2
	corpo.add_child(cilindro(0.083, 0.083, 0.018, Vector3(0, anca + 0.06, 0), "cuoio", Vector3.ZERO, 12))
	corpo.add_child(sfera(0.01, Vector3(0, anca + 0.06, 0.083), "oro_n"))
	corpo.add_child(cilindro(0.006, 0.006, 0.035, Vector3(0.062, anca + 0.055, 0.05), "legno", Vector3(0, 0, 8), 5))
	corpo.add_child(cilindro(0.01, 0.0, 0.05, Vector3(0.066, anca + 0.014, 0.053), "ossidiana", Vector3(180, 0, 8), 5))
	# mantellina di pelle sulle spalle
	corpo.add_child(cilindro(0.088, 0.075, 0.05, Vector3(0, anca + 0.165, -0.006), "pelliccia", Vector3.ZERO, 12))
	# tracolla della faretra
	corpo.add_child(scatola(Vector3(0.02, 0.21, 0.006), Vector3(0.0, anca + 0.1, 0.074), "cuoio", Vector3(0, 0, -36)))
	# berretto di pelle
	corpo.add_child(sfera(0.08, Vector3(0, anca + 0.285, -0.008), "cuoio", Vector3(1, 0.8, 1.05)))
	corpo.add_child(_toro(0.07, 0.087, Vector3(0, anca + 0.268, -0.008), "pelliccia", Vector3.ZERO, Vector3(1, 1.6, 1)))
	corpo.add_child(cilindro(0.081, 0.081, 0.01, Vector3(0, anca + 0.29, -0.008), "lapislazzuli", Vector3.ZERO, 14))
	corpo.add_child(cilindro(0.032, 0.0, 0.06, Vector3(0, anca + 0.36, -0.03), "cuoio", Vector3(-25, 0, 0), 8))
	for lato: int in [-1, 1]:
		corpo.add_child(scatola(Vector3(0.01, 0.05, 0.035), Vector3(lato * 0.078, anca + 0.235, 0.0), "cuoio"))
	# faretra sulla schiena
	corpo.add_child(_faretra(Vector3(0.035, anca + 0.16, -0.09), Vector3(-12, 0, -22), 1.0))
	# arco nella sinistra, col bracciale di cuoio
	var bs: Node3D = corpo.get_node("braccio_s")
	bs.add_child(cilindro(0.02, 0.018, 0.045, Vector3(0, -0.1, 0), "cuoio", Vector3.ZERO, 6))
	_arco_sic(bs, Vector3(-0.005, -0.14, 0.02), 0.24, 0.05)
	# freccia nella destra, con la punta d'ossidiana
	var bd: Node3D = corpo.get_node("braccio_d")
	bd.add_child(cilindro(0.0035, 0.0035, 0.28, Vector3(0, -0.08, 0.02), "legno", Vector3.ZERO, 4))
	bd.add_child(cilindro(0.01, 0.0, 0.035, Vector3(0, 0.077, 0.02), "ossidiana", Vector3.ZERO, 5))
	bd.add_child(scatola(Vector3(0.004, 0.035, 0.016), Vector3(0, -0.2, 0.02), "lino_bianco"))
	return r


# ------------------------------------------------------------------ altri edifici dei Sicani (step G6f)
# Stesso ingombro e stessa disposizione del corrispondente greco (stesso nome senza "_sicani"): la casa diventa la casa
# bassa di pietra grigia irregolare col tetto piatto d'erba, i recinti muri a secco con le lastre in cima, le giare orci
# grezzi con la fascia blu; dappertutto cataste di pietre, ossidiana nera e stoffe blu lapislazzuli.

## Orcio dei Sicani: vaso panciuto di terracotta grezza e scura col collo corto, fascia blu lapislazzuli (seme pari)
## o fila di tacche bianche (seme dispari), tappo di lastra.
static func _orcio_sic(pos: Vector3, scala := 1.0, seme := 0) -> Node3D:
	var n := Node3D.new()
	n.position = pos
	n.scale = Vector3.ONE * scala
	n.rotation_degrees.y = seme * 37.0
	n.add_child(sfera(0.048, Vector3(0, 0.05, 0), "terracotta", Vector3(1, 1.1, 1)))
	n.add_child(cilindro(0.03, 0.024, 0.03, Vector3(0, 0.104, 0), "terracotta", Vector3.ZERO, 8))
	n.add_child(cilindro(0.034, 0.034, 0.01, Vector3(0, 0.12, 0), "sasso_sic", Vector3.ZERO, 8))
	if absi(seme) % 2 == 0:
		n.add_child(cilindro(0.0485, 0.0485, 0.016, Vector3(0, 0.068, 0), "lapislazzuli", Vector3.ZERO, 12))
	else:
		for k in 4:
			var a := k * TAU / 8 - 0.4
			n.add_child(scatola(Vector3(0.012, 0.012, 0.006), Vector3(sin(a) * 0.047, 0.068, cos(a) * 0.047), "lino_bianco", Vector3(0, rad_to_deg(a), 45)))
	return n


## Bancone dei Sicani: lastra grigia di pietra appoggiata su due sassi grezzi.
static func _banco_sicano(r: Node3D, pos: Vector3, larg := 0.3, prof := 0.14, h := 0.1, rot_y := 0.0) -> void:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees.y = rot_y
	r.add_child(n)
	n.add_child(scatola(Vector3(larg, 0.03, prof), Vector3(0, h, 0), "lastra_sic", Vector3(0, 0, -1.5)))
	for lato: int in [-1, 1]:
		n.add_child(_sasso_sic(Vector3(lato * (larg * 0.5 - 0.05), (h - 0.015) * 0.5, 0), Vector3(0.07, h - 0.015, prof * 0.8), lato * 6.0, lato + 3))


## Vasca quadra di pietra a secco con l'acqua (abbeveratoio o cisterna), lastre sul bordo.
static func _vasca_sicana(r: Node3D, pos: Vector3, rg := 0.1, h := 0.06, mat := "acqua_pozzo") -> void:
	var l := rg * 2.0 + 0.05
	r.add_child(scatola(Vector3(l, h, l), pos + Vector3(0, h * 0.5, 0), "pietra_sicana"))
	r.add_child(scatola(Vector3(rg * 2.0, 0.004, rg * 2.0), pos + Vector3(0, h + 0.001, 0), mat))
	for f in 4:
		var a := f * 90.0
		r.add_child(scatola(Vector3(l + 0.01, 0.016, 0.03), pos + Vector3(0, h + 0.004, l * 0.5 - 0.012).rotated(Vector3.UP, deg_to_rad(a)), "lastra_sic" if f % 2 == 0 else "sasso_sic", Vector3(0, a + 3.0, 0)))


## Barca dei Sicani: scafo di tavole scure con la fascia blu lapislazzuli e i rombi bianchi, corna di montone sulla prua,
## panche e remo. pos = centro a terra, la prua verso +X locale.
static func _barca_sicana(r: Node3D, pos: Vector3, rot_y := 0.0, lung := 1.0) -> Node3D:
	var b := Node3D.new()
	b.position = pos
	b.rotation_degrees.y = rot_y
	b.scale = Vector3(lung, 1, 1)
	r.add_child(b)
	b.add_child(sfera(0.13, Vector3(0, 0.07, 0), "legno_scuro", Vector3(2.6, 0.7, 0.95)))
	b.add_child(sfera(0.115, Vector3(0, 0.1, 0), "legno_vecchio", Vector3(2.45, 0.35, 0.82)))
	for lato: int in [-1, 1]:
		b.add_child(scatola(Vector3(0.56, 0.022, 0.012), Vector3(0, 0.115, lato * 0.112), "lapislazzuli"))
		for k in 5:
			b.add_child(scatola(Vector3(0.014, 0.014, 0.006), Vector3(-0.2 + k * 0.1, 0.115, lato * 0.119), "lino_bianco", Vector3(0, 0, 45)))
	for x: float in [-0.12, 0.1]:
		b.add_child(scatola(Vector3(0.03, 0.012, 0.2), Vector3(x, 0.115, 0), "legno"))
	# corna di montone sulla prua
	b.add_child(sfera(0.018, Vector3(0.33, 0.14, 0), "osso", Vector3(1.1, 0.9, 0.8)))
	for lato: int in [-1, 1]:
		b.add_child(_toro(0.007, 0.02, Vector3(0.33, 0.15, lato * 0.026), "osso", Vector3(0, 0, 90)))
	b.add_child(scatola(Vector3(0.48, 0.008, 0.022), Vector3(0.02, 0.135, 0.05), "legno_chiaro", Vector3(0, 10, 6)))
	b.add_child(scatola(Vector3(0.07, 0.006, 0.035), Vector3(-0.22, 0.13, 0.09), "legno_chiaro", Vector3(0, 10, 6)))
	return b


## Porcile dei Sicani: casa bassa di pietra col tetto d'erba, recinto di muri a secco con le lastre in cima e il
## cancello di legno, truogolo di lastra, maiali nel fango sotto la quercia delle ghiande, catasta di pietre e orcio.
static func porcile_sicani() -> Node3D:
	var r := Node3D.new()
	_casa_sicana(r, Vector3(-0.3, 0, -0.32), 0.48, 0.37, 0.26, 801)
	var a := Vector3(0.05, 0, 0.0)
	r.add_child(scatola(Vector3(0.8, 0.012, 0.75), a + Vector3(0.12, 0.006, 0.12), "terra"))
	_muro_sic(r, a + Vector3(-0.28, 0, 0.5), a + Vector3(0.28, 0, 0.5), 0.08, 0.07)
	_graticcio(r, a + Vector3(0.3, 0, 0.5), a + Vector3(0.5, 0, 0.5), 0.08)
	_muro_sic(r, a + Vector3(0.52, 0, -0.26), a + Vector3(0.52, 0, 0.53), 0.08, 0.07)
	_muro_sic(r, a + Vector3(0.15, 0, -0.26), a + Vector3(0.55, 0, -0.26), 0.08, 0.07)
	r.add_child(sfera(0.14, a + Vector3(0.28, 0.0, 0.05), "fuliggine", Vector3(1.4, 0.1, 1.0)))
	# truogolo di pietra con il grano
	r.add_child(scatola(Vector3(0.24, 0.05, 0.08), a + Vector3(0.0, 0.025, 0.4), "lastra_sic"))
	r.add_child(scatola(Vector3(0.2, 0.008, 0.05), a + Vector3(0.0, 0.051, 0.4), "grano"))
	for p: Array in [[Vector3(0.25, 0, 0.3), 20], [Vector3(0.38, 0, -0.05), 130], [Vector3(0.05, 0, 0.18), -60], [Vector3(0.4, 0, 0.32), 200]]:
		r.add_child(maiale(a + (p[0] as Vector3), p[1]))
	r.add_child(scatola(Vector3(0.16, 0.04, 0.06), a + Vector3(-0.15, 0.02, 0.1), "pietra_sicana"))
	r.add_child(scatola(Vector3(0.13, 0.004, 0.04), a + Vector3(-0.15, 0.041, 0.1), "acqua_pozzo"))
	r.add_child(sacco(Vector3(-0.62, 0, 0.3), 0.3))
	r.add_child(_orcio_sic(Vector3(-0.48, 0, 0.42), 1.08, 0))
	_catasta_pietre(r, Vector3(-0.3, 0, 0.6), 0.5, 803)
	_quercia_n(r, Vector3(-0.7, 0, -0.1), 0.45, 202)
	for k in 6:
		r.add_child(sfera(0.012, Vector3(-0.6 + k * 0.04, 0.008, 0.05 + (k % 2) * 0.05), "corteccia"))
	return r


## Macelleria dei Sicani: casa di pietra a secco col tetto d'erba, tettoia di lastre con la carne appesa, bancone di
## lastra su due sassi con il coltello d'ossidiana, ceppo, orci e insegna blu.
static func macelleria_sicani() -> Node3D:
	var r := Node3D.new()
	_casa_sicana(r, Vector3(-0.2, 0, -0.25), 0.574, 0.434, 0.34, 811)
	_tettoia_sicana(r, Vector3(0.45, 0, 0.42), 0.6, 0.26, 0.42, 0.34, 212)
	r.add_child(cilindro(0.01, 0.01, 0.56, Vector3(0.45, 0.3, 0.52), "corteccia", Vector3(0, 0, 90), 5))
	for k in 5:
		var x := 0.25 + k * 0.1
		r.add_child(cilindro(0.003, 0.003, 0.05, Vector3(x, 0.275, 0.52), "corda", Vector3.ZERO, 3))
		if k % 2 == 0:
			r.add_child(sfera(0.035, Vector3(x, 0.215, 0.52), "carne", Vector3(0.9, 1.4, 0.8)))
		else:
			r.add_child(cilindro(0.016, 0.016, 0.1, Vector3(x, 0.205, 0.52), "carne", Vector3.ZERO, 8))
	var b := Vector3(-0.35, 0, 0.55)
	_banco_sicano(r, b, 0.32, 0.15, 0.1)
	r.add_child(sfera(0.04, b + Vector3(-0.05, 0.135, 0), "carne", Vector3(1.2, 0.5, 0.9)))
	r.add_child(_lama_oss(b + Vector3(0.08, 0.122, 0.02), Vector3(0, 30, 0), 0.08, true))
	r.add_child(cilindro(0.07, 0.075, 0.1, Vector3(-0.65, 0.05, 0.4), "corteccia", Vector3.ZERO, 12))
	r.add_child(_orcio_sic(Vector3(0.65, 0, 0.0), 1.32, 0))
	r.add_child(_orcio_sic(Vector3(0.68, 0, 0.16), 1.08, 1))
	r.add_child(maiale(Vector3(-0.6, 0, 0.0), 60))
	_insegna_sicana(r, Vector3(0.12, 0, 0.12), 0.55)
	return r


## Apiario dei Sicani: casa bassa di pietra, arnie a tronco di legno coricate a file su muri a secco, fiori tutto
## intorno, quercia, orci del miele.
static func apiario_sicani() -> Node3D:
	var r := Node3D.new()
	_casa_sicana(r, Vector3(-0.35, 0, -0.38), 0.44, 0.34, 0.24, 821)
	for f in 2:
		var z := 0.15 + f * 0.25
		_muro_sic(r, Vector3(-0.22, 0, z), Vector3(0.52, 0, z), 0.06, 0.12)
		for liv in 2:
			for k in 5 - liv:
				var x := -0.15 + k * 0.15 + liv * 0.075
				var p := Vector3(x, 0.105 + liv * 0.07, z)
				r.add_child(cilindro(0.035, 0.035, 0.16, p, "legno_vecchio", Vector3(90, 0, 0), 10))
				for dz: float in [-0.05, 0.05]:
					r.add_child(_toro(0.033, 0.039, p + Vector3(0, 0, dz), "corda", Vector3(90, 0, 0)))
				r.add_child(cilindro(0.032, 0.032, 0.01, p + Vector3(0, 0, 0.078), "terracotta", Vector3(90, 0, 0), 10))
				r.add_child(scatola(Vector3(0.016, 0.01, 0.006), p + Vector3(0, -0.012, 0.084), "buio"))
	var rng := _rng(222)
	for k in 30:
		var p := Vector3(rng.randf_range(-0.7, 0.7), 0.0, rng.randf_range(0.6, 0.75))
		if k % 2 == 0:
			p = Vector3(rng.randf_range(0.58, 0.75), 0.0, rng.randf_range(-0.3, 0.6))
		r.add_child(sfera(0.018, p + Vector3(0, 0.02, 0), "orto"))
		r.add_child(sfera(0.012, p + Vector3(0, 0.04, 0), ["fiore", "geranio", "miele"][k % 3]))
	_quercia_n(r, Vector3(0.55, 0, -0.42), 0.45, 223)
	r.add_child(_orcio_sic(Vector3(-0.62, 0, 0.2), 0.825, 2))
	r.add_child(_orcio_sic(Vector3(-0.52, 0, 0.3), 0.75, 1))
	r.add_child(_orcio_sic(Vector3(-0.66, 0, 0.36), 0.96, 1))
	return r


## Caseificio dei Sicani: casa di pietra col tetto d'erba e il fumo, paiolo col latte sul fuoco fra tre pali, ripiani
## di legno con le forme di formaggio sotto la tettoia di lastre e accanto alla casa, orci del latte.
static func caseificio_sicani() -> Node3D:
	var r := Node3D.new()
	_casa_sicana(r, Vector3(-0.2, 0, -0.25), 0.574, 0.434, 0.34, 831, 0.0, true, 0.0, true)
	var f := Vector3(0.45, 0, 0.45)
	_fuoco(r, f, 1.0)
	r.add_child(sfera(0.085, f + Vector3(0, 0.14, 0), "lino_bianco", Vector3(1, 0.85, 1)))
	r.add_child(cilindro(0.086, 0.086, 0.02, f + Vector3(0, 0.14, 0), "lapislazzuli", Vector3.ZERO, 14))
	r.add_child(cilindro(0.06, 0.06, 0.01, f + Vector3(0, 0.205, 0), "latte", Vector3.ZERO, 14))
	r.add_child(cilindro(0.062, 0.062, 0.012, f + Vector3(0, 0.2, 0), "lino_bianco", Vector3.ZERO, 14))
	for k in 3:
		var a := k * TAU / 3 + 0.5
		ramo(r, f + Vector3(cos(a) * 0.15, 0, sin(a) * 0.15), f + Vector3(0, 0.34, 0), 0.008, "corteccia")
	r.add_child(cilindro(0.004, 0.004, 0.12, f + Vector3(0, 0.27, 0), "corda", Vector3.ZERO, 3))
	_fumo(r, f + Vector3(0, 0.26, 0), 2, 0.6)
	_tettoia_sicana(r, Vector3(-0.3, 0, 0.5), 0.4, 0.2, 0.38, 0.32, 232)
	for p: Vector3 in [Vector3(-0.3, 0, 0.5), Vector3(0.7, 0, -0.05)]:
		var lungo_x := p.x < 0
		for liv in 3:
			r.add_child(scatola(Vector3(0.28 if lungo_x else 0.08, 0.012, 0.08 if lungo_x else 0.28), p + Vector3(0, 0.05 + liv * 0.08, 0), "legno_vecchio"))
			for k in 3:
				var o := Vector3((k - 1) * 0.085, 0, 0) if lungo_x else Vector3(0, 0, (k - 1) * 0.085)
				r.add_child(cilindro(0.033, 0.033, 0.035, p + o + Vector3(0, 0.074 + liv * 0.08, 0), "formaggio", Vector3.ZERO, 12))
		for s: int in [-1, 1]:
			var o2 := Vector3(s * 0.15, 0, 0) if lungo_x else Vector3(0, 0, s * 0.15)
			r.add_child(cilindro(0.008, 0.009, 0.24, p + o2 + Vector3(0, 0.12, 0), "corteccia", Vector3.ZERO, 5))
	r.add_child(_orcio_sic(Vector3(0.1, 0, 0.62), 1.02, 0))
	r.add_child(_orcio_sic(Vector3(0.24, 0, 0.6), 1.2, 1))
	return r


## Argillaio dei Sicani: casa bassa di pietra, mattoni crudi che seccano sulle tavole, fossa d'argilla bordata di
## sassi, stampo di legno, pala e vasca quadra di pietra a secco.
static func argillaio_sicani() -> Node3D:
	var r := Node3D.new()
	_casa_sicana(r, Vector3(-0.32, 0, -0.34), 0.44, 0.34, 0.24, 841)
	r.add_child(scatola(Vector3(0.44, 0.008, 0.18), Vector3(-0.41, 0.004, 0.45), "legno_vecchio"))
	r.add_child(sfera(0.3, Vector3(0.3, -0.02, 0.25), "argilla", Vector3(1.3, 0.12, 1.0)))
	r.add_child(sfera(0.22, Vector3(0.3, 0.0, 0.25), "argilla_cruda", Vector3(1.3, 0.08, 1.0)))
	for k in 6:
		var a := deg_to_rad(-20.0 + k * 40.0)
		r.add_child(sfera(0.03, Vector3(0.3 + cos(a) * 0.37, 0.01, 0.25 + sin(a) * 0.29), "pietra_sicana", Vector3(1.2, 0.6, 1.0)))
	for k in 12:
		r.add_child(scatola(Vector3(0.07, 0.03, 0.04), Vector3(-0.55 + (k % 4) * 0.09, 0.024 + (k / 4) * 0.032, 0.45), "argilla" if k % 3 else "argilla_cruda", Vector3(0, (k % 2) * 5, 0)))
	r.add_child(scatola(Vector3(0.1, 0.02, 0.06), Vector3(-0.12, 0.01, 0.6), "legno_vecchio"))
	r.add_child(scatola(Vector3(0.07, 0.006, 0.04), Vector3(-0.12, 0.023, 0.6), "buio"))
	var a := attrezzo("pala")
	a.position = Vector3(0.62, 0.02, 0.05)
	a.rotation_degrees = Vector3(0, 40, 10)
	r.add_child(a)
	_vasca_sicana(r, Vector3(0.04, 0, 0.62), 0.07, 0.05)
	r.add_child(_orcio_sic(Vector3(-0.02, 0, 0.0), 1.08, 1))
	return r


## Fornace dei Sicani: casa di pietra col tetto d'erba, forno a falsa cupola di pietre coperto d'erba con la bocca
## accesa e il fumo, file di orci ad asciugare, mucchio d'argilla, legna e fascine.
static func fornace_sicani() -> Node3D:
	var r := Node3D.new()
	_casa_sicana(r, Vector3(-0.25, 0, -0.3), 0.465, 0.357, 0.272, 851)
	_forno_sicano(r, Vector3(0.42, 0, 0.3), 1.05)
	for k in 7:
		var p := Vector3(-0.6 + (k % 4) * 0.1, 0, 0.42 + (k / 4) * 0.12)
		if k % 3 == 1:
			r.add_child(_orcio_sic(p, 0.78, k))
		else:
			r.add_child(_orcio_sic(p, 0.75, k % 3))
	r.add_child(mucchio(Vector3(0.68, 0, -0.18), "argilla_cruda", 8, 9))
	legnaia(r, Vector3(0.68, 0, 0.12), 0.2, 3)
	_fascina(r, Vector3(0.1, 0, 0.62), 80.0)
	return r


## Saline dei Sicani: vasche di evaporazione bordate di pietra a secco, canaletta, cumuli di sale, casetta di pietra
## col tetto d'erba, pala, sacco e orcio.
static func saline_sicani() -> Node3D:
	var r := Node3D.new()
	for i in 3:
		for j in 2:
			var p := Vector3(-0.45 + i * 0.42, 0, -0.25 + j * 0.5)
			r.add_child(scatola(Vector3(0.4, 0.04, 0.46), p + Vector3(0, 0.02, 0), "pietra_sicana"))
			var mat := "acqua_chiara" if (i + j) % 3 != 0 else "sale"
			r.add_child(scatola(Vector3(0.34, 0.005, 0.4), p + Vector3(0, 0.042, 0), mat))
			r.add_child(scatola(Vector3(0.05, 0.008, 0.04), p + Vector3(0, 0.04, -0.21), "acqua_chiara"))
			for k in 4:
				var q := p + Vector3(-0.17 + (k % 2) * 0.34, 0.04, -0.2 + (k / 2) * 0.4)
				r.add_child(sfera(0.024, q, "lastra_sic", Vector3(1.2, 0.6, 1.0)))
	var cz := -0.53
	r.add_child(scatola(Vector3(1.1, 0.024, 0.07), Vector3(-0.13, 0.012, cz), "pietra_sicana"))
	r.add_child(scatola(Vector3(1.1, 0.004, 0.035), Vector3(-0.13, 0.026, cz), "acqua_chiara"))
	for p: Vector3 in [Vector3(0.62, 0, 0.55), Vector3(0.42, 0, 0.62), Vector3(-0.6, 0, 0.6)]:
		r.add_child(sfera(0.1, p, "sale", Vector3(1, 0.9, 1)))
	_casa_sicana(r, Vector3(0.62, 0, -0.66), 0.29, 0.25, 0.2, 861, 0.0, true)
	var a := attrezzo("pala")
	a.position = Vector3(0.25, 0.02, 0.45)
	a.rotation_degrees = Vector3(0, -30, 5)
	r.add_child(a)
	r.add_child(sacco(Vector3(0.0, 0, 0.62), 0.3))
	r.add_child(_orcio_sic(Vector3(0.32, 0, -0.74), 0.96, 0))
	return r


## Tessitura dei Sicani: casa di pietra col tetto d'erba, telaio verticale a pesi con la tela a fasce blu lapislazzuli
## e bianche, matasse di lana, drappi blu e chiari stesi su una pertica, cesta di lana.
static func tessitura_sicani() -> Node3D:
	var r := Node3D.new()
	_casa_sicana(r, Vector3(-0.2, 0, -0.28), 0.558, 0.403, 0.34, 871)
	var t := Vector3(0.0, 0, 0.5)
	for x: float in [-0.18, 0.18]:
		r.add_child(cilindro(0.012, 0.014, 0.44, t + Vector3(x, 0.21, -0.02), "corteccia", Vector3(-6, 0, 0), 6))
	r.add_child(cilindro(0.012, 0.012, 0.42, t + Vector3(0, 0.4, -0.04), "legno_vecchio", Vector3(0, 0, 90), 6))
	var fili := ["lapislazzuli", "lino_bianco", "lino", "lapislazzuli", "lino", "lino_bianco"]
	for k in 6:
		r.add_child(scatola(Vector3(0.34, 0.03, 0.006), t + Vector3(0, 0.37 - k * 0.03, -0.035 + k * 0.003), fili[k]))
	for k in 12:
		r.add_child(scatola(Vector3(0.004, 0.13, 0.004), t + Vector3(-0.155 + k * 0.028, 0.15, -0.012), "lino"))
	# pesi da telaio d'argilla appesi ai fili
	for k in 8:
		r.add_child(cilindro(0.012, 0.022, 0.04, t + Vector3(-0.14 + k * 0.04, 0.07, -0.01 + (k % 2) * 0.012), "terracotta", Vector3.ZERO, 4))
	r.add_child(cilindro(0.006, 0.006, 0.36, t + Vector3(0, 0.1, -0.01), "legno_vecchio", Vector3(0, 0, 90), 5))
	var colori := ["lana", "lapislazzuli", "lino_bianco"]
	for i in 3:
		var p := Vector3(0.52 + (i % 2) * 0.06, 0, 0.05 + i * 0.1)
		r.add_child(sfera(0.045, p + Vector3(0, 0.035, 0), colori[i], Vector3(1.2, 0.8, 1)))
	r.add_child(cesta(Vector3(0.66, 0, 0.42), "lana"))
	for x: float in [0.36, 0.86]:
		r.add_child(cilindro(0.009, 0.01, 0.36, Vector3(x, 0.18, -0.35), "corteccia", Vector3.ZERO, 5))
	r.add_child(cilindro(0.008, 0.008, 0.54, Vector3(0.61, 0.36, -0.35), "legno_vecchio", Vector3(0, 0, 90), 5))
	for k in 2:
		var x := 0.49 + k * 0.24
		r.add_child(scatola(Vector3(0.2, 0.24, 0.006), Vector3(x, 0.24, -0.345), "lapislazzuli" if k == 0 else "lino"))
		for y: float in [0.3, 0.2]:
			r.add_child(scatola(Vector3(0.202, 0.02, 0.008), Vector3(x, y, -0.345), "lino_bianco" if k == 0 else "lapislazzuli"))
		r.add_child(scatola(Vector3(0.05, 0.05, 0.009), Vector3(x, 0.25, -0.345), "lino_bianco" if k == 0 else "lino_bianco", Vector3(0, 0, 45)))
	return r


## Pescatore dei Sicani: casa di pietra col tetto d'erba, reti stese su pali, barca con la fascia blu e le corna di
## montone a prua tirata a secco, ceste di pesce, orcio e quercia.
static func capanna_pescatore_sicani() -> Node3D:
	var r := Node3D.new()
	_casa_sicana(r, Vector3(-0.22, 0, -0.25), 0.512, 0.388, 0.306, 881)
	for x: float in [0.35, 0.75]:
		r.add_child(cilindro(0.012, 0.014, 0.36, Vector3(x, 0.18, -0.35), "corteccia", Vector3.ZERO, 6))
	r.add_child(scatola(Vector3(0.4, 0.26, 0.006), Vector3(0.55, 0.2, -0.35), "rete"))
	for k in 6:
		r.add_child(scatola(Vector3(0.004, 0.26, 0.008), Vector3(0.37 + k * 0.07, 0.2, -0.345), "corda"))
	for k in 4:
		r.add_child(scatola(Vector3(0.4, 0.004, 0.008), Vector3(0.55, 0.1 + k * 0.065, -0.345), "corda"))
	for k in 4:
		r.add_child(cilindro(0.012, 0.012, 0.02, Vector3(0.4 + k * 0.1, 0.07, -0.34), "terracotta", Vector3(90, 0, 0), 6))
	_barca_sicana(r, Vector3(0.35, 0, 0.45), -25.0)
	r.add_child(cesta(Vector3(-0.45, 0, 0.45), "pesce"))
	r.add_child(cesta(Vector3(-0.3, 0, 0.58), "pesce"))
	r.add_child(_orcio_sic(Vector3(-0.62, 0, 0.25), 1.2, 0))
	_quercia_n(r, Vector3(-0.66, 0, -0.05), 0.42, 282)
	return r


## Frantoio dei Sicani: casa grande di pietra col tetto d'erba, macina di lastra nella vasca di pietra a secco girata
## a mano, orci dell'olio, fiscoli di paglia con la pasta d'olive, grande orcio, ulivo e insegna blu.
static func frantoio_sicani() -> Node3D:
	var r := Node3D.new()
	_casa_sicana(r, Vector3(-0.2, 0, -0.22), 0.635, 0.48, 0.357, 891)
	var m := Vector3(-0.35, 0, 0.55)
	r.add_child(cilindro(0.26, 0.28, 0.1, m + Vector3(0, 0.05, 0), "pietra_sicana", Vector3.ZERO, 24))
	r.add_child(cilindro(0.27, 0.27, 0.012, m + Vector3(0, 0.104, 0), "lastra_sic", Vector3.ZERO, 24))
	r.add_child(cilindro(0.21, 0.21, 0.01, m + Vector3(0, 0.106, 0), "foglie_ulivo", Vector3.ZERO, 24))
	r.add_child(cilindro(0.03, 0.03, 0.22, m + Vector3(0, 0.2, 0), "legno_vecchio", Vector3.ZERO, 8))
	r.add_child(cilindro(0.12, 0.12, 0.08, m + Vector3(0.1, 0.22, 0), "lastra_sic", Vector3(0, 0, 90), 18))
	r.add_child(scatola(Vector3(0.6, 0.03, 0.03), m + Vector3(0.2, 0.26, 0), "legno_vecchio"))
	for i in 6:
		var p := Vector3(0.25 + (i % 3) * 0.1, 0.0, 0.42 + (i / 3) * 0.11)
		if i % 2 == 0:
			r.add_child(_orcio_sic(p, 0.84, i))
		else:
			r.add_child(_orcio_sic(p, 0.862, 2))
	for i in 3:
		r.add_child(cilindro(0.06, 0.05, 0.06, Vector3(0.62, 0.03, -0.3 + i * 0.16), "paglia", Vector3.ZERO, 12))
		r.add_child(sfera(0.05, Vector3(0.62, 0.06, -0.3 + i * 0.16), "foglie_ulivo", Vector3(1, 0.4, 1)))
	r.add_child(_orcio_sic(Vector3(0.62, 0.0, 0.25), 1.74, 1))
	var u := ulivo(292)
	u.position = Vector3(-0.72, 0, -0.45)
	u.scale = Vector3.ONE * 0.8
	r.add_child(u)
	_insegna_sicana(r, Vector3(0.3, 0, 0.18), 0.55)
	return r


## Uliveto dei Sicani: casa bassa di pietra, telo steso sotto l'ulivo, ceste di olive, scala a pioli, orcio, muro a
## secco e catasta di pietre tolte dal campo.
static func uliveto_sicani() -> Node3D:
	var r := Node3D.new()
	_casa_sicana(r, Vector3(-0.3, 0, -0.3), 0.449, 0.357, 0.255, 901)
	var u := ulivo(302)
	u.position = Vector3(0.35, 0, 0.3)
	u.scale = Vector3.ONE * 0.8
	r.add_child(u)
	r.add_child(scatola(Vector3(0.5, 0.004, 0.45), Vector3(0.35, 0.004, 0.3), "lino", Vector3(0, 12, 0)))
	for k in 12:
		r.add_child(sfera(0.012, Vector3(0.2 + (k % 4) * 0.08, 0.012, 0.18 + (k / 4) * 0.1), "oliva"))
	_muro_sic(r, Vector3(0.72, 0, -0.3), Vector3(0.72, 0, 0.5), 0.07, 0.07)
	_catasta_pietre(r, Vector3(0.3, 0, -0.42), 0.6, 903)
	for p: Vector3 in [Vector3(-0.45, 0, 0.45), Vector3(-0.25, 0, 0.55), Vector3(0.58, 0, -0.2)]:
		r.add_child(cesta(p, "olive"))
	for z: float in [0.12, 0.2]:
		r.add_child(cilindro(0.012, 0.012, 0.45, Vector3(0.12, 0.22, z), "corteccia", Vector3(0, 0, -18), 5))
	for k in 5:
		r.add_child(scatola(Vector3(0.012, 0.012, 0.08), Vector3(0.05 + k * 0.03, 0.03 + k * 0.08, 0.16), "legno_vecchio"))
	r.add_child(_orcio_sic(Vector3(-0.62, 0, 0.2), 1.2, 0))
	return r


## Vigneto dei Sicani: casa di pietra col tetto d'erba, pergolato d'uva su pali con la base di sasso, palmento
## scavato nella roccia con la vaschetta del mosto, ceste di grappoli.
static func vigneto_sicani() -> Node3D:
	var r := Node3D.new()
	_casa_sicana(r, Vector3(-0.25, 0, -0.32), 0.512, 0.372, 0.289, 911)
	for p: Vector3 in [Vector3(-0.35, 0, 0.15), Vector3(0.25, 0, 0.15), Vector3(-0.35, 0, 0.55), Vector3(0.25, 0, 0.55)]:
		r.add_child(cilindro(0.016, 0.02, 0.36, p + Vector3(0, 0.18, 0), "corteccia", Vector3.ZERO, 6))
		r.add_child(sfera(0.035, p + Vector3(0, 0.015, 0), "pietra_sicana", Vector3(1.2, 0.6, 1.0)))
	for z: float in [0.15, 0.55]:
		r.add_child(cilindro(0.011, 0.011, 0.68, Vector3(-0.05, 0.355, z), "legno_vecchio", Vector3(0, 0, 90), 5))
	for k in 6:
		r.add_child(cilindro(0.006, 0.006, 0.44, Vector3(-0.35 + k * 0.12, 0.368, 0.35), "legno_vecchio", Vector3(90, 0, 0), 4))
	var rng := _rng(312)
	for k in 26:
		r.add_child(sfera(0.045, Vector3(rng.randf_range(-0.38, 0.28), 0.38, rng.randf_range(0.12, 0.58)), "foglie" if k % 3 else "foglie_chiare", Vector3(1, 0.5, 1)))
	for k in 6:
		r.add_child(sfera(0.022, Vector3(-0.3 + k * 0.1, 0.33, 0.35 + (k % 2) * 0.1), "uva", Vector3(1, 1.5, 1)))
	# palmento: vasca scavata in un masso piatto, beccuccio e vaschetta del mosto
	var v := Vector3(0.55, 0, 0.38)
	r.add_child(sfera(0.16, v + Vector3(0, 0.0, 0), "lastra_sic", Vector3(1.0, 0.5, 0.9)))
	r.add_child(cilindro(0.11, 0.1, 0.01, v + Vector3(0, 0.075, 0), "vino", Vector3.ZERO, 14))
	r.add_child(sfera(0.022, v + Vector3(0.0, 0.085, 0.0), "uva", Vector3(1.6, 0.5, 1.4)))
	r.add_child(scatola(Vector3(0.03, 0.012, 0.06), v + Vector3(0, 0.05, 0.15), "lastra_sic", Vector3(-20, 0, 0)))
	r.add_child(cilindro(0.05, 0.045, 0.04, v + Vector3(0, 0.02, 0.22), "pietra_sicana", Vector3.ZERO, 10))
	r.add_child(cilindro(0.038, 0.038, 0.004, v + Vector3(0, 0.041, 0.22), "vino", Vector3.ZERO, 10))
	r.add_child(cesta(Vector3(0.62, 0, 0.0), "uva"))
	r.add_child(cesta(Vector3(0.45, 0, -0.2), "uva"))
	return r


## Cantina dei Sicani: casa grande di pietra col tetto d'erba, grandi orci del vino interrati a metà in un letto di
## pietre, orci minori in fila, palmento di pietra con il torchio a leva appesantito da un masso, cesta d'uva, insegna.
static func cantina_sicani() -> Node3D:
	var r := Node3D.new()
	_casa_sicana(r, Vector3(-0.2, 0, -0.25), 0.589, 0.434, 0.323, 921)
	r.add_child(scatola(Vector3(0.22, 0.04, 0.66), Vector3(0.62, 0.02, -0.1), "pietra_sicana"))
	for k in 3:
		var p := Vector3(0.62, 0.0, -0.32 + k * 0.21)
		r.add_child(_orcio_sic(p + Vector3(0, -0.03, 0), 1.62, k))
		r.add_child(cilindro(0.09, 0.095, 0.03, p + Vector3(0, 0.035, 0), "pietra_sicana", Vector3.ZERO, 12))
	for k in 5:
		r.add_child(_orcio_sic(Vector3(-0.6 + (k % 3) * 0.1, 0, 0.42 + (k / 3) * 0.12), 0.9, k))
	var t := Vector3(0.2, 0, 0.55)
	r.add_child(scatola(Vector3(0.36, 0.06, 0.28), t + Vector3(0, 0.03, 0), "pietra_sicana"))
	r.add_child(scatola(Vector3(0.3, 0.01, 0.22), t + Vector3(0, 0.065, 0), "vino"))
	r.add_child(scatola(Vector3(0.22, 0.03, 0.16), t + Vector3(0, 0.085, 0), "legno_vecchio"))
	# torchio a leva: palo forcuto, trave lunga, masso appeso
	r.add_child(cilindro(0.02, 0.024, 0.3, t + Vector3(-0.2, 0.15, 0), "corteccia", Vector3.ZERO, 6))
	r.add_child(cilindro(0.016, 0.016, 0.5, t + Vector3(0.02, 0.17, 0), "legno_vecchio", Vector3(0, 0, 80), 6))
	r.add_child(cilindro(0.004, 0.004, 0.08, t + Vector3(0.24, 0.12, 0), "corda", Vector3.ZERO, 3))
	r.add_child(sfera(0.05, t + Vector3(0.25, 0.06, 0), "roccia_massi", Vector3(1.1, 0.9, 1.0)))
	r.add_child(cesta(Vector3(-0.15, 0, 0.62), "uva"))
	_insegna_sicana(r, Vector3(0.28, 0, 0.12), 0.5)
	return r


## Ortolano dei Sicani: casa di pietra col tetto d'erba, orto chiuso dal muro a secco e bagnato dalla canaletta di
## pietra, trecce di cipolle appese a una pertica, ceste di verdura e orcio dell'acqua.
static func ortolano_sicani() -> Node3D:
	var r := Node3D.new()
	_casa_sicana(r, Vector3(-0.3, 0, -0.32), 0.449, 0.341, 0.272, 931)
	orto(r, Vector3(0.45, 0, 0.0), 0.36, 0.6, 332)
	r.add_child(scatola(Vector3(0.05, 0.02, 0.64), Vector3(0.45, 0.01, 0.0), "pietra_sicana"))
	r.add_child(scatola(Vector3(0.025, 0.004, 0.64), Vector3(0.45, 0.021, 0.0), "acqua_chiara"))
	_muro_sic(r, Vector3(0.68, 0, -0.34), Vector3(0.68, 0, 0.34), 0.08, 0.07)
	for x: float in [-0.56, -0.2]:
		r.add_child(cilindro(0.01, 0.012, 0.34, Vector3(x, 0.17, 0.14), "corteccia", Vector3.ZERO, 5))
	r.add_child(cilindro(0.008, 0.008, 0.38, Vector3(-0.38, 0.33, 0.14), "legno_vecchio", Vector3(0, 0, 90), 5))
	for k in 4:
		for i in 4:
			r.add_child(sfera(0.02, Vector3(-0.5 + k * 0.08, 0.3 - i * 0.04, 0.14), "cipolla"))
	for p: Vector3 in [Vector3(-0.4, 0, 0.45), Vector3(-0.2, 0, 0.55)]:
		r.add_child(cesta(p, "ortaggi"))
	r.add_child(cesta(Vector3(0.05, 0, 0.6), "cipolle"))
	r.add_child(_orcio_sic(Vector3(0.12, 0, 0.42), 1.02, 1))
	return r


## Agrumeto dei Sicani: casa di pietra col tetto d'erba, grande albero di agrumi nell'aiuola bordata di sassi, vasca
## quadra di pietra a secco con la canaletta, ceste di arance e limoni, orcio.
static func agrumeto_sicani() -> Node3D:
	var r := Node3D.new()
	_casa_sicana(r, Vector3(-0.3, 0, -0.3), 0.465, 0.357, 0.255, 941)
	var a := agrumi(3)
	var terra := a.get_child(0)
	a.remove_child(terra)
	terra.free()
	a.position = Vector3(0.3, 0, 0.25)
	a.scale = Vector3.ONE * 1.1
	r.add_child(a)
	r.add_child(cilindro(0.18, 0.18, 0.006, Vector3(0.3, 0.003, 0.25), "terra", Vector3.ZERO, 16))
	for k in 12:
		var an := k * TAU / 12
		r.add_child(sfera(0.03, Vector3(0.3 + cos(an) * 0.2, 0.012, 0.25 + sin(an) * 0.2), "pietra_sicana" if k % 2 else "lastra_sic", Vector3(1.2, 0.65, 1.0)))
	_vasca_sicana(r, Vector3(-0.02, 0, 0.6), 0.07, 0.08)
	r.add_child(scatola(Vector3(0.2, 0.02, 0.045), Vector3(0.145, 0.01, 0.51), "pietra_sicana", Vector3(0, 50, 0)))
	r.add_child(scatola(Vector3(0.2, 0.004, 0.022), Vector3(0.145, 0.021, 0.51), "acqua_chiara", Vector3(0, 50, 0)))
	for p: Vector3 in [Vector3(-0.45, 0, 0.45), Vector3(-0.28, 0, 0.6), Vector3(0.7, 0, -0.25)]:
		r.add_child(cesta(p, "agrumi"))
	r.add_child(_orcio_sic(Vector3(0.65, 0, 0.08), 1.08, 0))
	return r


## Pesca del pesce spada dei Sicani: casa di pietra col tetto d'erba, grande barca con l'albero di vedetta e il drappo
## blu, la passerella dell'arpioniere, l'arpione con la punta d'ossidiana, il pesce spada e l'orcio.
static func pesca_spada_sicani() -> Node3D:
	var r := Node3D.new()
	_casa_sicana(r, Vector3(-0.3, 0, -0.3), 0.465, 0.357, 0.255, 951)
	var b := _barca_sicana(r, Vector3(0.3, 0, 0.35), -30.0, 1.15)
	b.add_child(cilindro(0.01, 0.008, 0.6, Vector3(0.0, 0.42, 0), "corteccia", Vector3.ZERO, 6))
	for k in 5:
		b.add_child(scatola(Vector3(0.07, 0.006, 0.01), Vector3(0.0, 0.2 + k * 0.08, 0.0), "legno_vecchio"))
	b.add_child(scatola(Vector3(0.006, 0.06, 0.09), Vector3(0.0, 0.67, 0.045), "lapislazzuli"))
	b.add_child(scatola(Vector3(0.008, 0.012, 0.09), Vector3(0.0, 0.67, 0.045), "lino_bianco"))
	b.add_child(scatola(Vector3(0.4, 0.012, 0.02), Vector3(0.5, 0.13, 0), "legno_chiaro"))
	r.add_child(cilindro(0.006, 0.006, 0.5, Vector3(-0.6, 0.15, 0.4), "legno", Vector3(90, 0, 4), 5))
	r.add_child(cilindro(0.016, 0.0, 0.06, Vector3(-0.6, 0.15, 0.67), "ossidiana", Vector3(90, 0, 0), 5))
	var sp := pesce_spada_modello()
	sp.position = Vector3(-0.35, 0.02, 0.55)
	r.add_child(sp)
	r.add_child(_orcio_sic(Vector3(-0.66, 0, 0.1), 1.14, 1))
	return r


## Miniera dei Sicani: fianco della montagna con l'imbocco fra due stipiti di pietra grigia e l'architrave monolitico,
## slitta di legno e gerla con il minerale, mucchio, puntelli, lucerna su un palo, insegna blu e orcio.
static func miniera_ferro_sicani(minerale := "minerale") -> Node3D:
	var r := Node3D.new()
	r.add_child(sfera(0.6, Vector3(-0.25, 0.0, -0.3), "roccia_massi", Vector3(1.2, 0.75, 1.0)))
	r.add_child(sfera(0.35, Vector3(0.35, 0.0, -0.45), "roccia_massi", Vector3(1.1, 0.8, 1.0)))
	r.add_child(sfera(0.3, Vector3(-0.65, 0.0, 0.15), "roccia_massi", Vector3(1.0, 0.7, 1.0)))
	var imb := Vector3(-0.05, 0, 0.18)
	r.add_child(scatola(Vector3(0.42, 0.3, 0.12), imb + Vector3(0, 0.15, -0.04), "pietra_sicana"))
	r.add_child(scatola(Vector3(0.2, 0.25, 0.1), imb + Vector3(0, 0.125, 0.06), "buio"))
	_porta_sicana(r, imb + Vector3(0, 0, 0.12), 0.0, 0.18, 0.24, false)
	for lato: int in [-1, 1]:
		r.add_child(cilindro(0.014, 0.016, 0.24, imb + Vector3(lato * 0.15, 0.12, 0.16), "corteccia", Vector3.ZERO, 6))
	r.add_child(cilindro(0.014, 0.014, 0.36, imb + Vector3(0, 0.25, 0.16), "legno_vecchio", Vector3(0, 0, 90), 6))
	# slitta di legno con il minerale e gerla
	var carr := Vector3(-0.05, 0, 0.5)
	for lato: int in [-1, 1]:
		r.add_child(scatola(Vector3(0.016, 0.02, 0.24), carr + Vector3(lato * 0.065, 0.01, 0), "legno_vecchio"))
	r.add_child(scatola(Vector3(0.15, 0.06, 0.18), carr + Vector3(0, 0.05, 0), "legno_vecchio"))
	r.add_child(mucchio(carr + Vector3(0, 0.08, 0), minerale, 6, 3, 0.03))
	r.add_child(cilindro(0.004, 0.004, 0.2, carr + Vector3(0, 0.03, 0.2), "corda", Vector3(90, 0, 0), 3))
	r.add_child(cilindro(0.05, 0.035, 0.11, Vector3(-0.3, 0.055, 0.42), "paglia", Vector3(0, 0, 8), 10))
	r.add_child(mucchio(Vector3(-0.3, 0.1, 0.42), minerale, 4, 4, 0.025))
	r.add_child(mucchio(Vector3(0.45, 0, 0.35), minerale, 14, 4))
	# lucerna di ceramica su un palo
	r.add_child(cilindro(0.01, 0.012, 0.3, Vector3(0.22, 0.15, 0.3), "corteccia", Vector3.ZERO, 5))
	r.add_child(_orcio_sic(Vector3(0.22, 0.29, 0.3), 0.45, 0))
	r.add_child(sfera(0.014, Vector3(0.22, 0.35, 0.3), "brace"))
	for k in 4:
		r.add_child(cilindro(0.018, 0.018, 0.4, Vector3(-0.55 + k * 0.045, 0.02 + (k % 2) * 0.03, 0.55), "corteccia", Vector3(0, 70, 90), 6))
	r.add_child(_orcio_sic(Vector3(0.3, 0, 0.55), 1.02, 0))
	_insegna_sicana(r, Vector3(0.62, 0, 0.08), 0.5)
	return r


## Zecca dei Sicani: casa grande di pietra col tetto d'erba e lo scudo blu sulla porta, torretta tonda del tesoro di
## pietra a secco col tetto piatto d'erba e la fascia blu, coppe colme di monete, incudine di pietra col punzone
## d'ossidiana, argento grezzo e l'arciere sicano di guardia.
static func zecca_sicani() -> Node3D:
	var r := Node3D.new()
	_casa_sicana(r, Vector3(-0.12, 0, -0.2), 0.574, 0.434, 0.357, 971)
	r.add_child(_scudo_sicano(Vector3(-0.12, 0.3, 0.135), 0.0, 0.85))
	# torretta del tesoro
	var tp := Vector3(-0.55, 0, -0.5)
	var ht := 0.44
	r.add_child(cilindro(0.15, 0.18, ht, tp + Vector3(0, ht * 0.5, 0), "pietra_sicana", Vector3.ZERO, 16))
	r.add_child(cilindro(0.155, 0.155, 0.03, tp + Vector3(0, ht - 0.08, 0), "lapislazzuli", Vector3.ZERO, 16))
	for k in 14:
		var ak := k * TAU / 14
		r.add_child(_sasso_sic(tp + Vector3(cos(ak) * 0.158, ht * 0.3 + (k % 3) * 0.08, sin(ak) * 0.158), Vector3(0.06, 0.035, 0.022), -rad_to_deg(ak) + 90.0, k))
	r.add_child(cilindro(0.19, 0.19, 0.03, tp + Vector3(0, ht + 0.015, 0), "lastra_sic", Vector3.ZERO, 12))
	r.add_child(cilindro(0.165, 0.165, 0.03, tp + Vector3(0, ht + 0.045, 0), "terra", Vector3.ZERO, 14))
	r.add_child(sfera(0.165, tp + Vector3(0, ht + 0.058, 0), "erba_tetto", Vector3(1, 0.3, 1)))
	for k in 5:
		var ak := k * TAU / 5 + 0.4
		r.add_child(sfera(0.024, tp + Vector3(cos(ak) * 0.09, ht + 0.1, sin(ak) * 0.09), "prato" if k % 2 == 0 else "foglie_chiare", Vector3(1.2, 0.6, 1.2)))
	r.add_child(scatola(Vector3(0.04, 0.08, 0.03), tp + Vector3(0.1, ht * 0.6, 0.12), "buio", Vector3(0, 40, 0)))
	_insegna_sicana(r, Vector3(0.32, 0, 0.12), 0.6)
	# coppe di monete sulla lastra
	_banco_sicano(r, Vector3(0.55, 0, 0.4), 0.38, 0.14, 0.08)
	for k in 3:
		var p := Vector3(0.43 + k * 0.12, 0.095, 0.4)
		r.add_child(_orcio_sic(p, 0.675, 0))
		r.add_child(cilindro(0.04, 0.04, 0.012, p + Vector3(0, 0.08, 0), "moneta", Vector3.ZERO, 10))
	r.add_child(_orcio_sic(Vector3(0.66, 0, 0.12), 1.2, 1))
	r.add_child(cilindro(0.04, 0.05, 0.08, Vector3(-0.35, 0.04, 0.5), "corteccia", Vector3.ZERO, 10))
	r.add_child(sfera(0.05, Vector3(-0.35, 0.1, 0.5), "lastra_sic", Vector3(1.2, 0.6, 1.0)))
	r.add_child(cilindro(0.012, 0.0, 0.06, Vector3(-0.32, 0.15, 0.5), "ossidiana", Vector3(180, 0, 0), 5))
	r.add_child(mucchio(Vector3(-0.62, 0, 0.25), "argento_grezzo", 8, 10))
	var g := arciere_sicano()
	g.position = Vector3(0.18, 0, 0.5)
	g.scale = Vector3.ONE * 0.9
	r.add_child(g)
	return r


## Porto dei Sicani: banchina di pietra a secco, pontile di legno sul mare, bitte di lastra, casa di pietra col tetto
## d'erba e la tettoia di lastre sul davanti, orci, ceste e sacchi, gru di tronchi con l'orcio nella rete,
## vela blu arrotolata, ancora di pietra forata e insegna.
static func porto_sicani() -> Node3D:
	var r := Node3D.new()
	var rng := _rng(381)
	r.add_child(scatola(Vector3(0.42, 0.1, 1.08), Vector3(0.36, 0.05, 0.02), "pietra_sicana"))
	r.add_child(scatola(Vector3(0.46, 0.025, 1.12), Vector3(0.36, 0.112, 0.02), "pietra_sicana"))
	for k in 18:
		r.add_child(sfera(rng.randf_range(0.026, 0.034), Vector3(0.58, 0.11, -0.5 + k * 0.06), "pietra_sicana" if k % 3 else "lastra_sic", Vector3(0.7, 0.6, 1.2)))
	var pz := 0.26
	for k in 4:
		var x := 0.66 + k * 0.13
		for s: int in [-1, 1]:
			r.add_child(cilindro(0.017, 0.019, 0.26, Vector3(x, -0.01, pz + s * 0.12), "corteccia", Vector3.ZERO, 7))
			r.add_child(cilindro(0.02, 0.02, 0.012, Vector3(x, 0.01, pz + s * 0.12), "foglie_scure", Vector3.ZERO, 7))
	for s: int in [-1, 1]:
		r.add_child(scatola(Vector3(0.5, 0.025, 0.02), Vector3(0.82, 0.095, pz + s * 0.12), "legno_vecchio"))
	for k in 13:
		var x := 0.59 + k * 0.038
		r.add_child(scatola(Vector3(0.034, 0.014, 0.28), Vector3(x, 0.112 + rng.randf_range(-0.003, 0.003), pz), "legno_vecchio" if k % 3 else "legno", Vector3(0, rng.randf_range(-2, 2), 0)))
	for z: float in [-0.42, -0.08, 0.5]:
		r.add_child(sfera(0.034, Vector3(0.5, 0.15, z), "lastra_sic", Vector3(1, 1.4, 1)))
	for x: float in [0.72, 1.02]:
		for s: int in [-1, 1]:
			r.add_child(cilindro(0.014, 0.016, 0.07, Vector3(x, 0.155, pz + s * 0.125), "corteccia", Vector3.ZERO, 7))
	r.add_child(cilindro(0.036, 0.036, 0.014, Vector3(0.5, 0.17, -0.08), "corda", Vector3.ZERO, 10))
	ramo(r, Vector3(0.5, 0.17, -0.08), Vector3(0.66, 0.02, -0.02), 0.005, "corda")
	ramo(r, Vector3(1.02, 0.17, pz + 0.125), Vector3(1.1, 0.03, pz + 0.2), 0.005, "corda")
	# capanna del porto con la tettoia sul davanti
	_casa_sicana(r, Vector3(-0.28, 0, -0.32), 0.512, 0.372, 0.323, 982)
	_tettoia_sicana(r, Vector3(-0.28, 0, 0.08), 0.62, 0.22, 0.36, 0.3, 383)
	for i in 3:
		r.add_child(_orcio_sic(Vector3(-0.2 + i * 0.1, 0, 0.06), 0.84, i))
	r.add_child(sacco(Vector3(-0.5, 0, 0.06), 0.3))
	r.add_child(scatola(Vector3(0.62, 0.012, 0.5), Vector3(-0.12, 0.006, 0.36), "terra"))
	# fila di giare grandi sulle pietre
	var ra := Vector3(-0.42, 0, 0.4)
	r.add_child(scatola(Vector3(0.32, 0.03, 0.12), ra + Vector3(0, 0.015, -0.06), "pietra_sicana"))
	for k in 3:
		r.add_child(_orcio_sic(ra + Vector3(-0.1 + k * 0.1, 0.03, -0.06), 1.02, k))
	for k in 2:
		r.add_child(_orcio_sic(ra + Vector3(-0.06 + k * 0.12, 0, 0.1), 0.75, k + 1))
	r.add_child(cesta(Vector3(0.06, 0, 0.42), "pesce"))
	r.add_child(sacco(Vector3(0.18, 0, 0.44), -0.4))
	r.add_child(cesta(Vector3(0.28, 0.125, 0.4), "pesce", 0.8))
	# vela d'ocra arrotolata
	r.add_child(cilindro(0.028, 0.028, 0.18, Vector3(-0.05, 0.03, 0.58), "lapislazzuli", Vector3(0, 70, 90), 10))
	for k in 3:
		r.add_child(cilindro(0.03, 0.03, 0.012, Vector3(-0.05 + (k - 1) * 0.06 * cos(deg_to_rad(70.0)), 0.03, 0.58 - (k - 1) * 0.06 * sin(deg_to_rad(70.0))), "lino_bianco", Vector3(0, 70, 90), 10))
	# gru di tronchi con la giara nella rete
	var g := Node3D.new()
	g.position = Vector3(0.42, 0.125, -0.28)
	r.add_child(g)
	var gc := Vector3(0.36, 0.62, 0.0)
	for s: int in [-1, 1]:
		ramo(g, Vector3(-0.04, 0, s * 0.12), gc, 0.016, "corteccia")
	ramo(g, Vector3(-0.22, 0, 0), gc + Vector3(-0.02, -0.02, 0), 0.012, "legno_vecchio")
	g.add_child(cilindro(0.03, 0.03, 0.2, Vector3(0.0, 0.1, 0), "legno_vecchio", Vector3(90, 0, 0), 10))
	g.add_child(cilindro(0.032, 0.032, 0.06, Vector3(0.0, 0.1, 0), "corda", Vector3(90, 0, 0), 10))
	g.add_child(_toro(0.02, 0.035, gc, "corda", Vector3(90, 0, 0)))
	ramo(g, Vector3(0.0, 0.12, 0), gc, 0.004, "corda")
	ramo(g, gc, gc + Vector3(0, -0.3, 0), 0.004, "corda")
	var gr := _orcio_sic(gc + Vector3(0, -0.5, 0), 1.08, 0)
	g.add_child(gr)
	g.add_child(sfera(0.062, gc + Vector3(0, -0.42, 0), "rete", Vector3(1, 1.3, 1)))
	# ancora di pietra forata
	r.add_child(scatola(Vector3(0.1, 0.03, 0.12), Vector3(0.22, 0.14, -0.5), "lastra_sic", Vector3(0, 20, 0)))
	r.add_child(cilindro(0.016, 0.016, 0.032, Vector3(0.22, 0.14, -0.49), "buio", Vector3.ZERO, 8))
	ramo(r, Vector3(0.22, 0.156, -0.49), Vector3(0.36, 0.13, -0.42), 0.004, "corda")
	_insegna_sicana(r, Vector3(0.48, 0.125, 0.42), 0.5)
	return r


## Carbonaia dei Sicani: casetta di pietra col tetto d'erba, cupola di legna coperta di terra che fuma, legna, carbone
## pronto, sacchi, orcio e catasta di pietre.
static func carbonaia_sicani() -> Node3D:
	var r := Node3D.new()
	_casa_sicana(r, Vector3(-0.38, 0, -0.4), 0.4, 0.3, 0.23, 991, 0.0, true)
	var m := Vector3(0.22, 0, 0.2)
	r.add_child(sfera(0.36, m, "terra", Vector3(1, 0.7, 1)))
	r.add_child(sfera(0.3, m + Vector3(0, 0.03, 0), "fuliggine", Vector3(1, 0.7, 1)))
	r.add_child(sfera(0.37, m + Vector3(0, -0.01, 0), "terra", Vector3(1, 0.68, 1)))
	for k in 9:
		var a := k * TAU / 9
		r.add_child(sfera(0.04, m + Vector3(cos(a) * 0.3, 0.12, sin(a) * 0.3), "frasche", Vector3(1.2, 0.5, 1.0)))
	for k in 5:
		r.add_child(sfera(0.05 + k * 0.012, m + Vector3(0.02 * k, 0.28 + k * 0.07, -0.01 * k), "fumo", Vector3(1, 0.8, 1)))
	r.add_child(scatola(Vector3(0.06, 0.04, 0.04), m + Vector3(0.0, 0.12, 0.33), "buio"))
	legnaia(r, Vector3(-0.55, 0, 0.35), 0.35, 4)
	r.add_child(mucchio(Vector3(0.62, 0, -0.25), "carbone", 12, 5))
	r.add_child(sacco(Vector3(0.6, 0, 0.55), 0.4))
	r.add_child(_orcio_sic(Vector3(-0.1, 0, 0.0), 0.96, 1))
	_fascina(r, Vector3(-0.1, 0, 0.62), 70.0)
	_catasta_pietre(r, Vector3(-0.66, 0, 0.0), 0.6, 993)
	return r


## Fonderia dei Sicani: casa di pietra col tetto d'erba, forno a tino di pietre grigie a secco con la bocca accesa e il
## fumo, due mantici di pelle, lingotti, carbone e minerale.
static func fonderia_sicani() -> Node3D:
	var r := Node3D.new()
	_casa_sicana(r, Vector3(-0.25, 0, -0.27), 0.512, 0.388, 0.306, 1001)
	var f := Vector3(0.42, 0, 0.36)
	r.add_child(cilindro(0.22, 0.24, 0.1, f + Vector3(0, 0.05, 0), "pietra_sicana", Vector3.ZERO, 18))
	r.add_child(cilindro(0.13, 0.2, 0.42, f + Vector3(0, 0.31, 0), "pietra_sicana", Vector3.ZERO, 18))
	for k in 30:
		var ak := k * TAU / 10 + (k / 10) * 0.3
		var yk := 0.15 + (k / 10) * 0.12
		var rk := 0.2 - (yk - 0.1) / 0.42 * 0.07 + 0.006
		r.add_child(_sasso_sic(f + Vector3(cos(ak) * rk, yk, sin(ak) * rk), Vector3(0.065, 0.04, 0.022), -rad_to_deg(ak) + 90.0, k))
	r.add_child(cilindro(0.135, 0.14, 0.06, f + Vector3(0, 0.5, 0), "fuliggine", Vector3.ZERO, 18))
	r.add_child(cilindro(0.1, 0.1, 0.004, f + Vector3(0, 0.531, 0), "brace", Vector3.ZERO, 14))
	r.add_child(scatola(Vector3(0.1, 0.09, 0.05), f + Vector3(-0.05, 0.15, 0.2), "brace", Vector3(0, 25, 0)))
	r.add_child(scatola(Vector3(0.13, 0.03, 0.05), f + Vector3(-0.05, 0.21, 0.2), "lastra_sic", Vector3(0, 25, 0)))
	_fumo(r, f + Vector3(0, 0.6, 0), 4, 1.1)
	_mantice_sic(r, f + Vector3(-0.38, 0, 0.0), 0.0)
	_mantice_sic(r, f + Vector3(0.0, 0, -0.36), 90.0)
	for k in 6:
		r.add_child(scatola(Vector3(0.09, 0.025, 0.035), Vector3(-0.45 + (k % 3) * 0.1, 0.013 + (k / 3) * 0.026, 0.55), "lingotto"))
	r.add_child(mucchio(Vector3(-0.64, 0, 0.25), "carbone", 9, 6))
	r.add_child(mucchio(Vector3(0.7, 0, -0.12), "minerale", 9, 7))
	r.add_child(_orcio_sic(Vector3(0.08, 0, 0.62), 0.96, 0))
	return r


## Fabbro dei Sicani: casa grande di pietra col tetto d'erba, fucina di pietra a secco sotto la tettoia di lastre,
## mantice di pelle, incudine sul ceppo, attrezzi appesi alla trave, vasca quadra dell'acqua, lingotti.
static func fabbro_sicani() -> Node3D:
	var r := Node3D.new()
	_casa_sicana(r, Vector3(-0.2, 0, -0.32), 0.558, 0.388, 0.323, 1011)
	_tettoia_sicana(r, Vector3(-0.2, 0, 0.43), 0.66, 0.32, 0.4, 0.32, 412)
	r.add_child(cilindro(0.11, 0.12, 0.12, Vector3(-0.38, 0.06, 0.42), "pietra_sicana", Vector3.ZERO, 14))
	r.add_child(cilindro(0.1, 0.1, 0.012, Vector3(-0.38, 0.126, 0.42), "lastra_sic", Vector3.ZERO, 14))
	r.add_child(cilindro(0.07, 0.07, 0.01, Vector3(-0.38, 0.134, 0.42), "brace", Vector3.ZERO, 12))
	r.add_child(sfera(0.025, Vector3(-0.38, 0.145, 0.42), "brace", Vector3(1.2, 0.6, 1)))
	_mantice_sic(r, Vector3(-0.6, 0, 0.42), 0.0)
	r.add_child(cilindro(0.04, 0.05, 0.08, Vector3(-0.05, 0.04, 0.45), "corteccia", Vector3.ZERO, 10))
	r.add_child(scatola(Vector3(0.12, 0.04, 0.05), Vector3(-0.05, 0.1, 0.45), "ferro"))
	r.add_child(scatola(Vector3(0.04, 0.025, 0.035), Vector3(0.03, 0.1, 0.45), "ferro"))
	r.add_child(cilindro(0.008, 0.008, 0.6, Vector3(-0.2, 0.3, 0.3), "legno_vecchio", Vector3(0, 0, 90), 5))
	for k in 4:
		var a := attrezzo(ATTREZZI_FABBRO[k])
		a.position = Vector3(-0.42 + k * 0.1, 0.22, 0.31)
		a.rotation_degrees = Vector3(90, 0, 90)
		r.add_child(a)
	_vasca_sicana(r, Vector3(0.62, 0, 0.1), 0.07, 0.07)
	for k in 3:
		r.add_child(scatola(Vector3(0.09, 0.025, 0.035), Vector3(0.45, 0.013 + k * 0.026, 0.45), "lingotto"))
	legnaia(r, Vector3(0.62, 0, -0.18), 0.2, 3)
	_fumo(r, Vector3(-0.36, 0.46, 0.44), 3, 0.8)
	return r


## Armaiolo dei Sicani: la bottega del fabbro con la rastrelliera degli archi e le faretre, scudi blu appoggiati,
## lame d'ossidiana sul ceppo e l'elmo di cuoio.
static func armaiolo_sicani() -> Node3D:
	var r := fabbro_sicani()
	_rastrelliera_archi(r, Vector3(0.45, 0, 0.32), 0.0)
	for k in 2:
		var sc := _scudo_sicano(Vector3(0.72 + k * 0.02, 0.085, 0.24 + k * 0.17), 80.0 - k * 10.0, 1.05)
		sc.rotation_degrees.x = -12
		r.add_child(sc)
	r.add_child(cilindro(0.06, 0.065, 0.11, Vector3(0.3, 0.055, 0.6), "corteccia", Vector3.ZERO, 12))
	for k in 3:
		r.add_child(_lama_oss(Vector3(0.27 + k * 0.03, 0.115, 0.58 + k * 0.02), Vector3(0, -60 + k * 25, 0), 0.07, k == 1))
	r.add_child(_blocco_oss(Vector3(0.12, 0, 0.62), 0.9, 3))
	r.add_child(sfera(0.04, Vector3(0.5, 0.03, 0.64), "cuoio", Vector3(1, 0.75, 1.05)))
	r.add_child(cilindro(0.041, 0.042, 0.01, Vector3(0.5, 0.012, 0.64), "pelle_scura", Vector3.ZERO, 12))
	return r


# =================================================================== CONDOTTIERI (step 31)
# Eroi che guidano una schiera, uno per popolo: un po' più grandi dei soldati (scala 1,15), mantello lungo,
# copricapo distintivo e uno stendardo alto fissato alla schiena col colore del giocatore (materiale "giocatore").

## Mantello lungo: drappo sulle spalle, telo dietro che si allarga verso i polpacci, due lembi ai fianchi,
## orlo in basso e fibbia davanti.
static func _mantello(corpo: Node3D, mat: String, fibbia := "moneta", orlo := "") -> void:
	var anca := 0.2
	corpo.add_child(sfera(0.07, Vector3(0, anca + 0.165, -0.016), mat, Vector3(1.25, 0.4, 1.05)))
	# telo in tre pieghe che si allargano verso il basso
	for k in 3:
		var dx := (k - 1) * 0.04
		corpo.add_child(scatola(Vector3(0.05, 0.3, 0.01), Vector3(dx * 1.1, anca + 0.01, -0.094 - (0.006 if k == 1 else 0.0)), mat, Vector3(12, -dx * 500.0, -dx * 120.0)))
	if orlo != "":
		for k in 3:
			var dx := (k - 1) * 0.04
			corpo.add_child(scatola(Vector3(0.052, 0.014, 0.013), Vector3(dx * 1.25, anca - 0.135, -0.126 - (0.006 if k == 1 else 0.0)), orlo, Vector3(12, -dx * 500.0, -dx * 120.0)))
	corpo.add_child(sfera(0.016, Vector3(0, anca + 0.155, 0.064), fibbia))


## Simbolo del popolo dipinto sui due lati del drappo; c = centro del simbolo sul piano del drappo.
static func _simbolo_stendardo(s: Node3D, tipo: String, c: Vector3) -> void:
	for dz: float in [0.0055, -0.0045]:
		var p := c + Vector3(0, 0, dz)
		match tipo:
			"stella":  # stella a otto raggi bianca
				for k in 4:
					s.add_child(scatola(Vector3(0.078, 0.012, 0.003), p, "lino_bianco", Vector3(0, 0, k * 45)))
				s.add_child(cilindro(0.016, 0.016, 0.004, p, "oro_n", Vector3(90, 0, 0), 10))
			"toro":  # testa di toro: muso d'osso e corna
				s.add_child(sfera(0.03, p + Vector3(0, -0.01, 0), "osso", Vector3(0.8, 1.1, 0.12)))
				for lato: int in [-1, 1]:
					s.add_child(scatola(Vector3(0.04, 0.012, 0.003), p + Vector3(lato * 0.026, 0.03, 0), "osso", Vector3(0, 0, lato * 40)))
			"corona":  # corona d'alloro d'oro
				s.add_child(_toro(0.03, 0.04, p, "moneta", Vector3(90, 0, 0), Vector3(1, 0.25, 1)))
				s.add_child(sfera(0.01, p, "moneta", Vector3(1, 1, 0.3)))
			"stella8":  # stella a otto punte: due quadrati d'oro sovrapposti
				for k in 2:
					s.add_child(scatola(Vector3(0.06, 0.06, 0.003), p, "oro_n", Vector3(0, 0, k * 45)))
				s.add_child(cilindro(0.014, 0.014, 0.004, p, "stoffa_smeraldo", Vector3(90, 0, 0), 10))
			"croce":  # croce d'oro
				s.add_child(scatola(Vector3(0.018, 0.11, 0.003), p, "oro_n"))
				s.add_child(scatola(Vector3(0.07, 0.018, 0.003), p + Vector3(0, 0.02, 0), "oro_n"))
			"spirale":  # cerchi dipinti d'ocra e di nero
				s.add_child(cilindro(0.045, 0.045, 0.003, p, "ocra_rossa", Vector3(90, 0, 0), 14))
				s.add_child(cilindro(0.032, 0.032, 0.004, p, "vernice_nera", Vector3(90, 0, 0), 14))
				s.add_child(cilindro(0.02, 0.02, 0.005, p, "ocra_rossa", Vector3(90, 0, 0), 12))
				s.add_child(cilindro(0.008, 0.008, 0.006, p, "ceramica", Vector3(90, 0, 0), 8))
			"monte":  # monte bianco a gradoni
				for k in 3:
					s.add_child(scatola(Vector3(0.084 - k * 0.026, 0.024, 0.003), p + Vector3(0, -0.03 + k * 0.024, 0), "lino_bianco"))


## Puntale in cima all'asta dello stendardo.
static func _puntale(s: Node3D, tipo: String, cima: float) -> void:
	var p := Vector3(0, cima, 0)
	match tipo:
		"lancia":
			s.add_child(cilindro(0.016, 0.0, 0.07, p + Vector3(0, 0.035, 0), "bronzo", Vector3.ZERO, 6))
			s.add_child(cilindro(0.012, 0.012, 0.015, p, "bronzo", Vector3.ZERO, 6))
		"corna":
			s.add_child(sfera(0.018, p + Vector3(0, 0.012, 0), "osso"))
			for lato: int in [-1, 1]:
				s.add_child(cilindro(0.01, 0.0, 0.07, p + Vector3(lato * 0.03, 0.035, 0), "osso", Vector3(0, 0, -lato * 40), 6))
		"aquila":
			s.add_child(sfera(0.018, p + Vector3(0, 0.01, 0), "moneta"))
			s.add_child(sfera(0.02, p + Vector3(0, 0.04, 0), "moneta", Vector3(0.8, 1.2, 0.8)))
			for lato: int in [-1, 1]:
				s.add_child(scatola(Vector3(0.05, 0.03, 0.008), p + Vector3(lato * 0.03, 0.055, 0), "moneta", Vector3(0, 0, lato * 30)))
		"pomo":
			s.add_child(sfera(0.022, p + Vector3(0, 0.02, 0), "oro_n"))
			s.add_child(cilindro(0.006, 0.0, 0.04, p + Vector3(0, 0.06, 0), "oro_n", Vector3.ZERO, 5))
		"croce_ferro":
			s.add_child(scatola(Vector3(0.012, 0.07, 0.012), p + Vector3(0, 0.035, 0), "ferro"))
			s.add_child(scatola(Vector3(0.05, 0.012, 0.012), p + Vector3(0, 0.045, 0), "ferro"))
		"piume":
			for k in 3:
				var m: String = ["ocra_rossa", "lino_bianco", "vernice_nera"][k]
				s.add_child(sfera(0.016, p + Vector3(-0.02 + k * 0.02, 0.035 + (1 - absi(k - 1)) * 0.012, 0), m, Vector3(0.55, 2.2, 0.8)))
		"montone":
			s.add_child(cilindro(0.01, 0.0, 0.06, p + Vector3(0, 0.035, 0), "ossidiana", Vector3.ZERO, 5))
			for lato: int in [-1, 1]:
				s.add_child(_toro(0.008, 0.02, p + Vector3(lato * 0.022, 0.012, 0), "osso", Vector3(0, 0, 90), Vector3(1, 1, 1)))


## Stendardo alto fissato alla schiena: asta, traversa, drappo col colore del giocatore a coda di rondine,
## orlo e simbolo del popolo, puntale. Il drappo è girato di 25 gradi perché non si veda mai di taglio.
static func _stendardo(corpo: Node3D, simbolo: String, orlo: String, puntale: String, x := -0.035) -> void:
	var anca := 0.2
	var s := Node3D.new()
	s.name = "stendardo"
	s.position = Vector3(x, 0, -0.118)
	s.rotation_degrees.y = 25
	corpo.add_child(s)
	var cima := 0.86
	var base := 0.12
	s.add_child(cilindro(0.008, 0.008, cima - base, Vector3(0, (cima + base) * 0.5, 0), "legno_scuro", Vector3.ZERO, 6))
	s.add_child(scatola(Vector3(0.17, 0.012, 0.012), Vector3(0, cima - 0.05, 0), "legno_scuro"))
	for lato: int in [-1, 1]:
		s.add_child(sfera(0.011, Vector3(lato * 0.087, cima - 0.05, 0), orlo))
	# drappo piegato a U (pannello centrale col simbolo, due lembi che girano indietro), con l'orlo in alto e in basso
	var cz := 0.004
	s.add_child(scatola(Vector3(0.09, 0.16, 0.007), Vector3(0, cima - 0.135, cz), "giocatore"))
	for y: float in [cima - 0.06, cima - 0.21]:
		s.add_child(scatola(Vector3(0.092, 0.012, 0.009), Vector3(0, y, cz), orlo))
	for lato: int in [-1, 1]:
		var a := deg_to_rad(40.0)
		var c := Vector3(lato * (0.045 + 0.02 * cos(a)), 0, cz - 0.02 * sin(a))
		var rot := Vector3(0, lato * 40.0, 0)
		s.add_child(scatola(Vector3(0.042, 0.16, 0.007), c + Vector3(0, cima - 0.135, 0), "giocatore", rot))
		for y: float in [cima - 0.06, cima - 0.21]:
			s.add_child(scatola(Vector3(0.042, 0.012, 0.009), c + Vector3(0, y, 0), orlo, rot))
		# coda di rondine sotto il pannello centrale
		s.add_child(scatola(Vector3(0.04, 0.065, 0.007), Vector3(lato * 0.024, cima - 0.24, cz), "giocatore", Vector3(0, 0, lato * 14)))
	_simbolo_stendardo(s, simbolo, Vector3(0, cima - 0.135, 0.004))
	_puntale(s, puntale, cima)
	# cinghie di cuoio che tengono l'asta alla schiena
	corpo.add_child(cilindro(0.067, 0.065, 0.014, Vector3(0, anca + 0.15, 0), "cuoio", Vector3.ZERO, 12))
	corpo.add_child(scatola(Vector3(0.02, 0.22, 0.006), Vector3(0.0, anca + 0.1, 0.074), "cuoio", Vector3(0, 0, -34)))


## Condottiero di un popolo (greci, brettii, romani, saraceni, normanni, siculi, sicani).
static func condottiero(popolo: String) -> Node3D:
	var anca := 0.2
	var r: Node3D
	match popolo:
		"greci":
			# Eudora: chitone chiaro fino ai piedi, mantello blu scuro, diadema, scudo con la stella, lancia
			r = portatore("", "giocatore", "lino_bianco")
			var corpo: Node3D = r.get_node("corpo")
			corpo.add_child(cilindro(0.078, 0.086, 0.15, Vector3(0, anca - 0.075, 0), "lino_bianco", Vector3.ZERO, 12))
			corpo.add_child(cilindro(0.087, 0.087, 0.012, Vector3(0, anca - 0.145, 0), "mantello_blu", Vector3.ZERO, 12))
			# capelli lunghi raccolti dietro, diadema d'oro
			corpo.add_child(sfera(0.05, Vector3(0, anca + 0.22, -0.055), "capelli", Vector3(1.1, 1.5, 0.7)))
			corpo.add_child(sfera(0.032, Vector3(0, anca + 0.3, -0.075), "capelli"))
			corpo.add_child(_toro(0.072, 0.083, Vector3(0, anca + 0.286, -0.008), "oro_n", Vector3(-8, 0, 0), Vector3(1, 1.6, 1)))
			corpo.add_child(sfera(0.013, Vector3(0, anca + 0.3, 0.074), "lapislazzuli"))
			_mantello(corpo, "mantello_blu", "oro_n", "oro_n")
			_stendardo(corpo, "stella", "oro_n", "lancia")
			var bs: Node3D = corpo.get_node("braccio_s")
			bs.add_child(cilindro(0.09, 0.09, 0.014, Vector3(-0.02, -0.07, 0.04), "bronzo", Vector3(0, 0, 90), 16))
			bs.add_child(cilindro(0.072, 0.072, 0.004, Vector3(-0.028, -0.07, 0.04), "mantello_blu", Vector3(0, 0, 90), 16))
			for k in 4:
				bs.add_child(scatola(Vector3(0.004, 0.11, 0.012), Vector3(-0.031, -0.07, 0.04), "lino_bianco", Vector3(k * 45, 0, 0)))
			bs.add_child(sfera(0.014, Vector3(-0.032, -0.07, 0.04), "oro_n"))
			var bd: Node3D = corpo.get_node("braccio_d")
			bd.add_child(cilindro(0.007, 0.007, 0.56, Vector3(0, 0.08, 0.02), "legno", Vector3.ZERO, 5))
			bd.add_child(cilindro(0.017, 0.0, 0.065, Vector3(0, 0.39, 0.02), "bronzo", Vector3.ZERO, 6))
			r.set_meta("carico", "lancia")
		"brettii":
			# Tauro: pelliccia, berretto di pelo, mantello verde bosco, ascia e scudo ovale di legno
			r = portatore("", "giocatore", "pelliccia")
			var corpo: Node3D = r.get_node("corpo")
			corpo.add_child(sfera(0.086, Vector3(0, anca + 0.29, -0.01), "pelliccia", Vector3(1.05, 0.68, 1.05)))
			corpo.add_child(_toro(0.07, 0.09, Vector3(0, anca + 0.27, -0.01), "pelliccia", Vector3.ZERO, Vector3(1, 1.8, 1)))
			corpo.add_child(sfera(0.012, Vector3(0, anca + 0.345, -0.02), "osso", Vector3(1, 2.2, 1)))
			corpo.add_child(sfera(0.045, Vector3(0, anca + 0.215, 0.05), "capelli", Vector3(1.0, 0.9, 0.6)))
			_mantello(corpo, "stoffa_verde", "bronzo", "pelliccia")
			corpo.add_child(sfera(0.08, Vector3(0, anca + 0.17, -0.01), "pelliccia", Vector3(1.25, 0.35, 1.15)))
			_stendardo(corpo, "toro", "stoffa_verde", "corna")
			var bs: Node3D = corpo.get_node("braccio_s")
			bs.add_child(sfera(0.1, Vector3(-0.025, -0.07, 0.03), "legno", Vector3(0.2, 1.25, 0.85)))
			bs.add_child(sfera(0.085, Vector3(-0.032, -0.07, 0.03), "stoffa_verde", Vector3(0.12, 0.6, 0.12)))
			bs.add_child(sfera(0.026, Vector3(-0.045, -0.07, 0.03), "ferro"))
			var bd: Node3D = corpo.get_node("braccio_d")
			bd.add_child(scatola(Vector3(0.014, 0.014, 0.25), Vector3(0, -0.14, 0.08), "legno"))
			bd.add_child(scatola(Vector3(0.009, 0.08, 0.05), Vector3(0, -0.125, 0.19), "ferro"))
			bd.add_child(scatola(Vector3(0.011, 0.02, 0.03), Vector3(0, -0.14, 0.2), "legno_scuro"))
			r.set_meta("carico", "spada")
		"romani":
			# Gaio Settimio: agrimensore in armatura leggera di cuoio, mantello rosso pompeiano,
			# elmo con la cresta trasversale, gladio e la groma in spalla
			r = portatore("", "giocatore", "lino_bianco")
			var corpo: Node3D = r.get_node("corpo")
			for k in 3:
				var y := anca + 0.115 + k * 0.022
				var rr := 0.085 - (y - (anca - 0.03)) / 0.2 * 0.025 + 0.007
				corpo.add_child(cilindro(rr, rr - 0.002, 0.019, Vector3(0, y, 0), "cuoio" if k % 2 == 0 else "pelle_scura", Vector3.ZERO, 12))
			for lato: int in [-1, 1]:
				corpo.add_child(sfera(0.034, Vector3(lato * 0.058, anca + 0.17, 0), "cuoio", Vector3(1.15, 0.55, 1.1)))
			corpo.add_child(cilindro(0.083, 0.083, 0.018, Vector3(0, anca + 0.075, 0), "pelle_scura", Vector3.ZERO, 12))
			for k in 5:
				corpo.add_child(scatola(Vector3(0.014, 0.05, 0.006), Vector3(-0.036 + k * 0.018, anca + 0.04, 0.085), "cuoio"))
			# elmo di bronzo con la cresta rossa trasversale (da un orecchio all'altro)
			corpo.add_child(sfera(0.08, Vector3(0, anca + 0.282, -0.005), "bronzo", Vector3(1, 0.72, 1.05)))
			corpo.add_child(scatola(Vector3(0.13, 0.012, 0.06), Vector3(0, anca + 0.245, -0.08), "bronzo", Vector3(-22, 0, 0)))
			for lato: int in [-1, 1]:
				corpo.add_child(scatola(Vector3(0.01, 0.055, 0.04), Vector3(lato * 0.077, anca + 0.235, 0.025), "bronzo"))
			for k in 7:
				var x := -0.075 + k * 0.025
				corpo.add_child(sfera(0.024, Vector3(x, anca + 0.37 - absf(x) * 0.45, -0.005), "stoffa_pompeiana", Vector3(0.9, 1.2, 0.55)))
			_mantello(corpo, "rosso_pompeiano", "moneta", "moneta")
			_stendardo(corpo, "corona", "moneta", "aquila", 0.04)
			# groma: asta sulla spalla sinistra, croce in cima con quattro fili a piombo
			var g := Node3D.new()
			g.position = Vector3(-0.09, anca + 0.17, 0.035)
			g.rotation_degrees = Vector3(-24, 0, 12)
			corpo.add_child(g)
			g.add_child(cilindro(0.007, 0.007, 0.55, Vector3(0, 0.12, 0), "legno", Vector3.ZERO, 5))
			g.add_child(cilindro(0.009, 0.0, 0.03, Vector3(0, -0.17, 0), "ferro", Vector3(180, 0, 0), 5))
			var cr := Node3D.new()
			cr.position = Vector3(0, 0.39, 0)
			cr.rotation_degrees = Vector3(24, 0, -12)
			g.add_child(cr)
			cr.add_child(scatola(Vector3(0.17, 0.01, 0.01), Vector3.ZERO, "legno_scuro", Vector3(0, 45, 0)))
			cr.add_child(scatola(Vector3(0.17, 0.01, 0.01), Vector3.ZERO, "legno_scuro", Vector3(0, -45, 0)))
			for k in 4:
				var a := k * PI * 0.5 + PI * 0.25
				var e := Vector3(cos(a) * 0.08, 0, sin(a) * 0.08)
				cr.add_child(cilindro(0.0015, 0.0015, 0.08, e + Vector3(0, -0.04, 0), "corda", Vector3.ZERO, 3))
				cr.add_child(cilindro(0.008, 0.0, 0.02, e + Vector3(0, -0.088, 0), "bronzo", Vector3(180, 0, 0), 6))
			# gladio nella destra
			var bd: Node3D = corpo.get_node("braccio_d")
			bd.add_child(scatola(Vector3(0.01, 0.018, 0.15), Vector3(0, -0.14, 0.09), "spada"))
			bd.add_child(cilindro(0.009, 0.0, 0.025, Vector3(0, -0.14, 0.177), "spada", Vector3(90, 0, 0), 4))
			bd.add_child(scatola(Vector3(0.036, 0.016, 0.014), Vector3(0, -0.14, 0.012), "bronzo"))
			bd.add_child(scatola(Vector3(0.012, 0.014, 0.03), Vector3(0, -0.14, -0.01), "legno_scuro"))
			bd.add_child(sfera(0.011, Vector3(0, -0.14, -0.028), "moneta"))
			r.set_meta("carico", "spada")
		"saraceni":
			# Zahra: veste e turbante bianchi, fascia e mantello verde smeraldo, scimitarra e piccolo scudo tondo
			r = portatore("", "giocatore", "lino_bianco")
			var corpo: Node3D = r.get_node("corpo")
			corpo.add_child(cilindro(0.078, 0.088, 0.15, Vector3(0, anca - 0.075, 0), "lino_bianco", Vector3.ZERO, 12))
			corpo.add_child(cilindro(0.088, 0.088, 0.03, Vector3(0, anca + 0.06, 0), "stoffa_smeraldo", Vector3.ZERO, 12))
			corpo.add_child(scatola(Vector3(0.02, 0.07, 0.006), Vector3(0.03, anca + 0.02, 0.085), "stoffa_smeraldo", Vector3(0, 0, 8)))
			corpo.add_child(sfera(0.09, Vector3(0, anca + 0.3, -0.008), "lino_bianco", Vector3(1.05, 0.78, 1.05)))
			corpo.add_child(_toro(0.068, 0.095, Vector3(0, anca + 0.282, -0.008), "lino_bianco", Vector3(-6, 0, 0), Vector3(1, 0.9, 1)))
			corpo.add_child(sfera(0.015, Vector3(0, anca + 0.29, 0.09), "smeraldo"))
			corpo.add_child(sfera(0.009, Vector3(0, anca + 0.31, 0.088), "oro_n"))
			_mantello(corpo, "stoffa_smeraldo", "oro_n", "oro_n")
			_stendardo(corpo, "stella8", "oro_n", "pomo")
			var bs: Node3D = corpo.get_node("braccio_s")
			bs.add_child(cilindro(0.058, 0.058, 0.012, Vector3(-0.02, -0.085, 0.04), "maiolica_verde", Vector3(0, 0, 90), 14))
			bs.add_child(_toro(0.052, 0.06, Vector3(-0.022, -0.085, 0.04), "oro_n", Vector3(0, 0, 90)))
			bs.add_child(sfera(0.017, Vector3(-0.03, -0.085, 0.04), "oro_n"))
			var bd: Node3D = corpo.get_node("braccio_d")
			bd.add_child(scatola(Vector3(0.012, 0.014, 0.04), Vector3(0, -0.14, -0.002), "legno_scuro"))
			bd.add_child(scatola(Vector3(0.012, 0.045, 0.012), Vector3(0, -0.14, 0.022), "oro_n"))
			for k in 5:
				var z := 0.045 + k * 0.034
				bd.add_child(scatola(Vector3(0.008, 0.022 - k * 0.002, 0.038), Vector3(0, -0.14 + k * k * 0.0045, z), "spada", Vector3(-k * 9, 0, 0)))
			r.set_meta("carico", "spada")
		"normanni":
			# Osmund: cavaliere a piedi in cotta di maglia, elmo a nasale, mantello giallo oro, scudo a mandorla, spada
			r = portatore("", "giocatore", "maglia")
			var corpo: Node3D = r.get_node("corpo")
			corpo.add_child(cilindro(0.082, 0.094, 0.1, Vector3(0, anca - 0.045, 0), "maglia", Vector3.ZERO, 12))
			corpo.add_child(cilindro(0.086, 0.086, 0.02, Vector3(0, anca + 0.07, 0), "pelle_scura", Vector3.ZERO, 12))
			corpo.add_child(sfera(0.011, Vector3(0, anca + 0.07, 0.086), "oro_n"))
			corpo.add_child(sfera(0.079, Vector3(0, anca + 0.235, -0.005), "maglia", Vector3(1.05, 1.0, 1.05)))
			corpo.add_child(sfera(0.071, Vector3(0, anca + 0.25, 0.012), "pelle"))
			corpo.add_child(cilindro(0.082, 0.082, 0.04, Vector3(0, anca + 0.28, -0.005), "ferro", Vector3.ZERO, 12))
			corpo.add_child(cilindro(0.082, 0.0, 0.1, Vector3(0, anca + 0.35, -0.005), "ferro", Vector3.ZERO, 12))
			corpo.add_child(cilindro(0.084, 0.084, 0.012, Vector3(0, anca + 0.268, -0.005), "oro_n", Vector3.ZERO, 12))
			corpo.add_child(scatola(Vector3(0.014, 0.055, 0.012), Vector3(0, anca + 0.245, 0.08), "ferro"))
			_mantello(corpo, "stoffa_oro", "ferro", "pelle_scura")
			_stendardo(corpo, "croce", "oro_n", "croce_ferro")
			var bs: Node3D = corpo.get_node("braccio_s")
			bs.add_child(_scudo_n(Vector3(-0.03, -0.09, 0.035), -90.0, 1.2))
			var bd: Node3D = corpo.get_node("braccio_d")
			bd.add_child(scatola(Vector3(0.01, 0.02, 0.22), Vector3(0, -0.14, 0.13), "spada"))
			bd.add_child(cilindro(0.01, 0.0, 0.025, Vector3(0, -0.14, 0.252), "spada", Vector3(90, 0, 0), 4))
			bd.add_child(scatola(Vector3(0.065, 0.012, 0.012), Vector3(0, -0.14, 0.018), "ferro"))
			bd.add_child(scatola(Vector3(0.012, 0.014, 0.035), Vector3(0, -0.14, -0.005), "pelle_scura"))
			bd.add_child(sfera(0.012, Vector3(0, -0.14, -0.026), "oro_n"))
			r.set_meta("carico", "spada")
		"siculi":
			# Duketio: tunica ocra, mantello rosso-ocra, elmo di cuoio con le piume, lancia lunga, scudo dipinto
			r = portatore("", "giocatore", "tunica_ocra")
			var corpo: Node3D = r.get_node("corpo")
			corpo.add_child(cilindro(0.083, 0.083, 0.018, Vector3(0, anca + 0.04, 0), "cuoio", Vector3.ZERO, 12))
			corpo.add_child(sfera(0.011, Vector3(0, anca + 0.04, 0.083), "bronzo"))
			corpo.add_child(sfera(0.081, Vector3(0, anca + 0.282, -0.006), "cuoio", Vector3(1, 0.72, 1.05)))
			corpo.add_child(cilindro(0.083, 0.084, 0.014, Vector3(0, anca + 0.262, -0.006), "bronzo", Vector3.ZERO, 14))
			corpo.add_child(scatola(Vector3(0.12, 0.012, 0.05), Vector3(0, anca + 0.248, -0.078), "cuoio", Vector3(-25, 0, 0)))
			for lato: int in [-1, 1]:
				corpo.add_child(scatola(Vector3(0.01, 0.045, 0.035), Vector3(lato * 0.078, anca + 0.24, 0.02), "cuoio"))
			# ventaglio di piume alte sull'elmo
			corpo.add_child(cilindro(0.014, 0.016, 0.022, Vector3(0, anca + 0.345, -0.005), "bronzo", Vector3.ZERO, 6))
			for k in 5:
				var m: String = ["ocra_rossa", "lino_bianco", "vernice_nera", "lino_bianco", "ocra_rossa"][k]
				corpo.add_child(sfera(0.018, Vector3(-0.036 + k * 0.018, anca + 0.385 + (2 - absi(k - 2)) * 0.014, -0.01), m, Vector3(0.55, 2.2, 0.8)))
			_mantello(corpo, "ocra_rossa", "bronzo", "vernice_nera")
			_stendardo(corpo, "spirale", "ocra_rossa", "piume")
			var bs: Node3D = corpo.get_node("braccio_s")
			bs.add_child(_scudo_sic(Vector3(-0.03, -0.075, 0.04), -90.0, 1.12))
			var bd: Node3D = corpo.get_node("braccio_d")
			bd.add_child(cilindro(0.0075, 0.0075, 0.64, Vector3(0, 0.1, 0.02), "legno", Vector3.ZERO, 5))
			bd.add_child(cilindro(0.018, 0.0, 0.07, Vector3(0, 0.455, 0.02), "bronzo", Vector3.ZERO, 6))
			bd.add_child(cilindro(0.01, 0.01, 0.02, Vector3(0, 0.41, 0.02), "ocra_rossa", Vector3.ZERO, 6))
			r.set_meta("carico", "lancia")
		"sicani":
			# Kokalo: tunica blu lapislazzuli, mantello di pelle, corona di bronzo, arco e pugnale d'ossidiana
			r = portatore("", "giocatore", "tunica_lapis")
			var corpo: Node3D = r.get_node("corpo")
			corpo.add_child(cilindro(0.08, 0.092, 0.11, Vector3(0, anca - 0.055, 0), "tunica_lapis", Vector3.ZERO, 12))
			corpo.add_child(cilindro(0.083, 0.083, 0.018, Vector3(0, anca + 0.06, 0), "cuoio", Vector3.ZERO, 12))
			corpo.add_child(sfera(0.011, Vector3(0, anca + 0.06, 0.083), "oro_n"))
			# barba e corona di bronzo a punte
			corpo.add_child(sfera(0.048, Vector3(0, anca + 0.21, 0.048), "capelli", Vector3(1.0, 1.0, 0.6)))
			corpo.add_child(_toro(0.072, 0.084, Vector3(0, anca + 0.29, -0.008), "bronzo", Vector3.ZERO, Vector3(1, 2.2, 1)))
			for k in 7:
				var a := k * TAU / 7 + PI * 0.5
				corpo.add_child(cilindro(0.012, 0.0, 0.04, Vector3(cos(a) * 0.078, anca + 0.32, sin(a) * 0.078 - 0.008), "bronzo", Vector3.ZERO, 5))
			corpo.add_child(sfera(0.012, Vector3(0, anca + 0.295, 0.083), "lapislazzuli"))
			_mantello(corpo, "cuoio", "oro_n", "pelliccia")
			corpo.add_child(sfera(0.08, Vector3(0, anca + 0.17, -0.012), "pelliccia", Vector3(1.25, 0.35, 1.15)))
			_stendardo(corpo, "monte", "lino_bianco", "montone")
			var bs: Node3D = corpo.get_node("braccio_s")
			bs.add_child(cilindro(0.02, 0.018, 0.045, Vector3(0, -0.1, 0), "cuoio", Vector3.ZERO, 6))
			_arco_sic(bs, Vector3(-0.005, -0.14, 0.02), 0.26, 0.055)
			var bd: Node3D = corpo.get_node("braccio_d")
			bd.add_child(scatola(Vector3(0.012, 0.014, 0.035), Vector3(0, -0.14, 0.0), "cuoio"))
			bd.add_child(scatola(Vector3(0.03, 0.01, 0.01), Vector3(0, -0.14, 0.02), "oro_n"))
			bd.add_child(cilindro(0.014, 0.0, 0.08, Vector3(0, -0.14, 0.064), "ossidiana", Vector3(90, 0, 0), 5))
	r.scale = Vector3.ONE * 1.15
	return r
