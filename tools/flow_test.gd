extends SceneTree

var fails := 0

func _initialize():
	run.call_deferred()

func run():
	root.size = Vector2i(1152, 648)

	print("--- abre na tela de abertura ---")
	change_scene_to_file("res://scenes/menu.tscn")
	await frames(5)
	check(current_scene != null and current_scene.name == "Menu", "a cena de abertura carregou")

	print("\n--- tecla H abre e fecha as regras ---")
	await key(KEY_H)
	check(current_scene.get_node("%RulesPanel").visible, "H abriu as regras")
	await key(KEY_ESCAPE)
	check(not current_scene.get_node("%RulesPanel").visible, "Esc fechou as regras")

	print("\n--- Enter começa a vigília ---")
	await key(KEY_ENTER)
	await frames(8)
	check(current_scene != null and current_scene.name == "Game", "trocou pra cena de jogo")
	var game = current_scene
	check(game.vigil.hour == 1, "a noite começa às 22h")

	print("\n--- jogando pelas teclas 1 a 5 ---")
	var keys = [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5]
	var played := 0
	while not game.vigil.is_over() and played < 10:
		var before = game.vigil.hour
		await key(keys[played % 5])
		played += 1
		if not game.vigil.is_over():
			check(game.vigil.hour == before + 1, "tecla %d avançou a hora" % ((played - 1) % 5 + 1))
	check(game.vigil.is_over(), "a noite terminou: %s" % game.vigil.ending_title())
	await frames(10)
	check(game.get_node("%EndPanel").visible, "apareceu o desfecho")

	print("\n--- tecla R vela outra noite ---")
	await key(KEY_R)
	await frames(12)
	check(current_scene != null and current_scene.name == "Game", "recarregou a cena de jogo")
	check(current_scene.vigil.hour == 1, "a noite nova começa do zero")
	check(current_scene.vigil.light == Vigil.START_LIGHT, "a Luz voltou ao cheio")
	check(not current_scene.get_node("%EndPanel").visible, "o desfecho sumiu")

	print("\n--- botão volta pro começo ---")
	var g2 = current_scene
	while not g2.vigil.is_over():
		g2.get_node("%BtnEscutar").pressed.emit()
		await frames(2)
	await frames(6)
	g2.get_node("%BtnMenu").pressed.emit()
	await frames(10)
	check(current_scene != null and current_scene.name == "Menu", "voltou pra tela de abertura")

	print("\n=========================================")
	print("  tudo certo." if fails == 0 else "  %d VERIFICAÇÕES FALHARAM" % fails)
	print("=========================================")
	quit(1 if fails > 0 else 0)

func frames(n: int):
	for i in range(n):
		await process_frame

func key(code: Key):
	var down := InputEventKey.new()
	down.keycode = code
	down.physical_keycode = code
	down.pressed = true
	Input.parse_input_event(down)
	await frames(3)
	var up := InputEventKey.new()
	up.keycode = code
	up.physical_keycode = code
	up.pressed = false
	Input.parse_input_event(up)
	await frames(3)

func check(cond: bool, what: String):
	if cond:
		print("  ok    %s" % what)
	else:
		fails += 1
		print("  FALHA %s" % what)
