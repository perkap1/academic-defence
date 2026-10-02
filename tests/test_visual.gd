extends SceneTree

var checks := 0
var failures := 0

func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		print("FAIL: " + description)
	else:
		print("PASS: " + description)

func _initialize() -> void:
	call_deferred("run")

func click_at(point: Vector2) -> void:
	var window_point := root.get_final_transform() * point
	var motion := InputEventMouseMotion.new()
	motion.position = window_point
	root.push_input(motion)
	await process_frame
	var press := InputEventMouseButton.new()
	press.position = window_point
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	root.push_input(press)
	await physics_frame
	await process_frame
	var release := InputEventMouseButton.new()
	release.position = window_point
	release.button_index = MOUSE_BUTTON_LEFT
	release.pressed = false
	root.push_input(release)
	await physics_frame
	await process_frame

func capture(filename: String) -> void:
	await RenderingServer.frame_post_draw
	var error := root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../" + filename))
	check(error == OK,"Rendered " + filename)

func run() -> void:
	check(ProjectSettings.get_setting("application/run/main_scene") == "res://scenes/world_map.tscn","World Map is application start scene")
	var world = load("res://scenes/world_map.tscn").instantiate()
	root.add_child(world)
	current_scene = world
	await process_frame
	await physics_frame
	check(world.level_buttons.size() == 5 and not world.level_buttons[0].disabled,"Five levels, first open")
	for i in range(2,5):
		check(world.level_buttons[i].disabled,"Level %d locked" % (i+1))
	await click_at(Vector2(829,649))
	check(current_scene == world,"Locked level click cannot change scene")
	await capture("AcademicDefence-v004-map1-world.png")
	await click_at(Vector2(223,845))
	var main = current_scene
	check(main.name == "Main","First level click loads battle")
	await click_at(main.map.slots.get_child(4).global_position)
	check(main.ui.build_menu.visible and main.game.gold == 200,"Slot opens menu without spending")
	check(not main.ui.book_button.disabled and not main.ui.blackboard_button.disabled,"Both towers affordable initially")
	check(main.ui.book_button.texture_normal.get_size() == Vector2(200,200),"Radial choice uses fixed-canvas artwork")
	await capture("AcademicDefence-v004-map1-build.png")
	var rect: Rect2 = main.ui.blackboard_button.get_global_rect()
	await click_at(rect.get_center())
	check(main.map.slots.get_child(4).tower.tower_type == "blackboard" and main.game.gold == 100,"Actual Blackboard build choice")
	await click_at(main.map.slots.get_child(6).global_position)
	await click_at(main.ui.book_button.get_global_rect().get_center())
	check(main.map.slots.get_child(6).tower.tower_type == "book" and main.game.gold == 30,"Actual Book build choice")
	await click_at(main.map.slots.get_child(1).global_position)
	check(main.ui.book_button.disabled and main.ui.blackboard_button.disabled,"Both buttons disabled when funds insufficient")
	await click_at(main.ui.blackboard_button.get_global_rect().get_center())
	check(main.game.gold == 30 and not main.map.slots.get_child(1).occupied,"Disabled click cannot build")
	await click_at(Vector2(1000,260))
	check(not main.ui.build_menu.visible,"Outside click closes menu")
	await click_at(Vector2(1210,95))
	check(main.waves.active and main.waves.wave == 1,"Actual Start Wave input")
	await create_timer(0.15).timeout
	await click_at(Vector2(1390,95))
	check(paused and main.ui.pause_overlay.visible,"Pause button pauses battle")
	var student = main.waves.students[0]
	var progress_before: float = student.progress
	await create_timer(0.2,true).timeout
	check(student.progress == progress_before,"Paused student remains still")
	await click_at(Vector2(1390,95))
	check(not paused and not main.ui.pause_overlay.visible,"Pause button resumes battle")
	await click_at(Vector2(1585,95))
	main = current_scene
	check(main.game.gold == 200 and main.game.lives == 10 and main.waves.wave == 0,"Actual restart resets battle")
	check(main.map.towers.get_child_count() == 0,"Restart removes both tower types")
	main.build(main.map.slots.get_child(4),"blackboard")
	main.build(main.map.slots.get_child(6),"book")
	main.waves.wave = 2
	seed(12)
	main.waves.start_wave()
	Engine.time_scale = 8
	await create_timer(13).timeout
	Engine.time_scale = 1
	await capture("AcademicDefence-v004-map1-gameplay.png")
	DisplayServer.window_set_size(Vector2i(1000,700))
	await process_frame
	await process_frame
	await click_at(Vector2(1585,95))
	main = current_scene
	await click_at(main.map.slots.get_child(4).global_position)
	check(main.ui.build_menu.visible,"Resized window slot coordinates")
	await click_at(main.ui.blackboard_button.get_global_rect().get_center())
	check(main.game.gold == 100,"Resized window build button coordinates")
	await click_at(Vector2(1490,95))
	check(current_scene.name == "WorldMap" and not paused,"Return to World Map")
	await click_at(Vector2(223,845))
	check(current_scene.name == "Main" and current_scene.game.gold == 200,"World Map re-entry starts clean round")
	print("VISUAL MAP1 V0.004: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)

