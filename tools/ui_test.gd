extends SceneTree

var fails := 0

func _initialize():
	run.call_deferred()

func run():

	root.size = Vector2i(
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height"))
	var game = load("res://scenes/game.tscn").instantiate()
	root.add_child(game)
	await process_frame
	await process_frame

	var view = Vector2(root.size)
	print("viewport: %d x %d\n" % [view.x, view.y])

	print("--- onde cada parte da tela caiu ---")
	for path in ["UI/Cols/Left/TitleBox", "UI/Cols/Left/Stage", "UI/Cols/Left/Gap",
				 "UI/Cols/Left/Actions", "UI/Cols/Right/Head", "UI/Cols/Right/LogPanel"]:
		var c = game.get_node(path) as Control
		print("  %-28s x %4d..%4d   y %4d..%4d" % [path.get_file(),
			c.global_position.x, c.global_position.x + c.size.x,
			c.global_position.y, c.global_position.y + c.size.y])

	for path in ["UI/Cols/Left/Actions", "UI/Cols/Right/LogPanel"]:
		var c = game.get_node(path) as Control
		check(c.global_position.x + c.size.x <= view.x + 1, "%s não vaza pela direita" % path.get_file())
		check(c.global_position.y + c.size.y <= view.y + 1, "%s não vaza por baixo" % path.get_file())

	var gap = game.get_node("UI/Cols/Left/Gap") as Control
	var stage = game.get_node("UI/Cols/Left/Stage") as Control
	var actions = game.get_node("UI/Cols/Left/Actions") as Control
	print("\n--- a sala desenhada (x 60..640, y 348..516) cabe no vão? ---")
	print("  vão livre:  y %d..%d  (entre o presságio e os botões)" % [
		stage.global_position.y + stage.size.y, actions.global_position.y])
	check(stage.global_position.y + stage.size.y <= 352, "o presságio não cobre a chama")
	check(actions.global_position.y >= 512, "os botões não cobrem a mesa")
	check(gap.size.x >= 640, "o vão é largo o bastante pra sala")

	print("\n--- jogando uma noite pelos botões ---")
	var names = {"BtnAzeite": 1, "BtnSal": 2, "BtnReza": 3, "BtnTrago": 4, "BtnEscutar": 5}
	var hours := 0
	while not game.vigil.is_over() and hours < 12:
		var before_hour = game.vigil.hour
		var before_log = game.get_node("%LogText").get_parsed_text().length()

		var want = defense_for(game.vigil.current.kind)
		if not game.vigil.can_play(want):
			want = Vigil.Action.ESCUTAR
		var btn = button_for(game, want)
		btn.pressed.emit()
		await process_frame
		await process_frame
		hours += 1
		var after_log = game.get_node("%LogText").get_parsed_text().length()
		check(after_log > before_log, "hora %d: o registro cresceu" % before_hour)
		if not game.vigil.is_over():
			check(game.vigil.hour == before_hour + 1, "hora %d: o relógio andou" % before_hour)
			check(game.get_node("%Clock").text == game.vigil.hour_label(), "hora %d: o relógio na tela confere" % before_hour)
			check(game.get_node("%LightBar").value == game.vigil.light, "hora %d: a barra de Luz confere" % before_hour)
			check(game.get_node("%FearBar").value == game.vigil.fear, "hora %d: a barra de Medo confere" % before_hour)
			check(game.get_node("%StageText").get_parsed_text().contains(game.vigil.omen), "hora %d: o presságio novo apareceu" % before_hour)

	print("\n--- fim de jogo ---")
	print("  desfecho: %s" % game.vigil.ending_title())
	check(game.vigil.is_over(), "a noite terminou em %d horas" % hours)
	check(game.get_node("%EndPanel").visible, "o painel de desfecho apareceu")
	check(game.get_node("%EndTitle").text == game.vigil.ending_title(), "o título do desfecho confere")
	check(game.get_node("%EndText").text.length() > 120, "o texto do desfecho veio inteiro")
	check(game.get_node("%RulesText").get_parsed_text().contains("SOLEIRA"), "a tela de ajuda tem a tabela de defesas")

	print("\n--- tela de abertura ---")
	game.queue_free()
	var menu = load("res://scenes/menu.tscn").instantiate()
	root.add_child(menu)
	await process_frame
	await process_frame
	check(menu.get_node("%Intro").get_parsed_text().contains("Firmino"), "a abertura conta a história")
	check(menu.get_node("%RulesText").get_parsed_text().contains("PÂNICO"), "as regras estão na abertura")
	check(not menu.get_node("%RulesPanel").visible, "as regras começam fechadas")
	for b in ["BtnStart", "BtnRules", "BtnQuit"]:
		check(menu.get_node("%" + b) != null, "o botão %s existe" % b)
	var btm = menu.get_node("UI/Cols/Right/Buttons") as Control
	check(btm.global_position.y + btm.size.y <= root.size.y + 1, "os botões da abertura cabem na tela")

	print("\n--- os dois jeitos de perder ---")
	var dark = Vigil.new()
	while not dark.is_over():
		dark.play(Vigil.Action.REZA)
	check(dark.status == Vigil.Status.LOST_DARK, "quem só reza morre no escuro: %s" % dark.ending_title())
	check(dark.ending_text().length() > 150, "o desfecho do escuro tem texto")

	var scared = Vigil.new()
	while not scared.is_over():
		scared.play(Vigil.Action.AZEITE if scared.can_play(Vigil.Action.AZEITE) else Vigil.Action.ESCUTAR)
	check(scared.status == Vigil.Status.LOST_FEAR, "quem só cuida da luz foge de medo: %s" % scared.ending_title())
	check(scared.ending_text().length() > 150, "o desfecho da fuga tem texto")

	print("\n=========================================")
	if fails == 0:
		print("  tudo certo.")
	else:
		print("  %d VERIFICAÇÕES FALHARAM" % fails)
	print("=========================================")
	quit(1 if fails > 0 else 0)

func defense_for(kind):
	match kind:
		NightEvent.Kind.SOMBRA:  return Vigil.Action.AZEITE
		NightEvent.Kind.SOLEIRA: return Vigil.Action.SAL
		NightEvent.Kind.ALMA:    return Vigil.Action.REZA
		_:                       return Vigil.Action.TRAGO

func button_for(game, action):
	match action:
		Vigil.Action.AZEITE:  return game.get_node("%BtnAzeite")
		Vigil.Action.SAL:     return game.get_node("%BtnSal")
		Vigil.Action.REZA:    return game.get_node("%BtnReza")
		Vigil.Action.TRAGO:   return game.get_node("%BtnTrago")
		_:                    return game.get_node("%BtnEscutar")

func check(cond: bool, what: String):
	if cond:
		print("  ok    %s" % what)
	else:
		fails += 1
		print("  FALHA %s" % what)
