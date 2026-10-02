extends SceneTree

func _initialize():
	run.call_deferred()

func run():
	root.size = Vector2i(1152, 648)
	var game = load("res://scenes/game.tscn").instantiate()
	root.add_child(game)
	await frames(50)
	game.get_node("UI").visible = false
	game.vigil.light = 9
	game.vigil.fear = 3
	await frames(40)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/tmp/cover_clean.png")
	print("captura limpa salva")
	quit()

func frames(n: int):
	for i in range(n):
		await process_frame
