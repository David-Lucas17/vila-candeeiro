extends Control

func _ready():
	%Intro.text = RulesText.intro()
	%RulesText.text = RulesText.body()
	%RulesPanel.visible = false

	%Lamp.energy = 0.92
	%Lamp.dread = 0.10

	%BtnStart.pressed.connect(_start)
	%BtnRules.pressed.connect(func(): %RulesPanel.visible = true)
	%BtnCloseRules.pressed.connect(func(): %RulesPanel.visible = false)
	%BtnQuit.pressed.connect(func(): get_tree().quit())

	%AmbVento.finished.connect(%AmbVento.play)
	%AmbVento.play()
	%AmbCandeeiro.finished.connect(%AmbCandeeiro.play)
	%AmbCandeeiro.play()

	%BtnStart.grab_focus()

func _process(_delta):
	var mat : ShaderMaterial = ($Taipa as ColorRect).material
	mat.set_shader_parameter("light_energy", %Lamp.energy * 1.1)
	mat.set_shader_parameter("flicker", %Lamp.flicker)

func _unhandled_input(event):
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if %RulesPanel.visible:
		if event.keycode in [KEY_ESCAPE, KEY_ENTER, KEY_SPACE]:
			%RulesPanel.visible = false
		return
	match event.keycode:
		KEY_ENTER, KEY_SPACE: _start()
		KEY_H: %RulesPanel.visible = true
		KEY_ESCAPE: get_tree().quit()

func _start():
	get_tree().change_scene_to_file("res://scenes/game.tscn")
