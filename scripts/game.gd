extends Control

const C_AMBER := "#ffb347"
const C_CREAM := "#efe0c6"
const C_BLOOD := "#c0604a"
const C_ASH := "#9b8b74"

var vigil : Vigil

var _hit_flash : float = 0.0
var _hour_shown : int = 0

@onready var taipa_mat : ShaderMaterial = ($Taipa as ColorRect).material
@onready var vinheta_mat : ShaderMaterial = ($Vinheta as ColorRect).material

func _ready():
	vigil = Vigil.new()

	%BtnAzeite.pressed.connect(_on_action.bind(Vigil.Action.AZEITE))
	%BtnSal.pressed.connect(_on_action.bind(Vigil.Action.SAL))
	%BtnReza.pressed.connect(_on_action.bind(Vigil.Action.REZA))
	%BtnTrago.pressed.connect(_on_action.bind(Vigil.Action.TRAGO))
	%BtnEscutar.pressed.connect(_on_action.bind(Vigil.Action.ESCUTAR))

	%BtnHelp.pressed.connect(func(): %HelpPanel.visible = true)
	%BtnCloseHelp.pressed.connect(func(): %HelpPanel.visible = false)
	%BtnAgain.pressed.connect(_restart)
	%BtnMenu.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/menu.tscn"))

	for amb in [%AmbVento, %AmbCandeeiro, %AmbCoracao]:
		amb.finished.connect(amb.play)
		amb.play()

	%RulesText.text = RulesText.body()
	%EndPanel.visible = false
	%HelpPanel.visible = false

	%LogText.text = ""
	_log("[color=%s]22h — a casa ficou só com você e com ele.[/color]" % C_ASH)
	_log("Ninguém quis ficar. Vele o corpo até o galo cantar.")
	_log("")
	refresh()

func _process(delta):
	var light_k = float(vigil.light) / float(Vigil.MAX_LIGHT)
	var fear_k = float(vigil.fear) / float(Vigil.MAX_FEAR)

	_hit_flash = maxf(0.0, _hit_flash - delta * 1.6)

	%Lamp.energy = lerpf(%Lamp.energy, light_k, delta * 4.0)
	%Lamp.dread = lerpf(%Lamp.dread, fear_k, delta * 3.0)

	taipa_mat.set_shader_parameter("light_energy", %Lamp.energy * 1.15)
	taipa_mat.set_shader_parameter("flicker", %Lamp.flicker)
	vinheta_mat.set_shader_parameter("darkness", clampf(0.86 - light_k * 0.78, 0.08, 0.95))
	vinheta_mat.set_shader_parameter("dread", clampf(fear_k * 0.9 + _hit_flash, 0.0, 1.0))

	var heart_db = lerpf(-40.0, -6.0, clampf((fear_k - 0.45) / 0.55, 0.0, 1.0))
	%AmbCoracao.volume_db = heart_db
	%AmbCandeeiro.volume_db = lerpf(-34.0, -17.0, light_k)

func _unhandled_input(event):
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if %HelpPanel.visible:
		if event.keycode in [KEY_ESCAPE, KEY_H, KEY_ENTER]:
			%HelpPanel.visible = false
		return
	if vigil.is_over():
		if event.keycode == KEY_R:
			_restart()
		return
	match event.keycode:
		KEY_1: _on_action(Vigil.Action.AZEITE)
		KEY_2: _on_action(Vigil.Action.SAL)
		KEY_3: _on_action(Vigil.Action.REZA)
		KEY_4: _on_action(Vigil.Action.TRAGO)
		KEY_5: _on_action(Vigil.Action.ESCUTAR)
		KEY_H: %HelpPanel.visible = true

func _on_action(action):
	if vigil.is_over() or not vigil.can_play(action):
		return

	var hour_label = vigil.hour_label()
	var report = vigil.play(action)

	_play_action_sound(action)

	if vigil.last_defended:
		%SfxDefesa.play()
	else:
		%SfxSusto.play()
		_hit_flash = 0.45

	_log("[color=%s]── %s ─────────────────────────[/color]" % [C_ASH, hour_label])
	for line in report:
		if line == "":
			_log("")
		elif line.ends_with("]") and line.contains(" — ["):
			_log("[color=%s][b]%s[/b][/color]" % [C_AMBER, line])
		elif line.begins_with("A defesa pegou"):
			_log("[color=%s]%s[/color]" % [C_AMBER, line])
		elif line.begins_with("Era outra coisa") or line.begins_with("A coragem da cana"):
			_log("[color=%s]%s[/color]" % [C_BLOOD, line])
		else:
			_log(line)
	_log("")

	refresh()
	if vigil.is_over():
		_show_ending()

func _play_action_sound(action):
	match action:
		Vigil.Action.AZEITE:  %SfxAzeite.play()
		Vigil.Action.SAL:     %SfxSal.play()
		Vigil.Action.REZA:    %SfxReza.play()
		Vigil.Action.TRAGO:   %SfxTrago.play()
		Vigil.Action.ESCUTAR: %SfxEscutar.play()

func refresh():
	%Clock.text = vigil.hour_label()
	if vigil.is_over():
		%HoursLeft.text = "a noite acabou"
	elif vigil.hours_left() == 0:
		%HoursLeft.text = "última hora"
	else:
		%HoursLeft.text = "faltam %d horas" % (vigil.hours_left() + 1)

	%LightBar.value = vigil.light
	%LightValue.text = "%d/%d" % [vigil.light, Vigil.MAX_LIGHT]
	%FearBar.value = vigil.fear
	%FearValue.text = "%d/%d" % [vigil.fear, Vigil.MAX_FEAR]

	%StockOil.text = "Azeite  " + _pips(vigil.oil, Vigil.START_OIL)
	%StockSalt.text = "Sal  " + _pips(vigil.salt, Vigil.START_SALT)
	%StockBooze.text = "Cana  " + _pips(vigil.booze, Vigil.START_BOOZE)

	%BtnAzeite.text = "1 · Pingar azeite (%d)" % vigil.oil
	%BtnSal.text = "2 · Jogar sal (%d)" % vigil.salt
	%BtnReza.text = "3 · Fazer uma oração"
	%BtnTrago.text = "4 · Tomar um trago (%d)" % vigil.booze
	%BtnEscutar.text = "5 · Escutar"

	%BtnAzeite.disabled = not vigil.can_play(Vigil.Action.AZEITE)
	%BtnSal.disabled = not vigil.can_play(Vigil.Action.SAL)
	%BtnReza.disabled = not vigil.can_play(Vigil.Action.REZA)
	%BtnTrago.disabled = not vigil.can_play(Vigil.Action.TRAGO)
	%BtnEscutar.disabled = not vigil.can_play(Vigil.Action.ESCUTAR)

	_refresh_stage()

func _refresh_stage():
	if vigil.is_over():
		%StageText.text = "[center][color=%s]%s[/color][/center]" % [C_ASH, "A noite acabou."]
		return

	var s = "[color=%s]%s — a noite avisa:[/color]\n" % [C_ASH, vigil.hour_label()]
	var color = C_AMBER if vigil.revealed else C_CREAM
	if vigil.omen_is_vague:
		color = C_BLOOD
	s += "[color=%s][i]%s[/i][/color]\n\n" % [color, vigil.omen]

	if vigil.hangover:
		s += "[color=%s]A cana ainda está firmando sua mão. Vai cobrar na hora que vem.[/color]\n\n" % C_BLOOD

	s += "[color=%s]O que você faz?[/color]" % C_ASH
	%StageText.text = s

func _pips(have: int, total: int) -> String:
	var s = ""
	for i in range(total):
		s += "●" if i < have else "○"
	return s

func _log(line: String):
	%LogText.append_text(line + "\n")

	await get_tree().process_frame
	%LogScroll.scroll_vertical = int(%LogScroll.get_v_scroll_bar().max_value)

func _show_ending():
	%EndTitle.text = vigil.ending_title()
	%EndText.text = vigil.ending_text()

	match vigil.status:
		Vigil.Status.WON:
			%EndTitle.add_theme_color_override("font_color", Color("#ffcf7a"))
			%FimAmanhecer.play()
		Vigil.Status.LOST_DARK:
			%EndTitle.add_theme_color_override("font_color", Color("#8f8f8f"))
			%FimEscuro.play()
		_:
			%EndTitle.add_theme_color_override("font_color", Color("#c0604a"))
			%FimFuga.play()

	for amb in [%AmbVento, %AmbCandeeiro, %AmbCoracao]:
		amb.stop()

	%EndPanel.visible = true
	%EndPanel.modulate.a = 0.0
	create_tween().tween_property(%EndPanel, "modulate:a", 1.0, 1.2)

func _restart():
	get_tree().reload_current_scene()
