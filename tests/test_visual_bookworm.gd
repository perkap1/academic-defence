extends SceneTree
func _initialize(): call_deferred("run")
func run():
	var stage := Node2D.new()
	root.add_child(stage)
	var library = load("res://scripts/bookworm_frames.gd")
	for books in range(4):
		var frames = library.create(3-books)
		for direction in range(3):
			for frame in range(6):
				var sprite := Sprite2D.new()
				stage.add_child(sprite)
				sprite.texture = frames[["front","side","back"][direction]][frame]
				sprite.centered = false
				sprite.offset = Vector2(-90,-190)
				sprite.scale = Vector2.ONE*0.6
				sprite.position = Vector2(110+frame*260,100+books*260+direction*80)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("../AcademicDefence-bookworm-frames.png")
	stage.free()
	var main = load("res://scenes/main_map3.tscn").instantiate()
	root.add_child(main)
	main.process_mode = Node.PROCESS_MODE_DISABLED
	for path in main.map.get_routes():
		var line := Line2D.new()
		line.points = path.curve.get_baked_points()
		line.width = 3
		line.default_color = Color(1,0.3,0.1,0.75)
		main.map.effects.add_child(line)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("../AcademicDefence-map3-paths.png")
	main.free()
	print("BOOKWORM VISUAL: 72 poses and both Map3 paths rendered")
	quit()
