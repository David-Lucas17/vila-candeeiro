extends SceneTree

const FONT := "res://assets/fonts/DejaVuSerif.ttf"
const FONT_BOLD := "res://assets/fonts/DejaVuSerif-Bold.ttf"
const THEME_PATH := "res://assets/ui_theme.tres"

const AMBER := Color("ffb347")
const CREAM := Color("efe0c6")
const ASH := Color("9b8b74")
const BLOOD := Color("c0604a")

var scene_root : Node

func _init():
	build_theme()
	build_game()
	build_menu()
	quit()

func add(parent: Node, n: Node, nname: String, unique := false) -> Node:
	n.name = nname
	parent.add_child(n)
	n.owner = scene_root
	if unique:
		n.unique_name_in_owner = true
	return n

func full_rect(c: Control) -> Control:
	c.anchor_right = 1.0
	c.anchor_bottom = 1.0
	c.offset_left = 0.0
	c.offset_top = 0.0
	c.offset_right = 0.0
	c.offset_bottom = 0.0
	return c

func sb(bg: Color, border := Color(0, 0, 0, 0), bw := 0, radius := 3, margin := 0) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	if bw > 0:
		s.set_border_width_all(bw)
		s.border_color = border
	s.set_corner_radius_all(radius)
	if margin > 0:
		s.content_margin_left = margin
		s.content_margin_right = margin
		s.content_margin_top = margin * 0.7
		s.content_margin_bottom = margin * 0.7
	return s

func label(parent: Node, nname: String, txt: String, size: int, color: Color, bold := false, unique := false) -> Label:
	var l := Label.new()
	l.text = txt
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	if bold:
		l.add_theme_font_override("font", load(FONT_BOLD))
	return add(parent, l, nname, unique) as Label

func rich(parent: Node, nname: String, min_h: int, fit := false, unique := true) -> RichTextLabel:

	var r := RichTextLabel.new()
	r.bbcode_enabled = true
	r.fit_content = fit
	r.scroll_active = false
	r.custom_minimum_size = Vector2(0, min_h)
	r.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	r.size_flags_vertical = Control.SIZE_EXPAND_FILL
	return add(parent, r, nname, unique) as RichTextLabel

func scrolled_rich(parent: Node, nname: String, min_h: int) -> RichTextLabel:
	var sc := ScrollContainer.new()
	sc.custom_minimum_size = Vector2(0, min_h)
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	sc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add(parent, sc, nname + "Scroll")
	return rich(sc, nname, 0, true)

func vbox(parent: Node, nname: String, sep := 8) -> VBoxContainer:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", sep)
	return add(parent, v, nname) as VBoxContainer

func hbox(parent: Node, nname: String, sep := 8) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", sep)
	return add(parent, h, nname) as HBoxContainer

func panel(parent: Node, nname: String, unique := false) -> PanelContainer:
	return add(parent, PanelContainer.new(), nname, unique) as PanelContainer

func button(parent: Node, nname: String, txt: String, min_h := 44) -> Button:
	var b := Button.new()
	b.text = txt
	b.custom_minimum_size = Vector2(0, min_h)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return add(parent, b, nname, true) as Button

func shader_rect(parent: Node, nname: String, shader_path: String, params: Dictionary) -> ColorRect:
	var cr := ColorRect.new()
	full_rect(cr)
	cr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var mat := ShaderMaterial.new()
	mat.shader = load(shader_path)
	for k in params:
		mat.set_shader_parameter(k, params[k])
	cr.material = mat
	return add(parent, cr, nname) as ColorRect

func lamp_node(parent: Node) -> Node2D:
	var n := Node2D.new()
	n.set_script(load("res://scripts/lamp.gd"))
	return add(parent, n, "Lamp", true) as Node2D

func gauge(parent: Node, nname: String, caption: String, fill: Color, max_value: int) -> ProgressBar:
	var row := hbox(parent, nname + "Row", 10)
	var cap := label(row, nname + "Caption", caption, 14, ASH)
	cap.custom_minimum_size = Vector2(54, 0)
	var bar := ProgressBar.new()
	bar.max_value = max_value
	bar.value = max_value
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(0, 16)
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.add_theme_stylebox_override("fill", sb(fill, Color(0, 0, 0, 0), 0, 2))
	add(row, bar, nname + "Bar", true)
	var val := label(row, nname + "Value", "0/0", 14, CREAM, false, true)
	val.custom_minimum_size = Vector2(46, 0)
	val.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	return bar

const AUDIO := {
	"AmbVento": ["amb_vento.wav", -17.0],
	"AmbCandeeiro": ["amb_candeeiro.wav", -24.0],
	"AmbCoracao": ["amb_coracao.wav", -40.0],
	"SfxAzeite": ["acao_azeite.wav", -8.0],
	"SfxSal": ["acao_sal.wav", -8.0],
	"SfxReza": ["acao_reza.wav", -10.0],
	"SfxTrago": ["acao_trago.wav", -8.0],
	"SfxEscutar": ["acao_escutar.wav", -12.0],
	"SfxSusto": ["sfx_susto.wav", -6.0],
	"SfxDefesa": ["sfx_defesa.wav", -9.0],
	"SfxHora": ["sfx_hora.wav", -12.0],
	"FimAmanhecer": ["fim_amanhecer.wav", -6.0],
	"FimEscuro": ["fim_escuro.wav", -5.0],
	"FimFuga": ["fim_fuga.wav", -6.0],
}

func audio(parent: Node, names: Array):
	for nname in names:
		var p := AudioStreamPlayer.new()
		p.stream = load("res://assets/audio/" + AUDIO[nname][0])
		p.volume_db = AUDIO[nname][1]
		add(parent, p, nname, true)

func overlay(parent: Node, nname: String, dim_alpha: float, box_width: int) -> PanelContainer:
	var layer := Control.new()
	full_rect(layer)
	add(parent, layer, nname, true)
	var dim := ColorRect.new()
	full_rect(dim)
	dim.color = Color(0.015, 0.01, 0.008, dim_alpha)
	add(layer, dim, nname + "Dim")
	var center := CenterContainer.new()
	full_rect(center)
	add(layer, center, nname + "Center")
	var box := panel(center, nname + "Box")
	box.custom_minimum_size = Vector2(box_width, 0)
	return box

func build_theme():
	var th := Theme.new()
	th.default_font = load(FONT)
	th.default_font_size = 16

	th.set_stylebox("normal", "Button", sb(Color("1b1310"), Color("4b3826"), 1, 2, 10))
	th.set_stylebox("hover", "Button", sb(Color("2e2016"), AMBER, 1, 2, 10))
	th.set_stylebox("pressed", "Button", sb(Color("3c2a18"), AMBER, 2, 2, 10))
	th.set_stylebox("disabled", "Button", sb(Color("130e0b"), Color("271d15"), 1, 2, 10))
	th.set_stylebox("focus", "Button", sb(Color(0, 0, 0, 0), Color("6b5030"), 1, 2, 10))
	th.set_color("font_color", "Button", Color("e4d2b0"))
	th.set_color("font_hover_color", "Button", Color("ffd79a"))
	th.set_color("font_pressed_color", "Button", Color("fff0cf"))
	th.set_color("font_disabled_color", "Button", Color("574c40"))
	th.set_color("font_focus_color", "Button", Color("ffd79a"))

	var pan := sb(Color(0.035, 0.025, 0.019, 0.80), Color("3b2a1c"), 1, 3, 14)
	th.set_stylebox("panel", "PanelContainer", pan)
	th.set_stylebox("panel", "Panel", pan)

	th.set_color("font_color", "Label", CREAM)
	th.set_color("default_color", "RichTextLabel", CREAM)
	th.set_font("normal_font", "RichTextLabel", load(FONT))
	th.set_font("bold_font", "RichTextLabel", load(FONT_BOLD))
	th.set_font("italics_font", "RichTextLabel", load(FONT))
	th.set_font_size("normal_font_size", "RichTextLabel", 16)
	th.set_font_size("bold_font_size", "RichTextLabel", 16)

	th.set_stylebox("background", "ProgressBar", sb(Color("17100c"), Color("3b2a1c"), 1, 2))
	th.set_stylebox("fill", "ProgressBar", sb(Color("e08a26"), Color(0, 0, 0, 0), 0, 2))

	th.set_stylebox("panel", "ScrollContainer", sb(Color(0, 0, 0, 0)))

	ResourceSaver.save(th, THEME_PATH)
	print("tema .......... ", THEME_PATH)

func build_game():
	var game := Control.new()
	full_rect(game)
	game.name = "Game"
	game.set_script(load("res://scripts/game.gd"))
	game.theme = load(THEME_PATH)
	scene_root = game

	shader_rect(game, "Taipa", "res://shaders/taipa.gdshader",
		{"light_energy": 1.0, "light_pos": Vector2(0.26, 0.60), "flicker": 1.0})
	lamp_node(game)
	shader_rect(game, "Vinheta", "res://shaders/vinheta.gdshader",
		{"darkness": 0.35, "dread": 0.0})

	var ui := MarginContainer.new()
	full_rect(ui)
	ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for side in ["left", "right"]:
		ui.add_theme_constant_override("margin_" + side, 22)
	for side in ["top", "bottom"]:
		ui.add_theme_constant_override("margin_" + side, 18)
	add(game, ui, "UI")

	var cols := hbox(ui, "Cols", 14)

	var left := vbox(cols, "Left", 10)
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.size_flags_stretch_ratio = 1.42

	var title_box := vbox(left, "TitleBox", 0)
	label(title_box, "Title", "A VIGÍLIA DO CANDEEIRO", 25, AMBER, true)
	label(title_box, "Place", "sertão central do Ceará · 1932", 13, ASH)

	var stage := panel(left, "Stage")
	rich(stage, "StageText", 132)

	var gap := Control.new()
	gap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	gap.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add(left, gap, "Gap")

	var actions := GridContainer.new()
	actions.columns = 3
	actions.add_theme_constant_override("h_separation", 8)
	actions.add_theme_constant_override("v_separation", 8)
	add(left, actions, "Actions")
	button(actions, "BtnAzeite", "1 · Pingar azeite")
	button(actions, "BtnSal", "2 · Jogar sal")
	button(actions, "BtnReza", "3 · Fazer uma oração")
	button(actions, "BtnTrago", "4 · Tomar um trago")
	button(actions, "BtnEscutar", "5 · Escutar")
	button(actions, "BtnHelp", "H · O que a vó ensinou")

	var right := vbox(cols, "Right", 10)
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.size_flags_stretch_ratio = 1.0

	var head := panel(right, "Head")
	var head_col := vbox(head, "HeadCol", 8)
	var clock_row := hbox(head_col, "ClockRow", 8)
	var clock := label(clock_row, "Clock", "22h", 34, AMBER, true, true)
	clock.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var left_lbl := label(clock_row, "HoursLeft", "faltam 8 horas", 13, ASH, false, true)
	left_lbl.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM

	gauge(head_col, "Light", "LUZ", Color("e08a26"), 10)
	gauge(head_col, "Fear", "MEDO", Color("a8392c"), 10)

	var stock := hbox(head_col, "StockRow", 14)
	label(stock, "StockOil", "Azeite  ●●●●●", 14, CREAM, false, true)
	label(stock, "StockSalt", "Sal  ●●●", 14, CREAM, false, true)
	label(stock, "StockBooze", "Cana  ●●", 14, CREAM, false, true)

	var log_panel := panel(right, "LogPanel")
	log_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var log_col := vbox(log_panel, "LogCol", 6)
	label(log_col, "LogTitle", "REGISTRO DA NOITE", 13, ASH)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add(log_col, scroll, "LogScroll", true)
	rich(scroll, "LogText", 0, true)

	var help_box := overlay(game, "HelpPanel", 0.90, 700)
	var help_col := vbox(help_box, "HelpCol", 12)
	label(help_col, "HelpTitle", "O QUE A VÓ ENSINOU", 22, AMBER, true)
	scrolled_rich(help_col, "RulesText", 380)
	button(help_col, "BtnCloseHelp", "Fechar  ·  Esc")

	var end_box := overlay(game, "EndPanel", 0.93, 760)
	var end_col := vbox(end_box, "EndCol", 16)
	var end_title := label(end_col, "EndTitle", "O GALO CANTOU", 36, AMBER, true, true)
	end_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rich(end_col, "EndText", 258)
	var end_btns := hbox(end_col, "EndButtons", 10)
	button(end_btns, "BtnAgain", "Velar outra noite  ·  R")
	button(end_btns, "BtnMenu", "Voltar ao começo")

	audio(game, AUDIO.keys())

	save_scene(game, "res://scenes/game.tscn")

func build_menu():
	var menu := Control.new()
	full_rect(menu)
	menu.name = "Menu"
	menu.set_script(load("res://scripts/menu.gd"))
	menu.theme = load(THEME_PATH)
	scene_root = menu

	shader_rect(menu, "Taipa", "res://shaders/taipa.gdshader",
		{"light_energy": 1.0, "light_pos": Vector2(0.203, 0.673), "flicker": 1.0})

	var menu_lamp := lamp_node(menu)
	menu_lamp.scale = Vector2(0.78, 0.78)
	menu_lamp.position = Vector2(0, 130)
	shader_rect(menu, "Vinheta", "res://shaders/vinheta.gdshader",
		{"darkness": 0.48, "dread": 0.05, "radius": 0.72})

	var ui := MarginContainer.new()
	full_rect(ui)
	ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_theme_constant_override("margin_left", 40)
	ui.add_theme_constant_override("margin_right", 34)
	ui.add_theme_constant_override("margin_top", 28)
	ui.add_theme_constant_override("margin_bottom", 28)
	add(menu, ui, "UI")

	var cols := hbox(ui, "Cols", 20)
	var gap := Control.new()
	gap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	gap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	gap.size_flags_stretch_ratio = 0.85
	add(cols, gap, "Gap")

	var right := vbox(cols, "Right", 14)
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.size_flags_stretch_ratio = 1.15
	right.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	var title_box := vbox(right, "TitleBox", 2)
	label(title_box, "Kicker", "NOITES CABULOSAS NO CEARÁ", 13, ASH)
	label(title_box, "Title", "A VIGÍLIA\nDO CANDEEIRO", 44, AMBER, true)

	var intro_panel := panel(right, "IntroPanel")
	rich(intro_panel, "Intro", 250)

	var btns := vbox(right, "Buttons", 8)
	button(btns, "BtnStart", "Começar a vigília  ·  Enter")
	button(btns, "BtnRules", "Como se vela um corpo  ·  H")
	button(btns, "BtnQuit", "Sair  ·  Esc")

	var rules_box := overlay(menu, "RulesPanel", 0.92, 700)
	var rules_col := vbox(rules_box, "RulesCol", 12)
	label(rules_col, "RulesTitle", "COMO SE VELA UM CORPO", 22, AMBER, true)
	scrolled_rich(rules_col, "RulesText", 380)
	button(rules_col, "BtnCloseRules", "Fechar  ·  Esc")

	audio(menu, ["AmbVento", "AmbCandeeiro"])

	save_scene(menu, "res://scenes/menu.tscn")

func save_scene(node: Node, path: String):
	var packed := PackedScene.new()
	var err := packed.pack(node)
	if err != OK:
		push_error("falhou empacotar %s: %d" % [path, err])
		return
	err = ResourceSaver.save(packed, path)
	if err != OK:
		push_error("falhou salvar %s: %d" % [path, err])
		return
	print("cena .......... ", path, "  (", count(node), " nós)")
	node.free()

func count(n: Node) -> int:
	var total := 1
	for c in n.get_children():
		total += count(c)
	return total
