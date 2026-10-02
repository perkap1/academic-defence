extends "res://tests/test_visual.gd"

func run() -> void:
	var world = load("res://scenes/world_map.tscn").instantiate()
	root.add_child(world)
	current_scene = world
	await process_frame
	await physics_frame
	check(not world.level_buttons[1].disabled,"Map2 available from World Map")
	await capture("AcademicDefence-v004-world.png")
	await click_at(Vector2(490,758))
	var main = current_scene
	check(main.map.level_id == 2 and main.map.slots.get_child_count() == 8,"World Map node2 loads eight-slot Map2")
	check(main.ui.wave_label.text == "0 / 12","Map2 wave HUD is dynamic")
	await capture("AcademicDefence-v004-map2.png")
	# Render the baked curve for a separate alignment review, not in the game UI.
	var line := Line2D.new()
	line.points = main.map.route.curve.get_baked_points()
	line.width = 4
	line.default_color = Color("f44336")
	main.map.effects.add_child(line)
	await capture("AcademicDefence-v004-route-check.png")
	line.queue_free()
	var a = main.map.slots.get_child(2)
	var b = main.map.slots.get_child(3)
	var anchor: Vector2 = a.position
	await click_at(a.global_position)
	await click_at(main.ui.blackboard_button.get_global_rect().get_center())
	check(a.occupied and main.game.gold == 100,"Build Blackboard on Map2")
	await click_at(b.global_position)
	await click_at(main.ui.book_button.get_global_rect().get_center())
	check(b.occupied and main.game.gold == 30,"Build Book on Map2")
	await RenderingServer.frame_post_draw
	var pixel_position: Vector2 = root.get_final_transform() * (b.global_position + Vector2(0,10))
	var base_pixel := root.get_texture().get_image().get_pixelv(Vector2i(pixel_position))
	check(base_pixel.is_equal_approx(Color("173c2b")),"Built tower still fully covers painted placeholder circle")
	# Click the tower artwork above its original build-circle hit area.
	await click_at(a.global_position+Vector2(0,-100))
	check(a.tower.show_range and main.ui.tower_panel.visible,"Artwork click selects tower and SELL panel")
	check(main.ui.sell_button.text.contains("50"),"Blackboard SELL displays50 refund")
	await capture("AcademicDefence-v004-sell.png")
	await click_at(Vector2(1400,270))
	check(not a.tower.show_range and not main.ui.tower_panel.visible,"Ground click deselects tower")
	await click_at(a.global_position)
	await click_at(b.global_position+Vector2(0,-100))
	check(not a.tower.show_range and b.tower.show_range,"Tower switch shows exactly one range")
	await click_at(main.map.slots.get_child(5).global_position)
	check(not b.tower.show_range and main.ui.build_menu.visible,"Empty-slot click closes old tower range")
	await click_at(Vector2(1400,270))
	await click_at(b.global_position)
	await click_at(main.ui.sell_button.get_global_rect().get_center())
	check(not b.occupied and b.tower == null and main.game.gold == 65,"Actual SELL refunds35 and empties slot")
	await click_at(b.global_position)
	check(main.ui.book_button.disabled,"65KP cannot buy70KP Book")
	await click_at(Vector2(1400,270))
	await click_at(a.global_position)
	await click_at(main.ui.sell_button.get_global_rect().get_center())
	check(main.game.gold == 115 and not a.occupied,"Actual Blackboard sale refunds50")
	await click_at(a.global_position)
	await click_at(main.ui.book_button.get_global_rect().get_center())
	check(a.occupied and a.tower.tower_type == "book" and main.game.gold == 45,"Sold slot allows new tower")
	check(a.position == anchor,"Hover, selection, sale and rebuild retain exact anchor")
	await click_at(a.global_position)
	await click_at(Vector2(1390,95))
	check(paused and not a.tower.show_range and not main.ui.tower_panel.visible,"Pause clears selection")
	await click_at(Vector2(1390,95))
	await click_at(Vector2(1585,95))
	main = current_scene
	check(main.map.level_id == 2 and main.waves.counts.size() == 12 and main.game.gold == 200,"Restart stays on clean Map2")
	main.build(main.map.slots.get_child(2),"blackboard")
	main.build(main.map.slots.get_child(4),"book")
	main.waves.wave = 4
	seed(12)
	await click_at(Vector2(1210,95))
	check(main.waves.wave == 5 and main.waves.active,"Map2 starts mixed wave5")
	Engine.time_scale = 8
	await create_timer(12).timeout
	Engine.time_scale = 1
	await capture("AcademicDefence-v004-map2-gameplay.png")
	await click_at(Vector2(1390,95))
	if main.waves.students.size() > 0:
		var student = main.waves.students[0]
		student.apply_slow()
		var before: float = student.progress
		await create_timer(0.2,true).timeout
		check(student.progress == before and student.slow_remaining == 2.0,"Pause freezes both movement and slow timer")
	await click_at(Vector2(1390,95))
	DisplayServer.window_set_size(Vector2i(1000,700))
	await process_frame
	await process_frame
	await click_at(Vector2(1585,95))
	main = current_scene
	await click_at(main.map.slots.get_child(4).global_position)
	await click_at(main.ui.blackboard_button.get_global_rect().get_center())
	await click_at(main.map.slots.get_child(4).global_position+Vector2(0,-90))
	await click_at(main.ui.sell_button.get_global_rect().get_center())
	check(main.game.gold == 150,"Resized window build and SELL retain correct coordinates")
	await click_at(Vector2(1490,95))
	check(current_scene.name == "WorldMap" and not paused,"Map2 returns to World Map")
	await click_at(Vector2(223,845))
	check(current_scene.map.level_id == 1 and current_scene.waves.counts.size() == 7,"Map1 remains accessible with seven waves")
	print("VISUAL MAP2 V0.004: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
