extends SceneTree
var checks := 0
var failures := 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		print("FAIL: " + message)
func _initialize() -> void: call_deferred("run")
func click_at(point: Vector2) -> void:
	var actual: Vector2 = root.get_final_transform() * point
	var motion := InputEventMouseMotion.new()
	motion.position = actual
	root.push_input(motion)
	await process_frame
	for pressed in [true,false]:
		var event := InputEventMouseButton.new()
		event.position = actual
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		root.push_input(event)
		await physics_frame
		await process_frame
func capture(name: String) -> void:
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../AcademicDefence-economy-%s.png" % name)) == OK,"Rendered " + name)
func run() -> void:
	for scene in ["main","main_map2"]:
		var main = load("res://scenes/%s.tscn" % scene).instantiate()
		root.add_child(main)
		await process_frame
		main.game.gold = 1500
		main.update_ui()
		var slot = main.map.slots.get_child(2)
		await click_at(slot.global_position)
		check(main.ui.build_menu.position+Vector2(220,220) == slot.global_position,"Radial centered")
		await capture(scene+"-radial")
		await click_at(main.ui.study_button.get_global_rect().get_center())
		check(slot.occupied and slot.tower.tower_type == "economy" and main.game.gold == 1400,"Real Study build click")
		check(not main.ui.build_menu.visible,"Build closes radial")
		await click_at(slot.global_position)
		check(main.ui.specialization_panel.visible and not main.ui.upgrade_button.visible,"Real Study banner with three choices")
		await capture(scene+"-study")
		var position_before: Vector2 = slot.tower.global_position
		await click_at(main.ui.specialization_buttons[1].get_global_rect().get_center())
		check(slot.tower.branch == "scholarship" and main.game.gold == 1280,"Real Office specialization click charges once")
		check(not main.ui.specialization_panel.visible and slot.tower.show_range,"Office hides other branches and shows radius")
		check(slot.tower.global_position == position_before,"Position unchanged")
		await capture(scene+"-office")
		await click_at(Vector2(1000,340))
		check(not main.ui.tower_banner.visible and not slot.tower.show_range,"Ground deselects Office")
		await click_at(slot.global_position)
		await click_at(main.ui.banner_sell.get_global_rect().get_center())
		check(not slot.occupied and main.game.gold == 1390,"Real Office sale refunds110")
		for branch_index in [0,2]:
			await click_at(slot.global_position)
			await click_at(main.ui.study_button.get_global_rect().get_center())
			await click_at(slot.global_position)
			await click_at(main.ui.specialization_buttons[branch_index].get_global_rect().get_center())
			var building = slot.tower
			check(building.branch == ("library" if branch_index == 0 else "research"),"Actual branch button selects correct branch")
			check(not building.show_range,"Library/Research no circle")
			for frame_index in range(5):
				building.visual_time = float(frame_index) / 3.0
				building.active_time = 0.45 if frame_index == 4 else 0.0
				building._process(0)
				check(building.frames[frame_index].get_size() == Vector2(360,320),"Identical frame canvas")
				check(building.global_position == position_before and building.sprite.scale == Vector2.ONE*0.29,"Stable origin and scale")
				await capture("%s-%s-%d" % [scene,building.branch,frame_index])
			await click_at(main.ui.banner_sell.get_global_rect().get_center())
		main.free()
		await process_frame
	print("ECONOMY VISUAL: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
