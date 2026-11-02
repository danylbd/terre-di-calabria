class_name Suono
## Scorciatoie statiche verso l'autoload "Audio". Gli script del gioco usano queste e non
## l'identificatore Audio, che non esiste quando i test partono con --script.


static func _audio() -> Node:
	var albero := Engine.get_main_loop() as SceneTree
	return albero.root.get_node_or_null("Audio") if albero else null


static func suona_in(nome: String, dove: Vector2, volume_db := 0.0) -> void:
	var a := _audio()
	if a:
		a.suona_in(nome, dove, volume_db)


static func suona(nome: String, volume_db := 0.0) -> void:
	var a := _audio()
	if a:
		a.suona(nome, volume_db)


static func ambiente(nome: String, volume_db: Variant = 0.0) -> void:
	var a := _audio()
	if a:
		a.ambiente(nome, volume_db)


static func spegni_ambiente() -> void:
	var a := _audio()
	if a:
		a.spegni_ambiente()


static func musica(nome: String) -> void:
	var a := _audio()
	if a:
		a.musica(nome)


static func scaletta(nomi: Array[String]) -> void:
	var a := _audio()
	if a:
		a.scaletta(nomi)


static func brano() -> String:
	var a := _audio()
	return a.brano_attuale() if a else ""


static func alterna_musica() -> bool:
	var a := _audio()
	return a.alterna_musica() if a else false


## Un personaggio dice una battuta con la sua voce inventata (sillabe senza parole vere).
static func parla(voce: String, testo: String) -> void:
	var a := _audio()
	if a:
		a.parla(voce, testo)


static func taci() -> void:
	var a := _audio()
	if a:
		a.taci()
