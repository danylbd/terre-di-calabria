class_name TemaGioco
## Tema grafico dell'interfaccia di gioco: pergamena, terracotta, inchiostro.


static func crea(dim_font := 20) -> Theme:
	var t := Theme.new()
	t.default_font_size = dim_font

	var normale := StyleBoxFlat.new()
	normale.bg_color = Palette.PERGAMENA_CHIARA
	normale.border_color = Palette.TERRACOTTA_SCURA
	normale.set_border_width_all(2)
	normale.set_corner_radius_all(6)
	normale.set_content_margin_all(6)

	var sopra := normale.duplicate() as StyleBoxFlat
	sopra.bg_color = Color("fff8e6")
	sopra.border_color = Palette.TERRACOTTA

	var premuto := normale.duplicate() as StyleBoxFlat
	premuto.bg_color = Color("f6dca0")
	premuto.border_color = Palette.OCRA
	premuto.set_border_width_all(3)

	var spento := normale.duplicate() as StyleBoxFlat
	spento.bg_color = Color(Palette.PERGAMENA, 0.6)
	spento.border_color = Color(Palette.TERRACOTTA_SCURA, 0.4)

	for nome in ["normal", "focus"]:
		t.set_stylebox(nome, "Button", normale)
	t.set_stylebox("hover", "Button", sopra)
	t.set_stylebox("pressed", "Button", premuto)
	t.set_stylebox("hover_pressed", "Button", premuto)
	t.set_stylebox("disabled", "Button", spento)
	for c in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_hover_pressed_color"]:
		t.set_color(c, "Button", Palette.INCHIOSTRO)
	t.set_color("font_disabled_color", "Button", Color(Palette.INCHIOSTRO, 0.4))

	var pannello := StyleBoxFlat.new()
	pannello.bg_color = Palette.PERGAMENA
	pannello.border_color = Palette.TERRACOTTA_SCURA
	pannello.set_border_width_all(3)
	pannello.set_corner_radius_all(10)
	pannello.set_content_margin_all(12)
	pannello.shadow_color = Color(0, 0, 0, 0.35)
	pannello.shadow_size = 8
	pannello.shadow_offset = Vector2(0, 3)
	t.set_stylebox("panel", "PanelContainer", pannello)

	var suggerimento := pannello.duplicate() as StyleBoxFlat
	suggerimento.set_content_margin_all(10)
	t.set_stylebox("panel", "TooltipPanel", suggerimento)
	t.set_color("font_color", "TooltipLabel", Palette.INCHIOSTRO)
	t.set_font_size("font_size", "TooltipLabel", 17)

	t.set_color("font_color", "Label", Palette.INCHIOSTRO)
	return t
