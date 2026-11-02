class_name VillaggiIndigeni
extends Node
## I villaggi indigeni (step 30, Fase 7 — idee da Imperivm, vedi docs/piano-imperivm.md): piccoli villaggi
## neutrali sulla mappa che crescono da soli. Si possono unire con i doni (diventano alleati e mandano metà
## di quello che producono) o, fuori dalla modalità pace, conquistare con i soldati di riserva (mandano
## tutto e allargano i confini). Solo nella partita libera.

signal cambiato

const PERIODO := 60.0                # secondi tra un invio di merci e l'altro
const CRESCITA := 90.0               # secondi per un abitante in più
const ABITANTI_MAX := 60
const RAGGIO_CONFINI := 5.0
const RAGGIO_CONQUISTA := 18.0       # quanto vicino deve essere un nostro forte presidiato

## che cosa sono, come si vedono (sprite degli edifici esistenti) e che cosa producono
const TIPI := {
	"pastori": {"nome": "pastori", "sprite": ["casa_greca_brettii", "ovile_brettii", "capraio_brettii"], "merci": ["formaggio", "lana"]},
	"pescatori": {"nome": "pescatori", "sprite": ["casa_greca_siculi", "pescatore_siculi", "casa_greca_siculi"], "merci": ["pesce"]},
	"citta_greca": {"nome": "città greca", "sprite": ["casa_greca", "frantoio", "casa_greca"], "merci": ["olio", "grano"]},
	"borgo_siculo": {"nome": "borgo siculo", "sprite": ["casa_greca_siculi", "vasaio", "casa_greca_siculi"], "merci": ["grano", "ceramiche"]},
}
## per ogni mappa: [nome, tipo, luogo (della mappa) o direzione dal villaggio del giocatore]
const SU_MAPPA := {
	"costa_ionica": [["Pastori della montagna", "pastori", Vector2(-1, -0.2)], ["Pescatori della riva", "pescatori", Vector2(1, 0.2)],
		["Siris", "citta_greca", Vector2(0.2, 1)]],
	"monteleone": [["Tropea", "citta_greca", "Tropea"], ["Pizzo", "pescatori", "Pizzo"], ["Pastori delle Serre", "pastori", "Serre"]],
	"zancle": [["Milazzo", "pescatori", "Milazzo"], ["Taormina", "citta_greca", "Taormina"], ["Aci", "borgo_siculo", "Acireale"]],
	"bruzio": [["Petelia", "pastori", "Petelia"], ["Scolacium", "citta_greca", "Scolacium"], ["Consentia", "pastori", "Consentia"]],
}
const STATI := {"neutrale": "neutrale", "alleato": "alleato", "nostro": "conquistato"}

var villaggio: Villaggio
var risorse: RisorseNaturali
var dati: DatiMappa
var oggetti: Node2D
var attivi := false
var elenco: Array = []               # [{nome, tipo, casella, abitanti, stato, doni, crescita, attesa}]
var _nodi := []                      # per ogni villaggio: [sprite..., etichetta]


func prepara(v: Villaggio, d: DatiMappa, nodo_oggetti: Node2D, ris: RisorseNaturali) -> void:
	villaggio = v
	risorse = ris
	dati = d
	oggetti = nodo_oggetti
	attivi = Impostazioni.villaggi_indigeni and (Impostazioni.missione == ""
		or Missione.MISSIONI.get(Impostazioni.missione, {}).get("indigeni", false))


## Partita nuova: i villaggi nascono vicino ai loro luoghi (o nelle loro direzioni), dove c'è spazio.
func genera(mappa: String) -> void:
	if not attivi:
		return
	for voce in SU_MAPPA.get(mappa, []):
		var verso = voce[2]
		var dove := Vector2i(-1, -1)
		if verso is String and dati.luoghi.has(verso):
			dove = _posto_vicino(dati.luoghi[verso])
		elif verso is Vector2:
			dove = _posto_vicino(dati.villaggio + Vector2i((verso as Vector2).normalized() * 26.0))
		if dove.x >= 0:
			_aggiungi({"nome": voce[0], "tipo": voce[1], "casella": dove, "abitanti": 20, "stato": "neutrale",
				"doni": 0, "crescita": 0.0, "attesa": PERIODO})
	cambiato.emit()


func _aggiungi(v: Dictionary) -> void:
	elenco.append(v)
	var c: Vector2i = v["casella"]
	var nodi := []
	var posti := [Vector2i(0, 0), Vector2i(3, 0), Vector2i(0, 3)]
	for y in range(c.y, c.y + 5):
		for x in range(c.x, c.x + 5):
			if dati.dentro(x, y) and dati.occupante(x, y) == DatiMappa.NATURA:
				risorse.sgombra(Vector2i(x, y))
			villaggio.togli_decori.emit(Vector2i(x, y))
	for k in 3:
		var p: Vector2i = c + posti[k]
		var s := Sprites.crea(TIPI[v["tipo"]]["sprite"][k])
		s.position = dati.a_schermo(p.x + 1.0, p.y + 1.0)
		oggetti.add_child(s)
		nodi.append(s)
	for y in range(c.y, c.y + 5):
		for x in range(c.x, c.x + 5):
			if dati.dentro(x, y) and dati.occupante(x, y) == 0:
				dati.occupa(x, y, DatiMappa.NATURA)
	var l := Label.new()
	l.add_theme_font_size_override("font_size", 22)
	l.add_theme_color_override("font_outline_color", Color(Palette.INCHIOSTRO, 0.7))
	l.add_theme_constant_override("outline_size", 6)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.z_index = 45
	oggetti.get_parent().add_child(l)
	nodi.append(l)
	_nodi.append(nodi)
	_aggiorna_etichetta(elenco.size() - 1)
	if v["stato"] == "nostro":
		_aggiorna_confini()


func _aggiorna_etichetta(i: int) -> void:
	var v: Dictionary = elenco[i]
	var l: Label = _nodi[i][-1]
	l.text = "%s · %d abitanti · %s" % [v["nome"], v["abitanti"], STATI[v["stato"]]]
	var col := {"neutrale": Palette.PERGAMENA_CHIARA, "alleato": Color("bfe39a"), "nostro": Color("9fd0ff")}
	l.add_theme_color_override("font_color", col[v["stato"]])
	l.reset_size()
	var c: Vector2i = v["casella"]
	l.position = dati.a_schermo(c.x + 2.5, c.y + 2.5) - Vector2(l.get_combined_minimum_size().x * 0.5, 110)


func _posto_vicino(centro: Vector2i) -> Vector2i:
	for r in 10:
		for y in range(centro.y - r, centro.y + r + 1):
			for x in range(centro.x - r, centro.x + r + 1):
				if _libero(Vector2i(x, y)):
					return Vector2i(x, y)
	return Vector2i(-1, -1)


func _libero(c: Vector2i) -> bool:
	if Vector2(c - dati.villaggio).length() < 12.0:
		return false
	for y in range(c.y, c.y + 5):
		for x in range(c.x, c.x + 5):
			if not dati.dentro(x, y) or dati.tipo(x, y) in [DatiMappa.Terreno.ACQUA, DatiMappa.Terreno.NEVE, DatiMappa.Terreno.ROCCIA]:
				return false
			if dati.proprietario(x, y) != 0 or dati.occupante(x, y) > DatiMappa.NATURA or risorse.campi.has(Vector2i(x, y)):
				return false
	return true


func villaggio_in(c: Vector2i) -> int:
	for i in elenco.size():
		var o: Vector2i = elenco[i]["casella"]
		if c.x >= o.x and c.y >= o.y and c.x < o.x + 5 and c.y < o.y + 5:
			return i
	return -1


func _process(delta: float) -> void:
	if not attivi:
		return
	for i in elenco.size():
		var v: Dictionary = elenco[i]
		v["crescita"] += delta
		if v["crescita"] >= CRESCITA and v["abitanti"] < ABITANTI_MAX:
			v["crescita"] = 0.0
			v["abitanti"] += 1
			_aggiorna_etichetta(i)
		if v["stato"] == "neutrale":
			continue
		v["attesa"] -= delta
		if v["attesa"] <= 0.0:
			v["attesa"] = PERIODO
			_manda_merci(v)


## Ogni periodo un villaggio alleato manda metà del raccolto, uno conquistato tutto.
func _manda_merci(v: Dictionary) -> void:
	var quanto: int = maxi(1, v["abitanti"] / 20)
	if v["stato"] == "alleato":
		quanto = maxi(1, quanto / 2)
	for m in TIPI[v["tipo"]]["merci"]:
		villaggio.scorte[m] = villaggio.scorte.get(m, 0) + quanto
	villaggio.scorte_cambiate.emit()


## Quante merci di lusso servono per farsi amico un villaggio.
func doni_necessari(i: int) -> int:
	return 6 + elenco[i]["abitanti"] / 10


static func merci_dono() -> Array:
	return CatalogoEdifici.LUSSO + ["olio", "cavalli"]


## Porta i doni che ci sono in magazzino; quando bastano, il villaggio diventa alleato.
func dona(i: int) -> int:
	var v: Dictionary = elenco[i]
	if v["stato"] != "neutrale":
		return 0
	var dati_ora := 0
	for m in merci_dono():
		while villaggio.scorte.get(m, 0) > 0 and v["doni"] < doni_necessari(i):
			villaggio.scorte[m] -= 1
			v["doni"] += 1
			dati_ora += 1
	if dati_ora > 0:
		villaggio.scorte_cambiate.emit()
	if v["doni"] >= doni_necessari(i):
		v["stato"] = "alleato"
		villaggio.messaggio.emit("%s è ora nostro alleato: manderà parte del suo raccolto" % v["nome"], false)
		Suono.suona("completato")
	_aggiorna_etichetta(i)
	cambiato.emit()
	return dati_ora


func difensori(i: int) -> int:
	return 2 + elenco[i]["abitanti"] / 15


## Si può attaccare: non in pace, con soldati di riserva e un nostro forte presidiato abbastanza vicino.
func motivo_no_conquista(i: int) -> String:
	if Impostazioni.modalita == "pace":
		return "Nella partita in pace i villaggi si uniscono solo con i doni"
	if elenco[i]["stato"] == "nostro":
		return "È già nostro"
	if villaggio.soldati <= 0:
		return "Servono soldati di riserva (dalla caserma)"
	var centro := Vector2(elenco[i]["casella"]) + Vector2(2.5, 2.5)
	for e in villaggio.edifici.values():
		if CatalogoEdifici.dati(e.tipo).has("presidio") and e.presidiata and e.centro().distance_to(centro) <= RAGGIO_CONQUISTA:
			return ""
	return "Serve un nostro forte presidiato a meno di %d caselle" % int(RAGGIO_CONQUISTA)


## I soldati di riserva attaccano: un duello dopo l'altro contro i difensori. Vero se il villaggio è preso.
func conquista(i: int, rng := RandomNumberGenerator.new()) -> bool:
	if motivo_no_conquista(i) != "":
		return false
	var dif := difensori(i)
	var vittoria: float = 0.5 + villaggio.vantaggi.get("duelli", 0.0)
	while dif > 0 and villaggio.soldati > 0:
		if rng.randf() < vittoria:
			dif -= 1
		else:
			villaggio.soldati -= 1
	var v: Dictionary = elenco[i]
	if dif > 0:
		v["abitanti"] = maxi(10, v["abitanti"] - 5)
		villaggio.messaggio.emit("L'attacco a %s è fallito: servono più soldati" % v["nome"], true)
		_aggiorna_etichetta(i)
		return false
	prendi(i)
	return true


## Il villaggio diventa nostro (dopo un assalto vinto, dei soldati di riserva o di una schiera).
func prendi(i: int) -> void:
	var v: Dictionary = elenco[i]
	v["stato"] = "nostro"
	v["abitanti"] = maxi(10, v["abitanti"] - 5)
	villaggio.messaggio.emit("%s è conquistato! I confini si allargano" % v["nome"], false)
	Suono.suona("completato")
	_aggiorna_etichetta(i)
	_aggiorna_confini()
	cambiato.emit()


func _aggiorna_confini() -> void:
	villaggio.centri_propri = elenco.filter(func(v): return v["stato"] == "nostro").map(
		func(v): return [Vector2i(v["casella"]) + Vector2i(2, 2), RAGGIO_CONFINI, 1])
	villaggio._ricalcola_territorio()


func dati_salvataggio() -> Array:
	return elenco.map(func(v): return {"nome": v["nome"], "tipo": v["tipo"], "x": v["casella"].x, "y": v["casella"].y,
		"abitanti": v["abitanti"], "stato": v["stato"], "doni": v["doni"]})


func carica(lista: Array) -> void:
	for s in lista:
		_aggiungi({"nome": s["nome"], "tipo": s["tipo"], "casella": Vector2i(int(s["x"]), int(s["y"])), "abitanti": int(s["abitanti"]),
			"stato": s["stato"], "doni": int(s["doni"]), "crescita": 0.0, "attesa": PERIODO})
	if not lista.is_empty():
		attivi = true
	cambiato.emit()
