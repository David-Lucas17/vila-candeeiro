extends SceneTree

const SHOT_DIR := "/tmp/vigilia"

var errors := 0

func _initialize():
	run.call_deferred()

func run():
	DirAccess.make_dir_recursive_absolute(SHOT_DIR)
	root.size = Vector2i(1152, 648)

	var menu = load("res://scenes/menu.tscn").instantiate()
	root.add_child(menu)
	await settle(40)
	await shot("01-abertura")
	menu.get_node("%BtnRules").pressed.emit()
	await settle(15)
	await shot("02-regras")
	menu.get_node("%BtnCloseRules").pressed.emit()
	await settle(5)
	menu.free()

	var game = load("res://scenes/game.tscn").instantiate()
	root.add_child(game)
	await settle(40)
	print("\n[partida A] jogando a defesa certa a cada hora")
	await shot("03-hora-1")
	var hour := 0
	while not game.vigil.is_over():
		hour += 1
		var want = defense_for(game.vigil.current.kind)
		if not game.vigil.can_play(want):
			want = Vigil.Action.ESCUTAR
		print("  %s  luz %d  medo %d  -> %s (%s)" % [game.vigil.hour_label(),
			game.vigil.light, game.vigil.fear, action_name(want), game.vigil.current.kind_name()])
		button_for(game, want).pressed.emit()
		await settle(24)
		if hour == 4:
			await shot("04-meio-da-noite")
		if hour == 3:
			game.get_node("%BtnHelp").pressed.emit()
			await settle(12)
			await shot("05-ajuda")
			game.get_node("%BtnCloseHelp").pressed.emit()
			await settle(8)
	print("  desfecho: %s" % game.vigil.ending_title())
	await settle(100)
	await shot("06-fim-" + slug(game.vigil.status))
	game.free()

	var bad = load("res://scenes/game.tscn").instantiate()
	root.add_child(bad)
	await settle(30)
	print("\n[partida B] só escutando, pra deixar o medo subir")
	var shot_scared := false
	var shot_dark := false
	while not bad.vigil.is_over():
		bad.get_node("%BtnEscutar").pressed.emit()
		await settle(22)
		print("  %s  luz %d  medo %d" % [bad.vigil.hour_label(), bad.vigil.light, bad.vigil.fear])
		if not shot_scared and bad.vigil.fear >= 7:
			await shot("07-medo-alto")
			shot_scared = true
		if not shot_dark and bad.vigil.light <= 2:
			await shot("08-luz-curta")
			shot_dark = true
	print("  desfecho: %s" % bad.vigil.ending_title())
	await settle(100)
	await shot("09-fim-" + slug(bad.vigil.status))

	print("\nimagens em %s" % SHOT_DIR)
	quit()

func settle(frames: int):
	for i in range(frames):
		await process_frame

func shot(nname: String):
	await RenderingServer.frame_post_draw
	var img := root.get_texture().get_image()
	var path := "%s/%s.png" % [SHOT_DIR, nname]
	var err := img.save_png(path)
	if err != OK:
		push_error("não salvou %s: %d" % [path, err])
	else:
		print("    [tela] %s" % nname)

func slug(status) -> String:
	match status:
		Vigil.Status.WON: return "venceu"
		Vigil.Status.LOST_DARK: return "escuro"
		_: return "fuga"

func action_name(a) -> String:
	match a:
		Vigil.Action.AZEITE: return "azeite"
		Vigil.Action.SAL: return "sal"
		Vigil.Action.REZA: return "oração"
		Vigil.Action.TRAGO: return "trago"
		_: return "escutar"

func defense_for(kind):
	match kind:
		NightEvent.Kind.SOMBRA: return Vigil.Action.AZEITE
		NightEvent.Kind.SOLEIRA: return Vigil.Action.SAL
		NightEvent.Kind.ALMA: return Vigil.Action.REZA
		_: return Vigil.Action.TRAGO

func button_for(game, action):
	match action:
		Vigil.Action.AZEITE: return game.get_node("%BtnAzeite")
		Vigil.Action.SAL: return game.get_node("%BtnSal")
		Vigil.Action.REZA: return game.get_node("%BtnReza")
		Vigil.Action.TRAGO: return game.get_node("%BtnTrago")
		_: return game.get_node("%BtnEscutar")
