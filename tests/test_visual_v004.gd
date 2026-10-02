extends "res://tests/test_visual.gd"

func run() -> void:
	var main = load("res://scenes/main_map2.tscn").instantiate()
	root.add_child(main)
	current_scene = main
	await process_frame
	await physics_frame
	var slot = main.map.slots.get_child(2)
	await click_at(slot.global_position)
	check(main.ui.build_menu.visible,"Slot opens radial menu")
	var center: Vector2 = main.ui.build_menu.get_global_rect().get_center()
	check(center == slot.global_position,"Radial is centered on slot")
	await capture("AcademicDefence-v004-radial.png")
	var motion := InputEventMouseMotion.new()
	motion.position = root.get_final_transform() * main.ui.book_button.get_global_rect().get_center()
	root.push_input(motion)
	await process_frame
	check(main.ui.build_menu.get_global_rect().get_center() == center,"Hover never shifts radial center")
	main.game.gold = 69
	main.update_ui()
	await capture("AcademicDefence-v004-radial-disabled.png")
	await click_at(main.ui.book_button.get_global_rect().get_center())
	check(not slot.occupied and main.game.gold == 69 and main.ui.build_menu.visible,"Disabled radial click does not build or dismiss")
	await click_at(center+Vector2(215,215))
	check(not main.ui.build_menu.visible,"Outside circular menu dismisses even inside its bounding square")
	main.game.gold = 200
	main.update_ui()
	await click_at(slot.global_position)
	await click_at(main.ui.blackboard_button.get_global_rect().get_center())
	check(slot.occupied and main.game.gold == 100 and not main.ui.build_menu.visible,"Radial builds Blackboard and disappears")
	var second = main.map.slots.get_child(4)
	await click_at(second.global_position)
	await click_at(main.ui.book_button.get_global_rect().get_center())
	check(second.occupied and main.game.gold == 30 and not main.ui.build_menu.visible,"Radial builds Book and disappears")
	# Empty central disc intercepts input instead of selecting the underlying slot again.
	await click_at(main.map.slots.get_child(7).global_position)
	var selected_before = main.ui.selected_slot
	await click_at(main.ui.build_menu.get_global_rect().get_center())
	check(main.ui.selected_slot == selected_before and main.ui.build_menu.visible,"Center click never passes through radial menu")
	main.ui.close_build_menu()
	# Three student types share the same ordered artwork and immediate targeting removal.
	main.process_mode = Node.PROCESS_MODE_DISABLED
	var effects := []
	for i in range(3):
		var student = load("res://scenes/student.tscn").instantiate()
		student.configure("normal" if i == 0 else "pe","girl" if i == 2 else "boy")
		main.map.route.add_child(student)
		student.position = Vector2(690+i*110,450)
		student.resolved.connect(main.student_resolved)
		student.teach(100)
		check(student.done and not student.visible,"Graduated student immediately hidden and untargetable")
		effects.append(main.map.effects.get_child(main.map.effects.get_child_count()-1))
	for effect in effects: effect.advance(0.22)
	await capture("AcademicDefence-v004-poff.png")
	for effect in effects: effect.advance(0.36)
	await capture("AcademicDefence-v004-hats.png")
	for effect in effects: effect.advance(0.20)
	await capture("AcademicDefence-v004-stardust.png")
	for effect in effects: effect.advance(0.08)
	await process_frame
	check(get_nodes_in_group("graduation_effects").is_empty(),"All three completion effects clean up by0.86seconds")
	main.process_mode = Node.PROCESS_MODE_INHERIT
	var effect = load("res://scripts/graduation_effect.gd").new()
	effect.position = Vector2(800,450)
	main.map.effects.add_child(effect)
	await create_timer(0.1).timeout
	await click_at(Vector2(1390,95))
	var elapsed: float = effect.elapsed
	await create_timer(0.15,true).timeout
	check(effect.elapsed == elapsed,"Pause freezes graduation animation")
	await click_at(Vector2(1390,95))
	await create_timer(0.9).timeout
	check(not is_instance_valid(effect),"Resumed completion effect finishes and frees itself")
	DisplayServer.window_set_size(Vector2i(1000,700))
	await process_frame
	await process_frame
	await click_at(main.map.slots.get_child(0).global_position)
	check(main.ui.build_menu.get_global_rect().get_center() == main.map.slots.get_child(0).global_position,"Resized viewport keeps radial centered")
	print("VISUAL V0.004: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
